; pipe_probe.asm - Linux i386 pipe/pipe2 probe for vibe-os.
;
; Exercises the M1a pipe seed with in-kernel read/write buffering and
; pipe2 close-on-exec descriptor flags.
bits 32
global start

%define SYS_EXIT   1
%define SYS_READ   3
%define SYS_WRITE  4
%define SYS_CLOSE  6
%define SYS_PIPE   42
%define SYS_FCNTL  55
%define SYS_PIPE2  331
%define F_GETFD    1
%define FD_CLOEXEC 1
%define O_CLOEXEC  0x00080000

section .text
start:
    mov eax, SYS_PIPE
    mov ebx, pipefd
    int 0x80
    test eax, eax
    js fail

    mov eax, SYS_WRITE
    mov ebx, [pipefd + 4]
    mov ecx, msg
    mov edx, msg_len
    int 0x80
    cmp eax, msg_len
    jne fail

    mov eax, SYS_READ
    mov ebx, [pipefd]
    mov ecx, buf
    mov edx, msg_len
    int 0x80
    cmp eax, msg_len
    jne fail
    cmp dword [buf], 0x65706970
    jne fail
    cmp dword [buf + 4], 0x65747962
    jne fail

    mov eax, SYS_CLOSE
    mov ebx, [pipefd]
    int 0x80
    mov eax, SYS_CLOSE
    mov ebx, [pipefd + 4]
    int 0x80

    mov eax, SYS_PIPE2
    mov ebx, pipe2fd
    mov ecx, O_CLOEXEC
    int 0x80
    test eax, eax
    js fail

    mov eax, SYS_FCNTL
    mov ebx, [pipe2fd]
    mov ecx, F_GETFD
    xor edx, edx
    int 0x80
    cmp eax, FD_CLOEXEC
    jne fail

    mov eax, SYS_FCNTL
    mov ebx, [pipe2fd + 4]
    mov ecx, F_GETFD
    xor edx, edx
    int 0x80
    cmp eax, FD_CLOEXEC
    jne fail

    mov eax, SYS_WRITE
    mov ebx, [pipe2fd + 4]
    mov ecx, msg2
    mov edx, msg2_len
    int 0x80
    cmp eax, msg2_len
    jne fail

    mov eax, SYS_READ
    mov ebx, [pipe2fd]
    mov ecx, buf
    mov edx, msg2_len
    int 0x80
    cmp eax, msg2_len
    jne fail
    cmp word [buf], 0x3270
    jne fail

    mov eax, SYS_WRITE
    mov ebx, 1
    mov ecx, ok_msg
    mov edx, ok_len
    int 0x80
    mov eax, SYS_EXIT
    mov ebx, 19
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
msg:      db "pipebyte"
msg_len  equ $ - msg
msg2:     db "p2"
msg2_len equ $ - msg2
ok_msg:   db "pipe ok", 10
ok_len    equ $ - ok_msg
fail_msg: db "pipe fail", 10
fail_len  equ $ - fail_msg

section .bss
pipefd:  resd 2
pipe2fd: resd 2
buf:     resb 16
