#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "d_event.h"
#include "d_main.h"
#include "d_net.h"
#include "doomstat.h"
#include "i_net.h"
#include "i_sound.h"
#include "i_system.h"
#include "i_video.h"
#include "vibe_os.h"
#include "v_video.h"
#include "w_wad.h"
#include "z_zone.h"

extern doomcom_t* doomcom;

static byte doom_zone[8 * 1024 * 1024];
static doomcom_t local_doomcom;
static ticcmd_t empty_ticcmd;
static byte active_palette[256 * 3];
static int next_sound_handle = 1;

static int vibe_mouse_delta(unsigned int packed, int shift)
{
    return (int)(signed char)((packed >> shift) & 0xffu);
}

int mb_used = 8;
FILE* sndserver = 0;
char* sndserver_filename = "sndserver";

void I_Init(void)
{
}

byte* I_ZoneBase(int* size)
{
    *size = sizeof(doom_zone);
    return doom_zone;
}

int I_GetTime(void)
{
    return vibe_syscall3(VIBE_SYS_TIME, 0, 0, 0);
}

void I_StartFrame(void)
{
}

void I_StartTic(void)
{
    int i;
    int packed;
    event_t event;

    for (i = 0; i < 32; ++i) {
        packed = vibe_syscall3(VIBE_SYS_POLL_KEY, 0, 0, 0);
        if (!(packed & VIBE_KEY_EVENT_VALID))
            break;

        event.type = (packed & VIBE_KEY_EVENT_DOWN) ? ev_keydown : ev_keyup;
        event.data1 = packed & 0xff;
        event.data2 = 0;
        event.data3 = 0;
        D_PostEvent(&event);
    }

    for (i = 0; i < 32; ++i) {
        packed = vibe_syscall3(VIBE_SYS_POLL_MOUSE, 0, 0, 0);
        if (!((unsigned int)packed & VIBE_MOUSE_EVENT_VALID))
            break;

        event.type = ev_mouse;
        event.data1 = packed & 0x07;
        event.data2 = vibe_mouse_delta((unsigned int)packed, 8);
        event.data3 = vibe_mouse_delta((unsigned int)packed, 16);
        D_PostEvent(&event);
    }
}

ticcmd_t* I_BaseTiccmd(void)
{
    memset(&empty_ticcmd, 0, sizeof(empty_ticcmd));
    return &empty_ticcmd;
}

void I_Quit(void)
{
    exit(0);
}

byte* I_AllocLow(int length)
{
    return (byte*)malloc((size_t)length);
}

void I_Tactile(int on, int off, int total)
{
    (void)on;
    (void)off;
    (void)total;
}

void I_Error(char* error, ...)
{
    char buffer[256];
    va_list args;

    va_start(args, error);
    vsnprintf(buffer, sizeof(buffer), error, args);
    va_end(args);

    fprintf(stderr, "doom error: %s\n", buffer);
    exit(1);
}

void I_InitGraphics(void)
{
}

void I_ShutdownGraphics(void)
{
}

void I_SetPalette(byte* palette)
{
    memcpy(active_palette, palette, sizeof(active_palette));
}

void I_UpdateNoBlit(void)
{
}

static void report_gameplay_status(void)
{
    unsigned long packed = ((unsigned long)(gamestate & 0xff))
        | ((unsigned long)(gameepisode & 0xff) << 8)
        | ((unsigned long)(gamemap & 0xff) << 16)
        | ((unsigned long)(menuactive ? 1 : 0) << 24)
        | ((unsigned long)(automapactive ? 1 : 0) << 25)
        | ((unsigned long)(paused ? 1 : 0) << 26);

    (void)vibe_syscall3(
        VIBE_SYS_GAMEPLAY_STATUS,
        packed,
        (unsigned long)gametic,
        (unsigned long)leveltime);
}

void I_FinishUpdate(void)
{
    report_gameplay_status();
    if (screens[0])
        (void)vibe_syscall3(VIBE_SYS_PRESENT, (unsigned int)screens[0], (unsigned int)active_palette, 0);
}

void I_WaitVBL(int count)
{
    (void)count;
}

void I_ReadScreen(byte* scr)
{
    if (screens[0])
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
    memset(&local_doomcom, 0, sizeof(local_doomcom));
    local_doomcom.id = DOOMCOM_ID;
    local_doomcom.numnodes = 1;
    local_doomcom.ticdup = 1;
    local_doomcom.extratics = 0;
    local_doomcom.consoleplayer = 0;
    local_doomcom.numplayers = 1;
    doomcom = &local_doomcom;
    netgame = false;
}

void I_NetCmd(void)
{
    if (doomcom)
        doomcom->remotenode = -1;
}

void I_InitSound(void)
{
    (void)vibe_syscall3(VIBE_SYS_AUDIO, VIBE_AUDIO_INIT, 0, 0);
}

void I_UpdateSound(void)
{
}

void I_SubmitSound(void)
{
}

void I_ShutdownSound(void)
{
    (void)vibe_syscall3(VIBE_SYS_AUDIO, VIBE_AUDIO_SHUTDOWN, 0, 0);
}

void I_SetChannels(void)
{
}

int I_GetSfxLumpNum(sfxinfo_t* sfxinfo)
{
    char name[9];
    name[0] = 'd';
    name[1] = 's';
    strncpy(name + 2, sfxinfo->name, 6);
    name[8] = 0;
    return W_GetNumForName(name);
}

int I_StartSound(int id, int vol, int sep, int pitch, int priority)
{
    (void)priority;
    {
        int handle = next_sound_handle++;
        vibe_audio_sfx_desc_t desc;
        sfxinfo_t* sfx = &S_sfx[id];
        int lump_length;
        unsigned char* lump_data;

        if (sfx->link)
            sfx = sfx->link;

        if (sfx->lumpnum < 0)
            sfx->lumpnum = I_GetSfxLumpNum(sfx);

        if (!sfx->data)
            sfx->data = W_CacheLumpNum(sfx->lumpnum, PU_STATIC);

        lump_length = W_LumpLength(sfx->lumpnum);
        lump_data = (unsigned char*)sfx->data;

        memset(&desc, 0, sizeof(desc));
        if (lump_length > 8 && lump_data) {
            desc.samples = lump_data + 8;
            desc.length = (unsigned long)(lump_length - 8);
        }
        desc.volume = (unsigned long)(vol & 0xff);
        desc.separation = (unsigned long)(sep & 0xff);
        desc.pitch = (unsigned long)(pitch & 0xff);
        desc.sound_id = (unsigned long)id;

        (void)vibe_syscall3(
            VIBE_SYS_AUDIO,
            VIBE_AUDIO_START_SFX,
            (unsigned long)handle,
            (unsigned long)&desc);
        return handle;
    }
}

void I_StopSound(int handle)
{
    (void)vibe_syscall3(VIBE_SYS_AUDIO, VIBE_AUDIO_STOP_SFX, (unsigned long)handle, 0);
}

int I_SoundIsPlaying(int handle)
{
    (void)handle;
    return 0;
}

void I_UpdateSoundParams(int handle, int vol, int sep, int pitch)
{
    vibe_audio_sfx_desc_t desc;

    memset(&desc, 0, sizeof(desc));
    desc.volume = (unsigned long)(vol & 0xff);
    desc.separation = (unsigned long)(sep & 0xff);
    desc.pitch = (unsigned long)(pitch & 0xff);

    (void)vibe_syscall3(
        VIBE_SYS_AUDIO,
        VIBE_AUDIO_UPDATE_SFX,
        (unsigned long)handle,
        (unsigned long)&desc);
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
    return 1;
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
