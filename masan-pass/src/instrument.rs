use std::cell::RefCell;

use inkwell::basic_block::BasicBlock;
use inkwell::builder::Builder;
use inkwell::context::ContextRef;
use inkwell::module::{Linkage, Module};
use inkwell::passes::PassBuilderOptions;
use inkwell::targets::{CodeModel, FileType, RelocMode, Target, TargetMachine, TargetTriple};
use inkwell::types::BasicTypeEnum::{
    ArrayType, FloatType, IntType, PointerType, ScalableVectorType, StructType, VectorType,
};
use inkwell::values::AsValueRef;
use inkwell::values::InstructionValue;
use inkwell::values::{
    AnyValue, AnyValueEnum, BasicMetadataValueEnum, BasicValue, CallSiteValue, FunctionValue,
    InstructionOpcode, IntValue, PointerValue,
};
use inkwell::AddressSpace;
use llvm_sys::core::LLVMGetIntrinsicID;

#[derive(Debug)]
pub struct Instrument<'a, 'ctx> {
    context: ContextRef<'ctx>,
    module: &'a Module<'ctx>,
    builder: Builder<'ctx>,
    lifetime_end_id: u32,
    poison_fn: Option<FunctionValue<'ctx>>,
    unpoison_fn: Option<FunctionValue<'ctx>>,
}

impl<'a, 'ctx> Instrument<'a, 'ctx> {
    fn new(module: &'a Module<'ctx>) -> Self {
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
        }
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
        if let Some(f) = self.poison_fn {
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
        self.poison_fn = Some(f);
        f
    }

    fn get_or_declare_check_fn(&mut self) -> FunctionValue<'ctx> {
        if let Some(f) = self.poison_fn {
            return f;
        }
        let void_type = self.context.void_type();
        let ptr_type = self.context.ptr_type(AddressSpace::default());
        let i64_type = self.context.i64_type();

        let unpoison_fn_type = void_type.fn_type(&[ptr_type.into(), i64_type.into()], false);
        let f = self.module.add_function(
            "__check_memory_access",
            unpoison_fn_type,
            Some(Linkage::External),
        );
        self.poison_fn = Some(f);
        f
    }

    fn is_lifetime_end(&self, inst: InstructionValue<'ctx>) -> bool {
        if let Ok(call_site) = CallSiteValue::try_from(inst) {
            if let Some(called_fn) = call_site.get_called_fn_value() {
                let id = called_fn.get_intrinsic_id();
                return id != 0 && id == self.lifetime_end_id;
            }
        }
        false
    }
    fn run(&mut self) {
        for func in self.module.get_functions() {
            for bb in func.get_basic_blocks() {
                for inst in bb.get_instructions() {
                    self.analyze_inst(inst);
                }
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

            _ => (),
        }
    }

    fn analyze_call(&mut self, inst: InstructionValue<'ctx>) {
        // check if the inst has "lifetime.end"
        // the original llvm api (with c++) uses intrinsic to find the lifetime.end,
        // but the inkwell doesn't have the info in intrinsic (only ID according to its doc).
        // thus, find the specific keyword, "lifetime.end"

        let inst_size = if let Some(s) = self.get_inst_size(inst) {
            s
        } else {
            return;
        };

        if let Ok(call_site) = CallSiteValue::try_from(inst) {
            if let Some(called_fn) = call_site.get_called_fn_value() {
                let fn_name = called_fn.get_name().to_string_lossy();
                match fn_name.as_ref() {
                    "malloc" => (), // for future design (use-after-free)
                    "free" => (),   // for future design (use-after-free)
                    _ => {
                        // check if the call is for lifetime.end
                        if self.is_lifetime_end(inst) {
                            let ptr = match inst.try_into() {
                                Ok(ptr) => ptr,
                                Err(_) => return,
                            };
                            self.call_poison(ptr, inst_size, 0xf8);
                        }
                    }
                }
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

        self.builder.position_before(&inst);

        let rz_size = 32;
        let inst_size = size.get_zero_extended_constant().unwrap_or(8) as u32;

        let i8_type = self.context.i8_type();
        let left_rz_type = i8_type.array_type(rz_size);
        let inst_type = i8_type.array_type(inst_size);
        let right_rz_type = i8_type.array_type(rz_size);

        let struct_type = self.context.struct_type(
            &[left_rz_type.into(), inst_type.into(), right_rz_type.into()],
            false,
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

        inst.as_any_value_enum()
            .into_pointer_value()
            .replace_all_uses_with(inst_ptr);

        // let alloca_inst = alloca_ptr.as_instruction_value().unwrap();
        // let next_inst = alloca_inst.get_next_instruction().unwrap();
        // self.builder.position_before(&next_inst);

        let rz_size_val = self.context.i64_type().const_int(rz_size as u64, false);

        self.call_poison(left_rz_ptr, rz_size_val, 0xf1);
        self.call_unpoison(inst_ptr, size);
        self.call_poison(right_rz_ptr, rz_size_val, 0xf1);

        inst.erase_from_basic_block();
    }

    fn analyze_store(&mut self, inst: InstructionValue<'ctx>) {
        match inst.try_into() {
            Ok(ptr) => {
                if let Some(size) = self.get_inst_size(inst) {
                    self.builder.position_before(&inst);
                    self.call_check(ptr, size);
                }
            }
            Err(_) => return,
        };
    }

    fn analyze_load(&mut self, inst: InstructionValue<'ctx>) {
        match inst.try_into() {
            Ok(ptr) => {
                if let Some(size) = self.get_inst_size(inst) {
                    self.builder.position_before(&inst);
                    self.call_check(ptr, size);
                }
            }
            Err(_) => return,
        };
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
}
