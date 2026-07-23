# masan
build my (own) ASan (Address Sanitizer)

## Current stage:
- finished the unit testing for shadow memory functions and llvm-pass (analyze alloca, call, store, and load) 
- ToDo: testing with the actual source code (.c/.cpp) 


## Goal of this project 
- Better understanding of: 
    - memory vulnerability 
    - LLVM IRs 
    - Modern C++ 

## Features I'm going to implement 
- detects memory vulnerabilities: 
    - stack buffer overflow 
    - use-after-scope 
- error report for above vulnerabilities 

## architecture design 
- language: Rust (with llvm-plugin-rs) 
- architecture format: 
    1. target C/C++ program - Input (ex: foo.c)
    
        - `clang -S -emit-llvm -00 -g` 
    2. LLVM IR, unmodified (ex: foo.ll)
        - `opt -load-pass-plugin=libmyasan_pass.so -passes=myasan`
    3. Shadow checks inserted (ex: instrumented.ll)
        - `clang -c instrumented.ll -o foo.o`
        - `clang foo.o libmyasan_rt.a -o foo`
    4. Instrumented binary (ex: ./foo)
        - run 
    5. triggers__myasan_check() on bad access 
        - -> reports error
        - -> aborts

## Memory Vulnerability 
### Stack Buffer Overflow 
- When a program writes more data into a buffer than it was allocated to hold
     => The excess data to spill over adjacent memory on the stack 

### Use-After-Scope 
- A program accesses a variable after it has gone out of scope 
- The memory that variable lived in has already been released or repurposed, but a pointer to it still exists and gets used. 
```c++
// example #1
int* get_value() {
    int x = 42; // x lives on the stack 
    return &x;  //returning a pointer to a local variable 
}               // x goes out of scope here - memory is "freed" 

int main() {
    int* p = get_value(); 
    printf("%d\n", *p); // use-after-scope! reading dead memory 
}

// example #2 
int* p; 
{
    int arr[3] = {0, 1, 2, 3}; 
    p = arr;
}

p[2] = 3; // use-after-scope - arr is gone, but writing to its old location!
```

## Shadow Memory 
- TODO: 
    - How many full 8-byte words are there 
    - Is there a remainder that needs a partial shadow byte? 
    - Write the aprpropriate value to each shadow byte 
- Shadow memory format is 8 app_addr : 1 shadow byte: 
    - the variable can have multiple shadow bytes (ex: char buf[16]; // 2 shadows)
    - the partial shadow byte exists due to variable separation (ex: char buf1[4]; char buf2[5]; // there are three shadow bytes 1 for buf1 2 for buf2)
## Poisoning & Unpoisoning
- Poisoning: Writing a sentinel byte value into the shadow map for a given region 
- Unpoisoning: Writing zero 
## Redzone
- Poisoned memory placed around a valid buffer 
- handled by llvm pass 
- timing of the redzone: 
    - when variable is created => create redzone! 
    - when variable's lifetime is done => drop redzone!

## Dependencies for this project: 
- inkwell
- libc

## Resource: 
- [ASan Paper](https://www.usenix.org/system/files/conference/atc12/atc12-final39.pdf)