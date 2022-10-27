#include "x86.cc"
#include "disasm.cc"

int main(int argc, char** argv) {

    X86* x86 = new X86(argc, argv);
    x86->debugout();

    while (x86->main()) {
        x86->process();
    }

    return x86->destroy();
}
