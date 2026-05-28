default rel

%ifdef MACHO64
%define C(name) _ %+ name
%define MAIN _main
%else
%define C(name) name
%define MAIN main
%endif

%define MAX_FIELDS 1024
%define MAX_FILE_BYTES 1048576
%define MISSING_TRANSLATION 0xffffffff
%define KERNEL_HIGHER_HALF_BASE 0xc0000000
%define KERNEL_HIGH_LINK_BASE 0xc0010000
%define PAGING_DIR_ADDR 0x00090000
%define PROC_PROBE_PAGE_DIR_ADDR 0x00080000
%define PROC_PAYLOAD_PAGE_DIR_ADDR 0x00082000
%define PROC_PREEMPT_PAGE_DIR_ADDR 0x00083000
%define PROC_GENERIC0_PAGE_DIR_ADDR 0x00089000
%define PROC_GENERIC1_PAGE_DIR_ADDR 0x0008b000
%define KERNEL_HIGH_ABI_FULL_MASK 0x000007ff
%define KERNEL_HIGH_ABI_LOW_ID_RETAINED 0x00000200
%define KERNEL_HIGH_ABI_HIGH_DATA_WRITE 0x00000400
%define KERNEL_RELOC_ABI_FULL_MASK 0x000003ff
%define KERNEL_RELOC_ABI_RETURN_CR3_RESTORED 0x00000200
%define KERNEL_RELOCATION_LIVE_MAGIC 0x4b524c56
%define PREEMPT_ABI_FULL_MASK 0x000001ff
%define VFS_ABI_FULL_MASK 0x000003ff
%define FAT_ABI_FULL_MASK 0x000001ff
%define INPUT_ABI_FULL_MASK 0x0000000f
%define AUDIO_ABI_FULL_MASK 0x000001ff
%define FB_ABI_FULL_MASK 0x0000000f
%define SYS_EXEC_ARGV_SOURCE_USER 2
%define USER_KIND_PAYLOAD_PRIMARY 2
%define USER_KIND_PREEMPT_PROBE 3
%define USER_KIND_PAYLOAD_SECONDARY 5
%define PROC_MIN 0x00e80000
%define PROC_MAX 0x02000000
%define AUDIO_DEVICE_NONE 0
%define AUDIO_DEVICE_SB16 1
%define AUDIO_CAP_REQUIRED 0x0000000f
%define AUDIO_PCM_QUEUE_BYTES 65536
%define SB16_DMA_BUFFER_BYTES 4096
%define SB16_DMA_BLOCK_BYTES 2048
%define VIBE_INPUT_QUEUE_CAPACITY 63
%define FB_PRESENT_WIDTH 320
%define FB_PRESENT_HEIGHT 200
%define FB_PRESENT_ASPECT_HEIGHT 240
%define FB_PRESENT_FRAME_BYTES 64000
%define FB_PRESENT_PALETTE_BYTES 768
%define VIBE_FB_REQUIRED_CAPS 0x00000013

section .text
global MAIN
extern C(fopen)
extern C(fseek)
extern C(ftell)
extern C(fread)
extern C(fclose)
extern C(malloc)
extern C(free)
extern C(printf)
extern C(puts)
extern C(exit)
extern C(strcmp)
extern C(strstr)

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
    mov dword [rel opt_require_exec], 0
    mov dword [rel opt_require_preempt], 0
    mov dword [rel opt_require_vfs], 0
    mov dword [rel opt_require_device], 0
    mov dword [rel opt_repo_contract], 0
    mov dword [rel first_status_index], 1
    mov ebx, 1
.arg_loop:
    cmp ebx, r14d
    jge .args_done
    mov r12, [r15 + rbx * 8]
    cmp byte [r12], '-'
    jne .set_first
    mov rdi, r12
    lea rsi, [rel s_opt_require_exec]
    call C(strcmp)
    test eax, eax
    jne .not_exec
    mov dword [rel opt_require_exec], 1
    inc ebx
    jmp .arg_loop
.not_exec:
    mov rdi, r12
    lea rsi, [rel s_opt_require_preempt]
    call C(strcmp)
    test eax, eax
    jne .not_preempt
    mov dword [rel opt_require_preempt], 1
    inc ebx
    jmp .arg_loop
.not_preempt:
    mov rdi, r12
    lea rsi, [rel s_opt_require_vfs]
    call C(strcmp)
    test eax, eax
    jne .not_vfs
    mov dword [rel opt_require_vfs], 1
    inc ebx
    jmp .arg_loop
.not_vfs:
    mov rdi, r12
    lea rsi, [rel s_opt_require_device]
    call C(strcmp)
    test eax, eax
    jne .not_device
    mov dword [rel opt_require_device], 1
    inc ebx
    jmp .arg_loop
.not_device:
    mov rdi, r12
    lea rsi, [rel s_opt_repo_contract]
    call C(strcmp)
    test eax, eax
    jne .not_repo
    mov dword [rel opt_repo_contract], 1
    inc ebx
    jmp .arg_loop
.not_repo:
    mov rdi, r12
    lea rsi, [rel s_opt_help]
    call C(strcmp)
    test eax, eax
    je .help
    mov rdi, r12
    lea rsi, [rel s_opt_help_short]
    call C(strcmp)
    test eax, eax
    je .help
    lea rdi, [rel msg_unknown_option]
    call fail
.help:
    lea rdi, [rel usage_text]
    xor eax, eax
    call C(printf)
    xor eax, eax
    jmp .return
.set_first:
    mov [rel first_status_index], ebx
    jmp .args_done
.args_done:
    cmp dword [rel opt_repo_contract], 0
    je .status_mode
    call validate_repo_contract
    lea rdi, [rel msg_contract_ok]
    xor eax, eax
    call C(printf)
    xor eax, eax
    jmp .return
.status_mode:
    mov ebx, [rel first_status_index]
    cmp ebx, r14d
    jl .status_loop
    lea rdi, [rel usage_text]
    xor eax, eax
    call C(printf)
    lea rdi, [rel msg_status_required]
    call fail
.status_loop:
    cmp ebx, r14d
    jge .status_done
    mov rdi, [r15 + rbx * 8]
    call validate_status_file
    inc ebx
    jmp .status_loop
.status_done:
    mov esi, r14d
    sub esi, [rel first_status_index]
    lea rdi, [rel msg_status_ok]
    xor eax, eax
    call C(printf)
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

fail:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    mov [rbp - 8], rdi
    lea rdi, [rel msg_fail_fmt]
    mov rsi, [rel current_context]
    mov rdx, [rbp - 8]
    xor eax, eax
    call C(printf)
    mov edi, 1
    call C(exit)

read_text_file:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov r12, rdi
    lea rsi, [rel mode_rb]
    call C(fopen)
    test rax, rax
    jnz .opened
    lea rdi, [rel msg_open_failed]
    call fail
.opened:
    mov rbx, rax
    mov rdi, rbx
    xor esi, esi
    mov edx, 2
    call C(fseek)
    test eax, eax
    je .seeked_end
    lea rdi, [rel msg_seek_failed]
    call fail
.seeked_end:
    mov rdi, rbx
    call C(ftell)
    test rax, rax
    js .size_bad
    cmp rax, MAX_FILE_BYTES
    jbe .size_ok
.size_bad:
    lea rdi, [rel msg_size_failed]
    call fail
.size_ok:
    mov r13, rax
    mov rdi, rbx
    xor esi, esi
    xor edx, edx
    call C(fseek)
    test eax, eax
    je .rewound
    lea rdi, [rel msg_seek_failed]
    call fail
.rewound:
    lea rdi, [r13 + 1]
    call C(malloc)
    test rax, rax
    jnz .malloc_ok
    lea rdi, [rel msg_oom]
    call fail
.malloc_ok:
    mov r14, rax
    mov rdi, r14
    mov esi, 1
    mov rdx, r13
    mov rcx, rbx
    call C(fread)
    cmp rax, r13
    je .read_ok
    lea rdi, [rel msg_read_failed]
    call fail
.read_ok:
    mov byte [r14 + r13], 0
    mov rdi, rbx
    call C(fclose)
    test eax, eax
    je .close_ok
    lea rdi, [rel msg_close_failed]
    call fail
.close_ok:
    mov rax, r14
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

is_space:
    cmp dil, 32
    je .yes
    cmp dil, 9
    je .yes
    cmp dil, 10
    je .yes
    cmp dil, 11
    je .yes
    cmp dil, 12
    je .yes
    cmp dil, 13
    je .yes
    xor eax, eax
    ret
.yes:
    mov eax, 1
    ret

is_alpha:
    movzx eax, dil
    or al, 0x20
    cmp al, 'a'
    jb .no
    cmp al, 'z'
    ja .no
    mov eax, 1
    ret
.no:
    xor eax, eax
    ret

is_name_char:
    movzx eax, dil
    cmp al, '_'
    je .yes
    cmp al, '0'
    jb .check_alpha
    cmp al, '9'
    jbe .yes
.check_alpha:
    mov dil, al
    call is_alpha
    ret
.yes:
    mov eax, 1
    ret

parse_status:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov [rel status_path], rdi
    mov [rel current_context], rdi
    call read_text_file
    mov [rel status_text], rax
    mov qword [rel field_count], 0
    mov rbx, rax
.scan:
    mov al, [rbx]
    test al, al
    je .done
    mov dil, al
    call is_space
    test eax, eax
    jz .token_start
    inc rbx
    jmp .scan
.token_start:
    mov r12, rbx
.token_loop:
    mov al, [rbx]
    test al, al
    je .token_end_zero
    mov dil, al
    call is_space
    test eax, eax
    jnz .token_end_space
    inc rbx
    jmp .token_loop
.token_end_space:
    mov byte [rbx], 0
    inc rbx
    jmp .token_done
.token_end_zero:
.token_done:
    mov r13, r12
.find_eq:
    mov al, [r13]
    test al, al
    je .scan
    cmp al, '='
    je .got_eq
    inc r13
    jmp .find_eq
.got_eq:
    mov byte [r13], 0
    lea r14, [r13 + 1]
    cmp byte [r14], 0
    jne .value_nonempty
    lea rdi, [rel msg_empty_field]
    call fail
.value_nonempty:
    mov dil, [r12]
    call is_alpha
    test eax, eax
    jnz .name_chars
    lea rdi, [rel msg_bad_field_name]
    call fail
.name_chars:
    mov r15, r12
.name_loop:
    mov al, [r15]
    test al, al
    je .dup_check
    mov dil, al
    call is_name_char
    test eax, eax
    jnz .next_name_char
    lea rdi, [rel msg_bad_field_name]
    call fail
.next_name_char:
    inc r15
    jmp .name_loop
.dup_check:
    xor r15d, r15d
.dup_loop:
    cmp r15, [rel field_count]
    jae .store
    lea rax, [rel field_names]
    mov rdi, [rax + r15 * 8]
    mov rsi, r12
    call C(strcmp)
    test eax, eax
    jne .dup_next
    lea rdi, [rel msg_duplicate_field]
    call fail
.dup_next:
    inc r15
    jmp .dup_loop
.store:
    mov r15, [rel field_count]
    cmp r15, MAX_FIELDS
    jb .store_ok
    lea rdi, [rel msg_too_many_fields]
    call fail
.store_ok:
    lea rax, [rel field_names]
    mov [rax + r15 * 8], r12
    lea rax, [rel field_values]
    mov [rax + r15 * 8], r14
    inc r15
    mov [rel field_count], r15
    jmp .scan
.done:
    cmp qword [rel field_count], 0
    jne .return
    lea rdi, [rel msg_no_fields]
    call fail
.return:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

field:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov r12, rdi
    xor ebx, ebx
.loop:
    cmp rbx, [rel field_count]
    jae .missing
    lea rax, [rel field_names]
    mov rdi, [rax + rbx * 8]
    mov rsi, r12
    call C(strcmp)
    test eax, eax
    je .found
    inc rbx
    jmp .loop
.found:
    lea rax, [rel field_values]
    mov rax, [rax + rbx * 8]
    pop r12
    pop rbx
    pop rbp
    ret
.missing:
    lea rdi, [rel msg_missing_field]
    call fail

has_field:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov r12, rdi
    xor ebx, ebx
.loop:
    cmp rbx, [rel field_count]
    jae .no
    lea rax, [rel field_names]
    mov rdi, [rax + rbx * 8]
    mov rsi, r12
    call C(strcmp)
    test eax, eax
    je .yes
    inc rbx
    jmp .loop
.yes:
    mov eax, 1
    jmp .return
.no:
    xor eax, eax
.return:
    pop r12
    pop rbx
    pop rbp
    ret

exact:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov r12, rsi
    call field
    mov rdi, rax
    mov rsi, r12
    call C(strcmp)
    test eax, eax
    je .ok
    lea rdi, [rel msg_exact_failed]
    call fail
.ok:
    pop r12
    pop rbx
    pop rbp
    ret

parse_hex8_ptr:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov r12, rdi
    xor ebx, ebx
    xor eax, eax
.loop:
    cmp ebx, 8
    je .done
    movzx edx, byte [r12 + rbx]
    cmp dl, '0'
    jb .bad
    cmp dl, '9'
    jbe .digit
    cmp dl, 'A'
    jb .lower
    cmp dl, 'F'
    jbe .upper
.lower:
    cmp dl, 'a'
    jb .bad
    cmp dl, 'f'
    ja .bad
    sub dl, 'a' - 10
    jmp .add
.upper:
    sub dl, 'A' - 10
    jmp .add
.digit:
    sub dl, '0'
.add:
    shl eax, 4
    movzx edx, dl
    or eax, edx
    inc ebx
    jmp .loop
.bad:
    lea rdi, [rel msg_bad_hex]
    call fail
.done:
    pop r12
    pop rbx
    pop rbp
    ret

parse_hex8_value:
    push rbp
    mov rbp, rsp
    push r12
    sub rsp, 8
    mov r12, rdi
    call parse_hex8_ptr
    cmp byte [r12 + 8], 0
    je .ok
    lea rdi, [rel msg_bad_hex]
    call fail
.ok:
    add rsp, 8
    pop r12
    pop rbp
    ret

hex_field:
    call field
    mov rdi, rax
    jmp parse_hex8_value

hex_tuple:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov r12, rsi
    mov r13d, edx
    mov r14, rcx
    call field
    mov rbx, rax
    xor r15d, r15d
.loop:
    cmp r15, r12
    jae .done
    mov rdi, rbx
    call parse_hex8_ptr
    mov [r14 + r15 * 4], eax
    add rbx, 8
    lea rax, [r15 + 1]
    cmp rax, r12
    jae .last
    cmp byte [rbx], r13b
    je .sep_ok
    lea rdi, [rel msg_bad_tuple]
    call fail
.sep_ok:
    inc rbx
    inc r15
    jmp .loop
.last:
    cmp byte [rbx], 0
    je .done
    lea rdi, [rel msg_bad_tuple]
    call fail
.done:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

fixed_bootstrap_page_dir:
    cmp edi, PAGING_DIR_ADDR
    je .yes
    cmp edi, PROC_PROBE_PAGE_DIR_ADDR
    je .yes
    cmp edi, PROC_PAYLOAD_PAGE_DIR_ADDR
    je .yes
    cmp edi, PROC_PREEMPT_PAGE_DIR_ADDR
    je .yes
    cmp edi, PROC_GENERIC0_PAGE_DIR_ADDR
    je .yes
    cmp edi, PROC_GENERIC1_PAGE_DIR_ADDR
    je .yes
    xor eax, eax
    ret
.yes:
    mov eax, 1
    ret

validate_status_file:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    call parse_status
    lea rdi, [rel key_pg]
    lea rsi, [rel val_ON]
    call exact
    lea rdi, [rel key_pmm]
    lea rsi, [rel val_OK]
    call exact
    lea rdi, [rel key_e820]
    lea rsi, [rel val_OK]
    call exact
    lea rdi, [rel key_vmm]
    lea rsi, [rel val_OK]
    call exact
    call validate_clock
    call validate_kernel_relocation
    cmp dword [rel opt_require_exec], 0
    je .skip_exec
    call validate_exec
.skip_exec:
    cmp dword [rel opt_require_preempt], 0
    je .skip_preempt
    call validate_preemption
.skip_preempt:
    cmp dword [rel opt_require_vfs], 0
    je .skip_vfs
    call validate_vfs_abi
.skip_vfs:
    cmp dword [rel opt_require_device], 0
    je .skip_device
    call validate_device_status
.skip_device:
    mov rdi, [rel status_text]
    call C(free)
    leave
    ret

validate_clock:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    lea rdi, [rel key_ticks]
    call has_field
    test eax, eax
    jz .done
    lea rdi, [rel key_ticks]
    call hex_field
    test eax, eax
    jnz .done
    lea rdi, [rel msg_ticks_bad]
    call fail
.done:
    leave
    ret

validate_kernel_relocation:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    lea rdi, [rel key_kreloc]
    call field
    mov rdi, rax
    lea rsi, [rel val_HIGH]
    call C(strcmp)
    test eax, eax
    je .high
    lea rdi, [rel key_kreloc]
    call field
    mov rdi, rax
    lea rsi, [rel val_OK]
    call C(strcmp)
    test eax, eax
    je .ok_state
    lea rdi, [rel msg_kreloc_bad]
    call fail
.high:
    lea rdi, [rel key_krelocstep]
    lea rsi, [rel val_KPMAIN_HIGH]
    call exact
.ok_state:
    lea rdi, [rel key_khmain]
    lea rsi, [rel val_OK]
    call exact
    lea rdi, [rel key_kreldir]
    lea rsi, [rel val_OK]
    call exact
    lea rdi, [rel key_krelive]
    lea rsi, [rel val_OK]
    call exact
    lea rdi, [rel key_krelhaz]
    mov esi, 3
    mov edx, '/'
    lea rcx, [rel tuple_a]
    call hex_tuple
    mov eax, [rel tuple_a]
    cmp eax, [rel tuple_a + 8]
    jne .bad_hazard
    cmp dword [rel tuple_a + 4], MISSING_TRANSLATION
    jne .bad_hazard
    cmp eax, KERNEL_HIGHER_HALF_BASE
    jb .hazard_ok
.bad_hazard:
    lea rdi, [rel msg_krelhaz_bad]
    call fail
.hazard_ok:
    lea rdi, [rel key_khabi]
    mov esi, 5
    mov edx, '/'
    lea rcx, [rel tuple_a]
    call hex_tuple
    cmp dword [rel tuple_a], KERNEL_HIGH_ABI_FULL_MASK
    jne .bad_khabi
    cmp dword [rel tuple_a + 4], KERNEL_HIGH_ABI_FULL_MASK
    jne .bad_khabi
    cmp dword [rel tuple_a + 8], KERNEL_HIGH_ABI_LOW_ID_RETAINED
    jne .bad_khabi
    cmp dword [rel tuple_a + 12], 2
    jb .bad_khabi
    cmp dword [rel tuple_a + 16], 1
    je .khabi_ok
.bad_khabi:
    lea rdi, [rel msg_khabi_bad]
    call fail
.khabi_ok:
    lea rdi, [rel key_khdata]
    mov esi, 3
    mov edx, '/'
    lea rcx, [rel tuple_a]
    call hex_tuple
    cmp dword [rel tuple_a], 2
    jb .bad_khdata
    cmp dword [rel tuple_a + 4], KERNEL_HIGH_ABI_LOW_ID_RETAINED
    jne .bad_khdata
    cmp dword [rel tuple_a + 8], KERNEL_HIGH_ABI_HIGH_DATA_WRITE
    je .khdata_ok
.bad_khdata:
    lea rdi, [rel msg_khdata_bad]
    call fail
.khdata_ok:
    lea rdi, [rel key_krelabi]
    mov esi, 5
    mov edx, '/'
    lea rcx, [rel tuple_a]
    call hex_tuple
    cmp dword [rel tuple_a], KERNEL_RELOC_ABI_FULL_MASK
    jne .bad_krelabi
    cmp dword [rel tuple_a + 4], KERNEL_RELOC_ABI_FULL_MASK
    jne .bad_krelabi
    cmp dword [rel tuple_a + 8], KERNEL_RELOC_ABI_RETURN_CR3_RESTORED
    jne .bad_krelabi
    cmp dword [rel tuple_a + 12], 1
    jne .bad_krelabi
    cmp dword [rel tuple_a + 16], 1
    je .krelabi_ok
.bad_krelabi:
    lea rdi, [rel msg_krelabi_bad]
    call fail
.krelabi_ok:
    lea rdi, [rel key_krelivep]
    mov esi, 5
    mov edx, '/'
    lea rcx, [rel tuple_a]
    call hex_tuple
    cmp dword [rel tuple_a + 12], MISSING_TRANSLATION
    jne .bad_krelive
    cmp dword [rel tuple_a + 16], KERNEL_RELOCATION_LIVE_MAGIC
    je .done
.bad_krelive:
    lea rdi, [rel msg_krelive_bad]
    call fail
.done:
    leave
    ret

validate_exec:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    lea rdi, [rel key_exec]
    lea rsi, [rel val_OK]
    call exact
    lea rdi, [rel key_uexec]
    lea rsi, [rel val_OK]
    call exact
    lea rdi, [rel key_upath]
    lea rsi, [rel val_INIT_ELF]
    call exact
    lea rdi, [rel key_abiexec]
    lea rsi, [rel val_WAIT]
    call exact
    lea rdi, [rel key_abipath]
    lea rsi, [rel val_ABIPROBE_ELF]
    call exact
    lea rdi, [rel key_abiprobe]
    lea rsi, [rel val_WAIT]
    call exact
    lea rdi, [rel key_path]
    call field
    mov rdi, rax
    lea rsi, [rel val_PAYLOAD0_ELF]
    call C(strcmp)
    test eax, eax
    je .doom
    lea rdi, [rel key_path]
    call field
    mov rdi, rax
    lea rsi, [rel val_PAYLOAD1_ELF]
    call C(strcmp)
    test eax, eax
    je .quake
    lea rdi, [rel msg_path_bad]
    call fail
.doom:
    lea rdi, [rel key_doom]
    lea rsi, [rel val_OK]
    call exact
    jmp .path_ok
.quake:
    lea rdi, [rel key_quake]
    lea rsi, [rel val_OK]
    call exact
.path_ok:
    lea rdi, [rel key_argvsrc]
    call hex_field
    cmp eax, SYS_EXEC_ARGV_SOURCE_USER
    je .argv_ok
    lea rdi, [rel msg_argvsrc_bad]
    call fail
.argv_ok:
    lea rdi, [rel key_execmap]
    call field
    lea rdi, [rel key_procpool]
    call field
    lea rdi, [rel key_fdexec]
    call field
    lea rdi, [rel key_fdup]
    call field
    lea rdi, [rel key_kblock]
    call field
    lea rdi, [rel key_ksleep]
    call field
    lea rdi, [rel key_fork]
    call field
    lea rdi, [rel key_vmreap]
    call field
    lea rdi, [rel key_execcopy]
    call has_field
    test eax, eax
    jz .done
    lea rdi, [rel key_execcopy]
    mov esi, 9
    mov edx, '/'
    lea rcx, [rel tuple_a]
    call hex_tuple
    cmp dword [rel tuple_a], 0
    je .bad_copy
    mov eax, [rel tuple_a + 4]
    test eax, eax
    jz .bad_copy
    cmp eax, [rel tuple_a + 8]
    jne .bad_copy
    mov edi, [rel tuple_a + 12]
    call fixed_bootstrap_page_dir
    test eax, eax
    jz .bad_copy
    cmp dword [rel tuple_a + 16], PROC_PAYLOAD_PAGE_DIR_ADDR
    je .copy_cr3_ok
    cmp dword [rel tuple_a + 16], PROC_PREEMPT_PAGE_DIR_ADDR
    je .copy_cr3_ok
    cmp dword [rel tuple_a + 16], PROC_GENERIC0_PAGE_DIR_ADDR
    je .copy_cr3_ok
    cmp dword [rel tuple_a + 16], PROC_GENERIC1_PAGE_DIR_ADDR
    jne .bad_copy
.copy_cr3_ok:
    cmp dword [rel tuple_a + 28], 0
    je .bad_copy
    cmp dword [rel tuple_a + 32], 0
    je .bad_copy
    mov eax, [rel tuple_a + 28]
    cmp eax, [rel tuple_a + 32]
    jbe .done
.bad_copy:
    lea rdi, [rel msg_execcopy_bad]
    call fail
.done:
    leave
    ret

validate_preemption:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    lea rdi, [rel key_preempt]
    call hex_field
    mov [rel temp0], eax
    test eax, eax
    jnz .preempt_nonzero
    lea rdi, [rel msg_preempt_bad]
    call fail
.preempt_nonzero:
    lea rdi, [rel key_pirq]
    call hex_field
    test eax, eax
    jz .bad_preempt
    cmp eax, [rel temp0]
    jne .bad_preempt
    lea rdi, [rel key_pattempt]
    call hex_field
    test eax, eax
    jz .bad_preempt
    cmp eax, [rel temp0]
    jb .bad_preempt
    lea rdi, [rel key_puser]
    call hex_field
    cmp eax, [rel temp0]
    jb .bad_preempt
    lea rdi, [rel key_pround]
    call hex_field
    test eax, eax
    jz .bad_preempt
    lea rdi, [rel key_pctx]
    call hex_field
    cmp eax, [rel temp0]
    jb .bad_preempt
    lea rdi, [rel key_pmask]
    call hex_field
    and eax, 3
    cmp eax, 3
    jne .bad_preempt
    lea rdi, [rel key_pfrom]
    call hex_field
    mov [rel temp1], eax
    test eax, eax
    jz .bad_preempt
    cmp eax, MISSING_TRANSLATION
    je .bad_preempt
    lea rdi, [rel key_pto]
    call hex_field
    test eax, eax
    jz .bad_preempt
    cmp eax, MISSING_TRANSLATION
    je .bad_preempt
    cmp eax, [rel temp1]
    je .bad_preempt
    lea rdi, [rel key_wait]
    mov esi, 9
    mov edx, '/'
    lea rcx, [rel tuple_a]
    call hex_tuple
    cmp dword [rel tuple_a + 16], 0
    je .bad_preempt
    lea rdi, [rel key_waitseed]
    call hex_field
    test eax, eax
    jz .bad_preempt
    cmp eax, MISSING_TRANSLATION
    je .bad_preempt
    lea rdi, [rel key_pself]
    lea rsi, [rel val_OK]
    call exact
    lea rdi, [rel key_preemptabi]
    mov esi, 5
    mov edx, '/'
    lea rcx, [rel tuple_a]
    call hex_tuple
    mov eax, [rel tuple_a + 4]
    cmp eax, PREEMPT_ABI_FULL_MASK
    jne .bad_preemptabi
    mov eax, [rel tuple_a]
    and eax, PREEMPT_ABI_FULL_MASK
    cmp eax, PREEMPT_ABI_FULL_MASK
    jne .bad_preemptabi
    mov eax, [rel tuple_a]
    and eax, ~PREEMPT_ABI_FULL_MASK
    jne .bad_preemptabi
    mov eax, [rel tuple_a + 8]
    test eax, eax
    jz .bad_preemptabi
    test eax, ~PREEMPT_ABI_FULL_MASK
    jnz .bad_preemptabi
    mov ecx, eax
    dec ecx
    test ecx, eax
    jz .done
.bad_preemptabi:
    lea rdi, [rel msg_preemptabi_bad]
    call fail
.bad_preempt:
    lea rdi, [rel msg_preempt_bad]
    call fail
.done:
    leave
    ret

validate_vfs_abi:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    lea rdi, [rel key_vfsabi]
    call has_field
    test eax, eax
    jz .done
    lea rdi, [rel key_vfsabi]
    mov esi, 3
    mov edx, '/'
    lea rcx, [rel tuple_a]
    call hex_tuple
    cmp dword [rel tuple_a + 4], VFS_ABI_FULL_MASK
    jne .bad_vfsabi
    mov eax, [rel tuple_a]
    and eax, VFS_ABI_FULL_MASK
    cmp eax, VFS_ABI_FULL_MASK
    jne .bad_vfsabi
    mov eax, [rel tuple_a]
    and eax, ~VFS_ABI_FULL_MASK
    jne .bad_vfsabi
    mov eax, [rel tuple_a + 8]
    test eax, eax
    jz .bad_vfsabi
    test eax, ~VFS_ABI_FULL_MASK
    jnz .bad_vfsabi
    mov ecx, eax
    dec ecx
    test ecx, eax
    jnz .bad_vfsabi
    lea rdi, [rel key_vfsops]
    mov esi, 10
    mov edx, '/'
    lea rcx, [rel tuple_a]
    call hex_tuple
    xor ecx, ecx
.ops_loop:
    cmp ecx, 10
    je .fatdyn
    lea rax, [rel tuple_a]
    cmp dword [rax + rcx * 4], 0
    je .bad_vfsabi
    inc ecx
    jmp .ops_loop
.fatdyn:
    lea rdi, [rel key_fatdyn]
    mov esi, 9
    mov edx, '/'
    lea rcx, [rel tuple_a]
    call hex_tuple
    cmp dword [rel tuple_a], 0
    je .bad_fat
    cmp dword [rel tuple_a + 4], 0
    jne .bad_fat
    cmp dword [rel tuple_a + 8], 0
    je .bad_fat
    cmp dword [rel tuple_a + 12], 0
    je .bad_fat
    cmp dword [rel tuple_a + 16], 0
    je .bad_fat
    cmp dword [rel tuple_a + 20], 0
    je .bad_fat
    cmp dword [rel tuple_a + 24], 0
    je .bad_fat
    cmp dword [rel tuple_a + 28], 0
    je .bad_fat
    cmp dword [rel tuple_a + 32], 0
    jne .bad_fat
    mov eax, [rel tuple_a + 12]
    mov [rel temp0], eax
    mov eax, [rel tuple_a + 32]
    mov [rel temp1], eax
    lea rdi, [rel key_fatacct]
    mov esi, 5
    mov edx, '/'
    lea rcx, [rel tuple_a]
    call hex_tuple
    cmp dword [rel tuple_a + 16], 0
    jne .bad_fat
    mov eax, [rel tuple_a + 8]
    test eax, eax
    jz .bad_fat
    mov ecx, [rel tuple_a + 12]
    cmp ecx, 2
    jb .bad_fat
    lea edx, [rax + 1]
    cmp ecx, edx
    jne .bad_fat
    mov edx, [rel tuple_a]
    add edx, [rel tuple_a + 4]
    cmp edx, eax
    jne .bad_fat
    lea rdi, [rel key_fatabi]
    mov esi, 5
    mov edx, '/'
    lea rcx, [rel tuple_a]
    call hex_tuple
    cmp dword [rel tuple_a + 4], FAT_ABI_FULL_MASK
    jne .bad_fatabi
    mov eax, [rel tuple_a]
    and eax, FAT_ABI_FULL_MASK
    cmp eax, FAT_ABI_FULL_MASK
    jne .bad_fatabi
    mov eax, [rel tuple_a]
    and eax, ~FAT_ABI_FULL_MASK
    jne .bad_fatabi
    mov eax, [rel temp0]
    cmp [rel tuple_a + 12], eax
    jne .bad_fatabi
    mov eax, [rel temp1]
    cmp [rel tuple_a + 16], eax
    jne .bad_fatabi
    jmp .done
.bad_vfsabi:
    lea rdi, [rel msg_vfsabi_bad]
    call fail
.bad_fatabi:
    lea rdi, [rel msg_fatabi_bad]
    call fail
.bad_fat:
    lea rdi, [rel msg_fat_bad]
    call fail
.done:
    leave
    ret

validate_device_status:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    call validate_input_devices
    call validate_audio_device
    call validate_framebuffer_device
    leave
    ret

validate_input_devices:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    lea rdi, [rel key_inputstat]
    call has_field
    test eax, eax
    jz .done
    lea rdi, [rel key_inputqueue]
    call hex_field
    mov [rel temp0], eax
    lea rdi, [rel key_inputdepth]
    mov esi, 2
    mov edx, ':'
    lea rcx, [rel tuple_b]
    call hex_tuple
    lea rdi, [rel key_inputstat]
    mov esi, 4
    mov edx, ':'
    lea rcx, [rel tuple_a]
    call hex_tuple
    mov eax, [rel temp0]
    cmp eax, [rel tuple_a]
    jne .bad
    cmp dword [rel tuple_a + 12], VIBE_INPUT_QUEUE_CAPACITY
    jne .bad
    mov eax, [rel tuple_b + 4]
    cmp eax, [rel tuple_a + 8]
    jne .bad
    mov eax, [rel tuple_a + 4]
    add eax, [rel tuple_a + 8]
    add eax, [rel tuple_b]
    cmp eax, [rel tuple_a]
    jne .bad
    lea rdi, [rel key_inabi]
    call has_field
    test eax, eax
    jz .done
    lea rdi, [rel key_inabi]
    mov esi, 5
    mov edx, '/'
    lea rcx, [rel tuple_a]
    call hex_tuple
    cmp dword [rel tuple_a + 4], INPUT_ABI_FULL_MASK
    jne .bad_inabi
    mov eax, [rel tuple_a]
    and eax, INPUT_ABI_FULL_MASK
    cmp eax, INPUT_ABI_FULL_MASK
    jne .bad_inabi
    mov eax, [rel tuple_a]
    and eax, ~INPUT_ABI_FULL_MASK
    jne .bad_inabi
    mov eax, [rel tuple_a + 8]
    test eax, eax
    jz .bad_inabi
    test eax, ~INPUT_ABI_FULL_MASK
    jnz .bad_inabi
    cmp dword [rel tuple_a + 12], 0
    jne .done
.bad_inabi:
    lea rdi, [rel msg_inabi_bad]
    call fail
.bad:
    lea rdi, [rel msg_input_bad]
    call fail
.done:
    leave
    ret

validate_audio_device:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    lea rdi, [rel key_adev]
    call has_field
    test eax, eax
    jz .done
    lea rdi, [rel key_adev]
    mov esi, 3
    mov edx, ':'
    lea rcx, [rel tuple_a]
    call hex_tuple
    lea rdi, [rel key_audio]
    call has_field
    test eax, eax
    jz .check_pcm
    lea rdi, [rel key_audio]
    call field
    mov rdi, rax
    lea rsi, [rel val_SB16]
    call C(strcmp)
    test eax, eax
    jne .audio_not_sb16
    cmp dword [rel tuple_a], AUDIO_DEVICE_SB16
    jne .bad_audio
    mov eax, [rel tuple_a + 8]
    and eax, AUDIO_CAP_REQUIRED
    cmp eax, AUDIO_CAP_REQUIRED
    jne .bad_audio
    jmp .check_pcm
.audio_not_sb16:
    lea rdi, [rel key_audio]
    call field
    mov rdi, rax
    lea rsi, [rel val_NONE]
    call C(strcmp)
    test eax, eax
    jne .bad_audio
.check_pcm:
    lea rdi, [rel key_pcmbuf]
    mov esi, 4
    mov edx, ':'
    lea rcx, [rel tuple_a]
    call hex_tuple
    cmp dword [rel tuple_a], SB16_DMA_BUFFER_BYTES
    jne .bad_audio
    cmp dword [rel tuple_a + 4], SB16_DMA_BLOCK_BYTES
    jne .bad_audio
    lea rdi, [rel key_audabi]
    call has_field
    test eax, eax
    jz .done
    lea rdi, [rel key_audabi]
    mov esi, 4
    mov edx, '/'
    lea rcx, [rel tuple_a]
    call hex_tuple
    cmp dword [rel tuple_a + 4], AUDIO_ABI_FULL_MASK
    jne .bad_audabi
    mov eax, [rel tuple_a]
    and eax, AUDIO_ABI_FULL_MASK
    cmp eax, AUDIO_ABI_FULL_MASK
    jne .bad_audabi
    mov eax, [rel tuple_a]
    and eax, ~AUDIO_ABI_FULL_MASK
    jne .bad_audabi
    mov eax, [rel tuple_a + 8]
    test eax, eax
    jz .bad_audabi
    test eax, ~AUDIO_ABI_FULL_MASK
    jnz .bad_audabi
    jmp .done
.bad_audabi:
    lea rdi, [rel msg_audabi_bad]
    call fail
.bad_audio:
    lea rdi, [rel msg_audio_bad]
    call fail
.done:
    leave
    ret

validate_framebuffer_device:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    lea rdi, [rel key_fbdev]
    call has_field
    test eax, eax
    jz .done
    lea rdi, [rel key_fbcap]
    call hex_field
    and eax, VIBE_FB_REQUIRED_CAPS
    cmp eax, VIBE_FB_REQUIRED_CAPS
    jne .bad_fb
    lea rdi, [rel key_fbsrc]
    mov esi, 7
    mov edx, ':'
    lea rcx, [rel tuple_a]
    call hex_tuple
    cmp dword [rel tuple_a], 1
    jne .bad_fb
    cmp dword [rel tuple_a + 4], FB_PRESENT_WIDTH
    jne .bad_fb
    cmp dword [rel tuple_a + 8], FB_PRESENT_HEIGHT
    jne .bad_fb
    cmp dword [rel tuple_a + 12], FB_PRESENT_WIDTH
    jne .bad_fb
    cmp dword [rel tuple_a + 16], FB_PRESENT_ASPECT_HEIGHT
    jne .bad_fb
    lea rdi, [rel key_fbacct]
    mov esi, 9
    mov edx, ':'
    lea rcx, [rel tuple_a]
    call hex_tuple
    cmp dword [rel tuple_a], 1
    jne .bad_fb
    lea rdi, [rel key_fbabi]
    call has_field
    test eax, eax
    jz .done
    lea rdi, [rel key_fbabi]
    mov esi, 5
    mov edx, '/'
    lea rcx, [rel tuple_a]
    call hex_tuple
    cmp dword [rel tuple_a + 4], FB_ABI_FULL_MASK
    jne .bad_fbabi
    mov eax, [rel tuple_a]
    and eax, FB_ABI_FULL_MASK
    cmp eax, FB_ABI_FULL_MASK
    jne .bad_fbabi
    mov eax, [rel tuple_a]
    and eax, ~FB_ABI_FULL_MASK
    jne .bad_fbabi
    cmp dword [rel tuple_a + 8], 0
    je .bad_fbabi
    jmp .done
.bad_fbabi:
    lea rdi, [rel msg_fbabi_bad]
    call fail
.bad_fb:
    lea rdi, [rel msg_fb_bad]
    call fail
.done:
    leave
    ret

require_contains:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov r12, rdi
    mov r13, rsi
    call read_text_file
    mov rbx, rax
    mov rdi, rbx
    mov rsi, r13
    call C(strstr)
    test rax, rax
    jnz .ok
    lea rdi, [rel msg_contract_missing]
    call fail
.ok:
    mov rdi, rbx
    call C(free)
    add rsp, 8
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

forbid_contains:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov r12, rdi
    mov r13, rsi
    call read_text_file
    mov rbx, rax
    mov rdi, rbx
    mov rsi, r13
    call C(strstr)
    test rax, rax
    jz .ok
    lea rdi, [rel msg_contract_forbidden]
    call fail
.ok:
    mov rdi, rbx
    call C(free)
    add rsp, 8
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

validate_repo_contract:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    lea rax, [rel ctx_repo]
    mov [rel current_context], rax
    lea rdi, [rel file_makefile]
    lea rsi, [rel needle_status_asm]
    call require_contains
    lea rdi, [rel file_makefile]
    lea rsi, [rel needle_vm_status_target]
    call require_contains
    lea rdi, [rel file_makefile]
    lea rsi, [rel needle_old_python]
    call forbid_contains
    lea rdi, [rel file_os_smoke]
    lea rsi, [rel needle_status_checker_tool]
    call require_contains
    lea rdi, [rel file_os_smoke]
    lea rsi, [rel s_opt_require_exec]
    call require_contains
    lea rdi, [rel file_os_smoke]
    lea rsi, [rel s_opt_require_preempt]
    call require_contains
    lea rdi, [rel file_os_smoke]
    lea rsi, [rel needle_launcher_select_1]
    call require_contains
    lea rdi, [rel file_os_smoke]
    lea rsi, [rel needle_wait_pmask]
    call require_contains
    lea rdi, [rel file_real_wad_smoke]
    lea rsi, [rel needle_status_checker_tool]
    call require_contains
    lea rdi, [rel file_real_wad_smoke]
    lea rsi, [rel s_opt_require_preempt]
    call require_contains
    lea rdi, [rel file_real_wad_smoke]
    lea rsi, [rel needle_launcher_click]
    call require_contains
    lea rdi, [rel file_real_quake_smoke]
    lea rsi, [rel needle_launcher_select_2]
    call require_contains
    lea rdi, [rel file_real_quake_smoke]
    lea rsi, [rel needle_boot_payload_quake]
    call forbid_contains
    lea rdi, [rel file_real_wad_soak]
    lea rsi, [rel needle_status_checker_tool]
    call require_contains
    lea rdi, [rel file_real_wad_soak]
    lea rsi, [rel s_opt_require_preempt]
    call require_contains
    lea rdi, [rel file_real_wad_soak]
    lea rsi, [rel needle_launcher_click]
    call require_contains
    lea rdi, [rel file_readme]
    lea rsi, [rel needle_status_asm]
    call require_contains
    lea rdi, [rel file_readme]
    lea rsi, [rel needle_guest_launcher]
    call require_contains
    lea rdi, [rel file_readme]
    lea rsi, [rel needle_codespaces]
    call require_contains
    leave
    ret

section .data
align 8
current_context dq ctx_program

ctx_program db "vibe_status_check", 0
ctx_repo db "repo-contract", 0
mode_rb db "rb", 0

usage_text db "usage: tools/vibe_status_check [--repo-contract] [--require-exec] [--require-preempt] [--require-vfs-abi] [--require-device-abi] status.txt...", 10, 0
msg_fail_fmt db "%s: %s", 10, 0
msg_contract_ok db "VM status proof contract OK (ASM)", 10, 0
msg_status_ok db "VM status proof OK (ASM): validated %d status file(s)", 10, 0
msg_unknown_option db "unknown option", 0
msg_status_required db "status file required unless --repo-contract is used", 0
msg_open_failed db "could not open input file", 0
msg_seek_failed db "could not seek input file", 0
msg_size_failed db "input file is too large", 0
msg_oom db "out of memory", 0
msg_read_failed db "could not read input file", 0
msg_close_failed db "could not close input file", 0
msg_empty_field db "status field has an empty value", 0
msg_bad_field_name db "status field name is invalid", 0
msg_duplicate_field db "duplicate status field", 0
msg_too_many_fields db "too many status fields", 0
msg_no_fields db "no key=value status fields", 0
msg_missing_field db "missing required status field", 0
msg_exact_failed db "status field has unexpected value", 0
msg_bad_hex db "field is not an 8-digit hexadecimal value", 0
msg_bad_tuple db "tuple field has the wrong shape", 0
msg_ticks_bad db "ticks= must be nonzero", 0
msg_kreloc_bad db "kreloc= must be HIGH or OK", 0
msg_krelhaz_bad db "krelhaz= does not prove the low return hazard", 0
msg_khabi_bad db "khabi= does not prove the higher-half ABI mask", 0
msg_khdata_bad db "khdata= does not prove higher-half data bookkeeping", 0
msg_krelabi_bad db "krelabi= does not prove relocation-directory ABI coverage", 0
msg_krelive_bad db "krelivep= does not prove the live relocation switch", 0
msg_path_bad db "path= must be /APPS/DOOM/APP.ELF or /APPS/QUAKE/APP.ELF", 0
msg_argvsrc_bad db "argvsrc= must prove user-memory argv", 0
msg_execcopy_bad db "execcopy= does not prove balanced target-CR3 materialization", 0
msg_preempt_bad db "preemption proof fields are inconsistent", 0
msg_preemptabi_bad db "preemptabi= does not prove full preemption ABI coverage", 0
msg_vfsabi_bad db "vfsabi= does not prove full VFS ABI coverage", 0
msg_fatabi_bad db "fatabi= does not prove full FAT ABI coverage", 0
msg_fat_bad db "FAT dynamic/accounting proof fields are inconsistent", 0
msg_input_bad db "input device status accounting is inconsistent", 0
msg_inabi_bad db "inabi= does not prove full input ABI coverage", 0
msg_audio_bad db "audio device proof fields are inconsistent", 0
msg_audabi_bad db "audabi= does not prove full audio ABI coverage", 0
msg_fb_bad db "framebuffer proof fields are inconsistent", 0
msg_fbabi_bad db "fbabi= does not prove full framebuffer ABI coverage", 0
msg_contract_missing db "repository contract needle is missing", 0
msg_contract_forbidden db "repository contract contains forbidden legacy text", 0

s_opt_require_exec db "--require-exec", 0
s_opt_require_preempt db "--require-preempt", 0
s_opt_require_vfs db "--require-vfs-abi", 0
s_opt_require_device db "--require-device-abi", 0
s_opt_repo_contract db "--repo-contract", 0
s_opt_help db "--help", 0
s_opt_help_short db "-h", 0

key_pg db "pg", 0
key_pmm db "pmm", 0
key_e820 db "e820", 0
key_vmm db "vmm", 0
key_ticks db "ticks", 0
key_kreloc db "kreloc", 0
key_krelocstep db "krelocstep", 0
key_khmain db "khmain", 0
key_kreldir db "kreldir", 0
key_krelive db "krelive", 0
key_krelhaz db "krelhaz", 0
key_khabi db "khabi", 0
key_khdata db "khdata", 0
key_krelabi db "krelabi", 0
key_krelivep db "krelivep", 0
key_exec db "exec", 0
key_uexec db "uexec", 0
key_upath db "upath", 0
key_abiexec db "abiexec", 0
key_abipath db "abipath", 0
key_abiprobe db "abiprobe", 0
key_path db "path", 0
key_doom db "doom", 0
key_quake db "quake", 0
key_argvsrc db "argvsrc", 0
key_execmap db "execmap", 0
key_procpool db "procpool", 0
key_fdexec db "fdexec", 0
key_fdup db "fdup", 0
key_kblock db "kblock", 0
key_ksleep db "ksleep", 0
key_fork db "fork", 0
key_vmreap db "vmreap", 0
key_execcopy db "execcopy", 0
key_preempt db "preempt", 0
key_pirq db "pirq", 0
key_pattempt db "pattempt", 0
key_puser db "puser", 0
key_pround db "pround", 0
key_pctx db "pctx", 0
key_pmask db "pmask", 0
key_pfrom db "pfrom", 0
key_pto db "pto", 0
key_wait db "wait", 0
key_waitseed db "waitseed", 0
key_pself db "pself", 0
key_preemptabi db "preemptabi", 0
key_vfsabi db "vfsabi", 0
key_vfsops db "vfsops", 0
key_fatdyn db "fatdyn", 0
key_fatacct db "fatacct", 0
key_fatabi db "fatabi", 0
key_inputstat db "inputstat", 0
key_inputqueue db "inputqueue", 0
key_inputdepth db "inputdepth", 0
key_inabi db "inabi", 0
key_adev db "adev", 0
key_audio db "audio", 0
key_pcmbuf db "pcmbuf", 0
key_audabi db "audabi", 0
key_fbdev db "fbdev", 0
key_fbcap db "fbcap", 0
key_fbsrc db "fbsrc", 0
key_fbacct db "fbacct", 0
key_fbabi db "fbabi", 0

val_ON db "ON", 0
val_OK db "OK", 0
val_HIGH db "HIGH", 0
val_KPMAIN_HIGH db "KPMAIN_HIGH", 0
val_WAIT db "WAIT", 0
val_INIT_ELF db "/SYSTEM/INIT.ELF", 0
val_ABIPROBE_ELF db "/SYSTEM/ABIPROBE.ELF", 0
val_PAYLOAD0_ELF db "/APPS/DOOM/APP.ELF", 0
val_PAYLOAD1_ELF db "/APPS/QUAKE/APP.ELF", 0
val_SB16 db "SB16", 0
val_NONE db "NONE", 0

file_makefile db "Makefile", 0
file_os_smoke db ".github/workflows/os-smoke.yml", 0
file_real_wad_smoke db ".github/workflows/real-wad-smoke.yml", 0
file_real_quake_smoke db ".github/workflows/real-quake-smoke.yml", 0
file_real_wad_soak db ".github/workflows/real-wad-soak.yml", 0
file_readme db "README.md", 0
needle_status_asm db "tools/vibe_status_check.asm", 0
needle_status_checker_tool db "status-checker-tool", 0
needle_vm_status_target db "vm-status-proof-check:", 0
needle_old_python db "check_vm_status_proof", 0
needle_launcher_select_1 db "launcher-select:1", 0
needle_launcher_select_2 db "launcher-select:2", 0
needle_wait_pmask db "wait-status=pmask:00000003", 0
needle_launcher_click db "launcher-click:mousebtn=1", 0
needle_boot_payload_quake db "BOOT_PAYLOAD_QUAKE", 0
needle_guest_launcher db "guest launcher screen", 0
needle_codespaces db "tools/play_now_codespaces.sh", 0

section .bss
field_names resq MAX_FIELDS
field_values resq MAX_FIELDS
field_count resq 1
status_text resq 1
status_path resq 1
opt_require_exec resd 1
opt_require_preempt resd 1
opt_require_vfs resd 1
opt_require_device resd 1
opt_repo_contract resd 1
first_status_index resd 1
tuple_a resd 16
tuple_b resd 16
temp0 resd 1
temp1 resd 1
