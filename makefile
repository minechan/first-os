all:
	as -o src/mbr.o src/mbr.s
	as -o src/monitor.o src/monitor.s
	ld -N -T src/mbr.ld -o boot.bin