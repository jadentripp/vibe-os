#ifndef VIBE_DOOM_PORT_ERRNO_H
#define VIBE_DOOM_PORT_ERRNO_H

extern int errno;

#define EPERM 1
#define ENOENT 2
#define EIO 5
#define EBADF 9
#define ECHILD 10
#define ENOMEM 12
#define EACCES 13
#define ENOTDIR 20
#define EISDIR 21
#define EINVAL 22
#define EMFILE 24
#define ENOTTY 25
#define ENOSPC 28
#define ENOSYS 38
#define EOVERFLOW 75

#endif
