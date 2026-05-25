#include <ctype.h>
#include <errno.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_FIELDS 1024
#define MAX_FILE_BYTES (1024 * 1024)

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
#define VIBE_INPUT_EVENT_KEY 1u
#define VIBE_INPUT_EVENT_MOUSE_PACKET 2u
#define VIBE_INPUT_QUEUE_OVERFLOW_DROP_OLDEST 1u
#define VIBE_INPUT_CAP_KEYBOARD 0x00000001u
#define VIBE_INPUT_CAP_MOUSE 0x00000002u
#define VIBE_INPUT_CAP_POLL_EVENT 0x00000004u
#define VIBE_INPUT_CAP_STATUS 0x00000008u
#define VIBE_INPUT_CAP_DEVICE_STATUS 0x00000010u
#define VIBE_INPUT_REQUIRED_CAPS \
    (VIBE_INPUT_CAP_POLL_EVENT | VIBE_INPUT_CAP_STATUS | VIBE_INPUT_CAP_DEVICE_STATUS)
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
#define VIBE_FB_REQUIRED_CAPS \
    (VIBE_FB_CAP_PRESENT_INDEXED | VIBE_FB_CAP_PRESENT_RGB_PALETTE | VIBE_FB_CAP_DIRTY_SOURCE_RECT)
#define VIBE_FB_FORMAT_INDEX8_RGB24 1u
#define FRAMEBUFFER_ABI_VERSION 1u
#define FRAMEBUFFER_PRESENT_SEMANTICS_INDEXED_SOURCE 1u
#define FRAMEBUFFER_PRESENT_SOURCE_SYS 1u
#define FRAMEBUFFER_PRESENT_SOURCE_IOCTL 2u
#define FB_PRESENT_WIDTH 320u
#define FB_PRESENT_HEIGHT 200u
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

static int valid_field_name(const char *name) {
    const unsigned char *p = (const unsigned char *)name;

    if (!isalpha(*p)) {
        return 0;
    }
    for (; *p; p++) {
        if (!isalnum(*p) && *p != '_') {
            return 0;
        }
    }
    return 1;
}

static void parse_status(Status *status, const char *path) {
    char *p;

    memset(status, 0, sizeof(*status));
    status->path = path;
    status->text = read_text_file(path);
    p = status->text;

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
        fail("fbdev= must describe a ready mode13 or XRGB8888 framebuffer device");
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
        if ((fbcap & VIBE_FB_CAP_XRGB8888_LFB) == 0u || fbdev[3] != VIBE_INPUT_DEVICE_STATUS_READY) {
            fail("fbdev=/fbcap= must prove mapped XRGB8888 LFB support for the LFB backend");
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

static void validate_status_file(const char *path, const CheckOptions *opts) {
    Status status;

    current_context = path;
    parse_status(&status, path);
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
            "usage: tools/vibe_status_check [--repo-contract] [--require-exec] [--require-preempt] [--require-vfs-abi] [--require-device-abi] status.txt...\n"
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

    if (first_status >= argc) {
        usage(stderr);
        fail("status file required unless --repo-contract is used");
    }

    for (i = first_status; i < argc; i++) {
        validate_status_file(argv[i], &opts);
    }
    printf("VM status proof OK (C): validated %d status file(s)\n", argc - first_status);
    return 0;
}
