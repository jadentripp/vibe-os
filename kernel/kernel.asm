bits 32
%ifdef ELF_KERNEL
KERNEL_BASE equ 0
section .text
global start
global libc_strlen
global libc_strcmp
global libc_abs
global libc_idivmod
global kprintf
global wad_parse_status
global wad_lump_count
global playpal_offset
global playpal_size
global colormap_offset
global colormap_size
extern c_runtime_self_test
extern c_runtime_report
%else
KERNEL_BASE equ 0x10000
org KERNEL_BASE
%endif

INPUT_MAX equ 96
VGA_BUFFER equ 0x000b8000
VGA_GRAPHICS_BUFFER equ 0x000a0000
VGA_COLS equ 80
VGA_ROWS equ 25
VGA_ATTR equ 0x0f
SMOKE_STATUS_ADDR equ 0x0009d000
SMOKE_STATUS_BYTES equ 1024
DOOM_SCREEN_WIDTH equ 320
DOOM_SCREEN_HEIGHT equ 200
DOOM_FRAME_BYTES equ DOOM_SCREEN_WIDTH * DOOM_SCREEN_HEIGHT
DOOM_PALETTE_BYTES equ 256 * 3
BOOT_INFO_ADDR equ 0x7000
CODE_SEG equ 0x08
DATA_SEG equ 0x10
USER_CODE_SEG equ 0x1b
USER_DATA_SEG equ 0x23
TSS_SEG equ 0x28
KERNEL_STACK_TOP equ 0x00070000
PIT_DIVISOR_100HZ equ 11932
PAGE_SIZE equ 0x1000
PAGING_DIR_ADDR equ 0x00090000
PAGING_TABLES_ADDR equ 0x00091000
PAGING_TABLE_COUNT equ 8
PAGING_TOTAL_PAGES equ PAGING_TABLE_COUNT * 1024
PAGING_MAPPED_BYTES equ PAGING_TABLE_COUNT * 0x00400000
PMM_FRAME_MAP_ADDR equ 0x00099000
PMM_MANAGED_START equ 0x00100000
PMM_MANAGED_END equ 0x02000000
PMM_MANAGED_PAGES equ (PMM_MANAGED_END - PMM_MANAGED_START) / PAGE_SIZE
VMM_TEST_VADDR equ 0x00f00000
VMM_TEST_MAGIC equ 0x564d4d21
HEAP_START equ 0x00100000
HEAP_SIZE equ 0x00800000
HEAP_MIN_EXT_KB equ 8192
HEAP_ALIGN equ 16
HEAP_HEADER_SIZE equ 16
HEAP_MIN_SPLIT_SIZE equ HEAP_HEADER_SIZE + HEAP_ALIGN
HEAP_PROBE_SIZE equ 0x00400000
HEAP_PROBE_LAST_DWORD equ HEAP_PROBE_SIZE - 4
HEAP_PROBE_MAGIC equ 0x464c4154
HEAP_BLOCK_MAGIC_FREE equ 0x46524545
HEAP_BLOCK_MAGIC_USED equ 0x55534544
SECTOR_BUFFER_ADDR equ 0x0009b000
WAD_LOAD_ADDR equ 0x00900000
WAD_MAX_BYTES equ 0x00500000
DOOM_ELF_LOAD_ADDR equ 0x01000000
DOOM_ELF_LIMIT equ 0x02000000
DOOM_ELF_MAX_BYTES equ DOOM_ELF_LIMIT - DOOM_ELF_LOAD_ADDR
DOOM_USER_BASE equ DOOM_ELF_LOAD_ADDR
DOOM_USER_HEAP_START equ 0x01900000
DOOM_USER_HEAP_END equ 0x01f00000
DOOM_USER_END equ DOOM_ELF_LIMIT
C_RUNTIME_MAGIC equ 0xC0DEF00D
ELF_MAGIC equ 0x464c457f
ELFCLASS32 equ 1
ELFDATA2LSB equ 1
ET_EXEC equ 2
EM_386 equ 3
PT_LOAD equ 1
USER_ELF_LOAD_ADDR equ 0x00e40000
USER_ELF_MAX_BYTES equ 0x00020000
USER_CODE_ADDR equ 0x00e80000
USER_STACK_BOTTOM equ 0x00e81000
USER_STACK_TOP equ 0x00e82000
USER_HEAP_START equ USER_STACK_TOP
USER_HEAP_END equ 0x00f00000
USER_PROBE_EXPECTED_FLAGS equ 0x0000003f
USER_PROBE_MAGIC equ 0x13579BDF
USER_FAULT_ADDR equ 0x00010000
USER_FD_WAD equ 3
SYS_USER_PROBE equ 1
SYS_EXIT equ 2
SYS_EXPECT_FAULT equ 3
SYS_WRITE equ 4
SYS_SBRK equ 5
SYS_OPEN equ 6
SYS_READ equ 7
SYS_LSEEK equ 8
SYS_TIME equ 9
SYS_PRESENT equ 10
VGA_DAC_WRITE_INDEX equ 0x03c8
VGA_DAC_DATA equ 0x03c9
ATA_DATA equ 0x01f0
ATA_SECTOR_COUNT equ 0x01f2
ATA_LBA_LOW equ 0x01f3
ATA_LBA_MID equ 0x01f4
ATA_LBA_HIGH equ 0x01f5
ATA_DRIVE_HEAD equ 0x01f6
ATA_COMMAND_STATUS equ 0x01f7
ATA_CMD_READ_SECTORS equ 0x20

SC_LSHIFT equ 0x2a
SC_RSHIFT equ 0x36

start:
    cli
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, KERNEL_STACK_TOP

    cld
    call gdt_init
    call fpu_init
    call idt_init
    lidt [idt_descriptor]
    call pic_remap_and_mask
    call pit_init_100hz
    call paging_init
    call pmm_init
    call pmm_self_test
    call vmm_self_test
    call heap_init
    call heap_self_test
    call fpu_self_test
    call libc_self_test
    call storage_init
    call c_runtime_self_test
    cmp eax, C_RUNTIME_MAGIC
    je .c_runtime_ok
    mov byte [c_runtime_status], 2
    jmp .c_runtime_done

.c_runtime_ok:
    mov byte [c_runtime_status], 1

.c_runtime_done:
    call user_probe_run

user_probe_finished:
    call clear_screen
    mov esi, banner
    call print_string
    call draw_doom_status
    call draw_heap_status
    call draw_timer_status
    call write_smoke_status
    call pic_unmask_timer
    sti

main_loop:
    mov esi, prompt
    call print_string
    call read_line
    call handle_command
    jmp main_loop

handle_command:
    mov esi, input_buffer
    call skip_spaces
    mov [command_start], esi

    cmp byte [esi], 0
    je .done

    mov edi, cmd_help
    call match_exact
    cmp al, 1
    je .help

    mov esi, [command_start]
    mov edi, cmd_about
    call match_exact
    cmp al, 1
    je .about

    mov esi, [command_start]
    mov edi, cmd_clear
    call match_exact
    cmp al, 1
    je .clear

    mov esi, [command_start]
    mov edi, cmd_mem
    call match_exact
    cmp al, 1
    je .mem

    mov esi, [command_start]
    mov edi, cmd_mode
    call match_exact
    cmp al, 1
    je .mode

    mov esi, [command_start]
    mov edi, cmd_ticks
    call match_exact
    cmp al, 1
    je .ticks

    mov esi, [command_start]
    mov edi, cmd_heap
    call match_exact
    cmp al, 1
    je .heap

    mov esi, [command_start]
    mov edi, cmd_paging
    call match_exact
    cmp al, 1
    je .paging

    mov esi, [command_start]
    mov edi, cmd_libc
    call match_exact
    cmp al, 1
    je .libc

    mov esi, [command_start]
    mov edi, cmd_c
    call match_exact
    cmp al, 1
    je .cprobe

    mov esi, [command_start]
    mov edi, cmd_user
    call match_exact
    cmp al, 1
    je .user

    mov esi, [command_start]
    mov edi, cmd_wad
    call match_exact
    cmp al, 1
    je .wad

    mov esi, [command_start]
    mov edi, cmd_reboot
    call match_exact
    cmp al, 1
    je .reboot

    mov esi, [command_start]
    mov edi, cmd_halt
    call match_exact
    cmp al, 1
    je .halt

    mov esi, [command_start]
    mov edi, cmd_echo
    call starts_with_word
    cmp al, 1
    je .echo

    mov esi, unknown_message
    call print_string
    mov esi, [command_start]
    call print_string
    call newline
    ret

.help:
    mov esi, help_text
    call print_string
    ret

.about:
    mov esi, about_text
    call print_string
    ret

.clear:
    call clear_screen
    ret

.mem:
    mov esi, conventional_prefix
    call print_string
    movzx eax, word [BOOT_INFO_ADDR]
    call print_dec
    mov esi, kb_suffix
    call print_string
    mov esi, extended_prefix
    call print_string
    movzx eax, word [BOOT_INFO_ADDR + 4]
    call print_dec
    mov esi, kb_suffix
    call print_string
    ret

.mode:
    mov esi, mode_text
    call print_string
    ret

.ticks:
    mov esi, ticks_prefix
    call print_string
    mov eax, [timer_ticks]
    call print_dec
    mov esi, ticks_suffix
    call print_string
    ret

.heap:
    mov esi, heap_start_prefix
    call print_string
    mov eax, [heap_start]
    call print_hex32
    call newline

    mov esi, heap_free_head_prefix
    call print_string
    mov eax, [heap_free_head]
    call print_hex32
    call newline

    mov esi, heap_free_prefix
    call print_string
    call heap_free_bytes
    call print_hex32
    call newline

    mov esi, heap_alloc_prefix
    call print_string
    mov eax, [heap_alloc_count]
    call print_dec
    call newline

    mov esi, heap_test_prefix
    call print_string
    cmp byte [heap_test_status], 1
    je .heap_ok
    mov esi, fail_text
    call print_string
    ret

.heap_ok:
    mov esi, ok_text
    call print_string
    ret

.paging:
    mov esi, paging_state_prefix
    call print_string
    cmp byte [paging_status], 1
    je .paging_on
    mov esi, off_text
    call print_string
    jmp .paging_dir

.paging_on:
    mov esi, on_text
    call print_string

.paging_dir:
    mov esi, paging_dir_prefix
    call print_string
    mov eax, PAGING_DIR_ADDR
    call print_hex32
    call newline

    mov esi, paging_mapped_prefix
    call print_string
    mov eax, PAGING_MAPPED_BYTES / 0x00100000
    call print_dec
    mov esi, mib_suffix
    call print_string

    mov esi, pmm_total_prefix
    call print_string
    mov eax, [pmm_total_pages]
    call print_dec
    mov esi, pages_suffix
    call print_string

    mov esi, pmm_free_prefix
    call print_string
    mov eax, [pmm_free_pages]
    call print_dec
    mov esi, pages_suffix
    call print_string

    mov esi, pmm_used_prefix
    call print_string
    mov eax, [pmm_used_pages]
    call print_dec
    mov esi, pages_suffix
    call print_string

    mov esi, pmm_test_prefix
    call print_string
    cmp byte [pmm_test_status], 1
    je .pmm_ok
    mov esi, fail_text
    call print_string
    jmp .vmm_report

.pmm_ok:
    mov esi, ok_text
    call print_string

.vmm_report:
    mov esi, vmm_test_prefix
    call print_string
    cmp byte [vmm_test_status], 1
    je .vmm_ok
    mov esi, fail_text
    call print_string
    ret

.vmm_ok:
    mov esi, ok_text
    call print_string
    ret

.libc:
    cmp byte [libc_test_status], 1
    je .libc_ok
    push dword fail_text_plain
    push dword libc_status_fmt
    call kprintf
    add esp, 8
    ret

.libc_ok:
    push dword ok_text_plain
    push dword libc_status_fmt
    call kprintf
    add esp, 8

    push dword ok_text_plain
    push dword fpu_status_fmt
    call kprintf
    add esp, 8

    push dword libc_test_source
    call libc_strlen
    add esp, 4
    push eax
    push dword libc_strlen_fmt
    call kprintf
    add esp, 8

    push dword [libc_last_remainder]
    push dword [libc_last_quotient]
    push dword libc_math_fmt
    call kprintf
    add esp, 12
    ret

.cprobe:
    call c_runtime_report
    ret

.user:
    mov esi, user_elf_prefix
    call print_string
    cmp byte [user_elf_status], 1
    jne .user_elf_fail
    cmp byte [user_elf_parse_status], 1
    jne .user_elf_fail
    mov esi, ok_text
    call print_string
    jmp .user_entry

.user_elf_fail:
    mov esi, fail_text
    call print_string

.user_entry:
    mov esi, user_entry_prefix
    call print_string
    mov eax, [user_entry_addr]
    call print_hex32
    call newline
    mov esi, user_flags_prefix
    call print_string
    mov eax, [user_probe_flags_seen]
    call print_hex32
    call newline
    mov esi, user_wad_magic_prefix
    call print_string
    mov eax, [user_wad_magic_seen]
    call print_hex32
    call newline

    mov esi, user_status_prefix
    call print_string
    cmp byte [user_probe_status], 3
    je .user_ok
    mov esi, fail_text
    call print_string
    jmp .user_details

.user_ok:
    mov esi, ok_text
    call print_string

.user_details:
    mov esi, user_magic_prefix
    call print_string
    mov eax, [user_probe_magic_seen]
    call print_hex32
    call newline
    mov esi, user_cs_prefix
    call print_string
    movzx eax, word [user_probe_cs]
    call print_hex32
    mov esi, user_ss_prefix
    call print_string
    movzx eax, word [user_probe_ss]
    call print_hex32
    call newline
    mov esi, user_fault_prefix
    call print_string
    cmp byte [user_fault_status], 1
    je .user_fault_ok
    mov esi, fail_text
    call print_string
    ret

.user_fault_ok:
    mov esi, ok_text_plain
    call print_string
    mov esi, user_fault_addr_prefix
    call print_string
    mov eax, [user_fault_addr]
    call print_hex32
    call newline
    ret

.wad:
    mov esi, ata_status_prefix
    call print_string
    cmp byte [ata_status], 1
    je .ata_ok
    mov esi, fail_text
    call print_string
    jmp .wad_fat

.ata_ok:
    mov esi, ok_text
    call print_string

.wad_fat:
    mov esi, fat_status_prefix
    call print_string
    cmp byte [fat_status], 1
    je .fat_ok
    mov esi, fail_text
    call print_string
    jmp .wad_file

.fat_ok:
    mov esi, ok_text
    call print_string

.wad_file:
    mov esi, wad_status_prefix
    call print_string
    cmp byte [wad_status], 1
    je .wad_ok
    mov esi, fail_text
    call print_string
    ret

.wad_ok:
    mov esi, ok_text
    call print_string

    mov esi, wad_parse_prefix
    call print_string
    cmp byte [wad_parse_status], 1
    je .wad_parse_ok
    mov esi, fail_text
    call print_string
    ret

.wad_parse_ok:
    mov esi, ok_text
    call print_string

    mov esi, wad_size_prefix
    call print_string
    mov eax, [wad_size]
    call print_dec
    mov esi, bytes_suffix
    call print_string

    mov esi, wad_lump_count_prefix
    call print_string
    mov eax, [wad_lump_count]
    call print_dec
    call newline

    mov esi, wad_dir_prefix
    call print_string
    mov eax, [wad_directory_offset]
    call print_hex32
    call newline

    mov esi, playpal_prefix
    call print_string
    mov eax, [playpal_offset]
    call print_hex32
    mov esi, lump_size_mid
    call print_string
    mov eax, [playpal_size]
    call print_dec
    call newline

    mov esi, colormap_prefix
    call print_string
    mov eax, [colormap_offset]
    call print_hex32
    mov esi, lump_size_mid
    call print_string
    mov eax, [colormap_size]
    call print_dec
    call newline

    mov esi, wad_cluster_prefix
    call print_string
    movzx eax, word [wad_first_cluster]
    call print_dec
    call newline

    mov esi, doom_elf_prefix
    call print_string
    cmp byte [doom_elf_status], 1
    je .doom_elf_ok
    mov esi, fail_text
    call print_string
    jmp .wad_load_address

.doom_elf_ok:
    mov esi, ok_text
    call print_string

    mov esi, doom_elf_size_prefix
    call print_string
    mov eax, [doom_elf_size]
    call print_dec
    mov esi, bytes_suffix
    call print_string

    mov esi, doom_elf_cluster_prefix
    call print_string
    movzx eax, word [doom_elf_first_cluster]
    call print_dec
    call newline

    mov esi, doom_elf_load_prefix
    call print_string
    cmp byte [doom_elf_load_status], 1
    je .doom_elf_load_ok
    mov esi, fail_text
    call print_string
    jmp .wad_load_address

.doom_elf_load_ok:
    mov esi, ok_text
    call print_string

    mov esi, doom_elf_parse_prefix
    call print_string
    cmp byte [doom_elf_parse_status], 1
    je .doom_elf_parse_ok
    mov esi, fail_text
    call print_string
    jmp .wad_load_address

.doom_elf_parse_ok:
    mov esi, ok_text
    call print_string

    mov esi, doom_elf_entry_prefix
    call print_string
    mov eax, [doom_entry_addr]
    call print_hex32
    call newline

    mov esi, doom_elf_mem_prefix
    call print_string
    mov eax, [doom_segment_memsz]
    call print_dec
    mov esi, bytes_suffix
    call print_string

    mov esi, doom_elf_end_prefix
    call print_string
    mov eax, [doom_segment_end]
    call print_hex32
    call newline

    mov esi, doom_user_window_prefix
    call print_string
    cmp byte [doom_user_window_status], 1
    je .doom_user_window_ok
    mov esi, fail_text
    call print_string
    jmp .wad_load_address

.doom_user_window_ok:
    mov esi, ok_text
    call print_string

.wad_load_address:
    mov esi, wad_load_prefix
    call print_string
    mov eax, WAD_LOAD_ADDR
    call print_hex32
    call newline
    ret

.reboot:
    mov esi, reboot_message
    call print_string
    call keyboard_controller_reboot
    ret

.halt:
    mov esi, halt_message
    call print_string

.halt_loop:
    cli
    hlt
    jmp .halt_loop

.echo:
    mov esi, ebx
    call print_string
    call newline

.done:
    ret

read_line:
    push eax
    push ecx
    push edi

    mov edi, input_buffer
    mov ecx, INPUT_MAX - 1

.key_loop:
    call read_key
    cmp al, 13
    je .enter
    cmp al, 8
    je .backspace
    cmp al, 0
    je .key_loop
    cmp ecx, 0
    je .key_loop

    stosb
    dec ecx
    call put_char
    jmp .key_loop

.backspace:
    cmp edi, input_buffer
    je .key_loop
    dec edi
    inc ecx
    mov byte [edi], 0
    mov al, 8
    call put_char
    mov al, ' '
    call put_char
    mov al, 8
    call put_char
    jmp .key_loop

.enter:
    mov byte [edi], 0
    call newline
    pop edi
    pop ecx
    pop eax
    ret

read_key:
    push ebx

.next_scancode:
    call wait_scancode
    cmp al, 0xe0
    je .next_scancode

    mov bl, al
    test bl, 0x80
    jnz .release

    cmp bl, SC_LSHIFT
    je .shift_down
    cmp bl, SC_RSHIFT
    je .shift_down

    movzx ebx, bl
    cmp byte [shift_down], 0
    jne .shifted
    mov al, [keymap_normal + ebx]
    pop ebx
    ret

.shifted:
    mov al, [keymap_shift + ebx]
    pop ebx
    ret

.shift_down:
    mov byte [shift_down], 1
    jmp .next_scancode

.release:
    and bl, 0x7f
    cmp bl, SC_LSHIFT
    je .shift_up
    cmp bl, SC_RSHIFT
    je .shift_up
    jmp .next_scancode

.shift_up:
    mov byte [shift_down], 0
    jmp .next_scancode

wait_scancode:
    in al, 0x64
    test al, 0x01
    jz wait_scancode
    in al, 0x60
    ret

keyboard_controller_reboot:
    in al, 0x64
    test al, 0x02
    jnz keyboard_controller_reboot
    mov al, 0xfe
    out 0x64, al

.wait:
    cli
    hlt
    jmp .wait

skip_spaces:
    cmp byte [esi], ' '
    jne .done
    inc esi
    jmp skip_spaces

.done:
    ret

match_exact:
    push ebx

.loop:
    mov al, [edi]
    cmp al, 0
    je .check_tail
    mov bl, [esi]
    cmp bl, al
    jne .no
    inc esi
    inc edi
    jmp .loop

.check_tail:
    mov bl, [esi]
    cmp bl, 0
    je .yes
    cmp bl, ' '
    jne .no
    inc esi
    jmp .check_tail

.yes:
    mov al, 1
    pop ebx
    ret

.no:
    xor al, al
    pop ebx
    ret

starts_with_word:
    push edx

.loop:
    mov al, [edi]
    cmp al, 0
    je .word_end
    cmp [esi], al
    jne .no
    inc esi
    inc edi
    jmp .loop

.word_end:
    mov dl, [esi]
    cmp dl, 0
    je .yes
    cmp dl, ' '
    jne .no

.skip_argument_spaces:
    cmp byte [esi], ' '
    jne .yes
    inc esi
    jmp .skip_argument_spaces

.yes:
    mov ebx, esi
    mov al, 1
    pop edx
    ret

.no:
    xor al, al
    pop edx
    ret

clear_screen:
    push eax
    push ecx
    push edi

    mov edi, VGA_BUFFER
    mov ax, (VGA_ATTR << 8) | ' '
    mov ecx, VGA_COLS * VGA_ROWS

.clear_next:
    mov [edi], ax
    add edi, 2
    loop .clear_next

    mov dword [cursor_row], 0
    mov dword [cursor_col], 0
    call update_cursor

    pop edi
    pop ecx
    pop eax
    ret

newline:
    call vga_newline
    ret

print_string:
    push eax

.next:
    lodsb
    test al, al
    jz .done
    call put_char
    jmp .next

.done:
    pop eax
    ret

put_char:
    cmp al, 13
    je .done
    cmp al, 10
    je .newline
    cmp al, 8
    je .backspace

    call vga_put_visible
    ret

.newline:
    call vga_newline
    ret

.backspace:
    call vga_backspace

.done:
    ret

vga_put_visible:
    push eax
    push ebx
    push edi

    mov ebx, [cursor_row]
    imul ebx, VGA_COLS
    add ebx, [cursor_col]
    shl ebx, 1
    mov edi, VGA_BUFFER
    add edi, ebx
    mov ah, VGA_ATTR
    mov [edi], ax

    inc dword [cursor_col]
    cmp dword [cursor_col], VGA_COLS
    jb .update
    call vga_newline
    jmp .done

.update:
    call update_cursor

.done:
    pop edi
    pop ebx
    pop eax
    ret

vga_newline:
    push eax
    mov dword [cursor_col], 0
    inc dword [cursor_row]
    cmp dword [cursor_row], VGA_ROWS
    jb .update
    call vga_scroll
    mov dword [cursor_row], VGA_ROWS - 1

.update:
    call update_cursor
    pop eax
    ret

vga_backspace:
    push eax
    push ebx
    push edi

    cmp dword [cursor_col], 0
    jne .move_left
    cmp dword [cursor_row], 0
    je .done
    dec dword [cursor_row]
    mov dword [cursor_col], VGA_COLS

.move_left:
    dec dword [cursor_col]
    mov ebx, [cursor_row]
    imul ebx, VGA_COLS
    add ebx, [cursor_col]
    shl ebx, 1
    mov edi, VGA_BUFFER
    add edi, ebx
    mov ax, (VGA_ATTR << 8) | ' '
    mov [edi], ax
    call update_cursor

.done:
    pop edi
    pop ebx
    pop eax
    ret

vga_scroll:
    push eax
    push ecx
    push esi
    push edi

    mov esi, VGA_BUFFER + (VGA_COLS * 2)
    mov edi, VGA_BUFFER
    mov ecx, (VGA_ROWS - 1) * VGA_COLS

.copy_next:
    mov ax, [esi]
    mov [edi], ax
    add esi, 2
    add edi, 2
    loop .copy_next

    mov edi, VGA_BUFFER + ((VGA_ROWS - 1) * VGA_COLS * 2)
    mov ax, (VGA_ATTR << 8) | ' '
    mov ecx, VGA_COLS

.clear_last_row:
    mov [edi], ax
    add edi, 2
    loop .clear_last_row

    pop edi
    pop esi
    pop ecx
    pop eax
    ret

update_cursor:
    ret

pic_remap_and_mask:
    mov al, 0x11
    out 0x20, al
    call io_wait
    out 0xa0, al
    call io_wait
    mov al, 0x20
    out 0x21, al
    call io_wait
    mov al, 0x28
    out 0xa1, al
    call io_wait
    mov al, 0x04
    out 0x21, al
    call io_wait
    mov al, 0x02
    out 0xa1, al
    call io_wait
    mov al, 0x01
    out 0x21, al
    call io_wait
    out 0xa1, al
    call io_wait
    mov al, 0xff
    out 0x21, al
    call io_wait
    out 0xa1, al
    call io_wait
    ret

pic_unmask_timer:
    mov al, 0xfe
    out 0x21, al
    call io_wait
    mov al, 0xff
    out 0xa1, al
    call io_wait
    ret

io_wait:
    push eax
    xor al, al
    out 0x80, al
    pop eax
    ret

pit_init_100hz:
    mov al, 0x36
    out 0x43, al
    mov ax, PIT_DIVISOR_100HZ
    out 0x40, al
    mov al, ah
    out 0x40, al
    ret

gdt_init:
    mov dword [tss_esp0], KERNEL_STACK_TOP
    mov word [tss_ss0], DATA_SEG

    mov eax, tss_start
    mov word [kernel_gdt_tss + 2], ax
    shr eax, 16
    mov byte [kernel_gdt_tss + 4], al
    mov byte [kernel_gdt_tss + 7], ah

    lgdt [kernel_gdt_descriptor]
    jmp CODE_SEG:.reload_cs

.reload_cs:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ax, TSS_SEG
    ltr ax
    ret

paging_init:
    pushad

    mov edi, PAGING_DIR_ADDR
    xor eax, eax
    mov ecx, 1024
    rep stosd

    mov edi, PAGING_TABLES_ADDR
    xor eax, eax
    mov ecx, PAGING_TOTAL_PAGES

.pte_next:
    mov ebx, eax
    shl ebx, 12
    or ebx, 0x003
    mov [edi], ebx
    add edi, 4
    inc eax
    loop .pte_next

    mov edi, PAGING_DIR_ADDR
    mov eax, PAGING_TABLES_ADDR | 0x003
    mov ecx, PAGING_TABLE_COUNT

.pde_next:
    mov [edi], eax
    add eax, PAGE_SIZE
    add edi, 4
    loop .pde_next

    mov eax, USER_CODE_ADDR

.user_page_next:
    cmp eax, USER_HEAP_END
    jae .user_pages_done
    call vmm_mark_user_identity_page
    add eax, PAGE_SIZE
    jmp .user_page_next

.user_pages_done:
    mov eax, DOOM_USER_BASE

.doom_page_next:
    cmp eax, DOOM_USER_END
    jae .doom_pages_done
    call vmm_mark_user_identity_page
    add eax, PAGE_SIZE
    jmp .doom_page_next

.doom_pages_done:

    mov eax, PAGING_DIR_ADDR
    mov cr3, eax
    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax
    jmp short .flush

.flush:
    mov byte [paging_status], 1
    popad
    ret

vmm_mark_user_identity_page:
    push eax
    push ebx
    push edx
    push edi

    mov ebx, eax
    shr ebx, 22
    mov edi, PAGING_DIR_ADDR
    lea edi, [edi + ebx * 4]
    mov edx, [edi]
    or edx, 0x007
    mov [edi], edx
    and edx, 0xfffff000

    shr eax, 12
    and eax, 0x3ff
    lea edi, [edx + eax * 4]
    mov ebx, [edi]
    or ebx, 0x007
    mov [edi], ebx

    pop edi
    pop edx
    pop ebx
    pop eax
    ret

pmm_init:
    push eax
    push ecx
    push edi

    mov dword [pmm_total_pages], 0
    mov dword [pmm_free_pages], 0
    mov dword [pmm_used_pages], 0
    mov byte [pmm_test_status], 0

    mov edi, PMM_FRAME_MAP_ADDR
    xor eax, eax
    mov ecx, PMM_MANAGED_PAGES
    rep stosb

    movzx eax, word [BOOT_INFO_ADDR + 4]
    shr eax, 2
    cmp eax, PMM_MANAGED_PAGES
    jbe .page_count_ok
    mov eax, PMM_MANAGED_PAGES

.page_count_ok:
    mov [pmm_total_pages], eax
    mov [pmm_free_pages], eax
    mov edi, PMM_FRAME_MAP_ADDR
    mov ecx, eax
    mov al, 1
    rep stosb

    mov eax, HEAP_START
    mov ecx, HEAP_SIZE / PAGE_SIZE
    call pmm_reserve_pages

    mov eax, USER_CODE_ADDR
    mov ecx, (USER_HEAP_END - USER_CODE_ADDR) / PAGE_SIZE
    call pmm_reserve_pages

    pop edi
    pop ecx
    pop eax
    ret

pmm_reserve_pages:
    push eax
    push ebx
    push ecx
    push edi

    sub eax, PMM_MANAGED_START
    shr eax, 12
    mov ebx, eax

.reserve_next:
    cmp ecx, 0
    je .done
    cmp ebx, [pmm_total_pages]
    jae .done
    mov edi, PMM_FRAME_MAP_ADDR
    add edi, ebx
    cmp byte [edi], 1
    jne .advance
    mov byte [edi], 0
    dec dword [pmm_free_pages]
    inc dword [pmm_used_pages]

.advance:
    inc ebx
    dec ecx
    jmp .reserve_next

.done:
    pop edi
    pop ecx
    pop ebx
    pop eax
    ret

pmm_alloc_page:
    push ebx
    push ecx
    push edi

    xor ebx, ebx
    mov ecx, [pmm_total_pages]
    mov edi, PMM_FRAME_MAP_ADDR

.scan_next:
    cmp ecx, 0
    je .fail
    cmp byte [edi], 1
    je .found
    inc edi
    inc ebx
    dec ecx
    jmp .scan_next

.found:
    mov byte [edi], 0
    dec dword [pmm_free_pages]
    inc dword [pmm_used_pages]
    mov eax, ebx
    shl eax, 12
    add eax, PMM_MANAGED_START
    pop edi
    pop ecx
    pop ebx
    ret

.fail:
    xor eax, eax
    pop edi
    pop ecx
    pop ebx
    ret

pmm_free_page:
    push ebx
    push edi

    cmp eax, PMM_MANAGED_START
    jb .done
    cmp eax, PMM_MANAGED_END
    jae .done
    sub eax, PMM_MANAGED_START
    shr eax, 12
    mov ebx, eax
    cmp ebx, [pmm_total_pages]
    jae .done
    mov edi, PMM_FRAME_MAP_ADDR
    add edi, ebx
    cmp byte [edi], 0
    jne .done
    mov byte [edi], 1
    inc dword [pmm_free_pages]
    dec dword [pmm_used_pages]

.done:
    pop edi
    pop ebx
    ret

pmm_self_test:
    call pmm_alloc_page
    test eax, eax
    jz .fail
    mov ebx, eax
    mov dword [ebx], 0x50414745
    cmp dword [ebx], 0x50414745
    jne .fail
    mov eax, ebx
    call pmm_free_page
    mov byte [pmm_test_status], 1
    ret

.fail:
    mov byte [pmm_test_status], 2
    ret

vmm_map_page:
    push eax
    push ebx
    push ecx
    push edx
    push edi

    and eax, 0xfffff000
    and ebx, 0xfffff000
    or ebx, ecx
    or ebx, 0x001
    mov edx, eax
    shr edx, 12
    cmp edx, PAGING_TOTAL_PAGES
    jae .fail
    mov edi, PAGING_TABLES_ADDR
    shl edx, 2
    add edi, edx
    mov [edi], ebx
    invlpg [eax]
    mov byte [vmm_status], 1
    clc
    jmp .done

.fail:
    stc

.done:
    pop edi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

vmm_identity_page:
    push ebx
    push ecx

    mov ebx, eax
    mov ecx, 0x003
    call vmm_map_page

    pop ecx
    pop ebx
    ret

vmm_self_test:
    call pmm_alloc_page
    test eax, eax
    jz .fail
    mov ebx, eax

    mov eax, VMM_TEST_VADDR
    mov ecx, 0x003
    call vmm_map_page
    jc .free_fail

    mov dword [VMM_TEST_VADDR], VMM_TEST_MAGIC
    cmp dword [ebx], VMM_TEST_MAGIC
    jne .restore_fail

    mov eax, VMM_TEST_VADDR
    call vmm_identity_page
    mov eax, ebx
    call pmm_free_page
    mov byte [vmm_test_status], 1
    ret

.restore_fail:
    mov eax, VMM_TEST_VADDR
    call vmm_identity_page

.free_fail:
    mov eax, ebx
    call pmm_free_page

.fail:
    mov byte [vmm_test_status], 2
    ret

heap_init:
    mov dword [heap_start], 0
    mov dword [heap_free_head], 0
    mov dword [heap_end], 0
    mov dword [heap_alloc_count], 0
    mov dword [heap_alloc_bytes], 0
    mov dword [heap_last_ptr], 0
    mov byte [heap_test_status], 0

    movzx eax, word [BOOT_INFO_ADDR + 4]
    cmp eax, HEAP_MIN_EXT_KB
    jb .done

    mov dword [heap_start], HEAP_START
    mov dword [heap_end], HEAP_START + HEAP_SIZE
    mov dword [heap_free_head], HEAP_START
    mov dword [HEAP_START], HEAP_SIZE
    mov dword [HEAP_START + 4], 0
    mov dword [HEAP_START + 8], HEAP_BLOCK_MAGIC_FREE
    mov dword [HEAP_START + 12], 0

.done:
    ret

kalloc:
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov ebx, eax
    add ebx, HEAP_ALIGN - 1
    and ebx, 0xfffffff0
    cmp ebx, 0
    je .fail

    mov edx, ebx
    add edx, HEAP_HEADER_SIZE

    xor esi, esi
    mov edi, [heap_free_head]

.find_block:
    cmp edi, 0
    je .fail
    mov ecx, [edi]
    cmp ecx, edx
    jae .use_block
    mov esi, edi
    mov edi, [edi + 4]
    jmp .find_block

.use_block:
    mov eax, ecx
    sub eax, edx
    cmp eax, HEAP_MIN_SPLIT_SIZE
    jb .take_whole

    mov ecx, edi
    add ecx, edx
    mov [ecx], eax
    mov eax, [edi + 4]
    mov [ecx + 4], eax
    mov dword [ecx + 8], HEAP_BLOCK_MAGIC_FREE
    mov dword [ecx + 12], 0
    test esi, esi
    jz .split_head
    mov [esi + 4], ecx
    jmp .mark_used

.split_head:
    mov [heap_free_head], ecx
    jmp .mark_used

.take_whole:
    mov edx, [edi]
    mov ecx, [edi + 4]
    test esi, esi
    jz .take_head
    mov [esi + 4], ecx
    jmp .mark_used

.take_head:
    mov [heap_free_head], ecx

.mark_used:
    mov [edi], edx
    mov dword [edi + 4], 0
    mov dword [edi + 8], HEAP_BLOCK_MAGIC_USED
    mov [edi + 12], ebx
    inc dword [heap_alloc_count]
    add [heap_alloc_bytes], ebx
    lea eax, [edi + HEAP_HEADER_SIZE]
    mov [heap_last_ptr], eax
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

.fail:
    xor eax, eax
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

kfree:
    push ebx
    push ecx
    push edx
    push esi
    push edi

    test eax, eax
    jz .done
    mov edi, eax
    sub edi, HEAP_HEADER_SIZE
    cmp dword [edi + 8], HEAP_BLOCK_MAGIC_USED
    jne .done

    mov ebx, [edi + 12]
    sub [heap_alloc_bytes], ebx
    cmp dword [heap_alloc_count], 0
    je .mark_free
    dec dword [heap_alloc_count]

.mark_free:
    mov dword [edi + 8], HEAP_BLOCK_MAGIC_FREE
    mov dword [edi + 12], 0

    xor esi, esi
    mov edx, [heap_free_head]

.find_slot:
    test edx, edx
    jz .insert
    cmp edx, edi
    ja .insert
    mov esi, edx
    mov edx, [edx + 4]
    jmp .find_slot

.insert:
    mov [edi + 4], edx
    test esi, esi
    jz .insert_head
    mov [esi + 4], edi
    jmp .coalesce_next

.insert_head:
    mov [heap_free_head], edi

.coalesce_next:
    mov edx, [edi + 4]
    test edx, edx
    jz .coalesce_prev
    mov ecx, edi
    add ecx, [edi]
    cmp ecx, edx
    jne .coalesce_prev
    mov eax, [edx]
    add [edi], eax
    mov eax, [edx + 4]
    mov [edi + 4], eax

.coalesce_prev:
    test esi, esi
    jz .done
    mov ecx, esi
    add ecx, [esi]
    cmp ecx, edi
    jne .done
    mov eax, [edi]
    add [esi], eax
    mov eax, [edi + 4]
    mov [esi + 4], eax

.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

heap_free_bytes:
    push ebx

    xor eax, eax
    mov ebx, [heap_free_head]

.sum_next:
    test ebx, ebx
    jz .done
    add eax, [ebx]
    mov ebx, [ebx + 4]
    jmp .sum_next

.done:
    pop ebx
    ret

heap_self_test:
    mov eax, 64
    call kalloc
    test eax, eax
    jz .fail
    mov dword [eax], 0x41555241
    cmp dword [eax], 0x41555241
    jne .fail

    mov eax, 256
    call kalloc
    test eax, eax
    jz .fail
    mov dword [eax + 252], 0x48454150
    cmp dword [eax + 252], 0x48454150
    jne .fail

    mov eax, HEAP_PROBE_SIZE
    call kalloc
    test eax, eax
    jz .fail
    mov ebx, eax
    mov dword [eax + HEAP_PROBE_LAST_DWORD], HEAP_PROBE_MAGIC
    cmp dword [eax + HEAP_PROBE_LAST_DWORD], HEAP_PROBE_MAGIC
    jne .fail
    mov eax, ebx
    call kfree

    mov eax, 128
    call kalloc
    test eax, eax
    jz .fail
    mov ebx, eax
    call kfree

    mov eax, 128
    call kalloc
    cmp eax, ebx
    jne .fail
    call kfree

    mov byte [heap_test_status], 1
    ret

.fail:
    mov byte [heap_test_status], 2
    ret

fpu_init:
    push eax

    mov eax, cr0
    and eax, 0xfffffff3
    or eax, 0x00000002
    mov cr0, eax
    fninit
    mov byte [fpu_status], 1

    pop eax
    ret

fpu_self_test:
    cmp byte [fpu_status], 1
    jne .fail

    fild dword [fpu_test_three]
    fild dword [fpu_test_four]
    faddp st1, st0
    fistp dword [fpu_test_result]
    cmp dword [fpu_test_result], 7
    jne .fail

    mov byte [fpu_test_status], 1
    ret

.fail:
    mov byte [fpu_test_status], 2
    ret

libc_strlen:
    mov edx, [esp + 4]
    xor eax, eax

.next:
    cmp byte [edx + eax], 0
    je .done
    inc eax
    jmp .next

.done:
    ret

libc_strcpy:
    push esi
    push edi

    mov edi, [esp + 12]
    mov esi, [esp + 16]
    mov eax, edi

.next:
    mov dl, [esi]
    mov [edi], dl
    inc esi
    inc edi
    test dl, dl
    jne .next

    pop edi
    pop esi
    ret

libc_strcmp:
    push esi
    push edi

    mov esi, [esp + 12]
    mov edi, [esp + 16]

.next:
    mov al, [esi]
    mov dl, [edi]
    cmp al, dl
    jne .different
    test al, al
    je .equal
    inc esi
    inc edi
    jmp .next

.different:
    movzx eax, al
    movzx edx, dl
    sub eax, edx
    pop edi
    pop esi
    ret

.equal:
    xor eax, eax
    pop edi
    pop esi
    ret

libc_memcpy:
    push esi
    push edi

    mov edi, [esp + 12]
    mov esi, [esp + 16]
    mov ecx, [esp + 20]
    mov eax, edi
    rep movsb

    pop edi
    pop esi
    ret

libc_memset:
    push edi

    mov edi, [esp + 8]
    mov eax, [esp + 12]
    mov ecx, [esp + 16]
    mov edx, edi
    rep stosb
    mov eax, edx

    pop edi
    ret

libc_abs:
    mov eax, [esp + 4]
    test eax, eax
    jns .done
    neg eax

.done:
    ret

libc_idivmod:
    push ebx

    mov eax, [esp + 8]
    mov ebx, [esp + 12]
    cmp ebx, 0
    je .zero
    cdq
    idiv ebx
    mov ebx, [esp + 16]
    test ebx, ebx
    jz .done
    mov [ebx], edx
    jmp .done

.zero:
    xor eax, eax

.done:
    pop ebx
    ret

libc_self_test:
    mov byte [libc_test_status], 0

    push dword libc_test_source
    call libc_strlen
    add esp, 4
    cmp eax, 4
    jne .fail

    push dword libc_test_source
    push dword libc_copy_buffer
    call libc_strcpy
    add esp, 8
    cmp eax, libc_copy_buffer
    jne .fail

    push dword libc_test_source
    push dword libc_copy_buffer
    call libc_strcmp
    add esp, 8
    cmp eax, 0
    jne .fail

    push dword 5
    push dword 'Z'
    push dword libc_mem_buffer
    call libc_memset
    add esp, 12
    cmp byte [libc_mem_buffer], 'Z'
    jne .fail
    cmp byte [libc_mem_buffer + 4], 'Z'
    jne .fail

    push dword 5
    push dword libc_mem_buffer
    push dword libc_copy_buffer
    call libc_memcpy
    add esp, 12
    cmp byte [libc_copy_buffer + 4], 'Z'
    jne .fail

    push dword -42
    call libc_abs
    add esp, 4
    cmp eax, 42
    jne .fail

    push dword libc_last_remainder
    push dword 5
    push dword 42
    call libc_idivmod
    add esp, 12
    mov [libc_last_quotient], eax
    cmp eax, 8
    jne .fail
    cmp dword [libc_last_remainder], 2
    jne .fail

    cmp byte [fpu_test_status], 1
    jne .fail

    mov byte [libc_test_status], 1
    ret

.fail:
    mov byte [libc_test_status], 2
    ret

kprintf:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi

    mov esi, [ebp + 8]
    lea ebx, [ebp + 12]

.next:
    lodsb
    test al, al
    je .done
    cmp al, '%'
    je .specifier
    call put_char
    jmp .next

.specifier:
    lodsb
    cmp al, 0
    je .done
    cmp al, '%'
    je .literal_percent
    cmp al, 's'
    je .string
    cmp al, 'd'
    je .signed_decimal
    cmp al, 'i'
    je .signed_decimal
    cmp al, 'u'
    je .unsigned_decimal
    cmp al, 'x'
    je .hex
    cmp al, 'X'
    je .hex
    cmp al, 'c'
    je .character
    mov dl, al
    mov al, '%'
    call put_char
    mov al, dl
    call put_char
    jmp .next

.literal_percent:
    mov al, '%'
    call put_char
    jmp .next

.string:
    push esi
    mov esi, [ebx]
    add ebx, 4
    test esi, esi
    jnz .string_ok
    mov esi, null_text

.string_ok:
    call print_string
    pop esi
    jmp .next

.signed_decimal:
    mov eax, [ebx]
    add ebx, 4
    call print_signed_dec
    jmp .next

.unsigned_decimal:
    mov eax, [ebx]
    add ebx, 4
    call print_dec
    jmp .next

.hex:
    mov eax, [ebx]
    add ebx, 4
    call print_hex32
    jmp .next

.character:
    mov eax, [ebx]
    add ebx, 4
    call put_char
    jmp .next

.done:
    xor eax, eax
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

storage_init:
    mov byte [ata_status], 0
    mov byte [fat_status], 0
    mov byte [wad_status], 0
    mov byte [wad_parse_status], 0
    mov byte [user_elf_status], 0
    mov byte [user_elf_parse_status], 0
    mov byte [doom_elf_status], 0
    mov byte [doom_elf_load_status], 0
    mov byte [doom_elf_parse_status], 0
    mov dword [fat_lba_base], 0
    mov dword [wad_size], 0
    mov dword [wad_sectors_read], 0
    mov dword [wad_lump_count], 0
    mov dword [wad_directory_offset], 0
    mov dword [playpal_offset], 0
    mov dword [playpal_size], 0
    mov dword [colormap_offset], 0
    mov dword [colormap_size], 0
    mov dword [user_elf_size], 0
    mov dword [user_elf_sectors_read], 0
    mov dword [user_entry_addr], 0
    mov dword [doom_elf_size], 0
    mov dword [doom_elf_sectors_read], 0
    mov dword [doom_entry_addr], 0
    mov dword [doom_segment_filesz], 0
    mov dword [doom_segment_memsz], 0
    mov dword [doom_segment_end], 0
    mov byte [doom_user_window_status], 0
    mov word [doom_elf_first_cluster], 0
    mov dword [current_user_base], 0
    mov dword [current_user_end], 0
    mov dword [current_user_brk], 0
    mov dword [current_user_heap_end], 0
    mov byte [present_status], 0
    mov dword [present_frame_arg], 0
    mov dword [present_palette_arg], 0
    mov dword [present_sample_first], 0
    mov dword [present_sample_mid], 0
    mov dword [present_sample_last], 0

    xor eax, eax
    mov edi, SECTOR_BUFFER_ADDR
    call ata_read_sector
    jc .ata_fail

    cmp word [SECTOR_BUFFER_ADDR + 510], 0xaa55
    jne .read_bpb
    cmp byte [SECTOR_BUFFER_ADDR + 450], 0
    je .read_bpb
    mov eax, [SECTOR_BUFFER_ADDR + 454]
    mov [fat_lba_base], eax

.read_bpb:
    mov eax, [fat_lba_base]
    mov edi, SECTOR_BUFFER_ADDR
    call ata_read_sector
    jc .fat_fail

    cmp word [SECTOR_BUFFER_ADDR + 510], 0xaa55
    jne .fat_fail
    cmp word [SECTOR_BUFFER_ADDR + 11], 512
    jne .fat_fail
    cmp word [SECTOR_BUFFER_ADDR + 22], 0
    je .fat_fail

    mov al, [SECTOR_BUFFER_ADDR + 13]
    mov [fat_sectors_per_cluster], al
    movzx eax, word [SECTOR_BUFFER_ADDR + 14]
    mov [fat_reserved_sectors], eax
    movzx eax, byte [SECTOR_BUFFER_ADDR + 16]
    mov [fat_count], eax
    movzx eax, word [SECTOR_BUFFER_ADDR + 17]
    mov [fat_root_entries], eax
    add eax, 15
    shr eax, 4
    mov [fat_root_sectors], eax
    movzx eax, word [SECTOR_BUFFER_ADDR + 22]
    mov [fat_sectors_per_fat], eax

    mov eax, [fat_lba_base]
    add eax, [fat_reserved_sectors]
    mov [fat_start_lba], eax

    mov eax, [fat_sectors_per_fat]
    mov ebx, [fat_count]
    mul ebx
    add eax, [fat_start_lba]
    mov [fat_root_lba], eax
    add eax, [fat_root_sectors]
    mov [fat_data_lba], eax
    mov byte [fat_status], 1

    call fat_find_wad
    jc .wad_fail
    mov eax, [wad_size]
    add eax, PAGE_SIZE - 1
    shr eax, 12
    mov ecx, eax
    mov eax, WAD_LOAD_ADDR
    call pmm_reserve_pages
    call fat_load_wad
    jc .wad_fail
    call wad_parse
    jc .wad_parse_fail

    call fat_find_user_elf
    jc .user_elf_fail
    mov eax, [user_elf_size]
    add eax, PAGE_SIZE - 1
    shr eax, 12
    mov ecx, eax
    mov eax, USER_ELF_LOAD_ADDR
    call pmm_reserve_pages
    call fat_load_user_elf
    jc .user_elf_fail
    call fat_find_doom_elf
    jc .doom_elf_done
    mov eax, [doom_elf_size]
    add eax, PAGE_SIZE - 1
    shr eax, 12
    mov ecx, eax
    mov eax, DOOM_ELF_LOAD_ADDR
    call pmm_reserve_pages
    call fat_load_doom_elf
    jc .doom_elf_done
    call doom_elf_prepare

.doom_elf_done:
    clc
    ret

.ata_fail:
    mov byte [ata_status], 2
    ret

.fat_fail:
    mov byte [fat_status], 2
    ret

.wad_fail:
    mov byte [wad_status], 2
    ret

.wad_parse_fail:
    mov byte [wad_parse_status], 2
    ret

.user_elf_fail:
    mov byte [user_elf_status], 2
    ret

ata_io_delay:
    push ecx
    push edx

    mov ecx, 4
    mov dx, ATA_COMMAND_STATUS

.delay_next:
    in al, dx
    loop .delay_next

    pop edx
    pop ecx
    ret

ata_wait_not_busy:
    push ecx
    push edx

    mov ecx, 0x100000
    mov dx, ATA_COMMAND_STATUS

.wait_next:
    in al, dx
    test al, 0x80
    jz .ok
    loop .wait_next
    stc
    jmp .done

.ok:
    clc

.done:
    pop edx
    pop ecx
    ret

ata_wait_drq:
    push ecx
    push edx

    mov ecx, 0x100000
    mov dx, ATA_COMMAND_STATUS

.wait_next:
    in al, dx
    test al, 0x21
    jnz .fail
    test al, 0x80
    jnz .advance
    test al, 0x08
    jnz .ok

.advance:
    loop .wait_next

.fail:
    stc
    jmp .done

.ok:
    clc

.done:
    pop edx
    pop ecx
    ret

ata_read_sector:
    push ebx
    push ecx
    push edx

    mov ebx, eax
    mov [ata_last_lba], eax
    call ata_wait_not_busy
    jc .fail

    mov eax, ebx
    shr eax, 24
    and al, 0x0f
    or al, 0xe0
    mov dx, ATA_DRIVE_HEAD
    out dx, al
    call ata_io_delay

    mov dx, ATA_SECTOR_COUNT
    mov al, 1
    out dx, al

    mov eax, ebx
    mov dx, ATA_LBA_LOW
    out dx, al

    mov eax, ebx
    shr eax, 8
    mov dx, ATA_LBA_MID
    out dx, al

    mov eax, ebx
    shr eax, 16
    mov dx, ATA_LBA_HIGH
    out dx, al

    mov dx, ATA_COMMAND_STATUS
    mov al, ATA_CMD_READ_SECTORS
    out dx, al

    call ata_wait_drq
    jc .fail

    cld
    mov dx, ATA_DATA
    mov ecx, 256
    rep insw
    mov byte [ata_status], 1
    clc
    jmp .done

.fail:
    mov byte [ata_status], 2
    stc

.done:
    pop edx
    pop ecx
    pop ebx
    ret

fat_name_match:
    push ecx
    push esi
    push edi

    mov ecx, 11
    repe cmpsb
    sete al

    pop edi
    pop esi
    pop ecx
    ret

fat_find_file:
    mov [fat_search_name], edi
    xor ebx, ebx

.sector_loop:
    cmp ebx, [fat_root_sectors]
    jae .fail
    mov eax, [fat_root_lba]
    add eax, ebx
    mov edi, SECTOR_BUFFER_ADDR
    call ata_read_sector
    jc .fail

    mov esi, SECTOR_BUFFER_ADDR
    mov ecx, 16

.entry_loop:
    cmp byte [esi], 0
    je .fail
    cmp byte [esi], 0xe5
    je .next_entry
    mov al, [esi + 11]
    test al, 0x18
    jnz .next_entry
    push ebx
    push ecx
    mov edi, [fat_search_name]
    call fat_name_match
    pop ecx
    pop ebx
    cmp al, 1
    je .found

.next_entry:
    add esi, 32
    loop .entry_loop
    inc ebx
    jmp .sector_loop

.found:
    mov ax, [esi + 26]
    mov [fat_found_first_cluster], ax
    mov eax, [esi + 28]
    mov [fat_found_size], eax
    clc
    ret

.fail:
    stc
    ret

fat_find_wad:
    mov edi, wad_name_83
    call fat_find_file
    jc .fail
    mov ax, [fat_found_first_cluster]
    mov [wad_first_cluster], ax
    mov eax, [fat_found_size]
    mov [wad_size], eax
    clc
    ret

.fail:
    stc
    ret

fat_find_user_elf:
    mov edi, user_elf_name_83
    call fat_find_file
    jc .fail
    mov ax, [fat_found_first_cluster]
    mov [user_elf_first_cluster], ax
    mov eax, [fat_found_size]
    mov [user_elf_size], eax
    clc
    ret

.fail:
    stc
    ret

fat_find_doom_elf:
    mov edi, doom_elf_name_83
    call fat_find_file
    jc .fail
    mov ax, [fat_found_first_cluster]
    mov [doom_elf_first_cluster], ax
    mov eax, [fat_found_size]
    mov [doom_elf_size], eax
    mov byte [doom_elf_status], 1
    clc
    ret

.fail:
    mov byte [doom_elf_status], 2
    stc
    ret

fat_next_cluster:
    push ebx
    push ecx
    push edx
    push edi

    shl eax, 1
    xor edx, edx
    mov ecx, 512
    div ecx
    mov ebx, edx
    add eax, [fat_start_lba]
    mov edi, SECTOR_BUFFER_ADDR
    call ata_read_sector
    jc .fail
    movzx eax, word [SECTOR_BUFFER_ADDR + ebx]
    clc
    jmp .done

.fail:
    stc

.done:
    pop edi
    pop edx
    pop ecx
    pop ebx
    ret

fat_load_file:
    cmp ebx, 0
    je .fail
    cmp ebx, ecx
    ja .fail
    mov [fat_load_remaining], ebx
    mov dword [fat_load_sectors_read], 0
    mov [fat_current_cluster], ax

.cluster_loop:
    cmp dword [fat_load_remaining], 0
    je .ok
    movzx eax, word [fat_current_cluster]
    cmp eax, 2
    jb .fail
    cmp eax, 0xfff8
    jae .fail
    sub eax, 2
    movzx ebx, byte [fat_sectors_per_cluster]
    mul ebx
    add eax, [fat_data_lba]
    mov [fat_current_lba], eax
    movzx ecx, byte [fat_sectors_per_cluster]

.sector_loop:
    cmp ecx, 0
    je .next_cluster
    cmp dword [fat_load_remaining], 0
    je .ok
    push ecx
    mov eax, [fat_current_lba]
    call ata_read_sector
    pop ecx
    jc .fail
    inc dword [fat_current_lba]
    inc dword [fat_load_sectors_read]
    cmp dword [fat_load_remaining], 512
    ja .subtract_sector
    mov dword [fat_load_remaining], 0
    jmp .sector_done

.subtract_sector:
    sub dword [fat_load_remaining], 512

.sector_done:
    dec ecx
    jmp .sector_loop

.next_cluster:
    movzx eax, word [fat_current_cluster]
    call fat_next_cluster
    jc .fail
    mov [fat_current_cluster], ax
    jmp .cluster_loop

.ok:
    clc
    ret

.fail:
    stc
    ret

fat_load_wad:
    movzx eax, word [wad_first_cluster]
    mov ebx, [wad_size]
    mov ecx, WAD_MAX_BYTES
    mov edi, WAD_LOAD_ADDR
    call fat_load_file
    jc .fail
    mov eax, [fat_load_sectors_read]
    mov [wad_sectors_read], eax
    cmp dword [WAD_LOAD_ADDR], 0x44415749
    je .ok
    cmp dword [WAD_LOAD_ADDR], 0x44415750
    jne .fail

.ok:
    mov byte [wad_status], 1
    clc
    ret

.fail:
    mov byte [wad_status], 2
    stc
    ret

fat_load_user_elf:
    movzx eax, word [user_elf_first_cluster]
    mov ebx, [user_elf_size]
    mov ecx, USER_ELF_MAX_BYTES
    mov edi, USER_ELF_LOAD_ADDR
    call fat_load_file
    jc .fail
    mov eax, [fat_load_sectors_read]
    mov [user_elf_sectors_read], eax
    cmp dword [USER_ELF_LOAD_ADDR], ELF_MAGIC
    jne .fail
    mov byte [user_elf_status], 1
    clc
    ret

.fail:
    mov byte [user_elf_status], 2
    stc
    ret

fat_load_doom_elf:
    movzx eax, word [doom_elf_first_cluster]
    mov ebx, [doom_elf_size]
    mov ecx, DOOM_ELF_MAX_BYTES
    mov edi, DOOM_ELF_LOAD_ADDR
    call fat_load_file
    jc .fail
    mov eax, [fat_load_sectors_read]
    mov [doom_elf_sectors_read], eax
    cmp dword [DOOM_ELF_LOAD_ADDR], ELF_MAGIC
    jne .fail
    mov byte [doom_elf_load_status], 1
    clc
    ret

.fail:
    mov byte [doom_elf_load_status], 2
    stc
    ret

wad_validate_range:
    push edx

    mov edx, eax
    add edx, ebx
    jc .fail
    cmp edx, [wad_size]
    ja .fail
    clc
    jmp .done

.fail:
    stc

.done:
    pop edx
    ret

wad_find_lump:
    push ecx
    push edx
    push esi
    push edi

    mov esi, WAD_LOAD_ADDR
    add esi, [wad_directory_offset]
    mov ecx, [wad_lump_count]

.entry_loop:
    cmp ecx, 0
    je .fail
    push ecx
    push esi
    lea esi, [esi + 8]
    mov edi, edx
    mov ecx, 8
    repe cmpsb
    sete al
    pop esi
    pop ecx
    cmp al, 1
    je .found
    add esi, 16
    dec ecx
    jmp .entry_loop

.found:
    mov eax, [esi]
    mov ebx, [esi + 4]
    clc
    jmp .done

.fail:
    stc

.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    ret

wad_parse:
    cmp dword [WAD_LOAD_ADDR], 0x44415749
    je .header_ok
    cmp dword [WAD_LOAD_ADDR], 0x44415750
    jne .fail

.header_ok:
    mov eax, [WAD_LOAD_ADDR + 4]
    cmp eax, 0
    je .fail
    cmp eax, 4096
    ja .fail
    mov [wad_lump_count], eax

    mov ebx, [WAD_LOAD_ADDR + 8]
    mov [wad_directory_offset], ebx
    mov edx, eax
    shl edx, 4
    add edx, ebx
    jc .fail
    cmp edx, [wad_size]
    ja .fail

    mov edx, wad_name_playpal
    call wad_find_lump
    jc .fail
    call wad_validate_range
    jc .fail
    mov [playpal_offset], eax
    mov [playpal_size], ebx

    mov edx, wad_name_colormap
    call wad_find_lump
    jc .fail
    call wad_validate_range
    jc .fail
    mov [colormap_offset], eax
    mov [colormap_size], ebx

    mov byte [wad_parse_status], 1
    clc
    ret

.fail:
    mov byte [wad_parse_status], 2
    stc
    ret

%ifndef ELF_KERNEL
%include "c_runtime_probe.nasm"
%endif

idt_init:
    pushad

    mov edi, idt_start
    mov eax, exception_halt
    mov ecx, 32

.exceptions:
    call idt_set_gate
    loop .exceptions

    mov edi, idt_start + (14 * 8)
    mov eax, page_fault_handler
    mov bl, 10001110b
    call idt_set_gate_attr

    mov edi, idt_start + (32 * 8)
    mov eax, irq_timer
    call idt_set_gate

    mov eax, irq_ignore_master
    mov ecx, 7

.master_irqs:
    call idt_set_gate
    loop .master_irqs

    mov eax, irq_ignore_slave
    mov ecx, 8

.slave_irqs:
    call idt_set_gate
    loop .slave_irqs

    mov eax, exception_halt
    mov ecx, 208

.remaining:
    call idt_set_gate
    loop .remaining

    mov edi, idt_start + (0x80 * 8)
    mov eax, syscall_handler
    mov bl, 11101110b
    call idt_set_gate_attr

    popad
    ret

idt_set_gate:
    push ebx
    mov bl, 10001110b
    call idt_set_gate_attr
    pop ebx
    ret

idt_set_gate_attr:
    push eax
    push edx

    mov edx, eax
    mov [edi], dx
    mov word [edi + 2], CODE_SEG
    mov byte [edi + 4], 0
    mov byte [edi + 5], bl
    shr edx, 16
    mov [edi + 6], dx
    add edi, 8

    pop edx
    pop eax
    ret

user_probe_run:
    mov byte [user_probe_status], 0
    mov byte [user_fault_expected], 0
    mov byte [user_fault_status], 0
    mov dword [user_probe_magic_seen], 0
    mov dword [user_probe_flags_seen], 0
    mov dword [user_fault_addr], 0
    mov dword [user_wad_magic_seen], 0
    mov dword [user_wad_fd_offset], 0
    mov dword [user_brk_current], USER_HEAP_START
    mov dword [current_user_base], USER_CODE_ADDR
    mov dword [current_user_end], USER_HEAP_END
    mov dword [current_user_brk], USER_HEAP_START
    mov dword [current_user_heap_end], USER_HEAP_END
    mov byte [present_status], 0
    mov dword [present_sample_first], 0
    mov dword [present_sample_mid], 0
    mov dword [present_sample_last], 0
    mov word [user_probe_cs], 0
    mov word [user_probe_ss], 0

    call user_elf_prepare
    jc .fail

    mov edi, USER_STACK_BOTTOM
    xor eax, eax
    mov ecx, PAGE_SIZE / 4
    rep stosd
    mov edi, USER_HEAP_START
    xor eax, eax
    mov ecx, (USER_HEAP_END - USER_HEAP_START) / 4
    rep stosd

    mov dword [tss_esp0], KERNEL_STACK_TOP
    mov word [tss_ss0], DATA_SEG

    mov ax, USER_DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    push dword USER_DATA_SEG
    push dword USER_STACK_TOP
    push dword 0x00000002
    push dword USER_CODE_SEG
    push dword [user_entry_addr]
    iretd

.fail:
    mov byte [user_probe_status], 2
    ret

user_elf_prepare:
    mov byte [user_elf_parse_status], 0
    mov byte [user_load_segment_count], 0
    mov dword [user_entry_addr], 0

    cmp byte [user_elf_status], 1
    jne .fail
    cmp dword [user_elf_size], 52
    jb .fail

    mov esi, USER_ELF_LOAD_ADDR
    cmp dword [esi], ELF_MAGIC
    jne .fail
    cmp byte [esi + 4], ELFCLASS32
    jne .fail
    cmp byte [esi + 5], ELFDATA2LSB
    jne .fail
    cmp word [esi + 16], ET_EXEC
    jne .fail
    cmp word [esi + 18], EM_386
    jne .fail
    cmp dword [esi + 20], 1
    jne .fail
    cmp word [esi + 42], 32
    jne .fail

    movzx ecx, word [esi + 44]
    cmp ecx, 0
    je .fail
    cmp ecx, 16
    ja .fail

    mov eax, [esi + 28]
    mov ebx, ecx
    shl ebx, 5
    add ebx, eax
    jc .fail
    cmp ebx, [user_elf_size]
    ja .fail

    add eax, USER_ELF_LOAD_ADDR
    mov [user_phdr_ptr], eax
    mov [user_phdr_remaining], ecx
    mov eax, [esi + 24]
    mov [user_entry_addr], eax

.phdr_loop:
    cmp dword [user_phdr_remaining], 0
    je .segments_done
    mov esi, [user_phdr_ptr]
    cmp dword [esi], PT_LOAD
    jne .next_phdr

    mov eax, [esi + 16]
    cmp eax, [esi + 20]
    ja .fail

    mov eax, [esi + 4]
    add eax, [esi + 16]
    jc .fail
    cmp eax, [user_elf_size]
    ja .fail

    mov eax, [esi + 12]
    test eax, eax
    jnz .have_destination
    mov eax, [esi + 8]

.have_destination:
    mov [user_segment_dest], eax
    cmp eax, USER_CODE_ADDR
    jb .fail
    mov ebx, eax
    add ebx, [esi + 20]
    jc .fail
    cmp ebx, USER_STACK_BOTTOM
    ja .fail

    mov eax, [esi + 16]
    mov [user_segment_filesz], eax
    mov eax, [esi + 20]
    mov [user_segment_memsz], eax

    mov eax, [esi + 4]
    add eax, USER_ELF_LOAD_ADDR
    mov esi, eax
    mov edi, [user_segment_dest]
    mov ecx, [user_segment_filesz]
    cld
    rep movsb

    mov ecx, [user_segment_memsz]
    sub ecx, [user_segment_filesz]
    xor eax, eax
    rep stosb
    inc byte [user_load_segment_count]

.next_phdr:
    add dword [user_phdr_ptr], 32
    dec dword [user_phdr_remaining]
    jmp .phdr_loop

.segments_done:
    cmp byte [user_load_segment_count], 0
    je .fail
    mov eax, [user_entry_addr]
    cmp eax, USER_CODE_ADDR
    jb .fail
    cmp eax, USER_STACK_BOTTOM
    jae .fail
    mov byte [user_elf_parse_status], 1
    clc
    ret

.fail:
    mov byte [user_elf_parse_status], 2
    stc
    ret

doom_elf_prepare:
    mov byte [doom_elf_parse_status], 0
    mov byte [doom_load_segment_count], 0
    mov dword [doom_entry_addr], 0
    mov dword [doom_segment_source], 0
    mov dword [doom_segment_dest], 0
    mov dword [doom_segment_filesz], 0
    mov dword [doom_segment_memsz], 0
    mov dword [doom_segment_end], 0
    mov byte [doom_user_window_status], 0

    cmp byte [doom_elf_load_status], 1
    jne .fail
    cmp dword [doom_elf_size], 52
    jb .fail

    mov esi, DOOM_ELF_LOAD_ADDR
    cmp dword [esi], ELF_MAGIC
    jne .fail
    cmp byte [esi + 4], ELFCLASS32
    jne .fail
    cmp byte [esi + 5], ELFDATA2LSB
    jne .fail
    cmp word [esi + 16], ET_EXEC
    jne .fail
    cmp word [esi + 18], EM_386
    jne .fail
    cmp dword [esi + 20], 1
    jne .fail
    cmp word [esi + 42], 32
    jne .fail
    cmp word [esi + 44], 1
    jne .fail

    mov eax, [esi + 28]
    mov ebx, eax
    add ebx, 32
    jc .fail
    cmp ebx, [doom_elf_size]
    ja .fail

    mov eax, [esi + 24]
    mov [doom_entry_addr], eax

    mov eax, [esi + 28]
    add eax, DOOM_ELF_LOAD_ADDR
    mov esi, eax
    cmp dword [esi], PT_LOAD
    jne .fail

    mov eax, [esi + 16]
    cmp eax, [esi + 20]
    ja .fail

    mov eax, [esi + 4]
    add eax, [esi + 16]
    jc .fail
    cmp eax, [doom_elf_size]
    ja .fail

    mov eax, [esi + 12]
    test eax, eax
    jnz .have_destination
    mov eax, [esi + 8]

.have_destination:
    mov [doom_segment_dest], eax
    cmp eax, DOOM_ELF_LOAD_ADDR
    jb .fail
    mov ebx, eax
    add ebx, [esi + 20]
    jc .fail
    cmp ebx, DOOM_ELF_LIMIT
    ja .fail
    mov [doom_segment_end], ebx
    cmp ebx, DOOM_USER_HEAP_START
    ja .fail

    mov eax, [doom_entry_addr]
    cmp eax, [doom_segment_dest]
    jb .fail
    cmp eax, ebx
    jae .fail

    mov eax, [esi + 4]
    add eax, DOOM_ELF_LOAD_ADDR
    jc .fail
    mov ebx, [doom_segment_dest]
    cmp ebx, eax
    ja .fail
    mov [doom_segment_source], eax

    mov eax, [esi + 16]
    mov [doom_segment_filesz], eax
    mov eax, [esi + 20]
    mov [doom_segment_memsz], eax

    mov esi, [doom_segment_source]
    mov edi, [doom_segment_dest]
    mov ecx, [doom_segment_filesz]
    cld
    rep movsb

    mov ecx, [doom_segment_memsz]
    sub ecx, [doom_segment_filesz]
    xor eax, eax
    rep stosb

    inc byte [doom_load_segment_count]
    mov byte [doom_user_window_status], 1
    mov byte [doom_elf_parse_status], 1
    clc
    ret

.fail:
    mov byte [doom_elf_parse_status], 2
    stc
    ret

syscall_handler:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp

    cmp eax, SYS_USER_PROBE
    je .user_probe
    cmp eax, SYS_EXIT
    je .exit
    cmp eax, SYS_EXPECT_FAULT
    je .expect_fault
    cmp eax, SYS_WRITE
    je .write
    cmp eax, SYS_SBRK
    je .sbrk
    cmp eax, SYS_OPEN
    je .open
    cmp eax, SYS_READ
    je .read
    cmp eax, SYS_LSEEK
    je .lseek
    cmp eax, SYS_TIME
    je .time
    cmp eax, SYS_PRESENT
    je .present
    jmp .bad_syscall

.user_probe:
    mov [user_probe_magic_seen], ebx
    mov [user_probe_flags_seen], ecx
    movzx edx, word [esp + 28]
    mov [user_probe_cs], dx
    movzx edx, word [esp + 40]
    mov [user_probe_ss], dx
    mov byte [user_probe_status], 1
    xor eax, eax
    jmp .return

.expect_fault:
    mov byte [user_fault_expected], 1
    xor eax, eax
    jmp .return

.write:
    cmp ebx, 1
    je .write_fd_ok
    cmp ebx, 2
    jne .bad_syscall

.write_fd_ok:
    mov [syscall_ptr_arg], ecx
    mov [syscall_len_arg], edx
    mov eax, ecx
    mov ebx, edx
    call user_range_validate
    jc .bad_syscall
    mov esi, [syscall_ptr_arg]
    mov ecx, [syscall_len_arg]

.write_next:
    cmp ecx, 0
    je .write_done
    lodsb
    call put_char
    dec ecx
    jmp .write_next

.write_done:
    mov eax, [syscall_len_arg]
    jmp .return

.sbrk:
    mov eax, [current_user_brk]
    mov edx, eax
    add edx, ebx
    jc .bad_syscall
    cmp edx, [current_user_heap_end]
    ja .bad_syscall
    mov [current_user_brk], edx
    mov [user_brk_current], edx
    jmp .return

.open:
    mov [syscall_ptr_arg], ebx
    mov eax, ebx
    mov ebx, user_path_doom_wad_end - user_path_doom_wad
    call user_range_validate
    jc .bad_syscall
    mov esi, [syscall_ptr_arg]
    mov edi, user_path_doom_wad
    mov ecx, user_path_doom_wad_end - user_path_doom_wad
    repe cmpsb
    jne .bad_syscall
    cmp byte [wad_status], 1
    jne .bad_syscall
    mov dword [user_wad_fd_offset], 0
    mov eax, USER_FD_WAD
    jmp .return

.read:
    cmp ebx, USER_FD_WAD
    jne .bad_syscall
    mov [syscall_ptr_arg], ecx
    mov [syscall_len_arg], edx
    mov eax, ecx
    mov ebx, edx
    call user_range_validate
    jc .bad_syscall
    mov eax, [wad_size]
    sub eax, [user_wad_fd_offset]
    cmp edx, eax
    jbe .read_len_ok
    mov edx, eax
    mov [syscall_len_arg], edx

.read_len_ok:
    mov esi, WAD_LOAD_ADDR
    add esi, [user_wad_fd_offset]
    mov edi, [syscall_ptr_arg]
    mov ecx, [syscall_len_arg]
    cld
    rep movsb
    mov eax, [syscall_len_arg]
    add dword [user_wad_fd_offset], eax
    cmp eax, 4
    jb .read_done
    mov edi, [syscall_ptr_arg]
    mov edx, [edi]
    mov [user_wad_magic_seen], edx

.read_done:
    jmp .return

.lseek:
    cmp ebx, USER_FD_WAD
    jne .bad_syscall
    cmp edx, 0
    je .seek_set
    cmp edx, 1
    je .seek_cur
    cmp edx, 2
    je .seek_end
    jmp .bad_syscall

.seek_set:
    mov eax, ecx
    jmp .seek_validate

.seek_cur:
    mov eax, [user_wad_fd_offset]
    add eax, ecx
    jc .bad_syscall
    jmp .seek_validate

.seek_end:
    mov eax, [wad_size]
    add eax, ecx
    jc .bad_syscall

.seek_validate:
    cmp eax, [wad_size]
    ja .bad_syscall
    mov [user_wad_fd_offset], eax
    jmp .return

.time:
    mov eax, [timer_ticks]
    mov ebx, 35
    mul ebx
    mov ebx, 100
    div ebx
    jmp .return

.present:
    mov [present_frame_arg], ebx
    mov [present_palette_arg], ecx
    mov eax, ebx
    mov ebx, DOOM_FRAME_BYTES
    call user_range_validate
    jc .bad_syscall
    mov eax, [present_palette_arg]
    mov ebx, DOOM_PALETTE_BYTES
    call user_range_validate
    jc .bad_syscall
    call present_indexed_frame
    jc .bad_syscall
    xor eax, eax
    jmp .return

.bad_syscall:
    mov eax, 0xffffffff
    jmp .return

.exit:
    mov byte [user_probe_status], 2
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, KERNEL_STACK_TOP
    jmp user_probe_finished

.return:
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    iretd

user_range_validate:
    push edx
    cmp ebx, 0
    je .ok
    cmp eax, [current_user_base]
    jb .fail
    mov edx, eax
    add edx, ebx
    jc .fail
    cmp edx, [current_user_end]
    ja .fail

.ok:
    clc
    jmp .done

.fail:
    stc

.done:
    pop edx
    ret

present_indexed_frame:
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov dx, VGA_DAC_WRITE_INDEX
    xor al, al
    out dx, al
    mov dx, VGA_DAC_DATA
    mov esi, [present_palette_arg]
    mov ecx, DOOM_PALETTE_BYTES

.palette_next:
    lodsb
    shr al, 2
    out dx, al
    loop .palette_next

    mov esi, [present_frame_arg]
    mov edi, VGA_GRAPHICS_BUFFER
    mov ecx, DOOM_FRAME_BYTES / 4
    cld
    rep movsd

    movzx eax, byte [VGA_GRAPHICS_BUFFER]
    mov [present_sample_first], eax
    movzx eax, byte [VGA_GRAPHICS_BUFFER + 320]
    mov [present_sample_mid], eax
    movzx eax, byte [VGA_GRAPHICS_BUFFER + DOOM_FRAME_BYTES - 1]
    mov [present_sample_last], eax
    mov byte [present_status], 1
    clc

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

page_fault_handler:
    cmp byte [user_fault_expected], 1
    jne exception_halt
    mov byte [user_fault_expected], 0
    mov byte [user_fault_status], 1
    mov byte [user_probe_status], 3
    mov eax, cr2
    mov [user_fault_addr], eax
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, KERNEL_STACK_TOP
    jmp user_probe_finished

exception_halt:
    cli

.halt:
    hlt
    jmp .halt

irq_timer:
    pushad
    inc dword [timer_ticks]
    call draw_timer_status
    call write_smoke_status
    mov al, 0x20
    out 0x20, al
    popad
    iretd

irq_ignore_master:
    push eax
    mov al, 0x20
    out 0x20, al
    pop eax
    iretd

irq_ignore_slave:
    push eax
    mov al, 0x20
    out 0xa0, al
    out 0x20, al
    pop eax
    iretd

draw_timer_status:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov edi, VGA_BUFFER + ((VGA_ROWS - 1) * VGA_COLS * 2)
    mov esi, ticks_status_label

.label_next:
    lodsb
    test al, al
    jz .label_done
    mov ah, 0x0a
    mov [edi], ax
    add edi, 2
    jmp .label_next

.label_done:
    mov edx, [timer_ticks]
    mov ecx, 8

.hex_next:
    rol edx, 4
    mov bl, dl
    and bl, 0x0f
    movzx ebx, bl
    mov al, [hex_digits + ebx]
    mov ah, 0x0a
    mov [edi], ax
    add edi, 2
    loop .hex_next

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

write_smoke_status:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    cld
    mov edi, SMOKE_STATUS_ADDR
    xor eax, eax
    mov ecx, SMOKE_STATUS_BYTES / 4
    rep stosd

    mov edi, SMOKE_STATUS_ADDR
    mov esi, smoke_banner_text
    call smoke_copy_string

    mov esi, smoke_doom_text
    call smoke_copy_string
    cmp byte [doom_elf_status], 1
    jne .doom_fail
    cmp byte [doom_elf_load_status], 1
    jne .doom_fail
    cmp byte [doom_elf_parse_status], 1
    jne .doom_fail
    cmp byte [doom_load_segment_count], 1
    jne .doom_fail
    cmp byte [doom_user_window_status], 1
    jne .doom_fail
    mov esi, smoke_ok_text
    jmp .doom_write

.doom_fail:
    mov esi, smoke_fail_text

.doom_write:
    call smoke_copy_string

    mov esi, smoke_gfx_text
    call smoke_copy_string
    cmp byte [present_status], 1
    je .gfx_ok
    mov esi, smoke_fail_text
    jmp .gfx_write

.gfx_ok:
    mov esi, smoke_ok_text

.gfx_write:
    call smoke_copy_string

    mov esi, smoke_status_text
    call smoke_copy_string

    mov esi, paging_status_label
    call smoke_copy_string
    cmp byte [paging_status], 1
    je .paging_ok
    mov esi, off_status_text
    jmp .paging_write

.paging_ok:
    mov esi, on_status_text

.paging_write:
    call smoke_copy_string
    mov al, ' '
    stosb

    mov esi, pmm_status_label + 1
    call smoke_copy_string
    cmp byte [pmm_test_status], 1
    je .pmm_ok
    mov esi, fail_status_text
    jmp .pmm_write

.pmm_ok:
    mov esi, ok_status_text

.pmm_write:
    call smoke_copy_string
    mov al, ' '
    stosb

    mov esi, vmm_status_label + 1
    call smoke_copy_string
    cmp byte [vmm_test_status], 1
    je .vmm_ok
    mov esi, fail_status_text
    jmp .vmm_write

.vmm_ok:
    mov esi, ok_status_text

.vmm_write:
    call smoke_copy_string
    mov al, ' '
    stosb

    mov esi, libc_status_label + 1
    call smoke_copy_string
    cmp byte [libc_test_status], 1
    je .libc_ok
    mov esi, fail_status_text
    jmp .libc_write

.libc_ok:
    mov esi, ok_status_text

.libc_write:
    call smoke_copy_string
    mov al, ' '
    stosb

    mov esi, c_status_label + 1
    call smoke_copy_string
    cmp byte [c_runtime_status], 1
    je .c_ok
    mov esi, fail_status_text
    jmp .c_write

.c_ok:
    mov esi, ok_status_text

.c_write:
    call smoke_copy_string
    mov al, ' '
    stosb

    mov esi, user_status_label + 1
    call smoke_copy_string
    cmp byte [user_elf_status], 1
    jne .user_fail
    cmp byte [user_elf_parse_status], 1
    jne .user_fail
    cmp dword [user_probe_flags_seen], USER_PROBE_EXPECTED_FLAGS
    jne .user_fail
    cmp byte [user_probe_status], 3
    jne .user_fail
    mov esi, smoke_ok_text
    jmp .user_write

.user_fail:
    mov esi, smoke_fail_text

.user_write:
    call smoke_copy_string
    mov al, ' '
    stosb

    mov esi, wad_status_label + 1
    call smoke_copy_string
    cmp byte [wad_status], 1
    je .wad_ok
    mov esi, fail_status_text
    jmp .wad_write

.wad_ok:
    mov esi, ok_status_text

.wad_write:
    call smoke_copy_string
    mov al, ' '
    stosb

    mov esi, lump_status_label + 1
    call smoke_copy_string
    cmp byte [wad_parse_status], 1
    je .lump_ok
    mov esi, fail_status_text
    jmp .lump_write

.lump_ok:
    mov esi, ok_status_text

.lump_write:
    call smoke_copy_string
    mov al, ' '
    stosb

    mov esi, heap_status_label
    call smoke_copy_string
    cmp byte [heap_test_status], 1
    je .heap_ok
    mov esi, fail_status_text
    jmp .heap_write

.heap_ok:
    mov esi, ok_status_text

.heap_write:
    call smoke_copy_string
    mov esi, heap_status_free_label
    call smoke_copy_string
    call heap_free_bytes
    mov edx, eax
    call smoke_write_hex32

    mov al, ' '
    stosb
    mov esi, ticks_status_label
    call smoke_copy_string
    mov edx, [timer_ticks]
    call smoke_write_hex32

    mov al, 13
    stosb
    mov al, 10
    stosb

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

smoke_copy_string:
    lodsb
    test al, al
    jz .done
    stosb
    jmp smoke_copy_string

.done:
    ret

smoke_write_hex32:
    push ebx
    push ecx

    mov ecx, 8

.next:
    rol edx, 4
    mov bl, dl
    and bl, 0x0f
    movzx ebx, bl
    mov al, [hex_digits + ebx]
    stosb
    loop .next

    pop ecx
    pop ebx
    ret

draw_doom_status:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov edi, VGA_BUFFER + ((VGA_ROWS - 3) * VGA_COLS * 2)
    mov ax, (VGA_ATTR << 8) | ' '
    mov ecx, VGA_COLS

.clear_row:
    mov [edi], ax
    add edi, 2
    loop .clear_row

    mov edi, VGA_BUFFER + ((VGA_ROWS - 3) * VGA_COLS * 2)
    mov esi, doom_status_label
    call draw_status_string
    cmp byte [doom_elf_status], 1
    jne .fail
    cmp byte [doom_elf_load_status], 1
    jne .fail
    cmp byte [doom_elf_parse_status], 1
    jne .fail
    cmp byte [doom_load_segment_count], 1
    jne .fail
    cmp byte [doom_user_window_status], 1
    jne .fail

    mov esi, ok_status_text
    call draw_status_string
    mov esi, doom_status_entry_label
    call draw_status_string
    mov edx, [doom_entry_addr]
    call draw_status_hex32
    mov esi, doom_status_mem_label
    call draw_status_string
    mov edx, [doom_segment_memsz]
    call draw_status_hex32
    mov esi, gfx_status_label
    call draw_status_string
    cmp byte [present_status], 1
    je .gfx_ok
    mov esi, fail_status_text
    call draw_status_string
    jmp .done

.gfx_ok:
    mov esi, ok_status_text
    call draw_status_string
    jmp .done

.fail:
    mov esi, fail_status_text
    call draw_status_string

.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

draw_heap_status:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov edi, VGA_BUFFER + ((VGA_ROWS - 2) * VGA_COLS * 2)
    mov ax, (VGA_ATTR << 8) | ' '
    mov ecx, VGA_COLS

.clear_row:
    mov [edi], ax
    add edi, 2
    loop .clear_row

    mov edi, VGA_BUFFER + ((VGA_ROWS - 2) * VGA_COLS * 2)
    mov esi, paging_status_label
    call draw_status_string
    cmp byte [paging_status], 1
    je .paging_ok
    mov esi, off_status_text
    call draw_status_string
    jmp .pmm_status

.paging_ok:
    mov esi, on_status_text
    call draw_status_string

.pmm_status:
    mov esi, pmm_status_label
    call draw_status_string
    cmp byte [pmm_test_status], 1
    je .pmm_ok
    mov esi, fail_status_text
    call draw_status_string
    jmp .heap_status

.pmm_ok:
    mov esi, ok_status_text
    call draw_status_string

.vmm_status:
    mov esi, vmm_status_label
    call draw_status_string
    cmp byte [vmm_test_status], 1
    je .vmm_ok
    mov esi, fail_status_text
    call draw_status_string
    jmp .heap_status

.vmm_ok:
    mov esi, ok_status_text
    call draw_status_string

.libc_status:
    mov esi, libc_status_label
    call draw_status_string
    cmp byte [libc_test_status], 1
    je .libc_ok
    mov esi, fail_status_text
    call draw_status_string
    jmp .heap_status

.libc_ok:
    mov esi, ok_status_text
    call draw_status_string

.c_status:
    mov esi, c_status_label
    call draw_status_string
    cmp byte [c_runtime_status], 1
    je .c_ok
    mov esi, fail_status_text
    call draw_status_string
    jmp .wad_status

.c_ok:
    mov esi, ok_status_text
    call draw_status_string

.user_status:
    mov esi, user_status_label
    call draw_status_string
    cmp byte [user_elf_status], 1
    jne .user_fail
    cmp byte [user_elf_parse_status], 1
    jne .user_fail
    cmp dword [user_probe_flags_seen], USER_PROBE_EXPECTED_FLAGS
    jne .user_fail
    cmp byte [user_probe_status], 3
    je .user_ok

.user_fail:
    mov esi, fail_status_text
    call draw_status_string
    jmp .wad_status

.user_ok:
    mov esi, ok_status_text
    call draw_status_string

.wad_status:
    mov esi, wad_status_label
    call draw_status_string
    cmp byte [wad_status], 1
    je .wad_ok
    mov esi, fail_status_text
    call draw_status_string
    jmp .heap_status

.wad_ok:
    mov esi, ok_status_text
    call draw_status_string

.lump_status:
    mov esi, lump_status_label
    call draw_status_string
    cmp byte [wad_parse_status], 1
    je .lump_ok
    mov esi, fail_status_text
    call draw_status_string
    jmp .heap_status

.lump_ok:
    mov esi, ok_status_text
    call draw_status_string

.heap_status:
    mov esi, heap_status_gap
    call draw_status_string
    mov esi, heap_status_label
    call draw_status_string

    cmp byte [heap_test_status], 1
    je .status_ok
    mov esi, fail_status_text
    call draw_status_string
    jmp .free

.status_ok:
    mov esi, ok_status_text
    call draw_status_string

.free:
    mov esi, heap_status_free_label
    call draw_status_string
    call heap_free_bytes
    mov edx, eax
    call draw_status_hex32

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

draw_status_string:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0b
    mov [edi], ax
    add edi, 2
    jmp draw_status_string

.done:
    ret

draw_status_hex32:
    push eax
    push ebx
    push ecx

    mov ecx, 8

.next:
    rol edx, 4
    mov bl, dl
    and bl, 0x0f
    movzx ebx, bl
    mov al, [hex_digits + ebx]
    mov ah, 0x0b
    mov [edi], ax
    add edi, 2
    loop .next

    pop ecx
    pop ebx
    pop eax
    ret

print_dec:
    push eax
    push ebx
    push ecx
    push edx

    xor ecx, ecx
    mov ebx, 10
    cmp eax, 0
    jne .divide
    mov al, '0'
    call put_char
    jmp .done

.divide:
    xor edx, edx
    div ebx
    push edx
    inc ecx
    cmp eax, 0
    jne .divide

.digits:
    pop edx
    mov al, dl
    add al, '0'
    call put_char
    loop .digits

.done:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

print_signed_dec:
    push eax

    test eax, eax
    jns .positive
    neg eax
    push eax
    mov al, '-'
    call put_char
    pop eax

.positive:
    call print_dec
    pop eax
    ret

print_hex32:
    push eax
    push ebx
    push ecx
    push edx

    mov edx, eax
    mov al, '0'
    call put_char
    mov al, 'x'
    call put_char
    mov ecx, 8

.next:
    rol edx, 4
    mov bl, dl
    and bl, 0x0f
    movzx ebx, bl
    mov al, [hex_digits + ebx]
    call put_char
    loop .next

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

banner db 13, 10
       db "Aurora OS v0.2", 13, 10
       db "32-bit protected mode kernel online.", 13, 10
       db "Type 'help' for commands.", 13, 10, 13, 10, 0

prompt db "aurora> ", 0

help_text db "Commands:", 13, 10
          db "  help    show this list", 13, 10
          db "  about   describe the kernel", 13, 10
          db "  clear   reset the display", 13, 10
          db "  echo    print text", 13, 10
          db "  mem     show BIOS memory captured before protected mode", 13, 10
          db "  mode    show CPU execution mode", 13, 10
          db "  ticks   show timer interrupt ticks", 13, 10
          db "  heap    show kernel heap state", 13, 10
          db "  paging  show paging and physical frame state", 13, 10
          db "  libc    show C runtime subset status", 13, 10
          db "  c       run compiled-C kernel probe", 13, 10
          db "  user    show Ring 3 syscall probe status", 13, 10
          db "  wad     show IDE/FAT16 WAD loader status", 13, 10
          db "  reboot  restart via keyboard controller", 13, 10
          db "  halt    stop the CPU", 13, 10, 0

about_text db "Aurora now runs outside BIOS services with its own VGA text and keyboard IO.", 13, 10
           db "The kernel owns IDT, PIC, PIT ticks, paging, frame accounting, heap, libc, and IDE/FAT WAD loading.", 13, 10, 0

mode_text db "CPU mode: 32-bit protected mode, flat 4 GiB code/data segments.", 13, 10, 0
unknown_message db "Unknown command: ", 0
conventional_prefix db "Conventional memory: ", 0
extended_prefix db "Extended memory: ", 0
kb_suffix db " KB", 13, 10, 0
ticks_prefix db "Timer ticks: ", 0
ticks_suffix db " at 100 Hz", 13, 10, 0
ticks_status_label db "ticks=", 0
heap_start_prefix db "Heap start: ", 0
heap_free_head_prefix db "Heap free head: ", 0
heap_free_prefix db "Heap free:  ", 0
heap_alloc_prefix db "Heap active allocations: ", 0
heap_test_prefix db "Heap self-test: ", 0
paging_state_prefix db "Paging: ", 0
paging_dir_prefix db "Page directory: ", 0
paging_mapped_prefix db "Identity mapped: ", 0
pmm_total_prefix db "Physical frames tracked: ", 0
pmm_free_prefix db "Physical frames free: ", 0
pmm_used_prefix db "Physical frames used: ", 0
pmm_test_prefix db "PMM self-test: ", 0
vmm_test_prefix db "VMM map self-test: ", 0
libc_status_fmt db "libc self-test: %s", 13, 10, 0
fpu_status_fmt db "x87 floating-point self-test: %s", 13, 10, 0
libc_strlen_fmt db "strlen(doom)=%d", 13, 10, 0
libc_math_fmt db "42 / 5 => quotient=%d remainder=%d", 13, 10, 0
ata_status_prefix db "ATA PIO disk: ", 0
fat_status_prefix db "FAT16 filesystem: ", 0
wad_status_prefix db "DOOM1.WAD loader: ", 0
wad_parse_prefix db "WAD directory parser: ", 0
wad_size_prefix db "WAD size: ", 0
wad_lump_count_prefix db "WAD lumps: ", 0
wad_dir_prefix db "WAD directory offset: ", 0
playpal_prefix db "PLAYPAL offset: ", 0
colormap_prefix db "COLORMAP offset: ", 0
lump_size_mid db " size=", 0
wad_cluster_prefix db "WAD first cluster: ", 0
doom_elf_prefix db "DOOM.ELF FAT entry: ", 0
doom_elf_size_prefix db "DOOM.ELF size: ", 0
doom_elf_cluster_prefix db "DOOM.ELF first cluster: ", 0
doom_elf_load_prefix db "DOOM.ELF load: ", 0
doom_elf_parse_prefix db "DOOM.ELF parser: ", 0
doom_elf_entry_prefix db "DOOM.ELF entry: ", 0
doom_elf_mem_prefix db "DOOM.ELF segment bytes: ", 0
doom_elf_end_prefix db "DOOM.ELF segment end: ", 0
doom_user_window_prefix db "DOOM user window: ", 0
wad_load_prefix db "WAD load address: ", 0
bytes_suffix db " bytes", 13, 10, 0
pages_suffix db " pages", 13, 10, 0
mib_suffix db " MiB", 13, 10, 0
heap_status_label db "heap=", 0
heap_status_free_label db " free=", 0
paging_status_label db "pg=", 0
pmm_status_label db " pmm=", 0
vmm_status_label db " vmm=", 0
libc_status_label db " libc=", 0
c_status_label db " c=", 0
user_status_label db " usr=", 0
wad_status_label db " wad=", 0
lump_status_label db " lmp=", 0
doom_status_label db "doom=", 0
doom_status_entry_label db " entry=", 0
doom_status_mem_label db " mem=", 0
gfx_status_label db " gfx=", 0
smoke_banner_text db "Aurora OS v0.2 ", 0
smoke_doom_text db "doom=", 0
smoke_gfx_text db " gfx=", 0
smoke_status_text db " ", 0
smoke_ok_text db "OK", 0
smoke_fail_text db "FAIL", 0
heap_status_gap db " ", 0
ok_text db "OK", 13, 10, 0
fail_text db "FAIL", 13, 10, 0
ok_text_plain db "OK", 0
fail_text_plain db "FAIL", 0
on_text db "ON", 13, 10, 0
off_text db "OFF", 13, 10, 0
null_text db "(null)", 0
ok_status_text db "OK", 0
fail_status_text db "FAIL", 0
on_status_text db "ON", 0
off_status_text db "OFF", 0
hex_digits db "0123456789ABCDEF"
reboot_message db "Rebooting through the PS/2 controller...", 13, 10, 0
halt_message db "CPU halted. Close QEMU to exit.", 13, 10, 0

cmd_help db "help", 0
cmd_about db "about", 0
cmd_clear db "clear", 0
cmd_echo db "echo", 0
cmd_mem db "mem", 0
cmd_mode db "mode", 0
cmd_ticks db "ticks", 0
cmd_heap db "heap", 0
cmd_paging db "paging", 0
cmd_libc db "libc", 0
cmd_c db "c", 0
cmd_user db "user", 0
cmd_wad db "wad", 0
cmd_reboot db "reboot", 0
cmd_halt db "halt", 0

wad_name_83 db "DOOM1   WAD"
user_elf_name_83 db "USERPROBELF"
doom_elf_name_83 db "DOOM    ELF"
wad_name_playpal db "PLAYPAL", 0
wad_name_colormap db "COLORMAP"
user_path_doom_wad db "DOOM1.WAD", 0
user_path_doom_wad_end:
user_elf_prefix db "User ELF loader: ", 0
user_entry_prefix db "User entry: ", 0
user_flags_prefix db "User syscall flags: ", 0
user_wad_magic_prefix db "User WAD magic: ", 0
user_status_prefix db "Ring 3 syscall probe: ", 0
user_magic_prefix db "User magic: ", 0
user_cs_prefix db "User CS: ", 0
user_ss_prefix db " SS: ", 0
user_fault_prefix db "User isolation fault: ", 0
user_fault_addr_prefix db " at ", 0
libc_test_source db "doom", 0
fpu_test_three dd 3
fpu_test_four dd 4
fpu_test_result dd 0
libc_last_quotient dd 0
libc_last_remainder dd 0
libc_copy_buffer times 32 db 0
libc_mem_buffer times 32 db 0

keymap_normal:
    times 0x01 - ($ - keymap_normal) db 0
    db 27
    db '1','2','3','4','5','6','7','8','9','0'
    db '-','=',8,9
    db 'q','w','e','r','t','y','u','i','o','p'
    db '[',']',13
    times 0x1e - ($ - keymap_normal) db 0
    db 'a','s','d','f','g','h','j','k','l'
    db ';',39,'`'
    times 0x2b - ($ - keymap_normal) db 0
    db 92
    db 'z','x','c','v','b','n','m'
    db ',','.','/'
    times 0x39 - ($ - keymap_normal) db 0
    db ' '
    times 128 - ($ - keymap_normal) db 0

keymap_shift:
    times 0x01 - ($ - keymap_shift) db 0
    db 27
    db '!','@','#','$','%','^','&','*','(',')'
    db '_','+',8,9
    db 'Q','W','E','R','T','Y','U','I','O','P'
    db '{','}',13
    times 0x1e - ($ - keymap_shift) db 0
    db 'A','S','D','F','G','H','J','K','L'
    db ':',34,'~'
    times 0x2b - ($ - keymap_shift) db 0
    db '|'
    db 'Z','X','C','V','B','N','M'
    db '<','>','?'
    times 0x39 - ($ - keymap_shift) db 0
    db ' '
    times 128 - ($ - keymap_shift) db 0

cursor_row dd 0
cursor_col dd 0
timer_ticks dd 0
paging_status db 0
vmm_status db 0
pmm_test_status db 0
vmm_test_status db 0
heap_test_status db 0
fpu_status db 0
fpu_test_status db 0
libc_test_status db 0
c_runtime_status db 0
user_probe_status db 0
user_fault_expected db 0
user_fault_status db 0
user_elf_status db 0
user_elf_parse_status db 0
doom_elf_status db 0
doom_elf_load_status db 0
doom_elf_parse_status db 0
doom_user_window_status db 0
ata_status db 0
fat_status db 0
wad_status db 0
wad_parse_status db 0
align 4
pmm_total_pages dd 0
pmm_free_pages dd 0
pmm_used_pages dd 0
ata_last_lba dd 0
fat_lba_base dd 0
fat_reserved_sectors dd 0
fat_count dd 0
fat_root_entries dd 0
fat_root_sectors dd 0
fat_sectors_per_fat dd 0
fat_start_lba dd 0
fat_root_lba dd 0
fat_data_lba dd 0
fat_current_lba dd 0
fat_search_name dd 0
fat_found_size dd 0
fat_load_remaining dd 0
fat_load_sectors_read dd 0
wad_size dd 0
wad_remaining dd 0
wad_sectors_read dd 0
wad_lump_count dd 0
wad_directory_offset dd 0
playpal_offset dd 0
playpal_size dd 0
colormap_offset dd 0
colormap_size dd 0
user_elf_size dd 0
user_elf_sectors_read dd 0
user_entry_addr dd 0
doom_elf_size dd 0
doom_elf_sectors_read dd 0
doom_entry_addr dd 0
doom_segment_source dd 0
doom_segment_dest dd 0
doom_segment_filesz dd 0
doom_segment_memsz dd 0
doom_segment_end dd 0
user_phdr_ptr dd 0
user_phdr_remaining dd 0
user_segment_dest dd 0
user_segment_filesz dd 0
user_segment_memsz dd 0
syscall_ptr_arg dd 0
syscall_len_arg dd 0
user_probe_magic_seen dd 0
user_probe_flags_seen dd 0
user_fault_addr dd 0
user_wad_magic_seen dd 0
user_wad_fd_offset dd 0
user_brk_current dd 0
current_user_base dd 0
current_user_end dd 0
current_user_brk dd 0
current_user_heap_end dd 0
present_frame_arg dd 0
present_palette_arg dd 0
present_sample_first dd 0
present_sample_mid dd 0
present_sample_last dd 0
heap_start dd 0
heap_free_head dd 0
heap_end dd 0
heap_alloc_count dd 0
heap_alloc_bytes dd 0
heap_last_ptr dd 0
command_start dd 0
fat_current_cluster dw 0
fat_found_first_cluster dw 0
wad_first_cluster dw 0
user_elf_first_cluster dw 0
doom_elf_first_cluster dw 0
user_probe_cs dw 0
user_probe_ss dw 0
fat_sectors_per_cluster db 0
user_load_segment_count db 0
doom_load_segment_count db 0
present_status db 0
shift_down db 0
input_buffer times INPUT_MAX db 0

align 8
kernel_gdt_start:
kernel_gdt_null:
    dq 0

kernel_gdt_code:
    dw 0xffff
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00

kernel_gdt_data:
    dw 0xffff
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00

kernel_gdt_user_code:
    dw 0xffff
    dw 0x0000
    db 0x00
    db 11111010b
    db 11001111b
    db 0x00

kernel_gdt_user_data:
    dw 0xffff
    dw 0x0000
    db 0x00
    db 11110010b
    db 11001111b
    db 0x00

kernel_gdt_tss:
    dw tss_end - tss_start - 1
    dw 0
    db 0
    db 10001001b
    db 0
    db 0

kernel_gdt_end:

kernel_gdt_descriptor:
    dw kernel_gdt_end - kernel_gdt_start - 1
    dd kernel_gdt_start

align 4
tss_start:
    dd 0
tss_esp0:
    dd 0
tss_ss0:
    dw DATA_SEG
    dw 0
    times 102 - ($ - tss_start) db 0
    dw tss_end - tss_start
tss_end:

idt_start:
    times 256 * 8 db 0
idt_end:

idt_descriptor:
    dw idt_end - idt_start - 1
    dd idt_start
