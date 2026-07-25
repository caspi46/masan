// underflow — access before buffer
void test()
{
    char buf[8];
    *(buf - 1) = 'A'; // hits left redzone
}
int main() { test(); }