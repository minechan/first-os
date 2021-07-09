CFLAGS =-fleading-underscore -m32 -fno-pie -fno-asynchronous-unwind-tables -O2
ASFLAGS = --32

boot.img: src/mbr.o src/monitor.o src/start32.o src/main.o
	$(LD) -N -T src/mbr.ld -o $@ $^