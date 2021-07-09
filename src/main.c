#define VGA_BASE                0x000b8000
#define DRIVE_INFO_NUMBER       0x00007e00
#define DRIVE_INFO_CYLINDERS    0x00007e01
#define DRIVE_INFO_SECTORS      0x00007e03
#define DRIVE_INFO_HEADS        0x00007e04
#define MEMORY_MAP_COUNTER      0x00007e05
#define MEMORY_MAP_BASE         0x00008000

void hlt();
unsigned char cursor_x, cursor_y;

void main() {
    char* message_hello = "Hello FirstOS from protected mode!\n";
    char* message_url = "Repository: https://github.com/minechan/first-os\n\n";
    char* message_info = "Drive information:\n";
    char* message_info_number = "    Drive number       : 0x";
    char* message_info_cylinders = "    Cylinders          : 0x";
    char* message_info_sectors = "    Sectors per a track: 0x";
    char* message_info_heads = "    Heads              : 0x";
    char* message_memory_map = "Memory map:\n";
    char* message_memory_column = "    Start      End        Status\n";
    char* message_space4 = "    ";
    char* message_space1 = " ";
    char* message_0x = "0x";
    char* message_usable = "Usable";
    char* message_reserved = "Reserved";
    char* my_message = "Tsukaeru memory sukunakunai...?";
    cursor_x = 0;
    cursor_y = 0;

    clear_screen();
    print_string(&message_hello, 0x0f);
    print_string(&message_url, 0x07);
    print_string(&message_info, 0x07);
    print_string(&message_info_number, 0x07);
    print_number8(*(unsigned char*)DRIVE_INFO_NUMBER, 0x07);
    print_return();
    print_string(&message_info_cylinders, 0x07);
    print_number8(*(unsigned short*)DRIVE_INFO_CYLINDERS >> 8, 0x07);
    print_number8(*(unsigned short*)DRIVE_INFO_CYLINDERS & 0xff, 0x07);
    print_return();
    print_string(&message_info_sectors, 0x07);
    print_number8(*(unsigned char*)DRIVE_INFO_SECTORS, 0x07);
    print_return();
    print_string(&message_info_heads, 0x07);
    print_number8(*(unsigned char*)DRIVE_INFO_HEADS, 0x07);
    print_return();
    // メモリマップを出力
    print_string(&message_memory_map, 0x07);
    print_string(&message_memory_column, 0x07);
    int i = 0;
    for (i = 0; i < *(unsigned char*)MEMORY_MAP_COUNTER; i++) {
        print_string(&message_space4, 0x07);
        print_string(&message_0x, 0x07);
        print_number8(*(unsigned char*)(MEMORY_MAP_BASE + i * 20 + 3), 0x07);
        print_number8(*(unsigned char*)(MEMORY_MAP_BASE + i * 20 + 2), 0x07);
        print_number8(*(unsigned char*)(MEMORY_MAP_BASE + i * 20 + 1), 0x07);
        print_number8(*(unsigned char*)(MEMORY_MAP_BASE + i * 20), 0x07);
        print_string(&message_space1, 0x07);
        print_string(&message_0x, 0x07);
        unsigned int end_address = *(unsigned int*)(MEMORY_MAP_BASE + i * 20 + 8) - 1 + *(unsigned int*)(MEMORY_MAP_BASE + i * 20);
        print_number8(end_address >> 24, 0x07);
        print_number8(end_address >> 16 & 0xff, 0x07);
        print_number8(end_address >> 8 & 0xff, 0x07);
        print_number8(end_address & 0xff, 0x07);
        print_string(&message_space1, 0x07);
        switch (*(unsigned char*)(MEMORY_MAP_BASE + i * 20 + 16)) {
            case 1:
                print_string(&message_usable, 0x0a);
                break;
            case 2:
                print_string(&message_reserved, 0x0c);
                break;
        }
        print_return();
    }
    print_return();
    print_string(&my_message, 0x07);

    for(;;) {
        hlt();
    }
}

void clear_screen() {
    unsigned short i = 0;
    for (i = 0; i < 80 * 25; i++) {
        *(unsigned short*)(VGA_BASE + i) = 0x0000;
    }
    cursor_x = 0;
    cursor_y = 0;
}

void scroll_screen() {
    unsigned short i = 0;
    for (i = 0; i < 80 * 24; i++) {
        *(unsigned short*)(VGA_BASE + i) = *(unsigned short*)(VGA_BASE + i * 2 + 160);
    }
    for (i = 0; i < 80; i++) {
        *(unsigned short*)(VGA_BASE + i * 2 + 160 * 48) = 0x0000;
    }
}

void print_string(char** string, unsigned char attribute) {
    unsigned int offset = 0;
    while ((*string)[offset]) {
        if ((*string)[offset] == '\n') {
            print_return();
        } else {
            *(unsigned short*)(VGA_BASE + cursor_y * 160 + cursor_x * 2) = attribute << 8 | (*string)[offset];
            cursor_x++;
            if (cursor_x >= 80) {
                print_return();
            }
        }
        offset++;
    }
}

void print_number8(unsigned char number, unsigned char attribute) {
    print_number_char(number >> 4, attribute);
    print_number_char(number & 0x0f, attribute);
}

void print_number_char(unsigned char number, unsigned char attribute) {
    char* numbers = "0123456789ABCDEF";
    *(unsigned short*)(VGA_BASE + cursor_y * 160 + cursor_x * 2) = attribute << 8 | numbers[number];
    cursor_x++;
    if (cursor_x >= 80) {
        print_return();
    }
}

void print_return() {
    cursor_x = 0;
    cursor_y++;
    if (cursor_y >= 25) {
        scroll_screen();
        cursor_y--;
    }
}