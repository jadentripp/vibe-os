#ifndef VIBE_DOOM_PORT_SYS_WAIT_H
#define VIBE_DOOM_PORT_SYS_WAIT_H

#include <sys/types.h>

#define WNOHANG 1

pid_t wait(int* status);
pid_t waitpid(pid_t pid, int* status, int options);

#endif
