#include "doomtype.h"
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

static void report_save_stream_stage(unsigned long stage)
{
    unsigned long offset = 0xffffffffu;
    unsigned long next = 0xffu;
    unsigned long packed;
    unsigned long detail;

    if (save_p) {
        next = (unsigned long)(*save_p);
        if (savebuffer)
            offset = (unsigned long)(save_p - savebuffer);
    }

    detail = (next << 24)
        | ((offset & 3u) << 16)
        | (((unsigned long)save_p & 0xffu) << 8)
        | ((unsigned long)savebuffer & 0xffu);
    packed = VIBE_DOOM_SAVEACTION_STATUS
        | VIBE_DOOM_SAVEACTION_STREAM
        | ((stage & 0xffu) << VIBE_DOOM_SAVEACTION_GAMEACTION_SHIFT)
        | (((unsigned long)savegameslot & 0xffu) << VIBE_DOOM_SAVEACTION_SLOT_SHIFT);

    (void)vibe_syscall3(VIBE_SYS_GAMEPLAY_STATUS, packed, offset, detail);
}

void P_ArchivePlayers(void)
{
    report_save_stream_stage(VIBE_SAVE_STAGE_ARCHIVE_PLAYERS_BEFORE);
    doom_original_P_ArchivePlayers();
    report_save_stream_stage(VIBE_SAVE_STAGE_ARCHIVE_PLAYERS_AFTER);
}

void P_UnArchivePlayers(void)
{
    report_save_stream_stage(VIBE_SAVE_STAGE_UNARCHIVE_PLAYERS_BEFORE);
    doom_original_P_UnArchivePlayers();
    report_save_stream_stage(VIBE_SAVE_STAGE_UNARCHIVE_PLAYERS_AFTER);
}

void P_ArchiveWorld(void)
{
    report_save_stream_stage(VIBE_SAVE_STAGE_ARCHIVE_WORLD_BEFORE);
    doom_original_P_ArchiveWorld();
    report_save_stream_stage(VIBE_SAVE_STAGE_ARCHIVE_WORLD_AFTER);
}

void P_UnArchiveWorld(void)
{
    report_save_stream_stage(VIBE_SAVE_STAGE_UNARCHIVE_WORLD_BEFORE);
    doom_original_P_UnArchiveWorld();
    report_save_stream_stage(VIBE_SAVE_STAGE_UNARCHIVE_WORLD_AFTER);
}

void P_ArchiveThinkers(void)
{
    report_save_stream_stage(VIBE_SAVE_STAGE_ARCHIVE_THINKERS_BEFORE);
    doom_original_P_ArchiveThinkers();
    report_save_stream_stage(VIBE_SAVE_STAGE_ARCHIVE_THINKERS_AFTER);
}

void P_UnArchiveThinkers(void)
{
    report_save_stream_stage(VIBE_SAVE_STAGE_UNARCHIVE_THINKERS_BEFORE);
    doom_original_P_UnArchiveThinkers();
    report_save_stream_stage(VIBE_SAVE_STAGE_UNARCHIVE_THINKERS_AFTER);
}

void P_ArchiveSpecials(void)
{
    report_save_stream_stage(VIBE_SAVE_STAGE_ARCHIVE_SPECIALS_BEFORE);
    doom_original_P_ArchiveSpecials();
    report_save_stream_stage(VIBE_SAVE_STAGE_ARCHIVE_SPECIALS_AFTER);
}

void P_UnArchiveSpecials(void)
{
    report_save_stream_stage(VIBE_SAVE_STAGE_UNARCHIVE_SPECIALS_BEFORE);
    doom_original_P_UnArchiveSpecials();
    report_save_stream_stage(VIBE_SAVE_STAGE_UNARCHIVE_SPECIALS_AFTER);
}
