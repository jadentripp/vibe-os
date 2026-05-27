#include "quakedef.h"

void pi4_quake_show_stage(char* stage);

static char pi4_pr_stage[96];

static void pi4_pr_count_stage(char* name, int value)
{
    sprintf(pi4_pr_stage, "%s %d", name, value);
    pi4_quake_show_stage(pi4_pr_stage);
}

static byte* pi4_pr_load_hunk_file(char* path)
{
    int h;
    int len;
    int total;
    int want;
    int got;
    byte* buf;
    char base[32];

    pi4_quake_show_stage("pi4 progs open file");
    len = COM_OpenFile(path, &h);
    if (h == -1)
        return NULL;

    pi4_pr_count_stage("pi4 progs file bytes", len);
    COM_FileBase(path, base);

    pi4_quake_show_stage("pi4 progs hunk");
    buf = Hunk_AllocName(len + 1, base);
    if (!buf)
        Sys_Error("PR_LoadProgs: not enough space for %s", path);
    buf[len] = 0;

    pi4_quake_show_stage("pi4 progs read");
    Draw_BeginDisc();
    total = 0;
    while (total < len) {
        want = len - total;
        if (want > 512 * 1024)
            want = 512 * 1024;
        got = Sys_FileRead(h, buf + total, want);
        if (got <= 0)
            break;
        total += got;
        if ((total & 0xffff) == 0 || total == len)
            pi4_pr_count_stage("pi4 progs read", total);
    }
    COM_CloseFile(h);
    Draw_EndDisc();

    if (total != len)
        Sys_Error("PR_LoadProgs: short read %i/%i", total, len);

    return buf;
}

void PR_LoadProgs(void)
{
    int i;

    pi4_quake_show_stage("pi4 progs open");
    CRC_Init(&pr_crc);

    progs = (dprograms_t*)pi4_pr_load_hunk_file("progs.dat");
    if (!progs)
        Sys_Error("PR_LoadProgs: couldn't load progs.dat");

    pi4_pr_count_stage("pi4 progs bytes", com_filesize);
    Con_DPrintf("Programs occupy %iK.\n", com_filesize / 1024);

    pi4_quake_show_stage("pi4 progs crc");
    for (i = 0; i < com_filesize; i++)
        CRC_ProcessByte(&pr_crc, ((byte*)progs)[i]);

    pi4_quake_show_stage("pi4 progs header");
    for (i = 0; i < (int)(sizeof(*progs) / 4); i++)
        ((int*)progs)[i] = LittleLong(((int*)progs)[i]);

    pi4_pr_count_stage("pi4 progs version", progs->version);
    if (progs->version != PROG_VERSION)
        Sys_Error("progs.dat has wrong version number (%i should be %i)",
            progs->version, PROG_VERSION);
    if (progs->crc != PROGHEADER_CRC)
        Sys_Error("progs.dat system vars have been modified, progdefs.h is out of date");

    pr_functions = (dfunction_t*)((byte*)progs + progs->ofs_functions);
    pr_strings = (char*)progs + progs->ofs_strings;
    pr_globaldefs = (ddef_t*)((byte*)progs + progs->ofs_globaldefs);
    pr_fielddefs = (ddef_t*)((byte*)progs + progs->ofs_fielddefs);
    pr_statements = (dstatement_t*)((byte*)progs + progs->ofs_statements);

    pr_global_struct = (globalvars_t*)((byte*)progs + progs->ofs_globals);
    pr_globals = (float*)pr_global_struct;

    pr_edict_size = progs->entityfields * 4 + sizeof(edict_t) - sizeof(entvars_t);

    pi4_pr_count_stage("pi4 progs stmts", progs->numstatements);
    for (i = 0; i < progs->numstatements; i++) {
        pr_statements[i].op = LittleShort(pr_statements[i].op);
        pr_statements[i].a = LittleShort(pr_statements[i].a);
        pr_statements[i].b = LittleShort(pr_statements[i].b);
        pr_statements[i].c = LittleShort(pr_statements[i].c);
    }

    pi4_pr_count_stage("pi4 progs funcs", progs->numfunctions);
    for (i = 0; i < progs->numfunctions; i++) {
        pr_functions[i].first_statement = LittleLong(pr_functions[i].first_statement);
        pr_functions[i].parm_start = LittleLong(pr_functions[i].parm_start);
        pr_functions[i].s_name = LittleLong(pr_functions[i].s_name);
        pr_functions[i].s_file = LittleLong(pr_functions[i].s_file);
        pr_functions[i].numparms = LittleLong(pr_functions[i].numparms);
        pr_functions[i].locals = LittleLong(pr_functions[i].locals);
    }

    pi4_pr_count_stage("pi4 progs gdefs", progs->numglobaldefs);
    for (i = 0; i < progs->numglobaldefs; i++) {
        pr_globaldefs[i].type = LittleShort(pr_globaldefs[i].type);
        pr_globaldefs[i].ofs = LittleShort(pr_globaldefs[i].ofs);
        pr_globaldefs[i].s_name = LittleLong(pr_globaldefs[i].s_name);
    }

    pi4_pr_count_stage("pi4 progs fdefs", progs->numfielddefs);
    for (i = 0; i < progs->numfielddefs; i++) {
        pr_fielddefs[i].type = LittleShort(pr_fielddefs[i].type);
        if (pr_fielddefs[i].type & DEF_SAVEGLOBAL)
            Sys_Error("PR_LoadProgs: pr_fielddefs[i].type & DEF_SAVEGLOBAL");
        pr_fielddefs[i].ofs = LittleShort(pr_fielddefs[i].ofs);
        pr_fielddefs[i].s_name = LittleLong(pr_fielddefs[i].s_name);
    }

    pi4_pr_count_stage("pi4 progs globals", progs->numglobals);
    for (i = 0; i < progs->numglobals; i++)
        ((int*)pr_globals)[i] = LittleLong(((int*)pr_globals)[i]);

    pi4_quake_show_stage("pi4 progs done");
}
