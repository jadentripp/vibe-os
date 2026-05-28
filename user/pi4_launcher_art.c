#include "pi4_runtime.h"

#define PI4_LAUNCHER_ICON_SIZE 256u
#define PI4_LAUNCHER_ICON_PIXELS (PI4_LAUNCHER_ICON_SIZE * PI4_LAUNCHER_ICON_SIZE)
#define PI4_LAUNCHER_ASSET_BYTES 131072u
#define PI4_LAUNCHER_PALETTE_BYTES 768u
#define PI4_LAUNCHER_WAD_DIR_ENTRY_BYTES 16u
#define PI4_LAUNCHER_PAK_DIR_ENTRY_BYTES 64u
#define PI4_LAUNCHER_DOOM_TITLEPIC_WIDTH 320u
#define PI4_LAUNCHER_DOOM_TITLEPIC_HEIGHT 200u
#define PI4_LAUNCHER_DOOM_TITLEPIC_BYTES \
    (PI4_LAUNCHER_DOOM_TITLEPIC_WIDTH * PI4_LAUNCHER_DOOM_TITLEPIC_HEIGHT)
#define PI4_LAUNCHER_ART_PAYLOAD0 0x00000001ul
#define PI4_LAUNCHER_ART_PAYLOAD1 0x00000002ul
#define PI4_LAUNCHER_APP_INDEX_READY 0x00000010ul
#define PI4_LAUNCHER_APP_DOOM_MANIFEST_READY 0x00000020ul
#define PI4_LAUNCHER_APP_DOOM_EXEC_READY 0x00000040ul
#define PI4_LAUNCHER_APP_QUAKE_MANIFEST_READY 0x00000080ul
#define PI4_LAUNCHER_APP_QUAKE_EXEC_READY 0x00000100ul
#define PI4_LAUNCHER_ART_PALETTE_BASE 32u
#define PI4_LAUNCHER_ART_PALETTE_LEVELS 6u
#define PI4_LAUNCHER_COLOR_BLACK 0u
#define PI4_LAUNCHER_COLOR_BG0 1u
#define PI4_LAUNCHER_COLOR_BG1 2u
#define PI4_LAUNCHER_COLOR_PANEL 3u
#define PI4_LAUNCHER_COLOR_SELECTED 4u
#define PI4_LAUNCHER_COLOR_TEXT 5u
#define PI4_LAUNCHER_COLOR_DIM 6u
#define PI4_LAUNCHER_COLOR_BORDER 7u
#define PI4_LAUNCHER_COLOR_DOOM 8u
#define PI4_LAUNCHER_COLOR_QUAKE 9u
#define PI4_LAUNCHER_COLOR_DOOM_DARK 10u
#define PI4_LAUNCHER_COLOR_DOOM_FIRE 11u
#define PI4_LAUNCHER_COLOR_QUAKE_DARK 12u
#define PI4_LAUNCHER_COLOR_QUAKE_GOLD 13u
#define PI4_LAUNCHER_COLOR_CARD 14u
#define PI4_LAUNCHER_COLOR_HILITE 15u
#define PI4_LAUNCHER_ICON_BLACK PI4_LAUNCHER_ART_PALETTE_BASE

typedef unsigned char u8;
typedef unsigned int u32;
typedef unsigned long usize;

unsigned long pi4_launcher_art_flags;
unsigned long pi4_launcher_app_discovery_flags;
u8 pi4_launcher_doom_icon_pixels[PI4_LAUNCHER_ICON_PIXELS];
u8 pi4_launcher_quake_icon_pixels[PI4_LAUNCHER_ICON_PIXELS];

static u8 pi4_launcher_asset[PI4_LAUNCHER_ASSET_BYTES];
static u8 pi4_launcher_doom_palette[PI4_LAUNCHER_PALETTE_BYTES];
static u8 pi4_launcher_quake_palette[PI4_LAUNCHER_PALETTE_BYTES];

static u32 load_u16(const u8* data)
{
    return (u32)data[0] | ((u32)data[1] << 8);
}

static u32 load_u32(const u8* data)
{
    return (u32)data[0]
        | ((u32)data[1] << 8)
        | ((u32)data[2] << 16)
        | ((u32)data[3] << 24);
}

static int read_exact(long fd, void* buffer, usize bytes)
{
    return vibe_user_read(fd, buffer, bytes) == (long)bytes;
}

static int seek_abs(long fd, u32 offset)
{
    return vibe_user_lseek(fd, (long)offset, PI4_VIBE_SEEK_SET) >= 0;
}

static int range_fits(u32 offset, u32 bytes, usize file_size)
{
    if (!bytes)
        return 0;
    if ((usize)offset > file_size)
        return 0;
    return (usize)bytes <= file_size - (usize)offset;
}

static void clear_icon(u8* icon)
{
    volatile u8* out = icon;
    for (usize i = 0; i < PI4_LAUNCHER_ICON_PIXELS; i++)
        out[i] = 0;
}

static void fill_icon_rect(u8* icon, u32 x, u32 y, u32 width, u32 height, u8 color)
{
    if (x >= PI4_LAUNCHER_ICON_SIZE || y >= PI4_LAUNCHER_ICON_SIZE)
        return;
    if (width > PI4_LAUNCHER_ICON_SIZE - x)
        width = PI4_LAUNCHER_ICON_SIZE - x;
    if (height > PI4_LAUNCHER_ICON_SIZE - y)
        height = PI4_LAUNCHER_ICON_SIZE - y;

    for (u32 row = 0; row < height; row++) {
        u8* out = icon + (y + row) * PI4_LAUNCHER_ICON_SIZE + x;
        for (u32 col = 0; col < width; col++)
            out[col] = color;
    }
}

static void draw_icon_border(u8* icon, u32 x, u32 y, u32 width, u32 height, u8 color)
{
    if (!width || !height)
        return;

    fill_icon_rect(icon, x, y, width, 1u, color);
    fill_icon_rect(icon, x, y + height - 1u, width, 1u, color);
    fill_icon_rect(icon, x, y, 1u, height, color);
    fill_icon_rect(icon, x + width - 1u, y, 1u, height, color);
}

static void draw_icon_diagonal(u8* icon, u32 x, u32 y, u32 steps, u8 color)
{
    for (u32 i = 0; i < steps; i++) {
        if (x + i < PI4_LAUNCHER_ICON_SIZE && y + i < PI4_LAUNCHER_ICON_SIZE)
            icon[(y + i) * PI4_LAUNCHER_ICON_SIZE + x + i] = color;
        if (x + i + 1u < PI4_LAUNCHER_ICON_SIZE && y + i < PI4_LAUNCHER_ICON_SIZE)
            icon[(y + i) * PI4_LAUNCHER_ICON_SIZE + x + i + 1u] = color;
    }
}

static void decorate_loaded_icon(u8* icon, u8 accent, u8 glow)
{
    fill_icon_rect(icon, 0u, 0u, PI4_LAUNCHER_ICON_SIZE, 4u, accent);
    fill_icon_rect(icon, 0u, 4u, PI4_LAUNCHER_ICON_SIZE, 2u, glow);
    draw_icon_border(icon, 0u, 0u, PI4_LAUNCHER_ICON_SIZE, PI4_LAUNCHER_ICON_SIZE, accent);
    draw_icon_border(icon, 4u, 4u, PI4_LAUNCHER_ICON_SIZE - 8u, PI4_LAUNCHER_ICON_SIZE - 8u, PI4_LAUNCHER_ICON_BLACK);
}

static void build_doom_fallback_icon(u8* icon)
{
    for (u32 y = 0; y < PI4_LAUNCHER_ICON_SIZE; y++) {
        for (u32 x = 0; x < PI4_LAUNCHER_ICON_SIZE; x++) {
            u8 color = PI4_LAUNCHER_COLOR_DOOM_DARK;
            if (y < 42u)
                color = ((x + y) & 8u) ? PI4_LAUNCHER_COLOR_BG1 : PI4_LAUNCHER_COLOR_DOOM_DARK;
            else if (y < 86u)
                color = ((x + (y << 1)) & 16u) ? PI4_LAUNCHER_COLOR_DOOM : PI4_LAUNCHER_COLOR_DOOM_FIRE;
            else if (y < 130u)
                color = ((x ^ y) & 16u) ? PI4_LAUNCHER_COLOR_DOOM_DARK : PI4_LAUNCHER_COLOR_DOOM;
            else
                color = ((x + y) & 12u) ? PI4_LAUNCHER_ICON_BLACK : PI4_LAUNCHER_COLOR_DOOM_DARK;
            icon[y * PI4_LAUNCHER_ICON_SIZE + x] = color;
        }
    }

    for (u32 y = 78u; y < 128u; y++) {
        for (u32 x = 0; x < PI4_LAUNCHER_ICON_SIZE; x++) {
            u32 wave = x & 63u;
            u32 peak = wave < 32u ? wave : 63u - wave;
            if (y > 76u + (peak >> 1))
                icon[y * PI4_LAUNCHER_ICON_SIZE + x] = PI4_LAUNCHER_COLOR_DOOM_DARK;
        }
    }

    fill_icon_rect(icon, 36u, 48u, 34u, 22u, PI4_LAUNCHER_COLOR_DOOM_FIRE);
    fill_icon_rect(icon, 122u, 48u, 34u, 22u, PI4_LAUNCHER_COLOR_DOOM_FIRE);
    fill_icon_rect(icon, 48u, 62u, 96u, 86u, PI4_LAUNCHER_COLOR_DOOM);
    fill_icon_rect(icon, 58u, 74u, 76u, 58u, PI4_LAUNCHER_COLOR_DOOM_FIRE);
    fill_icon_rect(icon, 70u, 88u, 18u, 14u, PI4_LAUNCHER_ICON_BLACK);
    fill_icon_rect(icon, 104u, 88u, 18u, 14u, PI4_LAUNCHER_ICON_BLACK);
    fill_icon_rect(icon, 90u, 106u, 12u, 22u, PI4_LAUNCHER_ICON_BLACK);
    fill_icon_rect(icon, 72u, 136u, 48u, 8u, PI4_LAUNCHER_ICON_BLACK);
    fill_icon_rect(icon, 78u, 136u, 6u, 16u, PI4_LAUNCHER_COLOR_TEXT);
    fill_icon_rect(icon, 94u, 136u, 6u, 16u, PI4_LAUNCHER_COLOR_TEXT);
    fill_icon_rect(icon, 110u, 136u, 6u, 16u, PI4_LAUNCHER_COLOR_TEXT);
    fill_icon_rect(icon, 0u, 158u, PI4_LAUNCHER_ICON_SIZE, 18u, PI4_LAUNCHER_ICON_BLACK);
    fill_icon_rect(icon, 22u, 164u, 148u, 5u, PI4_LAUNCHER_COLOR_DOOM_FIRE);
    draw_icon_border(icon, 7u, 7u, 178u, 178u, PI4_LAUNCHER_COLOR_DOOM_FIRE);
    draw_icon_border(icon, 0u, 0u, PI4_LAUNCHER_ICON_SIZE, PI4_LAUNCHER_ICON_SIZE, PI4_LAUNCHER_COLOR_HILITE);
}

static void build_quake_fallback_icon(u8* icon)
{
    for (u32 y = 0; y < PI4_LAUNCHER_ICON_SIZE; y++) {
        for (u32 x = 0; x < PI4_LAUNCHER_ICON_SIZE; x++) {
            u8 color = PI4_LAUNCHER_COLOR_QUAKE_DARK;
            if (((x * 5u + y * 3u) & 31u) < 8u)
                color = PI4_LAUNCHER_COLOR_BG1;
            if (y > 132u)
                color = ((x + y) & 16u) ? PI4_LAUNCHER_ICON_BLACK : PI4_LAUNCHER_COLOR_QUAKE_DARK;
            icon[y * PI4_LAUNCHER_ICON_SIZE + x] = color;
        }
    }

    fill_icon_rect(icon, 0u, 0u, PI4_LAUNCHER_ICON_SIZE, 28u, PI4_LAUNCHER_ICON_BLACK);
    fill_icon_rect(icon, 20u, 12u, 152u, 5u, PI4_LAUNCHER_COLOR_QUAKE);
    fill_icon_rect(icon, 26u, 42u, 140u, 116u, PI4_LAUNCHER_ICON_BLACK);
    fill_icon_rect(icon, 38u, 54u, 116u, 92u, PI4_LAUNCHER_COLOR_QUAKE_GOLD);
    fill_icon_rect(icon, 58u, 74u, 76u, 52u, PI4_LAUNCHER_ICON_BLACK);
    fill_icon_rect(icon, 70u, 84u, 52u, 32u, PI4_LAUNCHER_COLOR_QUAKE);
    fill_icon_rect(icon, 88u, 94u, 16u, 12u, PI4_LAUNCHER_COLOR_HILITE);
    fill_icon_rect(icon, 122u, 126u, 34u, 18u, PI4_LAUNCHER_COLOR_QUAKE_GOLD);
    fill_icon_rect(icon, 142u, 144u, 24u, 14u, PI4_LAUNCHER_COLOR_QUAKE_GOLD);
    draw_icon_diagonal(icon, 132u, 132u, 28u, PI4_LAUNCHER_COLOR_QUAKE_GOLD);
    fill_icon_rect(icon, 42u, 164u, 108u, 6u, PI4_LAUNCHER_COLOR_QUAKE);
    fill_icon_rect(icon, 58u, 174u, 76u, 5u, PI4_LAUNCHER_COLOR_QUAKE_GOLD);
    draw_icon_border(icon, 7u, 7u, 178u, 178u, PI4_LAUNCHER_COLOR_QUAKE_GOLD);
    draw_icon_border(icon, 0u, 0u, PI4_LAUNCHER_ICON_SIZE, PI4_LAUNCHER_ICON_SIZE, PI4_LAUNCHER_COLOR_HILITE);
}

static u8 ascii_upper(u8 ch)
{
    if (ch >= 'a' && ch <= 'z')
        return (u8)(ch - ('a' - 'A'));
    return ch;
}

static u8 path_fold(u8 ch)
{
    if (ch == '\\')
        return '/';
    return ascii_upper(ch);
}

static int wad_name_eq(const u8* name, const char* want)
{
    for (u32 i = 0; i < 8u; i++) {
        u8 expected = (u8)want[i];
        if (!expected) {
            for (; i < 8u; i++) {
                if (name[i] != 0 && name[i] != ' ')
                    return 0;
            }
            return 1;
        }
        if (ascii_upper(name[i]) != ascii_upper(expected))
            return 0;
    }
    return want[8] == 0;
}

static int pak_name_eq(const u8* name, const char* want)
{
    u32 name_i = 0;
    u32 want_i = 0;

    while (name_i < 56u && (name[name_i] == '/' || name[name_i] == '\\'))
        name_i++;
    while (want[want_i] == '/' || want[want_i] == '\\')
        want_i++;

    for (;;) {
        if (name_i >= 56u)
            return want[want_i] == 0;

        u8 actual = name[name_i];
        u8 expected = (u8)want[want_i];
        if (!expected)
            return actual == 0;
        if (!actual)
            return 0;
        if (path_fold(actual) != path_fold(expected))
            return 0;
        name_i++;
        want_i++;
    }
}

static u8 palette_to_launcher_color(const u8* palette, u8 color_index)
{
    u32 offset = (u32)color_index * 3u;
    u32 red = ((u32)palette[offset + 0u] * PI4_LAUNCHER_ART_PALETTE_LEVELS) >> 8;
    u32 green = ((u32)palette[offset + 1u] * PI4_LAUNCHER_ART_PALETTE_LEVELS) >> 8;
    u32 blue = ((u32)palette[offset + 2u] * PI4_LAUNCHER_ART_PALETTE_LEVELS) >> 8;

    return (u8)(PI4_LAUNCHER_ART_PALETTE_BASE + red * 36u + green * 6u + blue);
}

static void cover_source_for_icon(
    u32 width,
    u32 height,
    u32* source_x,
    u32* source_y,
    u32* source_w,
    u32* source_h)
{
    *source_x = 0;
    *source_y = 0;
    *source_w = 0;
    *source_h = 0;

    if (!width || !height)
        return;

    if (width >= height) {
        *source_w = height;
        *source_h = height;
        *source_x = (width - height) >> 1;
    } else {
        *source_w = width;
        *source_h = width;
        *source_y = (height - width) >> 1;
    }
}

static int doom_patch_sample(const u8* patch, u32 patch_size, u32 width, u32 source_x, u32 source_y, u8* out)
{
    if (source_x >= width)
        return 0;

    u32 column_table = 8u + source_x * 4u;
    if (column_table + 4u > patch_size)
        return 0;

    u32 post = load_u32(patch + column_table);
    if (post >= patch_size)
        return 0;

    while (post < patch_size) {
        u32 top = patch[post + 0u];
        if (top == 0xffu)
            return 0;
        if (post + 4u > patch_size)
            return 0;

        u32 count = patch[post + 1u];
        u32 pixels = post + 3u;
        if (count > patch_size - post - 4u)
            return 0;

        if (source_y >= top && source_y < top + count) {
            *out = patch[pixels + (source_y - top)];
            return 1;
        }

        post += count + 4u;
    }

    return 0;
}

static int decode_doom_titlepic_icon(u8* icon, const u8* pixels, u32 pixel_size, const u8* palette)
{
    if (pixel_size < PI4_LAUNCHER_DOOM_TITLEPIC_BYTES)
        return 0;

    u32 crop_x;
    u32 crop_y;
    u32 crop_w;
    u32 crop_h;
    clear_icon(icon);
    cover_source_for_icon(
        PI4_LAUNCHER_DOOM_TITLEPIC_WIDTH,
        PI4_LAUNCHER_DOOM_TITLEPIC_HEIGHT,
        &crop_x,
        &crop_y,
        &crop_w,
        &crop_h);
    if (!crop_w || !crop_h)
        return 0;

    for (u32 y = 0; y < PI4_LAUNCHER_ICON_SIZE; y++) {
        u32 source_y = crop_y + (y * crop_h) / PI4_LAUNCHER_ICON_SIZE;
        for (u32 x = 0; x < PI4_LAUNCHER_ICON_SIZE; x++) {
            u32 source_x = crop_x + (x * crop_w) / PI4_LAUNCHER_ICON_SIZE;
            u32 source_offset = source_y * PI4_LAUNCHER_DOOM_TITLEPIC_WIDTH + source_x;
            icon[y * PI4_LAUNCHER_ICON_SIZE + x] = palette_to_launcher_color(
                palette,
                pixels[source_offset]);
        }
    }

    return 1;
}

static int decode_doom_patch_icon(u8* icon, const u8* patch, u32 patch_size, const u8* palette)
{
    if (patch_size < 8u)
        return 0;

    u32 width = load_u16(patch + 0u);
    u32 height = load_u16(patch + 2u);
    if (!width || !height || width > 1024u || height > 1024u)
        return 0;
    if (width > (patch_size - 8u) / 4u)
        return 0;

    u32 crop_x;
    u32 crop_y;
    u32 crop_w;
    u32 crop_h;
    clear_icon(icon);
    cover_source_for_icon(width, height, &crop_x, &crop_y, &crop_w, &crop_h);
    if (!crop_w || !crop_h)
        return 0;

    for (u32 y = 0; y < PI4_LAUNCHER_ICON_SIZE; y++) {
        u32 source_y = crop_y + (y * crop_h) / PI4_LAUNCHER_ICON_SIZE;
        for (u32 x = 0; x < PI4_LAUNCHER_ICON_SIZE; x++) {
            u32 source_x = crop_x + (x * crop_w) / PI4_LAUNCHER_ICON_SIZE;
            u8 color_index = 0;
            if (doom_patch_sample(patch, patch_size, width, source_x, source_y, &color_index)) {
                icon[y * PI4_LAUNCHER_ICON_SIZE + x] =
                    palette_to_launcher_color(palette, color_index);
            }
        }
    }

    return 1;
}

static int decode_quake_qpic_icon(u8* icon, const u8* qpic, u32 qpic_size, const u8* palette)
{
    if (qpic_size < 8u)
        return 0;

    u32 width = load_u32(qpic + 0u);
    u32 height = load_u32(qpic + 4u);
    if (!width || !height || width > 1024u || height > 1024u)
        return 0;
    if (width > (qpic_size - 8u) / height)
        return 0;

    u32 crop_x;
    u32 crop_y;
    u32 crop_w;
    u32 crop_h;
    clear_icon(icon);
    cover_source_for_icon(width, height, &crop_x, &crop_y, &crop_w, &crop_h);
    if (!crop_w || !crop_h)
        return 0;

    for (u32 y = 0; y < PI4_LAUNCHER_ICON_SIZE; y++) {
        u32 source_y = crop_y + (y * crop_h) / PI4_LAUNCHER_ICON_SIZE;
        for (u32 x = 0; x < PI4_LAUNCHER_ICON_SIZE; x++) {
            u32 source_x = crop_x + (x * crop_w) / PI4_LAUNCHER_ICON_SIZE;
            u32 source_offset = 8u + source_y * width + source_x;
            icon[y * PI4_LAUNCHER_ICON_SIZE + x] =
                palette_to_launcher_color(palette, qpic[source_offset]);
        }
    }

    return 1;
}

static int load_doom_icon(void)
{
    const char* paths[] = {
        "DOOM1.WAD",
        "/DOOM1.WAD",
        "doom1.wad",
        "/doom1.wad",
    };
    u8 header[12];
    u32 doom_logo_offset = 0;
    u32 doom_logo_size = 0;
    u32 titlepic_offset = 0;
    u32 titlepic_size = 0;
    u32 playpal_offset = 0;
    usize file_size = 0;

    long fd = -1;
    for (u32 i = 0; i < sizeof(paths) / sizeof(paths[0]); i++) {
        fd = vibe_user_open(paths[i], PI4_VIBE_O_RDONLY, 0);
        if (fd >= 0)
            break;
    }

    int ok = 0;
    if (fd < 0)
        return 0;

    long raw_file_size = vibe_user_file_size((pi4_vibe_word_t)fd);
    if (raw_file_size <= 0)
        goto done;
    file_size = (usize)raw_file_size;

    if (!read_exact(fd, header, sizeof(header)))
        goto done;
    if ((header[0] != 'I' && header[0] != 'P') || header[1] != 'W' ||
        header[2] != 'A' || header[3] != 'D')
        goto done;

    u32 entry_count = load_u32(header + 4u);
    u32 dir_offset = load_u32(header + 8u);
    if (!entry_count || entry_count > PI4_LAUNCHER_ASSET_BYTES / PI4_LAUNCHER_WAD_DIR_ENTRY_BYTES)
        goto done;

    u32 dir_bytes = entry_count * PI4_LAUNCHER_WAD_DIR_ENTRY_BYTES;
    if (!range_fits(dir_offset, dir_bytes, file_size))
        goto done;
    if (!seek_abs(fd, dir_offset) || !read_exact(fd, pi4_launcher_asset, dir_bytes))
        goto done;

    for (u32 i = 0; i < entry_count; i++) {
        const u8* entry = pi4_launcher_asset + i * PI4_LAUNCHER_WAD_DIR_ENTRY_BYTES;
        u32 offset = load_u32(entry + 0u);
        u32 size = load_u32(entry + 4u);
        if (wad_name_eq(entry + 8u, "M_DOOM") && size >= 8u &&
            size <= PI4_LAUNCHER_ASSET_BYTES && range_fits(offset, size, file_size)) {
            doom_logo_offset = offset;
            doom_logo_size = size;
        } else if (wad_name_eq(entry + 8u, "TITLEPIC") && size >= 8u &&
            size <= PI4_LAUNCHER_ASSET_BYTES && range_fits(offset, size, file_size)) {
            titlepic_offset = offset;
            titlepic_size = size;
        } else if (wad_name_eq(entry + 8u, "PLAYPAL") && size >= PI4_LAUNCHER_PALETTE_BYTES) {
            if (range_fits(offset, PI4_LAUNCHER_PALETTE_BYTES, file_size))
                playpal_offset = offset;
        }
    }

    if ((!doom_logo_offset && (!titlepic_offset || !titlepic_size)) || !playpal_offset)
        goto done;
    if (!seek_abs(fd, playpal_offset) ||
        !read_exact(fd, pi4_launcher_doom_palette, PI4_LAUNCHER_PALETTE_BYTES))
        goto done;

    if (titlepic_offset && seek_abs(fd, titlepic_offset) &&
        read_exact(fd, pi4_launcher_asset, titlepic_size)) {
        ok = decode_doom_titlepic_icon(
            pi4_launcher_doom_icon_pixels,
            pi4_launcher_asset,
            titlepic_size,
            pi4_launcher_doom_palette);
        if (!ok)
            ok = decode_doom_patch_icon(
                pi4_launcher_doom_icon_pixels,
                pi4_launcher_asset,
                titlepic_size,
                pi4_launcher_doom_palette);
    }

    if (!ok && doom_logo_offset && seek_abs(fd, doom_logo_offset) &&
        read_exact(fd, pi4_launcher_asset, doom_logo_size)) {
        ok = decode_doom_patch_icon(
            pi4_launcher_doom_icon_pixels,
            pi4_launcher_asset,
            doom_logo_size,
            pi4_launcher_doom_palette);
    }

done:
    vibe_user_close(fd);
    return ok;
}

static int load_quake_icon(void)
{
    const char* paths[] = {
        "/ID1/PAK0.PAK",
        "ID1/PAK0.PAK",
        "/id1/pak0.pak",
        "id1/pak0.pak",
    };
    u8 header[12];
    u32 conback_offset = 0;
    u32 conback_size = 0;
    u32 qplaque_offset = 0;
    u32 qplaque_size = 0;
    u32 palette_offset = 0;
    usize file_size = 0;

    long fd = -1;
    for (u32 i = 0; i < sizeof(paths) / sizeof(paths[0]); i++) {
        fd = vibe_user_open(paths[i], PI4_VIBE_O_RDONLY, 0);
        if (fd >= 0)
            break;
    }

    int ok = 0;
    if (fd < 0)
        return 0;

    long raw_file_size = vibe_user_file_size((pi4_vibe_word_t)fd);
    if (raw_file_size <= 0)
        goto done;
    file_size = (usize)raw_file_size;

    if (!read_exact(fd, header, sizeof(header)))
        goto done;
    if (header[0] != 'P' || header[1] != 'A' || header[2] != 'C' || header[3] != 'K')
        goto done;

    u32 dir_offset = load_u32(header + 4u);
    u32 dir_bytes = load_u32(header + 8u);
    if (!dir_bytes || dir_bytes > PI4_LAUNCHER_ASSET_BYTES ||
        dir_bytes % PI4_LAUNCHER_PAK_DIR_ENTRY_BYTES)
        goto done;
    if (!range_fits(dir_offset, dir_bytes, file_size))
        goto done;

    u32 entry_count = dir_bytes / PI4_LAUNCHER_PAK_DIR_ENTRY_BYTES;
    if (!seek_abs(fd, dir_offset) || !read_exact(fd, pi4_launcher_asset, dir_bytes))
        goto done;

    for (u32 i = 0; i < entry_count; i++) {
        const u8* entry = pi4_launcher_asset + i * PI4_LAUNCHER_PAK_DIR_ENTRY_BYTES;
        u32 offset = load_u32(entry + 56u);
        u32 size = load_u32(entry + 60u);
        if (pak_name_eq(entry, "gfx/qplaque.lmp") && size >= 8u &&
            size <= PI4_LAUNCHER_ASSET_BYTES && range_fits(offset, size, file_size)) {
            qplaque_offset = offset;
            qplaque_size = size;
        } else if (pak_name_eq(entry, "gfx/conback.lmp") && size >= 8u &&
            size <= PI4_LAUNCHER_ASSET_BYTES && range_fits(offset, size, file_size)) {
            conback_offset = offset;
            conback_size = size;
        } else if (pak_name_eq(entry, "gfx/palette.lmp") &&
            size >= PI4_LAUNCHER_PALETTE_BYTES) {
            if (range_fits(offset, PI4_LAUNCHER_PALETTE_BYTES, file_size))
                palette_offset = offset;
        }
    }

    if ((!conback_offset && (!qplaque_offset || !qplaque_size)) || !palette_offset)
        goto done;
    if (!seek_abs(fd, palette_offset) ||
        !read_exact(fd, pi4_launcher_quake_palette, PI4_LAUNCHER_PALETTE_BYTES))
        goto done;

    if (conback_offset && seek_abs(fd, conback_offset) &&
        read_exact(fd, pi4_launcher_asset, conback_size)) {
        ok = decode_quake_qpic_icon(
            pi4_launcher_quake_icon_pixels,
            pi4_launcher_asset,
            conback_size,
            pi4_launcher_quake_palette);
    }

    if (!ok && qplaque_offset && seek_abs(fd, qplaque_offset) &&
        read_exact(fd, pi4_launcher_asset, qplaque_size)) {
        ok = decode_quake_qpic_icon(
            pi4_launcher_quake_icon_pixels,
            pi4_launcher_asset,
            qplaque_size,
            pi4_launcher_quake_palette);
    }

done:
    vibe_user_close(fd);
    return ok;
}

static int read_installed_app_prefix(const char* path, u32 bytes)
{
    pi4_vibe_word_t got = 0;

    if (!bytes || bytes > PI4_LAUNCHER_ASSET_BYTES)
        return 0;
    if (vibe_user_file_read_at(path, 0, pi4_launcher_asset, bytes, &got) != 0)
        return 0;
    return got == bytes;
}

static int read_installed_app_elf_magic(const char* path)
{
    if (!read_installed_app_prefix(path, 4u))
        return 0;
    return pi4_launcher_asset[0] == 0x7fu &&
        pi4_launcher_asset[1] == 'E' &&
        pi4_launcher_asset[2] == 'L' &&
        pi4_launcher_asset[3] == 'F';
}

static void load_installed_app_metadata(void)
{
    unsigned long flags = 0;

    if (read_installed_app_prefix(PI4_VIBE_APP_INDEX_PATH, 16u))
        flags |= PI4_LAUNCHER_APP_INDEX_READY;
    if (read_installed_app_prefix(PI4_VIBE_DOOM_APP_MANIFEST_PATH, 16u))
        flags |= PI4_LAUNCHER_APP_DOOM_MANIFEST_READY;
    if (read_installed_app_elf_magic(PI4_VIBE_DOOM_APP_PATH))
        flags |= PI4_LAUNCHER_APP_DOOM_EXEC_READY;
    if (read_installed_app_prefix(PI4_VIBE_QUAKE_APP_MANIFEST_PATH, 16u))
        flags |= PI4_LAUNCHER_APP_QUAKE_MANIFEST_READY;
    if (read_installed_app_elf_magic(PI4_VIBE_QUAKE_APP_PATH))
        flags |= PI4_LAUNCHER_APP_QUAKE_EXEC_READY;

    pi4_launcher_app_discovery_flags = flags;
}

void pi4_launcher_load_art(void)
{
    clear_icon(pi4_launcher_doom_icon_pixels);
    clear_icon(pi4_launcher_quake_icon_pixels);
    pi4_launcher_art_flags = 0;
    pi4_launcher_app_discovery_flags = 0;
    load_installed_app_metadata();

    if (load_doom_icon()) {
        decorate_loaded_icon(
            pi4_launcher_doom_icon_pixels,
            PI4_LAUNCHER_COLOR_DOOM_FIRE,
            PI4_LAUNCHER_COLOR_HILITE);
    } else {
        build_doom_fallback_icon(pi4_launcher_doom_icon_pixels);
    }
    pi4_launcher_art_flags |= PI4_LAUNCHER_ART_PAYLOAD0;

    if (load_quake_icon()) {
        decorate_loaded_icon(
            pi4_launcher_quake_icon_pixels,
            PI4_LAUNCHER_COLOR_QUAKE_GOLD,
            PI4_LAUNCHER_COLOR_QUAKE);
    } else {
        build_quake_fallback_icon(pi4_launcher_quake_icon_pixels);
    }
    pi4_launcher_art_flags |= PI4_LAUNCHER_ART_PAYLOAD1;
}
