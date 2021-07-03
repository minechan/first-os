all:
	as -o src/mbr.o src/mbr.s
	ld --oformat binary -e start -Ttext 0x7c00 -o boot.bin src/mbr.o