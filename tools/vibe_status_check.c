#include <ctype.h>
#include <errno.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_FIELDS 768
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
#define PAGING_DIR_ADDR 0x00090000u
#define PROC_DOOM_PAGE_DIR_ADDR 0x00082000u
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
#define USER_KIND_DOOM 2u
#define USER_KIND_PREEMPT_PROBE 3u
#define USER_CODE_SEG 0x1Bu
#define USER_DATA_SEG 0x23u
#define DOOM_USER_BASE 0x01000000u
#define DOOM_USER_STACK_TOP 0x02000000u
#define PROBE_USER_BASE 0x00E80000u
#define PROBE_USER_END 0x00F00000u
#define SCHEDULER_QUANTUM_TICKS 5u
#define SYSCALL_RETURN_EFLAGS_SET 0x00000202u
#define SYSCALL_RETURN_EFLAGS_KEEP_MASK 0xFFF88AFFu
#define SYS_EXEC_ARGV_SOURCE_USER 2u

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
           cr3 == PROC_DOOM_PAGE_DIR_ADDR ||
           cr3 == PROC_PREEMPT_PAGE_DIR_ADDR ||
           cr3 == PROC_GENERIC0_PAGE_DIR_ADDR ||
           cr3 == PROC_GENERIC1_PAGE_DIR_ADDR;
}

static void validate_clock(const Status *status) {
    if (!has_field(status, "clocksrc")) {
        return;
    }
    exact(status, "clocksrc", "PIT");
    if (has_field(status, "ticks") && has_field(status, "dtick")) {
        uint32_t ticks = hex_field(status, "ticks");
        uint32_t dtick = hex_field(status, "dtick");
        if (ticks == 0u) {
            fail("ticks= must be nonzero");
        }
        if (dtick != (ticks * 35u) / 100u) {
            fail("dtick= must derive Doom 35 Hz time from the generic 100 Hz clock");
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
    if (kind == USER_KIND_DOOM) {
        return addr >= DOOM_USER_BASE && addr < DOOM_USER_STACK_TOP;
    }
    if (kind == USER_KIND_PREEMPT_PROBE) {
        return addr >= PROBE_USER_BASE && addr < PROBE_USER_END;
    }
    return 0;
}

static void validate_exec(const Status *status) {
    exact(status, "exec", "OK");
    exact(status, "uexec", "OK");
    exact(status, "upath", "USERPROB.ELF");
    exact(status, "abiexec", "OK");
    exact(status, "abipath", "ABIPROBE.ELF");
    exact(status, "abiprobe", "OK");
    exact(status, "doom", "OK");
    if (hex_field(status, "argvsrc") != SYS_EXEC_ARGV_SOURCE_USER) {
        fail("argvsrc= must prove exec argv came from user memory");
    }
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
        fail("pmask= must prove Doom and the preempt probe both ran");
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
    if (!((kinds[0] == USER_KIND_DOOM && kinds[1] == USER_KIND_PREEMPT_PROBE) ||
          (kinds[0] == USER_KIND_PREEMPT_PROBE && kinds[1] == USER_KIND_DOOM))) {
        fail("pkind= must switch between Doom and the preempt probe");
    }
    hex_tuple(status, "peip", 2, ':', eips);
    if (!addr_matches_kind(kinds[0], eips[0]) || !addr_matches_kind(kinds[1], eips[1])) {
        fail("peip= must contain user EIPs matching pkind=");
    }
    hex_tuple(status, "pcr3", 2, ':', cr3s);
    if (kinds[0] == USER_KIND_DOOM && cr3s[0] != PROC_DOOM_PAGE_DIR_ADDR) {
        fail("pcr3= Doom slot must use the Doom page directory");
    }
    if (kinds[1] == USER_KIND_DOOM && cr3s[1] != PROC_DOOM_PAGE_DIR_ADDR) {
        fail("pcr3= Doom slot must use the Doom page directory");
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
        !user_eflags_sanitized(eflags[2]) ||
        eflags[4] == 0u ||
        eflags[3] > preempt + user_irq_ticks) {
        fail("peflags= must prove sanitized EFLAGS and the dirty-frame self-test");
    }
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
    forbid_contains(".github/workflows/os-smoke.yml", "check_vm_status_proof");

    require_contains(".github/workflows/real-wad-smoke.yml", "tools/vibe_status_check.c");
    require_contains(".github/workflows/real-wad-smoke.yml", "--require-preempt");
    forbid_contains(".github/workflows/real-wad-smoke.yml", "check_vm_status_proof");

    require_contains(".github/workflows/real-wad-soak.yml", "tools/vibe_status_check.c");
    require_contains(".github/workflows/real-wad-soak.yml", "--require-preempt");
    forbid_contains(".github/workflows/real-wad-soak.yml", "check_vm_status_proof");

    require_contains("README.md", "small C tools");
    require_contains("docs/architecture.txt", "tools/vibe_status_check");
    require_contains("docs/proof.txt", "tools/vibe_status_check");
    require_contains("tests/strategy.txt", "tools/vibe_status_check");
}

static void usage(FILE *stream) {
    fprintf(stream,
            "usage: tools/vibe_status_check [--repo-contract] [--require-exec] [--require-preempt] status.txt...\n"
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
