// Raspberry Pi 4 storage parser/status helpers for vibe-os.
//
// Parser helpers consume caller-provided 512-byte sectors. The boot-media probe
// publishes FAT/VFS gates only after bounded SDHCI reads copied real media bytes.

.arch armv8-a

.equ VIBE_PI4_STORAGE_MAGIC,            0x50345354
.equ VIBE_PI4_STORAGE_VERSION,          1
.equ VIBE_PI4_STORAGE_WAIT,             0x57414954
.equ VIBE_PI4_STORAGE_SD_OK,            0x53444f4b
.equ VIBE_PI4_STORAGE_MBR_OK,           0x4d424f4b
.equ VIBE_PI4_STORAGE_MBR_BAD,          0x4d424144
.equ VIBE_PI4_STORAGE_BPB_OK,           0x42504f4b
.equ VIBE_PI4_STORAGE_BPB_BAD,          0x42424144
.equ VIBE_PI4_STORAGE_FAT12,            0x46413132
.equ VIBE_PI4_STORAGE_FAT16,            0x46413136
.equ VIBE_PI4_STORAGE_FAT32,            0x46413332
.equ VIBE_PI4_STORAGE_ROOT_OK,          0x524f4f4b
.equ VIBE_PI4_STORAGE_ROOT_BAD,         0x52424144
.equ VIBE_PI4_STORAGE_FILE_OK,          0x464f4f4b
.equ VIBE_PI4_STORAGE_FILE_MISSING,     0x464d4953
.equ VIBE_PI4_STORAGE_SDCTL_EMMC2,      0x454d4332
.equ VIBE_PI4_STORAGE_SDCTL_EMMC,       0x454d4d43
.equ VIBE_PI4_STORAGE_ENOSYS,           0x454e4f53
.equ VIBE_PI4_STORAGE_EINVAL,           0x45494e56
.equ VIBE_PI4_STORAGE_EIO,              0x45494f20

.equ PI4_STORAGE_BLOCK_SECTOR_BYTES,    512
.equ PI4_STORAGE_BLOCK_MAX_COUNT,       1024
.equ PI4_STORAGE_ROOT_BUFFER_SECTORS,   128
.equ PI4_STORAGE_ROOT_BUFFER_BYTES,     PI4_STORAGE_BLOCK_SECTOR_BYTES * PI4_STORAGE_ROOT_BUFFER_SECTORS
.equ PI4_STORAGE_ERRNO_WAIT,            11
.equ PI4_STORAGE_ERRNO_EIO,             5
.equ PI4_STORAGE_ERRNO_EINVAL,          22
.equ PI4_STORAGE_ERRNO_ENOSYS,          38

.equ PI4_STORAGE_BOOT_SIG_LE,           0xaa55
.equ PI4_STORAGE_MBR_PART0_OFF,         446
.equ PI4_STORAGE_MBR_PART_SIZE,         16
.equ PI4_STORAGE_MBR_PART_COUNT,        4
.equ PI4_STORAGE_MBR_PART_BOOT_OFF,     0
.equ PI4_STORAGE_MBR_PART_TYPE_OFF,     4
.equ PI4_STORAGE_MBR_PART_LBA_OFF,      8
.equ PI4_STORAGE_MBR_PART_SECTORS_OFF,  12
.equ PI4_STORAGE_MBR_PART_BOOT_ACTIVE,  0x80
.equ PI4_STORAGE_MBR_PART_TYPE_FAT16,   0x06
.equ PI4_STORAGE_MBR_PART_TYPE_FAT32,   0x0b
.equ PI4_STORAGE_MBR_PART_TYPE_FAT32_LBA, 0x0c

.equ PI4_STORAGE_BPB_BYTES_PER_SECTOR,  11
.equ PI4_STORAGE_BPB_SECTORS_PER_CLUS,  13
.equ PI4_STORAGE_BPB_RESERVED_SECTORS,  14
.equ PI4_STORAGE_BPB_FAT_COUNT,         16
.equ PI4_STORAGE_BPB_ROOT_ENTRIES,      17
.equ PI4_STORAGE_BPB_TOTAL_SECTORS_16,  19
.equ PI4_STORAGE_BPB_FAT_SECTORS_16,    22
.equ PI4_STORAGE_BPB_HIDDEN_SECTORS,    28
.equ PI4_STORAGE_BPB_TOTAL_SECTORS_32,  32
.equ PI4_STORAGE_BPB_FAT_SECTORS_32,    36
.equ PI4_STORAGE_BPB_ROOT_CLUSTER_32,   44
.equ PI4_STORAGE_BOOT_SIG_OFF,          510

.equ PI4_STORAGE_FAT12_CLUSTER_LIMIT,   4085
.equ PI4_STORAGE_FAT16_CLUSTER_LIMIT,   65525
.equ PI4_STORAGE_FAT_MAX_SPC,           128

.equ PI4_STORAGE_DIRENT_BYTES,          32
.equ PI4_STORAGE_DIRENT_ATTR_OFF,       11
.equ PI4_STORAGE_DIRENT_CLUSTER_HI_OFF, 20
.equ PI4_STORAGE_DIRENT_CLUSTER_LO_OFF, 26
.equ PI4_STORAGE_DIRENT_SIZE_OFF,       28
.equ PI4_STORAGE_DIRENT_DELETED,        0xe5
.equ PI4_STORAGE_DIRENT_ATTR_LONG,      0x0f
.equ PI4_STORAGE_DIRENT_ATTR_VOLUME,    0x08
.equ PI4_STORAGE_DIRENT_ATTR_DIRECTORY, 0x10
.equ PI4_STORAGE_READABLE_FILE_MIN_BYTES, 12
.equ PI4_STORAGE_APP_RECORD_KIND_BASE,  7
.equ PI4_STORAGE_APP_RECORD_COUNT,      2
.equ PI4_STORAGE_APP_RECORD_BYTES,      40
.equ PI4_STORAGE_APP_RECORD_DIR_STATUS_OFF, 0
.equ PI4_STORAGE_APP_RECORD_NAME_OFF,   8
.equ PI4_STORAGE_APP_RECORD_ELF_STATUS_OFF, 16
.equ PI4_STORAGE_APP_RECORD_ELF_ENTRY_OFF, 24
.equ PI4_STORAGE_APP_RECORD_MANIFEST_OFF, 32

.macro PI4_STORAGE_LOAD_LE16 dst, base, off, tmp
    ldrb \dst, [\base, #\off]
    ldrb \tmp, [\base, #(\off + 1)]
    orr \dst, \dst, \tmp, lsl #8
.endm

.macro PI4_STORAGE_LOAD_LE32 dst, base, off, tmp
    ldrb \dst, [\base, #\off]
    ldrb \tmp, [\base, #(\off + 1)]
    orr \dst, \dst, \tmp, lsl #8
    ldrb \tmp, [\base, #(\off + 2)]
    orr \dst, \dst, \tmp, lsl #16
    ldrb \tmp, [\base, #(\off + 3)]
    orr \dst, \dst, \tmp, lsl #24
.endm

.equ PI4_EMMC2_LEGACY_BASE,             0x7e340000
.equ PI4_EMMC2_ARM_BASE,                0xfe340000
.equ PI4_EMMC2_PERIPH_OFFSET,           0x00340000
.equ PI4_EMMC2_PERIPH_END_OFFSET,       0x00340100
.equ PI4_EMMC2_REG_SIZE,                0x100
.equ PI4_EMMC_LEGACY_BASE,              0x7e300000
.equ PI4_EMMC_ARM_BASE,                 0xfe300000
.equ PI4_EMMC_PERIPH_OFFSET,            0x00300000
.equ PI4_EMMC_PERIPH_END_OFFSET,        0x00300100
.equ PI4_EMMC_REG_SIZE,                 0x100

.equ PI4_SDHCI_DMA_ADDRESS,             0x00
.equ PI4_SDHCI_BLOCK_SIZE,              0x04
.equ PI4_SDHCI_BLOCK_COUNT,             0x06
.equ PI4_SDHCI_ARGUMENT,                0x08
.equ PI4_SDHCI_TRANSFER_MODE,           0x0c
.equ PI4_SDHCI_COMMAND,                 0x0e
.equ PI4_SDHCI_RESPONSE,                0x10
.equ PI4_SDHCI_BUFFER,                  0x20
.equ PI4_SDHCI_PRESENT_STATE,           0x24
.equ PI4_SDHCI_HOST_CONTROL,            0x28
.equ PI4_SDHCI_POWER_CONTROL,           0x29
.equ PI4_SDHCI_BLOCK_GAP_CONTROL,       0x2a
.equ PI4_SDHCI_WAKE_UP_CONTROL,         0x2b
.equ PI4_SDHCI_CLOCK_CONTROL,           0x2c
.equ PI4_SDHCI_TIMEOUT_CONTROL,         0x2e
.equ PI4_SDHCI_SOFTWARE_RESET,          0x2f
.equ PI4_SDHCI_INT_STATUS,              0x30
.equ PI4_SDHCI_INT_ENABLE,              0x34
.equ PI4_SDHCI_SIGNAL_ENABLE,           0x38
.equ PI4_SDHCI_AUTO_CMD12_ERR,          0x3c
.equ PI4_SDHCI_HOST_CONTROL2,           0x3e
.equ PI4_SDHCI_CAPABILITIES,            0x40
.equ PI4_SDHCI_CAPABILITIES_1,          0x44
.equ PI4_SDHCI_MAX_CURRENT,             0x48
.equ PI4_SDHCI_ADMA_ERROR,              0x54
.equ PI4_SDHCI_ADMA_ADDRESS,            0x58
.equ PI4_SDHCI_SLOT_INT_STATUS,         0xfc
.equ PI4_SDHCI_HOST_VERSION,            0xfe

.equ PI4_SDHCI_PRESENT_INHIBIT_MASK,    0x00000003
.equ PI4_SDHCI_INT_CMD_COMPLETE,        0x00000001
.equ PI4_SDHCI_INT_TRANSFER_COMPLETE,   0x00000002
.equ PI4_SDHCI_INT_BUFFER_READ_READY,   0x00000020
.equ PI4_SDHCI_INT_ERROR,               0x00008000
.equ PI4_SDHCI_INT_PIO_ENABLE_MASK,     0xffff8023
.equ PI4_SDHCI_RESET_ALL,               0x01
.equ PI4_SDHCI_POWER_3V3_ON,            0x0f
.equ PI4_SDHCI_CLOCK_INT_ENABLE,        0x0001
.equ PI4_SDHCI_CLOCK_INT_STABLE,        0x0002
.equ PI4_SDHCI_CLOCK_SD_ENABLE,         0x0004
.equ PI4_SDHCI_TIMEOUT_MAX,             0x0e
.equ PI4_SDHCI_TRANSFER_NONE,           0x00000000
.equ PI4_SDHCI_CMD0_GO_IDLE,            0x00000000
.equ PI4_SDHCI_CMD2_ALL_SEND_CID,       0x00000209
.equ PI4_SDHCI_CMD3_SEND_REL_ADDR,      0x0000031a
.equ PI4_SDHCI_CMD7_SELECT_CARD,        0x0000071b
.equ PI4_SDHCI_CMD8_SEND_IF_COND,       0x0000081a
.equ PI4_SDHCI_CMD16_SET_BLOCKLEN,      0x0000101a
.equ PI4_SDHCI_CMD17_READ_SINGLE,       0x0000113a
.equ PI4_SDHCI_CMD18_READ_MULTI,        0x0000123a
.equ PI4_SDHCI_CMD55_APP_CMD,           0x0000371a
.equ PI4_SDHCI_ACMD41_SD_SEND_OP_COND,  0x00002902
.equ PI4_SDHCI_TRANSFER_READ_SINGLE,    0x00000012
.equ PI4_SDHCI_TRANSFER_READ_MULTI,     0x00000036
.equ PI4_SDHCI_PIO_WORDS_PER_SECTOR,    128
.equ PI4_SDHCI_POLL_LIMIT,              0x10000
.equ PI4_SDHCI_ACMD41_POLL_LIMIT,       128
.equ PI4_SDHCI_CMD8_IF_COND_ARG,        0x000001aa
.equ PI4_SDHCI_CMD16_BLOCKLEN_ARG,      512
.equ PI4_SDHCI_ACMD41_ARG,              0x40ff8000
.equ PI4_SDHCI_ACMD41_ARG_LEGACY,       0x00ff8000
.equ PI4_SDHCI_OCR_POWER_UP,            0x80000000
.equ PI4_SDHCI_OCR_CARD_CAPACITY,       0x40000000

.section .text.pi4_storage, "ax", %progbits
.balign 16

.global pi4_storage_reset_status
.type pi4_storage_reset_status, %function
pi4_storage_reset_status:
    adr x0, pi4_storage_status_pi4sd
    ldr w1, =VIBE_PI4_STORAGE_WAIT
    str w1, [x0]
    adr x0, pi4_storage_status_pi4fat
    str w1, [x0]
    adr x0, pi4_storage_status_pi4vfs
    str w1, [x0]
    adr x0, pi4_storage_status_mbr
    str w1, [x0]
    adr x0, pi4_storage_status_bpb
    str w1, [x0]
    adr x0, pi4_storage_status_fat_type
    str w1, [x0]
    adr x0, pi4_storage_status_root
    str w1, [x0]
    adr x0, pi4_storage_status_init_elf
    str w1, [x0]
    adr x0, pi4_storage_status_app0_elf
    str w1, [x0]
    adr x0, pi4_storage_status_app1_elf
    str w1, [x0]
    adr x0, pi4_storage_status_block
    str w1, [x0]
    adr x0, pi4_storage_status_block_controller
    ldr w1, =VIBE_PI4_STORAGE_ENOSYS
    str w1, [x0]

    adr x0, pi4_storage_status_values_start
    adr x1, pi4_storage_status_values_end
.Lpi4_storage_reset_values:
    cmp x0, x1
    b.hs .Lpi4_storage_reset_done
    str xzr, [x0], #8
    b .Lpi4_storage_reset_values
.Lpi4_storage_reset_done:
    ret
.size pi4_storage_reset_status, . - pi4_storage_reset_status

// x0 = starting LBA, x1 = sector count, x2 = destination buffer.
// Returns x0 = -errno unless the bounded SDHCI PIO path copies the full request.
.global pi4_storage_read_blocks
.global pi4_storage_block_read
.type pi4_storage_read_blocks, %function
.type pi4_storage_block_read, %function
pi4_storage_read_blocks:
pi4_storage_block_read:
    mov x8, x0
    mov x9, x1
    mov x10, x2

    adr x3, pi4_storage_block_pio_values_start
    adr x4, pi4_storage_block_pio_values_end
.Lpi4_storage_block_clear_pio_values:
    cmp x3, x4
    b.hs .Lpi4_storage_block_clear_pio_done
    str xzr, [x3], #8
    b .Lpi4_storage_block_clear_pio_values
.Lpi4_storage_block_clear_pio_done:
    adr x3, pi4_storage_status_block_lba
    str x8, [x3]
    adr x3, pi4_storage_status_block_count
    str x9, [x3]
    adr x3, pi4_storage_status_block_buffer
    str x10, [x3]
    mov x5, #PI4_STORAGE_BLOCK_MAX_COUNT
    adr x3, pi4_storage_status_block_max_count
    str x5, [x3]
    adr x3, pi4_storage_status_block_bytes
    str xzr, [x3]

    cbz x9, .Lpi4_storage_block_einval
    cbz x10, .Lpi4_storage_block_einval
    cmp x9, x5
    b.hi .Lpi4_storage_block_einval
    lsr x3, x8, #32
    cbnz x3, .Lpi4_storage_block_einval

    mov x6, #PI4_STORAGE_BLOCK_SECTOR_BYTES
    mul x11, x9, x6
    adr x3, pi4_storage_status_block_bytes
    str x11, [x3]

    adr x3, pi4_storage_status_block_controller
    ldr w4, [x3]
    ldr w5, =VIBE_PI4_STORAGE_WAIT
    cmp w4, w5
    b.eq .Lpi4_storage_block_wait
    ldr w5, =VIBE_PI4_STORAGE_SDCTL_EMMC2
    cmp w4, w5
    b.eq .Lpi4_storage_block_sdhci_pio
    ldr w5, =VIBE_PI4_STORAGE_SDCTL_EMMC
    cmp w4, w5
    b.eq .Lpi4_storage_block_sdhci_pio

    ldr w4, =VIBE_PI4_STORAGE_ENOSYS
    mov x5, #-PI4_STORAGE_ERRNO_ENOSYS
    b .Lpi4_storage_block_finish

.Lpi4_storage_block_sdhci_pio:
    adr x3, pi4_storage_status_sdctl_arm_base
    ldr x12, [x3]
    cbz x12, .Lpi4_storage_block_enosys
    adr x3, pi4_storage_status_sdctl_card_ready
    ldr x4, [x3]
    cmp x4, #1
    b.ne .Lpi4_storage_block_enosys

    ldr w13, [x12, #PI4_SDHCI_PRESENT_STATE]
    adr x3, pi4_storage_status_block_present_before
    str x13, [x3]

    mov x14, #PI4_SDHCI_POLL_LIMIT
.Lpi4_storage_block_wait_inhibit:
    ldr w13, [x12, #PI4_SDHCI_PRESENT_STATE]
    adr x3, pi4_storage_status_block_present_after
    str x13, [x3]
    and w15, w13, #PI4_SDHCI_PRESENT_INHIBIT_MASK
    cbz w15, .Lpi4_storage_block_issue_command
    subs x14, x14, #1
    b.ne .Lpi4_storage_block_wait_inhibit
    b .Lpi4_storage_block_sdhci_wait

.Lpi4_storage_block_issue_command:
    mov x6, xzr
    mov x7, xzr
    mov w13, #PI4_SDHCI_CMD17_READ_SINGLE
    mov w14, #PI4_SDHCI_TRANSFER_READ_SINGLE
    adr x3, pi4_storage_status_block_command
    str x13, [x3]
    adr x3, pi4_storage_status_block_transfer_mode
    str x14, [x3]

.Lpi4_storage_block_issue_single_sector:
    mov w13, #PI4_SDHCI_CMD17_READ_SINGLE
    mov w14, #PI4_SDHCI_TRANSFER_READ_SINGLE
    add x16, x8, x7
    adr x3, pi4_storage_status_sdctl_block_addressing
    ldr x4, [x3]
    cbnz x4, .Lpi4_storage_block_have_sd_argument
    lsl x16, x16, #9
    lsr x3, x16, #32
    cbnz x3, .Lpi4_storage_block_einval
.Lpi4_storage_block_have_sd_argument:
    cbnz x7, .Lpi4_storage_block_sd_argument_recorded
    adr x3, pi4_storage_status_block_argument
    str x16, [x3]
.Lpi4_storage_block_sd_argument_recorded:

    mov w15, #-1
    str w15, [x12, #PI4_SDHCI_INT_STATUS]
    mov w15, #PI4_STORAGE_BLOCK_SECTOR_BYTES
    strh w15, [x12, #PI4_SDHCI_BLOCK_SIZE]
    mov w15, #1
    strh w15, [x12, #PI4_SDHCI_BLOCK_COUNT]
    str w16, [x12, #PI4_SDHCI_ARGUMENT]
    strh w14, [x12, #PI4_SDHCI_TRANSFER_MODE]
    strh w13, [x12, #PI4_SDHCI_COMMAND]
    dsb sy

    mov x14, #PI4_SDHCI_POLL_LIMIT
.Lpi4_storage_block_wait_cmd_done:
    ldr w13, [x12, #PI4_SDHCI_INT_STATUS]
    adr x3, pi4_storage_status_block_int_status
    str x13, [x3]
    tst w13, #PI4_SDHCI_INT_ERROR
    b.ne .Lpi4_storage_block_sdhci_error
    tst w13, #PI4_SDHCI_INT_CMD_COMPLETE
    b.ne .Lpi4_storage_block_cmd_done
    subs x14, x14, #1
    b.ne .Lpi4_storage_block_wait_cmd_done
    b .Lpi4_storage_block_sdhci_wait
.Lpi4_storage_block_cmd_done:
    mov w15, #PI4_SDHCI_INT_CMD_COMPLETE
    str w15, [x12, #PI4_SDHCI_INT_STATUS]

    mov x17, #1
.Lpi4_storage_block_sector_loop:
    cbz x17, .Lpi4_storage_block_wait_transfer_done
    mov x14, #PI4_SDHCI_POLL_LIMIT
.Lpi4_storage_block_wait_buffer_ready:
    ldr w13, [x12, #PI4_SDHCI_INT_STATUS]
    adr x3, pi4_storage_status_block_int_status
    str x13, [x3]
    tst w13, #PI4_SDHCI_INT_ERROR
    b.ne .Lpi4_storage_block_sdhci_error
    tst w13, #PI4_SDHCI_INT_BUFFER_READ_READY
    b.ne .Lpi4_storage_block_read_sector
    subs x14, x14, #1
    b.ne .Lpi4_storage_block_wait_buffer_ready
    cbz x6, .Lpi4_storage_block_sdhci_wait
    b .Lpi4_storage_block_sdhci_eio

.Lpi4_storage_block_read_sector:
    mov x14, #PI4_SDHCI_PIO_WORDS_PER_SECTOR
.Lpi4_storage_block_read_word:
    ldr w13, [x12, #PI4_SDHCI_BUFFER]
    str w13, [x10], #4
    add x6, x6, #4
    subs x14, x14, #1
    b.ne .Lpi4_storage_block_read_word

    add x7, x7, #1
    adr x3, pi4_storage_status_block_copied_bytes
    str x6, [x3]
    adr x3, pi4_storage_status_block_copied_sectors
    str x7, [x3]
    lsr x15, x6, #2
    adr x3, pi4_storage_status_block_pio_words
    str x15, [x3]
    mov w13, #PI4_SDHCI_INT_BUFFER_READ_READY
    str w13, [x12, #PI4_SDHCI_INT_STATUS]
    sub x17, x17, #1
    b .Lpi4_storage_block_sector_loop

.Lpi4_storage_block_wait_transfer_done:
    mov x14, #PI4_SDHCI_POLL_LIMIT
.Lpi4_storage_block_wait_transfer_loop:
    ldr w13, [x12, #PI4_SDHCI_INT_STATUS]
    adr x3, pi4_storage_status_block_int_status
    str x13, [x3]
    tst w13, #PI4_SDHCI_INT_ERROR
    b.ne .Lpi4_storage_block_sdhci_error
    tst w13, #PI4_SDHCI_INT_TRANSFER_COMPLETE
    b.ne .Lpi4_storage_block_transfer_done
    subs x14, x14, #1
    b.ne .Lpi4_storage_block_wait_transfer_loop
    cbz x6, .Lpi4_storage_block_sdhci_wait
    b .Lpi4_storage_block_sdhci_eio

.Lpi4_storage_block_transfer_done:
    mov w15, #PI4_SDHCI_INT_TRANSFER_COMPLETE
    str w15, [x12, #PI4_SDHCI_INT_STATUS]
    cmp x7, x9
    b.lo .Lpi4_storage_block_issue_single_sector
    cmp x6, x11
    b.ne .Lpi4_storage_block_sdhci_eio

    adr x3, pi4_storage_status_pi4sd
    ldr w4, =VIBE_PI4_STORAGE_SD_OK
    str w4, [x3]
    mov x5, xzr
    b .Lpi4_storage_block_sdhci_record_present

.Lpi4_storage_block_sdhci_error:
    adr x3, pi4_storage_status_block_error_status
    str x13, [x3]
    str w13, [x12, #PI4_SDHCI_INT_STATUS]
    b .Lpi4_storage_block_sdhci_eio

.Lpi4_storage_block_sdhci_eio:
    ldr w4, =VIBE_PI4_STORAGE_EIO
    mov x5, #-PI4_STORAGE_ERRNO_EIO
    b .Lpi4_storage_block_sdhci_record_present

.Lpi4_storage_block_sdhci_wait:
    ldr w4, =VIBE_PI4_STORAGE_WAIT
    mov x5, #-PI4_STORAGE_ERRNO_WAIT
    b .Lpi4_storage_block_sdhci_record_present

.Lpi4_storage_block_sdhci_record_present:
    ldr w13, [x12, #PI4_SDHCI_PRESENT_STATE]
    adr x3, pi4_storage_status_block_present_after
    str x13, [x3]
    b .Lpi4_storage_block_finish

.Lpi4_storage_block_enosys:
    ldr w4, =VIBE_PI4_STORAGE_ENOSYS
    mov x5, #-PI4_STORAGE_ERRNO_ENOSYS
    b .Lpi4_storage_block_finish

.Lpi4_storage_block_wait:
    ldr w4, =VIBE_PI4_STORAGE_WAIT
    mov x5, #-PI4_STORAGE_ERRNO_WAIT
    b .Lpi4_storage_block_finish

.Lpi4_storage_block_einval:
    ldr w4, =VIBE_PI4_STORAGE_EINVAL
    mov x5, #-PI4_STORAGE_ERRNO_EINVAL

.Lpi4_storage_block_finish:
    adr x3, pi4_storage_status_block
    str w4, [x3]
    adr x3, pi4_storage_status_block_result
    str x5, [x3]
    mov x0, x5
    ret
.size pi4_storage_read_blocks, . - pi4_storage_read_blocks
.size pi4_storage_block_read, . - pi4_storage_block_read

// x0 = SDHCI base, w1 = command register value, w2 = command argument.
// Returns x0 = 0 and x1 = response0 on command completion, or x0 = -errno.
.type pi4_storage_sdhci_send_command, %function
pi4_storage_sdhci_send_command:
    mov x9, x0
    mov w10, w1
    mov w11, w2

    mov x12, #PI4_SDHCI_POLL_LIMIT
.Lpi4_storage_sdhci_cmd_wait_inhibit:
    ldr w13, [x9, #PI4_SDHCI_PRESENT_STATE]
    and w14, w13, #PI4_SDHCI_PRESENT_INHIBIT_MASK
    cbz w14, .Lpi4_storage_sdhci_cmd_issue
    subs x12, x12, #1
    b.ne .Lpi4_storage_sdhci_cmd_wait_inhibit
    mov x0, #-PI4_STORAGE_ERRNO_WAIT
    mov x1, xzr
    ret

.Lpi4_storage_sdhci_cmd_issue:
    mov w13, #PI4_SDHCI_TRANSFER_NONE
    strh w13, [x9, #PI4_SDHCI_TRANSFER_MODE]
    mov w13, #-1
    str w13, [x9, #PI4_SDHCI_INT_STATUS]
    str w11, [x9, #PI4_SDHCI_ARGUMENT]
    strh w10, [x9, #PI4_SDHCI_COMMAND]
    dsb sy

    mov x12, #PI4_SDHCI_POLL_LIMIT
.Lpi4_storage_sdhci_cmd_poll:
    ldr w13, [x9, #PI4_SDHCI_INT_STATUS]
    adr x3, pi4_storage_status_block_int_status
    str x13, [x3]
    tst w13, #PI4_SDHCI_INT_ERROR
    b.ne .Lpi4_storage_sdhci_cmd_error
    tst w13, #PI4_SDHCI_INT_CMD_COMPLETE
    b.ne .Lpi4_storage_sdhci_cmd_done
    subs x12, x12, #1
    b.ne .Lpi4_storage_sdhci_cmd_poll
    mov x0, #-PI4_STORAGE_ERRNO_WAIT
    mov x1, xzr
    ret

.Lpi4_storage_sdhci_cmd_done:
    ldr w1, [x9, #PI4_SDHCI_RESPONSE]
    mov w14, #PI4_SDHCI_INT_CMD_COMPLETE
    str w14, [x9, #PI4_SDHCI_INT_STATUS]
    and w14, w10, #0x3
    cmp w14, #0x3
    b.ne .Lpi4_storage_sdhci_cmd_success

    mov x12, #PI4_SDHCI_POLL_LIMIT
.Lpi4_storage_sdhci_cmd_wait_busy:
    ldr w13, [x9, #PI4_SDHCI_INT_STATUS]
    adr x3, pi4_storage_status_block_int_status
    str x13, [x3]
    tst w13, #PI4_SDHCI_INT_ERROR
    b.ne .Lpi4_storage_sdhci_cmd_error
    tst w13, #PI4_SDHCI_INT_TRANSFER_COMPLETE
    b.ne .Lpi4_storage_sdhci_cmd_busy_done
    subs x12, x12, #1
    b.ne .Lpi4_storage_sdhci_cmd_wait_busy
    mov x0, #-PI4_STORAGE_ERRNO_WAIT
    mov x1, xzr
    ret

.Lpi4_storage_sdhci_cmd_busy_done:
    mov w14, #PI4_SDHCI_INT_TRANSFER_COMPLETE
    str w14, [x9, #PI4_SDHCI_INT_STATUS]

.Lpi4_storage_sdhci_cmd_success:
    mov x0, xzr
    ret

.Lpi4_storage_sdhci_cmd_error:
    adr x3, pi4_storage_status_block_error_status
    str x13, [x3]
    str w13, [x9, #PI4_SDHCI_INT_STATUS]
    mov x0, #-PI4_STORAGE_ERRNO_EIO
    mov x1, xzr
    ret
.size pi4_storage_sdhci_send_command, . - pi4_storage_sdhci_send_command

// x0 = initialized SDHCI base. Initializes an inserted SD card far enough for
// bounded PIO reads and records whether command arguments are block addresses.
.type pi4_storage_sdhci_init_card, %function
pi4_storage_sdhci_init_card:
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    str x21, [sp, #32]
    mov x19, x0
    ldr w21, =PI4_SDHCI_ACMD41_ARG

    adr x0, pi4_storage_status_sdctl_card_ready
    str xzr, [x0]
    adr x0, pi4_storage_status_sdctl_ocr
    str xzr, [x0]
    adr x0, pi4_storage_status_sdctl_rca
    str xzr, [x0]
    adr x0, pi4_storage_status_sdctl_block_addressing
    str xzr, [x0]

    mov x0, x19
    mov w1, #PI4_SDHCI_CMD0_GO_IDLE
    mov w2, wzr
    bl pi4_storage_sdhci_send_command
    cbnz x0, .Lpi4_storage_sdhci_init_done

    mov x0, x19
    mov w1, #PI4_SDHCI_CMD8_SEND_IF_COND
    mov w2, #PI4_SDHCI_CMD8_IF_COND_ARG
    bl pi4_storage_sdhci_send_command
    cbz x0, .Lpi4_storage_sdhci_init_acmd41_start
    ldr w21, =PI4_SDHCI_ACMD41_ARG_LEGACY

.Lpi4_storage_sdhci_init_acmd41_start:
    mov x20, #PI4_SDHCI_ACMD41_POLL_LIMIT
.Lpi4_storage_sdhci_init_acmd41_loop:
    mov x0, x19
    mov w1, #PI4_SDHCI_CMD55_APP_CMD
    mov w2, wzr
    bl pi4_storage_sdhci_send_command
    cbnz x0, .Lpi4_storage_sdhci_init_done

    mov x0, x19
    mov w1, #PI4_SDHCI_ACMD41_SD_SEND_OP_COND
    mov w2, w21
    bl pi4_storage_sdhci_send_command
    cbnz x0, .Lpi4_storage_sdhci_init_done

    adr x2, pi4_storage_status_sdctl_ocr
    str x1, [x2]
    tst w1, #PI4_SDHCI_OCR_POWER_UP
    b.ne .Lpi4_storage_sdhci_init_card_ready
    subs x20, x20, #1
    b.ne .Lpi4_storage_sdhci_init_acmd41_loop
    mov x0, #-PI4_STORAGE_ERRNO_WAIT
    b .Lpi4_storage_sdhci_init_done

.Lpi4_storage_sdhci_init_card_ready:
    mov x21, xzr
    tst w1, #PI4_SDHCI_OCR_CARD_CAPACITY
    cset x21, ne
    adr x2, pi4_storage_status_sdctl_block_addressing
    str x21, [x2]

    mov x0, x19
    mov w1, #PI4_SDHCI_CMD2_ALL_SEND_CID
    mov w2, wzr
    bl pi4_storage_sdhci_send_command
    cbnz x0, .Lpi4_storage_sdhci_init_done

    mov x0, x19
    mov w1, #PI4_SDHCI_CMD3_SEND_REL_ADDR
    mov w2, wzr
    bl pi4_storage_sdhci_send_command
    cbnz x0, .Lpi4_storage_sdhci_init_done

    lsr x20, x1, #16
    and x20, x20, #0xffff
    cbz x20, .Lpi4_storage_sdhci_init_eio
    adr x2, pi4_storage_status_sdctl_rca
    str x20, [x2]

    mov x0, x19
    mov w1, #PI4_SDHCI_CMD7_SELECT_CARD
    lsl w2, w20, #16
    bl pi4_storage_sdhci_send_command
    cbnz x0, .Lpi4_storage_sdhci_init_done

    cbnz x21, .Lpi4_storage_sdhci_init_success
    mov x0, x19
    mov w1, #PI4_SDHCI_CMD16_SET_BLOCKLEN
    mov w2, #PI4_SDHCI_CMD16_BLOCKLEN_ARG
    bl pi4_storage_sdhci_send_command
    cbnz x0, .Lpi4_storage_sdhci_init_done

.Lpi4_storage_sdhci_init_success:
    mov x2, #1
    adr x3, pi4_storage_status_sdctl_card_ready
    str x2, [x3]
    mov x0, xzr
    b .Lpi4_storage_sdhci_init_done

.Lpi4_storage_sdhci_init_eio:
    mov x0, #-PI4_STORAGE_ERRNO_EIO

.Lpi4_storage_sdhci_init_done:
    ldr x21, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret
.size pi4_storage_sdhci_init_card, . - pi4_storage_sdhci_init_card

// EMMC2/SDHCI controller discovery and bounded card initialization. This
// records the Pi 4 SD host register window before media gates can go green.
.global pi4_storage_probe_controller_status
.type pi4_storage_probe_controller_status, %function
pi4_storage_probe_controller_status:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x19, [sp, #16]
    dsb sy

    adr x1, pi4_storage_status_block_controller
    ldr w2, =VIBE_PI4_STORAGE_ENOSYS
    str w2, [x1]
    ldr x0, =PI4_EMMC2_LEGACY_BASE
    adr x1, pi4_storage_status_sdctl_legacy_base
    str x0, [x1]
    ldr x0, =PI4_EMMC2_ARM_BASE
    adr x1, pi4_storage_status_sdctl_arm_base
    str x0, [x1]
    mov x2, #PI4_EMMC2_REG_SIZE
    adr x1, pi4_storage_status_sdctl_span
    str x2, [x1]

    adr x3, pi4_status_pi4socrange_periph
    ldr x3, [x3]
    cbz x3, .Lpi4_storage_probe_controller_fallback
    adr x4, pi4_status_pi4socrange_span
    ldr x4, [x4]
    ldr x5, =PI4_EMMC2_PERIPH_END_OFFSET
    cmp x4, x5
    b.lo .Lpi4_storage_probe_controller_fallback
    ldr x5, =PI4_EMMC2_PERIPH_OFFSET
    add x19, x3, x5
    b .Lpi4_storage_probe_controller_selected

.Lpi4_storage_probe_controller_fallback:
    ldr x19, =PI4_EMMC2_ARM_BASE

.Lpi4_storage_probe_controller_selected:
    adr x1, pi4_storage_status_sdctl_arm_base
    str x19, [x1]

    adr x1, pi4_storage_status_block_controller
    ldr w2, =VIBE_PI4_STORAGE_SDCTL_EMMC2
    str w2, [x1]

.Lpi4_storage_probe_controller_reset:
    mov w2, #-1
    str w2, [x19, #PI4_SDHCI_INT_STATUS]
    mov w2, #PI4_SDHCI_RESET_ALL
    strb w2, [x19, #PI4_SDHCI_SOFTWARE_RESET]
    dsb sy

    mov x5, #PI4_SDHCI_POLL_LIMIT
.Lpi4_storage_probe_reset_poll:
    ldrb w2, [x19, #PI4_SDHCI_SOFTWARE_RESET]
    cbz w2, .Lpi4_storage_probe_reset_done
    subs x5, x5, #1
    b.ne .Lpi4_storage_probe_reset_poll
    b .Lpi4_storage_probe_record_regs

.Lpi4_storage_probe_reset_done:
    mov w2, #PI4_SDHCI_POWER_3V3_ON
    strb w2, [x19, #PI4_SDHCI_POWER_CONTROL]
    mov w2, #PI4_SDHCI_TIMEOUT_MAX
    strb w2, [x19, #PI4_SDHCI_TIMEOUT_CONTROL]
    mov w2, #PI4_SDHCI_CLOCK_INT_ENABLE
    strh w2, [x19, #PI4_SDHCI_CLOCK_CONTROL]
    dsb sy

    mov x5, #PI4_SDHCI_POLL_LIMIT
.Lpi4_storage_probe_clock_poll:
    ldrh w2, [x19, #PI4_SDHCI_CLOCK_CONTROL]
    tst w2, #PI4_SDHCI_CLOCK_INT_STABLE
    b.ne .Lpi4_storage_probe_clock_stable
    subs x5, x5, #1
    b.ne .Lpi4_storage_probe_clock_poll
    b .Lpi4_storage_probe_record_regs

.Lpi4_storage_probe_clock_stable:
    mov w2, #PI4_SDHCI_CLOCK_INT_ENABLE
    orr w2, w2, #PI4_SDHCI_CLOCK_SD_ENABLE
    strh w2, [x19, #PI4_SDHCI_CLOCK_CONTROL]
    ldr w2, =PI4_SDHCI_INT_PIO_ENABLE_MASK
    str w2, [x19, #PI4_SDHCI_INT_ENABLE]
    str wzr, [x19, #PI4_SDHCI_SIGNAL_ENABLE]
    dsb sy

    mov x0, x19
    bl pi4_storage_sdhci_init_card

.Lpi4_storage_probe_record_regs:
    ldrh w2, [x19, #PI4_SDHCI_HOST_VERSION]
    adr x1, pi4_storage_status_sdctl_host_version
    str x2, [x1]
    ldr w2, [x19, #PI4_SDHCI_CAPABILITIES]
    adr x1, pi4_storage_status_sdctl_caps0
    str x2, [x1]
    ldr w2, [x19, #PI4_SDHCI_CAPABILITIES_1]
    adr x1, pi4_storage_status_sdctl_caps1
    str x2, [x1]
    ldr w2, [x19, #PI4_SDHCI_PRESENT_STATE]
    adr x1, pi4_storage_status_sdctl_present
    str x2, [x1]
    ldrb w2, [x19, #PI4_SDHCI_HOST_CONTROL]
    adr x1, pi4_storage_status_sdctl_host_control
    str x2, [x1]
    ldrb w2, [x19, #PI4_SDHCI_POWER_CONTROL]
    adr x1, pi4_storage_status_sdctl_power_control
    str x2, [x1]
    ldrh w2, [x19, #PI4_SDHCI_CLOCK_CONTROL]
    adr x1, pi4_storage_status_sdctl_clock_control
    str x2, [x1]
    ldrb w2, [x19, #PI4_SDHCI_SOFTWARE_RESET]
    adr x1, pi4_storage_status_sdctl_software_reset
    str x2, [x1]
    ldr w2, [x19, #PI4_SDHCI_INT_STATUS]
    adr x1, pi4_storage_status_sdctl_int_status
    str x2, [x1]

    adr x1, pi4_storage_status_sdctl_card_ready
    ldr x2, [x1]
    cbnz x2, .Lpi4_storage_probe_controller_done

    adr x1, pi4_storage_status_block_controller
    ldr w2, [x1]
    ldr w3, =VIBE_PI4_STORAGE_SDCTL_EMMC2
    cmp w2, w3
    b.ne .Lpi4_storage_probe_controller_done

.Lpi4_storage_probe_controller_try_emmc:
    ldr x19, =PI4_EMMC_ARM_BASE
    adr x1, pi4_status_pi4socrange_periph
    ldr x3, [x1]
    cbz x3, .Lpi4_storage_probe_controller_emmc_fallback
    adr x4, pi4_status_pi4socrange_span
    ldr x4, [x4]
    ldr x5, =PI4_EMMC_PERIPH_END_OFFSET
    cmp x4, x5
    b.lo .Lpi4_storage_probe_controller_emmc_fallback
    ldr x5, =PI4_EMMC_PERIPH_OFFSET
    add x19, x3, x5

.Lpi4_storage_probe_controller_emmc_fallback:
    ldr x0, =PI4_EMMC_LEGACY_BASE
    adr x1, pi4_storage_status_sdctl_legacy_base
    str x0, [x1]
    adr x1, pi4_storage_status_sdctl_arm_base
    str x19, [x1]
    mov x0, #PI4_EMMC_REG_SIZE
    adr x1, pi4_storage_status_sdctl_span
    str x0, [x1]
    adr x1, pi4_storage_status_block_controller
    ldr w2, =VIBE_PI4_STORAGE_SDCTL_EMMC
    str w2, [x1]
    b .Lpi4_storage_probe_controller_reset

.Lpi4_storage_probe_controller_done:
    dsb sy
    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size pi4_storage_probe_controller_status, . - pi4_storage_probe_controller_status

// Real boot-media probe: read LBA0, parse the MBR, read the FAT BPB, validate a
// 512-byte-sector FAT16 layout, read the fixed root directory into a bounded
// buffer, then publish FAT/VFS gates only for that media-backed evidence.
.global pi4_storage_boot_media_probe
.type pi4_storage_boot_media_probe, %function
pi4_storage_boot_media_probe:
    stp x29, x30, [sp, #-96]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    str x27, [sp, #80]

    adr x16, pi4_storage_reset_status
    blr x16

    adr x19, pi4_storage_block_scratch
    adr x20, pi4_storage_boot_bpb_sector
    adr x21, pi4_storage_root_dir_scratch
    mov x22, xzr

    adr x0, pi4_storage_boot_mbr_sector_buffer
    str x19, [x0]
    adr x1, pi4_storage_boot_bpb_sector_buffer
    str x20, [x1]
    adr x0, pi4_storage_boot_root_dir_buffer_ptr
    str x21, [x0]
    mov x0, #PI4_STORAGE_ROOT_BUFFER_SECTORS
    lsl x0, x0, #9
    adr x1, pi4_storage_boot_root_dir_buffer_bytes
    str x0, [x1]

    adr x16, pi4_storage_probe_controller_status
    blr x16

    mov x0, xzr
    mov x1, #1
    mov x2, x19
    adr x16, pi4_storage_read_blocks
    blr x16
    cbnz x0, .Lpi4_storage_boot_media_done

    mov x0, x19
    adr x16, pi4_storage_parse_mbr
    blr x16
    cbz w0, .Lpi4_storage_boot_media_done

    orr x22, x22, #1
    adr x0, pi4_storage_status_mbr_part_lba
    ldr x23, [x0]

    mov x0, x23
    mov x1, #1
    mov x2, x20
    adr x16, pi4_storage_read_blocks
    blr x16
    cbnz x0, .Lpi4_storage_boot_media_done

    mov x0, x20
    mov x1, x23
    adr x16, pi4_storage_parse_fat_bpb
    blr x16
    cbz w0, .Lpi4_storage_boot_media_done

    orr x22, x22, #2
    adr x0, pi4_storage_status_fat_type
    ldr w1, [x0]
    ldr w2, =VIBE_PI4_STORAGE_FAT16
    cmp w1, w2
    b.ne .Lpi4_storage_boot_media_done
    adr x0, pi4_storage_status_bpb_bytes_per_sector
    ldr x1, [x0]
    cmp x1, #PI4_STORAGE_BLOCK_SECTOR_BYTES
    b.ne .Lpi4_storage_boot_media_done

    adr x0, pi4_storage_status_pi4fat
    ldr w1, =VIBE_PI4_STORAGE_BPB_OK
    str w1, [x0]

    adr x0, pi4_storage_status_bpb_root_dir_lba
    ldr x24, [x0]
    adr x0, pi4_storage_status_bpb_root_dir_sectors
    ldr x25, [x0]
    cbz x25, .Lpi4_storage_boot_root_bad
    mov x26, #PI4_STORAGE_ROOT_BUFFER_SECTORS
    cmp x25, x26
    b.hi .Lpi4_storage_boot_root_bad
    mov x26, #PI4_STORAGE_BLOCK_MAX_COUNT
    cmp x25, x26
    b.hi .Lpi4_storage_boot_root_bad

    mov x0, x24
    mov x1, x25
    mov x2, x21
    adr x16, pi4_storage_read_blocks
    blr x16
    cbnz x0, .Lpi4_storage_boot_media_done

    mov x0, x20
    mov x1, x23
    mov x2, x21
    lsl x3, x25, #9
    adr x16, pi4_storage_parse_fat_root
    blr x16
    cbz w0, .Lpi4_storage_boot_media_done

    orr x22, x22, #4
    b .Lpi4_storage_boot_media_done

.Lpi4_storage_boot_root_bad:
    adr x0, pi4_storage_status_root
    ldr w1, =VIBE_PI4_STORAGE_ROOT_BAD
    str w1, [x0]

.Lpi4_storage_boot_media_done:
    adr x0, pi4_storage_boot_parse_mask
    str x22, [x0]
    mov x0, x22

    ldr x27, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret
.size pi4_storage_boot_media_probe, . - pi4_storage_boot_media_probe

// x0 = 512-byte MBR sector buffer pointer, x1 = 512-byte partition BPB sector
// buffer pointer. Returns w0 bit0 for parsed MBR and bit1 for parsed BPB.
.global pi4_storage_probe_boot_sector_buffers
.type pi4_storage_probe_boot_sector_buffers, %function
pi4_storage_probe_boot_sector_buffers:
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    str x21, [sp, #32]

    mov x19, x0
    mov x20, x1
    mov x21, xzr

    adr x16, pi4_storage_reset_status
    blr x16

    adr x0, pi4_storage_boot_mbr_sector_buffer
    str x19, [x0]
    adr x0, pi4_storage_boot_bpb_sector_buffer
    str x20, [x0]

    cbz x19, .Lpi4_storage_probe_done

    mov x0, x19
    adr x16, pi4_storage_parse_mbr
    blr x16
    cbz w0, .Lpi4_storage_probe_done

    orr x21, x21, #1

    cbz x20, .Lpi4_storage_probe_done

    mov x0, x20
    adr x1, pi4_storage_status_mbr_part_lba
    ldr x1, [x1]
    adr x16, pi4_storage_parse_fat_bpb
    blr x16
    cbz w0, .Lpi4_storage_probe_done

    orr x21, x21, #2

.Lpi4_storage_probe_done:
    adr x0, pi4_storage_boot_parse_mask
    str x21, [x0]
    mov w0, w21

    ldr x21, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret
.size pi4_storage_probe_boot_sector_buffers, . - pi4_storage_probe_boot_sector_buffers

// x0 = 512-byte MBR sector pointer. Returns w0 = 1 when a usable partition
// entry is parsed, otherwise w0 = 0.
.global pi4_storage_parse_mbr
.type pi4_storage_parse_mbr, %function
pi4_storage_parse_mbr:
    adr x1, pi4_storage_status_mbr
    ldr w2, =VIBE_PI4_STORAGE_MBR_BAD
    str w2, [x1]

    adr x1, pi4_storage_mbr_values_start
    adr x2, pi4_storage_mbr_values_end
.Lpi4_storage_mbr_clear_values:
    cmp x1, x2
    b.hs .Lpi4_storage_mbr_clear_done
    str xzr, [x1], #8
    b .Lpi4_storage_mbr_clear_values
.Lpi4_storage_mbr_clear_done:
    cbz x0, .Lpi4_storage_mbr_bad

    PI4_STORAGE_LOAD_LE16 w2, x0, PI4_STORAGE_BOOT_SIG_OFF, w3
    mov w3, #PI4_STORAGE_BOOT_SIG_LE
    cmp w2, w3
    b.ne .Lpi4_storage_mbr_bad

    adr x1, pi4_storage_status_mbr_signature
    str x2, [x1]

    add x3, x0, #PI4_STORAGE_MBR_PART0_OFF
    mov w4, wzr
.Lpi4_storage_mbr_part_loop:
    cmp w4, #PI4_STORAGE_MBR_PART_COUNT
    b.hs .Lpi4_storage_mbr_bad

    add x5, x3, w4, uxtw #4
    ldrb w6, [x5, #PI4_STORAGE_MBR_PART_TYPE_OFF]
    cmp w6, #PI4_STORAGE_MBR_PART_TYPE_FAT16
    b.eq .Lpi4_storage_mbr_type_ok
    cmp w6, #PI4_STORAGE_MBR_PART_TYPE_FAT32
    b.eq .Lpi4_storage_mbr_type_ok
    cmp w6, #PI4_STORAGE_MBR_PART_TYPE_FAT32_LBA
    b.ne .Lpi4_storage_mbr_next_part
.Lpi4_storage_mbr_type_ok:
    ldrb w9, [x5, #PI4_STORAGE_MBR_PART_BOOT_OFF]
    cbz w9, .Lpi4_storage_mbr_boot_ok
    cmp w9, #PI4_STORAGE_MBR_PART_BOOT_ACTIVE
    b.ne .Lpi4_storage_mbr_next_part
.Lpi4_storage_mbr_boot_ok:
    ldrb w7, [x5, #PI4_STORAGE_MBR_PART_LBA_OFF]
    ldrb w10, [x5, #(PI4_STORAGE_MBR_PART_LBA_OFF + 1)]
    orr w7, w7, w10, lsl #8
    ldrb w10, [x5, #(PI4_STORAGE_MBR_PART_LBA_OFF + 2)]
    orr w7, w7, w10, lsl #16
    ldrb w10, [x5, #(PI4_STORAGE_MBR_PART_LBA_OFF + 3)]
    orr w7, w7, w10, lsl #24
    cbz w7, .Lpi4_storage_mbr_next_part
    ldrb w8, [x5, #PI4_STORAGE_MBR_PART_SECTORS_OFF]
    ldrb w10, [x5, #(PI4_STORAGE_MBR_PART_SECTORS_OFF + 1)]
    orr w8, w8, w10, lsl #8
    ldrb w10, [x5, #(PI4_STORAGE_MBR_PART_SECTORS_OFF + 2)]
    orr w8, w8, w10, lsl #16
    ldrb w10, [x5, #(PI4_STORAGE_MBR_PART_SECTORS_OFF + 3)]
    orr w8, w8, w10, lsl #24
    cbz w8, .Lpi4_storage_mbr_next_part

    adr x1, pi4_storage_status_mbr_part_index
    uxtw x2, w4
    str x2, [x1]
    adr x1, pi4_storage_status_mbr_part_boot
    uxtw x2, w9
    str x2, [x1]
    adr x1, pi4_storage_status_mbr_part_type
    uxtw x2, w6
    str x2, [x1]
    adr x1, pi4_storage_status_mbr_part_lba
    uxtw x2, w7
    str x2, [x1]
    adr x1, pi4_storage_status_mbr_part_sectors
    uxtw x2, w8
    str x2, [x1]

    adr x1, pi4_storage_status_mbr
    ldr w2, =VIBE_PI4_STORAGE_MBR_OK
    str w2, [x1]
    mov w0, #1
    ret

.Lpi4_storage_mbr_next_part:
    add w4, w4, #1
    b .Lpi4_storage_mbr_part_loop

.Lpi4_storage_mbr_bad:
    mov w0, wzr
    ret
.size pi4_storage_parse_mbr, . - pi4_storage_parse_mbr

// x0 = 512-byte FAT boot sector pointer, x1 = partition base LBA.
// Returns w0 = 1 when BPB-derived layout fields are sane enough to publish.
.global pi4_storage_parse_fat_bpb
.type pi4_storage_parse_fat_bpb, %function
pi4_storage_parse_fat_bpb:
    mov x2, x1

    adr x1, pi4_storage_status_bpb
    ldr w3, =VIBE_PI4_STORAGE_BPB_BAD
    str w3, [x1]
    adr x1, pi4_storage_status_fat_type
    ldr w3, =VIBE_PI4_STORAGE_WAIT
    str w3, [x1]

    adr x1, pi4_storage_bpb_values_start
    adr x3, pi4_storage_bpb_values_end
.Lpi4_storage_bpb_clear_values:
    cmp x1, x3
    b.hs .Lpi4_storage_bpb_clear_done
    str xzr, [x1], #8
    b .Lpi4_storage_bpb_clear_values
.Lpi4_storage_bpb_clear_done:
    cbz x0, .Lpi4_storage_bpb_bad

    PI4_STORAGE_LOAD_LE16 w3, x0, PI4_STORAGE_BOOT_SIG_OFF, w4
    mov w4, #PI4_STORAGE_BOOT_SIG_LE
    cmp w3, w4
    b.ne .Lpi4_storage_bpb_bad

    PI4_STORAGE_LOAD_LE16 w4, x0, PI4_STORAGE_BPB_BYTES_PER_SECTOR, w9
    cmp w4, #PI4_STORAGE_BLOCK_SECTOR_BYTES
    b.ne .Lpi4_storage_bpb_bad
.Lpi4_storage_bpb_bps_ok:
    ldrb w5, [x0, #PI4_STORAGE_BPB_SECTORS_PER_CLUS]
    cbz w5, .Lpi4_storage_bpb_bad
    sub w6, w5, #1
    tst w5, w6
    b.ne .Lpi4_storage_bpb_bad
    cmp w5, #PI4_STORAGE_FAT_MAX_SPC
    b.hi .Lpi4_storage_bpb_bad

    PI4_STORAGE_LOAD_LE16 w6, x0, PI4_STORAGE_BPB_RESERVED_SECTORS, w9
    cbz w6, .Lpi4_storage_bpb_bad
    ldrb w7, [x0, #PI4_STORAGE_BPB_FAT_COUNT]
    cbz w7, .Lpi4_storage_bpb_bad
    PI4_STORAGE_LOAD_LE16 w8, x0, PI4_STORAGE_BPB_ROOT_ENTRIES, w9

    PI4_STORAGE_LOAD_LE16 w9, x0, PI4_STORAGE_BPB_TOTAL_SECTORS_16, w13
    cbz w9, .Lpi4_storage_bpb_use_total32
    uxtw x10, w9
    b .Lpi4_storage_bpb_total_done
.Lpi4_storage_bpb_use_total32:
    PI4_STORAGE_LOAD_LE32 w9, x0, PI4_STORAGE_BPB_TOTAL_SECTORS_32, w13
    cbz w9, .Lpi4_storage_bpb_bad
    uxtw x10, w9
.Lpi4_storage_bpb_total_done:
    adr x9, pi4_storage_status_mbr_part_lba
    ldr x9, [x9]
    cbz x9, .Lpi4_storage_bpb_mbr_lba_ok
    cmp x9, x2
    b.ne .Lpi4_storage_bpb_bad
.Lpi4_storage_bpb_mbr_lba_ok:
    adr x9, pi4_storage_status_mbr_part_sectors
    ldr x9, [x9]
    cbz x9, .Lpi4_storage_bpb_part_span_ok
    cmp x10, x9
    b.hi .Lpi4_storage_bpb_bad
.Lpi4_storage_bpb_part_span_ok:

    PI4_STORAGE_LOAD_LE16 w9, x0, PI4_STORAGE_BPB_FAT_SECTORS_16, w13
    cbz w9, .Lpi4_storage_bpb_use_fat32_size
    uxtw x11, w9
    b .Lpi4_storage_bpb_fat_size_done
.Lpi4_storage_bpb_use_fat32_size:
    PI4_STORAGE_LOAD_LE32 w9, x0, PI4_STORAGE_BPB_FAT_SECTORS_32, w13
    cbz w9, .Lpi4_storage_bpb_bad
    uxtw x11, w9
.Lpi4_storage_bpb_fat_size_done:

    uxtw x12, w8
    lsl x12, x12, #5
    uxtw x13, w4
    sub x9, x13, #1
    add x12, x12, x9
    udiv x12, x12, x13

    uxtw x14, w7
    mul x14, x14, x11
    uxtw x15, w6
    add x16, x15, x14
    add x16, x16, x12
    cmp x16, x10
    b.hs .Lpi4_storage_bpb_bad

    sub x17, x10, x16
    uxtw x13, w5
    udiv x17, x17, x13
    cbz x17, .Lpi4_storage_bpb_bad

    ldr w1, =VIBE_PI4_STORAGE_FAT12
    mov x9, #PI4_STORAGE_FAT12_CLUSTER_LIMIT
    cmp x17, x9
    b.lo .Lpi4_storage_bpb_have_fat_type
    ldr w1, =VIBE_PI4_STORAGE_FAT16
    mov x9, #PI4_STORAGE_FAT16_CLUSTER_LIMIT
    cmp x17, x9
    b.lo .Lpi4_storage_bpb_have_fat_type
    ldr w1, =VIBE_PI4_STORAGE_FAT32
.Lpi4_storage_bpb_have_fat_type:
    PI4_STORAGE_LOAD_LE32 w9, x0, PI4_STORAGE_BPB_HIDDEN_SECTORS, w13
    uxtw x9, w9
    cbz x2, .Lpi4_storage_bpb_hidden_ok
    cmp x9, x2
    b.ne .Lpi4_storage_bpb_bad
.Lpi4_storage_bpb_hidden_ok:
    PI4_STORAGE_LOAD_LE32 w9, x0, PI4_STORAGE_BPB_ROOT_CLUSTER_32, w13
    uxtw x9, w9
    ldr w13, =VIBE_PI4_STORAGE_FAT32
    cmp w1, w13
    b.eq .Lpi4_storage_bpb_fat32_fields
    cbz w8, .Lpi4_storage_bpb_bad
    cbz x12, .Lpi4_storage_bpb_bad
    b .Lpi4_storage_bpb_type_fields_ok
.Lpi4_storage_bpb_fat32_fields:
    cbnz w8, .Lpi4_storage_bpb_bad
    cmp x9, #2
    b.lo .Lpi4_storage_bpb_bad
.Lpi4_storage_bpb_type_fields_ok:
    adr x13, pi4_storage_status_mbr_part_type
    ldr x13, [x13]
    cbz x13, .Lpi4_storage_bpb_mbr_type_ok
    cmp x13, #PI4_STORAGE_MBR_PART_TYPE_FAT16
    b.ne .Lpi4_storage_bpb_check_mbr_fat32
    ldr w9, =VIBE_PI4_STORAGE_FAT16
    cmp w1, w9
    b.ne .Lpi4_storage_bpb_bad
    b .Lpi4_storage_bpb_mbr_type_ok
.Lpi4_storage_bpb_check_mbr_fat32:
    cmp x13, #PI4_STORAGE_MBR_PART_TYPE_FAT32
    b.eq .Lpi4_storage_bpb_require_fat32
    cmp x13, #PI4_STORAGE_MBR_PART_TYPE_FAT32_LBA
    b.ne .Lpi4_storage_bpb_mbr_type_ok
.Lpi4_storage_bpb_require_fat32:
    ldr w9, =VIBE_PI4_STORAGE_FAT32
    cmp w1, w9
    b.ne .Lpi4_storage_bpb_bad
.Lpi4_storage_bpb_mbr_type_ok:

    adr x9, pi4_storage_status_bpb_signature
    uxtw x3, w3
    str x3, [x9]
    adr x9, pi4_storage_status_bpb_bytes_per_sector
    uxtw x3, w4
    str x3, [x9]
    adr x9, pi4_storage_status_bpb_sectors_per_cluster
    uxtw x3, w5
    str x3, [x9]
    adr x9, pi4_storage_status_bpb_reserved_sectors
    uxtw x3, w6
    str x3, [x9]
    adr x9, pi4_storage_status_bpb_fat_count
    uxtw x3, w7
    str x3, [x9]
    adr x9, pi4_storage_status_bpb_root_entries
    uxtw x3, w8
    str x3, [x9]
    adr x9, pi4_storage_status_bpb_total_sectors
    str x10, [x9]
    adr x9, pi4_storage_status_bpb_fat_sectors
    str x11, [x9]
    adr x9, pi4_storage_status_bpb_root_dir_sectors
    str x12, [x9]
    adr x9, pi4_storage_status_bpb_fat_span_sectors
    str x14, [x9]
    adr x9, pi4_storage_status_bpb_first_data_rel_lba
    str x16, [x9]
    adr x9, pi4_storage_status_bpb_cluster_count
    str x17, [x9]

    adr x9, pi4_storage_status_bpb_partition_lba
    str x2, [x9]
    add x3, x2, x15
    adr x9, pi4_storage_status_bpb_fat0_lba
    str x3, [x9]
    add x3, x3, x14
    mov x4, x3
    add x3, x2, x16
    adr x9, pi4_storage_status_bpb_data_lba
    str x3, [x9]
    PI4_STORAGE_LOAD_LE32 w9, x0, PI4_STORAGE_BPB_ROOT_CLUSTER_32, w13
    uxtw x9, w9
    ldr w13, =VIBE_PI4_STORAGE_FAT32
    cmp w1, w13
    b.ne .Lpi4_storage_bpb_store_root_lba
    sub x4, x9, #2
    uxtw x13, w5
    madd x4, x4, x13, x3
.Lpi4_storage_bpb_store_root_lba:
    adr x13, pi4_storage_status_bpb_root_dir_lba
    str x4, [x13]

    PI4_STORAGE_LOAD_LE32 w3, x0, PI4_STORAGE_BPB_HIDDEN_SECTORS, w13
    adr x9, pi4_storage_status_bpb_hidden_sectors
    uxtw x3, w3
    str x3, [x9]
    PI4_STORAGE_LOAD_LE32 w3, x0, PI4_STORAGE_BPB_ROOT_CLUSTER_32, w13
    adr x9, pi4_storage_status_bpb_root_cluster
    uxtw x3, w3
    str x3, [x9]

    adr x9, pi4_storage_status_fat_type
    str w1, [x9]
    adr x9, pi4_storage_status_bpb
    ldr w1, =VIBE_PI4_STORAGE_BPB_OK
    str w1, [x9]
    mov w0, #1
    ret

.Lpi4_storage_bpb_bad:
    mov w0, wzr
    ret
.size pi4_storage_parse_fat_bpb, . - pi4_storage_parse_fat_bpb

// x0 = 512-byte FAT boot sector pointer, x1 = partition base LBA,
// x2 = caller-provided FAT root directory buffer, x3 = root buffer bytes.
// Returns w0 = 1 when the root directory buffer was parsed. File-specific
// status records say whether INIT.ELF, installed app ELFs/manifests, and
// boot-packaged asset roots were found. This consumes buffers only; it does
// not read SD/MMC media.
.global pi4_storage_parse_fat_root
.type pi4_storage_parse_fat_root, %function
pi4_storage_parse_fat_root:
    stp x29, x30, [sp, #-96]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]

    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3

    adr x0, pi4_storage_status_root
    ldr w1, =VIBE_PI4_STORAGE_ROOT_BAD
    str w1, [x0]
    adr x0, pi4_storage_status_init_elf
    ldr w1, =VIBE_PI4_STORAGE_FILE_MISSING
    str w1, [x0]
    adr x0, pi4_storage_status_app0_elf
    str w1, [x0]
    adr x0, pi4_storage_status_app1_elf
    str w1, [x0]

    adr x0, pi4_storage_root_values_start
    adr x1, pi4_storage_root_values_end
.Lpi4_storage_root_clear_values:
    cmp x0, x1
    b.hs .Lpi4_storage_root_clear_done
    str xzr, [x0], #8
    b .Lpi4_storage_root_clear_values
.Lpi4_storage_root_clear_done:
    cbz x19, .Lpi4_storage_root_bad
    cbz x21, .Lpi4_storage_root_bad
    cmp x22, #PI4_STORAGE_DIRENT_BYTES
    b.lo .Lpi4_storage_root_bad

    mov x0, x19
    mov x1, x20
    adr x16, pi4_storage_parse_fat_bpb
    blr x16
    cbz w0, .Lpi4_storage_root_bad

    adr x0, pi4_storage_status_bpb_root_entries
    ldr x3, [x0]
    adr x0, pi4_storage_status_bpb_root_dir_sectors
    ldr x4, [x0]
    adr x0, pi4_storage_status_bpb_data_lba
    ldr x5, [x0]
    mov x28, x5
    adr x0, pi4_storage_status_bpb_root_cluster
    ldr x6, [x0]
    adr x0, pi4_storage_status_bpb_sectors_per_cluster
    ldr x19, [x0]
    adr x0, pi4_storage_status_bpb_bytes_per_sector
    ldr x20, [x0]
    adr x0, pi4_storage_status_fat_type
    ldr w7, [x0]
    ldr w8, =VIBE_PI4_STORAGE_FAT32
    cmp w7, w8
    b.eq .Lpi4_storage_root_check_fat32
    cbz x3, .Lpi4_storage_root_bad
    cbz x4, .Lpi4_storage_root_bad
    b .Lpi4_storage_root_layout_ok

.Lpi4_storage_root_check_fat32:
    cmp x6, #2
    b.lo .Lpi4_storage_root_bad
    cbz x19, .Lpi4_storage_root_bad
    mov x4, x19

.Lpi4_storage_root_layout_ok:
    mov x23, x22
    mul x7, x4, x20
    cbz x7, .Lpi4_storage_root_bad
    cmp x23, x7
    csel x23, x23, x7, lo
    cbz x3, .Lpi4_storage_root_have_scan_bytes
    lsl x7, x3, #5
    cmp x23, x7
    csel x23, x23, x7, lo
.Lpi4_storage_root_have_scan_bytes:
    lsr x24, x23, #5
    cbz x24, .Lpi4_storage_root_bad
    lsl x23, x24, #5

    adr x0, pi4_storage_status_bpb_root_dir_lba
    ldr x7, [x0]
    adr x0, pi4_storage_status_root_dir_lba
    str x7, [x0]
    adr x0, pi4_storage_status_root_dir_sectors
    str x4, [x0]
    adr x0, pi4_storage_status_root_cluster
    str x6, [x0]
    adr x0, pi4_storage_status_root_data_lba
    str x5, [x0]
    adr x0, pi4_storage_status_root_entries_scanned
    str x24, [x0]
    adr x0, pi4_storage_status_root_buffer_bytes
    str x23, [x0]

    adr x0, pi4_storage_status_root
    ldr w1, =VIBE_PI4_STORAGE_ROOT_OK
    str w1, [x0]

    mov x25, x21
    mov x26, xzr
    mov x27, xzr
.Lpi4_storage_root_scan_loop:
    cmp x26, x24
    b.hs .Lpi4_storage_root_scan_done
    ldrb w0, [x25]
    cbz w0, .Lpi4_storage_root_scan_done
    cmp w0, #PI4_STORAGE_DIRENT_DELETED
    b.eq .Lpi4_storage_root_next_entry
    ldrb w0, [x25, #PI4_STORAGE_DIRENT_ATTR_OFF]
    cmp w0, #PI4_STORAGE_DIRENT_ATTR_LONG
    b.eq .Lpi4_storage_root_next_entry
    tst w0, #PI4_STORAGE_DIRENT_ATTR_VOLUME
    b.ne .Lpi4_storage_root_next_entry
    tst w0, #PI4_STORAGE_DIRENT_ATTR_DIRECTORY
    b.ne .Lpi4_storage_root_check_directory

    mov x0, x25
    adr x1, pi4_storage_name_init_elf
    bl pi4_storage_match_short_name
    cbnz w0, .Lpi4_storage_root_record_init

    mov x0, x25
    adr x1, pi4_storage_name_kernel8_img
    bl pi4_storage_match_short_name
    cbnz w0, .Lpi4_storage_root_record_kernel8

    mov x0, x25
    adr x1, pi4_storage_name_config_txt
    bl pi4_storage_match_short_name
    cbnz w0, .Lpi4_storage_root_record_config

    mov x0, x25
    adr x1, pi4_storage_name_abiprobe_elf
    bl pi4_storage_match_short_name
    cbnz w0, .Lpi4_storage_root_record_abiprobe

    mov x0, x25
    adr x1, pi4_storage_name_doom1_wad
    bl pi4_storage_match_short_name
    cbnz w0, .Lpi4_storage_root_record_doom1
    b .Lpi4_storage_root_next_entry

.Lpi4_storage_root_check_directory:
    mov x0, x25
    adr x1, pi4_storage_name_proof_dir
    bl pi4_storage_match_short_name
    cbnz w0, .Lpi4_storage_root_record_proof_dir

    mov x0, x25
    adr x1, pi4_storage_name_assets_dir
    bl pi4_storage_match_short_name
    cbnz w0, .Lpi4_storage_root_record_assets_dir

    mov x0, x25
    adr x1, pi4_storage_name_id1_dir
    bl pi4_storage_match_short_name
    cbnz w0, .Lpi4_storage_root_record_id1_dir

    mov x0, x25
    adr x1, pi4_storage_name_system_dir
    bl pi4_storage_match_short_name
    cbnz w0, .Lpi4_storage_root_record_system_dir

    mov x0, x25
    adr x1, pi4_storage_name_apps_dir
    bl pi4_storage_match_short_name
    cbnz w0, .Lpi4_storage_root_record_apps_dir
    b .Lpi4_storage_root_next_entry

.Lpi4_storage_root_record_init:
    adr x0, pi4_storage_status_init_elf
    ldr w1, [x0]
    ldr w2, =VIBE_PI4_STORAGE_FILE_OK
    cmp w1, w2
    b.eq .Lpi4_storage_root_next_entry
    mov x0, x25
    mov x1, x26
    adr x2, pi4_storage_status_init_elf
    adr x3, pi4_storage_status_init_elf_entry_index
    mov x4, x28
    mov x5, x19
    mov x6, x20
    adr x7, pi4_storage_status_bpb_cluster_count
    ldr x7, [x7]
    bl pi4_storage_record_file_metadata
    cbz w0, .Lpi4_storage_root_next_entry
    orr x27, x27, #1
    b .Lpi4_storage_root_next_entry

.Lpi4_storage_root_record_kernel8:
    mov x0, x25
    mov x1, x26
    adr x2, pi4_storage_status_kernel8_img
    bl pi4_storage_record_dirent_metadata4
    orr x27, x27, #8
    b .Lpi4_storage_root_next_entry

.Lpi4_storage_root_record_config:
    mov x0, x25
    mov x1, x26
    adr x2, pi4_storage_status_config_txt
    bl pi4_storage_record_dirent_metadata4
    orr x27, x27, #16
    b .Lpi4_storage_root_next_entry

.Lpi4_storage_root_record_abiprobe:
    mov x0, x25
    mov x1, x26
    adr x2, pi4_storage_status_abiprobe_elf
    bl pi4_storage_record_dirent_metadata4
    orr x27, x27, #32
    b .Lpi4_storage_root_next_entry

.Lpi4_storage_root_record_doom1:
    mov x0, x25
    mov x1, x26
    adr x2, pi4_storage_status_doom1_wad
    mov x4, x28
    mov x5, x19
    mov x6, x20
    adr x7, pi4_storage_status_bpb_cluster_count
    ldr x7, [x7]
    bl pi4_storage_record_file_read_metadata
    cbz w0, .Lpi4_storage_root_next_entry
    adr x0, pi4_storage_status_assets_coverage_mask
    ldr x1, [x0]
    orr x1, x1, #1
    str x1, [x0]
    orr x27, x27, #64
    b .Lpi4_storage_root_next_entry

.Lpi4_storage_root_record_proof_dir:
    mov x0, x25
    mov x1, x26
    adr x2, pi4_storage_status_proof_dir
    bl pi4_storage_record_dirent_metadata4
    orr x27, x27, #128
    b .Lpi4_storage_root_next_entry

.Lpi4_storage_root_record_assets_dir:
    mov x0, x25
    mov x1, x26
    adr x2, pi4_storage_status_assets_dir
    bl pi4_storage_record_dirent_metadata4
    adr x0, pi4_storage_status_assets_nested_dir_count
    ldr x1, [x0]
    add x1, x1, #1
    str x1, [x0]
    orr x27, x27, #256
    b .Lpi4_storage_root_next_entry

.Lpi4_storage_root_record_id1_dir:
    mov x0, x25
    mov x1, x26
    adr x2, pi4_storage_status_id1_dir
    bl pi4_storage_record_dirent_metadata4
    orr x27, x27, #512
    b .Lpi4_storage_root_next_entry

.Lpi4_storage_root_record_system_dir:
    mov x0, x25
    mov x1, x26
    adr x2, pi4_storage_status_system_dir
    bl pi4_storage_record_dirent_metadata4
    orr x27, x27, #1024
    b .Lpi4_storage_root_next_entry

.Lpi4_storage_root_record_apps_dir:
    mov x0, x25
    mov x1, x26
    adr x2, pi4_storage_status_apps_dir
    bl pi4_storage_record_dirent_metadata4
    orr x27, x27, #2048

.Lpi4_storage_root_next_entry:
    add x25, x25, #PI4_STORAGE_DIRENT_BYTES
    add x26, x26, #1
    b .Lpi4_storage_root_scan_loop

.Lpi4_storage_root_scan_done:
    adr x0, pi4_storage_status_root_found_mask
    str x27, [x0]
    mov w0, #1
    b .Lpi4_storage_root_done

.Lpi4_storage_root_bad:
    mov w0, wzr

.Lpi4_storage_root_done:
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret
.size pi4_storage_parse_fat_root, . - pi4_storage_parse_fat_root

.type pi4_storage_match_short_name, %function
pi4_storage_match_short_name:
    mov x2, xzr
.Lpi4_storage_match_name_loop:
    cmp x2, #11
    b.hs .Lpi4_storage_match_name_ok
    ldrb w3, [x0, x2]
    ldrb w4, [x1, x2]
    cmp w3, w4
    b.ne .Lpi4_storage_match_name_no
    add x2, x2, #1
    b .Lpi4_storage_match_name_loop
.Lpi4_storage_match_name_ok:
    mov w0, #1
    ret
.Lpi4_storage_match_name_no:
    mov w0, wzr
    ret
.size pi4_storage_match_short_name, . - pi4_storage_match_short_name

.type pi4_storage_copy_short_name, %function
pi4_storage_copy_short_name:
    mov x2, xzr
.Lpi4_storage_copy_short_name_loop:
    cmp x2, #11
    b.hs .Lpi4_storage_copy_short_name_done
    ldrb w3, [x0, x2]
    strb w3, [x1, x2]
    add x2, x2, #1
    b .Lpi4_storage_copy_short_name_loop
.Lpi4_storage_copy_short_name_done:
    strb wzr, [x1, #11]
    ret
.size pi4_storage_copy_short_name, . - pi4_storage_copy_short_name

.type pi4_storage_record_dirent_metadata4, %function
pi4_storage_record_dirent_metadata4:
    add x1, x1, #1
    str x1, [x2]
    ldrb w3, [x0, #PI4_STORAGE_DIRENT_ATTR_OFF]
    str x3, [x2, #8]
    PI4_STORAGE_LOAD_LE16 w3, x0, PI4_STORAGE_DIRENT_CLUSTER_HI_OFF, w4
    lsl x3, x3, #16
    PI4_STORAGE_LOAD_LE16 w4, x0, PI4_STORAGE_DIRENT_CLUSTER_LO_OFF, w5
    orr x3, x3, x4
    str x3, [x2, #16]
    PI4_STORAGE_LOAD_LE32 w4, x0, PI4_STORAGE_DIRENT_SIZE_OFF, w5
    str x4, [x2, #24]
    ret
.size pi4_storage_record_dirent_metadata4, . - pi4_storage_record_dirent_metadata4

.type pi4_storage_record_file_read_metadata, %function
pi4_storage_record_file_read_metadata:
    mov x10, x4
    mov x11, x5
    mov x12, x6
    mov x13, x7
    add x1, x1, #1
    str x1, [x2]
    ldrb w4, [x0, #PI4_STORAGE_DIRENT_ATTR_OFF]
    cmp w4, #PI4_STORAGE_DIRENT_ATTR_LONG
    b.eq .Lpi4_storage_record_read_plan_invalid
    tst w4, #PI4_STORAGE_DIRENT_ATTR_VOLUME
    b.ne .Lpi4_storage_record_read_plan_invalid
    tst w4, #PI4_STORAGE_DIRENT_ATTR_DIRECTORY
    b.ne .Lpi4_storage_record_read_plan_invalid
    str x4, [x2, #8]
    PI4_STORAGE_LOAD_LE16 w4, x0, PI4_STORAGE_DIRENT_CLUSTER_HI_OFF, w5
    lsl x4, x4, #16
    PI4_STORAGE_LOAD_LE16 w5, x0, PI4_STORAGE_DIRENT_CLUSTER_LO_OFF, w6
    orr x4, x4, x5
    str x4, [x2, #16]
    PI4_STORAGE_LOAD_LE32 w5, x0, PI4_STORAGE_DIRENT_SIZE_OFF, w6
    str x5, [x2, #24]
    mov x6, xzr
    mov x7, xzr
    mov x8, xzr
    cmp x4, #2
    b.lo .Lpi4_storage_record_read_plan_invalid
    cbz x5, .Lpi4_storage_record_read_plan_invalid
    cbz x10, .Lpi4_storage_record_read_plan_invalid
    cbz x11, .Lpi4_storage_record_read_plan_invalid
    cbz x12, .Lpi4_storage_record_read_plan_invalid
    cbz x13, .Lpi4_storage_record_read_plan_invalid
    sub x14, x4, #2
    cmp x14, x13
    b.hs .Lpi4_storage_record_read_plan_invalid
    cmp x5, #PI4_STORAGE_READABLE_FILE_MIN_BYTES
    b.lo .Lpi4_storage_record_read_plan_invalid
    madd x6, x14, x11, x10
    sub x15, x13, x14
    mul x15, x15, x11
    add x14, x5, x12
    sub x14, x14, #1
    udiv x7, x14, x12
    cmp x7, x15
    b.hi .Lpi4_storage_record_read_plan_invalid
    mov x8, x5
    cbz x7, .Lpi4_storage_record_read_plan_invalid
    cbz x8, .Lpi4_storage_record_read_plan_invalid
    ldr w4, =VIBE_PI4_STORAGE_FILE_OK
    str w4, [x2]
    mov w0, #1
    b .Lpi4_storage_record_read_plan_done
.Lpi4_storage_record_read_plan_invalid:
    mov w0, wzr
.Lpi4_storage_record_read_plan_done:
    str x6, [x2, #32]
    str x7, [x2, #40]
    str x8, [x2, #48]
    str xzr, [x2, #56]
    ret
.size pi4_storage_record_file_read_metadata, . - pi4_storage_record_file_read_metadata

.type pi4_storage_record_file_metadata, %function
pi4_storage_record_file_metadata:
    mov x10, x4
    mov x11, x5
    mov x12, x6
    mov x13, x7
    str x1, [x3]
    ldrb w4, [x0, #PI4_STORAGE_DIRENT_ATTR_OFF]
    cmp w4, #PI4_STORAGE_DIRENT_ATTR_LONG
    b.eq .Lpi4_storage_record_file_plan_invalid
    tst w4, #PI4_STORAGE_DIRENT_ATTR_VOLUME
    b.ne .Lpi4_storage_record_file_plan_invalid
    tst w4, #PI4_STORAGE_DIRENT_ATTR_DIRECTORY
    b.ne .Lpi4_storage_record_file_plan_invalid
    str x4, [x3, #8]
    PI4_STORAGE_LOAD_LE16 w4, x0, PI4_STORAGE_DIRENT_CLUSTER_HI_OFF, w5
    lsl x4, x4, #16
    PI4_STORAGE_LOAD_LE16 w5, x0, PI4_STORAGE_DIRENT_CLUSTER_LO_OFF, w6
    orr x4, x4, x5
    str x4, [x3, #16]
    PI4_STORAGE_LOAD_LE32 w5, x0, PI4_STORAGE_DIRENT_SIZE_OFF, w6
    str x5, [x3, #24]
    mov x6, xzr
    mov x7, xzr
    mov x8, xzr
    cmp x4, #2
    b.lo .Lpi4_storage_record_file_plan_invalid
    cbz x5, .Lpi4_storage_record_file_plan_invalid
    cbz x10, .Lpi4_storage_record_file_plan_invalid
    cbz x11, .Lpi4_storage_record_file_plan_invalid
    cbz x12, .Lpi4_storage_record_file_plan_invalid
    cbz x13, .Lpi4_storage_record_file_plan_invalid
    sub x14, x4, #2
    cmp x14, x13
    b.hs .Lpi4_storage_record_file_plan_invalid
    madd x6, x14, x11, x10
    sub x15, x13, x14
    mul x15, x15, x11
    add x14, x5, x12
    sub x14, x14, #1
    udiv x7, x14, x12
    cmp x7, x15
    b.hi .Lpi4_storage_record_file_plan_invalid
    mov x8, x5
    cbz x7, .Lpi4_storage_record_file_plan_invalid
    cbz x8, .Lpi4_storage_record_file_plan_invalid
    ldr w4, =VIBE_PI4_STORAGE_FILE_OK
    str w4, [x2]
    mov w0, #1
    b .Lpi4_storage_record_file_plan_done
.Lpi4_storage_record_file_plan_invalid:
    mov w0, wzr
.Lpi4_storage_record_file_plan_done:
    str x6, [x3, #32]
    str x7, [x3, #40]
    str x8, [x3, #48]
    str xzr, [x3, #56]
    ret
.size pi4_storage_record_file_metadata, . - pi4_storage_record_file_metadata

// x0 = directory buffer, x1 = directory bytes, x2 = directory kind:
// 0 = /PROOF, 1 = /ASSETS, 2 = /ASSETS/MAPS, 3 = /ASSETS/TEXTURES, 4 = /ID1,
// 5 = /SYSTEM, 6 = /APPS, 7..8 = recorded /APPS child records.
// Returns w0 = number of expected entries recorded from the directory buffer.
.global pi4_storage_parse_asset_dir
.type pi4_storage_parse_asset_dir, %function
pi4_storage_parse_asset_dir:
    stp x29, x30, [sp, #-96]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]

    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x24, xzr
    cbz x19, .Lpi4_storage_asset_dir_done
    cmp x20, #PI4_STORAGE_DIRENT_BYTES
    b.lo .Lpi4_storage_asset_dir_done

    adr x0, pi4_storage_status_bpb_data_lba
    ldr x25, [x0]
    adr x0, pi4_storage_status_bpb_sectors_per_cluster
    ldr x26, [x0]
    adr x0, pi4_storage_status_bpb_bytes_per_sector
    ldr x27, [x0]
    adr x0, pi4_storage_status_bpb_cluster_count
    ldr x28, [x0]

    lsr x20, x20, #5
    mov x22, x19
    mov x23, xzr
.Lpi4_storage_asset_dir_loop:
    cmp x23, x20
    b.hs .Lpi4_storage_asset_dir_done
    ldrb w0, [x22]
    cbz w0, .Lpi4_storage_asset_dir_done
    cmp w0, #PI4_STORAGE_DIRENT_DELETED
    b.eq .Lpi4_storage_asset_dir_next
    ldrb w0, [x22, #PI4_STORAGE_DIRENT_ATTR_OFF]
    cmp w0, #PI4_STORAGE_DIRENT_ATTR_LONG
    b.eq .Lpi4_storage_asset_dir_next
    tst w0, #PI4_STORAGE_DIRENT_ATTR_VOLUME
    b.ne .Lpi4_storage_asset_dir_next

    cmp x21, #0
    b.eq .Lpi4_storage_asset_dir_kind_proof
    cmp x21, #1
    b.eq .Lpi4_storage_asset_dir_kind_assets
    cmp x21, #2
    b.eq .Lpi4_storage_asset_dir_kind_maps
    cmp x21, #3
    b.eq .Lpi4_storage_asset_dir_kind_textures
    cmp x21, #4
    b.eq .Lpi4_storage_asset_dir_kind_id1
    cmp x21, #5
    b.eq .Lpi4_storage_asset_dir_kind_system
    cmp x21, #6
    b.eq .Lpi4_storage_asset_dir_kind_apps
    sub x3, x21, #PI4_STORAGE_APP_RECORD_KIND_BASE
    cmp x3, #PI4_STORAGE_APP_RECORD_COUNT
    b.lo .Lpi4_storage_asset_dir_kind_app_record
    b .Lpi4_storage_asset_dir_next

.Lpi4_storage_asset_dir_kind_proof:
    tst w0, #PI4_STORAGE_DIRENT_ATTR_DIRECTORY
    b.ne .Lpi4_storage_asset_dir_next
    mov x0, x22
    adr x1, pi4_storage_name_manifest_txt
    bl pi4_storage_match_short_name
    cbz w0, .Lpi4_storage_asset_dir_next
    mov x0, x22
    mov x1, x23
    adr x2, pi4_storage_status_manifest_txt
    mov x4, x25
    mov x5, x26
    mov x6, x27
    mov x7, x28
    bl pi4_storage_record_file_read_metadata
    cbz w0, .Lpi4_storage_asset_dir_next
    adr x0, pi4_storage_status_assets_coverage_mask
    ldr x1, [x0]
    orr x1, x1, #2
    str x1, [x0]
    add x24, x24, #1
    b .Lpi4_storage_asset_dir_next

.Lpi4_storage_asset_dir_kind_assets:
    tst w0, #PI4_STORAGE_DIRENT_ATTR_DIRECTORY
    b.ne .Lpi4_storage_asset_dir_assets_dir
    mov x0, x22
    adr x1, pi4_storage_name_readme_txt
    bl pi4_storage_match_short_name
    cbz w0, .Lpi4_storage_asset_dir_next
    mov x0, x22
    mov x1, x23
    adr x2, pi4_storage_status_asset_readme
    mov x4, x25
    mov x5, x26
    mov x6, x27
    mov x7, x28
    bl pi4_storage_record_file_read_metadata
    cbz w0, .Lpi4_storage_asset_dir_next
    bl pi4_storage_note_default_asset_file
    add x24, x24, #1
    b .Lpi4_storage_asset_dir_next

.Lpi4_storage_asset_dir_assets_dir:
    mov x0, x22
    adr x1, pi4_storage_name_maps_dir
    bl pi4_storage_match_short_name
    cbnz w0, .Lpi4_storage_asset_dir_record_maps
    mov x0, x22
    adr x1, pi4_storage_name_textures_dir
    bl pi4_storage_match_short_name
    cbnz w0, .Lpi4_storage_asset_dir_record_textures
    b .Lpi4_storage_asset_dir_next

.Lpi4_storage_asset_dir_record_maps:
    mov x0, x22
    mov x1, x23
    adr x2, pi4_storage_status_asset_maps_dir
    bl pi4_storage_record_dirent_metadata4
    bl pi4_storage_note_nested_asset_dir
    add x24, x24, #1
    b .Lpi4_storage_asset_dir_next

.Lpi4_storage_asset_dir_record_textures:
    mov x0, x22
    mov x1, x23
    adr x2, pi4_storage_status_asset_textures_dir
    bl pi4_storage_record_dirent_metadata4
    bl pi4_storage_note_nested_asset_dir
    add x24, x24, #1
    b .Lpi4_storage_asset_dir_next

.Lpi4_storage_asset_dir_kind_maps:
    tst w0, #PI4_STORAGE_DIRENT_ATTR_DIRECTORY
    b.ne .Lpi4_storage_asset_dir_next
    mov x0, x22
    adr x1, pi4_storage_name_e1m1_map
    bl pi4_storage_match_short_name
    cbz w0, .Lpi4_storage_asset_dir_next
    mov x0, x22
    mov x1, x23
    adr x2, pi4_storage_status_asset_map
    mov x4, x25
    mov x5, x26
    mov x6, x27
    mov x7, x28
    bl pi4_storage_record_file_read_metadata
    cbz w0, .Lpi4_storage_asset_dir_next
    bl pi4_storage_note_default_asset_file
    add x24, x24, #1
    b .Lpi4_storage_asset_dir_next

.Lpi4_storage_asset_dir_kind_textures:
    tst w0, #PI4_STORAGE_DIRENT_ATTR_DIRECTORY
    b.ne .Lpi4_storage_asset_dir_next
    mov x0, x22
    adr x1, pi4_storage_name_pal0_bin
    bl pi4_storage_match_short_name
    cbz w0, .Lpi4_storage_asset_dir_next
    mov x0, x22
    mov x1, x23
    adr x2, pi4_storage_status_asset_palette
    mov x4, x25
    mov x5, x26
    mov x6, x27
    mov x7, x28
    bl pi4_storage_record_file_read_metadata
    cbz w0, .Lpi4_storage_asset_dir_next
    bl pi4_storage_note_default_asset_file
    add x24, x24, #1
    b .Lpi4_storage_asset_dir_next

.Lpi4_storage_asset_dir_kind_id1:
    tst w0, #PI4_STORAGE_DIRENT_ATTR_DIRECTORY
    b.ne .Lpi4_storage_asset_dir_next
    mov x0, x22
    adr x1, pi4_storage_name_pak0_pak
    bl pi4_storage_match_short_name
    cbz w0, .Lpi4_storage_asset_dir_next
    mov x0, x22
    mov x1, x23
    adr x2, pi4_storage_status_pak0_pak
    mov x4, x25
    mov x5, x26
    mov x6, x27
    mov x7, x28
    bl pi4_storage_record_file_read_metadata
    cbz w0, .Lpi4_storage_asset_dir_next
    adr x0, pi4_storage_status_assets_coverage_mask
    ldr x1, [x0]
    orr x1, x1, #4
    str x1, [x0]
    add x24, x24, #1
    b .Lpi4_storage_asset_dir_next

.Lpi4_storage_asset_dir_kind_system:
    tst w0, #PI4_STORAGE_DIRENT_ATTR_DIRECTORY
    b.ne .Lpi4_storage_asset_dir_next
    mov x0, x22
    adr x1, pi4_storage_name_init_elf
    bl pi4_storage_match_short_name
    cbnz w0, .Lpi4_storage_asset_dir_record_system_init
    mov x0, x22
    adr x1, pi4_storage_name_abiprobe_elf
    bl pi4_storage_match_short_name
    cbnz w0, .Lpi4_storage_asset_dir_record_system_abiprobe
    b .Lpi4_storage_asset_dir_next

.Lpi4_storage_asset_dir_record_system_init:
    mov x0, x22
    mov x1, x23
    adr x2, pi4_storage_status_init_elf
    adr x3, pi4_storage_status_init_elf_entry_index
    mov x4, x25
    mov x5, x26
    mov x6, x27
    mov x7, x28
    bl pi4_storage_record_file_metadata
    cbz w0, .Lpi4_storage_asset_dir_next
    add x24, x24, #1
    b .Lpi4_storage_asset_dir_next

.Lpi4_storage_asset_dir_record_system_abiprobe:
    mov x0, x22
    mov x1, x23
    adr x2, pi4_storage_status_system_abiprobe
    bl pi4_storage_record_dirent_metadata4
    add x24, x24, #1
    b .Lpi4_storage_asset_dir_next

.Lpi4_storage_asset_dir_kind_apps:
    tst w0, #PI4_STORAGE_DIRENT_ATTR_DIRECTORY
    b.ne .Lpi4_storage_asset_dir_apps_dir
    mov x0, x22
    adr x1, pi4_storage_name_index_txt
    bl pi4_storage_match_short_name
    cbz w0, .Lpi4_storage_asset_dir_next
    mov x0, x22
    mov x1, x23
    adr x2, pi4_storage_status_app_index
    mov x4, x25
    mov x5, x26
    mov x6, x27
    mov x7, x28
    bl pi4_storage_record_file_read_metadata
    cbz w0, .Lpi4_storage_asset_dir_next
    add x24, x24, #1
    b .Lpi4_storage_asset_dir_next

.Lpi4_storage_asset_dir_apps_dir:
    ldrb w3, [x22]
    cmp w3, #0x2e
    b.eq .Lpi4_storage_asset_dir_next
    bl pi4_storage_find_free_app_dir_record
    cbz x0, .Lpi4_storage_asset_dir_next
    mov x19, x0
    mov x0, x22
    bl pi4_storage_copy_short_name
    mov x0, x22
    mov x1, x23
    mov x2, x19
    bl pi4_storage_record_dirent_metadata4
    add x24, x24, #1
    b .Lpi4_storage_asset_dir_next

.Lpi4_storage_asset_dir_kind_app_record:
    tst w0, #PI4_STORAGE_DIRENT_ATTR_DIRECTORY
    b.ne .Lpi4_storage_asset_dir_next
    mov x0, x22
    adr x1, pi4_storage_name_app_elf
    bl pi4_storage_match_short_name
    cbnz w0, .Lpi4_storage_asset_dir_record_app_elf
    mov x0, x22
    adr x1, pi4_storage_name_app_txt
    bl pi4_storage_match_short_name
    cbnz w0, .Lpi4_storage_asset_dir_record_app_txt
    b .Lpi4_storage_asset_dir_next

.Lpi4_storage_asset_dir_record_app_elf:
    sub x0, x21, #PI4_STORAGE_APP_RECORD_KIND_BASE
    bl pi4_storage_app_record
    cbz x0, .Lpi4_storage_asset_dir_next
    ldr x2, [x0, #PI4_STORAGE_APP_RECORD_ELF_STATUS_OFF]
    ldr x3, [x0, #PI4_STORAGE_APP_RECORD_ELF_ENTRY_OFF]
    mov x0, x22
    mov x1, x23
    mov x4, x25
    mov x5, x26
    mov x6, x27
    mov x7, x28
    bl pi4_storage_record_file_metadata
    cbz w0, .Lpi4_storage_asset_dir_next
    add x24, x24, #1
    b .Lpi4_storage_asset_dir_next

.Lpi4_storage_asset_dir_record_app_txt:
    sub x0, x21, #PI4_STORAGE_APP_RECORD_KIND_BASE
    bl pi4_storage_app_record
    cbz x0, .Lpi4_storage_asset_dir_next
    ldr x2, [x0, #PI4_STORAGE_APP_RECORD_MANIFEST_OFF]
    mov x0, x22
    mov x1, x23
    mov x4, x25
    mov x5, x26
    mov x6, x27
    mov x7, x28
    bl pi4_storage_record_file_read_metadata
    cbz w0, .Lpi4_storage_asset_dir_next
    add x24, x24, #1

.Lpi4_storage_asset_dir_next:
    add x22, x22, #PI4_STORAGE_DIRENT_BYTES
    add x23, x23, #1
    b .Lpi4_storage_asset_dir_loop

.Lpi4_storage_asset_dir_done:
    mov w0, w24
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret
.size pi4_storage_parse_asset_dir, . - pi4_storage_parse_asset_dir

.type pi4_storage_find_free_app_dir_record, %function
pi4_storage_find_free_app_dir_record:
    adr x2, pi4_storage_app_records
    mov x3, #PI4_STORAGE_APP_RECORD_COUNT
.Lpi4_storage_find_free_app_dir_record_loop:
    cbz x3, .Lpi4_storage_find_free_app_dir_record_none
    ldr x0, [x2, #PI4_STORAGE_APP_RECORD_DIR_STATUS_OFF]
    ldr x4, [x0]
    cbz x4, .Lpi4_storage_find_free_app_dir_record_found
    add x2, x2, #PI4_STORAGE_APP_RECORD_BYTES
    sub x3, x3, #1
    b .Lpi4_storage_find_free_app_dir_record_loop
.Lpi4_storage_find_free_app_dir_record_found:
    ldr x1, [x2, #PI4_STORAGE_APP_RECORD_NAME_OFF]
    ret
.Lpi4_storage_find_free_app_dir_record_none:
    mov x0, xzr
    mov x1, xzr
    ret
.size pi4_storage_find_free_app_dir_record, . - pi4_storage_find_free_app_dir_record

.type pi4_storage_app_record, %function
pi4_storage_app_record:
    cmp x0, #PI4_STORAGE_APP_RECORD_COUNT
    b.hs .Lpi4_storage_app_record_bad
    adr x2, pi4_storage_app_records
    mov x1, #PI4_STORAGE_APP_RECORD_BYTES
    madd x0, x0, x1, x2
    ret
.Lpi4_storage_app_record_bad:
    mov x0, xzr
    ret
.size pi4_storage_app_record, . - pi4_storage_app_record

.type pi4_storage_note_default_asset_file, %function
pi4_storage_note_default_asset_file:
    adr x0, pi4_storage_status_assets_default_file_count
    ldr x1, [x0]
    add x1, x1, #1
    str x1, [x0]
    adr x0, pi4_storage_status_assets_coverage_mask
    ldr x1, [x0]
    orr x1, x1, #8
    str x1, [x0]
    ret
.size pi4_storage_note_default_asset_file, . - pi4_storage_note_default_asset_file

.type pi4_storage_note_nested_asset_dir, %function
pi4_storage_note_nested_asset_dir:
    adr x0, pi4_storage_status_assets_nested_dir_count
    ldr x1, [x0]
    add x1, x1, #1
    str x1, [x0]
    ret
.size pi4_storage_note_nested_asset_dir, . - pi4_storage_note_nested_asset_dir

.section .rodata.pi4_storage, "a", %progbits
.balign 1
pi4_storage_name_init_elf:
    .ascii "INIT    ELF"
pi4_storage_name_kernel8_img:
    .ascii "KERNEL8 IMG"
pi4_storage_name_config_txt:
    .ascii "CONFIG  TXT"
pi4_storage_name_abiprobe_elf:
    .ascii "ABIPROBEELF"
pi4_storage_name_doom1_wad:
    .ascii "DOOM1   WAD"
pi4_storage_name_proof_dir:
    .ascii "PROOF      "
pi4_storage_name_assets_dir:
    .ascii "ASSETS     "
pi4_storage_name_id1_dir:
    .ascii "ID1        "
pi4_storage_name_manifest_txt:
    .ascii "MANIFESTTXT"
pi4_storage_name_readme_txt:
    .ascii "README  TXT"
pi4_storage_name_maps_dir:
    .ascii "MAPS       "
pi4_storage_name_e1m1_map:
    .ascii "E1M1    MAP"
pi4_storage_name_textures_dir:
    .ascii "TEXTURES   "
pi4_storage_name_pal0_bin:
    .ascii "PAL0    BIN"
pi4_storage_name_pak0_pak:
    .ascii "PAK0    PAK"
pi4_storage_name_system_dir:
    .ascii "SYSTEM     "
pi4_storage_name_apps_dir:
    .ascii "APPS       "
pi4_storage_name_index_txt:
    .ascii "INDEX   TXT"
pi4_storage_name_app_elf:
    .ascii "APP     ELF"
pi4_storage_name_app_txt:
    .ascii "APP     TXT"
.balign 8
pi4_storage_app_records:
    .quad pi4_storage_status_app0_dir
    .quad pi4_storage_status_app0_dir_name
    .quad pi4_storage_status_app0_elf
    .quad pi4_storage_status_app0_elf_entry_index
    .quad pi4_storage_status_app0_manifest
    .quad pi4_storage_status_app1_dir
    .quad pi4_storage_status_app1_dir_name
    .quad pi4_storage_status_app1_elf
    .quad pi4_storage_status_app1_elf_entry_index
    .quad pi4_storage_status_app1_manifest

.section .pi4_storage_status, "aw", %progbits
.balign 8
.global pi4_storage_status_words
.type pi4_storage_status_words, %object
pi4_storage_status_words:
pi4_storage_status_magic:
    .word VIBE_PI4_STORAGE_MAGIC
pi4_storage_status_version:
    .word VIBE_PI4_STORAGE_VERSION
.global pi4_storage_status_pi4sd
pi4_storage_status_pi4sd:
    .word VIBE_PI4_STORAGE_WAIT
.global pi4_storage_status_pi4fat
pi4_storage_status_pi4fat:
    .word VIBE_PI4_STORAGE_WAIT
.global pi4_storage_status_pi4vfs
pi4_storage_status_pi4vfs:
    .word VIBE_PI4_STORAGE_WAIT
.global pi4_storage_status_mbr
pi4_storage_status_mbr:
    .word VIBE_PI4_STORAGE_WAIT
.global pi4_storage_status_bpb
pi4_storage_status_bpb:
    .word VIBE_PI4_STORAGE_WAIT
.global pi4_storage_status_fat_type
pi4_storage_status_fat_type:
    .word VIBE_PI4_STORAGE_WAIT
.global pi4_storage_status_root
pi4_storage_status_root:
    .word VIBE_PI4_STORAGE_WAIT
.global pi4_storage_status_init_elf
pi4_storage_status_init_elf:
    .word VIBE_PI4_STORAGE_WAIT
.global pi4_storage_status_app0_elf
pi4_storage_status_app0_elf:
    .word VIBE_PI4_STORAGE_WAIT
.global pi4_storage_status_app1_elf
pi4_storage_status_app1_elf:
    .word VIBE_PI4_STORAGE_WAIT
.global pi4_storage_status_block
pi4_storage_status_block:
    .word VIBE_PI4_STORAGE_WAIT
.global pi4_storage_status_block_controller
pi4_storage_status_block_controller:
    .word VIBE_PI4_STORAGE_ENOSYS

.balign 8
pi4_storage_status_values_start:
pi4_storage_block_values_start:
.global pi4_storage_status_block_lba
pi4_storage_status_block_lba:
    .quad 0
.global pi4_storage_status_block_count
pi4_storage_status_block_count:
    .quad 0
.global pi4_storage_status_block_buffer
pi4_storage_status_block_buffer:
    .quad 0
.global pi4_storage_status_block_max_count
pi4_storage_status_block_max_count:
    .quad 0
.global pi4_storage_status_block_bytes
pi4_storage_status_block_bytes:
    .quad 0
.global pi4_storage_status_block_result
pi4_storage_status_block_result:
    .quad 0
pi4_storage_block_pio_values_start:
.global pi4_storage_status_block_command
pi4_storage_status_block_command:
    .quad 0
.global pi4_storage_status_block_transfer_mode
pi4_storage_status_block_transfer_mode:
    .quad 0
.global pi4_storage_status_block_argument
pi4_storage_status_block_argument:
    .quad 0
.global pi4_storage_status_block_copied_bytes
pi4_storage_status_block_copied_bytes:
    .quad 0
.global pi4_storage_status_block_copied_sectors
pi4_storage_status_block_copied_sectors:
    .quad 0
.global pi4_storage_status_block_pio_words
pi4_storage_status_block_pio_words:
    .quad 0
.global pi4_storage_status_block_int_status
pi4_storage_status_block_int_status:
    .quad 0
.global pi4_storage_status_block_error_status
pi4_storage_status_block_error_status:
    .quad 0
.global pi4_storage_status_block_present_before
pi4_storage_status_block_present_before:
    .quad 0
.global pi4_storage_status_block_present_after
pi4_storage_status_block_present_after:
    .quad 0
pi4_storage_block_pio_values_end:
pi4_storage_block_values_end:
pi4_storage_sdctl_values_start:
.global pi4_storage_status_sdctl_legacy_base
pi4_storage_status_sdctl_legacy_base:
    .quad 0
.global pi4_storage_status_sdctl_arm_base
pi4_storage_status_sdctl_arm_base:
    .quad 0
.global pi4_storage_status_sdctl_span
pi4_storage_status_sdctl_span:
    .quad 0
.global pi4_storage_status_sdctl_host_version
pi4_storage_status_sdctl_host_version:
    .quad 0
.global pi4_storage_status_sdctl_caps0
pi4_storage_status_sdctl_caps0:
    .quad 0
.global pi4_storage_status_sdctl_caps1
pi4_storage_status_sdctl_caps1:
    .quad 0
.global pi4_storage_status_sdctl_present
pi4_storage_status_sdctl_present:
    .quad 0
.global pi4_storage_status_sdctl_host_control
pi4_storage_status_sdctl_host_control:
    .quad 0
.global pi4_storage_status_sdctl_power_control
pi4_storage_status_sdctl_power_control:
    .quad 0
.global pi4_storage_status_sdctl_clock_control
pi4_storage_status_sdctl_clock_control:
    .quad 0
.global pi4_storage_status_sdctl_software_reset
pi4_storage_status_sdctl_software_reset:
    .quad 0
.global pi4_storage_status_sdctl_int_status
pi4_storage_status_sdctl_int_status:
    .quad 0
.global pi4_storage_status_sdctl_ocr
pi4_storage_status_sdctl_ocr:
    .quad 0
.global pi4_storage_status_sdctl_rca
pi4_storage_status_sdctl_rca:
    .quad 0
.global pi4_storage_status_sdctl_block_addressing
pi4_storage_status_sdctl_block_addressing:
    .quad 0
.global pi4_storage_status_sdctl_card_ready
pi4_storage_status_sdctl_card_ready:
    .quad 0
pi4_storage_sdctl_values_end:
.global pi4_storage_boot_mbr_sector_buffer
pi4_storage_boot_mbr_sector_buffer:
    .quad 0
.global pi4_storage_boot_bpb_sector_buffer
pi4_storage_boot_bpb_sector_buffer:
    .quad 0
.global pi4_storage_boot_root_dir_buffer_ptr
pi4_storage_boot_root_dir_buffer_ptr:
    .quad 0
.global pi4_storage_boot_root_dir_buffer_bytes
pi4_storage_boot_root_dir_buffer_bytes:
    .quad 0
.global pi4_storage_boot_parse_mask
pi4_storage_boot_parse_mask:
    .quad 0
pi4_storage_mbr_values_start:
.global pi4_storage_status_mbr_signature
pi4_storage_status_mbr_signature:
    .quad 0
.global pi4_storage_status_mbr_part_index
pi4_storage_status_mbr_part_index:
    .quad 0
.global pi4_storage_status_mbr_part_boot
pi4_storage_status_mbr_part_boot:
    .quad 0
.global pi4_storage_status_mbr_part_type
pi4_storage_status_mbr_part_type:
    .quad 0
.global pi4_storage_status_mbr_part_lba
pi4_storage_status_mbr_part_lba:
    .quad 0
.global pi4_storage_status_mbr_part_sectors
pi4_storage_status_mbr_part_sectors:
    .quad 0
pi4_storage_mbr_values_end:

pi4_storage_bpb_values_start:
.global pi4_storage_status_bpb_signature
pi4_storage_status_bpb_signature:
    .quad 0
.global pi4_storage_status_bpb_partition_lba
pi4_storage_status_bpb_partition_lba:
    .quad 0
.global pi4_storage_status_bpb_bytes_per_sector
pi4_storage_status_bpb_bytes_per_sector:
    .quad 0
.global pi4_storage_status_bpb_sectors_per_cluster
pi4_storage_status_bpb_sectors_per_cluster:
    .quad 0
.global pi4_storage_status_bpb_reserved_sectors
pi4_storage_status_bpb_reserved_sectors:
    .quad 0
.global pi4_storage_status_bpb_fat_count
pi4_storage_status_bpb_fat_count:
    .quad 0
.global pi4_storage_status_bpb_root_entries
pi4_storage_status_bpb_root_entries:
    .quad 0
.global pi4_storage_status_bpb_total_sectors
pi4_storage_status_bpb_total_sectors:
    .quad 0
.global pi4_storage_status_bpb_fat_sectors
pi4_storage_status_bpb_fat_sectors:
    .quad 0
.global pi4_storage_status_bpb_root_dir_sectors
pi4_storage_status_bpb_root_dir_sectors:
    .quad 0
.global pi4_storage_status_bpb_fat_span_sectors
pi4_storage_status_bpb_fat_span_sectors:
    .quad 0
.global pi4_storage_status_bpb_first_data_rel_lba
pi4_storage_status_bpb_first_data_rel_lba:
    .quad 0
.global pi4_storage_status_bpb_cluster_count
pi4_storage_status_bpb_cluster_count:
    .quad 0
.global pi4_storage_status_bpb_fat0_lba
pi4_storage_status_bpb_fat0_lba:
    .quad 0
.global pi4_storage_status_bpb_root_dir_lba
pi4_storage_status_bpb_root_dir_lba:
    .quad 0
.global pi4_storage_status_bpb_data_lba
pi4_storage_status_bpb_data_lba:
    .quad 0
.global pi4_storage_status_bpb_hidden_sectors
pi4_storage_status_bpb_hidden_sectors:
    .quad 0
.global pi4_storage_status_bpb_root_cluster
pi4_storage_status_bpb_root_cluster:
    .quad 0
pi4_storage_bpb_values_end:
pi4_storage_root_values_start:
.global pi4_storage_status_root_dir_lba
pi4_storage_status_root_dir_lba:
    .quad 0
.global pi4_storage_status_root_dir_sectors
pi4_storage_status_root_dir_sectors:
    .quad 0
.global pi4_storage_status_root_cluster
pi4_storage_status_root_cluster:
    .quad 0
.global pi4_storage_status_root_data_lba
pi4_storage_status_root_data_lba:
    .quad 0
.global pi4_storage_status_root_entries_scanned
pi4_storage_status_root_entries_scanned:
    .quad 0
.global pi4_storage_status_root_buffer_bytes
pi4_storage_status_root_buffer_bytes:
    .quad 0
.global pi4_storage_status_root_found_mask
pi4_storage_status_root_found_mask:
    .quad 0
.global pi4_storage_status_init_elf_entry_index
pi4_storage_status_init_elf_entry_index:
    .quad 0
.global pi4_storage_status_init_elf_attr
pi4_storage_status_init_elf_attr:
    .quad 0
.global pi4_storage_status_init_elf_cluster
pi4_storage_status_init_elf_cluster:
    .quad 0
.global pi4_storage_status_init_elf_size
pi4_storage_status_init_elf_size:
    .quad 0
.global pi4_storage_status_init_elf_plan_lba
pi4_storage_status_init_elf_plan_lba:
    .quad 0
.global pi4_storage_status_init_elf_plan_sectors
pi4_storage_status_init_elf_plan_sectors:
    .quad 0
.global pi4_storage_status_init_elf_plan_bytes
pi4_storage_status_init_elf_plan_bytes:
    .quad 0
.global pi4_storage_status_init_elf_read_count
pi4_storage_status_init_elf_read_count:
    .quad 0
.global pi4_storage_status_app0_elf_entry_index
pi4_storage_status_app0_elf_entry_index:
    .quad 0
.global pi4_storage_status_app0_elf_attr
pi4_storage_status_app0_elf_attr:
    .quad 0
.global pi4_storage_status_app0_elf_cluster
pi4_storage_status_app0_elf_cluster:
    .quad 0
.global pi4_storage_status_app0_elf_size
pi4_storage_status_app0_elf_size:
    .quad 0
.global pi4_storage_status_app0_elf_plan_lba
pi4_storage_status_app0_elf_plan_lba:
    .quad 0
.global pi4_storage_status_app0_elf_plan_sectors
pi4_storage_status_app0_elf_plan_sectors:
    .quad 0
.global pi4_storage_status_app0_elf_plan_bytes
pi4_storage_status_app0_elf_plan_bytes:
    .quad 0
.global pi4_storage_status_app0_elf_read_count
pi4_storage_status_app0_elf_read_count:
    .quad 0
.global pi4_storage_status_app1_elf_entry_index
pi4_storage_status_app1_elf_entry_index:
    .quad 0
.global pi4_storage_status_app1_elf_attr
pi4_storage_status_app1_elf_attr:
    .quad 0
.global pi4_storage_status_app1_elf_cluster
pi4_storage_status_app1_elf_cluster:
    .quad 0
.global pi4_storage_status_app1_elf_size
pi4_storage_status_app1_elf_size:
    .quad 0
.global pi4_storage_status_app1_elf_plan_lba
pi4_storage_status_app1_elf_plan_lba:
    .quad 0
.global pi4_storage_status_app1_elf_plan_sectors
pi4_storage_status_app1_elf_plan_sectors:
    .quad 0
.global pi4_storage_status_app1_elf_plan_bytes
pi4_storage_status_app1_elf_plan_bytes:
    .quad 0
.global pi4_storage_status_app1_elf_read_count
pi4_storage_status_app1_elf_read_count:
    .quad 0
.global pi4_storage_status_kernel8_img
pi4_storage_status_kernel8_img:
    .quad 0
    .quad 0
    .quad 0
    .quad 0
.global pi4_storage_status_config_txt
pi4_storage_status_config_txt:
    .quad 0
    .quad 0
    .quad 0
    .quad 0
.global pi4_storage_status_abiprobe_elf
pi4_storage_status_abiprobe_elf:
    .quad 0
    .quad 0
    .quad 0
    .quad 0
.global pi4_storage_status_doom1_wad
pi4_storage_status_doom1_wad:
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
.global pi4_storage_status_proof_dir
pi4_storage_status_proof_dir:
    .quad 0
    .quad 0
    .quad 0
    .quad 0
.global pi4_storage_status_manifest_txt
pi4_storage_status_manifest_txt:
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
.global pi4_storage_status_assets_dir
pi4_storage_status_assets_dir:
    .quad 0
    .quad 0
    .quad 0
    .quad 0
.global pi4_storage_status_asset_readme
pi4_storage_status_asset_readme:
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
.global pi4_storage_status_asset_maps_dir
pi4_storage_status_asset_maps_dir:
    .quad 0
    .quad 0
    .quad 0
    .quad 0
.global pi4_storage_status_asset_map
pi4_storage_status_asset_map:
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
.global pi4_storage_status_asset_textures_dir
pi4_storage_status_asset_textures_dir:
    .quad 0
    .quad 0
    .quad 0
    .quad 0
.global pi4_storage_status_asset_palette
pi4_storage_status_asset_palette:
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
.global pi4_storage_status_id1_dir
pi4_storage_status_id1_dir:
    .quad 0
    .quad 0
    .quad 0
    .quad 0
.global pi4_storage_status_pak0_pak
pi4_storage_status_pak0_pak:
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
.global pi4_storage_status_system_dir
pi4_storage_status_system_dir:
    .quad 0
    .quad 0
    .quad 0
    .quad 0
.global pi4_storage_status_system_abiprobe
pi4_storage_status_system_abiprobe:
    .quad 0
    .quad 0
    .quad 0
    .quad 0
.global pi4_storage_status_apps_dir
pi4_storage_status_apps_dir:
    .quad 0
    .quad 0
    .quad 0
    .quad 0
.global pi4_storage_status_app_index
pi4_storage_status_app_index:
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
.global pi4_storage_status_app0_dir
pi4_storage_status_app0_dir:
    .quad 0
    .quad 0
    .quad 0
    .quad 0
.global pi4_storage_status_app0_dir_name
pi4_storage_status_app0_dir_name:
    .skip 16
    .balign 8
.global pi4_storage_status_app0_manifest
pi4_storage_status_app0_manifest:
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
.global pi4_storage_status_app1_dir
pi4_storage_status_app1_dir:
    .quad 0
    .quad 0
    .quad 0
    .quad 0
.global pi4_storage_status_app1_dir_name
pi4_storage_status_app1_dir_name:
    .skip 16
    .balign 8
.global pi4_storage_status_app1_manifest
pi4_storage_status_app1_manifest:
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
.global pi4_storage_status_assets_summary
pi4_storage_status_assets_summary:
.global pi4_storage_status_assets_default_file_count
pi4_storage_status_assets_default_file_count:
    .quad 0
.global pi4_storage_status_assets_nested_dir_count
pi4_storage_status_assets_nested_dir_count:
    .quad 0
.global pi4_storage_status_assets_coverage_mask
pi4_storage_status_assets_coverage_mask:
    .quad 0
pi4_storage_root_values_end:
pi4_storage_status_values_end:
.size pi4_storage_status_words, . - pi4_storage_status_words

.section .bss.pi4_storage, "aw", %nobits
.balign 512
.global pi4_storage_block_scratch
.type pi4_storage_block_scratch, %object
pi4_storage_block_scratch:
    .zero PI4_STORAGE_BLOCK_SECTOR_BYTES
.size pi4_storage_block_scratch, . - pi4_storage_block_scratch

.balign 512
.global pi4_storage_boot_bpb_sector
.type pi4_storage_boot_bpb_sector, %object
pi4_storage_boot_bpb_sector:
    .zero PI4_STORAGE_BLOCK_SECTOR_BYTES
.size pi4_storage_boot_bpb_sector, . - pi4_storage_boot_bpb_sector

.balign 512
.global pi4_storage_root_dir_scratch
.type pi4_storage_root_dir_scratch, %object
pi4_storage_root_dir_scratch:
    .zero PI4_STORAGE_ROOT_BUFFER_BYTES
.size pi4_storage_root_dir_scratch, . - pi4_storage_root_dir_scratch
