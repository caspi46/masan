pub struct Report;

impl Report {
    pub fn handle_sanitizer_crash(addr: *mut u8, access_size: usize, poison_type: u8) {
        eprintln!("=================================================================");
        eprintln!(
            "==ERROR: AddressSanitizer: bad-memory-access on address {:#x}",
            addr as usize
        );
        eprintln!("Access size: {} bytes", access_size as usize);

        let error_desc = match poison_type {
            0xf1 => "stack-left-redzone (Stack Buffer Overflow)",
            0xf3 => "stack-right-redzone (Stack Buffer Overflow)",
            0xf8 => "stack-use-after-scope",
            0xfd => "heap-use-after-free",
            _ => "unknown-poison-access",
        };

        eprintln!("Violation Type: {}", error_desc);
        eprintln!("=================================================================");
        std::process::exit(1);
    }

    fn print_stack_trace() {}
}
