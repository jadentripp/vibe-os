; ldso_header_probe.asm - Linux i386 ld.so-style shared-object header probe.
;
; Exercises absolute and dirfd-relative loader-like access to Chromium's glib
; dependency, including read, pread64, lseek+read, and file mmap validation.
bits 32
global start

%define SYS_EXIT    1
%define SYS_READ    3
%define SYS_WRITE   4
%define SYS_CLOSE   6
%define SYS_LSEEK   19
%define SYS_MUNMAP  91
%define SYS_PREAD64 180
%define SYS_MMAP2   192
%define SYS_OPENAT  295

%define AT_FDCWD    0xffffff9c
%define O_RDONLY    0x00000000
%define O_DIRECTORY 0x00010000
%define O_CLOEXEC   0x00080000
%define SEEK_SET    0

%define PROT_READ    1
%define MAP_PRIVATE  2
%define MAP_LEN      4096
%define ERRNO_LOW    0xfffff001

%define ELF_MAGIC       0x464c457f
%define ELFCLASS32      1
%define ELFDATA2LSB     1
%define EV_CURRENT      1
%define ET_DYN          3
%define EM_386          3
%define ELF32_EHDR_SIZE 52

section .text
start:
    mov eax, SYS_OPENAT
    mov ebx, AT_FDCWD
    mov ecx, path_glib_abs
    mov edx, O_RDONLY | O_CLOEXEC
    xor esi, esi
    int 0x80
    test eax, eax
    js fail
    call check_file_fd
    jc fail
    call close_fd
    jc fail

    mov eax, SYS_OPENAT
    mov ebx, AT_FDCWD
    mov ecx, path_lib_dir
    mov edx, O_RDONLY | O_DIRECTORY | O_CLOEXEC
    xor esi, esi
    int 0x80
    test eax, eax
    js fail
    mov [dirfd], eax

    mov eax, SYS_OPENAT
    mov ebx, [dirfd]
    mov ecx, name_glib
    mov edx, O_RDONLY | O_CLOEXEC
    xor esi, esi
    int 0x80
    test eax, eax
    js fail
    call check_file_fd
    jc fail
    call close_fd
    jc fail

    mov eax, SYS_CLOSE
    mov ebx, [dirfd]
    int 0x80
    test eax, eax
    jne fail

    mov eax, SYS_WRITE
    mov ebx, 1
    mov ecx, ok_msg
    mov edx, ok_len
    int 0x80
    mov eax, SYS_EXIT
    mov ebx, 31
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

check_file_fd:
    mov [fd], eax

    mov eax, SYS_READ
    mov ebx, [fd]
    mov ecx, ehdr_buf
    mov edx, ELF32_EHDR_SIZE
    int 0x80
    cmp eax, ELF32_EHDR_SIZE
    jne .fail
    call verify_ehdr
    jc .fail

    mov eax, SYS_PREAD64
    mov ebx, [fd]
    mov ecx, ehdr_buf
    mov edx, ELF32_EHDR_SIZE
    xor esi, esi
    xor edi, edi
    int 0x80
    cmp eax, ELF32_EHDR_SIZE
    jne .fail
    call verify_ehdr
    jc .fail

    mov eax, SYS_LSEEK
    mov ebx, [fd]
    xor ecx, ecx
    mov edx, SEEK_SET
    int 0x80
    test eax, eax
    jne .fail

    mov eax, SYS_READ
    mov ebx, [fd]
    mov ecx, ehdr_buf
    mov edx, ELF32_EHDR_SIZE
    int 0x80
    cmp eax, ELF32_EHDR_SIZE
    jne .fail
    call verify_ehdr
    jc .fail

    call try_file_mmap
    jc .fail

    clc
    ret

.fail:
    stc
    ret

close_fd:
    mov eax, SYS_CLOSE
    mov ebx, [fd]
    int 0x80
    test eax, eax
    jne .fail
    clc
    ret

.fail:
    stc
    ret

verify_ehdr:
    cmp dword [ehdr_buf], ELF_MAGIC
    jne .fail
    cmp byte [ehdr_buf + 4], ELFCLASS32
    jne .fail
    cmp byte [ehdr_buf + 5], ELFDATA2LSB
    jne .fail
    cmp byte [ehdr_buf + 6], EV_CURRENT
    jne .fail
    cmp word [ehdr_buf + 16], ET_DYN
    jne .fail
    cmp word [ehdr_buf + 18], EM_386
    jne .fail
    cmp word [ehdr_buf + 40], ELF32_EHDR_SIZE
    jne .fail
    clc
    ret

.fail:
    stc
    ret

try_file_mmap:
    mov eax, SYS_MMAP2
    xor ebx, ebx
    mov ecx, MAP_LEN
    mov edx, PROT_READ
    mov esi, MAP_PRIVATE
    mov edi, [fd]
    xor ebp, ebp
    int 0x80
    cmp eax, ERRNO_LOW
    jae .fail
    mov [map_addr], eax
    cmp dword [eax], ELF_MAGIC
    jne .unmap_fail

    mov eax, SYS_MUNMAP
    mov ebx, [map_addr]
    mov ecx, MAP_LEN
    int 0x80
    test eax, eax
    jne .fail

.ok:
    clc
    ret

.unmap_fail:
    mov eax, SYS_MUNMAP
    mov ebx, [map_addr]
    mov ecx, MAP_LEN
    int 0x80

.fail:
    stc
    ret

section .data
path_glib_abs: db "/lib/i386-linux-gnu/libglib-2.0.so.0", 0
path_lib_dir:  db "/lib/i386-linux-gnu", 0
name_glib:     db "libglib-2.0.so.0", 0
ok_msg:        db "ldso header ok", 10
ok_len         equ $ - ok_msg
fail_msg:      db "ldso header fail", 10
fail_len       equ $ - fail_msg

section .bss
fd:       resd 1
dirfd:    resd 1
map_addr: resd 1
ehdr_buf:  resb ELF32_EHDR_SIZE
