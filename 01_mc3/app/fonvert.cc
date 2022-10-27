/**
 * Конвертер BIN-файлов в HEX
 */

#include <stdlib.h>
#include <stdio.h>

int main(int argc, char** argv) {

    unsigned char b64[65536];

    if (argc < 3) {

        printf("ARG <src> <dst>\n");
        return 1;
    }

    FILE* fp = fopen(argv[1], "rb");
    FILE* dt = fopen(argv[2], "wb");

    if (fp == NULL || dt == NULL) {

        printf("File error\n");
        return 2;
    }

    int size = fread(b64, 1, 65536, fp);
    for (int i = 0; i < size; i++) {
        fprintf(dt, "%02X\n", b64[i]);
    }

    fclose(fp);
    fclose(dt);

    return 0;
}
