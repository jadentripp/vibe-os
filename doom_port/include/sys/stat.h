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
