#define VIBE_LIBC_HOST_TEST 1

#define stdin vibe_test_stdin
#define stdout vibe_test_stdout
#define stderr vibe_test_stderr
#define abs vibe_test_abs
#define atoi vibe_test_atoi
#define atol vibe_test_atol
#define malloc vibe_test_malloc
#define calloc vibe_test_calloc
#define realloc vibe_test_realloc
#define free vibe_test_free
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
#define access vibe_test_access
#define unlink vibe_test_unlink
#define remove vibe_test_remove
#define mmap vibe_test_mmap
#define munmap vibe_test_munmap
#define ioctl vibe_test_ioctl
#define fork vibe_test_fork
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

#define MOCK_MAX_FILES 8
#define MOCK_MAX_FDS 16
#define MOCK_FILE_CAPACITY 2048

struct mock_file {
    char path[64];
    unsigned char data[MOCK_FILE_CAPACITY];
    int size;
    int exists;
    int open_count;
    int close_count;
    int last_flags;
    int last_mode;
};

struct mock_fd {
    int used;
    int file_index;
    int pos;
    int flags;
};

static struct mock_file mock_files[MOCK_MAX_FILES];
static struct mock_fd mock_fds[MOCK_MAX_FDS];
static int mock_open_syscalls;
static int mock_read_syscalls;
static int mock_write_syscalls;
static int mock_lseek_syscalls;
static int mock_close_syscalls;
static int mock_unlink_syscalls;
static int mock_stat_syscalls;
static int mock_fstat_syscalls;
static int mock_ioctl_syscalls;
static int mock_present_count;

static void mock_copy_text(char* dest, const char* src, int capacity)
{
    int i = 0;
    while (i + 1 < capacity && src[i]) {
        dest[i] = src[i];
        ++i;
    }
    dest[i] = 0;
}

static void mock_reset(void)
{
    memset(mock_files, 0, sizeof(mock_files));
    memset(mock_fds, 0, sizeof(mock_fds));
    mock_open_syscalls = 0;
    mock_read_syscalls = 0;
    mock_write_syscalls = 0;
    mock_lseek_syscalls = 0;
    mock_close_syscalls = 0;
    mock_unlink_syscalls = 0;
    mock_stat_syscalls = 0;
    mock_fstat_syscalls = 0;
    mock_ioctl_syscalls = 0;
    mock_present_count = 0;
    errno = 0;
}

static int mock_find_file(const char* path)
{
    int i;
    for (i = 0; i < MOCK_MAX_FILES; ++i)
        if (mock_files[i].exists && !strcasecmp(mock_files[i].path, path))
            return i;
    return -1;
}

static int mock_create_file(const char* path)
{
    int i;
    for (i = 0; i < MOCK_MAX_FILES; ++i) {
        if (!mock_files[i].exists) {
            mock_files[i].exists = 1;
            mock_files[i].size = 0;
            mock_copy_text(mock_files[i].path, path, (int)sizeof(mock_files[i].path));
            return i;
        }
    }
    return -1;
}

static int mock_seed_file(const char* path, const char* content)
{
    int file_index = mock_create_file(path);
    int len = (int)strlen(content);
    if (file_index < 0 || len > MOCK_FILE_CAPACITY)
        return -1;
    memcpy(mock_files[file_index].data, content, (size_t)len);
    mock_files[file_index].size = len;
    return file_index;
}

static int mock_is_protected_file(const char* path)
{
    return !strcasecmp(path, "DOOM1.WAD")
        || !strcasecmp(path, "USERPROB.ELF")
        || !strcasecmp(path, "DOOM.ELF");
}

static void mock_fill_stat(struct stat* out, const struct mock_file* file)
{
    memset(out, 0, sizeof(*out));
    out->st_size = file->size;
    out->st_mode = S_IFREG | S_IRUSR;
    if (!mock_is_protected_file(file->path))
        out->st_mode |= S_IWUSR;
    out->st_nlink = 1;
}

static int mock_alloc_fd(int file_index, int flags)
{
    int fd;
    for (fd = 3; fd < MOCK_MAX_FDS; ++fd) {
        if (!mock_fds[fd].used) {
            mock_fds[fd].used = 1;
            mock_fds[fd].file_index = file_index;
            mock_fds[fd].flags = flags;
            mock_fds[fd].pos = (flags & O_APPEND) ? mock_files[file_index].size : 0;
            return fd;
        }
    }
    return -1;
}

static int mock_fd_can_read(int fd)
{
    int flags = mock_fds[fd].flags;
    return (flags & O_RDWR) == O_RDWR || !(flags & O_WRONLY);
}

static int mock_fd_can_write(int fd)
{
    int flags = mock_fds[fd].flags;
    return (flags & O_RDWR) == O_RDWR || (flags & O_WRONLY);
}

int vibe_syscall3(unsigned int number, unsigned long arg0, unsigned long arg1, unsigned long arg2)
{
    if (number == VIBE_SYS_OPEN) {
        const char* path = (const char*)arg0;
        int flags = (int)arg1;
        int mode = (int)arg2;
        int file_index;
        int fd;
        ++mock_open_syscalls;
        if (!strcasecmp(path, "denied.txt"))
            return -EACCES;
        if (mock_is_protected_file(path)
            && (flags & (O_WRONLY | O_RDWR | O_CREAT | O_TRUNC | O_APPEND)))
            return -EACCES;
        file_index = mock_find_file(path);
        if (file_index < 0) {
            if (!(flags & O_CREAT))
                return -ENOENT;
            file_index = mock_create_file(path);
            if (file_index < 0)
                return -EMFILE;
        }
        if ((flags & O_TRUNC) && ((flags & O_WRONLY) || (flags & O_RDWR)))
            mock_files[file_index].size = 0;
        mock_files[file_index].last_flags = flags;
        mock_files[file_index].last_mode = mode;
        ++mock_files[file_index].open_count;
        fd = mock_alloc_fd(file_index, flags);
        return fd < 0 ? -EMFILE : fd;
    }

    if (number == VIBE_SYS_READ) {
        int fd = (int)arg0;
        unsigned char* out = (unsigned char*)arg1;
        int count = (int)arg2;
        struct mock_file* file;
        int available;
        ++mock_read_syscalls;
        if (fd < 0 || fd >= MOCK_MAX_FDS || !mock_fds[fd].used || !mock_fd_can_read(fd))
            return -EBADF;
        file = &mock_files[mock_fds[fd].file_index];
        available = file->size - mock_fds[fd].pos;
        if (available < 0)
            available = 0;
        if (count > available)
            count = available;
        memcpy(out, file->data + mock_fds[fd].pos, (size_t)count);
        mock_fds[fd].pos += count;
        return count;
    }

    if (number == VIBE_SYS_WRITE) {
        int fd = (int)arg0;
        const unsigned char* in = (const unsigned char*)arg1;
        int count = (int)arg2;
        struct mock_file* file;
        ++mock_write_syscalls;
        if (fd < 0 || fd >= MOCK_MAX_FDS || !mock_fds[fd].used || !mock_fd_can_write(fd))
            return -EBADF;
        file = &mock_files[mock_fds[fd].file_index];
        if (mock_fds[fd].flags & O_APPEND)
            mock_fds[fd].pos = file->size;
        if (mock_fds[fd].pos + count > MOCK_FILE_CAPACITY)
            count = MOCK_FILE_CAPACITY - mock_fds[fd].pos;
        if (count < 0)
            count = 0;
        memcpy(file->data + mock_fds[fd].pos, in, (size_t)count);
        mock_fds[fd].pos += count;
        if (mock_fds[fd].pos > file->size)
            file->size = mock_fds[fd].pos;
        return count;
    }

    if (number == VIBE_SYS_LSEEK) {
        int fd = (int)arg0;
        int offset = (int)arg1;
        int whence = (int)arg2;
        int next;
        ++mock_lseek_syscalls;
        if (fd < 0 || fd >= MOCK_MAX_FDS || !mock_fds[fd].used)
            return -EBADF;
        if (whence == SEEK_SET)
            next = offset;
        else if (whence == SEEK_CUR)
            next = mock_fds[fd].pos + offset;
        else if (whence == SEEK_END)
            next = mock_files[mock_fds[fd].file_index].size + offset;
        else
            return -EINVAL;
        if (next < 0)
            return -EINVAL;
        mock_fds[fd].pos = next;
        return next;
    }

    if (number == VIBE_SYS_CLOSE) {
        int fd = (int)arg0;
        ++mock_close_syscalls;
        if (fd < 0 || fd >= MOCK_MAX_FDS || !mock_fds[fd].used)
            return -EBADF;
        ++mock_files[mock_fds[fd].file_index].close_count;
        mock_fds[fd].used = 0;
        return 0;
    }

    if (number == VIBE_SYS_UNLINK) {
        const char* path = (const char*)arg0;
        int file_index;
        int fd;
        ++mock_unlink_syscalls;
        if (mock_is_protected_file(path))
            return -EACCES;
        file_index = mock_find_file(path);
        if (file_index < 0)
            return -ENOENT;
        mock_files[file_index].exists = 0;
        mock_files[file_index].size = 0;
        for (fd = 3; fd < MOCK_MAX_FDS; ++fd)
            if (mock_fds[fd].used && mock_fds[fd].file_index == file_index)
                mock_fds[fd].used = 0;
        return 0;
    }

    if (number == VIBE_SYS_STAT) {
        const char* path = (const char*)arg0;
        struct stat* out = (struct stat*)arg1;
        int file_index;
        ++mock_stat_syscalls;
        file_index = mock_find_file(path);
        if (file_index < 0)
            return -ENOENT;
        mock_fill_stat(out, &mock_files[file_index]);
        return 0;
    }

    if (number == VIBE_SYS_FSTAT) {
        int fd = (int)arg0;
        struct stat* out = (struct stat*)arg1;
        ++mock_fstat_syscalls;
        if (fd < 0 || fd >= MOCK_MAX_FDS || !mock_fds[fd].used)
            return -EBADF;
        mock_fill_stat(out, &mock_files[mock_fds[fd].file_index]);
        return 0;
    }

    if (number == VIBE_SYS_IOCTL) {
        int fd = (int)arg0;
        unsigned long request = arg1;
        ++mock_ioctl_syscalls;
        if (fd != VIBE_DISPLAY_FD)
            return -ENOTTY;
        if (request == VIBE_IOCTL_FBINFO) {
            vibe_fb_info_t* info = (vibe_fb_info_t*)arg2;
            info->width = 640;
            info->height = 400;
            info->pitch = 640 * 4;
            info->backend = 2;
            info->frame_bytes = 320 * 200;
            info->palette_bytes = 256 * 3;
            return 0;
        }
        if (request == VIBE_IOCTL_PRESENT_INDEXED) {
            const vibe_present_indexed_t* present = (const vibe_present_indexed_t*)arg2;
            if (!present || !present->frame || !present->palette)
                return -EINVAL;
            if (present->width != 320 || present->height != 200)
                return -EINVAL;
            ++mock_present_count;
            return 0;
        }
        return -ENOTTY;
    }

    if (number == VIBE_SYS_FORK)
        return -ENOSYS;

    if (number == VIBE_SYS_WAITPID)
        return -ECHILD;

    return -ENOSYS;
}

static void fill_bytes(unsigned char* ptr, unsigned int count, unsigned char seed)
{
    unsigned int i;
    for (i = 0; i < count; ++i)
        ptr[i] = (unsigned char)(seed + i);
}

static int bytes_match(const unsigned char* ptr, unsigned int count, unsigned char seed)
{
    unsigned int i;
    for (i = 0; i < count; ++i)
        if (ptr[i] != (unsigned char)(seed + i))
            return 0;
    return 1;
}

static int mock_file_matches(int file_index, const char* content)
{
    int len = (int)strlen(content);
    if (file_index < 0)
        return 0;
    if (mock_files[file_index].size != len)
        return 0;
    return memcmp(mock_files[file_index].data, content, (size_t)len) == 0;
}

int main(void)
{
    unsigned char* a;
    unsigned char* b;
    unsigned char* c;
    unsigned char* grown;
    unsigned char* reused;
    size_t used;
    char text[16];
    char wad_path[32];
    char parsed_word[16];
    int parsed_value;

    vibe_libc_host_heap_reset();
    a = malloc(64);
    b = malloc(32);
    if (!a || !b)
        return 1;
    used = vibe_libc_host_heap_used();

    free(a);
    c = malloc(48);
    if (c != a)
        return 2;
    if (vibe_libc_host_heap_used() != used)
        return 3;

    free(c);
    free(b);
    c = malloc(96);
    if (c != a)
        return 4;
    if (vibe_libc_host_heap_used() != used)
        return 5;

    vibe_libc_host_heap_reset();
    a = malloc(32);
    b = malloc(64);
    if (!a || !b)
        return 6;
    used = vibe_libc_host_heap_used();
    fill_bytes(a, 32, 17);
    free(b);
    grown = realloc(a, 80);
    if (grown != a)
        return 7;
    if (!bytes_match(grown, 32, 17))
        return 8;
    if (vibe_libc_host_heap_used() != used)
        return 9;

    vibe_libc_host_heap_reset();
    a = malloc(32);
    b = malloc(32);
    if (!a || !b)
        return 10;
    fill_bytes(a, 32, 91);
    grown = realloc(a, 96);
    if (!grown || grown == a)
        return 11;
    if (!bytes_match(grown, 32, 91))
        return 12;
    reused = malloc(16);
    if (reused != a)
        return 13;

    vibe_libc_host_heap_reset();
    a = malloc(32);
    if (!a)
        return 14;
    fill_bytes(a, 32, 43);
    used = vibe_libc_host_heap_used();
    grown = realloc(a, VIBE_LIBC_HOST_HEAP_SIZE * 2);
    if (grown)
        return 15;
    if (vibe_libc_host_heap_used() != used)
        return 16;
    if (!bytes_match(a, 32, 43))
        return 17;

    if (calloc((size_t)-1, 2))
        return 18;

    sprintf(text, "STCFN%.3d", 33);
    if (strcmp(text, "STCFN033"))
        return 19;
    sprintf(text, "WILV%d%d", 1, 2);
    if (strcmp(text, "WILV12"))
        return 20;
    parsed_value = -1;
    if (sscanf("version 110", "version %i", &parsed_value) != 1 || parsed_value != 110)
        return 181;
    parsed_value = -1;
    if (sscanf("chatmacro0 \"HELLO\"", "%15s %[^\n]", parsed_word, wad_path) != 2)
        return 182;
    if (strcmp(parsed_word, "chatmacro0") || strcmp(wad_path, "\"HELLO\""))
        return 183;
    parsed_value = -1;
    if (sscanf("0x2a", "%x", &parsed_value) != 1 || parsed_value != 0x2a)
        return 184;

    mock_reset();
    if (mock_seed_file("DOOM1.WAD", "IWAD") < 0)
        return 185;
    sprintf(wad_path, "%s/doom1.wad", getenv("DOOMWADDIR"));
    if (strcmp(wad_path, "./doom1.wad"))
        return 186;
    if (access(wad_path, R_OK) != 0)
        return 187;
    {
        int file_index = mock_find_file("DOOM1.WAD");
        if (file_index < 0)
            return 188;
        if (mock_files[file_index].open_count != 1 || mock_files[file_index].close_count != 1)
            return 189;
        if (mock_files[file_index].last_flags != O_RDONLY)
            return 190;
    }
    if (strcmp(getenv("HOME"), "/"))
        return 191;

    mock_reset();
    if (mock_seed_file("default.cfg", "mouse_sensitivity\t\t9\nchatmacro0\t\t\"HELLO\"\n") < 0)
        return 21;
    {
        FILE* f = fopen("default.cfg", "r");
        char key[80];
        char value[100];
        int file_index = mock_find_file("default.cfg");
        if (!f)
            return 22;
        if (mock_files[file_index].last_flags != O_RDONLY)
            return 23;
        if (fscanf(f, "%79s %[^\n]\n", key, value) != 2)
            return 24;
        if (strcmp(key, "mouse_sensitivity") || strcmp(value, "9"))
            return 25;
        if (fscanf(f, "%79s %[^\n]\n", key, value) != 2)
            return 26;
        if (strcmp(key, "chatmacro0") || strcmp(value, "\"HELLO\""))
            return 27;
        if (fscanf(f, "%79s %[^\n]\n", key, value) != EOF)
            return 28;
        if (!feof(f))
            return 29;
        if (fclose(f) != 0)
            return 30;
        if (mock_files[file_index].close_count != 1 || mock_close_syscalls != 1)
            return 31;
    }

    mock_reset();
    if (mock_seed_file("args.rsp", "doom -file x.wad") < 0)
        return 32;
    {
        FILE* f = fopen("args.rsp", "rb");
        char buffer[16];
        int file_index = mock_find_file("args.rsp");
        if (!f)
            return 33;
        if (mock_files[file_index].last_flags != O_RDONLY)
            return 34;
        if (fseek(f, 0, SEEK_END) != 0 || ftell(f) != 16)
            return 35;
        if (fseek(f, 0, SEEK_SET) != 0)
            return 36;
        memset(buffer, 0, sizeof(buffer));
        if (fread(buffer, 16, 1, f) != 1)
            return 37;
        if (memcmp(buffer, "doom -file x.wad", 16))
            return 38;
        if (fclose(f) != 0)
            return 39;
    }

    mock_reset();
    if (mock_seed_file("default.cfg", "old") < 0)
        return 40;
    {
        FILE* f = fopen("default.cfg", "w");
        int file_index = mock_find_file("default.cfg");
        if (!f)
            return 41;
        if (mock_files[file_index].last_flags != (O_WRONLY | O_CREAT | O_TRUNC))
            return 42;
        if (mock_files[file_index].last_mode != 0666)
            return 43;
        if (fprintf(f, "%s\t\t%i\n", "screenblocks", 9) != 16)
            return 44;
        if (fclose(f) != 0)
            return 45;
        if (!mock_file_matches(file_index, "screenblocks\t\t9\n"))
            return 46;
    }

    mock_reset();
    {
        int fd = open("savegame.dsg", O_WRONLY | O_CREAT | O_TRUNC | O_BINARY, 0666);
        int file_index;
        if (fd < 0)
            return 47;
        if (write(fd, "SAVE", 4) != 4)
            return 48;
        if (close(fd) != 0)
            return 49;
        file_index = mock_find_file("savegame.dsg");
        if (!mock_file_matches(file_index, "SAVE"))
            return 50;
        if (mock_files[file_index].last_flags != (O_WRONLY | O_CREAT | O_TRUNC | O_BINARY))
            return 51;
    }

    mock_reset();
    if (mock_seed_file("DEFAULT.CFG", "old-value") < 0)
        return 141;
    {
        FILE* f = fopen("/.doomrc", "w");
        int file_index = mock_find_file("DEFAULT.CFG");
        char key[80];
        char value[100];
        struct stat st;
        if (!f)
            return 142;
        if (mock_files[file_index].last_flags != (O_WRONLY | O_CREAT | O_TRUNC))
            return 143;
        if (fprintf(f, "%s\t\t%i\n%s\t\t\"%s\"\n", "use_mouse", 1, "chatmacro0", "PERSIST") != 35)
            return 144;
        if (fclose(f) != 0)
            return 145;
        if (!mock_file_matches(file_index, "use_mouse\t\t1\nchatmacro0\t\t\"PERSIST\"\n"))
            return 146;
        f = fopen("c:\\doomdata\\default.cfg", "r");
        if (!f)
            return 147;
        if (fscanf(f, "%79s %[^\n]\n", key, value) != 2)
            return 148;
        if (strcmp(key, "use_mouse") || strcmp(value, "1"))
            return 149;
        if (fscanf(f, "%79s %[^\n]\n", key, value) != 2)
            return 150;
        if (strcmp(key, "chatmacro0") || strcmp(value, "\"PERSIST\""))
            return 151;
        if (fclose(f) != 0)
            return 152;
        if (stat("c:/doomdata/default.cfg", &st) != 0 || st.st_size != 35)
            return 153;
    }

    mock_reset();
    {
        unsigned char save_payload[64];
        unsigned char header[40];
        int fd;
        int file_index;
        struct stat st;
        memset(save_payload, 0, sizeof(save_payload));
        memcpy(save_payload, "VIBE SAVE SLOT", 14);
        memcpy(save_payload + 24, "version 110", 11);
        save_payload[40] = 3;
        save_payload[41] = 1;
        save_payload[42] = 1;
        fd = open("c:\\doomdata\\doomsav3.dsg", O_WRONLY | O_CREAT | O_TRUNC | O_BINARY, 0666);
        if (fd < 0)
            return 154;
        if (write(fd, save_payload, sizeof(save_payload)) != (ssize_t)sizeof(save_payload))
            return 155;
        if (close(fd) != 0)
            return 156;
        file_index = mock_find_file("doomsav3.dsg");
        if (file_index < 0)
            return 157;
        if (mock_files[file_index].last_flags != (O_WRONLY | O_CREAT | O_TRUNC | O_BINARY))
            return 158;
        fd = open("doomsav3.dsg", O_RDONLY | O_BINARY, 0666);
        if (fd < 0)
            return 159;
        if (fstat(fd, &st) != 0 || st.st_size != (off_t)sizeof(save_payload))
            return 160;
        if (read(fd, header, sizeof(header)) != (ssize_t)sizeof(header))
            return 161;
        if (memcmp(header, "VIBE SAVE SLOT", 14))
            return 162;
        if (memcmp(header + 24, "version 110", 11))
            return 163;
        if (close(fd) != 0)
            return 164;
        fd = open("doomsav3.dsg", O_WRONLY | O_CREAT | O_TRUNC | O_BINARY, 0666);
        if (fd < 0)
            return 165;
        if (write(fd, "tiny", 4) != 4)
            return 166;
        if (close(fd) != 0)
            return 167;
        if (stat("c:/doomdata/doomsav3.dsg", &st) != 0 || st.st_size != 4)
            return 168;
        if (remove("doomsav3.dsg") != 0)
            return 169;
        if (stat("doomsav3.dsg", &st) != -1 || errno != ENOENT)
            return 170;
    }

    mock_reset();
    if (mock_seed_file("DOOM1.WAD", "IWAD") < 0)
        return 171;
    if (mock_seed_file("DOOM.ELF", "ELF") < 0)
        return 172;
    {
        int fd = open("c:\\doomdata\\DOOM1.WAD", O_RDONLY | O_BINARY, 0666);
        if (fd < 0)
            return 173;
        if (close(fd) != 0)
            return 174;
        if (open("c:\\doomdata\\DOOM1.WAD", O_WRONLY | O_TRUNC | O_BINARY, 0666) != -1 || errno != EACCES)
            return 175;
        if (open("DOOM.ELF", O_WRONLY | O_TRUNC | O_BINARY, 0666) != -1 || errno != EACCES)
            return 176;
        if (mock_file_matches(mock_find_file("DOOM1.WAD"), "IWAD") == 0)
            return 177;
        if (mock_file_matches(mock_find_file("DOOM.ELF"), "ELF") == 0)
            return 178;
    }

    mock_reset();
    if (mock_seed_file("readme.txt", "abc") < 0)
        return 52;
    {
        FILE* f = fopen("readme.txt", "r");
        struct stat st;
        int fd;
        if (!f)
            return 53;
        if (fprintf(f, "nope") != EOF || errno != EBADF || !ferror(f))
            return 54;
        clearerr(f);
        if (ferror(f))
            return 55;
        if (fclose(f) != 0)
            return 56;
        if (fopen("readme.txt", "wr"))
            return 57;
        if (errno != EINVAL)
            return 58;
        if (access("readme.txt", R_OK) != 0)
            return 59;
        if (access("missing.txt", R_OK) != -1 || errno != ENOENT)
            return 60;
        if (stat("readme.txt", &st) != 0 || st.st_size != 3)
            return 61;
        if ((st.st_mode & (S_IFREG | S_IRUSR | S_IWUSR)) != (S_IFREG | S_IRUSR | S_IWUSR))
            return 108;
        if (mock_stat_syscalls != 1)
            return 109;
        fd = open("readme.txt", O_RDONLY);
        if (fd < 0)
            return 62;
        if (lseek(fd, 2, SEEK_SET) != 2)
            return 63;
        if (fstat(fd, &st) != 0 || st.st_size != 3)
            return 64;
        if (lseek(fd, 0, SEEK_CUR) != 2)
            return 65;
        if (mock_fstat_syscalls != 1)
            return 110;
        if (close(fd) != 0)
            return 66;
    }

    mock_reset();
    if (mock_seed_file("append.txt", "A") < 0)
        return 67;
    {
        FILE* f = fopen("append.txt", "ab+");
        int file_index = mock_find_file("append.txt");
        char ch = 0;
        if (!f)
            return 68;
        if (mock_files[file_index].last_flags != (O_RDWR | O_CREAT | O_APPEND))
            return 69;
        if (fseek(f, 0, SEEK_SET) != 0)
            return 70;
        if (fread(&ch, 1, 1, f) != 1 || ch != 'A')
            return 71;
        if (fwrite("B", 1, 1, f) != 1)
            return 72;
        if (fclose(f) != 0)
            return 73;
        if (!mock_file_matches(file_index, "AB"))
            return 74;
    }

    mock_reset();
    if (open("bad.txt", O_ACCMODE) != -1 || errno != EINVAL)
        return 75;
    if (mock_open_syscalls != 0)
        return 76;
    if (open("bad.txt", O_RDONLY | O_TRUNC) != -1 || errno != EINVAL)
        return 77;
    if (mock_open_syscalls != 0)
        return 78;
    if (open("bad.txt", O_RDONLY | 0x8000) != -1 || errno != EINVAL)
        return 192;
    if (mock_open_syscalls != 0)
        return 193;
    if (open("denied.txt", O_RDONLY) != -1 || errno != EACCES)
        return 79;
    if (mock_open_syscalls != 1)
        return 80;

    mock_reset();
    if (mock_seed_file("slots.txt", "x") < 0)
        return 194;
    {
        int fds[MOCK_MAX_FDS];
        int i;
        for (i = 0; i < MOCK_MAX_FDS; ++i)
            fds[i] = -1;
        for (i = 3; i < MOCK_MAX_FDS; ++i) {
            fds[i] = open("slots.txt", O_RDONLY);
            if (fds[i] < 0)
                return 195;
        }
        if (open("slots.txt", O_RDONLY) != -1 || errno != EMFILE)
            return 196;
        for (i = 3; i < MOCK_MAX_FDS; ++i)
            if (close(fds[i]) != 0)
                return 197;
    }

    errno = 0;
    if (mkdir("c:\\doomdata", 0) != 0)
        return 198;
    if (mkdir("notadir", 0) != -1 || errno != ENOSYS)
        return 199;

    mock_reset();
    {
        FILE* f = fopen("update.cfg", "w+b");
        int file_index = mock_find_file("update.cfg");
        char ch = 0;
        if (!f)
            return 81;
        if (mock_files[file_index].last_flags != (O_RDWR | O_CREAT | O_TRUNC))
            return 82;
        if (fwrite("XY", 1, 2, f) != 2)
            return 83;
        if (fseek(f, 0, SEEK_SET) != 0)
            return 84;
        if (fread(&ch, 1, 1, f) != 1 || ch != 'X')
            return 85;
        if (fclose(f) != 0)
            return 86;
    }

    mock_reset();
    {
        char ch = 0;
        int fd;
        if (read(99, &ch, 1) != -1 || errno != EBADF)
            return 87;
        if (write(99, "x", 1) != -1 || errno != EBADF)
            return 88;
        if (lseek(99, 0, SEEK_SET) != -1 || errno != EBADF)
            return 89;
        if (mock_seed_file("readme.txt", "hello") < 0)
            return 90;
        fd = open("readme.txt", O_RDONLY);
        if (fd < 0)
            return 91;
        if (lseek(fd, 0, 99) != -1 || errno != EINVAL)
            return 92;
        if (close(fd) != 0)
            return 93;
        if (close(fd) != -1 || errno != EBADF)
            return 94;
    }

    mock_reset();
    if (mock_seed_file("readme.txt", "hello") < 0)
        return 111;
    if (mock_seed_file("DOOM1.WAD", "IWAD") < 0)
        return 112;
    {
        char ch = 0;
        int fd = open("readme.txt", O_RDWR);
        struct stat st;
        if (fd < 0)
            return 113;
        if (unlink("DOOM1.WAD") != -1 || errno != EACCES)
            return 114;
        if (unlink("missing.txt") != -1 || errno != ENOENT)
            return 115;
        if (unlink("readme.txt") != 0)
            return 116;
        if (mock_unlink_syscalls != 3)
            return 117;
        if (stat("readme.txt", &st) != -1 || errno != ENOENT)
            return 118;
        if (read(fd, &ch, 1) != -1 || errno != EBADF)
            return 119;
        fd = open("readme.txt", O_RDWR | O_CREAT | O_TRUNC, 0666);
        if (fd < 0)
            return 120;
        if (write(fd, "new", 3) != 3)
            return 121;
        if (fstat(fd, &st) != 0 || st.st_size != 3)
            return 122;
        if (close(fd) != 0)
            return 123;
    }

    mock_reset();
    vibe_libc_host_heap_reset();
    {
        unsigned char* mapped = mmap(0, 8192, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
        if (mapped == MAP_FAILED)
            return 124;
        if (mapped[0] != 0 || mapped[4096] != 0)
            return 125;
        mapped[0] = 0xaa;
        mapped[4096] = 0xbb;
        if (munmap(mapped, 8192) != 0)
            return 126;
        if (munmap(0, 8192) != -1 || errno != EINVAL)
            return 127;
        if (mmap((void*)1, 4096, PROT_READ, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0) != MAP_FAILED || errno != EINVAL)
            return 128;
        if (mmap(0, 4096, PROT_READ, MAP_PRIVATE, -1, 0) != MAP_FAILED || errno != ENOSYS)
            return 129;
        if (mmap(0, 4096, PROT_READ, MAP_PRIVATE | MAP_ANONYMOUS, 3, 0) != MAP_FAILED || errno != ENOSYS)
            return 130;
    }

    mock_reset();
    {
        vibe_fb_info_t info;
        vibe_present_indexed_t present;
        unsigned char frame = 0;
        unsigned char palette = 0;
        if (ioctl(VIBE_DISPLAY_FD, VIBE_IOCTL_FBINFO, &info) != 0)
            return 131;
        if (info.width != 640 || info.height != 400 || info.frame_bytes != 320 * 200 || info.palette_bytes != 256 * 3)
            return 132;
        present.frame = &frame;
        present.palette = &palette;
        present.width = 320;
        present.height = 200;
        if (ioctl(VIBE_DISPLAY_FD, VIBE_IOCTL_PRESENT_INDEXED, &present) != 0)
            return 133;
        if (mock_present_count != 1 || mock_ioctl_syscalls != 2)
            return 134;
        present.width = 319;
        if (ioctl(VIBE_DISPLAY_FD, VIBE_IOCTL_PRESENT_INDEXED, &present) != -1 || errno != EINVAL)
            return 135;
        if (ioctl(99, VIBE_IOCTL_FBINFO, &info) != -1 || errno != ENOTTY)
            return 136;
        if (ioctl(VIBE_DISPLAY_FD, 0xdead, &info) != -1 || errno != ENOTTY)
            return 137;
    }

    mock_reset();
    {
        int status = 0;
        if (fork() != -1 || errno != ENOSYS)
            return 138;
        if (waitpid((pid_t)-1, &status, 0) != -1 || errno != ECHILD)
            return 139;
        if (wait(&status) != -1 || errno != ECHILD)
            return 140;
    }

    return 0;
}
