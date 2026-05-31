; startup_probe.asm - exercise the Linux i386 static-libc startup syscall batch.
bits 32
global start

LINUX_SYS_EXIT_GROUP equ 252
LINUX_SYS_WRITE equ 4
LINUX_SYS_BRK equ 45
LINUX_SYS_IOCTL equ 54
LINUX_SYS_READLINK equ 85
LINUX_SYS_MUNMAP equ 91
LINUX_SYS_MPROTECT equ 125
LINUX_SYS_RT_SIGPROCMASK equ 175
LINUX_SYS_MMAP2 equ 192
LINUX_SYS_SET_TID_ADDRESS equ 258
LINUX_SYS_GETRANDOM equ 355

PROT_READ equ 1
PROT_WRITE equ 2
MAP_PRIVATE equ 2
MAP_ANONYMOUS equ 0x20
TCGETS equ 0x5401
ENOTTY_NEG equ -25
STARTUP_MAGIC equ 0x53544152

section .text
start:
    mov eax, LINUX_SYS_BRK
    xor ebx, ebx
    int 0x80
    test eax, eax
    jz .fail
    mov [brk_base], eax

    mov ebx, eax
    add ebx, 16
    mov eax, LINUX_SYS_BRK
    int 0x80
    cmp eax, ebx
    jne .fail
    mov edi, [brk_base]
    mov dword [edi], STARTUP_MAGIC

    mov eax, LINUX_SYS_BRK
    mov ebx, [brk_base]
    int 0x80
    cmp eax, [brk_base]
    jne .fail

    mov eax, LINUX_SYS_SET_TID_ADDRESS
    mov ebx, tid_value
    int 0x80
    test eax, 0x80000000
    jnz .fail

    mov eax, LINUX_SYS_MMAP2
    xor ebx, ebx
    mov ecx, 4096
    mov edx, PROT_READ | PROT_WRITE
    mov esi, MAP_PRIVATE | MAP_ANONYMOUS
    mov edi, 0xffffffff
    xor ebp, ebp
    int 0x80
    test eax, 0x80000000
    jnz .fail
    mov [map_addr], eax
    mov dword [eax], STARTUP_MAGIC

    mov eax, LINUX_SYS_MPROTECT
    mov ebx, [map_addr]
    mov ecx, 4096
    mov edx, PROT_READ
    int 0x80
    test eax, eax
    jnz .fail

    mov eax, LINUX_SYS_IOCTL
    mov ebx, 1
    mov ecx, TCGETS
    mov edx, termios_buf
    int 0x80
    cmp eax, ENOTTY_NEG
    jne .fail

    mov eax, LINUX_SYS_GETRANDOM
    mov ebx, random_buf
    mov ecx, 16
    xor edx, edx
    int 0x80
    cmp eax, 16
    jne .fail

    mov eax, LINUX_SYS_RT_SIGPROCMASK
    xor ebx, ebx
    xor ecx, ecx
    mov edx, sigmask_buf
    mov esi, 8
    int 0x80
    test eax, eax
    jnz .fail

    mov eax, LINUX_SYS_READLINK
    mov ebx, proc_self_exe
    mov ecx, link_buf
    mov edx, 64
    int 0x80
    test eax, 0x80000000
    jnz .fail
    test eax, eax
    jz .fail
    cmp byte [link_buf], '/'
    jne .fail

    mov eax, LINUX_SYS_MUNMAP
    mov ebx, [map_addr]
    mov ecx, 4096
    int 0x80
    test eax, eax
    jnz .fail

    mov eax, LINUX_SYS_WRITE
    mov ebx, 1
    mov ecx, ok_msg
    mov edx, ok_len
    int 0x80
    mov eax, LINUX_SYS_EXIT_GROUP
    mov ebx, 7
    int 0x80

.fail:
    mov eax, LINUX_SYS_WRITE
    mov ebx, 1
    mov ecx, fail_msg
    mov edx, fail_len
    int 0x80
    mov eax, LINUX_SYS_EXIT_GROUP
    mov ebx, 1
    int 0x80
.hang:
    jmp .hang

section .data
proc_self_exe: db "/proc/self/exe", 0
ok_msg: db "startup ok", 10
ok_len equ $ - ok_msg
fail_msg: db "startup fail", 10
fail_len equ $ - fail_msg

section .bss
brk_base: resd 1
map_addr: resd 1
tid_value: resd 1
sigmask_buf: resb 8
random_buf: resb 16
termios_buf: resb 64
link_buf: resb 64
