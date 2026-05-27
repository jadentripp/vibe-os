#include "pi4_runtime.h"

#include <stdarg.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "d_event.h"
#include "d_net.h"
#include "doomdef.h"
#include "doomstat.h"
#include "i_sound.h"
#include "i_system.h"
#include "i_video.h"
#include "m_misc.h"
#include "sounds.h"
#include "v_video.h"
#include "w_wad.h"

#define PI4_DOOM_ZONE_BYTES (8 * 1024 * 1024)
#define PI4_DOOM_AUDIO_PROBE_BYTES 64
#define PI4_DOOM_AUDIO_PROBE_RATE 11025
#define PI4_DOOM_INPUT_POLL_BUDGET 32
#define PI4_DOOM_INPUT_LOAD_POLL_BUDGET 8
#define PI4_DOOM_INPUT_PRESENT_POLL_BUDGET 4
#define PI4_DOOM_UART_HOLD_TICS 4
#define PI4_DOOM_INPUT_STATUS_SYNC_TICS 8
#define PI4_DOOM_INPUT_KEY_RELEASED 0
#define PI4_DOOM_INPUT_KEY_PRESSED 1
#define PI4_DOOM_INPUT_KEY_SCANCODE_MASK 0x7ful
#define PI4_DOOM_INPUT_MOUSE_BUTTON_MASK 0x07ul
#define PI4_DOOM_MOUSE_DELTA_SCALE 4
#define PI4_DOOM_USB_HID_USAGE_E 0x08
#define PI4_DOOM_USB_HID_USAGE_Q 0x14
#define PI4_DOOM_USB_HID_USAGE_BACKSPACE 0x2a
#define PI4_DOOM_USB_HID_USAGE_TAB 0x2b
#define PI4_DOOM_USB_HID_USAGE_LEFT_ALT 0xe2
#define PI4_DOOM_USB_HID_USAGE_RIGHT_ALT 0xe6

static byte pi4_doom_zone[PI4_DOOM_ZONE_BYTES] __attribute__((aligned(16)));
static byte pi4_doom_palette[PI4_VIBE_FB_RGB24_PALETTE_BYTES];
static byte pi4_doom_progress_palette[PI4_VIBE_FB_RGB24_PALETTE_BYTES];
static byte pi4_doom_progress_frame[SCREENWIDTH * SCREENHEIGHT] __attribute__((aligned(16)));
static byte pi4_doom_audio_probe_pcm[PI4_DOOM_AUDIO_PROBE_BYTES] __attribute__((aligned(16)));
static ticcmd_t pi4_empty_ticcmd;
static doomcom_t pi4_doomcom;
static int pi4_next_sound_handle = 1;
static int pi4_doom_progress_palette_ready;
static int pi4_doom_progress_real_frame_seen;
static int pi4_doom_progress_last_phase;
static unsigned long pi4_doom_progress_last_input;
static unsigned long pi4_doom_progress_file_size;
static unsigned long pi4_doom_progress_file_loaded;
static unsigned long pi4_doom_progress_next_file_mark;
static unsigned long pi4_doom_progress_read_chunks;
static unsigned long pi4_doom_presented_frames;
static unsigned long pi4_doom_runtime_input_count;
static char pi4_doom_progress_console_line[42];
static int pi4_doom_audio_probe_done;
static int pi4_doom_audio_pcm_probe_ready;
static int pi4_doom_audio_started;
static pi4_vibe_word_t pi4_doom_audio_handle;
static long pi4_doom_audio_start_result;
static long pi4_doom_audio_device_info_result;
static long pi4_doom_audio_ring_info_result;
static long pi4_doom_audio_open_result;
static long pi4_doom_audio_write_result;
static long pi4_doom_audio_stream_info_result;
static long pi4_doom_audio_buffered_result;
static long pi4_doom_audio_drain_result;
static long pi4_doom_audio_close_result;
static unsigned char pi4_doom_real_key_down[256];
static unsigned char pi4_doom_synthetic_key_hold[256];
static unsigned char pi4_doom_posted_key_down[256];
static int pi4_doom_posted_mouse_buttons;
static unsigned int pi4_doom_input_status_sync_tics;
static int pi4_doom_status_mouse_delta_seen;
static pi4_vibe_sword_t pi4_doom_last_status_mouse_delta_x;
static pi4_vibe_sword_t pi4_doom_last_status_mouse_delta_y;

void D_PostEvent(event_t* ev);
static void pi4_doom_note_visible_input(unsigned long code);
static void pi4_doom_draw_runtime_status(byte* frame, unsigned long frame_count);
static void pi4_doom_note_synthetic_key(int key);
static void pi4_doom_sync_mouse_buttons_from_status(const pi4_vibe_input_status_t* status);
static int pi4_doom_handle_runtime_input(const pi4_vibe_input_event_t* input, int post_to_doom);
static int pi4_doom_poll_runtime_inputs(int budget, int post_to_doom);

static pi4_vibe_audio_device_info_t pi4_doom_audio_device_info;
static pi4_vibe_audio_pcm_ring_info_t pi4_doom_audio_ring_info;
static pi4_vibe_audio_stream_info_t pi4_doom_audio_stream_info;

typedef struct pi4_doom_glyph {
    char ch;
    unsigned char row[7];
} pi4_doom_glyph_t;

static const pi4_doom_glyph_t pi4_doom_font[] = {
    {'0', {0x0e, 0x11, 0x13, 0x15, 0x19, 0x11, 0x0e}},
    {'1', {0x04, 0x0c, 0x04, 0x04, 0x04, 0x04, 0x0e}},
    {'2', {0x0e, 0x11, 0x01, 0x02, 0x04, 0x08, 0x1f}},
    {'3', {0x1e, 0x01, 0x01, 0x0e, 0x01, 0x01, 0x1e}},
    {'4', {0x02, 0x06, 0x0a, 0x12, 0x1f, 0x02, 0x02}},
    {'5', {0x1f, 0x10, 0x10, 0x1e, 0x01, 0x01, 0x1e}},
    {'6', {0x0e, 0x10, 0x10, 0x1e, 0x11, 0x11, 0x0e}},
    {'7', {0x1f, 0x01, 0x02, 0x04, 0x08, 0x08, 0x08}},
    {'8', {0x0e, 0x11, 0x11, 0x0e, 0x11, 0x11, 0x0e}},
    {'9', {0x0e, 0x11, 0x11, 0x0f, 0x01, 0x01, 0x0e}},
    {'A', {0x0e, 0x11, 0x11, 0x1f, 0x11, 0x11, 0x11}},
    {'B', {0x1e, 0x11, 0x11, 0x1e, 0x11, 0x11, 0x1e}},
    {'C', {0x0f, 0x10, 0x10, 0x10, 0x10, 0x10, 0x0f}},
    {'D', {0x1e, 0x11, 0x11, 0x11, 0x11, 0x11, 0x1e}},
    {'E', {0x1f, 0x10, 0x10, 0x1e, 0x10, 0x10, 0x1f}},
    {'F', {0x1f, 0x10, 0x10, 0x1e, 0x10, 0x10, 0x10}},
    {'G', {0x0f, 0x10, 0x10, 0x13, 0x11, 0x11, 0x0f}},
    {'H', {0x11, 0x11, 0x11, 0x1f, 0x11, 0x11, 0x11}},
    {'I', {0x0e, 0x04, 0x04, 0x04, 0x04, 0x04, 0x0e}},
    {'J', {0x07, 0x02, 0x02, 0x02, 0x12, 0x12, 0x0c}},
    {'K', {0x11, 0x12, 0x14, 0x18, 0x14, 0x12, 0x11}},
    {'L', {0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x1f}},
    {'M', {0x11, 0x1b, 0x15, 0x15, 0x11, 0x11, 0x11}},
    {'N', {0x11, 0x19, 0x15, 0x13, 0x11, 0x11, 0x11}},
    {'O', {0x0e, 0x11, 0x11, 0x11, 0x11, 0x11, 0x0e}},
    {'P', {0x1e, 0x11, 0x11, 0x1e, 0x10, 0x10, 0x10}},
    {'Q', {0x0e, 0x11, 0x11, 0x11, 0x15, 0x12, 0x0d}},
    {'R', {0x1e, 0x11, 0x11, 0x1e, 0x14, 0x12, 0x11}},
    {'S', {0x0f, 0x10, 0x10, 0x0e, 0x01, 0x01, 0x1e}},
    {'T', {0x1f, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04}},
    {'U', {0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x0e}},
    {'V', {0x11, 0x11, 0x11, 0x11, 0x11, 0x0a, 0x04}},
    {'W', {0x11, 0x11, 0x11, 0x15, 0x15, 0x15, 0x0a}},
    {'X', {0x11, 0x11, 0x0a, 0x04, 0x0a, 0x11, 0x11}},
    {'Y', {0x11, 0x11, 0x0a, 0x04, 0x04, 0x04, 0x04}},
    {'Z', {0x1f, 0x01, 0x02, 0x04, 0x08, 0x10, 0x1f}},
    {'-', {0x00, 0x00, 0x00, 0x1f, 0x00, 0x00, 0x00}},
    {'.', {0x00, 0x00, 0x00, 0x00, 0x00, 0x0c, 0x0c}},
    {':', {0x00, 0x0c, 0x0c, 0x00, 0x0c, 0x0c, 0x00}},
    {'/', {0x01, 0x01, 0x02, 0x04, 0x08, 0x10, 0x10}},
    {'!', {0x04, 0x04, 0x04, 0x04, 0x04, 0x00, 0x04}},
};

static char pi4_doom_font_upper(char ch)
{
    if (ch >= 'a' && ch <= 'z')
        return (char)(ch - ('a' - 'A'));
    return ch;
}

static unsigned char pi4_doom_font_row(char ch, int row)
{
    unsigned int i;

    ch = pi4_doom_font_upper(ch);
    if (ch == ' ')
        return 0;
    for (i = 0; i < sizeof(pi4_doom_font) / sizeof(pi4_doom_font[0]); i++) {
        if (pi4_doom_font[i].ch == ch)
            return pi4_doom_font[i].row[row];
    }
    return 0x1f;
}

static void pi4_doom_fill_rect(byte* frame, int x, int y, int width, int height, byte color)
{
    int row;
    int col;

    if (!frame || width <= 0 || height <= 0)
        return;
    if (x < 0) {
        width += x;
        x = 0;
    }
    if (y < 0) {
        height += y;
        y = 0;
    }
    if (x >= SCREENWIDTH || y >= SCREENHEIGHT || width <= 0 || height <= 0)
        return;
    if (x + width > SCREENWIDTH)
        width = SCREENWIDTH - x;
    if (y + height > SCREENHEIGHT)
        height = SCREENHEIGHT - y;

    for (row = 0; row < height; row++) {
        for (col = 0; col < width; col++)
            frame[(y + row) * SCREENWIDTH + x + col] = color;
    }
}

static void pi4_doom_draw_char(byte* frame, int x, int y, char ch, byte color, int scale)
{
    int row;
    int col;

    if (scale <= 0)
        scale = 1;
    for (row = 0; row < 7; row++) {
        unsigned char bits = pi4_doom_font_row(ch, row);
        for (col = 0; col < 5; col++) {
            if (bits & (1u << (4 - col)))
                pi4_doom_fill_rect(frame, x + col * scale, y + row * scale,
                                   scale, scale, color);
        }
    }
}

static void pi4_doom_draw_text(byte* frame, int x, int y, const char* text, byte color, int scale)
{
    int start_x = x;

    while (text && *text) {
        if (*text == '\n') {
            x = start_x;
            y += 9 * scale;
            text++;
            continue;
        }
        if (x > SCREENWIDTH - 5 * scale)
            break;
        pi4_doom_draw_char(frame, x, y, *text, color, scale);
        x += 6 * scale;
        text++;
    }
}

static void pi4_doom_draw_text_line_limited(
    byte* frame,
    int x,
    int y,
    const char* text,
    byte color,
    int scale,
    int max_chars)
{
    char line[40];
    int i = 0;

    if (max_chars >= (int)sizeof(line))
        max_chars = (int)sizeof(line) - 1;
    while (text && text[i] && text[i] != '\n' && i < max_chars) {
        line[i] = text[i];
        i++;
    }
    line[i] = 0;
    pi4_doom_draw_text(frame, x, y, line, color, scale);
}

static long pi4_doom_present_indexed_frame(const byte* frame, const byte* palette)
{
    long result;
    pi4_vibe_present_indexed_t present;

    present.frame = frame;
    present.palette = palette;
    present.width = SCREENWIDTH;
    present.height = SCREENHEIGHT;
    result = vibe_user_present_indexed_checked(&present);
    if (result < 0)
        result = vibe_user_present_indexed(&present);
    return result;
}

static void pi4_doom_audio_init_pcm_desc(
    pi4_vibe_audio_pcm_desc_t* desc,
    const unsigned char* samples,
    pi4_vibe_word_t length,
    pi4_vibe_word_t sample_rate)
{
    memset(desc, 0, sizeof(*desc));
    desc->samples = samples;
    desc->length = length;
    desc->sample_rate = sample_rate;
    desc->channels = 2;
    desc->format = PI4_VIBE_AUDIO_FORMAT_U8_STEREO;
}

static int pi4_doom_audio_device_ready(const pi4_vibe_audio_device_info_t* info)
{
    return pi4_vibe_audio_device_info_is_playback_ready(info);
}

static int pi4_doom_audio_ring_ready(const pi4_vibe_audio_pcm_ring_info_t* info)
{
    return info
        && info->format == PI4_VIBE_AUDIO_FORMAT_U8_STEREO
        && info->channels == 2
        && info->sample_rate != 0
        && info->ring_bytes != 0;
}

static void pi4_doom_audio_prepare_probe_pcm(void)
{
    unsigned long i;
    for (i = 0; i < sizeof(pi4_doom_audio_probe_pcm); i += 2) {
        byte sample = (byte)(112 + ((i / 2) & 31));
        pi4_doom_audio_probe_pcm[i] = sample;
        pi4_doom_audio_probe_pcm[i + 1] = sample;
    }
}

static void pi4_doom_audio_probe_abi(void)
{
    pi4_vibe_audio_pcm_desc_t desc;
    pi4_vibe_word_t sample_rate;
    long handle;

    if (pi4_doom_audio_probe_done)
        return;
    pi4_doom_audio_probe_done = 1;
    pi4_doom_audio_pcm_probe_ready = 0;

    memset(&pi4_doom_audio_device_info, 0, sizeof(pi4_doom_audio_device_info));
    memset(&pi4_doom_audio_ring_info, 0, sizeof(pi4_doom_audio_ring_info));
    memset(&pi4_doom_audio_stream_info, 0, sizeof(pi4_doom_audio_stream_info));

    pi4_doom_audio_start_result = vibe_user_audio_device_start();
    pi4_doom_audio_device_info_result =
        vibe_user_audio_device_info(&pi4_doom_audio_device_info);
    if (pi4_doom_audio_device_info_result < 0)
        return;
    if (pi4_doom_audio_start_result < 0)
        return;
    pi4_doom_audio_started = 1;
    if (!pi4_doom_audio_device_ready(&pi4_doom_audio_device_info))
        return;

    pi4_doom_audio_ring_info_result =
        vibe_user_audio_pcm_ring_info(&pi4_doom_audio_ring_info);
    if (pi4_doom_audio_ring_info_result < 0)
        return;
    if (!pi4_doom_audio_ring_ready(&pi4_doom_audio_ring_info))
        return;

    sample_rate = pi4_doom_audio_ring_info.sample_rate;
    if (!sample_rate)
        sample_rate = PI4_DOOM_AUDIO_PROBE_RATE;

    pi4_doom_audio_init_pcm_desc(&desc, NULL, 0, sample_rate);
    handle = vibe_user_audio_pcm_open(&desc);
    pi4_doom_audio_open_result = handle;
    if (handle <= 0)
        return;
    pi4_doom_audio_handle = (pi4_vibe_word_t)handle;

    pi4_doom_audio_prepare_probe_pcm();
    pi4_doom_audio_init_pcm_desc(
        &desc,
        pi4_doom_audio_probe_pcm,
        sizeof(pi4_doom_audio_probe_pcm),
        sample_rate);
    pi4_doom_audio_write_result =
        vibe_user_audio_pcm_write_desc(pi4_doom_audio_handle, &desc);
    pi4_doom_audio_stream_info_result =
        vibe_user_audio_stream_info(pi4_doom_audio_handle, &pi4_doom_audio_stream_info);
    pi4_doom_audio_buffered_result =
        vibe_user_audio_pcm_buffered_bytes(pi4_doom_audio_handle);
    if (pi4_doom_audio_write_result == (long)sizeof(pi4_doom_audio_probe_pcm) &&
        pi4_doom_audio_stream_info_result >= 0 &&
        pi4_doom_audio_buffered_result >= 0 &&
        pi4_vibe_audio_stream_info_is_active_push(
            &pi4_doom_audio_stream_info,
            pi4_doom_audio_handle)) {
        pi4_doom_audio_pcm_probe_ready = 1;
    }
    pi4_doom_audio_drain_result = 0;
}

static void pi4_doom_progress_prepare_palette(void)
{
    if (pi4_doom_progress_palette_ready)
        return;
    memset(pi4_doom_progress_palette, 0, sizeof(pi4_doom_progress_palette));
    pi4_doom_progress_palette[1 * 3 + 0] = 16;
    pi4_doom_progress_palette[1 * 3 + 1] = 16;
    pi4_doom_progress_palette[1 * 3 + 2] = 20;
    pi4_doom_progress_palette[2 * 3 + 0] = 72;
    pi4_doom_progress_palette[2 * 3 + 1] = 72;
    pi4_doom_progress_palette[2 * 3 + 2] = 80;
    pi4_doom_progress_palette[3 * 3 + 0] = 36;
    pi4_doom_progress_palette[3 * 3 + 1] = 128;
    pi4_doom_progress_palette[3 * 3 + 2] = 88;
    pi4_doom_progress_palette[4 * 3 + 0] = 210;
    pi4_doom_progress_palette[4 * 3 + 1] = 164;
    pi4_doom_progress_palette[4 * 3 + 2] = 64;
    pi4_doom_progress_palette[5 * 3 + 0] = 184;
    pi4_doom_progress_palette[5 * 3 + 1] = 56;
    pi4_doom_progress_palette[5 * 3 + 2] = 44;
    pi4_doom_progress_palette[6 * 3 + 0] = 72;
    pi4_doom_progress_palette[6 * 3 + 1] = 128;
    pi4_doom_progress_palette[6 * 3 + 2] = 216;
    pi4_doom_progress_palette[7 * 3 + 0] = 232;
    pi4_doom_progress_palette[7 * 3 + 1] = 232;
    pi4_doom_progress_palette[7 * 3 + 2] = 208;
    pi4_doom_progress_palette_ready = 1;
}

static const char* pi4_doom_progress_phase_text(int phase)
{
    switch (phase) {
    case 1:
        return "DOOM SELECTED";
    case 2:
        return "ASSET PROBED";
    case 3:
        return "OPENING WAD";
    case 4:
        return "READING WAD";
    case 5:
    case 6:
    case 7:
        return "WAD READ ERROR";
    case 9:
        return "INPUT ACTIVE";
    case 10:
        return "WAD READY";
    case 11:
        return "ENGINE INIT";
    case 8:
        return "GRAPHICS READY";
    default:
        return "STARTING DOOM";
    }
}

static unsigned long pi4_doom_progress_kib(unsigned long bytes)
{
    if (!bytes)
        return 0;
    return (bytes + 1023ul) / 1024ul;
}

static void pi4_doom_note_visible_input(unsigned long code)
{
    pi4_doom_progress_last_input = code ? code : 1;
    pi4_doom_runtime_input_count++;
}

static void pi4_doom_draw_runtime_status(byte* frame, unsigned long frame_count)
{
    char line[48];

    if (!frame)
        return;
    pi4_doom_fill_rect(frame, 0, 0, SCREENWIDTH, 11, 0);
    snprintf(line, sizeof(line), "F:%lu I:%lu R:%lu W:%luK L:%lu",
             frame_count % 1000000ul,
             pi4_doom_runtime_input_count % 1000000ul,
             pi4_doom_progress_read_chunks % 1000000ul,
             pi4_doom_progress_kib(pi4_doom_progress_file_loaded),
             pi4_doom_progress_last_input & 0xfffful);
    pi4_doom_draw_text(frame, 3, 2, line, 7, 1);
}

static void pi4_doom_progress_draw_load_counts(unsigned long loaded, unsigned long total)
{
    char line[32];

    if (total <= 1)
        return;
    if (loaded > total)
        loaded = total;
    snprintf(line, sizeof(line), "WAD %lu/%luK",
             pi4_doom_progress_kib(loaded),
             pi4_doom_progress_kib(total));
    pi4_doom_draw_text(pi4_doom_progress_frame, 24, 120, line, 7, 1);
}

static void pi4_doom_progress_draw_runtime_counts(void)
{
    char line[32];

    snprintf(line, sizeof(line), "READS %lu INPUT %lu",
             pi4_doom_progress_read_chunks % 1000000ul,
             pi4_doom_runtime_input_count % 1000000ul);
    pi4_doom_draw_text(pi4_doom_progress_frame, 24, 136, line, 7, 1);
}

static void pi4_doom_progress_draw_text(int phase, unsigned long loaded, unsigned long total)
{
    pi4_doom_draw_text(pi4_doom_progress_frame, 16, 6, "VIBE-OS DOOM", 7, 2);
    pi4_doom_draw_text(pi4_doom_progress_frame, 24, 72,
                       pi4_doom_progress_phase_text(phase), 7, 2);
    if (phase == 4)
        pi4_doom_draw_text(pi4_doom_progress_frame, 24, 104, "LOADING DOOM1.WAD", 4, 1);
    else if (phase >= 5 && phase <= 7)
        pi4_doom_draw_text(pi4_doom_progress_frame, 24, 104, "CHECK DOOM1.WAD", 5, 1);
    else if (phase == 8)
        pi4_doom_draw_text(pi4_doom_progress_frame, 24, 104, "FRAMEBUFFER ONLINE", 3, 1);
    else if (phase == 9)
        pi4_doom_draw_text(pi4_doom_progress_frame, 24, 104, "CONTROLS MAPPED", 3, 1);
    else
        pi4_doom_draw_text(pi4_doom_progress_frame, 24, 104, "RUNTIME ABI ACTIVE", 6, 1);
    if (phase == 4 || phase == 9)
        pi4_doom_progress_draw_load_counts(loaded, total);
    if (phase == 4 || phase == 9 || pi4_doom_progress_read_chunks || pi4_doom_runtime_input_count)
        pi4_doom_progress_draw_runtime_counts();
    if (pi4_doom_progress_console_line[0])
        pi4_doom_draw_text_line_limited(pi4_doom_progress_frame, 24, 152,
                                        pi4_doom_progress_console_line, 4, 1, 36);
    if (pi4_doom_progress_last_input)
        pi4_doom_draw_text(pi4_doom_progress_frame, 24, 186, "INPUT ACTIVE", 7, 1);
}

static void pi4_doom_progress_present(int phase, unsigned long loaded, unsigned long total)
{
    int x;
    int y;
    unsigned long filled = 0;

    if (pi4_doom_progress_real_frame_seen)
        return;

    pi4_doom_progress_prepare_palette();
    if (total)
        filled = (loaded >= total) ? SCREENWIDTH : (loaded * SCREENWIDTH) / total;

    for (y = 0; y < SCREENHEIGHT; y++) {
        for (x = 0; x < SCREENWIDTH; x++) {
            byte color = 1;
            if (y < 20)
                color = (byte)(2 + (phase % 4));
            else if (y >= 156 && y < 176)
                color = (x < (int)filled) ? 3 : 2;
            else if (y >= 184)
                color = (pi4_doom_progress_last_input && x >= 24 && x < 296) ? 6 : 2;
            else if (((x >> 4) + (y >> 4) + phase) & 1)
                color = 0;
            pi4_doom_progress_frame[y * SCREENWIDTH + x] = color;
        }
    }

    if (phase >= 0 && phase < SCREENHEIGHT)
        memset(pi4_doom_progress_frame + phase * SCREENWIDTH, 7, SCREENWIDTH);

    pi4_doom_progress_draw_text(phase, loaded, total);
    pi4_doom_progress_last_phase = phase;
    (void)pi4_doom_present_indexed_frame(pi4_doom_progress_frame, pi4_doom_progress_palette);
}

void pi4_doom_engine_show_failure(const char* title, const char* detail, long code)
{
    char code_line[32];
    int x;
    int y;

    pi4_doom_progress_prepare_palette();
    for (y = 0; y < SCREENHEIGHT; y++) {
        for (x = 0; x < SCREENWIDTH; x++)
            pi4_doom_progress_frame[y * SCREENWIDTH + x] = (y < 28) ? 5 : 1;
    }

    pi4_doom_draw_text(pi4_doom_progress_frame, 16, 8,
                       title ? title : "DOOM ERROR", 7, 2);
    pi4_doom_draw_text_line_limited(pi4_doom_progress_frame, 18, 52,
                                    detail ? detail : "RUNTIME FAILED",
                                    7, 1, 32);
    pi4_doom_draw_text(pi4_doom_progress_frame, 18, 92, "EXPECTED WAD PATH:", 4, 1);
    pi4_doom_draw_text(pi4_doom_progress_frame, 18, 108, "DOOM1.WAD", 7, 2);
    pi4_doom_draw_text(pi4_doom_progress_frame, 18, 150,
                       "COPY ASSET INTO PI IMAGE", 3, 1);
    snprintf(code_line, sizeof(code_line), "STATUS %ld", code);
    pi4_doom_draw_text(pi4_doom_progress_frame, 18, 168, code_line, 6, 1);
    (void)pi4_doom_present_indexed_frame(pi4_doom_progress_frame, pi4_doom_progress_palette);
}

void pi4_doom_engine_mark_selected(void)
{
    pi4_doom_progress_file_size = 0;
    pi4_doom_progress_file_loaded = 0;
    pi4_doom_progress_next_file_mark = 0;
    pi4_doom_progress_read_chunks = 0;
    pi4_doom_progress_last_input = 0;
    pi4_doom_progress_real_frame_seen = 0;
    pi4_doom_presented_frames = 0;
    pi4_doom_runtime_input_count = 0;
    pi4_doom_progress_console_line[0] = 0;
    memset(pi4_doom_real_key_down, 0, sizeof(pi4_doom_real_key_down));
    memset(pi4_doom_synthetic_key_hold, 0, sizeof(pi4_doom_synthetic_key_hold));
    memset(pi4_doom_posted_key_down, 0, sizeof(pi4_doom_posted_key_down));
    pi4_doom_posted_mouse_buttons = 0;
    pi4_doom_input_status_sync_tics = 0;
    pi4_doom_status_mouse_delta_seen = 0;
    pi4_doom_last_status_mouse_delta_x = 0;
    pi4_doom_last_status_mouse_delta_y = 0;
    pi4_doom_progress_present(1, 0, 1);
}

void pi4_doom_engine_mark_probe_done(void)
{
    pi4_doom_progress_present(2, 0, 1);
}

void pi4_doom_engine_note_file_open(unsigned long size)
{
    pi4_doom_progress_file_size = size;
    pi4_doom_progress_file_loaded = 0;
    pi4_doom_progress_read_chunks = 0;
    pi4_doom_progress_next_file_mark = size / 64;
    if (pi4_doom_progress_next_file_mark < 4096)
        pi4_doom_progress_next_file_mark = 4096;
    pi4_doom_progress_present(3, 0, size ? size : 1);
}

void pi4_doom_engine_note_file_read(unsigned long loaded, unsigned long last, unsigned long size)
{
    if (last)
        pi4_doom_progress_read_chunks++;
    pi4_doom_progress_file_loaded = loaded;
    pi4_doom_progress_file_size = size;
    if (loaded < size && loaded < pi4_doom_progress_next_file_mark)
        return;
    while (loaded >= pi4_doom_progress_next_file_mark)
        pi4_doom_progress_next_file_mark += pi4_doom_progress_next_file_mark < 4096 ? 4096 : size / 64;
    pi4_doom_progress_present(4, loaded, size ? size : 1);
}

void pi4_doom_engine_note_file_ready(void)
{
    pi4_doom_progress_present(10, pi4_doom_progress_file_loaded,
                              pi4_doom_progress_file_size ? pi4_doom_progress_file_size : 1);
}

void pi4_doom_engine_note_console(const char* text, unsigned long count)
{
    unsigned long i;
    unsigned long out = 0;
    unsigned long useful = 0;

    if (!text || !count || pi4_doom_progress_real_frame_seen)
        return;

    for (i = 0; i < count; i++) {
        char ch = text[i];
        if (ch == '\r')
            continue;
        if (ch == '\n') {
            if (out)
                break;
            continue;
        }
        if (ch < ' ' || ch > '~')
            ch = '.';
        if ((ch >= '0' && ch <= '9') || (ch >= 'A' && ch <= 'Z') ||
            (ch >= 'a' && ch <= 'z'))
            useful++;
        if (out + 1 >= sizeof(pi4_doom_progress_console_line))
            break;
        pi4_doom_progress_console_line[out++] = ch;
    }
    if (!out || useful < 3)
        return;
    pi4_doom_progress_console_line[out] = 0;
    pi4_doom_progress_present(11, pi4_doom_progress_file_loaded,
                              pi4_doom_progress_file_size ? pi4_doom_progress_file_size : 1);
}

void pi4_doom_engine_note_file_error(unsigned long code)
{
    pi4_doom_progress_present(5 + code, pi4_doom_progress_file_loaded,
                              pi4_doom_progress_file_size ? pi4_doom_progress_file_size : 1);
}

static int pi4_doom_key_from_uart(pi4_vibe_word_t code)
{
    switch (code) {
    case PI4_VIBE_UART_EVENT_UP:
        return KEY_UPARROW;
    case PI4_VIBE_UART_EVENT_DOWN:
        return KEY_DOWNARROW;
    case PI4_VIBE_UART_EVENT_SELECT_1:
        return KEY_LEFTARROW;
    case PI4_VIBE_UART_EVENT_SELECT_2:
        return KEY_RIGHTARROW;
    case PI4_VIBE_UART_EVENT_CONFIRM:
        return KEY_RCTRL;
    default:
        return 0;
    }
}

static void pi4_doom_post_uart_action(pi4_vibe_word_t code)
{
    int key = pi4_doom_key_from_uart(code);

    if (code == PI4_VIBE_UART_EVENT_CONFIRM) {
        pi4_doom_note_synthetic_key(KEY_ENTER);
        pi4_doom_note_synthetic_key(KEY_RCTRL);
        pi4_doom_note_synthetic_key(' ');
        return;
    }
    if (key)
        pi4_doom_note_synthetic_key(key);
}

static int pi4_doom_key_from_ps2_set1(pi4_vibe_word_t code)
{
    int extended = (code & PI4_VIBE_INPUT_KEY_PS2_SET1_EXTENDED) != 0;

    if (extended) {
        switch (code & PI4_DOOM_INPUT_KEY_SCANCODE_MASK) {
        case 0x1c:
            return KEY_ENTER;
        case 0x1d:
            return KEY_RCTRL;
        case 0x38:
            return KEY_RALT;
        case 0x48:
            return KEY_UPARROW;
        case 0x4b:
            return KEY_LEFTARROW;
        case 0x4d:
            return KEY_RIGHTARROW;
        case 0x50:
            return KEY_DOWNARROW;
        case 0x53:
            return KEY_BACKSPACE;
        default:
            return 0;
        }
    }

    switch (code & PI4_DOOM_INPUT_KEY_SCANCODE_MASK) {
    case 0x01:
        return KEY_ESCAPE;
    case 0x02:
        return '1';
    case 0x03:
        return '2';
    case 0x04:
        return '3';
    case 0x05:
        return '4';
    case 0x06:
        return '5';
    case 0x07:
        return '6';
    case 0x08:
        return '7';
    case 0x09:
        return '8';
    case 0x0a:
        return '9';
    case 0x0b:
        return '0';
    case 0x0c:
        return KEY_MINUS;
    case 0x0d:
        return KEY_EQUALS;
    case 0x0e:
        return KEY_BACKSPACE;
    case 0x0f:
        return KEY_TAB;
    case 0x10:
        return ',';
    case 0x11:
        return KEY_UPARROW;
    case 0x12:
        return '.';
    case 0x13:
        return 'r';
    case 0x14:
        return 't';
    case 0x15:
        return 'y';
    case 0x16:
        return 'u';
    case 0x17:
        return 'i';
    case 0x18:
        return 'o';
    case 0x19:
        return 'p';
    case 0x1c:
        return KEY_ENTER;
    case 0x1d:
        return KEY_RCTRL;
    case 0x1e:
        return KEY_LEFTARROW;
    case 0x1f:
        return KEY_DOWNARROW;
    case 0x20:
        return KEY_RIGHTARROW;
    case 0x21:
        return 'f';
    case 0x22:
        return 'g';
    case 0x23:
        return 'h';
    case 0x24:
        return 'j';
    case 0x25:
        return 'k';
    case 0x26:
        return 'l';
    case 0x2a:
    case 0x36:
        return KEY_RSHIFT;
    case 0x2c:
        return 'z';
    case 0x2d:
        return 'x';
    case 0x2e:
        return 'c';
    case 0x2f:
        return 'v';
    case 0x30:
        return 'b';
    case 0x31:
        return 'n';
    case 0x32:
        return 'm';
    case 0x33:
        return ',';
    case 0x34:
        return '.';
    case 0x35:
        return '/';
    case 0x38:
        return KEY_RALT;
    case 0x39:
        return ' ';
    case 0x3b:
        return KEY_F1;
    case 0x3c:
        return KEY_F2;
    case 0x3d:
        return KEY_F3;
    case 0x3e:
        return KEY_F4;
    case 0x3f:
        return KEY_F5;
    case 0x40:
        return KEY_F6;
    case 0x41:
        return KEY_F7;
    case 0x42:
        return KEY_F8;
    case 0x43:
        return KEY_F9;
    case 0x44:
        return KEY_F10;
    case 0x48:
        return KEY_UPARROW;
    case 0x4b:
        return KEY_LEFTARROW;
    case 0x4d:
        return KEY_RIGHTARROW;
    case 0x50:
        return KEY_DOWNARROW;
    case 0x57:
        return KEY_F11;
    case 0x58:
        return KEY_F12;
    default:
        return 0;
    }
}

static int pi4_doom_key_from_usb_hid(pi4_vibe_word_t usage)
{
    switch (usage) {
    case PI4_DOOM_USB_HID_USAGE_Q:
        return ',';
    case PI4_DOOM_USB_HID_USAGE_E:
        return '.';
    case PI4_VIBE_INPUT_KEY_USB_HID_USAGE_1:
    case PI4_VIBE_INPUT_KEY_USB_HID_USAGE_KP_1:
        return '1';
    case PI4_VIBE_INPUT_KEY_USB_HID_USAGE_2:
    case PI4_VIBE_INPUT_KEY_USB_HID_USAGE_KP_2:
        return '2';
    case PI4_VIBE_INPUT_KEY_USB_HID_USAGE_3:
        return '3';
    case PI4_VIBE_INPUT_KEY_USB_HID_USAGE_4:
        return '4';
    case PI4_VIBE_INPUT_KEY_USB_HID_USAGE_5:
        return '5';
    case PI4_VIBE_INPUT_KEY_USB_HID_USAGE_6:
        return '6';
    case PI4_VIBE_INPUT_KEY_USB_HID_USAGE_7:
        return '7';
    case PI4_VIBE_INPUT_KEY_USB_HID_USAGE_ESCAPE:
        return KEY_ESCAPE;
    case PI4_DOOM_USB_HID_USAGE_TAB:
        return KEY_TAB;
    case PI4_DOOM_USB_HID_USAGE_BACKSPACE:
        return KEY_BACKSPACE;
    case PI4_VIBE_INPUT_KEY_USB_HID_USAGE_W:
    case PI4_VIBE_INPUT_KEY_USB_HID_USAGE_UP:
        return KEY_UPARROW;
    case PI4_VIBE_INPUT_KEY_USB_HID_USAGE_S:
    case PI4_VIBE_INPUT_KEY_USB_HID_USAGE_DOWN:
        return KEY_DOWNARROW;
    case PI4_VIBE_INPUT_KEY_USB_HID_USAGE_A:
    case PI4_VIBE_INPUT_KEY_USB_HID_USAGE_LEFT:
        return KEY_LEFTARROW;
    case PI4_VIBE_INPUT_KEY_USB_HID_USAGE_D:
    case PI4_VIBE_INPUT_KEY_USB_HID_USAGE_RIGHT:
        return KEY_RIGHTARROW;
    case PI4_VIBE_INPUT_KEY_USB_HID_USAGE_ENTER:
        return KEY_ENTER;
    case PI4_VIBE_INPUT_KEY_USB_HID_USAGE_SPACE:
        return ' ';
    case PI4_VIBE_INPUT_KEY_USB_HID_USAGE_LEFT_CTRL:
    case PI4_VIBE_INPUT_KEY_USB_HID_USAGE_RIGHT_CTRL:
        return KEY_RCTRL;
    case PI4_VIBE_INPUT_KEY_USB_HID_USAGE_LEFT_SHIFT:
    case PI4_VIBE_INPUT_KEY_USB_HID_USAGE_RIGHT_SHIFT:
        return KEY_RSHIFT;
    case PI4_DOOM_USB_HID_USAGE_LEFT_ALT:
    case PI4_DOOM_USB_HID_USAGE_RIGHT_ALT:
        return KEY_RALT;
    default:
        return 0;
    }
}

static int pi4_doom_key_from_runtime_input(const pi4_vibe_input_event_t* input)
{
    int key;

    if (!pi4_vibe_input_event_is_key(input))
        return 0;

    key = pi4_doom_key_from_ps2_set1(pi4_vibe_input_key_code(input));
    if (key)
        return key;
    return pi4_doom_key_from_usb_hid(pi4_vibe_input_key_usb_hid_usage(input));
}

static void pi4_doom_post_key_event(int key, evtype_t type)
{
    event_t ev;

    if (key <= 0 || key >= 256)
        return;
    memset(&ev, 0, sizeof(ev));
    ev.type = type;
    ev.data1 = key;
    D_PostEvent(&ev);
}

static void pi4_doom_sync_key_event(int key)
{
    int down;

    if (key <= 0 || key >= 256)
        return;
    down = pi4_doom_real_key_down[key] || pi4_doom_synthetic_key_hold[key];
    if (down && !pi4_doom_posted_key_down[key]) {
        pi4_doom_posted_key_down[key] = 1;
        pi4_doom_post_key_event(key, ev_keydown);
    } else if (!down && pi4_doom_posted_key_down[key]) {
        pi4_doom_posted_key_down[key] = 0;
        pi4_doom_post_key_event(key, ev_keyup);
    }
}

static void pi4_doom_set_real_key(int key, int down)
{
    if (key <= 0 || key >= 256)
        return;
    down = down != 0;
    if (pi4_doom_real_key_down[key] == (unsigned char)down)
        return;
    pi4_doom_real_key_down[key] = (unsigned char)down;
    pi4_doom_sync_key_event(key);
}

static void pi4_doom_release_synthetic_key(int key)
{
    if (key <= 0 || key >= 256)
        return;
    if (!pi4_doom_synthetic_key_hold[key])
        return;
    pi4_doom_synthetic_key_hold[key] = 0;
    pi4_doom_sync_key_event(key);
}

static void pi4_doom_decay_synthetic_keys(void)
{
    int key;

    for (key = 0; key < 256; key++) {
        if (!pi4_doom_synthetic_key_hold[key])
            continue;
        pi4_doom_synthetic_key_hold[key]--;
        if (!pi4_doom_synthetic_key_hold[key])
            pi4_doom_sync_key_event(key);
    }
}

static void pi4_doom_note_synthetic_key(int key)
{
    if (key <= 0 || key >= 256)
        return;

    if (key == KEY_UPARROW)
        pi4_doom_release_synthetic_key(KEY_DOWNARROW);
    else if (key == KEY_DOWNARROW)
        pi4_doom_release_synthetic_key(KEY_UPARROW);
    else if (key == KEY_LEFTARROW)
        pi4_doom_release_synthetic_key(KEY_RIGHTARROW);
    else if (key == KEY_RIGHTARROW)
        pi4_doom_release_synthetic_key(KEY_LEFTARROW);

    pi4_doom_synthetic_key_hold[key] = PI4_DOOM_UART_HOLD_TICS;
    pi4_doom_sync_key_event(key);
}

static int pi4_doom_status_ps2_down(
    const pi4_vibe_input_status_t* status,
    pi4_vibe_word_t scancode,
    int extended)
{
    return pi4_vibe_input_status_ps2_set1_key_is_down(status, scancode, extended);
}

static int pi4_doom_status_doom_key_down(
    const pi4_vibe_input_status_t* status,
    int key)
{
    switch (key) {
    case KEY_ESCAPE:
        return pi4_doom_status_ps2_down(status, 0x01, 0);
    case KEY_TAB:
        return pi4_doom_status_ps2_down(status, 0x0f, 0);
    case KEY_ENTER:
        return pi4_doom_status_ps2_down(status, 0x1c, 0) ||
            pi4_doom_status_ps2_down(status, 0x1c, 1);
    case KEY_RCTRL:
        return pi4_doom_status_ps2_down(status, 0x1d, 0) ||
            pi4_doom_status_ps2_down(status, 0x1d, 1);
    case KEY_RALT:
        return pi4_doom_status_ps2_down(status, 0x38, 0) ||
            pi4_doom_status_ps2_down(status, 0x38, 1);
    case KEY_RSHIFT:
        return pi4_doom_status_ps2_down(status, 0x2a, 0) ||
            pi4_doom_status_ps2_down(status, 0x36, 0);
    case KEY_BACKSPACE:
        return pi4_doom_status_ps2_down(status, 0x0e, 0) ||
            pi4_doom_status_ps2_down(status, 0x53, 1);
    case KEY_UPARROW:
        return pi4_doom_status_ps2_down(status, 0x11, 0) ||
            pi4_doom_status_ps2_down(status, 0x48, 0) ||
            pi4_doom_status_ps2_down(status, 0x48, 1);
    case KEY_DOWNARROW:
        return pi4_doom_status_ps2_down(status, 0x1f, 0) ||
            pi4_doom_status_ps2_down(status, 0x50, 0) ||
            pi4_doom_status_ps2_down(status, 0x50, 1);
    case KEY_LEFTARROW:
        return pi4_doom_status_ps2_down(status, 0x1e, 0) ||
            pi4_doom_status_ps2_down(status, 0x4b, 0) ||
            pi4_doom_status_ps2_down(status, 0x4b, 1);
    case KEY_RIGHTARROW:
        return pi4_doom_status_ps2_down(status, 0x20, 0) ||
            pi4_doom_status_ps2_down(status, 0x4d, 0) ||
            pi4_doom_status_ps2_down(status, 0x4d, 1);
    case ',':
        return pi4_doom_status_ps2_down(status, 0x10, 0);
    case '.':
        return pi4_doom_status_ps2_down(status, 0x12, 0);
    case ' ':
        return pi4_doom_status_ps2_down(status, 0x39, 0);
    case '1':
        return pi4_doom_status_ps2_down(status, 0x02, 0);
    case '2':
        return pi4_doom_status_ps2_down(status, 0x03, 0);
    case '3':
        return pi4_doom_status_ps2_down(status, 0x04, 0);
    case '4':
        return pi4_doom_status_ps2_down(status, 0x05, 0);
    case '5':
        return pi4_doom_status_ps2_down(status, 0x06, 0);
    case '6':
        return pi4_doom_status_ps2_down(status, 0x07, 0);
    case '7':
        return pi4_doom_status_ps2_down(status, 0x08, 0);
    default:
        return 0;
    }
}

static int pi4_doom_input_status_has_keyboard_state(
    const pi4_vibe_input_status_t* status)
{
    unsigned int i;

    if (!status)
        return 0;
    for (i = 0; i < sizeof(status->keyboard_state) / sizeof(status->keyboard_state[0]); i++) {
        if (status->keyboard_state[i])
            return 1;
    }
    return 0;
}

static void pi4_doom_sync_real_input_from_status(void)
{
    static const int keys[] = {
        KEY_ESCAPE,
        KEY_TAB,
        KEY_ENTER,
        KEY_RCTRL,
        KEY_RALT,
        KEY_RSHIFT,
        KEY_BACKSPACE,
        KEY_UPARROW,
        KEY_DOWNARROW,
        KEY_LEFTARROW,
        KEY_RIGHTARROW,
        ',',
        '.',
        ' ',
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
    };
    pi4_vibe_input_status_t status;
    unsigned int i;
    int keyboard_snapshot_valid;

    if (pi4_doom_input_status_sync_tics) {
        pi4_doom_input_status_sync_tics--;
        return;
    }
    pi4_doom_input_status_sync_tics = PI4_DOOM_INPUT_STATUS_SYNC_TICS;

    if (vibe_user_input_status(&status) < 0)
        return;
    if (!pi4_vibe_input_status_abi_is_current(&status))
        return;

    keyboard_snapshot_valid = pi4_vibe_input_status_keyboard_is_ready(&status) &&
        (!status.keyboard_down_count ||
            pi4_doom_input_status_has_keyboard_state(&status));
    if (keyboard_snapshot_valid) {
        for (i = 0; i < sizeof(keys) / sizeof(keys[0]); i++) {
            pi4_doom_set_real_key(
                keys[i],
                pi4_doom_status_doom_key_down(&status, keys[i]));
        }
    }
    pi4_doom_sync_mouse_buttons_from_status(&status);
}

static int pi4_doom_scaled_mouse_delta(pi4_vibe_sword_t delta)
{
    if (delta > 512)
        delta = 512;
    else if (delta < -512)
        delta = -512;
    return (int)delta * PI4_DOOM_MOUSE_DELTA_SCALE;
}

static int pi4_doom_mouse_buttons_from_runtime(pi4_vibe_word_t buttons)
{
    int doom_buttons = 0;

    if (buttons & PI4_VIBE_INPUT_MOUSE_BUTTON_LEFT)
        doom_buttons |= 1;
    if (buttons & PI4_VIBE_INPUT_MOUSE_BUTTON_MIDDLE)
        doom_buttons |= 2;
    if (buttons & PI4_VIBE_INPUT_MOUSE_BUTTON_RIGHT)
        doom_buttons |= 4;
    return doom_buttons;
}

static void pi4_doom_post_mouse_buttons(int buttons, int delta_x, int delta_y)
{
    event_t ev;

    memset(&ev, 0, sizeof(ev));
    ev.type = ev_mouse;
    ev.data1 = buttons & (int)PI4_DOOM_INPUT_MOUSE_BUTTON_MASK;
    ev.data2 = delta_x;
    ev.data3 = delta_y;
    D_PostEvent(&ev);
    pi4_doom_posted_mouse_buttons = ev.data1;
}

static void pi4_doom_post_mouse_event(const pi4_vibe_input_event_t* input)
{
    if (!input)
        return;
    pi4_doom_post_mouse_buttons(
        pi4_doom_mouse_buttons_from_runtime(pi4_vibe_input_mouse_buttons(input)),
        pi4_doom_scaled_mouse_delta(pi4_vibe_input_mouse_delta_x(input)),
        pi4_doom_scaled_mouse_delta(pi4_vibe_input_mouse_delta_y(input)));
}

static void pi4_doom_sync_mouse_buttons_from_status(const pi4_vibe_input_status_t* status)
{
    int buttons;
    pi4_vibe_sword_t delta_x;
    pi4_vibe_sword_t delta_y;
    int post_delta_x = 0;
    int post_delta_y = 0;

    if (!pi4_vibe_input_status_mouse_is_ready(status))
        return;
    buttons = pi4_doom_mouse_buttons_from_runtime(
        pi4_vibe_input_status_mouse_buttons(status));
    delta_x = status->mouse_delta_x_total;
    delta_y = status->mouse_delta_y_total;
    if (pi4_doom_status_mouse_delta_seen) {
        post_delta_x = pi4_doom_scaled_mouse_delta(
            delta_x - pi4_doom_last_status_mouse_delta_x);
        post_delta_y = pi4_doom_scaled_mouse_delta(
            delta_y - pi4_doom_last_status_mouse_delta_y);
    }
    pi4_doom_status_mouse_delta_seen = 1;
    pi4_doom_last_status_mouse_delta_x = delta_x;
    pi4_doom_last_status_mouse_delta_y = delta_y;
    if (buttons != pi4_doom_posted_mouse_buttons || post_delta_x || post_delta_y)
        pi4_doom_post_mouse_buttons(buttons, post_delta_x, post_delta_y);
}

static int pi4_doom_handle_runtime_input(const pi4_vibe_input_event_t* input, int post_to_doom)
{
    int key;

    if (!input)
        return 0;

    if (pi4_vibe_input_event_is_uart_serial(input)) {
        if (!pi4_doom_key_from_uart(pi4_vibe_input_event_uart_code(input)))
            return 0;
        pi4_doom_note_visible_input(pi4_vibe_input_event_uart_code(input));
        if (post_to_doom)
            pi4_doom_post_uart_action(pi4_vibe_input_event_uart_code(input));
        pi4_doom_progress_present(9, pi4_doom_progress_file_loaded,
                                  pi4_doom_progress_file_size ? pi4_doom_progress_file_size : 1);
        return 1;
    }

    if (pi4_vibe_input_event_is_key(input)) {
        key = pi4_doom_key_from_runtime_input(input);
        if (!key)
            return 0;
        pi4_doom_note_visible_input(input->code);
        if (post_to_doom) {
            if (pi4_vibe_input_key_is_pressed(input))
                pi4_doom_set_real_key(key, 1);
            else if (pi4_vibe_input_key_is_released(input))
                pi4_doom_set_real_key(key, 0);
        }
        pi4_doom_progress_present(9, pi4_doom_progress_file_loaded,
                                  pi4_doom_progress_file_size ? pi4_doom_progress_file_size : 1);
        return 1;
    }

    if (pi4_vibe_input_event_is_mouse_packet(input)) {
        pi4_doom_note_visible_input(
            (input->code & PI4_DOOM_INPUT_MOUSE_BUTTON_MASK) | 0x100ul);
        if (post_to_doom)
            pi4_doom_post_mouse_event(input);
        pi4_doom_progress_present(9, pi4_doom_progress_file_loaded,
                                  pi4_doom_progress_file_size ? pi4_doom_progress_file_size : 1);
        return 1;
    }

    return 0;
}

static int pi4_doom_poll_runtime_inputs(int budget, int post_to_doom)
{
    int handled = 0;
    pi4_vibe_input_event_t input;

    while (budget-- > 0 && vibe_user_poll_input(&input) > 0) {
        if (pi4_doom_handle_runtime_input(&input, post_to_doom))
            handled++;
    }
    return handled;
}

void pi4_doom_engine_poll_visible_input(void)
{
    pi4_vibe_input_status_t status;
    int active;

    active = pi4_doom_poll_runtime_inputs(PI4_DOOM_INPUT_LOAD_POLL_BUDGET, 1);
    pi4_doom_sync_real_input_from_status();
    if (vibe_user_input_status(&status) == 0 &&
        pi4_vibe_input_status_abi_is_current(&status) &&
        (status.keyboard_down_count || pi4_vibe_input_status_mouse_buttons(&status))) {
        pi4_doom_note_visible_input(
            status.keyboard_last_code ? status.keyboard_last_code :
                (pi4_vibe_input_status_mouse_buttons(&status) | 0x100ul));
        active = 1;
    }
    if (active)
        pi4_doom_progress_present(9, pi4_doom_progress_file_loaded,
                                  pi4_doom_progress_file_size ? pi4_doom_progress_file_size : 1);
}

void I_Init(void)
{
    vibe_user_file_probe_assets();
    pi4_doom_progress_present(6, pi4_doom_progress_file_loaded,
                              pi4_doom_progress_file_size ? pi4_doom_progress_file_size : 1);
    I_InitSound();
}

byte* I_ZoneBase(int* size)
{
    if (size)
        *size = PI4_DOOM_ZONE_BYTES;
    return pi4_doom_zone;
}

int I_GetTime(void)
{
    pi4_vibe_clock_time_t now;
    if (vibe_user_clock_monotonic(&now) == 0 && now.frequency_hz)
        return (int)((now.ticks * 35ul) / now.frequency_hz);
    return (int)vibe_user_monotonic_ticks();
}

void I_StartFrame(void)
{
}

void I_StartTic(void)
{
    pi4_doom_decay_synthetic_keys();
    (void)pi4_doom_poll_runtime_inputs(PI4_DOOM_INPUT_POLL_BUDGET, 1);
    pi4_doom_sync_real_input_from_status();
}

ticcmd_t* I_BaseTiccmd(void)
{
    memset(&pi4_empty_ticcmd, 0, sizeof(pi4_empty_ticcmd));
    return &pi4_empty_ticcmd;
}

void I_Quit(void)
{
    M_SaveDefaults();
    vibe_user_exit(0);
}

byte* I_AllocLow(int length)
{
    return (byte*)calloc(1, (size_t)length);
}

void I_Tactile(int on, int off, int total)
{
    (void)on;
    (void)off;
    (void)total;
}

void I_Error(char* error, ...)
{
    char message[512];
    va_list args;
    va_start(args, error);
    vsnprintf(message, sizeof(message), error, args);
    va_end(args);
    fprintf(stderr, "I_Error: %s\n", message);
    if (strstr(message, "no files") || strstr(message, "No such") ||
        strstr(message, "not found"))
        pi4_doom_engine_show_failure("DOOM WAD MISSING", message, 2);
    else
        pi4_doom_engine_show_failure("DOOM ERROR", message, 1);
    vibe_user_exit(1);
}

void I_InitGraphics(void)
{
    int i;
    pi4_vibe_fb_info_t info;
    for (i = 0; i < 256; i++) {
        pi4_doom_palette[i * 3 + 0] = (byte)i;
        pi4_doom_palette[i * 3 + 1] = (byte)i;
        pi4_doom_palette[i * 3 + 2] = (byte)i;
    }
    (void)vibe_user_fb_get_info(&info);
    pi4_doom_progress_present(8, pi4_doom_progress_file_loaded,
                              pi4_doom_progress_file_size ? pi4_doom_progress_file_size : 1);
}

void I_ShutdownGraphics(void)
{
}

void I_SetPalette(byte* palette)
{
    if (palette) {
        memcpy(pi4_doom_palette, palette, PI4_VIBE_FB_RGB24_PALETTE_BYTES);
    }
}

void I_UpdateNoBlit(void)
{
}

void I_FinishUpdate(void)
{
    unsigned long frame_count;

    if (!screens[0])
        return;
    (void)pi4_doom_poll_runtime_inputs(PI4_DOOM_INPUT_PRESENT_POLL_BUDGET, 1);
    frame_count = pi4_doom_presented_frames + 1;
    pi4_doom_draw_runtime_status(screens[0], frame_count);
    if (pi4_doom_present_indexed_frame(screens[0], pi4_doom_palette) >= 0) {
        pi4_doom_presented_frames = frame_count;
        pi4_doom_progress_real_frame_seen = 1;
    }
}

void I_WaitVBL(int count)
{
    volatile int spin;
    while (count-- > 0) {
        for (spin = 0; spin < 1000; spin++) {
        }
    }
}

void I_ReadScreen(byte* scr)
{
    if (scr && screens[0])
        memcpy(scr, screens[0], SCREENWIDTH * SCREENHEIGHT);
}

void I_BeginRead(void)
{
}

void I_EndRead(void)
{
}

void I_InitNetwork(void)
{
    memset(&pi4_doomcom, 0, sizeof(pi4_doomcom));
    singletics = false;
    netgame = false;
    pi4_doomcom.id = DOOMCOM_ID;
    pi4_doomcom.numnodes = 1;
    pi4_doomcom.ticdup = 1;
    pi4_doomcom.consoleplayer = 0;
    pi4_doomcom.numplayers = 1;
    doomcom = &pi4_doomcom;
}

void I_NetCmd(void)
{
    if (doomcom)
        doomcom->remotenode = -1;
}

void I_InitSound(void)
{
    pi4_doom_audio_probe_abi();
}

void I_UpdateSound(void)
{
}

void I_SubmitSound(void)
{
}

void I_ShutdownSound(void)
{
    if (pi4_doom_audio_handle) {
        pi4_doom_audio_close_result = vibe_user_audio_pcm_close(pi4_doom_audio_handle);
        pi4_doom_audio_handle = 0;
    }
    pi4_doom_audio_pcm_probe_ready = 0;
    if (pi4_doom_audio_started) {
        (void)vibe_user_audio_device_shutdown();
        pi4_doom_audio_started = 0;
    }
}

void I_SetChannels(void)
{
}

int I_GetSfxLumpNum(sfxinfo_t* sfxinfo)
{
    char namebuf[16];
    if (!sfxinfo || !sfxinfo->name)
        return 0;
    snprintf(namebuf, sizeof(namebuf), "ds%s", sfxinfo->name);
    return W_GetNumForName(namebuf);
}

int I_StartSound(int id, int vol, int sep, int pitch, int priority)
{
    (void)id;
    (void)vol;
    (void)sep;
    (void)pitch;
    (void)priority;
    if (!pi4_doom_audio_pcm_probe_ready)
        return 0;
    return pi4_next_sound_handle++;
}

void I_StopSound(int handle)
{
    (void)handle;
}

int I_SoundIsPlaying(int handle)
{
    (void)handle;
    return 0;
}

void I_UpdateSoundParams(int handle, int vol, int sep, int pitch)
{
    (void)handle;
    (void)vol;
    (void)sep;
    (void)pitch;
}

void I_InitMusic(void)
{
}

void I_ShutdownMusic(void)
{
}

void I_SetMusicVolume(int volume)
{
    (void)volume;
}

void I_PauseSong(int handle)
{
    (void)handle;
}

void I_ResumeSong(int handle)
{
    (void)handle;
}

int I_RegisterSong(void* data)
{
    (void)data;
    if (!pi4_doom_audio_pcm_probe_ready)
        return 0;
    return pi4_next_sound_handle++;
}

void I_PlaySong(int handle, int looping)
{
    (void)handle;
    (void)looping;
}

void I_StopSong(int handle)
{
    (void)handle;
}

void I_UnRegisterSong(int handle)
{
    (void)handle;
}
