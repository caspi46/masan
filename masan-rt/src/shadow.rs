use crate::poison::Poison;
use libc::{mmap, MAP_ANON, MAP_FAILED, MAP_FIXED, MAP_PRIVATE, PROT_READ, PROT_WRITE};

// Shadow memory is mapped at a fixed offset chosen to sit in the
// middle of the macOS/arm64 address space gap — above the heap
// (~0x0000_0001_0000_0000) and below the stack (~0x7fff_0000_0000_0000).
// The shadow region covers 1/8th of addressable memory, so it needs
// roughly 16TB of virtual address space reserved here.
// Physical pages are only committed when actually written to.
const SHADOW_OFFSET: usize = 0x0000_1000_0000_0000;
const SHADOW_SIZE: usize = 1 << 32;

struct Shadow {
    base: usize,
    poison_counter: u64,
    unpoison_counter: u64,
}

impl Shadow {
    /// init
    /// mmap the shadow region at SHADOW_OFFSET
    /// All memory start as valid until poison something explicitly
    fn init() {
        unsafe {
            // set up the shadow memory location
            let result = mmap(
                SHADOW_OFFSET as *mut libc::c_void, // fixed address
                SHADOW_SIZE,                        // how many bytes to reserve
                PROT_READ | PROT_WRITE,             // readable and writable
                MAP_PRIVATE | MAP_ANON | MAP_FIXED, // anonymous, fixed, private
                -1,                                 // no file descriptor
                0,                                  // no offset
            );

            if result == MAP_FAILED {
                panic!("masan: failed to map shadow memory");
            }
        }
    }

    /// shadow_addr_of
    /// The corresponding shadow byte pointer of application address
    fn shadow_addr_of(app_addr: usize) -> *mut u8 {
        ((app_addr >> 3) + SHADOW_OFFSET) as *mut u8
    }

    /// poison
    /// Marks a region as invalid by writing a sentinel value
    /// into the corresponding shadow bytes.
    /// TODO:
    /// - Convert addr to its shadow address
    /// - Figure out how many shadow bytes to write
    /// - Write value into all of them
    fn poison(addr: *mut u8, size: usize, value: Poison) {
        todo!("TODO: poison")
    }

    /// unpoison
    /// Same as poison but writes 0x00 (fully valid)
    /// Called when a variable comes into scope
    fn unpoison(addr: *mut u8, size: usize) {
        todo!("TODO: unpoison")
    }

    /// check
    /// Reads the shadow byte for addr
    /// Returns None if valid
    /// Handles the partial validity case (1-7)
    /// Returns Some(Poison::...) if poisoned so the caller can report the right error
    fn check(addr: usize, access_size: usize) -> Option<Poison> {
        todo!("TODO: should work")
    }
}
