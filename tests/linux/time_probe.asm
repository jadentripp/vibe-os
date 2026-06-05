; time_probe.asm - Linux i386 time/gettimeofday compatibility probe.
bits 32
global start

%define SYS_EXIT         1
%define SYS_WRITE        4
%define SYS_TIME        13
%define SYS_GETTIMEOFDAY 78
%define EFAULT_NEG     -14

section .text
start:
    mov eax, SYS_GETTIMEOFDAY
    mov ebx, timeval_buf
    mov ecx, timezone_buf
    int 0x80
    test eax, eax
    jne fail
    cmp dword [timeval_buf + 4], 1000000
    jae fail
    cmp dword [timezone_buf], 0
    jne fail
    cmp dword [timezone_buf + 4], 0
    jne fail

    mov eax, SYS_GETTIMEOFDAY
    xor ebx, ebx
    xor ecx, ecx
    int 0x80
    test eax, eax
    jne fail

    mov eax, SYS_TIME
    mov ebx, time_value
    int 0x80
    test eax, eax
    js fail
    cmp eax, [time_value]
    jne fail
    mov edx, [timeval_buf]
    cmp eax, edx
    jb fail
    add edx, 2
    cmp eax, edx
    ja fail

.time_ok:
    mov eax, SYS_GETTIMEOFDAY
    mov ebx, 1
    xor ecx, ecx
    int 0x80
    cmp eax, EFAULT_NEG
    jne fail

    mov eax, SYS_WRITE
    mov ebx, 1
    mov ecx, ok_msg
    mov edx, ok_len
    int 0x80
    mov eax, SYS_EXIT
    mov ebx, 32
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
ok_msg:   db "time ok", 10
ok_len    equ $ - ok_msg
fail_msg: db "time fail", 10
fail_len  equ $ - fail_msg

section .bss
timeval_buf:  resd 2
timezone_buf: resd 2
time_value:   resd 1
