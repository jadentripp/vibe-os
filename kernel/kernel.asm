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
SMOKE_STATUS_BYTES equ 4096
DOOM_LOG_BYTES equ 32
KEY_QUEUE_SIZE equ 32
KEY_QUEUE_MASK equ KEY_QUEUE_SIZE - 1
KEY_EVENT_DOWN equ 0x00000100
KEY_EVENT_VALID equ 0x00010000
KEY_PROOF_UP equ 0x00000001
KEY_PROOF_DOWN equ 0x00000002
KEY_PROOF_LEFT equ 0x00000004
KEY_PROOF_RIGHT equ 0x00000008
KEY_PROOF_FIRE equ 0x00000010
KEY_PROOF_USE equ 0x00000020
KEY_PROOF_MENU equ 0x00000040
KEY_PROOF_ENTER equ 0x00000080
MOUSE_QUEUE_SIZE equ 32
MOUSE_QUEUE_MASK equ MOUSE_QUEUE_SIZE - 1
MOUSE_EVENT_VALID equ 0x01000000
DOOM_SCREEN_WIDTH equ 320
DOOM_SCREEN_HEIGHT equ 200
DOOM_FRAME_BYTES equ DOOM_SCREEN_WIDTH * DOOM_SCREEN_HEIGHT
DOOM_PALETTE_BYTES equ 256 * 3
BOOT_INFO_ADDR equ 0x7000
VIDEO_BOOT_MAGIC equ 0x45444956
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
BOOT_VIDEO_FLAG_VBE equ 0x0001
BOOT_VIDEO_FLAG_LFB equ 0x0002
BOOT_VIDEO_FLAG_XRGB8888 equ 0x0004
VIDEO_BACKEND_MODE13 equ 1
VIDEO_BACKEND_LFB_XRGB8888 equ 2
PRESENT_POLICY_MODE13 equ 1
PRESENT_POLICY_ASPECT equ 2
PRESENT_POLICY_SQUARE equ 3
DOOM_ASPECT_HEIGHT equ 240
CODE_SEG equ 0x08
DATA_SEG equ 0x10
USER_CODE_SEG equ 0x1b
USER_DATA_SEG equ 0x23
TSS_SEG equ 0x28
KERNEL_STACK_TOP equ 0x00070000
PROC_KERNEL_PROCESS_STACK_TOP equ 0x00070000
PROC_USER_PROBE_KERNEL_STACK_TOP equ 0x00071000
PROC_PREEMPT_PROBE_KERNEL_STACK_TOP equ 0x00072000
PROC_DOOM_KERNEL_STACK_TOP equ 0x00073000
PROC_GENERIC0_KERNEL_STACK_TOP equ 0x00074000
PROC_GENERIC1_KERNEL_STACK_TOP equ 0x00075000
PIT_DIVISOR_100HZ equ 11932
PAGE_SIZE equ 0x1000
PTE_PRESENT equ 0x001
PTE_WRITE equ 0x002
PTE_USER equ 0x004
PTE_KERNEL_FLAGS equ PTE_PRESENT | PTE_WRITE
PTE_USER_READ_FLAGS equ PTE_PRESENT | PTE_USER
PTE_USER_WRITE_FLAGS equ PTE_PRESENT | PTE_WRITE | PTE_USER
PTE_USER_FLAGS equ PTE_USER_WRITE_FLAGS
PAGING_DIR_ADDR equ 0x00090000
PAGING_TABLES_ADDR equ 0x00091000
PAGING_TABLE_COUNT equ 8
PAGING_TOTAL_PAGES equ PAGING_TABLE_COUNT * 1024
PAGING_MAPPED_BYTES equ PAGING_TABLE_COUNT * 0x00400000
KERNEL_HIGHER_HALF_BASE equ 0xc0000000
KERNEL_HIGHER_HALF_PDE_INDEX equ KERNEL_HIGHER_HALF_BASE >> 22
FB_PAGE_TABLE_ADDR equ 0x0009c000
PROC_PROBE_PAGE_DIR_ADDR equ 0x00080000
PROC_PROBE_PDE3_TABLE_ADDR equ 0x00081000
PROC_DOOM_PAGE_DIR_ADDR equ 0x00082000
PROC_PREEMPT_PAGE_DIR_ADDR equ 0x00083000
PROC_DOOM_PDE4_TABLE_ADDR equ 0x00084000
PROC_DOOM_PDE5_TABLE_ADDR equ 0x00085000
PROC_DOOM_PDE6_TABLE_ADDR equ 0x00086000
PROC_DOOM_PDE7_TABLE_ADDR equ 0x00087000
PROC_PREEMPT_PDE3_TABLE_ADDR equ 0x00088000
PROC_GENERIC0_PAGE_DIR_ADDR equ 0x00089000
PROC_GENERIC0_PDE3_TABLE_ADDR equ 0x0008a000
PROC_GENERIC1_PAGE_DIR_ADDR equ 0x0008b000
PROC_GENERIC1_PDE3_TABLE_ADDR equ 0x0008c000
PMM_FRAME_MAP_ADDR equ 0x00099000
PMM_MANAGED_START equ 0x00100000
PMM_MANAGED_END equ 0x02000000
PMM_MANAGED_PAGES equ (PMM_MANAGED_END - PMM_MANAGED_START) / PAGE_SIZE
VMM_TEST_VADDR equ 0x00f00000
VMM_TEST_MAGIC equ 0x564d4d21
VMM_HIGH_TEST_VADDR equ KERNEL_HIGHER_HALF_BASE
VMM_HIGH_TEST_MAGIC equ 0x48494d4d
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
FAT_ROOT_CACHE_SECTORS equ 32
FAT_TABLE_CACHE_SECTORS equ 256
FAT_CACHE_BYTES equ FAT_TABLE_CACHE_SECTORS * 512 + FAT_ROOT_CACHE_SECTORS * 512
SECTOR_BUFFER_ADDR equ 0x0009b000
WAD_LOAD_ADDR equ 0x00900000
WAD_MAX_BYTES equ 0x00500000
FAT_TABLE_CACHE_ADDR equ WAD_LOAD_ADDR + WAD_MAX_BYTES
FAT_ROOT_CACHE_ADDR equ FAT_TABLE_CACHE_ADDR + FAT_TABLE_CACHE_SECTORS * 512
fat_table_cache equ FAT_TABLE_CACHE_ADDR
fat_root_cache equ FAT_ROOT_CACHE_ADDR
DOOM_ELF_LOAD_ADDR equ 0x01000000
DOOM_ELF_LIMIT equ 0x02000000
DOOM_ELF_MAX_BYTES equ DOOM_ELF_LIMIT - DOOM_ELF_LOAD_ADDR
DOOM_USER_BASE equ DOOM_ELF_LOAD_ADDR
DOOM_USER_HEAP_START equ 0x01900000
DOOM_USER_HEAP_END equ 0x01f00000
DOOM_USER_STACK_BOTTOM equ DOOM_USER_HEAP_END
DOOM_USER_STACK_TOP equ DOOM_ELF_LIMIT
DOOM_USER_END equ DOOM_ELF_LIMIT
DOOM_HEAP_PAGE_COUNT equ (DOOM_USER_HEAP_END - DOOM_USER_HEAP_START) / PAGE_SIZE
DOOM_HEAP_BITMAP_BYTES equ (DOOM_HEAP_PAGE_COUNT + 7) / 8
USER_KIND_NONE equ 0
USER_KIND_PROBE equ 1
USER_KIND_DOOM equ 2
USER_KIND_PREEMPT_PROBE equ 3
USER_KIND_GENERIC equ 4
PROC_STATE_UNUSED equ 0
PROC_STATE_READY equ 1
PROC_STATE_RUNNING equ 2
PROC_STATE_EXITED equ 3
PROC_STATE_FAULTED equ 4
PROCESS_SLOT_COUNT equ 6
PROCESS_GENERIC_SLOT_COUNT equ 2
PROCESS_RECORD_BYTES equ 168
PROCESS_EXEC_TABLE_COUNT equ 2
PROCESS_EXEC_ENTRY_BYTES equ 20
PROCESS_EXEC_PATH equ 0
PROCESS_EXEC_NAME83 equ 4
PROCESS_EXEC_LOAD_ADDR equ 8
PROCESS_EXEC_MAX_BYTES equ 12
PROCESS_EXEC_TARGET equ 16
PROC_PID equ 0
PROC_KIND equ 4
PROC_STATE equ 8
PROC_BASE equ 12
PROC_END equ 16
PROC_BRK equ 20
PROC_HEAP_START equ 24
PROC_HEAP_END equ 28
PROC_STACK_BOTTOM equ 32
PROC_STACK_TOP equ 36
PROC_ENTRY equ 40
PROC_SAVED_EAX equ 44
PROC_SAVED_EBX equ 48
PROC_SAVED_ECX equ 52
PROC_SAVED_EDX equ 56
PROC_SAVED_ESI equ 60
PROC_SAVED_EDI equ 64
PROC_SAVED_EBP equ 68
PROC_SAVED_ESP equ 72
PROC_SAVED_EIP equ 76
PROC_SAVED_EFLAGS equ 80
PROC_SAVED_CS equ 84
PROC_SAVED_SS equ 88
PROC_TICKS equ 92
PROC_RUNS equ 96
PROC_QUANTUM_TICKS equ 100
PROC_SWITCHES equ 104
PROC_PAGE_DIR equ 108
PROC_VM_REGIONS equ 112
PROC_VM_REGION_COUNT equ 116
PROC_VM_FLAGS equ 120
PROC_KERNEL_STACK_TOP equ 124
PROC_PARENT_PID equ 128
PROC_EXIT_STATUS equ 132
PROC_EXEC_COUNT equ 136
PROC_ARGC equ 140
PROC_ARGV equ 144
PROC_ENVP equ 148
PROC_ARGV0 equ 152
PROC_SLOT_GENERATION equ 156
PROC_HEAP_BITMAP equ 160
PROC_HEAP_PAGE_COUNT equ 164
PROC_FLAG_IRQ_FRAME_VALID equ 0x1
VM_REGION_BYTES equ 12
VM_REGION_BASE equ 0
VM_REGION_END equ 4
VM_REGION_FLAGS equ 8
VM_REGION_USER equ 0x1
VM_REGION_HEAP equ 0x2
VM_REGION_READ equ 0x4
VM_REGION_WRITE equ 0x8
VM_REGION_EXEC equ 0x10
SCHEDULER_QUANTUM_TICKS equ 5
C_RUNTIME_MAGIC equ 0xC0DEF00D
ELF_MAGIC equ 0x464c457f
ELFCLASS32 equ 1
ELFDATA2LSB equ 1
ET_EXEC equ 2
EM_386 equ 3
PT_LOAD equ 1
ELF_PHDR_SIZE equ 32
ELF_MAX_PHDRS equ 16
ELF_PH_FLAGS equ 24
ELF_PF_X equ 0x1
ELF_PF_W equ 0x2
ELF_PF_R equ 0x4
USER_ELF_LOAD_ADDR equ 0x00e40000
USER_ELF_MAX_BYTES equ 0x00020000
USER_CODE_ADDR equ 0x00e80000
USER_STACK_BOTTOM equ 0x00e90000
USER_STACK_TOP equ 0x00ea0000
USER_HEAP_START equ USER_STACK_TOP
USER_HEAP_END equ 0x00f00000
USER_HEAP_PAGE_COUNT equ (USER_HEAP_END - USER_HEAP_START) / PAGE_SIZE
USER_HEAP_BITMAP_BYTES equ (USER_HEAP_PAGE_COUNT + 7) / 8
USER_PROBE_EXPECTED_FLAGS equ 0x00003fff
USER_PROBE_MAGIC equ 0x13579BDF
PREEMPT_PROBE_MAGIC equ 0x50524545
USER_FAULT_ADDR equ 0x00010000
USER_FD_BASE equ 3
USER_FD_COUNT equ 16
FD_KIND_FREE equ 0
FD_KIND_WAD equ 1
FD_KIND_WRITABLE equ 2
FD_INHERIT_EXEC equ 0x1
WAIT_OPTION_WNOHANG equ 0x1
WAIT_SUPPORTED_OPTIONS equ WAIT_OPTION_WNOHANG
WAIT_PROOF_EXIT_STATUS equ 0x0000002a
WRITABLE_KNOWN_FILE_COUNT equ 7
WRITABLE_FILE_COUNT equ 16
WRITABLE_DEFAULT_CAPACITY equ 0x00004000
WRITABLE_SAVE_CAPACITY equ 0x00040000
WRITABLE_GENERIC_CAPACITY equ 0x00040000
PERSISTENCE_MARKER_COUNT equ 3
O_WRONLY equ 0x0001
O_RDWR equ 0x0002
O_ACCMODE equ 0x0003
O_CREAT equ 0x0100
O_TRUNC equ 0x0200
O_APPEND equ 0x0400
O_CLOEXEC equ 0x0800
O_KNOWN_MASK equ O_ACCMODE | O_CREAT | O_TRUNC | O_APPEND | O_CLOEXEC
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
SYS_POLL_KEY equ 11
SYS_CLOSE equ 12
SYS_AUDIO equ 13
SYS_POLL_MOUSE equ 14
SYS_GAMEPLAY_STATUS equ 15
SYS_EXEC equ 16
SYS_UNLINK equ 17
SYS_STAT equ 18
SYS_FSTAT equ 19
SYS_MMAP equ 20
SYS_MUNMAP equ 21
SYS_IOCTL equ 22
SYS_FORK equ 23
SYS_WAITPID equ 24
SYS_GETPID equ 25
SYS_PLAYER_DETAIL_STATUS equ 26
PLAYABLE_STATUS_FLAG equ 0x80000000
DOOM_INIT_STATUS_FLAG equ 0x40000000
SAVELOAD_STATUS_FLAG equ 0x20000000
SAVEACTION_STATUS_FLAG equ 0x10000000
SAVEACTION_GAMEACTION_SHIFT equ 8
SAVEACTION_SLOT_SHIFT equ 16
SAVELOAD_EVENT_OPEN equ 0x0001
SAVELOAD_EVENT_READ equ 0x0002
SAVELOAD_EVENT_WRITE equ 0x0004
SAVELOAD_EVENT_CLOSE equ 0x0008
SAVELOAD_SLOT_SHIFT equ 16
SYS_EXEC_PATH_MAX equ 16
MMAP_PROT_MASK equ 0x0000ffff
MMAP_FLAGS_SHIFT equ 16
MMAP_PROT_READ equ 0x00000001
MMAP_PROT_WRITE equ 0x00000002
MMAP_PROT_EXEC equ 0x00000004
MMAP_SUPPORTED_PROT equ MMAP_PROT_READ | MMAP_PROT_WRITE | MMAP_PROT_EXEC
MMAP_MAP_PRIVATE equ 0x00000002
MMAP_MAP_FIXED equ 0x00000010
MMAP_MAP_ANONYMOUS equ 0x00000020
MMAP_SUPPORTED_FLAGS equ MMAP_MAP_PRIVATE | MMAP_MAP_ANONYMOUS
IOCTL_DISPLAY_FD equ 1
VIBE_IOCTL_FBINFO equ 0x00005601
VIBE_IOCTL_PRESENT_INDEXED equ 0x00005602
VIBE_FB_INFO_WIDTH equ 0
VIBE_FB_INFO_HEIGHT equ 4
VIBE_FB_INFO_PITCH equ 8
VIBE_FB_INFO_BACKEND equ 12
VIBE_FB_INFO_FRAME_BYTES equ 16
VIBE_FB_INFO_PALETTE_BYTES equ 20
VIBE_FB_INFO_SCALE equ 24
VIBE_FB_INFO_VIEW_X equ 28
VIBE_FB_INFO_VIEW_Y equ 32
VIBE_FB_INFO_VIEW_WIDTH equ 36
VIBE_FB_INFO_VIEW_HEIGHT equ 40
VIBE_FB_INFO_POLICY equ 44
VIBE_FB_INFO_DIRTY_X equ 48
VIBE_FB_INFO_DIRTY_Y equ 52
VIBE_FB_INFO_DIRTY_WIDTH equ 56
VIBE_FB_INFO_DIRTY_HEIGHT equ 60
VIBE_FB_INFO_DIRTY_COUNT equ 64
VIBE_FB_INFO_BYTES equ 68
VIBE_PRESENT_DESC_FRAME equ 0
VIBE_PRESENT_DESC_PALETTE equ 4
VIBE_PRESENT_DESC_WIDTH equ 8
VIBE_PRESENT_DESC_HEIGHT equ 12
VIBE_PRESENT_DESC_BYTES equ 16
SYS_EXEC_ARGC_DEFAULT equ 1
SYS_EXEC_ARGV_SLOT_BYTES equ 12
SYS_EXEC_ARG_MAX equ 8
SYS_EXEC_ARG_STR_MAX equ 64
SYS_EXEC_ARG_FRAME_BASE_BYTES equ 12
SYS_EXEC_ARGV_SOURCE_DEFAULT equ 1
SYS_EXEC_ARGV_SOURCE_USER equ 2
SYSCALL_FRAME_EBP equ 0
SYSCALL_FRAME_EDI equ 4
SYSCALL_FRAME_ESI equ 8
SYSCALL_FRAME_EDX equ 12
SYSCALL_FRAME_ECX equ 16
SYSCALL_FRAME_EBX equ 20
SYSCALL_FRAME_EIP equ 24
SYSCALL_FRAME_CS equ 28
SYSCALL_FRAME_EFLAGS equ 32
SYSCALL_FRAME_ESP equ 36
SYSCALL_FRAME_SS equ 40
EXCEPTION_FRAME_VECTOR equ 0
EXCEPTION_FRAME_ERROR equ 4
EXCEPTION_FRAME_EIP equ 8
EXCEPTION_FRAME_CS equ 12
EXCEPTION_FRAME_EFLAGS equ 16
EXCEPTION_FRAME_ESP equ 20
EXCEPTION_FRAME_SS equ 24
EXPECTED_FAULT_INSTRUCTION_BYTES equ 2
PANIC_NONE equ 0
PANIC_UNHANDLED_EXCEPTION equ 1
SHUTDOWN_NONE equ 0
SHUTDOWN_HALT equ 1
SHUTDOWN_REBOOT equ 2
SHUTDOWN_POWEROFF equ 3
STAT_ST_MODE equ 8
STAT_ST_NLINK equ 12
STAT_ST_SIZE equ 28
STAT_BYTES equ 44
STAT_S_IFREG equ 0x00008000
STAT_S_IRUSR equ 0x00000100
STAT_S_IWUSR equ 0x00000080
STAT_MODE_READONLY_REG equ STAT_S_IFREG | STAT_S_IRUSR
STAT_MODE_WRITABLE_REG equ STAT_S_IFREG | STAT_S_IRUSR | STAT_S_IWUSR
ERRNO_ENOENT equ 2
ERRNO_EIO equ 5
ERRNO_EBADF equ 9
ERRNO_ECHILD equ 10
ERRNO_ENOMEM equ 12
ERRNO_EACCES equ 13
ERRNO_EINVAL equ 22
ERRNO_EMFILE equ 24
ERRNO_ENOTTY equ 25
ERRNO_ENOSYS equ 38
AUDIO_CMD_INIT equ 1
AUDIO_CMD_START_SFX equ 2
AUDIO_CMD_STOP_SFX equ 3
AUDIO_CMD_UPDATE_SFX equ 4
AUDIO_CMD_SHUTDOWN equ 5
AUDIO_CMD_IS_PLAYING equ 6
AUDIO_CMD_BUFFERED_BYTES equ 7
AUDIO_CMD_MUSIC_PULL_STATE equ 8
AUDIO_SFX_DESC_SAMPLES equ 0
AUDIO_SFX_DESC_LENGTH equ 4
AUDIO_SFX_DESC_VOLUME equ 8
AUDIO_SFX_DESC_SEPARATION equ 12
AUDIO_SFX_DESC_PITCH equ 16
AUDIO_SFX_DESC_SOUND_ID equ 20
AUDIO_SFX_DESC_FLAGS equ 24
AUDIO_SFX_DESC_SAMPLE_RATE equ 28
AUDIO_SFX_DESC_MUSIC_FORMAT equ 32
AUDIO_SFX_DESC_MUSIC_NOTE_EVENTS equ 36
AUDIO_SFX_DESC_MUSIC_CONTROL_EVENTS equ 40
AUDIO_SFX_DESC_MUSIC_ACTIVE_VOICE_PEAK equ 44
AUDIO_SFX_DESC_MUSIC_EMITTED_SAMPLES equ 48
AUDIO_SFX_DESC_MUSIC_STREAM_START equ 52
AUDIO_SFX_DESC_MUSIC_STREAM_END equ 56
AUDIO_SFX_DESC_MUSIC_STREAM_LOOP_COUNT equ 60
AUDIO_SFX_DESC_BYTES equ 64
AUDIO_FLAG_LOOP equ 0x00000001
AUDIO_FLAG_MUSIC equ 0x00000002
AUDIO_FLAG_WAD_SFX equ 0x00000004
AUDIO_FLAG_STREAM_FINAL equ 0x00000008
AUDIO_MUSIC_HANDLE_MASK equ 0xffff0000
AUDIO_MUSIC_HANDLE_BASE equ 0x4d550000
AUDIO_MUSIC_STREAM_NONE equ 0
AUDIO_MUSIC_STREAM_PUSH equ 1
AUDIO_MUSIC_STREAM_PULL equ 2
AUDIO_MAX_SFX_VOICES equ 8
AUDIO_MUSIC_PULL_LOW_WATER_BYTES equ 24576
AUDIO_PITCH_NORMAL equ 128
AUDIO_PITCH_STEP_NORMAL equ 0x00010000
AUDIO_PITCH_STEP_MIN equ 0x00004000
VGA_DAC_WRITE_INDEX equ 0x03c8
VGA_DAC_DATA equ 0x03c9
SB16_BASE equ 0x0220
SB16_MIXER_ADDR equ SB16_BASE + 0x04
SB16_MIXER_DATA equ SB16_BASE + 0x05
SB16_DSP_RESET equ SB16_BASE + 0x06
SB16_DSP_READ equ SB16_BASE + 0x0a
SB16_DSP_WRITE equ SB16_BASE + 0x0c
SB16_DSP_READ_STATUS equ SB16_BASE + 0x0e
SB16_DSP_ACK16 equ SB16_BASE + 0x0f
SB16_DSP_READY equ 0x80
SB16_DSP_RESET_ACK equ 0xaa
SB16_DSP_GET_VERSION equ 0xe1
SB16_DSP_SPEAKER_ON equ 0xd1
SB16_DSP_SPEAKER_OFF equ 0xd3
SB16_DSP_EXIT_8BIT_AUTO equ 0xda
SB16_DSP_SET_TIME_CONSTANT equ 0x40
SB16_DSP_SET_OUTPUT_RATE equ 0x41
SB16_DSP_SET_BLOCK_SIZE equ 0x48
SB16_DSP_8BIT_AUTO_OUT equ 0xc6
SB16_DSP_MODE_UNSIGNED_STEREO equ 0x20
SB16_DMA8_CHANNEL equ 1
SB16_DMA16_CHANNEL equ 5
SB16_IRQ_LINE equ 5
SB16_SAMPLE_RATE equ 11025
SB16_SAMPLE_RATE_HIGH equ SB16_SAMPLE_RATE / 256
SB16_SAMPLE_RATE_LOW equ SB16_SAMPLE_RATE & 0xff
SB16_TIME_CONSTANT equ 256 - (1000000 / SB16_SAMPLE_RATE)
SB16_DMA_BUFFER_BYTES equ 4096
SB16_DMA_BLOCK_BYTES equ SB16_DMA_BUFFER_BYTES / 2
SB16_MIXER_IRQ_SELECT equ 0x80
SB16_MIXER_DMA_SELECT equ 0x81
SB16_MIXER_IRQ5_BIT equ 0x02
SB16_MIXER_DMA_CH1_BIT equ 0x02
SB16_MIXER_DMA_CH5_BIT equ 0x20
DMA8_MASK_REG equ 0x0a
DMA8_MODE_REG equ 0x0b
DMA8_CLEAR_FLIPFLOP_REG equ 0x0c
DMA8_CH1_ADDR_REG equ 0x02
DMA8_CH1_COUNT_REG equ 0x03
DMA8_CH1_PAGE_REG equ 0x83
DMA8_CH1_AUTO_READ_MODE equ 0x59
PS2_DATA_PORT equ 0x0060
PS2_STATUS_PORT equ 0x0064
PS2_COMMAND_PORT equ 0x0064
PS2_STATUS_OUTPUT_FULL equ 0x01
PS2_STATUS_INPUT_FULL equ 0x02
PS2_COMMAND_READ_CONFIG equ 0x20
PS2_COMMAND_WRITE_CONFIG equ 0x60
PS2_COMMAND_ENABLE_AUX equ 0xa8
PS2_COMMAND_WRITE_AUX equ 0xd4
PS2_CONFIG_AUX_IRQ equ 0x02
PS2_CONFIG_AUX_CLOCK_DISABLE equ 0x20
PS2_MOUSE_ACK equ 0xfa
PS2_MOUSE_SET_DEFAULTS equ 0xf6
PS2_MOUSE_ENABLE_DATA equ 0xf4
PCI_CONFIG_ADDRESS equ 0x0cf8
PCI_CONFIG_DATA equ 0x0cfc
PCI_CONFIG_ENABLE equ 0x80000000
PCI_CONFIG_CLASS_REG equ 0x08
PCI_CONFIG_HEADER_REG equ 0x0c
PCI_HEADER_MULTIFUNCTION_FLAG equ 0x00800000
PCI_CLASS_MASS_STORAGE equ 0x01
PCI_CLASS_BRIDGE equ 0x06
PCI_SCAN_DEVICE_COUNT equ 32
PCI_SCAN_FUNCTION_COUNT equ 8
PCI_SCAN_FUNCTION_PROBES equ PCI_SCAN_DEVICE_COUNT * PCI_SCAN_FUNCTION_COUNT
PCI_TABLE_ENTRY_DWORDS equ 4
PCI_TABLE_ENTRY_SIZE equ PCI_TABLE_ENTRY_DWORDS * 4
PCI_TABLE_BDF_OFFSET equ 0
PCI_TABLE_ID_OFFSET equ 4
PCI_TABLE_CLASS_OFFSET equ 8
PCI_TABLE_HEADER_OFFSET equ 12
PCI_TABLE_MAX_ENTRIES equ PCI_SCAN_FUNCTION_PROBES
ATA_DATA equ 0x01f0
ATA_ERROR equ 0x01f1
ATA_SECTOR_COUNT equ 0x01f2
ATA_LBA_LOW equ 0x01f3
ATA_LBA_MID equ 0x01f4
ATA_LBA_HIGH equ 0x01f5
ATA_DRIVE_HEAD equ 0x01f6
ATA_COMMAND_STATUS equ 0x01f7
ATA_CMD_READ_SECTORS equ 0x20
ATA_CMD_WRITE_SECTORS equ 0x30
ATA_STATUS_ERR equ 0x01
ATA_STATUS_DRQ equ 0x08
ATA_STATUS_DF equ 0x20
ATA_STATUS_BSY equ 0x80
ATA_WAIT_POLL_LIMIT equ 0x20000
ATA_OP_NONE equ 0
ATA_OP_READ equ 1
ATA_OP_WRITE equ 2
ATA_WAIT_IDLE equ 0
ATA_WAIT_BUSY equ 1
ATA_WAIT_DRQ equ 2
ATA_WAIT_READY equ 3
ATA_WAIT_DATA equ 4
ACPI_PM1A_CNT_PORT equ 0x0604
ACPI_PM1_CNT_S5_ENABLE equ 0x2000
BOCHS_PM1A_CNT_PORT equ 0xb004
VIRTUALBOX_PM1A_CNT_PORT equ 0x4004
VIRTUALBOX_PM1_CNT_S5_ENABLE equ 0x3400
RESET_CONTROL_PORT equ 0x0cf9
RESET_CONTROL_SYSTEM equ 0x02
RESET_CONTROL_FULL_RESET equ 0x06
CMOS_INDEX_PORT equ 0x70
CMOS_DATA_PORT equ 0x71
CMOS_RTC_SECONDS_REGISTER equ 0x00
SHUTDOWN_PROOF_DELAY_SECONDS equ 20

SC_LSHIFT equ 0x2a
SC_RSHIFT equ 0x36
DOOM_KEY_RIGHTARROW equ 0xae
DOOM_KEY_LEFTARROW equ 0xac
DOOM_KEY_UPARROW equ 0xad
DOOM_KEY_DOWNARROW equ 0xaf
DOOM_KEY_ESCAPE equ 27
DOOM_KEY_ENTER equ 13
DOOM_KEY_TAB equ 9
DOOM_KEY_F1 equ 0xbb
DOOM_KEY_F2 equ 0xbc
DOOM_KEY_F3 equ 0xbd
DOOM_KEY_F4 equ 0xbe
DOOM_KEY_F5 equ 0xbf
DOOM_KEY_F6 equ 0xc0
DOOM_KEY_F7 equ 0xc1
DOOM_KEY_F8 equ 0xc2
DOOM_KEY_F9 equ 0xc3
DOOM_KEY_F10 equ 0xc4
DOOM_KEY_F11 equ 0xd7
DOOM_KEY_F12 equ 0xd8
DOOM_KEY_BACKSPACE equ 127
DOOM_KEY_PAUSE equ 0xff
DOOM_KEY_EQUALS equ 0x3d
DOOM_KEY_MINUS equ 0x2d
DOOM_KEY_RSHIFT equ 0xb6
DOOM_KEY_RCTRL equ 0x9d
DOOM_KEY_RALT equ 0xb8

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
    call framebuffer_init
    call pmm_init
    call pmm_self_test
    call vmm_self_test
    call heap_init
    call heap_self_test
    call fpu_self_test
    call libc_self_test
    call storage_init
    call pci_scan_qemu
    call audio_init
    call ps2_mouse_init
    call scheduler_init
    call scheduler_preempt_self_test
    call c_runtime_self_test
    cmp eax, C_RUNTIME_MAGIC
    je .c_runtime_ok
    mov byte [c_runtime_status], 2
    jmp .c_runtime_done

.c_runtime_ok:
    mov byte [c_runtime_status], 1

.c_runtime_done:
    call write_smoke_status
%ifdef SHUTDOWN_PANIC_PROOF_PANIC
    ud2
%endif
%ifdef SHUTDOWN_PANIC_PROOF_HALT
    mov dword [shutdown_state], SHUTDOWN_HALT
    call write_smoke_status
.proof_halt_loop:
    cli
    hlt
    jmp .proof_halt_loop
%endif
%ifdef SHUTDOWN_PANIC_PROOF_REBOOT
    mov dword [shutdown_state], SHUTDOWN_REBOOT
    call write_smoke_status
    call shutdown_proof_wait_before_guest_exit
    call keyboard_controller_reboot
%endif
%ifdef SHUTDOWN_PANIC_PROOF_POWEROFF
    mov dword [shutdown_state], SHUTDOWN_POWEROFF
    call write_smoke_status
    call shutdown_proof_wait_before_guest_exit
    call acpi_poweroff
%endif
    call user_probe_run

user_probe_finished:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, KERNEL_STACK_TOP
    call process_return_to_kernel
    call process_boot_launch_doom

doom_user_finished:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, KERNEL_STACK_TOP
    call process_return_to_kernel
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
    mov edi, cmd_poweroff
    call match_exact
    cmp al, 1
    je .poweroff

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

    mov esi, process_exec_prefix
    call print_string
    cmp byte [process_exec_status], 1
    je .process_exec_ok
    mov esi, fail_text
    call print_string
    jmp .wad_load_address

.process_exec_ok:
    mov esi, ok_text
    call print_string

    mov esi, process_exec_path_prefix
    call print_string
    cmp dword [process_exec_path_ptr], 0
    je .process_exec_path_empty
    mov esi, [process_exec_path_ptr]
    call print_string
    call newline
    jmp .process_exec_syscall_status

.process_exec_path_empty:
    mov esi, null_text
    call print_string
    call newline

.process_exec_syscall_status:
    mov esi, process_exec_syscall_prefix
    call print_string
    mov eax, [sys_exec_attempts]
    call print_dec
    mov al, '/'
    call put_char
    mov eax, [sys_exec_successes]
    call print_dec
    mov al, '/'
    call put_char
    mov eax, [sys_exec_failures]
    call print_dec
    mov al, '/'
    call put_char
    mov eax, [sys_exec_handoffs]
    call print_dec
    mov al, '/'
    call put_char
    mov eax, [sys_exec_scheduled]
    call print_dec
    mov al, '/'
    call put_char
    mov eax, [sys_exec_rollbacks]
    call print_dec
    call newline

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
    mov dword [shutdown_state], SHUTDOWN_REBOOT
    call write_smoke_status
    call keyboard_controller_reboot
    ret

.halt:
    mov esi, halt_message
    call print_string
    mov dword [shutdown_state], SHUTDOWN_HALT
    call write_smoke_status

.halt_loop:
    cli
    hlt
    jmp .halt_loop

.poweroff:
    mov esi, poweroff_message
    call print_string
    mov dword [shutdown_state], SHUTDOWN_POWEROFF
    call write_smoke_status
    call acpi_poweroff
    ret

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
    mov dx, RESET_CONTROL_PORT
    mov al, RESET_CONTROL_SYSTEM
    out dx, al
    call io_wait
    mov al, RESET_CONTROL_FULL_RESET
    out dx, al
    call io_wait

    in al, 0x64
    test al, 0x02
    jnz keyboard_controller_reboot
    mov al, 0xfe
    out 0x64, al

.wait:
    cli
    hlt
    jmp .wait

acpi_poweroff:
    mov dx, ACPI_PM1A_CNT_PORT
    mov ax, ACPI_PM1_CNT_S5_ENABLE
    out dx, ax
    mov dx, BOCHS_PM1A_CNT_PORT
    out dx, ax
    mov dx, VIRTUALBOX_PM1A_CNT_PORT
    mov ax, VIRTUALBOX_PM1_CNT_S5_ENABLE
    out dx, ax

.wait:
    cli
    hlt
    jmp .wait

read_cmos_seconds:
    mov al, CMOS_RTC_SECONDS_REGISTER
    out CMOS_INDEX_PORT, al
    call io_wait
    in al, CMOS_DATA_PORT
    ret

shutdown_proof_wait_before_guest_exit:
    cli
    call read_cmos_seconds
    mov bl, al
    mov ecx, SHUTDOWN_PROOF_DELAY_SECONDS

.wait_next_second:
    call read_cmos_seconds
    cmp al, bl
    je .wait_next_second
    mov bl, al
    loop .wait_next_second
    ret

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

pic_unmask_timer_keyboard:
    cmp byte [mouse_status], 1
    je .with_mouse
    cmp byte [audio_status], 1
    je .with_audio
    mov al, 0xfc
    out 0x21, al
    call io_wait
    mov al, 0xff
    out 0xa1, al
    call io_wait
    ret

.with_audio:
    mov al, 0xdc
    out 0x21, al
    call io_wait
    mov al, 0xff
    out 0xa1, al
    call io_wait
    ret

.with_mouse:
    cmp byte [audio_status], 1
    je .with_mouse_audio
    mov al, 0xf8
    out 0x21, al
    call io_wait
    mov al, 0xef
    out 0xa1, al
    call io_wait
    ret

.with_mouse_audio:
    mov al, 0xd8
    out 0x21, al
    call io_wait
    mov al, 0xef
    out 0xa1, al
    call io_wait
    ret

io_wait:
    push eax
    xor al, al
    out 0x80, al
    pop eax
    ret

pci_scan_qemu:
    pushad

    mov byte [pci_config_status], 0
    mov dword [pci_probe_count], 0
    mov dword [pci_function_count], 0
    mov dword [pci_first_bdf], 0
    mov dword [pci_first_id], 0
    mov dword [pci_first_class], 0
    mov dword [pci_last_bdf], 0
    mov dword [pci_class_table_hash], 0
    mov dword [pci_multifunction_device_count], 0
    mov dword [pci_mass_storage_class_count], 0
    mov dword [pci_bridge_class_count], 0

    mov edi, pci_device_table
    xor eax, eax
    mov ecx, PCI_TABLE_MAX_ENTRIES * PCI_TABLE_ENTRY_DWORDS
    rep stosd

    xor esi, esi

.device_loop:
    cmp esi, PCI_SCAN_DEVICE_COUNT
    jae .done
    xor edi, edi

.function_loop:
    cmp edi, PCI_SCAN_FUNCTION_COUNT
    jae .next_device

    inc dword [pci_probe_count]
    mov eax, PCI_CONFIG_ENABLE
    mov ebx, esi
    shl ebx, 11
    or eax, ebx
    mov ebx, edi
    shl ebx, 8
    or eax, ebx
    mov dx, PCI_CONFIG_ADDRESS
    out dx, eax
    mov dx, PCI_CONFIG_DATA
    in eax, dx
    cmp eax, 0xffffffff
    je .next_function
    cmp ax, 0xffff
    je .next_function

    mov ebp, eax

    mov eax, PCI_CONFIG_ENABLE
    mov ebx, esi
    shl ebx, 11
    or eax, ebx
    mov ebx, edi
    shl ebx, 8
    or eax, ebx
    or eax, PCI_CONFIG_CLASS_REG
    mov dx, PCI_CONFIG_ADDRESS
    out dx, eax
    mov dx, PCI_CONFIG_DATA
    in eax, dx
    mov ecx, eax

    mov eax, PCI_CONFIG_ENABLE
    mov ebx, esi
    shl ebx, 11
    or eax, ebx
    mov ebx, edi
    shl ebx, 8
    or eax, ebx
    or eax, PCI_CONFIG_HEADER_REG
    mov dx, PCI_CONFIG_ADDRESS
    out dx, eax
    mov dx, PCI_CONFIG_DATA
    in eax, dx
    mov ebx, eax

    mov edx, esi
    shl edx, 8
    or edx, edi

    mov eax, [pci_function_count]
    cmp eax, PCI_TABLE_MAX_ENTRIES
    jae .skip_table_store
    shl eax, 4
    mov [pci_device_table + eax + PCI_TABLE_BDF_OFFSET], edx
    mov [pci_device_table + eax + PCI_TABLE_ID_OFFSET], ebp
    mov [pci_device_table + eax + PCI_TABLE_CLASS_OFFSET], ecx
    mov [pci_device_table + eax + PCI_TABLE_HEADER_OFFSET], ebx

.skip_table_store:
    cmp byte [pci_config_status], 1
    je .not_first_device
    mov byte [pci_config_status], 1
    mov [pci_first_id], ebp
    mov [pci_first_bdf], edx
    mov [pci_first_class], ecx

.not_first_device:
    mov [pci_last_bdf], edx

    mov eax, [pci_class_table_hash]
    rol eax, 5
    xor eax, edx
    xor eax, ebp
    xor eax, ecx
    xor eax, ebx
    mov [pci_class_table_hash], eax

    cmp edi, 0
    jne .skip_multifunction_count
    test ebx, PCI_HEADER_MULTIFUNCTION_FLAG
    jz .skip_multifunction_count
    inc dword [pci_multifunction_device_count]

.skip_multifunction_count:
    mov eax, ecx
    shr eax, 24
    cmp al, PCI_CLASS_MASS_STORAGE
    jne .not_mass_storage_class
    inc dword [pci_mass_storage_class_count]

.not_mass_storage_class:
    cmp al, PCI_CLASS_BRIDGE
    jne .not_bridge_class
    inc dword [pci_bridge_class_count]

.not_bridge_class:
    inc dword [pci_function_count]

.next_function:
    inc edi
    jmp .function_loop

.next_device:
    inc esi
    jmp .device_loop

.done:
    xor eax, eax
    mov dx, PCI_CONFIG_ADDRESS
    out dx, eax
    popad
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

    mov dword [vmm_static_page_tables], PAGING_TABLE_COUNT
    mov dword [vmm_dynamic_page_tables], 0
    mov dword [vmm_active_page_tables], PAGING_TABLE_COUNT
    mov dword [vmm_reclaimed_page_tables], 0
    mov dword [vmm_last_reclaimed_page_table], 0
    mov dword [vmm_user_guard_pages], 0
    mov byte [vmm_high_mapping_status], 0
    mov dword [vmm_high_test_phys], 0
    mov dword [vmm_high_test_table], 0
    mov dword [vmm_high_test_reclaimed], 0

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
    or ebx, PTE_KERNEL_FLAGS
    mov [edi], ebx
    add edi, 4
    inc eax
    loop .pte_next

    mov edi, PAGING_DIR_ADDR
    mov eax, PAGING_TABLES_ADDR | PTE_KERNEL_FLAGS
    mov ecx, PAGING_TABLE_COUNT

.pde_next:
    mov [edi], eax
    add eax, PAGE_SIZE
    add edi, 4
    loop .pde_next

    call framebuffer_map_lfb
    call process_vm_init_page_spaces

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

framebuffer_map_lfb:
    pushad

    mov byte [framebuffer_map_status], 0
    cmp dword [BOOT_INFO_ADDR + 8], VIDEO_BOOT_MAGIC
    jne .done
    mov ax, [BOOT_VIDEO_FLAGS]
    and ax, BOOT_VIDEO_FLAG_LFB | BOOT_VIDEO_FLAG_XRGB8888
    cmp ax, BOOT_VIDEO_FLAG_LFB | BOOT_VIDEO_FLAG_XRGB8888
    jne .fail
    cmp byte [BOOT_VIDEO_BPP], 32
    jne .fail
    cmp dword [BOOT_VIDEO_FB_ADDR], 0
    je .fail

    mov eax, [BOOT_VIDEO_FB_ADDR]
    shr eax, 22
    mov [framebuffer_pde_index], eax
    cmp eax, PAGING_TABLE_COUNT
    jb .already_identity_mapped

    mov eax, [BOOT_VIDEO_FB_ADDR]
    and eax, 0x00000fff
    mov ebx, eax
    mov eax, [BOOT_VIDEO_PITCH]
    movzx ecx, word [BOOT_VIDEO_HEIGHT]
    mul ecx
    test edx, edx
    jnz .fail
    add eax, ebx
    jc .fail
    add eax, PAGE_SIZE - 1
    jc .fail
    shr eax, 12
    cmp eax, 1024
    ja .fail
    mov [framebuffer_page_count], eax

    mov edx, [BOOT_VIDEO_FB_ADDR]
    shr edx, 12
    and edx, 0x000003ff
    mov [framebuffer_pte_index], edx
    mov ecx, [framebuffer_page_count]
    add ecx, edx
    cmp ecx, 1024
    ja .fail

    mov edi, FB_PAGE_TABLE_ADDR
    xor eax, eax
    mov ecx, 1024
    cld
    rep stosd

    mov eax, [framebuffer_pde_index]
    mov edi, PAGING_DIR_ADDR
    lea edi, [edi + eax * 4]
    mov dword [edi], FB_PAGE_TABLE_ADDR | PTE_KERNEL_FLAGS
    inc dword [vmm_static_page_tables]
    inc dword [vmm_active_page_tables]

    mov edi, FB_PAGE_TABLE_ADDR
    mov eax, [framebuffer_pte_index]
    lea edi, [edi + eax * 4]
    mov ebx, [BOOT_VIDEO_FB_ADDR]
    and ebx, 0xfffff000
    or ebx, PTE_KERNEL_FLAGS
    mov ecx, [framebuffer_page_count]

.pte_next:
    cmp ecx, 0
    je .mapped
    mov [edi], ebx
    add ebx, PAGE_SIZE
    add edi, 4
    dec ecx
    jmp .pte_next

.already_identity_mapped:
    mov dword [framebuffer_page_count], 0
    mov dword [framebuffer_pte_index], 0

.mapped:
    mov byte [framebuffer_map_status], 1
    jmp .done

.fail:
    mov byte [framebuffer_map_status], 2

.done:
    popad
    ret

framebuffer_init:
    mov byte [video_backend], VIDEO_BACKEND_MODE13
    mov byte [framebuffer_status], 1
    mov dword [framebuffer_addr], VGA_GRAPHICS_BUFFER
    mov dword [framebuffer_pitch], DOOM_SCREEN_WIDTH
    mov dword [framebuffer_width], DOOM_SCREEN_WIDTH
    mov dword [framebuffer_height], DOOM_SCREEN_HEIGHT

    cmp dword [BOOT_INFO_ADDR + 8], VIDEO_BOOT_MAGIC
    jne .done
    cmp byte [framebuffer_map_status], 1
    jne .done
    mov ax, [BOOT_VIDEO_FLAGS]
    and ax, BOOT_VIDEO_FLAG_LFB | BOOT_VIDEO_FLAG_XRGB8888
    cmp ax, BOOT_VIDEO_FLAG_LFB | BOOT_VIDEO_FLAG_XRGB8888
    jne .done
    cmp byte [BOOT_VIDEO_BPP], 32
    jne .done
    cmp byte [BOOT_VIDEO_MEMORY_MODEL], 6
    jne .done
    cmp byte [BOOT_VIDEO_RED_MASK], 8
    jb .done
    cmp byte [BOOT_VIDEO_RED_POS], 16
    jne .done
    cmp byte [BOOT_VIDEO_GREEN_MASK], 8
    jb .done
    cmp byte [BOOT_VIDEO_GREEN_POS], 8
    jne .done
    cmp byte [BOOT_VIDEO_BLUE_MASK], 8
    jb .done
    cmp byte [BOOT_VIDEO_BLUE_POS], 0
    jne .done
    movzx eax, word [BOOT_VIDEO_WIDTH]
    cmp eax, 640
    jb .done
    movzx ebx, word [BOOT_VIDEO_HEIGHT]
    cmp ebx, 400
    jb .done
    mov ecx, [BOOT_VIDEO_PITCH]
    cmp ecx, 640 * 4
    jb .done

    mov byte [video_backend], VIDEO_BACKEND_LFB_XRGB8888
    mov eax, [BOOT_VIDEO_FB_ADDR]
    mov [framebuffer_addr], eax
    mov eax, [BOOT_VIDEO_PITCH]
    mov [framebuffer_pitch], eax
    movzx eax, word [BOOT_VIDEO_WIDTH]
    mov [framebuffer_width], eax
    movzx eax, word [BOOT_VIDEO_HEIGHT]
    mov [framebuffer_height], eax

.done:
    ret

process_vm_init_page_spaces:
    pushad

    mov esi, PAGING_DIR_ADDR
    mov edi, PROC_PROBE_PAGE_DIR_ADDR
    mov ecx, 1024
    cld
    rep movsd

    mov esi, PAGING_DIR_ADDR
    mov edi, PROC_DOOM_PAGE_DIR_ADDR
    mov ecx, 1024
    cld
    rep movsd

    mov esi, PAGING_DIR_ADDR
    mov edi, PROC_PREEMPT_PAGE_DIR_ADDR
    mov ecx, 1024
    cld
    rep movsd

    mov esi, PAGING_DIR_ADDR
    mov edi, PROC_GENERIC0_PAGE_DIR_ADDR
    mov ecx, 1024
    cld
    rep movsd

    mov esi, PAGING_DIR_ADDR
    mov edi, PROC_GENERIC1_PAGE_DIR_ADDR
    mov ecx, 1024
    cld
    rep movsd

    mov esi, PAGING_TABLES_ADDR + (3 * PAGE_SIZE)
    mov edi, PROC_PROBE_PDE3_TABLE_ADDR
    mov ecx, 1024
    cld
    rep movsd
    mov dword [PROC_PROBE_PAGE_DIR_ADDR + (3 * 4)], PROC_PROBE_PDE3_TABLE_ADDR | PTE_USER_FLAGS

    mov ebx, PROC_PROBE_PAGE_DIR_ADDR
    mov eax, USER_CODE_ADDR
    mov edx, USER_STACK_TOP
    call vmm_mark_process_user_range
    mov eax, USER_CODE_ADDR - PAGE_SIZE
    call vmm_clear_process_guard_page
    mov eax, USER_HEAP_END
    call vmm_clear_process_guard_page

    mov esi, PAGING_TABLES_ADDR + (3 * PAGE_SIZE)
    mov edi, PROC_PREEMPT_PDE3_TABLE_ADDR
    mov ecx, 1024
    cld
    rep movsd
    mov dword [PROC_PREEMPT_PAGE_DIR_ADDR + (3 * 4)], PROC_PREEMPT_PDE3_TABLE_ADDR | PTE_USER_FLAGS

    mov ebx, PROC_PREEMPT_PAGE_DIR_ADDR
    mov eax, USER_CODE_ADDR
    mov edx, USER_STACK_TOP
    call vmm_mark_process_user_range
    mov eax, USER_CODE_ADDR - PAGE_SIZE
    call vmm_clear_process_guard_page
    mov eax, USER_HEAP_END
    call vmm_clear_process_guard_page

    mov esi, PAGING_TABLES_ADDR + (3 * PAGE_SIZE)
    mov edi, PROC_GENERIC0_PDE3_TABLE_ADDR
    mov ecx, 1024
    cld
    rep movsd
    mov dword [PROC_GENERIC0_PAGE_DIR_ADDR + (3 * 4)], PROC_GENERIC0_PDE3_TABLE_ADDR | PTE_USER_FLAGS

    mov ebx, PROC_GENERIC0_PAGE_DIR_ADDR
    mov eax, USER_CODE_ADDR
    mov edx, USER_STACK_TOP
    call vmm_mark_process_user_range
    mov eax, USER_CODE_ADDR - PAGE_SIZE
    call vmm_clear_process_guard_page
    mov eax, USER_HEAP_END
    call vmm_clear_process_guard_page

    mov esi, PAGING_TABLES_ADDR + (3 * PAGE_SIZE)
    mov edi, PROC_GENERIC1_PDE3_TABLE_ADDR
    mov ecx, 1024
    cld
    rep movsd
    mov dword [PROC_GENERIC1_PAGE_DIR_ADDR + (3 * 4)], PROC_GENERIC1_PDE3_TABLE_ADDR | PTE_USER_FLAGS

    mov ebx, PROC_GENERIC1_PAGE_DIR_ADDR
    mov eax, USER_CODE_ADDR
    mov edx, USER_STACK_TOP
    call vmm_mark_process_user_range
    mov eax, USER_CODE_ADDR - PAGE_SIZE
    call vmm_clear_process_guard_page
    mov eax, USER_HEAP_END
    call vmm_clear_process_guard_page

    mov esi, PAGING_TABLES_ADDR + (4 * PAGE_SIZE)
    mov edi, PROC_DOOM_PDE4_TABLE_ADDR
    mov ecx, 1024
    cld
    rep movsd
    mov dword [PROC_DOOM_PAGE_DIR_ADDR + (4 * 4)], PROC_DOOM_PDE4_TABLE_ADDR | PTE_USER_FLAGS

    mov esi, PAGING_TABLES_ADDR + (5 * PAGE_SIZE)
    mov edi, PROC_DOOM_PDE5_TABLE_ADDR
    mov ecx, 1024
    cld
    rep movsd
    mov dword [PROC_DOOM_PAGE_DIR_ADDR + (5 * 4)], PROC_DOOM_PDE5_TABLE_ADDR | PTE_USER_FLAGS

    mov esi, PAGING_TABLES_ADDR + (6 * PAGE_SIZE)
    mov edi, PROC_DOOM_PDE6_TABLE_ADDR
    mov ecx, 1024
    cld
    rep movsd
    mov dword [PROC_DOOM_PAGE_DIR_ADDR + (6 * 4)], PROC_DOOM_PDE6_TABLE_ADDR | PTE_USER_FLAGS

    mov esi, PAGING_TABLES_ADDR + (7 * PAGE_SIZE)
    mov edi, PROC_DOOM_PDE7_TABLE_ADDR
    mov ecx, 1024
    cld
    rep movsd
    mov dword [PROC_DOOM_PAGE_DIR_ADDR + (7 * 4)], PROC_DOOM_PDE7_TABLE_ADDR | PTE_USER_FLAGS

    mov ebx, PROC_DOOM_PAGE_DIR_ADDR
    mov eax, DOOM_USER_BASE
    mov edx, DOOM_USER_HEAP_START
    call vmm_mark_process_user_range
    mov eax, DOOM_USER_STACK_BOTTOM
    mov edx, DOOM_USER_STACK_TOP
    call vmm_mark_process_user_range

    popad
    ret

vmm_mark_process_user_range:
    mov ecx, PTE_USER_WRITE_FLAGS
    jmp vmm_mark_process_user_range_with_flags

vmm_mark_process_user_read_range:
    mov ecx, PTE_USER_READ_FLAGS
    jmp vmm_mark_process_user_range_with_flags

vmm_mark_process_user_write_range:
    mov ecx, PTE_USER_WRITE_FLAGS

vmm_mark_process_user_range_with_flags:
    push eax
    push ecx
    push edx

    and eax, 0xfffff000
    add edx, PAGE_SIZE - 1
    and edx, 0xfffff000

.next:
    cmp eax, edx
    jae .done
    call vmm_mark_process_user_page
    add eax, PAGE_SIZE
    jmp .next

.done:
    pop edx
    pop ecx
    pop eax
    ret

vmm_mark_process_user_page:
    push eax
    push ebx
    push ecx
    push edx
    push edi

    mov edx, eax
    shr edx, 22
    lea edi, [ebx + edx * 4]
    mov edx, [edi]
    and edx, 0xfffff000
    or edx, PTE_USER_WRITE_FLAGS
    mov [edi], edx
    and edx, 0xfffff000

    shr eax, 12
    and eax, 0x3ff
    lea edi, [edx + eax * 4]
    mov ebx, [edi]
    and ebx, 0xfffff000
    or ebx, ecx
    mov [edi], ebx

    pop edi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

vmm_clear_process_page:
    push eax
    push ebx
    push edx
    push edi

    mov edx, eax
    shr edx, 22
    lea edi, [ebx + edx * 4]
    mov edx, [edi]
    test edx, PTE_PRESENT
    jz .done
    and edx, 0xfffff000
    shr eax, 12
    and eax, 0x3ff
    lea edi, [edx + eax * 4]
    and dword [edi], 0xfffffffe

.done:
    pop edi
    pop edx
    pop ebx
    pop eax
    ret

vmm_clear_process_guard_page:
    call vmm_clear_process_page
    inc dword [vmm_user_guard_pages]
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

    mov eax, DOOM_USER_BASE
    mov ecx, (DOOM_USER_END - DOOM_USER_BASE) / PAGE_SIZE
    call pmm_reserve_pages

    mov eax, FAT_TABLE_CACHE_ADDR
    mov ecx, (FAT_CACHE_BYTES + PAGE_SIZE - 1) / PAGE_SIZE
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
    push esi
    push edi

    and eax, 0xfffff000
    mov [vmm_map_vaddr], eax
    and ebx, 0xfffff000
    or ebx, ecx
    or ebx, 0x001
    mov [vmm_map_entry], ebx

    mov edx, eax
    shr edx, 22
    mov edi, PAGING_DIR_ADDR
    lea edi, [edi + edx * 4]
    mov edx, [edi]
    test edx, PTE_PRESENT
    jnz .have_table

    call pmm_alloc_page
    test eax, eax
    jz .fail
    mov [vmm_map_table_addr], eax
    mov [vmm_map_pde_ptr], edi
    mov edi, eax
    xor eax, eax
    mov ecx, 1024
    cld
    rep stosd
    mov edi, [vmm_map_pde_ptr]
    mov eax, [vmm_map_table_addr]
    or eax, PTE_KERNEL_FLAGS
    mov [edi], eax
    inc dword [vmm_dynamic_page_tables]
    inc dword [vmm_active_page_tables]

.have_table:
    mov edx, [edi]
    and edx, 0xfffff000
    mov eax, [vmm_map_vaddr]
    shr eax, 12
    and eax, 0x000003ff
    lea edi, [edx + eax * 4]
    mov ebx, [vmm_map_entry]
    mov [edi], ebx
    mov eax, [vmm_map_vaddr]
    invlpg [eax]
    mov byte [vmm_status], 1
    clc
    jmp .done

.fail:
    stc

.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

vmm_unmap_page:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    and eax, 0xfffff000
    mov [vmm_map_vaddr], eax
    mov edx, eax
    shr edx, 22
    mov edi, PAGING_DIR_ADDR
    lea edi, [edi + edx * 4]
    mov [vmm_map_pde_ptr], edi
    mov edx, [edi]
    test edx, PTE_PRESENT
    jz .done
    and edx, 0xfffff000
    mov [vmm_map_table_addr], edx
    mov eax, [vmm_map_vaddr]
    shr eax, 12
    and eax, 0x000003ff
    lea edi, [edx + eax * 4]
    mov dword [edi], 0
    mov eax, [vmm_map_vaddr]
    invlpg [eax]

    mov esi, [vmm_map_table_addr]
    mov ecx, 1024

.scan_table:
    cmp dword [esi], 0
    jne .done
    add esi, 4
    loop .scan_table

    mov eax, [vmm_map_table_addr]
    cmp eax, PMM_MANAGED_START
    jb .done
    cmp eax, PMM_MANAGED_END
    jae .done
    mov edi, [vmm_map_pde_ptr]
    mov dword [edi], 0
    mov [vmm_last_reclaimed_page_table], eax
    call pmm_free_page
    dec dword [vmm_active_page_tables]
    inc dword [vmm_reclaimed_page_tables]

.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

vmm_identity_page:
    push ebx
    push ecx

    mov ebx, eax
    mov ecx, PTE_KERNEL_FLAGS
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
    mov ecx, PTE_KERNEL_FLAGS
    call vmm_map_page
    jc .free_fail

    mov dword [VMM_TEST_VADDR], VMM_TEST_MAGIC
    cmp dword [ebx], VMM_TEST_MAGIC
    jne .restore_fail

    mov eax, VMM_TEST_VADDR
    call vmm_identity_page
    mov eax, ebx
    call pmm_free_page
    call pmm_alloc_page
    test eax, eax
    jz .fail
    mov ebx, eax

    mov eax, VMM_HIGH_TEST_VADDR
    cmp eax, ebx
    je .high_free_fail
    mov ecx, PTE_KERNEL_FLAGS
    call vmm_map_page
    jc .high_free_fail
    mov [vmm_high_test_phys], ebx
    mov eax, [vmm_map_table_addr]
    mov [vmm_high_test_table], eax

    mov dword [VMM_HIGH_TEST_VADDR], VMM_HIGH_TEST_MAGIC
    cmp dword [ebx], VMM_HIGH_TEST_MAGIC
    jne .high_unmap_fail

    mov eax, VMM_HIGH_TEST_VADDR
    call vmm_unmap_page
    mov eax, [vmm_last_reclaimed_page_table]
    mov [vmm_high_test_reclaimed], eax
    cmp eax, [vmm_high_test_table]
    jne .high_free_fail
    mov eax, ebx
    call pmm_free_page
    mov byte [vmm_high_mapping_status], 1
    mov byte [vmm_test_status], 1
    ret

.high_unmap_fail:
    mov eax, VMM_HIGH_TEST_VADDR
    call vmm_unmap_page

.high_free_fail:
    mov eax, ebx
    call pmm_free_page
    mov byte [vmm_high_mapping_status], 2
    jmp .fail

.restore_fail:
    mov eax, VMM_TEST_VADDR
    call vmm_identity_page

.free_fail:
    mov eax, ebx
    call pmm_free_page

.fail:
    cmp byte [vmm_high_mapping_status], 1
    je .status_only
    mov byte [vmm_high_mapping_status], 2

.status_only:
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

audio_init:
    mov byte [audio_status], 0
    mov byte [sb16_major_version], 0
    mov byte [sb16_minor_version], 0
    mov dword [doom_sound_call_count], 0
    mov dword [doom_sound_start_count], 0
    mov dword [doom_sound_stop_count], 0
    mov dword [doom_sound_update_count], 0
    mov dword [doom_sound_last_command], 0
    mov dword [doom_sound_last_handle], 0
    mov dword [doom_sound_last_packed], 0
    mov dword [sb16_sfx_voice_start_count], 0
    mov dword [sb16_sfx_voice_stop_count], 0
    mov dword [sb16_sfx_voice_update_count], 0
    mov dword [sb16_sfx_voice_finished_count], 0
    mov dword [sb16_sfx_wad_start_count], 0
    mov dword [sb16_sfx_submit_bytes], 0
    mov dword [sb16_sfx_output_bytes], 0
    mov dword [sb16_sfx_last_id], 0
    mov dword [sb16_sfx_last_rate], 0
    mov dword [sb16_sfx_last_length], 0
    mov dword [sb16_sfx_mix_count], 0
    mov dword [sb16_sfx_mix_bytes], 0
    mov dword [sb16_sfx_dma_mix_count], 0
    mov dword [sb16_sfx_dma_mix_bytes], 0
    mov dword [sb16_dma_write_pos], 0
    mov dword [sb16_mix_clip_count], 0
    mov dword [sb16_mix_underrun_count], 0
    mov dword [sb16_mix_wrap_count], 0
    mov dword [sb16_mix_overwrite_count], 0
    mov dword [sb16_irq_count], 0
    mov dword [sb16_irq_ack8_count], 0
    mov dword [sb16_irq_ack16_count], 0
    mov dword [sb16_irq_refill_count], 0
    mov dword [sb16_irq_half_index], 0
    mov dword [sb16_playback_start_count], 0
    mov dword [sb16_playback_stop_count], 0
    mov dword [sb16_dma_program_count], 0
    mov dword [sb16_active_voice_count], 0
    mov dword [sb16_active_sfx_voice_count], 0
    mov dword [sb16_active_music_voice_count], 0
    mov dword [sb16_voice_start_count], 0
    mov dword [sb16_voice_stop_count], 0
    mov dword [sb16_voice_update_count], 0
    mov dword [sb16_voice_refill_count], 0
    mov dword [sb16_voice_finished_count], 0
    mov dword [sb16_voice_steal_count], 0
    mov dword [sb16_voice_age_counter], 0
    mov dword [sb16_pitch_clamp_count], 0
    mov dword [sb16_pan_clamp_count], 0
    mov dword [sb16_music_start_count], 0
    mov dword [sb16_music_stop_count], 0
    mov dword [sb16_music_mix_count], 0
    mov dword [sb16_music_mix_bytes], 0
    mov dword [sb16_music_loop_count], 0
    mov dword [sb16_music_stream_pos_bytes], 0
    mov dword [sb16_music_stream_buffer_bytes], 0
    mov dword [sb16_music_stream_under_count], 0
    mov dword [sb16_music_stream_drop_count], 0
    mov dword [sb16_music_stream_mode], AUDIO_MUSIC_STREAM_NONE
    mov dword [sb16_music_pull_request_count], 0
    mov dword [sb16_music_pull_refill_count], 0
    mov dword [sb16_music_render_format], 0
    mov dword [sb16_music_render_chunk_count], 0
    mov dword [sb16_music_render_note_count], 0
    mov dword [sb16_music_render_event_count], 0
    mov dword [sb16_music_render_active_peak], 0
    mov dword [sb16_music_render_sample_count], 0
    mov dword [sb16_pan_left_arg], 0
    mov dword [sb16_pan_right_arg], 0
    mov dword [sb16_mix_source_pos], 0
    mov dword [sb16_mix_source_step], AUDIO_PITCH_STEP_NORMAL
    mov dword [sb16_mix_left_volume], 0
    mov dword [sb16_mix_right_volume], 0
    mov dword [sb16_mix_frames_mixed], 0
    mov dword [sb16_mix_voice_slot], 0
    mov dword [audio_sfx_rate_arg], 0
    mov dword [sb16_dma_buffer_phys], sb16_dma_buffer
    mov dword [sb16_dma_buffer_size], SB16_DMA_BUFFER_BYTES
    mov dword [sb16_dma_block_size], SB16_DMA_BLOCK_BYTES
    mov byte [sb16_playback_active], 0
    call sb16_clear_dma_buffer
    call sb16_clear_active_voices
    call sb16_probe
    ret

ps2_mouse_init:
    mov byte [mouse_status], 0
    mov byte [ps2_mouse_command_byte], 0
    call mouse_reset_queue

    mov al, PS2_COMMAND_ENABLE_AUX
    call ps2_write_command
    jc .absent

    mov al, PS2_COMMAND_READ_CONFIG
    call ps2_write_command
    jc .absent
    call ps2_read_data
    jc .absent
    or al, PS2_CONFIG_AUX_IRQ
    and al, ~PS2_CONFIG_AUX_CLOCK_DISABLE
    mov [ps2_mouse_command_byte], al

    mov al, PS2_COMMAND_WRITE_CONFIG
    call ps2_write_command
    jc .absent
    mov al, [ps2_mouse_command_byte]
    call ps2_write_data
    jc .absent

    mov al, PS2_MOUSE_SET_DEFAULTS
    call ps2_mouse_send_command
    jc .absent
    mov al, PS2_MOUSE_ENABLE_DATA
    call ps2_mouse_send_command
    jc .absent

    mov byte [mouse_status], 1
    clc
    ret

.absent:
    mov byte [mouse_status], 2
    stc
    ret

ps2_wait_input_clear:
    push ecx
    mov ecx, 0x00010000

.wait:
    in al, PS2_STATUS_PORT
    test al, PS2_STATUS_INPUT_FULL
    jz .ready
    loop .wait
    stc
    pop ecx
    ret

.ready:
    clc
    pop ecx
    ret

ps2_wait_output_full:
    push ecx
    mov ecx, 0x00010000

.wait:
    in al, PS2_STATUS_PORT
    test al, PS2_STATUS_OUTPUT_FULL
    jnz .ready
    loop .wait
    stc
    pop ecx
    ret

.ready:
    clc
    pop ecx
    ret

ps2_write_command:
    push edx
    push eax
    call ps2_wait_input_clear
    jc .done
    mov dx, PS2_COMMAND_PORT
    pop eax
    out dx, al
    clc
    pop edx
    ret

.done:
    pop eax
    pop edx
    ret

ps2_write_data:
    push edx
    push eax
    call ps2_wait_input_clear
    jc .done
    mov dx, PS2_DATA_PORT
    pop eax
    out dx, al
    clc
    pop edx
    ret

.done:
    pop eax
    pop edx
    ret

ps2_read_data:
    push edx
    call ps2_wait_output_full
    jc .done
    mov dx, PS2_DATA_PORT
    in al, dx
    clc

.done:
    pop edx
    ret

ps2_mouse_send_command:
    mov [ps2_mouse_command_byte], al
    mov al, PS2_COMMAND_WRITE_AUX
    call ps2_write_command
    jc .fail
    mov al, [ps2_mouse_command_byte]
    call ps2_write_data
    jc .fail
    call ps2_read_data
    jc .fail
    cmp al, PS2_MOUSE_ACK
    jne .fail
    clc
    ret

.fail:
    stc
    ret

sb16_probe:
    call sb16_reset_dsp
    jc .absent

    mov al, SB16_DSP_GET_VERSION
    call sb16_write_dsp
    jc .absent
    call sb16_read_dsp
    jc .absent
    mov [sb16_major_version], al
    call sb16_read_dsp
    jc .absent
    mov [sb16_minor_version], al
    mov byte [audio_status], 1
    call sb16_configure_mixer
    clc
    ret

.absent:
    mov byte [audio_status], 2
    stc
    ret

sb16_reset_dsp:
    mov dx, SB16_DSP_RESET
    mov al, 1
    out dx, al
    call sb16_io_delay
    xor al, al
    out dx, al
    call sb16_read_dsp
    jc .fail
    cmp al, SB16_DSP_RESET_ACK
    jne .fail
    clc
    ret

.fail:
    stc
    ret

sb16_io_delay:
    push ecx
    mov ecx, 0x1000

.delay_next:
    loop .delay_next
    pop ecx
    ret

sb16_configure_mixer:
    mov al, SB16_MIXER_IRQ_SELECT
    mov ah, SB16_MIXER_IRQ5_BIT
    call sb16_write_mixer
    mov al, SB16_MIXER_DMA_SELECT
    mov ah, SB16_MIXER_DMA_CH1_BIT | SB16_MIXER_DMA_CH5_BIT
    call sb16_write_mixer
    ret

sb16_write_mixer:
    push edx
    mov dx, SB16_MIXER_ADDR
    out dx, al
    call sb16_io_delay
    mov dx, SB16_MIXER_DATA
    mov al, ah
    out dx, al
    call sb16_io_delay
    pop edx
    ret

sb16_clear_dma_buffer:
    push eax
    push ecx
    push edi
    mov edi, sb16_dma_buffer
    mov eax, 0x80808080
    mov ecx, SB16_DMA_BUFFER_BYTES / 4
    cld
    rep stosd
    mov dword [sb16_dma_write_pos], 0
    mov dword [sb16_irq_half_index], 0
    pop edi
    pop ecx
    pop eax
    ret

sb16_clear_active_voices:
    push eax
    push ecx
    push edi

    mov edi, sb16_voice_active
    xor eax, eax
    mov ecx, AUDIO_MAX_SFX_VOICES
    cld
    rep stosb

    mov edi, sb16_voice_handles
    mov ecx, AUDIO_MAX_SFX_VOICES * 15
    cld
    rep stosd

    mov dword [sb16_active_voice_count], 0
    mov dword [sb16_active_sfx_voice_count], 0
    mov dword [sb16_active_music_voice_count], 0
    mov dword [sb16_voice_age_counter], 0

    pop edi
    pop ecx
    pop eax
    ret

sb16_recount_active_voices:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp

    xor eax, eax
    xor ebx, ebx
    xor edx, edx
    xor esi, esi
    xor ebp, ebp
    mov ecx, AUDIO_MAX_SFX_VOICES

.next:
    cmp byte [sb16_voice_active + ebx], 1
    jne .skip
    inc eax
    test dword [sb16_voice_flags + ebx * 4], AUDIO_FLAG_MUSIC
    jnz .count_music
    inc esi
    jmp .skip

.count_music:
    inc edx
    mov edi, [sb16_voice_positions + ebx * 4]
    shr edi, 16
    mov [sb16_music_stream_calc_pos], edi
    mov edi, [sb16_voice_lengths + ebx * 4]
    cmp edi, [sb16_music_stream_calc_pos]
    jbe .count_pending
    sub edi, [sb16_music_stream_calc_pos]
    add ebp, edi

.count_pending:
    mov edi, [sb16_voice_pending_lengths + ebx * 4]
    add ebp, edi
    jmp .skip

.skip:
    inc ebx
    loop .next
    mov [sb16_active_voice_count], eax
    mov [sb16_active_sfx_voice_count], esi
    mov [sb16_active_music_voice_count], edx
    mov [sb16_music_stream_buffer_bytes], ebp

    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

sb16_find_voice_by_handle:
    push ebx
    push ecx

    mov eax, [audio_sfx_handle_arg]
    xor ebx, ebx
    mov ecx, AUDIO_MAX_SFX_VOICES

.next:
    cmp byte [sb16_voice_active + ebx], 1
    jne .skip
    cmp [sb16_voice_handles + ebx * 4], eax
    je .found

.skip:
    inc ebx
    loop .next
    stc
    jmp .done

.found:
    mov eax, ebx
    clc

.done:
    pop ecx
    pop ebx
    ret

sb16_find_free_voice:
    push ebx
    push ecx

    xor ebx, ebx
    mov ecx, AUDIO_MAX_SFX_VOICES

.next:
    cmp byte [sb16_voice_active + ebx], 0
    je .found
    inc ebx
    loop .next
    stc
    jmp .done

.found:
    mov eax, ebx
    clc

.done:
    pop ecx
    pop ebx
    ret

sb16_find_steal_voice:
    push ebx
    push ecx
    push edx
    push esi

    xor esi, esi
    xor eax, eax
    xor ebx, ebx
    mov edx, 0xffffffff
    mov ecx, AUDIO_MAX_SFX_VOICES

.next:
    cmp byte [sb16_voice_active + ebx], 1
    jne .skip
    test dword [sb16_voice_flags + ebx * 4], AUDIO_FLAG_MUSIC
    jnz .skip
    cmp [sb16_voice_started_at + ebx * 4], edx
    jae .skip
    mov edx, [sb16_voice_started_at + ebx * 4]
    mov eax, ebx
    mov esi, 1

.skip:
    inc ebx
    loop .next
    cmp esi, 1
    je .found

    xor eax, eax
    xor ebx, ebx
    mov edx, [sb16_voice_started_at]
    mov ecx, AUDIO_MAX_SFX_VOICES

.fallback_next:
    cmp [sb16_voice_started_at + ebx * 4], edx
    jae .fallback_skip
    mov edx, [sb16_voice_started_at + ebx * 4]
    mov eax, ebx

.fallback_skip:
    inc ebx
    loop .fallback_next

.found:
    inc dword [sb16_voice_steal_count]
    clc

    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

sb16_pitch_to_step:
    push ebx

    and eax, 0xff
    cmp eax, AUDIO_PITCH_NORMAL
    jae .high_pitch

    mov ebx, AUDIO_PITCH_NORMAL
    sub ebx, eax
    cmp ebx, 64
    ja .low_outer_octave
    mov eax, ebx
    shl eax, 9
    mov ebx, AUDIO_PITCH_STEP_NORMAL
    sub ebx, eax
    mov eax, ebx
    jmp .done

.low_outer_octave:
    sub ebx, 64
    mov eax, ebx
    shl eax, 8
    mov ebx, 0x00008000
    sub ebx, eax
    cmp ebx, AUDIO_PITCH_STEP_MIN
    jae .low_ready
    mov ebx, AUDIO_PITCH_STEP_MIN
    inc dword [sb16_pitch_clamp_count]

.low_ready:
    mov eax, ebx
    jmp .done

.high_pitch:
    sub eax, AUDIO_PITCH_NORMAL
    cmp eax, 64
    ja .high_outer_octave
    shl eax, 10
    add eax, AUDIO_PITCH_STEP_NORMAL
    jmp .done

.high_outer_octave:
    sub eax, 64
    shl eax, 11
    add eax, 0x00020000

.done:
    pop ebx
    ret

sb16_compute_pan_from_args:
    push eax
    push ebx
    push ecx
    push edx

    mov ecx, [audio_sfx_volume_arg]
    and ecx, 0xff
    cmp ecx, 127
    jbe .volume_ready
    mov ecx, 127
    inc dword [sb16_pan_clamp_count]

.volume_ready:
    mov eax, [audio_sfx_separation_arg]
    and eax, 0xff
    inc eax
    mov ebx, eax
    imul ebx, ebx
    mov eax, ecx
    imul eax, ebx
    shr eax, 16
    mov edx, ecx
    sub edx, eax
    cmp edx, 127
    jle .left_low_check
    mov edx, 127
    inc dword [sb16_pan_clamp_count]
    jmp .left_ready

.left_low_check:
    cmp edx, 0
    jge .left_ready
    xor edx, edx
    inc dword [sb16_pan_clamp_count]

.left_ready:
    mov [sb16_pan_left_arg], edx

    mov eax, [audio_sfx_separation_arg]
    and eax, 0xff
    inc eax
    sub eax, 257
    imul eax, eax
    mov ebx, eax
    mov eax, ecx
    imul eax, ebx
    shr eax, 16
    mov edx, ecx
    sub edx, eax
    cmp edx, 127
    jle .right_low_check
    mov edx, 127
    inc dword [sb16_pan_clamp_count]
    jmp .right_ready

.right_low_check:
    cmp edx, 0
    jge .right_ready
    xor edx, edx
    inc dword [sb16_pan_clamp_count]

.right_ready:
    mov [sb16_pan_right_arg], edx

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

audio_mix_sfx_descriptor:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp

    mov eax, [audio_sfx_desc_arg]
    mov ebx, AUDIO_SFX_DESC_BYTES
    call user_range_validate
    jc .underrun

    mov esi, [audio_sfx_desc_arg]
    mov eax, [esi + AUDIO_SFX_DESC_SAMPLES]
    mov ebx, [esi + AUDIO_SFX_DESC_LENGTH]
    mov [audio_sfx_sample_arg], eax
    mov [audio_sfx_length_arg], ebx
    mov eax, [esi + AUDIO_SFX_DESC_VOLUME]
    and eax, 0xff
    mov [audio_sfx_volume_arg], eax
    mov eax, [esi + AUDIO_SFX_DESC_SEPARATION]
    and eax, 0xff
    mov [audio_sfx_separation_arg], eax
    mov eax, [esi + AUDIO_SFX_DESC_PITCH]
    and eax, 0xff
    mov [audio_sfx_pitch_arg], eax
    mov eax, [esi + AUDIO_SFX_DESC_SOUND_ID]
    mov [audio_sfx_id_arg], eax
    mov eax, [esi + AUDIO_SFX_DESC_FLAGS]
    mov [audio_sfx_flags_arg], eax
    mov eax, [esi + AUDIO_SFX_DESC_SAMPLE_RATE]
    mov [audio_sfx_rate_arg], eax

    mov eax, [audio_sfx_sample_arg]
    mov ebx, [audio_sfx_length_arg]
    cmp ebx, 0
    je .underrun
    cmp ebx, SB16_DMA_BUFFER_BYTES
    jbe .length_ready
    mov ebx, SB16_DMA_BUFFER_BYTES
    mov [audio_sfx_length_arg], ebx

.length_ready:
    call user_range_validate
    jc .underrun

    mov esi, [audio_sfx_sample_arg]
    mov ecx, [audio_sfx_length_arg]
    mov ebp, [audio_sfx_volume_arg]
    mov edi, sb16_dma_buffer
    add edi, [sb16_dma_write_pos]
    cld

.mix_next:
    cmp ecx, 0
    je .done_mix

    xor eax, eax
    lodsb
    sub eax, 128
    imul eax, ebp
    sar eax, 7

    movzx edx, byte [edi]
    sub edx, 128
    add eax, edx
    cmp eax, 127
    jle .check_low
    mov eax, 127
    inc dword [sb16_mix_clip_count]
    jmp .store

.check_low:
    cmp eax, -128
    jge .store
    mov eax, -128
    inc dword [sb16_mix_clip_count]

.store:
    push eax
    cmp byte [sb16_playback_active], 1
    jne .overwrite_done
    mov eax, [sb16_dma_write_pos]
    cmp eax, SB16_DMA_BLOCK_BYTES
    jb .write_half_ready
    mov eax, 1
    jmp .check_overwrite

.write_half_ready:
    xor eax, eax

.check_overwrite:
    cmp eax, [sb16_irq_half_index]
    jne .overwrite_done
    inc dword [sb16_mix_overwrite_count]

.overwrite_done:
    pop eax
    add eax, 128
    mov [edi], al
    inc edi
    inc dword [sb16_dma_write_pos]
    cmp dword [sb16_dma_write_pos], SB16_DMA_BUFFER_BYTES
    jb .advance_done
    mov dword [sb16_dma_write_pos], 0
    inc dword [sb16_mix_wrap_count]
    mov edi, sb16_dma_buffer

.advance_done:
    dec ecx
    jmp .mix_next

.done_mix:
    inc dword [sb16_sfx_mix_count]
    mov eax, [audio_sfx_length_arg]
    add [sb16_sfx_mix_bytes], eax
    jmp .done

.underrun:
    inc dword [sb16_mix_underrun_count]

.done:
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

sb16_record_music_render_stats:
    push eax
    push edx

    mov eax, [esi + AUDIO_SFX_DESC_MUSIC_FORMAT]
    cmp eax, 0
    je .done
    cmp eax, 2
    ja .done
    mov [sb16_music_render_format], eax
    inc dword [sb16_music_render_chunk_count]

    mov eax, [esi + AUDIO_SFX_DESC_MUSIC_NOTE_EVENTS]
    add [sb16_music_render_note_count], eax
    mov edx, eax
    mov eax, [esi + AUDIO_SFX_DESC_MUSIC_CONTROL_EVENTS]
    add edx, eax
    add [sb16_music_render_event_count], edx

    mov eax, [esi + AUDIO_SFX_DESC_MUSIC_ACTIVE_VOICE_PEAK]
    cmp eax, [sb16_music_render_active_peak]
    jbe .sample_count
    mov [sb16_music_render_active_peak], eax

.sample_count:
    mov eax, [esi + AUDIO_SFX_DESC_MUSIC_EMITTED_SAMPLES]
    add [sb16_music_render_sample_count], eax

.done:
    pop edx
    pop eax
    ret

audio_register_sfx_voice:
    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov eax, [audio_sfx_desc_arg]
    mov ebx, AUDIO_SFX_DESC_BYTES
    call user_range_validate
    jc .underrun

    mov esi, [audio_sfx_desc_arg]
    mov eax, [esi + AUDIO_SFX_DESC_SAMPLES]
    mov ebx, [esi + AUDIO_SFX_DESC_LENGTH]
    mov [audio_sfx_sample_arg], eax
    mov [audio_sfx_length_arg], ebx
    mov eax, [esi + AUDIO_SFX_DESC_VOLUME]
    and eax, 0xff
    mov [audio_sfx_volume_arg], eax
    mov eax, [esi + AUDIO_SFX_DESC_SEPARATION]
    and eax, 0xff
    mov [audio_sfx_separation_arg], eax
    mov eax, [esi + AUDIO_SFX_DESC_PITCH]
    and eax, 0xff
    mov [audio_sfx_pitch_arg], eax
    mov eax, [esi + AUDIO_SFX_DESC_SOUND_ID]
    mov [audio_sfx_id_arg], eax
    mov eax, [esi + AUDIO_SFX_DESC_FLAGS]
    mov [audio_sfx_flags_arg], eax
    mov eax, [esi + AUDIO_SFX_DESC_SAMPLE_RATE]
    mov [audio_sfx_rate_arg], eax
    mov eax, [audio_sfx_handle_arg]
    and eax, AUDIO_MUSIC_HANDLE_MASK
    cmp eax, AUDIO_MUSIC_HANDLE_BASE
    jne .flags_ready
    or dword [audio_sfx_flags_arg], AUDIO_FLAG_MUSIC

.flags_ready:

    mov eax, [audio_sfx_sample_arg]
    mov ebx, [audio_sfx_length_arg]
    cmp ebx, 0
    je .underrun
    call user_range_validate
    jc .underrun

    call sb16_find_voice_by_handle
    jnc .slot_ready
    call sb16_find_free_voice
    jnc .slot_ready
    call sb16_find_steal_voice

.slot_ready:
    mov [audio_sfx_voice_slot], eax
    mov ebx, eax
    mov byte [sb16_voice_active + ebx], 1
    mov eax, [audio_sfx_handle_arg]
    mov [sb16_voice_handles + ebx * 4], eax
    mov eax, [audio_sfx_sample_arg]
    mov [sb16_voice_samples + ebx * 4], eax
    mov eax, [audio_sfx_length_arg]
    mov [sb16_voice_lengths + ebx * 4], eax
    mov dword [sb16_voice_positions + ebx * 4], 0
    mov eax, [audio_sfx_flags_arg]
    mov [sb16_voice_flags + ebx * 4], eax
    mov dword [sb16_voice_loop_counts + ebx * 4], 0
    mov dword [sb16_voice_pending_samples + ebx * 4], 0
    mov dword [sb16_voice_pending_lengths + ebx * 4], 0
    mov eax, [audio_sfx_volume_arg]
    mov [sb16_voice_volumes + ebx * 4], eax
    mov eax, [audio_sfx_separation_arg]
    mov [sb16_voice_separations + ebx * 4], eax
    mov eax, [audio_sfx_pitch_arg]
    mov [sb16_voice_pitches + ebx * 4], eax
    call sb16_pitch_to_step
    mov [sb16_voice_steps + ebx * 4], eax
    call sb16_compute_pan_from_args
    mov eax, [sb16_pan_left_arg]
    mov [sb16_voice_left_volumes + ebx * 4], eax
    mov eax, [sb16_pan_right_arg]
    mov [sb16_voice_right_volumes + ebx * 4], eax
    inc dword [sb16_voice_age_counter]
    mov eax, [sb16_voice_age_counter]
    mov [sb16_voice_started_at + ebx * 4], eax
    inc dword [sb16_voice_start_count]
    test dword [sb16_voice_flags + ebx * 4], AUDIO_FLAG_MUSIC
    jz .sfx_started
    inc dword [sb16_music_start_count]
    mov dword [sb16_music_stream_mode], AUDIO_MUSIC_STREAM_PULL
    mov eax, [audio_sfx_length_arg]
    mov [sb16_music_stream_buffer_bytes], eax
    call sb16_record_music_render_stats
    jmp .recount

.sfx_started:
    inc dword [sb16_sfx_voice_start_count]
    mov eax, [audio_sfx_length_arg]
    add [sb16_sfx_submit_bytes], eax
    mov eax, [audio_sfx_id_arg]
    mov [sb16_sfx_last_id], eax
    mov eax, [audio_sfx_rate_arg]
    mov [sb16_sfx_last_rate], eax
    mov eax, [audio_sfx_length_arg]
    mov [sb16_sfx_last_length], eax
    test dword [audio_sfx_flags_arg], AUDIO_FLAG_WAD_SFX
    jz .recount
    inc dword [sb16_sfx_wad_start_count]

.recount:
    call sb16_recount_active_voices
    jmp .done

.underrun:
    inc dword [sb16_mix_underrun_count]

.done:
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

audio_stop_sfx_voice:
    push eax
    push ebx

    call sb16_find_voice_by_handle
    jc .done
    mov ebx, eax
    mov byte [sb16_voice_active + ebx], 0
    mov dword [sb16_voice_handles + ebx * 4], 0
    mov dword [sb16_voice_positions + ebx * 4], 0
    mov dword [sb16_voice_started_at + ebx * 4], 0
    test dword [sb16_voice_flags + ebx * 4], AUDIO_FLAG_MUSIC
    jz .count_sfx_stop
    inc dword [sb16_music_stop_count]
    mov dword [sb16_music_stream_buffer_bytes], 0
    jmp .clear_flags

.count_sfx_stop:
    inc dword [sb16_sfx_voice_stop_count]

.clear_flags:
    mov dword [sb16_voice_flags + ebx * 4], 0
    mov dword [sb16_voice_loop_counts + ebx * 4], 0
    mov dword [sb16_voice_pending_samples + ebx * 4], 0
    mov dword [sb16_voice_pending_lengths + ebx * 4], 0
    inc dword [sb16_voice_stop_count]
    call sb16_recount_active_voices

.done:
    pop ebx
    pop eax
    ret

audio_update_sfx_voice:
    push eax
    push ebx
    push edx
    push esi

    mov eax, [audio_sfx_desc_arg]
    mov ebx, AUDIO_SFX_DESC_BYTES
    call user_range_validate
    jc .maybe_drop_music
    call sb16_find_voice_by_handle
    jc .maybe_drop_music
    mov ebx, eax
    mov esi, [audio_sfx_desc_arg]
    mov eax, [esi + AUDIO_SFX_DESC_SAMPLES]
    mov [audio_sfx_sample_arg], eax
    mov eax, [esi + AUDIO_SFX_DESC_LENGTH]
    mov [audio_sfx_length_arg], eax
    mov eax, [esi + AUDIO_SFX_DESC_FLAGS]
    mov [audio_sfx_flags_arg], eax
    mov eax, [esi + AUDIO_SFX_DESC_SAMPLE_RATE]
    mov [audio_sfx_rate_arg], eax
    mov eax, [audio_sfx_handle_arg]
    and eax, AUDIO_MUSIC_HANDLE_MASK
    cmp eax, AUDIO_MUSIC_HANDLE_BASE
    jne .update_flags_ready
    or dword [audio_sfx_flags_arg], AUDIO_FLAG_MUSIC

.update_flags_ready:
    mov eax, [esi + AUDIO_SFX_DESC_VOLUME]
    and eax, 0xff
    mov [audio_sfx_volume_arg], eax
    mov [sb16_voice_volumes + ebx * 4], eax
    mov eax, [esi + AUDIO_SFX_DESC_SEPARATION]
    and eax, 0xff
    mov [audio_sfx_separation_arg], eax
    mov [sb16_voice_separations + ebx * 4], eax
    mov eax, [esi + AUDIO_SFX_DESC_PITCH]
    and eax, 0xff
    mov [audio_sfx_pitch_arg], eax
    mov [sb16_voice_pitches + ebx * 4], eax
    call sb16_pitch_to_step
    mov [sb16_voice_steps + ebx * 4], eax
    call sb16_compute_pan_from_args
    mov eax, [sb16_pan_left_arg]
    mov [sb16_voice_left_volumes + ebx * 4], eax
    mov eax, [sb16_pan_right_arg]
    mov [sb16_voice_right_volumes + ebx * 4], eax

    mov eax, [audio_sfx_sample_arg]
    cmp eax, 0
    je .count_update
    mov edx, [audio_sfx_length_arg]
    cmp edx, 0
    je .count_update
    test dword [sb16_voice_flags + ebx * 4], AUDIO_FLAG_MUSIC
    jnz .refresh_stream_window
    test dword [audio_sfx_flags_arg], AUDIO_FLAG_MUSIC
    jz .count_update

.refresh_stream_window:
    push ebx
    mov eax, [audio_sfx_sample_arg]
    mov ebx, [audio_sfx_length_arg]
    call user_range_validate
    pop ebx
    jc .stream_underrun
    mov eax, [audio_sfx_flags_arg]
    or eax, AUDIO_FLAG_MUSIC
    mov [sb16_voice_flags + ebx * 4], eax
    mov dword [sb16_music_stream_mode], AUDIO_MUSIC_STREAM_PULL
    call sb16_record_music_render_stats
    mov eax, [sb16_voice_positions + ebx * 4]
    shr eax, 16
    cmp eax, [sb16_voice_lengths + ebx * 4]
    jae .store_stream_window
    cmp dword [sb16_voice_pending_lengths + ebx * 4], 0
    jne .replace_pending_window
    mov eax, [audio_sfx_sample_arg]
    mov [sb16_voice_pending_samples + ebx * 4], eax
    mov eax, [audio_sfx_length_arg]
    mov [sb16_voice_pending_lengths + ebx * 4], eax
    call sb16_mark_music_pull_refill
    call sb16_recount_active_voices
    jmp .count_update

.replace_pending_window:
    inc dword [sb16_music_stream_drop_count]
    mov eax, [audio_sfx_sample_arg]
    mov [sb16_voice_pending_samples + ebx * 4], eax
    mov eax, [audio_sfx_length_arg]
    mov [sb16_voice_pending_lengths + ebx * 4], eax
    call sb16_mark_music_pull_refill
    call sb16_recount_active_voices
    jmp .count_update

.store_stream_window:
    mov eax, [audio_sfx_sample_arg]
    mov [sb16_voice_samples + ebx * 4], eax
    mov eax, [audio_sfx_length_arg]
    mov [sb16_voice_lengths + ebx * 4], eax
    mov [sb16_music_stream_buffer_bytes], eax
    mov dword [sb16_voice_positions + ebx * 4], 0
    mov dword [sb16_voice_pending_samples + ebx * 4], 0
    mov dword [sb16_voice_pending_lengths + ebx * 4], 0
    call sb16_mark_music_pull_refill
    call sb16_recount_active_voices
    jmp .count_update

.stream_underrun:
    inc dword [sb16_mix_underrun_count]
    inc dword [sb16_music_stream_under_count]
    inc dword [sb16_music_stream_drop_count]

.count_update:
    test dword [sb16_voice_flags + ebx * 4], AUDIO_FLAG_MUSIC
    jnz .count_global_update
    inc dword [sb16_sfx_voice_update_count]

.count_global_update:
    inc dword [sb16_voice_update_count]

.done:
    pop esi
    pop edx
    pop ebx
    pop eax
    ret

.maybe_drop_music:
    mov eax, [audio_sfx_handle_arg]
    and eax, AUDIO_MUSIC_HANDLE_MASK
    cmp eax, AUDIO_MUSIC_HANDLE_BASE
    jne .done
    inc dword [sb16_music_stream_drop_count]
    jmp .done

sb16_mark_music_pull_refill:
    push eax
    mov eax, [sb16_music_pull_request_count]
    cmp dword [sb16_music_pull_refill_count], eax
    jae .done
    inc dword [sb16_music_pull_refill_count]

.done:
    pop eax
    ret

sb16_note_music_pull_request:
    push eax
    push ebx
    push ecx
    cmp dword [sb16_music_stream_mode], AUDIO_MUSIC_STREAM_PULL
    jne .done
    cmp dword [sb16_active_music_voice_count], 0
    je .done
    xor ebx, ebx
    mov ecx, AUDIO_MAX_SFX_VOICES

.voice_next:
    cmp byte [sb16_voice_active + ebx], 1
    jne .voice_advance
    test dword [sb16_voice_flags + ebx * 4], AUDIO_FLAG_MUSIC
    jz .voice_advance
    test dword [sb16_voice_flags + ebx * 4], AUDIO_FLAG_STREAM_FINAL
    jz .maybe_request

.voice_advance:
    inc ebx
    loop .voice_next
    jmp .done

.maybe_request:
    mov eax, [sb16_music_stream_buffer_bytes]
    cmp eax, AUDIO_MUSIC_PULL_LOW_WATER_BYTES
    ja .done
    mov eax, [sb16_music_pull_request_count]
    cmp eax, dword [sb16_music_pull_refill_count]
    jne .done
    inc dword [sb16_music_pull_request_count]

.done:
    pop ecx
    pop ebx
    pop eax
    ret

sb16_music_promote_pending_window:
    push eax

    test dword [sb16_voice_flags + ebx * 4], AUDIO_FLAG_MUSIC
    jz .none
    cmp dword [sb16_voice_pending_lengths + ebx * 4], 0
    je .none

    mov eax, [sb16_voice_pending_samples + ebx * 4]
    mov [sb16_voice_samples + ebx * 4], eax
    mov eax, [sb16_voice_pending_lengths + ebx * 4]
    mov [sb16_voice_lengths + ebx * 4], eax
    mov dword [sb16_voice_pending_samples + ebx * 4], 0
    mov dword [sb16_voice_pending_lengths + ebx * 4], 0
    mov dword [sb16_voice_positions + ebx * 4], 0
    mov dword [sb16_mix_source_pos], 0
    clc
    jmp .done

.none:
    stc

.done:
    pop eax
    ret

sb16_refill_active_half:
    pushad

    mov edi, sb16_dma_buffer
    cmp dword [sb16_irq_half_index], 0
    je .dest_ready
    add edi, SB16_DMA_BLOCK_BYTES

.dest_ready:
    mov [sb16_refill_dest_base], edi
    mov eax, 0x80808080
    mov ecx, SB16_DMA_BLOCK_BYTES / 4
    cld
    rep stosd

    cmp dword [sb16_active_voice_count], 0
    jne .have_voices
    inc dword [sb16_mix_underrun_count]

.have_voices:
    xor ebx, ebx

.voice_next:
    cmp ebx, AUDIO_MAX_SFX_VOICES
    jae .done_voices
    cmp byte [sb16_voice_active + ebx], 1
    jne .advance_voice

    mov [sb16_mix_voice_slot], ebx
    mov eax, [sb16_voice_positions + ebx * 4]
    mov edx, eax
    shr edx, 16
    cmp edx, [sb16_voice_lengths + ebx * 4]
    jae .finish_voice
    mov [sb16_mix_source_pos], eax
    mov eax, [sb16_voice_steps + ebx * 4]
    mov [sb16_mix_source_step], eax
    mov eax, [sb16_voice_left_volumes + ebx * 4]
    mov [sb16_mix_left_volume], eax
    mov eax, [sb16_voice_right_volumes + ebx * 4]
    mov [sb16_mix_right_volume], eax
    mov edi, [sb16_refill_dest_base]
    mov ecx, SB16_DMA_BLOCK_BYTES / 2
    mov dword [sb16_mix_frames_mixed], 0

.mix_next:
    cmp ecx, 0
    je .voice_mixed
    mov eax, [sb16_mix_source_pos]
    mov edx, eax
    shr edx, 16
    mov ebx, [sb16_mix_voice_slot]
    cmp edx, [sb16_voice_lengths + ebx * 4]
    jb .source_ready
    test dword [sb16_voice_flags + ebx * 4], AUDIO_FLAG_LOOP
    jz .maybe_promote_pending
    cmp dword [sb16_voice_lengths + ebx * 4], 0
    je .voice_mixed
    mov dword [sb16_mix_source_pos], 0
    inc dword [sb16_voice_loop_counts + ebx * 4]
    test dword [sb16_voice_flags + ebx * 4], AUDIO_FLAG_MUSIC
    jz .mix_next
    inc dword [sb16_music_loop_count]
    jmp .mix_next

.maybe_promote_pending:
    call sb16_music_promote_pending_window
    jnc .mix_next
    jmp .voice_mixed

.source_ready:
    mov esi, [sb16_voice_samples + ebx * 4]
    add esi, edx
    movzx eax, byte [esi]
    sub eax, 128
    mov ebp, eax
    mov edx, [sb16_mix_left_volume]
    imul eax, edx
    sar eax, 7
    movzx edx, byte [edi]
    sub edx, 128
    add eax, edx
    cmp eax, 127
    jle .check_low
    mov eax, 127
    inc dword [sb16_mix_clip_count]
    jmp .store

.check_low:
    cmp eax, -128
    jge .store
    mov eax, -128
    inc dword [sb16_mix_clip_count]

.store:
    add eax, 128
    mov [edi], al
    mov eax, ebp
    mov edx, [sb16_mix_right_volume]
    imul eax, edx
    sar eax, 7
    movzx edx, byte [edi + 1]
    sub edx, 128
    add eax, edx
    cmp eax, 127
    jle .right_check_low
    mov eax, 127
    inc dword [sb16_mix_clip_count]
    jmp .right_store

.right_check_low:
    cmp eax, -128
    jge .right_store
    mov eax, -128
    inc dword [sb16_mix_clip_count]

.right_store:
    add eax, 128
    mov [edi + 1], al
    add edi, 2
    mov eax, [sb16_mix_source_step]
    add [sb16_mix_source_pos], eax
    inc dword [sb16_mix_frames_mixed]
    dec ecx
    jmp .mix_next

.voice_mixed:
    mov ebx, [sb16_mix_voice_slot]
    mov eax, [sb16_mix_source_pos]
    mov [sb16_voice_positions + ebx * 4], eax
    mov eax, [sb16_mix_frames_mixed]
    cmp eax, 0
    je .check_finished
    test dword [sb16_voice_flags + ebx * 4], AUDIO_FLAG_MUSIC
    jz .count_sfx_mix
    add [sb16_music_stream_pos_bytes], eax
    shl eax, 1
    inc dword [sb16_music_mix_count]
    add [sb16_music_mix_bytes], eax
    jmp .check_finished

.count_sfx_mix:
    shl eax, 1
    inc dword [sb16_sfx_mix_count]
    add [sb16_sfx_mix_bytes], eax
    add [sb16_sfx_output_bytes], eax
    inc dword [sb16_sfx_dma_mix_count]
    add [sb16_sfx_dma_mix_bytes], eax

.check_finished:
    mov eax, [sb16_voice_positions + ebx * 4]
    shr eax, 16
    cmp eax, [sb16_voice_lengths + ebx * 4]
    jb .advance_voice
    test dword [sb16_voice_flags + ebx * 4], AUDIO_FLAG_LOOP
    jz .maybe_promote_pending_after_half
    cmp dword [sb16_voice_lengths + ebx * 4], 0
    je .finish_voice
    mov dword [sb16_voice_positions + ebx * 4], 0
    inc dword [sb16_voice_loop_counts + ebx * 4]
    test dword [sb16_voice_flags + ebx * 4], AUDIO_FLAG_MUSIC
    jz .advance_voice
    inc dword [sb16_music_loop_count]
    jmp .advance_voice

.maybe_promote_pending_after_half:
    call sb16_music_promote_pending_window
    jnc .advance_voice
    jmp .finish_voice

.finish_voice:
    test dword [sb16_voice_flags + ebx * 4], AUDIO_FLAG_MUSIC
    jz .finish_sfx
    test dword [sb16_voice_flags + ebx * 4], AUDIO_FLAG_STREAM_FINAL
    jnz .finish_terminal_music
    inc dword [sb16_music_stream_under_count]
.finish_terminal_music:
    mov dword [sb16_music_stream_buffer_bytes], 0
    jmp .finish_clear

.finish_sfx:
    inc dword [sb16_sfx_voice_finished_count]

.finish_clear:
    mov byte [sb16_voice_active + ebx], 0
    mov dword [sb16_voice_handles + ebx * 4], 0
    mov dword [sb16_voice_started_at + ebx * 4], 0
    mov dword [sb16_voice_flags + ebx * 4], 0
    mov dword [sb16_voice_loop_counts + ebx * 4], 0
    mov dword [sb16_voice_pending_samples + ebx * 4], 0
    mov dword [sb16_voice_pending_lengths + ebx * 4], 0
    inc dword [sb16_voice_finished_count]

.advance_voice:
    inc ebx
    jmp .voice_next

.done_voices:
    inc dword [sb16_voice_refill_count]
    call sb16_recount_active_voices
    call sb16_note_music_pull_request
    popad
    ret

sb16_program_dma8:
    push eax
    push ecx
    push edx

    mov al, 0x04 | SB16_DMA8_CHANNEL
    out DMA8_MASK_REG, al
    out DMA8_CLEAR_FLIPFLOP_REG, al

    mov eax, sb16_dma_buffer
    mov dx, DMA8_CH1_ADDR_REG
    out dx, al
    shr eax, 8
    out dx, al
    shr eax, 8
    mov dx, DMA8_CH1_PAGE_REG
    out dx, al

    out DMA8_CLEAR_FLIPFLOP_REG, al
    mov ecx, SB16_DMA_BUFFER_BYTES - 1
    mov dx, DMA8_CH1_COUNT_REG
    mov al, cl
    out dx, al
    mov al, ch
    out dx, al

    mov al, DMA8_CH1_AUTO_READ_MODE
    out DMA8_MODE_REG, al
    mov al, SB16_DMA8_CHANNEL
    out DMA8_MASK_REG, al
    inc dword [sb16_dma_program_count]

    pop edx
    pop ecx
    pop eax
    ret

sb16_start_playback:
    cmp byte [audio_status], 1
    jne .not_ready
    cmp byte [sb16_playback_active], 1
    je .not_ready
    call sb16_clear_dma_buffer
    call sb16_program_dma8

    mov al, SB16_DSP_SPEAKER_ON
    call sb16_write_dsp
    jc .fail
    mov al, SB16_DSP_SET_TIME_CONSTANT
    call sb16_write_dsp
    jc .fail
    mov al, SB16_TIME_CONSTANT
    call sb16_write_dsp
    jc .fail
    mov al, SB16_DSP_SET_OUTPUT_RATE
    call sb16_write_dsp
    jc .fail
    mov al, SB16_SAMPLE_RATE_HIGH
    call sb16_write_dsp
    jc .fail
    mov al, SB16_SAMPLE_RATE_LOW
    call sb16_write_dsp
    jc .fail
    mov al, SB16_DSP_SET_BLOCK_SIZE
    call sb16_write_dsp
    jc .fail
    mov ax, SB16_DMA_BLOCK_BYTES - 1
    call sb16_write_dsp
    jc .fail
    mov al, ah
    call sb16_write_dsp
    jc .fail
    mov al, SB16_DSP_8BIT_AUTO_OUT
    call sb16_write_dsp
    jc .fail
    mov al, SB16_DSP_MODE_UNSIGNED_STEREO
    call sb16_write_dsp
    jc .fail
    mov ax, SB16_DMA_BLOCK_BYTES - 1
    call sb16_write_dsp
    jc .fail
    mov al, ah
    call sb16_write_dsp
    jc .fail

    mov byte [sb16_playback_active], 1
    inc dword [sb16_playback_start_count]
    clc
    ret

.not_ready:
    clc
    ret

.fail:
    mov byte [sb16_playback_active], 0
    stc
    ret

sb16_stop_playback:
    cmp byte [audio_status], 1
    jne .not_ready
    mov al, SB16_DSP_EXIT_8BIT_AUTO
    call sb16_write_dsp
    mov al, SB16_DSP_SPEAKER_OFF
    call sb16_write_dsp
    mov al, 0x04 | SB16_DMA8_CHANNEL
    out DMA8_MASK_REG, al
    mov byte [sb16_playback_active], 0
    inc dword [sb16_playback_stop_count]
    call sb16_clear_active_voices

.not_ready:
    clc
    ret

sb16_write_dsp:
    push ecx
    push edx
    push eax
    mov ah, al
    mov ecx, 0x10000
    mov dx, SB16_DSP_WRITE

.wait_next:
    in al, dx
    test al, SB16_DSP_READY
    jz .write_ok
    loop .wait_next
    pop eax
    stc
    jmp .done

.write_ok:
    mov al, ah
    out dx, al
    pop eax
    clc

.done:
    pop edx
    pop ecx
    ret

sb16_read_dsp:
    push ecx
    push edx
    mov ecx, 0x10000
    mov dx, SB16_DSP_READ_STATUS

.wait_next:
    in al, dx
    test al, SB16_DSP_READY
    jnz .read_ok
    loop .wait_next
    stc
    jmp .done

.read_ok:
    mov dx, SB16_DSP_READ
    in al, dx
    clc

.done:
    pop edx
    pop ecx
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
    mov dword [ata_last_lba], 0
    mov dword [ata_last_op], ATA_OP_NONE
    mov dword [ata_wait_phase], ATA_WAIT_IDLE
    mov dword [ata_last_status], 0
    mov dword [ata_last_error], 0
    mov dword [ata_wait_failures], 0
    mov dword [ata_wait_timeouts], 0
    mov dword [ata_wait_error_failures], 0
    mov dword [fat_lba_base], 0
    mov dword [fat_total_sectors], 0
    mov dword [fat_last_data_cluster], 0
    mov dword [fat_next_free_hint], 2
    mov dword [fat_scan_start], 0
    mov dword [fat_alloc_zero_policy], 1
    mov dword [fat_file_lba_was_new_cluster], 0
    mov dword [fat_alloc_debug_stage], 0
    mov dword [fat_alloc_debug_hint], 0
    mov dword [fat_alloc_debug_cluster], 0
    mov dword [fat_alloc_debug_refreshes], 0
    mov dword [fat_alloc_scan_refreshed], 0
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
    mov ecx, USER_FD_COUNT
    xor ebx, ebx

.clear_user_fds:
    mov byte [fd_status + ebx], FD_KIND_FREE
    mov byte [fd_kinds + ebx], FD_KIND_FREE
    mov dword [fd_indices + ebx * 4], 0
    mov dword [fd_offsets + ebx * 4], 0
    mov dword [fd_flags + ebx * 4], 0
    mov dword [fd_owner_pids + ebx * 4], 0xffffffff
    mov dword [fd_open_generations + ebx * 4], 0
    mov dword [fd_inherit_flags + ebx * 4], 0
    inc ebx
    loop .clear_user_fds
    mov ecx, WRITABLE_FILE_COUNT
    xor ebx, ebx

.clear_writable_files:
    mov byte [writable_status + ebx], 0
    mov word [writable_first_clusters + ebx * 2], 0
    mov dword [writable_sizes + ebx * 4], 0
    mov dword [writable_root_lbas + ebx * 4], 0
    mov dword [writable_root_offsets + ebx * 4], 0
    mov dword [writable_offsets + ebx * 4], 0
    inc ebx
    loop .clear_writable_files
    mov ecx, PERSISTENCE_MARKER_COUNT
    xor ebx, ebx

.clear_persistence_markers:
    mov byte [persistence_marker_status + ebx], 0
    mov dword [persistence_marker_sizes + ebx * 4], 0
    inc ebx
    loop .clear_persistence_markers
    mov byte [doom_user_window_status], 0
    mov word [doom_elf_first_cluster], 0
    mov dword [current_pid], 0
    mov dword [current_process_ptr], 0
    mov dword [current_user_base], 0
    mov dword [current_user_end], 0
    mov dword [current_user_brk], 0
    mov dword [current_user_heap_start], 0
    mov dword [current_user_heap_end], 0
    mov dword [current_user_stack_top], 0
    mov dword [current_user_entry], 0
    mov dword [current_syscall_number], 0
    mov dword [syscall_return_value], 0
    mov dword [file_write_debug_stage], 0
    mov dword [file_write_debug_result], 0
    mov dword [file_write_debug_capacity], 0
    mov dword [syscall_stat_ptr], 0
    mov dword [fat_unlink_slot], 0xffffffff
    mov dword [stat_size_arg], 0
    mov dword [stat_mode_arg], 0
    mov dword [mmap_addr_arg], 0
    mov dword [mmap_len_arg], 0
    mov dword [mmap_prot_arg], 0
    mov dword [mmap_flags_arg], 0
    mov dword [mmap_base_arg], 0
    mov dword [mmap_end_arg], 0
    mov byte [current_user_kind], USER_KIND_NONE
    mov byte [doom_run_status], 0
    mov dword [doom_exit_code], 0
    mov dword [doom_fault_addr], 0
    mov dword [doom_fault_eip], 0
    mov dword [doom_fault_vector], 0
    mov dword [doom_fault_error], 0
    call clear_fault_record
    mov dword [doom_last_syscall], 0
    mov dword [doom_open_count], 0
    mov dword [doom_read_count], 0
    mov dword [doom_lseek_count], 0
    mov dword [doom_write_count], 0
    mov dword [doom_close_count], 0
    mov dword [doom_sbrk_count], 0
    mov dword [doom_error_count], 0
    mov dword [doom_last_error], 0
    mov dword [doom_last_open_flags], 0
    mov dword [doom_last_open_mode], 0
    mov dword [doom_saveload_flags], 0
    mov dword [doom_saveload_slot], 0xffffffff
    mov dword [doom_saveload_open_count], 0
    mov dword [doom_saveload_read_count], 0
    mov dword [doom_saveload_write_count], 0
    mov dword [doom_saveload_close_count], 0
    mov dword [doom_saveload_read_bytes], 0
    mov dword [doom_saveload_write_bytes], 0
    mov dword [doom_saveload_last_open_flags], 0
    mov dword [doom_saveload_last_open_mode], 0
    mov dword [doom_saveaction_flags], 0
    mov dword [doom_saveaction_gameaction], 0
    mov dword [doom_saveaction_slot], 0xffffffff
    mov dword [doom_saveaction_desc_len], 0
    mov dword [doom_saveaction_desc_hash], 0
    mov dword [doom_saveaction_report_count], 0
    mov dword [doom_present_count], 0
    mov dword [doom_init_flags], 0
    mov dword [doom_init_report_count], 0
    mov byte [doom_gameplay_status], 0
    mov dword [doom_gameplay_report_count], 0
    mov dword [doom_game_state_packed], 0
    mov dword [doom_game_state], 0
    mov dword [doom_game_episode], 0
    mov dword [doom_game_map], 0
    mov dword [doom_game_map_pair], 0
    mov dword [doom_game_flags], 0
    mov dword [doom_game_tic], 0
    mov dword [doom_level_time], 0
    mov dword [doom_player_flags], 0
    mov dword [doom_player_buttons], 0
    mov dword [doom_game_action], 0
    mov dword [doom_player_x], 0
    mov dword [doom_player_y], 0
    mov dword [doom_player_origin_set], 0
    mov dword [doom_player_origin_x], 0
    mov dword [doom_player_origin_y], 0
    mov dword [doom_player_delta], 0
    mov dword [doom_player_cmd], 0
    mov dword [doom_player_angle], 0
    mov dword [doom_player_angle_origin_set], 0
    mov dword [doom_player_origin_angle], 0
    mov dword [doom_player_angle_delta], 0
    mov dword [doom_player_ammo], 0
    mov dword [doom_player_refire], 0
    mov dword [doom_player_weapon], 0
    mov dword [doom_key_down_seen], 0
    mov dword [doom_key_last_event], 0
    mov dword [doom_mouse_event_count], 0
    mov dword [doom_mouse_buttons_seen], 0
    mov dword [doom_mouse_delta_x], 0
    mov dword [doom_mouse_delta_y], 0
    mov dword [doom_mouse_last_event], 0
    mov dword [doom_sound_call_count], 0
    mov dword [doom_sound_start_count], 0
    mov dword [doom_sound_stop_count], 0
    mov dword [doom_sound_update_count], 0
    mov dword [doom_sound_last_command], 0
    mov dword [doom_sound_last_handle], 0
    mov dword [doom_sound_last_packed], 0
    mov dword [doom_wad_magic_seen], 0
    mov dword [doom_log_len], 0
    mov byte [doom_log_buffer], 0
    mov byte [present_status], 0
    mov dword [present_frame_arg], 0
    mov dword [present_palette_arg], 0
    mov dword [present_sample_first], 0
    mov dword [present_sample_mid], 0
    mov dword [present_sample_last], 0
    mov dword [present_palette_hash], 0
    mov dword [present_frame_hash], 0
    mov dword [present_nonzero_count], 0
    mov dword [present_color_transition_count], 0
    mov byte [present_previous_index], 0
    call present_reset_status_fields
    call mouse_reset_queue

    mov dword [sys_exec_attempts], 0
    mov dword [sys_exec_successes], 0
    mov dword [sys_exec_failures], 0
    mov dword [sys_exec_handoffs], 0
    mov dword [sys_exec_scheduled], 0
    mov dword [sys_exec_rollbacks], 0
    mov dword [sys_exec_last_result], 0
    mov dword [sys_exec_last_caller_pid], 0xffffffff
    mov dword [sys_exec_last_parent_pid], 0xffffffff
    mov dword [sys_exec_last_target_pid], 0xffffffff
    mov dword [sys_exec_last_target_entry], 0
    mov dword [sys_exec_last_target_stack], 0
    mov dword [sys_exec_last_argc], 0
    mov dword [sys_exec_last_argv], 0
    mov dword [sys_exec_last_envp], 0
    mov dword [sys_exec_last_argv0], 0
    mov dword [sys_exec_last_envp0], 0
    mov dword [sys_exec_last_argv_source], 0
    mov dword [sys_exec_user_argv_arg], 0
    mov dword [sys_exec_flags_arg], 0
    mov dword [sys_exec_frame_ptr], 0
    mov dword [sys_exec_user_stack_ptr], 0
    mov dword [sys_exec_argv0_ptr], 0
    mov dword [sys_exec_argc], 0
    mov dword [sys_exec_arg_copy_index], 0
    mov dword [sys_exec_stack_cursor], 0
    mov dword [process_exec_last_error], 0
    mov byte [process_exec_reject_active_target], 0
    mov byte [sys_exec_path_buffer], 0
    mov dword [process_wait_attempts], 0
    mov dword [process_wait_reaps], 0
    mov dword [process_wait_failures], 0
    mov dword [process_wait_last_pid_arg], 0
    mov dword [process_wait_last_status_ptr], 0
    mov dword [process_wait_last_options], 0
    mov dword [process_wait_last_reaped_pid], 0xffffffff
    mov dword [process_wait_last_status], 0
    mov dword [process_wait_seen_live_child], 0
    mov dword [process_wait_nohang_returns], 0
    mov dword [process_wait_seeded_children], 0
    mov dword [process_wait_seeded_child_pid], 0xffffffff
    mov dword [fd_exec_handoffs], 0
    mov dword [fd_exec_inherited], 0
    mov dword [fd_exec_closed], 0
    mov dword [fd_owner_closes], 0
    mov dword [fd_last_exec_from_pid], 0xffffffff
    mov dword [fd_last_exec_to_pid], 0xffffffff
    mov dword [fd_last_closed_owner_pid], 0xffffffff

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
    movzx eax, word [SECTOR_BUFFER_ADDR + 19]
    cmp eax, 0
    jne .have_total_sectors
    mov eax, [SECTOR_BUFFER_ADDR + 32]

.have_total_sectors:
    mov [fat_total_sectors], eax

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
    mov eax, [fat_total_sectors]
    sub eax, [fat_reserved_sectors]
    mov ebx, [fat_sectors_per_fat]
    mov ecx, [fat_count]
    imul ebx, ecx
    sub eax, ebx
    sub eax, [fat_root_sectors]
    xor edx, edx
    movzx ebx, byte [fat_sectors_per_cluster]
    div ebx
    inc eax
    mov [fat_last_data_cluster], eax
    mov byte [fat_status], 1
    cmp dword [fat_sectors_per_fat], FAT_TABLE_CACHE_SECTORS
    ja .fat_fail
    call fat_cache_table
    jc .fat_fail
    cmp dword [fat_root_sectors], FAT_ROOT_CACHE_SECTORS
    ja .fat_fail
    call fat_cache_root_dir
    jc .fat_fail

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
    call fat_find_writable_files
    call fat_find_persistence_markers

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

    mov dword [ata_wait_phase], ATA_WAIT_BUSY
    mov ecx, ATA_WAIT_POLL_LIMIT
    mov dx, ATA_COMMAND_STATUS

.wait_next:
    in al, dx
    movzx eax, al
    mov [ata_last_status], eax
    test al, ATA_STATUS_BSY
    jz .not_busy
    loop .wait_next
    inc dword [ata_wait_failures]
    inc dword [ata_wait_timeouts]
    mov dword [ata_last_error], 0
    stc
    jmp .done

.not_busy:
    test al, ATA_STATUS_DF | ATA_STATUS_ERR
    jnz .error

.ok:
    mov dword [ata_wait_phase], ATA_WAIT_IDLE
    clc
    jmp .done

.error:
    mov dx, ATA_ERROR
    in al, dx
    movzx eax, al
    mov [ata_last_error], eax
    inc dword [ata_wait_failures]
    inc dword [ata_wait_error_failures]
    stc

.done:
    pop edx
    pop ecx
    ret

ata_wait_drq:
    push ecx
    push edx

    mov dword [ata_wait_phase], ATA_WAIT_DRQ
    mov ecx, ATA_WAIT_POLL_LIMIT
    mov dx, ATA_COMMAND_STATUS

.wait_next:
    in al, dx
    movzx eax, al
    mov [ata_last_status], eax
    test al, ATA_STATUS_BSY
    jnz .advance
    test al, ATA_STATUS_DF | ATA_STATUS_ERR
    jnz .error
    test al, ATA_STATUS_DRQ
    jnz .ok

.advance:
    loop .wait_next

    inc dword [ata_wait_failures]
    inc dword [ata_wait_timeouts]
    mov dword [ata_last_error], 0
    stc
    jmp .done

.error:
    mov dx, ATA_ERROR
    in al, dx
    movzx eax, al
    mov [ata_last_error], eax
    inc dword [ata_wait_failures]
    inc dword [ata_wait_error_failures]
    stc
    jmp .done

.ok:
    mov dword [ata_wait_phase], ATA_WAIT_IDLE
    clc

.done:
    pop edx
    pop ecx
    ret

ata_wait_ready:
    push ecx
    push edx

    mov dword [ata_wait_phase], ATA_WAIT_READY
    mov ecx, ATA_WAIT_POLL_LIMIT
    mov dx, ATA_COMMAND_STATUS

.wait_next:
    in al, dx
    movzx eax, al
    mov [ata_last_status], eax
    test al, ATA_STATUS_BSY
    jnz .advance
    test al, ATA_STATUS_DF | ATA_STATUS_ERR
    jnz .error
    test al, ATA_STATUS_DRQ
    jz .ok

.advance:
    loop .wait_next

    inc dword [ata_wait_failures]
    inc dword [ata_wait_timeouts]
    mov dword [ata_last_error], 0
    stc
    jmp .done

.error:
    mov dx, ATA_ERROR
    in al, dx
    movzx eax, al
    mov [ata_last_error], eax
    inc dword [ata_wait_failures]
    inc dword [ata_wait_error_failures]
    stc
    jmp .done

.ok:
    mov dword [ata_wait_phase], ATA_WAIT_IDLE
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
    mov dword [ata_last_op], ATA_OP_READ
    mov [ata_last_lba], eax
    call ata_wait_ready
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
    call ata_io_delay

    call ata_wait_drq
    jc .fail

    cld
    mov dword [ata_wait_phase], ATA_WAIT_DATA
    mov dx, ATA_DATA
    mov ecx, 256
.read_word:
    in ax, dx
    mov [edi], ax
    add edi, 2
    loop .read_word
    mov dword [ata_wait_phase], ATA_WAIT_IDLE
    call ata_io_delay
    call ata_wait_ready
    jc .fail
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

ata_write_sector:
    push ebx
    push ecx
    push edx
    push esi

    mov ebx, eax
    mov dword [ata_last_op], ATA_OP_WRITE
    mov [ata_last_lba], eax
    call ata_wait_ready
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
    mov al, ATA_CMD_WRITE_SECTORS
    out dx, al
    call ata_io_delay

    call ata_wait_drq
    jc .fail

    cld
    mov dword [ata_wait_phase], ATA_WAIT_DATA
    mov dx, ATA_DATA
    mov ecx, 256
.write_word:
    mov ax, [esi]
    out dx, ax
    add esi, 2
    loop .write_word
    mov dword [ata_wait_phase], ATA_WAIT_IDLE
    call ata_io_delay
    call ata_wait_ready
    jc .fail
    mov byte [ata_status], 1
    clc
    jmp .done

.fail:
    mov byte [ata_status], 2
    stc

.done:
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

fat_cache_root_dir:
    push ebx
    push ecx
    push edi

    xor ebx, ebx

.sector_loop:
    cmp ebx, [fat_root_sectors]
    jae .ok
    mov eax, [fat_root_lba]
    add eax, ebx
    mov edi, ebx
    shl edi, 9
    add edi, fat_root_cache
    call ata_read_sector
    jc .fail
    inc ebx
    jmp .sector_loop

.ok:
    clc
    jmp .done

.fail:
    stc

.done:
    pop edi
    pop ecx
    pop ebx
    ret

fat_cache_table:
    push ebx
    push ecx
    push edi

    xor ebx, ebx

.sector_loop:
    cmp ebx, [fat_sectors_per_fat]
    jae .ok
    mov eax, [fat_start_lba]
    add eax, ebx
    mov edi, ebx
    shl edi, 9
    add edi, fat_table_cache
    call ata_read_sector
    jc .fail
    inc ebx
    jmp .sector_loop

.ok:
    clc
    jmp .done

.fail:
    stc

.done:
    pop edi
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
    mov esi, ebx
    shl esi, 9
    add esi, fat_root_cache
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
    mov eax, [fat_root_lba]
    add eax, ebx
    mov [fat_found_root_lba], eax
    mov eax, esi
    sub eax, fat_root_cache
    and eax, 511
    mov [fat_found_root_offset], eax
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

    shl eax, 1
    mov ebx, eax
    mov eax, [fat_sectors_per_fat]
    shl eax, 9
    cmp ebx, eax
    jae .fail
    movzx eax, word [fat_table_cache + ebx]
    clc
    jmp .done

.fail:
    stc

.done:
    pop edx
    pop ecx
    pop ebx
    ret

fat_write_cluster_entry:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov [fat_mut_cluster], eax
    mov [fat_mut_value], dx
    shl eax, 1
    xor edx, edx
    mov ecx, 512
    div ecx
    mov [fat_mut_sector_index], eax
    mov [fat_mut_entry_offset], edx
    cmp eax, [fat_sectors_per_fat]
    jae .fail
    mov esi, eax
    shl esi, 9
    add esi, fat_table_cache
    mov edx, [fat_mut_entry_offset]
    mov ax, [fat_mut_value]
    mov [esi + edx], ax
    xor ebx, ebx

.fat_copy_loop:
    cmp ebx, [fat_count]
    jae .ok
    mov eax, [fat_sectors_per_fat]
    mul ebx
    add eax, [fat_start_lba]
    add eax, [fat_mut_sector_index]
    mov esi, [fat_mut_sector_index]
    shl esi, 9
    add esi, fat_table_cache
    call ata_write_sector
    jc .fail
    inc ebx
    jmp .fat_copy_loop

.ok:
    clc
    jmp .done

.fail:
    stc

.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

fat_zero_cluster:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    cmp eax, 2
    jb .fail
    cmp eax, [fat_last_data_cluster]
    ja .fail
    sub eax, 2
    movzx ebx, byte [fat_sectors_per_cluster]
    mul ebx
    add eax, [fat_data_lba]
    mov [fat_current_lba], eax
    mov edi, SECTOR_BUFFER_ADDR
    xor eax, eax
    mov ecx, 512 / 4
    cld
    rep stosd
    movzx ecx, byte [fat_sectors_per_cluster]

.sector_loop:
    cmp ecx, 0
    je .ok
    push ecx
    mov eax, [fat_current_lba]
    mov esi, SECTOR_BUFFER_ADDR
    call ata_write_sector
    pop ecx
    jc .fail
    inc dword [fat_current_lba]
    dec ecx
    jmp .sector_loop

.ok:
    clc
    jmp .done

.fail:
    stc

.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

fat_alloc_cluster:
    push ebx
    push ecx
    push edx
    push edi

    mov dword [fat_alloc_scan_refreshed], 0

.start_scan:
    mov dword [fat_alloc_debug_stage], 1
    mov ebx, [fat_next_free_hint]
    mov [fat_alloc_debug_hint], ebx
    cmp ebx, 2
    jae .hint_min_ok
    mov ebx, 2

.hint_min_ok:
    cmp ebx, [fat_last_data_cluster]
    jbe .hint_ready
    mov ebx, 2

.hint_ready:
    mov [fat_scan_start], ebx

.scan_loop:
    cmp ebx, [fat_last_data_cluster]
    ja .wrap_scan
    mov eax, ebx
    call fat_next_cluster
    jc .fail
    cmp ax, 0
    je .found
    inc ebx
    jmp .scan_loop

.wrap_scan:
    mov ebx, 2
    cmp ebx, [fat_scan_start]
    jae .retry_or_fail

.wrap_loop:
    cmp ebx, [fat_scan_start]
    jae .retry_or_fail
    mov eax, ebx
    call fat_next_cluster
    jc .fail
    cmp ax, 0
    je .found
    inc ebx
    jmp .wrap_loop

.found:
    mov dword [fat_alloc_debug_stage], 2
    mov [fat_alloc_debug_cluster], ebx
    mov eax, ebx
    mov dx, 0xffff
    call fat_write_cluster_entry
    jc .fail
    mov eax, ebx
    cmp dword [fat_alloc_zero_policy], 0
    je .allocated
    call fat_zero_cluster
    jc .rollback_alloc

.allocated:
    mov dword [fat_alloc_debug_stage], 3
    mov edx, ebx
    inc edx
    cmp edx, [fat_last_data_cluster]
    jbe .store_hint
    mov edx, 2

.store_hint:
    mov [fat_next_free_hint], edx
    mov eax, ebx
    clc
    jmp .done

.rollback_alloc:
    mov dword [fat_alloc_debug_stage], 0xe1
    mov eax, ebx
    xor edx, edx
    call fat_write_cluster_entry
    stc
    jmp .done

.retry_or_fail:
    cmp dword [fat_alloc_scan_refreshed], 0
    jne .fail
    mov dword [fat_alloc_scan_refreshed], 1
    inc dword [fat_alloc_debug_refreshes]
    mov dword [fat_alloc_debug_stage], 0xd0
    call fat_cache_table
    jc .fail
    jmp .start_scan

.fail:
    mov dword [fat_alloc_debug_stage], 0xe0
    stc

.done:
    pop edi
    pop edx
    pop ecx
    pop ebx
    ret

fat_free_chain:
    push eax
    push ebx
    push ecx
    push edx

    movzx ebx, ax
    cmp ax, 0
    je .ok
    cmp ebx, 2
    jb .fail
    mov [fat_current_cluster], ax
    mov ecx, [fat_last_data_cluster]

.validate_loop:
    cmp ebx, 0xfff8
    jae .validated
    cmp ebx, 2
    jb .fail
    cmp ebx, [fat_last_data_cluster]
    ja .fail
    cmp ecx, 0
    je .fail
    mov eax, ebx
    call fat_next_cluster
    jc .fail
    cmp ax, 0
    je .fail
    movzx ebx, ax
    dec ecx
    jmp .validate_loop

.validated:
    movzx ebx, word [fat_current_cluster]
    mov [fat_next_free_hint], ebx

.free_loop:
    cmp ebx, 0xfff8
    jae .ok
    cmp ebx, 2
    jb .fail
    cmp ebx, [fat_last_data_cluster]
    ja .fail
    mov eax, ebx
    call fat_next_cluster
    jc .fail
    mov [fat_free_next_cluster], ax
    mov eax, ebx
    xor edx, edx
    call fat_write_cluster_entry
    jc .fail
    movzx ebx, word [fat_free_next_cluster]
    jmp .free_loop

.ok:
    clc
    jmp .done

.fail:
    stc

.done:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

fat_create_root_file:
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov [fat_search_name], edi
    xor ebx, ebx

.sector_loop:
    cmp ebx, [fat_root_sectors]
    jae .fail
    mov esi, ebx
    shl esi, 9
    add esi, fat_root_cache
    mov ecx, 16

.entry_loop:
    cmp byte [esi], 0
    je .create_here
    cmp byte [esi], 0xe5
    je .create_here
    add esi, 32
    loop .entry_loop
    inc ebx
    jmp .sector_loop

.create_here:
    push ecx
    push esi
    mov edi, esi
    xor eax, eax
    mov ecx, 32 / 4
    cld
    rep stosd
    pop esi
    mov edi, esi
    mov esi, [fat_search_name]
    mov ecx, 11
    cld
    rep movsb
    pop ecx
    mov byte [edi], 0x20
    mov eax, [fat_root_lba]
    add eax, ebx
    mov [fat_found_root_lba], eax
    mov eax, edi
    sub eax, 11
    sub eax, fat_root_cache
    and eax, 511
    mov [fat_found_root_offset], eax
    mov word [fat_found_first_cluster], 0
    mov dword [fat_found_size], 0
    mov eax, [fat_found_root_lba]
    mov esi, ebx
    shl esi, 9
    add esi, fat_root_cache
    call ata_write_sector
    jc .fail
    clc
    jmp .done

.fail:
    stc

.done:
    pop edi
    pop esi
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

fat_find_writable_files:
    push ebx

    xor ebx, ebx

.loop:
    cmp ebx, WRITABLE_KNOWN_FILE_COUNT
    jae .ok
    mov edi, [writable_name_table + ebx * 4]
    push ebx
    call fat_find_file
    pop ebx
    jnc .found
    mov edi, [writable_name_table + ebx * 4]
    push ebx
    call fat_create_root_file
    pop ebx
    jc .fail

.found:
    mov eax, [fat_found_size]
    cmp eax, [writable_capacity_table + ebx * 4]
    ja .fail
    mov ax, [fat_found_first_cluster]
    mov [writable_first_clusters + ebx * 2], ax
    mov eax, [fat_found_size]
    mov [writable_sizes + ebx * 4], eax
    mov eax, [fat_found_root_lba]
    mov [writable_root_lbas + ebx * 4], eax
    mov eax, [fat_found_root_offset]
    mov [writable_root_offsets + ebx * 4], eax
    mov dword [writable_offsets + ebx * 4], 0
    mov byte [writable_status + ebx], 1
    inc ebx
    jmp .loop

.ok:
    clc
    jmp .done

.fail:
    mov byte [writable_status + ebx], 2
    stc

.done:
    pop ebx
    ret

fat_find_persistence_markers:
    push ebx

    xor ebx, ebx

.loop:
    cmp ebx, PERSISTENCE_MARKER_COUNT
    jae .done
    mov edi, [persistence_marker_name_table + ebx * 4]
    push ebx
    call fat_find_file
    pop ebx
    jc .missing
    mov eax, [fat_found_size]
    mov [persistence_marker_sizes + ebx * 4], eax
    mov byte [persistence_marker_status + ebx], 1
    jmp .next

.missing:
    mov dword [persistence_marker_sizes + ebx * 4], 0
    mov byte [persistence_marker_status + ebx], 0

.next:
    inc ebx
    jmp .loop

.done:
    pop ebx
    ret

user_path_equals:
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov esi, eax
    call user_range_validate
    jc .fail
    mov ecx, ebx
    repe cmpsb
    jne .fail
    clc
    jmp .done

.fail:
    stc

.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

fat_parse_user_root83:
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov eax, [syscall_ptr_arg]
    mov ebx, 13
    call user_range_validate
    jc .fail
    mov edi, fat_open_name_buffer
    mov al, ' '
    mov ecx, 11
    cld
    rep stosb
    mov esi, [syscall_ptr_arg]
    xor eax, eax
    mov [fat_open_base_len], al
    mov [fat_open_ext_len], al
    mov [fat_open_dot_seen], al
    mov ecx, 12

.char_loop:
    lodsb
    cmp al, 0
    je .finish
    cmp ecx, 0
    je .fail
    dec ecx
    cmp al, '/'
    je .fail
    cmp al, 0x5c
    je .fail
    cmp al, '.'
    je .dot
    cmp al, 'a'
    jb .validate_char
    cmp al, 'z'
    ja .validate_char
    sub al, 32

.validate_char:
    cmp al, 'A'
    jb .check_digit
    cmp al, 'Z'
    jbe .store_char

.check_digit:
    cmp al, '0'
    jb .check_extra
    cmp al, '9'
    jbe .store_char

.check_extra:
    cmp al, '_'
    je .store_char
    cmp al, '-'
    je .store_char
    jmp .fail

.dot:
    cmp byte [fat_open_base_len], 0
    je .fail
    cmp byte [fat_open_dot_seen], 0
    jne .fail
    mov byte [fat_open_dot_seen], 1
    jmp .char_loop

.store_char:
    cmp byte [fat_open_dot_seen], 0
    jne .store_ext
    movzx edx, byte [fat_open_base_len]
    cmp edx, 8
    jae .fail
    mov [fat_open_name_buffer + edx], al
    inc byte [fat_open_base_len]
    jmp .char_loop

.store_ext:
    movzx edx, byte [fat_open_ext_len]
    cmp edx, 3
    jae .fail
    mov [fat_open_name_buffer + 8 + edx], al
    inc byte [fat_open_ext_len]
    jmp .char_loop

.finish:
    cmp byte [fat_open_base_len], 0
    je .fail
    cmp byte [fat_open_dot_seen], 0
    je .ok
    cmp byte [fat_open_ext_len], 0
    je .fail

.ok:
    clc
    jmp .done

.fail:
    stc

.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

fat_open_name_is_protected:
    push esi
    push edi

    mov esi, fat_open_name_buffer
    mov edi, wad_name_83
    call fat_name_match
    cmp al, 1
    je .protected
    mov esi, fat_open_name_buffer
    mov edi, user_elf_name_83
    call fat_name_match
    cmp al, 1
    je .protected
    mov esi, fat_open_name_buffer
    mov edi, doom_elf_name_83
    call fat_name_match
    cmp al, 1
    je .protected
    clc
    jmp .done

.protected:
    stc

.done:
    pop edi
    pop esi
    ret

fat_open_name_marker_index:
    push ebx
    push esi
    push edi

    xor ebx, ebx

.loop:
    cmp ebx, PERSISTENCE_MARKER_COUNT
    jae .fail
    mov esi, fat_open_name_buffer
    mov edi, [persistence_marker_name_table + ebx * 4]
    call fat_name_match
    cmp al, 1
    je .found
    inc ebx
    jmp .loop

.found:
    mov eax, ebx
    clc
    jmp .done

.fail:
    stc

.done:
    pop edi
    pop esi
    pop ebx
    ret

fat_bind_found_writable_slot:
    push ebx
    push ecx
    push edx

    xor ebx, ebx

.reuse_loop:
    cmp ebx, WRITABLE_FILE_COUNT
    jae .find_free
    cmp byte [writable_status + ebx], 1
    jne .reuse_next
    mov eax, [fat_found_root_lba]
    cmp eax, [writable_root_lbas + ebx * 4]
    jne .reuse_next
    mov eax, [fat_found_root_offset]
    cmp eax, [writable_root_offsets + ebx * 4]
    je .bind

.reuse_next:
    inc ebx
    jmp .reuse_loop

.find_free:
    mov ebx, WRITABLE_KNOWN_FILE_COUNT

.free_loop:
    cmp ebx, WRITABLE_FILE_COUNT
    jae .fail
    cmp byte [writable_status + ebx], 1
    jne .bind
    inc ebx
    jmp .free_loop

.bind:
    mov eax, [fat_found_size]
    cmp eax, [writable_capacity_table + ebx * 4]
    ja .fail
    mov ax, [fat_found_first_cluster]
    mov [writable_first_clusters + ebx * 2], ax
    mov eax, [fat_found_size]
    mov [writable_sizes + ebx * 4], eax
    mov eax, [fat_found_root_lba]
    mov [writable_root_lbas + ebx * 4], eax
    mov eax, [fat_found_root_offset]
    mov [writable_root_offsets + ebx * 4], eax
    mov dword [writable_offsets + ebx * 4], 0
    mov byte [writable_status + ebx], 1
    mov [fat_open_slot], ebx
    clc
    jmp .done

.fail:
    stc

.done:
    pop edx
    pop ecx
    pop ebx
    ret

fat_bind_found_to_writable_slot:
    push ebx

    cmp ebx, WRITABLE_FILE_COUNT
    jae .fail
    mov eax, [fat_found_size]
    cmp eax, [writable_capacity_table + ebx * 4]
    ja .fail
    mov ax, [fat_found_first_cluster]
    mov [writable_first_clusters + ebx * 2], ax
    mov eax, [fat_found_size]
    mov [writable_sizes + ebx * 4], eax
    mov eax, [fat_found_root_lba]
    mov [writable_root_lbas + ebx * 4], eax
    mov eax, [fat_found_root_offset]
    mov [writable_root_offsets + ebx * 4], eax
    mov dword [writable_offsets + ebx * 4], 0
    mov byte [writable_status + ebx], 1
    mov [fat_open_slot], ebx
    clc
    jmp .done

.fail:
    stc

.done:
    pop ebx
    ret

fat_find_writable_slot_for_found:
    push ebx

    xor ebx, ebx

.loop:
    cmp ebx, WRITABLE_FILE_COUNT
    jae .fail
    cmp byte [writable_status + ebx], 1
    jne .next
    mov eax, [fat_found_root_lba]
    cmp eax, [writable_root_lbas + ebx * 4]
    jne .next
    mov eax, [fat_found_root_offset]
    cmp eax, [writable_root_offsets + ebx * 4]
    je .found

.next:
    inc ebx
    jmp .loop

.found:
    mov eax, ebx
    clc
    jmp .done

.fail:
    stc

.done:
    pop ebx
    ret

fat_close_writable_fds_for_slot:
    push eax
    push ebx
    push ecx
    push edx

    mov edx, eax
    mov ecx, USER_FD_COUNT
    xor ebx, ebx

.loop:
    cmp byte [fd_status + ebx], 1
    jne .next
    cmp byte [fd_kinds + ebx], FD_KIND_WRITABLE
    jne .next
    cmp [fd_indices + ebx * 4], edx
    jne .next
    mov byte [fd_status + ebx], FD_KIND_FREE
    mov byte [fd_kinds + ebx], FD_KIND_FREE
    mov dword [fd_indices + ebx * 4], 0
    mov dword [fd_offsets + ebx * 4], 0
    mov dword [fd_flags + ebx * 4], 0
    mov dword [fd_owner_pids + ebx * 4], 0xffffffff
    mov dword [fd_inherit_flags + ebx * 4], 0

.next:
    inc ebx
    loop .loop

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

fat_clear_writable_slot:
    push eax
    push ebx

    mov ebx, eax
    cmp ebx, WRITABLE_FILE_COUNT
    jae .done
    mov byte [writable_status + ebx], 0
    mov word [writable_first_clusters + ebx * 2], 0
    mov dword [writable_sizes + ebx * 4], 0
    mov dword [writable_root_lbas + ebx * 4], 0
    mov dword [writable_root_offsets + ebx * 4], 0
    mov dword [writable_offsets + ebx * 4], 0

.done:
    pop ebx
    pop eax
    ret

fd_reset_all:
    push ebx
    push ecx

    mov ecx, USER_FD_COUNT
    xor ebx, ebx

.loop:
    mov byte [fd_status + ebx], FD_KIND_FREE
    mov byte [fd_kinds + ebx], FD_KIND_FREE
    mov dword [fd_indices + ebx * 4], 0
    mov dword [fd_offsets + ebx * 4], 0
    mov dword [fd_flags + ebx * 4], 0
    mov dword [fd_owner_pids + ebx * 4], 0xffffffff
    mov dword [fd_inherit_flags + ebx * 4], 0
    inc ebx
    loop .loop

    pop ecx
    pop ebx
    ret

fd_alloc:
    push ebx

    xor ebx, ebx

.loop:
    cmp ebx, USER_FD_COUNT
    jae .fail
    cmp byte [fd_status + ebx], FD_KIND_FREE
    je .found
    inc ebx
    jmp .loop

.found:
    mov byte [fd_status + ebx], 1
    mov eax, [current_pid]
    mov [fd_owner_pids + ebx * 4], eax
    inc dword [fd_open_generations + ebx * 4]
    test dword [syscall_open_flags], O_CLOEXEC
    jnz .no_exec_inherit
    mov dword [fd_inherit_flags + ebx * 4], FD_INHERIT_EXEC
    jmp .inherit_done

.no_exec_inherit:
    mov dword [fd_inherit_flags + ebx * 4], 0

.inherit_done:
    mov eax, ebx
    clc
    jmp .done

.fail:
    stc

.done:
    pop ebx
    ret

fd_lookup:
    mov eax, ebx
    sub eax, USER_FD_BASE
    cmp eax, USER_FD_COUNT
    jae .fail
    cmp byte [fd_status + eax], 1
    jne .fail
    push edx
    mov edx, [current_pid]
    cmp [fd_owner_pids + eax * 4], edx
    pop edx
    jne .fail
    mov [file_io_fd_slot], eax
    clc
    ret

.fail:
    stc
    ret

fd_clear_slot:
    mov byte [fd_status + ebx], FD_KIND_FREE
    mov byte [fd_kinds + ebx], FD_KIND_FREE
    mov dword [fd_indices + ebx * 4], 0
    mov dword [fd_offsets + ebx * 4], 0
    mov dword [fd_flags + ebx * 4], 0
    mov dword [fd_owner_pids + ebx * 4], 0xffffffff
    mov dword [fd_inherit_flags + ebx * 4], 0
    ret

fd_close_owned_by_pid:
    push ebx
    push ecx
    push edx

    mov edx, eax
    mov [fd_last_closed_owner_pid], edx
    mov ecx, USER_FD_COUNT
    xor ebx, ebx

.loop:
    cmp byte [fd_status + ebx], 1
    jne .next
    cmp [fd_owner_pids + ebx * 4], edx
    jne .next
    call fd_clear_slot
    inc dword [fd_owner_closes]

.next:
    inc ebx
    loop .loop

    pop edx
    pop ecx
    pop ebx
    ret

fd_close_owned_by_process:
    push eax
    cmp esi, 0
    je .done
    cmp esi, process_kernel
    je .done
    mov eax, [esi + PROC_PID]
    call fd_close_owned_by_pid

.done:
    pop eax
    ret

fd_exec_handoff:
    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov [fd_last_exec_from_pid], eax
    mov [fd_last_exec_to_pid], edx
    inc dword [fd_exec_handoffs]
    mov esi, eax
    mov ecx, USER_FD_COUNT
    xor ebx, ebx

.loop:
    cmp byte [fd_status + ebx], 1
    jne .next
    cmp [fd_owner_pids + ebx * 4], esi
    jne .next
    test dword [fd_inherit_flags + ebx * 4], FD_INHERIT_EXEC
    jz .close_on_exec
    mov [fd_owner_pids + ebx * 4], edx
    inc dword [fd_exec_inherited]
    jmp .next

.close_on_exec:
    call fd_clear_slot
    inc dword [fd_exec_closed]

.next:
    inc ebx
    loop .loop

    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

writable_fd_index:
    call fd_lookup
    jc .fail
    cmp byte [fd_kinds + eax], FD_KIND_WRITABLE
    jne .fail
    mov ebx, [fd_indices + eax * 4]
    cmp ebx, WRITABLE_FILE_COUNT
    jae .fail
    cmp byte [writable_status + ebx], 1
    jne .fail
    mov [file_io_index], ebx
    clc
    ret

.fail:
    stc
    ret

fat_file_lba_for_offset:
    push ecx
    push edx

    mov ebx, edx
    and ebx, 511
    shr edx, 9
    mov [fat_current_cluster], ax

.cluster_loop:
    movzx ecx, byte [fat_sectors_per_cluster]
    cmp edx, ecx
    jb .have_cluster
    sub edx, ecx
    movzx eax, word [fat_current_cluster]
    call fat_next_cluster
    jc .fail
    cmp eax, 2
    jb .fail
    cmp eax, 0xfff8
    jae .fail
    mov [fat_current_cluster], ax
    jmp .cluster_loop

.have_cluster:
    mov ecx, edx
    movzx eax, word [fat_current_cluster]
    cmp eax, 2
    jb .fail
    cmp eax, 0xfff8
    jae .fail
    sub eax, 2
    movzx edx, byte [fat_sectors_per_cluster]
    mul edx
    add eax, [fat_data_lba]
    add eax, ecx
    clc
    jmp .done

.fail:
    stc

.done:
    pop edx
    pop ecx
    ret

fat_file_lba_for_write:
    push ecx
    push edx
    push esi

    mov dword [fat_file_lba_was_new_cluster], 0
    mov esi, ebx
    mov ebx, edx
    and ebx, 511
    shr edx, 9
    mov ax, [writable_first_clusters + esi * 2]
    cmp ax, 2
    jae .have_first_cluster
    call fat_alloc_cluster
    jc .fail
    mov [writable_first_clusters + esi * 2], ax
    mov dword [fat_file_lba_was_new_cluster], 1

.have_first_cluster:
    mov [fat_current_cluster], ax

.cluster_loop:
    movzx ecx, byte [fat_sectors_per_cluster]
    cmp edx, ecx
    jb .have_cluster
    sub edx, ecx
    movzx eax, word [fat_current_cluster]
    call fat_next_cluster
    jc .fail
    cmp eax, 0
    je .allocate_next_cluster
    cmp eax, 0xfff8
    jb .next_exists

.allocate_next_cluster:
    call fat_alloc_cluster
    jc .fail
    mov [fat_new_cluster], ax
    mov dword [fat_file_lba_was_new_cluster], 1
	    movzx eax, word [fat_current_cluster]
	    mov dx, [fat_new_cluster]
	    call fat_write_cluster_entry
	    jnc .linked_new_cluster
	    movzx eax, word [fat_new_cluster]
	    xor edx, edx
	    call fat_write_cluster_entry
	    jmp .fail

	.linked_new_cluster:
	    mov ax, [fat_new_cluster]

	.next_exists:
    cmp eax, 2
    jb .fail
    cmp eax, 0xfff8
    jae .fail
    mov [fat_current_cluster], ax
    jmp .cluster_loop

.have_cluster:
    mov ecx, edx
    movzx eax, word [fat_current_cluster]
    cmp eax, 2
    jb .fail
    cmp eax, 0xfff8
    jae .fail
    sub eax, 2
    movzx edx, byte [fat_sectors_per_cluster]
    mul edx
    add eax, [fat_data_lba]
    add eax, ecx
    clc
    jmp .done

.fail:
    stc
    jmp .done

.done:
    pop esi
    pop edx
    pop ecx
    ret

fat_update_writable_size:
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov ebx, eax
    mov eax, [writable_root_lbas + ebx * 4]
    sub eax, [fat_root_lba]
    cmp eax, [fat_root_sectors]
    jae .fail
    mov esi, eax
    shl esi, 9
    add esi, fat_root_cache
    mov edx, [writable_root_offsets + ebx * 4]
    mov ax, [writable_first_clusters + ebx * 2]
    mov [esi + edx + 26], ax
    mov ecx, [writable_sizes + ebx * 4]
    mov [esi + edx + 28], ecx
    mov eax, [writable_root_lbas + ebx * 4]
    call ata_write_sector
    jc .fail
    clc
    jmp .done

.fail:
    stc

.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

fat_truncate_writable_file:
    push ebx

    mov ebx, eax
    mov ax, [writable_first_clusters + ebx * 2]
    cmp ax, 2
    jb .clear_root
    call fat_free_chain
    jc .fail

.clear_root:
    mov word [writable_first_clusters + ebx * 2], 0
    mov dword [writable_sizes + ebx * 4], 0
    mov dword [writable_offsets + ebx * 4], 0
    mov eax, ebx
    call fat_update_writable_size
    jc .fail
    clc
    jmp .done

.fail:
    stc

.done:
    pop ebx
    ret

fat_delete_found_file:
    push eax
    push edx
    push esi
    push edi

    mov ax, [fat_found_first_cluster]
    cmp ax, 2
    jb .clear_root_entry
    call fat_free_chain
    jc .fail

.clear_root_entry:
    mov eax, [fat_found_root_lba]
    sub eax, [fat_root_lba]
    cmp eax, [fat_root_sectors]
    jae .fail
    mov esi, eax
    shl esi, 9
    add esi, fat_root_cache
    mov edx, [fat_found_root_offset]
    mov byte [esi + edx], 0xe5
    mov word [esi + edx + 26], 0
    mov dword [esi + edx + 28], 0
    mov eax, [fat_found_root_lba]
    call ata_write_sector
    jc .fail
    clc
    jmp .done

.fail:
    stc

.done:
    pop edi
    pop esi
    pop edx
    pop eax
    ret

stat_fill_user:
    push eax
    push ebx
    push ecx
    push edx
    push edi

    mov [stat_size_arg], eax
    mov [stat_mode_arg], edx
    mov eax, [syscall_stat_ptr]
    mov ebx, STAT_BYTES
    call user_range_validate
    jc .fail
    mov edi, [syscall_stat_ptr]
    xor eax, eax
    mov ecx, STAT_BYTES / 4
    cld
    rep stosd
    mov edi, [syscall_stat_ptr]
    mov eax, [stat_mode_arg]
    mov [edi + STAT_ST_MODE], eax
    mov dword [edi + STAT_ST_NLINK], 1
    mov eax, [stat_size_arg]
    mov [edi + STAT_ST_SIZE], eax
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

user_file_read:
    call writable_fd_index
    jc .fail_badfd
    mov esi, [file_io_fd_slot]
    mov eax, [fd_flags + esi * 4]
    and eax, O_ACCMODE
    cmp eax, O_WRONLY
    je .fail_badfd
    mov [file_io_user_ptr], ecx
    mov [file_io_remaining], edx
    mov dword [file_io_done], 0
    mov eax, ecx
    mov ebx, edx
    call user_range_validate
    jc .fail_inval
    mov ebx, [file_io_index]
    mov eax, [writable_sizes + ebx * 4]
    mov esi, [file_io_fd_slot]
    cmp [fd_offsets + esi * 4], eax
    jb .have_readable_bytes
    mov dword [file_io_remaining], 0
    jmp .loop

.have_readable_bytes:
    sub eax, [fd_offsets + esi * 4]
    cmp [file_io_remaining], eax
    jbe .loop
    mov [file_io_remaining], eax

.loop:
    cmp dword [file_io_remaining], 0
    je .ok
    mov ebx, [file_io_index]
    mov esi, [file_io_fd_slot]
    mov edx, [fd_offsets + esi * 4]
    mov ax, [writable_first_clusters + ebx * 2]
    call fat_file_lba_for_offset
    jc .fail_io
    mov [file_io_sector_offset], ebx
    mov edi, SECTOR_BUFFER_ADDR
    call ata_read_sector
    jc .fail_io
    mov eax, 512
    sub eax, [file_io_sector_offset]
    cmp eax, [file_io_remaining]
    jbe .chunk_ok
    mov eax, [file_io_remaining]

.chunk_ok:
    mov [file_io_chunk], eax
    mov esi, SECTOR_BUFFER_ADDR
    add esi, [file_io_sector_offset]
    mov edi, [file_io_user_ptr]
    add edi, [file_io_done]
    mov ecx, [file_io_chunk]
    cld
    rep movsb
    mov eax, [file_io_chunk]
    add [file_io_done], eax
    sub [file_io_remaining], eax
    mov esi, [file_io_fd_slot]
    add [fd_offsets + esi * 4], eax
    jmp .loop

.ok:
    mov eax, [file_io_done]
    clc
    ret

.fail_badfd:
    mov eax, -ERRNO_EBADF
    stc
    ret

.fail_inval:
    mov eax, -ERRNO_EINVAL
    stc
    ret

.fail_io:
    mov eax, -ERRNO_EIO
    stc
    ret

user_file_write:
    mov dword [file_write_debug_stage], 1
    mov dword [file_write_debug_result], 0
    mov dword [file_write_debug_capacity], 0
    call writable_fd_index
    jc .fail_badfd
    mov esi, [file_io_fd_slot]
    mov eax, [fd_flags + esi * 4]
    and eax, O_ACCMODE
    cmp eax, O_WRONLY
    je .write_mode_ok
    cmp eax, O_RDWR
    jne .fail_badfd

.write_mode_ok:
    mov dword [file_write_debug_stage], 2
    test dword [fd_flags + esi * 4], O_APPEND
    jz .write_offset_ready
    mov ebx, [file_io_index]
    mov eax, [writable_sizes + ebx * 4]
    mov [fd_offsets + esi * 4], eax

.write_offset_ready:
    mov dword [file_write_debug_stage], 3
    mov [file_io_user_ptr], ecx
    mov [file_io_remaining], edx
    mov [file_write_requested], edx
    mov dword [file_io_done], 0
    mov dword [file_write_fail_stage], 0
    mov eax, ecx
    mov ebx, edx
    call user_range_validate
    jc .fail_inval_range
    mov dword [file_write_debug_stage], 4
    mov ebx, [file_io_index]
    mov esi, [file_io_fd_slot]
    mov eax, [writable_capacity_table + ebx * 4]
    mov [file_write_capacity], eax
    sub eax, [fd_offsets + esi * 4]
    mov [file_write_debug_capacity], eax
    cmp [file_io_remaining], eax
    jbe .loop
    mov [file_io_remaining], eax

.loop:
    cmp dword [file_io_remaining], 0
    je .ok
    mov ebx, [file_io_index]
    mov esi, [file_io_fd_slot]
    mov edx, [fd_offsets + esi * 4]
    mov dword [fat_alloc_zero_policy], 1
    cmp edx, [writable_sizes + ebx * 4]
    ja .allocation_policy_ready
    mov eax, edx
    and eax, 511
    cmp eax, 0
    jne .allocation_policy_ready
    cmp dword [file_io_remaining], 512
    jb .allocation_policy_ready
    mov dword [fat_alloc_zero_policy], 0

.allocation_policy_ready:
    mov dword [file_write_debug_stage], 5
    mov dword [file_write_fail_stage], 4
    call fat_file_lba_for_write
    mov dword [fat_alloc_zero_policy], 1
    jc .fail_io
    mov [file_io_sector_lba], eax
    mov [file_io_sector_offset], ebx
    mov eax, 512
    sub eax, [file_io_sector_offset]
    cmp eax, [file_io_remaining]
    jbe .chunk_ok
    mov eax, [file_io_remaining]

.chunk_ok:
    mov [file_io_chunk], eax
    cmp dword [file_io_sector_offset], 0
    jne .prepare_partial_sector
    cmp dword [file_io_chunk], 512
    jne .prepare_partial_sector
    mov dword [file_write_debug_stage], 6
    mov eax, [file_io_sector_lba]
    mov esi, [file_io_user_ptr]
    add esi, [file_io_done]
    mov dword [file_write_fail_stage], 5
    call ata_write_sector
    jc .fail_io
    jmp .after_sector_write

.prepare_partial_sector:
    cmp dword [fat_file_lba_was_new_cluster], 1
    je .zero_sector_buffer
    mov dword [file_write_debug_stage], 7
    mov eax, [file_io_sector_lba]
    mov edi, SECTOR_BUFFER_ADDR
    mov dword [file_write_fail_stage], 6
    call ata_read_sector
    jc .fail_io
    jmp .copy_partial_sector

.zero_sector_buffer:
    mov edi, SECTOR_BUFFER_ADDR
    xor eax, eax
    mov ecx, 512 / 4
    cld
    rep stosd

.copy_partial_sector:
    mov esi, [file_io_user_ptr]
    add esi, [file_io_done]
    mov edi, SECTOR_BUFFER_ADDR
    add edi, [file_io_sector_offset]
    mov ecx, [file_io_chunk]
    cld
    rep movsb
    mov dword [file_write_debug_stage], 8
    mov eax, [file_io_sector_lba]
    mov esi, SECTOR_BUFFER_ADDR
    mov dword [file_write_fail_stage], 7
    call ata_write_sector
    jc .fail_io

.after_sector_write:
    mov dword [file_write_fail_stage], 0
    mov eax, [file_io_chunk]
    add [file_io_done], eax
    sub [file_io_remaining], eax
    mov esi, [file_io_fd_slot]
    add [fd_offsets + esi * 4], eax
    mov edx, [fd_offsets + esi * 4]
    mov ebx, [file_io_index]
    cmp edx, [writable_sizes + ebx * 4]
    jbe .loop
    mov [writable_sizes + ebx * 4], edx
    jmp .loop

.ok:
    mov dword [file_write_debug_stage], 9
    cmp dword [file_write_requested], 0
    je .update_size
    cmp dword [file_io_done], 0
    jne .update_size
    mov dword [file_write_fail_stage], 3

.update_size:
    mov eax, [file_io_index]
    cmp dword [file_write_fail_stage], 3
    je .skip_update_stage
    mov dword [file_write_fail_stage], 8

.skip_update_stage:
    call fat_update_writable_size
    jc .fail_io
    cmp dword [file_write_fail_stage], 3
    je .return_done
    mov dword [file_write_fail_stage], 0

.return_done:
    mov eax, [file_io_done]
    mov dword [file_write_debug_stage], 0x0a
    mov [file_write_debug_result], eax
    clc
    ret

.fail_badfd:
    mov dword [file_write_fail_stage], 1
    mov eax, -ERRNO_EBADF
    mov dword [file_write_debug_stage], 0xe1
    mov [file_write_debug_result], eax
    stc
    ret

.fail_inval_range:
    mov dword [file_write_fail_stage], 2

.fail_inval:
    mov eax, -ERRNO_EINVAL
    mov dword [file_write_debug_stage], 0xe2
    mov [file_write_debug_result], eax
    stc
    ret

.fail_io:
    mov eax, -ERRNO_EIO
    mov [file_write_debug_result], eax
    stc
    ret

user_file_lseek:
    call writable_fd_index
    jc .fail_badfd
    mov ebx, [file_io_index]
    mov esi, [file_io_fd_slot]
    cmp edx, 0
    je .seek_set
    cmp edx, 1
    je .seek_cur
    cmp edx, 2
    je .seek_end
    jmp .fail_inval

.seek_set:
    mov eax, ecx
    jmp .seek_validate

.seek_cur:
    mov eax, [fd_offsets + esi * 4]
    add eax, ecx
    jc .fail_inval
    jmp .seek_validate

.seek_end:
    mov eax, [writable_sizes + ebx * 4]
    add eax, ecx
    jc .fail_inval

.seek_validate:
    cmp eax, [writable_capacity_table + ebx * 4]
    ja .fail_inval
    mov [fd_offsets + esi * 4], eax
    clc
    ret

.fail_badfd:
    mov eax, -ERRNO_EBADF
    stc
    ret

.fail_inval:
    mov eax, -ERRNO_EINVAL
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

    mov edi, idt_start + (0 * 8)
    mov eax, exception_divide_error
    mov bl, 10001110b
    call idt_set_gate_attr

    mov edi, idt_start + (6 * 8)
    mov eax, exception_invalid_opcode
    mov bl, 10001110b
    call idt_set_gate_attr

    mov edi, idt_start + (12 * 8)
    mov eax, exception_stack_fault
    mov bl, 10001110b
    call idt_set_gate_attr

    mov edi, idt_start + (13 * 8)
    mov eax, exception_general_protection
    mov bl, 10001110b
    call idt_set_gate_attr

    mov edi, idt_start + (14 * 8)
    mov eax, page_fault_handler
    mov bl, 10001110b
    call idt_set_gate_attr

    mov edi, idt_start + (32 * 8)
    mov eax, irq_timer
    call idt_set_gate

    mov eax, irq_keyboard
    call idt_set_gate

    mov eax, irq_ignore_master
    mov ecx, 3

.master_irqs:
    call idt_set_gate
    loop .master_irqs

    mov eax, irq_audio
    call idt_set_gate

    mov eax, irq_ignore_master
    mov ecx, 2

.master_irqs_after_audio:
    call idt_set_gate
    loop .master_irqs_after_audio

    mov eax, irq_ignore_slave
    mov ecx, 8

.slave_irqs:
    call idt_set_gate
    loop .slave_irqs

    mov edi, idt_start + (44 * 8)
    mov eax, irq_mouse
    call idt_set_gate

    mov edi, idt_start + (48 * 8)
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

scheduler_init:
    mov dword [scheduler_tick_count], 0
    mov dword [scheduler_round_count], 0
    mov dword [scheduler_context_switches], 0
    mov dword [scheduler_rr_cursor], 0
    mov dword [scheduler_next_pid], 0xffffffff
    mov dword [scheduler_next_process_ptr], 0
    mov dword [scheduler_preempt_attempts], 0
    mov dword [scheduler_preempt_switches], 0
    mov dword [scheduler_irq_context_switches], 0
    mov dword [scheduler_preempt_skips], 0
    mov dword [scheduler_user_irq_ticks], 0
    mov dword [scheduler_last_preempt_from_pid], 0xffffffff
    mov dword [scheduler_last_preempt_to_pid], 0xffffffff
    mov dword [scheduler_last_preempt_from_kind], 0
    mov dword [scheduler_last_preempt_to_kind], 0
    mov dword [scheduler_last_preempt_from_eip], 0
    mov dword [scheduler_last_preempt_to_eip], 0
    mov dword [scheduler_last_preempt_from_cr3], 0
    mov dword [scheduler_last_preempt_to_cr3], 0
    mov dword [scheduler_last_preempt_from_kstack], 0
    mov dword [scheduler_last_preempt_to_kstack], 0
    mov dword [scheduler_preempt_probe_ready], 0
    mov dword [scheduler_preempt_spin_value], 0
    mov byte [scheduler_preempt_selftest_status], 0
    mov dword [current_process_ptr], 0
    mov dword [current_pid], 0
    mov dword [process_next_pid], 4
    mov dword [process_slot_reuses], 0
    mov dword [process_vm_teardowns], 0
    mov dword [process_vm_pages_cleared], 0
    mov dword [process_mmap_allocations], 0
    mov dword [process_mmap_pages_mapped], 0
    mov dword [process_munmap_attempts], 0
    mov dword [process_munmap_pages_released], 0
    mov dword [process_munmap_non_tail_kept], 0
    mov dword [process_munmap_holes_punched], 0
    mov dword [process_munmap_pages_unmapped], 0
    mov dword [process_last_munmap_base], 0
    mov dword [process_last_munmap_end], 0
    mov dword [process_exit_teardowns], 0
    mov dword [process_exec_teardowns], 0
    mov dword [process_last_reused_slot], 0
    mov dword [process_last_reused_pid], 0xffffffff
    mov dword [process_last_slot_generation], 0
    mov dword [process_last_teardown_pid], 0xffffffff
    mov dword [process_last_teardown_base], 0
    mov dword [process_last_teardown_end], 0
    mov dword [process_generic_slot_allocations], 0
    mov dword [process_generic_slot_failures], 0
    mov dword [process_last_generic_slot], 0
    mov dword [process_wait_attempts], 0
    mov dword [process_wait_reaps], 0
    mov dword [process_wait_failures], 0
    mov dword [process_wait_last_pid_arg], 0
    mov dword [process_wait_last_status_ptr], 0
    mov dword [process_wait_last_options], 0
    mov dword [process_wait_last_reaped_pid], 0xffffffff
    mov dword [process_wait_last_status], 0
    mov dword [process_wait_seen_live_child], 0
    mov dword [process_wait_nohang_returns], 0
    mov dword [process_wait_seeded_children], 0
    mov dword [process_wait_seeded_child_pid], 0xffffffff
    mov dword [fd_exec_handoffs], 0
    mov dword [fd_exec_inherited], 0
    mov dword [fd_exec_closed], 0
    mov dword [fd_owner_closes], 0
    mov dword [fd_last_exec_from_pid], 0xffffffff
    mov dword [fd_last_exec_to_pid], 0xffffffff
    mov dword [fd_last_closed_owner_pid], 0xffffffff

    mov esi, process_kernel
    call process_reset_accounting
    mov dword [process_kernel + PROC_STATE], PROC_STATE_READY
    mov esi, process_user_probe
    call process_reset_user_probe
    mov esi, process_preempt_probe
    call process_reset_preempt_probe
    mov esi, process_doom
    call process_reset_doom
    mov esi, process_generic0
    call process_reset_generic_unused
    mov esi, process_generic1
    call process_reset_generic_unused
    mov esi, process_kernel
    call process_activate
    ret

process_reset_user_probe:
    call process_reset_accounting
    mov dword [esi + PROC_STATE], PROC_STATE_READY
    mov dword [esi + PROC_BRK], USER_HEAP_START
    mov dword [esi + PROC_ENTRY], 0
    ret

process_reset_preempt_probe:
    call process_reset_accounting
    mov dword [esi + PROC_STATE], PROC_STATE_READY
    mov dword [esi + PROC_BRK], USER_HEAP_START
    mov dword [esi + PROC_ENTRY], 0
    ret

process_seed_wait_reap_probe_child:
    push eax
    push esi
    mov esi, process_preempt_probe
    call process_reset_preempt_probe
    mov eax, [current_pid]
    mov [esi + PROC_PARENT_PID], eax
    mov dword [esi + PROC_EXIT_STATUS], WAIT_PROOF_EXIT_STATUS
    mov dword [esi + PROC_STATE], PROC_STATE_EXITED
    mov eax, [esi + PROC_PID]
    mov [process_wait_seeded_child_pid], eax
    inc dword [process_wait_seeded_children]
    pop esi
    pop eax
    ret

process_reset_doom:
    call process_reset_accounting
    mov dword [esi + PROC_STATE], PROC_STATE_READY
    mov dword [esi + PROC_BRK], DOOM_USER_HEAP_START
    mov dword [esi + PROC_ENTRY], 0
    ret

process_reset_generic_unused:
    call process_reset_accounting
    mov dword [esi + PROC_STATE], PROC_STATE_UNUSED
    mov dword [esi + PROC_BRK], USER_HEAP_START
    mov dword [esi + PROC_ENTRY], 0
    ret

process_reset_accounting:
    push eax
    push ecx
    push edi
    call process_heap_clear_all
    mov dword [esi + PROC_TICKS], 0
    mov dword [esi + PROC_RUNS], 0
    mov dword [esi + PROC_QUANTUM_TICKS], 0
    mov dword [esi + PROC_SWITCHES], 0
    and dword [esi + PROC_VM_FLAGS], 0xfffffffe
    mov dword [esi + PROC_PARENT_PID], 0xffffffff
    mov dword [esi + PROC_EXIT_STATUS], 0
    mov dword [esi + PROC_EXEC_COUNT], 0
    mov dword [esi + PROC_ARGC], 0
    mov dword [esi + PROC_ARGV], 0
    mov dword [esi + PROC_ENVP], 0
    mov dword [esi + PROC_ARGV0], 0
    lea edi, [esi + PROC_SAVED_EAX]
    xor eax, eax
    mov ecx, 12
    rep stosd
    pop edi
    pop ecx
    pop eax
    ret

process_heap_clear_all:
    push eax
    push ecx
    push edi
    mov edi, [esi + PROC_HEAP_BITMAP]
    test edi, edi
    jz .done
    mov ecx, [esi + PROC_HEAP_PAGE_COUNT]
    add ecx, 7
    shr ecx, 3
    test ecx, ecx
    jz .done
    xor eax, eax
    cld
    rep stosb

.done:
    pop edi
    pop ecx
    pop eax
    ret

process_heap_mark_range:
    pushad
    cmp esi, 0
    je .done
    mov edi, [esi + PROC_HEAP_BITMAP]
    test edi, edi
    jz .done
    mov ebx, eax
    cmp ebx, [esi + PROC_HEAP_START]
    jae .base_ready
    mov ebx, [esi + PROC_HEAP_START]

.base_ready:
    mov ecx, edx
    cmp ecx, [esi + PROC_HEAP_END]
    jbe .end_ready
    mov ecx, [esi + PROC_HEAP_END]

.end_ready:
    cmp ebx, ecx
    jae .done
    sub ebx, [esi + PROC_HEAP_START]
    shr ebx, 12
    sub ecx, [esi + PROC_HEAP_START]
    add ecx, PAGE_SIZE - 1
    shr ecx, 12
    cmp ecx, [esi + PROC_HEAP_PAGE_COUNT]
    jbe .count_ready
    mov ecx, [esi + PROC_HEAP_PAGE_COUNT]

.count_ready:
    mov ebp, ecx
    cmp ebx, ebp
    jae .done

.mark_next:
    mov edx, ebx
    shr edx, 3
    mov al, 1
    mov ecx, ebx
    and ecx, 7
    shl al, cl
    or byte [edi + edx], al
    inc ebx
    cmp ebx, ebp
    jb .mark_next

.done:
    popad
    ret

process_heap_clear_range:
    pushad
    cmp esi, 0
    je .done
    mov edi, [esi + PROC_HEAP_BITMAP]
    test edi, edi
    jz .done
    mov ebx, eax
    cmp ebx, [esi + PROC_HEAP_START]
    jae .base_ready
    mov ebx, [esi + PROC_HEAP_START]

.base_ready:
    mov ecx, edx
    cmp ecx, [esi + PROC_HEAP_END]
    jbe .end_ready
    mov ecx, [esi + PROC_HEAP_END]

.end_ready:
    cmp ebx, ecx
    jae .done
    sub ebx, [esi + PROC_HEAP_START]
    shr ebx, 12
    sub ecx, [esi + PROC_HEAP_START]
    add ecx, PAGE_SIZE - 1
    shr ecx, 12
    cmp ecx, [esi + PROC_HEAP_PAGE_COUNT]
    jbe .count_ready
    mov ecx, [esi + PROC_HEAP_PAGE_COUNT]

.count_ready:
    mov ebp, ecx
    cmp ebx, ebp
    jae .done

.clear_next:
    mov edx, ebx
    shr edx, 3
    mov al, 1
    mov ecx, ebx
    and ecx, 7
    shl al, cl
    not al
    and byte [edi + edx], al
    inc ebx
    cmp ebx, ebp
    jb .clear_next

.done:
    popad
    ret

process_heap_range_is_mapped:
    push ebx
    push ecx
    push edx
    push edi
    cmp esi, 0
    je .fail
    mov edi, [esi + PROC_HEAP_BITMAP]
    test edi, edi
    jz .fail
    cmp eax, [esi + PROC_HEAP_START]
    jb .fail
    cmp edx, [esi + PROC_BRK]
    ja .fail
    mov ebx, eax
    sub ebx, [esi + PROC_HEAP_START]
    shr ebx, 12
    mov ecx, edx
    sub ecx, [esi + PROC_HEAP_START]
    add ecx, PAGE_SIZE - 1
    shr ecx, 12
    cmp ecx, [esi + PROC_HEAP_PAGE_COUNT]
    ja .fail
    mov edx, ecx
    cmp ebx, edx
    jae .ok

.check_next:
    mov ecx, ebx
    shr ecx, 3
    mov al, 1
    push ecx
    mov ecx, ebx
    and ecx, 7
    shl al, cl
    pop ecx
    test byte [edi + ecx], al
    jz .fail
    inc ebx
    cmp ebx, edx
    jb .check_next

.ok:
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

process_clear_user_range:
    push eax
    push edx

.next:
    cmp eax, edx
    jae .done
    call vmm_clear_process_page
    push edx
    mov edx, eax
    add edx, PAGE_SIZE
    call process_heap_clear_range
    pop edx
    inc dword [process_vm_pages_cleared]
    add eax, PAGE_SIZE
    jmp .next

.done:
    pop edx
    pop eax
    ret

process_teardown_user_vm:
    pushad
    cmp esi, 0
    je .done
    cmp esi, process_kernel
    je .done
    mov eax, [esi + PROC_PID]
    mov [process_last_teardown_pid], eax
    mov eax, [esi + PROC_BASE]
    mov [process_last_teardown_base], eax
    mov eax, [esi + PROC_END]
    mov [process_last_teardown_end], eax
    inc dword [process_vm_teardowns]
    mov ebx, [esi + PROC_PAGE_DIR]
    cmp ebx, 0
    je .reset_metadata
    mov edi, [esi + PROC_VM_REGIONS]
    mov ecx, [esi + PROC_VM_REGION_COUNT]

.region_next:
    cmp ecx, 0
    je .reset_metadata
    test dword [edi + VM_REGION_FLAGS], VM_REGION_USER
    jz .region_advance
    mov eax, [edi + VM_REGION_BASE]
    mov edx, [edi + VM_REGION_END]
    call process_clear_user_range

.region_advance:
    add edi, VM_REGION_BYTES
    dec ecx
    jmp .region_next

.reset_metadata:
    mov eax, [esi + PROC_HEAP_START]
    mov [esi + PROC_BRK], eax
    and dword [esi + PROC_VM_FLAGS], 0xfffffffe

.done:
    popad
    ret

process_restore_user_stack_vm:
    push eax
    push ebx
    push edx
    cmp esi, 0
    je .done
    cmp esi, process_kernel
    je .done
    mov ebx, [esi + PROC_PAGE_DIR]
    cmp ebx, 0
    je .done
    mov eax, [esi + PROC_STACK_BOTTOM]
    mov edx, [esi + PROC_STACK_TOP]
    call vmm_mark_process_user_write_range

.done:
    pop edx
    pop ebx
    pop eax
    ret

process_reuse_exec_target_slot:
    push eax
    cmp esi, 0
    je .done
    cmp esi, process_kernel
    je .done
    call fd_close_owned_by_process
    call process_teardown_user_vm
    call process_restore_user_stack_vm
    inc dword [process_slot_reuses]
    mov [process_last_reused_slot], esi
    mov eax, [process_next_pid]
    mov [esi + PROC_PID], eax
    mov [process_last_reused_pid], eax
    inc eax
    cmp eax, 0
    jne .pid_ready
    mov eax, 4

.pid_ready:
    mov [process_next_pid], eax
    mov dword [esi + PROC_PARENT_PID], 0xffffffff
    mov dword [esi + PROC_EXIT_STATUS], 0
    mov dword [esi + PROC_EXEC_COUNT], 0
    mov dword [esi + PROC_ARGC], 0
    mov dword [esi + PROC_ARGV], 0
    mov dword [esi + PROC_ENVP], 0
    mov dword [esi + PROC_ARGV0], 0
    inc dword [esi + PROC_SLOT_GENERATION]
    mov eax, [esi + PROC_SLOT_GENERATION]
    mov [process_last_slot_generation], eax
    mov dword [esi + PROC_STATE], PROC_STATE_UNUSED

.done:
    pop eax
    ret

process_is_user_exec_target:
    cmp eax, process_user_probe
    je .yes
    cmp eax, process_generic0
    je .yes
    cmp eax, process_generic1
    je .yes
    stc
    ret

.yes:
    clc
    ret

process_alloc_generic_exec_slot:
    push eax
    push ecx
    push edi
    mov edi, process_generic_exec_slots
    mov ecx, PROCESS_GENERIC_SLOT_COUNT

.scan_next:
    cmp ecx, 0
    je .none
    mov esi, [edi]
    cmp dword [esi + PROC_STATE], PROC_STATE_UNUSED
    je .found
    cmp dword [esi + PROC_PARENT_PID], 0xffffffff
    jne .advance
    cmp dword [esi + PROC_STATE], PROC_STATE_EXITED
    je .found
    cmp dword [esi + PROC_STATE], PROC_STATE_FAULTED
    je .found

.advance:
    add edi, 4
    dec ecx
    jmp .scan_next

.found:
    mov [process_last_generic_slot], esi
    inc dword [process_generic_slot_allocations]
    clc
    jmp .done

.none:
    inc dword [process_generic_slot_failures]
    mov dword [process_exec_last_error], -ERRNO_ENOMEM
    stc

.done:
    pop edi
    pop ecx
    pop eax
    ret

process_retire_exec_slot:
    cmp esi, 0
    je .done
    cmp esi, process_kernel
    je .done
    call fd_close_owned_by_process
    call process_teardown_user_vm
    inc dword [process_exec_teardowns]
    mov dword [esi + PROC_STATE], PROC_STATE_EXITED
    and dword [esi + PROC_VM_FLAGS], 0xfffffffe

.done:
    ret

process_retire_current_exit_slot:
    cmp esi, 0
    je .done
    cmp esi, process_kernel
    je .done
    call fd_close_owned_by_process
    call process_teardown_user_vm
    inc dword [process_exit_teardowns]
    mov dword [esi + PROC_STATE], PROC_STATE_EXITED
    and dword [esi + PROC_VM_FLAGS], 0xfffffffe

.done:
    ret

clear_fault_record:
    push eax
    push ecx
    push edi
    mov edi, fault_vector
    xor eax, eax
    mov ecx, 12
    cld
    rep stosd
    pop edi
    pop ecx
    pop eax
    ret

process_seed_initial_user_context:
    push eax
    push ecx
    push edi
    lea edi, [esi + PROC_SAVED_EAX]
    xor eax, eax
    mov ecx, 12
    cld
    rep stosd
    mov eax, [esi + PROC_ENTRY]
    mov [esi + PROC_SAVED_EIP], eax
    mov eax, [esi + PROC_STACK_TOP]
    mov [esi + PROC_SAVED_ESP], eax
    mov dword [esi + PROC_SAVED_EFLAGS], 0x00000202
    mov dword [esi + PROC_SAVED_CS], USER_CODE_SEG
    mov dword [esi + PROC_SAVED_SS], USER_DATA_SEG
    mov dword [esi + PROC_STATE], PROC_STATE_READY
    mov dword [esi + PROC_QUANTUM_TICKS], 0
    or dword [esi + PROC_VM_FLAGS], PROC_FLAG_IRQ_FRAME_VALID
    pop edi
    pop ecx
    pop eax
    ret

process_activate:
    push eax
    push ebx
    mov ebx, [current_process_ptr]
    cmp ebx, 0
    je .activate
    cmp dword [ebx + PROC_STATE], PROC_STATE_RUNNING
    jne .activate
    mov dword [ebx + PROC_STATE], PROC_STATE_READY

.activate:
    mov [current_process_ptr], esi
    mov eax, [esi + PROC_PID]
    mov [current_pid], eax
    mov eax, [esi + PROC_PAGE_DIR]
    test eax, eax
    jnz .have_page_dir
    mov eax, PAGING_DIR_ADDR

.have_page_dir:
    mov cr3, eax
    mov eax, [esi + PROC_KERNEL_STACK_TOP]
    mov [tss_esp0], eax
    mov word [tss_ss0], DATA_SEG
    mov dword [esi + PROC_STATE], PROC_STATE_RUNNING
    inc dword [esi + PROC_RUNS]
    inc dword [esi + PROC_SWITCHES]
    inc dword [scheduler_context_switches]
    mov eax, [esi + PROC_KIND]
    mov [current_user_kind], al
    mov eax, [esi + PROC_BASE]
    mov [current_user_base], eax
    mov eax, [esi + PROC_END]
    mov [current_user_end], eax
    mov eax, [esi + PROC_BRK]
    mov [current_user_brk], eax
    mov [user_brk_current], eax
    mov eax, [esi + PROC_HEAP_START]
    mov [current_user_heap_start], eax
    mov eax, [esi + PROC_HEAP_END]
    mov [current_user_heap_end], eax
    mov eax, [esi + PROC_STACK_TOP]
    mov [current_user_stack_top], eax
    mov eax, [esi + PROC_ENTRY]
    mov [current_user_entry], eax
    pop ebx
    pop eax
    ret

process_return_to_kernel:
    mov esi, process_kernel
    call process_activate
    ret

process_mark_current_exited:
    push esi
    mov esi, [current_process_ptr]
    cmp esi, 0
    je .done
    call process_retire_current_exit_slot
    mov [esi + PROC_EXIT_STATUS], ebx

.done:
    pop esi
    ret

process_mark_current_faulted:
    push esi
    mov esi, [current_process_ptr]
    cmp esi, 0
    je .done
    call fd_close_owned_by_process
    call process_teardown_user_vm
    mov dword [esi + PROC_STATE], PROC_STATE_FAULTED

.done:
    pop esi
    ret

process_waitpid_current:
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov [process_wait_last_pid_arg], ebx
    mov [process_wait_last_status_ptr], ecx
    mov [process_wait_last_options], edx
    inc dword [process_wait_attempts]
    mov eax, edx
    and eax, 0xfffffffe
    jne .einval
    cmp ebx, 0xffffffff
    je .pid_ok
    cmp ebx, 0
    jg .pid_ok
    jmp .echild

.pid_ok:
    cmp ecx, 0
    je .scan
    mov eax, ecx
    mov ebx, 4
    call user_range_validate
    jc .einval

.scan:
    mov dword [process_wait_seen_live_child], 0
    mov esi, process_table
    mov edi, PROCESS_SLOT_COUNT

.scan_next:
    cmp edi, 0
    je .scan_done
    cmp esi, process_kernel
    je .advance
    mov eax, [current_process_ptr]
    cmp esi, eax
    je .advance
    mov eax, [esi + PROC_PARENT_PID]
    cmp eax, [current_pid]
    jne .advance
    mov eax, [process_wait_last_pid_arg]
    cmp eax, 0xffffffff
    je .child_matches
    cmp eax, [esi + PROC_PID]
    jne .advance

.child_matches:
    mov eax, [esi + PROC_STATE]
    cmp eax, PROC_STATE_EXITED
    je .reap
    cmp eax, PROC_STATE_FAULTED
    je .reap
    mov dword [process_wait_seen_live_child], 1
    jmp .advance

.advance:
    add esi, PROCESS_RECORD_BYTES
    dec edi
    jmp .scan_next

.scan_done:
    cmp dword [process_wait_seen_live_child], 0
    jne .live_child
    jmp .echild

.live_child:
    test dword [process_wait_last_options], WAIT_OPTION_WNOHANG
    jnz .nohang
    jmp .enosys

.nohang:
    inc dword [process_wait_nohang_returns]
    xor eax, eax
    clc
    jmp .done

.reap:
    mov eax, [esi + PROC_PID]
    mov [process_wait_last_reaped_pid], eax
    mov ebx, [esi + PROC_EXIT_STATUS]
    mov [process_wait_last_status], ebx
    mov ecx, [process_wait_last_status_ptr]
    cmp ecx, 0
    je .reap_without_status
    mov [ecx], ebx

.reap_without_status:
    inc dword [process_wait_reaps]
    call fd_close_owned_by_process
    mov dword [esi + PROC_STATE], PROC_STATE_UNUSED
    mov dword [esi + PROC_PARENT_PID], 0xffffffff
    and dword [esi + PROC_VM_FLAGS], 0xfffffffe
    mov eax, [process_wait_last_reaped_pid]
    clc
    jmp .done

.einval:
    inc dword [process_wait_failures]
    mov eax, -ERRNO_EINVAL
    stc
    jmp .done

.enosys:
    inc dword [process_wait_failures]
    mov eax, -ERRNO_ENOSYS
    stc
    jmp .done

.echild:
    inc dword [process_wait_failures]
    mov eax, -ERRNO_ECHILD
    stc

.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

scheduler_prepare_live_preempt_probe:
    push eax
    push esi
    mov esi, process_preempt_probe
    call process_reset_preempt_probe
    call process_restore_user_stack_vm
    mov dword [esi + PROC_ENTRY], USER_CODE_ADDR
    call process_seed_initial_user_context
    mov dword [esi + PROC_SAVED_EAX], PREEMPT_PROBE_MAGIC
    mov dword [USER_STACK_TOP - 4], PREEMPT_PROBE_MAGIC
    mov dword [scheduler_preempt_probe_ready], 1
    mov dword [scheduler_preempt_spin_value], PREEMPT_PROBE_MAGIC
    pop esi
    pop eax
    ret

scheduler_capture_preempt_spin:
    push eax
    cmp dword [scheduler_preempt_probe_ready], 0
    je .done
    cmp dword [current_process_ptr], process_preempt_probe
    jne .done
    mov eax, [USER_STACK_TOP - 4]
    mov [scheduler_preempt_spin_value], eax

.done:
    pop eax
    ret

scheduler_tick:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    inc dword [scheduler_tick_count]
    mov esi, [current_process_ptr]
    cmp esi, 0
    je .done
    call scheduler_capture_preempt_spin
    mov eax, [ebx + 36]
    test eax, 3
    jz .account_current
    inc dword [scheduler_user_irq_ticks]

.account_current:
    inc dword [esi + PROC_TICKS]
    inc dword [esi + PROC_QUANTUM_TICKS]
    call process_save_irq_context
    mov eax, [esi + PROC_QUANTUM_TICKS]
    cmp eax, SCHEDULER_QUANTUM_TICKS
    jb .done
    mov dword [esi + PROC_QUANTUM_TICKS], 0
    inc dword [scheduler_round_count]
    mov eax, [ebx + 36]
    test eax, 3
    jz .skip_preempt
    inc dword [scheduler_preempt_attempts]
    mov eax, [esi + PROC_PID]
    mov [scheduler_last_preempt_from_pid], eax
    mov eax, [esi + PROC_KIND]
    mov [scheduler_last_preempt_from_kind], eax
    mov eax, [esi + PROC_SAVED_EIP]
    mov [scheduler_last_preempt_from_eip], eax
    mov eax, [esi + PROC_PAGE_DIR]
    mov [scheduler_last_preempt_from_cr3], eax
    mov eax, [esi + PROC_KERNEL_STACK_TOP]
    mov [scheduler_last_preempt_from_kstack], eax
    mov dword [scheduler_last_preempt_to_pid], 0xffffffff
    mov dword [scheduler_last_preempt_to_kind], 0
    mov dword [scheduler_last_preempt_to_eip], 0
    mov dword [scheduler_last_preempt_to_cr3], 0
    mov dword [scheduler_last_preempt_to_kstack], 0
    call scheduler_select_next_ready
    mov esi, [scheduler_next_process_ptr]
    cmp esi, 0
    je .skip_preempt
    mov eax, [esi + PROC_PID]
    mov [scheduler_last_preempt_to_pid], eax
    mov eax, [esi + PROC_KIND]
    mov [scheduler_last_preempt_to_kind], eax
    mov eax, [esi + PROC_SAVED_EIP]
    mov [scheduler_last_preempt_to_eip], eax
    mov eax, [esi + PROC_PAGE_DIR]
    mov [scheduler_last_preempt_to_cr3], eax
    mov eax, [esi + PROC_KERNEL_STACK_TOP]
    mov [scheduler_last_preempt_to_kstack], eax
    call process_activate
    call process_restore_irq_context
    inc dword [scheduler_preempt_switches]
    inc dword [scheduler_irq_context_switches]
    jmp .done

.skip_preempt:
    inc dword [scheduler_preempt_skips]

.done:
    call scheduler_capture_preempt_spin

.restore_regs:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

process_save_irq_context:
    mov eax, [ebx + 28]
    mov [esi + PROC_SAVED_EAX], eax
    mov eax, [ebx + 16]
    mov [esi + PROC_SAVED_EBX], eax
    mov eax, [ebx + 24]
    mov [esi + PROC_SAVED_ECX], eax
    mov eax, [ebx + 20]
    mov [esi + PROC_SAVED_EDX], eax
    mov eax, [ebx + 4]
    mov [esi + PROC_SAVED_ESI], eax
    mov eax, [ebx]
    mov [esi + PROC_SAVED_EDI], eax
    mov eax, [ebx + 8]
    mov [esi + PROC_SAVED_EBP], eax
    mov eax, [ebx + 32]
    mov [esi + PROC_SAVED_EIP], eax
    mov eax, [ebx + 40]
    mov [esi + PROC_SAVED_EFLAGS], eax
    mov eax, [ebx + 36]
    mov [esi + PROC_SAVED_CS], eax
    test eax, 3
    jz .kernel_frame
    mov eax, [ebx + 44]
    mov [esi + PROC_SAVED_ESP], eax
    mov eax, [ebx + 48]
    mov [esi + PROC_SAVED_SS], eax
    or dword [esi + PROC_VM_FLAGS], PROC_FLAG_IRQ_FRAME_VALID
    ret

.kernel_frame:
    mov eax, [ebx + 12]
    mov [esi + PROC_SAVED_ESP], eax
    mov dword [esi + PROC_SAVED_SS], DATA_SEG
    and dword [esi + PROC_VM_FLAGS], 0xfffffffe
    ret

process_restore_irq_context:
    mov eax, [esi + PROC_SAVED_EDI]
    mov [ebx], eax
    mov eax, [esi + PROC_SAVED_ESI]
    mov [ebx + 4], eax
    mov eax, [esi + PROC_SAVED_EBP]
    mov [ebx + 8], eax
    mov eax, [esi + PROC_SAVED_ESP]
    mov [ebx + 12], eax
    mov eax, [esi + PROC_SAVED_EBX]
    mov [ebx + 16], eax
    mov eax, [esi + PROC_SAVED_EDX]
    mov [ebx + 20], eax
    mov eax, [esi + PROC_SAVED_ECX]
    mov [ebx + 24], eax
    mov eax, [esi + PROC_SAVED_EAX]
    mov [ebx + 28], eax
    mov eax, [esi + PROC_SAVED_EIP]
    mov [ebx + 32], eax
    mov eax, [esi + PROC_SAVED_CS]
    mov [ebx + 36], eax
    mov eax, [esi + PROC_SAVED_EFLAGS]
    mov [ebx + 40], eax
    mov eax, [esi + PROC_SAVED_ESP]
    mov [ebx + 44], eax
    mov eax, [esi + PROC_SAVED_SS]
    mov [ebx + 48], eax
    ret

process_save_syscall_return_context:
    push eax
    push esi
    mov esi, [current_process_ptr]
    cmp esi, 0
    je .done
    mov eax, [syscall_return_value]
    mov [esi + PROC_SAVED_EAX], eax
    mov eax, [esp + 32]
    mov [esi + PROC_SAVED_EBX], eax
    mov eax, [esp + 28]
    mov [esi + PROC_SAVED_ECX], eax
    mov eax, [esp + 24]
    mov [esi + PROC_SAVED_EDX], eax
    mov eax, [esp + 20]
    mov [esi + PROC_SAVED_ESI], eax
    mov eax, [esp + 16]
    mov [esi + PROC_SAVED_EDI], eax
    mov eax, [esp + 12]
    mov [esi + PROC_SAVED_EBP], eax
    mov eax, [esp + 36]
    mov [esi + PROC_SAVED_EIP], eax
    mov eax, [esp + 44]
    mov [esi + PROC_SAVED_EFLAGS], eax
    mov eax, [esp + 40]
    mov [esi + PROC_SAVED_CS], eax
    mov eax, [esp + 48]
    mov [esi + PROC_SAVED_ESP], eax
    mov eax, [esp + 52]
    mov [esi + PROC_SAVED_SS], eax
    or dword [esi + PROC_VM_FLAGS], PROC_FLAG_IRQ_FRAME_VALID

.done:
    pop esi
    pop eax
    ret

scheduler_select_next_ready:
    push eax
    push ecx
    push edx
    push edi
    mov dword [scheduler_next_process_ptr], 0
    mov eax, [scheduler_rr_cursor]
    mov ecx, PROCESS_SLOT_COUNT

.next:
    inc eax
    cmp eax, PROCESS_SLOT_COUNT
    jb .index_ok
    xor eax, eax

.index_ok:
    mov edi, eax
    imul edi, PROCESS_RECORD_BYTES
    add edi, process_table
    cmp dword [edi + PROC_STATE], PROC_STATE_READY
    jne .advance
    test dword [edi + PROC_VM_FLAGS], PROC_FLAG_IRQ_FRAME_VALID
    jz .advance
    test dword [edi + PROC_SAVED_CS], 3
    jz .advance
    cmp dword [edi + PROC_SAVED_EIP], 0
    jne .found

.advance:
    loop .next
    mov dword [scheduler_next_pid], 0xffffffff
    jmp .done

.found:
    mov [scheduler_rr_cursor], eax
    mov [scheduler_next_process_ptr], edi
    mov edx, [edi + PROC_PID]
    mov [scheduler_next_pid], edx

.done:
    pop edi
    pop edx
    pop ecx
    pop eax
    ret

scheduler_preempt_self_test:
    pushad
    mov byte [scheduler_preempt_selftest_status], 0

    mov esi, process_user_probe
    mov dword [esi + PROC_STATE], PROC_STATE_READY
    mov dword [esi + PROC_SAVED_EAX], 0x11111111
    mov dword [esi + PROC_SAVED_EBX], 0x22222222
    mov dword [esi + PROC_SAVED_ECX], 0x33333333
    mov dword [esi + PROC_SAVED_EDX], 0x44444444
    mov dword [esi + PROC_SAVED_ESI], 0x55555555
    mov dword [esi + PROC_SAVED_EDI], 0x66666666
    mov dword [esi + PROC_SAVED_EBP], 0x77777777
    mov dword [esi + PROC_SAVED_ESP], USER_STACK_TOP - 16
    mov dword [esi + PROC_SAVED_EIP], USER_CODE_ADDR
    mov dword [esi + PROC_SAVED_EFLAGS], 0x00000202
    mov dword [esi + PROC_SAVED_CS], USER_CODE_SEG
    mov dword [esi + PROC_SAVED_SS], USER_DATA_SEG
    or dword [esi + PROC_VM_FLAGS], PROC_FLAG_IRQ_FRAME_VALID

    mov esi, process_preempt_probe
    mov dword [esi + PROC_ENTRY], USER_CODE_ADDR
    call process_seed_initial_user_context

    mov edi, scheduler_preempt_selftest_frame
    xor eax, eax
    mov ecx, 13
    cld
    rep stosd

    mov esi, process_user_probe
    mov ebx, scheduler_preempt_selftest_frame
    call process_restore_irq_context

    cmp dword [scheduler_preempt_selftest_frame + 28], 0x11111111
    jne .done
    cmp dword [scheduler_preempt_selftest_frame + 16], 0x22222222
    jne .done
    cmp dword [scheduler_preempt_selftest_frame + 32], USER_CODE_ADDR
    jne .done
    cmp dword [scheduler_preempt_selftest_frame + 36], USER_CODE_SEG
    jne .done
    cmp dword [scheduler_preempt_selftest_frame + 40], 0x00000202
    jne .done
    cmp dword [scheduler_preempt_selftest_frame + 44], USER_STACK_TOP - 16
    jne .done
    cmp dword [scheduler_preempt_selftest_frame + 48], USER_DATA_SEG
    jne .done

    mov dword [scheduler_rr_cursor], 0
    call scheduler_select_next_ready
    cmp dword [scheduler_next_pid], 1
    jne .done
    cmp dword [scheduler_next_process_ptr], process_user_probe
    jne .done
    mov dword [scheduler_rr_cursor], 1
    call scheduler_select_next_ready
    cmp dword [scheduler_next_pid], 3
    jne .done
    cmp dword [scheduler_next_process_ptr], process_preempt_probe
    jne .done
    mov byte [scheduler_preempt_selftest_status], 1

.done:
    mov dword [scheduler_rr_cursor], 0
    mov dword [scheduler_next_pid], 0xffffffff
    mov dword [scheduler_next_process_ptr], 0
    mov esi, process_user_probe
    call process_reset_user_probe
    mov esi, process_preempt_probe
    call process_reset_preempt_probe
    mov esi, process_doom
    call process_reset_doom
    popad
    ret

process_boot_launch_doom:
    cmp dword [sys_exec_successes], 0
    jne .done
    mov byte [doom_run_status], 4

.done:
    ret

process_exec_path:
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov byte [process_exec_status], 0
    mov dword [process_exec_last_error], 0
    mov dword [process_exec_entry], 0
    mov dword [process_exec_path_ptr], esi
    mov dword [process_exec_target], edi
    call process_exec_resolve_path
    jnc .resolved
    cmp dword [process_exec_last_error], 0
    jne .fail
    mov dword [process_exec_last_error], -ERRNO_ENOENT
    jmp .fail

.resolved:
    cmp byte [process_exec_reject_active_target], 1
    jne .target_safe
    mov eax, [current_process_ptr]
    cmp eax, [process_exec_target]
    jne .target_safe
    mov dword [process_exec_last_error], -ERRNO_EACCES
    jmp .fail

.target_safe:
    mov esi, [process_exec_target]
    call process_reuse_exec_target_slot

    mov edi, [process_exec_name83]
    call fat_find_file
    jnc .fat_found
    mov dword [process_exec_last_error], -ERRNO_ENOENT
    jmp .fail

.fat_found:

    mov ax, [fat_found_first_cluster]
    mov [process_exec_first_cluster], ax
    mov eax, [fat_found_size]
    mov [process_exec_size], eax

    cmp dword [process_exec_target], process_doom
    je .bind_doom_artifact
    mov eax, [process_exec_target]
    call process_is_user_exec_target
    jnc .bind_user_artifact
    jmp .reserve

.bind_doom_artifact:
    mov ax, [process_exec_first_cluster]
    mov [doom_elf_first_cluster], ax
    mov eax, [process_exec_size]
    mov [doom_elf_size], eax
    mov byte [doom_elf_status], 1
    jmp .reserve

.bind_user_artifact:
    mov ax, [process_exec_first_cluster]
    mov [user_elf_first_cluster], ax
    mov eax, [process_exec_size]
    mov [user_elf_size], eax
    mov byte [user_elf_status], 1

.reserve:
    mov eax, [process_exec_size]
    add eax, PAGE_SIZE - 1
    shr eax, 12
    mov ecx, eax
    mov eax, [process_exec_load_addr]
    call pmm_reserve_pages

    movzx eax, word [process_exec_first_cluster]
    mov ebx, [process_exec_size]
    mov ecx, [process_exec_max_bytes]
    mov edi, [process_exec_load_addr]
    call fat_load_file
    jc .load_fail

    mov eax, [fat_load_sectors_read]
    mov [process_exec_sectors_read], eax
    mov esi, [process_exec_load_addr]
    cmp dword [esi], ELF_MAGIC
    jne .load_fail

    cmp dword [process_exec_target], process_doom
    je .loaded_doom
    mov eax, [process_exec_target]
    call process_is_user_exec_target
    jnc .loaded_user_probe
    jmp .unsupported

.loaded_doom:
    mov eax, [process_exec_sectors_read]
    mov [doom_elf_sectors_read], eax
    mov byte [doom_elf_load_status], 1
    jmp .prepare

.loaded_user_probe:
    mov eax, [process_exec_sectors_read]
    mov [user_elf_sectors_read], eax
    mov byte [user_elf_status], 1

.prepare:
    call process_exec_prepare_elf_image
    jnc .prepared
    mov dword [process_exec_last_error], -ERRNO_EIO
    jmp .fail

.prepared:
    mov esi, [process_exec_target]
    mov eax, [process_exec_entry]
    mov [esi + PROC_ENTRY], eax
    mov byte [process_exec_status], 1
    clc
    jmp .done

.unsupported:
    mov dword [process_exec_last_error], -ERRNO_EINVAL
    stc
    jmp .fail

.load_fail:
    mov dword [process_exec_last_error], -ERRNO_EIO
    cmp dword [process_exec_target], process_doom
    je .load_fail_doom
    mov eax, [process_exec_target]
    call process_is_user_exec_target
    jc .fail
    mov byte [user_elf_status], 2
    jmp .fail

.load_fail_doom:
    mov byte [doom_elf_load_status], 2

.fail:
    mov esi, [process_exec_target]
    cmp esi, 0
    je .status_fail
    cmp esi, [current_process_ptr]
    je .status_fail
    call process_retire_exec_slot

.status_fail:
    mov byte [process_exec_status], 2
    stc

.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

process_exec_resolve_path:
    push eax
    push ebx
    push ecx
    push esi
    push edi

    mov ebx, process_exec_table
    mov ecx, PROCESS_EXEC_TABLE_COUNT

.entry_loop:
    cmp ecx, 0
    je .try_generic_root83
    mov esi, [process_exec_path_ptr]
    mov edi, [ebx + PROCESS_EXEC_PATH]
    call kernel_streq
    cmp al, 1
    je .found
    add ebx, PROCESS_EXEC_ENTRY_BYTES
    dec ecx
    jmp .entry_loop

.found:
    mov eax, [ebx + PROCESS_EXEC_NAME83]
    mov [process_exec_name83], eax
    mov eax, [ebx + PROCESS_EXEC_LOAD_ADDR]
    mov [process_exec_load_addr], eax
    mov eax, [ebx + PROCESS_EXEC_MAX_BYTES]
    mov [process_exec_max_bytes], eax
    mov eax, [ebx + PROCESS_EXEC_TARGET]
    mov [process_exec_target], eax
    clc
    jmp .done

.try_generic_root83:
    call process_exec_resolve_generic_root83
    jnc .done

.fail:
    stc

.done:
    pop edi
    pop esi
    pop ecx
    pop ebx
    pop eax
    ret

process_exec_resolve_generic_root83:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov edi, process_exec_name83_buffer
    mov al, ' '
    mov ecx, 11
    cld
    rep stosb
    mov esi, [process_exec_path_ptr]
    cmp esi, 0
    je .fail
    xor eax, eax
    mov [process_exec_base_len], al
    mov [process_exec_ext_len], al
    mov [process_exec_dot_seen], al
    mov ecx, SYS_EXEC_PATH_MAX - 1

.char_loop:
    cmp ecx, 0
    je .fail
    lodsb
    test al, al
    jz .finish
    dec ecx
    cmp al, '/'
    je .fail
    cmp al, 0x5c
    je .fail
    cmp al, '.'
    je .dot
    cmp al, 'a'
    jb .validate_char
    cmp al, 'z'
    ja .validate_char
    sub al, 32

.validate_char:
    cmp al, 'A'
    jb .check_digit
    cmp al, 'Z'
    jbe .store_char

.check_digit:
    cmp al, '0'
    jb .check_extra
    cmp al, '9'
    jbe .store_char

.check_extra:
    cmp al, '_'
    je .store_char
    cmp al, '-'
    je .store_char
    jmp .fail

.dot:
    cmp byte [process_exec_base_len], 0
    je .fail
    cmp byte [process_exec_dot_seen], 0
    jne .fail
    mov byte [process_exec_dot_seen], 1
    jmp .char_loop

.store_char:
    cmp byte [process_exec_dot_seen], 0
    jne .store_ext
    movzx edx, byte [process_exec_base_len]
    cmp edx, 8
    jae .fail
    mov [process_exec_name83_buffer + edx], al
    inc byte [process_exec_base_len]
    jmp .char_loop

.store_ext:
    movzx edx, byte [process_exec_ext_len]
    cmp edx, 3
    jae .fail
    mov [process_exec_name83_buffer + 8 + edx], al
    inc byte [process_exec_ext_len]
    jmp .char_loop

.finish:
    cmp byte [process_exec_base_len], 0
    je .fail
    cmp byte [process_exec_dot_seen], 0
    je .fail
    cmp byte [process_exec_ext_len], 0
    je .fail
    cmp byte [process_exec_name83_buffer + 8], 'E'
    jne .fail
    cmp byte [process_exec_name83_buffer + 9], 'L'
    jne .fail
    cmp byte [process_exec_name83_buffer + 10], 'F'
    jne .fail
    call process_alloc_generic_exec_slot
    jc .fail
    mov dword [process_exec_name83], process_exec_name83_buffer
    mov dword [process_exec_load_addr], USER_ELF_LOAD_ADDR
    mov dword [process_exec_max_bytes], USER_ELF_MAX_BYTES
    mov [process_exec_target], esi
    clc
    jmp .done

.fail:
    stc

.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

process_exec_prepare_elf_image:
    cmp dword [process_exec_target], process_doom
    je .prepare_doom
    mov eax, [process_exec_target]
    call process_is_user_exec_target
    jnc .prepare_user_probe
    jmp .fail

.prepare_doom:
    call doom_elf_prepare
    jc .fail
    mov eax, [doom_entry_addr]
    mov [process_exec_entry], eax
    clc
    ret

.prepare_user_probe:
    call user_elf_prepare
    jc .fail
    mov eax, [user_entry_addr]
    mov [process_exec_entry], eax
    clc
    ret

.fail:
    stc
    ret

process_exec_handoff_current:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov esi, [process_exec_target]
    cmp esi, 0
    je .einval
    mov edi, [current_process_ptr]
    cmp edi, 0
    je .einval
    cmp edi, esi
    je .eacces
    cmp dword [process_exec_entry], 0
    je .eio

    cmp esi, process_doom
    je .reset_doom_target
    mov eax, esi
    call process_is_user_exec_target
    jnc .reset_user_probe_target
    jmp .einval

.reset_doom_target:
    call process_reset_doom
    mov eax, [process_exec_entry]
    mov [esi + PROC_ENTRY], eax
    mov byte [doom_run_status], 1
    mov dword [doom_exit_code], 0
    mov dword [doom_fault_addr], 0
    mov dword [doom_fault_eip], 0
    mov dword [doom_fault_vector], 0
    mov dword [doom_fault_error], 0
    call clear_fault_record
    mov dword [doom_last_syscall], 0
    mov dword [doom_error_count], 0
    mov dword [doom_last_error], 0
    mov dword [doom_log_len], 0
    mov byte [doom_log_buffer], 0
    jmp .seed_context

.reset_user_probe_target:
    call process_reset_user_probe
    mov eax, [process_exec_entry]
    mov [esi + PROC_ENTRY], eax
    mov byte [user_probe_status], 0
    mov byte [user_fault_expected], 0
    mov byte [user_fault_status], 0
    mov dword [user_probe_magic_seen], 0
    mov dword [user_probe_flags_seen], 0
    mov dword [user_fault_addr], 0
    mov dword [user_fault_recovery], 0

.seed_context:
    mov eax, [edi + PROC_PID]
    mov edx, [esi + PROC_PID]
    call fd_exec_handoff
    call keyboard_reset_queue
    call mouse_reset_queue
    call process_seed_initial_user_context
    cmp esi, process_doom
    jne .activate_target
    call scheduler_prepare_live_preempt_probe

.activate_target:
    mov eax, [edi + PROC_PID]
    mov [esi + PROC_PARENT_PID], eax
    call process_activate
    call process_exec_seed_argv_stack
    jc .eio_after_activate
    call pic_unmask_timer_keyboard

    mov eax, [edi + PROC_PID]
    mov [sys_exec_last_caller_pid], eax
    mov eax, [esi + PROC_PARENT_PID]
    mov [sys_exec_last_parent_pid], eax
    mov eax, [esi + PROC_PID]
    mov [sys_exec_last_target_pid], eax
    mov eax, [esi + PROC_ENTRY]
    mov [sys_exec_last_target_entry], eax
    mov eax, [esi + PROC_SAVED_ESP]
    mov [sys_exec_last_target_stack], eax
    inc dword [esi + PROC_EXEC_COUNT]
    call process_exec_patch_syscall_frame
    jc .eio_after_activate
    push esi
    mov esi, edi
    call process_retire_exec_slot
    pop esi

    mov eax, [esi + PROC_PID]
    mov [scheduler_next_pid], eax
    mov [scheduler_next_process_ptr], esi
    inc dword [sys_exec_scheduled]
    inc dword [sys_exec_handoffs]
    clc
    jmp .done

.eacces:
    mov dword [process_exec_last_error], -ERRNO_EACCES
    stc
    jmp .done

.einval:
    mov dword [process_exec_last_error], -ERRNO_EINVAL
    stc
    jmp .done

.eio_after_activate:
    push esi
    mov esi, edi
    call process_activate
    pop esi
    call process_retire_exec_slot
    jmp .eio

.eio:
    mov dword [process_exec_last_error], -ERRNO_EIO
    stc

.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

process_exec_seed_argv_stack:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov edx, esi
    cmp dword [sys_exec_argc], 0
    je .fail
    cmp dword [sys_exec_argc], SYS_EXEC_ARG_MAX
    ja .fail

    mov eax, [edx + PROC_STACK_TOP]
    mov [sys_exec_stack_cursor], eax
    mov ecx, [sys_exec_argc]

.copy_string_loop:
    cmp ecx, 0
    je .strings_done
    dec ecx
    mov eax, [sys_exec_stack_cursor]
    sub eax, SYS_EXEC_ARG_STR_MAX
    jc .fail
    and eax, 0xfffffffc
    cmp eax, [edx + PROC_STACK_BOTTOM]
    jb .fail
    mov [sys_exec_stack_cursor], eax
    mov edi, eax
    mov esi, sys_exec_arg_strings
    mov ebx, ecx
    shl ebx, 6
    add esi, ebx
    push ecx
    mov ecx, SYS_EXEC_ARG_STR_MAX
    cld
    rep movsb
    pop ecx
    mov [sys_exec_arg_target_ptrs + ecx * 4], eax
    jmp .copy_string_loop

.strings_done:
    mov ecx, [sys_exec_argc]
    mov ebx, ecx
    shl ebx, 2
    add ebx, SYS_EXEC_ARG_FRAME_BASE_BYTES
    mov eax, [sys_exec_stack_cursor]
    sub eax, ebx
    jc .fail
    and eax, 0xfffffff0
    cmp eax, [edx + PROC_STACK_BOTTOM]
    jb .fail
    mov [sys_exec_user_stack_ptr], eax
    mov edi, eax
    mov [edi], ecx
    lea ebx, [edi + 4]
    xor esi, esi

.copy_argv_ptr_loop:
    cmp esi, ecx
    jae .argv_ptrs_done
    mov eax, [sys_exec_arg_target_ptrs + esi * 4]
    mov [ebx + esi * 4], eax
    inc esi
    jmp .copy_argv_ptr_loop

.argv_ptrs_done:
    mov dword [ebx + ecx * 4], 0
    mov dword [ebx + ecx * 4 + 4], 0
    mov eax, [sys_exec_argc]
    mov [sys_exec_last_argc], eax
    mov [edx + PROC_ARGC], eax
    mov eax, ebx
    mov [sys_exec_last_argv], eax
    mov [edx + PROC_ARGV], eax
    lea eax, [ebx + ecx * 4 + 4]
    mov [sys_exec_last_envp], eax
    mov [edx + PROC_ENVP], eax
    mov eax, [eax]
    mov [sys_exec_last_envp0], eax
    mov eax, [sys_exec_arg_target_ptrs]
    mov [sys_exec_argv0_ptr], eax
    mov [sys_exec_last_argv0], eax
    mov [edx + PROC_ARGV0], eax
    mov eax, [sys_exec_user_stack_ptr]
    mov [edx + PROC_SAVED_ESP], eax
    clc
    jmp .done

.fail:
    stc

.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

process_exec_patch_syscall_frame:
    push eax
    push ebx

    mov ebx, [sys_exec_frame_ptr]
    cmp ebx, 0
    je .fail
    mov dword [ebx + SYSCALL_FRAME_EBP], 0
    mov dword [ebx + SYSCALL_FRAME_EDI], 0
    mov dword [ebx + SYSCALL_FRAME_ESI], 0
    mov dword [ebx + SYSCALL_FRAME_EDX], 0
    mov dword [ebx + SYSCALL_FRAME_ECX], 0
    mov dword [ebx + SYSCALL_FRAME_EBX], 0
    mov eax, [esi + PROC_SAVED_EIP]
    mov [ebx + SYSCALL_FRAME_EIP], eax
    mov eax, [esi + PROC_SAVED_CS]
    mov [ebx + SYSCALL_FRAME_CS], eax
    mov eax, [esi + PROC_SAVED_EFLAGS]
    mov [ebx + SYSCALL_FRAME_EFLAGS], eax
    mov eax, [esi + PROC_SAVED_ESP]
    mov [ebx + SYSCALL_FRAME_ESP], eax
    mov eax, [esi + PROC_SAVED_SS]
    mov [ebx + SYSCALL_FRAME_SS], eax
    clc
    jmp .done

.fail:
    stc

.done:
    pop ebx
    pop eax
    ret

kernel_streq:
    push esi
    push edi

.next:
    mov al, [esi]
    cmp al, [edi]
    jne .no
    test al, al
    jz .yes
    inc esi
    inc edi
    jmp .next

.yes:
    mov al, 1
    jmp .done

.no:
    xor al, al

.done:
    pop edi
    pop esi
    ret

user_probe_run:
    mov esi, process_user_probe
    call process_reset_user_probe
    mov dword [process_user_probe + PROC_PARENT_PID], 0
    call process_activate
    mov byte [user_probe_status], 0
    mov byte [user_fault_expected], 0
    mov byte [user_fault_status], 0
    mov dword [user_probe_magic_seen], 0
    mov dword [user_probe_flags_seen], 0
    mov dword [user_fault_addr], 0
    mov dword [user_fault_recovery], 0
    mov dword [user_wad_magic_seen], 0
    call fd_reset_all
    call process_seed_wait_reap_probe_child
    mov byte [present_status], 0
    mov dword [present_sample_first], 0
    mov dword [present_sample_mid], 0
    mov dword [present_sample_last], 0
    mov dword [present_palette_hash], 0
    mov dword [present_frame_hash], 0
    mov dword [present_nonzero_count], 0
    mov dword [present_color_transition_count], 0
    mov byte [present_previous_index], 0
    call present_reset_status_fields
    mov word [user_probe_cs], 0
    mov word [user_probe_ss], 0

    call user_elf_prepare
    jc .fail
    mov eax, [user_entry_addr]
    mov [process_user_probe + PROC_ENTRY], eax
    mov [current_user_entry], eax

    mov edi, USER_STACK_BOTTOM
    xor eax, eax
    mov ecx, PAGE_SIZE / 4
    rep stosd
    mov edi, USER_HEAP_START
    xor eax, eax
    mov ecx, (USER_HEAP_END - USER_HEAP_START) / 4
    rep stosd
    mov esi, exec_path_user_probe
    call sys_exec_stage_kernel_arg
    jc .fail
    mov esi, process_user_probe
    call process_seed_initial_user_context
    call process_activate
    call process_exec_seed_argv_stack
    jc .fail
    inc dword [process_user_probe + PROC_EXEC_COUNT]

    mov ax, USER_DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    push dword USER_DATA_SEG
    push dword [process_user_probe + PROC_SAVED_ESP]
    push dword 0x00000202
    push dword USER_CODE_SEG
    push dword [current_user_entry]
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx
    xor esi, esi
    xor edi, edi
    xor ebp, ebp
    iretd

.fail:
    mov byte [user_probe_status], 2
    call process_mark_current_faulted
    ret

doom_user_run:
    mov esi, process_doom
    call process_reset_doom
    call process_activate
    mov byte [doom_run_status], 0
    mov dword [doom_exit_code], 0
    mov dword [doom_fault_addr], 0
    mov dword [doom_fault_eip], 0
    mov dword [doom_fault_vector], 0
    mov dword [doom_fault_error], 0
    call clear_fault_record
    mov dword [doom_last_syscall], 0
    mov dword [doom_open_count], 0
    mov dword [doom_read_count], 0
    mov dword [doom_lseek_count], 0
    mov dword [doom_write_count], 0
    mov dword [doom_close_count], 0
    mov dword [doom_sbrk_count], 0
    mov dword [doom_error_count], 0
    mov dword [doom_last_error], 0
    mov dword [doom_last_open_flags], 0
    mov dword [doom_last_open_mode], 0
    mov dword [doom_saveaction_flags], 0
    mov dword [doom_saveaction_gameaction], 0
    mov dword [doom_saveaction_slot], 0xffffffff
    mov dword [doom_saveaction_desc_len], 0
    mov dword [doom_saveaction_desc_hash], 0
    mov dword [doom_saveaction_report_count], 0
    mov dword [doom_present_count], 0
    mov dword [doom_init_flags], 0
    mov dword [doom_init_report_count], 0
    mov byte [doom_gameplay_status], 0
    mov dword [doom_gameplay_report_count], 0
    mov dword [doom_game_state_packed], 0
    mov dword [doom_game_state], 0
    mov dword [doom_game_episode], 0
    mov dword [doom_game_map], 0
    mov dword [doom_game_map_pair], 0
    mov dword [doom_game_flags], 0
    mov dword [doom_game_tic], 0
    mov dword [doom_level_time], 0
    mov dword [doom_player_flags], 0
    mov dword [doom_player_buttons], 0
    mov dword [doom_game_action], 0
    mov dword [doom_player_x], 0
    mov dword [doom_player_y], 0
    mov dword [doom_player_origin_set], 0
    mov dword [doom_player_origin_x], 0
    mov dword [doom_player_origin_y], 0
    mov dword [doom_player_delta], 0
    mov dword [doom_player_cmd], 0
    mov dword [doom_player_angle], 0
    mov dword [doom_player_angle_origin_set], 0
    mov dword [doom_player_origin_angle], 0
    mov dword [doom_player_angle_delta], 0
    mov dword [doom_player_ammo], 0
    mov dword [doom_player_refire], 0
    mov dword [doom_player_weapon], 0
    mov dword [doom_key_down_seen], 0
    mov dword [doom_key_last_event], 0
    mov dword [doom_mouse_buttons_seen], 0
    mov dword [doom_mouse_delta_x], 0
    mov dword [doom_mouse_delta_y], 0
    mov dword [doom_mouse_last_event], 0
    mov dword [doom_sound_call_count], 0
    mov dword [doom_sound_start_count], 0
    mov dword [doom_sound_stop_count], 0
    mov dword [doom_sound_update_count], 0
    mov dword [doom_sound_last_command], 0
    mov dword [doom_sound_last_handle], 0
    mov dword [doom_sound_last_packed], 0
    mov dword [doom_wad_magic_seen], 0
    mov dword [doom_log_len], 0
    mov byte [doom_log_buffer], 0
    mov byte [present_status], 0
    mov dword [present_sample_first], 0
    mov dword [present_sample_mid], 0
    mov dword [present_sample_last], 0
    mov dword [present_palette_hash], 0
    mov dword [present_frame_hash], 0
    mov dword [present_nonzero_count], 0
    mov dword [present_color_transition_count], 0
    mov byte [present_previous_index], 0
    call present_reset_status_fields
    call keyboard_reset_queue
    call mouse_reset_queue
    call fd_reset_all

    cmp byte [doom_elf_parse_status], 1
    jne .fail
    mov eax, [doom_entry_addr]
    mov [process_doom + PROC_ENTRY], eax
    mov [current_user_entry], eax

    cld
    mov edi, DOOM_USER_HEAP_START
    xor eax, eax
    mov ecx, (DOOM_USER_END - DOOM_USER_HEAP_START) / 4
    rep stosd

    mov byte [doom_run_status], 1

    call pic_unmask_timer_keyboard

    mov ax, USER_DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    push dword USER_DATA_SEG
    push dword [current_user_stack_top]
    push dword 0x00000202
    push dword USER_CODE_SEG
    push dword [current_user_entry]
    iretd

.fail:
    mov byte [doom_run_status], 4
    call process_mark_current_faulted
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

    mov eax, [esi + 24]
    mov [user_entry_addr], eax

    push ecx
    mov eax, [esi + 28]
    add eax, USER_ELF_LOAD_ADDR
    mov esi, eax
    mov edi, elf_phdr_scratch
    mov ecx, [esp]
    shl ecx, 5
    cld
    rep movsb
    pop ecx
    mov dword [user_phdr_ptr], elf_phdr_scratch
    mov [user_phdr_remaining], ecx

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
    mov eax, [esi + ELF_PH_FLAGS]
    mov [user_segment_flags], eax

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

    mov eax, [user_segment_dest]
    and eax, 0xfffff000
    mov edx, [user_segment_dest]
    add edx, [user_segment_memsz]
    add edx, PAGE_SIZE - 1
    and edx, 0xfffff000
    mov ebx, PROC_PROBE_PAGE_DIR_ADDR
    mov edi, [process_exec_target]
    cmp edi, 0
    je .user_segment_page_dir_ready
    mov ebx, [edi + PROC_PAGE_DIR]

.user_segment_page_dir_ready:
    test dword [user_segment_flags], ELF_PF_W
    jz .mark_user_segment_read
    call vmm_mark_process_user_write_range
    jmp .user_segment_permissions_done

.mark_user_segment_read:
    call vmm_mark_process_user_read_range

.user_segment_permissions_done:
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
    movzx ecx, word [esi + 44]
    cmp ecx, 0
    je .fail
    cmp ecx, 16
    ja .fail

    mov eax, [esi + 28]
    mov ebx, eax
    mov edx, ecx
    shl edx, 5
    add ebx, edx
    jc .fail
    cmp ebx, [doom_elf_size]
    ja .fail

    mov eax, [esi + 24]
    mov [doom_entry_addr], eax

    mov eax, [esi + 28]
    push ecx
    add eax, DOOM_ELF_LOAD_ADDR
    mov esi, eax
    mov edi, elf_phdr_scratch
    mov ecx, [esp]
    shl ecx, 5
    cld
    rep movsb
    pop ecx
    mov dword [doom_phdr_ptr], elf_phdr_scratch
    mov [doom_phdr_remaining], ecx

.phdr_loop:
    cmp dword [doom_phdr_remaining], 0
    je .segments_done
    mov esi, [doom_phdr_ptr]
    cmp dword [esi], PT_LOAD
    jne .next_phdr

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
    cmp ebx, DOOM_USER_HEAP_START
    ja .fail
    cmp ebx, [doom_segment_end]
    jbe .doom_segment_end_ok
    mov [doom_segment_end], ebx

.doom_segment_end_ok:

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
    mov eax, [esi + ELF_PH_FLAGS]
    mov [doom_segment_flags], eax

    mov esi, [doom_segment_source]
    mov edi, [doom_segment_dest]
    mov ecx, [doom_segment_filesz]
    cld
    rep movsb

    mov ecx, [doom_segment_memsz]
    sub ecx, [doom_segment_filesz]
    xor eax, eax
    rep stosb

    mov eax, [doom_segment_dest]
    and eax, 0xfffff000
    mov edx, [doom_segment_dest]
    add edx, [doom_segment_memsz]
    add edx, PAGE_SIZE - 1
    and edx, 0xfffff000
    mov ebx, PROC_DOOM_PAGE_DIR_ADDR
    test dword [doom_segment_flags], ELF_PF_W
    jz .mark_doom_segment_read
    call vmm_mark_process_user_write_range
    jmp .doom_segment_permissions_done

.mark_doom_segment_read:
    call vmm_mark_process_user_read_range

.doom_segment_permissions_done:
    inc byte [doom_load_segment_count]

.next_phdr:
    add dword [doom_phdr_ptr], 32
    dec dword [doom_phdr_remaining]
    jmp .phdr_loop

.segments_done:
    cmp byte [doom_load_segment_count], 0
    je .fail
    mov eax, [doom_entry_addr]
    cmp eax, DOOM_ELF_LOAD_ADDR
    jb .fail
    cmp eax, [doom_segment_end]
    jae .fail
    mov eax, [doom_segment_end]
    sub eax, DOOM_ELF_LOAD_ADDR
    mov [doom_segment_memsz], eax
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

    mov [current_syscall_number], eax
    cmp byte [current_user_kind], USER_KIND_DOOM
    jne .dispatch
    mov [doom_last_syscall], eax

.dispatch:
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
    cmp eax, SYS_POLL_KEY
    je .poll_key
    cmp eax, SYS_CLOSE
    je .close
    cmp eax, SYS_AUDIO
    je .audio
    cmp eax, SYS_POLL_MOUSE
    je .poll_mouse
    cmp eax, SYS_GAMEPLAY_STATUS
    je .gameplay_status
    cmp eax, SYS_EXEC
    je .exec
    cmp eax, SYS_UNLINK
    je .unlink
    cmp eax, SYS_STAT
    je .stat
    cmp eax, SYS_FSTAT
    je .fstat
    cmp eax, SYS_MMAP
    je .mmap
    cmp eax, SYS_MUNMAP
    je .munmap
    cmp eax, SYS_IOCTL
    je .ioctl
    cmp eax, SYS_FORK
    je .fork
    cmp eax, SYS_WAITPID
    je .waitpid
    cmp eax, SYS_GETPID
    je .getpid
    cmp eax, SYS_PLAYER_DETAIL_STATUS
    je .player_detail_status
    jmp .bad_syscall_enosys

.user_probe:
    cmp byte [current_user_kind], USER_KIND_PREEMPT_PROBE
    je .user_probe_skip
    mov [user_probe_magic_seen], ebx
    mov [user_probe_flags_seen], ecx
    movzx edx, word [esp + 28]
    mov [user_probe_cs], dx
    movzx edx, word [esp + 40]
    mov [user_probe_ss], dx
    mov byte [user_probe_status], 1
    xor eax, eax
    jmp .return

.user_probe_skip:
    xor eax, eax
    jmp .return

.expect_fault:
    mov [syscall_ptr_arg], ebx
    cmp ebx, 0
    je .expect_fault_arm
    mov eax, ebx
    mov ebx, 1
    call user_range_validate
    jc .bad_syscall_einval
    mov ebx, [syscall_ptr_arg]

.expect_fault_arm:
    mov byte [user_fault_expected], 1
    mov [user_fault_recovery], ebx
    xor eax, eax
    jmp .return

.write:
    cmp ebx, 1
    je .write_fd_ok
    cmp ebx, 2
    je .write_fd_ok
    call user_file_write
    jc .bad_syscall_from_eax
    jmp .return

.write_fd_ok:
    mov [syscall_ptr_arg], ecx
    mov [syscall_len_arg], edx
    mov eax, ecx
    mov ebx, edx
    call user_range_validate
    jc .bad_syscall_einval
    mov esi, [syscall_ptr_arg]
    mov ecx, [syscall_len_arg]

.write_next:
    cmp ecx, 0
    je .write_done
    lodsb
    call put_char
    cmp byte [current_user_kind], USER_KIND_DOOM
    jne .write_skip_capture
    call doom_log_char

.write_skip_capture:
    dec ecx
    jmp .write_next

.write_done:
    mov eax, [syscall_len_arg]
    cmp byte [current_user_kind], USER_KIND_DOOM
    jne .write_return
    inc dword [doom_write_count]

.write_return:
    jmp .return

.sbrk:
    mov esi, [current_process_ptr]
    cmp esi, 0
    je .bad_syscall_enomem
    mov eax, [esi + PROC_BRK]
    mov edx, eax
    add edx, ebx
    jc .bad_syscall_enomem
    cmp edx, [esi + PROC_HEAP_END]
    ja .bad_syscall_enomem
    push eax
    push edx
    mov ebx, [esi + PROC_PAGE_DIR]
    test ebx, ebx
    jnz .sbrk_have_page_dir
    mov ebx, PAGING_DIR_ADDR

.sbrk_have_page_dir:
    call vmm_mark_process_user_range
    mov ebx, [esi + PROC_PAGE_DIR]
    test ebx, ebx
    jz .sbrk_restore_brk
    mov cr3, ebx

.sbrk_restore_brk:
    pop edx
    pop eax
    call process_heap_mark_range
    mov [esi + PROC_BRK], edx
    mov [current_user_brk], edx
    mov [user_brk_current], edx
    cmp byte [current_user_kind], USER_KIND_DOOM
    jne .sbrk_return
    inc dword [doom_sbrk_count]

.sbrk_return:
    jmp .return

.open:
    mov [syscall_ptr_arg], ebx
    mov [syscall_open_flags], ecx
    cmp byte [current_user_kind], USER_KIND_DOOM
    jne .open_skip_status
    mov [doom_last_open_flags], ecx
    mov [doom_last_open_mode], edx

.open_skip_status:
    mov eax, [syscall_open_flags]
    and eax, O_KNOWN_MASK
    cmp eax, [syscall_open_flags]
    jne .bad_syscall_einval
    mov eax, [syscall_open_flags]
    and eax, O_ACCMODE
    cmp eax, O_ACCMODE
    je .bad_syscall_einval
    test dword [syscall_open_flags], O_TRUNC | O_APPEND
    jz .open_flags_ok
    cmp eax, O_WRONLY
    je .open_flags_ok
    cmp eax, O_RDWR
    jne .bad_syscall_einval

.open_flags_ok:
    mov eax, ebx
    mov ebx, user_path_doom_wad_end - user_path_doom_wad
    mov edi, user_path_doom_wad
    call user_path_equals
    jc .open_writable
    test dword [syscall_open_flags], O_WRONLY | O_RDWR | O_TRUNC | O_APPEND
    jnz .bad_syscall_eacces
    cmp byte [wad_status], 1
    jne .bad_syscall_enoent
    call fd_alloc
    jc .bad_syscall_emfile
    mov byte [fd_kinds + eax], FD_KIND_WAD
    mov dword [fd_indices + eax * 4], 0
    mov dword [fd_offsets + eax * 4], 0
    mov edx, [syscall_open_flags]
    mov [fd_flags + eax * 4], edx
    add eax, USER_FD_BASE
    cmp byte [current_user_kind], USER_KIND_DOOM
    jne .open_return
    inc dword [doom_open_count]

.open_return:
    jmp .return

.open_writable:
    xor edx, edx

.open_writable_loop:
    cmp edx, WRITABLE_KNOWN_FILE_COUNT
    jae .open_generic_root83
    mov eax, [syscall_ptr_arg]
    mov ebx, [writable_path_len_table + edx * 4]
    mov edi, [writable_path_table + edx * 4]
    push edx
    call user_path_equals
    pop edx
    jnc .open_writable_found
    inc edx
    jmp .open_writable_loop

.open_writable_found:
    cmp byte [writable_status + edx], 1
    je .open_writable_ready
    test dword [syscall_open_flags], O_CREAT
    jz .bad_syscall_enoent
    mov edi, [writable_name_table + edx * 4]
    push edx
    call fat_find_file
    pop edx
    jnc .open_writable_bind_known
    mov edi, [writable_name_table + edx * 4]
    push edx
    call fat_create_root_file
    pop edx
    jc .bad_syscall_enomem

.open_writable_bind_known:
    mov ebx, edx
    call fat_bind_found_to_writable_slot
    jc .bad_syscall_enomem

.open_writable_ready:
    mov [fat_open_slot], edx
    call fd_alloc
    jc .bad_syscall_emfile
    mov [file_io_fd_slot], eax
    test dword [syscall_open_flags], O_TRUNC
    jz .open_writable_bind_reserved
    mov eax, [fat_open_slot]
    call fat_truncate_writable_file
    jc .open_writable_reserved_eio

.open_writable_bind_reserved:
    mov eax, [file_io_fd_slot]
    mov byte [fd_kinds + eax], FD_KIND_WRITABLE
    mov edx, [fat_open_slot]
    mov [fd_indices + eax * 4], edx
    mov dword [fd_offsets + eax * 4], 0
    test dword [syscall_open_flags], O_APPEND
    jz .open_writable_bind_flags
    mov ecx, [writable_sizes + edx * 4]
    mov [fd_offsets + eax * 4], ecx

.open_writable_bind_flags:
    mov ecx, [syscall_open_flags]
    mov [fd_flags + eax * 4], ecx
    add eax, USER_FD_BASE
    jmp .return

.open_writable_reserved_eio:
    mov eax, [file_io_fd_slot]
    mov byte [fd_status + eax], FD_KIND_FREE
    mov byte [fd_kinds + eax], FD_KIND_FREE
    mov dword [fd_indices + eax * 4], 0
    mov dword [fd_offsets + eax * 4], 0
    mov dword [fd_flags + eax * 4], 0
    mov dword [fd_owner_pids + eax * 4], 0xffffffff
    mov dword [fd_inherit_flags + eax * 4], 0
    jmp .bad_syscall_eio

.open_generic_root83:
    call fat_parse_user_root83
    jc .bad_syscall_einval
    call fat_open_name_is_protected
    jc .bad_syscall_eacces
    mov edi, fat_open_name_buffer
    call fat_find_file
    jnc .open_generic_found
    test dword [syscall_open_flags], O_CREAT
    jz .bad_syscall_enoent
    mov edi, fat_open_name_buffer
    call fat_create_root_file
    jc .bad_syscall_enomem

.open_generic_found:
    call fat_bind_found_writable_slot
    jc .bad_syscall_enomem
    mov edx, [fat_open_slot]
    jmp .open_writable_ready

.read:
    call fd_lookup
    jc .bad_syscall_ebadf
    cmp byte [fd_kinds + eax], FD_KIND_WAD
    je .read_wad
    call user_file_read
    jc .bad_syscall_from_eax
    jmp .return

.read_wad:
    mov [syscall_ptr_arg], ecx
    mov [syscall_len_arg], edx
    mov eax, ecx
    mov ebx, edx
    call user_range_validate
    jc .bad_syscall_einval
    mov eax, [wad_size]
    mov esi, [file_io_fd_slot]
    sub eax, [fd_offsets + esi * 4]
    cmp edx, eax
    jbe .read_len_ok
    mov edx, eax
    mov [syscall_len_arg], edx

.read_len_ok:
    mov esi, WAD_LOAD_ADDR
    mov eax, [file_io_fd_slot]
    add esi, [fd_offsets + eax * 4]
    mov edi, [syscall_ptr_arg]
    mov ecx, [syscall_len_arg]
    cld
    rep movsb
    mov eax, [syscall_len_arg]
    mov esi, [file_io_fd_slot]
    add [fd_offsets + esi * 4], eax
    cmp eax, 4
    jb .read_done
    mov edi, [syscall_ptr_arg]
    mov edx, [edi]
    mov [user_wad_magic_seen], edx
    cmp byte [current_user_kind], USER_KIND_DOOM
    jne .read_done
    cmp dword [doom_wad_magic_seen], 0
    jne .read_done
    mov [doom_wad_magic_seen], edx

.read_done:
    cmp byte [current_user_kind], USER_KIND_DOOM
    jne .read_return
    cmp eax, 0
    je .read_return
    inc dword [doom_read_count]

.read_return:
    jmp .return

.lseek:
    call fd_lookup
    jc .bad_syscall_ebadf
    cmp byte [fd_kinds + eax], FD_KIND_WAD
    je .lseek_wad
    call user_file_lseek
    jc .bad_syscall_from_eax
    jmp .return

.lseek_wad:
    cmp edx, 0
    je .seek_set
    cmp edx, 1
    je .seek_cur
    cmp edx, 2
    je .seek_end
    jmp .bad_syscall_einval

.seek_set:
    mov eax, ecx
    jmp .seek_validate

.seek_cur:
    mov esi, [file_io_fd_slot]
    mov eax, [fd_offsets + esi * 4]
    add eax, ecx
    jc .bad_syscall_einval
    jmp .seek_validate

.seek_end:
    mov eax, [wad_size]
    add eax, ecx
    jc .bad_syscall_einval

.seek_validate:
    cmp eax, [wad_size]
    ja .bad_syscall_einval
    mov esi, [file_io_fd_slot]
    mov [fd_offsets + esi * 4], eax
    cmp byte [current_user_kind], USER_KIND_DOOM
    jne .seek_return
    inc dword [doom_lseek_count]

.seek_return:
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
    jc .bad_syscall_einval
    mov eax, [present_palette_arg]
    mov ebx, DOOM_PALETTE_BYTES
    call user_range_validate
    jc .bad_syscall_einval
    call present_indexed_frame
    jc .bad_syscall_eio
    cmp byte [current_user_kind], USER_KIND_DOOM
    jne .present_return
    inc dword [doom_present_count]

.present_return:
    xor eax, eax
    jmp .return

.poll_key:
    mov ebx, [key_event_tail]
    cmp ebx, [key_event_head]
    je .poll_key_empty
    mov edi, key_event_queue
    mov eax, [edi + ebx * 4]
    inc ebx
    and ebx, KEY_QUEUE_MASK
    mov [key_event_tail], ebx
    cmp byte [current_user_kind], USER_KIND_DOOM
    jne .return
    call doom_record_key_event
    inc dword [doom_key_event_count]
    jmp .return

.poll_key_empty:
    xor eax, eax
    jmp .return

.poll_mouse:
    mov ebx, [mouse_event_tail]
    cmp ebx, [mouse_event_head]
    je .poll_mouse_empty
    mov edi, mouse_event_queue
    mov eax, [edi + ebx * 4]
    inc ebx
    and ebx, MOUSE_QUEUE_MASK
    mov [mouse_event_tail], ebx
    cmp byte [current_user_kind], USER_KIND_DOOM
    jne .return
    call doom_record_mouse_event
    inc dword [doom_mouse_event_count]
    jmp .return

.poll_mouse_empty:
    xor eax, eax
    jmp .return

.close:
    call fd_lookup
    jc .bad_syscall_ebadf
    mov byte [fd_status + eax], FD_KIND_FREE
    mov byte [fd_kinds + eax], FD_KIND_FREE
    mov dword [fd_indices + eax * 4], 0
    mov dword [fd_offsets + eax * 4], 0
    mov dword [fd_flags + eax * 4], 0
    mov dword [fd_owner_pids + eax * 4], 0xffffffff
    mov dword [fd_inherit_flags + eax * 4], 0

.close_ok:
    cmp byte [current_user_kind], USER_KIND_DOOM
    jne .close_return
    inc dword [doom_close_count]

.close_return:
    xor eax, eax
    jmp .return

.audio:
    cmp byte [current_user_kind], USER_KIND_DOOM
    jne .audio_status
    inc dword [doom_sound_call_count]
    mov [doom_sound_last_command], ebx
    mov [doom_sound_last_handle], ecx
    mov [doom_sound_last_packed], edx
    cmp ebx, AUDIO_CMD_INIT
    je .audio_init_cmd
    cmp ebx, AUDIO_CMD_START_SFX
    je .audio_start_sfx
    cmp ebx, AUDIO_CMD_STOP_SFX
    je .audio_stop_sfx
    cmp ebx, AUDIO_CMD_UPDATE_SFX
    je .audio_update_sfx
    cmp ebx, AUDIO_CMD_SHUTDOWN
    je .audio_shutdown_cmd
    cmp ebx, AUDIO_CMD_IS_PLAYING
    je .audio_is_playing
    cmp ebx, AUDIO_CMD_BUFFERED_BYTES
    je .audio_buffered_bytes
    cmp ebx, AUDIO_CMD_MUSIC_PULL_STATE
    je .audio_music_pull_state
    jmp .audio_status

.audio_init_cmd:
    call sb16_start_playback
    jmp .audio_status

.audio_start_sfx:
    inc dword [doom_sound_start_count]
    mov [audio_sfx_handle_arg], ecx
    mov [audio_sfx_desc_arg], edx
    call sb16_start_playback
    call audio_register_sfx_voice
    jmp .audio_status

.audio_stop_sfx:
    inc dword [doom_sound_stop_count]
    mov [audio_sfx_handle_arg], ecx
    call audio_stop_sfx_voice
    jmp .audio_status

.audio_update_sfx:
    inc dword [doom_sound_update_count]
    mov [audio_sfx_handle_arg], ecx
    mov [audio_sfx_desc_arg], edx
    call audio_update_sfx_voice
    jmp .audio_status

.audio_shutdown_cmd:
    call sb16_stop_playback
    jmp .audio_status

.audio_is_playing:
    mov [audio_sfx_handle_arg], ecx
    call sb16_find_voice_by_handle
    jc .audio_not_playing
    mov eax, 1
    jmp .return

.audio_not_playing:
    xor eax, eax
    jmp .return

.audio_buffered_bytes:
    mov [audio_sfx_handle_arg], ecx
    call sb16_find_voice_by_handle
    jc .audio_not_playing
    mov ebx, eax
    mov edx, [sb16_voice_positions + ebx * 4]
    shr edx, 16
    mov eax, [sb16_voice_lengths + ebx * 4]
    cmp eax, edx
    jbe .audio_pending_only
    sub eax, edx
    jmp .audio_add_pending

.audio_pending_only:
    xor eax, eax

.audio_add_pending:
    add eax, [sb16_voice_pending_lengths + ebx * 4]
    jmp .return

.audio_music_pull_state:
    mov [audio_sfx_handle_arg], ecx
    call sb16_find_voice_by_handle
    jc .audio_no_pull_state
    mov ebx, eax
    test dword [sb16_voice_flags + ebx * 4], AUDIO_FLAG_MUSIC
    jz .audio_no_pull_state
    mov eax, [sb16_music_pull_request_count]
    jmp .return

.audio_no_pull_state:
    xor eax, eax
    jmp .return

.audio_status:
    movzx eax, byte [audio_status]
    jmp .return

.gameplay_status:
    cmp byte [current_user_kind], USER_KIND_DOOM
    jne .gameplay_return
    test ebx, DOOM_INIT_STATUS_FLAG
    jnz .doom_init_status
    test ebx, SAVELOAD_STATUS_FLAG
    jnz .saveload_status
    test ebx, SAVEACTION_STATUS_FLAG
    jnz .saveaction_status
    test ebx, PLAYABLE_STATUS_FLAG
    jnz .playable_status
    inc dword [doom_gameplay_report_count]
    mov [doom_game_state_packed], ebx
    mov eax, ebx
    and eax, 0xff
    mov [doom_game_state], eax
    mov eax, ebx
    shr eax, 8
    and eax, 0xff
    mov [doom_game_episode], eax
    mov eax, ebx
    shr eax, 16
    and eax, 0xff
    mov [doom_game_map], eax
    mov eax, ebx
    shr eax, 24
    mov [doom_game_flags], eax
    mov eax, [doom_game_episode]
    shl eax, 8
    or eax, [doom_game_map]
    mov [doom_game_map_pair], eax
    mov [doom_game_tic], ecx
    mov [doom_level_time], edx
    cmp dword [doom_game_state], 0
    jne .gameplay_return
    cmp dword [doom_game_episode], 0
    je .gameplay_return
    cmp dword [doom_game_map], 0
    je .gameplay_return
    cmp ecx, 0
    je .gameplay_return
    cmp edx, 0
    je .gameplay_return
    mov byte [doom_gameplay_status], 1
    jmp .gameplay_return

.doom_init_status:
    mov eax, ebx
    and eax, 0x0000ffff
    or [doom_init_flags], eax
    inc dword [doom_init_report_count]
    jmp .gameplay_return

.saveload_status:
    mov esi, ebx
    and esi, 0x0000ffff
    or [doom_saveload_flags], esi
    mov eax, ebx
    shr eax, SAVELOAD_SLOT_SHIFT
    and eax, 0xff
    mov [doom_saveload_slot], eax
    test esi, SAVELOAD_EVENT_OPEN
    jz .saveload_read
    inc dword [doom_saveload_open_count]
    mov [doom_saveload_last_open_flags], ecx
    mov [doom_saveload_last_open_mode], edx

.saveload_read:
    test esi, SAVELOAD_EVENT_READ
    jz .saveload_write
    inc dword [doom_saveload_read_count]
    add [doom_saveload_read_bytes], ecx

.saveload_write:
    test esi, SAVELOAD_EVENT_WRITE
    jz .saveload_close
    inc dword [doom_saveload_write_count]
    add [doom_saveload_write_bytes], ecx

.saveload_close:
    test esi, SAVELOAD_EVENT_CLOSE
    jz .gameplay_return
    inc dword [doom_saveload_close_count]
    jmp .gameplay_return

.saveaction_status:
    inc dword [doom_saveaction_report_count]
    mov eax, ebx
    and eax, 0x000000ff
    mov [doom_saveaction_flags], eax
    mov eax, ebx
    shr eax, SAVEACTION_GAMEACTION_SHIFT
    and eax, 0x000000ff
    mov [doom_saveaction_gameaction], eax
    mov eax, ebx
    shr eax, SAVEACTION_SLOT_SHIFT
    and eax, 0x000000ff
    mov [doom_saveaction_slot], eax
    mov [doom_saveaction_desc_hash], ecx
    mov [doom_saveaction_desc_len], edx
    jmp .gameplay_return

.playable_status:
    mov eax, ebx
    and eax, 0x0000ffff
    mov [doom_player_flags], eax
    mov eax, ebx
    shr eax, 16
    and eax, 0xff
    mov [doom_player_buttons], eax
    mov eax, ebx
    shr eax, 24
    and eax, 0x7f
    mov [doom_game_action], eax
    mov [doom_player_x], ecx
    mov [doom_player_y], edx
    cmp dword [doom_player_origin_set], 0
    jne .playable_delta
    mov dword [doom_player_origin_set], 1
    mov [doom_player_origin_x], ecx
    mov [doom_player_origin_y], edx

.playable_delta:
    mov eax, ecx
    sub eax, [doom_player_origin_x]
    jns .playable_dx_ok
    neg eax

.playable_dx_ok:
    mov esi, eax
    mov eax, edx
    sub eax, [doom_player_origin_y]
    jns .playable_dy_ok
    neg eax

.playable_dy_ok:
    add eax, esi
    cmp eax, [doom_player_delta]
    jbe .gameplay_return
    mov [doom_player_delta], eax
    jmp .gameplay_return

.player_detail_status:
    cmp byte [current_user_kind], USER_KIND_DOOM
    jne .gameplay_return
    mov [doom_player_cmd], ebx
    mov [doom_player_angle], ecx
    mov eax, edx
    and eax, 0x0000ffff
    mov [doom_player_ammo], eax
    mov eax, edx
    shr eax, 16
    and eax, 0xff
    mov [doom_player_refire], eax
    mov eax, edx
    shr eax, 24
    and eax, 0xff
    mov [doom_player_weapon], eax
    cmp dword [doom_player_angle_origin_set], 0
    jne .player_angle_delta
    mov dword [doom_player_angle_origin_set], 1
    mov [doom_player_origin_angle], ecx

.player_angle_delta:
    mov eax, ecx
    xor eax, [doom_player_origin_angle]
    or [doom_player_angle_delta], eax
    jmp .gameplay_return

.gameplay_return:
    xor eax, eax
    jmp .return

.unlink:
    mov [syscall_ptr_arg], ebx
    call fat_parse_user_root83
    jc .bad_syscall_einval
    call fat_open_name_is_protected
    jc .bad_syscall_eacces
    mov edi, fat_open_name_buffer
    call fat_find_file
    jc .bad_syscall_enoent
    mov dword [fat_unlink_slot], 0xffffffff
    call fat_find_writable_slot_for_found
    jc .unlink_delete
    mov [fat_unlink_slot], eax

.unlink_delete:
    call fat_delete_found_file
    jc .bad_syscall_eio
    mov eax, [fat_unlink_slot]
    cmp eax, 0xffffffff
    je .unlink_ok
    call fat_close_writable_fds_for_slot
    mov eax, [fat_unlink_slot]
    call fat_clear_writable_slot

.unlink_ok:
    xor eax, eax
    jmp .return

.stat:
    mov [syscall_ptr_arg], ebx
    mov [syscall_stat_ptr], ecx
    mov eax, ebx
    mov ebx, user_path_doom_wad_end - user_path_doom_wad
    mov edi, user_path_doom_wad
    call user_path_equals
    jnc .stat_wad
    call fat_parse_user_root83
    jc .bad_syscall_einval
    mov esi, fat_open_name_buffer
    mov edi, wad_name_83
    call fat_name_match
    cmp al, 1
    je .stat_wad
    mov esi, fat_open_name_buffer
    mov edi, user_elf_name_83
    call fat_name_match
    cmp al, 1
    je .stat_user_elf
    mov esi, fat_open_name_buffer
    mov edi, doom_elf_name_83
    call fat_name_match
    cmp al, 1
    je .stat_doom_elf
    call fat_open_name_marker_index
    jnc .stat_persistence_marker
    mov edi, fat_open_name_buffer
    call fat_find_file
    jc .bad_syscall_enoent
    mov eax, [fat_found_size]
    mov edx, STAT_MODE_WRITABLE_REG
    call stat_fill_user
    jc .bad_syscall_einval
    xor eax, eax
    jmp .return

.stat_wad:
    mov edi, wad_name_83
    call fat_find_file
    jc .bad_syscall_enoent
    mov eax, [fat_found_size]
    mov edx, STAT_MODE_READONLY_REG
    call stat_fill_user
    jc .bad_syscall_einval
    xor eax, eax
    jmp .return

.stat_user_elf:
    mov edi, user_elf_name_83
    call fat_find_file
    jc .bad_syscall_enoent
    mov eax, [fat_found_size]
    mov edx, STAT_MODE_READONLY_REG
    call stat_fill_user
    jc .bad_syscall_einval
    xor eax, eax
    jmp .return

.stat_doom_elf:
    mov edi, doom_elf_name_83
    call fat_find_file
    jc .bad_syscall_enoent
    mov eax, [fat_found_size]
    mov edx, STAT_MODE_READONLY_REG
    call stat_fill_user
    jc .bad_syscall_einval
    xor eax, eax
    jmp .return

.stat_persistence_marker:
    cmp byte [persistence_marker_status + eax], 1
    jne .bad_syscall_enoent
    mov eax, [persistence_marker_sizes + eax * 4]
    mov edx, STAT_MODE_READONLY_REG
    call stat_fill_user
    jc .bad_syscall_einval
    xor eax, eax
    jmp .return

.fstat:
    mov [syscall_stat_ptr], ecx
    call fd_lookup
    jc .bad_syscall_ebadf
    cmp byte [fd_kinds + eax], FD_KIND_WAD
    je .fstat_wad
    cmp byte [fd_kinds + eax], FD_KIND_WRITABLE
    jne .bad_syscall_ebadf
    mov ebx, [fd_indices + eax * 4]
    cmp ebx, WRITABLE_FILE_COUNT
    jae .bad_syscall_ebadf
    cmp byte [writable_status + ebx], 1
    jne .bad_syscall_ebadf
    mov eax, [writable_sizes + ebx * 4]
    mov edx, STAT_MODE_WRITABLE_REG
    call stat_fill_user
    jc .bad_syscall_einval
    xor eax, eax
    jmp .return

.fstat_wad:
    mov eax, [wad_size]
    mov edx, STAT_MODE_READONLY_REG
    call stat_fill_user
    jc .bad_syscall_einval
    xor eax, eax
    jmp .return

.mmap:
    mov [mmap_addr_arg], ebx
    mov [mmap_len_arg], ecx
    mov eax, edx
    and eax, MMAP_PROT_MASK
    mov [mmap_prot_arg], eax
    mov eax, edx
    shr eax, MMAP_FLAGS_SHIFT
    mov [mmap_flags_arg], eax
    cmp dword [mmap_addr_arg], 0
    jne .bad_syscall_einval
    cmp dword [mmap_len_arg], 0
    je .bad_syscall_einval
    cmp dword [mmap_prot_arg], 0
    je .bad_syscall_einval
    mov eax, [mmap_prot_arg]
    and eax, 0xfffffff8
    jnz .bad_syscall_einval
    test dword [mmap_flags_arg], MMAP_MAP_FIXED
    jnz .bad_syscall_einval
    test dword [mmap_flags_arg], MMAP_MAP_ANONYMOUS
    jz .bad_syscall_einval
    test dword [mmap_flags_arg], MMAP_MAP_PRIVATE
    jz .bad_syscall_einval
    mov eax, [mmap_flags_arg]
    and eax, 0xffffffdd
    jnz .bad_syscall_einval
    mov eax, [mmap_len_arg]
    add eax, PAGE_SIZE - 1
    jc .bad_syscall_enomem
    and eax, 0xfffff000
    mov [mmap_len_arg], eax
    mov esi, [current_process_ptr]
    cmp esi, 0
    je .bad_syscall_enomem
    mov eax, [esi + PROC_BRK]
    mov [mmap_base_arg], eax
    mov edx, eax
    add edx, [mmap_len_arg]
    jc .bad_syscall_enomem
    cmp edx, [esi + PROC_HEAP_END]
    ja .bad_syscall_enomem
    mov [mmap_end_arg], edx
    mov ebx, [esi + PROC_PAGE_DIR]
    test ebx, ebx
    jnz .mmap_have_page_dir
    mov ebx, PAGING_DIR_ADDR

.mmap_have_page_dir:
    test dword [mmap_prot_arg], MMAP_PROT_WRITE
    jz .mmap_readonly
    call vmm_mark_process_user_write_range
    jmp .mmap_flush

.mmap_readonly:
    call vmm_mark_process_user_read_range

.mmap_flush:
    mov ebx, [esi + PROC_PAGE_DIR]
    test ebx, ebx
    jz .mmap_zero
    mov cr3, ebx

.mmap_zero:
    mov edi, [mmap_base_arg]
    mov ecx, [mmap_len_arg]
    shr ecx, 2
    xor eax, eax
    cld
    rep stosd
    mov eax, [mmap_base_arg]
    mov edx, [mmap_end_arg]
    call process_heap_mark_range
    mov edx, [mmap_end_arg]
    mov [esi + PROC_BRK], edx
    mov [current_user_brk], edx
    mov [user_brk_current], edx
    mov eax, [mmap_len_arg]
    shr eax, 12
    add [process_mmap_pages_mapped], eax
    inc dword [process_mmap_allocations]
    mov eax, [mmap_base_arg]
    cmp byte [current_user_kind], USER_KIND_DOOM
    jne .return
    inc dword [doom_sbrk_count]
    jmp .return

.munmap:
    inc dword [process_munmap_attempts]
    cmp ebx, 0
    je .bad_syscall_einval
    cmp ecx, 0
    je .bad_syscall_einval
    mov eax, ebx
    and eax, PAGE_SIZE - 1
    jnz .bad_syscall_einval
    mov [mmap_base_arg], ebx
    mov eax, ecx
    add eax, PAGE_SIZE - 1
    jc .bad_syscall_einval
    and eax, 0xfffff000
    mov [mmap_len_arg], eax
    mov eax, ebx
    add eax, [mmap_len_arg]
    jc .bad_syscall_einval
    mov [mmap_end_arg], eax
    mov eax, [mmap_base_arg]
    mov ebx, [mmap_len_arg]
    call user_range_validate
    jc .bad_syscall_einval
    mov esi, [current_process_ptr]
    cmp esi, 0
    je .bad_syscall_einval
    mov eax, [mmap_base_arg]
    mov [process_last_munmap_base], eax
    mov eax, [mmap_end_arg]
    mov [process_last_munmap_end], eax
    cmp eax, [esi + PROC_BRK]
    jne .munmap_keep_non_tail
    mov ebx, [esi + PROC_PAGE_DIR]
    test ebx, ebx
    jnz .munmap_have_page_dir
    mov ebx, PAGING_DIR_ADDR

.munmap_have_page_dir:
    mov eax, [mmap_base_arg]
    mov edx, [mmap_end_arg]
    call process_clear_user_range
    mov ebx, [esi + PROC_PAGE_DIR]
    test ebx, ebx
    jz .munmap_update_brk
    mov cr3, ebx

.munmap_update_brk:
    mov eax, [mmap_base_arg]
    mov [esi + PROC_BRK], eax
    mov [current_user_brk], eax
    mov [user_brk_current], eax
    mov eax, [mmap_len_arg]
    shr eax, 12
    add [process_munmap_pages_released], eax
    xor eax, eax
    jmp .return

.munmap_keep_non_tail:
    inc dword [process_munmap_non_tail_kept]
    mov ebx, [esi + PROC_PAGE_DIR]
    test ebx, ebx
    jnz .munmap_non_tail_have_page_dir
    mov ebx, PAGING_DIR_ADDR

.munmap_non_tail_have_page_dir:
    mov eax, [mmap_base_arg]
    mov edx, [mmap_end_arg]
    call process_clear_user_range
    mov ebx, [esi + PROC_PAGE_DIR]
    test ebx, ebx
    jz .munmap_non_tail_account
    mov cr3, ebx

.munmap_non_tail_account:
    inc dword [process_munmap_holes_punched]
    mov eax, [mmap_len_arg]
    shr eax, 12
    add [process_munmap_pages_unmapped], eax
    xor eax, eax
    jmp .return

.ioctl:
    cmp ebx, IOCTL_DISPLAY_FD
    jne .bad_syscall_enotty
    cmp ecx, VIBE_IOCTL_FBINFO
    je .ioctl_fbinfo
    cmp ecx, VIBE_IOCTL_PRESENT_INDEXED
    je .ioctl_present_indexed
    jmp .bad_syscall_enotty

.ioctl_fbinfo:
    mov [syscall_ptr_arg], edx
    mov eax, edx
    mov ebx, VIBE_FB_INFO_BYTES
    call user_range_validate
    jc .bad_syscall_einval
    mov edi, [syscall_ptr_arg]
    mov eax, [framebuffer_width]
    mov [edi + VIBE_FB_INFO_WIDTH], eax
    mov eax, [framebuffer_height]
    mov [edi + VIBE_FB_INFO_HEIGHT], eax
    mov eax, [framebuffer_pitch]
    mov [edi + VIBE_FB_INFO_PITCH], eax
    movzx eax, byte [video_backend]
    mov [edi + VIBE_FB_INFO_BACKEND], eax
    mov dword [edi + VIBE_FB_INFO_FRAME_BYTES], DOOM_FRAME_BYTES
    mov dword [edi + VIBE_FB_INFO_PALETTE_BYTES], DOOM_PALETTE_BYTES
    mov eax, [present_lfb_scale]
    mov [edi + VIBE_FB_INFO_SCALE], eax
    mov eax, [present_lfb_view_x]
    mov [edi + VIBE_FB_INFO_VIEW_X], eax
    mov eax, [present_lfb_view_y]
    mov [edi + VIBE_FB_INFO_VIEW_Y], eax
    mov eax, [present_lfb_view_width]
    mov [edi + VIBE_FB_INFO_VIEW_WIDTH], eax
    mov eax, [present_lfb_view_height]
    mov [edi + VIBE_FB_INFO_VIEW_HEIGHT], eax
    mov eax, [present_lfb_policy]
    mov [edi + VIBE_FB_INFO_POLICY], eax
    mov eax, [present_dirty_x]
    mov [edi + VIBE_FB_INFO_DIRTY_X], eax
    mov eax, [present_dirty_y]
    mov [edi + VIBE_FB_INFO_DIRTY_Y], eax
    mov eax, [present_dirty_width]
    mov [edi + VIBE_FB_INFO_DIRTY_WIDTH], eax
    mov eax, [present_dirty_height]
    mov [edi + VIBE_FB_INFO_DIRTY_HEIGHT], eax
    mov eax, [present_dirty_count]
    mov [edi + VIBE_FB_INFO_DIRTY_COUNT], eax
    xor eax, eax
    jmp .return

.ioctl_present_indexed:
    mov [syscall_ptr_arg], edx
    mov eax, edx
    mov ebx, VIBE_PRESENT_DESC_BYTES
    call user_range_validate
    jc .bad_syscall_einval
    mov esi, [syscall_ptr_arg]
    cmp dword [esi + VIBE_PRESENT_DESC_WIDTH], DOOM_SCREEN_WIDTH
    jne .bad_syscall_einval
    cmp dword [esi + VIBE_PRESENT_DESC_HEIGHT], DOOM_SCREEN_HEIGHT
    jne .bad_syscall_einval
    mov eax, [esi + VIBE_PRESENT_DESC_FRAME]
    mov [present_frame_arg], eax
    mov eax, [esi + VIBE_PRESENT_DESC_PALETTE]
    mov [present_palette_arg], eax
    mov eax, [present_frame_arg]
    mov ebx, DOOM_FRAME_BYTES
    call user_range_validate
    jc .bad_syscall_einval
    mov eax, [present_palette_arg]
    mov ebx, DOOM_PALETTE_BYTES
    call user_range_validate
    jc .bad_syscall_einval
    call present_indexed_frame
    jc .bad_syscall_eio
    cmp byte [current_user_kind], USER_KIND_DOOM
    jne .ioctl_present_return
    inc dword [doom_present_count]

.ioctl_present_return:
    xor eax, eax
    jmp .return

.fork:
    jmp .bad_syscall_enosys

.waitpid:
    call process_waitpid_current
    jc .bad_syscall_from_eax
    jmp .return

.getpid:
    mov eax, [current_pid]
    jmp .return

.exec:
    mov [syscall_ptr_arg], ebx
    mov [sys_exec_user_argv_arg], ecx
    mov [sys_exec_flags_arg], edx
    mov [sys_exec_frame_ptr], esp
    mov dword [process_exec_path_ptr], 0
    mov dword [process_exec_target], 0
    mov dword [process_exec_entry], 0
    mov dword [process_exec_last_error], 0
    mov dword [sys_exec_last_parent_pid], 0xffffffff
    mov dword [sys_exec_last_target_pid], 0xffffffff
    mov dword [sys_exec_last_target_entry], 0
    mov dword [sys_exec_last_target_stack], 0
    mov dword [sys_exec_last_argc], 0
    mov dword [sys_exec_last_argv], 0
    mov dword [sys_exec_last_envp], 0
    mov dword [sys_exec_last_argv0], 0
    mov dword [sys_exec_last_envp0], 0
    mov dword [sys_exec_last_argv_source], 0
    inc dword [sys_exec_attempts]
    cmp dword [sys_exec_flags_arg], 0
    jne .exec_einval
    call sys_exec_copy_user_path
    jc .exec_einval
    call sys_exec_copy_argv
    jc .exec_einval
    mov esi, sys_exec_path_buffer
    xor edi, edi
    mov byte [process_exec_reject_active_target], 1
    call process_exec_path
    mov byte [process_exec_reject_active_target], 0
    jc .exec_path_failed
    call process_exec_handoff_current
    jc .exec_path_failed
    inc dword [sys_exec_successes]
    xor eax, eax
    mov [sys_exec_last_result], eax
    jmp .exec_handoff_return

.exec_einval:
    mov dword [process_exec_last_error], -ERRNO_EINVAL
    mov eax, -ERRNO_EINVAL
    jmp .exec_fail

.exec_path_failed:
    mov byte [process_exec_reject_active_target], 0
    mov eax, [process_exec_last_error]
    cmp eax, 0
    jne .exec_fail
    mov eax, -ERRNO_ENOENT

.exec_fail:
    inc dword [sys_exec_failures]
    inc dword [sys_exec_rollbacks]
    mov [sys_exec_last_result], eax
    jmp .bad_syscall_return

.exec_handoff_return:
    xor eax, eax
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    iretd

.bad_syscall:
    mov eax, 0xffffffff
    jmp .bad_syscall_return

.bad_syscall_from_eax:
    jmp .bad_syscall_return

.bad_syscall_enoent:
    mov eax, -ERRNO_ENOENT
    jmp .bad_syscall_return

.bad_syscall_eio:
    mov eax, -ERRNO_EIO
    jmp .bad_syscall_return

.bad_syscall_ebadf:
    mov eax, -ERRNO_EBADF
    jmp .bad_syscall_return

.bad_syscall_enomem:
    mov eax, -ERRNO_ENOMEM
    jmp .bad_syscall_return

.bad_syscall_eacces:
    mov eax, -ERRNO_EACCES
    jmp .bad_syscall_return

.bad_syscall_einval:
    mov eax, -ERRNO_EINVAL
    jmp .bad_syscall_return

.bad_syscall_emfile:
    mov eax, -ERRNO_EMFILE
    jmp .bad_syscall_return

.bad_syscall_enotty:
    mov eax, -ERRNO_ENOTTY
    jmp .bad_syscall_return

.bad_syscall_echild:
    mov eax, -ERRNO_ECHILD
    jmp .bad_syscall_return

.bad_syscall_enosys:
    mov eax, -ERRNO_ENOSYS
    jmp .bad_syscall_return

.bad_syscall_return:
    cmp byte [current_user_kind], USER_KIND_DOOM
    jne .return
    inc dword [doom_error_count]
    mov [doom_last_error], eax
    jmp .return

.exit:
    cmp byte [current_user_kind], USER_KIND_DOOM
    je .doom_exit
    mov byte [user_probe_status], 2
    call process_mark_current_exited
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, KERNEL_STACK_TOP
    jmp user_probe_finished

.doom_exit:
    mov [doom_exit_code], ebx
    mov byte [doom_run_status], 2
    call process_mark_current_exited
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, KERNEL_STACK_TOP
    jmp doom_user_finished

.return:
    mov [syscall_return_value], eax
    call process_save_syscall_return_context
    mov eax, [syscall_return_value]
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    iretd

sys_exec_copy_user_path:
    push eax
    push ebx
    push ecx
    push esi
    push edi

    mov edi, sys_exec_path_buffer
    xor eax, eax
    mov ecx, SYS_EXEC_PATH_MAX
    cld
    rep stosb

    mov esi, [syscall_ptr_arg]
    cmp esi, 0
    je .fail
    mov edi, sys_exec_path_buffer
    xor ecx, ecx

.next:
    mov eax, esi
    add eax, ecx
    jc .fail
    mov ebx, 1
    call user_range_validate
    jc .fail
    mov al, [esi + ecx]
    mov [edi + ecx], al
    test al, al
    jz .ok
    inc ecx
    cmp ecx, SYS_EXEC_PATH_MAX - 1
    jb .next
    mov byte [sys_exec_path_buffer + SYS_EXEC_PATH_MAX - 1], 0

.fail:
    stc
    jmp .done

.ok:
    clc

.done:
    pop edi
    pop esi
    pop ecx
    pop ebx
    pop eax
    ret

sys_exec_clear_args:
    push eax
    push ecx
    push edi
    mov dword [sys_exec_argc], 0
    mov dword [sys_exec_arg_copy_index], 0
    mov dword [sys_exec_stack_cursor], 0
    mov dword [sys_exec_user_stack_ptr], 0
    mov dword [sys_exec_argv0_ptr], 0
    mov dword [sys_exec_last_argv_source], 0
    mov edi, sys_exec_arg_target_ptrs
    xor eax, eax
    mov ecx, SYS_EXEC_ARG_MAX
    cld
    rep stosd
    mov edi, sys_exec_arg_strings
    mov ecx, SYS_EXEC_ARG_MAX * SYS_EXEC_ARG_STR_MAX
    rep stosb
    pop edi
    pop ecx
    pop eax
    ret

sys_exec_stage_kernel_arg:
    push eax
    push ecx
    push esi
    push edi

    call sys_exec_clear_args
    mov edi, sys_exec_arg_strings
    mov ecx, SYS_EXEC_ARG_STR_MAX

.copy:
    cmp ecx, 0
    je .too_long
    lodsb
    stosb
    dec ecx
    test al, al
    jz .ok
    jmp .copy

.too_long:
    mov byte [sys_exec_arg_strings + SYS_EXEC_ARG_STR_MAX - 1], 0
    stc
    jmp .done

.ok:
    mov dword [sys_exec_argc], SYS_EXEC_ARGC_DEFAULT
    mov dword [sys_exec_last_argv_source], SYS_EXEC_ARGV_SOURCE_DEFAULT
    clc

.done:
    pop edi
    pop esi
    pop ecx
    pop eax
    ret

sys_exec_copy_argv:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    call sys_exec_clear_args
    cmp dword [sys_exec_user_argv_arg], 0
    jne .copy_user_argv

    mov esi, sys_exec_path_buffer
    mov edi, sys_exec_arg_strings
    mov ecx, SYS_EXEC_PATH_MAX
    cld
    rep movsb
    mov dword [sys_exec_argc], SYS_EXEC_ARGC_DEFAULT
    mov dword [sys_exec_last_argv_source], SYS_EXEC_ARGV_SOURCE_DEFAULT
    clc
    jmp .done

.copy_user_argv:
    mov dword [sys_exec_arg_copy_index], 0

.argv_loop:
    mov ecx, [sys_exec_arg_copy_index]
    cmp ecx, SYS_EXEC_ARG_MAX
    jae .fail
    mov eax, [sys_exec_user_argv_arg]
    mov edx, ecx
    shl edx, 2
    add eax, edx
    jc .fail
    mov ebx, 4
    call user_range_validate
    jc .fail
    mov esi, [eax]
    cmp esi, 0
    je .argv_done
    mov edi, sys_exec_arg_strings
    mov edx, ecx
    shl edx, 6
    add edi, edx
    call sys_exec_copy_user_arg_string
    jc .fail
    inc dword [sys_exec_arg_copy_index]
    jmp .argv_loop

.argv_done:
    cmp dword [sys_exec_arg_copy_index], 0
    je .fail
    mov eax, [sys_exec_arg_copy_index]
    mov [sys_exec_argc], eax
    mov dword [sys_exec_last_argv_source], SYS_EXEC_ARGV_SOURCE_USER
    clc
    jmp .done

.fail:
    stc

.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

sys_exec_copy_user_arg_string:
    push eax
    push ebx
    push ecx
    push esi
    push edi

    xor ecx, ecx

.next:
    mov eax, esi
    add eax, ecx
    jc .fail
    mov ebx, 1
    call user_range_validate
    jc .fail
    mov al, [esi + ecx]
    mov [edi + ecx], al
    test al, al
    jz .ok
    inc ecx
    cmp ecx, SYS_EXEC_ARG_STR_MAX - 1
    jb .next
    mov byte [edi + SYS_EXEC_ARG_STR_MAX - 1], 0

.fail:
    stc
    jmp .done

.ok:
    clc

.done:
    pop edi
    pop esi
    pop ecx
    pop ebx
    pop eax
    ret

user_range_validate:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    mov esi, [current_process_ptr]
    cmp esi, 0
    je .fail
    cmp ebx, 0
    je .ok
    mov edx, eax
    add edx, ebx
    jc .fail
    mov edi, [esi + PROC_VM_REGIONS]
    mov ecx, [esi + PROC_VM_REGION_COUNT]

.region_next:
    cmp ecx, 0
    je .fail
    cmp eax, [edi + VM_REGION_BASE]
    jb .region_advance
    mov ebx, [edi + VM_REGION_END]
    test dword [edi + VM_REGION_FLAGS], VM_REGION_HEAP
    jz .region_end_ready
    mov ebx, [esi + PROC_BRK]

.region_end_ready:
    cmp edx, ebx
    ja .region_advance
    test dword [edi + VM_REGION_FLAGS], VM_REGION_HEAP
    jz .ok
    call process_heap_range_is_mapped
    jc .fail
    jmp .ok

.region_advance:
    add edi, VM_REGION_BYTES
    dec ecx
    jmp .region_next

.ok:
    clc
    jmp .done

.fail:
    stc

.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

doom_log_char:
    push eax
    push ebx
    push ecx
    push esi
    push edi

    cmp al, 13
    je .space
    cmp al, 10
    je .space
    cmp al, 9
    je .space
    cmp al, 32
    jb .space
    cmp al, 126
    jbe .have_char

.space:
    mov al, ' '

.have_char:
    mov bl, al
    mov eax, [doom_log_len]
    cmp eax, DOOM_LOG_BYTES - 1
    jb .append

    mov esi, doom_log_buffer + 1
    mov edi, doom_log_buffer
    mov ecx, DOOM_LOG_BYTES - 2
    cld
    rep movsb
    mov byte [doom_log_buffer + DOOM_LOG_BYTES - 2], bl
    mov byte [doom_log_buffer + DOOM_LOG_BYTES - 1], 0
    jmp .done

.append:
    mov edi, doom_log_buffer
    add edi, eax
    mov [edi], bl
    inc eax
    mov [doom_log_len], eax
    mov byte [edi + 1], 0

.done:
    pop edi
    pop esi
    pop ecx
    pop ebx
    pop eax
    ret

present_indexed_frame:
    push ebx
    push ecx
    push edx
    push esi
    push edi

    cmp byte [video_backend], VIDEO_BACKEND_LFB_XRGB8888
    je .lfb_present

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

.mode13_present:
    call present_set_mode13_geometry
    call present_update_dirty_rect
    call present_copy_indexed_shadow
    call present_update_visual_proof
    jmp .success

.lfb_present:
    call present_select_lfb_geometry
    jc .fail
    call present_update_dirty_rect
    call present_copy_indexed_shadow
    call present_update_visual_proof
    call present_clear_lfb
    call present_lfb_xrgb8888
    jc .fail

.success:
    mov byte [present_status], 1
    clc
    jmp .done

.fail:
    stc

.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

present_reset_status_fields:
    mov byte [present_status], 0
    mov dword [present_sample_first], 0
    mov dword [present_sample_mid], 0
    mov dword [present_sample_last], 0
    mov dword [present_palette_hash], 0
    mov dword [present_frame_hash], 0
    mov dword [present_nonzero_count], 0
    mov dword [present_color_transition_count], 0
    mov byte [present_previous_index], 0
    mov dword [present_dirty_x], 0
    mov dword [present_dirty_y], 0
    mov dword [present_dirty_width], 0
    mov dword [present_dirty_height], 0
    mov dword [present_dirty_count], 0
    mov dword [present_lfb_policy], PRESENT_POLICY_MODE13
    mov dword [present_lfb_scale], 1
    mov dword [present_lfb_view_x], 0
    mov dword [present_lfb_view_y], 0
    mov dword [present_lfb_view_width], DOOM_SCREEN_WIDTH
    mov dword [present_lfb_view_height], DOOM_SCREEN_HEIGHT
    ret

present_set_mode13_geometry:
    mov dword [present_lfb_policy], PRESENT_POLICY_MODE13
    mov dword [present_lfb_scale], 1
    mov dword [present_lfb_view_x], 0
    mov dword [present_lfb_view_y], 0
    mov dword [present_lfb_view_width], DOOM_SCREEN_WIDTH
    mov dword [present_lfb_view_height], DOOM_SCREEN_HEIGHT
    ret

present_update_dirty_rect:
    pushad

    mov dword [present_dirty_count], 0
    mov dword [present_dirty_x], 0
    mov dword [present_dirty_y], 0
    mov dword [present_dirty_width], 0
    mov dword [present_dirty_height], 0
    mov dword [present_dirty_min_x], DOOM_SCREEN_WIDTH
    mov dword [present_dirty_min_y], DOOM_SCREEN_HEIGHT
    mov dword [present_dirty_max_x], 0
    mov dword [present_dirty_max_y], 0

    mov esi, [present_frame_arg]
    mov edi, VGA_GRAPHICS_BUFFER
    xor ebx, ebx

.dirty_y_next:
    cmp ebx, DOOM_SCREEN_HEIGHT
    jae .dirty_done_scan
    xor ecx, ecx

.dirty_x_next:
    cmp ecx, DOOM_SCREEN_WIDTH
    jae .dirty_next_row
    mov al, [esi]
    cmp al, [edi]
    je .dirty_same
    inc dword [present_dirty_count]
    cmp ecx, [present_dirty_min_x]
    jae .dirty_min_x_done
    mov [present_dirty_min_x], ecx

.dirty_min_x_done:
    cmp ebx, [present_dirty_min_y]
    jae .dirty_min_y_done
    mov [present_dirty_min_y], ebx

.dirty_min_y_done:
    cmp ecx, [present_dirty_max_x]
    jbe .dirty_max_x_done
    mov [present_dirty_max_x], ecx

.dirty_max_x_done:
    cmp ebx, [present_dirty_max_y]
    jbe .dirty_same
    mov [present_dirty_max_y], ebx

.dirty_same:
    inc esi
    inc edi
    inc ecx
    jmp .dirty_x_next

.dirty_next_row:
    inc ebx
    jmp .dirty_y_next

.dirty_done_scan:
    cmp dword [present_dirty_count], 0
    je .dirty_done
    mov eax, [present_dirty_min_x]
    mov [present_dirty_x], eax
    mov eax, [present_dirty_min_y]
    mov [present_dirty_y], eax
    mov eax, [present_dirty_max_x]
    sub eax, [present_dirty_min_x]
    inc eax
    mov [present_dirty_width], eax
    mov eax, [present_dirty_max_y]
    sub eax, [present_dirty_min_y]
    inc eax
    mov [present_dirty_height], eax

.dirty_done:
    popad
    ret

present_copy_indexed_shadow:
    push eax
    push ecx
    push esi
    push edi

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

    pop edi
    pop esi
    pop ecx
    pop eax
    ret

present_update_visual_proof:
    pushad

    mov esi, [present_palette_arg]
    mov ecx, DOOM_PALETTE_BYTES
    mov eax, 0x811c9dc5

.palette_hash_next:
    rol eax, 5
    movzx ebx, byte [esi]
    xor eax, ebx
    add eax, 0x01000193
    inc esi
    loop .palette_hash_next
    mov [present_palette_hash], eax

    mov esi, [present_frame_arg]
    mov ecx, DOOM_FRAME_BYTES
    mov eax, 0x811c9dc5
    xor edx, edx
    xor edi, edi
    mov byte [present_previous_index], 0

.frame_hash_next:
    rol eax, 5
    movzx ebx, byte [esi]
    xor eax, ebx
    add eax, 0x01000193
    cmp bl, 0
    je .nonzero_done
    inc edx

.nonzero_done:
    cmp ecx, DOOM_FRAME_BYTES
    je .transition_done
    cmp bl, byte [present_previous_index]
    je .transition_done
    inc edi

.transition_done:
    mov [present_previous_index], bl
    inc esi
    loop .frame_hash_next

    mov [present_frame_hash], eax
    mov [present_nonzero_count], edx
    mov [present_color_transition_count], edi

    popad
    ret

present_lfb_xrgb8888:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp

    cmp dword [present_lfb_policy], PRESENT_POLICY_ASPECT
    je .aspect
    cmp dword [present_lfb_policy], PRESENT_POLICY_SQUARE
    je .square
    jmp .fail

.aspect:
    call present_lfb_aspect_xrgb8888
    jmp .done_from_render

.square:
    call present_lfb_square_xrgb8888

.done_from_render:
    jc .fail

.ok:
    clc
    jmp .done

.fail:
    stc

.done:
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

present_select_lfb_geometry:
    push eax
    push ebx
    push ecx
    push edx

    cmp dword [framebuffer_width], DOOM_SCREEN_WIDTH * 2
    jb .fail
    cmp dword [framebuffer_height], DOOM_SCREEN_HEIGHT * 2
    jb .fail
    mov eax, [framebuffer_width]
    shl eax, 2
    cmp [framebuffer_pitch], eax
    jb .fail

    mov eax, [framebuffer_width]
    xor edx, edx
    mov ebx, DOOM_SCREEN_WIDTH
    div ebx
    mov ecx, eax
    mov eax, [framebuffer_height]
    xor edx, edx
    mov ebx, DOOM_ASPECT_HEIGHT
    div ebx
    cmp ecx, eax
    jbe .aspect_scale_ready
    mov ecx, eax

.aspect_scale_ready:
    cmp ecx, 2
    jb .try_square
    mov dword [present_lfb_policy], PRESENT_POLICY_ASPECT
    mov [present_lfb_scale], ecx
    mov eax, DOOM_SCREEN_WIDTH
    mul ecx
    mov [present_lfb_view_width], eax
    mov eax, DOOM_ASPECT_HEIGHT
    mul ecx
    mov [present_lfb_view_height], eax
    jmp .compute_center

.try_square:
    mov eax, [framebuffer_width]
    xor edx, edx
    mov ebx, DOOM_SCREEN_WIDTH
    div ebx
    mov ecx, eax
    mov eax, [framebuffer_height]
    xor edx, edx
    mov ebx, DOOM_SCREEN_HEIGHT
    div ebx
    cmp ecx, eax
    jbe .square_scale_ready
    mov ecx, eax

.square_scale_ready:
    cmp ecx, 2
    jb .fail
    mov dword [present_lfb_policy], PRESENT_POLICY_SQUARE
    mov [present_lfb_scale], ecx
    mov eax, DOOM_SCREEN_WIDTH
    mul ecx
    mov [present_lfb_view_width], eax
    mov eax, DOOM_SCREEN_HEIGHT
    mul ecx
    mov [present_lfb_view_height], eax

.compute_center:
    mov eax, [framebuffer_width]
    sub eax, [present_lfb_view_width]
    shr eax, 1
    mov [present_lfb_view_x], eax
    shl eax, 2
    mov [present_lfb_x_offset], eax

    mov eax, [framebuffer_height]
    sub eax, [present_lfb_view_height]
    shr eax, 1
    mov [present_lfb_view_y], eax
    clc
    jmp .done

.fail:
    stc

.done:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

present_clear_lfb:
    pushad
    mov edi, [framebuffer_addr]
    mov eax, [framebuffer_pitch]
    mul dword [framebuffer_height]
    shr eax, 2
    mov ecx, eax
    xor eax, eax
    cld
    rep stosd
    popad
    ret

present_lfb_start_row:
    push edx
    mov eax, [present_lfb_view_y]
    mul dword [framebuffer_pitch]
    add eax, [present_lfb_x_offset]
    add eax, [framebuffer_addr]
    mov [present_lfb_row], eax
    pop edx
    ret

present_lfb_square_xrgb8888:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    call present_lfb_start_row
    xor ebx, ebx

.source_row_next:
    cmp ebx, DOOM_SCREEN_HEIGHT
    jae .ok
    mov eax, ebx
    mov ecx, DOOM_SCREEN_WIDTH
    mul ecx
    add eax, [present_frame_arg]
    mov esi, eax
    mov ecx, [present_lfb_scale]

.repeat_row:
    mov edi, [present_lfb_row]
    push esi
    call present_lfb_render_scaled_row
    pop esi
    mov eax, [framebuffer_pitch]
    add [present_lfb_row], eax
    dec ecx
    jnz .repeat_row
    inc ebx
    jmp .source_row_next

.ok:
    clc
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

present_lfb_aspect_xrgb8888:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    call present_lfb_start_row
    xor ebx, ebx

.visual_row_next:
    cmp ebx, DOOM_ASPECT_HEIGHT
    jae .ok
    mov eax, ebx
    mov ecx, DOOM_SCREEN_HEIGHT
    mul ecx
    mov ecx, DOOM_ASPECT_HEIGHT
    div ecx
    mov [present_lfb_source_y], eax
    mov ecx, DOOM_SCREEN_WIDTH
    mul ecx
    add eax, [present_frame_arg]
    mov esi, eax
    mov ecx, [present_lfb_scale]

.repeat_row:
    mov edi, [present_lfb_row]
    push esi
    call present_lfb_render_scaled_row
    pop esi
    mov eax, [framebuffer_pitch]
    add [present_lfb_row], eax
    dec ecx
    jnz .repeat_row
    inc ebx
    jmp .visual_row_next

.ok:
    clc
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

present_lfb_render_scaled_row:
    push eax
    push ebx
    push ecx
    push edx
    push ebp

    mov ecx, DOOM_SCREEN_WIDTH

.pixel_next:
    movzx ebx, byte [esi]
    inc esi
    lea edx, [ebx + ebx * 2]
    add edx, [present_palette_arg]
    xor eax, eax
    movzx ebx, byte [edx]
    shl ebx, 16
    or eax, ebx
    movzx ebx, byte [edx + 1]
    shl ebx, 8
    or eax, ebx
    movzx ebx, byte [edx + 2]
    or eax, ebx
    mov ebp, [present_lfb_scale]

.repeat_pixel:
    mov [edi], eax
    add edi, 4
    dec ebp
    jnz .repeat_pixel
    loop .pixel_next

    pop ebp
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

keyboard_reset_queue:
    mov dword [key_event_head], 0
    mov dword [key_event_tail], 0
    mov dword [keyboard_irq_count], 0
    mov dword [keyboard_event_count], 0
    mov dword [doom_key_event_count], 0
    mov dword [doom_key_down_seen], 0
    mov dword [doom_key_last_event], 0
    mov byte [keyboard_extended], 0
    ret

keyboard_queue_scancode:
    push eax
    push ebx
    push edx

    cmp al, 0xe0
    je .extended_prefix
    cmp al, 0xe1
    je .ignore

    mov bl, al
    mov dl, 1
    test bl, 0x80
    jz .translate
    and bl, 0x7f
    xor dl, dl

.translate:
    cmp byte [keyboard_extended], 0
    jne .translate_extended
    movzx ebx, bl
    mov al, [doom_scancode_map + ebx]
    jmp .queue

.translate_extended:
    mov byte [keyboard_extended], 0
    xor al, al
    cmp bl, 0x48
    je .ext_up
    cmp bl, 0x50
    je .ext_down
    cmp bl, 0x4b
    je .ext_left
    cmp bl, 0x4d
    je .ext_right
    cmp bl, 0x1c
    je .ext_enter
    cmp bl, 0x1d
    je .ext_ctrl
    cmp bl, 0x38
    je .ext_alt
    cmp bl, 0x53
    je .ext_backspace
    jmp .queue

.ext_up:
    mov al, DOOM_KEY_UPARROW
    jmp .queue

.ext_down:
    mov al, DOOM_KEY_DOWNARROW
    jmp .queue

.ext_left:
    mov al, DOOM_KEY_LEFTARROW
    jmp .queue

.ext_right:
    mov al, DOOM_KEY_RIGHTARROW
    jmp .queue

.ext_enter:
    mov al, DOOM_KEY_ENTER
    jmp .queue

.ext_ctrl:
    mov al, DOOM_KEY_RCTRL
    jmp .queue

.ext_alt:
    mov al, DOOM_KEY_RALT
    jmp .queue

.ext_backspace:
    mov al, DOOM_KEY_BACKSPACE

.queue:
    call keyboard_queue_event
    jmp .done

.extended_prefix:
    mov byte [keyboard_extended], 1
    jmp .done

.ignore:
    mov byte [keyboard_extended], 0

.done:
    pop edx
    pop ebx
    pop eax
    ret

keyboard_queue_event:
    test al, al
    jz .done
    push ebx
    push edx
    push edi

    movzx eax, al
    or eax, KEY_EVENT_VALID
    test dl, dl
    jz .have_packed
    or eax, KEY_EVENT_DOWN

.have_packed:
    mov ebx, [key_event_head]
    mov edx, ebx
    inc edx
    and edx, KEY_QUEUE_MASK
    cmp edx, [key_event_tail]
    jne .space_available
    mov edi, [key_event_tail]
    inc edi
    and edi, KEY_QUEUE_MASK
    mov [key_event_tail], edi

.space_available:
    mov edi, key_event_queue
    mov [edi + ebx * 4], eax
    mov [key_event_head], edx
    inc dword [keyboard_event_count]

    pop edi
    pop edx
    pop ebx

.done:
    ret

mouse_reset_queue:
    mov dword [mouse_event_head], 0
    mov dword [mouse_event_tail], 0
    mov dword [mouse_irq_count], 0
    mov dword [mouse_packet_count], 0
    mov dword [mouse_sync_loss_count], 0
    mov dword [doom_mouse_event_count], 0
    mov dword [doom_mouse_buttons_seen], 0
    mov dword [doom_mouse_delta_x], 0
    mov dword [doom_mouse_delta_y], 0
    mov dword [doom_mouse_last_event], 0
    mov byte [mouse_packet_index], 0
    mov byte [mouse_packet0], 0
    mov byte [mouse_packet1], 0
    mov byte [mouse_packet2], 0
    ret

mouse_queue_byte:
    push eax
    push ebx
    push edx

    mov bl, al
    cmp byte [mouse_packet_index], 0
    je .packet0
    cmp byte [mouse_packet_index], 1
    je .packet1

    mov [mouse_packet2], bl
    mov byte [mouse_packet_index], 0
    call mouse_decode_packet
    jmp .done

.packet0:
    test bl, 0x08
    jnz .packet0_ok
    inc dword [mouse_sync_loss_count]
    jmp .done

.packet0_ok:
    mov [mouse_packet0], bl
    mov byte [mouse_packet_index], 1
    jmp .done

.packet1:
    mov [mouse_packet1], bl
    mov byte [mouse_packet_index], 2

.done:
    pop edx
    pop ebx
    pop eax
    ret

mouse_decode_packet:
    push eax
    push ebx

    mov al, [mouse_packet0]
    test al, 0xc0
    jnz .overflow

    movzx eax, al
    and eax, 0x07
    movzx ebx, byte [mouse_packet1]
    shl ebx, 8
    or eax, ebx
    movzx ebx, byte [mouse_packet2]
    shl ebx, 16
    or eax, ebx
    or eax, MOUSE_EVENT_VALID
    call mouse_queue_event
    inc dword [mouse_packet_count]
    jmp .done

.overflow:
    inc dword [mouse_sync_loss_count]

.done:
    pop ebx
    pop eax
    ret

mouse_queue_event:
    push ebx
    push edx
    push edi

    mov ebx, [mouse_event_head]
    mov edx, ebx
    inc edx
    and edx, MOUSE_QUEUE_MASK
    cmp edx, [mouse_event_tail]
    jne .space_available
    mov edi, [mouse_event_tail]
    inc edi
    and edi, MOUSE_QUEUE_MASK
    mov [mouse_event_tail], edi

.space_available:
    mov edi, mouse_event_queue
    mov [edi + ebx * 4], eax
    mov [mouse_event_head], edx

    pop edi
    pop edx
    pop ebx
    ret

doom_record_key_event:
    push eax
    push ebx

    mov [doom_key_last_event], eax
    test eax, KEY_EVENT_DOWN
    jz .done
    mov ebx, eax
    and ebx, 0xff
    cmp bl, DOOM_KEY_UPARROW
    je .seen_up
    cmp bl, DOOM_KEY_DOWNARROW
    je .seen_down
    cmp bl, DOOM_KEY_LEFTARROW
    je .seen_left
    cmp bl, DOOM_KEY_RIGHTARROW
    je .seen_right
    cmp bl, DOOM_KEY_RCTRL
    je .seen_fire
    cmp bl, 32
    je .seen_use
    cmp bl, DOOM_KEY_ESCAPE
    je .seen_menu
    cmp bl, DOOM_KEY_ENTER
    je .seen_enter
    jmp .done

.seen_up:
    or dword [doom_key_down_seen], KEY_PROOF_UP
    jmp .done

.seen_down:
    or dword [doom_key_down_seen], KEY_PROOF_DOWN
    jmp .done

.seen_left:
    or dword [doom_key_down_seen], KEY_PROOF_LEFT
    jmp .done

.seen_right:
    or dword [doom_key_down_seen], KEY_PROOF_RIGHT
    jmp .done

.seen_fire:
    or dword [doom_key_down_seen], KEY_PROOF_FIRE
    jmp .done

.seen_use:
    or dword [doom_key_down_seen], KEY_PROOF_USE
    jmp .done

.seen_menu:
    or dword [doom_key_down_seen], KEY_PROOF_MENU
    jmp .done

.seen_enter:
    or dword [doom_key_down_seen], KEY_PROOF_ENTER

.done:
    pop ebx
    pop eax
    ret

doom_record_mouse_event:
    push eax
    push ebx
    push edx

    mov [doom_mouse_last_event], eax

    mov ebx, eax
    and ebx, 0x07
    or dword [doom_mouse_buttons_seen], ebx

    mov ebx, eax
    shr ebx, 8
    movsx ebx, bl
    test ebx, ebx
    jns .dx_positive
    neg ebx

.dx_positive:
    add dword [doom_mouse_delta_x], ebx

    mov ebx, eax
    shr ebx, 16
    movsx ebx, bl
    test ebx, ebx
    jns .dy_positive
    neg ebx

.dy_positive:
    add dword [doom_mouse_delta_y], ebx

    pop edx
    pop ebx
    pop eax
    ret

exception_divide_error:
    push dword 0
    push dword 0
    jmp exception_common

exception_invalid_opcode:
    push dword 0
    push dword 6
    jmp exception_common

exception_stack_fault:
    push dword 12
    jmp exception_common

exception_general_protection:
    push dword 13
    jmp exception_common

page_fault_handler:
    push dword 14
    jmp exception_common

exception_halt:
    push dword 0
    push dword 0xffffffff
    jmp exception_common

exception_common:
    mov eax, [esp + EXCEPTION_FRAME_VECTOR]
    mov [fault_vector], eax
    mov eax, [esp + EXCEPTION_FRAME_ERROR]
    mov [fault_error], eax
    mov eax, [esp + EXCEPTION_FRAME_EIP]
    mov [fault_eip], eax
    mov eax, [esp + EXCEPTION_FRAME_CS]
    mov [fault_cs], eax
    mov eax, [esp + EXCEPTION_FRAME_EFLAGS]
    mov [fault_eflags], eax
    mov eax, [esp + EXCEPTION_FRAME_CS]
    test eax, 3
    jz .kernel_frame
    mov eax, [esp + EXCEPTION_FRAME_ESP]
    mov [fault_esp], eax
    mov eax, [esp + EXCEPTION_FRAME_SS]
    mov [fault_ss], eax
    jmp .frame_done

.kernel_frame:
    lea eax, [esp + 20]
    mov [fault_esp], eax
    mov dword [fault_ss], DATA_SEG

.frame_done:
    mov eax, cr2
    mov [fault_cr2], eax
    mov eax, [current_pid]
    mov [fault_pid], eax
    movzx eax, byte [current_user_kind]
    mov [fault_kind], eax
    mov dword [fault_state], 0
    mov esi, [current_process_ptr]
    cmp esi, 0
    je .no_process
    mov eax, [esi + PROC_STATE]
    mov [fault_state], eax

.no_process:
    mov eax, [current_syscall_number]
    mov [fault_last_syscall], eax

    cmp dword [fault_vector], 14
    jne .not_expected_user_fault
    cmp byte [user_fault_expected], 1
    jne .not_expected_user_fault
    mov byte [user_fault_expected], 0
    mov byte [user_fault_status], 1
    mov byte [user_probe_status], 3
    mov eax, [fault_cr2]
    mov [user_fault_addr], eax
    mov eax, [user_fault_recovery]
    mov dword [user_fault_recovery], 0
    cmp eax, 0
    je .expected_fault_skip_instruction
    mov [esp + EXCEPTION_FRAME_EIP], eax
    jmp .expected_fault_return

.expected_fault_skip_instruction:
    add dword [esp + EXCEPTION_FRAME_EIP], EXPECTED_FAULT_INSTRUCTION_BYTES

.expected_fault_return:
    add esp, 8
    iretd

.not_expected_user_fault:
    cmp byte [current_user_kind], USER_KIND_DOOM
    je doom_user_fault
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov dword [panic_status], PANIC_UNHANDLED_EXCEPTION
    call write_smoke_status
    cli

.halt:
    hlt
    jmp .halt

doom_user_fault:
    mov byte [doom_run_status], 3
    mov eax, [fault_cr2]
    mov [doom_fault_addr], eax
    mov eax, [fault_eip]
    mov [doom_fault_eip], eax
    mov eax, [fault_vector]
    mov [doom_fault_vector], eax
    mov eax, [fault_error]
    mov [doom_fault_error], eax
    call process_mark_current_faulted
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, KERNEL_STACK_TOP
    jmp doom_user_finished

irq_timer:
    pushad
    inc dword [timer_ticks]
    mov ebx, esp
    call scheduler_tick
    call draw_timer_status
    call write_smoke_status
    mov al, 0x20
    out 0x20, al
    popad
    iretd

irq_keyboard:
    pushad
    inc dword [keyboard_irq_count]
    in al, PS2_DATA_PORT
    call keyboard_queue_scancode
    mov al, 0x20
    out 0x20, al
    popad
    iretd

irq_mouse:
    pushad
    inc dword [mouse_irq_count]
    in al, PS2_DATA_PORT
    call mouse_queue_byte
    mov al, 0x20
    out 0xa0, al
    out 0x20, al
    popad
    iretd

irq_audio:
    push eax
    push edx
    inc dword [sb16_irq_count]
    mov dx, SB16_DSP_READ_STATUS
    in al, dx
    test al, SB16_DSP_READY
    jz .ack16
    inc dword [sb16_irq_ack8_count]

.ack16:
    mov dx, SB16_DSP_ACK16
    in al, dx
    test al, SB16_DSP_READY
    jz .account_refill
    inc dword [sb16_irq_ack16_count]

.account_refill:
    cmp byte [sb16_playback_active], 1
    jne .send_eoi
    inc dword [sb16_irq_refill_count]
    xor dword [sb16_irq_half_index], 1
    call sb16_refill_active_half

.send_eoi:
    mov al, 0x20
    out 0x20, al
    pop edx
    pop eax
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

    mov esi, smoke_exec_text
    call smoke_copy_string
    cmp byte [process_exec_status], 1
    je .exec_ok
    mov esi, smoke_fail_text
    jmp .exec_write

.exec_ok:
    mov esi, smoke_ok_text

.exec_write:
    call smoke_copy_string
    mov esi, smoke_exec_path_text
    call smoke_copy_string
    cmp dword [process_exec_path_ptr], 0
    je .exec_path_empty
    mov esi, [process_exec_path_ptr]
    jmp .exec_path_write

.exec_path_empty:
    mov esi, smoke_dash_text

.exec_path_write:
    call smoke_copy_string
    mov esi, smoke_execsys_text
    call smoke_copy_string
    mov edx, [sys_exec_attempts]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [sys_exec_successes]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [sys_exec_failures]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [sys_exec_handoffs]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [sys_exec_scheduled]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [sys_exec_rollbacks]
    call smoke_write_hex32
    mov esi, smoke_execerr_text
    call smoke_copy_string
    mov edx, [process_exec_last_error]
    call smoke_write_hex32
    mov esi, smoke_execres_text
    call smoke_copy_string
    mov edx, [sys_exec_last_result]
    call smoke_write_hex32
    mov esi, smoke_exec_target_text
    call smoke_copy_string
    mov edx, [sys_exec_last_target_pid]
    call smoke_write_hex32
    mov esi, smoke_exec_ppid_text
    call smoke_copy_string
    mov edx, [sys_exec_last_parent_pid]
    call smoke_write_hex32
    mov esi, smoke_exec_entry_text
    call smoke_copy_string
    mov edx, [sys_exec_last_target_entry]
    call smoke_write_hex32
    mov esi, smoke_exec_stack_text
    call smoke_copy_string
    mov edx, [sys_exec_last_target_stack]
    call smoke_write_hex32
    mov esi, smoke_exec_argc_text
    call smoke_copy_string
    mov edx, [sys_exec_last_argc]
    call smoke_write_hex32
    mov esi, smoke_exec_argv_ptr_text
    call smoke_copy_string
    mov edx, [sys_exec_last_argv]
    call smoke_write_hex32
    mov esi, smoke_exec_envp_ptr_text
    call smoke_copy_string
    mov edx, [sys_exec_last_envp]
    call smoke_write_hex32
    mov esi, smoke_exec_argv_text
    call smoke_copy_string
    mov edx, [sys_exec_last_argv0]
    call smoke_write_hex32
    mov esi, smoke_exec_envp0_text
    call smoke_copy_string
    mov edx, [sys_exec_last_envp0]
    call smoke_write_hex32
    mov esi, smoke_exec_argvsrc_text
    call smoke_copy_string
    mov edx, [sys_exec_last_argv_source]
    call smoke_write_hex32

    mov esi, smoke_procpool_text
    call smoke_copy_string
    mov edx, PROCESS_SLOT_COUNT
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, PROCESS_GENERIC_SLOT_COUNT
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [process_slot_reuses]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [process_generic_slot_allocations]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [process_generic_slot_failures]
    call smoke_write_hex32

    mov esi, smoke_pidseq_text
    call smoke_copy_string
    mov edx, [process_next_pid]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [process_last_reused_pid]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [process_last_slot_generation]
    call smoke_write_hex32

    mov esi, smoke_fdexec_text
    call smoke_copy_string
    mov edx, [fd_exec_handoffs]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [fd_exec_inherited]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [fd_exec_closed]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [fd_owner_closes]
    call smoke_write_hex32

    mov esi, smoke_pwait_text
    call smoke_copy_string
    mov edx, [process_wait_attempts]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [process_wait_reaps]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [process_wait_failures]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [process_wait_nohang_returns]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [process_wait_seeded_children]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [process_wait_last_reaped_pid]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [process_wait_last_status]
    call smoke_write_hex32
    mov al, ' '
    stosb

    mov esi, smoke_doom_text
    call smoke_copy_string
    cmp byte [doom_elf_status], 1
    jne .doom_fail
    cmp byte [doom_elf_load_status], 1
    jne .doom_fail
    cmp byte [doom_elf_parse_status], 1
    jne .doom_fail
    cmp byte [doom_load_segment_count], 0
    je .doom_fail
    cmp byte [doom_user_window_status], 1
    jne .doom_fail
    mov esi, smoke_ok_text
    jmp .doom_write

.doom_fail:
    mov esi, smoke_fail_text

.doom_write:
    call smoke_copy_string

    mov esi, smoke_doomrun_text
    call smoke_copy_string
    cmp byte [doom_run_status], 1
    je .doomrun_running
    cmp byte [doom_run_status], 2
    je .doomrun_exited
    cmp byte [doom_run_status], 3
    je .doomrun_faulted
    cmp byte [doom_run_status], 4
    je .doomrun_failed
    mov esi, smoke_wait_text
    jmp .doomrun_write

.doomrun_running:
    mov esi, smoke_run_text
    jmp .doomrun_write

.doomrun_exited:
    mov esi, smoke_exit_text
    jmp .doomrun_write

.doomrun_faulted:
    mov esi, smoke_fault_text
    jmp .doomrun_write

.doomrun_failed:
    mov esi, smoke_fail_text

.doomrun_write:
    call smoke_copy_string

    mov esi, smoke_doomexit_text
    call smoke_copy_string
    mov edx, [doom_exit_code]
    call smoke_write_hex32

    mov esi, smoke_doomfault_text
    call smoke_copy_string
    mov edx, [doom_fault_addr]
    call smoke_write_hex32

    mov esi, smoke_doomfaultip_text
    call smoke_copy_string
    mov edx, [doom_fault_eip]
    call smoke_write_hex32

    mov esi, smoke_doomfaultv_text
    call smoke_copy_string
    mov edx, [doom_fault_vector]
    call smoke_write_hex32

    mov esi, smoke_doomfaulterr_text
    call smoke_copy_string
    mov edx, [doom_fault_error]
    call smoke_write_hex32

    mov esi, smoke_faultframe_text
    call smoke_copy_string
    mov edx, [fault_vector]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [fault_error]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [fault_eip]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [fault_cs]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [fault_esp]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [fault_ss]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [fault_cr2]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [fault_pid]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [fault_kind]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [fault_state]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [fault_last_syscall]
    call smoke_write_hex32

    mov esi, smoke_panic_text
    call smoke_copy_string
    cmp dword [panic_status], PANIC_UNHANDLED_EXCEPTION
    je .panic_unhandled_exception
    mov esi, smoke_none_text
    jmp .panic_write

.panic_unhandled_exception:
    mov esi, smoke_kexc_text

.panic_write:
    call smoke_copy_string

    mov esi, smoke_shutdown_text
    call smoke_copy_string
    cmp dword [shutdown_state], SHUTDOWN_HALT
    je .shutdown_halt
    cmp dword [shutdown_state], SHUTDOWN_REBOOT
    je .shutdown_reboot
    cmp dword [shutdown_state], SHUTDOWN_POWEROFF
    je .shutdown_poweroff
    mov esi, smoke_none_text
    jmp .shutdown_write

.shutdown_halt:
    mov esi, smoke_halt_text
    jmp .shutdown_write

.shutdown_reboot:
    mov esi, smoke_reboot_text
    jmp .shutdown_write

.shutdown_poweroff:
    mov esi, smoke_poweroff_text

.shutdown_write:
    call smoke_copy_string

    mov esi, smoke_ata_text
    call smoke_copy_string
    cmp byte [ata_status], 1
    je .ata_ok
    cmp byte [ata_status], 2
    je .ata_fail
    mov esi, smoke_wait_text
    jmp .ata_write

.ata_ok:
    mov esi, smoke_ok_text
    jmp .ata_write

.ata_fail:
    mov esi, smoke_fail_text

.ata_write:
    call smoke_copy_string

    mov esi, smoke_ataop_text
    call smoke_copy_string
    cmp dword [ata_last_op], ATA_OP_READ
    je .ataop_read
    cmp dword [ata_last_op], ATA_OP_WRITE
    je .ataop_write
    mov esi, smoke_none_text
    jmp .ataop_write_field

.ataop_read:
    mov esi, smoke_read_text
    jmp .ataop_write_field

.ataop_write:
    mov esi, smoke_write_text

.ataop_write_field:
    call smoke_copy_string

    mov esi, smoke_atawait_text
    call smoke_copy_string
    cmp dword [ata_wait_phase], ATA_WAIT_BUSY
    je .atawait_busy
    cmp dword [ata_wait_phase], ATA_WAIT_DRQ
    je .atawait_drq
    cmp dword [ata_wait_phase], ATA_WAIT_READY
    je .atawait_ready
    cmp dword [ata_wait_phase], ATA_WAIT_DATA
    je .atawait_data
    mov esi, smoke_idle_text
    jmp .atawait_write

.atawait_busy:
    mov esi, smoke_busy_text
    jmp .atawait_write

.atawait_drq:
    mov esi, smoke_drq_text
    jmp .atawait_write

.atawait_ready:
    mov esi, smoke_ready_text
    jmp .atawait_write

.atawait_data:
    mov esi, smoke_data_text

.atawait_write:
    call smoke_copy_string

    mov esi, smoke_atalba_text
    call smoke_copy_string
    mov edx, [ata_last_lba]
    call smoke_write_hex32

    mov esi, smoke_atastat_text
    call smoke_copy_string
    mov edx, [ata_last_status]
    call smoke_write_hex32

    mov esi, smoke_ataerr_text
    call smoke_copy_string
    mov edx, [ata_last_error]
    call smoke_write_hex32

    mov esi, smoke_atafail_text
    call smoke_copy_string
    mov edx, [ata_wait_failures]
    call smoke_write_hex32

    mov esi, smoke_atatmo_text
    call smoke_copy_string
    mov edx, [ata_wait_timeouts]
    call smoke_write_hex32

    mov esi, smoke_doomopen_text
    call smoke_copy_string
    cmp dword [doom_open_count], 0
    je .doomopen_fail
    mov esi, smoke_ok_text
    jmp .doomopen_write

.doomopen_fail:
    mov esi, smoke_fail_text

.doomopen_write:
    call smoke_copy_string

    mov esi, smoke_doomread_text
    call smoke_copy_string
    cmp dword [doom_read_count], 0
    je .doomread_fail
    cmp dword [doom_wad_magic_seen], 0x44415749
    jne .doomread_fail
    mov esi, smoke_ok_text
    jmp .doomread_write

.doomread_fail:
    mov esi, smoke_fail_text

.doomread_write:
    call smoke_copy_string

    mov esi, smoke_doomwrite_text
    call smoke_copy_string
    mov edx, [doom_write_count]
    call smoke_write_hex32

    mov esi, smoke_doomseek_text
    call smoke_copy_string
    mov edx, [doom_lseek_count]
    call smoke_write_hex32

    mov esi, smoke_doomwad_text
    call smoke_copy_string
    mov edx, [doom_open_count]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [doom_read_count]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [doom_lseek_count]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [doom_wad_magic_seen]
    call smoke_write_hex32

    mov esi, smoke_doomclose_text
    call smoke_copy_string
    mov edx, [doom_close_count]
    call smoke_write_hex32

    mov esi, smoke_doomsbrk_text
    call smoke_copy_string
    mov edx, [doom_sbrk_count]
    call smoke_write_hex32

    mov esi, smoke_doomerr_text
    call smoke_copy_string
    mov edx, [doom_error_count]
    call smoke_write_hex32

    mov esi, smoke_doomerrno_text
    call smoke_copy_string
    mov edx, [doom_last_error]
    call smoke_write_hex32

    mov esi, smoke_doommode_text
    call smoke_copy_string
    mov edx, [doom_last_open_flags]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [doom_last_open_mode]
    call smoke_write_hex32

    mov esi, smoke_doomsav_text
    call smoke_copy_string
    mov edx, [doom_saveload_flags]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [doom_saveload_slot]
    call smoke_write_hex32

    mov esi, smoke_saverd_text
    call smoke_copy_string
    mov edx, [doom_saveload_read_bytes]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [doom_saveload_read_count]
    call smoke_write_hex32

    mov esi, smoke_savewr_text
    call smoke_copy_string
    mov edx, [doom_saveload_write_bytes]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [doom_saveload_write_count]
    call smoke_write_hex32

    mov esi, smoke_saveclose_text
    call smoke_copy_string
    mov edx, [doom_saveload_close_count]
    call smoke_write_hex32

    mov esi, smoke_savemode_text
    call smoke_copy_string
    mov edx, [doom_saveload_last_open_flags]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [doom_saveload_last_open_mode]
    call smoke_write_hex32

    mov esi, smoke_filewrite_text
    call smoke_copy_string
    mov edx, [file_write_debug_stage]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [file_write_debug_result]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [file_io_index]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [file_io_fd_slot]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [file_io_remaining]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [file_io_done]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [file_io_chunk]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [file_io_sector_lba]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [file_io_sector_offset]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [file_write_debug_capacity]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [fat_file_lba_was_new_cluster]
    call smoke_write_hex32

    mov esi, smoke_fatalloc_text
    call smoke_copy_string
    mov edx, [fat_alloc_debug_stage]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [fat_alloc_debug_hint]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [fat_alloc_debug_cluster]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [fat_alloc_debug_refreshes]
    call smoke_write_hex32

    mov esi, smoke_saveact_text
    call smoke_copy_string
    mov edx, [doom_saveaction_flags]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [doom_saveaction_gameaction]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [doom_saveaction_slot]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [doom_saveaction_report_count]
    call smoke_write_hex32

    mov esi, smoke_savedesc_text
    call smoke_copy_string
    mov edx, [doom_saveaction_desc_len]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [doom_saveaction_desc_hash]
    call smoke_write_hex32

    mov esi, smoke_fio_text
    call smoke_copy_string
    mov edx, [file_write_fail_stage]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [file_io_index]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [file_io_fd_slot]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [file_write_requested]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [file_write_capacity]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [file_io_remaining]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [file_io_done]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [file_io_sector_lba]
    call smoke_write_hex32

    mov esi, smoke_doomlog_text
    call smoke_copy_string
    cmp byte [doom_log_buffer], 0
    je .doomlog_empty
    mov esi, doom_log_buffer
    jmp .doomlog_write

.doomlog_empty:
    mov esi, smoke_dash_text

.doomlog_write:
    call smoke_copy_string

    mov esi, smoke_doompresent_text
    call smoke_copy_string
    mov edx, [doom_present_count]
    call smoke_write_hex32
    mov esi, smoke_doompal_text
    call smoke_copy_string
    mov edx, [present_palette_hash]
    call smoke_write_hex32
    mov esi, smoke_doomframe_text
    call smoke_copy_string
    mov edx, [present_frame_hash]
    call smoke_write_hex32
    mov esi, smoke_doomnonzero_text
    call smoke_copy_string
    mov edx, [present_nonzero_count]
    call smoke_write_hex32
    mov esi, smoke_doomcolors_text
    call smoke_copy_string
    mov edx, [present_color_transition_count]
    call smoke_write_hex32
    mov esi, smoke_doomsamp_text
    call smoke_copy_string
    mov edx, [present_sample_first]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [present_sample_mid]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [present_sample_last]
    call smoke_write_hex32

    mov esi, smoke_doominit_text
    call smoke_copy_string
    mov edx, [doom_init_flags]
    call smoke_write_hex32
    mov al, '/'
    stosb
    mov edx, [doom_init_report_count]
    call smoke_write_hex32

    mov esi, smoke_gameplay_text
    call smoke_copy_string
    cmp byte [doom_gameplay_status], 1
    je .gameplay_ok
    mov esi, smoke_wait_text
    jmp .gameplay_write

.gameplay_ok:
    mov esi, smoke_ok_text

.gameplay_write:
    call smoke_copy_string

    mov esi, smoke_gstate_text
    call smoke_copy_string
    mov edx, [doom_game_state]
    call smoke_write_hex32

    mov esi, smoke_gmap_text
    call smoke_copy_string
    mov edx, [doom_game_map_pair]
    call smoke_write_hex32

    mov esi, smoke_gtic_text
    call smoke_copy_string
    mov edx, [doom_game_tic]
    call smoke_write_hex32

    mov esi, smoke_leveltime_text
    call smoke_copy_string
    mov edx, [doom_level_time]
    call smoke_write_hex32

    mov esi, smoke_doomtick_text
    call smoke_copy_string
    mov eax, [timer_ticks]
    mov ebx, 35
    mul ebx
    mov ebx, 100
    div ebx
    mov edx, eax
    call smoke_write_hex32

    mov esi, smoke_gflags_text
    call smoke_copy_string
    mov edx, [doom_game_flags]
    call smoke_write_hex32

    mov esi, smoke_gaction_text
    call smoke_copy_string
    mov edx, [doom_game_action]
    call smoke_write_hex32

    mov esi, smoke_pflags_text
    call smoke_copy_string
    mov edx, [doom_player_flags]
    call smoke_write_hex32

    mov esi, smoke_pbuttons_text
    call smoke_copy_string
    mov edx, [doom_player_buttons]
    call smoke_write_hex32

    mov esi, smoke_ppos_text
    call smoke_copy_string
    mov edx, [doom_player_x]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [doom_player_y]
    call smoke_write_hex32

    mov esi, smoke_pdelta_text
    call smoke_copy_string
    mov edx, [doom_player_delta]
    call smoke_write_hex32

    mov esi, smoke_pcmd_text
    call smoke_copy_string
    mov edx, [doom_player_cmd]
    call smoke_write_hex32

    mov esi, smoke_pangle_text
    call smoke_copy_string
    mov edx, [doom_player_angle]
    call smoke_write_hex32

    mov esi, smoke_pangledelta_text
    call smoke_copy_string
    mov edx, [doom_player_angle_delta]
    call smoke_write_hex32

    mov esi, smoke_pammo_text
    call smoke_copy_string
    mov edx, [doom_player_ammo]
    call smoke_write_hex32

    mov esi, smoke_prefire_text
    call smoke_copy_string
    mov edx, [doom_player_refire]
    call smoke_write_hex32

    mov esi, smoke_pweapon_text
    call smoke_copy_string
    mov edx, [doom_player_weapon]
    call smoke_write_hex32

    mov esi, smoke_doomsound_text
    call smoke_copy_string
    mov edx, [doom_sound_call_count]
    call smoke_write_hex32

    mov esi, smoke_sfxmix_text
    call smoke_copy_string
    mov edx, [sb16_sfx_mix_count]
    call smoke_write_hex32

    mov esi, smoke_sfxq_text
    call smoke_copy_string
    mov edx, [sb16_sfx_voice_start_count]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [sb16_sfx_voice_stop_count]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [sb16_sfx_voice_update_count]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [sb16_sfx_voice_finished_count]
    call smoke_write_hex32

    mov esi, smoke_sfxbytes_text
    call smoke_copy_string
    mov edx, [sb16_sfx_submit_bytes]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [sb16_sfx_output_bytes]
    call smoke_write_hex32

    mov esi, smoke_sfxdma_text
    call smoke_copy_string
    mov edx, [sb16_sfx_dma_mix_count]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [sb16_sfx_dma_mix_bytes]
    call smoke_write_hex32

    mov esi, smoke_sfxsrc_text
    call smoke_copy_string
    mov edx, [sb16_sfx_wad_start_count]
    call smoke_write_hex32

    mov esi, smoke_sfxlast_text
    call smoke_copy_string
    mov edx, [sb16_sfx_last_id]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [sb16_sfx_last_rate]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [sb16_sfx_last_length]
    call smoke_write_hex32

    mov esi, smoke_audiovoices_text
    call smoke_copy_string
    mov edx, [sb16_active_voice_count]
    call smoke_write_hex32

    mov esi, smoke_sfxvoices_text
    call smoke_copy_string
    mov edx, [sb16_active_sfx_voice_count]
    call smoke_write_hex32

    mov esi, smoke_audioirq_text
    call smoke_copy_string
    mov edx, [sb16_irq_count]
    call smoke_write_hex32

    mov esi, smoke_audioack8_text
    call smoke_copy_string
    mov edx, [sb16_irq_ack8_count]
    call smoke_write_hex32

    mov esi, smoke_audioack16_text
    call smoke_copy_string
    mov edx, [sb16_irq_ack16_count]
    call smoke_write_hex32

    mov esi, smoke_audiorefill_text
    call smoke_copy_string
    mov edx, [sb16_irq_refill_count]
    call smoke_write_hex32

    mov esi, smoke_audiohalf_text
    call smoke_copy_string
    mov edx, [sb16_irq_half_index]
    call smoke_write_hex32

    mov esi, smoke_mixwrap_text
    call smoke_copy_string
    mov edx, [sb16_mix_wrap_count]
    call smoke_write_hex32

    mov esi, smoke_mixover_text
    call smoke_copy_string
    mov edx, [sb16_mix_overwrite_count]
    call smoke_write_hex32

    mov esi, smoke_mixunder_text
    call smoke_copy_string
    mov edx, [sb16_mix_underrun_count]
    call smoke_write_hex32

    mov esi, smoke_mixclip_text
    call smoke_copy_string
    mov edx, [sb16_mix_clip_count]
    call smoke_write_hex32

    mov esi, smoke_voicesteal_text
    call smoke_copy_string
    mov edx, [sb16_voice_steal_count]
    call smoke_write_hex32

    mov esi, smoke_pitchclamp_text
    call smoke_copy_string
    mov edx, [sb16_pitch_clamp_count]
    call smoke_write_hex32

    mov esi, smoke_panclamp_text
    call smoke_copy_string
    mov edx, [sb16_pan_clamp_count]
    call smoke_write_hex32

    mov esi, smoke_musicvoices_text
    call smoke_copy_string
    mov edx, [sb16_active_music_voice_count]
    call smoke_write_hex32

    mov esi, smoke_musicmix_text
    call smoke_copy_string
    mov edx, [sb16_music_mix_count]
    call smoke_write_hex32

    mov esi, smoke_musicloop_text
    call smoke_copy_string
    mov edx, [sb16_music_loop_count]
    call smoke_write_hex32

    mov esi, smoke_musicpos_text
    call smoke_copy_string
    mov edx, [sb16_music_stream_pos_bytes]
    call smoke_write_hex32

    mov esi, smoke_musicbuf_text
    call smoke_copy_string
    mov edx, [sb16_music_stream_buffer_bytes]
    call smoke_write_hex32

    mov esi, smoke_musicunder_text
    call smoke_copy_string
    mov edx, [sb16_music_stream_under_count]
    call smoke_write_hex32

    mov esi, smoke_musicdrops_text
    call smoke_copy_string
    mov edx, [sb16_music_stream_drop_count]
    call smoke_write_hex32

    mov esi, smoke_musicstream_text
    call smoke_copy_string
    mov eax, [sb16_music_stream_mode]
    cmp eax, AUDIO_MUSIC_STREAM_PUSH
    je .musicstream_push
    cmp eax, AUDIO_MUSIC_STREAM_PULL
    je .musicstream_pull
    mov esi, smoke_none_text
    jmp .musicstream_write

.musicstream_push:
    mov esi, smoke_push_text
    jmp .musicstream_write

.musicstream_pull:
    mov esi, smoke_pull_text

.musicstream_write:
    call smoke_copy_string

    mov esi, smoke_musicpull_text
    call smoke_copy_string
    mov edx, [sb16_music_pull_request_count]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [sb16_music_pull_refill_count]
    call smoke_write_hex32

    mov esi, smoke_musicrend_text
    call smoke_copy_string
    mov edx, [sb16_music_render_format]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [sb16_music_render_chunk_count]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [sb16_music_render_note_count]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [sb16_music_render_event_count]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [sb16_music_render_active_peak]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [sb16_music_render_sample_count]
    call smoke_write_hex32

    mov esi, smoke_sb16ver_text
    call smoke_copy_string
    movzx edx, byte [sb16_major_version]
    call smoke_write_hex32
    mov al, ':'
    stosb
    movzx edx, byte [sb16_minor_version]
    call smoke_write_hex32

    mov esi, smoke_dmaprog_text
    call smoke_copy_string
    mov edx, [sb16_dma_program_count]
    call smoke_write_hex32

    mov esi, smoke_play_text
    call smoke_copy_string
    mov edx, [sb16_playback_start_count]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [sb16_playback_stop_count]
    call smoke_write_hex32

    mov esi, smoke_voiceq_text
    call smoke_copy_string
    mov edx, [sb16_voice_start_count]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [sb16_voice_stop_count]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [sb16_voice_update_count]
    call smoke_write_hex32

    mov esi, smoke_musicq_text
    call smoke_copy_string
    mov edx, [sb16_music_start_count]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [sb16_music_stop_count]
    call smoke_write_hex32

    mov esi, smoke_audio_text
    call smoke_copy_string
    cmp byte [audio_status], 1
    je .audio_sb16
    mov esi, smoke_none_text
    jmp .audio_write

.audio_sb16:
    mov esi, smoke_sb16_text

.audio_write:
    call smoke_copy_string

    mov esi, smoke_keyirq_text
    call smoke_copy_string
    mov edx, [keyboard_irq_count]
    call smoke_write_hex32

    mov esi, smoke_keyqueue_text
    call smoke_copy_string
    mov edx, [keyboard_event_count]
    call smoke_write_hex32

    mov esi, smoke_keypoll_text
    call smoke_copy_string
    mov edx, [doom_key_event_count]
    call smoke_write_hex32

    mov esi, smoke_keyseen_text
    call smoke_copy_string
    mov edx, [doom_key_down_seen]
    call smoke_write_hex32

    mov esi, smoke_keylast_text
    call smoke_copy_string
    mov edx, [doom_key_last_event]
    call smoke_write_hex32

    mov esi, smoke_mouse_text
    call smoke_copy_string
    cmp byte [mouse_status], 1
    je .mouse_ok
    mov esi, smoke_none_text
    jmp .mouse_write

.mouse_ok:
    mov esi, smoke_ok_text

.mouse_write:
    call smoke_copy_string

    mov esi, smoke_mouseirq_text
    call smoke_copy_string
    mov edx, [mouse_irq_count]
    call smoke_write_hex32

    mov esi, smoke_mousepkt_text
    call smoke_copy_string
    mov edx, [mouse_packet_count]
    call smoke_write_hex32

    mov esi, smoke_mousepoll_text
    call smoke_copy_string
    mov edx, [doom_mouse_event_count]
    call smoke_write_hex32

    mov esi, smoke_mousebtn_text
    call smoke_copy_string
    mov edx, [doom_mouse_buttons_seen]
    call smoke_write_hex32

    mov esi, smoke_mousedelta_text
    call smoke_copy_string
    mov edx, [doom_mouse_delta_x]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [doom_mouse_delta_y]
    call smoke_write_hex32

    mov esi, smoke_pci_text
    call smoke_copy_string
    cmp byte [pci_config_status], 1
    je .pci_ok
    mov esi, smoke_none_text
    jmp .pci_write

.pci_ok:
    mov esi, smoke_ok_text

.pci_write:
    call smoke_copy_string

    mov esi, smoke_pciprobe_text
    call smoke_copy_string
    mov edx, [pci_probe_count]
    call smoke_write_hex32

    mov esi, smoke_pcicount_text
    call smoke_copy_string
    mov edx, [pci_function_count]
    call smoke_write_hex32

    mov esi, smoke_pcifirst_text
    call smoke_copy_string
    mov edx, [pci_first_bdf]
    call smoke_write_hex32

    mov esi, smoke_pciid_text
    call smoke_copy_string
    mov edx, [pci_first_id]
    call smoke_write_hex32

    mov esi, smoke_pciclass_text
    call smoke_copy_string
    mov edx, [pci_first_class]
    call smoke_write_hex32

    mov esi, smoke_pcitable_text
    call smoke_copy_string
    mov esi, smoke_ok_text
    call smoke_copy_string

    mov esi, smoke_pcitabcap_text
    call smoke_copy_string
    mov edx, PCI_TABLE_MAX_ENTRIES
    call smoke_write_hex32

    mov esi, smoke_pcitabuse_text
    call smoke_copy_string
    mov edx, [pci_function_count]
    call smoke_write_hex32

    mov esi, smoke_pcilast_text
    call smoke_copy_string
    mov edx, [pci_last_bdf]
    call smoke_write_hex32

    mov esi, smoke_pciclassh_text
    call smoke_copy_string
    mov edx, [pci_class_table_hash]
    call smoke_write_hex32

    mov esi, smoke_pcimulti_text
    call smoke_copy_string
    mov edx, [pci_multifunction_device_count]
    call smoke_write_hex32

    mov esi, smoke_pciclsms_text
    call smoke_copy_string
    mov edx, [pci_mass_storage_class_count]
    call smoke_write_hex32

    mov esi, smoke_pciclsbr_text
    call smoke_copy_string
    mov edx, [pci_bridge_class_count]
    call smoke_write_hex32

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

    mov esi, smoke_fb_text
    call smoke_copy_string
    cmp byte [video_backend], VIDEO_BACKEND_LFB_XRGB8888
    je .fb_lfb
    mov esi, smoke_mode13_text
    jmp .fb_write

.fb_lfb:
    mov esi, smoke_lfb_text

.fb_write:
    call smoke_copy_string

    mov esi, smoke_fbpolicy_text
    call smoke_copy_string
    cmp dword [present_lfb_policy], PRESENT_POLICY_ASPECT
    je .fbpolicy_aspect
    cmp dword [present_lfb_policy], PRESENT_POLICY_SQUARE
    je .fbpolicy_square
    mov esi, smoke_mode13_text
    jmp .fbpolicy_write

.fbpolicy_aspect:
    mov esi, smoke_aspect_text
    jmp .fbpolicy_write

.fbpolicy_square:
    mov esi, smoke_square_text

.fbpolicy_write:
    call smoke_copy_string

    mov esi, smoke_fbgeom_text
    call smoke_copy_string
    mov edx, [present_lfb_view_x]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [present_lfb_view_y]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [present_lfb_view_width]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [present_lfb_view_height]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [present_lfb_scale]
    call smoke_write_hex32

    mov esi, smoke_fbdirty_text
    call smoke_copy_string
    mov edx, [present_dirty_x]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [present_dirty_y]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [present_dirty_width]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [present_dirty_height]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [present_dirty_count]
    call smoke_write_hex32

    mov esi, smoke_preempt_text
    call smoke_copy_string
    mov edx, [scheduler_preempt_switches]
    call smoke_write_hex32

    mov esi, smoke_pirq_text
    call smoke_copy_string
    mov edx, [scheduler_irq_context_switches]
    call smoke_write_hex32

    mov esi, smoke_pattempt_text
    call smoke_copy_string
    mov edx, [scheduler_preempt_attempts]
    call smoke_write_hex32

    mov esi, smoke_pskip_text
    call smoke_copy_string
    mov edx, [scheduler_preempt_skips]
    call smoke_write_hex32

    mov esi, smoke_puser_text
    call smoke_copy_string
    mov edx, [scheduler_user_irq_ticks]
    call smoke_write_hex32

    mov esi, smoke_pround_text
    call smoke_copy_string
    mov edx, [scheduler_round_count]
    call smoke_write_hex32

    mov esi, smoke_pctx_text
    call smoke_copy_string
    mov edx, [scheduler_context_switches]
    call smoke_write_hex32

    mov esi, smoke_pfrom_text
    call smoke_copy_string
    mov edx, [scheduler_last_preempt_from_pid]
    call smoke_write_hex32

    mov esi, smoke_pto_text
    call smoke_copy_string
    mov edx, [scheduler_last_preempt_to_pid]
    call smoke_write_hex32

    mov esi, smoke_pkind_text
    call smoke_copy_string
    mov edx, [scheduler_last_preempt_from_kind]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [scheduler_last_preempt_to_kind]
    call smoke_write_hex32

    mov esi, smoke_peip_text
    call smoke_copy_string
    mov edx, [scheduler_last_preempt_from_eip]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [scheduler_last_preempt_to_eip]
    call smoke_write_hex32

    mov esi, smoke_pcr3_text
    call smoke_copy_string
    mov edx, [scheduler_last_preempt_from_cr3]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [scheduler_last_preempt_to_cr3]
    call smoke_write_hex32

    mov esi, smoke_pkstk_text
    call smoke_copy_string
    mov edx, [scheduler_last_preempt_from_kstack]
    call smoke_write_hex32
    mov al, ':'
    stosb
    mov edx, [scheduler_last_preempt_to_kstack]
    call smoke_write_hex32

    mov esi, smoke_pspin_text
    call smoke_copy_string
    mov edx, [scheduler_preempt_spin_value]
    call smoke_write_hex32

    mov esi, smoke_pself_text
    call smoke_copy_string
    cmp byte [scheduler_preempt_selftest_status], 1
    je .pself_ok
    mov esi, smoke_fail_text
    jmp .pself_write

.pself_ok:
    mov esi, smoke_ok_text

.pself_write:
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

    mov esi, smoke_vmmhi_text
    call smoke_copy_string
    cmp byte [vmm_high_mapping_status], 1
    je .vmmhi_ok
    mov esi, fail_status_text
    jmp .vmmhi_write

.vmmhi_ok:
    mov esi, ok_status_text

.vmmhi_write:
    call smoke_copy_string

    mov esi, smoke_vmmhva_text
    call smoke_copy_string
    mov edx, VMM_HIGH_TEST_VADDR
    call smoke_write_hex32

    mov esi, smoke_vmmhpa_text
    call smoke_copy_string
    mov edx, [vmm_high_test_phys]
    call smoke_write_hex32

    mov esi, smoke_vmmhpt_text
    call smoke_copy_string
    mov edx, [vmm_high_test_table]
    call smoke_write_hex32

    mov esi, smoke_vmmhfree_text
    call smoke_copy_string
    mov edx, [vmm_high_test_reclaimed]
    call smoke_write_hex32

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
    cmp byte [doom_elf_status], 1
    jne .user_fail_text
    cmp byte [doom_elf_load_status], 1
    jne .user_fail_text
    cmp byte [doom_elf_parse_status], 1
    jne .user_fail_text
    cmp byte [process_exec_status], 1
    jne .user_fail_text
    cmp byte [doom_run_status], 1
    je .user_check_live_doom
    cmp byte [doom_run_status], 2
    je .user_ok_from_doom
    jmp .user_fail_text

.user_check_live_doom:
    mov eax, [process_doom + PROC_STATE]
    cmp eax, PROC_STATE_READY
    je .user_ok_from_doom
    cmp eax, PROC_STATE_RUNNING
    jne .user_fail_text
.user_ok_from_doom:
    mov esi, smoke_ok_text
    jmp .user_write

.user_fail_text:
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
    cmp byte [doom_load_segment_count], 0
    je .fail
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
    cmp byte [doom_elf_status], 1
    jne .user_fail_text
    cmp byte [doom_elf_load_status], 1
    jne .user_fail_text
    cmp byte [doom_elf_parse_status], 1
    jne .user_fail_text
    cmp byte [process_exec_status], 1
    jne .user_fail_text
    cmp byte [doom_run_status], 1
    je .user_check_live_doom
    cmp byte [doom_run_status], 2
    je .user_ok_from_doom
    jmp .user_fail_text

.user_check_live_doom:
    mov eax, [process_doom + PROC_STATE]
    cmp eax, PROC_STATE_READY
    je .user_ok_from_doom
    cmp eax, PROC_STATE_RUNNING
    jne .user_fail_text
.user_ok_from_doom:
    mov esi, ok_status_text
    call draw_status_string
    jmp .wad_status

.user_fail_text:
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
          db "  halt    stop the CPU", 13, 10
          db "  poweroff request ACPI/QEMU poweroff", 13, 10, 0

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
process_exec_prefix db "Process exec: ", 0
process_exec_path_prefix db "Exec path: ", 0
process_exec_syscall_prefix db "Exec syscall attempts/success/failure/handoff/scheduled/rollback: ", 0
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
smoke_exec_text db "exec=", 0
smoke_exec_path_text db " path=", 0
smoke_execsys_text db " execsys=", 0
smoke_execerr_text db " execerr=", 0
smoke_execres_text db " execres=", 0
smoke_exec_target_text db " target=", 0
smoke_exec_ppid_text db " ppid=", 0
smoke_exec_entry_text db " entry=", 0
smoke_exec_stack_text db " stack=", 0
smoke_exec_argc_text db " argc=", 0
smoke_exec_argv_ptr_text db " argv=", 0
smoke_exec_envp_ptr_text db " envp=", 0
smoke_exec_argv_text db " argv0=", 0
smoke_exec_envp0_text db " envp0=", 0
smoke_exec_argvsrc_text db " argvsrc=", 0
smoke_procpool_text db " procpool=", 0
smoke_pidseq_text db " pidseq=", 0
smoke_fdexec_text db " fdexec=", 0
smoke_pwait_text db " wait=", 0
smoke_doom_text db "doom=", 0
smoke_doomrun_text db " doomrun=", 0
smoke_doomexit_text db " doomexit=", 0
smoke_doomfault_text db " doomfault=", 0
smoke_doomfaultip_text db " doomfaultip=", 0
smoke_doomfaultv_text db " doomfaultv=", 0
smoke_doomfaulterr_text db " doomfaulterr=", 0
smoke_faultframe_text db " fault=", 0
smoke_panic_text db " panic=", 0
smoke_shutdown_text db " shutdown=", 0
smoke_ata_text db " ata=", 0
smoke_ataop_text db " ataop=", 0
smoke_atawait_text db " atawait=", 0
smoke_atalba_text db " atalba=", 0
smoke_atastat_text db " atastat=", 0
smoke_ataerr_text db " ataerr=", 0
smoke_atafail_text db " atafail=", 0
smoke_atatmo_text db " atatmo=", 0
smoke_vmmhi_text db " vmmhi=", 0
smoke_vmmhva_text db " vmmhva=", 0
smoke_vmmhpa_text db " vmmhpa=", 0
smoke_vmmhpt_text db " vmmhpt=", 0
smoke_vmmhfree_text db " vmmhfree=", 0
smoke_doomopen_text db " doomopen=", 0
smoke_doomread_text db " doomread=", 0
smoke_doomwrite_text db " doomwrite=", 0
smoke_doomseek_text db " doomseek=", 0
smoke_doomwad_text db " doomwad=", 0
smoke_doomclose_text db " doomclose=", 0
smoke_doomsbrk_text db " doomsbrk=", 0
smoke_doomerr_text db " doomerr=", 0
smoke_doomerrno_text db " doomerrno=", 0
smoke_doommode_text db " doommode=", 0
smoke_doomsav_text db " doomsav=", 0
smoke_saverd_text db " saverd=", 0
smoke_savewr_text db " savewr=", 0
smoke_saveclose_text db " saveclose=", 0
smoke_savemode_text db " savemode=", 0
smoke_filewrite_text db " fwr=", 0
smoke_fatalloc_text db " fal=", 0
smoke_saveact_text db " saveact=", 0
smoke_savedesc_text db " savedesc=", 0
smoke_fio_text db " fio=", 0
smoke_doomlog_text db " doomlog=", 0
smoke_doompresent_text db " doompresent=", 0
smoke_doompal_text db " doompal=", 0
smoke_doomframe_text db " doomframe=", 0
smoke_doomnonzero_text db " doomnonzero=", 0
smoke_doomcolors_text db " doomcolors=", 0
smoke_doomsamp_text db " doomsamp=", 0
smoke_doominit_text db " doominit=", 0
smoke_gameplay_text db " gameplay=", 0
smoke_gstate_text db " gstate=", 0
smoke_gmap_text db " gmap=", 0
smoke_gtic_text db " gtic=", 0
smoke_leveltime_text db " leveltime=", 0
smoke_doomtick_text db " dtick=", 0
smoke_gflags_text db " gflags=", 0
smoke_gaction_text db " gaction=", 0
smoke_pflags_text db " pflags=", 0
smoke_pbuttons_text db " pbuttons=", 0
smoke_ppos_text db " ppos=", 0
smoke_pdelta_text db " pdelta=", 0
smoke_pcmd_text db " pcmd=", 0
smoke_pangle_text db " pangle=", 0
smoke_pangledelta_text db " pangledelta=", 0
smoke_pammo_text db " pammo=", 0
smoke_prefire_text db " prefire=", 0
smoke_pweapon_text db " pweapon=", 0
smoke_doomsound_text db " doomsound=", 0
smoke_sfxmix_text db " sfxmix=", 0
smoke_sfxq_text db " sfxq=", 0
smoke_sfxbytes_text db " sfxbytes=", 0
smoke_sfxdma_text db " sfxdma=", 0
smoke_sfxsrc_text db " sfxsrc=", 0
smoke_sfxlast_text db " sfxlast=", 0
smoke_audiovoices_text db " voices=", 0
smoke_sfxvoices_text db " sfxvoices=", 0
smoke_audioirq_text db " audioirq=", 0
smoke_audioack8_text db " ack8=", 0
smoke_audioack16_text db " ack16=", 0
smoke_audiorefill_text db " refill=", 0
smoke_audiohalf_text db " half=", 0
smoke_mixwrap_text db " mixwrap=", 0
smoke_mixover_text db " mixover=", 0
smoke_mixunder_text db " mixunder=", 0
smoke_mixclip_text db " mixclip=", 0
smoke_voicesteal_text db " steal=", 0
smoke_pitchclamp_text db " pitchclamp=", 0
smoke_panclamp_text db " panclamp=", 0
smoke_musicvoices_text db " musicvoices=", 0
smoke_musicmix_text db " musicmix=", 0
smoke_musicloop_text db " musicloop=", 0
smoke_musicpos_text db " musicpos=", 0
smoke_musicbuf_text db " musicbuf=", 0
smoke_musicunder_text db " musicunder=", 0
smoke_musicdrops_text db " musicdrops=", 0
smoke_musicstream_text db " musicstream=", 0
smoke_musicpull_text db " musicpull=", 0
smoke_musicrend_text db " musicrend=", 0
smoke_sb16ver_text db " sb16=", 0
smoke_dmaprog_text db " dma=", 0
smoke_play_text db " play=", 0
smoke_voiceq_text db " voiceq=", 0
smoke_musicq_text db " musicq=", 0
smoke_audio_text db " audio=", 0
smoke_keyirq_text db " keyirq=", 0
smoke_keyqueue_text db " keyqueue=", 0
smoke_keypoll_text db " keypoll=", 0
smoke_keyseen_text db " keyseen=", 0
smoke_keylast_text db " keylast=", 0
smoke_mouse_text db " mouse=", 0
smoke_mouseirq_text db " mouseirq=", 0
smoke_mousepkt_text db " mousepkt=", 0
smoke_mousepoll_text db " mousepoll=", 0
smoke_mousebtn_text db " mousebtn=", 0
smoke_mousedelta_text db " mousedelta=", 0
smoke_pci_text db " pci=", 0
smoke_pciprobe_text db " pciprobe=", 0
smoke_pcicount_text db " pcicount=", 0
smoke_pcifirst_text db " pcifirst=", 0
smoke_pciid_text db " pciid=", 0
smoke_pciclass_text db " pciclass=", 0
smoke_pcitable_text db " pcitable=", 0
smoke_pcitabcap_text db " pcitabcap=", 0
smoke_pcitabuse_text db " pcitabuse=", 0
smoke_pcilast_text db " pcilast=", 0
smoke_pciclassh_text db " pciclassh=", 0
smoke_pcimulti_text db " pcimulti=", 0
smoke_pciclsms_text db " pciclsms=", 0
smoke_pciclsbr_text db " pciclsbr=", 0
smoke_gfx_text db " gfx=", 0
smoke_fb_text db " fb=", 0
smoke_fbpolicy_text db " fbpolicy=", 0
smoke_fbgeom_text db " fbgeom=", 0
smoke_fbdirty_text db " fbdirty=", 0
smoke_preempt_text db " preempt=", 0
smoke_pirq_text db " pirq=", 0
smoke_pattempt_text db " pattempt=", 0
smoke_pskip_text db " pskip=", 0
smoke_puser_text db " puser=", 0
smoke_pround_text db " pround=", 0
smoke_pctx_text db " pctx=", 0
smoke_pfrom_text db " pfrom=", 0
smoke_pto_text db " pto=", 0
smoke_pkind_text db " pkind=", 0
smoke_peip_text db " peip=", 0
smoke_pcr3_text db " pcr3=", 0
smoke_pkstk_text db " pkstk=", 0
smoke_pspin_text db " pspin=", 0
smoke_pself_text db " pself=", 0
smoke_status_text db " ", 0
smoke_ok_text db "OK", 0
smoke_fail_text db "FAIL", 0
smoke_dash_text db "-", 0
smoke_wait_text db "WAIT", 0
smoke_run_text db "RUN", 0
smoke_exit_text db "EXIT", 0
smoke_fault_text db "FAULT", 0
smoke_mode13_text db "M13", 0
smoke_lfb_text db "LFB", 0
smoke_aspect_text db "ASP", 0
smoke_square_text db "SQ", 0
smoke_sb16_text db "SB16", 0
smoke_none_text db "NONE", 0
smoke_push_text db "PUSH", 0
smoke_pull_text db "PULL", 0
smoke_kexc_text db "KEXC", 0
smoke_halt_text db "HALT", 0
smoke_reboot_text db "REBOOT", 0
smoke_poweroff_text db "POWEROFF", 0
smoke_read_text db "READ", 0
smoke_write_text db "WRITE", 0
smoke_idle_text db "IDLE", 0
smoke_busy_text db "BUSY", 0
smoke_drq_text db "DRQ", 0
smoke_ready_text db "READY", 0
smoke_data_text db "DATA", 0
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
reboot_message db "Rebooting through x86 reset control / PS/2 controller...", 13, 10, 0
halt_message db "CPU halted. Close QEMU to exit.", 13, 10, 0
poweroff_message db "Requesting ACPI/QEMU poweroff...", 13, 10, 0

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
cmd_poweroff db "poweroff", 0

wad_name_83 db "DOOM1   WAD"
user_elf_name_83 db "USERPROBELF"
doom_elf_name_83 db "DOOM    ELF"
exec_path_doom db "DOOM.ELF", 0
exec_path_user_probe db "USERPROB.ELF", 0
default_cfg_name_83 db "DEFAULT CFG"
doomsav0_name_83 db "DOOMSAV0DSG"
doomsav1_name_83 db "DOOMSAV1DSG"
doomsav2_name_83 db "DOOMSAV2DSG"
doomsav3_name_83 db "DOOMSAV3DSG"
doomsav4_name_83 db "DOOMSAV4DSG"
doomsav5_name_83 db "DOOMSAV5DSG"
persist_chk_name_83 db "PERSIST CHK"
save_req_name_83 db "SAVEREQ CHK"
load_req_name_83 db "LOADREQ CHK"
wad_name_playpal db "PLAYPAL", 0
wad_name_colormap db "COLORMAP"
user_path_doom_wad db "DOOM1.WAD", 0
user_path_doom_wad_end:
user_path_default_cfg db "DEFAULT.CFG", 0
user_path_default_cfg_end:
user_path_doomrc db ".doomrc", 0
user_path_doomrc_end:
user_path_doomsav0 db "doomsav0.dsg", 0
user_path_doomsav0_end:
user_path_doomsav1 db "doomsav1.dsg", 0
user_path_doomsav1_end:
user_path_doomsav2 db "doomsav2.dsg", 0
user_path_doomsav2_end:
user_path_doomsav3 db "doomsav3.dsg", 0
user_path_doomsav3_end:
user_path_doomsav4 db "doomsav4.dsg", 0
user_path_doomsav4_end:
user_path_doomsav5 db "doomsav5.dsg", 0
user_path_doomsav5_end:
writable_name_table dd default_cfg_name_83, doomsav0_name_83, doomsav1_name_83, doomsav2_name_83, doomsav3_name_83, doomsav4_name_83, doomsav5_name_83
writable_path_table dd user_path_default_cfg, user_path_doomsav0, user_path_doomsav1, user_path_doomsav2, user_path_doomsav3, user_path_doomsav4, user_path_doomsav5
writable_path_len_table dd user_path_default_cfg_end - user_path_default_cfg, user_path_doomsav0_end - user_path_doomsav0, user_path_doomsav1_end - user_path_doomsav1, user_path_doomsav2_end - user_path_doomsav2, user_path_doomsav3_end - user_path_doomsav3, user_path_doomsav4_end - user_path_doomsav4, user_path_doomsav5_end - user_path_doomsav5
writable_capacity_table dd WRITABLE_DEFAULT_CAPACITY, WRITABLE_SAVE_CAPACITY, WRITABLE_SAVE_CAPACITY, WRITABLE_SAVE_CAPACITY, WRITABLE_SAVE_CAPACITY, WRITABLE_SAVE_CAPACITY, WRITABLE_SAVE_CAPACITY, WRITABLE_GENERIC_CAPACITY, WRITABLE_GENERIC_CAPACITY, WRITABLE_GENERIC_CAPACITY, WRITABLE_GENERIC_CAPACITY, WRITABLE_GENERIC_CAPACITY, WRITABLE_GENERIC_CAPACITY, WRITABLE_GENERIC_CAPACITY, WRITABLE_GENERIC_CAPACITY, WRITABLE_GENERIC_CAPACITY
persistence_marker_name_table dd persist_chk_name_83, save_req_name_83, load_req_name_83
process_exec_table:
    dd exec_path_doom, doom_elf_name_83, DOOM_ELF_LOAD_ADDR, DOOM_ELF_MAX_BYTES, process_doom
    dd exec_path_user_probe, user_elf_name_83, USER_ELF_LOAD_ADDR, USER_ELF_MAX_BYTES, process_user_probe
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

doom_scancode_map:
    times 0x01 - ($ - doom_scancode_map) db 0
    db DOOM_KEY_ESCAPE
    db '1','2','3','4','5','6','7','8','9','0'
    db DOOM_KEY_MINUS, DOOM_KEY_EQUALS, DOOM_KEY_BACKSPACE, DOOM_KEY_TAB
    db 'q','w','e','r','t','y','u','i','o','p'
    db '[',']',DOOM_KEY_ENTER,DOOM_KEY_RCTRL
    db 'a','s','d','f','g','h','j','k','l'
    db ';',39,'`',DOOM_KEY_RSHIFT,92
    db 'z','x','c','v','b','n','m'
    db ',','.','/',DOOM_KEY_RSHIFT
    times 0x38 - ($ - doom_scancode_map) db 0
    db DOOM_KEY_RALT
    db ' '
    times 0x3b - ($ - doom_scancode_map) db 0
    db DOOM_KEY_F1,DOOM_KEY_F2,DOOM_KEY_F3,DOOM_KEY_F4,DOOM_KEY_F5
    db DOOM_KEY_F6,DOOM_KEY_F7,DOOM_KEY_F8,DOOM_KEY_F9,DOOM_KEY_F10
    times 0x48 - ($ - doom_scancode_map) db 0
    db DOOM_KEY_UPARROW
    times 0x4a - ($ - doom_scancode_map) db 0
    db DOOM_KEY_MINUS,DOOM_KEY_LEFTARROW,0,DOOM_KEY_RIGHTARROW,DOOM_KEY_EQUALS,0,DOOM_KEY_DOWNARROW
    times 0x53 - ($ - doom_scancode_map) db 0
    db DOOM_KEY_BACKSPACE
    times 0x57 - ($ - doom_scancode_map) db 0
    db DOOM_KEY_F11,DOOM_KEY_F12
    times 128 - ($ - doom_scancode_map) db 0

cursor_row dd 0
cursor_col dd 0
timer_ticks dd 0
paging_status db 0
vmm_status db 0
pmm_test_status db 0
vmm_test_status db 0
vmm_high_mapping_status db 0
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
process_exec_status db 0
current_user_kind db 0
doom_run_status db 0
ata_status db 0
fat_status db 0
wad_status db 0
wad_parse_status db 0
align 4
process_user_probe_vm_regions:
    dd USER_CODE_ADDR, USER_STACK_BOTTOM, VM_REGION_USER | VM_REGION_READ | VM_REGION_WRITE | VM_REGION_EXEC
    dd USER_HEAP_START, USER_HEAP_END, VM_REGION_USER | VM_REGION_HEAP | VM_REGION_READ | VM_REGION_WRITE
    dd USER_STACK_BOTTOM, USER_STACK_TOP, VM_REGION_USER | VM_REGION_READ | VM_REGION_WRITE
process_doom_vm_regions:
    dd DOOM_USER_BASE, DOOM_USER_HEAP_START, VM_REGION_USER | VM_REGION_READ | VM_REGION_WRITE | VM_REGION_EXEC
    dd DOOM_USER_HEAP_START, DOOM_USER_HEAP_END, VM_REGION_USER | VM_REGION_HEAP | VM_REGION_READ | VM_REGION_WRITE
    dd DOOM_USER_STACK_BOTTOM, DOOM_USER_STACK_TOP, VM_REGION_USER | VM_REGION_READ | VM_REGION_WRITE
process_table:
process_kernel:
    dd 0, USER_KIND_NONE, PROC_STATE_READY
    dd 0, 0, 0, 0, 0
    dd 0, KERNEL_STACK_TOP, start
    times 12 dd 0
    dd 0, 0, 0, 0
    dd PAGING_DIR_ADDR, 0, 0, 0, PROC_KERNEL_PROCESS_STACK_TOP
    dd 0xffffffff, 0, 0, 0, 0, 0, 0, 0
    dd 0, 0
process_user_probe:
    dd 1, USER_KIND_PROBE, PROC_STATE_READY
    dd USER_CODE_ADDR, USER_HEAP_END, USER_HEAP_START, USER_HEAP_START, USER_HEAP_END
    dd USER_STACK_BOTTOM, USER_STACK_TOP, 0
    times 12 dd 0
    dd 0, 0, 0, 0
    dd PROC_PROBE_PAGE_DIR_ADDR, process_user_probe_vm_regions, 3, 0, PROC_USER_PROBE_KERNEL_STACK_TOP
    dd 0xffffffff, 0, 0, 0, 0, 0, 0, 0
    dd process_user_probe_heap_bitmap, USER_HEAP_PAGE_COUNT
process_preempt_probe:
    dd 3, USER_KIND_PREEMPT_PROBE, PROC_STATE_READY
    dd USER_CODE_ADDR, USER_HEAP_END, USER_HEAP_START, USER_HEAP_START, USER_HEAP_END
    dd USER_STACK_BOTTOM, USER_STACK_TOP, 0
    times 12 dd 0
    dd 0, 0, 0, 0
    dd PROC_PREEMPT_PAGE_DIR_ADDR, process_user_probe_vm_regions, 3, 0, PROC_PREEMPT_PROBE_KERNEL_STACK_TOP
    dd 0xffffffff, 0, 0, 0, 0, 0, 0, 0
    dd process_preempt_probe_heap_bitmap, USER_HEAP_PAGE_COUNT
process_doom:
    dd 2, USER_KIND_DOOM, PROC_STATE_READY
    dd DOOM_USER_BASE, DOOM_USER_END, DOOM_USER_HEAP_START, DOOM_USER_HEAP_START, DOOM_USER_HEAP_END
    dd DOOM_USER_STACK_BOTTOM, DOOM_USER_STACK_TOP, 0
    times 12 dd 0
    dd 0, 0, 0, 0
    dd PROC_DOOM_PAGE_DIR_ADDR, process_doom_vm_regions, 3, 0, PROC_DOOM_KERNEL_STACK_TOP
    dd 0xffffffff, 0, 0, 0, 0, 0, 0, 0
    dd process_doom_heap_bitmap, DOOM_HEAP_PAGE_COUNT
process_generic0:
    dd 0xffffffff, USER_KIND_GENERIC, PROC_STATE_UNUSED
    dd USER_CODE_ADDR, USER_HEAP_END, USER_HEAP_START, USER_HEAP_START, USER_HEAP_END
    dd USER_STACK_BOTTOM, USER_STACK_TOP, 0
    times 12 dd 0
    dd 0, 0, 0, 0
    dd PROC_GENERIC0_PAGE_DIR_ADDR, process_user_probe_vm_regions, 3, 0, PROC_GENERIC0_KERNEL_STACK_TOP
    dd 0xffffffff, 0, 0, 0, 0, 0, 0, 0
    dd process_generic0_heap_bitmap, USER_HEAP_PAGE_COUNT
process_generic1:
    dd 0xffffffff, USER_KIND_GENERIC, PROC_STATE_UNUSED
    dd USER_CODE_ADDR, USER_HEAP_END, USER_HEAP_START, USER_HEAP_START, USER_HEAP_END
    dd USER_STACK_BOTTOM, USER_STACK_TOP, 0
    times 12 dd 0
    dd 0, 0, 0, 0
    dd PROC_GENERIC1_PAGE_DIR_ADDR, process_user_probe_vm_regions, 3, 0, PROC_GENERIC1_KERNEL_STACK_TOP
    dd 0xffffffff, 0, 0, 0, 0, 0, 0, 0
    dd process_generic1_heap_bitmap, USER_HEAP_PAGE_COUNT
process_generic_exec_slots:
    dd process_generic0, process_generic1
align 4
process_user_probe_heap_bitmap times USER_HEAP_BITMAP_BYTES db 0
process_preempt_probe_heap_bitmap times USER_HEAP_BITMAP_BYTES db 0
process_doom_heap_bitmap times DOOM_HEAP_BITMAP_BYTES db 0
process_generic0_heap_bitmap times USER_HEAP_BITMAP_BYTES db 0
process_generic1_heap_bitmap times USER_HEAP_BITMAP_BYTES db 0
align 4
pmm_total_pages dd 0
pmm_free_pages dd 0
pmm_used_pages dd 0
vmm_static_page_tables dd 0
vmm_dynamic_page_tables dd 0
vmm_active_page_tables dd 0
vmm_reclaimed_page_tables dd 0
vmm_last_reclaimed_page_table dd 0
vmm_user_guard_pages dd 0
vmm_high_test_phys dd 0
vmm_high_test_table dd 0
vmm_high_test_reclaimed dd 0
vmm_map_vaddr dd 0
vmm_map_entry dd 0
vmm_map_table_addr dd 0
vmm_map_pde_ptr dd 0
ata_last_lba dd 0
ata_last_op dd 0
ata_wait_phase dd 0
ata_last_status dd 0
ata_last_error dd 0
ata_wait_failures dd 0
ata_wait_timeouts dd 0
ata_wait_error_failures dd 0
fat_lba_base dd 0
fat_total_sectors dd 0
fat_last_data_cluster dd 0
fat_next_free_hint dd 0
fat_scan_start dd 0
fat_alloc_zero_policy dd 0
fat_file_lba_was_new_cluster dd 0
fat_alloc_debug_stage dd 0
fat_alloc_debug_hint dd 0
fat_alloc_debug_cluster dd 0
fat_alloc_debug_refreshes dd 0
fat_alloc_scan_refreshed dd 0
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
fat_found_root_lba dd 0
fat_found_root_offset dd 0
fat_load_remaining dd 0
fat_load_sectors_read dd 0
fat_mut_cluster dd 0
fat_mut_sector_index dd 0
fat_mut_entry_offset dd 0
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
doom_segment_flags dd 0
doom_phdr_ptr dd 0
doom_phdr_remaining dd 0
user_phdr_ptr dd 0
user_phdr_remaining dd 0
elf_phdr_scratch times ELF_MAX_PHDRS * ELF_PHDR_SIZE db 0
user_segment_dest dd 0
user_segment_filesz dd 0
user_segment_memsz dd 0
user_segment_flags dd 0
process_exec_path_ptr dd 0
process_exec_target dd 0
process_exec_name83 dd 0
process_exec_load_addr dd 0
process_exec_max_bytes dd 0
process_exec_size dd 0
process_exec_first_cluster dw 0
align 4
process_exec_sectors_read dd 0
process_exec_entry dd 0
process_exec_last_error dd 0
process_exec_reject_active_target db 0
process_exec_target_reusable db 0
process_exec_dot_seen db 0
process_exec_base_len db 0
process_exec_ext_len db 0
align 4
process_exec_name83_buffer times 11 db 0
align 4
sys_exec_attempts dd 0
sys_exec_successes dd 0
sys_exec_failures dd 0
sys_exec_handoffs dd 0
sys_exec_scheduled dd 0
sys_exec_rollbacks dd 0
sys_exec_last_result dd 0
sys_exec_last_caller_pid dd 0xffffffff
sys_exec_last_parent_pid dd 0xffffffff
sys_exec_last_target_pid dd 0xffffffff
sys_exec_last_target_entry dd 0
sys_exec_last_target_stack dd 0
sys_exec_last_argc dd 0
sys_exec_last_argv dd 0
sys_exec_last_envp dd 0
sys_exec_last_argv0 dd 0
sys_exec_last_envp0 dd 0
sys_exec_last_argv_source dd 0
sys_exec_user_argv_arg dd 0
sys_exec_flags_arg dd 0
sys_exec_frame_ptr dd 0
sys_exec_user_stack_ptr dd 0
sys_exec_argv0_ptr dd 0
sys_exec_argc dd 0
sys_exec_arg_copy_index dd 0
sys_exec_stack_cursor dd 0
sys_exec_arg_target_ptrs times SYS_EXEC_ARG_MAX dd 0
sys_exec_arg_strings times SYS_EXEC_ARG_MAX * SYS_EXEC_ARG_STR_MAX db 0
sys_exec_path_buffer times SYS_EXEC_PATH_MAX db 0
syscall_ptr_arg dd 0
syscall_len_arg dd 0
syscall_stat_ptr dd 0
syscall_open_flags dd 0
fat_open_slot dd 0
fat_unlink_slot dd 0
stat_size_arg dd 0
stat_mode_arg dd 0
mmap_addr_arg dd 0
mmap_len_arg dd 0
mmap_prot_arg dd 0
mmap_flags_arg dd 0
mmap_base_arg dd 0
mmap_end_arg dd 0
file_io_fd_slot dd 0
fd_status times USER_FD_COUNT db 0
fd_kinds times USER_FD_COUNT db 0
align 4
fd_indices times USER_FD_COUNT dd 0
fd_offsets times USER_FD_COUNT dd 0
fd_flags times USER_FD_COUNT dd 0
fd_owner_pids times USER_FD_COUNT dd 0xffffffff
fd_open_generations times USER_FD_COUNT dd 0
fd_inherit_flags times USER_FD_COUNT dd 0
fd_exec_handoffs dd 0
fd_exec_inherited dd 0
fd_exec_closed dd 0
fd_owner_closes dd 0
fd_last_exec_from_pid dd 0xffffffff
fd_last_exec_to_pid dd 0xffffffff
fd_last_closed_owner_pid dd 0xffffffff
file_io_index dd 0
file_io_user_ptr dd 0
file_io_remaining dd 0
file_io_done dd 0
file_io_sector_lba dd 0
file_io_sector_offset dd 0
file_io_chunk dd 0
file_write_debug_stage dd 0
file_write_debug_result dd 0
file_write_debug_capacity dd 0
file_write_requested dd 0
file_write_capacity dd 0
file_write_fail_stage dd 0
user_probe_magic_seen dd 0
user_probe_flags_seen dd 0
user_fault_addr dd 0
user_fault_recovery dd 0
fault_vector dd 0
fault_error dd 0
fault_eip dd 0
fault_cs dd 0
fault_eflags dd 0
fault_esp dd 0
fault_ss dd 0
fault_cr2 dd 0
fault_pid dd 0
fault_kind dd 0
fault_state dd 0
fault_last_syscall dd 0
panic_status dd 0
shutdown_state dd 0
user_wad_magic_seen dd 0
user_brk_current dd 0
current_pid dd 0
current_process_ptr dd 0
current_user_base dd 0
current_user_end dd 0
current_user_brk dd 0
current_user_heap_start dd 0
current_user_heap_end dd 0
current_user_stack_top dd 0
current_user_entry dd 0
current_syscall_number dd 0
syscall_return_value dd 0
scheduler_tick_count dd 0
scheduler_round_count dd 0
scheduler_context_switches dd 0
scheduler_rr_cursor dd 0
scheduler_next_pid dd 0xffffffff
scheduler_next_process_ptr dd 0
scheduler_preempt_attempts dd 0
scheduler_preempt_switches dd 0
scheduler_irq_context_switches dd 0
scheduler_preempt_skips dd 0
scheduler_user_irq_ticks dd 0
scheduler_last_preempt_from_pid dd 0xffffffff
scheduler_last_preempt_to_pid dd 0xffffffff
scheduler_last_preempt_from_kind dd 0
scheduler_last_preempt_to_kind dd 0
scheduler_last_preempt_from_eip dd 0
scheduler_last_preempt_to_eip dd 0
scheduler_last_preempt_from_cr3 dd 0
scheduler_last_preempt_to_cr3 dd 0
scheduler_last_preempt_from_kstack dd 0
scheduler_last_preempt_to_kstack dd 0
scheduler_preempt_probe_ready dd 0
scheduler_preempt_spin_value dd 0
scheduler_preempt_selftest_frame times 13 dd 0
scheduler_preempt_selftest_status db 0
align 4
process_next_pid dd 4
process_slot_reuses dd 0
process_vm_teardowns dd 0
process_vm_pages_cleared dd 0
process_mmap_allocations dd 0
process_mmap_pages_mapped dd 0
process_munmap_attempts dd 0
process_munmap_pages_released dd 0
process_munmap_non_tail_kept dd 0
process_munmap_holes_punched dd 0
process_munmap_pages_unmapped dd 0
process_last_munmap_base dd 0
process_last_munmap_end dd 0
process_exit_teardowns dd 0
process_exec_teardowns dd 0
process_last_reused_slot dd 0
process_last_reused_pid dd 0xffffffff
process_last_slot_generation dd 0
process_last_teardown_pid dd 0xffffffff
process_last_teardown_base dd 0
process_last_teardown_end dd 0
process_generic_slot_allocations dd 0
process_generic_slot_failures dd 0
process_last_generic_slot dd 0
process_wait_attempts dd 0
process_wait_reaps dd 0
process_wait_failures dd 0
process_wait_last_pid_arg dd 0
process_wait_last_status_ptr dd 0
process_wait_last_options dd 0
process_wait_last_reaped_pid dd 0xffffffff
process_wait_last_status dd 0
process_wait_seen_live_child dd 0
process_wait_nohang_returns dd 0
process_wait_seeded_children dd 0
process_wait_seeded_child_pid dd 0xffffffff
doom_exit_code dd 0
doom_fault_addr dd 0
doom_fault_eip dd 0
doom_fault_vector dd 0
doom_fault_error dd 0
doom_last_syscall dd 0
doom_open_count dd 0
doom_read_count dd 0
doom_lseek_count dd 0
doom_write_count dd 0
doom_close_count dd 0
doom_sbrk_count dd 0
doom_error_count dd 0
doom_last_error dd 0
doom_last_open_flags dd 0
doom_last_open_mode dd 0
doom_saveload_flags dd 0
doom_saveload_slot dd 0xffffffff
doom_saveload_open_count dd 0
doom_saveload_read_count dd 0
doom_saveload_write_count dd 0
doom_saveload_close_count dd 0
doom_saveload_read_bytes dd 0
doom_saveload_write_bytes dd 0
doom_saveload_last_open_flags dd 0
doom_saveload_last_open_mode dd 0
doom_saveaction_flags dd 0
doom_saveaction_gameaction dd 0
doom_saveaction_slot dd 0xffffffff
doom_saveaction_desc_len dd 0
doom_saveaction_desc_hash dd 0
doom_saveaction_report_count dd 0
doom_present_count dd 0
doom_init_flags dd 0
doom_init_report_count dd 0
doom_key_event_count dd 0
doom_key_down_seen dd 0
doom_key_last_event dd 0
doom_mouse_event_count dd 0
doom_mouse_buttons_seen dd 0
doom_mouse_delta_x dd 0
doom_mouse_delta_y dd 0
doom_mouse_last_event dd 0
doom_gameplay_status dd 0
doom_gameplay_report_count dd 0
doom_game_state_packed dd 0
doom_game_state dd 0
doom_game_episode dd 0
doom_game_map dd 0
doom_game_map_pair dd 0
doom_game_flags dd 0
doom_game_tic dd 0
doom_level_time dd 0
doom_player_flags dd 0
doom_player_buttons dd 0
doom_game_action dd 0
doom_player_x dd 0
doom_player_y dd 0
doom_player_origin_set dd 0
doom_player_origin_x dd 0
doom_player_origin_y dd 0
doom_player_delta dd 0
doom_player_cmd dd 0
doom_player_angle dd 0
doom_player_angle_origin_set dd 0
doom_player_origin_angle dd 0
doom_player_angle_delta dd 0
doom_player_ammo dd 0
doom_player_refire dd 0
doom_player_weapon dd 0
doom_sound_call_count dd 0
doom_sound_start_count dd 0
doom_sound_stop_count dd 0
doom_sound_update_count dd 0
doom_sound_last_command dd 0
doom_sound_last_handle dd 0
doom_sound_last_packed dd 0
sb16_sfx_voice_start_count dd 0
sb16_sfx_voice_stop_count dd 0
sb16_sfx_voice_update_count dd 0
sb16_sfx_voice_finished_count dd 0
sb16_sfx_wad_start_count dd 0
sb16_sfx_submit_bytes dd 0
sb16_sfx_output_bytes dd 0
sb16_sfx_last_id dd 0
sb16_sfx_last_rate dd 0
sb16_sfx_last_length dd 0
doom_wad_magic_seen dd 0
doom_log_len dd 0
key_event_head dd 0
key_event_tail dd 0
keyboard_irq_count dd 0
keyboard_event_count dd 0
mouse_irq_count dd 0
mouse_event_head dd 0
mouse_event_tail dd 0
mouse_packet_count dd 0
mouse_sync_loss_count dd 0
present_frame_arg dd 0
present_palette_arg dd 0
present_sample_first dd 0
present_sample_mid dd 0
present_sample_last dd 0
present_palette_hash dd 0
present_frame_hash dd 0
present_nonzero_count dd 0
present_color_transition_count dd 0
present_previous_index db 0
align 4
present_dirty_x dd 0
present_dirty_y dd 0
present_dirty_width dd 0
present_dirty_height dd 0
present_dirty_count dd 0
present_dirty_min_x dd 0
present_dirty_min_y dd 0
present_dirty_max_x dd 0
present_dirty_max_y dd 0
present_lfb_policy dd PRESENT_POLICY_MODE13
present_lfb_scale dd 1
present_lfb_view_x dd 0
present_lfb_view_y dd 0
present_lfb_view_width dd DOOM_SCREEN_WIDTH
present_lfb_view_height dd DOOM_SCREEN_HEIGHT
framebuffer_addr dd 0
framebuffer_pitch dd 0
framebuffer_width dd 0
framebuffer_height dd 0
framebuffer_page_count dd 0
framebuffer_pde_index dd 0
framebuffer_pte_index dd 0
present_lfb_row dd 0
present_lfb_x_offset dd 0
present_lfb_rows_left dd 0
present_lfb_source_y dd 0
present_lfb_repeat_rows dd 0
pci_probe_count dd 0
pci_function_count dd 0
pci_first_bdf dd 0
pci_first_id dd 0
pci_first_class dd 0
pci_last_bdf dd 0
pci_class_table_hash dd 0
pci_multifunction_device_count dd 0
pci_mass_storage_class_count dd 0
pci_bridge_class_count dd 0
pci_config_status db 0
align 4
pci_device_table times PCI_TABLE_MAX_ENTRIES * PCI_TABLE_ENTRY_DWORDS dd 0
audio_status db 0
sb16_major_version db 0
sb16_minor_version db 0
sb16_playback_active db 0
align 4
sb16_irq_count dd 0
sb16_irq_ack8_count dd 0
sb16_irq_ack16_count dd 0
sb16_irq_refill_count dd 0
sb16_irq_half_index dd 0
sb16_playback_start_count dd 0
sb16_playback_stop_count dd 0
sb16_dma_program_count dd 0
sb16_sfx_mix_count dd 0
sb16_sfx_mix_bytes dd 0
sb16_sfx_dma_mix_count dd 0
sb16_sfx_dma_mix_bytes dd 0
sb16_dma_write_pos dd 0
sb16_mix_clip_count dd 0
sb16_mix_underrun_count dd 0
sb16_mix_wrap_count dd 0
sb16_mix_overwrite_count dd 0
sb16_active_voice_count dd 0
sb16_active_sfx_voice_count dd 0
sb16_active_music_voice_count dd 0
sb16_voice_start_count dd 0
sb16_voice_stop_count dd 0
sb16_voice_update_count dd 0
sb16_voice_refill_count dd 0
sb16_voice_finished_count dd 0
sb16_voice_steal_count dd 0
sb16_voice_age_counter dd 0
sb16_pitch_clamp_count dd 0
sb16_pan_clamp_count dd 0
sb16_music_start_count dd 0
sb16_music_stop_count dd 0
sb16_music_mix_count dd 0
sb16_music_mix_bytes dd 0
sb16_music_loop_count dd 0
sb16_music_stream_pos_bytes dd 0
sb16_music_stream_buffer_bytes dd 0
sb16_music_stream_under_count dd 0
sb16_music_stream_drop_count dd 0
sb16_music_stream_mode dd AUDIO_MUSIC_STREAM_NONE
sb16_music_pull_request_count dd 0
sb16_music_pull_refill_count dd 0
sb16_music_render_format dd 0
sb16_music_render_chunk_count dd 0
sb16_music_render_note_count dd 0
sb16_music_render_event_count dd 0
sb16_music_render_active_peak dd 0
sb16_music_render_sample_count dd 0
sb16_music_stream_calc_pos dd 0
audio_sfx_desc_arg dd 0
audio_sfx_handle_arg dd 0
audio_sfx_sample_arg dd 0
audio_sfx_length_arg dd 0
audio_sfx_volume_arg dd 0
audio_sfx_separation_arg dd 0
audio_sfx_pitch_arg dd 0
audio_sfx_id_arg dd 0
audio_sfx_flags_arg dd 0
audio_sfx_rate_arg dd 0
audio_sfx_voice_slot dd 0
sb16_pan_left_arg dd 0
sb16_pan_right_arg dd 0
sb16_mix_source_pos dd 0
sb16_mix_source_step dd AUDIO_PITCH_STEP_NORMAL
sb16_mix_left_volume dd 0
sb16_mix_right_volume dd 0
sb16_mix_frames_mixed dd 0
sb16_mix_voice_slot dd 0
sb16_refill_dest_base dd 0
sb16_refill_chunk_bytes dd 0
sb16_voice_active times AUDIO_MAX_SFX_VOICES db 0
align 4
sb16_voice_handles times AUDIO_MAX_SFX_VOICES dd 0
sb16_voice_samples times AUDIO_MAX_SFX_VOICES dd 0
sb16_voice_lengths times AUDIO_MAX_SFX_VOICES dd 0
sb16_voice_positions times AUDIO_MAX_SFX_VOICES dd 0
sb16_voice_volumes times AUDIO_MAX_SFX_VOICES dd 0
sb16_voice_separations times AUDIO_MAX_SFX_VOICES dd 0
sb16_voice_pitches times AUDIO_MAX_SFX_VOICES dd 0
sb16_voice_steps times AUDIO_MAX_SFX_VOICES dd 0
sb16_voice_left_volumes times AUDIO_MAX_SFX_VOICES dd 0
sb16_voice_right_volumes times AUDIO_MAX_SFX_VOICES dd 0
sb16_voice_started_at times AUDIO_MAX_SFX_VOICES dd 0
sb16_voice_flags times AUDIO_MAX_SFX_VOICES dd 0
sb16_voice_loop_counts times AUDIO_MAX_SFX_VOICES dd 0
sb16_voice_pending_samples times AUDIO_MAX_SFX_VOICES dd 0
sb16_voice_pending_lengths times AUDIO_MAX_SFX_VOICES dd 0
sb16_dma_buffer_phys dd 0
sb16_dma_buffer_size dd 0
sb16_dma_block_size dd 0
mouse_status db 0
ps2_mouse_command_byte db 0
mouse_packet_index db 0
mouse_packet0 db 0
mouse_packet1 db 0
mouse_packet2 db 0
align 4096
sb16_dma_buffer times SB16_DMA_BUFFER_BYTES db 0x80
align 4
heap_start dd 0
heap_free_head dd 0
heap_end dd 0
heap_alloc_count dd 0
heap_alloc_bytes dd 0
heap_last_ptr dd 0
command_start dd 0
writable_sizes times WRITABLE_FILE_COUNT dd 0
persistence_marker_sizes times PERSISTENCE_MARKER_COUNT dd 0
writable_root_lbas times WRITABLE_FILE_COUNT dd 0
writable_root_offsets times WRITABLE_FILE_COUNT dd 0
writable_offsets times WRITABLE_FILE_COUNT dd 0
fat_current_cluster dw 0
fat_found_first_cluster dw 0
wad_first_cluster dw 0
user_elf_first_cluster dw 0
doom_elf_first_cluster dw 0
fat_mut_value dw 0
fat_new_cluster dw 0
fat_free_next_cluster dw 0
writable_first_clusters times WRITABLE_FILE_COUNT dw 0
user_probe_cs dw 0
user_probe_ss dw 0
fat_sectors_per_cluster db 0
fat_open_dot_seen db 0
fat_open_base_len db 0
fat_open_ext_len db 0
fat_open_name_buffer times 11 db 0
user_load_segment_count db 0
doom_load_segment_count db 0
present_status db 0
video_backend db 0
framebuffer_status db 0
framebuffer_map_status db 0
shift_down db 0
keyboard_extended db 0
writable_status times WRITABLE_FILE_COUNT db 0
persistence_marker_status times PERSISTENCE_MARKER_COUNT db 0
doom_log_buffer times DOOM_LOG_BYTES db 0
key_event_queue times KEY_QUEUE_SIZE dd 0
mouse_event_queue times MOUSE_QUEUE_SIZE dd 0
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
