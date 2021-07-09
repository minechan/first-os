    .global start32
    .global _hlt

# ------------------------------------------------------------------
# プログラム
    .text
    .code32

start32:
    # PICの無効化
    mov     $0xff, %al
    out     %al, $0x21
    mov     $0xff, %al
    out     %al, $0xa1
    # セグメントの設定
    mov     $0x10, %eax
    mov     %eax, %ss
    mov     %eax, %ds
    mov     %eax, %es
    mov     %eax, %fs
    mov     %eax, %gs
    # スタックポインタの設定
    mov     $0x7c00, %eax
    mov     %eax, %esp

    sti

    call    _main
_hlt:
    hlt
    jmp _hlt