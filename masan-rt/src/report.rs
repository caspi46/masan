struct report {}

impl report {
    fn report_single_addr(addr: *mut u8, access_size: *mut u8, is_write: bool) {
        println!(
            "ADDRESS: {:?}, ACCESS_SIZE: {:?}, IS_WRITE: {}",
            addr, access_size, is_write
        );
    }

    fn print_stack_trace() {}
}
