; fd_probe.asm - Linux i386 FD plumbing probe for vibe-os.
;
; Exercises dup/dup2/dup3 and fcntl/fcntl64 on a real FAT-backed file.
bits 32
global start

%define SYS_EXIT    1
%define SYS_READ    3
%define SYS_WRITE   4
%define SYS_CLOSE   6
%define SYS_DUP     41
%define SYS_FCNTL   55
%define SYS_DUP2    63
%define SYS_FCNTL64 221
%define SYS_OPENAT  295
%define SYS_DUP3    330
%define AT_FDCWD    0xffffff9c
%define F_DUPFD     0
%define F_GETFD     1
%define F_SETFD     2
%define F_GETFL     3
%define F_SETFL     4
%define FD_CLOEXEC  1
%define O_APPEND    0x00000400
%define O_CLOEXEC   0x00080000

section .text
start:
    mov eax, SYS_OPENAT
    mov ebx, AT_FDCWD
    mov ecx, path_self
    xor edx, edx
    xor esi, esi
    int 0x80
    test eax, eax
    js fail
    mov [fd0], eax

    mov eax, SYS_READ
    mov ebx, [fd0]
    mov ecx, buf
    mov edx, 4
    int 0x80
    cmp eax, 4
    jne fail
    cmp dword [buf], 0x464c457f
    jne fail

    mov eax, SYS_DUP
    mov ebx, [fd0]
    int 0x80
    test eax, eax
    js fail
    mov [fd1], eax

    mov eax, SYS_READ
    mov ebx, [fd1]
    mov ecx, buf
    mov edx, 1
    int 0x80
    cmp eax, 1
    jne fail
    cmp byte [buf], 1
    jne fail

    mov eax, SYS_FCNTL
    mov ebx, [fd1]
    mov ecx, F_GETFD
    xor edx, edx
    int 0x80
    test eax, eax
    jne fail

    mov eax, SYS_FCNTL
    mov ebx, [fd1]
    mov ecx, F_SETFD
    mov edx, FD_CLOEXEC
    int 0x80
    test eax, eax
    jne fail

    mov eax, SYS_FCNTL
    mov ebx, [fd1]
    mov ecx, F_GETFD
    xor edx, edx
    int 0x80
    cmp eax, FD_CLOEXEC
    jne fail

    mov eax, SYS_DUP2
    mov ebx, [fd1]
    mov ecx, 8
    int 0x80
    cmp eax, 8
    jne fail
    mov [fd2], eax

    mov eax, SYS_CLOSE
    mov ebx, [fd1]
    int 0x80

    mov eax, SYS_READ
    mov ebx, [fd2]
    mov ecx, buf
    mov edx, 1
    int 0x80
    cmp eax, 1
    jne fail
    cmp byte [buf], 1
    jne fail

    mov eax, SYS_DUP3
    mov ebx, [fd2]
    mov ecx, 9
    mov edx, O_CLOEXEC
    int 0x80
    cmp eax, 9
    jne fail
    mov [fd3], eax

    mov eax, SYS_FCNTL64
    mov ebx, [fd3]
    mov ecx, F_GETFD
    xor edx, edx
    int 0x80
    cmp eax, FD_CLOEXEC
    jne fail

    mov eax, SYS_FCNTL
    mov ebx, [fd3]
    mov ecx, F_DUPFD
    mov edx, 10
    int 0x80
    cmp eax, 10
    jb fail
    mov [fd4], eax

    mov eax, SYS_FCNTL
    mov ebx, [fd4]
    mov ecx, F_GETFD
    xor edx, edx
    int 0x80
    test eax, eax
    jne fail

    mov eax, SYS_FCNTL
    mov ebx, [fd4]
    mov ecx, F_GETFL
    xor edx, edx
    int 0x80
    test eax, eax
    js fail

    mov eax, SYS_FCNTL
    mov ebx, [fd4]
    mov ecx, F_SETFL
    mov edx, O_APPEND
    int 0x80
    test eax, eax
    jne fail

    mov eax, SYS_FCNTL
    mov ebx, [fd4]
    mov ecx, F_GETFL
    xor edx, edx
    int 0x80
    test eax, O_APPEND
    jz fail

    mov eax, SYS_WRITE
    mov ebx, 1
    mov ecx, ok_msg
    mov edx, ok_len
    int 0x80
    mov eax, SYS_EXIT
    mov ebx, 17
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
path_self: db "/BIN/FD.ELF", 0
ok_msg:   db "fd ok", 10
ok_len    equ $ - ok_msg
fail_msg: db "fd fail", 10
fail_len  equ $ - fail_msg

section .bss
fd0: resd 1
fd1: resd 1
fd2: resd 1
fd3: resd 1
fd4: resd 1
buf: resb 8
