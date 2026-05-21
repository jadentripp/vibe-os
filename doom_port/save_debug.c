#include "doomtype.h"
#include "doomstat.h"
#include "p_saveg.h"
#include "vibe_os.h"

extern byte* savebuffer;
extern int savegameslot;

void doom_original_P_ArchivePlayers(void);
void doom_original_P_UnArchivePlayers(void);
void doom_original_P_ArchiveWorld(void);
void doom_original_P_UnArchiveWorld(void);
void doom_original_P_ArchiveThinkers(void);
void doom_original_P_UnArchiveThinkers(void);
void doom_original_P_ArchiveSpecials(void);
void doom_original_P_UnArchiveSpecials(void);

enum {
    VIBE_SAVE_STAGE_ARCHIVE_PLAYERS_BEFORE = 0x01,
    VIBE_SAVE_STAGE_ARCHIVE_PLAYERS_AFTER = 0x02,
    VIBE_SAVE_STAGE_ARCHIVE_WORLD_BEFORE = 0x03,
    VIBE_SAVE_STAGE_ARCHIVE_WORLD_AFTER = 0x04,
    VIBE_SAVE_STAGE_ARCHIVE_THINKERS_BEFORE = 0x05,
    VIBE_SAVE_STAGE_ARCHIVE_THINKERS_AFTER = 0x06,
    VIBE_SAVE_STAGE_ARCHIVE_SPECIALS_BEFORE = 0x07,
    VIBE_SAVE_STAGE_ARCHIVE_SPECIALS_AFTER = 0x08,
    VIBE_SAVE_STAGE_UNARCHIVE_PLAYERS_BEFORE = 0x11,
    VIBE_SAVE_STAGE_UNARCHIVE_PLAYERS_AFTER = 0x12,
    VIBE_SAVE_STAGE_UNARCHIVE_WORLD_BEFORE = 0x13,
    VIBE_SAVE_STAGE_UNARCHIVE_WORLD_AFTER = 0x14,
    VIBE_SAVE_STAGE_UNARCHIVE_THINKERS_BEFORE = 0x15,
    VIBE_SAVE_STAGE_UNARCHIVE_THINKERS_AFTER = 0x16,
    VIBE_SAVE_STAGE_UNARCHIVE_SPECIALS_BEFORE = 0x17,
    VIBE_SAVE_STAGE_UNARCHIVE_SPECIALS_AFTER = 0x18,
};

static unsigned long active_save_stream_stage;

static void report_save_stream_pointer(unsigned long stage, byte* stream_p)
{
    unsigned long offset = 0xffffffffu;
    unsigned long value = 0xffu;
    unsigned long packed;
    unsigned long detail;

    if (stream_p) {
        value = (unsigned long)(*stream_p);
        if (savebuffer)
            offset = (unsigned long)(stream_p - savebuffer);
    }

    detail = (value << 24)
        | ((offset & 3u) << 16)
        | (((unsigned long)save_p & 0xffu) << 8)
        | ((unsigned long)savebuffer & 0xffu);
    packed = VIBE_DOOM_SAVEACTION_STATUS
        | VIBE_DOOM_SAVEACTION_STREAM
        | ((stage & 0xffu) << VIBE_DOOM_SAVEACTION_GAMEACTION_SHIFT)
        | (((unsigned long)savegameslot & 0xffu) << VIBE_DOOM_SAVEACTION_SLOT_SHIFT);

    (void)vibe_syscall3(VIBE_SYS_GAMEPLAY_STATUS, packed, offset, detail);
}

static void report_save_stream_stage(unsigned long stage)
{
    report_save_stream_pointer(stage, save_p);
}

static int save_stage_reads_class_byte(unsigned long stage)
{
    return stage == VIBE_SAVE_STAGE_UNARCHIVE_THINKERS_BEFORE
        || stage == VIBE_SAVE_STAGE_UNARCHIVE_SPECIALS_BEFORE;
}

static void enter_save_stream_stage(unsigned long stage)
{
    active_save_stream_stage = stage;
    report_save_stream_stage(stage);
}

static void leave_save_stream_stage(unsigned long stage)
{
    report_save_stream_stage(stage);
    active_save_stream_stage = 0;
}

void vibe_doom_save_stream_note_error(void)
{
    byte* stream_p;

    if (!active_save_stream_stage || !save_p)
        return;

    stream_p = save_p;
    if (save_stage_reads_class_byte(active_save_stream_stage)
        && savebuffer
        && save_p > savebuffer) {
        stream_p = save_p - 1;
    }

    report_save_stream_pointer(active_save_stream_stage, stream_p);
}

void P_ArchivePlayers(void)
{
    enter_save_stream_stage(VIBE_SAVE_STAGE_ARCHIVE_PLAYERS_BEFORE);
    doom_original_P_ArchivePlayers();
    leave_save_stream_stage(VIBE_SAVE_STAGE_ARCHIVE_PLAYERS_AFTER);
}

void P_UnArchivePlayers(void)
{
    enter_save_stream_stage(VIBE_SAVE_STAGE_UNARCHIVE_PLAYERS_BEFORE);
    doom_original_P_UnArchivePlayers();
    leave_save_stream_stage(VIBE_SAVE_STAGE_UNARCHIVE_PLAYERS_AFTER);
}

void P_ArchiveWorld(void)
{
    enter_save_stream_stage(VIBE_SAVE_STAGE_ARCHIVE_WORLD_BEFORE);
    doom_original_P_ArchiveWorld();
    leave_save_stream_stage(VIBE_SAVE_STAGE_ARCHIVE_WORLD_AFTER);
}

void P_UnArchiveWorld(void)
{
    enter_save_stream_stage(VIBE_SAVE_STAGE_UNARCHIVE_WORLD_BEFORE);
    doom_original_P_UnArchiveWorld();
    leave_save_stream_stage(VIBE_SAVE_STAGE_UNARCHIVE_WORLD_AFTER);
}

void P_ArchiveThinkers(void)
{
    enter_save_stream_stage(VIBE_SAVE_STAGE_ARCHIVE_THINKERS_BEFORE);
    doom_original_P_ArchiveThinkers();
    leave_save_stream_stage(VIBE_SAVE_STAGE_ARCHIVE_THINKERS_AFTER);
}

void P_UnArchiveThinkers(void)
{
    enter_save_stream_stage(VIBE_SAVE_STAGE_UNARCHIVE_THINKERS_BEFORE);
    doom_original_P_UnArchiveThinkers();
    leave_save_stream_stage(VIBE_SAVE_STAGE_UNARCHIVE_THINKERS_AFTER);
}

void P_ArchiveSpecials(void)
{
    enter_save_stream_stage(VIBE_SAVE_STAGE_ARCHIVE_SPECIALS_BEFORE);
    doom_original_P_ArchiveSpecials();
    leave_save_stream_stage(VIBE_SAVE_STAGE_ARCHIVE_SPECIALS_AFTER);
}

void P_UnArchiveSpecials(void)
{
    enter_save_stream_stage(VIBE_SAVE_STAGE_UNARCHIVE_SPECIALS_BEFORE);
    doom_original_P_UnArchiveSpecials();
    leave_save_stream_stage(VIBE_SAVE_STAGE_UNARCHIVE_SPECIALS_AFTER);
}
