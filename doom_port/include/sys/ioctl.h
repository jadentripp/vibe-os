#ifndef VIBE_DOOM_PORT_SYS_IOCTL_H
#define VIBE_DOOM_PORT_SYS_IOCTL_H

#include "vibe_os.h"

#define FIONBIO 0x5421

int ioctl(int fd, unsigned long request, void* arg);

#endif
