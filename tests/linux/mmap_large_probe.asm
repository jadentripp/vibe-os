; mmap_large_probe.asm - Linux i386 large readonly file-backed mmap2 probe.
;
; Opens the probe's staged image, maps a 64 MiB MAP_PRIVATE/PROT_READ window
; from it, then touches safe file-backed pages plus the zero-filled EOF tail.
bits 32
global start

%define SYS_EXIT    1
%define SYS_WRITE   4
%define SYS_CLOSE   6
%define SYS_LSEEK   19
%define SYS_MUNMAP  91
%define SYS_MMAP2   192
%define SYS_OPENAT  295

%define AT_FDCWD    0xffffff9c
%define O_RDONLY    0x00000000
%define O_CLOEXEC   0x00080000
%define SEEK_END    2

%define PROT_READ   1
%define MAP_PRIVATE 2
%define MAP_FIXED   0x10
%define MAP_BASE    0x02000000
%define MAP_LEN     0x04000000
%define PAGE_SIZE   4096
%define PAGE_MASK   0xfffff000
%define ERRNO_LOW   0xfffff001
%define ELF_MAGIC   0x464c457f

section .text
start:
    mov eax, SYS_OPENAT
    mov ebx, AT_FDCWD
    mov ecx, path_self
    mov edx, O_RDONLY | O_CLOEXEC
    xor esi, esi
    int 0x80
    test eax, eax
    js fail
    mov [fd], eax

    mov eax, SYS_LSEEK
    mov ebx, [fd]
    xor ecx, ecx
    mov edx, SEEK_END
    int 0x80
    test eax, eax
    js fail_close
    cmp eax, PAGE_SIZE + 1
    jb fail_close
    mov [file_size], eax

    mov ebx, eax
    add ebx, PAGE_SIZE - 1
    and ebx, PAGE_MASK
    cmp ebx, MAP_LEN
    ja fail_close
    mov [file_rounded], ebx

    test eax, PAGE_SIZE - 1
    jz fail_close

    mov eax, SYS_MMAP2
    mov ebx, MAP_BASE
    mov ecx, MAP_LEN
    mov edx, PROT_READ
    mov esi, MAP_PRIVATE | MAP_FIXED
    mov edi, [fd]
    xor ebp, ebp
    int 0x80
    cmp eax, MAP_BASE
    jne fail_close
    mov [map_addr], eax

    cmp dword [eax], ELF_MAGIC
    jne fail_unmap

    mov ebx, [map_addr]
    mov al, [ebx + PAGE_SIZE]
    mov [touch_byte], al

    mov ecx, [file_size]
    shr ecx, 1
    and ecx, PAGE_MASK
    cmp ecx, PAGE_SIZE
    jae .touch_middle
    mov ecx, PAGE_SIZE
.touch_middle:
    mov al, [ebx + ecx]
    xor [touch_byte], al

    mov ecx, [file_size]
    dec ecx
    mov al, [ebx + ecx]
    xor [touch_byte], al

    mov esi, [map_addr]
    add esi, [file_size]
    mov edi, [map_addr]
    add edi, [file_rounded]
.zero_tail:
    cmp esi, edi
    jae .tail_ok
    cmp byte [esi], 0
    jne fail_unmap
    inc esi
    jmp .zero_tail

.tail_ok:
    mov eax, SYS_MUNMAP
    mov ebx, [map_addr]
    mov ecx, MAP_LEN
    int 0x80
    test eax, eax
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
    mov ebx, 37
    int 0x80

fail_unmap:
    mov eax, SYS_MUNMAP
    mov ebx, [map_addr]
    mov ecx, MAP_LEN
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
path_self: db "/BIN/MMAPLG.ELF", 0
ok_msg:   db "mmaplarge ok", 10
ok_len    equ $ - ok_msg
fail_msg: db "mmaplarge fail", 10
fail_len  equ $ - fail_msg

section .bss
fd:           resd 1
file_size:    resd 1
file_rounded: resd 1
map_addr:     resd 1
touch_byte:   resb 1
