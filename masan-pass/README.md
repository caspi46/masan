# mASan Pass (`masan-pass`)

The LLVM IR transformation pass that instruments C/C++ programs at compile 
time. It walks the IR of each function and inserts calls to the masan-rt 
runtime functions at the right points.

---

## How It Works

The pass operates on LLVM IR — not source code. This means it works for any 
language that compiles through LLVM (C, C++, etc.) without any language-specific 
logic.

**The pass does two things:**
1. **Reads** the IR to find instructions to instrument
2. **Writes** new runtime calls into the IR using inkwell's `Builder`

---

## Four Instructions to Instrument

| Instruction | Action |
|---|---|
| `alloca` | Create unified struct with redzones, unpoison variable, poison redzones |
| `llvm.lifetime.end` | Poison variable (`0xf8`), unpoison redzones |
| `load` | Insert `__miniasan_check` before the read |
| `store` | Insert `__miniasan_check` before the write |

## Stack Buffer Overflow Detection

Every `alloca` instruction gets replaced with a unified struct containing 
the variable and its redzones:

[ left redzone (32B) ][ variable ][ right redzone (32B) ]
0xf1 0xf1


The pass:
1. Replaces the original `alloca` with a single unified struct alloca
2. Uses GEP (GetElementPtr) to get pointers to each field
3. Replaces all uses of the original alloca with the variable pointer
4. Poisons the redzones and unpoisons the variable
5. Erases the original alloca from the IR

Any access that overflows into a redzone gets caught by `__miniasan_check` 
at runtime.

---

## Use-After-Scope Detection

```c
int* p;
{
    int x = 42;
    p = &x;
}           // llvm.lifetime.end fires here → x is poisoned (0xf8)

*p = 99;    // __miniasan_check sees 0xf8 → REPORT use-after-scope
```

When the pass finds `llvm.lifetime.end` for a tracked variable:
1. Poisons the variable's shadow bytes with `0xf8`
2. Unpoisons the redzones (they're no longer needed)

**Note:** `llvm.lifetime.end` markers only appear at `-O1` or higher. 
Always compile with `-O1` when using mASan.

---

## Variable Lifetime

A variable's lifetime begins when it is declared and ends when its enclosing 
scope closes:

```c
void foo() {
    int x = 42;     // lifetime starts — unpoison
    {
        char buf[8]; // lifetime starts — unpoison
    }                // lifetime ends  — poison (0xf8)
}                    // x lifetime ends — poison (0xf8)
```

LLVM emits `llvm.lifetime.end` intrinsics to mark these boundaries. The pass 
uses these markers rather than analyzing scope boundaries itself.

---

## Difference From Real ASan's Pass

### Redzone Implementation

**Real ASan:**
- Collects all `alloca` instructions in a function
- Calculates total size including all redzones and alignment padding
- Creates one giant `alloca` to replace all of them
- Manually computes offsets for each variable within the block
- Replaces all uses of original allocas with pointer arithmetic

**mASan:**
- Replaces each `alloca` individually with a unified struct
- Uses LLVM's struct type and GEP for field access
- Simpler implementation but doesn't guarantee variables are contiguous
- Redzone size is fixed at 32 bytes vs real ASan's dynamic sizing

### Other Limitations
- Stack overflows larger than 32 bytes may not be detected
- Heap allocations (`malloc`/`free`) are not yet instrumented
- Multithreaded programs are not supported

---

## Implementation Notes

- The pass collects all instructions first, then instruments them — modifying 
  IR while iterating over it is unsafe
- `llvm.lifetime.end` is detected via intrinsic ID lookup using `llvm-sys` 
  rather than string matching for reliability
- Runtime function declarations (`__miniasan_*`) are added to the module once 
  and reused across all instrumentation sites