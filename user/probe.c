typedef unsigned int uint32_t;
typedef unsigned int size_t;

enum {
    SYS_USER_PROBE = 1,
    SYS_EXPECT_FAULT = 3,
    SYS_WRITE = 4,
    SYS_SBRK = 5,
    SYS_OPEN = 6,
    SYS_READ = 7,
    SYS_LSEEK = 8,
    SYS_PRESENT = 10,
};

enum {
    USER_PROBE_MAGIC = 0x13579BDFu,
    USER_FAULT_ADDR = 0x00010000u,
    PROBE_FLAG_WRITE = 0x01u,
    PROBE_FLAG_SBRK = 0x02u,
    PROBE_FLAG_OPEN = 0x04u,
    PROBE_FLAG_READ_IWAD = 0x08u,
    PROBE_FLAG_LSEEK = 0x10u,
    PROBE_FLAG_PRESENT = 0x20u,
};

enum {
    DOOM_FRAME_BYTES = 320u * 200u,
    DOOM_PALETTE_BYTES = 256u * 3u,
};

static inline int syscall3(uint32_t number, uint32_t arg0, uint32_t arg1, uint32_t arg2) {
    uint32_t result;
    __asm__ volatile(
        "int $0x80"
        : "=a"(result)
        : "a"(number), "b"(arg0), "c"(arg1), "d"(arg2)
        : "memory");
    return (int)result;
}

static int sys_write(int fd, const void *buffer, size_t length) {
    return syscall3(SYS_WRITE, (uint32_t)fd, (uint32_t)buffer, (uint32_t)length);
}

static void *sys_sbrk(size_t increment) {
    int result = syscall3(SYS_SBRK, (uint32_t)increment, 0, 0);
    return result < 0 ? (void *)0 : (void *)(uint32_t)result;
}

static int sys_open(const char *path) {
    return syscall3(SYS_OPEN, (uint32_t)path, 0, 0);
}

static int sys_read(int fd, void *buffer, size_t length) {
    return syscall3(SYS_READ, (uint32_t)fd, (uint32_t)buffer, (uint32_t)length);
}

static int sys_lseek(int fd, uint32_t offset, int whence) {
    return syscall3(SYS_LSEEK, (uint32_t)fd, offset, (uint32_t)whence);
}

static int sys_present(const void *frame, const void *palette) {
    return syscall3(SYS_PRESENT, (uint32_t)frame, (uint32_t)palette, 0);
}

static void sys_user_probe(uint32_t flags) {
    (void)syscall3(SYS_USER_PROBE, USER_PROBE_MAGIC, flags, 0);
}

static void sys_expect_fault(void) {
    (void)syscall3(SYS_EXPECT_FAULT, 0, 0, 0);
}

int user_main(void) {
    static char header[12];
    const char hello[] = "user C probe\n";
    const char wad_path[] = "DOOM1.WAD";
    uint32_t flags = 0;

    if (sys_write(1, hello, sizeof(hello) - 1) == (int)(sizeof(hello) - 1)) {
        flags |= PROBE_FLAG_WRITE;
    }

    void *heap = sys_sbrk(64);
    if (heap) {
        flags |= PROBE_FLAG_SBRK;
    }

    int wad = sys_open(wad_path);
    if (wad >= 0) {
        flags |= PROBE_FLAG_OPEN;
    }

    if (wad >= 0 && heap && sys_read(wad, header, sizeof(header)) == (int)sizeof(header)) {
        uint32_t magic = ((uint32_t)(unsigned char)header[0])
            | ((uint32_t)(unsigned char)header[1] << 8)
            | ((uint32_t)(unsigned char)header[2] << 16)
            | ((uint32_t)(unsigned char)header[3] << 24);
        if (magic == 0x44415749u) {
            flags |= PROBE_FLAG_READ_IWAD;
        }
    }

    if (wad >= 0 && sys_lseek(wad, 4, 0) == 4) {
        flags |= PROBE_FLAG_LSEEK;
    }

    unsigned char *video = sys_sbrk(DOOM_FRAME_BYTES + DOOM_PALETTE_BYTES);
    if (video) {
        unsigned char *frame = video;
        unsigned char *palette = video + DOOM_FRAME_BYTES;
        for (uint32_t i = 0; i < DOOM_FRAME_BYTES; ++i) {
            frame[i] = (unsigned char)i;
        }
        for (uint32_t i = 0; i < 256; ++i) {
            palette[i * 3 + 0] = (unsigned char)i;
            palette[i * 3 + 1] = (unsigned char)(255u - i);
            palette[i * 3 + 2] = (unsigned char)(i >> 1);
        }
        if (sys_present(frame, palette) == 0) {
            flags |= PROBE_FLAG_PRESENT;
        }
    }

    sys_user_probe(flags);
    sys_expect_fault();

    volatile uint32_t *fault = (volatile uint32_t *)USER_FAULT_ADDR;
    (void)*fault;
    return 1;
}
