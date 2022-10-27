#include "app.cc"
#include "cpu.cc"

int main(int argc, char** argv) {

    App* app = new App(640, 400, 1);

    app->print("HELLO WORLD");

    while (app->main()) {
        // stub
    }

    return app->destroy();
}
