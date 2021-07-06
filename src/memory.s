    .bss

    .global drive_info
    .global drive_info.number
    .global drive_info.cylinders
    .global drive_info.sectors
    .global drive_info.heads 

drive_info:
drive_info.number:
    .byte 0x00

drive_info.cylinders:
    .word 0x0000

drive_info.sectors:
    .byte 0x00

drive_info.heads:
    .byte 0x00