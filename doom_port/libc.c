#include <ctype.h>
#include <fcntl.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

#include "vibe_os.h"

struct vibe_doom_file {
    int fd;
    int eof;
    int used;
};

typedef struct alloc_header {
    size_t size;
    int free;
    struct alloc_header* prev;
    struct alloc_header* next;
} alloc_header_t;

static struct vibe_doom_file stdin_file = { 0, 0, 1 };
static struct vibe_doom_file stdout_file = { 1, 0, 1 };
static struct vibe_doom_file stderr_file = { 2, 0, 1 };
static alloc_header_t* alloc_head;
static alloc_header_t* alloc_tail;

FILE* stdin = &stdin_file;
FILE* stdout = &stdout_file;
FILE* stderr = &stderr_file;

#ifndef VIBE_LIBC_HOST_TEST
int vibe_syscall3(unsigned int number, unsigned int arg0, unsigned int arg1, unsigned int arg2)
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

    raw = vibe_syscall3(VIBE_SYS_SBRK, (unsigned int)total, 0, 0);
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

static const char* mapped_path(const char* path)
{
    const char* slash = path;
    const char* p;

    for (p = path; *p; ++p)
        if (*p == '/' || *p == '\\')
            slash = p + 1;

    if (!strcasecmp(slash, "doom1.wad"))
        return "DOOM1.WAD";
    return path;
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

void exit(int status)
{
    (void)vibe_syscall3(VIBE_SYS_EXIT, (unsigned int)status, 0, 0);
    for (;;) {
    }
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
    (void)flags;
    return vibe_syscall3(VIBE_SYS_OPEN, (unsigned int)mapped_path(path), 0, 0);
}

ssize_t read(int fd, void* buffer, size_t count)
{
    return vibe_syscall3(VIBE_SYS_READ, (unsigned int)fd, (unsigned int)buffer, (unsigned int)count);
}

ssize_t write(int fd, const void* buffer, size_t count)
{
    return vibe_syscall3(VIBE_SYS_WRITE, (unsigned int)fd, (unsigned int)buffer, (unsigned int)count);
}

int close(int fd)
{
    (void)fd;
    return 0;
}

off_t lseek(int fd, off_t offset, int whence)
{
    return vibe_syscall3(VIBE_SYS_LSEEK, (unsigned int)fd, (unsigned int)offset, (unsigned int)whence);
}

int access(const char* path, int mode)
{
    int fd;
    (void)mode;
    fd = open(path, O_RDONLY);
    if (fd < 0)
        return -1;
    close(fd);
    return 0;
}

int unlink(const char* path)
{
    (void)path;
    return -1;
}

int mkdir(const char* path, mode_t mode)
{
    (void)path;
    (void)mode;
    return 0;
}

int fstat(int fd, struct stat* out)
{
    off_t current = lseek(fd, 0, SEEK_CUR);
    off_t end = lseek(fd, 0, SEEK_END);
    if (current < 0 || end < 0)
        return -1;
    (void)lseek(fd, current, SEEK_SET);
    memset(out, 0, sizeof(*out));
    out->st_size = end;
    out->st_mode = S_IFREG | S_IRUSR;
    return 0;
}

int stat(const char* path, struct stat* out)
{
    int fd = open(path, O_RDONLY);
    int result;
    if (fd < 0)
        return -1;
    result = fstat(fd, out);
    close(fd);
    return result;
}

FILE* fopen(const char* path, const char* mode)
{
    static FILE file_pool[4];
    int fd;
    int i;
    (void)mode;
    fd = open(path, O_RDONLY);
    if (fd < 0)
        return 0;
    for (i = 0; i < 4; ++i) {
        if (!file_pool[i].used) {
            file_pool[i].used = 1;
            file_pool[i].fd = fd;
            file_pool[i].eof = 0;
            return &file_pool[i];
        }
    }
    close(fd);
    return 0;
}

size_t fread(void* ptr, size_t size, size_t count, FILE* stream)
{
    int bytes;
    if (!size || !count)
        return 0;
    bytes = read(stream->fd, ptr, size * count);
    if (bytes <= 0) {
        stream->eof = 1;
        return 0;
    }
    if ((size_t)bytes < size * count)
        stream->eof = 1;
    return (size_t)bytes / size;
}

size_t fwrite(const void* ptr, size_t size, size_t count, FILE* stream)
{
    int bytes = write(stream->fd, ptr, size * count);
    return bytes < 0 || !size ? 0 : (size_t)bytes / size;
}

int fseek(FILE* stream, long offset, int whence)
{
    return lseek(stream->fd, (off_t)offset, whence) < 0 ? -1 : 0;
}

long ftell(FILE* stream)
{
    return (long)lseek(stream->fd, 0, SEEK_CUR);
}

int fclose(FILE* stream)
{
    int result = close(stream->fd);
    stream->fd = -1;
    stream->eof = 1;
    stream->used = 0;
    return result;
}

int fflush(FILE* stream)
{
    (void)stream;
    return 0;
}

int feof(FILE* stream)
{
    return stream->eof;
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

static void out_char(char** out, size_t* left, int fd, char ch)
{
    if (out) {
        if (*left > 1) {
            **out = ch;
            ++*out;
            --*left;
        }
    } else {
        (void)write(fd, &ch, 1);
    }
}

static void out_string(char** out, size_t* left, int fd, const char* text)
{
    if (!text)
        text = "(null)";
    while (*text)
        out_char(out, left, fd, *text++);
}

static void out_unsigned(char** out, size_t* left, int fd, unsigned int value, int base, int width, int pad_zero)
{
    char tmp[16];
    int pos = 0;
    do {
        unsigned int digit = value % (unsigned int)base;
        tmp[pos++] = digit < 10 ? (char)('0' + digit) : (char)('a' + digit - 10);
        value /= (unsigned int)base;
    } while (value);
    while (pos < width)
        tmp[pos++] = pad_zero ? '0' : ' ';
    while (pos--)
        out_char(out, left, fd, tmp[pos]);
}

static int format_to(char* buffer, size_t size, int fd, const char* format, va_list args)
{
    char* out = buffer;
    size_t left = size;
    const char* start = buffer;

    while (*format) {
        int width = 0;
        int pad_zero = 0;
        if (*format != '%') {
            out_char(buffer ? &out : 0, &left, fd, *format++);
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
            while (isdigit((unsigned char)*format))
                ++format;
        }
        switch (*format++) {
        case 's':
            out_string(buffer ? &out : 0, &left, fd, va_arg(args, const char*));
            break;
        case 'c':
            out_char(buffer ? &out : 0, &left, fd, (char)va_arg(args, int));
            break;
        case 'd':
        case 'i': {
            int value = va_arg(args, int);
            if (value < 0) {
                out_char(buffer ? &out : 0, &left, fd, '-');
                value = -value;
            }
            out_unsigned(buffer ? &out : 0, &left, fd, (unsigned int)value, 10, width, pad_zero);
            break;
        }
        case 'u':
            out_unsigned(buffer ? &out : 0, &left, fd, va_arg(args, unsigned int), 10, width, pad_zero);
            break;
        case 'x':
        case 'p':
            out_unsigned(buffer ? &out : 0, &left, fd, va_arg(args, unsigned int), 16, width, pad_zero);
            break;
        case '%':
            out_char(buffer ? &out : 0, &left, fd, '%');
            break;
        default:
            break;
        }
    }
    if (buffer && size)
        *out = 0;
    return buffer ? (int)(out - start) : 0;
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
    return format_to(0, 0, stream->fd, format, args);
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

int sscanf(const char* text, const char* format, ...)
{
    va_list args;
    int assigned = 0;
    va_start(args, format);
    while (*format && *text) {
        if (*format++ != '%')
            continue;
        if (*format == 'i' || *format == 'd') {
            *va_arg(args, int*) = atoi(text);
            ++assigned;
        } else if (*format == 'x') {
            int value = 0;
            while (isxdigit((unsigned char)*text)) {
                int ch = tolower((unsigned char)*text++);
                value = value * 16 + (isdigit(ch) ? ch - '0' : ch - 'a' + 10);
            }
            *va_arg(args, int*) = value;
            ++assigned;
        }
        ++format;
    }
    va_end(args);
    return assigned;
}

int fscanf(FILE* stream, const char* format, ...)
{
    (void)stream;
    (void)format;
    return EOF;
}
