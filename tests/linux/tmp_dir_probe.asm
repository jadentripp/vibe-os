; tmp_dir_probe.asm - Linux i386 /tmp profile directory probe for vibe-os.
;
; Proves the tiny synthetic directory contract Chromium startup expects for
; --user-data-dir=/tmp/chromium-profile without adding a tmpfs.
bits 32
global start

%define SYS_EXIT       1
%define SYS_WRITE      4
%define SYS_CLOSE      6
%define SYS_ACCESS     33
%define SYS_STAT64     195
%define SYS_FSTAT64    197
%define SYS_GETDENTS64 220
%define SYS_OPENAT     295
%define SYS_FSTATAT64  300
%define SYS_FACCESSAT  307
%define AT_FDCWD       0xffffff9c
%define O_DIRECTORY    0x00010000
%define O_CLOEXEC      0x00080000
%define R_OK           4
%define W_OK           2
%define X_OK           1
%define S_IFMT         0x0000f000
%define S_IFDIR        0x00004000
%define STAT64_MODE    16

section .text
start:
    mov ecx, path_tmp
    call check_profile_dir
    jc fail

    mov ecx, path_profile
    call check_profile_dir
    jc fail

    mov eax, SYS_WRITE
    mov ebx, 1
    mov ecx, ok_msg
    mov edx, ok_len
    int 0x80
    mov eax, SYS_EXIT
    mov ebx, 23
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

check_profile_dir:
    mov [path_ptr], ecx

    mov eax, SYS_ACCESS
    mov ebx, [path_ptr]
    xor ecx, ecx
    int 0x80
    test eax, eax
    jne .fail

    mov eax, SYS_ACCESS
    mov ebx, [path_ptr]
    mov ecx, R_OK | W_OK | X_OK
    int 0x80
    test eax, eax
    jne .fail

    mov eax, SYS_STAT64
    mov ebx, [path_ptr]
    mov ecx, stat_buf
    int 0x80
    test eax, eax
    jne .fail
    call stat_buf_is_dir
    jc .fail

    mov eax, SYS_FSTATAT64
    mov ebx, AT_FDCWD
    mov ecx, [path_ptr]
    mov edx, stat_buf
    xor esi, esi
    int 0x80
    test eax, eax
    jne .fail
    call stat_buf_is_dir
    jc .fail

    mov eax, SYS_FACCESSAT
    mov ebx, AT_FDCWD
    mov ecx, [path_ptr]
    mov edx, R_OK | W_OK | X_OK
    int 0x80
    test eax, eax
    jne .fail

    mov eax, SYS_OPENAT
    mov ebx, AT_FDCWD
    mov ecx, [path_ptr]
    mov edx, O_DIRECTORY | O_CLOEXEC
    xor esi, esi
    int 0x80
    test eax, eax
    js .fail
    mov [fd], eax

    mov eax, SYS_FSTAT64
    mov ebx, [fd]
    mov ecx, stat_buf
    int 0x80
    test eax, eax
    jne .close_fail
    call stat_buf_is_dir
    jc .close_fail

    mov eax, SYS_GETDENTS64
    mov ebx, [fd]
    mov ecx, dir_buf
    mov edx, dir_buf_len
    int 0x80
    test eax, eax
    js .close_fail
    test eax, eax
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

section .data
path_tmp:     db "/tmp", 0
path_profile: db "/tmp/chromium-profile", 0
ok_msg:       db "tmpdir ok", 10
ok_len        equ $ - ok_msg
fail_msg:     db "tmpdir fail", 10
fail_len      equ $ - fail_msg

section .bss
fd:       resd 1
path_ptr: resd 1
stat_buf: resb 96
dir_buf:  resb 64
dir_buf_len equ $ - dir_buf
