#include "main.h"

int main(int argc, char* argv[]) {

    Main app(640, 400, 2, 25);

    app.load(argc, argv);
    dword cycle = 0;

    // Обработка возникшего события
    while (int event = app.event()) {

        switch (event) {

            // Обработать обновление экрана
            case EvtRedraw:

                // Симуляция исполнения 25 Mhz
                while (cycle < 1000000) cycle += app.step();
                cycle %= 1000000;
                break;
        }
    }

    app.regdump();
    return 0;
}
