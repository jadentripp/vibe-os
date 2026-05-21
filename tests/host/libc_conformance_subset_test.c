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

int main(void)
{
    unsigned char bytes[6];
    char overlap[8] = "abcdef";
    char pad[6];
    char cat[12] = "ab";
    char small[5];
    char word[8];
    char hex_text[16];
    int value;
    int written;
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

    if (!isdigit('7') || isdigit('x') || !isxdigit('f') || !isxdigit('F'))
        return fail(1);
    if (!isalpha('Z') || !isalnum('9') || !isspace('\n'))
        return fail(2);
    if (tolower('Q') != 'q' || toupper('q') != 'Q')
        return fail(3);

    memset(bytes, 0x11, sizeof(bytes));
    if (memcmp(bytes, "\x11\x11\x11\x11\x11\x11", sizeof(bytes)) != 0)
        return fail(4);
    memcpy(bytes + 1, "WAD", 3);
    if (memcmp(bytes, "\x11WAD\x11\x11", sizeof(bytes)) != 0)
        return fail(5);
    memmove(overlap + 2, overlap, 4);
    if (strcmp(overlap, "ababcd") != 0)
        return fail(6);

    memset(pad, '?', sizeof(pad));
    strncpy(pad, "xy", sizeof(pad));
    if (pad[0] != 'x' || pad[1] != 'y' || pad[2] != 0 || pad[5] != 0)
        return fail(7);
    strncat(cat, "cdef", 2);
    if (strcmp(cat, "abcd") != 0)
        return fail(8);
    if (strchr(text, 0) != text + 4 || strrchr(text, 'a') != text + 3)
        return fail(9);
    if (strcasecmp("DoOm", "doom") != 0 || strncasecmp("DOOMWAD", "doomelf", 4) != 0)
        return fail(10);
    if (atoi(" \t-42x") != -42 || atol("17") != 17)
        return fail(11);

    written = snprintf(small, sizeof(small), "E%dM%d", 12, 3);
    if (written != 5 || strcmp(small, "E12M") != 0)
        return fail(12);
    value = -1;
    if (sscanf("0x2a WAD", "%i %7s", &value, word) != 2)
        return fail(13);
    if (value != 42 || strcmp(word, "WAD") != 0)
        return fail(14);
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
