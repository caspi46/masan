use inkwell::context::Context;
use inkwell::memory_buffer::MemoryBuffer;
use masan_pass::instrument::Instrument;
use std::env;
use std::path::Path;

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        eprintln!("Usage: masan_pass <input.ll> [-o <output.ll>]");
        std::process::exit(1);
    }

    let input_path = &args[1];
    let output_path = if args.len() >= 4 && args[2] == "-o" {
        &args[3]
    } else {
        "instrumented.ll"
    };

    let context = Context::create();

    // Load the .ll file into an Inkwell MemoryBuffer first
    let buffer = MemoryBuffer::create_from_file(Path::new(input_path))
        .expect("Failed to read IR file into memory buffer");

    // Parse the IR module out of the buffer
    let module = context
        .create_module_from_ir(buffer)
        .expect("Failed to parse LLVM IR module");

    let mut worker = Instrument::new(&module);
    worker.run();

    module
        .print_to_file(Path::new(output_path))
        .expect("Failed to write instrumented LLVM IR file");
}
