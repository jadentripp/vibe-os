// Read-only app-record metadata and indexed artwork for the AArch64 Pi 4 launcher.

.arch armv8-a

.section .rodata.pi4_launcher_app_record_strings, "a", %progbits
.balign 8
.global pi4_launcher_app_record_present_state
pi4_launcher_app_record_present_state:
    .asciz "present"

.global pi4_launcher_app_record_absent_state
pi4_launcher_app_record_absent_state:
    .asciz "absent"

.section .rodata.pi4_launcher_palette, "a", %progbits
.balign 4
.global pi4_launcher_indexed_palette
pi4_launcher_indexed_palette:
    .byte 0x00, 0x00, 0x00
    .byte 0x5c, 0x4a, 0x0b
    .byte 0x86, 0x6f, 0x14
    .byte 0xc6, 0xd3, 0xd8
    .byte 0xd9, 0x64, 0x0a
    .byte 0xe8, 0xf7, 0xff
    .byte 0x6e, 0x75, 0x7a
    .byte 0xf0, 0xfa, 0xff
    .byte 0x2b, 0x2f, 0xc8
    .byte 0xf2, 0xbf, 0x39
    .byte 0x0a, 0x08, 0x24
    .byte 0x1a, 0x7b, 0xff
    .byte 0x3d, 0x2f, 0x10
    .byte 0x5a, 0xb4, 0xd8
    .byte 0x30, 0x26, 0x20
    .byte 0xff, 0xe6, 0x9e

    .rept 16
    .byte 0x00, 0x00, 0x00
    .endr

    .set pi4_art_r, 0
    .rept 6
        .set pi4_art_g, 0
        .rept 6
            .set pi4_art_b, 0
            .rept 6
                .byte pi4_art_b * 51, pi4_art_g * 51, pi4_art_r * 51
                .set pi4_art_b, pi4_art_b + 1
            .endr
            .set pi4_art_g, pi4_art_g + 1
        .endr
        .set pi4_art_r, pi4_art_r + 1
    .endr

    .rept 8
    .byte 0xff, 0xff, 0xff
    .endr

.section .rodata.pi4_launcher_label_bits, "a", %progbits
.balign 4
.global pi4_launcher_key_1_bitmap
pi4_launcher_key_1_bitmap:
    .word 0b010
    .word 0b110
    .word 0b010
    .word 0b010
    .word 0b111

.global pi4_launcher_key_2_bitmap
pi4_launcher_key_2_bitmap:
    .word 0b111
    .word 0b001
    .word 0b111
    .word 0b100
    .word 0b111

.global pi4_launcher_enter_label_bitmap
pi4_launcher_enter_label_bitmap:
    .word 0b1110101011101110110
    .word 0b1000111001001000101
    .word 0b1100111001001100110
    .word 0b1000111001001000101
    .word 0b1110101001001110101

    .balign 4
    .global pi4_launcher_cursor_bitmap
    pi4_launcher_cursor_bitmap:
    .word 0b100000000
    .word 0b110000000
    .word 0b111000000
    .word 0b111100000
    .word 0b111110000
    .word 0b111111000
    .word 0b111111100
    .word 0b111100000
    .word 0b110110000
    .word 0b100110000
    .word 0b000011000
    .word 0b000011000
    .word 0b000001100

    .section .note.GNU-stack, "", %progbits
