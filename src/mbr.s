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
    sti
    # ビデオモードを16色テキストに
    mov     $0x03,  %al
    int     $0x10
    # メッセージの出力
    # call    print_return
    mov     $msg_hello, %si
    call    print_string
halt:
    # 停止
    hlt
    jmp halt

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

print_number8.numbers:
    .ascii "0123456789ABCDEF"

# --------------------------------------
# リソース

msg_hello:
    .ascii "Hello, world!\r\n"
    .asciz "Repository: https://github.com/minechan/first-os\r\n"

.fill 510-(.-start), 1, 0
.word 0xaa55
