; llseek_probe.asm - Linux i386 _llseek compatibility probe for vibe-os.
;
; Exercises fd, offset_hi/offset_lo, result pointer, whence, and offset
; preservation on readonly FAT files plus Chromium's tiny synthetic files.
bits 32
global start

%define SYS_EXIT    1
%define SYS_READ    3
%define SYS_WRITE   4
%define SYS_CLOSE   6
%define SYS_PIPE    42
%define SYS_LLSEEK  140
%define SYS_OPENAT  295
%define AT_FDCWD    0xffffff9c
%define O_RDONLY    0x00000000
%define O_DIRECTORY 0x00010000
%define O_CLOEXEC   0x00080000
%define SEEK_SET    0
%define SEEK_CUR    1
%define SEEK_END    2
%define EBADF_NEG   -9
%define EFAULT_NEG  -14
%define EINVAL_NEG  -22
%define ESPIPE_NEG  -29

section .text
start:
    call check_readonly_file
    jc fail
    call check_synthetic_file
    jc fail
    call check_directory_fd
    jc fail
    call check_dev_null_fd
    jc fail
    call check_pipe_fd
    jc fail

    mov eax, SYS_WRITE
    mov ebx, 1
    mov ecx, ok_msg
    mov edx, ok_len
    int 0x80
    mov eax, SYS_EXIT
    mov ebx, 35
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

check_readonly_file:
    mov eax, SYS_OPENAT
    mov ebx, AT_FDCWD
    mov ecx, path_self
    mov edx, O_RDONLY | O_CLOEXEC
    xor esi, esi
    int 0x80
    test eax, eax
    js .fail
    mov [fd], eax

    mov ebx, [fd]
    xor ecx, ecx
    mov edx, 4
    mov edi, SEEK_SET
    call llseek_expect_success
    jc .close_fail
    cmp dword [pos], 4
    jne .close_fail
    cmp dword [pos + 4], 0
    jne .close_fail

    mov eax, SYS_READ
    mov ebx, [fd]
    mov ecx, buf
    mov edx, 1
    int 0x80
    cmp eax, 1
    jne .close_fail
    cmp byte [buf], 1
    jne .close_fail

    mov ebx, [fd]
    xor ecx, ecx
    xor edx, edx
    mov edi, SEEK_CUR
    call llseek_expect_success
    jc .close_fail
    cmp dword [pos], 5
    jne .close_fail
    cmp dword [pos + 4], 0
    jne .close_fail

    mov ebx, [fd]
    mov ecx, 0xffffffff
    mov edx, 0xfffffffc
    mov edi, SEEK_CUR
    call llseek_expect_success
    jc .close_fail
    cmp dword [pos], 1
    jne .close_fail

    mov eax, SYS_READ
    mov ebx, [fd]
    mov ecx, buf
    mov edx, 3
    int 0x80
    cmp eax, 3
    jne .close_fail
    cmp word [buf], 0x4c45
    jne .close_fail
    cmp byte [buf + 2], 0x46
    jne .close_fail

    mov ebx, [fd]
    xor ecx, ecx
    xor edx, edx
    mov edi, SEEK_END
    call llseek_expect_success
    jc .close_fail
    cmp dword [pos + 4], 0
    jne .close_fail
    cmp dword [pos], 8
    jb .close_fail
    mov eax, [pos]
    mov [file_size], eax
    sub eax, 2
    mov [expected], eax

    mov ebx, [fd]
    mov ecx, 0xffffffff
    mov edx, 0xfffffffe
    mov edi, SEEK_END
    call llseek_expect_success
    jc .close_fail
    mov eax, [expected]
    cmp [pos], eax
    jne .close_fail
    cmp dword [pos + 4], 0
    jne .close_fail

    mov ebx, [fd]
    xor ecx, ecx
    mov edx, 0xffffffff
    mov esi, pos
    mov edi, SEEK_END
    mov eax, SYS_LLSEEK
    int 0x80
    cmp eax, EINVAL_NEG
    jne .close_fail
    call expect_current_offset
    jc .close_fail

    mov ebx, [fd]
    xor ecx, ecx
    mov edx, 1
    mov esi, pos
    mov edi, 99
    mov eax, SYS_LLSEEK
    int 0x80
    cmp eax, EINVAL_NEG
    jne .close_fail
    call expect_current_offset
    jc .close_fail

    mov ebx, [fd]
    xor ecx, ecx
    xor edx, edx
    xor esi, esi
    mov edi, SEEK_SET
    mov eax, SYS_LLSEEK
    int 0x80
    cmp eax, EFAULT_NEG
    jne .close_fail
    call expect_current_offset
    jc .close_fail

    mov eax, SYS_LLSEEK
    mov ebx, 99
    xor ecx, ecx
    xor edx, edx
    mov esi, pos
    mov edi, SEEK_SET
    int 0x80
    cmp eax, EBADF_NEG
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

check_synthetic_file:
    mov eax, SYS_OPENAT
    mov ebx, AT_FDCWD
    mov ecx, path_maps
    mov edx, O_RDONLY | O_CLOEXEC
    xor esi, esi
    int 0x80
    test eax, eax
    js .fail
    mov [fd], eax

    mov ebx, [fd]
    xor ecx, ecx
    mov edx, 4
    mov edi, SEEK_SET
    call llseek_expect_success
    jc .close_fail
    cmp dword [pos], 4
    jne .close_fail
    cmp dword [pos + 4], 0
    jne .close_fail

    mov eax, SYS_READ
    mov ebx, [fd]
    mov ecx, buf
    mov edx, 4
    int 0x80
    cmp eax, 4
    jne .close_fail

    mov ebx, [fd]
    xor ecx, ecx
    xor edx, edx
    mov edi, SEEK_CUR
    call llseek_expect_success
    jc .close_fail
    cmp dword [pos], 8
    jne .close_fail

    mov ebx, [fd]
    mov ecx, 0xffffffff
    mov edx, 0xfffffffc
    mov edi, SEEK_CUR
    call llseek_expect_success
    jc .close_fail
    cmp dword [pos], 4
    jne .close_fail

    mov ebx, [fd]
    xor ecx, ecx
    xor edx, edx
    mov edi, SEEK_END
    call llseek_expect_success
    jc .close_fail
    cmp dword [pos + 4], 0
    jne .close_fail
    cmp dword [pos], 8
    jb .close_fail
    mov eax, [pos]
    sub eax, 1
    mov [expected], eax

    mov ebx, [fd]
    mov ecx, 0xffffffff
    mov edx, 0xffffffff
    mov edi, SEEK_END
    call llseek_expect_success
    jc .close_fail
    mov eax, [expected]
    cmp [pos], eax
    jne .close_fail
    cmp dword [pos + 4], 0
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

check_directory_fd:
    mov eax, SYS_OPENAT
    mov ebx, AT_FDCWD
    mov ecx, path_bin
    mov edx, O_RDONLY | O_DIRECTORY | O_CLOEXEC
    xor esi, esi
    int 0x80
    test eax, eax
    js .fail
    mov [fd], eax

    mov ebx, [fd]
    xor ecx, ecx
    mov edx, 1
    mov edi, SEEK_SET
    call llseek_expect_success
    jc .close_fail
    cmp dword [pos], 1
    jne .close_fail
    cmp dword [pos + 4], 0
    jne .close_fail

    mov ebx, [fd]
    mov ecx, 0xffffffff
    mov edx, 0xffffffff
    mov edi, SEEK_CUR
    call llseek_expect_success
    jc .close_fail
    cmp dword [pos], 0
    jne .close_fail
    cmp dword [pos + 4], 0
    jne .close_fail
    mov dword [expected], 0

    mov ebx, [fd]
    xor ecx, ecx
    xor edx, edx
    mov esi, pos
    mov edi, SEEK_END
    mov eax, SYS_LLSEEK
    int 0x80
    cmp eax, EINVAL_NEG
    jne .close_fail
    call expect_current_offset
    jc .close_fail

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

check_dev_null_fd:
    mov eax, SYS_OPENAT
    mov ebx, AT_FDCWD
    mov ecx, path_null
    mov edx, O_RDONLY | O_CLOEXEC
    xor esi, esi
    int 0x80
    test eax, eax
    js .fail
    mov [fd], eax

    mov ebx, [fd]
    xor ecx, ecx
    xor edx, edx
    mov edi, SEEK_CUR
    call llseek_expect_success
    jc .close_fail
    cmp dword [pos], 0
    jne .close_fail
    cmp dword [pos + 4], 0
    jne .close_fail

    mov ebx, [fd]
    xor ecx, ecx
    mov edx, 1
    mov esi, pos
    mov edi, SEEK_SET
    mov eax, SYS_LLSEEK
    int 0x80
    cmp eax, EINVAL_NEG
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

check_pipe_fd:
    mov eax, SYS_PIPE
    mov ebx, pipefds
    int 0x80
    test eax, eax
    js .fail

    mov eax, SYS_LLSEEK
    mov ebx, [pipefds]
    xor ecx, ecx
    xor edx, edx
    mov esi, pos
    mov edi, SEEK_CUR
    int 0x80
    cmp eax, ESPIPE_NEG
    jne .close_fail

    mov eax, SYS_CLOSE
    mov ebx, [pipefds]
    int 0x80
    test eax, eax
    jne .fail
    mov eax, SYS_CLOSE
    mov ebx, [pipefds + 4]
    int 0x80
    test eax, eax
    jne .fail
    clc
    ret

.close_fail:
    mov eax, SYS_CLOSE
    mov ebx, [pipefds]
    int 0x80
    mov eax, SYS_CLOSE
    mov ebx, [pipefds + 4]
    int 0x80

.fail:
    stc
    ret

llseek_expect_success:
    mov esi, pos
    mov eax, SYS_LLSEEK
    int 0x80
    test eax, eax
    jne .fail
    clc
    ret

.fail:
    stc
    ret

expect_current_offset:
    mov ebx, [fd]
    xor ecx, ecx
    xor edx, edx
    mov esi, pos
    mov edi, SEEK_CUR
    mov eax, SYS_LLSEEK
    int 0x80
    test eax, eax
    jne .fail
    mov eax, [expected]
    cmp [pos], eax
    jne .fail
    cmp dword [pos + 4], 0
    jne .fail
    clc
    ret

.fail:
    stc
    ret

section .data
path_self: db "/BIN/LLSEEK.ELF", 0
path_maps: db "/proc/self/maps", 0
path_bin:  db "/BIN", 0
path_null: db "/dev/null", 0
ok_msg:    db "llseek ok", 10
ok_len     equ $ - ok_msg
fail_msg:  db "llseek fail", 10
fail_len   equ $ - fail_msg

section .bss
fd:        resd 1
pos:       resq 1
file_size: resd 1
expected:  resd 1
pipefds:   resd 2
buf:       resb 8
