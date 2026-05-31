#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#ifndef AT_FDCWD
#define AT_FDCWD -100
#endif

#define FUTEX_WAIT_PRIVATE 128
#define FUTEX_WAKE_PRIVATE 129
#define LINUX_EAGAIN 11
#define LINUX_RLIMIT_STACK 3

static int raw_faccessat(const char *path, int mode) {
    register int nr __asm__("eax") = 307;
    register int dirfd __asm__("ebx") = AT_FDCWD;
    register const char *name __asm__("ecx") = path;
    register int access_mode __asm__("edx") = mode;
    __asm__ __volatile__("int $0x80"
                         : "+a"(nr)
                         : "b"(dirfd), "c"(name), "d"(access_mode)
                         : "memory");
    return nr;
}

static int raw_getrlimit(int resource, void *limit) {
    register int nr __asm__("eax") = 76;
    register int res __asm__("ebx") = resource;
    register void *lim __asm__("ecx") = limit;
    __asm__ __volatile__("int $0x80"
                         : "+a"(nr)
                         : "b"(res), "c"(lim)
                         : "memory");
    return nr;
}

static int raw_rt_sigaction(int signum, const void *act, void *oldact) {
    register int nr __asm__("eax") = 174;
    register int sig __asm__("ebx") = signum;
    register const void *new_action __asm__("ecx") = act;
    register void *old_action __asm__("edx") = oldact;
    register int sigset_size __asm__("esi") = 8;
    __asm__ __volatile__("int $0x80"
                         : "+a"(nr)
                         : "b"(sig), "c"(new_action), "d"(old_action), "S"(sigset_size)
                         : "memory");
    return nr;
}

static int raw_futex(int *word, int op, int value) {
    register int nr __asm__("eax") = 240;
    register int *uaddr __asm__("ebx") = word;
    register int futex_op __asm__("ecx") = op;
    register int futex_value __asm__("edx") = value;
    register void *timeout __asm__("esi") = NULL;
    __asm__ __volatile__("int $0x80"
                         : "+a"(nr)
                         : "b"(uaddr), "c"(futex_op), "d"(futex_value), "S"(timeout)
                         : "memory");
    return nr;
}

static int raw_set_robust_list(void *head, unsigned int len) {
    register int nr __asm__("eax") = 311;
    register void *robust_head __asm__("ebx") = head;
    register unsigned int robust_len __asm__("ecx") = len;
    __asm__ __volatile__("int $0x80"
                         : "+a"(nr)
                         : "b"(robust_head), "c"(robust_len)
                         : "memory");
    return nr;
}

static int raw_prlimit64(int resource, void *old_limit) {
    register int nr __asm__("eax") = 340;
    register int pid __asm__("ebx") = 0;
    register int res __asm__("ecx") = resource;
    register void *new_limit __asm__("edx") = NULL;
    register void *old_limit_arg __asm__("esi") = old_limit;
    __asm__ __volatile__("int $0x80"
                         : "+a"(nr)
                         : "b"(pid), "c"(res), "d"(new_limit), "S"(old_limit_arg)
                         : "memory");
    return nr;
}

static int same_text(const char *left, const char *right) {
    while (*left != 0 && *right != 0) {
        if (*left != *right) {
            return 0;
        }
        left++;
        right++;
    }

    return *left == *right;
}

static int check_numbers(void) {
    char *end = NULL;
    char buf[32];
    long value;
    int n;

    errno = 0;
    value = strtol("12345x", &end, 10);
    if (value != 12345 || end == NULL || *end != 'x' || errno != 0) {
        return 30;
    }

    n = snprintf(buf, sizeof(buf), "n=%ld hex=%x", value, 0x2a);
    if (n != 14 || !same_text(buf, "n=12345 hex=2a")) {
        return 31;
    }

    return 0;
}

static int cmp_ints(const void *left, const void *right) {
    const int a = *(const int *)left;
    const int b = *(const int *)right;

    return (a > b) - (a < b);
}

static int check_heap_and_sort(void) {
    int *values = malloc(4 * sizeof(*values));
    int *grown;

    if (values == NULL) {
        return 40;
    }

    values[0] = 7;
    values[1] = 3;
    values[2] = 5;
    values[3] = 1;
    qsort(values, 4, sizeof(*values), cmp_ints);
    if (values[0] != 1 || values[1] != 3 || values[2] != 5 || values[3] != 7) {
        free(values);
        return 41;
    }

    grown = realloc(values, 6 * sizeof(*values));
    if (grown == NULL) {
        free(values);
        return 42;
    }
    values = grown;
    values[4] = 9;
    values[5] = 11;

    if (values[5] != 11) {
        free(values);
        return 43;
    }

    free(values);
    return 0;
}

static int check_file_io(void) {
    unsigned char ident[4];
    int fd;
    ssize_t got;

    if (access("/LIB/LIBC.SO6", R_OK) != 0) {
        return 60;
    }

    if (raw_faccessat("/LIB/LIBC.SO6", R_OK) != 0) {
        return 61;
    }

    fd = open("/LIB/LIBC.SO6", O_RDONLY);
    if (fd < 0) {
        return 62;
    }

    got = read(fd, ident, sizeof(ident));
    if (got != (ssize_t)sizeof(ident)) {
        close(fd);
        return 63;
    }

    if (close(fd) != 0) {
        return 64;
    }

    if (ident[0] != 0x7f || ident[1] != 'E' || ident[2] != 'L' || ident[3] != 'F') {
        return 65;
    }

    return 0;
}

static int check_glibc_init_syscalls(void) {
    unsigned long limit32[2] = {0, 0};
    unsigned long long limit64[2] = {0, 0};
    unsigned int robust_head[3] = {0, 0, 0};
    unsigned char old_action[20];
    int futex_word = 0;

    if (raw_getrlimit(LINUX_RLIMIT_STACK, limit32) != 0 || limit32[0] == 0 || limit32[1] == 0) {
        return 70;
    }

    if (raw_prlimit64(LINUX_RLIMIT_STACK, limit64) != 0 || limit64[0] == 0 || limit64[1] == 0) {
        return 71;
    }

    if (raw_set_robust_list(robust_head, sizeof(robust_head)) != 0) {
        return 72;
    }

    if (raw_rt_sigaction(2, NULL, old_action) != 0) {
        return 73;
    }

    if (raw_futex(&futex_word, FUTEX_WAKE_PRIVATE, 1) != 0) {
        return 74;
    }

    if (raw_futex(&futex_word, FUTEX_WAIT_PRIVATE, 1) != -LINUX_EAGAIN) {
        return 75;
    }

    return 0;
}

int main(void) {
    int rc;
    int pid;

    rc = check_numbers();
    if (rc != 0) {
        return rc;
    }

    rc = check_heap_and_sort();
    if (rc != 0) {
        return rc;
    }

    rc = check_file_io();
    if (rc != 0) {
        return rc;
    }

    rc = check_glibc_init_syscalls();
    if (rc != 0) {
        return rc;
    }

    pid = getpid();
    if (pid <= 0) {
        return 44;
    }

    printf("libc probe ok: %s %d pid=%d\n", getenv("VIBE_LIBC_PROBE") ? "env" : "noenv", 42, pid);
    if (fflush(stdout) != 0) {
        return 50;
    }

    return 13;
}
