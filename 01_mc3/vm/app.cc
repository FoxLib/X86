#define SDL_MAIN_HANDLED

#include <SDL2/SDL.h>
#include <stdlib.h>
#include <stdio.h>

#include "app.h"

class App {

protected:

    int width, height, scale, frame_length, pticks;
    int frame_id;
    int fore = 0xffffff;
    int back = 0;

    SDL_Surface*        screen_surface;
    SDL_Window*         sdl_window;
    SDL_Renderer*       sdl_renderer;
    SDL_PixelFormat*    sdl_pixel_format;
    SDL_Texture*        sdl_screen_texture;
    SDL_Event           evt;
    Uint32*             screen_buffer;

    // Реализация процессора
    unsigned char mem[65536];
    unsigned short opcode, modrm;
    unsigned short ax, bx, cx, dx, sp, bp, si, di;
    unsigned short flags, ip = 0;
    unsigned short ea, op1, op2, dir, size, mod, mod_reg, mod_rm;

public:

    App(int w = 640, int h = 400, int s = 1, const char* title = "SDL2 Application") {

        frame_id     = 0;
        width        = w;
        height       = h;
        scale        = s;
        frame_length = 50;      // 20 кадров в секунду

        if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO)) {
            exit(1);
        }

        SDL_ClearError();
        screen_buffer       = (Uint32*) malloc(width * height * sizeof(Uint32));
        sdl_window          = SDL_CreateWindow(title, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, scale*width, scale*height, SDL_WINDOW_SHOWN);
        sdl_renderer        = SDL_CreateRenderer(sdl_window, -1, SDL_RENDERER_PRESENTVSYNC);
        sdl_pixel_format    = SDL_AllocFormat(SDL_PIXELFORMAT_BGRA32);
        sdl_screen_texture  = SDL_CreateTexture(sdl_renderer, SDL_PIXELFORMAT_BGRA32, SDL_TEXTUREACCESS_STREAMING, width, height);
        SDL_SetTextureBlendMode(sdl_screen_texture, SDL_BLENDMODE_NONE);
    }

    // Основной цикл
    int main() {

        for (;;) {

            Uint32 ticks = SDL_GetTicks();

            while (SDL_PollEvent(& evt)) {

                // Прием событий
                switch (evt.type) {

                    case SDL_QUIT:
                        return 0;

                    case SDL_KEYDOWN:

                        // keyb = evt.key.keysym.scancode;
                        break;

                    case SDL_KEYUP:

                        // keyb = evt.key.keysym.scancode;
                        break;
                }
            }

            // Обновление экрана
            if (ticks - pticks >= frame_length) {

                pticks = ticks;
                update();
                return 1;
            }

            SDL_Delay(1);
        }
    }

    // Обновить окно
    void update() {

        SDL_Rect dstRect;

        dstRect.x = 0;
        dstRect.y = 0;
        dstRect.w = scale * width;
        dstRect.h = scale * height;

        SDL_UpdateTexture       (sdl_screen_texture, NULL, screen_buffer, width * sizeof(Uint32));
        SDL_SetRenderDrawColor  (sdl_renderer, 0, 0, 0, 0);
        SDL_RenderClear         (sdl_renderer);
        SDL_RenderCopy          (sdl_renderer, sdl_screen_texture, NULL, &dstRect);
        SDL_RenderPresent       (sdl_renderer);
    }

    // Уничтожение окна
    int destroy() {

        free(screen_buffer);
        SDL_DestroyTexture(sdl_screen_texture);
        SDL_FreeFormat(sdl_pixel_format);
        SDL_DestroyRenderer(sdl_renderer);
        SDL_DestroyWindow(sdl_window);
        SDL_Quit();
        return 0;
    }

    // Установка точки
    void pset(int x, int y, Uint32 cl) {

        if (x < 0 || y < 0 || x >= width || y >= height)
            return;

        screen_buffer[width*y + x] = cl;
    }

    // Печать символа
    void printc(int x, int y, char c) {

        for (int i = 0; i < 16; i++)
        for (int j = 0; j < 8; j++) {

            int cl = (font[16*(unsigned char)c + i] & (1 << (7-j))) ? fore : back;
            if (cl >= 0) pset(x + j, y + i, cl);
        }
    }

    // Печать строки
    void print(const char* msg, int x = 0, int y = 0) {

        int i = 0;
        while (msg[i]) {

            printc(x + i*8, y, msg[i]);
            i++;
        }
    }

    // Сохранение фрейма
    void saveframe() {

        FILE* fp = fopen("out/record.ppm", "ab");
        if (fp) {

            fprintf(fp, "P6\n# Verilator\n640 400\n255\n");
            for (int y = 0; y < 400; y++)
            for (int x = 0; x < 640; x++) {

                int cl = screen_buffer[y*width + x];
                int vl = ((cl >> 16) & 255) + (cl & 0xFF00) + ((cl & 255)<<16);
                fwrite(&vl, 1, 3, fp);
            }

            fclose(fp);
        }

        frame_id++;
    }

    // ============== PROCESSOR ================================================

    unsigned char fetch();
    unsigned short fetch_word();
    unsigned short get_reg(int n, int bit);
    unsigned short read(int A, int bit);
    unsigned short group_alu(int id, unsigned short op1, unsigned short op2);

    void fetch_modrm();
    void step();

};
