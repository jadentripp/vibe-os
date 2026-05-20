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
    SYS_EXEC = 16,
    SYS_MMAP = 20,
    SYS_MUNMAP = 21,
    SYS_IOCTL = 22,
    SYS_FORK = 23,
    SYS_WAITPID = 24,
    SYS_GETPID = 25,
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
    PROBE_FLAG_WRITABLE_FILE = 0x40u,
    PROBE_FLAG_MMAP = 0x80u,
    PROBE_FLAG_IOCTL_FBINFO = 0x100u,
    PROBE_FLAG_IOCTL_PRESENT = 0x200u,
    PROBE_FLAG_FORK_WAIT = 0x400u,
    PROBE_FLAG_PROCESS_ABI = 0x800u,
    PROBE_FLAG_NEGATIVE_SYSCALLS = 0x1000u,
};

enum {
    DOOM_FRAME_BYTES = 320u * 200u,
    DOOM_PALETTE_BYTES = 256u * 3u,
    PROT_READ = 0x1u,
    PROT_WRITE = 0x2u,
    MAP_PRIVATE = 0x2u,
    MAP_ANONYMOUS = 0x20u,
    MAP_FIXED = 0x10u,
    VIBE_DISPLAY_FD = 1u,
    VIBE_IOCTL_FBINFO = 0x00005601u,
    VIBE_IOCTL_PRESENT_INDEXED = 0x00005602u,
    ERRNO_EINVAL = 22,
    ERRNO_ECHILD = 10,
    ERRNO_ENOSYS = 38,
};

struct vibe_fb_info {
    uint32_t width;
    uint32_t height;
    uint32_t pitch;
    uint32_t backend;
    uint32_t frame_bytes;
    uint32_t palette_bytes;
};

struct vibe_present_indexed {
    const void *frame;
    const void *palette;
    uint32_t width;
    uint32_t height;
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

static void *sys_mmap(size_t length, uint32_t prot, uint32_t flags) {
    uint32_t packed = ((flags & 0xffffu) << 16) | (prot & 0xffffu);
    int result = syscall3(SYS_MMAP, 0, (uint32_t)length, packed);
    return result < 0 ? (void *)0 : (void *)(uint32_t)result;
}

static int sys_munmap(void *addr, size_t length) {
    return syscall3(SYS_MUNMAP, (uint32_t)addr, (uint32_t)length, 0);
}

static int sys_ioctl(uint32_t fd, uint32_t request, void *arg) {
    return syscall3(SYS_IOCTL, fd, request, (uint32_t)arg);
}

static int sys_execv(const char *path, char *const argv[]) {
    return syscall3(SYS_EXEC, (uint32_t)path, (uint32_t)argv, 0);
}

static void sys_user_probe(uint32_t flags) {
    (void)syscall3(SYS_USER_PROBE, USER_PROBE_MAGIC, flags, 0);
}

static void sys_expect_fault(void *recovery) {
    (void)syscall3(SYS_EXPECT_FAULT, (uint32_t)recovery, 0, 0);
}

static void trigger_expected_fault(void) {
    __asm__ volatile(
        "movl %0, %%eax\n\t"
        "movl $1f, %%ebx\n\t"
        "xorl %%ecx, %%ecx\n\t"
        "xorl %%edx, %%edx\n\t"
        "int $0x80\n\t"
        "movl %1, %%eax\n\t"
        "movl (%%eax), %%eax\n\t"
        "1:\n\t"
        :
        : "i"(SYS_EXPECT_FAULT), "i"(USER_FAULT_ADDR)
        : "eax", "ebx", "ecx", "edx", "memory");
}

static int probe_streq(const char *left, const char *right) {
    while (*left && *left == *right) {
        ++left;
        ++right;
    }
    return *left == *right;
}

int user_main(int argc, char **argv, char **envp) {
    static char header[12];
    static char readback[12];
    const char hello[] = "user C probe\n";
    const char wad_path[] = "DOOM1.WAD";
    const char doom_path[] = "DOOM.ELF";
    const char default_path[] = "DEFAULT.CFG";
    const char writable_payload[] = "persist-ok\n";
    char *doom_argv[] = {(char *)doom_path, (char *)0};
    static struct vibe_fb_info fbinfo;
    static struct vibe_present_indexed present;
    uint32_t flags = 0;

    if (argc == 1
        && argv
        && argv[0]
        && probe_streq(argv[0], "USERPROB.ELF")
        && argv[1] == (char *)0
        && envp
        && envp[0] == (char *)0
        && syscall3(SYS_GETPID, 0, 0, 0) == 1) {
        flags |= PROBE_FLAG_PROCESS_ABI;
    }

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

    int defaults = sys_open(default_path);
    if (defaults >= 0
        && sys_write(defaults, writable_payload, sizeof(writable_payload) - 1) == (int)(sizeof(writable_payload) - 1)
        && sys_lseek(defaults, 0, 0) == 0
        && sys_read(defaults, readback, sizeof(writable_payload) - 1) == (int)(sizeof(writable_payload) - 1)) {
        int matches = 1;
        for (size_t i = 0; i < sizeof(writable_payload) - 1; ++i) {
            if (readback[i] != writable_payload[i]) {
                matches = 0;
            }
        }
        if (matches) {
            flags |= PROBE_FLAG_WRITABLE_FILE;
        }
    }

    unsigned char *video = sys_mmap(DOOM_FRAME_BYTES + DOOM_PALETTE_BYTES, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS);
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
        if (sys_ioctl(VIBE_DISPLAY_FD, VIBE_IOCTL_FBINFO, &fbinfo) == 0
            && fbinfo.frame_bytes == DOOM_FRAME_BYTES
            && fbinfo.palette_bytes == DOOM_PALETTE_BYTES) {
            flags |= PROBE_FLAG_IOCTL_FBINFO;
        }
        present.frame = frame;
        present.palette = palette;
        present.width = 320;
        present.height = 200;
        if (sys_ioctl(VIBE_DISPLAY_FD, VIBE_IOCTL_PRESENT_INDEXED, &present) == 0) {
            flags |= PROBE_FLAG_IOCTL_PRESENT;
        }
        if (sys_munmap(video, DOOM_FRAME_BYTES + DOOM_PALETTE_BYTES) == 0) {
            flags |= PROBE_FLAG_MMAP;
        }
    }

    if (syscall3(SYS_FORK, 0, 0, 0) == -ERRNO_ENOSYS
        && syscall3(SYS_WAITPID, (uint32_t)-1, 0, 0) == -ERRNO_ECHILD) {
        flags |= PROBE_FLAG_FORK_WAIT;
    }

    uint32_t mmap_flags = ((MAP_PRIVATE | MAP_ANONYMOUS) << 16) | (PROT_READ | PROT_WRITE);
    uint32_t mmap_fixed_flags = ((MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED) << 16) | (PROT_READ | PROT_WRITE);
    if (syscall3(0x7fffffffu, 0, 0, 0) == -ERRNO_ENOSYS
        && syscall3(SYS_MMAP, 0, 0, mmap_flags) == -ERRNO_EINVAL
        && syscall3(SYS_MMAP, 0, 4096, mmap_fixed_flags) == -ERRNO_EINVAL
        && syscall3(SYS_MUNMAP, 0, 4096, 0) == -ERRNO_EINVAL
        && syscall3(SYS_WAITPID, (uint32_t)-1, USER_FAULT_ADDR, 0) == -ERRNO_EINVAL) {
        flags |= PROBE_FLAG_NEGATIVE_SYSCALLS;
    }

    sys_user_probe(flags);
    trigger_expected_fault();

    return sys_execv(doom_path, doom_argv) == 0 ? 0 : 1;
}
