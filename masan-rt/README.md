# mASan's Runtime 

## Structure 
### Shadow Memory
- 8:1 format
- application memory : shadow memory 
- 8 bytes per shadow byte
- shadow byte: 
    - how many bytes in the key are valid
    - shadow_address = (app_address >> 3) + SHADOW_OFFSET
```c++
// example 
char buf[5]; // lives at address 0x1000
(0x1000 >> 3) + SHADOW_OFFSET = 0x200 + SHADOW_OFFSET
```
- byte info: 
    - 0: all valid 
    - 1-7: partial
    - 0xf1: buffer overflow 
    - 0xf8: use-after-scope 
    - 0xfa: heap overflow 
    - 0xfd: use-after-free 
### Poisoning 

### `mmap` 
- Reserve a region of virtual address space and return a pointer to the start of that region 
- gives: 
    - a pointer to the start of region 
    - a guarantee the region is zeroed 
    - a guarantee the region of virtual address space is yours