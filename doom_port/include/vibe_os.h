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
    VIBE_SYS_EXEC = 16,
    VIBE_SYS_UNLINK = 17,
    VIBE_SYS_STAT = 18,
    VIBE_SYS_FSTAT = 19,
    VIBE_SYS_MMAP = 20,
    VIBE_SYS_MUNMAP = 21,
    VIBE_SYS_IOCTL = 22,
    VIBE_SYS_FORK = 23,
    VIBE_SYS_WAITPID = 24,
    VIBE_SYS_GETPID = 25,
};

enum {
    VIBE_AUDIO_INIT = 1,
    VIBE_AUDIO_START_SFX = 2,
    VIBE_AUDIO_STOP_SFX = 3,
    VIBE_AUDIO_UPDATE_SFX = 4,
    VIBE_AUDIO_SHUTDOWN = 5,
    VIBE_AUDIO_IS_PLAYING = 6,
    VIBE_AUDIO_BUFFERED_BYTES = 7,
};

typedef struct vibe_audio_sfx_desc {
    const unsigned char* samples;
    unsigned long length;
    unsigned long volume;
    unsigned long separation;
    unsigned long pitch;
    unsigned long sound_id;
    unsigned long flags;
} vibe_audio_sfx_desc_t;

enum {
    VIBE_AUDIO_FLAG_LOOP = 0x00000001u,
    VIBE_AUDIO_FLAG_MUSIC = 0x00000002u,
};

enum {
    VIBE_KEY_EVENT_DOWN = 0x00000100u,
    VIBE_KEY_EVENT_VALID = 0x00010000u,
};

enum {
    VIBE_MOUSE_EVENT_VALID = 0x01000000u,
};

enum {
    VIBE_PLAYABLE_STATUS = 0x80000000u,
    VIBE_PLAYABLE_SEEN_PLAYER = 0x0001u,
    VIBE_PLAYABLE_SEEN_MOVE_CMD = 0x0002u,
    VIBE_PLAYABLE_SEEN_ATTACK_CMD = 0x0004u,
    VIBE_PLAYABLE_SEEN_USE_CMD = 0x0008u,
    VIBE_PLAYABLE_SEEN_MENU = 0x0010u,
    VIBE_PLAYABLE_SEEN_POS_DELTA = 0x0020u,
    VIBE_PLAYABLE_SEEN_AMMO_DELTA = 0x0040u,
    VIBE_PLAYABLE_SEEN_REFIRE = 0x0080u,
};

enum {
    VIBE_DOOM_INIT_STATUS = 0x40000000u,
    VIBE_DOOM_INIT_START = 0x0001u,
    VIBE_DOOM_INIT_I_INIT = 0x0002u,
    VIBE_DOOM_INIT_ZONE = 0x0004u,
    VIBE_DOOM_INIT_NETWORK = 0x0008u,
    VIBE_DOOM_INIT_SOUND = 0x0010u,
    VIBE_DOOM_INIT_GRAPHICS = 0x0020u,
    VIBE_DOOM_INIT_PALETTE = 0x0040u,
    VIBE_DOOM_INIT_TIC = 0x0080u,
    VIBE_DOOM_INIT_FRAME = 0x0100u,
};

enum {
    VIBE_DISPLAY_FD = 1,
    VIBE_IOCTL_FBINFO = 0x00005601u,
    VIBE_IOCTL_PRESENT_INDEXED = 0x00005602u,
};

typedef struct vibe_fb_info {
    unsigned long width;
    unsigned long height;
    unsigned long pitch;
    unsigned long backend;
    unsigned long frame_bytes;
    unsigned long palette_bytes;
    unsigned long scale;
    unsigned long view_x;
    unsigned long view_y;
    unsigned long view_width;
    unsigned long view_height;
    unsigned long policy;
    unsigned long dirty_x;
    unsigned long dirty_y;
    unsigned long dirty_width;
    unsigned long dirty_height;
    unsigned long dirty_count;
} vibe_fb_info_t;

enum {
    VIBE_FB_POLICY_MODE13 = 1,
    VIBE_FB_POLICY_ASPECT = 2,
    VIBE_FB_POLICY_SQUARE = 3,
};

typedef struct vibe_present_indexed {
    const void* frame;
    const void* palette;
    unsigned long width;
    unsigned long height;
} vibe_present_indexed_t;

int vibe_syscall3(unsigned int number, unsigned long arg0, unsigned long arg1, unsigned long arg2);

/*
 * Doom port syscall ABI:
 * - Success returns a non-negative int-sized value.
 * - Failure returns -errno when the kernel can classify the error.
 * - Legacy kernel paths may still return -1; libc maps those through the
 *   operation-specific fallback errno.
 * - File flags use the O_* constants from fcntl.h, including O_ACCMODE and
 *   O_CLOEXEC.
 * - mmap is currently anonymous/private and brk-backed; munmap validates the
 *   mapping range but does not reclaim heap pages.
 * - execv passes a bounded argv vector to the process handoff. Table entries
 *   cover Doom/probe images; other root-level FAT16 .ELF names use reusable
 *   probe-class slots. File descriptors inherit across exec unless opened with
 *   O_CLOEXEC. envp is intentionally empty for now.
 * - getpid returns the active static process id.
 * - fork returns ENOSYS until address-space cloning exists. wait/waitpid scan
 *   parent-PID metadata, reap EXITED/FAULTED children, support WNOHANG, and
 *   return ENOSYS for blocking waits on live children until a sleep queue
 *   exists.
 */

#endif
