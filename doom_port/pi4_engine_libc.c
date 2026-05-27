#include "pi4_runtime.h"

#include <errno.h>
#include <fcntl.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <time.h>
#include <unistd.h>

#define PI4_ENGINE_HEAP_BYTES (32 * 1024 * 1024)
#define PI4_ENGINE_MAX_FILES 8
#define PI4_ENGINE_FIRST_FD 3
#define PI4_ENGINE_WAD_READ_CHUNK (512 * 1024)
#define PI4_ENGINE_PRELOAD_WAD 1

int errno;
char** environ;

struct vibe_doom_file {
    int fd;
    int eof;
    int error;
    int pushed;
    unsigned char pushback;
};

typedef struct pi4_engine_file {
    int used;
    int writable;
    long kernel_fd;
    unsigned char* data;
    long size;
    long pos;
    long loaded;
} pi4_engine_file_t;

static unsigned char pi4_engine_heap[PI4_ENGINE_HEAP_BYTES] __attribute__((aligned(16)));
static unsigned long pi4_engine_heap_used;
static pi4_engine_file_t pi4_engine_files[PI4_ENGINE_MAX_FILES];

static struct vibe_doom_file pi4_stdin = {0, 0, 0, 0, 0};
static struct vibe_doom_file pi4_stdout = {1, 0, 0, 0, 0};
static struct vibe_doom_file pi4_stderr = {2, 0, 0, 0, 0};

FILE* stdin = &pi4_stdin;
FILE* stdout = &pi4_stdout;
FILE* stderr = &pi4_stderr;

void pi4_doom_engine_note_file_open(unsigned long size);
void pi4_doom_engine_note_file_read(unsigned long loaded, unsigned long last, unsigned long size);
void pi4_doom_engine_note_file_ready(void);
void pi4_doom_engine_note_file_error(unsigned long code);
void pi4_doom_engine_note_console(const char* text, unsigned long count);
void pi4_doom_engine_poll_visible_input(void);
void pi4_doom_engine_show_failure(const char* title, const char* detail, long code);

static int pi4_is_space(int ch)
{
    return ch == ' ' || (ch >= '\t' && ch <= '\r');
}

static int pi4_lower(int ch)
{
    if (ch >= 'A' && ch <= 'Z')
        return ch + ('a' - 'A');
    return ch;
}

static int pi4_digit_value(int ch)
{
    if (ch >= '0' && ch <= '9')
        return ch - '0';
    ch = pi4_lower(ch);
    if (ch >= 'a' && ch <= 'f')
        return ch - 'a' + 10;
    return -1;
}

static void pi4_set_errno_from_result(long result)
{
    if (result < 0)
        errno = (int)-result;
}

void* memcpy(void* dest, const void* src, size_t count)
{
    unsigned char* d = (unsigned char*)dest;
    const unsigned char* s = (const unsigned char*)src;
    if ((((unsigned long)d | (unsigned long)s) & (sizeof(unsigned long) - 1)) == 0) {
        unsigned long* dw = (unsigned long*)d;
        const unsigned long* sw = (const unsigned long*)s;
        while (count >= sizeof(unsigned long)) {
            *dw++ = *sw++;
            count -= sizeof(unsigned long);
        }
        d = (unsigned char*)dw;
        s = (const unsigned char*)sw;
    }
    while (count--)
        *d++ = *s++;
    return dest;
}

void* memmove(void* dest, const void* src, size_t count)
{
    unsigned char* d = (unsigned char*)dest;
    const unsigned char* s = (const unsigned char*)src;
    if (d <= s) {
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
    unsigned char* d = (unsigned char*)dest;
    unsigned long word = (unsigned char)value;
    word |= word << 8;
    word |= word << 16;
    word |= word << 32;
    while (count && ((unsigned long)d & (sizeof(unsigned long) - 1))) {
        *d++ = (unsigned char)value;
        count--;
    }
    if (count >= sizeof(unsigned long)) {
        unsigned long* dw = (unsigned long*)d;
        while (count >= sizeof(unsigned long)) {
            *dw++ = word;
            count -= sizeof(unsigned long);
        }
        d = (unsigned char*)dw;
    }
    while (count--)
        *d++ = (unsigned char)value;
    return dest;
}

int memcmp(const void* left, const void* right, size_t count)
{
    const unsigned char* l = (const unsigned char*)left;
    const unsigned char* r = (const unsigned char*)right;
    while (count--) {
        if (*l != *r)
            return (int)*l - (int)*r;
        l++;
        r++;
    }
    return 0;
}

void* memchr(const void* data, int ch, size_t count)
{
    const unsigned char* p = (const unsigned char*)data;
    while (count--) {
        if (*p == (unsigned char)ch)
            return (void*)p;
        p++;
    }
    return NULL;
}

size_t strlen(const char* text)
{
    const char* p = text;
    while (p && *p)
        p++;
    return p ? (size_t)(p - text) : 0;
}

size_t strnlen(const char* text, size_t max_length)
{
    size_t len = 0;
    while (text && len < max_length && text[len])
        len++;
    return len;
}

char* strcpy(char* dest, const char* src)
{
    char* out = dest;
    while ((*dest++ = *src++) != 0) {
    }
    return out;
}

char* strncpy(char* dest, const char* src, size_t count)
{
    size_t i;
    for (i = 0; i < count && src[i]; i++)
        dest[i] = src[i];
    for (; i < count; i++)
        dest[i] = 0;
    return dest;
}

char* strcat(char* dest, const char* src)
{
    strcpy(dest + strlen(dest), src);
    return dest;
}

char* strncat(char* dest, const char* src, size_t count)
{
    char* out = dest;
    dest += strlen(dest);
    while (count-- && *src)
        *dest++ = *src++;
    *dest = 0;
    return out;
}

int strcmp(const char* left, const char* right)
{
    while (*left && *left == *right) {
        left++;
        right++;
    }
    return (unsigned char)*left - (unsigned char)*right;
}

int strncmp(const char* left, const char* right, size_t count)
{
    while (count && *left && *left == *right) {
        left++;
        right++;
        count--;
    }
    if (!count)
        return 0;
    return (unsigned char)*left - (unsigned char)*right;
}

int strcasecmp(const char* left, const char* right)
{
    while (*left && pi4_lower((unsigned char)*left) == pi4_lower((unsigned char)*right)) {
        left++;
        right++;
    }
    return pi4_lower((unsigned char)*left) - pi4_lower((unsigned char)*right);
}

int strncasecmp(const char* left, const char* right, size_t count)
{
    while (count && *left && pi4_lower((unsigned char)*left) == pi4_lower((unsigned char)*right)) {
        left++;
        right++;
        count--;
    }
    if (!count)
        return 0;
    return pi4_lower((unsigned char)*left) - pi4_lower((unsigned char)*right);
}

char* strchr(const char* text, int ch)
{
    do {
        if (*text == (char)ch)
            return (char*)text;
    } while (*text++);
    return NULL;
}

char* strrchr(const char* text, int ch)
{
    const char* last = NULL;
    do {
        if (*text == (char)ch)
            last = text;
    } while (*text++);
    return (char*)last;
}

char* strpbrk(const char* text, const char* accept)
{
    while (*text) {
        if (strchr(accept, *text))
            return (char*)text;
        text++;
    }
    return NULL;
}

size_t strspn(const char* text, const char* accept)
{
    size_t count = 0;
    while (text[count] && strchr(accept, text[count]))
        count++;
    return count;
}

size_t strcspn(const char* text, const char* reject)
{
    size_t count = 0;
    while (text[count] && !strchr(reject, text[count]))
        count++;
    return count;
}

char* strstr(const char* text, const char* needle)
{
    size_t needle_len = strlen(needle);
    if (!needle_len)
        return (char*)text;
    while (*text) {
        if (strncmp(text, needle, needle_len) == 0)
            return (char*)text;
        text++;
    }
    return NULL;
}

char* strtok_r(char* text, const char* delimiters, char** saveptr)
{
    char* start = text ? text : *saveptr;
    if (!start)
        return NULL;
    start += strspn(start, delimiters);
    if (!*start) {
        *saveptr = NULL;
        return NULL;
    }
    char* end = start + strcspn(start, delimiters);
    if (*end) {
        *end++ = 0;
        *saveptr = end;
    } else {
        *saveptr = NULL;
    }
    return start;
}

char* strtok(char* text, const char* delimiters)
{
    static char* save;
    return strtok_r(text, delimiters, &save);
}

char* strdup(const char* text)
{
    size_t bytes = strlen(text) + 1;
    char* copy = (char*)malloc(bytes);
    if (copy)
        memcpy(copy, text, bytes);
    return copy;
}

char* strndup(const char* text, size_t max_length)
{
    size_t bytes = strnlen(text, max_length);
    char* copy = (char*)malloc(bytes + 1);
    if (!copy)
        return NULL;
    memcpy(copy, text, bytes);
    copy[bytes] = 0;
    return copy;
}

char* strerror(int error)
{
    switch (error) {
    case 0:
        return "ok";
    case ENOENT:
        return "not found";
    case EBADF:
        return "bad file";
    case ENOMEM:
        return "out of memory";
    case EINVAL:
        return "invalid";
    case ENOSYS:
        return "not implemented";
    default:
        return "error";
    }
}

static unsigned long pi4_align16(unsigned long value)
{
    return (value + 15ul) & ~15ul;
}

void* malloc(size_t size)
{
    unsigned long aligned = pi4_align16(pi4_engine_heap_used);
    if (!size)
        size = 1;
    if (aligned > PI4_ENGINE_HEAP_BYTES || size > PI4_ENGINE_HEAP_BYTES - aligned) {
        errno = ENOMEM;
        return NULL;
    }
    pi4_engine_heap_used = aligned + (unsigned long)size;
    return pi4_engine_heap + aligned;
}

void* calloc(size_t count, size_t size)
{
    if (count && size > ((size_t)-1) / count) {
        errno = ENOMEM;
        return NULL;
    }
    void* ptr = malloc(count * size);
    if (ptr)
        memset(ptr, 0, count * size);
    return ptr;
}

void* realloc(void* ptr, size_t size)
{
    void* next;
    if (!ptr)
        return malloc(size);
    next = malloc(size);
    if (!next)
        return NULL;
    return next;
}

void free(void* ptr)
{
    (void)ptr;
}

long labs(long value)
{
    return value < 0 ? -value : value;
}

long strtol(const char* text, char** endptr, int base)
{
    long sign = 1;
    unsigned long value = 0;
    int digit;
    while (pi4_is_space(*text))
        text++;
    if (*text == '-') {
        sign = -1;
        text++;
    } else if (*text == '+') {
        text++;
    }
    if ((base == 0 || base == 16) && text[0] == '0' && (text[1] == 'x' || text[1] == 'X')) {
        base = 16;
        text += 2;
    } else if (base == 0) {
        base = text[0] == '0' ? 8 : 10;
    }
    while ((digit = pi4_digit_value(*text)) >= 0 && digit < base) {
        value = value * (unsigned long)base + (unsigned long)digit;
        text++;
    }
    if (endptr)
        *endptr = (char*)text;
    return sign < 0 ? -(long)value : (long)value;
}

unsigned long strtoul(const char* text, char** endptr, int base)
{
    return (unsigned long)strtol(text, endptr, base);
}

int atoi(const char* text)
{
    return (int)strtol(text, NULL, 10);
}

long atol(const char* text)
{
    return strtol(text, NULL, 10);
}

double atof(const char* text)
{
    (void)text;
    return 0.0;
}

double strtod(const char* text, char** endptr)
{
    if (endptr)
        *endptr = (char*)text;
    return 0.0;
}

void qsort(void* base, size_t count, size_t size, int (*compar)(const void*, const void*))
{
    (void)base;
    (void)count;
    (void)size;
    (void)compar;
}

void* bsearch(const void* key, const void* base, size_t count, size_t size,
              int (*compar)(const void*, const void*))
{
    (void)key;
    (void)base;
    (void)count;
    (void)size;
    (void)compar;
    return NULL;
}

int rand(void)
{
    static unsigned long state = 1;
    state = state * 1103515245ul + 12345ul;
    return (int)((state >> 16) & RAND_MAX);
}

void srand(unsigned int seed)
{
    (void)seed;
}

char* getenv(const char* name)
{
    if (strcmp(name, "DOOMWADDIR") == 0)
        return ".";
    if (strcmp(name, "HOME") == 0)
        return ".";
    return NULL;
}

static int pi4_path_is_doom_wad(const char* path)
{
    const char* base;

    if (!path)
        return 0;
    base = strrchr(path, '/');
    if (!base)
        base = strrchr(path, '\\');
    base = base ? base + 1 : path;
    return strcasecmp(base, "doom1.wad") == 0;
}

static void pi4_show_doom_wad_failure_once(const char* title, const char* detail)
{
    static int shown;

    if (shown)
        return;
    shown = 1;
    pi4_doom_engine_note_file_error(0);
    pi4_doom_engine_show_failure(title, detail, errno);
}

static int pi4_probe_doom_wad(long* out_fd, long* out_size)
{
    long kfd = vibe_user_file_open("DOOM1.WAD");
    long size;
    if (kfd < 0) {
        pi4_set_errno_from_result(kfd);
        return -1;
    }
    size = vibe_user_file_size((pi4_vibe_word_t)kfd);
    if (size <= 0) {
        pi4_set_errno_from_result(size < 0 ? size : -PI4_VIBE_ENOENT);
        (void)vibe_user_file_close((pi4_vibe_word_t)kfd);
        return -1;
    }
    if (out_fd)
        *out_fd = kfd;
    else
        (void)vibe_user_file_close((pi4_vibe_word_t)kfd);
    if (out_size)
        *out_size = size;
    return 0;
}

static pi4_engine_file_t* pi4_file_from_fd(int fd)
{
    int index = fd - PI4_ENGINE_FIRST_FD;
    if (index < 0 || index >= PI4_ENGINE_MAX_FILES || !pi4_engine_files[index].used) {
        errno = EBADF;
        return NULL;
    }
    return &pi4_engine_files[index];
}

static void pi4_note_file_progress(pi4_engine_file_t* file, long got)
{
    if (!file || got <= 0 || file->size <= 0)
        return;
    pi4_doom_engine_poll_visible_input();
    file->loaded += got;
    if (file->loaded > file->size)
        file->loaded = file->size;
    pi4_doom_engine_note_file_read(
        (unsigned long)file->loaded,
        (unsigned long)got,
        (unsigned long)file->size);
}

int open(const char* path, int flags, ...)
{
    int i;
    long kfd;
    long size;
    long total;
    long got;
    long request;
    pi4_engine_file_t* file;

    if ((flags & O_ACCMODE) != O_RDONLY) {
        errno = ENOSYS;
        return -1;
    }
    if (!path || !pi4_path_is_doom_wad(path)) {
        errno = ENOENT;
        return -1;
    }
    for (i = 0; i < PI4_ENGINE_MAX_FILES; i++) {
        if (!pi4_engine_files[i].used)
            break;
    }
    if (i == PI4_ENGINE_MAX_FILES) {
        errno = EMFILE;
        return -1;
    }
    if (pi4_probe_doom_wad(&kfd, &size) < 0) {
        pi4_show_doom_wad_failure_once("DOOM WAD MISSING", "COPY DOOM1.WAD TO PI IMAGE");
        return -1;
    }
    file = &pi4_engine_files[i];
    memset(file, 0, sizeof(*file));
    file->kernel_fd = kfd;
    file->size = size;
    file->pos = 0;
    file->data = NULL;
    pi4_doom_engine_note_file_open((unsigned long)size);
    pi4_doom_engine_poll_visible_input();
#if PI4_ENGINE_PRELOAD_WAD
    file->data = (unsigned char*)malloc((size_t)size);
    if (!file->data) {
        file->used = 1;
        errno = 0;
        return PI4_ENGINE_FIRST_FD + i;
    }
    total = 0;
    while (total < size) {
        request = size - total;
        if (request > PI4_ENGINE_WAD_READ_CHUNK)
            request = PI4_ENGINE_WAD_READ_CHUNK;
        got = vibe_user_file_read(
            (pi4_vibe_word_t)kfd,
            file->data + total,
            (pi4_vibe_word_t)request);
        if (got <= 0) {
            pi4_set_errno_from_result(got < 0 ? got : -PI4_VIBE_ENOENT);
            pi4_doom_engine_note_file_error(1);
            pi4_show_doom_wad_failure_once("DOOM WAD READ ERR", "DOOM1.WAD READ FAILED");
            (void)vibe_user_file_close((pi4_vibe_word_t)kfd);
            return -1;
        }
        total += got;
        file->loaded = total;
    }
    if (total != size) {
        errno = EIO;
        pi4_doom_engine_note_file_error(2);
        pi4_show_doom_wad_failure_once("DOOM WAD READ ERR", "DOOM1.WAD SHORT READ");
        (void)vibe_user_file_close((pi4_vibe_word_t)kfd);
        return -1;
    }
    pi4_doom_engine_note_file_read((unsigned long)size, (unsigned long)size,
                                   (unsigned long)size);
    file->used = 1;
    (void)vibe_user_file_close((pi4_vibe_word_t)kfd);
    file->kernel_fd = 0;
    pi4_doom_engine_note_file_ready();
    return PI4_ENGINE_FIRST_FD + i;
#else
    file->used = 1;
    pi4_doom_engine_note_file_ready();
    return PI4_ENGINE_FIRST_FD + i;
#endif
}

ssize_t read(int fd, void* buffer, size_t count)
{
    pi4_engine_file_t* file;
    long remain;
    long got;
    long seek_result;
    unsigned char* out;
    size_t total;
    size_t request;
    if (fd == 0)
        return 0;
    file = pi4_file_from_fd(fd);
    if (!file)
        return -1;
    if (!buffer && count) {
        errno = EINVAL;
        return -1;
    }
    remain = file->size - file->pos;
    if (remain < 0)
        remain = 0;
    if ((long)count > remain)
        count = (size_t)remain;
    if (!count)
        return 0;
    if (file->data) {
        memcpy(buffer, file->data + file->pos, count);
        file->pos += (long)count;
        return (ssize_t)count;
    }
    if (file->kernel_fd <= 0) {
        errno = EBADF;
        return -1;
    }
    out = (unsigned char*)buffer;
    total = 0;
    seek_result = vibe_user_file_seek(
        (pi4_vibe_word_t)file->kernel_fd,
        (pi4_vibe_sword_t)file->pos,
        PI4_VIBE_SEEK_SET);
    if (seek_result < 0) {
        pi4_set_errno_from_result(seek_result);
        return -1;
    }
    while (total < count) {
        request = count - total;
        if (request > PI4_ENGINE_WAD_READ_CHUNK)
            request = PI4_ENGINE_WAD_READ_CHUNK;
        pi4_doom_engine_poll_visible_input();
        got = vibe_user_file_read(
            (pi4_vibe_word_t)file->kernel_fd,
            out + total,
            (pi4_vibe_word_t)request);
        if (got < 0) {
            pi4_set_errno_from_result(got);
            return total ? (ssize_t)total : -1;
        }
        if (!got)
            break;
        file->pos += got;
        total += (size_t)got;
        pi4_note_file_progress(file, got);
        if (got < (long)request)
            break;
    }
    return (ssize_t)total;
}

ssize_t pread(int fd, void* buffer, size_t count, off_t offset)
{
    pi4_engine_file_t* file = pi4_file_from_fd(fd);
    long saved;
    ssize_t got;
    if (!file)
        return -1;
    if (offset < 0) {
        errno = EINVAL;
        return -1;
    }
    saved = file->pos;
    file->pos = offset;
    got = read(fd, buffer, count);
    file->pos = saved;
    return got;
}

ssize_t write(int fd, const void* buffer, size_t count)
{
    long result;
    if (fd == 1 || fd == 2) {
        if (buffer && count)
            pi4_doom_engine_note_console((const char*)buffer, (unsigned long)count);
        result = vibe_user_syscall3(PI4_VIBE_SYS_IOCTL, (pi4_vibe_word_t)fd,
                                    (pi4_vibe_word_t)buffer, (pi4_vibe_word_t)count);
        if (result < 0)
            return (ssize_t)count;
        return (ssize_t)result;
    }
    (void)buffer;
    return (ssize_t)count;
}

ssize_t pwrite(int fd, const void* buffer, size_t count, off_t offset)
{
    (void)fd;
    (void)buffer;
    (void)count;
    (void)offset;
    errno = ENOSYS;
    return -1;
}

off_t lseek(int fd, off_t offset, int whence)
{
    pi4_engine_file_t* file = pi4_file_from_fd(fd);
    long next;
    if (!file)
        return -1;
    if (whence == SEEK_SET)
        next = offset;
    else if (whence == SEEK_CUR)
        next = file->pos + offset;
    else if (whence == SEEK_END)
        next = file->size + offset;
    else {
        errno = EINVAL;
        return -1;
    }
    if (next < 0) {
        errno = EINVAL;
        return -1;
    }
    file->pos = next;
    return (off_t)file->pos;
}

int close(int fd)
{
    pi4_engine_file_t* file = pi4_file_from_fd(fd);
    if (!file)
        return -1;
    if (file->kernel_fd > 0)
        (void)vibe_user_file_close((pi4_vibe_word_t)file->kernel_fd);
    file->used = 0;
    file->kernel_fd = 0;
    file->data = NULL;
    file->size = 0;
    file->pos = 0;
    file->loaded = 0;
    return 0;
}

int fstat(int fd, struct stat* out)
{
    pi4_engine_file_t* file = pi4_file_from_fd(fd);
    if (!file || !out)
        return -1;
    memset(out, 0, sizeof(*out));
    out->st_mode = S_IFREG | S_IRUSR;
    out->st_size = (off_t)file->size;
    return 0;
}

int stat(const char* path, struct stat* out)
{
    long size;

    if (!out) {
        errno = EINVAL;
        return -1;
    }
    if (!pi4_path_is_doom_wad(path)) {
        errno = ENOENT;
        return -1;
    }
    if (pi4_probe_doom_wad(NULL, &size) < 0) {
        pi4_show_doom_wad_failure_once("DOOM WAD MISSING", "COPY DOOM1.WAD TO PI IMAGE");
        return -1;
    }
    memset(out, 0, sizeof(*out));
    out->st_mode = S_IFREG | S_IRUSR;
    out->st_size = (off_t)size;
    return 0;
}

int access(const char* path, int mode)
{
    if (!pi4_path_is_doom_wad(path)) {
        errno = ENOENT;
        return -1;
    }
    if (mode & W_OK) {
        errno = EACCES;
        return -1;
    }
    if (pi4_probe_doom_wad(NULL, NULL) < 0) {
        pi4_show_doom_wad_failure_once("DOOM WAD MISSING", "COPY DOOM1.WAD TO PI IMAGE");
        return -1;
    }
    return 0;
}

int unlink(const char* path)
{
    (void)path;
    errno = ENOSYS;
    return -1;
}

int mkdir(const char* path, mode_t mode)
{
    (void)path;
    (void)mode;
    return 0;
}

int ftruncate(int fd, off_t length)
{
    (void)fd;
    (void)length;
    errno = ENOSYS;
    return -1;
}

int truncate(const char* path, off_t length)
{
    (void)path;
    (void)length;
    errno = ENOSYS;
    return -1;
}

int fcntl(int fd, int cmd, ...)
{
    (void)fd;
    (void)cmd;
    return 0;
}

int dup(int oldfd)
{
    (void)oldfd;
    errno = ENOSYS;
    return -1;
}

int dup2(int oldfd, int newfd)
{
    (void)oldfd;
    (void)newfd;
    errno = ENOSYS;
    return -1;
}

int dup3(int oldfd, int newfd, int flags)
{
    (void)oldfd;
    (void)newfd;
    (void)flags;
    errno = ENOSYS;
    return -1;
}

void* mmap(void* addr, size_t length, int prot, int flags, int fd, off_t offset)
{
    (void)addr;
    (void)prot;
    (void)flags;
    (void)fd;
    (void)offset;
    return malloc(length);
}

int munmap(void* addr, size_t length)
{
    (void)addr;
    (void)length;
    return 0;
}

FILE* fopen(const char* path, const char* mode)
{
    struct vibe_doom_file* stream;
    int fd;
    if (!mode || mode[0] != 'r') {
        stream = (struct vibe_doom_file*)malloc(sizeof(*stream));
        if (!stream)
            return NULL;
        stream->fd = 2;
        stream->eof = 0;
        stream->error = 0;
        stream->pushed = 0;
        stream->pushback = 0;
        return stream;
    }
    fd = open(path, O_RDONLY);
    if (fd < 0)
        return NULL;
    stream = (struct vibe_doom_file*)malloc(sizeof(*stream));
    if (!stream) {
        close(fd);
        return NULL;
    }
    stream->fd = fd;
    stream->eof = 0;
    stream->error = 0;
    stream->pushed = 0;
    stream->pushback = 0;
    return stream;
}

size_t fread(void* ptr, size_t size, size_t count, FILE* stream)
{
    size_t bytes;
    ssize_t got;
    if (!stream || !size)
        return 0;
    bytes = size * count;
    got = read(stream->fd, ptr, bytes);
    if (got < 0) {
        stream->error = 1;
        return 0;
    }
    if ((size_t)got < bytes)
        stream->eof = 1;
    return (size_t)got / size;
}

size_t fwrite(const void* ptr, size_t size, size_t count, FILE* stream)
{
    size_t bytes;
    if (!stream || !size)
        return 0;
    bytes = size * count;
    if (write(stream->fd, ptr, bytes) < 0) {
        stream->error = 1;
        return 0;
    }
    return count;
}

int fseek(FILE* stream, long offset, int whence)
{
    if (!stream)
        return -1;
    stream->eof = 0;
    return lseek(stream->fd, (off_t)offset, whence) < 0 ? -1 : 0;
}

long ftell(FILE* stream)
{
    if (!stream)
        return -1;
    return (long)lseek(stream->fd, 0, SEEK_CUR);
}

void rewind(FILE* stream)
{
    (void)fseek(stream, 0, SEEK_SET);
}

int fclose(FILE* stream)
{
    int rc = 0;
    if (!stream || stream == stdin || stream == stdout || stream == stderr)
        return 0;
    if (stream->fd >= PI4_ENGINE_FIRST_FD)
        rc = close(stream->fd);
    free(stream);
    return rc;
}

int fflush(FILE* stream)
{
    (void)stream;
    return 0;
}

int feof(FILE* stream)
{
    return stream ? stream->eof : 1;
}

int ferror(FILE* stream)
{
    return stream ? stream->error : 1;
}

void clearerr(FILE* stream)
{
    if (stream) {
        stream->eof = 0;
        stream->error = 0;
    }
}

void setbuf(FILE* stream, char* buffer)
{
    (void)stream;
    (void)buffer;
}

int fgetc(FILE* stream)
{
    unsigned char ch;
    if (!stream)
        return EOF;
    if (stream->pushed) {
        stream->pushed = 0;
        return stream->pushback;
    }
    if (fread(&ch, 1, 1, stream) != 1)
        return EOF;
    return ch;
}

int getc(FILE* stream)
{
    return fgetc(stream);
}

int getchar(void)
{
    return fgetc(stdin);
}

int ungetc(int ch, FILE* stream)
{
    if (!stream || ch == EOF)
        return EOF;
    stream->pushed = 1;
    stream->pushback = (unsigned char)ch;
    stream->eof = 0;
    return ch;
}

char* fgets(char* buffer, int size, FILE* stream)
{
    int i;
    int ch;
    if (!buffer || size <= 0)
        return NULL;
    for (i = 0; i < size - 1; i++) {
        ch = fgetc(stream);
        if (ch == EOF)
            break;
        buffer[i] = (char)ch;
        if (ch == '\n') {
            i++;
            break;
        }
    }
    if (!i)
        return NULL;
    buffer[i] = 0;
    return buffer;
}

int fputc(int ch, FILE* stream)
{
    unsigned char out = (unsigned char)ch;
    return fwrite(&out, 1, 1, stream) == 1 ? ch : EOF;
}

int putc(int ch, FILE* stream)
{
    return fputc(ch, stream);
}

int putchar(int ch)
{
    return fputc(ch, stdout);
}

int fputs(const char* text, FILE* stream)
{
    return fwrite(text, 1, strlen(text), stream) == strlen(text) ? 0 : EOF;
}

int puts(const char* text)
{
    if (fputs(text, stdout) == EOF)
        return EOF;
    return fputc('\n', stdout);
}

int remove(const char* path)
{
    return unlink(path);
}

void perror(const char* text)
{
    if (text)
        fprintf(stderr, "%s: %s\n", text, strerror(errno));
}

static void pi4_out_char(char** out, size_t* remain, int* total, char ch)
{
    if (*remain > 1) {
        **out = ch;
        (*out)++;
        (*remain)--;
    }
    (*total)++;
}

static void pi4_out_text(char** out, size_t* remain, int* total, const char* text)
{
    if (!text)
        text = "(null)";
    while (*text)
        pi4_out_char(out, remain, total, *text++);
}

static void pi4_out_unsigned(char** out, size_t* remain, int* total,
                             unsigned long value, unsigned int base,
                             int width, int zero)
{
    char tmp[32];
    int used = 0;
    int pad;
    do {
        unsigned int digit = (unsigned int)(value % base);
        tmp[used++] = digit < 10 ? (char)('0' + digit) : (char)('a' + digit - 10);
        value /= base;
    } while (value);
    for (pad = used; pad < width; pad++)
        pi4_out_char(out, remain, total, zero ? '0' : ' ');
    while (used--)
        pi4_out_char(out, remain, total, tmp[used]);
}

int vsnprintf(char* buffer, size_t size, const char* format, va_list args)
{
    char* out = buffer;
    size_t remain = size;
    int total = 0;
    while (*format) {
        int width = 0;
        int zero = 0;
        int is_long = 0;
        if (*format != '%') {
            pi4_out_char(&out, &remain, &total, *format++);
            continue;
        }
        format++;
        if (*format == '0') {
            zero = 1;
            format++;
        }
        if (*format == '.') {
            zero = 1;
            format++;
            if (*format == '0') {
                format++;
            }
        }
        while (*format >= '0' && *format <= '9') {
            width = width * 10 + (*format - '0');
            format++;
        }
        if (*format == 'l') {
            is_long = 1;
            format++;
        }
        switch (*format) {
        case 's':
            pi4_out_text(&out, &remain, &total, va_arg(args, const char*));
            break;
        case 'c':
            pi4_out_char(&out, &remain, &total, (char)va_arg(args, int));
            break;
        case 'd':
        case 'i': {
            long value = is_long ? va_arg(args, long) : va_arg(args, int);
            if (value < 0) {
                pi4_out_char(&out, &remain, &total, '-');
                value = -value;
            }
            pi4_out_unsigned(&out, &remain, &total, (unsigned long)value, 10, width, zero);
            break;
        }
        case 'u':
            pi4_out_unsigned(&out, &remain, &total,
                             is_long ? va_arg(args, unsigned long) : va_arg(args, unsigned int),
                             10, width, zero);
            break;
        case 'x':
        case 'X':
            pi4_out_unsigned(&out, &remain, &total,
                             is_long ? va_arg(args, unsigned long) : va_arg(args, unsigned int),
                             16, width, zero);
            break;
        case 'p':
            pi4_out_text(&out, &remain, &total, "0x");
            pi4_out_unsigned(&out, &remain, &total,
                             (unsigned long)va_arg(args, void*), 16, width ? width : 1, 0);
            break;
        case '%':
            pi4_out_char(&out, &remain, &total, '%');
            break;
        default:
            pi4_out_char(&out, &remain, &total, '%');
            pi4_out_char(&out, &remain, &total, *format);
            break;
        }
        if (*format)
            format++;
    }
    if (size) {
        if (remain)
            *out = 0;
        else
            buffer[size - 1] = 0;
    }
    return total;
}

int snprintf(char* buffer, size_t size, const char* format, ...)
{
    va_list args;
    int rc;
    va_start(args, format);
    rc = vsnprintf(buffer, size, format, args);
    va_end(args);
    return rc;
}

int vsprintf(char* buffer, const char* format, va_list args)
{
    return vsnprintf(buffer, (size_t)-1, format, args);
}

int sprintf(char* buffer, const char* format, ...)
{
    va_list args;
    int rc;
    va_start(args, format);
    rc = vsnprintf(buffer, (size_t)-1, format, args);
    va_end(args);
    return rc;
}

int vfprintf(FILE* stream, const char* format, va_list args)
{
    char buffer[1024];
    int rc = vsnprintf(buffer, sizeof(buffer), format, args);
    fwrite(buffer, 1, strlen(buffer), stream);
    return rc;
}

int fprintf(FILE* stream, const char* format, ...)
{
    va_list args;
    int rc;
    va_start(args, format);
    rc = vfprintf(stream, format, args);
    va_end(args);
    return rc;
}

int vprintf(const char* format, va_list args)
{
    return vfprintf(stdout, format, args);
}

int printf(const char* format, ...)
{
    va_list args;
    int rc;
    va_start(args, format);
    rc = vfprintf(stdout, format, args);
    va_end(args);
    return rc;
}

int sscanf(const char* text, const char* format, ...)
{
    va_list args;
    int matched = 0;
    va_start(args, format);
    while (*format) {
        if (*format++ != '%')
            continue;
        while (*format >= '0' && *format <= '9')
            format++;
        if (*format == 'i' || *format == 'd') {
            int* out = va_arg(args, int*);
            *out = (int)strtol(text, (char**)&text, 10);
            matched++;
        } else if (*format == 'x') {
            int* out = va_arg(args, int*);
            *out = (int)strtol(text, (char**)&text, 16);
            matched++;
        } else if (*format == 'c') {
            char* out = va_arg(args, char*);
            *out = *text ? *text++ : 0;
            matched++;
        } else if (*format == 's') {
            char* out = va_arg(args, char*);
            while (pi4_is_space(*text))
                text++;
            while (*text && !pi4_is_space(*text))
                *out++ = *text++;
            *out = 0;
            matched++;
        }
        if (*format)
            format++;
    }
    va_end(args);
    return matched;
}

int fscanf(FILE* stream, const char* format, ...)
{
    (void)stream;
    (void)format;
    return EOF;
}

void exit(int status)
{
    vibe_user_exit(status);
}

void _exit(int status)
{
    vibe_user_exit(status);
}

pid_t fork(void)
{
    errno = ENOSYS;
    return -1;
}

pid_t getpid(void)
{
    return (pid_t)vibe_user_syscall0(PI4_VIBE_SYS_GETPID);
}

int execl(const char* path, const char* arg, ...)
{
    (void)path;
    (void)arg;
    errno = ENOSYS;
    return -1;
}

int execv(const char* path, char* const argv[])
{
    (void)path;
    (void)argv;
    errno = ENOSYS;
    return -1;
}

int execve(const char* path, char* const argv[], char* const envp[])
{
    (void)path;
    (void)argv;
    (void)envp;
    errno = ENOSYS;
    return -1;
}

int clock_gettime(clockid_t clock_id, struct timespec* tp)
{
    pi4_vibe_clock_time_t now;
    long rc = vibe_user_clock_gettime((pi4_vibe_word_t)clock_id, &now);
    if (rc < 0 || !tp) {
        pi4_set_errno_from_result(rc < 0 ? rc : -PI4_VIBE_EINVAL);
        return -1;
    }
    tp->tv_sec = (time_t)(now.milliseconds / 1000ul);
    tp->tv_nsec = (long)((now.milliseconds % 1000ul) * 1000000ul);
    return 0;
}

clock_t clock(void)
{
    return (clock_t)vibe_user_monotonic_ticks();
}

time_t time(time_t* out)
{
    time_t now = (time_t)(vibe_user_monotonic_ticks() / PI4_VIBE_CLOCK_MONOTONIC_HZ);
    if (out)
        *out = now;
    return now;
}
