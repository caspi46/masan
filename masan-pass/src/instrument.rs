use std::cell::RefCell;

use inkwell::basic_block::BasicBlock;
use inkwell::builder::Builder;
use inkwell::context::ContextRef;
use inkwell::module::{Linkage, Module};
use inkwell::passes::PassBuilderOptions;
use inkwell::targets::{CodeModel, FileType, RelocMode, Target, TargetMachine, TargetTriple};
use inkwell::types::BasicTypeEnum::{
    self, ArrayType, FloatType, IntType, PointerType, ScalableVectorType, StructType, VectorType,
};
use inkwell::values::AsValueRef;
use inkwell::values::BasicValueEnum;
use inkwell::values::InstructionValue;
use inkwell::values::{
    AnyValue, AnyValueEnum, BasicMetadataValueEnum, BasicValue, CallSiteValue, FunctionValue,
    InstructionOpcode, IntValue, Operand, PointerValue,
};
use inkwell::AddressSpace;
use llvm_sys::core::LLVMGetIntrinsicID;
use std::collections::HashMap;

#[derive(Debug)]
pub struct Instrument<'a, 'ctx> {
    context: ContextRef<'ctx>,
    module: &'a Module<'ctx>,
    builder: Builder<'ctx>,
    lifetime_end_id: u32,
    poison_fn: Option<FunctionValue<'ctx>>,
    unpoison_fn: Option<FunctionValue<'ctx>>,
    check_fn: Option<FunctionValue<'ctx>>,
    alloca_to_payload: HashMap<PointerValue<'ctx>, PointerValue<'ctx>>,
    inst_to_size: HashMap<PointerValue<'ctx>, IntValue<'ctx>>,
}

impl<'a, 'ctx> Instrument<'a, 'ctx> {
    pub fn new(module: &'a Module<'ctx>) -> Self {
        let context = module.get_context();
        let lifetime_end_id = unsafe {
            let name = "llvm.lifetime.end.p0";
            llvm_sys::core::LLVMLookupIntrinsicID(name.as_ptr() as *const libc::c_char, name.len())
        };
        Self {
            context,
            module,
            builder: context.create_builder(),
            lifetime_end_id,
            poison_fn: None,
            unpoison_fn: None,
            check_fn: None,
            alloca_to_payload: HashMap::new(),
            inst_to_size: HashMap::new(),
        }
    }

    pub fn run(&mut self) {
        for func in self.module.get_functions() {
            eprintln!("MASAN DEBUG: commented passes version");
            self.inst_to_size.clear();
            // PASS 0: collect lifetime information before rewriting allocas
            let mut lifetime_ends = Vec::new();

            for bb in func.get_basic_blocks() {
                for inst in bb.get_instructions() {
                    println!("lifetime: {}", inst.print_to_string().to_string());
                    // if self.is_lifetime_start(inst) {
                    //     self.record_lifetime_start(inst);
                    // }

                    if self.is_lifetime_end(inst) {
                        println!("FOUND lifetime.end: {}", inst.print_to_string().to_string());

                        lifetime_ends.push(inst);
                    }
                }
            }

            // -------------------------------------------------------------
            // PASS 1: Transform all standard Alloca instructions into padded
            // redzone structs and replace user pointer usages first.
            // -------------------------------------------------------------
            let mut allocas = Vec::new();
            for bb in func.get_basic_blocks() {
                for inst in bb.get_instructions() {
                    if inst.get_opcode() == InstructionOpcode::Alloca {
                        allocas.push(inst);
                    }
                }
            }
            for alloca_inst in allocas {
                self.analyze_alloca(alloca_inst);
            }

            // -------------------------------------------------------------
            // PASS 2: Instrument Loads, Stores, Calls, and Returns against
            // the already updated/replaced payload pointers.
            // -------------------------------------------------------------
            for bb in func.get_basic_blocks() {
                let insts = bb.get_instructions();
                for inst in insts {
                    match inst.get_opcode() {
                        InstructionOpcode::Call => self.analyze_call(inst),
                        InstructionOpcode::Load => self.analyze_load(inst),
                        InstructionOpcode::Store => self.analyze_store(inst),
                        InstructionOpcode::Return => self.analyze_return(inst),
                        _ => (),
                    }
                }
            }

            // PASS 3: emit lifetime poison after mapping exists
            for lifetime_end in lifetime_ends {
                // let lifetime_end_ptr = match lifetime_end.get_operand(1) {
                //     Some(Operand::Value(v)) if v.is_pointer_value() => v.into_pointer_value(),
                //     _ => continue,
                // };
                self.handle_lifetime_end(lifetime_end);
            }
        }
    }
    // check the instruction's type: function call, alloc, and free
    fn analyze_inst(&mut self, inst: InstructionValue<'ctx>) {
        match inst.get_opcode() {
            InstructionOpcode::Call => {
                // check malloc and free
                self.analyze_call(inst);
            }
            InstructionOpcode::Alloca => {
                // stack allocation
                self.analyze_alloca(inst);
            }
            InstructionOpcode::Load => {
                // load (read)
                self.analyze_load(inst);
            }
            InstructionOpcode::Store => {
                // store (write)
                self.analyze_store(inst);
            }
            InstructionOpcode::Return => {
                // return
                self.analyze_return(inst);
            }

            _ => (),
        }
    }

    fn analyze_call(&mut self, inst: InstructionValue<'ctx>) {
        println!("CALL: {}", inst.print_to_string().to_string());
        let call_site = match CallSiteValue::try_from(inst) {
            Ok(site) => site,
            Err(_) => return,
        };

        let called_fn = match call_site.get_called_fn_value() {
            Some(f) => f,
            None => return,
        };

        let fn_name = called_fn.get_name().to_string_lossy();

        match fn_name.as_ref() {
            "malloc" => (), // For future design
            "free" => (),   // For future design
            _ => {
                // if self.is_lifetime_end(inst) {
                //     println!("LIFETIME DETECTED: {}", inst.print_to_string().to_string());
                //     self.handle_lifetime_end(inst);
                // }
            }
        }
    }

    /// analyze_alloca
    /// one unified struct for variable and redzones
    fn analyze_alloca(&mut self, inst: InstructionValue<'ctx>) {
        // variable type
        let size = if let Some(s) = self.get_inst_size(inst) {
            s
        } else {
            return;
        };
        // variable & redzones names
        let name = inst
            .get_name()
            .expect("alloca should have a name")
            .to_str()
            .unwrap_or("var");
        let original_ptr = inst.as_any_value_enum().into_pointer_value();

        self.builder.position_before(&inst);

        let rz_size = 32;
        let inst_size = size.get_zero_extended_constant().unwrap_or(8) as u32;

        let i8_type = self.context.i8_type();
        let left_rz_type = i8_type.array_type(rz_size);
        let inst_type = i8_type.array_type(inst_size);
        let right_rz_type = i8_type.array_type(rz_size);

        let struct_type = self.context.struct_type(
            &[left_rz_type.into(), inst_type.into(), right_rz_type.into()],
            true,
        );

        let alloca_ptr = self
            .builder
            .build_alloca(struct_type, &format!("alloca_{}", name))
            .expect("failed to build alloca struct");

        // ptrs
        let left_rz_ptr = self
            .builder
            .build_struct_gep(struct_type, alloca_ptr, 0, "left_rz_ptr")
            .unwrap();
        let inst_ptr = self
            .builder
            .build_struct_gep(struct_type, alloca_ptr, 1, "inst_ptr")
            .unwrap();
        let right_rz_ptr = self
            .builder
            .build_struct_gep(struct_type, alloca_ptr, 2, "right_rz_ptr")
            .unwrap();

        original_ptr.replace_all_uses_with(inst_ptr);

        let rz_size_val = self.context.i64_type().const_int(rz_size as u64, false);

        self.call_poison(left_rz_ptr, rz_size_val, 0xf1);
        self.call_unpoison(inst_ptr, size);
        self.call_poison(right_rz_ptr, rz_size_val, 0xf1);

        self.inst_to_size.insert(inst_ptr, size);

        self.alloca_to_payload.insert(original_ptr, inst_ptr);
        self.alloca_to_payload.insert(alloca_ptr, inst_ptr);
        self.alloca_to_payload.insert(inst_ptr, inst_ptr);

        inst.erase_from_basic_block();
    }

    fn analyze_store(&mut self, inst: InstructionValue<'ctx>) {
        let stored_val = match inst.get_operand(0) {
            Some(Operand::Value(v)) => v,
            _ => return,
        };

        let dest_ptr = match inst.get_operand(1) {
            Some(Operand::Value(v)) if v.is_pointer_value() => v.into_pointer_value(),
            _ => return,
        };

        let access_size_bytes = self.get_type_size_in_bytes(stored_val.get_type());

        let access_size_val = self
            .context
            .i64_type()
            .const_int(std::cmp::max(1, access_size_bytes), false);

        self.builder.position_before(&inst);
        self.call_check(dest_ptr, access_size_val);
    }

    fn analyze_return(&mut self, inst: InstructionValue<'ctx>) {
        let allocas: Vec<(PointerValue<'ctx>, IntValue<'ctx>)> = self
            .inst_to_size
            .iter()
            .map(|(&ptr, &size)| (ptr, size))
            .collect();

        self.builder.position_before(&inst);

        for (ptr, size) in allocas {
            self.call_poison(ptr, size, 0xf3); // 0xF3 = Stack Frame Returned
        }
    }

    fn get_type_size_in_bytes(&mut self, ty: BasicTypeEnum<'ctx>) -> u64 {
        match ty {
            ArrayType(at) => {
                let element_size = self.get_type_size_in_bytes(at.get_element_type());
                element_size * (at.len() as u64)
            }
            FloatType(ft) => (ft.get_bit_width() as u64 + 7) / 8,
            IntType(it) => (it.get_bit_width() as u64 + 7) / 8,
            PointerType(_) => 8, // assuming 64-bit target pointer
            VectorType(vt) => {
                let element_size = self.get_type_size_in_bytes(vt.get_element_type());
                element_size * (vt.get_size() as u64)
            }
            StructType(st) => {
                let mut size = 0;
                for field in st.get_field_types() {
                    size += self.get_type_size_in_bytes(field);
                }
                size
            }
            _ => 0,
        }
    }

    fn analyze_load(&mut self, inst: InstructionValue<'ctx>) {
        let pointer = match inst.get_operand(0) {
            Some(Operand::Value(v)) if v.is_pointer_value() => v.into_pointer_value(),
            _ => return,
        };
        let loaded_val = match inst.get_operand(0) {
            Some(Operand::Value(v)) => v,
            _ => return,
        };

        let access_size_bytes = self.get_type_size_in_bytes(loaded_val.get_type());

        let access_size_val = self
            .context
            .i64_type()
            .const_int(std::cmp::max(1, access_size_bytes), false);

        self.builder.position_before(&inst);
        self.call_check(pointer, access_size_val);
    }

    fn get_inst_size(&mut self, inst: InstructionValue<'ctx>) -> Option<IntValue<'ctx>> {
        let alloca_type = match inst.get_allocated_type() {
            Ok(t) => t,
            Err(_) => return None,
        };

        // allocated size
        match alloca_type {
            ArrayType(at) => at.size_of(),
            IntType(it) => Some(it.size_of()),
            PointerType(pt) => Some(pt.size_of()),
            StructType(st) => st.size_of(),
            VectorType(vt) => vt.size_of(),
            ScalableVectorType(svt) => svt.size_of(),
            _ => None,
        }
    }

    fn call_poison(&mut self, pv: PointerValue<'ctx>, size: IntValue<'ctx>, poison_type: u64) {
        let call_name = format!("{}_call", pv.get_name().to_str().unwrap_or("pv_name"));
        let pv_addr = pv.as_basic_value_enum().into();

        let args = &[
            pv_addr,
            size.into(),
            self.context.i8_type().const_int(poison_type, false).into(),
        ];
        let pf = self.get_or_declare_poison_fn();
        self.builder.build_call(pf, args, &call_name).unwrap();
    }

    fn call_unpoison(&mut self, pv: PointerValue<'ctx>, size: IntValue<'ctx>) {
        let call_name = format!("{}_call", pv.get_name().to_str().unwrap_or("unpoison"));
        let pv_addr = pv.as_basic_value_enum().into();

        let args = &[pv_addr, size.into()];
        let pf = self.get_or_declare_unpoison_fn();
        self.builder.build_call(pf, args, &call_name).unwrap();
    }

    fn call_check(&mut self, pv: PointerValue<'ctx>, size: IntValue<'ctx>) {
        let call_name = format!("{}_call", pv.get_name().to_str().unwrap_or("check"));
        let pv_addr = pv.as_basic_value_enum().into();

        let args = &[pv_addr, size.into()];
        let pf = self.get_or_declare_check_fn();
        self.builder.build_call(pf, args, &call_name).unwrap();
    }

    fn get_or_declare_poison_fn(&mut self) -> FunctionValue<'ctx> {
        if let Some(f) = self.poison_fn {
            return f;
        }
        let void_type = self.context.void_type();
        let ptr_type = self.context.ptr_type(AddressSpace::default());
        let i64_type = self.context.i64_type();
        let i8_type = self.context.i8_type();

        let poison_fn_type =
            void_type.fn_type(&[ptr_type.into(), i64_type.into(), i8_type.into()], false);
        let f =
            self.module
                .add_function("__poison_memory", poison_fn_type, Some(Linkage::External));
        self.poison_fn = Some(f);
        f
    }

    fn get_or_declare_unpoison_fn(&mut self) -> FunctionValue<'ctx> {
        if let Some(f) = self.unpoison_fn {
            return f;
        }
        let void_type = self.context.void_type();
        let ptr_type = self.context.ptr_type(AddressSpace::default());
        let i64_type = self.context.i64_type();

        let unpoison_fn_type = void_type.fn_type(&[ptr_type.into(), i64_type.into()], false);
        let f = self.module.add_function(
            "__unpoison_memory",
            unpoison_fn_type,
            Some(Linkage::External),
        );
        self.unpoison_fn = Some(f);
        f
    }

    fn get_or_declare_check_fn(&mut self) -> FunctionValue<'ctx> {
        if let Some(f) = self.check_fn {
            return f;
        }
        let void_type = self.context.void_type();
        let ptr_type = self.context.ptr_type(AddressSpace::default());
        let i64_type = self.context.i64_type();

        let check_fn_type = void_type.fn_type(&[ptr_type.into(), i64_type.into()], false);
        let f = self.module.add_function(
            "__check_memory_access",
            check_fn_type,
            Some(Linkage::External),
        );
        self.check_fn = Some(f);
        f
    }

    fn is_lifetime_end(&self, inst: InstructionValue<'ctx>) -> bool {
        let call_site = match CallSiteValue::try_from(inst) {
            Ok(c) => c,
            Err(_) => return false,
        };

        let called = match call_site.get_called_fn_value() {
            Some(f) => f,
            None => return false,
        };

        let name = called.get_name();

        name.to_str()
            .map(|n| n.starts_with("llvm.lifetime.end"))
            .unwrap_or(false)
    }

    fn get_lifetime_ptr(&self, inst: InstructionValue<'ctx>) -> Option<PointerValue<'ctx>> {
        for i in 0..inst.get_num_operands() {
            if let Some(Operand::Value(v)) = inst.get_operand(i) {
                if v.is_pointer_value() {
                    return Some(v.into_pointer_value());
                }
            }
        }

        None
    }

    // fn handle_lifetime_end_ptr(&mut self, ptr: PointerValue<'ctx>) {
    //     let base_ptr = self.get_base_ptr(ptr);

    //     let payload_ptr = if let Some(&payload) = self.alloca_to_payload.get(&base_ptr) {
    //         payload
    //     } else if let Some(&payload) = self.alloca_to_payload.get(&ptr) {
    //         payload
    //     } else {
    //         return;
    //     };

    //     if let Some(&size) = self.inst_to_size.get(&payload_ptr) {
    //         self.builder.position_before(&inst);
    //         self.call_poison(payload_ptr, size, 0xf8);
    //     }
    // }

    fn handle_lifetime_end(&mut self, inst: InstructionValue<'ctx>) {
        // 1. Extract pointer operand from llvm.lifetime.end
        // LLVM versions differ:
        //   old: llvm.lifetime.end(i64 size, ptr %var)
        //   new: llvm.lifetime.end(ptr %var)

        let ptr = match self.get_lifetime_ptr(inst) {
            Some(p) => p,
            None => return,
        };
        // 2. Resolve original allocation pointer through GEP/bitcast chain
        let base_ptr = self.get_base_ptr(ptr);

        // 3. Resolve payload pointer
        let payload_ptr = match self.alloca_to_payload.get(&base_ptr) {
            Some(&payload) => payload,

            None => match self.alloca_to_payload.get(&ptr) {
                Some(&payload) => payload,

                None if self.inst_to_size.contains_key(&ptr) => ptr,

                None if self.inst_to_size.contains_key(&base_ptr) => base_ptr,

                None => return,
            },
        };

        // 4. Insert poison BEFORE lifetime.end
        if let Some(&size) = self.inst_to_size.get(&payload_ptr) {
            self.builder.position_before(&inst);

            // 0xf8 = stack-use-after-scope
            self.call_poison(payload_ptr, size, 0xf8);

            // Optional:
            // Remove LLVM lifetime marker because MASAN now manages the lifetime.
            // inst.erase_from_basic_block();
        }
    }
    fn get_base_ptr(&self, mut ptr: PointerValue<'ctx>) -> PointerValue<'ctx> {
        // Limit loop depth to prevent infinite loops on recursive GEPs
        for _ in 0..16 {
            let val = ptr.as_instruction_value();

            if let Some(inst) = val {
                match inst.get_opcode() {
                    InstructionOpcode::GetElementPtr
                    | InstructionOpcode::BitCast
                    | InstructionOpcode::AddrSpaceCast => {
                        if let Some(Operand::Value(base)) = inst.get_operand(0) {
                            if base.is_pointer_value() {
                                ptr = base.into_pointer_value();
                                continue;
                            }
                        }
                    }
                    _ => break,
                }
            } else {
                break;
            }
        }
        ptr
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use inkwell::context::Context;

    #[test]
    fn test_analyze_alloca() {
        // 1. create a context and module
        let context = Context::create();
        let module = context.create_module("test");
        let builder = context.create_builder();

        // 2. create a simple function with an alloca
        let fn_type = context.void_type().fn_type(&[], false);
        let func = module.add_function("test_fn", fn_type, None);
        let bb = context.append_basic_block(func, "entry");
        builder.position_at_end(bb);

        // 3. add an alloca — simulates char buf[8]
        let alloca = builder
            .build_alloca(context.i8_type().array_type(8), "buf")
            .unwrap();

        // add return
        builder.build_return(None).unwrap();

        // 4. print IR before pass
        println!("=== BEFORE ===");
        module.print_to_stderr();

        // 5. run your pass
        let mut worker = Instrument::new(&module);
        worker.run();

        // 6. print IR after pass
        println!("=== AFTER ===");
        module.print_to_stderr();

        // 7. verify IR was modified
        // check that __miniasan_poison calls exist in the module
        let poison_fn = module.get_function("__poison_memory");
        assert!(
            poison_fn.is_some(),
            "poison_memory function should be declared"
        );
    }

    #[test]
    fn test_lifetime_end() {
        // 1. create a context and module
        let context = Context::create();
        let module = context.create_module("test");
        let builder = context.create_builder();

        // 2. create a simple function with an alloca
        let fn_type = context.void_type().fn_type(&[], false);
        let func = module.add_function("test_fn", fn_type, None);
        let bb = context.append_basic_block(func, "entry");
        builder.position_at_end(bb);

        // 3. add an alloca — simulates char buf[8]
        let alloca = builder
            .build_alloca(context.i8_type().array_type(8), "buf")
            .unwrap();

        let intrinsic = inkwell::intrinsics::Intrinsic::find("llvm.lifetime.end").unwrap();
        let lifetime_end_fn = intrinsic
            .get_declaration(
                &module,
                &[context.ptr_type(inkwell::AddressSpace::default()).into()],
            )
            .expect("Failed to declare llvm.lifetime.end intrinsic");

        let size_val = context.i64_type().const_int(8, false).into();
        let ptr_val = alloca.into();

        builder
            .build_call(lifetime_end_fn, &[size_val, ptr_val], "lifetime_end")
            .unwrap();

        // add return
        builder.build_return(None).unwrap();

        // 4. print IR before pass
        println!("=== BEFORE ===");
        module.print_to_stderr();

        // 5. run your pass
        let mut worker = Instrument::new(&module);
        worker.run();

        // 6. print IR after pass
        println!("=== AFTER ===");
        module.print_to_stderr();

        // 7. verify IR was modified
        // check that __miniasan_poison calls exist in the module
        let poison_fn = module.get_function("__poison_memory");
        assert!(
            poison_fn.is_some(),
            "poison_memory function should be declared"
        );
    }

    #[test]
    fn test_store() {
        // 1. create a context and module
        let context = Context::create();
        let module = context.create_module("test");
        let builder = context.create_builder();

        // 2. create a simple function with an alloca
        let fn_type = context.void_type().fn_type(&[], false);
        let func = module.add_function("test_fn", fn_type, None);
        let bb = context.append_basic_block(func, "entry");
        builder.position_at_end(bb);

        // 3. add an alloca — simulates char buf[8]
        let alloca = builder
            .build_alloca(context.i8_type().array_type(8), "buf")
            .unwrap();

        let store_value = context.i8_type().const_int(1, false);
        let store = builder.build_store(alloca, store_value);

        let intrinsic = inkwell::intrinsics::Intrinsic::find("llvm.lifetime.end").unwrap();
        let lifetime_end_fn = intrinsic
            .get_declaration(
                &module,
                &[context.ptr_type(inkwell::AddressSpace::default()).into()],
            )
            .expect("Failed to declare llvm.lifetime.end intrinsic");

        let size_val = context.i64_type().const_int(8, false).into();
        let ptr_val = alloca.into();

        builder
            .build_call(lifetime_end_fn, &[size_val, ptr_val], "lifetime_end")
            .unwrap();

        // add return
        builder.build_return(None).unwrap();

        // 4. print IR before pass
        println!("=== BEFORE ===");
        module.print_to_stderr();

        // 5. run your pass
        let mut worker = Instrument::new(&module);
        worker.run();

        // 6. print IR after pass
        println!("=== AFTER ===");
        module.print_to_stderr();

        // 7. verify IR was modified
        // check that __miniasan_poison calls exist in the module
        let poison_fn = module.get_function("__poison_memory");
        assert!(
            poison_fn.is_some(),
            "poison_memory function should be declared"
        );
    }

    #[test]
    fn test_load() {
        // 1. create a context and module
        let context = Context::create();
        let module = context.create_module("test");
        let builder = context.create_builder();

        // 2. create a simple function with an alloca
        let fn_type = context.void_type().fn_type(&[], false);
        let func = module.add_function("test_fn", fn_type, None);
        let bb = context.append_basic_block(func, "entry");
        builder.position_at_end(bb);

        // 3. add an alloca — simulates char buf[8]
        let alloca = builder
            .build_alloca(context.i8_type().array_type(8), "buf")
            .unwrap();

        let store_value = context.i8_type().const_int(1, false);
        let _store = builder.build_store(alloca, store_value);

        let _load = builder.build_load(context.i8_type().array_type(8), alloca, "load");

        let intrinsic = inkwell::intrinsics::Intrinsic::find("llvm.lifetime.end").unwrap();
        let lifetime_end_fn = intrinsic
            .get_declaration(
                &module,
                &[context.ptr_type(inkwell::AddressSpace::default()).into()],
            )
            .expect("Failed to declare llvm.lifetime.end intrinsic");

        let size_val = context.i64_type().const_int(8, false).into();
        let ptr_val = alloca.into();

        builder
            .build_call(lifetime_end_fn, &[size_val, ptr_val], "lifetime_end")
            .unwrap();

        // add return
        builder.build_return(None).unwrap();

        // 4. print IR before pass
        println!("=== BEFORE ===");
        module.print_to_stderr();

        // 5. run your pass
        let mut worker = Instrument::new(&module);
        worker.run();

        // 6. print IR after pass
        println!("=== AFTER ===");
        module.print_to_stderr();

        // 7. verify IR was modified
        // check that __miniasan_poison calls exist in the module
        let poison_fn = module.get_function("__poison_memory");
        assert!(
            poison_fn.is_some(),
            "poison_memory function should be declared"
        );
    }
}
