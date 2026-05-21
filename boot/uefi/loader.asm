bits 64
default rel

; x86_64 UEFI proof loader.
;
; This is intentionally a loader/proof rung, not a kernel entry path. It reads
; VIBEOS/KERNEL.ELF from the ESP, records GOP and memory-map facts, calls
; ExitBootServices, emits debugcon markers for cloud parsing, then exits QEMU
; through isa-debug-exit. The source now carries the BIOS-compatible 32-bit
; handoff plan and mode-switch stubs, but the final jump remains disabled until
; low-memory ELF placement and a kernel-owned entry marker are proven.

EFI_SUCCESS equ 0
EFI_ABORTED equ 0x8000000000000015
EFI_FILE_MODE_READ equ 0x0000000000000001
EFI_LOADER_DATA equ 2
ALLOCATE_ANY_PAGES equ 0

BOOT_SERVICES_HANDLE_PROTOCOL equ 152
BOOT_SERVICES_ALLOCATE_PAGES equ 40
BOOT_SERVICES_GET_MEMORY_MAP equ 56
BOOT_SERVICES_LOCATE_PROTOCOL equ 320
BOOT_SERVICES_SET_WATCHDOG_TIMER equ 256
BOOT_SERVICES_EXIT_BOOT_SERVICES equ 232

SYSTEM_TABLE_BOOT_SERVICES equ 96
LOADED_IMAGE_DEVICE_HANDLE equ 24

FILE_OPEN equ 8
FILE_CLOSE equ 16
FILE_READ equ 32

GOP_MODE_OFFSET equ 24
GOP_MODE_INFO equ 8
GOP_MODE_FB_BASE equ 24
GOP_MODE_FB_SIZE equ 32
GOP_INFO_WIDTH equ 4
GOP_INFO_HEIGHT equ 8
GOP_INFO_PIXEL_FORMAT equ 12
GOP_INFO_PIXELS_PER_SCAN_LINE equ 32

KERNEL_MAX_BYTES equ 0x00020000
KERNEL_BUFFER_PAGES equ KERNEL_MAX_BYTES / 0x1000
MEMORY_MAP_BUFFER_BYTES equ 0x00010000
DEBUGCON_PORT equ 0x0402
DEBUG_EXIT_PORT equ 0x0501

; BIOS-stage2-compatible 32-bit kernel handoff targets. The current kernel
; reads boot video facts from BOOT_INFO_ADDR and expects flat 0x08/0x10
; protected-mode selectors before it installs its own GDT.
BOOT_INFO_ADDR equ 0x00007000
BOOT_VIDEO_MAGIC equ 0x45444956
BOOT_VIDEO_MODE equ BOOT_INFO_ADDR + 12
BOOT_VIDEO_FLAGS equ BOOT_INFO_ADDR + 14
BOOT_VIDEO_FB_ADDR equ BOOT_INFO_ADDR + 16
BOOT_VIDEO_PITCH equ BOOT_INFO_ADDR + 20
BOOT_VIDEO_WIDTH equ BOOT_INFO_ADDR + 24
BOOT_VIDEO_HEIGHT equ BOOT_INFO_ADDR + 26
BOOT_VIDEO_BPP equ BOOT_INFO_ADDR + 28
BOOT_VIDEO_MEMORY_MODEL equ BOOT_INFO_ADDR + 29
BOOT_VIDEO_RED_MASK equ BOOT_INFO_ADDR + 30
BOOT_VIDEO_RED_POS equ BOOT_INFO_ADDR + 31
BOOT_VIDEO_GREEN_MASK equ BOOT_INFO_ADDR + 32
BOOT_VIDEO_GREEN_POS equ BOOT_INFO_ADDR + 33
BOOT_VIDEO_BLUE_MASK equ BOOT_INFO_ADDR + 34
BOOT_VIDEO_BLUE_POS equ BOOT_INFO_ADDR + 35
BOOT_E820_MAGIC_ADDR equ BOOT_INFO_ADDR + 36
BOOT_E820_COUNT equ BOOT_INFO_ADDR + 40
BOOT_E820_ENTRY_SIZE_ADDR equ BOOT_INFO_ADDR + 42
BOOT_E820_MAP_ADDR_PTR equ BOOT_INFO_ADDR + 44
BOOT_VIDEO_FLAG_VBE equ 0x0001
BOOT_VIDEO_FLAG_LFB equ 0x0002
BOOT_VIDEO_FLAG_XRGB8888 equ 0x0004
BOOT_E820_MAGIC equ 0x30323845
UEFI32_E820_MAP_ADDR equ 0x00007100
UEFI32_TRAMPOLINE_ADDR equ 0x00008000
UEFI32_HANDOFF_BLOCK_ADDR equ 0x00009000
UEFI32_STACK_LOW equ 0x00060000
UEFI32_STACK_TOP equ 0x00070000
UEFI32_CODE_SEG equ 0x08
UEFI32_DATA_SEG equ 0x10

UEFI_HANDOFF_MAGIC equ 0x444e4855
UEFI_HANDOFF_VERSION equ 1
UEFI_HANDOFF_FLAG_GOP_XRGB8888 equ 0x00000001
UEFI_HANDOFF_FLAG_MMAP_READY equ 0x00000002
UEFI_HANDOFF_FLAG_BOOTINFO_LAYOUT_READY equ 0x00000004
UEFI_HANDOFF_FLAG_TRANSITION_STUB_PRESENT equ 0x00000008
UEFI_HANDOFF_FLAG_FINAL_JUMP_DISABLED equ 0x00000010
UEFI_HANDOFF_MAGIC_OFF equ 0
UEFI_HANDOFF_VERSION_OFF equ 4
UEFI_HANDOFF_FLAGS_OFF equ 8
UEFI_HANDOFF_ENTRY32_OFF equ 16
UEFI_HANDOFF_STACK32_OFF equ 24
UEFI_HANDOFF_BOOT_INFO32_OFF equ 32
UEFI_HANDOFF_E820_MAP32_OFF equ 40
UEFI_HANDOFF_TRAMPOLINE32_OFF equ 48
UEFI_HANDOFF_GDT_BASE_OFF equ 56
UEFI_HANDOFF_CODE_SELECTOR_OFF equ 64
UEFI_HANDOFF_DATA_SELECTOR_OFF equ 72
UEFI_HANDOFF_KERNEL_BUFFER_OFF equ 80
UEFI_HANDOFF_KERNEL_READ_SIZE_OFF equ 88
UEFI_HANDOFF_FRAMEBUFFER_BASE_OFF equ 96
UEFI_HANDOFF_PITCH_OFF equ 104
UEFI_HANDOFF_WIDTH_OFF equ 112
UEFI_HANDOFF_HEIGHT_OFF equ 120
UEFI_HANDOFF_PIXEL_FORMAT_OFF equ 128
UEFI_HANDOFF_MMAP_BUFFER_OFF equ 136
UEFI_HANDOFF_MMAP_SIZE_OFF equ 144
UEFI_HANDOFF_MMAP_DESC_SIZE_OFF equ 152
UEFI_HANDOFF_MMAP_DESC_COUNT_OFF equ 160
UEFI_HANDOFF_BLOCK_BYTES equ 168
IA32_EFER_MSR equ 0xc0000080
CR0_PG_CLEAR_MASK equ 0x7fffffff
EFER_LME_CLEAR_MASK equ 0xfffffeff
CR4_PAE_CLEAR_MASK equ 0xffffffdf

global efi_main

efi_main:
    push rbp
    mov rbp, rsp
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    sub rsp, 0x88

    mov [image_handle], rcx
    mov [system_table], rdx
    mov rax, [rdx + SYSTEM_TABLE_BOOT_SERVICES]
    mov [boot_services], rax

    lea rcx, [msg_step_entry]
    call debug_write
    call disable_watchdog

    call load_kernel_from_esp
    test rax, rax
    jnz .return_status

    call collect_gop_info
    test rax, rax
    jnz .return_status

    call capture_memory_map_and_exit_boot_services

.return_status:
    mov rbx, rax
    lea rcx, [msg_error_returning]
    mov rdx, rbx
    call debug_status_line
    mov rax, rbx
    add rsp, 0x88
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    pop rbp
    ret

disable_watchdog:
    push rbp
    mov rbp, rsp
    sub rsp, 0x80
    mov rax, [boot_services]
    xor ecx, ecx
    xor edx, edx
    xor r8d, r8d
    xor r9d, r9d
    call qword [rax + BOOT_SERVICES_SET_WATCHDOG_TIMER]
    leave
    ret

load_kernel_from_esp:
    push rbp
    mov rbp, rsp
    sub rsp, 0x80

    mov rax, [boot_services]
    mov rcx, [image_handle]
    lea rdx, [loaded_image_protocol_guid]
    lea r8, [loaded_image]
    call qword [rax + BOOT_SERVICES_HANDLE_PROTOCOL]
    test rax, rax
    jnz .loaded_image_failed

    mov rax, [loaded_image]
    mov rcx, [rax + LOADED_IMAGE_DEVICE_HANDLE]
    mov rax, [boot_services]
    lea rdx, [simple_file_system_protocol_guid]
    lea r8, [simple_file_system]
    call qword [rax + BOOT_SERVICES_HANDLE_PROTOCOL]
    test rax, rax
    jnz .filesystem_failed

    mov rcx, [simple_file_system]
    lea rdx, [root_file]
    call qword [rcx + 8]
    test rax, rax
    jnz .open_volume_failed

    mov qword [rsp + 32], 0
    mov rcx, [root_file]
    lea rdx, [kernel_file]
    lea r8, [kernel_path]
    mov r9, EFI_FILE_MODE_READ
    call qword [rcx + FILE_OPEN]
    test rax, rax
    jnz .open_kernel_failed

    mov qword [kernel_buffer], 0
    mov rax, [boot_services]
    mov ecx, ALLOCATE_ANY_PAGES
    mov edx, EFI_LOADER_DATA
    mov r8d, KERNEL_BUFFER_PAGES
    lea r9, [kernel_buffer]
    call qword [rax + BOOT_SERVICES_ALLOCATE_PAGES]
    test rax, rax
    jnz .allocate_kernel_failed

    mov qword [kernel_read_size], KERNEL_MAX_BYTES
    mov rcx, [kernel_file]
    lea rdx, [kernel_read_size]
    mov r8, [kernel_buffer]
    call qword [rcx + FILE_READ]
    test rax, rax
    jnz .read_kernel_failed

    cmp qword [kernel_read_size], KERNEL_MAX_BYTES
    jae .kernel_too_large

    mov rbx, [kernel_buffer]
    cmp qword [kernel_read_size], 52
    jb .bad_elf
    cmp dword [rbx], 0x464c457f
    jne .bad_elf
    cmp byte [rbx + 4], 1
    jne .bad_elf
    cmp byte [rbx + 5], 1
    jne .bad_elf
    cmp word [rbx + 16], 2
    jne .bad_elf
    cmp word [rbx + 18], 3
    jne .bad_elf
    cmp word [rbx + 42], 32
    jne .bad_elf
    mov eax, [rbx + 24]
    mov [kernel_entry32], rax

    mov rcx, [kernel_file]
    call qword [rcx + FILE_CLOSE]
    mov rcx, [root_file]
    call qword [rcx + FILE_CLOSE]

    lea rcx, [msg_step_kernel_read]
    call debug_write
    lea rcx, [msg_kernel_bytes]
    mov rdx, [kernel_read_size]
    call debug_hex_field
    lea rcx, [msg_kernel_entry]
    mov rdx, [kernel_entry32]
    call debug_hex_field
    call debug_newline
    xor eax, eax
    jmp .done

.loaded_image_failed:
    lea rcx, [msg_error_loaded_image]
    jmp .status_error

.filesystem_failed:
    lea rcx, [msg_error_filesystem]
    jmp .status_error

.open_volume_failed:
    lea rcx, [msg_error_open_volume]
    jmp .status_error

.open_kernel_failed:
    lea rcx, [msg_error_open_kernel]
    jmp .status_error

.allocate_kernel_failed:
    lea rcx, [msg_error_alloc_kernel]
    jmp .status_error

.read_kernel_failed:
    lea rcx, [msg_error_read_kernel]
    jmp .status_error

.kernel_too_large:
    lea rcx, [msg_error_kernel_too_large]
    mov rax, EFI_ABORTED
    jmp .status_error

.bad_elf:
    lea rcx, [msg_error_bad_elf]
    mov rax, EFI_ABORTED

.status_error:
    mov rdx, rax
    call debug_status_line
    mov rax, EFI_ABORTED

.done:
    leave
    ret

collect_gop_info:
    push rbp
    mov rbp, rsp
    sub rsp, 0x80

    mov rax, [boot_services]
    lea rcx, [graphics_output_protocol_guid]
    xor edx, edx
    lea r8, [gop]
    call qword [rax + BOOT_SERVICES_LOCATE_PROTOCOL]
    test rax, rax
    jnz .gop_failed

    mov rax, [gop]
    mov rax, [rax + GOP_MODE_OFFSET]
    mov [gop_mode], rax
    mov rbx, [rax + GOP_MODE_INFO]
    mov [gop_info], rbx
    mov eax, [rbx + GOP_INFO_WIDTH]
    mov [gop_width], rax
    mov eax, [rbx + GOP_INFO_HEIGHT]
    mov [gop_height], rax
    mov eax, [rbx + GOP_INFO_PIXEL_FORMAT]
    mov [gop_pixel_format], rax
    mov eax, [rbx + GOP_INFO_PIXELS_PER_SCAN_LINE]
    shl eax, 2
    mov [gop_pitch], rax
    mov rax, [gop_mode]
    mov rbx, [rax + GOP_MODE_FB_BASE]
    mov [gop_framebuffer_base], rbx
    mov rbx, [rax + GOP_MODE_FB_SIZE]
    mov [gop_framebuffer_size], rbx

    lea rcx, [msg_step_gop]
    call debug_write
    lea rcx, [msg_gop_fb]
    mov rdx, [gop_framebuffer_base]
    call debug_hex_field
    lea rcx, [msg_gop_size]
    mov rdx, [gop_framebuffer_size]
    call debug_hex_field
    lea rcx, [msg_gop_width]
    mov rdx, [gop_width]
    call debug_hex_field
    lea rcx, [msg_gop_height]
    mov rdx, [gop_height]
    call debug_hex_field
    lea rcx, [msg_gop_pitch]
    mov rdx, [gop_pitch]
    call debug_hex_field
    lea rcx, [msg_gop_format]
    mov rdx, [gop_pixel_format]
    call debug_hex_field
    call debug_newline
    xor eax, eax
    jmp .done

.gop_failed:
    lea rcx, [msg_error_gop]
    mov rdx, rax
    call debug_status_line
    mov rax, EFI_ABORTED

.done:
    leave
    ret

capture_memory_map_and_exit_boot_services:
    push rbp
    mov rbp, rsp
    sub rsp, 0x80

    call get_memory_map
    test rax, rax
    jnz .done
    call print_memory_map_step
    call prepare_kernel_handoff_plan

    mov rax, [boot_services]
    mov rcx, [image_handle]
    mov rdx, [memory_map_key]
    call qword [rax + BOOT_SERVICES_EXIT_BOOT_SERVICES]
    test rax, rax
    jz .exit_boot_services_ok

    mov [exit_boot_services_status], rax
    call get_memory_map
    test rax, rax
    jnz .exit_boot_services_failed
    mov rax, [boot_services]
    mov rcx, [image_handle]
    mov rdx, [memory_map_key]
    call qword [rax + BOOT_SERVICES_EXIT_BOOT_SERVICES]
    test rax, rax
    jz .exit_boot_services_ok

.exit_boot_services_failed:
    lea rcx, [msg_error_exit_boot_services]
    mov rdx, rax
    call debug_status_line
    mov rax, EFI_ABORTED
    jmp .done

.exit_boot_services_ok:
    lea rcx, [msg_step_exit_boot_services]
    call debug_write
    lea rcx, [msg_step_kernel_handoff_blocked]
    call debug_write
    mov dx, DEBUG_EXIT_PORT
    mov ax, 0x10
    out dx, ax
.halt:
    cli
    hlt
    jmp .halt

.done:
    leave
    ret

get_memory_map:
    mov qword [memory_map_size], MEMORY_MAP_BUFFER_BYTES
    mov qword [memory_map_key], 0
    mov qword [memory_map_descriptor_size], 0
    mov dword [memory_map_descriptor_version], 0
    mov rax, [boot_services]
    lea rcx, [memory_map_size]
    lea rdx, [memory_map_buffer]
    lea r8, [memory_map_key]
    lea r9, [memory_map_descriptor_size]
    lea r10, [memory_map_descriptor_version]
    mov [rsp + 32], r10
    call qword [rax + BOOT_SERVICES_GET_MEMORY_MAP]
    test rax, rax
    jz .done
    lea rcx, [msg_error_memory_map]
    mov rdx, rax
    call debug_status_line
    mov rax, EFI_ABORTED
.done:
    ret

print_memory_map_step:
    mov rax, [memory_map_size]
    xor edx, edx
    mov rcx, [memory_map_descriptor_size]
    test rcx, rcx
    jz .count_ready
    div rcx
    mov [memory_map_descriptor_count], rax
.count_ready:
    lea rcx, [msg_step_memory_map]
    call debug_write
    lea rcx, [msg_mmap_bytes]
    mov rdx, [memory_map_size]
    call debug_hex_field
    lea rcx, [msg_mmap_desc]
    mov rdx, [memory_map_descriptor_size]
    call debug_hex_field
    lea rcx, [msg_mmap_count]
    mov rdx, [memory_map_descriptor_count]
    call debug_hex_field
    lea rcx, [msg_mmap_key]
    mov rdx, [memory_map_key]
    call debug_hex_field
    call debug_newline
    ret

prepare_kernel_handoff_plan:
    mov dword [handoff_magic], UEFI_HANDOFF_MAGIC
    mov dword [handoff_version], UEFI_HANDOFF_VERSION
    mov qword [handoff_flags], UEFI_HANDOFF_FLAG_BOOTINFO_LAYOUT_READY | UEFI_HANDOFF_FLAG_TRANSITION_STUB_PRESENT | UEFI_HANDOFF_FLAG_FINAL_JUMP_DISABLED

    mov rax, [kernel_entry32]
    mov [handoff_entry32], rax
    mov qword [handoff_stack32], UEFI32_STACK_TOP
    mov qword [handoff_boot_info32], BOOT_INFO_ADDR
    mov qword [handoff_e820_map32], UEFI32_E820_MAP_ADDR
    mov qword [handoff_trampoline32], UEFI32_TRAMPOLINE_ADDR
    lea rax, [uefi_gdt_start]
    mov [handoff_gdt_base], rax
    mov qword [handoff_code_selector], UEFI32_CODE_SEG
    mov qword [handoff_data_selector], UEFI32_DATA_SEG
    mov rax, [kernel_buffer]
    mov [handoff_kernel_buffer], rax
    mov rax, [kernel_read_size]
    mov [handoff_kernel_read_size], rax
    mov rax, [gop_framebuffer_base]
    mov [handoff_framebuffer_base], rax
    mov rax, [gop_pitch]
    mov [handoff_pitch], rax
    mov rax, [gop_width]
    mov [handoff_width], rax
    mov rax, [gop_height]
    mov [handoff_height], rax
    mov rax, [gop_pixel_format]
    mov [handoff_pixel_format], rax
    lea rax, [memory_map_buffer]
    mov [handoff_mmap_buffer], rax
    mov rax, [memory_map_size]
    mov [handoff_mmap_size], rax
    mov rax, [memory_map_descriptor_size]
    mov [handoff_mmap_desc_size], rax
    mov rax, [memory_map_descriptor_count]
    mov [handoff_mmap_desc_count], rax

    cmp qword [memory_map_descriptor_count], 0
    je .mmap_flag_done
    or qword [handoff_flags], UEFI_HANDOFF_FLAG_MMAP_READY

.mmap_flag_done:
    cmp qword [gop_pixel_format], 1
    jne .gop_flag_done
    cmp qword [gop_pitch], 0
    je .gop_flag_done
    cmp qword [gop_framebuffer_base], 0
    je .gop_flag_done
    or qword [handoff_flags], UEFI_HANDOFF_FLAG_GOP_XRGB8888

.gop_flag_done:
    lea rcx, [msg_step_handoff_plan]
    call debug_write
    lea rcx, [msg_handoff_entry]
    mov rdx, [handoff_entry32]
    call debug_hex_field
    lea rcx, [msg_handoff_stack]
    mov rdx, [handoff_stack32]
    call debug_hex_field
    lea rcx, [msg_handoff_bootinfo]
    mov rdx, [handoff_boot_info32]
    call debug_hex_field
    lea rcx, [msg_handoff_trampoline]
    mov rdx, [handoff_trampoline32]
    call debug_hex_field
    lea rcx, [msg_handoff_gdt]
    mov rdx, [handoff_gdt_base]
    call debug_hex_field
    lea rcx, [msg_handoff_code]
    mov rdx, [handoff_code_selector]
    call debug_hex_field
    lea rcx, [msg_handoff_data]
    mov rdx, [handoff_data_selector]
    call debug_hex_field
    lea rcx, [msg_handoff_flags]
    mov rdx, [handoff_flags]
    call debug_hex_field
    call debug_newline
    xor eax, eax
    ret

copy_handoff_trampoline_to_low_memory:
    push rsi
    push rdi
    push rcx
    lea rsi, [uefi32_low_trampoline_start]
    mov edi, UEFI32_TRAMPOLINE_ADDR
    mov ecx, uefi32_low_trampoline_end - uefi32_low_trampoline_start
    cld
    rep movsb
    pop rcx
    pop rdi
    pop rsi
    ret

copy_handoff_block_to_low_memory:
    push rsi
    push rdi
    push rcx
    lea rsi, [uefi_handoff_block]
    mov edi, UEFI32_HANDOFF_BLOCK_ADDR
    mov ecx, UEFI_HANDOFF_BLOCK_BYTES
    cld
    rep movsb
    pop rcx
    pop rdi
    pop rsi
    ret

; Host-buildable transition stub. It is deliberately not called from the proof
; path yet: the current loader still has to reserve/populate the fixed low
; memory ranges and prove that the 32-bit kernel owns the first post-handoff
; marker. When enabled, this is the irreversible post-ExitBootServices path.
uefi64_to_protected32_transition_stub:
    lea rcx, [msg_step_transition_stub]
    call debug_write
    call copy_handoff_trampoline_to_low_memory
    call copy_handoff_block_to_low_memory
    cli
    lea rax, [uefi_gdt_start]
    mov [uefi_gdt64_descriptor + 2], rax
    lgdt [uefi_gdt64_descriptor]
    mov rax, cr0
    and eax, CR0_PG_CLEAR_MASK
    mov cr0, rax
    mov ecx, IA32_EFER_MSR
    rdmsr
    and eax, EFER_LME_CLEAR_MASK
    wrmsr
    mov rax, cr4
    and eax, CR4_PAE_CLEAR_MASK
    mov cr4, rax
    db 0xea
    dd UEFI32_TRAMPOLINE_ADDR
    dw UEFI32_CODE_SEG

bits 32
uefi32_low_trampoline_start:
    cli
    mov ax, UEFI32_DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, UEFI32_STACK_TOP
    mov edx, UEFI_HANDOFF_MAGIC
    mov ebx, BOOT_INFO_ADDR
    mov ecx, UEFI32_HANDOFF_BLOCK_ADDR
    mov esi, UEFI32_E820_MAP_ADDR
    mov eax, [UEFI32_HANDOFF_BLOCK_ADDR + UEFI_HANDOFF_ENTRY32_OFF]
    test eax, eax
    jz .halt
    jmp eax

.halt:
    hlt
    jmp .halt

uefi32_low_trampoline_end:
bits 64
default rel

debug_status_line:
    push rdx
    call debug_write
    pop rcx
    call debug_hex64
    call debug_newline
    ret

debug_hex_field:
    push rdx
    call debug_write
    pop rcx
    call debug_hex64
    ret

debug_newline:
    lea rcx, [msg_newline]
    call debug_write
    ret

debug_write:
    push rax
    push rcx
    push rdx
    push rsi
    mov rsi, rcx
    mov dx, DEBUGCON_PORT
.next:
    lodsb
    test al, al
    jz .done
    out dx, al
    jmp .next
.done:
    pop rsi
    pop rdx
    pop rcx
    pop rax
    ret

debug_hex64:
    push rax
    push rbx
    push rcx
    push rdx
    push r8
    push r9
    push r10
    mov r10, rcx
    lea r8, [hex_digits]
    mov r9d, 16
    mov dx, DEBUGCON_PORT
.digit:
    mov rax, r10
    shr rax, 60
    mov ebx, eax
    mov al, [r8 + rbx]
    out dx, al
    shl r10, 4
    dec r9d
    jnz .digit
    pop r10
    pop r9
    pop r8
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

align 8
loaded_image_protocol_guid:
    dd 0x5b1b31a1
    dw 0x9562
    dw 0x11d2
    db 0x8e, 0x3f, 0x00, 0xa0, 0xc9, 0x69, 0x72, 0x3b

simple_file_system_protocol_guid:
    dd 0x964e5b22
    dw 0x6459
    dw 0x11d2
    db 0x8e, 0x39, 0x00, 0xa0, 0xc9, 0x69, 0x72, 0x3b

graphics_output_protocol_guid:
    dd 0x9042a9de
    dw 0x23dc
    dw 0x4a38
    db 0x96, 0xfb, 0x7a, 0xde, 0xd0, 0x80, 0x51, 0x6a

kernel_path:
    dw 0x005c, 'V', 'I', 'B', 'E', 'O', 'S'
    dw 0x005c, 'K', 'E', 'R', 'N', 'E', 'L', '.', 'E', 'L', 'F', 0

msg_step_entry db "VIBEUEFI step=entry", 10, 0
msg_step_kernel_read db "VIBEUEFI step=esp-kernel-read", 0
msg_step_gop db "VIBEUEFI step=gop", 0
msg_step_memory_map db "VIBEUEFI step=memory-map", 0
msg_step_exit_boot_services db "VIBEUEFI step=exit-boot-services status=success", 10, 0
msg_step_handoff_plan db "VIBEUEFI step=handoff-plan status=stub", 0
msg_step_transition_stub db "VIBEUEFI step=uefi64-to-protected32-transition status=stub", 10, 0
msg_step_kernel_handoff_blocked db "VIBEUEFI step=kernel-handoff status=blocked reason=final-jump-disabled-until-low-memory-elf32-placement-and-kernel-entry-marker-proof", 10, 0
msg_kernel_bytes db " bytes=0x", 0
msg_kernel_entry db " entry32=0x", 0
msg_gop_fb db " fb=0x", 0
msg_gop_size db " fbsize=0x", 0
msg_gop_width db " width=0x", 0
msg_gop_height db " height=0x", 0
msg_gop_pitch db " pitch=0x", 0
msg_gop_format db " pixfmt=0x", 0
msg_mmap_bytes db " bytes=0x", 0
msg_mmap_desc db " desc=0x", 0
msg_mmap_count db " count=0x", 0
msg_mmap_key db " key=0x", 0
msg_handoff_entry db " entry32=0x", 0
msg_handoff_stack db " stack32=0x", 0
msg_handoff_bootinfo db " bootinfo=0x", 0
msg_handoff_trampoline db " tramp32=0x", 0
msg_handoff_gdt db " gdt=0x", 0
msg_handoff_code db " code=0x", 0
msg_handoff_data db " data=0x", 0
msg_handoff_flags db " flags=0x", 0
msg_error_loaded_image db "VIBEUEFI error=loaded-image status=0x", 0
msg_error_filesystem db "VIBEUEFI error=simple-filesystem status=0x", 0
msg_error_open_volume db "VIBEUEFI error=open-volume status=0x", 0
msg_error_open_kernel db "VIBEUEFI error=open-kernel status=0x", 0
msg_error_alloc_kernel db "VIBEUEFI error=allocate-kernel-buffer status=0x", 0
msg_error_read_kernel db "VIBEUEFI error=read-kernel status=0x", 0
msg_error_kernel_too_large db "VIBEUEFI error=kernel-too-large status=0x", 0
msg_error_bad_elf db "VIBEUEFI error=bad-elf32-kernel status=0x", 0
msg_error_gop db "VIBEUEFI error=gop status=0x", 0
msg_error_memory_map db "VIBEUEFI error=memory-map status=0x", 0
msg_error_exit_boot_services db "VIBEUEFI error=exit-boot-services status=0x", 0
msg_error_returning db "VIBEUEFI result=returning-to-firmware status=0x", 0
msg_newline db 10, 0
hex_digits db "0123456789ABCDEF"

align 8
image_handle dq 0
system_table dq 0
boot_services dq 0
loaded_image dq 0
simple_file_system dq 0
root_file dq 0
kernel_file dq 0
kernel_buffer dq 0
kernel_read_size dq 0
kernel_entry32 dq 0
gop dq 0
gop_mode dq 0
gop_info dq 0
gop_framebuffer_base dq 0
gop_framebuffer_size dq 0
gop_width dq 0
gop_height dq 0
gop_pitch dq 0
gop_pixel_format dq 0
memory_map_size dq 0
memory_map_key dq 0
memory_map_descriptor_size dq 0
memory_map_descriptor_count dq 0
memory_map_descriptor_version dd 0
exit_boot_services_status dq 0

align 16
uefi_handoff_block:
handoff_magic dd 0
handoff_version dd 0
handoff_flags dq 0
handoff_entry32 dq 0
handoff_stack32 dq 0
handoff_boot_info32 dq 0
handoff_e820_map32 dq 0
handoff_trampoline32 dq 0
handoff_gdt_base dq 0
handoff_code_selector dq 0
handoff_data_selector dq 0
handoff_kernel_buffer dq 0
handoff_kernel_read_size dq 0
handoff_framebuffer_base dq 0
handoff_pitch dq 0
handoff_width dq 0
handoff_height dq 0
handoff_pixel_format dq 0
handoff_mmap_buffer dq 0
handoff_mmap_size dq 0
handoff_mmap_desc_size dq 0
handoff_mmap_desc_count dq 0
uefi_handoff_block_end:

align 8
uefi_gdt_start:
uefi_gdt_null:
    dq 0

uefi_gdt_code32:
    dw 0xffff
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00

uefi_gdt_data32:
    dw 0xffff
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00

uefi_gdt_code64:
    dw 0x0000
    dw 0x0000
    db 0x00
    db 10011010b
    db 00100000b
    db 0x00

uefi_gdt_end:

uefi_gdt64_descriptor:
    dw uefi_gdt_end - uefi_gdt_start - 1
    dq 0

align 16
memory_map_buffer:
    times MEMORY_MAP_BUFFER_BYTES db 0
