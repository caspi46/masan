#include <stdlib.h>
#include <stdio.h>

int main(void)
{
    volatile int *arr = (volatile int *)malloc(4 * sizeof(int));
    if (!arr)
        return 1;

    arr[0] = 42;

    // Free the heap block (shadow memory marked as freed/poisoned)
    free((void *)arr);

    // Bug: Use-After-Free (writing to or reading from freed heap memory)
    volatile int val = arr[0];

    printf("Read value: %d\n", val);
    return 0;
}