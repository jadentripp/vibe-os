#include "quakedef.h"

extern char localmodels[MAX_MODELS][5];
extern float scr_centertime_off;

void SV_CreateBaseline(void);
void SV_SendReconnect(void);
void SV_SendServerinfo(client_t* client);
void pi4_quake_show_stage(char* stage);

void SV_SpawnServer(char* server)
{
    edict_t* ent;
    int i;

    if (hostname.string[0] == 0)
        Cvar_Set("hostname", "UNNAMED");
    scr_centertime_off = 0;
    svs.changelevel_issued = false;

    if (sv.active)
        SV_SendReconnect();

    if (coop.value)
        Cvar_SetValue("deathmatch", 0);
    current_skill = (int)(skill.value + 0.5);
    if (current_skill < 0)
        current_skill = 0;
    if (current_skill > 3)
        current_skill = 3;

    Cvar_SetValue("skill", (float)current_skill);

    pi4_quake_show_stage("pi4 spawn clear memory");
    Host_ClearMemory();

    memset(&sv, 0, sizeof(sv));

    strcpy(sv.name, server);

    pi4_quake_show_stage("pi4 spawn load progs");
    PR_LoadProgs();

    pi4_quake_show_stage("pi4 spawn alloc edicts");
    sv.max_edicts = MAX_EDICTS;
    sv.edicts = Hunk_AllocName(sv.max_edicts * pr_edict_size, "edicts");

    sv.datagram.maxsize = sizeof(sv.datagram_buf);
    sv.datagram.cursize = 0;
    sv.datagram.data = sv.datagram_buf;

    sv.reliable_datagram.maxsize = sizeof(sv.reliable_datagram_buf);
    sv.reliable_datagram.cursize = 0;
    sv.reliable_datagram.data = sv.reliable_datagram_buf;

    sv.signon.maxsize = sizeof(sv.signon_buf);
    sv.signon.cursize = 0;
    sv.signon.data = sv.signon_buf;

    sv.num_edicts = svs.maxclients + 1;
    for (i = 0; i < svs.maxclients; i++)
    {
        ent = EDICT_NUM(i + 1);
        svs.clients[i].edict = ent;
    }

    sv.state = ss_loading;
    sv.paused = false;
    sv.time = 1.0;

    strcpy(sv.name, server);
    sprintf(sv.modelname, "maps/%s.bsp", server);

    pi4_quake_show_stage("pi4 spawn load world");
    sv.worldmodel = Mod_ForName(sv.modelname, false);
    if (!sv.worldmodel)
    {
        Con_Printf("Couldn't spawn server %s\n", sv.modelname);
        sv.active = false;
        return;
    }
    sv.models[1] = sv.worldmodel;

    pi4_quake_show_stage("pi4 spawn clear world");
    SV_ClearWorld();

    sv.sound_precache[0] = pr_strings;
    sv.model_precache[0] = pr_strings;
    sv.model_precache[1] = sv.modelname;
    for (i = 1; i < sv.worldmodel->numsubmodels; i++)
    {
        sv.model_precache[1 + i] = localmodels[i];
        sv.models[i + 1] = Mod_ForName(localmodels[i], false);
    }

    pi4_quake_show_stage("pi4 spawn entities");
    ent = EDICT_NUM(0);
    memset(&ent->v, 0, progs->entityfields * 4);
    ent->free = false;
    ent->v.model = sv.worldmodel->name - pr_strings;
    ent->v.modelindex = 1;
    ent->v.solid = SOLID_BSP;
    ent->v.movetype = MOVETYPE_PUSH;

    if (coop.value)
        pr_global_struct->coop = coop.value;
    else
        pr_global_struct->deathmatch = deathmatch.value;

    pr_global_struct->mapname = sv.name - pr_strings;
    pr_global_struct->serverflags = svs.serverflags;

    ED_LoadFromFile(sv.worldmodel->entities);

    pi4_quake_show_stage("pi4 spawn active");
    sv.active = true;
    sv.state = ss_active;

    pi4_quake_show_stage("pi4 spawn physics 1");
    host_frametime = 0.1;
    SV_Physics();
    pi4_quake_show_stage("pi4 spawn physics 2");
    SV_Physics();

    pi4_quake_show_stage("pi4 spawn baseline");
    SV_CreateBaseline();

    for (i = 0, host_client = svs.clients; i < svs.maxclients; i++, host_client++)
        if (host_client->active)
            SV_SendServerinfo(host_client);

    pi4_quake_show_stage("pi4 spawn done");
}
