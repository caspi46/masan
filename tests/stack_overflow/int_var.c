// non-array variable overflow
void test()
{
    int x;
    int *p = &x;
    *(p + 2) = 99; // overflow past x
}
int main() { test(); }