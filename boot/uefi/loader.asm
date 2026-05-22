bits 64
default rel

; x86_64 UEFI proof loader.
;
; This is intentionally an unclaimed loader/proof rung until an OVMF run proves
; a kernel-owned entry marker. It reads VIBEOS/KERNEL.ELF from the ESP, records
; GOP and memory-map facts, places ELF32 PT_LOAD segments, synthesizes the
; legacy boot-info/E820 block, calls ExitBootServices, emits debugcon markers
; for cloud parsing, then attempts the 64-bit UEFI to 32-bit kernel handoff.

EFI_SUCCESS equ 0
EFI_ABORTED equ 0x8000000000000015
EFI_FILE_MODE_READ equ 0x0000000000000001
EFI_LOADER_CODE equ 1
EFI_LOADER_DATA equ 2
EFI_BOOT_SERVICES_CODE equ 3
EFI_BOOT_SERVICES_DATA equ 4
EFI_CONVENTIONAL_MEMORY equ 7
EFI_UNUSABLE_MEMORY equ 8
EFI_ACPI_RECLAIM_MEMORY equ 9
EFI_ACPI_MEMORY_NVS equ 10
ALLOCATE_ANY_PAGES equ 0
ALLOCATE_MAX_ADDRESS equ 1
ALLOCATE_ADDRESS equ 2
PAGE_SIZE equ 0x1000

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

KERNEL_MAX_BYTES equ 0x00028000
KERNEL_BUFFER_PAGES equ KERNEL_MAX_BYTES / 0x1000
KERNEL_PHYS equ 0x00010000
KERNEL_LOAD_LIMIT equ 0x00040000
MEMORY_MAP_BUFFER_BYTES equ 0x00010000
DEBUGCON_PORT equ 0x0402

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
E820_ENTRY_SIZE equ 24
E820_MAX_ENTRIES equ 32
E820_TYPE_USABLE equ 1
E820_TYPE_RESERVED equ 2
E820_TYPE_ACPI_RECLAIM equ 3
E820_TYPE_ACPI_NVS equ 4
E820_TYPE_UNUSABLE equ 5
UEFI_E820_LOW_LIMIT equ 0x02000000
UEFI32_E820_MAP_ADDR equ 0x00007100
UEFI32_TRAMPOLINE_ADDR equ 0x00008000
UEFI32_HANDOFF_BLOCK_ADDR equ 0x00009000
UEFI64_TRANSITION_ADDR equ 0x0000a000
UEFI32_STACK_LOW equ 0x00060000
UEFI32_STACK_TOP equ 0x00070000
UEFI32_CODE_SEG equ 0x08
UEFI32_DATA_SEG equ 0x10

ELF_MAGIC equ 0x464c457f
ELFCLASS32 equ 1
ELFDATA2LSB equ 1
ELF_VERSION_CURRENT equ 1
ET_EXEC equ 2
EM_386 equ 3
PT_LOAD equ 1
ELF32_HEADER_SIZE equ 52
ELF32_MAX_PHDRS equ 16
ELF32_E_IDENT_VERSION equ 6
ELF32_E_TYPE equ 16
ELF32_E_MACHINE equ 18
ELF32_E_VERSION equ 20
ELF32_E_ENTRY equ 24
ELF32_E_PHOFF equ 28
ELF32_E_EHSIZE equ 40
ELF32_E_PHENTSIZE equ 42
ELF32_E_PHNUM equ 44
ELF32_PHDR_P_TYPE equ 0
ELF32_PHDR_P_OFFSET equ 4
ELF32_PHDR_P_VADDR equ 8
ELF32_PHDR_P_PADDR equ 12
ELF32_PHDR_P_FILESZ equ 16
ELF32_PHDR_P_MEMSZ equ 20
ELF32_PHDR_P_ALIGN equ 28
ELF32_PROGRAM_HEADER_SIZE equ 32

UEFI_MEMORY_TYPE_OFF equ 0
UEFI_MEMORY_PHYSICAL_START_OFF equ 8
UEFI_MEMORY_NUMBER_OF_PAGES_OFF equ 24
UEFI_MEMORY_DESCRIPTOR_MIN_BYTES equ 32

UEFI_HANDOFF_MAGIC equ 0x444e4855
UEFI_HANDOFF_VERSION equ 1
UEFI_HANDOFF_FLAG_GOP_XRGB8888 equ 0x00000001
UEFI_HANDOFF_FLAG_MMAP_READY equ 0x00000002
UEFI_HANDOFF_FLAG_BOOTINFO_LAYOUT_READY equ 0x00000004
UEFI_HANDOFF_FLAG_TRANSITION_STUB_PRESENT equ 0x00000008
UEFI_HANDOFF_FLAG_ELF32_SEGMENTS_READY equ 0x00000010
UEFI_HANDOFF_FLAG_LOW_MEMORY_READY equ 0x00000020
UEFI_HANDOFF_FLAG_FINAL_JUMP_ENABLED equ 0x00000040
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
UEFI_HANDOFF_LOADED_SEGMENTS_OFF equ 168
UEFI_HANDOFF_TRANSITION64_OFF equ 176
UEFI_HANDOFF_BLOCK_BYTES equ 184
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

    call reserve_low_handoff_pages
    test rax, rax
    jnz .return_status

    call load_elf32_kernel_segments
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

    mov rax, 0x00000000ffffffff
    mov [kernel_buffer], rax
    mov rax, [boot_services]
    mov ecx, ALLOCATE_MAX_ADDRESS
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
    cmp dword [rbx], ELF_MAGIC
    jne .bad_elf
    cmp byte [rbx + 4], ELFCLASS32
    jne .bad_elf
    cmp byte [rbx + 5], ELFDATA2LSB
    jne .bad_elf
    cmp byte [rbx + ELF32_E_IDENT_VERSION], ELF_VERSION_CURRENT
    jne .bad_elf
    cmp word [rbx + ELF32_E_TYPE], ET_EXEC
    jne .bad_elf
    cmp word [rbx + ELF32_E_MACHINE], EM_386
    jne .bad_elf
    cmp dword [rbx + ELF32_E_VERSION], ELF_VERSION_CURRENT
    jne .bad_elf
    cmp word [rbx + ELF32_E_EHSIZE], ELF32_HEADER_SIZE
    jne .bad_elf
    cmp word [rbx + ELF32_E_PHENTSIZE], ELF32_PROGRAM_HEADER_SIZE
    jne .bad_elf
    mov eax, [rbx + ELF32_E_ENTRY]
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

reserve_physical_pages:
    push rbp
    mov rbp, rsp
    sub rsp, 0x80
    mov [alloc_target], rcx
    mov r10, rdx
    mov r11, r8
    mov rax, [boot_services]
    mov ecx, ALLOCATE_ADDRESS
    mov rdx, r11
    mov r8, r10
    lea r9, [alloc_target]
    call qword [rax + BOOT_SERVICES_ALLOCATE_PAGES]
    leave
    ret

reserve_low_handoff_pages:
    push rbp
    mov rbp, rsp
    sub rsp, 0x80

    mov ecx, BOOT_INFO_ADDR
    mov edx, 1
    mov r8d, EFI_LOADER_DATA
    call reserve_physical_pages
    test rax, rax
    jnz .reserve_failed

    mov ecx, UEFI32_TRAMPOLINE_ADDR
    mov edx, 1
    mov r8d, EFI_LOADER_CODE
    call reserve_physical_pages
    test rax, rax
    jnz .reserve_failed

    mov ecx, UEFI32_HANDOFF_BLOCK_ADDR
    mov edx, 1
    mov r8d, EFI_LOADER_DATA
    call reserve_physical_pages
    test rax, rax
    jnz .reserve_failed

    mov ecx, UEFI64_TRANSITION_ADDR
    mov edx, 1
    mov r8d, EFI_LOADER_CODE
    call reserve_physical_pages
    test rax, rax
    jnz .reserve_failed

    mov ecx, UEFI32_STACK_LOW
    mov edx, (UEFI32_STACK_TOP - UEFI32_STACK_LOW) / PAGE_SIZE
    mov r8d, EFI_LOADER_DATA
    call reserve_physical_pages
    test rax, rax
    jnz .reserve_failed

    mov qword [low_handoff_ready], 1
    lea rcx, [msg_step_low_reserved]
    call debug_write
    lea rcx, [msg_low_bootinfo]
    mov edx, BOOT_INFO_ADDR
    call debug_hex_field
    lea rcx, [msg_low_trampoline]
    mov edx, UEFI32_TRAMPOLINE_ADDR
    call debug_hex_field
    lea rcx, [msg_low_transition64]
    mov edx, UEFI64_TRANSITION_ADDR
    call debug_hex_field
    lea rcx, [msg_low_stack]
    mov edx, UEFI32_STACK_TOP
    call debug_hex_field
    call debug_newline
    xor eax, eax
    jmp .done

.reserve_failed:
    lea rcx, [msg_error_low_reserve]
    mov rdx, rax
    call debug_status_line
    mov rax, EFI_ABORTED

.done:
    leave
    ret

load_elf32_kernel_segments:
    push rbp
    mov rbp, rsp
    sub rsp, 0x80

    mov rsi, [kernel_buffer]
    cmp dword [rsi], ELF_MAGIC
    jne .bad_elf
    cmp byte [rsi + 4], ELFCLASS32
    jne .bad_elf
    cmp byte [rsi + 5], ELFDATA2LSB
    jne .bad_elf
    cmp byte [rsi + ELF32_E_IDENT_VERSION], ELF_VERSION_CURRENT
    jne .bad_elf
    cmp word [rsi + ELF32_E_TYPE], ET_EXEC
    jne .bad_elf
    cmp word [rsi + ELF32_E_MACHINE], EM_386
    jne .bad_elf
    cmp dword [rsi + ELF32_E_VERSION], ELF_VERSION_CURRENT
    jne .bad_elf
    cmp word [rsi + ELF32_E_EHSIZE], ELF32_HEADER_SIZE
    jne .bad_elf
    cmp word [rsi + ELF32_E_PHENTSIZE], ELF32_PROGRAM_HEADER_SIZE
    jne .bad_elf
    mov eax, [rsi + ELF32_E_ENTRY]
    test eax, eax
    jz .bad_elf
    mov eax, [rsi + ELF32_E_PHOFF]
    mov r13, rax
    movzx r15d, word [rsi + ELF32_E_PHNUM]
    test r15d, r15d
    jz .bad_elf
    cmp r15d, ELF32_MAX_PHDRS
    ja .bad_elf
    cmp r13, ELF32_HEADER_SIZE
    jb .bad_elf

    mov rax, r15
    shl rax, 5
    add rax, r13
    jc .bad_elf
    cmp rax, [kernel_read_size]
    ja .bad_elf

    lea rbx, [rsi + r13]
    xor r12d, r12d
    mov byte [kernel_entry_covered], 0

.program_header:
    cmp dword [rbx + ELF32_PHDR_P_TYPE], PT_LOAD
    jne .next_header

    cmp dword [rbx + ELF32_PHDR_P_ALIGN], PAGE_SIZE
    jne .bad_elf
    mov edx, [rbx + ELF32_PHDR_P_FILESZ]
    mov eax, [rbx + ELF32_PHDR_P_MEMSZ]
    cmp eax, edx
    jb .bad_elf
    test eax, eax
    jz .next_header

    mov r13d, [rbx + ELF32_PHDR_P_PADDR]
    cmp r13d, [rbx + ELF32_PHDR_P_VADDR]
    jne .bad_elf
    test r13d, r13d
    jz .bad_elf
    cmp r13d, KERNEL_PHYS
    jb .bad_elf
    mov eax, r13d
    add eax, [rbx + ELF32_PHDR_P_MEMSZ]
    jc .bad_elf
    cmp eax, KERNEL_LOAD_LIMIT
    ja .bad_elf

    mov eax, [rbx + ELF32_PHDR_P_OFFSET]
    add eax, [rbx + ELF32_PHDR_P_FILESZ]
    jc .bad_elf
    cmp rax, [kernel_read_size]
    ja .bad_elf

    mov r14d, r13d
    and r14d, 0xfffff000
    mov eax, r13d
    and eax, 0x00000fff
    add eax, [rbx + ELF32_PHDR_P_MEMSZ]
    jc .bad_elf
    add eax, PAGE_SIZE - 1
    jc .bad_elf
    shr eax, 12
    test eax, eax
    jz .bad_elf
    mov r10d, eax

    mov eax, [kernel_entry32]
    cmp eax, r13d
    jb .entry_check_done
    mov edx, r13d
    add edx, [rbx + ELF32_PHDR_P_MEMSZ]
    jc .bad_elf
    cmp eax, edx
    jae .entry_check_done
    mov byte [kernel_entry_covered], 1

.entry_check_done:
    mov rcx, r14
    mov edx, r10d
    mov r8d, EFI_LOADER_DATA
    call reserve_physical_pages
    test rax, rax
    jnz .segment_reserve_failed

    mov rsi, [kernel_buffer]
    mov eax, [rbx + ELF32_PHDR_P_OFFSET]
    add rsi, rax
    mov rdi, r13
    mov ecx, [rbx + ELF32_PHDR_P_FILESZ]
    cld
    rep movsb

    mov ecx, [rbx + ELF32_PHDR_P_MEMSZ]
    sub ecx, [rbx + ELF32_PHDR_P_FILESZ]
    jz .segment_done
    xor eax, eax
    rep stosb

.segment_done:
    inc r12d

.next_header:
    add rbx, ELF32_PROGRAM_HEADER_SIZE
    dec r15d
    jnz .program_header

    test r12d, r12d
    jz .bad_elf
    cmp byte [kernel_entry_covered], 1
    jne .bad_elf
    mov [kernel_loaded_segments], r12
    lea rcx, [msg_step_elf_loaded]
    call debug_write
    lea rcx, [msg_handoff_entry]
    mov rdx, [kernel_entry32]
    call debug_hex_field
    lea rcx, [msg_elf_segments]
    mov rdx, [kernel_loaded_segments]
    call debug_hex_field
    call debug_newline
    xor eax, eax
    jmp .done

.segment_reserve_failed:
    lea rcx, [msg_error_kernel_segment_reserve]
    mov rdx, rax
    call debug_status_line
    mov rax, EFI_ABORTED
    jmp .done

.bad_elf:
    lea rcx, [msg_error_elf_segments]
    mov rdx, EFI_ABORTED
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
    call prepare_handoff_material
    test rax, rax
    jnz .done

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
    call print_memory_map_step
    call prepare_handoff_material
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
    call emit_kernel_handoff_attempt
    mov rax, UEFI64_TRANSITION_ADDR
    jmp rax

.done:
    leave
    ret

get_memory_map:
    push rbp
    mov rbp, rsp
    sub rsp, 0x80
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
    jz .success
    lea rcx, [msg_error_memory_map]
    mov rdx, rax
    call debug_status_line
    mov rax, EFI_ABORTED
    jmp .done
.success:
    cmp qword [memory_map_descriptor_size], UEFI_MEMORY_DESCRIPTOR_MIN_BYTES
    jb .bad_shape
    mov rax, [memory_map_size]
    cmp rax, MEMORY_MAP_BUFFER_BYTES
    ja .bad_shape
    cmp rax, [memory_map_descriptor_size]
    jb .bad_shape
    xor eax, eax
    jmp .done
.bad_shape:
    lea rcx, [msg_error_memory_map_shape]
    mov rdx, EFI_ABORTED
    call debug_status_line
    mov rax, EFI_ABORTED
.done:
    leave
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

prepare_handoff_material:
    call synthesize_boot_info_from_uefi
    test rax, rax
    jnz .done
    call prepare_kernel_handoff
    test rax, rax
    jnz .done
    call copy_handoff_trampoline_to_low_memory
    call copy_handoff_block_to_low_memory
    call copy_transition64_to_low_memory
    call validate_low_handoff_copy
    test rax, rax
    jnz .done
    xor eax, eax

.done:
    ret

synthesize_boot_info_from_uefi:
    mov edi, BOOT_INFO_ADDR
    xor eax, eax
    mov ecx, PAGE_SIZE / 8
    cld
    rep stosq

    mov word [abs BOOT_INFO_ADDR], 640
    mov byte [abs BOOT_INFO_ADDR + 2], 0
    mov word [abs BOOT_INFO_ADDR + 4], (UEFI_E820_LOW_LIMIT - 0x00100000) / 1024
    mov word [abs BOOT_E820_ENTRY_SIZE_ADDR], E820_ENTRY_SIZE
    mov dword [abs BOOT_E820_MAP_ADDR_PTR], UEFI32_E820_MAP_ADDR

    call synthesize_e820_map
    call synthesize_gop_boot_video
    call validate_uefi_boot_info
    test rax, rax
    jnz .done

    lea rcx, [msg_step_boot_info]
    call debug_write
    lea rcx, [msg_bootinfo_flags]
    movzx edx, word [abs BOOT_VIDEO_FLAGS]
    call debug_hex_field
    lea rcx, [msg_bootinfo_e820]
    movzx edx, word [abs BOOT_E820_COUNT]
    call debug_hex_field
    call debug_newline
    xor eax, eax

.done:
    ret

synthesize_e820_map:
    mov edi, UEFI32_E820_MAP_ADDR
    xor eax, eax
    mov ecx, (E820_ENTRY_SIZE * E820_MAX_ENTRIES) / 8
    cld
    rep stosq

    lea rsi, [memory_map_buffer]
    mov rbx, [memory_map_size]
    mov r11, [memory_map_descriptor_size]
    xor r15d, r15d
    test r11, r11
    jz .done
    mov r14d, UEFI32_E820_MAP_ADDR

.descriptor_loop:
    cmp rbx, r11
    jb .done
    cmp r15d, E820_MAX_ENTRIES
    jae .done

    mov r8, [rsi + UEFI_MEMORY_PHYSICAL_START_OFF]
    cmp r8, UEFI_E820_LOW_LIMIT
    jae .next_descriptor

    mov r9, [rsi + UEFI_MEMORY_NUMBER_OF_PAGES_OFF]
    test r9, r9
    jz .next_descriptor
    shl r9, 12
    jz .next_descriptor
    mov r10, r8
    add r10, r9
    jc .clip_end
    cmp r10, UEFI_E820_LOW_LIMIT
    jbe .length_ready

.clip_end:
    mov r10d, UEFI_E820_LOW_LIMIT

.length_ready:
    cmp r10, r8
    jbe .next_descriptor
    mov r9, r10
    sub r9, r8

    mov eax, [rsi + UEFI_MEMORY_TYPE_OFF]
    cmp eax, EFI_CONVENTIONAL_MEMORY
    je .usable
    cmp eax, EFI_BOOT_SERVICES_CODE
    je .usable
    cmp eax, EFI_BOOT_SERVICES_DATA
    je .usable
    cmp eax, EFI_ACPI_RECLAIM_MEMORY
    je .acpi_reclaim
    cmp eax, EFI_ACPI_MEMORY_NVS
    je .acpi_nvs
    cmp eax, EFI_UNUSABLE_MEMORY
    je .unusable
    mov eax, E820_TYPE_RESERVED
    jmp .type_ready

.usable:
    mov eax, E820_TYPE_USABLE
    jmp .type_ready

.acpi_reclaim:
    mov eax, E820_TYPE_ACPI_RECLAIM
    jmp .type_ready

.acpi_nvs:
    mov eax, E820_TYPE_ACPI_NVS
    jmp .type_ready

.unusable:
    mov eax, E820_TYPE_UNUSABLE

.type_ready:
    mov [r14], r8
    mov [r14 + 8], r9
    mov [r14 + 16], eax
    mov dword [r14 + 20], 1
    add r14, E820_ENTRY_SIZE
    inc r15d

.next_descriptor:
    add rsi, r11
    sub rbx, r11
    jmp .descriptor_loop

.done:
    test r15d, r15d
    jz .no_entries
    mov [abs BOOT_E820_COUNT], r15w
    mov dword [abs BOOT_E820_MAGIC_ADDR], BOOT_E820_MAGIC

.no_entries:
    mov [e820_entry_count], r15
    ret

synthesize_gop_boot_video:
    cmp qword [gop_pixel_format], 1
    jne .done
    mov rax, [gop_framebuffer_base]
    test rax, rax
    jz .done
    mov edx, 0xffffffff
    cmp rax, rdx
    ja .done
    mov rax, [gop_pitch]
    cmp rax, rdx
    ja .done
    cmp qword [gop_width], 0xffff
    ja .done
    cmp qword [gop_height], 0xffff
    ja .done

    mov dword [abs BOOT_INFO_ADDR + 8], BOOT_VIDEO_MAGIC
    mov word [abs BOOT_VIDEO_MODE], 0xffff
    mov word [abs BOOT_VIDEO_FLAGS], BOOT_VIDEO_FLAG_VBE | BOOT_VIDEO_FLAG_LFB | BOOT_VIDEO_FLAG_XRGB8888
    mov eax, [gop_framebuffer_base]
    mov [abs BOOT_VIDEO_FB_ADDR], eax
    mov eax, [gop_pitch]
    mov [abs BOOT_VIDEO_PITCH], eax
    mov ax, [gop_width]
    mov [abs BOOT_VIDEO_WIDTH], ax
    mov ax, [gop_height]
    mov [abs BOOT_VIDEO_HEIGHT], ax
    mov byte [abs BOOT_VIDEO_BPP], 32
    mov byte [abs BOOT_VIDEO_MEMORY_MODEL], 6
    mov byte [abs BOOT_VIDEO_RED_MASK], 8
    mov byte [abs BOOT_VIDEO_RED_POS], 16
    mov byte [abs BOOT_VIDEO_GREEN_MASK], 8
    mov byte [abs BOOT_VIDEO_GREEN_POS], 8
    mov byte [abs BOOT_VIDEO_BLUE_MASK], 8
    mov byte [abs BOOT_VIDEO_BLUE_POS], 0

.done:
    ret

validate_uefi_boot_info:
    cmp dword [abs BOOT_INFO_ADDR + 8], BOOT_VIDEO_MAGIC
    jne .fail
    cmp dword [abs BOOT_VIDEO_FB_ADDR], 0
    je .fail
    cmp dword [abs BOOT_VIDEO_PITCH], 0
    je .fail
    cmp word [abs BOOT_VIDEO_WIDTH], 0
    je .fail
    cmp word [abs BOOT_VIDEO_HEIGHT], 0
    je .fail
    mov eax, [abs BOOT_VIDEO_PITCH]
    movzx ecx, word [abs BOOT_VIDEO_HEIGHT]
    mul ecx
    test edx, edx
    jnz .fail
    test eax, eax
    jz .fail
    add eax, [abs BOOT_VIDEO_FB_ADDR]
    jc .fail
    cmp dword [abs BOOT_E820_MAGIC_ADDR], BOOT_E820_MAGIC
    jne .fail
    cmp word [abs BOOT_E820_COUNT], 0
    je .fail
    cmp word [abs BOOT_E820_COUNT], E820_MAX_ENTRIES
    ja .fail
    cmp word [abs BOOT_E820_ENTRY_SIZE_ADDR], E820_ENTRY_SIZE
    jne .fail
    cmp dword [abs BOOT_E820_MAP_ADDR_PTR], UEFI32_E820_MAP_ADDR
    jne .fail
    xor eax, eax
    ret

.fail:
    lea rcx, [msg_error_boot_info]
    mov rdx, EFI_ABORTED
    call debug_status_line
    mov rax, EFI_ABORTED
    ret

prepare_kernel_handoff:
    cmp qword [low_handoff_ready], 1
    jne .precondition_failed
    cmp qword [kernel_loaded_segments], 0
    je .precondition_failed
    cmp byte [kernel_entry_covered], 1
    jne .precondition_failed

    mov dword [handoff_magic], UEFI_HANDOFF_MAGIC
    mov dword [handoff_version], UEFI_HANDOFF_VERSION
    mov qword [handoff_flags], UEFI_HANDOFF_FLAG_BOOTINFO_LAYOUT_READY | UEFI_HANDOFF_FLAG_TRANSITION_STUB_PRESENT | UEFI_HANDOFF_FLAG_ELF32_SEGMENTS_READY | UEFI_HANDOFF_FLAG_LOW_MEMORY_READY | UEFI_HANDOFF_FLAG_FINAL_JUMP_ENABLED

    mov rax, [kernel_entry32]
    mov [handoff_entry32], rax
    mov qword [handoff_stack32], UEFI32_STACK_TOP
    mov qword [handoff_boot_info32], BOOT_INFO_ADDR
    mov qword [handoff_e820_map32], UEFI32_E820_MAP_ADDR
    mov qword [handoff_trampoline32], UEFI32_TRAMPOLINE_ADDR
    mov rax, UEFI64_TRANSITION_ADDR + (uefi64_low_gdt_start - uefi64_low_transition_start)
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
    mov rax, [kernel_loaded_segments]
    mov [handoff_loaded_segments], rax
    mov qword [handoff_transition64], UEFI64_TRANSITION_ADDR

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
    lea rcx, [msg_elf_segments]
    mov rdx, [handoff_loaded_segments]
    call debug_hex_field
    lea rcx, [msg_low_transition64]
    mov rdx, [handoff_transition64]
    call debug_hex_field
    call debug_newline
    xor eax, eax
    ret

.precondition_failed:
    lea rcx, [msg_error_handoff_precondition]
    mov rdx, EFI_ABORTED
    call debug_status_line
    mov rax, EFI_ABORTED
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

copy_transition64_to_low_memory:
    push rsi
    push rdi
    push rcx
    lea rsi, [uefi64_low_transition_start]
    mov edi, UEFI64_TRANSITION_ADDR
    mov ecx, uefi64_low_transition_end - uefi64_low_transition_start
    cld
    rep movsb
    pop rcx
    pop rdi
    pop rsi
    ret

validate_low_handoff_copy:
    cmp dword [abs UEFI32_HANDOFF_BLOCK_ADDR + UEFI_HANDOFF_MAGIC_OFF], UEFI_HANDOFF_MAGIC
    jne .fail
    cmp dword [abs UEFI32_HANDOFF_BLOCK_ADDR + UEFI_HANDOFF_VERSION_OFF], UEFI_HANDOFF_VERSION
    jne .fail
    mov eax, [handoff_flags]
    cmp dword [abs UEFI32_HANDOFF_BLOCK_ADDR + UEFI_HANDOFF_FLAGS_OFF], eax
    jne .fail
    mov eax, [handoff_entry32]
    cmp dword [abs UEFI32_HANDOFF_BLOCK_ADDR + UEFI_HANDOFF_ENTRY32_OFF], eax
    jne .fail
    cmp dword [abs UEFI32_HANDOFF_BLOCK_ADDR + UEFI_HANDOFF_STACK32_OFF], UEFI32_STACK_TOP
    jne .fail
    cmp dword [abs UEFI32_HANDOFF_BLOCK_ADDR + UEFI_HANDOFF_BOOT_INFO32_OFF], BOOT_INFO_ADDR
    jne .fail
    cmp dword [abs UEFI32_HANDOFF_BLOCK_ADDR + UEFI_HANDOFF_E820_MAP32_OFF], UEFI32_E820_MAP_ADDR
    jne .fail
    cmp dword [abs UEFI32_HANDOFF_BLOCK_ADDR + UEFI_HANDOFF_TRAMPOLINE32_OFF], UEFI32_TRAMPOLINE_ADDR
    jne .fail
    cmp dword [abs UEFI32_HANDOFF_BLOCK_ADDR + UEFI_HANDOFF_CODE_SELECTOR_OFF], UEFI32_CODE_SEG
    jne .fail
    cmp dword [abs UEFI32_HANDOFF_BLOCK_ADDR + UEFI_HANDOFF_DATA_SELECTOR_OFF], UEFI32_DATA_SEG
    jne .fail
    cmp dword [abs UEFI32_HANDOFF_BLOCK_ADDR + UEFI_HANDOFF_LOADED_SEGMENTS_OFF], 0
    je .fail
    cmp dword [abs UEFI32_HANDOFF_BLOCK_ADDR + UEFI_HANDOFF_TRANSITION64_OFF], UEFI64_TRANSITION_ADDR
    jne .fail
    cmp byte [abs UEFI32_TRAMPOLINE_ADDR], 0xfa
    jne .fail
    cmp byte [abs UEFI64_TRANSITION_ADDR], 0xfa
    jne .fail

    lea rcx, [msg_step_low_handoff_copy]
    call debug_write
    lea rcx, [msg_handoff_entry]
    mov rdx, [handoff_entry32]
    call debug_hex_field
    lea rcx, [msg_handoff_flags]
    mov rdx, [handoff_flags]
    call debug_hex_field
    lea rcx, [msg_low_trampoline]
    mov edx, UEFI32_TRAMPOLINE_ADDR
    call debug_hex_field
    lea rcx, [msg_low_transition64]
    mov edx, UEFI64_TRANSITION_ADDR
    call debug_hex_field
    call debug_newline
    xor eax, eax
    ret

.fail:
    lea rcx, [msg_error_low_handoff_copy]
    mov rdx, EFI_ABORTED
    call debug_status_line
    mov rax, EFI_ABORTED
    ret

emit_kernel_handoff_attempt:
    lea rcx, [msg_step_kernel_handoff_attempt]
    call debug_write
    lea rcx, [msg_handoff_entry]
    mov rdx, [handoff_entry32]
    call debug_hex_field
    lea rcx, [msg_handoff_block]
    mov edx, UEFI32_HANDOFF_BLOCK_ADDR
    call debug_hex_field
    lea rcx, [msg_handoff_bootinfo]
    mov edx, BOOT_INFO_ADDR
    call debug_hex_field
    lea rcx, [msg_handoff_e820]
    mov edx, UEFI32_E820_MAP_ADDR
    call debug_hex_field
    lea rcx, [msg_handoff_trampoline]
    mov edx, UEFI32_TRAMPOLINE_ADDR
    call debug_hex_field
    lea rcx, [msg_low_transition64]
    mov edx, UEFI64_TRANSITION_ADDR
    call debug_hex_field
    lea rcx, [msg_handoff_flags]
    mov rdx, [handoff_flags]
    call debug_hex_field
    lea rcx, [msg_elf_segments]
    mov rdx, [handoff_loaded_segments]
    call debug_hex_field
    call debug_newline
    ret

; Copied to UEFI64_TRANSITION_ADDR before ExitBootServices. It runs from an
; identity-mapped low physical page, loads a low GDT, disables paging to leave
; long mode, and far-jumps into the 32-bit trampoline at UEFI32_TRAMPOLINE_ADDR.
align 16
uefi64_low_transition_start:
    cli
    lgdt [rel uefi64_low_gdt_descriptor]
    mov rax, cr0
    and eax, CR0_PG_CLEAR_MASK
    mov cr0, rax
    db 0xea
    dd UEFI32_TRAMPOLINE_ADDR
    dw UEFI32_CODE_SEG

align 8
uefi64_low_gdt_start:
uefi64_low_gdt_null:
    dq 0

uefi64_low_gdt_code32:
    dw 0xffff
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00

uefi64_low_gdt_data32:
    dw 0xffff
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00

uefi64_low_gdt_end:

uefi64_low_gdt_descriptor:
    dw uefi64_low_gdt_end - uefi64_low_gdt_start - 1
    dq UEFI64_TRANSITION_ADDR + (uefi64_low_gdt_start - uefi64_low_transition_start)
uefi64_low_transition_end:

bits 32
uefi32_low_trampoline_start:
    cli
    mov ecx, IA32_EFER_MSR
    rdmsr
    and eax, EFER_LME_CLEAR_MASK
    wrmsr
    mov eax, cr4
    and eax, CR4_PAE_CLEAR_MASK
    mov cr4, eax
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
msg_step_low_reserved db "VIBEUEFI step=low-memory-reserve status=success", 0
msg_step_elf_loaded db "VIBEUEFI step=elf32-load status=success", 0
msg_step_gop db "VIBEUEFI step=gop", 0
msg_step_memory_map db "VIBEUEFI step=memory-map", 0
msg_step_boot_info db "VIBEUEFI step=boot-info status=success", 0
msg_step_low_handoff_copy db "VIBEUEFI step=low-handoff-copy status=success", 0
msg_step_exit_boot_services db "VIBEUEFI step=exit-boot-services status=success", 10, 0
msg_step_handoff_plan db "VIBEUEFI step=handoff-plan status=ready", 0
msg_step_kernel_handoff_attempt db "VIBEUEFI step=kernel-handoff status=attempting proof=pending-kernel-entry-marker", 0
msg_kernel_bytes db " bytes=0x", 0
msg_kernel_entry db " entry32=0x", 0
msg_elf_segments db " segments=0x", 0
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
msg_bootinfo_flags db " flags=0x", 0
msg_bootinfo_e820 db " e820=0x", 0
msg_handoff_entry db " entry32=0x", 0
msg_handoff_stack db " stack32=0x", 0
msg_handoff_block db " handoff=0x", 0
msg_handoff_bootinfo db " bootinfo=0x", 0
msg_handoff_e820 db " e820=0x", 0
msg_handoff_trampoline db " tramp32=0x", 0
msg_handoff_gdt db " gdt=0x", 0
msg_handoff_code db " code=0x", 0
msg_handoff_data db " data=0x", 0
msg_handoff_flags db " flags=0x", 0
msg_low_bootinfo db " bootinfo=0x", 0
msg_low_trampoline db " tramp32=0x", 0
msg_low_transition64 db " transition64=0x", 0
msg_low_stack db " stack32=0x", 0
msg_error_loaded_image db "VIBEUEFI error=loaded-image status=0x", 0
msg_error_filesystem db "VIBEUEFI error=simple-filesystem status=0x", 0
msg_error_open_volume db "VIBEUEFI error=open-volume status=0x", 0
msg_error_open_kernel db "VIBEUEFI error=open-kernel status=0x", 0
msg_error_alloc_kernel db "VIBEUEFI error=allocate-kernel-buffer status=0x", 0
msg_error_read_kernel db "VIBEUEFI error=read-kernel status=0x", 0
msg_error_kernel_too_large db "VIBEUEFI error=kernel-too-large status=0x", 0
msg_error_bad_elf db "VIBEUEFI error=bad-elf32-kernel status=0x", 0
msg_error_low_reserve db "VIBEUEFI error=low-memory-reserve status=0x", 0
msg_error_elf_segments db "VIBEUEFI error=elf32-load status=0x", 0
msg_error_kernel_segment_reserve db "VIBEUEFI error=kernel-segment-reserve status=0x", 0
msg_error_boot_info db "VIBEUEFI error=boot-info status=0x", 0
msg_error_handoff_precondition db "VIBEUEFI error=handoff-precondition status=0x", 0
msg_error_low_handoff_copy db "VIBEUEFI error=low-handoff-copy status=0x", 0
msg_error_gop db "VIBEUEFI error=gop status=0x", 0
msg_error_memory_map db "VIBEUEFI error=memory-map status=0x", 0
msg_error_memory_map_shape db "VIBEUEFI error=memory-map-shape status=0x", 0
msg_error_exit_boot_services db "VIBEUEFI error=exit-boot-services status=0x", 0
msg_error_returning db "VIBEUEFI result=returning-to-firmware status=0x", 0
msg_newline db 10, 0
hex_digits db "0123456789ABCDEF"

align 8
image_handle dq 0
system_table dq 0
boot_services dq 0
alloc_target dq 0
loaded_image dq 0
simple_file_system dq 0
root_file dq 0
kernel_file dq 0
kernel_buffer dq 0
kernel_read_size dq 0
kernel_entry32 dq 0
kernel_loaded_segments dq 0
low_handoff_ready dq 0
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
e820_entry_count dq 0
kernel_entry_covered db 0

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
handoff_loaded_segments dq 0
handoff_transition64 dq 0
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
