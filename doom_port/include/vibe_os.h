#ifndef VIBE_DOOM_PORT_VIBE_OS_H
#define VIBE_DOOM_PORT_VIBE_OS_H

enum {
    VIBE_SYS_EXIT = 2,
    VIBE_SYS_WRITE = 4,
    VIBE_SYS_SBRK = 5,
    VIBE_SYS_OPEN = 6,
    VIBE_SYS_READ = 7,
    VIBE_SYS_LSEEK = 8,
    VIBE_SYS_TIME = 9,
    VIBE_SYS_PRESENT = 10,
    VIBE_SYS_POLL_KEY = 11,
    VIBE_SYS_CLOSE = 12,
    VIBE_SYS_AUDIO = 13,
    VIBE_SYS_POLL_MOUSE = 14,
    VIBE_SYS_GAMEPLAY_STATUS = 15,
};

enum {
    VIBE_AUDIO_INIT = 1,
    VIBE_AUDIO_START_SFX = 2,
    VIBE_AUDIO_STOP_SFX = 3,
    VIBE_AUDIO_UPDATE_SFX = 4,
    VIBE_AUDIO_SHUTDOWN = 5,
};

enum {
    VIBE_KEY_EVENT_DOWN = 0x00000100u,
    VIBE_KEY_EVENT_VALID = 0x00010000u,
};

enum {
    VIBE_MOUSE_EVENT_VALID = 0x01000000u,
};

int vibe_syscall3(unsigned int number, unsigned long arg0, unsigned long arg1, unsigned long arg2);

#endif
