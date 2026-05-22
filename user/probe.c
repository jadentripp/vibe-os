typedef unsigned int uint32_t;
typedef unsigned int size_t;
typedef int int32_t;

enum {
    SYS_USER_PROBE = 1,
    SYS_EXPECT_FAULT = 3,
    SYS_WRITE = 4,
    SYS_SBRK = 5,
    SYS_OPEN = 6,
    SYS_READ = 7,
    SYS_LSEEK = 8,
    SYS_PRESENT = 10,
    SYS_CLOSE = 12,
    SYS_EXEC = 16,
    SYS_STAT = 18,
    SYS_MMAP = 20,
    SYS_MUNMAP = 21,
    SYS_IOCTL = 22,
    SYS_FORK = 23,
    SYS_WAITPID = 24,
    SYS_GETPID = 25,
    SYS_FTRUNCATE = 27,
    SYS_LISTDIR = 30,
    SYS_DUP = 32,
    SYS_DUP2 = 33,
    SYS_DUP3 = 34,
    SYS_FCNTL = 35,
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
    PROBE_FLAG_WAIT_REAP = 0x2000u,
    PROBE_FLAG_FTRUNCATE = 0x4000u,
    PROBE_FLAG_SBRK_SHRINK = 0x8000u,
    PROBE_FLAG_LISTDIR = 0x10000u,
    PROBE_FLAG_DUP = 0x20000u,
    PROBE_FLAG_FCNTL = 0x40000u,
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
    VIBE_FB_CAP_PRESENT_INDEXED = 0x00000001u,
    VIBE_FB_CAP_PRESENT_RGB_PALETTE = 0x00000002u,
    VIBE_FB_CAP_FIXED_PRESENT_SIZE = 0x00000020u,
    VIBE_FB_FORMAT_INDEX8_RGB24 = 1u,
    WAIT_OPTION_WNOHANG = 0x1u,
    WAIT_PROOF_EXIT_STATUS = 0x2a,
    WAIT_PROOF_CHILD_PID = 3,
    O_RDWR = 0x0002u,
    O_CREAT = 0x0100u,
    O_TRUNC = 0x0200u,
    O_CLOEXEC = 0x0800u,
    F_GETFD = 1,
    F_SETFD = 2,
    FD_CLOEXEC = 1,
    DUP2_TARGET_FD = 8,
    DUP3_TARGET_FD = 9,
    SEEK_SET = 0,
    SEEK_END = 2,
    S_IFREG = 0100000u,
    S_IFDIR = 0040000u,
    ERRNO_EBADF = 9,
    ERRNO_EACCES = 13,
    ERRNO_ENOTDIR = 20,
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
    uint32_t scale;
    uint32_t view_x;
    uint32_t view_y;
    uint32_t view_width;
    uint32_t view_height;
    uint32_t policy;
    uint32_t dirty_x;
    uint32_t dirty_y;
    uint32_t dirty_width;
    uint32_t dirty_height;
    uint32_t dirty_count;
    uint32_t capabilities;
    uint32_t present_format;
    uint32_t max_present_width;
    uint32_t max_present_height;
};

struct vibe_present_indexed {
    const void *frame;
    const void *palette;
    uint32_t width;
    uint32_t height;
};

struct vibe_dirent {
    char name[16];
    uint32_t size;
    uint32_t mode;
    uint32_t first_cluster;
    uint32_t attributes;
};

struct stat {
    uint32_t st_dev;
    uint32_t st_ino;
    uint32_t st_mode;
    uint32_t st_nlink;
    uint32_t st_uid;
    uint32_t st_gid;
    uint32_t st_rdev;
    uint32_t st_size;
    uint32_t st_atime;
    uint32_t st_mtime;
    uint32_t st_ctime;
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

static void *sys_sbrk(int32_t increment) {
    int result = syscall3(SYS_SBRK, (uint32_t)increment, 0, 0);
    return result < 0 ? (void *)0 : (void *)(uint32_t)result;
}

static int sys_open(const char *path) {
    return syscall3(SYS_OPEN, (uint32_t)path, 0, 0);
}

static int sys_open_flags(const char *path, uint32_t flags) {
    return syscall3(SYS_OPEN, (uint32_t)path, flags, 0666);
}

static int sys_read(int fd, void *buffer, size_t length) {
    return syscall3(SYS_READ, (uint32_t)fd, (uint32_t)buffer, (uint32_t)length);
}

static int sys_lseek(int fd, uint32_t offset, int whence) {
    return syscall3(SYS_LSEEK, (uint32_t)fd, offset, (uint32_t)whence);
}

static int sys_close(int fd) {
    return syscall3(SYS_CLOSE, (uint32_t)fd, 0, 0);
}

static int sys_dup(int fd) {
    return syscall3(SYS_DUP, (uint32_t)fd, 0, 0);
}

static int sys_dup2(int oldfd, int newfd) {
    return syscall3(SYS_DUP2, (uint32_t)oldfd, (uint32_t)newfd, 0);
}

static int sys_dup3(int oldfd, int newfd, uint32_t flags) {
    return syscall3(SYS_DUP3, (uint32_t)oldfd, (uint32_t)newfd, flags);
}

static int sys_fcntl(int fd, int cmd, uint32_t arg) {
    return syscall3(SYS_FCNTL, (uint32_t)fd, (uint32_t)cmd, arg);
}

static int sys_stat(const char *path, struct stat *out) {
    return syscall3(SYS_STAT, (uint32_t)path, (uint32_t)out, 0);
}

static int sys_ftruncate(int fd, uint32_t length) {
    return syscall3(SYS_FTRUNCATE, (uint32_t)fd, length, 0);
}

static int sys_listdir(const char *path, struct vibe_dirent *entries, uint32_t max_entries) {
    return syscall3(SYS_LISTDIR, (uint32_t)path, (uint32_t)entries, max_entries);
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

static int sys_execve(const char *path, char *const argv[], char *const envp[]) {
    return syscall3(SYS_EXEC, (uint32_t)path, (uint32_t)argv, (uint32_t)envp);
}

static int sys_waitpid(uint32_t pid, int *status, uint32_t options) {
    return syscall3(SYS_WAITPID, pid, (uint32_t)status, options);
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
    static char readback[40];
    const char hello[] = "user C probe\n";
    const char wad_path[] = "DOOM1.WAD";
    const char abi_probe_path[] = "ABIPROBE.ELF";
    const char asset_dir_path[] = "/ASSETS";
    const char asset_readme_path[] = "/ASSETS/README.TXT";
    const char asset_deep_path[] = "/ASSETS/SUB/README.TXT";
    const char asset_payload[] = "vibe-os FAT16 one-level asset file\n";
    const char default_path[] = "DEFAULT.CFG";
    const char writable_payload[] = "persist-ok\n";
    char *abi_probe_argv[] = {(char *)abi_probe_path, (char *)0};
    char *abi_probe_envp[] = {(char *)"PROBE_LAUNCHER=USERPROB", (char *)"ABI_ENV=present", (char *)0};
    static struct vibe_fb_info fbinfo;
    static struct vibe_present_indexed present;
    static struct vibe_dirent root_entries[16];
    static struct vibe_dirent asset_entries[4];
    static struct stat statbuf;
    uint32_t flags = 0;
    int mmap_hole_ok = 0;
    int pid = syscall3(SYS_GETPID, 0, 0, 0);
    if (argc == 1
        && argv
        && argv[0]
        && probe_streq(argv[0], "USERPROB.ELF")
        && argv[1] == (char *)0
        && envp
        && envp[0] == (char *)0
        && pid > 0) {
        flags |= PROBE_FLAG_PROCESS_ABI;
    }

    if (sys_write(1, hello, sizeof(hello) - 1) == (int)(sizeof(hello) - 1)) {
        flags |= PROBE_FLAG_WRITE;
    }

    void *heap = sys_sbrk(64);
    if (heap) {
        flags |= PROBE_FLAG_SBRK;
    }

    unsigned char *trim = (unsigned char *)sys_sbrk(4096);
    if (trim
        && sys_sbrk(-4096) == trim + 4096
        && sys_write(1, trim + 4096, 1) == -ERRNO_EINVAL) {
        flags |= PROBE_FLAG_SBRK_SHRINK;
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

    if (wad >= 0 && sys_lseek(wad, 4, SEEK_SET) == 4) {
        flags |= PROBE_FLAG_LSEEK;
    }

    int root_count = sys_listdir("/", root_entries, 16);
    if (root_count > 0) {
        int saw_wad = 0;
        int saw_probe = 0;
        int saw_abi_probe = 0;
        int saw_assets = 0;
        for (int i = 0; i < root_count; ++i) {
            if (probe_streq(root_entries[i].name, "DOOM1.WAD")
                && root_entries[i].size > 4
                && (root_entries[i].mode & S_IFREG)
                && root_entries[i].first_cluster >= 2) {
                saw_wad = 1;
            }
            if (probe_streq(root_entries[i].name, "USERPROB.ELF")
                && root_entries[i].size > 4
                && (root_entries[i].mode & S_IFREG)
                && root_entries[i].first_cluster >= 2) {
                saw_probe = 1;
            }
            if (probe_streq(root_entries[i].name, abi_probe_path)
                && root_entries[i].size > 4
                && (root_entries[i].mode & S_IFREG)
                && root_entries[i].first_cluster >= 2) {
                saw_abi_probe = 1;
            }
            if (probe_streq(root_entries[i].name, "ASSETS")
                && (root_entries[i].mode & S_IFDIR)
                && root_entries[i].first_cluster >= 2) {
                saw_assets = 1;
            }
        }
        int asset_count = sys_listdir(asset_dir_path, asset_entries, 4);
        int asset_fd = sys_open(asset_readme_path);
        int asset_ok = asset_count > 0
            && probe_streq(asset_entries[0].name, "README.TXT")
            && (asset_entries[0].mode & S_IFREG)
            && asset_fd >= 0
            && sys_read(asset_fd, readback, sizeof(asset_payload) - 1) == (int)(sizeof(asset_payload) - 1)
            && probe_streq(readback, asset_payload)
            && sys_lseek(asset_fd, (uint32_t)-5, SEEK_END) == sizeof(asset_payload) - 6
            && sys_read(asset_fd, readback, 5) == 5
            && readback[0] == 'f'
            && readback[1] == 'i'
            && readback[2] == 'l'
            && readback[3] == 'e'
            && readback[4] == '\n'
            && sys_stat(asset_readme_path, &statbuf) == 0
            && statbuf.st_size == sizeof(asset_payload) - 1
            && (statbuf.st_mode & S_IFREG)
            && sys_stat(asset_dir_path, &statbuf) == 0
            && (statbuf.st_mode & S_IFDIR)
            && sys_open_flags(asset_readme_path, O_RDWR) == -ERRNO_EACCES
            && sys_listdir(asset_readme_path, asset_entries, 1) == -ERRNO_ENOTDIR
            && sys_open(asset_deep_path) == -ERRNO_EINVAL;
        if (asset_fd >= 0) {
            sys_close(asset_fd);
        }
        if (saw_wad && saw_probe && saw_abi_probe && saw_assets && asset_ok && sys_listdir("doom", root_entries, 1) == -ERRNO_EINVAL) {
            flags |= PROBE_FLAG_LISTDIR;
        }
    }

    int defaults = sys_open_flags(default_path, O_RDWR | O_CREAT | O_TRUNC);
    if (defaults >= 0
        && sys_write(defaults, writable_payload, sizeof(writable_payload) - 1) == (int)(sizeof(writable_payload) - 1)
        && sys_lseek(defaults, 0, SEEK_SET) == 0
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

    if (defaults >= 0
        && sys_ftruncate(defaults, 4) == 0
        && sys_lseek(defaults, (uint32_t)-2, SEEK_END) == 2
        && sys_read(defaults, readback, 2) == 2
        && readback[0] == 'r'
        && readback[1] == 's'
        && sys_ftruncate(defaults, 8) == 0
        && sys_lseek(defaults, 4, SEEK_SET) == 4
        && sys_read(defaults, readback, 4) == 4
        && readback[0] == 0
        && readback[1] == 0
        && readback[2] == 0
        && readback[3] == 0) {
        flags |= PROBE_FLAG_FTRUNCATE;
    }

    int dup_fd = -1;
    if (defaults >= 0) {
        int dup_ok = 0;
        if (sys_lseek(defaults, 0, SEEK_SET) == 0) {
            dup_fd = sys_dup(defaults);
            if (dup_fd >= 0
                && sys_read(dup_fd, readback, 4) == 4
                && readback[0] == 'p'
                && readback[1] == 'e'
                && readback[2] == 'r'
                && readback[3] == 's'
                && sys_read(defaults, readback, 4) == 4
                && readback[0] == 0
                && readback[1] == 0
                && readback[2] == 0
                && readback[3] == 0
                && sys_lseek(defaults, 0, SEEK_SET) == 0
                && sys_dup2(dup_fd, DUP2_TARGET_FD) == DUP2_TARGET_FD
                && sys_read(DUP2_TARGET_FD, readback, 4) == 4
                && readback[0] == 'p'
                && readback[1] == 'e'
                && readback[2] == 'r'
                && readback[3] == 's'
                && sys_read(defaults, readback, 4) == 4
                && readback[0] == 0
                && readback[1] == 0
                && readback[2] == 0
                && readback[3] == 0
                && sys_lseek(defaults, 0, SEEK_SET) == 0
                && sys_dup3(defaults, DUP3_TARGET_FD, O_CLOEXEC) == DUP3_TARGET_FD
                && sys_read(DUP3_TARGET_FD, readback, 4) == 4
                && readback[0] == 'p'
                && readback[1] == 'e'
                && readback[2] == 'r'
                && readback[3] == 's'
                && sys_read(defaults, readback, 4) == 4
                && readback[0] == 0
                && readback[1] == 0
                && readback[2] == 0
                && readback[3] == 0
                && sys_dup2(dup_fd, dup_fd) == dup_fd
                && sys_dup3(dup_fd, dup_fd, 0) == -ERRNO_EINVAL
                && syscall3(SYS_DUP, 99, 0, 0) == -ERRNO_EBADF) {
                dup_ok = 1;
            }
        }
        if (dup_fd >= 0) {
            sys_close(dup_fd);
        }
        sys_close(DUP2_TARGET_FD);
        if (dup_ok) {
            flags |= PROBE_FLAG_DUP;
        }
    }

    if (defaults >= 0
        && sys_fcntl(defaults, F_GETFD, 0) == 0
        && sys_fcntl(defaults, F_SETFD, FD_CLOEXEC) == 0
        && sys_fcntl(defaults, F_GETFD, 0) == FD_CLOEXEC
        && sys_fcntl(defaults, F_SETFD, 0) == 0
        && sys_fcntl(defaults, F_GETFD, 0) == 0
        && sys_fcntl(defaults, F_SETFD, FD_CLOEXEC | 0x10u) == -ERRNO_EINVAL
        && sys_fcntl(99, F_GETFD, 0) == -ERRNO_EBADF) {
        flags |= PROBE_FLAG_FCNTL;
    }

    unsigned char *hole = sys_mmap(8192, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS);
    if (hole) {
        hole[0] = 'x';
        hole[4096] = 'y';
        if (sys_munmap(hole, 4096) == 0
            && sys_write(1, hole, 1) == -ERRNO_EINVAL
            && sys_munmap(hole + 4096, 4096) == 0) {
            mmap_hole_ok = 1;
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
            && fbinfo.palette_bytes == DOOM_PALETTE_BYTES
            && fbinfo.max_present_width == 320
            && fbinfo.max_present_height == 200
            && fbinfo.present_format == VIBE_FB_FORMAT_INDEX8_RGB24
            && (fbinfo.capabilities & VIBE_FB_CAP_PRESENT_INDEXED)
            && (fbinfo.capabilities & VIBE_FB_CAP_PRESENT_RGB_PALETTE)
            && (fbinfo.capabilities & VIBE_FB_CAP_FIXED_PRESENT_SIZE)) {
            flags |= PROBE_FLAG_IOCTL_FBINFO;
        }
        present.frame = frame;
        present.palette = palette;
        present.width = 320;
        present.height = 200;
        if (sys_ioctl(VIBE_DISPLAY_FD, VIBE_IOCTL_PRESENT_INDEXED, &present) == 0) {
            flags |= PROBE_FLAG_IOCTL_PRESENT;
        }
        if (mmap_hole_ok && sys_munmap(video, DOOM_FRAME_BYTES + DOOM_PALETTE_BYTES) == 0) {
            flags |= PROBE_FLAG_MMAP;
        }
    }

    int wait_status = 0;
    if (sys_waitpid((uint32_t)-1, &wait_status, WAIT_OPTION_WNOHANG) == WAIT_PROOF_CHILD_PID
        && wait_status == WAIT_PROOF_EXIT_STATUS
        && sys_waitpid((uint32_t)-1, 0, WAIT_OPTION_WNOHANG) == -ERRNO_ECHILD) {
        flags |= PROBE_FLAG_FORK_WAIT;
        flags |= PROBE_FLAG_WAIT_REAP;
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

    return sys_execve(abi_probe_path, abi_probe_argv, abi_probe_envp) == 0 ? 0 : 1;
}
