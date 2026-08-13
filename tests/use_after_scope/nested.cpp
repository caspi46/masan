// nested lifetime scope in C++
void test_nested_use_after_scope()
{
    int *ptr = nullptr;

    {
        int nested_var = 100; // MUST BE DECLARED HERE
        ptr = &nested_var;
    } // Scope ends here -> clang emits lifetime.end

    // Stack Use-After-Scope violation:
    *ptr = 200;
}

int main()
{
    test_nested_use_after_scope();
    return 0;
}
