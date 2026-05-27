#include "quakedef.h"

static char pi4_quake_default_map_cmd[] = "map start";
static char pi4_quake_default_map_name[] = "start";
static char pi4_quake_local_host[] = "local";
static int pi4_quake_state_last_signon = -1;
static int pi4_quake_state_last_key = -1;
static int pi4_quake_local_begin_done = 0;
static int pi4_quake_local_begin_attempts = 0;
static int pi4_quake_first_game_drawn = 0;

extern sizebuf_t cmd_text;
int CL_ReadFromServer(void);
void Host_Reconnect_f(void);
void Host_Frame(float time);
void SCR_UpdateScreen(void);
void SV_SendClientMessages(void);
void Sys_Printf(char* format, ...);

void pi4_quake_force_local_begin(void)
{
    if (pi4_quake_local_begin_done)
        return;
    if (cls.state != ca_connected || cls.signon != SIGNONS - 1)
        return;
    if (!sv.active || svs.maxclients < 1 || !svs.clients[0].active)
        return;

    if (!svs.clients[0].spawned)
        svs.clients[0].spawned = true;

    pi4_quake_local_begin_attempts++;
    SV_SendClientMessages();
    CL_ReadFromServer();
    Sys_Printf("pi4 quake local begin flush attempt=%d signon=%d spawned=%d\n",
        pi4_quake_local_begin_attempts, cls.signon, svs.clients[0].spawned);

    if (cls.signon == SIGNONS)
        pi4_quake_local_begin_done = 1;
}

void pi4_quake_show_stage(char* stage)
{
    Draw_String(0, 0, stage);
    VID_Update(0);
}

void pi4_quake_begin_default_game(void)
{
    cmd_text.cursize = 0;
    key_dest = key_game;
    pi4_quake_local_begin_done = 0;
    pi4_quake_local_begin_attempts = 0;
    pi4_quake_first_game_drawn = 0;
    cls.demonum = -1;
    cls.mapstring[0] = 0;
    strcpy(cls.mapstring, pi4_quake_default_map_cmd);
    strcat(cls.mapstring, "\n");
    svs.serverflags = 0;
    Cvar_SetValue("viewsize", 30);
    Cvar_SetValue("r_drawviewmodel", 0);
    Cvar_SetValue("r_drawflat", 1);
    pi4_quake_show_stage("pi4 stage spawn start");
    SV_SpawnServer(pi4_quake_default_map_name);
    pi4_quake_show_stage("pi4 stage spawn done");
    if (sv.active && cls.state != ca_dedicated)
    {
        strcpy(cls.spawnparms, "");
        CL_EstablishConnection(pi4_quake_local_host);
        Host_Reconnect_f();
        pi4_quake_show_stage("pi4 stage connect done");
    }
    key_dest = key_game;
    con_forcedup = false;
    scr_conlines = 0;
    scr_con_current = 0;
    scr_fullupdate = 0;
    SCR_EndLoadingPlaque();
    cmd_text.cursize = 0;
}

int pi4_quake_ready_for_game_view(void)
{
    return cls.state == ca_connected && cls.signon == SIGNONS && cl.worldmodel != 0;
}

void pi4_quake_host_frame(float time)
{
    static int frame_count = 0;
    int trace = frame_count < 8 || cls.signon >= SIGNONS - 1;

    if (trace) {
        Sys_Printf("pi4 quake host frame begin n=%d cls=%d signon=%d key=%d\n",
            frame_count, cls.state, cls.signon, key_dest);
    }
    Host_Frame(time);
    if (trace) {
        Sys_Printf("pi4 quake host frame done n=%d cls=%d signon=%d key=%d\n",
            frame_count, cls.state, cls.signon, key_dest);
    }
    frame_count++;
}

void pi4_quake_force_game_view(void)
{
    if (cls.signon != pi4_quake_state_last_signon ||
        key_dest != pi4_quake_state_last_key) {
        pi4_quake_state_last_signon = cls.signon;
        pi4_quake_state_last_key = key_dest;
        Sys_Printf("pi4 quake state cls=%d signon=%d world=%x key=%d load=%d force=%d\n",
            cls.state, cls.signon, (int)(long)cl.worldmodel,
            key_dest, scr_disabled_for_loading, con_forcedup);
    }

    pi4_quake_force_local_begin();

    if (!pi4_quake_ready_for_game_view())
        return;

    key_dest = key_game;
    con_forcedup = false;
    scr_conlines = 0;
    scr_con_current = 0;
    scr_fullupdate = 0;
    sv.paused = false;
    SCR_EndLoadingPlaque();
    if (!pi4_quake_first_game_drawn) {
        Sys_Printf("pi4 quake first game draw begin\n");
        SCR_UpdateScreen();
        Sys_Printf("pi4 quake first game draw done\n");
        pi4_quake_first_game_drawn = 1;
    }
}
