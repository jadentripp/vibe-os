#include <ctype.h>
#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_STATUS_BYTES (1024 * 1024)
#define MAX_FIELDS 128
#define ARRAY_COUNT(a) (sizeof(a) / sizeof((a)[0]))
#define STATUS_PREFIX "vibe-status"
#define PI4_VIBE_SYS_EXEC_HEX "0000000000000010"
#define PI4_FAT_ATTR_LONG_NAME 0x0Full
#define PI4_FAT_ATTR_VOLUME_ID 0x08ull
#define PI4_FAT_ATTR_DIRECTORY 0x10ull
#define PI4_STORAGE_FILE_STATUS_OK 0x00000000464F4F4Bull
#define PI4_VIBE_FILE_ASSET_APP_ELF_BASE 14ull
#define PI4_VIBE_FIRST_PROVEN_APP_COUNT 2ull
#define PI4_VIBE_FILE_ASSET_APP_RECORD0_ELF \
    (PI4_VIBE_FILE_ASSET_APP_ELF_BASE + 0ull)
#define PI4_VIBE_FILE_ASSET_APP_RECORD1_ELF \
    (PI4_VIBE_FILE_ASSET_APP_ELF_BASE + 1ull)
#define PI4_APP_RECORD_KEY_BYTES 32u
#define PI4_STORAGE_ASSET_COVERAGE_WAD 0x00000001ull
#define PI4_STORAGE_ASSET_COVERAGE_MANIFEST 0x00000002ull
#define PI4_STORAGE_ASSET_COVERAGE_PAK0 0x00000004ull
#define PI4_STORAGE_ASSET_COVERAGE_DEFAULT_FILES 0x00000008ull
#define PI4_STORAGE_ASSET_REQUIRED_COVERAGE \
    (PI4_STORAGE_ASSET_COVERAGE_WAD | PI4_STORAGE_ASSET_COVERAGE_MANIFEST | \
     PI4_STORAGE_ASSET_COVERAGE_DEFAULT_FILES)
#define PI4_EMMC2_LEGACY_BASE 0x7E340000ull
#define PI4_EMMC2_ARM_BASE 0xFE340000ull
#define PI4_EMMC2_MIN_REG_SPAN 0x100ull
#define PI4_VIBE_APP_DOOM 0ull
#define PI4_VIBE_APP_QUAKE 1ull
#define PI4_PROC_TABLE_ENTRY_BYTES 64ull
#define PI4_PROC_CONTEXT_BYTES 64ull
#define PI4_PROC_CONTEXT_VERSION 1ull
#define PI4_PROC_CONTEXT_FLAG_EL0_FRAME 0x00000001ull
#define PI4_PROC_CONTEXT_FLAG_TIMER_IRQ 0x00000002ull
#define PI4_PROC_CONTEXT_REQUIRED_FLAGS \
    (PI4_PROC_CONTEXT_FLAG_EL0_FRAME | PI4_PROC_CONTEXT_FLAG_TIMER_IRQ)
#define PI4_BLOCK_READ_MAX_COUNT 1024ull
#define PI4_BLOCK_READ_SECTOR_BYTES 512ull
#define PI4_STORAGE_STATUS_SD_OK 0x0000000053444F4Bull
#define PI4_EL0_ALLOC_REQUIRED_FLAGS 0x0000000Full
#define PI4_EL0_ALLOC_BOOT_COUNT 2ull
#define PI4_AUDIO_CAP_MMIO_WINDOW 0x00000001ull
#define PI4_AUDIO_CAP_MAILBOX_CLOCK 0x00000002ull
#define PI4_AUDIO_CAP_PCM_QUEUE 0x00000004ull
#define PI4_AUDIO_CAP_USB_AUDIO 0x00000008ull
#define PI4_AUDIO_REQUIRED_CAPS \
    (PI4_AUDIO_CAP_MMIO_WINDOW | PI4_AUDIO_CAP_MAILBOX_CLOCK | PI4_AUDIO_CAP_PCM_QUEUE)
#define PI4_AUDIO_USB_REQUIRED_CAPS \
    (PI4_AUDIO_CAP_USB_AUDIO | PI4_AUDIO_CAP_PCM_QUEUE)
#define PI4_AUDIO_ABI_DEVICE_STATUS 0x00000001ull
#define PI4_AUDIO_ABI_QUEUE_STATUS 0x00000002ull
#define PI4_AUDIO_ABI_CAP_STATUS 0x00000004ull
#define PI4_AUDIO_ABI_FULL_MASK \
    (PI4_AUDIO_ABI_DEVICE_STATUS | PI4_AUDIO_ABI_QUEUE_STATUS | PI4_AUDIO_ABI_CAP_STATUS)
#define PI4_SDHCI_CMD17_READ_SINGLE 0x0000113Aull
#define PI4_SDHCI_CMD18_READ_MULTI 0x0000123Aull
#define PI4_SDHCI_TRANSFER_READ_SINGLE 0x00000012ull
#define PI4_SDHCI_TRANSFER_READ_MULTI 0x00000036ull
#define PI4_SDHCI_PIO_WORDS_PER_SECTOR 128ull

typedef struct {
    char* key;
    char* value;
} Field;

typedef struct {
    const char* key;
    const char* value;
} RequiredValue;

static const RequiredValue required_values[] = {
    {"arch", "AARCH64"},
    {"machine", "PI4"},
    {"image", "PI4"},
    {"artifact", "OK"},
    {"pi4boot", "OK"},
    {"pi4uart", "OK"},
    {"pi4input", "UART"},
    {"pi4usb", "WAIT"},
    {"pi4el", "EL1"},
    {"pi4dtb", "OK"},
    {"pi4boarddtb", "OK"},
    {"pi4soc", "WAIT"},
    {"pi4socdtb", "OK"},
    {"pi4gicdtb", "OK"},
    {"pi4gicmmio", "OK"},
    {"pi4giccfg", "OK"},
    {"pi4irq", "OK"},
    {"pi4timer", "OK"},
    {"pi4vec", "OK"},
    {"pi4svc", "OK"},
    {"pi4mailbox", "OK"},
    {"pi4fb", "OK"},
    {"pi4sd", "OK"},
    {"pi4fat", "OK"},
    {"pi4vfs", "OK"},
    {"pi4mem", "OK"},
    {"pi4uabi", "OK"},
    {"pi4elf", "OK"},
    {"pi4elfsrc", "VFS"},
    {"pi4runtime", "OK"},
    {"pi4preempt", "OK"},
    {"faultsrc", "NONE"},
    {"faultmode", "NONE"},
    {"panic", "NONE"},
    {"shutdown", "NONE"},
};

static const char* required_fields[] = {
    "pi4entry",
    "pi4inputdev",
    "pi4inputq",
    "pi4inputlast",
    "pi4dtbroot",
    "pi4model",
    "pi4compat",
    "pi4socrange",
    "pi4socrangelen",
    "pi4currentel",
    "pi4gicnode",
    "pi4giccompat",
    "pi4gicreg",
    "pi4gicreglen",
    "pi4gicbase",
    "pi4gicctl",
    "pi4giciidr",
    "pi4vbar",
    "pi4sysframe",
    "pi4mem",
    "pi4kmap",
    "pi4stack",
    "pi4umem",
    "pi4ualloc",
    "pi4fbmap",
    "pi4ptable",
    "pi4mbr",
    "pi4bpb",
    "pi4root",
    "pi4kernel8",
    "pi4config",
    "pi4init",
    "pi4abiprobe",
    "pi4app0",
    "pi4app1",
    "pi4manifest",
    "pi4assets",
    "pi4wad",
    "pi4elfentry",
    "pi4elfphdr",
    "pi4elfload",
    "uentry",
    "execsys",
    "pi4ustack",
    "execmap",
    "pstat",
    "procpool",
    "pidseq",
    "pi4ctx",
    "pi4sched",
    "pi4fbmail",
    "fbgeom",
    "fbpresent",
    "fbdirty",
    "fbabi",
    "pi4audiommio",
    "pi4audiomailbox",
    "pi4audiocap",
    "pi4audioq",
    "pi4audioabi",
};

static void usage(const char* argv0)
{
    fprintf(stderr, "usage: %s [serial-status.txt]\n", argv0);
    fprintf(stderr, "       %s < serial-status.txt\n", argv0);
}

static char* read_stream(FILE* input, const char* label, size_t* out_size)
{
    size_t cap = 4096;
    size_t used = 0;
    char* data = (char*)malloc(cap);
    if (!data) {
        fprintf(stderr, "pi4_status_evidence: out of memory\n");
        exit(2);
    }

    for (;;) {
        if (used == cap) {
            size_t next_cap = cap * 2;
            char* next = NULL;
            if (next_cap > MAX_STATUS_BYTES + 1)
                next_cap = MAX_STATUS_BYTES + 1;
            if (next_cap == cap) {
                fprintf(stderr, "pi4_status_evidence: %s is larger than %u bytes\n",
                    label, MAX_STATUS_BYTES);
                free(data);
                exit(2);
            }
            next = (char*)realloc(data, next_cap);
            if (!next) {
                fprintf(stderr, "pi4_status_evidence: out of memory\n");
                free(data);
                exit(2);
            }
            data = next;
            cap = next_cap;
        }

        size_t got = fread(data + used, 1, cap - used, input);
        used += got;
        if (got == 0) {
            if (ferror(input)) {
                fprintf(stderr, "pi4_status_evidence: %s: read failed\n", label);
                free(data);
                exit(2);
            }
            break;
        }
    }

    data[used] = '\0';
    *out_size = used;
    return data;
}

static char* read_input(const char* path, size_t* out_size)
{
    char* data = NULL;
    if (!path)
        return read_stream(stdin, "stdin", out_size);

    FILE* input = fopen(path, "rb");
    if (!input) {
        fprintf(stderr, "pi4_status_evidence: %s: %s\n", path, strerror(errno));
        exit(2);
    }
    data = read_stream(input, path, out_size);
    fclose(input);
    return data;
}

static int is_status_line(const char* line)
{
    size_t prefix_len = strlen(STATUS_PREFIX);

    return strncmp(line, STATUS_PREFIX, prefix_len) == 0 &&
        (line[prefix_len] == '\0' || line[prefix_len] == ' ' || line[prefix_len] == '\t');
}

static int valid_field_name_span(const char* name, size_t len)
{
    const unsigned char* p = (const unsigned char*)name;
    const unsigned char* end = p + len;

    if (len == 0 || !isalpha(*p))
        return 0;
    for (; p < end; p++) {
        if (!isalnum(*p) && *p != '_')
            return 0;
    }
    return 1;
}

static int line_starts_with_status_field(const char* line)
{
    const char* name = NULL;

    while (*line == ' ' || *line == '\t' || *line == '\r')
        line++;
    name = line;
    while (*line && !isspace((unsigned char)*line) && *line != '=')
        line++;
    return *line == '=' && valid_field_name_span(name, (size_t)(line - name));
}

static char* find_last_status_record(char* data)
{
    char* best = NULL;
    char* cursor = data;

    while (*cursor) {
        char* line = cursor;
        char* end = strchr(cursor, '\n');

        if (is_status_line(line))
            best = line;
        if (!end)
            break;
        cursor = end + 1;
    }

    return best;
}

static char* select_status_parse_text(char* data)
{
    char* record = find_last_status_record(data);
    char* block_end = NULL;
    char* scan = NULL;

    if (!record)
        return NULL;

    block_end = strpbrk(record, "\r\n");
    if (!block_end)
        return record;

    scan = block_end;
    while (*scan == '\r' || *scan == '\n')
        scan++;
    while (*scan && line_starts_with_status_field(scan)) {
        char* next = strpbrk(scan, "\r\n");
        if (!next) {
            block_end = scan + strlen(scan);
            break;
        }
        block_end = next;
        scan = next;
        while (*scan == '\r' || *scan == '\n')
            scan++;
    }

    *block_end = '\0';
    return record;
}

static int parse_fields(char* line, Field* fields, size_t* out_count)
{
    size_t count = 0;
    char* cursor = line;

    while (*cursor && !isspace((unsigned char)*cursor))
        cursor++;

    while (*cursor) {
        char* token = NULL;
        char* eq = NULL;

        while (*cursor && isspace((unsigned char)*cursor))
            cursor++;
        if (!*cursor)
            break;

        token = cursor;
        while (*cursor && !isspace((unsigned char)*cursor))
            cursor++;
        if (*cursor) {
            *cursor = '\0';
            cursor++;
        }

        eq = strchr(token, '=');
        if (!eq || eq == token || !eq[1]) {
            fprintf(stderr, "pi4_status_evidence: malformed field '%s'\n", token);
            return 0;
        }
        *eq = '\0';

        if (count == MAX_FIELDS) {
            fprintf(stderr, "pi4_status_evidence: too many status fields\n");
            return 0;
        }

        fields[count].key = token;
        fields[count].value = eq + 1;
        count++;
    }

    *out_count = count;
    return 1;
}

static const char* find_value(const Field* fields, size_t count, const char* key)
{
    size_t i = 0;
    for (i = 0; i < count; i++) {
        if (strcmp(fields[i].key, key) == 0)
            return fields[i].value;
    }
    return NULL;
}

static int check_required_values(const Field* fields, size_t count)
{
    int ok = 1;
    size_t i = 0;

    for (i = 0; i < ARRAY_COUNT(required_values); i++) {
        const char* got = find_value(fields, count, required_values[i].key);
        if (!got) {
            fprintf(stderr, "pi4_status_evidence: missing %s=%s\n",
                required_values[i].key, required_values[i].value);
            ok = 0;
        } else if (strcmp(got, required_values[i].value) != 0) {
            fprintf(stderr, "pi4_status_evidence: expected %s=%s, got %s=%s\n",
                required_values[i].key, required_values[i].value,
                required_values[i].key, got);
            ok = 0;
        }
    }

    return ok;
}

static int check_required_fields(const Field* fields, size_t count)
{
    int ok = 1;
    size_t i = 0;

    for (i = 0; i < ARRAY_COUNT(required_fields); i++) {
        const char* got = find_value(fields, count, required_fields[i]);
        if (!got) {
            fprintf(stderr, "pi4_status_evidence: missing %s=<value>\n",
                required_fields[i]);
            ok = 0;
        }
    }

    return ok;
}

static int check_panic_fault_status(const Field* fields, size_t count)
{
    const char* faultsrc = find_value(fields, count, "faultsrc");
    const char* faultmode = find_value(fields, count, "faultmode");
    const char* panic = find_value(fields, count, "panic");
    int ok = 1;

    if (!faultsrc) {
        fprintf(stderr, "pi4_status_evidence: missing faultsrc=<value>\n");
        ok = 0;
    }
    if (!faultmode) {
        fprintf(stderr, "pi4_status_evidence: missing faultmode=<value>\n");
        ok = 0;
    }
    if (!panic) {
        fprintf(stderr, "pi4_status_evidence: missing panic=<value>\n");
        ok = 0;
    }
    if (!ok)
        return 0;

    if (strcmp(panic, "NONE") == 0) {
        if (strcmp(faultsrc, "NONE") != 0 || strcmp(faultmode, "NONE") != 0) {
            fprintf(stderr,
                "pi4_status_evidence: panic=NONE requires faultsrc=NONE and faultmode=NONE\n");
            return 0;
        }
        return 1;
    }

    if (strcmp(faultsrc, "NONE") == 0 || strcmp(faultmode, "NONE") == 0) {
        fprintf(stderr,
            "pi4_status_evidence: panic=%s requires non-NONE faultsrc= and faultmode= evidence\n",
            panic);
        return 0;
    }
    return 1;
}

static int require_value(const Field* fields, size_t count, const char* key, const char* expected)
{
    const char* got = find_value(fields, count, key);
    if (!got) {
        fprintf(stderr, "pi4_status_evidence: missing %s=%s\n", key, expected);
        return 0;
    }
    if (strcmp(got, expected) != 0) {
        fprintf(stderr, "pi4_status_evidence: expected %s=%s, got %s=%s\n",
            key, expected, key, got);
        return 0;
    }
    return 1;
}

static int require_field(const Field* fields, size_t count, const char* key)
{
    if (!find_value(fields, count, key)) {
        fprintf(stderr, "pi4_status_evidence: missing %s=<value>\n", key);
        return 0;
    }
    return 1;
}

static int value_is_truthy(const char* value)
{
    return strcmp(value, "true") == 0 || strcmp(value, "TRUE") == 0 ||
        strcmp(value, "1") == 0 || strcmp(value, "yes") == 0 ||
        strcmp(value, "YES") == 0;
}

static int value_has_prefix(const char* value, const char* prefix)
{
    return strncmp(value, prefix, strlen(prefix)) == 0;
}

static int value_is_falsey(const char* value)
{
    return strcmp(value, "false") == 0 || strcmp(value, "FALSE") == 0 ||
        strcmp(value, "0") == 0 || strcmp(value, "no") == 0 ||
        strcmp(value, "NO") == 0;
}

static int check_capture_source(const Field* fields, size_t count)
{
    const char* local_qemu_only = find_value(fields, count, "local_qemu_only");
    const char* evidence_class = find_value(fields, count, "evidence_class");
    const char* smoke_gate = find_value(fields, count, "smoke_gate");
    const char* hardware = find_value(fields, count, "hardware");
    const char* green_gate = find_value(fields, count, "green_gate");
    const char* hardware_proof = find_value(fields, count, "hardware_proof");
    const char* audio_gate = find_value(fields, count, "audio");

    if ((local_qemu_only && value_is_truthy(local_qemu_only)) ||
        (evidence_class && value_has_prefix(evidence_class, "local-qemu")) ||
        (smoke_gate && value_has_prefix(smoke_gate, "pi4-local-qemu")) ||
        (hardware && strcmp(hardware, "unclaimed") == 0) ||
        (green_gate && value_is_falsey(green_gate)) ||
        (hardware_proof && strcmp(hardware_proof, "unclaimed") == 0)) {
        fprintf(stderr,
            "pi4_status_evidence: local QEMU smoke metadata cannot satisfy real Pi 4 hardware proof\n");
        return 0;
    }
    if (audio_gate && strcmp(audio_gate, "green") == 0) {
        fprintf(stderr,
            "pi4_status_evidence: audio=green is a final-gate claim, not Pi 4 serial audio evidence\n");
        return 0;
    }
    return 1;
}

static int value_has_nonzero_hex_digit(const char* value)
{
    const char* p = value;

    if (p[0] == '0' && (p[1] == 'x' || p[1] == 'X'))
        p += 2;
    for (; *p; p++) {
        if (*p >= '1' && *p <= '9')
            return 1;
        if (*p >= 'a' && *p <= 'f')
            return 1;
        if (*p >= 'A' && *p <= 'F')
            return 1;
    }
    return 0;
}

static int require_nonzero_hex_field(const Field* fields, size_t count, const char* key)
{
    const char* value = find_value(fields, count, key);

    if (!value) {
        fprintf(stderr, "pi4_status_evidence: missing %s=<value>\n", key);
        return 0;
    }
    if (!value_has_nonzero_hex_digit(value)) {
        fprintf(stderr, "pi4_status_evidence: %s= must be nonzero\n", key);
        return 0;
    }
    return 1;
}

static int count_nonzero_tuple_fields(const char* value, size_t* out_fields, size_t* out_nonzero)
{
    const char* p = value;
    size_t fields = 0;
    size_t nonzero_fields = 0;

    while (*p) {
        int digits = 0;
        int nonzero = 0;

        if (p[0] == '0' && (p[1] == 'x' || p[1] == 'X'))
            p += 2;
        while (*p && *p != '/') {
            if (*p >= '0' && *p <= '9') {
                digits++;
                nonzero = nonzero || *p != '0';
            } else if (*p >= 'a' && *p <= 'f') {
                digits++;
                nonzero = 1;
            } else if (*p >= 'A' && *p <= 'F') {
                digits++;
                nonzero = 1;
            } else {
                return 0;
            }
            p++;
        }

        if (digits == 0)
            return 0;
        fields++;
        if (nonzero)
            nonzero_fields++;
        if (*p == '/') {
            p++;
            if (!*p)
                return 0;
        }
    }

    *out_fields = fields;
    *out_nonzero = nonzero_fields;
    return fields > 0;
}

static int hex_value(char c)
{
    if (c >= '0' && c <= '9')
        return c - '0';
    if (c >= 'a' && c <= 'f')
        return c - 'a' + 10;
    if (c >= 'A' && c <= 'F')
        return c - 'A' + 10;
    return -1;
}

static int parse_hex64_tuple_exact(const Field* fields, size_t count, const char* key,
    size_t expected_fields, uint64_t* out)
{
    const char* p = find_value(fields, count, key);
    size_t parsed = 0;

    if (!p) {
        fprintf(stderr, "pi4_status_evidence: missing %s=<value>\n", key);
        return 0;
    }

    while (*p) {
        uint64_t value = 0;
        size_t digits = 0;

        if (parsed == expected_fields) {
            fprintf(stderr,
                "pi4_status_evidence: %s= must include exactly %zu hexadecimal fields\n",
                key, expected_fields);
            return 0;
        }
        if (p[0] == '0' && (p[1] == 'x' || p[1] == 'X'))
            p += 2;
        while (*p && *p != '/') {
            int digit = hex_value(*p);
            if (digit < 0 || digits == 16) {
                fprintf(stderr,
                    "pi4_status_evidence: %s= must contain 64-bit hexadecimal fields\n",
                    key);
                return 0;
            }
            value = (value << 4) | (uint64_t)digit;
            digits++;
            p++;
        }
        if (digits == 0) {
            fprintf(stderr, "pi4_status_evidence: %s= has an empty field\n", key);
            return 0;
        }
        out[parsed++] = value;
        if (*p == '/') {
            p++;
            if (!*p) {
                fprintf(stderr,
                    "pi4_status_evidence: %s= must not end with a separator\n", key);
                return 0;
            }
        }
    }

    if (parsed != expected_fields) {
        fprintf(stderr,
            "pi4_status_evidence: %s= must include exactly %zu hexadecimal fields\n",
            key, expected_fields);
        return 0;
    }
    return 1;
}

static int parse_hex64_tuple_fields(const Field* fields, size_t count, const char* key,
    uint64_t* out, size_t max_fields, size_t* out_fields)
{
    const char* p = find_value(fields, count, key);
    size_t parsed = 0;

    if (!p) {
        fprintf(stderr, "pi4_status_evidence: missing %s=<value>\n", key);
        return 0;
    }

    while (*p) {
        uint64_t value = 0;
        size_t digits = 0;

        if (parsed == max_fields) {
            fprintf(stderr,
                "pi4_status_evidence: %s= must include at most %zu hexadecimal fields\n",
                key, max_fields);
            return 0;
        }
        if (p[0] == '0' && (p[1] == 'x' || p[1] == 'X'))
            p += 2;
        while (*p && *p != '/') {
            int digit = hex_value(*p);
            if (digit < 0 || digits == 16) {
                fprintf(stderr,
                    "pi4_status_evidence: %s= must contain 64-bit hexadecimal fields\n",
                    key);
                return 0;
            }
            value = (value << 4) | (uint64_t)digit;
            digits++;
            p++;
        }
        if (digits == 0) {
            fprintf(stderr, "pi4_status_evidence: %s= has an empty field\n", key);
            return 0;
        }
        out[parsed++] = value;
        if (*p == '/') {
            p++;
            if (!*p) {
                fprintf(stderr,
                    "pi4_status_evidence: %s= must not end with a separator\n", key);
                return 0;
            }
        }
    }

    *out_fields = parsed;
    return parsed > 0;
}

static int parse_hex64_scalar_value(const char* value, uint64_t* out)
{
    uint64_t parsed = 0;
    size_t digits = 0;

    if (value[0] == '0' && (value[1] == 'x' || value[1] == 'X'))
        value += 2;
    while (*value) {
        int digit = hex_value(*value);
        if (digit < 0 || digits == 16)
            return 0;
        parsed = (parsed << 4) | (uint64_t)digit;
        digits++;
        value++;
    }
    if (digits == 0)
        return 0;
    *out = parsed;
    return 1;
}

static int status_word_equals(const char* value, const char* name, uint64_t word)
{
    uint64_t parsed = 0;

    if (strcmp(value, name) == 0)
        return 1;
    return parse_hex64_scalar_value(value, &parsed) && parsed == word;
}

static int is_pi4_installed_app_path(const char* path)
{
    static const char prefix[] = "/APPS/";
    static const char suffix[] = "/APP.ELF";
    size_t prefix_len = sizeof(prefix) - 1u;
    size_t suffix_len = sizeof(suffix) - 1u;
    size_t path_len = strlen(path);
    const char* name = NULL;
    const char* name_end = NULL;

    if (strncmp(path, prefix, prefix_len) != 0 || path_len <= prefix_len + suffix_len ||
        strcmp(path + path_len - suffix_len, suffix) != 0)
        return 0;

    name = path + prefix_len;
    name_end = path + path_len - suffix_len;
    for (; name < name_end; name++) {
        if (*name == '/')
            return 0;
    }
    return 1;
}

static int is_pi4_user_exec_path(const char* path)
{
    return strcmp(path, "/SYSTEM/INIT.ELF") == 0 ||
        is_pi4_installed_app_path(path);
}

static int pi4_app_record_field_index(const char* name, uint64_t* index)
{
    static const char prefix[] = "pi4app";
    const char* p = NULL;
    uint64_t value = 0;

    if (strncmp(name, prefix, sizeof(prefix) - 1) != 0)
        return 0;
    p = name + sizeof(prefix) - 1;
    if (!isdigit((unsigned char)*p))
        return 0;
    for (; *p; p++) {
        uint64_t digit = 0;

        if (!isdigit((unsigned char)*p))
            return 0;
        digit = (uint64_t)(*p - '0');
        if (value > (UINT64_MAX - digit) / 10)
            return 0;
        value = value * 10 + digit;
    }
    if (index)
        *index = value;
    return 1;
}

static int pi4_app_record_key_for_index(uint64_t index, char* key, size_t key_size)
{
    int written = snprintf(key, key_size, "pi4app%llu", (unsigned long long)index);

    return written > 0 && (size_t)written < key_size;
}

static int pi4_app_record_key_for_elf_asset(uint64_t app_record, char* key,
    size_t key_size)
{
    if (app_record < PI4_VIBE_FILE_ASSET_APP_ELF_BASE)
        return 0;
    return pi4_app_record_key_for_index(app_record - PI4_VIBE_FILE_ASSET_APP_ELF_BASE,
        key, key_size);
}

static int pi4_status_has_installed_app_record(const Field* fields, size_t count,
    uint64_t app_record, char* key, size_t key_size)
{
    return pi4_app_record_key_for_elf_asset(app_record, key, key_size) &&
        find_value(fields, count, key) != NULL;
}

static int pi4_first_app_record_for_path(const char* path, uint64_t* app_record)
{
    if (strcmp(path, "/APPS/DOOM/APP.ELF") == 0) {
        *app_record = PI4_VIBE_FILE_ASSET_APP_RECORD0_ELF;
        return 1;
    }
    if (strcmp(path, "/APPS/QUAKE/APP.ELF") == 0) {
        *app_record = PI4_VIBE_FILE_ASSET_APP_RECORD1_ELF;
        return 1;
    }
    return 0;
}

static int require_tuple_nonzero_fields(const Field* fields, size_t count, const char* key,
    size_t min_fields, size_t min_nonzero)
{
    size_t field_count = 0;
    size_t nonzero_count = 0;
    const char* value = find_value(fields, count, key);

    if (!value) {
        fprintf(stderr, "pi4_status_evidence: missing %s=<value>\n", key);
        return 0;
    }
    if (!count_nonzero_tuple_fields(value, &field_count, &nonzero_count) ||
        field_count < min_fields || nonzero_count < min_nonzero) {
        fprintf(stderr,
            "pi4_status_evidence: %s= must include at least %zu fields with %zu nonzero entries\n",
            key, min_fields, min_nonzero);
        return 0;
    }
    return 1;
}

static int require_pi4_storage_file_tuple(const char* key, const uint64_t* file,
    const uint64_t* mbr, const uint64_t* bpb, const uint64_t* root)
{
    uint64_t partition_end = mbr[4] + mbr[5];
    uint64_t bytes_per_sector = bpb[1];
    uint64_t sectors_per_cluster = bpb[2];
    uint64_t expected_lba = 0;
    uint64_t expected_plan_bytes = 0;
    uint64_t expected_plan_sectors = 0;

    if ((file[1] & PI4_FAT_ATTR_LONG_NAME) == PI4_FAT_ATTR_LONG_NAME ||
        (file[1] & (PI4_FAT_ATTR_VOLUME_ID | PI4_FAT_ATTR_DIRECTORY)) != 0 ||
        file[2] < 2 || file[3] == 0 || file[4] == 0 || file[5] == 0 ||
        file[6] == 0) {
        fprintf(stderr,
            "pi4_status_evidence: %s= must prove regular FAT metadata and a read plan\n",
            key);
        return 0;
    }
    if (bytes_per_sector == 0 || sectors_per_cluster == 0 ||
        sectors_per_cluster > UINT64_MAX / bytes_per_sector ||
        (file[2] - 2) > (UINT64_MAX - root[3]) / sectors_per_cluster ||
        file[3] > UINT64_MAX - (bytes_per_sector - 1)) {
        fprintf(stderr,
            "pi4_status_evidence: %s= cannot be checked against invalid FAT geometry\n",
            key);
        return 0;
    }

    expected_lba = root[3] + ((file[2] - 2) * sectors_per_cluster);
    expected_plan_bytes = file[3];
    expected_plan_sectors = (file[3] + bytes_per_sector - 1) / bytes_per_sector;

    if (file[4] != expected_lba || file[5] != expected_plan_sectors ||
        file[6] != expected_plan_bytes || file[7] > file[5] ||
        (file[7] != file[5] && !pi4_app_record_field_index(key, NULL) &&
         strcmp(key, "pi4manifest") != 0 && strcmp(key, "pi4wad") != 0 &&
         strcmp(key, "pi4pak0") != 0)) {
        fprintf(stderr,
            "pi4_status_evidence: %s= read plan/count must prove a completed FAT file read\n",
            key);
        return 0;
    }
    if (file[4] < mbr[4] || file[4] >= partition_end || file[5] > partition_end - file[4]) {
        fprintf(stderr,
            "pi4_status_evidence: %s= read plan must stay inside the validated MBR partition\n",
            key);
        return 0;
    }
    return 1;
}

static int require_pi4_storage_file_plan(const Field* fields, size_t count, const char* key,
    const uint64_t* mbr, const uint64_t* bpb, const uint64_t* root)
{
    uint64_t file[8];

    if (!parse_hex64_tuple_exact(fields, count, key, 8, file))
        return 0;
    return require_pi4_storage_file_tuple(key, file, mbr, bpb, root);
}

static int reject_pi4_app_catalog_fields(const Field* fields, size_t count,
    const char* gate)
{
    int ok = 1;
    size_t i = 0;

    for (i = 0; i < count; i++) {
        if (pi4_app_record_field_index(fields[i].key, NULL)) {
            fprintf(stderr, "pi4_status_evidence: %s=WAIT must not include %s=\n",
                gate, fields[i].key);
            ok = 0;
        }
    }
    return ok;
}

static int require_pi4_app_catalog_evidence(const Field* fields, size_t count,
    const uint64_t* mbr, const uint64_t* bpb, const uint64_t* root)
{
    int saw_first_apps[PI4_VIBE_FIRST_PROVEN_APP_COUNT] = {0};
    uint64_t required = 0;
    size_t i = 0;
    int ok = 1;

    for (i = 0; i < count; i++) {
        uint64_t index = 0;

        if (!pi4_app_record_field_index(fields[i].key, &index))
            continue;
        ok = require_pi4_storage_file_plan(fields, count, fields[i].key, mbr, bpb, root) &&
            ok;
        if (index < PI4_VIBE_FIRST_PROVEN_APP_COUNT)
            saw_first_apps[index] = 1;
    }

    for (required = 0; required < PI4_VIBE_FIRST_PROVEN_APP_COUNT; required++) {
        char app_key[PI4_APP_RECORD_KEY_BYTES];

        if (!pi4_app_record_key_for_index(required, app_key, sizeof(app_key))) {
            fprintf(stderr,
                "pi4_status_evidence: could not format required Pi app catalog entry key\n");
            ok = 0;
            continue;
        }
        if (!saw_first_apps[required]) {
            fprintf(stderr,
                "pi4_status_evidence: pi4vfs=OK requires first app catalog entry %s=\n",
                app_key);
            ok = 0;
        }
    }
    return ok;
}

static int require_pi4_storage_root_artifact(const Field* fields, size_t count,
    const char* key)
{
    uint64_t file[4];

    if (!parse_hex64_tuple_exact(fields, count, key, 4, file))
        return 0;
    if (file[0] == 0 ||
        (file[1] & PI4_FAT_ATTR_LONG_NAME) == PI4_FAT_ATTR_LONG_NAME ||
        (file[1] & (PI4_FAT_ATTR_VOLUME_ID | PI4_FAT_ATTR_DIRECTORY)) != 0 ||
        file[2] < 2 || file[3] == 0) {
        fprintf(stderr,
            "pi4_status_evidence: %s= must prove regular FAT root metadata for a packaged Pi image artifact\n",
            key);
        return 0;
    }
    return 1;
}

static int require_pi4_storage_asset_summary(const Field* fields, size_t count,
    uint64_t* out_coverage)
{
    uint64_t assets[3];

    if (!parse_hex64_tuple_exact(fields, count, "pi4assets", 3, assets))
        return 0;
    if (assets[0] < 3 || assets[1] < 2 ||
        (assets[2] & PI4_STORAGE_ASSET_REQUIRED_COVERAGE) !=
            PI4_STORAGE_ASSET_REQUIRED_COVERAGE) {
        fprintf(stderr,
            "pi4_status_evidence: pi4assets= must prove default asset files, nested asset directories, WAD, and manifest coverage\n");
        return 0;
    }
    *out_coverage = assets[2];
    return 1;
}

static int require_non_embedded_elf_source(const Field* fields, size_t count)
{
    const char* value = find_value(fields, count, "pi4elfsrc");

    if (!value) {
        fprintf(stderr, "pi4_status_evidence: missing pi4elfsrc=<value>\n");
        return 0;
    }
    if (strcmp(value, "EMBEDDED") == 0) {
        fprintf(stderr,
            "pi4_status_evidence: pi4uabi=OK must not use pi4elfsrc=EMBEDDED\n");
        return 0;
    }
    return 1;
}

static int tuple_starts_with_exec_sysno(const char* value)
{
    size_t len = strlen(PI4_VIBE_SYS_EXEC_HEX);

    return strncmp(value, PI4_VIBE_SYS_EXEC_HEX, len) == 0 &&
        (value[len] == '/' || value[len] == '\0');
}

static int reject_field_for_gate(const Field* fields, size_t count, const char* gate, const char* key)
{
    if (find_value(fields, count, key)) {
        fprintf(stderr, "pi4_status_evidence: %s=WAIT must not include %s=\n", gate, key);
        return 0;
    }
    return 1;
}

static int reject_fields_for_gate(const Field* fields, size_t count, const char* gate,
    const char* const* keys, size_t key_count)
{
    int ok = 1;
    size_t i = 0;

    for (i = 0; i < key_count; i++)
        ok = reject_field_for_gate(fields, count, gate, keys[i]) && ok;

    return ok;
}

static int require_fields(const Field* fields, size_t count, const char* const* keys,
    size_t key_count)
{
    int ok = 1;
    size_t i = 0;

    for (i = 0; i < key_count; i++)
        ok = require_field(fields, count, keys[i]) && ok;

    return ok;
}

static int check_input_status(const Field* fields, size_t count)
{
    int ok = 1;

    ok = require_value(fields, count, "pi4input", "UART") && ok;
    ok = require_value(fields, count, "pi4usb", "WAIT") && ok;
    ok = require_nonzero_hex_field(fields, count, "pi4inputdev") && ok;
    ok = require_field(fields, count, "pi4inputq") && ok;
    ok = require_field(fields, count, "pi4inputlast") && ok;
    ok = reject_field_for_gate(fields, count, "pi4usb", "pi4usbdev") && ok;
    ok = reject_field_for_gate(fields, count, "pi4usb", "pi4usbq") && ok;
    return ok;
}

static int check_audio_status(const Field* fields, size_t count)
{
    static const char* const audio_hardware_fields[] = {
        "pi4audiodev",
        "pi4audiofmt",
        "pi4audiorate",
        "pi4audiocount",
    };
    const char* audio = find_value(fields, count, "pi4audio");
    const char* audiohw = find_value(fields, count, "pi4audiohw");
    const char* audiommio = find_value(fields, count, "pi4audiommio");
    const char* audiomailbox = find_value(fields, count, "pi4audiomailbox");
    const char* audiocap = find_value(fields, count, "pi4audiocap");
    const char* audioq = find_value(fields, count, "pi4audioq");
    const char* audioabi = find_value(fields, count, "pi4audioabi");
    int ok = 1;

    if (!audio) {
        fprintf(stderr, "pi4_status_evidence: missing pi4audio=<value>\n");
        ok = 0;
    }
    if (!audiohw) {
        fprintf(stderr, "pi4_status_evidence: missing pi4audiohw=<value>\n");
        ok = 0;
    }
    if (!audiommio) {
        fprintf(stderr, "pi4_status_evidence: missing pi4audiommio=<value>\n");
        ok = 0;
    }
    if (!audiomailbox) {
        fprintf(stderr, "pi4_status_evidence: missing pi4audiomailbox=<value>\n");
        ok = 0;
    }
    if (!audiocap) {
        fprintf(stderr, "pi4_status_evidence: missing pi4audiocap=<value>\n");
        ok = 0;
    }
    if (!audioq) {
        fprintf(stderr, "pi4_status_evidence: missing pi4audioq=<value>\n");
        ok = 0;
    }
    if (!audioabi) {
        fprintf(stderr, "pi4_status_evidence: missing pi4audioabi=<value>\n");
        ok = 0;
    }
    if (!ok)
        return 0;

    if (strcmp(audio, "WAIT") == 0) {
        ok = require_value(fields, count, "pi4audiohw", "NONE") && ok;
        ok = require_value(fields, count, "pi4audiommio", "NONE") && ok;
        ok = require_value(fields, count, "pi4audiomailbox", "WAIT") && ok;
        ok = require_value(fields, count, "pi4audiocap", "NONE") && ok;
        ok = require_value(fields, count, "pi4audioq", "NONE") && ok;
        ok = require_value(fields, count, "pi4audioabi", "NONE") && ok;
        ok = reject_fields_for_gate(fields, count, "pi4audio", audio_hardware_fields,
                 ARRAY_COUNT(audio_hardware_fields)) &&
             ok;
        fprintf(stderr,
            "pi4_status_evidence: pi4audio=WAIT cannot satisfy real Pi 4 audio hardware proof\n");
        ok = 0;
        return ok;
    }

    if (strcmp(audio, "HARDWARE-UNPROVEN") == 0) {
        uint64_t mmio[4];
        uint64_t mailbox[4] = {0, 0, 0, 0};
        uint64_t cap[1];

        if (strcmp(audiohw, "PWM") != 0 && strcmp(audiohw, "PCM") != 0 &&
            strcmp(audiohw, "HDMI") != 0) {
            fprintf(stderr,
                "pi4_status_evidence: pi4audio=HARDWARE-UNPROVEN must name PWM, PCM, or HDMI audio hardware\n");
            ok = 0;
        }
        if (parse_hex64_tuple_exact(fields, count, "pi4audiommio", 4, mmio)) {
            if (mmio[0] == 0 || mmio[1] == 0 || mmio[2] == 0) {
                fprintf(stderr,
                    "pi4_status_evidence: pi4audio=HARDWARE-UNPROVEN must include the attempted MMIO audio window\n");
                ok = 0;
            }
        } else {
            ok = 0;
        }
        if (strcmp(audiomailbox, "WAIT") != 0 &&
            !parse_hex64_tuple_exact(fields, count, "pi4audiomailbox", 4, mailbox)) {
            ok = 0;
        }
        if (!parse_hex64_tuple_exact(fields, count, "pi4audiocap", 1, cap)) {
            ok = 0;
        } else if (cap[0] == 0 || (cap[0] & ~PI4_AUDIO_REQUIRED_CAPS) != 0 ||
                   (cap[0] & PI4_AUDIO_CAP_PCM_QUEUE) != 0) {
            fprintf(stderr,
                "pi4_status_evidence: pi4audio=HARDWARE-UNPROVEN may only expose partial MMIO/mailbox audio capability evidence\n");
            ok = 0;
        }
        if (mailbox[0] != 0 && (cap[0] & PI4_AUDIO_CAP_MAILBOX_CLOCK) == 0) {
            fprintf(stderr,
                "pi4_status_evidence: pi4audio=HARDWARE-UNPROVEN mailbox evidence must be reflected in pi4audiocap=\n");
            ok = 0;
        }
        ok = require_value(fields, count, "pi4audioq", "NONE") && ok;
        ok = require_value(fields, count, "pi4audioabi", "NONE") && ok;
        ok = reject_fields_for_gate(fields, count, "pi4audio", audio_hardware_fields,
                 ARRAY_COUNT(audio_hardware_fields)) &&
             ok;
        fprintf(stderr,
            "pi4_status_evidence: pi4audio=HARDWARE-UNPROVEN cannot satisfy real Pi 4 audio hardware proof\n");
        ok = 0;
        return ok;
    }

    if (strcmp(audio, "OK") == 0) {
        uint64_t mmio[4];
        uint64_t mailbox[4];
        uint64_t cap[1];
        uint64_t audioq_fields[4];
        uint64_t audioabi[4];
        int usb_audio = strcmp(audiohw, "USB-AUDIO") == 0;

        if (strcmp(audiohw, "PWM") != 0 && strcmp(audiohw, "PCM") != 0 &&
            strcmp(audiohw, "HDMI") != 0 && !usb_audio) {
            fprintf(stderr,
                "pi4_status_evidence: pi4audio=OK must name PWM, PCM, HDMI, or USB-AUDIO hardware\n");
            ok = 0;
        }
        if (parse_hex64_tuple_exact(fields, count, "pi4audiommio", 4, mmio)) {
            if (mmio[0] == 0 || mmio[1] == 0 || mmio[2] == 0 ||
                (!usb_audio && mmio[3] == 0)) {
                fprintf(stderr,
                    "pi4_status_evidence: pi4audio=OK must include nonzero pi4audiommio= hardware window evidence\n");
                ok = 0;
            }
        } else {
            ok = 0;
        }
        if (parse_hex64_tuple_exact(fields, count, "pi4audiomailbox", 4, mailbox)) {
            if (!usb_audio &&
                (mailbox[0] == 0 || mailbox[1] == 0 || mailbox[2] == 0 ||
                 mailbox[3] == 0)) {
                fprintf(stderr,
                    "pi4_status_evidence: pi4audio=OK must include nonzero pi4audiomailbox= capability evidence\n");
                ok = 0;
            }
        } else {
            ok = 0;
        }
        if (!parse_hex64_tuple_exact(fields, count, "pi4audiocap", 1, cap)) {
            ok = 0;
        } else if (usb_audio) {
            if ((cap[0] & PI4_AUDIO_USB_REQUIRED_CAPS) != PI4_AUDIO_USB_REQUIRED_CAPS ||
                (cap[0] & ~(PI4_AUDIO_REQUIRED_CAPS | PI4_AUDIO_CAP_USB_AUDIO)) != 0) {
                fprintf(stderr,
                    "pi4_status_evidence: pi4audio=OK USB-AUDIO must include USB audio plus PCM queue capability evidence\n");
                ok = 0;
            }
        } else if ((cap[0] & PI4_AUDIO_REQUIRED_CAPS) != PI4_AUDIO_REQUIRED_CAPS ||
                   (cap[0] & ~PI4_AUDIO_REQUIRED_CAPS) != 0) {
            fprintf(stderr,
                "pi4_status_evidence: pi4audio=OK must include exactly the Pi audio MMIO, mailbox-clock, and PCM-queue capability mask\n");
            ok = 0;
        }
        if (usb_audio) {
            uint64_t usb[8];
            if (parse_hex64_tuple_exact(fields, count, "pi4audiousb", 8, usb)) {
                if (usb[0] != 1 || usb[1] == 0 || usb[3] == 0 ||
                    usb[4] == 0 || usb[4] > 1024) {
                    fprintf(stderr,
                        "pi4_status_evidence: pi4audiousb= must expose a ready USB audio endpoint\n");
                    ok = 0;
                }
            } else {
                ok = 0;
            }
        }
        if (parse_hex64_tuple_exact(fields, count, "pi4audioq", 4, audioq_fields)) {
            if (audioq_fields[0] == 0 || audioq_fields[1] == 0 ||
                audioq_fields[1] > audioq_fields[0] || audioq_fields[2] == 0) {
                fprintf(stderr,
                    "pi4_status_evidence: pi4audio=OK must include bounded nonzero pi4audioq= bytes/usable/stream evidence\n");
                ok = 0;
            }
        } else {
            ok = 0;
        }
        if (parse_hex64_tuple_exact(fields, count, "pi4audioabi", 4, audioabi)) {
            if (audioabi[1] != PI4_AUDIO_ABI_FULL_MASK ||
                (audioabi[0] & PI4_AUDIO_ABI_FULL_MASK) != PI4_AUDIO_ABI_FULL_MASK ||
                (audioabi[0] & ~PI4_AUDIO_ABI_FULL_MASK) != 0 ||
                audioabi[2] == 0 || audioabi[3] == 0) {
                fprintf(stderr,
                    "pi4_status_evidence: pi4audio=OK must include the full Pi audio device, queue, and capability ABI mask\n");
                ok = 0;
            }
        } else {
            ok = 0;
        }
        return ok;
    }

    fprintf(stderr,
        "pi4_status_evidence: pi4audio= must be WAIT, HARDWARE-UNPROVEN, or OK, got %s\n",
        audio);
    return 0;
}

static int check_irq_status(const Field* fields, size_t count)
{
    const char* irq = find_value(fields, count, "pi4irq");
    if (!irq) {
        fprintf(stderr, "pi4_status_evidence: missing pi4irq=<value>\n");
        return 0;
    }

    if (strcmp(irq, "WAIT") == 0) {
        static const char* const irq_fields[] = {
            "irqctl",
            "pi4gic",
            "clocksrc",
            "clockhz",
            "clocktick",
            "clockirq",
            "ticks",
        };
        int ok = require_value(fields, count, "pi4timer", "WAIT");
        ok = reject_fields_for_gate(fields, count, "pi4irq", irq_fields, ARRAY_COUNT(irq_fields)) && ok;
        return ok;
    }

    if (strcmp(irq, "OK") == 0) {
        int ok = require_value(fields, count, "pi4timer", "OK");
        ok = require_value(fields, count, "irqctl", "GIC") && ok;
        ok = require_value(fields, count, "clocksrc", "ARMTMR") && ok;
        ok = require_field(fields, count, "pi4gic") && ok;
        ok = require_nonzero_hex_field(fields, count, "clockhz") && ok;
        ok = require_nonzero_hex_field(fields, count, "clocktick") && ok;
        ok = require_nonzero_hex_field(fields, count, "clockirq") && ok;
        ok = require_nonzero_hex_field(fields, count, "ticks") && ok;
        return ok;
    }

    fprintf(stderr, "pi4_status_evidence: pi4irq= must be WAIT or OK, got %s\n", irq);
    return 0;
}

static int check_preempt_context_skeleton(const Field* fields, size_t count, int require_switch)
{
    const int has_ctx = find_value(fields, count, "pi4ctx") != NULL;
    const int has_sched = find_value(fields, count, "pi4sched") != NULL;
    uint64_t ctx[9];
    uint64_t sched[6];
    uint64_t ptable[4];
    int ok = 1;

    if (!has_ctx && !has_sched) {
        if (require_switch) {
            fprintf(stderr,
                "pi4_status_evidence: pi4preempt=OK requires pi4ctx=/pi4sched= switch evidence\n");
            return 0;
        }
        return 1;
    }
    if (!has_ctx || !has_sched) {
        fprintf(stderr,
            "pi4_status_evidence: pi4ctx= and pi4sched= must be reported together\n");
        return 0;
    }

    ok = parse_hex64_tuple_exact(fields, count, "pi4ctx", 9, ctx) && ok;
    ok = parse_hex64_tuple_exact(fields, count, "pi4sched", 6, sched) && ok;
    ok = parse_hex64_tuple_exact(fields, count, "pi4ptable", 4, ptable) && ok;
    if (!ok)
        return 0;

    if (ctx[0] == 0 || ctx[1] != PI4_PROC_CONTEXT_BYTES ||
        ctx[2] != PI4_PROC_CONTEXT_VERSION || ctx[3] == 0 || ctx[4] == 0 ||
        ctx[5] == 0 || ctx[6] == 0 ||
        (ctx[8] & PI4_PROC_CONTEXT_REQUIRED_FLAGS) != PI4_PROC_CONTEXT_REQUIRED_FLAGS) {
        fprintf(stderr,
            "pi4_status_evidence: pi4ctx= must expose a nonzero assembly-owned EL0 process context skeleton\n");
        ok = 0;
    }
    if (ptable[0] == 0 || ptable[1] == 0 || ptable[2] < PI4_PROC_TABLE_ENTRY_BYTES ||
        ptable[3] > ptable[1]) {
        fprintf(stderr,
            "pi4_status_evidence: pi4ptable= must expose a bounded process table skeleton\n");
        ok = 0;
    }
    if (ctx[3] != sched[4] || sched[4] == 0 || sched[5] == 0) {
        fprintf(stderr,
            "pi4_status_evidence: pi4sched= must account the current process context PID\n");
        ok = 0;
    }
    if (sched[1] != sched[2] + sched[3]) {
        fprintf(stderr,
            "pi4_status_evidence: pi4sched= attempts must equal no-peer waits plus process switches\n");
        ok = 0;
    }
    {
        const char* irq = find_value(fields, count, "pi4irq");
        if (irq && strcmp(irq, "OK") == 0) {
            uint64_t ticks[1];
            if (!parse_hex64_tuple_exact(fields, count, "ticks", 1, ticks)) {
                ok = 0;
            } else if (sched[0] != ticks[0]) {
                fprintf(stderr,
                    "pi4_status_evidence: pi4sched= tick accounting must mirror ticks=\n");
                ok = 0;
            }
        } else if (sched[0] != 0 || sched[1] != 0 || sched[2] != 0 || sched[3] != 0) {
            fprintf(stderr,
                "pi4_status_evidence: pi4sched= must not claim timer accounting while pi4irq=WAIT\n");
            ok = 0;
        }
    }
    if (!require_switch) {
        if (sched[3] != 0) {
            fprintf(stderr,
                "pi4_status_evidence: pi4preempt=WAIT must keep pi4sched= process switches at zero\n");
            ok = 0;
        }
        return ok;
    }
    if (ptable[3] < 2 || sched[3] == 0) {
        fprintf(stderr,
            "pi4_status_evidence: pi4preempt=OK requires two process contexts and a nonzero switch count\n");
        ok = 0;
    }
    return ok;
}

static int check_preempt_status(const Field* fields, size_t count)
{
    static const char* const preempt_fields[] = {
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
    const char* preempt = find_value(fields, count, "pi4preempt");
    int ok = 1;

    if (!preempt) {
        fprintf(stderr, "pi4_status_evidence: missing pi4preempt=<value>\n");
        return 0;
    }

    if (strcmp(preempt, "WAIT") == 0) {
        ok = reject_fields_for_gate(fields, count, "pi4preempt", preempt_fields,
                 ARRAY_COUNT(preempt_fields)) &&
             ok;
        ok = check_preempt_context_skeleton(fields, count, 0) && ok;
        return ok;
    }

    if (strcmp(preempt, "OK") == 0) {
        uint64_t preempt_count[1];
        uint64_t irq_switches[1];
        uint64_t context_switches[1];
        uint64_t from_pid[1];
        uint64_t to_pid[1];

        ok = require_value(fields, count, "pi4irq", "OK") && ok;
        ok = require_value(fields, count, "pi4timer", "OK") && ok;
        ok = require_value(fields, count, "pi4uabi", "OK") && ok;
        ok = require_value(fields, count, "pi4mem", "OK") && ok;
        ok = require_value(fields, count, "pi4runtime", "OK") && ok;
        ok = require_nonzero_hex_field(fields, count, "ticks") && ok;
        ok = require_nonzero_hex_field(fields, count, "preempt") && ok;
        ok = require_nonzero_hex_field(fields, count, "pirq") && ok;
        ok = require_nonzero_hex_field(fields, count, "pctx") && ok;
        ok = require_nonzero_hex_field(fields, count, "pfrom") && ok;
        ok = require_nonzero_hex_field(fields, count, "pto") && ok;
        ok = parse_hex64_tuple_exact(fields, count, "preempt", 1, preempt_count) && ok;
        ok = parse_hex64_tuple_exact(fields, count, "pirq", 1, irq_switches) && ok;
        ok = parse_hex64_tuple_exact(fields, count, "pctx", 1, context_switches) && ok;
        ok = parse_hex64_tuple_exact(fields, count, "pfrom", 1, from_pid) && ok;
        ok = parse_hex64_tuple_exact(fields, count, "pto", 1, to_pid) && ok;
        if (!ok)
            return 0;
        if (preempt_count[0] == 0 || irq_switches[0] != preempt_count[0] ||
            context_switches[0] < preempt_count[0]) {
            fprintf(stderr,
                "pi4_status_evidence: pi4preempt=OK requires matching nonzero preempt=/pirq= and covering pctx=\n");
            ok = 0;
        }
        if (from_pid[0] == 0 || to_pid[0] == 0 || from_pid[0] == to_pid[0]) {
            fprintf(stderr,
                "pi4_status_evidence: pi4preempt=OK requires distinct pfrom=/pto= PIDs\n");
            ok = 0;
        }
        ok = check_preempt_context_skeleton(fields, count, 1) && ok;
        return ok;
    }

    fprintf(stderr, "pi4_status_evidence: pi4preempt= must be WAIT or OK, got %s\n",
        preempt);
    return 0;
}

static int check_mailbox_status(const Field* fields, size_t count)
{
    const char* mailbox = find_value(fields, count, "pi4mailbox");
    if (!mailbox) {
        fprintf(stderr, "pi4_status_evidence: missing pi4mailbox=<value>\n");
        return 0;
    }

    if (strcmp(mailbox, "WAIT") == 0)
        return reject_field_for_gate(fields, count, "pi4mailbox", "pi4fbmail");

    if (strcmp(mailbox, "OK") == 0)
        return require_field(fields, count, "pi4fbmail");

    fprintf(stderr, "pi4_status_evidence: pi4mailbox= must be WAIT or OK, got %s\n",
        mailbox);
    return 0;
}

static int check_sd_controller_status(const Field* fields, size_t count)
{
    const char* ctl = find_value(fields, count, "pi4sdctl");
    const char* regs_value = find_value(fields, count, "pi4sdregs");
    uint64_t regs[12];
    size_t i = 0;

    if (!ctl && !regs_value)
        return 1;
    if (!ctl || !regs_value) {
        fprintf(stderr,
            "pi4_status_evidence: Pi 4 SD controller evidence requires both pi4sdctl= and pi4sdregs=\n");
        return 0;
    }
    if (!parse_hex64_tuple_exact(fields, count, "pi4sdregs", 12, regs))
        return 0;

    if (strcmp(ctl, "WAIT") == 0 || strcmp(ctl, "ENOSYS") == 0) {
        if (regs[0] != 0 &&
            (regs[0] != PI4_EMMC2_LEGACY_BASE || regs[1] != PI4_EMMC2_ARM_BASE ||
             regs[2] < PI4_EMMC2_MIN_REG_SPAN)) {
            fprintf(stderr,
                "pi4_status_evidence: pi4sdregs= controller constants must identify the BCM2711 EMMC2 window\n");
            return 0;
        }
        for (i = 3; i < ARRAY_COUNT(regs); i++) {
            if (regs[i] != 0) {
                fprintf(stderr,
                    "pi4_status_evidence: pi4sdctl=%s must not include nonzero live controller register evidence\n",
                    ctl);
                return 0;
            }
        }
        return 1;
    }

    if (strcmp(ctl, "EMMC2") != 0) {
        fprintf(stderr,
            "pi4_status_evidence: pi4sdctl= must be WAIT, ENOSYS, or EMMC2, got %s\n",
            ctl);
        return 0;
    }
    if (regs[0] != PI4_EMMC2_LEGACY_BASE || regs[1] != PI4_EMMC2_ARM_BASE ||
        regs[2] < PI4_EMMC2_MIN_REG_SPAN) {
        fprintf(stderr,
            "pi4_status_evidence: pi4sdregs= must identify the BCM2711 EMMC2 bus/ARM register window\n");
        return 0;
    }
    return 1;
}

static int require_completed_block_read_status(const Field* fields, size_t count)
{
    const char* block = find_value(fields, count, "pi4blk");
    uint64_t req[6];
    uint64_t pio[10];
    uint64_t expected_command = 0;
    uint64_t expected_transfer = 0;
    uint64_t expected_pio_words = 0;
    int ok = 1;

    if (!block) {
        fprintf(stderr, "pi4_status_evidence: missing pi4blk=OK storage proof\n");
        return 0;
    }
    if (!status_word_equals(block, "OK", PI4_STORAGE_STATUS_SD_OK)) {
        fprintf(stderr, "pi4_status_evidence: pi4sd=OK requires pi4blk=OK media-read proof\n");
        ok = 0;
    }
    ok = parse_hex64_tuple_exact(fields, count, "pi4blkreq", 6, req) && ok;
    ok = parse_hex64_tuple_exact(fields, count, "pi4blkpio", 10, pio) && ok;
    if (!ok)
        return 0;

    if (req[1] == 0 || req[1] > req[3] || req[3] == 0 ||
        req[3] > PI4_BLOCK_READ_MAX_COUNT || req[2] == 0 ||
        req[4] != req[1] * PI4_BLOCK_READ_SECTOR_BYTES || req[5] != 0) {
        fprintf(stderr,
            "pi4_status_evidence: pi4blkreq= must prove a bounded completed 512-byte SD read\n");
        ok = 0;
    }
    expected_command = req[1] == 1 ? PI4_SDHCI_CMD17_READ_SINGLE : PI4_SDHCI_CMD18_READ_MULTI;
    expected_transfer = req[1] == 1 ? PI4_SDHCI_TRANSFER_READ_SINGLE : PI4_SDHCI_TRANSFER_READ_MULTI;
    expected_pio_words = req[1] * PI4_SDHCI_PIO_WORDS_PER_SECTOR;
    if (pio[0] != expected_command || pio[1] != expected_transfer ||
        pio[2] != req[0] || pio[3] != req[4] || pio[4] != req[1] ||
        pio[5] != expected_pio_words || pio[5] > UINT64_MAX / 4 ||
        pio[5] * 4 != pio[3] || pio[7] != 0) {
        fprintf(stderr,
            "pi4_status_evidence: pi4blkpio= must prove the matching SDHCI PIO read completed without error\n");
        ok = 0;
    }
    return ok;
}

static int check_storage_status(const Field* fields, size_t count)
{
    static const char* const all_storage_fields[] = {
        "pi4blk",
        "pi4blkreq",
        "pi4blkpio",
        "pi4mbr",
        "pi4bpb",
        "pi4root",
        "pi4kernel8",
        "pi4config",
        "pi4init",
        "pi4abiprobe",
        "pi4app0",
        "pi4app1",
        "pi4manifest",
        "pi4assets",
        "pi4wad",
        "pi4pak0",
    };
    static const char* const fat_storage_fields[] = {
        "pi4bpb",
        "pi4root",
        "pi4kernel8",
        "pi4config",
        "pi4init",
        "pi4abiprobe",
        "pi4app0",
        "pi4app1",
        "pi4manifest",
        "pi4assets",
        "pi4wad",
        "pi4pak0",
    };
    const char* sd = find_value(fields, count, "pi4sd");
    const char* fat = find_value(fields, count, "pi4fat");
    const char* vfs = find_value(fields, count, "pi4vfs");
    uint64_t mbr[6];
    uint64_t bpb[9];
    uint64_t root[4];
    int have_mbr = 0;
    int have_bpb = 0;
    int have_root = 0;
    uint64_t asset_coverage = 0;
    int ok = 1;

    if (!sd) {
        fprintf(stderr, "pi4_status_evidence: missing pi4sd=<value>\n");
        ok = 0;
    }
    if (!fat) {
        fprintf(stderr, "pi4_status_evidence: missing pi4fat=<value>\n");
        ok = 0;
    }
    if (!vfs) {
        fprintf(stderr, "pi4_status_evidence: missing pi4vfs=<value>\n");
        ok = 0;
    }
    if (!ok)
        return 0;

    ok = check_sd_controller_status(fields, count) && ok;

    if (strcmp(sd, "WAIT") == 0) {
        ok = reject_fields_for_gate(fields, count, "pi4sd", all_storage_fields,
                 ARRAY_COUNT(all_storage_fields)) &&
             ok;
        ok = reject_pi4_app_catalog_fields(fields, count, "pi4sd") && ok;
        if (strcmp(fat, "WAIT") != 0 || strcmp(vfs, "WAIT") != 0) {
            fprintf(stderr,
                "pi4_status_evidence: pi4sd=WAIT requires pi4fat=WAIT and pi4vfs=WAIT\n");
            ok = 0;
        }
        return ok;
    }

    if (strcmp(sd, "OK") != 0) {
        fprintf(stderr, "pi4_status_evidence: pi4sd= must be WAIT or OK, got %s\n", sd);
        return 0;
    }
    ok = require_completed_block_read_status(fields, count) && ok;

    have_mbr = parse_hex64_tuple_exact(fields, count, "pi4mbr", 6, mbr);
    ok = have_mbr && ok;
    if (have_mbr && (mbr[0] != 0xaa55 || mbr[3] == 0 ||
                     mbr[4] == 0 || mbr[5] == 0)) {
        fprintf(stderr,
            "pi4_status_evidence: pi4mbr= must prove MBR signature, partition type, LBA, and sector count\n");
        ok = 0;
    }

    if (strcmp(fat, "WAIT") == 0) {
        ok = reject_fields_for_gate(fields, count, "pi4fat", fat_storage_fields,
                 ARRAY_COUNT(fat_storage_fields)) &&
             ok;
        ok = reject_pi4_app_catalog_fields(fields, count, "pi4fat") && ok;
        if (strcmp(vfs, "WAIT") != 0) {
            fprintf(stderr, "pi4_status_evidence: pi4fat=WAIT requires pi4vfs=WAIT\n");
            ok = 0;
        }
        return ok;
    }

    if (strcmp(fat, "OK") != 0) {
        fprintf(stderr, "pi4_status_evidence: pi4fat= must be WAIT or OK, got %s\n", fat);
        return 0;
    }

    have_bpb = parse_hex64_tuple_exact(fields, count, "pi4bpb", 9, bpb);
    have_root = parse_hex64_tuple_exact(fields, count, "pi4root", 4, root);
    ok = have_bpb && ok;
    ok = have_root && ok;
    if (have_bpb && (bpb[0] != 0xaa55 || bpb[1] == 0 || bpb[2] == 0 ||
                        bpb[3] == 0 || bpb[4] == 0 || bpb[5] == 0 ||
                        bpb[6] == 0 || bpb[7] == 0 || bpb[8] == 0)) {
        fprintf(stderr,
            "pi4_status_evidence: pi4bpb= must prove BPB signature and FAT geometry\n");
        ok = 0;
    }
    if (have_root && (root[0] == 0 || root[1] == 0 || root[3] == 0)) {
        fprintf(stderr,
            "pi4_status_evidence: pi4root= must prove a nonzero FAT root scan span and data LBA\n");
        ok = 0;
    }
    ok = require_pi4_storage_root_artifact(fields, count, "pi4kernel8") && ok;
    ok = require_pi4_storage_root_artifact(fields, count, "pi4config") && ok;
    ok = require_pi4_storage_root_artifact(fields, count, "pi4abiprobe") && ok;
    if (have_mbr && have_bpb && have_root) {
        ok = require_pi4_storage_file_plan(fields, count, "pi4init", mbr, bpb, root) && ok;
        ok = require_pi4_app_catalog_evidence(fields, count, mbr, bpb, root) && ok;
        ok = require_pi4_storage_file_plan(fields, count, "pi4manifest", mbr, bpb, root) && ok;
        ok = require_pi4_storage_file_plan(fields, count, "pi4wad", mbr, bpb, root) && ok;
    } else {
        ok = 0;
    }
    if (require_pi4_storage_asset_summary(fields, count, &asset_coverage)) {
        if ((asset_coverage & PI4_STORAGE_ASSET_COVERAGE_PAK0) != 0) {
            if (have_mbr && have_bpb && have_root) {
                ok = require_pi4_storage_file_plan(fields, count, "pi4pak0", mbr, bpb, root) && ok;
            } else {
                ok = 0;
            }
        } else if (find_value(fields, count, "pi4pak0")) {
            fprintf(stderr,
                "pi4_status_evidence: pi4pak0= requires the pi4assets= PAK coverage bit\n");
            ok = 0;
        }
    } else {
        ok = 0;
    }

    if (strcmp(vfs, "WAIT") == 0 || strcmp(vfs, "OK") == 0)
        return ok;

    fprintf(stderr, "pi4_status_evidence: pi4vfs= must be WAIT or OK, got %s\n", vfs);
    return 0;
}

static int check_framebuffer_status(const Field* fields, size_t count)
{
    static const char* const fb_fields[] = {
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
    static const char* const fb_required_fields[] = {
        "fbgeom",
        "fbpresent",
        "fbdirty",
        "pi4fbmail",
        "fbabi",
    };
    const char* fb = find_value(fields, count, "pi4fb");
    int ok = 1;

    if (!fb) {
        fprintf(stderr, "pi4_status_evidence: missing pi4fb=<value>\n");
        return 0;
    }

    if (strcmp(fb, "WAIT") == 0) {
        ok = reject_fields_for_gate(fields, count, "pi4fb", fb_fields, ARRAY_COUNT(fb_fields));
        if (find_value(fields, count, "pi4fbmail"))
            ok = require_value(fields, count, "pi4mailbox", "OK") && ok;
        return ok;
    }

    if (strcmp(fb, "OK") == 0) {
        ok = require_value(fields, count, "pi4mailbox", "OK");
        ok = require_value(fields, count, "gfx", "OK") && ok;
        ok = require_value(fields, count, "fb", "PI4FB") && ok;
        ok = require_fields(fields, count, fb_required_fields, ARRAY_COUNT(fb_required_fields)) && ok;
        ok = require_tuple_nonzero_fields(fields, count, "pi4fbmail", 4, 3) && ok;
        ok = require_tuple_nonzero_fields(fields, count, "fbgeom", 4, 4) && ok;
        ok = require_tuple_nonzero_fields(fields, count, "fbpresent", 4, 4) && ok;
        ok = require_tuple_nonzero_fields(fields, count, "fbdirty", 5, 3) && ok;
        ok = require_tuple_nonzero_fields(fields, count, "fbabi", 4, 3) && ok;
        return ok;
    }

    fprintf(stderr, "pi4_status_evidence: pi4fb= must be WAIT or OK, got %s\n", fb);
    return 0;
}

static int check_runtime_status(const Field* fields, size_t count)
{
    static const char* const process_fields[] = {
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
    static const char* const process_required_fields[] = {
        "pi4elfentry",
        "pi4elfphdr",
        "pi4elfload",
        "uentry",
        "execsys",
        "pi4ustack",
        "execmap",
        "pstat",
        "procpool",
        "pidseq",
    };
    const char* uabi = find_value(fields, count, "pi4uabi");
    const char* runtime = find_value(fields, count, "pi4runtime");
    const char* mem = find_value(fields, count, "pi4mem");
    uint64_t ualloc[8];
    int ok = 1;

    if (!uabi) {
        fprintf(stderr, "pi4_status_evidence: missing pi4uabi=<value>\n");
        ok = 0;
    }
    if (!runtime) {
        fprintf(stderr, "pi4_status_evidence: missing pi4runtime=<value>\n");
        ok = 0;
    }
    if (!mem) {
        fprintf(stderr, "pi4_status_evidence: missing pi4mem=<value>\n");
        ok = 0;
    }
    if (!ok)
        return 0;

    ok = require_nonzero_hex_field(fields, count, "pi4kmap") && ok;
    ok = require_nonzero_hex_field(fields, count, "pi4stack") && ok;
    ok = require_nonzero_hex_field(fields, count, "pi4umem") && ok;
    if (parse_hex64_tuple_exact(fields, count, "pi4ualloc", 8, ualloc)) {
        if (ualloc[0] == 0 || ualloc[1] <= ualloc[0] || ualloc[2] != ualloc[1] - ualloc[0] ||
            ualloc[3] == 0 || ualloc[4] <= ualloc[3] || ualloc[5] != ualloc[4] - ualloc[3] ||
            ualloc[6] != PI4_EL0_ALLOC_REQUIRED_FLAGS ||
            ualloc[7] != PI4_EL0_ALLOC_BOOT_COUNT) {
            fprintf(stderr,
                "pi4_status_evidence: pi4ualloc= must expose bounded EL0 image and stack allocation\n");
            ok = 0;
        }
    } else {
        ok = 0;
    }
    ok = require_field(fields, count, "pi4fbmap") && ok;
    ok = require_tuple_nonzero_fields(fields, count, "pi4ptable", 4, 3) && ok;
    if (find_value(fields, count, "pi4fb") &&
        strcmp(find_value(fields, count, "pi4fb"), "OK") == 0)
        ok = require_nonzero_hex_field(fields, count, "pi4fbmap") && ok;

    if (strcmp(uabi, "WAIT") == 0 && strcmp(runtime, "WAIT") == 0 &&
        strcmp(mem, "WAIT") == 0) {
        ok = require_value(fields, count, "pi4elfsrc", "EMBEDDED");
        ok = require_field(fields, count, "pi4elfprobe") && ok;
        ok = reject_fields_for_gate(fields, count, "pi4runtime", process_fields,
                 ARRAY_COUNT(process_fields)) &&
             ok;
        return ok;
    }

    if (strcmp(uabi, "OK") == 0 &&
        (strcmp(runtime, "WAIT") == 0 || strcmp(runtime, "OK") == 0) &&
        strcmp(mem, "OK") == 0) {
        const char* path = find_value(fields, count, "path");
        const char* upath = find_value(fields, count, "upath");

        ok = require_non_embedded_elf_source(fields, count);
        ok = require_value(fields, count, "pi4elfsrc", "VFS") && ok;
        ok = require_value(fields, count, "exec", "OK") && ok;
        if (!path || !is_pi4_user_exec_path(path)) {
            fprintf(stderr,
                "pi4_status_evidence: path= must be /SYSTEM/INIT.ELF or an installed app executable\n");
            ok = 0;
        }
        ok = require_value(fields, count, "uexec", "OK") && ok;
        if (!upath || !path || strcmp(upath, path) != 0) {
            fprintf(stderr, "pi4_status_evidence: upath= must match path=\n");
            ok = 0;
        }
        ok = require_fields(fields, count, process_required_fields,
                 ARRAY_COUNT(process_required_fields)) &&
             ok;
        ok = require_nonzero_hex_field(fields, count, "pi4elfentry") && ok;
        ok = require_nonzero_hex_field(fields, count, "pi4elfphdr") && ok;
        ok = require_nonzero_hex_field(fields, count, "pi4elfload") && ok;
        ok = require_nonzero_hex_field(fields, count, "uentry") && ok;
        ok = require_nonzero_hex_field(fields, count, "execsys") && ok;
        ok = require_nonzero_hex_field(fields, count, "pi4ustack") && ok;
        ok = require_nonzero_hex_field(fields, count, "execmap") && ok;
        ok = require_tuple_nonzero_fields(fields, count, "pi4ptable", 4, 4) && ok;
        ok = require_nonzero_hex_field(fields, count, "pstat") && ok;
        ok = require_nonzero_hex_field(fields, count, "procpool") && ok;
        ok = require_tuple_nonzero_fields(fields, count, "pidseq", 2, 2) && ok;
        {
            uint64_t ptable[4];
            uint64_t pstat[16];
            uint64_t procpool[16];
            uint64_t pidseq[16];
            size_t pstat_count = 0;
            size_t procpool_count = 0;
            size_t pidseq_count = 0;

            ok = parse_hex64_tuple_exact(fields, count, "pi4ptable", 4, ptable) && ok;
            ok = parse_hex64_tuple_fields(fields, count, "pstat", pstat,
                     ARRAY_COUNT(pstat), &pstat_count) &&
                 ok;
            ok = parse_hex64_tuple_fields(fields, count, "procpool", procpool,
                     ARRAY_COUNT(procpool), &procpool_count) &&
                 ok;
            ok = parse_hex64_tuple_fields(fields, count, "pidseq", pidseq,
                     ARRAY_COUNT(pidseq), &pidseq_count) &&
                 ok;
            if (ok && pstat_count >= 6) {
                if (procpool_count < 2 || pidseq_count < 2 || pstat[2] != procpool[0] ||
                    pstat[0] != pidseq[0] || pstat[1] != pidseq[1]) {
                    fprintf(stderr,
                        "pi4_status_evidence: extended pstat= must match procpool= and pidseq= lifecycle counters\n");
                    ok = 0;
                }
                if (pstat[3] == 0 || pstat[4] > pstat[3] || pstat[5] > pstat[3]) {
                    fprintf(stderr,
                        "pi4_status_evidence: extended pstat= must bound EL0 launch, return, and exec-launch counts\n");
                    ok = 0;
                }
                if (find_value(fields, count, "pi4exec") &&
                    strcmp(find_value(fields, count, "pi4exec"), "WAIT") == 0 &&
                    pstat[5] != 0) {
                    fprintf(stderr,
                        "pi4_status_evidence: pi4exec=WAIT must not claim an app process launch in pstat=\n");
                    ok = 0;
                }
                if (find_value(fields, count, "pi4exec") &&
                    strcmp(find_value(fields, count, "pi4exec"), "OK") == 0 &&
                    (pstat[5] == 0 || ptable[3] < 2)) {
                    fprintf(stderr,
                        "pi4_status_evidence: pi4exec=OK requires app PID allocation in pstat=/pi4ptable=\n");
                    ok = 0;
                }
            }
        }
        ok = require_value(fields, count, "panic", "NONE") && ok;
        ok = require_value(fields, count, "shutdown", "NONE") && ok;
        return ok;
    }

    if (strcmp(uabi, "WAIT") != 0 && strcmp(uabi, "OK") != 0) {
        fprintf(stderr, "pi4_status_evidence: pi4uabi= must be WAIT or OK, got %s\n", uabi);
        ok = 0;
    }
    if (strcmp(runtime, "WAIT") != 0 && strcmp(runtime, "OK") != 0) {
        fprintf(stderr, "pi4_status_evidence: pi4runtime= must be WAIT or OK, got %s\n",
            runtime);
        ok = 0;
    }
    if (strcmp(mem, "WAIT") != 0 && strcmp(mem, "OK") != 0) {
        fprintf(stderr, "pi4_status_evidence: pi4mem= must be WAIT or OK, got %s\n", mem);
        ok = 0;
    }
    if (ok) {
        fprintf(stderr,
            "pi4_status_evidence: pi4uabi, pi4mem, and pi4runtime must not overclaim process memory\n");
    }
    return 0;
}

static int require_pi4_app_vfs_evidence(const Field* fields, size_t count)
{
    uint64_t appvfs[10];
    uint64_t app_file[8];
    uint64_t mbr[6];
    uint64_t bpb[9];
    uint64_t root[4];
    const char* path = find_value(fields, count, "path");
    char app_key[PI4_APP_RECORD_KEY_BYTES];
    uint64_t first_app_record = 0;
    size_t i = 0;
    int ok = 1;

    if (!path || !is_pi4_installed_app_path(path)) {
        fprintf(stderr,
            "pi4_status_evidence: path= must be an installed /APPS/.../APP.ELF executable for pi4appvfs=\n");
        ok = 0;
    }
    ok = require_value(fields, count, "pi4vfs", "OK") && ok;
    ok = parse_hex64_tuple_exact(fields, count, "pi4appvfs", 10, appvfs) && ok;
    ok = parse_hex64_tuple_exact(fields, count, "pi4mbr", 6, mbr) && ok;
    ok = parse_hex64_tuple_exact(fields, count, "pi4bpb", 9, bpb) && ok;
    ok = parse_hex64_tuple_exact(fields, count, "pi4root", 4, root) && ok;
    if (!ok)
        return 0;

    if (!pi4_status_has_installed_app_record(fields, count, appvfs[0], app_key,
            sizeof(app_key))) {
        fprintf(stderr,
            "pi4_status_evidence: pi4appvfs= app record must name a reported app catalog entry\n");
        return 0;
    }
    if (path && pi4_first_app_record_for_path(path, &first_app_record) &&
        appvfs[0] != first_app_record) {
        fprintf(stderr,
            "pi4_status_evidence: pi4appvfs= app record must match the first installed app path\n");
        return 0;
    }
    if (appvfs[1] != PI4_STORAGE_FILE_STATUS_OK) {
        fprintf(stderr,
            "pi4_status_evidence: pi4appvfs= must prove the selected installed app record was present in the Pi VFS\n");
        return 0;
    }

    if (!parse_hex64_tuple_exact(fields, count, app_key, 8, app_file))
        return 0;
    for (i = 0; i < ARRAY_COUNT(app_file); i++) {
        if (appvfs[i + 2] != app_file[i]) {
            fprintf(stderr,
                "pi4_status_evidence: pi4appvfs= must match the selected installed app record read plan\n");
            return 0;
        }
    }

    return require_pi4_storage_file_tuple("pi4appvfs", appvfs + 2, mbr, bpb, root);
}

static int check_exec_status(const Field* fields, size_t count)
{
    const char* exec = find_value(fields, count, "pi4exec");
    const char* request = find_value(fields, count, "pi4execreq");
    const char* path = find_value(fields, count, "path");
    const char* doom = find_value(fields, count, "doom");
    const char* quake = find_value(fields, count, "quake");
    int ok = 1;

    if (!exec) {
        if (request) {
            fprintf(stderr, "pi4_status_evidence: pi4execreq= requires pi4exec=\n");
            ok = 0;
        }
        if ((doom && strcmp(doom, "OK") == 0) || (quake && strcmp(quake, "OK") == 0)) {
            fprintf(stderr,
                "pi4_status_evidence: Pi first installed Doom/Quake app proof requires pi4exec=OK\n");
            ok = 0;
        }
        return ok;
    }

    if (!request) {
        fprintf(stderr, "pi4_status_evidence: missing pi4execreq=<value>\n");
        return 0;
    }

    if (strcmp(exec, "WAIT") == 0) {
        if (!tuple_starts_with_exec_sysno(request) && value_has_nonzero_hex_digit(request)) {
            fprintf(stderr,
                "pi4_status_evidence: pi4execreq= must start with the Pi exec syscall number\n");
            ok = 0;
        }
        if ((doom && strcmp(doom, "OK") == 0) || (quake && strcmp(quake, "OK") == 0)) {
            fprintf(stderr,
                "pi4_status_evidence: pi4exec=WAIT cannot prove first installed Doom/Quake app launch\n");
            ok = 0;
        }
        if (path && is_pi4_installed_app_path(path)) {
            fprintf(stderr,
                "pi4_status_evidence: pi4exec=WAIT cannot claim app exec path success\n");
            ok = 0;
        }
        return ok;
    }

    if (strcmp(exec, "OK") == 0) {
        if (!tuple_starts_with_exec_sysno(request)) {
            fprintf(stderr,
                "pi4_status_evidence: pi4exec=OK must prove the Pi exec syscall\n");
            ok = 0;
        }
        ok = require_value(fields, count, "pi4uabi", "OK") && ok;
        ok = require_value(fields, count, "pi4runtime", "OK") && ok;
        ok = require_value(fields, count, "pi4mem", "OK") && ok;
        ok = require_pi4_app_vfs_evidence(fields, count) && ok;
        ok = require_value(fields, count, "panic", "NONE") && ok;
        ok = require_value(fields, count, "shutdown", "NONE") && ok;
        return ok;
    }

    fprintf(stderr, "pi4_status_evidence: pi4exec= must be WAIT or OK, got %s\n", exec);
    return 0;
}

static int check_app_launch_claim(const Field* fields, size_t count)
{
    const char* claim = find_value(fields, count, "app_launch_claim");

    if (!claim)
        return 1;
    if (strcmp(claim, "none") == 0)
        return 1;

    fprintf(stderr,
        "pi4_status_evidence: app_launch_claim= must remain none until Pi app exec proof exists\n");
    return 0;
}

int main(int argc, char** argv)
{
    char* data = NULL;
    char* line = NULL;
    size_t size = 0;
    Field fields[MAX_FIELDS];
    size_t field_count = 0;
    int ok = 1;

    if (argc > 2) {
        usage(argv[0]);
        return 2;
    }

    data = read_input(argc == 2 ? argv[1] : NULL, &size);
    (void)size;
    line = select_status_parse_text(data);
    if (!line) {
        fprintf(stderr, "pi4_status_evidence: no vibe-status line found in serial capture\n");
        free(data);
        return 1;
    }

    if (!parse_fields(line, fields, &field_count)) {
        free(data);
        return 1;
    }

    ok = check_panic_fault_status(fields, field_count);
    ok = check_required_values(fields, field_count) && ok;
    ok = check_required_fields(fields, field_count) && ok;
    ok = check_capture_source(fields, field_count) && ok;
    ok = check_input_status(fields, field_count) && ok;
    ok = check_audio_status(fields, field_count) && ok;
    ok = check_irq_status(fields, field_count) && ok;
    ok = check_preempt_status(fields, field_count) && ok;
    ok = check_mailbox_status(fields, field_count) && ok;
    ok = check_storage_status(fields, field_count) && ok;
    ok = check_framebuffer_status(fields, field_count) && ok;
    ok = check_runtime_status(fields, field_count) && ok;
    ok = check_exec_status(fields, field_count) && ok;
    ok = check_app_launch_claim(fields, field_count) && ok;

    if (ok)
        printf("pi4_status_evidence: OK fields=%zu\n", field_count);

    free(data);
    return ok ? 0 : 1;
}
