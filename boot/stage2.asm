bits 16
org 0x8000

KERNEL_SEG equ 0x1000
KERNEL_OFF equ 0x0000
KERNEL_PHYS equ 0x00010000
KERNEL_ELF_SEG equ 0x2000
KERNEL_ELF_OFF equ 0x0000
KERNEL_ELF_PHYS equ 0x00020000
KERNEL_LBA equ 17
KERNEL_SECTORS equ 96

ELF_MAGIC equ 0x464c457f
ELFCLASS32 equ 1
ELFDATA2LSB equ 1
ET_EXEC equ 2
EM_386 equ 3
PT_LOAD equ 1

BOOT_INFO_ADDR equ 0x7000
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

    mov si, kernel_packet
    mov ah, 0x42
    mov dl, [boot_drive]
    int 0x13
    jc disk_error

    call set_video_mode13
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

enable_a20:
    in al, 0x92
    or al, 0x02
    and al, 0xfe
    out 0x92, al
    ret

set_video_mode13:
    mov ax, 0x0013
    int 0x10
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
    dw KERNEL_SECTORS
    dw KERNEL_ELF_OFF
    dw KERNEL_ELF_SEG
    dq KERNEL_LBA

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
stage2_message db "Aurora stage 2: loading protected kernel...", 13, 10, 0
disk_error_message db "Aurora stage 2: disk read failed.", 13, 10, 0
elf_error_message db "Aurora stage 2: ELF load failed.", 0
