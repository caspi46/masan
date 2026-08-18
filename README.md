# mASan

A custom memory sanitizer built in Rust that detects **stack buffer overflow** 
and **use-after-scope** vulnerabilities in C/C++ programs via LLVM IR 
instrumentation and shadow memory.

---

## Features

- Detects stack/heap buffer overflow — spatial memory error
- Detects use-after-scope/use-after-free — temporal memory error  
- Error reporting with stack traces on detection
- Zero source code changes required — works at the IR level

---

**Components:**

| masan-pass (compile time) | masan-rt (run time) |
|---|---|
| LLVM IR pass plugin | Shadow memory engine |
| Instruments `alloca` | `poison` / `unpoison` |
| Instruments `llvm.lifetime.end` | `check` |
| Instruments `load` / `store` | `report` + abort |

**Pipeline:**

```
foo.c
  ↓  clang -O1 -S -emit-llvm
foo.ll                          (unmodified IR)
  ↓  opt -load-pass-plugin=libmasan_pass.dylib -passes=masan
instrumented.ll                 (shadow checks inserted)
  ↓  clang instrumented.ll libmasan_rt.a -o foo
./foo                           (instrumented binary)
  ↓  on bad access:
__masan_check() fires → report error → abort
```

---

## Memory Vulnerabilities

### Stack Buffer Overflow

A program writes or reads past the end of a stack-allocated buffer, 
corrupting adjacent memory.

```c
char buf[8];
buf[9] = 'A';  // one byte past the end — corrupts adjacent memory
```

mASan detects this by placing poisoned **redzones** around every stack 
variable. Any access into a redzone triggers an immediate error report.

---

### Use-After-Scope

A program accesses a variable through a pointer after the variable's 
scope has ended. The stack memory has been released but the pointer 
still holds the old address.

```c
// example 1 — returning pointer to local variable
int* get_value() {
    int x = 42;
    return &x;      // x goes out of scope when function returns
}

int main() {
    int* p = get_value();
    printf("%d\n", *p);  // use-after-scope — x is gone
}

// example 2 — pointer outlives its scope
int* p;
{
    int arr[3] = {0, 1, 2};
    p = arr;
}                   // arr goes out of scope here

p[2] = 3;           // use-after-scope — arr's memory is no longer valid
```

mASan detects this by poisoning a variable's shadow bytes (`0xf8`) when 
its `llvm.lifetime.end` marker is reached. Any subsequent access through 
a dangling pointer triggers an error report.

---

### Heap Buffer Overflow

A program reads or writes past the boundary of a dynamically allocated heap buffer, corrupting adjacent heap chunks or allocator metadata.

```c
#include <stdlib.h>
#include <string.h>

int main() {
    char *buf = (char *)malloc(4);
    if (!buf) return 1;

    // Copies 9 bytes (8 chars + '\0') into a 4-byte buffer
    strcpy(buf, "OVERFLOW"); 

    free(buf);
    return 0;
}
```

- Detection: `malloc` wrapper places poisoned heap redzones (`0xFB`) immediately before and after the requested payload. Any load or store landing in these redzones triggers an immediate bounds-violation abort.

---

### Use-After-Free (UAF)
A program accesses dynamically allocated memory after it has already been released to the system.

Example: 
```c
#include <stdlib.h>

int main() {
    int *arr = (int *)malloc(sizeof(int) * 4);
    if (!arr) return 1;

    free(arr);

    // Read/write to deallocated heap chunk
    int val = arr[0]; 

    return val;
}
```
- Detection: `free` immediately overwrites the chunk's shadow bytes with freed markers (`0xFD`) and moves the chunk into a quarantine ring buffer to delay address reuse. Any subsequent dereference triggers an invalid access fault.
---

### Double Free
A program attempts to call free() on an address that has already been deallocated.

Example: 
```c
#include <stdlib.h>

int main() {
    void *ptr = malloc(32);
    if (!ptr) return 1;

    free(ptr);
    free(ptr); // Double free: ptr has already been released

    return 0;
}
```
- Detection: The `free` hook inspects the target address's shadow memory before releasing it. If the address is already marked as poisoned or quarantined (`0xFD`), the runtime aborts immediately with a double-free panic and provides both allocation/deallocation stack traces.

---

## Known Limitations

- Stack overflows larger than 32 bytes may not be detected if they land 
  beyond the redzone in valid memory
- Multithreaded programs are not supported
- Requires `-O1` or higher for use-after-scope detection 
  (`llvm.lifetime.end` markers only appear with optimization enabled)

---

## Dependencies

| Crate | Purpose |
|-------|---------|
| `inkwell` | Safe Rust bindings to LLVM for writing the IR pass |
| `libc` | `mmap` system call for shadow memory initialization |
| `llvm-sys` | Raw LLVM C API for intrinsic ID lookup |
| `backtrace` | Symbolized stack traces in error reports |

---

## References

- [AddressSanitizer: A Fast Address Sanity Checker (USENIX ATC 2012)](https://www.usenix.org/system/files/conference/atc12/atc12-final39.pdf)
- [LLVM Language Reference — Lifetime Intrinsics](https://llvm.org/docs/LangRef.html#llvm-lifetime-end-intrinsic)
- [Google Sanitizers Wiki](https://github.com/google/sanitizers/wiki/AddressSanitizerAlgorithm)