use crate::poison::Poison::{
    self, BUF_OVERFLOW, HEAP_OVERFLOW, UNPOISON, USE_AFTER_FREE, USE_AFTER_SCOPE,
};
use libc::{mmap, MAP_ANON, MAP_FAILED, MAP_FIXED, MAP_PRIVATE, PROT_READ, PROT_WRITE};
use std::cell::RefCell;
use std::sync::{Mutex, OnceLock};

// Shadow memory is mapped at a fixed offset chosen to sit in the
// middle of the macOS/arm64 address space gap — above the heap
// (~0x0000_0001_0000_0000) and below the stack (~0x7fff_0000_0000_0000).
// The shadow region covers 1/8th of addressable memory, so it needs
// roughly 16TB of virtual address space reserved here.
// Physical pages are only committed when actually written to.
const SHADOW_OFFSET: usize = 0x100000000000;
const SHADOW_SIZE: usize = 1 << 44; // 16TB

static SHADOW_INSTANCE: OnceLock<Mutex<Shadow>> = OnceLock::new();

#[derive(Debug, Clone, Copy)]
pub struct Shadow {
    poison_counter: u64,
    unpoison_counter: u64,
}

impl Shadow {
    /// lazy_init
    fn lazy_init() -> Self {
        let mut s = Self {
            poison_counter: 0,
            unpoison_counter: 0,
        };
        s.init();
        s
    }

    pub fn global() -> &'static Mutex<Self> {
        SHADOW_INSTANCE.get_or_init(|| Mutex::new(Self::lazy_init()))
    }
    /// init
    /// mmap the shadow region at SHADOW_OFFSET
    /// All memory start as valid until poison something explicitly
    fn init(&mut self) {
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
    fn shadow_addr_of(&self, app_addr: usize) -> *mut u8 {
        ((app_addr >> 3) + SHADOW_OFFSET) as *mut u8
    }

    /// poison
    /// Marks a region as invalid by writing a sentinel value
    /// into the corresponding shadow bytes.
    /// TODO:
    /// - Convert addr to its shadow address
    /// - Figure out how many shadow bytes to write
    /// - Write value into all of them
    pub fn poison(&mut self, addr: *mut u8, size: usize, value: u8) {
        let base_shadow = self.shadow_addr_of(addr as usize);

        let total_shadow = (size + 7) / 8;

        for i in 0..total_shadow {
            unsafe {
                std::ptr::write(base_shadow.add(i), value);
            }
            self.poison_counter += 1;
        }
    }

    /// unpoison
    /// Same as poison but writes 0x00 (fully valid)
    /// Called when a variable comes into scope
    pub fn unpoison(&mut self, addr: *mut u8, size: usize) {
        let base_shadow = self.shadow_addr_of(addr as usize);
        let full_chunks = size / 8;
        let remainder = size % 8;

        for i in 0..full_chunks {
            unsafe {
                std::ptr::write(base_shadow.add(i), 0x00);
            }
        }

        if remainder > 0 {
            unsafe {
                let partial_shadow = base_shadow.add(full_chunks);
                std::ptr::write(partial_shadow, remainder as u8);
            }
        }
        self.unpoison_counter += 1;
    }

    /// check
    /// Reads the shadow byte for addr
    /// Returns None if valid
    /// Handles the partial validity case (1-7)
    /// Returns Some(Poison::...) if poisoned so the caller can report the right error
    pub fn check(&self, addr: usize, access_size: usize) -> Option<u8> {
        let start_addr = addr;
        let end_addr = addr + access_size - 1;

        let start_shadow = self.shadow_addr_of(start_addr);
        let end_shadow = self.shadow_addr_of(end_addr);

        let mut curr_shadow = start_shadow;
        unsafe {
            while curr_shadow <= end_shadow {
                let state_byte = std::ptr::read(curr_shadow);

                if state_byte != 0 {
                    if state_byte >= 0xf0 {
                        return Some(state_byte);
                    }

                    // for partial address
                    let shadow_index = curr_shadow as usize - start_shadow as usize;
                    let word_addr = addr + (shadow_index * 8);
                    let word_offset = (word_addr & 7) as u8;

                    let bytes_in_word = if curr_shadow == end_shadow {
                        ((addr + access_size - 1) & 7) as u8 + 1 - word_offset
                    } else {
                        8 - word_offset
                    };

                    // does our access reach beyond the valid prefix?
                    if word_offset + bytes_in_word > state_byte {
                        let next_shadow = curr_shadow.add(1);
                        let neighbor = std::ptr::read(next_shadow);

                        return match neighbor {
                            0xf1 => Some(0xf1),
                            0xfa => Some(0xfa),
                            _ => Some(0xf1),
                        };
                    }
                }
                curr_shadow = curr_shadow.add(1);
            }
        }
        None
    }

    fn get_poison_counter(self) -> u64 {
        self.poison_counter
    }

    fn get_unpoison_counter(self) -> u64 {
        self.unpoison_counter
    }
}

mod tests {
    use super::*;
    const SHADOW_OFFSET: usize = 0x100000000000;
    const SHADOW_SIZE: usize = 1 << 44; // 16TB
    #[test]
    fn test_init() {
        if let Ok(mut shadow) = Shadow::global().lock() {}
    }

    #[test]
    fn test_poison() {
        if let Ok(mut shadow) = Shadow::global().lock() {
            let addr: *mut u8 = 0x602000000010 as *mut u8;
            let shadow_addr = shadow.shadow_addr_of(addr as usize);

            println!("app addr:      {:#x}", addr as usize);
            println!("shadow addr:   {:#x}", shadow_addr as usize);
            println!("SHADOW_OFFSET: {:#x}", SHADOW_OFFSET);
            println!("SHADOW_SIZE:   {:#x}", SHADOW_SIZE);

            assert!(shadow_addr as usize >= SHADOW_OFFSET);
            assert!((shadow_addr as usize) < SHADOW_OFFSET + SHADOW_SIZE);

            shadow.poison(addr, 64, 0xf1);
            let value = unsafe { std::ptr::read(shadow_addr as *const u8) };
            println!("value after poison: {}", value);
            assert_eq!(value, 0xf1, "Value != 0xf1");
        }
    }

    #[test]
    fn test_unpoison() {
        if let Ok(mut shadow) = Shadow::global().lock() {
            let addr: *mut u8 = 0x602000000010 as *mut u8;
            let shadow_addr = shadow.shadow_addr_of(addr as usize);

            println!("app addr:      {:#x}", addr as usize);
            println!("shadow addr:   {:#x}", shadow_addr as usize);
            println!("SHADOW_OFFSET: {:#x}", SHADOW_OFFSET);
            println!("SHADOW_SIZE:   {:#x}", SHADOW_SIZE);

            assert!(shadow_addr as usize >= SHADOW_OFFSET);
            assert!((shadow_addr as usize) < SHADOW_OFFSET + SHADOW_SIZE);

            // poison first
            shadow.poison(addr, 64, 0xf1);
            let value = unsafe { std::ptr::read(shadow_addr as *const u8) };
            println!("value after poison: {}", value);
            assert_eq!(value, 0xf1, "Value != 0xf1");

            // unpoison
            shadow.unpoison(addr, 64);
            let value = unsafe { std::ptr::read(shadow_addr as *const u8) };
            println!("value after unpoison: {}", value);
            assert_eq!(value, 0, "Value = 0xf1");
        }
    }

    #[test]
    fn test_check() {
        if let Ok(mut shadow) = Shadow::global().lock() {
            let addr: *mut u8 = 0x602000000010 as *mut u8;
            let shadow_addr = shadow.shadow_addr_of(addr as usize);

            println!("app addr:      {:#x}", addr as usize);
            println!("shadow addr:   {:#x}", shadow_addr as usize);
            println!("SHADOW_OFFSET: {:#x}", SHADOW_OFFSET);
            println!("SHADOW_SIZE:   {:#x}", SHADOW_SIZE);

            assert!(shadow_addr as usize >= SHADOW_OFFSET);
            assert!((shadow_addr as usize) < SHADOW_OFFSET + SHADOW_SIZE);

            // poison first
            shadow.poison(addr, 64, 0xf1);
            let value = unsafe { std::ptr::read(shadow_addr as *const u8) };
            assert_eq!(value, 0xf1, "Value != 0xf1");

            let result = shadow.check(addr as usize, 64);
            assert_ne!(result, None, "Result == None");
        }
    }

    #[test]
    fn test_partial() {
        if let Ok(mut shadow) = Shadow::global().lock() {
            let addr: *mut u8 = 0x602000000010 as *mut u8;
            let shadow_addr = shadow.shadow_addr_of(addr as usize);

            println!("app addr:      {:#x}", addr as usize);
            println!("shadow addr:   {:#x}", shadow_addr as usize);
            println!("SHADOW_OFFSET: {:#x}", SHADOW_OFFSET);
            println!("SHADOW_SIZE:   {:#x}", SHADOW_SIZE);

            assert!(shadow_addr as usize >= SHADOW_OFFSET);
            assert!((shadow_addr as usize) < SHADOW_OFFSET + SHADOW_SIZE);

            // poison first
            shadow.poison(addr, 6, 0xf1);
            let value = unsafe { std::ptr::read(shadow_addr as *const u8) };
            assert_eq!(value, 0xf1, "Value != 0xf1");

            shadow.unpoison(addr, 6);
            let value = unsafe { std::ptr::read(shadow_addr as *const u8) };
            assert_eq!(value, 0x06, "Value != 0x06");

            let result = shadow.check(addr as usize, 6);
            assert_eq!(result, None, "Result != None");
        }
    }

    #[test]
    fn test_full_partial() {
        if let Ok(mut shadow) = Shadow::global().lock() {
            let addr: *mut u8 = 0x602000000010 as *mut u8;
            let shadow_addr = shadow.shadow_addr_of(addr as usize);

            println!("app addr:      {:#x}", addr as usize);
            println!("shadow addr:   {:#x}", shadow_addr as usize);
            println!("SHADOW_OFFSET: {:#x}", SHADOW_OFFSET);
            println!("SHADOW_SIZE:   {:#x}", SHADOW_SIZE);

            assert!(shadow_addr as usize >= SHADOW_OFFSET);
            assert!((shadow_addr as usize) < SHADOW_OFFSET + SHADOW_SIZE);

            // poison first
            shadow.poison(addr, 18, 0xf1);
            let value = unsafe { std::ptr::read(shadow_addr as *const u8) };
            assert_eq!(value, 0xf1, "Value != 0xf1");

            shadow.unpoison(addr, 18);
            let shadow_addr_1 = shadow.shadow_addr_of(addr as usize + 16);
            let value = unsafe { std::ptr::read(shadow_addr_1 as *const u8) };
            assert_eq!(value, 0x02, "Value != 0x01");

            let result = shadow.check(addr as usize, 19);
            assert_eq!(result, Some(0xf1), "Result != None");
        }
    }
}
