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
	.global pi4_launcher_doom_label_bitmap
	pi4_launcher_doom_label_bitmap:
	    .word 0b11110001110001110010001
	    .word 0b10001010001010001011011
	    .word 0b10001010001010001010101
	    .word 0b10001010001010001010101
	    .word 0b10001010001010001010001
	    .word 0b10001010001010001010001
	    .word 0b11110001110001110010001

	.global pi4_launcher_quake_label_bitmap
	pi4_launcher_quake_label_bitmap:
	    .word 0b01110010001001110010001011111
	    .word 0b10001010001010001010010010000
	    .word 0b10001010001010001010100010000
	    .word 0b10001010001011111011000011110
	    .word 0b10101010001010001010100010000
	    .word 0b10010010001010001010010010000
	    .word 0b01101001110010001010001011111

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
