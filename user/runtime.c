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

int vibe_user_sbrk(long increment, void** previous_break)
{
    int raw;

    if (!previous_break)
        return -22;

    raw = vibe_user_syscall3(VIBE_SYS_SBRK, (unsigned long)increment, 0, 0);
    if (raw < 0)
        return -vibe_user_syscall_errno(raw, 12);

    *previous_break = (void*)(unsigned long)raw;
    return 0;
}

int vibe_user_open(const char* path, unsigned long flags, unsigned long mode)
{
    return vibe_user_syscall3(VIBE_SYS_OPEN, (unsigned long)path, flags, mode);
}

int vibe_user_read(int fd, void* buffer, unsigned long count)
{
    if (!buffer && count)
        return -22;
    return vibe_user_syscall3(VIBE_SYS_READ, (unsigned long)fd, (unsigned long)buffer, count);
}

int vibe_user_lseek(int fd, long offset, unsigned long whence)
{
    return vibe_user_syscall3(VIBE_SYS_LSEEK, (unsigned long)fd, (unsigned long)offset, whence);
}

int vibe_user_pread(int fd, void* buffer, unsigned long count, long offset)
{
    int original;
    int result;
    int restore;

    if (offset < 0 || (!buffer && count))
        return -22;

    original = vibe_user_lseek(fd, 0, 1);
    if (original < 0)
        return original;

    result = vibe_user_lseek(fd, offset, 0);
    if (result < 0) {
        (void)vibe_user_lseek(fd, original, 0);
        return result;
    }

    result = vibe_user_read(fd, buffer, count);
    restore = vibe_user_lseek(fd, original, 0);
    if (restore < 0 && result >= 0)
        return restore;
    return result;
}

int vibe_user_close(int fd)
{
    return vibe_user_syscall3(VIBE_SYS_CLOSE, (unsigned long)fd, 0, 0);
}

int vibe_user_getpid(void)
{
    return vibe_user_syscall3(VIBE_SYS_GETPID, 0, 0, 0);
}

int vibe_user_fork(void)
{
    return vibe_user_syscall3(VIBE_SYS_FORK, 0, 0, 0);
}

int vibe_user_waitpid(long pid, int* status, unsigned long options)
{
    return vibe_user_syscall3(VIBE_SYS_WAITPID, (unsigned long)pid, (unsigned long)status, options);
}

int vibe_user_dup(int oldfd)
{
    return vibe_user_syscall3(VIBE_SYS_DUP, (unsigned long)oldfd, 0, 0);
}

int vibe_user_dup2(int oldfd, int newfd)
{
    return vibe_user_syscall3(VIBE_SYS_DUP2, (unsigned long)oldfd, (unsigned long)newfd, 0);
}

int vibe_user_dup3(int oldfd, int newfd, unsigned long flags)
{
    return vibe_user_syscall3(VIBE_SYS_DUP3, (unsigned long)oldfd, (unsigned long)newfd, flags);
}

int vibe_user_fcntl(int fd, int cmd, unsigned long arg)
{
    return vibe_user_syscall3(VIBE_SYS_FCNTL, (unsigned long)fd, (unsigned long)cmd, arg);
}

int vibe_user_mmap(void** out, unsigned long length, unsigned long prot, unsigned long flags)
{
    unsigned long packed;
    int raw;

    if (!out || !length)
        return -22;

    packed = ((flags & 0xffffu) << 16) | (prot & 0xffffu);
    raw = vibe_user_syscall3(VIBE_SYS_MMAP, 0, length, packed);
    if (raw < 0)
        return -vibe_user_syscall_errno(raw, 12);

    *out = (void*)(unsigned long)raw;
    return 0;
}

int vibe_user_mmap_anon(void** out, unsigned long length, unsigned long prot)
{
    return vibe_user_mmap(
        out,
        length,
        prot,
        VIBE_USER_MAP_PRIVATE | VIBE_USER_MAP_ANONYMOUS);
}

int vibe_user_munmap(void* addr, unsigned long length)
{
    if (!addr || !length)
        return -22;
    return vibe_user_syscall3(VIBE_SYS_MUNMAP, (unsigned long)addr, length, 0);
}

unsigned long vibe_user_heap_capabilities(void)
{
    return VIBE_HEAP_CAP_SBRK_GROW | VIBE_HEAP_CAP_SBRK_SHRINK;
}

unsigned long vibe_user_vm_capabilities(void)
{
    return VIBE_VM_CAP_ANON_PRIVATE
        | VIBE_VM_CAP_BRK_BACKED
        | VIBE_VM_CAP_TAIL_MUNMAP_RECLAIM
        | VIBE_VM_CAP_NONTAIL_MUNMAP_HOLES;
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
