bits 16
org 0x8000

KERNEL_SEG equ 0x1000
KERNEL_OFF equ 0x0000
KERNEL_PHYS equ 0x00010000
KERNEL_ELF_SEG equ 0x4000
KERNEL_ELF_OFF equ 0x0000
KERNEL_ELF_PHYS equ 0x00040000
STAGE2_SECTORS equ 16
KERNEL_LBA equ 17
KERNEL_SECTORS equ 320
KERNEL_READ_CHUNK_SECTORS equ 64
KERNEL_ELF_MAX_BYTES equ KERNEL_SECTORS * 512
KERNEL_LOAD_LIMIT equ KERNEL_ELF_PHYS
DISK_RETRIES equ 3
CHS_SECTOR_BYTES_IN_PARAGRAPHS equ 0x20

ELF_MAGIC equ 0x464c457f
ELFCLASS32 equ 1
ELFDATA2LSB equ 1
ELF_VERSION_CURRENT equ 1
ELF_HEADER_SIZE equ 52
ELF_PHDR_SIZE equ 32
ELF_MAX_PHDRS equ 16
ET_EXEC equ 2
EM_386 equ 3
PT_LOAD equ 1

BOOT_INFO_ADDR equ 0x7000
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
BOOT_LOADER_MAGIC_ADDR equ BOOT_INFO_ADDR + 48
BOOT_LOADER_VERSION_ADDR equ BOOT_INFO_ADDR + 52
BOOT_LOADER_STATUS_ADDR equ BOOT_INFO_ADDR + 54
BOOT_LOADER_FLAGS_ADDR equ BOOT_INFO_ADDR + 56
BOOT_LOADER_STAGE2_SECTORS_ADDR equ BOOT_INFO_ADDR + 60
BOOT_LOADER_KERNEL_SECTORS_ADDR equ BOOT_INFO_ADDR + 62
BOOT_LOADER_KERNEL_ENTRY_ADDR equ BOOT_INFO_ADDR + 64
BOOT_LOADER_ELF_LOADS_ADDR equ BOOT_INFO_ADDR + 68
BOOT_VIDEO_FLAG_VBE equ 0x0001
BOOT_VIDEO_FLAG_LFB equ 0x0002
BOOT_VIDEO_FLAG_XRGB8888 equ 0x0004
BOOT_E820_MAGIC equ 0x30323845
BOOT_LOADER_MAGIC equ 0x534f4942
BOOT_LOADER_VERSION equ 1
BOOT_LOADER_STATUS_STARTED equ 1
BOOT_LOADER_STATUS_OK equ 2
BOOT_LOADER_FLAG_STAGE2_REACHED equ 0x00000001
BOOT_LOADER_FLAG_EDD_PRESENT equ 0x00000002
BOOT_LOADER_FLAG_KERNEL_EDD_READ equ 0x00000004
BOOT_LOADER_FLAG_KERNEL_CHS_READ equ 0x00000008
BOOT_LOADER_FLAG_E820 equ 0x00000010
BOOT_LOADER_FLAG_VBE_LFB equ 0x00000020
BOOT_LOADER_FLAG_MODE13 equ 0x00000040
BOOT_LOADER_FLAG_A20 equ 0x00000080
BOOT_LOADER_FLAG_GDT_LOADED equ 0x00000100
BOOT_LOADER_FLAG_PROTECTED_MODE equ 0x00000200
BOOT_LOADER_FLAG_ELF_VALID equ 0x00000400
BOOT_LOADER_FLAG_ENTRY_COVERED equ 0x00000800
BOOT_LOADER_FLAG_E820_BOUNDED equ 0x00001000
BOOT_LOADER_FLAG_VIDEO_VALID equ 0x00002000
BOOT_LOADER_FLAG_ELF_PHDR_VALID equ 0x00004000
BOOT_LOADER_FLAG_CHS_GEOMETRY equ 0x00008000
BOOT_LOADER_REQUIRED_PROTECTED_FLAGS equ BOOT_LOADER_FLAG_STAGE2_REACHED | BOOT_LOADER_FLAG_E820 | BOOT_LOADER_FLAG_E820_BOUNDED | BOOT_LOADER_FLAG_VIDEO_VALID | BOOT_LOADER_FLAG_A20 | BOOT_LOADER_FLAG_GDT_LOADED | BOOT_LOADER_FLAG_PROTECTED_MODE | BOOT_LOADER_FLAG_ELF_VALID | BOOT_LOADER_FLAG_ENTRY_COVERED | BOOT_LOADER_FLAG_ELF_PHDR_VALID
E820_SMAP equ 0x534d4150
E820_MAP_ADDR equ 0x7100
E820_ENTRY_SIZE equ 24
E820_MAX_ENTRIES equ 32
E820_MAP_END equ E820_MAP_ADDR + E820_ENTRY_SIZE * E820_MAX_ENTRIES
VBE_INFO_ADDR equ 0x6000
VBE_MODE_INFO_ADDR equ 0x6200
VBE_MAX_MODES equ 128
A20_TEST_LOW_OFF equ 0x0500
A20_TEST_HIGH_SEG equ 0xffff
A20_TEST_HIGH_OFF equ 0x0510
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti
    cld

    mov [boot_drive], dl
    mov si, stage2_message
    call print_string

    call clear_boot_info

    int 0x12
    mov [BOOT_INFO_ADDR], ax

    mov ah, 0x88
    int 0x15
    jc .skip_ext_mem
    mov [BOOT_INFO_ADDR + 4], ax

.skip_ext_mem:
    mov al, [boot_drive]
    mov [BOOT_INFO_ADDR + 2], al
    call initialize_bios_boot_handoff
    call collect_e820_map

    call require_edd

    call load_kernel_elf_sectors

    call set_vbe_lfb_or_mode13
    call validate_boot_info_handoff
    call enable_a20

    cli
    or dword [BOOT_LOADER_FLAGS_ADDR], BOOT_LOADER_FLAG_GDT_LOADED
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 0x00000001
    mov cr0, eax
    jmp CODE_SEG:protected_entry

require_edd:
    mov byte [disk_use_edd], 0
    mov ah, 0x41
    mov bx, 0x55aa
    mov dl, [boot_drive]
    int 0x13
    jc .chs
    cmp bx, 0xaa55
    jne .chs
    test cx, 0x0001
    jz .chs
    mov byte [disk_use_edd], 1
    or dword [BOOT_LOADER_FLAGS_ADDR], BOOT_LOADER_FLAG_EDD_PRESENT
    ret

.chs:
    call ensure_chs_geometry
    ret

clear_boot_info:
    push ax
    push cx
    push di
    push es

    xor ax, ax
    mov es, ax
    mov di, BOOT_INFO_ADDR
    mov cx, 128
    rep stosw

    pop es
    pop di
    pop cx
    pop ax
    ret

initialize_bios_boot_handoff:
    mov dword [BOOT_LOADER_MAGIC_ADDR], BOOT_LOADER_MAGIC
    mov word [BOOT_LOADER_VERSION_ADDR], BOOT_LOADER_VERSION
    mov word [BOOT_LOADER_STATUS_ADDR], BOOT_LOADER_STATUS_STARTED
    mov dword [BOOT_LOADER_FLAGS_ADDR], BOOT_LOADER_FLAG_STAGE2_REACHED
    mov word [BOOT_LOADER_STAGE2_SECTORS_ADDR], STAGE2_SECTORS
    mov word [BOOT_LOADER_KERNEL_SECTORS_ADDR], KERNEL_SECTORS
    mov dword [BOOT_LOADER_KERNEL_ENTRY_ADDR], 0
    mov dword [BOOT_LOADER_ELF_LOADS_ADDR], 0
    ret

collect_e820_map:
    push ax
    push bx
    push cx
    push dx
    push di
    push bp
    push es

    xor ax, ax
    mov es, ax
    mov dword [BOOT_E820_MAGIC_ADDR], 0
    mov word [BOOT_E820_COUNT], 0
    mov word [BOOT_E820_ENTRY_SIZE_ADDR], E820_ENTRY_SIZE
    mov dword [BOOT_E820_MAP_ADDR_PTR], E820_MAP_ADDR

    xor ebx, ebx
    xor bp, bp
    mov di, E820_MAP_ADDR

.next_entry:
    cmp bp, E820_MAX_ENTRIES
    jae .finish
    cmp di, E820_MAP_END
    jae .finish

    mov dword [es:di + 20], 1
    mov eax, 0xe820
    mov edx, E820_SMAP
    mov ecx, E820_ENTRY_SIZE
    int 0x15
    jc .finish
    cmp eax, E820_SMAP
    jne .finish
    cmp ecx, 20
    jb .finish
    cmp ecx, E820_ENTRY_SIZE
    jb .entry_size_ok
    test dword [es:di + 20], 1
    jz .maybe_continue

.entry_size_ok:

    mov eax, [es:di + 8]
    or eax, [es:di + 12]
    jz .maybe_continue
    inc bp
    add di, E820_ENTRY_SIZE

.maybe_continue:
    test ebx, ebx
    jnz .next_entry

.finish:
    test bp, bp
    jz .done
    mov [BOOT_E820_COUNT], bp
    mov dword [BOOT_E820_MAGIC_ADDR], BOOT_E820_MAGIC
    or dword [BOOT_LOADER_FLAGS_ADDR], BOOT_LOADER_FLAG_E820 | BOOT_LOADER_FLAG_E820_BOUNDED

.done:
    pop es
    pop bp
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

load_kernel_elf_sectors:
    mov word [kernel_load_remaining], KERNEL_SECTORS
    mov word [kernel_load_segment], KERNEL_ELF_SEG
    mov dword [kernel_load_lba], KERNEL_LBA
    mov dword [kernel_load_lba + 4], 0

.next:
    cmp word [kernel_load_remaining], 0
    je .done

    mov ax, [kernel_load_remaining]
    cmp ax, KERNEL_READ_CHUNK_SECTORS
    jbe .count_ready
    mov ax, KERNEL_READ_CHUNK_SECTORS

.count_ready:
    mov [kernel_packet_sectors], ax
    mov word [kernel_packet_offset], KERNEL_ELF_OFF
    mov ax, [kernel_load_segment]
    mov [kernel_packet_segment], ax
    mov eax, [kernel_load_lba]
    mov [kernel_packet_lba], eax
    mov eax, [kernel_load_lba + 4]
    mov [kernel_packet_lba + 4], eax

    call read_kernel_packet

    mov ax, [kernel_packet_sectors]
    sub [kernel_load_remaining], ax
    push ax
    shl ax, 5
    add [kernel_load_segment], ax
    pop ax
    xor ebx, ebx
    mov bx, ax
    add [kernel_load_lba], ebx
    adc dword [kernel_load_lba + 4], 0
    jmp .next

.done:
    ret

read_kernel_packet:
    mov ax, [kernel_packet_sectors]
    mov [kernel_packet_requested_sectors], ax
    cmp byte [disk_use_edd], 1
    jne read_kernel_packet_chs
    mov byte [disk_retries_left], DISK_RETRIES

.try:
    mov ax, [kernel_packet_requested_sectors]
    mov [kernel_packet_sectors], ax
    mov si, kernel_packet
    mov ah, 0x42
    mov dl, [boot_drive]
    int 0x13
    jc .retry_or_fallback
    mov ax, [kernel_packet_sectors]
    cmp ax, [kernel_packet_requested_sectors]
    je .done

.retry_or_fallback:
    xor ah, ah
    mov dl, [boot_drive]
    int 0x13
    dec byte [disk_retries_left]
    jnz .try
    call ensure_chs_geometry
    mov ax, [kernel_packet_requested_sectors]
    mov [kernel_packet_sectors], ax
    jmp read_kernel_packet_chs

.done:
    mov ax, [kernel_packet_requested_sectors]
    mov [kernel_packet_sectors], ax
    or dword [BOOT_LOADER_FLAGS_ADDR], BOOT_LOADER_FLAG_KERNEL_EDD_READ
    ret

read_kernel_packet_chs:
    cmp dword [kernel_packet_lba + 4], 0
    jne disk_error
    cmp word [kernel_packet_offset], 0
    jne disk_error
    mov ax, [kernel_packet_sectors]
    mov [chs_read_remaining], ax
    mov ax, [kernel_packet_segment]
    mov [chs_buffer_segment], ax
    mov ax, [kernel_packet_lba]
    mov [chs_current_lba], ax
    or dword [BOOT_LOADER_FLAGS_ADDR], BOOT_LOADER_FLAG_KERNEL_CHS_READ

.next_sector:
    cmp word [chs_read_remaining], 0
    je .done
    call read_one_sector_chs
    inc word [chs_current_lba]
    add word [chs_buffer_segment], CHS_SECTOR_BYTES_IN_PARAGRAPHS
    dec word [chs_read_remaining]
    jmp .next_sector

.done:
    ret

ensure_chs_geometry:
    cmp byte [chs_geometry_ready], 1
    je .done
    mov ah, 0x08
    mov dl, [boot_drive]
    int 0x13
    jc disk_error
    and cl, 0x3f
    jz disk_error
    xor ax, ax
    mov al, cl
    mov [chs_sectors_per_track], ax
    xor ax, ax
    mov al, dh
    inc ax
    mov [chs_heads], ax
    mov byte [chs_geometry_ready], 1
    or dword [BOOT_LOADER_FLAGS_ADDR], BOOT_LOADER_FLAG_CHS_GEOMETRY

.done:
    ret

read_one_sector_chs:
    mov byte [disk_retries_left], DISK_RETRIES

.try:
    mov ax, [chs_current_lba]
    xor dx, dx
    div word [chs_sectors_per_track]
    mov bl, dl
    inc bl
    xor dx, dx
    div word [chs_heads]
    cmp ax, 1023
    ja disk_error
    mov ch, al
    mov cl, bl
    mov bl, ah
    and bl, 0x03
    shl bl, 6
    or cl, bl
    mov dh, dl
    mov ax, [chs_buffer_segment]
    mov es, ax
    xor bx, bx
    mov ax, 0x0201
    mov dl, [boot_drive]
    int 0x13
    jnc .done

    xor ah, ah
    mov dl, [boot_drive]
    int 0x13
    dec byte [disk_retries_left]
    jnz .try
    jmp disk_error

.done:
    ret

enable_a20:
    call test_a20
    jnc .done
    call enable_a20_fast
    call test_a20
    jnc .done
    call enable_a20_8042
    jc a20_error
    call test_a20
    jc a20_error

.done:
    or dword [BOOT_LOADER_FLAGS_ADDR], BOOT_LOADER_FLAG_A20
    ret

enable_a20_fast:
    in al, 0x92
    or al, 0x02
    and al, 0xfe
    out 0x92, al
    ret

test_a20:
    pushf
    push ax
    push bx
    push ds
    push es
    cli

    xor ax, ax
    mov ds, ax
    mov ax, A20_TEST_HIGH_SEG
    mov es, ax
    mov bl, [A20_TEST_LOW_OFF]
    mov bh, [es:A20_TEST_HIGH_OFF]

    mov byte [A20_TEST_LOW_OFF], 0x00
    mov byte [es:A20_TEST_HIGH_OFF], 0xff
    mov byte [a20_test_result], 0
    cmp byte [A20_TEST_LOW_OFF], 0x00
    jne .restore
    mov byte [a20_test_result], 1

.restore:
    mov [es:A20_TEST_HIGH_OFF], bh
    mov [A20_TEST_LOW_OFF], bl
    pop es
    pop ds
    pop bx
    pop ax
    popf
    cmp byte [a20_test_result], 1
    je .enabled
    stc
    ret

.enabled:
    clc
    ret

enable_a20_8042:
    call a20_wait_input_clear
    jc .fail
    mov al, 0xad
    out 0x64, al

    call a20_wait_input_clear
    jc .fail
    mov al, 0xd0
    out 0x64, al

    call a20_wait_output_full
    jc .fail
    in al, 0x60
    mov [a20_output_port], al

    call a20_wait_input_clear
    jc .fail
    mov al, 0xd1
    out 0x64, al

    call a20_wait_input_clear
    jc .fail
    mov al, [a20_output_port]
    or al, 0x02
    out 0x60, al

    call a20_wait_input_clear
    jc .fail
    mov al, 0xae
    out 0x64, al

    call a20_wait_input_clear
    jc .fail
    clc
    ret

.fail:
    stc
    ret

a20_wait_input_clear:
    push cx
    mov cx, 0xffff

.wait:
    in al, 0x64
    test al, 0x02
    jz .ready
    loop .wait
    stc
    pop cx
    ret

.ready:
    clc
    pop cx
    ret

a20_wait_output_full:
    push cx
    mov cx, 0xffff

.wait:
    in al, 0x64
    test al, 0x01
    jnz .ready
    loop .wait
    stc
    pop cx
    ret

.ready:
    clc
    pop cx
    ret

set_vbe_lfb_or_mode13:
    call try_set_vbe_lfb
    jnc .done
    call set_video_mode13

.done:
    ret

try_set_vbe_lfb:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push bp
    push es
    push fs

    mov dword [VBE_INFO_ADDR], 0x32454256
    mov ax, 0x4f00
    xor bx, bx
    mov es, bx
    mov di, VBE_INFO_ADDR
    int 0x10
    cmp ax, 0x004f
    jne .fail
    cmp dword [VBE_INFO_ADDR], 0x41534556
    jne .fail
    cmp word [VBE_INFO_ADDR + 4], 0x0200
    jb .fail

    mov si, [VBE_INFO_ADDR + 0x0e]
    mov ax, [VBE_INFO_ADDR + 0x10]
    test ax, ax
    jz .fail
    mov fs, ax
    mov bp, VBE_MAX_MODES

.mode_loop:
    cmp bp, 0
    je .fail
    dec bp
    mov cx, [fs:si]
    add si, 2
    cmp cx, 0xffff
    je .fail
    mov [vbe_candidate_mode], cx

    push esi
    push fs
    mov ax, 0x4f01
    xor bx, bx
    mov es, bx
    mov di, VBE_MODE_INFO_ADDR
    int 0x10
    pop fs
    pop esi
    cmp ax, 0x004f
    jne .mode_loop

    call validate_vbe_mode_info
    jc .mode_loop

    push esi
    push fs
    mov ax, 0x4f02
    mov bx, [vbe_candidate_mode]
    or bx, 0x4000
    int 0x10
    pop fs
    pop esi
    cmp ax, 0x004f
    jne .mode_loop

    push esi
    push fs
    mov ax, 0x4f01
    mov cx, [vbe_candidate_mode]
    xor bx, bx
    mov es, bx
    mov di, VBE_MODE_INFO_ADDR
    int 0x10
    pop fs
    pop esi
    cmp ax, 0x004f
    jne .mode_loop
    call validate_vbe_mode_info
    jc .mode_loop

    call store_vbe_video_info
    clc
    jmp .done

.fail:
    stc

.done:
    pop fs
    pop es
    pop bp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

validate_vbe_mode_info:
    mov ax, [VBE_MODE_INFO_ADDR]
    and ax, 0x0091
    cmp ax, 0x0091
    jne .fail
    cmp word [VBE_MODE_INFO_ADDR + 18], 640
    jne .fail
    cmp word [VBE_MODE_INFO_ADDR + 20], 400
    jb .fail
    cmp byte [VBE_MODE_INFO_ADDR + 25], 32
    jne .fail
    cmp byte [VBE_MODE_INFO_ADDR + 27], 6
    jne .fail
    cmp dword [VBE_MODE_INFO_ADDR + 40], 0
    je .fail
    cmp byte [VBE_MODE_INFO_ADDR + 31], 8
    jb .fail
    cmp byte [VBE_MODE_INFO_ADDR + 32], 16
    jne .fail
    cmp byte [VBE_MODE_INFO_ADDR + 33], 8
    jb .fail
    cmp byte [VBE_MODE_INFO_ADDR + 34], 8
    jne .fail
    cmp byte [VBE_MODE_INFO_ADDR + 35], 8
    jb .fail
    cmp byte [VBE_MODE_INFO_ADDR + 36], 0
    jne .fail
    mov eax, [VBE_MODE_INFO_ADDR + 40]
    xor ebx, ebx
    mov bx, [VBE_MODE_INFO_ADDR + 16]
    add eax, ebx
    jc .fail
    clc
    ret

.fail:
    stc
    ret

store_vbe_video_info:
    mov dword [BOOT_INFO_ADDR + 8], BOOT_VIDEO_MAGIC
    or dword [BOOT_LOADER_FLAGS_ADDR], BOOT_LOADER_FLAG_VBE_LFB | BOOT_LOADER_FLAG_VIDEO_VALID
    mov ax, [vbe_candidate_mode]
    mov [BOOT_VIDEO_MODE], ax
    mov word [BOOT_VIDEO_FLAGS], BOOT_VIDEO_FLAG_VBE | BOOT_VIDEO_FLAG_LFB | BOOT_VIDEO_FLAG_XRGB8888
    mov eax, [VBE_MODE_INFO_ADDR + 40]
    mov [BOOT_VIDEO_FB_ADDR], eax
    xor eax, eax
    mov ax, [VBE_MODE_INFO_ADDR + 16]
    mov [BOOT_VIDEO_PITCH], eax
    mov ax, [VBE_MODE_INFO_ADDR + 18]
    mov [BOOT_VIDEO_WIDTH], ax
    mov ax, [VBE_MODE_INFO_ADDR + 20]
    mov [BOOT_VIDEO_HEIGHT], ax
    mov al, [VBE_MODE_INFO_ADDR + 25]
    mov [BOOT_VIDEO_BPP], al
    mov al, [VBE_MODE_INFO_ADDR + 27]
    mov [BOOT_VIDEO_MEMORY_MODEL], al
    mov al, [VBE_MODE_INFO_ADDR + 31]
    mov [BOOT_VIDEO_RED_MASK], al
    mov al, [VBE_MODE_INFO_ADDR + 32]
    mov [BOOT_VIDEO_RED_POS], al
    mov al, [VBE_MODE_INFO_ADDR + 33]
    mov [BOOT_VIDEO_GREEN_MASK], al
    mov al, [VBE_MODE_INFO_ADDR + 34]
    mov [BOOT_VIDEO_GREEN_POS], al
    mov al, [VBE_MODE_INFO_ADDR + 35]
    mov [BOOT_VIDEO_BLUE_MASK], al
    mov al, [VBE_MODE_INFO_ADDR + 36]
    mov [BOOT_VIDEO_BLUE_POS], al
    ret

set_video_mode13:
    mov ax, 0x0013
    int 0x10
    mov ah, 0x0f
    int 0x10
    cmp al, 0x13
    jne video_error
    mov dword [BOOT_INFO_ADDR + 8], BOOT_VIDEO_MAGIC
    or dword [BOOT_LOADER_FLAGS_ADDR], BOOT_LOADER_FLAG_MODE13 | BOOT_LOADER_FLAG_VIDEO_VALID
    mov word [BOOT_VIDEO_MODE], 0x0013
    mov word [BOOT_VIDEO_FLAGS], 0
    mov dword [BOOT_VIDEO_FB_ADDR], 0x000a0000
    mov dword [BOOT_VIDEO_PITCH], 320
    mov word [BOOT_VIDEO_WIDTH], 320
    mov word [BOOT_VIDEO_HEIGHT], 200
    mov byte [BOOT_VIDEO_BPP], 8
    mov byte [BOOT_VIDEO_MEMORY_MODEL], 4
    mov byte [BOOT_VIDEO_RED_MASK], 0
    mov byte [BOOT_VIDEO_RED_POS], 0
    mov byte [BOOT_VIDEO_GREEN_MASK], 0
    mov byte [BOOT_VIDEO_GREEN_POS], 0
    mov byte [BOOT_VIDEO_BLUE_MASK], 0
    mov byte [BOOT_VIDEO_BLUE_POS], 0
    ret

validate_boot_info_handoff:
    cmp dword [BOOT_LOADER_MAGIC_ADDR], BOOT_LOADER_MAGIC
    jne boot_info_error
    cmp word [BOOT_LOADER_VERSION_ADDR], BOOT_LOADER_VERSION
    jne boot_info_error
    cmp word [BOOT_LOADER_STATUS_ADDR], BOOT_LOADER_STATUS_STARTED
    jne boot_info_error
    cmp word [BOOT_LOADER_STAGE2_SECTORS_ADDR], STAGE2_SECTORS
    jne boot_info_error
    cmp word [BOOT_LOADER_KERNEL_SECTORS_ADDR], KERNEL_SECTORS
    jne boot_info_error
    mov eax, [BOOT_LOADER_FLAGS_ADDR]
    test eax, BOOT_LOADER_FLAG_STAGE2_REACHED
    jz boot_info_error
    test eax, BOOT_LOADER_FLAG_KERNEL_EDD_READ | BOOT_LOADER_FLAG_KERNEL_CHS_READ
    jz boot_info_error
    test eax, BOOT_LOADER_FLAG_KERNEL_CHS_READ
    jz .chs_ok
    test eax, BOOT_LOADER_FLAG_CHS_GEOMETRY
    jz boot_info_error

.chs_ok:
    test eax, BOOT_LOADER_FLAG_VIDEO_VALID
    jz boot_info_error
    cmp dword [BOOT_INFO_ADDR + 8], BOOT_VIDEO_MAGIC
    jne boot_info_error
    cmp dword [BOOT_VIDEO_FB_ADDR], 0
    je boot_info_error
    cmp dword [BOOT_VIDEO_PITCH], 0
    je boot_info_error
    cmp word [BOOT_VIDEO_WIDTH], 0
    je boot_info_error
    cmp word [BOOT_VIDEO_HEIGHT], 0
    je boot_info_error
    mov eax, [BOOT_VIDEO_PITCH]
    movzx ecx, word [BOOT_VIDEO_HEIGHT]
    mul ecx
    test edx, edx
    jnz boot_info_error
    test eax, eax
    jz boot_info_error
    add eax, [BOOT_VIDEO_FB_ADDR]
    jc boot_info_error
    cmp dword [BOOT_E820_MAGIC_ADDR], BOOT_E820_MAGIC
    jne boot_info_error
    cmp word [BOOT_E820_COUNT], 0
    je boot_info_error
    cmp word [BOOT_E820_COUNT], E820_MAX_ENTRIES
    ja boot_info_error
    cmp word [BOOT_E820_ENTRY_SIZE_ADDR], E820_ENTRY_SIZE
    jne boot_info_error
    cmp dword [BOOT_E820_MAP_ADDR_PTR], E820_MAP_ADDR
    jne boot_info_error

.done:
    ret

a20_error:
    mov si, a20_error_message
    call print_string
    jmp fatal_hang

video_error:
    mov si, video_error_message
    call print_string
    jmp fatal_hang

boot_info_error:
    mov si, boot_info_error_message
    call print_string
    jmp fatal_hang

disk_error:
    mov si, disk_error_message
    call print_string

fatal_hang:
    hlt
    jmp fatal_hang

print_string:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0e
    mov bh, 0x00
    mov bl, 0x07
    int 0x10
    jmp print_string

.done:
    ret

bits 32
protected_entry:
    cli
    or dword [BOOT_LOADER_FLAGS_ADDR], BOOT_LOADER_FLAG_PROTECTED_MODE
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x70000
    call elf_load_kernel
    call validate_protected_kernel_handoff
    mov word [BOOT_LOADER_STATUS_ADDR], BOOT_LOADER_STATUS_OK
    jmp eax

validate_protected_kernel_handoff:
    push eax
    push ebx
    push edx

    cmp dword [BOOT_LOADER_MAGIC_ADDR], BOOT_LOADER_MAGIC
    jne protected_boot_info_error
    cmp word [BOOT_LOADER_VERSION_ADDR], BOOT_LOADER_VERSION
    jne protected_boot_info_error
    cmp word [BOOT_LOADER_STATUS_ADDR], BOOT_LOADER_STATUS_STARTED
    jne protected_boot_info_error
    cmp word [BOOT_LOADER_STAGE2_SECTORS_ADDR], STAGE2_SECTORS
    jne protected_boot_info_error
    cmp word [BOOT_LOADER_KERNEL_SECTORS_ADDR], KERNEL_SECTORS
    jne protected_boot_info_error

    mov eax, [BOOT_LOADER_FLAGS_ADDR]
    mov ebx, BOOT_LOADER_REQUIRED_PROTECTED_FLAGS
    mov edx, eax
    and edx, ebx
    cmp edx, ebx
    jne protected_boot_info_error

    test eax, BOOT_LOADER_FLAG_KERNEL_EDD_READ | BOOT_LOADER_FLAG_KERNEL_CHS_READ
    jz protected_boot_info_error
    test eax, BOOT_LOADER_FLAG_KERNEL_EDD_READ
    jz .edd_ok
    test eax, BOOT_LOADER_FLAG_EDD_PRESENT
    jz protected_boot_info_error

.edd_ok:
    test eax, BOOT_LOADER_FLAG_KERNEL_CHS_READ
    jz .chs_ok
    test eax, BOOT_LOADER_FLAG_CHS_GEOMETRY
    jz protected_boot_info_error

.chs_ok:
    mov edx, eax
    and edx, BOOT_LOADER_FLAG_VBE_LFB | BOOT_LOADER_FLAG_MODE13
    cmp edx, BOOT_LOADER_FLAG_VBE_LFB
    je .video_ok
    cmp edx, BOOT_LOADER_FLAG_MODE13
    jne protected_boot_info_error

.video_ok:
    cmp dword [BOOT_LOADER_KERNEL_ENTRY_ADDR], KERNEL_PHYS
    jne protected_boot_info_error
    cmp dword [BOOT_LOADER_ELF_LOADS_ADDR], 0
    je protected_boot_info_error

    pop edx
    pop ebx
    pop eax
    ret

elf_load_kernel:
    mov esi, KERNEL_ELF_PHYS
    cmp dword [esi], ELF_MAGIC
    jne elf_fail
    cmp byte [esi + 4], ELFCLASS32
    jne elf_fail
    cmp byte [esi + 5], ELFDATA2LSB
    jne elf_fail
    cmp byte [esi + 6], ELF_VERSION_CURRENT
    jne elf_fail
    cmp word [esi + 16], ET_EXEC
    jne elf_fail
    cmp word [esi + 18], EM_386
    jne elf_fail
    cmp dword [esi + 20], ELF_VERSION_CURRENT
    jne elf_fail
    cmp word [esi + 40], ELF_HEADER_SIZE
    jne elf_fail
    cmp word [esi + 42], 32
    jne elf_fail
    movzx ecx, word [esi + 44]
    test ecx, ecx
    jz elf_fail
    cmp ecx, ELF_MAX_PHDRS
    ja elf_fail
    mov eax, [esi + 28]
    cmp eax, ELF_HEADER_SIZE
    jb elf_fail
    cmp eax, KERNEL_ELF_MAX_BYTES
    jae elf_fail
    mov edx, ecx
    shl edx, 5
    add edx, eax
    jc elf_fail
    cmp edx, KERNEL_ELF_MAX_BYTES
    ja elf_fail
    mov ebx, esi
    add ebx, eax
    xor ebp, ebp
    mov byte [elf_entry_covered], 0

.program_header:
    cmp dword [ebx], PT_LOAD
    jne .next_header

    cmp dword [ebx + 28], 0x1000
    jne elf_fail
    mov edi, [ebx + 12]
    cmp edi, [ebx + 8]
    jne elf_fail
    test edi, edi
    jz elf_fail
    cmp edi, KERNEL_PHYS
    jb elf_fail
    mov edx, [ebx + 16]
    mov eax, [ebx + 20]
    cmp eax, edx
    jb elf_fail
    test eax, eax
    jz elf_fail
    mov esi, edi
    add esi, eax
    jc elf_fail
    cmp esi, KERNEL_LOAD_LIMIT
    ja elf_fail
    mov eax, [ebx + 4]
    cmp eax, KERNEL_ELF_MAX_BYTES
    jae elf_fail
    mov esi, eax
    add esi, edx
    jc elf_fail
    cmp esi, KERNEL_ELF_MAX_BYTES
    ja elf_fail

    mov eax, [KERNEL_ELF_PHYS + 24]
    cmp eax, edi
    jb .copy_segment
    mov esi, edi
    add esi, [ebx + 20]
    jc elf_fail
    cmp eax, esi
    jae .copy_segment
    mov byte [elf_entry_covered], 1

.copy_segment:
    push ecx
    push ebx
    push edx
    mov esi, KERNEL_ELF_PHYS
    add esi, [ebx + 4]
    mov ecx, edx
    cld
    rep movsb
    pop edx
    mov ecx, [ebx + 20]
    sub ecx, edx
    xor eax, eax
    rep stosb
    pop ebx
    pop ecx
    inc ebp

.next_header:
    add ebx, ELF_PHDR_SIZE
    dec ecx
    jnz .program_header

    test ebp, ebp
    jz elf_fail
    cmp byte [elf_entry_covered], 1
    jne elf_fail
    mov eax, [KERNEL_ELF_PHYS + 24]
    test eax, eax
    jz elf_fail
    mov [BOOT_LOADER_ELF_LOADS_ADDR], ebp
    mov [BOOT_LOADER_KERNEL_ENTRY_ADDR], eax
    or dword [BOOT_LOADER_FLAGS_ADDR], BOOT_LOADER_FLAG_ELF_VALID | BOOT_LOADER_FLAG_ENTRY_COVERED | BOOT_LOADER_FLAG_ELF_PHDR_VALID
    ret

elf_fail:
    mov esi, elf_error_message
    call pm_print_string

.hang:
    hlt
    jmp .hang

protected_boot_info_error:
    mov esi, pm_boot_info_error_message
    call pm_print_string

.hang:
    hlt
    jmp .hang

pm_print_string:
    mov edi, 0x000b8000 + (4 * 80 * 2)

.next_char:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0c
    mov [edi], ax
    add edi, 2
    jmp .next_char

.done:
    ret

bits 16
align 4
kernel_packet:
    db 0x10
    db 0x00
kernel_packet_sectors:
    dw 0
kernel_packet_offset:
    dw KERNEL_ELF_OFF
kernel_packet_segment:
    dw KERNEL_ELF_SEG
kernel_packet_lba:
    dq 0
kernel_packet_requested_sectors dw 0
kernel_load_remaining dw 0
kernel_load_segment dw 0
align 4
kernel_load_lba dq 0

gdt_start:
gdt_null:
    dq 0

gdt_code:
    dw 0xffff
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00

gdt_data:
    dw 0xffff
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

boot_drive db 0
disk_use_edd db 0
disk_retries_left db 0
chs_geometry_ready db 0
a20_test_result db 0
a20_output_port db 0
elf_entry_covered db 0
vbe_candidate_mode dw 0
chs_sectors_per_track dw 0
chs_heads dw 0
chs_current_lba dw 0
chs_buffer_segment dw 0
chs_read_remaining dw 0
stage2_message db "Aurora stage 2: loading protected kernel...", 13, 10, 0
a20_error_message db "Aurora stage 2: A20 enable failed.", 13, 10, 0
video_error_message db "Aurora stage 2: video mode setup failed.", 13, 10, 0
boot_info_error_message db "Aurora stage 2: boot info validation failed.", 13, 10, 0
disk_error_message db "Aurora stage 2: disk read failed.", 13, 10, 0
elf_error_message db "Aurora stage 2: ELF load failed.", 0
pm_boot_info_error_message db "Aurora stage 2: protected handoff validation failed.", 0
