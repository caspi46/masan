# mASan Runtime (`masan-rt`)

The runtime library linked into instrumented binaries. It owns the shadow 
memory engine and exposes `extern "C"` functions that the LLVM pass inserts 
calls to at compile time.

---

## Architecture

### Shadow Memory

Shadow memory is a flat, direct-mapped byte array that tracks the validity 
of every 8 bytes of application memory. It uses an 8:1 compression ratio —
1 shadow byte covers 8 application bytes.

**Address Translation:**

shadow_address = (app_address >> 3) + SHADOW_OFFSET


Example — `char buf[5]` at address `0x1000`:

(0x1000 >> 3) + SHADOW_OFFSET = 0x200 + SHADOW_OFFSET


**Shadow Byte Encoding:**

| Value | Meaning |
|-------|---------|
| `0x00` | All 8 bytes valid |
| `1–7` | First N bytes valid (partial) |
| `0xf1` | Stack redzone (buffer overflow) |
| `0xf8` | Use-after-scope |
| `0xfa` | Heap redzone (heap overflow) |
| `0xfd` | Use-after-free |

**Partial Shadow Bytes:**

Variables that don't fill a complete 8-byte word get a partial shadow byte.
For example, `char buf[5]` gets shadow byte `5` — meaning only the first 5
bytes of that 8-byte word are valid. Any access beyond byte 4 is caught.

---

### Shadow Memory Initialization (`mmap`)

The shadow region is reserved once at program startup via `mmap`:

- Maps a fixed region at `SHADOW_OFFSET` in the process address space
- The OS guarantees the region starts as all zeros (`0x00` = all valid)
- Physical pages are only committed when actually written to — reserving
  a large virtual region is cheap

SHADOW_OFFSET = 0x100000000000 (sits in macOS/arm64 address space gap)
SHADOW_SIZE = 1 << 44 (16TB virtual reservation)


---

### Poison Values

Each memory error type has a dedicated sentinel byte:

```rust
pub enum Poison {
    BufOverflow,    // 0xf1 — stack redzone violated
    UseAfterScope,  // 0xf8 — variable accessed after lifetime ended
    HeapOverflow,   // 0xfa — heap redzone violated (future)
    UseAfterFree,   // 0xfd — heap memory accessed after free (future)
    Unpoison,       // 0x00 — mark region as valid
}
```

When `check()` reads a shadow byte it pattern matches on these values to 
determine what kind of error to report.

---

### Redzones

Redzones are poisoned regions placed around every stack variable to catch 
spatial memory errors (overflow and underflow).

[ left redzone (32B) ][ variable ][ right redzone (32B) ]
0xf1 0xf1


Example — `char buf[8]` with a right redzone:
```c
char buf[8];
buf[9] = 'A';  // hits right redzone → detected
```

**Known Limitation:** Overflows larger than the redzone size may not be 
detected if they land in valid memory beyond the redzone. Real ASan uses 
larger redzones to reduce this risk but faces the same fundamental limitation.

---

## Public Interface (`lib.rs`)

These `extern "C"` functions are called by the instrumented binary at runtime:

```rust
__miniasan_init()                          // initialize shadow memory
__miniasan_poison(addr, size, value)       // mark region as invalid
__miniasan_unpoison(addr, size)            // mark region as valid
__miniasan_check(addr, size, is_write)     // validate memory access
```

---

## Shadow Memory Functions

| Function | Description |
|----------|-------------|
| `init()` | Calls `mmap` to reserve shadow region |
| `shadow_addr_of(addr)` | Converts application address to shadow address |
| `poison(addr, size, value)` | Writes sentinel to shadow bytes |
| `unpoison(addr, size)` | Writes `0x00` (or remainder) to shadow bytes |
| `check(addr, size, is_write)` | Reads shadow byte and returns error type if poisoned |