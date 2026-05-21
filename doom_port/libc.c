#include <ctype.h>
#include <errno.h>
#include <fcntl.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

#include "vibe_os.h"

#define VIBE_FILE_WRITE_BUFFER 4096
#define VIBE_FILE_POOL_SIZE 4
#define VIBE_TRACKED_FDS 32

struct vibe_doom_file {
    int fd;
    int eof;
    int error;
    int used;
    int readable;
    int writable;
    int append;
    size_t write_buffered;
    int has_pushback;
    unsigned char pushback;
    char write_buffer[VIBE_FILE_WRITE_BUFFER];
};

typedef struct alloc_header {
    size_t size;
    int free;
    struct alloc_header* prev;
    struct alloc_header* next;
} alloc_header_t;

int errno;

static struct vibe_doom_file stdin_file = { 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, { 0 } };
static struct vibe_doom_file stdout_file = { 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, { 0 } };
static struct vibe_doom_file stderr_file = { 2, 0, 0, 1, 0, 1, 0, 0, 0, 0, { 0 } };
static FILE file_pool[VIBE_FILE_POOL_SIZE];
static char* empty_environment[] = { 0 };
static alloc_header_t* alloc_head;
static alloc_header_t* alloc_tail;
static unsigned char tracked_save_fd[VIBE_TRACKED_FDS];
static unsigned char tracked_save_slot[VIBE_TRACKED_FDS];

FILE* stdin = &stdin_file;
FILE* stdout = &stdout_file;
FILE* stderr = &stderr_file;
char** environ = empty_environment;

static int write_all_fd(int fd, const char* data, size_t length);
static int stream_flush_write(FILE* stream);
static int stream_write(FILE* stream, const char* data, size_t length);

#ifndef VIBE_LIBC_HOST_TEST
int vibe_syscall3(unsigned int number, unsigned long arg0, unsigned long arg1, unsigned long arg2)
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

static size_t align16(size_t size)
{
    return (size + 15) & ~(size_t)15;
}

static size_t alloc_header_size(void)
{
    return align16(sizeof(alloc_header_t));
}

static void* alloc_payload(alloc_header_t* header)
{
    return (void*)((unsigned char*)header + alloc_header_size());
}

static alloc_header_t* alloc_from_payload(void* ptr)
{
    return (alloc_header_t*)((unsigned char*)ptr - alloc_header_size());
}

#ifdef VIBE_LIBC_HOST_TEST
#define VIBE_LIBC_HOST_HEAP_SIZE (64 * 1024)

static unsigned char vibe_libc_host_heap[VIBE_LIBC_HOST_HEAP_SIZE] __attribute__((aligned(16)));
static size_t vibe_libc_host_heap_offset;

void vibe_libc_host_heap_reset(void)
{
    alloc_head = 0;
    alloc_tail = 0;
    vibe_libc_host_heap_offset = 0;
}

size_t vibe_libc_host_heap_used(void)
{
    return vibe_libc_host_heap_offset;
}

static void* alloc_sbrk(size_t total)
{
    void* ptr;

    total = align16(total);
    if (total > VIBE_LIBC_HOST_HEAP_SIZE - vibe_libc_host_heap_offset)
        return 0;

    ptr = vibe_libc_host_heap + vibe_libc_host_heap_offset;
    vibe_libc_host_heap_offset += total;
    return ptr;
}
#else
static void* alloc_sbrk(size_t total)
{
    int raw;

    if (total > (unsigned int)-1)
        return 0;

    raw = vibe_syscall3(VIBE_SYS_SBRK, (unsigned long)total, 0, 0);
    if (raw < 0)
        return 0;
    return (void*)(unsigned int)raw;
}
#endif

static alloc_header_t* alloc_find_free(size_t size)
{
    alloc_header_t* block = alloc_head;
    while (block) {
        if (block->free && block->size >= size)
            return block;
        block = block->next;
    }
    return 0;
}

static void alloc_split(alloc_header_t* block, size_t size)
{
    size_t header_size = alloc_header_size();
    alloc_header_t* next;

    if (block->size <= size || block->size - size < header_size + 16)
        return;

    next = (alloc_header_t*)((unsigned char*)alloc_payload(block) + size);
    next->size = block->size - size - header_size;
    next->free = 1;
    next->prev = block;
    next->next = block->next;

    if (next->next)
        next->next->prev = next;
    else
        alloc_tail = next;

    block->size = size;
    block->next = next;
}

static void alloc_coalesce_next(alloc_header_t* block)
{
    alloc_header_t* next = block->next;
    if (!next || !next->free)
        return;

    block->size += alloc_header_size() + next->size;
    block->next = next->next;
    if (block->next)
        block->next->prev = block;
    else
        alloc_tail = block;
}

static alloc_header_t* alloc_request(size_t size)
{
    size_t header_size = alloc_header_size();
    size_t total;
    void* raw;
    alloc_header_t* block;

    if (size > (size_t)-1 - header_size)
        return 0;

    total = header_size + size;
    raw = alloc_sbrk(total);
    if (!raw)
        return 0;

    block = (alloc_header_t*)raw;
    block->size = size;
    block->free = 0;
    block->prev = alloc_tail;
    block->next = 0;

    if (alloc_tail)
        alloc_tail->next = block;
    else
        alloc_head = block;
    alloc_tail = block;

    return block;
}

static int is_doom_save_basename(const char* path)
{
    return strlen(path) == 12
        && !strncasecmp(path, "doomsav", 7)
        && path[7] >= '0'
        && path[7] <= '5'
        && !strcasecmp(path + 8, ".dsg");
}

static int doom_save_slot_for_basename(const char* path)
{
    if (!is_doom_save_basename(path))
        return -1;
    return path[7] - '0';
}

static void report_doom_save_event(int slot, unsigned long event, unsigned long value, unsigned long extra)
{
    unsigned long packed;

    if (slot < 0 || slot > 5)
        return;

    packed = VIBE_DOOM_SAVELOAD_STATUS
        | (event & 0xffffu)
        | ((unsigned long)slot << VIBE_DOOM_SAVELOAD_SLOT_SHIFT);
    (void)vibe_syscall3(VIBE_SYS_GAMEPLAY_STATUS, packed, value, extra);
}

static void track_save_fd(int fd, int slot)
{
    if (fd < 0 || fd >= VIBE_TRACKED_FDS)
        return;
    tracked_save_fd[fd] = 1;
    tracked_save_slot[fd] = (unsigned char)slot;
}

static int tracked_save_slot_for_fd(int fd)
{
    if (fd < 0 || fd >= VIBE_TRACKED_FDS || !tracked_save_fd[fd])
        return -1;
    return tracked_save_slot[fd];
}

static void untrack_save_fd(int fd)
{
    if (fd < 0 || fd >= VIBE_TRACKED_FDS)
        return;
    tracked_save_fd[fd] = 0;
    tracked_save_slot[fd] = 0;
}

static const char* mapped_path(const char* path)
{
    static char save_path[] = "doomsav0.dsg";
    const char* slash = path;
    const char* p;

    for (p = path; *p; ++p)
        if (*p == '/' || *p == '\\')
            slash = p + 1;

    if (!strcasecmp(slash, "doom1.wad"))
        return "DOOM1.WAD";
    if (!strcasecmp(slash, "doom.elf"))
        return "DOOM.ELF";
    if (!strcasecmp(slash, "userprob.elf"))
        return "USERPROB.ELF";
    if (!strcasecmp(slash, ".doomrc") || !strcasecmp(slash, "default.cfg"))
        return "DEFAULT.CFG";
    if (is_doom_save_basename(slash)) {
        save_path[7] = slash[7];
        return save_path;
    }
    return path;
}

static int is_doom_data_dir(const char* path)
{
    return !strcasecmp(path, "c:\\doomdata")
        || !strcasecmp(path, "c:/doomdata")
        || !strcasecmp(path, "doomdata");
}

static int syscall_failed(int raw, int fallback_errno)
{
    if (raw < -1)
        errno = -raw;
    else
        errno = fallback_errno;
    return -1;
}

static int validate_open_flags(int flags)
{
    int access_mode = flags & O_ACCMODE;
    int known_flags = O_ACCMODE | O_CREAT | O_TRUNC | O_APPEND | O_CLOEXEC | O_BINARY;

    if ((flags & ~known_flags) || access_mode == O_ACCMODE) {
        errno = EINVAL;
        return -1;
    }

    if ((flags & O_TRUNC) && access_mode == O_RDONLY) {
        errno = EINVAL;
        return -1;
    }

    if ((flags & O_APPEND) && access_mode == O_RDONLY) {
        errno = EINVAL;
        return -1;
    }

    return 0;
}

static int checked_multiply_size(size_t left, size_t right, size_t* out)
{
    if (left && right > (size_t)-1 / left) {
        errno = EOVERFLOW;
        return -1;
    }
    *out = left * right;
    return 0;
}

void* memcpy(void* dest, const void* src, size_t count)
{
    unsigned char* d = dest;
    const unsigned char* s = src;
    while (count--)
        *d++ = *s++;
    return dest;
}

void* memmove(void* dest, const void* src, size_t count)
{
    unsigned char* d = dest;
    const unsigned char* s = src;
    if (d < s) {
        while (count--)
            *d++ = *s++;
    } else {
        d += count;
        s += count;
        while (count--)
            *--d = *--s;
    }
    return dest;
}

void* memset(void* dest, int value, size_t count)
{
    unsigned char* d = dest;
    while (count--)
        *d++ = (unsigned char)value;
    return dest;
}

int memcmp(const void* left, const void* right, size_t count)
{
    const unsigned char* l = left;
    const unsigned char* r = right;
    while (count--) {
        if (*l != *r)
            return (int)*l - (int)*r;
        ++l;
        ++r;
    }
    return 0;
}

size_t strlen(const char* text)
{
    const char* p = text;
    while (*p)
        ++p;
    return (size_t)(p - text);
}

char* strcpy(char* dest, const char* src)
{
    char* out = dest;
    while ((*dest++ = *src++))
        ;
    return out;
}

char* strncpy(char* dest, const char* src, size_t count)
{
    char* out = dest;
    while (count && *src) {
        *dest++ = *src++;
        --count;
    }
    while (count--)
        *dest++ = 0;
    return out;
}

char* strcat(char* dest, const char* src)
{
    strcpy(dest + strlen(dest), src);
    return dest;
}

char* strncat(char* dest, const char* src, size_t count)
{
    char* end = dest + strlen(dest);
    while (count-- && *src)
        *end++ = *src++;
    *end = 0;
    return dest;
}

int strcmp(const char* left, const char* right)
{
    while (*left && *left == *right) {
        ++left;
        ++right;
    }
    return (unsigned char)*left - (unsigned char)*right;
}

int strncmp(const char* left, const char* right, size_t count)
{
    while (count && *left && *left == *right) {
        ++left;
        ++right;
        --count;
    }
    return count ? (unsigned char)*left - (unsigned char)*right : 0;
}

int strcasecmp(const char* left, const char* right)
{
    while (*left && tolower((unsigned char)*left) == tolower((unsigned char)*right)) {
        ++left;
        ++right;
    }
    return tolower((unsigned char)*left) - tolower((unsigned char)*right);
}

int strncasecmp(const char* left, const char* right, size_t count)
{
    while (count && *left && tolower((unsigned char)*left) == tolower((unsigned char)*right)) {
        ++left;
        ++right;
        --count;
    }
    return count ? tolower((unsigned char)*left) - tolower((unsigned char)*right) : 0;
}

char* strchr(const char* text, int ch)
{
    while (*text) {
        if (*text == (char)ch)
            return (char*)text;
        ++text;
    }
    return ch == 0 ? (char*)text : 0;
}

char* strrchr(const char* text, int ch)
{
    const char* last = 0;
    do {
        if (*text == (char)ch)
            last = text;
    } while (*text++);
    return (char*)last;
}

char* strdup(const char* text)
{
    size_t len = strlen(text) + 1;
    char* copy = malloc(len);
    if (copy)
        memcpy(copy, text, len);
    return copy;
}

int atoi(const char* text)
{
    int sign = 1;
    int value = 0;
    while (isspace((unsigned char)*text))
        ++text;
    if (*text == '-') {
        sign = -1;
        ++text;
    }
    while (isdigit((unsigned char)*text))
        value = value * 10 + (*text++ - '0');
    return value * sign;
}

long atol(const char* text)
{
    return (long)atoi(text);
}

void* malloc(size_t size)
{
    alloc_header_t* block;

    if (!size)
        return 0;
    if (size > (size_t)-1 - 15)
        return 0;

    size = align16(size);
    block = alloc_find_free(size);
    if (!block)
        block = alloc_request(size);
    if (!block)
        return 0;

    block->free = 0;
    alloc_split(block, size);
    return alloc_payload(block);
}

void* calloc(size_t count, size_t size)
{
    size_t total;
    void* ptr;

    if (size && count > (size_t)-1 / size)
        return 0;

    total = count * size;
    ptr = malloc(total);
    if (ptr)
        memset(ptr, 0, total);
    return ptr;
}

void* realloc(void* ptr, size_t size)
{
    alloc_header_t* old_header;
    void* next;
    size_t copy;
    size_t combined;

    if (!ptr)
        return malloc(size);
    if (!size) {
        free(ptr);
        return 0;
    }
    if (size > (size_t)-1 - 15)
        return 0;

    size = align16(size);
    old_header = alloc_from_payload(ptr);

    if (old_header->size >= size) {
        alloc_split(old_header, size);
        if (old_header->next)
            alloc_coalesce_next(old_header->next);
        return ptr;
    }

    if (old_header->next && old_header->next->free) {
        combined = old_header->size + alloc_header_size();
        if (combined >= old_header->size) {
            combined += old_header->next->size;
            if (combined >= old_header->next->size && combined >= size) {
                alloc_coalesce_next(old_header);
                alloc_split(old_header, size);
                return ptr;
            }
        }
    }

    next = malloc(size);
    if (!next)
        return 0;
    copy = old_header->size < size ? old_header->size : size;
    memcpy(next, ptr, copy);
    free(ptr);
    return next;
}

void free(void* ptr)
{
    alloc_header_t* block;

    if (!ptr)
        return;

    block = alloc_from_payload(ptr);
    if (block->free)
        return;

    block->free = 1;
    alloc_coalesce_next(block);
    if (block->prev && block->prev->free)
        alloc_coalesce_next(block->prev);
}

void _exit(int status)
{
    (void)vibe_syscall3(VIBE_SYS_EXIT, (unsigned long)status, 0, 0);
    for (;;) {
    }
}

void exit(int status)
{
    _exit(status);
}

char* getenv(const char* name)
{
    if (!strcmp(name, "HOME"))
        return "/";
    if (!strcmp(name, "DOOMWADDIR"))
        return ".";
    return 0;
}

int rand(void)
{
    static unsigned int state = 1;
    state = state * 1103515245u + 12345u;
    return (int)((state >> 16) & 0x7fff);
}

void srand(unsigned int seed)
{
    (void)seed;
}

int open(const char* path, int flags, ...)
{
    int raw;
    int slot;
    unsigned int mode = 0;
    const char* mapped;
    va_list args;

    if (!path) {
        errno = EINVAL;
        return -1;
    }

    if (validate_open_flags(flags) < 0)
        return -1;

    if (flags & O_CREAT) {
        va_start(args, flags);
        mode = (unsigned int)va_arg(args, int);
        va_end(args);
    }

    mapped = mapped_path(path);
    raw = vibe_syscall3(VIBE_SYS_OPEN, (unsigned long)mapped, (unsigned long)flags, mode);
    if (raw >= 0) {
        slot = doom_save_slot_for_basename(mapped);
        if (slot >= 0) {
            track_save_fd(raw, slot);
            report_doom_save_event(
                slot,
                VIBE_DOOM_SAVELOAD_OPEN,
                (unsigned long)flags,
                mode);
        }
    }
    return raw < 0 ? syscall_failed(raw, ENOENT) : raw;
}

ssize_t read(int fd, void* buffer, size_t count)
{
    int raw;
    int slot;
    if (!buffer && count) {
        errno = EINVAL;
        return -1;
    }
    raw = vibe_syscall3(VIBE_SYS_READ, (unsigned long)fd, (unsigned long)buffer, (unsigned long)count);
    if (raw > 0) {
        slot = tracked_save_slot_for_fd(fd);
        if (slot >= 0)
            report_doom_save_event(slot, VIBE_DOOM_SAVELOAD_READ, (unsigned long)raw, 0);
    }
    return raw < 0 ? syscall_failed(raw, EIO) : raw;
}

ssize_t write(int fd, const void* buffer, size_t count)
{
    int raw;
    int slot;
    if (!buffer && count) {
        errno = EINVAL;
        return -1;
    }
    raw = vibe_syscall3(VIBE_SYS_WRITE, (unsigned long)fd, (unsigned long)buffer, (unsigned long)count);
    if (raw > 0) {
        slot = tracked_save_slot_for_fd(fd);
        if (slot >= 0)
            report_doom_save_event(slot, VIBE_DOOM_SAVELOAD_WRITE, (unsigned long)raw, 0);
    }
    return raw < 0 ? syscall_failed(raw, EIO) : raw;
}

int close(int fd)
{
    int slot = tracked_save_slot_for_fd(fd);
    int raw = vibe_syscall3(VIBE_SYS_CLOSE, (unsigned long)fd, 0, 0);
    if (raw >= 0 && slot >= 0) {
        report_doom_save_event(slot, VIBE_DOOM_SAVELOAD_CLOSE, 0, 0);
        untrack_save_fd(fd);
    }
    return raw < 0 ? syscall_failed(raw, EBADF) : raw;
}

off_t lseek(int fd, off_t offset, int whence)
{
    int raw = vibe_syscall3(VIBE_SYS_LSEEK, (unsigned long)fd, (unsigned long)offset, (unsigned long)whence);
    return raw < 0 ? syscall_failed(raw, EINVAL) : raw;
}

int vibe_clock_gettime(unsigned long clock_id, vibe_clock_time_t* out)
{
    int raw;

    if (!out) {
        errno = EINVAL;
        return -1;
    }

    raw = vibe_syscall3(
        VIBE_SYS_CLOCK_GETTIME,
        clock_id,
        (unsigned long)out,
        (unsigned long)sizeof(*out));
    return raw < 0 ? syscall_failed(raw, EINVAL) : raw;
}

unsigned long vibe_monotonic_ticks(void)
{
    vibe_clock_time_t now;

    if (vibe_clock_gettime(VIBE_CLOCK_MONOTONIC, &now) < 0)
        return 0;
    return now.ticks;
}

unsigned long vibe_monotonic_milliseconds(void)
{
    vibe_clock_time_t now;

    if (vibe_clock_gettime(VIBE_CLOCK_MONOTONIC, &now) < 0)
        return 0;
    return now.milliseconds;
}

int clock_gettime(clockid_t clock_id, struct timespec* tp)
{
    vibe_clock_time_t now;

    if (!tp || clock_id != CLOCK_MONOTONIC) {
        errno = EINVAL;
        return -1;
    }

    if (vibe_clock_gettime(VIBE_CLOCK_MONOTONIC, &now) < 0)
        return -1;

    tp->tv_sec = (time_t)(now.milliseconds / 1000u);
    tp->tv_nsec = (long)((now.milliseconds % 1000u) * 1000000u);
    return 0;
}

int ftruncate(int fd, off_t length)
{
    int raw;
    if (length < 0) {
        errno = EINVAL;
        return -1;
    }
    raw = vibe_syscall3(VIBE_SYS_FTRUNCATE, (unsigned long)fd, (unsigned long)length, 0);
    return raw < 0 ? syscall_failed(raw, EIO) : raw;
}

int truncate(const char* path, off_t length)
{
    int fd;
    int result;
    int close_result;
    int saved_errno;

    if (!path || length < 0) {
        errno = EINVAL;
        return -1;
    }

    fd = open(path, O_WRONLY);
    if (fd < 0)
        return -1;

    result = ftruncate(fd, length);
    saved_errno = errno;
    close_result = close(fd);
    if (close_result < 0 && result == 0)
        return -1;
    if (result < 0)
        errno = saved_errno;
    return result;
}

int access(const char* path, int mode)
{
    int fd;
    int flags = O_RDONLY;
    if (mode & ~(F_OK | R_OK | W_OK | X_OK)) {
        errno = EINVAL;
        return -1;
    }
    if (mode & W_OK)
        flags = O_WRONLY;
    fd = open(path, flags);
    if (fd < 0)
        return -1;
    close(fd);
    return 0;
}

int unlink(const char* path)
{
    int raw;
    if (!path) {
        errno = EINVAL;
        return -1;
    }
    raw = vibe_syscall3(VIBE_SYS_UNLINK, (unsigned long)mapped_path(path), 0, 0);
    return raw < 0 ? syscall_failed(raw, ENOSYS) : raw;
}

int remove(const char* path)
{
    return unlink(path);
}

int mkdir(const char* path, mode_t mode)
{
    (void)mode;
    if (!path) {
        errno = EINVAL;
        return -1;
    }
    if (is_doom_data_dir(path))
        return 0;
    errno = ENOSYS;
    return -1;
}

int fstat(int fd, struct stat* out)
{
    int raw;
    if (!out) {
        errno = EINVAL;
        return -1;
    }
    raw = vibe_syscall3(VIBE_SYS_FSTAT, (unsigned long)fd, (unsigned long)out, 0);
    return raw < 0 ? syscall_failed(raw, EBADF) : raw;
}

int stat(const char* path, struct stat* out)
{
    int raw;
    if (!path) {
        errno = EINVAL;
        return -1;
    }
    if (!out) {
        errno = EINVAL;
        return -1;
    }
    raw = vibe_syscall3(VIBE_SYS_STAT, (unsigned long)mapped_path(path), (unsigned long)out, 0);
    return raw < 0 ? syscall_failed(raw, ENOENT) : raw;
}

int vibe_listdir(const char* path, vibe_dirent_t* entries, unsigned long max_entries)
{
    int raw;
    if (!path) {
        errno = EINVAL;
        return -1;
    }
    if (max_entries && !entries) {
        errno = EINVAL;
        return -1;
    }
    raw = vibe_syscall3(VIBE_SYS_LISTDIR, (unsigned long)path, (unsigned long)entries, max_entries);
    return raw < 0 ? syscall_failed(raw, EINVAL) : raw;
}

void* mmap(void* addr, size_t length, int prot, int flags, int fd, off_t offset)
{
#ifdef VIBE_LIBC_HOST_TEST
    size_t rounded;
    void* raw;
#else
    int raw;
    unsigned long packed;
#endif

    if (addr || !length || (flags & MAP_FIXED) || offset != 0) {
        errno = EINVAL;
        return MAP_FAILED;
    }

    if (!prot
        || (prot & ~(PROT_READ | PROT_WRITE | PROT_EXEC))
        || (flags & ~(MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED | MAP_SHARED))) {
        errno = EINVAL;
        return MAP_FAILED;
    }

    if (!(flags & MAP_ANONYMOUS) || fd != -1 || !(flags & MAP_PRIVATE) || (flags & MAP_SHARED)) {
        errno = ENOSYS;
        return MAP_FAILED;
    }

#ifdef VIBE_LIBC_HOST_TEST
    if (length > (size_t)-1 - 4095) {
        errno = ENOMEM;
        return MAP_FAILED;
    }
    rounded = (length + 4095) & ~(size_t)4095;
    raw = alloc_sbrk(rounded);
    if (!raw) {
        errno = ENOMEM;
        return MAP_FAILED;
    }
    memset(raw, 0, rounded);
    return raw;
#else
    packed = ((unsigned long)(flags & 0xffff) << 16) | (unsigned long)(prot & 0xffff);
    raw = vibe_syscall3(VIBE_SYS_MMAP, 0, (unsigned long)length, packed);
    if (raw < 0) {
        (void)syscall_failed(raw, ENOMEM);
        return MAP_FAILED;
    }
    return (void*)(unsigned int)raw;
#endif
}

int munmap(void* addr, size_t length)
{
#ifndef VIBE_LIBC_HOST_TEST
    int raw;
#endif
    if (!addr || addr == MAP_FAILED || !length) {
        errno = EINVAL;
        return -1;
    }
#ifdef VIBE_LIBC_HOST_TEST
    return 0;
#else
    raw = vibe_syscall3(VIBE_SYS_MUNMAP, (unsigned long)addr, (unsigned long)length, 0);
    return raw < 0 ? syscall_failed(raw, EINVAL) : raw;
#endif
}

int ioctl(int fd, unsigned long request, void* arg)
{
    int raw = vibe_syscall3(VIBE_SYS_IOCTL, (unsigned long)fd, request, (unsigned long)arg);
    return raw < 0 ? syscall_failed(raw, ENOTTY) : raw;
}

int execv(const char* path, char* const argv[])
{
    int raw;

    if (!path) {
        errno = EINVAL;
        return -1;
    }

    raw = vibe_syscall3(VIBE_SYS_EXEC, (unsigned long)mapped_path(path), (unsigned long)argv, 0);
    return raw < 0 ? syscall_failed(raw, ENOENT) : raw;
}

int execve(const char* path, char* const argv[], char* const envp[])
{
    if (envp && envp[0]) {
        errno = ENOSYS;
        return -1;
    }
    return execv(path, argv);
}

int execl(const char* path, const char* arg, ...)
{
    char* argv[8];
    int count = 0;
    va_list args;

    if (!path) {
        errno = EINVAL;
        return -1;
    }

    va_start(args, arg);
    while (arg) {
        if (count >= (int)(sizeof(argv) / sizeof(argv[0])) - 1) {
            va_end(args);
            errno = EINVAL;
            return -1;
        }
        argv[count++] = (char*)arg;
        arg = va_arg(args, const char*);
    }
    va_end(args);
    argv[count] = 0;
    return execv(path, argv);
}

pid_t getpid(void)
{
    int raw = vibe_syscall3(VIBE_SYS_GETPID, 0, 0, 0);
    return raw < 0 ? syscall_failed(raw, ENOSYS) : raw;
}

pid_t fork(void)
{
    int raw = vibe_syscall3(VIBE_SYS_FORK, 0, 0, 0);
    return raw < 0 ? syscall_failed(raw, ENOSYS) : raw;
}

pid_t waitpid(pid_t pid, int* status, int options)
{
    int raw = vibe_syscall3(VIBE_SYS_WAITPID, (unsigned long)pid, (unsigned long)status, (unsigned long)options);
    return raw < 0 ? syscall_failed(raw, ECHILD) : raw;
}

pid_t wait(int* status)
{
    return waitpid((pid_t)-1, status, 0);
}

static int parse_fopen_mode(const char* mode, int* flags, int* readable, int* writable, int* append)
{
    int saw_plus = 0;
    int saw_binary = 0;

    if (!mode || !*mode) {
        errno = EINVAL;
        return -1;
    }

    *readable = 0;
    *writable = 0;
    *append = 0;

    switch (*mode++) {
    case 'r':
        *flags = O_RDONLY;
        *readable = 1;
        break;
    case 'w':
        *flags = O_WRONLY | O_CREAT | O_TRUNC;
        *writable = 1;
        break;
    case 'a':
        *flags = O_WRONLY | O_CREAT | O_APPEND;
        *writable = 1;
        *append = 1;
        break;
    default:
        errno = EINVAL;
        return -1;
    }

    while (*mode) {
        if (*mode == 'b') {
            if (saw_binary) {
                errno = EINVAL;
                return -1;
            }
            saw_binary = 1;
        } else if (*mode == '+') {
            if (saw_plus) {
                errno = EINVAL;
                return -1;
            }
            saw_plus = 1;
        } else {
            errno = EINVAL;
            return -1;
        }
        ++mode;
    }

    if (saw_plus) {
        *flags = (*flags & ~(O_RDONLY | O_WRONLY)) | O_RDWR;
        *readable = 1;
        *writable = 1;
    }

    return 0;
}

FILE* fopen(const char* path, const char* mode)
{
    int fd;
    int i;
    int flags;
    int readable;
    int writable;
    int append;

    if (parse_fopen_mode(mode, &flags, &readable, &writable, &append) < 0)
        return 0;

    fd = open(path, flags, 0666);
    if (fd < 0)
        return 0;
    for (i = 0; i < VIBE_FILE_POOL_SIZE; ++i) {
        if (!file_pool[i].used) {
            file_pool[i].used = 1;
            file_pool[i].fd = fd;
            file_pool[i].eof = 0;
            file_pool[i].error = 0;
            file_pool[i].readable = readable;
            file_pool[i].writable = writable;
            file_pool[i].append = append;
            file_pool[i].write_buffered = 0;
            file_pool[i].has_pushback = 0;
            file_pool[i].pushback = 0;
            if (append)
                (void)lseek(fd, 0, SEEK_END);
            return &file_pool[i];
        }
    }
    errno = EMFILE;
    close(fd);
    return 0;
}

size_t fread(void* ptr, size_t size, size_t count, FILE* stream)
{
    int bytes;
    size_t total;
    if (!size || !count)
        return 0;
    if (!stream || !stream->used || !stream->readable || checked_multiply_size(size, count, &total) < 0) {
        if (stream)
            stream->error = 1;
        if (!stream || !stream->used || !stream->readable)
            errno = EBADF;
        return 0;
    }
    if (stream_flush_write(stream) < 0)
        return 0;
    bytes = read(stream->fd, ptr, total);
    if (bytes < 0) {
        stream->error = 1;
        return 0;
    }
    if (bytes == 0) {
        stream->eof = 1;
        return 0;
    }
    if ((size_t)bytes < total)
        stream->eof = 1;
    return (size_t)bytes / size;
}

size_t fwrite(const void* ptr, size_t size, size_t count, FILE* stream)
{
    size_t total;
    if (!size || !count)
        return 0;
    if (!stream || !stream->used || !stream->writable || checked_multiply_size(size, count, &total) < 0) {
        if (stream)
            stream->error = 1;
        if (!stream || !stream->used || !stream->writable)
            errno = EBADF;
        return 0;
    }
    if (stream->append)
        (void)lseek(stream->fd, 0, SEEK_END);
    if (stream_write(stream, ptr, total) < 0) {
        stream->error = 1;
        return 0;
    }
    return count;
}

int fseek(FILE* stream, long offset, int whence)
{
    if (!stream || !stream->used) {
        errno = EBADF;
        return -1;
    }
    if (stream_flush_write(stream) < 0)
        return -1;
    if (lseek(stream->fd, (off_t)offset, whence) < 0) {
        stream->error = 1;
        return -1;
    }
    stream->eof = 0;
    stream->has_pushback = 0;
    return 0;
}

long ftell(FILE* stream)
{
    off_t raw;
    if (!stream || !stream->used) {
        errno = EBADF;
        return -1;
    }
    raw = lseek(stream->fd, 0, SEEK_CUR);
    if (raw < 0) {
        stream->error = 1;
        return -1;
    }
    return (long)(raw + (off_t)stream->write_buffered);
}

int fclose(FILE* stream)
{
    int result;
    if (!stream || !stream->used) {
        errno = EBADF;
        return EOF;
    }
    result = stream_flush_write(stream);
    if (close(stream->fd) < 0)
        result = EOF;
    stream->fd = -1;
    stream->eof = 1;
    stream->error = result < 0;
    stream->used = 0;
    stream->readable = 0;
    stream->writable = 0;
    stream->append = 0;
    stream->write_buffered = 0;
    stream->has_pushback = 0;
    return result;
}

int fflush(FILE* stream)
{
    int i;
    int result = 0;

    if (!stream) {
        if (stream_flush_write(stdout) < 0)
            result = EOF;
        if (stream_flush_write(stderr) < 0)
            result = EOF;
        for (i = 0; i < VIBE_FILE_POOL_SIZE; ++i) {
            if (file_pool[i].used && file_pool[i].writable
                && stream_flush_write(&file_pool[i]) < 0)
                result = EOF;
        }
        return result;
    }
    if (!stream->used) {
        errno = EBADF;
        return EOF;
    }
    return stream_flush_write(stream);
}

int feof(FILE* stream)
{
    if (!stream)
        return 0;
    return stream->eof;
}

int ferror(FILE* stream)
{
    if (!stream)
        return 0;
    return stream->error;
}

void clearerr(FILE* stream)
{
    if (!stream)
        return;
    stream->eof = 0;
    stream->error = 0;
}

void setbuf(FILE* stream, char* buffer)
{
    (void)stream;
    (void)buffer;
}

int getchar(void)
{
    return EOF;
}

static int out_char(char** out, size_t* left, int fd, char ch)
{
    if (out) {
        if (*left > 1) {
            **out = ch;
            ++*out;
            --*left;
        }
    } else {
        if (write(fd, &ch, 1) != 1)
            return -1;
    }
    return 0;
}

static int write_all_fd(int fd, const char* data, size_t length)
{
    size_t done = 0;
    while (done < length) {
        ssize_t bytes = write(fd, data + done, length - done);
        if (bytes <= 0)
            return -1;
        done += (size_t)bytes;
    }
    return 0;
}

static int stream_flush_write(FILE* stream)
{
    if (!stream || !stream->write_buffered)
        return 0;
    if (write_all_fd(stream->fd, stream->write_buffer, stream->write_buffered) < 0) {
        stream->error = 1;
        return EOF;
    }
    stream->write_buffered = 0;
    return 0;
}

static int stream_write(FILE* stream, const char* data, size_t length)
{
    if (!length)
        return 0;
    if (stream->fd == 1 || stream->fd == 2)
        return write_all_fd(stream->fd, data, length);
    if (length > VIBE_FILE_WRITE_BUFFER) {
        if (stream_flush_write(stream) < 0)
            return -1;
        return write_all_fd(stream->fd, data, length);
    }
    if (stream->write_buffered + length > VIBE_FILE_WRITE_BUFFER
        && stream_flush_write(stream) < 0)
        return -1;
    memcpy(stream->write_buffer + stream->write_buffered, data, length);
    stream->write_buffered += length;
    return 0;
}

static int out_string(char** out, size_t* left, int fd, const char* text)
{
    int count = 0;
    if (!text)
        text = "(null)";
    while (*text) {
        if (out_char(out, left, fd, *text++) < 0)
            return -1;
        ++count;
    }
    return count;
}

static int out_unsigned(char** out, size_t* left, int fd, unsigned int value, int base, int width, int pad_zero)
{
    char tmp[16];
    int pos = 0;
    int count = 0;
    do {
        unsigned int digit = value % (unsigned int)base;
        tmp[pos++] = digit < 10 ? (char)('0' + digit) : (char)('a' + digit - 10);
        value /= (unsigned int)base;
    } while (value);
    while (pos < width)
        tmp[pos++] = pad_zero ? '0' : ' ';
    while (pos--) {
        if (out_char(out, left, fd, tmp[pos]) < 0)
            return -1;
        ++count;
    }
    return count;
}

static int format_to(char* buffer, size_t size, int fd, const char* format, va_list args)
{
    char* out = buffer;
    size_t left = size;
    int count = 0;

    while (*format) {
        int width = 0;
        int pad_zero = 0;
        int precision = -1;
        int wrote = 0;
        if (*format != '%') {
            if (out_char(buffer ? &out : 0, &left, fd, *format++) < 0)
                return -1;
            ++count;
            continue;
        }
        ++format;
        if (*format == '0') {
            pad_zero = 1;
            ++format;
        }
        while (isdigit((unsigned char)*format)) {
            width = width * 10 + (*format++ - '0');
        }
        if (*format == '.') {
            ++format;
            precision = 0;
            while (isdigit((unsigned char)*format)) {
                precision = precision * 10 + (*format - '0');
                ++format;
            }
        }
        switch (*format++) {
        case 's':
            wrote = out_string(buffer ? &out : 0, &left, fd, va_arg(args, const char*));
            if (wrote < 0)
                return -1;
            count += wrote;
            break;
        case 'c':
            if (out_char(buffer ? &out : 0, &left, fd, (char)va_arg(args, int)) < 0)
                return -1;
            ++count;
            break;
        case 'd':
        case 'i': {
            int value = va_arg(args, int);
            int digits_width = width;
            int digits_pad_zero = pad_zero;
            if (value < 0) {
                if (out_char(buffer ? &out : 0, &left, fd, '-') < 0)
                    return -1;
                ++count;
                value = -value;
            }
            if (precision >= 0) {
                digits_pad_zero = 1;
                if (precision > digits_width)
                    digits_width = precision;
            }
            wrote = out_unsigned(buffer ? &out : 0, &left, fd, (unsigned int)value, 10, digits_width, digits_pad_zero);
            if (wrote < 0)
                return -1;
            count += wrote;
            break;
        }
        case 'u':
            if (precision >= 0) {
                pad_zero = 1;
                if (precision > width)
                    width = precision;
            }
            wrote = out_unsigned(buffer ? &out : 0, &left, fd, va_arg(args, unsigned int), 10, width, pad_zero);
            if (wrote < 0)
                return -1;
            count += wrote;
            break;
        case 'x':
        case 'p':
            if (precision >= 0) {
                pad_zero = 1;
                if (precision > width)
                    width = precision;
            }
            wrote = out_unsigned(buffer ? &out : 0, &left, fd, va_arg(args, unsigned int), 16, width, pad_zero);
            if (wrote < 0)
                return -1;
            count += wrote;
            break;
        case '%':
            if (out_char(buffer ? &out : 0, &left, fd, '%') < 0)
                return -1;
            ++count;
            break;
        default:
            break;
        }
    }
    if (buffer && size)
        *out = 0;
    return count;
}

int vsnprintf(char* buffer, size_t size, const char* format, va_list args)
{
    return format_to(buffer, size, 1, format, args);
}

int vsprintf(char* buffer, const char* format, va_list args)
{
    return vsnprintf(buffer, (size_t)-1, format, args);
}

int snprintf(char* buffer, size_t size, const char* format, ...)
{
    int result;
    va_list args;
    va_start(args, format);
    result = vsnprintf(buffer, size, format, args);
    va_end(args);
    return result;
}

int sprintf(char* buffer, const char* format, ...)
{
    int result;
    va_list args;
    va_start(args, format);
    result = vsprintf(buffer, format, args);
    va_end(args);
    return result;
}

int vfprintf(FILE* stream, const char* format, va_list args)
{
    char buffer[512];
    va_list copy;
    int result;
    if (!stream || !stream->used || !stream->writable) {
        if (stream)
            stream->error = 1;
        errno = EBADF;
        return EOF;
    }
    if (stream->append)
        (void)lseek(stream->fd, 0, SEEK_END);

    va_copy(copy, args);
    result = format_to(buffer, sizeof(buffer), stream->fd, format, copy);
    va_end(copy);
    if (result >= 0 && (size_t)result < sizeof(buffer)) {
        if (stream_write(stream, buffer, (size_t)result) < 0)
            result = -1;
    } else if (result >= 0) {
        if (stream_flush_write(stream) < 0)
            return EOF;
        result = format_to(0, 0, stream->fd, format, args);
    }
    if (result < 0)
        stream->error = 1;
    return result;
}

int fprintf(FILE* stream, const char* format, ...)
{
    int result;
    va_list args;
    va_start(args, format);
    result = vfprintf(stream, format, args);
    va_end(args);
    return result;
}

int vprintf(const char* format, va_list args)
{
    return vfprintf(stdout, format, args);
}

int printf(const char* format, ...)
{
    int result;
    va_list args;
    va_start(args, format);
    result = vprintf(format, args);
    va_end(args);
    return result;
}

static void scan_text_skip_space(const char** text)
{
    while (isspace((unsigned char)**text))
        ++*text;
}

static int scan_text_read_int(const char** text, int* dest, int width, int base)
{
    const char* p = *text;
    int sign = 1;
    int value = 0;
    int digits = 0;
    int consumed = 0;

    if (width <= 0)
        width = 64;

    scan_text_skip_space(&p);
    if (consumed < width && (*p == '-' || *p == '+')) {
        if (*p == '-')
            sign = -1;
        ++p;
        ++consumed;
    }

    if ((base == 0 || base == 16)
        && consumed + 2 <= width
        && p[0] == '0'
        && (p[1] == 'x' || p[1] == 'X')) {
        base = 16;
        p += 2;
        consumed += 2;
    } else if (base == 0) {
        base = 10;
    }

    while (consumed < width && *p) {
        int digit;
        if (isdigit((unsigned char)*p))
            digit = *p - '0';
        else if (isxdigit((unsigned char)*p))
            digit = tolower((unsigned char)*p) - 'a' + 10;
        else
            break;
        if (digit >= base)
            break;
        value = value * base + digit;
        ++digits;
        ++p;
        ++consumed;
    }

    if (!digits)
        return 0;
    *dest = value * sign;
    *text = p;
    return 1;
}

static int scan_text_read_word(const char** text, char* dest, int width)
{
    int count = 0;

    if (width <= 0)
        width = 1023;
    scan_text_skip_space(text);
    while (count < width && **text && !isspace((unsigned char)**text)) {
        dest[count++] = **text;
        ++*text;
    }
    dest[count] = 0;
    return count > 0;
}

static int scan_text_read_until(const char** text, char* dest, int width, int stop)
{
    int count = 0;

    if (width <= 0)
        width = 99;
    while (count < width && **text && **text != (char)stop) {
        dest[count++] = **text;
        ++*text;
    }
    dest[count] = 0;
    return count > 0;
}

int sscanf(const char* text, const char* format, ...)
{
    va_list args;
    int assigned = 0;
    int matched = 0;

    if (!text || !format) {
        errno = EINVAL;
        return EOF;
    }

    va_start(args, format);
    while (*format) {
        int width = 0;

        if (isspace((unsigned char)*format)) {
            while (isspace((unsigned char)*format))
                ++format;
            scan_text_skip_space(&text);
            continue;
        }

        if (*format != '%') {
            if (*text != *format)
                break;
            ++text;
            ++format;
            ++matched;
            continue;
        }

        ++format;
        if (*format == '%') {
            if (*text != '%')
                break;
            ++text;
            ++format;
            ++matched;
            continue;
        }

        while (isdigit((unsigned char)*format)) {
            width = width * 10 + (*format - '0');
            ++format;
        }

        if (*format == 's') {
            if (!scan_text_read_word(&text, va_arg(args, char*), width))
                break;
            ++assigned;
            ++matched;
            ++format;
        } else if (*format == '[') {
            ++format;
            if (*format == '^' && format[1] && format[2] == ']') {
                if (!scan_text_read_until(&text, va_arg(args, char*), width, (unsigned char)format[1]))
                    break;
                format += 3;
                ++assigned;
                ++matched;
            } else {
                errno = EINVAL;
                break;
            }
        } else if (*format == 'i' || *format == 'd') {
            if (!scan_text_read_int(&text, va_arg(args, int*), width, *format == 'i' ? 0 : 10))
                break;
            ++assigned;
            ++matched;
            ++format;
        } else if (*format == 'x') {
            if (!scan_text_read_int(&text, va_arg(args, int*), width, 16))
                break;
            ++assigned;
            ++matched;
            ++format;
        } else {
            errno = EINVAL;
            break;
        }
    }
    va_end(args);

    if (!matched && !*text)
        return EOF;
    return assigned;
}

static int file_read_char(FILE* stream)
{
    unsigned char ch;
    int bytes;

    if (!stream || !stream->used || !stream->readable) {
        if (stream)
            stream->error = 1;
        errno = EBADF;
        return EOF;
    }

    if (stream->has_pushback) {
        stream->has_pushback = 0;
        return stream->pushback;
    }

    bytes = read(stream->fd, &ch, 1);
    if (bytes == 1)
        return ch;
    if (bytes == 0) {
        stream->eof = 1;
        return EOF;
    }
    stream->error = 1;
    return EOF;
}

static void file_unread_char(FILE* stream, int ch)
{
    if (!stream || ch == EOF)
        return;
    stream->pushback = (unsigned char)ch;
    stream->has_pushback = 1;
    stream->eof = 0;
}

static void scan_skip_space(FILE* stream)
{
    int ch;
    do {
        ch = file_read_char(stream);
    } while (ch != EOF && isspace((unsigned char)ch));
    file_unread_char(stream, ch);
}

static int scan_read_word(FILE* stream, char* dest, int width)
{
    int ch;
    int count = 0;

    if (width <= 0)
        width = 1023;
    scan_skip_space(stream);
    while (count < width) {
        ch = file_read_char(stream);
        if (ch == EOF)
            break;
        if (isspace((unsigned char)ch)) {
            file_unread_char(stream, ch);
            break;
        }
        dest[count++] = (char)ch;
    }
    dest[count] = 0;
    return count > 0;
}

static int scan_read_until(FILE* stream, char* dest, int width, int stop)
{
    int ch;
    int count = 0;

    if (width <= 0)
        width = 99;
    while (count < width) {
        ch = file_read_char(stream);
        if (ch == EOF)
            break;
        if (ch == stop) {
            file_unread_char(stream, ch);
            break;
        }
        dest[count++] = (char)ch;
    }
    dest[count] = 0;
    return count > 0;
}

static int scan_read_int(FILE* stream, int* dest, int width, int base)
{
    char tmp[64];
    int ch;
    int count = 0;
    int sign = 1;
    int value = 0;
    int digits = 0;
    const char* p;

    if (width <= 0 || width >= (int)sizeof(tmp))
        width = (int)sizeof(tmp) - 1;
    scan_skip_space(stream);
    ch = file_read_char(stream);
    if (ch == '-' || ch == '+') {
        tmp[count++] = (char)ch;
        ch = file_read_char(stream);
    }
    while (ch != EOF && count < width && (isalnum((unsigned char)ch) || ch == 'x' || ch == 'X')) {
        tmp[count++] = (char)ch;
        ch = file_read_char(stream);
    }
    file_unread_char(stream, ch);
    tmp[count] = 0;

    p = tmp;
    if (*p == '-') {
        sign = -1;
        ++p;
    } else if (*p == '+') {
        ++p;
    }
    if ((base == 0 || base == 16) && p[0] == '0' && (p[1] == 'x' || p[1] == 'X')) {
        base = 16;
        p += 2;
    } else if (base == 0) {
        base = 10;
    }
    while (*p) {
        int digit;
        if (isdigit((unsigned char)*p))
            digit = *p - '0';
        else if (isxdigit((unsigned char)*p))
            digit = tolower((unsigned char)*p) - 'a' + 10;
        else
            break;
        if (digit >= base)
            break;
        value = value * base + digit;
        ++digits;
        ++p;
    }
    if (!digits)
        return 0;
    *dest = value * sign;
    return 1;
}

int fscanf(FILE* stream, const char* format, ...)
{
    va_list args;
    int assigned = 0;
    int matched = 0;

    if (!stream || !format) {
        errno = EINVAL;
        return EOF;
    }

    va_start(args, format);
    while (*format) {
        int width = 0;
        int ch;

        if (isspace((unsigned char)*format)) {
            while (isspace((unsigned char)*format))
                ++format;
            scan_skip_space(stream);
            continue;
        }

        if (*format != '%') {
            ch = file_read_char(stream);
            if (ch == EOF || ch != (unsigned char)*format) {
                file_unread_char(stream, ch);
                break;
            }
            ++format;
            ++matched;
            continue;
        }

        ++format;
        if (*format == '%') {
            ch = file_read_char(stream);
            if (ch != '%') {
                file_unread_char(stream, ch);
                break;
            }
            ++format;
            ++matched;
            continue;
        }

        while (isdigit((unsigned char)*format)) {
            width = width * 10 + (*format - '0');
            ++format;
        }

        if (*format == 's') {
            if (!scan_read_word(stream, va_arg(args, char*), width))
                break;
            ++assigned;
            ++matched;
            ++format;
        } else if (*format == '[') {
            ++format;
            if (*format == '^' && format[1] && format[2] == ']') {
                if (!scan_read_until(stream, va_arg(args, char*), width, (unsigned char)format[1]))
                    break;
                format += 3;
                ++assigned;
                ++matched;
            } else {
                errno = EINVAL;
                break;
            }
        } else if (*format == 'i' || *format == 'd') {
            if (!scan_read_int(stream, va_arg(args, int*), width, *format == 'i' ? 0 : 10))
                break;
            ++assigned;
            ++matched;
            ++format;
        } else if (*format == 'x') {
            if (!scan_read_int(stream, va_arg(args, int*), width, 16))
                break;
            ++assigned;
            ++matched;
            ++format;
        } else {
            errno = EINVAL;
            break;
        }
    }
    va_end(args);

    if (!matched && stream->eof)
        return EOF;
    return assigned;
}
