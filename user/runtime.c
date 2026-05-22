#include "runtime.h"
#include "sys/stat.h"

#define VIBE_USER_LONG_MAX_32 0x7ffffffful

#ifndef VIBE_USER_RUNTIME_HOST_TEST
extern int __vibe_syscall0(unsigned int number);
extern int __vibe_syscall1(unsigned int number, unsigned long arg0);
extern int __vibe_syscall2(unsigned int number, unsigned long arg0, unsigned long arg1);
extern int __vibe_syscall3(unsigned int number, unsigned long arg0, unsigned long arg1, unsigned long arg2);

int vibe_user_syscall0(unsigned int number)
{
    /* int $0x80 ABI lives in user/crt0.asm so EBX and DF handling stay central. */
    return __vibe_syscall0(number);
}

int vibe_user_syscall1(unsigned int number, unsigned long arg0)
{
    return __vibe_syscall1(number, arg0);
}

int vibe_user_syscall2(unsigned int number, unsigned long arg0, unsigned long arg1)
{
    return __vibe_syscall2(number, arg0, arg1);
}

int vibe_user_syscall3(unsigned int number, unsigned long arg0, unsigned long arg1, unsigned long arg2)
{
    return __vibe_syscall3(number, arg0, arg1, arg2);
}
#else
int vibe_user_syscall0(unsigned int number)
{
    return vibe_user_syscall3(number, 0, 0, 0);
}

int vibe_user_syscall1(unsigned int number, unsigned long arg0)
{
    return vibe_user_syscall3(number, arg0, 0, 0);
}

int vibe_user_syscall2(unsigned int number, unsigned long arg0, unsigned long arg1)
{
    return vibe_user_syscall3(number, arg0, arg1, 0);
}
#endif

int vibe_user_syscall_errno(int raw_result, int fallback_errno)
{
    return vibe_user_result_errno(raw_result, fallback_errno);
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

    while (text[length])
        ++length;

    return vibe_user_write_full(fd, text, length, 0);
}

int vibe_user_write_full(int fd, const void* buffer, unsigned long count, unsigned long* out_written)
{
    const unsigned char* bytes = buffer;
    unsigned long done = 0;
    unsigned long chunk;
    int result;

    if (out_written)
        *out_written = 0;
    if (count && !bytes)
        return -22;

    while (done < count) {
        chunk = count - done;
        if (chunk > 0x7ffffffful)
            chunk = 0x7ffffffful;

        result = vibe_user_write(fd, bytes + done, chunk);
        if (result < 0) {
            if (out_written)
                *out_written = done;
            return -vibe_user_syscall_errno(result, 5);
        }
        if (result == 0 || (unsigned long)result > chunk) {
            if (out_written)
                *out_written = done;
            return -5;
        }

        done += (unsigned long)result;
        if (out_written)
            *out_written = done;
    }

    return 0;
}

int vibe_user_read_full(int fd, void* buffer, unsigned long count, unsigned long* out_read)
{
    unsigned char* bytes = buffer;
    unsigned long done = 0;
    unsigned long chunk;
    int result;

    if (out_read)
        *out_read = 0;
    if (count && !bytes)
        return -22;

    while (done < count) {
        chunk = count - done;
        if (chunk > 0x7ffffffful)
            chunk = 0x7ffffffful;

        result = vibe_user_read(fd, bytes + done, chunk);
        if (result < 0) {
            if (out_read)
                *out_read = done;
            return -vibe_user_syscall_errno(result, 5);
        }
        if (result == 0)
            break;
        if ((unsigned long)result > chunk) {
            if (out_read)
                *out_read = done;
            return -5;
        }

        done += (unsigned long)result;
        if (out_read)
            *out_read = done;
    }

    return 0;
}

int vibe_user_read_exact(int fd, void* buffer, unsigned long count, unsigned long* out_read)
{
    unsigned long done = 0;
    int result;

    result = vibe_user_read_full(fd, buffer, count, &done);
    if (out_read)
        *out_read = done;
    if (result < 0)
        return result;
    return done == count ? 0 : -5;
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

int vibe_user_write(int fd, const void* buffer, unsigned long count)
{
    if (!buffer && count)
        return -22;
    return vibe_user_syscall3(VIBE_SYS_WRITE, (unsigned long)fd, (unsigned long)buffer, count);
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

int vibe_user_pwrite(int fd, const void* buffer, unsigned long count, long offset)
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

    result = vibe_user_write(fd, buffer, count);
    restore = vibe_user_lseek(fd, original, 0);
    if (restore < 0 && result >= 0)
        return restore;
    return result;
}

int vibe_user_close(int fd)
{
    return vibe_user_syscall1(VIBE_SYS_CLOSE, (unsigned long)fd);
}

int vibe_user_unlink(const char* path)
{
    if (!path)
        return -22;
    return vibe_user_syscall1(VIBE_SYS_UNLINK, (unsigned long)path);
}

int vibe_user_stat(const char* path, struct stat* out)
{
    if (!path || !out)
        return -22;
    return vibe_user_syscall2(VIBE_SYS_STAT, (unsigned long)path, (unsigned long)out);
}

int vibe_user_fstat(int fd, struct stat* out)
{
    if (!out)
        return -22;
    return vibe_user_syscall2(VIBE_SYS_FSTAT, (unsigned long)fd, (unsigned long)out);
}

int vibe_user_ftruncate(int fd, long length)
{
    if (length < 0)
        return -22;
    return vibe_user_syscall2(VIBE_SYS_FTRUNCATE, (unsigned long)fd, (unsigned long)length);
}

int vibe_user_getpid(void)
{
    return vibe_user_syscall0(VIBE_SYS_GETPID);
}

int vibe_user_getppid(void)
{
    return vibe_user_syscall0(VIBE_SYS_GETPPID);
}

void vibe_user_exit(int status)
{
    (void)vibe_user_syscall1(VIBE_SYS_EXIT, (unsigned long)status);
    for (;;) {
    }
}

int vibe_user_fork(void)
{
    return vibe_user_syscall0(VIBE_SYS_FORK);
}

int vibe_user_waitpid(long pid, int* status, unsigned long options)
{
    return vibe_user_syscall3(VIBE_SYS_WAITPID, (unsigned long)pid, (unsigned long)status, options);
}

int vibe_user_waitpid_nohang_reap(long pid, int* status, unsigned long max_polls)
{
    unsigned long poll;
    int result;

    if (!max_polls)
        return -22;

    for (poll = 0; poll < max_polls; ++poll) {
        result = vibe_user_waitpid(pid, status, VIBE_USER_WNOHANG);
        if (result != 0)
            return result;
        result = vibe_user_yield();
        if (result < 0)
            return result;
    }

    return 0;
}

int vibe_user_dup(int oldfd)
{
    return vibe_user_syscall1(VIBE_SYS_DUP, (unsigned long)oldfd);
}

int vibe_user_dup2(int oldfd, int newfd)
{
    return vibe_user_syscall2(VIBE_SYS_DUP2, (unsigned long)oldfd, (unsigned long)newfd);
}

int vibe_user_dup3(int oldfd, int newfd, unsigned long flags)
{
    return vibe_user_syscall3(VIBE_SYS_DUP3, (unsigned long)oldfd, (unsigned long)newfd, flags);
}

int vibe_user_fcntl(int fd, int cmd, unsigned long arg)
{
    return vibe_user_syscall3(VIBE_SYS_FCNTL, (unsigned long)fd, (unsigned long)cmd, arg);
}

int vibe_user_process_status(long pid, vibe_process_status_t* out)
{
    if (!out)
        return -22;
    return vibe_user_syscall3(
        VIBE_SYS_PROCESS_STATUS,
        (unsigned long)pid,
        (unsigned long)out,
        sizeof(*out));
}

int vibe_user_process_status_current(vibe_process_status_t* out)
{
    return vibe_user_process_status(VIBE_PROCESS_STATUS_SELF, out);
}

int vibe_user_yield(void)
{
    return vibe_user_syscall0(VIBE_SYS_YIELD);
}

int vibe_user_sleep_ticks(unsigned long ticks)
{
    if (!ticks)
        return vibe_user_yield();
    return vibe_user_syscall1(VIBE_SYS_SLEEP_TICKS, ticks);
}

int vibe_user_sleep_milliseconds(unsigned long milliseconds)
{
    unsigned long ticks;

    if (!milliseconds)
        return vibe_user_yield();
    if (milliseconds > (~0ul - 999ul) / VIBE_CLOCK_MONOTONIC_HZ)
        return -22;

    ticks = ((milliseconds * VIBE_CLOCK_MONOTONIC_HZ) + 999ul) / 1000ul;
    if (!ticks)
        ticks = 1;
    return vibe_user_sleep_ticks(ticks);
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

int vibe_user_mmap_file(
    void** out,
    unsigned long length,
    unsigned long prot,
    unsigned long flags,
    int fd,
    long offset)
{
    void* mapped = 0;
    unsigned long copied = 0;
    unsigned long chunk;
    unsigned long request_offset;
    int result;

    if (!out)
        return -22;
    *out = 0;
    if (!length || fd < 0 || offset < 0)
        return -22;
    if (!prot || (prot & ~(VIBE_USER_PROT_READ | VIBE_USER_PROT_WRITE | VIBE_USER_PROT_EXEC)))
        return -22;
    if (flags != VIBE_USER_MAP_PRIVATE)
        return -22;

    result = vibe_user_mmap_anon(out, length, prot);
    if (result < 0)
        return result;

    mapped = *out;
    while (copied < length) {
        if ((unsigned long)offset > VIBE_USER_LONG_MAX_32
            || copied > VIBE_USER_LONG_MAX_32 - (unsigned long)offset) {
            (void)vibe_user_munmap(mapped, length);
            *out = 0;
            return -22;
        }

        chunk = length - copied;
        if (chunk > 0x7ffffffful)
            chunk = 0x7ffffffful;
        request_offset = (unsigned long)offset + copied;

        result = vibe_user_pread(
            fd,
            (unsigned char*)mapped + copied,
            chunk,
            (long)request_offset);
        if (result < 0) {
            (void)vibe_user_munmap(mapped, length);
            *out = 0;
            return result;
        }
        if (result == 0)
            break;

        copied += (unsigned long)result;
    }

    return 0;
}

int vibe_user_mmap_file_private(void** out, unsigned long length, unsigned long prot, int fd, long offset)
{
    return vibe_user_mmap_file(out, length, prot, VIBE_USER_MAP_PRIVATE, fd, offset);
}

int vibe_user_munmap(void* addr, unsigned long length)
{
    if (!addr || !length)
        return -22;
    return vibe_user_syscall2(VIBE_SYS_MUNMAP, (unsigned long)addr, length);
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
        | VIBE_VM_CAP_NONTAIL_MUNMAP_HOLES
        | VIBE_USER_VM_CAP_FILE_PRIVATE_COPY;
}

int vibe_user_clock_gettime(unsigned long clock_id, vibe_clock_time_t* out)
{
    return vibe_user_syscall3(
        VIBE_SYS_CLOCK_GETTIME,
        clock_id,
        (unsigned long)out,
        sizeof(*out));
}

int vibe_user_clock_monotonic(vibe_clock_time_t* out)
{
    return vibe_user_clock_gettime(VIBE_CLOCK_MONOTONIC, out);
}

unsigned long vibe_user_monotonic_milliseconds(void)
{
    vibe_clock_time_t now;

    if (vibe_user_clock_monotonic(&now) < 0)
        return 0;
    return now.milliseconds;
}

int vibe_user_poll_input(vibe_input_event_t* event)
{
    if (!event)
        return -22;

    return vibe_user_syscall3(
        VIBE_SYS_POLL_INPUT,
        (unsigned long)event,
        sizeof(*event),
        0);
}

int vibe_user_drain_input(vibe_input_event_t* events, unsigned long max_events)
{
    unsigned long count = 0;
    int result;

    if (max_events && !events)
        return -22;

    while (count < max_events) {
        result = vibe_user_poll_input(&events[count]);
        if (result < 0)
            return result;
        if (result == 0)
            break;
        ++count;
    }

    return (int)count;
}

int vibe_user_input_status(vibe_input_status_t* status)
{
    if (!status)
        return -22;

    return vibe_user_syscall3(
        VIBE_SYS_INPUT_STATUS,
        (unsigned long)status,
        sizeof(*status),
        0);
}

int vibe_user_input_device_status(unsigned long device_id, vibe_input_device_status_t* status)
{
    if (!status)
        return -22;

    return vibe_user_syscall3(
        VIBE_SYS_INPUT_DEVICE_STATUS,
        device_id,
        (unsigned long)status,
        sizeof(*status));
}

int vibe_user_fb_get_info(vibe_fb_info_t* info)
{
    if (!info)
        return -22;

    return vibe_user_syscall3(
        VIBE_USER_SYS_DISPLAY_IOCTL,
        VIBE_DISPLAY_FD,
        VIBE_IOCTL_FBINFO,
        (unsigned long)info);
}

int vibe_user_fb_can_present_indexed(const vibe_fb_info_t* info, const vibe_present_indexed_t* present)
{
    return vibe_fb_info_accepts_present_indexed(info, present);
}

int vibe_user_present_indexed(const vibe_present_indexed_t* present)
{
    if (!present || !present->frame || !present->palette || !present->width || !present->height)
        return -22;

    return vibe_user_syscall3(
        VIBE_USER_SYS_DISPLAY_IOCTL,
        VIBE_DISPLAY_FD,
        VIBE_IOCTL_PRESENT_INDEXED,
        (unsigned long)present);
}

int vibe_user_present_indexed_checked(const vibe_present_indexed_t* present)
{
    vibe_fb_info_t info;
    int result;

    if (!present || !present->frame || !present->palette || !present->width || !present->height)
        return -22;

    result = vibe_user_fb_get_info(&info);
    if (result < 0)
        return result;
    if (!vibe_fb_info_supports_indexed_rgb24(&info))
        return -38;
    if (!vibe_user_fb_can_present_indexed(&info, present))
        return -22;
    return vibe_user_present_indexed(present);
}

int vibe_user_listdir(const char* path, vibe_dirent_t* entries, unsigned long max_entries)
{
    if (!path || (max_entries && !entries))
        return -22;
    return vibe_user_syscall3(
        VIBE_SYS_LISTDIR,
        (unsigned long)path,
        (unsigned long)entries,
        max_entries);
}

int vibe_user_file_size(const char* path, unsigned long* out_size)
{
    struct stat st;
    int result;

    if (!path || !out_size)
        return -22;

    result = vibe_user_stat(path, &st);
    if (result < 0)
        return result;
    if (!S_ISREG(st.st_mode))
        return -21;
    if (st.st_size < 0)
        return -75;

    *out_size = (unsigned long)st.st_size;
    return 0;
}

int vibe_user_file_read_at(
    const char* path,
    unsigned long offset,
    void* buffer,
    unsigned long count,
    unsigned long* out_read)
{
    int fd;
    int result;
    int close_result;

    if (!path || (count && !buffer))
        return -22;
    if (out_read)
        *out_read = 0;
    if (offset > VIBE_USER_LONG_MAX_32)
        return -75;

    fd = vibe_user_open(path, VIBE_USER_O_RDONLY, 0);
    if (fd < 0)
        return fd;

    result = vibe_user_pread(fd, buffer, count, (long)offset);
    close_result = vibe_user_close(fd);
    if (result < 0)
        return result;
    if (close_result < 0)
        return close_result;

    if (out_read)
        *out_read = (unsigned long)result;
    return 0;
}

int vibe_user_file_write_at(
    const char* path,
    unsigned long offset,
    const void* buffer,
    unsigned long count,
    unsigned long* out_written)
{
    int fd;
    int result;
    int close_result;

    if (!path || (count && !buffer))
        return -22;
    if (out_written)
        *out_written = 0;
    if (offset > VIBE_USER_LONG_MAX_32)
        return -75;

    fd = vibe_user_open(path, VIBE_USER_O_CREAT | VIBE_USER_O_RDWR, 0);
    if (fd < 0)
        return fd;

    result = vibe_user_pwrite(fd, buffer, count, (long)offset);
    close_result = vibe_user_close(fd);
    if (result < 0)
        return result;
    if (close_result < 0)
        return close_result;

    if (out_written)
        *out_written = (unsigned long)result;
    return 0;
}

int vibe_user_file_read_all(const char* path, void* buffer, unsigned long capacity, unsigned long* out_size)
{
    unsigned long size;
    unsigned long done;
    int fd;
    int result;
    int close_result;

    if (!path || (capacity && !buffer))
        return -22;

    result = vibe_user_file_size(path, &size);
    if (result < 0)
        return result;
    if (out_size)
        *out_size = size;
    if (size > capacity)
        return -28;

    fd = vibe_user_open(path, VIBE_USER_O_RDONLY, 0);
    if (fd < 0)
        return fd;

    done = 0;
    while (done < size) {
        result = vibe_user_read(fd, (unsigned char*)buffer + done, size - done);
        if (result < 0) {
            (void)vibe_user_close(fd);
            return result;
        }
        if (result == 0) {
            (void)vibe_user_close(fd);
            return -5;
        }
        done += (unsigned long)result;
    }

    close_result = vibe_user_close(fd);
    return close_result < 0 ? close_result : 0;
}

int vibe_user_execv(const char* path, char* const argv[])
{
    return vibe_user_syscall3(VIBE_SYS_EXEC, (unsigned long)path, (unsigned long)argv, 0);
}

void vibe_user_report_probe(unsigned long magic, unsigned long flags)
{
    (void)vibe_user_syscall2(VIBE_SYS_USER_PROBE, magic, flags);
}
