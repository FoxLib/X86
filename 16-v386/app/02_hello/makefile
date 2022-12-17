CC=clang
# gcc -mgeneral-regs-only
COPT=-Os -I../../include -ffreestanding -fno-pie -nostdlib -m32 -mno-sse -mno-mmx
DEPS=nasm.o main.o
ROOT=../..

all: $(DEPS)
	ld -m elf_i386 -nostdlib -nodefaultlibs --oformat binary -Ttext=0xF8000 -Tdata=0x800 $(DEPS) -o bios.bin
	objdump -Mintel -S main.o > main.lst
	php $(ROOT)/utils/makebin.php bios.bin $(ROOT)/bios.hex
	php $(ROOT)/utils/bin2mif.php bios.bin 32768 > $(ROOT)/de0/bios.mif
	mv bios.bin $(ROOT)/bios.bin
	cd $(ROOT) && make
nasm.o: main.asm
	nasm -felf32 -o nasm.o main.asm
%.o: %.c
	$(CC) $(COPT) -c $< -o $@
clean:
	rm -f *.o *.ini

