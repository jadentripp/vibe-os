; timerfd_probe.asm - Linux i386 timerfd create/set/get/read probe for vibe-os.
bits 32
global start

%define SYS_EXIT           1
%define SYS_READ           3
%define SYS_WRITE          4
%define SYS_FCNTL          55
%define SYS_TIMERFD_CREATE 322
%define SYS_TIMERFD_SETTIME 325
%define SYS_TIMERFD_GETTIME 326
%define CLOCK_MONOTONIC    1
%define F_GETFD            1
%define FD_CLOEXEC         1
%define TFD_NONBLOCK       0x00000800
%define TFD_CLOEXEC        0x00080000

section .text
start:
    mov eax, SYS_TIMERFD_CREATE
    mov ebx, CLOCK_MONOTONIC
    mov ecx, TFD_CLOEXEC | TFD_NONBLOCK
    int 0x80
    test eax, eax
    js fail
    mov [tfd], eax

    mov eax, SYS_FCNTL
    mov ebx, [tfd]
    mov ecx, F_GETFD
    xor edx, edx
    int 0x80
    cmp eax, FD_CLOEXEC
    jne fail

    mov eax, SYS_TIMERFD_GETTIME
    mov ebx, [tfd]
    mov ecx, old_time
    int 0x80
    test eax, eax
    js fail
    cmp dword [old_time], 0
    jne fail
    cmp dword [old_time + 8], 0
    jne fail

    mov dword [new_time], 0
    mov dword [new_time + 4], 0
    mov dword [new_time + 8], 1
    mov dword [new_time + 12], 0
    mov eax, SYS_TIMERFD_SETTIME
    mov ebx, [tfd]
    xor ecx, ecx
    mov edx, new_time
    mov esi, old_time
    int 0x80
    test eax, eax
    js fail

    mov eax, SYS_READ
    mov ebx, [tfd]
    mov ecx, expirations
    mov edx, 8
    int 0x80
    cmp eax, 8
    jne fail
    cmp dword [expirations], 1
    jne fail
    cmp dword [expirations + 4], 0
    jne fail

    mov eax, SYS_TIMERFD_SETTIME
    mov ebx, [tfd]
    xor ecx, ecx
    mov edx, zero_time
    xor esi, esi
    int 0x80
    test eax, eax
    js fail

    mov eax, SYS_WRITE
    mov ebx, 1
    mov ecx, ok_msg
    mov edx, ok_len
    int 0x80
    mov eax, SYS_EXIT
    mov ebx, 31
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
ok_msg:   db "timerfd ok", 10
ok_len    equ $ - ok_msg
fail_msg: db "timerfd fail", 10
fail_len  equ $ - fail_msg

section .bss
tfd:         resd 1
new_time:    resd 4
old_time:    resd 4
zero_time:   resd 4
expirations: resd 2
