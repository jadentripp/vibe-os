bits 16
org 0x7c00

STAGE2_SEG equ 0x0000
STAGE2_OFF equ 0x8000
STAGE2_LBA equ 1
STAGE2_SECTORS equ 16

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti

    mov [boot_drive], dl
    mov si, stage1_message
    call print_string

    call require_edd

    mov si, stage2_packet
    mov ah, 0x42
    mov dl, [boot_drive]
    int 0x13
    jc disk_error

    mov dl, [boot_drive]
    jmp STAGE2_SEG:STAGE2_OFF

require_edd:
    mov ah, 0x41
    mov bx, 0x55aa
    mov dl, [boot_drive]
    int 0x13
    jc disk_error
    cmp bx, 0xaa55
    jne disk_error
    test cx, 0x0001
    jz disk_error
    ret

disk_error:
    mov si, disk_error_message
    call print_string

.hang:
    hlt
    jmp .hang

print_string:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0e
    mov bh, 0x00
    mov bl, 0x07
    int 0x10
    jmp print_string

.done:
    ret

align 4
stage2_packet:
    db 0x10
    db 0x00
    dw STAGE2_SECTORS
    dw STAGE2_OFF
    dw STAGE2_SEG
    dq STAGE2_LBA

boot_drive db 0
stage1_message db "Aurora MBR: loading stage 2...", 13, 10, 0
disk_error_message db "Aurora MBR: disk read failed.", 13, 10, 0

times 446 - ($ - $$) db 0
times 64 db 0
dw 0xaa55
