#define VIBE_LIBC_HOST_TEST 1

#define stdin vibe_test_stdin
#define stdout vibe_test_stdout
#define stderr vibe_test_stderr
#define environ vibe_test_environ
#define abs vibe_test_abs
#define atoi vibe_test_atoi
#define atol vibe_test_atol
#define malloc vibe_test_malloc
#define calloc vibe_test_calloc
#define realloc vibe_test_realloc
#define free vibe_test_free
#define _exit vibe_test__exit
#define exit vibe_test_exit
#define getenv vibe_test_getenv
#define rand vibe_test_rand
#define srand vibe_test_srand
#define memcpy vibe_test_memcpy
#define memmove vibe_test_memmove
#define memset vibe_test_memset
#define memcmp vibe_test_memcmp
#define strlen vibe_test_strlen
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
#define strdup vibe_test_strdup
#define open vibe_test_open
#define read vibe_test_read
#define write vibe_test_write
#define close vibe_test_close
#define lseek vibe_test_lseek
#define ftruncate vibe_test_ftruncate
#define truncate vibe_test_truncate
#define clock_gettime vibe_test_clock_gettime
#define access vibe_test_access
#define unlink vibe_test_unlink
#define remove vibe_test_remove
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
#define fseek vibe_test_fseek
#define ftell vibe_test_ftell
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

#include "../../doom_port/libc.c"

#define MOCK_FILE_CAPACITY 128
#define MOCK_MAX_FDS 8

struct mock_fd {
    int used;
    int pos;
    int flags;
};

static unsigned char mock_file_data[MOCK_FILE_CAPACITY];
static int mock_file_size;
static int mock_file_exists;
static struct mock_fd mock_fds[MOCK_MAX_FDS];
static int mock_close_count;
static int mock_exec_count;
static int mock_exec_argc;
static char mock_exec_path[32];
static char mock_exec_argv0[32];
static unsigned long mock_clock_milliseconds;
static vibe_input_event_t mock_input_event;
static int mock_input_queued;
static int mock_present_count;
static unsigned long mock_present_width;
static unsigned long mock_present_height;
static int mock_fb_supports_indexed;
static unsigned long mock_fb_max_width;
static unsigned long mock_fb_max_height;

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
    mock_exec_path[0] = 0;
    mock_exec_argv0[0] = 0;
    mock_clock_milliseconds = 12345;
    memset(&mock_input_event, 0, sizeof(mock_input_event));
    mock_input_queued = 0;
    mock_present_count = 0;
    mock_present_width = 0;
    mock_present_height = 0;
    mock_fb_supports_indexed = 1;
    mock_fb_max_width = 320;
    mock_fb_max_height = 200;
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
        out->queued_events = mock_input_queued ? 1 : 0;
        out->capabilities = VIBE_INPUT_CAP_KEYBOARD | VIBE_INPUT_CAP_POLL_EVENT | VIBE_INPUT_CAP_STATUS;
        return 0;
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
            info->present_format = mock_fb_supports_indexed ? VIBE_FB_FORMAT_INDEX8_RGB24 : 0;
            info->max_present_width = mock_fb_max_width;
            info->max_present_height = mock_fb_max_height;
            return 0;
        }
        if (arg1 == VIBE_IOCTL_PRESENT_INDEXED) {
            vibe_present_indexed_t* present = (vibe_present_indexed_t*)arg2;
            if (!present || !present->frame || !present->palette || !present->width || !present->height)
                return -EINVAL;
            if (mock_fb_max_width && present->width > mock_fb_max_width)
                return -EINVAL;
            if (mock_fb_max_height && present->height > mock_fb_max_height)
                return -EINVAL;
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
        int argc = 0;
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

static int test_stat_directory_listdir_and_clock_contracts(void)
{
    FILE* file;
    struct stat st;
    vibe_dirent_t entries[2];
    struct timespec ts;
    vibe_clock_time_t now;
    unsigned long file_size;
    unsigned long read_size;
    char read_buffer[8];

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
    if (mock_exec_count != 1 || mock_exec_argc != 2)
        return fail(42);
    if (strcmp(mock_exec_path, "tool.elf") || strcmp(mock_exec_argv0, "tool.elf"))
        return fail(43);
    if (execve("tool.elf", argv, nonempty_env) != -1 || errno != ENOSYS)
        return fail(44);
    return 0;
}

static int test_generic_input_and_indexed_present_wrappers(void)
{
    vibe_input_event_t events[2];
    vibe_input_status_t status;
    vibe_fb_info_t info;
    vibe_present_indexed_t present;
    unsigned char frame[4];
    unsigned char palette[3];

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
        || vibe_input_status_queue_is_empty(&status))
        return fail(51);

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
    if (vibe_drain_input(0, 1) != -1 || errno != EINVAL)
        return fail(60);

    memset(frame, 1, sizeof(frame));
    memset(palette, 2, sizeof(palette));
    present.frame = frame;
    present.palette = palette;
    present.width = 2;
    present.height = 2;
    if (vibe_fb_get_info(&info) != 0)
        return fail(61);
    if (!vibe_fb_can_present_indexed(&info, &present)
        || info.max_present_width != 320
        || info.max_present_height != 200)
        return fail(62);
    if (vibe_present_indexed_checked(&present) != 0)
        return fail(57);
    if (mock_present_count != 1 || mock_present_width != 2 || mock_present_height != 2)
        return fail(58);
    present.frame = 0;
    if (vibe_present_indexed(&present) != -1 || errno != EINVAL)
        return fail(59);
    present.frame = frame;
    present.width = 321;
    if (vibe_present_indexed_checked(&present) != -1 || errno != EINVAL)
        return fail(63);
    present.width = 2;
    mock_fb_supports_indexed = 0;
    if (vibe_present_indexed_checked(&present) != -1 || errno != ENOSYS)
        return fail(64);
    if (vibe_heap_capabilities() != (VIBE_HEAP_CAP_SBRK_GROW | VIBE_HEAP_CAP_SBRK_SHRINK))
        return fail(65);
    if (!(vibe_vm_capabilities() & VIBE_VM_CAP_ANON_PRIVATE)
        || !(vibe_vm_capabilities() & VIBE_VM_CAP_BRK_BACKED))
        return fail(66);
    if (vibe_mmap_anon(4096, PROT_READ | PROT_WRITE) == MAP_FAILED)
        return fail(67);

    return 0;
}

int main(void)
{
    int result;

    vibe_libc_host_heap_reset();
    result = test_stdio_flush_all_and_descriptor_lifecycle();
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

    return 0;
}
