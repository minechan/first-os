OUTPUT_FORMAT("binary", "binary", "binary");
OUTPUT_ARCH(i386);
ENTRY(start)

SECTIONS {
    mbr 0x7c00: AT(0x0000) {
        src/mbr.o(.text)
        src/mbr.o(.data)
        FILL(0x00)
        . = 0x01fe;
        SHORT(0xaa55)
    }
    monitor 0x8800: AT(0x0200) {
        src/monitor.o(.text)
        src/monitor.o(.data)
        FILL(0x00)
        . = 0x0200;
    }
    start32 0x8a00: AT(0x0400) {
        src/start32.o(.text)
        src/main.o(.text)
        src/main.o(.rodata)
        src/main.o(.rodata.*)
        src/main.o(.data)
    }
    ram 0x7e00 (NOLOAD): {
        KEEP(src/mbr.o(.bss))
        src/main.o(.bss)
    }

    property 0x0000(NOLOAD): {
        src/*(.note.gnu.property)
        src/*(.eh_frame)
    }
}