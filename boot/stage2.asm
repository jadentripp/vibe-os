bits 16
org 0x8000

KERNEL_SEG equ 0x1000
KERNEL_OFF equ 0x0000
KERNEL_PHYS equ 0x00010000
KERNEL_ELF_SEG equ 0x4000
KERNEL_ELF_OFF equ 0x0000
KERNEL_ELF_PHYS equ 0x00040000
KERNEL_LBA equ 17
KERNEL_SECTORS equ 256
KERNEL_READ_CHUNK_SECTORS equ 64

ELF_MAGIC equ 0x464c457f
ELFCLASS32 equ 1
ELFDATA2LSB equ 1
ET_EXEC equ 2
EM_386 equ 3
PT_LOAD equ 1

BOOT_INFO_ADDR equ 0x7000
BOOT_VIDEO_MAGIC equ 0x45444956
BOOT_VIDEO_MODE equ BOOT_INFO_ADDR + 12
BOOT_VIDEO_FLAGS equ BOOT_INFO_ADDR + 14
BOOT_VIDEO_FB_ADDR equ BOOT_INFO_ADDR + 16
BOOT_VIDEO_PITCH equ BOOT_INFO_ADDR + 20
BOOT_VIDEO_WIDTH equ BOOT_INFO_ADDR + 24
BOOT_VIDEO_HEIGHT equ BOOT_INFO_ADDR + 26
BOOT_VIDEO_BPP equ BOOT_INFO_ADDR + 28
BOOT_VIDEO_MEMORY_MODEL equ BOOT_INFO_ADDR + 29
BOOT_VIDEO_RED_MASK equ BOOT_INFO_ADDR + 30
BOOT_VIDEO_RED_POS equ BOOT_INFO_ADDR + 31
BOOT_VIDEO_GREEN_MASK equ BOOT_INFO_ADDR + 32
BOOT_VIDEO_GREEN_POS equ BOOT_INFO_ADDR + 33
BOOT_VIDEO_BLUE_MASK equ BOOT_INFO_ADDR + 34
BOOT_VIDEO_BLUE_POS equ BOOT_INFO_ADDR + 35
BOOT_VIDEO_FLAG_VBE equ 0x0001
BOOT_VIDEO_FLAG_LFB equ 0x0002
BOOT_VIDEO_FLAG_XRGB8888 equ 0x0004
VBE_INFO_ADDR equ 0x6000
VBE_MODE_INFO_ADDR equ 0x6200
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti

    mov [boot_drive], dl
    mov si, stage2_message
    call print_string

    int 0x12
    mov [BOOT_INFO_ADDR], ax

    mov ah, 0x88
    int 0x15
    jc .skip_ext_mem
    mov [BOOT_INFO_ADDR + 4], ax

.skip_ext_mem:
    mov al, [boot_drive]
    mov [BOOT_INFO_ADDR + 2], al

    call require_edd

    call load_kernel_elf_sectors

    call set_vbe_lfb_or_mode13
    call enable_a20

    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 0x00000001
    mov cr0, eax
    jmp CODE_SEG:protected_entry

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

load_kernel_elf_sectors:
    mov word [kernel_load_remaining], KERNEL_SECTORS
    mov word [kernel_load_segment], KERNEL_ELF_SEG
    mov dword [kernel_load_lba], KERNEL_LBA
    mov dword [kernel_load_lba + 4], 0

.next:
    cmp word [kernel_load_remaining], 0
    je .done

    mov ax, [kernel_load_remaining]
    cmp ax, KERNEL_READ_CHUNK_SECTORS
    jbe .count_ready
    mov ax, KERNEL_READ_CHUNK_SECTORS

.count_ready:
    mov [kernel_packet_sectors], ax
    mov word [kernel_packet_offset], KERNEL_ELF_OFF
    mov ax, [kernel_load_segment]
    mov [kernel_packet_segment], ax
    mov eax, [kernel_load_lba]
    mov [kernel_packet_lba], eax
    mov eax, [kernel_load_lba + 4]
    mov [kernel_packet_lba + 4], eax

    mov si, kernel_packet
    mov ah, 0x42
    mov dl, [boot_drive]
    int 0x13
    jc disk_error

    mov ax, [kernel_packet_sectors]
    sub [kernel_load_remaining], ax
    push ax
    shl ax, 5
    add [kernel_load_segment], ax
    pop ax
    xor ebx, ebx
    mov bx, ax
    add [kernel_load_lba], ebx
    adc dword [kernel_load_lba + 4], 0
    jmp .next

.done:
    ret

enable_a20:
    in al, 0x92
    or al, 0x02
    and al, 0xfe
    out 0x92, al
    ret

set_vbe_lfb_or_mode13:
    call try_set_vbe_lfb
    jnc .done
    call set_video_mode13

.done:
    ret

try_set_vbe_lfb:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push es
    push fs

    mov dword [VBE_INFO_ADDR], 0x32454256
    mov ax, 0x4f00
    xor bx, bx
    mov es, bx
    mov di, VBE_INFO_ADDR
    int 0x10
    cmp ax, 0x004f
    jne .fail

    mov si, [VBE_INFO_ADDR + 0x0e]
    mov ax, [VBE_INFO_ADDR + 0x10]
    test ax, ax
    jz .fail
    mov fs, ax

.mode_loop:
    mov cx, [fs:si]
    add si, 2
    cmp cx, 0xffff
    je .fail
    mov [vbe_candidate_mode], cx

    push esi
    push fs
    mov ax, 0x4f01
    xor bx, bx
    mov es, bx
    mov di, VBE_MODE_INFO_ADDR
    int 0x10
    pop fs
    pop esi
    cmp ax, 0x004f
    jne .mode_loop

    mov ax, [VBE_MODE_INFO_ADDR]
    and ax, 0x0091
    cmp ax, 0x0091
    jne .mode_loop
    cmp word [VBE_MODE_INFO_ADDR + 18], 640
    jne .mode_loop
    cmp word [VBE_MODE_INFO_ADDR + 20], 400
    jb .mode_loop
    cmp byte [VBE_MODE_INFO_ADDR + 25], 32
    jne .mode_loop
    cmp byte [VBE_MODE_INFO_ADDR + 27], 6
    jne .mode_loop
    cmp dword [VBE_MODE_INFO_ADDR + 40], 0
    je .mode_loop
    cmp byte [VBE_MODE_INFO_ADDR + 31], 8
    jb .mode_loop
    cmp byte [VBE_MODE_INFO_ADDR + 32], 16
    jne .mode_loop
    cmp byte [VBE_MODE_INFO_ADDR + 33], 8
    jb .mode_loop
    cmp byte [VBE_MODE_INFO_ADDR + 34], 8
    jne .mode_loop
    cmp byte [VBE_MODE_INFO_ADDR + 35], 8
    jb .mode_loop
    cmp byte [VBE_MODE_INFO_ADDR + 36], 0
    jne .mode_loop

    mov ax, 0x4f02
    mov bx, [vbe_candidate_mode]
    or bx, 0x4000
    int 0x10
    cmp ax, 0x004f
    jne .mode_loop

    call store_vbe_video_info
    clc
    jmp .done

.fail:
    stc

.done:
    pop fs
    pop es
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

store_vbe_video_info:
    mov dword [BOOT_INFO_ADDR + 8], BOOT_VIDEO_MAGIC
    mov ax, [vbe_candidate_mode]
    mov [BOOT_VIDEO_MODE], ax
    mov word [BOOT_VIDEO_FLAGS], BOOT_VIDEO_FLAG_VBE | BOOT_VIDEO_FLAG_LFB | BOOT_VIDEO_FLAG_XRGB8888
    mov eax, [VBE_MODE_INFO_ADDR + 40]
    mov [BOOT_VIDEO_FB_ADDR], eax
    xor eax, eax
    mov ax, [VBE_MODE_INFO_ADDR + 16]
    mov [BOOT_VIDEO_PITCH], eax
    mov ax, [VBE_MODE_INFO_ADDR + 18]
    mov [BOOT_VIDEO_WIDTH], ax
    mov ax, [VBE_MODE_INFO_ADDR + 20]
    mov [BOOT_VIDEO_HEIGHT], ax
    mov al, [VBE_MODE_INFO_ADDR + 25]
    mov [BOOT_VIDEO_BPP], al
    mov al, [VBE_MODE_INFO_ADDR + 27]
    mov [BOOT_VIDEO_MEMORY_MODEL], al
    mov al, [VBE_MODE_INFO_ADDR + 31]
    mov [BOOT_VIDEO_RED_MASK], al
    mov al, [VBE_MODE_INFO_ADDR + 32]
    mov [BOOT_VIDEO_RED_POS], al
    mov al, [VBE_MODE_INFO_ADDR + 33]
    mov [BOOT_VIDEO_GREEN_MASK], al
    mov al, [VBE_MODE_INFO_ADDR + 34]
    mov [BOOT_VIDEO_GREEN_POS], al
    mov al, [VBE_MODE_INFO_ADDR + 35]
    mov [BOOT_VIDEO_BLUE_MASK], al
    mov al, [VBE_MODE_INFO_ADDR + 36]
    mov [BOOT_VIDEO_BLUE_POS], al
    ret

set_video_mode13:
    mov ax, 0x0013
    int 0x10
    mov dword [BOOT_INFO_ADDR + 8], BOOT_VIDEO_MAGIC
    mov word [BOOT_VIDEO_MODE], 0x0013
    mov word [BOOT_VIDEO_FLAGS], 0
    mov dword [BOOT_VIDEO_FB_ADDR], 0x000a0000
    mov dword [BOOT_VIDEO_PITCH], 320
    mov word [BOOT_VIDEO_WIDTH], 320
    mov word [BOOT_VIDEO_HEIGHT], 200
    mov byte [BOOT_VIDEO_BPP], 8
    mov byte [BOOT_VIDEO_MEMORY_MODEL], 4
    mov byte [BOOT_VIDEO_RED_MASK], 0
    mov byte [BOOT_VIDEO_RED_POS], 0
    mov byte [BOOT_VIDEO_GREEN_MASK], 0
    mov byte [BOOT_VIDEO_GREEN_POS], 0
    mov byte [BOOT_VIDEO_BLUE_MASK], 0
    mov byte [BOOT_VIDEO_BLUE_POS], 0
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

bits 32
protected_entry:
    cli
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x70000
    call elf_load_kernel
    jmp eax

elf_load_kernel:
    mov esi, KERNEL_ELF_PHYS
    cmp dword [esi], ELF_MAGIC
    jne elf_fail
    cmp byte [esi + 4], ELFCLASS32
    jne elf_fail
    cmp byte [esi + 5], ELFDATA2LSB
    jne elf_fail
    cmp word [esi + 16], ET_EXEC
    jne elf_fail
    cmp word [esi + 18], EM_386
    jne elf_fail
    cmp word [esi + 42], 32
    jne elf_fail

    mov ebx, [esi + 28]
    add ebx, esi
    movzx ecx, word [esi + 44]
    test ecx, ecx
    jz elf_fail
    xor ebp, ebp

.program_header:
    cmp dword [ebx], PT_LOAD
    jne .next_header

    mov edi, [ebx + 12]
    test edi, edi
    jnz .has_destination
    mov edi, [ebx + 8]

.has_destination:
    test edi, edi
    jz elf_fail
    mov edx, [ebx + 16]
    mov eax, [ebx + 20]
    cmp eax, edx
    jb elf_fail

    push ecx
    push ebx
    push eax
    push edx
    mov esi, KERNEL_ELF_PHYS
    add esi, [ebx + 4]
    mov ecx, edx
    cld
    rep movsb
    pop edx
    pop eax
    sub eax, edx
    mov ecx, eax
    xor eax, eax
    rep stosb
    pop ebx
    pop ecx
    inc ebp

.next_header:
    add ebx, 32
    dec ecx
    jnz .program_header

    test ebp, ebp
    jz elf_fail
    mov eax, [KERNEL_ELF_PHYS + 24]
    test eax, eax
    jz elf_fail
    ret

elf_fail:
    mov esi, elf_error_message
    call pm_print_string

.hang:
    hlt
    jmp .hang

pm_print_string:
    mov edi, 0x000b8000 + (4 * 80 * 2)

.next_char:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0c
    mov [edi], ax
    add edi, 2
    jmp .next_char

.done:
    ret

bits 16
align 4
kernel_packet:
    db 0x10
    db 0x00
kernel_packet_sectors:
    dw 0
kernel_packet_offset:
    dw KERNEL_ELF_OFF
kernel_packet_segment:
    dw KERNEL_ELF_SEG
kernel_packet_lba:
    dq 0
kernel_load_remaining dw 0
kernel_load_segment dw 0
align 4
kernel_load_lba dq 0

gdt_start:
gdt_null:
    dq 0

gdt_code:
    dw 0xffff
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00

gdt_data:
    dw 0xffff
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

boot_drive db 0
vbe_candidate_mode dw 0
stage2_message db "Aurora stage 2: loading protected kernel...", 13, 10, 0
disk_error_message db "Aurora stage 2: disk read failed.", 13, 10, 0
elf_error_message db "Aurora stage 2: ELF load failed.", 0
