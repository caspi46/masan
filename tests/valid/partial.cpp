// partial variable access in C++
struct Wrapper
{
    char buf[5];
};

void test()
{
    Wrapper w{};
    w.buf[4] = 'A'; // last valid byte
}

int main()
{
    test();
    return 0;
}
