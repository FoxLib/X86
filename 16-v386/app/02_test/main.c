int main() {

    char* m = (char*) 0xb8000;
    for (int i = 0; i < 1024; i++) m[i] = i;
    return 0;
}