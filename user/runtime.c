#include "runtime.h"

#ifndef VIBE_USER_RUNTIME_HOST_TEST
int vibe_user_syscall3(unsigned int number, unsigned long arg0, unsigned long arg1, unsigned long arg2)
{
    unsigned int result;
    __asm__ volatile(
        "int $0x80"
        : "=a"(result)
        : "a"(number), "b"(arg0), "c"(arg1), "d"(arg2)
        : "memory");
    return (int)result;
}
#endif

int vibe_user_syscall_errno(int raw_result, int fallback_errno)
{
    if (raw_result >= 0)
        return 0;
    if (raw_result < -1)
        return -raw_result;
    return fallback_errno > 0 ? fallback_errno : 5;
}

int vibe_user_streq(const char* left, const char* right)
{
    while (*left && *left == *right) {
        ++left;
        ++right;
    }
    return *left == *right;
}

int vibe_user_write_all(int fd, const char* text)
{
    unsigned long length = 0;
    int raw;

    while (text[length])
        ++length;

    raw = vibe_user_syscall3(VIBE_SYS_WRITE, (unsigned long)fd, (unsigned long)text, length);
    return raw == (int)length ? 0 : -vibe_user_syscall_errno(raw, 5);
}

int vibe_user_getpid(void)
{
    return vibe_user_syscall3(VIBE_SYS_GETPID, 0, 0, 0);
}

int vibe_user_clock_monotonic(vibe_clock_time_t* out)
{
    return vibe_user_syscall3(
        VIBE_SYS_CLOCK_GETTIME,
        VIBE_CLOCK_MONOTONIC,
        (unsigned long)out,
        sizeof(*out));
}

int vibe_user_listdir(const char* path, vibe_dirent_t* entries, unsigned long max_entries)
{
    return vibe_user_syscall3(
        VIBE_SYS_LISTDIR,
        (unsigned long)path,
        (unsigned long)entries,
        max_entries);
}

int vibe_user_execv(const char* path, char* const argv[])
{
    return vibe_user_syscall3(VIBE_SYS_EXEC, (unsigned long)path, (unsigned long)argv, 0);
}

void vibe_user_report_probe(unsigned long magic, unsigned long flags)
{
    (void)vibe_user_syscall3(VIBE_SYS_USER_PROBE, magic, flags, 0);
}
