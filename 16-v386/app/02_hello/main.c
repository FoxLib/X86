#include <io.h>

static const char test[4] = {15, 15, 2, 4};

int main() {

    cli;

    IoWrite8(0x3D8, 3);

    char* m = (char*) 0xa0000;

    for (;;) {
        for (int i = 0; i < 4; i++) {

            m[i] = test[i];
        }
    }

    for(;;);
}
