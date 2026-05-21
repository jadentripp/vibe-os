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
int close(int fd);
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
