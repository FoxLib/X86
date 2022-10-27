#include <SDL2/SDL.h>

const int dac_init[256] = {
    0x00000000, 0x000000AA, 0x0000AA00, 0x0000AAAA, 0x00AA0000, 0x00AA00AA, 0x00AA5500, 0x00AAAAAA,
    0x00555555, 0x005555FF, 0x0055FF55, 0x0055FFFF, 0x00FF5555, 0x00FF55FF, 0x00FFFF55, 0x00FFFFFF,
    0x00000000, 0x00141414, 0x00202020, 0x002C2C2C, 0x00383838, 0x00454545, 0x00515151, 0x00616161,
    0x00717171, 0x00828282, 0x00929292, 0x00A2A2A2, 0x00B6B6B6, 0x00CBCBCB, 0x00E3E3E3, 0x00FFFFFF,
    0x000000FF, 0x004100FF, 0x007D00FF, 0x00BE00FF, 0x00FF00FF, 0x00FF00BE, 0x00FF007D, 0x00FF0041,
    0x00FF0000, 0x00FF4100, 0x00FF7D00, 0x00FFBE00, 0x00FFFF00, 0x00BEFF00, 0x007DFF00, 0x0041FF00,
    0x0000FF00, 0x0000FF41, 0x0000FF7D, 0x0000FFBE, 0x0000FFFF, 0x0000BEFF, 0x00007DFF, 0x000041FF,
    0x007D7DFF, 0x009E7DFF, 0x00BE7DFF, 0x00DF7DFF, 0x00FF7DFF, 0x00FF7DDF, 0x00FF7DBE, 0x00FF7D9E,
    0x00FF7D7D, 0x00FF9E7D, 0x00FFBE7D, 0x00FFDF7D, 0x00FFFF7D, 0x00DFFF7D, 0x00BEFF7D, 0x009EFF7D,
    0x007DFF7D, 0x007DFF9E, 0x007DFFBE, 0x007DFFDF, 0x007DFFFF, 0x007DDFFF, 0x007DBEFF, 0x007D9EFF,
    0x00B6B6FF, 0x00C7B6FF, 0x00DBB6FF, 0x00EBB6FF, 0x00FFB6FF, 0x00FFB6EB, 0x00FFB6DB, 0x00FFB6C7,
    0x00FFB6B6, 0x00FFC7B6, 0x00FFDBB6, 0x00FFEBB6, 0x00FFFFB6, 0x00EBFFB6, 0x00DBFFB6, 0x00C7FFB6,
    0x00B6FFB6, 0x00B6FFC7, 0x00B6FFDB, 0x00B6FFEB, 0x00B6FFFF, 0x00B6EBFF, 0x00B6DBFF, 0x00B6C7FF,
    0x00000071, 0x001C0071, 0x00380071, 0x00550071, 0x00710071, 0x00710055, 0x00710038, 0x0071001C,
    0x00710000, 0x00711C00, 0x00713800, 0x00715500, 0x00717100, 0x00557100, 0x00387100, 0x001C7100,
    0x00007100, 0x0000711C, 0x00007138, 0x00007155, 0x00007171, 0x00005571, 0x00003871, 0x00001C71,
    0x00383871, 0x00453871, 0x00553871, 0x00613871, 0x00713871, 0x00713861, 0x00713855, 0x00713845,
    0x00713838, 0x00714538, 0x00715538, 0x00716138, 0x00717138, 0x00617138, 0x00557138, 0x00457138,
    0x00387138, 0x00387145, 0x00387155, 0x00387161, 0x00387171, 0x00386171, 0x00385571, 0x00384571,
    0x00515171, 0x00595171, 0x00615171, 0x00695171, 0x00715171, 0x00715169, 0x00715161, 0x00715159,
    0x00715151, 0x00715951, 0x00716151, 0x00716951, 0x00717151, 0x00697151, 0x00617151, 0x00597151,
    0x00517151, 0x00517159, 0x00517161, 0x00517169, 0x00517171, 0x00516971, 0x00516171, 0x00515971,
    0x00000041, 0x00100041, 0x00200041, 0x00300041, 0x00410041, 0x00410030, 0x00410020, 0x00410010,
    0x00410000, 0x00411000, 0x00412000, 0x00413000, 0x00414100, 0x00304100, 0x00204100, 0x00104100,
    0x00004100, 0x00004110, 0x00004120, 0x00004130, 0x00004141, 0x00003041, 0x00002041, 0x00001041,
    0x00202041, 0x00282041, 0x00302041, 0x00382041, 0x00412041, 0x00412038, 0x00412030, 0x00412028,
    0x00412020, 0x00412820, 0x00413020, 0x00413820, 0x00414120, 0x00384120, 0x00304120, 0x00284120,
    0x00204120, 0x00204128, 0x00204130, 0x00204138, 0x00204141, 0x00203841, 0x00203041, 0x00202841,
    0x002C2C41, 0x00302C41, 0x00342C41, 0x003C2C41, 0x00412C41, 0x00412C3C, 0x00412C34, 0x00412C30,
    0x00412C2C, 0x0041302C, 0x0041342C, 0x00413C2C, 0x0041412C, 0x003C412C, 0x0034412C, 0x0030412C,
    0x002C412C, 0x002C4130, 0x002C4134, 0x002C413C, 0x002C4141, 0x002C3C41, 0x002C3441, 0x002C3041,
    0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000
};

// Список мнемоник, используюстя в ops
const char* mnemonics[] = {

    /* 00 */ "add",     /* 01 */ "or",      /* 02 */ "adc",     /* 03 */ "sbb",
    /* 04 */ "and",     /* 05 */ "sub",     /* 06 */ "xor",     /* 07 */ "cmp",
    /* 08 */ "es:",     /* 09 */ "cs:",     /* 0A */ "ss:",     /* 0B */ "ds:",
    /* 0C */ "fs:",     /* 0D */ "gs:",     /* 0E */ "push",    /* 0F */ "pop",

    /* 10 */ "daa",     /* 11 */ "das",     /* 12 */ "aaa",     /* 13 */ "aas",
    /* 14 */ "inc",     /* 15 */ "dec",     /* 16 */ "pusha",   /* 17 */ "popa",
    /* 18 */ "bound",   /* 19 */ "arpl",    /* 1A */ "imul",    /* 1B */ "ins",
    /* 1C */ "outs",    /* 1D */ "test",    /* 1E */ "xchg",    /* 1F */ "lea",

    /* 20 */ "jo",      /* 21 */ "jno",     /* 22 */ "jb",      /* 23 */ "jnb",
    /* 24 */ "jz",      /* 25 */ "jnz",     /* 26 */ "jbe",     /* 27 */ "jnbe",
    /* 28 */ "js",      /* 29 */ "jns",     /* 2A */ "jp",      /* 2B */ "jnp",
    /* 2C */ "jl",      /* 2D */ "jnl",     /* 2E */ "jle",     /* 2F */ "jnle",

    /* 30 */ "mov",     /* 31 */ "nop",     /* 32 */ "cbw",     /* 33 */ "cwd",
    /* 34 */ "cwde",    /* 35 */ "cdq",     /* 36 */ "callf",   /* 37 */ "fwait",
    /* 38 */ "pushf",   /* 39 */ "popf",    /* 3A */ "sahf",    /* 3B */ "lahf",
    /* 3C */ "movs",    /* 3D */ "cmps",    /* 3E */ "stos",    /* 3F */ "lods",

    /* 40 */ "scas",    /* 41 */ "ret",     /* 42 */ "retf",    /* 43 */ "les",
    /* 44 */ "lds",     /* 45 */ "lfs",     /* 46 */ "lgs",     /* 47 */ "enter",
    /* 48 */ "leave",   /* 49 */ "int",     /* 4A */ "int1",    /* 4B */ "int3",
    /* 4C */ "into",    /* 4D */ "iret",    /* 4E */ "aam",     /* 4F */ "aad",

    /* 50 */ "salc",    /* 51 */ "xlatb",   /* 52 */ "loopnz",  /* 53 */ "loopz",
    /* 54 */ "loop",    /* 55 */ "jcxz",    /* 56 */ "in",      /* 57 */ "out",
    /* 58 */ "call",    /* 59 */ "jmp",     /* 5A */ "jmpf",    /* 5B */ "lock:",
    /* 5C */ "repnz:",  /* 5D */ "repz:",   /* 5E */ "hlt",     /* 5F */ "cmc",

    /* 60 */ "clc",     /* 61 */ "stc",     /* 62 */ "cli",     /* 63 */ "sti",
    /* 64 */ "cld",     /* 65 */ "std",     /* 66 */ "rol",     /* 67 */ "ror",
    /* 68 */ "rcl",     /* 69 */ "rcr",     /* 6A */ "shl",     /* 6B */ "shr",
    /* 6C */ "sal",     /* 6D */ "sar",     /* 6E */ "not",     /* 6F */ "neg",

    /* 70 */ "mul",     /* 71 */ "div",     /* 72 */ "idiv",    /* 73 */ "rep:",
    /* 74 */ "",        /* 75 */ "",        /* 76 */ "",        /* 77 */ "",
    /* 78 */ "",        /* 79 */ "",        /* 7A */ "",        /* 7B */ "",
    /* 7C */ "",        /* 7D */ "",        /* 7E */ "",        /* 7F */ "",
};

const int ops[256] = {

    /* Основной набор */
    /* 00 */ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0E, 0x0F,
    /* 08 */ 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x0E, 0xFF,
    /* 10 */ 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x0E, 0x0F,
    /* 18 */ 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x0E, 0x0F,
    /* 20 */ 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x08, 0x10,
    /* 28 */ 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x09, 0x11,
    /* 30 */ 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x0A, 0x12,
    /* 38 */ 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x0B, 0x13,
    /* 40 */ 0x14, 0x14, 0x14, 0x14, 0x14, 0x14, 0x14, 0x14,
    /* 48 */ 0x15, 0x15, 0x15, 0x15, 0x15, 0x15, 0x15, 0x15,
    /* 50 */ 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E,
    /* 58 */ 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F,
    /* 60 */ 0x16, 0x17, 0x18, 0x19, 0x0C, 0x0D, 0xFF, 0xFF,
    /* 68 */ 0x0E, 0x1A, 0x0E, 0x1A, 0x1B, 0x1B, 0x1C, 0x1C,
    /* 70 */ 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27,
    /* 78 */ 0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x2D, 0x2E, 0x2F,
    /* 80 */ 0xFF, 0xFF, 0xFF, 0xFF, 0x1D, 0x1D, 0x1E, 0x1E,
    /* 88 */ 0x30, 0x30, 0x30, 0x30, 0x30, 0x1F, 0x30, 0x0F,
    /* 90 */ 0x31, 0x1E, 0x1E, 0x1E, 0x1E, 0x1E, 0x1E, 0x1E,
    /* 98 */ 0x32, 0x33, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x3B,
    /* A0 */ 0x30, 0x30, 0x30, 0x30, 0x3C, 0x3C, 0x3D, 0x3D,
    /* A8 */ 0x1D, 0x1D, 0x3E, 0x3E, 0x3F, 0x3F, 0x40, 0x40,
    /* B0 */ 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30,
    /* B8 */ 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30,
    /* C0 */ 0xFF, 0xFF, 0x41, 0x41, 0x43, 0x44, 0x30, 0x30,
    /* C8 */ 0x47, 0x48, 0x42, 0x42, 0x4B, 0x49, 0x4C, 0x4D,
    /* D0 */ 0xFF, 0xFF, 0xFF, 0xFF, 0x4E, 0x4F, 0x50, 0x51,
    /* D8 */ 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    /* E0 */ 0x52, 0x53, 0x54, 0x55, 0x56, 0x56, 0x57, 0x57,
    /* E8 */ 0x58, 0x59, 0x5A, 0x59, 0x56, 0x56, 0x57, 0x57,
    /* F0 */ 0x5B, 0x4A, 0x5C, 0x5D, 0x5E, 0x5F, 0xFF, 0xFF,
    /* F8 */ 0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0xFF, 0xFF
};

const Uint8 modrm_lookup[512] = {

    /*       0 1 2 3 4 5 6 7 8 9 A B C D E F */
    /* 00 */ 1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,
    /* 10 */ 1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,
    /* 20 */ 1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,
    /* 30 */ 1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,
    /* 40 */ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    /* 50 */ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    /* 60 */ 0,0,1,1,0,0,0,0,0,1,0,1,0,0,0,0,
    /* 70 */ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    /* 80 */ 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    /* 90 */ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    /* A0 */ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    /* B0 */ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    /* C0 */ 1,1,0,0,1,1,1,1,0,0,0,0,0,0,0,0,
    /* D0 */ 1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,
    /* E0 */ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    /* F0 */ 0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1
};

const char* regnames[] = {

    /* 00 */ "al",  "cl",  "dl",  "bl",  "ah",  "ch",  "dh",  "bh",
    /* 08 */ "ax",  "cx",  "dx",  "bx",  "sp",  "bp",  "si",  "di",
    /* 10 */ "eax", "ecx", "edx", "ebx", "esp", "ebp", "esi", "edi",
    /* 18 */ "es",  "cs",  "ds",  "ss",  "fs",  "gs",  "",    ""

};

const char* rm16names[] = {

    /* 0 */ "bx+si",
    /* 1 */ "bx+di",
    /* 2 */ "bp+si",
    /* 3 */ "bp+di",
    /* 4 */ "si",
    /* 5 */ "di",
    /* 6 */ "bp",
    /* 7 */ "bx"

};

const char* grp2[] = {

    /* 0 */ "test",
    /* 1 */ "test",
    /* 2 */ "not",
    /* 3 */ "neg",
    /* 4 */ "mul",
    /* 5 */ "imul",
    /* 6 */ "div",
    /* 7 */ "idiv",

};

const char* grp3[] = {

    /* 0 */ "inc",
    /* 1 */ "dec",
    /* 2 */ "call",
    /* 3 */ "callf",
    /* 4 */ "jmp",
    /* 5 */ "jmpf",
    /* 6 */ "push",
    /* 7 */ "(unk)",

};

class App {

protected:

    int width, height, frame_length, frame_prev_ticks;
    int frame_id;
    int x, y, _hs, _vs;
    int debug_log;

    SDL_Surface*        screen_surface;
    SDL_Window*         sdl_window;
    SDL_Renderer*       sdl_renderer;
    SDL_PixelFormat*    sdl_pixel_format;
    SDL_Texture*        sdl_screen_texture;
    SDL_Event           evt;
    Uint32*             screen_buffer;

    Vvga*       vga_mod;
    Vsd*        sd_mod;
    Vps2*       ps2_mod;
    Vpctl*      pctl_mod;
    Vcore88*    cpu_mod;

    FILE* sdcard;

    unsigned char kbd[256];
    int kbd_top, kbd_phase, kbd_ticker;

    int tstate = 0;
    int ps_clock = 1,
        ps_data = 1;
    int spi_sclk = 0,
        spi_cnt = 0,
        spi_indata,
        spi_state,
        spi_odata,
        spi_command,
        sd_index,
        sd_cmd_arg;

    unsigned char* memory;
    int  dacmem[256];

    /* Из байта modrm */
    int  reg, mod, rm;
    char tmps[256];
    char dis_row[256];
    int  eip;
    char dis_rg[32];        /* Rm-часть Modrm */
    char dis_rm[32];        /* Rm-часть Modrm */
    char dis_px[32];        /* Префикс */

public:

    App(int argc, char** argv) {

        x   = 0;
        y   = 0;
        _hs = 1;
        _vs = 0;
        frame_prev_ticks = 0;
        frame_id = 0;

        kbd_top     = 0;
        kbd_phase   = 0;
        kbd_ticker  = 0;
        tstate      = 0;

        memory      = (unsigned char*)malloc(64*1024*1024);

        debug_log = (argc > 1 && strcmp(argv[1], "-d") == 0);

        vga_mod  = new Vvga();
        ps2_mod  = new Vps2();
        cpu_mod  = new Vcore88();
        sd_mod   = new Vsd();
        pctl_mod = new Vpctl();

        ps_clock = 1;
        ps_data  = 1;
        spi_sclk = 0;
        spi_cnt  = 0;
        spi_state = 0;
        spi_odata = 0xFF;
        sd_mod->SPI_MISO = 1;

        // Пины сброса
        cpu_mod->locked     = 1;
        cpu_mod->reset_n    = 0;
        pctl_mod->reset_n   = 0;

        // Сброс процессора и модулей
        cpu_mod->clock  = 0; cpu_mod->eval();   cpu_mod->clock  = 1; cpu_mod->eval();
        pctl_mod->clock = 0; pctl_mod->eval();  pctl_mod->clock = 1; pctl_mod->eval();

        cpu_mod->reset_n    = 1;
        pctl_mod->reset_n   = 1;
        pctl_mod->reset_n   = 1;

        // Удвоение пикселей
        width        = 2*640;
        height       = 2*400;
        frame_length = 50;      // 20 кадров в секунду

        if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO)) {
            exit(1);
        }

        SDL_ClearError();
        screen_buffer       = (Uint32*) malloc(width * height * sizeof(Uint32));
        sdl_window          = SDL_CreateWindow("Verilated VGA Display", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, width, height, SDL_WINDOW_SHOWN);
        sdl_renderer        = SDL_CreateRenderer(sdl_window, -1, SDL_RENDERER_PRESENTVSYNC);
        sdl_pixel_format    = SDL_AllocFormat(SDL_PIXELFORMAT_BGRA32);
        sdl_screen_texture  = SDL_CreateTexture(sdl_renderer, SDL_PIXELFORMAT_BGRA32, SDL_TEXTUREACCESS_STREAMING, width, height);
        SDL_SetTextureBlendMode(sdl_screen_texture, SDL_BLENDMODE_NONE);

        FILE* fp;

        // Создать record-файл
        fp = fopen("out/record.ppm", "wb");
        if (fp) fclose(fp);

        // Загрузить знакогенератор
        if (fp = fopen("font.bin", "rb")) {
            fread(memory + 0xB8000 + 4096, 1, 4096, fp);
            fclose(fp);
        } else {
            printf("font.bin not found\n");
            exit(1);
        }

        // Загрузить bios
        if (fp = fopen("bios/bios.bin", "rb")) {

            fseek(fp, 0, SEEK_END);
            int size = ftell(fp);
            fseek(fp, 0, SEEK_SET);
            fread(memory + 0x100000 - size, 1, size, fp);
            fclose(fp);

        } else {

            printf("bios/bios.bin not found\n");
            exit(1);
        }

        // Заполнить чем-нибудь видеобуфер
        for (int i = 0; i < 4096; i += 2) {

            memory[0xb8000 + i]   = i;      // (i>>1) & 255;
            memory[0xb8000 + i+1] = i+1;    //0x17;
        }

        // Заполнение цветами
        for (int i = 0; i < 256; i++) dacmem[i] = dac_init[i];

        sdcard = fopen("sd.img", "rb+");
    }

    int main() {

        for (;;) {

            Uint32 ticks = SDL_GetTicks();

            while (SDL_PollEvent(& evt)) {

                // Прием событий
                switch (evt.type) {

                    case SDL_QUIT:
                        return 0;

                    case SDL_KEYDOWN:

                        kbd_scancode(evt.key.keysym.scancode, 0);
                        break;

                    case SDL_KEYUP:

                        kbd_scancode(evt.key.keysym.scancode, 1);
                        break;
                }
            }

            // Обновление экрана
            if (ticks - frame_prev_ticks >= frame_length) {

                frame_prev_ticks = ticks;
                update();
                return 1;
            }

            SDL_Delay(1);
        }
    }

    // Один такт 25 Mhz
    void tick25() {

        // Если есть запись, записать, и потом прочесть новое значение
        if (cpu_mod->wreq) memory[ cpu_mod->address & 0xFFFFF ] = cpu_mod->data;
        cpu_mod->bus = memory[ cpu_mod->address & 0xFFFFF ];

        // Запись в ЦАП
        if (pctl_mod->dac_we) dacmem[ pctl_mod->dac_address ] = pctl_mod->dac_out;

        // Пошаговый лог
        if (debug_log) {

            eip = cpu_mod->address;

            // Входы-выход из CPU
            printf("%08x [%02x] %08x | i=%02x | %c | o=%02x | p=%04x %c O=%02x I=%02x",
                tstate,
                cpu_mod->iload, eip, cpu_mod->bus, cpu_mod->wreq ? 'W' : ' ',cpu_mod->data,
                cpu_mod->port, cpu_mod->port_w ? 'w' : ' ', cpu_mod->port_o, cpu_mod->port_i);

            if (cpu_mod->iload == 0) {

                printf(" > ");
                disassemble(eip); printf("%s", dis_row);
            }

            tstate++;
            printf("\n");
        }

        // Видеопамять
        vga_mod->data           = memory[ 0xB8000 + vga_mod->address ];
        vga_mod->vga_data       = memory[ 0xA0000 + (vga_mod->vga_address & 65535) ];
        vga_mod->vga_dac_data   = dacmem[ vga_mod->vga_dac_address ];

        // Эмуляция PS/2 кнопки
        kbd_pop(ps_clock, ps_data);
        ps2_mod->ps_clock = ps_clock;
        ps2_mod->ps_data  = ps_data;

        // Отладка
        // if (ps2_mod->done) printf("%02x ", ps2_mod->data);

        // Обмен данными с контроллером порта
        pctl_mod->port_clk      = cpu_mod->port_clk;
        pctl_mod->port          = cpu_mod->port;
        pctl_mod->port_o        = cpu_mod->port_o;
        pctl_mod->port_w        = cpu_mod->port_w;
        pctl_mod->intr_latch    = cpu_mod->intr_latch;
        pctl_mod->ps2_data      = ps2_mod->data;
        pctl_mod->ps2_hit       = ps2_mod->done;

        cpu_mod->port_i         = pctl_mod->port_i;
        cpu_mod->intr           = pctl_mod->intr;
        cpu_mod->irq            = pctl_mod->irq;

        vga_mod->videomode       = pctl_mod->videomode;
        vga_mod->cursor          = pctl_mod->vga_cursor;
        vga_mod->cursor_shape_lo = pctl_mod->cursor_shape_lo;
        vga_mod->cursor_shape_hi = pctl_mod->cursor_shape_hi;

        // Связь с SD-картой
        sd_mod->sd_signal       = pctl_mod->sd_signal;
        sd_mod->sd_cmd          = pctl_mod->sd_cmd;
        sd_mod->sd_out          = pctl_mod->sd_out;
        pctl_mod->sd_din        = sd_mod->sd_din;
        pctl_mod->sd_busy       = sd_mod->sd_busy;
        pctl_mod->sd_timeout    = sd_mod->sd_timeout;

        sdspi();

        // Сначала ставится 0 для всех
        sd_mod->clock   = 0; sd_mod->eval();
        pctl_mod->clock = 0; pctl_mod->eval();
        ps2_mod->clock  = 0; ps2_mod->eval();
        vga_mod->clock  = 0; vga_mod->eval();
        cpu_mod->clock  = 0; cpu_mod->eval();

        // Потом ставится 1
        sd_mod->clock   = 1; sd_mod->eval();
        pctl_mod->clock = 1; pctl_mod->eval();
        ps2_mod->clock  = 1; ps2_mod->eval();
        vga_mod->clock  = 1; vga_mod->eval();
        cpu_mod->clock  = 1; cpu_mod->eval();

        int cl = (vga_mod->r*16)*65536 + (vga_mod->g*16)*256 + (vga_mod->b*16);
        vga(vga_mod->hs, vga_mod->vs, cl);
    }

    // Обновить окно
    void update() {

        SDL_Rect dstRect;

        dstRect.x = 0;
        dstRect.y = 0;
        dstRect.w = width;
        dstRect.h = height;

        SDL_UpdateTexture       (sdl_screen_texture, NULL, screen_buffer, width * sizeof(Uint32));
        SDL_SetRenderDrawColor  (sdl_renderer, 0, 0, 0, 0);
        SDL_RenderClear         (sdl_renderer);
        SDL_RenderCopy          (sdl_renderer, sdl_screen_texture, NULL, &dstRect);
        SDL_RenderPresent       (sdl_renderer);
    }

    // Уничтожение окна
    void destroy() {

        free(screen_buffer);
        free(memory);

        if (sdcard) fclose(sdcard);

        SDL_DestroyTexture(sdl_screen_texture);
        SDL_FreeFormat(sdl_pixel_format);
        SDL_DestroyRenderer(sdl_renderer);
        SDL_DestroyWindow(sdl_window);
        SDL_Quit();
    }

    // Установка точки
    void pset(int x, int y, Uint32 cl) {

        if (x < 0 || y < 0 || x >= 640 || y >= 400)
            return;

        for (int i = 0; i < 2; i++)
        for (int j = 0; j < 2; j++)
            screen_buffer[width*(2*y+i) + (2*x+j)] = cl;
    }

    // Сохранение фрейма
    void saveframe() {

        FILE* fp = fopen("out/record.ppm", "ab");
        if (fp) {

            fprintf(fp, "P6\n# Verilator\n640 400\n255\n");
            for (int y = 0; y < 400; y++)
            for (int x = 0; x < 640; x++) {

                int cl = screen_buffer[2*(y*width + x)];
                int vl = ((cl >> 16) & 255) + (cl & 0xFF00) + ((cl&255)<<16);
                fwrite(&vl, 1, 3, fp);
            }

            fclose(fp);
        }

        frame_id++;
    }

    // Эмуляция протокола SDCard
    void sdspi() {

        unsigned char bchar;

        // Отослать данные контроллеру
        if (sd_mod->SPI_SCLK == 1) {
            sd_mod->SPI_MISO = (spi_odata & (1 << (7 - spi_cnt))) ? 1 : 0;
        }

        // Прием данных от SPI
        if (spi_sclk == 0 && sd_mod->SPI_SCLK == 1) {

            // Прием данных от контроллера
            spi_indata = ((spi_indata << 1) | sd_mod->SPI_MOSI) & 0xff;

            // Отладка
            if (debug_log) {
                printf("[%d] > spi_cnt | in=%d, out=%d\n", spi_cnt, sd_mod->SPI_MOSI, sd_mod->SPI_MISO);
            }

            spi_cnt++;
            if (spi_cnt == 8) {

                spi_cnt = 0;

                if (debug_log) {
                    printf("%02x | O=%02x | I=%02x\n", spi_state, spi_indata, spi_odata);
                }

                switch (spi_state) {

                    // IDLE
                    case 0: {

                        spi_odata = 0xFF;

                        // Получена команда
                        if (spi_indata >= 0x40 && spi_indata < 0x80) {

                            // printf("CMD ACCEPT\n");
                            spi_command = spi_indata & 0x3F;
                            spi_state = 1;
                        }

                        break;
                    }

                    // COMMAND ARG4+CHKSUM
                    case 1: spi_state = 2; sd_cmd_arg  =  spi_indata << 24;  break;
                    case 2: spi_state = 3; sd_cmd_arg |= (spi_indata << 16); break;
                    case 3: spi_state = 4; sd_cmd_arg |= (spi_indata << 8);  break;
                    case 4: spi_state = 5; sd_cmd_arg |= spi_indata; break;
                    case 5: {

                        // OK: ответ на комманду
                        spi_odata = 0x00;

                        if (debug_log) printf("ARG=%08x\n", sd_cmd_arg);

                        switch (spi_command) {

                            // INIT
                            case 0x00:

                                spi_state = 6;
                                spi_odata = 0x01;
                                break;

                            case 0x08: spi_state = 7; break;

                            // ACMD
                            case 0x37: spi_state = 6; break;
                            case 0x29: spi_state = 6; break;
                            case 0x3A: spi_state = 11; break;

                            // READ
                            case 0x11: spi_state = 15; break;

                            default: printf("UNK: %02x\n", spi_command); exit(1);
                        }

                        break;
                    }

                    // Инициализация без до-параметров
                    case 6: spi_state = 0; spi_odata = 0xFF; break;

                    // 48h CMD-8
                    case 7: case 8: case 9: spi_state = spi_state + 1; spi_odata = 0xff; break;
                    case 10: spi_state = 0; spi_odata = 0xAA; break;

                    // 3A
                    case 11: spi_state = 12; spi_odata = 0xc0; break;
                    case 12: case 13: spi_state = spi_state + 1; spi_odata = 0xff; break;
                    case 14: spi_state = 0; break;

                    // READ
                    case 15: spi_state = 16; spi_odata = 0xFE; sd_index = 0; break;
                    // Читать сектор
                    case 16: {

                        if (sdcard) {

                            fseek(sdcard, 512*sd_cmd_arg + sd_index, SEEK_SET);
                            sd_index++;
                            fread(&bchar, 1, 1, sdcard);
                            spi_odata = bchar;

                        } else {
                            spi_odata = 0xff;
                        }

                        // Последний байт и выход
                        if (sd_index == 512) {
                            spi_state = 0;
                        }

                        break;
                    }
                }
            }
        }

        spi_sclk = sd_mod->SPI_SCLK;
    }

    // 640 x 400 x 70
    void vga(int hs, int vs, int color) {

        if (hs) x++;

        // Отслеживание изменений HS/VS
        if (_hs == 0 && hs == 1) { x = 0; y++; }
        if (_vs == 1 && vs == 0) { x = 0; y = 0; saveframe(); }

        // Сохранить предыдущее значение
        _hs = hs;
        _vs = vs;

        // Вывод на экран
        pset(x-48, y-35, color);
    }

    // Сканирование нажатой клавиши
    // https://ru.wikipedia.org/wiki/Скан-код
    void kbd_scancode(int scancode, int release) {

        switch (scancode) {

            // Коды клавиш A-Z
            case SDL_SCANCODE_A: if (release) kbd_push(0xF0); kbd_push(0x1C); break;
            case SDL_SCANCODE_B: if (release) kbd_push(0xF0); kbd_push(0x32); break;
            case SDL_SCANCODE_C: if (release) kbd_push(0xF0); kbd_push(0x21); break;
            case SDL_SCANCODE_D: if (release) kbd_push(0xF0); kbd_push(0x23); break;
            case SDL_SCANCODE_E: if (release) kbd_push(0xF0); kbd_push(0x24); break;
            case SDL_SCANCODE_F: if (release) kbd_push(0xF0); kbd_push(0x2B); break;
            case SDL_SCANCODE_G: if (release) kbd_push(0xF0); kbd_push(0x34); break;
            case SDL_SCANCODE_H: if (release) kbd_push(0xF0); kbd_push(0x33); break;
            case SDL_SCANCODE_I: if (release) kbd_push(0xF0); kbd_push(0x43); break;
            case SDL_SCANCODE_J: if (release) kbd_push(0xF0); kbd_push(0x3B); break;
            case SDL_SCANCODE_K: if (release) kbd_push(0xF0); kbd_push(0x42); break;
            case SDL_SCANCODE_L: if (release) kbd_push(0xF0); kbd_push(0x4B); break;
            case SDL_SCANCODE_M: if (release) kbd_push(0xF0); kbd_push(0x3A); break;
            case SDL_SCANCODE_N: if (release) kbd_push(0xF0); kbd_push(0x31); break;
            case SDL_SCANCODE_O: if (release) kbd_push(0xF0); kbd_push(0x44); break;
            case SDL_SCANCODE_P: if (release) kbd_push(0xF0); kbd_push(0x4D); break;
            case SDL_SCANCODE_Q: if (release) kbd_push(0xF0); kbd_push(0x15); break;
            case SDL_SCANCODE_R: if (release) kbd_push(0xF0); kbd_push(0x2D); break;
            case SDL_SCANCODE_S: if (release) kbd_push(0xF0); kbd_push(0x1B); break;
            case SDL_SCANCODE_T: if (release) kbd_push(0xF0); kbd_push(0x2C); break;
            case SDL_SCANCODE_U: if (release) kbd_push(0xF0); kbd_push(0x3C); break;
            case SDL_SCANCODE_V: if (release) kbd_push(0xF0); kbd_push(0x2A); break;
            case SDL_SCANCODE_W: if (release) kbd_push(0xF0); kbd_push(0x1D); break;
            case SDL_SCANCODE_X: if (release) kbd_push(0xF0); kbd_push(0x22); break;
            case SDL_SCANCODE_Y: if (release) kbd_push(0xF0); kbd_push(0x35); break;
            case SDL_SCANCODE_Z: if (release) kbd_push(0xF0); kbd_push(0x1A); break;

            // Цифры
            case SDL_SCANCODE_0: if (release) kbd_push(0xF0); kbd_push(0x45); break;
            case SDL_SCANCODE_1: if (release) kbd_push(0xF0); kbd_push(0x16); break;
            case SDL_SCANCODE_2: if (release) kbd_push(0xF0); kbd_push(0x1E); break;
            case SDL_SCANCODE_3: if (release) kbd_push(0xF0); kbd_push(0x26); break;
            case SDL_SCANCODE_4: if (release) kbd_push(0xF0); kbd_push(0x25); break;
            case SDL_SCANCODE_5: if (release) kbd_push(0xF0); kbd_push(0x2E); break;
            case SDL_SCANCODE_6: if (release) kbd_push(0xF0); kbd_push(0x36); break;
            case SDL_SCANCODE_7: if (release) kbd_push(0xF0); kbd_push(0x3D); break;
            case SDL_SCANCODE_8: if (release) kbd_push(0xF0); kbd_push(0x3E); break;
            case SDL_SCANCODE_9: if (release) kbd_push(0xF0); kbd_push(0x46); break;

            // Keypad
            case SDL_SCANCODE_KP_0: if (release) kbd_push(0xF0); kbd_push(0x70); break;
            case SDL_SCANCODE_KP_1: if (release) kbd_push(0xF0); kbd_push(0x69); break;
            case SDL_SCANCODE_KP_2: if (release) kbd_push(0xF0); kbd_push(0x72); break;
            case SDL_SCANCODE_KP_3: if (release) kbd_push(0xF0); kbd_push(0x7A); break;
            case SDL_SCANCODE_KP_4: if (release) kbd_push(0xF0); kbd_push(0x6B); break;
            case SDL_SCANCODE_KP_5: if (release) kbd_push(0xF0); kbd_push(0x73); break;
            case SDL_SCANCODE_KP_6: if (release) kbd_push(0xF0); kbd_push(0x74); break;
            case SDL_SCANCODE_KP_7: if (release) kbd_push(0xF0); kbd_push(0x6C); break;
            case SDL_SCANCODE_KP_8: if (release) kbd_push(0xF0); kbd_push(0x75); break;
            case SDL_SCANCODE_KP_9: if (release) kbd_push(0xF0); kbd_push(0x7D); break;

            // Специальные символы
            case SDL_SCANCODE_GRAVE:        if (release) kbd_push(0xF0); kbd_push(0x0E); break;
            case SDL_SCANCODE_MINUS:        if (release) kbd_push(0xF0); kbd_push(0x4E); break;
            case SDL_SCANCODE_EQUALS:       if (release) kbd_push(0xF0); kbd_push(0x55); break;
            case SDL_SCANCODE_BACKSLASH:    if (release) kbd_push(0xF0); kbd_push(0x5D); break;
            case SDL_SCANCODE_LEFTBRACKET:  if (release) kbd_push(0xF0); kbd_push(0x54); break;
            case SDL_SCANCODE_RIGHTBRACKET: if (release) kbd_push(0xF0); kbd_push(0x5B); break;
            case SDL_SCANCODE_SEMICOLON:    if (release) kbd_push(0xF0); kbd_push(0x4C); break;
            case SDL_SCANCODE_APOSTROPHE:   if (release) kbd_push(0xF0); kbd_push(0x52); break;
            case SDL_SCANCODE_COMMA:        if (release) kbd_push(0xF0); kbd_push(0x41); break;
            case SDL_SCANCODE_PERIOD:       if (release) kbd_push(0xF0); kbd_push(0x49); break;
            case SDL_SCANCODE_SLASH:        if (release) kbd_push(0xF0); kbd_push(0x4A); break;
            case SDL_SCANCODE_BACKSPACE:    if (release) kbd_push(0xF0); kbd_push(0x66); break;
            case SDL_SCANCODE_SPACE:        if (release) kbd_push(0xF0); kbd_push(0x29); break;
            case SDL_SCANCODE_TAB:          if (release) kbd_push(0xF0); kbd_push(0x0D); break;
            case SDL_SCANCODE_CAPSLOCK:     if (release) kbd_push(0xF0); kbd_push(0x58); break;
            case SDL_SCANCODE_LSHIFT:       if (release) kbd_push(0xF0); kbd_push(0x12); break;
            case SDL_SCANCODE_LCTRL:        if (release) kbd_push(0xF0); kbd_push(0x14); break;
            case SDL_SCANCODE_LALT:         if (release) kbd_push(0xF0); kbd_push(0x11); break;
            case SDL_SCANCODE_RSHIFT:       if (release) kbd_push(0xF0); kbd_push(0x59); break;
            case SDL_SCANCODE_RETURN:       if (release) kbd_push(0xF0); kbd_push(0x5A); break;
            case SDL_SCANCODE_ESCAPE:       if (release) kbd_push(0xF0); kbd_push(0x76); break;
            case SDL_SCANCODE_NUMLOCKCLEAR: if (release) kbd_push(0xF0); kbd_push(0x77); break;
            case SDL_SCANCODE_KP_MULTIPLY:  if (release) kbd_push(0xF0); kbd_push(0x7C); break;
            case SDL_SCANCODE_KP_MINUS:     if (release) kbd_push(0xF0); kbd_push(0x7B); break;
            case SDL_SCANCODE_KP_PLUS:      if (release) kbd_push(0xF0); kbd_push(0x79); break;
            case SDL_SCANCODE_KP_PERIOD:    if (release) kbd_push(0xF0); kbd_push(0x71); break;
            case SDL_SCANCODE_SCROLLLOCK:   if (release) kbd_push(0xF0); kbd_push(0x7E); break;

            // F1-F12 Клавиши
            case SDL_SCANCODE_F1:   if (release) kbd_push(0xF0); kbd_push(0x05); break;
            case SDL_SCANCODE_F2:   if (release) kbd_push(0xF0); kbd_push(0x06); break;
            case SDL_SCANCODE_F3:   if (release) kbd_push(0xF0); kbd_push(0x04); break;
            case SDL_SCANCODE_F4:   if (release) kbd_push(0xF0); kbd_push(0x0C); break;
            case SDL_SCANCODE_F5:   if (release) kbd_push(0xF0); kbd_push(0x03); break;
            case SDL_SCANCODE_F6:   if (release) kbd_push(0xF0); kbd_push(0x0B); break;
            case SDL_SCANCODE_F7:   if (release) kbd_push(0xF0); kbd_push(0x83); break;
            case SDL_SCANCODE_F8:   if (release) kbd_push(0xF0); kbd_push(0x0A); break;
            case SDL_SCANCODE_F9:   if (release) kbd_push(0xF0); kbd_push(0x01); break;
            case SDL_SCANCODE_F10:  if (release) kbd_push(0xF0); kbd_push(0x09); break;
            case SDL_SCANCODE_F11:  if (release) kbd_push(0xF0); kbd_push(0x78); break;
            case SDL_SCANCODE_F12:  if (release) kbd_push(0xF0); kbd_push(0x07); break;

            // Расширенные клавиши
            case SDL_SCANCODE_LGUI:         kbd_push(0xE0); if (release) kbd_push(0xF0); kbd_push(0x1F); break;
            case SDL_SCANCODE_RGUI:         kbd_push(0xE0); if (release) kbd_push(0xF0); kbd_push(0x27); break;
            case SDL_SCANCODE_APPLICATION:  kbd_push(0xE0); if (release) kbd_push(0xF0); kbd_push(0x2F); break;
            case SDL_SCANCODE_RCTRL:        kbd_push(0xE0); if (release) kbd_push(0xF0); kbd_push(0x14); break;
            case SDL_SCANCODE_RALT:         kbd_push(0xE0); if (release) kbd_push(0xF0); kbd_push(0x11); break;
            case SDL_SCANCODE_KP_DIVIDE:    kbd_push(0xE0); if (release) kbd_push(0xF0); kbd_push(0x4A); break;
            case SDL_SCANCODE_KP_ENTER:     kbd_push(0xE0); if (release) kbd_push(0xF0); kbd_push(0x5A); break;

            case SDL_SCANCODE_INSERT:       kbd_push(0xE0); if (release) kbd_push(0xF0); kbd_push(0x70); break;
            case SDL_SCANCODE_HOME:         kbd_push(0xE0); if (release) kbd_push(0xF0); kbd_push(0x6C); break;
            case SDL_SCANCODE_END:          kbd_push(0xE0); if (release) kbd_push(0xF0); kbd_push(0x69); break;
            case SDL_SCANCODE_PAGEUP:       kbd_push(0xE0); if (release) kbd_push(0xF0); kbd_push(0x7D); break;
            case SDL_SCANCODE_PAGEDOWN:     kbd_push(0xE0); if (release) kbd_push(0xF0); kbd_push(0x7A); break;
            case SDL_SCANCODE_DELETE:       kbd_push(0xE0); if (release) kbd_push(0xF0); kbd_push(0x71); break;

            case SDL_SCANCODE_UP:           kbd_push(0xE0); if (release) kbd_push(0xF0); kbd_push(0x75); break;
            case SDL_SCANCODE_DOWN:         kbd_push(0xE0); if (release) kbd_push(0xF0); kbd_push(0x72); break;
            case SDL_SCANCODE_LEFT:         kbd_push(0xE0); if (release) kbd_push(0xF0); kbd_push(0x6B); break;
            case SDL_SCANCODE_RIGHT:        kbd_push(0xE0); if (release) kbd_push(0xF0); kbd_push(0x74); break;

            // Клавиша PrnScr
            case SDL_SCANCODE_PRINTSCREEN: {

                if (release == 0) {

                    kbd_push(0xE0); kbd_push(0x12);
                    kbd_push(0xE0); kbd_push(0x7C);

                } else {

                    kbd_push(0xE0); kbd_push(0xF0); kbd_push(0x7C);
                    kbd_push(0xE0); kbd_push(0xF0); kbd_push(0x12);
                }

                break;
            }

            // Клавиша Pause
            case SDL_SCANCODE_PAUSE: {

                kbd_push(0xE1);
                kbd_push(0x14); if (release) kbd_push(0xF0); kbd_push(0x77);
                kbd_push(0x14); if (release) kbd_push(0xF0); kbd_push(0x77);
                break;
            }
        }
    }

    void kbd_push(int data) {

        if (kbd_top >= 255) return;
        kbd[kbd_top] = data;
        kbd_top++;
    }

    void kbd_pop(int& ps_clock, int& ps_data) {

        // В очереди нет клавиш для нажатия
        if (kbd_top == 0) return;

        // 25000000/2000 = 12.5 kHz Очередной полутакт для PS/2
        if (++kbd_ticker >= 2000) {

            ps_clock = kbd_phase & 1;

            switch (kbd_phase) {

                // Старт-бит [=0]
                case 0: case 1: ps_data = 0; break;

                // Бит четности
                case 18: case 19:

                    ps_data = 1;
                    for (int i = 0; i < 8; i++)
                        ps_data ^= !!(kbd[0] & (1 << i));

                    break;

                // Стоп-бит [=1]
                case 20: case 21: ps_data = 1; break;

                // Небольшая задержка между нажатиями клавиш
                case 22: case 23:
                case 24: case 25:

                    ps_clock = 1;
                    ps_data  = 1;
                    break;

                // Завершение
                case 26:

                    // Удалить символ из буфера
                    for (int i = 0; i < kbd_top - 1; i++)
                        kbd[i] = kbd[i+1];

                    kbd_top--;
                    kbd_phase = -1;
                    ps_clock  = 1;
                    break;

                // Отсчет битов от 0 до 7
                // 0=2,3   | 1=4,5   | 2=6,7   | 3=8,9
                // 4=10,11 | 5=12,13 | 6=14,15 | 7=16,17
                default:

                    ps_data = !!(kbd[0] & (1 << ((kbd_phase >> 1) - 1)));
                    break;
            }

            kbd_ticker = 0;
            kbd_phase++;
        }
    }

    int readb(int address) {
        return memory[address & 0xfffff];
    }

    int fetchb() {

        int a = readb(eip);
        eip = (eip + 1) & 0xfffff;
        return a;
    }

    int fetchw() { int a = fetchb(); int b = fetchb(); return b*256 + a; }
    int fetchd() { int a = fetchw(); int b = fetchw(); return b*65536 + a; }

    // Дизассемблирование modrm
    int disas_modrm(int reg32, int mem32) {

        int n = 0, b, w;

        /* Очистка */
        dis_rg[0] = 0;
        dis_rm[0] = 0;

        b = fetchb(); n++;

        rm  = (b & 0x07);
        reg = (b & 0x38) >> 3;
        mod = (b & 0xc0);

        /* Печать регистра 8/16/32 */
        switch (reg32) {
            case 0x08: sprintf(dis_rg, "%s", regnames[ reg ]); break;
            case 0x10: sprintf(dis_rg, "%s", regnames[ reg + 0x08 ]); break;
            case 0x20: sprintf(dis_rg, "%s", regnames[ reg + 0x10 ]); break;
            default:   sprintf(dis_rg, "<unknown>"); break;
        }

        // 16 бит
        if (mem32 == 0) {

            /* Rm-часть */
            switch (mod) {

                /* Индекс без disp или disp16 */
                case 0x00:

                    if (rm == 6) {
                        w = fetchw(); n += 2;
                        sprintf(dis_rm, "[%s%04x]", dis_px, w);
                    } else {
                        sprintf(dis_rm, "[%s%s]", dis_px, rm16names[ rm ]);
                    }

                    break;

                /* + disp8 */
                case 0x40:

                    b = fetchb(); n++;
                    if (b & 0x80) {
                        sprintf(dis_rm, "[%s%s-%02x]", dis_px, rm16names[ rm ], (0xff ^ b) + 1);
                    } else if (b == 0) {
                        sprintf(dis_rm, "[%s%s]", dis_px, rm16names[ rm ]);
                    } else {
                        sprintf(dis_rm, "[%s%s+%02x]", dis_px, rm16names[ rm ], b);
                    }

                    break;

                /* + disp16 */
                case 0x80:

                    w = fetchw(); n += 2;
                    if (w & 0x8000) {
                        sprintf(dis_rm, "[%s%s-%04x]", dis_px, rm16names[ rm ], (0xFFFF ^ w) + 1);
                    } else if (w == 0) {
                        sprintf(dis_rm, "[%s%s]", dis_px, rm16names[ rm ]);
                    } else {
                        sprintf(dis_rm, "[%s%s+%04x]", dis_px, rm16names[ rm ], w);
                    }

                    break;

                /* Регистровая часть */
                case 0xc0:

                    switch (reg32) {
                        case 0x08: sprintf(dis_rm, "%s", regnames[ rm ]); break;
                        case 0x10: sprintf(dis_rm, "%s", regnames[ rm + 0x08 ]); break;
                        case 0x20: sprintf(dis_rm, "%s", regnames[ rm + 0x10 ]); break;
                    }

                    break;
            }
        }
        // 32 бит
        else {

            int sib = 0, sibhas = 0;

            switch (mod) {

                case 0x00:

                    if (rm == 5) {

                        w = fetchd(); n += 4;
                        sprintf(dis_rm, "[%s%08x]", dis_px, w);

                    } else if (rm == 4) { /* SIB */

                        sib = fetchb(); n++;
                        sibhas = 1;

                    } else {
                        sprintf(dis_rm, "[%s%s]", dis_px, regnames[0x10 + rm]);
                    }

                    break;

                /* + disp8 */
                case 0x40:


                    if (rm == 4) {

                        sib = fetchb(); n++;
                        sibhas = 1;

                    } else {

                        b = fetchb(); n++;

                        if (b & 0x80) {
                            sprintf(dis_rm, "[%s%s-%02x]", dis_px, regnames[ 0x10 + rm ], (0xff ^ b) + 1);
                        } else if (b == 0) {
                            sprintf(dis_rm, "[%s%s]", dis_px, regnames[ 0x10 + rm ]);
                        } else {
                            sprintf(dis_rm, "[%s%s+%02x]", dis_px, regnames[ 0x10 + rm ], b);
                        }
                    }

                    break;

                /* + disp32 */
                case 0x80:


                    if (rm == 4) {

                        sib = fetchb(); n++;
                        sibhas = 1;

                    } else {

                        w = fetchd(); n += 4;

                        if (w & 0x80000000) {
                        sprintf(dis_rm, "[%s%s-%04x]", dis_px, regnames[ 0x10 + rm ], (0xFFFFFFFF ^ w) + 1);
                        } else if (w == 0) {
                            sprintf(dis_rm, "[%s%s]", dis_px, regnames[ 0x10 + rm ]);
                        } else {
                            sprintf(dis_rm, "[%s%s+%04x]", dis_px, regnames[ 0x10 + rm ], w);
                        }
                    }

                    break;

                /* Регистровая часть */
                case 0xc0:

                    switch (reg32) {
                        case 0x08: sprintf(dis_rm, "%s", regnames[ rm ]); break;
                        case 0x10: sprintf(dis_rm, "%s", regnames[ rm + 0x08 ]); break;
                        case 0x20: sprintf(dis_rm, "%s", regnames[ rm + 0x10 ]); break;
                    }

                    break;
            }

            /* Имеется байт SIB */
            if (sibhas) {

                char cdisp32[16]; cdisp32[0] = 0;

                int disp = 0;
                int sib_ss = (sib & 0xc0);
                int sib_ix = (sib & 0x38) >> 3;
                int sib_bs = (sib & 0x07);

                /* Декодирование Displacement */
                switch (mod) {

                    case 0x40:

                        disp = fetchb(); n += 1;

                        if (disp & 0x80) {
                            sprintf(cdisp32, "-%02X", (disp ^ 0xff) + 1);
                        } else {
                            sprintf(cdisp32, "+%02X", disp);
                        }

                        break;

                   case 0x80:
                   case 0xc0:

                        disp = fetchd(); n += 4;
                        if (disp & 0x80000000) {
                            sprintf(cdisp32, "-%08X", (disp ^ 0xffffffff) + 1);
                        } else {
                            sprintf(cdisp32, "+%08X", disp);
                        }
                        break;
                }

                /* Декодирование Index */
                if (sib_ix == 4) {

                    sprintf(dis_rm, "[%s%s]", dis_px, regnames[ 0x10 + sib_bs ]);

                } else {

                    switch (sib_ss) {

                        case 0x00:

                            sprintf(dis_rm, "[%s%s+%s]", dis_px, regnames[ 0x10 + sib_bs ], regnames[ 0x10 + sib_ix ]);
                            break;

                        case 0x40:

                            sprintf(dis_rm, "[%s%s+2*%s%s]", dis_px, regnames[ 0x10 + sib_bs ], regnames[ 0x10 + sib_ix ], cdisp32);
                            break;

                        case 0x80:

                            sprintf(dis_rm, "[%s%s+4*%s%s]", dis_px, regnames[ 0x10 + sib_bs ], regnames[ 0x10 + sib_ix ], cdisp32);
                            break;

                        case 0xc0:

                            sprintf(dis_rm, "[%s%s+8*%s%s]", dis_px, regnames[ 0x10 + sib_bs ], regnames[ 0x10 + sib_ix ], cdisp32);
                            break;
                    }
                }
            }
        }

        return n;
    }

    // Дизассемблировать строку
    int disassemble(int address) {

        eip = address & 0xfffff;

        int  ereg = 0, emem = 0, stop = 0;
        char dis_pf[8];
        char dis_cmd [32];
        char dis_cmd2[64];
        char dis_ops[128];
        char dis_dmp[128];
        char dis_sfx[8];

        int n = 0, i, j, d, opcode = 0;
        int elock = 0;

        // Очистить префикс
        dis_px[0]  = 0; // Сегментный префикс
        dis_pf[0]  = 0; // Префикс
        dis_ops[0] = 0; // Операнды
        dis_dmp[0] = 0; // Минидамп
        dis_sfx[0] = 0; // Суффикс

        /* Декодирование префиксов (до 6 штук) */
        for (i = 0; i < 6; i++) {

            d = fetchb();
            n++;

            switch (d) {
                case 0x0F: opcode |= 0x100; break;
                case 0x26: sprintf(dis_px, "%s", "es:"); break;
                case 0x2E: sprintf(dis_px, "%s", "cs:"); break;
                case 0x36: sprintf(dis_px, "%s", "ss:"); break;
                case 0x3E: sprintf(dis_px, "%s", "ss:"); break;
                case 0x64: sprintf(dis_px, "%s", "fs:"); break;
                case 0x65: sprintf(dis_px, "%s", "gs:"); break;
                case 0x66: ereg = ereg ^ 1; break;
                case 0x67: emem = emem ^ 1; break;
                case 0xf0: elock = 1; break;
                case 0xf2: sprintf(dis_pf, "%s", "repnz "); break;
                case 0xf3: sprintf(dis_pf, "%s", "rep "); break;
                default:   opcode |= d; stop = 1; break;
            }

            if (stop) break;
        }

        int opdec    = ops[ opcode & 255 ];
        int hasmodrm = modrm_lookup[ opcode ];

        // Типичная мнемоника
        if (opdec != 0xff) {
            sprintf(dis_cmd, "%s", mnemonics[ opdec ] );
        }

        // Байт имеет modrm
        if (hasmodrm) {

            // Размер по умолчанию 8 бит, если opcode[0] = 1, то либо 16, либо 32
            int regsize = opcode & 1 ? (ereg ? 32 : 16) : 8;
            int swmod   = opcode & 2; // Обмен местами dis_rm и dis_rg

            if (opcode == /* BOUND */ 0x62) regsize = (ereg ? 32 : 16);

            // SWmod
            if (opcode == /* ARPL */ 0x63) swmod = 0;
            if (opcode == /* LEA */ 0x8D || opcode == 0xC4 /* LES */ || opcode == 0xC5) swmod = 1;

            // Regsize
            if (opcode == /* SREG */ 0x8C || opcode == 0x8E ||
                opcode == /* LES */ 0xC4) regsize = (ereg ? 32 : 16);

            // Получить данные из modrm
            n += disas_modrm(regsize, emem ? 0x20 : 0x00);

            // GRP-1 8
            if (opcode == 0x80 || opcode == 0x82) {

                sprintf(dis_cmd, "%s", mnemonics[ reg ]  );
                sprintf(dis_ops, "%s, %02X", dis_rm, fetchb()); n++;
            }

            // GRP-1 16/32
            else if (opcode == 0x81) {

                sprintf(dis_cmd, "%s", mnemonics[ reg ]  );

                if (ereg) {
                    sprintf(dis_ops, "%s, %08X", dis_rm, fetchd()); n += 4;
                } else {
                    sprintf(dis_ops, "%s, %04X", dis_rm, fetchw()); n += 2;
                }
            }

            // GRP-1 16/32: Расширение 8 бит до 16/32
            else if (opcode == 0x83) {

                int b8 = fetchb(); n++;
                sprintf(dis_cmd, "%s", mnemonics[ reg ]  );

                if (ereg) {
                    sprintf(dis_ops, "%s, %08X", dis_rm, b8 | (b8 & 0x80 ? 0xFFFFFF00 : 0));
                } else {
                    sprintf(dis_ops, "%s, %04X", dis_rm, b8 | (b8 & 0x80 ? 0xFF00 : 0));
                }
            }

            // IMUL imm16
            else if (opcode == 0x69) {

                if (ereg) {
                    sprintf(dis_ops, "%s, %s, %08X", dis_rg, dis_rm, fetchd() ); n += 4;
                } else {
                    sprintf(dis_ops, "%s, %s, %04X", dis_rg, dis_rm, fetchw() ); n += 2;
                }
            }
            // Групповые инструкции #2: Byte
            else if (opcode == 0xF6) {

                sprintf(dis_cmd, "%s", grp2[ reg ]  );
                if (reg < 2) { /* TEST */
                    sprintf(dis_ops, "%s, %02X", dis_rm, fetchb() ); n++;
                } else {
                    sprintf(dis_ops, "%s", dis_rm);
                }
            }

            // Групповые инструкции #2: Word/Dword
            else if (opcode == 0xF7) {

                sprintf(dis_cmd, "%s", grp2[ reg ]  );

                if (reg < 2) { /* TEST */
                    if (ereg) {
                        sprintf(dis_ops, "%s, %08X", dis_rm, fetchd() ); n += 4;
                    } else {
                        sprintf(dis_ops, "%s, %04X", dis_rm, fetchw() ); n += 2;
                    }
                } else {
                    sprintf(dis_ops, "%s", dis_rm);
                }
            }

            // Групповые инструкции #3: Byte
            else if (opcode == 0xFE) {

                if (reg < 2) {
                    sprintf(dis_cmd, "%s", grp3[ reg ]  );
                    sprintf(dis_ops, "byte %s", dis_rm );
                } else {
                    sprintf(dis_cmd, "(unk)");
                }
            }
            // Групповые инструкции #3: Word / Dword
            else if (opcode == 0xFF) {

                sprintf(dis_cmd, "%s", grp3[ reg ]  );
                sprintf(dis_ops, "%s %s", ereg ? "dword" : "word", dis_rm );

            }

            // Сегментные и POP r/m
            else if (opcode == 0x8C) { sprintf(dis_ops, "%s, %s", dis_rm, regnames[ 0x18 + reg ] ); }
            else if (opcode == 0x8E) { sprintf(dis_ops, "%s, %s", regnames[ 0x18 + reg ], dis_rm ); }
            else if (opcode == 0x8F) { sprintf(dis_ops, "%s %s", ereg ? "dword" : "word", dis_rm ); }

            // GRP-2: imm
            else if (opcode == 0xC0 || opcode == 0xC1) {
                sprintf(dis_cmd, "%s", mnemonics[ 0x66 + reg ]);
                sprintf(dis_ops, "%s, %02X", dis_rm, fetchb()); n++;
            }
            // 1
            else if (opcode == 0xD0 || opcode == 0xD1) {
                sprintf(dis_cmd, "%s", mnemonics[ 0x66 + reg ]);
                sprintf(dis_ops, "%s, 1", dis_rm);
            }
            // cl
            else if (opcode == 0xD2 || opcode == 0xD3) {
                sprintf(dis_cmd, "%s", mnemonics[ 0x66 + reg ]);
                sprintf(dis_ops, "%s, cl", dis_rm);
            }
            // mov r/m, i8/16/32
            else if (opcode == 0xC6) {
                sprintf(dis_ops, "%s, %02X", dis_rm, fetchb()); n++;
            }
            else if (opcode == 0xC7) {
                if (ereg) {
                    sprintf(dis_ops, "%s, %08X", dis_rm, fetchd()); n += 4;
                } else {
                    sprintf(dis_ops, "%s, %04X", dis_rm, fetchw()); n += 2;
                }
            }
            // Обычные
            else {
                sprintf(dis_ops, "%s, %s", swmod ? dis_rg : dis_rm, swmod ? dis_rm : dis_rg);
            }

        } else {

            // [00xx_x10x] АЛУ AL/AX/EAX, i8/16/32
            if ((opcode & 0b11000110) == 0b00000100) {

                if ((opcode & 1) == 0) { // 8 bit
                    sprintf(dis_ops, "al, %02X", fetchb()); n++;
                } else if (ereg == 0) { // 16 bit
                    sprintf(dis_ops, "ax, %04X", fetchw()); n += 2;
                } else {
                    sprintf(dis_ops, "eax, %08X", fetchd()); n += 4;
                }
            }

            // [000x x11x] PUSH/POP
            else if ((opcode & 0b11100110) == 0b00000110) {
                sprintf(dis_ops, "%s", regnames[0x18 + ((opcode >> 3) & 3)] );
            }

            // [0100_xxxx] INC/DEC/PUSH/POP
            else if ((opcode & 0b11100000) == 0b01000000) {
                sprintf(dis_ops, "%s", regnames[ (ereg ? 0x10 : 0x08) + (opcode & 7)] );
            }
            else if (opcode == 0x60 && ereg) { sprintf(dis_cmd, "pushad"); }
            else if (opcode == 0x61 && ereg) { sprintf(dis_cmd, "popad"); }

            // PUSH imm16/32
            else if (opcode == 0x68) {

                if (ereg) {
                    sprintf(dis_ops, "%08X", fetchd()); n += 4;
                } else {
                    sprintf(dis_ops, "%04X", fetchw()); n += 2;
                }
            }
            // PUSH imm8
            else if (opcode == 0x6A) { int t = fetchb(); sprintf(dis_ops, "%04X", t | ((t & 0x80) ? 0xFF00 : 0)); n++; }
            // Jccc rel8
            else if (((opcode & 0b11110000) == 0b01110000) || (opcode >= 0xE0 && opcode <= 0xE3) || (opcode == 0xEB)) {
                int br = fetchb(); n++;
                sprintf(dis_ops, "%08X", (br & 0x80 ? (eip + br - 256) : eip + br ));
            }
            else if (opcode == 0x6c) sprintf(dis_cmd, "insb");
            else if (opcode == 0x6d) sprintf(dis_cmd, ereg ? "insd" : "insw");
            else if (opcode == 0x6e) sprintf(dis_cmd, "outsb");
            else if (opcode == 0x6f) sprintf(dis_cmd, ereg ? "outsd" : "outsw");
            // XCHG ax, r16/32
            else if (opcode > 0x90 && opcode <= 0x97) {
                if (ereg) {
                    sprintf(dis_ops, "eax, %s", regnames[ 0x10 + (opcode & 7) ] );
                } else {
                    sprintf(dis_ops, "ax, %s", regnames[ 0x8 + (opcode & 7) ] );
                }
            }
            else if (opcode == 0x98 && ereg) sprintf(dis_cmd, "cwde");
            else if (opcode == 0x99 && ereg) sprintf(dis_cmd, "cdq");

            // CALLF/JMPF
            else if (opcode == 0x9A || opcode == 0xEA) {

                int dw = ereg ? fetchd() : fetchw();
                n += (ereg ? 4 : 2);

                int sg = fetchw();
                n += 2;

                if (ereg) sprintf(dis_ops, "%04X:%08X", sg, dw);
                    else  sprintf(dis_ops, "%04X:%04X", sg, dw);
            }
            // MOV
            else if (opcode == 0xA0) { sprintf(dis_ops, "al, [%04X]", fetchw()); n += 2; }
            else if (opcode == 0xA1) { sprintf(dis_ops, "ax, [%04X]", fetchw()); n += 2; }
            else if (opcode == 0xA2) { sprintf(dis_ops, "[%04X], al", fetchw()); n += 2; }
            else if (opcode == 0xA3) { sprintf(dis_ops, "[%04X], ax", fetchw()); n += 2; }
            else if (opcode == 0xA8) { sprintf(dis_ops, "al, %02X", fetchb()); n++; }
            // TEST
            else if (opcode == 0xA9) {
                if (ereg) {
                    sprintf(dis_ops, "eax, %08X", fetchd()); n += 4;
                } else {
                    sprintf(dis_ops, "ax, %04X", fetchw()); n += 2;
                }
            }
            else if ((opcode >= 0xA4 && opcode <= 0xA7) || (opcode >= 0xAA && opcode <= 0xAF)) {
                sprintf(dis_sfx, opcode&1 ? (ereg ? "d" : "w") : "b");
            }
            else if (opcode >= 0xB0 && opcode <= 0xB7) {
                sprintf(dis_ops, "%s, %02x", regnames[ opcode & 7 ], fetchb()); n++;
            }
            else if (opcode >= 0xB8 && opcode <= 0xBF) {
                if (ereg) {
                    sprintf(dis_ops, "%s, %08x", regnames[ 0x10 + (opcode & 7) ], fetchd()); n += 4;
                } else {
                    sprintf(dis_ops, "%s, %04x", regnames[ 0x08 + (opcode & 7) ], fetchw()); n += 2;
                }
            }
            // RET / RETF
            else if (opcode == 0xc2 || opcode == 0xca) {
                sprintf(dis_ops, "%04X", fetchw()); n += 2;
            }
            // ENTER
            else if (opcode == 0xC8) {

                int aa = fetchw();
                int ab = fetchb();
                sprintf(dis_ops, "%04x, %02X", aa, ab); n += 3;
            }
            // INT
            else if (opcode == 0xCD) { sprintf(dis_ops, "%02X", fetchb()); n++; }
            // IO/OUT
            else if (opcode == 0xE4) { sprintf(dis_ops, "al, %02X", fetchb()); n++; }
            else if (opcode == 0xE5) { sprintf(dis_ops, "%s, %02X", ereg ? "eax" : "ax", fetchb()); n++; }
            else if (opcode == 0xE6) { sprintf(dis_ops, "%02X, al", fetchb()); n++; }
            else if (opcode == 0xE7) { sprintf(dis_ops, "%02X, %s", fetchb(), ereg ? "eax" : "ax"); n++; }
            else if (opcode == 0xEC) { sprintf(dis_ops, "al, dx"); }
            else if (opcode == 0xED) { sprintf(dis_ops, "%s, dx", ereg ? "eax" : "ax"); }
            else if (opcode == 0xEE) { sprintf(dis_ops, "dx, al"); }
            else if (opcode == 0xEF) { sprintf(dis_ops, "dx, %s", ereg ? "eax" : "ax"); }
            // CALL / JMP rel16
            else if (opcode == 0xE8 || opcode == 0xE9) {
                if (ereg) {

                    int m = fetchd(); n += 4;
                        m = (m & 0x80000000) ? m - 0x100000000 : m;
                    sprintf(dis_ops, "%08X", m);

                } else {
                    int m = fetchw(); n += 2;
                        m = (m & 0x8000) ? m - 0x10000 : m;
                    sprintf(dis_ops, "%04X", m + (eip & 0xffff));
                }
            }

        }

        // Максимальное кол-во байт должно быть не более 6
        for (i = 0; i < 6; i++) {
            if (i == 5 && n > 5) {
                sprintf(dis_dmp + 2*i, "..");
            } else if (i < n) {
                sprintf(dis_dmp + 2*i, "%02X", readb(address + i));
            } else {
                sprintf(dis_dmp + 2*i, "  ");
            }
        }

        // Суффикс команды
        sprintf(dis_cmd2, "%s%s", dis_cmd, dis_sfx);

        // Дополнить пробелами мнемонику
        for (i = 0; i < 8; i++) {
            if (dis_cmd2[i] == 0) {
                for (j = i; j < 8; j++) {
                    dis_cmd2[j] = ' ';
                }
                dis_cmd2[8 - 1] = 0;
                break;
            }
        }

        // Формирование строки вывода
        // Дамп инструкции, команда, операнды
        sprintf(dis_row, "%s %s%s%s %s", dis_dmp, elock ? "lock " : "", dis_pf, dis_cmd2, dis_ops);
        return n;
    }
};
