; execve_probe.asm - Linux i386 execve proof for vibe-os.
;
; Proves syscall 11 with no libc: a missing exec returns -ENOENT, then a
; successful execve of /BIN/HELLO.ELF must not return to this program.
bits 32
global start

%define SYS_EXIT    1
%define SYS_WRITE   4
%define SYS_EXECVE  11
%define ENOENT_NEG  -2

section .text
start:
    mov eax, SYS_EXECVE
    mov ebx, missing_path
    mov ecx, missing_argv
    mov edx, empty_envp
    int 0x80
    cmp eax, ENOENT_NEG
    jne fail

    mov eax, SYS_WRITE
    mov ebx, 1
    mov ecx, handoff_msg
    mov edx, handoff_len
    int 0x80

    mov eax, SYS_EXECVE
    mov ebx, hello_path
    mov ecx, hello_argv
    mov edx, hello_envp
    int 0x80
    mov [execve_ret], eax
    mov eax, SYS_WRITE
    mov ebx, 1
    mov ecx, fail_msg
    mov edx, fail_len
    int 0x80
    mov eax, SYS_EXIT
    mov ebx, 2
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
hello_path: db "/BIN/HELLO.ELF", 0
hello_arg1: db "execve-child", 0
hello_env0: db "EXECVE_PROBE=1", 0
missing_path: db "/BIN/NOEXEC.ELF", 0

hello_argv:
    dd hello_path
    dd hello_arg1
    dd 0

hello_envp:
    dd hello_env0
    dd 0

missing_argv:
    dd missing_path
    dd 0

empty_envp:
    dd 0

handoff_msg: db "execve handoff", 10
handoff_len equ $ - handoff_msg
fail_msg: db "execve fail", 10
fail_len equ $ - fail_msg

section .bss
execve_ret: resd 1
