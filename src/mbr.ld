OUTPUT_FORMAT("binary", "binary", "binary");
OUTPUT_ARCH(i386:x86-64);
ENTRY(start)

SECTIONS {
    mbr 0x7c00: AT(0x0000) {
        KEEP(src/mbr.o(.text))
        FILL(0x00)
        . = 0x01fe;
        SHORT(0xaa55)
    }
    monitor 0x8800: AT(0x0200) {
        KEEP(src/monitor.o(.text))
        FILL(0x00)
        . = 0x0200;
    }
    ram 0x7e00 (NOLOAD): {
        KEEP(src/mbr.o(.bss))
    }
}