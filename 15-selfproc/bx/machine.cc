#include "main.h"
#include "font.h"

// -----------------------------------------------------------------------------
// ОБЩИЕ МЕТОДЫ
// -----------------------------------------------------------------------------

Main::Main(int w, int h, int scale, int fps) {

    create(w, h, scale, "SDL2 Window", fps);
    memory = (unsigned char*) malloc(1024*1024);
}

Main::~Main() {
    destroy();
}

// Создать новое окно
int Main::create(int w, int h, int scale, const char* name = "SDL2", int fps = 50) {

    unsigned format = SDL_PIXELFORMAT_BGRA32;

    _scale  = scale;
    _width  = w;
    _height = h;

    width  = w * scale;
    height = h * scale;

    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO)) {
        exit(1);
    }

    SDL_ClearError();

    // Создать окно
    sdl_window = SDL_CreateWindow(name, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, width, height, SDL_WINDOW_SHOWN);
    if (sdl_window == NULL) exit(1);

    // Создать отрисовщик текстур
    sdl_renderer = SDL_CreateRenderer(sdl_window, -1, SDL_RENDERER_PRESENTVSYNC);
    if (!sdl_renderer) exit(1);

    // Формат пикселей
    sdl_pixel_format = SDL_AllocFormat(format);
    if (!sdl_pixel_format) exit(1);

    //  Создать текстуру в памяти
    sdl_screen_texture = SDL_CreateTexture(sdl_renderer, format, SDL_TEXTUREACCESS_STREAMING, width, height);
    if (!sdl_screen_texture) exit(1);

    // Смешивания текстур нет
    SDL_SetTextureBlendMode(sdl_screen_texture, SDL_BLENDMODE_NONE);

    // Буфер экрана в памяти
    screen_buffer    = (Uint32*)malloc(width * height * sizeof(Uint32));

    // Настройка FPS
    frame_length     = 1000 / (fps ? fps : 1);
    frame_prev_ticks = SDL_GetTicks();

    return 0;
}

// Ожидание событий
int Main::event() {

    for (;;) {

        Uint32 ticks = SDL_GetTicks();

        // Ожидать наступления события
        if (SDL_PollEvent(& evt)) {

            switch (evt.type) {

                // Выход из программы по нажатии "крестика"
                case SDL_QUIT: {
                    return 0;
                }

                // https://wiki.machinesdl.org/SDL_Scancode

                // Нажатие на клавишу
                case SDL_KEYDOWN: {

                    kb = evt.key.keysym.scancode;
                    return EvtKbDown;
                }

                // Клавиша отпущена
                case SDL_KEYUP: {

                    kb = evt.key.keysym.scancode;
                    return EvtKbUp;
                }

                // Движение мыши
                case SDL_MOUSEMOTION: {

                    mx = evt.motion.x;
                    my = evt.motion.y;
                    return EvtMsMotion;
                }

                // Движение мыши
                case SDL_MOUSEBUTTONDOWN:
                case SDL_MOUSEBUTTONUP: {

                    // SDL_BUTTON_LEFT | SDL_BUTTON_MIDDLE | SDL_BUTTON_RIGHT
                    mb = evt.button.button;

                    // SDL_PRESSED | SDL_RELEASED
                    ms = evt.button.state;

                    return EvtMsButton;
                }

                // Все другие события
                default: {
                    return EvtOther;
                }
            }
        }

        // Истечение таймаута: обновление экрана
        if (ticks - frame_prev_ticks >= frame_length) {

            frame_prev_ticks = ticks;
            update();
            return EvtRedraw;
        }

        SDL_Delay(1);
    }
}

// Обновить окно
void Main::update() {

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
void Main::destroy() {

    if (sdl_screen_texture) {
        SDL_DestroyTexture(sdl_screen_texture);
        sdl_screen_texture = NULL;
    }

    if (sdl_pixel_format) {
        SDL_FreeFormat(sdl_pixel_format);
        sdl_pixel_format = NULL;
    }

    if (sdl_renderer) {
        SDL_DestroyRenderer(sdl_renderer);
        sdl_renderer = NULL;
    }

    free(screen_buffer);
    free(memory);

    SDL_DestroyWindow(sdl_window);
    SDL_Quit();
}

// Инициализация процессора
void Main::load(int argc, char** argv) {

    for (int i = 0; i < 256;  i++) regs[i] = 0;
    for (int i = 0; i < 2*1024; i++) stack[i] = 0;

    tstates = 0;
    ip = 0;
    sp = 0;
    of = 0; sf = 0; zf = 0; cf = 0;

    if (argc > 1) {

        FILE* fp = fopen(argv[1], "rb");
        if (fp) {

            fseek(fp, 0, SEEK_END);
            int fs = ftell(fp);
            fseek(fp, 0, SEEK_SET);
            size_t rslt = fread(memory, 1, fs, fp);
            if (rslt == 0) printf("Warning: don't read anything\n");
            fclose(fp);

        } else {

            printf("File not found: %s", argv[1]);
            exit(1);
        }
    }
}

void Main::regdump() {

    for (int i = 0; i < 16; i++) printf("       %x ", i);
    printf("\n");

    for (int i = 0; i < 16; i++) {
        printf("%02x: ", i*16);
        for (int j = 0; j < 16; j++) {
            printf("%08x ", (unsigned int) regs[16*i+j]);
        }
        printf("\n");
    }

    printf("IP=%08x ", (unsigned int)ip);
    printf("STACK=%04x ", (unsigned int)sp);
    printf("CYCLE=%d ", (int)tstates);
    printf("[%c%c%c%c]\n",
        (of?'O':' '),
        (sf?'S':' '),
        (zf?'Z':' '),
        (cf?'C':' '));
}

// -----------------------------------------------------------------------------
// ФУНКЦИИ РИСОВАНИЯ
// -----------------------------------------------------------------------------

// Установка точки
void Main::pset(int x, int y, Uint32 cl) {

    if (x < 0 || y < 0 || x >= _width || y >= _height)
        return;

    if (_scale == 1) {
        screen_buffer[y*width + x] = cl;
    } else {
        for (int i = 0; i < _scale; i++)
        for (int j = 0; j < _scale; j++)
            screen_buffer[(_scale*y+i)*width + (_scale*x + j)] = cl;
    }
}

// -----------------------------------------------------------------------------
// РАБОТА С ПАМЯТЬЮ
// -----------------------------------------------------------------------------

// Запись байта
void Main::writeb(dword address, byte data) {

    memory[ address & 0xfffff ] = data;

    // Видеопамять
    if (address >= 0xC0000 && address < 0x100000) {

        address -= 0xC0000;
        int x = address % 640;
        int y = address / 640;
        pset(x, y, dac[data]);
    }
}

// Чтение байта
byte Main::readb(dword address) {
    return memory[address & 0xfffff];
}

// Чтение слова
dword Main::readd(dword address) {

    byte ll = readb(address);
    byte lh = readb(address+1);
    byte hl = readb(address+2);
    byte hh = readb(address+3);
    return ll + (lh<<8) + (hl<<16) + (hh<<24);
}

// Запись слова
void Main::writed(dword address, dword data) {

    writeb(address,   data);
    writeb(address+1, data>>8);
    writeb(address+2, data>>16);
    writeb(address+3, data>>24);
}

