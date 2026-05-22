#ifndef VIBE_DOOM_PORT_TIME_H
#define VIBE_DOOM_PORT_TIME_H

#include <sys/types.h>

typedef int clockid_t;
typedef long clock_t;

struct timespec {
    time_t tv_sec;
    long tv_nsec;
};

#define CLOCK_MONOTONIC 1
#define CLOCKS_PER_SEC 1000L

int clock_gettime(clockid_t clock_id, struct timespec* tp);
clock_t clock(void);
time_t time(time_t* out);

#endif
