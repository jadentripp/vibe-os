#include <fcntl.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

#include "doomdef.h"
#include "doomstat.h"
#include "hu_stuff.h"
#include "m_swap.h"
#include "m_misc.h"
#include "v_video.h"

char* defaultfile;

extern patch_t* hu_font[HU_FONTSIZE];

static int pi4_m_toupper(int ch)
{
    if (ch >= 'a' && ch <= 'z')
        return ch - ('a' - 'A');
    return ch;
}

int M_DrawText(int x, int y, boolean direct, char* string)
{
    int c;
    int w;

    while (string && *string) {
        c = pi4_m_toupper((unsigned char)*string) - HU_FONTSTART;
        string++;
        if (c < 0 || c >= HU_FONTSIZE || !hu_font[c]) {
            x += 4;
            continue;
        }

        w = SHORT(hu_font[c]->width);
        if (x + w > SCREENWIDTH)
            break;
        if (direct)
            V_DrawPatchDirect(x, y, 0, hu_font[c]);
        else
            V_DrawPatch(x, y, 0, hu_font[c]);
        x += w;
    }

    return x;
}

boolean M_WriteFile(char const* name, void* source, int length)
{
    int handle = open(name, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    int written;
    if (handle < 0)
        return false;
    written = (int)write(handle, source, (size_t)length);
    close(handle);
    return written == length;
}

int M_ReadFile(char const* name, byte** buffer)
{
    int handle;
    struct stat st;
    int length;
    int total;
    int got;

    if (!buffer)
        return 0;
    *buffer = NULL;
    handle = open(name, O_RDONLY | O_BINARY);
    if (handle < 0)
        return 0;
    if (fstat(handle, &st) < 0) {
        close(handle);
        return 0;
    }
    length = (int)st.st_size;
    *buffer = (byte*)malloc((size_t)length);
    if (!*buffer) {
        close(handle);
        return 0;
    }
    total = 0;
    while (total < length) {
        got = (int)read(handle, *buffer + total, (size_t)(length - total));
        if (got <= 0)
            break;
        total += got;
    }
    close(handle);
    if (total != length) {
        free(*buffer);
        *buffer = NULL;
        return 0;
    }
    return length;
}

void M_SaveDefaults(void)
{
}

void M_LoadDefaults(void)
{
    defaultfile = basedefault;
}

void WritePCXfile(char* filename, byte* data, int width, int height, byte* palette)
{
    (void)filename;
    (void)data;
    (void)width;
    (void)height;
    (void)palette;
}

void M_ScreenShot(void)
{
}
