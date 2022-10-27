#include <stdlib.h>
#include <stdio.h>
#include "app.h"

int main(int argc, char* argv[]) {

    FILE *fp;
    unsigned char mem[65536];

    if (argc < 3) {
        return 1;
    }

    int size = 0;

    // Генерация hex-файла
    if (fp = fopen(argv[1], "rb")) {

        size = fread(mem, 1, 65536, fp);
        printf("%d ", size);
        fclose(fp);
        fp = fopen(argv[2], "w");
        for (int i = 0; i < size; i++) {
            fprintf(fp, "%02X\n", mem[i]);
        }
        fclose(fp);
    }

    // И mif-файла
    for (int i = 3; i < argc; i++) {

        // 64K версия
        fp = fopen(argv[3], "w");

        // Заголовок
        fprintf(fp, "WIDTH=8;\nDEPTH=65536;\nADDRESS_RADIX=HEX;\nDATA_RADIX=HEX;\nCONTENT BEGIN\n");

        // Контент
        for (int j = 0; j < size; j++) fprintf(fp, "%04X: %02X;\n", j, mem[j]);

        // Филлер
        if (size < 0xB800) fprintf(fp, "[%04X..C7FF]: 00;\n", size);

        // Видеопамять
        for (int j = 0; j < 4096; j++) fprintf(fp, "%04X: %02X;\n", 0xC800 + j, font[j]);

        // Филлер
        fprintf(fp, "[D800..FFFF]: 00;\n");
        fprintf(fp, "END;\n");
        fclose(fp);
    }

    return 0;
}
