; dev_null_probe.asm - Linux i386 /dev/null FD semantics probe for vibe-os.
;
; Exercises exact /dev/null open/openat plus read/write/close behavior.
bits 32
global start

%define SYS_EXIT    1
%define SYS_READ    3
%define SYS_WRITE   4
%define SYS_OPEN    5
%define SYS_CLOSE   6
%define SYS_FSTAT64 197
%define SYS_OPENAT  295
%define AT_FDCWD    0xffffff9c
%define O_RDONLY    0x00000000
%define O_WRONLY    0x00000001
%define O_RDWR      0x00000002
%define O_CLOEXEC   0x00080000
%define S_IFMT      0x0000f000
%define S_IFCHR     0x00002000
%define STAT64_MODE 16
%define STAT64_SIZE 44

section .text
start:
    mov eax, SYS_OPENAT
    mov ebx, AT_FDCWD
    mov ecx, path_null
    mov edx, O_RDONLY | O_CLOEXEC
    xor esi, esi
    int 0x80
    test eax, eax
    js fail
    mov [fd], eax

    mov eax, SYS_READ
    mov ebx, [fd]
    mov ecx, buf
    mov edx, 8
    int 0x80
    test eax, eax
    jne fail

    mov eax, SYS_FSTAT64
    mov ebx, [fd]
    mov ecx, statbuf
    int 0x80
    test eax, eax
    jne fail
    mov eax, [statbuf + STAT64_MODE]
    and eax, S_IFMT
    cmp eax, S_IFCHR
    jne fail
    mov eax, [statbuf + STAT64_SIZE]
    test eax, eax
    jne fail

    mov eax, SYS_CLOSE
    mov ebx, [fd]
    int 0x80
    test eax, eax
    jne fail

    mov eax, SYS_OPENAT
    mov ebx, AT_FDCWD
    mov ecx, path_null
    mov edx, O_WRONLY | O_CLOEXEC
    xor esi, esi
    int 0x80
    test eax, eax
    js fail
    mov [fd], eax

    mov eax, SYS_WRITE
    mov ebx, [fd]
    mov ecx, payload
    mov edx, payload_len
    int 0x80
    cmp eax, payload_len
    jne fail

    mov eax, SYS_CLOSE
    mov ebx, [fd]
    int 0x80
    test eax, eax
    jne fail

    mov eax, SYS_OPEN
    mov ebx, path_null
    mov ecx, O_RDWR | O_CLOEXEC
    xor edx, edx
    int 0x80
    test eax, eax
    js fail
    mov [fd], eax

    mov eax, SYS_WRITE
    mov ebx, [fd]
    mov ecx, payload
    mov edx, payload_len
    int 0x80
    cmp eax, payload_len
    jne fail

    mov eax, SYS_READ
    mov ebx, [fd]
    mov ecx, buf
    mov edx, 8
    int 0x80
    test eax, eax
    jne fail

    mov eax, SYS_CLOSE
    mov ebx, [fd]
    int 0x80
    test eax, eax
    jne fail

    mov eax, SYS_WRITE
    mov ebx, 1
    mov ecx, ok_msg
    mov edx, ok_len
    int 0x80
    mov eax, SYS_EXIT
    mov ebx, 23
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
path_null: db "/dev/null", 0
payload:   db "nullsink"
payload_len equ $ - payload
ok_msg:    db "devnull ok", 10
ok_len     equ $ - ok_msg
fail_msg:  db "devnull fail", 10
fail_len   equ $ - fail_msg

section .bss
fd:      resd 1
buf:     resb 8
statbuf: resb 96
