#include "vibe_os.h"

static inline int syscall3(unsigned int number, unsigned long arg0, unsigned long arg1, unsigned long arg2)
{
    unsigned int result;
    __asm__ volatile(
        "int $0x80"
        : "=a"(result)
        : "a"(number), "b"(arg0), "c"(arg1), "d"(arg2)
        : "memory");
    return (int)result;
}

static int streq(const char* left, const char* right)
{
    while (*left && *left == *right) {
        ++left;
        ++right;
    }
    return *left == *right;
}

static int write_all(int fd, const char* text)
{
    unsigned long length = 0;
    while (text[length])
        ++length;
    return syscall3(VIBE_SYS_WRITE, (unsigned long)fd, (unsigned long)text, length) == (int)length;
}

static int root_contains(const vibe_dirent_t* entries, int count, const char* name)
{
    for (int index = 0; index < count; ++index) {
        if (vibe_dirent_is_regular_file(&entries[index]) && streq(entries[index].name, name))
            return 1;
    }
    return 0;
}

int user_main(int argc, char** argv, char** envp)
{
    static vibe_dirent_t root_entries[16];
    static vibe_clock_time_t now;
    int pid = syscall3(VIBE_SYS_GETPID, 0, 0, 0);
    int root_count = syscall3(
        VIBE_SYS_LISTDIR,
        (unsigned long)"/",
        (unsigned long)root_entries,
        16);
    int clock_ok = syscall3(
        VIBE_SYS_CLOCK_GETTIME,
        VIBE_CLOCK_MONOTONIC,
        (unsigned long)&now,
        sizeof(now)) == 0;

    if (argc != 1 || !argv || !argv[0] || !streq(argv[0], "ABIPROBE.ELF"))
        return 10;
    if (argv[1] || !envp || envp[0])
        return 11;
    if (pid <= 0)
        return 12;
    if (!clock_ok || now.frequency_hz != VIBE_CLOCK_MONOTONIC_HZ)
        return 13;
    if (root_count <= 0)
        return 14;
    if (!root_contains(root_entries, root_count, "ABIPROBE.ELF"))
        return 15;
    if (!root_contains(root_entries, root_count, "USERPROB.ELF"))
        return 16;
    if (!root_contains(root_entries, root_count, "DOOM.ELF"))
        return 17;

    write_all(1, "abi probe ok\n");
    return 0;
}
