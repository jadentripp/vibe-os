; writev_probe.asm - Linux i386 writev FD-kind probe for vibe-os.
;
; Exercises writev to stdout/stderr, /dev/null, and the existing pipe buffer.
bits 32
global start

%define SYS_EXIT    1
%define SYS_READ    3
%define SYS_WRITE   4
%define SYS_OPENAT  295
%define SYS_CLOSE   6
%define SYS_PIPE    42
%define SYS_WRITEV  146
%define SYS_FSTAT64 197
%define AT_FDCWD    0xffffff9c
%define O_WRONLY    0x00000001
%define O_CLOEXEC   0x00080000
%define S_IFMT      0x0000f000
%define S_IFIFO     0x00001000
%define STAT64_MODE 16

section .text
start:
    mov eax, SYS_WRITEV
    mov ebx, 1
    mov ecx, stdout_iov
    mov edx, 2
    int 0x80
    cmp eax, stdout_len
    jne fail

    mov eax, SYS_WRITEV
    mov ebx, 2
    mov ecx, stderr_iov
    mov edx, 2
    int 0x80
    cmp eax, stderr_len
    jne fail

    mov eax, SYS_OPENAT
    mov ebx, AT_FDCWD
    mov ecx, path_null
    mov edx, O_WRONLY | O_CLOEXEC
    xor esi, esi
    int 0x80
    test eax, eax
    js fail
    mov [null_fd], eax

    mov eax, SYS_WRITEV
    mov ebx, [null_fd]
    mov ecx, null_iov
    mov edx, 2
    int 0x80
    cmp eax, null_len
    jne fail

    mov eax, SYS_CLOSE
    mov ebx, [null_fd]
    int 0x80
    test eax, eax
    jne fail

    mov eax, SYS_PIPE
    mov ebx, pipefd
    int 0x80
    test eax, eax
    js fail

    mov eax, SYS_FSTAT64
    mov ebx, [pipefd]
    mov ecx, statbuf
    int 0x80
    test eax, eax
    jne fail
    mov eax, [statbuf + STAT64_MODE]
    and eax, S_IFMT
    cmp eax, S_IFIFO
    jne fail

    mov eax, SYS_WRITEV
    mov ebx, [pipefd + 4]
    mov ecx, pipe_iov
    mov edx, 2
    int 0x80
    cmp eax, pipe_len
    jne fail

    mov eax, SYS_READ
    mov ebx, [pipefd]
    mov ecx, pipe_buf
    mov edx, pipe_len
    int 0x80
    cmp eax, pipe_len
    jne fail
    cmp dword [pipe_buf], 0x65706970
    jne fail
    cmp byte [pipe_buf + 4], 'v'
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
stdout_a: db "write"
stdout_a_len equ $ - stdout_a
stdout_b: db "v stdout", 10
stdout_b_len equ $ - stdout_b
stdout_len equ stdout_a_len + stdout_b_len
stdout_iov:
    dd stdout_a, stdout_a_len
    dd stdout_b, stdout_b_len

stderr_a: db "write"
stderr_a_len equ $ - stderr_a
stderr_b: db "v stderr", 10
stderr_b_len equ $ - stderr_b
stderr_len equ stderr_a_len + stderr_b_len
stderr_iov:
    dd stderr_a, stderr_a_len
    dd stderr_b, stderr_b_len

path_null: db "/dev/null", 0
null_a: db "null"
null_a_len equ $ - null_a
null_b: db "sink"
null_b_len equ $ - null_b
null_len equ null_a_len + null_b_len
null_iov:
    dd null_a, null_a_len
    dd null_b, null_b_len

pipe_a: db "pipe"
pipe_a_len equ $ - pipe_a
pipe_b: db "v"
pipe_b_len equ $ - pipe_b
pipe_len equ pipe_a_len + pipe_b_len
pipe_iov:
    dd pipe_a, pipe_a_len
    dd pipe_b, pipe_b_len

ok_msg: db "writev ok", 10
ok_len equ $ - ok_msg
fail_msg: db "writev fail", 10
fail_len equ $ - fail_msg

section .bss
null_fd:  resd 1
pipefd:   resd 2
pipe_buf: resb 8
statbuf:  resb 96
