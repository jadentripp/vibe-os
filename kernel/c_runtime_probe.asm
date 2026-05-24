BITS 32

%define C_RUNTIME_MAGIC 0xC0DEF00D

section .text

global c_runtime_self_test
global c_runtime_report

extern libc_strlen
extern libc_strcmp
extern libc_abs
extern libc_idivmod
extern kprintf

extern wad_parse_status
extern wad_lump_count
extern playpal_offset
extern playpal_size
extern colormap_offset
extern colormap_size

c_runtime_self_test:
    push ebp
    mov ebp, esp
    sub esp, 4

    mov dword [ebp - 4], -1

    push str_doom
    call libc_strlen
    add esp, 4
    cmp eax, 4
    jne .fail_strlen

    push str_playpal
    push str_playpal
    call libc_strcmp
    add esp, 8
    test eax, eax
    jne .fail_strcmp

    push dword -99
    call libc_abs
    add esp, 4
    cmp eax, 99
    jne .fail_abs

    lea eax, [ebp - 4]
    push eax
    push dword 5
    push dword 42
    call libc_idivmod
    add esp, 12
    cmp eax, 8
    jne .fail_div
    cmp dword [ebp - 4], 2
    jne .fail_div

    cmp byte [wad_parse_status], 1
    jne .fail_wad_parse

    cmp dword [wad_lump_count], 2
    jb .fail_lumps

    cmp dword [playpal_size], 10752
    jne .fail_palette_sizes
    cmp dword [colormap_size], 8704
    jne .fail_palette_sizes

    cmp dword [playpal_offset], 0
    je .fail_palette_offsets
    cmp dword [colormap_offset], 0
    je .fail_palette_offsets

    mov eax, C_RUNTIME_MAGIC
    jmp .done

.fail_strlen:
    mov eax, 1
    jmp .done
.fail_strcmp:
    mov eax, 2
    jmp .done
.fail_abs:
    mov eax, 3
    jmp .done
.fail_div:
    mov eax, 4
    jmp .done
.fail_wad_parse:
    mov eax, 5
    jmp .done
.fail_lumps:
    mov eax, 6
    jmp .done
.fail_palette_sizes:
    mov eax, 7
    jmp .done
.fail_palette_offsets:
    mov eax, 8

.done:
    leave
    ret

c_runtime_report:
    push ebp
    mov ebp, esp
    sub esp, 4

    call c_runtime_self_test
    mov [ebp - 4], eax

    cmp eax, C_RUNTIME_MAGIC
    mov eax, str_fail
    jne .have_status
    mov eax, str_ok
.have_status:
    push eax
    push fmt_probe_status
    call kprintf
    add esp, 8

    push dword [colormap_size]
    push dword [playpal_size]
    push dword [wad_lump_count]
    push fmt_lumps
    call kprintf
    add esp, 16

    push dword [ebp - 4]
    push fmt_magic
    call kprintf
    add esp, 8

    leave
    ret

section .rodata

str_doom db "doom", 0
str_playpal db "PLAYPAL", 0
str_ok db "OK", 0
str_fail db "FAIL", 0
fmt_probe_status db "compiled assembly probe: %s", 13, 10, 0
fmt_lumps db "assembly sees lumps=%u PLAYPAL=%u COLORMAP=%u", 13, 10, 0
fmt_magic db "assembly probe magic: %x", 13, 10, 0
