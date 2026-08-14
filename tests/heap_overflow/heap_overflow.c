#include <stdlib.h>
#include <stdio.h>

int main(void)
{
    // Allocate 10 bytes on the heap (surrounded by mASan heap redzones)
    volatile char *buf = (volatile char *)malloc(10);
    if (!buf)
    {
        return 1;
    }

    // Valid accesses: indices 0 to 9
    for (int i = 0; i < 10; i++)
    {
        buf[i] = 'A';
    }

    // Bug: 1-byte heap buffer overflow (accessing index 10)
    // mASan's __check_memory_access should intercept this store
    buf[10] = 'X';

    printf("Buffer content: %c\n", buf[0]);

    free((void *)buf);
    return 0;
}