#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>

#include "doomdef.h"
#include "doomstat.h"
#include "d_main.h"
#include "d_net.h"
#include "i_sound.h"
#include "i_system.h"
#include "i_video.h"
#include "m_argv.h"
#include "w_wad.h"

#define LDOOM_ZONE_BYTES (3 * 1024 * 1024)
#define LDOOM_FRAME_BYTES (SCREENWIDTH * SCREENHEIGHT)

extern byte *screens[5];

char *sndserver_filename = "";
int mb_used = 3;

static ticcmd_t ldoom_empty_cmd;
static doomcom_t ldoom_doomcom;
static int ldoom_tics;
static int ldoom_frames;

static int ldoom_streq(const char *a, const char *b)
{
    while (*a && *b && *a == *b)
    {
        a++;
        b++;
    }

    return *a == 0 && *b == 0;
}

static int ldoom_tolower(int ch)
{
    if (ch >= 'A' && ch <= 'Z')
        return ch + ('a' - 'A');
    return ch;
}

int strcasecmp(const char *a, const char *b)
{
    int ca;
    int cb;

    while (*a && *b)
    {
        ca = ldoom_tolower((unsigned char)*a);
        cb = ldoom_tolower((unsigned char)*b);
        if (ca != cb)
            return ca - cb;
        a++;
        b++;
    }

    return ldoom_tolower((unsigned char)*a) - ldoom_tolower((unsigned char)*b);
}

int strncasecmp(const char *a, const char *b, size_t n)
{
    int ca;
    int cb;

    while (n > 0 && *a && *b)
    {
        ca = ldoom_tolower((unsigned char)*a);
        cb = ldoom_tolower((unsigned char)*b);
        if (ca != cb)
            return ca - cb;
        a++;
        b++;
        n--;
    }

    if (n == 0)
        return 0;

    return ldoom_tolower((unsigned char)*a) - ldoom_tolower((unsigned char)*b);
}

static unsigned ldoom_strlen(const char *s)
{
    unsigned len = 0;

    if (!s)
        return 0;

    while (s[len])
        len++;
    return len;
}

static int ldoom_write_raw(int fd, const char *buf, unsigned len)
{
    int ret;

    __asm__ volatile(
        "int $0x80"
        : "=a"(ret)
        : "0"(4), "b"(fd), "c"(buf), "d"(len)
        : "memory");
    return ret;
}

static void ldoom_write_str(int fd, const char *s)
{
    ldoom_write_raw(fd, s, ldoom_strlen(s));
}

off_t lseek(int fd, off_t offset, int whence)
{
    int ret;
    int low = (int)offset;

    __asm__ volatile(
        "int $0x80"
        : "=a"(ret)
        : "0"(19), "b"(fd), "c"(low), "d"(whence)
        : "memory");
    return (off_t)ret;
}

struct ldoom_format_out
{
    char *buf;
    unsigned cap;
    unsigned len;
    int fd;
};

static void ldoom_emit_char(struct ldoom_format_out *out, char ch)
{
    if (out->fd >= 0)
        ldoom_write_raw(out->fd, &ch, 1);
    else if (out->cap > 0 && out->len + 1 < out->cap)
        out->buf[out->len] = ch;
    out->len++;
}

static void ldoom_emit_repeat(struct ldoom_format_out *out, char ch, int count)
{
    while (count > 0)
    {
        ldoom_emit_char(out, ch);
        count--;
    }
}

static void ldoom_emit_strn(struct ldoom_format_out *out, const char *s, int max)
{
    int i = 0;

    if (!s)
        s = "(null)";

    while (s[i] && (max < 0 || i < max))
    {
        ldoom_emit_char(out, s[i]);
        i++;
    }
}

static int ldoom_uint_digits(unsigned value, unsigned base)
{
    int digits = 1;

    while (value >= base)
    {
        value /= base;
        digits++;
    }

    return digits;
}

static void ldoom_emit_uint(struct ldoom_format_out *out,
                            unsigned value,
                            unsigned base,
                            int width,
                            int precision,
                            int zero_pad,
                            int negative)
{
    char tmp[16];
    const char *digits = "0123456789abcdef";
    int pos = 0;
    int number_digits;
    int precision_pad = 0;
    int total;

    if (base < 2)
        base = 10;

    number_digits = ldoom_uint_digits(value, base);
    if (precision > number_digits)
        precision_pad = precision - number_digits;
    total = number_digits + precision_pad + (negative ? 1 : 0);

    if (!zero_pad || precision >= 0)
        ldoom_emit_repeat(out, ' ', width - total);

    if (negative)
        ldoom_emit_char(out, '-');

    if (zero_pad && precision < 0)
        ldoom_emit_repeat(out, '0', width - total);

    ldoom_emit_repeat(out, '0', precision_pad);

    do
    {
        tmp[pos++] = digits[value % base];
        value /= base;
    }
    while (value && pos < (int)sizeof(tmp));

    while (pos > 0)
    {
        pos--;
        ldoom_emit_char(out, tmp[pos]);
    }
}

static int ldoom_vformat(char *buf, unsigned cap, int fd, const char *fmt, va_list args)
{
    struct ldoom_format_out out;

    out.buf = buf;
    out.cap = cap;
    out.len = 0;
    out.fd = fd;

    while (*fmt)
    {
        if (*fmt != '%')
        {
            ldoom_emit_char(&out, *fmt);
            fmt++;
            continue;
        }

        fmt++;

        {
            int zero_pad = 0;
            int width = 0;
            int precision = -1;

            if (*fmt == '0')
            {
                zero_pad = 1;
                fmt++;
            }

            while (*fmt >= '0' && *fmt <= '9')
            {
                width = width * 10 + (*fmt - '0');
                fmt++;
            }

            if (*fmt == '.')
            {
                fmt++;
                precision = 0;
                if (*fmt == '0')
                    fmt++;
                while (*fmt >= '0' && *fmt <= '9')
                {
                    precision = precision * 10 + (*fmt - '0');
                    fmt++;
                }
            }

            while (*fmt == 'l')
                fmt++;

            switch (*fmt)
            {
            case 's':
            {
                const char *s = va_arg(args, const char *);
                int len = (int)ldoom_strlen(s);
                if (precision >= 0 && precision < len)
                    len = precision;
                ldoom_emit_repeat(&out, ' ', width - len);
                ldoom_emit_strn(&out, s, len);
                break;
            }
            case 'd':
            case 'i':
            {
                int value = va_arg(args, int);
                unsigned uvalue;
                int negative = value < 0;

                if (negative)
                    uvalue = 0 - (unsigned)value;
                else
                    uvalue = (unsigned)value;
                ldoom_emit_uint(&out, uvalue, 10, width, precision, zero_pad, negative);
                break;
            }
            case 'u':
                ldoom_emit_uint(&out, va_arg(args, unsigned), 10, width, precision, zero_pad, 0);
                break;
            case 'x':
            case 'X':
            case 'p':
                ldoom_emit_uint(&out, va_arg(args, unsigned), 16, width, precision, zero_pad, 0);
                break;
            case 'c':
            {
                char ch = (char)va_arg(args, int);
                ldoom_emit_repeat(&out, ' ', width - 1);
                ldoom_emit_char(&out, ch);
                break;
            }
            case '%':
                ldoom_emit_char(&out, '%');
                break;
            case 0:
                if (out.fd < 0 && out.cap > 0)
                    out.buf[out.len < out.cap ? out.len : out.cap - 1] = 0;
                return (int)out.len;
            default:
                ldoom_emit_char(&out, '%');
                ldoom_emit_char(&out, *fmt);
                break;
            }
        }

        fmt++;
    }

    if (out.fd < 0 && out.cap > 0)
        out.buf[out.len < out.cap ? out.len : out.cap - 1] = 0;

    return (int)out.len;
}

static void ldoom_vwrite_fmt(int fd, const char *fmt, va_list args)
{
    ldoom_vformat(NULL, 0, fd, fmt, args);
}

int vsnprintf(char *str, size_t size, const char *fmt, va_list args)
{
    return ldoom_vformat(str, (unsigned)size, -1, fmt, args);
}

int snprintf(char *str, size_t size, const char *fmt, ...)
{
    int ret;
    va_list args;

    va_start(args, fmt);
    ret = vsnprintf(str, size, fmt, args);
    va_end(args);
    return ret;
}

int sprintf(char *str, const char *fmt, ...)
{
    int ret;
    va_list args;

    va_start(args, fmt);
    ret = ldoom_vformat(str, (unsigned)-1, -1, fmt, args);
    va_end(args);
    return ret;
}

char *getenv(const char *name)
{
    if (ldoom_streq(name, "HOME"))
        return "/";
    if (ldoom_streq(name, "DOOMWADDIR"))
        return "/";
    return NULL;
}

int vfprintf(FILE *stream, const char *fmt, va_list args)
{
    (void)stream;
    ldoom_vwrite_fmt(2, fmt, args);
    return 0;
}

int fprintf(FILE *stream, const char *fmt, ...)
{
    va_list args;

    va_start(args, fmt);
    vfprintf(stream, fmt, args);
    va_end(args);
    return 0;
}

int printf(const char *fmt, ...)
{
    va_list args;

    va_start(args, fmt);
    ldoom_vwrite_fmt(1, fmt, args);
    va_end(args);
    return 0;
}

int fflush(FILE *stream)
{
    (void)stream;
    return 0;
}

int fputc(int c, FILE *stream)
{
    char ch = (char)c;
    int fd = stream == stderr ? 2 : 1;

    ldoom_write_raw(fd, &ch, 1);
    return c;
}

int fputs(const char *s, FILE *stream)
{
    int fd = stream == stderr ? 2 : 1;

    ldoom_write_str(fd, s);
    return 0;
}

int puts(const char *s)
{
    ldoom_write_str(1, s);
    ldoom_write_raw(1, "\n", 1);
    return 0;
}

static void ldoom_puts(const char *s)
{
    ldoom_write_str(1, s);
    ldoom_write_raw(1, "\n", 1);
}

static unsigned ldoom_frame_checksum(const byte *pixels, unsigned *nonzero)
{
    unsigned hash = 2166136261u;
    unsigned nz = 0;
    int i;

    if (!pixels)
    {
        *nonzero = 0;
        return 0;
    }

    for (i = 0; i < LDOOM_FRAME_BYTES; i++)
    {
        unsigned v = pixels[i];
        nz += (v != 0);
        hash ^= v;
        hash *= 16777619u;
    }

    *nonzero = nz;
    return hash;
}

int main(void)
{
    static char *argv[] = {
        "ldoom",
        "-warp", "1", "1",
        "-skill", "3",
        NULL
    };

    myargc = 6;
    myargv = argv;

    ldoom_puts("ldoom linux personality start");
    D_DoomMain();
    return 0;
}

void I_Tactile(int on, int off, int total)
{
    (void)on;
    (void)off;
    (void)total;
}

ticcmd_t *I_BaseTiccmd(void)
{
    memset(&ldoom_empty_cmd, 0, sizeof(ldoom_empty_cmd));
    return &ldoom_empty_cmd;
}

int I_GetHeapSize(void)
{
    return LDOOM_ZONE_BYTES;
}

byte *I_ZoneBase(int *size)
{
    byte *zone;

    *size = LDOOM_ZONE_BYTES;
    zone = malloc(*size);
    if (!zone)
        I_Error("linux doom: zone malloc failed");
    return zone;
}

int I_GetTime(void)
{
    return ++ldoom_tics;
}

void I_Init(void)
{
    I_InitSound();
    I_InitGraphics();
}

void I_Quit(void)
{
    ldoom_puts("ldoom quit");
    _exit(0);
}

void I_WaitVBL(int count)
{
    (void)count;
}

void I_BeginRead(void)
{
}

void I_EndRead(void)
{
}

byte *I_AllocLow(int length)
{
    byte *mem = malloc(length);
    if (!mem)
        I_Error("linux doom: low malloc failed");
    memset(mem, 0, length);
    return mem;
}

void I_Error(char *error, ...)
{
    va_list argptr;

    va_start(argptr, error);
    fputs("ldoom error: ", stderr);
    vfprintf(stderr, error, argptr);
    fputc('\n', stderr);
    va_end(argptr);
    fflush(stderr);
    _exit(1);
}

void I_StartFrame(void)
{
}

void I_StartTic(void)
{
}

void I_InitGraphics(void)
{
}

void I_ShutdownGraphics(void)
{
}

void I_SetPalette(byte *palette)
{
    (void)palette;
}

void I_UpdateNoBlit(void)
{
}

void I_FinishUpdate(void)
{
    unsigned nonzero;
    unsigned checksum;

    ldoom_frames++;
    checksum = ldoom_frame_checksum(screens[0], &nonzero);
    printf("ldoom frame=%d checksum=%08x nonzero=%u\n",
           ldoom_frames, checksum, nonzero);
    fflush(stdout);

    if (nonzero != 0)
        _exit(0);

    if (ldoom_frames >= 16)
        _exit(2);
}

void I_ReadScreen(byte *scr)
{
    memcpy(scr, screens[0], LDOOM_FRAME_BYTES);
}

void I_InitNetwork(void)
{
    memset(&ldoom_doomcom, 0, sizeof(ldoom_doomcom));
    ldoom_doomcom.id = DOOMCOM_ID;
    ldoom_doomcom.numnodes = 1;
    ldoom_doomcom.ticdup = 1;
    ldoom_doomcom.consoleplayer = 0;
    ldoom_doomcom.numplayers = 1;
    doomcom = &ldoom_doomcom;
    netgame = false;
    singletics = true;
}

void I_NetCmd(void)
{
    if (doomcom)
        doomcom->remotenode = -1;
}

void I_InitSound(void)
{
}

void I_UpdateSound(void)
{
}

void I_SubmitSound(void)
{
}

void I_ShutdownSound(void)
{
}

void I_SetChannels(void)
{
}

int I_GetSfxLumpNum(sfxinfo_t *sfx)
{
    char namebuf[9];

    snprintf(namebuf, sizeof(namebuf), "ds%s", sfx->name);
    return W_CheckNumForName(namebuf);
}

int I_StartSound(int id, int vol, int sep, int pitch, int priority)
{
    (void)id;
    (void)vol;
    (void)sep;
    (void)pitch;
    (void)priority;
    return 0;
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

int I_RegisterSong(void *data)
{
    (void)data;
    return 0;
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
