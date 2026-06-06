; eventfd_probe.asm - Linux i386 eventfd/eventfd2 probe for vibe-os.
bits 32
global start

%define SYS_EXIT     1
%define SYS_READ     3
%define SYS_WRITE    4
%define SYS_FCNTL    55
%define SYS_EVENTFD  323
%define SYS_EVENTFD2 328
%define F_GETFD      1
%define FD_CLOEXEC   1
%define EINVAL_NEG   -22
%define EFD_SEMAPHORE 0x00000001
%define EFD_NONBLOCK  0x00000800
%define EFD_CLOEXEC   0x00080000

section .text
start:
    mov eax, SYS_EVENTFD
    mov ebx, 5
    int 0x80
    test eax, eax
    js fail
    mov [efd], eax

    mov eax, SYS_READ
    mov ebx, [efd]
    mov ecx, counter
    mov edx, 8
    int 0x80
    cmp eax, 8
    jne fail
    cmp dword [counter], 5
    jne fail
    cmp dword [counter + 4], 0
    jne fail

    mov dword [counter], 7
    mov dword [counter + 4], 0
    mov eax, SYS_WRITE
    mov ebx, [efd]
    mov ecx, counter
    mov edx, 8
    int 0x80
    cmp eax, 8
    jne fail

    mov dword [counter], 0
    mov dword [counter + 4], 0
    mov eax, SYS_READ
    mov ebx, [efd]
    mov ecx, counter
    mov edx, 8
    int 0x80
    cmp eax, 8
    jne fail
    cmp dword [counter], 7
    jne fail

    mov eax, SYS_EVENTFD2
    mov ebx, 1
    mov ecx, EFD_CLOEXEC | EFD_NONBLOCK
    int 0x80
    test eax, eax
    js fail
    mov [efd2], eax

    mov eax, SYS_FCNTL
    mov ebx, [efd2]
    mov ecx, F_GETFD
    xor edx, edx
    int 0x80
    cmp eax, FD_CLOEXEC
    jne fail

    mov eax, SYS_EVENTFD2
    xor ebx, ebx
    mov ecx, EFD_SEMAPHORE
    int 0x80
    cmp eax, EINVAL_NEG
    jne fail

    mov eax, SYS_WRITE
    mov ebx, 1
    mov ecx, ok_msg
    mov edx, ok_len
    int 0x80
    mov eax, SYS_EXIT
    mov ebx, 27
    int 0x80

fail:
    mov eax, SYS_WRITE
    mov ebx, 1
    mov ecx, fail_msg
    mov edx, fail_len
    int 0x80
    mov eax, SYS_EXIT
    mov ebx, 1
    int 0x80

section .data
ok_msg:   db "eventfd ok", 10
ok_len    equ $ - ok_msg
fail_msg: db "eventfd fail", 10
fail_len  equ $ - fail_msg

section .bss
efd:     resd 1
efd2:    resd 1
counter: resd 2
