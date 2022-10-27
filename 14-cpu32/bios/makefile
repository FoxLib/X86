all:
	fasm bios.asm bios.bin
	php convert.php
	php bin2mif.php bios.bin 32768 > ../de0/bios.mif
	cd .. && make
