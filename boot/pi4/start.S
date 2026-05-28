// Raspberry Pi 4 AArch64 kernel8.img boot stub for vibe-os.
//
// Firmware loads kernel8.img at 0x80000 and enters here with x0 holding the
// device-tree pointer on normal Pi firmware paths. This first rung is
// intentionally assembly-native: enter EL1, bring up one serial status channel,
// then publish guest-visible status as framebuffer, timer, and runtime paths
// come up.

.arch armv8-a

.equ PI4_KERNEL8_LOAD_ADDR,              0x00080000
.equ PI4_PERIPHERAL_BASE,               0xfe000000
.equ PI4_GPIO_BASE,                     0xfe200000
.equ PI4_UART0_BASE,                    0xfe201000
.equ PI4_PWM0_BASE,                     PI4_PERIPHERAL_BASE + 0x0020c000
.equ PI4_MAILBOX_BASE,                  PI4_PERIPHERAL_BASE + 0x0000b880
.equ PI4_PWM0_LEGACY_BASE,              0x7e20c000
.equ PI4_PWM0_SPAN,                     0x28

.equ PI4_GPIO_GPFSEL1,                  PI4_GPIO_BASE + 0x04
.equ PI4_GPIO_GPPUPPDN0,                PI4_GPIO_BASE + 0xe4
.equ PI4_PWM0_CTL,                      PI4_PWM0_BASE + 0x00
.equ PI4_PWM0_STA,                      PI4_PWM0_BASE + 0x04
.equ PI4_UART0_DR,                      PI4_UART0_BASE + 0x00
.equ PI4_UART0_FR,                      PI4_UART0_BASE + 0x18
.equ PI4_UART0_IBRD,                    PI4_UART0_BASE + 0x24
.equ PI4_UART0_FBRD,                    PI4_UART0_BASE + 0x28
.equ PI4_UART0_LCRH,                    PI4_UART0_BASE + 0x2c
.equ PI4_UART0_CR,                      PI4_UART0_BASE + 0x30
.equ PI4_UART0_IMSC,                    PI4_UART0_BASE + 0x38
.equ PI4_UART0_ICR,                     PI4_UART0_BASE + 0x44
.equ PI4_MAILBOX_READ,                  PI4_MAILBOX_BASE + 0x00
.equ PI4_MAILBOX_STATUS,                PI4_MAILBOX_BASE + 0x18
.equ PI4_MAILBOX_WRITE,                 PI4_MAILBOX_BASE + 0x20

.equ PI4_GIC_DIST_FALLBACK_BASE,        0xff841000
.equ PI4_GIC_CPU_FALLBACK_BASE,         0xff842000
.equ PI4_GIC_DIST_FALLBACK_LEN,         0x1000
.equ PI4_GIC_CPU_FALLBACK_LEN,          0x2000
.equ PI4_GICD_CTLR,                     0x000
.equ PI4_GICD_TYPER,                    0x004
.equ PI4_GICD_IIDR,                     0x008
.equ PI4_GICD_ISENABLER0,               0x100
.equ PI4_GICD_IPRIORITYR,               0x400
.equ PI4_GICC_CTLR,                     0x0000
.equ PI4_GICC_PMR,                      0x0004
.equ PI4_GICC_BPR,                      0x0008
.equ PI4_GICC_IAR,                      0x000c
.equ PI4_GICC_EOIR,                     0x0010
.equ PI4_GICC_IIDR,                     0x00fc
.equ PI4_TIMER_PPI_ID,                  30
.equ PI4_TIMER_TICK_DIV,                100

.equ PI4_UART_FR_TXFF,                  5
.equ PI4_UART_ICR_ALL,                  0x07ff
.equ PI4_UART_IBRD_115200,              26
.equ PI4_UART_FBRD_115200,              3
.equ PI4_UART_LCRH_8N1_FIFO,            0x70
.equ PI4_UART_CR_UARTEN_TXE_RXE,        0x0301
.equ PI4_MAILBOX_STATUS_EMPTY,          30
.equ PI4_MAILBOX_STATUS_FULL,           31
.equ PI4_MAILBOX_PROPERTY_CHANNEL,      8
.equ PI4_MAILBOX_RESPONSE_SUCCESS,      0x80000000
.equ PI4_MAILBOX_TAG_RESPONSE,          31
.equ PI4_MAILBOX_POLL_LIMIT,            0x00100000
.equ PI4_MAILBOX_TAG_GET_CLOCK_STATE,   0x00030001
.equ PI4_MAILBOX_TAG_GET_CLOCK_RATE,    0x00030002
.equ PI4_MAILBOX_TAG_SET_PHYSICAL_SIZE, 0x00048003
.equ PI4_MAILBOX_TAG_SET_VIRTUAL_SIZE,  0x00048004
.equ PI4_MAILBOX_TAG_SET_DEPTH,         0x00048005
.equ PI4_MAILBOX_TAG_SET_PIXEL_ORDER,   0x00048006
.equ PI4_MAILBOX_TAG_SET_VIRTUAL_OFFSET, 0x00048009
.equ PI4_MAILBOX_TAG_ALLOCATE_BUFFER,   0x00040001
.equ PI4_MAILBOX_TAG_GET_PITCH,         0x00040008
.equ PI4_MAILBOX_TAG_END,               0x00000000
.equ PI4_MAILBOX_CLOCK_PWM,             0x0000000a
.equ PI4_MAILBOX_CLOCK_STATE_MISSING,   1
.equ PI4_FB_REQUEST_WIDTH,              1280
.equ PI4_FB_REQUEST_HEIGHT,             720
.equ PI4_FB_REQUEST_DEPTH,              32
.equ PI4_FB_REQUEST_PIXEL_ORDER,        1
.equ PI4_FB_REQUEST_ALIGNMENT,          4096
.equ PI4_FB_TEST_PIXEL,                 0x00ff00ff

.equ VIBE_PI4_STATUS_MAGIC,             0x56345049
.equ VIBE_PI4_STATUS_VERSION,           1
.equ VIBE_PI4_STATUS_BOOT_ENTRY,        0x50494245
.equ VIBE_PI4_STATUS_PRIMARY_CORE,      0x50494330
.equ VIBE_PI4_STATUS_UART_READY,        0x50495552
.equ VIBE_PI4_STATUS_HOLDING,           0x5049484f
.equ VIBE_PI4_STATUS_WAIT,              0x57414954
.equ VIBE_PI4_STATUS_NONE,              0x4e4f4e45
.equ VIBE_PI4_STATUS_PI4EL_OK,          0x5034454c
.equ VIBE_PI4_STATUS_PI4VEC_ARMED,      0x50345641
.equ VIBE_PI4_STATUS_PI4VEC_OK,         0x50345643
.equ VIBE_PI4_STATUS_PI4VBAR_OK,        0x50345642
.equ VIBE_PI4_STATUS_PI4SVC_WAIT,       0x53564357
.equ VIBE_PI4_STATUS_PI4SVC_ARMED,      0x53564341
.equ VIBE_PI4_STATUS_PI4SVC_RETURNED,   0x53564352
.equ VIBE_PI4_STATUS_PI4SVC_OK,         0x5356434f
.equ VIBE_PI4_STATUS_PI4SYSFRAME_ARMED, 0x53594641
.equ VIBE_PI4_STATUS_PI4SYSFRAME_OK,    0x5359464f
.equ VIBE_PI4_STATUS_PI4UABI_OK,        0x5541424f
.equ VIBE_PI4_STATUS_PI4ELF_ARMED,      0x454c4641
.equ VIBE_PI4_STATUS_PI4ELF_OK,         0x454c464f
.equ VIBE_PI4_STATUS_PI4ELF_BAD,        0x454c4655
.equ VIBE_PI4_STATUS_PI4DTB_OK,         0x4454424f
.equ VIBE_PI4_STATUS_PI4DTB_BAD,        0x44544255
.equ VIBE_PI4_STATUS_PI4SOCDTB_OK,      0x53434f4b
.equ VIBE_PI4_STATUS_PI4BOARDDTB_OK,    0x42444f4b
.equ VIBE_PI4_STATUS_PI4GICDTB_OK,      0x47494f4b
.equ VIBE_PI4_STATUS_PI4GICMMIO_OK,     0x474d4f4b
.equ VIBE_PI4_STATUS_PI4GICCFG_OK,      0x47434f4b
.equ VIBE_PI4_STATUS_PI4IRQ_OK,         0x49524f4b
.equ VIBE_PI4_STATUS_PI4TIMER_ARMED,    0x544d4152
.equ VIBE_PI4_STATUS_PI4TIMER_OK,       0x544d4f4b
.equ VIBE_PI4_STATUS_PI4PREEMPT_OK,     0x50524f4b
.equ VIBE_PI4_STATUS_PI4MAILBOX_OK,     0x4d424f4b
.equ VIBE_PI4_STATUS_PI4FB_OK,          0x46424f4b
.equ VIBE_PI4_STATUS_GFX_OK,            0x4746584f
.equ VIBE_PI4_STATUS_FB_PI4FB,          0x50494642
.equ VIBE_PI4_STATUS_VECTOR_HIT,        0x50345648
.equ VIBE_PI4_STATUS_VECTOR_UNEXPECTED, 0x50345655
.equ VIBE_PI4_STATUS_PANIC_ASSERT,      0x41535354
.equ VIBE_PI4_FAULTSRC_BOOT,            1
.equ VIBE_PI4_FAULTSRC_EL1,             2
.equ VIBE_PI4_FAULTSRC_EL0,             3
.equ VIBE_PI4_FAULTMODE_EL,             1
.equ VIBE_PI4_FAULTMODE_ALLOC,          2
.equ VIBE_PI4_FAULTMODE_ELF,            3
.equ VIBE_PI4_FAULTMODE_STACK,          4
.equ VIBE_PI4_FAULTMODE_SYNC,           5
.equ VIBE_PI4_FAULTMODE_IRQ,            6
.equ VIBE_PI4_FAULTMODE_SVC,            7
.equ VIBE_PI4_FAULTMODE_VECTOR,         8

.equ PI4_START_STORAGE_WAIT,            0x57414954
.equ PI4_START_STORAGE_SD_OK,           0x53444f4b
.equ PI4_START_STORAGE_MBR_OK,          0x4d424f4b
.equ PI4_START_STORAGE_BPB_OK,          0x42504f4b
.equ PI4_START_STORAGE_ROOT_OK,         0x524f4f4b
.equ PI4_START_STORAGE_FILE_OK,         0x464f4f4b
.equ PI4_START_STORAGE_VFS_OK,          PI4_START_STORAGE_FILE_OK
.equ PI4_START_STORAGE_FAT16,           0x46413136
.equ PI4_START_STORAGE_ENOSYS,          0x454e4f53
.equ PI4_START_STORAGE_EINVAL,          0x45494e56
.equ PI4_START_STORAGE_EIO,             0x45494f20
.equ PI4_START_STORAGE_SDCTL_EMMC2,     0x454d4332
.equ PI4_START_STORAGE_SDCTL_EMMC,      0x454d4d43
.equ PI4_START_STORAGE_SECTOR_BYTES,    512
.equ PI4_START_STORAGE_MAX_READ_SECTORS, 128
.equ PI4_START_STORAGE_BLOCK_MAX_READ_SECTORS, 1024
.equ PI4_START_STORAGE_APP_ELF_MAX_READ_SECTORS, 1024
.equ PI4_START_STORAGE_BUFFER_BYTES,    PI4_START_STORAGE_SECTOR_BYTES * PI4_START_STORAGE_MAX_READ_SECTORS
.equ PI4_START_STORAGE_BLOCK_MAX_READ_BYTES, PI4_START_STORAGE_SECTOR_BYTES * PI4_START_STORAGE_BLOCK_MAX_READ_SECTORS
.equ PI4_START_STORAGE_APP_ELF_BUFFER_BYTES, PI4_START_STORAGE_SECTOR_BYTES * PI4_START_STORAGE_APP_ELF_MAX_READ_SECTORS
.equ PI4_START_STORAGE_ASSET_DIR_PROOF,  0
.equ PI4_START_STORAGE_ASSET_DIR_ASSETS, 1
.equ PI4_START_STORAGE_ASSET_DIR_MAPS,   2
.equ PI4_START_STORAGE_ASSET_DIR_TEXTURES, 3
.equ PI4_START_STORAGE_ASSET_DIR_ID1,    4
.equ PI4_START_STORAGE_ASSET_DIR_SYSTEM, 5
.equ PI4_START_STORAGE_ASSET_DIR_APPS,   6
.equ PI4_START_STORAGE_ASSET_DIR_APP_BASE, 7
.equ PI4_START_STORAGE_ASSET_DIR_APP_COUNT, 4

.equ PI4_VIBE_SVC_IMM,                  0x80
.equ PI4_VIBE_SYS_READ,                 0
.equ PI4_VIBE_SYS_WRITE,                4
.equ PI4_VIBE_SYS_OPEN,                 5
.equ PI4_VIBE_SYS_LSEEK,                8
.equ PI4_VIBE_SYS_CLOSE,                12
.equ PI4_VIBE_SYS_EXIT,                 2
.equ PI4_VIBE_SYS_AUDIO,                13
.equ PI4_VIBE_SYS_EXEC,                 16
.equ PI4_VIBE_SYS_STAT,                 18
.equ PI4_VIBE_SYS_FSTAT,                19
.equ PI4_VIBE_SYS_IOCTL,                22
.equ PI4_VIBE_SYS_GETPID,               25
.equ PI4_VIBE_SYS_POLL_INPUT,           28
.equ PI4_VIBE_SYS_CLOCK_GETTIME,        29
.equ PI4_VIBE_SYS_INPUT_STATUS,         31
.equ PI4_VIBE_SYS_INPUT_DEVICE_STATUS,  39
.equ PI4_VIBE_SYS_FILE_SIZE,            40
.equ PI4_VIBE_IOCTL_FBINFO,             0x00005601
.equ PI4_VIBE_IOCTL_PRESENT_INDEXED,    0x00005602
.equ PI4_VIBE_DISPLAY_FD,               1
.equ PI4_VIBE_FD_DOOM1_WAD,             3
.equ PI4_VIBE_FD_PAK0_PAK,              4
.equ PI4_VIBE_FD_MANIFEST_TXT,          7
.equ PI4_VIBE_FD_ASSET_README,          8
.equ PI4_VIBE_FD_ASSET_MAP,             9
.equ PI4_VIBE_FD_ASSET_PALETTE,         10
.equ PI4_VIBE_FD_APP_INDEX,             11
.equ PI4_VIBE_FD_APP_MANIFEST_BASE, 12
.equ PI4_VIBE_FD_APP_MANIFEST_COUNT, 4
.equ PI4_VIBE_FD_APP_ELF_BASE,      16
.equ PI4_VIBE_FD_APP_ELF_COUNT,     4
.equ PI4_VIBE_ENOENT,                   2
.equ PI4_VIBE_EBADF,                    9
.equ PI4_VIBE_EINVAL,                   22
.equ PI4_VIBE_ENOSYS,                   38
.equ PI4_VIBE_FILE_PATH_MAX_BYTES,      64
.equ PI4_VIBE_FILE_OP_OPEN,             0x00000001
.equ PI4_VIBE_FILE_OP_SIZE,             0x00000002
.equ PI4_VIBE_FILE_OP_READ,             0x00000004
.equ PI4_VIBE_FILE_PROOF_MIN_READ_BYTES, 4
.equ PI4_VIBE_FILE_ASSET_NONE,          0
.equ PI4_VIBE_FILE_ASSET_DOOM1_WAD,     1
.equ PI4_VIBE_FILE_ASSET_PAK0_PAK,      2
.equ PI4_VIBE_FILE_ASSET_MANIFEST_TXT,  5
.equ PI4_VIBE_FILE_ASSET_README_TXT,    6
.equ PI4_VIBE_FILE_ASSET_E1M1_MAP,      7
.equ PI4_VIBE_FILE_ASSET_PAL0_BIN,      8
.equ PI4_VIBE_FILE_ASSET_APP_INDEX,     9
.equ PI4_VIBE_FILE_ASSET_APP_MANIFEST_BASE, 10
.equ PI4_VIBE_FILE_ASSET_APP_MANIFEST_COUNT, 4
.equ PI4_VIBE_FILE_ASSET_APP_ELF_BASE, 14
.equ PI4_VIBE_FILE_ASSET_APP_ELF_COUNT, 4
.equ PI4_VIBE_STAT_BYTES,               44
.equ PI4_VIBE_STAT_MODE_OFFSET,         8
.equ PI4_VIBE_STAT_SIZE_OFFSET,         28
.equ PI4_VIBE_S_IFREG,                  0100000
.equ PI4_VIBE_S_IRUSR,                  0000400
.equ PI4_VIBE_SEEK_SET,                 0
.equ PI4_VIBE_SEEK_CUR,                 1
.equ PI4_VIBE_SEEK_END,                 2
.equ PI4_VIBE_REQUIRED_APP_RECORD_COUNT, 2
.equ PI4_VIBE_APP_RECORD_DIR_NAME,  0
.equ PI4_VIBE_APP_RECORD_ELF_META,  8
.equ PI4_VIBE_APP_RECORD_ELF_OFFSET, 16
.equ PI4_VIBE_APP_RECORD_MANIFEST_META, 24
.equ PI4_VIBE_APP_RECORD_MANIFEST_OFFSET, 32
.equ PI4_VIBE_APP_RECORD_ELF_STATUS, 40
.equ PI4_VIBE_APP_RECORD_ELF_READ_COUNT, 48
.equ PI4_VIBE_APP_RECORD_DIR_STATUS, 56
.equ PI4_VIBE_APP_RECORD_STATUS_LABEL, 64
.equ PI4_VIBE_APP_RECORD_BYTES,     72
.equ PI4_VIBE_APP_RECORD_TABLE_BYTES, 288
.equ PI4_VIBE_APP_RECORD_COUNT,     PI4_VIBE_APP_RECORD_TABLE_BYTES / PI4_VIBE_APP_RECORD_BYTES
.equ PI4_VIBE_EXEC_REQUEST_ABI_VERSION, 1
.equ PI4_VIBE_EXEC_REQUEST_BYTES,       32
.equ PI4_VIBE_EXEC_REQUEST_PATH_MAX_BYTES, 64
.equ PI4_VIBE_EXEC_REQUEST_ABI_VERSION_OFFSET, 0
.equ PI4_VIBE_EXEC_REQUEST_BYTES_OFFSET, 8
.equ PI4_VIBE_EXEC_REQUEST_RESERVED_OFFSET, 16
.equ PI4_VIBE_EXEC_REQUEST_PATH_OFFSET, 24
.equ PI4_VIBE_INPUT_DEVICE_KEYBOARD,    1
.equ PI4_VIBE_INPUT_DEVICE_MOUSE,       2
.equ PI4_VIBE_INPUT_DEVICE_UART,        3
.equ PI4_VIBE_INPUT_DEVICE_USB,         4
.equ PI4_VIBE_INPUT_DEVICE_STATUS_WAIT, 0
.equ PI4_VIBE_INPUT_DEVICE_STATUS_READY, 1
.equ PI4_VIBE_INPUT_CAP_KEYBOARD,       0x00000001
.equ PI4_VIBE_INPUT_CAP_MOUSE,          0x00000002
.equ PI4_VIBE_INPUT_CAP_POLL_EVENT,     0x00000004
.equ PI4_VIBE_INPUT_CAP_STATUS,         0x00000008
.equ PI4_VIBE_INPUT_CAP_DEVICE_STATUS,  0x00000010
.equ PI4_VIBE_INPUT_CAP_UART_SERIAL,    0x00000020
.equ PI4_VIBE_INPUT_DEVICE_CAP_KEYS,    0x00000001
.equ PI4_VIBE_INPUT_DEVICE_CAP_RELATIVE_POINTER, 0x00000002
.equ PI4_VIBE_INPUT_DEVICE_CAP_BUTTONS, 0x00000004
.equ PI4_VIBE_INPUT_DEVICE_CAP_STATE_SNAPSHOT, 0x00000008
.equ PI4_VIBE_INPUT_EVENT_KEY,          1
.equ PI4_VIBE_INPUT_EVENT_MOUSE_PACKET, 2
.equ PI4_VIBE_INPUT_EVENT_UART,         3
.equ PI4_VIBE_INPUT_KEY_RELEASED,       0
.equ PI4_VIBE_INPUT_KEY_PRESSED,        1
.equ PI4_VIBE_INPUT_ACTION_RELEASED,    PI4_VIBE_INPUT_KEY_RELEASED
.equ PI4_VIBE_INPUT_ACTION_PRESSED,     PI4_VIBE_INPUT_KEY_PRESSED
.equ PI4_VIBE_INPUT_KEY_STATE_BITS,     256
.equ PI4_VIBE_INPUT_KEY_PS2_SET1_ESCAPE, 0x01
.equ PI4_VIBE_INPUT_KEY_PS2_SET1_LEFT_CTRL, 0x1d
.equ PI4_VIBE_INPUT_KEY_PS2_SET1_LEFT_SHIFT, 0x2a
.equ PI4_VIBE_INPUT_KEY_PS2_SET1_RIGHT_SHIFT, 0x36
.equ PI4_VIBE_INPUT_KEY_PS2_SET1_LEFT_ALT, 0x38
.equ PI4_VIBE_INPUT_KEY_PS2_SET1_RIGHT_CTRL, PI4_VIBE_INPUT_KEY_PS2_SET1_LEFT_CTRL | 0x80
.equ PI4_VIBE_INPUT_KEY_PS2_SET1_RIGHT_ALT, PI4_VIBE_INPUT_KEY_PS2_SET1_LEFT_ALT | 0x80
.equ PI4_VIBE_INPUT_EVENT_KEY_TOKEN,    0x80000000
.equ PI4_VIBE_INPUT_EVENT_KEY_TOKEN_CODE_MASK, 0xff
.equ PI4_VIBE_INPUT_EVENT_KEY_TOKEN_HID_SHIFT, 8
.equ PI4_VIBE_INPUT_EVENT_KEY_TOKEN_ACTION_SHIFT, 24
.equ PI4_VIBE_INPUT_EVENT_KEY_TOKEN_FIELD_MASK, 0xff
.equ PI4_VIBE_INPUT_MOD_SHIFT,          0x00000001
.equ PI4_VIBE_INPUT_MOD_CTRL,           0x00000002
.equ PI4_VIBE_INPUT_MOD_ALT,            0x00000004
.equ PI4_UART_INPUT_MOUSE_PACKET,       6
.equ PI4_VIBE_INPUT_SOURCE_UNKNOWN,     0
.equ PI4_VIBE_INPUT_SOURCE_UART_SERIAL, 1
.equ PI4_VIBE_INPUT_SOURCE_MSMOUSE,     2
.equ PI4_VIBE_INPUT_SOURCE_USB_HID_KEYBOARD, 3
.equ PI4_VIBE_INPUT_SOURCE_USB_HID_MOUSE, 4
.equ PI4_VIBE_INPUT_QUEUE_OVERFLOW_DROP_NEWEST, 2
.equ PI4_UART_INPUT_CAPS,               0x0000003c
.equ PI4_RUNTIME_INPUT_KEY_STATE_WORDS, 8
.equ PI4_RUNTIME_INPUT_KEY_STATE_BYTES, PI4_RUNTIME_INPUT_KEY_STATE_WORDS * 8
.equ PI4_START_USB_DEVICE_KIND_UNKNOWN, 0
.equ PI4_START_USB_DEVICE_KIND_KEYBOARD, 1
.equ PI4_START_USB_DEVICE_KIND_MOUSE,   2
.equ PI4_START_USB_STATUS_WAIT,         0
.equ PI4_START_USB_STATUS_HOST,         1
.equ PI4_START_USB_STATUS_PORT,         2
.equ PI4_START_USB_STATUS_ADDR,         3
.equ PI4_START_USB_STATUS_HID,          4
.equ PI4_UART_INPUT_QUEUE_SIZE,         8
.equ PI4_UART_INPUT_QUEUE_USABLE,       7
.equ PI4_VIBE_FB_BACKEND_XRGB8888_LFB,  2
.equ PI4_VIBE_FB_CAP_PRESENT_INDEXED,   0x00000001
.equ PI4_VIBE_FB_CAP_PRESENT_RGB_PALETTE, 0x00000002
.equ PI4_VIBE_FB_CAP_XRGB8888_LFB,      0x00000004
.equ PI4_VIBE_FB_CAP_DIRTY_SOURCE_RECT, 0x00000010
.equ PI4_VIBE_FB_CAP_PRESENT_FULLSCREEN_SCALE, 0x00000020
.equ PI4_VIBE_FB_FORMAT_INDEX8_RGB24,   1
.equ PI4_VIBE_FB_RGB24_PALETTE_BYTES,   768
.equ PI4_VIBE_FB_POLICY_ASPECT,         2
.equ PI4_VIBE_FB_POLICY_FULLSCREEN_STRETCH, 4
.equ PI4_VIBE_AUDIO_CAP_MMIO_WINDOW,    0x00000001
.equ PI4_VIBE_AUDIO_CAP_MAILBOX_CLOCK,  0x00000002
.equ PI4_VIBE_AUDIO_CAP_PCM_QUEUE,      0x00000004
.equ PI4_VIBE_AUDIO_CAP_USB_AUDIO,      0x00000008
.equ PI4_VIBE_AUDIO_CAP_FULL_MASK,      PI4_VIBE_AUDIO_CAP_MMIO_WINDOW | PI4_VIBE_AUDIO_CAP_MAILBOX_CLOCK | PI4_VIBE_AUDIO_CAP_PCM_QUEUE
.equ PI4_VIBE_AUDIO_USB_FULL_MASK,      PI4_VIBE_AUDIO_CAP_USB_AUDIO | PI4_VIBE_AUDIO_CAP_PCM_QUEUE
.equ PI4_VIBE_AUDIO_ABI_DEVICE_STATUS,  0x00000001
.equ PI4_VIBE_AUDIO_ABI_QUEUE_STATUS,   0x00000002
.equ PI4_VIBE_AUDIO_ABI_CAP_STATUS,     0x00000004
.equ PI4_VIBE_AUDIO_ABI_FULL_MASK,      PI4_VIBE_AUDIO_ABI_DEVICE_STATUS | PI4_VIBE_AUDIO_ABI_QUEUE_STATUS | PI4_VIBE_AUDIO_ABI_CAP_STATUS
.equ PI4_VIBE_AUDIO_DEVICE_NONE,        0
.equ PI4_VIBE_AUDIO_DEVICE_PI4_PWM,     2
.equ PI4_VIBE_AUDIO_DEVICE_PI4_USB,     3
.equ PI4_VIBE_AUDIO_DEVICE_STATUS_NONE, 0
.equ PI4_VIBE_AUDIO_DEVICE_STATUS_READY, 1
.equ PI4_VIBE_AUDIO_DEVICE_STATUS_ABSENT, 2
.equ PI4_VIBE_AUDIO_FORMAT_U8_STEREO,   1
.equ PI4_VIBE_AUDIO_STREAM_NONE,        0
.equ PI4_VIBE_AUDIO_STREAM_PUSH,        1
.equ PI4_VIBE_AUDIO_STREAM_PULL,        2
.equ PI4_VIBE_AUDIO_STREAM_FLAG_PULL,   0x00000001
.equ PI4_VIBE_AUDIO_STREAM_FLAG_REFILL_PENDING, 0x00000002
.equ PI4_VIBE_AUDIO_STREAM_FLAG_ACTIVE, 0x00000004
.equ PI4_VIBE_AUDIO_PCM_LIFECYCLE_IDLE, 0
.equ PI4_VIBE_AUDIO_PCM_LIFECYCLE_OPEN, 1
.equ PI4_VIBE_AUDIO_PCM_LIFECYCLE_WRITTEN, 2
.equ PI4_VIBE_AUDIO_PCM_LIFECYCLE_DRAINING, 3
.equ PI4_VIBE_AUDIO_PCM_LIFECYCLE_CLOSED, 4
.equ PI4_VIBE_AUDIO_DEVICE_START,       1
.equ PI4_VIBE_AUDIO_MIXER_START,        2
.equ PI4_VIBE_AUDIO_MIXER_STOP,         3
.equ PI4_VIBE_AUDIO_MIXER_UPDATE,       4
.equ PI4_VIBE_AUDIO_DEVICE_SHUTDOWN,    5
.equ PI4_VIBE_AUDIO_MIXER_IS_PLAYING,   6
.equ PI4_VIBE_AUDIO_PCM_BUFFERED_BYTES, 7
.equ PI4_VIBE_AUDIO_PCM_PULL_STATE,     8
.equ PI4_VIBE_AUDIO_DEVICE_INFO,        9
.equ PI4_VIBE_AUDIO_PCM_RING_INFO,      10
.equ PI4_VIBE_AUDIO_STREAM_INFO,        11
.equ PI4_VIBE_AUDIO_PCM_WRITE,          12
.equ PI4_VIBE_AUDIO_PCM_WRITE_DESC,     13
.equ PI4_VIBE_AUDIO_PCM_OPEN,           14
.equ PI4_VIBE_AUDIO_PCM_DRAIN,          15
.equ PI4_VIBE_AUDIO_PCM_CLOSE,          16
.equ PI4_VIBE_AUDIO_HANDLE,             1
.equ PI4_VIBE_AUDIO_QUEUE_BYTES,        4096
.equ PI4_VIBE_AUDIO_PERIOD_BYTES,       512
.equ PI4_VIBE_AUDIO_LOW_WATER_BYTES,    512
.equ PI4_VIBE_AUDIO_SAMPLE_RATE,        48000
.equ PI4_VIBE_AUDIO_CHANNELS,           2
.equ PI4_VIBE_AUDIO_INFO_BYTES,         96
.equ PI4_VIBE_AUDIO_RING_INFO_BYTES,    96
.equ PI4_VIBE_AUDIO_STREAM_INFO_BYTES,  96
.equ PI4_VIBE_AUDIO_PCM_DESC_MIN_BYTES, 40
.equ PI4_VIBE_AUDIO_DESC_SAMPLES_OFFSET, 0
.equ PI4_VIBE_AUDIO_DESC_LENGTH_OFFSET, 8
.equ PI4_VIBE_AUDIO_DESC_RATE_OFFSET,   16
.equ PI4_VIBE_AUDIO_DESC_CHANNELS_OFFSET, 24
.equ PI4_VIBE_AUDIO_DESC_FORMAT_OFFSET, 32
.equ PI4_VIBE_CLOCK_MONOTONIC,          1
.equ PI4_VIBE_CLOCK_MONOTONIC_HZ,       PI4_TIMER_TICK_DIV
.equ PI4_VIBE_CLOCK_TIME_BYTES,         32
.equ PI4_VIBE_CLOCK_TIME_TICKS_OFFSET,  0
.equ PI4_VIBE_CLOCK_TIME_FREQUENCY_HZ_OFFSET, 8
.equ PI4_VIBE_CLOCK_TIME_MILLISECONDS_OFFSET, 16
.equ PI4_VIBE_CLOCK_TIME_FLAGS_OFFSET,  24
.equ PI4_VIBE_CLOCK_TICK_MILLISECONDS,  10
.equ PI4_VIBE_CLOCK_FLAG_KERNEL_OWNED,  0x00000001

.equ PI4_SPSR_EL0T_MASKED,              0x03c0
.equ PI4_SPSR_EL0T_IRQ_UNMASKED,        0x0340
.equ PI4_SPSR_EL1H_MASKED,              0x03c5
.equ PI4_EL0_SVC_ROUNDTRIP,             0x0040
.equ PI4_EL0_SVC_EXIT,                  0x0041
.equ PI4_EL0_SVC_TRACE,                 0x0042
.equ PI4_EL0_SVC_BAD,                   0x007f
.equ PI4_EL0_RETURN_MAGIC_LO,           0x4f4b
.equ PI4_EL0_RETURN_MAGIC_HI,           0x5530

.equ PI4_FB_PRESENT_SOURCE_SELFTEST,    1
.equ PI4_FB_PRESENT_SOURCE_IOCTL,       2
.equ PI4_FB_PRESENT_MAX_WIDTH,          PI4_FB_REQUEST_WIDTH
.equ PI4_FB_PRESENT_MAX_HEIGHT,         PI4_FB_REQUEST_HEIGHT
.equ PI4_FB_PRESENT_MODE13_WIDTH,       320
.equ PI4_FB_PRESENT_MODE13_HEIGHT,      200
.equ PI4_FB_PRESENT_MODE13_ASPECT_HEIGHT, 240
.equ PI4_FB_SELFTEST_WIDTH,             16
.equ PI4_FB_SELFTEST_HEIGHT,            9
.equ PI4_FB_PRESENT_FRAME_BYTES,        PI4_FB_PRESENT_MAX_WIDTH * PI4_FB_PRESENT_MAX_HEIGHT
.equ PI4_FB_ABI_INFO,                   0x00000001
.equ PI4_FB_ABI_PRESENT,                0x00000002
.equ PI4_FB_ABI_DIRTY,                  0x00000004
.equ PI4_FB_ABI_IOCTL_PRESENT,          0x00000008
.equ PI4_FB_ABI_FULL_MASK,              PI4_FB_ABI_INFO | PI4_FB_ABI_PRESENT | PI4_FB_ABI_DIRTY | PI4_FB_ABI_IOCTL_PRESENT

.equ PI4_ELF64_MAGIC,                   0x464c457f
.equ PI4_ELF64_CLASS_64,                2
.equ PI4_ELF64_DATA_LSB,                1
.equ PI4_ELF64_VERSION_CURRENT,         1
.equ PI4_ELF64_ET_EXEC,                 2
.equ PI4_ELF64_EM_AARCH64,              183
.equ PI4_ELF64_EHDR_SIZE,               64
.equ PI4_ELF64_PHDR_SIZE,               56
.equ PI4_ELF64_PHNUM,                   1
.equ PI4_ELF64_PHNUM_MAX,               8
.equ PI4_ELF64_PT_LOAD,                 1
.equ PI4_ELF64_PF_X,                    1
.equ PI4_ELF64_PF_W,                    2
.equ PI4_ELF64_PF_R,                    4
.equ PI4_ELF64_PF_RX,                   5

.equ PI4_VIBE_USER_ABI_VERSION,         1
.equ PI4_VIBE_USER_STACK_ABI_VERSION,   1
.equ PI4_VIBE_USER_ARG_MAX,             8
.equ PI4_VIBE_USER_ENV_MAX,             8
.equ PI4_VIBE_USER_AUX_MAX,             16
.equ PI4_VIBE_USER_START_REQUIRED_FLAGS, 0x0000001f
.equ PI4_VIBE_AT_NULL,                  0
.equ PI4_VIBE_AT_PHDR,                  3
.equ PI4_VIBE_AT_PHENT,                 4
.equ PI4_VIBE_AT_PHNUM,                 5
.equ PI4_VIBE_AT_PAGESZ,                6
.equ PI4_VIBE_AT_ENTRY,                 9
.equ PI4_VIBE_INPUT_EVENT_BYTES,        56
.equ PI4_VIBE_INPUT_STATUS_BYTES,       264
.equ PI4_VIBE_INPUT_DEVICE_STATUS_BYTES, 128
.equ PI4_VIBE_FB_INFO_BYTES,            168
.equ PI4_VIBE_PRESENT_INDEXED_BYTES,    32
.equ PI4_EL0_STACK_HEADER_BYTES,        128
.equ PI4_EL0_STACK_ARGV0_BYTES,         PI4_VIBE_FILE_PATH_MAX_BYTES
.equ PI4_EL0_STACK_FRAME_BYTES,         PI4_EL0_STACK_HEADER_BYTES + PI4_EL0_STACK_ARGV0_BYTES
.equ PI4_EL0_STACK_TOTAL_BYTES,         0x00040000
.equ PI4_EL0_ALLOC_FLAG_IMAGE,          0x00000001
.equ PI4_EL0_ALLOC_FLAG_STACK,          0x00000002
.equ PI4_EL0_ALLOC_FLAG_BOUNDED,        0x00000004
.equ PI4_EL0_ALLOC_FLAG_EL0,            0x00000008
.equ PI4_EL0_ALLOC_REQUIRED_FLAGS,      PI4_EL0_ALLOC_FLAG_IMAGE | PI4_EL0_ALLOC_FLAG_STACK | PI4_EL0_ALLOC_FLAG_BOUNDED | PI4_EL0_ALLOC_FLAG_EL0
.equ PI4_EL0_ALLOC_BOOT_COUNT,          2
.equ PI4_PROC_TABLE_CAPACITY,           4
.equ PI4_PROC_TABLE_ENTRY_BYTES,        64
.equ PI4_PROC_CONTEXT_BYTES,            64
.equ PI4_PROC_IRQ_FRAME_BYTES,          256
.equ PI4_PROC_CONTEXT_VERSION,          1
.equ PI4_PROC_CONTEXT_FLAG_EL0_FRAME,   0x00000001
.equ PI4_PROC_CONTEXT_FLAG_TIMER_IRQ,   0x00000002
.equ PI4_PROC_CONTEXT_REQUIRED_FLAGS,   PI4_PROC_CONTEXT_FLAG_EL0_FRAME | PI4_PROC_CONTEXT_FLAG_TIMER_IRQ
.equ PI4_PROC_STATE_EL0_PROBE,          1
.equ PI4_PROC_STATE_INIT,               2
.equ PI4_PROC_STATE_APP,            3
.equ PI4_PROC_STATE_REPLACED,           4
.equ PI4_PROC_STATE_RETURNED,           5
.equ PI4_PROC_STATE_FAULTED,            6
.equ PI4_PROC_KIND_EL0_PROBE,           1
.equ PI4_PROC_KIND_INIT,                2
.equ PI4_PROC_KIND_APP_BASE,        3
.equ PI4_PROC_KIND_APP_COUNT,       PI4_VIBE_APP_RECORD_COUNT
.equ PI4_PROC_PID_INIT,                 1
.equ PI4_PROC_PID_NEXT_INIT,            2
.equ PI4_PROC_PID_APP_FIRST,        2

.equ PI4_FDT_MAGIC,                     0xd00dfeed
.equ PI4_FDT_VERSION_MIN,               17
.equ PI4_FDT_HEADER_SIZE,               40
.equ PI4_FDT_BEGIN_NODE,                1
.equ PI4_FDT_END_NODE,                  2
.equ PI4_FDT_PROP,                      3
.equ PI4_FDT_NOP,                       4
.equ PI4_FDT_END,                       9
.equ PI4_FDT_ROOT_TOKEN_BYTES,          4
.equ PI4_FDT_SOC_RANGES_MIN_BYTES,      16
.equ PI4_ARMSTUB_DTB_PTR32_ADDR,        0x000000f8

// Gate words start as WAIT and are promoted by the concrete code paths that
// prove them: mailbox framebuffer setup, timer IRQ/preemption, and EL0 runtime.
.equ VIBE_PI4_GATE_FRAMEBUFFER_WAIT,    VIBE_PI4_STATUS_WAIT
.equ VIBE_PI4_GATE_FRAMEBUFFER_OK,      VIBE_PI4_STATUS_PI4FB_OK
.equ VIBE_PI4_GATE_TIMER_WAIT,          VIBE_PI4_STATUS_WAIT
.equ VIBE_PI4_GATE_TIMER_ARMED,         VIBE_PI4_STATUS_PI4TIMER_ARMED
.equ VIBE_PI4_GATE_TIMER_IRQ_OK,        VIBE_PI4_STATUS_PI4TIMER_OK
.equ VIBE_PI4_GATE_TIMER_PREEMPT_OK,    VIBE_PI4_STATUS_PI4PREEMPT_OK
.equ VIBE_PI4_GATE_AUDIO_TODO,          0x50494155
.equ VIBE_PI4_GATE_RUNTIME_WAIT,        VIBE_PI4_STATUS_WAIT
.equ VIBE_PI4_GATE_RUNTIME_ARMED,       VIBE_PI4_STATUS_PI4SVC_ARMED
.equ VIBE_PI4_GATE_RUNTIME_RETURNED,    VIBE_PI4_STATUS_PI4SVC_RETURNED
.equ VIBE_PI4_GATE_RUNTIME_OK,          VIBE_PI4_STATUS_PI4UABI_OK

.section .text.boot, "ax", %progbits
.balign 16
.global _start
.type _start, %function

_start:
    msr daifset, #0xf
    mov x20, x0
    mrs x21, CurrentEL
    mrs x22, MPIDR_EL1

    and x1, x22, #0xff
    cbz x1, .Lprimary_core

.Lsecondary_hold:
    wfe
    b .Lsecondary_hold

.Lprimary_core:
    adr x23, pi4_boot_stack_top
    cmp x21, #0x8
    b.eq .Lenter_el1_from_el2
    cmp x21, #0x4
    b.eq .Lconfirm_el1
    mov sp, x23
    b .Lprimary_el_ready

.Lconfirm_el1:
    msr SPSel, #1
    isb
    mov sp, x23
    b .Lprimary_el_ready

.Lenter_el1_from_el2:
    msr SP_EL1, x23
    mrs x0, CNTHCTL_EL2
    orr x0, x0, #0x3
    msr CNTHCTL_EL2, x0
    msr CNTVOFF_EL2, xzr
    msr CPTR_EL2, xzr
    movz x0, #0x8000, lsl #16
    msr HCR_EL2, x0
    mov x0, #0x03c5
    msr SPSR_EL2, x0
    adr x0, .Lprimary_el_ready
    msr ELR_EL2, x0
    isb
    eret

.Lprimary_el_ready:
    mrs x24, CurrentEL
    bl pi4_clear_bss
    bl pi4_init_el0_allocator
    bl pi4_init_process_table_skeleton
    bl pi4_record_entry_status
    cmp x24, #0x4
    b.ne .Lprimary_el_wait
    bl pi4_record_el1_ready
    bl pi4_uart_init
    adr x0, msg_uart_ready
    bl pi4_uart_write_string
    bl pi4_install_el1_vectors
    bl pi4_enable_el0_fp_simd
    adr x0, msg_stage_vectors
    bl pi4_uart_write_string
    bl pi4_validate_dtb
    adr x0, msg_stage_dtb
    bl pi4_uart_write_string
    bl pi4_scan_board_identity
    bl pi4_scan_soc_ranges
    bl pi4_scan_gic_dtb
    bl pi4_prepare_gic_mmio
    bl pi4_configure_gic
    adr x0, msg_stage_gic
    bl pi4_uart_write_string
    bl pi4_run_el1_vector_selftest
    adr x0, msg_stage_el1vec
    bl pi4_uart_write_string
    bl pi4_run_timer_irq_probe
    adr x0, msg_stage_timer
    bl pi4_uart_write_string
    bl pi4_run_lower_el_svc_selftest
    adr x0, msg_stage_el0svc
    bl pi4_uart_write_string
    bl pi4_framebuffer_init
    adr x0, msg_stage_fb
    bl pi4_uart_write_string
    bl pi4_probe_audio_status
    adr x0, msg_stage_audio
    bl pi4_uart_write_string
    ldr x16, =pi4_uart_input_init
    blr x16
    bl pi4_audio_try_promote_hardware_backend
    ldr x16, =pi4_uart_input_poll
    blr x16
    adr x0, msg_stage_input
    bl pi4_uart_write_string
    adr x0, msg_stage_storage_enter
    bl pi4_uart_write_string
    bl pi4_prepare_storage_handoff
    adr x0, msg_stage_storage
    bl pi4_uart_write_string
    bl pi4_sync_storage_status
    bl pi4_try_launch_nonembedded_init
    bl pi4_uart_write_status_line

    adr x0, msg_banner
    bl pi4_uart_write_string
    adr x0, msg_load_addr
    bl pi4_uart_write_string
    mov x0, #PI4_KERNEL8_LOAD_ADDR
    bl pi4_uart_write_hex64
    bl pi4_uart_write_newline

    adr x0, msg_dtb
    bl pi4_uart_write_string
    mov x0, x20
    bl pi4_uart_write_hex64
    bl pi4_uart_write_newline

    adr x0, msg_entry_el
    bl pi4_uart_write_string
    mov x0, x21
    bl pi4_uart_write_hex64
    bl pi4_uart_write_newline

    adr x0, msg_current_el
    bl pi4_uart_write_string
    mov x0, x24
    bl pi4_uart_write_hex64
    bl pi4_uart_write_newline

    adr x0, msg_mpidr
    bl pi4_uart_write_string
    mov x0, x22
    bl pi4_uart_write_hex64
    bl pi4_uart_write_newline

    adr x0, msg_uart_ready
    bl pi4_uart_write_string
    adr x0, msg_framebuffer_gate
    bl pi4_uart_write_string
    adr x0, msg_timer_gate
    bl pi4_uart_write_string
    adr x0, msg_runtime_gate
    bl pi4_uart_write_string
    adr x0, msg_elf_probe
    bl pi4_uart_write_string
    adr x0, msg_holding
    bl pi4_uart_write_string

.Lprimary_hold:
    wfe
    b .Lprimary_hold

.Lprimary_el_wait:
    bl pi4_uart_init
    ldr w0, =VIBE_PI4_FAULTSRC_BOOT
    ldr w1, =VIBE_PI4_FAULTMODE_EL
    bl pi4_record_panic_status
    adr x0, msg_el_wait
    bl pi4_uart_write_string
    mov x0, x24
    bl pi4_uart_write_hex64
    bl pi4_uart_write_newline
    bl pi4_uart_write_status_line
    b .Lprimary_hold

.size _start, . - _start

.type pi4_clear_bss, %function
pi4_clear_bss:
    adr x0, __bss_start
    ldr x1, =__bss_end
.Lclear_bss_loop:
    cmp x0, x1
    b.hs .Lclear_bss_done
    str xzr, [x0], #8
    b .Lclear_bss_loop
.Lclear_bss_done:
    ret
.size pi4_clear_bss, . - pi4_clear_bss

.type pi4_init_process_table_skeleton, %function
pi4_init_process_table_skeleton:
    ldr x0, =pi4_process_table

    adr x1, pi4_status_pi4ptable_base
    str x0, [x1]
    adr x1, pi4_status_pi4ptable_capacity
    mov x2, #PI4_PROC_TABLE_CAPACITY
    str x2, [x1]
    adr x1, pi4_status_pi4ptable_entry_bytes
    mov x2, #PI4_PROC_TABLE_ENTRY_BYTES
    str x2, [x1]
    adr x1, pi4_status_pi4ptable_used
    mov x2, #1
    str x2, [x1]

    mov x2, #PI4_PROC_STATE_EL0_PROBE
    str x2, [x0, #0]
    mov x2, #PI4_PROC_PID_INIT
    str x2, [x0, #8]
    adr x2, pi4_el0_svc_probe
    str x2, [x0, #16]
    adr x2, pi4_status_pi4el0_stack_base
    ldr x2, [x2]
    str x2, [x0, #24]
    adr x2, pi4_status_pi4el0_stack_top
    ldr x2, [x2]
    str x2, [x0, #32]
    mov x2, #PI4_PROC_KIND_EL0_PROBE
    str x2, [x0, #40]
    mov x2, #-1
    str x2, [x0, #48]
    mov x2, #PI4_SPSR_EL0T_MASKED
    str x2, [x0, #56]

    adr x1, pi4_status_proc_current_pid
    mov x2, #PI4_PROC_PID_INIT
    str x2, [x1]
    adr x1, pi4_status_proc_last_pid
    str x2, [x1]
    adr x1, pi4_status_proc_next_pid
    mov x2, #PI4_PROC_PID_NEXT_INIT
    str x2, [x1]
    adr x1, pi4_status_proc_alloc_count
    mov x2, #1
    str x2, [x1]
    adr x1, pi4_status_proc_el0_launch_count
    str x2, [x1]
    adr x1, pi4_status_proc_el0_return_count
    str xzr, [x1]
    adr x1, pi4_status_proc_exec_launch_count
    str xzr, [x1]
    adr x1, pi4_status_proc_exec_pid
    str xzr, [x1]
    adr x1, pi4_status_proc_exec_slot
    mov x2, #-1
    str x2, [x1]
    adr x1, pi4_status_proc_exec_kind
    str xzr, [x1]
    adr x1, pi4_status_proc_exec_state
    str xzr, [x1]
    adr x1, pi4_status_proc_exec_spsr
    str xzr, [x1]
    adr x1, pi4_status_proc_return_pid
    str xzr, [x1]
    adr x1, pi4_status_proc_return_slot
    mov x2, #-1
    str x2, [x1]
    adr x1, pi4_status_proc_return_kind
    str xzr, [x1]
    adr x1, pi4_status_proc_return_code
    str xzr, [x1]
    adr x1, pi4_status_proc_return_elr
    str xzr, [x1]
    adr x1, pi4_status_proc_fault_pid
    str xzr, [x1]
    adr x1, pi4_status_proc_fault_slot
    mov x2, #-1
    str x2, [x1]
    adr x1, pi4_status_proc_fault_kind
    str xzr, [x1]
    adr x1, pi4_status_proc_fault_mode
    str xzr, [x1]
    adr x1, pi4_status_proc_fault_esr
    str xzr, [x1]
    adr x1, pi4_status_proc_fault_elr
    str xzr, [x1]
    adr x1, pi4_status_proc_fault_count
    str xzr, [x1]

    adr x0, pi4_el0_svc_probe
    adr x1, pi4_status_pi4el0_stack_top
    ldr x1, [x1]
    mov x2, #PI4_PROC_PID_INIT
    mov x3, #PI4_PROC_KIND_EL0_PROBE
    mov x4, #PI4_SPSR_EL0T_MASKED
    b pi4_record_process_context_skeleton
.size pi4_init_process_table_skeleton, . - pi4_init_process_table_skeleton

.type pi4_record_process_context_skeleton, %function
pi4_record_process_context_skeleton:
    ldr x7, =pi4_process_context_record

    mov x5, #PI4_PROC_CONTEXT_VERSION
    str x5, [x7, #0]
    str x2, [x7, #8]
    str x3, [x7, #16]
    str x0, [x7, #24]
    str x1, [x7, #32]
    str x4, [x7, #40]
    mov x5, #PI4_PROC_CONTEXT_REQUIRED_FLAGS
    str x5, [x7, #48]
    adr x6, pi4_status_timer_ticks
    ldr x5, [x6]
    str x5, [x7, #56]

    adr x6, pi4_status_pi4ctx_base
    str x7, [x6]
    adr x6, pi4_status_pi4ctx_bytes
    mov x5, #PI4_PROC_CONTEXT_BYTES
    str x5, [x6]
    adr x6, pi4_status_pi4ctx_version
    mov x5, #PI4_PROC_CONTEXT_VERSION
    str x5, [x6]
    adr x6, pi4_status_pi4ctx_pid
    str x2, [x6]
    adr x6, pi4_status_pi4ctx_kind
    str x3, [x6]
    adr x6, pi4_status_pi4ctx_elr
    str x0, [x6]
    adr x6, pi4_status_pi4ctx_sp
    str x1, [x6]
    adr x6, pi4_status_pi4ctx_spsr
    str x4, [x6]
    adr x6, pi4_status_pi4ctx_flags
    mov x5, #PI4_PROC_CONTEXT_REQUIRED_FLAGS
    str x5, [x6]
    adr x6, pi4_status_pi4sched_current_pid
    str x2, [x6]
    adr x6, pi4_status_pi4sched_last_pid
    str x2, [x6]
    ret
.size pi4_record_process_context_skeleton, . - pi4_record_process_context_skeleton

.type pi4_mark_current_process_fault, %function
pi4_mark_current_process_fault:
    mov x9, x0
    mov x10, x1
    mov x11, x2
    adr x12, pi4_status_proc_current_pid
    ldr x13, [x12]
    cbnz x13, .Lpi4_proc_fault_have_pid
    mov x13, #PI4_PROC_PID_INIT
.Lpi4_proc_fault_have_pid:
    mov x14, #-1
    mov x15, xzr
    ldr x16, =pi4_process_table
    mov x17, #PI4_PROC_TABLE_CAPACITY
.Lpi4_proc_fault_scan_next:
    cbz x17, .Lpi4_proc_fault_record
    ldr x0, [x16, #8]
    cmp x0, x13
    b.eq .Lpi4_proc_fault_found
    add x16, x16, #PI4_PROC_TABLE_ENTRY_BYTES
    sub x17, x17, #1
    b .Lpi4_proc_fault_scan_next
.Lpi4_proc_fault_found:
    mov x0, #PI4_PROC_STATE_FAULTED
    str x0, [x16, #0]
    ldr x15, [x16, #40]
    ldr x14, [x16, #48]
.Lpi4_proc_fault_record:
    adr x0, pi4_status_proc_fault_pid
    str x13, [x0]
    adr x0, pi4_status_proc_fault_slot
    str x14, [x0]
    adr x0, pi4_status_proc_fault_kind
    str x15, [x0]
    adr x0, pi4_status_proc_fault_mode
    str x11, [x0]
    adr x0, pi4_status_proc_fault_esr
    str x9, [x0]
    adr x0, pi4_status_proc_fault_elr
    str x10, [x0]
    adr x0, pi4_status_proc_fault_count
    ldr x1, [x0]
    add x1, x1, #1
    str x1, [x0]
    ret
.size pi4_mark_current_process_fault, . - pi4_mark_current_process_fault

.type pi4_copy_irq_frame_256, %function
pi4_copy_irq_frame_256:
    mov x2, #32
.Lpi4_copy_irq_frame_next:
    ldr x3, [x0], #8
    str x3, [x1], #8
    subs x2, x2, #1
    b.ne .Lpi4_copy_irq_frame_next
    ret
.size pi4_copy_irq_frame_256, . - pi4_copy_irq_frame_256

.type pi4_rearm_timer_tick, %function
pi4_rearm_timer_tick:
    adr x4, pi4_status_timer_tick
    ldr x4, [x4]
    cbz x4, .Lpi4_rearm_timer_tick_done
    msr CNTP_TVAL_EL0, x4
    mov x4, #1
    msr CNTP_CTL_EL0, x4
    isb
.Lpi4_rearm_timer_tick_done:
    ret
.size pi4_rearm_timer_tick, . - pi4_rearm_timer_tick

.type pi4_start_runtime_timer, %function
pi4_start_runtime_timer:
    adr x0, pi4_status_pi4timer
    ldr w0, [x0]
    ldr w1, =VIBE_PI4_STATUS_PI4TIMER_OK
    cmp w0, w1
    b.ne .Lpi4_start_runtime_timer_done
    adr x0, pi4_status_timer_tick
    ldr x0, [x0]
    cbz x0, .Lpi4_start_runtime_timer_done
    msr CNTP_CTL_EL0, xzr
    isb
    msr CNTP_TVAL_EL0, x0
    mov x0, #1
    msr CNTP_CTL_EL0, x0
    isb
.Lpi4_start_runtime_timer_done:
    ret
.size pi4_start_runtime_timer, . - pi4_start_runtime_timer

.type pi4_stop_runtime_timer, %function
pi4_stop_runtime_timer:
    msr CNTP_CTL_EL0, xzr
    isb
    ret
.size pi4_stop_runtime_timer, . - pi4_stop_runtime_timer

.type pi4_record_timer_preempt_wait, %function
pi4_record_timer_preempt_wait:
    adr x0, pi4_status_pi4sched_attempts
    ldr x1, [x0]
    add x1, x1, #1
    str x1, [x0]
    adr x0, pi4_status_pi4sched_no_peer
    ldr x1, [x0]
    add x1, x1, #1
    str x1, [x0]
    adr x0, pi4_status_proc_current_pid
    ldr x1, [x0]
    cbnz x1, .Lpi4_timer_preempt_have_pid
    mov x1, #PI4_PROC_PID_INIT
.Lpi4_timer_preempt_have_pid:
    adr x0, pi4_status_pi4sched_current_pid
    str x1, [x0]
    adr x0, pi4_status_pi4sched_last_pid
    str x1, [x0]
    b pi4_refresh_preempt_status_from_sched
.size pi4_record_timer_preempt_wait, . - pi4_record_timer_preempt_wait

.type pi4_seed_live_preempt_probe, %function
pi4_seed_live_preempt_probe:
    adr x0, pi4_status_pi4ptable_used
    ldr x1, [x0]
    cmp x1, #PI4_PROC_TABLE_CAPACITY
    b.hs .Lpi4_seed_live_preempt_probe_done

    adr x2, pi4_status_proc_next_pid
    ldr x3, [x2]
    cbnz x3, .Lpi4_seed_live_preempt_probe_have_pid
    mov x3, #PI4_PROC_PID_APP_FIRST
.Lpi4_seed_live_preempt_probe_have_pid:
    ldr x5, =pi4_process_table
    lsl x4, x1, #6
    add x4, x5, x4

    mov x6, #PI4_PROC_STATE_EL0_PROBE
    str x6, [x4, #0]
    str x3, [x4, #8]
    adr x6, pi4_el0_preempt_idle
    str x6, [x4, #16]
    adr x6, pi4_el0_stack
    add x6, x6, #0x100
    str x6, [x4, #24]
    str x6, [x4, #32]
    mov x6, #PI4_PROC_KIND_EL0_PROBE
    str x6, [x4, #40]
    mov x6, #-1
    str x6, [x4, #48]
    mov x6, #PI4_SPSR_EL0T_IRQ_UNMASKED
    str x6, [x4, #56]

    add x6, x3, #1
    str x6, [x2]
    add x6, x1, #1
    str x6, [x0]

    adr x7, pi4_status_proc_alloc_count
    str x6, [x7]

    ldr x7, =pi4_process_irq_frames
    lsl x6, x1, #8
    add x6, x7, x6
    mov x8, #32
.Lpi4_seed_live_preempt_probe_zero_frame:
    str xzr, [x6], #8
    subs x8, x8, #1
    b.ne .Lpi4_seed_live_preempt_probe_zero_frame

.Lpi4_seed_live_preempt_probe_done:
    ret
.size pi4_seed_live_preempt_probe, . - pi4_seed_live_preempt_probe

.type pi4_record_timer_preempt_schedule, %function
pi4_record_timer_preempt_schedule:
    stp x29, x30, [sp, #-96]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]

    mov x26, x0

    adr x0, pi4_status_pi4sched_attempts
    ldr x1, [x0]
    add x1, x1, #1
    str x1, [x0]

    ldr x28, =pi4_process_table
    adr x0, pi4_status_pi4ptable_used
    ldr x11, [x0]
    cmp x11, #2
    b.lo .Lpi4_timer_preempt_schedule_no_peer
    mov x0, #PI4_PROC_TABLE_CAPACITY
    cmp x11, x0
    csel x11, x11, x0, lo

    adr x0, pi4_status_proc_current_pid
    ldr x19, [x0]
    cbnz x19, .Lpi4_timer_preempt_schedule_have_from
    ldr x19, [x28, #8]
.Lpi4_timer_preempt_schedule_have_from:

    mov x23, xzr
    mov x14, xzr
    mov x15, x28
    mov x16, x11
.Lpi4_timer_preempt_schedule_find_current:
    cbz x16, .Lpi4_timer_preempt_schedule_no_peer
    ldr x0, [x15, #8]
    cmp x0, x19
    b.ne .Lpi4_timer_preempt_schedule_find_current_next
    ldr x1, [x15, #0]
    cbz x1, .Lpi4_timer_preempt_schedule_no_peer
    cmp x1, #PI4_PROC_STATE_REPLACED
    b.eq .Lpi4_timer_preempt_schedule_no_peer
    cmp x1, #PI4_PROC_STATE_RETURNED
    b.eq .Lpi4_timer_preempt_schedule_no_peer
    cmp x1, #PI4_PROC_STATE_FAULTED
    b.eq .Lpi4_timer_preempt_schedule_no_peer
    ldr x1, [x15, #16]
    cbz x1, .Lpi4_timer_preempt_schedule_no_peer
    ldr x1, [x15, #24]
    cbz x1, .Lpi4_timer_preempt_schedule_no_peer
    mov x23, x15
    b .Lpi4_timer_preempt_schedule_current_ready
.Lpi4_timer_preempt_schedule_find_current_next:
    add x15, x15, #PI4_PROC_TABLE_ENTRY_BYTES
    add x14, x14, #1
    sub x16, x16, #1
    b .Lpi4_timer_preempt_schedule_find_current

.Lpi4_timer_preempt_schedule_current_ready:
    add x12, x14, #1
    cmp x12, x11
    csel x12, xzr, x12, eq
    sub x16, x11, #1
    mov x21, xzr
.Lpi4_timer_preempt_schedule_find_target:
    cbz x16, .Lpi4_timer_preempt_schedule_no_peer
    lsl x15, x12, #6
    add x15, x28, x15
    ldr x20, [x15, #8]
    cbz x20, .Lpi4_timer_preempt_schedule_target_next
    cmp x20, x19
    b.eq .Lpi4_timer_preempt_schedule_target_next
    ldr x0, [x15, #0]
    cbz x0, .Lpi4_timer_preempt_schedule_target_next
    cmp x0, #PI4_PROC_STATE_REPLACED
    b.eq .Lpi4_timer_preempt_schedule_target_next
    cmp x0, #PI4_PROC_STATE_RETURNED
    b.eq .Lpi4_timer_preempt_schedule_target_next
    cmp x0, #PI4_PROC_STATE_FAULTED
    b.eq .Lpi4_timer_preempt_schedule_target_next
    ldr x22, [x15, #16]
    cbz x22, .Lpi4_timer_preempt_schedule_target_next
    ldr x24, [x15, #24]
    cbz x24, .Lpi4_timer_preempt_schedule_target_next
    mov x21, x15
    b .Lpi4_timer_preempt_schedule_have_target
.Lpi4_timer_preempt_schedule_target_next:
    add x12, x12, #1
    cmp x12, x11
    csel x12, xzr, x12, eq
    sub x16, x16, #1
    b .Lpi4_timer_preempt_schedule_find_target

.Lpi4_timer_preempt_schedule_have_target:
    ldr x22, [x21, #16]
    ldr x24, [x21, #24]
    ldr x25, [x21, #40]
    ldr x27, [x21, #56]
    cbz x22, .Lpi4_timer_preempt_schedule_no_peer
    cbz x24, .Lpi4_timer_preempt_schedule_no_peer
    cbz x25, .Lpi4_timer_preempt_schedule_default_kind_done
    b .Lpi4_timer_preempt_schedule_kind_ready
.Lpi4_timer_preempt_schedule_default_kind_done:
    mov x25, #PI4_PROC_KIND_EL0_PROBE
.Lpi4_timer_preempt_schedule_kind_ready:
    cbnz x27, .Lpi4_timer_preempt_schedule_spsr_ready
    mov x27, #PI4_SPSR_EL0T_MASKED
.Lpi4_timer_preempt_schedule_spsr_ready:

    adr x0, pi4_status_irqframe_elr_el1
    ldr x1, [x0]
    str x1, [x23, #16]
    adr x0, pi4_status_irqframe_sp_el0
    ldr x1, [x0]
    str x1, [x23, #24]
    adr x0, pi4_status_irqframe_spsr_el1
    ldr x1, [x0]
    str x1, [x23, #56]

    cbz x26, .Lpi4_timer_preempt_schedule_frame_saved
    mov x0, x26
    ldr x28, =pi4_process_table
    sub x1, x23, x28
    lsl x1, x1, #2
    ldr x2, =pi4_process_irq_frames
    add x1, x2, x1
    bl pi4_copy_irq_frame_256
.Lpi4_timer_preempt_schedule_frame_saved:

    adr x0, pi4_status_pi4sched_switches
    ldr x1, [x0]
    add x1, x1, #1
    str x1, [x0]

    adr x0, pi4_status_pi4preempt_from_pid
    str x19, [x0]
    adr x0, pi4_status_pi4preempt_to_pid
    str x20, [x0]
    adr x0, pi4_status_proc_current_pid
    str x20, [x0]
    adr x0, pi4_status_proc_current_pid
    str x19, [x0]
    adr x0, pi4_status_pi4sched_current_pid
    str x20, [x0]
    adr x0, pi4_status_pi4sched_last_pid
    str x19, [x0]

    adr x0, pi4_status_irqframe_elr_el1
    str x22, [x0]
    adr x0, pi4_status_irqframe_sp_el0
    str x24, [x0]
    adr x0, pi4_status_irqframe_spsr_el1
    str x27, [x0]

    mov x0, x22
    mov x1, x24
    mov x2, x20
    mov x3, x25
    mov x4, x27
    bl pi4_record_process_context_skeleton

    adr x0, pi4_status_proc_current_pid
    str x20, [x0]
    adr x0, pi4_status_proc_last_pid
    str x19, [x0]
    adr x0, pi4_status_pi4sched_current_pid
    str x20, [x0]
    adr x0, pi4_status_pi4sched_last_pid
    str x19, [x0]
    adr x0, pi4_status_pi4preempt_from_pid
    str x19, [x0]
    adr x0, pi4_status_pi4preempt_to_pid
    str x20, [x0]
    cbz x26, .Lpi4_timer_preempt_schedule_refresh_done
    ldr x28, =pi4_process_table
    sub x0, x21, x28
    lsl x0, x0, #2
    ldr x1, =pi4_process_irq_frames
    add x0, x1, x0
    mov x1, x26
    bl pi4_copy_irq_frame_256
    adr x0, pi4_status_pi4sched_irq_switches
    ldr x1, [x0]
    add x1, x1, #1
    str x1, [x0]
.Lpi4_timer_preempt_schedule_refresh_done:
    bl pi4_refresh_preempt_status_from_sched
    b .Lpi4_timer_preempt_schedule_done

.Lpi4_timer_preempt_schedule_no_peer:
    adr x0, pi4_status_pi4sched_no_peer
    ldr x1, [x0]
    add x1, x1, #1
    str x1, [x0]
    adr x0, pi4_status_proc_current_pid
    ldr x1, [x0]
    cbnz x1, .Lpi4_timer_preempt_schedule_no_peer_have_pid
    mov x1, #PI4_PROC_PID_INIT
.Lpi4_timer_preempt_schedule_no_peer_have_pid:
    adr x0, pi4_status_pi4sched_current_pid
    str x1, [x0]
    adr x0, pi4_status_pi4sched_last_pid
    str x1, [x0]
    bl pi4_refresh_preempt_status_from_sched

.Lpi4_timer_preempt_schedule_done:
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret
.size pi4_record_timer_preempt_schedule, . - pi4_record_timer_preempt_schedule

.type pi4_refresh_preempt_status_from_sched, %function
pi4_refresh_preempt_status_from_sched:
    adr x0, pi4_status_timer_ticks
    ldr x1, [x0]
    cbz x1, .Lpi4_refresh_preempt_wait
    adr x0, pi4_status_pi4sched_attempts
    ldr x1, [x0]
    cbz x1, .Lpi4_refresh_preempt_wait
    adr x0, pi4_status_pi4sched_switches
    ldr x1, [x0]
    cbz x1, .Lpi4_refresh_preempt_wait
    adr x0, pi4_status_pi4preempt_from_pid
    ldr x2, [x0]
    cbz x2, .Lpi4_refresh_preempt_wait
    adr x0, pi4_status_pi4preempt_to_pid
    ldr x3, [x0]
    cbz x3, .Lpi4_refresh_preempt_wait
    cmp x2, x3
    b.eq .Lpi4_refresh_preempt_wait
    adr x0, pi4_status_pi4preempt
    ldr w1, =VIBE_PI4_STATUS_PI4PREEMPT_OK
    str w1, [x0]
    adr x0, pi4_status_timer_gate
    ldr w1, =VIBE_PI4_GATE_TIMER_PREEMPT_OK
    str w1, [x0]
    ret
.Lpi4_refresh_preempt_wait:
    adr x0, pi4_status_pi4preempt
    ldr w1, =VIBE_PI4_STATUS_WAIT
    str w1, [x0]
    ret
.size pi4_refresh_preempt_status_from_sched, . - pi4_refresh_preempt_status_from_sched

.type pi4_init_el0_allocator, %function
pi4_init_el0_allocator:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    adr x0, pi4_embedded_el0_elf
    adr x1, pi4_el0_svc_probe_end
    adr x2, pi4_el0_svc_probe
    bl pi4_alloc_el0_image_region
    adr x0, pi4_el0_stack
    adr x1, pi4_el0_stack_top
    bl pi4_alloc_el0_stack_region

    adr x0, pi4_status_pi4el0_alloc_flags
    ldr x1, [x0]
    mov x2, #PI4_EL0_ALLOC_FLAG_BOUNDED
    orr x1, x1, x2
    mov x2, #PI4_EL0_ALLOC_FLAG_EL0
    orr x1, x1, x2
    str x1, [x0]

    adr x0, pi4_status_pi4el0_alloc_count
    mov x1, #PI4_EL0_ALLOC_BOOT_COUNT
    str x1, [x0]

    ldp x29, x30, [sp], #16
    ret
.size pi4_init_el0_allocator, . - pi4_init_el0_allocator

.type pi4_alloc_el0_image_region, %function
pi4_alloc_el0_image_region:
    cbz x0, .Lpi4_el0_alloc_bad
    cmp x1, x0
    b.ls .Lpi4_el0_alloc_bad
    cmp x2, x0
    b.lo .Lpi4_el0_alloc_bad
    cmp x2, x1
    b.hs .Lpi4_el0_alloc_bad

    adr x3, pi4_status_pi4el0_image_base
    str x0, [x3]
    adr x3, pi4_status_pi4el0_image_end
    str x1, [x3]
    sub x4, x1, x0
    adr x3, pi4_status_pi4el0_image_bytes
    str x4, [x3]

    adr x3, pi4_status_pi4el0_alloc_flags
    ldr x4, [x3]
    mov x5, #PI4_EL0_ALLOC_FLAG_IMAGE
    orr x4, x4, x5
    str x4, [x3]
    ret
.size pi4_alloc_el0_image_region, . - pi4_alloc_el0_image_region

.type pi4_alloc_el0_stack_region, %function
pi4_alloc_el0_stack_region:
    cbz x0, .Lpi4_el0_alloc_bad
    cmp x1, x0
    b.ls .Lpi4_el0_alloc_bad
    sub x2, x1, x0
    cmp x2, #PI4_EL0_STACK_FRAME_BYTES
    b.lo .Lpi4_el0_alloc_bad
    cmp x2, #PI4_EL0_STACK_TOTAL_BYTES
    b.hi .Lpi4_el0_alloc_bad

    adr x3, pi4_status_pi4el0_stack_base
    str x0, [x3]
    adr x3, pi4_status_pi4el0_stack_top
    str x1, [x3]
    adr x3, pi4_status_pi4el0_stack_bytes
    str x2, [x3]

    adr x3, pi4_status_pi4el0_alloc_flags
    ldr x4, [x3]
    mov x5, #PI4_EL0_ALLOC_FLAG_STACK
    orr x4, x4, x5
    str x4, [x3]
    ret
.size pi4_alloc_el0_stack_region, . - pi4_alloc_el0_stack_region

.Lpi4_el0_alloc_bad:
    ldr w0, =VIBE_PI4_FAULTSRC_BOOT
    ldr w1, =VIBE_PI4_FAULTMODE_ALLOC
    bl pi4_record_panic_status
    adr x3, pi4_status_pi4elf
    ldr w4, =VIBE_PI4_STATUS_PI4ELF_BAD
    str w4, [x3]
    adr x3, pi4_status_last
    ldr w4, =VIBE_PI4_STATUS_VECTOR_UNEXPECTED
    str w4, [x3]
.Lpi4_el0_alloc_bad_hold:
    wfe
    b .Lpi4_el0_alloc_bad_hold

.type pi4_record_entry_status, %function
pi4_record_entry_status:
    adr x0, pi4_status_dtb
    str x20, [x0]
    adr x0, pi4_status_entry_el
    str x21, [x0]
    adr x0, pi4_status_current_el
    str x24, [x0]
    adr x0, pi4_status_mpidr
    str x22, [x0]
    adr x0, pi4_status_last
    movz w1, #0x4330
    movk w1, #0x5049, lsl #16
    str w1, [x0]
    ret
.size pi4_record_entry_status, . - pi4_record_entry_status

.type pi4_record_el1_ready, %function
pi4_record_el1_ready:
    adr x0, pi4_status_pi4el
    ldr w1, =VIBE_PI4_STATUS_PI4EL_OK
    str w1, [x0]
    ret
.size pi4_record_el1_ready, . - pi4_record_el1_ready

.type pi4_record_panic_status, %function
pi4_record_panic_status:
    adr x2, pi4_status_faultsrc
    str w0, [x2]
    adr x2, pi4_status_faultmode
    str w1, [x2]
    adr x2, pi4_status_panic
    ldr w3, =VIBE_PI4_STATUS_PANIC_ASSERT
    str w3, [x2]
    ret
.size pi4_record_panic_status, . - pi4_record_panic_status

.type pi4_install_el1_vectors, %function
pi4_install_el1_vectors:
    adr x0, pi4_el1_vectors
    msr VBAR_EL1, x0
    isb
    mrs x1, VBAR_EL1
    adr x2, pi4_status_vbar_el1
    str x1, [x2]
    adr x2, pi4_status_pi4vbar
    ldr w3, =VIBE_PI4_STATUS_PI4VBAR_OK
    str w3, [x2]
    ret
.size pi4_install_el1_vectors, . - pi4_install_el1_vectors

.type pi4_enable_el0_fp_simd, %function
pi4_enable_el0_fp_simd:
    mrs x0, CPACR_EL1
    mov x1, #(3 << 20)
    orr x0, x0, x1
    msr CPACR_EL1, x0
    isb
    ret
.size pi4_enable_el0_fp_simd, . - pi4_enable_el0_fp_simd

.type pi4_run_el1_vector_selftest, %function
pi4_run_el1_vector_selftest:
    adr x0, pi4_status_pi4vec
    ldr w1, =VIBE_PI4_STATUS_PI4VEC_ARMED
    str w1, [x0]
    brk #0
    ret
.size pi4_run_el1_vector_selftest, . - pi4_run_el1_vector_selftest

.type pi4_run_lower_el_svc_selftest, %function
pi4_run_lower_el_svc_selftest:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adr x0, pi4_status_pi4svc
    ldr w1, =VIBE_PI4_STATUS_PI4SVC_ARMED
    str w1, [x0]
    adr x0, pi4_status_runtime_gate
    ldr w1, =VIBE_PI4_GATE_RUNTIME_ARMED
    str w1, [x0]
    adr x0, pi4_status_pi4sysframe
    ldr w1, =VIBE_PI4_STATUS_PI4SYSFRAME_ARMED
    str w1, [x0]
    adr x0, pi4_status_pi4elf
    ldr w1, =VIBE_PI4_STATUS_PI4ELF_ARMED
    str w1, [x0]
    bl pi4_prepare_embedded_elf_probe
    adr x1, pi4_status_el0_return_el1
    adr x2, pi4_lower_el_svc_done
    str x2, [x1]
    sub sp, sp, #16
    str x0, [sp]
    bl pi4_build_embedded_user_stack
    msr SP_EL0, x0
    mov x0, xzr
    ldr x1, [sp]
    add sp, sp, #16
    msr ELR_EL1, x1
    mov x1, #PI4_SPSR_EL0T_MASKED
    msr SPSR_EL1, x1
    isb
    eret
pi4_lower_el_svc_done:
    ldp x29, x30, [sp], #16
    ret
.size pi4_run_lower_el_svc_selftest, . - pi4_run_lower_el_svc_selftest

.type pi4_prepare_embedded_elf_probe, %function
pi4_prepare_embedded_elf_probe:
    adr x0, pi4_embedded_el0_elf
    ldr w1, [x0, #0]
    ldr w2, =PI4_ELF64_MAGIC
    cmp w1, w2
    b.ne .Lpi4_embedded_elf_bad
    ldrb w1, [x0, #4]
    cmp w1, #PI4_ELF64_CLASS_64
    b.ne .Lpi4_embedded_elf_bad
    ldrb w1, [x0, #5]
    cmp w1, #PI4_ELF64_DATA_LSB
    b.ne .Lpi4_embedded_elf_bad
    ldrb w1, [x0, #6]
    cmp w1, #PI4_ELF64_VERSION_CURRENT
    b.ne .Lpi4_embedded_elf_bad
    ldrh w1, [x0, #16]
    cmp w1, #PI4_ELF64_ET_EXEC
    b.ne .Lpi4_embedded_elf_bad
    ldrh w1, [x0, #18]
    cmp w1, #PI4_ELF64_EM_AARCH64
    b.ne .Lpi4_embedded_elf_bad
    ldr w1, [x0, #20]
    cmp w1, #PI4_ELF64_VERSION_CURRENT
    b.ne .Lpi4_embedded_elf_bad
    ldr x6, [x0, #24]
    ldr x7, [x0, #32]
    cmp x7, #PI4_ELF64_EHDR_SIZE
    b.ne .Lpi4_embedded_elf_bad
    ldrh w1, [x0, #52]
    cmp w1, #PI4_ELF64_EHDR_SIZE
    b.ne .Lpi4_embedded_elf_bad
    ldrh w1, [x0, #54]
    cmp w1, #PI4_ELF64_PHDR_SIZE
    b.ne .Lpi4_embedded_elf_bad
    ldrh w1, [x0, #56]
    cmp w1, #PI4_ELF64_PHNUM
    b.ne .Lpi4_embedded_elf_bad
    add x8, x0, x7
    ldr w1, [x8, #0]
    cmp w1, #PI4_ELF64_PT_LOAD
    b.ne .Lpi4_embedded_elf_bad
    ldr w1, [x8, #4]
    cmp w1, #PI4_ELF64_PF_RX
    b.ne .Lpi4_embedded_elf_bad
    ldr x9, [x8, #8]
    adr x10, pi4_el0_svc_probe
    sub x11, x10, x0
    cmp x9, x11
    b.ne .Lpi4_embedded_elf_bad
    ldr x12, [x8, #16]
    cmp x12, x6
    b.ne .Lpi4_embedded_elf_bad
    cmp x12, x10
    b.ne .Lpi4_embedded_elf_bad
    ldr x13, [x8, #24]
    cmp x13, x10
    b.ne .Lpi4_embedded_elf_bad
    ldr x13, [x8, #32]
    adr x14, pi4_el0_svc_probe_end
    sub x15, x14, x10
    cmp x13, x15
    b.ne .Lpi4_embedded_elf_bad
    ldr x13, [x8, #40]
    cmp x13, x15
    b.ne .Lpi4_embedded_elf_bad
    ldr x13, [x8, #48]
    cmp x13, #16
    b.ne .Lpi4_embedded_elf_bad
    adr x1, pi4_status_pi4elf_base
    str x0, [x1]
    adr x1, pi4_status_pi4elf_entry
    str x6, [x1]
    adr x1, pi4_status_pi4elf_phdr
    str x8, [x1]
    adr x1, pi4_status_pi4elf_filesz
    str x15, [x1]
    adr x1, pi4_status_pi4elf_phent
    mov x2, #PI4_ELF64_PHDR_SIZE
    str x2, [x1]
    adr x1, pi4_status_pi4elf_phnum
    mov x2, #PI4_ELF64_PHNUM
    str x2, [x1]
    adr x1, pi4_status_pi4elf_load_vaddr
    ldr x2, [x8, #16]
    str x2, [x1]
    adr x1, pi4_status_pi4elf_load_paddr
    ldr x2, [x8, #24]
    str x2, [x1]
    adr x1, pi4_status_pi4elf_load_filesz
    ldr x2, [x8, #32]
    str x2, [x1]
    adr x1, pi4_status_pi4elf_load_memsz
    ldr x2, [x8, #40]
    str x2, [x1]
    adr x1, pi4_status_pi4elf_load_flags
    ldr w2, [x8, #4]
    str x2, [x1]
    adr x1, pi4_status_pi4elf_load_align
    ldr x2, [x8, #48]
    str x2, [x1]
    mov x0, x6
    ret
.Lpi4_embedded_elf_bad:
    ldr w0, =VIBE_PI4_FAULTSRC_BOOT
    ldr w1, =VIBE_PI4_FAULTMODE_ELF
    bl pi4_record_panic_status
    adr x1, pi4_status_pi4elf
    ldr w2, =VIBE_PI4_STATUS_PI4ELF_BAD
    str w2, [x1]
    adr x1, pi4_status_last
    ldr w2, =VIBE_PI4_STATUS_VECTOR_UNEXPECTED
    str w2, [x1]
.Lpi4_embedded_elf_bad_hold:
    wfe
    b .Lpi4_embedded_elf_bad_hold
.size pi4_prepare_embedded_elf_probe, . - pi4_prepare_embedded_elf_probe

.type pi4_build_embedded_user_stack, %function
pi4_build_embedded_user_stack:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adr x0, pi4_status_pi4el0_stack_base
    ldr x0, [x0]
    adr x1, pi4_status_pi4el0_stack_top
    ldr x1, [x1]
    cbz x0, .Lpi4_embedded_stack_bad
    cbz x1, .Lpi4_embedded_stack_bad
    mov x2, #PI4_EL0_STACK_FRAME_BYTES
    sub x3, x1, x2
    cmp x3, x0
    b.lo .Lpi4_embedded_stack_bad
    mov x7, x1

    mov x4, x3
    mov x5, #1
    str x5, [x4], #8
    adr x5, pi4_embedded_user_argv0_string
    add x6, x3, #PI4_EL0_STACK_HEADER_BYTES
    mov x0, x6
    mov x1, x5
    bl pi4_copy_argv0_to_user_stack
    str x6, [x4], #8
    str xzr, [x4], #8
    str xzr, [x4], #8

    mov x5, #PI4_VIBE_AT_PHDR
    str x5, [x4], #8
    adr x5, pi4_embedded_el0_elf_phdr
    str x5, [x4], #8
    mov x5, #PI4_VIBE_AT_PHENT
    str x5, [x4], #8
    mov x5, #PI4_ELF64_PHDR_SIZE
    str x5, [x4], #8
    mov x5, #PI4_VIBE_AT_PHNUM
    str x5, [x4], #8
    mov x5, #PI4_ELF64_PHNUM
    str x5, [x4], #8
    mov x5, #PI4_VIBE_AT_PAGESZ
    str x5, [x4], #8
    mov x5, #4096
    str x5, [x4], #8
    mov x5, #PI4_VIBE_AT_ENTRY
    str x5, [x4], #8
    adr x5, pi4_el0_svc_probe
    str x5, [x4], #8
    str xzr, [x4], #8
    str xzr, [x4], #8

    adr x5, pi4_status_pi4ustack_sp
    str x3, [x5]
    adr x5, pi4_status_pi4ustack_top
    str x7, [x5]
    adr x5, pi4_status_pi4ustack_bytes
    str x2, [x5]
    adr x5, pi4_status_pi4ustack_argc
    mov x6, #1
    str x6, [x5]
    adr x5, pi4_status_pi4ustack_argv
    add x6, x3, #8
    str x6, [x5]
    adr x5, pi4_status_pi4ustack_envp
    add x6, x3, #24
    str x6, [x5]
    adr x5, pi4_status_pi4ustack_auxv
    add x6, x3, #32
    str x6, [x5]
    adr x5, pi4_status_pi4ustack_flags
    mov x6, #PI4_VIBE_USER_START_REQUIRED_FLAGS
    str x6, [x5]

    mov x0, x3
    ldp x29, x30, [sp], #16
    ret

.Lpi4_embedded_stack_bad:
    ldr w0, =VIBE_PI4_FAULTSRC_BOOT
    ldr w1, =VIBE_PI4_FAULTMODE_STACK
    bl pi4_record_panic_status
    adr x1, pi4_status_pi4elf
    ldr w2, =VIBE_PI4_STATUS_PI4ELF_BAD
    str w2, [x1]
    adr x1, pi4_status_last
    ldr w2, =VIBE_PI4_STATUS_VECTOR_UNEXPECTED
    str w2, [x1]
.Lpi4_embedded_stack_bad_hold:
    wfe
    b .Lpi4_embedded_stack_bad_hold
.size pi4_build_embedded_user_stack, . - pi4_build_embedded_user_stack

.type pi4_try_launch_nonembedded_init, %function
pi4_try_launch_nonembedded_init:
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]

    adr x0, pi4_storage_status_init_elf
    ldr w0, [x0]
    ldr w1, =PI4_START_STORAGE_FILE_OK
    cmp w0, w1
    b.ne .Lpi4_nonembedded_init_done
    adr x0, pi4_storage_status_init_elf_read_count
    ldr x0, [x0]
    cbz x0, .Lpi4_nonembedded_init_done

    adr x0, pi4_nonembedded_init_elf_buffer
    ldr x19, [x0]
    adr x0, pi4_nonembedded_init_elf_bytes
    ldr x20, [x0]
    adr x0, pi4_nonembedded_init_stack_base
    ldr x21, [x0]
    adr x0, pi4_nonembedded_init_stack_top
    ldr x22, [x0]
    cbz x19, .Lpi4_nonembedded_init_done
    cbz x20, .Lpi4_nonembedded_init_done
    cbz x21, .Lpi4_nonembedded_init_done
    cbz x22, .Lpi4_nonembedded_init_done

    mov x0, x19
    mov x1, x20
    bl pi4_prepare_nonembedded_init_elf
    cbz x0, .Lpi4_nonembedded_init_bad_elf
    mov x23, x0

    mov x0, x21
    mov x1, x22
    bl pi4_build_nonembedded_user_stack
    cbz x0, .Lpi4_nonembedded_init_bad_stack
    mov x24, x0

    mov x0, x23
    mov x1, x24
    bl pi4_record_nonembedded_init_launch
    adr x0, pi4_status_el0_return_el1
    adr x1, .Lpi4_nonembedded_init_returned
    str x1, [x0]
    bl pi4_start_runtime_timer
    msr SP_EL0, x24
    msr ELR_EL1, x23
    mov x0, #PI4_SPSR_EL0T_IRQ_UNMASKED
    msr SPSR_EL1, x0
    isb
    eret

.Lpi4_nonembedded_init_bad_elf:
    ldr w0, =VIBE_PI4_FAULTSRC_BOOT
    ldr w1, =VIBE_PI4_FAULTMODE_ELF
    bl pi4_record_panic_status
    b .Lpi4_nonembedded_init_bad_record

.Lpi4_nonembedded_init_bad_stack:
    ldr w0, =VIBE_PI4_FAULTSRC_BOOT
    ldr w1, =VIBE_PI4_FAULTMODE_STACK
    bl pi4_record_panic_status

.Lpi4_nonembedded_init_bad_record:
    adr x0, pi4_status_pi4elf
    ldr w1, =VIBE_PI4_STATUS_PI4ELF_BAD
    str w1, [x0]
    adr x0, pi4_status_last
    ldr w1, =VIBE_PI4_STATUS_VECTOR_UNEXPECTED
    str w1, [x0]
    b .Lpi4_nonembedded_init_done

.Lpi4_nonembedded_init_returned:
    bl pi4_stop_runtime_timer
.Lpi4_nonembedded_init_done:
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret
.size pi4_try_launch_nonembedded_init, . - pi4_try_launch_nonembedded_init

.type pi4_run_timer_preempt_selftest, %function
pi4_run_timer_preempt_selftest:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x19, [sp, #16]

    adr x0, pi4_status_pi4timer
    ldr w0, [x0]
    ldr w1, =VIBE_PI4_STATUS_PI4TIMER_OK
    cmp w0, w1
    b.ne .Lpi4_timer_preempt_selftest_done
    adr x0, pi4_status_pi4gic_cpu_base
    ldr x19, [x0]
    cbz x19, .Lpi4_timer_preempt_selftest_done
    adr x0, pi4_status_timer_tick
    ldr x0, [x0]
    cbz x0, .Lpi4_timer_preempt_selftest_done

    adr x0, pi4_status_timer_ticks
    str xzr, [x0]
    adr x0, pi4_status_pi4sched_attempts
    str xzr, [x0]
    adr x0, pi4_status_pi4sched_no_peer
    str xzr, [x0]
    adr x0, pi4_status_pi4sched_switches
    str xzr, [x0]
    adr x0, pi4_status_pi4sched_irq_switches
    str xzr, [x0]
    adr x0, pi4_status_pi4preempt_from_pid
    str xzr, [x0]
    adr x0, pi4_status_pi4preempt_to_pid
    str xzr, [x0]
    adr x0, pi4_status_pi4preempt
    ldr w1, =VIBE_PI4_STATUS_WAIT
    str w1, [x0]

    bl pi4_seed_timer_preempt_processes

    adr x0, pi4_status_el0_return_el1
    adr x1, .Lpi4_timer_preempt_selftest_returned
    str x1, [x0]
    msr daifset, #2
    msr CNTP_CTL_EL0, xzr
    isb
    mov x0, #1
    msr CNTP_TVAL_EL0, x0
    mov x0, #1
    msr CNTP_CTL_EL0, x0
    isb

    ldr x1, =pi4_process_table
    add x1, x1, #PI4_PROC_TABLE_ENTRY_BYTES
    ldr x0, [x1, #24]
    msr SP_EL0, x0
    ldr x0, [x1, #16]
    msr ELR_EL1, x0
    mov x0, #PI4_SPSR_EL0T_IRQ_UNMASKED
    msr SPSR_EL1, x0
    isb
    eret

.Lpi4_timer_preempt_selftest_returned:
    msr daifset, #2
    msr CNTP_CTL_EL0, xzr
    isb
    bl pi4_refresh_preempt_status_from_sched
    adr x0, pi4_status_pi4preempt
    ldr w0, [x0]
    ldr w1, =VIBE_PI4_STATUS_PI4PREEMPT_OK
    cmp w0, w1
    b.ne .Lpi4_timer_preempt_selftest_done
    adr x0, pi4_status_timer_gate
    ldr w1, =VIBE_PI4_GATE_TIMER_PREEMPT_OK
    str w1, [x0]

.Lpi4_timer_preempt_selftest_done:
    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size pi4_run_timer_preempt_selftest, . - pi4_run_timer_preempt_selftest

.type pi4_seed_timer_preempt_processes, %function
pi4_seed_timer_preempt_processes:
    ldr x0, =pi4_process_table
    add x1, x0, #PI4_PROC_TABLE_ENTRY_BYTES
    adr x2, pi4_status_pi4el0_stack_top
    ldr x2, [x2]
    sub x3, x2, #0x100
    sub x4, x2, #0x200

    mov x5, #PI4_PROC_STATE_INIT
    str x5, [x0, #0]
    mov x5, #PI4_PROC_PID_INIT
    str x5, [x0, #8]
    adr x5, pi4_el0_preempt_target
    str x5, [x0, #16]
    str x4, [x0, #24]
    str x3, [x0, #32]
    mov x5, #PI4_PROC_KIND_INIT
    str x5, [x0, #40]
    mov x5, #-1
    str x5, [x0, #48]
    mov x5, #PI4_SPSR_EL0T_IRQ_UNMASKED
    str x5, [x0, #56]

    mov x5, #PI4_PROC_STATE_EL0_PROBE
    str x5, [x1, #0]
    mov x5, #PI4_PROC_PID_NEXT_INIT
    str x5, [x1, #8]
    adr x5, pi4_el0_preempt_source
    str x5, [x1, #16]
    str x3, [x1, #24]
    str x2, [x1, #32]
    mov x5, #PI4_PROC_KIND_EL0_PROBE
    str x5, [x1, #40]
    mov x5, #-1
    str x5, [x1, #48]
    mov x5, #PI4_SPSR_EL0T_IRQ_UNMASKED
    str x5, [x1, #56]

    adr x5, pi4_status_pi4ptable_used
    mov x6, #2
    str x6, [x5]
    adr x5, pi4_status_proc_current_pid
    mov x6, #PI4_PROC_PID_NEXT_INIT
    str x6, [x5]
    adr x5, pi4_status_proc_last_pid
    mov x6, #PI4_PROC_PID_INIT
    str x6, [x5]
    adr x5, pi4_status_proc_next_pid
    mov x6, #3
    str x6, [x5]
    adr x5, pi4_status_proc_alloc_count
    mov x6, #2
    str x6, [x5]
    adr x5, pi4_status_pi4preempt_from_pid
    str xzr, [x5]
    adr x5, pi4_status_pi4preempt_to_pid
    str xzr, [x5]

    adr x0, pi4_el0_preempt_source
    mov x1, x3
    mov x2, #PI4_PROC_PID_NEXT_INIT
    mov x3, #PI4_PROC_KIND_EL0_PROBE
    mov x4, #PI4_SPSR_EL0T_IRQ_UNMASKED
    b pi4_record_process_context_skeleton
.size pi4_seed_timer_preempt_processes, . - pi4_seed_timer_preempt_processes

.type pi4_prepare_nonembedded_init_elf, %function
pi4_prepare_nonembedded_init_elf:
    stp x29, x30, [sp, #-96]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]

    mov x19, x0
    mov x20, x1
    cbz x19, .Lpi4_nonembedded_elf_bad
    cmp x20, #PI4_ELF64_EHDR_SIZE
    b.lo .Lpi4_nonembedded_elf_bad
    ldr w2, [x19, #0]
    ldr w3, =PI4_ELF64_MAGIC
    cmp w2, w3
    b.ne .Lpi4_nonembedded_elf_bad
    ldrb w2, [x19, #4]
    cmp w2, #PI4_ELF64_CLASS_64
    b.ne .Lpi4_nonembedded_elf_bad
    ldrb w2, [x19, #5]
    cmp w2, #PI4_ELF64_DATA_LSB
    b.ne .Lpi4_nonembedded_elf_bad
    ldrb w2, [x19, #6]
    cmp w2, #PI4_ELF64_VERSION_CURRENT
    b.ne .Lpi4_nonembedded_elf_bad
    ldrh w2, [x19, #16]
    cmp w2, #PI4_ELF64_ET_EXEC
    b.ne .Lpi4_nonembedded_elf_bad
    ldrh w2, [x19, #18]
    cmp w2, #PI4_ELF64_EM_AARCH64
    b.ne .Lpi4_nonembedded_elf_bad
    ldr w2, [x19, #20]
    cmp w2, #PI4_ELF64_VERSION_CURRENT
    b.ne .Lpi4_nonembedded_elf_bad
    ldr x21, [x19, #24]
    ldr x22, [x19, #32]
    ldrh w2, [x19, #52]
    cmp w2, #PI4_ELF64_EHDR_SIZE
    b.ne .Lpi4_nonembedded_elf_bad
    ldrh w2, [x19, #54]
    cmp w2, #PI4_ELF64_PHDR_SIZE
    b.ne .Lpi4_nonembedded_elf_bad
    ldrh w2, [x19, #56]
    cbz w2, .Lpi4_nonembedded_elf_bad
    cmp w2, #PI4_ELF64_PHNUM_MAX
    b.hi .Lpi4_nonembedded_elf_bad
    uxtw x23, w2
    cmp x22, x20
    b.hs .Lpi4_nonembedded_elf_bad
    mov x5, #PI4_ELF64_PHDR_SIZE
    mul x6, x23, x5
    sub x7, x20, x22
    cmp x7, x6
    b.lo .Lpi4_nonembedded_elf_bad
    add x24, x19, x22
    mov x25, xzr
    mov x26, xzr
    mov x27, xzr
    mov x6, xzr

.Lpi4_nonembedded_phdr_loop:
    cmp x6, x23
    b.hs .Lpi4_nonembedded_phdr_done
    madd x7, x6, x5, x24
    ldr w8, [x7, #0]
    cmp w8, #PI4_ELF64_PT_LOAD
    b.ne .Lpi4_nonembedded_phdr_next
    ldr w18, [x7, #4]
    cbz w18, .Lpi4_nonembedded_elf_bad
    ldr x12, [x7, #8]
    ldr x13, [x7, #16]
    ldr x14, [x7, #24]
    ldr x15, [x7, #32]
    ldr x16, [x7, #40]
    ldr x17, [x7, #48]
    cbz x17, .Lpi4_nonembedded_elf_bad
    cbz x16, .Lpi4_nonembedded_elf_bad
    cmp x14, x13
    b.ne .Lpi4_nonembedded_elf_bad
    cmp x16, x15
    b.lo .Lpi4_nonembedded_elf_bad
    cmp x12, x20
    b.hi .Lpi4_nonembedded_elf_bad
    sub x2, x20, x12
    cmp x2, x15
    b.lo .Lpi4_nonembedded_elf_bad
    adds x2, x19, x12
    b.cs .Lpi4_nonembedded_elf_bad
    adds x9, x13, x16
    b.cs .Lpi4_nonembedded_elf_bad
    cbnz x26, .Lpi4_nonembedded_range_have_base
    mov x26, x13
    b .Lpi4_nonembedded_range_check_end
.Lpi4_nonembedded_range_have_base:
    cmp x13, x26
    csel x26, x13, x26, lo
.Lpi4_nonembedded_range_check_end:
    cmp x9, x27
    csel x27, x9, x27, hi

    mov x3, x13
    mov x10, x15
    cbz x10, .Lpi4_nonembedded_copy_done
.Lpi4_nonembedded_copy_loop:
    ldrb w11, [x2], #1
    strb w11, [x3], #1
    subs x10, x10, #1
    b.ne .Lpi4_nonembedded_copy_loop
.Lpi4_nonembedded_copy_done:
    cmp x21, x13
    b.lo .Lpi4_nonembedded_bss_zero
    sub x2, x21, x13
    cmp x2, x16
    b.hs .Lpi4_nonembedded_bss_zero
    tst w18, #PI4_ELF64_PF_X
    b.eq .Lpi4_nonembedded_elf_bad
    mov x25, x7

.Lpi4_nonembedded_bss_zero:
    cmp x16, x15
    b.eq .Lpi4_nonembedded_phdr_next
    adds x2, x13, x15
    b.cs .Lpi4_nonembedded_elf_bad
    sub x3, x16, x15
.Lpi4_nonembedded_bss_zero_loop:
    strb wzr, [x2], #1
    sub x3, x3, #1
    cbnz x3, .Lpi4_nonembedded_bss_zero_loop

.Lpi4_nonembedded_phdr_next:
    add x6, x6, #1
    b .Lpi4_nonembedded_phdr_loop

.Lpi4_nonembedded_phdr_done:
    cbz x25, .Lpi4_nonembedded_elf_bad
    cbz x26, .Lpi4_nonembedded_elf_bad
    cbz x27, .Lpi4_nonembedded_elf_bad
    dsb sy
    ic iallu
    dsb sy
    isb
    adr x2, pi4_status_pi4el0_image_base
    str x26, [x2]
    adr x2, pi4_status_pi4el0_image_end
    str x27, [x2]
    adr x2, pi4_status_pi4el0_image_bytes
    sub x3, x27, x26
    str x3, [x2]
    adr x2, pi4_status_pi4elf_base
    str x19, [x2]
    adr x2, pi4_status_pi4elf_entry
    str x21, [x2]
    adr x2, pi4_status_pi4elf_phdr
    str x24, [x2]
    adr x2, pi4_status_pi4elf_filesz
    ldr x3, [x25, #32]
    str x3, [x2]
    adr x2, pi4_status_pi4elf_phent
    mov x3, #PI4_ELF64_PHDR_SIZE
    str x3, [x2]
    adr x2, pi4_status_pi4elf_phnum
    str x23, [x2]
    adr x2, pi4_status_pi4elf_load_vaddr
    ldr x3, [x25, #16]
    str x3, [x2]
    adr x2, pi4_status_pi4elf_load_paddr
    ldr x3, [x25, #24]
    str x3, [x2]
    adr x2, pi4_status_pi4elf_load_filesz
    ldr x3, [x25, #32]
    str x3, [x2]
    adr x2, pi4_status_pi4elf_load_memsz
    ldr x3, [x25, #40]
    str x3, [x2]
    adr x2, pi4_status_pi4elf_load_flags
    ldr w3, [x25, #4]
    str x3, [x2]
    adr x2, pi4_status_pi4elf_load_align
    ldr x3, [x25, #48]
    str x3, [x2]
    mov x0, x21
    mov x1, x24
    mov x2, x23
    b .Lpi4_nonembedded_elf_restore

.Lpi4_nonembedded_elf_bad:
    mov x0, xzr

.Lpi4_nonembedded_elf_restore:
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret
.size pi4_prepare_nonembedded_init_elf, . - pi4_prepare_nonembedded_init_elf

.type pi4_build_nonembedded_user_stack, %function
pi4_build_nonembedded_user_stack:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    cbz x0, .Lpi4_nonembedded_stack_bad
    cbz x1, .Lpi4_nonembedded_stack_bad
    cmp x1, x0
    b.ls .Lpi4_nonembedded_stack_bad
    sub x2, x1, x0
    cmp x2, #PI4_EL0_STACK_FRAME_BYTES
    b.lo .Lpi4_nonembedded_stack_bad
    cmp x2, #PI4_EL0_STACK_TOTAL_BYTES
    b.hi .Lpi4_nonembedded_stack_bad
    bic x7, x1, #0xf
    sub x3, x7, #PI4_EL0_STACK_FRAME_BYTES
    cmp x3, x0
    b.lo .Lpi4_nonembedded_stack_bad

    mov x4, x3
    mov x5, #1
    str x5, [x4], #8
    adr x5, pi4_nonembedded_user_argv0_string
    adr x6, pi4_status_pi4exec_count
    ldr x6, [x6]
    cbz x6, .Lpi4_nonembedded_stack_have_argv0
    adr x6, pi4_status_pi4appreq_matched_asset
    ldr x6, [x6]
    mov x8, #PI4_VIBE_FILE_ASSET_APP_ELF_BASE
    cmp x6, x8
    b.lo .Lpi4_nonembedded_stack_have_argv0
    sub x6, x6, x8
    cmp x6, #PI4_VIBE_FILE_ASSET_APP_ELF_COUNT
    b.hs .Lpi4_nonembedded_stack_have_argv0
    adr x5, pi4_status_pi4appreq_path_copy
    b .Lpi4_nonembedded_stack_have_argv0
.Lpi4_nonembedded_stack_have_argv0:
    add x6, x3, #PI4_EL0_STACK_HEADER_BYTES
    mov x0, x6
    mov x1, x5
    bl pi4_copy_argv0_to_user_stack
    str x6, [x4], #8
    str xzr, [x4], #8
    str xzr, [x4], #8

    mov x5, #PI4_VIBE_AT_PHDR
    str x5, [x4], #8
    adr x6, pi4_status_pi4elf_phdr
    ldr x5, [x6]
    str x5, [x4], #8
    mov x5, #PI4_VIBE_AT_PHENT
    str x5, [x4], #8
    mov x5, #PI4_ELF64_PHDR_SIZE
    str x5, [x4], #8
    mov x5, #PI4_VIBE_AT_PHNUM
    str x5, [x4], #8
    adr x6, pi4_status_pi4elf_phnum
    ldr x5, [x6]
    str x5, [x4], #8
    mov x5, #PI4_VIBE_AT_PAGESZ
    str x5, [x4], #8
    mov x5, #4096
    str x5, [x4], #8
    mov x5, #PI4_VIBE_AT_ENTRY
    str x5, [x4], #8
    adr x6, pi4_status_pi4elf_entry
    ldr x5, [x6]
    str x5, [x4], #8
    str xzr, [x4], #8
    str xzr, [x4], #8

    adr x5, pi4_status_pi4ustack_sp
    str x3, [x5]
    adr x5, pi4_status_pi4ustack_top
    str x7, [x5]
    adr x5, pi4_status_pi4ustack_bytes
    mov x6, #PI4_EL0_STACK_FRAME_BYTES
    str x6, [x5]
    adr x5, pi4_status_pi4ustack_argc
    mov x6, #1
    str x6, [x5]
    adr x5, pi4_status_pi4ustack_argv
    add x6, x3, #8
    str x6, [x5]
    adr x5, pi4_status_pi4ustack_envp
    add x6, x3, #24
    str x6, [x5]
    adr x5, pi4_status_pi4ustack_auxv
    add x6, x3, #32
    str x6, [x5]
    adr x5, pi4_status_pi4ustack_flags
    mov x6, #PI4_VIBE_USER_START_REQUIRED_FLAGS
    str x6, [x5]

    mov x0, x3
    ldp x29, x30, [sp], #16
    ret

.Lpi4_nonembedded_stack_bad:
    mov x0, xzr
    ldp x29, x30, [sp], #16
    ret
.size pi4_build_nonembedded_user_stack, . - pi4_build_nonembedded_user_stack

.type pi4_record_nonembedded_init_launch, %function
pi4_record_nonembedded_init_launch:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    adr x2, pi4_status_pi4uabi
    ldr w3, =VIBE_PI4_STATUS_PI4UABI_OK
    str w3, [x2]
    adr x2, pi4_status_runtime_gate
    ldr w3, =VIBE_PI4_GATE_RUNTIME_OK
    str w3, [x2]
    adr x2, pi4_status_pi4elf
    ldr w3, =VIBE_PI4_STATUS_PI4ELF_OK
    str w3, [x2]

    ldr x2, =pi4_process_table
    mov x3, #PI4_PROC_STATE_INIT
    str x3, [x2, #0]
    mov x3, #PI4_PROC_PID_INIT
    str x3, [x2, #8]
    str x0, [x2, #16]
    adr x4, pi4_status_pi4ustack_sp
    ldr x4, [x4]
    str x4, [x2, #24]
    adr x4, pi4_status_pi4ustack_top
    ldr x4, [x4]
    str x4, [x2, #32]
    mov x3, #PI4_PROC_KIND_INIT
    str x3, [x2, #40]
    mov x3, #-1
    str x3, [x2, #48]
    mov x3, #PI4_SPSR_EL0T_IRQ_UNMASKED
    str x3, [x2, #56]

    adr x2, pi4_status_pi4ptable_used
    mov x3, #1
    str x3, [x2]
    adr x2, pi4_status_proc_current_pid
    mov x3, #PI4_PROC_PID_INIT
    str x3, [x2]
    adr x2, pi4_status_proc_last_pid
    str x3, [x2]
    adr x2, pi4_status_proc_next_pid
    mov x3, #PI4_PROC_PID_NEXT_INIT
    str x3, [x2]
    adr x2, pi4_status_proc_alloc_count
    mov x3, #1
    str x3, [x2]
    adr x2, pi4_status_proc_el0_launch_count
    str x3, [x2]
    adr x2, pi4_status_proc_el0_return_count
    str xzr, [x2]
    adr x2, pi4_status_proc_exec_launch_count
    str xzr, [x2]
    adr x2, pi4_status_proc_exec_pid
    str xzr, [x2]
    adr x2, pi4_status_proc_exec_slot
    mov x3, #-1
    str x3, [x2]
    adr x2, pi4_status_proc_exec_kind
    str xzr, [x2]
    adr x2, pi4_status_proc_exec_state
    str xzr, [x2]
    adr x2, pi4_status_proc_exec_spsr
    str xzr, [x2]
    adr x2, pi4_status_proc_return_pid
    str xzr, [x2]
    adr x2, pi4_status_proc_return_slot
    mov x3, #-1
    str x3, [x2]
    adr x2, pi4_status_proc_return_kind
    str xzr, [x2]
    adr x2, pi4_status_proc_return_code
    str xzr, [x2]
    adr x2, pi4_status_proc_return_elr
    str xzr, [x2]
    adr x2, pi4_status_proc_fault_pid
    str xzr, [x2]
    adr x2, pi4_status_proc_fault_slot
    mov x3, #-1
    str x3, [x2]
    adr x2, pi4_status_proc_fault_kind
    str xzr, [x2]
    adr x2, pi4_status_proc_fault_mode
    str xzr, [x2]
    adr x2, pi4_status_proc_fault_esr
    str xzr, [x2]
    adr x2, pi4_status_proc_fault_elr
    str xzr, [x2]
    adr x2, pi4_status_proc_fault_count
    str xzr, [x2]

    bl pi4_seed_live_preempt_probe

    adr x0, pi4_status_pi4ustack_sp
    ldr x1, [x0]
    adr x0, pi4_status_pi4elf_entry
    ldr x0, [x0]
    mov x2, #PI4_PROC_PID_INIT
    mov x3, #PI4_PROC_KIND_INIT
    mov x4, #PI4_SPSR_EL0T_IRQ_UNMASKED
    bl pi4_record_process_context_skeleton
    ldp x29, x30, [sp], #16
    ret
.size pi4_record_nonembedded_init_launch, . - pi4_record_nonembedded_init_launch

.type pi4_record_nonembedded_app_launch, %function
pi4_record_nonembedded_app_launch:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    mov x9, x2
    mov x13, x3

    adr x2, pi4_status_pi4uabi
    ldr w3, =VIBE_PI4_STATUS_PI4UABI_OK
    str w3, [x2]
    adr x2, pi4_status_runtime_gate
    ldr w3, =VIBE_PI4_GATE_RUNTIME_OK
    str w3, [x2]
    adr x2, pi4_status_pi4elf
    ldr w3, =VIBE_PI4_STATUS_PI4ELF_OK
    str w3, [x2]

    mov x5, #PI4_PROC_KIND_APP_BASE
    add x5, x5, x9

    adr x12, pi4_status_proc_current_pid
    ldr x12, [x12]
    cbnz x12, .Lpi4_record_app_have_last_pid
    mov x12, #PI4_PROC_PID_INIT
.Lpi4_record_app_have_last_pid:

    adr x10, pi4_status_proc_next_pid
    ldr x10, [x10]
    cbnz x10, .Lpi4_record_app_have_pid
    mov x10, #PI4_PROC_PID_APP_FIRST
.Lpi4_record_app_have_pid:

    ldr x2, =pi4_process_table
    add x2, x2, #PI4_PROC_TABLE_ENTRY_BYTES
    mov x3, #PI4_PROC_STATE_APP
    str x3, [x2, #0]
    str x10, [x2, #8]
    str x0, [x2, #16]
    adr x4, pi4_status_pi4ustack_sp
    ldr x4, [x4]
    str x4, [x2, #24]
    adr x4, pi4_status_pi4ustack_top
    ldr x4, [x4]
    str x4, [x2, #32]
    str x5, [x2, #40]
    str x9, [x2, #48]
    mov x3, #PI4_SPSR_EL0T_IRQ_UNMASKED
    str x3, [x2, #56]

    ldr x11, =pi4_process_table
    mov x3, #PI4_PROC_STATE_REPLACED
    str x3, [x11, #0]
    adr x3, pi4_status_sysframe_elr_el1
    ldr x3, [x3]
    cbz x3, .Lpi4_record_app_parent_elr_done
    str x3, [x11, #16]
.Lpi4_record_app_parent_elr_done:
    adr x3, pi4_status_sysframe_sp_el0
    ldr x3, [x3]
    cbz x3, .Lpi4_record_app_parent_sp_done
    str x3, [x11, #24]
.Lpi4_record_app_parent_sp_done:
    mov x3, #PI4_PROC_KIND_INIT
    str x3, [x11, #40]
    mov x3, #-1
    str x3, [x11, #48]
    adr x3, pi4_status_sysframe_spsr_el1
    ldr x3, [x3]
    cbnz x3, .Lpi4_record_app_parent_spsr_ready
    mov x3, #PI4_SPSR_EL0T_IRQ_UNMASKED
.Lpi4_record_app_parent_spsr_ready:
    str x3, [x11, #56]
    cbz x13, .Lpi4_record_app_parent_frame_done
    mov x0, x13
    ldr x1, =pi4_process_irq_frames
    bl pi4_copy_irq_frame_256
    ldr x0, =pi4_process_irq_frames
    str xzr, [x0]
.Lpi4_record_app_parent_frame_done:

    adr x2, pi4_status_pi4ptable_used
    mov x3, #2
    str x3, [x2]
    adr x2, pi4_status_proc_current_pid
    str x10, [x2]
    adr x2, pi4_status_proc_last_pid
    str x10, [x2]
    adr x2, pi4_status_proc_next_pid
    add x3, x10, #1
    str x3, [x2]
    adr x2, pi4_status_proc_alloc_count
    ldr x3, [x2]
    add x3, x3, #1
    str x3, [x2]
    adr x2, pi4_status_proc_el0_launch_count
    ldr x3, [x2]
    add x3, x3, #1
    str x3, [x2]
    adr x2, pi4_status_proc_exec_launch_count
    ldr x3, [x2]
    add x3, x3, #1
    str x3, [x2]
    adr x2, pi4_status_proc_exec_pid
    str x10, [x2]
    adr x2, pi4_status_proc_exec_slot
    str x9, [x2]
    adr x2, pi4_status_proc_exec_kind
    str x5, [x2]
    adr x2, pi4_status_proc_exec_state
    mov x3, #PI4_PROC_STATE_APP
    str x3, [x2]
    adr x2, pi4_status_proc_exec_spsr
    mov x3, #PI4_SPSR_EL0T_IRQ_UNMASKED
    str x3, [x2]
    adr x2, pi4_status_proc_return_pid
    str xzr, [x2]
    adr x2, pi4_status_proc_return_slot
    mov x3, #-1
    str x3, [x2]
    adr x2, pi4_status_proc_return_kind
    str xzr, [x2]
    adr x2, pi4_status_proc_return_code
    str xzr, [x2]
    adr x2, pi4_status_proc_return_elr
    str xzr, [x2]
    adr x2, pi4_status_proc_fault_pid
    str xzr, [x2]
    adr x2, pi4_status_proc_fault_slot
    mov x3, #-1
    str x3, [x2]
    adr x2, pi4_status_proc_fault_kind
    str xzr, [x2]
    adr x2, pi4_status_proc_fault_mode
    str xzr, [x2]
    adr x2, pi4_status_proc_fault_esr
    str xzr, [x2]
    adr x2, pi4_status_proc_fault_elr
    str xzr, [x2]

    bl pi4_seed_live_preempt_probe

    adr x0, pi4_status_pi4ustack_sp
    ldr x1, [x0]
    adr x0, pi4_status_pi4elf_entry
    ldr x0, [x0]
    ldr x2, =pi4_process_table
    add x2, x2, #PI4_PROC_TABLE_ENTRY_BYTES
    ldr x3, [x2, #40]
    ldr x2, [x2, #8]
    mov x4, #PI4_SPSR_EL0T_IRQ_UNMASKED
    bl pi4_record_process_context_skeleton
    ldp x29, x30, [sp], #16
    ret
.size pi4_record_nonembedded_app_launch, . - pi4_record_nonembedded_app_launch

.type pi4_exec_app_from_vfs, %function
pi4_exec_app_from_vfs:
    stp x29, x30, [sp, #-112]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]

    mov x19, x0
    mov x28, x1
    mov x20, x2

    adr x0, pi4_status_pi4vfs
    ldr w0, [x0]
    ldr w1, =PI4_START_STORAGE_VFS_OK
    cmp w0, w1
    b.ne .Lpi4_exec_app_enosys

    adr x0, pi4_status_pi4appvfs_status
    ldr w0, [x0]
    ldr w1, =PI4_START_STORAGE_FILE_OK
    cmp w0, w1
    b.ne .Lpi4_exec_app_enosys

    adr x0, pi4_status_pi4appvfs_plan_sectors
    ldr x21, [x0]
    adr x0, pi4_status_pi4appvfs_plan_bytes
    ldr x22, [x0]
    cbz x21, .Lpi4_exec_app_enosys
    cbz x22, .Lpi4_exec_app_enosys
    mov x0, #PI4_START_STORAGE_APP_ELF_MAX_READ_SECTORS
    cmp x21, x0
    b.hi .Lpi4_exec_app_enosys
    mov x0, #PI4_START_STORAGE_SECTOR_BYTES
    mul x1, x21, x0
    cmp x22, x1
    b.hi .Lpi4_exec_app_enosys

    adr x0, pi4_start_storage_app_elf_buffer
    mov x1, #PI4_START_STORAGE_APP_ELF_BUFFER_BYTES
    bl pi4_zero_buffer

    adr x0, pi4_status_pi4appvfs_entry_index
    adr x1, pi4_start_storage_app_elf_buffer
    mov x2, xzr
    mov x3, x21
    mov x4, #1
    bl pi4_read_storage_file_sectors
    cbnz x0, .Lpi4_exec_app_enosys
    mov x27, x1

    cbnz x20, .Lpi4_exec_app_source_read_count
    mov x0, x19
    bl pi4_app_record_ptr_by_index
    cbz x0, .Lpi4_exec_app_enosys
    ldr x25, [x0, #PI4_VIBE_APP_RECORD_ELF_READ_COUNT]
    b .Lpi4_exec_app_have_read_count
.Lpi4_exec_app_source_read_count:
    mov x25, x20
    add x25, x25, #56
.Lpi4_exec_app_have_read_count:
    str x27, [x25]
    adr x25, pi4_status_pi4appvfs_read_count
    str x27, [x25]

    adr x0, pi4_start_storage_app_elf_buffer
    mov x1, x22
    bl pi4_prepare_nonembedded_init_elf
    cbz x0, .Lpi4_exec_app_enosys
    mov x26, x0

    adr x0, pi4_el0_stack
    adr x1, pi4_el0_stack_top
    bl pi4_build_nonembedded_user_stack
    cbz x0, .Lpi4_exec_app_enosys
    mov x27, x0

    mov x0, x26
    mov x1, x27
    mov x2, x19
    mov x3, x28
    bl pi4_record_nonembedded_app_launch

    bl pi4_start_runtime_timer
    adr x0, pi4_status_pi4timer
    ldr w0, [x0]
    ldr w1, =VIBE_PI4_STATUS_PI4TIMER_OK
    cmp w0, w1
    b.ne .Lpi4_exec_app_timer_ready
    mov x0, #1
    msr CNTP_TVAL_EL0, x0
    mov x0, #1
    msr CNTP_CTL_EL0, x0
    isb
.Lpi4_exec_app_timer_ready:
    msr SP_EL0, x27
    msr ELR_EL1, x26
    mov x0, #PI4_SPSR_EL0T_IRQ_UNMASKED
    msr SPSR_EL1, x0
    isb
    mov x0, xzr
    b .Lpi4_exec_app_done

.Lpi4_exec_app_enosys:
    mov x0, #PI4_VIBE_ENOSYS
    neg x0, x0

.Lpi4_exec_app_done:
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #112
    ret
.size pi4_exec_app_from_vfs, . - pi4_exec_app_from_vfs

.type pi4_zero_buffer, %function
pi4_zero_buffer:
    cbz x1, .Lpi4_zero_buffer_done
.Lpi4_zero_buffer_loop:
    str xzr, [x0], #8
    subs x1, x1, #8
    b.ne .Lpi4_zero_buffer_loop
.Lpi4_zero_buffer_done:
    ret
.size pi4_zero_buffer, . - pi4_zero_buffer

.type pi4_prepare_storage_handoff, %function
pi4_prepare_storage_handoff:
    stp x29, x30, [sp, #-96]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]

    adr x0, pi4_nonembedded_init_elf_buffer
    str xzr, [x0]
    adr x0, pi4_nonembedded_init_elf_bytes
    str xzr, [x0]
    adr x0, pi4_nonembedded_init_stack_base
    str xzr, [x0]
    adr x0, pi4_nonembedded_init_stack_top
    str xzr, [x0]

    ldr x16, =pi4_storage_reset_status
    blr x16
    adr x0, msg_stage_storage_reset
    bl pi4_uart_write_string
    ldr x16, =pi4_storage_probe_controller_status
    blr x16
    adr x0, msg_stage_storage_probe
    bl pi4_uart_write_string

    mov x0, xzr
    mov x1, #1
    adr x2, pi4_start_storage_mbr_sector_buffer
    adr x0, msg_stage_storage_read0
    bl pi4_uart_write_string
    mov x0, xzr
    mov x1, #1
    adr x2, pi4_start_storage_mbr_sector_buffer
    ldr x16, =pi4_storage_read_blocks
    blr x16
    cbnz x0, .Lpi4_prepare_storage_handoff_done

    adr x0, pi4_start_storage_mbr_sector_buffer
    adr x1, pi4_storage_boot_mbr_sector_buffer
    str x0, [x1]
    ldr x16, =pi4_storage_parse_mbr
    blr x16
    cbz w0, .Lpi4_prepare_storage_handoff_done

    adr x0, pi4_storage_status_mbr_part_lba
    ldr x19, [x0]
    mov x0, x19
    mov x1, #1
    adr x2, pi4_start_storage_bpb_sector_buffer
    ldr x16, =pi4_storage_read_blocks
    blr x16
    cbnz x0, .Lpi4_prepare_storage_handoff_done

    adr x0, pi4_start_storage_bpb_sector_buffer
    adr x1, pi4_storage_boot_bpb_sector_buffer
    str x0, [x1]
    mov x1, x19
    ldr x16, =pi4_storage_parse_fat_bpb
    blr x16
    cbz w0, .Lpi4_prepare_storage_handoff_done

    adr x0, pi4_storage_status_pi4fat
    ldr w1, =PI4_START_STORAGE_BPB_OK
    str w1, [x0]

    adr x0, pi4_storage_status_bpb_bytes_per_sector
    ldr x20, [x0]
    cmp x20, #PI4_START_STORAGE_SECTOR_BYTES
    b.ne .Lpi4_prepare_storage_handoff_done

    adr x0, pi4_storage_status_bpb_root_dir_lba
    ldr x21, [x0]
    adr x0, pi4_storage_status_bpb_root_dir_sectors
    ldr x22, [x0]
    cbnz x22, .Lpi4_prepare_storage_have_root_request

    adr x0, pi4_storage_status_bpb_root_cluster
    ldr x23, [x0]
    cmp x23, #2
    b.lo .Lpi4_prepare_storage_handoff_done
    adr x0, pi4_storage_status_bpb_sectors_per_cluster
    ldr x22, [x0]
    cbz x22, .Lpi4_prepare_storage_handoff_done
    adr x0, pi4_storage_status_bpb_data_lba
    ldr x21, [x0]
    sub x23, x23, #2
    madd x21, x23, x22, x21

.Lpi4_prepare_storage_have_root_request:
    cbz x22, .Lpi4_prepare_storage_handoff_done
    mov x23, #PI4_START_STORAGE_MAX_READ_SECTORS
    cmp x22, x23
    csel x22, x22, x23, lo
    mov x24, #PI4_START_STORAGE_SECTOR_BYTES
    mul x24, x22, x24

    mov x0, x21
    mov x1, x22
    adr x2, pi4_start_storage_root_dir_buffer
    ldr x16, =pi4_storage_read_blocks
    blr x16
    cbnz x0, .Lpi4_prepare_storage_handoff_done

    adr x0, pi4_start_storage_bpb_sector_buffer
    mov x1, x19
    adr x2, pi4_start_storage_root_dir_buffer
    mov x3, x24
    ldr x16, =pi4_storage_parse_fat_root
    blr x16
    cbz w0, .Lpi4_prepare_storage_handoff_done

    adr x0, pi4_storage_status_proof_dir
    mov x1, #PI4_START_STORAGE_ASSET_DIR_PROOF
    bl pi4_prepare_storage_scan_dir_cluster
    adr x0, pi4_storage_status_assets_dir
    mov x1, #PI4_START_STORAGE_ASSET_DIR_ASSETS
    bl pi4_prepare_storage_scan_dir_cluster
    adr x0, pi4_storage_status_asset_maps_dir
    mov x1, #PI4_START_STORAGE_ASSET_DIR_MAPS
    bl pi4_prepare_storage_scan_dir_cluster
    adr x0, pi4_storage_status_asset_textures_dir
    mov x1, #PI4_START_STORAGE_ASSET_DIR_TEXTURES
    bl pi4_prepare_storage_scan_dir_cluster
    adr x0, pi4_storage_status_id1_dir
    mov x1, #PI4_START_STORAGE_ASSET_DIR_ID1
    bl pi4_prepare_storage_scan_dir_cluster
    adr x0, pi4_storage_status_system_dir
    mov x1, #PI4_START_STORAGE_ASSET_DIR_SYSTEM
    bl pi4_prepare_storage_scan_dir_cluster
    adr x0, pi4_storage_status_apps_dir
    mov x1, #PI4_START_STORAGE_ASSET_DIR_APPS
    bl pi4_prepare_storage_scan_dir_cluster
    bl pi4_prepare_storage_scan_app_dirs

    adr x0, pi4_storage_status_init_elf
    ldr w1, [x0]
    ldr w2, =PI4_START_STORAGE_FILE_OK
    cmp w1, w2
    b.ne .Lpi4_prepare_storage_handoff_done

    adr x0, pi4_storage_status_init_elf_plan_lba
    ldr x25, [x0]
    adr x0, pi4_storage_status_init_elf_plan_sectors
    ldr x26, [x0]
    adr x0, pi4_storage_status_init_elf_plan_bytes
    ldr x27, [x0]
    cbz x26, .Lpi4_prepare_storage_handoff_done
    cbz x27, .Lpi4_prepare_storage_handoff_done
    mov x28, #PI4_START_STORAGE_MAX_READ_SECTORS
    cmp x26, x28
    b.hi .Lpi4_prepare_storage_handoff_done
    mov x28, #PI4_START_STORAGE_SECTOR_BYTES
    mul x28, x26, x28
    cmp x27, x28
    b.hi .Lpi4_prepare_storage_handoff_done

    mov x0, x25
    mov x1, x26
    adr x2, pi4_start_storage_init_elf_buffer
    ldr x16, =pi4_storage_read_blocks
    blr x16
    cbnz x0, .Lpi4_prepare_storage_handoff_done

    adr x0, pi4_storage_status_block_copied_sectors
    ldr x1, [x0]
    cmp x1, x26
    b.lo .Lpi4_prepare_storage_handoff_done
    adr x0, pi4_storage_status_block_copied_bytes
    ldr x2, [x0]
    cmp x2, x27
    b.lo .Lpi4_prepare_storage_handoff_done
    adr x0, pi4_storage_status_init_elf_read_count
    str x1, [x0]

    adr x0, pi4_nonembedded_init_elf_buffer
    adr x1, pi4_start_storage_init_elf_buffer
    str x1, [x0]
    adr x0, pi4_nonembedded_init_elf_bytes
    str x27, [x0]
    adr x0, pi4_nonembedded_init_stack_base
    adr x1, pi4_el0_stack
    str x1, [x0]
    adr x0, pi4_nonembedded_init_stack_top
    adr x1, pi4_el0_stack_top
    str x1, [x0]

    mov x0, #PI4_VIBE_APP_RECORD_ELF_STATUS
    bl pi4_app_records_have_file_status
    cbz x0, .Lpi4_prepare_storage_handoff_done

    adr x0, pi4_storage_status_app_index
    ldr w1, [x0]
    ldr w2, =PI4_START_STORAGE_FILE_OK
    cmp w1, w2
    b.ne .Lpi4_prepare_storage_handoff_done

    mov x0, #PI4_VIBE_APP_RECORD_MANIFEST_META
    bl pi4_app_records_have_file_status
    cbz x0, .Lpi4_prepare_storage_handoff_done

    adr x0, pi4_storage_status_doom1_wad
    ldr w1, [x0]
    ldr w2, =PI4_START_STORAGE_FILE_OK
    cmp w1, w2
    b.ne .Lpi4_prepare_storage_handoff_done

    adr x0, pi4_storage_status_pi4vfs
    ldr w1, =PI4_START_STORAGE_VFS_OK
    str w1, [x0]

    adr x0, pi4_storage_status_manifest_txt
    ldr w1, [x0]
    ldr w2, =PI4_START_STORAGE_FILE_OK
    cmp w1, w2
    b.ne .Lpi4_prepare_storage_handoff_done

    adr x0, pi4_storage_status_id1_dir
    ldr x1, [x0]
    cbz x1, .Lpi4_prepare_storage_no_pak
    adr x0, pi4_storage_status_pak0_pak
    ldr w1, [x0]
    ldr w2, =PI4_START_STORAGE_FILE_OK
    cmp w1, w2
    b.ne .Lpi4_prepare_storage_handoff_done
    ldr x1, [x0, #16]
    cbz x1, .Lpi4_prepare_storage_handoff_done
.Lpi4_prepare_storage_no_pak:
    adr x0, pi4_storage_status_pi4vfs
    ldr w1, =PI4_START_STORAGE_VFS_OK
    str w1, [x0]

.Lpi4_prepare_storage_handoff_done:
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret
.size pi4_prepare_storage_handoff, . - pi4_prepare_storage_handoff

.type pi4_prepare_storage_scan_app_dirs, %function
pi4_prepare_storage_scan_app_dirs:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    stp x19, x20, [sp, #16]

    adr x19, pi4_app_file_record_table
    mov x20, xzr
.Lpi4_prepare_storage_scan_app_dirs_next:
    cmp x20, #PI4_VIBE_APP_RECORD_COUNT
    b.hs .Lpi4_prepare_storage_scan_app_dirs_done
    ldr x0, [x19, #PI4_VIBE_APP_RECORD_DIR_STATUS]
    ldr x2, [x0]
    cbz x2, .Lpi4_prepare_storage_scan_app_dirs_step
    mov x1, #PI4_START_STORAGE_ASSET_DIR_APP_BASE
    add x1, x1, x20
    bl pi4_prepare_storage_scan_dir_cluster
.Lpi4_prepare_storage_scan_app_dirs_step:
    add x19, x19, #PI4_VIBE_APP_RECORD_BYTES
    add x20, x20, #1
    b .Lpi4_prepare_storage_scan_app_dirs_next

.Lpi4_prepare_storage_scan_app_dirs_done:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size pi4_prepare_storage_scan_app_dirs, . - pi4_prepare_storage_scan_app_dirs

.type pi4_app_records_have_file_status, %function
pi4_app_records_have_file_status:
    mov x1, x0
    adr x2, pi4_app_file_record_table
    mov x3, xzr
    mov x7, xzr
    ldr w6, =PI4_START_STORAGE_FILE_OK
.Lpi4_app_records_have_file_status_next:
    cmp x3, #PI4_VIBE_APP_RECORD_COUNT
    b.hs .Lpi4_app_records_have_file_status_ok
    ldr x8, [x2, #PI4_VIBE_APP_RECORD_DIR_STATUS]
    ldr x8, [x8]
    cbnz x8, .Lpi4_app_records_have_file_status_active
    cmp x3, #PI4_VIBE_REQUIRED_APP_RECORD_COUNT
    b.lo .Lpi4_app_records_have_file_status_bad
    b .Lpi4_app_records_have_file_status_step
.Lpi4_app_records_have_file_status_active:
    add x7, x7, #1
    add x4, x2, x1
    ldr x4, [x4]
    ldr w5, [x4]
    cmp w5, w6
    b.ne .Lpi4_app_records_have_file_status_bad
.Lpi4_app_records_have_file_status_step:
    add x2, x2, #PI4_VIBE_APP_RECORD_BYTES
    add x3, x3, #1
    b .Lpi4_app_records_have_file_status_next

.Lpi4_app_records_have_file_status_ok:
    cmp x7, #PI4_VIBE_REQUIRED_APP_RECORD_COUNT
    b.lo .Lpi4_app_records_have_file_status_bad
    mov x0, #1
    ret
.Lpi4_app_records_have_file_status_bad:
    mov x0, xzr
    ret
.size pi4_app_records_have_file_status, . - pi4_app_records_have_file_status

.type pi4_prepare_storage_scan_dir_cluster, %function
pi4_prepare_storage_scan_dir_cluster:
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]

    mov x19, x0
    mov x20, x1
    ldr x21, [x19, #16]
    cmp x21, #2
    b.lo .Lpi4_prepare_storage_scan_dir_done

    adr x0, pi4_storage_status_bpb_sectors_per_cluster
    ldr x22, [x0]
    cbz x22, .Lpi4_prepare_storage_scan_dir_done
    mov x0, #PI4_START_STORAGE_MAX_READ_SECTORS
    cmp x22, x0
    b.hi .Lpi4_prepare_storage_scan_dir_done

    adr x0, pi4_storage_status_bpb_data_lba
    ldr x23, [x0]
    sub x21, x21, #2
    madd x21, x21, x22, x23

    mov x0, x21
    mov x1, x22
    adr x2, pi4_start_storage_app_elf_buffer
    ldr x16, =pi4_storage_read_blocks
    blr x16
    cbnz x0, .Lpi4_prepare_storage_scan_dir_done

    adr x0, pi4_start_storage_app_elf_buffer
    mov x1, #PI4_START_STORAGE_SECTOR_BYTES
    mul x1, x22, x1
    mov x2, x20
    ldr x16, =pi4_storage_parse_asset_dir
    blr x16

.Lpi4_prepare_storage_scan_dir_done:
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret
.size pi4_prepare_storage_scan_dir_cluster, . - pi4_prepare_storage_scan_dir_cluster

.type pi4_read_fat16_next_cluster, %function
pi4_read_fat16_next_cluster:
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]

    mov x19, x0
    adr x0, pi4_storage_status_bpb_cluster_count
    ldr x24, [x0]
    cbz x24, .Lpi4_read_fat16_next_cluster_fail
    cmp x19, #2
    b.lo .Lpi4_read_fat16_next_cluster_fail
    sub x0, x19, #2
    cmp x0, x24
    b.hs .Lpi4_read_fat16_next_cluster_fail

    lsl x20, x19, #1
    lsr x21, x20, #9
    and x22, x20, #0x1ff
    adr x0, pi4_storage_status_bpb_fat0_lba
    ldr x0, [x0]
    cbz x0, .Lpi4_read_fat16_next_cluster_fail
    add x0, x0, x21
    mov x1, #1
    ldr x2, =pi4_start_storage_user_file_buffer
    ldr x16, =pi4_storage_read_blocks
    blr x16
    cbnz x0, .Lpi4_read_fat16_next_cluster_return

    adr x0, pi4_storage_status_block_copied_sectors
    ldr x0, [x0]
    cmp x0, #1
    b.lo .Lpi4_read_fat16_next_cluster_fail

    ldr x0, =pi4_start_storage_user_file_buffer
    add x0, x0, x22
    ldrh w23, [x0]
    mov x0, #0xfff7
    cmp x23, x0
    b.eq .Lpi4_read_fat16_next_cluster_fail
    mov x0, #0xfff8
    cmp x23, x0
    b.hs .Lpi4_read_fat16_next_cluster_fail
    cmp x23, #2
    b.lo .Lpi4_read_fat16_next_cluster_fail
    sub x0, x23, #2
    cmp x0, x24
    b.hs .Lpi4_read_fat16_next_cluster_fail

    mov x0, xzr
    mov x1, x23
    b .Lpi4_read_fat16_next_cluster_done

.Lpi4_read_fat16_next_cluster_fail:
    mov x0, #PI4_VIBE_ENOSYS
    neg x0, x0
.Lpi4_read_fat16_next_cluster_return:
    mov x1, xzr

.Lpi4_read_fat16_next_cluster_done:
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret
.size pi4_read_fat16_next_cluster, . - pi4_read_fat16_next_cluster

.type pi4_resolve_file_sector_lba, %function
pi4_resolve_file_sector_lba:
    stp x29, x30, [sp, #-112]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]

    mov x19, x0
    mov x20, x1
    cbz x19, .Lpi4_resolve_file_sector_lba_fail
    adr x0, pi4_storage_status_fat_type
    ldr w0, [x0]
    ldr w1, =PI4_START_STORAGE_FAT16
    cmp w0, w1
    b.ne .Lpi4_resolve_file_sector_lba_fail

    ldr x25, [x19, #16]
    ldr x28, [x19, #40]
    cbz x28, .Lpi4_resolve_file_sector_lba_fail
    cmp x20, x28
    b.hs .Lpi4_resolve_file_sector_lba_fail
    cmp x25, #2
    b.lo .Lpi4_resolve_file_sector_lba_fail

    adr x0, pi4_storage_status_bpb_sectors_per_cluster
    ldr x21, [x0]
    cbz x21, .Lpi4_resolve_file_sector_lba_fail
    adr x0, pi4_storage_status_bpb_cluster_count
    ldr x22, [x0]
    cbz x22, .Lpi4_resolve_file_sector_lba_fail
    sub x0, x25, #2
    cmp x0, x22
    b.hs .Lpi4_resolve_file_sector_lba_fail
    adr x0, pi4_storage_status_bpb_fat0_lba
    ldr x23, [x0]
    cbz x23, .Lpi4_resolve_file_sector_lba_fail
    adr x0, pi4_storage_status_bpb_data_lba
    ldr x24, [x0]
    cbz x24, .Lpi4_resolve_file_sector_lba_fail

    udiv x26, x20, x21
    msub x27, x26, x21, x20
    mov x28, x26
.Lpi4_resolve_file_sector_lba_walk:
    cbz x28, .Lpi4_resolve_file_sector_lba_have_cluster
    mov x0, x25
    bl pi4_read_fat16_next_cluster
    cbnz x0, .Lpi4_resolve_file_sector_lba_return
    mov x25, x1
    cmp x25, #2
    b.lo .Lpi4_resolve_file_sector_lba_fail
    sub x0, x25, #2
    cmp x0, x22
    b.hs .Lpi4_resolve_file_sector_lba_fail
    sub x28, x28, #1
    b .Lpi4_resolve_file_sector_lba_walk

.Lpi4_resolve_file_sector_lba_have_cluster:
    sub x1, x25, #2
    madd x1, x1, x21, x24
    add x1, x1, x27
    sub x2, x21, x27
    mov x3, x25
    mov x0, xzr
    b .Lpi4_resolve_file_sector_lba_done

.Lpi4_resolve_file_sector_lba_fail:
    mov x0, #PI4_VIBE_ENOSYS
    neg x0, x0
.Lpi4_resolve_file_sector_lba_return:
    mov x1, xzr
    mov x2, xzr
    mov x3, xzr

.Lpi4_resolve_file_sector_lba_done:
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #112
    ret
.size pi4_resolve_file_sector_lba, . - pi4_resolve_file_sector_lba

.type pi4_read_storage_file_sectors, %function
pi4_read_storage_file_sectors:
    stp x29, x30, [sp, #-112]!
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
    mov x28, x4
    mov x23, xzr
    cbz x19, .Lpi4_read_storage_file_sectors_fail
    cbz x20, .Lpi4_read_storage_file_sectors_fail
    cbz x22, .Lpi4_read_storage_file_sectors_ok
    ldr x25, [x19, #40]
    cbz x25, .Lpi4_read_storage_file_sectors_fail
    add x0, x21, x22
    cmp x0, x21
    b.lo .Lpi4_read_storage_file_sectors_fail
    cmp x0, x25
    b.hi .Lpi4_read_storage_file_sectors_fail

    ldr x25, [x19, #32]
    cbz x25, .Lpi4_read_storage_file_sectors_fail
    add x25, x25, x21
    mov x26, x22
    mov x27, xzr
    cbz x26, .Lpi4_read_storage_file_sectors_fail

.Lpi4_read_storage_file_sectors_loop:
    cbz x22, .Lpi4_read_storage_file_sectors_ok
    cmp x22, x26
    csel x24, x22, x26, lo
    mov x0, #PI4_START_STORAGE_BLOCK_MAX_READ_SECTORS
    cmp x24, x0
    csel x24, x24, x0, lo

    mov x0, x25
    mov x1, x24
    mov x2, x20
    ldr x16, =pi4_storage_read_blocks
    blr x16
    cbnz x0, .Lpi4_read_storage_file_sectors_return
    adr x0, pi4_storage_status_block_copied_sectors
    ldr x0, [x0]
    cmp x0, x24
    b.lo .Lpi4_read_storage_file_sectors_fail
    adr x0, pi4_storage_status_block_copied_bytes
    ldr x0, [x0]
    mov x1, #PI4_START_STORAGE_SECTOR_BYTES
    mul x1, x24, x1
    cmp x0, x1
    b.lo .Lpi4_read_storage_file_sectors_fail

    add x23, x23, x24
    add x21, x21, x24
    sub x22, x22, x24
    add x25, x25, x24
    sub x26, x26, x24
    tbz x28, #0, .Lpi4_read_storage_file_sectors_no_dest_advance
    mov x0, #PI4_START_STORAGE_SECTOR_BYTES
    madd x20, x24, x0, x20
.Lpi4_read_storage_file_sectors_no_dest_advance:
    b .Lpi4_read_storage_file_sectors_loop

.Lpi4_read_storage_file_sectors_ok:
    mov x0, xzr
    mov x1, x23
    b .Lpi4_read_storage_file_sectors_done

.Lpi4_read_storage_file_sectors_fail:
    mov x0, #PI4_VIBE_ENOSYS
    neg x0, x0
.Lpi4_read_storage_file_sectors_return:
    mov x1, x23

.Lpi4_read_storage_file_sectors_done:
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #112
    ret
.size pi4_read_storage_file_sectors, . - pi4_read_storage_file_sectors

.type pi4_read_storage_file_plan_status, %function
pi4_read_storage_file_plan_status:
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    str x25, [sp, #64]

    mov x19, x0
    mov x20, x1
    str xzr, [x19, #56]
    cbz x20, .Lpi4_read_storage_file_plan_fail
    ldr x21, [x19, #32]
    ldr x22, [x19, #40]
    ldr x25, [x19, #48]
    cbz x21, .Lpi4_read_storage_file_plan_fail
    cbz x22, .Lpi4_read_storage_file_plan_fail
    cbz x25, .Lpi4_read_storage_file_plan_fail

    mov x0, x19
    mov x1, x20
    mov x2, xzr
    mov x3, x22
    mov x4, xzr
    bl pi4_read_storage_file_sectors
    cbnz x0, .Lpi4_read_storage_file_plan_fail
    str x1, [x19, #56]

.Lpi4_read_storage_file_plan_ok:
    mov x0, xzr
    b .Lpi4_read_storage_file_plan_done

.Lpi4_read_storage_file_plan_fail:
    mov x0, #1

.Lpi4_read_storage_file_plan_done:
    ldr x25, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret
.size pi4_read_storage_file_plan_status, . - pi4_read_storage_file_plan_status

.type pi4_write_uart_input_event, %function
pi4_write_uart_input_event:
    tbnz x1, #31, .Lpi4_write_uart_key_input_event
    adr x2, pi4_status_timer_ticks
    ldr x2, [x2]
    str x2, [x0, #0]
    mov x2, #PI4_VIBE_INPUT_DEVICE_UART
    str x2, [x0, #8]
    mov x2, #PI4_VIBE_INPUT_EVENT_UART
    str x2, [x0, #16]
    str x1, [x0, #24]
    mov x2, #1
    str x2, [x0, #32]
    str xzr, [x0, #40]
    mov x2, #PI4_VIBE_INPUT_SOURCE_UART_SERIAL
    str x2, [x0, #48]
    ret
.Lpi4_write_uart_key_input_event:
    adr x2, pi4_status_timer_ticks
    ldr x2, [x2]
    str x2, [x0, #0]
    ubfx x4, x1, #PI4_VIBE_INPUT_EVENT_KEY_TOKEN_HID_SHIFT, #8
    mov x5, #PI4_VIBE_INPUT_DEVICE_KEYBOARD
    cbz x4, .Lpi4_write_uart_key_input_device_ready
    adr x6, pi4_status_pi4ctx_kind
    ldr x6, [x6]
    mov x7, #PI4_PROC_KIND_APP_BASE
    cmp x6, x7
    b.lo .Lpi4_write_uart_key_input_device_ready
    sub x6, x6, x7
    cmp x6, #PI4_PROC_KIND_APP_COUNT
    b.hs .Lpi4_write_uart_key_input_device_ready
.Lpi4_write_uart_key_input_usb_device:
    mov x5, #PI4_VIBE_INPUT_DEVICE_USB
.Lpi4_write_uart_key_input_device_ready:
    str x5, [x0, #8]
    mov x2, #PI4_VIBE_INPUT_EVENT_KEY
    str x2, [x0, #16]
    and x2, x1, #PI4_VIBE_INPUT_EVENT_KEY_TOKEN_CODE_MASK
    str x2, [x0, #24]
    ubfx x3, x1, #PI4_VIBE_INPUT_EVENT_KEY_TOKEN_ACTION_SHIFT, #8
    str x3, [x0, #32]
    str x4, [x0, #40]
    mov x5, #PI4_VIBE_INPUT_SOURCE_UNKNOWN
    cbz x4, .Lpi4_write_uart_key_input_source_ready
    mov x5, #PI4_VIBE_INPUT_SOURCE_USB_HID_KEYBOARD
.Lpi4_write_uart_key_input_source_ready:
    str x5, [x0, #48]
    mov x0, x2
    mov x1, x3
    b pi4_runtime_note_key_event
.size pi4_write_uart_input_event, . - pi4_write_uart_input_event

.type pi4_runtime_note_key_event, %function
pi4_runtime_note_key_event:
    cmp x0, #PI4_VIBE_INPUT_KEY_STATE_BITS
    b.hs .Lpi4_runtime_note_key_event_done
    cmp x1, #PI4_VIBE_INPUT_ACTION_PRESSED
    b.eq .Lpi4_runtime_note_key_event_pressed
    cmp x1, #PI4_VIBE_INPUT_ACTION_RELEASED
    b.eq .Lpi4_runtime_note_key_event_released
    b .Lpi4_runtime_note_key_event_done
.Lpi4_runtime_note_key_event_pressed:
    lsr x2, x0, #6
    and x3, x0, #63
    mov x4, #1
    lsl x4, x4, x3
    adr x5, pi4_runtime_input_key_state
    ldr x6, [x5, x2, lsl #3]
    orr x6, x6, x4
    str x6, [x5, x2, lsl #3]
    b .Lpi4_runtime_note_key_event_done
.Lpi4_runtime_note_key_event_released:
    lsr x2, x0, #6
    and x3, x0, #63
    mov x4, #1
    lsl x4, x4, x3
    adr x5, pi4_runtime_input_key_state
    ldr x6, [x5, x2, lsl #3]
    bic x6, x6, x4
    str x6, [x5, x2, lsl #3]
.Lpi4_runtime_note_key_event_done:
    ret
.size pi4_runtime_note_key_event, . - pi4_runtime_note_key_event

.type pi4_runtime_copy_key_state, %function
pi4_runtime_copy_key_state:
    adr x1, pi4_runtime_input_key_state
    mov x2, #PI4_RUNTIME_INPUT_KEY_STATE_WORDS
.Lpi4_runtime_copy_key_state_next:
    ldr x3, [x1], #8
    str x3, [x0], #8
    subs x2, x2, #1
    b.ne .Lpi4_runtime_copy_key_state_next
    ret
.size pi4_runtime_copy_key_state, . - pi4_runtime_copy_key_state

.type pi4_runtime_key_state_bit, %function
pi4_runtime_key_state_bit:
    cmp x0, #PI4_VIBE_INPUT_KEY_STATE_BITS
    b.hs .Lpi4_runtime_key_state_bit_zero
    lsr x1, x0, #6
    and x2, x0, #63
    adr x3, pi4_runtime_input_key_state
    ldr x4, [x3, x1, lsl #3]
    lsr x4, x4, x2
    and x0, x4, #1
    ret
.Lpi4_runtime_key_state_bit_zero:
    mov x0, xzr
    ret
.size pi4_runtime_key_state_bit, . - pi4_runtime_key_state_bit

.type pi4_runtime_keyboard_modifiers_snapshot, %function
pi4_runtime_keyboard_modifiers_snapshot:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x19, [sp, #16]
    mov x19, xzr

    mov x0, #PI4_VIBE_INPUT_KEY_PS2_SET1_LEFT_SHIFT
    bl pi4_runtime_key_state_bit
    cbnz x0, .Lpi4_runtime_keyboard_mod_shift
    mov x0, #PI4_VIBE_INPUT_KEY_PS2_SET1_RIGHT_SHIFT
    bl pi4_runtime_key_state_bit
    cbz x0, .Lpi4_runtime_keyboard_mod_ctrl_check
.Lpi4_runtime_keyboard_mod_shift:
    orr x19, x19, #PI4_VIBE_INPUT_MOD_SHIFT

.Lpi4_runtime_keyboard_mod_ctrl_check:
    mov x0, #PI4_VIBE_INPUT_KEY_PS2_SET1_LEFT_CTRL
    bl pi4_runtime_key_state_bit
    cbnz x0, .Lpi4_runtime_keyboard_mod_ctrl
    mov x0, #PI4_VIBE_INPUT_KEY_PS2_SET1_RIGHT_CTRL
    bl pi4_runtime_key_state_bit
    cbz x0, .Lpi4_runtime_keyboard_mod_alt_check
.Lpi4_runtime_keyboard_mod_ctrl:
    orr x19, x19, #PI4_VIBE_INPUT_MOD_CTRL

.Lpi4_runtime_keyboard_mod_alt_check:
    mov x0, #PI4_VIBE_INPUT_KEY_PS2_SET1_LEFT_ALT
    bl pi4_runtime_key_state_bit
    cbnz x0, .Lpi4_runtime_keyboard_mod_alt
    mov x0, #PI4_VIBE_INPUT_KEY_PS2_SET1_RIGHT_ALT
    bl pi4_runtime_key_state_bit
    cbz x0, .Lpi4_runtime_keyboard_mod_done
.Lpi4_runtime_keyboard_mod_alt:
    orr x19, x19, #PI4_VIBE_INPUT_MOD_ALT

.Lpi4_runtime_keyboard_mod_done:
    mov x0, x19
    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size pi4_runtime_keyboard_modifiers_snapshot, . - pi4_runtime_keyboard_modifiers_snapshot

.type pi4_write_uart_mouse_input_event, %function
pi4_write_uart_mouse_input_event:
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    mov x19, x0

    ldr x16, =pi4_uart_input_mouse_snapshot
    blr x16
    mov x20, x0
    mov x21, x1
    mov x22, x2

    mov x6, #PI4_VIBE_INPUT_DEVICE_MOUSE
    mov x7, #PI4_VIBE_INPUT_SOURCE_MSMOUSE
    ldr x16, =pi4_usb_input_snapshot
    blr x16
    cbz x5, .Lpi4_write_uart_mouse_source_ready
    mov x7, #PI4_VIBE_INPUT_SOURCE_USB_HID_MOUSE
    adr x8, pi4_status_pi4ctx_kind
    ldr x8, [x8]
    mov x9, #PI4_PROC_KIND_APP_BASE
    cmp x8, x9
    b.lo .Lpi4_write_uart_mouse_source_ready
    sub x8, x8, x9
    cmp x8, #PI4_PROC_KIND_APP_COUNT
    b.hs .Lpi4_write_uart_mouse_source_ready
.Lpi4_write_uart_mouse_usb_device:
    mov x6, #PI4_VIBE_INPUT_DEVICE_USB
.Lpi4_write_uart_mouse_source_ready:

    adr x2, pi4_status_timer_ticks
    ldr x2, [x2]
    str x2, [x19, #0]
    str x6, [x19, #8]
    mov x2, #PI4_VIBE_INPUT_EVENT_MOUSE_PACKET
    str x2, [x19, #16]
    str x20, [x19, #24]
    str x21, [x19, #32]
    str x22, [x19, #40]
    str x7, [x19, #48]

    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret
.size pi4_write_uart_mouse_input_event, . - pi4_write_uart_mouse_input_event

.type pi4_write_uart_input_status, %function
pi4_write_uart_input_status:
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    str x19, [sp, #16]
    mov x19, x0

    mov x1, #PI4_VIBE_INPUT_STATUS_BYTES
    bl pi4_zero_buffer
    ldr x16, =pi4_uart_input_snapshot
    blr x16

    mov x5, #PI4_VIBE_USER_ABI_VERSION
    str x5, [x19, #0]
    mov x5, #PI4_VIBE_INPUT_EVENT_BYTES
    str x5, [x19, #8]
    mov x5, #PI4_UART_INPUT_QUEUE_SIZE
    str x5, [x19, #16]
    str x0, [x19, #24]
    str x1, [x19, #32]
    str x2, [x19, #40]
    str x3, [x19, #48]

    ldr x16, =pi4_input_last_snapshot
    blr x16
    cbz x0, .Lpi4_input_status_no_last
    str x0, [x19, #208]
    str x1, [x19, #216]
.Lpi4_input_status_no_last:

    ldr x16, =pi4_input_keyboard_snapshot
    blr x16
    str x0, [x19, #72]
    str x1, [x19, #80]
    str x2, [x19, #88]
    str x0, [sp, #24]
    add x0, x19, #96
    bl pi4_runtime_copy_key_state

    ldr x16, =pi4_input_mouse_status_snapshot
    blr x16
    str x0, [x19, #168]
    str x1, [x19, #184]
    str x2, [x19, #192]
    str x3, [x19, #200]
    str x0, [sp, #32]

    ldr x16, =pi4_usb_input_snapshot
    blr x16
    mov x7, x4
    mov x8, x5
    mov x5, #PI4_UART_INPUT_CAPS
    ldr x6, [sp, #24]
    cbnz x6, .Lpi4_input_status_keyboard_ready
    cbnz x7, .Lpi4_input_status_keyboard_ready
    cmp x1, #PI4_START_USB_DEVICE_KIND_KEYBOARD
    b.ne .Lpi4_input_status_keyboard_done
.Lpi4_input_status_keyboard_ready:
    orr x5, x5, #PI4_VIBE_INPUT_CAP_KEYBOARD
    mov x6, #PI4_VIBE_INPUT_DEVICE_STATUS_READY
    str x6, [x19, #248]
.Lpi4_input_status_keyboard_done:
    ldr x6, [sp, #32]
    cbnz x6, .Lpi4_input_status_mouse_ready
    cbnz x8, .Lpi4_input_status_mouse_ready
    cmp x1, #PI4_START_USB_DEVICE_KIND_MOUSE
    b.ne .Lpi4_input_status_mouse_done
.Lpi4_input_status_mouse_ready:
    orr x5, x5, #PI4_VIBE_INPUT_CAP_MOUSE
    mov x6, #PI4_VIBE_INPUT_DEVICE_STATUS_READY
    str x6, [x19, #256]
.Lpi4_input_status_mouse_done:
    str x5, [x19, #56]
    mov x5, #PI4_VIBE_INPUT_STATUS_BYTES
    str x5, [x19, #224]
    mov x5, #PI4_UART_INPUT_QUEUE_USABLE
    str x5, [x19, #232]
    mov x5, #PI4_VIBE_INPUT_QUEUE_OVERFLOW_DROP_NEWEST
    str x5, [x19, #240]

    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #64
    ret
.size pi4_write_uart_input_status, . - pi4_write_uart_input_status

.type pi4_write_uart_input_device_status, %function
pi4_write_uart_input_device_status:
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    mov x19, x0
    mov x20, x1

    mov x0, x20
    mov x1, #PI4_VIBE_INPUT_DEVICE_STATUS_BYTES
    bl pi4_zero_buffer
    mov x5, #PI4_VIBE_USER_ABI_VERSION
    str x5, [x20, #0]
    mov x5, #PI4_VIBE_INPUT_DEVICE_STATUS_BYTES
    str x5, [x20, #8]
    str x19, [x20, #16]

    cmp x19, #PI4_VIBE_INPUT_DEVICE_UART
    b.eq .Lpi4_input_device_status_uart
    cmp x19, #PI4_VIBE_INPUT_DEVICE_KEYBOARD
    b.eq .Lpi4_input_device_status_keyboard
    cmp x19, #PI4_VIBE_INPUT_DEVICE_MOUSE
    b.eq .Lpi4_input_device_status_mouse
    cmp x19, #PI4_VIBE_INPUT_DEVICE_USB
    b.eq .Lpi4_input_device_status_usb
    mov x0, #-PI4_VIBE_EINVAL
    b .Lpi4_input_device_status_done

.Lpi4_input_device_status_wait:
    mov x0, xzr
    b .Lpi4_input_device_status_done

.Lpi4_input_device_status_uart:
    ldr x16, =pi4_uart_input_snapshot
    blr x16
    mov x5, #PI4_VIBE_INPUT_DEVICE_STATUS_READY
    str x5, [x20, #24]
    mov x5, #PI4_UART_INPUT_CAPS
    str x5, [x20, #32]
    str x1, [x20, #48]
    str x2, [x20, #56]
    str x3, [x20, #64]
    adr x5, pi4_status_timer_ticks
    ldr x5, [x5]
    str x5, [x20, #72]
    cbz x4, .Lpi4_input_device_status_uart_no_last
    mov x5, #PI4_VIBE_INPUT_EVENT_UART
    str x5, [x20, #80]
    str x4, [x20, #88]
.Lpi4_input_device_status_uart_no_last:
    mov x0, xzr
    b .Lpi4_input_device_status_done

.Lpi4_input_device_status_keyboard:
    ldr x16, =pi4_input_keyboard_snapshot
    blr x16
    str x0, [x20, #48]
    str x2, [x20, #88]
    str x0, [sp, #32]
    ldr x16, =pi4_usb_input_snapshot
    blr x16
    mov x7, x4
    ldr x6, [sp, #32]
    cbnz x6, .Lpi4_input_device_status_keyboard_ready
    cbnz x7, .Lpi4_input_device_status_keyboard_ready
    cmp x1, #PI4_START_USB_DEVICE_KIND_KEYBOARD
    b.ne .Lpi4_input_device_status_wait
.Lpi4_input_device_status_keyboard_ready:
    mov x5, #PI4_VIBE_INPUT_DEVICE_STATUS_READY
    str x5, [x20, #24]
    mov x5, #(PI4_VIBE_INPUT_DEVICE_CAP_KEYS | PI4_VIBE_INPUT_DEVICE_CAP_STATE_SNAPSHOT)
    str x5, [x20, #32]
    bl pi4_runtime_keyboard_modifiers_snapshot
    str x0, [x20, #96]
    ldr x5, [sp, #32]
    cbz x5, .Lpi4_input_device_status_keyboard_no_last
    mov x6, #PI4_VIBE_INPUT_EVENT_KEY
    str x6, [x20, #80]
.Lpi4_input_device_status_keyboard_no_last:
    adr x5, pi4_status_timer_ticks
    ldr x5, [x5]
    str x5, [x20, #72]
    mov x0, xzr
    b .Lpi4_input_device_status_done

.Lpi4_input_device_status_mouse:
    ldr x16, =pi4_input_mouse_status_snapshot
    blr x16
    str x0, [x20, #48]
    str x1, [x20, #88]
    str x1, [x20, #96]
    str x2, [x20, #104]
    str x3, [x20, #112]
    str x0, [sp, #32]
    ldr x16, =pi4_usb_input_snapshot
    blr x16
    mov x7, x5
    ldr x6, [sp, #32]
    cbnz x6, .Lpi4_input_device_status_mouse_ready
    cbnz x7, .Lpi4_input_device_status_mouse_ready
    cmp x1, #PI4_START_USB_DEVICE_KIND_MOUSE
    b.ne .Lpi4_input_device_status_wait
.Lpi4_input_device_status_mouse_ready:
    mov x5, #PI4_VIBE_INPUT_DEVICE_STATUS_READY
    str x5, [x20, #24]
    mov x5, #(PI4_VIBE_INPUT_DEVICE_CAP_RELATIVE_POINTER | PI4_VIBE_INPUT_DEVICE_CAP_BUTTONS | PI4_VIBE_INPUT_DEVICE_CAP_STATE_SNAPSHOT)
    str x5, [x20, #32]
    ldr x5, [sp, #32]
    cbz x5, .Lpi4_input_device_status_mouse_no_last
    mov x6, #PI4_VIBE_INPUT_EVENT_MOUSE_PACKET
    str x6, [x20, #80]
.Lpi4_input_device_status_mouse_no_last:
    adr x5, pi4_status_timer_ticks
    ldr x5, [x5]
    str x5, [x20, #72]
    mov x0, xzr
    b .Lpi4_input_device_status_done

.Lpi4_input_device_status_usb:
    ldr x16, =pi4_usb_input_snapshot
    blr x16
    str x1, [x20, #88]
    str x2, [x20, #96]
    str x0, [sp, #32]
    str x1, [sp, #40]
    str x4, [sp, #64]
    str x5, [sp, #72]
    ldr x16, =pi4_input_keyboard_snapshot
    blr x16
    str x0, [sp, #48]
    ldr x16, =pi4_input_mouse_status_snapshot
    blr x16
    str x0, [sp, #56]
    ldr x5, [sp, #48]
    add x5, x5, x0
    str x5, [x20, #48]
    cbnz x5, .Lpi4_input_device_status_usb_ready
    ldr x5, [sp, #64]
    cbnz x5, .Lpi4_input_device_status_usb_ready
    ldr x5, [sp, #72]
    cbnz x5, .Lpi4_input_device_status_usb_ready
    ldr x5, [sp, #32]
    cbnz x5, .Lpi4_input_device_status_usb_ready
    ldr x5, [sp, #40]
    cmp x5, #PI4_START_USB_DEVICE_KIND_UNKNOWN
    b.eq .Lpi4_input_device_status_wait
.Lpi4_input_device_status_usb_ready:
    mov x5, #PI4_VIBE_INPUT_DEVICE_STATUS_READY
    str x5, [x20, #24]
    mov x5, xzr
    ldr x6, [sp, #48]
    cbnz x6, .Lpi4_input_device_status_usb_caps_key
    ldr x6, [sp, #64]
    cbnz x6, .Lpi4_input_device_status_usb_caps_key
    ldr x6, [sp, #40]
    cmp x6, #PI4_START_USB_DEVICE_KIND_KEYBOARD
    b.ne .Lpi4_input_device_status_usb_caps_mouse_check
.Lpi4_input_device_status_usb_caps_key:
    mov x5, #(PI4_VIBE_INPUT_DEVICE_CAP_KEYS | PI4_VIBE_INPUT_DEVICE_CAP_STATE_SNAPSHOT)
.Lpi4_input_device_status_usb_caps_mouse_check:
    ldr x6, [sp, #56]
    cbnz x6, .Lpi4_input_device_status_usb_caps_mouse
    ldr x6, [sp, #72]
    cbnz x6, .Lpi4_input_device_status_usb_caps_mouse
    ldr x6, [sp, #40]
    cmp x6, #PI4_START_USB_DEVICE_KIND_MOUSE
    b.ne .Lpi4_input_device_status_usb_caps_done
.Lpi4_input_device_status_usb_caps_mouse:
    orr x5, x5, #(PI4_VIBE_INPUT_DEVICE_CAP_RELATIVE_POINTER | PI4_VIBE_INPUT_DEVICE_CAP_BUTTONS | PI4_VIBE_INPUT_DEVICE_CAP_STATE_SNAPSHOT)
.Lpi4_input_device_status_usb_caps_done:
    str x5, [x20, #32]
    ldr x16, =pi4_input_last_snapshot
    blr x16
    cmp x0, #PI4_VIBE_INPUT_DEVICE_KEYBOARD
    b.eq .Lpi4_input_device_status_usb_have_last
    cmp x0, #PI4_VIBE_INPUT_DEVICE_MOUSE
    b.ne .Lpi4_input_device_status_usb_no_last
.Lpi4_input_device_status_usb_have_last:
    str x1, [x20, #80]
    str x2, [x20, #88]
.Lpi4_input_device_status_usb_no_last:
    adr x5, pi4_status_timer_ticks
    ldr x5, [x5]
    str x5, [x20, #72]
    mov x0, xzr

.Lpi4_input_device_status_done:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret
.size pi4_write_uart_input_device_status, . - pi4_write_uart_input_device_status

.type pi4_uart_init, %function
pi4_uart_init:
    ldr x0, =PI4_GPIO_GPFSEL1
    ldr w1, [x0]
    mov w2, #0x3f000
    bic w1, w1, w2
    movz w2, #0x4000
    movk w2, #0x0002, lsl #16
    orr w1, w1, w2
    str w1, [x0]

    ldr x0, =PI4_GPIO_GPPUPPDN0
    ldr w1, [x0]
    mov w2, #0xf0000000
    bic w1, w1, w2
    str w1, [x0]

    ldr x0, =PI4_UART0_CR
    str wzr, [x0]
    ldr x0, =PI4_UART0_ICR
    mov w1, #PI4_UART_ICR_ALL
    str w1, [x0]
    ldr x0, =PI4_UART0_IMSC
    str wzr, [x0]
    ldr x0, =PI4_UART0_IBRD
    mov w1, #PI4_UART_IBRD_115200
    str w1, [x0]
    ldr x0, =PI4_UART0_FBRD
    mov w1, #PI4_UART_FBRD_115200
    str w1, [x0]
    ldr x0, =PI4_UART0_LCRH
    mov w1, #PI4_UART_LCRH_8N1_FIFO
    str w1, [x0]
    ldr x0, =PI4_UART0_CR
    mov w1, #PI4_UART_CR_UARTEN_TXE_RXE
    str w1, [x0]
    dsb sy
    isb

    adr x0, pi4_status_last
    movz w1, #0x5552
    movk w1, #0x5049, lsl #16
    str w1, [x0]
    ret
.size pi4_uart_init, . - pi4_uart_init

.type pi4_uart_write_status_line, %function
pi4_uart_write_status_line:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    adr x0, msg_status_prefix
    bl pi4_uart_write_string
    mov x0, #PI4_KERNEL8_LOAD_ADDR
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_boot_stack_top
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_entry_el
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_dtb
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_current_el
    bl pi4_uart_write_string
    bl pi4_uart_write_dtb_tuple
    adr x0, pi4_status_current_el
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_vector_tuple
    bl pi4_uart_write_string
    adr x0, pi4_status_vbar_el1
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_vector_hits
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_esr_el1
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_elr_el1
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_svc_tuple
    bl pi4_uart_write_string
    adr x0, pi4_status_sysframe_elr_el1
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_sysframe_sp_el0
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_sysframe_spsr_el1
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_sysframe_x0
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_svcapi_tuple
    bl pi4_uart_write_string
    adr x0, pi4_status_svc_runtime_hits
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_svc_runtime_last_number
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_svc_runtime_last_result
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_svc_runtime_bad_count
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_svc_runtime_getpid_count
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_svc_runtime_ioctl_count
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_svc_runtime_input_count
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_svc_runtime_present_count
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_pi4clockapi
    bl pi4_uart_write_string
    adr x0, pi4_status_svc_runtime_clock_count
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_svc_runtime_clock_last_ticks
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_svc_runtime_clock_last_hz
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_svc_runtime_clock_last_ms
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_svcptr_tuple
    bl pi4_uart_write_string
    adr x0, pi4_status_svc_runtime_ptr_check_count
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_svc_runtime_ptr_bad_count
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_svc_runtime_ptr_last_base
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_svc_runtime_ptr_last_bytes
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    bl pi4_uart_write_input_tuple
    bl pi4_uart_write_uabi_tuple
    adr x0, pi4_status_pi4exec_count
    ldr x1, [x0]
    cbz x1, .Lpi4_uart_write_pi4exec_wait
    adr x0, pi4_status_pi4exec_result
    ldr x1, [x0]
    cbnz x1, .Lpi4_uart_write_pi4exec_wait
    adr x0, msg_status_pi4exec_ok_tuple
    b .Lpi4_uart_write_pi4exec_prefix
.Lpi4_uart_write_pi4exec_wait:
    adr x0, msg_status_pi4exec_tuple
.Lpi4_uart_write_pi4exec_prefix:
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4exec_sysno
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4exec_path
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4exec_argv
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4exec_envp
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4exec_result
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4exec_count
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_pi4appreq_tuple
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4appreq_request
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4appreq_abi
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4appreq_bytes
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4appreq_path
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4appreq_path_bytes
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4appreq_matched_asset
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    bl pi4_uart_write_app_vfs_tuple
    bl pi4_uart_write_user_file_tuple
    bl pi4_uart_write_memory_tuple
    bl pi4_uart_write_storage_status_tuple
    bl pi4_uart_write_audio_status_tuple
    bl pi4_uart_write_runtime_suffix

    ldp x29, x30, [sp], #16
    ret
.size pi4_uart_write_status_line, . - pi4_uart_write_status_line

.type pi4_uart_write_app_vfs_tuple, %function
pi4_uart_write_app_vfs_tuple:
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    str x21, [sp, #32]

    adr x0, msg_status_pi4appvfs_tuple
    bl pi4_uart_write_string
    adr x19, pi4_status_pi4appvfs_values_start
    adr x20, pi4_status_pi4appvfs_values_end
.Lpi4_uart_write_app_vfs_next:
    ldr x0, [x19], #8
    bl pi4_uart_write_hex64
    cmp x19, x20
    b.hs .Lpi4_uart_write_app_vfs_done
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    b .Lpi4_uart_write_app_vfs_next

.Lpi4_uart_write_app_vfs_done:
    ldr x21, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret
.size pi4_uart_write_app_vfs_tuple, . - pi4_uart_write_app_vfs_tuple

.type pi4_uart_write_user_file_tuple, %function
pi4_uart_write_user_file_tuple:
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    str x21, [sp, #32]

    adr x0, msg_status_pi4userfile_tuple
    bl pi4_uart_write_string
    adr x19, pi4_status_pi4userfile_values_start
    adr x20, pi4_status_pi4userfile_values_end
.Lpi4_uart_write_user_file_next:
    ldr x0, [x19], #8
    bl pi4_uart_write_hex64
    cmp x19, x20
    b.hs .Lpi4_uart_write_user_file_done
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    b .Lpi4_uart_write_user_file_next

.Lpi4_uart_write_user_file_done:
    ldr x21, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret
.size pi4_uart_write_user_file_tuple, . - pi4_uart_write_user_file_tuple

.type pi4_uart_write_audio_status_tuple, %function
pi4_uart_write_audio_status_tuple:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x19, [sp, #16]
    mov x19, xzr

    adr x0, pi4_audio_status_caps
    ldr x1, [x0]
    cbnz x1, .Lpi4_uart_write_audio_pwm_wait
    adr x0, pi4_audio_status_mailbox_success
    ldr x1, [x0]
    cbnz x1, .Lpi4_uart_write_audio_pwm_wait
    adr x0, pi4_audio_status_mmio_legacy_base
    ldr x1, [x0]
    cbnz x1, .Lpi4_uart_write_audio_pwm_wait

    adr x0, msg_status_pi4audio_wait_none
    bl pi4_uart_write_string
    b .Lpi4_uart_write_audio_done

.Lpi4_uart_write_audio_pwm_wait:
    bl pi4_audio_status_can_claim_ok
    mov x19, x0
    adr x0, pi4_audio_status_usb_ready
    ldr x1, [x0]
    cbz x1, .Lpi4_uart_write_audio_pwm_prefix
    cbz x19, .Lpi4_uart_write_audio_unproven_prefix
    adr x0, msg_status_pi4audio_ok_usb
    bl pi4_uart_write_string
    b .Lpi4_uart_write_audio_hw_fields
.Lpi4_uart_write_audio_pwm_prefix:
    cbz x19, .Lpi4_uart_write_audio_unproven_prefix
    adr x0, msg_status_pi4audio_ok_pwm
    bl pi4_uart_write_string
    b .Lpi4_uart_write_audio_hw_fields
.Lpi4_uart_write_audio_unproven_prefix:
    adr x0, pi4_audio_status_usb_ready
    ldr x1, [x0]
    cbz x1, .Lpi4_uart_write_audio_unproven_pwm_prefix
    adr x0, msg_status_pi4audio_wait_usb
    bl pi4_uart_write_string
    b .Lpi4_uart_write_audio_hw_fields
.Lpi4_uart_write_audio_unproven_pwm_prefix:
    adr x0, msg_status_pi4audio_wait_pwm
    bl pi4_uart_write_string
.Lpi4_uart_write_audio_hw_fields:
    adr x0, pi4_audio_status_mmio_legacy_base
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_audio_status_mmio_arm_base
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_audio_status_mmio_span
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_audio_status_mmio_ready
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    adr x0, msg_status_pi4audio_mailbox
    bl pi4_uart_write_string
    adr x0, pi4_audio_status_mailbox_success
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_audio_status_mailbox_clock_id
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_audio_status_mailbox_clock_rate
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_audio_status_mailbox_clock_state
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    adr x0, msg_status_pi4audio_cap
    bl pi4_uart_write_string
    adr x0, pi4_audio_status_caps
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    adr x0, msg_status_pi4audio_usb
    bl pi4_uart_write_string
    adr x0, pi4_audio_status_usb_ready
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_audio_status_usb_addr
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_audio_status_usb_interface
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_audio_status_usb_endpoint
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_audio_status_usb_mps
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_audio_status_usb_packets
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_audio_status_usb_bytes
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_audio_status_usb_last_hcint
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    cbnz x19, .Lpi4_uart_write_audio_ok_queue
    adr x0, msg_status_pi4audio_queue_none
    bl pi4_uart_write_string
    adr x0, msg_status_pi4audio_abi_none
    bl pi4_uart_write_string
    b .Lpi4_uart_write_audio_done

.Lpi4_uart_write_audio_ok_queue:
    adr x0, msg_status_pi4audio_queue
    bl pi4_uart_write_string
    adr x0, pi4_audio_status_queue_bytes
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_audio_status_queue_usable
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_audio_status_queue_streams
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_audio_status_queue_underruns
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    adr x0, msg_status_pi4audio_abi
    bl pi4_uart_write_string
    adr x0, pi4_audio_status_abi_observed
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_audio_status_abi_required
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_audio_status_abi_version
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_audio_status_abi_backend_ready
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    adr x0, msg_status_pi4audiodev
    bl pi4_uart_write_string
    adr x0, pi4_audio_status_usb_ready
    ldr x0, [x0]
    cbz x0, .Lpi4_uart_write_audio_device_pwm
    mov x0, #PI4_VIBE_AUDIO_DEVICE_PI4_USB
    b .Lpi4_uart_write_audio_device_kind
.Lpi4_uart_write_audio_device_pwm:
    mov x0, #PI4_VIBE_AUDIO_DEVICE_PI4_PWM
.Lpi4_uart_write_audio_device_kind:
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    mov x0, #PI4_VIBE_AUDIO_DEVICE_STATUS_READY
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_audio_status_caps
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_audio_status_abi_backend_ready
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    adr x0, msg_status_pi4audiofmt
    bl pi4_uart_write_string
    mov x0, #PI4_VIBE_AUDIO_FORMAT_U8_STEREO
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    mov x0, #PI4_VIBE_AUDIO_CHANNELS
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    mov x0, #PI4_VIBE_AUDIO_QUEUE_BYTES
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    mov x0, #PI4_VIBE_AUDIO_PERIOD_BYTES
    bl pi4_uart_write_hex64

    adr x0, msg_status_pi4audiorate
    bl pi4_uart_write_string
    mov x0, #PI4_VIBE_AUDIO_SAMPLE_RATE
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    mov x0, #PI4_VIBE_AUDIO_LOW_WATER_BYTES
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_audio_pcm_queued_bytes
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_audio_pcm_position_bytes
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    adr x0, msg_status_pi4audiocount
    bl pi4_uart_write_string
    adr x0, pi4_audio_status_call_count
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_audio_status_playback_start_count
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_audio_pcm_mixed_bytes
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_audio_status_last_result
    ldr x0, [x0]
    bl pi4_uart_write_hex64

.Lpi4_uart_write_audio_done:
    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size pi4_uart_write_audio_status_tuple, . - pi4_uart_write_audio_status_tuple

.type pi4_uart_write_runtime_suffix, %function
pi4_uart_write_runtime_suffix:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    ldr w2, =VIBE_PI4_STATUS_NONE
    adr x0, pi4_status_panic
    ldr w1, [x0]
    cmp w1, w2
    b.ne .Lpi4_uart_write_runtime_fault
    adr x0, pi4_status_faultsrc
    ldr w1, [x0]
    cmp w1, w2
    b.ne .Lpi4_uart_write_runtime_fault
    adr x0, pi4_status_faultmode
    ldr w1, [x0]
    cmp w1, w2
    b.ne .Lpi4_uart_write_runtime_fault

    adr x0, pi4_status_pi4uabi
    ldr w1, [x0]
    ldr w2, =VIBE_PI4_STATUS_PI4UABI_OK
    cmp w1, w2
    b.eq .Lpi4_uart_write_runtime_ok
    adr x0, msg_status_suffix
    bl pi4_uart_write_string
    b .Lpi4_uart_write_runtime_done

.Lpi4_uart_write_runtime_ok:
    adr x0, msg_status_suffix_ok
    bl pi4_uart_write_string
    b .Lpi4_uart_write_runtime_done

.Lpi4_uart_write_runtime_fault:
    adr x0, msg_status_faultsrc
    bl pi4_uart_write_string
    adr x0, pi4_status_faultsrc
    ldr w0, [x0]
    bl pi4_uart_write_faultsrc_value
    adr x0, msg_status_faultmode
    bl pi4_uart_write_string
    adr x0, pi4_status_faultmode
    ldr w0, [x0]
    bl pi4_uart_write_faultmode_value
    adr x0, msg_status_runtime_wait
    bl pi4_uart_write_string
    adr x0, msg_status_panic
    bl pi4_uart_write_string
    adr x0, pi4_status_panic
    ldr w0, [x0]
    bl pi4_uart_write_panic_value
    adr x0, msg_status_shutdown_none
    bl pi4_uart_write_string

.Lpi4_uart_write_runtime_done:
    ldp x29, x30, [sp], #16
    ret
.size pi4_uart_write_runtime_suffix, . - pi4_uart_write_runtime_suffix

.type pi4_uart_write_faultsrc_value, %function
pi4_uart_write_faultsrc_value:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    ldr w1, =VIBE_PI4_STATUS_NONE
    cmp w0, w1
    b.eq .Lpi4_uart_write_faultsrc_none
    ldr w1, =VIBE_PI4_FAULTSRC_BOOT
    cmp w0, w1
    b.eq .Lpi4_uart_write_faultsrc_boot
    ldr w1, =VIBE_PI4_FAULTSRC_EL1
    cmp w0, w1
    b.eq .Lpi4_uart_write_faultsrc_el1
    ldr w1, =VIBE_PI4_FAULTSRC_EL0
    cmp w0, w1
    b.eq .Lpi4_uart_write_faultsrc_el0
    uxtw x0, w0
    bl pi4_uart_write_hex64
    b .Lpi4_uart_write_faultsrc_done

.Lpi4_uart_write_faultsrc_none:
    adr x0, msg_status_none_value
    bl pi4_uart_write_string
    b .Lpi4_uart_write_faultsrc_done
.Lpi4_uart_write_faultsrc_boot:
    adr x0, msg_status_boot_value
    bl pi4_uart_write_string
    b .Lpi4_uart_write_faultsrc_done
.Lpi4_uart_write_faultsrc_el1:
    adr x0, msg_status_el1_value
    bl pi4_uart_write_string
    b .Lpi4_uart_write_faultsrc_done
.Lpi4_uart_write_faultsrc_el0:
    adr x0, msg_status_el0_value
    bl pi4_uart_write_string

.Lpi4_uart_write_faultsrc_done:
    ldp x29, x30, [sp], #16
    ret
.size pi4_uart_write_faultsrc_value, . - pi4_uart_write_faultsrc_value

.type pi4_uart_write_faultmode_value, %function
pi4_uart_write_faultmode_value:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    ldr w1, =VIBE_PI4_STATUS_NONE
    cmp w0, w1
    b.eq .Lpi4_uart_write_faultmode_none
    ldr w1, =VIBE_PI4_FAULTMODE_EL
    cmp w0, w1
    b.eq .Lpi4_uart_write_faultmode_el
    ldr w1, =VIBE_PI4_FAULTMODE_ALLOC
    cmp w0, w1
    b.eq .Lpi4_uart_write_faultmode_alloc
    ldr w1, =VIBE_PI4_FAULTMODE_ELF
    cmp w0, w1
    b.eq .Lpi4_uart_write_faultmode_elf
    ldr w1, =VIBE_PI4_FAULTMODE_STACK
    cmp w0, w1
    b.eq .Lpi4_uart_write_faultmode_stack
    ldr w1, =VIBE_PI4_FAULTMODE_SYNC
    cmp w0, w1
    b.eq .Lpi4_uart_write_faultmode_sync
    ldr w1, =VIBE_PI4_FAULTMODE_IRQ
    cmp w0, w1
    b.eq .Lpi4_uart_write_faultmode_irq
    ldr w1, =VIBE_PI4_FAULTMODE_SVC
    cmp w0, w1
    b.eq .Lpi4_uart_write_faultmode_svc
    ldr w1, =VIBE_PI4_FAULTMODE_VECTOR
    cmp w0, w1
    b.eq .Lpi4_uart_write_faultmode_vector
    uxtw x0, w0
    bl pi4_uart_write_hex64
    b .Lpi4_uart_write_faultmode_done

.Lpi4_uart_write_faultmode_none:
    adr x0, msg_status_none_value
    bl pi4_uart_write_string
    b .Lpi4_uart_write_faultmode_done
.Lpi4_uart_write_faultmode_el:
    adr x0, msg_status_el_value
    bl pi4_uart_write_string
    b .Lpi4_uart_write_faultmode_done
.Lpi4_uart_write_faultmode_alloc:
    adr x0, msg_status_alloc_value
    bl pi4_uart_write_string
    b .Lpi4_uart_write_faultmode_done
.Lpi4_uart_write_faultmode_elf:
    adr x0, msg_status_elf_value
    bl pi4_uart_write_string
    b .Lpi4_uart_write_faultmode_done
.Lpi4_uart_write_faultmode_stack:
    adr x0, msg_status_stack_value
    bl pi4_uart_write_string
    b .Lpi4_uart_write_faultmode_done
.Lpi4_uart_write_faultmode_sync:
    adr x0, msg_status_sync_value
    bl pi4_uart_write_string
    b .Lpi4_uart_write_faultmode_done
.Lpi4_uart_write_faultmode_irq:
    adr x0, msg_status_irq_value
    bl pi4_uart_write_string
    b .Lpi4_uart_write_faultmode_done
.Lpi4_uart_write_faultmode_svc:
    adr x0, msg_status_svc_value
    bl pi4_uart_write_string
    b .Lpi4_uart_write_faultmode_done
.Lpi4_uart_write_faultmode_vector:
    adr x0, msg_status_vector_value
    bl pi4_uart_write_string

.Lpi4_uart_write_faultmode_done:
    ldp x29, x30, [sp], #16
    ret
.size pi4_uart_write_faultmode_value, . - pi4_uart_write_faultmode_value

.type pi4_uart_write_panic_value, %function
pi4_uart_write_panic_value:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    ldr w1, =VIBE_PI4_STATUS_NONE
    cmp w0, w1
    b.eq .Lpi4_uart_write_panic_none
    ldr w1, =VIBE_PI4_STATUS_PANIC_ASSERT
    cmp w0, w1
    b.eq .Lpi4_uart_write_panic_assert
    uxtw x0, w0
    bl pi4_uart_write_hex64
    b .Lpi4_uart_write_panic_done

.Lpi4_uart_write_panic_none:
    adr x0, msg_status_none_value
    bl pi4_uart_write_string
    b .Lpi4_uart_write_panic_done
.Lpi4_uart_write_panic_assert:
    adr x0, msg_status_assert_value
    bl pi4_uart_write_string

.Lpi4_uart_write_panic_done:
    ldp x29, x30, [sp], #16
    ret
.size pi4_uart_write_panic_value, . - pi4_uart_write_panic_value

.type pi4_uart_write_storage_status_tuple, %function
pi4_uart_write_storage_status_tuple:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x19, [sp, #16]

    adr x0, msg_status_pi4sd
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4sd
    ldr w0, [x0]
    bl pi4_uart_write_storage_gate_word

    adr x0, msg_status_pi4fat
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4fat
    ldr w0, [x0]
    bl pi4_uart_write_storage_gate_word

    adr x0, msg_status_pi4vfs
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4vfs
    ldr w0, [x0]
    bl pi4_uart_write_storage_gate_word

    adr x0, pi4_storage_status_block_count
    ldr x0, [x0]
    cbz x0, .Lpi4_uart_write_storage_no_block
    bl pi4_uart_write_storage_block_status
.Lpi4_uart_write_storage_no_block:

    adr x0, pi4_status_pi4sd
    ldr w19, [x0]
    ldr w0, =PI4_START_STORAGE_SD_OK
    cmp w19, w0
    b.ne .Lpi4_uart_write_storage_tuple_done

    adr x0, msg_status_pi4mbr
    adr x1, pi4_storage_status_mbr_signature
    mov x2, #6
    bl pi4_uart_write_storage_named_tuple

    adr x0, pi4_status_pi4fat
    ldr w19, [x0]
    ldr w0, =PI4_START_STORAGE_BPB_OK
    cmp w19, w0
    b.ne .Lpi4_uart_write_storage_tuple_done

    bl pi4_uart_write_storage_bpb_tuple
    bl pi4_uart_write_storage_root_tuple

    adr x0, pi4_status_pi4vfs
    ldr w19, [x0]
    ldr w0, =PI4_START_STORAGE_VFS_OK
    cmp w19, w0
    b.ne .Lpi4_uart_write_storage_tuple_done

    bl pi4_uart_write_storage_vfs_file_tuples

.Lpi4_uart_write_storage_tuple_done:
    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size pi4_uart_write_storage_status_tuple, . - pi4_uart_write_storage_status_tuple

.type pi4_uart_write_storage_named_tuple, %function
pi4_uart_write_storage_named_tuple:
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]

    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, xzr

    mov x0, x19
    bl pi4_uart_write_string
.Lpi4_uart_write_storage_named_tuple_next:
    ldr x0, [x20, x22, lsl #3]
    bl pi4_uart_write_hex64
    add x22, x22, #1
    cmp x22, x21
    b.hs .Lpi4_uart_write_storage_named_tuple_done
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    b .Lpi4_uart_write_storage_named_tuple_next

.Lpi4_uart_write_storage_named_tuple_done:
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret
.size pi4_uart_write_storage_named_tuple, . - pi4_uart_write_storage_named_tuple

.type pi4_uart_write_storage_bpb_tuple, %function
pi4_uart_write_storage_bpb_tuple:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    adr x0, msg_status_pi4bpb
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_bpb_signature
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_bpb_bytes_per_sector
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_bpb_sectors_per_cluster
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_bpb_reserved_sectors
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_bpb_root_dir_sectors
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_bpb_fat_count
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_bpb_total_sectors
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_bpb_fat_sectors
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_bpb_cluster_count
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    ldp x29, x30, [sp], #16
    ret
.size pi4_uart_write_storage_bpb_tuple, . - pi4_uart_write_storage_bpb_tuple

.type pi4_uart_write_storage_root_tuple, %function
pi4_uart_write_storage_root_tuple:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    adr x0, msg_status_pi4root
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_root_dir_sectors
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_root_dir_lba
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_root_cluster
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_root_data_lba
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    ldp x29, x30, [sp], #16
    ret
.size pi4_uart_write_storage_root_tuple, . - pi4_uart_write_storage_root_tuple

.type pi4_uart_write_storage_vfs_file_tuples, %function
pi4_uart_write_storage_vfs_file_tuples:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    adr x0, msg_status_pi4kernel8
    adr x1, pi4_storage_status_kernel8_img
    mov x2, #4
    bl pi4_uart_write_storage_named_tuple
    adr x0, msg_status_pi4config
    adr x1, pi4_storage_status_config_txt
    mov x2, #4
    bl pi4_uart_write_storage_named_tuple
    adr x0, msg_status_pi4init
    adr x1, pi4_storage_status_init_elf_entry_index
    mov x2, #8
    bl pi4_uart_write_storage_named_tuple
    adr x0, msg_status_pi4abiprobe
    adr x1, pi4_storage_status_system_abiprobe
    mov x2, #4
    bl pi4_uart_write_storage_named_tuple
    bl pi4_uart_write_storage_app_record_tuples
    adr x0, msg_status_pi4manifest
    adr x1, pi4_storage_status_manifest_txt
    mov x2, #8
    bl pi4_uart_write_storage_named_tuple
    adr x0, msg_status_pi4assets
    adr x1, pi4_storage_status_assets_summary
    mov x2, #3
    bl pi4_uart_write_storage_named_tuple
    adr x0, msg_status_pi4wad
    adr x1, pi4_storage_status_doom1_wad
    mov x2, #8
    bl pi4_uart_write_storage_named_tuple
    adr x0, pi4_storage_status_pak0_pak
    ldr x0, [x0, #16]
    cbz x0, .Lpi4_uart_write_storage_no_pak0
    adr x0, msg_status_pi4pak0
    adr x1, pi4_storage_status_pak0_pak
    mov x2, #8
    bl pi4_uart_write_storage_named_tuple
.Lpi4_uart_write_storage_no_pak0:

    adr x0, msg_status_pi4initbuf
    bl pi4_uart_write_string
    adr x0, pi4_nonembedded_init_elf_buffer
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_nonembedded_init_elf_bytes
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_nonembedded_init_stack_base
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_nonembedded_init_stack_top
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    ldp x29, x30, [sp], #16
    ret
.size pi4_uart_write_storage_vfs_file_tuples, . - pi4_uart_write_storage_vfs_file_tuples

.type pi4_uart_write_storage_app_record_tuples, %function
pi4_uart_write_storage_app_record_tuples:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    stp x19, x20, [sp, #16]

    adr x19, pi4_app_file_record_table
    mov x20, xzr
.Lpi4_uart_write_storage_app_record_tuples_next:
    cmp x20, #PI4_VIBE_APP_RECORD_COUNT
    b.hs .Lpi4_uart_write_storage_app_record_tuples_done
    ldr x0, [x19, #PI4_VIBE_APP_RECORD_DIR_STATUS]
    ldr x0, [x0]
    cbz x0, .Lpi4_uart_write_storage_app_record_tuples_step
    ldr x0, [x19, #PI4_VIBE_APP_RECORD_STATUS_LABEL]
    ldr x1, [x19, #PI4_VIBE_APP_RECORD_ELF_META]
    mov x2, #8
    bl pi4_uart_write_storage_named_tuple
.Lpi4_uart_write_storage_app_record_tuples_step:
    add x19, x19, #PI4_VIBE_APP_RECORD_BYTES
    add x20, x20, #1
    b .Lpi4_uart_write_storage_app_record_tuples_next

.Lpi4_uart_write_storage_app_record_tuples_done:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size pi4_uart_write_storage_app_record_tuples, . - pi4_uart_write_storage_app_record_tuples

.type pi4_uart_write_storage_block_status, %function
pi4_uart_write_storage_block_status:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    adr x0, msg_status_pi4blk
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_block
    ldr w0, [x0]
    bl pi4_uart_write_storage_status_word

    adr x0, msg_status_pi4blkreq
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_block_lba
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_block_count
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_block_buffer
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_block_max_count
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_block_bytes
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_block_result
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    adr x0, msg_status_pi4blkpio
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_block_command
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_block_transfer_mode
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_block_argument
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_block_copied_bytes
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_block_copied_sectors
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_block_pio_words
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_block_int_status
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_block_error_status
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_block_present_before
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_block_present_after
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    adr x0, msg_status_pi4sdctl
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_block_controller
    ldr w0, [x0]
    bl pi4_uart_write_storage_status_word

    adr x0, msg_status_pi4sdregs
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_sdctl_legacy_base
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_sdctl_arm_base
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_sdctl_span
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_sdctl_host_version
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_sdctl_caps0
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_sdctl_caps1
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_sdctl_present
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_sdctl_host_control
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_sdctl_power_control
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_sdctl_clock_control
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_sdctl_software_reset
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_storage_status_sdctl_int_status
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    ldp x29, x30, [sp], #16
    ret
.size pi4_uart_write_storage_block_status, . - pi4_uart_write_storage_block_status

.type pi4_uart_write_storage_gate_word, %function
pi4_uart_write_storage_gate_word:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    ldr w1, =PI4_START_STORAGE_WAIT
    cmp w0, w1
    b.eq .Lpi4_uart_write_storage_gate_wait
    ldr w1, =PI4_START_STORAGE_SD_OK
    cmp w0, w1
    b.eq .Lpi4_uart_write_storage_gate_ok
    ldr w1, =PI4_START_STORAGE_MBR_OK
    cmp w0, w1
    b.eq .Lpi4_uart_write_storage_gate_ok
    ldr w1, =PI4_START_STORAGE_BPB_OK
    cmp w0, w1
    b.eq .Lpi4_uart_write_storage_gate_ok
    ldr w1, =PI4_START_STORAGE_ROOT_OK
    cmp w0, w1
    b.eq .Lpi4_uart_write_storage_gate_ok
    ldr w1, =PI4_START_STORAGE_FILE_OK
    cmp w0, w1
    b.eq .Lpi4_uart_write_storage_gate_ok
    uxtw x0, w0
    bl pi4_uart_write_hex64
    b .Lpi4_uart_write_storage_gate_done

.Lpi4_uart_write_storage_gate_wait:
    adr x0, msg_status_wait_value
    bl pi4_uart_write_string
    b .Lpi4_uart_write_storage_gate_done

.Lpi4_uart_write_storage_gate_ok:
    adr x0, msg_status_ok_value
    bl pi4_uart_write_string

.Lpi4_uart_write_storage_gate_done:
    ldp x29, x30, [sp], #16
    ret
.size pi4_uart_write_storage_gate_word, . - pi4_uart_write_storage_gate_word

.type pi4_uart_write_storage_status_word, %function
pi4_uart_write_storage_status_word:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    ldr w1, =PI4_START_STORAGE_WAIT
    cmp w0, w1
    b.eq .Lpi4_uart_write_storage_status_wait
    ldr w1, =PI4_START_STORAGE_SD_OK
    cmp w0, w1
    b.eq .Lpi4_uart_write_storage_status_ok
    ldr w1, =PI4_START_STORAGE_ENOSYS
    cmp w0, w1
    b.eq .Lpi4_uart_write_storage_status_enosys
    ldr w1, =PI4_START_STORAGE_EINVAL
    cmp w0, w1
    b.eq .Lpi4_uart_write_storage_status_einval
    ldr w1, =PI4_START_STORAGE_EIO
    cmp w0, w1
    b.eq .Lpi4_uart_write_storage_status_eio
    ldr w1, =PI4_START_STORAGE_SDCTL_EMMC2
    cmp w0, w1
    b.eq .Lpi4_uart_write_storage_status_emmc2
    ldr w1, =PI4_START_STORAGE_SDCTL_EMMC
    cmp w0, w1
    b.eq .Lpi4_uart_write_storage_status_emmc
    uxtw x0, w0
    bl pi4_uart_write_hex64
    b .Lpi4_uart_write_storage_status_done

.Lpi4_uart_write_storage_status_wait:
    adr x0, msg_status_wait_value
    bl pi4_uart_write_string
    b .Lpi4_uart_write_storage_status_done

.Lpi4_uart_write_storage_status_ok:
    adr x0, msg_status_ok_value
    bl pi4_uart_write_string
    b .Lpi4_uart_write_storage_status_done

.Lpi4_uart_write_storage_status_enosys:
    adr x0, msg_status_enosys_value
    bl pi4_uart_write_string
    b .Lpi4_uart_write_storage_status_done

.Lpi4_uart_write_storage_status_einval:
    adr x0, msg_status_einval_value
    bl pi4_uart_write_string
    b .Lpi4_uart_write_storage_status_done

.Lpi4_uart_write_storage_status_eio:
    adr x0, msg_status_eio_value
    bl pi4_uart_write_string
    b .Lpi4_uart_write_storage_status_done

.Lpi4_uart_write_storage_status_emmc2:
    adr x0, msg_status_emmc2_value
    bl pi4_uart_write_string
    b .Lpi4_uart_write_storage_status_done

.Lpi4_uart_write_storage_status_emmc:
    adr x0, msg_status_emmc_value
    bl pi4_uart_write_string

.Lpi4_uart_write_storage_status_done:
    ldp x29, x30, [sp], #16
    ret
.size pi4_uart_write_storage_status_word, . - pi4_uart_write_storage_status_word

.type pi4_sync_storage_status, %function
pi4_sync_storage_status:
    adr x0, pi4_storage_status_block_copied_bytes
    ldr x2, [x0]
    cbnz x2, .Lpi4_sync_storage_copy_status

    ldr w1, =PI4_START_STORAGE_WAIT
    adr x0, pi4_status_pi4sd
    str w1, [x0]
    adr x0, pi4_status_pi4fat
    str w1, [x0]
    adr x0, pi4_status_pi4vfs
    str w1, [x0]
    ret

.Lpi4_sync_storage_copy_status:
    adr x0, pi4_storage_status_pi4sd
    ldr w1, [x0]
    adr x0, pi4_status_pi4sd
    str w1, [x0]
    adr x0, pi4_storage_status_pi4fat
    ldr w1, [x0]
    adr x0, pi4_status_pi4fat
    str w1, [x0]
    adr x0, pi4_storage_status_pi4vfs
    ldr w1, [x0]
    adr x0, pi4_status_pi4vfs
    str w1, [x0]
    ret
.size pi4_sync_storage_status, . - pi4_sync_storage_status

.type pi4_memory_gate_ready, %function
pi4_memory_gate_ready:
    adr x1, pi4_status_pi4el0_image_base
    ldr x2, [x1]
    cbz x2, .Lpi4_memory_gate_wait
    adr x1, pi4_status_pi4el0_image_end
    ldr x3, [x1]
    cmp x3, x2
    b.ls .Lpi4_memory_gate_wait
    adr x1, pi4_status_pi4el0_image_bytes
    ldr x4, [x1]
    sub x5, x3, x2
    cmp x4, x5
    b.ne .Lpi4_memory_gate_wait

    adr x1, pi4_status_pi4el0_stack_base
    ldr x2, [x1]
    cbz x2, .Lpi4_memory_gate_wait
    adr x1, pi4_status_pi4el0_stack_top
    ldr x3, [x1]
    cmp x3, x2
    b.ls .Lpi4_memory_gate_wait
    adr x1, pi4_status_pi4el0_stack_bytes
    ldr x4, [x1]
    sub x5, x3, x2
    cmp x4, x5
    b.ne .Lpi4_memory_gate_wait
    cmp x5, #PI4_EL0_STACK_FRAME_BYTES
    b.lo .Lpi4_memory_gate_wait
    cmp x5, #PI4_EL0_STACK_TOTAL_BYTES
    b.hi .Lpi4_memory_gate_wait

    adr x1, pi4_status_pi4el0_alloc_flags
    ldr x2, [x1]
    mov x3, #PI4_EL0_ALLOC_REQUIRED_FLAGS
    cmp x2, x3
    b.ne .Lpi4_memory_gate_wait
    adr x1, pi4_status_pi4el0_alloc_count
    ldr x2, [x1]
    cmp x2, #PI4_EL0_ALLOC_BOOT_COUNT
    b.ne .Lpi4_memory_gate_wait

    adr x1, pi4_status_pi4ptable_base
    ldr x2, [x1]
    cbz x2, .Lpi4_memory_gate_wait
    adr x1, pi4_status_pi4ptable_capacity
    ldr x3, [x1]
    cbz x3, .Lpi4_memory_gate_wait
    adr x1, pi4_status_pi4ptable_entry_bytes
    ldr x4, [x1]
    cmp x4, #PI4_PROC_TABLE_ENTRY_BYTES
    b.ne .Lpi4_memory_gate_wait
    adr x1, pi4_status_pi4ptable_used
    ldr x4, [x1]
    cbz x4, .Lpi4_memory_gate_wait
    cmp x4, x3
    b.hi .Lpi4_memory_gate_wait

    adr x1, pi4_status_proc_current_pid
    ldr x2, [x1]
    cbz x2, .Lpi4_memory_gate_wait
    adr x1, pi4_status_proc_next_pid
    ldr x3, [x1]
    cmp x3, x2
    b.ls .Lpi4_memory_gate_wait
    adr x1, pi4_status_proc_alloc_count
    ldr x2, [x1]
    cbz x2, .Lpi4_memory_gate_wait
    cmp x2, x4
    b.lo .Lpi4_memory_gate_wait

    mov x0, #1
    ret

.Lpi4_memory_gate_wait:
    mov x0, xzr
    ret
.size pi4_memory_gate_ready, . - pi4_memory_gate_ready

.type pi4_uart_write_memory_tuple, %function
pi4_uart_write_memory_tuple:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    bl pi4_memory_gate_ready
    cbnz x0, .Lpi4_uart_write_memory_ok
    adr x0, msg_status_pi4mem_wait
    bl pi4_uart_write_string
    b .Lpi4_uart_write_memory_prefix_done

.Lpi4_uart_write_memory_ok:
    adr x0, msg_status_pi4mem_ok
    bl pi4_uart_write_string

.Lpi4_uart_write_memory_prefix_done:
    mov x0, #PI4_KERNEL8_LOAD_ADDR
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    ldr x0, =__bss_end
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_words
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_words_end
    bl pi4_uart_write_hex64

    adr x0, msg_status_pi4stack
    bl pi4_uart_write_string
    adr x0, pi4_boot_stack
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_boot_stack_top
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4el0_stack_base
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4el0_stack_top
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    adr x0, msg_status_pi4umem
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4el0_image_base
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4el0_image_end
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4elf_entry
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4elf_filesz
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    adr x0, msg_status_pi4ualloc
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4el0_image_base
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4el0_image_end
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4el0_image_bytes
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4el0_stack_base
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4el0_stack_top
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4el0_stack_bytes
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4el0_alloc_flags
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4el0_alloc_count
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    adr x0, msg_status_pi4fbmap
    bl pi4_uart_write_string
    adr x0, pi4_status_fb_cpu_base
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_fb_size
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_fb_pitch
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_fb_depth
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    adr x0, msg_status_pi4ptable
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4ptable_base
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4ptable_capacity
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4ptable_entry_bytes
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4ptable_used
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    ldp x29, x30, [sp], #16
    ret
.size pi4_uart_write_memory_tuple, . - pi4_uart_write_memory_tuple

.type pi4_uart_write_input_tuple, %function
pi4_uart_write_input_tuple:
    stp x29, x30, [sp, #-96]!
    mov x29, sp

    ldr x16, =pi4_uart_input_snapshot
    blr x16
    stp x0, x1, [sp, #16]
    stp x2, x3, [sp, #32]
    str x4, [sp, #48]

    adr x0, msg_status_pi4input
    bl pi4_uart_write_string
    bl pi4_uart_write_usb_input_status
    adr x0, msg_status_pi4inputdev
    bl pi4_uart_write_string
    bl pi4_uart_write_input_device_tuple

    adr x0, msg_status_pi4inputq
    bl pi4_uart_write_string
    ldr x0, [sp, #16]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    ldr x0, [sp, #24]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    ldr x0, [sp, #32]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    ldr x0, [sp, #40]
    bl pi4_uart_write_hex64

    adr x0, msg_status_pi4inputlast
    bl pi4_uart_write_string
    ldr x16, =pi4_input_last_snapshot
    blr x16
    cmp x0, #PI4_VIBE_INPUT_DEVICE_UART
    b.ne .Lpi4_input_tuple_last_value_ready
    mov x1, x2
.Lpi4_input_tuple_last_value_ready:
    str x1, [sp, #48]
    cbz x0, .Lpi4_input_tuple_no_last
    b .Lpi4_input_tuple_emit_last_device
.Lpi4_input_tuple_no_last:
    mov x0, xzr
    str xzr, [sp, #48]
.Lpi4_input_tuple_emit_last_device:
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    ldr x0, [sp, #48]
    bl pi4_uart_write_hex64

    ldr x16, =pi4_uart_input_event_counts_snapshot
    blr x16
    stp x0, x1, [sp, #56]
    stp x2, x3, [sp, #72]
    str x4, [sp, #88]

    adr x0, msg_status_pi4inputevt
    bl pi4_uart_write_string
    ldr x0, [sp, #56]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    ldr x0, [sp, #64]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    ldr x0, [sp, #72]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    ldr x0, [sp, #80]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    ldr x0, [sp, #88]
    bl pi4_uart_write_hex64

    ldr x16, =pi4_uart_input_rx_debug_snapshot
    blr x16
    stp x0, x1, [sp, #16]
    stp x2, x3, [sp, #32]
    stp x4, x5, [sp, #48]

    adr x0, msg_status_pi4uartrx
    bl pi4_uart_write_string
    ldr x0, [sp, #16]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    ldr x0, [sp, #24]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    ldr x0, [sp, #32]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    ldr x0, [sp, #40]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    ldr x0, [sp, #48]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    ldr x0, [sp, #56]
    bl pi4_uart_write_hex64

    ldp x29, x30, [sp], #96
    ret
.size pi4_uart_write_input_tuple, . - pi4_uart_write_input_tuple

.type pi4_uart_write_usb_input_status, %function
pi4_uart_write_usb_input_status:
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    str x21, [sp, #32]

    ldr x16, =pi4_usb_input_snapshot
    blr x16
    mov x19, x0
    mov x20, x1
    mov x21, x2

    cbz x4, .Lpi4_uart_write_usb_input_mouse_ready_check
    cbnz x5, .Lpi4_uart_write_usb_input_both
    b .Lpi4_uart_write_usb_input_keyboard
.Lpi4_uart_write_usb_input_mouse_ready_check:
    cbnz x5, .Lpi4_uart_write_usb_input_mouse

    cmp x20, #PI4_START_USB_DEVICE_KIND_KEYBOARD
    b.eq .Lpi4_uart_write_usb_input_keyboard
    cmp x20, #PI4_START_USB_DEVICE_KIND_MOUSE
    b.eq .Lpi4_uart_write_usb_input_mouse

    ldr x16, =pi4_input_keyboard_snapshot
    blr x16
    cbnz x0, .Lpi4_uart_write_usb_input_keyboard
    ldr x16, =pi4_input_mouse_status_snapshot
    blr x16
    cbnz x0, .Lpi4_uart_write_usb_input_mouse

    cbnz x19, .Lpi4_uart_write_usb_input_hid
    cmp x21, #PI4_START_USB_STATUS_HID
    b.eq .Lpi4_uart_write_usb_input_hid
    cmp x21, #PI4_START_USB_STATUS_ADDR
    b.eq .Lpi4_uart_write_usb_input_addr
    cmp x21, #PI4_START_USB_STATUS_PORT
    b.eq .Lpi4_uart_write_usb_input_port
    cmp x21, #PI4_START_USB_STATUS_HOST
    b.eq .Lpi4_uart_write_usb_input_host

    adr x0, msg_status_pi4usb_wait
    b .Lpi4_uart_write_usb_input_emit
.Lpi4_uart_write_usb_input_keyboard:
    adr x0, msg_status_pi4usb_keyboard
    b .Lpi4_uart_write_usb_input_emit
.Lpi4_uart_write_usb_input_mouse:
    adr x0, msg_status_pi4usb_mouse
    b .Lpi4_uart_write_usb_input_emit
.Lpi4_uart_write_usb_input_both:
    adr x0, msg_status_pi4usb_both
    b .Lpi4_uart_write_usb_input_emit
.Lpi4_uart_write_usb_input_hid:
    adr x0, msg_status_pi4usb_hid
    b .Lpi4_uart_write_usb_input_emit
.Lpi4_uart_write_usb_input_addr:
    adr x0, msg_status_pi4usb_addr
    b .Lpi4_uart_write_usb_input_emit
.Lpi4_uart_write_usb_input_port:
    adr x0, msg_status_pi4usb_port
    b .Lpi4_uart_write_usb_input_emit
.Lpi4_uart_write_usb_input_host:
    adr x0, msg_status_pi4usb_host
.Lpi4_uart_write_usb_input_emit:
    bl pi4_uart_write_string
    ldr x21, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret
.size pi4_uart_write_usb_input_status, . - pi4_uart_write_usb_input_status

.type pi4_uart_write_input_device_tuple, %function
pi4_uart_write_input_device_tuple:
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]

    ldr x16, =pi4_input_last_snapshot
    blr x16
    mov x19, x0
    cmp x19, #PI4_VIBE_INPUT_DEVICE_KEYBOARD
    b.eq .Lpi4_inputdev_emit_keyboard
    cmp x19, #PI4_VIBE_INPUT_DEVICE_MOUSE
    b.eq .Lpi4_inputdev_emit_mouse

    ldr x16, =pi4_usb_input_snapshot
    blr x16
    mov x20, x0
    mov x21, x1
    cmp x21, #PI4_START_USB_DEVICE_KIND_KEYBOARD
    b.eq .Lpi4_inputdev_emit_keyboard
    cmp x21, #PI4_START_USB_DEVICE_KIND_MOUSE
    b.eq .Lpi4_inputdev_emit_mouse

    ldr x16, =pi4_input_keyboard_snapshot
    blr x16
    cbnz x0, .Lpi4_inputdev_emit_keyboard
    ldr x16, =pi4_input_mouse_status_snapshot
    blr x16
    cbnz x0, .Lpi4_inputdev_emit_mouse
    cbnz x20, .Lpi4_inputdev_emit_usb
    cmp x21, #PI4_START_USB_DEVICE_KIND_UNKNOWN
    b.ne .Lpi4_inputdev_emit_usb
    b .Lpi4_inputdev_emit_uart

.Lpi4_inputdev_emit_keyboard:
    mov x0, #PI4_VIBE_INPUT_DEVICE_KEYBOARD
    mov x1, #PI4_VIBE_INPUT_DEVICE_STATUS_READY
    mov x2, #(PI4_VIBE_INPUT_DEVICE_CAP_KEYS | PI4_VIBE_INPUT_DEVICE_CAP_STATE_SNAPSHOT)
    b .Lpi4_inputdev_emit_values
.Lpi4_inputdev_emit_mouse:
    mov x0, #PI4_VIBE_INPUT_DEVICE_MOUSE
    mov x1, #PI4_VIBE_INPUT_DEVICE_STATUS_READY
    mov x2, #(PI4_VIBE_INPUT_DEVICE_CAP_RELATIVE_POINTER | PI4_VIBE_INPUT_DEVICE_CAP_BUTTONS | PI4_VIBE_INPUT_DEVICE_CAP_STATE_SNAPSHOT)
    b .Lpi4_inputdev_emit_values
.Lpi4_inputdev_emit_usb:
    mov x0, #PI4_VIBE_INPUT_DEVICE_USB
    mov x1, #PI4_VIBE_INPUT_DEVICE_STATUS_READY
    mov x2, #PI4_VIBE_INPUT_CAP_POLL_EVENT
    b .Lpi4_inputdev_emit_values
.Lpi4_inputdev_emit_uart:
    mov x0, #PI4_VIBE_INPUT_DEVICE_UART
    mov x1, #PI4_VIBE_INPUT_DEVICE_STATUS_READY
    mov x2, #PI4_UART_INPUT_CAPS

.Lpi4_inputdev_emit_values:
    mov x22, x1
    mov x19, x2
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    mov x0, x22
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    mov x0, x19
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    mov x0, #PI4_UART_INPUT_QUEUE_SIZE
    bl pi4_uart_write_hex64

    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret
.size pi4_uart_write_input_device_tuple, . - pi4_uart_write_input_device_tuple

.type pi4_uart_write_uabi_tuple, %function
pi4_uart_write_uabi_tuple:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    adr x0, pi4_status_pi4uabi
    ldr w1, [x0]
    ldr w2, =VIBE_PI4_STATUS_PI4UABI_OK
    cmp w1, w2
    b.eq .Lpi4_uart_write_uabi_ok

    adr x0, msg_status_elf_tuple
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4elf_base
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4elf_entry
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4elf_phdr
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4elf_filesz
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    bl pi4_uart_write_elf_load_metadata

    adr x0, msg_status_ustack_tuple
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4ustack_sp
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4ustack_top
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4ustack_bytes
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4ustack_argc
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    adr x0, msg_status_ustackv_tuple
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4ustack_argv
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4ustack_envp
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4ustack_auxv
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4ustack_flags
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    b .Lpi4_uart_write_uabi_done

.Lpi4_uart_write_uabi_ok:
    adr x0, pi4_status_pi4exec_count
    ldr x1, [x0]
    cbz x1, .Lpi4_uart_write_uabi_ok_init
    adr x0, pi4_status_pi4exec_result
    ldr x1, [x0]
    cbnz x1, .Lpi4_uart_write_uabi_ok_init
    adr x0, pi4_status_pi4appreq_path_bytes
    ldr x1, [x0]
    cbnz x1, .Lpi4_uart_write_uabi_ok_app_path

.Lpi4_uart_write_uabi_ok_init:
    adr x0, msg_status_pi4uabi_ok
    bl pi4_uart_write_string
    b .Lpi4_uart_write_uabi_ok_entry

.Lpi4_uart_write_uabi_ok_app_path:
    adr x0, msg_status_pi4uabi_ok_path_prefix
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4appreq_path_copy
    bl pi4_uart_write_string
    adr x0, msg_status_pi4uabi_ok_upath_prefix
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4appreq_path_copy
    bl pi4_uart_write_string
    adr x0, msg_status_pi4uabi_ok_uentry_prefix
    bl pi4_uart_write_string

.Lpi4_uart_write_uabi_ok_entry:
    adr x0, pi4_status_pi4elf_entry
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_execsys_tuple
    bl pi4_uart_write_string
    adr x0, pi4_status_svc_runtime_hits
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_svc_hits
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_pi4ustack_tuple
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4ustack_sp
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4ustack_top
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4ustack_bytes
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4ustack_argc
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_ustackv_tuple
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4ustack_argv
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4ustack_envp
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4ustack_auxv
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4ustack_flags
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_execmap_tuple
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4elf_load_vaddr
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4elf_load_memsz
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4elf_load_flags
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_pstat_tuple
    bl pi4_uart_write_string
    adr x0, pi4_status_proc_current_pid
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_proc_next_pid
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_proc_alloc_count
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_proc_el0_launch_count
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_proc_el0_return_count
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_proc_exec_launch_count
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_procpool_tuple
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4ptable_used
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4ptable_capacity
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_pidseq_tuple
    bl pi4_uart_write_string
    adr x0, pi4_status_proc_current_pid
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_proc_next_pid
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_pexec_tuple
    bl pi4_uart_write_string
    adr x0, pi4_status_proc_exec_pid
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_proc_exec_slot
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_proc_exec_kind
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_proc_exec_state
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_proc_exec_spsr
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_preturn_tuple
    bl pi4_uart_write_string
    adr x0, pi4_status_proc_return_pid
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_proc_return_slot
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_proc_return_kind
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_proc_return_code
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_proc_return_elr
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_pfault_tuple
    bl pi4_uart_write_string
    adr x0, pi4_status_proc_fault_pid
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_proc_fault_slot
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_proc_fault_kind
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_proc_fault_mode
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_proc_fault_count
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_proc_fault_esr
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_proc_fault_elr
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_elf_tuple_vfs
    bl pi4_uart_write_string
    bl pi4_uart_write_elf_load_metadata

.Lpi4_uart_write_uabi_done:
    ldp x29, x30, [sp], #16
    ret
.size pi4_uart_write_uabi_tuple, . - pi4_uart_write_uabi_tuple

.type pi4_uart_write_elf_load_metadata, %function
pi4_uart_write_elf_load_metadata:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    adr x0, msg_status_elf_entry
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4elf_entry
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    adr x0, msg_status_elf_phdr
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4elf_phdr
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4elf_phent
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4elf_phnum
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    adr x0, msg_status_elf_load
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4elf_load_vaddr
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4elf_load_paddr
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4elf_load_filesz
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4elf_load_memsz
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4elf_load_flags
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4elf_load_align
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    ldp x29, x30, [sp], #16
    ret
.size pi4_uart_write_elf_load_metadata, . - pi4_uart_write_elf_load_metadata

.type pi4_uart_write_dtb_tuple, %function
pi4_uart_write_dtb_tuple:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    adr x0, pi4_status_pi4dtb
    ldr w0, [x0]
    ldr w1, =VIBE_PI4_STATUS_PI4DTB_OK
    cmp w0, w1
    b.eq .Ldtb_tuple_ok
    adr x0, msg_status_dtb_bad
    b .Ldtb_tuple_emit_label
.Ldtb_tuple_ok:
    adr x0, msg_status_dtb_ok
.Ldtb_tuple_emit_label:
    bl pi4_uart_write_string

    adr x0, pi4_status_pi4dtb_root
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4dtb_total_size
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4dtb_version
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4dtb_struct_off
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    bl pi4_uart_write_board_tuple
    bl pi4_uart_write_soc_tuple
    bl pi4_uart_write_gic_tuple
    bl pi4_uart_write_mailbox_fb_tuple

    ldp x29, x30, [sp], #16
    ret
.size pi4_uart_write_dtb_tuple, . - pi4_uart_write_dtb_tuple

.type pi4_uart_write_board_tuple, %function
pi4_uart_write_board_tuple:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    adr x0, pi4_status_pi4boarddtb
    ldr w0, [x0]
    ldr w1, =VIBE_PI4_STATUS_PI4BOARDDTB_OK
    cmp w0, w1
    b.eq .Lboard_tuple_ok
    adr x0, msg_status_pi4boarddtb_wait
    b .Lboard_tuple_emit_label
.Lboard_tuple_ok:
    adr x0, msg_status_pi4boarddtb_ok
.Lboard_tuple_emit_label:
    bl pi4_uart_write_string

    adr x0, pi4_status_pi4model_ptr
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4model_len
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4model_hash
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_pi4compat
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4compat_ptr
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4compat_len
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4compat_hash
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    ldp x29, x30, [sp], #16
    ret
.size pi4_uart_write_board_tuple, . - pi4_uart_write_board_tuple

.type pi4_uart_write_soc_tuple, %function
pi4_uart_write_soc_tuple:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    adr x0, pi4_status_pi4socdtb
    ldr w0, [x0]
    ldr w1, =VIBE_PI4_STATUS_PI4SOCDTB_OK
    cmp w0, w1
    b.eq .Lsoc_tuple_ok
    adr x0, msg_status_pi4socdtb_wait
    b .Lsoc_tuple_emit_label
.Lsoc_tuple_ok:
    adr x0, msg_status_pi4socdtb_ok
.Lsoc_tuple_emit_label:
    bl pi4_uart_write_string

    adr x0, pi4_status_pi4socrange_bus
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4socrange_periph
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4socrange_span
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4socrange_node
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_pi4socrangelen
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4socrange_len
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    ldp x29, x30, [sp], #16
    ret
.size pi4_uart_write_soc_tuple, . - pi4_uart_write_soc_tuple

.type pi4_uart_write_gic_tuple, %function
pi4_uart_write_gic_tuple:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    adr x0, pi4_status_pi4gicdtb
    ldr w0, [x0]
    ldr w1, =VIBE_PI4_STATUS_PI4GICDTB_OK
    cmp w0, w1
    b.eq .Lgic_tuple_ok
    adr x0, msg_status_pi4gicdtb_wait
    b .Lgic_tuple_emit_label
.Lgic_tuple_ok:
    adr x0, msg_status_pi4gicdtb_ok
.Lgic_tuple_emit_label:
    bl pi4_uart_write_string

    adr x0, pi4_status_pi4gic_node
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_pi4giccompat
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4giccompat_ptr
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4giccompat_len
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4giccompat_hash
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_pi4gicreg
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4gicreg0
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4gicreg1
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4gicreg2
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4gicreg3
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4gicreg4
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4gicreg5
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4gicreg6
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4gicreg7
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_pi4gicreglen
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4gicreg_len
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    bl pi4_uart_write_gic_mmio_tuple
    bl pi4_uart_write_gic_cfg_tuple
    bl pi4_uart_write_irq_tuple

    ldp x29, x30, [sp], #16
    ret
.size pi4_uart_write_gic_tuple, . - pi4_uart_write_gic_tuple

.type pi4_uart_write_gic_mmio_tuple, %function
pi4_uart_write_gic_mmio_tuple:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    adr x0, pi4_status_pi4gicmmio
    ldr w0, [x0]
    ldr w1, =VIBE_PI4_STATUS_PI4GICMMIO_OK
    cmp w0, w1
    b.eq .Lgic_mmio_tuple_ok
    adr x0, msg_status_pi4gicmmio_wait
    b .Lgic_mmio_tuple_emit_label
.Lgic_mmio_tuple_ok:
    adr x0, msg_status_pi4gicmmio_ok
.Lgic_mmio_tuple_emit_label:
    bl pi4_uart_write_string

    adr x0, pi4_status_pi4gic_dist_base
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4gic_cpu_base
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4gic_dist_len
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4gic_cpu_len
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    ldp x29, x30, [sp], #16
    ret
.size pi4_uart_write_gic_mmio_tuple, . - pi4_uart_write_gic_mmio_tuple

.type pi4_uart_write_gic_cfg_tuple, %function
pi4_uart_write_gic_cfg_tuple:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    adr x0, pi4_status_pi4giccfg
    ldr w0, [x0]
    ldr w1, =VIBE_PI4_STATUS_PI4GICCFG_OK
    cmp w0, w1
    b.eq .Lgic_cfg_tuple_ok
    adr x0, msg_status_pi4giccfg_wait
    b .Lgic_cfg_tuple_emit_label
.Lgic_cfg_tuple_ok:
    adr x0, msg_status_pi4giccfg_ok
.Lgic_cfg_tuple_emit_label:
    bl pi4_uart_write_string

    adr x0, pi4_status_pi4gic_dist_ctlr
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4gic_cpu_ctlr
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4gic_cpu_pmr
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4gic_dist_typer
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_pi4giciidr
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4gic_dist_iidr
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4gic_cpu_iidr
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    ldp x29, x30, [sp], #16
    ret
.size pi4_uart_write_gic_cfg_tuple, . - pi4_uart_write_gic_cfg_tuple

.type pi4_uart_write_irq_tuple, %function
pi4_uart_write_irq_tuple:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    adr x0, pi4_status_pi4irq
    ldr w0, [x0]
    ldr w1, =VIBE_PI4_STATUS_PI4IRQ_OK
    cmp w0, w1
    b.eq .Lirq_tuple_ok
    adr x0, msg_status_pi4irq_wait
    bl pi4_uart_write_string
    bl pi4_uart_write_preempt_tuple
    ldp x29, x30, [sp], #16
    ret

.Lirq_tuple_ok:
    adr x0, msg_status_pi4irq_ok
    bl pi4_uart_write_string
    adr x0, pi4_status_irq_gic_dist_ctlr
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_irq_gic_cpu_ctlr
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_timer_irq_id
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_timer_eoi_id
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_clockhz
    bl pi4_uart_write_string
    adr x0, pi4_status_timer_freq
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_clocktick
    bl pi4_uart_write_string
    adr x0, pi4_status_timer_tick
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_clockirq
    bl pi4_uart_write_string
    adr x0, pi4_status_timer_irq_id
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_ticks
    bl pi4_uart_write_string
    adr x0, pi4_status_timer_ticks
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_pi4timer_ok
    bl pi4_uart_write_string
    bl pi4_uart_write_preempt_tuple

    ldp x29, x30, [sp], #16
    ret
.size pi4_uart_write_irq_tuple, . - pi4_uart_write_irq_tuple

.type pi4_uart_write_preempt_tuple, %function
pi4_uart_write_preempt_tuple:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    bl pi4_refresh_preempt_status_from_sched
    adr x0, pi4_status_pi4preempt
    ldr w0, [x0]
    ldr w1, =VIBE_PI4_STATUS_PI4PREEMPT_OK
    cmp w0, w1
    b.eq .Lpreempt_tuple_ok
    bl pi4_uart_write_preempt_label
    adr x0, msg_status_wait_value
    b .Lpreempt_tuple_emit_label
.Lpreempt_tuple_ok:
    bl pi4_uart_write_preempt_evidence_tuple
    bl pi4_uart_write_preempt_label
    adr x0, msg_status_ok_value
.Lpreempt_tuple_emit_label:
    bl pi4_uart_write_string
    bl pi4_uart_write_preempt_skeleton_tuple

    ldp x29, x30, [sp], #16
    ret
.size pi4_uart_write_preempt_tuple, . - pi4_uart_write_preempt_tuple

.type pi4_uart_write_preempt_evidence_tuple, %function
pi4_uart_write_preempt_evidence_tuple:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    adr x0, msg_status_preempt_count
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4sched_switches
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_pirq_count
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4sched_switches
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_pctx_count
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4sched_switches
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_pfrom_pid
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4preempt_from_pid
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_pto_pid
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4preempt_to_pid
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    ldp x29, x30, [sp], #16
    ret
.size pi4_uart_write_preempt_evidence_tuple, . - pi4_uart_write_preempt_evidence_tuple

.type pi4_uart_write_preempt_skeleton_tuple, %function
pi4_uart_write_preempt_skeleton_tuple:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    adr x0, msg_status_pi4ctx
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4ctx_base
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4ctx_bytes
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4ctx_version
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4ctx_pid
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4ctx_kind
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4ctx_elr
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4ctx_sp
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4ctx_spsr
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4ctx_flags
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    adr x0, msg_status_pi4sched
    bl pi4_uart_write_string
    adr x0, pi4_status_timer_ticks
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4sched_attempts
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4sched_no_peer
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4sched_switches
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4sched_current_pid
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_pi4sched_last_pid
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    ldp x29, x30, [sp], #16
    ret
.size pi4_uart_write_preempt_skeleton_tuple, . - pi4_uart_write_preempt_skeleton_tuple

.type pi4_uart_write_preempt_label, %function
pi4_uart_write_preempt_label:
    adr x0, msg_status_pi4preempt
    b pi4_uart_write_string
.size pi4_uart_write_preempt_label, . - pi4_uart_write_preempt_label

.type pi4_uart_write_mailbox_fb_tuple, %function
pi4_uart_write_mailbox_fb_tuple:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    adr x0, pi4_status_pi4mailbox
    ldr w0, [x0]
    ldr w1, =VIBE_PI4_STATUS_PI4MAILBOX_OK
    cmp w0, w1
    b.eq .Lmailbox_tuple_ok
    adr x0, msg_status_pi4mailbox_wait
    bl pi4_uart_write_string
    adr x0, msg_status_pi4fb_wait
    bl pi4_uart_write_string
    b .Lmailbox_fb_tuple_done

.Lmailbox_tuple_ok:
    adr x0, msg_status_pi4mailbox_ok
    bl pi4_uart_write_string

    adr x0, pi4_status_mbox_req
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_fb_bus_base
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_fb_pitch
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_fb_format
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    adr x0, pi4_status_pi4fb
    ldr w0, [x0]
    ldr w1, =VIBE_PI4_STATUS_PI4FB_OK
    cmp w0, w1
    b.eq .Lpi4fb_tuple_ok
    adr x0, msg_status_pi4fb_wait
    bl pi4_uart_write_string
    b .Lmailbox_fb_tuple_done

.Lpi4fb_tuple_ok:
    adr x0, pi4_status_gfx
    ldr w0, [x0]
    ldr w1, =VIBE_PI4_STATUS_GFX_OK
    cmp w0, w1
    b.eq .Lgfx_tuple_ok
    adr x0, msg_status_gfx_wait
    b .Lgfx_tuple_emit_label
.Lgfx_tuple_ok:
    adr x0, msg_status_gfx_ok
.Lgfx_tuple_emit_label:
    bl pi4_uart_write_string

    adr x0, pi4_status_fb
    ldr w0, [x0]
    ldr w1, =VIBE_PI4_STATUS_FB_PI4FB
    cmp w0, w1
    b.eq .Lfb_tuple_pi4fb
    adr x0, msg_status_fb_wait
    b .Lfb_tuple_emit_label
.Lfb_tuple_pi4fb:
    adr x0, msg_status_fb_pi4fb
.Lfb_tuple_emit_label:
    bl pi4_uart_write_string

    adr x0, msg_status_fbgeom
    bl pi4_uart_write_string
    adr x0, pi4_status_fb_width
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_fb_height
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_fb_pitch
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_fb_depth
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    adr x0, msg_status_fbpresent
    bl pi4_uart_write_string
    adr x0, pi4_status_fb_present_count
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_fb_present_source
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_fb_write
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_fb_sample
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    adr x0, msg_status_fbdirty
    bl pi4_uart_write_string
    adr x0, pi4_status_fb_dirty_x
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_fb_dirty_y
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_fb_dirty_width
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_fb_dirty_height
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_fb_dirty_count
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_fbclear
    bl pi4_uart_write_string
    adr x0, pi4_status_fb_clear_count
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    adr x0, msg_status_fbchange
    bl pi4_uart_write_string
    adr x0, pi4_status_fb_prev_frame_hash
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_fb_frame_hash
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_fb_change_count
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_fb_changed
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    adr x0, msg_status_fbabi
    bl pi4_uart_write_string
    adr x0, pi4_status_fb_abi_mask
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    mov x0, #PI4_FB_ABI_FULL_MASK
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_fb_abi_last_op
    ldr x0, [x0]
    bl pi4_uart_write_hex64
    adr x0, msg_status_slash
    bl pi4_uart_write_string
    adr x0, pi4_status_fb_abi_last_source
    ldr x0, [x0]
    bl pi4_uart_write_hex64

    adr x0, msg_status_pi4fb_ok
    bl pi4_uart_write_string

.Lmailbox_fb_tuple_done:
    adr x0, msg_status_pi4currentel
    bl pi4_uart_write_string

    ldp x29, x30, [sp], #16
    ret
.size pi4_uart_write_mailbox_fb_tuple, . - pi4_uart_write_mailbox_fb_tuple

.type pi4_validate_dtb, %function
pi4_validate_dtb:
    mov x13, x20
    mov w14, wzr

.Lpi4_dtb_validate_candidate:
    cbz x13, .Lpi4_dtb_candidate_bad
    tst x13, #0x3
    b.ne .Lpi4_dtb_candidate_bad

    ldr w1, [x13, #0]
    rev w1, w1
    ldr w0, =PI4_FDT_MAGIC
    cmp w1, w0
    b.ne .Lpi4_dtb_candidate_bad

    ldr w2, [x13, #4]
    rev w2, w2
    cmp w2, #PI4_FDT_HEADER_SIZE
    b.lo .Lpi4_dtb_candidate_bad

    ldr w3, [x13, #8]
    rev w3, w3
    ldr w4, [x13, #12]
    rev w4, w4
    ldr w5, [x13, #16]
    rev w5, w5
    ldr w6, [x13, #20]
    rev w6, w6
    ldr w7, [x13, #24]
    rev w7, w7
    ldr w8, [x13, #32]
    rev w8, w8
    ldr w9, [x13, #36]
    rev w9, w9

    cmp w6, #PI4_FDT_VERSION_MIN
    b.lo .Lpi4_dtb_candidate_bad
    cmp w7, w6
    b.hi .Lpi4_dtb_candidate_bad
    cmp w3, #PI4_FDT_HEADER_SIZE
    b.lo .Lpi4_dtb_candidate_bad
    cmp w5, #PI4_FDT_HEADER_SIZE
    b.lo .Lpi4_dtb_candidate_bad
    cmp w3, w2
    b.hs .Lpi4_dtb_candidate_bad
    cmp w4, w2
    b.hs .Lpi4_dtb_candidate_bad
    cmp w5, w2
    b.hs .Lpi4_dtb_candidate_bad
    cmp w9, #PI4_FDT_ROOT_TOKEN_BYTES
    b.lo .Lpi4_dtb_candidate_bad

    uxtw x10, w2
    uxtw x11, w3
    uxtw x12, w9
    add x12, x11, x12
    cmp x12, x10
    b.hi .Lpi4_dtb_candidate_bad

    uxtw x11, w4
    uxtw x12, w8
    add x12, x11, x12
    cmp x12, x10
    b.hi .Lpi4_dtb_candidate_bad

    add x10, x13, w3, uxtw
    ldr w11, [x10]
    rev w11, w11
    cmp w11, #PI4_FDT_BEGIN_NODE
    b.ne .Lpi4_dtb_candidate_bad
    ldrb w12, [x10, #4]
    cbnz w12, .Lpi4_dtb_candidate_bad

    mov x20, x13
    adr x0, pi4_status_dtb
    str x20, [x0]

    adr x0, pi4_status_pi4dtb
    ldr w1, =VIBE_PI4_STATUS_PI4DTB_OK
    str w1, [x0]
    adr x0, pi4_status_pi4dtb_root
    str x10, [x0]
    adr x0, pi4_status_pi4dtb_total_size
    uxtw x1, w2
    str x1, [x0]
    adr x0, pi4_status_pi4dtb_version
    uxtw x1, w6
    str x1, [x0]
    adr x0, pi4_status_pi4dtb_struct_off
    uxtw x1, w3
    str x1, [x0]
    adr x0, pi4_status_pi4dtb_strings_off
    uxtw x1, w4
    str x1, [x0]
    adr x0, pi4_status_pi4dtb_struct_size
    uxtw x1, w9
    str x1, [x0]
    adr x0, pi4_status_pi4dtb_strings_size
    uxtw x1, w8
    str x1, [x0]
    adr x0, pi4_status_pi4dtb_root_token
    uxtw x1, w11
    str x1, [x0]
    ret

.Lpi4_dtb_candidate_bad:
    cbnz w14, .Lpi4_dtb_bad
    mov w14, #1
    // Raspberry Pi armstub stores the firmware-provided DTB pointer here.
    ldr x15, =PI4_ARMSTUB_DTB_PTR32_ADDR
    ldr w13, [x15]
    uxtw x13, w13
    cmp x13, x20
    b.ne .Lpi4_dtb_validate_candidate

.Lpi4_dtb_bad:
    adr x0, pi4_status_pi4dtb
    ldr w1, =VIBE_PI4_STATUS_PI4DTB_BAD
    str w1, [x0]
    ret
.size pi4_validate_dtb, . - pi4_validate_dtb

.type pi4_scan_soc_ranges, %function
pi4_scan_soc_ranges:
    adr x0, pi4_status_pi4dtb
    ldr w0, [x0]
    ldr w1, =VIBE_PI4_STATUS_PI4DTB_OK
    cmp w0, w1
    b.ne .Lpi4_soc_scan_done

    adr x0, pi4_status_pi4dtb_root
    ldr x1, [x0]
    cbz x1, .Lpi4_soc_scan_done
    adr x0, pi4_status_pi4dtb_struct_off
    ldr x9, [x0]
    adr x0, pi4_status_pi4dtb_struct_size
    ldr x10, [x0]
    add x11, x20, x9
    add x2, x11, x10
    adr x0, pi4_status_pi4dtb_strings_off
    ldr x9, [x0]
    adr x0, pi4_status_pi4dtb_strings_size
    ldr x10, [x0]
    add x3, x20, x9
    add x4, x3, x10

    add x5, x1, #8
    mov w6, #1
    mov x7, xzr
    mov w8, wzr

.Lpi4_soc_scan_loop:
    add x9, x5, #4
    cmp x9, x2
    b.hi .Lpi4_soc_scan_done
    mov x9, x5
    ldr w0, [x5]
    rev w0, w0
    add x5, x5, #4

    cmp w0, #PI4_FDT_BEGIN_NODE
    b.eq .Lpi4_soc_scan_begin_node
    cmp w0, #PI4_FDT_END_NODE
    b.eq .Lpi4_soc_scan_end_node
    cmp w0, #PI4_FDT_PROP
    b.eq .Lpi4_soc_scan_prop
    cmp w0, #PI4_FDT_NOP
    b.eq .Lpi4_soc_scan_loop
    cmp w0, #PI4_FDT_END
    b.eq .Lpi4_soc_scan_done
    b .Lpi4_soc_scan_done

.Lpi4_soc_scan_begin_node:
    cmp w6, #1
    b.ne .Lpi4_soc_scan_skip_name_match
    add x10, x5, #4
    cmp x10, x2
    b.hi .Lpi4_soc_scan_skip_name_match
    ldrb w10, [x5]
    cmp w10, #'s'
    b.ne .Lpi4_soc_scan_skip_name_match
    ldrb w10, [x5, #1]
    cmp w10, #'o'
    b.ne .Lpi4_soc_scan_skip_name_match
    ldrb w10, [x5, #2]
    cmp w10, #'c'
    b.ne .Lpi4_soc_scan_skip_name_match
    ldrb w10, [x5, #3]
    cbnz w10, .Lpi4_soc_scan_skip_name_match
    mov x7, x9
    mov w8, #2
.Lpi4_soc_scan_skip_name_match:
    mov x10, x5
.Lpi4_soc_scan_name_loop:
    cmp x10, x2
    b.hs .Lpi4_soc_scan_done
    ldrb w11, [x10], #1
    cbnz w11, .Lpi4_soc_scan_name_loop
    add x5, x10, #3
    bic x5, x5, #3
    cmp x5, x2
    b.hi .Lpi4_soc_scan_done
    add w6, w6, #1
    b .Lpi4_soc_scan_loop

.Lpi4_soc_scan_end_node:
    cbz w6, .Lpi4_soc_scan_done
    cmp w6, w8
    b.ne .Lpi4_soc_scan_not_leaving_soc
    mov x7, xzr
    mov w8, wzr
.Lpi4_soc_scan_not_leaving_soc:
    subs w6, w6, #1
    b.eq .Lpi4_soc_scan_done
    b .Lpi4_soc_scan_loop

.Lpi4_soc_scan_prop:
    add x9, x5, #8
    cmp x9, x2
    b.hi .Lpi4_soc_scan_done
    ldr w9, [x5]
    rev w9, w9
    ldr w10, [x5, #4]
    rev w10, w10
    add x11, x5, #8
    uxtw x12, w9
    add x12, x12, #3
    bic x12, x12, #3
    add x13, x11, x12
    cmp x13, x2
    b.hi .Lpi4_soc_scan_done

    cbz w8, .Lpi4_soc_scan_skip_prop
    cmp w6, w8
    b.ne .Lpi4_soc_scan_skip_prop
    cmp w9, #PI4_FDT_SOC_RANGES_MIN_BYTES
    b.lo .Lpi4_soc_scan_skip_prop
    tst w9, #0x3
    b.ne .Lpi4_soc_scan_skip_prop
    uxtw x12, w10
    add x14, x3, x12
    cmp x14, x4
    b.hs .Lpi4_soc_scan_skip_prop
    add x15, x14, #7
    cmp x15, x4
    b.hi .Lpi4_soc_scan_skip_prop
    ldrb w15, [x14]
    cmp w15, #'r'
    b.ne .Lpi4_soc_scan_skip_prop
    ldrb w15, [x14, #1]
    cmp w15, #'a'
    b.ne .Lpi4_soc_scan_skip_prop
    ldrb w15, [x14, #2]
    cmp w15, #'n'
    b.ne .Lpi4_soc_scan_skip_prop
    ldrb w15, [x14, #3]
    cmp w15, #'g'
    b.ne .Lpi4_soc_scan_skip_prop
    ldrb w15, [x14, #4]
    cmp w15, #'e'
    b.ne .Lpi4_soc_scan_skip_prop
    ldrb w15, [x14, #5]
    cmp w15, #'s'
    b.ne .Lpi4_soc_scan_skip_prop
    ldrb w15, [x14, #6]
    cbnz w15, .Lpi4_soc_scan_skip_prop

    ldr w0, [x11]
    rev w0, w0
    ldr w1, [x11, #4]
    rev w1, w1
    ldr w12, [x11, #8]
    rev w12, w12
    ldr w14, [x11, #12]
    rev w14, w14
    uxtw x0, w0
    uxtw x1, w1
    lsl x1, x1, #32
    uxtw x12, w12
    orr x1, x1, x12
    uxtw x2, w14

    adr x12, pi4_status_pi4socrange_bus
    str x0, [x12]
    adr x12, pi4_status_pi4socrange_periph
    str x1, [x12]
    adr x12, pi4_status_pi4socrange_span
    str x2, [x12]
    adr x12, pi4_status_pi4socrange_node
    str x7, [x12]
    adr x12, pi4_status_pi4socrange_len
    uxtw x14, w9
    str x14, [x12]
    adr x12, pi4_status_pi4socdtb
    ldr w14, =VIBE_PI4_STATUS_PI4SOCDTB_OK
    str w14, [x12]
    ret

.Lpi4_soc_scan_skip_prop:
    mov x5, x13
    b .Lpi4_soc_scan_loop

.Lpi4_soc_scan_done:
    ret
.size pi4_scan_soc_ranges, . - pi4_scan_soc_ranges

.type pi4_scan_gic_dtb, %function
pi4_scan_gic_dtb:
    adr x0, pi4_status_pi4dtb
    ldr w0, [x0]
    ldr w1, =VIBE_PI4_STATUS_PI4DTB_OK
    cmp w0, w1
    b.ne .Lpi4_gic_scan_done

    adr x0, pi4_status_pi4socdtb
    ldr w0, [x0]
    ldr w1, =VIBE_PI4_STATUS_PI4SOCDTB_OK
    cmp w0, w1
    b.ne .Lpi4_gic_scan_done

    adr x0, pi4_status_pi4dtb_root
    ldr x1, [x0]
    cbz x1, .Lpi4_gic_scan_done
    adr x0, pi4_status_pi4dtb_struct_off
    ldr x9, [x0]
    adr x0, pi4_status_pi4dtb_struct_size
    ldr x10, [x0]
    add x11, x20, x9
    add x2, x11, x10
    adr x0, pi4_status_pi4dtb_strings_off
    ldr x9, [x0]
    adr x0, pi4_status_pi4dtb_strings_size
    ldr x10, [x0]
    add x3, x20, x9
    add x4, x3, x10

    add x5, x1, #8
    mov w6, #1
    mov w7, wzr

.Lpi4_gic_scan_loop:
    add x9, x5, #4
    cmp x9, x2
    b.hi .Lpi4_gic_scan_done
    mov x9, x5
    ldr w0, [x5]
    rev w0, w0
    add x5, x5, #4

    cmp w0, #PI4_FDT_BEGIN_NODE
    b.eq .Lpi4_gic_scan_begin_node
    cmp w0, #PI4_FDT_END_NODE
    b.eq .Lpi4_gic_scan_end_node
    cmp w0, #PI4_FDT_PROP
    b.eq .Lpi4_gic_scan_prop
    cmp w0, #PI4_FDT_NOP
    b.eq .Lpi4_gic_scan_loop
    cmp w0, #PI4_FDT_END
    b.eq .Lpi4_gic_scan_done
    b .Lpi4_gic_scan_done

.Lpi4_gic_scan_begin_node:
    cbnz w7, .Lpi4_gic_scan_skip_name_match
    add x10, x5, #20
    cmp x10, x2
    b.hi .Lpi4_gic_scan_skip_name_match
    ldrb w10, [x5]
    cmp w10, #'i'
    b.ne .Lpi4_gic_scan_skip_name_match
    ldrb w10, [x5, #1]
    cmp w10, #'n'
    b.ne .Lpi4_gic_scan_skip_name_match
    ldrb w10, [x5, #2]
    cmp w10, #'t'
    b.ne .Lpi4_gic_scan_skip_name_match
    ldrb w10, [x5, #3]
    cmp w10, #'e'
    b.ne .Lpi4_gic_scan_skip_name_match
    ldrb w10, [x5, #4]
    cmp w10, #'r'
    b.ne .Lpi4_gic_scan_skip_name_match
    ldrb w10, [x5, #5]
    cmp w10, #'r'
    b.ne .Lpi4_gic_scan_skip_name_match
    ldrb w10, [x5, #6]
    cmp w10, #'u'
    b.ne .Lpi4_gic_scan_skip_name_match
    ldrb w10, [x5, #7]
    cmp w10, #'p'
    b.ne .Lpi4_gic_scan_skip_name_match
    ldrb w10, [x5, #8]
    cmp w10, #'t'
    b.ne .Lpi4_gic_scan_skip_name_match
    ldrb w10, [x5, #9]
    cmp w10, #'-'
    b.ne .Lpi4_gic_scan_skip_name_match
    ldrb w10, [x5, #10]
    cmp w10, #'c'
    b.ne .Lpi4_gic_scan_skip_name_match
    ldrb w10, [x5, #11]
    cmp w10, #'o'
    b.ne .Lpi4_gic_scan_skip_name_match
    ldrb w10, [x5, #12]
    cmp w10, #'n'
    b.ne .Lpi4_gic_scan_skip_name_match
    ldrb w10, [x5, #13]
    cmp w10, #'t'
    b.ne .Lpi4_gic_scan_skip_name_match
    ldrb w10, [x5, #14]
    cmp w10, #'r'
    b.ne .Lpi4_gic_scan_skip_name_match
    ldrb w10, [x5, #15]
    cmp w10, #'o'
    b.ne .Lpi4_gic_scan_skip_name_match
    ldrb w10, [x5, #16]
    cmp w10, #'l'
    b.ne .Lpi4_gic_scan_skip_name_match
    ldrb w10, [x5, #17]
    cmp w10, #'l'
    b.ne .Lpi4_gic_scan_skip_name_match
    ldrb w10, [x5, #18]
    cmp w10, #'e'
    b.ne .Lpi4_gic_scan_skip_name_match
    ldrb w10, [x5, #19]
    cmp w10, #'r'
    b.ne .Lpi4_gic_scan_skip_name_match

    add w7, w6, #1
    adr x10, pi4_status_pi4gic_node
    str x9, [x10]
    adr x10, pi4_status_pi4gic_depth
    uxtw x11, w7
    str x11, [x10]
    adr x10, pi4_status_pi4gic_interrupt
    str xzr, [x10]
    adr x10, pi4_status_pi4giccompat_ptr
    str xzr, [x10]
    adr x10, pi4_status_pi4giccompat_len
    str xzr, [x10]
    adr x10, pi4_status_pi4giccompat_hash
    str xzr, [x10]
    adr x10, pi4_status_pi4gicreg0
    str xzr, [x10]
    adr x10, pi4_status_pi4gicreg1
    str xzr, [x10]
    adr x10, pi4_status_pi4gicreg2
    str xzr, [x10]
    adr x10, pi4_status_pi4gicreg3
    str xzr, [x10]
    adr x10, pi4_status_pi4gicreg4
    str xzr, [x10]
    adr x10, pi4_status_pi4gicreg5
    str xzr, [x10]
    adr x10, pi4_status_pi4gicreg6
    str xzr, [x10]
    adr x10, pi4_status_pi4gicreg7
    str xzr, [x10]
    adr x10, pi4_status_pi4gicreg_len
    str xzr, [x10]

.Lpi4_gic_scan_skip_name_match:
    mov x10, x5
.Lpi4_gic_scan_name_loop:
    cmp x10, x2
    b.hs .Lpi4_gic_scan_done
    ldrb w11, [x10], #1
    cbnz w11, .Lpi4_gic_scan_name_loop
    add x5, x10, #3
    bic x5, x5, #3
    cmp x5, x2
    b.hi .Lpi4_gic_scan_done
    add w6, w6, #1
    b .Lpi4_gic_scan_loop

.Lpi4_gic_scan_end_node:
    cbz w6, .Lpi4_gic_scan_done
    cmp w6, w7
    b.ne .Lpi4_gic_scan_not_leaving_gic
    adr x10, pi4_status_pi4gicdtb
    ldr w11, [x10]
    ldr w12, =VIBE_PI4_STATUS_PI4GICDTB_OK
    cmp w11, w12
    b.eq .Lpi4_gic_scan_done
    mov w7, wzr
    adr x10, pi4_status_pi4gic_node
    str xzr, [x10]
    adr x10, pi4_status_pi4gic_depth
    str xzr, [x10]
    adr x10, pi4_status_pi4gic_interrupt
    str xzr, [x10]
    adr x10, pi4_status_pi4giccompat_ptr
    str xzr, [x10]
    adr x10, pi4_status_pi4giccompat_len
    str xzr, [x10]
    adr x10, pi4_status_pi4giccompat_hash
    str xzr, [x10]
    adr x10, pi4_status_pi4gicreg0
    str xzr, [x10]
    adr x10, pi4_status_pi4gicreg1
    str xzr, [x10]
    adr x10, pi4_status_pi4gicreg2
    str xzr, [x10]
    adr x10, pi4_status_pi4gicreg3
    str xzr, [x10]
    adr x10, pi4_status_pi4gicreg4
    str xzr, [x10]
    adr x10, pi4_status_pi4gicreg5
    str xzr, [x10]
    adr x10, pi4_status_pi4gicreg6
    str xzr, [x10]
    adr x10, pi4_status_pi4gicreg7
    str xzr, [x10]
    adr x10, pi4_status_pi4gicreg_len
    str xzr, [x10]
.Lpi4_gic_scan_not_leaving_gic:
    subs w6, w6, #1
    b.eq .Lpi4_gic_scan_done
    b .Lpi4_gic_scan_loop

.Lpi4_gic_scan_prop:
    add x9, x5, #8
    cmp x9, x2
    b.hi .Lpi4_gic_scan_done
    ldr w9, [x5]
    rev w9, w9
    ldr w10, [x5, #4]
    rev w10, w10
    add x11, x5, #8
    uxtw x12, w9
    add x12, x12, #3
    bic x12, x12, #3
    add x13, x11, x12
    cmp x13, x2
    b.hi .Lpi4_gic_scan_done

    cbz w7, .Lpi4_gic_scan_skip_prop
    cmp w6, w7
    b.ne .Lpi4_gic_scan_skip_prop
    uxtw x12, w10
    add x14, x3, x12
    cmp x14, x4
    b.hs .Lpi4_gic_scan_skip_prop

    add x15, x14, #21
    cmp x15, x4
    b.hi .Lpi4_gic_scan_check_compatible
    ldrb w15, [x14]
    cmp w15, #'i'
    b.ne .Lpi4_gic_scan_check_compatible
    ldrb w15, [x14, #1]
    cmp w15, #'n'
    b.ne .Lpi4_gic_scan_check_compatible
    ldrb w15, [x14, #2]
    cmp w15, #'t'
    b.ne .Lpi4_gic_scan_check_compatible
    ldrb w15, [x14, #3]
    cmp w15, #'e'
    b.ne .Lpi4_gic_scan_check_compatible
    ldrb w15, [x14, #4]
    cmp w15, #'r'
    b.ne .Lpi4_gic_scan_check_compatible
    ldrb w15, [x14, #5]
    cmp w15, #'r'
    b.ne .Lpi4_gic_scan_check_compatible
    ldrb w15, [x14, #6]
    cmp w15, #'u'
    b.ne .Lpi4_gic_scan_check_compatible
    ldrb w15, [x14, #7]
    cmp w15, #'p'
    b.ne .Lpi4_gic_scan_check_compatible
    ldrb w15, [x14, #8]
    cmp w15, #'t'
    b.ne .Lpi4_gic_scan_check_compatible
    ldrb w15, [x14, #9]
    cmp w15, #'-'
    b.ne .Lpi4_gic_scan_check_compatible
    ldrb w15, [x14, #10]
    cmp w15, #'c'
    b.ne .Lpi4_gic_scan_check_compatible
    ldrb w15, [x14, #11]
    cmp w15, #'o'
    b.ne .Lpi4_gic_scan_check_compatible
    ldrb w15, [x14, #12]
    cmp w15, #'n'
    b.ne .Lpi4_gic_scan_check_compatible
    ldrb w15, [x14, #13]
    cmp w15, #'t'
    b.ne .Lpi4_gic_scan_check_compatible
    ldrb w15, [x14, #14]
    cmp w15, #'r'
    b.ne .Lpi4_gic_scan_check_compatible
    ldrb w15, [x14, #15]
    cmp w15, #'o'
    b.ne .Lpi4_gic_scan_check_compatible
    ldrb w15, [x14, #16]
    cmp w15, #'l'
    b.ne .Lpi4_gic_scan_check_compatible
    ldrb w15, [x14, #17]
    cmp w15, #'l'
    b.ne .Lpi4_gic_scan_check_compatible
    ldrb w15, [x14, #18]
    cmp w15, #'e'
    b.ne .Lpi4_gic_scan_check_compatible
    ldrb w15, [x14, #19]
    cmp w15, #'r'
    b.ne .Lpi4_gic_scan_check_compatible
    ldrb w15, [x14, #20]
    cbnz w15, .Lpi4_gic_scan_check_compatible
    cbnz w9, .Lpi4_gic_scan_skip_prop
    adr x15, pi4_status_pi4gic_interrupt
    mov x16, #1
    str x16, [x15]
    adr x15, pi4_status_pi4gicreg_len
    ldr x16, [x15]
    cbz x16, .Lpi4_gic_scan_skip_prop
    adr x15, pi4_status_pi4gicdtb
    ldr w16, =VIBE_PI4_STATUS_PI4GICDTB_OK
    str w16, [x15]
    b .Lpi4_gic_scan_skip_prop

.Lpi4_gic_scan_check_compatible:
    add x15, x14, #11
    cmp x15, x4
    b.hi .Lpi4_gic_scan_check_reg
    ldrb w15, [x14]
    cmp w15, #'c'
    b.ne .Lpi4_gic_scan_check_reg
    ldrb w15, [x14, #1]
    cmp w15, #'o'
    b.ne .Lpi4_gic_scan_check_reg
    ldrb w15, [x14, #2]
    cmp w15, #'m'
    b.ne .Lpi4_gic_scan_check_reg
    ldrb w15, [x14, #3]
    cmp w15, #'p'
    b.ne .Lpi4_gic_scan_check_reg
    ldrb w15, [x14, #4]
    cmp w15, #'a'
    b.ne .Lpi4_gic_scan_check_reg
    ldrb w15, [x14, #5]
    cmp w15, #'t'
    b.ne .Lpi4_gic_scan_check_reg
    ldrb w15, [x14, #6]
    cmp w15, #'i'
    b.ne .Lpi4_gic_scan_check_reg
    ldrb w15, [x14, #7]
    cmp w15, #'b'
    b.ne .Lpi4_gic_scan_check_reg
    ldrb w15, [x14, #8]
    cmp w15, #'l'
    b.ne .Lpi4_gic_scan_check_reg
    ldrb w15, [x14, #9]
    cmp w15, #'e'
    b.ne .Lpi4_gic_scan_check_reg
    ldrb w15, [x14, #10]
    cbnz w15, .Lpi4_gic_scan_check_reg

    adr x15, pi4_status_pi4giccompat_len
    ldr x16, [x15]
    cbnz x16, .Lpi4_gic_scan_skip_prop
    mov x0, #5381
    mov x15, x11
    uxtw x16, w9
    cbz x16, .Lpi4_gic_scan_hash_done
.Lpi4_gic_scan_hash_loop:
    ldrb w17, [x15], #1
    lsl x12, x0, #5
    sub x0, x12, x0
    add x0, x0, x17
    subs x16, x16, #1
    b.ne .Lpi4_gic_scan_hash_loop
.Lpi4_gic_scan_hash_done:
    adr x15, pi4_status_pi4giccompat_ptr
    str x11, [x15]
    adr x15, pi4_status_pi4giccompat_len
    uxtw x16, w9
    str x16, [x15]
    adr x15, pi4_status_pi4giccompat_hash
    str x0, [x15]
    b .Lpi4_gic_scan_skip_prop

.Lpi4_gic_scan_check_reg:
    add x15, x14, #4
    cmp x15, x4
    b.hi .Lpi4_gic_scan_skip_prop
    ldrb w15, [x14]
    cmp w15, #'r'
    b.ne .Lpi4_gic_scan_skip_prop
    ldrb w15, [x14, #1]
    cmp w15, #'e'
    b.ne .Lpi4_gic_scan_skip_prop
    ldrb w15, [x14, #2]
    cmp w15, #'g'
    b.ne .Lpi4_gic_scan_skip_prop
    ldrb w15, [x14, #3]
    cbnz w15, .Lpi4_gic_scan_skip_prop
    cmp w9, #4
    b.lo .Lpi4_gic_scan_skip_prop
    tst w9, #0x3
    b.ne .Lpi4_gic_scan_skip_prop

    adr x15, pi4_status_pi4gicreg0
    mov x16, #8
.Lpi4_gic_scan_clear_reg_loop:
    str xzr, [x15], #8
    subs x16, x16, #1
    b.ne .Lpi4_gic_scan_clear_reg_loop

    lsr w14, w9, #2
    cmp w14, #8
    b.ls .Lpi4_gic_scan_reg_count_ok
    mov w14, #8
.Lpi4_gic_scan_reg_count_ok:
    adr x15, pi4_status_pi4gicreg0
    mov x12, x11
.Lpi4_gic_scan_store_reg_loop:
    ldr w16, [x12], #4
    rev w16, w16
    uxtw x16, w16
    str x16, [x15], #8
    subs w14, w14, #1
    b.ne .Lpi4_gic_scan_store_reg_loop

    adr x15, pi4_status_pi4gicreg_len
    uxtw x16, w9
    str x16, [x15]
    adr x15, pi4_status_pi4gic_interrupt
    ldr x16, [x15]
    cbz x16, .Lpi4_gic_scan_skip_prop
    adr x15, pi4_status_pi4gicdtb
    ldr w16, =VIBE_PI4_STATUS_PI4GICDTB_OK
    str w16, [x15]

.Lpi4_gic_scan_skip_prop:
    mov x5, x13
    b .Lpi4_gic_scan_loop

.Lpi4_gic_scan_done:
    ret
.size pi4_scan_gic_dtb, . - pi4_scan_gic_dtb

.type pi4_prepare_gic_mmio, %function
pi4_prepare_gic_mmio:
    adr x0, pi4_status_pi4gicdtb
    ldr w0, [x0]
    ldr w1, =VIBE_PI4_STATUS_PI4GICDTB_OK
    cmp w0, w1
    b.ne .Lpi4_gic_mmio_fallback

    adr x0, pi4_status_pi4gicreg_len
    ldr x1, [x0]
    cmp x1, #16
    b.lo .Lpi4_gic_mmio_fallback

    adr x0, pi4_status_pi4gicreg0
    ldr x2, [x0]
    adr x0, pi4_status_pi4gicreg1
    ldr x3, [x0]
    adr x0, pi4_status_pi4gicreg2
    ldr x4, [x0]
    adr x0, pi4_status_pi4gicreg3
    ldr x5, [x0]

    cbz x2, .Lpi4_gic_mmio_try_64
    cbz x3, .Lpi4_gic_mmio_try_64
    cbz x4, .Lpi4_gic_mmio_try_64
    cbz x5, .Lpi4_gic_mmio_try_64

    mov x6, x4
    mov x4, x3
    mov x3, x6
    b .Lpi4_gic_mmio_store

.Lpi4_gic_mmio_try_64:
    cmp x1, #32
    b.lo .Lpi4_gic_mmio_fallback

    adr x0, pi4_status_pi4gicreg4
    ldr x6, [x0]
    adr x0, pi4_status_pi4gicreg5
    ldr x7, [x0]
    adr x0, pi4_status_pi4gicreg6
    ldr x8, [x0]
    adr x0, pi4_status_pi4gicreg7
    ldr x9, [x0]

    lsl x2, x2, #32
    orr x2, x2, x3
    lsl x4, x4, #32
    orr x4, x4, x5
    lsl x6, x6, #32
    orr x6, x6, x7
    lsl x8, x8, #32
    orr x8, x8, x9

    cbz x2, .Lpi4_gic_mmio_fallback
    cbz x4, .Lpi4_gic_mmio_fallback
    cbz x6, .Lpi4_gic_mmio_fallback
    cbz x8, .Lpi4_gic_mmio_fallback

    mov x3, x6
    mov x5, x8
    b .Lpi4_gic_mmio_store

.Lpi4_gic_mmio_fallback:
    ldr x2, =PI4_GIC_DIST_FALLBACK_BASE
    ldr x3, =PI4_GIC_CPU_FALLBACK_BASE
    mov x4, #PI4_GIC_DIST_FALLBACK_LEN
    mov x5, #PI4_GIC_CPU_FALLBACK_LEN

.Lpi4_gic_mmio_store:
    adr x0, pi4_status_pi4gic_dist_base
    str x2, [x0]
    adr x0, pi4_status_pi4gic_cpu_base
    str x3, [x0]
    adr x0, pi4_status_pi4gic_dist_len
    str x4, [x0]
    adr x0, pi4_status_pi4gic_cpu_len
    str x5, [x0]
    adr x0, pi4_status_pi4gicmmio
    ldr w1, =VIBE_PI4_STATUS_PI4GICMMIO_OK
    str w1, [x0]

.Lpi4_gic_mmio_done:
    ret
.size pi4_prepare_gic_mmio, . - pi4_prepare_gic_mmio

.type pi4_configure_gic, %function
pi4_configure_gic:
    adr x0, pi4_status_pi4gicmmio
    ldr w0, [x0]
    ldr w1, =VIBE_PI4_STATUS_PI4GICMMIO_OK
    cmp w0, w1
    b.ne .Lpi4_gic_cfg_done

    adr x0, pi4_status_pi4gic_dist_base
    ldr x2, [x0]
    adr x0, pi4_status_pi4gic_cpu_base
    ldr x3, [x0]
    adr x0, pi4_status_pi4gic_dist_len
    ldr x4, [x0]
    adr x0, pi4_status_pi4gic_cpu_len
    ldr x5, [x0]

    cbz x2, .Lpi4_gic_cfg_done
    cbz x3, .Lpi4_gic_cfg_done
    cmp x4, #0x0c
    b.lo .Lpi4_gic_cfg_done
    cmp x5, #0x100
    b.lo .Lpi4_gic_cfg_done

    ldr w6, [x2, #PI4_GICD_TYPER]
    ldr w7, [x2, #PI4_GICD_IIDR]
    ldr w8, [x3, #PI4_GICC_IIDR]

    mov w9, #0xff
    str w9, [x3, #PI4_GICC_PMR]
    str wzr, [x3, #PI4_GICC_BPR]
    mov w9, #1
    str w9, [x3, #PI4_GICC_CTLR]
    str w9, [x2, #PI4_GICD_CTLR]
    dsb sy
    isb

    ldr w9, [x2, #PI4_GICD_CTLR]
    ldr w10, [x3, #PI4_GICC_CTLR]
    ldr w11, [x3, #PI4_GICC_PMR]
    ldr w12, [x3, #PI4_GICC_BPR]

    adr x0, pi4_status_pi4gic_dist_ctlr
    uxtw x13, w9
    str x13, [x0]
    adr x0, pi4_status_pi4gic_cpu_ctlr
    uxtw x13, w10
    str x13, [x0]
    adr x0, pi4_status_pi4gic_cpu_pmr
    uxtw x13, w11
    str x13, [x0]
    adr x0, pi4_status_pi4gic_cpu_bpr
    uxtw x13, w12
    str x13, [x0]
    adr x0, pi4_status_pi4gic_dist_typer
    uxtw x13, w6
    str x13, [x0]
    adr x0, pi4_status_pi4gic_dist_iidr
    uxtw x13, w7
    str x13, [x0]
    adr x0, pi4_status_pi4gic_cpu_iidr
    uxtw x13, w8
    str x13, [x0]

    adr x0, pi4_status_pi4giccfg
    ldr w13, =VIBE_PI4_STATUS_PI4GICCFG_OK
    str w13, [x0]

.Lpi4_gic_cfg_done:
    ret
.size pi4_configure_gic, . - pi4_configure_gic

.type pi4_run_timer_irq_probe, %function
pi4_run_timer_irq_probe:
    adr x0, pi4_status_pi4giccfg
    ldr w0, [x0]
    ldr w1, =VIBE_PI4_STATUS_PI4GICCFG_OK
    cmp w0, w1
    b.ne .Lpi4_timer_probe_done

    adr x0, pi4_status_pi4gic_dist_base
    ldr x2, [x0]
    adr x0, pi4_status_pi4gic_cpu_base
    ldr x3, [x0]
    adr x0, pi4_status_pi4gic_dist_len
    ldr x4, [x0]
    adr x0, pi4_status_pi4gic_cpu_len
    ldr x5, [x0]
    cbz x2, .Lpi4_timer_probe_done
    cbz x3, .Lpi4_timer_probe_done
    cmp x4, #0x420
    b.lo .Lpi4_timer_probe_done
    cmp x5, #0x14
    b.lo .Lpi4_timer_probe_done

    mrs x6, CNTFRQ_EL0
    cbz x6, .Lpi4_timer_probe_done
    mov x7, #PI4_TIMER_TICK_DIV
    udiv x8, x6, x7
    cbnz x8, .Lpi4_timer_tick_nonzero
    mov x8, #1
.Lpi4_timer_tick_nonzero:
    adr x0, pi4_status_timer_freq
    str x6, [x0]
    adr x0, pi4_status_timer_tick
    str x8, [x0]
    adr x0, pi4_status_timer_irq_id
    mov x9, #PI4_TIMER_PPI_ID
    str x9, [x0]
    adr x0, pi4_status_pi4timer
    ldr w9, =VIBE_PI4_STATUS_PI4TIMER_ARMED
    str w9, [x0]
    adr x0, pi4_status_timer_gate
    ldr w9, =VIBE_PI4_GATE_TIMER_ARMED
    str w9, [x0]

    add x9, x2, #PI4_GICD_IPRIORITYR
    mov w10, #0x80
    strb w10, [x9, #PI4_TIMER_PPI_ID]
    add x9, x2, #PI4_GICD_ISENABLER0
    mov w10, #1
    lsl w10, w10, #PI4_TIMER_PPI_ID
    str w10, [x9]
    dsb sy
    isb

    msr CNTP_CTL_EL0, xzr
    isb
    msr CNTP_TVAL_EL0, x8
    mov x9, #1
    msr CNTP_CTL_EL0, x9
    isb
    msr daifclr, #2

    ldr x9, =0x400000
.Lpi4_timer_wait_loop:
    wfe
    adr x0, pi4_status_timer_ticks
    ldr x10, [x0]
    cbnz x10, .Lpi4_timer_probe_ok
    subs x9, x9, #1
    b.ne .Lpi4_timer_wait_loop

    msr daifset, #2
    msr CNTP_CTL_EL0, xzr
    isb
    b .Lpi4_timer_probe_done

.Lpi4_timer_probe_ok:
    msr daifset, #2
    msr CNTP_CTL_EL0, xzr
    isb
    ldr w9, [x2, #PI4_GICD_CTLR]
    ldr w10, [x3, #PI4_GICC_CTLR]
    adr x0, pi4_status_irq_gic_dist_ctlr
    uxtw x11, w9
    str x11, [x0]
    adr x0, pi4_status_irq_gic_cpu_ctlr
    uxtw x11, w10
    str x11, [x0]
    adr x0, pi4_status_pi4irq
    ldr w11, =VIBE_PI4_STATUS_PI4IRQ_OK
    str w11, [x0]
    adr x0, pi4_status_pi4timer
    ldr w11, =VIBE_PI4_STATUS_PI4TIMER_OK
    str w11, [x0]
    adr x0, pi4_status_timer_gate
    ldr w11, =VIBE_PI4_GATE_TIMER_IRQ_OK
    str w11, [x0]

.Lpi4_timer_probe_done:
    ret
.size pi4_run_timer_irq_probe, . - pi4_run_timer_irq_probe

.type pi4_mailbox_call, %function
pi4_mailbox_call:
    adr x1, pi4_status_mbox_req
    str x0, [x1]
    adr x1, pi4_status_mbox_resp
    str xzr, [x1]
    adr x1, pi4_status_mbox_read
    str xzr, [x1]
    adr x1, pi4_status_mbox_fail
    str xzr, [x1]

    and x1, x0, #0xf
    cbz x1, .Lpi4_mailbox_aligned
    mov x10, #1
    b .Lpi4_mailbox_fail
.Lpi4_mailbox_aligned:
    lsr x1, x0, #32
    cbz x1, .Lpi4_mailbox_low_addr
    mov x10, #2
    b .Lpi4_mailbox_fail
.Lpi4_mailbox_low_addr:
    orr x3, x0, #PI4_MAILBOX_PROPERTY_CHANNEL
    adr x1, pi4_status_mbox_write
    str x3, [x1]

    ldr x4, =PI4_MAILBOX_STATUS
    ldr x5, =PI4_MAILBOX_WRITE
    ldr x6, =PI4_MAILBOX_READ
    ldr x7, =PI4_MAILBOX_POLL_LIMIT
.Lpi4_mailbox_wait_write:
    ldr w8, [x4]
    adr x1, pi4_status_mbox_status
    uxtw x9, w8
    str x9, [x1]
    tbz w8, #PI4_MAILBOX_STATUS_FULL, .Lpi4_mailbox_write_ready
    subs x7, x7, #1
    b.ne .Lpi4_mailbox_wait_write
    mov x10, #3
    b .Lpi4_mailbox_fail

.Lpi4_mailbox_write_ready:
    dsb sy
    str w3, [x5]
    dsb sy

    ldr x7, =PI4_MAILBOX_POLL_LIMIT
.Lpi4_mailbox_wait_read:
    ldr w8, [x4]
    adr x1, pi4_status_mbox_status
    uxtw x9, w8
    str x9, [x1]
    tbnz w8, #PI4_MAILBOX_STATUS_EMPTY, .Lpi4_mailbox_read_empty
    ldr w9, [x6]
    adr x1, pi4_status_mbox_read
    uxtw x10, w9
    str x10, [x1]
    and w10, w9, #0xf
    cmp w10, #PI4_MAILBOX_PROPERTY_CHANNEL
    b.ne .Lpi4_mailbox_read_empty
    bic w10, w9, #0xf
    cmp w10, w0
    b.ne .Lpi4_mailbox_read_empty
    ldr w11, [x0, #4]
    adr x1, pi4_status_mbox_resp
    uxtw x12, w11
    str x12, [x1]
    ldr w12, =PI4_MAILBOX_RESPONSE_SUCCESS
    cmp w11, w12
    b.eq .Lpi4_mailbox_ok
    mov x10, #5
    b .Lpi4_mailbox_fail

.Lpi4_mailbox_read_empty:
    subs x7, x7, #1
    b.ne .Lpi4_mailbox_wait_read
    mov x10, #4
    b .Lpi4_mailbox_fail

.Lpi4_mailbox_ok:
    dsb sy
    mov x0, #1
    ret

.Lpi4_mailbox_fail:
    adr x1, pi4_status_mbox_fail
    str x10, [x1]
    mov x0, xzr
    ret
.size pi4_mailbox_call, . - pi4_mailbox_call

.type pi4_probe_audio_status, %function
pi4_probe_audio_status:
    stp x29, x30, [sp, #-80]!
    mov x29, sp

    bl pi4_record_audio_mmio_probe
    bl pi4_audio_init_status

    adr x0, pi4_status_mbox_req
    ldr x1, [x0]
    str x1, [sp, #16]
    adr x0, pi4_status_mbox_write
    ldr x1, [x0]
    str x1, [sp, #24]
    adr x0, pi4_status_mbox_read
    ldr x1, [x0]
    str x1, [sp, #32]
    adr x0, pi4_status_mbox_resp
    ldr x1, [x0]
    str x1, [sp, #40]
    adr x0, pi4_status_mbox_status
    ldr x1, [x0]
    str x1, [sp, #48]
    adr x0, pi4_status_mbox_fail
    ldr x1, [x0]
    str x1, [sp, #56]

    bl pi4_prepare_audio_mailbox_msg
    adr x0, pi4_audio_mailbox_msg
    bl pi4_mailbox_call
    cbz x0, .Lpi4_audio_probe_restore
    bl pi4_record_audio_mailbox_probe
    bl pi4_audio_try_promote_hardware_backend

.Lpi4_audio_probe_restore:
    adr x0, pi4_status_mbox_req
    ldr x1, [sp, #16]
    str x1, [x0]
    adr x0, pi4_status_mbox_write
    ldr x1, [sp, #24]
    str x1, [x0]
    adr x0, pi4_status_mbox_read
    ldr x1, [sp, #32]
    str x1, [x0]
    adr x0, pi4_status_mbox_resp
    ldr x1, [sp, #40]
    str x1, [x0]
    adr x0, pi4_status_mbox_status
    ldr x1, [sp, #48]
    str x1, [x0]
    adr x0, pi4_status_mbox_fail
    ldr x1, [sp, #56]
    str x1, [x0]

    ldp x29, x30, [sp], #80
    ret
.size pi4_probe_audio_status, . - pi4_probe_audio_status

.type pi4_audio_init_status, %function
pi4_audio_init_status:
    adr x0, pi4_audio_status_queue_bytes
    mov x1, #PI4_VIBE_AUDIO_QUEUE_BYTES
    str x1, [x0]
    adr x0, pi4_audio_status_queue_usable
    mov x1, #PI4_VIBE_AUDIO_QUEUE_BYTES
    str x1, [x0]
    adr x0, pi4_audio_status_queue_streams
    str xzr, [x0]
    adr x0, pi4_audio_status_queue_underruns
    str xzr, [x0]
    adr x0, pi4_audio_status_abi_required
    mov x1, #PI4_VIBE_AUDIO_ABI_FULL_MASK
    str x1, [x0]
    adr x0, pi4_audio_status_abi_version
    mov x1, #PI4_VIBE_USER_ABI_VERSION
    str x1, [x0]
    adr x0, pi4_audio_status_abi_backend_ready
    str xzr, [x0]
    ret
.size pi4_audio_init_status, . - pi4_audio_init_status

.type pi4_audio_backend_ready, %function
pi4_audio_backend_ready:
    adr x0, pi4_audio_status_abi_backend_ready
    ldr x0, [x0]
    cbz x0, .Lpi4_audio_backend_not_ready
    adr x0, pi4_audio_status_usb_ready
    ldr x0, [x0]
    cbz x0, .Lpi4_audio_backend_check_pwm
    adr x0, pi4_audio_status_caps
    ldr x0, [x0]
    mov x1, #PI4_VIBE_AUDIO_USB_FULL_MASK
    and x0, x0, x1
    cmp x0, x1
    b.eq .Lpi4_audio_backend_ready

.Lpi4_audio_backend_check_pwm:
    adr x0, pi4_audio_status_mmio_ready
    ldr x0, [x0]
    cbz x0, .Lpi4_audio_backend_not_ready
    adr x0, pi4_audio_status_mailbox_success
    ldr x0, [x0]
    cbz x0, .Lpi4_audio_backend_not_ready
    adr x0, pi4_audio_status_caps
    ldr x0, [x0]
    mov x1, #PI4_VIBE_AUDIO_CAP_FULL_MASK
    and x0, x0, x1
    cmp x0, x1
    b.ne .Lpi4_audio_backend_not_ready
.Lpi4_audio_backend_ready:
    mov x0, #1
    ret
.Lpi4_audio_backend_not_ready:
    mov x0, xzr
    ret
.size pi4_audio_backend_ready, . - pi4_audio_backend_ready

.type pi4_audio_status_can_claim_ok, %function
pi4_audio_status_can_claim_ok:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    bl pi4_audio_backend_ready
    cbz x0, .Lpi4_audio_status_cannot_claim_ok
    adr x0, pi4_audio_status_abi_observed
    ldr x0, [x0]
    mov x1, #PI4_VIBE_AUDIO_ABI_FULL_MASK
    and x0, x0, x1
    cmp x0, x1
    b.ne .Lpi4_audio_status_cannot_claim_ok
    adr x0, pi4_audio_status_playback_start_count
    ldr x0, [x0]
    cbz x0, .Lpi4_audio_status_cannot_claim_ok
    adr x0, pi4_audio_pcm_mixed_bytes
    ldr x0, [x0]
    cbz x0, .Lpi4_audio_status_cannot_claim_ok
    mov x0, #1
    b .Lpi4_audio_status_claim_ok_done
.Lpi4_audio_status_cannot_claim_ok:
    mov x0, xzr
.Lpi4_audio_status_claim_ok_done:
    ldp x29, x30, [sp], #16
    ret
.size pi4_audio_status_can_claim_ok, . - pi4_audio_status_can_claim_ok

.type pi4_audio_try_promote_hardware_backend, %function
pi4_audio_try_promote_hardware_backend:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    ldr x16, =pi4_usb_audio_snapshot
    blr x16
    cbz x0, .Lpi4_audio_promote_done

    adr x8, pi4_audio_status_usb_ready
    str x0, [x8]
    adr x8, pi4_audio_status_usb_addr
    str x1, [x8]
    adr x8, pi4_audio_status_usb_interface
    str x2, [x8]
    adr x8, pi4_audio_status_usb_endpoint
    str x3, [x8]
    adr x8, pi4_audio_status_usb_mps
    str x4, [x8]
    adr x8, pi4_audio_status_usb_packets
    str x5, [x8]
    adr x8, pi4_audio_status_usb_bytes
    str x6, [x8]
    adr x8, pi4_audio_status_usb_last_hcint
    str x7, [x8]

    adr x8, pi4_audio_status_caps
    ldr x9, [x8]
    orr x9, x9, #PI4_VIBE_AUDIO_CAP_USB_AUDIO
    orr x9, x9, #PI4_VIBE_AUDIO_CAP_PCM_QUEUE
    str x9, [x8]
    adr x8, pi4_audio_status_abi_backend_ready
    mov x9, #1
    str x9, [x8]

.Lpi4_audio_promote_done:
    ldp x29, x30, [sp], #16
    ret
.size pi4_audio_try_promote_hardware_backend, . - pi4_audio_try_promote_hardware_backend

.type pi4_audio_record_abi_command, %function
pi4_audio_record_abi_command:
    adr x2, pi4_audio_status_call_count
    ldr x3, [x2]
    add x3, x3, #1
    str x3, [x2]
    adr x2, pi4_audio_status_last_command
    str x0, [x2]
    adr x2, pi4_audio_status_abi_required
    mov x3, #PI4_VIBE_AUDIO_ABI_FULL_MASK
    str x3, [x2]
    adr x2, pi4_audio_status_abi_version
    mov x3, #PI4_VIBE_USER_ABI_VERSION
    str x3, [x2]

    mov x1, xzr
    cmp x0, #PI4_VIBE_AUDIO_DEVICE_START
    b.eq .Lpi4_audio_record_device
    cmp x0, #PI4_VIBE_AUDIO_DEVICE_SHUTDOWN
    b.eq .Lpi4_audio_record_device
    cmp x0, #PI4_VIBE_AUDIO_DEVICE_INFO
    b.eq .Lpi4_audio_record_device_cap
    cmp x0, #PI4_VIBE_AUDIO_PCM_RING_INFO
    b.eq .Lpi4_audio_record_queue_cap
    cmp x0, #PI4_VIBE_AUDIO_STREAM_INFO
    b.eq .Lpi4_audio_record_queue_cap
    cmp x0, #PI4_VIBE_AUDIO_PCM_BUFFERED_BYTES
    b.eq .Lpi4_audio_record_queue
    cmp x0, #PI4_VIBE_AUDIO_PCM_PULL_STATE
    b.eq .Lpi4_audio_record_queue
    cmp x0, #PI4_VIBE_AUDIO_PCM_OPEN
    b.eq .Lpi4_audio_record_queue
    cmp x0, #PI4_VIBE_AUDIO_PCM_WRITE
    b.eq .Lpi4_audio_record_queue
    cmp x0, #PI4_VIBE_AUDIO_PCM_WRITE_DESC
    b.eq .Lpi4_audio_record_queue
    cmp x0, #PI4_VIBE_AUDIO_PCM_DRAIN
    b.eq .Lpi4_audio_record_queue
    cmp x0, #PI4_VIBE_AUDIO_PCM_CLOSE
    b.eq .Lpi4_audio_record_queue
    b .Lpi4_audio_record_done

.Lpi4_audio_record_device:
    mov x1, #PI4_VIBE_AUDIO_ABI_DEVICE_STATUS
    b .Lpi4_audio_record_update
.Lpi4_audio_record_device_cap:
    mov x1, #(PI4_VIBE_AUDIO_ABI_DEVICE_STATUS | PI4_VIBE_AUDIO_ABI_CAP_STATUS)
    b .Lpi4_audio_record_update
.Lpi4_audio_record_queue_cap:
    mov x1, #(PI4_VIBE_AUDIO_ABI_QUEUE_STATUS | PI4_VIBE_AUDIO_ABI_CAP_STATUS)
    b .Lpi4_audio_record_update
.Lpi4_audio_record_queue:
    mov x1, #PI4_VIBE_AUDIO_ABI_QUEUE_STATUS

.Lpi4_audio_record_update:
    adr x2, pi4_audio_status_abi_observed
    ldr x3, [x2]
    orr x3, x3, x1
    str x3, [x2]
    adr x2, pi4_audio_status_abi_last_op
    str x1, [x2]

.Lpi4_audio_record_done:
    ret
.size pi4_audio_record_abi_command, . - pi4_audio_record_abi_command

.type pi4_audio_syscall_dispatch, %function
pi4_audio_syscall_dispatch:
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    str x25, [sp, #64]

    mov x19, x0
    mov x20, x1
    mov x21, x2
    bl pi4_audio_record_abi_command
    bl pi4_audio_try_promote_hardware_backend

    cmp x19, #PI4_VIBE_AUDIO_DEVICE_START
    b.eq .Lpi4_audio_cmd_device_start
    cmp x19, #PI4_VIBE_AUDIO_DEVICE_SHUTDOWN
    b.eq .Lpi4_audio_cmd_device_shutdown
    cmp x19, #PI4_VIBE_AUDIO_MIXER_START
    b.eq .Lpi4_audio_cmd_enosys
    cmp x19, #PI4_VIBE_AUDIO_MIXER_UPDATE
    b.eq .Lpi4_audio_cmd_enosys
    cmp x19, #PI4_VIBE_AUDIO_MIXER_STOP
    b.eq .Lpi4_audio_cmd_zero
    cmp x19, #PI4_VIBE_AUDIO_MIXER_IS_PLAYING
    b.eq .Lpi4_audio_cmd_zero
    cmp x19, #PI4_VIBE_AUDIO_PCM_BUFFERED_BYTES
    b.eq .Lpi4_audio_cmd_buffered_bytes
    cmp x19, #PI4_VIBE_AUDIO_PCM_PULL_STATE
    b.eq .Lpi4_audio_cmd_pull_state
    cmp x19, #PI4_VIBE_AUDIO_DEVICE_INFO
    b.eq .Lpi4_audio_cmd_device_info
    cmp x19, #PI4_VIBE_AUDIO_PCM_RING_INFO
    b.eq .Lpi4_audio_cmd_ring_info
    cmp x19, #PI4_VIBE_AUDIO_STREAM_INFO
    b.eq .Lpi4_audio_cmd_stream_info
    cmp x19, #PI4_VIBE_AUDIO_PCM_OPEN
    b.eq .Lpi4_audio_cmd_pcm_open
    cmp x19, #PI4_VIBE_AUDIO_PCM_WRITE
    b.eq .Lpi4_audio_cmd_pcm_write
    cmp x19, #PI4_VIBE_AUDIO_PCM_WRITE_DESC
    b.eq .Lpi4_audio_cmd_pcm_write
    cmp x19, #PI4_VIBE_AUDIO_PCM_DRAIN
    b.eq .Lpi4_audio_cmd_pcm_drain
    cmp x19, #PI4_VIBE_AUDIO_PCM_CLOSE
    b.eq .Lpi4_audio_cmd_pcm_close
    b .Lpi4_audio_cmd_inval

.Lpi4_audio_cmd_device_start:
    bl pi4_audio_backend_ready
    cbz x0, .Lpi4_audio_cmd_unavailable
    adr x2, pi4_audio_status_playback_start_count
    ldr x3, [x2]
    add x3, x3, #1
    str x3, [x2]
    b .Lpi4_audio_cmd_zero

.Lpi4_audio_cmd_device_shutdown:
    bl pi4_audio_pcm_reset_queue
    b .Lpi4_audio_cmd_zero

.Lpi4_audio_cmd_device_info:
    mov x0, x20
    bl pi4_audio_write_device_info
    b .Lpi4_audio_cmd_finish

.Lpi4_audio_cmd_ring_info:
    mov x0, x20
    bl pi4_audio_write_ring_info
    b .Lpi4_audio_cmd_finish

.Lpi4_audio_cmd_stream_info:
    mov x0, x20
    mov x1, x21
    bl pi4_audio_write_stream_info
    b .Lpi4_audio_cmd_finish

.Lpi4_audio_cmd_buffered_bytes:
    cmp x20, #PI4_VIBE_AUDIO_HANDLE
    b.ne .Lpi4_audio_cmd_zero
    adr x2, pi4_audio_pcm_queued_bytes
    ldr x0, [x2]
    b .Lpi4_audio_cmd_finish

.Lpi4_audio_cmd_pull_state:
    cmp x20, #PI4_VIBE_AUDIO_HANDLE
    b.ne .Lpi4_audio_cmd_zero
    adr x2, pi4_audio_pcm_pull_request_count
    ldr x0, [x2]
    b .Lpi4_audio_cmd_finish

.Lpi4_audio_cmd_pcm_open:
    cbz x21, .Lpi4_audio_cmd_pcm_open_backend
    mov x0, x21
    mov x1, #PI4_VIBE_AUDIO_PCM_DESC_MIN_BYTES
    bl pi4_validate_el0_user_range
    cbz x0, .Lpi4_audio_cmd_inval
    ldr x2, [x21, #PI4_VIBE_AUDIO_DESC_CHANNELS_OFFSET]
    cbz x2, .Lpi4_audio_cmd_pcm_open_check_format
    cmp x2, #PI4_VIBE_AUDIO_CHANNELS
    b.ne .Lpi4_audio_cmd_inval
.Lpi4_audio_cmd_pcm_open_check_format:
    ldr x2, [x21, #PI4_VIBE_AUDIO_DESC_FORMAT_OFFSET]
    cbz x2, .Lpi4_audio_cmd_pcm_open_backend
    cmp x2, #PI4_VIBE_AUDIO_FORMAT_U8_STEREO
    b.ne .Lpi4_audio_cmd_inval
.Lpi4_audio_cmd_pcm_open_backend:
    bl pi4_audio_backend_ready
    cbz x0, .Lpi4_audio_cmd_unavailable
    adr x2, pi4_audio_status_caps
    ldr x3, [x2]
    orr x3, x3, #PI4_VIBE_AUDIO_CAP_PCM_QUEUE
    str x3, [x2]
    adr x2, pi4_audio_pcm_stream_handle
    mov x3, #PI4_VIBE_AUDIO_HANDLE
    str x3, [x2]
    adr x2, pi4_audio_pcm_stream_mode
    mov x3, #PI4_VIBE_AUDIO_STREAM_PUSH
    str x3, [x2]
    adr x2, pi4_audio_status_queue_streams
    mov x3, #1
    str x3, [x2]
    adr x2, pi4_audio_pcm_active_streams
    str x3, [x2]
    adr x2, pi4_audio_pcm_lifecycle
    mov x3, #PI4_VIBE_AUDIO_PCM_LIFECYCLE_OPEN
    str x3, [x2]
    mov x0, #PI4_VIBE_AUDIO_HANDLE
    b .Lpi4_audio_cmd_finish

.Lpi4_audio_cmd_pcm_write:
    cmp x20, #PI4_VIBE_AUDIO_HANDLE
    b.ne .Lpi4_audio_cmd_inval
    cbz x21, .Lpi4_audio_cmd_inval
    mov x0, x21
    mov x1, #16
    bl pi4_validate_el0_user_range
    cbz x0, .Lpi4_audio_cmd_inval
    cmp x19, #PI4_VIBE_AUDIO_PCM_WRITE_DESC
    b.ne .Lpi4_audio_cmd_pcm_write_load
    mov x0, x21
    mov x1, #PI4_VIBE_AUDIO_PCM_DESC_MIN_BYTES
    bl pi4_validate_el0_user_range
    cbz x0, .Lpi4_audio_cmd_inval
    ldr x2, [x21, #PI4_VIBE_AUDIO_DESC_CHANNELS_OFFSET]
    cbz x2, .Lpi4_audio_cmd_pcm_write_check_format
    cmp x2, #PI4_VIBE_AUDIO_CHANNELS
    b.ne .Lpi4_audio_cmd_inval
.Lpi4_audio_cmd_pcm_write_check_format:
    ldr x2, [x21, #PI4_VIBE_AUDIO_DESC_FORMAT_OFFSET]
    cbz x2, .Lpi4_audio_cmd_pcm_write_load
    cmp x2, #PI4_VIBE_AUDIO_FORMAT_U8_STEREO
    b.ne .Lpi4_audio_cmd_inval
.Lpi4_audio_cmd_pcm_write_load:
    ldr x22, [x21, #PI4_VIBE_AUDIO_DESC_SAMPLES_OFFSET]
    ldr x23, [x21, #PI4_VIBE_AUDIO_DESC_LENGTH_OFFSET]
    cbz x23, .Lpi4_audio_cmd_zero
    adr x2, pi4_audio_pcm_stream_handle
    ldr x3, [x2]
    cmp x3, #PI4_VIBE_AUDIO_HANDLE
    b.ne .Lpi4_audio_cmd_inval
    bl pi4_audio_backend_ready
    cbz x0, .Lpi4_audio_cmd_unavailable
    mov x0, x22
    mov x1, x23
    bl pi4_validate_el0_user_range
    cbz x0, .Lpi4_audio_cmd_inval
    adr x2, pi4_audio_pcm_queued_bytes
    ldr x3, [x2]
    mov x4, #PI4_VIBE_AUDIO_QUEUE_BYTES
    cmp x3, x4
    b.hs .Lpi4_audio_cmd_pcm_write_full
    sub x4, x4, x3
    cmp x23, x4
    csel x24, x23, x4, lo
    mov x0, x22
    mov x1, x24
    ldr x16, =pi4_usb_audio_write_u8_stereo
    blr x16
    cmp x0, x24
    csel x24, x0, x24, lo
    add x3, x3, x24
    str x3, [x2]
    adr x2, pi4_audio_pcm_write_offset
    ldr x3, [x2]
    add x3, x3, x24
    and x3, x3, #(PI4_VIBE_AUDIO_QUEUE_BYTES - 1)
    str x3, [x2]
    adr x2, pi4_audio_pcm_position_bytes
    ldr x3, [x2]
    add x3, x3, x24
    str x3, [x2]
    adr x2, pi4_audio_pcm_mixed_bytes
    ldr x3, [x2]
    add x3, x3, x24
    str x3, [x2]
    cmp x24, x23
    b.hs .Lpi4_audio_cmd_pcm_write_done
    sub x3, x23, x24
    adr x2, pi4_audio_pcm_drop_count
    ldr x4, [x2]
    add x4, x4, x3
    str x4, [x2]
.Lpi4_audio_cmd_pcm_write_done:
    adr x2, pi4_audio_pcm_queued_bytes
    str xzr, [x2]
    bl pi4_audio_try_promote_hardware_backend
    adr x2, pi4_audio_pcm_lifecycle
    mov x3, #PI4_VIBE_AUDIO_PCM_LIFECYCLE_WRITTEN
    str x3, [x2]
    mov x0, x24
    b .Lpi4_audio_cmd_finish

.Lpi4_audio_cmd_pcm_write_full:
    adr x2, pi4_audio_pcm_drop_count
    ldr x3, [x2]
    add x3, x3, x23
    str x3, [x2]
    mov x0, xzr
    b .Lpi4_audio_cmd_finish

.Lpi4_audio_cmd_pcm_drain:
    cmp x20, #PI4_VIBE_AUDIO_HANDLE
    b.ne .Lpi4_audio_cmd_inval
    adr x2, pi4_audio_pcm_queued_bytes
    str xzr, [x2]
    adr x2, pi4_audio_pcm_lifecycle
    mov x3, #PI4_VIBE_AUDIO_PCM_LIFECYCLE_DRAINING
    str x3, [x2]
    adr x2, pi4_audio_pcm_pull_request_count
    ldr x3, [x2]
    adr x2, pi4_audio_pcm_pull_refill_count
    str x3, [x2]
    b .Lpi4_audio_cmd_zero

.Lpi4_audio_cmd_pcm_close:
    cmp x20, #PI4_VIBE_AUDIO_HANDLE
    b.ne .Lpi4_audio_cmd_inval
    bl pi4_audio_pcm_reset_queue
    adr x2, pi4_audio_pcm_lifecycle
    mov x3, #PI4_VIBE_AUDIO_PCM_LIFECYCLE_CLOSED
    str x3, [x2]
    b .Lpi4_audio_cmd_zero

.Lpi4_audio_cmd_zero:
    mov x0, xzr
    b .Lpi4_audio_cmd_finish
.Lpi4_audio_cmd_enosys:
    mov x0, #PI4_VIBE_ENOSYS
    neg x0, x0
    b .Lpi4_audio_cmd_finish
.Lpi4_audio_cmd_unavailable:
    mov x0, #PI4_VIBE_ENOSYS
    neg x0, x0
    b .Lpi4_audio_cmd_finish
.Lpi4_audio_cmd_inval:
    mov x0, #PI4_VIBE_EINVAL
    neg x0, x0

.Lpi4_audio_cmd_finish:
    adr x2, pi4_audio_status_last_result
    str x0, [x2]
    ldr x25, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret
.size pi4_audio_syscall_dispatch, . - pi4_audio_syscall_dispatch

.type pi4_audio_pcm_reset_queue, %function
pi4_audio_pcm_reset_queue:
    adr x0, pi4_audio_pcm_stream_handle
    str xzr, [x0]
    adr x0, pi4_audio_pcm_stream_mode
    str xzr, [x0]
    adr x0, pi4_audio_pcm_active_streams
    str xzr, [x0]
    adr x0, pi4_audio_pcm_queued_bytes
    str xzr, [x0]
    adr x0, pi4_audio_pcm_write_offset
    str xzr, [x0]
    ret
.size pi4_audio_pcm_reset_queue, . - pi4_audio_pcm_reset_queue

.type pi4_audio_write_device_info, %function
pi4_audio_write_device_info:
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    str x21, [sp, #32]
    mov x19, x0
    mov x1, #PI4_VIBE_AUDIO_INFO_BYTES
    bl pi4_validate_el0_user_range
    cbz x0, .Lpi4_audio_write_info_inval
    mov x0, x19
    mov x1, #PI4_VIBE_AUDIO_INFO_BYTES
    bl pi4_zero_buffer
    bl pi4_audio_backend_ready
    mov x20, x0
    adr x0, pi4_audio_status_caps
    ldr x21, [x0]
    cbz x20, .Lpi4_audio_write_info_no_device
    adr x0, pi4_audio_status_usb_ready
    ldr x0, [x0]
    cbz x0, .Lpi4_audio_write_info_pwm_kind
    mov x0, #PI4_VIBE_AUDIO_DEVICE_PI4_USB
    b .Lpi4_audio_write_info_kind_ready
.Lpi4_audio_write_info_pwm_kind:
    mov x0, #PI4_VIBE_AUDIO_DEVICE_PI4_PWM
    b .Lpi4_audio_write_info_kind_ready
.Lpi4_audio_write_info_no_device:
    mov x0, #PI4_VIBE_AUDIO_DEVICE_NONE
.Lpi4_audio_write_info_kind_ready:
    str x0, [x19, #0]
    cbz x20, .Lpi4_audio_write_info_absent
    mov x0, #PI4_VIBE_AUDIO_DEVICE_STATUS_READY
    b .Lpi4_audio_write_info_status_ready
.Lpi4_audio_write_info_absent:
    mov x21, xzr
    mov x0, #PI4_VIBE_AUDIO_DEVICE_STATUS_ABSENT
.Lpi4_audio_write_info_status_ready:
    str x0, [x19, #8]
    str x21, [x19, #56]
    cbz x20, .Lpi4_audio_write_info_success
    mov x0, #PI4_VIBE_AUDIO_SAMPLE_RATE
    str x0, [x19, #16]
    mov x0, #PI4_VIBE_AUDIO_CHANNELS
    str x0, [x19, #24]
    mov x0, #PI4_VIBE_AUDIO_FORMAT_U8_STEREO
    str x0, [x19, #32]
    mov x0, #PI4_VIBE_AUDIO_QUEUE_BYTES
    str x0, [x19, #40]
    mov x0, #PI4_VIBE_AUDIO_PERIOD_BYTES
    str x0, [x19, #48]
    adr x0, pi4_audio_pcm_active_streams
    ldr x0, [x0]
    str x0, [x19, #64]
    str xzr, [x19, #72]
    adr x0, pi4_audio_pcm_pull_refill_count
    ldr x0, [x0]
    str x0, [x19, #80]
    adr x0, pi4_audio_status_playback_start_count
    ldr x0, [x0]
    str x0, [x19, #88]
.Lpi4_audio_write_info_success:
    mov x0, xzr
    b .Lpi4_audio_write_info_done
.Lpi4_audio_write_info_inval:
    mov x0, #PI4_VIBE_EINVAL
    neg x0, x0
.Lpi4_audio_write_info_done:
    ldr x21, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret
.size pi4_audio_write_device_info, . - pi4_audio_write_device_info

.type pi4_audio_write_ring_info, %function
pi4_audio_write_ring_info:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x19, [sp, #16]
    mov x19, x0
    mov x1, #PI4_VIBE_AUDIO_RING_INFO_BYTES
    bl pi4_validate_el0_user_range
    cbz x0, .Lpi4_audio_write_ring_inval
    mov x0, x19
    mov x1, #PI4_VIBE_AUDIO_RING_INFO_BYTES
    bl pi4_zero_buffer
    bl pi4_audio_backend_ready
    cbz x0, .Lpi4_audio_write_ring_success
    mov x0, #PI4_VIBE_AUDIO_FORMAT_U8_STEREO
    str x0, [x19, #0]
    mov x0, #PI4_VIBE_AUDIO_CHANNELS
    str x0, [x19, #8]
    mov x0, #PI4_VIBE_AUDIO_SAMPLE_RATE
    str x0, [x19, #16]
    mov x0, #PI4_VIBE_AUDIO_QUEUE_BYTES
    str x0, [x19, #24]
    mov x0, #PI4_VIBE_AUDIO_PERIOD_BYTES
    str x0, [x19, #32]
    adr x0, pi4_audio_pcm_write_offset
    ldr x1, [x0]
    str x1, [x19, #40]
    lsr x2, x1, #9
    and x2, x2, #1
    str x2, [x19, #48]
    adr x0, pi4_audio_pcm_queued_bytes
    ldr x1, [x0]
    str x1, [x19, #56]
    adr x0, pi4_audio_pcm_mixed_bytes
    ldr x1, [x0]
    str x1, [x19, #64]
    adr x0, pi4_audio_status_queue_underruns
    ldr x1, [x0]
    str x1, [x19, #72]
    adr x0, pi4_audio_pcm_drop_count
    ldr x1, [x0]
    str x1, [x19, #80]
    str xzr, [x19, #88]
.Lpi4_audio_write_ring_success:
    mov x0, xzr
    b .Lpi4_audio_write_ring_done
.Lpi4_audio_write_ring_inval:
    mov x0, #PI4_VIBE_EINVAL
    neg x0, x0
.Lpi4_audio_write_ring_done:
    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size pi4_audio_write_ring_info, . - pi4_audio_write_ring_info

.type pi4_audio_write_stream_info, %function
pi4_audio_write_stream_info:
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    mov x19, x0
    mov x20, x1
    mov x0, x20
    mov x1, #PI4_VIBE_AUDIO_STREAM_INFO_BYTES
    bl pi4_validate_el0_user_range
    cbz x0, .Lpi4_audio_write_stream_inval
    mov x0, x20
    mov x1, #PI4_VIBE_AUDIO_STREAM_INFO_BYTES
    bl pi4_zero_buffer
    bl pi4_audio_backend_ready
    cbz x0, .Lpi4_audio_write_stream_empty
    adr x0, pi4_audio_pcm_stream_handle
    ldr x21, [x0]
    cbnz x19, .Lpi4_audio_write_stream_have_request
    mov x19, x21
.Lpi4_audio_write_stream_have_request:
    cbz x21, .Lpi4_audio_write_stream_empty
    cmp x19, x21
    b.ne .Lpi4_audio_write_stream_empty
    adr x0, pi4_audio_pcm_stream_mode
    ldr x1, [x0]
    str x1, [x20, #0]
    mov x2, xzr
    cmp x1, #PI4_VIBE_AUDIO_STREAM_PULL
    b.ne .Lpi4_audio_write_stream_active_flag
    orr x2, x2, #PI4_VIBE_AUDIO_STREAM_FLAG_PULL
.Lpi4_audio_write_stream_active_flag:
    adr x0, pi4_audio_pcm_active_streams
    ldr x3, [x0]
    cbz x3, .Lpi4_audio_write_stream_pending_flag
    orr x2, x2, #PI4_VIBE_AUDIO_STREAM_FLAG_ACTIVE
.Lpi4_audio_write_stream_pending_flag:
    adr x0, pi4_audio_pcm_pull_request_count
    ldr x4, [x0]
    adr x0, pi4_audio_pcm_pull_refill_count
    ldr x5, [x0]
    cmp x4, x5
    b.ls .Lpi4_audio_write_stream_flags_done
    orr x2, x2, #PI4_VIBE_AUDIO_STREAM_FLAG_REFILL_PENDING
.Lpi4_audio_write_stream_flags_done:
    str x2, [x20, #8]
    str x21, [x20, #16]
    str x4, [x20, #24]
    str x5, [x20, #32]
    sub x6, x4, x5
    cmp x4, x5
    csel x6, x6, xzr, hi
    str x6, [x20, #40]
    adr x0, pi4_audio_pcm_queued_bytes
    ldr x1, [x0]
    str x1, [x20, #48]
    mov x1, #PI4_VIBE_AUDIO_LOW_WATER_BYTES
    str x1, [x20, #56]
    str x3, [x20, #64]
    adr x0, pi4_audio_status_queue_underruns
    ldr x1, [x0]
    str x1, [x20, #72]
    adr x0, pi4_audio_pcm_drop_count
    ldr x1, [x0]
    str x1, [x20, #80]
    adr x0, pi4_audio_pcm_position_bytes
    ldr x1, [x0]
    str x1, [x20, #88]
    mov x0, xzr
    b .Lpi4_audio_write_stream_done
.Lpi4_audio_write_stream_empty:
    str x19, [x20, #16]
    mov x0, xzr
    b .Lpi4_audio_write_stream_done
.Lpi4_audio_write_stream_inval:
    mov x0, #PI4_VIBE_EINVAL
    neg x0, x0
.Lpi4_audio_write_stream_done:
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret
.size pi4_audio_write_stream_info, . - pi4_audio_write_stream_info

.type pi4_prepare_audio_mailbox_msg, %function
pi4_prepare_audio_mailbox_msg:
    adr x0, pi4_audio_mailbox_msg_code
    str wzr, [x0]

    mov w1, #4
    adr x0, pi4_audio_clock_state_code
    str w1, [x0]
    adr x0, pi4_audio_clock_rate_code
    str w1, [x0]

    mov w1, #PI4_MAILBOX_CLOCK_PWM
    adr x0, pi4_audio_clock_state_id
    str w1, [x0]
    adr x0, pi4_audio_clock_rate_id
    str w1, [x0]

    adr x0, pi4_audio_clock_state_value
    str wzr, [x0]
    adr x0, pi4_audio_clock_rate_value
    str wzr, [x0]
    ret
.size pi4_prepare_audio_mailbox_msg, . - pi4_prepare_audio_mailbox_msg

.type pi4_record_audio_mailbox_probe, %function
pi4_record_audio_mailbox_probe:
    adr x0, pi4_audio_clock_state_code
    ldr w1, [x0]
    tbnz w1, #PI4_MAILBOX_TAG_RESPONSE, .Lpi4_audio_state_tag_ok
    ret
.Lpi4_audio_state_tag_ok:
    adr x0, pi4_audio_clock_rate_code
    ldr w1, [x0]
    tbnz w1, #PI4_MAILBOX_TAG_RESPONSE, .Lpi4_audio_rate_tag_ok
    ret
.Lpi4_audio_rate_tag_ok:
    adr x0, pi4_audio_clock_state_id
    ldr w2, [x0]
    cmp w2, #PI4_MAILBOX_CLOCK_PWM
    b.ne .Lpi4_audio_probe_done
    adr x0, pi4_audio_clock_rate_id
    ldr w3, [x0]
    cmp w3, #PI4_MAILBOX_CLOCK_PWM
    b.ne .Lpi4_audio_probe_done
    adr x0, pi4_audio_clock_state_value
    ldr w4, [x0]
    tbnz w4, #PI4_MAILBOX_CLOCK_STATE_MISSING, .Lpi4_audio_probe_done
    adr x0, pi4_audio_clock_rate_value
    ldr w5, [x0]
    cbz w5, .Lpi4_audio_probe_done

    adr x0, pi4_audio_status_mailbox_success
    mov x6, #1
    str x6, [x0]
    adr x0, pi4_audio_status_mailbox_clock_id
    uxtw x6, w3
    str x6, [x0]
    adr x0, pi4_audio_status_mailbox_clock_rate
    uxtw x6, w5
    str x6, [x0]
    adr x0, pi4_audio_status_mailbox_clock_state
    uxtw x6, w4
    str x6, [x0]
    adr x0, pi4_audio_status_caps
    ldr x6, [x0]
    orr x6, x6, #PI4_VIBE_AUDIO_CAP_MAILBOX_CLOCK
    str x6, [x0]
.Lpi4_audio_probe_done:
    ret
.size pi4_record_audio_mailbox_probe, . - pi4_record_audio_mailbox_probe

.type pi4_record_audio_mmio_probe, %function
pi4_record_audio_mmio_probe:
    adr x0, pi4_audio_status_mmio_legacy_base
    ldr x1, =PI4_PWM0_LEGACY_BASE
    str x1, [x0]
    adr x0, pi4_audio_status_mmio_arm_base
    ldr x1, =PI4_PWM0_BASE
    str x1, [x0]
    adr x0, pi4_audio_status_mmio_span
    mov x1, #PI4_PWM0_SPAN
    str x1, [x0]
    adr x0, pi4_audio_status_mmio_ready
    str xzr, [x0]
    adr x0, pi4_audio_status_caps
    mov x1, #PI4_VIBE_AUDIO_CAP_MMIO_WINDOW
    str x1, [x0]
    ret
.size pi4_record_audio_mmio_probe, . - pi4_record_audio_mmio_probe

.type pi4_framebuffer_init, %function
pi4_framebuffer_init:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    adr x0, pi4_status_mbox_base
    ldr x1, =PI4_MAILBOX_BASE
    str x1, [x0]

    adr x0, pi4_fb_mailbox_msg_code
    str wzr, [x0]
    mov w1, #8
    adr x0, pi4_fb_phys_code
    str w1, [x0]
    adr x0, pi4_fb_virt_code
    str w1, [x0]
    adr x0, pi4_fb_offset_code
    str w1, [x0]
    mov w1, #4
    adr x0, pi4_fb_depth_code
    str w1, [x0]
    adr x0, pi4_fb_order_code
    str w1, [x0]
    adr x0, pi4_fb_pitch_code
    str w1, [x0]
    mov w1, #8
    adr x0, pi4_fb_alloc_code
    str w1, [x0]

    mov w1, #PI4_FB_REQUEST_WIDTH
    adr x0, pi4_fb_phys_width
    str w1, [x0]
    adr x0, pi4_fb_virt_width
    str w1, [x0]
    mov w1, #PI4_FB_REQUEST_HEIGHT
    adr x0, pi4_fb_phys_height
    str w1, [x0]
    adr x0, pi4_fb_virt_height
    str w1, [x0]
    adr x0, pi4_fb_offset_x
    str wzr, [x0]
    adr x0, pi4_fb_offset_y
    str wzr, [x0]
    mov w1, #PI4_FB_REQUEST_DEPTH
    adr x0, pi4_fb_depth_value
    str w1, [x0]
    mov w1, #PI4_FB_REQUEST_PIXEL_ORDER
    adr x0, pi4_fb_order_value
    str w1, [x0]
    mov w1, #PI4_FB_REQUEST_ALIGNMENT
    adr x0, pi4_fb_alloc_align
    str w1, [x0]
    adr x0, pi4_fb_pitch_value
    str wzr, [x0]

    adr x0, pi4_fb_mailbox_msg
    bl pi4_mailbox_call
    cbnz x0, .Lpi4_framebuffer_mailbox_ok
    mov x0, #1
    b .Lpi4_framebuffer_keep_wait

.Lpi4_framebuffer_mailbox_ok:
    adr x0, pi4_status_pi4mailbox
    ldr w1, =VIBE_PI4_STATUS_PI4MAILBOX_OK
    str w1, [x0]

    adr x0, pi4_fb_phys_code
    ldr w1, [x0]
    tbnz w1, #PI4_MAILBOX_TAG_RESPONSE, .Lpi4_framebuffer_phys_ok
    mov x0, #2
    b .Lpi4_framebuffer_keep_wait
.Lpi4_framebuffer_phys_ok:
    adr x0, pi4_fb_virt_code
    ldr w1, [x0]
    tbnz w1, #PI4_MAILBOX_TAG_RESPONSE, .Lpi4_framebuffer_virt_ok
    mov x0, #3
    b .Lpi4_framebuffer_keep_wait
.Lpi4_framebuffer_virt_ok:
    adr x0, pi4_fb_offset_code
    ldr w1, [x0]
    tbnz w1, #PI4_MAILBOX_TAG_RESPONSE, .Lpi4_framebuffer_offset_ok
    mov x0, #16
    b .Lpi4_framebuffer_keep_wait
.Lpi4_framebuffer_offset_ok:
    adr x0, pi4_fb_depth_code
    ldr w1, [x0]
    tbnz w1, #PI4_MAILBOX_TAG_RESPONSE, .Lpi4_framebuffer_depth_ok
    mov x0, #4
    b .Lpi4_framebuffer_keep_wait
.Lpi4_framebuffer_depth_ok:
    adr x0, pi4_fb_order_code
    ldr w1, [x0]
    tbnz w1, #PI4_MAILBOX_TAG_RESPONSE, .Lpi4_framebuffer_order_ok
    mov x0, #5
    b .Lpi4_framebuffer_keep_wait
.Lpi4_framebuffer_order_ok:
    adr x0, pi4_fb_alloc_code
    ldr w1, [x0]
    tbnz w1, #PI4_MAILBOX_TAG_RESPONSE, .Lpi4_framebuffer_alloc_ok
    mov x0, #6
    b .Lpi4_framebuffer_keep_wait
.Lpi4_framebuffer_alloc_ok:
    adr x0, pi4_fb_pitch_code
    ldr w1, [x0]
    tbnz w1, #PI4_MAILBOX_TAG_RESPONSE, .Lpi4_framebuffer_pitch_ok
    mov x0, #7
    b .Lpi4_framebuffer_keep_wait

.Lpi4_framebuffer_pitch_ok:
    adr x0, pi4_fb_alloc_base
    ldr w2, [x0]
    adr x0, pi4_fb_alloc_size
    ldr w3, [x0]
    adr x0, pi4_fb_pitch_value
    ldr w5, [x0]
    adr x0, pi4_fb_virt_width
    ldr w6, [x0]
    adr x0, pi4_fb_virt_height
    ldr w7, [x0]
    adr x0, pi4_fb_depth_value
    ldr w8, [x0]
    adr x0, pi4_fb_order_value
    ldr w9, [x0]
    adr x0, pi4_fb_offset_x
    ldr w18, [x0]
    adr x0, pi4_fb_offset_y
    ldr w4, [x0]

    cbz w2, .Lpi4_framebuffer_bad_base
    cbz w3, .Lpi4_framebuffer_bad_size
    cbz w5, .Lpi4_framebuffer_bad_pitch
    cbz w6, .Lpi4_framebuffer_bad_width
    cbz w7, .Lpi4_framebuffer_bad_height
    cmp w6, #PI4_FB_PRESENT_MAX_WIDTH
    b.lo .Lpi4_framebuffer_bad_width
    cmp w7, #PI4_FB_PRESENT_MAX_HEIGHT
    b.lo .Lpi4_framebuffer_bad_height
    cmp w8, #PI4_FB_REQUEST_DEPTH
    b.ne .Lpi4_framebuffer_bad_depth
    cbnz w18, .Lpi4_framebuffer_bad_offset
    cbnz w4, .Lpi4_framebuffer_bad_offset

    uxtw x10, w6
    uxtw x11, w7
    uxtw x12, w5
    lsl x13, x10, #2
    cmp x12, x13
    b.lo .Lpi4_framebuffer_bad_pitch
    mul x14, x12, x11
    uxtw x15, w3
    cmp x15, x14
    b.lo .Lpi4_framebuffer_bad_size

    uxtw x16, w2
    and x17, x16, #0x3fffffff
    cbz x17, .Lpi4_framebuffer_bad_base

    adr x0, pi4_status_fb_bus_base
    str x16, [x0]
    adr x0, pi4_status_fb_cpu_base
    str x17, [x0]
    adr x0, pi4_status_fb_size
    str x15, [x0]
    adr x0, pi4_status_fb_pitch
    str x12, [x0]
    adr x0, pi4_status_fb_width
    str x10, [x0]
    adr x0, pi4_status_fb_height
    str x11, [x0]
    adr x0, pi4_status_fb_depth
    uxtw x13, w8
    str x13, [x0]
    adr x0, pi4_status_fb_order
    uxtw x14, w9
    str x14, [x0]
    lsl x13, x13, #32
    orr x13, x13, x14
    adr x0, pi4_status_fb_format
    str x13, [x0]

    ldr w0, =PI4_FB_TEST_PIXEL
    str w0, [x17]
    dsb sy
    ldr w1, [x17]
    adr x2, pi4_status_fb_write
    uxtw x3, w0
    str x3, [x2]
    adr x2, pi4_status_fb_sample
    uxtw x3, w1
    str x3, [x2]
    cmp w1, w0
    b.ne .Lpi4_framebuffer_bad_sample

    adr x0, pi4_status_gfx
    ldr w1, =VIBE_PI4_STATUS_GFX_OK
    str w1, [x0]
    adr x0, pi4_status_fb
    ldr w1, =VIBE_PI4_STATUS_FB_PI4FB
    str w1, [x0]
    adr x0, pi4_status_pi4fb
    ldr w1, =VIBE_PI4_STATUS_PI4FB_OK
    str w1, [x0]
    adr x0, pi4_fb_selftest_present
    mov x1, #PI4_FB_PRESENT_SOURCE_SELFTEST
    bl pi4_present_indexed_frame
    cbz x0, .Lpi4_framebuffer_selftest_ok
    mov x0, #15
    b .Lpi4_framebuffer_keep_wait
.Lpi4_framebuffer_selftest_ok:
    adr x0, pi4_status_framebuffer_gate
    ldr w1, =VIBE_PI4_GATE_FRAMEBUFFER_OK
    str w1, [x0]
    b .Lpi4_framebuffer_done

.Lpi4_framebuffer_bad_base:
    mov x0, #8
    b .Lpi4_framebuffer_keep_wait
.Lpi4_framebuffer_bad_size:
    mov x0, #9
    b .Lpi4_framebuffer_keep_wait
.Lpi4_framebuffer_bad_pitch:
    mov x0, #10
    b .Lpi4_framebuffer_keep_wait
.Lpi4_framebuffer_bad_width:
    mov x0, #11
    b .Lpi4_framebuffer_keep_wait
.Lpi4_framebuffer_bad_height:
    mov x0, #12
    b .Lpi4_framebuffer_keep_wait
.Lpi4_framebuffer_bad_depth:
    mov x0, #13
    b .Lpi4_framebuffer_keep_wait
.Lpi4_framebuffer_bad_sample:
    mov x0, #14
    b .Lpi4_framebuffer_keep_wait
.Lpi4_framebuffer_bad_offset:
    mov x0, #17
    b .Lpi4_framebuffer_keep_wait

.Lpi4_framebuffer_keep_wait:
    adr x1, pi4_status_fb_fail
    str x0, [x1]
    ldr w2, =VIBE_PI4_STATUS_WAIT
    adr x1, pi4_status_pi4fb
    str w2, [x1]
    adr x1, pi4_status_gfx
    str w2, [x1]
    adr x1, pi4_status_fb
    str w2, [x1]
    adr x1, pi4_status_framebuffer_gate
    ldr w2, =VIBE_PI4_GATE_FRAMEBUFFER_WAIT
    str w2, [x1]

.Lpi4_framebuffer_done:
    ldp x29, x30, [sp], #16
    ret
.size pi4_framebuffer_init, . - pi4_framebuffer_init

.type pi4_present_indexed_frame, %function
pi4_present_indexed_frame:
    stp x19, x20, [sp, #-96]!
    stp x21, x22, [sp, #16]
    stp x23, x24, [sp, #32]
    stp x25, x26, [sp, #48]
    stp x27, x28, [sp, #64]
    stp x29, x30, [sp, #80]

    mov x19, x0
    mov x20, x1
    cbz x19, .Lpi4_present_bad_arg

    adr x0, pi4_status_pi4fb
    ldr w0, [x0]
    ldr w1, =VIBE_PI4_STATUS_PI4FB_OK
    cmp w0, w1
    b.ne .Lpi4_present_unavailable

    ldr x21, [x19, #0]
    ldr x22, [x19, #8]
    ldr x23, [x19, #16]
    ldr x24, [x19, #24]
    cbz x21, .Lpi4_present_bad_arg
    cbz x22, .Lpi4_present_bad_arg
    cbz x23, .Lpi4_present_bad_arg
    cbz x24, .Lpi4_present_bad_arg
    cmp x23, #PI4_FB_PRESENT_MAX_WIDTH
    b.hi .Lpi4_present_bad_arg
    cmp x24, #PI4_FB_PRESENT_MAX_HEIGHT
    b.hi .Lpi4_present_bad_arg

    adr x0, pi4_status_fb_width
    ldr x7, [x0]
    adr x0, pi4_status_fb_height
    ldr x8, [x0]
    adr x0, pi4_status_fb_pitch
    ldr x26, [x0]
    adr x0, pi4_status_fb_cpu_base
    ldr x25, [x0]
    adr x0, pi4_status_fb_order
    ldr x28, [x0]
    cbz x7, .Lpi4_present_unavailable
    cbz x8, .Lpi4_present_unavailable
    cbz x26, .Lpi4_present_unavailable
    cbz x25, .Lpi4_present_unavailable

    mov x30, xzr
    cmp x23, #PI4_FB_PRESENT_MODE13_WIDTH
    b.ne .Lpi4_present_fullscreen_desktop_check
    cmp x24, #PI4_FB_PRESENT_MODE13_HEIGHT
    b.ne .Lpi4_present_visual_height_source
    b .Lpi4_present_fullscreen_prepare

.Lpi4_present_fullscreen_desktop_check:
    cmp x23, #PI4_FB_PRESENT_MAX_WIDTH
    b.ne .Lpi4_present_visual_height_source
    cmp x24, #PI4_FB_PRESENT_MAX_HEIGHT
    b.ne .Lpi4_present_visual_height_source
    b .Lpi4_present_fullscreen_prepare

.Lpi4_present_fullscreen_prepare:
    udiv x11, x7, x23
    mov x30, #1
    mov x27, #1
    cmp x11, #0
    csel x27, x27, x11, eq
    mov x13, x7
    mov x14, x8
    mov x15, xzr
    mov x16, xzr
    mov x29, xzr
    b .Lpi4_present_view_ready

.Lpi4_present_visual_height_source:
    mov x18, x24
    cmp x23, #PI4_FB_PRESENT_MODE13_WIDTH
    b.ne .Lpi4_present_visual_height_ready
    cmp x24, #PI4_FB_PRESENT_MODE13_HEIGHT
    b.ne .Lpi4_present_visual_height_ready
    mov x18, #PI4_FB_PRESENT_MODE13_ASPECT_HEIGHT
.Lpi4_present_visual_height_ready:
    udiv x11, x7, x23
    udiv x12, x8, x18
    cmp x11, x12
    csel x27, x11, x12, lo
    cbz x27, .Lpi4_present_bad_arg
    mov x29, xzr

    mul x13, x23, x27
    mul x14, x18, x27
    sub x15, x7, x13
    lsr x15, x15, #1
    sub x16, x8, x14
    lsr x16, x16, #1

.Lpi4_present_view_ready:
    mov x19, xzr
    adr x2, pi4_status_fb_view_x
    str x15, [x2]
    adr x2, pi4_status_fb_view_y
    str x16, [x2]
    adr x2, pi4_status_fb_view_width
    str x13, [x2]
    adr x2, pi4_status_fb_view_height
    str x14, [x2]
    mov x3, #PI4_VIBE_FB_POLICY_ASPECT
    cbz x30, .Lpi4_present_policy_ready
    mov x3, #PI4_VIBE_FB_POLICY_FULLSCREEN_STRETCH
.Lpi4_present_policy_ready:
    adr x2, pi4_status_fb_policy
    str x3, [x2]

    adr x0, pi4_status_fb_last_view_x
    ldr x1, [x0]
    cmp x1, x15
    b.ne .Lpi4_present_clear_lfb
    adr x0, pi4_status_fb_last_view_y
    ldr x1, [x0]
    cmp x1, x16
    b.ne .Lpi4_present_clear_lfb
    adr x0, pi4_status_fb_last_view_width
    ldr x1, [x0]
    cmp x1, x13
    b.ne .Lpi4_present_clear_lfb
    adr x0, pi4_status_fb_last_view_height
    ldr x1, [x0]
    cmp x1, x14
    b.ne .Lpi4_present_clear_lfb
    b .Lpi4_present_clear_done

.Lpi4_present_clear_lfb:
    mul x2, x26, x8
    mov x3, x25
    lsr x4, x2, #3
    cbz x4, .Lpi4_present_clear_tail
.Lpi4_present_clear_loop:
    str xzr, [x3], #8
    subs x4, x4, #1
    b.ne .Lpi4_present_clear_loop
.Lpi4_present_clear_tail:
    tbz x2, #2, .Lpi4_present_clear_store
    str wzr, [x3]
.Lpi4_present_clear_store:
    dsb sy
    adr x0, pi4_status_fb_clear_count
    ldr x1, [x0]
    add x1, x1, #1
    str x1, [x0]
    adr x0, pi4_status_fb_last_view_x
    str x15, [x0]
    adr x0, pi4_status_fb_last_view_y
    str x16, [x0]
    adr x0, pi4_status_fb_last_view_width
    str x13, [x0]
    adr x0, pi4_status_fb_last_view_height
    str x14, [x0]
.Lpi4_present_clear_done:
    cbnz x30, .Lpi4_present_stretch_frame

    cmp x23, x7
    b.ne .Lpi4_present_scaled_frame
    cmp x24, x8
    b.ne .Lpi4_present_scaled_frame
    cmp x27, #1
    b.ne .Lpi4_present_scaled_frame
    cbnz x15, .Lpi4_present_scaled_frame
    cbnz x16, .Lpi4_present_scaled_frame

    mov x0, xzr
.Lpi4_present_fullscreen_y:
    cmp x0, x24
    b.hs .Lpi4_present_copy_done
    madd x1, x0, x23, x21
    madd x5, x0, x26, x25
    mov x6, xzr

.Lpi4_present_fullscreen_x:
    cmp x6, x23
    b.hs .Lpi4_present_next_fullscreen_y
    ldrb w7, [x1, x6]
    add x8, x7, x7, lsl #1
    add x8, x22, x8
    ldrb w9, [x8]
    ldrb w10, [x8, #1]
    ldrb w11, [x8, #2]
    lsl w12, w9, #16
    lsl w13, w10, #8
    orr w12, w12, w13
    orr w12, w12, w11
    lsl w14, w11, #16
    orr w14, w14, w13
    orr w14, w14, w9
    cmp x28, xzr
    csel w12, w14, w12, eq
    cbnz x19, .Lpi4_present_fullscreen_sample_ready
    cbz w12, .Lpi4_present_fullscreen_sample_ready
    uxtw x19, w12
.Lpi4_present_fullscreen_sample_ready:
    str w12, [x5], #4
    add x29, x29, x12
    add x29, x29, x29, lsl #5
    eor x29, x29, x0
    eor x29, x29, x6, lsl #32
    add x6, x6, #1
    b .Lpi4_present_fullscreen_x

.Lpi4_present_next_fullscreen_y:
    add x0, x0, #1
    b .Lpi4_present_fullscreen_y

.Lpi4_present_stretch_frame:
    udiv x18, x23, x7
    msub x3, x18, x7, x23
    mov x0, xzr
.Lpi4_present_stretch_y:
    cmp x0, x8
    b.hs .Lpi4_present_copy_done
    mul x1, x0, x24
    udiv x1, x1, x8
    mul x1, x1, x23
    add x1, x21, x1
    madd x5, x0, x26, x25
    mov x6, xzr
    mov x17, xzr
    mov x4, xzr

.Lpi4_present_stretch_x:
    cmp x6, x7
    b.hs .Lpi4_present_next_stretch_y
    ldrb w2, [x1, x17]
    add x2, x2, x2, lsl #1
    add x2, x22, x2
    ldrb w9, [x2]
    ldrb w10, [x2, #1]
    ldrb w11, [x2, #2]
    lsl w12, w9, #16
    lsl w13, w10, #8
    orr w12, w12, w13
    orr w12, w12, w11
    lsl w14, w11, #16
    orr w14, w14, w13
    orr w14, w14, w9
    cmp x28, xzr
    csel w12, w14, w12, eq
    cbnz x19, .Lpi4_present_stretch_sample_ready
    cbz w12, .Lpi4_present_stretch_sample_ready
    uxtw x19, w12
.Lpi4_present_stretch_sample_ready:
    add x29, x29, x12
    add x29, x29, x29, lsl #5
    eor x29, x29, x0
    eor x29, x29, x6, lsl #32
    str w12, [x5], #4
    add x17, x17, x18
    add x4, x4, x3
    cmp x4, x7
    b.lo .Lpi4_present_next_stretch_x
    sub x4, x4, x7
    add x17, x17, #1
.Lpi4_present_next_stretch_x:
    add x6, x6, #1
    b .Lpi4_present_stretch_x

.Lpi4_present_next_stretch_y:
    add x0, x0, #1
    b .Lpi4_present_stretch_y

.Lpi4_present_scaled_frame:
    mov x0, xzr
.Lpi4_present_visual_y:
    cmp x0, x18
    b.hs .Lpi4_present_copy_done
    mul x1, x0, x24
    udiv x1, x1, x18
    mul x1, x1, x23
    add x1, x21, x1
    madd x2, x0, x27, x16
    mov x3, xzr

.Lpi4_present_scale_y:
    cmp x3, x27
    b.hs .Lpi4_present_next_src_y
    add x4, x2, x3
    madd x5, x4, x26, x25
    add x5, x5, x15, lsl #2
    mov x6, xzr

.Lpi4_present_src_x:
    cmp x6, x23
    b.hs .Lpi4_present_next_scale_y
    ldrb w7, [x1, x6]
    add x8, x7, x7, lsl #1
    add x8, x22, x8
    ldrb w9, [x8]
    ldrb w10, [x8, #1]
    ldrb w11, [x8, #2]
    lsl w12, w9, #16
    lsl w13, w10, #8
    orr w12, w12, w13
    orr w12, w12, w11
    lsl w14, w11, #16
    orr w14, w14, w13
    orr w14, w14, w9
    cmp x28, xzr
    csel w12, w14, w12, eq
    cbnz x19, .Lpi4_present_scaled_sample_ready
    cbz w12, .Lpi4_present_scaled_sample_ready
    uxtw x19, w12
.Lpi4_present_scaled_sample_ready:
    add x29, x29, x12
    add x29, x29, x29, lsl #5
    eor x29, x29, x0
    eor x29, x29, x6, lsl #32
    mov x17, xzr

.Lpi4_present_scale_x:
    cmp x17, x27
    b.hs .Lpi4_present_next_src_x
    str w12, [x5], #4
    add x17, x17, #1
    b .Lpi4_present_scale_x

.Lpi4_present_next_src_x:
    add x6, x6, #1
    b .Lpi4_present_src_x

.Lpi4_present_next_scale_y:
    add x3, x3, #1
    b .Lpi4_present_scale_y

.Lpi4_present_next_src_y:
    add x0, x0, #1
    b .Lpi4_present_visual_y

.Lpi4_present_copy_done:
    dsb sy
    madd x0, x16, x26, x25
    add x0, x0, x15, lsl #2
    ldr w1, [x0]

    uxtw x3, w12
    cbz x19, .Lpi4_present_write_sample_ready
    mov x3, x19
.Lpi4_present_write_sample_ready:
    adr x2, pi4_status_fb_write
    str x3, [x2]
    uxtw x3, w1
    cbnz x3, .Lpi4_present_read_sample_ready
    mov x3, x19
.Lpi4_present_read_sample_ready:
    adr x2, pi4_status_fb_sample
    str x3, [x2]

    adr x2, pi4_status_fb_frame_hash
    ldr x3, [x2]
    adr x4, pi4_status_fb_prev_frame_hash
    str x3, [x4]
    str x29, [x2]
    cmp x29, x3
    cset x4, ne
    adr x2, pi4_status_fb_changed
    str x4, [x2]
    cbz x4, .Lpi4_present_change_ready
    adr x2, pi4_status_fb_change_count
    ldr x3, [x2]
    add x3, x3, #1
    str x3, [x2]

.Lpi4_present_change_ready:
    adr x2, pi4_status_fb_present_count
    ldr x3, [x2]
    add x3, x3, #1
    str x3, [x2]
    adr x2, pi4_status_fb_present_source
    str x20, [x2]
    adr x2, pi4_status_fb_present_width
    str x23, [x2]
    adr x2, pi4_status_fb_present_height
    str x24, [x2]
    adr x2, pi4_status_fb_present_scale
    str x27, [x2]
    adr x2, pi4_status_fb_dirty_x
    str xzr, [x2]
    adr x2, pi4_status_fb_dirty_y
    str xzr, [x2]
    adr x2, pi4_status_fb_dirty_width
    str x23, [x2]
    adr x2, pi4_status_fb_dirty_height
    str x24, [x2]
    adr x2, pi4_status_fb_dirty_count
    ldr x3, [x2]
    add x3, x3, #1
    str x3, [x2]

    mov x4, #(PI4_FB_ABI_PRESENT | PI4_FB_ABI_DIRTY)
    cmp x20, #PI4_FB_PRESENT_SOURCE_IOCTL
    b.ne .Lpi4_present_abi_op_ready
    orr x4, x4, #PI4_FB_ABI_IOCTL_PRESENT
.Lpi4_present_abi_op_ready:
    adr x2, pi4_status_fb_abi_mask
    ldr x3, [x2]
    orr x3, x3, x4
    str x3, [x2]
    adr x2, pi4_status_fb_abi_last_op
    str x4, [x2]
    adr x2, pi4_status_fb_abi_last_source
    str x20, [x2]

    mov x0, xzr
    b .Lpi4_present_done

.Lpi4_present_bad_arg:
    mov x0, #PI4_VIBE_EINVAL
    neg x0, x0
    b .Lpi4_present_done

.Lpi4_present_unavailable:
    mov x0, #PI4_VIBE_ENOSYS
    neg x0, x0

.Lpi4_present_done:
    ldp x29, x30, [sp, #80]
    ldp x27, x28, [sp, #64]
    ldp x25, x26, [sp, #48]
    ldp x23, x24, [sp, #32]
    ldp x21, x22, [sp, #16]
    ldp x19, x20, [sp], #96
    ret
.size pi4_present_indexed_frame, . - pi4_present_indexed_frame

.type pi4_scan_board_identity, %function
pi4_scan_board_identity:
    adr x0, pi4_status_pi4dtb
    ldr w0, [x0]
    ldr w1, =VIBE_PI4_STATUS_PI4DTB_OK
    cmp w0, w1
    b.ne .Lpi4_board_scan_done

    adr x0, pi4_status_pi4dtb_root
    ldr x1, [x0]
    cbz x1, .Lpi4_board_scan_done
    adr x0, pi4_status_pi4dtb_struct_off
    ldr x9, [x0]
    adr x0, pi4_status_pi4dtb_struct_size
    ldr x10, [x0]
    add x11, x20, x9
    add x2, x11, x10
    adr x0, pi4_status_pi4dtb_strings_off
    ldr x9, [x0]
    adr x0, pi4_status_pi4dtb_strings_size
    ldr x10, [x0]
    add x3, x20, x9
    add x4, x3, x10

    add x5, x1, #8
    mov w6, wzr
    mov w7, wzr

.Lpi4_board_scan_loop:
    add x9, x5, #4
    cmp x9, x2
    b.hi .Lpi4_board_scan_done
    ldr w8, [x5]
    rev w8, w8
    add x5, x5, #4

    cmp w8, #PI4_FDT_PROP
    b.eq .Lpi4_board_scan_prop
    cmp w8, #PI4_FDT_NOP
    b.eq .Lpi4_board_scan_loop
    b .Lpi4_board_scan_done

.Lpi4_board_scan_prop:
    add x9, x5, #8
    cmp x9, x2
    b.hi .Lpi4_board_scan_done
    ldr w9, [x5]
    rev w9, w9
    ldr w10, [x5, #4]
    rev w10, w10
    add x11, x5, #8
    uxtw x12, w9
    add x12, x12, #3
    bic x12, x12, #3
    add x13, x11, x12
    cmp x13, x2
    b.hi .Lpi4_board_scan_done

    uxtw x12, w10
    add x14, x3, x12
    cmp x14, x4
    b.hs .Lpi4_board_scan_skip_prop

    add x15, x14, #6
    cmp x15, x4
    b.hi .Lpi4_board_scan_check_compatible
    ldrb w15, [x14]
    cmp w15, #'m'
    b.ne .Lpi4_board_scan_check_compatible
    ldrb w15, [x14, #1]
    cmp w15, #'o'
    b.ne .Lpi4_board_scan_check_compatible
    ldrb w15, [x14, #2]
    cmp w15, #'d'
    b.ne .Lpi4_board_scan_check_compatible
    ldrb w15, [x14, #3]
    cmp w15, #'e'
    b.ne .Lpi4_board_scan_check_compatible
    ldrb w15, [x14, #4]
    cmp w15, #'l'
    b.ne .Lpi4_board_scan_check_compatible
    ldrb w15, [x14, #5]
    cbnz w15, .Lpi4_board_scan_check_compatible
    cbnz w6, .Lpi4_board_scan_skip_prop
    mov w14, #1
    b .Lpi4_board_scan_hash_value

.Lpi4_board_scan_check_compatible:
    add x15, x14, #11
    cmp x15, x4
    b.hi .Lpi4_board_scan_skip_prop
    ldrb w15, [x14]
    cmp w15, #'c'
    b.ne .Lpi4_board_scan_skip_prop
    ldrb w15, [x14, #1]
    cmp w15, #'o'
    b.ne .Lpi4_board_scan_skip_prop
    ldrb w15, [x14, #2]
    cmp w15, #'m'
    b.ne .Lpi4_board_scan_skip_prop
    ldrb w15, [x14, #3]
    cmp w15, #'p'
    b.ne .Lpi4_board_scan_skip_prop
    ldrb w15, [x14, #4]
    cmp w15, #'a'
    b.ne .Lpi4_board_scan_skip_prop
    ldrb w15, [x14, #5]
    cmp w15, #'t'
    b.ne .Lpi4_board_scan_skip_prop
    ldrb w15, [x14, #6]
    cmp w15, #'i'
    b.ne .Lpi4_board_scan_skip_prop
    ldrb w15, [x14, #7]
    cmp w15, #'b'
    b.ne .Lpi4_board_scan_skip_prop
    ldrb w15, [x14, #8]
    cmp w15, #'l'
    b.ne .Lpi4_board_scan_skip_prop
    ldrb w15, [x14, #9]
    cmp w15, #'e'
    b.ne .Lpi4_board_scan_skip_prop
    ldrb w15, [x14, #10]
    cbnz w15, .Lpi4_board_scan_skip_prop
    cbnz w7, .Lpi4_board_scan_skip_prop
    mov w14, #2

.Lpi4_board_scan_hash_value:
    mov x0, #5381
    mov x15, x11
    uxtw x16, w9
    cbz x16, .Lpi4_board_scan_hash_done
.Lpi4_board_scan_hash_loop:
    ldrb w17, [x15], #1
    lsl x12, x0, #5
    sub x0, x12, x0
    add x0, x0, x17
    subs x16, x16, #1
    b.ne .Lpi4_board_scan_hash_loop
.Lpi4_board_scan_hash_done:
    cmp w14, #1
    b.eq .Lpi4_board_scan_store_model

    adr x15, pi4_status_pi4compat_ptr
    str x11, [x15]
    adr x15, pi4_status_pi4compat_len
    uxtw x16, w9
    str x16, [x15]
    adr x15, pi4_status_pi4compat_hash
    str x0, [x15]
    mov w7, #1
    b .Lpi4_board_scan_check_complete

.Lpi4_board_scan_store_model:
    adr x15, pi4_status_pi4model_ptr
    str x11, [x15]
    adr x15, pi4_status_pi4model_len
    uxtw x16, w9
    str x16, [x15]
    adr x15, pi4_status_pi4model_hash
    str x0, [x15]
    mov w6, #1

.Lpi4_board_scan_check_complete:
    cbz w6, .Lpi4_board_scan_skip_prop
    cbz w7, .Lpi4_board_scan_skip_prop
    adr x15, pi4_status_pi4boarddtb
    ldr w16, =VIBE_PI4_STATUS_PI4BOARDDTB_OK
    str w16, [x15]
    ret

.Lpi4_board_scan_skip_prop:
    mov x5, x13
    b .Lpi4_board_scan_loop

.Lpi4_board_scan_done:
    ret
.size pi4_scan_board_identity, . - pi4_scan_board_identity

.type pi4_uart_write_string, %function
pi4_uart_write_string:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x19, [sp, #16]
    mov x19, x0

.Lwrite_string_next:
    ldrb w0, [x19], #1
    cbz w0, .Lwrite_string_done
    bl pi4_uart_putc
    b .Lwrite_string_next

.Lwrite_string_done:
    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size pi4_uart_write_string, . - pi4_uart_write_string

.type pi4_uart_write_newline, %function
pi4_uart_write_newline:
    mov w0, #'\n'
    b pi4_uart_putc
.size pi4_uart_write_newline, . - pi4_uart_write_newline

.type pi4_uart_write_hex64, %function
pi4_uart_write_hex64:
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    str x21, [sp, #32]
    mov x19, x0

    mov w0, #'0'
    bl pi4_uart_putc
    mov w0, #'x'
    bl pi4_uart_putc
    mov x20, #16

.Lhex_next:
    lsr x21, x19, #60
    cmp x21, #10
    b.lo .Lhex_digit
    add w0, w21, #('a' - 10)
    b .Lhex_emit
.Lhex_digit:
    add w0, w21, #'0'
.Lhex_emit:
    bl pi4_uart_putc
    lsl x19, x19, #4
    subs x20, x20, #1
    b.ne .Lhex_next

    ldr x21, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret
.size pi4_uart_write_hex64, . - pi4_uart_write_hex64

.type pi4_uart_putc, %function
pi4_uart_putc:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    cmp w0, #'\n'
    b.ne .Lputc_raw
    mov w0, #'\r'
    bl pi4_uart_putc_raw
    mov w0, #'\n'
.Lputc_raw:
    bl pi4_uart_putc_raw
    ldp x29, x30, [sp], #16
    ret
.size pi4_uart_putc, . - pi4_uart_putc

.type pi4_uart_putc_raw, %function
pi4_uart_putc_raw:
    ldr x1, =PI4_UART0_FR
.Lputc_wait:
    ldr w2, [x1]
    tbnz w2, #PI4_UART_FR_TXFF, .Lputc_wait
    ldr x1, =PI4_UART0_DR
    str w0, [x1]
    ret
.size pi4_uart_putc_raw, . - pi4_uart_putc_raw

.type pi4_validate_el0_user_range, %function
pi4_validate_el0_user_range:
    adr x2, pi4_status_svc_runtime_ptr_check_count
    ldr x3, [x2]
    add x3, x3, #1
    str x3, [x2]
    adr x2, pi4_status_svc_runtime_ptr_last_base
    str x0, [x2]
    adr x2, pi4_status_svc_runtime_ptr_last_bytes
    str x1, [x2]

    cbz x0, .Lpi4_user_range_bad
    cbz x1, .Lpi4_user_range_bad
    sub x2, x1, #1
    adds x2, x0, x2
    b.cs .Lpi4_user_range_bad

    adr x3, pi4_status_pi4el0_image_base
    ldr x3, [x3]
    adr x4, pi4_status_pi4el0_image_end
    ldr x4, [x4]
    cbz x3, .Lpi4_user_range_check_elf
    cmp x4, x3
    b.ls .Lpi4_user_range_check_elf
    cmp x0, x3
    b.lo .Lpi4_user_range_check_elf
    cmp x2, x4
    b.lo .Lpi4_user_range_ok

.Lpi4_user_range_check_elf:
    adr x3, pi4_status_pi4elf_load_vaddr
    ldr x3, [x3]
    adr x4, pi4_status_pi4elf_load_memsz
    ldr x4, [x4]
    cbz x3, .Lpi4_user_range_check_stack_alloc
    cbz x4, .Lpi4_user_range_check_stack_alloc
    adds x4, x3, x4
    b.cs .Lpi4_user_range_check_stack_alloc
    cmp x0, x3
    b.lo .Lpi4_user_range_check_stack_alloc
    cmp x2, x4
    b.lo .Lpi4_user_range_ok

.Lpi4_user_range_check_stack_alloc:
    adr x3, pi4_status_pi4el0_stack_base
    ldr x3, [x3]
    adr x4, pi4_status_pi4el0_stack_top
    ldr x4, [x4]
    cbz x3, .Lpi4_user_range_check_stack_active
    cmp x4, x3
    b.ls .Lpi4_user_range_check_stack_active
    cmp x0, x3
    b.lo .Lpi4_user_range_check_stack_active
    cmp x2, x4
    b.lo .Lpi4_user_range_ok

.Lpi4_user_range_check_stack_active:
    adr x3, pi4_status_pi4ustack_sp
    ldr x3, [x3]
    adr x4, pi4_status_pi4ustack_top
    ldr x4, [x4]
    cbz x3, .Lpi4_user_range_bad
    cmp x4, x3
    b.ls .Lpi4_user_range_bad
    cmp x0, x3
    b.lo .Lpi4_user_range_bad
    cmp x2, x4
    b.hs .Lpi4_user_range_bad

.Lpi4_user_range_ok:
    mov x0, #1
    ret

.Lpi4_user_range_bad:
    adr x2, pi4_status_svc_runtime_ptr_bad_count
    ldr x3, [x2]
    add x3, x3, #1
    str x3, [x2]
    mov x0, xzr
    ret
.size pi4_validate_el0_user_range, . - pi4_validate_el0_user_range

.type pi4_kernel_el0_path_eq16, %function
pi4_kernel_el0_path_eq16:
    mov x2, xzr
.Lpi4_kernel_el0_path_eq16_next:
    ldrb w3, [x0, x2]
    ldrb w4, [x1, x2]
    sub w5, w3, #0x61
    cmp w5, #25
    b.hi .Lpi4_kernel_el0_path_eq16_left_folded
    sub w3, w3, #0x20
.Lpi4_kernel_el0_path_eq16_left_folded:
    sub w5, w4, #0x61
    cmp w5, #25
    b.hi .Lpi4_kernel_el0_path_eq16_right_folded
    sub w4, w4, #0x20
.Lpi4_kernel_el0_path_eq16_right_folded:
    cmp w3, w4
    b.ne .Lpi4_kernel_el0_path_eq16_no
    cbz w4, .Lpi4_kernel_el0_path_eq16_yes
    add x2, x2, #1
    cmp x2, #PI4_VIBE_FILE_PATH_MAX_BYTES
    b.lo .Lpi4_kernel_el0_path_eq16_next
.Lpi4_kernel_el0_path_eq16_no:
    mov x0, xzr
    ret
.Lpi4_kernel_el0_path_eq16_yes:
    mov x0, #1
    ret
.size pi4_kernel_el0_path_eq16, . - pi4_kernel_el0_path_eq16

.type pi4_kernel_el0_asset_suffix_eq16, %function
pi4_kernel_el0_asset_suffix_eq16:
    cbz x0, .Lpi4_kernel_el0_asset_suffix_eq16_no
    cbz x1, .Lpi4_kernel_el0_asset_suffix_eq16_no
    mov x9, x0
    mov x10, x1
    mov x11, xzr
.Lpi4_kernel_el0_asset_suffix_path_len_next:
    cmp x11, #PI4_VIBE_FILE_PATH_MAX_BYTES
    b.hs .Lpi4_kernel_el0_asset_suffix_eq16_no
    ldrb w12, [x9, x11]
    cbz w12, .Lpi4_kernel_el0_asset_suffix_path_len_done
    add x11, x11, #1
    b .Lpi4_kernel_el0_asset_suffix_path_len_next
.Lpi4_kernel_el0_asset_suffix_path_len_done:
    mov x12, xzr
.Lpi4_kernel_el0_asset_suffix_len_next:
    cmp x12, #PI4_VIBE_FILE_PATH_MAX_BYTES
    b.hs .Lpi4_kernel_el0_asset_suffix_eq16_no
    ldrb w13, [x10, x12]
    cbz w13, .Lpi4_kernel_el0_asset_suffix_len_done
    add x12, x12, #1
    b .Lpi4_kernel_el0_asset_suffix_len_next
.Lpi4_kernel_el0_asset_suffix_len_done:
    cbz x12, .Lpi4_kernel_el0_asset_suffix_eq16_no
    cmp x11, x12
    b.lo .Lpi4_kernel_el0_asset_suffix_eq16_no
    sub x13, x11, x12
    cbz x13, .Lpi4_kernel_el0_asset_suffix_compare
    sub x14, x13, #1
    ldrb w15, [x9, x14]
    cmp w15, #0x2f
    b.eq .Lpi4_kernel_el0_asset_suffix_compare
    cmp w15, #0x5c
    b.ne .Lpi4_kernel_el0_asset_suffix_eq16_no

.Lpi4_kernel_el0_asset_suffix_compare:
    mov x14, xzr
.Lpi4_kernel_el0_asset_suffix_compare_next:
    cmp x14, x12
    b.hs .Lpi4_kernel_el0_asset_suffix_eq16_yes
    ldrb w15, [x9, x13]
    ldrb w16, [x10, x14]
    cmp w15, #0x5c
    b.ne .Lpi4_kernel_el0_asset_suffix_left_sep_folded
    mov w15, #0x2f
.Lpi4_kernel_el0_asset_suffix_left_sep_folded:
    cmp w16, #0x5c
    b.ne .Lpi4_kernel_el0_asset_suffix_right_sep_folded
    mov w16, #0x2f
.Lpi4_kernel_el0_asset_suffix_right_sep_folded:
    sub w17, w15, #0x61
    cmp w17, #25
    b.hi .Lpi4_kernel_el0_asset_suffix_left_case_folded
    sub w15, w15, #0x20
.Lpi4_kernel_el0_asset_suffix_left_case_folded:
    sub w17, w16, #0x61
    cmp w17, #25
    b.hi .Lpi4_kernel_el0_asset_suffix_right_case_folded
    sub w16, w16, #0x20
.Lpi4_kernel_el0_asset_suffix_right_case_folded:
    cmp w15, w16
    b.ne .Lpi4_kernel_el0_asset_suffix_eq16_no
    add x13, x13, #1
    add x14, x14, #1
    b .Lpi4_kernel_el0_asset_suffix_compare_next
.Lpi4_kernel_el0_asset_suffix_eq16_yes:
    mov x0, #1
    ret
.Lpi4_kernel_el0_asset_suffix_eq16_no:
    mov x0, xzr
    ret
.size pi4_kernel_el0_asset_suffix_eq16, . - pi4_kernel_el0_asset_suffix_eq16

.type pi4_kernel_el0_app_path_match, %function
pi4_kernel_el0_app_path_match:
    cbz x0, .Lpi4_kernel_el0_app_path_match_no
    cbz x1, .Lpi4_kernel_el0_app_path_match_no
    cbz x2, .Lpi4_kernel_el0_app_path_match_no
    ldrb w3, [x1]
    cbz w3, .Lpi4_kernel_el0_app_path_match_no
    cmp w3, #0x20
    b.eq .Lpi4_kernel_el0_app_path_match_no

    mov x3, x0
    adr x4, pi4_apps_path_prefix_string
.Lpi4_kernel_el0_app_path_match_prefix:
    ldrb w5, [x4], #1
    cbz w5, .Lpi4_kernel_el0_app_path_match_component
    ldrb w6, [x3], #1
    cbz w6, .Lpi4_kernel_el0_app_path_match_no
    cmp w6, #0x5c
    b.ne .Lpi4_kernel_el0_app_path_match_prefix_fold
    mov w6, #0x2f
.Lpi4_kernel_el0_app_path_match_prefix_fold:
    cmp w6, #0x61
    b.lo .Lpi4_kernel_el0_app_path_match_prefix_cmp
    cmp w6, #0x7a
    b.hi .Lpi4_kernel_el0_app_path_match_prefix_cmp
    sub w6, w6, #0x20
.Lpi4_kernel_el0_app_path_match_prefix_cmp:
    cmp w6, w5
    b.ne .Lpi4_kernel_el0_app_path_match_no
    b .Lpi4_kernel_el0_app_path_match_prefix

.Lpi4_kernel_el0_app_path_match_component:
    mov x4, x1
    mov x7, xzr
.Lpi4_kernel_el0_app_path_match_component_next:
    cmp x7, #8
    b.hs .Lpi4_kernel_el0_app_path_match_component_end
    ldrb w5, [x4, x7]
    cmp w5, #0x20
    b.eq .Lpi4_kernel_el0_app_path_match_padding
    cbz w5, .Lpi4_kernel_el0_app_path_match_padding
    ldrb w6, [x3]
    cbz w6, .Lpi4_kernel_el0_app_path_match_no
    cmp w6, #0x2f
    b.eq .Lpi4_kernel_el0_app_path_match_no
    cmp w6, #0x5c
    b.eq .Lpi4_kernel_el0_app_path_match_no
    cmp w6, #0x61
    b.lo .Lpi4_kernel_el0_app_path_match_component_cmp
    cmp w6, #0x7a
    b.hi .Lpi4_kernel_el0_app_path_match_component_cmp
    sub w6, w6, #0x20
.Lpi4_kernel_el0_app_path_match_component_cmp:
    cmp w6, w5
    b.ne .Lpi4_kernel_el0_app_path_match_no
    add x3, x3, #1
    add x7, x7, #1
    b .Lpi4_kernel_el0_app_path_match_component_next

.Lpi4_kernel_el0_app_path_match_padding:
    ldrb w6, [x3]
    cmp w6, #0x2f
    b.eq .Lpi4_kernel_el0_app_path_match_padding_check
    cmp w6, #0x5c
    b.eq .Lpi4_kernel_el0_app_path_match_padding_check
    b .Lpi4_kernel_el0_app_path_match_no
.Lpi4_kernel_el0_app_path_match_padding_check:
    cmp x7, #8
    b.hs .Lpi4_kernel_el0_app_path_match_component_slash
    ldrb w5, [x4, x7]
    cbz w5, .Lpi4_kernel_el0_app_path_match_component_slash
    cmp w5, #0x20
    b.ne .Lpi4_kernel_el0_app_path_match_no
    add x7, x7, #1
    b .Lpi4_kernel_el0_app_path_match_padding_check

.Lpi4_kernel_el0_app_path_match_component_end:
    ldrb w6, [x3]
    cmp w6, #0x2f
    b.eq .Lpi4_kernel_el0_app_path_match_component_slash
    cmp w6, #0x5c
    b.ne .Lpi4_kernel_el0_app_path_match_no
.Lpi4_kernel_el0_app_path_match_component_slash:
    add x3, x3, #1
    mov x8, #16
.Lpi4_kernel_el0_app_path_match_leaf:
    cbz x8, .Lpi4_kernel_el0_app_path_match_no
    sub x8, x8, #1
    ldrb w5, [x2], #1
    ldrb w6, [x3], #1
    cbz w5, .Lpi4_kernel_el0_app_path_match_leaf_end
    cbz w6, .Lpi4_kernel_el0_app_path_match_no
    cmp w6, #0x61
    b.lo .Lpi4_kernel_el0_app_path_match_leaf_cmp
    cmp w6, #0x7a
    b.hi .Lpi4_kernel_el0_app_path_match_leaf_cmp
    sub w6, w6, #0x20
.Lpi4_kernel_el0_app_path_match_leaf_cmp:
    cmp w6, w5
    b.ne .Lpi4_kernel_el0_app_path_match_no
    b .Lpi4_kernel_el0_app_path_match_leaf
.Lpi4_kernel_el0_app_path_match_leaf_end:
    cbnz w6, .Lpi4_kernel_el0_app_path_match_no
    mov x0, #1
    ret
.Lpi4_kernel_el0_app_path_match_no:
    mov x0, xzr
    ret
.size pi4_kernel_el0_app_path_match, . - pi4_kernel_el0_app_path_match

.type pi4_kernel_el0_strlen_bounded, %function
pi4_kernel_el0_strlen_bounded:
    cbz x0, .Lpi4_kernel_el0_strlen_bounded_bad
    cbz x1, .Lpi4_kernel_el0_strlen_bounded_bad
    mov x2, xzr
.Lpi4_kernel_el0_strlen_bounded_next:
    cmp x2, x1
    b.hs .Lpi4_kernel_el0_strlen_bounded_bad
    ldrb w3, [x0, x2]
    cbz w3, .Lpi4_kernel_el0_strlen_bounded_done
    add x2, x2, #1
    b .Lpi4_kernel_el0_strlen_bounded_next
.Lpi4_kernel_el0_strlen_bounded_done:
    mov x0, x2
    ret
.Lpi4_kernel_el0_strlen_bounded_bad:
    mov x0, #-1
    ret
.size pi4_kernel_el0_strlen_bounded, . - pi4_kernel_el0_strlen_bounded

.type pi4_kernel_copy_string_bounded, %function
pi4_kernel_copy_string_bounded:
    cbz x0, .Lpi4_kernel_copy_string_bounded_bad
    cbz x1, .Lpi4_kernel_copy_string_bounded_bad
    cmp x2, #PI4_VIBE_FILE_PATH_MAX_BYTES
    b.hs .Lpi4_kernel_copy_string_bounded_bad
    mov x3, xzr
.Lpi4_kernel_copy_string_bounded_next:
    ldrb w4, [x0, x3]
    strb w4, [x1, x3]
    cmp x3, x2
    b.eq .Lpi4_kernel_copy_string_bounded_done
    add x3, x3, #1
    b .Lpi4_kernel_copy_string_bounded_next
.Lpi4_kernel_copy_string_bounded_done:
    mov x0, #1
    ret
.Lpi4_kernel_copy_string_bounded_bad:
    mov x0, xzr
    ret
.size pi4_kernel_copy_string_bounded, . - pi4_kernel_copy_string_bounded

.type pi4_copy_argv0_to_user_stack, %function
pi4_copy_argv0_to_user_stack:
    stp x2, x3, [sp, #-16]!
    cbz x0, .Lpi4_copy_argv0_to_user_stack_done
    cbz x1, .Lpi4_copy_argv0_to_user_stack_done
    mov x2, xzr
.Lpi4_copy_argv0_to_user_stack_next:
    ldrb w3, [x1, x2]
    strb w3, [x0, x2]
    cbz w3, .Lpi4_copy_argv0_to_user_stack_done
    add x2, x2, #1
    cmp x2, #(PI4_EL0_STACK_ARGV0_BYTES - 1)
    b.lo .Lpi4_copy_argv0_to_user_stack_next
    strb wzr, [x0, x2]
.Lpi4_copy_argv0_to_user_stack_done:
    ldp x2, x3, [sp], #16
    ret
.size pi4_copy_argv0_to_user_stack, . - pi4_copy_argv0_to_user_stack

.type pi4_user_file_metadata_is_valid, %function
pi4_user_file_metadata_is_valid:
    cbz x0, .Lpi4_user_file_metadata_bad
    ldr x1, [x0, #16]
    cmp x1, #2
    b.lo .Lpi4_user_file_metadata_bad
    ldr x1, [x0, #24]
    cbz x1, .Lpi4_user_file_metadata_bad
    ldr x1, [x0, #32]
    cbz x1, .Lpi4_user_file_metadata_bad
    ldr x1, [x0, #40]
    cbz x1, .Lpi4_user_file_metadata_bad
    ldr x1, [x0, #48]
    cbz x1, .Lpi4_user_file_metadata_bad
    mov x0, #1
    ret
.Lpi4_user_file_metadata_bad:
    mov x0, xzr
    ret
.size pi4_user_file_metadata_is_valid, . - pi4_user_file_metadata_is_valid

.type pi4_app_record_ptr_by_index, %function
pi4_app_record_ptr_by_index:
    cmp x0, #PI4_VIBE_APP_RECORD_COUNT
    b.hs .Lpi4_app_record_ptr_bad
    adr x1, pi4_app_file_record_table
    mov x2, #PI4_VIBE_APP_RECORD_BYTES
    madd x0, x0, x2, x1
    ret
.Lpi4_app_record_ptr_bad:
    mov x0, xzr
    ret
.size pi4_app_record_ptr_by_index, . - pi4_app_record_ptr_by_index

.type pi4_app_index_from_elf_asset, %function
pi4_app_index_from_elf_asset:
    mov x1, #PI4_VIBE_FILE_ASSET_APP_ELF_BASE
    cmp x0, x1
    b.lo .Lpi4_app_index_from_elf_asset_bad
    sub x0, x0, x1
    cmp x0, #PI4_VIBE_FILE_ASSET_APP_ELF_COUNT
    b.hs .Lpi4_app_index_from_elf_asset_bad
    ret
.Lpi4_app_index_from_elf_asset_bad:
    mov x0, xzr
    ret
.size pi4_app_index_from_elf_asset, . - pi4_app_index_from_elf_asset

.type pi4_user_file_lookup_app_path, %function
pi4_user_file_lookup_app_path:
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    str x23, [sp, #48]
    mov x19, x0
    mov x20, x1
    mov x21, x2
    adr x23, pi4_app_file_record_table
    mov x22, xzr
.Lpi4_lookup_app_path_next:
    cmp x22, #PI4_VIBE_APP_RECORD_COUNT
    b.hs .Lpi4_lookup_app_path_none
    ldr x0, [x23, #PI4_VIBE_APP_RECORD_DIR_STATUS]
    ldr x0, [x0]
    cbz x0, .Lpi4_lookup_app_path_step
    mov x0, x19
    ldr x1, [x23, #PI4_VIBE_APP_RECORD_DIR_NAME]
    mov x2, x20
    bl pi4_kernel_el0_app_path_match
    cbnz x0, .Lpi4_lookup_app_path_match
.Lpi4_lookup_app_path_step:
    add x23, x23, #PI4_VIBE_APP_RECORD_BYTES
    add x22, x22, #1
    b .Lpi4_lookup_app_path_next

.Lpi4_lookup_app_path_match:
    cbnz x21, .Lpi4_lookup_app_path_elf
    ldr x0, [x23, #PI4_VIBE_APP_RECORD_MANIFEST_META]
    mov x1, #PI4_VIBE_FILE_ASSET_APP_MANIFEST_BASE
    add x1, x1, x22
    ldr x2, [x23, #PI4_VIBE_APP_RECORD_MANIFEST_OFFSET]
    mov x3, #PI4_VIBE_FD_APP_MANIFEST_BASE
    add x3, x3, x22
    b .Lpi4_lookup_app_path_done

.Lpi4_lookup_app_path_elf:
    ldr x0, [x23, #PI4_VIBE_APP_RECORD_ELF_META]
    mov x1, #PI4_VIBE_FILE_ASSET_APP_ELF_BASE
    add x1, x1, x22
    ldr x2, [x23, #PI4_VIBE_APP_RECORD_ELF_OFFSET]
    mov x3, #PI4_VIBE_FD_APP_ELF_BASE
    add x3, x3, x22
    b .Lpi4_lookup_app_path_done

.Lpi4_lookup_app_path_none:
    mov x0, xzr
    mov x1, xzr
    mov x2, xzr
    mov x3, xzr

.Lpi4_lookup_app_path_done:
    ldr x23, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret
.size pi4_user_file_lookup_app_path, . - pi4_user_file_lookup_app_path

.type pi4_user_file_lookup_app_fd, %function
pi4_user_file_lookup_app_fd:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    mov x4, #PI4_VIBE_FD_APP_MANIFEST_BASE
    cmp x0, x4
    b.lo .Lpi4_user_file_lookup_app_fd_check_elf
    sub x5, x0, x4
    cmp x5, #PI4_VIBE_FD_APP_MANIFEST_COUNT
    b.lo .Lpi4_user_file_lookup_app_fd_manifest

.Lpi4_user_file_lookup_app_fd_check_elf:
    mov x4, #PI4_VIBE_FD_APP_ELF_BASE
    cmp x0, x4
    b.lo .Lpi4_user_file_lookup_app_fd_none
    sub x5, x0, x4
    cmp x5, #PI4_VIBE_FD_APP_ELF_COUNT
    b.hs .Lpi4_user_file_lookup_app_fd_none
    mov x6, x5
    mov x0, x5
    bl pi4_app_record_ptr_by_index
    cbz x0, .Lpi4_user_file_lookup_app_fd_none
    mov x7, x0
    ldr x0, [x7, #PI4_VIBE_APP_RECORD_ELF_META]
    mov x1, #PI4_VIBE_FILE_ASSET_APP_ELF_BASE
    add x1, x1, x6
    ldr x2, [x7, #PI4_VIBE_APP_RECORD_ELF_OFFSET]
    mov x3, #PI4_VIBE_FD_APP_ELF_BASE
    add x3, x3, x6
    b .Lpi4_user_file_lookup_app_fd_done

.Lpi4_user_file_lookup_app_fd_manifest:
    mov x6, x5
    mov x0, x5
    bl pi4_app_record_ptr_by_index
    cbz x0, .Lpi4_user_file_lookup_app_fd_none
    mov x7, x0
    ldr x0, [x7, #PI4_VIBE_APP_RECORD_MANIFEST_META]
    mov x1, #PI4_VIBE_FILE_ASSET_APP_MANIFEST_BASE
    add x1, x1, x6
    ldr x2, [x7, #PI4_VIBE_APP_RECORD_MANIFEST_OFFSET]
    mov x3, #PI4_VIBE_FD_APP_MANIFEST_BASE
    add x3, x3, x6
    b .Lpi4_user_file_lookup_app_fd_done

.Lpi4_user_file_lookup_app_fd_none:
    mov x0, xzr
    mov x1, xzr
    mov x2, xzr
    mov x3, xzr
.Lpi4_user_file_lookup_app_fd_done:
    ldp x29, x30, [sp], #16
    ret
.size pi4_user_file_lookup_app_fd, . - pi4_user_file_lookup_app_fd

.type pi4_user_file_lookup_path, %function
pi4_user_file_lookup_path:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x19, [sp, #16]
    mov x19, x0

    adr x1, pi4_app_elf_leaf_string
    mov x2, #1
    bl pi4_user_file_lookup_app_path
    cbnz x0, .Lpi4_user_file_lookup_path_done
    mov x0, x19
    adr x1, pi4_app_index_path_string
    bl pi4_kernel_el0_asset_suffix_eq16
    cbnz x0, .Lpi4_user_file_lookup_path_app_index
    mov x0, x19
    adr x1, pi4_app_manifest_leaf_string
    mov x2, xzr
    bl pi4_user_file_lookup_app_path
    cbnz x0, .Lpi4_user_file_lookup_path_done
    mov x0, x19
    adr x1, pi4_user_file_doom1_path
    bl pi4_kernel_el0_asset_suffix_eq16
    cbnz x0, .Lpi4_user_file_lookup_path_doom
    mov x0, x19
    adr x1, pi4_user_file_pak0_suffix
    bl pi4_kernel_el0_asset_suffix_eq16
    cbnz x0, .Lpi4_user_file_lookup_path_pak
    mov x0, x19
    adr x1, pi4_user_file_manifest_suffix
    bl pi4_kernel_el0_asset_suffix_eq16
    cbnz x0, .Lpi4_user_file_lookup_path_manifest
    mov x0, x19
    adr x1, pi4_user_file_readme_suffix
    bl pi4_kernel_el0_asset_suffix_eq16
    cbnz x0, .Lpi4_user_file_lookup_path_readme
    mov x0, x19
    adr x1, pi4_user_file_map_suffix
    bl pi4_kernel_el0_asset_suffix_eq16
    cbnz x0, .Lpi4_user_file_lookup_path_map
    mov x0, x19
    adr x1, pi4_user_file_palette_suffix
    bl pi4_kernel_el0_asset_suffix_eq16
    cbnz x0, .Lpi4_user_file_lookup_path_palette
    b .Lpi4_user_file_lookup_none

.Lpi4_user_file_lookup_path_doom:
    adr x0, pi4_storage_status_doom1_wad
    mov x1, #PI4_VIBE_FILE_ASSET_DOOM1_WAD
    adr x2, pi4_status_pi4userfile_doom_offset
    mov x3, #PI4_VIBE_FD_DOOM1_WAD
    b .Lpi4_user_file_lookup_path_done
.Lpi4_user_file_lookup_path_pak:
    adr x0, pi4_storage_status_pak0_pak
    mov x1, #PI4_VIBE_FILE_ASSET_PAK0_PAK
    adr x2, pi4_status_pi4userfile_pak_offset
    mov x3, #PI4_VIBE_FD_PAK0_PAK
    b .Lpi4_user_file_lookup_path_done
.Lpi4_user_file_lookup_path_manifest:
    adr x0, pi4_storage_status_manifest_txt
    mov x1, #PI4_VIBE_FILE_ASSET_MANIFEST_TXT
    adr x2, pi4_status_pi4userfile_manifest_offset
    mov x3, #PI4_VIBE_FD_MANIFEST_TXT
    b .Lpi4_user_file_lookup_path_done
.Lpi4_user_file_lookup_path_readme:
    adr x0, pi4_storage_status_asset_readme
    mov x1, #PI4_VIBE_FILE_ASSET_README_TXT
    adr x2, pi4_status_pi4userfile_readme_offset
    mov x3, #PI4_VIBE_FD_ASSET_README
    b .Lpi4_user_file_lookup_path_done
.Lpi4_user_file_lookup_path_map:
    adr x0, pi4_storage_status_asset_map
    mov x1, #PI4_VIBE_FILE_ASSET_E1M1_MAP
    adr x2, pi4_status_pi4userfile_map_offset
    mov x3, #PI4_VIBE_FD_ASSET_MAP
    b .Lpi4_user_file_lookup_path_done
.Lpi4_user_file_lookup_path_palette:
    adr x0, pi4_storage_status_asset_palette
    mov x1, #PI4_VIBE_FILE_ASSET_PAL0_BIN
    adr x2, pi4_status_pi4userfile_palette_offset
    mov x3, #PI4_VIBE_FD_ASSET_PALETTE
    b .Lpi4_user_file_lookup_path_done
.Lpi4_user_file_lookup_path_app_index:
    adr x0, pi4_storage_status_app_index
    mov x1, #PI4_VIBE_FILE_ASSET_APP_INDEX
    adr x2, pi4_status_pi4userfile_app_index_offset
    mov x3, #PI4_VIBE_FD_APP_INDEX
    b .Lpi4_user_file_lookup_path_done
.Lpi4_user_file_lookup_none:
    mov x0, xzr
    mov x1, xzr
    mov x2, xzr
    mov x3, xzr

.Lpi4_user_file_lookup_path_done:
    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size pi4_user_file_lookup_path, . - pi4_user_file_lookup_path

.type pi4_user_file_lookup_fd, %function
pi4_user_file_lookup_fd:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    cmp x0, #PI4_VIBE_FD_DOOM1_WAD
    b.eq .Lpi4_user_file_lookup_fd_doom
    cmp x0, #PI4_VIBE_FD_PAK0_PAK
    b.eq .Lpi4_user_file_lookup_fd_pak
    cmp x0, #PI4_VIBE_FD_MANIFEST_TXT
    b.eq .Lpi4_user_file_lookup_fd_manifest
    cmp x0, #PI4_VIBE_FD_ASSET_README
    b.eq .Lpi4_user_file_lookup_fd_readme
    cmp x0, #PI4_VIBE_FD_ASSET_MAP
    b.eq .Lpi4_user_file_lookup_fd_map
    cmp x0, #PI4_VIBE_FD_ASSET_PALETTE
    b.eq .Lpi4_user_file_lookup_fd_palette
    cmp x0, #PI4_VIBE_FD_APP_INDEX
    b.eq .Lpi4_user_file_lookup_fd_app_index
    bl pi4_user_file_lookup_app_fd
    cbnz x0, .Lpi4_user_file_lookup_fd_done
    mov x0, xzr
    mov x1, xzr
    mov x2, xzr
    mov x3, xzr
.Lpi4_user_file_lookup_fd_done:
    ldp x29, x30, [sp], #16
    ret
.Lpi4_user_file_lookup_fd_doom:
    adr x0, pi4_storage_status_doom1_wad
    mov x1, #PI4_VIBE_FILE_ASSET_DOOM1_WAD
    adr x2, pi4_status_pi4userfile_doom_offset
    mov x3, #PI4_VIBE_FD_DOOM1_WAD
    b .Lpi4_user_file_lookup_fd_done
.Lpi4_user_file_lookup_fd_pak:
    adr x0, pi4_storage_status_pak0_pak
    mov x1, #PI4_VIBE_FILE_ASSET_PAK0_PAK
    adr x2, pi4_status_pi4userfile_pak_offset
    mov x3, #PI4_VIBE_FD_PAK0_PAK
    b .Lpi4_user_file_lookup_fd_done
.Lpi4_user_file_lookup_fd_manifest:
    adr x0, pi4_storage_status_manifest_txt
    mov x1, #PI4_VIBE_FILE_ASSET_MANIFEST_TXT
    adr x2, pi4_status_pi4userfile_manifest_offset
    mov x3, #PI4_VIBE_FD_MANIFEST_TXT
    b .Lpi4_user_file_lookup_fd_done
.Lpi4_user_file_lookup_fd_readme:
    adr x0, pi4_storage_status_asset_readme
    mov x1, #PI4_VIBE_FILE_ASSET_README_TXT
    adr x2, pi4_status_pi4userfile_readme_offset
    mov x3, #PI4_VIBE_FD_ASSET_README
    b .Lpi4_user_file_lookup_fd_done
.Lpi4_user_file_lookup_fd_map:
    adr x0, pi4_storage_status_asset_map
    mov x1, #PI4_VIBE_FILE_ASSET_E1M1_MAP
    adr x2, pi4_status_pi4userfile_map_offset
    mov x3, #PI4_VIBE_FD_ASSET_MAP
    b .Lpi4_user_file_lookup_fd_done
.Lpi4_user_file_lookup_fd_palette:
    adr x0, pi4_storage_status_asset_palette
    mov x1, #PI4_VIBE_FILE_ASSET_PAL0_BIN
    adr x2, pi4_status_pi4userfile_palette_offset
    mov x3, #PI4_VIBE_FD_ASSET_PALETTE
    b .Lpi4_user_file_lookup_fd_done
.Lpi4_user_file_lookup_fd_app_index:
    adr x0, pi4_storage_status_app_index
    mov x1, #PI4_VIBE_FILE_ASSET_APP_INDEX
    adr x2, pi4_status_pi4userfile_app_index_offset
    mov x3, #PI4_VIBE_FD_APP_INDEX
    b .Lpi4_user_file_lookup_fd_done
.size pi4_user_file_lookup_fd, . - pi4_user_file_lookup_fd

.type pi4_write_user_regular_stat, %function
pi4_write_user_regular_stat:
    str xzr, [x0]
    str xzr, [x0, #8]
    str xzr, [x0, #16]
    str xzr, [x0, #24]
    str xzr, [x0, #32]
    str wzr, [x0, #40]
    mov w2, #(PI4_VIBE_S_IFREG | PI4_VIBE_S_IRUSR)
    str w2, [x0, #PI4_VIBE_STAT_MODE_OFFSET]
    str w1, [x0, #PI4_VIBE_STAT_SIZE_OFFSET]
    ret
.size pi4_write_user_regular_stat, . - pi4_write_user_regular_stat

.balign 2048
.global pi4_el1_vectors
.type pi4_el1_vectors, %function
pi4_el1_vectors:
    // Current EL using SP0.
    b pi4_el1_unexpected_exception
    .balign 128
    b pi4_el1_unexpected_exception
    .balign 128
    b pi4_el1_unexpected_exception
    .balign 128
    b pi4_el1_unexpected_exception
    .balign 128
    // Current EL using SPx.
    b pi4_el1_sync_spx_exception
    .balign 128
    b pi4_el1_irq_spx_exception
    .balign 128
    b pi4_el1_unexpected_exception
    .balign 128
    b pi4_el1_unexpected_exception
    .balign 128
    // Lower EL using AArch64.
    b pi4_el1_lower_aarch64_sync_exception
    .balign 128
    b pi4_el1_lower_aarch64_irq_exception
    .balign 128
    b pi4_el1_unexpected_exception
    .balign 128
    b pi4_el1_unexpected_exception
    .balign 128
    // Lower EL using AArch32.
    b pi4_el1_unexpected_exception
    .balign 128
    b pi4_el1_unexpected_exception
    .balign 128
    b pi4_el1_unexpected_exception
    .balign 128
    b pi4_el1_unexpected_exception
    .balign 128
.size pi4_el1_vectors, . - pi4_el1_vectors

.type pi4_el1_sync_spx_exception, %function
pi4_el1_sync_spx_exception:
    sub sp, sp, #32
    stp x0, x1, [sp]
    stp x2, x3, [sp, #16]
    mrs x0, ESR_EL1
    mrs x1, ELR_EL1
    adr x2, pi4_status_esr_el1
    str x0, [x2]
    adr x2, pi4_status_elr_el1
    str x1, [x2]
    lsr x2, x0, #26
    cmp x2, #0x15
    b.eq .Lpi4_el1_sync_spx_known
    cmp x2, #0x3c
    b.ne pi4_el1_unexpected_exception_recorded
.Lpi4_el1_sync_spx_known:
    adr x2, pi4_status_vector_hits
    ldr x3, [x2]
    add x3, x3, #1
    str x3, [x2]
    adr x2, pi4_status_pi4vec
    ldr w3, =VIBE_PI4_STATUS_PI4VEC_OK
    str w3, [x2]
    adr x2, pi4_status_last
    ldr w3, =VIBE_PI4_STATUS_VECTOR_HIT
    str w3, [x2]
    add x1, x1, #4
    msr ELR_EL1, x1
    ldp x2, x3, [sp, #16]
    ldp x0, x1, [sp], #32
    eret
.size pi4_el1_sync_spx_exception, . - pi4_el1_sync_spx_exception

.type pi4_el1_irq_spx_exception, %function
pi4_el1_irq_spx_exception:
    sub sp, sp, #80
    stp x0, x1, [sp]
    stp x2, x3, [sp, #16]
    stp x4, x5, [sp, #32]
    stp x6, x7, [sp, #48]
    str x30, [sp, #64]

    mrs x0, ELR_EL1
    adr x1, pi4_status_elr_el1
    str x0, [x1]
    adr x1, pi4_status_pi4gic_cpu_base
    ldr x1, [x1]
    cbz x1, .Lpi4_irq_unexpected

    ldr w2, [x1, #PI4_GICC_IAR]
    and w3, w2, #0x3ff
    adr x4, pi4_status_timer_iar_id
    uxtw x5, w3
    str x5, [x4]
    cmp w3, #PI4_TIMER_PPI_ID
    b.ne .Lpi4_irq_unexpected

    msr CNTP_CTL_EL0, xzr
    adr x4, pi4_status_timer_ticks
    ldr x5, [x4]
    add x5, x5, #1
    str x5, [x4]
    adr x4, pi4_status_vector_hits
    ldr x5, [x4]
    add x5, x5, #1
    str x5, [x4]
    str w2, [x1, #PI4_GICC_EOIR]
    adr x4, pi4_status_timer_eoi_id
    uxtw x5, w3
    str x5, [x4]
    adr x4, pi4_status_last
    ldr w5, =VIBE_PI4_STATUS_VECTOR_HIT
    str w5, [x4]
    bl pi4_rearm_timer_tick
    bl pi4_record_timer_preempt_wait

    ldr x30, [sp, #64]
    ldp x6, x7, [sp, #48]
    ldp x4, x5, [sp, #32]
    ldp x2, x3, [sp, #16]
    ldp x0, x1, [sp], #80
    eret

.Lpi4_irq_unexpected:
    adr x4, pi4_status_pi4vec
    ldr w5, =VIBE_PI4_STATUS_VECTOR_UNEXPECTED
    str w5, [x4]
    adr x4, pi4_status_last
    ldr w5, =VIBE_PI4_STATUS_VECTOR_UNEXPECTED
    str w5, [x4]
    ldr w0, =VIBE_PI4_FAULTSRC_EL1
    ldr w1, =VIBE_PI4_FAULTMODE_IRQ
    bl pi4_record_panic_status
    bl pi4_uart_write_status_line
.Lpi4_irq_unexpected_hold:
    wfe
    b .Lpi4_irq_unexpected_hold
.size pi4_el1_irq_spx_exception, . - pi4_el1_irq_spx_exception

.type pi4_el1_lower_aarch64_irq_exception, %function
pi4_el1_lower_aarch64_irq_exception:
    sub sp, sp, #256
    stp x0, x1, [sp]
    stp x2, x3, [sp, #16]
    stp x4, x5, [sp, #32]
    stp x6, x7, [sp, #48]
    stp x8, x9, [sp, #64]
    stp x10, x11, [sp, #80]
    stp x12, x13, [sp, #96]
    stp x14, x15, [sp, #112]
    stp x16, x17, [sp, #128]
    stp x18, x19, [sp, #144]
    stp x20, x21, [sp, #160]
    stp x22, x23, [sp, #176]
    stp x24, x25, [sp, #192]
    stp x26, x27, [sp, #208]
    stp x28, x29, [sp, #224]
    str x30, [sp, #240]

    adr x0, pi4_status_pi4gic_cpu_base
    ldr x0, [x0]
    cbz x0, .Lpi4_lower_el_irq_unexpected

    ldr w1, [x0, #PI4_GICC_IAR]
    and w2, w1, #0x3ff
    adr x3, pi4_status_timer_iar_id
    uxtw x4, w2
    str x4, [x3]
    cmp w2, #PI4_TIMER_PPI_ID
    b.ne .Lpi4_lower_el_irq_unexpected

pi4_lower_el_irq_record_timer_frame:
    mrs x3, ELR_EL1
    mrs x4, SPSR_EL1
    mrs x5, SP_EL0
    adr x6, pi4_status_elr_el1
    str x3, [x6]
    adr x6, pi4_status_irqframe_elr_el1
    str x3, [x6]
    adr x6, pi4_status_irqframe_spsr_el1
    str x4, [x6]
    adr x6, pi4_status_irqframe_sp_el0
    str x5, [x6]
    adr x6, pi4_status_irqframe_x0
    ldp x7, x8, [sp]
    stp x7, x8, [x6]
    ldp x7, x8, [sp, #16]
    stp x7, x8, [x6, #16]
    ldp x7, x8, [sp, #32]
    stp x7, x8, [x6, #32]
    ldp x7, x8, [sp, #48]
    stp x7, x8, [x6, #48]
    ldp x7, x8, [sp, #64]
    stp x7, x8, [x6, #64]
    ldp x7, x8, [sp, #80]
    stp x7, x8, [x6, #80]
    ldp x7, x8, [sp, #96]
    stp x7, x8, [x6, #96]
    ldp x7, x8, [sp, #112]
    stp x7, x8, [x6, #112]
    ldp x7, x8, [sp, #128]
    stp x7, x8, [x6, #128]
    ldp x7, x8, [sp, #144]
    stp x7, x8, [x6, #144]
    ldp x7, x8, [sp, #160]
    stp x7, x8, [x6, #160]
    ldp x7, x8, [sp, #176]
    stp x7, x8, [x6, #176]
    ldp x7, x8, [sp, #192]
    stp x7, x8, [x6, #192]
    ldp x7, x8, [sp, #208]
    stp x7, x8, [x6, #208]
    ldp x7, x8, [sp, #224]
    stp x7, x8, [x6, #224]
    ldr x7, [sp, #240]
    str x7, [x6, #240]

    msr CNTP_CTL_EL0, xzr
    adr x3, pi4_status_timer_ticks
    ldr x4, [x3]
    add x4, x4, #1
    str x4, [x3]
    adr x3, pi4_status_vector_hits
    ldr x4, [x3]
    add x4, x4, #1
    str x4, [x3]
    str w1, [x0, #PI4_GICC_EOIR]
    adr x3, pi4_status_timer_eoi_id
    uxtw x4, w2
    str x4, [x3]
    adr x3, pi4_status_last
    ldr w4, =VIBE_PI4_STATUS_VECTOR_HIT
    str w4, [x3]
    bl pi4_rearm_timer_tick
    adr x0, pi4_status_irqframe_elr_el1
    ldr x0, [x0]
    adr x1, pi4_status_irqframe_sp_el0
    ldr x1, [x1]
    adr x2, pi4_status_proc_current_pid
    ldr x2, [x2]
    cbnz x2, .Lpi4_lower_el_irq_account_have_pid
    mov x2, #PI4_PROC_PID_INIT
.Lpi4_lower_el_irq_account_have_pid:
    ldr x3, =pi4_process_table
    ldr x6, [x3, #8]
    cmp x2, x6
    b.eq .Lpi4_lower_el_irq_account_entry_ready
    add x6, x3, #PI4_PROC_TABLE_ENTRY_BYTES
    ldr x7, [x6, #8]
    cmp x2, x7
    csel x3, x6, x3, eq
.Lpi4_lower_el_irq_account_entry_ready:
    ldr x3, [x3, #40]
    cbnz x3, .Lpi4_lower_el_irq_account_have_kind
    mov x3, #PI4_PROC_KIND_INIT
.Lpi4_lower_el_irq_account_have_kind:
    adr x4, pi4_status_irqframe_spsr_el1
    ldr x4, [x4]
    bl pi4_record_process_context_skeleton
    mov x0, sp
    bl pi4_record_timer_preempt_schedule
    b pi4_lower_el_irq_restore_eret

.Lpi4_lower_el_irq_unexpected:
    mrs x19, ESR_EL1
    mrs x20, ELR_EL1
    adr x3, pi4_status_esr_el1
    str x19, [x3]
    adr x3, pi4_status_elr_el1
    str x20, [x3]
    mov x0, x19
    mov x1, x20
    mov x2, #VIBE_PI4_FAULTMODE_IRQ
    bl pi4_mark_current_process_fault
    adr x3, pi4_status_pi4vec
    ldr w4, =VIBE_PI4_STATUS_VECTOR_UNEXPECTED
    str w4, [x3]
    adr x3, pi4_status_last
    ldr w4, =VIBE_PI4_STATUS_VECTOR_UNEXPECTED
    str w4, [x3]
    ldr w0, =VIBE_PI4_FAULTSRC_EL0
    ldr w1, =VIBE_PI4_FAULTMODE_IRQ
    bl pi4_record_panic_status
    bl pi4_uart_write_status_line
.Lpi4_lower_el_irq_unexpected_hold:
    wfe
    b .Lpi4_lower_el_irq_unexpected_hold

pi4_lower_el_irq_restore_eret:
    adr x0, pi4_status_irqframe_elr_el1
    ldr x1, [x0]
    msr ELR_EL1, x1
    adr x0, pi4_status_irqframe_spsr_el1
    ldr x1, [x0]
    msr SPSR_EL1, x1
    adr x0, pi4_status_irqframe_sp_el0
    ldr x1, [x0]
    msr SP_EL0, x1
    ldp x28, x29, [sp, #224]
    ldr x30, [sp, #240]
    ldp x26, x27, [sp, #208]
    ldp x24, x25, [sp, #192]
    ldp x22, x23, [sp, #176]
    ldp x20, x21, [sp, #160]
    ldp x18, x19, [sp, #144]
    ldp x16, x17, [sp, #128]
    ldp x14, x15, [sp, #112]
    ldp x12, x13, [sp, #96]
    ldp x10, x11, [sp, #80]
    ldp x8, x9, [sp, #64]
    ldp x6, x7, [sp, #48]
    ldp x4, x5, [sp, #32]
    ldp x2, x3, [sp, #16]
    ldp x0, x1, [sp], #256
    eret
.size pi4_el1_lower_aarch64_irq_exception, . - pi4_el1_lower_aarch64_irq_exception

.type pi4_el1_lower_aarch64_sync_exception, %function
pi4_el1_lower_aarch64_sync_exception:
    sub sp, sp, #256
    stp x0, x1, [sp]
    stp x2, x3, [sp, #16]
    stp x4, x5, [sp, #32]
    stp x6, x7, [sp, #48]
    stp x8, x9, [sp, #64]
    stp x10, x11, [sp, #80]
    stp x12, x13, [sp, #96]
    stp x14, x15, [sp, #112]
    stp x16, x17, [sp, #128]
    stp x18, x19, [sp, #144]
    stp x20, x21, [sp, #160]
    stp x22, x23, [sp, #176]
    stp x24, x25, [sp, #192]
    stp x26, x27, [sp, #208]
    stp x28, x29, [sp, #224]
    str x30, [sp, #240]
    adr x4, pi4_status_sysframe_x0
    str x0, [x4]
    mrs x0, ESR_EL1
    mrs x1, ELR_EL1
    mrs x2, SPSR_EL1
    mrs x3, SP_EL0
    adr x4, pi4_status_esr_el1
    str x0, [x4]
    adr x4, pi4_status_elr_el1
    str x1, [x4]
    adr x4, pi4_status_sysframe_elr_el1
    str x1, [x4]
    adr x4, pi4_status_sysframe_spsr_el1
    str x2, [x4]
    adr x4, pi4_status_sysframe_sp_el0
    str x3, [x4]
    adr x4, pi4_status_pi4sysframe
    ldr w5, =VIBE_PI4_STATUS_PI4SYSFRAME_OK
    str w5, [x4]
    lsr x4, x0, #26
    cmp x4, #0x15
    b.ne .Lpi4_lower_el_svc_unexpected
    ubfx x4, x0, #0, #16
    cmp x4, #PI4_EL0_SVC_ROUNDTRIP
    b.eq .Lpi4_lower_el_svc_roundtrip
    cmp x4, #PI4_EL0_SVC_EXIT
    b.eq .Lpi4_lower_el_svc_exit
    cmp x4, #PI4_EL0_SVC_TRACE
    b.eq .Lpi4_lower_el_svc_trace
    cmp x4, #PI4_VIBE_SVC_IMM
    b.eq .Lpi4_lower_el_svc_runtime_dispatch
    b .Lpi4_lower_el_svc_unexpected

.Lpi4_lower_el_svc_roundtrip:
    adr x0, msg_stage_el0round
    bl pi4_uart_write_string
    adr x5, pi4_status_vector_hits
    ldr x6, [x5]
    add x6, x6, #1
    str x6, [x5]
    adr x5, pi4_status_svc_hits
    ldr x6, [x5]
    add x6, x6, #1
    str x6, [x5]
    adr x5, pi4_status_pi4svc
    ldr w6, =VIBE_PI4_STATUS_PI4SVC_RETURNED
    str w6, [x5]
    adr x5, pi4_status_runtime_gate
    ldr w6, =VIBE_PI4_GATE_RUNTIME_RETURNED
    str w6, [x5]
    adr x5, pi4_status_last
    ldr w6, =VIBE_PI4_STATUS_VECTOR_HIT
    str w6, [x5]
    movz w5, #PI4_EL0_RETURN_MAGIC_LO
    movk w5, #PI4_EL0_RETURN_MAGIC_HI, lsl #16
    str x5, [sp]
    b .Lpi4_lower_el_svc_restore_eret

.Lpi4_lower_el_svc_exit:
    adr x5, pi4_status_vector_hits
    ldr x6, [x5]
    add x6, x6, #1
    str x6, [x5]
    adr x5, pi4_status_svc_hits
    ldr x6, [x5]
    add x6, x6, #1
    str x6, [x5]
    adr x5, pi4_status_el0_return_elr
    str x1, [x5]
    adr x5, pi4_status_pi4svc
    ldr w6, =VIBE_PI4_STATUS_PI4SVC_OK
    str w6, [x5]
    adr x5, pi4_status_pi4sysframe
    ldr w6, =VIBE_PI4_STATUS_PI4SYSFRAME_OK
    str w6, [x5]
    adr x5, pi4_status_pi4elf
    ldr w6, =VIBE_PI4_STATUS_PI4ELF_OK
    str w6, [x5]
    adr x5, pi4_status_runtime_gate
    ldr w6, =VIBE_PI4_GATE_RUNTIME_OK
    str w6, [x5]
    adr x5, pi4_status_last
    ldr w6, =VIBE_PI4_STATUS_VECTOR_HIT
    str w6, [x5]
    adr x5, pi4_status_el0_return_el1
    ldr x5, [x5]
    cbnz x5, .Lpi4_lower_el_svc_exit_return_set
    adr x5, pi4_lower_el_svc_done
.Lpi4_lower_el_svc_exit_return_set:
    msr ELR_EL1, x5
    mov x5, #PI4_SPSR_EL1H_MASKED
    msr SPSR_EL1, x5
    b .Lpi4_lower_el_svc_restore_eret

.Lpi4_lower_el_svc_trace:
    adr x0, msg_stage_el0trace
    bl pi4_uart_write_string
    ldr x0, [sp]
    bl pi4_uart_write_hex64
    bl pi4_uart_write_newline
    b .Lpi4_lower_el_svc_restore_eret

.Lpi4_lower_el_svc_runtime_dispatch:
    adr x5, pi4_status_vector_hits
    ldr x6, [x5]
    add x6, x6, #1
    str x6, [x5]
    adr x5, pi4_status_svc_hits
    ldr x6, [x5]
    add x6, x6, #1
    str x6, [x5]
    adr x5, pi4_status_svc_runtime_hits
    ldr x6, [x5]
    add x6, x6, #1
    str x6, [x5]
    adr x5, pi4_status_svc_runtime_last_number
    str x8, [x5]
    adr x5, pi4_status_svc_runtime_last_arg0
    ldr x6, [sp]
    str x6, [x5]
    adr x5, pi4_status_svc_runtime_last_arg1
    ldr x6, [sp, #8]
    str x6, [x5]
    adr x5, pi4_status_svc_runtime_last_arg2
    ldr x6, [sp, #16]
    str x6, [x5]
    adr x5, pi4_status_pi4svc
    ldr w6, =VIBE_PI4_STATUS_PI4SVC_RETURNED
    str w6, [x5]
    adr x5, pi4_status_runtime_gate
    ldr w6, =VIBE_PI4_GATE_RUNTIME_RETURNED
    str w6, [x5]
    adr x5, pi4_status_last
    ldr w6, =VIBE_PI4_STATUS_VECTOR_HIT
    str w6, [x5]

    cmp x8, #PI4_VIBE_SYS_READ
    b.eq .Lpi4_lower_el_svc_runtime_file_read
    cmp x8, #PI4_VIBE_SYS_WRITE
    b.eq .Lpi4_lower_el_svc_runtime_write
    cmp x8, #PI4_VIBE_SYS_OPEN
    b.eq .Lpi4_lower_el_svc_runtime_file_open
    cmp x8, #PI4_VIBE_SYS_FILE_SIZE
    b.eq .Lpi4_lower_el_svc_runtime_file_size
    cmp x8, #PI4_VIBE_SYS_LSEEK
    b.eq pi4_lower_el_svc_runtime_file_lseek
    cmp x8, #PI4_VIBE_SYS_CLOSE
    b.eq pi4_lower_el_svc_runtime_file_close
    cmp x8, #PI4_VIBE_SYS_STAT
    b.eq pi4_lower_el_svc_runtime_file_stat
    cmp x8, #PI4_VIBE_SYS_FSTAT
    b.eq pi4_lower_el_svc_runtime_file_fstat
    cmp x8, #PI4_VIBE_SYS_GETPID
    b.eq .Lpi4_lower_el_svc_runtime_getpid
    cmp x8, #PI4_VIBE_SYS_CLOCK_GETTIME
    b.eq .Lpi4_lower_el_svc_runtime_clock_gettime
    cmp x8, #PI4_VIBE_SYS_AUDIO
    b.eq .Lpi4_lower_el_svc_runtime_audio
    cmp x8, #PI4_VIBE_SYS_EXEC
    b.eq .Lpi4_lower_el_svc_runtime_exec
    cmp x8, #PI4_VIBE_SYS_EXIT
    b.eq .Lpi4_lower_el_svc_runtime_exit
    cmp x8, #PI4_VIBE_SYS_IOCTL
    b.eq .Lpi4_lower_el_svc_runtime_ioctl
    cmp x8, #PI4_VIBE_SYS_POLL_INPUT
    b.eq .Lpi4_lower_el_svc_runtime_poll_input
    cmp x8, #PI4_VIBE_SYS_INPUT_STATUS
    b.eq .Lpi4_lower_el_svc_runtime_input_status
    cmp x8, #PI4_VIBE_SYS_INPUT_DEVICE_STATUS
    b.eq .Lpi4_lower_el_svc_runtime_input_device_status
    b .Lpi4_lower_el_svc_runtime_inval

.Lpi4_lower_el_svc_runtime_write:
    ldr x10, [sp]
    cmp x10, #1
    b.eq .Lpi4_lower_el_svc_runtime_write_fd_ok
    cmp x10, #2
    b.eq .Lpi4_lower_el_svc_runtime_write_fd_ok
    mov x9, #PI4_VIBE_EBADF
    neg x9, x9
    b .Lpi4_lower_el_svc_runtime_return

.Lpi4_lower_el_svc_runtime_write_fd_ok:
    ldr x12, [sp, #16]
    cbz x12, .Lpi4_lower_el_svc_runtime_write_done
    ldr x11, [sp, #8]
    mov x0, x11
    mov x1, x12
    bl pi4_validate_el0_user_range
    cbz x0, .Lpi4_lower_el_svc_runtime_inval
    ldr x11, [sp, #8]
    ldr x12, [sp, #16]
    mov x13, xzr

.Lpi4_lower_el_svc_runtime_write_next:
    cmp x13, x12
    b.hs .Lpi4_lower_el_svc_runtime_write_done
    ldrb w0, [x11, x13]
    bl pi4_uart_putc
    add x13, x13, #1
    b .Lpi4_lower_el_svc_runtime_write_next

.Lpi4_lower_el_svc_runtime_write_done:
    ldr x9, [sp, #16]
    b .Lpi4_lower_el_svc_runtime_return

.Lpi4_lower_el_svc_runtime_file_open:
    ldr x11, [sp]
    ldr x12, [sp, #8]
    ldr x13, [sp, #16]
    cbnz x12, .Lpi4_lower_el_svc_runtime_file_inval_preserve
    cbnz x13, .Lpi4_lower_el_svc_runtime_file_inval_preserve
    mov x0, x11
    mov x1, #PI4_VIBE_FILE_PATH_MAX_BYTES
    bl pi4_validate_el0_user_range
    cbz x0, .Lpi4_lower_el_svc_runtime_file_inval_preserve

    ldr x0, [sp]
    bl pi4_user_file_lookup_path
    cbz x0, .Lpi4_lower_el_svc_runtime_file_enoent_preserve
    mov x20, x0
    mov x22, x1
    mov x21, x2
    mov x23, x3
    cbz x23, .Lpi4_lower_el_svc_runtime_file_enoent_preserve
    cbz x21, .Lpi4_lower_el_svc_runtime_file_enoent_preserve
    b .Lpi4_lower_el_svc_runtime_file_open_have_asset

.Lpi4_lower_el_svc_runtime_file_open_have_asset:
    adr x10, pi4_status_pi4userfile_open_count
    ldr x11, [x10]
    add x11, x11, #1
    str x11, [x10]
    adr x10, pi4_status_pi4userfile_op_mask
    ldr x11, [x10]
    orr x11, x11, #PI4_VIBE_FILE_OP_OPEN
    str x11, [x10]
    adr x10, pi4_status_pi4userfile_proof_latched
    ldr x11, [x10]
    cbnz x11, .Lpi4_lower_el_svc_runtime_file_open_keep_proof
    adr x10, pi4_status_pi4userfile_last_op
    mov x11, #PI4_VIBE_FILE_OP_OPEN
    str x11, [x10]
    adr x10, pi4_status_pi4userfile_slot
    adr x11, pi4_status_pi4appreq_matched_asset
    ldr x0, [x11]
    bl pi4_app_index_from_elf_asset
    str x0, [x10]
    adr x10, pi4_status_pi4userfile_asset
    str x22, [x10]
    adr x10, pi4_status_pi4userfile_fd
    str x23, [x10]
    adr x10, pi4_status_pi4userfile_proof_latched
    ldr x11, [x10]
    cbnz x11, .Lpi4_lower_el_svc_runtime_file_open_keep_proof
    adr x10, pi4_status_pi4userfile_size
    str xzr, [x10]
    adr x10, pi4_status_pi4userfile_offset
    str xzr, [x10]
    adr x10, pi4_status_pi4userfile_requested
    str xzr, [x10]
    adr x10, pi4_status_pi4userfile_magic
    str xzr, [x10]
.Lpi4_lower_el_svc_runtime_file_open_keep_proof:
    adr x10, pi4_status_pi4vfs
    ldr w11, [x10]
    ldr w12, =PI4_START_STORAGE_VFS_OK
    cmp w11, w12
    b.ne .Lpi4_lower_el_svc_runtime_file_enosys_status
    mov x0, x20
    bl pi4_user_file_metadata_is_valid
    cbz x0, .Lpi4_lower_el_svc_runtime_file_enoent
    str xzr, [x21]
    ldr x9, [x20, #24]
    adr x10, pi4_status_pi4userfile_size
    str x9, [x10]
    mov x9, x23
    b .Lpi4_lower_el_svc_runtime_file_result

.Lpi4_lower_el_svc_runtime_file_size:
    adr x10, pi4_status_pi4userfile_size_count
    ldr x11, [x10]
    add x11, x11, #1
    str x11, [x10]
    adr x10, pi4_status_pi4userfile_op_mask
    ldr x11, [x10]
    orr x11, x11, #PI4_VIBE_FILE_OP_SIZE
    str x11, [x10]
    adr x10, pi4_status_pi4userfile_proof_latched
    ldr x11, [x10]
    cbnz x11, .Lpi4_lower_el_svc_runtime_file_size_have_fd
    adr x10, pi4_status_pi4userfile_last_op
    mov x11, #PI4_VIBE_FILE_OP_SIZE
    str x11, [x10]
    adr x10, pi4_status_pi4userfile_slot
    adr x11, pi4_status_pi4appreq_matched_asset
    ldr x0, [x11]
    bl pi4_app_index_from_elf_asset
    str x0, [x10]
    ldr x0, [sp]
    adr x10, pi4_status_pi4userfile_fd
    str x0, [x10]
.Lpi4_lower_el_svc_runtime_file_size_have_fd:
    ldr x0, [sp]
    bl pi4_user_file_lookup_fd
    cbz x0, .Lpi4_lower_el_svc_runtime_file_ebadf
    mov x20, x0
    mov x22, x1
    adr x10, pi4_status_pi4userfile_proof_latched
    ldr x11, [x10]
    cbnz x11, .Lpi4_lower_el_svc_runtime_file_size_asset_done
    adr x10, pi4_status_pi4userfile_asset
    str x22, [x10]
.Lpi4_lower_el_svc_runtime_file_size_asset_done:
    adr x10, pi4_status_pi4vfs
    ldr w11, [x10]
    ldr w12, =PI4_START_STORAGE_VFS_OK
    cmp w11, w12
    b.ne .Lpi4_lower_el_svc_runtime_file_enosys_status
    mov x0, x20
    bl pi4_user_file_metadata_is_valid
    cbz x0, .Lpi4_lower_el_svc_runtime_file_enoent
    ldr x9, [x20, #24]
    adr x10, pi4_status_pi4userfile_proof_latched
    ldr x11, [x10]
    cbnz x11, .Lpi4_lower_el_svc_runtime_file_size_result
    adr x10, pi4_status_pi4userfile_size
    str x9, [x10]
.Lpi4_lower_el_svc_runtime_file_size_result:
    b .Lpi4_lower_el_svc_runtime_file_result

pi4_lower_el_svc_runtime_file_lseek:
    ldr x19, [sp]
    ldr x20, [sp, #8]
    ldr x21, [sp, #16]
    mov x0, x19
    bl pi4_user_file_lookup_fd
    cbz x0, .Lpi4_lower_el_svc_runtime_file_lseek_ebadf
    mov x22, x0
    mov x24, x2
    cbz x24, .Lpi4_lower_el_svc_runtime_file_lseek_ebadf
    adr x10, pi4_status_pi4vfs
    ldr w11, [x10]
    ldr w12, =PI4_START_STORAGE_VFS_OK
    cmp w11, w12
    b.ne .Lpi4_lower_el_svc_runtime_file_lseek_enosys
    mov x0, x22
    bl pi4_user_file_metadata_is_valid
    cbz x0, .Lpi4_lower_el_svc_runtime_file_lseek_enoent
    ldr x25, [x22, #24]
    cmp x21, #PI4_VIBE_SEEK_SET
    b.eq .Lpi4_lower_el_svc_runtime_file_lseek_set
    cmp x21, #PI4_VIBE_SEEK_CUR
    b.eq .Lpi4_lower_el_svc_runtime_file_lseek_cur
    cmp x21, #PI4_VIBE_SEEK_END
    b.eq .Lpi4_lower_el_svc_runtime_file_lseek_end
    b .Lpi4_lower_el_svc_runtime_file_lseek_inval

.Lpi4_lower_el_svc_runtime_file_lseek_set:
    mov x26, x20
    b .Lpi4_lower_el_svc_runtime_file_lseek_check

.Lpi4_lower_el_svc_runtime_file_lseek_cur:
    ldr x27, [x24]
    adds x26, x27, x20
    b.vs .Lpi4_lower_el_svc_runtime_file_lseek_inval
    b .Lpi4_lower_el_svc_runtime_file_lseek_check

.Lpi4_lower_el_svc_runtime_file_lseek_end:
    adds x26, x25, x20
    b.vs .Lpi4_lower_el_svc_runtime_file_lseek_inval

.Lpi4_lower_el_svc_runtime_file_lseek_check:
    tbnz x26, #63, .Lpi4_lower_el_svc_runtime_file_lseek_inval
    str x26, [x24]
    mov x9, x26
    b .Lpi4_lower_el_svc_runtime_return

.Lpi4_lower_el_svc_runtime_file_lseek_ebadf:
    mov x9, #PI4_VIBE_EBADF
    neg x9, x9
    b .Lpi4_lower_el_svc_runtime_return
.Lpi4_lower_el_svc_runtime_file_lseek_enoent:
    mov x9, #PI4_VIBE_ENOENT
    neg x9, x9
    b .Lpi4_lower_el_svc_runtime_return
.Lpi4_lower_el_svc_runtime_file_lseek_enosys:
    mov x9, #PI4_VIBE_ENOSYS
    neg x9, x9
    b .Lpi4_lower_el_svc_runtime_return
.Lpi4_lower_el_svc_runtime_file_lseek_inval:
    mov x9, #PI4_VIBE_EINVAL
    neg x9, x9
    b .Lpi4_lower_el_svc_runtime_return

pi4_lower_el_svc_runtime_file_close:
    ldr x0, [sp]
    bl pi4_user_file_lookup_fd
    cbz x0, .Lpi4_lower_el_svc_runtime_file_close_ebadf
    cbz x2, .Lpi4_lower_el_svc_runtime_file_close_ebadf
    str xzr, [x2]
    mov x9, xzr
    b .Lpi4_lower_el_svc_runtime_return
.Lpi4_lower_el_svc_runtime_file_close_ebadf:
    mov x9, #PI4_VIBE_EBADF
    neg x9, x9
    b .Lpi4_lower_el_svc_runtime_return

pi4_lower_el_svc_runtime_file_stat:
    ldr x19, [sp]
    ldr x20, [sp, #8]
    mov x0, x19
    mov x1, #PI4_VIBE_FILE_PATH_MAX_BYTES
    bl pi4_validate_el0_user_range
    cbz x0, .Lpi4_lower_el_svc_runtime_file_stat_inval
    mov x0, x20
    mov x1, #PI4_VIBE_STAT_BYTES
    bl pi4_validate_el0_user_range
    cbz x0, .Lpi4_lower_el_svc_runtime_file_stat_inval
    mov x0, x19
    bl pi4_user_file_lookup_path
    cbz x0, .Lpi4_lower_el_svc_runtime_file_stat_enoent
    b .Lpi4_lower_el_svc_runtime_file_stat_have_file

pi4_lower_el_svc_runtime_file_fstat:
    ldr x19, [sp]
    ldr x20, [sp, #8]
    mov x0, x20
    mov x1, #PI4_VIBE_STAT_BYTES
    bl pi4_validate_el0_user_range
    cbz x0, .Lpi4_lower_el_svc_runtime_file_stat_inval
    mov x0, x19
    bl pi4_user_file_lookup_fd
    cbz x0, .Lpi4_lower_el_svc_runtime_file_stat_ebadf

.Lpi4_lower_el_svc_runtime_file_stat_have_file:
    mov x22, x0
    mov x23, x1
    adr x10, pi4_status_pi4userfile_asset
    str x23, [x10]
    adr x10, pi4_status_pi4vfs
    ldr w11, [x10]
    ldr w12, =PI4_START_STORAGE_VFS_OK
    cmp w11, w12
    b.ne .Lpi4_lower_el_svc_runtime_file_stat_enosys
    mov x0, x22
    bl pi4_user_file_metadata_is_valid
    cbz x0, .Lpi4_lower_el_svc_runtime_file_stat_enoent
    ldr x24, [x22, #24]
    adr x10, pi4_status_pi4userfile_size
    str x24, [x10]
    mov x0, x20
    mov x1, x24
    bl pi4_write_user_regular_stat
    mov x9, xzr
    b .Lpi4_lower_el_svc_runtime_return

.Lpi4_lower_el_svc_runtime_file_stat_inval:
    mov x9, #PI4_VIBE_EINVAL
    neg x9, x9
    b .Lpi4_lower_el_svc_runtime_return
.Lpi4_lower_el_svc_runtime_file_stat_ebadf:
    mov x9, #PI4_VIBE_EBADF
    neg x9, x9
    b .Lpi4_lower_el_svc_runtime_return
.Lpi4_lower_el_svc_runtime_file_stat_enoent:
    mov x9, #PI4_VIBE_ENOENT
    neg x9, x9
    b .Lpi4_lower_el_svc_runtime_return
.Lpi4_lower_el_svc_runtime_file_stat_enosys:
    mov x9, #PI4_VIBE_ENOSYS
    neg x9, x9
    b .Lpi4_lower_el_svc_runtime_return

.Lpi4_lower_el_svc_runtime_file_read:
    adr x10, pi4_status_pi4userfile_op_mask
    ldr x11, [x10]
    orr x11, x11, #PI4_VIBE_FILE_OP_READ
    str x11, [x10]
    adr x10, pi4_status_pi4userfile_last_op
    mov x11, #PI4_VIBE_FILE_OP_READ
    str x11, [x10]
    adr x10, pi4_status_pi4userfile_slot
    adr x11, pi4_status_pi4appreq_matched_asset
    ldr x0, [x11]
    bl pi4_app_index_from_elf_asset
    str x0, [x10]
    ldr x19, [sp]
    ldr x20, [sp, #8]
    ldr x21, [sp, #16]
    adr x10, pi4_status_pi4userfile_fd
    str x19, [x10]
    adr x10, pi4_status_pi4userfile_proof_latched
    ldr x11, [x10]
    cbnz x11, .Lpi4_lower_el_svc_runtime_file_read_keep_proof
    adr x10, pi4_status_pi4userfile_requested
    str x21, [x10]
    adr x10, pi4_status_pi4userfile_magic
    str xzr, [x10]
.Lpi4_lower_el_svc_runtime_file_read_keep_proof:
    mov x0, x19
    bl pi4_user_file_lookup_fd
    cbz x0, .Lpi4_lower_el_svc_runtime_file_ebadf
    mov x22, x0
    mov x23, x1
    mov x24, x2
    adr x10, pi4_status_pi4userfile_asset
    str x23, [x10]
    cbz x21, .Lpi4_lower_el_svc_runtime_file_read_zero
    adr x10, pi4_status_pi4vfs
    ldr w11, [x10]
    ldr w12, =PI4_START_STORAGE_VFS_OK
    cmp w11, w12
    b.ne .Lpi4_lower_el_svc_runtime_file_enosys_status
    mov x0, x22
    bl pi4_user_file_metadata_is_valid
    cbz x0, .Lpi4_lower_el_svc_runtime_file_enoent
    ldr x25, [x22, #24]
    adr x10, pi4_status_pi4userfile_size
    str x25, [x10]
    ldr x26, [x24]
    adr x10, pi4_status_pi4userfile_proof_latched
    ldr x11, [x10]
    cbnz x11, .Lpi4_lower_el_svc_runtime_file_offset_keep_proof
    adr x10, pi4_status_pi4userfile_offset
    str x26, [x10]
.Lpi4_lower_el_svc_runtime_file_offset_keep_proof:
    cmp x26, x25
    b.hs .Lpi4_lower_el_svc_runtime_file_read_zero
    sub x27, x25, x26
    cmp x21, x27
    csel x21, x21, x27, lo
    and x28, x26, #0x1ff
    mov x27, #PI4_START_STORAGE_BLOCK_MAX_READ_BYTES
    sub x27, x27, x28
    cmp x21, x27
    csel x21, x21, x27, lo
    cbz x21, .Lpi4_lower_el_svc_runtime_file_read_zero
    mov x0, x20
    mov x1, x21
    bl pi4_validate_el0_user_range
    cbz x0, .Lpi4_lower_el_svc_runtime_file_inval
    add x27, x28, x21
    add x27, x27, #PI4_START_STORAGE_SECTOR_BYTES - 1
    lsr x27, x27, #9
    mov x0, x22
    adr x1, pi4_start_storage_app_elf_buffer
    lsr x2, x26, #9
    mov x3, x27
    mov x4, #1
    bl pi4_read_storage_file_sectors
    cbnz x0, .Lpi4_lower_el_svc_runtime_file_block_result
    cmp x1, x27
    b.lo .Lpi4_lower_el_svc_runtime_file_short_read
    adr x10, pi4_start_storage_app_elf_buffer
    add x10, x10, x28
    cmp x21, #4
    b.lo .Lpi4_lower_el_svc_runtime_file_copy
    cbnz x26, .Lpi4_lower_el_svc_runtime_file_copy
    ldrb w11, [x10]
    ldrb w12, [x10, #1]
    orr w11, w11, w12, lsl #8
    ldrb w12, [x10, #2]
    orr w11, w11, w12, lsl #16
    ldrb w12, [x10, #3]
    orr w11, w11, w12, lsl #24
    adr x12, pi4_status_pi4userfile_proof_latched
    ldr x13, [x12]
    cbnz x13, .Lpi4_lower_el_svc_runtime_file_copy
    adr x12, pi4_status_pi4userfile_magic
    str x11, [x12]

.Lpi4_lower_el_svc_runtime_file_copy:
    mov x11, x20
    mov x12, x21
.Lpi4_lower_el_svc_runtime_file_copy_fast_check:
    cmp x12, #8
    b.lo .Lpi4_lower_el_svc_runtime_file_copy_next
    orr x13, x10, x11
    tst x13, #7
    b.ne .Lpi4_lower_el_svc_runtime_file_copy_next
.Lpi4_lower_el_svc_runtime_file_copy_word:
    ldr x13, [x10], #8
    str x13, [x11], #8
    sub x12, x12, #8
    cmp x12, #8
    b.hs .Lpi4_lower_el_svc_runtime_file_copy_word
.Lpi4_lower_el_svc_runtime_file_copy_next:
    cbz x12, .Lpi4_lower_el_svc_runtime_file_copy_done
    ldrb w13, [x10], #1
    strb w13, [x11], #1
    sub x12, x12, #1
    b .Lpi4_lower_el_svc_runtime_file_copy_next

.Lpi4_lower_el_svc_runtime_file_copy_done:
    adr x10, pi4_status_pi4userfile_read_count
    ldr x11, [x10]
    add x11, x11, #1
    str x11, [x10]
    ldr x11, [x22, #56]
    add x11, x11, x27
    str x11, [x22, #56]
    add x26, x26, x21
    str x26, [x24]
    mov x9, x21
    b .Lpi4_lower_el_svc_runtime_file_result

.Lpi4_lower_el_svc_runtime_file_read_zero:
    mov x9, xzr
    b .Lpi4_lower_el_svc_runtime_file_result

.Lpi4_lower_el_svc_runtime_file_block_result:
    mov x9, x0
    b .Lpi4_lower_el_svc_runtime_file_result

.Lpi4_lower_el_svc_runtime_file_short_read:
    mov x9, #PI4_VIBE_ENOSYS
    neg x9, x9
    b .Lpi4_lower_el_svc_runtime_file_result

.Lpi4_lower_el_svc_runtime_file_inval:
    mov x9, #PI4_VIBE_EINVAL
    neg x9, x9
    b .Lpi4_lower_el_svc_runtime_file_result

.Lpi4_lower_el_svc_runtime_file_inval_preserve:
    mov x9, #PI4_VIBE_EINVAL
    neg x9, x9
    b .Lpi4_lower_el_svc_runtime_return

.Lpi4_lower_el_svc_runtime_file_enoent:
    mov x9, #PI4_VIBE_ENOENT
    neg x9, x9
    b .Lpi4_lower_el_svc_runtime_file_result

.Lpi4_lower_el_svc_runtime_file_enoent_preserve:
    mov x9, #PI4_VIBE_ENOENT
    neg x9, x9
    b .Lpi4_lower_el_svc_runtime_return

.Lpi4_lower_el_svc_runtime_file_ebadf:
    mov x9, #PI4_VIBE_EBADF
    neg x9, x9
    b .Lpi4_lower_el_svc_runtime_file_result

.Lpi4_lower_el_svc_runtime_file_enosys_status:
    mov x9, #PI4_VIBE_ENOSYS
    neg x9, x9

.Lpi4_lower_el_svc_runtime_file_result:
    adr x10, pi4_status_pi4userfile_proof_latched
    ldr x12, [x10]
    cbnz x12, .Lpi4_lower_el_svc_runtime_return
    adr x10, pi4_status_pi4userfile_last_op
    ldr x11, [x10]
    adr x10, pi4_status_pi4userfile_result
    str x9, [x10]
    cmp x11, #PI4_VIBE_FILE_OP_READ
    b.ne .Lpi4_lower_el_svc_runtime_return
    cmp x9, #0
    b.le .Lpi4_lower_el_svc_runtime_return
    adr x10, pi4_status_pi4userfile_slot
    ldr x12, [x10]
    adr x10, pi4_status_pi4userfile_asset
    ldr x13, [x10]
    cmp x12, #0
    b.eq .Lpi4_lower_el_svc_runtime_file_result_first_app
    cmp x12, #1
    b.eq .Lpi4_lower_el_svc_runtime_file_result_second_app
    b .Lpi4_lower_el_svc_runtime_return
.Lpi4_lower_el_svc_runtime_file_result_first_app:
    cmp x13, #PI4_VIBE_FILE_ASSET_DOOM1_WAD
    b.ne .Lpi4_lower_el_svc_runtime_return
    b .Lpi4_lower_el_svc_runtime_file_result_asset_ok
.Lpi4_lower_el_svc_runtime_file_result_second_app:
    cmp x13, #PI4_VIBE_FILE_ASSET_PAK0_PAK
    b.ne .Lpi4_lower_el_svc_runtime_return
.Lpi4_lower_el_svc_runtime_file_result_asset_ok:
    adr x10, pi4_status_pi4userfile_magic
    ldr x12, [x10]
    cbz x12, .Lpi4_lower_el_svc_runtime_return
    cmp x9, #PI4_VIBE_FILE_PROOF_MIN_READ_BYTES
    b.lo .Lpi4_lower_el_svc_runtime_return
    adr x10, pi4_status_pi4userfile_requested
    ldr x12, [x10]
    cmp x12, #PI4_VIBE_FILE_PROOF_MIN_READ_BYTES
    b.lo .Lpi4_lower_el_svc_runtime_return
    adr x10, pi4_status_pi4userfile_proof_latched
    mov x12, #1
    str x12, [x10]
    b .Lpi4_lower_el_svc_runtime_return

.Lpi4_lower_el_svc_runtime_getpid:
    adr x10, pi4_status_svc_runtime_getpid_count
    ldr x11, [x10]
    add x11, x11, #1
    str x11, [x10]
    adr x10, pi4_status_proc_current_pid
    ldr x9, [x10]
    cbnz x9, .Lpi4_lower_el_svc_runtime_getpid_return
    mov x9, #PI4_PROC_PID_INIT
.Lpi4_lower_el_svc_runtime_getpid_return:
    b .Lpi4_lower_el_svc_runtime_return

.Lpi4_lower_el_svc_runtime_clock_gettime:
    adr x10, pi4_status_svc_runtime_clock_count
    ldr x11, [x10]
    add x11, x11, #1
    str x11, [x10]
    ldr x11, [sp]
    cmp x11, #PI4_VIBE_CLOCK_MONOTONIC
    b.ne .Lpi4_lower_el_svc_runtime_inval
    ldr x11, [sp, #16]
    cmp x11, #PI4_VIBE_CLOCK_TIME_BYTES
    b.lo .Lpi4_lower_el_svc_runtime_inval
    adr x11, pi4_status_pi4timer
    ldr w12, [x11]
    ldr w13, =VIBE_PI4_STATUS_PI4TIMER_OK
    cmp w12, w13
    b.ne .Lpi4_lower_el_svc_runtime_enosys
    ldr x11, [sp, #8]
    cbz x11, .Lpi4_lower_el_svc_runtime_inval
    mov x0, x11
    mov x1, #PI4_VIBE_CLOCK_TIME_BYTES
    bl pi4_validate_el0_user_range
    cbz x0, .Lpi4_lower_el_svc_runtime_inval
    ldr x11, [sp, #8]
    adr x12, pi4_status_timer_ticks
    ldr x13, [x12]
    str x13, [x11, #PI4_VIBE_CLOCK_TIME_TICKS_OFFSET]
    mov x14, #PI4_VIBE_CLOCK_MONOTONIC_HZ
    str x14, [x11, #PI4_VIBE_CLOCK_TIME_FREQUENCY_HZ_OFFSET]
    mov x15, #PI4_VIBE_CLOCK_TICK_MILLISECONDS
    mul x15, x13, x15
    str x15, [x11, #PI4_VIBE_CLOCK_TIME_MILLISECONDS_OFFSET]
    mov x16, #PI4_VIBE_CLOCK_FLAG_KERNEL_OWNED
    str x16, [x11, #PI4_VIBE_CLOCK_TIME_FLAGS_OFFSET]
    adr x10, pi4_status_svc_runtime_clock_last_ticks
    str x13, [x10]
    adr x10, pi4_status_svc_runtime_clock_last_hz
    str x14, [x10]
    adr x10, pi4_status_svc_runtime_clock_last_ms
    str x15, [x10]
    mov x9, xzr
    b .Lpi4_lower_el_svc_runtime_return

.Lpi4_lower_el_svc_runtime_audio:
    ldr x0, [sp]
    ldr x1, [sp, #8]
    ldr x2, [sp, #16]
    bl pi4_audio_syscall_dispatch
    mov x9, x0
    b .Lpi4_lower_el_svc_runtime_return

.Lpi4_lower_el_svc_runtime_exec:
    adr x10, pi4_status_pi4exec_sysno
    str x8, [x10]
    adr x10, pi4_status_pi4exec_path
    ldr x11, [sp]
    str x11, [x10]
    adr x10, pi4_status_pi4exec_argv
    ldr x11, [sp, #8]
    str x11, [x10]
    adr x10, pi4_status_pi4exec_envp
    ldr x11, [sp, #16]
    str x11, [x10]
    adr x10, pi4_status_pi4exec_count
    ldr x11, [x10]
    add x11, x11, #1
    str x11, [x10]

    ldr x11, [sp]
    adr x10, pi4_status_pi4appreq_request
    str x11, [x10]
    adr x10, pi4_status_pi4appreq_abi
    str xzr, [x10]
    adr x10, pi4_status_pi4appreq_bytes
    str xzr, [x10]
    adr x10, pi4_status_pi4appreq_path
    str xzr, [x10]
    adr x10, pi4_status_pi4appreq_path_bytes
    str xzr, [x10]
    adr x10, pi4_status_pi4appreq_path_copy
    str xzr, [x10]
    adr x10, pi4_status_pi4appreq_matched_asset
    mov x12, #PI4_VIBE_FILE_ASSET_NONE
    str x12, [x10]
    adr x10, pi4_status_pi4appvfs_values_start
    adr x12, pi4_status_pi4appvfs_values_end
.Lpi4_lower_el_svc_runtime_exec_clear_app_vfs:
    cmp x10, x12
    b.hs .Lpi4_lower_el_svc_runtime_exec_clear_app_vfs_done
    str xzr, [x10], #8
    b .Lpi4_lower_el_svc_runtime_exec_clear_app_vfs
.Lpi4_lower_el_svc_runtime_exec_clear_app_vfs_done:
    adr x10, pi4_status_pi4appvfs_asset
    mov x12, #PI4_VIBE_FILE_ASSET_NONE
    str x12, [x10]
    adr x10, pi4_status_pi4appvfs_status
    ldr w12, =PI4_START_STORAGE_WAIT
    str x12, [x10]
    adr x10, pi4_status_pi4userfile_values_start
    adr x12, pi4_status_pi4userfile_proof_latched
    add x12, x12, #8
.Lpi4_lower_el_svc_runtime_exec_clear_userfile:
    cmp x10, x12
    b.hs .Lpi4_lower_el_svc_runtime_exec_clear_userfile_done
    str xzr, [x10], #8
    b .Lpi4_lower_el_svc_runtime_exec_clear_userfile
.Lpi4_lower_el_svc_runtime_exec_clear_userfile_done:

    mov x0, x11
    mov x1, #PI4_VIBE_EXEC_REQUEST_BYTES
    bl pi4_validate_el0_user_range
    cbz x0, .Lpi4_lower_el_svc_runtime_exec_inval
    ldr x11, [sp]
    ldr x12, [x11, #PI4_VIBE_EXEC_REQUEST_ABI_VERSION_OFFSET]
    adr x10, pi4_status_pi4appreq_abi
    str x12, [x10]
    cmp x12, #PI4_VIBE_EXEC_REQUEST_ABI_VERSION
    b.ne .Lpi4_lower_el_svc_runtime_exec_inval
    ldr x12, [x11, #PI4_VIBE_EXEC_REQUEST_BYTES_OFFSET]
    adr x10, pi4_status_pi4appreq_bytes
    str x12, [x10]
    cmp x12, #PI4_VIBE_EXEC_REQUEST_BYTES
    b.ne .Lpi4_lower_el_svc_runtime_exec_inval
    ldr x13, [x11, #PI4_VIBE_EXEC_REQUEST_PATH_OFFSET]
    adr x10, pi4_status_pi4appreq_path
    str x13, [x10]
    mov x0, x13
    mov x1, #PI4_VIBE_FILE_PATH_MAX_BYTES
    bl pi4_validate_el0_user_range
    cbz x0, .Lpi4_lower_el_svc_runtime_exec_inval
    mov x0, x13
    mov x1, #PI4_VIBE_FILE_PATH_MAX_BYTES
    bl pi4_kernel_el0_strlen_bounded
    cmn x0, #1
    b.eq .Lpi4_lower_el_svc_runtime_exec_inval
    adr x10, pi4_status_pi4appreq_path_bytes
    str x0, [x10]
    mov x2, x0
    mov x0, x13
    adr x1, pi4_status_pi4appreq_path_copy
    bl pi4_kernel_copy_string_bounded
    cbz x0, .Lpi4_lower_el_svc_runtime_exec_inval
    ldr x14, [sp, #8]
    cbz x14, .Lpi4_lower_el_svc_runtime_exec_argv_ready
    mov x0, x14
    mov x1, #16
    bl pi4_validate_el0_user_range
    cbz x0, .Lpi4_lower_el_svc_runtime_exec_inval

.Lpi4_lower_el_svc_runtime_exec_argv_ready:
    mov x0, x13
    bl pi4_user_file_lookup_path
    cbz x0, .Lpi4_lower_el_svc_runtime_exec_inval
    mov x14, x1
    mov x15, #PI4_VIBE_FILE_ASSET_APP_ELF_BASE
    cmp x14, x15
    b.lo .Lpi4_lower_el_svc_runtime_exec_inval
    sub x12, x14, x15
    cmp x12, #PI4_VIBE_FILE_ASSET_APP_ELF_COUNT
    b.hs .Lpi4_lower_el_svc_runtime_exec_inval
    mov x0, x12
    bl pi4_app_record_ptr_by_index
    cbz x0, .Lpi4_lower_el_svc_runtime_exec_inval
    mov x15, x0
    ldr x6, [x15, #PI4_VIBE_APP_RECORD_ELF_STATUS]
    ldr x7, [x15, #PI4_VIBE_APP_RECORD_ELF_META]
.Lpi4_lower_el_svc_runtime_exec_have_app_meta:
    adr x10, pi4_status_pi4appreq_matched_asset
    str x14, [x10]
    adr x10, pi4_status_pi4appvfs_asset
    str x14, [x10]
    adr x10, pi4_status_pi4appvfs_status
    ldr w11, [x6]
    str x11, [x10]
    adr x10, pi4_status_pi4appvfs_entry_index
    mov x16, x7
    mov x15, #8
.Lpi4_lower_el_svc_runtime_exec_copy_app_vfs:
    ldr x11, [x7], #8
    str x11, [x10], #8
    subs x15, x15, #1
    b.ne .Lpi4_lower_el_svc_runtime_exec_copy_app_vfs
    mov x0, x12
    mov x1, sp
    mov x2, x16
    bl pi4_exec_app_from_vfs
    mov x9, x0
    b .Lpi4_lower_el_svc_runtime_exec_store_result

.Lpi4_lower_el_svc_runtime_exec_inval:
    mov x9, #PI4_VIBE_EINVAL
    neg x9, x9

.Lpi4_lower_el_svc_runtime_exec_store_result:
    adr x10, pi4_status_pi4exec_result
    str x9, [x10]
    b .Lpi4_lower_el_svc_runtime_return

.Lpi4_lower_el_svc_runtime_ioctl:
    adr x10, pi4_status_svc_runtime_ioctl_count
    ldr x11, [x10]
    add x11, x11, #1
    str x11, [x10]
    ldr x10, [sp]
    cmp x10, #PI4_VIBE_DISPLAY_FD
    b.ne .Lpi4_lower_el_svc_runtime_inval
    ldr x10, [sp, #8]
    mov x11, #PI4_VIBE_IOCTL_FBINFO
    cmp x10, x11
    b.eq .Lpi4_lower_el_svc_runtime_ioctl_fbinfo
    mov x11, #PI4_VIBE_IOCTL_PRESENT_INDEXED
    cmp x10, x11
    b.eq .Lpi4_lower_el_svc_runtime_ioctl_present_indexed
    b .Lpi4_lower_el_svc_runtime_inval

.Lpi4_lower_el_svc_runtime_ioctl_fbinfo:
    ldr x10, [sp, #16]
    mov x0, x10
    mov x1, #PI4_VIBE_FB_INFO_BYTES
    bl pi4_validate_el0_user_range
    cbz x0, .Lpi4_lower_el_svc_runtime_inval
    ldr x10, [sp, #16]
    adr x11, pi4_status_pi4fb
    ldr w11, [x11]
    ldr w12, =VIBE_PI4_STATUS_PI4FB_OK
    cmp w11, w12
    b.ne .Lpi4_lower_el_svc_runtime_enosys
    adr x11, pi4_status_svc_runtime_fbinfo_count
    ldr x12, [x11]
    add x12, x12, #1
    str x12, [x11]
    mov x13, x10
    mov x12, #PI4_VIBE_FB_INFO_BYTES
.Lpi4_lower_el_svc_runtime_fbinfo_zero:
    str xzr, [x10], #8
    subs x12, x12, #8
    b.ne .Lpi4_lower_el_svc_runtime_fbinfo_zero
    adr x10, pi4_status_pi4fb
    ldr w10, [x10]
    ldr w11, =VIBE_PI4_STATUS_PI4FB_OK
    cmp w10, w11
    b.ne .Lpi4_lower_el_svc_runtime_ok
    adr x10, pi4_status_fb_width
    ldr x15, [x10]
    str x15, [x13]
    adr x10, pi4_status_fb_height
    ldr x16, [x10]
    str x16, [x13, #8]
    adr x10, pi4_status_fb_pitch
    ldr x17, [x10]
    str x17, [x13, #16]
    mov x14, #PI4_VIBE_FB_BACKEND_XRGB8888_LFB
    str x14, [x13, #24]
    ldr x14, =PI4_FB_PRESENT_FRAME_BYTES
    str x14, [x13, #32]
    mov x14, #PI4_VIBE_FB_RGB24_PALETTE_BYTES
    str x14, [x13, #40]
    adr x10, pi4_status_fb_present_scale
    ldr x14, [x10]
    str x14, [x13, #48]
    adr x10, pi4_status_fb_view_x
    ldr x14, [x10]
    str x14, [x13, #56]
    adr x10, pi4_status_fb_view_y
    ldr x14, [x10]
    str x14, [x13, #64]
    adr x10, pi4_status_fb_view_width
    ldr x14, [x10]
    str x14, [x13, #72]
    adr x10, pi4_status_fb_view_height
    ldr x14, [x10]
    str x14, [x13, #80]
    adr x10, pi4_status_fb_policy
    ldr x14, [x10]
    str x14, [x13, #88]
    adr x10, pi4_status_fb_dirty_x
    ldr x14, [x10]
    str x14, [x13, #96]
    adr x10, pi4_status_fb_dirty_y
    ldr x14, [x10]
    str x14, [x13, #104]
    adr x10, pi4_status_fb_dirty_width
    ldr x14, [x10]
    str x14, [x13, #112]
    adr x10, pi4_status_fb_dirty_height
    ldr x14, [x10]
    str x14, [x13, #120]
    adr x10, pi4_status_fb_dirty_count
    ldr x14, [x10]
    str x14, [x13, #128]
    mov x14, #(PI4_VIBE_FB_CAP_PRESENT_INDEXED | PI4_VIBE_FB_CAP_PRESENT_RGB_PALETTE | PI4_VIBE_FB_CAP_XRGB8888_LFB | PI4_VIBE_FB_CAP_DIRTY_SOURCE_RECT | PI4_VIBE_FB_CAP_PRESENT_FULLSCREEN_SCALE)
    str x14, [x13, #136]
    mov x14, #PI4_VIBE_FB_FORMAT_INDEX8_RGB24
    str x14, [x13, #144]
    mov x14, #PI4_FB_PRESENT_MAX_WIDTH
    str x14, [x13, #152]
    mov x14, #PI4_FB_PRESENT_MAX_HEIGHT
    str x14, [x13, #160]
    adr x10, pi4_status_fb_abi_mask
    ldr x11, [x10]
    orr x11, x11, #PI4_FB_ABI_INFO
    str x11, [x10]
    adr x10, pi4_status_fb_abi_last_op
    mov x11, #PI4_FB_ABI_INFO
    str x11, [x10]
    adr x10, pi4_status_fb_abi_last_source
    str xzr, [x10]
    b .Lpi4_lower_el_svc_runtime_ok

.Lpi4_lower_el_svc_runtime_ioctl_present_indexed:
    ldr x10, [sp, #16]
    mov x0, x10
    mov x1, #PI4_VIBE_PRESENT_INDEXED_BYTES
    bl pi4_validate_el0_user_range
    cbz x0, .Lpi4_lower_el_svc_runtime_inval
    ldr x10, [sp, #16]
    ldr x11, [x10]
    ldr x12, [x10, #8]
    ldr x13, [x10, #16]
    ldr x14, [x10, #24]
    cbz x11, .Lpi4_lower_el_svc_runtime_inval
    cbz x12, .Lpi4_lower_el_svc_runtime_inval
    cbz x13, .Lpi4_lower_el_svc_runtime_inval
    cbz x14, .Lpi4_lower_el_svc_runtime_inval
    cmp x13, #PI4_FB_PRESENT_MAX_WIDTH
    b.hi .Lpi4_lower_el_svc_runtime_inval
    cmp x14, #PI4_FB_PRESENT_MAX_HEIGHT
    b.hi .Lpi4_lower_el_svc_runtime_inval
    mul x15, x13, x14
    mov x0, x11
    mov x1, x15
    bl pi4_validate_el0_user_range
    cbz x0, .Lpi4_lower_el_svc_runtime_inval
    mov x0, x12
    mov x1, #PI4_VIBE_FB_RGB24_PALETTE_BYTES
    bl pi4_validate_el0_user_range
    cbz x0, .Lpi4_lower_el_svc_runtime_inval
    ldr x10, [sp, #16]
    mov x0, x10
    mov x1, #PI4_FB_PRESENT_SOURCE_IOCTL
    sub sp, sp, #16
    str x30, [sp]
    bl pi4_present_indexed_frame
    ldr x30, [sp]
    add sp, sp, #16
    mov x9, x0
    cbnz x9, .Lpi4_lower_el_svc_runtime_return
    ldr x10, [sp, #16]
    ldr x13, [x10, #16]
    ldr x14, [x10, #24]
    adr x10, pi4_status_svc_runtime_present_count
    ldr x11, [x10]
    add x11, x11, #1
    str x11, [x10]
    adr x10, pi4_status_svc_runtime_last_present_width
    str x13, [x10]
    adr x10, pi4_status_svc_runtime_last_present_height
    str x14, [x10]
    bl pi4_uart_write_status_line
    b .Lpi4_lower_el_svc_runtime_ok

.Lpi4_lower_el_svc_runtime_poll_input:
    ldr x10, [sp]
    ldr x11, [sp, #8]
    cmp x11, #PI4_VIBE_INPUT_EVENT_BYTES
    b.lo .Lpi4_lower_el_svc_runtime_inval
    mov x0, x10
    mov x1, #PI4_VIBE_INPUT_EVENT_BYTES
    bl pi4_validate_el0_user_range
    cbz x0, .Lpi4_lower_el_svc_runtime_inval
    ldr x10, [sp]
    adr x11, pi4_status_svc_runtime_input_count
    ldr x12, [x11]
    add x12, x12, #1
    str x12, [x11]
    adr x11, pi4_status_svc_runtime_poll_count
    ldr x12, [x11]
    add x12, x12, #1
    str x12, [x11]
    mov x19, x10
    mov x0, x19
    mov x1, #PI4_VIBE_INPUT_EVENT_BYTES
    bl pi4_zero_buffer
    ldr x16, =pi4_uart_input_poll
    blr x16
    ldr x16, =pi4_uart_input_pop
    blr x16
    cbz x0, .Lpi4_lower_el_svc_runtime_poll_none
    cmp x0, #PI4_UART_INPUT_MOUSE_PACKET
    b.eq .Lpi4_lower_el_svc_runtime_poll_mouse
    mov x1, x0
    mov x0, x19
    bl pi4_write_uart_input_event
    bl pi4_uart_write_status_line
    mov x9, #1
    b .Lpi4_lower_el_svc_runtime_return
.Lpi4_lower_el_svc_runtime_poll_mouse:
    mov x0, x19
    bl pi4_write_uart_mouse_input_event
    bl pi4_uart_write_status_line
    mov x9, #1
    b .Lpi4_lower_el_svc_runtime_return
.Lpi4_lower_el_svc_runtime_poll_none:
    mov x9, xzr
    b .Lpi4_lower_el_svc_runtime_return

.Lpi4_lower_el_svc_runtime_input_status:
    ldr x10, [sp]
    ldr x11, [sp, #8]
    cmp x11, #PI4_VIBE_INPUT_STATUS_BYTES
    b.lo .Lpi4_lower_el_svc_runtime_inval
    mov x0, x10
    mov x1, #PI4_VIBE_INPUT_STATUS_BYTES
    bl pi4_validate_el0_user_range
    cbz x0, .Lpi4_lower_el_svc_runtime_inval
    ldr x10, [sp]
    adr x11, pi4_status_svc_runtime_input_count
    ldr x12, [x11]
    add x12, x12, #1
    str x12, [x11]
    adr x11, pi4_status_svc_runtime_input_status_count
    ldr x12, [x11]
    add x12, x12, #1
    str x12, [x11]
    mov x0, x10
    bl pi4_write_uart_input_status
    b .Lpi4_lower_el_svc_runtime_ok

.Lpi4_lower_el_svc_runtime_input_device_status:
    ldr x10, [sp]
    ldr x11, [sp, #8]
    ldr x12, [sp, #16]
    cmp x12, #PI4_VIBE_INPUT_DEVICE_STATUS_BYTES
    b.lo .Lpi4_lower_el_svc_runtime_inval
    mov x0, x11
    mov x1, #PI4_VIBE_INPUT_DEVICE_STATUS_BYTES
    bl pi4_validate_el0_user_range
    cbz x0, .Lpi4_lower_el_svc_runtime_inval
    ldr x10, [sp]
    ldr x11, [sp, #8]
    cmp x10, #PI4_VIBE_INPUT_DEVICE_KEYBOARD
    b.eq .Lpi4_lower_el_svc_runtime_input_device_known
    cmp x10, #PI4_VIBE_INPUT_DEVICE_MOUSE
    b.eq .Lpi4_lower_el_svc_runtime_input_device_known
    cmp x10, #PI4_VIBE_INPUT_DEVICE_UART
    b.eq .Lpi4_lower_el_svc_runtime_input_device_known
    cmp x10, #PI4_VIBE_INPUT_DEVICE_USB
    b.eq .Lpi4_lower_el_svc_runtime_input_device_known
    b .Lpi4_lower_el_svc_runtime_inval
.Lpi4_lower_el_svc_runtime_input_device_known:
    adr x12, pi4_status_svc_runtime_input_count
    ldr x13, [x12]
    add x13, x13, #1
    str x13, [x12]
    adr x12, pi4_status_svc_runtime_input_device_status_count
    ldr x13, [x12]
    add x13, x13, #1
    str x13, [x12]
    mov x0, x10
    mov x1, x11
    bl pi4_write_uart_input_device_status
    mov x9, x0
    b .Lpi4_lower_el_svc_runtime_return

.Lpi4_lower_el_svc_runtime_exit:
    ldr x9, [sp]
    adr x10, pi4_status_svc_runtime_exit_code
    str x9, [x10]
    adr x10, pi4_status_proc_current_pid
    ldr x12, [x10]
    cbnz x12, .Lpi4_lower_el_svc_runtime_exit_have_pid
    mov x12, #PI4_PROC_PID_INIT
.Lpi4_lower_el_svc_runtime_exit_have_pid:
    mov x16, #-1
    mov x17, xzr
    ldr x13, =pi4_process_table
    mov x14, #PI4_PROC_TABLE_CAPACITY
.Lpi4_lower_el_svc_runtime_exit_mark_next:
    cbz x14, .Lpi4_lower_el_svc_runtime_exit_accounted
    ldr x15, [x13, #8]
    cmp x15, x12
    b.eq .Lpi4_lower_el_svc_runtime_exit_mark_current
    add x13, x13, #PI4_PROC_TABLE_ENTRY_BYTES
    sub x14, x14, #1
    b .Lpi4_lower_el_svc_runtime_exit_mark_next
.Lpi4_lower_el_svc_runtime_exit_mark_current:
    mov x15, #PI4_PROC_STATE_RETURNED
    str x15, [x13, #0]
    ldr x17, [x13, #40]
    ldr x16, [x13, #48]
.Lpi4_lower_el_svc_runtime_exit_accounted:
    adr x10, pi4_status_proc_last_pid
    str x12, [x10]
    adr x10, pi4_status_proc_return_pid
    str x12, [x10]
    adr x10, pi4_status_proc_return_slot
    str x16, [x10]
    adr x10, pi4_status_proc_return_kind
    str x17, [x10]
    adr x10, pi4_status_proc_return_code
    str x9, [x10]
    adr x10, pi4_status_proc_return_elr
    str x1, [x10]
    adr x10, pi4_status_proc_el0_return_count
    ldr x11, [x10]
    add x11, x11, #1
    str x11, [x10]
    mov x18, x9
    mov x9, xzr
    adr x10, pi4_status_svc_runtime_last_result
    str x9, [x10]
    adr x10, pi4_status_el0_return_elr
    str x1, [x10]
    adr x10, pi4_status_pi4svc
    ldr w11, =VIBE_PI4_STATUS_PI4SVC_OK
    str w11, [x10]
    adr x10, pi4_status_pi4sysframe
    ldr w11, =VIBE_PI4_STATUS_PI4SYSFRAME_OK
    str w11, [x10]
    adr x10, pi4_status_pi4elf
    ldr w11, =VIBE_PI4_STATUS_PI4ELF_OK
    str w11, [x10]
    adr x10, pi4_status_runtime_gate
    ldr w11, =VIBE_PI4_GATE_RUNTIME_OK
    str w11, [x10]
    adr x10, pi4_status_last
    ldr w11, =VIBE_PI4_STATUS_VECTOR_HIT
    str w11, [x10]
    mov x11, #PI4_PROC_KIND_APP_BASE
    cmp x17, x11
    b.lo .Lpi4_lower_el_svc_runtime_exit_not_app
    sub x11, x17, x11
    cmp x11, #PI4_PROC_KIND_APP_COUNT
    b.lo .Lpi4_lower_el_svc_runtime_exit_app_return
.Lpi4_lower_el_svc_runtime_exit_not_app:
    adr x10, pi4_status_el0_return_el1
    ldr x10, [x10]
    cbnz x10, .Lpi4_lower_el_svc_runtime_exit_return_set
    adr x10, pi4_lower_el_svc_done
.Lpi4_lower_el_svc_runtime_exit_return_set:
    msr ELR_EL1, x10
    mov x10, #PI4_SPSR_EL1H_MASKED
    msr SPSR_EL1, x10
    b .Lpi4_lower_el_svc_restore_eret

.Lpi4_lower_el_svc_runtime_exit_app_return:
    mov x20, x12
    ldr x10, =pi4_process_table
    ldr x19, [x10, #8]
    cbnz x19, .Lpi4_lower_el_svc_runtime_exit_parent_pid_ready
    mov x19, #PI4_PROC_PID_INIT
    str x19, [x10, #8]
.Lpi4_lower_el_svc_runtime_exit_parent_pid_ready:
    ldr x11, [x10, #16]
    cbz x11, .Lpi4_lower_el_svc_runtime_exit_return_to_el1
    ldr x12, [x10, #24]
    cbz x12, .Lpi4_lower_el_svc_runtime_exit_return_to_el1
    mov x13, #PI4_PROC_STATE_INIT
    str x13, [x10, #0]
    adr x13, pi4_status_proc_current_pid
    str x19, [x13]
    adr x13, pi4_status_proc_last_pid
    str x20, [x13]
    adr x13, pi4_status_pi4sched_current_pid
    str x19, [x13]
    adr x13, pi4_status_pi4sched_last_pid
    str x20, [x13]
    adr x13, pi4_status_pi4preempt_from_pid
    str x20, [x13]
    adr x13, pi4_status_pi4preempt_to_pid
    str x19, [x13]
    ldr x0, =pi4_process_irq_frames
    str x18, [x0]
    mov x1, sp
    bl pi4_copy_irq_frame_256
    msr ELR_EL1, x11
    msr SP_EL0, x12
    ldr x13, [x10, #56]
    cbnz x13, .Lpi4_lower_el_svc_runtime_exit_parent_spsr_ready
    mov x13, #PI4_SPSR_EL0T_IRQ_UNMASKED
.Lpi4_lower_el_svc_runtime_exit_parent_spsr_ready:
    msr SPSR_EL1, x13
    b .Lpi4_lower_el_svc_restore_eret

.Lpi4_lower_el_svc_runtime_exit_return_to_el1:
    adr x10, pi4_status_el0_return_el1
    ldr x10, [x10]
    cbnz x10, .Lpi4_lower_el_svc_runtime_exit_return_set
    adr x10, pi4_lower_el_svc_done
    b .Lpi4_lower_el_svc_runtime_exit_return_set

.Lpi4_lower_el_svc_runtime_inval:
    adr x10, pi4_status_svc_runtime_bad_count
    ldr x11, [x10]
    add x11, x11, #1
    str x11, [x10]
    mov x9, #PI4_VIBE_EINVAL
    neg x9, x9
    b .Lpi4_lower_el_svc_runtime_return

.Lpi4_lower_el_svc_runtime_enosys:
    mov x9, #PI4_VIBE_ENOSYS
    neg x9, x9
    b .Lpi4_lower_el_svc_runtime_return

.Lpi4_lower_el_svc_runtime_ok:
    mov x9, xzr

.Lpi4_lower_el_svc_runtime_return:
    adr x10, pi4_status_svc_runtime_last_result
    str x9, [x10]
    str x9, [sp]
    b .Lpi4_lower_el_svc_restore_eret

.Lpi4_lower_el_svc_unexpected:
    adr x0, msg_stage_el0bad
    bl pi4_uart_write_string
    mrs x19, ESR_EL1
    mrs x20, ELR_EL1
    mov x0, x19
    bl pi4_uart_write_hex64
    bl pi4_uart_write_newline
    mov x0, x20
    bl pi4_uart_write_hex64
    bl pi4_uart_write_newline
    lsr x21, x19, #26
    ldr w22, =VIBE_PI4_FAULTMODE_SYNC
    cmp x21, #0x15
    b.ne .Lpi4_lower_el_unexpected_have_mode
    ldr w22, =VIBE_PI4_FAULTMODE_SVC
.Lpi4_lower_el_unexpected_have_mode:
    mov x0, x19
    mov x1, x20
    mov x2, x22
    bl pi4_mark_current_process_fault
    adr x5, pi4_status_pi4vec
    ldr w6, =VIBE_PI4_STATUS_VECTOR_UNEXPECTED
    str w6, [x5]
    adr x5, pi4_status_pi4svc
    ldr w6, =VIBE_PI4_STATUS_VECTOR_UNEXPECTED
    str w6, [x5]
    adr x5, pi4_status_pi4sysframe
    ldr w6, =VIBE_PI4_STATUS_VECTOR_UNEXPECTED
    str w6, [x5]
    adr x5, pi4_status_pi4elf
    ldr w6, =VIBE_PI4_STATUS_VECTOR_UNEXPECTED
    str w6, [x5]
    adr x5, pi4_status_last
    ldr w6, =VIBE_PI4_STATUS_VECTOR_UNEXPECTED
    str w6, [x5]
    ldr w0, =VIBE_PI4_FAULTSRC_EL0
    mov w1, w22
    bl pi4_record_panic_status
    bl pi4_uart_write_status_line
.Lpi4_lower_el_svc_unexpected_hold:
    wfe
    b .Lpi4_lower_el_svc_unexpected_hold

.Lpi4_lower_el_svc_restore_eret:
    ldp x28, x29, [sp, #224]
    ldr x30, [sp, #240]
    ldp x26, x27, [sp, #208]
    ldp x24, x25, [sp, #192]
    ldp x22, x23, [sp, #176]
    ldp x20, x21, [sp, #160]
    ldp x18, x19, [sp, #144]
    ldp x16, x17, [sp, #128]
    ldp x14, x15, [sp, #112]
    ldp x12, x13, [sp, #96]
    ldp x10, x11, [sp, #80]
    ldp x8, x9, [sp, #64]
    ldp x6, x7, [sp, #48]
    ldp x4, x5, [sp, #32]
    ldp x2, x3, [sp, #16]
    ldp x0, x1, [sp], #256
    eret
.size pi4_el1_lower_aarch64_sync_exception, . - pi4_el1_lower_aarch64_sync_exception

.type pi4_el1_unexpected_exception, %function
pi4_el1_unexpected_exception:
    mrs x0, ESR_EL1
    mrs x1, ELR_EL1
pi4_el1_unexpected_exception_recorded:
    mov x19, x0
    mov x20, x1
    adr x0, msg_stage_el1bad
    bl pi4_uart_write_string
    mov x0, x19
    bl pi4_uart_write_hex64
    bl pi4_uart_write_newline
    mov x0, x20
    bl pi4_uart_write_hex64
    bl pi4_uart_write_newline
    mov x0, x19
    mov x1, x20
    adr x2, pi4_status_esr_el1
    str x0, [x2]
    adr x2, pi4_status_elr_el1
    str x1, [x2]
    adr x2, pi4_status_pi4vec
    ldr w3, =VIBE_PI4_STATUS_VECTOR_UNEXPECTED
    str w3, [x2]
    adr x2, pi4_status_last
    ldr w3, =VIBE_PI4_STATUS_VECTOR_UNEXPECTED
    str w3, [x2]
    ldr w0, =VIBE_PI4_FAULTSRC_EL1
    ldr w1, =VIBE_PI4_FAULTMODE_VECTOR
    bl pi4_record_panic_status
    bl pi4_uart_write_status_line
.Lunexpected_exception_hold:
    wfe
    b .Lunexpected_exception_hold
.size pi4_el1_unexpected_exception, . - pi4_el1_unexpected_exception

.section .pi4_user_elf, "ax", %progbits
.balign 16
.global pi4_embedded_el0_elf
.type pi4_embedded_el0_elf, %object
pi4_embedded_el0_elf:
    .byte 0x7f, 'E', 'L', 'F'
    .byte PI4_ELF64_CLASS_64
    .byte PI4_ELF64_DATA_LSB
    .byte PI4_ELF64_VERSION_CURRENT
    .byte 0
    .byte 0, 0, 0, 0, 0, 0, 0, 0
    .hword PI4_ELF64_ET_EXEC
    .hword PI4_ELF64_EM_AARCH64
    .word PI4_ELF64_VERSION_CURRENT
    .quad pi4_el0_svc_probe
    .quad pi4_embedded_el0_elf_phdr - pi4_embedded_el0_elf
    .quad 0
    .word 0
    .hword PI4_ELF64_EHDR_SIZE
    .hword PI4_ELF64_PHDR_SIZE
    .hword PI4_ELF64_PHNUM
    .hword 0
    .hword 0
    .hword 0
pi4_embedded_el0_elf_phdr:
    .word PI4_ELF64_PT_LOAD
    .word PI4_ELF64_PF_RX
    .quad pi4_el0_svc_probe - pi4_embedded_el0_elf
    .quad pi4_el0_svc_probe
    .quad pi4_el0_svc_probe
    .quad pi4_el0_svc_probe_end - pi4_el0_svc_probe
    .quad pi4_el0_svc_probe_end - pi4_el0_svc_probe
    .quad 16
.balign 16
pi4_embedded_el0_elf_note:
    .asciz "PI4ELFPROBE embedded AArch64 ELF64 EL0 SVC probe"
.balign 8
pi4_embedded_user_argv0_string:
    .asciz "ABIPROBE.ELF"
.balign 8
pi4_nonembedded_user_argv0_string:
    .asciz "/SYSTEM/INIT.ELF"
.balign 16
.type pi4_el0_preempt_idle, %function
pi4_el0_preempt_idle:
    wfe
    b pi4_el0_preempt_idle
.size pi4_el0_preempt_idle, . - pi4_el0_preempt_idle

.balign 16
.type pi4_el0_preempt_source, %function
pi4_el0_preempt_source:
    movz x9, #0xffff
    movk x9, #0x00ff, lsl #16
.Lpi4_el0_preempt_source_wait:
    subs x9, x9, #1
    b.ne .Lpi4_el0_preempt_source_wait
    svc #PI4_EL0_SVC_EXIT
    b .Lpi4_el0_preempt_source_wait
.size pi4_el0_preempt_source, . - pi4_el0_preempt_source

.balign 16
.type pi4_el0_preempt_target, %function
pi4_el0_preempt_target:
    mov x8, #PI4_VIBE_SYS_GETPID
    svc #PI4_VIBE_SVC_IMM
    cmp x0, #PI4_PROC_PID_INIT
    b.ne .Lpi4_el0_preempt_target_bad
    svc #PI4_EL0_SVC_EXIT
.Lpi4_el0_preempt_target_bad:
    svc #PI4_EL0_SVC_BAD
    b .Lpi4_el0_preempt_target_bad
.size pi4_el0_preempt_target, . - pi4_el0_preempt_target

.balign 16
.global pi4_el0_svc_probe
.type pi4_el0_svc_probe, %function
pi4_el0_svc_probe:
    mov x9, sp
    and x10, x9, #0xf
    cbnz x10, .Lpi4_el0_svc_bad
    ldr x10, [x9]
    cmp x10, #1
    b.ne .Lpi4_el0_svc_bad
    ldr x10, [x9, #8]
    add x11, x9, #PI4_EL0_STACK_HEADER_BYTES
    cmp x10, x11
    b.ne .Lpi4_el0_svc_bad
    adr x12, pi4_embedded_user_argv0_string
    mov x13, xzr
.Lpi4_el0_svc_argv0_next:
    cmp x13, #PI4_EL0_STACK_ARGV0_BYTES
    b.hs .Lpi4_el0_svc_bad
    ldrb w14, [x10, x13]
    ldrb w15, [x12, x13]
    cmp w14, w15
    b.ne .Lpi4_el0_svc_bad
    cbz w14, .Lpi4_el0_svc_argv0_ok
    add x13, x13, #1
    b .Lpi4_el0_svc_argv0_next
.Lpi4_el0_svc_argv0_ok:
    ldr x10, [x9, #16]
    cbnz x10, .Lpi4_el0_svc_bad
    ldr x10, [x9, #24]
    cbnz x10, .Lpi4_el0_svc_bad
    ldr x10, [x9, #32]
    cmp x10, #PI4_VIBE_AT_PHDR
    b.ne .Lpi4_el0_svc_bad
    ldr x10, [x9, #40]
    adr x11, pi4_embedded_el0_elf_phdr
    cmp x10, x11
    b.ne .Lpi4_el0_svc_bad
    ldr x10, [x9, #48]
    cmp x10, #PI4_VIBE_AT_PHENT
    b.ne .Lpi4_el0_svc_bad
    ldr x10, [x9, #56]
    cmp x10, #PI4_ELF64_PHDR_SIZE
    b.ne .Lpi4_el0_svc_bad
    ldr x10, [x9, #64]
    cmp x10, #PI4_VIBE_AT_PHNUM
    b.ne .Lpi4_el0_svc_bad
    ldr x10, [x9, #72]
    cmp x10, #PI4_ELF64_PHNUM
    b.ne .Lpi4_el0_svc_bad
    ldr x10, [x9, #80]
    cmp x10, #PI4_VIBE_AT_PAGESZ
    b.ne .Lpi4_el0_svc_bad
    ldr x10, [x9, #88]
    cmp x10, #4096
    b.ne .Lpi4_el0_svc_bad
    ldr x10, [x9, #96]
    cmp x10, #PI4_VIBE_AT_ENTRY
    b.ne .Lpi4_el0_svc_bad
    ldr x10, [x9, #104]
    adr x11, pi4_el0_svc_probe
    cmp x10, x11
    b.ne .Lpi4_el0_svc_bad
    ldr x10, [x9, #112]
    cbnz x10, .Lpi4_el0_svc_bad
    ldr x10, [x9, #120]
    cbnz x10, .Lpi4_el0_svc_bad
    mov x0, #1
    svc #PI4_EL0_SVC_TRACE
    svc #PI4_EL0_SVC_ROUNDTRIP
    movz w1, #PI4_EL0_RETURN_MAGIC_LO
    movk w1, #PI4_EL0_RETURN_MAGIC_HI, lsl #16
    cmp w0, w1
    b.ne .Lpi4_el0_svc_bad
    mov x0, #2
    svc #PI4_EL0_SVC_TRACE
    mov x8, #PI4_VIBE_SYS_GETPID
    svc #PI4_VIBE_SVC_IMM
    cmp x0, #1
    b.ne .Lpi4_el0_svc_bad
    mov x0, #3
    svc #PI4_EL0_SVC_TRACE
    mov x0, #PI4_VIBE_CLOCK_MONOTONIC
    mov x1, x9
    mov x2, #PI4_VIBE_CLOCK_TIME_BYTES
    mov x8, #PI4_VIBE_SYS_CLOCK_GETTIME
    svc #PI4_VIBE_SVC_IMM
    cbnz x0, .Lpi4_el0_svc_bad
    ldr x10, [x9, #PI4_VIBE_CLOCK_TIME_TICKS_OFFSET]
    cbz x10, .Lpi4_el0_svc_bad
    ldr x10, [x9, #PI4_VIBE_CLOCK_TIME_FREQUENCY_HZ_OFFSET]
    cmp x10, #PI4_VIBE_CLOCK_MONOTONIC_HZ
    b.ne .Lpi4_el0_svc_bad
    ldr x10, [x9, #PI4_VIBE_CLOCK_TIME_MILLISECONDS_OFFSET]
    cbz x10, .Lpi4_el0_svc_bad
    ldr x10, [x9, #PI4_VIBE_CLOCK_TIME_FLAGS_OFFSET]
    tst x10, #PI4_VIBE_CLOCK_FLAG_KERNEL_OWNED
    b.eq .Lpi4_el0_svc_bad
    mov x0, #4
    svc #PI4_EL0_SVC_TRACE
    svc #PI4_EL0_SVC_EXIT
.Lpi4_el0_svc_bad:
    svc #PI4_EL0_SVC_BAD
    b .Lpi4_el0_svc_bad
pi4_el0_svc_probe_end:
.size pi4_el0_svc_probe, . - pi4_el0_svc_probe
.size pi4_embedded_el0_elf, . - pi4_embedded_el0_elf

.section .rodata, "a", %progbits
    .balign 8
pi4_fb_selftest_frame:
    .byte 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    .byte 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
    .byte 1, 0, 2, 2, 2, 2, 0, 3, 3, 3, 3, 0, 4, 4, 0, 1
    .byte 1, 0, 2, 5, 5, 2, 0, 3, 6, 6, 3, 0, 4, 7, 0, 1
    .byte 1, 0, 2, 5, 5, 2, 0, 3, 6, 6, 3, 0, 4, 7, 0, 1
    .byte 1, 0, 2, 2, 2, 2, 0, 3, 3, 3, 3, 0, 4, 4, 0, 1
    .byte 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
    .byte 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    .byte 5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 2, 2, 2, 2
    .balign 8
pi4_fb_selftest_palette:
    .byte 0x10, 0x16, 0x22
    .byte 0x5a, 0xd7, 0xff
    .byte 0xff, 0x4f, 0x8b
    .byte 0xff, 0xd1, 0x66
    .byte 0xf8, 0xf8, 0xff
    .byte 0x4c, 0xe0, 0x91
    .byte 0x6d, 0x8d, 0xff
    .byte 0xff, 0x6b, 0x5c
    .zero PI4_VIBE_FB_RGB24_PALETTE_BYTES - 24
    .balign 8
pi4_fb_selftest_present:
    .quad pi4_fb_selftest_frame
    .quad pi4_fb_selftest_palette
    .quad PI4_FB_SELFTEST_WIDTH
    .quad PI4_FB_SELFTEST_HEIGHT
    .balign 8
msg_banner:
    .asciz "vibe-os pi4: aarch64 assembly boot stub\r\n"
msg_load_addr:
    .asciz "status: kernel8 load address = "
msg_dtb:
    .asciz "status: firmware dtb pointer = "
msg_entry_el:
    .asciz "status: firmware entry current_el = "
msg_current_el:
    .asciz "status: active current_el = "
msg_mpidr:
    .asciz "status: mpidr_el1 = "
msg_uart_ready:
    .asciz "status: pl011 uart0 ready\r\n"
msg_stage_vectors:
    .asciz "status: stage vectors\r\n"
msg_stage_dtb:
    .asciz "status: stage dtb\r\n"
msg_stage_gic:
    .asciz "status: stage gic\r\n"
msg_stage_el1vec:
    .asciz "status: stage el1vec\r\n"
msg_stage_el0svc:
    .asciz "status: stage el0svc\r\n"
msg_stage_el0bad:
    .asciz "status: stage el0bad\r\n"
msg_stage_el0trace:
    .asciz "status: stage el0trace\r\n"
msg_stage_el0round:
    .asciz "status: stage el0round\r\n"
msg_stage_el1bad:
    .asciz "status: stage el1bad\r\n"
msg_stage_timer:
    .asciz "status: stage timer\r\n"
msg_stage_fb:
    .asciz "status: stage fb\r\n"
msg_stage_input:
    .asciz "status: stage input\r\n"
msg_stage_storage_enter:
    .asciz "status: stage storage-enter\r\n"
msg_stage_storage_reset:
    .asciz "status: stage storage-reset\r\n"
msg_stage_storage_probe:
    .asciz "status: stage storage-probe\r\n"
msg_stage_storage_read0:
    .asciz "status: stage storage-read0\r\n"
msg_stage_storage:
    .asciz "status: stage storage\r\n"
msg_stage_audio:
    .asciz "status: stage audio\r\n"
msg_framebuffer_gate:
    .asciz "status: mailbox framebuffer path recorded in status block\r\n"
msg_timer_gate:
    .asciz "status: timer irq/preempt path recorded in status block\r\n"
msg_runtime_gate:
    .asciz "status: el0 runtime path recorded in status block\r\n"
msg_elf_probe:
    .asciz "status: embedded elf64 el0 probe launched with bounded stack\r\n"
msg_holding:
    .asciz "status: holding in pi4 boot stub\r\n"
msg_el_wait:
    .asciz "gate: pi4 EL1/vector bring-up WAIT current_el = "
msg_status_prefix:
    .asciz "vibe-status arch=AARCH64 machine=PI4 image=PI4 artifact=OK pi4boot=OK pi4uart=OK pi4entry="
msg_status_slash:
    .asciz "/"
msg_status_current_el:
    .asciz " pi4el=EL1"
msg_status_dtb_ok:
    .asciz " pi4dtb=OK pi4dtbroot="
msg_status_dtb_bad:
    .asciz " pi4dtb=BAD pi4dtbroot="
msg_status_pi4boarddtb_ok:
    .asciz " pi4boarddtb=OK pi4model="
msg_status_pi4boarddtb_wait:
    .asciz " pi4boarddtb=WAIT pi4model="
msg_status_pi4compat:
    .asciz " pi4compat="
msg_status_pi4socdtb_ok:
    .asciz " pi4soc=WAIT pi4socdtb=OK pi4socrange="
msg_status_pi4socdtb_wait:
    .asciz " pi4soc=WAIT pi4socdtb=WAIT pi4socrange="
msg_status_pi4socrangelen:
    .asciz " pi4socrangelen="
msg_status_pi4mailbox_ok:
    .asciz " pi4mailbox=OK pi4fbmail="
msg_status_pi4mailbox_wait:
    .asciz " pi4mailbox=WAIT"
msg_status_gfx_ok:
    .asciz " gfx=OK"
msg_status_gfx_wait:
    .asciz " gfx=WAIT"
msg_status_fb_pi4fb:
    .asciz " fb=PI4FB"
msg_status_fb_wait:
    .asciz " fb=WAIT"
msg_status_fbgeom:
    .asciz " fbgeom="
msg_status_fbpresent:
    .asciz " fbpresent="
msg_status_fbdirty:
    .asciz " fbdirty="
msg_status_fbclear:
    .asciz " fbclear="
msg_status_fbchange:
    .asciz " fbchange="
msg_status_fbabi:
    .asciz " fbabi="
msg_status_pi4fb_ok:
    .asciz " pi4fb=OK"
msg_status_pi4fb_wait:
    .asciz " pi4fb=WAIT"
msg_status_pi4currentel:
    .asciz " pi4currentel="
msg_status_pi4gicdtb_ok:
    .asciz " pi4gicdtb=OK pi4gicnode="
msg_status_pi4gicdtb_wait:
    .asciz " pi4gicdtb=WAIT pi4gicnode="
msg_status_pi4giccompat:
    .asciz " pi4giccompat="
msg_status_pi4gicreg:
    .asciz " pi4gicreg="
msg_status_pi4gicreglen:
    .asciz " pi4gicreglen="
msg_status_pi4gicmmio_ok:
    .asciz " pi4gicmmio=OK pi4gicbase="
msg_status_pi4gicmmio_wait:
    .asciz " pi4gicmmio=WAIT pi4gicbase="
msg_status_pi4giccfg_ok:
    .asciz " pi4giccfg=OK pi4gicctl="
msg_status_pi4giccfg_wait:
    .asciz " pi4giccfg=WAIT pi4gicctl="
msg_status_pi4giciidr:
    .asciz " pi4giciidr="
msg_status_pi4irq_wait:
    .asciz " pi4irq=WAIT pi4timer=WAIT"
msg_status_pi4irq_ok:
    .asciz " pi4irq=OK irqctl=GIC pi4gic="
msg_status_clockhz:
    .asciz " clocksrc=ARMTMR clockhz="
msg_status_clocktick:
    .asciz " clocktick="
msg_status_clockirq:
    .asciz " clockirq="
msg_status_ticks:
    .asciz " ticks="
msg_status_pi4timer_ok:
    .asciz " pi4timer=OK"
msg_status_preempt_count:
    .asciz " preempt="
msg_status_pirq_count:
    .asciz " pirq="
msg_status_pctx_count:
    .asciz " pctx="
msg_status_pfrom_pid:
    .asciz " pfrom="
msg_status_pto_pid:
    .asciz " pto="
msg_status_pi4ctx:
    .asciz " pi4ctx="
msg_status_pi4sched:
    .asciz " pi4sched="
msg_status_pi4preempt:
    .asciz " pi4preempt="
msg_status_wait_value:
    .asciz "WAIT"
msg_status_ok_value:
    .asciz "OK"
msg_status_none_value:
    .asciz "NONE"
msg_status_assert_value:
    .asciz "ASSERT"
msg_status_boot_value:
    .asciz "BOOT"
msg_status_el_value:
    .asciz "EL"
msg_status_el1_value:
    .asciz "EL1"
msg_status_el0_value:
    .asciz "EL0"
msg_status_alloc_value:
    .asciz "ALLOC"
msg_status_elf_value:
    .asciz "ELF"
msg_status_stack_value:
    .asciz "STACK"
msg_status_sync_value:
    .asciz "SYNC"
msg_status_irq_value:
    .asciz "IRQ"
msg_status_svc_value:
    .asciz "SVC"
msg_status_vector_value:
    .asciz "VEC"
msg_status_enosys_value:
    .asciz "ENOSYS"
msg_status_einval_value:
    .asciz "EINVAL"
msg_status_eio_value:
    .asciz "EIO"
msg_status_emmc2_value:
    .asciz "EMMC2"
msg_status_emmc_value:
    .asciz "EMMC"
msg_status_vector_tuple:
    .asciz " pi4vec=OK pi4vbar="
msg_status_svc_tuple:
    .asciz " pi4svc=OK pi4sysframe="
msg_status_svcapi_tuple:
    .asciz " pi4svcapi="
msg_status_pi4clockapi:
    .asciz " pi4clockapi="
msg_status_svcptr_tuple:
    .asciz " pi4svcptr="
msg_status_pi4input:
    .asciz " pi4input=UART-LIVE"
msg_status_pi4usb_wait:
    .asciz " pi4usb=WAIT"
msg_status_pi4usb_host:
    .asciz " pi4usb=HOST"
msg_status_pi4usb_port:
    .asciz " pi4usb=PORT"
msg_status_pi4usb_addr:
    .asciz " pi4usb=ADDR"
msg_status_pi4usb_hid:
    .asciz " pi4usb=HID"
msg_status_pi4usb_keyboard:
    .asciz " pi4usb=KBD"
msg_status_pi4usb_mouse:
    .asciz " pi4usb=MOUSE"
msg_status_pi4usb_both:
    .asciz " pi4usb=BOTH"
msg_status_pi4inputdev:
    .asciz " pi4inputdev="
msg_status_pi4inputq:
    .asciz " pi4inputq="
msg_status_pi4inputlast:
    .asciz " pi4inputlast="
msg_status_pi4inputevt:
    .asciz " pi4inputevt="
msg_status_pi4uartrx:
    .asciz " pi4uartrx="
msg_status_elf_tuple:
    .asciz " pi4uabi=WAIT pi4elf=OK pi4elfsrc=EMBEDDED pi4elfprobe="
msg_status_pi4uabi_ok:
    .asciz " pi4uabi=OK exec=OK path=/SYSTEM/INIT.ELF uexec=OK upath=/SYSTEM/INIT.ELF uentry="
msg_status_pi4uabi_ok_path_prefix:
    .asciz " pi4uabi=OK exec=OK path="
msg_status_pi4uabi_ok_upath_prefix:
    .asciz " uexec=OK upath="
msg_status_pi4uabi_ok_uentry_prefix:
    .asciz " uentry="
msg_status_execsys_tuple:
    .asciz " execsys="
msg_status_pi4ustack_tuple:
    .asciz " pi4ustack="
msg_status_execmap_tuple:
    .asciz " execmap="
msg_status_pstat_tuple:
    .asciz " pstat="
msg_status_procpool_tuple:
    .asciz " procpool="
msg_status_pidseq_tuple:
    .asciz " pidseq="
msg_status_pexec_tuple:
    .asciz " pexec="
msg_status_preturn_tuple:
    .asciz " preturn="
msg_status_pfault_tuple:
    .asciz " pfault="
msg_status_elf_tuple_vfs:
    .asciz " pi4elf=OK pi4elfsrc=VFS"
msg_status_elf_entry:
    .asciz " pi4elfentry="
msg_status_elf_phdr:
    .asciz " pi4elfphdr="
msg_status_elf_load:
    .asciz " pi4elfload="
msg_status_ustack_tuple:
    .asciz " pi4estack="
msg_status_ustackv_tuple:
    .asciz " pi4estackv="
msg_status_pi4exec_tuple:
    .asciz " pi4exec=WAIT pi4execreq="
msg_status_pi4exec_ok_tuple:
    .asciz " pi4exec=OK pi4execreq="
msg_status_pi4appreq_tuple:
    .asciz " pi4appreq="
msg_status_pi4appvfs_tuple:
    .asciz " pi4appvfs="
msg_status_pi4userfile_tuple:
    .asciz " pi4userfile="
msg_status_pi4mem_wait:
    .asciz " pi4mem=WAIT pi4kmap="
msg_status_pi4mem_ok:
    .asciz " pi4mem=OK pi4kmap="
msg_status_pi4stack:
    .asciz " pi4stack="
msg_status_pi4umem:
    .asciz " pi4umem="
msg_status_pi4ualloc:
    .asciz " pi4ualloc="
msg_status_pi4fbmap:
    .asciz " pi4fbmap="
msg_status_pi4ptable:
    .asciz " pi4ptable="
msg_status_pi4storage_wait:
    .asciz " pi4sd=WAIT pi4fat=WAIT pi4vfs=WAIT"
msg_status_pi4sd:
    .asciz " pi4sd="
msg_status_pi4fat:
    .asciz " pi4fat="
msg_status_pi4vfs:
    .asciz " pi4vfs="
msg_status_pi4mbr:
    .asciz " pi4mbr="
msg_status_pi4bpb:
    .asciz " pi4bpb="
msg_status_pi4root:
    .asciz " pi4root="
msg_status_pi4kernel8:
    .asciz " pi4kernel8="
msg_status_pi4config:
    .asciz " pi4config="
msg_status_pi4init:
    .asciz " pi4init="
msg_status_pi4abiprobe:
    .asciz " pi4abiprobe="
msg_status_pi4app_record0:
    .asciz " pi4app0="
msg_status_pi4app_record1:
    .asciz " pi4app1="
msg_status_pi4app_record2:
    .asciz " pi4app2="
msg_status_pi4app_record3:
    .asciz " pi4app3="
msg_status_pi4manifest:
    .asciz " pi4manifest="
msg_status_pi4assets:
    .asciz " pi4assets="
msg_status_pi4wad:
    .asciz " pi4wad="
msg_status_pi4pak0:
    .asciz " pi4pak0="
msg_status_pi4initbuf:
    .asciz " pi4initbuf="
msg_status_pi4blk:
    .asciz " pi4blk="
msg_status_pi4blkreq:
    .asciz " pi4blkreq="
msg_status_pi4blkpio:
    .asciz " pi4blkpio="
msg_status_pi4sdctl:
    .asciz " pi4sdctl="
msg_status_pi4sdregs:
    .asciz " pi4sdregs="
msg_status_pi4audio_wait_none:
    .asciz " pi4audio=WAIT pi4audiohw=NONE pi4audiommio=NONE pi4audiomailbox=WAIT pi4audiocap=NONE pi4audioq=NONE pi4audioabi=NONE"
msg_status_pi4audio_wait_pwm:
    .asciz " pi4audio=HARDWARE-UNPROVEN pi4audiohw=PWM pi4audiommio="
msg_status_pi4audio_ok_pwm:
    .asciz " pi4audio=OK pi4audiohw=PWM pi4audiommio="
msg_status_pi4audio_wait_usb:
    .asciz " pi4audio=HARDWARE-UNPROVEN pi4audiohw=USB-AUDIO pi4audiommio="
msg_status_pi4audio_ok_usb:
    .asciz " pi4audio=OK pi4audiohw=USB-AUDIO pi4audiommio="
msg_status_pi4audio_mailbox:
    .asciz " pi4audiomailbox="
msg_status_pi4audio_cap:
    .asciz " pi4audiocap="
msg_status_pi4audio_usb:
    .asciz " pi4audiousb="
msg_status_pi4audio_queue_none:
    .asciz " pi4audioq=NONE"
msg_status_pi4audio_queue:
    .asciz " pi4audioq="
msg_status_pi4audio_abi_none:
    .asciz " pi4audioabi=NONE"
msg_status_pi4audio_abi:
    .asciz " pi4audioabi="
msg_status_pi4audiodev:
    .asciz " pi4audiodev="
msg_status_pi4audiofmt:
    .asciz " pi4audiofmt="
msg_status_pi4audiorate:
    .asciz " pi4audiorate="
msg_status_pi4audiocount:
    .asciz " pi4audiocount="
msg_status_suffix:
    .asciz " faultsrc=NONE faultmode=NONE pi4runtime=WAIT panic=NONE shutdown=NONE\r\n"
msg_status_suffix_ok:
    .asciz " faultsrc=NONE faultmode=NONE pi4runtime=OK panic=NONE shutdown=NONE\r\n"
msg_status_faultsrc:
    .asciz " faultsrc="
msg_status_faultmode:
    .asciz " faultmode="
msg_status_runtime_wait:
    .asciz " pi4runtime=WAIT"
msg_status_panic:
    .asciz " panic="
msg_status_shutdown_none:
    .asciz " shutdown=NONE\r\n"
pi4_apps_path_prefix_string:
    .asciz "/APPS/"
pi4_app_elf_leaf_string:
    .asciz "APP.ELF"
pi4_app_manifest_leaf_string:
    .asciz "APP.TXT"
pi4_app_index_path_string:
    .asciz "/APPS/INDEX.TXT"
    .balign 8
pi4_app_file_record_table:
    .quad pi4_storage_status_app0_dir_name
    .quad pi4_storage_status_app0_elf_entry_index
    .quad pi4_status_pi4userfile_app0_elf_offset
    .quad pi4_storage_status_app0_manifest
    .quad pi4_status_pi4userfile_app0_manifest_offset
    .quad pi4_storage_status_app0_elf
    .quad pi4_storage_status_app0_elf_read_count
    .quad pi4_storage_status_app0_dir
    .quad msg_status_pi4app_record0
    .quad pi4_storage_status_app1_dir_name
    .quad pi4_storage_status_app1_elf_entry_index
    .quad pi4_status_pi4userfile_app1_elf_offset
    .quad pi4_storage_status_app1_manifest
    .quad pi4_status_pi4userfile_app1_manifest_offset
    .quad pi4_storage_status_app1_elf
    .quad pi4_storage_status_app1_elf_read_count
    .quad pi4_storage_status_app1_dir
    .quad msg_status_pi4app_record1
    .quad pi4_storage_status_app2_dir_name
    .quad pi4_storage_status_app2_elf_entry_index
    .quad pi4_status_pi4userfile_app2_elf_offset
    .quad pi4_storage_status_app2_manifest
    .quad pi4_status_pi4userfile_app2_manifest_offset
    .quad pi4_storage_status_app2_elf
    .quad pi4_storage_status_app2_elf_read_count
    .quad pi4_storage_status_app2_dir
    .quad msg_status_pi4app_record2
    .quad pi4_storage_status_app3_dir_name
    .quad pi4_storage_status_app3_elf_entry_index
    .quad pi4_status_pi4userfile_app3_elf_offset
    .quad pi4_storage_status_app3_manifest
    .quad pi4_status_pi4userfile_app3_manifest_offset
    .quad pi4_storage_status_app3_elf
    .quad pi4_storage_status_app3_elf_read_count
    .quad pi4_storage_status_app3_dir
    .quad msg_status_pi4app_record3
pi4_app_file_record_table_end:
.if (pi4_app_file_record_table_end - pi4_app_file_record_table) != PI4_VIBE_APP_RECORD_TABLE_BYTES
.error "PI4 app file record table size does not match capacity bytes"
.endif
pi4_user_file_doom1_path:
    .asciz "DOOM1.WAD"
pi4_user_file_pak0_path:
    .asciz "/ID1/PAK0.PAK"
pi4_user_file_pak0_suffix:
    .asciz "ID1/PAK0.PAK"
pi4_user_file_manifest_suffix:
    .asciz "PROOF/MANIFEST.TXT"
pi4_user_file_readme_suffix:
    .asciz "ASSETS/README.TXT"
pi4_user_file_map_suffix:
    .asciz "ASSETS/MAPS/E1M1.MAP"
pi4_user_file_palette_suffix:
    .asciz "ASSETS/TEXTURES/PAL0.BIN"

.section .pi4_mailbox, "aw", %progbits
.balign 16
.global pi4_fb_mailbox_msg
pi4_fb_mailbox_msg:
    .word pi4_fb_mailbox_msg_end - pi4_fb_mailbox_msg
pi4_fb_mailbox_msg_code:
    .word 0
pi4_fb_phys_tag:
    .word PI4_MAILBOX_TAG_SET_PHYSICAL_SIZE
    .word 8
pi4_fb_phys_code:
    .word 8
pi4_fb_phys_width:
    .word PI4_FB_REQUEST_WIDTH
pi4_fb_phys_height:
    .word PI4_FB_REQUEST_HEIGHT
pi4_fb_virt_tag:
    .word PI4_MAILBOX_TAG_SET_VIRTUAL_SIZE
    .word 8
pi4_fb_virt_code:
    .word 8
pi4_fb_virt_width:
    .word PI4_FB_REQUEST_WIDTH
pi4_fb_virt_height:
    .word PI4_FB_REQUEST_HEIGHT
pi4_fb_offset_tag:
    .word PI4_MAILBOX_TAG_SET_VIRTUAL_OFFSET
    .word 8
pi4_fb_offset_code:
    .word 8
pi4_fb_offset_x:
    .word 0
pi4_fb_offset_y:
    .word 0
pi4_fb_depth_tag:
    .word PI4_MAILBOX_TAG_SET_DEPTH
    .word 4
pi4_fb_depth_code:
    .word 4
pi4_fb_depth_value:
    .word PI4_FB_REQUEST_DEPTH
pi4_fb_order_tag:
    .word PI4_MAILBOX_TAG_SET_PIXEL_ORDER
    .word 4
pi4_fb_order_code:
    .word 4
pi4_fb_order_value:
    .word PI4_FB_REQUEST_PIXEL_ORDER
pi4_fb_alloc_tag:
    .word PI4_MAILBOX_TAG_ALLOCATE_BUFFER
    .word 8
pi4_fb_alloc_code:
    .word 8
pi4_fb_alloc_align:
pi4_fb_alloc_base:
    .word PI4_FB_REQUEST_ALIGNMENT
pi4_fb_alloc_size:
    .word 0
pi4_fb_pitch_tag:
    .word PI4_MAILBOX_TAG_GET_PITCH
    .word 4
pi4_fb_pitch_code:
    .word 4
pi4_fb_pitch_value:
    .word 0
pi4_fb_mailbox_end_tag:
    .word PI4_MAILBOX_TAG_END
pi4_fb_mailbox_msg_end:
.size pi4_fb_mailbox_msg, . - pi4_fb_mailbox_msg

.balign 16
pi4_audio_mailbox_msg:
    .word pi4_audio_mailbox_msg_end - pi4_audio_mailbox_msg
pi4_audio_mailbox_msg_code:
    .word 0
pi4_audio_clock_state_tag:
    .word PI4_MAILBOX_TAG_GET_CLOCK_STATE
    .word 8
pi4_audio_clock_state_code:
    .word 4
pi4_audio_clock_state_id:
    .word PI4_MAILBOX_CLOCK_PWM
pi4_audio_clock_state_value:
    .word 0
pi4_audio_clock_rate_tag:
    .word PI4_MAILBOX_TAG_GET_CLOCK_RATE
    .word 8
pi4_audio_clock_rate_code:
    .word 4
pi4_audio_clock_rate_id:
    .word PI4_MAILBOX_CLOCK_PWM
pi4_audio_clock_rate_value:
    .word 0
pi4_audio_mailbox_end_tag:
    .word PI4_MAILBOX_TAG_END
pi4_audio_mailbox_msg_end:
.size pi4_audio_mailbox_msg, . - pi4_audio_mailbox_msg

.section .pi4_status, "aw", %progbits
.balign 8
.global pi4_status_words
pi4_status_words:
pi4_status_magic:
    .word VIBE_PI4_STATUS_MAGIC
pi4_status_version:
    .word VIBE_PI4_STATUS_VERSION
pi4_status_boot_entry:
    .word VIBE_PI4_STATUS_BOOT_ENTRY
pi4_status_framebuffer_gate:
    .word VIBE_PI4_GATE_FRAMEBUFFER_WAIT
pi4_status_timer_gate:
    .word VIBE_PI4_GATE_TIMER_WAIT
pi4_status_audio_gate:
    .word VIBE_PI4_GATE_AUDIO_TODO
pi4_status_runtime_gate:
    .word VIBE_PI4_GATE_RUNTIME_WAIT
pi4_status_last:
    .word VIBE_PI4_STATUS_HOLDING
pi4_status_pi4el:
    .word VIBE_PI4_STATUS_WAIT
pi4_status_pi4vec:
    .word VIBE_PI4_STATUS_WAIT
pi4_status_pi4vbar:
    .word VIBE_PI4_STATUS_WAIT
pi4_status_pi4svc:
    .word VIBE_PI4_STATUS_PI4SVC_WAIT
pi4_status_pi4sysframe:
    .word VIBE_PI4_STATUS_WAIT
pi4_status_pi4uabi:
    .word VIBE_PI4_STATUS_WAIT
pi4_status_pi4elf:
    .word VIBE_PI4_STATUS_WAIT
pi4_status_pi4dtb:
    .word VIBE_PI4_STATUS_WAIT
pi4_status_pi4soc:
    .word VIBE_PI4_STATUS_WAIT
pi4_status_pi4mailbox:
    .word VIBE_PI4_STATUS_WAIT
pi4_status_pi4fb:
    .word VIBE_PI4_STATUS_WAIT
pi4_status_gfx:
    .word VIBE_PI4_STATUS_WAIT
pi4_status_fb:
    .word VIBE_PI4_STATUS_WAIT
pi4_status_pi4socdtb:
    .word VIBE_PI4_STATUS_WAIT
pi4_status_pi4boarddtb:
    .word VIBE_PI4_STATUS_WAIT
pi4_status_pi4gicdtb:
    .word VIBE_PI4_STATUS_WAIT
pi4_status_pi4gicmmio:
    .word VIBE_PI4_STATUS_WAIT
pi4_status_pi4giccfg:
    .word VIBE_PI4_STATUS_WAIT
pi4_status_pi4irq:
    .word VIBE_PI4_STATUS_WAIT
pi4_status_pi4timer:
    .word VIBE_PI4_STATUS_WAIT
pi4_status_pi4preempt:
    .word VIBE_PI4_STATUS_WAIT
pi4_status_pi4sd:
    .word VIBE_PI4_STATUS_WAIT
pi4_status_pi4fat:
    .word VIBE_PI4_STATUS_WAIT
pi4_status_pi4vfs:
    .word VIBE_PI4_STATUS_WAIT
pi4_status_pi4audio:
    .word VIBE_PI4_STATUS_WAIT
pi4_status_pi4audiohw:
    .word VIBE_PI4_STATUS_NONE
pi4_status_pi4audiommio:
    .word VIBE_PI4_STATUS_NONE
pi4_status_pi4audiomailbox:
    .word VIBE_PI4_STATUS_WAIT
pi4_status_pi4audiocap:
    .word VIBE_PI4_STATUS_NONE
pi4_status_pi4audioq:
    .word VIBE_PI4_STATUS_NONE
pi4_status_pi4audioabi:
    .word VIBE_PI4_STATUS_NONE
pi4_status_faultsrc:
    .word VIBE_PI4_STATUS_NONE
pi4_status_faultmode:
    .word VIBE_PI4_STATUS_NONE
pi4_status_panic:
    .word VIBE_PI4_STATUS_NONE
.balign 8
pi4_audio_status_mmio_legacy_base:
    .quad 0
pi4_audio_status_mmio_arm_base:
    .quad 0
pi4_audio_status_mmio_span:
    .quad 0
pi4_audio_status_mmio_ready:
    .quad 0
pi4_audio_status_mailbox_success:
    .quad 0
pi4_audio_status_mailbox_clock_id:
    .quad 0
pi4_audio_status_mailbox_clock_rate:
    .quad 0
pi4_audio_status_mailbox_clock_state:
    .quad 0
pi4_audio_status_caps:
    .quad 0
pi4_audio_status_queue_bytes:
    .quad 0
pi4_audio_status_queue_usable:
    .quad 0
pi4_audio_status_queue_streams:
    .quad 0
pi4_audio_status_queue_underruns:
    .quad 0
pi4_audio_status_abi_observed:
    .quad 0
pi4_audio_status_abi_required:
    .quad 0
pi4_audio_status_abi_version:
    .quad 0
pi4_audio_status_abi_backend_ready:
    .quad 0
pi4_audio_status_abi_last_op:
    .quad 0
pi4_audio_status_call_count:
    .quad 0
pi4_audio_status_last_command:
    .quad 0
pi4_audio_status_last_result:
    .quad 0
pi4_audio_status_playback_start_count:
    .quad 0
pi4_audio_status_usb_ready:
    .quad 0
pi4_audio_status_usb_addr:
    .quad 0
pi4_audio_status_usb_interface:
    .quad 0
pi4_audio_status_usb_endpoint:
    .quad 0
pi4_audio_status_usb_mps:
    .quad 0
pi4_audio_status_usb_packets:
    .quad 0
pi4_audio_status_usb_bytes:
    .quad 0
pi4_audio_status_usb_last_hcint:
    .quad 0
pi4_audio_pcm_stream_handle:
    .quad 0
pi4_audio_pcm_stream_mode:
    .quad 0
pi4_audio_pcm_active_streams:
    .quad 0
pi4_audio_pcm_queued_bytes:
    .quad 0
pi4_audio_pcm_write_offset:
    .quad 0
pi4_audio_pcm_mixed_bytes:
    .quad 0
pi4_audio_pcm_drop_count:
    .quad 0
pi4_audio_pcm_pull_request_count:
    .quad 0
pi4_audio_pcm_pull_refill_count:
    .quad 0
pi4_audio_pcm_position_bytes:
    .quad 0
pi4_audio_pcm_lifecycle:
    .quad 0
pi4_status_dtb:
    .quad 0
pi4_status_entry_el:
    .quad 0
pi4_status_current_el:
    .quad 0
pi4_status_mpidr:
    .quad 0
pi4_status_vbar_el1:
    .quad 0
pi4_status_vector_hits:
    .quad 0
pi4_status_svc_hits:
    .quad 0
pi4_status_svc_runtime_hits:
    .quad 0
pi4_status_svc_runtime_last_number:
    .quad 0
pi4_status_svc_runtime_last_result:
    .quad 0
pi4_status_svc_runtime_bad_count:
    .quad 0
pi4_status_svc_runtime_getpid_count:
    .quad 0
.global pi4_status_svc_runtime_clock_count
pi4_status_svc_runtime_clock_count:
    .quad 0
.global pi4_status_svc_runtime_clock_last_ticks
pi4_status_svc_runtime_clock_last_ticks:
    .quad 0
.global pi4_status_svc_runtime_clock_last_hz
pi4_status_svc_runtime_clock_last_hz:
    .quad 0
.global pi4_status_svc_runtime_clock_last_ms
pi4_status_svc_runtime_clock_last_ms:
    .quad 0
pi4_status_svc_runtime_ioctl_count:
    .quad 0
pi4_status_svc_runtime_fbinfo_count:
    .quad 0
pi4_status_svc_runtime_present_count:
    .quad 0
pi4_status_svc_runtime_ptr_check_count:
    .quad 0
pi4_status_svc_runtime_ptr_bad_count:
    .quad 0
pi4_status_svc_runtime_ptr_last_base:
    .quad 0
pi4_status_svc_runtime_ptr_last_bytes:
    .quad 0
pi4_status_svc_runtime_input_count:
    .quad 0
pi4_status_svc_runtime_poll_count:
    .quad 0
pi4_status_svc_runtime_input_status_count:
    .quad 0
pi4_status_svc_runtime_input_device_status_count:
    .quad 0
pi4_runtime_input_key_state:
    .skip PI4_RUNTIME_INPUT_KEY_STATE_BYTES
pi4_status_svc_runtime_exit_code:
    .quad 0
pi4_status_svc_runtime_last_arg0:
    .quad 0
pi4_status_svc_runtime_last_arg1:
    .quad 0
pi4_status_svc_runtime_last_arg2:
    .quad 0
pi4_status_svc_runtime_last_present_width:
    .quad 0
pi4_status_svc_runtime_last_present_height:
    .quad 0
pi4_status_pi4exec_sysno:
    .quad 0
pi4_status_pi4exec_path:
    .quad 0
pi4_status_pi4exec_argv:
    .quad 0
pi4_status_pi4exec_envp:
    .quad 0
pi4_status_pi4exec_result:
    .quad 0
pi4_status_pi4exec_count:
    .quad 0
pi4_status_pi4appreq_request:
    .quad 0
pi4_status_pi4appreq_abi:
    .quad 0
pi4_status_pi4appreq_bytes:
    .quad 0
pi4_status_pi4appreq_path:
    .quad 0
pi4_status_pi4appreq_path_bytes:
    .quad 0
pi4_status_pi4appreq_path_copy:
    .skip PI4_VIBE_FILE_PATH_MAX_BYTES
    .balign 8
pi4_status_pi4appreq_matched_asset:
    .quad PI4_VIBE_FILE_ASSET_NONE
pi4_status_pi4appvfs_values_start:
pi4_status_pi4appvfs_asset:
    .quad PI4_VIBE_FILE_ASSET_NONE
pi4_status_pi4appvfs_status:
    .quad PI4_START_STORAGE_WAIT
pi4_status_pi4appvfs_entry_index:
    .quad 0
pi4_status_pi4appvfs_attr:
    .quad 0
pi4_status_pi4appvfs_cluster:
    .quad 0
pi4_status_pi4appvfs_size:
    .quad 0
pi4_status_pi4appvfs_plan_lba:
    .quad 0
pi4_status_pi4appvfs_plan_sectors:
    .quad 0
pi4_status_pi4appvfs_plan_bytes:
    .quad 0
pi4_status_pi4appvfs_read_count:
    .quad 0
pi4_status_pi4appvfs_values_end:
pi4_status_pi4userfile_values_start:
pi4_status_pi4userfile_op_mask:
    .quad 0
pi4_status_pi4userfile_last_op:
    .quad 0
pi4_status_pi4userfile_slot:
    .quad 0
pi4_status_pi4userfile_asset:
    .quad 0
pi4_status_pi4userfile_fd:
    .quad 0
pi4_status_pi4userfile_size:
    .quad 0
pi4_status_pi4userfile_offset:
    .quad 0
pi4_status_pi4userfile_requested:
    .quad 0
pi4_status_pi4userfile_result:
    .quad 0
pi4_status_pi4userfile_magic:
    .quad 0
pi4_status_pi4userfile_open_count:
    .quad 0
pi4_status_pi4userfile_size_count:
    .quad 0
pi4_status_pi4userfile_read_count:
    .quad 0
pi4_status_pi4userfile_values_end:
pi4_status_pi4userfile_doom_offset:
    .quad 0
pi4_status_pi4userfile_pak_offset:
    .quad 0
pi4_status_pi4userfile_app_record0_offset:
    .quad 0
pi4_status_pi4userfile_app_record1_offset:
    .quad 0
pi4_status_pi4userfile_app_record2_offset:
    .quad 0
pi4_status_pi4userfile_app_record3_offset:
    .quad 0
pi4_status_pi4userfile_app0_elf_offset:
    .quad 0
pi4_status_pi4userfile_app1_elf_offset:
    .quad 0
pi4_status_pi4userfile_app2_elf_offset:
    .quad 0
pi4_status_pi4userfile_app3_elf_offset:
    .quad 0
pi4_status_pi4userfile_manifest_offset:
    .quad 0
pi4_status_pi4userfile_readme_offset:
    .quad 0
pi4_status_pi4userfile_map_offset:
    .quad 0
pi4_status_pi4userfile_palette_offset:
    .quad 0
pi4_status_pi4userfile_app_index_offset:
    .quad 0
pi4_status_pi4userfile_app0_manifest_offset:
    .quad 0
pi4_status_pi4userfile_app1_manifest_offset:
    .quad 0
pi4_status_pi4userfile_app2_manifest_offset:
    .quad 0
pi4_status_pi4userfile_app3_manifest_offset:
    .quad 0
pi4_status_pi4userfile_proof_latched:
    .quad 0
pi4_status_pi4ptable_base:
    .quad 0
pi4_status_pi4ptable_capacity:
    .quad 0
pi4_status_pi4ptable_entry_bytes:
    .quad 0
pi4_status_pi4ptable_used:
    .quad 0
pi4_status_proc_current_pid:
    .quad 0
pi4_status_proc_last_pid:
    .quad 0
pi4_status_proc_next_pid:
    .quad 0
pi4_status_proc_alloc_count:
    .quad 0
.global pi4_status_proc_el0_launch_count
pi4_status_proc_el0_launch_count:
    .quad 0
.global pi4_status_proc_el0_return_count
pi4_status_proc_el0_return_count:
    .quad 0
.global pi4_status_proc_exec_launch_count
pi4_status_proc_exec_launch_count:
    .quad 0
pi4_status_proc_exec_pid:
    .quad 0
pi4_status_proc_exec_slot:
    .quad -1
pi4_status_proc_exec_kind:
    .quad 0
pi4_status_proc_exec_state:
    .quad 0
pi4_status_proc_exec_spsr:
    .quad 0
pi4_status_proc_return_pid:
    .quad 0
pi4_status_proc_return_slot:
    .quad -1
pi4_status_proc_return_kind:
    .quad 0
pi4_status_proc_return_code:
    .quad 0
pi4_status_proc_return_elr:
    .quad 0
pi4_status_proc_fault_pid:
    .quad 0
pi4_status_proc_fault_slot:
    .quad -1
pi4_status_proc_fault_kind:
    .quad 0
pi4_status_proc_fault_mode:
    .quad 0
pi4_status_proc_fault_esr:
    .quad 0
pi4_status_proc_fault_elr:
    .quad 0
pi4_status_proc_fault_count:
    .quad 0
pi4_status_esr_el1:
    .quad 0
pi4_status_elr_el1:
    .quad 0
pi4_status_sysframe_elr_el1:
    .quad 0
pi4_status_sysframe_spsr_el1:
    .quad 0
pi4_status_sysframe_sp_el0:
    .quad 0
pi4_status_el0_return_elr:
    .quad 0
pi4_status_el0_return_el1:
    .quad 0
pi4_status_sysframe_x0:
    .quad 0
pi4_status_pi4elf_base:
    .quad 0
pi4_status_pi4elf_entry:
    .quad 0
pi4_status_pi4elf_phdr:
    .quad 0
pi4_status_pi4elf_filesz:
    .quad 0
pi4_status_pi4elf_phent:
    .quad 0
pi4_status_pi4elf_phnum:
    .quad 0
pi4_status_pi4elf_load_vaddr:
    .quad 0
pi4_status_pi4elf_load_paddr:
    .quad 0
pi4_status_pi4elf_load_filesz:
    .quad 0
pi4_status_pi4elf_load_memsz:
    .quad 0
pi4_status_pi4elf_load_flags:
    .quad 0
pi4_status_pi4elf_load_align:
    .quad 0
pi4_status_pi4ustack_sp:
    .quad 0
pi4_status_pi4ustack_top:
    .quad 0
pi4_status_pi4ustack_bytes:
    .quad 0
pi4_status_pi4ustack_argc:
    .quad 0
pi4_status_pi4ustack_argv:
    .quad 0
pi4_status_pi4ustack_envp:
    .quad 0
pi4_status_pi4ustack_auxv:
    .quad 0
pi4_status_pi4ustack_flags:
    .quad 0
pi4_status_pi4el0_image_base:
    .quad 0
pi4_status_pi4el0_image_end:
    .quad 0
pi4_status_pi4el0_image_bytes:
    .quad 0
pi4_status_pi4el0_stack_base:
    .quad 0
pi4_status_pi4el0_stack_top:
    .quad 0
pi4_status_pi4el0_stack_bytes:
    .quad 0
pi4_status_pi4el0_alloc_flags:
    .quad 0
pi4_status_pi4el0_alloc_count:
    .quad 0
pi4_status_pi4dtb_root:
    .quad 0
pi4_status_pi4dtb_total_size:
    .quad 0
pi4_status_pi4dtb_version:
    .quad 0
pi4_status_pi4dtb_struct_off:
    .quad 0
pi4_status_pi4dtb_strings_off:
    .quad 0
pi4_status_pi4dtb_struct_size:
    .quad 0
pi4_status_pi4dtb_strings_size:
    .quad 0
pi4_status_pi4dtb_root_token:
    .quad 0
pi4_status_pi4socrange_bus:
    .quad 0
pi4_status_pi4socrange_periph:
    .quad 0
pi4_status_pi4socrange_span:
    .quad 0
pi4_status_pi4socrange_node:
    .quad 0
pi4_status_pi4socrange_len:
    .quad 0
pi4_status_pi4model_ptr:
    .quad 0
pi4_status_pi4model_len:
    .quad 0
pi4_status_pi4model_hash:
    .quad 0
pi4_status_pi4compat_ptr:
    .quad 0
pi4_status_pi4compat_len:
    .quad 0
pi4_status_pi4compat_hash:
    .quad 0
pi4_status_pi4gic_node:
    .quad 0
pi4_status_pi4gic_depth:
    .quad 0
pi4_status_pi4gic_interrupt:
    .quad 0
pi4_status_pi4giccompat_ptr:
    .quad 0
pi4_status_pi4giccompat_len:
    .quad 0
pi4_status_pi4giccompat_hash:
    .quad 0
pi4_status_pi4gicreg0:
    .quad 0
pi4_status_pi4gicreg1:
    .quad 0
pi4_status_pi4gicreg2:
    .quad 0
pi4_status_pi4gicreg3:
    .quad 0
pi4_status_pi4gicreg4:
    .quad 0
pi4_status_pi4gicreg5:
    .quad 0
pi4_status_pi4gicreg6:
    .quad 0
pi4_status_pi4gicreg7:
    .quad 0
pi4_status_pi4gicreg_len:
    .quad 0
pi4_status_pi4gic_dist_base:
    .quad 0
pi4_status_pi4gic_cpu_base:
    .quad 0
pi4_status_pi4gic_dist_len:
    .quad 0
pi4_status_pi4gic_cpu_len:
    .quad 0
pi4_status_pi4gic_dist_ctlr:
    .quad 0
pi4_status_pi4gic_cpu_ctlr:
    .quad 0
pi4_status_pi4gic_cpu_pmr:
    .quad 0
pi4_status_pi4gic_cpu_bpr:
    .quad 0
pi4_status_pi4gic_dist_typer:
    .quad 0
pi4_status_pi4gic_dist_iidr:
    .quad 0
pi4_status_pi4gic_cpu_iidr:
    .quad 0
pi4_status_timer_freq:
    .quad 0
pi4_status_timer_tick:
    .quad 0
pi4_status_timer_irq_id:
    .quad 0
pi4_status_timer_iar_id:
    .quad 0
pi4_status_timer_eoi_id:
    .quad 0
pi4_status_timer_ticks:
    .quad 0
pi4_status_pi4ctx_base:
    .quad 0
pi4_status_pi4ctx_bytes:
    .quad 0
pi4_status_pi4ctx_version:
    .quad 0
pi4_status_pi4ctx_pid:
    .quad 0
pi4_status_pi4ctx_kind:
    .quad 0
pi4_status_pi4ctx_elr:
    .quad 0
pi4_status_pi4ctx_sp:
    .quad 0
pi4_status_pi4ctx_spsr:
    .quad 0
pi4_status_pi4ctx_flags:
    .quad 0
pi4_status_pi4sched_attempts:
    .quad 0
pi4_status_pi4sched_no_peer:
    .quad 0
pi4_status_pi4sched_switches:
    .quad 0
pi4_status_pi4sched_irq_switches:
    .quad 0
pi4_status_pi4sched_current_pid:
    .quad 0
pi4_status_pi4sched_last_pid:
    .quad 0
pi4_status_pi4preempt_from_pid:
    .quad 0
pi4_status_pi4preempt_to_pid:
    .quad 0
pi4_status_irqframe_elr_el1:
    .quad 0
pi4_status_irqframe_spsr_el1:
    .quad 0
pi4_status_irqframe_sp_el0:
    .quad 0
pi4_status_irqframe_x0:
    .quad 0
pi4_status_irqframe_x1:
    .quad 0
pi4_status_irqframe_x2:
    .quad 0
pi4_status_irqframe_x3:
    .quad 0
pi4_status_irqframe_x4:
    .quad 0
pi4_status_irqframe_x5:
    .quad 0
pi4_status_irqframe_x6:
    .quad 0
pi4_status_irqframe_x7:
    .quad 0
pi4_status_irqframe_x8:
    .quad 0
pi4_status_irqframe_x9:
    .quad 0
pi4_status_irqframe_x10:
    .quad 0
pi4_status_irqframe_x11:
    .quad 0
pi4_status_irqframe_x12:
    .quad 0
pi4_status_irqframe_x13:
    .quad 0
pi4_status_irqframe_x14:
    .quad 0
pi4_status_irqframe_x15:
    .quad 0
pi4_status_irqframe_x16:
    .quad 0
pi4_status_irqframe_x17:
    .quad 0
pi4_status_irqframe_x18:
    .quad 0
pi4_status_irqframe_x19:
    .quad 0
pi4_status_irqframe_x20:
    .quad 0
pi4_status_irqframe_x21:
    .quad 0
pi4_status_irqframe_x22:
    .quad 0
pi4_status_irqframe_x23:
    .quad 0
pi4_status_irqframe_x24:
    .quad 0
pi4_status_irqframe_x25:
    .quad 0
pi4_status_irqframe_x26:
    .quad 0
pi4_status_irqframe_x27:
    .quad 0
pi4_status_irqframe_x28:
    .quad 0
pi4_status_irqframe_x29:
    .quad 0
pi4_status_irqframe_x30:
    .quad 0
pi4_status_irq_gic_dist_ctlr:
    .quad 0
pi4_status_irq_gic_cpu_ctlr:
    .quad 0
pi4_status_mbox_base:
    .quad 0
pi4_status_mbox_req:
    .quad 0
pi4_status_mbox_write:
    .quad 0
pi4_status_mbox_read:
    .quad 0
pi4_status_mbox_resp:
    .quad 0
pi4_status_mbox_status:
    .quad 0
pi4_status_mbox_fail:
    .quad 0
pi4_status_fb_bus_base:
    .quad 0
pi4_status_fb_cpu_base:
    .quad 0
pi4_status_fb_size:
    .quad 0
pi4_status_fb_pitch:
    .quad 0
pi4_status_fb_width:
    .quad 0
pi4_status_fb_height:
    .quad 0
pi4_status_fb_depth:
    .quad 0
pi4_status_fb_order:
    .quad 0
pi4_status_fb_format:
    .quad 0
pi4_status_fb_write:
    .quad 0
pi4_status_fb_sample:
    .quad 0
pi4_status_fb_present_count:
    .quad 0
pi4_status_fb_present_source:
    .quad 0
pi4_status_fb_present_width:
    .quad 0
pi4_status_fb_present_height:
    .quad 0
pi4_status_fb_present_scale:
    .quad 0
pi4_status_fb_policy:
    .quad PI4_VIBE_FB_POLICY_ASPECT
pi4_status_fb_view_x:
    .quad 0
pi4_status_fb_view_y:
    .quad 0
pi4_status_fb_view_width:
    .quad 0
pi4_status_fb_view_height:
    .quad 0
pi4_status_fb_last_view_x:
    .quad -1
pi4_status_fb_last_view_y:
    .quad -1
pi4_status_fb_last_view_width:
    .quad -1
pi4_status_fb_last_view_height:
    .quad -1
pi4_status_fb_dirty_x:
    .quad 0
pi4_status_fb_dirty_y:
    .quad 0
pi4_status_fb_dirty_width:
    .quad 0
pi4_status_fb_dirty_height:
    .quad 0
pi4_status_fb_dirty_count:
    .quad 0
pi4_status_fb_clear_count:
    .quad 0
pi4_status_fb_prev_frame_hash:
    .quad 0
pi4_status_fb_frame_hash:
    .quad 0
pi4_status_fb_change_count:
    .quad 0
pi4_status_fb_changed:
    .quad 0
pi4_status_fb_abi_mask:
    .quad 0
pi4_status_fb_abi_last_op:
    .quad 0
pi4_status_fb_abi_last_source:
    .quad 0
pi4_status_fb_fail:
    .quad 0
.global pi4_nonembedded_init_elf_buffer
.global pi4_nonembedded_init_elf_bytes
.global pi4_nonembedded_init_stack_base
.global pi4_nonembedded_init_stack_top
pi4_nonembedded_init_elf_buffer:
    .quad 0
pi4_nonembedded_init_elf_bytes:
    .quad 0
pi4_nonembedded_init_stack_base:
    .quad 0
pi4_nonembedded_init_stack_top:
    .quad 0
pi4_status_words_end:

.section .bss.stack, "aw", %nobits
.balign 16
pi4_boot_stack:
    .skip 16384
pi4_boot_stack_top:
pi4_el0_stack:
    .skip PI4_EL0_STACK_TOTAL_BYTES
pi4_el0_stack_top:

.section .bss.pi4_storage, "aw", %nobits
.balign 512

.section .bss.pi4_start_storage, "aw", %nobits
.balign 512
.global pi4_start_storage_mbr_sector_buffer
.type pi4_start_storage_mbr_sector_buffer, %object
pi4_start_storage_mbr_sector_buffer:
    .zero PI4_START_STORAGE_SECTOR_BYTES
.size pi4_start_storage_mbr_sector_buffer, . - pi4_start_storage_mbr_sector_buffer
.global pi4_start_storage_bpb_sector_buffer
.type pi4_start_storage_bpb_sector_buffer, %object
pi4_start_storage_bpb_sector_buffer:
    .zero PI4_START_STORAGE_SECTOR_BYTES
.size pi4_start_storage_bpb_sector_buffer, . - pi4_start_storage_bpb_sector_buffer
.global pi4_start_storage_root_dir_buffer
.type pi4_start_storage_root_dir_buffer, %object
pi4_start_storage_root_dir_buffer:
    .zero PI4_START_STORAGE_BUFFER_BYTES
.size pi4_start_storage_root_dir_buffer, . - pi4_start_storage_root_dir_buffer
.global pi4_start_storage_init_elf_buffer
.type pi4_start_storage_init_elf_buffer, %object
pi4_start_storage_init_elf_buffer:
    .zero PI4_START_STORAGE_BUFFER_BYTES
.size pi4_start_storage_init_elf_buffer, . - pi4_start_storage_init_elf_buffer
.global pi4_start_storage_app_elf_buffer
.type pi4_start_storage_app_elf_buffer, %object
pi4_start_storage_app_elf_buffer:
    .zero PI4_START_STORAGE_APP_ELF_BUFFER_BYTES
.size pi4_start_storage_app_elf_buffer, . - pi4_start_storage_app_elf_buffer
.global pi4_start_storage_user_file_buffer
.type pi4_start_storage_user_file_buffer, %object
pi4_start_storage_user_file_buffer:
    .zero PI4_START_STORAGE_SECTOR_BYTES
.size pi4_start_storage_user_file_buffer, . - pi4_start_storage_user_file_buffer

.section .bss.pi4_process, "aw", %nobits
.balign 16
pi4_process_table:
    .skip PI4_PROC_TABLE_ENTRY_BYTES * PI4_PROC_TABLE_CAPACITY
pi4_process_table_end:
pi4_process_context_record:
    .skip PI4_PROC_CONTEXT_BYTES
pi4_process_context_record_end:
pi4_process_irq_frames:
    .skip PI4_PROC_IRQ_FRAME_BYTES * PI4_PROC_TABLE_CAPACITY
pi4_process_irq_frames_end:
