#include "doomtype.h"
#include "doomstat.h"
#include "info.h"
#include "p_mobj.h"
#include "p_saveg.h"
#include "stddef.h"
#include "vibe_os.h"

#ifndef offsetof
#define offsetof(type, member) ((unsigned long)&(((type*)0)->member))
#endif

extern byte* savebuffer;
extern int savegameslot;

void P_MobjThinker(mobj_t* mobj);

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
    VIBE_SAVE_STAGE_UNARCHIVE_THINKERS_REPAIRED = 0x1a,
};

enum {
    VIBE_SAVE_TCLASS_END = 0,
    VIBE_SAVE_TCLASS_MOBJ = 1,
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

static unsigned long read_save_u32(const byte* p)
{
    return ((unsigned long)p[0])
        | ((unsigned long)p[1] << 8)
        | ((unsigned long)p[2] << 16)
        | ((unsigned long)p[3] << 24);
}

static byte* aligned_after_save_class(byte* p)
{
    unsigned long align;

    ++p;
    align = (4u - ((unsigned long)p & 3u)) & 3u;
    return p + align;
}

static int save_has_live_player(void)
{
    int i;

    for (i = 0; i < MAXPLAYERS; ++i)
        if (playeringame[i])
            return 1;
    return 0;
}

static int looks_like_archived_mobj(byte* class_p)
{
    byte* mobj_p;
    unsigned long thinker_function;
    unsigned long state_index;
    unsigned long type_index;
    unsigned long player_index;

    if (!class_p || *class_p != VIBE_SAVE_TCLASS_END || !save_has_live_player())
        return 0;

    mobj_p = aligned_after_save_class(class_p);
    thinker_function = read_save_u32(mobj_p + offsetof(mobj_t, thinker.function));
    state_index = read_save_u32(mobj_p + offsetof(mobj_t, state));
    type_index = read_save_u32(mobj_p + offsetof(mobj_t, type));
    player_index = read_save_u32(mobj_p + offsetof(mobj_t, player));

    if (thinker_function != (unsigned long)P_MobjThinker)
        return 0;
    if (state_index >= NUMSTATES)
        return 0;
    if (type_index >= NUMMOBJTYPES)
        return 0;
    if (player_index > MAXPLAYERS)
        return 0;

    return 1;
}

static void repair_missing_mobj_classes(void)
{
    byte* class_p;
    unsigned long repaired = 0;

    class_p = save_p;
    while (looks_like_archived_mobj(class_p)) {
        *class_p = VIBE_SAVE_TCLASS_MOBJ;
        ++repaired;
        class_p = aligned_after_save_class(class_p) + sizeof(mobj_t);
    }

    if (repaired)
        report_save_stream_stage(VIBE_SAVE_STAGE_UNARCHIVE_THINKERS_REPAIRED);
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
    repair_missing_mobj_classes();
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
