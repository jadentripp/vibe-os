bits 16
org 0x7c00

STAGE2_SEG equ 0x0000
STAGE2_OFF equ 0x8000
STAGE2_LBA equ 1
STAGE2_SECTORS equ 16
DISK_RETRIES equ 3
STAGE1_ERR_CHS_GEOMETRY equ 0xc1
STAGE1_ERR_CHS_RANGE equ 0xc2
STAGE1_ERR_CHS_READ equ 0xc3

start:
    jmp 0x0000:stage1_entry

stage1_entry:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti
    cld

    mov [boot_drive], dl
    mov si, stage1_message
    call print_string

    call require_edd
    call read_stage2

    mov dl, [boot_drive]
    jmp STAGE2_SEG:STAGE2_OFF

require_edd:
    mov byte [disk_use_edd], 0
    mov ah, 0x41
    mov bx, 0x55aa
    mov dl, [boot_drive]
    int 0x13
    jc .done
    cmp bx, 0xaa55
    jne .done
    test cx, 0x0001
    jz .done
    mov byte [disk_use_edd], 1

.done:
    ret

read_stage2:
    cmp byte [disk_use_edd], 1
    jne read_stage2_chs
    mov byte [disk_retries_left], DISK_RETRIES

.try:
    mov word [stage2_packet_sectors], STAGE2_SECTORS
    mov si, stage2_packet
    mov ah, 0x42
    mov dl, [boot_drive]
    int 0x13
    jc .retry_or_fallback
    cmp word [stage2_packet_sectors], STAGE2_SECTORS
    je .done

.retry_or_fallback:
    xor ah, ah
    mov dl, [boot_drive]
    int 0x13
    dec byte [disk_retries_left]
    jnz .try
    jmp read_stage2_chs

.done:
    ret

read_stage2_chs:
    call ensure_chs_geometry
    mov word [chs_current_lba], STAGE2_LBA
    mov word [chs_buffer_segment], STAGE2_SEG
    mov word [chs_buffer_offset], STAGE2_OFF
    mov word [chs_read_remaining], STAGE2_SECTORS

.next_sector:
    cmp word [chs_read_remaining], 0
    je .done
    call read_one_sector_chs
    inc word [chs_current_lba]
    add word [chs_buffer_offset], 512
    dec word [chs_read_remaining]
    jmp .next_sector

.done:
    ret

ensure_chs_geometry:
    cmp byte [chs_geometry_ready], 1
    je .done
    mov ah, 0x08
    mov dl, [boot_drive]
    int 0x13
    jc .error
    and cl, 0x3f
    jz .error
    xor ax, ax
    mov al, cl
    mov [chs_sectors_per_track], ax
    xor ax, ax
    mov al, dh
    inc ax
    mov [chs_heads], ax
    mov byte [chs_geometry_ready], 1

.done:
    ret

.error:
    mov al, STAGE1_ERR_CHS_GEOMETRY
    jmp disk_error

read_one_sector_chs:
    mov byte [disk_retries_left], DISK_RETRIES

.try:
    mov ax, [chs_current_lba]
    xor dx, dx
    div word [chs_sectors_per_track]
    mov bl, dl
    inc bl
    xor dx, dx
    div word [chs_heads]
    cmp ax, 1023
    ja .range_error
    mov ch, al
    mov cl, bl
    mov bl, ah
    and bl, 0x03
    shl bl, 6
    or cl, bl
    mov dh, dl
    mov ax, [chs_buffer_segment]
    mov es, ax
    mov bx, [chs_buffer_offset]
    mov ax, 0x0201
    mov dl, [boot_drive]
    int 0x13
    jnc .done

    xor ah, ah
    mov dl, [boot_drive]
    int 0x13
    dec byte [disk_retries_left]
    jnz .try
    mov al, STAGE1_ERR_CHS_READ
    jmp disk_error

.done:
    ret

.range_error:
    mov al, STAGE1_ERR_CHS_RANGE
    jmp disk_error

disk_error:
    push ax
    mov si, disk_error_message
    call print_string
    pop ax
    call print_hex8

.hang:
    hlt
    jmp .hang

print_hex8:
    push ax
    shr al, 4
    call print_hex_nibble
    pop ax
    and al, 0x0f

print_hex_nibble:
    add al, "0"
    cmp al, "9"
    jbe .emit
    add al, 7

.emit:
    mov ah, 0x0e
    mov bx, 0x0007
    int 0x10
    ret

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
stage2_packet_sectors:
    dw STAGE2_SECTORS
    dw STAGE2_OFF
    dw STAGE2_SEG
    dq STAGE2_LBA

boot_drive db 0
disk_use_edd db 0
disk_retries_left db 0
chs_geometry_ready db 0
chs_sectors_per_track dw 0
chs_heads dw 0
chs_current_lba dw 0
chs_buffer_segment dw 0
chs_buffer_offset dw 0
chs_read_remaining dw 0
stage1_message db "vibe MBR", 13, 10, 0
disk_error_message db "MBR disk error ", 0

times 446 - ($ - $$) db 0
times 64 db 0
dw 0xaa55
