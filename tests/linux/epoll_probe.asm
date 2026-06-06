; epoll_probe.asm - Linux i386 epoll/eventfd readiness probe for vibe-os.
bits 32
global start

%define SYS_EXIT          1
%define SYS_WRITE         4
%define SYS_EPOLL_CREATE  254
%define SYS_EPOLL_CTL     255
%define SYS_EPOLL_WAIT    256
%define SYS_EVENTFD2      328
%define SYS_EPOLL_CREATE1 329
%define EPOLL_CTL_ADD     1
%define EPOLL_CTL_DEL     2
%define EPOLL_CTL_MOD     3
%define EPOLLIN           0x00000001
%define EPOLLOUT          0x00000004
%define EFD_NONBLOCK      0x00000800
%define EPOLL_CLOEXEC     0x00080000

section .text
start:
    mov eax, SYS_EPOLL_CREATE
    mov ebx, 1
    int 0x80
    test eax, eax
    js fail
    mov [epfd], eax

    mov eax, SYS_EVENTFD2
    xor ebx, ebx
    mov ecx, EFD_NONBLOCK
    int 0x80
    test eax, eax
    js fail
    mov [efd], eax

    mov dword [ev], EPOLLIN
    mov dword [ev + 4], 0x12345678
    mov dword [ev + 8], 0
    mov eax, SYS_EPOLL_CTL
    mov ebx, [epfd]
    mov ecx, EPOLL_CTL_ADD
    mov edx, [efd]
    mov esi, ev
    int 0x80
    test eax, eax
    js fail

    mov eax, SYS_EPOLL_WAIT
    mov ebx, [epfd]
    mov ecx, out_ev
    mov edx, 1
    xor esi, esi
    int 0x80
    cmp eax, 0
    jne fail

    mov dword [counter], 1
    mov dword [counter + 4], 0
    mov eax, SYS_WRITE
    mov ebx, [efd]
    mov ecx, counter
    mov edx, 8
    int 0x80
    cmp eax, 8
    jne fail

    mov eax, SYS_EPOLL_WAIT
    mov ebx, [epfd]
    mov ecx, out_ev
    mov edx, 1
    xor esi, esi
    int 0x80
    cmp eax, 1
    jne fail
    test dword [out_ev], EPOLLIN
    jz fail
    cmp dword [out_ev + 4], 0x12345678
    jne fail

    mov dword [ev], EPOLLOUT
    mov dword [ev + 4], 0x87654321
    mov dword [ev + 8], 0
    mov eax, SYS_EPOLL_CTL
    mov ebx, [epfd]
    mov ecx, EPOLL_CTL_MOD
    mov edx, [efd]
    mov esi, ev
    int 0x80
    test eax, eax
    js fail

    mov eax, SYS_EPOLL_WAIT
    mov ebx, [epfd]
    mov ecx, out_ev
    mov edx, 1
    xor esi, esi
    int 0x80
    cmp eax, 1
    jne fail
    test dword [out_ev], EPOLLOUT
    jz fail
    cmp dword [out_ev + 4], 0x87654321
    jne fail

    mov eax, SYS_EPOLL_CTL
    mov ebx, [epfd]
    mov ecx, EPOLL_CTL_DEL
    mov edx, [efd]
    xor esi, esi
    int 0x80
    test eax, eax
    js fail

    mov eax, SYS_EPOLL_CREATE1
    mov ebx, EPOLL_CLOEXEC
    int 0x80
    test eax, eax
    js fail

    mov eax, SYS_WRITE
    mov ebx, 1
    mov ecx, ok_msg
    mov edx, ok_len
    int 0x80
    mov eax, SYS_EXIT
    mov ebx, 29
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
ok_msg:   db "epoll ok", 10
ok_len    equ $ - ok_msg
fail_msg: db "epoll fail", 10
fail_len  equ $ - fail_msg

section .bss
epfd:    resd 1
efd:     resd 1
counter: resd 2
ev:      resb 12
out_ev:  resb 12
