#include <stdio.h>

int main()
{
    char buf[8];
    buf[10] = 'X';
    printf("%c\n", buf[10]);
    return 0;
}