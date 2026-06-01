; libmagic_probe.asm - Linux i386 shared-library alias read probe for vibe-os.
;
; Proves ld.so.cache ENOENT is a benign loader fallback, then reads the first
; bytes of the Chromium libglib alias to verify the guest VFS returns ELF data.
bits 32
global start

%define SYS_EXIT    1
%define SYS_READ    3
%define SYS_WRITE   4
%define SYS_CLOSE   6
%define SYS_OPENAT  295
%define SYS_PREAD64 180
%define AT_FDCWD    0xffffff9c
%define O_RDONLY    0x00000000
%define O_CLOEXEC   0x00080000
%define ENOENT      2
%define ELF_MAGIC   0x464c457f

section .text
start:
    mov eax, SYS_OPENAT
    mov ebx, AT_FDCWD
    mov ecx, path_ldso_cache
    mov edx, O_RDONLY | O_CLOEXEC
    xor esi, esi
    int 0x80
    cmp eax, -ENOENT
    jne fail

    mov eax, SYS_OPENAT
    mov ebx, AT_FDCWD
    mov ecx, path_glib
    mov edx, O_RDONLY | O_CLOEXEC
    xor esi, esi
    int 0x80
    test eax, eax
    js fail
    mov [fd], eax

    mov eax, SYS_READ
    mov ebx, [fd]
    mov ecx, read_buf
    mov edx, 4
    int 0x80
    cmp eax, 4
    jne fail_close
    cmp dword [read_buf], ELF_MAGIC
    jne fail_close

    mov eax, SYS_PREAD64
    mov ebx, [fd]
    mov ecx, pread_buf
    mov edx, 4
    xor esi, esi
    xor edi, edi
    int 0x80
    cmp eax, 4
    jne fail_close
    cmp dword [pread_buf], ELF_MAGIC
    jne fail_close

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
    mov ebx, 29
    int 0x80

fail_close:
    mov eax, SYS_CLOSE
    mov ebx, [fd]
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
path_ldso_cache: db "/etc/ld.so.cache", 0
path_glib: db "/lib/i386-linux-gnu/libglib-2.0.so.0", 0
ok_msg:    db "libmagic ok", 10
ok_len     equ $ - ok_msg
fail_msg:  db "libmagic fail", 10
fail_len   equ $ - fail_msg

section .bss
fd:        resd 1
read_buf:  resb 4
pread_buf: resb 4
