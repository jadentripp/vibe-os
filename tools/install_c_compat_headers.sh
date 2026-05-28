#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "usage: tools/install_c_compat_headers.sh BUILD_INCLUDE_ROOT" >&2
  exit 2
fi

root="$1"
doom="$root/doom"
quake="$root/quake"

rm -rf "$root"
mkdir -p "$doom/sys" "$quake"

cat > "$doom/alloca.h" <<'EOF'
#ifndef VIBE_DOOM_PORT_ALLOCA_H
#define VIBE_DOOM_PORT_ALLOCA_H

#define alloca(size) __builtin_alloca(size)

#endif
EOF

cat > "$doom/ctype.h" <<'EOF'
#ifndef VIBE_DOOM_PORT_CTYPE_H
#define VIBE_DOOM_PORT_CTYPE_H

static inline int isdigit(int ch)
{
    return ch >= '0' && ch <= '9';
}

static inline int isxdigit(int ch)
{
    return (ch >= '0' && ch <= '9')
        || (ch >= 'a' && ch <= 'f')
        || (ch >= 'A' && ch <= 'F');
}

static inline int islower(int ch)
{
    return ch >= 'a' && ch <= 'z';
}

static inline int isupper(int ch)
{
    return ch >= 'A' && ch <= 'Z';
}

static inline int isalpha(int ch)
{
    return islower(ch) || isupper(ch);
}

static inline int isalnum(int ch)
{
    return isalpha(ch) || isdigit(ch);
}

static inline int isspace(int ch)
{
    return ch == ' ' || (ch >= '\t' && ch <= '\r');
}

static inline int isblank(int ch)
{
    return ch == ' ' || ch == '\t';
}

static inline int iscntrl(int ch)
{
    return (ch >= 0 && ch < 0x20) || ch == 0x7f;
}

static inline int isgraph(int ch)
{
    return ch >= 0x21 && ch <= 0x7e;
}

static inline int isprint(int ch)
{
    return ch >= 0x20 && ch <= 0x7e;
}

static inline int ispunct(int ch)
{
    return isgraph(ch) && !isalnum(ch);
}

static inline int toupper(int ch)
{
    return islower(ch) ? ch - ('a' - 'A') : ch;
}

static inline int tolower(int ch)
{
    return isupper(ch) ? ch + ('a' - 'A') : ch;
}

#endif
EOF

cat > "$doom/fcntl.h" <<'EOF'
#ifndef VIBE_DOOM_PORT_FCNTL_H
#define VIBE_DOOM_PORT_FCNTL_H

#define O_RDONLY 0x0000
#define O_WRONLY 0x0001
#define O_RDWR   0x0002
#define O_ACCMODE 0x0003
#define O_CREAT  0x0100
#define O_TRUNC  0x0200
#define O_APPEND 0x0400
#define O_CLOEXEC 0x0800
#define O_BINARY 0x0000

#define F_GETFD 1
#define F_SETFD 2

#define FD_CLOEXEC 1

int open(const char* path, int flags, ...);
int fcntl(int fd, int cmd, ...);

#endif
EOF

cat > "$doom/malloc.h" <<'EOF'
#ifndef VIBE_DOOM_PORT_MALLOC_H
#define VIBE_DOOM_PORT_MALLOC_H

#include <stdlib.h>

#endif
EOF

cat > "$doom/math.h" <<'EOF'
#ifndef VIBE_DOOM_PORT_MATH_H
#define VIBE_DOOM_PORT_MATH_H

double sin(double x);
double cos(double x);
double atan(double x);
double atan2(double y, double x);
double pow(double x, double y);
double sqrt(double x);
double floor(double x);
double ceil(double x);
double fabs(double x);

#endif
EOF

cat > "$doom/stddef.h" <<'EOF'
#ifndef VIBE_DOOM_PORT_STDDEF_H
#define VIBE_DOOM_PORT_STDDEF_H

typedef unsigned int size_t;
typedef int ptrdiff_t;

#ifndef NULL
#define NULL ((void*)0)
#endif

#endif
EOF

cat > "$doom/stdio.h" <<'EOF'
#ifndef VIBE_DOOM_PORT_STDIO_H
#define VIBE_DOOM_PORT_STDIO_H

#include <stdarg.h>
#include <stddef.h>

#define EOF (-1)
#define SEEK_SET 0
#define SEEK_CUR 1
#define SEEK_END 2

typedef struct vibe_doom_file FILE;

extern FILE* stdin;
extern FILE* stdout;
extern FILE* stderr;

int printf(const char* format, ...);
int fprintf(FILE* stream, const char* format, ...);
int sprintf(char* buffer, const char* format, ...);
int snprintf(char* buffer, size_t size, const char* format, ...);
int vprintf(const char* format, va_list args);
int vfprintf(FILE* stream, const char* format, va_list args);
int vsprintf(char* buffer, const char* format, va_list args);
int vsnprintf(char* buffer, size_t size, const char* format, va_list args);
int sscanf(const char* text, const char* format, ...);
int fscanf(FILE* stream, const char* format, ...);

FILE* fopen(const char* path, const char* mode);
size_t fread(void* ptr, size_t size, size_t count, FILE* stream);
size_t fwrite(const void* ptr, size_t size, size_t count, FILE* stream);
int fgetc(FILE* stream);
int getc(FILE* stream);
int ungetc(int ch, FILE* stream);
char* fgets(char* buffer, int size, FILE* stream);
int fputc(int ch, FILE* stream);
int putc(int ch);
int putchar(int ch);
int fputs(const char* text, FILE* stream);
int puts(const char* text);
int fseek(FILE* stream, long offset, int whence);
long ftell(FILE* stream);
void rewind(FILE* stream);
int fclose(FILE* stream);
int fflush(FILE* stream);
int feof(FILE* stream);
int ferror(FILE* stream);
void clearerr(FILE* stream);
void setbuf(FILE* stream, char* buffer);
int getchar(void);
int remove(const char* path);
void perror(const char* text);

#endif
EOF

cat > "$doom/stdlib.h" <<'EOF'
#ifndef VIBE_DOOM_PORT_STDLIB_H
#define VIBE_DOOM_PORT_STDLIB_H

#include <stddef.h>

#define EXIT_SUCCESS 0
#define EXIT_FAILURE 1
#define RAND_MAX 0x7fffffff

static inline int abs(int value)
{
    return value < 0 ? -value : value;
}

long labs(long value);
int atoi(const char* text);
long atol(const char* text);
double atof(const char* text);
long strtol(const char* text, char** endptr, int base);
unsigned long strtoul(const char* text, char** endptr, int base);
double strtod(const char* text, char** endptr);
void qsort(void* base, size_t count, size_t size, int (*compar)(const void*, const void*));
void* bsearch(
    const void* key,
    const void* base,
    size_t count,
    size_t size,
    int (*compar)(const void*, const void*));
void* malloc(size_t size);
void* calloc(size_t count, size_t size);
void* realloc(void* ptr, size_t size);
void free(void* ptr);
void exit(int status);
char* getenv(const char* name);
int rand(void);
void srand(unsigned int seed);

#endif
EOF

cat > "$doom/string.h" <<'EOF'
#ifndef VIBE_DOOM_PORT_STRING_H
#define VIBE_DOOM_PORT_STRING_H

#include <stddef.h>

void* memcpy(void* dest, const void* src, size_t count);
void* memmove(void* dest, const void* src, size_t count);
void* memset(void* dest, int value, size_t count);
int memcmp(const void* left, const void* right, size_t count);
void* memchr(const void* data, int ch, size_t count);
size_t strlen(const char* text);
size_t strnlen(const char* text, size_t max_length);
char* strcpy(char* dest, const char* src);
char* strncpy(char* dest, const char* src, size_t count);
char* strcat(char* dest, const char* src);
char* strncat(char* dest, const char* src, size_t count);
int strcmp(const char* left, const char* right);
int strncmp(const char* left, const char* right, size_t count);
int strcasecmp(const char* left, const char* right);
int strncasecmp(const char* left, const char* right, size_t count);
char* strchr(const char* text, int ch);
char* strrchr(const char* text, int ch);
char* strpbrk(const char* text, const char* accept);
char* strstr(const char* text, const char* needle);
size_t strspn(const char* text, const char* accept);
size_t strcspn(const char* text, const char* reject);
char* strtok(char* text, const char* delimiters);
char* strtok_r(char* text, const char* delimiters, char** saveptr);
char* strdup(const char* text);
char* strndup(const char* text, size_t max_length);
char* strerror(int error);

#define strcmpi strcasecmp

#endif
EOF

cat > "$doom/sys/stat.h" <<'EOF'
#ifndef VIBE_DOOM_PORT_SYS_STAT_H
#define VIBE_DOOM_PORT_SYS_STAT_H

#include <sys/types.h>

struct stat
{
    dev_t st_dev;
    ino_t st_ino;
    mode_t st_mode;
    nlink_t st_nlink;
    uid_t st_uid;
    gid_t st_gid;
    dev_t st_rdev;
    off_t st_size;
    time_t st_atime;
    time_t st_mtime;
    time_t st_ctime;
};

#define S_IFREG 0100000
#define S_IFDIR 0040000
#define S_IFMT  0170000
#define S_IRUSR 0000400
#define S_IWUSR 0000200

#define S_ISREG(mode) (((mode) & S_IFMT) == S_IFREG)
#define S_ISDIR(mode) (((mode) & S_IFMT) == S_IFDIR)

int stat(const char* path, struct stat* out);
int fstat(int fd, struct stat* out);
int mkdir(const char* path, mode_t mode);

#endif
EOF

cat > "$doom/sys/types.h" <<'EOF'
#ifndef VIBE_DOOM_PORT_SYS_TYPES_H
#define VIBE_DOOM_PORT_SYS_TYPES_H

#include <stddef.h>

typedef int ssize_t;
typedef int off_t;
typedef int pid_t;
typedef unsigned int mode_t;
typedef unsigned int dev_t;
typedef unsigned int ino_t;
typedef unsigned int nlink_t;
typedef unsigned int uid_t;
typedef unsigned int gid_t;
typedef int time_t;

#endif
EOF

cat > "$doom/unistd.h" <<'EOF'
#ifndef VIBE_DOOM_PORT_UNISTD_H
#define VIBE_DOOM_PORT_UNISTD_H

#include <stddef.h>
#include <sys/types.h>

#define F_OK 0
#define X_OK 1
#define R_OK 4
#define W_OK 2

ssize_t read(int fd, void* buffer, size_t count);
ssize_t write(int fd, const void* buffer, size_t count);
ssize_t pread(int fd, void* buffer, size_t count, off_t offset);
ssize_t pwrite(int fd, const void* buffer, size_t count, off_t offset);
int close(int fd);
int dup(int oldfd);
int dup2(int oldfd, int newfd);
int dup3(int oldfd, int newfd, int flags);
off_t lseek(int fd, off_t offset, int whence);
int ftruncate(int fd, off_t length);
int truncate(const char* path, off_t length);
int access(const char* path, int mode);
int unlink(const char* path);
void _exit(int status);
int execl(const char* path, const char* arg, ...);
int execv(const char* path, char* const argv[]);
int execve(const char* path, char* const argv[], char* const envp[]);
extern char** environ;
pid_t fork(void);
pid_t getpid(void);

#endif
EOF

cat > "$doom/values.h" <<'EOF'
#ifndef VIBE_DOOM_PORT_VALUES_H
#define VIBE_DOOM_PORT_VALUES_H

#define MAXCHAR  ((char)0x7f)
#define MAXSHORT ((short)0x7fff)
#define MAXINT   ((int)0x7fffffff)
#define MAXLONG  ((long)0x7fffffff)
#define MINCHAR  ((char)0x80)
#define MINSHORT ((short)0x8000)
#define MININT   ((int)0x80000000)
#define MINLONG  ((long)0x80000000)

#endif
EOF

cat > "$quake/math.h" <<'EOF'
#ifndef VIBE_QUAKE_PORT_MATH_H
#define VIBE_QUAKE_PORT_MATH_H

#define M_PI 3.14159265358979323846

double sin(double x);
double cos(double x);
double tan(double x);
double atan(double x);
double atan2(double y, double x);
double pow(double x, double y);
double sqrt(double x);
double floor(double x);
double ceil(double x);
double fabs(double x);

#endif
EOF

cat > "$quake/setjmp.h" <<'EOF'
#ifndef VIBE_QUAKE_PORT_SETJMP_H
#define VIBE_QUAKE_PORT_SETJMP_H

typedef unsigned long jmp_buf[6];

int setjmp(jmp_buf env);
void longjmp(jmp_buf env, int value);

#endif
EOF
