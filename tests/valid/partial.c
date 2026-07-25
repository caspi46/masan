// partial variable access
void test()
{
    char buf[5];  // partial shadow byte
    buf[4] = 'A'; // last valid byte — should pass
}
int main() { test(); }