; mmap_many_probe.asm - Linux i386 many fixed readonly file-backed mmap2 probe.
;
; Opens this staged ELF and registers more MAP_FIXED/PROT_READ file windows than
; the kernel's compact lazy-file record pool can hold. The first batch is partly
; replaced with anonymous fixed maps before the second batch, matching ld.so's
; habit of overlaying file-backed segment tails with zero-fill mappings.
bits 32
global start

%define SYS_EXIT    1
%define SYS_READ    3
%define SYS_WRITE   4
%define SYS_CLOSE   6
%define SYS_LSEEK   19
%define SYS_MUNMAP  91
%define SYS_MMAP2   192
%define SYS_OPENAT  295

%define AT_FDCWD    0xffffff9c
%define O_RDONLY    0x00000000
%define O_CLOEXEC   0x00080000
%define SEEK_SET    0
%define SEEK_END    2

%define PROT_READ   1
%define PROT_WRITE  2
%define MAP_PRIVATE 2
%define MAP_FIXED   0x10
%define MAP_ANONYMOUS 0x20
%define MAP_BASE    0x02000000
%define FOCUS_BASE  0x03000000
%define MAP_LEN     0x00016000
%define FOCUS_LEN   (PAGE_SIZE * 3)
%define MAP_COUNT   72
%define MAP_RECLAIM_AFTER 48
%define MAP_RECLAIM_COUNT 24
%define MAP_STRIDE_SHIFT 17
%define PAGE_SIZE   4096
%define MIN_FILE_SIZE (PAGE_SIZE * 2 + 4)
%define ELF_MAGIC   0x464c457f

section .text
start:
    mov dword [fd], -1
    mov dword [mapped_count], 0

    mov eax, SYS_OPENAT
    mov ebx, AT_FDCWD
    mov ecx, path_self
    mov edx, O_RDONLY | O_CLOEXEC
    xor esi, esi
    int 0x80
    test eax, eax
    js fail_open
    mov [fd], eax

    mov eax, SYS_LSEEK
    mov ebx, [fd]
    xor ecx, ecx
    mov edx, SEEK_END
    int 0x80
    test eax, eax
    js fail_size
    cmp eax, MIN_FILE_SIZE
    jb fail_size

    call fixed_file_remap_probe
    jc fail_fixed_remap

.map_loop:
    mov eax, [mapped_count]
    cmp eax, MAP_RECLAIM_AFTER
    jae .touch_reclaim_seed
    call map_file_slot
    jc fail_map

    inc dword [mapped_count]
    jmp .map_loop

.touch_reclaim_seed:
    cmp dword [MAP_BASE], ELF_MAGIC
    jne fail_touch
    mov dword [reclaim_index], 0

.reclaim_loop:
    mov eax, [reclaim_index]
    cmp eax, MAP_RECLAIM_COUNT
    jae .map_more_loop
    mov ebx, eax
    shl ebx, MAP_STRIDE_SHIFT
    add ebx, MAP_BASE
    mov [expected_addr], ebx

    mov eax, SYS_MMAP2
    mov ecx, MAP_LEN
    mov edx, PROT_READ | PROT_WRITE
    mov esi, MAP_PRIVATE | MAP_FIXED | MAP_ANONYMOUS
    mov edi, -1
    xor ebp, ebp
    int 0x80
    cmp eax, [expected_addr]
    jne fail_anon_addr
    mov ebx, [expected_addr]
    cmp dword [ebx], 0
    jne fail_anon_zero

    inc dword [reclaim_index]
    jmp .reclaim_loop

.map_more_loop:
    mov eax, [mapped_count]
    cmp eax, MAP_COUNT
    jae touch_maps
    call map_file_slot
    jc fail_map

    inc dword [mapped_count]
    jmp .map_more_loop

map_file_slot:
    mov ebx, eax
    shl ebx, MAP_STRIDE_SHIFT
    add ebx, MAP_BASE
    mov [expected_addr], ebx

    mov eax, SYS_MMAP2
    mov ecx, MAP_LEN
    mov edx, PROT_READ
    mov esi, MAP_PRIVATE | MAP_FIXED
    mov edi, [fd]
    mov ebp, [mapped_count]
    and ebp, 1
    int 0x80
    cmp eax, [expected_addr]
    jne .fail

    clc
    ret

.fail:
    stc
    ret

fixed_file_remap_probe:
    mov eax, SYS_LSEEK
    mov ebx, [fd]
    mov ecx, PAGE_SIZE * 2
    mov edx, SEEK_SET
    int 0x80
    cmp eax, PAGE_SIZE * 2
    jne .fail

    mov eax, SYS_READ
    mov ebx, [fd]
    mov ecx, focus_tail_word
    mov edx, 4
    int 0x80
    cmp eax, 4
    jne .fail

    mov eax, SYS_MMAP2
    mov ebx, FOCUS_BASE
    mov ecx, PAGE_SIZE
    mov edx, PROT_READ
    mov esi, MAP_PRIVATE | MAP_FIXED
    mov edi, [fd]
    xor ebp, ebp
    int 0x80
    cmp eax, FOCUS_BASE
    jne fail_fixed_first
    cmp dword [FOCUS_BASE], ELF_MAGIC
    jne fail_fixed_first

    mov eax, SYS_MMAP2
    mov ebx, FOCUS_BASE
    mov ecx, PAGE_SIZE
    mov edx, PROT_READ
    mov esi, MAP_PRIVATE | MAP_FIXED
    mov edi, [fd]
    mov ebp, 1
    int 0x80
    cmp eax, FOCUS_BASE
    jne fail_fixed_second
    cmp dword [FOCUS_BASE], ELF_MAGIC
    je fail_fixed_second

    mov eax, SYS_MUNMAP
    mov ebx, FOCUS_BASE
    mov ecx, PAGE_SIZE
    int 0x80
    test eax, eax
    jne fail_fixed_unmap

    mov eax, SYS_MMAP2
    mov ebx, FOCUS_BASE
    mov ecx, FOCUS_LEN
    mov edx, PROT_READ
    mov esi, MAP_PRIVATE | MAP_FIXED
    mov edi, [fd]
    xor ebp, ebp
    int 0x80
    cmp eax, FOCUS_BASE
    jne .fail
    cmp dword [FOCUS_BASE], ELF_MAGIC
    jne .fail

    mov eax, SYS_MMAP2
    mov ebx, FOCUS_BASE + PAGE_SIZE
    mov ecx, PAGE_SIZE
    mov edx, PROT_READ
    mov esi, MAP_PRIVATE | MAP_FIXED
    mov edi, [fd]
    xor ebp, ebp
    int 0x80
    cmp eax, FOCUS_BASE + PAGE_SIZE
    jne .fail
    cmp dword [FOCUS_BASE], ELF_MAGIC
    jne .fail
    cmp dword [FOCUS_BASE + PAGE_SIZE], ELF_MAGIC
    jne .fail
    mov eax, [FOCUS_BASE + PAGE_SIZE * 2]
    cmp eax, [focus_tail_word]
    jne fail_fixed_tail
    mov al, [FOCUS_BASE + PAGE_SIZE * 2]
    xor [touch_byte], al

    mov eax, SYS_MUNMAP
    mov ebx, FOCUS_BASE
    mov ecx, FOCUS_LEN
    int 0x80
    test eax, eax
    jne fail_fixed_unmap
    clc
    ret

.fail:
    stc
    ret

touch_maps:
    mov ebx, MAP_RECLAIM_COUNT
    shl ebx, MAP_STRIDE_SHIFT
    add ebx, MAP_BASE
    cmp dword [ebx], ELF_MAGIC
    jne fail_touch

    xor ecx, ecx
.touch_loop:
    cmp ecx, MAP_COUNT
    jae .success

    mov ebx, ecx
    shl ebx, MAP_STRIDE_SHIFT
    add ebx, MAP_BASE

    cmp ecx, MAP_RECLAIM_COUNT
    jb .touch_anon

    mov al, [ebx]
    xor [touch_byte], al

    test ecx, 1
    jnz .next_touch
    mov al, [ebx + PAGE_SIZE]
    xor [touch_byte], al
    jmp .next_touch

.touch_anon:
    mov byte [ebx], 0x5a
    cmp byte [ebx], 0x5a
    jne fail_touch

.next_touch:
    inc ecx
    jmp .touch_loop

.success:
    call unmap_many
    jc fail_unmap

    mov eax, SYS_CLOSE
    mov ebx, [fd]
    int 0x80
    test eax, eax
    jne fail_close
    mov dword [fd], -1

    mov eax, SYS_WRITE
    mov ebx, 1
    mov ecx, ok_msg
    mov edx, ok_len
    int 0x80

    mov eax, SYS_EXIT
    mov ebx, 53
    int 0x80

unmap_many:
    mov dword [unmap_failed], 0
.unmap_loop:
    cmp dword [mapped_count], 0
    je .done

    dec dword [mapped_count]
    mov ebx, [mapped_count]
    shl ebx, MAP_STRIDE_SHIFT
    add ebx, MAP_BASE
    mov eax, SYS_MUNMAP
    mov ecx, MAP_LEN
    int 0x80
    test eax, eax
    je .unmap_loop
    mov dword [unmap_failed], 1
    jmp .unmap_loop

.done:
    cmp dword [unmap_failed], 0
    jne .fail
    clc
    ret

.fail:
    stc
    ret

fail_open:
    mov ecx, fail_open_msg
    mov edx, fail_open_len
    jmp fail

fail_size:
    mov ecx, fail_size_msg
    mov edx, fail_size_len
    jmp fail

fail_map:
    mov ecx, fail_map_msg
    mov edx, fail_map_len
    jmp fail

fail_anon:
    mov ecx, fail_anon_msg
    mov edx, fail_anon_len
    jmp fail

fail_anon_addr:
    mov ecx, fail_anon_addr_msg
    mov edx, fail_anon_addr_len
    jmp fail

fail_anon_zero:
    mov ecx, fail_anon_zero_msg
    mov edx, fail_anon_zero_len
    jmp fail

fail_touch:
    mov ecx, fail_touch_msg
    mov edx, fail_touch_len
    jmp fail

fail_fixed_remap:
    mov ecx, fail_fixed_remap_msg
    mov edx, fail_fixed_remap_len
    jmp fail

fail_fixed_first:
    mov ecx, fail_fixed_first_msg
    mov edx, fail_fixed_first_len
    jmp fail

fail_fixed_second:
    mov ecx, fail_fixed_second_msg
    mov edx, fail_fixed_second_len
    jmp fail

fail_fixed_tail:
    mov ecx, fail_fixed_tail_msg
    mov edx, fail_fixed_tail_len
    jmp fail

fail_fixed_unmap:
    mov ecx, fail_fixed_unmap_msg
    mov edx, fail_fixed_unmap_len
    jmp fail

fail_unmap:
    mov ecx, fail_unmap_msg
    mov edx, fail_unmap_len
    jmp fail_no_cleanup

fail_close:
    mov ecx, fail_close_msg
    mov edx, fail_close_len
    jmp fail_no_cleanup

fail:
    mov [fail_msg_ptr], ecx
    mov [fail_msg_len], edx
    mov eax, SYS_MUNMAP
    mov ebx, FOCUS_BASE
    mov ecx, FOCUS_LEN
    int 0x80
    call unmap_many
    cmp dword [fd], 0
    jl .write_fail
    mov eax, SYS_CLOSE
    mov ebx, [fd]
    int 0x80
    mov dword [fd], -1

.write_fail:
    mov ecx, [fail_msg_ptr]
    mov edx, [fail_msg_len]

fail_no_cleanup:
    mov eax, SYS_WRITE
    mov ebx, 1
    int 0x80
    mov eax, SYS_EXIT
    mov ebx, 1
    int 0x80

section .data
path_self: db "/BIN/MMAPMNY.ELF", 0
ok_msg:   db "mmapmany ok: fixed file remaps and 72 ro maps touched", 10
ok_len    equ $ - ok_msg
fail_open_msg:  db "mmapmany fail: open", 10
fail_open_len   equ $ - fail_open_msg
fail_size_msg:  db "mmapmany fail: self image too small", 10
fail_size_len   equ $ - fail_size_msg
fail_map_msg:   db "mmapmany fail: mmap2", 10
fail_map_len    equ $ - fail_map_msg
fail_anon_msg:  db "mmapmany fail: anon mmap2", 10
fail_anon_len   equ $ - fail_anon_msg
fail_anon_addr_msg:  db "mmapmany fail: anon mmap2 addr", 10
fail_anon_addr_len   equ $ - fail_anon_addr_msg
fail_anon_zero_msg:  db "mmapmany fail: anon mmap2 zero", 10
fail_anon_zero_len   equ $ - fail_anon_zero_msg
fail_touch_msg: db "mmapmany fail: touch", 10
fail_touch_len  equ $ - fail_touch_msg
fail_fixed_remap_msg: db "mmapmany fail: fixed file remap", 10
fail_fixed_remap_len  equ $ - fail_fixed_remap_msg
fail_fixed_first_msg: db "mmapmany fail: fixed first map", 10
fail_fixed_first_len  equ $ - fail_fixed_first_msg
fail_fixed_second_msg: db "mmapmany fail: fixed second map", 10
fail_fixed_second_len  equ $ - fail_fixed_second_msg
fail_fixed_tail_msg: db "mmapmany fail: fixed tail", 10
fail_fixed_tail_len  equ $ - fail_fixed_tail_msg
fail_fixed_unmap_msg: db "mmapmany fail: fixed unmap", 10
fail_fixed_unmap_len  equ $ - fail_fixed_unmap_msg
fail_unmap_msg: db "mmapmany fail: munmap", 10
fail_unmap_len  equ $ - fail_unmap_msg
fail_close_msg: db "mmapmany fail: close", 10
fail_close_len  equ $ - fail_close_msg

section .bss
fd:            resd 1
mapped_count:  resd 1
reclaim_index: resd 1
expected_addr: resd 1
fail_msg_ptr:  resd 1
fail_msg_len:  resd 1
unmap_failed:  resd 1
touch_byte:    resb 1
alignb 4
focus_tail_word: resd 1
