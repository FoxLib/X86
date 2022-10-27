#define SDL_MAIN_HANDLED

#include <SDL2/SDL.h>
#include <stdlib.h>
#include <stdio.h>

#define byte unsigned char
#define dword unsigned long long

enum MainEventSDL {

    EvtRedraw   = 1,
    EvtKbDown   = 2,
    EvtKbUp     = 3,
    EvtMsMotion = 4,
    EvtMsButton = 5,
    EvtOther    = 256
};

class Main {
protected:

    SDL_Surface*        screen_surface  = NULL;
    SDL_Window*         sdl_window      = NULL;
    SDL_Renderer*       sdl_renderer;
    SDL_PixelFormat*    sdl_pixel_format;
    SDL_Texture*        sdl_screen_texture;
    SDL_Event           evt;

    Uint32* screen_buffer;
    Uint32  width, height, _scale, _width, _height;
    Uint32  frame_length;
    Uint32  frame_prev_ticks;

    // Информация
    dword   stack[2048];
    dword   regs [256];
    byte*   memory;

    dword   ip;
    dword   sp;
    dword   tstates;

    byte    cf, zf, sf, of;

public:

    // Открытые поля
    int     kb, mx, my, ms, mb;

    // Конструктор и деструктор
     Main(int w, int h, int scale, int fps);
    ~Main();

    // Главные свойства окна
    int     create(int w, int h, int scale, const char* name, int fps);
    int     event();
    void    update();
    void    destroy();
    void    load(int, char**);

    void    pset(int x, int y, Uint32 cl);
    byte    fetch_byte();
    dword   fetch_dword();
    byte    readb(dword address);
    dword   readd(dword address);
    void    writeb(dword address, byte data);
    void    writed(dword address, dword data);
    void    push(dword data);
    dword   pop();
    int     step();
    dword   get_reg(int n);
    void    put_reg(int n, dword v);
    dword   grp(dword a, dword b, int instr);
    dword   sft(dword a, dword b, int instr);

    void    regdump();
};
