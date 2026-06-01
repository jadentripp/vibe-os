; rseq_probe.asm - Linux i386 rseq registration seed probe for vibe-os.
bits 32
global start

%define SYS_EXIT_GROUP        252
%define SYS_WRITE               4
%define SYS_RSEQ              386

%define RSEQ_LEN             0x20
%define RSEQ_SIG       0x53053053
%define RSEQ_FLAG_UNREGISTER   1
%define EFAULT_NEG           -14
%define EBUSY_NEG            -16
%define EINVAL_NEG           -22

section .text
start:
    mov eax, SYS_RSEQ
    mov ebx, rseq_area
    mov ecx, RSEQ_LEN - 4
    xor edx, edx
    mov esi, RSEQ_SIG
    xor edi, edi
    xor ebp, ebp
    int 0x80
    cmp eax, EINVAL_NEG
    jne fail

    mov eax, SYS_RSEQ
    mov ebx, 1
    mov ecx, RSEQ_LEN
    xor edx, edx
    mov esi, RSEQ_SIG
    xor edi, edi
    xor ebp, ebp
    int 0x80
    cmp eax, EFAULT_NEG
    jne fail

    mov eax, SYS_RSEQ
    mov ebx, rseq_area
    mov ecx, RSEQ_LEN
    mov edx, 2
    mov esi, RSEQ_SIG
    xor edi, edi
    xor ebp, ebp
    int 0x80
    cmp eax, EINVAL_NEG
    jne fail

    mov dword [rseq_area], 0xffffffff
    mov dword [rseq_area + 4], 0xffffffff
    mov dword [rseq_area + 8], 0x11223344
    mov dword [rseq_area + 12], 0x55667788
    mov dword [rseq_area + 16], 0x99aabbcc

    mov eax, SYS_RSEQ
    mov ebx, rseq_area
    mov ecx, RSEQ_LEN
    xor edx, edx
    mov esi, RSEQ_SIG
    xor edi, edi
    xor ebp, ebp
    int 0x80
    test eax, eax
    jne fail
    cmp dword [rseq_area], 0
    jne fail
    cmp dword [rseq_area + 4], 0
    jne fail
    cmp dword [rseq_area + 8], 0x11223344
    jne fail
    cmp dword [rseq_area + 12], 0x55667788
    jne fail
    cmp dword [rseq_area + 16], 0x99aabbcc
    jne fail

    mov eax, SYS_RSEQ
    mov ebx, rseq_area
    mov ecx, RSEQ_LEN
    xor edx, edx
    mov esi, RSEQ_SIG
    xor edi, edi
    xor ebp, ebp
    int 0x80
    cmp eax, EBUSY_NEG
    jne fail

    mov eax, SYS_RSEQ
    mov ebx, rseq_area
    mov ecx, RSEQ_LEN
    mov edx, RSEQ_FLAG_UNREGISTER
    mov esi, RSEQ_SIG
    xor edi, edi
    xor ebp, ebp
    int 0x80
    test eax, eax
    jne fail

    mov eax, SYS_RSEQ
    mov ebx, rseq_area
    mov ecx, RSEQ_LEN
    mov edx, RSEQ_FLAG_UNREGISTER
    mov esi, RSEQ_SIG
    xor edi, edi
    xor ebp, ebp
    int 0x80
    cmp eax, EINVAL_NEG
    jne fail

    mov eax, SYS_WRITE
    mov ebx, 1
    mov ecx, ok_msg
    mov edx, ok_len
    int 0x80
    mov eax, SYS_EXIT_GROUP
    mov ebx, 34
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
ok_msg: db "rseq ok", 10
ok_len equ $ - ok_msg
fail_msg: db "rseq fail", 10
fail_len equ $ - fail_msg
align 32
rseq_area: times RSEQ_LEN db 0
