all: binhex asm verilog #win32
asm:
	fasm bios.asm bios.bin
	./binhex bios.bin tb.hex de0/memory.mif
win32:	
	g++ -o tb tb.cc -lSDL2
	strip tb.exe
	upx tb.exe
	./tb bios.bin
verilog:
	iverilog -g2005-sv -DICARUS=1 -o tb.qqq tb.v core.v
	vvp tb.qqq >> /dev/null
	rm tb.qqq
vcd:
	gtkwave tb.vcd
wave:
	gtkwave tb.gtkw
binhex:
	g++ binhex.cc -o binhex
clean:
	rm -rf tb tb.exe bios.bin
