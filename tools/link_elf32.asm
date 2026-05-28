default rel

%ifdef MACHO64
%define C(name) _ %+ name
%define MAIN _main
%else
%define C(name) name
%define MAIN main
%endif

%define SHT_SYMTAB 2
%define SHT_NOBITS 8
%define SHT_REL 9
%define SHF_WRITE 1
%define SHF_ALLOC 2
%define SHF_EXECINSTR 4
%define SHN_UNDEF 0
%define SHN_COMMON 0xfff2
%define R_386_32 1
%define R_386_PC32 2
%define ELF_HEADER_SIZE 52
%define PROGRAM_HEADER_SIZE 32
%define SEGMENT_OFFSET 0x1000
%define PAGE_SIZE 0x1000
%define PF_X 1
%define PF_W 2
%define PF_R 4

%define OBJ_path 0
%define OBJ_data 8
%define OBJ_size 16
%define OBJ_sections 24
%define OBJ_section_count 32
%define OBJ_symbols 40
%define OBJ_symbol_count 48
%define OBJ_SIZE 72

%define SEC_obj 0
%define SEC_index 8
%define SEC_name 16
%define SEC_type 24
%define SEC_flags 28
%define SEC_offset 32
%define SEC_size 36
%define SEC_align 40
%define SEC_link 44
%define SEC_info 48
%define SEC_entsize 52
%define SEC_out_addr 56
%define SEC_mem_off 60
%define SEC_segment 64
%define SEC_SIZE 72

%define SYM_obj 0
%define SYM_index 8
%define SYM_name 16
%define SYM_value 24
%define SYM_size 28
%define SYM_info 32
%define SYM_shndx 34
%define SYM_SIZE 40

%define SEG_flags 0
%define SEG_mem_off 4
%define SEG_vaddr 8
%define SEG_filesz 12
%define SEG_memsz 16
%define SEG_offset 20
%define SEG_SIZE 24

%define VEC_items 0
%define VEC_count 8
%define VEC_cap 16
%define VEC_SIZE 24

%define GLOB_name 0
%define GLOB_symbol 8
%define GLOB_SIZE 16

section .text
global MAIN
extern C(calloc)
extern C(realloc)
extern C(free)
extern C(strlen)
extern C(memcpy)
extern C(memset)
extern C(memcmp)
extern C(strcmp)
extern C(fopen)
extern C(fseek)
extern C(ftell)
extern C(fread)
extern C(fwrite)
extern C(fclose)
extern C(printf)
extern C(fprintf)
extern C(strtoul)
extern C(exit)

MAIN:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov r14d, edi
    mov r15, rsi
    mov qword [rel output_path], 0
    mov qword [rel map_path], 0
    mov dword [rel have_base], 0
    mov edi, r14d
    mov esi, 8
    call xcalloc
    mov [rel input_paths], rax
    mov qword [rel input_count], 0
    mov ebx, 1
.arg_loop:
    cmp ebx, r14d
    jge .args_done
    mov r12, [r15 + rbx * 8]
    mov rdi, r12
    lea rsi, [rel opt_o]
    call C(strcmp)
    test eax, eax
    jne .not_o
    inc ebx
    cmp ebx, r14d
    jl .have_o_arg
    lea rdi, [rel msg_o_requires]
    call die
.have_o_arg:
    mov rax, [r15 + rbx * 8]
    mov [rel output_path], rax
    inc ebx
    jmp .arg_loop
.not_o:
    mov rdi, r12
    lea rsi, [rel opt_base]
    call C(strcmp)
    test eax, eax
    jne .not_base
    inc ebx
    cmp ebx, r14d
    jl .have_base_arg
    lea rdi, [rel msg_base_requires]
    call die
.have_base_arg:
    mov rdi, [r15 + rbx * 8]
    call parse_u32_arg
    mov [rel base_addr], eax
    mov dword [rel have_base], 1
    inc ebx
    jmp .arg_loop
.not_base:
    mov rdi, r12
    lea rsi, [rel opt_map]
    call C(strcmp)
    test eax, eax
    jne .not_map
    inc ebx
    cmp ebx, r14d
    jl .have_map_arg
    lea rdi, [rel msg_map_requires]
    call die
.have_map_arg:
    mov rax, [r15 + rbx * 8]
    mov [rel map_path], rax
    inc ebx
    jmp .arg_loop
.not_map:
    cmp byte [r12], '-'
    jne .input
    lea rdi, [rel msg_unknown_option]
    call die
.input:
    mov rax, [rel input_count]
    mov rcx, [rel input_paths]
    mov [rcx + rax * 8], r12
    inc rax
    mov [rel input_count], rax
    inc ebx
    jmp .arg_loop
.args_done:
    cmp qword [rel output_path], 0
    je .usage
    cmp dword [rel have_base], 0
    je .usage
    cmp qword [rel input_count], 0
    jne .parse_inputs
.usage:
    lea rdi, [rel usage_text]
    xor eax, eax
    call C(printf)
    mov eax, 1
    jmp .return
.parse_inputs:
    mov rdi, [rel input_count]
    mov esi, OBJ_SIZE
    call xcalloc
    mov [rel objects], rax
    xor ebx, ebx
.parse_loop:
    cmp rbx, [rel input_count]
    jae .build
    mov rdi, rbx
    imul rdi, OBJ_SIZE
    add rdi, [rel objects]
    mov rcx, [rel input_paths]
    mov rsi, [rcx + rbx * 8]
    call parse_object
    inc rbx
    jmp .parse_loop
.build:
    call build_executable
    mov rdi, [rel output_path]
    mov rsi, [rel elf_buffer]
    mov rdx, [rel elf_size]
    call write_file
    cmp qword [rel map_path], 0
    je .ok
    call write_symbol_map
.ok:
    xor eax, eax
.return:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

die:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    mov rsi, rdi
    lea rdi, [rel die_fmt]
    xor eax, eax
    call C(printf)
    mov edi, 1
    call C(exit)

xcalloc:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    call C(calloc)
    test rax, rax
    jnz .ok
    lea rdi, [rel msg_oom]
    call die
.ok:
    leave
    ret

xrealloc:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    call C(realloc)
    test rax, rax
    jnz .ok
    lea rdi, [rel msg_oom]
    call die
.ok:
    leave
    ret

xstrdup0:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov r12, rdi
    call C(strlen)
    mov rbx, rax
    lea rdi, [rbx + 1]
    mov esi, 1
    call xcalloc
    mov rdi, rax
    mov rsi, r12
    mov rdx, rbx
    mov r12, rax
    call C(memcpy)
    mov rax, r12
    pop r12
    pop rbx
    pop rbp
    ret

xstrdup_range:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov r12, rdi
    mov r13, rsi
    mov r14, rdx
    cmp r14, r13
    jb .scan
    lea rdi, [rel empty_string]
    call xstrdup0
    jmp .return
.scan:
    mov rbx, r14
.scan_loop:
    cmp rbx, r13
    jae .copy
    cmp byte [r12 + rbx], 0
    je .copy
    inc rbx
    jmp .scan_loop
.copy:
    mov rdi, rbx
    sub rdi, r14
    mov rbx, rdi
    inc rdi
    mov esi, 1
    call xcalloc
    mov rdi, rax
    lea rsi, [r12 + r14]
    mov rdx, rbx
    mov r14, rax
    call C(memcpy)
    mov rax, r14
.return:
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

align_up:
    mov eax, edi
    cmp esi, 1
    jbe .done
    lea ecx, [rsi - 1]
    add eax, ecx
    not ecx
    and eax, ecx
.done:
    ret

u16:
    mov rax, rdx
    add rax, 2
    cmp rax, rsi
    jbe .ok
    lea rdi, [rel msg_eof]
    call die
.ok:
    movzx eax, byte [rdi + rdx]
    movzx ecx, byte [rdi + rdx + 1]
    shl ecx, 8
    or eax, ecx
    ret

u32:
    mov rax, rdx
    add rax, 4
    cmp rax, rsi
    jbe .ok
    lea rdi, [rel msg_eof]
    call die
.ok:
    movzx eax, byte [rdi + rdx]
    movzx ecx, byte [rdi + rdx + 1]
    shl ecx, 8
    or eax, ecx
    movzx ecx, byte [rdi + rdx + 2]
    shl ecx, 16
    or eax, ecx
    movzx ecx, byte [rdi + rdx + 3]
    shl ecx, 24
    or eax, ecx
    ret

put_u16:
    mov rax, rdx
    add rax, 2
    cmp rax, rsi
    jbe .ok
    lea rdi, [rel msg_write_past]
    call die
.ok:
    mov [rdi + rdx], cl
    shr ecx, 8
    mov [rdi + rdx + 1], cl
    ret

put_u32:
    mov rax, rdx
    add rax, 4
    cmp rax, rsi
    jbe .ok
    lea rdi, [rel msg_write_past]
    call die
.ok:
    mov eax, ecx
    mov [rdi + rdx], al
    shr eax, 8
    mov [rdi + rdx + 1], al
    shr eax, 8
    mov [rdi + rdx + 2], al
    shr eax, 8
    mov [rdi + rdx + 3], al
    ret

read_file:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov r12, rdi
    lea rsi, [rel mode_rb]
    call C(fopen)
    test rax, rax
    jnz .opened
    lea rdi, [rel msg_open]
    call die
.opened:
    mov rbx, rax
    mov rdi, rbx
    xor esi, esi
    mov edx, 2
    call C(fseek)
    test eax, eax
    je .seeked
    lea rdi, [rel msg_seek]
    call die
.seeked:
    mov rdi, rbx
    call C(ftell)
    test rax, rax
    jns .sized
    lea rdi, [rel msg_tell]
    call die
.sized:
    mov r13, rax
    mov rdi, rbx
    xor esi, esi
    xor edx, edx
    call C(fseek)
    test eax, eax
    je .rewound
    lea rdi, [rel msg_seek]
    call die
.rewound:
    mov rdi, r13
    test rdi, rdi
    jnz .alloc
    mov edi, 1
.alloc:
    mov esi, 1
    call xcalloc
    mov r14, rax
    test r13, r13
    jz .read_ok
    mov rdi, r14
    mov esi, 1
    mov rdx, r13
    mov rcx, rbx
    call C(fread)
    cmp rax, r13
    je .read_ok
    lea rdi, [rel msg_read]
    call die
.read_ok:
    mov rdi, rbx
    call C(fclose)
    mov rax, r14
    mov [rel temp_size], r13
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

parse_symbols:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov r12, rdi
    mov r13, rsi
    mov eax, [r13 + SEC_link]
    cmp rax, [r12 + OBJ_section_count]
    jb .link_ok
    lea rdi, [rel msg_sym_link]
    call die
.link_ok:
    imul rax, SEC_SIZE
    add rax, [r12 + OBJ_sections]
    mov r14, rax
    cmp dword [r13 + SEC_entsize], 0
    jne .entsize_ok
    lea rdi, [rel msg_sym_entsize]
    call die
.entsize_ok:
    mov eax, [r13 + SEC_offset]
    add eax, [r13 + SEC_size]
    cmp rax, [r12 + OBJ_size]
    ja .range_bad
    mov eax, [r14 + SEC_offset]
    add eax, [r14 + SEC_size]
    cmp rax, [r12 + OBJ_size]
    jbe .range_ok
.range_bad:
    lea rdi, [rel msg_sym_range]
    call die
.range_ok:
    mov eax, [r13 + SEC_size]
    xor edx, edx
    div dword [r13 + SEC_entsize]
    mov [r12 + OBJ_symbol_count], rax
    mov rdi, [r12 + OBJ_symbol_count]
    mov esi, SYM_SIZE
    call xcalloc
    mov [r12 + OBJ_symbols], rax
    xor r15d, r15d
.loop:
    cmp r15, [r12 + OBJ_symbol_count]
    jae .done
    mov eax, [r13 + SEC_entsize]
    imul eax, r15d
    add eax, [r13 + SEC_offset]
    mov [rel temp_off], rax
    mov rbx, r15
    imul rbx, SYM_SIZE
    add rbx, [r12 + OBJ_symbols]
    mov [rbx + SYM_obj], r12
    mov [rbx + SYM_index], r15d
    mov rdi, [r12 + OBJ_data]
    mov rsi, [r12 + OBJ_size]
    mov edx, [rel temp_off]
    call u32
    mov [rel temp0], eax
    mov rdi, [r12 + OBJ_data]
    mov eax, [r14 + SEC_offset]
    add rdi, rax
    mov esi, [r14 + SEC_size]
    mov edx, [rel temp0]
    call xstrdup_range
    mov [rbx + SYM_name], rax
    mov rdi, [r12 + OBJ_data]
    mov rsi, [r12 + OBJ_size]
    mov edx, [rel temp_off]
    add edx, 4
    call u32
    mov [rbx + SYM_value], eax
    mov rdi, [r12 + OBJ_data]
    mov rsi, [r12 + OBJ_size]
    mov edx, [rel temp_off]
    add edx, 8
    call u32
    mov [rbx + SYM_size], eax
    mov rax, [r12 + OBJ_data]
    mov edx, [rel temp_off]
    mov al, [rax + rdx + 12]
    mov [rbx + SYM_info], al
    mov rdi, [r12 + OBJ_data]
    mov rsi, [r12 + OBJ_size]
    mov edx, [rel temp_off]
    add edx, 14
    call u16
    mov [rbx + SYM_shndx], ax
    inc r15
    jmp .loop
.done:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

parse_object:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov r12, rdi
    mov r13, rsi
    mov rdi, r12
    xor esi, esi
    mov edx, OBJ_SIZE
    call C(memset)
    mov rdi, r13
    call xstrdup0
    mov [r12 + OBJ_path], rax
    mov rdi, r13
    call read_file
    mov [r12 + OBJ_data], rax
    mov rax, [rel temp_size]
    mov [r12 + OBJ_size], rax
    cmp qword [r12 + OBJ_size], ELF_HEADER_SIZE
    jae .size_ok
    lea rdi, [rel msg_not_elf]
    call die
.size_ok:
    mov rax, [r12 + OBJ_data]
    cmp byte [rax + 0], 0x7f
    jne .not_magic
    cmp byte [rax + 1], 'E'
    jne .not_magic
    cmp byte [rax + 2], 'L'
    jne .not_magic
    cmp byte [rax + 3], 'F'
    je .magic_ok
.not_magic:
    lea rdi, [rel msg_not_elf]
    call die
.magic_ok:
    mov rax, [r12 + OBJ_data]
    cmp byte [rax + 4], 1
    jne .class_bad
    cmp byte [rax + 5], 1
    je .class_ok
.class_bad:
    lea rdi, [rel msg_elf32]
    call die
.class_ok:
    mov rdi, [r12 + OBJ_data]
    mov rsi, [r12 + OBJ_size]
    mov edx, 16
    call u16
    cmp eax, 1
    jne .reloc_bad
    mov rdi, [r12 + OBJ_data]
    mov rsi, [r12 + OBJ_size]
    mov edx, 18
    call u16
    cmp eax, 3
    je .reloc_ok
.reloc_bad:
    lea rdi, [rel msg_reloc]
    call die
.reloc_ok:
    mov rdi, [r12 + OBJ_data]
    mov rsi, [r12 + OBJ_size]
    mov edx, 32
    call u32
    mov [rel shoff_tmp], eax
    mov rdi, [r12 + OBJ_data]
    mov rsi, [r12 + OBJ_size]
    mov edx, 46
    call u16
    mov [rel shentsize_tmp], ax
    cmp eax, 40
    jae .shent_ok
    lea rdi, [rel msg_shent]
    call die
.shent_ok:
    mov rdi, [r12 + OBJ_data]
    mov rsi, [r12 + OBJ_size]
    mov edx, 48
    call u16
    mov [rel shnum_tmp], ax
    mov [r12 + OBJ_section_count], rax
    mov rdi, [r12 + OBJ_data]
    mov rsi, [r12 + OBJ_size]
    mov edx, 50
    call u16
    mov [rel shstrndx_tmp], ax
    movzx rax, word [rel shnum_tmp]
    movzx rcx, word [rel shentsize_tmp]
    imul rax, rcx
    mov edx, [rel shoff_tmp]
    add rax, rdx
    cmp rax, [r12 + OBJ_size]
    jbe .headers_ok
    lea rdi, [rel msg_sh_range]
    call die
.headers_ok:
    movzx rdi, word [rel shnum_tmp]
    test rdi, rdi
    jnz .alloc_sections
    mov edi, 1
.alloc_sections:
    mov esi, SEC_SIZE
    call xcalloc
    mov [r12 + OBJ_sections], rax
    mov qword [rel shstr_ptr], 0
    mov qword [rel shstr_size], 0
    movzx eax, word [rel shstrndx_tmp]
    test eax, eax
    jz .sections
    cmp ax, [rel shnum_tmp]
    jae .sections
    movzx ebx, word [rel shentsize_tmp]
    imul eax, ebx
    add eax, [rel shoff_tmp]
    mov [rel temp_off], eax
    mov rdi, [r12 + OBJ_data]
    mov rsi, [r12 + OBJ_size]
    mov edx, [rel temp_off]
    add edx, 16
    call u32
    mov r14d, eax
    mov rdi, [r12 + OBJ_data]
    mov rsi, [r12 + OBJ_size]
    mov edx, [rel temp_off]
    add edx, 20
    call u32
    mov [rel shstr_size], rax
    mov edx, r14d
    add rdx, rax
    cmp rdx, [r12 + OBJ_size]
    jbe .shstr_ok
    lea rdi, [rel msg_shstr_range]
    call die
.shstr_ok:
    mov rax, [r12 + OBJ_data]
    add rax, r14
    mov [rel shstr_ptr], rax
.sections:
    xor r15d, r15d
.section_loop:
    movzx eax, word [rel shnum_tmp]
    cmp r15d, eax
    jae .find_syms
    movzx eax, word [rel shentsize_tmp]
    imul eax, r15d
    add eax, [rel shoff_tmp]
    mov [rel temp_off], eax
    mov rbx, r15
    imul rbx, SEC_SIZE
    add rbx, [r12 + OBJ_sections]
    mov [rbx + SEC_obj], r12
    mov [rbx + SEC_index], r15d
    mov rdi, [r12 + OBJ_data]
    mov rsi, [r12 + OBJ_size]
    mov edx, [rel temp_off]
    call u32
    mov r14d, eax
    cmp qword [rel shstr_ptr], 0
    je .blank_name
    mov rdi, [rel shstr_ptr]
    mov rsi, [rel shstr_size]
    mov edx, r14d
    call xstrdup_range
    jmp .name_done
.blank_name:
    lea rdi, [rel empty_string]
    call xstrdup0
.name_done:
    mov [rbx + SEC_name], rax
    mov rdi, [r12 + OBJ_data]
    mov rsi, [r12 + OBJ_size]
    mov edx, [rel temp_off]
    add edx, 4
    call u32
    mov [rbx + SEC_type], eax
    mov rdi, [r12 + OBJ_data]
    mov rsi, [r12 + OBJ_size]
    mov edx, [rel temp_off]
    add edx, 8
    call u32
    mov [rbx + SEC_flags], eax
    mov rdi, [r12 + OBJ_data]
    mov rsi, [r12 + OBJ_size]
    mov edx, [rel temp_off]
    add edx, 16
    call u32
    mov [rbx + SEC_offset], eax
    mov rdi, [r12 + OBJ_data]
    mov rsi, [r12 + OBJ_size]
    mov edx, [rel temp_off]
    add edx, 20
    call u32
    mov [rbx + SEC_size], eax
    mov rdi, [r12 + OBJ_data]
    mov rsi, [r12 + OBJ_size]
    mov edx, [rel temp_off]
    add edx, 24
    call u32
    mov [rbx + SEC_link], eax
    mov rdi, [r12 + OBJ_data]
    mov rsi, [r12 + OBJ_size]
    mov edx, [rel temp_off]
    add edx, 28
    call u32
    mov [rbx + SEC_info], eax
    mov rdi, [r12 + OBJ_data]
    mov rsi, [r12 + OBJ_size]
    mov edx, [rel temp_off]
    add edx, 32
    call u32
    mov [rbx + SEC_align], eax
    mov rdi, [r12 + OBJ_data]
    mov rsi, [r12 + OBJ_size]
    mov edx, [rel temp_off]
    add edx, 36
    call u32
    mov [rbx + SEC_entsize], eax
    mov dword [rbx + SEC_segment], -1
    cmp dword [rbx + SEC_type], SHT_NOBITS
    je .section_next
    mov eax, [rbx + SEC_offset]
    add eax, [rbx + SEC_size]
    cmp rax, [r12 + OBJ_size]
    jbe .section_next
    lea rdi, [rel msg_section_range]
    call die
.section_next:
    inc r15d
    jmp .section_loop
.find_syms:
    mov r15d, 1
.sym_loop:
    cmp r15, [r12 + OBJ_section_count]
    jae .common
    mov rbx, r15
    imul rbx, SEC_SIZE
    add rbx, [r12 + OBJ_sections]
    cmp dword [rbx + SEC_type], SHT_SYMTAB
    jne .sym_next
    mov rdi, r12
    mov rsi, rbx
    call parse_symbols
.sym_next:
    inc r15
    jmp .sym_loop
.common:
    mov rdi, r12
    call assign_common_symbols
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

symbol_is_common:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov r12, rdi
    movzx eax, word [r12 + SYM_shndx]
    mov rbx, [r12 + SYM_obj]
    cmp rax, [rbx + OBJ_section_count]
    jb .by_name
    cmp eax, SHN_COMMON
    sete al
    movzx eax, al
    jmp .done
.by_name:
    imul rax, SEC_SIZE
    add rax, [rbx + OBJ_sections]
    mov rdi, [rax + SEC_name]
    lea rsi, [rel common_name]
    call C(strcmp)
    test eax, eax
    sete al
    movzx eax, al
.done:
    pop r12
    pop rbx
    pop rbp
    ret

assign_common_symbols:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov r12, rdi
    xor r13d, r13d
    mov r14d, 1
    xor r15d, r15d
.scan:
    cmp r15, [r12 + OBJ_symbol_count]
    jae .maybe_add
    mov rbx, r15
    imul rbx, SYM_SIZE
    add rbx, [r12 + OBJ_symbols]
    cmp word [rbx + SYM_shndx], SHN_COMMON
    jne .scan_next
    cmp dword [rbx + SYM_size], 0
    je .scan_next
    mov esi, [rbx + SYM_value]
    test esi, esi
    jnz .align_ok
    mov esi, 1
.align_ok:
    mov edi, r13d
    call align_up
    mov r13d, eax
    mov [rbx + SYM_value], eax
    add r13d, [rbx + SYM_size]
    cmp esi, r14d
    jbe .mark
    mov r14d, esi
.mark:
    mov dword [rel temp_has_common], 1
.scan_next:
    inc r15
    jmp .scan
.maybe_add:
    cmp dword [rel temp_has_common], 1
    jne .done
    mov dword [rel temp_has_common], 0
    mov r15, [r12 + OBJ_section_count]
    mov rdi, [r12 + OBJ_sections]
    lea rsi, [r15 + 1]
    imul rsi, SEC_SIZE
    call xrealloc
    mov [r12 + OBJ_sections], rax
    mov rbx, r15
    imul rbx, SEC_SIZE
    add rbx, rax
    mov rdi, rbx
    xor esi, esi
    mov edx, SEC_SIZE
    call C(memset)
    mov [rbx + SEC_obj], r12
    mov [rbx + SEC_index], r15d
    lea rdi, [rel common_name]
    call xstrdup0
    mov [rbx + SEC_name], rax
    mov dword [rbx + SEC_type], SHT_NOBITS
    mov dword [rbx + SEC_flags], SHF_ALLOC | SHF_WRITE
    mov [rbx + SEC_size], r13d
    mov [rbx + SEC_align], r14d
    mov dword [rbx + SEC_segment], -1
    inc qword [r12 + OBJ_section_count]
    xor r13d, r13d
.fix_loop:
    cmp r13, [r12 + OBJ_symbol_count]
    jae .done
    mov rbx, r13
    imul rbx, SYM_SIZE
    add rbx, [r12 + OBJ_symbols]
    cmp word [rbx + SYM_shndx], SHN_COMMON
    jne .fix_next
    mov [rbx + SYM_shndx], r15w
.fix_next:
    inc r13
    jmp .fix_loop
.done:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

section_vec_push:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov r12, rdi
    mov rbx, rsi
    mov rax, [r12 + VEC_count]
    cmp rax, [r12 + VEC_cap]
    jb .store
    mov rcx, [r12 + VEC_cap]
    test rcx, rcx
    jnz .grow
    mov ecx, 32
    jmp .resize
.grow:
    add rcx, rcx
.resize:
    mov [r12 + VEC_cap], rcx
    mov rdi, [r12 + VEC_items]
    mov rsi, rcx
    shl rsi, 3
    call xrealloc
    mov [r12 + VEC_items], rax
.store:
    mov rax, [r12 + VEC_count]
    mov rcx, [r12 + VEC_items]
    mov [rcx + rax * 8], rbx
    inc qword [r12 + VEC_count]
    pop r12
    pop rbx
    pop rbp
    ret

segment_vec_push:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov r12, rdi
    mov rbx, rsi
    mov rax, [r12 + VEC_count]
    cmp rax, [r12 + VEC_cap]
    jb .store
    mov rcx, [r12 + VEC_cap]
    test rcx, rcx
    jnz .grow
    mov ecx, 8
    jmp .resize
.grow:
    add rcx, rcx
.resize:
    mov [r12 + VEC_cap], rcx
    mov rdi, [r12 + VEC_items]
    imul rsi, rcx, SEG_SIZE
    call xrealloc
    mov [r12 + VEC_items], rax
.store:
    mov rax, [r12 + VEC_count]
    imul rax, SEG_SIZE
    add rax, [r12 + VEC_items]
    mov rdi, rax
    mov rsi, rbx
    mov edx, SEG_SIZE
    call C(memcpy)
    inc qword [r12 + VEC_count]
    pop r12
    pop rbx
    pop rbp
    ret

global_vec_push:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov r12, rdi
    mov r13, rsi
    mov r14, rdx
    mov rax, [r12 + VEC_count]
    cmp rax, [r12 + VEC_cap]
    jb .store
    mov rcx, [r12 + VEC_cap]
    test rcx, rcx
    jnz .grow
    mov ecx, 128
    jmp .resize
.grow:
    add rcx, rcx
.resize:
    mov [r12 + VEC_cap], rcx
    mov rdi, [r12 + VEC_items]
    imul rsi, rcx, GLOB_SIZE
    call xrealloc
    mov [r12 + VEC_items], rax
.store:
    mov rdi, r13
    call xstrdup0
    mov rbx, [r12 + VEC_count]
    imul rbx, GLOB_SIZE
    add rbx, [r12 + VEC_items]
    mov [rbx + GLOB_name], rax
    mov [rbx + GLOB_symbol], r14
    inc qword [r12 + VEC_count]
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

find_global_slot:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov r12, rdi
    mov r13, rsi
    xor ebx, ebx
.loop:
    cmp rbx, [r12 + VEC_count]
    jae .none
    mov rax, rbx
    imul rax, GLOB_SIZE
    add rax, [r12 + VEC_items]
    mov [rel temp_ptr], rax
    mov rax, [rel temp_ptr]
    mov rdi, [rax + GLOB_name]
    mov rsi, r13
    call cstr_equal
    test eax, eax
    jne .found
    inc rbx
    jmp .loop
.found:
    mov rax, [rel temp_ptr]
    jmp .return
.none:
    xor eax, eax
.return:
    add rsp, 8
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

; Returns 1 when the two NUL-terminated strings match, 0 otherwise.
cstr_equal:
    xor ecx, ecx
.loop:
    mov al, [rdi + rcx]
    mov dl, [rsi + rcx]
    cmp al, dl
    jne .no
    test al, al
    je .yes
    inc rcx
    jmp .loop
.yes:
    mov eax, 1
    ret
.no:
    xor eax, eax
    ret

find_global:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    call find_global_slot
    test rax, rax
    jz .none
    mov rax, [rax + GLOB_symbol]
    leave
    ret
.none:
    xor eax, eax
    leave
    ret

collect_global_symbols:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    xor r12d, r12d
.obj_loop:
    cmp r12, [rel input_count]
    jae .done
    mov r13, r12
    imul r13, OBJ_SIZE
    add r13, [rel objects]
    xor r14d, r14d
.sym_loop:
    cmp r14, [r13 + OBJ_symbol_count]
    jae .next_obj
    mov rbx, r14
    imul rbx, SYM_SIZE
    add rbx, [r13 + OBJ_symbols]
    mov rax, [rbx + SYM_name]
    cmp byte [rax], 0
    je .next_sym
    cmp word [rbx + SYM_shndx], SHN_UNDEF
    je .next_sym
    movzx eax, byte [rbx + SYM_info]
    shr eax, 4
    test eax, eax
    jz .next_sym
    lea rdi, [rel globals_vec]
    mov rsi, [rbx + SYM_name]
    call find_global_slot
    test rax, rax
    jz .add
    mov r15, rax
    mov rdi, [r15 + GLOB_symbol]
    call symbol_is_common
    mov [rel temp0], eax
    mov rdi, rbx
    call symbol_is_common
    mov [rel temp1], eax
    cmp dword [rel temp0], 1
    jne .existing_not_common
    cmp dword [rel temp1], 1
    je .next_sym
    mov [r15 + GLOB_symbol], rbx
    jmp .next_sym
.existing_not_common:
    cmp dword [rel temp1], 1
    je .next_sym
    lea rdi, [rel msg_duplicate]
    call die
.add:
    lea rdi, [rel globals_vec]
    mov rsi, [rbx + SYM_name]
    mov rdx, rbx
    call global_vec_push
.next_sym:
    inc r14
    jmp .sym_loop
.next_obj:
    inc r12
    jmp .obj_loop
.done:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

symbol_address:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov r12, rdi
    cmp word [r12 + SYM_shndx], SHN_UNDEF
    jne .defined
    lea rdi, [rel msg_undefined_addr]
    call die
.defined:
    mov rbx, [r12 + SYM_obj]
    movzx eax, word [r12 + SYM_shndx]
    cmp rax, [rbx + OBJ_section_count]
    jb .sec_ok
    lea rdi, [rel msg_sym_section]
    call die
.sec_ok:
    imul rax, SEC_SIZE
    add rax, [rbx + OBJ_sections]
    test dword [rax + SEC_flags], SHF_ALLOC
    jnz .alloc
    lea rdi, [rel msg_sym_nonalloc]
    call die
.alloc:
    mov eax, [rax + SEC_out_addr]
    add eax, [r12 + SYM_value]
    pop r12
    pop rbx
    pop rbp
    ret

relocation_symbol_value:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov r12, rdi
    cmp word [r12 + SYM_shndx], SHN_UNDEF
    jne .maybe_common
    lea rdi, [rel globals_vec]
    mov rsi, [r12 + SYM_name]
    call find_global
    test rax, rax
    jnz .addr
    lea rdi, [rel msg_unresolved]
    call die
.maybe_common:
    mov rdi, r12
    call symbol_is_common
    test eax, eax
    jz .self
    lea rdi, [rel globals_vec]
    mov rsi, [r12 + SYM_name]
    call find_global
    test rax, rax
    jnz .addr
.self:
    mov rax, r12
.addr:
    mov rdi, rax
    call symbol_address
    pop r12
    pop rbx
    pop rbp
    ret

layout_group:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov [rel layout_flags], edi
    mov [rel layout_kind], esi
    mov dword [rel layout_has], 0
    mov eax, [rel mem_cursor]
    mov edi, eax
    mov esi, PAGE_SIZE
    call align_up
    mov [rel layout_segment_start], eax
    mov [rel mem_cursor], eax
    mov dword [rel layout_file_size], 0
    mov rax, [rel segments_vec + VEC_count]
    mov [rel layout_segment_index], eax
    xor r12d, r12d
.obj_loop:
    cmp r12, [rel input_count]
    jae .finish
    mov r13, r12
    imul r13, OBJ_SIZE
    add r13, [rel objects]
    mov r14d, 1
.sec_loop:
    cmp r14, [r13 + OBJ_section_count]
    jae .next_obj
    mov rbx, r14
    imul rbx, SEC_SIZE
    add rbx, [r13 + OBJ_sections]
    test dword [rbx + SEC_flags], SHF_ALLOC
    jz .next_sec
    mov eax, [rbx + SEC_flags]
    test eax, SHF_EXECINSTR
    setnz cl
    test eax, SHF_WRITE
    setnz dl
    mov eax, [rel layout_kind]
    cmp eax, 0
    jne .kind1
    test cl, cl
    jnz .match
    jmp .next_sec
.kind1:
    cmp eax, 1
    jne .kind2
    test cl, cl
    jnz .next_sec
    test dl, dl
    jz .match
    jmp .next_sec
.kind2:
    test dl, dl
    jz .next_sec
.match:
    mov dword [rel layout_has], 1
    mov eax, [rbx + SEC_align]
    test eax, eax
    jnz .align_ok
    mov eax, 1
.align_ok:
    mov edi, [rel mem_cursor]
    mov esi, eax
    call align_up
    mov [rel mem_cursor], eax
    mov [rbx + SEC_mem_off], eax
    add eax, [rel base_addr]
    mov [rbx + SEC_out_addr], eax
    mov eax, [rel layout_segment_index]
    mov [rbx + SEC_segment], eax
    lea rdi, [rel ordered_vec]
    mov rsi, rbx
    call section_vec_push
    mov eax, [rbx + SEC_size]
    add [rel mem_cursor], eax
    cmp dword [rbx + SEC_type], SHT_NOBITS
    je .next_sec
    mov eax, [rel mem_cursor]
    sub eax, [rel layout_segment_start]
    mov [rel layout_file_size], eax
.next_sec:
    inc r14
    jmp .sec_loop
.next_obj:
    inc r12
    jmp .obj_loop
.finish:
    cmp dword [rel layout_has], 0
    je .done
    lea rdi, [rel temp_segment]
    xor esi, esi
    mov edx, SEG_SIZE
    call C(memset)
    mov eax, [rel layout_flags]
    mov [rel temp_segment + SEG_flags], eax
    mov eax, [rel layout_segment_start]
    mov [rel temp_segment + SEG_mem_off], eax
    add eax, [rel base_addr]
    mov [rel temp_segment + SEG_vaddr], eax
    mov eax, [rel layout_file_size]
    mov [rel temp_segment + SEG_filesz], eax
    mov eax, [rel mem_cursor]
    sub eax, [rel layout_segment_start]
    mov [rel temp_segment + SEG_memsz], eax
    lea rdi, [rel segments_vec]
    lea rsi, [rel temp_segment]
    call segment_vec_push
.done:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

layout_sections:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    lea rdi, [rel ordered_vec]
    xor esi, esi
    mov edx, VEC_SIZE
    call C(memset)
    lea rdi, [rel segments_vec]
    xor esi, esi
    mov edx, VEC_SIZE
    call C(memset)
    mov dword [rel mem_cursor], 0
    mov edi, PF_R | PF_X
    xor esi, esi
    call layout_group
    mov edi, PF_R
    mov esi, 1
    call layout_group
    mov edi, PF_R | PF_W
    mov esi, 2
    call layout_group
    leave
    ret

apply_relocations:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    xor r12d, r12d
.obj_loop:
    cmp r12, [rel input_count]
    jae .done
    mov r13, r12
    imul r13, OBJ_SIZE
    add r13, [rel objects]
    mov r14d, 1
.rel_sec_loop:
    cmp r14, [r13 + OBJ_section_count]
    jae .next_obj
    mov rbx, r14
    imul rbx, SEC_SIZE
    add rbx, [r13 + OBJ_sections]
    cmp dword [rbx + SEC_type], SHT_REL
    jne .next_rel_sec
    mov eax, [rbx + SEC_info]
    cmp rax, [r13 + OBJ_section_count]
    jb .rel_target_ok
    lea rdi, [rel msg_rel_target]
    call die
.rel_target_ok:
    mov r15, rax
    imul r15, SEC_SIZE
    add r15, [r13 + OBJ_sections]
    test dword [r15 + SEC_flags], SHF_ALLOC
    jz .next_rel_sec
    cmp dword [rbx + SEC_entsize], 0
    je .rel_count
    cmp dword [rbx + SEC_entsize], 8
    je .rel_count
    lea rdi, [rel msg_rel_entsize]
    call die
.rel_count:
    mov eax, [rbx + SEC_size]
    shr eax, 3
    mov [rel rel_count_tmp], eax
    mov dword [rel rel_index_tmp], 0
.entry_loop:
    mov eax, [rel rel_index_tmp]
    cmp eax, [rel rel_count_tmp]
    jae .next_rel_sec
    shl eax, 3
    add eax, [rbx + SEC_offset]
    mov [rel temp_off], eax
    mov rdi, [r13 + OBJ_data]
    mov rsi, [r13 + OBJ_size]
    mov edx, eax
    call u32
    mov [rel rel_offset_tmp], eax
    mov rdi, [r13 + OBJ_data]
    mov rsi, [r13 + OBJ_size]
    mov edx, [rel temp_off]
    add edx, 4
    call u32
    mov ecx, eax
    mov edx, eax
    shr ecx, 8
    and edx, 0xff
    mov [rel rel_sym_tmp], ecx
    mov [rel rel_type_tmp], edx
    cmp rcx, [r13 + OBJ_symbol_count]
    jb .sym_ok
    lea rdi, [rel msg_rel_sym]
    call die
.sym_ok:
    mov eax, [rel rel_offset_tmp]
    add eax, 4
    cmp eax, [r15 + SEC_size]
    jbe .off_ok
    lea rdi, [rel msg_rel_off]
    call die
.off_ok:
    mov eax, [rel rel_offset_tmp]
    add eax, [r15 + SEC_mem_off]
    mov [rel patch_off_tmp], eax
    mov eax, [rel rel_offset_tmp]
    add eax, [r15 + SEC_out_addr]
    mov [rel place_tmp], eax
    mov rdi, [rel memory_buffer]
    mov rsi, [rel mem_size_q]
    mov edx, [rel patch_off_tmp]
    call u32
    mov [rel addend_tmp], eax
    mov edi, [rel rel_sym_tmp]
    imul rdi, SYM_SIZE
    add rdi, [r13 + OBJ_symbols]
    call relocation_symbol_value
    mov ecx, eax
    add ecx, [rel addend_tmp]
    cmp dword [rel rel_type_tmp], R_386_32
    je .patch
    cmp dword [rel rel_type_tmp], R_386_PC32
    je .pc32
    lea rdi, [rel msg_rel_type]
    call die
.pc32:
    sub ecx, [rel place_tmp]
.patch:
    mov rdi, [rel memory_buffer]
    mov rsi, [rel mem_size_q]
    mov edx, [rel patch_off_tmp]
    call put_u32
    inc dword [rel rel_index_tmp]
    jmp .entry_loop
.next_rel_sec:
    inc r14
    jmp .rel_sec_loop
.next_obj:
    inc r12
    jmp .obj_loop
.done:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

build_executable:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    call layout_sections
    cmp qword [rel segments_vec + VEC_count], 0
    jne .have_segments
    lea rdi, [rel msg_no_sections]
    call die
.have_segments:
    mov eax, [rel mem_cursor]
    mov [rel mem_size_q], rax
    mov rdi, rax
    test rdi, rdi
    jnz .alloc_mem
    mov edi, 1
.alloc_mem:
    mov esi, 1
    call xcalloc
    mov [rel memory_buffer], rax
    xor r12d, r12d
.copy_loop:
    cmp r12, [rel ordered_vec + VEC_count]
    jae .globals
    mov rax, [rel ordered_vec + VEC_items]
    mov rbx, [rax + r12 * 8]
    cmp dword [rbx + SEC_type], SHT_NOBITS
    je .copy_next
    mov rdi, [rel memory_buffer]
    mov eax, [rbx + SEC_mem_off]
    add rdi, rax
    mov rsi, [rbx + SEC_obj]
    mov rax, [rsi + OBJ_data]
    mov ecx, [rbx + SEC_offset]
    add rax, rcx
    mov rsi, rax
    mov edx, [rbx + SEC_size]
    call C(memcpy)
.copy_next:
    inc r12
    jmp .copy_loop
.globals:
    lea rdi, [rel globals_vec]
    xor esi, esi
    mov edx, VEC_SIZE
    call C(memset)
    call collect_global_symbols
    lea rdi, [rel globals_vec]
    lea rsi, [rel start_symbol]
    call find_global
    test rax, rax
    jnz .start_ok
    lea rdi, [rel msg_missing_start]
    call die
.start_ok:
    mov [rel start_sym_ptr], rax
    call apply_relocations
    mov dword [rel file_cursor], SEGMENT_OFFSET
    xor r12d, r12d
.seg_offset_loop:
    cmp r12, [rel segments_vec + VEC_count]
    jae .alloc_elf
    mov rbx, r12
    imul rbx, SEG_SIZE
    add rbx, [rel segments_vec + VEC_items]
    mov edi, [rel file_cursor]
    mov esi, PAGE_SIZE
    call align_up
    mov [rbx + SEG_offset], eax
    cmp dword [rbx + SEG_filesz], 0
    je .next_seg_offset
    mov edi, [rbx + SEG_filesz]
    mov esi, 16
    call align_up
    add eax, [rbx + SEG_offset]
    mov [rel file_cursor], eax
.next_seg_offset:
    inc r12
    jmp .seg_offset_loop
.alloc_elf:
    mov eax, [rel file_cursor]
    mov [rel elf_size], rax
    mov rdi, rax
    test rdi, rdi
    jnz .elf_alloc_size
    mov edi, 1
.elf_alloc_size:
    mov esi, 1
    call xcalloc
    mov [rel elf_buffer], rax
    mov rax, [rel elf_buffer]
    mov byte [rax + 0], 0x7f
    mov byte [rax + 1], 'E'
    mov byte [rax + 2], 'L'
    mov byte [rax + 3], 'F'
    mov byte [rax + 4], 1
    mov byte [rax + 5], 1
    mov byte [rax + 6], 1
    mov rdi, rax
    mov rsi, [rel elf_size]
    mov edx, 16
    mov ecx, 2
    call put_u16
    mov rdi, [rel elf_buffer]
    mov rsi, [rel elf_size]
    mov edx, 18
    mov ecx, 3
    call put_u16
    mov rdi, [rel elf_buffer]
    mov rsi, [rel elf_size]
    mov edx, 20
    mov ecx, 1
    call put_u32
    mov rdi, [rel start_sym_ptr]
    call symbol_address
    mov ecx, eax
    mov rdi, [rel elf_buffer]
    mov rsi, [rel elf_size]
    mov edx, 24
    call put_u32
    mov rdi, [rel elf_buffer]
    mov rsi, [rel elf_size]
    mov edx, 28
    mov ecx, ELF_HEADER_SIZE
    call put_u32
    mov rdi, [rel elf_buffer]
    mov rsi, [rel elf_size]
    mov edx, 40
    mov ecx, ELF_HEADER_SIZE
    call put_u16
    mov rdi, [rel elf_buffer]
    mov rsi, [rel elf_size]
    mov edx, 42
    mov ecx, PROGRAM_HEADER_SIZE
    call put_u16
    mov rdi, [rel elf_buffer]
    mov rsi, [rel elf_size]
    mov edx, 44
    mov ecx, [rel segments_vec + VEC_count]
    call put_u16
    xor r12d, r12d
.ph_loop:
    cmp r12, [rel segments_vec + VEC_count]
    jae .done
    mov rbx, r12
    imul rbx, SEG_SIZE
    add rbx, [rel segments_vec + VEC_items]
    mov r14d, ELF_HEADER_SIZE
    mov eax, r12d
    imul eax, PROGRAM_HEADER_SIZE
    add r14d, eax
    mov rdi, [rel elf_buffer]
    mov rsi, [rel elf_size]
    mov edx, r14d
    mov ecx, 1
    call put_u32
    mov rdi, [rel elf_buffer]
    mov rsi, [rel elf_size]
    lea edx, [r14d + 4]
    mov ecx, [rbx + SEG_offset]
    call put_u32
    mov rdi, [rel elf_buffer]
    mov rsi, [rel elf_size]
    lea edx, [r14d + 8]
    mov ecx, [rbx + SEG_vaddr]
    call put_u32
    mov rdi, [rel elf_buffer]
    mov rsi, [rel elf_size]
    lea edx, [r14d + 12]
    mov ecx, [rbx + SEG_vaddr]
    call put_u32
    mov rdi, [rel elf_buffer]
    mov rsi, [rel elf_size]
    lea edx, [r14d + 16]
    mov ecx, [rbx + SEG_filesz]
    call put_u32
    mov rdi, [rel elf_buffer]
    mov rsi, [rel elf_size]
    lea edx, [r14d + 20]
    mov ecx, [rbx + SEG_memsz]
    call put_u32
    mov rdi, [rel elf_buffer]
    mov rsi, [rel elf_size]
    lea edx, [r14d + 24]
    mov ecx, [rbx + SEG_flags]
    call put_u32
    mov rdi, [rel elf_buffer]
    mov rsi, [rel elf_size]
    lea edx, [r14d + 28]
    mov ecx, PAGE_SIZE
    call put_u32
    cmp dword [rbx + SEG_filesz], 0
    je .next_ph
    mov rdi, [rel elf_buffer]
    mov eax, [rbx + SEG_offset]
    add rdi, rax
    mov rsi, [rel memory_buffer]
    mov ecx, [rbx + SEG_mem_off]
    add rsi, rcx
    mov edx, [rbx + SEG_filesz]
    call C(memcpy)
.next_ph:
    inc r12
    jmp .ph_loop
.done:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

write_file:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    mov r12, rdi
    mov r13, rsi
    mov r14, rdx
    lea rsi, [rel mode_wb]
    call C(fopen)
    test rax, rax
    jnz .opened
    lea rdi, [rel msg_open]
    call die
.opened:
    mov rbx, rax
    test r14, r14
    jz .close
    mov rdi, r13
    mov esi, 1
    mov rdx, r14
    mov rcx, rbx
    call C(fwrite)
    cmp rax, r14
    je .close
    lea rdi, [rel msg_write]
    call die
.close:
    mov rdi, rbx
    call C(fclose)
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

parse_u32_arg:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    lea rsi, [rbp - 8]
    xor edx, edx
    call C(strtoul)
    mov rcx, 0xffffffff
    cmp rax, rcx
    jbe .ok
    lea rdi, [rel msg_bad_addr]
    call die
.ok:
    leave
    ret

write_symbol_map:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov rdi, [rel map_path]
    lea rsi, [rel mode_w]
    call C(fopen)
    test rax, rax
    jnz .opened
    lea rdi, [rel msg_open]
    call die
.opened:
    mov [rel map_file], rax
    mov rdi, rax
    lea rsi, [rel map_header1]
    xor eax, eax
    call C(fprintf)
    mov rdi, [rel map_file]
    lea rsi, [rel map_header2]
    xor eax, eax
    call C(fprintf)
    xor r12d, r12d
.obj_loop:
    cmp r12, [rel input_count]
    jae .close
    mov r13, r12
    imul r13, OBJ_SIZE
    add r13, [rel objects]
    xor r14d, r14d
.sym_loop:
    cmp r14, [r13 + OBJ_symbol_count]
    jae .next_obj
    mov rbx, r14
    imul rbx, SYM_SIZE
    add rbx, [r13 + OBJ_symbols]
    mov rax, [rbx + SYM_name]
    cmp byte [rax], 0
    je .next_sym
    cmp word [rbx + SYM_shndx], SHN_UNDEF
    je .next_sym
    movzx eax, word [rbx + SYM_shndx]
    cmp rax, [r13 + OBJ_section_count]
    jae .next_sym
    mov r15, rax
    imul r15, SEC_SIZE
    add r15, [r13 + OBJ_sections]
    test dword [r15 + SEC_flags], SHF_ALLOC
    jz .next_sym
    mov rdi, rbx
    call symbol_address
    mov [rel map_addr], eax
    mov rdi, [rel map_file]
    lea rsi, [rel map_row_fmt]
    mov edx, [rel map_addr]
    mov ecx, [rbx + SYM_size]
    movzx eax, byte [rbx + SYM_info]
    and eax, 0x0f
    lea rdx, [rel type_names]
    mov r8, [rdx + rax * 8]
    movzx eax, byte [rbx + SYM_info]
    shr eax, 4
    cmp eax, 2
    jbe .bind_known
    mov eax, 3
.bind_known:
    lea rdx, [rel bind_names]
    mov r9, [rdx + rax * 8]
    sub rsp, 32
    mov rax, [r15 + SEC_name]
    mov [rsp], rax
    mov rax, [r13 + OBJ_path]
    mov [rsp + 8], rax
    mov rax, [rbx + SYM_name]
    mov [rsp + 16], rax
    xor eax, eax
    call C(fprintf)
    add rsp, 32
.next_sym:
    inc r14
    jmp .sym_loop
.next_obj:
    inc r12
    jmp .obj_loop
.close:
    mov rdi, [rel map_file]
    call C(fclose)
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

section .data
align 8
opt_o db "-o", 0
opt_base db "--base", 0
opt_map db "--map", 0
mode_rb db "rb", 0
mode_wb db "wb", 0
mode_w db "w", 0
empty_string db 0
common_name db ".common", 0
start_symbol db "start", 0
elf_magic db 0x7f, "ELF"

usage_text db "usage: link_elf32 -o OUTPUT --base 0xADDR [--map MAP] INPUT.o...", 10, 0
die_fmt db "link_elf32: %s", 10, 0
msg_oom db "out of memory", 0
msg_eof db "unexpected end of file", 0
msg_write_past db "write past output", 0
msg_open db "open failed", 0
msg_seek db "seek failed", 0
msg_tell db "tell failed", 0
msg_read db "read failed", 0
msg_write db "write failed", 0
msg_o_requires db "-o requires an output path", 0
msg_base_requires db "--base requires an address", 0
msg_map_requires db "--map requires an output path", 0
msg_unknown_option db "unknown option", 0
msg_bad_addr db "invalid address", 0
msg_not_elf db "not an ELF file", 0
msg_elf32 db "expected ELF32 little-endian", 0
msg_reloc db "expected i386 relocatable ELF", 0
msg_shent db "section header size too small", 0
msg_sh_range db "section headers out of range", 0
msg_shstr_range db "section string table out of range", 0
msg_section_range db "section data out of range", 0
msg_sym_link db "symbol table string link out of range", 0
msg_sym_entsize db "symbol table has zero entry size", 0
msg_sym_range db "symbol table out of range", 0
msg_duplicate db "duplicate symbol", 0
msg_undefined_addr db "undefined symbol has no address", 0
msg_sym_section db "symbol section out of range", 0
msg_sym_nonalloc db "symbol is not in an allocated section", 0
msg_unresolved db "unresolved symbol", 0
msg_rel_target db "relocation target section out of range", 0
msg_rel_entsize db "unsupported relocation entry size", 0
msg_rel_sym db "relocation symbol out of range", 0
msg_rel_off db "relocation offset out of target range", 0
msg_rel_type db "unsupported relocation type", 0
msg_no_sections db "no allocated sections", 0
msg_missing_start db "missing kernel entry symbol: start", 0

map_header1 db "# vibe-os-symbol-map-v1", 10, 0
map_header2 db "# address", 9, "size", 9, "type", 9, "bind", 9, "section", 9, "object", 9, "symbol", 10, 0
map_row_fmt db "%08X", 9, "%08X", 9, "%s", 9, "%s", 9, "%s", 9, "%s", 9, "%s", 10, 0
bind_local db "LOCAL", 0
bind_global db "GLOBAL", 0
bind_weak db "WEAK", 0
bind_unknown db "BIND", 0
type_notype db "NOTYPE", 0
type_object db "OBJECT", 0
type_func db "FUNC", 0
type_section db "SECTION", 0
type_file db "FILE", 0
type_unknown db "TYPE", 0
align 8
bind_names dq bind_local, bind_global, bind_weak, bind_unknown
type_names dq type_notype, type_object, type_func, type_section, type_file, type_unknown, type_unknown, type_unknown

section .bss
align 8
output_path resq 1
map_path resq 1
input_paths resq 1
input_count resq 1
objects resq 1
base_addr resd 1
have_base resd 1
temp_size resq 1
temp_off resd 1
temp_ptr resq 1
temp0 resd 1
temp1 resd 1
temp_has_common resd 1
shoff_tmp resd 1
shentsize_tmp resw 1
shnum_tmp resw 1
shstrndx_tmp resw 1
shstr_ptr resq 1
shstr_size resq 1
ordered_vec resb VEC_SIZE
segments_vec resb VEC_SIZE
globals_vec resb VEC_SIZE
mem_cursor resd 1
layout_flags resd 1
layout_kind resd 1
layout_has resd 1
layout_segment_start resd 1
layout_file_size resd 1
layout_segment_index resq 1
temp_segment resb SEG_SIZE
memory_buffer resq 1
mem_size_q resq 1
elf_buffer resq 1
elf_size resq 1
file_cursor resd 1
start_sym_ptr resq 1
rel_count_tmp resd 1
rel_index_tmp resd 1
rel_offset_tmp resd 1
rel_sym_tmp resd 1
rel_type_tmp resd 1
patch_off_tmp resd 1
place_tmp resd 1
addend_tmp resd 1
map_file resq 1
map_addr resd 1
