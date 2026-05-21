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

#endif
