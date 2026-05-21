#ifndef VIBE_DOOM_PORT_TIME_H
#define VIBE_DOOM_PORT_TIME_H

#include <sys/types.h>

typedef int clockid_t;

struct timespec {
    time_t tv_sec;
    long tv_nsec;
};

#define CLOCK_MONOTONIC 1

int clock_gettime(clockid_t clock_id, struct timespec* tp);

#endif
