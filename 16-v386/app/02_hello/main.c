#include <io.h>

int main() {

    cli;

    IoWrite8(0x3D8, 3);

    char* m = (char*) 0xa0000;

    int n = 0;

    for (;;) {

        for (int y = 0; y < 256; y++)
        for (int x = 0; x < 256; x++) {
            m[y*320+x] = x+y+n;
        }

        n++;
    }

    for(;;);
}
