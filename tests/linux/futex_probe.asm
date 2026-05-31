; futex_probe.asm - Linux i386 FUTEX_WAIT/WAKE seed probe for vibe-os.
bits 32
global start

%define SYS_EXIT_GROUP 252
%define SYS_WRITE        4
%define SYS_FUTEX      240

%define FUTEX_WAIT       0
%define FUTEX_WAKE       1
%define FUTEX_PRIVATE  128
%define EAGAIN_NEG     -11

section .text
start:
    mov dword [futex_word], 7

    mov eax, SYS_FUTEX
    mov ebx, futex_word
    mov ecx, FUTEX_WAIT | FUTEX_PRIVATE
    mov edx, 9
    xor esi, esi
    xor edi, edi
    xor ebp, ebp
    int 0x80
    cmp eax, EAGAIN_NEG
    jne fail

    mov eax, SYS_FUTEX
    mov ebx, futex_word
    mov ecx, FUTEX_WAIT | FUTEX_PRIVATE
    mov edx, 7
    xor esi, esi
    xor edi, edi
    xor ebp, ebp
    int 0x80
    test eax, eax
    jne fail

    mov eax, SYS_FUTEX
    mov ebx, futex_word
    mov ecx, FUTEX_WAKE | FUTEX_PRIVATE
    mov edx, 1
    xor esi, esi
    xor edi, edi
    xor ebp, ebp
    int 0x80
    test eax, eax
    jne fail

    mov eax, SYS_WRITE
    mov ebx, 1
    mov ecx, ok_msg
    mov edx, ok_len
    int 0x80
    mov eax, SYS_EXIT_GROUP
    mov ebx, 32
    int 0x80

fail:
    mov eax, SYS_WRITE
    mov ebx, 1
    mov ecx, fail_msg
    mov edx, fail_len
    int 0x80
    mov eax, SYS_EXIT_GROUP
    mov ebx, 1
    int 0x80

section .data
ok_msg: db "futex ok", 10
ok_len equ $ - ok_msg
fail_msg: db "futex fail", 10
fail_len equ $ - fail_msg
futex_word: dd 0
