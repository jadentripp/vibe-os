#define VIBE_LIBC_HOST_TEST 1

#define stdin vibe_test_stdin
#define stdout vibe_test_stdout
#define stderr vibe_test_stderr
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

#include <limits.h>
#include <stdint.h>
#include <stdbool.h>

#include "../../doom_port/libc.c"

int vibe_syscall3(unsigned int number, unsigned long arg0, unsigned long arg1, unsigned long arg2)
{
    (void)number;
    (void)arg0;
    (void)arg1;
    (void)arg2;
    return -ENOSYS;
}

static int fail(int code)
{
    return code;
}

static int near_double(double left, double right)
{
    double delta = left - right;
    if (delta < 0.0)
        delta = -delta;
    return delta < 0.000001;
}

static int compare_ints(const void* left, const void* right)
{
    int left_value = *(const int*)left;
    int right_value = *(const int*)right;

    if (left_value < right_value)
        return -1;
    if (left_value > right_value)
        return 1;
    return 0;
}

int main(void)
{
    unsigned char bytes[6];
    char overlap[8] = "abcdef";
    char pad[6];
    char cat[12] = "ab";
    char small[5];
    char word[8];
    char hex_text[16];
    char token_text[32];
    char token_a[16];
    char token_b[16];
    char* token;
    char* token_a_save = 0;
    char* token_b_save = 0;
    char* bounded_copy;
    char* end;
    long parsed;
    unsigned long uparsed;
    double dparsed;
    unsigned int scanned_unsigned;
    char scanned_chars[4];
    char next_ch;
    time_t wall_time;
    int value;
    int written;
    int first_rand;
    int second_rand;
    int values[5] = { 4, 1, 3, 1, 2 };
    int key;
    int* found;
    bool truth = true;
    uint32_t max32 = UINT32_MAX;
    int8_t signed8 = -5;
    const char* text = "abca";
    vibe_input_event_t event;
    vibe_input_status_t input_status;
    vibe_audio_voice_desc_t voice;
    vibe_audio_device_info_t device;
    vibe_audio_pcm_ring_info_t ring;
    vibe_audio_stream_info_t stream;
    vibe_fb_info_t fb;
    vibe_present_indexed_t present;
    unsigned char frame[4] = { 0, 1, 2, 3 };
    unsigned char palette[6] = { 0, 0, 0, 63, 63, 63 };

    if (CHAR_BIT != 8 || INT_MAX != 2147483647 || LONG_MAX != 2147483647L)
        return fail(50);
    if (!truth || false || max32 != 4294967295u || signed8 != -5)
        return fail(51);
    if (RAND_MAX != 0x7fffffff || EXIT_SUCCESS != 0 || EXIT_FAILURE != 1)
        return fail(52);
    if (labs(-12345L) != 12345L)
        return fail(53);

    if (!isdigit('7') || isdigit('x') || !isxdigit('f') || !isxdigit('F'))
        return fail(1);
    if (!isalpha('Z') || !isalnum('9') || !isspace('\n'))
        return fail(2);
    if (!isblank('\t') || !iscntrl('\n') || !isgraph('A') || !isprint(' ') || !ispunct('!'))
        return fail(54);
    if (tolower('Q') != 'q' || toupper('q') != 'Q')
        return fail(3);

    memset(bytes, 0x11, sizeof(bytes));
    if (memcmp(bytes, "\x11\x11\x11\x11\x11\x11", sizeof(bytes)) != 0)
        return fail(4);
    memcpy(bytes + 1, "WAD", 3);
    if (memcmp(bytes, "\x11WAD\x11\x11", sizeof(bytes)) != 0)
        return fail(5);
    if (memchr(bytes, 'W', sizeof(bytes)) != bytes + 1 || memchr(bytes, 'Z', sizeof(bytes)) != 0)
        return fail(55);
    memmove(overlap + 2, overlap, 4);
    if (strcmp(overlap, "ababcd") != 0)
        return fail(6);
    if (strnlen("abc", 2) != 2 || strnlen("abc", 8) != 3)
        return fail(56);

    memset(pad, '?', sizeof(pad));
    strncpy(pad, "xy", sizeof(pad));
    if (pad[0] != 'x' || pad[1] != 'y' || pad[2] != 0 || pad[5] != 0)
        return fail(7);
    strncat(cat, "cdef", 2);
    if (strcmp(cat, "abcd") != 0)
        return fail(8);
    if (strchr(text, 0) != text + 4 || strrchr(text, 'a') != text + 3)
        return fail(9);
    if (strspn("level01.wad", "abcdefghijklmnopqrstuvwxyz") != 5)
        return fail(42);
    if (strcspn("level01.wad", "0123456789") != 5)
        return fail(43);
    if (!strpbrk("config=video", "=:") || strcmp(strpbrk("config=video", "=:"), "=video") != 0)
        return fail(44);
    if (strstr("assets/maps/e1m1.wad", "maps") == 0
        || strcmp(strstr("assets/maps/e1m1.wad", "e1"), "e1m1.wad") != 0)
        return fail(45);
    strcpy(token_text, "wad;map,,sound");
    token = strtok(token_text, ";,");
    if (!token || strcmp(token, "wad") != 0)
        return fail(46);
    token = strtok(0, ";,");
    if (!token || strcmp(token, "map") != 0)
        return fail(47);
    token = strtok(0, ";,");
    if (!token || strcmp(token, "sound") != 0)
        return fail(48);
    if (strtok(0, ";,") != 0)
        return fail(49);
    strcpy(token_a, "one/two");
    strcpy(token_b, "red,blue");
    token = strtok_r(token_a, "/", &token_a_save);
    if (!token || strcmp(token, "one") != 0)
        return fail(57);
    token = strtok_r(token_b, ",", &token_b_save);
    if (!token || strcmp(token, "red") != 0)
        return fail(58);
    token = strtok_r(0, "/", &token_a_save);
    if (!token || strcmp(token, "two") != 0)
        return fail(59);
    token = strtok_r(0, ",", &token_b_save);
    if (!token || strcmp(token, "blue") != 0)
        return fail(60);
    bounded_copy = strndup("E1M1.WAD", 4);
    if (!bounded_copy || strcmp(bounded_copy, "E1M1") != 0)
        return fail(61);
    free(bounded_copy);
    if (strcasecmp("DoOm", "doom") != 0 || strncasecmp("DOOMWAD", "doomelf", 4) != 0)
        return fail(10);
    if (atoi(" \t-42x") != -42 || atol("17") != 17)
        return fail(11);
    parsed = strtol("  -0x2a!", &end, 0);
    if (parsed != -42 || *end != '!')
        return fail(33);
    parsed = strtol("0777", &end, 0);
    if (parsed != 511 || *end)
        return fail(34);
    uparsed = strtoul("0xffZ", &end, 0);
    if (uparsed != 255ul || *end != 'Z')
        return fail(35);
    dparsed = strtod(" -12.5e1rest", &end);
    if (!near_double(dparsed, -125.0) || strcmp(end, "rest") != 0)
        return fail(65);
    if (!near_double(atof("0.125"), 0.125))
        return fail(66);
    dparsed = strtod("nope", &end);
    if (dparsed != 0.0 || end[0] != 'n')
        return fail(67);
    errno = 0;
    parsed = strtol("999999999999", &end, 10);
    if (parsed != 0x7fffffffl || errno != ERANGE)
        return fail(36);
    errno = 0;
    if (strtol("nope", &end, 10) != 0 || end[0] != 'n' || errno != 0)
        return fail(37);
    if (strcmp(strerror(ENOENT), "No such file or directory") != 0
        || strcmp(strerror(1234), "Unknown error") != 0)
        return fail(38);
    srand(7);
    first_rand = rand();
    second_rand = rand();
    srand(7);
    if (rand() != first_rand || rand() != second_rand)
        return fail(39);
    qsort(values, 5, sizeof(values[0]), compare_ints);
    if (values[0] != 1 || values[1] != 1 || values[2] != 2 || values[3] != 3 || values[4] != 4)
        return fail(62);
    key = 3;
    found = bsearch(&key, values, 5, sizeof(values[0]), compare_ints);
    if (!found || *found != 3)
        return fail(63);
    key = 5;
    if (bsearch(&key, values, 5, sizeof(values[0]), compare_ints) != 0)
        return fail(64);
    errno = 0;
    wall_time = time(0);
    if (wall_time != (time_t)-1 || errno != ENOSYS)
        return fail(40);
    if (clock() != 0)
        return fail(41);
    if (!near_double(sqrt(25.0), 5.0)
        || !near_double(fabs(-3.5), 3.5)
        || !near_double(floor(3.75), 3.0)
        || !near_double(ceil(3.25), 4.0)
        || !near_double(sin(0.0), 0.0)
        || !near_double(cos(0.0), 1.0)
        || !near_double(atan(0.0), 0.0)
        || !near_double(atan2(1.0, 1.0), 0.7853981633974483)
        || !near_double(pow(2.0, 3.0), 8.0))
        return fail(32);

    written = snprintf(small, sizeof(small), "E%dM%d", 12, 3);
    if (written != 5 || strcmp(small, "E12M") != 0)
        return fail(12);
    value = -1;
    if (sscanf("0x2a WAD", "%i %7s", &value, word) != 2)
        return fail(13);
    if (value != 42 || strcmp(word, "WAD") != 0)
        return fail(14);
    value = -1;
    next_ch = 0;
    if (sscanf("077z", "%i%c", &value, &next_ch) != 2 || value != 63 || next_ch != 'z')
        return fail(68);
    scanned_unsigned = 0;
    next_ch = 0;
    if (sscanf("123x", "%2u%c", &scanned_unsigned, &next_ch) != 2
        || scanned_unsigned != 12u
        || next_ch != '3')
        return fail(69);
    scanned_unsigned = 0;
    next_ch = 0;
    if (sscanf("128z", "%3o%c", &scanned_unsigned, &next_ch) != 2
        || scanned_unsigned != 10u
        || next_ch != '8')
        return fail(70);
    memset(scanned_chars, 0, sizeof(scanned_chars));
    if (sscanf(" abc", "%3c", scanned_chars) != 1
        || scanned_chars[0] != ' '
        || scanned_chars[1] != 'a'
        || scanned_chars[2] != 'b')
        return fail(71);
    sprintf(hex_text, "%04x", 0x2a);
    if (strcmp(hex_text, "002a") != 0)
        return fail(15);

    if (vibe_syscall_errno(-ENOSYS, EIO) != ENOSYS)
        return fail(16);
    if (vibe_syscall_errno(-1, EINVAL) != EINVAL)
        return fail(17);
    if (vibe_clock_ticks_to_milliseconds(123, VIBE_CLOCK_MONOTONIC_HZ) != 1230)
        return fail(18);
    if (vibe_clock_ticks_to_milliseconds(5, 0) != 0)
        return fail(19);

    vibe_input_make_key_event(&event, 12, 57, 1);
    if (!vibe_input_event_is_key(&event) || !vibe_input_key_is_pressed(&event))
        return fail(20);
    vibe_input_make_mouse_packet_event(&event, 13, VIBE_INPUT_MOUSE_BUTTON_LEFT, 5, -2);
    if (!vibe_input_event_is_mouse_packet(&event)
        || !vibe_input_mouse_button_is_down(&event, VIBE_INPUT_MOUSE_BUTTON_LEFT)
        || vibe_input_mouse_delta(&event, VIBE_INPUT_MOUSE_AXIS_X) != 5
        || vibe_input_mouse_delta(&event, VIBE_INPUT_MOUSE_AXIS_Y) != -2)
        return fail(21);
    memset(&input_status, 0, sizeof(input_status));
    input_status.abi_version = VIBE_INPUT_ABI_VERSION;
    input_status.event_bytes = VIBE_INPUT_EVENT_BYTES;
    input_status.queue_capacity = VIBE_INPUT_EVENT_QUEUE_CAPACITY;
    input_status.status_bytes = VIBE_INPUT_STATUS_BYTES;
    input_status.queue_usable_capacity = VIBE_INPUT_EVENT_QUEUE_USABLE_CAPACITY;
    input_status.overflow_policy = VIBE_INPUT_QUEUE_OVERFLOW_DROP_OLDEST;
    input_status.keyboard_status = VIBE_INPUT_DEVICE_STATUS_READY;
    input_status.mouse_status = VIBE_INPUT_DEVICE_STATUS_READY;
    input_status.total_events = 7;
    input_status.queued_events = 2;
    input_status.polled_events = 4;
    input_status.dropped_events = 1;
    input_status.capabilities = VIBE_INPUT_CAP_KEYBOARD | VIBE_INPUT_CAP_MOUSE;
    input_status.keyboard_state[57 >> 5] = 1ul << (57 & 31);
    input_status.mouse_buttons = VIBE_INPUT_MOUSE_BUTTON_RIGHT;
    input_status.mouse_delta_x_total = -7;
    if (!vibe_input_status_abi_is_current(&input_status)
        || !vibe_input_status_has_capability(&input_status, VIBE_INPUT_CAP_MOUSE)
        || !vibe_input_status_uses_drop_oldest(&input_status)
        || !vibe_input_status_keyboard_is_ready(&input_status)
        || !vibe_input_status_mouse_is_ready(&input_status)
        || !vibe_input_status_key_is_down(&input_status, 57)
        || !vibe_input_status_mouse_button_is_down(&input_status, VIBE_INPUT_MOUSE_BUTTON_RIGHT)
        || !vibe_input_status_mouse_has_motion(&input_status))
        return fail(22);
    if (vibe_input_status_queued_events(&input_status) != 2
        || vibe_input_status_available_events(&input_status) != 61
        || vibe_input_status_queue_is_full(&input_status)
        || !vibe_input_status_counters_are_consistent(&input_status))
        return fail(29);
    input_status.queued_events = VIBE_INPUT_EVENT_QUEUE_USABLE_CAPACITY;
    input_status.polled_events = 0;
    input_status.dropped_events = 0;
    input_status.total_events = VIBE_INPUT_EVENT_QUEUE_USABLE_CAPACITY;
    if (!vibe_input_status_queue_is_full(&input_status)
        || vibe_input_status_available_events(&input_status) != 0
        || !vibe_input_status_counters_are_consistent(&input_status))
        return fail(30);
    input_status.total_events = 0;
    if (vibe_input_status_counters_are_consistent(&input_status))
        return fail(31);

    vibe_audio_voice_desc_init(&voice, bytes, sizeof(bytes), 11025, 100, 128, 0);
    if (voice.samples != bytes || voice.length != sizeof(bytes) || voice.sample_rate != 11025)
        return fail(23);
    memset(&device, 0, sizeof(device));
    device.device_kind = VIBE_AUDIO_DEVICE_SB16;
    device.status = VIBE_AUDIO_DEVICE_STATUS_READY;
    device.capabilities = VIBE_AUDIO_CAP_PCM_RING | VIBE_AUDIO_CAP_PULL_STREAM;
    if (!vibe_audio_device_is_ready(&device)
        || !vibe_audio_device_has_capability(&device, VIBE_AUDIO_CAP_PULL_STREAM))
        return fail(24);
    memset(&ring, 0, sizeof(ring));
    ring.format = VIBE_AUDIO_FORMAT_U8_STEREO;
    ring.channels = 2;
    if (!vibe_audio_pcm_ring_is_u8_stereo(&ring))
        return fail(25);
    memset(&stream, 0, sizeof(stream));
    stream.stream_mode = VIBE_AUDIO_MUSIC_STREAM_PULL;
    stream.flags = VIBE_AUDIO_STREAM_FLAG_PULL | VIBE_AUDIO_STREAM_FLAG_REFILL_PENDING;
    stream.handle = 7;
    stream.pull_request_count = 5;
    stream.pull_refill_count = 4;
    stream.pending_pull_requests = 1;
    if (!vibe_audio_stream_uses_pull(&stream)
        || !vibe_audio_stream_matches_handle(&stream, 7)
        || !vibe_audio_stream_refills_are_ordered(&stream)
        || !vibe_audio_stream_needs_refill(&stream)
        || !vibe_audio_stream_has_new_refill_request(&stream, 4))
        return fail(26);

    memset(&fb, 0, sizeof(fb));
    fb.capabilities = VIBE_FB_CAP_PRESENT_INDEXED
        | VIBE_FB_CAP_PRESENT_RGB_PALETTE
        | VIBE_FB_CAP_FIXED_PRESENT_SIZE;
    fb.present_format = VIBE_FB_FORMAT_INDEX8_RGB24;
    fb.max_present_width = 2;
    fb.max_present_height = 2;
    vibe_present_indexed_init(&present, frame, palette, 2, 2);
    if (!vibe_fb_info_supports_indexed_rgb24(&fb)
        || !vibe_fb_info_present_size_is_accepted(&fb, 2, 2)
        || !vibe_fb_can_present_indexed(&fb, &present))
        return fail(27);
    present.width = 1;
    if (vibe_fb_info_present_size_is_accepted(&fb, 1, 2)
        || vibe_fb_can_present_indexed(&fb, &present))
        return fail(28);

    return 0;
}
