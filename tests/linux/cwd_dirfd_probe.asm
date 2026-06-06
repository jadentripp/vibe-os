; cwd_dirfd_probe.asm - Linux i386 cwd and dirfd regression probe for vibe-os.
;
; Exercises getcwd, chdir("/BIN"), cwd-relative open/openat/stat64, and
; dirfd-relative openat/fstatat64 without depending on libc.
bits 32
global start

%define SYS_EXIT      1
%define SYS_READ      3
%define SYS_WRITE     4
%define SYS_OPEN      5
%define SYS_CLOSE     6
%define SYS_CHDIR     12
%define SYS_GETCWD    183
%define SYS_STAT64    195
%define SYS_FSTAT64   197
%define SYS_OPENAT    295
%define SYS_FSTATAT64 300

%define AT_FDCWD    0xffffff9c
%define O_RDONLY    0x00000000
%define O_DIRECTORY 0x00010000
%define O_CLOEXEC   0x00080000
%define ERRNO_ENOENT -2
%define S_IFMT      0x0000f000
%define S_IFDIR     0x00004000
%define S_IFREG     0x00008000
%define STAT64_MODE 16
%define ELF_MAGIC   0x464c457f

section .text
start:
    mov eax, SYS_GETCWD
    mov ebx, cwd_buf
    mov ecx, cwd_buf_len
    int 0x80
    test eax, eax
    jle fail
    mov esi, cwd_buf
    mov edi, path_root
    call streq
    jc fail

    mov eax, SYS_STAT64
    mov ebx, name_bin
    mov ecx, stat_buf
    int 0x80
    test eax, eax
    jne fail
    call stat_buf_is_dir
    jc fail

    mov eax, SYS_CHDIR
    mov ebx, path_bin
    int 0x80
    test eax, eax
    jne fail

    mov eax, SYS_GETCWD
    mov ebx, cwd_buf
    mov ecx, cwd_buf_len
    int 0x80
    test eax, eax
    jle fail
    mov esi, cwd_buf
    mov edi, path_bin
    call streq
    jc fail

    mov eax, SYS_STAT64
    mov ebx, name_bin
    mov ecx, stat_buf
    int 0x80
    cmp eax, ERRNO_ENOENT
    jne fail

    mov eax, SYS_OPENAT
    mov ebx, AT_FDCWD
    mov ecx, name_bin
    mov edx, O_RDONLY | O_DIRECTORY | O_CLOEXEC
    xor esi, esi
    int 0x80
    cmp eax, ERRNO_ENOENT
    jne fail

    mov eax, SYS_OPEN
    mov ebx, name_fd_elf
    mov ecx, O_RDONLY | O_CLOEXEC
    xor edx, edx
    int 0x80
    test eax, eax
    js fail
    call check_elf_fd
    jc fail

    mov eax, SYS_OPENAT
    mov ebx, AT_FDCWD
    mov ecx, name_dir_elf
    mov edx, O_RDONLY | O_CLOEXEC
    xor esi, esi
    int 0x80
    test eax, eax
    js fail
    call check_elf_fd
    jc fail

    mov eax, SYS_STAT64
    mov ebx, name_dir_elf
    mov ecx, stat_buf
    int 0x80
    test eax, eax
    jne fail
    call stat_buf_is_reg
    jc fail

    mov eax, SYS_OPENAT
    mov ebx, AT_FDCWD
    mov ecx, path_bin
    mov edx, O_RDONLY | O_DIRECTORY | O_CLOEXEC
    xor esi, esi
    int 0x80
    test eax, eax
    js fail
    mov [dirfd], eax

    mov eax, SYS_FSTAT64
    mov ebx, [dirfd]
    mov ecx, stat_buf
    int 0x80
    test eax, eax
    jne close_dirfd_fail
    call stat_buf_is_dir
    jc close_dirfd_fail

    mov eax, SYS_OPENAT
    mov ebx, [dirfd]
    mov ecx, name_fd_elf
    mov edx, O_RDONLY | O_CLOEXEC
    xor esi, esi
    int 0x80
    test eax, eax
    js close_dirfd_fail
    call check_elf_fd
    jc close_dirfd_fail

    mov eax, SYS_FSTATAT64
    mov ebx, [dirfd]
    mov ecx, name_dir_elf
    mov edx, stat_buf
    xor esi, esi
    int 0x80
    test eax, eax
    jne close_dirfd_fail
    call stat_buf_is_reg
    jc close_dirfd_fail

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
    mov ebx, 41
    int 0x80

close_dirfd_fail:
    mov eax, SYS_CLOSE
    mov ebx, [dirfd]
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

check_elf_fd:
    mov [fd], eax

    mov eax, SYS_READ
    mov ebx, [fd]
    mov ecx, magic_buf
    mov edx, 4
    int 0x80
    cmp eax, 4
    jne .close_fail
    cmp dword [magic_buf], ELF_MAGIC
    jne .close_fail

    mov eax, SYS_CLOSE
    mov ebx, [fd]
    int 0x80
    test eax, eax
    jne .fail
    clc
    ret

.close_fail:
    mov eax, SYS_CLOSE
    mov ebx, [fd]
    int 0x80

.fail:
    stc
    ret

stat_buf_is_dir:
    mov eax, [stat_buf + STAT64_MODE]
    and eax, S_IFMT
    cmp eax, S_IFDIR
    jne .fail
    clc
    ret

.fail:
    stc
    ret

stat_buf_is_reg:
    mov eax, [stat_buf + STAT64_MODE]
    and eax, S_IFMT
    cmp eax, S_IFREG
    jne .fail
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
path_root:    db "/", 0
path_bin:     db "/BIN", 0
name_bin:     db "BIN", 0
name_fd_elf:  db "FD.ELF", 0
name_dir_elf: db "DIR.ELF", 0
ok_msg:       db "cwd dirfd ok", 10
ok_len        equ $ - ok_msg
fail_msg:     db "cwd dirfd fail", 10
fail_len      equ $ - fail_msg

section .bss
fd:        resd 1
dirfd:     resd 1
cwd_buf:   resb 64
cwd_buf_len equ $ - cwd_buf
magic_buf: resb 4
stat_buf:  resb 96
