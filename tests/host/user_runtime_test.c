#define VIBE_USER_RUNTIME_HOST_TEST 1

#include "../../user/runtime.h"
#include "sys/stat.h"

#define MOCK_MAX_WRITES 4
#define MOCK_MAX_DIRENTS 4
#define MOCK_MMAP_BASE 0x00408000u
#define MOCK_MMAP_BYTES 12288u

static char mock_write_buffer[64];
static const char mock_read_data[] = "abcdef";
static unsigned char mock_mmap_region[MOCK_MMAP_BYTES];
static int mock_write_length;
static int mock_write_chunk_limit;
static int mock_accumulate_writes;
static int mock_file_pos;
static int mock_read_chunk_limit;
static int mock_brk = 0x00400000;
static int mock_wait_reaped;
static int mock_munmap_count;
static int mock_exec_count;
static const char* mock_exec_path;
static unsigned long mock_exec_argv;
static unsigned long mock_exec_envp;
static int mock_close_count;
static int mock_probe_count;
static unsigned long mock_probe_magic;
static unsigned long mock_probe_flags;
static int mock_force_legacy_error;
static int mock_fd_flags;
static unsigned long mock_clock_ticks = 12;
static int mock_yield_count;
static int mock_input_queued;
static vibe_input_event_t mock_input_event;
static int mock_audio_calls;
static unsigned long mock_audio_command;
static unsigned long mock_audio_handle;
static int mock_fb_info_queries;
static int mock_fb_present_count;
static unsigned long mock_fb_present_width;
static unsigned long mock_fb_present_height;
static int mock_unlink_count;
static int mock_ftruncate_count;
static long mock_ftruncate_length;

static char* mock_user_buffer(unsigned long address, unsigned long count)
{
    if (address >= MOCK_MMAP_BASE
        && count <= MOCK_MMAP_BYTES
        && address - MOCK_MMAP_BASE <= MOCK_MMAP_BYTES - count)
        return (char*)mock_mmap_region + (address - MOCK_MMAP_BASE);
    return (char*)address;
}

int vibe_user_syscall3(unsigned int number, unsigned long arg0, unsigned long arg1, unsigned long arg2)
{
    if (number == VIBE_SYS_WRITE) {
        const char* text = (const char*)arg1;
        unsigned long length = arg2;
        unsigned long offset = mock_accumulate_writes ? (unsigned long)mock_write_length : 0;
        unsigned long index;

        (void)arg0;
        if (mock_force_legacy_error)
            return -1;
        if (mock_write_chunk_limit && length > (unsigned long)mock_write_chunk_limit)
            length = (unsigned long)mock_write_chunk_limit;
        for (index = 0; index < length && offset + index < sizeof(mock_write_buffer); ++index)
            mock_write_buffer[offset + index] = text[index];
        if (mock_accumulate_writes)
            mock_write_length += (int)length;
        else
            mock_write_length = (int)length;
        return (int)length;
    }

    if (number == VIBE_SYS_SBRK) {
        long increment = (long)arg0;
        int old = mock_brk;
        int next = mock_brk + (int)increment;

        if (next < 0x00400000 || next > 0x00410000)
            return -12;
        mock_brk = next;
        return old;
    }

    if (number == VIBE_SYS_OPEN) {
        if (!arg0 || arg2 != 0)
            return -22;
        if (arg1 == 0 || arg1 == (VIBE_USER_O_CREAT | VIBE_USER_O_RDWR))
            return 4;
        return -22;
    }

    if (number == VIBE_SYS_READ) {
        char* out = mock_user_buffer(arg1, arg2);
        int count = (int)arg2;
        int available;
        int index;

        if (arg0 != 4 || (!out && count))
            return -22;
        available = (int)sizeof(mock_read_data) - 1 - mock_file_pos;
        if (available < 0)
            available = 0;
        if (count > available)
            count = available;
        if (mock_read_chunk_limit && count > mock_read_chunk_limit)
            count = mock_read_chunk_limit;
        for (index = 0; index < count; ++index)
            out[index] = mock_read_data[mock_file_pos + index];
        mock_file_pos += count;
        return count;
    }

    if (number == VIBE_SYS_LSEEK) {
        int offset = (int)arg1;
        int next;

        if (arg0 != 4)
            return -9;
        if (arg2 == 0)
            next = offset;
        else if (arg2 == 1)
            next = mock_file_pos + offset;
        else if (arg2 == 2)
            next = (int)sizeof(mock_read_data) - 1 + offset;
        else
            return -22;
        if (next < 0)
            return -22;
        mock_file_pos = next;
        return mock_file_pos;
    }

    if (number == VIBE_SYS_CLOSE) {
        if (arg0 != 4)
            return -9;
        ++mock_close_count;
        return 0;
    }

    if (number == VIBE_SYS_UNLINK) {
        const char* path = (const char*)arg0;
        if (!path)
            return -22;
        if (path[0] == 'T' && path[1] == 'O' && path[2] == 'O' && path[3] == 'L') {
            ++mock_unlink_count;
            return 0;
        }
        return -2;
    }

    if (number == VIBE_SYS_STAT || number == VIBE_SYS_FSTAT) {
        struct stat* out = (struct stat*)arg1;
        if (number == VIBE_SYS_FSTAT)
            out = (struct stat*)arg1;
        if (number == VIBE_SYS_STAT && !arg0)
            return -22;
        if (number == VIBE_SYS_FSTAT && arg0 != 4)
            return -9;
        if (!out)
            return -22;
        out->st_mode = S_IFREG | S_IRUSR;
        out->st_size = (off_t)(sizeof(mock_read_data) - 1);
        return 0;
    }

    if (number == VIBE_SYS_FTRUNCATE) {
        if (arg0 != 4)
            return -9;
        if ((long)arg1 > (long)(sizeof(mock_read_data) - 1))
            return -28;
        ++mock_ftruncate_count;
        mock_ftruncate_length = (long)arg1;
        return 0;
    }

    if (number == VIBE_SYS_GETPID)
        return 7;

    if (number == VIBE_SYS_FORK)
        return -38;

    if (number == VIBE_SYS_WAITPID) {
        int* status = (int*)arg1;

        if (((long)arg0 != -1 && (long)arg0 != 3) || arg2 != VIBE_USER_WNOHANG)
            return -22;
        if (mock_wait_reaped)
            return -10;
        if (status)
            *status = 0x2a;
        mock_wait_reaped = 1;
        return 3;
    }

    if (number == VIBE_SYS_DUP)
        return arg0 == 4 ? 5 : -9;

    if (number == VIBE_SYS_DUP2)
        return arg0 == 4 && arg1 == 8 ? 8 : -9;

    if (number == VIBE_SYS_DUP3)
        return arg0 == 4 && arg1 == 9 && arg2 == 0x0800u ? 9 : -22;

    if (number == VIBE_SYS_FCNTL) {
        if (arg0 != 4)
            return -9;
        if (arg1 == 1)
            return mock_fd_flags;
        if (arg1 == 2 && arg2 <= 1) {
            mock_fd_flags = (int)arg2;
            return 0;
        }
        return -22;
    }

    if (number == VIBE_SYS_PROCESS_STATUS) {
        vibe_process_status_t* out = (vibe_process_status_t*)arg1;
        long pid = (long)arg0;

        if (!out || arg2 < VIBE_PROCESS_STATUS_BYTES)
            return -22;
        if (pid != VIBE_PROCESS_STATUS_SELF && pid != 7)
            return -22;
        out->abi_version = VIBE_PROCESS_STATUS_ABI_VERSION;
        out->status_bytes = VIBE_PROCESS_STATUS_BYTES;
        out->pid = 7;
        out->parent_pid = 1;
        out->state = VIBE_PROCESS_STATE_RUNNING;
        out->kind = VIBE_PROCESS_KIND_GENERIC;
        out->exit_status = 0;
        out->ticks = mock_clock_ticks;
        out->runs = 2;
        out->switches = 3;
        out->quantum_ticks = 1;
        out->entry = 0x00e40000u;
        out->stack_top = 0x00ed0000u;
        out->brk = 0x00ea1000u;
        out->scheduler_ticks = mock_clock_ticks;
        out->scheduler_rounds = (unsigned long)mock_yield_count;
        return 0;
    }

    if (number == VIBE_SYS_YIELD) {
        ++mock_yield_count;
        ++mock_clock_ticks;
        return 0;
    }

    if (number == VIBE_SYS_SLEEP_TICKS) {
        if (arg0 == 0)
            return -22;
        mock_clock_ticks += arg0;
        return 0;
    }

    if (number == VIBE_SYS_MMAP) {
        unsigned long prot = arg2 & 0xffffu;
        unsigned long flags = arg2 >> 16;
        unsigned long index;

        if (arg0 != 0 || arg1 == 0)
            return -22;
        if (flags != (VIBE_USER_MAP_PRIVATE | VIBE_USER_MAP_ANONYMOUS))
            return -22;
        if ((prot & (VIBE_USER_PROT_READ | VIBE_USER_PROT_WRITE)) != (VIBE_USER_PROT_READ | VIBE_USER_PROT_WRITE))
            return -22;
        for (index = 0; index < MOCK_MMAP_BYTES; ++index)
            mock_mmap_region[index] = 0;
        return MOCK_MMAP_BASE;
    }

    if (number == VIBE_SYS_MUNMAP) {
        if (arg0 != MOCK_MMAP_BASE || (arg1 != 4096 && arg1 != 8192) || arg2 != 0)
            return -22;
        ++mock_munmap_count;
        return 0;
    }

    if (number == VIBE_SYS_CLOCK_GETTIME) {
        vibe_clock_time_t* out = (vibe_clock_time_t*)arg1;
        if (arg0 != VIBE_CLOCK_MONOTONIC || !out || arg2 != sizeof(*out))
            return -22;
        out->ticks = mock_clock_ticks;
        out->frequency_hz = VIBE_CLOCK_MONOTONIC_HZ;
        out->milliseconds = mock_clock_ticks * 10;
        out->flags = 0;
        return 0;
    }

    if (number == VIBE_SYS_POLL_INPUT) {
        vibe_input_event_t* out = (vibe_input_event_t*)arg0;

        if (!out || arg1 < sizeof(*out) || arg2 != 0)
            return -22;
        if (!mock_input_queued)
            return 0;
        *out = mock_input_event;
        mock_input_queued = 0;
        return 1;
    }

    if (number == VIBE_SYS_INPUT_STATUS) {
        vibe_input_status_t* out = (vibe_input_status_t*)arg0;

        if (!out || arg1 < sizeof(*out) || arg2 != 0)
            return -22;
        out->abi_version = VIBE_INPUT_ABI_VERSION;
        out->event_bytes = VIBE_INPUT_EVENT_BYTES;
        out->queue_capacity = VIBE_INPUT_EVENT_QUEUE_CAPACITY;
        out->status_bytes = VIBE_INPUT_STATUS_BYTES;
        out->queue_usable_capacity = VIBE_INPUT_EVENT_QUEUE_USABLE_CAPACITY;
        out->overflow_policy = VIBE_INPUT_QUEUE_OVERFLOW_DROP_OLDEST;
        out->queued_events = mock_input_queued ? 1 : 0;
        out->total_events = mock_input_queued ? 1 : 0;
        out->polled_events = 0;
        out->dropped_events = 0;
        out->capabilities = VIBE_INPUT_CAP_KEYBOARD
            | VIBE_INPUT_CAP_MOUSE
            | VIBE_INPUT_CAP_POLL_EVENT
            | VIBE_INPUT_CAP_STATUS;
        out->keyboard_irq_count = 2;
        out->keyboard_event_count = 1;
        out->keyboard_down_count = 1;
        out->keyboard_last_code = vibe_input_ps2_set1_key_code(0x11, 0);
        out->keyboard_status = VIBE_INPUT_DEVICE_STATUS_READY;
        out->keyboard_state[0] = 1ul << 0x11;
        out->keyboard_state[1] = 0;
        out->keyboard_state[2] = 0;
        out->keyboard_state[3] = 0;
        out->keyboard_state[4] = 0;
        out->keyboard_state[5] = 0;
        out->keyboard_state[6] = 0;
        out->keyboard_state[7] = 0;
        out->mouse_irq_count = 3;
        out->mouse_packet_count = 1;
        out->mouse_sync_loss_count = 0;
        out->mouse_buttons = VIBE_INPUT_MOUSE_BUTTON_LEFT;
        out->mouse_delta_x_total = 4;
        out->mouse_delta_y_total = -2;
        out->mouse_status = VIBE_INPUT_DEVICE_STATUS_READY;
        out->last_event_device_id = VIBE_INPUT_DEVICE_KEYBOARD;
        out->last_event_type = VIBE_INPUT_EVENT_KEY;
        return 0;
    }

    if (number == VIBE_SYS_INPUT_DEVICE_STATUS) {
        vibe_input_device_status_t* out = (vibe_input_device_status_t*)arg1;

        if (!out || arg2 < sizeof(*out))
            return -22;
        if (arg0 != VIBE_INPUT_DEVICE_KEYBOARD && arg0 != VIBE_INPUT_DEVICE_MOUSE)
            return -22;
        out->abi_version = VIBE_INPUT_ABI_VERSION;
        out->status_bytes = VIBE_INPUT_DEVICE_STATUS_BYTES;
        out->device_id = arg0;
        out->status = VIBE_INPUT_DEVICE_STATUS_READY;
        out->irq_count = arg0 == VIBE_INPUT_DEVICE_KEYBOARD ? 2 : 3;
        out->event_count = 1;
        out->polled_events = 0;
        out->dropped_events = 0;
        out->last_timestamp = 77;
        out->reserved0 = 0;
        if (arg0 == VIBE_INPUT_DEVICE_KEYBOARD) {
            out->capabilities = VIBE_INPUT_DEVICE_CAP_KEYS | VIBE_INPUT_DEVICE_CAP_STATE_SNAPSHOT;
            out->last_event_type = VIBE_INPUT_EVENT_KEY;
            out->last_code = vibe_input_ps2_set1_key_code(0x11, 0);
            out->active_state = VIBE_INPUT_MOD_SHIFT;
            out->axis_x_total = 0;
            out->axis_y_total = 0;
        } else {
            out->capabilities = VIBE_INPUT_DEVICE_CAP_RELATIVE_POINTER
                | VIBE_INPUT_DEVICE_CAP_BUTTONS
                | VIBE_INPUT_DEVICE_CAP_STATE_SNAPSHOT;
            out->last_event_type = VIBE_INPUT_EVENT_MOUSE_PACKET;
            out->last_code = VIBE_INPUT_MOUSE_BUTTON_LEFT;
            out->active_state = VIBE_INPUT_MOUSE_BUTTON_LEFT;
            out->axis_x_total = 4;
            out->axis_y_total = -2;
        }
        return 0;
    }

    if (number == VIBE_USER_SYS_DISPLAY_IOCTL) {
        if (arg0 != VIBE_DISPLAY_FD)
            return -25;
        if (arg1 == VIBE_IOCTL_FBINFO) {
            vibe_fb_info_t* out = (vibe_fb_info_t*)arg2;
            if (!out)
                return -22;
            out->width = 640;
            out->height = 480;
            out->pitch = 640 * 4;
            out->backend = VIBE_FB_BACKEND_LFB_XRGB8888;
            out->frame_bytes = 160 * 100;
            out->palette_bytes = VIBE_FB_RGB24_PALETTE_BYTES;
            out->scale = 2;
            out->view_x = 160;
            out->view_y = 120;
            out->view_width = 320;
            out->view_height = 240;
            out->policy = VIBE_FB_POLICY_ASPECT;
            out->dirty_x = 1;
            out->dirty_y = 2;
            out->dirty_width = 3;
            out->dirty_height = 4;
            out->dirty_count = mock_fb_present_count ? 12 : 0;
            out->capabilities = VIBE_FB_CAP_PRESENT_INDEXED
                | VIBE_FB_CAP_PRESENT_RGB_PALETTE
                | VIBE_FB_CAP_XRGB8888_LFB
                | VIBE_FB_CAP_DIRTY_SOURCE_RECT;
            out->present_format = VIBE_FB_FORMAT_INDEX8_RGB24;
            out->max_present_width = 160;
            out->max_present_height = 100;
            ++mock_fb_info_queries;
            return 0;
        }
        if (arg1 == VIBE_IOCTL_PRESENT_INDEXED) {
            const vibe_present_indexed_t* present = (const vibe_present_indexed_t*)arg2;
            if (!present || !present->frame || !present->palette)
                return -22;
            if (present->width > 160 || present->height > 100)
                return -22;
            ++mock_fb_present_count;
            mock_fb_present_width = present->width;
            mock_fb_present_height = present->height;
            return 0;
        }
        return -25;
    }

    if (number == VIBE_SYS_AUDIO) {
        ++mock_audio_calls;
        mock_audio_command = arg0;
        mock_audio_handle = arg1;

        if (arg0 == VIBE_AUDIO_DEVICE_START)
            return 1;
        if (arg0 == VIBE_AUDIO_DEVICE_SHUTDOWN)
            return 0;
        if (arg0 == VIBE_AUDIO_DEVICE_INFO) {
            vibe_audio_device_info_t* out = (vibe_audio_device_info_t*)arg1;
            if (!out || arg2 != 0)
                return -22;
            out->device_kind = VIBE_AUDIO_DEVICE_SB16;
            out->status = VIBE_AUDIO_DEVICE_STATUS_READY;
            out->capabilities = VIBE_AUDIO_CAP_PCM_RING | VIBE_AUDIO_CAP_PULL_STREAM;
            return 0;
        }
        if (arg0 == VIBE_AUDIO_PCM_RING_INFO) {
            vibe_audio_pcm_ring_info_t* out = (vibe_audio_pcm_ring_info_t*)arg1;
            if (!out || arg2 != 0)
                return -22;
            out->format = VIBE_AUDIO_FORMAT_U8_STEREO;
            out->channels = 2;
            out->ring_bytes = 4096;
            return 0;
        }
        if (arg0 == VIBE_AUDIO_STREAM_INFO) {
            vibe_audio_stream_info_t* out = (vibe_audio_stream_info_t*)arg2;
            if (!out)
                return -22;
            out->stream_mode = VIBE_AUDIO_STREAM_PULL;
            out->flags = VIBE_AUDIO_STREAM_FLAG_PULL;
            out->handle = arg1;
            return 0;
        }
        if (arg0 == VIBE_AUDIO_PCM_WRITE) {
            const vibe_audio_voice_desc_t* desc = (const vibe_audio_voice_desc_t*)arg2;
            if (!desc)
                return -22;
            return (int)desc->length;
        }
        if (arg0 == VIBE_AUDIO_PCM_BUFFERED_BYTES)
            return 4;
        if (arg0 == VIBE_AUDIO_PCM_PULL_STATE)
            return 2;
        return -38;
    }

    if (number == VIBE_SYS_LISTDIR) {
        vibe_dirent_t* entries = (vibe_dirent_t*)arg1;
        if (!entries || arg2 < MOCK_MAX_DIRENTS)
            return -22;
        entries[0].name[0] = 'T';
        entries[0].name[1] = 'O';
        entries[0].name[2] = 'O';
        entries[0].name[3] = 'L';
        entries[0].name[4] = 0;
        return 1;
    }

    if (number == VIBE_SYS_EXEC) {
        ++mock_exec_count;
        mock_exec_path = (const char*)arg0;
        mock_exec_argv = arg1;
        mock_exec_envp = arg2;
        return arg0 ? 0 : -22;
    }

    if (number == VIBE_SYS_USER_PROBE) {
        ++mock_probe_count;
        mock_probe_magic = arg0;
        mock_probe_flags = arg1;
        return 0;
    }

    return -38;
}

#include "../../user/runtime.c"

static int fail(int code)
{
    return code;
}

static void clear_chars(char* buffer, unsigned long length)
{
    unsigned long index;

    for (index = 0; index < length; ++index)
        buffer[index] = 0;
}

int main(void)
{
    vibe_clock_time_t now;
    vibe_dirent_t entries[MOCK_MAX_DIRENTS];
    vibe_input_event_t input_events[2];
    vibe_input_status_t input_status;
    vibe_input_device_status_t input_device_status;
    vibe_fb_info_t fb_info;
    vibe_present_indexed_t fb_present;
    vibe_audio_device_info_t audio_device;
    vibe_audio_pcm_ring_info_t audio_ring;
    vibe_audio_stream_info_t audio_stream;
    vibe_audio_voice_desc_t audio_desc;
    vibe_process_status_t process_status;
    struct stat stat_info;
    unsigned char audio_samples[4] = { 128, 129, 127, 128 };
    unsigned char fb_frame[160 * 100] = { 0 };
    unsigned char fb_palette[VIBE_FB_RGB24_PALETTE_BYTES] = { 0 };
    char read_buffer[4];
    char* argv[] = { "TOOL.ELF", 0 };
    char* empty_env[] = { 0 };
    char* nonempty_env[] = { "A=B", 0 };
    char* max_argv[VIBE_EXEC_ARG_MAX + 1];
    char* too_many_argv[VIBE_EXEC_ARG_MAX + 2];
    char* max_env[VIBE_EXEC_ENV_MAX + 1];
    char* too_many_env[VIBE_EXEC_ENV_MAX + 2];
    char long_path[VIBE_EXEC_PATH_MAX + 1];
    char long_arg[VIBE_EXEC_ARG_STR_MAX + 1];
    char long_env[VIBE_EXEC_ENV_STR_MAX + 1];
    unsigned long argc = 0;
    unsigned long file_size = 0;
    unsigned long out_read = 0;
    unsigned long io_count = 0;
    void* old_break = 0;
    void* mapped = 0;
    void* file_mapped = 0;
    char full_buffer[8];
    int wait_status = 0;
    int index;

    if (vibe_user_syscall_errno(-13, 5) != 13)
        return fail(1);
    if (vibe_user_syscall_errno(-1, 22) != 22)
        return fail(2);
    if (vibe_user_syscall_errno(0, 5) != 0)
        return fail(3);
    if (!vibe_user_streq("ABIPROBE.ELF", "ABIPROBE.ELF") || vibe_user_streq("A", "B"))
        return fail(4);
    if (vibe_user_write_all(1, "hello") != 0 || mock_write_length != 5 || mock_write_buffer[0] != 'h')
        return fail(5);
    mock_force_legacy_error = 1;
    if (vibe_user_write_all(1, "bad") != -5)
        return fail(6);
    mock_force_legacy_error = 0;
    clear_chars(mock_write_buffer, sizeof(mock_write_buffer));
    mock_write_length = 0;
    mock_accumulate_writes = 1;
    mock_write_chunk_limit = 2;
    io_count = 99;
    if (vibe_user_write_full(1, "abcde", 5, &io_count) != 0
        || io_count != 5
        || mock_write_length != 5
        || !vibe_user_streq(mock_write_buffer, "abcde"))
        return fail(105);
    if (vibe_user_write_full(1, 0, 1, &io_count) != -22 || io_count != 0)
        return fail(106);
    mock_accumulate_writes = 0;
    mock_write_chunk_limit = 0;
    mock_file_pos = 0;
    mock_read_chunk_limit = 2;
    clear_chars(full_buffer, sizeof(full_buffer));
    io_count = 99;
    if (vibe_user_read_full(4, full_buffer, 5, &io_count) != 0
        || io_count != 5
        || !vibe_user_streq(full_buffer, "abcde"))
        return fail(107);
    mock_file_pos = 0;
    clear_chars(full_buffer, sizeof(full_buffer));
    if (vibe_user_read_exact(4, full_buffer, 5, &io_count) != 0
        || io_count != 5
        || !vibe_user_streq(full_buffer, "abcde"))
        return fail(108);
    mock_file_pos = 0;
    clear_chars(full_buffer, sizeof(full_buffer));
    if (vibe_user_read_exact(4, full_buffer, 8, &io_count) != -5
        || io_count != sizeof(mock_read_data) - 1
        || !vibe_user_streq(full_buffer, mock_read_data))
        return fail(109);
    if (vibe_user_read_full(4, 0, 1, &io_count) != -22 || io_count != 0)
        return fail(110);
    mock_read_chunk_limit = 0;
    mock_file_pos = 0;
    if (vibe_user_getpid() != 7)
        return fail(7);
    if (vibe_user_process_status_current(&process_status) != 0
        || process_status.abi_version != VIBE_PROCESS_STATUS_ABI_VERSION
        || process_status.status_bytes != VIBE_PROCESS_STATUS_BYTES
        || process_status.pid != 7
        || process_status.state != VIBE_PROCESS_STATE_RUNNING
        || process_status.kind != VIBE_PROCESS_KIND_GENERIC)
        return fail(89);
    if (vibe_user_process_status(7, &process_status) != 0
        || process_status.parent_pid != 1
        || process_status.scheduler_ticks != mock_clock_ticks)
        return fail(90);
    if (vibe_user_process_status(99, &process_status) != -22
        || vibe_user_process_status_current(0) != -22)
        return fail(91);
    mock_yield_count = 0;
    mock_clock_ticks = 20;
    if (vibe_user_yield() != 0 || mock_yield_count != 1 || mock_clock_ticks != 21)
        return fail(92);
    mock_yield_count = 0;
    mock_clock_ticks = 20;
    if (vibe_user_sleep_ticks(3) != 0 || mock_yield_count != 0 || mock_clock_ticks != 23)
        return fail(93);
    mock_yield_count = 0;
    mock_clock_ticks = 30;
    if (vibe_user_sleep_milliseconds(10) != 0 || mock_yield_count != 0 || mock_clock_ticks != 31)
        return fail(94);
    if (vibe_user_sleep_ticks(0) != 0 || mock_yield_count != 1)
        return fail(95);
    if (vibe_user_sleep_milliseconds(0) != 0 || mock_yield_count != 2)
        return fail(96);
    if (vibe_user_fork() != -38)
        return fail(19);
    if (vibe_user_waitpid(-1, &wait_status, VIBE_USER_WNOHANG) != 3 || wait_status != 0x2a)
        return fail(20);
    if (vibe_user_waitpid(-1, &wait_status, VIBE_USER_WNOHANG) != -10)
        return fail(21);
    mock_wait_reaped = 0;
    wait_status = 0;
    if (vibe_user_waitpid_nohang_reap(3, &wait_status, 3) != 3 || wait_status != 0x2a)
        return fail(37);
    if (vibe_user_waitpid_nohang_reap(3, &wait_status, 0) != -22)
        return fail(38);
    mock_wait_reaped = 0;
    wait_status = 0;
    if (vibe_user_waitpid_nohang_reap_exact(3, &wait_status, 3) != 3 || wait_status != 0x2a)
        return fail(43);
    if (vibe_user_waitpid_nohang_reap_exact(-1, &wait_status, 3) != -22)
        return fail(44);
    if (vibe_user_sbrk(4096, &old_break) != 0 || old_break != (void*)0x00400000)
        return fail(22);
    if (vibe_user_sbrk(-4096, &old_break) != 0 || old_break != (void*)0x00401000)
        return fail(23);
    if (vibe_user_sbrk(4096, 0) != -22)
        return fail(24);
    if (vibe_user_mmap_anon(&mapped, 4096, VIBE_USER_PROT_READ | VIBE_USER_PROT_WRITE) != 0 || mapped != (void*)0x00408000)
        return fail(25);
    if (vibe_user_mmap(&mapped, 4096, VIBE_USER_PROT_READ, VIBE_USER_MAP_FIXED) != -22)
        return fail(26);
    if (vibe_user_munmap(mapped, 4096) != 0 || mock_munmap_count != 1)
        return fail(27);
    if (vibe_user_munmap(0, 4096) != -22)
        return fail(28);
    if ((vibe_user_heap_capabilities() & (VIBE_HEAP_CAP_SBRK_GROW | VIBE_HEAP_CAP_SBRK_SHRINK)) != (VIBE_HEAP_CAP_SBRK_GROW | VIBE_HEAP_CAP_SBRK_SHRINK))
        return fail(29);
    if ((vibe_user_vm_capabilities() & (VIBE_VM_CAP_ANON_PRIVATE | VIBE_VM_CAP_NONTAIL_MUNMAP_HOLES | VIBE_USER_VM_CAP_FILE_PRIVATE_COPY)) != (VIBE_VM_CAP_ANON_PRIVATE | VIBE_VM_CAP_NONTAIL_MUNMAP_HOLES | VIBE_USER_VM_CAP_FILE_PRIVATE_COPY))
        return fail(30);
    mock_file_pos = 1;
    if (vibe_user_mmap_file_private(&file_mapped, 4096, VIBE_USER_PROT_READ | VIBE_USER_PROT_WRITE, 4, 2) != 0 || file_mapped != (void*)MOCK_MMAP_BASE)
        return fail(31);
    if (mock_mmap_region[0] != 'c' || mock_mmap_region[1] != 'd' || mock_mmap_region[2] != 'e' || mock_mmap_region[3] != 'f')
        return fail(32);
    if (mock_file_pos != 1)
        return fail(33);
    if (vibe_user_munmap(file_mapped, 4096) != 0 || mock_munmap_count != 2)
        return fail(34);
    mock_file_pos = 2;
    if (vibe_user_mmap_file_private(&file_mapped, 8192, VIBE_USER_PROT_READ | VIBE_USER_PROT_WRITE, 4, 5) != 0 || file_mapped != (void*)MOCK_MMAP_BASE)
        return fail(39);
    if (mock_mmap_region[0] != 'f' || mock_mmap_region[1] != 0 || mock_mmap_region[4096] != 0)
        return fail(40);
    if (mock_file_pos != 2)
        return fail(41);
    if (vibe_user_munmap(file_mapped, 8192) != 0 || mock_munmap_count != 3)
        return fail(42);
    if (vibe_user_mmap_file(&file_mapped, 4096, VIBE_USER_PROT_READ | VIBE_USER_PROT_WRITE, VIBE_USER_MAP_SHARED, 4, 0) != -22)
        return fail(35);
    if (vibe_user_mmap_file_private(&file_mapped, 8192, VIBE_USER_PROT_READ | VIBE_USER_PROT_WRITE, 3, 0) != -9 || file_mapped != 0 || mock_munmap_count != 4)
        return fail(36);
    if (vibe_user_dup(4) != 5 || vibe_user_dup2(4, 8) != 8 || vibe_user_dup3(4, 9, 0x0800u) != 9)
        return fail(8);
    if (vibe_user_open("TOOL.TXT", 0, 0) != 4 || vibe_user_fcntl(4, 1, 0) != 0 || vibe_user_fcntl(4, 2, 1) != 0)
        return fail(13);
    if (vibe_user_write(4, "xy", 2) != 2 || mock_write_length != 2 || mock_write_buffer[0] != 'x')
        return fail(81);
    if (vibe_user_write(4, 0, 1) != -22)
        return fail(82);
    if (vibe_user_stat("TOOL.TXT", &stat_info) != 0 || !S_ISREG(stat_info.st_mode) || stat_info.st_size != 6)
        return fail(83);
    if (vibe_user_stat(0, &stat_info) != -22 || vibe_user_stat("TOOL.TXT", 0) != -22)
        return fail(84);
    if (vibe_user_fstat(4, &stat_info) != 0 || stat_info.st_size != 6 || vibe_user_fstat(3, &stat_info) != -9 || vibe_user_fstat(4, 0) != -22)
        return fail(85);
    if (vibe_user_ftruncate(4, 3) != 0 || mock_ftruncate_count != 1 || mock_ftruncate_length != 3)
        return fail(86);
    if (vibe_user_ftruncate(4, -1) != -22 || vibe_user_ftruncate(4, 7) != -28)
        return fail(87);
    if (vibe_user_unlink("TOOL.TXT") != 0 || mock_unlink_count != 1 || vibe_user_unlink("MISSING.TXT") != -2 || vibe_user_unlink(0) != -22)
        return fail(88);
    if (vibe_user_get_cloexec(4, &wait_status) != 0 || wait_status != 1)
        return fail(45);
    if (vibe_user_set_cloexec(4, 0) != 0 || vibe_user_get_cloexec(4, &wait_status) != 0 || wait_status != 0)
        return fail(46);
    if (vibe_user_get_cloexec(4, 0) != -22)
        return fail(47);
    if (vibe_user_lseek(4, 6, 0) != 6)
        return fail(15);
    if (vibe_user_pread(4, read_buffer, 3, 2) != 3
        || read_buffer[0] != 'c'
        || read_buffer[1] != 'd'
        || read_buffer[2] != 'e')
        return fail(16);
    if (vibe_user_lseek(4, 0, 1) != 6)
        return fail(17);
    clear_chars(mock_write_buffer, sizeof(mock_write_buffer));
    mock_write_length = 0;
    if (vibe_user_pwrite(4, "UV", 2, 2) != 2
        || mock_file_pos != 6
        || mock_write_length != 2
        || mock_write_buffer[0] != 'U')
        return fail(111);
    if (vibe_user_pwrite(4, 0, 1, 2) != -22 || vibe_user_pwrite(4, "Z", 1, -1) != -22)
        return fail(112);
    if (vibe_user_pread(4, read_buffer, 1, -1) != -22)
        return fail(18);
    if (vibe_user_close(4) != 0 || mock_close_count != 1)
        return fail(14);
    if (VIBE_USER_O_RDONLY != 0
        || VIBE_USER_O_RDWR != 2
        || VIBE_USER_O_CLOEXEC != 0x0800u
        || VIBE_USER_SEEK_CUR != 1)
        return fail(97);
    if (vibe_user_file_size("TOOL.TXT", &file_size) != 0 || file_size != sizeof(mock_read_data) - 1)
        return fail(98);
    if (vibe_user_file_size(0, &file_size) != -22 || vibe_user_file_size("TOOL.TXT", 0) != -22)
        return fail(99);
    mock_file_pos = 0;
    clear_chars(read_buffer, sizeof(read_buffer));
    if (vibe_user_file_read_at("TOOL.TXT", 2, read_buffer, 3, &out_read) != 0
        || out_read != 3
        || read_buffer[0] != 'c'
        || read_buffer[1] != 'd'
        || read_buffer[2] != 'e'
        || mock_file_pos != 0)
        return fail(100);
    clear_chars(mock_write_buffer, sizeof(mock_write_buffer));
    mock_write_length = 0;
    out_read = 99;
    if (vibe_user_file_write_at("TOOL.TXT", 2, "UV", 2, &out_read) != 0
        || out_read != 2
        || mock_file_pos != 0
        || mock_write_length != 2
        || mock_write_buffer[0] != 'U')
        return fail(113);
    if (vibe_user_file_write_at(0, 0, "X", 1, &out_read) != -22
        || vibe_user_file_write_at("TOOL.TXT", 0x80000000ul, "X", 1, &out_read) != -75)
        return fail(114);
    mock_file_pos = 0;
    clear_chars(full_buffer, sizeof(full_buffer));
    if (vibe_user_file_read_all("TOOL.TXT", full_buffer, sizeof(full_buffer), &out_read) != 0
        || out_read != sizeof(mock_read_data) - 1
        || !vibe_user_streq(full_buffer, mock_read_data))
        return fail(101);
    mock_file_pos = 0;
    if (vibe_user_file_read_all("TOOL.TXT", full_buffer, 3, &out_read) != -28
        || out_read != sizeof(mock_read_data) - 1)
        return fail(102);
    if (vibe_user_clock_monotonic(&now) != 0 || now.frequency_hz != VIBE_CLOCK_MONOTONIC_HZ)
        return fail(9);
    vibe_input_make_key_event(
        &mock_input_event,
        77,
        vibe_input_ps2_set1_key_code(0x11, 0),
        VIBE_INPUT_KEY_PRESSED);
    mock_input_queued = 1;
    if (vibe_user_input_status(&input_status) != 0
        || !vibe_input_status_abi_is_current(&input_status)
        || !vibe_input_status_has_capability(&input_status, VIBE_INPUT_CAP_POLL_EVENT)
        || vibe_input_status_queued_events(&input_status) != 1
        || vibe_input_status_usable_capacity(&input_status) != VIBE_INPUT_EVENT_QUEUE_USABLE_CAPACITY
        || !vibe_input_status_uses_drop_oldest(&input_status)
        || !vibe_input_status_keyboard_is_ready(&input_status)
        || !vibe_input_status_mouse_is_ready(&input_status)
        || !vibe_input_status_ps2_set1_key_is_down(&input_status, 0x11, 0)
        || !vibe_input_status_mouse_button_is_down(&input_status, VIBE_INPUT_MOUSE_BUTTON_LEFT)
        || !vibe_input_status_mouse_has_motion(&input_status))
        return fail(58);
    if (vibe_user_input_device_status(VIBE_INPUT_DEVICE_KEYBOARD, &input_device_status) != 0
        || !vibe_input_device_record_is_ready(&input_device_status)
        || !vibe_input_device_status_has_capability(&input_device_status, VIBE_INPUT_DEVICE_CAP_KEYS)
        || vibe_input_device_status_keyboard_modifiers(&input_device_status) != VIBE_INPUT_MOD_SHIFT)
        return fail(103);
    if (vibe_user_input_device_status(VIBE_INPUT_DEVICE_MOUSE, &input_device_status) != 0
        || !vibe_input_device_status_has_capability(&input_device_status, VIBE_INPUT_DEVICE_CAP_BUTTONS)
        || vibe_input_device_status_mouse_buttons(&input_device_status) != VIBE_INPUT_MOUSE_BUTTON_LEFT)
        return fail(104);
    if (vibe_user_drain_input(input_events, 2) != 1
        || !vibe_input_event_is_key(&input_events[0])
        || input_events[0].timestamp != 77
        || input_events[0].code != vibe_input_ps2_set1_key_code(0x11, 0)
        || !vibe_input_key_is_pressed(&input_events[0]))
        return fail(59);
    if (vibe_user_drain_input(input_events, 2) != 0)
        return fail(60);
    if (vibe_user_poll_input(0) != -22
        || vibe_user_input_status(0) != -22
        || vibe_user_input_device_status(VIBE_INPUT_DEVICE_KEYBOARD, 0) != -22
        || vibe_user_input_device_status(99, &input_device_status) != -22
        || vibe_user_drain_input(0, 1) != -22)
        return fail(61);
    vibe_present_indexed_init(&fb_present, fb_frame, fb_palette, 160, 100);
    if (vibe_user_fb_get_info(&fb_info) != 0
        || !vibe_fb_info_supports_indexed_rgb24(&fb_info)
        || !vibe_fb_info_has_capability(&fb_info, VIBE_FB_CAP_DIRTY_SOURCE_RECT)
        || vibe_fb_info_requires_fixed_present_size(&fb_info)
        || !vibe_fb_info_present_size_is_accepted(&fb_info, 160, 100)
        || !vibe_fb_info_present_size_is_accepted(&fb_info, 80, 100)
        || vibe_fb_info_present_size_is_accepted(&fb_info, 161, 100))
        return fail(70);
    if (vibe_fb_info_present_frame_bytes(&fb_info) != 16000
        || vibe_fb_info_present_palette_bytes(&fb_info) != VIBE_FB_RGB24_PALETTE_BYTES
        || vibe_fb_info_source_format(&fb_info) != VIBE_FB_FORMAT_INDEX8_RGB24
        || vibe_fb_info_source_width(&fb_info) != 160
        || vibe_fb_info_source_height(&fb_info) != 100
        || vibe_fb_info_source_palette_entries(&fb_info) != VIBE_FB_INDEXED_PALETTE_COLORS
        || vibe_fb_info_source_palette_entry_bytes(&fb_info) != VIBE_FB_RGB24_PALETTE_ENTRY_BYTES
        || vibe_fb_info_source_aspect_height(&fb_info) != 120)
        return fail(71);
    if (!vibe_user_fb_can_present_indexed(&fb_info, &fb_present))
        return fail(72);
    if (vibe_user_present_indexed_checked(&fb_present) != 0
        || mock_fb_info_queries < 2
        || mock_fb_present_count != 1
        || mock_fb_present_width != 160
        || mock_fb_present_height != 100)
        return fail(73);
    fb_present.width = 161;
    if (vibe_user_fb_can_present_indexed(&fb_info, &fb_present)
        || vibe_user_present_indexed_checked(&fb_present) != -22
        || vibe_user_fb_get_info(0) != -22
        || vibe_user_present_indexed(0) != -22)
        return fail(74);
    if (vibe_user_audio_device_start() != 1 || mock_audio_command != VIBE_AUDIO_DEVICE_START)
        return fail(62);
    if (vibe_user_audio_device_info(&audio_device) != 0
        || audio_device.device_kind != VIBE_AUDIO_DEVICE_SB16
        || !vibe_audio_device_has_capability(&audio_device, VIBE_AUDIO_CAP_PULL_STREAM))
        return fail(63);
    if (vibe_user_audio_pcm_ring_info(&audio_ring) != 0
        || !vibe_audio_pcm_ring_is_u8_stereo(&audio_ring))
        return fail(64);
    if (vibe_user_audio_stream_info(0x7100u, &audio_stream) != 0
        || !vibe_audio_stream_matches_handle(&audio_stream, 0x7100u)
        || !vibe_audio_stream_uses_pull(&audio_stream))
        return fail(65);
    vibe_audio_voice_desc_init(&audio_desc, audio_samples, 4, 11025, 127, 128, 128);
    if (vibe_user_audio_pcm_write(0x7100u, &audio_desc) != 4
        || mock_audio_command != VIBE_AUDIO_PCM_WRITE
        || mock_audio_handle != 0x7100u)
        return fail(66);
    if (vibe_user_audio_stream_write(0x7100u, &audio_desc) != 4)
        return fail(67);
    if (vibe_user_audio_pcm_buffered_bytes(0x7100u) != 4
        || vibe_user_audio_pcm_pull_state(0x7100u) != 2
        || vibe_user_audio_device_shutdown() != 0)
        return fail(68);
    if (vibe_user_audio_device_info(0) != -22
        || vibe_user_audio_pcm_ring_info(0) != -22
        || vibe_user_audio_stream_info(0x7100u, 0) != -22
        || vibe_user_audio_pcm_write(0x7100u, 0) != -22)
        return fail(69);
    if (vibe_user_listdir("/", entries, MOCK_MAX_DIRENTS) != 1 || !vibe_user_streq(entries[0].name, "TOOL"))
        return fail(10);
    if (vibe_user_listdir_find("/", "TOOL", entries) != 1 || !vibe_user_streq(entries[0].name, "TOOL"))
        return fail(48);
    if (vibe_user_listdir_find("/", "MISSING", entries) != 0)
        return fail(49);
    if (!vibe_user_dirent_name_eq(entries, "TOOL") || vibe_user_dirent_name_eq(0, "TOOL"))
        return fail(50);
    if (vibe_user_validate_exec_argv("TOOL.ELF", argv, &argc) != 0 || argc != 1)
        return fail(51);
    if (vibe_user_validate_exec_argv("TOOL.ELF", 0, &argc) != 0 || argc != 1)
        return fail(52);
    long_path[0] = 'A';
    long_path[1] = 'B';
    long_path[2] = 'C';
    long_path[3] = 'D';
    long_path[4] = 'E';
    long_path[5] = 'F';
    long_path[6] = 'G';
    long_path[7] = 'H';
    long_path[8] = 'I';
    long_path[9] = 'J';
    long_path[10] = 'K';
    long_path[11] = 'L';
    long_path[12] = 'M';
    long_path[13] = 'N';
    long_path[14] = 'O';
    long_path[15] = 'P';
    long_path[16] = 0;
    if (vibe_user_validate_exec_argv(long_path, argv, &argc) != -22)
        return fail(53);
    for (index = 0; index < VIBE_EXEC_ARG_STR_MAX; ++index)
        long_arg[index] = 'A';
    long_arg[VIBE_EXEC_ARG_STR_MAX] = 0;
    argv[0] = long_arg;
    if (vibe_user_validate_exec_argv("TOOL.ELF", argv, &argc) != -22)
        return fail(54);
    for (index = 0; index < VIBE_EXEC_ARG_MAX; ++index)
        max_argv[index] = "ARG";
    max_argv[VIBE_EXEC_ARG_MAX] = 0;
    if (vibe_user_validate_exec_argv("TOOL.ELF", max_argv, &argc) != 0 || argc != VIBE_EXEC_ARG_MAX)
        return fail(77);
    for (index = 0; index <= VIBE_EXEC_ARG_MAX; ++index)
        too_many_argv[index] = "ARG";
    too_many_argv[VIBE_EXEC_ARG_MAX + 1] = 0;
    if (vibe_user_validate_exec_argv("TOOL.ELF", too_many_argv, &argc) != -22)
        return fail(78);
    for (index = 0; index < VIBE_EXEC_ENV_STR_MAX; ++index)
        long_env[index] = 'B';
    long_env[VIBE_EXEC_ENV_STR_MAX] = 0;
    nonempty_env[0] = long_env;
    if (vibe_user_validate_exec_envp(nonempty_env, &argc) != -22)
        return fail(56);
    nonempty_env[0] = "A=B";
    for (index = 0; index < VIBE_EXEC_ENV_MAX; ++index)
        max_env[index] = "E=1";
    max_env[VIBE_EXEC_ENV_MAX] = 0;
    if (vibe_user_validate_exec_envp(max_env, &argc) != 0 || argc != VIBE_EXEC_ENV_MAX)
        return fail(79);
    for (index = 0; index <= VIBE_EXEC_ENV_MAX; ++index)
        too_many_env[index] = "E=1";
    too_many_env[VIBE_EXEC_ENV_MAX + 1] = 0;
    if (vibe_user_validate_exec_envp(too_many_env, &argc) != -22)
        return fail(80);
    argv[0] = "TOOL.ELF";
    if (vibe_user_execv("TOOL.ELF", argv) != 0 || mock_exec_count != 1 || !vibe_user_streq(mock_exec_path, "TOOL.ELF") || mock_exec_envp != 0)
        return fail(11);
    if (vibe_user_execv_checked("", argv) != -22 || mock_exec_count != 1)
        return fail(55);
    if (vibe_user_execve("TOOL.ELF", argv, nonempty_env) != 0 || mock_exec_count != 2 || mock_exec_envp != (unsigned long)nonempty_env)
        return fail(75);
    if (vibe_user_execve("TOOL.ELF", 0, empty_env) != 0 || mock_exec_count != 3 || mock_exec_argv != 0 || mock_exec_envp != (unsigned long)empty_env)
        return fail(76);
    vibe_user_report_probe(0x1234u, 0x55u);
    if (mock_probe_count != 1 || mock_probe_magic != 0x1234u || mock_probe_flags != 0x55u)
        return fail(12);

    return 0;
}
