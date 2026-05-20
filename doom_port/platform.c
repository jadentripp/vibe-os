#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>

#include "d_event.h"
#include "d_main.h"
#include "d_net.h"
#include "doomstat.h"
#include "i_net.h"
#include "i_sound.h"
#include "i_system.h"
#include "i_video.h"
#include "input.h"
#include "m_misc.h"
#include "music.h"
#include "p_mobj.h"
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
static unsigned char music_pcm[VIBE_MUSIC_RENDER_BYTES];
static int current_music_handle;
static int current_music_looping;
static int current_music_paused;
static int current_music_volume = 127;
static unsigned long playable_proof_flags;
static int playable_origin_set;
static int playable_origin_x;
static int playable_origin_y;
static int playable_initial_clip = -1;

#define VIBE_MUSIC_AUDIO_HANDLE_BASE 0x4d550000u

static void report_doom_init_status(unsigned long flags)
{
    (void)vibe_syscall3(VIBE_SYS_GAMEPLAY_STATUS, VIBE_DOOM_INIT_STATUS | flags, 0, 0);
}

static int vibe_music_audio_handle(int handle)
{
    return (int)(VIBE_MUSIC_AUDIO_HANDLE_BASE | ((unsigned int)handle & 0xffffu));
}

static void submit_music_pcm(int handle, int looping)
{
    vibe_audio_sfx_desc_t desc;
    vibe_music_render_stats_t stats;
    unsigned long rendered;

    rendered = vibe_music_render_song(
        handle,
        music_pcm,
        sizeof(music_pcm),
        VIBE_MUSIC_DEFAULT_SAMPLE_RATE,
        (unsigned long)current_music_volume,
        looping,
        &stats);

    if (!rendered)
        return;

    memset(&desc, 0, sizeof(desc));
    desc.samples = music_pcm;
    desc.length = rendered;
    desc.volume = 127;
    desc.separation = 128;
    desc.pitch = 128;
    desc.sound_id = 0x4d555349u;
    desc.flags = VIBE_AUDIO_FLAG_MUSIC;
    if (looping)
        desc.flags |= VIBE_AUDIO_FLAG_LOOP;

    (void)vibe_syscall3(
        VIBE_SYS_AUDIO,
        VIBE_AUDIO_START_SFX,
        (unsigned long)vibe_music_audio_handle(handle),
        (unsigned long)&desc);
}

int mb_used = 8;
FILE* sndserver = 0;
char* sndserver_filename = "sndserver";

void I_Init(void)
{
    report_doom_init_status(VIBE_DOOM_INIT_I_INIT);
}

byte* I_ZoneBase(int* size)
{
    report_doom_init_status(VIBE_DOOM_INIT_ZONE);
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
    vibe_doom_input_event_t translated;

    report_doom_init_status(VIBE_DOOM_INIT_TIC);

    for (i = 0; i < 32; ++i) {
        packed = vibe_syscall3(VIBE_SYS_POLL_KEY, 0, 0, 0);
        if (!vibe_doom_translate_key_event((unsigned int)packed, &translated))
            break;

        event.type = translated.type == VIBE_DOOM_INPUT_KEYDOWN ? ev_keydown : ev_keyup;
        event.data1 = translated.data1;
        event.data2 = translated.data2;
        event.data3 = translated.data3;
        D_PostEvent(&event);
    }

    for (i = 0; i < 32; ++i) {
        packed = vibe_syscall3(VIBE_SYS_POLL_MOUSE, 0, 0, 0);
        if (!vibe_doom_translate_mouse_event((unsigned int)packed, &translated))
            break;

        event.type = ev_mouse;
        event.data1 = translated.data1;
        event.data2 = translated.data2;
        event.data3 = translated.data3;
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
    D_QuitNetGame();
    I_ShutdownSound();
    I_ShutdownMusic();
    M_SaveDefaults();
    I_ShutdownGraphics();
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
    report_doom_init_status(VIBE_DOOM_INIT_GRAPHICS);
}

void I_ShutdownGraphics(void)
{
}

void I_SetPalette(byte* palette)
{
    report_doom_init_status(VIBE_DOOM_INIT_PALETTE);
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

static void report_playability_status(void)
{
    unsigned long buttons = 0;
    unsigned long action = (unsigned long)gameaction & 0x7fu;
    int x = 0;
    int y = 0;

    if (menuactive)
        playable_proof_flags |= VIBE_PLAYABLE_SEEN_MENU;

    if (consoleplayer >= 0 && consoleplayer < MAXPLAYERS && playeringame[consoleplayer]) {
        player_t* player = &players[consoleplayer];

        playable_proof_flags |= VIBE_PLAYABLE_SEEN_PLAYER;
        buttons = (unsigned long)player->cmd.buttons & 0xffu;

        if (player->cmd.forwardmove || player->cmd.sidemove || player->cmd.angleturn)
            playable_proof_flags |= VIBE_PLAYABLE_SEEN_MOVE_CMD;
        if (player->cmd.buttons & BT_ATTACK)
            playable_proof_flags |= VIBE_PLAYABLE_SEEN_ATTACK_CMD;
        if (player->cmd.buttons & BT_USE)
            playable_proof_flags |= VIBE_PLAYABLE_SEEN_USE_CMD;
        if (player->refire > 0)
            playable_proof_flags |= VIBE_PLAYABLE_SEEN_REFIRE;

        if (playable_initial_clip < 0)
            playable_initial_clip = player->ammo[am_clip];
        else if (player->ammo[am_clip] != playable_initial_clip)
            playable_proof_flags |= VIBE_PLAYABLE_SEEN_AMMO_DELTA;

        if (player->mo) {
            x = player->mo->x;
            y = player->mo->y;
            if (!playable_origin_set) {
                playable_origin_set = 1;
                playable_origin_x = x;
                playable_origin_y = y;
            } else if (x != playable_origin_x || y != playable_origin_y) {
                playable_proof_flags |= VIBE_PLAYABLE_SEEN_POS_DELTA;
            }
        }
    }

    (void)vibe_syscall3(
        VIBE_SYS_GAMEPLAY_STATUS,
        VIBE_PLAYABLE_STATUS
            | (playable_proof_flags & 0xffffu)
            | ((buttons & 0xffu) << 16)
            | ((action & 0x7fu) << 24),
        (unsigned long)x,
        (unsigned long)y);
}

void I_FinishUpdate(void)
{
    vibe_present_indexed_t present;

    report_doom_init_status(VIBE_DOOM_INIT_FRAME);
    report_gameplay_status();
    report_playability_status();
    if (screens[0]) {
        present.frame = screens[0];
        present.palette = active_palette;
        present.width = SCREENWIDTH;
        present.height = SCREENHEIGHT;
        (void)ioctl(VIBE_DISPLAY_FD, VIBE_IOCTL_PRESENT_INDEXED, &present);
    }
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
    report_doom_init_status(VIBE_DOOM_INIT_NETWORK);
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
    report_doom_init_status(VIBE_DOOM_INIT_SOUND);
    vibe_music_init();
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
    report_doom_init_status(VIBE_DOOM_INIT_SOUND);
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
        desc.flags = 0;

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
    return vibe_syscall3(VIBE_SYS_AUDIO, VIBE_AUDIO_IS_PLAYING, (unsigned long)handle, 0) > 0;
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
    vibe_music_init();
}

void I_ShutdownMusic(void)
{
    if (current_music_handle)
        (void)vibe_syscall3(
            VIBE_SYS_AUDIO,
            VIBE_AUDIO_STOP_SFX,
            (unsigned long)vibe_music_audio_handle(current_music_handle),
            0);
    current_music_handle = 0;
    current_music_looping = 0;
    current_music_paused = 0;
}

void I_SetMusicVolume(int volume)
{
    if (volume < 0)
        volume = 0;
    if (volume <= 15)
        volume = volume * 8 + 7;
    if (volume > 127)
        volume = 127;
    current_music_volume = volume;
}

void I_PauseSong(int handle)
{
    if (handle <= 0)
        return;
    current_music_paused = 1;
    (void)vibe_syscall3(
        VIBE_SYS_AUDIO,
        VIBE_AUDIO_STOP_SFX,
        (unsigned long)vibe_music_audio_handle(handle),
        0);
}

void I_ResumeSong(int handle)
{
    if (handle <= 0 || !current_music_paused)
        return;
    current_music_paused = 0;
    submit_music_pcm(handle, current_music_looping);
}

int I_RegisterSong(void* data)
{
    return vibe_music_register_song(data);
}

void I_PlaySong(int handle, int looping)
{
    if (handle <= 0)
        return;
    current_music_handle = handle;
    current_music_looping = looping;
    current_music_paused = 0;
    submit_music_pcm(handle, looping);
}

void I_StopSong(int handle)
{
    if (handle <= 0)
        return;
    (void)vibe_syscall3(
        VIBE_SYS_AUDIO,
        VIBE_AUDIO_STOP_SFX,
        (unsigned long)vibe_music_audio_handle(handle),
        0);
    if (current_music_handle == handle) {
        current_music_handle = 0;
        current_music_looping = 0;
        current_music_paused = 0;
    }
}

void I_UnRegisterSong(int handle)
{
    vibe_music_unregister_song(handle);
}
