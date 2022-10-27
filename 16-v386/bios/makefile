all: comp run
comp:
	fasm bios.asm bios.bin
	php makebin.php
	php bin2mif.php bios.bin 32768 > ../de0/bios.mif
run:
	cd .. && make icarus && make int3
