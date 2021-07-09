    .global     start
    .global     lba2chs
    .global     print_string
    .global     print_return
    .global     print_number8
    .global     drive_info
    .global     drive_info.number
    .global     drive_info.cylinders
    .global     drive_info.sectors
    .global     drive_info.heads
    .global     msg_ok
    .global     msg_failed
    .global     mamory_map_counter

# ------------------------------------------------------------------
# プログラム
    .text
    .code16

start:
    # スタック領域を0x7c00から下に
    cli
    xor     %ax, %ax
    mov     %ax, %ss
    mov     $0x7c00, %sp
    # セグメントの初期化
    mov     %ax, %ds
    mov     %ax, %es
    sti
    # ビデオモードを16色テキストに
    mov     $0x03, %al
    int     $0x10

    # 起動ディスクの情報を取得
    mov     %dl, drive_info.number
    # ドライブパラメータの取得
    # CH = 最大シリンダ番号[7:0]
    # CL = 最大シリンダ番号[9:8] 最大セクタ番号[5:0]
    # DH = 最大ヘッド番号
    mov     $0x08, %ah
    int     $0x13
    inc     %dh
    mov     %dh, drive_info.heads
    mov     %ch, drive_info.cylinders
    push    %cx
    and     $0b00111111, %cl
    mov     %cl, drive_info.sectors
    pop     %cx
    shr     $6, %cl
    mov     %cl, drive_info.cylinders+1
    incw    drive_info.cylinders

    # セクタを読み込む
    mov     $msg_loading, %si
    call    print_string
    mov     $0x0001, %ax
    call    lba2chs
    mov     $0x0205, %ax
    mov     drive_info.number, %dl
    mov     $0x8800, %bx
    clc
    int     $0x13
    jc      failed
    mov     $msg_ok, %si
    call    print_string
    ljmpw   $0x0000, $start16

failed:
    mov     $msg_failed, %si
    call    print_string
    mov     %ah, %al
    call    print_number8
failed_halt:
    hlt
    jmp     failed_halt

# ------------------------------------------------------------------
# サブルーチン

# LBAをCHSに変換
# パラメータ
#     AX: LBA
# 戻り値
#     CH: シリンダ番号[7:0]
#     CL: シリンダ番号[9:8], セクタ番号[5:0]
#     DH: ヘッド番号
lba2chs:
    # レジスタを退避
    push    %ax
    push    %bx
    push    %dx
    # Tempとセクタ番号を求める
    xor     %dx, %dx
    xor     %bh, %bh
    mov     drive_info.sectors, %bl
    div     %bx
    inc     %dx
    and     $0b00111111, %dl
    mov     %dl, %cl
    # ヘッド番号とシリンダ番号を求める
    xor     %dx, %dx
    mov     drive_info.heads, %bl
    div     %bx
    mov     %al, %ch
    and     $0b00000011, %ah
    shl     $6, %ah
    or      %ah, %cl
    mov     %dl, %dh
    # レジスタを戻す
    pop     %ax
    mov     %al, %dl
    pop     %bx
    pop     %ax
    ret

# 文字列の出力
# SI: 文字列のアドレス
print_string:
    push    %ax
    push    %bx
    push    %si
    mov     $0x0e, %ah
    mov     $0x0000, %bx
print_string.loop:
    lodsb
    cmp     $0x00, %al
    je      print_string.exit
    int     $0x10
    jmp     print_string.loop
print_string.exit:
    pop     %si
    pop     %bx
    pop     %ax
    ret

# 改行の出力
print_return:
    push    %ax
    push    %bx
    mov     $0x0e0d, %ax
    mov     $0x0000, %bx
    int     $0x10
    mov     $0x0a, %al
    int     $0x10
    pop     %bx
    pop     %ax
    ret

# 8ビット数字の出力
# AL: 数字
print_number8:
    # スタックに退避
    push    %ax
    push    %bx
    push    %si
    # 数字を上位ビットと下位ビットに分ける
    mov     %al, %ah
    shr     $4, %ah
    and     $0x0f, %al
    mov     $0x0000, %bx
    push    %ax
    # 上位ビットを出力
    shr     $8, %ax
    call    print_number8.print
    # 下位ビットを出力
    pop     %ax
    mov     $0x00, %ax
    call    print_number8.print
    # スタックから戻す
    pop     %si
    pop     %bx
    pop     %ax
    ret

print_number8.print:
    mov     %ax, %si
    mov     print_number8.numbers(%si), %al
    mov     $0x0e, %ah
    int     $0x10
    ret

# ------------------------------------------------------------------
# 定数
    .data

print_number8.numbers:
    .ascii "0123456789ABCDEF"

msg_loading:
    .asciz "Loading boot monitor..."

msg_ok:
    .asciz "OK!"

msg_failed:
    .asciz "Failed! 0x"

# ------------------------------------------------------------------
# メモリ
    .bss

drive_info:
drive_info.number:
    .byte 0x00

drive_info.cylinders:
    .word 0x0000

drive_info.sectors:
    .byte 0x00

drive_info.heads:
    .byte 0x00

mamory_map_counter:
    .byte 0x00