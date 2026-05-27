#include "pi4_runtime.h"

#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <math.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define PI4_QUAKE_HEAP_BYTES (40 * 1024 * 1024)
#define PI4_QUAKE_FILE_READ_CHUNK_BYTES (512 * 1024)
#define PI4_QUAKE_PAK_CACHE_MAX_BYTES (24 * 1024 * 1024)

int errno = 0;
char** environ = 0;

struct vibe_doom_file {
    int fd;
    int eof;
    int error;
    int pushed;
    unsigned char pushback;
    long offset;
    int positioned;
};

static struct vibe_doom_file pi4_stdin = {0, 0, 0, 0, 0, 0, 0};
static struct vibe_doom_file pi4_stdout = {1, 0, 0, 0, 0, 0, 0};
static struct vibe_doom_file pi4_stderr = {2, 0, 0, 0, 0, 0, 0};

FILE* stdin = &pi4_stdin;
FILE* stdout = &pi4_stdout;
FILE* stderr = &pi4_stderr;

extern int nostdout;
extern void pi4_quake_present_missing_pak_frame(void);
extern void pi4_quake_present_runtime_error_frame(void);

static unsigned char pi4_quake_heap[PI4_QUAKE_HEAP_BYTES] __attribute__((aligned(16)));
static unsigned long pi4_quake_heap_used;
static int pi4_quake_missing_pak_logged;
static int pi4_quake_pak_io_failure_logged;
static int pi4_quake_write_rejected_logged;
static unsigned long pi4_quake_pak_fd_offset;
static int pi4_quake_pak_fd_offset_valid;
static unsigned char* pi4_quake_pak_cache;
static unsigned long pi4_quake_pak_cache_size;
static int pi4_quake_pak_cache_attempted;
static int pi4_quake_pak_cache_ready;

unsigned long pi4_quake_pak_open_count;
unsigned long pi4_quake_pak_read_calls;
unsigned long pi4_quake_pak_read_bytes;
unsigned long pi4_quake_pak_seek_count;
unsigned long pi4_quake_pak_short_read_count;
unsigned long pi4_quake_pak_read_error_count;
unsigned long pi4_quake_pak_max_offset;
unsigned long pi4_quake_pak_last_request_bytes;
long pi4_quake_pak_last_result;

static void pi4_quake_write_text(int fd, const char* text);

static void pi4_stream_init(struct vibe_doom_file* stream, int fd)
{
    stream->fd = fd;
    stream->eof = 0;
    stream->error = 0;
    stream->pushed = 0;
    stream->pushback = 0;
    stream->offset = 0;
    stream->positioned = fd == PI4_VIBE_FD_PAK0_PAK;
}

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

static int pi4_size_mul_overflow(size_t left, size_t right, size_t* out)
{
    size_t value;
    if (!out)
        return 1;
    if (!left || !right) {
        *out = 0;
        return 0;
    }
    value = left * right;
    if (value / left != right)
        return 1;
    *out = value;
    return 0;
}

static int pi4_quake_stream_is_pak(FILE* stream)
{
    return stream && stream->fd == PI4_VIBE_FD_PAK0_PAK;
}

static int pi4_quake_fd_is_pak(long fd)
{
    return fd == PI4_VIBE_FD_PAK0_PAK;
}

static void pi4_quake_pak_note_offset(long offset)
{
    if (offset >= 0 && (unsigned long)offset > pi4_quake_pak_max_offset)
        pi4_quake_pak_max_offset = (unsigned long)offset;
}

static void pi4_quake_pak_note_fd_offset(long offset)
{
    if (offset < 0) {
        pi4_quake_pak_fd_offset_valid = 0;
        return;
    }
    pi4_quake_pak_fd_offset = (unsigned long)offset;
    pi4_quake_pak_fd_offset_valid = 1;
    pi4_quake_pak_note_offset(offset);
}

static int pi4_quake_errno_from_result(long result, int fallback)
{
    long code;
    if (result >= 0)
        return 0;
    code = -result;
    if (code > 0 && code <= 4095)
        return (int)code;
    return fallback;
}

static int pi4_quake_add_long(long left, long right, long* out)
{
    if (!out)
        return 1;
    if (right > 0 && left > LONG_MAX - right)
        return 1;
    if (right < 0 && left < LONG_MIN - right)
        return 1;
    *out = left + right;
    return 0;
}

static void pi4_quake_report_pak_io_failure(const char* operation, long result)
{
    char suffix[48];
    if (pi4_quake_pak_io_failure_logged)
        return;
    pi4_quake_pak_io_failure_logged = 1;
    pi4_quake_present_runtime_error_frame();
    pi4_quake_write_text(2, "vibe-os Quake: /ID1/PAK0.PAK ");
    pi4_quake_write_text(2, operation ? operation : "I/O");
    pi4_quake_write_text(2, " failed");
    if (result) {
        sprintf(suffix, " (%ld)", result);
        pi4_quake_write_text(2, suffix);
    }
    pi4_quake_write_text(2, ".\n");
}

static void pi4_quake_report_write_rejected(void)
{
    if (pi4_quake_write_rejected_logged)
        return;
    pi4_quake_write_rejected_logged = 1;
    pi4_quake_write_text(2,
        "vibe-os Quake: game-file writes are read-only on the Pi image; "
        "returning ENOSYS instead of pretending success.\n");
}

static int pi4_quake_pak_seek_target(
    long fd,
    long current,
    int have_current,
    long offset,
    unsigned long whence,
    long* out)
{
    long base;
    long size;
    long next;

    size = vibe_user_file_size((pi4_vibe_word_t)fd);
    if (size < 0) {
        errno = pi4_quake_errno_from_result(size, EIO);
        return -1;
    }

    if (whence == SEEK_SET) {
        base = 0;
    } else if (whence == SEEK_CUR) {
        if (!have_current) {
            current = vibe_user_lseek((pi4_vibe_word_t)fd, 0, SEEK_CUR);
            if (current < 0) {
                errno = pi4_quake_errno_from_result(current, EIO);
                return -1;
            }
        }
        base = current;
    } else if (whence == SEEK_END) {
        base = size;
    } else {
        errno = EINVAL;
        return -1;
    }

    if (pi4_quake_add_long(base, offset, &next) || next < 0 || next > size) {
        errno = EINVAL;
        return -1;
    }
    *out = next;
    return 0;
}

void* memcpy(void* dest, const void* src, size_t count)
{
    unsigned char* d;
    const unsigned char* s;
    d = (unsigned char*)dest;
    s = (const unsigned char*)src;
    while (count--)
        *d++ = *s++;
    return dest;
}

void* memset(void* dest, int value, size_t count)
{
    unsigned char* d;
    d = (unsigned char*)dest;
    while (count--)
        *d++ = (unsigned char)value;
    return dest;
}

size_t strlen(const char* text)
{
    const char* p;
    if (!text)
        return 0;
    p = text;
    while (*p)
        p++;
    return (size_t)(p - text);
}

char* strcpy(char* dest, const char* src)
{
    char* out;
    out = dest;
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

char* strchr(const char* text, int ch)
{
    do {
        if (*text == (char)ch)
            return (char*)text;
    } while (*text++);
    return NULL;
}

char* strstr(const char* text, const char* needle)
{
    size_t needle_len;
    needle_len = strlen(needle);
    if (!needle_len)
        return (char*)text;
    while (*text) {
        if (strncmp(text, needle, needle_len) == 0)
            return (char*)text;
        text++;
    }
    return NULL;
}

static unsigned long pi4_align16(unsigned long value)
{
    return (value + 15ul) & ~15ul;
}

void* malloc(size_t size)
{
    unsigned long aligned;
    aligned = pi4_align16(pi4_quake_heap_used);
    if (!size)
        size = 1;
    if (aligned > PI4_QUAKE_HEAP_BYTES || size > PI4_QUAKE_HEAP_BYTES - aligned) {
        errno = ENOMEM;
        return NULL;
    }
    pi4_quake_heap_used = aligned + (unsigned long)size;
    return pi4_quake_heap + aligned;
}

void free(void* ptr)
{
    (void)ptr;
}

static long pi4_strtol_base(const char* text, char** endptr, int base)
{
    long sign;
    unsigned long value;
    int digit;
    sign = 1;
    value = 0;
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

int atoi(const char* text)
{
    return (int)pi4_strtol_base(text, NULL, 10);
}

double atof(const char* text)
{
    double value;
    double place;
    double sign;
    int exponent;
    int exponent_sign;
    sign = 1.0;
    value = 0.0;
    while (pi4_is_space(*text))
        text++;
    if (*text == '-') {
        sign = -1.0;
        text++;
    } else if (*text == '+') {
        text++;
    }
    while (*text >= '0' && *text <= '9') {
        value = value * 10.0 + (double)(*text - '0');
        text++;
    }
    if (*text == '.') {
        text++;
        place = 0.1;
        while (*text >= '0' && *text <= '9') {
            value += place * (double)(*text - '0');
            place *= 0.1;
            text++;
        }
    }
    if (*text == 'e' || *text == 'E') {
        text++;
        exponent_sign = 1;
        exponent = 0;
        if (*text == '-') {
            exponent_sign = -1;
            text++;
        } else if (*text == '+') {
            text++;
        }
        while (*text >= '0' && *text <= '9') {
            exponent = exponent * 10 + (*text - '0');
            text++;
        }
        while (exponent-- > 0)
            value = exponent_sign > 0 ? value * 10.0 : value * 0.1;
    }
    return sign * value;
}

int rand(void)
{
    static unsigned long state = 1;
    state = state * 1103515245ul + 12345ul;
    return (int)((state >> 16) & RAND_MAX);
}

static long pi4_quake_file_read_chunks(unsigned long fd, void* buffer, unsigned long bytes)
{
    unsigned char* out;
    unsigned long total;
    unsigned long request;
    long got;

    if (!bytes)
        return 0;
    if (!buffer)
        return -PI4_VIBE_EINVAL;
    if (bytes > (unsigned long)LONG_MAX)
        return -PI4_VIBE_EOVERFLOW;

    out = (unsigned char*)buffer;
    total = 0;
    while (total < bytes) {
        request = bytes - total;
        if (request > PI4_QUAKE_FILE_READ_CHUNK_BYTES)
            request = PI4_QUAKE_FILE_READ_CHUNK_BYTES;
        got = vibe_user_file_read((pi4_vibe_word_t)fd, out + total, (pi4_vibe_word_t)request);
        if (got < 0)
            return total ? (long)total : got;
        if (!got)
            break;
        if ((unsigned long)got > request)
            return total ? (long)total : -PI4_VIBE_EIO;
        total += (unsigned long)got;
        if ((unsigned long)got < request)
            break;
    }
    return (long)total;
}

static int pi4_quake_load_pak_cache(void)
{
    unsigned char* cache;
    unsigned long total;
    unsigned long request;
    long size;
    long got;

    if (pi4_quake_pak_cache_attempted)
        return pi4_quake_pak_cache_ready;
    pi4_quake_pak_cache_attempted = 1;

    size = vibe_user_file_size(PI4_VIBE_FD_PAK0_PAK);
    if (size <= 0 || (unsigned long)size > PI4_QUAKE_PAK_CACHE_MAX_BYTES)
        return 0;

    cache = (unsigned char*)malloc((size_t)size);
    if (!cache)
        return 0;

    if (vibe_user_lseek(PI4_VIBE_FD_PAK0_PAK, 0, SEEK_SET) != 0)
        return 0;

    total = 0;
    while (total < (unsigned long)size) {
        request = (unsigned long)size - total;
        if (request > PI4_QUAKE_FILE_READ_CHUNK_BYTES)
            request = PI4_QUAKE_FILE_READ_CHUNK_BYTES;
        got = vibe_user_file_read(
            PI4_VIBE_FD_PAK0_PAK, cache + total, (pi4_vibe_word_t)request);
        if (got <= 0)
            return 0;
        total += (unsigned long)got;
    }

    vibe_user_lseek(PI4_VIBE_FD_PAK0_PAK, 0, SEEK_SET);
    pi4_quake_pak_cache = cache;
    pi4_quake_pak_cache_size = (unsigned long)size;
    pi4_quake_pak_cache_ready = 1;
    pi4_quake_pak_note_fd_offset(0);
    return 1;
}

FILE* fopen(const char* path, const char* mode)
{
    struct vibe_doom_file* stream;
    int fd;
    if (!mode || mode[0] != 'r') {
        errno = ENOSYS;
        return NULL;
    }
    fd = open(path, O_RDONLY);
    if (fd < 0) {
        errno = pi4_quake_errno_from_result(fd, ENOENT);
        return NULL;
    }
    stream = (struct vibe_doom_file*)malloc(sizeof(*stream));
    if (!stream) {
        close(fd);
        return NULL;
    }
    pi4_stream_init(stream, fd);
    return stream;
}

size_t fread(void* ptr, size_t size, size_t count, FILE* stream)
{
    unsigned char* out;
    size_t bytes;
    size_t requested;
    size_t copied;
    long got;
    long seek_result;
    if (!stream || !size)
        return 0;
    if (pi4_size_mul_overflow(size, count, &bytes)) {
        stream->error = 1;
        errno = EOVERFLOW;
        return 0;
    }
    if (!bytes)
        return 0;
    requested = bytes;
    copied = 0;
    out = (unsigned char*)ptr;
    if (stream->pushed) {
        *out++ = stream->pushback;
        stream->pushed = 0;
        stream->offset++;
        copied = 1;
        bytes--;
    }
    if (!bytes) {
        if (pi4_quake_stream_is_pak(stream))
            pi4_quake_pak_note_fd_offset(stream->offset);
        return copied / size;
    }
    if (stream->positioned) {
        seek_result = vibe_user_lseek((pi4_vibe_word_t)stream->fd, (off_t)stream->offset, SEEK_SET);
        if (seek_result != stream->offset) {
            stream->error = 1;
            if (seek_result < 0)
                errno = pi4_quake_errno_from_result(seek_result, EIO);
            else
                errno = EIO;
            if (pi4_quake_stream_is_pak(stream)) {
                pi4_quake_pak_read_error_count++;
                pi4_quake_pak_last_result = seek_result < 0 ? seek_result : -PI4_VIBE_EIO;
                pi4_quake_report_pak_io_failure("seek", pi4_quake_pak_last_result);
            }
            return copied / size;
        }
        if (pi4_quake_stream_is_pak(stream))
            pi4_quake_pak_note_fd_offset(seek_result);
    }
    if (pi4_quake_stream_is_pak(stream)) {
        pi4_quake_pak_read_calls++;
        pi4_quake_pak_last_request_bytes = requested;
        if (pi4_quake_pak_cache_ready ||
            (pi4_quake_pak_cache_attempted && pi4_quake_pak_cache_ready)) {
            if ((unsigned long)stream->offset < pi4_quake_pak_cache_size) {
                size_t avail;
                avail = (size_t)(pi4_quake_pak_cache_size - (unsigned long)stream->offset);
                if (bytes > avail)
                    bytes = avail;
                memcpy(out, pi4_quake_pak_cache + stream->offset, bytes);
                stream->offset += (long)bytes;
                copied += bytes;
            }
            if (copied < requested)
                stream->eof = 1;
            pi4_quake_pak_read_bytes += copied;
            pi4_quake_pak_last_result = (long)copied;
            pi4_quake_pak_note_fd_offset(stream->offset);
            return copied / size;
        }
    }
    got = pi4_quake_file_read_chunks((unsigned long)stream->fd, out, (unsigned long)bytes);
    if (got < 0) {
        stream->error = 1;
        errno = pi4_quake_errno_from_result(got, EIO);
        if (pi4_quake_stream_is_pak(stream)) {
            pi4_quake_pak_read_error_count++;
            pi4_quake_pak_last_result = got;
            pi4_quake_pak_fd_offset_valid = 0;
            pi4_quake_report_pak_io_failure("read", got);
        }
        return copied / size;
    }
    if (got > 0) {
        stream->offset += (long)got;
        copied += (size_t)got;
    }
    if ((size_t)got < bytes) {
        stream->eof = 1;
        if (pi4_quake_stream_is_pak(stream))
            pi4_quake_pak_short_read_count++;
    }
    if (pi4_quake_stream_is_pak(stream)) {
        pi4_quake_pak_read_bytes += copied;
        pi4_quake_pak_last_result = (long)copied;
        pi4_quake_pak_note_fd_offset(stream->offset);
    }
    return copied / size;
}

size_t fwrite(const void* ptr, size_t size, size_t count, FILE* stream)
{
    size_t bytes;
    ssize_t written;
    if (!stream || !size)
        return 0;
    if (pi4_size_mul_overflow(size, count, &bytes)) {
        stream->error = 1;
        errno = EOVERFLOW;
        return 0;
    }
    if (!bytes)
        return 0;
    written = write(stream->fd, ptr, bytes);
    if (written < 0) {
        stream->error = 1;
        return 0;
    }
    if ((size_t)written < bytes) {
        stream->error = 1;
        return (size_t)written / size;
    }
    return count;
}

int fseek(FILE* stream, long offset, int whence)
{
    long base;
    long size;
    long next;
    if (!stream)
        return -1;
    stream->eof = 0;
    stream->pushed = 0;
    if (pi4_quake_stream_is_pak(stream))
        pi4_quake_pak_seek_count++;
    if (!stream->positioned) {
        next = (long)lseek(stream->fd, (off_t)offset, whence);
        if (next < 0)
            return -1;
        stream->offset = next;
        if (pi4_quake_stream_is_pak(stream))
            pi4_quake_pak_note_offset(stream->offset);
        return 0;
    }
    if (whence == SEEK_SET) {
        base = 0;
    } else if (whence == SEEK_CUR) {
        base = stream->offset;
    } else if (whence == SEEK_END) {
        size = vibe_user_file_size(stream->fd);
        if (size < 0)
            return -1;
        base = size;
    } else {
        return -1;
    }
    if (pi4_quake_add_long(base, offset, &next) || next < 0)
        return -1;
    if (pi4_quake_stream_is_pak(stream) &&
        pi4_quake_pak_seek_target(stream->fd, stream->offset, 1, offset, whence, &next) < 0) {
        stream->error = 1;
        return -1;
    }
    stream->offset = next;
    if (pi4_quake_stream_is_pak(stream))
        pi4_quake_pak_note_offset(stream->offset);
    return 0;
}

long ftell(FILE* stream)
{
    if (!stream)
        return -1;
    return stream->offset;
}

void rewind(FILE* stream)
{
    (void)fseek(stream, 0, SEEK_SET);
}

int fclose(FILE* stream)
{
    int rc;
    rc = 0;
    if (!stream || stream == stdin || stream == stdout || stream == stderr)
        return 0;
    if (stream->fd > 2)
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

int fgetc(FILE* stream)
{
    unsigned char ch;
    if (!stream)
        return EOF;
    if (stream->pushed) {
        stream->pushed = 0;
        stream->offset++;
        if (pi4_quake_stream_is_pak(stream))
            pi4_quake_pak_note_offset(stream->offset);
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

int ungetc(int ch, FILE* stream)
{
    if (!stream || ch == EOF || stream->pushed)
        return EOF;
    stream->pushed = 1;
    stream->pushback = (unsigned char)ch;
    stream->eof = 0;
    if (stream->offset > 0)
        stream->offset--;
    return ch;
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
    int used;
    int pad;
    used = 0;
    do {
        unsigned int digit;
        digit = (unsigned int)(value % base);
        tmp[used++] = digit < 10 ? (char)('0' + digit) : (char)('a' + digit - 10);
        value /= base;
    } while (value);
    for (pad = used; pad < width; pad++)
        pi4_out_char(out, remain, total, zero ? '0' : ' ');
    while (used--)
        pi4_out_char(out, remain, total, tmp[used]);
}

static void pi4_out_double(char** out, size_t* remain, int* total,
                           double value, int width, int precision)
{
    unsigned long whole;
    double frac;
    int digits;
    int negative;
    int whole_digits;
    unsigned long tmp;
    if (precision < 0)
        precision = 6;
    if (precision > 8)
        precision = 8;
    negative = value < 0.0;
    if (negative)
        value = -value;
    whole = (unsigned long)value;
    frac = value - (double)whole;
    whole_digits = 1;
    tmp = whole;
    while (tmp >= 10) {
        tmp /= 10;
        whole_digits++;
    }
    while (width > whole_digits + precision + (precision > 0 ? 1 : 0) + negative) {
        pi4_out_char(out, remain, total, ' ');
        width--;
    }
    if (negative)
        pi4_out_char(out, remain, total, '-');
    pi4_out_unsigned(out, remain, total, whole, 10, 0, 0);
    if (precision > 0)
        pi4_out_char(out, remain, total, '.');
    for (digits = 0; digits < precision; digits++) {
        int digit;
        frac *= 10.0;
        digit = (int)frac;
        if (digit < 0)
            digit = 0;
        if (digit > 9)
            digit = 9;
        pi4_out_char(out, remain, total, (char)('0' + digit));
        frac -= (double)digit;
    }
}

int vsnprintf(char* buffer, size_t size, const char* format, va_list args)
{
    char* out;
    size_t remain;
    int total;
    out = buffer;
    remain = size;
    total = 0;
    while (*format) {
        int width;
        int precision;
        int zero;
        int is_long;
        width = 0;
        precision = -1;
        zero = 0;
        is_long = 0;
        if (*format != '%') {
            pi4_out_char(&out, &remain, &total, *format++);
            continue;
        }
        format++;
        if (*format == '0') {
            zero = 1;
            format++;
        }
        while (*format >= '0' && *format <= '9') {
            width = width * 10 + (*format - '0');
            format++;
        }
        if (*format == '.') {
            precision = 0;
            format++;
            while (*format >= '0' && *format <= '9') {
                precision = precision * 10 + (*format - '0');
                format++;
            }
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
            long value;
            value = is_long ? va_arg(args, long) : va_arg(args, int);
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
        case 'f':
            pi4_out_double(&out, &remain, &total, va_arg(args, double), width, precision);
            break;
        case '%':
            pi4_out_char(&out, &remain, &total, '%');
            break;
        default:
            pi4_out_char(&out, &remain, &total, '%');
            if (*format)
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
    int rc;
    rc = vsnprintf(buffer, sizeof(buffer), format, args);
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

int printf(const char* format, ...)
{
    va_list args;
    int rc;
    va_start(args, format);
    rc = vfprintf(stdout, format, args);
    va_end(args);
    return rc;
}

static void pi4_quake_write_text(int fd, const char* text)
{
    size_t len;
    if (!text)
        return;
    len = strlen(text);
    if (len)
        write(fd, text, len);
}

static void pi4_quake_vprint(int fd, const char* prefix, const char* format, va_list args)
{
    char buffer[1024];
    if (prefix)
        pi4_quake_write_text(fd, prefix);
    vsnprintf(buffer, sizeof(buffer), format ? format : "", args);
    pi4_quake_write_text(fd, buffer);
}

void Sys_Printf(char* format, ...)
{
    va_list args;
    if (nostdout)
        return;
    va_start(args, format);
    pi4_quake_vprint(1, NULL, format, args);
    va_end(args);
}

void pi4_quake_common_sys_printf(char* format, ...)
{
    va_list args;
    if (!format)
        return;
    if (format[0] == 'P' && format[1] == 'a' && format[2] == 'c' &&
        format[3] == 'k' && format[4] == 'F' && format[5] == 'i' &&
        format[6] == 'l' && format[7] == 'e' && format[8] == ':')
        return;
    if (nostdout)
        return;
    va_start(args, format);
    pi4_quake_vprint(1, NULL, format, args);
    va_end(args);
}

void Sys_Warn(char* warning, ...)
{
    va_list args;
    va_start(args, warning);
    pi4_quake_vprint(2, "Warning: ", warning, args);
    va_end(args);
}

void Sys_Error(char* error, ...)
{
    va_list args;
    va_start(args, error);
    pi4_quake_vprint(2, "Error: ", error, args);
    va_end(args);
    pi4_quake_write_text(2, "\n");
    pi4_quake_present_runtime_error_frame();
    vibe_user_exit(1);
}

static int pi4_quake_is_separator(int ch)
{
    return ch == '/' || ch == '\\';
}

static int pi4_quake_path_matches_suffix(const char* path, const char* suffix)
{
    size_t path_len;
    size_t suffix_len;
    size_t start;
    size_t i;
    int left;
    int right;
    if (!path || !suffix)
        return 0;
    path_len = strlen(path);
    suffix_len = strlen(suffix);
    if (path_len < suffix_len)
        return 0;
    start = path_len - suffix_len;
    if (start && !pi4_quake_is_separator(path[start - 1]))
        return 0;
    for (i = 0; i < suffix_len; i++) {
        left = path[start + i];
        right = suffix[i];
        if (pi4_quake_is_separator(left) && pi4_quake_is_separator(right))
            continue;
        if (pi4_lower(left) != pi4_lower(right))
            return 0;
    }
    return 1;
}

static const char* pi4_quake_default_asset_path(const char* path)
{
    if (pi4_quake_path_matches_suffix(path, "id1/pak0.pak") ||
        pi4_quake_path_matches_suffix(path, "pak0.pak"))
        return PI4_VIBE_QUAKE_PAK0_PATH;
    return path;
}

long pi4_quake_file_open(const char* path, unsigned long flags, unsigned long mode)
{
    const char* mapped;
    long fd;
    (void)mode;
    if (flags != O_RDONLY) {
        errno = ENOSYS;
        pi4_quake_report_write_rejected();
        return -PI4_VIBE_ENOSYS;
    }
    mapped = pi4_quake_default_asset_path(path);
    fd = vibe_user_file_open(mapped);
    if (fd == PI4_VIBE_FD_PAK0_PAK) {
        pi4_quake_pak_open_count++;
        pi4_quake_load_pak_cache();
        pi4_quake_pak_note_fd_offset(0);
    } else if (mapped && strcmp(mapped, PI4_VIBE_QUAKE_PAK0_PATH) == 0) {
        pi4_quake_pak_fd_offset_valid = 0;
    }
    if (fd < 0 && flags == O_RDONLY &&
        mapped && strcmp(mapped, PI4_VIBE_QUAKE_PAK0_PATH) == 0 &&
        !pi4_quake_missing_pak_logged) {
        pi4_quake_missing_pak_logged = 1;
        pi4_quake_present_missing_pak_frame();
        pi4_quake_write_text(2,
            "vibe-os Quake: /ID1/PAK0.PAK is unavailable for requested path ");
        pi4_quake_write_text(2, path ? path : "(null)");
        pi4_quake_write_text(2,
            "; package a Quake PAK so the Pi VFS exposes /ID1/PAK0.PAK.\n");
    }
    if (fd < 0)
        errno = pi4_quake_errno_from_result(fd, ENOENT);
    return fd;
}

long pi4_quake_file_write(unsigned long fd, const void* buffer, unsigned long bytes)
{
    long written;
    if (!bytes)
        return 0;
    if (!buffer) {
        errno = EINVAL;
        return -PI4_VIBE_EINVAL;
    }
    if (bytes > (unsigned long)LONG_MAX) {
        errno = EOVERFLOW;
        return -PI4_VIBE_EOVERFLOW;
    }
    if (fd != 1 && fd != 2) {
        errno = ENOSYS;
        pi4_quake_report_write_rejected();
        return -PI4_VIBE_ENOSYS;
    }
    written = vibe_user_write((pi4_vibe_word_t)fd, buffer, (pi4_vibe_word_t)bytes);
    if (written < 0)
        errno = pi4_quake_errno_from_result(written, EIO);
    return written;
}

long pi4_quake_file_read(unsigned long fd, void* buffer, unsigned long bytes)
{
    long got;
    if (!bytes)
        return 0;
    if (!buffer) {
        errno = EINVAL;
        if (pi4_quake_fd_is_pak((long)fd)) {
            pi4_quake_pak_read_error_count++;
            pi4_quake_pak_last_request_bytes = bytes;
            pi4_quake_pak_last_result = -PI4_VIBE_EINVAL;
            pi4_quake_report_pak_io_failure("read", pi4_quake_pak_last_result);
        }
        return -PI4_VIBE_EINVAL;
    }
    if (pi4_quake_fd_is_pak((long)fd)) {
        pi4_quake_pak_read_calls++;
        pi4_quake_pak_last_request_bytes = bytes;
        if (pi4_quake_pak_cache_ready && pi4_quake_pak_fd_offset_valid) {
            unsigned long offset;
            unsigned long avail;
            unsigned long copied;
            offset = pi4_quake_pak_fd_offset;
            if (offset >= pi4_quake_pak_cache_size) {
                pi4_quake_pak_last_result = 0;
                return 0;
            }
            avail = pi4_quake_pak_cache_size - offset;
            copied = bytes < avail ? bytes : avail;
            memcpy(buffer, pi4_quake_pak_cache + offset, (size_t)copied);
            pi4_quake_pak_fd_offset += copied;
            pi4_quake_pak_note_offset((long)pi4_quake_pak_fd_offset);
            pi4_quake_pak_read_bytes += copied;
            pi4_quake_pak_last_result = (long)copied;
            if (copied < bytes)
                pi4_quake_pak_short_read_count++;
            return (long)copied;
        }
    }
    got = pi4_quake_file_read_chunks(fd, buffer, bytes);
    if (pi4_quake_fd_is_pak((long)fd)) {
        pi4_quake_pak_last_result = got;
        if (got < 0) {
            pi4_quake_pak_read_error_count++;
            pi4_quake_pak_fd_offset_valid = 0;
            errno = pi4_quake_errno_from_result(got, EIO);
            pi4_quake_report_pak_io_failure("read", got);
        } else {
            pi4_quake_pak_read_bytes += (unsigned long)got;
            if ((unsigned long)got < bytes)
                pi4_quake_pak_short_read_count++;
            if (pi4_quake_pak_fd_offset_valid) {
                if ((unsigned long)got > ULONG_MAX - pi4_quake_pak_fd_offset) {
                    pi4_quake_pak_fd_offset_valid = 0;
                } else {
                    pi4_quake_pak_fd_offset += (unsigned long)got;
                    pi4_quake_pak_note_offset((long)pi4_quake_pak_fd_offset);
                }
            }
        }
    } else if (got < 0) {
        errno = pi4_quake_errno_from_result(got, EIO);
    }
    return got;
}

long pi4_quake_file_seek(unsigned long fd, long offset, unsigned long whence)
{
    long target;
    long result;
    if (!pi4_quake_fd_is_pak((long)fd))
        return vibe_user_lseek((pi4_vibe_word_t)fd, (pi4_vibe_sword_t)offset, whence);

    pi4_quake_pak_seek_count++;
    if (pi4_quake_pak_seek_target(
            (long)fd,
            (long)pi4_quake_pak_fd_offset,
            pi4_quake_pak_fd_offset_valid,
            offset,
            whence,
            &target) < 0) {
        pi4_quake_pak_fd_offset_valid = 0;
        return -1;
    }
    if (pi4_quake_pak_cache_ready) {
        pi4_quake_pak_note_fd_offset(target);
        return target;
    }
    result = vibe_user_lseek((pi4_vibe_word_t)fd, (pi4_vibe_sword_t)target, SEEK_SET);
    if (result != target) {
        if (result < 0)
            errno = pi4_quake_errno_from_result(result, EIO);
        else
            errno = EIO;
        pi4_quake_pak_fd_offset_valid = 0;
        return -1;
    }
    pi4_quake_pak_note_fd_offset(result);
    return result;
}

int fscanf(FILE* stream, const char* format, ...)
{
    (void)stream;
    (void)format;
    return EOF;
}

double fabs(double x)
{
    return x < 0.0 ? -x : x;
}

double floor(double x)
{
    long i;
    i = (long)x;
    if (x < 0.0 && (double)i != x)
        i--;
    return (double)i;
}

double ceil(double x)
{
    long i;
    i = (long)x;
    if (x > 0.0 && (double)i != x)
        i++;
    return (double)i;
}

double sqrt(double x)
{
    double guess;
    int i;
    if (x <= 0.0)
        return 0.0;
    guess = x > 1.0 ? x : 1.0;
    for (i = 0; i < 16; i++)
        guess = 0.5 * (guess + x / guess);
    return guess;
}

static double pi4_wrap_radians(double x)
{
    const double two_pi = 6.28318530717958647692;
    while (x > M_PI)
        x -= two_pi;
    while (x < -M_PI)
        x += two_pi;
    return x;
}

double sin(double x)
{
    double x2;
    double term;
    double sum;
    int n;
    x = pi4_wrap_radians(x);
    x2 = x * x;
    term = x;
    sum = x;
    for (n = 1; n < 8; n++) {
        term *= -x2 / ((double)(2 * n) * (double)(2 * n + 1));
        sum += term;
    }
    return sum;
}

double cos(double x)
{
    double x2;
    double term;
    double sum;
    int n;
    x = pi4_wrap_radians(x);
    x2 = x * x;
    term = 1.0;
    sum = 1.0;
    for (n = 1; n < 8; n++) {
        term *= -x2 / ((double)(2 * n - 1) * (double)(2 * n));
        sum += term;
    }
    return sum;
}

double tan(double x)
{
    double c;
    c = cos(x);
    if (c == 0.0)
        return 0.0;
    return sin(x) / c;
}

double atan(double x)
{
    double x2;
    double term;
    double sum;
    int n;
    if (x > 1.0)
        return M_PI / 2.0 - atan(1.0 / x);
    if (x < -1.0)
        return -M_PI / 2.0 - atan(1.0 / x);
    x2 = x * x;
    term = x;
    sum = x;
    for (n = 1; n < 12; n++) {
        term *= -x2;
        sum += term / (double)(2 * n + 1);
    }
    return sum;
}

double atan2(double y, double x)
{
    if (x > 0.0)
        return atan(y / x);
    if (x < 0.0 && y >= 0.0)
        return atan(y / x) + M_PI;
    if (x < 0.0 && y < 0.0)
        return atan(y / x) - M_PI;
    if (y > 0.0)
        return M_PI / 2.0;
    if (y < 0.0)
        return -M_PI / 2.0;
    return 0.0;
}

static double pi4_log(double x)
{
    double z;
    double z2;
    double term;
    double sum;
    int k;
    int n;
    const double ln2 = 0.69314718055994530942;
    if (x <= 0.0)
        return 0.0;
    k = 0;
    while (x > 2.0) {
        x *= 0.5;
        k++;
    }
    while (x < 0.5) {
        x *= 2.0;
        k--;
    }
    z = (x - 1.0) / (x + 1.0);
    z2 = z * z;
    term = z;
    sum = z;
    for (n = 1; n < 16; n++) {
        term *= z2;
        sum += term / (double)(2 * n + 1);
    }
    return 2.0 * sum + (double)k * ln2;
}

static double pi4_exp(double x)
{
    double term;
    double sum;
    int n;
    int k;
    int scale;
    const double ln2 = 0.69314718055994530942;
    k = 0;
    while (x > ln2) {
        x -= ln2;
        k++;
    }
    while (x < -ln2) {
        x += ln2;
        k--;
    }
    term = 1.0;
    sum = 1.0;
    for (n = 1; n < 20; n++) {
        term *= x / (double)n;
        sum += term;
    }
    scale = k;
    while (scale-- > 0)
        sum *= 2.0;
    scale = k;
    while (scale++ < 0)
        sum *= 0.5;
    return sum;
}

double pow(double x, double y)
{
    double yi;
    double result;
    int exponent;
    int negative;
    if (y == 0.0)
        return 1.0;
    if (x == 0.0)
        return 0.0;
    yi = floor(y);
    if (yi == y && yi > -64.0 && yi < 64.0) {
        exponent = (int)yi;
        negative = exponent < 0;
        if (negative)
            exponent = -exponent;
        result = 1.0;
        while (exponent-- > 0)
            result *= x;
        return negative ? 1.0 / result : result;
    }
    if (x < 0.0)
        return 0.0;
    return pi4_exp(y * pi4_log(x));
}
