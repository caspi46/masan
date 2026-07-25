// nested scopes
void test()
{
    int *p;
    {
        int x = 42;
        p = &x;
    }
    *p = 99; // should trigger
}
int main() { test(); }