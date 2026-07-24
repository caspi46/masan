pub mod poison;
pub mod report;
pub mod shadow;
use crate::report::Report;
use crate::shadow::Shadow;

// ===================================================================
// EXTERN "C" INTERFACE FOR LLVM INSTRUMENTATION PASS
// ===================================================================

#[no_mangle]
pub unsafe extern "C" fn __poison_memory(addr: *mut u8, size: usize, value: u8) {
    if let Ok(mut shadow) = Shadow::global().lock() {
        shadow.poison(addr, size, value);
    }
}

#[no_mangle]
pub unsafe extern "C" fn __unpoison_memory(addr: *mut u8, size: usize) {
    if let Ok(mut shadow) = Shadow::global().lock() {
        shadow.unpoison(addr, size);
    }
}

#[no_mangle]
pub unsafe extern "C" fn __check_memory_access(addr: *mut u8, size: usize) {
    let check_result = {
        if let Ok(shadow) = Shadow::global().lock() {
            shadow.check(addr as usize, size)
        } else {
            None
        }
    };

    if let Some(poison_type) = check_result {
        Report::handle_sanitizer_crash(addr, size, poison_type);
    }
}
