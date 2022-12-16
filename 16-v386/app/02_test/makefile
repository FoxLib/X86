CC=clang
COPT=-Os -ffreestanding -fno-pie -nostdlib -m32 -mno-sse
DEPS=nasm.o main.o

all: $(DEPS)
	ld -m elf_i386 -nostdlib -nodefaultlibs --oformat binary -Ttext=0x0600 -Tdata=0x10000 $(DEPS) -o core.bin
nasm.o: main.asm
	nasm -felf32 -o nasm.o main.asm
%.o: %.c
	$(CC) $(COPT) -c $< -o $@
clean:
	rm -f *.o *.ini

