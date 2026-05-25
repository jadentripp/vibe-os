#ifndef VIBE_OS_USER_ABI_H
#define VIBE_OS_USER_ABI_H

enum {
    VIBE_OS_ABI_VERSION = 1,
    VIBE_SYSCALL_VECTOR = 0x80,
    VIBE_SYSCALL_MAX_ARGS = 3,
    VIBE_SYSCALL_ERROR_NEGATIVE_ERRNO = 1,
    VIBE_PROCESS_FAULT_EXIT_STATUS_BASE = 0x80,
};

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
    VIBE_SYS_DUP = 32,
    VIBE_SYS_DUP2 = 33,
    VIBE_SYS_DUP3 = 34,
    VIBE_SYS_FCNTL = 35,
    VIBE_SYS_PROCESS_STATUS = 36,
    VIBE_SYS_YIELD = 37,
    VIBE_SYS_SLEEP_TICKS = 38,
    VIBE_SYS_INPUT_DEVICE_STATUS = 39,
    VIBE_SYS_GETPPID = 40,
};

enum {
    VIBE_EXEC_PATH_MAX = 16,
    VIBE_EXEC_ARG_MAX = 8,
    VIBE_EXEC_ARG_STR_MAX = 64,
    VIBE_EXEC_ENV_MAX = 8,
    VIBE_EXEC_ENV_STR_MAX = 64,
    VIBE_EXEC_STACK_ABI_VERSION = 1,
    VIBE_EXEC_STACK_ALIGN = 16,
    VIBE_EXEC_AUX_AT_NULL = 0,
    VIBE_EXEC_AUX_AT_PAGESZ = 6,
    VIBE_EXEC_AUX_AT_ENTRY = 9,
    VIBE_EXEC_AUXV_PAIR_COUNT = 3,
    VIBE_EXEC_ARGV_SOURCE_DEFAULT = 1,
    VIBE_EXEC_ARGV_SOURCE_USER = 2,
    VIBE_EXEC_ENVP_SOURCE_EMPTY = 1,
    VIBE_EXEC_ENVP_SOURCE_USER = 2,
    VIBE_EXEC_RESOLVE_NONE = 0,
    VIBE_EXEC_RESOLVE_TABLE = 1,
    VIBE_EXEC_RESOLVE_GENERIC_ROOT83 = 2,
};

enum {
    VIBE_USER_START_FLAG_ARGV_BOUNDED = 0x00000001u,
    VIBE_USER_START_FLAG_ENVP_BOUNDED = 0x00000002u,
    VIBE_USER_START_FLAG_AUXV_PRESENT = 0x00000004u,
    VIBE_USER_START_FLAG_STACK_ALIGNED = 0x00000008u,
    VIBE_USER_START_REQUIRED_FLAGS = VIBE_USER_START_FLAG_ARGV_BOUNDED
        | VIBE_USER_START_FLAG_ENVP_BOUNDED
        | VIBE_USER_START_FLAG_AUXV_PRESENT
        | VIBE_USER_START_FLAG_STACK_ALIGNED,
    VIBE_USER_START_FAIL_STATUS = VIBE_PROCESS_FAULT_EXIT_STATUS_BASE | 22u,
    VIBE_USER_DEFAULT_PAGE_SIZE = 4096u,
};

enum {
    VIBE_PROCESS_STATUS_SELF = 0,
    VIBE_PROCESS_STATUS_ABI_VERSION = 1,
    VIBE_PROCESS_STATUS_BYTES = 64,
};

enum {
    VIBE_PROCESS_STATE_UNUSED = 0,
    VIBE_PROCESS_STATE_READY = 1,
    VIBE_PROCESS_STATE_RUNNING = 2,
    VIBE_PROCESS_STATE_EXITED = 3,
    VIBE_PROCESS_STATE_FAULTED = 4,
    VIBE_PROCESS_STATE_SLEEPING = 5,
    VIBE_PROCESS_STATE_BLOCKED = 6,
};

enum {
    VIBE_PROCESS_KIND_NONE = 0,
    VIBE_PROCESS_KIND_PROBE = 1,
    VIBE_PROCESS_KIND_PAYLOAD_PRIMARY = 2,
    VIBE_PROCESS_KIND_PREEMPT_PROBE = 3,
    VIBE_PROCESS_KIND_GENERIC = 4,
    VIBE_PROCESS_KIND_PAYLOAD_SECONDARY = 5,
};

typedef struct vibe_process_status {
    unsigned long abi_version;
    unsigned long status_bytes;
    unsigned long pid;
    unsigned long parent_pid;
    unsigned long state;
    unsigned long kind;
    unsigned long exit_status;
    unsigned long ticks;
    unsigned long runs;
    unsigned long switches;
    unsigned long quantum_ticks;
    unsigned long entry;
    unsigned long stack_top;
    unsigned long brk;
    unsigned long scheduler_ticks;
    unsigned long scheduler_rounds;
} vibe_process_status_t;

enum {
    VIBE_CLOCK_MONOTONIC = 1,
    VIBE_CLOCK_MONOTONIC_HZ = 100,
    VIBE_CLOCK_FLAG_KERNEL_OWNED = 0x00000001u,
    VIBE_CLOCK_FLAG_HPET_BACKED = 0x00000002u,
};

typedef struct vibe_clock_time {
    unsigned long ticks;
    unsigned long frequency_hz;
    unsigned long milliseconds;
    unsigned long flags;
} vibe_clock_time_t;

enum {
    VIBE_HEAP_CAP_SBRK_GROW = 0x00000001u,
    VIBE_HEAP_CAP_SBRK_SHRINK = 0x00000002u,
};

enum {
    VIBE_VM_CAP_ANON_PRIVATE = 0x00000001u,
    VIBE_VM_CAP_BRK_BACKED = 0x00000002u,
    VIBE_VM_CAP_TAIL_MUNMAP_RECLAIM = 0x00000004u,
    VIBE_VM_CAP_NONTAIL_MUNMAP_HOLES = 0x00000008u,
    VIBE_VM_CAP_FILE_PRIVATE_COPY = 0x00010000u,
};

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
    VIBE_AUDIO_FD = 0x00004155u,
    VIBE_IOCTL_AUDIO_DEVICE_INFO = 0x00004101u,
    VIBE_IOCTL_AUDIO_PCM_RING_INFO = 0x00004102u,
    VIBE_IOCTL_AUDIO_STREAM_INFO = 0x00004103u,
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
    /* Reusable OS audio commands: device lifecycle, mixer voice control,
       PCM ring diagnostics, and pull-stream service state. */
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
    VIBE_AUDIO_STREAM_INFO = 11,
    VIBE_AUDIO_PCM_WRITE = 12,
    VIBE_AUDIO_PCM_WRITE_DESC = 13,
    VIBE_AUDIO_PCM_OPEN = 14,
    VIBE_AUDIO_PCM_DRAIN = 15,
    VIBE_AUDIO_PCM_CLOSE = 16,
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
    VIBE_AUDIO_STREAM_WRITE = VIBE_AUDIO_PCM_WRITE,
    VIBE_AUDIO_STREAM_OPEN = VIBE_AUDIO_PCM_OPEN,
    VIBE_AUDIO_STREAM_DRAIN = VIBE_AUDIO_PCM_DRAIN,
    VIBE_AUDIO_STREAM_CLOSE = VIBE_AUDIO_PCM_CLOSE,
};

enum {
    VIBE_AUDIO_MUSIC_STREAM_NONE = 0,
    VIBE_AUDIO_MUSIC_STREAM_PUSH = 1,
    VIBE_AUDIO_MUSIC_STREAM_PULL = 2,
    VIBE_AUDIO_STREAM_NONE = VIBE_AUDIO_MUSIC_STREAM_NONE,
    VIBE_AUDIO_STREAM_PUSH = VIBE_AUDIO_MUSIC_STREAM_PUSH,
    VIBE_AUDIO_STREAM_PULL = VIBE_AUDIO_MUSIC_STREAM_PULL,
};

enum {
    VIBE_AUDIO_PCM_LIFECYCLE_IDLE = 0,
    VIBE_AUDIO_PCM_LIFECYCLE_OPEN = 1,
    VIBE_AUDIO_PCM_LIFECYCLE_WRITTEN = 2,
    VIBE_AUDIO_PCM_LIFECYCLE_DRAINING = 3,
    VIBE_AUDIO_PCM_LIFECYCLE_CLOSED = 4,
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

typedef struct vibe_audio_pcm_desc {
    const unsigned char* samples;
    unsigned long length;
    unsigned long sample_rate;
    unsigned long channels;
    unsigned long format;
    unsigned long flags;
    unsigned long reserved0;
    unsigned long reserved1;
    unsigned long reserved2;
    unsigned long reserved3;
    unsigned long reserved4;
    unsigned long reserved5;
    unsigned long reserved6;
    unsigned long reserved7;
    unsigned long reserved8;
    unsigned long reserved9;
} vibe_audio_pcm_desc_t;

enum {
    VIBE_AUDIO_PCM_DESC_BYTES = 64,
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

static inline void vibe_audio_pcm_desc_init(
    vibe_audio_pcm_desc_t* desc,
    const unsigned char* samples,
    unsigned long length,
    unsigned long sample_rate,
    unsigned long channels,
    unsigned long format)
{
    if (!desc)
        return;

    desc->samples = samples;
    desc->length = length;
    desc->sample_rate = sample_rate;
    desc->channels = channels;
    desc->format = format;
    desc->flags = 0;
    desc->reserved0 = 0;
    desc->reserved1 = 0;
    desc->reserved2 = 0;
    desc->reserved3 = 0;
    desc->reserved4 = 0;
    desc->reserved5 = 0;
    desc->reserved6 = 0;
    desc->reserved7 = 0;
    desc->reserved8 = 0;
    desc->reserved9 = 0;
}

typedef struct vibe_audio_device_info {
    /* Device-level capability record for callers before assuming an SB16
       backing device, PCM ring, mixer voices, or pull streams. */
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
    /* PCM-ring geometry and safety counters. This is the reusable device
       stream buffer contract, not an application asset or SFX descriptor. */
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

typedef struct vibe_audio_stream_info {
    /* Pull-stream service snapshot for hardware-paced refill loops. The stream
       may carry music or any caller-owned PCM; the ABI is app-neutral. */
    unsigned long stream_mode;
    unsigned long flags;
    unsigned long handle;
    unsigned long pull_request_count;
    unsigned long pull_refill_count;
    unsigned long pending_pull_requests;
    unsigned long queued_bytes;
    unsigned long low_water_bytes;
    unsigned long active_streams;
    unsigned long underrun_count;
    unsigned long drop_count;
    unsigned long position_bytes;
} vibe_audio_stream_info_t;

enum {
    VIBE_AUDIO_STREAM_INFO_BYTES = 48,
    VIBE_AUDIO_STREAM_FLAG_PULL = 0x00000001u,
    VIBE_AUDIO_STREAM_FLAG_REFILL_PENDING = 0x00000002u,
    VIBE_AUDIO_STREAM_FLAG_ACTIVE = 0x00000004u,
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

static inline int vibe_audio_stream_uses_pull(const vibe_audio_stream_info_t* info)
{
    return info
        && info->stream_mode == VIBE_AUDIO_STREAM_PULL
        && (info->flags & VIBE_AUDIO_STREAM_FLAG_PULL) != 0;
}

static inline int vibe_audio_stream_matches_handle(
    const vibe_audio_stream_info_t* info,
    unsigned long handle)
{
    return info && info->handle == handle;
}

static inline int vibe_audio_stream_refills_are_ordered(const vibe_audio_stream_info_t* info)
{
    unsigned long pending;

    if (!info || info->pull_refill_count > info->pull_request_count)
        return 0;

    pending = info->pull_request_count - info->pull_refill_count;
    return info->pending_pull_requests == pending;
}

static inline int vibe_audio_stream_needs_refill(const vibe_audio_stream_info_t* info)
{
    return info
        && vibe_audio_stream_refills_are_ordered(info)
        && info->pending_pull_requests != 0
        && (info->flags & VIBE_AUDIO_STREAM_FLAG_REFILL_PENDING) != 0;
}

static inline int vibe_audio_stream_has_new_refill_request(
    const vibe_audio_stream_info_t* info,
    unsigned long last_request_count)
{
    return vibe_audio_stream_uses_pull(info)
        && vibe_audio_stream_needs_refill(info)
        && info->pull_request_count > last_request_count;
}

enum {
    VIBE_AUDIO_FLAG_LOOP = 0x00000001u,
    VIBE_AUDIO_FLAG_MUSIC = 0x00000002u,
    VIBE_AUDIO_FLAG_ASSET_SFX = 0x00000004u,
    VIBE_AUDIO_FLAG_STREAM_FINAL = 0x00000008u,
    VIBE_AUDIO_FLAG_STREAM = 0x00000010u,
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
    VIBE_INPUT_ABI_VERSION = 2,
    VIBE_INPUT_EVENT_QUEUE_CAPACITY = 64,
    VIBE_INPUT_EVENT_QUEUE_USABLE_CAPACITY = VIBE_INPUT_EVENT_QUEUE_CAPACITY - 1,
    VIBE_INPUT_EVENT_VALUE_COUNT = 3,
    VIBE_INPUT_KEY_STATE_BITS = 256,
};

enum {
    VIBE_INPUT_QUEUE_OVERFLOW_DROP_OLDEST = 1,
};

enum {
    VIBE_INPUT_DEVICE_STATUS_UNKNOWN = 0,
    VIBE_INPUT_DEVICE_STATUS_READY = 1,
    VIBE_INPUT_DEVICE_STATUS_ERROR = 2,
};

enum {
    VIBE_INPUT_KEY_RELEASED = 0,
    VIBE_INPUT_KEY_PRESSED = 1,
};

enum {
    VIBE_INPUT_KEY_PS2_SET1_SCANCODE_MASK = 0x7fu,
    VIBE_INPUT_KEY_PS2_SET1_EXTENDED = 0x80u,
};

enum {
    VIBE_INPUT_MOUSE_BUTTON_LEFT = 0x01u,
    VIBE_INPUT_MOUSE_BUTTON_RIGHT = 0x02u,
    VIBE_INPUT_MOUSE_BUTTON_MIDDLE = 0x04u,
    VIBE_INPUT_MOUSE_BUTTON_MASK = 0x07u,
    VIBE_INPUT_MOUSE_AXIS_X = 0,
    VIBE_INPUT_MOUSE_AXIS_Y = 1,
};

enum {
    VIBE_INPUT_CAP_KEYBOARD = 0x00000001u,
    VIBE_INPUT_CAP_MOUSE = 0x00000002u,
    VIBE_INPUT_CAP_POLL_EVENT = 0x00000004u,
    VIBE_INPUT_CAP_STATUS = 0x00000008u,
    VIBE_INPUT_CAP_DEVICE_STATUS = 0x00000010u,
};

enum {
    VIBE_INPUT_DEVICE_CAP_KEYS = 0x00000001u,
    VIBE_INPUT_DEVICE_CAP_RELATIVE_POINTER = 0x00000002u,
    VIBE_INPUT_DEVICE_CAP_BUTTONS = 0x00000004u,
    VIBE_INPUT_DEVICE_CAP_STATE_SNAPSHOT = 0x00000008u,
};

enum {
    VIBE_INPUT_MOD_SHIFT = 0x00000001u,
    VIBE_INPUT_MOD_CTRL = 0x00000002u,
    VIBE_INPUT_MOD_ALT = 0x00000004u,
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
    unsigned long status_bytes;
    unsigned long queue_usable_capacity;
    unsigned long overflow_policy;
    unsigned long keyboard_status;
    unsigned long mouse_status;
} vibe_input_status_t;

enum {
    VIBE_INPUT_STATUS_BYTES = 132,
};

typedef struct vibe_input_device_status {
    unsigned long abi_version;
    unsigned long status_bytes;
    unsigned long device_id;
    unsigned long status;
    unsigned long capabilities;
    unsigned long irq_count;
    unsigned long event_count;
    unsigned long polled_events;
    unsigned long dropped_events;
    unsigned long last_timestamp;
    unsigned long last_event_type;
    unsigned long last_code;
    unsigned long active_state;
    long axis_x_total;
    long axis_y_total;
    unsigned long reserved0;
} vibe_input_device_status_t;

enum {
    VIBE_INPUT_DEVICE_STATUS_BYTES = 64,
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
    event->code = buttons & VIBE_INPUT_MOUSE_BUTTON_MASK;
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

static inline unsigned long vibe_input_key_code(const vibe_input_event_t* event)
{
    return vibe_input_event_is_key(event) ? event->code : 0;
}

static inline unsigned long vibe_input_ps2_set1_key_code(
    unsigned long scancode,
    int extended)
{
    return (scancode & VIBE_INPUT_KEY_PS2_SET1_SCANCODE_MASK)
        | (extended ? VIBE_INPUT_KEY_PS2_SET1_EXTENDED : 0);
}

static inline unsigned long vibe_input_key_ps2_set1_scancode(const vibe_input_event_t* event)
{
    return vibe_input_key_code(event) & VIBE_INPUT_KEY_PS2_SET1_SCANCODE_MASK;
}

static inline int vibe_input_key_ps2_set1_is_extended(const vibe_input_event_t* event)
{
    return (vibe_input_key_code(event) & VIBE_INPUT_KEY_PS2_SET1_EXTENDED) != 0;
}

static inline int vibe_input_key_is_pressed(const vibe_input_event_t* event)
{
    return vibe_input_event_is_key(event)
        && event->value0 == VIBE_INPUT_KEY_PRESSED;
}

static inline int vibe_input_key_is_released(const vibe_input_event_t* event)
{
    return vibe_input_event_is_key(event)
        && event->value0 == VIBE_INPUT_KEY_RELEASED;
}

static inline int vibe_input_mouse_button_is_supported(unsigned long button)
{
    return button
        && (button & ~VIBE_INPUT_MOUSE_BUTTON_MASK) == 0;
}

static inline unsigned long vibe_input_mouse_buttons(const vibe_input_event_t* event)
{
    if (!vibe_input_event_is_mouse_packet(event))
        return 0;

    return event->code & VIBE_INPUT_MOUSE_BUTTON_MASK;
}

static inline int vibe_input_mouse_button_is_down(
    const vibe_input_event_t* event,
    unsigned long button)
{
    return vibe_input_mouse_button_is_supported(button)
        && (vibe_input_mouse_buttons(event) & button) == button;
}

static inline int vibe_input_mouse_has_buttons(const vibe_input_event_t* event)
{
    return vibe_input_mouse_buttons(event) != 0;
}

static inline long vibe_input_mouse_delta_x(const vibe_input_event_t* event)
{
    return vibe_input_event_is_mouse_packet(event) ? event->value0 : 0;
}

static inline long vibe_input_mouse_delta_y(const vibe_input_event_t* event)
{
    return vibe_input_event_is_mouse_packet(event) ? event->value1 : 0;
}

static inline long vibe_input_mouse_delta(const vibe_input_event_t* event, unsigned long axis)
{
    if (axis == VIBE_INPUT_MOUSE_AXIS_X)
        return vibe_input_mouse_delta_x(event);
    if (axis == VIBE_INPUT_MOUSE_AXIS_Y)
        return vibe_input_mouse_delta_y(event);
    return 0;
}

static inline int vibe_input_mouse_has_motion(const vibe_input_event_t* event)
{
    return vibe_input_event_is_mouse_packet(event)
        && (event->value0 != 0 || event->value1 != 0);
}

static inline int vibe_input_status_abi_is_current(const vibe_input_status_t* status)
{
    return status
        && status->abi_version == VIBE_INPUT_ABI_VERSION
        && status->event_bytes == VIBE_INPUT_EVENT_BYTES
        && status->queue_capacity == VIBE_INPUT_EVENT_QUEUE_CAPACITY
        && status->status_bytes == VIBE_INPUT_STATUS_BYTES
        && status->queue_usable_capacity == VIBE_INPUT_EVENT_QUEUE_USABLE_CAPACITY
        && status->overflow_policy == VIBE_INPUT_QUEUE_OVERFLOW_DROP_OLDEST;
}

static inline int vibe_input_status_has_overflow(const vibe_input_status_t* status)
{
    return status && status->dropped_events != 0;
}

static inline int vibe_input_status_has_capability(
    const vibe_input_status_t* status,
    unsigned long capability)
{
    return status && (status->capabilities & capability) == capability;
}

static inline int vibe_input_device_status_is_ready(unsigned long device_status)
{
    return device_status == VIBE_INPUT_DEVICE_STATUS_READY;
}

static inline int vibe_input_device_status_abi_is_current(const vibe_input_device_status_t* status)
{
    return status
        && status->abi_version == VIBE_INPUT_ABI_VERSION
        && status->status_bytes == VIBE_INPUT_DEVICE_STATUS_BYTES
        && (status->device_id == VIBE_INPUT_DEVICE_KEYBOARD
            || status->device_id == VIBE_INPUT_DEVICE_MOUSE);
}

static inline int vibe_input_device_record_is_ready(const vibe_input_device_status_t* status)
{
    return vibe_input_device_status_abi_is_current(status)
        && status->status == VIBE_INPUT_DEVICE_STATUS_READY;
}

static inline int vibe_input_device_status_has_capability(
    const vibe_input_device_status_t* status,
    unsigned long capability)
{
    return vibe_input_device_status_abi_is_current(status)
        && (status->capabilities & capability) == capability;
}

static inline int vibe_input_device_status_counters_are_consistent(
    const vibe_input_device_status_t* status)
{
    return vibe_input_device_status_abi_is_current(status)
        && status->polled_events <= status->event_count
        && status->dropped_events <= status->event_count;
}

static inline int vibe_input_device_status_keyboard_modifiers(
    const vibe_input_device_status_t* status)
{
    if (!vibe_input_device_status_abi_is_current(status)
        || status->device_id != VIBE_INPUT_DEVICE_KEYBOARD)
        return 0;
    return (int)(status->active_state & (VIBE_INPUT_MOD_SHIFT | VIBE_INPUT_MOD_CTRL | VIBE_INPUT_MOD_ALT));
}

static inline unsigned long vibe_input_device_status_mouse_buttons(
    const vibe_input_device_status_t* status)
{
    if (!vibe_input_device_status_abi_is_current(status)
        || status->device_id != VIBE_INPUT_DEVICE_MOUSE)
        return 0;
    return status->active_state & VIBE_INPUT_MOUSE_BUTTON_MASK;
}

static inline int vibe_input_status_queue_is_empty(const vibe_input_status_t* status)
{
    return status && status->queued_events == 0;
}

static inline unsigned long vibe_input_status_queued_events(const vibe_input_status_t* status)
{
    return status ? status->queued_events : 0;
}

static inline unsigned long vibe_input_status_usable_capacity(const vibe_input_status_t* status)
{
    if (!status || !status->queue_usable_capacity)
        return VIBE_INPUT_EVENT_QUEUE_USABLE_CAPACITY;
    return status->queue_usable_capacity;
}

static inline unsigned long vibe_input_status_available_events(const vibe_input_status_t* status)
{
    unsigned long usable;

    if (!status)
        return 0;

    usable = vibe_input_status_usable_capacity(status);
    if (status->queued_events >= usable)
        return 0;
    return usable - status->queued_events;
}

static inline int vibe_input_status_queue_is_full(const vibe_input_status_t* status)
{
    return status
        && status->queued_events >= vibe_input_status_usable_capacity(status);
}

static inline int vibe_input_status_uses_drop_oldest(const vibe_input_status_t* status)
{
    return status
        && status->overflow_policy == VIBE_INPUT_QUEUE_OVERFLOW_DROP_OLDEST;
}

static inline int vibe_input_status_keyboard_is_ready(const vibe_input_status_t* status)
{
    return status && vibe_input_device_status_is_ready(status->keyboard_status);
}

static inline int vibe_input_status_mouse_is_ready(const vibe_input_status_t* status)
{
    return status && vibe_input_device_status_is_ready(status->mouse_status);
}

static inline int vibe_input_status_counters_are_consistent(const vibe_input_status_t* status)
{
    unsigned long usable;

    if (!vibe_input_status_abi_is_current(status))
        return 0;

    usable = vibe_input_status_usable_capacity(status);
    if (usable > status->queue_capacity)
        return 0;
    if (status->queued_events > usable)
        return 0;
    return status->total_events
        == status->queued_events + status->polled_events + status->dropped_events;
}

static inline int vibe_input_status_key_is_down(
    const vibe_input_status_t* status,
    unsigned long code)
{
    return status
        && code < VIBE_INPUT_KEY_STATE_BITS
        && (status->keyboard_state[code >> 5] & (1ul << (code & 31))) != 0;
}

static inline int vibe_input_status_ps2_set1_key_is_down(
    const vibe_input_status_t* status,
    unsigned long scancode,
    int extended)
{
    return vibe_input_status_key_is_down(
        status,
        vibe_input_ps2_set1_key_code(scancode, extended));
}

static inline int vibe_input_status_shift_is_down(const vibe_input_status_t* status)
{
    return vibe_input_status_ps2_set1_key_is_down(status, 0x2a, 0)
        || vibe_input_status_ps2_set1_key_is_down(status, 0x36, 0);
}

static inline int vibe_input_status_ctrl_is_down(const vibe_input_status_t* status)
{
    return vibe_input_status_ps2_set1_key_is_down(status, 0x1d, 0)
        || vibe_input_status_ps2_set1_key_is_down(status, 0x1d, 1);
}

static inline int vibe_input_status_alt_is_down(const vibe_input_status_t* status)
{
    return vibe_input_status_ps2_set1_key_is_down(status, 0x38, 0)
        || vibe_input_status_ps2_set1_key_is_down(status, 0x38, 1);
}

static inline unsigned long vibe_input_status_keyboard_modifiers(const vibe_input_status_t* status)
{
    unsigned long modifiers = 0;

    if (vibe_input_status_shift_is_down(status))
        modifiers |= VIBE_INPUT_MOD_SHIFT;
    if (vibe_input_status_ctrl_is_down(status))
        modifiers |= VIBE_INPUT_MOD_CTRL;
    if (vibe_input_status_alt_is_down(status))
        modifiers |= VIBE_INPUT_MOD_ALT;
    return modifiers;
}

static inline unsigned long vibe_input_status_mouse_buttons(const vibe_input_status_t* status)
{
    return status ? status->mouse_buttons & VIBE_INPUT_MOUSE_BUTTON_MASK : 0;
}

static inline int vibe_input_status_mouse_button_is_down(
    const vibe_input_status_t* status,
    unsigned long button)
{
    return vibe_input_mouse_button_is_supported(button)
        && (vibe_input_status_mouse_buttons(status) & button) == button;
}

static inline int vibe_input_status_mouse_has_buttons(const vibe_input_status_t* status)
{
    return vibe_input_status_mouse_buttons(status) != 0;
}

static inline long vibe_input_status_mouse_delta_x(const vibe_input_status_t* status)
{
    return status ? status->mouse_delta_x_total : 0;
}

static inline long vibe_input_status_mouse_delta_y(const vibe_input_status_t* status)
{
    return status ? status->mouse_delta_y_total : 0;
}

static inline long vibe_input_status_mouse_delta(
    const vibe_input_status_t* status,
    unsigned long axis)
{
    if (axis == VIBE_INPUT_MOUSE_AXIS_X)
        return vibe_input_status_mouse_delta_x(status);
    if (axis == VIBE_INPUT_MOUSE_AXIS_Y)
        return vibe_input_status_mouse_delta_y(status);
    return 0;
}

static inline int vibe_input_status_mouse_has_motion(const vibe_input_status_t* status)
{
    return status
        && (status->mouse_delta_x_total != 0 || status->mouse_delta_y_total != 0);
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
    VIBE_PAYLOAD_PERSIST_ACTION_STATUS = 0x10000000u,
    VIBE_PAYLOAD_PERSIST_ACTION_SEND = 0x0001u,
    VIBE_PAYLOAD_PERSIST_ACTION_UI_ACTIVE = 0x0002u,
    VIBE_PAYLOAD_PERSIST_ACTION_DESCRIPTION = 0x0004u,
    VIBE_PAYLOAD_PERSIST_ACTION_WRITE_REQUESTED = 0x0008u,
    VIBE_PAYLOAD_PERSIST_ACTION_WRITE_DONE = 0x0010u,
    VIBE_PAYLOAD_PERSIST_ACTION_READ_REQUESTED = 0x0020u,
    VIBE_PAYLOAD_PERSIST_ACTION_READ_DONE = 0x0040u,
    VIBE_PAYLOAD_PERSIST_ACTION_STREAM = 0x0080u,
    VIBE_PAYLOAD_PERSIST_ACTION_OP_SHIFT = 8,
    VIBE_PAYLOAD_PERSIST_ACTION_SLOT_SHIFT = 16,
};

enum {
    VIBE_PAYLOAD_PERSIST_IO_STATUS = 0x20000000u,
    VIBE_PAYLOAD_PERSIST_IO_OPEN = 0x0001u,
    VIBE_PAYLOAD_PERSIST_IO_READ = 0x0002u,
    VIBE_PAYLOAD_PERSIST_IO_WRITE = 0x0004u,
    VIBE_PAYLOAD_PERSIST_IO_CLOSE = 0x0008u,
    VIBE_PAYLOAD_PERSIST_IO_SLOT_SHIFT = 16,
};

enum {
    /* Compatibility aliases for existing save/load payload instrumentation. */
    VIBE_PAYLOAD_SAVEACTION_STATUS = VIBE_PAYLOAD_PERSIST_ACTION_STATUS,
    VIBE_PAYLOAD_SAVEACTION_SENDSAVE = VIBE_PAYLOAD_PERSIST_ACTION_SEND,
    VIBE_PAYLOAD_SAVEACTION_MENUACTIVE = VIBE_PAYLOAD_PERSIST_ACTION_UI_ACTIVE,
    VIBE_PAYLOAD_SAVEACTION_DESCRIPTION = VIBE_PAYLOAD_PERSIST_ACTION_DESCRIPTION,
    VIBE_PAYLOAD_SAVEACTION_SAVE_REQUESTED = VIBE_PAYLOAD_PERSIST_ACTION_WRITE_REQUESTED,
    VIBE_PAYLOAD_SAVEACTION_SAVE_DONE = VIBE_PAYLOAD_PERSIST_ACTION_WRITE_DONE,
    VIBE_PAYLOAD_SAVEACTION_LOAD_REQUESTED = VIBE_PAYLOAD_PERSIST_ACTION_READ_REQUESTED,
    VIBE_PAYLOAD_SAVEACTION_LOAD_DONE = VIBE_PAYLOAD_PERSIST_ACTION_READ_DONE,
    VIBE_PAYLOAD_SAVEACTION_STREAM = VIBE_PAYLOAD_PERSIST_ACTION_STREAM,
    VIBE_PAYLOAD_SAVEACTION_GAMEACTION_SHIFT = VIBE_PAYLOAD_PERSIST_ACTION_OP_SHIFT,
    VIBE_PAYLOAD_SAVEACTION_SLOT_SHIFT = VIBE_PAYLOAD_PERSIST_ACTION_SLOT_SHIFT,
    VIBE_PAYLOAD_SAVELOAD_STATUS = VIBE_PAYLOAD_PERSIST_IO_STATUS,
    VIBE_PAYLOAD_SAVELOAD_OPEN = VIBE_PAYLOAD_PERSIST_IO_OPEN,
    VIBE_PAYLOAD_SAVELOAD_READ = VIBE_PAYLOAD_PERSIST_IO_READ,
    VIBE_PAYLOAD_SAVELOAD_WRITE = VIBE_PAYLOAD_PERSIST_IO_WRITE,
    VIBE_PAYLOAD_SAVELOAD_CLOSE = VIBE_PAYLOAD_PERSIST_IO_CLOSE,
    VIBE_PAYLOAD_SAVELOAD_SLOT_SHIFT = VIBE_PAYLOAD_PERSIST_IO_SLOT_SHIFT,
};

enum {
    VIBE_PAYLOAD_INIT_STATUS = 0x40000000u,
    VIBE_PAYLOAD_INIT_START = 0x0001u,
    VIBE_PAYLOAD_INIT_I_INIT = 0x0002u,
    VIBE_PAYLOAD_INIT_ZONE = 0x0004u,
    VIBE_PAYLOAD_INIT_NETWORK = 0x0008u,
    VIBE_PAYLOAD_INIT_SOUND = 0x0010u,
    VIBE_PAYLOAD_INIT_GRAPHICS = 0x0020u,
    VIBE_PAYLOAD_INIT_PALETTE = 0x0040u,
    VIBE_PAYLOAD_INIT_TIC = 0x0080u,
    VIBE_PAYLOAD_INIT_FRAME = 0x0100u,
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
    VIBE_FB_ABI_VERSION = 1,
    VIBE_FB_PRESENT_SEMANTICS_INDEXED_SOURCE = 1,
};

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
    VIBE_FB_CAP_FIXED_PRESENT_SIZE = 0x00000020u,
    VIBE_FB_CAP_XBGR8888_LFB = 0x00000040u,
};

enum {
    VIBE_FB_FORMAT_INDEX8_RGB24 = 1,
};

enum {
    VIBE_FB_INDEXED_PALETTE_COLORS = 256,
    VIBE_FB_RGB24_PALETTE_ENTRY_BYTES = 3,
    VIBE_FB_RGB24_PALETTE_BYTES = 256 * 3,
};

typedef struct vibe_present_indexed {
    const void* frame;
    const void* palette;
    unsigned long width;
    unsigned long height;
} vibe_present_indexed_t;

static inline void vibe_present_indexed_init(
    vibe_present_indexed_t* present,
    const void* frame,
    const void* palette,
    unsigned long width,
    unsigned long height)
{
    if (!present)
        return;

    present->frame = frame;
    present->palette = palette;
    present->width = width;
    present->height = height;
}

static inline int vibe_fb_info_has_capability(
    const vibe_fb_info_t* info,
    unsigned long capability)
{
    return info && (info->capabilities & capability) == capability;
}

static inline int vibe_fb_info_requires_fixed_present_size(const vibe_fb_info_t* info)
{
    return vibe_fb_info_has_capability(info, VIBE_FB_CAP_FIXED_PRESENT_SIZE);
}

static inline int vibe_fb_info_supports_indexed_rgb24(const vibe_fb_info_t* info)
{
    return info
        && vibe_fb_info_has_capability(info, VIBE_FB_CAP_PRESENT_INDEXED)
        && vibe_fb_info_has_capability(info, VIBE_FB_CAP_PRESENT_RGB_PALETTE)
        && info->present_format == VIBE_FB_FORMAT_INDEX8_RGB24;
}

static inline unsigned long vibe_fb_info_present_frame_bytes(const vibe_fb_info_t* info)
{
    if (!info || !info->max_present_width || !info->max_present_height)
        return 0;
    if (info->max_present_width > ~0ul / info->max_present_height)
        return 0;
    return info->max_present_width * info->max_present_height;
}

static inline unsigned long vibe_fb_info_present_palette_bytes(const vibe_fb_info_t* info)
{
    return vibe_fb_info_supports_indexed_rgb24(info)
        ? VIBE_FB_RGB24_PALETTE_BYTES
        : (info ? info->palette_bytes : 0);
}

static inline unsigned long vibe_fb_info_source_format(const vibe_fb_info_t* info)
{
    return info ? info->present_format : 0;
}

static inline unsigned long vibe_fb_info_source_width(const vibe_fb_info_t* info)
{
    return info ? info->max_present_width : 0;
}

static inline unsigned long vibe_fb_info_source_height(const vibe_fb_info_t* info)
{
    return info ? info->max_present_height : 0;
}

static inline unsigned long vibe_fb_info_source_palette_entries(const vibe_fb_info_t* info)
{
    return vibe_fb_info_supports_indexed_rgb24(info) ? VIBE_FB_INDEXED_PALETTE_COLORS : 0;
}

static inline unsigned long vibe_fb_info_source_palette_entry_bytes(const vibe_fb_info_t* info)
{
    return vibe_fb_info_supports_indexed_rgb24(info) ? VIBE_FB_RGB24_PALETTE_ENTRY_BYTES : 0;
}

static inline unsigned long vibe_fb_info_source_aspect_width(const vibe_fb_info_t* info)
{
    return info ? info->max_present_width : 0;
}

static inline unsigned long vibe_fb_info_source_aspect_height(const vibe_fb_info_t* info)
{
    if (!info || !info->scale)
        return 0;
    if (info->policy == VIBE_FB_POLICY_ASPECT)
        return info->view_height / info->scale;
    if (info->policy == VIBE_FB_POLICY_SQUARE || info->policy == VIBE_FB_POLICY_MODE13)
        return info->max_present_height;
    return 0;
}

static inline int vibe_fb_info_present_size_is_accepted(
    const vibe_fb_info_t* info,
    unsigned long width,
    unsigned long height)
{
    if (!info || !width || !height || !vibe_fb_info_supports_indexed_rgb24(info))
        return 0;
    if (vibe_fb_info_requires_fixed_present_size(info)
        && (width != info->max_present_width || height != info->max_present_height))
        return 0;
    if (info->max_present_width && width > info->max_present_width)
        return 0;
    if (info->max_present_height && height > info->max_present_height)
        return 0;
    return 1;
}

static inline unsigned long vibe_present_indexed_frame_bytes(const vibe_present_indexed_t* present)
{
    if (!present || !present->width || !present->height)
        return 0;
    if (present->width > ~0ul / present->height)
        return 0;
    return present->width * present->height;
}

static inline int vibe_fb_info_accepts_present_indexed(
    const vibe_fb_info_t* info,
    const vibe_present_indexed_t* present)
{
    return present
        && present->frame
        && present->palette
        && vibe_present_indexed_frame_bytes(present) != 0
        && vibe_fb_info_present_size_is_accepted(info, present->width, present->height);
}

static inline int vibe_fb_info_dirty_rect_is_empty(const vibe_fb_info_t* info)
{
    return info
        && info->dirty_count == 0
        && info->dirty_x == 0
        && info->dirty_y == 0
        && info->dirty_width == 0
        && info->dirty_height == 0;
}

static inline int vibe_fb_info_dirty_rect_is_bounded(const vibe_fb_info_t* info)
{
    if (!info || !vibe_fb_info_has_capability(info, VIBE_FB_CAP_DIRTY_SOURCE_RECT))
        return 0;
    if (!info->max_present_width || !info->max_present_height)
        return 0;
    if (info->dirty_count == 0)
        return vibe_fb_info_dirty_rect_is_empty(info);
    if (info->dirty_count > vibe_fb_info_present_frame_bytes(info))
        return 0;
    if (info->dirty_width == 0 || info->dirty_height == 0)
        return 0;
    if (info->dirty_x >= info->max_present_width || info->dirty_y >= info->max_present_height)
        return 0;
    if (info->dirty_width > info->max_present_width - info->dirty_x)
        return 0;
    if (info->dirty_height > info->max_present_height - info->dirty_y)
        return 0;
    return 1;
}

int vibe_syscall3(unsigned int number, unsigned long arg0, unsigned long arg1, unsigned long arg2);
int vibe_syscall_errno(int raw_result, int fallback_errno);
int vibe_clock_gettime(unsigned long clock_id, vibe_clock_time_t* out);
int vibe_clock_monotonic(vibe_clock_time_t* out);
unsigned long vibe_clock_ticks_to_milliseconds(unsigned long ticks, unsigned long frequency_hz);
int vibe_listdir(const char* path, vibe_dirent_t* entries, unsigned long max_entries);
int vibe_file_size(const char* path, unsigned long* out_size);
int vibe_file_read_at(
    const char* path,
    unsigned long offset,
    void* buffer,
    unsigned long count,
    unsigned long* out_read);
int vibe_file_write_at(
    const char* path,
    unsigned long offset,
    const void* buffer,
    unsigned long count,
    unsigned long* out_written);
int vibe_file_read_all(const char* path, void* buffer, unsigned long capacity, unsigned long* out_size);
int vibe_audio_device_start(void);
int vibe_audio_device_shutdown(void);
int vibe_audio_mixer_start(unsigned long handle, const vibe_audio_voice_desc_t* desc);
int vibe_audio_mixer_stop(unsigned long handle);
int vibe_audio_mixer_update(unsigned long handle, const vibe_audio_voice_desc_t* desc);
int vibe_audio_mixer_is_playing(unsigned long handle);
int vibe_audio_pcm_buffered_bytes(unsigned long handle);
int vibe_audio_pcm_pull_state(unsigned long handle);
int vibe_audio_device_info(vibe_audio_device_info_t* info);
int vibe_audio_pcm_ring_info(vibe_audio_pcm_ring_info_t* info);
int vibe_audio_stream_info(unsigned long handle, vibe_audio_stream_info_t* info);
int vibe_audio_device_info_ioctl(vibe_audio_device_info_t* info);
int vibe_audio_pcm_ring_info_ioctl(vibe_audio_pcm_ring_info_t* info);
int vibe_audio_stream_info_ioctl(unsigned long handle, vibe_audio_stream_info_t* info);
int vibe_audio_pcm_open(const vibe_audio_pcm_desc_t* format);
int vibe_audio_pcm_drain(unsigned long handle);
int vibe_audio_pcm_close(unsigned long handle);
int vibe_audio_pcm_write(unsigned long handle, const vibe_audio_voice_desc_t* desc);
int vibe_audio_pcm_write_desc(unsigned long handle, const vibe_audio_pcm_desc_t* desc);
int vibe_audio_stream_open(const vibe_audio_pcm_desc_t* format);
int vibe_audio_stream_write(unsigned long handle, const vibe_audio_voice_desc_t* desc);
int vibe_audio_stream_drain(unsigned long handle);
int vibe_audio_stream_close(unsigned long handle);
int vibe_poll_input(vibe_input_event_t* event);
int vibe_drain_input(vibe_input_event_t* events, unsigned long max_events);
int vibe_input_status(vibe_input_status_t* status);
int vibe_input_device_status(unsigned long device_id, vibe_input_device_status_t* status);
int vibe_fb_get_info(vibe_fb_info_t* info);
int vibe_fb_can_present_indexed(const vibe_fb_info_t* info, const vibe_present_indexed_t* present);
int vibe_present_indexed(const vibe_present_indexed_t* present);
int vibe_present_indexed_checked(const vibe_present_indexed_t* present);
unsigned long vibe_heap_capabilities(void);
unsigned long vibe_vm_capabilities(void);
void* vibe_mmap_anon(unsigned long length, int prot);
unsigned long vibe_monotonic_ticks(void);
unsigned long vibe_monotonic_milliseconds(void);

/*
 * Vibe OS user syscall ABI:
 * - Success returns a non-negative int-sized value.
 * - Failure returns -errno when the kernel can classify the error.
 * - Legacy kernel paths may still return -1; libc maps those through the
 *   operation-specific fallback errno.
 * - `vibe_syscall_errno` centralizes that conversion for small ports that call
 *   `vibe_syscall3` directly and still want POSIX-shaped errno values.
 * - File flags use the O_* constants from fcntl.h, including O_ACCMODE and
 *   O_CLOEXEC. dup/dup2/dup3 create new descriptors that share the same open
 *   file description offset/status; dup3 accepts O_CLOEXEC for the new
 *   descriptor. fcntl(F_GETFD/F_SETFD) exposes descriptor-level FD_CLOEXEC so
 *   ports can audit or change exec inheritance after open/dup.
 * - ftruncate resizes writable FAT16 files opened through the VFS descriptor
 *   path. Growth zero-fills new bytes, and shrink frees tail clusters through
 *   the FAT layer.
 * - `vibe_file_size` and `vibe_file_read_all` are convenience wrappers for
 *   small tools and games that need whole-file asset/config reads without
 *   learning the descriptor syscall details. They still inherit the current
 *   FAT16 VFS path model.
 *   `pread`, `pwrite`, `vibe_file_read_at`, and `vibe_file_write_at` provide
 *   lseek-backed positioned I/O for single-threaded asset/state loaders that
 *   need package-table reads or small state-file updates without
 *   mutating their descriptor's logical offset.
 * - VIBE_SYS_CLOCK_GETTIME exposes the reusable monotonic kernel clock. It
 *   reports 100 Hz compatibility ticks plus milliseconds; on the supported QEMU
 *   target those milliseconds are HPET-backed once ACPI/HPET probing succeeds.
 *   It is not an RTC or wall clock. `vibe_clock_monotonic` and
 *   `vibe_clock_ticks_to_milliseconds` are generic helpers for game loops that
 *   do not want fixed 35 Hz tic conversion.
 * - VIBE_SYS_LISTDIR lists cached FAT16 root entries and one-level root
 *   subdirectories into fixed `vibe_dirent_t` records. Names are normalized
 *   8.3 display names, and stat/open/listdir honor FAT readonly attributes for
 *   root entries plus one-level subdirectory files. Nested traversal is not
 *   supported. Directory/file mismatches are classified for small tools:
 *   opening or unlinking a directory as a file returns `EISDIR`, while listing
 *   an existing regular file returns `ENOTDIR`.
 * - VIBE_SYS_POLL_INPUT drains one reusable keyboard/mouse event at a time.
 *   VIBE_SYS_INPUT_STATUS reports queue capacity/depth, overflow counters,
 *   keyboard state, and mouse state without consuming queued input.
 *   VIBE_SYS_INPUT_DEVICE_STATUS reports one device at a time, so future games
 *   can inspect keyboard and mouse readiness/counters/state without linking
 *   app-local translation helpers. The libc wrappers `vibe_poll_input`,
 *   `vibe_input_status`, and `vibe_input_device_status` pass the ABI byte sizes
 *   explicitly so game/tool code does not need to duplicate syscall details.
 *   `vibe_drain_input` is a bounded nonblocking drain helper for per-frame
 *   event pumps. Keyboard event codes are PS/2 set-1 make scancodes with bit 7
 *   used for E0-extended keys; inline helpers expose key press/release checks,
 *   PS/2 scancode/extended decoding, raw PS/2 mouse buttons, relative X/Y
 *   deltas, queue depth/counter invariants, explicit overflow policy/device
 *   readiness fields, modifier helpers, per-device drop/poll counters, and
 *   status ABI validation so consumers can stay out of app-local event translation
 *   layer. The queue stores 64 slots with one empty sentinel, so
 *   `VIBE_INPUT_EVENT_QUEUE_USABLE_CAPACITY` is the observable full depth; on
 *   overflow the kernel drops the oldest queued event and increments
 *   `dropped_events`.
 * - `vibe_audio_*` wrappers hide the VIBE_SYS_AUDIO command numbers and
 *   argument ordering for device/ring/stream/mixer calls. `PCM_OPEN`,
 *   `PCM_WRITE_DESC`, `PCM_DRAIN`, and `PCM_CLOSE` are the reusable stream
 *   path for games/tools that want to queue unsigned 8-bit stereo
 *   PCM without linking app-specific platform glue.
 * - `vibe_fb_get_info` queries the reusable framebuffer contract, and
 *   `vibe_present_indexed_checked` verifies the advertised caps/format/size
 *   before presenting a `vibe_present_indexed_t` through the display fd/ioctl
 *   path. `vibe_fb_info_t` advertises the accepted indexed source size and
 *   palette format before a program submits a frame. When
 *   `VIBE_FB_CAP_FIXED_PRESENT_SIZE` is set, callers must submit exactly
 *   `max_present_width` by `max_present_height`; future variable-size present
 *   formats can clear that bit and treat those fields as true maxima. Inline
 *   framebuffer helpers expose indexed RGB24 support, present-size acceptance,
 *   and source aspect metadata derived from the advertised viewport.
 * - sbrk grows or shrinks the process heap. Shrink trims whole released pages
 *   from the process page tables and heap-validation bitmap.
 *   `vibe_heap_capabilities` exposes this as grow+shrink brk-style heap only.
 * - mmap is currently anonymous/private and brk-backed; munmap validates the
 *   mapping range, tail munmap moves brk back, and valid non-tail munmap
 *   punches validation holes without creating reusable VM objects.
 *   `vibe_vm_capabilities` and `vibe_mmap_anon` make the supported VM subset
 *   explicit for ports that would otherwise probe file-backed/shared mappings.
 * - crt0 validates bounded argc/envp startup shape before calling user_main,
 *   records startup status flags, and exposes auxv through runtime helpers so
 *   generic programs can query page size and entry metadata without parsing
 *   the raw initial stack themselves.
 * - execv/execve pass bounded argv/envp vectors to the process handoff; execve copies bounded envp strings. Table
 *   entries cover compatibility/probe images; root-level FAT16 .ELF names use reusable
 *   probe-class slots. File descriptors inherit across exec unless
 *   opened with O_CLOEXEC, created by dup3 with O_CLOEXEC, or marked
 *   FD_CLOEXEC through fcntl(F_SETFD). Duplicated descriptors share offsets
 *   across exec until a close-on-exec descriptor is retired.
 *   VIBE_EXEC_* exposes the current path, argv, envp, and resolver-mode bounds
 *   to generic userland programs. Resolver mode `VIBE_EXEC_RESOLVE_GENERIC_ROOT83`
 *   means a root FAT 8.3 `.ELF` name used the reusable process pool instead of a
 *   table-only compatibility/probe path.
 * - getpid returns the active static process id. process_status returns a
 *   fixed 64-byte snapshot for the current process or a positive PID.
 * - yield is a cooperative scheduler handoff. `sleep_ticks` and direct-child
 *   blocking `waitpid` both park the caller on the kernel block primitive.
 * - fork eagerly clones probe-class address spaces and fd tables. wait/waitpid
 *   scan parent-PID metadata, reap EXITED/FAULTED children, support WNOHANG,
 *   and block on live direct children through that same bounded primitive.
 */

#endif
