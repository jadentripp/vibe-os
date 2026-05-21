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
    VIBE_SYS_PLAYER_DETAIL_STATUS = 26,
    VIBE_SYS_FTRUNCATE = 27,
    VIBE_SYS_POLL_INPUT = 28,
    VIBE_SYS_CLOCK_GETTIME = 29,
    VIBE_SYS_LISTDIR = 30,
    VIBE_SYS_INPUT_STATUS = 31,
};

enum {
    VIBE_EXEC_PATH_MAX = 16,
    VIBE_EXEC_ARG_MAX = 8,
    VIBE_EXEC_ARG_STR_MAX = 64,
    VIBE_EXEC_ARGV_SOURCE_DEFAULT = 1,
    VIBE_EXEC_ARGV_SOURCE_USER = 2,
};

enum {
    VIBE_CLOCK_MONOTONIC = 1,
    VIBE_CLOCK_MONOTONIC_HZ = 100,
};

typedef struct vibe_clock_time {
    unsigned long ticks;
    unsigned long frequency_hz;
    unsigned long milliseconds;
    unsigned long flags;
} vibe_clock_time_t;

typedef struct vibe_dirent {
    char name[16];
    unsigned long size;
    unsigned long mode;
    unsigned long first_cluster;
    unsigned long attributes;
} vibe_dirent_t;

enum {
    VIBE_DIRENT_NAME_BYTES = 16,
    VIBE_DIRENT_BYTES = 32,
};

enum {
    VIBE_DIRENT_ATTR_READ_ONLY = 0x01u,
    VIBE_DIRENT_ATTR_HIDDEN = 0x02u,
    VIBE_DIRENT_ATTR_SYSTEM = 0x04u,
    VIBE_DIRENT_ATTR_VOLUME_ID = 0x08u,
    VIBE_DIRENT_ATTR_DIRECTORY = 0x10u,
    VIBE_DIRENT_ATTR_ARCHIVE = 0x20u,
};

static inline int vibe_dirent_is_directory(const vibe_dirent_t* entry)
{
    return entry && (entry->attributes & VIBE_DIRENT_ATTR_DIRECTORY) != 0;
}

static inline int vibe_dirent_is_regular_file(const vibe_dirent_t* entry)
{
    return entry && entry->name[0] && !vibe_dirent_is_directory(entry);
}

enum {
    VIBE_AUDIO_DEVICE_NONE = 0,
    VIBE_AUDIO_DEVICE_SB16 = 1,
};

enum {
    VIBE_AUDIO_DEVICE_STATUS_NONE = 0,
    VIBE_AUDIO_DEVICE_STATUS_READY = 1,
    VIBE_AUDIO_DEVICE_STATUS_ABSENT = 2,
};

enum {
    VIBE_AUDIO_FORMAT_U8_STEREO = 1,
};

enum {
    VIBE_AUDIO_CAP_PCM_RING = 0x00000001u,
    VIBE_AUDIO_CAP_MIXER_VOICES = 0x00000002u,
    VIBE_AUDIO_CAP_PULL_STREAM = 0x00000004u,
    VIBE_AUDIO_CAP_SB16_DMA = 0x00000008u,
};

enum {
    VIBE_AUDIO_DEVICE_START = 1,
    VIBE_AUDIO_MIXER_START = 2,
    VIBE_AUDIO_MIXER_STOP = 3,
    VIBE_AUDIO_MIXER_UPDATE = 4,
    VIBE_AUDIO_DEVICE_SHUTDOWN = 5,
    VIBE_AUDIO_MIXER_IS_PLAYING = 6,
    VIBE_AUDIO_PCM_BUFFERED_BYTES = 7,
    VIBE_AUDIO_PCM_PULL_STATE = 8,
    VIBE_AUDIO_DEVICE_INFO = 9,
    VIBE_AUDIO_PCM_RING_INFO = 10,
};

enum {
    VIBE_AUDIO_INIT = VIBE_AUDIO_DEVICE_START,
    VIBE_AUDIO_START_SFX = VIBE_AUDIO_MIXER_START,
    VIBE_AUDIO_STOP_SFX = VIBE_AUDIO_MIXER_STOP,
    VIBE_AUDIO_UPDATE_SFX = VIBE_AUDIO_MIXER_UPDATE,
    VIBE_AUDIO_SHUTDOWN = VIBE_AUDIO_DEVICE_SHUTDOWN,
    VIBE_AUDIO_IS_PLAYING = VIBE_AUDIO_MIXER_IS_PLAYING,
    VIBE_AUDIO_BUFFERED_BYTES = VIBE_AUDIO_PCM_BUFFERED_BYTES,
    VIBE_AUDIO_MUSIC_PULL_STATE = VIBE_AUDIO_PCM_PULL_STATE,
};

enum {
    VIBE_AUDIO_MUSIC_STREAM_NONE = 0,
    VIBE_AUDIO_MUSIC_STREAM_PUSH = 1,
    VIBE_AUDIO_MUSIC_STREAM_PULL = 2,
};

typedef struct vibe_audio_sfx_desc {
    const unsigned char* samples;
    unsigned long length;
    unsigned long volume;
    unsigned long separation;
    unsigned long pitch;
    unsigned long sound_id;
    unsigned long flags;
    unsigned long sample_rate;
    unsigned long music_format;
    unsigned long music_note_events;
    unsigned long music_control_events;
    unsigned long music_active_voice_peak;
    unsigned long music_emitted_samples;
    unsigned long music_stream_start;
    unsigned long music_stream_end;
    unsigned long music_stream_loop_count;
} vibe_audio_sfx_desc_t;

typedef vibe_audio_sfx_desc_t vibe_audio_voice_desc_t;

enum {
    VIBE_AUDIO_VOICE_DESC_BYTES = 64,
};

static inline void vibe_audio_voice_desc_init(
    vibe_audio_voice_desc_t* desc,
    const unsigned char* samples,
    unsigned long length,
    unsigned long sample_rate,
    unsigned long volume,
    unsigned long separation,
    unsigned long pitch)
{
    if (!desc)
        return;

    desc->samples = samples;
    desc->length = length;
    desc->volume = volume;
    desc->separation = separation;
    desc->pitch = pitch;
    desc->sound_id = 0;
    desc->flags = 0;
    desc->sample_rate = sample_rate;
    desc->music_format = 0;
    desc->music_note_events = 0;
    desc->music_control_events = 0;
    desc->music_active_voice_peak = 0;
    desc->music_emitted_samples = 0;
    desc->music_stream_start = 0;
    desc->music_stream_end = 0;
    desc->music_stream_loop_count = 0;
}

typedef struct vibe_audio_device_info {
    unsigned long device_kind;
    unsigned long status;
    unsigned long sample_rate;
    unsigned long channels;
    unsigned long format;
    unsigned long ring_bytes;
    unsigned long period_bytes;
    unsigned long capabilities;
    unsigned long active_voices;
    unsigned long irq_count;
    unsigned long refill_count;
    unsigned long playback_start_count;
} vibe_audio_device_info_t;

enum {
    VIBE_AUDIO_DEVICE_INFO_BYTES = 48,
};

typedef struct vibe_audio_pcm_ring_info {
    unsigned long format;
    unsigned long channels;
    unsigned long sample_rate;
    unsigned long ring_bytes;
    unsigned long period_bytes;
    unsigned long write_offset;
    unsigned long active_half;
    unsigned long queued_bytes;
    unsigned long mixed_bytes;
    unsigned long underrun_count;
    unsigned long overwrite_count;
    unsigned long clip_count;
} vibe_audio_pcm_ring_info_t;

enum {
    VIBE_AUDIO_PCM_RING_INFO_BYTES = 48,
};

static inline int vibe_audio_device_is_ready(const vibe_audio_device_info_t* info)
{
    return info
        && info->status == VIBE_AUDIO_DEVICE_STATUS_READY
        && info->device_kind != VIBE_AUDIO_DEVICE_NONE;
}

static inline int vibe_audio_device_has_capability(
    const vibe_audio_device_info_t* info,
    unsigned long capability)
{
    return info && (info->capabilities & capability) == capability;
}

static inline int vibe_audio_pcm_ring_is_u8_stereo(const vibe_audio_pcm_ring_info_t* info)
{
    return info
        && info->format == VIBE_AUDIO_FORMAT_U8_STEREO
        && info->channels == 2;
}

enum {
    VIBE_AUDIO_FLAG_LOOP = 0x00000001u,
    VIBE_AUDIO_FLAG_MUSIC = 0x00000002u,
    VIBE_AUDIO_FLAG_WAD_SFX = 0x00000004u,
    VIBE_AUDIO_FLAG_STREAM_FINAL = 0x00000008u,
};

enum {
    VIBE_KEY_EVENT_DOWN = 0x00000100u,
    VIBE_KEY_EVENT_VALID = 0x00010000u,
};

enum {
    VIBE_MOUSE_EVENT_VALID = 0x01000000u,
};

enum {
    VIBE_INPUT_DEVICE_KEYBOARD = 1,
    VIBE_INPUT_DEVICE_MOUSE = 2,
};

enum {
    VIBE_INPUT_EVENT_NONE = 0,
    VIBE_INPUT_EVENT_KEY = 1,
    VIBE_INPUT_EVENT_MOUSE_PACKET = 2,
};

enum {
    VIBE_INPUT_ABI_VERSION = 1,
    VIBE_INPUT_EVENT_QUEUE_CAPACITY = 64,
};

enum {
    VIBE_INPUT_KEY_RELEASED = 0,
    VIBE_INPUT_KEY_PRESSED = 1,
};

enum {
    VIBE_INPUT_MOUSE_BUTTON_LEFT = 0x01u,
    VIBE_INPUT_MOUSE_BUTTON_RIGHT = 0x02u,
    VIBE_INPUT_MOUSE_BUTTON_MIDDLE = 0x04u,
};

enum {
    VIBE_INPUT_CAP_KEYBOARD = 0x00000001u,
    VIBE_INPUT_CAP_MOUSE = 0x00000002u,
    VIBE_INPUT_CAP_POLL_EVENT = 0x00000004u,
    VIBE_INPUT_CAP_STATUS = 0x00000008u,
};

typedef struct vibe_input_event {
    unsigned long timestamp;
    unsigned long device_id;
    unsigned long type;
    unsigned long code;
    long value0;
    long value1;
    long value2;
} vibe_input_event_t;

enum {
    VIBE_INPUT_EVENT_BYTES = 28,
};

typedef struct vibe_input_status {
    unsigned long abi_version;
    unsigned long event_bytes;
    unsigned long queue_capacity;
    unsigned long queued_events;
    unsigned long total_events;
    unsigned long polled_events;
    unsigned long dropped_events;
    unsigned long capabilities;
    unsigned long keyboard_irq_count;
    unsigned long keyboard_event_count;
    unsigned long keyboard_down_count;
    unsigned long keyboard_last_code;
    unsigned long keyboard_state[8];
    unsigned long mouse_irq_count;
    unsigned long mouse_packet_count;
    unsigned long mouse_sync_loss_count;
    unsigned long mouse_buttons;
    long mouse_delta_x_total;
    long mouse_delta_y_total;
    unsigned long last_event_device_id;
    unsigned long last_event_type;
} vibe_input_status_t;

enum {
    VIBE_INPUT_STATUS_BYTES = 112,
};

static inline void vibe_input_make_key_event(
    vibe_input_event_t* event,
    unsigned long timestamp,
    unsigned long code,
    int pressed)
{
    if (!event)
        return;

    event->timestamp = timestamp;
    event->device_id = VIBE_INPUT_DEVICE_KEYBOARD;
    event->type = VIBE_INPUT_EVENT_KEY;
    event->code = code;
    event->value0 = pressed ? VIBE_INPUT_KEY_PRESSED : VIBE_INPUT_KEY_RELEASED;
    event->value1 = 0;
    event->value2 = 0;
}

static inline void vibe_input_make_mouse_packet_event(
    vibe_input_event_t* event,
    unsigned long timestamp,
    unsigned long buttons,
    long delta_x,
    long delta_y)
{
    if (!event)
        return;

    event->timestamp = timestamp;
    event->device_id = VIBE_INPUT_DEVICE_MOUSE;
    event->type = VIBE_INPUT_EVENT_MOUSE_PACKET;
    event->code = buttons & (
        VIBE_INPUT_MOUSE_BUTTON_LEFT
        | VIBE_INPUT_MOUSE_BUTTON_RIGHT
        | VIBE_INPUT_MOUSE_BUTTON_MIDDLE);
    event->value0 = delta_x;
    event->value1 = delta_y;
    event->value2 = 0;
}

static inline int vibe_input_event_is_key(const vibe_input_event_t* event)
{
    return event
        && event->device_id == VIBE_INPUT_DEVICE_KEYBOARD
        && event->type == VIBE_INPUT_EVENT_KEY;
}

static inline int vibe_input_event_is_mouse_packet(const vibe_input_event_t* event)
{
    return event
        && event->device_id == VIBE_INPUT_DEVICE_MOUSE
        && event->type == VIBE_INPUT_EVENT_MOUSE_PACKET;
}

static inline int vibe_input_status_has_overflow(const vibe_input_status_t* status)
{
    return status && status->dropped_events != 0;
}

static inline int vibe_input_status_key_is_down(
    const vibe_input_status_t* status,
    unsigned long code)
{
    return status
        && code < 256
        && (status->keyboard_state[code >> 5] & (1ul << (code & 31))) != 0;
}

enum {
    VIBE_GAMEPLAY_FLAG_MENU_ACTIVE = 0x01u,
    VIBE_GAMEPLAY_FLAG_AUTOMAP_ACTIVE = 0x02u,
    VIBE_GAMEPLAY_FLAG_PAUSED = 0x04u,
    VIBE_GAMEPLAY_FLAG_SINGLETICS = 0x08u,
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
    VIBE_PLAYABLE_SEEN_TURN_CMD = 0x0100u,
};

enum {
    VIBE_DOOM_SAVEACTION_STATUS = 0x10000000u,
    VIBE_DOOM_SAVEACTION_SENDSAVE = 0x0001u,
    VIBE_DOOM_SAVEACTION_MENUACTIVE = 0x0002u,
    VIBE_DOOM_SAVEACTION_DESCRIPTION = 0x0004u,
    VIBE_DOOM_SAVEACTION_SAVE_REQUESTED = 0x0008u,
    VIBE_DOOM_SAVEACTION_SAVE_DONE = 0x0010u,
    VIBE_DOOM_SAVEACTION_LOAD_REQUESTED = 0x0020u,
    VIBE_DOOM_SAVEACTION_LOAD_DONE = 0x0040u,
    VIBE_DOOM_SAVEACTION_STREAM = 0x0080u,
    VIBE_DOOM_SAVEACTION_GAMEACTION_SHIFT = 8,
    VIBE_DOOM_SAVEACTION_SLOT_SHIFT = 16,
};

enum {
    VIBE_DOOM_SAVELOAD_STATUS = 0x20000000u,
    VIBE_DOOM_SAVELOAD_OPEN = 0x0001u,
    VIBE_DOOM_SAVELOAD_READ = 0x0002u,
    VIBE_DOOM_SAVELOAD_WRITE = 0x0004u,
    VIBE_DOOM_SAVELOAD_CLOSE = 0x0008u,
    VIBE_DOOM_SAVELOAD_SLOT_SHIFT = 16,
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
    unsigned long capabilities;
    unsigned long present_format;
    unsigned long max_present_width;
    unsigned long max_present_height;
} vibe_fb_info_t;

enum {
    VIBE_FB_BACKEND_MODE13 = 1,
    VIBE_FB_BACKEND_LFB_XRGB8888 = 2,
};

enum {
    VIBE_FB_POLICY_MODE13 = 1,
    VIBE_FB_POLICY_ASPECT = 2,
    VIBE_FB_POLICY_SQUARE = 3,
};

enum {
    VIBE_FB_CAP_PRESENT_INDEXED = 0x00000001u,
    VIBE_FB_CAP_PRESENT_RGB_PALETTE = 0x00000002u,
    VIBE_FB_CAP_XRGB8888_LFB = 0x00000004u,
    VIBE_FB_CAP_MODE13_SHADOW = 0x00000008u,
    VIBE_FB_CAP_DIRTY_SOURCE_RECT = 0x00000010u,
};

enum {
    VIBE_FB_FORMAT_INDEX8_RGB24 = 1,
};

typedef struct vibe_present_indexed {
    const void* frame;
    const void* palette;
    unsigned long width;
    unsigned long height;
} vibe_present_indexed_t;

int vibe_syscall3(unsigned int number, unsigned long arg0, unsigned long arg1, unsigned long arg2);
int vibe_clock_gettime(unsigned long clock_id, vibe_clock_time_t* out);
int vibe_listdir(const char* path, vibe_dirent_t* entries, unsigned long max_entries);
unsigned long vibe_monotonic_ticks(void);
unsigned long vibe_monotonic_milliseconds(void);

/*
 * Doom port syscall ABI:
 * - Success returns a non-negative int-sized value.
 * - Failure returns -errno when the kernel can classify the error.
 * - Legacy kernel paths may still return -1; libc maps those through the
 *   operation-specific fallback errno.
 * - File flags use the O_* constants from fcntl.h, including O_ACCMODE and
 *   O_CLOEXEC.
 * - ftruncate resizes writable root-level FAT16 files by descriptor. Growth
 *   zero-fills new bytes, and shrink frees tail clusters through the FAT layer.
 * - VIBE_SYS_CLOCK_GETTIME exposes a reusable monotonic PIT-derived clock. It
 *   reports 100 Hz ticks and milliseconds only; it is not an RTC or wall clock.
 * - VIBE_SYS_LISTDIR lists cached FAT16 root entries into fixed
 *   `vibe_dirent_t` records. It is readonly and root-only for now; names are
 *   normalized 8.3 display names, and `stat("/")` reports readonly directory
 *   metadata.
 * - VIBE_SYS_POLL_INPUT drains one reusable keyboard/mouse event at a time.
 *   VIBE_SYS_INPUT_STATUS reports queue capacity/depth, overflow counters,
 *   keyboard state, and mouse state without consuming queued input.
 * - sbrk grows or shrinks the process heap. Shrink trims whole released pages
 *   from the process page tables and heap-validation bitmap.
 * - mmap is currently anonymous/private and brk-backed; munmap validates the
 *   mapping range, tail munmap moves brk back, and valid non-tail munmap
 *   punches validation holes without creating reusable VM objects.
 * - execv passes a bounded argv vector to the process handoff. Table entries
 *   cover Doom/probe images; other root-level FAT16 .ELF names use reusable
 *   probe-class slots. File descriptors inherit across exec unless opened with
 *   O_CLOEXEC. VIBE_EXEC_* exposes the current path and argv bounds to generic
 *   userland programs. execve accepts NULL or empty envp only; the kernel seeds
 *   an empty envp terminator for every launched image until environment copying
 *   exists.
 * - getpid returns the active static process id.
 * - fork returns ENOSYS until address-space cloning exists. wait/waitpid scan
 *   parent-PID metadata, reap EXITED/FAULTED children, support WNOHANG, and
 *   return ENOSYS for blocking waits on live children until a sleep queue
 *   exists.
 */

#endif
