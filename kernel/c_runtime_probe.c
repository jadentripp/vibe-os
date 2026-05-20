typedef unsigned int u32;
typedef unsigned char u8;

extern u32 libc_strlen(const char *s);
extern int libc_strcmp(const char *a, const char *b);
extern int libc_abs(int value);
extern int libc_idivmod(int numerator, int denominator, int *remainder);
extern void kprintf(const char *fmt, ...);

extern u8 wad_parse_status;
extern u32 wad_lump_count;
extern u32 playpal_offset;
extern u32 playpal_size;
extern u32 colormap_offset;
extern u32 colormap_size;

#define C_RUNTIME_MAGIC 0xC0DEF00Du

u32 c_runtime_self_test(void) {
    int remainder = -1;

    if (libc_strlen("doom") != 4) {
        return 1;
    }
    if (libc_strcmp("PLAYPAL", "PLAYPAL") != 0) {
        return 2;
    }
    if (libc_abs(-99) != 99) {
        return 3;
    }
    if (libc_idivmod(42, 5, &remainder) != 8 || remainder != 2) {
        return 4;
    }
    if (wad_parse_status != 1) {
        return 5;
    }
    if (wad_lump_count < 2) {
        return 6;
    }
    if (playpal_size != 10752 || colormap_size != 8704) {
        return 7;
    }
    if (playpal_offset == 0 || colormap_offset == 0) {
        return 8;
    }

    return C_RUNTIME_MAGIC;
}

void c_runtime_report(void) {
    u32 result = c_runtime_self_test();

    kprintf("compiled C probe: %s\r\n", result == C_RUNTIME_MAGIC ? "OK" : "FAIL");
    kprintf("C sees lumps=%u PLAYPAL=%u COLORMAP=%u\r\n", wad_lump_count, playpal_size, colormap_size);
    kprintf("C probe magic: %x\r\n", result);
}
