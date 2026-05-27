#include "quakedef.h"
#include "r_local.h"

void pi4_quake_original_V_RenderView(void);
void pi4_quake_original_SCR_UpdateScreen(void);
void pi4_quake_force_local_begin(void);
void Sys_Printf(char* format, ...);
void VID_Update(vrect_t* rects);
extern byte* r_warpbuffer;
extern espan_t* span_p;
extern espan_t* max_span_p;
extern int current_iv;
extern int edge_head_u_shift20;
extern int edge_tail_u_shift20;
extern edge_t edge_sentinel;
extern float fv;
static byte pi4_quake_warpbuffer[WARP_WIDTH * WARP_HEIGHT];
static edge_t pi4_quake_ledges[NUMSTACKEDGES + ((CACHE_SIZE - 1) / sizeof(edge_t)) + 1];
static surf_t pi4_quake_lsurfs[NUMSTACKSURFACES + ((CACHE_SIZE - 1) / sizeof(surf_t)) + 1];
static byte pi4_quake_basespans[MAXSPANS * sizeof(espan_t) + CACHE_SIZE];

void R_EdgeDrawing(void);
void R_DrawCulledPolys(void);
void R_GenerateSpans(void);
void R_GenerateSpansBackward(void);

void R_RenderView(void)
{
    Sys_Printf("pi4 quake R_RenderView begin\n");
    r_warpbuffer = pi4_quake_warpbuffer;

    if (r_timegraph.value || r_speeds.value || r_dspeeds.value)
        r_time1 = Sys_FloatTime();

    Sys_Printf("pi4 quake R setup begin\n");
    R_SetupFrame();
    Sys_Printf("pi4 quake R setup done\n");

    Sys_Printf("pi4 quake R mark leaves begin\n");
    R_MarkLeaves();
    Sys_Printf("pi4 quake R mark leaves done\n");

    Sys_LowFPPrecision();

    if (!cl_entities[0].model || !cl.worldmodel)
        Sys_Error("R_RenderView: NULL worldmodel");

    if (!r_dspeeds.value) {
        VID_UnlockBuffer();
        S_ExtraUpdate();
        VID_LockBuffer();
    }

    Sys_Printf("pi4 quake R edge begin\n");
    R_EdgeDrawing();
    Sys_Printf("pi4 quake R edge done\n");

    if (!r_dspeeds.value) {
        VID_UnlockBuffer();
        S_ExtraUpdate();
        VID_LockBuffer();
    }

    Sys_Printf("pi4 quake R entities begin\n");
    R_DrawEntitiesOnList();
    Sys_Printf("pi4 quake R entities done\n");

    Sys_Printf("pi4 quake R viewmodel begin\n");
    R_DrawViewModel();
    Sys_Printf("pi4 quake R viewmodel done\n");

    Sys_Printf("pi4 quake R particles begin\n");
    R_DrawParticles();
    Sys_Printf("pi4 quake R particles done\n");

    if (r_dowarp)
        D_WarpScreen();

    V_SetContentsColor(r_viewleaf->contents);
    Sys_HighFPPrecision();
    Sys_Printf("pi4 quake R_RenderView done\n");
}

void R_EdgeDrawing(void)
{
    if (auxedges) {
        r_edges = auxedges;
    } else {
        r_edges = (edge_t*)(((long)&pi4_quake_ledges[0] + CACHE_SIZE - 1) & ~(CACHE_SIZE - 1));
    }

    if (r_surfsonstack) {
        surfaces = (surf_t*)(((long)&pi4_quake_lsurfs[0] + CACHE_SIZE - 1) & ~(CACHE_SIZE - 1));
        surf_max = &surfaces[r_cnumsurfs];
        surfaces--;
        R_SurfacePatch();
    }

    Sys_Printf("pi4 quake R edge begin-edge-frame\n");
    R_BeginEdgeFrame();

    if (r_dspeeds.value)
        rw_time1 = Sys_FloatTime();

    Sys_Printf("pi4 quake R edge render-world\n");
    R_RenderWorld();

    if (r_drawculledpolys)
        R_ScanEdges();

    D_TurnZOn();

    if (r_dspeeds.value) {
        rw_time2 = Sys_FloatTime();
        db_time1 = rw_time2;
    }

    Sys_Printf("pi4 quake R edge bentities\n");
    R_DrawBEntitiesOnList();

    if (r_dspeeds.value) {
        db_time2 = Sys_FloatTime();
        se_time1 = db_time2;
    }

    if (!r_dspeeds.value) {
        VID_UnlockBuffer();
        S_ExtraUpdate();
        VID_LockBuffer();
    }

    if (!(r_drawpolys | r_drawculledpolys)) {
        Sys_Printf("pi4 quake R edge scan\n");
        R_ScanEdges();
    }
    Sys_Printf("pi4 quake R edge complete\n");
}

void R_ScanEdges(void)
{
    int iv, bottom;
    espan_t* basespan_p;
    surf_t* s;
    void (*drawfunc)(void);

    Sys_Printf("pi4 quake R scan begin\n");
    drawfunc = r_draworder.value ? R_GenerateSpansBackward : R_GenerateSpans;
    basespan_p = (espan_t*)((long)(pi4_quake_basespans + CACHE_SIZE - 1) & ~(CACHE_SIZE - 1));
    max_span_p = &basespan_p[MAXSPANS - r_refdef.vrect.width];
    span_p = basespan_p;
    Sys_Printf("pi4 quake R scan bounds y=%d bottom=%d x=%d right=%d width=%d\n",
        r_refdef.vrect.y, r_refdef.vrectbottom, r_refdef.vrect.x,
        r_refdef.vrectright, r_refdef.vrect.width);

    edge_head.u = r_refdef.vrect.x << 20;
    edge_head_u_shift20 = edge_head.u >> 20;
    edge_head.u_step = 0;
    edge_head.prev = NULL;
    edge_head.next = &edge_tail;
    edge_head.surfs[0] = 0;
    edge_head.surfs[1] = 1;

    edge_tail.u = (r_refdef.vrectright << 20) + 0xFFFFF;
    edge_tail_u_shift20 = edge_tail.u >> 20;
    edge_tail.u_step = 0;
    edge_tail.prev = &edge_head;
    edge_tail.next = &edge_aftertail;
    edge_tail.surfs[0] = 1;
    edge_tail.surfs[1] = 0;

    edge_aftertail.u = -1;
    edge_aftertail.u_step = 0;
    edge_aftertail.next = &edge_sentinel;
    edge_aftertail.prev = &edge_tail;

    edge_sentinel.u = 0x7fffffff;
    edge_sentinel.prev = &edge_aftertail;

    bottom = r_refdef.vrectbottom - 1;
    for (iv = r_refdef.vrect.y; iv < bottom; iv++) {
        int trace_line = (iv == r_refdef.vrect.y) || ((iv & 31) == 0) || (iv >= 92);
        current_iv = iv;
        fv = (float)iv;
        surfaces[1].spanstate = 1;
        if (trace_line)
            Sys_Printf("pi4 quake R scan line=%d new=%x remove=%x\n",
                iv, (int)(long)newedges[iv], (int)(long)removeedges[iv]);

        if (newedges[iv]) {
            if (trace_line)
                Sys_Printf("pi4 quake R scan insert begin line=%d\n", iv);
            R_InsertNewEdges(newedges[iv], edge_head.next);
            if (trace_line)
                Sys_Printf("pi4 quake R scan insert done line=%d\n", iv);
        }

        if (trace_line)
            Sys_Printf("pi4 quake R scan draw begin line=%d\n", iv);
        (*drawfunc)();
        if (trace_line)
            Sys_Printf("pi4 quake R scan draw done line=%d\n", iv);

        if (span_p >= max_span_p) {
            VID_UnlockBuffer();
            S_ExtraUpdate();
            VID_LockBuffer();

            if (r_drawculledpolys)
                R_DrawCulledPolys();
            else
                D_DrawSurfaces();

            for (s = &surfaces[1]; s < surface_p; s++)
                s->spans = NULL;

            span_p = basespan_p;
        }

        if (removeedges[iv]) {
            if (trace_line)
                Sys_Printf("pi4 quake R scan remove begin line=%d\n", iv);
            R_RemoveEdges(removeedges[iv]);
            if (trace_line)
                Sys_Printf("pi4 quake R scan remove done line=%d\n", iv);
        }

        if (edge_head.next != &edge_tail) {
            if (trace_line)
                Sys_Printf("pi4 quake R scan step begin line=%d\n", iv);
            R_StepActiveU(edge_head.next);
            if (trace_line)
                Sys_Printf("pi4 quake R scan step done line=%d\n", iv);
        }
    }

    current_iv = iv;
    fv = (float)iv;
    surfaces[1].spanstate = 1;

    Sys_Printf("pi4 quake R scan final line=%d new=%x\n",
        iv, (int)(long)newedges[iv]);
    if (newedges[iv]) {
        Sys_Printf("pi4 quake R scan final insert begin\n");
        R_InsertNewEdges(newedges[iv], edge_head.next);
        Sys_Printf("pi4 quake R scan final insert done\n");
    }

    Sys_Printf("pi4 quake R scan final draw begin\n");
    (*drawfunc)();
    Sys_Printf("pi4 quake R scan final draw done\n");

    if (r_drawculledpolys) {
        Sys_Printf("pi4 quake R scan final culled begin\n");
        R_DrawCulledPolys();
        Sys_Printf("pi4 quake R scan final culled done\n");
    } else {
        Sys_Printf("pi4 quake R scan final surfaces begin\n");
        D_DrawSurfaces();
        Sys_Printf("pi4 quake R scan final surfaces done\n");
    }
    Sys_Printf("pi4 quake R scan done\n");
}

void V_RenderView(void)
{
    Sys_Printf("pi4 quake V_RenderView begin forced=%d signon=%d world=%x\n",
        con_forcedup, cls.signon, (int)(long)cl.worldmodel);
    pi4_quake_original_V_RenderView();
    Sys_Printf("pi4 quake V_RenderView done\n");
}

void SCR_UpdateScreen(void)
{
    Sys_Printf("pi4 quake SCR_UpdateScreen begin signon=%d key=%d\n",
        cls.signon, key_dest);
    if (cls.signon < 2) {
        pi4_quake_original_SCR_UpdateScreen();
        Sys_Printf("pi4 quake SCR_UpdateScreen done signon=%d key=%d\n",
            cls.signon, key_dest);
        return;
    }
    if (cls.signon == SIGNONS - 1)
        pi4_quake_force_local_begin();
    V_RenderView();
    Sys_Printf("pi4 quake VID_Update begin signon=%d\n", cls.signon);
    VID_Update(0);
    Sys_Printf("pi4 quake VID_Update done signon=%d\n", cls.signon);
    Sys_Printf("pi4 quake SCR_UpdateScreen done signon=%d key=%d\n",
        cls.signon, key_dest);
}
