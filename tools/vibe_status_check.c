#include <ctype.h>
#include <errno.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_FIELDS 1024
#define MAX_FILE_BYTES (1024 * 1024)
#define ARRAY_LEN(a) (sizeof(a) / sizeof((a)[0]))
#define MAX_HEX64_TUPLE_FIELDS 16
#define STATUS_RECORD_PREFIX "vibe-status"

#define KERNEL_HIGHER_HALF_BASE 0xC0000000u
#define KERNEL_LOW_LINK_BASE 0x00010000u
#define KERNEL_HIGH_LINK_BASE (KERNEL_HIGHER_HALF_BASE + KERNEL_LOW_LINK_BASE)
#define KERNEL_ELF_MAX_BYTES 0x00028000u
#define PAGE_SIZE 0x1000u
#define KERNEL_STACK_LOW 0x00060000u
#define KERNEL_STACK_TOP 0x00070000u
#define KERNEL_HIGH_STACK_LOW (KERNEL_HIGHER_HALF_BASE + KERNEL_STACK_LOW)
#define KERNEL_HIGH_STACK_TOP (KERNEL_HIGHER_HALF_BASE + KERNEL_STACK_TOP)
#define KERNEL_HIGH_MAINLINE_MIN_CHECKPOINTS 2u
#define KERNEL_HIGH_ABI_ENTRY_CHECKPOINT 0x00000001u
#define KERNEL_HIGH_ABI_LATE_CHECKPOINT 0x00000002u
#define KERNEL_HIGH_ABI_IDT_BIAS 0x00000004u
#define KERNEL_HIGH_ABI_TSS_ESP0 0x00000008u
#define KERNEL_HIGH_ABI_HIGH_EIP 0x00000010u
#define KERNEL_HIGH_ABI_HIGH_ESP 0x00000020u
#define KERNEL_HIGH_ABI_TEXT_XLAT 0x00000040u
#define KERNEL_HIGH_ABI_STACK_XLAT 0x00000080u
#define KERNEL_HIGH_ABI_PTE_CHECK 0x00000100u
#define KERNEL_HIGH_ABI_LOW_ID_RETAINED 0x00000200u
#define KERNEL_HIGH_ABI_HIGH_DATA_WRITE 0x00000400u
#define KERNEL_HIGH_ABI_FULL_MASK \
    (KERNEL_HIGH_ABI_ENTRY_CHECKPOINT | KERNEL_HIGH_ABI_LATE_CHECKPOINT | \
     KERNEL_HIGH_ABI_IDT_BIAS | KERNEL_HIGH_ABI_TSS_ESP0 | KERNEL_HIGH_ABI_HIGH_EIP | \
     KERNEL_HIGH_ABI_HIGH_ESP | KERNEL_HIGH_ABI_TEXT_XLAT | KERNEL_HIGH_ABI_STACK_XLAT | \
     KERNEL_HIGH_ABI_PTE_CHECK | KERNEL_HIGH_ABI_LOW_ID_RETAINED | \
     KERNEL_HIGH_ABI_HIGH_DATA_WRITE)
#define PAGING_DIR_ADDR 0x00090000u
#define PROC_PROBE_PAGE_DIR_ADDR 0x00080000u
#define PROC_PAYLOAD_PAGE_DIR_ADDR 0x00082000u
#define PROC_PREEMPT_PAGE_DIR_ADDR 0x00083000u
#define PROC_GENERIC0_PAGE_DIR_ADDR 0x00089000u
#define PROC_GENERIC1_PAGE_DIR_ADDR 0x0008B000u
#define PTE_PRESENT 0x001u
#define PTE_WRITE 0x002u
#define PTE_KERNEL_FLAGS (PTE_PRESENT | PTE_WRITE)
#define LOW_IDENTITY_PRESENT 0x00000001u
#define LOW_IDENTITY_TRAPPED 0x00000002u
#define MISSING_TRANSLATION 0xFFFFFFFFu
#define PMM_MANAGED_START 0x00100000u
#define PMM_MANAGED_END 0x02000000u
#define KERNEL_RELOCATION_LIVE_MAGIC 0x4B524C56u
#define KERNEL_RELOC_ABI_DIR_ALLOC 0x00000001u
#define KERNEL_RELOC_ABI_HIGH_PDE 0x00000002u
#define KERNEL_RELOC_ABI_LOW_PDE_ABSENT 0x00000004u
#define KERNEL_RELOC_ABI_TEXT_XLAT 0x00000008u
#define KERNEL_RELOC_ABI_STACK_XLAT 0x00000010u
#define KERNEL_RELOC_ABI_LOW_XLAT_ABSENT 0x00000020u
#define KERNEL_RELOC_ABI_LIVE_CR3_SWITCH 0x00000040u
#define KERNEL_RELOC_ABI_HIGH_DATA_WRITE 0x00000080u
#define KERNEL_RELOC_ABI_LOW_RETURN_BLOCKED 0x00000100u
#define KERNEL_RELOC_ABI_RETURN_CR3_RESTORED 0x00000200u
#define KERNEL_RELOC_ABI_FULL_MASK \
    (KERNEL_RELOC_ABI_DIR_ALLOC | KERNEL_RELOC_ABI_HIGH_PDE | \
     KERNEL_RELOC_ABI_LOW_PDE_ABSENT | KERNEL_RELOC_ABI_TEXT_XLAT | \
     KERNEL_RELOC_ABI_STACK_XLAT | KERNEL_RELOC_ABI_LOW_XLAT_ABSENT | \
     KERNEL_RELOC_ABI_LIVE_CR3_SWITCH | KERNEL_RELOC_ABI_HIGH_DATA_WRITE | \
     KERNEL_RELOC_ABI_LOW_RETURN_BLOCKED | KERNEL_RELOC_ABI_RETURN_CR3_RESTORED)
#define USER_KIND_PAYLOAD_PRIMARY 2u
#define USER_KIND_PREEMPT_PROBE 3u
#define USER_KIND_PAYLOAD_SECONDARY 5u
#define USER_CODE_SEG 0x1Bu
#define USER_DATA_SEG 0x23u
#define PAYLOAD_USER_BASE 0x01000000u
#define PAYLOAD_USER_STACK_TOP 0x02000000u
#define PROBE_USER_BASE 0x00E80000u
#define PROBE_USER_END 0x00F00000u
#define SCHEDULER_QUANTUM_TICKS 5u
#define PREEMPT_ABI_USER_IRQ_FRAME 0x00000001u
#define PREEMPT_ABI_SAVE_CONTEXT 0x00000002u
#define PREEMPT_ABI_TIMER_ATTEMPT 0x00000004u
#define PREEMPT_ABI_SELECT_TARGET 0x00000008u
#define PREEMPT_ABI_ACTIVATE_TARGET 0x00000010u
#define PREEMPT_ABI_RESTORE_FRAME 0x00000020u
#define PREEMPT_ABI_REWRITE_IRQ_FRAME 0x00000040u
#define PREEMPT_ABI_ACCOUNT_SWITCH 0x00000080u
#define PREEMPT_ABI_CAPTURE_SPIN 0x00000100u
#define PREEMPT_ABI_FULL_MASK \
    (PREEMPT_ABI_USER_IRQ_FRAME | PREEMPT_ABI_SAVE_CONTEXT | \
     PREEMPT_ABI_TIMER_ATTEMPT | PREEMPT_ABI_SELECT_TARGET | \
     PREEMPT_ABI_ACTIVATE_TARGET | PREEMPT_ABI_RESTORE_FRAME | \
     PREEMPT_ABI_REWRITE_IRQ_FRAME | PREEMPT_ABI_ACCOUNT_SWITCH | \
     PREEMPT_ABI_CAPTURE_SPIN)
#define SYSCALL_RETURN_EFLAGS_SET 0x00000202u
#define SYSCALL_RETURN_EFLAGS_KEEP_MASK 0xFFF88AFFu
#define USER_EFLAGS_RF 0x00010000u
#define SYS_EXEC_ARGV_SOURCE_USER 2u
#define VFS_ABI_OPEN 0x00000001u
#define VFS_ABI_READ 0x00000002u
#define VFS_ABI_WRITE 0x00000004u
#define VFS_ABI_LSEEK 0x00000008u
#define VFS_ABI_STAT 0x00000010u
#define VFS_ABI_FSTAT 0x00000020u
#define VFS_ABI_LISTDIR 0x00000040u
#define VFS_ABI_UNLINK 0x00000080u
#define VFS_ABI_FTRUNCATE 0x00000100u
#define VFS_ABI_CLOSE 0x00000200u
#define VFS_ABI_FULL_MASK \
    (VFS_ABI_OPEN | VFS_ABI_READ | VFS_ABI_WRITE | VFS_ABI_LSEEK | VFS_ABI_STAT | \
     VFS_ABI_FSTAT | VFS_ABI_LISTDIR | VFS_ABI_UNLINK | VFS_ABI_FTRUNCATE | VFS_ABI_CLOSE)
#define FAT_ABI_ALLOC_CLUSTER 0x00000001u
#define FAT_ABI_FREE_CHAIN 0x00000002u
#define FAT_ABI_FREE_TAIL 0x00000004u
#define FAT_ABI_TRUNCATE_ZERO 0x00000008u
#define FAT_ABI_RESIZE_GROW 0x00000010u
#define FAT_ABI_RESIZE_SHRINK 0x00000020u
#define FAT_ABI_DELETE_FILE 0x00000040u
#define FAT_ABI_DIR_UPDATE 0x00000080u
#define FAT_ABI_ACCOUNTING 0x00000100u
#define FAT_ABI_FULL_MASK \
    (FAT_ABI_ALLOC_CLUSTER | FAT_ABI_FREE_CHAIN | FAT_ABI_FREE_TAIL | \
     FAT_ABI_TRUNCATE_ZERO | FAT_ABI_RESIZE_GROW | FAT_ABI_RESIZE_SHRINK | \
     FAT_ABI_DELETE_FILE | FAT_ABI_DIR_UPDATE | FAT_ABI_ACCOUNTING)
#define USER_ELF_LOAD_ADDR 0x00E40000u
#define USER_ELF_MAX_BYTES 0x00040000u
#define VIBE_INPUT_EVENT_QUEUE_USABLE_CAPACITY 63u
#define VIBE_INPUT_DEVICE_KEYBOARD 1u
#define VIBE_INPUT_DEVICE_MOUSE 2u
#define PI4_INPUT_DEVICE_UART 3u
#define PI4_INPUT_DEVICE_USB 4u
#define VIBE_INPUT_EVENT_KEY 1u
#define VIBE_INPUT_EVENT_MOUSE_PACKET 2u
#define PI4_INPUT_EVENT_UART 3u
#define VIBE_INPUT_QUEUE_OVERFLOW_DROP_OLDEST 1u
#define VIBE_INPUT_CAP_KEYBOARD 0x00000001u
#define VIBE_INPUT_CAP_MOUSE 0x00000002u
#define VIBE_INPUT_CAP_POLL_EVENT 0x00000004u
#define VIBE_INPUT_CAP_STATUS 0x00000008u
#define VIBE_INPUT_CAP_DEVICE_STATUS 0x00000010u
#define PI4_INPUT_CAP_UART_SERIAL 0x00000020u
#define VIBE_INPUT_REQUIRED_CAPS \
    (VIBE_INPUT_CAP_POLL_EVENT | VIBE_INPUT_CAP_STATUS | VIBE_INPUT_CAP_DEVICE_STATUS)
#define PI4_UART_INPUT_REQUIRED_CAPS \
    (VIBE_INPUT_REQUIRED_CAPS | PI4_INPUT_CAP_UART_SERIAL)
#define PI4_UART_INPUT_QUEUE_SIZE 8u
#define PI4_UART_INPUT_EVENT_COUNTER_FIELDS 5u
#define PI4_UART_INPUT_EVENT_MAX 5u
#define PI4_UART_INPUT_EVENT_DOOM_SELECT_INDEX 0u
#define PI4_UART_INPUT_EVENT_QUAKE_SELECT_INDEX 1u
#define PI4_UART_INPUT_EVENT_LAUNCH_CLICK_INDEX 2u
#define PI4_UART_INPUT_EVENT_DOOM_GAMEPLAY_INDEX 3u
#define PI4_UART_INPUT_EVENT_QUAKE_GAMEPLAY_INDEX 4u
#define VIBE_INPUT_MOD_MASK 0x00000007u
#define VIBE_INPUT_DEVICE_STATUS_READY 1u
#define VIBE_INPUT_DEVICE_STATUS_ERROR 2u
#define INPUT_ABI_POLL_EVENT 0x00000001u
#define INPUT_ABI_STATUS 0x00000002u
#define INPUT_ABI_KEYBOARD_STATUS 0x00000004u
#define INPUT_ABI_MOUSE_STATUS 0x00000008u
#define INPUT_ABI_FULL_MASK \
    (INPUT_ABI_POLL_EVENT | INPUT_ABI_STATUS | INPUT_ABI_KEYBOARD_STATUS | INPUT_ABI_MOUSE_STATUS)
#define AUDIO_DEVICE_NONE 0u
#define AUDIO_DEVICE_SB16 1u
#define AUDIO_CAP_PCM_RING 0x00000001u
#define AUDIO_CAP_MIXER_VOICES 0x00000002u
#define AUDIO_CAP_PULL_STREAM 0x00000004u
#define AUDIO_CAP_SB16_DMA 0x00000008u
#define AUDIO_REQUIRED_CAPS \
    (AUDIO_CAP_PCM_RING | AUDIO_CAP_MIXER_VOICES | AUDIO_CAP_PULL_STREAM | AUDIO_CAP_SB16_DMA)
#define AUDIO_PCM_QUEUE_BYTES 65536u
#define SB16_DMA_BUFFER_BYTES 4096u
#define SB16_DMA_BLOCK_BYTES 2048u
#define AUDIO_STREAM_PULL 2u
#define SB16_DMA_STATUS_FAIL 2u
#define SB16_DMA_ERROR_DSP 2u
#define AUDIO_ABI_DEVICE_START 0x00000001u
#define AUDIO_ABI_DEVICE_INFO 0x00000002u
#define AUDIO_ABI_PCM_RING_INFO 0x00000004u
#define AUDIO_ABI_STREAM_INFO 0x00000008u
#define AUDIO_ABI_PCM_OPEN 0x00000010u
#define AUDIO_ABI_PCM_WRITE 0x00000020u
#define AUDIO_ABI_PCM_BUFFERED_BYTES 0x00000040u
#define AUDIO_ABI_PCM_DRAIN 0x00000080u
#define AUDIO_ABI_PCM_CLOSE 0x00000100u
#define AUDIO_ABI_FULL_MASK \
    (AUDIO_ABI_DEVICE_START | AUDIO_ABI_DEVICE_INFO | AUDIO_ABI_PCM_RING_INFO | \
     AUDIO_ABI_STREAM_INFO | AUDIO_ABI_PCM_OPEN | AUDIO_ABI_PCM_WRITE | \
     AUDIO_ABI_PCM_BUFFERED_BYTES | AUDIO_ABI_PCM_DRAIN | AUDIO_ABI_PCM_CLOSE)
#define AUDIO_CMD_PCM_CLOSE 16u
#define VIDEO_BACKEND_MODE13 1u
#define VIDEO_BACKEND_LFB_XRGB8888 2u
#define FRAMEBUFFER_HANDOFF_SOURCE_VGA_MODE13 1u
#define FRAMEBUFFER_HANDOFF_SOURCE_GOP 3u
#define VIBE_FB_CAP_PRESENT_INDEXED 0x00000001u
#define VIBE_FB_CAP_PRESENT_RGB_PALETTE 0x00000002u
#define VIBE_FB_CAP_XRGB8888_LFB 0x00000004u
#define VIBE_FB_CAP_MODE13_SHADOW 0x00000008u
#define VIBE_FB_CAP_DIRTY_SOURCE_RECT 0x00000010u
#define VIBE_FB_CAP_FIXED_PRESENT_SIZE 0x00000020u
#define VIBE_FB_CAP_XBGR8888_LFB 0x00000040u
#define VIBE_FB_CAP_DIRECT8888_LFB (VIBE_FB_CAP_XRGB8888_LFB | VIBE_FB_CAP_XBGR8888_LFB)
#define VIBE_FB_REQUIRED_CAPS \
    (VIBE_FB_CAP_PRESENT_INDEXED | VIBE_FB_CAP_PRESENT_RGB_PALETTE | VIBE_FB_CAP_DIRTY_SOURCE_RECT)
#define VIBE_FB_FORMAT_INDEX8_RGB24 1u
#define FRAMEBUFFER_ABI_VERSION 1u
#define FRAMEBUFFER_PRESENT_SEMANTICS_INDEXED_SOURCE 1u
#define FRAMEBUFFER_PRESENT_SOURCE_SYS 1u
#define FRAMEBUFFER_PRESENT_SOURCE_IOCTL 2u
#define FB_PRESENT_WIDTH 320u
#define FB_PRESENT_HEIGHT 200u
#define PI4_FB_PRESENT_WIDTH FB_PRESENT_WIDTH
#define PI4_FB_PRESENT_HEIGHT FB_PRESENT_HEIGHT
#define FB_PRESENT_ASPECT_HEIGHT 240u
#define FB_PRESENT_FRAME_BYTES (FB_PRESENT_WIDTH * FB_PRESENT_HEIGHT)
#define FB_PRESENT_PALETTE_ENTRIES 256u
#define FB_PRESENT_PALETTE_ENTRY_BYTES 3u
#define FB_PRESENT_PALETTE_BYTES (FB_PRESENT_PALETTE_ENTRIES * FB_PRESENT_PALETTE_ENTRY_BYTES)
#define FB_ABI_INFO 0x00000001u
#define FB_ABI_PRESENT 0x00000002u
#define FB_ABI_DIRTY 0x00000004u
#define FB_ABI_IOCTL_PRESENT 0x00000008u
#define FB_ABI_FULL_MASK (FB_ABI_INFO | FB_ABI_PRESENT | FB_ABI_DIRTY | FB_ABI_IOCTL_PRESENT)
#define PI4_KERNEL8_LOAD_ADDR 0x00080000ull
#define PI4_EMMC2_LEGACY_BASE 0x7E340000ull
#define PI4_EMMC2_ARM_BASE 0xFE340000ull
#define PI4_EMMC_LEGACY_BASE 0x7E300000ull
#define PI4_EMMC_ARM_BASE 0xFE300000ull
#define PI4_EMMC2_MIN_REG_SPAN 0x100ull
#define PI4_MIN_STACK_BYTES 128ull
#define PI4_MAX_STACK_BYTES 0x00100000ull
#define PI4_BLOCK_READ_MAX_COUNT 1024ull
#define PI4_BLOCK_READ_SECTOR_BYTES 512ull
#define PI4_BLOCK_READ_RESULT_WAIT 0xFFFFFFFFFFFFFFF5ull
#define PI4_BLOCK_READ_RESULT_EIO 0xFFFFFFFFFFFFFFFBull
#define PI4_BLOCK_READ_RESULT_EINVAL 0xFFFFFFFFFFFFFFEAull
#define PI4_BLOCK_READ_RESULT_ENOSYS 0xFFFFFFFFFFFFFFDAull
#define PI4_STORAGE_STATUS_SD_OK 0x0000000053444F4Bull
#define PI4_EL0_ALLOC_REQUIRED_FLAGS 0x0000000Full
#define PI4_EL0_ALLOC_BOOT_COUNT 2ull
#define PI4_VIBE_SYS_EXEC 16ull
#define PI4_VIBE_EINVAL 22ull
#define PI4_VIBE_ENOSYS 38ull
#define PI4_VIBE_EXEC_REQUEST_ABI_VERSION 1ull
#define PI4_VIBE_EXEC_REQUEST_BYTES 32ull
#define PI4_VIBE_EXEC_REQUEST_PATH_MAX_BYTES 16ull
#define PI4_VIBE_USER_START_REQUIRED_FLAGS 0x0000001Full
#define PI4_VIBE_INPUT_EVENT_BYTES 56ull
#define PI4_VIBE_INPUT_STATUS_BYTES 264ull
#define PI4_VIBE_INPUT_DEVICE_STATUS_BYTES 128ull
#define PI4_VIBE_FB_INFO_BYTES 168ull
#define PI4_VIBE_PRESENT_INDEXED_BYTES 32ull
#define PI4_VIBE_FB_RGB24_PALETTE_BYTES 768ull
#define PI4_VIBE_PAYLOAD_SLOT0 0ull
#define PI4_VIBE_PAYLOAD_SLOT1 1ull
#define PI4_VIBE_FD_DOOM1_WAD 3ull
#define PI4_VIBE_FD_PAK0_PAK 4ull
#define PI4_VIBE_ENOENT 2ull
#define PI4_USER_FILE_OP_OPEN 0x00000001ull
#define PI4_USER_FILE_OP_SIZE 0x00000002ull
#define PI4_USER_FILE_OP_READ 0x00000004ull
#define PI4_USER_FILE_OP_FULL_MASK \
    (PI4_USER_FILE_OP_OPEN | PI4_USER_FILE_OP_SIZE | PI4_USER_FILE_OP_READ)
#define PI4_USER_FILE_ASSET_DOOM1_WAD 1ull
#define PI4_USER_FILE_ASSET_PAK0_PAK 2ull
#define PI4_USER_FILE_MAGIC_IWAD 0x0000000044415749ull
#define PI4_USER_FILE_MAGIC_PWAD 0x0000000044415750ull
#define PI4_USER_FILE_MAGIC_PACK 0x000000004B434150ull
#define PI4_AUDIO_CAP_MMIO_WINDOW 0x00000001ull
#define PI4_AUDIO_CAP_MAILBOX_CLOCK 0x00000002ull
#define PI4_AUDIO_CAP_PCM_QUEUE 0x00000004ull
#define PI4_AUDIO_REQUIRED_CAPS \
    (PI4_AUDIO_CAP_MMIO_WINDOW | PI4_AUDIO_CAP_MAILBOX_CLOCK | PI4_AUDIO_CAP_PCM_QUEUE)
#define PI4_AUDIO_DEVICE_PI4_PWM 2ull
#define PI4_AUDIO_DEVICE_STATUS_READY 1ull
#define PI4_AUDIO_FORMAT_U8_STEREO 1ull
#define PI4_AUDIO_CHANNELS 2ull
#define PI4_AUDIO_ABI_DEVICE_STATUS 0x00000001ull
#define PI4_AUDIO_ABI_QUEUE_STATUS 0x00000002ull
#define PI4_AUDIO_ABI_CAP_STATUS 0x00000004ull
#define PI4_AUDIO_ABI_FULL_MASK \
    (PI4_AUDIO_ABI_DEVICE_STATUS | PI4_AUDIO_ABI_QUEUE_STATUS | PI4_AUDIO_ABI_CAP_STATUS)
#define PI4_PROC_TABLE_ENTRY_BYTES 64ull
#define PI4_PROC_CONTEXT_BYTES 64ull
#define PI4_PROC_CONTEXT_VERSION 1ull
#define PI4_PROC_CONTEXT_FLAG_EL0_FRAME 0x00000001ull
#define PI4_PROC_CONTEXT_FLAG_TIMER_IRQ 0x00000002ull
#define PI4_PROC_CONTEXT_REQUIRED_FLAGS \
    (PI4_PROC_CONTEXT_FLAG_EL0_FRAME | PI4_PROC_CONTEXT_FLAG_TIMER_IRQ)
#define PI4_FAT_ATTR_LONG_NAME 0x0Full
#define PI4_FAT_ATTR_VOLUME_ID 0x08ull
#define PI4_FAT_ATTR_DIRECTORY 0x10ull
#define PI4_FAT_ATTR_ARCHIVE 0x20ull
#define PI4_STORAGE_FILE_STATUS_OK 0x00000000464F4F4Bull
#define PI4_STORAGE_ASSET_COVERAGE_WAD 0x00000001ull
#define PI4_STORAGE_ASSET_COVERAGE_MANIFEST 0x00000002ull
#define PI4_STORAGE_ASSET_COVERAGE_PAK0 0x00000004ull
#define PI4_STORAGE_ASSET_COVERAGE_DEFAULT_FILES 0x00000008ull
#define PI4_STORAGE_ASSET_REQUIRED_COVERAGE \
    (PI4_STORAGE_ASSET_COVERAGE_WAD | PI4_STORAGE_ASSET_COVERAGE_MANIFEST | \
     PI4_STORAGE_ASSET_COVERAGE_DEFAULT_FILES)
#define PI4_MBR_PART_TYPE_FAT16 0x06ull
#define PI4_MBR_PART_TYPE_FAT32_CHS 0x0Bull
#define PI4_MBR_PART_TYPE_FAT32_LBA 0x0Cull
#define PI4_SDHCI_CMD17_READ_SINGLE 0x0000113Aull
#define PI4_SDHCI_CMD18_READ_MULTI 0x0000123Aull
#define PI4_SDHCI_TRANSFER_READ_SINGLE 0x00000012ull
#define PI4_SDHCI_TRANSFER_READ_MULTI 0x00000036ull
#define PI4_SDHCI_PIO_WORDS_PER_SECTOR 128ull
#define PI4_ELF64_PHDR_SIZE 56ull

typedef struct {
    const char *name;
    const char *value;
} StatusField;

typedef struct {
    char *text;
    StatusField fields[MAX_FIELDS];
    size_t count;
    const char *path;
} Status;

typedef struct {
    int require_exec;
    int require_preempt;
    int require_vfs_abi;
    int require_device_abi;
    int pi4_local_qemu;
    const char *pi4_final_gates_path;
    const char *pi4_final_gates_single_artifact_path;
    const char *pi4_final_gates_single_artifact_sha256;
} CheckOptions;

static const char *current_context = "vibe_status_check";

static void fail(const char *fmt, ...) {
    va_list ap;

    fprintf(stderr, "%s: ", current_context);
    va_start(ap, fmt);
    vfprintf(stderr, fmt, ap);
    va_end(ap);
    fputc('\n', stderr);
    exit(1);
}

static void *xmalloc(size_t size) {
    void *ptr = malloc(size);
    if (!ptr) {
        fail("out of memory allocating %zu bytes", size);
    }
    return ptr;
}

static char *read_text_file(const char *path) {
    FILE *fp = fopen(path, "rb");
    long size;
    char *buf;
    size_t got;

    if (!fp) {
        fail("could not open %s: %s", path, strerror(errno));
    }
    if (fseek(fp, 0, SEEK_END) != 0) {
        fail("could not seek %s", path);
    }
    size = ftell(fp);
    if (size < 0) {
        fail("could not size %s", path);
    }
    if (size > MAX_FILE_BYTES) {
        fail("%s is too large for a status/contract file", path);
    }
    if (fseek(fp, 0, SEEK_SET) != 0) {
        fail("could not rewind %s", path);
    }
    buf = xmalloc((size_t)size + 1u);
    got = fread(buf, 1, (size_t)size, fp);
    if (got != (size_t)size) {
        fail("could not read %s", path);
    }
    if (fclose(fp) != 0) {
        fail("could not close %s", path);
    }
    buf[size] = '\0';
    return buf;
}

static int valid_field_name_span(const char *name, size_t len) {
    const unsigned char *p = (const unsigned char *)name;
    const unsigned char *end = p + len;

    if (len == 0u || !isalpha(*p)) {
        return 0;
    }
    for (; p < end; p++) {
        if (!isalnum(*p) && *p != '_') {
            return 0;
        }
    }
    return 1;
}

static int valid_field_name(const char *name) {
    return valid_field_name_span(name, strlen(name));
}

static int line_has_status_record_prefix(const char *line) {
    size_t n = strlen(STATUS_RECORD_PREFIX);

    return strncmp(line, STATUS_RECORD_PREFIX, n) == 0 &&
           (line[n] == '\0' || isspace((unsigned char)line[n]));
}

static int line_starts_with_status_field(const char *line) {
    const char *name;

    while (*line == ' ' || *line == '\t' || *line == '\r') {
        line++;
    }
    name = line;
    while (*line && !isspace((unsigned char)*line) && *line != '=') {
        line++;
    }
    return *line == '=' && valid_field_name_span(name, (size_t)(line - name));
}

static char *find_last_status_record(char *text) {
    char *line = text;
    char *last = NULL;

    while (*line) {
        char *next;

        if (line_has_status_record_prefix(line)) {
            last = line;
        }
        next = strchr(line, '\n');
        if (!next) {
            break;
        }
        line = next + 1;
    }
    return last;
}

static char *select_status_parse_text(char *text) {
    char *record = find_last_status_record(text);
    char *line_end;
    char *block_end;
    char *scan;

    if (!record) {
        return text;
    }

    record += strlen(STATUS_RECORD_PREFIX);
    line_end = strpbrk(record, "\r\n");
    if (!line_end) {
        return record;
    }

    block_end = line_end;
    scan = line_end;
    while (*scan == '\r' || *scan == '\n') {
        scan++;
    }
    while (*scan && line_starts_with_status_field(scan)) {
        char *next = strpbrk(scan, "\r\n");

        if (!next) {
            block_end = scan + strlen(scan);
            break;
        }
        block_end = next;
        scan = next;
        while (*scan == '\r' || *scan == '\n') {
            scan++;
        }
    }
    *block_end = '\0';
    return record;
}

static void parse_status(Status *status, const char *path) {
    char *p;

    memset(status, 0, sizeof(*status));
    status->path = path;
    status->text = read_text_file(path);
    p = select_status_parse_text(status->text);

    while (*p) {
        char *start;
        char *eq;
        char *end;
        size_t i;

        while (*p && isspace((unsigned char)*p)) {
            p++;
        }
        if (!*p) {
            break;
        }
        start = p;
        while (*p && !isspace((unsigned char)*p)) {
            p++;
        }
        end = p;
        if (*p) {
            *p++ = '\0';
        }
        eq = strchr(start, '=');
        if (!eq) {
            continue;
        }
        *eq = '\0';
        if (!valid_field_name(start)) {
            fail("%s has invalid status field name %s", path, start);
        }
        if (eq + 1 == end) {
            fail("%s has empty %s= value", path, start);
        }
        for (i = 0; i < status->count; i++) {
            if (strcmp(status->fields[i].name, start) == 0) {
                fail("%s has duplicate %s= field", path, start);
            }
        }
        if (status->count == MAX_FIELDS) {
            fail("%s has too many status fields", path);
        }
        status->fields[status->count].name = start;
        status->fields[status->count].value = eq + 1;
        status->count++;
    }

    if (status->count == 0) {
        fail("%s has no key=value status fields", path);
    }
}

static const char *field(const Status *status, const char *name) {
    size_t i;

    for (i = 0; i < status->count; i++) {
        if (strcmp(status->fields[i].name, name) == 0) {
            return status->fields[i].value;
        }
    }
    fail("%s missing %s= field", status->path, name);
    return NULL;
}

static int has_field(const Status *status, const char *name) {
    size_t i;

    for (i = 0; i < status->count; i++) {
        if (strcmp(status->fields[i].name, name) == 0) {
            return 1;
        }
    }
    return 0;
}

static void exact(const Status *status, const char *name, const char *expected) {
    const char *actual = field(status, name);
    if (strcmp(actual, expected) != 0) {
        fail("%s= must be %s, got %s", name, expected, actual);
    }
}

static int hex_digit(char c) {
    if (c >= '0' && c <= '9') {
        return c - '0';
    }
    if (c >= 'A' && c <= 'F') {
        return c - 'A' + 10;
    }
    if (c >= 'a' && c <= 'f') {
        return c - 'a' + 10;
    }
    return -1;
}

static int is_hex_string_len(const char *value, size_t len) {
    size_t i;

    if (strlen(value) != len) {
        return 0;
    }
    for (i = 0; i < len; i++) {
        if (hex_digit(value[i]) < 0) {
            return 0;
        }
    }
    return 1;
}

static int is_sha256_hex(const char *value) {
    return is_hex_string_len(value, 64u);
}

static int sha256_hex_equals(const char *a, const char *b) {
    size_t i;

    for (i = 0; i < 64u; i++) {
        if (hex_digit(a[i]) != hex_digit(b[i])) {
            return 0;
        }
    }
    return a[64] == '\0' && b[64] == '\0';
}

static int field_equals(const Status *status, const char *name, const char *expected) {
    return has_field(status, name) && strcmp(field(status, name), expected) == 0;
}

static int string_has_prefix(const char *value, const char *prefix) {
    return strncmp(value, prefix, strlen(prefix)) == 0;
}

static int field_has_prefix(const Status *status, const char *name, const char *prefix) {
    return has_field(status, name) && string_has_prefix(field(status, name), prefix);
}

static int field_truthy(const Status *status, const char *name) {
    const char *value;

    if (!has_field(status, name)) {
        return 0;
    }
    value = field(status, name);
    return strcmp(value, "true") == 0 || strcmp(value, "TRUE") == 0 ||
           strcmp(value, "1") == 0 || strcmp(value, "yes") == 0 ||
           strcmp(value, "YES") == 0;
}

static int field_falsey(const Status *status, const char *name) {
    const char *value;

    if (!has_field(status, name)) {
        return 0;
    }
    value = field(status, name);
    return strcmp(value, "false") == 0 || strcmp(value, "FALSE") == 0 ||
           strcmp(value, "0") == 0 || strcmp(value, "no") == 0 ||
           strcmp(value, "NO") == 0;
}

static int status_has_local_qemu_metadata(const Status *status) {
    return field_truthy(status, "local_qemu_only") ||
           field_has_prefix(status, "evidence_class", "local-qemu") ||
           field_has_prefix(status, "smoke_gate", "pi4-local-qemu") ||
           field_equals(status, "hardware", "unclaimed") ||
           field_falsey(status, "green_gate") ||
           field_equals(status, "hardware_proof", "unclaimed");
}

static int is_pi4_user_exec_path(const char *path) {
    return strcmp(path, "INIT.ELF") == 0 ||
           strcmp(path, "PAYLOAD0.ELF") == 0 ||
           strcmp(path, "PAYLOAD1.ELF") == 0;
}

static void hex_like_tuple(const Status *status, const char *name, size_t count, char sep) {
    const char *p = field(status, name);
    size_t parts = 0;

    while (*p) {
        size_t digits = 0;

        if (parts == count) {
            fail("%s= must contain exactly %zu hex fields", name, count);
        }
        if (p[0] == '0' && (p[1] == 'x' || p[1] == 'X')) {
            p += 2;
        }
        while (*p && *p != sep) {
            if (hex_digit(*p) < 0) {
                fail("%s= must contain hexadecimal fields", name);
            }
            digits++;
            if (digits > 16u) {
                fail("%s= hex fields must fit in 64 bits", name);
            }
            p++;
        }
        if (digits == 0u) {
            fail("%s= must contain nonempty hex fields", name);
        }
        parts++;
        if (*p == sep) {
            p++;
        }
    }
    if (parts != count) {
        fail("%s= must contain exactly %zu hex fields", name, count);
    }
}

static size_t hex64_tuple_fields(const Status *status, const char *name, char sep,
                                 uint64_t *out, size_t max_count) {
    const char *p = field(status, name);
    size_t parts = 0;

    while (*p) {
        uint64_t value = 0;
        size_t digits = 0;

        if (parts == max_count) {
            fail("%s= must contain at most %zu hex fields", name, max_count);
        }
        if (p[0] == '0' && (p[1] == 'x' || p[1] == 'X')) {
            p += 2;
        }
        while (*p && *p != sep) {
            int d = hex_digit(*p);
            if (d < 0) {
                fail("%s= must contain hexadecimal fields", name);
            }
            if (digits == 16u) {
                fail("%s= hex fields must fit in 64 bits", name);
            }
            value = (value << 4) | (uint64_t)d;
            digits++;
            p++;
        }
        if (digits == 0u) {
            fail("%s= must contain nonempty hex fields", name);
        }
        out[parts++] = value;
        if (*p == sep) {
            p++;
            if (!*p) {
                fail("%s= must not end with a separator", name);
            }
        }
    }
    return parts;
}

static void hex64_tuple_exact(const Status *status, const char *name, size_t count,
                              char sep, uint64_t *out) {
    size_t parts = hex64_tuple_fields(status, name, sep, out, count);
    if (parts != count) {
        fail("%s= must contain exactly %zu hex fields", name, count);
    }
}

static int any_nonzero64(const uint64_t *values, size_t count) {
    size_t i;

    for (i = 0; i < count; i++) {
        if (values[i] != 0u) {
            return 1;
        }
    }
    return 0;
}

static int field_is_none_or_zero_tuple(const Status *status, const char *name, size_t count) {
    uint64_t values[MAX_HEX64_TUPLE_FIELDS];

    if (count > MAX_HEX64_TUPLE_FIELDS) {
        fail("%s= internal tuple width exceeds checker capacity", name);
    }
    if (strcmp(field(status, name), "NONE") == 0) {
        return 1;
    }
    hex64_tuple_exact(status, name, count, '/', values);
    return !any_nonzero64(values, count);
}

static void validate_pi4_panic_fault_status(const Status *status) {
    const char *faultsrc = field(status, "faultsrc");
    const char *faultmode = field(status, "faultmode");
    const char *panic = field(status, "panic");

    if (strcmp(panic, "NONE") == 0) {
        if (strcmp(faultsrc, "NONE") != 0 || strcmp(faultmode, "NONE") != 0) {
            fail("panic=NONE requires faultsrc=NONE and faultmode=NONE");
        }
        return;
    }

    if (strcmp(faultsrc, "NONE") == 0 || strcmp(faultmode, "NONE") == 0) {
        fail("panic=%s requires non-NONE faultsrc= and faultmode= evidence", panic);
    }
}

static uint64_t neg_errno64(uint64_t value) {
    return 0u - value;
}

static int parse_hex64_scalar(const char *value, uint64_t *out) {
    uint64_t parsed = 0u;
    size_t digits = 0u;

    if (value[0] == '0' && (value[1] == 'x' || value[1] == 'X')) {
        value += 2;
    }
    while (*value) {
        int d = hex_digit(*value);
        if (d < 0 || digits == 16u) {
            return 0;
        }
        parsed = (parsed << 4) | (uint64_t)d;
        digits++;
        value++;
    }
    if (digits == 0u) {
        return 0;
    }
    *out = parsed;
    return 1;
}

static int status_word_equals(const char *actual, const char *name, uint64_t word) {
    uint64_t parsed;

    if (strcmp(actual, name) == 0) {
        return 1;
    }
    return parse_hex64_scalar(actual, &parsed) && parsed == word;
}

static void validate_pi4_process_table_skeleton(const Status *status, uint64_t *ptable) {
    hex64_tuple_exact(status, "pi4ptable", 4, '/', ptable);
    if (ptable[0] == 0u || ptable[1] == 0u || ptable[2] < PI4_PROC_TABLE_ENTRY_BYTES ||
        ptable[3] > ptable[1]) {
        fail("pi4ptable= must expose a nonzero Pi process table base/capacity/entry-size skeleton");
    }
}

static void validate_pi4_preempt_context_skeleton(const Status *status, int require_switch) {
    const int has_ctx = has_field(status, "pi4ctx");
    const int has_sched = has_field(status, "pi4sched");
    uint64_t ctx[9];
    uint64_t sched[6];
    uint64_t ptable[4];

    if (!has_ctx && !has_sched) {
        if (require_switch) {
            fail("pi4preempt=OK requires pi4ctx=/pi4sched= switch evidence");
        }
        return;
    }
    if (!has_ctx || !has_sched) {
        fail("pi4ctx= and pi4sched= must be reported together");
    }

    hex64_tuple_exact(status, "pi4ctx", 9, '/', ctx);
    hex64_tuple_exact(status, "pi4sched", 6, '/', sched);
    validate_pi4_process_table_skeleton(status, ptable);

    if (ctx[0] == 0u || ctx[1] != PI4_PROC_CONTEXT_BYTES ||
        ctx[2] != PI4_PROC_CONTEXT_VERSION || ctx[3] == 0u || ctx[4] == 0u ||
        ctx[5] == 0u || ctx[6] == 0u ||
        (ctx[8] & PI4_PROC_CONTEXT_REQUIRED_FLAGS) != PI4_PROC_CONTEXT_REQUIRED_FLAGS) {
        fail("pi4ctx= must expose a nonzero assembly-owned EL0 process context skeleton");
    }
    if (ctx[3] != sched[4] || sched[4] == 0u || sched[5] == 0u) {
        fail("pi4sched= must account the current process context PID");
    }
    if (sched[1] != sched[2] + sched[3]) {
        fail("pi4sched= attempts must equal no-peer waits plus process switches");
    }
    if (field_equals(status, "pi4irq", "OK")) {
        uint64_t ticks[1];

        hex64_tuple_exact(status, "ticks", 1, '/', ticks);
        if (sched[0] != ticks[0]) {
            fail("pi4sched= tick accounting must mirror ticks=");
        }
    } else if (sched[0] != 0u || sched[1] != 0u || sched[2] != 0u || sched[3] != 0u) {
        fail("pi4sched= must not claim timer accounting while pi4irq=WAIT");
    }
    if (!require_switch) {
        if (sched[3] != 0u) {
            fail("pi4preempt=WAIT must keep pi4sched= process switches at zero");
        }
        return;
    }

    if (ptable[3] < 2u || sched[3] == 0u) {
        fail("pi4preempt=OK requires at least two process contexts and a nonzero switch count");
    }
}

static void reject_fields(const Status *status, const char *state,
                          const char *const *names, size_t count) {
    size_t i;

    for (i = 0; i < count; i++) {
        if (has_field(status, names[i])) {
            fail("%s must not include %s=", state, names[i]);
        }
    }
}

static uint32_t parse_hex8_value(const char *value, const char *name) {
    uint32_t out = 0;
    int i;

    if (strlen(value) != 8u) {
        fail("%s= must be an 8-digit hexadecimal value, got %s", name, value);
    }
    for (i = 0; i < 8; i++) {
        int d = hex_digit(value[i]);
        if (d < 0) {
            fail("%s= must be an 8-digit hexadecimal value, got %s", name, value);
        }
        out = (out << 4) | (uint32_t)d;
    }
    return out;
}

static uint32_t hex_field(const Status *status, const char *name) {
    return parse_hex8_value(field(status, name), name);
}

static int user_eflags_sanitized(uint32_t value) {
    if ((value & SYSCALL_RETURN_EFLAGS_SET) != SYSCALL_RETURN_EFLAGS_SET) {
        return 0;
    }
    if ((value & ~SYSCALL_RETURN_EFLAGS_KEEP_MASK) != 0u) {
        return 0;
    }
    return 1;
}

static int user_eflags_sanitized_or_rf(uint32_t value) {
    return user_eflags_sanitized(value) || user_eflags_sanitized(value & ~USER_EFLAGS_RF);
}

static void hex_tuple(const Status *status, const char *name, size_t count, char sep, uint32_t *out) {
    const char *p = field(status, name);
    size_t i;

    for (i = 0; i < count; i++) {
        char part[9];
        size_t j;

        for (j = 0; j < 8; j++) {
            if (!p[j]) {
                fail("%s= must contain %zu hex fields separated by %c", name, count, sep);
            }
            part[j] = p[j];
        }
        part[8] = '\0';
        out[i] = parse_hex8_value(part, name);
        p += 8;
        if (i + 1u < count) {
            if (*p != sep) {
                fail("%s= must contain %zu hex fields separated by %c", name, count, sep);
            }
            p++;
        } else if (*p != '\0') {
            fail("%s= must contain exactly %zu hex fields", name, count);
        }
    }
}

static void page_aligned(uint32_t value, const char *name) {
    if ((value & (PAGE_SIZE - 1u)) != 0u) {
        fail("%s must be page-aligned, got 0x%08X", name, value);
    }
}

static void managed_frame(uint32_t value, const char *name) {
    page_aligned(value, name);
    if (value < PMM_MANAGED_START || value >= PMM_MANAGED_END) {
        fail("%s must be a PMM-managed frame, got 0x%08X", name, value);
    }
}

static void in_range(uint32_t value, uint32_t start, uint32_t end, const char *name) {
    if (value < start || value >= end) {
        fail("%s=0x%08X outside expected range 0x%08X..0x%08X", name, value, start, end);
    }
}

static int fixed_bootstrap_page_dir(uint32_t cr3) {
    return cr3 == PAGING_DIR_ADDR ||
           cr3 == PROC_PROBE_PAGE_DIR_ADDR ||
           cr3 == PROC_PAYLOAD_PAGE_DIR_ADDR ||
           cr3 == PROC_PREEMPT_PAGE_DIR_ADDR ||
           cr3 == PROC_GENERIC0_PAGE_DIR_ADDR ||
           cr3 == PROC_GENERIC1_PAGE_DIR_ADDR;
}

static int process_page_dir(uint32_t cr3) {
    return cr3 == PROC_PROBE_PAGE_DIR_ADDR ||
           cr3 == PROC_PAYLOAD_PAGE_DIR_ADDR ||
           cr3 == PROC_PREEMPT_PAGE_DIR_ADDR ||
           cr3 == PROC_GENERIC0_PAGE_DIR_ADDR ||
           cr3 == PROC_GENERIC1_PAGE_DIR_ADDR;
}

static void validate_clock(const Status *status) {
    const char *source;

    if (!has_field(status, "clocksrc")) {
        return;
    }
    source = field(status, "clocksrc");
    if (strcmp(source, "PIT") != 0 && strcmp(source, "HPET") != 0) {
        fail("clocksrc= must be PIT or HPET, got %s", source);
    }
    if (strcmp(source, "HPET") == 0) {
        uint32_t hpet_clock[6];
        exact(status, "hpet", "LIVE");
        hex_tuple(status, "clockhpet", 6, '/', hpet_clock);
        if (hpet_clock[0] != 1u) {
            fail("clockhpet= must report a ready HPET-backed monotonic clock");
        }
        if (hpet_clock[1] == 0u || hpet_clock[3] == 0u || hpet_clock[5] == 0u) {
            fail("clockhpet= must show ticks-per-ms, last-ms, and sample progress");
        }
    }
    if (has_field(status, "ticks") && has_field(status, "dtick")) {
        uint32_t ticks = hex_field(status, "ticks");
        uint32_t dtick = hex_field(status, "dtick");
        uint32_t expected;
        if (ticks == 0u) {
            fail("ticks= must be nonzero");
        }
        expected = (ticks * 35u) / 100u;
        if (dtick + 1u < expected || dtick > expected + 1u) {
            fail("dtick= must stay within one 35 Hz compatibility tick of the generic 100 Hz clock");
        }
    }
}

static void validate_low_identity_probe(const Status *status, int relocated) {
    uint32_t v[4];

    hex_tuple(status, "klowid", 4, '/', v);
    if (v[1] != KERNEL_LOW_LINK_BASE) {
        fail("klowid= must probe the low linked kernel entry page");
    }
    if (relocated) {
        if (v[0] != LOW_IDENTITY_TRAPPED) {
            fail("klowid= must prove the low identity mapping is trapped for kreloc=OK");
        }
        if (v[2] != MISSING_TRANSLATION) {
            fail("klowid= must report no low identity translation once kreloc=OK");
        }
        if ((v[3] & PTE_PRESENT) != 0u) {
            fail("klowid= PTE flags must not retain the present bit once kreloc=OK");
        }
        return;
    }
    if (v[0] != LOW_IDENTITY_PRESENT) {
        fail("klowid= must expose the retained low identity dependency before kreloc=OK");
    }
    if (v[2] != v[1]) {
        fail("klowid= must translate the retained low identity page back to itself");
    }
    if ((v[3] & PTE_PRESENT) == 0u) {
        fail("klowid= must include the present bit for the retained low identity mapping");
    }
    if ((v[3] & ~(PAGE_SIZE - 1u)) != (v[2] & ~(PAGE_SIZE - 1u))) {
        fail("klowid= PTE frame must match the retained low identity translation");
    }
}

static void validate_high_mainline(const Status *status, uint32_t expected_cr3) {
    uint32_t span[8];
    uint32_t xlat[4];
    uint32_t pte[5];
    uint32_t abi[5];
    uint32_t data[3];
    uint32_t kppt;

    exact(status, "khmain", "OK");
    hex_tuple(status, "khmspan", 8, '/', span);
    in_range(span[0], KERNEL_HIGH_LINK_BASE, KERNEL_HIGH_LINK_BASE + KERNEL_ELF_MAX_BYTES, "khmspan entry EIP");
    in_range(span[1], KERNEL_HIGH_LINK_BASE, KERNEL_HIGH_LINK_BASE + KERNEL_ELF_MAX_BYTES, "khmspan late EIP");
    in_range(span[2], KERNEL_HIGH_STACK_LOW, KERNEL_HIGH_STACK_TOP, "khmspan entry ESP");
    in_range(span[3], KERNEL_HIGH_STACK_LOW, KERNEL_HIGH_STACK_TOP, "khmspan late ESP");
    if (span[0] == span[1]) {
        fail("khmspan= must contain two distinct higher-half mainline checkpoints");
    }
    if (span[4] != expected_cr3) {
        fail("khmspan= CR3 must match the active kernel relocation CR3");
    }
    if (span[5] != KERNEL_HIGH_STACK_TOP) {
        fail("khmspan= must prove TSS esp0 uses the higher-half kernel stack");
    }
    if (span[6] != KERNEL_HIGHER_HALF_BASE) {
        fail("khmspan= must prove IDT gates were rebuilt for higher-half handlers");
    }
    if (span[7] < KERNEL_HIGH_MAINLINE_MIN_CHECKPOINTS) {
        fail("khmspan= must prove at least two live higher-half mainline checkpoints");
    }

    hex_tuple(status, "khmxlat", 4, '/', xlat);
    if (xlat[0] != span[0] - KERNEL_HIGHER_HALF_BASE ||
        xlat[1] != span[1] - KERNEL_HIGHER_HALF_BASE ||
        xlat[2] != span[2] - KERNEL_HIGHER_HALF_BASE ||
        xlat[3] != span[3] - KERNEL_HIGHER_HALF_BASE) {
        fail("khmxlat= must translate high-mainline EIP/ESP back to physical addresses");
    }

    hex_tuple(status, "khmpte", 5, '/', pte);
    kppt = hex_field(status, "kppt");
    if ((pte[0] & PTE_KERNEL_FLAGS) != PTE_KERNEL_FLAGS) {
        fail("khmpte= high-mainline PDE must be present and writable");
    }
    if ((pte[0] & ~(PAGE_SIZE - 1u)) != kppt) {
        fail("khmpte= PDE must point at the persistent high alias page table");
    }
    if ((pte[1] & PTE_KERNEL_FLAGS) != PTE_KERNEL_FLAGS ||
        (pte[2] & PTE_KERNEL_FLAGS) != PTE_KERNEL_FLAGS ||
        (pte[3] & PTE_KERNEL_FLAGS) != PTE_KERNEL_FLAGS ||
        (pte[4] & PTE_KERNEL_FLAGS) != PTE_KERNEL_FLAGS) {
        fail("khmpte= all checked text/stack PTEs must be present and writable");
    }
    if ((pte[1] & ~(PAGE_SIZE - 1u)) != (xlat[0] & ~(PAGE_SIZE - 1u)) ||
        (pte[2] & ~(PAGE_SIZE - 1u)) != (xlat[1] & ~(PAGE_SIZE - 1u)) ||
        (pte[3] & ~(PAGE_SIZE - 1u)) != (xlat[2] & ~(PAGE_SIZE - 1u)) ||
        (pte[4] & ~(PAGE_SIZE - 1u)) != (xlat[3] & ~(PAGE_SIZE - 1u))) {
        fail("khmpte= PTE frames must match khmxlat=");
    }

    hex_tuple(status, "khabi", 5, '/', abi);
    if (abi[0] != KERNEL_HIGH_ABI_FULL_MASK || abi[1] != KERNEL_HIGH_ABI_FULL_MASK) {
        fail("khabi= must prove every live higher-half kernel checkpoint ran in guest assembly");
    }
    if (abi[2] != KERNEL_HIGH_ABI_LOW_ID_RETAINED) {
        fail("khabi= final operation must prove the retained low identity dependency was checked");
    }
    if (abi[3] != span[7]) {
        fail("khabi= checkpoint count must match khmspan=");
    }
    if (abi[4] != 1u) {
        fail("khabi= must prove the persistent higher-half mainline is active");
    }

    hex_tuple(status, "khdata", 3, '/', data);
    if (data[0] < KERNEL_HIGH_MAINLINE_MIN_CHECKPOINTS) {
        fail("khdata= must prove repeated higher-half data writes");
    }
    if (data[1] != KERNEL_HIGH_ABI_LOW_ID_RETAINED) {
        fail("khdata= final high-data write must match khabi= final operation");
    }
    if (data[2] != KERNEL_HIGH_ABI_HIGH_DATA_WRITE) {
        fail("khdata= must declare the high-data write ABI bit");
    }
}

static void validate_relocation_dir(const Status *status, uint32_t expected_vaddr, uint32_t expected_phys) {
    uint32_t x[6];
    uint32_t p[3];
    uint32_t kppt = hex_field(status, "kppt");
    uint32_t stack_phys = hex_field(status, "kpspa");

    exact(status, "kreldir", "OK");
    hex_tuple(status, "kreldirx", 6, '/', x);
    hex_tuple(status, "kreldirp", 3, '/', p);

    managed_frame(x[0], "kreldirx directory");
    if (fixed_bootstrap_page_dir(x[0])) {
        fail("kreldirx= directory must be a dedicated PMM-managed relocation page directory");
    }
    if ((x[1] & PTE_KERNEL_FLAGS) != PTE_KERNEL_FLAGS) {
        fail("kreldirx= high PDE must be present and supervisor-writable");
    }
    if ((x[1] & ~(PAGE_SIZE - 1u)) != kppt) {
        fail("kreldirx= high PDE must point at the persistent high alias page table");
    }
    if ((x[2] & PTE_PRESENT) != 0u) {
        fail("kreldirx= low PDE must be absent in the candidate relocation directory");
    }
    if (x[3] != expected_phys) {
        fail("kreldirx= entry translation must preserve higher-half kernel text");
    }
    if (x[4] != stack_phys) {
        fail("kreldirx= stack translation must preserve the higher-half kernel stack");
    }
    if (x[5] != MISSING_TRANSLATION) {
        fail("kreldirx= low identity translation must be absent");
    }
    if ((p[0] & PTE_KERNEL_FLAGS) != PTE_KERNEL_FLAGS ||
        (p[1] & PTE_KERNEL_FLAGS) != PTE_KERNEL_FLAGS) {
        fail("kreldirp= entry and stack PTEs must be present and supervisor-writable");
    }
    if ((p[0] & ~(PAGE_SIZE - 1u)) != (x[3] & ~(PAGE_SIZE - 1u))) {
        fail("kreldirp= entry PTE frame must match kreldirx= entry translation");
    }
    if ((p[1] & ~(PAGE_SIZE - 1u)) != (x[4] & ~(PAGE_SIZE - 1u))) {
        fail("kreldirp= stack PTE frame must match kreldirx= stack translation");
    }
    if ((p[2] & PTE_PRESENT) != 0u) {
        fail("kreldirp= low PTE must not retain the present bit");
    }
    if (expected_vaddr != KERNEL_HIGHER_HALF_BASE + expected_phys) {
        fail("kreldirx= expected high entry must remain the direct higher-half alias");
    }
}

static void validate_live_relocation_switch(const Status *status) {
    uint32_t live[10];
    uint32_t proof[5];
    uint32_t hazard[3];
    uint32_t dir[6];
    uint32_t abi[5];
    uint32_t kerncr3 = hex_field(status, "kerncr3");

    exact(status, "krelive", "OK");
    hex_tuple(status, "krelivex", 10, '/', live);
    hex_tuple(status, "krelivep", 5, '/', proof);
    hex_tuple(status, "krelhaz", 3, '/', hazard);
    hex_tuple(status, "kreldirx", 6, '/', dir);

    if (live[2] != dir[0]) {
        fail("krelivex= live CR3 must be the PMM-backed relocation directory");
    }
    if (live[2] == kerncr3 || fixed_bootstrap_page_dir(live[2])) {
        fail("krelivex= live CR3 must differ from bootstrap/user page directories");
    }
    managed_frame(live[2], "krelivex live CR3");
    if (live[3] != PAGING_DIR_ADDR) {
        fail("krelivex= return CR3 must prove the bounded proof switched back");
    }

    page_aligned(live[4], "krelivex code vaddr");
    page_aligned(live[5], "krelivex code phys");
    page_aligned(live[6], "krelivex stack vaddr");
    page_aligned(live[7], "krelivex stack phys");
    if (live[4] != KERNEL_HIGHER_HALF_BASE + live[5] ||
        live[6] != KERNEL_HIGHER_HALF_BASE + live[7] ||
        live[8] != KERNEL_HIGHER_HALF_BASE + live[9]) {
        fail("krelivex= code, stack, and data slots must be direct higher-half aliases");
    }
    in_range(live[5], KERNEL_LOW_LINK_BASE, KERNEL_LOW_LINK_BASE + KERNEL_ELF_MAX_BYTES, "krelivex code phys");
    in_range(live[7], KERNEL_STACK_LOW, KERNEL_STACK_TOP, "krelivex stack phys");
    in_range(live[9], KERNEL_LOW_LINK_BASE, KERNEL_LOW_LINK_BASE + KERNEL_ELF_MAX_BYTES, "krelivex data phys");
    if (live[0] < live[4] || live[0] >= live[4] + PAGE_SIZE) {
        fail("krelivex= EIP must be inside the high relocation-switch code page");
    }
    if (live[1] < live[6] || live[1] >= live[6] + PAGE_SIZE) {
        fail("krelivex= ESP must be inside the high relocation-switch stack page");
    }
    if (proof[0] != live[5] || proof[1] != live[7] || proof[2] != live[9]) {
        fail("krelivep= translations must survive under the relocation directory");
    }
    if (proof[3] != MISSING_TRANSLATION) {
        fail("krelivep= low identity translation must be absent during live CR3 proof");
    }
    if (proof[4] != KERNEL_RELOCATION_LIVE_MAGIC) {
        fail("krelivep= magic must prove the live relocation directory wrote through high data");
    }

    if (hazard[0] != hazard[2]) {
        fail("krelhaz= return address must match the low continuation after the live switch");
    }
    in_range(hazard[0], KERNEL_LOW_LINK_BASE, KERNEL_LOW_LINK_BASE + KERNEL_ELF_MAX_BYTES, "krelhaz return address");
    if (hazard[0] >= KERNEL_HIGHER_HALF_BASE) {
        fail("krelhaz= return address must not already be a higher-half continuation");
    }
    if (hazard[1] != MISSING_TRANSLATION) {
        fail("krelhaz= low return continuation must be unmapped by the relocation directory");
    }

    hex_tuple(status, "krelabi", 5, '/', abi);
    if (abi[0] != KERNEL_RELOC_ABI_FULL_MASK || abi[1] != KERNEL_RELOC_ABI_FULL_MASK) {
        fail("krelabi= must prove the PMM relocation directory and bounded CR3 switch in guest assembly");
    }
    if (abi[2] != KERNEL_RELOC_ABI_RETURN_CR3_RESTORED) {
        fail("krelabi= final operation must prove CR3 returned after the bounded switch");
    }
    if (abi[3] != 1u || abi[4] != 1u) {
        fail("krelabi= must report both relocation directory and live switch status OK");
    }
}

static void validate_kernel_relocation(const Status *status) {
    const char *state = field(status, "kreloc");
    const char *step = field(status, "krelocstep");
    uint32_t eip = hex_field(status, "kerneip");
    uint32_t esp = hex_field(status, "kernesp");
    uint32_t cr3 = hex_field(status, "kerncr3");
    uint32_t virt = hex_field(status, "kernvirt");
    uint32_t phys = hex_field(status, "kernphys");

    if (strcmp(state, "HIGH") == 0) {
        if (strcmp(step, "KPMAIN_HIGH") != 0) {
            fail("krelocstep= must be KPMAIN_HIGH while kreloc=HIGH");
        }
        in_range(eip, KERNEL_HIGH_LINK_BASE, KERNEL_HIGH_LINK_BASE + KERNEL_ELF_MAX_BYTES, "kerneip");
        in_range(esp, KERNEL_HIGH_STACK_LOW, KERNEL_HIGH_STACK_TOP, "kernesp");
        if (cr3 != PAGING_DIR_ADDR) {
            fail("kerncr3= must still be the low bootstrap page directory while kreloc=HIGH");
        }
        if (virt != KERNEL_HIGH_LINK_BASE) {
            fail("kernvirt= must be the persistent higher-half kernel entry");
        }
        page_aligned(phys, "kernphys");
        in_range(phys, KERNEL_LOW_LINK_BASE, KERNEL_LOW_LINK_BASE + KERNEL_ELF_MAX_BYTES, "kernphys");
        if (phys == virt) {
            fail("kernphys= must be non-identity when kreloc=HIGH");
        }
        validate_low_identity_probe(status, 0);
        validate_high_mainline(status, cr3);
        validate_relocation_dir(status, virt, phys);
        validate_live_relocation_switch(status);
        return;
    }

    if (strcmp(state, "OK") == 0) {
        if (strcmp(step, "FULL") != 0) {
            fail("krelocstep= must be FULL once kreloc=OK");
        }
        in_range(eip, KERNEL_HIGH_LINK_BASE, KERNEL_HIGH_LINK_BASE + KERNEL_ELF_MAX_BYTES, "kerneip");
        in_range(esp, KERNEL_HIGH_STACK_LOW, KERNEL_HIGH_STACK_TOP, "kernesp");
        if (cr3 == PAGING_DIR_ADDR || fixed_bootstrap_page_dir(cr3)) {
            fail("kerncr3= must be a dedicated PMM-managed kernel page directory for kreloc=OK");
        }
        managed_frame(cr3, "kerncr3");
        if (virt != KERNEL_HIGH_LINK_BASE) {
            fail("kernvirt= must be the higher-half kernel entry");
        }
        page_aligned(phys, "kernphys");
        if (phys >= KERNEL_HIGHER_HALF_BASE || phys == virt) {
            fail("kernphys= must be a non-identity physical frame when kreloc=OK");
        }
        validate_low_identity_probe(status, 1);
        validate_high_mainline(status, cr3);
        return;
    }

    fail("kreloc= must be HIGH or OK for the C VM status proof, got %s", state);
}

static int addr_matches_kind(uint32_t kind, uint32_t addr) {
    if (kind == USER_KIND_PAYLOAD_PRIMARY || kind == USER_KIND_PAYLOAD_SECONDARY) {
        return addr >= PAYLOAD_USER_BASE && addr < PAYLOAD_USER_STACK_TOP;
    }
    if (kind == USER_KIND_PREEMPT_PROBE) {
        return addr >= PROBE_USER_BASE && addr < PROBE_USER_END;
    }
    return 0;
}

static int is_large_payload_kind(uint32_t kind) {
    return kind == USER_KIND_PAYLOAD_PRIMARY || kind == USER_KIND_PAYLOAD_SECONDARY;
}

static int expected_large_payload_kind_for_path(const Status *status, uint32_t *kind) {
    const char *exec_path;

    if (!has_field(status, "path")) {
        return 0;
    }
    exec_path = field(status, "path");
    if (strcmp(exec_path, "PAYLOAD0.ELF") == 0) {
        *kind = USER_KIND_PAYLOAD_PRIMARY;
        return 1;
    }
    if (strcmp(exec_path, "PAYLOAD1.ELF") == 0) {
        *kind = USER_KIND_PAYLOAD_SECONDARY;
        return 1;
    }
    return 0;
}

static int exec_copy_source_ok(uint32_t addr) {
    return (addr >= USER_ELF_LOAD_ADDR && addr < USER_ELF_LOAD_ADDR + USER_ELF_MAX_BYTES) ||
           (addr >= PAYLOAD_USER_BASE && addr < PAYLOAD_USER_STACK_TOP);
}

static int exec_copy_destination_ok(uint32_t addr) {
    return (addr >= PROBE_USER_BASE && addr < PROBE_USER_END) ||
           (addr >= PAYLOAD_USER_BASE && addr < PAYLOAD_USER_STACK_TOP);
}

static void validate_exec_copy(const Status *status) {
    uint32_t v[9];

    if (!has_field(status, "execcopy")) {
        return;
    }

    hex_tuple(status, "execcopy", 9, '/', v);
    if (v[0] == 0u) {
        fail("execcopy= must show at least one loaded ELF segment");
    }
    if (v[1] == 0u || v[1] != v[2]) {
        fail("execcopy= must show balanced CR3 switches and restores");
    }
    if (!fixed_bootstrap_page_dir(v[3]) || !process_page_dir(v[4])) {
        fail("execcopy= must record old CR3 and target process CR3");
    }
    if (v[3] == v[4]) {
        fail("execcopy= must prove segment materialization used a target address space");
    }
    if (!exec_copy_source_ok(v[5]) || !exec_copy_destination_ok(v[6])) {
        fail("execcopy= source/destination must stay inside known ELF/user windows");
    }
    if (v[7] == 0u || v[8] == 0u || v[7] > v[8]) {
        fail("execcopy= must report a nonempty file image within segment memory");
    }
}

static void validate_vfs_abi(const Status *status) {
    uint32_t abi[3];
    uint32_t ops[10];
    uint32_t fatdyn[9];
    uint32_t fatacct[5];
    uint32_t fatabi[5];
    size_t i;

    if (!has_field(status, "vfsabi")) {
        return;
    }

    hex_tuple(status, "vfsabi", 3, '/', abi);
    if (abi[1] != VFS_ABI_FULL_MASK) {
        fail("vfsabi= declared full mask must be 0x%08X", VFS_ABI_FULL_MASK);
    }
    if ((abi[0] & VFS_ABI_FULL_MASK) != VFS_ABI_FULL_MASK) {
        fail("vfsabi= must show every generic VFS syscall was exercised");
    }
    if ((abi[0] & ~VFS_ABI_FULL_MASK) != 0u) {
        fail("vfsabi= must not set unknown operation bits");
    }
    if (abi[2] == 0u || (abi[2] & ~VFS_ABI_FULL_MASK) != 0u || (abi[2] & (abi[2] - 1u)) != 0u) {
        fail("vfsabi= last operation must be exactly one known operation bit");
    }

    hex_tuple(status, "vfsops", 10, '/', ops);
    for (i = 0; i < 10u; i++) {
        if (ops[i] == 0u) {
            fail("vfsops= must show every generic VFS counter incremented");
        }
    }
    hex_tuple(status, "fatdyn", 9, '/', fatdyn);
    if (fatdyn[0] == 0u || fatdyn[1] != 0u || fatdyn[2] == 0u || fatdyn[3] == 0u ||
        fatdyn[4] == 0u || fatdyn[5] == 0u || fatdyn[6] == 0u || fatdyn[7] == 0u ||
        fatdyn[8] != 0u) {
        fail("fatdyn= must prove successful dynamic FAT allocation, free, resize, truncate, and directory updates");
    }
    hex_tuple(status, "fatacct", 5, '/', fatacct);
    if (fatacct[4] != 0u || fatacct[2] == 0u || fatacct[3] < 2u ||
        fatacct[2] != fatacct[3] - 1u || fatacct[0] + fatacct[1] != fatacct[2]) {
        fail("fatacct= must prove consistent FAT free/used cluster accounting");
    }
    hex_tuple(status, "fatabi", 5, '/', fatabi);
    if (fatabi[1] != FAT_ABI_FULL_MASK) {
        fail("fatabi= declared full mask must be 0x%08X", FAT_ABI_FULL_MASK);
    }
    if ((fatabi[0] & FAT_ABI_FULL_MASK) != FAT_ABI_FULL_MASK) {
        fail("fatabi= must prove every tracked generic FAT operation ran in the guest");
    }
    if ((fatabi[0] & ~FAT_ABI_FULL_MASK) != 0u) {
        fail("fatabi= contains unknown operation bits");
    }
    if (fatabi[2] == 0u || (fatabi[2] & ~FAT_ABI_FULL_MASK) != 0u ||
        (fatabi[2] & (fatabi[2] - 1u)) != 0u ||
        (fatabi[0] & fatabi[2]) == 0u) {
        fail("fatabi= last operation must be one completed FAT operation bit");
    }
    if (fatabi[3] != fatdyn[3] || fatabi[4] != fatdyn[8]) {
        fail("fatabi= free-cluster and directory-failure counts must mirror fatdyn=");
    }
}

static void validate_exec(const Status *status) {
    const char *exec_path;

    exact(status, "exec", "OK");
    exact(status, "uexec", "OK");
    exact(status, "upath", "INIT.ELF");
    exact(status, "abiexec", "WAIT");
    exact(status, "abipath", "ABIPROBE.ELF");
    exact(status, "abiprobe", "WAIT");
    exec_path = field(status, "path");
    if (strcmp(exec_path, "PAYLOAD1.ELF") == 0) {
        exact(status, "quake", "OK");
    } else if (strcmp(exec_path, "PAYLOAD0.ELF") == 0) {
        exact(status, "doom", "OK");
    } else {
        fail("path= must be PAYLOAD0.ELF or PAYLOAD1.ELF");
    }
    if (hex_field(status, "argvsrc") != SYS_EXEC_ARGV_SOURCE_USER) {
        fail("argvsrc= must prove exec argv came from user memory");
    }
    validate_exec_copy(status);
    (void)field(status, "execmap");
    (void)field(status, "procpool");
    (void)field(status, "fdexec");
    (void)field(status, "fdup");
    (void)field(status, "kblock");
    (void)field(status, "ksleep");
    (void)field(status, "fork");
    (void)field(status, "vmreap");
}

static void validate_preemption(const Status *status) {
    uint32_t preempt;
    uint32_t attempts;
    uint32_t skips;
    uint32_t no_peer;
    uint32_t irq_switches;
    uint32_t user_irq_ticks;
    uint32_t context_switches;
    uint32_t source_pid;
    uint32_t target_pid;
    uint32_t wait[9];
    uint32_t kinds[2];
    uint32_t eips[2];
    uint32_t cr3s[2];
    uint32_t stacks[2];
    uint32_t frame[5];
    uint32_t segs[4];
    uint32_t eflags[5];
    uint32_t preemptabi[5];
    uint32_t expected_payload_kind;

    preempt = hex_field(status, "preempt");
    if (preempt == 0u) {
        fail("preempt= must prove at least one timer-driven context switch");
    }
    irq_switches = hex_field(status, "pirq");
    if (irq_switches == 0u) {
        fail("pirq= must prove timer IRQ context switches");
    }
    if (irq_switches != preempt) {
        fail("pirq= must match preempt= to prove timer IRQ context switches");
    }
    attempts = hex_field(status, "pattempt");
    if (attempts == 0u) {
        fail("pattempt= must prove timer IRQ preemption attempts");
    }
    skips = hex_field(status, "pskip");
    no_peer = has_field(status, "pnone") ? hex_field(status, "pnone") : 0u;
    if (has_field(status, "pnone")) {
        if (skips != 0u) {
            fail("pskip= must stay zero once pnone= accounts for no-peer scheduler attempts");
        }
        if (attempts < preempt || no_peer != attempts - preempt) {
            fail("pnone= must exactly account for timer attempts with no alternate ready process");
        }
    } else if (attempts < preempt || skips != attempts - preempt) {
        fail("pskip= must exactly account for timer attempts with no alternate ready process");
    }
    user_irq_ticks = hex_field(status, "puser");
    if (user_irq_ticks == 0u || user_irq_ticks < preempt) {
        fail("puser= must cover every timer-driven preempt switch");
    }
    if (hex_field(status, "pround") == 0u) {
        fail("pround= must prove the scheduler round advanced");
    }
    context_switches = hex_field(status, "pctx");
    if (context_switches == 0u || context_switches < preempt) {
        fail("pctx= must be at least the preempt switch count");
    }
    if ((hex_field(status, "pmask") & 0x3u) != 0x3u) {
        fail("pmask= must prove the large payload and the preempt probe both ran");
    }
    source_pid = hex_field(status, "pfrom");
    target_pid = hex_field(status, "pto");
    if (source_pid == 0u || target_pid == 0u || source_pid == MISSING_TRANSLATION ||
        target_pid == MISSING_TRANSLATION || source_pid == target_pid) {
        fail("pfrom=/pto= must prove a switch between two real processes");
    }

    hex_tuple(status, "wait", 9, '/', wait);
    if (wait[4] == 0u) {
        fail("wait= must prove the preempt-probe child was seeded");
    }
    if (hex_field(status, "waitseed") == 0u || hex_field(status, "waitseed") == MISSING_TRANSLATION) {
        fail("waitseed= must record the preempt-probe child PID");
    }

    hex_tuple(status, "pkind", 2, ':', kinds);
    if (!((is_large_payload_kind(kinds[0]) && kinds[1] == USER_KIND_PREEMPT_PROBE) ||
          (kinds[0] == USER_KIND_PREEMPT_PROBE && is_large_payload_kind(kinds[1])))) {
        fail("pkind= must switch between a large payload and the preempt probe");
    }
    if (expected_large_payload_kind_for_path(status, &expected_payload_kind) &&
        kinds[0] != expected_payload_kind && kinds[1] != expected_payload_kind) {
        fail("pkind= large payload kind must match selected exec path");
    }
    hex_tuple(status, "peip", 2, ':', eips);
    if (!addr_matches_kind(kinds[0], eips[0]) || !addr_matches_kind(kinds[1], eips[1])) {
        fail("peip= must contain user EIPs matching pkind=");
    }
    hex_tuple(status, "pcr3", 2, ':', cr3s);
    if (is_large_payload_kind(kinds[0]) && cr3s[0] != PROC_PAYLOAD_PAGE_DIR_ADDR) {
        fail("pcr3= large payload slot must use the payload page directory");
    }
    if (is_large_payload_kind(kinds[1]) && cr3s[1] != PROC_PAYLOAD_PAGE_DIR_ADDR) {
        fail("pcr3= large payload slot must use the payload page directory");
    }
    if (kinds[0] == USER_KIND_PREEMPT_PROBE && cr3s[0] != PROC_PREEMPT_PAGE_DIR_ADDR) {
        fail("pcr3= preempt-probe slot must use the preempt page directory");
    }
    if (kinds[1] == USER_KIND_PREEMPT_PROBE && cr3s[1] != PROC_PREEMPT_PAGE_DIR_ADDR) {
        fail("pcr3= preempt-probe slot must use the preempt page directory");
    }

    hex_tuple(status, "pkstk", 2, ':', stacks);
    if (stacks[0] == stacks[1] || stacks[0] == 0u || stacks[1] == 0u) {
        fail("pkstk= must prove distinct kernel stacks for switched processes");
    }
    hex_tuple(status, "pframe", 5, '/', frame);
    if (frame[0] != irq_switches || frame[2] != USER_CODE_SEG || frame[4] != USER_DATA_SEG) {
        fail("pframe= must expose a Ring 3 iret frame");
    }
    hex_tuple(status, "psegs", 4, ':', segs);
    if (segs[0] != USER_DATA_SEG || segs[1] != USER_DATA_SEG ||
        segs[2] != USER_DATA_SEG || segs[3] != USER_DATA_SEG) {
        fail("psegs= must prove user data selectors were restored");
    }
    hex_tuple(status, "peflags", 5, ':', eflags);
    if (!user_eflags_sanitized(eflags[0]) ||
        !user_eflags_sanitized(eflags[1]) ||
        !user_eflags_sanitized_or_rf(eflags[2]) ||
        eflags[4] == 0u ||
        eflags[3] > preempt + user_irq_ticks) {
        fail("peflags= must prove sanitized EFLAGS and the dirty-frame self-test");
    }
    if (!has_field(status, "pself") || strcmp(field(status, "pself"), "OK") != 0) {
        fail("pself= must prove the assembly scheduler self-test passed");
    }
    hex_tuple(status, "preemptabi", 5, '/', preemptabi);
    if (preemptabi[1] != PREEMPT_ABI_FULL_MASK) {
        fail("preemptabi= declared full mask must be 0x%08X", PREEMPT_ABI_FULL_MASK);
    }
    if ((preemptabi[0] & PREEMPT_ABI_FULL_MASK) != PREEMPT_ABI_FULL_MASK) {
        fail("preemptabi= must prove every timer-preemption ABI operation ran in the guest");
    }
    if ((preemptabi[0] & ~PREEMPT_ABI_FULL_MASK) != 0u) {
        fail("preemptabi= contains unknown operation bits");
    }
    if (preemptabi[2] == 0u || (preemptabi[2] & ~PREEMPT_ABI_FULL_MASK) != 0u ||
        (preemptabi[2] & (preemptabi[2] - 1u)) != 0u ||
        (preemptabi[0] & preemptabi[2]) == 0u) {
        fail("preemptabi= last operation must be one completed preemption ABI bit");
    }
    if (preemptabi[3] != irq_switches || preemptabi[4] != frame[0]) {
        fail("preemptabi= switch/frame counts must mirror pirq=/pframe=");
    }
}

static void validate_input_devices(const Status *status) {
    uint32_t queue_total;
    uint32_t depth[2];
    uint32_t stat[4];
    uint32_t policy[2];
    uint32_t dev[2];
    uint32_t devices[5];
    uint32_t inabi[5];
    uint32_t last[3];
    uint64_t accounted;

    if (!has_field(status, "inputstat")) {
        return;
    }

    queue_total = hex_field(status, "inputqueue");
    hex_tuple(status, "inputdepth", 2, ':', depth);
    hex_tuple(status, "inputstat", 4, ':', stat);
    hex_tuple(status, "inputpolicy", 2, ':', policy);
    hex_tuple(status, "inputdev", 2, ':', dev);
    hex_tuple(status, "inputdevices", 5, ':', devices);
    hex_tuple(status, "inputlast", 3, ':', last);

    if (queue_total != stat[0]) {
        fail("inputqueue= must mirror inputstat total events");
    }
    if (stat[3] != VIBE_INPUT_EVENT_QUEUE_USABLE_CAPACITY ||
        policy[1] != VIBE_INPUT_EVENT_QUEUE_USABLE_CAPACITY) {
        fail("inputstat=/inputpolicy= must expose the generic queue usable capacity");
    }
    if (policy[0] != VIBE_INPUT_QUEUE_OVERFLOW_DROP_OLDEST) {
        fail("inputpolicy= must prove drop-oldest overflow handling");
    }
    if (depth[0] > stat[3]) {
        fail("inputdepth= queued events must not exceed usable capacity");
    }
    if (depth[1] != stat[2]) {
        fail("inputdepth= drop count must mirror inputstat dropped events");
    }
    accounted = (uint64_t)stat[1] + (uint64_t)stat[2] + (uint64_t)depth[0];
    if (accounted != (uint64_t)stat[0]) {
        fail("inputstat= total must equal polled + dropped + queued events");
    }
    if (dev[0] > VIBE_INPUT_DEVICE_STATUS_ERROR || dev[1] > VIBE_INPUT_DEVICE_STATUS_ERROR) {
        fail("inputdev= contains an unknown device status");
    }
    if (devices[0] != 2u || (devices[1] & ~0x3u) != 0u) {
        fail("inputdevices= must describe exactly keyboard and mouse");
    }
    if ((devices[2] & VIBE_INPUT_REQUIRED_CAPS) != VIBE_INPUT_REQUIRED_CAPS) {
        fail("inputdevices= must expose generic poll, status, and device-status caps");
    }
    if (dev[0] == VIBE_INPUT_DEVICE_STATUS_READY) {
        if ((devices[1] & 0x1u) == 0u || (devices[2] & VIBE_INPUT_CAP_KEYBOARD) == 0u) {
            fail("inputdevices= must mark the ready keyboard in the ready mask and caps");
        }
    }
    if (dev[1] == VIBE_INPUT_DEVICE_STATUS_READY) {
        if ((devices[1] & 0x2u) == 0u || (devices[2] & VIBE_INPUT_CAP_MOUSE) == 0u) {
            fail("inputdevices= must mark the ready mouse in the ready mask and caps");
        }
    }
    if (devices[3] + devices[4] != stat[1]) {
        fail("inputdevices= per-device poll counts must add up to inputstat polled events");
    }
    if (hex_field(status, "inputmods") & ~VIBE_INPUT_MOD_MASK) {
        fail("inputmods= must stay inside the public modifier bitmask");
    }
    if (last[1] == 0u) {
        if (last[2] != 0u) {
            fail("inputlast= cannot report an event type without a device");
        }
    } else if (last[1] == VIBE_INPUT_DEVICE_KEYBOARD) {
        if (last[2] != VIBE_INPUT_EVENT_KEY) {
            fail("inputlast= keyboard events must use the key event type");
        }
    } else if (last[1] == VIBE_INPUT_DEVICE_MOUSE) {
        if (last[2] != VIBE_INPUT_EVENT_MOUSE_PACKET) {
            fail("inputlast= mouse events must use the mouse packet event type");
        }
    } else {
        fail("inputlast= contains an unknown device id");
    }

    if (has_field(status, "inabi")) {
        hex_tuple(status, "inabi", 5, '/', inabi);
        if (inabi[1] != INPUT_ABI_FULL_MASK) {
            fail("inabi= declared full mask must be 0x%08X", INPUT_ABI_FULL_MASK);
        }
        if ((inabi[0] & INPUT_ABI_FULL_MASK) != INPUT_ABI_FULL_MASK) {
            fail("inabi= must prove generic poll, aggregate status, keyboard status, and mouse status");
        }
        if ((inabi[0] & ~INPUT_ABI_FULL_MASK) != 0u ||
            (inabi[2] & ~INPUT_ABI_FULL_MASK) != 0u ||
            inabi[2] == 0u ||
            (inabi[2] & (inabi[2] - 1u)) != 0u) {
            fail("inabi= must not set unknown operation bits");
        }
        if (inabi[3] == 0u) {
            fail("inabi= must record the driving user process kind");
        }
        if (inabi[4] > 1u) {
            fail("inabi= last result must be an input poll/status success result");
        }
    }
}

static void validate_audio_device(const Status *status) {
    uint32_t adev[3];
    uint32_t pcmbuf[4];
    uint32_t pcmstream[5];
    uint32_t pcmqueue[6];
    uint32_t pcmpull[3];
    uint32_t pcmdma[6];
    uint32_t audabi[4];

    if (!has_field(status, "adev")) {
        return;
    }

    hex_tuple(status, "adev", 3, ':', adev);
    if (has_field(status, "audio")) {
        const char *audio = field(status, "audio");
        if (strcmp(audio, "SB16") == 0) {
            if (adev[0] != AUDIO_DEVICE_SB16 || adev[1] != VIBE_INPUT_DEVICE_STATUS_READY ||
                (adev[2] & AUDIO_REQUIRED_CAPS) != AUDIO_REQUIRED_CAPS) {
                fail("adev= must match audio=SB16 with PCM ring, mixer, pull, and DMA caps");
            }
        } else if (strcmp(audio, "NONE") == 0) {
            if (adev[0] != AUDIO_DEVICE_NONE || adev[2] != 0u) {
                fail("adev= must clear kind and caps when audio=NONE");
            }
        } else {
            fail("audio= must be SB16 or NONE");
        }
    }

    hex_tuple(status, "pcmbuf", 4, ':', pcmbuf);
    if (pcmbuf[0] != SB16_DMA_BUFFER_BYTES || pcmbuf[1] != SB16_DMA_BLOCK_BYTES ||
        pcmbuf[2] >= pcmbuf[0] || pcmbuf[3] > 1u) {
        fail("pcmbuf= must describe the bounded SB16 DMA ring");
    }

    hex_tuple(status, "pcmstream", 5, ':', pcmstream);
    if (pcmstream[0] > AUDIO_STREAM_PULL || pcmstream[2] > 1u ||
        pcmstream[3] > AUDIO_PCM_QUEUE_BYTES) {
        fail("pcmstream= must describe a bounded pull stream");
    }
    if (pcmstream[2] != 0u && pcmstream[0] == 0u) {
        fail("pcmstream= active streams must have a nonzero stream mode");
    }

    hex_tuple(status, "pcmqueue", 6, ':', pcmqueue);
    if (pcmqueue[0] != 0u && pcmqueue[0] != AUDIO_PCM_QUEUE_BYTES) {
        fail("pcmqueue= capacity must be either absent or the generic PCM queue size");
    }
    if (pcmqueue[1] > pcmqueue[0] || pcmqueue[5] > pcmqueue[0]) {
        fail("pcmqueue= byte counters must stay within queue capacity");
    }

    hex_tuple(status, "pcmpull", 3, ':', pcmpull);
    if (pcmpull[2] != (pcmpull[0] > pcmpull[1] ? pcmpull[0] - pcmpull[1] : 0u)) {
        fail("pcmpull= pending count must derive from requests minus refills");
    }

    hex_tuple(status, "pcmdma", 6, ':', pcmdma);
    if (pcmdma[0] > SB16_DMA_STATUS_FAIL || pcmdma[1] > SB16_DMA_ERROR_DSP ||
        pcmdma[5] >= SB16_DMA_BUFFER_BYTES) {
        fail("pcmdma= must expose bounded DMA status, error, and transfer count");
    }
    if (has_field(status, "audabi") && has_field(status, "audio") &&
        strcmp(field(status, "audio"), "SB16") == 0) {
        hex_tuple(status, "audabi", 4, '/', audabi);
        if (audabi[1] != AUDIO_ABI_FULL_MASK) {
            fail("audabi= declared full mask must be 0x%08X", AUDIO_ABI_FULL_MASK);
        }
        if ((audabi[0] & AUDIO_ABI_FULL_MASK) != AUDIO_ABI_FULL_MASK) {
            fail("audabi= must prove generic user audio opened, wrote, queried, drained, and closed PCM");
        }
        if ((audabi[0] & ~AUDIO_ABI_FULL_MASK) != 0u) {
            fail("audabi= must not set unknown operation bits");
        }
        if (audabi[2] == 0u || (audabi[2] & ~AUDIO_ABI_FULL_MASK) != 0u ||
            (audabi[2] & (audabi[2] - 1u)) != 0u) {
            fail("audabi= last operation must be exactly one known operation bit");
        }
        if (audabi[3] == 0u || audabi[3] > AUDIO_CMD_PCM_CLOSE) {
            fail("audabi= last command must be a known generic PCM lifecycle command");
        }
    }
}

static void validate_framebuffer_device(const Status *status) {
    uint32_t fbpresent[9];
    uint32_t fbinfo[3];
    uint32_t fbsrc[7];
    uint32_t fbacct[9];
    uint32_t fbdev[4];
    uint32_t fbmmio[4];
    uint32_t fbgeom[5];
    uint32_t fbdirty[5];
    uint32_t fbabi[5];
    uint32_t fbcap;
    uint32_t backend;

    if (!has_field(status, "fbdev")) {
        return;
    }

    hex_tuple(status, "fbdev", 4, ':', fbdev);
    backend = fbdev[1];
    if (fbdev[0] != VIBE_INPUT_DEVICE_STATUS_READY ||
        (backend != VIDEO_BACKEND_MODE13 && backend != VIDEO_BACKEND_LFB_XRGB8888) ||
        fbdev[2] < FRAMEBUFFER_HANDOFF_SOURCE_VGA_MODE13 ||
        fbdev[2] > FRAMEBUFFER_HANDOFF_SOURCE_GOP || fbdev[3] > VIBE_INPUT_DEVICE_STATUS_ERROR) {
        fail("fbdev= must describe a ready mode13 or direct-8888 framebuffer device");
    }
    if (has_field(status, "fb")) {
        const char *fb = field(status, "fb");
        if ((backend == VIDEO_BACKEND_LFB_XRGB8888 && strcmp(fb, "LFB") != 0) ||
            (backend == VIDEO_BACKEND_MODE13 && strcmp(fb, "M13") != 0)) {
            fail("fb= must match fbdev backend");
        }
    }
    if (has_field(status, "fbpolicy")) {
        const char *policy = field(status, "fbpolicy");
        if (strcmp(policy, "M13") != 0 && strcmp(policy, "ASP") != 0 &&
            strcmp(policy, "SQ") != 0) {
            fail("fbpolicy= must be M13, ASP, or SQ");
        }
    }

    fbcap = hex_field(status, "fbcap");
    if ((fbcap & VIBE_FB_REQUIRED_CAPS) != VIBE_FB_REQUIRED_CAPS) {
        fail("fbcap= must expose indexed present, RGB palette, and dirty rect caps");
    }
    if (backend == VIDEO_BACKEND_LFB_XRGB8888) {
        uint32_t direct_caps = fbcap & VIBE_FB_CAP_DIRECT8888_LFB;
        if ((direct_caps != VIBE_FB_CAP_XRGB8888_LFB && direct_caps != VIBE_FB_CAP_XBGR8888_LFB) ||
            fbdev[3] != VIBE_INPUT_DEVICE_STATUS_READY) {
            fail("fbdev=/fbcap= must prove mapped XRGB8888 or XBGR8888 LFB support for the LFB backend");
        }
    } else if ((fbcap & (VIBE_FB_CAP_MODE13_SHADOW | VIBE_FB_CAP_FIXED_PRESENT_SIZE)) !=
               (VIBE_FB_CAP_MODE13_SHADOW | VIBE_FB_CAP_FIXED_PRESENT_SIZE)) {
        fail("fbcap= must expose mode13 shadow and fixed-size semantics for the mode13 backend");
    }

    hex_tuple(status, "fbsrc", 7, ':', fbsrc);
    if (fbsrc[0] != VIBE_FB_FORMAT_INDEX8_RGB24 || fbsrc[1] != FB_PRESENT_WIDTH ||
        fbsrc[2] != FB_PRESENT_HEIGHT || fbsrc[3] != FB_PRESENT_WIDTH ||
        fbsrc[4] != FB_PRESENT_ASPECT_HEIGHT || fbsrc[5] != FB_PRESENT_PALETTE_ENTRIES ||
        fbsrc[6] != FB_PRESENT_PALETTE_ENTRY_BYTES) {
        fail("fbsrc= must describe the public indexed 320x200 RGB24 source ABI");
    }

    hex_tuple(status, "fbacct", 9, ':', fbacct);
    if (fbacct[0] != FRAMEBUFFER_ABI_VERSION ||
        fbacct[1] != FRAMEBUFFER_PRESENT_SEMANTICS_INDEXED_SOURCE ||
        (fbacct[5] != 0u && (fbacct[7] != FB_PRESENT_FRAME_BYTES ||
                             fbacct[8] != FB_PRESENT_PALETTE_BYTES))) {
        fail("fbacct= must expose the indexed-present ABI and source byte accounting");
    }

    hex_tuple(status, "fbpresent", 9, ':', fbpresent);
    if (fbpresent[0] != fbpresent[1] + fbpresent[2]) {
        fail("fbpresent= total must equal syscall plus ioctl present counts");
    }
    if (fbpresent[0] != 0u &&
        (fbpresent[6] == 0u || fbpresent[7] > FB_PRESENT_WIDTH ||
         fbpresent[8] > FB_PRESENT_HEIGHT)) {
        fail("fbpresent= must report a bounded last present source and size");
    }

    hex_tuple(status, "fbinfo", 3, ':', fbinfo);
    if (fbinfo[0] != 0u && (fbinfo[1] == 0u || fbinfo[2] == 0u)) {
        fail("fbinfo= must account the querying process for nonzero info queries");
    }

    hex_tuple(status, "fbmmio", 4, ':', fbmmio);
    if (backend == VIDEO_BACKEND_LFB_XRGB8888 && (fbmmio[0] == 0u || fbmmio[1] == 0u)) {
        fail("fbmmio= must expose mapped MMIO pages for the LFB backend");
    }

    hex_tuple(status, "fbgeom", 5, ':', fbgeom);
    if (fbgeom[2] == 0u || fbgeom[3] == 0u || fbgeom[4] == 0u ||
        fbgeom[2] > FB_PRESENT_WIDTH * 4u || fbgeom[3] > FB_PRESENT_HEIGHT * 4u) {
        fail("fbgeom= must describe a bounded nonzero present view");
    }

    hex_tuple(status, "fbdirty", 5, ':', fbdirty);
    if (fbdirty[2] > FB_PRESENT_WIDTH || fbdirty[3] > FB_PRESENT_HEIGHT ||
        fbdirty[0] + fbdirty[2] > FB_PRESENT_WIDTH ||
        fbdirty[1] + fbdirty[3] > FB_PRESENT_HEIGHT) {
        fail("fbdirty= must stay inside the indexed source rectangle");
    }

    if (has_field(status, "fbabi")) {
        hex_tuple(status, "fbabi", 5, '/', fbabi);
        if (fbabi[1] != FB_ABI_FULL_MASK) {
            fail("fbabi= declared full mask must be 0x%08X", FB_ABI_FULL_MASK);
        }
        if ((fbabi[0] & FB_ABI_FULL_MASK) != FB_ABI_FULL_MASK) {
            fail("fbabi= must prove generic framebuffer info, ioctl present, and dirty tracking");
        }
        if ((fbabi[0] & ~FB_ABI_FULL_MASK) != 0u || (fbabi[2] & ~FB_ABI_FULL_MASK) != 0u ||
            fbabi[2] == 0u) {
            fail("fbabi= must not set unknown operation bits");
        }
        if (fbabi[3] > FRAMEBUFFER_PRESENT_SOURCE_IOCTL) {
            fail("fbabi= last source must be none, syscall present, or ioctl present");
        }
        if (fbabi[4] == 0u) {
            fail("fbabi= must record the driving user process kind");
        }
    }
}

static void validate_device_status(const Status *status) {
    validate_input_devices(status);
    validate_audio_device(status);
    validate_framebuffer_device(status);
}

static void validate_pi4_input_status(const Status *status) {
    const char *input;
    const char *usb;
    uint64_t dev[4];
    uint64_t queue[4];
    uint64_t last[2];
    uint64_t events[PI4_UART_INPUT_EVENT_COUNTER_FIELDS];
    uint64_t event_total;
    int have_event_counts;
    int usb_wait;
    static const char *const usb_fields[] = {
        "pi4usbdev",
        "pi4usbq",
    };

    input = field(status, "pi4input");
    if (strcmp(input, "UART-LIVE") != 0 && strcmp(input, "UART") != 0) {
        fail("pi4input= must report UART-LIVE for the supported Pi/QEMU lane, or legacy UART fixture status");
    }
    if (strcmp(input, "UART-LIVE") == 0) {
        if (has_field(status, "scripted_input") ||
            field_equals(status, "pi4inputmode", "SCRIPTED") ||
            field_equals(status, "pi4inputsrc", "SCRIPTED")) {
            fail("pi4input=UART-LIVE must not be paired with scripted UART input metadata");
        }
    }
    usb = field(status, "pi4usb");
    usb_wait = strcmp(usb, "WAIT") == 0;
    if (!usb_wait &&
        strcmp(usb, "HOST") != 0 &&
        strcmp(usb, "PORT") != 0 &&
        strcmp(usb, "ADDR") != 0 &&
        strcmp(usb, "HID") != 0 &&
        strcmp(usb, "KBD") != 0 &&
        strcmp(usb, "MOUSE") != 0 &&
        strcmp(usb, "BOTH") != 0) {
        fail("pi4usb= must be WAIT, a USB probe stage, or a detected HID input kind");
    }
    if (usb_wait) {
        reject_fields(status, "pi4usb=WAIT", usb_fields, ARRAY_LEN(usb_fields));
    }

    hex64_tuple_exact(status, "pi4inputdev", 4, '/', dev);
    if (usb_wait) {
        if (dev[0] != PI4_INPUT_DEVICE_UART ||
            dev[1] != VIBE_INPUT_DEVICE_STATUS_READY ||
            (dev[2] & PI4_UART_INPUT_REQUIRED_CAPS) != PI4_UART_INPUT_REQUIRED_CAPS ||
            dev[3] != PI4_UART_INPUT_QUEUE_SIZE) {
            fail("pi4inputdev= must describe ready UART serial input with poll/status/device-status caps");
        }
        if ((dev[2] & (VIBE_INPUT_CAP_KEYBOARD | VIBE_INPUT_CAP_MOUSE)) != 0u) {
            fail("pi4inputdev= must not advertise UART input as keyboard, mouse, or USB");
        }
    } else {
        if ((dev[0] != PI4_INPUT_DEVICE_UART &&
                dev[0] != PI4_INPUT_DEVICE_USB &&
                dev[0] != VIBE_INPUT_DEVICE_KEYBOARD &&
                dev[0] != VIBE_INPUT_DEVICE_MOUSE) ||
            dev[1] != VIBE_INPUT_DEVICE_STATUS_READY ||
            dev[2] == 0u ||
            dev[3] != PI4_UART_INPUT_QUEUE_SIZE) {
            fail("pi4inputdev= must describe a ready UART, USB, keyboard, or mouse input lane while pi4usb is active");
        }
    }

    hex64_tuple_exact(status, "pi4inputq", 4, '/', queue);
    if (queue[0] >= dev[3]) {
        fail("pi4inputq= queued events must fit in the UART ring");
    }
    if (queue[1] < queue[2] || queue[1] - queue[2] < queue[0]) {
        fail("pi4inputq= total events must account for polled and queued UART input");
    }

    have_event_counts = has_field(status, "pi4inputevt");
    if (have_event_counts) {
        hex64_tuple_exact(status, "pi4inputevt", PI4_UART_INPUT_EVENT_COUNTER_FIELDS, '/', events);
        event_total = events[0] + events[1] + events[2] + events[3] + events[4];
        if (event_total != queue[1]) {
            fail("pi4inputevt= stable UART launcher/gameplay counters must add up to total events");
        }
    }

    hex64_tuple_exact(status, "pi4inputlast", 2, '/', last);
    if (last[0] == 0u) {
        if (last[1] != 0u) {
            fail("pi4inputlast= cannot report a UART event without a UART device id");
        }
    } else if (last[0] == PI4_INPUT_DEVICE_UART) {
        if (last[1] > PI4_UART_INPUT_EVENT_MAX) {
            fail("pi4inputlast= contains an unknown UART launcher/gameplay event");
        }
        if (last[1] != 0u && have_event_counts && events[last[1] - 1u] == 0u) {
            fail("pi4inputlast= must refer to a counted UART launcher/gameplay event");
        }
    } else if (last[0] == PI4_INPUT_DEVICE_USB ||
        last[0] == VIBE_INPUT_DEVICE_KEYBOARD ||
        last[0] == VIBE_INPUT_DEVICE_MOUSE) {
        if (usb_wait) {
            fail("pi4inputlast= must not report HID input while pi4usb=WAIT");
        }
        if (last[0] == VIBE_INPUT_DEVICE_KEYBOARD && last[1] != VIBE_INPUT_EVENT_KEY) {
            fail("pi4inputlast= keyboard device must report a key event type");
        }
        if (last[0] == VIBE_INPUT_DEVICE_MOUSE && last[1] != VIBE_INPUT_EVENT_MOUSE_PACKET) {
            fail("pi4inputlast= mouse device must report a mouse packet event type");
        }
        if (last[0] == PI4_INPUT_DEVICE_USB &&
            last[1] != VIBE_INPUT_EVENT_KEY &&
            last[1] != VIBE_INPUT_EVENT_MOUSE_PACKET) {
            fail("pi4inputlast= USB device must report key or mouse packet input");
        }
    } else {
        fail("pi4inputlast= contains an unknown Pi input device id");
    }
}

static void validate_pi4_audio_status(const Status *status) {
    const char *audio = field(status, "pi4audio");
    const char *audiohw = field(status, "pi4audiohw");
    const char *audiomailbox = field(status, "pi4audiomailbox");
    static const char *const audio_hardware_fields[] = {
        "pi4audiodev",
        "pi4audiofmt",
        "pi4audiorate",
        "pi4audiocount",
    };

    if (strcmp(audio, "WAIT") == 0) {
        if (strcmp(audiohw, "NONE") != 0 || strcmp(audiomailbox, "WAIT") != 0 ||
            !field_is_none_or_zero_tuple(status, "pi4audiommio", 4) ||
            !field_is_none_or_zero_tuple(status, "pi4audiocap", 1) ||
            !field_is_none_or_zero_tuple(status, "pi4audioq", 4) ||
            !field_is_none_or_zero_tuple(status, "pi4audioabi", 4)) {
            fail("pi4audio=WAIT requires pi4audiohw=NONE, pi4audiomailbox=WAIT, and no nonzero audio capability/queue/ABI evidence");
        }
        reject_fields(status, "pi4audio=WAIT", audio_hardware_fields,
                      ARRAY_LEN(audio_hardware_fields));
        return;
    }

    if (strcmp(audio, "HARDWARE-UNPROVEN") == 0) {
        uint64_t mmio[4];
        uint64_t mailbox[4] = {0u, 0u, 0u, 0u};
        uint64_t cap[1];

        if (strcmp(audiohw, "PWM") != 0 && strcmp(audiohw, "PCM") != 0 &&
            strcmp(audiohw, "HDMI") != 0) {
            fail("pi4audio=HARDWARE-UNPROVEN must name the attempted Pi audio hardware path");
        }
        hex64_tuple_exact(status, "pi4audiommio", 4, '/', mmio);
        if (mmio[0] == 0u || mmio[1] == 0u || mmio[2] == 0u) {
            fail("pi4audio=HARDWARE-UNPROVEN must include the attempted MMIO audio window");
        }
        if (strcmp(audiomailbox, "WAIT") != 0) {
            hex64_tuple_exact(status, "pi4audiomailbox", 4, '/', mailbox);
        }
        hex64_tuple_exact(status, "pi4audiocap", 1, '/', cap);
        if (cap[0] == 0u || (cap[0] & ~PI4_AUDIO_REQUIRED_CAPS) != 0u) {
            fail("pi4audio=HARDWARE-UNPROVEN may only expose bounded Pi audio capability evidence");
        }
        if (mailbox[0] != 0u && (cap[0] & PI4_AUDIO_CAP_MAILBOX_CLOCK) == 0u) {
            fail("pi4audio=HARDWARE-UNPROVEN mailbox evidence must be reflected in pi4audiocap=");
        }
        if (!field_is_none_or_zero_tuple(status, "pi4audioq", 4) ||
            !field_is_none_or_zero_tuple(status, "pi4audioabi", 4)) {
            fail("pi4audio=HARDWARE-UNPROVEN must not claim PCM queue or audio ABI proof");
        }
        reject_fields(status, "pi4audio=HARDWARE-UNPROVEN", audio_hardware_fields,
                      ARRAY_LEN(audio_hardware_fields));
        return;
    }

    if (strcmp(audio, "OK") == 0) {
        uint64_t mmio[4];
        uint64_t mailbox[4];
        uint64_t cap[1];
        uint64_t queue[4];
        uint64_t abi[4];

        if (strcmp(audiohw, "PWM") != 0 && strcmp(audiohw, "PCM") != 0 &&
            strcmp(audiohw, "HDMI") != 0) {
            fail("pi4audio=OK must name a real Pi audio hardware path: PWM, PCM, or HDMI");
        }
        hex64_tuple_exact(status, "pi4audiommio", 4, '/', mmio);
        if (mmio[0] == 0u || mmio[1] == 0u || mmio[2] == 0u || mmio[3] == 0u) {
            fail("pi4audio=OK must include nonzero pi4audiommio= hardware window evidence");
        }
        hex64_tuple_exact(status, "pi4audiomailbox", 4, '/', mailbox);
        if (mailbox[0] == 0u || mailbox[1] == 0u || mailbox[2] == 0u || mailbox[3] == 0u) {
            fail("pi4audio=OK must include nonzero pi4audiomailbox= capability evidence");
        }
        hex64_tuple_exact(status, "pi4audiocap", 1, '/', cap);
        if ((cap[0] & PI4_AUDIO_REQUIRED_CAPS) != PI4_AUDIO_REQUIRED_CAPS ||
            (cap[0] & ~PI4_AUDIO_REQUIRED_CAPS) != 0u) {
            fail("pi4audio=OK must include exactly the Pi audio MMIO, mailbox-clock, and PCM-queue capability mask");
        }
        hex64_tuple_exact(status, "pi4audioq", 4, '/', queue);
        if (queue[0] == 0u || queue[1] == 0u || queue[1] > queue[0] || queue[2] == 0u) {
            fail("pi4audio=OK must include bounded nonzero pi4audioq= bytes/usable/stream evidence");
        }
        hex64_tuple_exact(status, "pi4audioabi", 4, '/', abi);
        if (abi[1] != PI4_AUDIO_ABI_FULL_MASK ||
            (abi[0] & PI4_AUDIO_ABI_FULL_MASK) != PI4_AUDIO_ABI_FULL_MASK ||
            (abi[0] & ~PI4_AUDIO_ABI_FULL_MASK) != 0u || abi[2] == 0u ||
            abi[3] == 0u) {
            fail("pi4audio=OK must include the full Pi audio device, queue, and capability ABI mask");
        }
        if (has_field(status, "pi4audiodev")) {
            uint64_t dev[4];
            hex64_tuple_exact(status, "pi4audiodev", 4, '/', dev);
            if (dev[0] != PI4_AUDIO_DEVICE_PI4_PWM ||
                dev[1] != PI4_AUDIO_DEVICE_STATUS_READY ||
                dev[2] != cap[0] || dev[3] == 0u) {
                fail("pi4audiodev= must expose the ready Pi PWM device, caps, and backend-ready bit");
            }
        }
        if (has_field(status, "pi4audiofmt")) {
            uint64_t fmt[4];
            hex64_tuple_exact(status, "pi4audiofmt", 4, '/', fmt);
            if (fmt[0] != PI4_AUDIO_FORMAT_U8_STEREO ||
                fmt[1] != PI4_AUDIO_CHANNELS ||
                fmt[2] == 0u || fmt[3] == 0u || fmt[3] > fmt[2]) {
                fail("pi4audiofmt= must expose a bounded U8 stereo PCM queue format");
            }
        }
        if (has_field(status, "pi4audiorate")) {
            uint64_t rate[4];
            hex64_tuple_exact(status, "pi4audiorate", 4, '/', rate);
            if (rate[0] == 0u || rate[1] == 0u || rate[2] > queue[0]) {
                fail("pi4audiorate= must expose nonzero sample timing and bounded queued bytes");
            }
        }
        if (has_field(status, "pi4audiocount")) {
            uint64_t count[4];
            hex64_tuple_exact(status, "pi4audiocount", 4, '/', count);
            if (count[0] == 0u || count[1] == 0u || count[2] == 0u) {
                fail("pi4audiocount= must prove payload audio calls, device start, and mixed PCM bytes");
            }
        }
        return;
    }

    fail("pi4audio= must be WAIT, HARDWARE-UNPROVEN, or OK, got %s", audio);
}

static void validate_pi4_mailbox_status(const Status *status) {
    const char *mailbox = field(status, "pi4mailbox");
    static const char *const mailbox_fields[] = {
        "pi4fbmail",
    };

    if (strcmp(mailbox, "WAIT") == 0) {
        reject_fields(status, "pi4mailbox=WAIT", mailbox_fields, ARRAY_LEN(mailbox_fields));
        return;
    }

    if (strcmp(mailbox, "OK") == 0) {
        if (!has_field(status, "pi4fbmail")) {
            fail("pi4mailbox=OK must include Pi mailbox response evidence");
        }
        return;
    }

    fail("pi4mailbox= must be WAIT or OK, got %s", mailbox);
}

static int pi4_storage_mbr_part_type_is_fat(uint64_t part_type) {
    return part_type == PI4_MBR_PART_TYPE_FAT16 ||
           part_type == PI4_MBR_PART_TYPE_FAT32_CHS ||
           part_type == PI4_MBR_PART_TYPE_FAT32_LBA;
}

static void validate_pi4_storage_mbr(const Status *status, uint64_t *mbr) {
    hex64_tuple_exact(status, "pi4mbr", 6, '/', mbr);
    if (mbr[0] != 0xaa55u || mbr[1] >= 4u || (mbr[2] != 0u && mbr[2] != 0x80u) ||
        !pi4_storage_mbr_part_type_is_fat(mbr[3]) || mbr[4] == 0u || mbr[5] == 0u) {
        fail("pi4mbr= must prove MBR signature, partition type, LBA, and sector count");
    }
    if (mbr[5] > UINT64_MAX - mbr[4]) {
        fail("pi4mbr= partition LBA/count must stay within 64-bit media coordinates");
    }
}

static void validate_pi4_storage_fat_evidence(const Status *status, const uint64_t *mbr,
                                              uint64_t *bpb, uint64_t *root) {
    uint64_t partition_end = mbr[4] + mbr[5];

    hex64_tuple_exact(status, "pi4bpb", 9, '/', bpb);
    if (bpb[0] != 0xaa55u || bpb[1] != PI4_BLOCK_READ_SECTOR_BYTES ||
        bpb[2] == 0u || bpb[2] > 128u || bpb[3] == 0u || bpb[4] == 0u ||
        bpb[5] == 0u || bpb[6] == 0u || bpb[7] == 0u || bpb[8] == 0u) {
        fail("pi4bpb= must prove BPB signature, geometry, FAT count, size, and clusters");
    }
    if (bpb[6] > mbr[5]) {
        fail("pi4bpb= total sectors must fit inside the validated MBR partition");
    }

    hex64_tuple_exact(status, "pi4root", 4, '/', root);
    if (root[3] == 0u || ((root[0] == 0u || root[1] == 0u) && root[2] == 0u)) {
        fail("pi4root= must prove a FAT root directory/cluster and data LBA");
    }
    if (root[3] < mbr[4] || root[3] >= partition_end) {
        fail("pi4root= data LBA must live inside the validated MBR partition");
    }
}

static void validate_pi4_storage_root_artifact(const Status *status, const char *name) {
    uint64_t file[4];

    hex64_tuple_exact(status, name, 4, '/', file);
    if (file[0] == 0u ||
        (file[1] & PI4_FAT_ATTR_LONG_NAME) == PI4_FAT_ATTR_LONG_NAME ||
        (file[1] & (PI4_FAT_ATTR_VOLUME_ID | PI4_FAT_ATTR_DIRECTORY)) != 0u ||
        file[2] < 2u || file[3] == 0u) {
        fail("%s= must prove regular root FAT metadata for a packaged Pi image artifact", name);
    }
}

static uint64_t validate_pi4_storage_asset_summary(const Status *status) {
    uint64_t assets[3];

    hex64_tuple_exact(status, "pi4assets", 3, '/', assets);
    if (assets[0] < 3u || assets[1] < 2u ||
        (assets[2] & PI4_STORAGE_ASSET_REQUIRED_COVERAGE) !=
            PI4_STORAGE_ASSET_REQUIRED_COVERAGE) {
        fail("pi4assets= must prove default asset files, nested asset directories, WAD, and manifest coverage");
    }
    return assets[2];
}

static void validate_pi4_storage_file_evidence(const Status *status, const uint64_t *mbr,
                                               const uint64_t *bpb, const uint64_t *root,
                                               const char *name);

static void validate_pi4_storage_asset_evidence(const Status *status, const uint64_t *mbr,
                                                const uint64_t *bpb, const uint64_t *root) {
    uint64_t coverage;

    validate_pi4_storage_root_artifact(status, "pi4kernel8");
    validate_pi4_storage_root_artifact(status, "pi4config");
    validate_pi4_storage_root_artifact(status, "pi4abiprobe");
    validate_pi4_storage_file_evidence(status, mbr, bpb, root, "pi4manifest");
    validate_pi4_storage_file_evidence(status, mbr, bpb, root, "pi4wad");
    coverage = validate_pi4_storage_asset_summary(status);
    if ((coverage & PI4_STORAGE_ASSET_COVERAGE_PAK0) != 0u) {
        validate_pi4_storage_file_evidence(status, mbr, bpb, root, "pi4pak0");
    } else if (has_field(status, "pi4pak0")) {
        fail("pi4pak0= requires the pi4assets= PAK coverage bit");
    }
}

static void validate_pi4_storage_file_tuple(const uint64_t *mbr, const uint64_t *bpb,
                                            const uint64_t *root, const char *name,
                                            const uint64_t *file) {
    uint64_t partition_end = mbr[4] + mbr[5];
    uint64_t bytes_per_sector;
    uint64_t sectors_per_cluster;
    uint64_t expected_lba;
    uint64_t expected_plan_bytes;
    uint64_t expected_plan_sectors;

    if ((file[1] & PI4_FAT_ATTR_LONG_NAME) == PI4_FAT_ATTR_LONG_NAME ||
        (file[1] & (PI4_FAT_ATTR_VOLUME_ID | PI4_FAT_ATTR_DIRECTORY)) != 0u ||
        file[2] < 2u || file[3] == 0u || file[4] == 0u || file[5] == 0u ||
        file[6] == 0u) {
        fail("%s= must prove regular FAT file metadata with first-cluster read plan", name);
    }

    bytes_per_sector = bpb[1];
    sectors_per_cluster = bpb[2];
    if (bytes_per_sector == 0u || sectors_per_cluster == 0u ||
        sectors_per_cluster > UINT64_MAX / bytes_per_sector ||
        (file[2] - 2u) > (UINT64_MAX - root[3]) / sectors_per_cluster ||
        file[3] > UINT64_MAX - (bytes_per_sector - 1u)) {
        fail("%s= cannot be checked against invalid BPB geometry", name);
    }

    expected_lba = root[3] + ((file[2] - 2u) * sectors_per_cluster);
    expected_plan_bytes = file[3];
    expected_plan_sectors = (file[3] + bytes_per_sector - 1u) / bytes_per_sector;
    if (file[4] != expected_lba || file[5] != expected_plan_sectors ||
        file[6] != expected_plan_bytes) {
        fail("%s= read plan must match first cluster, file size, and BPB geometry", name);
    }
    if (file[4] < mbr[4] || file[4] >= partition_end || file[5] > partition_end - file[4]) {
        fail("%s= first-cluster read plan must stay inside the validated MBR partition", name);
    }
    if (file[7] > file[5] && strcmp(name, "pi4wad") != 0 &&
        strcmp(name, "pi4pak0") != 0) {
        fail("%s= read count cannot exceed the planned first-cluster read", name);
    }
    if (file[7] != file[5] && strcmp(name, "pi4payload0") != 0 &&
        strcmp(name, "pi4payload1") != 0 && strcmp(name, "pi4manifest") != 0 &&
        strcmp(name, "pi4wad") != 0 && strcmp(name, "pi4pak0") != 0) {
        fail("%s= read count must prove the full planned first-cluster read completed", name);
    }
}

static void validate_pi4_storage_file_evidence(const Status *status, const uint64_t *mbr,
                                               const uint64_t *bpb, const uint64_t *root,
                                               const char *name) {
    uint64_t file[8];

    hex64_tuple_exact(status, name, 8, '/', file);
    validate_pi4_storage_file_tuple(mbr, bpb, root, name, file);
}

static void validate_pi4_payload_vfs_evidence(const Status *status) {
    uint64_t payloadvfs[10];
    uint64_t payload_file[8];
    uint64_t mbr[6];
    uint64_t bpb[9];
    uint64_t root[4];
    const char *payload_key;
    size_t i;

    exact(status, "pi4vfs", "OK");
    hex64_tuple_exact(status, "pi4payloadvfs", 10, '/', payloadvfs);
    if (payloadvfs[0] != PI4_VIBE_PAYLOAD_SLOT0 && payloadvfs[0] != PI4_VIBE_PAYLOAD_SLOT1) {
        fail("pi4payloadvfs= slot must be PAYLOAD0 or PAYLOAD1");
    }
    if (payloadvfs[1] != PI4_STORAGE_FILE_STATUS_OK) {
        fail("pi4payloadvfs= must prove the selected payload ELF was present in the Pi VFS");
    }

    payload_key = payloadvfs[0] == PI4_VIBE_PAYLOAD_SLOT0 ? "pi4payload0" : "pi4payload1";
    hex64_tuple_exact(status, payload_key, 8, '/', payload_file);
    for (i = 0; i < ARRAY_LEN(payload_file); i++) {
        if (payloadvfs[i + 2u] != payload_file[i]) {
            fail("pi4payloadvfs= must match the selected %s= full-file read plan", payload_key);
        }
    }

    validate_pi4_storage_mbr(status, mbr);
    validate_pi4_storage_fat_evidence(status, mbr, bpb, root);
    validate_pi4_storage_file_tuple(mbr, bpb, root, "pi4payloadvfs", payloadvfs + 2u);
}

static void validate_pi4_user_file_status(const Status *status) {
    uint64_t file[13];
    uint64_t asset_tuple[8];
    uint64_t expected_fd = 0;
    const char *asset_field = NULL;

    if (!has_field(status, "pi4userfile")) {
        return;
    }

    hex64_tuple_exact(status, "pi4userfile", 13, '/', file);
    if (!any_nonzero64(file, ARRAY_LEN(file))) {
        return;
    }

    if ((file[0] & ~PI4_USER_FILE_OP_FULL_MASK) != 0u ||
        file[1] == 0u || (file[1] & ~PI4_USER_FILE_OP_FULL_MASK) != 0u ||
        (file[1] & (file[1] - 1u)) != 0u || (file[0] & file[1]) == 0u) {
        fail("pi4userfile= must use known open/size/read operation bits");
    }
    if (file[10] == 0u || (file[0] & PI4_USER_FILE_OP_OPEN) == 0u) {
        fail("pi4userfile= must prove an EL0 open attempt");
    }

    if (file[3] == PI4_USER_FILE_ASSET_DOOM1_WAD) {
        expected_fd = PI4_VIBE_FD_DOOM1_WAD;
        asset_field = "pi4wad";
    } else if (file[3] == PI4_USER_FILE_ASSET_PAK0_PAK) {
        expected_fd = PI4_VIBE_FD_PAK0_PAK;
        asset_field = "pi4pak0";
    } else {
        fail("pi4userfile= asset id must be DOOM1.WAD or /ID1/PAK0.PAK");
    }
    if (file[4] != expected_fd) {
        fail("pi4userfile= fd must match the selected payload asset");
    }

    if (file[8] == neg_errno64(PI4_VIBE_ENOENT) ||
        file[8] == neg_errno64(PI4_VIBE_ENOSYS)) {
        if ((file[0] & (PI4_USER_FILE_OP_SIZE | PI4_USER_FILE_OP_READ)) != 0u ||
            file[11] != 0u || file[12] != 0u) {
            fail("pi4userfile= missing/unavailable files must not claim size/read calls");
        }
        return;
    }

    if ((file[0] & PI4_USER_FILE_OP_FULL_MASK) != PI4_USER_FILE_OP_FULL_MASK ||
        file[1] != PI4_USER_FILE_OP_READ || file[11] == 0u || file[12] == 0u) {
        fail("pi4userfile= successful payload file proof must include open, size, and read");
    }
    if (file[2] != PI4_VIBE_PAYLOAD_SLOT0 && file[2] != PI4_VIBE_PAYLOAD_SLOT1) {
        fail("pi4userfile= must record the selected payload slot");
    }
    if ((file[3] == PI4_USER_FILE_ASSET_DOOM1_WAD && file[2] != PI4_VIBE_PAYLOAD_SLOT0) ||
        (file[3] == PI4_USER_FILE_ASSET_PAK0_PAK && file[2] != PI4_VIBE_PAYLOAD_SLOT1)) {
        fail("pi4userfile= payload slot must match the expected Doom/Quake asset");
    }
    if (file[5] == 0u || file[7] == 0u || file[8] == 0u || file[8] > file[7]) {
        fail("pi4userfile= successful read must expose nonzero size/request/result");
    }
    if (file[6] != 0u) {
        fail("pi4userfile= proof read must start at file offset zero");
    }
    if (file[3] == PI4_USER_FILE_ASSET_DOOM1_WAD) {
        if (file[9] != PI4_USER_FILE_MAGIC_IWAD && file[9] != PI4_USER_FILE_MAGIC_PWAD) {
            fail("pi4userfile= Doom payload read must expose IWAD/PWAD magic");
        }
    } else if (file[9] != PI4_USER_FILE_MAGIC_PACK) {
        fail("pi4userfile= Quake payload read must expose PACK magic");
    }
    if (has_field(status, asset_field)) {
        hex64_tuple_exact(status, asset_field, 8, '/', asset_tuple);
        if (asset_tuple[3] != file[5]) {
            fail("pi4userfile= size must match the boot-discovered %s= tuple", asset_field);
        }
    }
}

static void validate_pi4_engine_asset_vfs_read(const Status *status, uint64_t slot) {
    uint64_t file[13];
    uint64_t expected_asset;
    uint64_t expected_fd;
    const char *payload_name;

    if (slot == PI4_VIBE_PAYLOAD_SLOT0) {
        expected_asset = PI4_USER_FILE_ASSET_DOOM1_WAD;
        expected_fd = PI4_VIBE_FD_DOOM1_WAD;
        payload_name = "Doom";
    } else if (slot == PI4_VIBE_PAYLOAD_SLOT1) {
        expected_asset = PI4_USER_FILE_ASSET_PAK0_PAK;
        expected_fd = PI4_VIBE_FD_PAK0_PAK;
        payload_name = "Quake";
    } else {
        fail("unknown Pi payload slot for engine asset VFS read");
    }

    if (!has_field(status, "pi4userfile")) {
        fail("%s payload gameplay proof requires pi4userfile= real asset VFS read evidence",
             payload_name);
    }
    hex64_tuple_exact(status, "pi4userfile", 13, '/', file);
    if (!any_nonzero64(file, ARRAY_LEN(file))) {
        fail("%s payload gameplay proof requires nonzero pi4userfile= real asset VFS read evidence",
             payload_name);
    }
    if ((file[0] & ~PI4_USER_FILE_OP_FULL_MASK) != 0u ||
        (file[0] & PI4_USER_FILE_OP_FULL_MASK) != PI4_USER_FILE_OP_FULL_MASK ||
        file[1] != PI4_USER_FILE_OP_READ) {
        fail("pi4userfile= gameplay proof must include completed open, size, and read operations");
    }
    if (file[2] != slot || file[3] != expected_asset || file[4] != expected_fd) {
        fail("pi4userfile= gameplay proof must read the selected payload's real asset");
    }
    if (file[5] == 0u || file[6] != 0u || file[7] == 0u || file[8] == 0u ||
        file[8] > file[7] || file[10] == 0u || file[11] == 0u || file[12] == 0u) {
        fail("pi4userfile= gameplay proof must show a successful nonzero asset VFS read");
    }
    if (slot == PI4_VIBE_PAYLOAD_SLOT0) {
        if (file[9] != PI4_USER_FILE_MAGIC_IWAD &&
            file[9] != PI4_USER_FILE_MAGIC_PWAD) {
            fail("pi4userfile= Doom gameplay proof must read an IWAD/PWAD asset");
        }
    } else if (file[9] != PI4_USER_FILE_MAGIC_PACK) {
        fail("pi4userfile= Quake gameplay proof must read a PACK asset");
    }
}

static void validate_pi4_block_pio_evidence(const Status *status, const uint64_t *req) {
    uint64_t pio[10];
    uint64_t expected_command = PI4_SDHCI_CMD17_READ_SINGLE;
    uint64_t expected_transfer = PI4_SDHCI_TRANSFER_READ_SINGLE;
    uint64_t byte_address_argument = 0u;
    uint64_t expected_pio_words;

    hex64_tuple_exact(status, "pi4blkpio", 10, '/', pio);
    if (pio[0] == PI4_SDHCI_CMD18_READ_MULTI) {
        expected_command = PI4_SDHCI_CMD18_READ_MULTI;
        expected_transfer = PI4_SDHCI_TRANSFER_READ_MULTI;
    }
    expected_pio_words = req[1] * PI4_SDHCI_PIO_WORDS_PER_SECTOR;
    if (req[0] <= UINT64_MAX / PI4_BLOCK_READ_SECTOR_BYTES) {
        byte_address_argument = req[0] * PI4_BLOCK_READ_SECTOR_BYTES;
    }
    if (pio[0] != expected_command || pio[1] != expected_transfer ||
        (pio[2] != req[0] && pio[2] != byte_address_argument)) {
        fail("pi4blkpio= must prove the SDHCI read command, transfer mode, and LBA argument");
    }
    if (pio[3] != req[4] || pio[4] != req[1] || pio[5] != expected_pio_words ||
        pio[5] > UINT64_MAX / 4u || pio[5] * 4u != pio[3]) {
        fail("pi4blkpio= must prove copied PIO bytes/sectors/words for the whole request");
    }
    if (pio[7] != 0u) {
        fail("pi4blkpio= must not report an SDHCI error status for a completed read");
    }
}

static int validate_pi4_block_read_status(const Status *status) {
    const char *block;
    uint64_t req[6];
    int pending;

    if (!has_field(status, "pi4blk")) {
        if (has_field(status, "pi4blkreq") || has_field(status, "pi4blkpio")) {
            fail("pi4blkreq=/pi4blkpio= require pi4blk= status");
        }
        return 0;
    }

    block = field(status, "pi4blk");
    hex64_tuple_exact(status, "pi4blkreq", 6, '/', req);
    if (req[3] == 0u || req[3] > PI4_BLOCK_READ_MAX_COUNT) {
        fail("pi4blkreq= must publish a bounded block-read max count");
    }
    if (status_word_equals(block, "OK", PI4_STORAGE_STATUS_SD_OK)) {
        if (req[1] == 0u || req[1] > req[3] || req[2] == 0u) {
            fail("pi4blk=OK requires a bounded nonempty block-read request");
        }
        if (req[4] != req[1] * PI4_BLOCK_READ_SECTOR_BYTES) {
            fail("pi4blk=OK byte count must match completed 512-byte sectors");
        }
        if (req[5] != 0u) {
            fail("pi4blk=OK requires a zero block-read result");
        }
        validate_pi4_block_pio_evidence(status, req);
        return 1;
    }

    pending = strcmp(block, "WAIT") == 0 || strcmp(block, "ENOSYS") == 0;
    if (pending) {
        if (req[1] == 0u || req[1] > req[3] || req[2] == 0u) {
            fail("pi4blkreq= must record a bounded nonempty request while pi4blk is pending");
        }
        if (req[4] != req[1] * PI4_BLOCK_READ_SECTOR_BYTES) {
            fail("pi4blkreq= byte count must match requested 512-byte sectors");
        }
    }

    if (strcmp(block, "WAIT") == 0) {
        if (req[5] != PI4_BLOCK_READ_RESULT_WAIT) {
            fail("pi4blk=WAIT requires a wait result");
        }
        return 0;
    }
    if (strcmp(block, "ENOSYS") == 0) {
        if (req[5] != PI4_BLOCK_READ_RESULT_ENOSYS) {
            fail("pi4blk=ENOSYS requires a -ENOSYS result");
        }
        return 0;
    }
    if (strcmp(block, "EINVAL") == 0) {
        if (req[5] != PI4_BLOCK_READ_RESULT_EINVAL) {
            fail("pi4blk=EINVAL requires a -EINVAL result");
        }
        return 0;
    }
    if (strcmp(block, "EIO") == 0) {
        if (req[5] != PI4_BLOCK_READ_RESULT_EIO) {
            fail("pi4blk=EIO requires a -EIO result");
        }
        return 0;
    }

    fail("pi4blk= must be WAIT, ENOSYS, EINVAL, EIO, or OK, got %s", block);
    return 0;
}

static void validate_pi4_sd_controller_status(const Status *status) {
    int has_ctl = has_field(status, "pi4sdctl");
    int has_regs = has_field(status, "pi4sdregs");
    uint64_t regs[12];
    const char *ctl;
    uint64_t expected_legacy = PI4_EMMC2_LEGACY_BASE;
    uint64_t expected_arm = PI4_EMMC2_ARM_BASE;

    if (!has_ctl && !has_regs) {
        return;
    }
    if (!has_ctl || !has_regs) {
        fail("Pi 4 SD controller evidence requires both pi4sdctl= and pi4sdregs=");
    }

    ctl = field(status, "pi4sdctl");
    hex64_tuple_exact(status, "pi4sdregs", 12, '/', regs);
    if (strcmp(ctl, "WAIT") == 0 || strcmp(ctl, "ENOSYS") == 0) {
        if (regs[0] != 0u &&
            !((regs[0] == PI4_EMMC2_LEGACY_BASE && regs[1] == PI4_EMMC2_ARM_BASE &&
               regs[2] >= PI4_EMMC2_MIN_REG_SPAN) ||
              (regs[0] == PI4_EMMC_LEGACY_BASE && regs[1] == PI4_EMMC_ARM_BASE &&
               regs[2] >= PI4_EMMC2_MIN_REG_SPAN))) {
            fail("pi4sdregs= controller constants must identify a BCM2711 SDHCI window");
        }
        if (any_nonzero64(regs + 3, ARRAY_LEN(regs) - 3u)) {
            fail("pi4sdctl=%s must not include nonzero live controller register evidence", ctl);
        }
        return;
    }

    if (strcmp(ctl, "EMMC2") == 0) {
        expected_legacy = PI4_EMMC2_LEGACY_BASE;
        expected_arm = PI4_EMMC2_ARM_BASE;
    } else if (strcmp(ctl, "EMMC") == 0) {
        expected_legacy = PI4_EMMC_LEGACY_BASE;
        expected_arm = PI4_EMMC_ARM_BASE;
    } else {
        fail("pi4sdctl= must be WAIT, ENOSYS, EMMC2, or EMMC, got %s", ctl);
    }
    if (regs[0] != expected_legacy || regs[1] != expected_arm ||
        regs[2] < PI4_EMMC2_MIN_REG_SPAN) {
        fail("pi4sdregs= must identify the selected BCM2711 SDHCI bus/ARM register window");
    }
}

static void validate_pi4_storage_status(const Status *status) {
    const char *sd = field(status, "pi4sd");
    const char *fat = field(status, "pi4fat");
    const char *vfs = field(status, "pi4vfs");
    uint64_t mbr[6];
    uint64_t bpb[9];
    uint64_t root[4];
    int completed_block_read;
    static const char *const all_storage_fields[] = {
        "pi4mbr",
        "pi4bpb",
        "pi4root",
        "pi4kernel8",
        "pi4config",
        "pi4init",
        "pi4abiprobe",
        "pi4payload0",
        "pi4payload1",
        "pi4manifest",
        "pi4assets",
        "pi4wad",
        "pi4pak0",
    };
    static const char *const fat_storage_fields[] = {
        "pi4bpb",
        "pi4root",
        "pi4kernel8",
        "pi4config",
        "pi4init",
        "pi4abiprobe",
        "pi4payload0",
        "pi4payload1",
        "pi4manifest",
        "pi4assets",
        "pi4wad",
        "pi4pak0",
    };

    completed_block_read = validate_pi4_block_read_status(status);
    validate_pi4_sd_controller_status(status);

    if (strcmp(sd, "WAIT") == 0) {
        reject_fields(status, "pi4sd=WAIT", all_storage_fields, ARRAY_LEN(all_storage_fields));
        if (strcmp(fat, "WAIT") != 0 || strcmp(vfs, "WAIT") != 0) {
            fail("pi4sd=WAIT requires pi4fat=WAIT and pi4vfs=WAIT");
        }
        if (completed_block_read) {
            fail("pi4sd=WAIT must not include completed pi4blk=OK media-read evidence");
        }
        return;
    }

    if (strcmp(sd, "OK") != 0) {
        fail("pi4sd= must be WAIT or OK, got %s", sd);
    }
    if (!completed_block_read) {
        fail("pi4sd=OK requires completed pi4blk=/pi4blkpio= media-read evidence");
    }
    validate_pi4_storage_mbr(status, mbr);

    if (strcmp(fat, "WAIT") == 0) {
        reject_fields(status, "pi4fat=WAIT", fat_storage_fields, ARRAY_LEN(fat_storage_fields));
        if (strcmp(vfs, "WAIT") != 0) {
            fail("pi4fat=WAIT requires pi4vfs=WAIT");
        }
        return;
    }

    if (strcmp(fat, "OK") != 0) {
        fail("pi4fat= must be WAIT or OK, got %s", fat);
    }
    validate_pi4_storage_fat_evidence(status, mbr, bpb, root);

    if (strcmp(vfs, "WAIT") == 0) {
        return;
    }
    if (strcmp(vfs, "OK") == 0) {
        validate_pi4_storage_file_evidence(status, mbr, bpb, root, "pi4init");
        validate_pi4_storage_file_evidence(status, mbr, bpb, root, "pi4payload0");
        validate_pi4_storage_file_evidence(status, mbr, bpb, root, "pi4payload1");
        validate_pi4_storage_asset_evidence(status, mbr, bpb, root);
        return;
    }

    fail("pi4vfs= must be WAIT or OK, got %s", vfs);
}

static void validate_pi4_irq_status(const Status *status) {
    const char *irq = field(status, "pi4irq");
    static const char *const timer_irq_fields[] = {
        "irqctl",
        "pi4gic",
        "clocksrc",
        "clockhz",
        "clocktick",
        "clockirq",
        "ticks",
        "dtick",
        "preempt",
        "pirq",
        "pattempt",
        "pskip",
        "puser",
        "pround",
        "pctx",
        "pmask",
        "pfrom",
        "pto",
        "pkind",
        "peip",
        "pcr3",
        "pkstk",
        "pframe",
        "psegs",
        "peflags",
        "pspin",
        "pself",
        "preemptabi",
    };

    if (strcmp(irq, "WAIT") == 0) {
        exact(status, "pi4timer", "WAIT");
        reject_fields(status, "pi4irq=WAIT", timer_irq_fields, ARRAY_LEN(timer_irq_fields));
        return;
    }

    if (strcmp(irq, "OK") == 0) {
        uint64_t pi4gic[4];
        uint64_t clockhz[1];
        uint64_t clocktick[1];
        uint64_t clockirq[1];
        uint64_t ticks[1];

        exact(status, "pi4timer", "OK");
        exact(status, "irqctl", "GIC");
        exact(status, "clocksrc", "ARMTMR");
        hex64_tuple_exact(status, "pi4gic", 4, '/', pi4gic);
        hex64_tuple_exact(status, "clockhz", 1, '/', clockhz);
        hex64_tuple_exact(status, "clocktick", 1, '/', clocktick);
        hex64_tuple_exact(status, "clockirq", 1, '/', clockirq);
        hex64_tuple_exact(status, "ticks", 1, '/', ticks);
        if (pi4gic[0] == 0u || pi4gic[1] == 0u || clockhz[0] == 0u ||
            clocktick[0] == 0u || clockirq[0] == 0u || ticks[0] == 0u) {
            fail("pi4irq=OK must prove nonzero GIC/timer activity");
        }
        if (clockirq[0] != pi4gic[2] || clockirq[0] != pi4gic[3]) {
            fail("pi4gic= IRQ/EOI IDs must match clockirq=");
        }
        return;
    }

    fail("pi4irq= must be WAIT or OK, got %s", irq);
}

static void validate_pi4_preempt_status(const Status *status) {
    const char *preempt_state = field(status, "pi4preempt");
    static const char *const preempt_fields[] = {
        "dtick",
        "preempt",
        "pirq",
        "pattempt",
        "pnone",
        "pskip",
        "puser",
        "pround",
        "pctx",
        "pmask",
        "pfrom",
        "pto",
        "pkind",
        "peip",
        "pcr3",
        "pkstk",
        "pframe",
        "psegs",
        "peflags",
        "pspin",
        "pself",
        "preemptabi",
    };

    if (strcmp(preempt_state, "WAIT") == 0) {
        reject_fields(status, "pi4preempt=WAIT", preempt_fields, ARRAY_LEN(preempt_fields));
        validate_pi4_preempt_context_skeleton(status, 0);
        return;
    }

    if (strcmp(preempt_state, "OK") == 0) {
        uint64_t ticks[1];
        uint64_t preempt[1];
        uint64_t irq_switches[1];
        uint64_t context_switches[1];
        uint64_t from_pid[1];
        uint64_t to_pid[1];

        exact(status, "pi4irq", "OK");
        exact(status, "pi4timer", "OK");
        exact(status, "pi4uabi", "OK");
        exact(status, "pi4mem", "OK");
        exact(status, "pi4runtime", "OK");
        hex64_tuple_exact(status, "ticks", 1, '/', ticks);
        hex64_tuple_exact(status, "preempt", 1, '/', preempt);
        hex64_tuple_exact(status, "pirq", 1, '/', irq_switches);
        hex64_tuple_exact(status, "pctx", 1, '/', context_switches);
        hex64_tuple_exact(status, "pfrom", 1, '/', from_pid);
        hex64_tuple_exact(status, "pto", 1, '/', to_pid);
        if (ticks[0] == 0u) {
            fail("pi4preempt=OK requires nonzero timer ticks");
        }
        if (preempt[0] == 0u || irq_switches[0] == 0u) {
            fail("pi4preempt=OK requires nonzero timer IRQ preempt switches");
        }
        if (irq_switches[0] != preempt[0]) {
            fail("pi4preempt=OK requires pirq= to match preempt=");
        }
        if (context_switches[0] < preempt[0]) {
            fail("pi4preempt=OK requires pctx= context switches to cover preempt=");
        }
        if (from_pid[0] == 0u || to_pid[0] == 0u || from_pid[0] == to_pid[0]) {
            fail("pi4preempt=OK requires a switch between distinct process IDs");
        }
        validate_pi4_preempt_context_skeleton(status, 1);
        return;
    }

    fail("pi4preempt= must be WAIT or OK, got %s", preempt_state);
}

static void validate_pi4_elf_load_metadata(const Status *status, uint64_t entry[1],
                                           uint64_t phdr[3], uint64_t load[6]) {
    hex64_tuple_exact(status, "pi4elfentry", 1, '/', entry);
    hex64_tuple_exact(status, "pi4elfphdr", 3, '/', phdr);
    hex64_tuple_exact(status, "pi4elfload", 6, '/', load);

    if (entry[0] == 0u) {
        fail("pi4elfentry= must expose a nonzero ELF entry point");
    }
    if (phdr[0] == 0u || phdr[1] != PI4_ELF64_PHDR_SIZE || phdr[2] == 0u) {
        fail("pi4elfphdr= must expose PHDR address, ELF64 PHDR size, and count");
    }
    if (load[0] == 0u || load[1] == 0u || load[2] == 0u || load[3] == 0u ||
        load[3] < load[2] || load[4] == 0u || load[5] == 0u) {
        fail("pi4elfload= must expose nonzero load vaddr/paddr/filesz/memsz/flags/align");
    }
    if (load[0] > UINT64_MAX - (load[3] - 1u) ||
        entry[0] < load[0] || entry[0] >= load[0] + load[3]) {
        fail("pi4elfentry= must be inside the recorded load segment");
    }
}

static void validate_pi4_embedded_stack_metadata(const Status *status) {
    uint64_t stack[4];
    uint64_t stackv[4];

    hex64_tuple_exact(status, "pi4estack", 4, '/', stack);
    hex64_tuple_exact(status, "pi4estackv", 4, '/', stackv);
    if (stack[0] == 0u || stack[1] == 0u || stack[2] == 0u || stack[3] == 0u ||
        stack[0] >= stack[1] || stack[2] > stack[1] - stack[0]) {
        fail("pi4estack= must expose the bounded embedded probe stack");
    }
    if (stackv[0] == 0u || stackv[2] == 0u || stackv[3] == 0u ||
        stackv[0] < stack[0] || stackv[0] >= stack[1] ||
        stackv[1] < stack[0] || stackv[1] >= stack[1] ||
        stackv[2] < stack[0] || stackv[2] >= stack[1]) {
        fail("pi4estackv= must expose argv/envp/auxv pointers inside the embedded stack");
    }
}

static void validate_pi4_svc_pointer_status(const Status *status) {
    uint64_t ptr[4];
    uint64_t max_copy = FB_PRESENT_WIDTH * FB_PRESENT_HEIGHT;

    if (!has_field(status, "pi4svcptr")) {
        return;
    }

    hex64_tuple_exact(status, "pi4svcptr", 4, '/', ptr);
    if (ptr[1] > ptr[0]) {
        fail("pi4svcptr= bad pointer checks cannot exceed total pointer checks");
    }
    if (ptr[0] == 0u) {
        if (ptr[1] != 0u || ptr[2] != 0u || ptr[3] != 0u) {
            fail("pi4svcptr= zero checks cannot report bad checks or a last range");
        }
        return;
    }
    if (ptr[3] == 0u) {
        fail("pi4svcptr= nonzero checks must report the last checked byte length");
    }
    if (ptr[1] != 0u && ptr[2] == 0u) {
        fail("pi4svcptr= bad pointer checks must retain the rejected base pointer");
    }

    if (PI4_VIBE_INPUT_EVENT_BYTES > max_copy) {
        max_copy = PI4_VIBE_INPUT_EVENT_BYTES;
    }
    if (PI4_VIBE_INPUT_STATUS_BYTES > max_copy) {
        max_copy = PI4_VIBE_INPUT_STATUS_BYTES;
    }
    if (PI4_VIBE_INPUT_DEVICE_STATUS_BYTES > max_copy) {
        max_copy = PI4_VIBE_INPUT_DEVICE_STATUS_BYTES;
    }
    if (PI4_VIBE_FB_INFO_BYTES > max_copy) {
        max_copy = PI4_VIBE_FB_INFO_BYTES;
    }
    if (PI4_VIBE_PRESENT_INDEXED_BYTES > max_copy) {
        max_copy = PI4_VIBE_PRESENT_INDEXED_BYTES;
    }
    if (PI4_VIBE_FB_RGB24_PALETTE_BYTES > max_copy) {
        max_copy = PI4_VIBE_FB_RGB24_PALETTE_BYTES;
    }
    if (PI4_VIBE_EXEC_REQUEST_BYTES > max_copy) {
        max_copy = PI4_VIBE_EXEC_REQUEST_BYTES;
    }
    if (PI4_VIBE_EXEC_REQUEST_PATH_MAX_BYTES > max_copy) {
        max_copy = PI4_VIBE_EXEC_REQUEST_PATH_MAX_BYTES;
    }
    if (ptr[3] > max_copy) {
        fail("pi4svcptr= last checked byte length exceeds known Pi syscall copy sizes");
    }
}

static void validate_pi4_uabi_status(const Status *status) {
    const char *uabi = field(status, "pi4uabi");
    static const char *const process_fields[] = {
        "exec",
        "path",
        "uexec",
        "upath",
        "uentry",
        "execsys",
        "pi4ustack",
        "pi4ustackv",
        "execmap",
        "pstat",
        "procpool",
        "pidseq",
    };

    if (strcmp(uabi, "WAIT") == 0) {
        uint64_t entry[1];
        uint64_t phdr[3];
        uint64_t load[6];
        uint64_t probe[4];

        reject_fields(status, "pi4uabi=WAIT", process_fields, ARRAY_LEN(process_fields));
        exact(status, "pi4elf", "OK");
        exact(status, "pi4elfsrc", "EMBEDDED");
        hex64_tuple_exact(status, "pi4elfprobe", 4, '/', probe);
        validate_pi4_elf_load_metadata(status, entry, phdr, load);
        validate_pi4_embedded_stack_metadata(status);
        if (probe[0] == 0u || probe[1] != entry[0] || probe[2] != phdr[0] ||
            probe[3] == 0u) {
            fail("pi4elfprobe= must remain embedded-probe evidence separate from ELF load metadata");
        }
        return;
    }

    if (strcmp(uabi, "OK") == 0) {
        const char *elfsrc;
        uint64_t elfentry[1];
        uint64_t elfphdr[3];
        uint64_t elfload[6];
        uint64_t uentry[1];
        uint64_t execsys[2];
        uint64_t execmap[3];
        uint64_t ptable[4];
        uint64_t pstat[MAX_HEX64_TUPLE_FIELDS];
        uint64_t procpool[MAX_HEX64_TUPLE_FIELDS];
        uint64_t pidseq[MAX_HEX64_TUPLE_FIELDS];
        uint64_t pi4ustack[4];
        uint64_t pi4ustackv[4];
        const char *path;
        const char *upath;
        size_t pstat_count;
        size_t procpool_count;
        size_t pidseq_count;

        exact(status, "pi4svc", "OK");
        exact(status, "pi4elf", "OK");
        elfsrc = field(status, "pi4elfsrc");
        if (strcmp(elfsrc, "EMBEDDED") == 0) {
            fail("pi4uabi=OK must not rely on boot-embedded pi4elfsrc=EMBEDDED evidence");
        }
        if (strcmp(elfsrc, "VFS") != 0) {
            fail("pi4uabi=OK requires non-embedded pi4elfsrc=VFS INIT.ELF evidence");
        }
        exact(status, "exec", "OK");
        path = field(status, "path");
        if (!is_pi4_user_exec_path(path)) {
            fail("path= must be INIT.ELF, PAYLOAD0.ELF, or PAYLOAD1.ELF for pi4uabi=OK");
        }
        exact(status, "uexec", "OK");
        upath = field(status, "upath");
        if (strcmp(upath, path) != 0) {
            fail("upath= must match path= for pi4uabi=OK");
        }
        validate_pi4_elf_load_metadata(status, elfentry, elfphdr, elfload);
        hex64_tuple_exact(status, "uentry", 1, '/', uentry);
        hex64_tuple_exact(status, "execsys", 2, '/', execsys);
        hex64_tuple_exact(status, "pi4ustack", 4, '/', pi4ustack);
        if (has_field(status, "pi4ustackv")) {
            hex64_tuple_exact(status, "pi4ustackv", 4, '/', pi4ustackv);
        }
        hex64_tuple_exact(status, "execmap", 3, '/', execmap);
        validate_pi4_process_table_skeleton(status, ptable);
        pstat_count = hex64_tuple_fields(status, "pstat", '/', pstat, ARRAY_LEN(pstat));
        procpool_count = hex64_tuple_fields(status, "procpool", '/', procpool,
                                            ARRAY_LEN(procpool));
        pidseq_count = hex64_tuple_fields(status, "pidseq", '/', pidseq, ARRAY_LEN(pidseq));
        if (uentry[0] == 0u) {
            fail("uentry= must prove a nonzero INIT.ELF entry point for pi4uabi=OK");
        }
        if (uentry[0] != elfentry[0]) {
            fail("uentry= must match validated pi4elfentry= INIT.ELF metadata");
        }
        if (execsys[0] == 0u || execsys[1] == 0u) {
            fail("execsys= must prove nonzero Pi syscall dispatch and return counters");
        }
        if (pi4ustack[0] == 0u || pi4ustack[1] == 0u || pi4ustack[2] == 0u ||
            pi4ustack[0] >= pi4ustack[1] || pi4ustack[2] > pi4ustack[1] - pi4ustack[0]) {
            fail("pi4ustack= must prove a bounded nonzero INIT.ELF user stack");
        }
        if (has_field(status, "pi4ustackv") &&
            (pi4ustackv[0] == 0u || pi4ustackv[2] == 0u ||
             pi4ustackv[3] != PI4_VIBE_USER_START_REQUIRED_FLAGS ||
             pi4ustackv[0] < pi4ustack[0] || pi4ustackv[0] >= pi4ustack[1] ||
             pi4ustackv[1] < pi4ustack[0] || pi4ustackv[1] >= pi4ustack[1] ||
             pi4ustackv[2] < pi4ustack[0] || pi4ustackv[2] >= pi4ustack[1])) {
            fail("pi4ustackv= must prove argv/envp/auxv pointers inside the active user stack");
        }
        if (execmap[0] == 0u || execmap[1] == 0u || execmap[2] == 0u) {
            fail("execmap= must prove nonzero INIT.ELF mapping address, size, and flags");
        }
        if (elfload[0] < execmap[0] || elfload[0] - execmap[0] > execmap[1] ||
            elfload[3] > execmap[1] - (elfload[0] - execmap[0])) {
            fail("execmap= must cover the validated INIT.ELF load segment");
        }
        if (ptable[3] == 0u) {
            fail("pi4ptable= must record at least one live table entry for pi4uabi=OK");
        }
        if (pstat_count < 3u || pstat[0] == 0u || pstat[1] == 0u) {
            fail("pstat= must expose Pi process status counters");
        }
        if (procpool_count < 2u || procpool[0] == 0u || procpool[1] == 0u ||
            procpool[0] != ptable[3] || procpool[1] != ptable[1]) {
            fail("procpool= must match the nonzero Pi process table usage/capacity");
        }
        if (pidseq_count < 2u || pidseq[0] == 0u || pidseq[1] <= pidseq[0]) {
            fail("pidseq= must expose a nonzero increasing Pi process id sequence");
        }
        if (pstat_count >= 6u) {
            if (pstat[2] != procpool[0] || pstat[0] != pidseq[0] ||
                pstat[1] != pidseq[1]) {
                fail("extended pstat= must match procpool= and pidseq= lifecycle counters");
            }
            if (pstat[3] == 0u || pstat[4] > pstat[3] || pstat[5] > pstat[3]) {
                fail("extended pstat= must bound EL0 launch, return, and exec-launch counts");
            }
            if (has_field(status, "pi4exec")) {
                const char *pi4exec = field(status, "pi4exec");

                if (strcmp(pi4exec, "WAIT") == 0 && pstat[5] != 0u) {
                    fail("pi4exec=WAIT must not claim a payload process launch in pstat=");
                }
                if (strcmp(pi4exec, "OK") == 0 && (pstat[5] == 0u || ptable[3] < 2u)) {
                    fail("pi4exec=OK requires payload PID allocation in pstat=/pi4ptable=");
                }
            }
        }
        if (has_field(status, "pi4elfprobe")) {
            hex_like_tuple(status, "pi4elfprobe", 4, '/');
        }
        exact(status, "panic", "NONE");
        exact(status, "shutdown", "NONE");
        return;
    }

    fail("pi4uabi= must be WAIT or OK, got %s", uabi);
}

static void validate_pi4_exec_status(const Status *status) {
    const char *exec;
    uint64_t request[6];
    uint64_t payload_request[6];

    if (!has_field(status, "pi4exec")) {
        if (has_field(status, "pi4execreq")) {
            fail("pi4execreq= requires pi4exec= state evidence");
        }
        if (has_field(status, "pi4payloadreq")) {
            fail("pi4payloadreq= requires pi4exec= state evidence");
        }
        if (field_equals(status, "doom", "OK") || field_equals(status, "quake", "OK")) {
            fail("Pi Doom/Quake proof requires pi4exec=OK launch evidence");
        }
        return;
    }

    exec = field(status, "pi4exec");
    hex64_tuple_exact(status, "pi4execreq", 6, '/', request);

    if (strcmp(exec, "WAIT") == 0) {
        if (request[5] != 0u) {
            if (request[0] != PI4_VIBE_SYS_EXEC) {
                fail("pi4execreq= must record the Pi exec syscall number");
            }
            if (request[1] == 0u) {
                fail("pi4exec=WAIT request evidence must include the exec request pointer");
            }
            if (request[4] != neg_errno64(PI4_VIBE_ENOSYS)) {
                fail("pi4exec=WAIT request evidence must return ENOSYS until the Pi loader exists");
            }
            hex64_tuple_exact(status, "pi4payloadreq", 6, '/', payload_request);
            if (payload_request[0] != request[1]) {
                fail("pi4payloadreq= request pointer must match pi4execreq=");
            }
            if (payload_request[1] != PI4_VIBE_EXEC_REQUEST_ABI_VERSION ||
                payload_request[2] != PI4_VIBE_EXEC_REQUEST_BYTES) {
                fail("pi4payloadreq= must record the exec request ABI version and byte size");
            }
            if (payload_request[3] != PI4_VIBE_PAYLOAD_SLOT0 &&
                payload_request[3] != PI4_VIBE_PAYLOAD_SLOT1) {
                fail("pi4payloadreq= slot must be PAYLOAD0 or PAYLOAD1");
            }
            if (payload_request[4] == 0u) {
                fail("pi4payloadreq= must record the requested payload path pointer");
            }
            if (payload_request[5] != payload_request[3]) {
                fail("pi4payloadreq= matched slot must confirm path and slot agree");
            }
        }
        if (field_equals(status, "doom", "OK") || field_equals(status, "quake", "OK")) {
            fail("pi4exec=WAIT cannot prove Doom or Quake gameplay launch");
        }
        if (field_equals(status, "path", "PAYLOAD0.ELF") ||
            field_equals(status, "path", "PAYLOAD1.ELF")) {
            fail("pi4exec=WAIT cannot claim payload exec path success");
        }
        return;
    }

    if (strcmp(exec, "OK") == 0) {
        if (request[0] != PI4_VIBE_SYS_EXEC || request[5] == 0u || request[4] != 0u) {
            fail("pi4exec=OK must prove a successful Pi exec syscall request");
        }
        exact(status, "pi4uabi", "OK");
        exact(status, "pi4runtime", "OK");
        exact(status, "pi4mem", "OK");
        validate_pi4_payload_vfs_evidence(status);
        exact(status, "panic", "NONE");
        exact(status, "shutdown", "NONE");
        return;
    }

    fail("pi4exec= must be WAIT or OK, got %s", exec);
}

static void validate_pi4_payload_launch_claim(const Status *status) {
    if (!has_field(status, "payload_launch_claim")) {
        return;
    }
    if (!field_equals(status, "payload_launch_claim", "none")) {
        fail("payload_launch_claim= must remain none until Pi payload exec proof exists");
    }
}

static void validate_pi4_memory_status(const Status *status) {
    const char *mem = field(status, "pi4mem");
    uint64_t kmap[4];
    uint64_t stack[4];
    uint64_t umem[4];
    uint64_t fbmap[4];
    uint64_t ptable[4];
    int allocator_ready = 0;

    hex64_tuple_exact(status, "pi4kmap", 4, '/', kmap);
    hex64_tuple_exact(status, "pi4stack", 4, '/', stack);
    hex64_tuple_exact(status, "pi4umem", 4, '/', umem);
    hex64_tuple_exact(status, "pi4fbmap", 4, '/', fbmap);
    validate_pi4_process_table_skeleton(status, ptable);

    if (kmap[0] != PI4_KERNEL8_LOAD_ADDR || kmap[1] <= kmap[0]) {
        fail("pi4kmap= must expose the kernel8 load base and a nonempty kernel image range");
    }
    if (kmap[2] < kmap[0] || kmap[3] <= kmap[2] || kmap[3] > kmap[1]) {
        fail("pi4kmap= must include a bounded guest status block inside the kernel image");
    }
    if (stack[0] == 0u || stack[1] <= stack[0] || stack[2] < stack[1] ||
        stack[3] <= stack[2] ||
        stack[1] - stack[0] < PI4_MIN_STACK_BYTES ||
        stack[3] - stack[2] < PI4_MIN_STACK_BYTES ||
        stack[1] - stack[0] > PI4_MAX_STACK_BYTES ||
        stack[3] - stack[2] > PI4_MAX_STACK_BYTES) {
        fail("pi4stack= must expose bounded boot and EL0 probe stack ranges");
    }
    if (umem[0] == 0u || umem[1] <= umem[0] || umem[2] < umem[0] ||
        umem[2] >= umem[1] || umem[3] == 0u || umem[3] > umem[1] - umem[0]) {
        fail("pi4umem= must expose a bounded embedded EL0 probe image range");
    }
    if (has_field(status, "pi4ualloc")) {
        uint64_t ualloc[8];
        uint64_t image_bytes;
        uint64_t stack_bytes;

        hex64_tuple_exact(status, "pi4ualloc", 8, '/', ualloc);
        if (ualloc[0] == 0u || ualloc[1] <= ualloc[0] ||
            ualloc[2] == 0u || ualloc[2] != ualloc[1] - ualloc[0] ||
            ualloc[3] == 0u || ualloc[4] <= ualloc[3] ||
            ualloc[5] == 0u || ualloc[5] != ualloc[4] - ualloc[3] ||
            ualloc[6] != PI4_EL0_ALLOC_REQUIRED_FLAGS ||
            ualloc[7] != PI4_EL0_ALLOC_BOOT_COUNT) {
            fail("pi4ualloc= must expose bounded EL0 image and stack allocator evidence");
        }
        image_bytes = umem[1] - umem[0];
        stack_bytes = stack[3] - stack[2];
        if (umem[0] < ualloc[0] || umem[1] > ualloc[1] ||
            umem[2] < ualloc[0] || umem[2] >= ualloc[1] ||
            umem[3] > ualloc[2] || image_bytes > ualloc[2]) {
            fail("pi4ualloc= image allocation must bound pi4umem=");
        }
        if (ualloc[3] != stack[2] || ualloc[4] != stack[3] ||
            ualloc[5] != stack_bytes) {
            fail("pi4ualloc= stack allocation must match the EL0 stack in pi4stack=");
        }
        allocator_ready = 1;
    }
    if (field_equals(status, "pi4fb", "OK")) {
        if (fbmap[0] == 0u || fbmap[1] == 0u || fbmap[2] == 0u || fbmap[3] == 0u) {
            fail("pi4fbmap= must expose framebuffer base, byte size, pitch, and depth when pi4fb=OK");
        }
    } else if (any_nonzero64(fbmap, ARRAY_LEN(fbmap)) &&
               !field_equals(status, "pi4mailbox", "OK")) {
        fail("pi4fbmap= may only expose nonzero framebuffer ranges after mailbox evidence");
    }

    if (strcmp(mem, "WAIT") == 0) {
        if (field_equals(status, "pi4uabi", "OK") || field_equals(status, "pi4runtime", "OK")) {
            fail("pi4mem=WAIT cannot accompany pi4uabi=OK or pi4runtime=OK process claims");
        }
        if (allocator_ready && ptable[3] != 0u) {
            fail("pi4mem=WAIT cannot hide complete Pi allocator/process table evidence");
        }
        return;
    }

    if (strcmp(mem, "OK") == 0) {
        if (!allocator_ready) {
            fail("pi4mem=OK requires pi4ualloc= allocator evidence");
        }
        if (ptable[2] != PI4_PROC_TABLE_ENTRY_BYTES || ptable[3] == 0u) {
            fail("pi4mem=OK requires a live Pi process table entry");
        }
        exact(status, "panic", "NONE");
        exact(status, "shutdown", "NONE");
        return;
    }

    fail("pi4mem= must be WAIT or OK, got %s", mem);
}

static void validate_pi4_runtime_status(const Status *status) {
    const char *runtime = field(status, "pi4runtime");

    if (strcmp(runtime, "WAIT") == 0) {
        return;
    }

    if (strcmp(runtime, "OK") == 0) {
        exact(status, "pi4uabi", "OK");
        exact(status, "pi4mem", "OK");
        exact(status, "panic", "NONE");
        exact(status, "shutdown", "NONE");
        return;
    }

    fail("pi4runtime= must be WAIT or OK, got %s", runtime);
}

static void validate_pi4_framebuffer_status(const Status *status) {
    const char *fb_state = field(status, "pi4fb");
    static const char *const framebuffer_fields[] = {
        "gfx",
        "fb",
        "fbdev",
        "fbmmio",
        "fbgeom",
        "fbdirty",
        "fbcap",
        "fbpresent",
        "fbabi",
    };

    if (strcmp(fb_state, "WAIT") == 0) {
        reject_fields(status, "pi4fb=WAIT", framebuffer_fields, ARRAY_LEN(framebuffer_fields));
        if (has_field(status, "pi4fbmail") && !field_equals(status, "pi4mailbox", "OK")) {
            fail("pi4fb=WAIT may only include pi4fbmail= when pi4mailbox=OK");
        }
        return;
    }

    if (strcmp(fb_state, "OK") == 0) {
        uint64_t fbmail[4];
        uint64_t geom[4];
        uint64_t present[4];
        uint64_t dirty[5];
        uint64_t bytes_per_pixel;

        exact(status, "pi4mailbox", "OK");
        exact(status, "gfx", "OK");
        exact(status, "fb", "PI4FB");
        hex64_tuple_exact(status, "pi4fbmail", 4, '/', fbmail);
        hex64_tuple_exact(status, "fbgeom", 4, '/', geom);
        hex64_tuple_exact(status, "fbpresent", 4, '/', present);
        hex64_tuple_exact(status, "fbdirty", 5, '/', dirty);
        if (fbmail[0] == 0u || fbmail[1] == 0u || fbmail[2] == 0u) {
            fail("pi4fbmail= must prove a mailbox request, framebuffer base, and pitch");
        }
        if (geom[0] == 0u || geom[1] == 0u || geom[2] == 0u ||
            (geom[3] != 16u && geom[3] != 24u && geom[3] != 32u)) {
            fail("fbgeom= must expose nonzero Pi framebuffer geometry and 16/24/32 bpp");
        }
        bytes_per_pixel = (geom[3] + 7u) / 8u;
        if (geom[2] < geom[0] * bytes_per_pixel || fbmail[2] != geom[2]) {
            fail("fbgeom=/pi4fbmail= pitch must cover the reported width and agree");
        }
        if (present[0] == 0u || present[1] == 0u ||
            (present[2] == 0u && present[3] == 0u)) {
            fail("fbpresent= must prove a rendered nonzero framebuffer write and sample");
        }
        if (dirty[0] > FB_PRESENT_WIDTH || dirty[1] > FB_PRESENT_HEIGHT ||
            dirty[2] > FB_PRESENT_WIDTH - dirty[0] ||
            dirty[3] > FB_PRESENT_HEIGHT - dirty[1] || dirty[4] == 0u) {
            fail("fbdirty= must prove a bounded nonzero indexed source dirty rect");
        }
        if (has_field(status, "fbabi")) {
            uint64_t fbabi[4];
            hex64_tuple_exact(status, "fbabi", 4, '/', fbabi);
            if (fbabi[0] == 0u || fbabi[1] == 0u || fbabi[2] == 0u) {
                fail("fbabi= must prove framebuffer surface, dirty, and present paths");
            }
        }
        return;
    }

    fail("pi4fb= must be WAIT or OK, got %s", fb_state);
}

static void validate_pi4_status(const Status *status, const CheckOptions *opts) {
    exact(status, "arch", "AARCH64");
    exact(status, "machine", "PI4");
    exact(status, "image", "PI4");
    if (!opts->pi4_local_qemu && status_has_local_qemu_metadata(status)) {
        fail("local QEMU smoke metadata cannot satisfy Pi 4 green gates");
    }
    validate_pi4_panic_fault_status(status);
    exact(status, "artifact", "OK");
    exact(status, "pi4boot", "OK");
    exact(status, "pi4uart", "OK");
    validate_pi4_input_status(status);
    validate_pi4_audio_status(status);
    if (opts->pi4_local_qemu && field_equals(status, "pi4audio", "OK")) {
        fail("local QEMU status must keep pi4audio=WAIT or HARDWARE-UNPROVEN; pi4audio=OK requires real Pi hardware evidence");
    }
    hex_like_tuple(status, "pi4entry", 4, '/');

    exact(status, "pi4el", "EL1");
    if (opts->pi4_local_qemu) {
        exact(status, "pi4dtb", "BAD");
        hex_like_tuple(status, "pi4dtbroot", 4, '/');
        exact(status, "pi4boarddtb", "WAIT");
        hex_like_tuple(status, "pi4model", 3, '/');
        hex_like_tuple(status, "pi4compat", 3, '/');
        exact(status, "pi4soc", "WAIT");
        exact(status, "pi4socdtb", "WAIT");
        hex_like_tuple(status, "pi4socrange", 4, '/');
        hex_like_tuple(status, "pi4socrangelen", 1, '/');
    } else {
        exact(status, "pi4dtb", "OK");
        hex_like_tuple(status, "pi4dtbroot", 4, '/');
        exact(status, "pi4boarddtb", "OK");
        hex_like_tuple(status, "pi4model", 3, '/');
        hex_like_tuple(status, "pi4compat", 3, '/');
        exact(status, "pi4soc", "WAIT");
        exact(status, "pi4socdtb", "OK");
        hex_like_tuple(status, "pi4socrange", 4, '/');
        hex_like_tuple(status, "pi4socrangelen", 1, '/');
    }
    hex_like_tuple(status, "pi4currentel", 1, '/');

    if (opts->pi4_local_qemu) {
        exact(status, "pi4gicdtb", "WAIT");
        hex_like_tuple(status, "pi4gicnode", 1, '/');
        hex_like_tuple(status, "pi4giccompat", 3, '/');
        hex_like_tuple(status, "pi4gicreg", 8, '/');
        hex_like_tuple(status, "pi4gicreglen", 1, '/');
    } else {
        exact(status, "pi4gicdtb", "OK");
        hex_like_tuple(status, "pi4gicnode", 1, '/');
        hex_like_tuple(status, "pi4giccompat", 3, '/');
        hex_like_tuple(status, "pi4gicreg", 8, '/');
        hex_like_tuple(status, "pi4gicreglen", 1, '/');
    }
    exact(status, "pi4gicmmio", "OK");
    hex_like_tuple(status, "pi4gicbase", 4, '/');
    exact(status, "pi4giccfg", "OK");
    hex_like_tuple(status, "pi4gicctl", 4, '/');
    hex_like_tuple(status, "pi4giciidr", 2, '/');
    validate_pi4_irq_status(status);
    validate_pi4_preempt_status(status);

    exact(status, "pi4vec", "OK");
    hex_like_tuple(status, "pi4vbar", 4, '/');
    exact(status, "pi4svc", "OK");
    hex_like_tuple(status, "pi4sysframe", 4, '/');
    validate_pi4_svc_pointer_status(status);
    validate_pi4_uabi_status(status);
    validate_pi4_exec_status(status);
    validate_pi4_user_file_status(status);
    validate_pi4_payload_launch_claim(status);

    validate_pi4_mailbox_status(status);
    validate_pi4_framebuffer_status(status);
    validate_pi4_storage_status(status);
    validate_pi4_memory_status(status);
    validate_pi4_runtime_status(status);
    exact(status, "panic", "NONE");
    exact(status, "shutdown", "NONE");
}

static void validate_pi4_final_gate_asset_tuple(const Status *status, const char *name) {
    uint64_t file[8];
    size_t i;

    hex64_tuple_exact(status, name, 8, '/', file);
    for (i = 0; i < ARRAY_LEN(file); i++) {
        if (file[i] == 0u) {
            fail("%s= final gate asset tuple must be complete and nonzero", name);
        }
    }
}

static void validate_status_file(const char *path, const CheckOptions *opts) {
    Status status;

    current_context = path;
    parse_status(&status, path);
    if (has_field(&status, "arch") || has_field(&status, "machine")) {
        validate_pi4_status(&status, opts);
        free(status.text);
        return;
    }
    exact(&status, "pg", "ON");
    exact(&status, "pmm", "OK");
    exact(&status, "e820", "OK");
    exact(&status, "vmm", "OK");
    validate_clock(&status);
    validate_kernel_relocation(&status);
    if (opts->require_exec) {
        validate_exec(&status);
    }
    if (opts->require_preempt) {
        validate_preemption(&status);
    }
    if (opts->require_vfs_abi) {
        validate_vfs_abi(&status);
    }
    if (opts->require_device_abi) {
        validate_device_status(&status);
    }
    free(status.text);
}

static const char *pi4_payload_path_for_slot(uint64_t slot) {
    if (slot == PI4_VIBE_PAYLOAD_SLOT0) {
        return "PAYLOAD0.ELF";
    }
    if (slot == PI4_VIBE_PAYLOAD_SLOT1) {
        return "PAYLOAD1.ELF";
    }
    (void)slot;
    fail("unknown Pi payload slot");
    return "";
}

static int is_pi4_payload_capture_candidate(const Status *status, uint64_t slot) {
    return field_equals(status, "pi4exec", "OK") &&
           field_equals(status, "path", pi4_payload_path_for_slot(slot));
}

static void validate_pi4_local_payload_capture(const Status *status, uint64_t slot) {
    uint64_t execreq[6];
    uint64_t payloadvfs[10];
    uint64_t present[4];
    uint64_t change[4];
    uint64_t events[PI4_UART_INPUT_EVENT_COUNTER_FIELDS];
    const char *path = pi4_payload_path_for_slot(slot);

    exact(status, "pi4exec", "OK");
    exact(status, "path", path);
    exact(status, "upath", path);
    hex64_tuple_exact(status, "pi4execreq", 6, '/', execreq);
    if (execreq[0] != PI4_VIBE_SYS_EXEC || execreq[4] != 0u || execreq[5] == 0u) {
        fail("pi4execreq= must prove a successful captured Pi payload exec syscall");
    }
    hex64_tuple_exact(status, "pi4payloadvfs", 10, '/', payloadvfs);
    if (payloadvfs[0] != slot || payloadvfs[1] != PI4_STORAGE_FILE_STATUS_OK) {
        fail("pi4payloadvfs= must prove the selected Pi payload ELF was read from VFS");
    }
    if (payloadvfs[2] == 0u || payloadvfs[3] == 0u || payloadvfs[4] == 0u ||
        payloadvfs[5] == 0u || payloadvfs[6] == 0u || payloadvfs[7] == 0u ||
        payloadvfs[8] == 0u || payloadvfs[9] == 0u) {
        fail("pi4payloadvfs= must carry the selected Pi payload full-file read tuple");
    }
    validate_pi4_engine_asset_vfs_read(status, slot);
    exact(status, "pi4uabi", "OK");
    exact(status, "pi4runtime", "OK");
    exact(status, "pi4mem", "OK");
    exact(status, "pi4preempt", "OK");
    validate_pi4_uabi_status(status);
    validate_pi4_memory_status(status);
    validate_pi4_runtime_status(status);
    validate_pi4_preempt_status(status);

    exact(status, "pi4fb", "OK");
    hex64_tuple_exact(status, "fbpresent", 4, '/', present);
    hex64_tuple_exact(status, "fbchange", 4, '/', change);
    if (present[0] < 2u || present[1] == 0u ||
        (present[2] == 0u && present[3] == 0u)) {
        fail("fbpresent= must prove a captured rendered frame after Pi payload launch");
    }
    if (change[1] == 0u || change[0] == change[1] || change[2] == 0u || change[3] == 0u) {
        fail("fbchange= must prove rendered-frame progress after Pi payload launch");
    }

    hex64_tuple_exact(status, "pi4inputevt", PI4_UART_INPUT_EVENT_COUNTER_FIELDS, '/', events);
    if (events[PI4_UART_INPUT_EVENT_LAUNCH_CLICK_INDEX] == 0u) {
        fail("pi4inputevt= must prove mouse/click launcher activation before payload gameplay");
    }
    if (slot == PI4_VIBE_PAYLOAD_SLOT0) {
        if (events[PI4_UART_INPUT_EVENT_DOOM_SELECT_INDEX] == 0u ||
            events[PI4_UART_INPUT_EVENT_DOOM_GAMEPLAY_INDEX] == 0u) {
            fail("pi4inputevt= must prove Doom launcher selection and gameplay input progress");
        }
    } else if (slot == PI4_VIBE_PAYLOAD_SLOT1) {
        if (events[PI4_UART_INPUT_EVENT_QUAKE_SELECT_INDEX] == 0u ||
            events[PI4_UART_INPUT_EVENT_QUAKE_GAMEPLAY_INDEX] == 0u) {
            fail("pi4inputevt= must prove Quake launcher selection and gameplay input progress");
        }
    } else {
        fail("unknown Pi payload slot for local capture");
    }
    exact(status, "panic", "NONE");
    exact(status, "shutdown", "NONE");
}

static const char *framebuffer_gate_hash(const Status *gates, const char *name) {
    const char *value = field(gates, name);

    if (!is_hex_string_len(value, 16u)) {
        fail("%s= must be a 16-hex-digit framebuffer artifact hash", name);
    }
    return value;
}

static void validate_pi4_local_framebuffer_artifact_gate(const Status *gates) {
    const char *doom_frame0;
    const char *doom_frame1;
    const char *quake_frame0;
    const char *quake_frame1;

    exact(gates, "framebuffer_artifact", "green");
    exact(gates, "framebuffer_artifact_source", "qemu-screendump");
    exact(gates, "doom_framebuffer_artifact", "green");
    exact(gates, "quake_framebuffer_artifact", "green");
    (void)field(gates, "doom_framebuffer_report");
    (void)field(gates, "quake_framebuffer_report");
    doom_frame0 = framebuffer_gate_hash(gates, "doom_framebuffer_frame0_hash");
    doom_frame1 = framebuffer_gate_hash(gates, "doom_framebuffer_frame1_hash");
    quake_frame0 = framebuffer_gate_hash(gates, "quake_framebuffer_frame0_hash");
    quake_frame1 = framebuffer_gate_hash(gates, "quake_framebuffer_frame1_hash");
    if (strcmp(doom_frame0, doom_frame1) == 0) {
        fail("Doom framebuffer artifact hashes must prove changed frames");
    }
    if (strcmp(quake_frame0, quake_frame1) == 0) {
        fail("Quake framebuffer artifact hashes must prove changed frames");
    }
}

static void validate_pi4_final_gates(const char *gate_path, int status_count,
                                     char **status_paths) {
    Status gates;
    const char *storage_gate;
    const char *audio_gate;
    const char *hardware_gate;
    const char *hardware_proof_gate;
    int require_process_green;
    int require_memory_green;
    int require_preemption_green;
    int require_doom_payload;
    int require_quake_payload;
    int require_pak0;
    int saw_storage_ok = 0;
    int saw_pi4wad = 0;
    int saw_pi4pak0 = 0;
    int saw_audio_ok = 0;
    int saw_audio_wait = 0;
    int saw_audio_hardware_unproven = 0;
    int saw_process_ok = 0;
    int saw_memory_ok = 0;
    int saw_preemption_ok = 0;
    int saw_local_qemu = 0;
    int saw_local_audio_ok = 0;
    int local_payload_gates;
    uint32_t local_payload_mask = 0u;
    int i;

    current_context = gate_path;
    parse_status(&gates, gate_path);
    storage_gate = field(&gates, "storage");
    audio_gate = field(&gates, "audio");
    hardware_gate = field(&gates, "hardware");
    hardware_proof_gate = field(&gates, "hardware_proof");
    require_process_green = field_equals(&gates, "process", "green");
    require_memory_green = field_equals(&gates, "memory", "green");
    require_preemption_green = field_equals(&gates, "preemption", "green");
    require_doom_payload = field_equals(&gates, "launcher_doom_exec", "green");
    require_quake_payload = field_equals(&gates, "launcher_quake_exec", "green");
    local_payload_gates = field_equals(&gates, "evidence_class", "local-qemu-final-gates");
    require_pak0 =
        field_equals(&gates, "storage_assets", "real-wad-and-pak") ||
        (has_field(&gates, "storage_status_fields") &&
         strstr(field(&gates, "storage_status_fields"), "pi4pak0") != NULL);

    for (i = 0; i < status_count; i++) {
        Status status;
        const char *audio;
        int status_local_qemu;

        current_context = status_paths[i];
        parse_status(&status, status_paths[i]);
        status_local_qemu = status_has_local_qemu_metadata(&status);
        exact(&status, "arch", "AARCH64");
        exact(&status, "machine", "PI4");
        exact(&status, "image", "PI4");
        validate_pi4_audio_status(&status);
        validate_pi4_storage_status(&status);
        if (strcmp(storage_gate, "green") == 0) {
            exact(&status, "pi4sd", "OK");
            exact(&status, "pi4fat", "OK");
            exact(&status, "pi4vfs", "OK");
            validate_pi4_final_gate_asset_tuple(&status, "pi4wad");
            saw_storage_ok = 1;
            saw_pi4wad = 1;
            if (require_pak0) {
                validate_pi4_final_gate_asset_tuple(&status, "pi4pak0");
                saw_pi4pak0 = 1;
            }
        }
        audio = field(&status, "pi4audio");
        if (strcmp(audio, "OK") == 0) {
            saw_audio_ok = 1;
            if (local_payload_gates || status_local_qemu) {
                saw_local_audio_ok = 1;
            }
        } else if (strcmp(audio, "WAIT") == 0) {
            saw_audio_wait = 1;
        } else if (strcmp(audio, "HARDWARE-UNPROVEN") == 0) {
            saw_audio_hardware_unproven = 1;
        } else {
            fail("pi4audio= must be WAIT, HARDWARE-UNPROVEN, or OK, got %s",
                 audio);
        }
        if (require_process_green &&
            field_equals(&status, "pi4uabi", "OK") &&
            field_equals(&status, "pi4runtime", "OK")) {
            validate_pi4_uabi_status(&status);
            validate_pi4_runtime_status(&status);
            saw_process_ok = 1;
        }
        if (require_memory_green && field_equals(&status, "pi4mem", "OK")) {
            validate_pi4_memory_status(&status);
            saw_memory_ok = 1;
        }
        if (require_preemption_green && field_equals(&status, "pi4preempt", "OK")) {
            validate_pi4_preempt_status(&status);
            saw_preemption_ok = 1;
        }
        if (status_local_qemu) {
            saw_local_qemu = 1;
        }
        if (local_payload_gates || status_local_qemu) {
            if (is_pi4_payload_capture_candidate(&status, PI4_VIBE_PAYLOAD_SLOT0)) {
                validate_pi4_local_payload_capture(&status, PI4_VIBE_PAYLOAD_SLOT0);
                local_payload_mask |= 0x1u;
            }
            if (is_pi4_payload_capture_candidate(&status, PI4_VIBE_PAYLOAD_SLOT1)) {
                validate_pi4_local_payload_capture(&status, PI4_VIBE_PAYLOAD_SLOT1);
                local_payload_mask |= 0x2u;
            }
        }
        free(status.text);
    }

    current_context = gate_path;
    if (local_payload_gates || saw_local_qemu) {
        if (strcmp(hardware_gate, "unclaimed") != 0 ||
            strcmp(hardware_proof_gate, "unclaimed") != 0 ||
            !field_falsey(&gates, "green_gate")) {
            fail("local QEMU final gates must keep hardware proof unclaimed and green_gate=false");
        }
        if (saw_local_audio_ok) {
            fail("local QEMU final gates must keep captured pi4audio=WAIT or HARDWARE-UNPROVEN; pi4audio=OK requires real Pi hardware evidence");
        }
        if (field_equals(&gates, "input", "green") ||
            field_equals(&gates, "graphics", "green") ||
            field_equals(&gates, "process", "green")) {
            if ((local_payload_mask & 0x3u) != 0x3u) {
                fail("local QEMU payload gates require captured Doom and Quake payload status, not ELF launch alone");
            }
        }
        if (field_equals(&gates, "graphics", "green")) {
            validate_pi4_local_framebuffer_artifact_gate(&gates);
        }
    }
    if (require_process_green && !saw_process_ok) {
        fail("process=green final gate requires captured pi4uabi=OK/pi4runtime=OK process status fields");
    }
    if (require_memory_green && !saw_memory_ok) {
        fail("memory=green final gate requires captured pi4mem=OK allocator/process-table status fields");
    }
    if (require_preemption_green && !saw_preemption_ok) {
        fail("preemption=green final gate requires captured pi4preempt=OK switch status fields");
    }
    if (require_doom_payload && (local_payload_mask & 0x1u) == 0u) {
        fail("launcher_doom_exec=green requires captured PAYLOAD0.ELF launch status fields");
    }
    if (require_quake_payload && (local_payload_mask & 0x2u) == 0u) {
        fail("launcher_quake_exec=green requires captured PAYLOAD1.ELF launch status fields");
    }
    if (strcmp(storage_gate, "green") == 0) {
        if (!saw_storage_ok || !saw_pi4wad) {
            fail("storage=green final gate requires captured nonzero pi4wad= storage evidence");
        }
        if (require_pak0 && !saw_pi4pak0) {
            fail("storage=green real-wad-and-pak final gate requires captured nonzero pi4pak0= storage evidence");
        }
    }
    if (strcmp(audio_gate, "wait") != 0 &&
        strcmp(audio_gate, "hardware-unproven") != 0 &&
        strcmp(audio_gate, "green") != 0) {
        fail("audio= final gate must be wait, hardware-unproven, or green");
    }
    if (strcmp(audio_gate, "wait") == 0) {
        if (saw_audio_ok || saw_audio_hardware_unproven) {
            fail("audio=wait final gate requires captured pi4audio=WAIT only");
        }
        if (!saw_audio_wait) {
            fail("audio=wait final gate requires at least one captured pi4audio=WAIT status");
        }
    }
    if (strcmp(audio_gate, "hardware-unproven") == 0) {
        if (saw_audio_ok) {
            fail("audio=hardware-unproven final gate must not include captured pi4audio=OK");
        }
        if (!saw_audio_hardware_unproven) {
            fail("audio=hardware-unproven final gate requires captured pi4audio=HARDWARE-UNPROVEN");
        }
    }
    if (strcmp(audio_gate, "green") == 0) {
        if (saw_audio_hardware_unproven) {
            fail("audio=green final gate requires pi4audio=OK, got HARDWARE-UNPROVEN");
        }
        if (saw_audio_wait) {
            fail("audio=green final gate requires pi4audio=OK, got WAIT");
        }
        if (!saw_audio_ok) {
            fail("audio=green final gate requires at least one captured pi4audio=OK status");
        }
        if (strcmp(hardware_gate, "claimed") != 0 ||
            strcmp(hardware_proof_gate, "claimed") != 0 ||
            !field_truthy(&gates, "green_gate")) {
            fail("audio=green final gate requires explicit hardware=claimed, hardware_proof=claimed, and green_gate=true");
        }
        if (saw_local_qemu) {
            fail("audio=green final gate requires hardware evidence, not local QEMU or unclaimed hardware proof");
        }
    }
    if (saw_local_qemu && strcmp(hardware_gate, "unclaimed") != 0) {
        fail("local QEMU captured status requires hardware=unclaimed in final gates");
    }

    free(gates.text);
}

static void validate_pi4_final_gates_single_artifact(const char *gate_path,
                                                     const char *current_sha256) {
    Status gates;
    const char *gate_sha256;

    if (!is_sha256_hex(current_sha256)) {
        fail("current Pi image SHA must be exactly 64 hex digits, got %s",
             current_sha256);
    }

    current_context = gate_path;
    parse_status(&gates, gate_path);
    exact(&gates, "single_artifact", "green");
    (void)field(&gates, "single_artifact_image");
    gate_sha256 = field(&gates, "single_artifact_sha256");
    if (!is_sha256_hex(gate_sha256)) {
        fail("single_artifact_sha256= must be exactly 64 hex digits, got %s",
             gate_sha256);
    }
    if (!sha256_hex_equals(gate_sha256, current_sha256)) {
        fail("single_artifact_sha256= is stale: final gates have %s but current Pi image is %s",
             gate_sha256, current_sha256);
    }
    free(gates.text);
}

static int contains_text(const char *haystack, const char *needle) {
    return strstr(haystack, needle) != NULL;
}

static void require_contains(const char *path, const char *needle) {
    char *text = read_text_file(path);
    if (!contains_text(text, needle)) {
        fail("%s missing %s", path, needle);
    }
    free(text);
}

static void forbid_contains(const char *path, const char *needle) {
    char *text = read_text_file(path);
    if (contains_text(text, needle)) {
        fail("%s must not contain %s", path, needle);
    }
    free(text);
}

static void validate_repo_contract(void) {
    current_context = "repo-contract";
    require_contains("Makefile", "tools/vibe_status_check.c");
    require_contains("Makefile", "vm-status-proof-check:");
    forbid_contains("Makefile", "check_vm_status_proof");

    require_contains(".github/workflows/os-smoke.yml", "tools/vibe_status_check.c");
    require_contains(".github/workflows/os-smoke.yml", "--require-exec");
    require_contains(".github/workflows/os-smoke.yml", "--require-preempt");
    require_contains(".github/workflows/os-smoke.yml", "launcher-select:1");
    require_contains(".github/workflows/os-smoke.yml", "wait-status=pmask:00000003");
    forbid_contains(".github/workflows/os-smoke.yml", "check_vm_status_proof");

    require_contains(".github/workflows/real-wad-smoke.yml", "tools/vibe_status_check.c");
    require_contains(".github/workflows/real-wad-smoke.yml", "--require-preempt");
    require_contains(".github/workflows/real-wad-smoke.yml", "launcher-click:mousebtn=1");
    forbid_contains(".github/workflows/real-wad-smoke.yml", "check_vm_status_proof");

    require_contains(".github/workflows/real-quake-smoke.yml", "launcher-select:2");
    forbid_contains(".github/workflows/real-quake-smoke.yml", "BOOT_PAYLOAD_QUAKE");

    require_contains(".github/workflows/real-wad-soak.yml", "tools/vibe_status_check.c");
    require_contains(".github/workflows/real-wad-soak.yml", "--require-preempt");
    require_contains(".github/workflows/real-wad-soak.yml", "launcher-click:mousebtn=1");
    forbid_contains(".github/workflows/real-wad-soak.yml", "check_vm_status_proof");

    require_contains("README.md", "tools/vibe_status_check.c");
    require_contains("README.md", "guest launcher screen");
    require_contains("README.md", "tools/play_now_codespaces.sh");
    require_contains("README.md", "This README is the human overview");
}

static void usage(FILE *stream) {
    fprintf(stream,
            "usage: tools/vibe_status_check [--repo-contract] [--require-exec] [--require-preempt] [--require-vfs-abi] [--require-device-abi] [--pi4-local-qemu] [--pi4-final-gates gates.txt] [--pi4-final-gates-single-artifact gates.txt sha256] status.txt...\n"
            "\n"
            "Compiled C validator for vibe-os guest status fields. The current lane\n"
            "checks the higher-half relocation proof, including krelive= and krelhaz=.\n");
}

int main(int argc, char **argv) {
    CheckOptions opts;
    int repo_contract = 0;
    int first_status = 1;
    int i;

    memset(&opts, 0, sizeof(opts));
    for (i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--require-exec") == 0) {
            opts.require_exec = 1;
        } else if (strcmp(argv[i], "--require-preempt") == 0) {
            opts.require_preempt = 1;
        } else if (strcmp(argv[i], "--require-vfs-abi") == 0) {
            opts.require_vfs_abi = 1;
        } else if (strcmp(argv[i], "--require-device-abi") == 0) {
            opts.require_device_abi = 1;
        } else if (strcmp(argv[i], "--pi4-local-qemu") == 0) {
            opts.pi4_local_qemu = 1;
        } else if (strcmp(argv[i], "--pi4-final-gates") == 0) {
            if (i + 1 >= argc) {
                usage(stderr);
                fail("--pi4-final-gates requires a gates.txt path");
            }
            opts.pi4_final_gates_path = argv[++i];
        } else if (strcmp(argv[i], "--pi4-final-gates-single-artifact") == 0) {
            if (i + 2 >= argc) {
                usage(stderr);
                fail("--pi4-final-gates-single-artifact requires a gates.txt path and current sha256");
            }
            opts.pi4_final_gates_single_artifact_path = argv[++i];
            opts.pi4_final_gates_single_artifact_sha256 = argv[++i];
        } else if (strcmp(argv[i], "--repo-contract") == 0) {
            repo_contract = 1;
        } else if (strcmp(argv[i], "--help") == 0 || strcmp(argv[i], "-h") == 0) {
            usage(stdout);
            return 0;
        } else if (argv[i][0] == '-') {
            usage(stderr);
            fail("unknown option %s", argv[i]);
        } else {
            first_status = i;
            break;
        }
    }

    if (repo_contract) {
        validate_repo_contract();
        printf("VM status proof contract OK (C)\n");
        return 0;
    }

    if (opts.pi4_final_gates_single_artifact_path) {
        validate_pi4_final_gates_single_artifact(
            opts.pi4_final_gates_single_artifact_path,
            opts.pi4_final_gates_single_artifact_sha256);
        printf("Pi 4 final gates single artifact OK (C): sha256 is current\n");
        return 0;
    }

    if (first_status >= argc) {
        usage(stderr);
        fail("status file required unless --repo-contract is used");
    }

    if (opts.pi4_final_gates_path) {
        validate_pi4_final_gates(opts.pi4_final_gates_path, argc - first_status,
                                 &argv[first_status]);
        printf("Pi 4 final gates OK (C): validated %d captured status file(s)\n",
               argc - first_status);
        return 0;
    }

    for (i = first_status; i < argc; i++) {
        validate_status_file(argv[i], &opts);
    }
    printf("VM status proof OK (C): validated %d status file(s)\n", argc - first_status);
    return 0;
}
