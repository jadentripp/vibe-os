bits 32

global start

SYS_USER_PROBE equ 1
SYS_EXIT equ 2
SYS_EXPECT_FAULT equ 3
SYS_WRITE equ 4
SYS_SBRK equ 5
SYS_OPEN equ 6
SYS_READ equ 7
SYS_LSEEK equ 8
USER_PROBE_MAGIC equ 0x13579BDF
USER_FAULT_ADDR equ 0x00010000
PROBE_FLAG_SBRK equ 0x01
PROBE_FLAG_OPEN equ 0x02
PROBE_FLAG_READ_IWAD equ 0x04
PROBE_FLAG_LSEEK equ 0x08

start:
    mov dword [probe_flags], 0
    mov dword [buffer_ptr], 0
    mov dword [wad_fd], 0

    mov eax, SYS_SBRK
    mov ebx, 64
    int 0x80
    cmp eax, 0xffffffff
    je .report
    mov [buffer_ptr], eax
    or dword [probe_flags], PROBE_FLAG_SBRK

    mov eax, SYS_OPEN
    mov ebx, wad_path
    xor ecx, ecx
    int 0x80
    cmp eax, 0xffffffff
    je .report
    mov [wad_fd], eax
    or dword [probe_flags], PROBE_FLAG_OPEN

    mov eax, SYS_READ
    mov ebx, [wad_fd]
    mov ecx, [buffer_ptr]
    mov edx, 12
    int 0x80
    cmp eax, 12
    jne .report
    mov edi, [buffer_ptr]
    cmp dword [edi], 0x44415749
    jne .report
    or dword [probe_flags], PROBE_FLAG_READ_IWAD

    mov eax, SYS_LSEEK
    mov ebx, [wad_fd]
    mov ecx, 4
    xor edx, edx
    int 0x80
    cmp eax, 4
    jne .report
    or dword [probe_flags], PROBE_FLAG_LSEEK

.report:
    mov eax, SYS_USER_PROBE
    mov ebx, USER_PROBE_MAGIC
    mov ecx, [probe_flags]
    int 0x80

    mov eax, SYS_EXPECT_FAULT
    int 0x80

    mov eax, [USER_FAULT_ADDR]

    mov eax, SYS_EXIT
    int 0x80

.hang:
    jmp .hang

wad_path db "DOOM1.WAD", 0
align 4
probe_flags dd 0
buffer_ptr dd 0
wad_fd dd 0
