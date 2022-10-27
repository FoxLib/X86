all:
	fasm main.asm main.bin
	../fonvert main.bin ../../tb.hex
	rm main.bin
	cd ../.. && make
