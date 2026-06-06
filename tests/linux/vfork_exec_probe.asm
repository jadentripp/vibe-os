; vfork_exec_probe.asm - Linux i386 vfork-shaped clone plus execve proof.
;
; The parent must resume after the child successfully execs /BIN/VFORKCH.ELF,
; then waitpid must reap that exec target under the original child pid.
bits 32
global start

%define SYS_EXIT    1
%define SYS_WRITE   4
%define SYS_WAITPID 7
%define SYS_EXECVE  11
%define SYS_CLONE   120

%define SIGCHLD     17
%define CLONE_VM    0x00000100
%define CLONE_VFORK 0x00004000

section .text
start:
    mov eax, SYS_CLONE
    mov ebx, CLONE_VM | CLONE_VFORK | SIGCHLD
    xor ecx, ecx
    xor edx, edx
    xor esi, esi
    xor edi, edi
    int 0x80
    test eax, eax
    js fail
    jz child

parent:
    mov [child_pid], eax
    mov eax, SYS_WAITPID
    mov ebx, [child_pid]
    mov ecx, wait_status
    xor edx, edx
    int 0x80
    cmp eax, [child_pid]
    jne fail
    cmp dword [wait_status], (42 << 8)
    jne fail
    mov eax, SYS_WRITE
    mov ebx, 1
    mov ecx, ok_msg
    mov edx, ok_len
    int 0x80
    mov eax, SYS_EXIT
    mov ebx, 39
    int 0x80

child:
    mov eax, SYS_EXECVE
    mov ebx, child_path
    mov ecx, child_argv
    mov edx, empty_envp
    int 0x80
    mov eax, SYS_EXIT
    mov ebx, 7
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
child_path: db "/BIN/VFORKCH.ELF", 0
child_arg1: db "vfork-exec-child", 0

child_argv:
    dd child_path
    dd child_arg1
    dd 0

empty_envp:
    dd 0

ok_msg: db "vfork exec ok", 10
ok_len equ $ - ok_msg
fail_msg: db "vfork exec fail", 10
fail_len equ $ - fail_msg

section .bss
child_pid: resd 1
wait_status: resd 1
