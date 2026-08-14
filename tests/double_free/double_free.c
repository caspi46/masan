#include <stdlib.h>
#include <stdio.h>

int main(void)
{
    void *ptr = malloc(64);
    if (!ptr)
        return 1;

    // First free: valid
    free(ptr);

    printf("First free successful.\n");

    // Bug: Double-Free (freeing the same address twice)
    free(ptr);

    printf("Should not reach here!\n");
    return 0;
}