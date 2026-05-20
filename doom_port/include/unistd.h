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
int access(const char* path, int mode);
int unlink(const char* path);
pid_t fork(void);

#endif
