// classic dangling pointer in C++
int *get_ptr()
{
    int x = 42;
    return &x;
}

int main()
{
    int *p = get_ptr();
    *p = 99; // should trigger
    return 0;
}
