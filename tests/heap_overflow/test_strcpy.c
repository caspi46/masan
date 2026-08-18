#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main()
{
    // 1. Initialize a small 4-byte buffer on the heap
    char *buffer = (char *)malloc(4 * sizeof(char));
    if (buffer == NULL)
        return 1;

    // 2. This string requires 9 bytes of space (8 characters + '\0')
    char *too_much_data = "OVERFLOW";

    // 3. HEAP OVERFLOW: strcpy copies all 9 bytes into the 4-byte buffer
    strcpy(buffer, too_much_data);

    // 4. Cleanup (this might crash the program due to corrupted heap metadata)
    free(buffer);
    buffer = NULL;

    return 0;
}