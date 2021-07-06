    .global     start16

# ------------------------------------------------------------------
# プログラム
    .text
    .code16

start16:
    call print_return
    call print_return
    mov $msg_boot, %si
    call print_string
    call print_return
    # メモリの値を確認
    mov $msg_sector_value, %si
    call print_string
    mov drive_info.sectors, %al
    call print_number8
    call print_return

    mov $msg_0x7e03_value, %si
    call print_string
    mov 0x7e03, %al
    call print_number8

start16.halt:
    hlt
    jmp start16.halt

# ------------------------------------------------------------------
# 定数

msg_boot:
    .ascii "Welcome to FirstOS!\r\n"
    .asciz "Repository: https://github.com/minechan/first-os\r\n"

msg_sector_value:
    .asciz "Value of sectors per track  : 0x"

msg_0x7e03_value:
    .asciz "Value of 0x7e03             : 0x"
