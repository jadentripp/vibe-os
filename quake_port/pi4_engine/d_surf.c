#include "quakedef.h"
#include "d_local.h"
#include "r_local.h"

#define PI4_SURFCACHE_ALIGN 8

extern int sc_size;
extern surfcache_t* sc_base;
extern float surfscale;
extern qboolean r_cache_thrash;

void D_CheckCacheGuard(void);

static int pi4_surfcache_data_offset(void)
{
    return (int)(long)&((surfcache_t*)0)->data[0];
}

static int pi4_surfcache_align_size(int size)
{
    long aligned = (long)pi4_surfcache_data_offset() + (long)size;

    aligned = (aligned + (PI4_SURFCACHE_ALIGN - 1)) & ~(long)(PI4_SURFCACHE_ALIGN - 1);
    if (aligned > 0x7fffffffL)
        Sys_Error("D_SCAlloc: aligned cache size overflow");
    return (int)aligned;
}

surfcache_t* D_SCAlloc(int width, int size)
{
    surfcache_t* new_block;
    qboolean wrapped_this_time;
    int block_size;

    if ((width < 0) || (width > 256))
        Sys_Error("D_SCAlloc: bad cache width %d\n", width);

    if ((size <= 0) || (size > 0x10000))
        Sys_Error("D_SCAlloc: bad cache size %d\n", size);

    block_size = pi4_surfcache_align_size(size);
    if (block_size > sc_size)
        Sys_Error("D_SCAlloc: %i > cache size", block_size);

    wrapped_this_time = false;

    if (!sc_rover || (long)((byte*)sc_rover - (byte*)sc_base) > (long)(sc_size - block_size)) {
        if (sc_rover)
            wrapped_this_time = true;
        sc_rover = sc_base;
    }

    new_block = sc_rover;
    if (sc_rover->owner)
        *sc_rover->owner = NULL;

    while (new_block->size < block_size) {
        sc_rover = sc_rover->next;
        if (!sc_rover)
            Sys_Error("D_SCAlloc: hit the end of memory");
        if (sc_rover->owner)
            *sc_rover->owner = NULL;

        new_block->size += sc_rover->size;
        new_block->next = sc_rover->next;
    }

    if (new_block->size - block_size > 256) {
        sc_rover = (surfcache_t*)((byte*)new_block + block_size);
        sc_rover->size = new_block->size - block_size;
        sc_rover->next = new_block->next;
        sc_rover->width = 0;
        sc_rover->owner = NULL;
        new_block->next = sc_rover;
        new_block->size = block_size;
    } else {
        sc_rover = new_block->next;
    }

    new_block->width = width;
    if (width > 0)
        new_block->height = (block_size - pi4_surfcache_data_offset()) / width;

    new_block->owner = NULL;

    if (d_roverwrapped) {
        if (wrapped_this_time || (sc_rover >= d_initial_rover))
            r_cache_thrash = true;
    } else if (wrapped_this_time) {
        d_roverwrapped = true;
    }

    D_CheckCacheGuard();
    return new_block;
}

surfcache_t* D_CacheSurface(msurface_t* surface, int miplevel)
{
    surfcache_t* cache;

    r_drawsurf.texture = R_TextureAnimation(surface->texinfo->texture);
    r_drawsurf.lightadj[0] = d_lightstylevalue[surface->styles[0]];
    r_drawsurf.lightadj[1] = d_lightstylevalue[surface->styles[1]];
    r_drawsurf.lightadj[2] = d_lightstylevalue[surface->styles[2]];
    r_drawsurf.lightadj[3] = d_lightstylevalue[surface->styles[3]];

    cache = surface->cachespots[miplevel];

    if (cache && !cache->dlight && surface->dlightframe != r_framecount
        && cache->texture == r_drawsurf.texture
        && cache->lightadj[0] == r_drawsurf.lightadj[0]
        && cache->lightadj[1] == r_drawsurf.lightadj[1]
        && cache->lightadj[2] == r_drawsurf.lightadj[2]
        && cache->lightadj[3] == r_drawsurf.lightadj[3])
        return cache;

    surfscale = 1.0 / (1 << miplevel);
    r_drawsurf.surfmip = miplevel;
    r_drawsurf.surfwidth = surface->extents[0] >> miplevel;
    r_drawsurf.rowbytes = r_drawsurf.surfwidth;
    r_drawsurf.surfheight = surface->extents[1] >> miplevel;

    if (!cache) {
        cache = D_SCAlloc(r_drawsurf.surfwidth,
            r_drawsurf.surfwidth * r_drawsurf.surfheight);
        surface->cachespots[miplevel] = cache;
        cache->owner = &surface->cachespots[miplevel];
        cache->mipscale = surfscale;
    }

    if (surface->dlightframe == r_framecount)
        cache->dlight = 1;
    else
        cache->dlight = 0;

    r_drawsurf.surfdat = (pixel_t*)cache->data;

    cache->texture = r_drawsurf.texture;
    cache->lightadj[0] = r_drawsurf.lightadj[0];
    cache->lightadj[1] = r_drawsurf.lightadj[1];
    cache->lightadj[2] = r_drawsurf.lightadj[2];
    cache->lightadj[3] = r_drawsurf.lightadj[3];

    r_drawsurf.surf = surface;

    c_surf++;
    R_DrawSurface();

    return surface->cachespots[miplevel];
}
