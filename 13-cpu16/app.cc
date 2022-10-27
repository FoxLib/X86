#define SDL_MAIN_HANDLED

#include <SDL2/SDL.h>
#include <stdlib.h>
#include <stdio.h>
#include "app.h"

class App {

protected:

    int width, height, frame_length, pticks;
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
    uint8_t*            memory;
    int                 need_update = 1;
    int                 keyb[256];
    uint8_t             kbt = 0, kbc = 0;

public:

    App(int argc, char** argv, const char* title = "SDL2 Application") {

        frame_id     = 0;
        width        = 640;
        height       = 400;
        frame_length = 1000/25;

        if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO)) {
            exit(1);
        }

        SDL_ClearError();
        screen_buffer       = (Uint32*) malloc(width * height * sizeof(Uint32));
        sdl_window          = SDL_CreateWindow(title, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, width, height, SDL_WINDOW_SHOWN);
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

                        keyb[kbt++] = parse_keycode(evt.key.keysym.scancode, 0);
                        break;

                    case SDL_KEYUP:
                    
                        keyb[kbt++] = parse_keycode(evt.key.keysym.scancode, 1);
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
        dstRect.w = width;
        dstRect.h = height;

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

    void cls(Uint32 cl) {

        back = cl;
        for (int y = 0; y < height; y++)
        for (int x = 0; x < width; x++)
            pset(x, y, cl);
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
            frame_id++;
        }
    }

    // Полное обновление дисплея
    void display_update() {

        saveframe();

        if (need_update == 0)
            return; 

        int k = 0;
        for (int i = 0; i < 25; i++)
        for (int j = 0; j < 80; j++) {

            uint8_t attr = memory[0xB801 + k];
            fore = dos_palette[attr & 15];
            back = dos_palette[attr >> 4];
            printc(j*8, i*16, memory[0xB800 + k]);
            k += 2;
        }

        need_update = 0;
    }

    // По сканкоду получить ASCII-код
    int parse_keycode(int scancode, int release) {
        
        release = (release ? 0x80 : 0x00);

        switch (scancode) {

            // Коды клавиш A-Z
            case SDL_SCANCODE_A: return 'A' | release;
            case SDL_SCANCODE_B: return 'B' | release;
            case SDL_SCANCODE_C: return 'C' | release;
            case SDL_SCANCODE_D: return 'D' | release;
            case SDL_SCANCODE_E: return 'E' | release;
            case SDL_SCANCODE_F: return 'F' | release;
            case SDL_SCANCODE_G: return 'G' | release;
            case SDL_SCANCODE_H: return 'H' | release;
            case SDL_SCANCODE_I: return 'I' | release;
            case SDL_SCANCODE_J: return 'J' | release;
            case SDL_SCANCODE_K: return 'K' | release;
            case SDL_SCANCODE_L: return 'L' | release;
            case SDL_SCANCODE_M: return 'M' | release;
            case SDL_SCANCODE_N: return 'N' | release;
            case SDL_SCANCODE_O: return 'O' | release;
            case SDL_SCANCODE_P: return 'P' | release;
            case SDL_SCANCODE_Q: return 'Q' | release;
            case SDL_SCANCODE_R: return 'E' | release;
            case SDL_SCANCODE_S: return 'S' | release;
            case SDL_SCANCODE_T: return 'T' | release;
            case SDL_SCANCODE_U: return 'U' | release;
            case SDL_SCANCODE_V: return 'V' | release;
            case SDL_SCANCODE_W: return 'W' | release;
            case SDL_SCANCODE_X: return 'X' | release;
            case SDL_SCANCODE_Y: return 'Y' | release;
            case SDL_SCANCODE_Z: return 'Z' | release;

            // Цифры
            case SDL_SCANCODE_0: return '0' | release;
            case SDL_SCANCODE_1: return '1' | release;
            case SDL_SCANCODE_2: return '2' | release;
            case SDL_SCANCODE_3: return '3' | release;
            case SDL_SCANCODE_4: return '4' | release;
            case SDL_SCANCODE_5: return '5' | release;
            case SDL_SCANCODE_6: return '6' | release;
            case SDL_SCANCODE_7: return '7' | release;
            case SDL_SCANCODE_8: return '8' | release;
            case SDL_SCANCODE_9: return '9' | release;

            // Keypad
            case SDL_SCANCODE_KP_0: return '0' | release;
            case SDL_SCANCODE_KP_1: return '1' | release;
            case SDL_SCANCODE_KP_2: return '2' | release;
            case SDL_SCANCODE_KP_3: return '3' | release;
            case SDL_SCANCODE_KP_4: return '4' | release;
            case SDL_SCANCODE_KP_5: return '5' | release;
            case SDL_SCANCODE_KP_6: return '6' | release;
            case SDL_SCANCODE_KP_7: return '7' | release;
            case SDL_SCANCODE_KP_8: return '8' | release;
            case SDL_SCANCODE_KP_9: return '9' | release;
            
            // Специальные символы
            case SDL_SCANCODE_GRAVE:        return '`' | release;
            case SDL_SCANCODE_MINUS:        return '-' | release;
            case SDL_SCANCODE_EQUALS:       return '=' | release;
            case SDL_SCANCODE_BACKSLASH:    return '\\'| release;
            case SDL_SCANCODE_LEFTBRACKET:  return '[' | release;
            case SDL_SCANCODE_RIGHTBRACKET: return ']' | release;
            case SDL_SCANCODE_SEMICOLON:    return ';' | release;
            case SDL_SCANCODE_APOSTROPHE:   return '\'' | release;
            case SDL_SCANCODE_COMMA:        return ',' | release;
            case SDL_SCANCODE_PERIOD:       return '.' | release;
            case SDL_SCANCODE_KP_DIVIDE:
            case SDL_SCANCODE_SLASH:        return '/' | release;
            case SDL_SCANCODE_BACKSPACE:    return key_BS | release;
            case SDL_SCANCODE_SPACE:        return ' ' | release;
            case SDL_SCANCODE_TAB:          return key_TAB | release;
            case SDL_SCANCODE_LSHIFT:
            case SDL_SCANCODE_RSHIFT:       return key_LSHIFT | release;
            case SDL_SCANCODE_LCTRL:
            case SDL_SCANCODE_RCTRL:        return key_LCTRL   | release;
            case SDL_SCANCODE_LALT:
            case SDL_SCANCODE_RALT:         return key_LALT   | release;
            case SDL_SCANCODE_KP_ENTER:
            case SDL_SCANCODE_KP_MULTIPLY:  return '*' | release;
            case SDL_SCANCODE_KP_MINUS:     return '-' | release;
            case SDL_SCANCODE_KP_PLUS:      return '+' | release;
            case SDL_SCANCODE_KP_PERIOD:    return '.' | release;
            case SDL_SCANCODE_RETURN:       return key_ENTER  | release;
            case SDL_SCANCODE_ESCAPE:       return key_ESC    | release;
            case SDL_SCANCODE_NUMLOCKCLEAR: return key_NL     | release;
            case SDL_SCANCODE_APPLICATION:  return key_APP | release;

            // F1-F12 Клавиши
            case SDL_SCANCODE_F1:  return key_F1 | release;
            case SDL_SCANCODE_F2:  return key_F2 | release;
            case SDL_SCANCODE_F3:  return key_F3 | release;
            case SDL_SCANCODE_F4:  return key_F4 | release;
            case SDL_SCANCODE_F5:  return key_F5 | release;
            case SDL_SCANCODE_F6:  return key_F6 | release;
            case SDL_SCANCODE_F7:  return key_F7 | release;
            case SDL_SCANCODE_F8:  return key_F8 | release;
            case SDL_SCANCODE_F9:  return key_F9 | release;
            case SDL_SCANCODE_F10: return key_F10 | release;
            case SDL_SCANCODE_F11: return key_F11 | release;
            case SDL_SCANCODE_F12: return key_F12 | release;

            // Расширенные клавиши
            case SDL_SCANCODE_UP:       return key_UP   | release;
            case SDL_SCANCODE_DOWN:     return key_DN   | release;
            case SDL_SCANCODE_LEFT:     return key_LF   | release;
            case SDL_SCANCODE_RIGHT:    return key_RT   | release;
            case SDL_SCANCODE_INSERT:   return key_INS  | release;
            case SDL_SCANCODE_HOME:     return key_HOME | release;
            case SDL_SCANCODE_END:      return key_END  | release;
            case SDL_SCANCODE_PAGEUP:   return key_PGUP | release;
            case SDL_SCANCODE_PAGEDOWN: return key_PGDN | release;
            case SDL_SCANCODE_DELETE:   return key_DEL  | release;
        }

        return 0;
    }

    // Следующий введенный код
    int get_next_key() {

        if (kbt == kbc) return 0;
        return keyb[kbc++];
    }
};
