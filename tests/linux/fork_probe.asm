; fork_probe.asm - Linux i386 fork/wait probe for vibe-os.
;
; Proves the first M1a process-control seed: Linux fork returns child pid in
; the parent, zero in the child, waitpid reaps the child with Linux wait status,
; and the forked address space is isolated from the parent.
bits 32
global start

%define SYS_EXIT    1
%define SYS_FORK    2
%define SYS_WRITE   4
%define SYS_WAITPID 7

section .text
start:
    mov byte [marker], 'P'

    mov eax, SYS_FORK
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
    cmp dword [wait_status], (23 << 8)
    jne fail
    cmp byte [marker], 'P'
    jne fail

    mov eax, SYS_WRITE
    mov ebx, 1
    mov ecx, ok_msg
    mov edx, ok_len
    int 0x80
    mov eax, SYS_EXIT
    mov ebx, 21
    int 0x80

child:
    cmp byte [marker], 'P'
    jne child_fail
    mov byte [marker], 'C'
    mov eax, SYS_EXIT
    mov ebx, 23
    int 0x80

child_fail:
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
ok_msg:   db "fork ok", 10
ok_len    equ $ - ok_msg
fail_msg: db "fork fail", 10
fail_len  equ $ - fail_msg
marker:   db 'U'

section .bss
child_pid:   resd 1
wait_status: resd 1
