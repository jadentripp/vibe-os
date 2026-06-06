; dir_probe.asm - Linux i386 directory enumeration probe for vibe-os.
;
; Exercises openat(..., O_DIRECTORY) plus getdents64(220) on "/" and "/BIN".
; It proves the first M1a `ls` prerequisite without depending on libc.
bits 32
global start

%define SYS_EXIT       1
%define SYS_WRITE      4
%define SYS_CLOSE      6
%define SYS_GETDENTS64 220
%define SYS_OPENAT     295
%define AT_FDCWD       0xffffff9c
%define O_DIRECTORY    0x00010000
%define O_CLOEXEC      0x00080000

section .text
start:
    mov ecx, path_root
    mov edx, name_bin
    call open_dir_and_find
    jc fail

    mov ecx, path_bin
    mov edx, name_dir_elf
    call open_dir_and_find
    jc fail

    mov eax, SYS_WRITE
    mov ebx, 1
    mov ecx, ok_msg
    mov edx, ok_len
    int 0x80
    mov eax, SYS_EXIT
    mov ebx, 15
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

open_dir_and_find:
    mov [target_ptr], edx
    mov eax, SYS_OPENAT
    mov ebx, AT_FDCWD
    mov edx, O_DIRECTORY | O_CLOEXEC
    xor esi, esi
    int 0x80
    test eax, eax
    js .fail
    mov [fd], eax

    mov eax, SYS_GETDENTS64
    mov ebx, [fd]
    mov ecx, dir_buf
    mov edx, dir_buf_len
    int 0x80
    mov [nread], eax

    mov eax, SYS_CLOSE
    mov ebx, [fd]
    int 0x80

    mov eax, [nread]
    test eax, eax
    jle .fail
    mov esi, dir_buf
    lea edi, [dir_buf + eax]

.scan:
    cmp esi, edi
    jae .fail
    movzx eax, word [esi + 16]
    cmp eax, 20
    jb .fail
    mov [reclen], eax
    mov ebx, esi
    add ebx, eax
    cmp ebx, edi
    ja .fail
    push esi
    push edi
    lea esi, [esi + 19]
    mov edi, [target_ptr]
    call streq
    pop edi
    pop esi
    jnc .found
    add esi, [reclen]
    jmp .scan

.found:
    clc
    ret

.fail:
    stc
    ret

streq:
    lodsb
    mov bl, [edi]
    inc edi
    cmp al, bl
    jne .fail
    test al, al
    jne streq
    clc
    ret

.fail:
    stc
    ret

section .data
path_root:   db "/", 0
path_bin:    db "/BIN", 0
name_bin:    db "BIN", 0
name_dir_elf: db "DIR.ELF", 0
ok_msg:      db "dir ok", 10
ok_len       equ $ - ok_msg
fail_msg:    db "dir fail", 10
fail_len     equ $ - fail_msg

section .bss
fd:         resd 1
nread:      resd 1
reclen:     resd 1
target_ptr: resd 1
dir_buf:    resb 1024
dir_buf_len equ $ - dir_buf
