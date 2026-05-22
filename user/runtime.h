#ifndef VIBE_USER_RUNTIME_H
#define VIBE_USER_RUNTIME_H

#include "vibe_os.h"

struct stat;

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
    VIBE_USER_O_RDONLY = 0x0000u,
    VIBE_USER_O_WRONLY = 0x0001u,
    VIBE_USER_O_RDWR = 0x0002u,
    VIBE_USER_O_CREAT = 0x0100u,
    VIBE_USER_O_TRUNC = 0x0200u,
    VIBE_USER_O_APPEND = 0x0400u,
    VIBE_USER_O_CLOEXEC = 0x0800u,
    VIBE_USER_SEEK_SET = 0,
    VIBE_USER_SEEK_CUR = 1,
    VIBE_USER_SEEK_END = 2,
    VIBE_USER_F_GETFD = 1,
    VIBE_USER_F_SETFD = 2,
    VIBE_USER_FD_CLOEXEC = 1,
    VIBE_USER_SYS_DISPLAY_IOCTL = 22u,
};

enum {
    VIBE_USER_VM_CAP_FILE_PRIVATE_COPY = VIBE_VM_CAP_FILE_PRIVATE_COPY,
};

int vibe_user_syscall0(unsigned int number);
int vibe_user_syscall1(unsigned int number, unsigned long arg0);
int vibe_user_syscall2(unsigned int number, unsigned long arg0, unsigned long arg1);
int vibe_user_syscall3(unsigned int number, unsigned long arg0, unsigned long arg1, unsigned long arg2);
int vibe_user_syscall_errno(int raw_result, int fallback_errno);
int vibe_user_streq(const char* left, const char* right);
int vibe_user_write_all(int fd, const char* text);
int vibe_user_write_full(int fd, const void* buffer, unsigned long count, unsigned long* out_written);
int vibe_user_read_full(int fd, void* buffer, unsigned long count, unsigned long* out_read);
int vibe_user_read_exact(int fd, void* buffer, unsigned long count, unsigned long* out_read);
int vibe_user_sbrk(long increment, void** previous_break);
int vibe_user_open(const char* path, unsigned long flags, unsigned long mode);
int vibe_user_write(int fd, const void* buffer, unsigned long count);
int vibe_user_read(int fd, void* buffer, unsigned long count);
int vibe_user_lseek(int fd, long offset, unsigned long whence);
int vibe_user_pread(int fd, void* buffer, unsigned long count, long offset);
int vibe_user_pwrite(int fd, const void* buffer, unsigned long count, long offset);
int vibe_user_close(int fd);
int vibe_user_unlink(const char* path);
int vibe_user_stat(const char* path, struct stat* out);
int vibe_user_fstat(int fd, struct stat* out);
int vibe_user_ftruncate(int fd, long length);
int vibe_user_getpid(void);
int vibe_user_getppid(void);
void vibe_user_exit(int status);
int vibe_user_fork(void);
int vibe_user_waitpid(long pid, int* status, unsigned long options);
int vibe_user_waitpid_nohang_reap(long pid, int* status, unsigned long max_polls);
int vibe_user_dup(int oldfd);
int vibe_user_dup2(int oldfd, int newfd);
int vibe_user_dup3(int oldfd, int newfd, unsigned long flags);
int vibe_user_fcntl(int fd, int cmd, unsigned long arg);
int vibe_user_process_status(long pid, vibe_process_status_t* out);
int vibe_user_process_status_current(vibe_process_status_t* out);
int vibe_user_yield(void);
int vibe_user_sleep_ticks(unsigned long ticks);
int vibe_user_sleep_milliseconds(unsigned long milliseconds);
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
int vibe_user_clock_gettime(unsigned long clock_id, vibe_clock_time_t* out);
int vibe_user_clock_monotonic(vibe_clock_time_t* out);
unsigned long vibe_user_monotonic_milliseconds(void);
int vibe_user_poll_input(vibe_input_event_t* event);
int vibe_user_drain_input(vibe_input_event_t* events, unsigned long max_events);
int vibe_user_input_status(vibe_input_status_t* status);
int vibe_user_input_device_status(unsigned long device_id, vibe_input_device_status_t* status);
int vibe_user_fb_get_info(vibe_fb_info_t* info);
int vibe_user_fb_can_present_indexed(const vibe_fb_info_t* info, const vibe_present_indexed_t* present);
int vibe_user_present_indexed(const vibe_present_indexed_t* present);
int vibe_user_present_indexed_checked(const vibe_present_indexed_t* present);
int vibe_user_listdir(const char* path, vibe_dirent_t* entries, unsigned long max_entries);
int vibe_user_file_size(const char* path, unsigned long* out_size);
int vibe_user_file_read_at(
    const char* path,
    unsigned long offset,
    void* buffer,
    unsigned long count,
    unsigned long* out_read);
int vibe_user_file_write_at(
    const char* path,
    unsigned long offset,
    const void* buffer,
    unsigned long count,
    unsigned long* out_written);
int vibe_user_file_read_all(const char* path, void* buffer, unsigned long capacity, unsigned long* out_size);
int vibe_user_execv(const char* path, char* const argv[]);
void vibe_user_report_probe(unsigned long magic, unsigned long flags);

static inline int vibe_user_result_is_error(int raw_result)
{
    return raw_result < 0 && VIBE_SYSCALL_ERROR_NEGATIVE_ERRNO;
}

static inline int vibe_user_result_errno(int raw_result, int fallback_errno)
{
    if (!vibe_user_result_is_error(raw_result))
        return 0;
    if (raw_result < -1)
        return -raw_result;
    return fallback_errno > 0 ? fallback_errno : 5;
}

static inline int vibe_user_audio_device_start(void)
{
    return vibe_user_syscall3(VIBE_SYS_AUDIO, VIBE_AUDIO_DEVICE_START, 0, 0);
}

static inline int vibe_user_audio_device_shutdown(void)
{
    return vibe_user_syscall3(VIBE_SYS_AUDIO, VIBE_AUDIO_DEVICE_SHUTDOWN, 0, 0);
}

static inline int vibe_user_audio_device_info(vibe_audio_device_info_t* info)
{
    if (!info)
        return -22;
    return vibe_user_syscall3(
        VIBE_SYS_AUDIO,
        VIBE_AUDIO_DEVICE_INFO,
        (unsigned long)info,
        0);
}

static inline int vibe_user_audio_pcm_ring_info(vibe_audio_pcm_ring_info_t* info)
{
    if (!info)
        return -22;
    return vibe_user_syscall3(
        VIBE_SYS_AUDIO,
        VIBE_AUDIO_PCM_RING_INFO,
        (unsigned long)info,
        0);
}

static inline int vibe_user_audio_stream_info(unsigned long handle, vibe_audio_stream_info_t* info)
{
    if (!info)
        return -22;
    return vibe_user_syscall3(
        VIBE_SYS_AUDIO,
        VIBE_AUDIO_STREAM_INFO,
        handle,
        (unsigned long)info);
}

static inline int vibe_user_audio_pcm_open(const vibe_audio_pcm_desc_t* format)
{
    return vibe_user_syscall3(
        VIBE_SYS_AUDIO,
        VIBE_AUDIO_PCM_OPEN,
        0,
        (unsigned long)format);
}

static inline int vibe_user_audio_pcm_write(
    unsigned long handle,
    const vibe_audio_voice_desc_t* desc)
{
    if (!desc)
        return -22;
    return vibe_user_syscall3(
        VIBE_SYS_AUDIO,
        VIBE_AUDIO_PCM_WRITE,
        handle,
        (unsigned long)desc);
}

static inline int vibe_user_audio_pcm_write_desc(
    unsigned long handle,
    const vibe_audio_pcm_desc_t* desc)
{
    if (!desc)
        return -22;
    return vibe_user_syscall3(
        VIBE_SYS_AUDIO,
        VIBE_AUDIO_PCM_WRITE_DESC,
        handle,
        (unsigned long)desc);
}

static inline int vibe_user_audio_pcm_drain(unsigned long handle)
{
    if (!handle)
        return -22;
    return vibe_user_syscall3(VIBE_SYS_AUDIO, VIBE_AUDIO_PCM_DRAIN, handle, 0);
}

static inline int vibe_user_audio_pcm_close(unsigned long handle)
{
    if (!handle)
        return -22;
    return vibe_user_syscall3(VIBE_SYS_AUDIO, VIBE_AUDIO_PCM_CLOSE, handle, 0);
}

static inline int vibe_user_audio_stream_open(const vibe_audio_pcm_desc_t* format)
{
    return vibe_user_audio_pcm_open(format);
}

static inline int vibe_user_audio_stream_write(
    unsigned long handle,
    const vibe_audio_voice_desc_t* desc)
{
    return vibe_user_audio_pcm_write(handle, desc);
}

static inline int vibe_user_audio_stream_drain(unsigned long handle)
{
    return vibe_user_audio_pcm_drain(handle);
}

static inline int vibe_user_audio_stream_close(unsigned long handle)
{
    return vibe_user_audio_pcm_close(handle);
}

static inline int vibe_user_audio_pcm_buffered_bytes(unsigned long handle)
{
    return vibe_user_syscall3(VIBE_SYS_AUDIO, VIBE_AUDIO_PCM_BUFFERED_BYTES, handle, 0);
}

static inline int vibe_user_audio_pcm_pull_state(unsigned long handle)
{
    return vibe_user_syscall3(VIBE_SYS_AUDIO, VIBE_AUDIO_PCM_PULL_STATE, handle, 0);
}

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

    for (;;) {
        if (!argv[argc]) {
            if (argc == 0)
                return -22;
            if (out_argc)
                *out_argc = argc;
            return 0;
        }
        if (argc >= VIBE_EXEC_ARG_MAX)
            return -22;
        if (!vibe_user_bounded_string_ok(argv[argc], VIBE_EXEC_ARG_STR_MAX))
            return -22;
        ++argc;
    }

    return -22;
}

static inline int vibe_user_validate_exec_envp(char* const envp[], unsigned long* out_envc)
{
    unsigned long envc = 0;

    if (out_envc)
        *out_envc = 0;
    if (!envp)
        return 0;

    for (;;) {
        if (!envp[envc]) {
            if (out_envc)
                *out_envc = envc;
            return 0;
        }
        if (envc >= VIBE_EXEC_ENV_MAX)
            return -22;
        if (!vibe_user_bounded_string_ok(envp[envc], VIBE_EXEC_ENV_STR_MAX))
            return -22;
        ++envc;
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

static inline int vibe_user_execve_checked(const char* path, char* const argv[], char* const envp[])
{
    int result = vibe_user_validate_exec_argv(path, argv, 0);

    if (result < 0)
        return result;
    result = vibe_user_validate_exec_envp(envp, 0);
    if (result < 0)
        return result;
    return vibe_user_syscall3(VIBE_SYS_EXEC, (unsigned long)path, (unsigned long)argv, (unsigned long)envp);
}

static inline int vibe_user_execve(const char* path, char* const argv[], char* const envp[])
{
    return vibe_user_execve_checked(path, argv, envp);
}

#endif
