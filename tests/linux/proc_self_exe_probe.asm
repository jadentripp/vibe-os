; proc_self_exe_probe.asm - Linux i386 /proc/self/exe readlink probe.
;
; Exercises the synthetic /proc/self/exe readlink/readlinkat path without
; depending on libc or a full procfs implementation.
bits 32
global start

%define SYS_EXIT       1
%define SYS_WRITE      4
%define SYS_READLINK   85
%define SYS_READLINKAT 305
%define AT_FDCWD       0xffffff9c
%define ENOENT_NEG     -2

section .text
start:
    mov eax, SYS_READLINK
    mov ebx, proc_self_exe
    mov ecx, link_buf
    mov edx, link_buf_len
    int 0x80
    mov esi, link_buf
    mov edi, expected_path
    mov edx, expected_path_len
    call expect_path
    jc fail

    mov eax, SYS_READLINKAT
    mov ebx, AT_FDCWD
    mov ecx, proc_self_exe
    mov edx, link_buf
    mov esi, link_buf_len
    int 0x80
    mov esi, link_buf
    mov edi, expected_path
    mov edx, expected_path_len
    call expect_path
    jc fail

    mov eax, SYS_READLINK
    mov ebx, proc_self_exe
    mov ecx, link_buf
    mov edx, 4
    int 0x80
    cmp eax, 4
    jne fail
    cmp dword [link_buf], 0x4e49422f
    jne fail

    mov eax, SYS_READLINK
    mov ebx, not_proc_self_exe
    mov ecx, link_buf
    mov edx, link_buf_len
    int 0x80
    cmp eax, ENOENT_NEG
    jne fail

    mov eax, SYS_READLINKAT
    mov ebx, 5
    mov ecx, relative_proc_self_exe
    mov edx, link_buf
    mov esi, link_buf_len
    int 0x80
    cmp eax, ENOENT_NEG
    jne fail

    mov eax, SYS_WRITE
    mov ebx, 1
    mov ecx, ok_msg
    mov edx, ok_len
    int 0x80
    mov eax, SYS_EXIT
    mov ebx, 25
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

expect_path:
    cmp eax, edx
    jne .fail
    mov ecx, edx

.next:
    test ecx, ecx
    jz .ok
    mov al, [esi]
    cmp al, [edi]
    jne .fail
    inc esi
    inc edi
    dec ecx
    jmp .next

.ok:
    clc
    ret

.fail:
    stc
    ret

section .data
proc_self_exe: db "/proc/self/exe", 0
relative_proc_self_exe: db "proc/self/exe", 0
not_proc_self_exe: db "/proc/not-exe", 0
expected_path: db "/BIN/PROCEXE.ELF", 0
expected_path_len equ $ - expected_path - 1
ok_msg: db "proc self exe ok", 10
ok_len equ $ - ok_msg
fail_msg: db "proc self exe fail", 10
fail_len equ $ - fail_msg

section .bss
link_buf: resb 64
link_buf_len equ $ - link_buf
