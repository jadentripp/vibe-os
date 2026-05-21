#ifndef VIBE_USER_RUNTIME_H
#define VIBE_USER_RUNTIME_H

#include "vibe_os.h"

enum {
    VIBE_SYS_USER_PROBE = 1,
};

enum {
    VIBE_USER_MAP_SHARED = 0x1u,
    VIBE_USER_PROT_READ = 0x1u,
    VIBE_USER_PROT_WRITE = 0x2u,
    VIBE_USER_PROT_EXEC = 0x4u,
    VIBE_USER_MAP_PRIVATE = 0x2u,
    VIBE_USER_MAP_FIXED = 0x10u,
    VIBE_USER_MAP_ANONYMOUS = 0x20u,
    VIBE_USER_WNOHANG = 0x1u,
    VIBE_USER_O_CLOEXEC = 0x0800u,
    VIBE_USER_F_GETFD = 1,
    VIBE_USER_F_SETFD = 2,
    VIBE_USER_FD_CLOEXEC = 1,
};

enum {
    VIBE_USER_VM_CAP_FILE_PRIVATE_COPY = 0x00010000u,
};

int vibe_user_syscall3(unsigned int number, unsigned long arg0, unsigned long arg1, unsigned long arg2);
int vibe_user_syscall_errno(int raw_result, int fallback_errno);
int vibe_user_streq(const char* left, const char* right);
int vibe_user_write_all(int fd, const char* text);
int vibe_user_sbrk(long increment, void** previous_break);
int vibe_user_open(const char* path, unsigned long flags, unsigned long mode);
int vibe_user_read(int fd, void* buffer, unsigned long count);
int vibe_user_lseek(int fd, long offset, unsigned long whence);
int vibe_user_pread(int fd, void* buffer, unsigned long count, long offset);
int vibe_user_close(int fd);
int vibe_user_getpid(void);
void vibe_user_exit(int status);
int vibe_user_fork(void);
int vibe_user_waitpid(long pid, int* status, unsigned long options);
int vibe_user_waitpid_nohang_reap(long pid, int* status, unsigned long max_polls);
int vibe_user_dup(int oldfd);
int vibe_user_dup2(int oldfd, int newfd);
int vibe_user_dup3(int oldfd, int newfd, unsigned long flags);
int vibe_user_fcntl(int fd, int cmd, unsigned long arg);
int vibe_user_mmap(void** out, unsigned long length, unsigned long prot, unsigned long flags);
int vibe_user_mmap_anon(void** out, unsigned long length, unsigned long prot);
int vibe_user_mmap_file(
    void** out,
    unsigned long length,
    unsigned long prot,
    unsigned long flags,
    int fd,
    long offset);
int vibe_user_mmap_file_private(void** out, unsigned long length, unsigned long prot, int fd, long offset);
int vibe_user_munmap(void* addr, unsigned long length);
unsigned long vibe_user_heap_capabilities(void);
unsigned long vibe_user_vm_capabilities(void);
int vibe_user_clock_monotonic(vibe_clock_time_t* out);
int vibe_user_listdir(const char* path, vibe_dirent_t* entries, unsigned long max_entries);
int vibe_user_execv(const char* path, char* const argv[]);
void vibe_user_report_probe(unsigned long magic, unsigned long flags);

static inline int vibe_user_waitpid_nohang_reap_exact(long pid, int* status, unsigned long max_polls)
{
    unsigned long poll;
    int result;

    if (pid <= 0 || !max_polls)
        return -22;

    for (poll = 0; poll < max_polls; ++poll) {
        result = vibe_user_waitpid(pid, status, VIBE_USER_WNOHANG);
        if (result == pid)
            return result;
        if (result < 0)
            return result;
        if (result != 0)
            return -10;
    }

    return 0;
}

static inline int vibe_user_get_cloexec(int fd, int* out)
{
    int raw;

    if (!out)
        return -22;

    raw = vibe_user_fcntl(fd, VIBE_USER_F_GETFD, 0);
    if (raw < 0)
        return raw;

    *out = (raw & VIBE_USER_FD_CLOEXEC) ? 1 : 0;
    return 0;
}

static inline int vibe_user_set_cloexec(int fd, int enabled)
{
    return vibe_user_fcntl(
        fd,
        VIBE_USER_F_SETFD,
        enabled ? VIBE_USER_FD_CLOEXEC : 0);
}

static inline int vibe_user_dirent_name_eq(const vibe_dirent_t* entry, const char* name)
{
    return entry && name && vibe_user_streq(entry->name, name);
}

static inline int vibe_user_listdir_find(const char* path, const char* name, vibe_dirent_t* out)
{
    vibe_dirent_t entries[16];
    int count;
    int index;

    if (!path || !name)
        return -22;

    count = vibe_user_listdir(path, entries, 16);
    if (count < 0)
        return count;

    for (index = 0; index < count; ++index) {
        if (vibe_user_dirent_name_eq(&entries[index], name)) {
            if (out)
                *out = entries[index];
            return 1;
        }
    }

    return 0;
}

static inline int vibe_user_bounded_string_ok(const char* text, unsigned long max_bytes)
{
    unsigned long index;

    if (!text || !max_bytes)
        return 0;

    for (index = 0; index < max_bytes; ++index) {
        if (text[index] == 0)
            return index != 0;
    }

    return 0;
}

static inline int vibe_user_validate_exec_argv(const char* path, char* const argv[], unsigned long* out_argc)
{
    unsigned long argc = 0;

    if (out_argc)
        *out_argc = 0;
    if (!vibe_user_bounded_string_ok(path, VIBE_EXEC_PATH_MAX))
        return -22;

    if (!argv) {
        if (out_argc)
            *out_argc = 1;
        return 0;
    }

    while (argc < VIBE_EXEC_ARG_MAX) {
        if (!argv[argc]) {
            if (argc == 0)
                return -22;
            if (out_argc)
                *out_argc = argc;
            return 0;
        }
        if (!vibe_user_bounded_string_ok(argv[argc], VIBE_EXEC_ARG_STR_MAX))
            return -22;
        ++argc;
    }

    return -22;
}

static inline int vibe_user_execv_checked(const char* path, char* const argv[])
{
    int result = vibe_user_validate_exec_argv(path, argv, 0);

    if (result < 0)
        return result;
    return vibe_user_execv(path, argv);
}

static inline int vibe_user_execve(const char* path, char* const argv[], char* const envp[])
{
    if (envp && envp[0])
        return -38;
    return vibe_user_execv_checked(path, argv);
}

#endif
