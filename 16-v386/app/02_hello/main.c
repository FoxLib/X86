#include <io.h>

static const char test[4] = {15, 15, 2, 4};

void pset(int x, int y, char ch) {

    char* m = (char*) 0xA0000;
    m[x + y*320] = ch;
}

int main() {

    cli;

    IoWrite8(0x3D8, 3);

    char* m = (char*) 0xa0000;

    for (int y = 0; y < 200; y++)
    for (int x = 0; x < 256; x++) {
        pset(x, y, x + y);
    }

    for(;;);
}
