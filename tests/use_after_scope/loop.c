// reuse across loop iterations
void test()
{
    int *p;
    for (int i = 0; i < 3; i++)
    {
        int x = i;
        p = &x;
    }
    *p = 99; // should trigger
}
int main() { test(); }