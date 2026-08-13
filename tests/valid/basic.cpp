// valid accesses that should pass cleanly in C++
void test()
{
    char buf[8];
    buf[0] = 'A';
    buf[7] = 'Z'; // last valid byte

    int x = 42;
    int *p = &x;
    *p = 99; // valid
}

int main()
{
    test();
    return 0;
}
