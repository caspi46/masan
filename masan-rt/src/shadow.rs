use crate::poison::Poison::{
    self, BUF_OVERFLOW, HEAP_OVERFLOW, UNPOISON, USE_AFTER_FREE, USE_AFTER_SCOPE,
};
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
    fn shadow_addr_of(&self, app_addr: usize) -> usize {
        (app_addr >> 3) + SHADOW_OFFSET
    }

    /// poison
    /// Marks a region as invalid by writing a sentinel value
    /// into the corresponding shadow bytes.
    /// TODO:
    /// - Convert addr to its shadow address
    /// - Figure out how many shadow bytes to write
    /// - Write value into all of them
    fn poison(&mut self, addr: *mut u8, size: usize, value: Poison) {
        let addr_bytes = if size % 8 == 0 {
            size / 8
        } else {
            (size / 8) + 1
        };

        for i in 0..addr_bytes {
            let shadow_byte = self.shadow_addr_of(addr as usize + i * 8) as *mut u8;
            let p_value = match value {
                BUF_OVERFLOW => 0xf1,
                USE_AFTER_SCOPE => 0xf8,
                HEAP_OVERFLOW => 0xfa,
                USE_AFTER_FREE => 0xfd,
                UNPOISON => 0x00, // stay!
            };
            unsafe {
                std::ptr::write(shadow_byte, p_value);
            }
            self.poison_counter += 1;
        }

        todo!("test required");
    }

    /// unpoison
    /// Same as poison but writes 0x00 (fully valid)
    /// Called when a variable comes into scope
    fn unpoison(&mut self, addr: *mut u8, size: usize) {
        let addr_bytes = if size % 8 == 0 {
            size / 8
        } else {
            (size / 8) + 1
        };

        for i in 0..addr_bytes {
            let shadow_byte = self.shadow_addr_of(addr as usize + i * 8) as *mut u8;
            unsafe {
                std::ptr::write(shadow_byte, 0x00);
            }
            self.unpoison_counter += 1;
        }
        todo!("test required");
    }

    /// check
    /// Reads the shadow byte for addr
    /// Returns None if valid
    /// Handles the partial validity case (1-7)
    /// Returns Some(Poison::...) if poisoned so the caller can report the right error
    fn check(&self, addr: usize, access_size: usize) -> Option<Poison> {
        let addr_bytes = if access_size % 8 == 0 {
            access_size / 8
        } else {
            (access_size / 8) + 1
        };

        for i in 0..addr_bytes {
            let shadow_byte = self.shadow_addr_of(addr as usize + i * 8) as *mut u8;
            unsafe {
                let state_byte = std::ptr::read(shadow_byte);
                let state = match state_byte {
                    0xf1 => Some(BUF_OVERFLOW),
                    0xf8 => Some(USE_AFTER_SCOPE),
                    0xfa => Some(HEAP_OVERFLOW),
                    0xfd => Some(USE_AFTER_FREE),
                    0x00 => Some(UNPOISON),
                    _ => None,
                };
                return state;
            }
        }
        return None;
    }
}
