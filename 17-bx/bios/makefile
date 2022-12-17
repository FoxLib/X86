ROOT=../../
all:
	fasm bios.asm bios.bin
	php $(ROOT)/utils/makebin.php
	php $(UTIL)/utils/bin2mif.php bios.bin 32768 > $(ROOT)/de0/bios.mif
