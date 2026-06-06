; ldso_reloc_probe.asm - Linux i386 Chromium relocation-table probe.
;
; Static guest probe for the ld.so frontier where glibc expects every entry
; covered by DT_RELCOUNT to be R_386_RELATIVE. It opens the staged Chromium ELF,
; parses PT_DYNAMIC, translates DT_REL through PT_LOAD, then reads and checks the
; guest-visible relocation table with pread64.
bits 32
global start

%define SYS_EXIT    1
%define SYS_WRITE   4
%define SYS_CLOSE   6
%define SYS_MUNMAP  91
%define SYS_MPROTECT 125
%define SYS_PREAD64 180
%define SYS_MMAP2   192
%define SYS_OPENAT  295

%define AT_FDCWD    0xffffff9c
%define O_RDONLY    0x00000000
%define O_CLOEXEC   0x00080000
%define PROT_READ   0x00000001
%define MAP_PRIVATE 0x00000002
%define MAP_FIXED   0x00000010

%define ELF_MAGIC       0x464c457f
%define ELFCLASS32      1
%define ELFDATA2LSB     1
%define EV_CURRENT      1
%define ET_EXEC         2
%define ET_DYN          3
%define EM_386          3
%define ELF32_EHDR_SIZE 52
%define ELF32_PHDR_SIZE 32
%define PHDR_MAX        64
%define DYN_BUF_SIZE    4096
%define REL_BUF_SIZE    4096
%define REL_CHUNK_ENTS  512
%define MMAP_PRESSURE_BASE        0x02000000
%define MMAP_PRESSURE_LEN         0x01000000
%define MMAP_PRESSURE_FILE_OFFSET 0x08000000
%define MMAP_PRESSURE_PGOFF       0x00008000

%define PT_LOAD     1
%define PT_DYNAMIC  2

%define DT_NULL     0
%define DT_REL      17
%define DT_RELSZ    18
%define DT_RELENT   19
%define DT_RELCOUNT 0x6ffffffa

%define R_386_RELATIVE 8

%macro FAIL 1
    mov byte [fail_code], %1
    jmp fail
%endmacro

section .text
start:
    mov dword [fd], -1
    mov eax, SYS_OPENAT
    mov ebx, AT_FDCWD
    mov ecx, chromium_path
    mov edx, O_RDONLY | O_CLOEXEC
    xor esi, esi
    int 0x80
    test eax, eax
    js .open_fail
    mov [fd], eax

    mov ecx, ehdr_buf
    mov edx, ELF32_EHDR_SIZE
    xor esi, esi
    call pread_exact
    jc .ehdr_read_fail
    call verify_ehdr
    jc .ehdr_fail

    call read_program_headers
    jc .phdr_fail
    call find_dynamic
    jc .dynamic_phdr_fail
    call read_dynamic
    jc .dynamic_read_fail
    call scan_dynamic
    jc .dynamic_tag_fail
    call validate_reloc_tags
    jc .rel_tag_fail
    call check_relative_relocs
    jc .rel_scan_fail
    call check_chromium_mmap_pressure
    jc .mmap_pressure_fail

    call print_summary

    mov eax, SYS_WRITE
    mov ebx, 1
    mov ecx, ok_msg
    mov edx, ok_len
    int 0x80

    call close_if_open

    mov eax, SYS_EXIT
    mov ebx, 32
    int 0x80

.open_fail:
    FAIL 0x01
.ehdr_read_fail:
    FAIL 0x02
.ehdr_fail:
    FAIL 0x03
.phdr_fail:
    FAIL 0x04
.dynamic_phdr_fail:
    FAIL 0x05
.dynamic_read_fail:
    FAIL 0x06
.dynamic_tag_fail:
    FAIL 0x07
.rel_tag_fail:
    FAIL 0x08
.rel_scan_fail:
    FAIL 0x09
.mmap_pressure_fail:
    FAIL 0x0a

fail:
    movzx eax, byte [fail_code]
    mov edi, fail_code_hex
    call write_hex8

    movzx eax, byte [bad_type]
    mov edi, fail_type_hex
    call write_hex8

    mov eax, [bad_index]
    mov edi, fail_index_hex
    call write_hex32

    mov eax, SYS_WRITE
    mov ebx, 1
    mov ecx, fail_msg
    mov edx, fail_len
    int 0x80

    call close_if_open

    mov eax, SYS_EXIT
    mov ebx, 1
    int 0x80

pread_exact:
    mov [pread_expected], edx
    mov eax, SYS_PREAD64
    mov ebx, [fd]
    xor edi, edi
    int 0x80
    cmp eax, [pread_expected]
    jne .fail
    clc
    ret

.fail:
    stc
    ret

check_chromium_mmap_pressure:
    mov ecx, mmap_head_buf
    mov edx, 4
    mov esi, MMAP_PRESSURE_FILE_OFFSET
    call pread_exact
    jc .fail

    mov eax, SYS_MMAP2
    mov ebx, MMAP_PRESSURE_BASE
    mov ecx, MMAP_PRESSURE_LEN
    mov edx, PROT_READ
    mov esi, MAP_PRIVATE | MAP_FIXED
    mov edi, [fd]
    mov ebp, MMAP_PRESSURE_PGOFF
    int 0x80
    cmp eax, MMAP_PRESSURE_BASE
    jne .fail

    mov eax, [mmap_head_buf]
    cmp eax, [MMAP_PRESSURE_BASE]
    jne .fail_unmap

    mov ecx, mmap_tail_buf
    mov edx, 4
    mov esi, MMAP_PRESSURE_FILE_OFFSET + MMAP_PRESSURE_LEN - 4
    call pread_exact
    jc .fail_unmap

    mov eax, [mmap_tail_buf]
    cmp eax, [MMAP_PRESSURE_BASE + MMAP_PRESSURE_LEN - 4]
    jne .fail_unmap

    mov eax, SYS_MPROTECT
    mov ebx, MMAP_PRESSURE_BASE
    mov ecx, MMAP_PRESSURE_LEN
    mov edx, PROT_READ
    int 0x80
    test eax, eax
    jne .fail_unmap

    mov eax, SYS_MUNMAP
    mov ebx, MMAP_PRESSURE_BASE
    mov ecx, MMAP_PRESSURE_LEN
    int 0x80
    test eax, eax
    jne .fail

    clc
    ret

.fail_unmap:
    mov eax, SYS_MUNMAP
    mov ebx, MMAP_PRESSURE_BASE
    mov ecx, MMAP_PRESSURE_LEN
    int 0x80

.fail:
    stc
    ret

close_if_open:
    cmp dword [fd], 0
    jl .done
    mov eax, SYS_CLOSE
    mov ebx, [fd]
    int 0x80
    mov dword [fd], -1

.done:
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
    je .type_ok
    cmp word [ehdr_buf + 16], ET_EXEC
    jne .fail
.type_ok:
    cmp word [ehdr_buf + 18], EM_386
    jne .fail
    cmp word [ehdr_buf + 40], ELF32_EHDR_SIZE
    jne .fail
    cmp word [ehdr_buf + 42], ELF32_PHDR_SIZE
    jne .fail
    clc
    ret

.fail:
    stc
    ret

read_program_headers:
    movzx eax, word [ehdr_buf + 44]
    test eax, eax
    jz .fail
    cmp eax, PHDR_MAX
    ja .fail
    mov [phnum], eax
    shl eax, 5
    mov edx, eax
    mov ecx, phdr_buf
    mov esi, [ehdr_buf + 28]
    call pread_exact
    jc .fail
    clc
    ret

.fail:
    stc
    ret

find_dynamic:
    mov esi, phdr_buf
    mov ecx, [phnum]
    xor eax, eax
    mov [dyn_offset], eax
    mov [dyn_size], eax

.loop:
    cmp dword [esi], PT_DYNAMIC
    jne .next
    mov eax, [esi + 4]
    mov [dyn_offset], eax
    mov eax, [esi + 16]
    mov [dyn_size], eax
    jmp .found

.next:
    add esi, ELF32_PHDR_SIZE
    dec ecx
    jnz .loop

.found:
    cmp dword [dyn_size], 0
    je .fail
    cmp dword [dyn_size], DYN_BUF_SIZE
    ja .fail
    test dword [dyn_size], 7
    jnz .fail
    clc
    ret

.fail:
    stc
    ret

read_dynamic:
    mov ecx, dyn_buf
    mov edx, [dyn_size]
    mov esi, [dyn_offset]
    call pread_exact
    ret

scan_dynamic:
    xor eax, eax
    mov [dt_rel], eax
    mov [dt_relsz], eax
    mov [dt_relent], eax
    mov [dt_relcount], eax

    mov esi, dyn_buf
    mov ecx, [dyn_size]
    shr ecx, 3

.loop:
    cmp ecx, 0
    je .done
    mov eax, [esi]
    test eax, eax
    jz .done
    cmp eax, DT_REL
    je .tag_rel
    cmp eax, DT_RELSZ
    je .tag_relsz
    cmp eax, DT_RELENT
    je .tag_relent
    cmp eax, DT_RELCOUNT
    je .tag_relcount
    jmp .next

.tag_rel:
    mov eax, [esi + 4]
    mov [dt_rel], eax
    jmp .next

.tag_relsz:
    mov eax, [esi + 4]
    mov [dt_relsz], eax
    jmp .next

.tag_relent:
    mov eax, [esi + 4]
    mov [dt_relent], eax
    jmp .next

.tag_relcount:
    mov eax, [esi + 4]
    mov [dt_relcount], eax

.next:
    add esi, 8
    dec ecx
    jmp .loop

.done:
    cmp dword [dt_rel], 0
    je .fail
    cmp dword [dt_relsz], 0
    je .fail
    cmp dword [dt_relent], 8
    jne .fail
    cmp dword [dt_relcount], 0
    je .fail
    clc
    ret

.fail:
    stc
    ret

validate_reloc_tags:
    mov eax, [dt_relsz]
    test eax, 7
    jnz .fail
    shr eax, 3
    mov [total_rel_entries], eax
    cmp dword [dt_relcount], eax
    ja .fail

    mov eax, [dt_rel]
    call vaddr_to_file_offset
    jc .fail
    mov [rel_file_offset], eax

    clc
    ret

.fail:
    stc
    ret

vaddr_to_file_offset:
    mov [vaddr_query], eax
    mov esi, phdr_buf
    mov ecx, [phnum]

.loop:
    cmp dword [esi], PT_LOAD
    jne .next
    mov eax, [vaddr_query]
    mov ebx, [esi + 8]
    cmp eax, ebx
    jb .next
    mov edx, [esi + 16]
    add edx, ebx
    cmp eax, edx
    jae .next
    sub eax, ebx
    add eax, [esi + 4]
    clc
    ret

.next:
    add esi, ELF32_PHDR_SIZE
    dec ecx
    jnz .loop
    stc
    ret

check_relative_relocs:
    xor eax, eax
    mov [scan_index], eax
    mov [bad_index], eax
    mov [first_type], eax
    mov [last_type], eax
    mov [bad_type], eax
    mov dword [after_type], 0xffffffff

    mov eax, [dt_relcount]
    mov [scan_remaining], eax
    mov eax, [rel_file_offset]
    mov [current_rel_offset], eax

.chunk_loop:
    cmp dword [scan_remaining], 0
    je .checked_relcount

    mov eax, [scan_remaining]
    cmp eax, REL_CHUNK_ENTS
    jbe .chunk_ready
    mov eax, REL_CHUNK_ENTS

.chunk_ready:
    mov [chunk_entries], eax
    shl eax, 3
    mov [chunk_bytes], eax

    mov ecx, rel_buf
    mov edx, [chunk_bytes]
    mov esi, [current_rel_offset]
    call pread_exact
    jc .fail

    mov esi, rel_buf
    mov ecx, [chunk_entries]

.entry_loop:
    mov eax, [esi + 4]
    and eax, 0xff
    cmp dword [scan_index], 0
    jne .not_first
    mov [first_type], eax

.not_first:
    mov [last_type], eax
    cmp eax, R_386_RELATIVE
    jne .bad_reloc

    add esi, 8
    inc dword [scan_index]
    dec ecx
    jnz .entry_loop

    mov eax, [chunk_bytes]
    add [current_rel_offset], eax
    mov eax, [chunk_entries]
    sub [scan_remaining], eax
    jmp .chunk_loop

.checked_relcount:
    mov eax, [dt_relcount]
    cmp eax, [total_rel_entries]
    jae .done
    shl eax, 3
    add eax, [rel_file_offset]
    mov ecx, one_rel_buf
    mov edx, 8
    mov esi, eax
    call pread_exact
    jc .fail
    mov eax, [one_rel_buf + 4]
    and eax, 0xff
    mov [after_type], eax

.done:
    clc
    ret

.bad_reloc:
    mov [bad_type], eax
    mov eax, [scan_index]
    mov [bad_index], eax

.fail:
    stc
    ret

print_summary:
    mov eax, [dt_rel]
    mov edi, summary_rel_hex
    call write_hex32

    mov eax, [dt_relsz]
    mov edi, summary_relsz_hex
    call write_hex32

    mov eax, [dt_relcount]
    mov edi, summary_relcount_hex
    call write_hex32

    mov eax, [first_type]
    mov edi, summary_first_hex
    call write_hex8

    mov eax, [last_type]
    mov edi, summary_last_hex
    call write_hex8

    mov eax, [after_type]
    mov edi, summary_after_hex
    call write_hex8

    mov eax, SYS_WRITE
    mov ebx, 1
    mov ecx, summary_msg
    mov edx, summary_len
    int 0x80
    ret

write_hex32:
    push ebx
    push ecx
    push edx
    mov ecx, 8

.digit:
    rol eax, 4
    mov edx, eax
    and edx, 0x0f
    mov bl, [hex_digits + edx]
    mov [edi], bl
    inc edi
    loop .digit

    pop edx
    pop ecx
    pop ebx
    ret

write_hex8:
    push eax
    push ebx
    push edx
    mov ebx, eax
    shr eax, 4
    and eax, 0x0f
    mov dl, [hex_digits + eax]
    mov [edi], dl
    mov eax, ebx
    and eax, 0x0f
    mov dl, [hex_digits + eax]
    mov [edi + 1], dl
    pop edx
    pop ebx
    pop eax
    ret

section .data
chromium_path: db "/BIN/CHROMIUM.ELF", 0

summary_msg: db "ldso reloc rel=0x"
summary_rel_hex: db "00000000"
             db " relsz=0x"
summary_relsz_hex: db "00000000"
             db " relcnt=0x"
summary_relcount_hex: db "00000000"
             db " first=0x"
summary_first_hex: db "00"
             db " last=0x"
summary_last_hex: db "00"
             db " after=0x"
summary_after_hex: db "00", 10
summary_len equ $ - summary_msg

ok_msg: db "ldso reloc ok", 10
ok_len equ $ - ok_msg

fail_msg: db "ldso reloc fail code=0x"
fail_code_hex: db "00"
          db " bad_index=0x"
fail_index_hex: db "00000000"
          db " bad_type=0x"
fail_type_hex: db "00", 10
fail_len equ $ - fail_msg

hex_digits: db "0123456789abcdef"

section .bss
fd:                 resd 1
pread_expected:     resd 1
phnum:              resd 1
dyn_offset:         resd 1
dyn_size:           resd 1
dt_rel:             resd 1
dt_relsz:           resd 1
dt_relent:          resd 1
dt_relcount:        resd 1
total_rel_entries:  resd 1
rel_file_offset:    resd 1
vaddr_query:        resd 1
scan_remaining:     resd 1
scan_index:         resd 1
current_rel_offset: resd 1
chunk_entries:      resd 1
chunk_bytes:        resd 1
first_type:         resd 1
last_type:          resd 1
after_type:         resd 1
bad_index:          resd 1
bad_type:           resd 1
fail_code:          resb 1
ehdr_buf:           resb ELF32_EHDR_SIZE
phdr_buf:           resb PHDR_MAX * ELF32_PHDR_SIZE
dyn_buf:            resb DYN_BUF_SIZE
rel_buf:            resb REL_BUF_SIZE
one_rel_buf:        resb 8
mmap_head_buf:      resb 4
mmap_tail_buf:      resb 4
