#include <ctype.h>
#include <errno.h>
#include <fcntl.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
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
#define VIBE_LONG_MAX_VALUE 0x7fffffffl
#define VIBE_LONG_MIN_VALUE (-VIBE_LONG_MAX_VALUE - 1l)
#define VIBE_ULONG_MAX_VALUE 0xfffffffful
#define VIBE_DOUBLE_MAX_VALUE 1.7976931348623157e308

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
static unsigned int rand_state = 1;

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

static void clone_save_fd_tracking(int oldfd, int newfd)
{
    int slot = tracked_save_slot_for_fd(oldfd);
    if (slot >= 0)
        track_save_fd(newfd, slot);
    else
        untrack_save_fd(newfd);
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

int vibe_syscall_errno(int raw_result, int fallback_errno)
{
    if (raw_result >= 0)
        return 0;
    if (raw_result < -1)
        return -raw_result;
    return fallback_errno > 0 ? fallback_errno : EIO;
}

static int syscall_failed(int raw, int fallback_errno)
{
    errno = vibe_syscall_errno(raw, fallback_errno);
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

void* memchr(const void* data, int ch, size_t count)
{
    const unsigned char* p = data;
    unsigned char needle = (unsigned char)ch;

    while (count--) {
        if (*p == needle)
            return (void*)p;
        ++p;
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

size_t strnlen(const char* text, size_t max_length)
{
    size_t length = 0;

    while (length < max_length && text[length])
        ++length;
    return length;
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

static int string_set_contains(const char* set, int ch)
{
    if (!set)
        return 0;
    while (*set) {
        if ((unsigned char)*set == (unsigned char)ch)
            return 1;
        ++set;
    }
    return 0;
}

size_t strspn(const char* text, const char* accept)
{
    const char* start = text;

    if (!text || !accept)
        return 0;
    while (*text && string_set_contains(accept, (unsigned char)*text))
        ++text;
    return (size_t)(text - start);
}

size_t strcspn(const char* text, const char* reject)
{
    const char* start = text;

    if (!text || !reject)
        return 0;
    while (*text && !string_set_contains(reject, (unsigned char)*text))
        ++text;
    return (size_t)(text - start);
}

char* strpbrk(const char* text, const char* accept)
{
    if (!text || !accept)
        return 0;
    while (*text) {
        if (string_set_contains(accept, (unsigned char)*text))
            return (char*)text;
        ++text;
    }
    return 0;
}

char* strstr(const char* text, const char* needle)
{
    size_t needle_length;

    if (!text || !needle)
        return 0;
    if (!*needle)
        return (char*)text;

    needle_length = strlen(needle);
    while (*text) {
        if (*text == *needle && !strncmp(text, needle, needle_length))
            return (char*)text;
        ++text;
    }
    return 0;
}

char* strtok_r(char* text, const char* delimiters, char** saveptr)
{
    char* token;

    if (!delimiters || !saveptr)
        return 0;
    if (!text)
        text = *saveptr;
    if (!text)
        return 0;

    text += strspn(text, delimiters);
    if (!*text) {
        *saveptr = 0;
        return 0;
    }

    token = text;
    text += strcspn(text, delimiters);
    if (*text) {
        *text = 0;
        *saveptr = text + 1;
    } else {
        *saveptr = 0;
    }
    return token;
}

char* strtok(char* text, const char* delimiters)
{
    static char* next_token;

    return strtok_r(text, delimiters, &next_token);
}

char* strdup(const char* text)
{
    size_t len = strlen(text) + 1;
    char* copy = malloc(len);
    if (copy)
        memcpy(copy, text, len);
    return copy;
}

char* strndup(const char* text, size_t max_length)
{
    size_t len = strnlen(text, max_length);
    char* copy = malloc(len + 1);

    if (!copy)
        return 0;
    memcpy(copy, text, len);
    copy[len] = 0;
    return copy;
}

char* strerror(int error)
{
    switch (error) {
    case EPERM:
        return "Operation not permitted";
    case ENOENT:
        return "No such file or directory";
    case EIO:
        return "I/O error";
    case EBADF:
        return "Bad file descriptor";
    case ECHILD:
        return "No child processes";
    case ENOMEM:
        return "Out of memory";
    case EACCES:
        return "Permission denied";
    case ENOTDIR:
        return "Not a directory";
    case EISDIR:
        return "Is a directory";
    case EINVAL:
        return "Invalid argument";
    case EMFILE:
        return "Too many open files";
    case ENOTTY:
        return "Inappropriate ioctl for device";
    case ENOSPC:
        return "No space left on device";
    case ERANGE:
        return "Result out of range";
    case ENOSYS:
        return "Function not implemented";
    case EOVERFLOW:
        return "Value too large";
    default:
        return "Unknown error";
    }
}

static int integer_digit_value(int ch)
{
    if (ch >= '0' && ch <= '9')
        return ch - '0';
    if (ch >= 'a' && ch <= 'z')
        return ch - 'a' + 10;
    if (ch >= 'A' && ch <= 'Z')
        return ch - 'A' + 10;
    return -1;
}

static int integer_digit_valid(int ch, int base)
{
    int digit = integer_digit_value(ch);
    return digit >= 0 && digit < base;
}

static const char* integer_parse_prefix(const char* p, int* base)
{
    if (*base == 0) {
        if (p[0] == '0' && (p[1] == 'x' || p[1] == 'X') && integer_digit_valid(p[2], 16)) {
            *base = 16;
            return p + 2;
        }
        if (p[0] == '0') {
            *base = 8;
            return p;
        }
        *base = 10;
        return p;
    }

    if (*base == 16 && p[0] == '0' && (p[1] == 'x' || p[1] == 'X') && integer_digit_valid(p[2], 16))
        return p + 2;
    return p;
}

unsigned long strtoul(const char* text, char** endptr, int base)
{
    const char* start = text;
    const char* p;
    unsigned long value = 0;
    int negative = 0;
    int digits = 0;
    int overflow = 0;

    if (endptr)
        *endptr = (char*)text;
    if (!text || (base != 0 && (base < 2 || base > 36))) {
        errno = EINVAL;
        return 0;
    }

    p = text;
    while (isspace((unsigned char)*p))
        ++p;
    if (*p == '-' || *p == '+') {
        negative = *p == '-';
        ++p;
    }
    p = integer_parse_prefix(p, &base);

    while (*p) {
        int digit = integer_digit_value((unsigned char)*p);
        if (digit < 0 || digit >= base)
            break;
        if (value > (VIBE_ULONG_MAX_VALUE - (unsigned long)digit) / (unsigned long)base) {
            overflow = 1;
        } else if (!overflow) {
            value = value * (unsigned long)base + (unsigned long)digit;
        }
        ++digits;
        ++p;
    }

    if (!digits) {
        if (endptr)
            *endptr = (char*)start;
        return 0;
    }

    if (overflow) {
        errno = ERANGE;
        value = VIBE_ULONG_MAX_VALUE;
    } else if (negative && value) {
        value = VIBE_ULONG_MAX_VALUE - value + 1ul;
    }

    if (endptr)
        *endptr = (char*)p;
    return value;
}

long strtol(const char* text, char** endptr, int base)
{
    const char* start = text;
    const char* p;
    unsigned long value = 0;
    unsigned long limit;
    int negative = 0;
    int digits = 0;
    int overflow = 0;

    if (endptr)
        *endptr = (char*)text;
    if (!text || (base != 0 && (base < 2 || base > 36))) {
        errno = EINVAL;
        return 0;
    }

    p = text;
    while (isspace((unsigned char)*p))
        ++p;
    if (*p == '-' || *p == '+') {
        negative = *p == '-';
        ++p;
    }
    p = integer_parse_prefix(p, &base);
    limit = negative ? (unsigned long)VIBE_LONG_MAX_VALUE + 1ul : (unsigned long)VIBE_LONG_MAX_VALUE;

    while (*p) {
        int digit = integer_digit_value((unsigned char)*p);
        if (digit < 0 || digit >= base)
            break;
        if (value > (limit - (unsigned long)digit) / (unsigned long)base) {
            overflow = 1;
        } else if (!overflow) {
            value = value * (unsigned long)base + (unsigned long)digit;
        }
        ++digits;
        ++p;
    }

    if (!digits) {
        if (endptr)
            *endptr = (char*)start;
        return 0;
    }

    if (overflow) {
        errno = ERANGE;
        if (endptr)
            *endptr = (char*)p;
        return negative ? VIBE_LONG_MIN_VALUE : VIBE_LONG_MAX_VALUE;
    }

    if (endptr)
        *endptr = (char*)p;
    if (negative && value == (unsigned long)VIBE_LONG_MAX_VALUE + 1ul)
        return VIBE_LONG_MIN_VALUE;
    return negative ? -(long)value : (long)value;
}

static double scale_decimal_double(double value, int exponent, int negative)
{
    double original = value;

    while (exponent > 0) {
        if (value > VIBE_DOUBLE_MAX_VALUE / 10.0) {
            errno = ERANGE;
            return negative ? -VIBE_DOUBLE_MAX_VALUE : VIBE_DOUBLE_MAX_VALUE;
        }
        value *= 10.0;
        --exponent;
    }

    while (exponent < 0) {
        value /= 10.0;
        ++exponent;
    }

    if (original != 0.0 && value == 0.0)
        errno = ERANGE;
    return negative ? -value : value;
}

double strtod(const char* text, char** endptr)
{
    const char* start = text;
    const char* p;
    const char* exponent_start;
    double value = 0.0;
    int negative = 0;
    int digits = 0;
    int fraction_exponent = 0;
    int exponent_sign = 1;
    int exponent_value = 0;
    int exponent_digits = 0;
    int exponent_overflow = 0;
    int exponent;

    if (endptr)
        *endptr = (char*)text;
    if (!text) {
        errno = EINVAL;
        return 0.0;
    }

    p = text;
    while (isspace((unsigned char)*p))
        ++p;
    if (*p == '-' || *p == '+') {
        negative = *p == '-';
        ++p;
    }

    while (isdigit((unsigned char)*p)) {
        value = value * 10.0 + (double)(*p - '0');
        ++digits;
        ++p;
    }

    if (*p == '.') {
        ++p;
        while (isdigit((unsigned char)*p)) {
            value = value * 10.0 + (double)(*p - '0');
            --fraction_exponent;
            ++digits;
            ++p;
        }
    }

    if (!digits) {
        if (endptr)
            *endptr = (char*)start;
        return 0.0;
    }

    exponent_start = p;
    if (*p == 'e' || *p == 'E') {
        ++p;
        if (*p == '-' || *p == '+') {
            exponent_sign = *p == '-' ? -1 : 1;
            ++p;
        }
        while (isdigit((unsigned char)*p)) {
            if (exponent_value > 400)
                exponent_overflow = 1;
            else
                exponent_value = exponent_value * 10 + (*p - '0');
            ++exponent_digits;
            ++p;
        }
        if (!exponent_digits) {
            p = exponent_start;
            exponent_value = 0;
            exponent_sign = 1;
            exponent_overflow = 0;
        }
    }

    if (endptr)
        *endptr = (char*)p;
    if (exponent_overflow) {
        errno = ERANGE;
        return exponent_sign < 0 ? (negative ? -0.0 : 0.0)
                                 : (negative ? -VIBE_DOUBLE_MAX_VALUE : VIBE_DOUBLE_MAX_VALUE);
    }

    exponent = fraction_exponent + exponent_sign * exponent_value;
    return scale_decimal_double(value, exponent, negative);
}

double atof(const char* text)
{
    return strtod(text, 0);
}

int atoi(const char* text)
{
    return (int)strtol(text, 0, 10);
}

long atol(const char* text)
{
    return strtol(text, 0, 10);
}

long labs(long value)
{
    return value < 0 ? -value : value;
}

static void qsort_swap_bytes(unsigned char* left, unsigned char* right, size_t size)
{
    unsigned char tmp;

    while (size--) {
        tmp = *left;
        *left++ = *right;
        *right++ = tmp;
    }
}

void qsort(void* base, size_t count, size_t size, int (*compar)(const void*, const void*))
{
    unsigned char* bytes = base;
    size_t index;
    size_t cursor;

    if (!bytes || !compar || !size || count < 2)
        return;

    for (index = 1; index < count; ++index) {
        cursor = index;
        while (cursor > 0
            && compar(bytes + (cursor - 1) * size, bytes + cursor * size) > 0) {
            qsort_swap_bytes(bytes + (cursor - 1) * size, bytes + cursor * size, size);
            --cursor;
        }
    }
}

void* bsearch(
    const void* key,
    const void* base,
    size_t count,
    size_t size,
    int (*compar)(const void*, const void*))
{
    const unsigned char* bytes = base;
    size_t low = 0;
    size_t high = count;
    size_t middle;
    const void* element;
    int order;

    if (!key || !bytes || !compar || !size)
        return 0;

    while (low < high) {
        middle = low + (high - low) / 2;
        element = bytes + middle * size;
        order = compar(key, element);

        if (order < 0)
            high = middle;
        else if (order > 0)
            low = middle + 1;
        else
            return (void*)element;
    }

    return 0;
}

void* malloc(size_t size)
{
    alloc_header_t* block;

    if (!size)
        return 0;
    if (size > (size_t)-1 - 15) {
        errno = ENOMEM;
        return 0;
    }

    size = align16(size);
    block = alloc_find_free(size);
    if (!block)
        block = alloc_request(size);
    if (!block) {
        errno = ENOMEM;
        return 0;
    }

    block->free = 0;
    alloc_split(block, size);
    return alloc_payload(block);
}

void* calloc(size_t count, size_t size)
{
    size_t total;
    void* ptr;

    if (size && count > (size_t)-1 / size) {
        errno = ENOMEM;
        return 0;
    }

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
    if (size > (size_t)-1 - 15) {
        errno = ENOMEM;
        return 0;
    }

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
    rand_state = rand_state * 1103515245u + 12345u;
    return (int)((rand_state >> 16) & 0x7fff);
}

void srand(unsigned int seed)
{
    rand_state = seed;
}

static double x87_round_with_mode(double value, unsigned short rounding_mode)
{
    unsigned short control_word;
    unsigned short rounded_control_word;
    double result;

    __asm__ volatile("fnstcw %0" : "=m"(control_word));
    rounded_control_word = (unsigned short)((control_word & 0xf3ffu) | rounding_mode);
    __asm__ volatile(
        "fldcw %1\n"
        "fldl %2\n"
        "frndint\n"
        "fstpl %0\n"
        "fldcw %3"
        : "=m"(result)
        : "m"(rounded_control_word), "m"(value), "m"(control_word)
        : "memory");
    return result;
}

double fabs(double x)
{
    double result;
    __asm__ volatile("fldl %1; fabs; fstpl %0" : "=m"(result) : "m"(x));
    return result;
}

double sqrt(double x)
{
    double result;
    __asm__ volatile("fldl %1; fsqrt; fstpl %0" : "=m"(result) : "m"(x));
    return result;
}

double floor(double x)
{
    return x87_round_with_mode(x, 0x0400u);
}

double ceil(double x)
{
    return x87_round_with_mode(x, 0x0800u);
}

double sin(double x)
{
    double result;
    __asm__ volatile("fldl %1; fsin; fstpl %0" : "=m"(result) : "m"(x));
    return result;
}

double cos(double x)
{
    double result;
    __asm__ volatile("fldl %1; fcos; fstpl %0" : "=m"(result) : "m"(x));
    return result;
}

double atan(double x)
{
    double result;
    __asm__ volatile("fldl %1; fld1; fpatan; fstpl %0" : "=m"(result) : "m"(x));
    return result;
}

double atan2(double y, double x)
{
    double result;
    __asm__ volatile("fldl %1; fldl %2; fpatan; fstpl %0" : "=m"(result) : "m"(y), "m"(x));
    return result;
}

double pow(double x, double y)
{
    double result;
    __asm__ volatile(
        "fldl %2\n"
        "fldl %1\n"
        "fyl2x\n"
        "fld %%st(0)\n"
        "frndint\n"
        "fxch %%st(1)\n"
        "fsub %%st(1), %%st(0)\n"
        "f2xm1\n"
        "fld1\n"
        "faddp %%st(0), %%st(1)\n"
        "fscale\n"
        "fstp %%st(1)\n"
        "fstpl %0"
        : "=m"(result)
        : "m"(x), "m"(y));
    return result;
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

int dup(int oldfd)
{
    int raw = vibe_syscall3(VIBE_SYS_DUP, (unsigned long)oldfd, 0, 0);
    if (raw >= 0)
        clone_save_fd_tracking(oldfd, raw);
    return raw < 0 ? syscall_failed(raw, EBADF) : raw;
}

int dup2(int oldfd, int newfd)
{
    int raw = vibe_syscall3(VIBE_SYS_DUP2, (unsigned long)oldfd, (unsigned long)newfd, 0);
    if (raw >= 0)
        clone_save_fd_tracking(oldfd, raw);
    return raw < 0 ? syscall_failed(raw, EBADF) : raw;
}

int dup3(int oldfd, int newfd, int flags)
{
    int raw;

    if (flags & ~O_CLOEXEC) {
        errno = EINVAL;
        return -1;
    }

    raw = vibe_syscall3(VIBE_SYS_DUP3, (unsigned long)oldfd, (unsigned long)newfd, (unsigned long)flags);
    if (raw >= 0)
        clone_save_fd_tracking(oldfd, raw);
    return raw < 0 ? syscall_failed(raw, EBADF) : raw;
}

int fcntl(int fd, int cmd, ...)
{
    unsigned long arg = 0;
    int raw;
    va_list args;

    if (cmd == F_SETFD) {
        va_start(args, cmd);
        arg = (unsigned long)va_arg(args, int);
        va_end(args);
        if (arg & ~FD_CLOEXEC) {
            errno = EINVAL;
            return -1;
        }
    } else if (cmd != F_GETFD) {
        errno = EINVAL;
        return -1;
    }

    raw = vibe_syscall3(VIBE_SYS_FCNTL, (unsigned long)fd, (unsigned long)cmd, arg);
    return raw < 0 ? syscall_failed(raw, EBADF) : raw;
}

off_t lseek(int fd, off_t offset, int whence)
{
    int raw = vibe_syscall3(VIBE_SYS_LSEEK, (unsigned long)fd, (unsigned long)offset, (unsigned long)whence);
    return raw < 0 ? syscall_failed(raw, EINVAL) : raw;
}

static ssize_t positioned_io(
    int fd,
    void* buffer,
    size_t count,
    off_t offset,
    int write_mode)
{
    off_t original;
    ssize_t result;
    int saved_errno;

    if (offset < 0 || (!buffer && count)) {
        errno = EINVAL;
        return -1;
    }

    original = lseek(fd, 0, SEEK_CUR);
    if (original < 0)
        return -1;

    if (lseek(fd, offset, SEEK_SET) < 0) {
        saved_errno = errno;
        (void)lseek(fd, original, SEEK_SET);
        errno = saved_errno;
        return -1;
    }

    result = write_mode ? write(fd, buffer, count) : read(fd, buffer, count);
    saved_errno = errno;

    if (lseek(fd, original, SEEK_SET) < 0) {
        if (result < 0)
            errno = saved_errno;
        return -1;
    }

    if (result < 0)
        errno = saved_errno;
    return result;
}

ssize_t pread(int fd, void* buffer, size_t count, off_t offset)
{
    return positioned_io(fd, buffer, count, offset, 0);
}

ssize_t pwrite(int fd, const void* buffer, size_t count, off_t offset)
{
    return positioned_io(fd, (void*)buffer, count, offset, 1);
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

int vibe_clock_monotonic(vibe_clock_time_t* out)
{
    return vibe_clock_gettime(VIBE_CLOCK_MONOTONIC, out);
}

static unsigned long scale_remainder_ticks_to_milliseconds(
    unsigned long remainder_ticks,
    unsigned long frequency_hz)
{
    unsigned long accumulator = 0;
    unsigned long milliseconds = 0;
    unsigned int step;

    if (!remainder_ticks || !frequency_hz)
        return 0;

    for (step = 0; step < 1000u; ++step) {
        unsigned long gap = frequency_hz - accumulator;
        if (remainder_ticks >= gap) {
            accumulator = remainder_ticks - gap;
            ++milliseconds;
        } else {
            accumulator += remainder_ticks;
        }
    }
    return milliseconds;
}

unsigned long vibe_clock_ticks_to_milliseconds(unsigned long ticks, unsigned long frequency_hz)
{
    unsigned long whole_seconds;
    unsigned long remainder_ticks;

    if (!frequency_hz)
        return 0;
    whole_seconds = ticks / frequency_hz;
    remainder_ticks = ticks - whole_seconds * frequency_hz;
    if (whole_seconds > ((unsigned long)-1) / 1000ul)
        return (unsigned long)-1;
    return whole_seconds * 1000ul
        + scale_remainder_ticks_to_milliseconds(remainder_ticks, frequency_hz);
}

unsigned long vibe_monotonic_ticks(void)
{
    vibe_clock_time_t now;

    if (vibe_clock_monotonic(&now) < 0)
        return 0;
    return now.ticks;
}

unsigned long vibe_monotonic_milliseconds(void)
{
    vibe_clock_time_t now;

    if (vibe_clock_monotonic(&now) < 0)
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

    if (vibe_clock_monotonic(&now) < 0)
        return -1;

    tp->tv_sec = (time_t)(now.milliseconds / 1000u);
    tp->tv_nsec = (long)((now.milliseconds % 1000u) * 1000000u);
    return 0;
}

clock_t clock(void)
{
    return (clock_t)vibe_monotonic_milliseconds();
}

time_t time(time_t* out)
{
    if (out)
        *out = (time_t)-1;
    errno = ENOSYS;
    return (time_t)-1;
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

int vibe_file_size(const char* path, unsigned long* out_size)
{
    struct stat st;

    if (!path || !out_size) {
        errno = EINVAL;
        return -1;
    }

    if (stat(path, &st) < 0)
        return -1;
    if (!S_ISREG(st.st_mode)) {
        errno = EISDIR;
        return -1;
    }
    if (st.st_size < 0) {
        errno = EOVERFLOW;
        return -1;
    }

    *out_size = (unsigned long)st.st_size;
    return 0;
}

int vibe_file_read_at(
    const char* path,
    unsigned long offset,
    void* buffer,
    unsigned long count,
    unsigned long* out_read)
{
    int fd;
    ssize_t got;
    int saved_errno;

    if (!path || (count && !buffer)) {
        errno = EINVAL;
        return -1;
    }
    if (offset > 0x7ffffffful) {
        errno = EOVERFLOW;
        return -1;
    }

    fd = open(path, O_RDONLY);
    if (fd < 0)
        return -1;

    got = pread(fd, buffer, count, (off_t)offset);
    saved_errno = errno;
    if (close(fd) < 0 && got >= 0)
        return -1;
    if (got < 0) {
        errno = saved_errno;
        return -1;
    }

    if (out_read)
        *out_read = (unsigned long)got;
    return 0;
}

int vibe_file_read_all(const char* path, void* buffer, unsigned long capacity, unsigned long* out_size)
{
    unsigned long size;
    unsigned long done;
    int fd;
    int saved_errno;
    ssize_t got;

    if (!path || (capacity && !buffer)) {
        errno = EINVAL;
        return -1;
    }

    if (vibe_file_size(path, &size) < 0)
        return -1;
    if (out_size)
        *out_size = size;
    if (size > capacity) {
        errno = ENOSPC;
        return -1;
    }

    fd = open(path, O_RDONLY);
    if (fd < 0)
        return -1;

    done = 0;
    while (done < size) {
        got = read(fd, (unsigned char*)buffer + done, size - done);
        if (got < 0) {
            saved_errno = errno;
            (void)close(fd);
            errno = saved_errno;
            return -1;
        }
        if (got == 0) {
            saved_errno = EIO;
            (void)close(fd);
            errno = saved_errno;
            return -1;
        }
        done += (unsigned long)got;
    }

    if (close(fd) < 0)
        return -1;
    return 0;
}

int vibe_audio_device_start(void)
{
    int raw;

    raw = vibe_syscall3(VIBE_SYS_AUDIO, VIBE_AUDIO_DEVICE_START, 0, 0);
    return raw < 0 ? syscall_failed(raw, EIO) : raw;
}

int vibe_audio_device_shutdown(void)
{
    int raw;

    raw = vibe_syscall3(VIBE_SYS_AUDIO, VIBE_AUDIO_DEVICE_SHUTDOWN, 0, 0);
    return raw < 0 ? syscall_failed(raw, EIO) : raw;
}

int vibe_audio_mixer_start(unsigned long handle, const vibe_audio_voice_desc_t* desc)
{
    int raw;

    if (!desc) {
        errno = EINVAL;
        return -1;
    }

    raw = vibe_syscall3(
        VIBE_SYS_AUDIO,
        VIBE_AUDIO_MIXER_START,
        handle,
        (unsigned long)desc);
    return raw < 0 ? syscall_failed(raw, EINVAL) : raw;
}

int vibe_audio_mixer_stop(unsigned long handle)
{
    int raw;

    raw = vibe_syscall3(VIBE_SYS_AUDIO, VIBE_AUDIO_MIXER_STOP, handle, 0);
    return raw < 0 ? syscall_failed(raw, EINVAL) : raw;
}

int vibe_audio_mixer_update(unsigned long handle, const vibe_audio_voice_desc_t* desc)
{
    int raw;

    if (!desc) {
        errno = EINVAL;
        return -1;
    }

    raw = vibe_syscall3(
        VIBE_SYS_AUDIO,
        VIBE_AUDIO_MIXER_UPDATE,
        handle,
        (unsigned long)desc);
    return raw < 0 ? syscall_failed(raw, EINVAL) : raw;
}

int vibe_audio_mixer_is_playing(unsigned long handle)
{
    int raw;

    raw = vibe_syscall3(VIBE_SYS_AUDIO, VIBE_AUDIO_MIXER_IS_PLAYING, handle, 0);
    return raw < 0 ? syscall_failed(raw, EINVAL) : raw;
}

int vibe_audio_pcm_buffered_bytes(unsigned long handle)
{
    int raw;

    raw = vibe_syscall3(VIBE_SYS_AUDIO, VIBE_AUDIO_PCM_BUFFERED_BYTES, handle, 0);
    return raw < 0 ? syscall_failed(raw, EINVAL) : raw;
}

int vibe_audio_pcm_pull_state(unsigned long handle)
{
    int raw;

    raw = vibe_syscall3(VIBE_SYS_AUDIO, VIBE_AUDIO_PCM_PULL_STATE, handle, 0);
    return raw < 0 ? syscall_failed(raw, EINVAL) : raw;
}

int vibe_audio_device_info(vibe_audio_device_info_t* info)
{
    int raw;

    if (!info) {
        errno = EINVAL;
        return -1;
    }

    raw = vibe_syscall3(VIBE_SYS_AUDIO, VIBE_AUDIO_DEVICE_INFO, (unsigned long)info, 0);
    return raw < 0 ? syscall_failed(raw, EINVAL) : raw;
}

int vibe_audio_pcm_ring_info(vibe_audio_pcm_ring_info_t* info)
{
    int raw;

    if (!info) {
        errno = EINVAL;
        return -1;
    }

    raw = vibe_syscall3(VIBE_SYS_AUDIO, VIBE_AUDIO_PCM_RING_INFO, (unsigned long)info, 0);
    return raw < 0 ? syscall_failed(raw, EINVAL) : raw;
}

int vibe_audio_stream_info(unsigned long handle, vibe_audio_stream_info_t* info)
{
    int raw;

    if (!info) {
        errno = EINVAL;
        return -1;
    }

    raw = vibe_syscall3(VIBE_SYS_AUDIO, VIBE_AUDIO_STREAM_INFO, handle, (unsigned long)info);
    return raw < 0 ? syscall_failed(raw, EINVAL) : raw;
}

int vibe_audio_device_info_ioctl(vibe_audio_device_info_t* info)
{
    if (!info) {
        errno = EINVAL;
        return -1;
    }

    return ioctl(VIBE_AUDIO_FD, VIBE_IOCTL_AUDIO_DEVICE_INFO, info);
}

int vibe_audio_pcm_ring_info_ioctl(vibe_audio_pcm_ring_info_t* info)
{
    if (!info) {
        errno = EINVAL;
        return -1;
    }

    return ioctl(VIBE_AUDIO_FD, VIBE_IOCTL_AUDIO_PCM_RING_INFO, info);
}

int vibe_audio_stream_info_ioctl(unsigned long handle, vibe_audio_stream_info_t* info)
{
    if (!info) {
        errno = EINVAL;
        return -1;
    }

    info->handle = handle;
    return ioctl(VIBE_AUDIO_FD, VIBE_IOCTL_AUDIO_STREAM_INFO, info);
}

int vibe_audio_pcm_open(const vibe_audio_pcm_desc_t* format)
{
    int raw;

    raw = vibe_syscall3(VIBE_SYS_AUDIO, VIBE_AUDIO_PCM_OPEN, 0, (unsigned long)format);
    return raw < 0 ? syscall_failed(raw, raw == -5 ? EIO : EINVAL) : raw;
}

int vibe_audio_pcm_write(unsigned long handle, const vibe_audio_voice_desc_t* desc)
{
    int raw;

    if (!desc) {
        errno = EINVAL;
        return -1;
    }

    raw = vibe_syscall3(VIBE_SYS_AUDIO, VIBE_AUDIO_PCM_WRITE, handle, (unsigned long)desc);
    return raw < 0 ? syscall_failed(raw, raw == -5 ? EIO : EINVAL) : raw;
}

int vibe_audio_pcm_write_desc(unsigned long handle, const vibe_audio_pcm_desc_t* desc)
{
    int raw;

    if (!desc) {
        errno = EINVAL;
        return -1;
    }

    raw = vibe_syscall3(VIBE_SYS_AUDIO, VIBE_AUDIO_PCM_WRITE_DESC, handle, (unsigned long)desc);
    return raw < 0 ? syscall_failed(raw, raw == -5 ? EIO : EINVAL) : raw;
}

int vibe_audio_pcm_drain(unsigned long handle)
{
    int raw;

    raw = vibe_syscall3(VIBE_SYS_AUDIO, VIBE_AUDIO_PCM_DRAIN, handle, 0);
    return raw < 0 ? syscall_failed(raw, EINVAL) : raw;
}

int vibe_audio_pcm_close(unsigned long handle)
{
    int raw;

    raw = vibe_syscall3(VIBE_SYS_AUDIO, VIBE_AUDIO_PCM_CLOSE, handle, 0);
    return raw < 0 ? syscall_failed(raw, EINVAL) : raw;
}

int vibe_audio_stream_open(const vibe_audio_pcm_desc_t* format)
{
    return vibe_audio_pcm_open(format);
}

int vibe_audio_stream_write(unsigned long handle, const vibe_audio_voice_desc_t* desc)
{
    return vibe_audio_pcm_write(handle, desc);
}

int vibe_audio_stream_drain(unsigned long handle)
{
    return vibe_audio_pcm_drain(handle);
}

int vibe_audio_stream_close(unsigned long handle)
{
    return vibe_audio_pcm_close(handle);
}

int vibe_poll_input(vibe_input_event_t* event)
{
    int raw;
    if (!event) {
        errno = EINVAL;
        return -1;
    }
    raw = vibe_syscall3(
        VIBE_SYS_POLL_INPUT,
        (unsigned long)event,
        (unsigned long)sizeof(*event),
        0);
    return raw < 0 ? syscall_failed(raw, EINVAL) : raw;
}

int vibe_drain_input(vibe_input_event_t* events, unsigned long max_events)
{
    unsigned long count;
    int raw;

    if (max_events && !events) {
        errno = EINVAL;
        return -1;
    }

    count = 0;
    while (count < max_events) {
        raw = vibe_poll_input(&events[count]);
        if (raw < 0)
            return -1;
        if (raw == 0)
            break;
        ++count;
    }
    return (int)count;
}

int vibe_input_status(vibe_input_status_t* status)
{
    int raw;
    if (!status) {
        errno = EINVAL;
        return -1;
    }
    raw = vibe_syscall3(
        VIBE_SYS_INPUT_STATUS,
        (unsigned long)status,
        (unsigned long)sizeof(*status),
        0);
    return raw < 0 ? syscall_failed(raw, EINVAL) : raw;
}

int vibe_input_device_status(unsigned long device_id, vibe_input_device_status_t* status)
{
    int raw;
    if (!status) {
        errno = EINVAL;
        return -1;
    }
    raw = vibe_syscall3(
        VIBE_SYS_INPUT_DEVICE_STATUS,
        device_id,
        (unsigned long)status,
        (unsigned long)sizeof(*status));
    return raw < 0 ? syscall_failed(raw, EINVAL) : raw;
}

unsigned long vibe_heap_capabilities(void)
{
    return VIBE_HEAP_CAP_SBRK_GROW | VIBE_HEAP_CAP_SBRK_SHRINK;
}

unsigned long vibe_vm_capabilities(void)
{
    return VIBE_VM_CAP_ANON_PRIVATE
        | VIBE_VM_CAP_BRK_BACKED
        | VIBE_VM_CAP_TAIL_MUNMAP_RECLAIM
        | VIBE_VM_CAP_NONTAIL_MUNMAP_HOLES
        | VIBE_VM_CAP_FILE_PRIVATE_COPY;
}

void* vibe_mmap_anon(unsigned long length, int prot)
{
    return mmap(0, (size_t)length, prot, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
}

static void* mmap_allocate_private(size_t length, int prot)
{
#ifdef VIBE_LIBC_HOST_TEST
    size_t rounded;
    void* raw;
    (void)prot;
#else
    int raw;
    unsigned long packed;
#endif

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
    packed = ((unsigned long)(MAP_PRIVATE | MAP_ANONYMOUS) << 16) | (unsigned long)(prot & 0xffff);
    raw = vibe_syscall3(VIBE_SYS_MMAP, 0, (unsigned long)length, packed);
    if (raw < 0) {
        (void)syscall_failed(raw, ENOMEM);
        return MAP_FAILED;
    }
    return (void*)(unsigned int)raw;
#endif
}

static int mmap_copy_file_private(int fd, void* mapped, size_t length, off_t offset)
{
    size_t copied = 0;

    while (copied < length) {
        size_t request;
        ssize_t got;

        if (copied > (size_t)((unsigned long)VIBE_LONG_MAX_VALUE - (unsigned long)offset)) {
            errno = EOVERFLOW;
            return -1;
        }

        request = length - copied;
        if (request > (size_t)VIBE_LONG_MAX_VALUE)
            request = (size_t)VIBE_LONG_MAX_VALUE;
        got = pread(fd, (unsigned char*)mapped + copied, request, offset + (off_t)copied);
        if (got < 0)
            return -1;
        if (got == 0)
            break;
        copied += (size_t)got;
    }

    return 0;
}

void* mmap(void* addr, size_t length, int prot, int flags, int fd, off_t offset)
{
    void* mapped;
    int saved_errno;

    if (addr || !length || (flags & MAP_FIXED) || offset < 0) {
        errno = EINVAL;
        return MAP_FAILED;
    }

    if (!prot
        || (prot & ~(PROT_READ | PROT_WRITE | PROT_EXEC))
        || (flags & ~(MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED | MAP_SHARED))) {
        errno = EINVAL;
        return MAP_FAILED;
    }

    if (!(flags & MAP_PRIVATE) || (flags & MAP_SHARED)) {
        errno = ENOSYS;
        return MAP_FAILED;
    }

    if (flags & MAP_ANONYMOUS) {
        if (fd != -1 || offset != 0) {
            errno = ENOSYS;
            return MAP_FAILED;
        }
        return mmap_allocate_private(length, prot);
    }

    if (fd < 0) {
        errno = ENOSYS;
        return MAP_FAILED;
    }

    mapped = mmap_allocate_private(length, prot);
    if (mapped == MAP_FAILED)
        return MAP_FAILED;

    if (mmap_copy_file_private(fd, mapped, length, offset) < 0) {
        saved_errno = errno;
        (void)munmap(mapped, length);
        errno = saved_errno;
        return MAP_FAILED;
    }

    return mapped;
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

int vibe_fb_get_info(vibe_fb_info_t* info)
{
    if (!info) {
        errno = EINVAL;
        return -1;
    }
    return ioctl(VIBE_DISPLAY_FD, VIBE_IOCTL_FBINFO, info);
}

int vibe_fb_can_present_indexed(const vibe_fb_info_t* info, const vibe_present_indexed_t* present)
{
    return vibe_fb_info_accepts_present_indexed(info, present);
}

int vibe_present_indexed(const vibe_present_indexed_t* present)
{
    if (!present || !present->frame || !present->palette || !present->width || !present->height) {
        errno = EINVAL;
        return -1;
    }
    return ioctl(VIBE_DISPLAY_FD, VIBE_IOCTL_PRESENT_INDEXED, (void*)present);
}

int vibe_present_indexed_checked(const vibe_present_indexed_t* present)
{
    vibe_fb_info_t info;

    if (!present || !present->frame || !present->palette || !present->width || !present->height) {
        errno = EINVAL;
        return -1;
    }

    if (vibe_fb_get_info(&info) < 0)
        return -1;
    if (!vibe_fb_info_supports_indexed_rgb24(&info)) {
        errno = ENOSYS;
        return -1;
    }
    if (!vibe_fb_can_present_indexed(&info, present)) {
        errno = EINVAL;
        return -1;
    }
    return vibe_present_indexed(present);
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
    int raw;

    if (!path) {
        errno = EINVAL;
        return -1;
    }

    raw = vibe_syscall3(VIBE_SYS_EXEC, (unsigned long)mapped_path(path), (unsigned long)argv, (unsigned long)envp);
    return raw < 0 ? syscall_failed(raw, ENOENT) : raw;
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
    unsigned char* out = ptr;
    size_t total;
    size_t done = 0;
    if (!size || !count)
        return 0;
    if (!ptr || !stream || !stream->used || !stream->readable || checked_multiply_size(size, count, &total) < 0) {
        if (stream)
            stream->error = 1;
        if (!ptr)
            errno = EINVAL;
        else if (!stream || !stream->used || !stream->readable)
            errno = EBADF;
        return 0;
    }
    if (stream_flush_write(stream) < 0)
        return 0;
    if (stream->has_pushback) {
        out[done++] = stream->pushback;
        stream->has_pushback = 0;
        stream->eof = 0;
    }
    if (done == total)
        return count;
    bytes = read(stream->fd, out + done, total - done);
    if (bytes < 0) {
        stream->error = 1;
        return done / size;
    }
    if (bytes == 0) {
        stream->eof = 1;
        return done / size;
    }
    done += (size_t)bytes;
    if (done < total)
        stream->eof = 1;
    return done / size;
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
    if (stream->has_pushback && whence == SEEK_CUR)
        --offset;
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
    off_t logical;
    if (!stream || !stream->used) {
        errno = EBADF;
        return -1;
    }
    raw = lseek(stream->fd, 0, SEEK_CUR);
    if (raw < 0) {
        stream->error = 1;
        return -1;
    }
    logical = raw + (off_t)stream->write_buffered;
    if (stream->has_pushback)
        --logical;
    return (long)logical;
}

void rewind(FILE* stream)
{
    (void)fseek(stream, 0, SEEK_SET);
    clearerr(stream);
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
    return fgetc(stdin);
}

static int out_char(char** out, size_t* left, int fd, char ch)
{
    if (out) {
        if (*left > 1) {
            **out = ch;
            ++*out;
            --*left;
        }
    } else if (fd < 0) {
        return 0;
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

static int out_repeat(char** out, size_t* left, int fd, char ch, int repeat)
{
    int count = 0;
    while (count < repeat) {
        if (out_char(out, left, fd, ch) < 0)
            return -1;
        ++count;
    }
    return count;
}

static int out_bytes(char** out, size_t* left, int fd, const char* text, int length)
{
    int count = 0;
    while (count < length) {
        if (out_char(out, left, fd, text[count]) < 0)
            return -1;
        ++count;
    }
    return count;
}

static int out_string(
    char** out,
    size_t* left,
    int fd,
    const char* text,
    int width,
    int precision,
    int left_align)
{
    int length = 0;
    int padding;
    int wrote;
    int count = 0;

    if (!text)
        text = "(null)";

    while (text[length] && (precision < 0 || length < precision))
        ++length;

    padding = width > length ? width - length : 0;
    if (!left_align) {
        wrote = out_repeat(out, left, fd, ' ', padding);
        if (wrote < 0)
            return -1;
        count += wrote;
    }

    wrote = out_bytes(out, left, fd, text, length);
    if (wrote < 0)
        return -1;
    count += wrote;
    if (left_align) {
        wrote = out_repeat(out, left, fd, ' ', padding);
        if (wrote < 0)
            return -1;
        count += wrote;
    }
    return count;
}

static int unsupported_format(char** out, size_t* left, int fd, char specifier)
{
    if (out_char(out, left, fd, '%') < 0)
        return -1;
    if (specifier) {
        if (out_char(out, left, fd, specifier) < 0)
            return -1;
        return 2;
    }
    return 1;
}

static int unsigned_digits(
    char* tmp,
    unsigned long value,
    int base,
    int precision,
    int uppercase)
{
    int pos = 0;

    if (!value && precision == 0)
        return 0;

    do {
        unsigned long digit = value % (unsigned long)base;
        if (digit < 10)
            tmp[pos++] = (char)('0' + digit);
        else
            tmp[pos++] = (char)((uppercase ? 'A' : 'a') + digit - 10);
        value /= (unsigned long)base;
    } while (value);
    return pos;
}

static int out_unsigned(
    char** out,
    size_t* left,
    int fd,
    unsigned long value,
    int base,
    int width,
    int precision,
    int pad_zero,
    int negative,
    int uppercase,
    int left_align)
{
    char tmp[sizeof(unsigned long) * 8 + 1];
    int digits = unsigned_digits(tmp, value, base, precision, uppercase);
    int zeroes = 0;
    int spaces;
    int total;
    int wrote;
    int count = 0;

    if (precision > digits)
        zeroes = precision - digits;
    else if (precision < 0 && pad_zero && width > digits + negative)
        zeroes = width - digits - negative;

    total = digits + zeroes + negative;
    spaces = width > total ? width - total : 0;

    if (!left_align) {
        wrote = out_repeat(out, left, fd, ' ', spaces);
        if (wrote < 0)
            return -1;
        count += wrote;
    }

    if (negative) {
        if (out_char(out, left, fd, '-') < 0)
            return -1;
        ++count;
    }

    wrote = out_repeat(out, left, fd, '0', zeroes);
    if (wrote < 0)
        return -1;
    count += wrote;

    while (digits--) {
        if (out_char(out, left, fd, tmp[digits]) < 0)
            return -1;
        ++count;
    }
    if (left_align) {
        wrote = out_repeat(out, left, fd, ' ', spaces);
        if (wrote < 0)
            return -1;
        count += wrote;
    }
    return count;
}

static int format_to(char* buffer, size_t size, int fd, const char* format, va_list args)
{
    char* out = buffer;
    size_t left = size;
    int count = 0;
    char** out_arg = buffer ? &out : 0;

    while (*format) {
        int width = 0;
        int pad_zero = 0;
        int precision = -1;
        int wrote = 0;
        int length_modifier = 0;
        int left_align = 0;
        if (*format != '%') {
            if (out_char(out_arg, &left, fd, *format++) < 0)
                return -1;
            ++count;
            continue;
        }
        ++format;
        while (*format == '-' || *format == '+' || *format == ' ' || *format == '#') {
            if (*format == '-')
                left_align = 1;
            ++format;
        }
        if (*format == '0') {
            pad_zero = 1;
            ++format;
        }
        if (*format == '*') {
            width = va_arg(args, int);
            if (width < 0) {
                left_align = 1;
                width = -width;
            }
            ++format;
        }
        while (isdigit((unsigned char)*format)) {
            width = width * 10 + (*format++ - '0');
        }
        if (*format == '.') {
            ++format;
            precision = 0;
            if (*format == '*') {
                precision = va_arg(args, int);
                if (precision < 0)
                    precision = -1;
                ++format;
            }
            while (isdigit((unsigned char)*format)) {
                precision = precision * 10 + (*format - '0');
                ++format;
            }
        }
        if (*format == 'h') {
            length_modifier = 0;
            ++format;
            if (*format == 'h')
                ++format;
        } else if (*format == 'l') {
            length_modifier = 1;
            ++format;
            if (*format == 'l') {
                length_modifier = 2;
                ++format;
            }
        } else if (*format == 'z') {
            length_modifier = 3;
            ++format;
        }
        if (left_align)
            pad_zero = 0;
        switch (*format++) {
        case 's':
            wrote = out_string(out_arg, &left, fd, va_arg(args, const char*), width, precision, left_align);
            if (wrote < 0)
                return -1;
            count += wrote;
            break;
        case 'c':
            if (!left_align) {
                wrote = out_repeat(out_arg, &left, fd, ' ', width > 1 ? width - 1 : 0);
                if (wrote < 0)
                    return -1;
                count += wrote;
            }
            if (out_char(out_arg, &left, fd, (char)va_arg(args, int)) < 0)
                return -1;
            ++count;
            if (left_align) {
                wrote = out_repeat(out_arg, &left, fd, ' ', width > 1 ? width - 1 : 0);
                if (wrote < 0)
                    return -1;
                count += wrote;
            }
            break;
        case 'd':
        case 'i': {
            long value;
            unsigned long magnitude;
            int negative;
            if (length_modifier == 3)
                value = (long)va_arg(args, ssize_t);
            else if (length_modifier == 2)
                value = (long)va_arg(args, long long);
            else if (length_modifier == 1)
                value = va_arg(args, long);
            else
                value = (long)va_arg(args, int);
            negative = value < 0;
            if (value < 0) {
                magnitude = 0ul - (unsigned long)value;
            } else {
                magnitude = (unsigned long)value;
            }
            wrote = out_unsigned(out_arg, &left, fd, magnitude, 10, width, precision, pad_zero, negative, 0, left_align);
            if (wrote < 0)
                return -1;
            count += wrote;
            break;
        }
        case 'u': {
            unsigned long value;
            if (length_modifier == 3)
                value = (unsigned long)va_arg(args, size_t);
            else if (length_modifier == 2)
                value = (unsigned long)va_arg(args, unsigned long long);
            else if (length_modifier == 1)
                value = va_arg(args, unsigned long);
            else
                value = (unsigned long)va_arg(args, unsigned int);
            wrote = out_unsigned(out_arg, &left, fd, value, 10, width, precision, pad_zero, 0, 0, left_align);
            if (wrote < 0)
                return -1;
            count += wrote;
            break;
        }
        case 'o': {
            unsigned long value;
            if (length_modifier == 3)
                value = (unsigned long)va_arg(args, size_t);
            else if (length_modifier == 2)
                value = (unsigned long)va_arg(args, unsigned long long);
            else if (length_modifier == 1)
                value = va_arg(args, unsigned long);
            else
                value = (unsigned long)va_arg(args, unsigned int);
            wrote = out_unsigned(out_arg, &left, fd, value, 8, width, precision, pad_zero, 0, 0, left_align);
            if (wrote < 0)
                return -1;
            count += wrote;
            break;
        }
        case 'x': {
            unsigned long value;
            if (length_modifier == 3)
                value = (unsigned long)va_arg(args, size_t);
            else if (length_modifier == 2)
                value = (unsigned long)va_arg(args, unsigned long long);
            else if (length_modifier == 1)
                value = va_arg(args, unsigned long);
            else
                value = (unsigned long)va_arg(args, unsigned int);
            wrote = out_unsigned(out_arg, &left, fd, value, 16, width, precision, pad_zero, 0, 0, left_align);
            if (wrote < 0)
                return -1;
            count += wrote;
            break;
        }
        case 'X': {
            unsigned long value;
            if (length_modifier == 3)
                value = (unsigned long)va_arg(args, size_t);
            else if (length_modifier == 2)
                value = (unsigned long)va_arg(args, unsigned long long);
            else if (length_modifier == 1)
                value = va_arg(args, unsigned long);
            else
                value = (unsigned long)va_arg(args, unsigned int);
            wrote = out_unsigned(out_arg, &left, fd, value, 16, width, precision, pad_zero, 0, 1, left_align);
            if (wrote < 0)
                return -1;
            count += wrote;
            break;
        }
        case 'p': {
            unsigned long value = (unsigned long)va_arg(args, void*);
            wrote = out_unsigned(out_arg, &left, fd, value, 16, width, precision, pad_zero, 0, 0, left_align);
            if (wrote < 0)
                return -1;
            count += wrote;
            break;
        }
        case 'a':
        case 'A':
        case 'e':
        case 'E':
        case 'f':
        case 'F':
        case 'g':
        case 'G':
            (void)va_arg(args, double);
            wrote = unsupported_format(out_arg, &left, fd, *(format - 1));
            if (wrote < 0)
                return -1;
            count += wrote;
            break;
        case 'n':
            (void)va_arg(args, void*);
            wrote = unsupported_format(out_arg, &left, fd, *(format - 1));
            if (wrote < 0)
                return -1;
            count += wrote;
            break;
        case '%':
            if (out_char(out_arg, &left, fd, '%') < 0)
                return -1;
            ++count;
            break;
        default:
            wrote = unsupported_format(out_arg, &left, fd, *(format - 1));
            if (wrote < 0)
                return -1;
            count += wrote;
            break;
        }
    }
    if (buffer && size)
        *out = 0;
    return count;
}

int vsnprintf(char* buffer, size_t size, const char* format, va_list args)
{
    return format_to(buffer, size, buffer ? 1 : -1, format, args);
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

static int scan_text_read_number(const char** text, void* dest, int width, int base, int is_signed)
{
    const char* p = *text;
    char tmp[64];
    char* end;
    int limit;
    int count = 0;

    if (width <= 0 || width >= (int)sizeof(tmp))
        limit = (int)sizeof(tmp) - 1;
    else
        limit = width;
    scan_text_skip_space(&p);
    while (count < limit && p[count]) {
        tmp[count] = p[count];
        ++count;
    }
    tmp[count] = 0;

    if (is_signed) {
        long value = strtol(tmp, &end, base);
        if (end == tmp)
            return 0;
        *(int*)dest = (int)value;
    } else {
        unsigned long value = strtoul(tmp, &end, base);
        if (end == tmp)
            return 0;
        *(unsigned int*)dest = (unsigned int)value;
    }
    *text = p + (end - tmp);
    return 1;
}

static int scan_text_read_chars(const char** text, char* dest, int width)
{
    int count = 0;

    if (width <= 0)
        width = 1;
    while (count < width && (*text)[count])
        ++count;
    if (count < width)
        return 0;
    memcpy(dest, *text, (size_t)width);
    *text += width;
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
        } else if (*format == 'c') {
            if (!scan_text_read_chars(&text, va_arg(args, char*), width))
                break;
            ++assigned;
            ++matched;
            ++format;
        } else if (*format == 'i' || *format == 'd') {
            if (!scan_text_read_number(&text, va_arg(args, int*), width, *format == 'i' ? 0 : 10, 1))
                break;
            ++assigned;
            ++matched;
            ++format;
        } else if (*format == 'u') {
            if (!scan_text_read_number(&text, va_arg(args, unsigned int*), width, 10, 0))
                break;
            ++assigned;
            ++matched;
            ++format;
        } else if (*format == 'o') {
            if (!scan_text_read_number(&text, va_arg(args, unsigned int*), width, 8, 0))
                break;
            ++assigned;
            ++matched;
            ++format;
        } else if (*format == 'x' || *format == 'X') {
            if (!scan_text_read_number(&text, va_arg(args, unsigned int*), width, 16, 0))
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

int fgetc(FILE* stream)
{
    return file_read_char(stream);
}

int getc(FILE* stream)
{
    return fgetc(stream);
}

int ungetc(int ch, FILE* stream)
{
    if (ch == EOF || !stream || !stream->used || !stream->readable || stream->has_pushback) {
        if (stream && (!stream->used || !stream->readable))
            stream->error = 1;
        if (!stream || !stream->used || !stream->readable)
            errno = EBADF;
        return EOF;
    }

    file_unread_char(stream, ch);
    return (unsigned char)ch;
}

char* fgets(char* buffer, int size, FILE* stream)
{
    int count = 0;

    if (!buffer || size <= 0) {
        errno = EINVAL;
        return 0;
    }
    if (size == 1) {
        buffer[0] = 0;
        return buffer;
    }

    while (count + 1 < size) {
        int ch = file_read_char(stream);
        if (ch == EOF)
            break;
        buffer[count++] = (char)ch;
        if (ch == '\n')
            break;
    }

    if (!count)
        return 0;
    buffer[count] = 0;
    return buffer;
}

int fputc(int ch, FILE* stream)
{
    unsigned char byte = (unsigned char)ch;

    if (!stream || !stream->used || !stream->writable) {
        if (stream)
            stream->error = 1;
        errno = EBADF;
        return EOF;
    }

    if (stream->append)
        (void)lseek(stream->fd, 0, SEEK_END);
    if (stream_write(stream, (const char*)&byte, 1) < 0) {
        stream->error = 1;
        return EOF;
    }
    return byte;
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
    size_t length;

    if (!text || !stream || !stream->used || !stream->writable) {
        if (stream)
            stream->error = 1;
        errno = !text ? EINVAL : EBADF;
        return EOF;
    }

    if (stream->append)
        (void)lseek(stream->fd, 0, SEEK_END);
    length = strlen(text);
    if (stream_write(stream, text, length) < 0) {
        stream->error = 1;
        return EOF;
    }
    return 0;
}

int puts(const char* text)
{
    if (fputs(text, stdout) == EOF)
        return EOF;
    return fputc('\n', stdout) == EOF ? EOF : 1;
}

void perror(const char* text)
{
    int saved_errno = errno;

    if (text && *text) {
        (void)fputs(text, stderr);
        (void)fputs(": ", stderr);
    }
    (void)fputs(strerror(saved_errno), stderr);
    (void)fputc('\n', stderr);
    errno = saved_errno;
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

static int scan_read_number(FILE* stream, void* dest, int width, int base, int is_signed)
{
    char tmp[64];
    int ch;
    int count = 0;
    long start;
    char* end;
    int consumed;

    if (width <= 0 || width >= (int)sizeof(tmp))
        width = (int)sizeof(tmp) - 1;
    scan_skip_space(stream);
    start = ftell(stream);
    if (start < 0)
        return 0;

    while (count < width) {
        ch = file_read_char(stream);
        if (ch == EOF)
            break;
        tmp[count++] = (char)ch;
    }
    tmp[count] = 0;

    if (is_signed) {
        long value = strtol(tmp, &end, base);
        if (end == tmp) {
            if (count)
                (void)fseek(stream, start, SEEK_SET);
            return 0;
        }
        *(int*)dest = (int)value;
    } else {
        unsigned long value = strtoul(tmp, &end, base);
        if (end == tmp) {
            if (count)
                (void)fseek(stream, start, SEEK_SET);
            return 0;
        }
        *(unsigned int*)dest = (unsigned int)value;
    }

    consumed = (int)(end - tmp);
    if (consumed < count && fseek(stream, start + consumed, SEEK_SET) < 0)
        return 0;
    return 1;
}

static int scan_read_chars(FILE* stream, char* dest, int width)
{
    int count = 0;

    if (width <= 0)
        width = 1;
    while (count < width) {
        int ch = file_read_char(stream);
        if (ch == EOF)
            return 0;
        dest[count++] = (char)ch;
    }
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
        } else if (*format == 'c') {
            if (!scan_read_chars(stream, va_arg(args, char*), width))
                break;
            ++assigned;
            ++matched;
            ++format;
        } else if (*format == 'i' || *format == 'd') {
            if (!scan_read_number(stream, va_arg(args, int*), width, *format == 'i' ? 0 : 10, 1))
                break;
            ++assigned;
            ++matched;
            ++format;
        } else if (*format == 'u') {
            if (!scan_read_number(stream, va_arg(args, unsigned int*), width, 10, 0))
                break;
            ++assigned;
            ++matched;
            ++format;
        } else if (*format == 'o') {
            if (!scan_read_number(stream, va_arg(args, unsigned int*), width, 8, 0))
                break;
            ++assigned;
            ++matched;
            ++format;
        } else if (*format == 'x' || *format == 'X') {
            if (!scan_read_number(stream, va_arg(args, unsigned int*), width, 16, 0))
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
