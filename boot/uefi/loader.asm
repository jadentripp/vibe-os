bits 64
default rel

; x86_64 UEFI proof loader.
;
; This is intentionally a loader/proof rung, not a kernel entry path. It reads
; VIBEOS/KERNEL.ELF from the ESP, records GOP and memory-map facts, calls
; ExitBootServices, emits debugcon markers for cloud parsing, then exits QEMU
; through isa-debug-exit. The remaining blocker is the 64-bit UEFI to 32-bit
; protected-mode handoff expected by the current kernel.

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
    lea rcx, [msg_kernel_handoff_blocked]
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
msg_kernel_handoff_blocked db "VIBEUEFI step=kernel-handoff status=blocked reason=uefi64-to-elf32-protected-mode-transition-not-implemented", 10, 0
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
memory_map_buffer:
    times MEMORY_MAP_BUFFER_BYTES db 0
