#ifndef VIBE_USER_RUNTIME_H
#define VIBE_USER_RUNTIME_H

#include "vibe_os.h"

enum {
    VIBE_SYS_USER_PROBE = 1,
};

int vibe_user_syscall3(unsigned int number, unsigned long arg0, unsigned long arg1, unsigned long arg2);
int vibe_user_syscall_errno(int raw_result, int fallback_errno);
int vibe_user_streq(const char* left, const char* right);
int vibe_user_write_all(int fd, const char* text);
int vibe_user_open(const char* path, unsigned long flags, unsigned long mode);
int vibe_user_close(int fd);
int vibe_user_getpid(void);
int vibe_user_dup(int oldfd);
int vibe_user_dup2(int oldfd, int newfd);
int vibe_user_dup3(int oldfd, int newfd, unsigned long flags);
int vibe_user_fcntl(int fd, int cmd, unsigned long arg);
int vibe_user_clock_monotonic(vibe_clock_time_t* out);
int vibe_user_listdir(const char* path, vibe_dirent_t* entries, unsigned long max_entries);
int vibe_user_execv(const char* path, char* const argv[]);
void vibe_user_report_probe(unsigned long magic, unsigned long flags);

#endif
