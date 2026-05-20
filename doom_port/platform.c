#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/stat.h>

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
extern char* defaultfile;
extern boolean sendsave;
extern int savegameslot;
extern char savedescription[32];
void doom_original_G_BuildTiccmd(ticcmd_t* cmd);
void doom_original_G_Ticker(void);
void G_SaveGame(int slot, char* description);
void G_DoSaveGame(void);
void G_LoadGame(char* name);

static byte doom_zone[8 * 1024 * 1024];
static doomcom_t local_doomcom;
static char default_config_check_buffer[16 * 1024 + 1];
static ticcmd_t empty_ticcmd;
static byte active_palette[256 * 3];
static int next_sound_handle = 1;
static unsigned char* cached_sfx_samples[NUMSFX];
static unsigned long cached_sfx_lengths[NUMSFX];
static unsigned long cached_sfx_rates[NUMSFX];
static unsigned long cached_sfx_flags[NUMSFX];
static unsigned char music_pcm[2][VIBE_MUSIC_STREAM_BYTES];
static int current_music_handle;
static int current_music_looping;
static int current_music_paused;
static int current_music_volume = 127;
static unsigned int current_music_buffer;
static int current_music_next_tic;
static unsigned long current_music_pull_seen;
static unsigned long playable_proof_flags;
static int playable_origin_set;
static int playable_origin_x;
static int playable_origin_y;
static unsigned int playable_origin_angle;
static int playable_initial_clip = -1;
static int default_config_checkpoint_checked;
static int default_config_checkpoint_request_checked;
static int default_config_checkpoint_requested;
static int save_checkpoint_request_checked;
static int save_checkpoint_requested;
static int save_checkpoint_slot;
static int save_checkpoint_done;
static int load_checkpoint_request_checked;
static int load_checkpoint_requested;
static int load_checkpoint_slot;
static int load_checkpoint_done;

#define VIBE_MUSIC_AUDIO_HANDLE_BASE 0x4d550000u
#define VIBE_SFX_DEFAULT_SAMPLE_RATE 11025u
#define VIBE_SFX_PAD_BYTES 512u
#define VIBE_MUSIC_STREAM_TICS \
    ((int)((VIBE_MUSIC_STREAM_BYTES * 35u) / VIBE_MUSIC_DEFAULT_SAMPLE_RATE) / 16)
#define VIBE_DOOM_SAVE_SCRATCH_BYTES 0x2c000u
#define VIBE_PERSISTENCE_MIN_LEVELTIME 32

static void report_doom_init_status(unsigned long flags)
{
    (void)vibe_syscall3(VIBE_SYS_GAMEPLAY_STATUS, VIBE_DOOM_INIT_STATUS | flags, 0, 0);
}

static int vibe_music_audio_handle(int handle)
{
    return (int)(VIBE_MUSIC_AUDIO_HANDLE_BASE | ((unsigned int)handle & 0xffffu));
}

static int music_stream_tics(void)
{
    return VIBE_MUSIC_STREAM_TICS > 1 ? VIBE_MUSIC_STREAM_TICS : 1;
}

static unsigned long read_le16(const unsigned char* data)
{
    return (unsigned long)data[0] | ((unsigned long)data[1] << 8);
}

static unsigned long read_le32(const unsigned char* data)
{
    return (unsigned long)data[0]
        | ((unsigned long)data[1] << 8)
        | ((unsigned long)data[2] << 16)
        | ((unsigned long)data[3] << 24);
}

static void report_save_action_status(void);

static int sfx_cache_index(sfxinfo_t* sfx, int fallback)
{
    int index;

    index = (int)(sfx - S_sfx);
    if (index > 0 && index < NUMSFX)
        return index;
    if (fallback > 0 && fallback < NUMSFX)
        return fallback;
    return 0;
}

static unsigned long pad_sfx_length(unsigned long length)
{
    if (!length)
        return 0;
    return ((length + VIBE_SFX_PAD_BYTES - 1u) / VIBE_SFX_PAD_BYTES) * VIBE_SFX_PAD_BYTES;
}

static unsigned char* cache_sfx_samples(
    int id,
    sfxinfo_t* sfx,
    unsigned long* out_length,
    unsigned long* out_rate,
    unsigned long* out_flags)
{
    int index;
    int lump_length;
    unsigned long raw_length;
    unsigned long padded_length;
    unsigned long sample_rate;
    unsigned long declared_length;
    unsigned long flags;
    unsigned char* lump_data;
    unsigned char* samples;

    index = sfx_cache_index(sfx, id);
    if (index <= 0)
        return 0;

    if (cached_sfx_samples[index]) {
        *out_length = cached_sfx_lengths[index];
        *out_rate = cached_sfx_rates[index];
        *out_flags = cached_sfx_flags[index];
        return cached_sfx_samples[index];
    }

    if (sfx->lumpnum < 0)
        sfx->lumpnum = I_GetSfxLumpNum(sfx);

    if (!sfx->data)
        sfx->data = W_CacheLumpNum(sfx->lumpnum, PU_STATIC);

    lump_length = W_LumpLength(sfx->lumpnum);
    lump_data = (unsigned char*)sfx->data;
    if (lump_length <= 8 || !lump_data)
        return 0;

    raw_length = (unsigned long)(lump_length - 8);
    padded_length = pad_sfx_length(raw_length);
    if (!padded_length)
        return 0;

    sample_rate = read_le16(lump_data + 2);
    if (!sample_rate)
        sample_rate = VIBE_SFX_DEFAULT_SAMPLE_RATE;

    flags = 0;
    declared_length = read_le32(lump_data + 4);
    if (read_le16(lump_data) == 3u
        && declared_length > 0
        && declared_length <= raw_length + VIBE_SFX_PAD_BYTES) {
        flags |= VIBE_AUDIO_FLAG_WAD_SFX;
    }

    samples = (unsigned char*)Z_Malloc(padded_length, PU_STATIC, 0);
    memcpy(samples, lump_data + 8, raw_length);
    if (padded_length > raw_length)
        memset(samples + raw_length, 128, padded_length - raw_length);

    cached_sfx_samples[index] = samples;
    cached_sfx_lengths[index] = padded_length;
    cached_sfx_rates[index] = sample_rate;
    cached_sfx_flags[index] = flags;

    *out_length = padded_length;
    *out_rate = sample_rate;
    *out_flags = flags;
    return samples;
}

static int submit_music_stream_chunk(int handle, int start_voice)
{
    vibe_audio_sfx_desc_t desc;
    vibe_music_render_stats_t stats;
    unsigned long rendered;
    unsigned int buffer_index;

    buffer_index = current_music_buffer ^ 1u;
    rendered = vibe_music_stream_render(
        handle,
        music_pcm[buffer_index],
        VIBE_MUSIC_STREAM_BYTES,
        &stats);

    if (!rendered) {
        if (!current_music_looping && current_music_handle == handle) {
            (void)vibe_syscall3(
                VIBE_SYS_AUDIO,
                VIBE_AUDIO_STOP_SFX,
                (unsigned long)vibe_music_audio_handle(handle),
                0);
            current_music_handle = 0;
            current_music_next_tic = 0;
            vibe_music_stream_stop(handle);
        }
        return 0;
    }

    current_music_buffer = buffer_index;

    memset(&desc, 0, sizeof(desc));
    desc.samples = music_pcm[current_music_buffer];
    desc.length = rendered;
    desc.volume = 127;
    desc.separation = 128;
    desc.pitch = 128;
    desc.sound_id = 0x4d555349u;
    desc.flags = VIBE_AUDIO_FLAG_MUSIC;
    if (!current_music_looping
        && stats.stream_song_samples
        && stats.stream_end_sample >= stats.stream_song_samples) {
        desc.flags |= VIBE_AUDIO_FLAG_STREAM_FINAL;
    }
    desc.sample_rate = VIBE_MUSIC_DEFAULT_SAMPLE_RATE;
    desc.music_format = stats.format;
    desc.music_note_events = stats.note_on_count + stats.note_off_count;
    desc.music_control_events = stats.controller_count
        + stats.program_count
        + stats.pan_count
        + stats.expression_count
        + stats.sustain_count
        + stats.pitch_bend_count
        + stats.tempo_count
        + stats.all_notes_off_count;
    desc.music_active_voice_peak = stats.active_voice_peak;
    desc.music_emitted_samples = stats.emitted_samples;
    desc.music_stream_start = stats.stream_start_sample;
    desc.music_stream_end = stats.stream_end_sample;
    desc.music_stream_loop_count = stats.stream_loop_count;

    (void)vibe_syscall3(
        VIBE_SYS_AUDIO,
        start_voice ? VIBE_AUDIO_START_SFX : VIBE_AUDIO_UPDATE_SFX,
        (unsigned long)vibe_music_audio_handle(handle),
        (unsigned long)&desc);
    return 1;
}

static void stop_music_stream_handle(int handle)
{
    if (handle <= 0)
        return;

    (void)vibe_syscall3(
        VIBE_SYS_AUDIO,
        VIBE_AUDIO_STOP_SFX,
        (unsigned long)vibe_music_audio_handle(handle),
        0);
    vibe_music_stream_stop(handle);
}

static int default_config_contains_marker(size_t length, const char* marker)
{
    size_t marker_length;
    size_t index;

    marker_length = strlen(marker);
    if (marker_length == 0)
        return 1;
    if (marker_length > length)
        return 0;

    for (index = 0; index <= length - marker_length; ++index) {
        if (memcmp(default_config_check_buffer + index, marker, marker_length) == 0)
            return 1;
    }
    return 0;
}

static int default_config_needs_checkpoint(void)
{
    const char* path;
    FILE* file;
    size_t length;

    path = defaultfile ? defaultfile : "DEFAULT.CFG";
    file = fopen(path, "r");
    if (!file)
        return 1;

    length = fread(
        default_config_check_buffer,
        1,
        sizeof(default_config_check_buffer) - 1,
        file);
    fclose(file);
    default_config_check_buffer[length] = 0;

    return length == 0
        || default_config_check_buffer[length - 1] != '\n'
        || !default_config_contains_marker(length, "mouse_sensitivity")
        || !default_config_contains_marker(length, "use_mouse")
        || !default_config_contains_marker(length, "screenblocks")
        || !default_config_contains_marker(length, "chatmacro0");
}

static int persistence_checkpoint_requested(void)
{
    struct stat info;

    if (default_config_checkpoint_request_checked)
        return default_config_checkpoint_requested;
    if (default_config_checkpoint_requested)
        return default_config_checkpoint_requested;

    default_config_checkpoint_request_checked = 1;
    if (stat("PERSIST.CHK", &info) == 0)
        default_config_checkpoint_requested = 1;

    return default_config_checkpoint_requested;
}

static int read_persistence_slot_request(const char* path, int* slot)
{
    struct stat info;

    if (!slot)
        return 0;

    *slot = 0;
    if (stat(path, &info) < 0)
        return 0;

    if (info.st_size < 1 || info.st_size > 6)
        return 0;

    *slot = (int)info.st_size - 1;
    return 1;
}

static int save_checkpoint_requested_once(void)
{
    if (save_checkpoint_requested)
        return save_checkpoint_requested;
    if (save_checkpoint_request_checked)
        return save_checkpoint_requested;

    save_checkpoint_request_checked = 1;
    save_checkpoint_requested = read_persistence_slot_request(
        "SAVEREQ.CHK",
        &save_checkpoint_slot);
    if (!save_checkpoint_requested)
        save_checkpoint_request_checked = 0;
    return save_checkpoint_requested;
}

static int load_checkpoint_requested_once(void)
{
    if (load_checkpoint_requested)
        return load_checkpoint_requested;
    if (load_checkpoint_request_checked)
        return load_checkpoint_requested;

    load_checkpoint_request_checked = 1;
    load_checkpoint_requested = read_persistence_slot_request(
        "LOADREQ.CHK",
        &load_checkpoint_slot);
    if (!load_checkpoint_requested)
        load_checkpoint_request_checked = 0;
    return load_checkpoint_requested;
}

static int default_config_checkpoint_ready(void)
{
    return gamestate == GS_LEVEL
        && gameepisode > 0
        && gamemap > 0
        && gametic > 0
        && leveltime >= VIBE_PERSISTENCE_MIN_LEVELTIME
        && consoleplayer >= 0
        && consoleplayer < MAXPLAYERS
        && playeringame[consoleplayer]
        && players[consoleplayer].mo;
}

static void cache_persistence_requests(void)
{
    (void)persistence_checkpoint_requested();
    (void)save_checkpoint_requested_once();
    (void)load_checkpoint_requested_once();
}

static void checkpoint_default_config_if_needed(void)
{
    if (default_config_checkpoint_checked || !defaultfile)
        return;

    if (!default_config_checkpoint_ready() || !persistence_checkpoint_requested())
        return;

    default_config_checkpoint_checked = 1;
    if (default_config_needs_checkpoint())
        M_SaveDefaults();
}

static void checkpoint_save_slot_if_needed(void)
{
    static char description[] = "VIBE SAVE";

    if (save_checkpoint_done)
        return;
    if (!default_config_checkpoint_ready()
        || menuactive
        || sendsave
        || savedescription[0]
        || gameaction != ga_nothing) {
        return;
    }
    if (!save_checkpoint_requested_once())
        return;

    report_save_action_status();
    G_SaveGame(save_checkpoint_slot, description);
    sendsave = false;
    gameaction = ga_savegame;
    G_DoSaveGame();
    save_checkpoint_done = 1;
}

static void checkpoint_load_slot_if_needed(void)
{
    char path[] = "doomsav0.dsg";

    if (load_checkpoint_done)
        return;
    if (!default_config_checkpoint_ready()
        || menuactive
        || sendsave
        || savedescription[0]
        || gameaction != ga_nothing) {
        return;
    }
    if (!load_checkpoint_requested_once())
        return;

    path[7] = (char)('0' + load_checkpoint_slot);
    G_LoadGame(path);
    load_checkpoint_done = 1;
}

static void pump_music_stream(void)
{
    int now;
    int start_voice;
    unsigned long pull_request;

    if (current_music_handle <= 0 || current_music_paused)
        return;

    now = I_GetTime();
    if (current_music_next_tic && now < current_music_next_tic)
        return;

    start_voice = vibe_syscall3(
        VIBE_SYS_AUDIO,
        VIBE_AUDIO_IS_PLAYING,
        (unsigned long)vibe_music_audio_handle(current_music_handle),
        0) <= 0;
    if (start_voice) {
        if (submit_music_stream_chunk(current_music_handle, start_voice)) {
            current_music_pull_seen = vibe_syscall3(
                VIBE_SYS_AUDIO,
                VIBE_AUDIO_MUSIC_PULL_STATE,
                (unsigned long)vibe_music_audio_handle(current_music_handle),
                0);
            current_music_next_tic = now + music_stream_tics();
        } else {
            current_music_next_tic = 0;
        }
        return;
    }

    pull_request = vibe_syscall3(
        VIBE_SYS_AUDIO,
        VIBE_AUDIO_MUSIC_PULL_STATE,
        (unsigned long)vibe_music_audio_handle(current_music_handle),
        0);
    if (pull_request == current_music_pull_seen) {
        current_music_next_tic = now + 1;
        return;
    }

    if (submit_music_stream_chunk(current_music_handle, start_voice)) {
        current_music_pull_seen = pull_request;
        current_music_next_tic = now + music_stream_tics();
    } else {
        current_music_next_tic = 0;
    }
}

int mb_used = 8;
FILE* sndserver = 0;
char* sndserver_filename = "sndserver";

void I_Init(void)
{
    report_doom_init_status(VIBE_DOOM_INIT_I_INIT);
    cache_persistence_requests();
}

byte* I_ZoneBase(int* size)
{
    report_doom_init_status(VIBE_DOOM_INIT_ZONE);
    cache_persistence_requests();
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
    pump_music_stream();

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
    byte* mem;
    size_t bytes;

    if (length <= 0)
        return 0;

    bytes = (size_t)length + VIBE_DOOM_SAVE_SCRATCH_BYTES;
    mem = (byte*)malloc(bytes);
    if (!mem)
        return 0;
    memset(mem, 0, bytes);
    return mem;
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
    unsigned long flags = 0;
    unsigned long tic = (unsigned long)gametic;
    unsigned long packed = ((unsigned long)(gamestate & 0xff))
        | ((unsigned long)(gameepisode & 0xff) << 8)
        | ((unsigned long)(gamemap & 0xff) << 16);

    if (menuactive)
        flags |= VIBE_GAMEPLAY_FLAG_MENU_ACTIVE;
    if (automapactive)
        flags |= VIBE_GAMEPLAY_FLAG_AUTOMAP_ACTIVE;
    if (paused)
        flags |= VIBE_GAMEPLAY_FLAG_PAUSED;
    if (singletics)
        flags |= VIBE_GAMEPLAY_FLAG_SINGLETICS;

    if (!tic && leveltime > 0)
        tic = (unsigned long)leveltime;

    packed |= flags << 24;

    (void)vibe_syscall3(
        VIBE_SYS_GAMEPLAY_STATUS,
        packed,
        tic,
        (unsigned long)leveltime);
}

static void report_save_action_status(void)
{
    unsigned long flags = 0;
    unsigned long hash = 0;
    unsigned long length = 0;
    unsigned long packed;
    unsigned char c;
    int i;

    if (sendsave)
        flags |= VIBE_DOOM_SAVEACTION_SENDSAVE;
    if (menuactive)
        flags |= VIBE_DOOM_SAVEACTION_MENUACTIVE;

    for (i = 0; i < 32 && savedescription[i]; ++i) {
        c = (unsigned char)savedescription[i];
        if (length == 0)
            hash = 2166136261u;
        hash ^= c;
        hash *= 16777619u;
        ++length;
    }

    if (length)
        flags |= VIBE_DOOM_SAVEACTION_DESCRIPTION;

    packed = VIBE_DOOM_SAVEACTION_STATUS
        | flags
        | (((unsigned long)gameaction & 0xffu) << VIBE_DOOM_SAVEACTION_GAMEACTION_SHIFT)
        | (((unsigned long)savegameslot & 0xffu) << VIBE_DOOM_SAVEACTION_SLOT_SHIFT);

    (void)vibe_syscall3(VIBE_SYS_GAMEPLAY_STATUS, packed, hash, length);
}

void G_BuildTiccmd(ticcmd_t* cmd)
{
    int target_tic;
    int divisor;

    checkpoint_save_slot_if_needed();
    doom_original_G_BuildTiccmd(cmd);

    if (!singletics || !cmd)
        return;
    if (!(cmd->buttons & BT_SPECIAL))
        return;
    if ((cmd->buttons & BT_SPECIALMASK) != BTS_SAVEGAME)
        return;

    divisor = ticdup > 0 ? ticdup : 1;
    target_tic = (gametic / divisor) % BACKUPTICS;
    if (target_tic < 0)
        target_tic += BACKUPTICS;

    netcmds[consoleplayer][target_tic] = *cmd;
}

void G_Ticker(void)
{
    doom_original_G_Ticker();

    if (gameaction == ga_savegame && savedescription[0])
        G_DoSaveGame();
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

        if (player->cmd.forwardmove || player->cmd.sidemove)
            playable_proof_flags |= VIBE_PLAYABLE_SEEN_MOVE_CMD;
        if (player->cmd.angleturn)
            playable_proof_flags |= VIBE_PLAYABLE_SEEN_TURN_CMD;
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
                playable_origin_angle = (unsigned int)player->mo->angle;
            } else if (x != playable_origin_x || y != playable_origin_y) {
                playable_proof_flags |= VIBE_PLAYABLE_SEEN_POS_DELTA;
            }
            if (playable_origin_set && (unsigned int)player->mo->angle != playable_origin_angle)
                playable_proof_flags |= VIBE_PLAYABLE_SEEN_TURN_CMD;
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

static void report_player_detail_status(void)
{
    unsigned long cmd;
    unsigned long stats;
    player_t* player;

    if (consoleplayer < 0 || consoleplayer >= MAXPLAYERS || !playeringame[consoleplayer])
        return;

    player = &players[consoleplayer];
    if (!player->mo)
        return;

    cmd = ((unsigned long)player->cmd.buttons & 0xffu)
        | (((unsigned long)(unsigned char)player->cmd.forwardmove) << 8)
        | (((unsigned long)(unsigned char)player->cmd.sidemove) << 16);
    stats = ((unsigned long)player->ammo[am_clip] & 0xffffu)
        | (((unsigned long)player->refire & 0xffu) << 16)
        | (((unsigned long)player->readyweapon & 0xffu) << 24);

    (void)vibe_syscall3(VIBE_SYS_PLAYER_DETAIL_STATUS, cmd, (unsigned long)player->mo->angle, stats);
}

void I_FinishUpdate(void)
{
    vibe_present_indexed_t present;

    report_doom_init_status(VIBE_DOOM_INIT_FRAME);
    pump_music_stream();
    report_gameplay_status();
    checkpoint_load_slot_if_needed();
    report_save_action_status();
    report_playability_status();
    report_player_detail_status();
    checkpoint_default_config_if_needed();
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
    singletics = true;
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
    pump_music_stream();
}

void I_SubmitSound(void)
{
    pump_music_stream();
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
    int lump;
    name[0] = 'd';
    name[1] = 's';
    strncpy(name + 2, sfxinfo->name, 6);
    name[8] = 0;
    lump = W_CheckNumForName(name);
    if (lump < 0)
        lump = W_GetNumForName("dspistol");
    return lump;
}

int I_StartSound(int id, int vol, int sep, int pitch, int priority)
{
    (void)priority;
    {
        int handle = next_sound_handle++;
        vibe_audio_sfx_desc_t desc;
        sfxinfo_t* sfx = &S_sfx[id];
        unsigned long sample_length;
        unsigned long sample_rate;
        unsigned long sample_flags;
        unsigned char* samples;

        if (sfx->link)
            sfx = sfx->link;

        sample_length = 0;
        sample_rate = VIBE_SFX_DEFAULT_SAMPLE_RATE;
        sample_flags = 0;
        samples = cache_sfx_samples(id, sfx, &sample_length, &sample_rate, &sample_flags);

        memset(&desc, 0, sizeof(desc));
        desc.samples = samples;
        desc.length = sample_length;
        desc.volume = (unsigned long)(vol & 0xff);
        desc.separation = (unsigned long)(sep & 0xff);
        desc.pitch = (unsigned long)(pitch & 0xff);
        desc.sound_id = (unsigned long)id;
        desc.flags = sample_flags;
        desc.sample_rate = sample_rate;

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
        stop_music_stream_handle(current_music_handle);
    current_music_handle = 0;
    current_music_looping = 0;
    current_music_paused = 0;
    current_music_next_tic = 0;
    current_music_pull_seen = 0;
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
    if (current_music_handle > 0)
        vibe_music_stream_set_volume(current_music_handle, (unsigned long)current_music_volume);
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
    current_music_next_tic = 0;
    pump_music_stream();
}

int I_RegisterSong(void* data)
{
    return vibe_music_register_song(data);
}

void I_PlaySong(int handle, int looping)
{
    if (handle <= 0)
        return;
    if (current_music_handle > 0 && current_music_handle != handle)
        stop_music_stream_handle(current_music_handle);
    current_music_handle = handle;
    current_music_looping = looping;
    current_music_paused = 0;
    current_music_next_tic = 0;
    current_music_pull_seen = 0;
    vibe_music_stream_begin(
        handle,
        VIBE_MUSIC_DEFAULT_SAMPLE_RATE,
        (unsigned long)current_music_volume,
        looping);
}

void I_StopSong(int handle)
{
    if (handle <= 0)
        return;
    stop_music_stream_handle(handle);
    if (current_music_handle == handle) {
        current_music_handle = 0;
        current_music_looping = 0;
        current_music_paused = 0;
        current_music_next_tic = 0;
        current_music_pull_seen = 0;
    }
}

void I_UnRegisterSong(int handle)
{
    if (handle == current_music_handle)
        I_StopSong(handle);
    vibe_music_unregister_song(handle);
}
