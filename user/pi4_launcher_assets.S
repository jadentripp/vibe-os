// Read-only slot metadata and indexed artwork for the AArch64 Pi 4 launcher.

.arch armv8-a

.equ PI4_LAUNCHER_SLOT_DOOM,        0
.equ PI4_LAUNCHER_SLOT_QUAKE,       1
.equ PI4_LAUNCHER_SLOT_STATE_PRESENT, 1

.section .rodata.pi4_launcher_slots, "a", %progbits
.balign 8
.global pi4_launcher_slot_table
pi4_launcher_slot_table:
    .quad PI4_LAUNCHER_SLOT_DOOM
    .quad pi4_launcher_slot_doom_name
    .quad pi4_launcher_slot_doom_path
    .quad PI4_LAUNCHER_SLOT_STATE_PRESENT
    .quad pi4_launcher_slot_present_state
    .quad PI4_LAUNCHER_SLOT_QUAKE
    .quad pi4_launcher_slot_quake_name
    .quad pi4_launcher_slot_quake_path
    .quad PI4_LAUNCHER_SLOT_STATE_PRESENT
    .quad pi4_launcher_slot_present_state

.global pi4_launcher_slot_doom_name
pi4_launcher_slot_doom_name:
    .asciz "DOOM"

.global pi4_launcher_slot_quake_name
pi4_launcher_slot_quake_name:
    .asciz "QUAKE"

.global pi4_launcher_slot_doom_path
pi4_launcher_slot_doom_path:
    .asciz "PAYLOAD0.ELF"

.global pi4_launcher_slot_quake_path
pi4_launcher_slot_quake_path:
    .asciz "PAYLOAD1.ELF"

.global pi4_launcher_slot_present_state
pi4_launcher_slot_present_state:
    .asciz "present"

.section .rodata.pi4_launcher_palette, "a", %progbits
.balign 4
.global pi4_launcher_indexed_palette
pi4_launcher_indexed_palette:
    .byte 0x00, 0x00, 0x00
    .byte 0x05, 0x07, 0x0d
    .byte 0x15, 0x18, 0x22
    .byte 0x24, 0x26, 0x31
    .byte 0xff, 0xc7, 0x3d
    .byte 0xff, 0xf4, 0xd7
    .byte 0x8a, 0x93, 0xa2
    .byte 0xb7, 0xc0, 0xcf
    .byte 0xc8, 0x2f, 0x2b
    .byte 0x31, 0xb5, 0xff
    .byte 0x31, 0x0b, 0x11
    .byte 0xff, 0x7b, 0x1a
    .byte 0x0d, 0x24, 0x34
    .byte 0xe2, 0xb8, 0x54
    .byte 0x1d, 0x22, 0x2d
    .byte 0xff, 0xec, 0x8a

    .rept 16
    .byte 0x00, 0x00, 0x00
    .endr

    .set pi4_art_r, 0
    .rept 6
        .set pi4_art_g, 0
        .rept 6
            .set pi4_art_b, 0
            .rept 6
                .byte pi4_art_r * 51, pi4_art_g * 51, pi4_art_b * 51
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
.global pi4_launcher_doom_label_bitmap
pi4_launcher_doom_label_bitmap:
    .word 0b110011101110101
    .word 0b101010101010111
    .word 0b101010101010111
    .word 0b101010101010101
    .word 0b110011101110101

.global pi4_launcher_quake_label_bitmap
pi4_launcher_quake_label_bitmap:
    .word 0b1110101011101010111
    .word 0b1010101010101100100
    .word 0b1010101011101000111
    .word 0b1110101010101100100
    .word 0b0010111010101010111

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
