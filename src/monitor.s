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
load_memory_map:
    # メモリマップを読み込む
    mov     $msg_memory_map, %si
    call    print_string
    mov     $0xe820, %eax
    xor     %ebx, %ebx
    mov     $20, %ecx               # デスクリプタのバイト数
    mov     $0x534d4150, %edx       # "SMAP"
    # mov     $0, %es                 # デスクリプタを書き込むアドレス
    mov     $0x8000, %di
load_memory_map.loop:
    int     $0x15
    jc      load_memory_map.failed
    cmp     $0x534d4150, %eax
    jne     load_memory_map.failed
    # アドレスを追加
    add     $20, %di
    # カウンタを追加
    incb    mamory_map_counter
    # Continuation valueが0なら終了
    test    %ebx, %ebx
    je      load_memory_map.exit
    mov     $0xe820, %eax
    mov     $20, %ecx
    mov     $0x534d4150, %edx
    jmp     load_memory_map.loop
load_memory_map.exit:
    mov     $msg_ok, %si
    call    print_string
    call    print_return
    jmp     enable_a20
load_memory_map.failed:
    mov     $msg_failed, %si
    call    print_string
load_memory_map.halt:
    hlt
    jmp     load_memory_map.halt
enable_a20:
    # A20を有効化
    mov $msg_a20, %si
    call print_string
    cli                         # 割り込みを無効化
    xor     %cx, %cx
enable_a20.wait1:
    inc     %cx                 # CXがオーバーフローするまで試す
    jz      enable_a20.failed
    in      $0x64, %al          # ビジーでなくなるまで待つ
    test    $0x02, %al
    jnz     enable_a20.wait1
    mov     $0xd1, %al          # コマンドを出力する(P2に0x60)
    out     %al, $0x64
enable_a20.wait2:
    in      $0x64, %al          # ビジーでなくなるまで待つ
    test    $0x02, %al
    jnz     enable_a20.wait2
    mov     $0xdf, %al          # コマンドを出力する(A20を有効化)
    out     %al, $0x60
    jmp     init_protected_mode
enable_a20.failed:
    # A20の有効化に失敗
    mov $msg_failed, %si
    call print_string
    sti
enable_a20.halt:
    hlt
    jmp enable_a20.halt
init_protected_mode:
    # プロテクトモードの準備
    mov     $msg_ok, %si
    call    print_string
    call    print_return
    mov     $msg_protected_mode, %si
    call    print_string
    # IDTRとGDTRの設定
    lidt    (ldtr)
    lgdt    (gdtr)
    # プロテクトモードに入る
    mov     %cr0, %eax
    or      $0x1, %eax
    mov     %eax, %cr0
    # ジャンプ
    ljmpl   $0x08, $start32
# LDTR
ldtr:
    .word   0x00
    .long   0x00

# GDTR
gdtr:
    .word   gdt.limit - gdt - 1
    .long   gdt

# GDT
gdt:
    .word   0x0000, 0x0000, 0x0000, 0x0000
    .word   0xffff, 0x0000, 0x9a00, 0x00cf
    .word   0xffff, 0x0000, 0x9200, 0x00cf
gdt.limit:

# ------------------------------------------------------------------
# 定数
    .data

msg_boot:
    .ascii "Welcome to FirstOS!\r\n"
    .asciz "Repository: https://github.com/minechan/first-os\r\n"

msg_sector_value:
    .asciz "Value of sectors per track  : 0x"

msg_0x7e03_value:
    .asciz "Value of 0x7e03             : 0x"

msg_a20:
    .asciz "Enabling A20 Line..."

msg_protected_mode:
    .asciz "Initializing protected mode..."

msg_memory_map:
    .asciz "Gettings the memory map..."