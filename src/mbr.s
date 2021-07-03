.code16
.global     start

# --------------------------------------
# メインのプログラム
start:
    # スタック領域を0x7c00から下に
    cli
    xor     %ax, %ax
    mov     %ax, %ss
    mov     $0x7c00, %sp
    # セグメントの初期化
    mov     %ax, %ds
    mov     %ax, %es
    sli
    # ビデオモードを16色テキストに
    mov     $0x03,  %al
    int     $0x10

# --------------------------------------
# サブルーチン

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

# --------------------------------------
# リソース

