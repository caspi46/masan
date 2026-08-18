pub mod poison;
pub mod report;
pub mod shadow;
use crate::report::Report;
use crate::shadow::Shadow;
use std::ffi::CStr;

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
    if addr.is_null() {
        Report::handle_sanitizer_crash(addr, size, 0xf1);
        return;
    }
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

// ===================================================================
// EXTERN "C" INTERCEPTOR CHCK FUNCTIONS
// ===================================================================
#[no_mangle]
pub unsafe extern "C" fn __free_chk(addr: *mut u8, size: usize) {
    if addr.is_null() {
        // free(NULL);
        return;
    }
    __unpoison_memory(addr, size);
}

#[no_mangle]
pub unsafe extern "C" fn strcpy(dest: *mut u8, src: *const u8) -> *mut u8 {
    copy_c_string(dest, src)
}

#[no_mangle]
pub unsafe extern "C" fn __strcpy_chk(dest: *mut u8, src: *const u8, _dest_size: usize) -> *mut u8 {
    copy_c_string(dest, src)
}

unsafe fn copy_c_string(dest: *mut u8, src: *const u8) -> *mut u8 {
    let bytes = CStr::from_ptr(src.cast()).to_bytes_with_nul();
    __check_memory_access(dest, bytes.len());

    for (offset, byte) in bytes.iter().enumerate() {
        *dest.add(offset) = *byte;
    }

    dest
}
