#define VIBE_LIBC_HOST_TEST 1

#define stdin vibe_test_stdin
#define stdout vibe_test_stdout
#define stderr vibe_test_stderr
#define environ vibe_test_environ
#define abs vibe_test_abs
#define atoi vibe_test_atoi
#define atol vibe_test_atol
#define atof vibe_test_atof
#define strtol vibe_test_strtol
#define strtoul vibe_test_strtoul
#define strtod vibe_test_strtod
#define malloc vibe_test_malloc
#define calloc vibe_test_calloc
#define realloc vibe_test_realloc
#define free vibe_test_free
#define _exit vibe_test__exit
#define exit vibe_test_exit
#define getenv vibe_test_getenv
#define rand vibe_test_rand
#define srand vibe_test_srand
#define sin vibe_test_sin
#define cos vibe_test_cos
#define atan vibe_test_atan
#define atan2 vibe_test_atan2
#define pow vibe_test_pow
#define sqrt vibe_test_sqrt
#define floor vibe_test_floor
#define ceil vibe_test_ceil
#define fabs vibe_test_fabs
#define memcpy vibe_test_memcpy
#define memmove vibe_test_memmove
#define memset vibe_test_memset
#define memcmp vibe_test_memcmp
#define memchr vibe_test_memchr
#define strlen vibe_test_strlen
#define strnlen vibe_test_strnlen
#define strcpy vibe_test_strcpy
#define strncpy vibe_test_strncpy
#define strcat vibe_test_strcat
#define strncat vibe_test_strncat
#define strcmp vibe_test_strcmp
#define strncmp vibe_test_strncmp
#define strcasecmp vibe_test_strcasecmp
#define strncasecmp vibe_test_strncasecmp
#define strchr vibe_test_strchr
#define strrchr vibe_test_strrchr
#define strpbrk vibe_test_strpbrk
#define strstr vibe_test_strstr
#define strspn vibe_test_strspn
#define strcspn vibe_test_strcspn
#define strtok vibe_test_strtok
#define strtok_r vibe_test_strtok_r
#define strdup vibe_test_strdup
#define strndup vibe_test_strndup
#define strerror vibe_test_strerror
#define labs vibe_test_labs
#define qsort vibe_test_qsort
#define bsearch vibe_test_bsearch
#define open vibe_test_open
#define read vibe_test_read
#define write vibe_test_write
#define pread vibe_test_pread
#define pwrite vibe_test_pwrite
#define close vibe_test_close
#define lseek vibe_test_lseek
#define ftruncate vibe_test_ftruncate
#define truncate vibe_test_truncate
#define clock_gettime vibe_test_clock_gettime
#define access vibe_test_access
#define unlink vibe_test_unlink
#define remove vibe_test_remove
#define perror vibe_test_perror
#define mmap vibe_test_mmap
#define munmap vibe_test_munmap
#define ioctl vibe_test_ioctl
#define execl vibe_test_execl
#define execv vibe_test_execv
#define execve vibe_test_execve
#define fork vibe_test_fork
#define getpid vibe_test_getpid
#define wait vibe_test_wait
#define waitpid vibe_test_waitpid
#define mkdir vibe_test_mkdir
#define fstat vibe_test_fstat
#define stat vibe_test_stat
#define fopen vibe_test_fopen
#define fread vibe_test_fread
#define fwrite vibe_test_fwrite
#define fgetc vibe_test_fgetc
#define getc vibe_test_getc
#define ungetc vibe_test_ungetc
#define fgets vibe_test_fgets
#define fputc vibe_test_fputc
#define putc vibe_test_putc
#define putchar vibe_test_putchar
#define fputs vibe_test_fputs
#define puts vibe_test_puts
#define fseek vibe_test_fseek
#define ftell vibe_test_ftell
#define rewind vibe_test_rewind
#define fclose vibe_test_fclose
#define fflush vibe_test_fflush
#define feof vibe_test_feof
#define ferror vibe_test_ferror
#define clearerr vibe_test_clearerr
#define setbuf vibe_test_setbuf
#define getchar vibe_test_getchar
#define printf vibe_test_printf
#define fprintf vibe_test_fprintf
#define sprintf vibe_test_sprintf
#define snprintf vibe_test_snprintf
#define vprintf vibe_test_vprintf
#define vfprintf vibe_test_vfprintf
#define vsprintf vibe_test_vsprintf
#define vsnprintf vibe_test_vsnprintf
#define sscanf vibe_test_sscanf
#define fscanf vibe_test_fscanf
#define clock vibe_test_clock
#define time vibe_test_time

#include "../../doom_port/libc.c"

#define MOCK_FILE_CAPACITY 128
#define MOCK_MAX_FDS 8

struct mock_fd {
    int used;
    int pos;
    int flags;
    int fd_flags;
};

static unsigned char mock_file_data[MOCK_FILE_CAPACITY];
static int mock_file_size;
static int mock_file_exists;
static struct mock_fd mock_fds[MOCK_MAX_FDS];
static int mock_close_count;
static int mock_exec_count;
static int mock_exec_argc;
static int mock_exec_envc;
static char mock_exec_path[32];
static char mock_exec_argv0[32];
static unsigned long mock_clock_milliseconds;
static vibe_input_event_t mock_input_event;
static int mock_input_queued;
static int mock_present_count;
static unsigned long mock_present_width;
static unsigned long mock_present_height;
static int mock_fb_supports_indexed;
static int mock_fb_fixed_present_size;
static unsigned long mock_fb_max_width;
static unsigned long mock_fb_max_height;
static int mock_audio_started;
static int mock_audio_playing;
static unsigned long mock_audio_handle;
static vibe_audio_voice_desc_t mock_audio_voice;
static int mock_audio_update_count;

static int fail(int code)
{
    return code;
}

static void copy_text(char* dest, const char* src, int capacity)
{
    int i = 0;
    while (i + 1 < capacity && src && src[i]) {
        dest[i] = src[i];
        ++i;
    }
    dest[i] = 0;
}

static void reset_mock(void)
{
    memset(mock_file_data, 0, sizeof(mock_file_data));
    memset(mock_fds, 0, sizeof(mock_fds));
    mock_file_size = 0;
    mock_file_exists = 0;
    mock_close_count = 0;
    mock_exec_count = 0;
    mock_exec_argc = 0;
    mock_exec_envc = 0;
    mock_exec_path[0] = 0;
    mock_exec_argv0[0] = 0;
    mock_clock_milliseconds = 12345;
    memset(&mock_input_event, 0, sizeof(mock_input_event));
    mock_input_queued = 0;
    mock_present_count = 0;
    mock_present_width = 0;
    mock_present_height = 0;
    mock_fb_supports_indexed = 1;
    mock_fb_fixed_present_size = 1;
    mock_fb_max_width = 320;
    mock_fb_max_height = 200;
    mock_audio_started = 0;
    mock_audio_playing = 0;
    mock_audio_handle = 0;
    memset(&mock_audio_voice, 0, sizeof(mock_audio_voice));
    mock_audio_update_count = 0;
    errno = 0;
}

static int alloc_fd(int flags)
{
    int fd;
    for (fd = 3; fd < MOCK_MAX_FDS; ++fd) {
        if (!mock_fds[fd].used) {
            mock_fds[fd].used = 1;
            mock_fds[fd].flags = flags;
            mock_fds[fd].pos = (flags & O_APPEND) ? mock_file_size : 0;
            return fd;
        }
    }
    return -EMFILE;
}

static int can_read_fd(int fd)
{
    int flags = mock_fds[fd].flags;
    return (flags & O_RDWR) == O_RDWR || !(flags & O_WRONLY);
}

static int can_write_fd(int fd)
{
    int flags = mock_fds[fd].flags;
    return (flags & O_RDWR) == O_RDWR || (flags & O_WRONLY);
}

static void fill_stat(struct stat* out)
{
    memset(out, 0, sizeof(*out));
    out->st_mode = S_IFREG | S_IRUSR | S_IWUSR;
    out->st_size = mock_file_size;
    out->st_nlink = 1;
}

int vibe_syscall3(unsigned int number, unsigned long arg0, unsigned long arg1, unsigned long arg2)
{
    if (number == VIBE_SYS_OPEN) {
        const char* path = (const char*)arg0;
        int flags = (int)arg1;
        (void)arg2;
        if (!path)
            return -EINVAL;
        if (!mock_file_exists) {
            if (!(flags & O_CREAT))
                return -ENOENT;
            mock_file_exists = 1;
        }
        if (flags & O_TRUNC)
            mock_file_size = 0;
        return alloc_fd(flags);
    }

    if (number == VIBE_SYS_WRITE) {
        int fd = (int)arg0;
        const unsigned char* data = (const unsigned char*)arg1;
        int count = (int)arg2;
        int room;
        if (fd < 0 || fd >= MOCK_MAX_FDS || !mock_fds[fd].used || !can_write_fd(fd))
            return -EBADF;
        if (!data && count)
            return -EINVAL;
        if (mock_fds[fd].flags & O_APPEND)
            mock_fds[fd].pos = mock_file_size;
        room = MOCK_FILE_CAPACITY - mock_fds[fd].pos;
        if (count > room)
            count = room;
        if (count < 0)
            count = 0;
        memcpy(mock_file_data + mock_fds[fd].pos, data, (size_t)count);
        mock_fds[fd].pos += count;
        if (mock_fds[fd].pos > mock_file_size)
            mock_file_size = mock_fds[fd].pos;
        return count;
    }

    if (number == VIBE_SYS_READ) {
        int fd = (int)arg0;
        unsigned char* data = (unsigned char*)arg1;
        int count = (int)arg2;
        int available;
        if (fd < 0 || fd >= MOCK_MAX_FDS || !mock_fds[fd].used || !can_read_fd(fd))
            return -EBADF;
        if (!data && count)
            return -EINVAL;
        available = mock_file_size - mock_fds[fd].pos;
        if (count > available)
            count = available;
        if (count < 0)
            count = 0;
        memcpy(data, mock_file_data + mock_fds[fd].pos, (size_t)count);
        mock_fds[fd].pos += count;
        return count;
    }

    if (number == VIBE_SYS_LSEEK) {
        int fd = (int)arg0;
        int offset = (int)arg1;
        int whence = (int)arg2;
        int base;
        if (fd < 0 || fd >= MOCK_MAX_FDS || !mock_fds[fd].used)
            return -EBADF;
        if (whence == SEEK_SET)
            base = 0;
        else if (whence == SEEK_CUR)
            base = mock_fds[fd].pos;
        else if (whence == SEEK_END)
            base = mock_file_size;
        else
            return -EINVAL;
        if (base + offset < 0)
            return -EINVAL;
        mock_fds[fd].pos = base + offset;
        return mock_fds[fd].pos;
    }

    if (number == VIBE_SYS_CLOSE) {
        int fd = (int)arg0;
        if (fd < 0 || fd >= MOCK_MAX_FDS || !mock_fds[fd].used)
            return -EBADF;
        mock_fds[fd].used = 0;
        ++mock_close_count;
        return 0;
    }

    if (number == VIBE_SYS_FCNTL) {
        int fd = (int)arg0;
        int cmd = (int)arg1;
        int flags = (int)arg2;
        if (fd < 0 || fd >= MOCK_MAX_FDS || !mock_fds[fd].used)
            return -EBADF;
        if (cmd == F_GETFD)
            return mock_fds[fd].fd_flags;
        if (cmd == F_SETFD) {
            if (flags & ~FD_CLOEXEC)
                return -EINVAL;
            mock_fds[fd].fd_flags = flags;
            return 0;
        }
        return -EINVAL;
    }

    if (number == VIBE_SYS_FSTAT) {
        int fd = (int)arg0;
        struct stat* out = (struct stat*)arg1;
        if (fd < 0 || fd >= MOCK_MAX_FDS || !mock_fds[fd].used)
            return -EBADF;
        if (!out)
            return -EINVAL;
        fill_stat(out);
        return 0;
    }

    if (number == VIBE_SYS_STAT) {
        const char* path = (const char*)arg0;
        struct stat* out = (struct stat*)arg1;
        if (!path || !out)
            return -EINVAL;
        if (!strcmp(path, "/")) {
            memset(out, 0, sizeof(*out));
            out->st_mode = S_IFDIR | S_IRUSR;
            out->st_nlink = 1;
            return 0;
        }
        if (!mock_file_exists)
            return -ENOENT;
        fill_stat(out);
        return 0;
    }

    if (number == VIBE_SYS_LISTDIR) {
        const char* path = (const char*)arg0;
        vibe_dirent_t* entries = (vibe_dirent_t*)arg1;
        unsigned long max_entries = arg2;
        if (!path || strcmp(path, "/"))
            return -EINVAL;
        if (max_entries && !entries)
            return -EINVAL;
        if (!max_entries || !mock_file_exists)
            return 0;
        memset(entries, 0, sizeof(*entries));
        copy_text(entries[0].name, "TOOL.TXT", (int)sizeof(entries[0].name));
        entries[0].size = (unsigned long)mock_file_size;
        entries[0].mode = S_IFREG | S_IRUSR | S_IWUSR;
        entries[0].attributes = VIBE_DIRENT_ATTR_ARCHIVE;
        return 1;
    }

    if (number == VIBE_SYS_CLOCK_GETTIME) {
        vibe_clock_time_t* out = (vibe_clock_time_t*)arg1;
        if (arg0 != VIBE_CLOCK_MONOTONIC || !out || arg2 < sizeof(*out))
            return -EINVAL;
        out->ticks = mock_clock_milliseconds;
        out->frequency_hz = VIBE_CLOCK_MONOTONIC_HZ;
        out->milliseconds = mock_clock_milliseconds;
        out->flags = 0;
        return 0;
    }

    if (number == VIBE_SYS_POLL_INPUT) {
        vibe_input_event_t* out = (vibe_input_event_t*)arg0;
        if (!out || arg1 < sizeof(*out))
            return -EINVAL;
        if (!mock_input_queued)
            return 0;
        *out = mock_input_event;
        mock_input_queued = 0;
        return 1;
    }

    if (number == VIBE_SYS_INPUT_STATUS) {
        vibe_input_status_t* out = (vibe_input_status_t*)arg0;
        if (!out || arg1 < sizeof(*out))
            return -EINVAL;
        memset(out, 0, sizeof(*out));
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
        out->capabilities = VIBE_INPUT_CAP_KEYBOARD | VIBE_INPUT_CAP_POLL_EVENT | VIBE_INPUT_CAP_STATUS;
        out->keyboard_status = VIBE_INPUT_DEVICE_STATUS_READY;
        out->mouse_status = VIBE_INPUT_DEVICE_STATUS_UNKNOWN;
        return 0;
    }

    if (number == VIBE_SYS_INPUT_DEVICE_STATUS) {
        vibe_input_device_status_t* out = (vibe_input_device_status_t*)arg1;
        if (!out || arg2 < sizeof(*out))
            return -EINVAL;
        if (arg0 != VIBE_INPUT_DEVICE_KEYBOARD && arg0 != VIBE_INPUT_DEVICE_MOUSE)
            return -EINVAL;
        memset(out, 0, sizeof(*out));
        out->abi_version = VIBE_INPUT_ABI_VERSION;
        out->status_bytes = VIBE_INPUT_DEVICE_STATUS_BYTES;
        out->device_id = arg0;
        out->status = arg0 == VIBE_INPUT_DEVICE_KEYBOARD
            ? VIBE_INPUT_DEVICE_STATUS_READY
            : VIBE_INPUT_DEVICE_STATUS_UNKNOWN;
        out->event_count = arg0 == VIBE_INPUT_DEVICE_KEYBOARD ? 1 : 0;
        out->polled_events = 0;
        out->dropped_events = 0;
        if (arg0 == VIBE_INPUT_DEVICE_KEYBOARD) {
            out->capabilities = VIBE_INPUT_DEVICE_CAP_KEYS | VIBE_INPUT_DEVICE_CAP_STATE_SNAPSHOT;
            out->last_event_type = VIBE_INPUT_EVENT_KEY;
            out->last_code = 'z';
            out->active_state = VIBE_INPUT_MOD_SHIFT;
        } else {
            out->capabilities = VIBE_INPUT_DEVICE_CAP_RELATIVE_POINTER
                | VIBE_INPUT_DEVICE_CAP_BUTTONS
                | VIBE_INPUT_DEVICE_CAP_STATE_SNAPSHOT;
            out->last_event_type = VIBE_INPUT_EVENT_MOUSE_PACKET;
        }
        return 0;
    }

    if (number == VIBE_SYS_AUDIO) {
        unsigned long command = arg0;
        if (command == VIBE_AUDIO_DEVICE_START) {
            mock_audio_started = 1;
            return VIBE_AUDIO_DEVICE_STATUS_READY;
        }
        if (command == VIBE_AUDIO_DEVICE_SHUTDOWN) {
            mock_audio_started = 0;
            mock_audio_playing = 0;
            return VIBE_AUDIO_DEVICE_STATUS_ABSENT;
        }
        if (command == VIBE_AUDIO_MIXER_START || command == VIBE_AUDIO_MIXER_UPDATE) {
            vibe_audio_voice_desc_t* desc = (vibe_audio_voice_desc_t*)arg2;
            if (!desc)
                return -EINVAL;
            mock_audio_handle = arg1;
            mock_audio_voice = *desc;
            if (command == VIBE_AUDIO_MIXER_START)
                mock_audio_playing = 1;
            else
                ++mock_audio_update_count;
            return 0;
        }
        if (command == VIBE_AUDIO_MIXER_STOP) {
            if (arg1 == mock_audio_handle)
                mock_audio_playing = 0;
            return 0;
        }
        if (command == VIBE_AUDIO_MIXER_IS_PLAYING)
            return mock_audio_playing && arg1 == mock_audio_handle;
        if (command == VIBE_AUDIO_PCM_BUFFERED_BYTES)
            return 256;
        if (command == VIBE_AUDIO_PCM_PULL_STATE)
            return 5;
        if (command == VIBE_AUDIO_DEVICE_INFO) {
            vibe_audio_device_info_t* out = (vibe_audio_device_info_t*)arg1;
            if (!out)
                return -EINVAL;
            memset(out, 0, sizeof(*out));
            out->device_kind = VIBE_AUDIO_DEVICE_SB16;
            out->status = mock_audio_started
                ? VIBE_AUDIO_DEVICE_STATUS_READY
                : VIBE_AUDIO_DEVICE_STATUS_ABSENT;
            out->sample_rate = 11025;
            out->channels = 2;
            out->format = VIBE_AUDIO_FORMAT_U8_STEREO;
            out->ring_bytes = 32768;
            out->period_bytes = 16384;
            out->capabilities = VIBE_AUDIO_CAP_PCM_RING
                | VIBE_AUDIO_CAP_MIXER_VOICES
                | VIBE_AUDIO_CAP_PULL_STREAM;
            out->active_voices = mock_audio_playing ? 1 : 0;
            return 0;
        }
        if (command == VIBE_AUDIO_PCM_RING_INFO) {
            vibe_audio_pcm_ring_info_t* out = (vibe_audio_pcm_ring_info_t*)arg1;
            if (!out)
                return -EINVAL;
            memset(out, 0, sizeof(*out));
            out->format = VIBE_AUDIO_FORMAT_U8_STEREO;
            out->channels = 2;
            out->sample_rate = 11025;
            out->ring_bytes = 32768;
            out->period_bytes = 16384;
            out->queued_bytes = 256;
            out->mixed_bytes = 512;
            return 0;
        }
        if (command == VIBE_AUDIO_STREAM_INFO) {
            vibe_audio_stream_info_t* out = (vibe_audio_stream_info_t*)arg2;
            if (!out)
                return -EINVAL;
            memset(out, 0, sizeof(*out));
            out->stream_mode = VIBE_AUDIO_MUSIC_STREAM_PULL;
            out->flags = VIBE_AUDIO_STREAM_FLAG_PULL | VIBE_AUDIO_STREAM_FLAG_REFILL_PENDING;
            out->handle = arg1;
            out->pull_request_count = 5;
            out->pull_refill_count = 4;
            out->pending_pull_requests = 1;
            out->queued_bytes = 256;
            return 0;
        }
        return -EINVAL;
    }

    if (number == VIBE_SYS_IOCTL) {
        if (arg0 != VIBE_DISPLAY_FD)
            return -ENOTTY;
        if (arg1 == VIBE_IOCTL_FBINFO) {
            vibe_fb_info_t* info = (vibe_fb_info_t*)arg2;
            if (!info)
                return -EINVAL;
            memset(info, 0, sizeof(*info));
            info->width = 640;
            info->height = 400;
            info->pitch = 640 * 4;
            info->backend = VIBE_FB_BACKEND_LFB_XRGB8888;
            info->capabilities = mock_fb_supports_indexed
                ? VIBE_FB_CAP_PRESENT_INDEXED | VIBE_FB_CAP_PRESENT_RGB_PALETTE
                : 0;
            if (mock_fb_supports_indexed && mock_fb_fixed_present_size)
                info->capabilities |= VIBE_FB_CAP_FIXED_PRESENT_SIZE;
            info->present_format = mock_fb_supports_indexed ? VIBE_FB_FORMAT_INDEX8_RGB24 : 0;
            info->max_present_width = mock_fb_max_width;
            info->max_present_height = mock_fb_max_height;
            return 0;
        }
        if (arg1 == VIBE_IOCTL_PRESENT_INDEXED) {
            vibe_present_indexed_t* present = (vibe_present_indexed_t*)arg2;
            if (!present || !present->frame || !present->palette || !present->width || !present->height)
                return -EINVAL;
            if (mock_fb_supports_indexed) {
                if (mock_fb_fixed_present_size
                    && (present->width != mock_fb_max_width || present->height != mock_fb_max_height))
                    return -EINVAL;
                if (!mock_fb_fixed_present_size && mock_fb_max_width && present->width > mock_fb_max_width)
                    return -EINVAL;
                if (!mock_fb_fixed_present_size && mock_fb_max_height && present->height > mock_fb_max_height)
                    return -EINVAL;
            }
            ++mock_present_count;
            mock_present_width = present->width;
            mock_present_height = present->height;
            return 0;
        }
        return -ENOTTY;
    }

    if (number == VIBE_SYS_EXEC) {
        const char* path = (const char*)arg0;
        char* const* argv = (char* const*)arg1;
        char* const* envp = (char* const*)arg2;
        int argc = 0;
        int envc = 0;
        if (!path)
            return -EINVAL;
        ++mock_exec_count;
        copy_text(mock_exec_path, path, (int)sizeof(mock_exec_path));
        mock_exec_argv0[0] = 0;
        if (argv) {
            while (argv[argc]) {
                if (argc == 0)
                    copy_text(mock_exec_argv0, argv[argc], (int)sizeof(mock_exec_argv0));
                ++argc;
            }
        }
        mock_exec_argc = argc;
        if (envp) {
            while (envp[envc])
                ++envc;
        }
        mock_exec_envc = envc;
        return 0;
    }

    if (number == VIBE_SYS_FORK || number == VIBE_SYS_WAITPID)
        return -ENOSYS;
    if (number == VIBE_SYS_GETPID)
        return 7;
    if (number == VIBE_SYS_UNLINK || number == VIBE_SYS_FTRUNCATE)
        return -ENOSYS;
    return -ENOSYS;
}

static int test_stdio_flush_all_and_descriptor_lifecycle(void)
{
    FILE* first;
    FILE* second;
    struct stat st;
    char buffer[8];

    reset_mock();
    first = fopen("tool.txt", "w");
    if (!first)
        return fail(10);
    if (fwrite("ab", 1, 2, first) != 2)
        return fail(11);
    if (stat("tool.txt", &st) != 0 || st.st_size != 0)
        return fail(12);
    if (fflush(NULL) != 0)
        return fail(13);
    if (stat("tool.txt", &st) != 0 || st.st_size != 2 || !S_ISREG(st.st_mode))
        return fail(14);
    if (fclose(first) != 0 || mock_close_count != 1)
        return fail(15);

    second = fopen("tool.txt", "r");
    if (!second)
        return fail(16);
    if (fread(buffer, 1, 2, second) != 2)
        return fail(17);
    if (buffer[0] != 'a' || buffer[1] != 'b')
        return fail(18);
    if (fclose(second) != 0 || mock_close_count != 2)
        return fail(19);
    if (fclose(second) != EOF || errno != EBADF)
        return fail(20);
    return 0;
}

static int test_stdio_character_and_line_helpers(void)
{
    FILE* file;
    char line[16];
    char block[4];
    char next;
    unsigned int scanned;
    int ivalue;

    reset_mock();
    file = fopen("tool.txt", "w+");
    if (!file)
        return fail(97);
    if (fputs("alpha\nbeta", file) != 0)
        return fail(98);
    if (putc('\n', file) != '\n')
        return fail(99);
    if (fseek(file, 0, SEEK_SET) != 0)
        return fail(100);
    if (fgetc(file) != 'a')
        return fail(101);
    if (ftell(file) != 1)
        return fail(109);
    if (ungetc('a', file) != 'a')
        return fail(102);
    if (ftell(file) != 0)
        return fail(110);
    memset(block, 0, sizeof(block));
    if (fread(block, 1, 2, file) != 2 || block[0] != 'a' || block[1] != 'l')
        return fail(111);
    if (ftell(file) != 2)
        return fail(112);
    rewind(file);
    if (ftell(file) != 0 || feof(file) || ferror(file))
        return fail(113);
    if (fgetc(file) != 'a')
        return fail(114);
    if (ungetc('a', file) != 'a')
        return fail(115);
    if (getc(file) != 'a')
        return fail(103);
    if (!fgets(line, sizeof(line), file) || strcmp(line, "lpha\n") != 0)
        return fail(104);
    if (!fgets(line, sizeof(line), file) || strcmp(line, "beta\n") != 0)
        return fail(105);
    if (fgets(line, sizeof(line), file) != 0 || !feof(file))
        return fail(106);
    if (ungetc(EOF, file) != EOF)
        return fail(107);
    if (fclose(file) != 0)
        return fail(108);

    reset_mock();
    file = fopen("scan.txt", "w+");
    if (!file)
        return fail(116);
    if (fputs("123 128 077z abc", file) != 0 || fseek(file, 0, SEEK_SET) != 0)
        return fail(117);
    scanned = 0;
    next = 0;
    if (fscanf(file, "%2u%c", &scanned, &next) != 2 || scanned != 12u || next != '3')
        return fail(118);
    scanned = 0;
    next = 0;
    if (fscanf(file, " %3o%c", &scanned, &next) != 2 || scanned != 10u || next != '8')
        return fail(119);
    ivalue = 0;
    next = 0;
    if (fscanf(file, " %i%c", &ivalue, &next) != 2 || ivalue != 63 || next != 'z')
        return fail(120);
    memset(block, 0, sizeof(block));
    if (fscanf(file, "%3c", block) != 1
        || block[0] != ' '
        || block[1] != 'a'
        || block[2] != 'b')
        return fail(121);
    if (fclose(file) != 0)
        return fail(122);

    reset_mock();
    mock_fds[2].used = 1;
    mock_fds[2].flags = O_WRONLY;
    errno = ENOENT;
    perror("load");
    if (errno != ENOENT || strcmp((const char*)mock_file_data, "load: No such file or directory\n") != 0)
        return fail(123);
    return 0;
}

static int test_stat_directory_listdir_and_clock_contracts(void)
{
    FILE* file;
    struct stat st;
    vibe_dirent_t entries[2];
    struct timespec ts;
    vibe_clock_time_t now;
    time_t wall_time;
    unsigned long file_size;
    unsigned long read_size;
    char read_buffer[8];
    unsigned char* mapped;
    int fd;

    reset_mock();
    if (stat("/", &st) != 0 || !S_ISDIR(st.st_mode) || S_ISREG(st.st_mode))
        return fail(30);
    if (vibe_file_size("/", &file_size) != -1 || errno != EISDIR)
        return fail(29);
    if (vibe_listdir("/", entries, 2) != 0)
        return fail(31);
    if (vibe_listdir("missing", entries, 2) != -1 || errno != EINVAL)
        return fail(32);
    file = fopen("tool.txt", "w");
    if (!file)
        return fail(33);
    if (fwrite("game", 1, 4, file) != 4 || fflush(file) != 0)
        return fail(28);
    if (vibe_file_size("tool.txt", &file_size) != 0 || file_size != 4)
        return fail(27);
    memset(read_buffer, 0, sizeof(read_buffer));
    if (vibe_file_read_all("tool.txt", read_buffer, sizeof(read_buffer), &read_size) != 0)
        return fail(26);
    if (read_size != 4 || strcmp(read_buffer, "game"))
        return fail(25);
    if (vibe_file_read_all("tool.txt", read_buffer, 3, &read_size) != -1
        || errno != ENOSPC
        || read_size != 4)
        return fail(24);
    fd = open("tool.txt", O_RDWR);
    if (fd < 0)
        return fail(73);
    if (lseek(fd, 0, SEEK_END) != 4)
        return fail(74);
    memset(read_buffer, 0, sizeof(read_buffer));
    if (pread(fd, read_buffer, 2, 1) != 2 || read_buffer[0] != 'a' || read_buffer[1] != 'm')
        return fail(75);
    if (lseek(fd, 0, SEEK_CUR) != 4)
        return fail(76);
    if (pwrite(fd, "XY", 2, 1) != 2)
        return fail(77);
    if (lseek(fd, 0, SEEK_CUR) != 4)
        return fail(78);
    memset(read_buffer, 0, sizeof(read_buffer));
    if (vibe_file_read_at("tool.txt", 0, read_buffer, 4, &read_size) != 0
        || read_size != 4
        || strcmp(read_buffer, "gXYe"))
        return fail(79);
    if (vibe_file_read_at("tool.txt", 0x80000000ul, read_buffer, 1, &read_size) != -1
        || errno != EOVERFLOW)
        return fail(80);
    if (pread(fd, read_buffer, 1, -1) != -1 || errno != EINVAL)
        return fail(81);
    mapped = mmap(0, 8, PROT_READ | PROT_WRITE, MAP_PRIVATE, fd, 1);
    if (mapped == MAP_FAILED)
        return fail(111);
    if (mapped[0] != 'X' || mapped[1] != 'Y' || mapped[2] != 'e'
        || mapped[3] != 0 || mapped[7] != 0)
        return fail(112);
    mapped[0] = 'q';
    memset(read_buffer, 0, sizeof(read_buffer));
    if (pread(fd, read_buffer, 1, 1) != 1 || read_buffer[0] != 'X')
        return fail(113);
    if (lseek(fd, 0, SEEK_CUR) != 4)
        return fail(114);
    if (munmap(mapped, 8) != 0)
        return fail(115);
    if (mmap(0, 4, PROT_READ, MAP_SHARED, fd, 0) != MAP_FAILED || errno != ENOSYS)
        return fail(116);
    if (close(fd) != 0)
        return fail(82);
    if (fcntl(file->fd, F_GETFD) != 0)
        return fail(21);
    if (fcntl(file->fd, F_SETFD, FD_CLOEXEC) != 0)
        return fail(20);
    if (fcntl(file->fd, F_GETFD) != FD_CLOEXEC)
        return fail(19);
    if (fcntl(file->fd, F_SETFD, FD_CLOEXEC | 0x10) != -1 || errno != EINVAL)
        return fail(18);
    if (vibe_listdir("/", entries, 2) != 1)
        return fail(34);
    if (!vibe_dirent_is_regular_file(&entries[0]) || vibe_dirent_is_directory(&entries[0]))
        return fail(35);
    if (fclose(file) != 0)
        return fail(36);
    if (clock_gettime(CLOCK_MONOTONIC, &ts) != 0)
        return fail(37);
    if (ts.tv_sec != 12 || ts.tv_nsec != 345000000)
        return fail(38);
    if (clock() != 12345)
        return fail(109);
    errno = 0;
    wall_time = 0;
    if (time(&wall_time) != (time_t)-1 || wall_time != (time_t)-1 || errno != ENOSYS)
        return fail(110);
    if (vibe_clock_monotonic(&now) != 0
        || now.milliseconds != 12345
        || vibe_clock_ticks_to_milliseconds(12345, VIBE_CLOCK_MONOTONIC_HZ) != 123450)
        return fail(23);
    if (clock_gettime(0, &ts) != -1 || errno != EINVAL)
        return fail(39);
    if (vibe_syscall_errno(-EACCES, EIO) != EACCES
        || vibe_syscall_errno(-1, ENOENT) != ENOENT
        || vibe_syscall_errno(5, EIO) != 0)
        return fail(22);
    return 0;
}

static int test_empty_environment_and_execve_contract(void)
{
    char* argv[3];
    char* empty_env[1];
    char* nonempty_env[2];

    reset_mock();
    if (!environ || environ[0])
        return fail(40);

    argv[0] = "tool.elf";
    argv[1] = "--dry-run";
    argv[2] = 0;
    empty_env[0] = 0;
    nonempty_env[0] = "HOME=/";
    nonempty_env[1] = 0;

    if (execve("tool.elf", argv, empty_env) != 0)
        return fail(41);
    if (mock_exec_count != 1 || mock_exec_argc != 2 || mock_exec_envc != 0)
        return fail(42);
    if (strcmp(mock_exec_path, "tool.elf") || strcmp(mock_exec_argv0, "tool.elf"))
        return fail(43);
    if (execve("tool.elf", argv, nonempty_env) != 0)
        return fail(44);
    if (mock_exec_count != 2 || mock_exec_argc != 2 || mock_exec_envc != 1)
        return fail(45);
    return 0;
}

static int test_generic_input_and_indexed_present_wrappers(void)
{
    vibe_input_event_t events[2];
    vibe_input_status_t status;
    vibe_input_device_status_t device_status;
    vibe_fb_info_t info;
    vibe_present_indexed_t present;
    unsigned char frame[320 * 200];
    unsigned char palette[VIBE_FB_RGB24_PALETTE_BYTES];

    reset_mock();
    vibe_input_make_key_event(&mock_input_event, 77, 'z', VIBE_INPUT_KEY_PRESSED);
    mock_input_queued = 1;

    if (vibe_input_status(&status) != 0)
        return fail(50);
    if (status.abi_version != VIBE_INPUT_ABI_VERSION
        || status.event_bytes != VIBE_INPUT_EVENT_BYTES
        || status.queue_capacity != VIBE_INPUT_EVENT_QUEUE_CAPACITY
        || status.queued_events != 1
        || !vibe_input_status_has_capability(&status, VIBE_INPUT_CAP_POLL_EVENT)
        || vibe_input_status_queue_is_empty(&status)
        || vibe_input_status_available_events(&status) != 62
        || !vibe_input_status_uses_drop_oldest(&status)
        || !vibe_input_status_keyboard_is_ready(&status)
        || vibe_input_status_mouse_is_ready(&status)
        || !vibe_input_status_counters_are_consistent(&status))
        return fail(51);
    if (vibe_input_device_status(VIBE_INPUT_DEVICE_KEYBOARD, &device_status) != 0
        || !vibe_input_device_record_is_ready(&device_status)
        || !vibe_input_device_status_has_capability(&device_status, VIBE_INPUT_DEVICE_CAP_KEYS)
        || vibe_input_device_status_keyboard_modifiers(&device_status) != VIBE_INPUT_MOD_SHIFT)
        return fail(97);

    if (vibe_drain_input(events, 2) != 1)
        return fail(52);
    if (!vibe_input_event_is_key(&events[0])
        || events[0].timestamp != 77
        || events[0].code != 'z'
        || events[0].value0 != VIBE_INPUT_KEY_PRESSED)
        return fail(53);
    if (vibe_drain_input(events, 2) != 0)
        return fail(54);
    if (vibe_poll_input(0) != -1 || errno != EINVAL)
        return fail(55);
    if (vibe_input_status(0) != -1 || errno != EINVAL)
        return fail(56);
    if (vibe_input_device_status(VIBE_INPUT_DEVICE_KEYBOARD, 0) != -1 || errno != EINVAL)
        return fail(98);
    if (vibe_drain_input(0, 1) != -1 || errno != EINVAL)
        return fail(60);

    memset(frame, 1, sizeof(frame));
    memset(palette, 2, sizeof(palette));
    present.frame = frame;
    present.palette = palette;
    present.width = 320;
    present.height = 200;
    if (vibe_fb_get_info(&info) != 0)
        return fail(61);
    if (!vibe_fb_can_present_indexed(&info, &present)
        || info.max_present_width != 320
        || info.max_present_height != 200)
        return fail(62);
    if (vibe_present_indexed_checked(&present) != 0)
        return fail(57);
    if (mock_present_count != 1 || mock_present_width != 320 || mock_present_height != 200)
        return fail(58);
    present.frame = 0;
    if (vibe_present_indexed(&present) != -1 || errno != EINVAL)
        return fail(59);
    present.frame = frame;
    present.width = 319;
    if (vibe_present_indexed_checked(&present) != -1 || errno != EINVAL)
        return fail(63);

    mock_fb_fixed_present_size = 0;
    present.width = 160;
    present.height = 100;
    if (vibe_fb_get_info(&info) != 0)
        return fail(68);
    if (!vibe_fb_can_present_indexed(&info, &present))
        return fail(69);
    if (vibe_present_indexed_checked(&present) != 0)
        return fail(70);
    if (mock_present_count != 2 || mock_present_width != 160 || mock_present_height != 100)
        return fail(71);
    present.width = 321;
    present.height = 200;
    if (vibe_present_indexed_checked(&present) != -1 || errno != EINVAL)
        return fail(72);

    present.width = 320;
    present.height = 200;
    mock_fb_fixed_present_size = 1;
    mock_fb_supports_indexed = 0;
    if (vibe_present_indexed_checked(&present) != -1 || errno != ENOSYS)
        return fail(64);
    if (vibe_heap_capabilities() != (VIBE_HEAP_CAP_SBRK_GROW | VIBE_HEAP_CAP_SBRK_SHRINK))
        return fail(65);
    if (!(vibe_vm_capabilities() & VIBE_VM_CAP_ANON_PRIVATE)
        || !(vibe_vm_capabilities() & VIBE_VM_CAP_BRK_BACKED)
        || !(vibe_vm_capabilities() & VIBE_VM_CAP_FILE_PRIVATE_COPY))
        return fail(66);
    if (vibe_mmap_anon(4096, PROT_READ | PROT_WRITE) == MAP_FAILED)
        return fail(67);

    return 0;
}

static int test_generic_audio_wrappers(void)
{
    unsigned char bytes[4] = { 128, 129, 127, 128 };
    vibe_audio_voice_desc_t voice;
    vibe_audio_device_info_t device;
    vibe_audio_pcm_ring_info_t ring;
    vibe_audio_stream_info_t stream;

    reset_mock();
    vibe_audio_voice_desc_init(&voice, bytes, sizeof(bytes), 11025, 96, 128, 128);

    if (vibe_audio_device_start() != VIBE_AUDIO_DEVICE_STATUS_READY || !mock_audio_started)
        return fail(83);
    if (vibe_audio_mixer_start(42, &voice) != 0 || !mock_audio_playing)
        return fail(84);
    if (mock_audio_handle != 42
        || mock_audio_voice.samples != bytes
        || mock_audio_voice.length != sizeof(bytes)
        || mock_audio_voice.sample_rate != 11025)
        return fail(85);
    voice.volume = 64;
    if (vibe_audio_mixer_update(42, &voice) != 0 || mock_audio_update_count != 1)
        return fail(86);
    if (vibe_audio_mixer_is_playing(42) != 1)
        return fail(87);
    if (vibe_audio_pcm_buffered_bytes(42) != 256)
        return fail(88);
    if (vibe_audio_pcm_pull_state(42) != 5)
        return fail(89);
    if (vibe_audio_device_info(&device) != 0
        || !vibe_audio_device_is_ready(&device)
        || !vibe_audio_device_has_capability(&device, VIBE_AUDIO_CAP_PULL_STREAM))
        return fail(90);
    if (vibe_audio_pcm_ring_info(&ring) != 0 || !vibe_audio_pcm_ring_is_u8_stereo(&ring))
        return fail(91);
    if (vibe_audio_stream_info(42, &stream) != 0
        || !vibe_audio_stream_matches_handle(&stream, 42)
        || !vibe_audio_stream_has_new_refill_request(&stream, 4))
        return fail(92);
    if (vibe_audio_mixer_stop(42) != 0 || vibe_audio_mixer_is_playing(42) != 0)
        return fail(93);
    if (vibe_audio_mixer_start(43, 0) != -1 || errno != EINVAL)
        return fail(94);
    if (vibe_audio_device_info(0) != -1 || errno != EINVAL)
        return fail(95);
    if (vibe_audio_device_shutdown() != VIBE_AUDIO_DEVICE_STATUS_ABSENT || mock_audio_started)
        return fail(96);

    return 0;
}

int main(void)
{
    int result;

    vibe_libc_host_heap_reset();
    result = test_stdio_flush_all_and_descriptor_lifecycle();
    if (result)
        return result;

    result = test_stdio_character_and_line_helpers();
    if (result)
        return result;

    result = test_stat_directory_listdir_and_clock_contracts();
    if (result)
        return result;

    result = test_empty_environment_and_execve_contract();
    if (result)
        return result;

    result = test_generic_input_and_indexed_present_wrappers();
    if (result)
        return result;

    result = test_generic_audio_wrappers();
    if (result)
        return result;

    return 0;
}
