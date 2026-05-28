#include <errno.h>
#include <limits.h>
#include <stdint.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef PATH_MAX
#define PATH_MAX 4096
#endif

enum {
    SECTOR_SIZE = 512,
    IMAGE_SECTORS = 131072,
    STAGE2_LBA = 1,
    STAGE2_SECTORS = 16,
    KERNEL_LBA = 17,
    KERNEL_SECTORS = 320,
    PARTITION_START = 2048,
    RESERVED_SECTORS = 1,
    FAT_COUNT = 2,
    ROOT_ENTRIES = 512,
    SECTORS_PER_CLUSTER = 2,
    SECTORS_PER_FAT = 256,
    FAT16_EOC = 0xfff8,
    FAT16_EOC_VALUE = 0xffff,
    FAT_ATTR_READ_ONLY = 0x01,
    FAT_ATTR_DIRECTORY = 0x10,
    FAT_ATTR_ARCHIVE = 0x20,
    FIXTURE_WAD_SIZE = 1024 * 1024,
    MAX_PRIMARY_WAD_BYTES = 0x00500000,
    PAK_DIRECTORY_ENTRY_SIZE = 64,
    MIN_OS_CREATED_FILE_CLUSTERS = 4096,
    DEFAULT_PI4_ASSET_COUNT = 3,
    DEFAULT_PI4_PALETTE_BYTES = 32,
};

enum {
    PARTITION_SECTORS = IMAGE_SECTORS - PARTITION_START,
    ROOT_DIR_SECTORS = (ROOT_ENTRIES * 32 + SECTOR_SIZE - 1) / SECTOR_SIZE,
    FAT_ENTRY_COUNT = SECTORS_PER_FAT * SECTOR_SIZE / 2,
};

typedef struct {
    uint8_t* data;
    size_t size;
} Blob;

typedef struct {
    uint8_t* data;
    size_t size;
    uint16_t fat[FAT_ENTRY_COUNT];
} Image;

typedef struct {
    uint32_t filepos;
    uint32_t size;
    char name[8];
} WadLump;

typedef struct {
    char name[11];
    const char* path;
} RootElfArg;

typedef struct {
    char display[96];
    const char* path;
} AssetArg;

typedef struct {
    char name[11];
    const char* path;
} RootFileArg;

typedef struct {
    char file[96];
    size_t size;
} ManifestEntry;

typedef struct {
    char* data;
    size_t size;
    size_t cap;
} TextBuffer;

typedef struct {
    int enabled;
    int primary_asset_external;
    size_t primary_asset_size;
    int quake_pak_present;
    size_t quake_pak_size;
    ManifestEntry* root_elves;
    size_t root_elf_count;
    ManifestEntry* root_files;
    size_t root_file_count;
    ManifestEntry* assets;
    size_t asset_count;
} ProofManifest;

typedef struct {
    int present;
    uint8_t attr;
    uint32_t first_cluster;
    uint32_t size;
} FatFileInfo;

typedef struct {
    const char* baseline_image;
    const char* reboot_baseline_image;
    const char* write_status;
    const char* save_write_status;
    const char* load_status;
    const char* reboot_status;
    int require_default;
    int require_dynamic_fat_proof;
    int save_slots[6];
    size_t save_slot_count;
    const char* save_descriptions[6];
} PersistenceCheck;

static const char USER_PROBE_NAME[] = "USERPROBELF";
static const char LEGACY_PAYLOAD_ELF_NAME[] = "PAYLOAD0ELF";
static const char KERNEL_ELF_NAME[] = "KERNEL  ELF";
static const char PI4_KERNEL8_IMG_NAME[] = "KERNEL8 IMG";
static const char PI4_CONFIG_TXT_NAME[] = "CONFIG  TXT";
static const char INIT_ELF_NAME[] = "INIT    ELF";
static const char ABI_PROBE_ELF_NAME[] = "ABIPROBEELF";
static const char PAYLOAD1_ELF_NAME[] = "PAYLOAD1ELF";
static const char PRIMARY_ASSET_WAD_NAME[] = "DOOM1   WAD";
static const char QUAKE_ID1_DIR_NAME[] = "ID1        ";
static const char QUAKE_PAK0_NAME[] = "PAK0    PAK";
static const char DEFAULT_CFG_NAME[] = "DEFAULT CFG";
static const uint8_t DEFAULT_CFG_CONTENT[] = "screenblocks\t\t11\n";
static const char PERSISTENCE_CHECKPOINT_NAME[] = "PERSIST CHK";
static const char SAVE_REQUEST_NAME[] = "SAVEREQ CHK";
static const char LOAD_REQUEST_NAME[] = "LOADREQ CHK";
static const char STATE_DIR_NAME[] = "STATE      ";
static const char PRIMARY_SAVE_SLOT_TEMPLATE_NAME[] = "DOOMSAV DSG";
static const char PROOF_MANIFEST_PATH[] = "/PROOF/MANIFEST.TXT";
static const char PROOF_QUAKE_PAK_PATH[] = "/ID1/PAK0.PAK";
static const char PI4_SYSTEM_INIT_PATH[] = "/SYSTEM/INIT.ELF";
static const char PI4_SYSTEM_ABIPROBE_PATH[] = "/SYSTEM/ABIPROBE.ELF";
static const char PI4_APP_INDEX_PATH[] = "/APPS/INDEX.TXT";
static const char PI4_DOOM_APP_MANIFEST_PATH[] = "/APPS/DOOM/APP.TXT";
static const char PI4_DOOM_APP_EXEC_PATH[] = "/APPS/DOOM/APP.ELF";
static const char PI4_QUAKE_APP_MANIFEST_PATH[] = "/APPS/QUAKE/APP.TXT";
static const char PI4_QUAKE_APP_EXEC_PATH[] = "/APPS/QUAKE/APP.ELF";
static const char PI4_APP_LAYOUT[] = "system-init-plus-apps-tree";
static const char PI4_APP_DISCOVERY_MODEL[] = "vfs-app-index";
static const char PI4_APP_EXEC_MODEL[] = "generic-aarch64-el0-elf-by-path";
static const char PI4_LEGACY_ROOT_PAYLOADS[] = "compatibility-only";
static const char PI4_DOOM_APP_NAME[] = "DOOM";
static const char PI4_QUAKE_APP_NAME[] = "Quake";
static const char PI4_DOOM_APP_RESOURCE_PATH[] = "/DOOM1.WAD";
static const char PI4_QUAKE_APP_RESOURCE_PATH[] = "/ID1/PAK0.PAK";
static const char PI4_DOOM_APP_ICON[] = "wad:TITLEPIC";
static const char PI4_QUAKE_APP_ICON[] = "pak:gfx/conback.lmp";
static const char PI4_APP_INPUT[] = "keyboard,mouse";
static const char DEFAULT_PI4_ASSET_README_PATH[] = "/ASSETS/README.TXT";
static const char DEFAULT_PI4_ASSET_MAP_PATH[] = "/ASSETS/MAPS/E1M1.MAP";
static const char DEFAULT_PI4_ASSET_PALETTE_PATH[] = "/ASSETS/TEXTURES/PAL0.BIN";
static const uint8_t DEFAULT_PI4_ASSET_README[] = "vibe-os FAT16 one-level asset file\n";
static const uint8_t DEFAULT_PI4_ASSET_MAP[] = "name=E1M1\nmusic=D_E1M1\n";
static const char MBR_DISK_ID[] = "VOSD";
static const char FAT_OEM_NAME[] = "VIBEOS  ";
static const char FAT_VOLUME_LABEL[] = "VIBEOS WAD ";
static const uint8_t FIXTURE_MUS_SCORE_END[] = {
    'M', 'U', 'S', 0x1a,
    0x01, 0x00, 0x10, 0x00,
    0x01, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00,
    0x60,
};

static const char* const switch_textures[] = {
    "SW1BRCOM", "SW2BRCOM", "SW1BRN1", "SW2BRN1", "SW1BRN2", "SW2BRN2",
    "SW1BRNGN", "SW2BRNGN", "SW1BROWN", "SW2BROWN", "SW1COMM", "SW2COMM",
    "SW1COMP", "SW2COMP", "SW1DIRT", "SW2DIRT", "SW1EXIT", "SW2EXIT",
    "SW1GRAY", "SW2GRAY", "SW1GRAY1", "SW2GRAY1", "SW1METAL", "SW2METAL",
    "SW1PIPE", "SW2PIPE", "SW1SLAD", "SW2SLAD", "SW1STARG", "SW2STARG",
    "SW1STON1", "SW2STON1", "SW1STON2", "SW2STON2", "SW1STONE", "SW2STONE",
    "SW1STRTN", "SW2STRTN", "SKY1", "SKY2", "SKY3", "SKY4",
};

static void die(const char* message)
{
    fprintf(stderr, "make_wad_image: %s\n", message);
    exit(1);
}

static void die_path(const char* path, const char* message)
{
    fprintf(stderr, "make_wad_image: %s: %s\n", path, message);
    exit(1);
}

static void* xcalloc(size_t count, size_t size)
{
    void* ptr = calloc(count, size);
    if (!ptr)
        die("out of memory");
    return ptr;
}

static void* xrealloc(void* ptr, size_t size)
{
    void* out = realloc(ptr, size);
    if (!out)
        die("out of memory");
    return out;
}

static uint16_t get_u16(const uint8_t* data, size_t size, size_t off)
{
    if (off + 2 > size)
        die("read past end");
    return (uint16_t)data[off] | ((uint16_t)data[off + 1] << 8);
}

static uint32_t get_u32(const uint8_t* data, size_t size, size_t off)
{
    if (off + 4 > size)
        die("read past end");
    return (uint32_t)data[off]
        | ((uint32_t)data[off + 1] << 8)
        | ((uint32_t)data[off + 2] << 16)
        | ((uint32_t)data[off + 3] << 24);
}

static void put_u16(uint8_t* data, size_t size, size_t off, uint16_t value)
{
    if (off + 2 > size)
        die("write past end");
    data[off] = (uint8_t)value;
    data[off + 1] = (uint8_t)(value >> 8);
}

static void put_u32(uint8_t* data, size_t size, size_t off, uint32_t value)
{
    if (off + 4 > size)
        die("write past end");
    data[off] = (uint8_t)value;
    data[off + 1] = (uint8_t)(value >> 8);
    data[off + 2] = (uint8_t)(value >> 16);
    data[off + 3] = (uint8_t)(value >> 24);
}

static size_t sector_offset(uint32_t lba)
{
    return (size_t)lba * SECTOR_SIZE;
}

static uint32_t cluster_size(void)
{
    return SECTORS_PER_CLUSTER * SECTOR_SIZE;
}

static uint32_t clusters_for_size(size_t size)
{
    uint32_t bytes = cluster_size();
    uint32_t count = (uint32_t)((size + bytes - 1) / bytes);
    return count ? count : 1;
}

static uint32_t data_cluster_count(void)
{
    uint32_t metadata = RESERVED_SECTORS + FAT_COUNT * SECTORS_PER_FAT + ROOT_DIR_SECTORS;
    return (PARTITION_SECTORS - metadata) / SECTORS_PER_CLUSTER;
}

static uint32_t last_data_cluster(void)
{
    return data_cluster_count() + 1;
}

static uint32_t root_lba(void)
{
    return PARTITION_START + RESERVED_SECTORS + FAT_COUNT * SECTORS_PER_FAT;
}

static uint32_t data_lba(void)
{
    return root_lba() + ROOT_DIR_SECTORS;
}

static size_t cluster_offset(uint32_t cluster)
{
    if (cluster < 2 || cluster > last_data_cluster())
        die("cluster outside FAT16 data area");
    return sector_offset(data_lba() + (cluster - 2) * SECTORS_PER_CLUSTER);
}

static Blob read_file(const char* path)
{
    FILE* f = fopen(path, "rb");
    if (!f)
        die_path(path, strerror(errno));
    if (fseek(f, 0, SEEK_END) != 0)
        die_path(path, "seek failed");
    long end = ftell(f);
    if (end < 0)
        die_path(path, "tell failed");
    if (fseek(f, 0, SEEK_SET) != 0)
        die_path(path, "seek failed");

    Blob blob;
    blob.size = (size_t)end;
    blob.data = (uint8_t*)xcalloc(blob.size + 1, 1);
    if (blob.size && fread(blob.data, 1, blob.size, f) != blob.size)
        die_path(path, "read failed");
    fclose(f);
    return blob;
}

static void write_file(const char* path, const uint8_t* data, size_t size)
{
    FILE* f = fopen(path, "wb");
    if (!f)
        die_path(path, strerror(errno));
    if (size && fwrite(data, 1, size, f) != size)
        die_path(path, "write failed");
    fclose(f);
}

static void format_fat_name(const uint8_t* raw, char out[13])
{
    size_t pos = 0;
    for (size_t i = 0; i < 8 && raw[i] != ' '; i++)
        out[pos++] = (char)raw[i];
    if (raw[8] != ' ') {
        out[pos++] = '.';
        for (size_t i = 8; i < 11 && raw[i] != ' '; i++)
            out[pos++] = (char)raw[i];
    }
    out[pos] = 0;
}

static void text_appendf(TextBuffer* text, const char* fmt, ...)
{
    for (;;) {
        if (!text->data) {
            text->cap = 512;
            text->data = (char*)xcalloc(text->cap, 1);
        }
        if (text->cap - text->size < 128) {
            text->cap *= 2;
            text->data = (char*)xrealloc(text->data, text->cap);
        }

        va_list ap;
        va_start(ap, fmt);
        int written = vsnprintf(text->data + text->size, text->cap - text->size, fmt, ap);
        va_end(ap);
        if (written < 0)
            die("manifest formatting failed");
        if ((size_t)written < text->cap - text->size) {
            text->size += (size_t)written;
            return;
        }

        text->cap = text->size + (size_t)written + 1;
        text->data = (char*)xrealloc(text->data, text->cap);
    }
}

static void manifest_add_entry(ManifestEntry** entries, size_t* count, const char* file, size_t size)
{
    *entries = (ManifestEntry*)xrealloc(*entries, (*count + 1) * sizeof((*entries)[0]));
    int written = snprintf((*entries)[*count].file, sizeof((*entries)[*count].file), "%s", file);
    if (written < 0 || (size_t)written >= sizeof((*entries)[*count].file))
        die("manifest file name is too long");
    (*entries)[*count].size = size;
    (*count)++;
}

static void manifest_note_root_elf(ProofManifest* manifest, const char name[11], size_t size)
{
    if (!manifest->enabled)
        return;
    char display[13];
    format_fat_name((const uint8_t*)name, display);
    manifest_add_entry(&manifest->root_elves, &manifest->root_elf_count, display, size);
}

static void manifest_note_root_file(ProofManifest* manifest, const char name[11], size_t size)
{
    if (!manifest->enabled)
        return;
    char display[13];
    format_fat_name((const uint8_t*)name, display);
    manifest_add_entry(&manifest->root_files, &manifest->root_file_count, display, size);
}

static void manifest_note_asset(ProofManifest* manifest, const char* display, size_t size)
{
    if (!manifest->enabled)
        return;
    manifest_add_entry(&manifest->assets, &manifest->asset_count, display, size);
}

static const ManifestEntry* manifest_find(const ManifestEntry* entries, size_t count, const char* file)
{
    for (size_t i = 0; i < count; i++) {
        if (strcmp(entries[i].file, file) == 0)
            return &entries[i];
    }
    return NULL;
}

static void free_proof_manifest(ProofManifest* manifest)
{
    free(manifest->root_elves);
    free(manifest->root_files);
    free(manifest->assets);
}

static int inspect_path_has_component(const char* cursor)
{
    while (*cursor == '/' || *cursor == '\\')
        cursor++;
    return *cursor != '\0';
}

static int inspect_next_path_component(const char** cursor, char* component, size_t component_size)
{
    size_t len = 0;

    while (**cursor == '/' || **cursor == '\\')
        (*cursor)++;
    if (!**cursor)
        return 0;
    while (**cursor && **cursor != '/' && **cursor != '\\') {
        if (len + 1 >= component_size)
            die("inspect path component is too long");
        component[len++] = **cursor;
        (*cursor)++;
    }
    component[len] = '\0';
    return 1;
}

static int inspect_find_entry_in_dir(const Blob* image, const uint8_t* dir, size_t dir_size, const char* component, FatFileInfo* out)
{
    (void)image;
    for (uint32_t i = 0; (size_t)i * 32 + 32 <= dir_size; i++) {
        const uint8_t* entry = dir + (size_t)i * 32;
        if (entry[0] == 0)
            return 0;
        if (entry[0] == 0xe5 || entry[0] == '.' || entry[11] == 0x0f)
            continue;

        char name[13];
        format_fat_name(entry, name);
        if (strcmp(name, component) != 0)
            continue;

        memset(out, 0, sizeof(*out));
        out->present = 1;
        out->attr = entry[11];
        out->first_cluster = get_u16(dir, dir_size, (size_t)i * 32 + 26);
        out->size = get_u32(dir, dir_size, (size_t)i * 32 + 28);
        return 1;
    }
    return 0;
}

static int inspect_find_path(const Blob* image, const char* path, FatFileInfo* out)
{
    const uint8_t* dir = image->data + sector_offset(root_lba());
    size_t dir_size = ROOT_ENTRIES * 32;
    const char* cursor = path;
    char component[64];
    int saw_component = 0;

    while (inspect_next_path_component(&cursor, component, sizeof(component))) {
        FatFileInfo info;
        saw_component = 1;
        if (!inspect_find_entry_in_dir(image, dir, dir_size, component, &info))
            return 0;
        if (!inspect_path_has_component(cursor)) {
            *out = info;
            return 1;
        }
        if ((info.attr & FAT_ATTR_DIRECTORY) == 0)
            return 0;
        if (info.first_cluster < 2 || info.first_cluster > last_data_cluster())
            die_path(path, "directory has invalid first cluster");
        dir = image->data + cluster_offset(info.first_cluster);
        dir_size = cluster_size();
    }

    return saw_component ? 0 : 0;
}

static uint16_t inspect_fat_entry(const Blob* image, uint32_t cluster)
{
    if (cluster >= FAT_ENTRY_COUNT)
        die("FAT cluster outside table");
    const uint8_t* fat = image->data + sector_offset(PARTITION_START + RESERVED_SECTORS);
    return get_u16(fat, SECTORS_PER_FAT * SECTOR_SIZE, (size_t)cluster * 2);
}

static Blob inspect_read_file_blob(const Blob* image, const FatFileInfo* info, const char* label)
{
    Blob out;
    out.size = info->size;
    out.data = (uint8_t*)xcalloc(out.size + 1, 1);
    if (!out.size)
        return out;
    if (info->attr & FAT_ATTR_DIRECTORY)
        die_path(label, "expected a file, found a directory");
    if (info->first_cluster < 2 || info->first_cluster > last_data_cluster())
        die_path(label, "file has invalid first cluster");

    uint32_t cluster = info->first_cluster;
    size_t copied = 0;
    uint32_t guard = 0;
    while (copied < out.size) {
        if (cluster < 2 || cluster > last_data_cluster() || guard++ > data_cluster_count())
            die_path(label, "file cluster chain is invalid");
        size_t chunk = out.size - copied;
        if (chunk > cluster_size())
            chunk = cluster_size();
        memcpy(out.data + copied, image->data + cluster_offset(cluster), chunk);
        copied += chunk;
        if (copied >= out.size)
            break;
        cluster = inspect_fat_entry(image, cluster);
        if (cluster >= FAT16_EOC)
            die_path(label, "file cluster chain ended early");
    }
    return out;
}

static int manifest_get_value(const Blob* manifest, const char* key, char* out, size_t out_size)
{
    const char* data = (const char*)manifest->data;
    size_t key_len = strlen(key);
    size_t pos = 0;

    while (pos < manifest->size) {
        size_t line_start = pos;
        size_t line_end = 0;
        while (pos < manifest->size && data[pos] != '\n' && data[pos] != '\r')
            pos++;
        line_end = pos;
        while (pos < manifest->size && (data[pos] == '\n' || data[pos] == '\r'))
            pos++;

        if (line_end > line_start + key_len &&
            memcmp(data + line_start, key, key_len) == 0 &&
            data[line_start + key_len] == '=') {
            size_t value_len = line_end - line_start - key_len - 1;
            if (value_len + 1 > out_size)
                die("Pi proof manifest value is too long");
            memcpy(out, data + line_start + key_len + 1, value_len);
            out[value_len] = '\0';
            return 1;
        }
    }

    return 0;
}

static unsigned long long manifest_require_u64(const Blob* manifest, const char* key)
{
    char value[64];
    char* end = NULL;
    unsigned long long parsed = 0;

    if (!manifest_get_value(manifest, key, value, sizeof(value)))
        die("Pi proof manifest is missing a required size field");
    errno = 0;
    parsed = strtoull(value, &end, 10);
    if (errno || !end || *end)
        die("Pi proof manifest size field is not decimal");
    return parsed;
}

static size_t manifest_require_count(const Blob* manifest, const char* key)
{
    unsigned long long value = manifest_require_u64(manifest, key);
    if (value > 256)
        die("Pi proof manifest count is too large");
    return (size_t)value;
}

static void manifest_require_value(const Blob* manifest, const char* key, const char* expected)
{
    char value[160];

    if (!manifest_get_value(manifest, key, value, sizeof(value)))
        die("Pi proof manifest is missing a required field");
    if (strcmp(value, expected) != 0)
        die("Pi proof manifest field does not match the boot artifact");
}

static void manifest_require_file_size(const Blob* manifest, const char* key, uint32_t actual_size)
{
    unsigned long long expected_size = manifest_require_u64(manifest, key);
    if (expected_size != actual_size)
        die("Pi proof manifest file size does not match the FAT image");
}

static void manifest_require_u32_value(const Blob* manifest, const char* key, uint32_t expected)
{
    unsigned long long actual = manifest_require_u64(manifest, key);
    if (actual != expected)
        die("Pi proof manifest numeric field does not match the boot artifact");
}

static void manifest_require_file_cluster(const Blob* manifest, const char* key, uint32_t actual_cluster)
{
    unsigned long long expected_cluster = manifest_require_u64(manifest, key);
    if (expected_cluster != actual_cluster)
        die("Pi proof manifest file cluster does not match the FAT image");
}

static void manifest_require_same_u64(const Blob* manifest, const char* lhs_key, const char* rhs_key)
{
    unsigned long long lhs = manifest_require_u64(manifest, lhs_key);
    unsigned long long rhs = manifest_require_u64(manifest, rhs_key);
    if (lhs != rhs)
        die("Pi proof manifest numeric fields disagree");
}

static void inspect_manifest_print_field(const Blob* manifest, const char* key)
{
    char value[160];

    if (!manifest_get_value(manifest, key, value, sizeof(value)))
        die("Pi proof manifest is missing a command-visible field");
    printf("%s=%s\n", key, value);
}

static const char* manifest_asset_kind_for_path(const char* path)
{
    if (strcmp(path, PROOF_QUAKE_PAK_PATH) == 0)
        return "quake-pak0";
    return "generic-external-asset";
}

static const char* manifest_asset_repo_state_for_path(const char* path)
{
    if (strcmp(path, PROOF_QUAKE_PAK_PATH) == 0)
        return "outside-repo";
    return "unchecked";
}

static void inspect_manifest_require_file(
    const Blob* image,
    const Blob* manifest,
    const char* path,
    const char* size_key,
    const char* cluster_key,
    size_t* checked_files)
{
    FatFileInfo info;

    if (!inspect_find_path(image, path, &info))
        die_path(path, "Pi proof manifest names a file missing from the FAT image");
    if (info.attr & FAT_ATTR_DIRECTORY)
        die_path(path, "Pi proof manifest expected a file, found a directory");
    if (info.size == 0)
        die_path(path, "Pi proof manifest file is empty");
    if (size_key)
        manifest_require_file_size(manifest, size_key, info.size);
    if (cluster_key)
        manifest_require_file_cluster(manifest, cluster_key, info.first_cluster);

    printf("manifest_file=%s state=present size=%u cluster=%u\n", path, info.size, info.first_cluster);
    (*checked_files)++;
}

static void text_manifest_require_value(const Blob* text, const char* path, const char* key, const char* expected)
{
    char value[160];

    if (!manifest_get_value(text, key, value, sizeof(value))) {
        fprintf(stderr, "make_wad_image: %s: missing app manifest field %s\n", path, key);
        exit(1);
    }
    if (strcmp(value, expected) != 0) {
        fprintf(stderr, "make_wad_image: %s: app manifest field %s does not match image layout\n", path, key);
        exit(1);
    }
}

static Blob inspect_read_text_manifest(const Blob* image, const char* path, FatFileInfo* info)
{
    if (!inspect_find_path(image, path, info))
        die_path(path, "Pi app layout names a file missing from the FAT image");
    if (info->attr & FAT_ATTR_DIRECTORY)
        die_path(path, "Pi app layout expected a file, found a directory");
    if (info->size == 0)
        die_path(path, "Pi app layout file is empty");
    return inspect_read_file_blob(image, info, path);
}

static void inspect_pi4_app_index(const Blob* image)
{
    FatFileInfo info;
    Blob index = inspect_read_text_manifest(image, PI4_APP_INDEX_PATH, &info);

    text_manifest_require_value(&index, PI4_APP_INDEX_PATH, "schema", "vibe-os-app-index-v1");
    text_manifest_require_value(&index, PI4_APP_INDEX_PATH, "app_count", "2");
    text_manifest_require_value(&index, PI4_APP_INDEX_PATH, "app.0.id", "doom");
    text_manifest_require_value(&index, PI4_APP_INDEX_PATH, "app.0.manifest", PI4_DOOM_APP_MANIFEST_PATH);
    text_manifest_require_value(&index, PI4_APP_INDEX_PATH, "app.1.id", "quake");
    text_manifest_require_value(&index, PI4_APP_INDEX_PATH, "app.1.manifest", PI4_QUAKE_APP_MANIFEST_PATH);
    printf(
        "app_index_manifest=%s state=present schema=vibe-os-app-index-v1 app_count=2 discovery=%s\n",
        PI4_APP_INDEX_PATH,
        PI4_APP_DISCOVERY_MODEL);
    free(index.data);
}

static void inspect_pi4_app_manifest(
    const Blob* image,
    const char* manifest_path,
    const char* id,
    const char* name,
    const char* exec_path,
    const char* resource_path,
    const char* icon,
    int require_resource)
{
    FatFileInfo manifest_info;
    FatFileInfo exec_info;
    FatFileInfo resource_info;
    Blob app = inspect_read_text_manifest(image, manifest_path, &manifest_info);
    int resource_present;

    text_manifest_require_value(&app, manifest_path, "schema", "vibe-os-app-v1");
    text_manifest_require_value(&app, manifest_path, "id", id);
    text_manifest_require_value(&app, manifest_path, "name", name);
    text_manifest_require_value(&app, manifest_path, "exec", exec_path);
    text_manifest_require_value(&app, manifest_path, "asset", resource_path);
    text_manifest_require_value(&app, manifest_path, "icon", icon);
    text_manifest_require_value(&app, manifest_path, "input", PI4_APP_INPUT);

    if (!inspect_find_path(image, exec_path, &exec_info))
        die_path(exec_path, "Pi app manifest exec target is missing from the FAT image");
    if ((exec_info.attr & FAT_ATTR_DIRECTORY) || exec_info.size == 0)
        die_path(exec_path, "Pi app manifest exec target must be a nonempty file");

    resource_present = inspect_find_path(image, resource_path, &resource_info);
    if (resource_present && ((resource_info.attr & FAT_ATTR_DIRECTORY) || resource_info.size == 0))
        die_path(resource_path, "Pi app manifest resource must be a nonempty file");
    if (!resource_present && require_resource)
        die_path(resource_path, "real Pi app layout requires the manifest resource file");

    printf(
        "app_manifest=%s state=present id=%s exec=%s icon=%s resource=%s input=%s\n",
        manifest_path,
        id,
        exec_path,
        icon,
        resource_path,
        PI4_APP_INPUT);
    printf(
        "app_exec=%s state=present model=%s app=%s size=%u cluster=%u\n",
        exec_path,
        PI4_APP_EXEC_MODEL,
        id,
        exec_info.size,
        exec_info.first_cluster);
    printf("app_icon=%s state=manifest app=%s\n", icon, id);
    if (resource_present) {
        printf(
            "app_resource=%s state=present app=%s source=manifest size=%u cluster=%u\n",
            resource_path,
            id,
            resource_info.size,
            resource_info.first_cluster);
    } else {
        printf("app_resource=%s state=absent app=%s source=manifest\n", resource_path, id);
    }
    free(app.data);
}

static int inspect_manifest_require_indexed_file(
    const Blob* image,
    const Blob* manifest,
    const char* prefix,
    size_t index,
    size_t* checked_files)
{
    char file_key[64];
    char size_key[64];
    char kind_key[64];
    char source_key[64];
    char repo_state_key[64];
    char evidence_key[64];
    char hardware_proof_key[64];
    char path[160];
    int is_quake_pak = 0;
    int written = snprintf(file_key, sizeof(file_key), "%s.%zu.file", prefix, index);
    if (written < 0 || (size_t)written >= sizeof(file_key))
        die("Pi proof manifest key is too long");
    written = snprintf(size_key, sizeof(size_key), "%s.%zu.size", prefix, index);
    if (written < 0 || (size_t)written >= sizeof(size_key))
        die("Pi proof manifest key is too long");
    if (!manifest_get_value(manifest, file_key, path, sizeof(path)))
        die("Pi proof manifest is missing an indexed file");
    written = snprintf(kind_key, sizeof(kind_key), "%s.%zu.kind", prefix, index);
    if (written < 0 || (size_t)written >= sizeof(kind_key))
        die("Pi proof manifest key is too long");
    written = snprintf(source_key, sizeof(source_key), "%s.%zu.source", prefix, index);
    if (written < 0 || (size_t)written >= sizeof(source_key))
        die("Pi proof manifest key is too long");
    written = snprintf(repo_state_key, sizeof(repo_state_key), "%s.%zu.repo_state", prefix, index);
    if (written < 0 || (size_t)written >= sizeof(repo_state_key))
        die("Pi proof manifest key is too long");
    written = snprintf(evidence_key, sizeof(evidence_key), "%s.%zu.evidence", prefix, index);
    if (written < 0 || (size_t)written >= sizeof(evidence_key))
        die("Pi proof manifest key is too long");
    written = snprintf(hardware_proof_key, sizeof(hardware_proof_key), "%s.%zu.hardware_proof", prefix, index);
    if (written < 0 || (size_t)written >= sizeof(hardware_proof_key))
        die("Pi proof manifest key is too long");

    manifest_require_value(manifest, kind_key, manifest_asset_kind_for_path(path));
    manifest_require_value(manifest, source_key, "external-host-input");
    manifest_require_value(manifest, repo_state_key, manifest_asset_repo_state_for_path(path));
    manifest_require_value(manifest, evidence_key, "packaged-file-only");
    manifest_require_value(manifest, hardware_proof_key, "unclaimed");
    inspect_manifest_require_file(image, manifest, path, size_key, NULL, checked_files);
    is_quake_pak = strcmp(path, PROOF_QUAKE_PAK_PATH) == 0;
    inspect_manifest_print_field(manifest, file_key);
    inspect_manifest_print_field(manifest, kind_key);
    inspect_manifest_print_field(manifest, source_key);
    inspect_manifest_print_field(manifest, repo_state_key);
    inspect_manifest_print_field(manifest, evidence_key);
    inspect_manifest_print_field(manifest, hardware_proof_key);
    inspect_manifest_print_field(manifest, size_key);
    return is_quake_pak;
}

static void inspect_manifest_require_indexed_sized_file(
    const Blob* image,
    const Blob* manifest,
    const char* prefix,
    size_t index,
    size_t* checked_files)
{
    char file_key[64];
    char size_key[64];
    char path[128];
    int written = snprintf(file_key, sizeof(file_key), "%s.%zu.file", prefix, index);
    if (written < 0 || (size_t)written >= sizeof(file_key))
        die("Pi proof manifest key is too long");
    written = snprintf(size_key, sizeof(size_key), "%s.%zu.size", prefix, index);
    if (written < 0 || (size_t)written >= sizeof(size_key))
        die("Pi proof manifest key is too long");
    if (!manifest_get_value(manifest, file_key, path, sizeof(path)))
        die("Pi proof manifest is missing an indexed file");

    inspect_manifest_require_file(image, manifest, path, size_key, NULL, checked_files);
    inspect_manifest_print_field(manifest, file_key);
    inspect_manifest_print_field(manifest, size_key);
}

static void inspect_manifest_require_root_elf_slot(
    const Blob* manifest,
    const char* slot,
    const char* expected_file,
    const char* expected_state)
{
    char key[64];
    int written = snprintf(key, sizeof(key), "root_elf_slot.%s.file", slot);
    if (written < 0 || (size_t)written >= sizeof(key))
        die("Pi proof manifest key is too long");
    manifest_require_value(manifest, key, expected_file);
    inspect_manifest_print_field(manifest, key);

    written = snprintf(key, sizeof(key), "root_elf_slot.%s.state", slot);
    if (written < 0 || (size_t)written >= sizeof(key))
        die("Pi proof manifest key is too long");
    manifest_require_value(manifest, key, expected_state);
    inspect_manifest_print_field(manifest, key);
}

static void inspect_manifest_check_optional_slot(
    const Blob* image,
    const Blob* manifest,
    size_t index,
    const char* expected_kind,
    const char* expected_file,
    const char* expected_root_slot,
    const char* expected_app_exec,
    size_t* checked_files)
{
    char key[64];
    char state[32];
    int present = 0;
    int written = snprintf(key, sizeof(key), "payload_slot.%zu.kind", index);
    if (written < 0 || (size_t)written >= sizeof(key))
        die("Pi proof manifest key is too long");
    manifest_require_value(manifest, key, expected_kind);
    inspect_manifest_print_field(manifest, key);
    written = snprintf(key, sizeof(key), "payload_slot.%zu.file", index);
    if (written < 0 || (size_t)written >= sizeof(key))
        die("Pi proof manifest key is too long");
    manifest_require_value(manifest, key, expected_file);
    inspect_manifest_print_field(manifest, key);
    written = snprintf(key, sizeof(key), "payload_slot.%zu.root_elf_slot", index);
    if (written < 0 || (size_t)written >= sizeof(key))
        die("Pi proof manifest key is too long");
    manifest_require_value(manifest, key, expected_root_slot);
    inspect_manifest_print_field(manifest, key);
    written = snprintf(key, sizeof(key), "payload_slot.%zu.state", index);
    if (written < 0 || (size_t)written >= sizeof(key))
        die("Pi proof manifest key is too long");
    if (!manifest_get_value(manifest, key, state, sizeof(state)))
        die("Pi proof manifest is missing payload slot state");
    inspect_manifest_print_field(manifest, key);

    if (strcmp(state, "present") == 0) {
        present = 1;
    } else if (strcmp(state, "absent") != 0) {
        die("Pi proof manifest payload state must be present or absent");
    }
    inspect_manifest_require_root_elf_slot(manifest, expected_root_slot, expected_file, state);

    written = snprintf(key, sizeof(key), "payload_slot.%zu.source", index);
    if (written < 0 || (size_t)written >= sizeof(key))
        die("Pi proof manifest key is too long");
    manifest_require_value(manifest, key, present ? "root-elf-input" : "absent");
    inspect_manifest_print_field(manifest, key);
    written = snprintf(key, sizeof(key), "payload_slot.%zu.repo_state", index);
    if (written < 0 || (size_t)written >= sizeof(key))
        die("Pi proof manifest key is too long");
    manifest_require_value(manifest, key, present ? "unchecked" : "absent");
    inspect_manifest_print_field(manifest, key);
    written = snprintf(key, sizeof(key), "payload_slot.%zu.evidence", index);
    if (written < 0 || (size_t)written >= sizeof(key))
        die("Pi proof manifest key is too long");
    manifest_require_value(manifest, key, present ? "packaged-file-only" : "absent");
    inspect_manifest_print_field(manifest, key);
    written = snprintf(key, sizeof(key), "payload_slot.%zu.hardware_proof", index);
    if (written < 0 || (size_t)written >= sizeof(key))
        die("Pi proof manifest key is too long");
    manifest_require_value(manifest, key, "unclaimed");
    inspect_manifest_print_field(manifest, key);
    written = snprintf(key, sizeof(key), "payload_slot.%zu.launch_proof", index);
    if (written < 0 || (size_t)written >= sizeof(key))
        die("Pi proof manifest key is too long");
    manifest_require_value(manifest, key, "unclaimed");
    inspect_manifest_print_field(manifest, key);

    written = snprintf(key, sizeof(key), "payload_slot.%zu.compatibility", index);
    if (written < 0 || (size_t)written >= sizeof(key))
        die("Pi proof manifest key is too long");
    manifest_require_value(manifest, key, "legacy-root-payload");
    inspect_manifest_print_field(manifest, key);
    written = snprintf(key, sizeof(key), "payload_slot.%zu.app_exec", index);
    if (written < 0 || (size_t)written >= sizeof(key))
        die("Pi proof manifest key is too long");
    manifest_require_value(manifest, key, expected_app_exec);
    inspect_manifest_print_field(manifest, key);

    if (present) {
        char size_key[64];
        char cluster_key[64];
        char root_size_key[64];
        char root_cluster_key[64];
        written = snprintf(size_key, sizeof(size_key), "payload_slot.%zu.size", index);
        if (written < 0 || (size_t)written >= sizeof(size_key))
            die("Pi proof manifest key is too long");
        written = snprintf(cluster_key, sizeof(cluster_key), "payload_slot.%zu.cluster", index);
        if (written < 0 || (size_t)written >= sizeof(cluster_key))
            die("Pi proof manifest key is too long");
        written = snprintf(root_size_key, sizeof(root_size_key), "root_elf_slot.%s.size", expected_root_slot);
        if (written < 0 || (size_t)written >= sizeof(root_size_key))
            die("Pi proof manifest key is too long");
        written = snprintf(root_cluster_key, sizeof(root_cluster_key), "root_elf_slot.%s.cluster", expected_root_slot);
        if (written < 0 || (size_t)written >= sizeof(root_cluster_key))
            die("Pi proof manifest key is too long");
        inspect_manifest_require_file(image, manifest, expected_file, size_key, cluster_key, checked_files);
        manifest_require_same_u64(manifest, root_cluster_key, cluster_key);
        manifest_require_same_u64(manifest, root_size_key, size_key);
        inspect_manifest_print_field(manifest, root_cluster_key);
        inspect_manifest_print_field(manifest, root_size_key);
        inspect_manifest_print_field(manifest, cluster_key);
        inspect_manifest_print_field(manifest, size_key);
    } else {
        FatFileInfo info;
        if (inspect_find_path(image, expected_file, &info))
            die_path(expected_file, "Pi proof manifest marks payload absent but file exists");
        printf("manifest_file=%s state=absent\n", expected_file);
    }
}

static void inspect_pi4_manifest(const Blob* image, int require_real_assets)
{
    FatFileInfo manifest_info;
    size_t checked_files = 0;
    int indexed_quake_pak = 0;
    int checked_quake_pak = 0;
    char primary_source[32];
    char primary_repo_state[32];
    char quake_state[32];

    if (!inspect_find_path(image, PROOF_MANIFEST_PATH, &manifest_info)) {
        if (require_real_assets)
            die("Pi proof manifest is required for real asset proof");
        return;
    }

    Blob manifest = inspect_read_file_blob(image, &manifest_info, PROOF_MANIFEST_PATH);

    manifest_require_value(&manifest, "schema", "vibe-os-pi4-image-manifest-v1");
    manifest_require_value(&manifest, "layout", "vibe-os-pi4-fat16-v1");
    manifest_require_u32_value(&manifest, "root_lba", root_lba());
    manifest_require_u32_value(&manifest, "data_lba", data_lba());
    manifest_require_u32_value(&manifest, "root_entry_count", ROOT_ENTRIES);
    manifest_require_value(&manifest, "manifest_path", PROOF_MANIFEST_PATH);
    printf("manifest_path=%s state=present size=%u\n", PROOF_MANIFEST_PATH, manifest_info.size);

    manifest_require_value(&manifest, "kernel_file", "KERNEL8.IMG");
    inspect_manifest_print_field(&manifest, "kernel_file");
    inspect_manifest_require_file(image, &manifest, "KERNEL8.IMG", "kernel_size", NULL, &checked_files);
    manifest_require_value(&manifest, "config_file", "CONFIG.TXT");
    inspect_manifest_print_field(&manifest, "config_file");
    inspect_manifest_require_file(image, &manifest, "CONFIG.TXT", "config_size", NULL, &checked_files);

    manifest_require_value(&manifest, "root_elf_slot_count", "4");
    inspect_manifest_print_field(&manifest, "root_elf_slot_count");
    manifest_require_value(&manifest, "root_elf_slot.0.file", "INIT.ELF");
    inspect_manifest_print_field(&manifest, "root_elf_slot.0.file");
    manifest_require_value(&manifest, "root_elf_slot.0.state", "present");
    inspect_manifest_print_field(&manifest, "root_elf_slot.0.state");
    inspect_manifest_require_file(image, &manifest, "INIT.ELF", "root_elf_slot.0.size", "root_elf_slot.0.cluster", &checked_files);
    inspect_manifest_print_field(&manifest, "root_elf_slot.0.cluster");
    inspect_manifest_print_field(&manifest, "root_elf_slot.0.size");
    manifest_require_value(&manifest, "root_elf_slot.1.file", "ABIPROBE.ELF");
    inspect_manifest_print_field(&manifest, "root_elf_slot.1.file");
    manifest_require_value(&manifest, "root_elf_slot.1.state", "present");
    inspect_manifest_print_field(&manifest, "root_elf_slot.1.state");
    inspect_manifest_require_file(image, &manifest, "ABIPROBE.ELF", "root_elf_slot.1.size", "root_elf_slot.1.cluster", &checked_files);
    inspect_manifest_print_field(&manifest, "root_elf_slot.1.cluster");
    inspect_manifest_print_field(&manifest, "root_elf_slot.1.size");

    manifest_require_value(&manifest, "payload_slot_count", "2");
    inspect_manifest_print_field(&manifest, "payload_slot_count");
    manifest_require_value(&manifest, "legacy_root_payloads", PI4_LEGACY_ROOT_PAYLOADS);
    inspect_manifest_print_field(&manifest, "legacy_root_payloads");
    inspect_manifest_check_optional_slot(
        image, &manifest, 0, "doom", "PAYLOAD0.ELF", "2", PI4_DOOM_APP_EXEC_PATH, &checked_files);
    inspect_manifest_check_optional_slot(
        image, &manifest, 1, "quake", "PAYLOAD1.ELF", "3", PI4_QUAKE_APP_EXEC_PATH, &checked_files);

    manifest_require_value(&manifest, "app_model_schema", "vibe-os-pi4-app-install-v1");
    inspect_manifest_print_field(&manifest, "app_model_schema");
    manifest_require_value(&manifest, "app_layout", PI4_APP_LAYOUT);
    inspect_manifest_print_field(&manifest, "app_layout");
    manifest_require_value(&manifest, "app_discovery_model", PI4_APP_DISCOVERY_MODEL);
    inspect_manifest_print_field(&manifest, "app_discovery_model");
    manifest_require_value(&manifest, "app_launch_model", "generic-vfs-path-exec");
    inspect_manifest_print_field(&manifest, "app_launch_model");
    manifest_require_value(&manifest, "app_exec_model", PI4_APP_EXEC_MODEL);
    inspect_manifest_print_field(&manifest, "app_exec_model");
    manifest_require_value(&manifest, "system_init", PI4_SYSTEM_INIT_PATH);
    inspect_manifest_print_field(&manifest, "system_init");
    inspect_manifest_require_file(image, &manifest, PI4_SYSTEM_INIT_PATH, "system_init_size", NULL, &checked_files);
    manifest_require_value(&manifest, "system_abiprobe", PI4_SYSTEM_ABIPROBE_PATH);
    inspect_manifest_print_field(&manifest, "system_abiprobe");
    inspect_manifest_require_file(image, &manifest, PI4_SYSTEM_ABIPROBE_PATH, "system_abiprobe_size", NULL, &checked_files);
    manifest_require_value(&manifest, "app_index", PI4_APP_INDEX_PATH);
    inspect_manifest_print_field(&manifest, "app_index");
    inspect_manifest_require_file(image, &manifest, PI4_APP_INDEX_PATH, "app_index_size", NULL, &checked_files);
    inspect_pi4_app_index(image);
    manifest_require_value(&manifest, "app_count", "2");
    inspect_manifest_print_field(&manifest, "app_count");
    manifest_require_value(&manifest, "app.0.id", "doom");
    inspect_manifest_print_field(&manifest, "app.0.id");
    manifest_require_value(&manifest, "app.0.name", PI4_DOOM_APP_NAME);
    inspect_manifest_print_field(&manifest, "app.0.name");
    manifest_require_value(&manifest, "app.0.manifest", PI4_DOOM_APP_MANIFEST_PATH);
    inspect_manifest_print_field(&manifest, "app.0.manifest");
    inspect_manifest_require_file(image, &manifest, PI4_DOOM_APP_MANIFEST_PATH, "app.0.manifest_size", NULL, &checked_files);
    manifest_require_value(&manifest, "app.0.exec", PI4_DOOM_APP_EXEC_PATH);
    inspect_manifest_print_field(&manifest, "app.0.exec");
    inspect_manifest_require_file(image, &manifest, PI4_DOOM_APP_EXEC_PATH, "app.0.exec_size", NULL, &checked_files);
    manifest_require_value(&manifest, "app.0.launch", "generic-path-exec");
    inspect_manifest_print_field(&manifest, "app.0.launch");
    manifest_require_value(&manifest, "app.0.exec_model", PI4_APP_EXEC_MODEL);
    inspect_manifest_print_field(&manifest, "app.0.exec_model");
    manifest_require_value(&manifest, "app.0.resource", PI4_DOOM_APP_RESOURCE_PATH);
    inspect_manifest_print_field(&manifest, "app.0.resource");
    manifest_require_value(&manifest, "app.0.icon", PI4_DOOM_APP_ICON);
    inspect_manifest_print_field(&manifest, "app.0.icon");
    inspect_pi4_app_manifest(
        image,
        PI4_DOOM_APP_MANIFEST_PATH,
        "doom",
        PI4_DOOM_APP_NAME,
        PI4_DOOM_APP_EXEC_PATH,
        PI4_DOOM_APP_RESOURCE_PATH,
        PI4_DOOM_APP_ICON,
        1);
    manifest_require_value(&manifest, "app.1.id", "quake");
    inspect_manifest_print_field(&manifest, "app.1.id");
    manifest_require_value(&manifest, "app.1.name", PI4_QUAKE_APP_NAME);
    inspect_manifest_print_field(&manifest, "app.1.name");
    manifest_require_value(&manifest, "app.1.manifest", PI4_QUAKE_APP_MANIFEST_PATH);
    inspect_manifest_print_field(&manifest, "app.1.manifest");
    inspect_manifest_require_file(image, &manifest, PI4_QUAKE_APP_MANIFEST_PATH, "app.1.manifest_size", NULL, &checked_files);
    manifest_require_value(&manifest, "app.1.exec", PI4_QUAKE_APP_EXEC_PATH);
    inspect_manifest_print_field(&manifest, "app.1.exec");
    inspect_manifest_require_file(image, &manifest, PI4_QUAKE_APP_EXEC_PATH, "app.1.exec_size", NULL, &checked_files);
    manifest_require_value(&manifest, "app.1.launch", "generic-path-exec");
    inspect_manifest_print_field(&manifest, "app.1.launch");
    manifest_require_value(&manifest, "app.1.exec_model", PI4_APP_EXEC_MODEL);
    inspect_manifest_print_field(&manifest, "app.1.exec_model");
    manifest_require_value(&manifest, "app.1.resource", PI4_QUAKE_APP_RESOURCE_PATH);
    inspect_manifest_print_field(&manifest, "app.1.resource");
    manifest_require_value(&manifest, "app.1.icon", PI4_QUAKE_APP_ICON);
    inspect_manifest_print_field(&manifest, "app.1.icon");
    inspect_pi4_app_manifest(
        image,
        PI4_QUAKE_APP_MANIFEST_PATH,
        "quake",
        PI4_QUAKE_APP_NAME,
        PI4_QUAKE_APP_EXEC_PATH,
        PI4_QUAKE_APP_RESOURCE_PATH,
        PI4_QUAKE_APP_ICON,
        require_real_assets);

    size_t root_file_count = manifest_require_count(&manifest, "root_file_count");
    inspect_manifest_print_field(&manifest, "root_file_count");
    for (size_t i = 0; i < root_file_count; i++)
        inspect_manifest_require_indexed_sized_file(image, &manifest, "root_file", i, &checked_files);

    size_t root_elf_count = manifest_require_count(&manifest, "root_elf_count");
    inspect_manifest_print_field(&manifest, "root_elf_count");
    for (size_t i = 0; i < root_elf_count; i++)
        inspect_manifest_require_indexed_sized_file(image, &manifest, "root_elf", i, &checked_files);

    manifest_require_value(&manifest, "primary_asset_file", "DOOM1.WAD");
    manifest_require_value(&manifest, "primary_asset_kind", "doom-wad");
    manifest_require_value(&manifest, "primary_asset_state", "present");
    if (!manifest_get_value(&manifest, "primary_asset_source", primary_source, sizeof(primary_source)))
        die("Pi proof manifest is missing primary WAD source");
    if (!manifest_get_value(&manifest, "primary_asset_repo_state", primary_repo_state, sizeof(primary_repo_state)))
        die("Pi proof manifest is missing primary WAD repo state");
    if (strcmp(primary_source, "external") == 0) {
        if (strcmp(primary_repo_state, "outside-repo") != 0)
            die("Pi proof manifest external WAD must be marked outside-repo");
    } else if (strcmp(primary_source, "generated-fixture") == 0) {
        if (strcmp(primary_repo_state, "generated-by-builder") != 0)
            die("Pi proof manifest generated WAD must be marked generated-by-builder");
    } else {
        die("Pi proof manifest primary WAD source must be external or generated-fixture");
    }
    manifest_require_value(&manifest, "primary_asset_evidence", "packaged-file-only");
    manifest_require_value(&manifest, "primary_asset_hardware_proof", "unclaimed");
    inspect_manifest_require_file(image, &manifest, "DOOM1.WAD", "primary_asset_size", NULL, &checked_files);
    inspect_manifest_print_field(&manifest, "primary_asset_file");
    inspect_manifest_print_field(&manifest, "primary_asset_kind");
    inspect_manifest_print_field(&manifest, "primary_asset_state");
    inspect_manifest_print_field(&manifest, "primary_asset_source");
    inspect_manifest_print_field(&manifest, "primary_asset_repo_state");
    inspect_manifest_print_field(&manifest, "primary_asset_evidence");
    inspect_manifest_print_field(&manifest, "primary_asset_hardware_proof");
    inspect_manifest_print_field(&manifest, "primary_asset_size");
    printf(
        "manifest_asset=DOOM1.WAD kind=doom-wad source=%s repo_state=%s evidence=packaged-file-only hardware_proof=unclaimed state=present\n",
        primary_source,
        primary_repo_state);

    manifest_require_value(&manifest, "default_asset_count", "3");
    manifest_require_value(&manifest, "default_asset.0.file", DEFAULT_PI4_ASSET_README_PATH);
    inspect_manifest_require_file(image, &manifest, DEFAULT_PI4_ASSET_README_PATH, "default_asset.0.size", NULL, &checked_files);
    manifest_require_value(&manifest, "default_asset.1.file", DEFAULT_PI4_ASSET_MAP_PATH);
    inspect_manifest_require_file(image, &manifest, DEFAULT_PI4_ASSET_MAP_PATH, "default_asset.1.size", NULL, &checked_files);
    manifest_require_value(&manifest, "default_asset.2.file", DEFAULT_PI4_ASSET_PALETTE_PATH);
    inspect_manifest_require_file(image, &manifest, DEFAULT_PI4_ASSET_PALETTE_PATH, "default_asset.2.size", NULL, &checked_files);

    size_t asset_count = manifest_require_count(&manifest, "asset_count");
    inspect_manifest_print_field(&manifest, "asset_count");
    for (size_t i = 0; i < asset_count; i++) {
        if (inspect_manifest_require_indexed_file(image, &manifest, "asset", i, &checked_files))
            indexed_quake_pak = 1;
    }

    manifest_require_value(&manifest, "quake_pak_file", PROOF_QUAKE_PAK_PATH);
    manifest_require_value(&manifest, "quake_pak_kind", "quake-pak");
    if (!manifest_get_value(&manifest, "quake_pak_state", quake_state, sizeof(quake_state)))
        die("Pi proof manifest is missing Quake PAK state");
    if (strcmp(quake_state, "absent") == 0) {
        manifest_require_value(&manifest, "quake_pak_source", "absent");
        manifest_require_value(&manifest, "quake_pak_repo_state", "absent");
        manifest_require_value(&manifest, "quake_pak_evidence", "absent");
        manifest_require_value(&manifest, "quake_pak_hardware_proof", "unclaimed");
        inspect_manifest_print_field(&manifest, "quake_pak_file");
        inspect_manifest_print_field(&manifest, "quake_pak_kind");
        inspect_manifest_print_field(&manifest, "quake_pak_state");
        inspect_manifest_print_field(&manifest, "quake_pak_source");
        inspect_manifest_print_field(&manifest, "quake_pak_repo_state");
        inspect_manifest_print_field(&manifest, "quake_pak_evidence");
        inspect_manifest_print_field(&manifest, "quake_pak_hardware_proof");
        printf(
            "manifest_asset=%s kind=quake-pak source=absent repo_state=absent evidence=absent hardware_proof=unclaimed state=absent\n",
            PROOF_QUAKE_PAK_PATH);
    } else if (strcmp(quake_state, "present") == 0) {
        manifest_require_value(&manifest, "quake_pak_source", "external");
        manifest_require_value(&manifest, "quake_pak_repo_state", "outside-repo");
        manifest_require_value(&manifest, "quake_pak_evidence", "packaged-file-only");
        manifest_require_value(&manifest, "quake_pak_hardware_proof", "unclaimed");
        inspect_manifest_require_file(image, &manifest, PROOF_QUAKE_PAK_PATH, "quake_pak_size", NULL, &checked_files);
        checked_quake_pak = 1;
        inspect_manifest_print_field(&manifest, "quake_pak_file");
        inspect_manifest_print_field(&manifest, "quake_pak_kind");
        inspect_manifest_print_field(&manifest, "quake_pak_state");
        inspect_manifest_print_field(&manifest, "quake_pak_source");
        inspect_manifest_print_field(&manifest, "quake_pak_repo_state");
        inspect_manifest_print_field(&manifest, "quake_pak_evidence");
        inspect_manifest_print_field(&manifest, "quake_pak_hardware_proof");
        inspect_manifest_print_field(&manifest, "quake_pak_size");
        printf(
            "manifest_asset=%s kind=quake-pak source=external repo_state=outside-repo evidence=packaged-file-only hardware_proof=unclaimed state=present\n",
            PROOF_QUAKE_PAK_PATH);
    } else {
        die("Pi proof manifest Quake PAK state must be present or absent");
    }

    manifest_require_value(&manifest, "asset_slot_count", "2");
    inspect_manifest_print_field(&manifest, "asset_slot_count");
    manifest_require_value(&manifest, "asset_slot.0.kind", "doom-wad");
    manifest_require_value(&manifest, "asset_slot.0.file", "DOOM1.WAD");
    manifest_require_value(&manifest, "asset_slot.0.state", "present");
    manifest_require_value(&manifest, "asset_slot.0.source", primary_source);
    manifest_require_value(&manifest, "asset_slot.0.repo_state", primary_repo_state);
    manifest_require_value(&manifest, "asset_slot.0.evidence", "packaged-file-only");
    manifest_require_value(&manifest, "asset_slot.0.hardware_proof", "unclaimed");
    manifest_require_same_u64(&manifest, "asset_slot.0.size", "primary_asset_size");
    inspect_manifest_print_field(&manifest, "asset_slot.0.kind");
    inspect_manifest_print_field(&manifest, "asset_slot.0.file");
    inspect_manifest_print_field(&manifest, "asset_slot.0.state");
    inspect_manifest_print_field(&manifest, "asset_slot.0.source");
    inspect_manifest_print_field(&manifest, "asset_slot.0.repo_state");
    inspect_manifest_print_field(&manifest, "asset_slot.0.evidence");
    inspect_manifest_print_field(&manifest, "asset_slot.0.hardware_proof");
    inspect_manifest_print_field(&manifest, "asset_slot.0.size");

    manifest_require_value(&manifest, "asset_slot.1.kind", "quake-pak");
    manifest_require_value(&manifest, "asset_slot.1.file", PROOF_QUAKE_PAK_PATH);
    manifest_require_value(&manifest, "asset_slot.1.state", quake_state);
    manifest_require_value(
        &manifest,
        "asset_slot.1.source",
        strcmp(quake_state, "present") == 0 ? "external" : "absent");
    manifest_require_value(
        &manifest,
        "asset_slot.1.repo_state",
        strcmp(quake_state, "present") == 0 ? "outside-repo" : "absent");
    manifest_require_value(
        &manifest,
        "asset_slot.1.evidence",
        strcmp(quake_state, "present") == 0 ? "packaged-file-only" : "absent");
    manifest_require_value(&manifest, "asset_slot.1.hardware_proof", "unclaimed");
    if (strcmp(quake_state, "present") == 0)
        manifest_require_same_u64(&manifest, "asset_slot.1.size", "quake_pak_size");
    inspect_manifest_print_field(&manifest, "asset_slot.1.kind");
    inspect_manifest_print_field(&manifest, "asset_slot.1.file");
    inspect_manifest_print_field(&manifest, "asset_slot.1.state");
    inspect_manifest_print_field(&manifest, "asset_slot.1.source");
    inspect_manifest_print_field(&manifest, "asset_slot.1.repo_state");
    inspect_manifest_print_field(&manifest, "asset_slot.1.evidence");
    inspect_manifest_print_field(&manifest, "asset_slot.1.hardware_proof");
    if (strcmp(quake_state, "present") == 0)
        inspect_manifest_print_field(&manifest, "asset_slot.1.size");

    printf(
        "manifest_asset_handoff=OK primary_asset_state=present primary_asset_source=%s primary_asset_evidence=packaged-file-only primary_asset_hardware_proof=unclaimed quake_pak_state=%s quake_pak_evidence=%s quake_pak_hardware_proof=unclaimed\n",
        primary_source,
        quake_state,
        strcmp(quake_state, "present") == 0 ? "packaged-file-only" : "absent");
    if (require_real_assets) {
        if (strcmp(primary_source, "external") != 0 || strcmp(primary_repo_state, "outside-repo") != 0)
            die("real Pi asset proof requires an external outside-repo Doom WAD");
        if (strcmp(quake_state, "present") != 0)
            die("real Pi asset proof requires an external outside-repo Quake PAK");
        if (!indexed_quake_pak || !checked_quake_pak)
            die("real Pi asset proof requires checked_files to include /ID1/PAK0.PAK");
        printf(
            "real_asset_manifest=OK primary_asset_source=external primary_asset_repo_state=outside-repo quake_pak_source=external quake_pak_repo_state=outside-repo checked_files_include_pak=true\n");
    }
    printf("pi4_manifest=OK checked_files=%zu\n", checked_files);
    free(manifest.data);
}

static void inspect_directory(const Blob* image, const char* prefix, uint32_t first_cluster, int depth)
{
    if (depth <= 0 || first_cluster < 2 || first_cluster > last_data_cluster())
        return;

    const uint8_t* dir = image->data + cluster_offset(first_cluster);
    size_t dir_size = cluster_size();
    for (uint32_t i = 0; (size_t)i * 32 + 32 <= dir_size; i++) {
        const uint8_t* entry = dir + (size_t)i * 32;
        if (entry[0] == 0)
            break;
        if (entry[0] == 0xe5 || entry[0] == '.')
            continue;

        char name[13];
        char path[160];
        format_fat_name(entry, name);
        int written = snprintf(path, sizeof(path), "%s/%s", prefix, name);
        if (written < 0 || (size_t)written >= sizeof(path))
            die("inspect path is too long");

        uint32_t cluster = get_u16(dir, dir_size, (size_t)i * 32 + 26);
        uint32_t size = get_u32(dir, dir_size, (size_t)i * 32 + 28);
        printf(
            "path=%s attr=0x%02X cluster=%u size=%u\n",
            path,
            entry[11],
            cluster,
            size);

        if (entry[11] & FAT_ATTR_DIRECTORY)
            inspect_directory(image, path, cluster, depth - 1);
    }
}

static void inspect_require_file(const Blob* image, const char* path)
{
    FatFileInfo info;

    if (!inspect_find_path(image, path, &info))
        die_path(path, "required FAT file is missing");
    if (info.attr & FAT_ATTR_DIRECTORY)
        die_path(path, "required FAT path is a directory");
    if (info.size == 0)
        die_path(path, "required FAT file is empty");
    if (info.first_cluster < 2 || info.first_cluster > last_data_cluster())
        die_path(path, "required FAT file has invalid first cluster");

    printf("required_file=%s state=present size=%u cluster=%u\n",
           path,
           info.size,
           info.first_cluster);
}

static void inspect_image(
    const char* path,
    int require_real_assets,
    const char* const* required_files,
    size_t required_file_count)
{
    Blob image = read_file(path);
    if (image.size != (size_t)IMAGE_SECTORS * SECTOR_SIZE)
        die_path(path, "unexpected image size");
    if (get_u16(image.data, image.size, 510) != 0xaa55)
        die_path(path, "missing MBR signature");
    uint32_t part_lba = get_u32(image.data, image.size, 446 + 8);
    uint32_t part_sectors = get_u32(image.data, image.size, 446 + 12);
    if (part_lba != PARTITION_START || part_sectors != PARTITION_SECTORS)
        die_path(path, "unexpected partition layout");

    size_t boot = sector_offset(PARTITION_START);
    if (get_u16(image.data, image.size, boot + 510) != 0xaa55)
        die_path(path, "missing FAT boot signature");
    if (get_u16(image.data, image.size, boot + 11) != SECTOR_SIZE)
        die_path(path, "unexpected FAT bytes per sector");
    if (image.data[boot + 13] != SECTORS_PER_CLUSTER)
        die_path(path, "unexpected FAT sectors per cluster");

    printf("schema=vibe-os-c-image-inspect-v1\n");
    printf("image_path=%s\n", path);
    printf("image_size=%zu\n", image.size);
    printf("partition_lba=%u\n", part_lba);
    printf("partition_sectors=%u\n", part_sectors);
    printf("root_lba=%u\n", root_lba());
    printf("data_lba=%u\n", data_lba());
    printf("root_entry_count=%u\n", ROOT_ENTRIES);
    printf("data_clusters=%u\n", data_cluster_count());

    const uint8_t* root = image.data + sector_offset(root_lba());
    for (uint32_t i = 0; i < ROOT_ENTRIES; i++) {
        const uint8_t* entry = root + i * 32;
        if (entry[0] == 0)
            break;
        if (entry[0] == 0xe5)
            continue;
        char name[13];
        format_fat_name(entry, name);
        printf(
            "root[%u]=%s attr=0x%02X cluster=%u size=%u\n",
            i,
            name,
            entry[11],
            get_u16(root, ROOT_ENTRIES * 32, i * 32 + 26),
            get_u32(root, ROOT_ENTRIES * 32, i * 32 + 28));
        if (entry[11] & FAT_ATTR_DIRECTORY)
            inspect_directory(&image, name, get_u16(root, ROOT_ENTRIES * 32, i * 32 + 26), 3);
    }
    for (size_t i = 0; i < required_file_count; i++)
        inspect_require_file(&image, required_files[i]);
    inspect_pi4_manifest(&image, require_real_assets);
    free(image.data);
}

static void validate_image_layout(const Blob* image, const char* path)
{
    if (image->size != (size_t)IMAGE_SECTORS * SECTOR_SIZE)
        die_path(path, "unexpected image size");
    if (get_u16(image->data, image->size, 510) != 0xaa55)
        die_path(path, "missing MBR signature");
    uint32_t part_lba = get_u32(image->data, image->size, 446 + 8);
    uint32_t part_sectors = get_u32(image->data, image->size, 446 + 12);
    if (part_lba != PARTITION_START || part_sectors != PARTITION_SECTORS)
        die_path(path, "unexpected partition layout");

    size_t boot = sector_offset(PARTITION_START);
    if (get_u16(image->data, image->size, boot + 510) != 0xaa55)
        die_path(path, "missing FAT boot signature");
    if (get_u16(image->data, image->size, boot + 11) != SECTOR_SIZE)
        die_path(path, "unexpected FAT bytes per sector");
    if (image->data[boot + 13] != SECTORS_PER_CLUSTER)
        die_path(path, "unexpected FAT sectors per cluster");
}

static uint16_t image_fat_entry(const Blob* image, uint32_t cluster)
{
    if (cluster >= FAT_ENTRY_COUNT)
        die("FAT cluster outside table");
    const uint8_t* fat = image->data + sector_offset(PARTITION_START + RESERVED_SECTORS);
    return get_u16(fat, SECTORS_PER_FAT * SECTOR_SIZE, (size_t)cluster * 2);
}

static FatFileInfo find_root_file(const Blob* image, const char name[11])
{
    FatFileInfo info;
    memset(&info, 0, sizeof(info));
    const uint8_t* root = image->data + sector_offset(root_lba());
    for (uint32_t i = 0; i < ROOT_ENTRIES; i++) {
        const uint8_t* entry = root + (size_t)i * 32;
        if (entry[0] == 0)
            break;
        if (entry[0] == 0xe5)
            continue;
        if (memcmp(entry, name, 11) != 0)
            continue;
        info.present = 1;
        info.attr = entry[11];
        info.first_cluster = get_u16(root, ROOT_ENTRIES * 32, (size_t)i * 32 + 26);
        info.size = get_u32(root, ROOT_ENTRIES * 32, (size_t)i * 32 + 28);
        return info;
    }
    return info;
}

static Blob read_root_file_blob(const Blob* image, const FatFileInfo* info, const char* label)
{
    Blob out;
    out.size = info->size;
    out.data = (uint8_t*)xcalloc(out.size ? out.size : 1, 1);
    if (!out.size)
        return out;
    if (info->first_cluster < 2 || info->first_cluster > last_data_cluster())
        die_path(label, "file has invalid first cluster");

    uint32_t cluster = info->first_cluster;
    size_t copied = 0;
    uint32_t guard = 0;
    while (copied < out.size) {
        if (cluster < 2 || cluster > last_data_cluster() || guard++ > data_cluster_count())
            die_path(label, "file cluster chain is invalid");
        size_t chunk = out.size - copied;
        if (chunk > cluster_size())
            chunk = cluster_size();
        memcpy(out.data + copied, image->data + cluster_offset(cluster), chunk);
        copied += chunk;
        if (copied >= out.size)
            break;
        cluster = image_fat_entry(image, cluster);
        if (cluster >= FAT16_EOC)
            die_path(label, "file cluster chain ended early");
    }
    return out;
}

static int root_file_equal(const Blob* left, const Blob* right, const char name[11])
{
    FatFileInfo left_info = find_root_file(left, name);
    FatFileInfo right_info = find_root_file(right, name);
    if (!left_info.present || !right_info.present)
        return 0;
    if (left_info.attr != right_info.attr || left_info.size != right_info.size)
        return 0;
    Blob left_data = read_root_file_blob(left, &left_info, "left image");
    Blob right_data = read_root_file_blob(right, &right_info, "right image");
    int equal = left_data.size == right_data.size
        && memcmp(left_data.data, right_data.data, left_data.size) == 0;
    free(left_data.data);
    free(right_data.data);
    return equal;
}

static int root_file_changed_from_baseline(const Blob* image, const Blob* baseline, const char name[11])
{
    if (!baseline)
        return 1;
    return !root_file_equal(image, baseline, name);
}

static Blob read_optional_text_file(const char* path)
{
    if (!path)
        return (Blob){ 0, 0 };
    return read_file(path);
}

static const char* status_find_field(const Blob* text, const char* key)
{
    if (!text->data)
        return NULL;
    size_t key_len = strlen(key);
    const char* data = (const char*)text->data;
    for (size_t i = 0; i + key_len < text->size; i++) {
        if (i != 0 && data[i - 1] != ' ' && data[i - 1] != '\n' && data[i - 1] != '\r')
            continue;
        if (memcmp(data + i, key, key_len) == 0 && data[i + key_len] == '=')
            return data + i + key_len + 1;
    }
    return NULL;
}

static int hex_value(char ch)
{
    if (ch >= '0' && ch <= '9')
        return ch - '0';
    if (ch >= 'a' && ch <= 'f')
        return ch - 'a' + 10;
    if (ch >= 'A' && ch <= 'F')
        return ch - 'A' + 10;
    return -1;
}

static uint32_t parse_status_hex(const char* p)
{
    uint32_t value = 0;
    int digits = 0;
    while (*p) {
        int nibble = hex_value(*p);
        if (nibble < 0)
            break;
        value = (value << 4) | (uint32_t)nibble;
        digits++;
        p++;
    }
    if (!digits)
        die("status field did not contain a hex value");
    return value;
}

static uint32_t status_hex_field(const Blob* text, const char* key)
{
    const char* p = status_find_field(text, key);
    if (!p)
        die("required status field is missing");
    return parse_status_hex(p);
}

static uint32_t status_hex_tuple_part(const Blob* text, const char* key, size_t part)
{
    const char* p = status_find_field(text, key);
    if (!p)
        die("required status tuple is missing");
    while (part--) {
        while (*p && *p != '/' && *p != ':')
            p++;
        if (!*p)
            die("status tuple has too few parts");
        p++;
    }
    return parse_status_hex(p);
}

static int status_has_literal(const Blob* text, const char* literal)
{
    if (!text->data)
        return 0;
    size_t len = strlen(literal);
    const char* data = (const char*)text->data;
    for (size_t i = 0; i + len <= text->size; i++) {
        if (memcmp(data + i, literal, len) == 0)
            return 1;
    }
    return 0;
}

static void check_default_cfg(const Blob* image, const Blob* baseline)
{
    FatFileInfo info = find_root_file(image, DEFAULT_CFG_NAME);
    if (!info.present)
        die("DEFAULT.CFG is missing from the FAT root");
    if (info.attr & FAT_ATTR_DIRECTORY)
        die("DEFAULT.CFG is a directory");
    if (info.size == 0)
        die("DEFAULT.CFG was not written");
    if (!root_file_changed_from_baseline(image, baseline, DEFAULT_CFG_NAME))
        die("DEFAULT.CFG did not change from the persistence baseline");
}

static void primary_save_slot_name_for_slot(int slot, char out[11])
{
    if (slot < 0 || slot > 5)
        die("save slot must be 0..5");
    memcpy(out, PRIMARY_SAVE_SLOT_TEMPLATE_NAME, 11);
    out[7] = (char)('0' + slot);
}

static void check_primary_save_slot(const Blob* image, const Blob* baseline, const Blob* reboot_baseline, int slot, const char* description)
{
    char name[11];
    primary_save_slot_name_for_slot(slot, name);
    FatFileInfo info = find_root_file(image, name);
    if (!info.present)
        die("required save slot is missing from the FAT root");
    if (info.attr & FAT_ATTR_DIRECTORY)
        die("required save slot is a directory");
    if (info.size < 64)
        die("required save slot is too small to prove persistence");
    if (!root_file_changed_from_baseline(image, baseline, name))
        die("required save slot did not change from the persistence baseline");
    if (reboot_baseline && !root_file_equal(image, reboot_baseline, name))
        die("required save slot changed across reboot/load proof");

    Blob data = read_root_file_blob(image, &info, "save slot");
    if (description) {
        size_t len = strlen(description);
        if (len > 24)
            die("required save description is longer than Doom's save title field");
        if (data.size < 24 || memcmp(data.data, description, len) != 0)
            die("required save slot does not contain the requested description");
    }
    if (data.size < 40 || memcmp(data.data + 24, "version ", 8) != 0)
        die("required save slot does not contain the expected version header");
    free(data.data);
}

static void check_write_status(const char* path, int require_save)
{
    Blob status = read_optional_text_file(path);
    if (!status.data)
        return;
    if (require_save) {
        if (status_hex_tuple_part(&status, "savewr", 0) == 0 ||
            status_hex_tuple_part(&status, "savewr", 1) == 0)
            die_path(path, "save write status did not prove save slot bytes and calls");
        if (status_hex_field(&status, "saveclose") == 0)
            die_path(path, "save write status did not prove close");
    } else {
        if (status_hex_field(&status, "doomwrite") == 0)
            die_path(path, "write status did not prove file writes");
        if (status_hex_field(&status, "doomclose") == 0)
            die_path(path, "write status did not prove closes");
    }
    free(status.data);
}

static void check_reboot_status(const char* path)
{
    Blob status = read_optional_text_file(path);
    if (!status.data)
        return;
    if (!status_has_literal(&status, "gameplay=OK"))
        die_path(path, "reboot status did not return to gameplay");
    if (status_has_literal(&status, "panic=") && !status_has_literal(&status, "panic=NONE"))
        die_path(path, "reboot status reported a panic");
    free(status.data);
}

static void check_load_status(const char* path)
{
    Blob status = read_optional_text_file(path);
    if (!status.data)
        return;
    if (!status_has_literal(&status, "gameplay=OK"))
        die_path(path, "load status did not return to gameplay");
    if (status_hex_tuple_part(&status, "saverd", 0) == 0 ||
        status_hex_tuple_part(&status, "saverd", 1) == 0)
        die_path(path, "load status did not prove save slot reads");
    if (status_has_literal(&status, "panic=") && !status_has_literal(&status, "panic=NONE"))
        die_path(path, "load status reported a panic");
    free(status.data);
}

static int check_dynamic_fat_status(const char* path)
{
    Blob status = read_optional_text_file(path);
    if (!status.data)
        return 0;
    if (!status_find_field(&status, "fatdyn")) {
        free(status.data);
        return 0;
    }
    uint32_t alloc_success = status_hex_tuple_part(&status, "fatdyn", 0);
    uint32_t free_ops = status_hex_tuple_part(&status, "fatdyn", 2);
    uint32_t grow_ops = status_hex_tuple_part(&status, "fatdyn", 4);
    uint32_t truncate_ops = status_hex_tuple_part(&status, "fatdyn", 6);
    uint32_t dir_updates = status_hex_tuple_part(&status, "fatdyn", 7);
    if (alloc_success == 0 && free_ops == 0 && grow_ops == 0 && truncate_ops == 0 && dir_updates == 0)
        die_path(path, "fatdyn status did not prove dynamic FAT activity");
    free(status.data);
    return 1;
}

static void parse_save_description(PersistenceCheck* check, const char* spec)
{
    char* end = NULL;
    long slot = strtol(spec, &end, 10);
    if (end == spec || *end != '=' || slot < 0 || slot > 5)
        die("--require-save-description expects SLOT=TEXT with slot 0..5");
    check->save_descriptions[slot] = end + 1;
}

static void persistence_check_add_slot(PersistenceCheck* check, const char* slot_text)
{
    char* end = NULL;
    long slot = strtol(slot_text, &end, 10);
    if (end == slot_text || *end || slot < 0 || slot > 5)
        die("--require-save-slot expects slot 0..5");
    for (size_t i = 0; i < check->save_slot_count; i++) {
        if (check->save_slots[i] == (int)slot)
            return;
    }
    if (check->save_slot_count >= 6)
        die("too many save slots requested");
    check->save_slots[check->save_slot_count++] = (int)slot;
}

static void check_persistence_image(const char* image_path, const PersistenceCheck* check)
{
    Blob image = read_file(image_path);
    validate_image_layout(&image, image_path);

    Blob baseline = { 0, 0 };
    Blob reboot_baseline = { 0, 0 };
    if (check->baseline_image) {
        baseline = read_file(check->baseline_image);
        validate_image_layout(&baseline, check->baseline_image);
    }
    if (check->reboot_baseline_image) {
        reboot_baseline = read_file(check->reboot_baseline_image);
        validate_image_layout(&reboot_baseline, check->reboot_baseline_image);
    }

    if (check->require_default)
        check_default_cfg(&image, baseline.data ? &baseline : NULL);
    for (size_t i = 0; i < check->save_slot_count; i++) {
        int slot = check->save_slots[i];
        check_primary_save_slot(
            &image,
            baseline.data ? &baseline : NULL,
            reboot_baseline.data ? &reboot_baseline : NULL,
            slot,
            check->save_descriptions[slot]);
    }

    check_write_status(check->write_status, 0);
    check_write_status(check->save_write_status, 1);
    check_load_status(check->load_status);
    check_reboot_status(check->reboot_status);
    if (check->require_dynamic_fat_proof) {
        int proved = check_dynamic_fat_status(check->write_status);
        proved |= check_dynamic_fat_status(check->save_write_status);
        if (!proved)
            die("dynamic FAT proof was requested without a write status file");
    }

    printf("schema=vibe-os-c-persistence-proof-v1\n");
    printf("image=%s\n", image_path);
    printf("default_cfg=%s\n", check->require_default ? "checked" : "not-requested");
    for (size_t i = 0; i < check->save_slot_count; i++)
        printf("save_slot_%d=checked\n", check->save_slots[i]);
    printf("result=ok\n");

    free(image.data);
    free(baseline.data);
    free(reboot_baseline.data);
}

static void write_padded_file(Image* image, uint32_t lba, uint32_t sectors, const char* path, const char* label)
{
    Blob blob = read_file(path);
    size_t cap = (size_t)sectors * SECTOR_SIZE;
    if (blob.size > cap) {
        fprintf(stderr, "make_wad_image: %s is %zu bytes, exceeds %zu bytes\n", label, blob.size, cap);
        exit(1);
    }
    memcpy(image->data + sector_offset(lba), blob.data, blob.size);
    free(blob.data);
}

static void fat83_from_display_component(const char* component, char out[11])
{
    memset(out, ' ', 11);
    const char* dot = strchr(component, '.');
    size_t base_len = dot ? (size_t)(dot - component) : strlen(component);
    size_t ext_len = dot ? strlen(dot + 1) : 0;
    if (!base_len || base_len > 8 || ext_len > 3)
        die("FAT16 path component must fit 8.3");
    if (dot && strchr(dot + 1, '.'))
        die("FAT16 path component has too many dots");

    for (size_t i = 0; i < base_len; i++) {
        char ch = component[i];
        if (ch >= 'a' && ch <= 'z')
            ch = (char)(ch - 'a' + 'A');
        if (!((ch >= 'A' && ch <= 'Z') || (ch >= '0' && ch <= '9') || ch == '_' || ch == '-'))
            die("FAT16 path component has unsupported characters");
        out[i] = ch;
    }
    for (size_t i = 0; i < ext_len; i++) {
        char ch = dot[1 + i];
        if (ch >= 'a' && ch <= 'z')
            ch = (char)(ch - 'a' + 'A');
        if (!((ch >= 'A' && ch <= 'Z') || (ch >= '0' && ch <= '9') || ch == '_' || ch == '-'))
            die("FAT16 extension has unsupported characters");
        out[8 + i] = ch;
    }
}

static int parse_path83(const char* display, char out[][11], size_t* out_count, size_t max_count)
{
    char component[64];
    size_t comp_len = 0;
    size_t count = 0;
    const char* p = display;

    if (!display || !display[0])
        die("FAT16 path must not be empty");
    while (*p) {
        char ch = *p++;
        if (ch == '\\')
            ch = '/';
        if (ch == '/') {
            if (comp_len) {
                component[comp_len] = 0;
                if (count == max_count)
                    die("FAT16 path is too deep");
                if (strcmp(component, "..") == 0)
                    die("FAT16 path must not use dot traversal");
                if (strcmp(component, ".") != 0)
                    fat83_from_display_component(component, out[count++]);
                comp_len = 0;
            }
            continue;
        }
        if (comp_len + 1 >= sizeof(component))
            die("FAT16 path component is too long");
        component[comp_len++] = ch;
    }
    if (comp_len) {
        component[comp_len] = 0;
        if (count == max_count)
            die("FAT16 path is too deep");
        if (strcmp(component, "..") == 0)
            die("FAT16 path must not use dot traversal");
        if (strcmp(component, ".") != 0)
            fat83_from_display_component(component, out[count++]);
    }
    if (!count)
        die("FAT16 path must name at least one component");
    *out_count = count;
    return 0;
}

static void root83_from_display(const char* display, char out[11])
{
    char path[4][11];
    size_t count = 0;
    parse_path83(display, path, &count, 4);
    if (count != 1)
        die("--root-elf must be a root-level NAME.ELF");
    if (memcmp(path[0] + 8, "ELF", 3) != 0)
        die("--root-elf name must use .ELF");
    memcpy(out, path[0], 11);
}

static void root_file83_from_display(const char* display, char out[11])
{
    char path[4][11];
    size_t count = 0;
    parse_path83(display, path, &count, 4);
    if (count != 1)
        die("--root-file must be a root-level 8.3 file name");
    memcpy(out, path[0], 11);
}

static int name_eq(const char lhs[11], const char rhs[11])
{
    return memcmp(lhs, rhs, 11) == 0;
}

static int asset_path_is_quake_pak0(const char path[][11], size_t count)
{
    return count == 2 && name_eq(path[0], QUAKE_ID1_DIR_NAME) && name_eq(path[1], QUAKE_PAK0_NAME);
}

static int path_is_at_or_under(const char* path, const char* root)
{
    size_t root_len = strlen(root);
    return strcmp(path, root) == 0 || (strncmp(path, root, root_len) == 0 && path[root_len] == '/');
}

static void reject_repo_local_external_asset(const char* path, const char* label)
{
    char cwd[PATH_MAX];
    char asset[PATH_MAX];

    if (!realpath(".", cwd))
        die_path(".", strerror(errno));
    if (!realpath(path, asset))
        die_path(path, strerror(errno));
    if (path_is_at_or_under(asset, cwd)) {
        fprintf(stderr, "make_wad_image: %s: %s must stay outside the repo for Pi proof packaging\n", path, label);
        exit(1);
    }
}

static void reject_protected_root_name(const char name[11])
{
    if (name_eq(name, PRIMARY_ASSET_WAD_NAME) || name_eq(name, KERNEL_ELF_NAME) ||
        name_eq(name, USER_PROBE_NAME))
        die("root file option tries to replace a protected boot entry");
}

static uint32_t allocate_cluster_chain(Image* image, uint32_t count, uint32_t* out_chain)
{
    uint32_t found = 0;
    for (uint32_t cluster = 2; cluster <= last_data_cluster() && found < count; cluster++) {
        if (image->fat[cluster] == 0)
            out_chain[found++] = cluster;
    }
    if (found != count)
        die("file does not fit in FAT16 data area");

    for (uint32_t i = 0; i < count; i++)
        image->fat[out_chain[i]] = (i + 1 == count) ? FAT16_EOC_VALUE : out_chain[i + 1];
    return out_chain[0];
}

static uint32_t write_cluster_chain(Image* image, const uint8_t* data, size_t size, uint32_t* out_count)
{
    uint32_t count = clusters_for_size(size);
    uint32_t* chain = (uint32_t*)xcalloc(count, sizeof(uint32_t));
    uint32_t first = allocate_cluster_chain(image, count, chain);
    size_t remaining = size;
    for (uint32_t i = 0; i < count; i++) {
        size_t off = cluster_offset(chain[i]);
        size_t chunk = remaining < cluster_size() ? remaining : cluster_size();
        if (chunk)
            memcpy(image->data + off, data + (size - remaining), chunk);
        remaining -= chunk;
    }
    free(chain);
    *out_count = count;
    return first;
}

static void write_dir_entry(uint8_t* dir, size_t dir_size, uint32_t index, const char name[11], uint8_t attr, uint32_t first_cluster, uint32_t size)
{
    size_t off = (size_t)index * 32;
    if (off + 32 > dir_size)
        die("FAT16 directory is full");
    memset(dir + off, 0, 32);
    memcpy(dir + off, name, 11);
    dir[off + 11] = attr;
    put_u16(dir, dir_size, off + 26, (uint16_t)first_cluster);
    put_u32(dir, dir_size, off + 28, size);
}

static uint8_t* root_dir(Image* image)
{
    return image->data + sector_offset(root_lba());
}

static uint32_t root_next_free(Image* image)
{
    uint8_t* root = root_dir(image);
    size_t root_size = ROOT_ENTRIES * 32;
    for (uint32_t i = 0; i < ROOT_ENTRIES; i++) {
        uint8_t first = root[i * 32];
        if (first == 0 || first == 0xe5)
            return i;
    }
    (void)root_size;
    die("FAT16 root directory is full");
    return 0;
}

static int dir_find(uint8_t* dir, size_t dir_size, const char name[11], uint32_t* out_index)
{
    for (uint32_t i = 0; (size_t)i * 32 + 32 <= dir_size; i++) {
        uint8_t first = dir[i * 32];
        if (first == 0)
            return 0;
        if (first != 0xe5 && memcmp(dir + i * 32, name, 11) == 0) {
            *out_index = i;
            return 1;
        }
    }
    return 0;
}

static uint32_t dir_next_free(uint8_t* dir, size_t dir_size)
{
    for (uint32_t i = 0; (size_t)i * 32 + 32 <= dir_size; i++) {
        uint8_t first = dir[i * 32];
        if (first == 0 || first == 0xe5)
            return i;
    }
    die("FAT16 directory is full");
    return 0;
}

static uint32_t entry_cluster(uint8_t* dir, size_t dir_size, uint32_t index)
{
    return get_u16(dir, dir_size, (size_t)index * 32 + 26);
}

static uint32_t ensure_child_directory(Image* image, uint32_t parent_cluster, const char name[11], uint8_t attr)
{
    uint8_t* dir = parent_cluster ? image->data + cluster_offset(parent_cluster) : root_dir(image);
    size_t dir_size = parent_cluster ? cluster_size() : ROOT_ENTRIES * 32;
    uint32_t index = 0;
    if (dir_find(dir, dir_size, name, &index)) {
        uint8_t* entry = dir + (size_t)index * 32;
        if ((entry[11] & FAT_ATTR_DIRECTORY) == 0)
            die("FAT16 path component exists but is not a directory");
        if (attr & FAT_ATTR_READ_ONLY)
            entry[11] |= FAT_ATTR_READ_ONLY;
        return entry_cluster(dir, dir_size, index);
    }

    uint32_t chain_count = 0;
    uint8_t zero = 0;
    uint32_t cluster = write_cluster_chain(image, &zero, 0, &chain_count);
    (void)chain_count;
    uint32_t free_index = dir_next_free(dir, dir_size);
    write_dir_entry(dir, dir_size, free_index, name, attr, cluster, 0);

    uint8_t* child = image->data + cluster_offset(cluster);
    write_dir_entry(child, cluster_size(), 0, ".          ", attr, cluster, 0);
    write_dir_entry(child, cluster_size(), 1, "..         ", FAT_ATTR_DIRECTORY, parent_cluster, 0);
    return cluster;
}

static void ensure_directory_path(Image* image, const char path[][11], size_t count, uint8_t attr)
{
    uint32_t parent = 0;
    for (size_t i = 0; i < count; i++)
        parent = ensure_child_directory(image, parent, path[i], attr);
}

static void write_file_path(Image* image, const char path[][11], size_t count, const uint8_t* data, size_t size, uint8_t attr)
{
    if (!count)
        die("FAT16 file path is empty");

    uint32_t parent = 0;
    for (size_t i = 0; i + 1 < count; i++)
        parent = ensure_child_directory(image, parent, path[i], FAT_ATTR_DIRECTORY | FAT_ATTR_READ_ONLY);

    uint8_t* dir = parent ? image->data + cluster_offset(parent) : root_dir(image);
    size_t dir_size = parent ? cluster_size() : ROOT_ENTRIES * 32;
    uint32_t chain_count = 0;
    uint32_t first_cluster = write_cluster_chain(image, data, size, &chain_count);
    (void)chain_count;

    uint32_t index = 0;
    if (!dir_find(dir, dir_size, path[count - 1], &index))
        index = dir_next_free(dir, dir_size);
    write_dir_entry(dir, dir_size, index, path[count - 1], attr, first_cluster, (uint32_t)size);
}

static void write_root_file_entry(Image* image, const char name[11], const uint8_t* data, size_t size)
{
    char path[1][11];
    memcpy(path[0], name, 11);
    write_file_path(image, path, 1, data, size, FAT_ATTR_ARCHIVE);
}

static int root_file_info(Image* image, const char name[11], FatFileInfo* out)
{
    uint8_t* root = root_dir(image);
    uint32_t index = 0;
    if (!dir_find(root, ROOT_ENTRIES * 32, name, &index))
        return 0;
    memset(out, 0, sizeof(*out));
    out->present = 1;
    out->attr = root[(size_t)index * 32 + 11];
    out->first_cluster = entry_cluster(root, ROOT_ENTRIES * 32, index);
    out->size = get_u32(root, ROOT_ENTRIES * 32, (size_t)index * 32 + 28);
    return 1;
}

static int root_file_size(Image* image, const char name[11], uint32_t* out_size)
{
    FatFileInfo info;
    if (!root_file_info(image, name, &info))
        return 0;
    *out_size = info.size;
    return 1;
}

static void manifest_write_root_elf_slot(TextBuffer* text, Image* image, size_t index, const char name[11])
{
    char display[13];
    FatFileInfo info;
    int present = root_file_info(image, name, &info);

    format_fat_name((const uint8_t*)name, display);
    text_appendf(text, "root_elf_slot.%zu.file=%s\n", index, display);
    text_appendf(text, "root_elf_slot.%zu.state=%s\n", index, present ? "present" : "absent");
    if (present) {
        text_appendf(text, "root_elf_slot.%zu.cluster=%u\n", index, info.first_cluster);
        text_appendf(text, "root_elf_slot.%zu.size=%u\n", index, info.size);
    }
}

static void manifest_write_payload_slot(
    TextBuffer* text,
    Image* image,
    size_t index,
    const char* kind,
    size_t root_elf_slot,
    const char name[11],
    const char* app_exec_path)
{
    char display[13];
    FatFileInfo info;
    int present = root_file_info(image, name, &info);

    format_fat_name((const uint8_t*)name, display);
    text_appendf(text, "payload_slot.%zu.kind=%s\n", index, kind);
    text_appendf(text, "payload_slot.%zu.file=%s\n", index, display);
    text_appendf(text, "payload_slot.%zu.root_elf_slot=%zu\n", index, root_elf_slot);
    text_appendf(text, "payload_slot.%zu.state=%s\n", index, present ? "present" : "absent");
    text_appendf(text, "payload_slot.%zu.source=%s\n", index, present ? "root-elf-input" : "absent");
    text_appendf(text, "payload_slot.%zu.repo_state=%s\n", index, present ? "unchecked" : "absent");
    text_appendf(text, "payload_slot.%zu.evidence=%s\n", index, present ? "packaged-file-only" : "absent");
    text_appendf(text, "payload_slot.%zu.hardware_proof=unclaimed\n", index);
    text_appendf(text, "payload_slot.%zu.launch_proof=unclaimed\n", index);
    text_appendf(text, "payload_slot.%zu.compatibility=legacy-root-payload\n", index);
    text_appendf(text, "payload_slot.%zu.app_exec=%s\n", index, app_exec_path);
    if (present) {
        text_appendf(text, "payload_slot.%zu.cluster=%u\n", index, info.first_cluster);
        text_appendf(text, "payload_slot.%zu.size=%u\n", index, info.size);
    }
}

static void proof_manifest_require_root_input(
    const ManifestEntry* entries,
    size_t entry_count,
    Image* image,
    const char name[11],
    const char* display,
    const char* kind)
{
    if (!manifest_find(entries, entry_count, display)) {
        fprintf(stderr, "make_wad_image: Pi proof manifest requires %s %s\n", display, kind);
        exit(1);
    }

    uint32_t size = 0;
    if (!root_file_size(image, name, &size) || size == 0) {
        fprintf(stderr, "make_wad_image: Pi proof manifest %s %s is missing or empty\n", display, kind);
        exit(1);
    }
}

static void proof_manifest_require_root_file(const ProofManifest* manifest, Image* image, const char name[11], const char* display)
{
    proof_manifest_require_root_input(manifest->root_files, manifest->root_file_count, image, name, display, "root file");
}

static void proof_manifest_require_root_elf(const ProofManifest* manifest, Image* image, const char name[11], const char* display)
{
    proof_manifest_require_root_input(manifest->root_elves, manifest->root_elf_count, image, name, display, "root ELF");
}

static const ManifestEntry* proof_manifest_require_asset(const ProofManifest* manifest, const char* display)
{
    const ManifestEntry* entry = manifest_find(manifest->assets, manifest->asset_count, display);
    if (!entry || entry->size == 0) {
        fprintf(stderr, "make_wad_image: Pi proof manifest requires installed app file %s\n", display);
        exit(1);
    }
    return entry;
}

static void manifest_write_app_file(TextBuffer* text, const char* prefix, const ManifestEntry* entry)
{
    text_appendf(text, "%s=%s\n", prefix, entry->file);
    text_appendf(text, "%s_size=%zu\n", prefix, entry->size);
}

static void write_proof_manifest(Image* image, const ProofManifest* manifest)
{
    if (!manifest->enabled)
        return;

    proof_manifest_require_root_file(manifest, image, PI4_KERNEL8_IMG_NAME, "KERNEL8.IMG");
    proof_manifest_require_root_file(manifest, image, PI4_CONFIG_TXT_NAME, "CONFIG.TXT");
    proof_manifest_require_root_elf(manifest, image, INIT_ELF_NAME, "INIT.ELF");
    proof_manifest_require_root_elf(manifest, image, ABI_PROBE_ELF_NAME, "ABIPROBE.ELF");
    proof_manifest_require_root_elf(manifest, image, LEGACY_PAYLOAD_ELF_NAME, "PAYLOAD0.ELF");
    proof_manifest_require_root_elf(manifest, image, PAYLOAD1_ELF_NAME, "PAYLOAD1.ELF");
    const ManifestEntry* system_init = proof_manifest_require_asset(manifest, PI4_SYSTEM_INIT_PATH);
    const ManifestEntry* system_abiprobe = proof_manifest_require_asset(manifest, PI4_SYSTEM_ABIPROBE_PATH);
    const ManifestEntry* app_index = proof_manifest_require_asset(manifest, PI4_APP_INDEX_PATH);
    const ManifestEntry* doom_manifest = proof_manifest_require_asset(manifest, PI4_DOOM_APP_MANIFEST_PATH);
    const ManifestEntry* doom_exec = proof_manifest_require_asset(manifest, PI4_DOOM_APP_EXEC_PATH);
    const ManifestEntry* quake_manifest = proof_manifest_require_asset(manifest, PI4_QUAKE_APP_MANIFEST_PATH);
    const ManifestEntry* quake_exec = proof_manifest_require_asset(manifest, PI4_QUAKE_APP_EXEC_PATH);

    TextBuffer text;
    memset(&text, 0, sizeof(text));
    const ManifestEntry* kernel = manifest_find(manifest->root_files, manifest->root_file_count, "KERNEL8.IMG");
    const ManifestEntry* config = manifest_find(manifest->root_files, manifest->root_file_count, "CONFIG.TXT");

    text_appendf(&text, "schema=vibe-os-pi4-image-manifest-v1\n");
    text_appendf(&text, "layout=vibe-os-pi4-fat16-v1\n");
    text_appendf(&text, "root_lba=%u\n", root_lba());
    text_appendf(&text, "data_lba=%u\n", data_lba());
    text_appendf(&text, "root_entry_count=%u\n", ROOT_ENTRIES);
    text_appendf(&text, "manifest_path=%s\n", PROOF_MANIFEST_PATH);
    if (kernel) {
        text_appendf(&text, "kernel_file=%s\n", kernel->file);
        text_appendf(&text, "kernel_size=%zu\n", kernel->size);
    } else {
        text_appendf(&text, "kernel_file=absent\n");
    }
    if (config) {
        text_appendf(&text, "config_file=%s\n", config->file);
        text_appendf(&text, "config_size=%zu\n", config->size);
    } else {
        text_appendf(&text, "config_file=absent\n");
    }
    text_appendf(&text, "root_elf_slot_count=4\n");
    manifest_write_root_elf_slot(&text, image, 0, INIT_ELF_NAME);
    manifest_write_root_elf_slot(&text, image, 1, ABI_PROBE_ELF_NAME);
    manifest_write_root_elf_slot(&text, image, 2, LEGACY_PAYLOAD_ELF_NAME);
    manifest_write_root_elf_slot(&text, image, 3, PAYLOAD1_ELF_NAME);
    text_appendf(&text, "payload_slot_count=2\n");
    text_appendf(&text, "legacy_root_payloads=%s\n", PI4_LEGACY_ROOT_PAYLOADS);
    manifest_write_payload_slot(&text, image, 0, "doom", 2, LEGACY_PAYLOAD_ELF_NAME, PI4_DOOM_APP_EXEC_PATH);
    manifest_write_payload_slot(&text, image, 1, "quake", 3, PAYLOAD1_ELF_NAME, PI4_QUAKE_APP_EXEC_PATH);
    text_appendf(&text, "app_model_schema=vibe-os-pi4-app-install-v1\n");
    text_appendf(&text, "app_layout=%s\n", PI4_APP_LAYOUT);
    text_appendf(&text, "app_discovery_model=%s\n", PI4_APP_DISCOVERY_MODEL);
    text_appendf(&text, "app_launch_model=generic-vfs-path-exec\n");
    text_appendf(&text, "app_exec_model=%s\n", PI4_APP_EXEC_MODEL);
    manifest_write_app_file(&text, "system_init", system_init);
    manifest_write_app_file(&text, "system_abiprobe", system_abiprobe);
    manifest_write_app_file(&text, "app_index", app_index);
    text_appendf(&text, "app_count=2\n");
    text_appendf(&text, "app.0.id=doom\n");
    text_appendf(&text, "app.0.name=%s\n", PI4_DOOM_APP_NAME);
    manifest_write_app_file(&text, "app.0.manifest", doom_manifest);
    manifest_write_app_file(&text, "app.0.exec", doom_exec);
    text_appendf(&text, "app.0.launch=generic-path-exec\n");
    text_appendf(&text, "app.0.exec_model=%s\n", PI4_APP_EXEC_MODEL);
    text_appendf(&text, "app.0.resource=%s\n", PI4_DOOM_APP_RESOURCE_PATH);
    text_appendf(&text, "app.0.asset=%s\n", PI4_DOOM_APP_RESOURCE_PATH);
    text_appendf(&text, "app.0.icon=%s\n", PI4_DOOM_APP_ICON);
    text_appendf(&text, "app.0.hardware_proof=unclaimed\n");
    text_appendf(&text, "app.1.id=quake\n");
    text_appendf(&text, "app.1.name=%s\n", PI4_QUAKE_APP_NAME);
    manifest_write_app_file(&text, "app.1.manifest", quake_manifest);
    manifest_write_app_file(&text, "app.1.exec", quake_exec);
    text_appendf(&text, "app.1.launch=generic-path-exec\n");
    text_appendf(&text, "app.1.exec_model=%s\n", PI4_APP_EXEC_MODEL);
    text_appendf(&text, "app.1.resource=%s\n", PI4_QUAKE_APP_RESOURCE_PATH);
    text_appendf(&text, "app.1.asset=%s\n", PROOF_QUAKE_PAK_PATH);
    text_appendf(&text, "app.1.icon=%s\n", PI4_QUAKE_APP_ICON);
    text_appendf(&text, "app.1.hardware_proof=unclaimed\n");
    text_appendf(&text, "primary_asset_file=DOOM1.WAD\n");
    text_appendf(&text, "primary_asset_kind=doom-wad\n");
    text_appendf(&text, "primary_asset_state=present\n");
    text_appendf(&text, "primary_asset_source=%s\n", manifest->primary_asset_external ? "external" : "generated-fixture");
    text_appendf(&text, "primary_asset_repo_state=%s\n", manifest->primary_asset_external ? "outside-repo" : "generated-by-builder");
    text_appendf(&text, "primary_asset_evidence=packaged-file-only\n");
    text_appendf(&text, "primary_asset_hardware_proof=unclaimed\n");
    text_appendf(&text, "primary_asset_size=%zu\n", manifest->primary_asset_size);
    text_appendf(&text, "asset_slot_count=2\n");
    text_appendf(&text, "asset_slot.0.kind=doom-wad\n");
    text_appendf(&text, "asset_slot.0.file=DOOM1.WAD\n");
    text_appendf(&text, "asset_slot.0.state=present\n");
    text_appendf(&text, "asset_slot.0.source=%s\n", manifest->primary_asset_external ? "external" : "generated-fixture");
    text_appendf(&text, "asset_slot.0.repo_state=%s\n", manifest->primary_asset_external ? "outside-repo" : "generated-by-builder");
    text_appendf(&text, "asset_slot.0.evidence=packaged-file-only\n");
    text_appendf(&text, "asset_slot.0.hardware_proof=unclaimed\n");
    text_appendf(&text, "asset_slot.0.size=%zu\n", manifest->primary_asset_size);
    text_appendf(&text, "asset_slot.1.kind=quake-pak\n");
    text_appendf(&text, "asset_slot.1.file=%s\n", PROOF_QUAKE_PAK_PATH);
    text_appendf(&text, "asset_slot.1.state=%s\n", manifest->quake_pak_present ? "present" : "absent");
    if (manifest->quake_pak_present) {
        text_appendf(&text, "asset_slot.1.source=external\n");
        text_appendf(&text, "asset_slot.1.repo_state=outside-repo\n");
        text_appendf(&text, "asset_slot.1.evidence=packaged-file-only\n");
        text_appendf(&text, "asset_slot.1.hardware_proof=unclaimed\n");
        text_appendf(&text, "asset_slot.1.size=%zu\n", manifest->quake_pak_size);
    } else {
        text_appendf(&text, "asset_slot.1.source=absent\n");
        text_appendf(&text, "asset_slot.1.repo_state=absent\n");
        text_appendf(&text, "asset_slot.1.evidence=absent\n");
        text_appendf(&text, "asset_slot.1.hardware_proof=unclaimed\n");
    }
    text_appendf(&text, "default_asset_count=%u\n", (unsigned)DEFAULT_PI4_ASSET_COUNT);
    text_appendf(&text, "default_asset.0.file=%s\n", DEFAULT_PI4_ASSET_README_PATH);
    text_appendf(&text, "default_asset.0.size=%zu\n", sizeof(DEFAULT_PI4_ASSET_README) - 1);
    text_appendf(&text, "default_asset.1.file=%s\n", DEFAULT_PI4_ASSET_MAP_PATH);
    text_appendf(&text, "default_asset.1.size=%zu\n", sizeof(DEFAULT_PI4_ASSET_MAP) - 1);
    text_appendf(&text, "default_asset.2.file=%s\n", DEFAULT_PI4_ASSET_PALETTE_PATH);
    text_appendf(&text, "default_asset.2.size=%u\n", (unsigned)DEFAULT_PI4_PALETTE_BYTES);
    text_appendf(&text, "quake_pak_file=%s\n", PROOF_QUAKE_PAK_PATH);
    text_appendf(&text, "quake_pak_kind=quake-pak\n");
    text_appendf(&text, "quake_pak_state=%s\n", manifest->quake_pak_present ? "present" : "absent");
    if (manifest->quake_pak_present) {
        text_appendf(&text, "quake_pak_source=external\n");
        text_appendf(&text, "quake_pak_repo_state=outside-repo\n");
        text_appendf(&text, "quake_pak_evidence=packaged-file-only\n");
        text_appendf(&text, "quake_pak_hardware_proof=unclaimed\n");
        text_appendf(&text, "quake_pak_size=%zu\n", manifest->quake_pak_size);
    } else {
        text_appendf(&text, "quake_pak_source=absent\n");
        text_appendf(&text, "quake_pak_repo_state=absent\n");
        text_appendf(&text, "quake_pak_evidence=absent\n");
        text_appendf(&text, "quake_pak_hardware_proof=unclaimed\n");
    }
    text_appendf(&text, "root_file_count=%zu\n", manifest->root_file_count);
    for (size_t i = 0; i < manifest->root_file_count; i++) {
        text_appendf(&text, "root_file.%zu.file=%s\n", i, manifest->root_files[i].file);
        text_appendf(&text, "root_file.%zu.size=%zu\n", i, manifest->root_files[i].size);
    }
    text_appendf(&text, "root_elf_count=%zu\n", manifest->root_elf_count);
    for (size_t i = 0; i < manifest->root_elf_count; i++) {
        text_appendf(&text, "root_elf.%zu.file=%s\n", i, manifest->root_elves[i].file);
        text_appendf(&text, "root_elf.%zu.size=%zu\n", i, manifest->root_elves[i].size);
    }
    text_appendf(&text, "asset_count=%zu\n", manifest->asset_count);
    for (size_t i = 0; i < manifest->asset_count; i++) {
        text_appendf(&text, "asset.%zu.file=%s\n", i, manifest->assets[i].file);
        text_appendf(&text, "asset.%zu.kind=%s\n", i, manifest_asset_kind_for_path(manifest->assets[i].file));
        text_appendf(&text, "asset.%zu.source=external-host-input\n", i);
        text_appendf(&text, "asset.%zu.repo_state=%s\n", i, manifest_asset_repo_state_for_path(manifest->assets[i].file));
        text_appendf(&text, "asset.%zu.evidence=packaged-file-only\n", i);
        text_appendf(&text, "asset.%zu.hardware_proof=unclaimed\n", i);
        text_appendf(&text, "asset.%zu.size=%zu\n", i, manifest->assets[i].size);
    }

    char path[4][11];
    size_t count = 0;
    parse_path83(PROOF_MANIFEST_PATH, path, &count, 4);
    write_file_path(image, path, count, (const uint8_t*)text.data, text.size, FAT_ATTR_ARCHIVE | FAT_ATTR_READ_ONLY);
    free(text.data);
}

static void write_empty_root_entry(Image* image, const char name[11])
{
    write_dir_entry(root_dir(image), ROOT_ENTRIES * 32, root_next_free(image), name, FAT_ATTR_ARCHIVE, 0, 0);
}

static void load_fat_copy(Image* image)
{
    const uint8_t* fat = image->data + sector_offset(PARTITION_START + RESERVED_SECTORS);

    for (uint32_t i = 0; i < FAT_ENTRY_COUNT; i++)
        image->fat[i] = get_u16(fat, SECTORS_PER_FAT * SECTOR_SIZE, (size_t)i * 2);
}

static void free_cluster_chain(Image* image, uint32_t first_cluster)
{
    uint32_t cluster = first_cluster;
    uint32_t guard = 0;

    while (cluster >= 2 && cluster < FAT_ENTRY_COUNT && guard++ < FAT_ENTRY_COUNT) {
        uint32_t next = image->fat[cluster];
        image->fat[cluster] = 0;
        memset(image->data + cluster_offset(cluster), 0, cluster_size());
        if (next >= FAT16_EOC)
            return;
        cluster = next;
    }
}

static void delete_root_file_entry(Image* image, const char name[11])
{
    uint8_t* root = root_dir(image);
    uint32_t index = 0;

    if (!dir_find(root, ROOT_ENTRIES * 32, name, &index))
        return;
    free_cluster_chain(image, entry_cluster(root, ROOT_ENTRIES * 32, index));
    memset(root + (size_t)index * 32, 0, 32);
    root[(size_t)index * 32] = 0xe5;
}

static void write_fat_copies(Image* image)
{
    image->fat[0] = 0xfff8;
    image->fat[1] = FAT16_EOC_VALUE;
    for (uint32_t fat_index = 0; fat_index < FAT_COUNT; fat_index++) {
        uint8_t* fat = image->data + sector_offset(PARTITION_START + RESERVED_SECTORS + fat_index * SECTORS_PER_FAT);
        for (uint32_t i = 0; i < FAT_ENTRY_COUNT; i++)
            put_u16(fat, SECTORS_PER_FAT * SECTOR_SIZE, (size_t)i * 2, image->fat[i]);
    }
}

static void wad_name(char out[8], const char* name)
{
    memset(out, 0, 8);
    size_t len = strlen(name);
    if (len > 8)
        die("WAD lump name too long");
    memcpy(out, name, len);
}

static Blob build_patch(uint8_t pixel)
{
    Blob patch;
    patch.size = 18;
    patch.data = (uint8_t*)xcalloc(patch.size, 1);
    put_u16(patch.data, patch.size, 0, 1);
    put_u16(patch.data, patch.size, 2, 1);
    put_u32(patch.data, patch.size, 8, 12);
    patch.data[12] = 0;
    patch.data[13] = 1;
    patch.data[14] = 0;
    patch.data[15] = pixel;
    patch.data[16] = 0;
    patch.data[17] = 0xff;
    return patch;
}

static Blob build_pnames(void)
{
    Blob out;
    out.size = 12;
    out.data = (uint8_t*)xcalloc(out.size, 1);
    put_u32(out.data, out.size, 0, 1);
    wad_name((char*)out.data + 4, "SYNTHPCH");
    return out;
}

static Blob build_texture1(void)
{
    size_t texture_count = sizeof(switch_textures) / sizeof(switch_textures[0]);
    size_t directory_size = 4 + texture_count * 4;
    Blob out;
    out.size = directory_size + texture_count * 32;
    out.data = (uint8_t*)xcalloc(out.size, 1);
    put_u32(out.data, out.size, 0, (uint32_t)texture_count);
    for (size_t i = 0; i < texture_count; i++) {
        size_t texture_off = directory_size + i * 32;
        put_u32(out.data, out.size, 4 + i * 4, (uint32_t)texture_off);
        wad_name((char*)out.data + texture_off, switch_textures[i]);
        put_u16(out.data, out.size, texture_off + 12, 1);
        put_u16(out.data, out.size, texture_off + 14, 1);
        put_u16(out.data, out.size, texture_off + 20, 1);
    }
    return out;
}

static void add_lump(WadLump** lumps, size_t* count, size_t* cap, uint8_t* wad, uint32_t* cursor, const char* name, const uint8_t* data, size_t size)
{
    if (*count == *cap) {
        *cap = *cap ? *cap * 2 : 128;
        *lumps = (WadLump*)xrealloc(*lumps, *cap * sizeof((*lumps)[0]));
    }
    WadLump* lump = &(*lumps)[(*count)++];
    lump->filepos = size ? *cursor : 0;
    lump->size = (uint32_t)size;
    wad_name(lump->name, name);
    if (size) {
        if ((uint64_t)*cursor + size > FIXTURE_WAD_SIZE)
            die("generated WAD fixture overflow");
        memcpy(wad + *cursor, data, size);
        *cursor += (uint32_t)size;
    }
}

static void add_startup_patch_lumps(WadLump** lumps, size_t* count, size_t* cap, uint8_t* wad, uint32_t* cursor, const uint8_t* patch, size_t patch_size)
{
    char name[16];
    for (int code = '!'; code <= '_'; code++) {
        snprintf(name, sizeof(name), "STCFN%03d", code);
        add_lump(lumps, count, cap, wad, cursor, name, patch, patch_size);
    }
    for (int i = 0; i < 10; i++) {
        snprintf(name, sizeof(name), "STTNUM%d", i);
        add_lump(lumps, count, cap, wad, cursor, name, patch, patch_size);
    }
    add_lump(lumps, count, cap, wad, cursor, "STTMINUS", patch, patch_size);
    for (int i = 0; i < 10; i++) {
        snprintf(name, sizeof(name), "STYSNUM%d", i);
        add_lump(lumps, count, cap, wad, cursor, name, patch, patch_size);
    }
    add_lump(lumps, count, cap, wad, cursor, "STTPRCNT", patch, patch_size);
    for (int i = 0; i < 6; i++) {
        snprintf(name, sizeof(name), "STKEYS%d", i);
        add_lump(lumps, count, cap, wad, cursor, name, patch, patch_size);
    }
    add_lump(lumps, count, cap, wad, cursor, "STARMS", patch, patch_size);
    for (int i = 2; i < 8; i++) {
        snprintf(name, sizeof(name), "STGNUM%d", i);
        add_lump(lumps, count, cap, wad, cursor, name, patch, patch_size);
    }
    add_lump(lumps, count, cap, wad, cursor, "STFB0", patch, patch_size);
    add_lump(lumps, count, cap, wad, cursor, "STBAR", patch, patch_size);
    for (int pain = 0; pain < 5; pain++) {
        for (int straight = 0; straight < 3; straight++) {
            snprintf(name, sizeof(name), "STFST%d%d", pain, straight);
            add_lump(lumps, count, cap, wad, cursor, name, patch, patch_size);
        }
        snprintf(name, sizeof(name), "STFTR%d0", pain);
        add_lump(lumps, count, cap, wad, cursor, name, patch, patch_size);
        snprintf(name, sizeof(name), "STFTL%d0", pain);
        add_lump(lumps, count, cap, wad, cursor, name, patch, patch_size);
        snprintf(name, sizeof(name), "STFOUCH%d", pain);
        add_lump(lumps, count, cap, wad, cursor, name, patch, patch_size);
        snprintf(name, sizeof(name), "STFEVL%d", pain);
        add_lump(lumps, count, cap, wad, cursor, name, patch, patch_size);
        snprintf(name, sizeof(name), "STFKILL%d", pain);
        add_lump(lumps, count, cap, wad, cursor, name, patch, patch_size);
    }
    add_lump(lumps, count, cap, wad, cursor, "STFGOD0", patch, patch_size);
    add_lump(lumps, count, cap, wad, cursor, "STFDEAD0", patch, patch_size);
    add_lump(lumps, count, cap, wad, cursor, "TITLEPIC", patch, patch_size);
    add_lump(lumps, count, cap, wad, cursor, "CREDIT", patch, patch_size);
    add_lump(lumps, count, cap, wad, cursor, "HELP2", patch, patch_size);
}

static void add_fixture_sprite_lumps(WadLump** lumps, size_t* count, size_t* cap, uint8_t* wad, uint32_t* cursor, const uint8_t* patch, size_t patch_size)
{
    static const char* const sprites[] = {
        "PUNGA0", "PUNGB0", "PUNGC0", "PUNGD0",
        "PISGA0", "PISGB0", "PISGC0", "PISFA0",
        "PLAYA0",
    };

    for (size_t i = 0; i < sizeof(sprites) / sizeof(sprites[0]); i++)
        add_lump(lumps, count, cap, wad, cursor, sprites[i], patch, patch_size);
}

static void put_map_vertex(uint8_t* data, size_t off, int16_t x, int16_t y)
{
    put_u16(data, 16, off, (uint16_t)x);
    put_u16(data, 16, off + 2, (uint16_t)y);
}

static void put_map_linedef(uint8_t* data, size_t off, int16_t v1, int16_t v2, int16_t flags, int16_t side)
{
    put_u16(data, 56, off, (uint16_t)v1);
    put_u16(data, 56, off + 2, (uint16_t)v2);
    put_u16(data, 56, off + 4, (uint16_t)flags);
    put_u16(data, 56, off + 6, 0);
    put_u16(data, 56, off + 8, 0);
    put_u16(data, 56, off + 10, (uint16_t)side);
    put_u16(data, 56, off + 12, 0xffff);
}

static void put_map_sidedef(uint8_t* data, size_t off)
{
    put_u16(data, 120, off, 0);
    put_u16(data, 120, off + 2, 0);
    wad_name((char*)data + off + 4, "-");
    wad_name((char*)data + off + 12, "-");
    wad_name((char*)data + off + 20, "SW1BRCOM");
    put_u16(data, 120, off + 28, 0);
}

static void put_map_seg(uint8_t* data, size_t off, int16_t v1, int16_t v2, int16_t angle, int16_t linedef)
{
    put_u16(data, 48, off, (uint16_t)v1);
    put_u16(data, 48, off + 2, (uint16_t)v2);
    put_u16(data, 48, off + 4, (uint16_t)angle);
    put_u16(data, 48, off + 6, (uint16_t)linedef);
    put_u16(data, 48, off + 8, 0);
    put_u16(data, 48, off + 10, 0);
}

static Blob build_generated_wad(void)
{
    Blob wad;
    wad.size = FIXTURE_WAD_SIZE;
    wad.data = (uint8_t*)xcalloc(wad.size, 1);
    WadLump* lumps = NULL;
    size_t lump_count = 0;
    size_t lump_cap = 0;
    uint32_t cursor = 12;
    Blob patch = build_patch(0);
    Blob pnames = build_pnames();
    Blob texture1 = build_texture1();
    uint8_t* playpal = (uint8_t*)xcalloc(14 * 256 * 3, 1);
    uint8_t* colormap = (uint8_t*)xcalloc(34 * 256, 1);
    uint8_t flat[64 * 64] = {0};
    uint8_t things[10] = {0};
    uint8_t linedefs[4 * 14] = {0};
    uint8_t sidedefs[4 * 30] = {0};
    uint8_t vertexes[4 * 4] = {0};
    uint8_t segs[4 * 12] = {0};
    uint8_t ssectors[4] = {0};
    uint8_t sector[26] = {0};
    uint8_t reject[1] = {0};
    uint8_t blockmap[13 * 2] = {0};

    for (size_t i = 0; i < 14 * 256 * 3; i++)
        playpal[i] = (uint8_t)(i % 64);
    for (size_t i = 0; i < 34 * 256; i++)
        colormap[i] = (uint8_t)(i & 0xff);
    put_u16(things, sizeof(things), 6, 1);
    put_u16(things, sizeof(things), 8, 7);
    put_map_vertex(vertexes, 0, -64, -64);
    put_map_vertex(vertexes, 4, 64, -64);
    put_map_vertex(vertexes, 8, 64, 64);
    put_map_vertex(vertexes, 12, -64, 64);
    put_map_linedef(linedefs, 0, 1, 0, 1, 0);
    put_map_linedef(linedefs, 14, 2, 1, 1, 1);
    put_map_linedef(linedefs, 28, 3, 2, 1, 2);
    put_map_linedef(linedefs, 42, 0, 3, 1, 3);
    for (size_t i = 0; i < 4; i++)
        put_map_sidedef(sidedefs, i * 30);
    put_map_seg(segs, 0, 1, 0, 32767, 0);
    put_map_seg(segs, 12, 2, 1, -16384, 1);
    put_map_seg(segs, 24, 3, 2, 0, 2);
    put_map_seg(segs, 36, 0, 3, 16384, 3);
    put_u16(ssectors, sizeof(ssectors), 0, 4);
    put_u16(ssectors, sizeof(ssectors), 2, 0);
    put_u16(sector, sizeof(sector), 0, 0);
    put_u16(sector, sizeof(sector), 2, 128);
    wad_name((char*)sector + 4, "F_SKY1");
    wad_name((char*)sector + 12, "F_SKY1");
    put_u16(sector, sizeof(sector), 20, 160);
    put_u16(blockmap, sizeof(blockmap), 0, (uint16_t)-128);
    put_u16(blockmap, sizeof(blockmap), 2, (uint16_t)-128);
    put_u16(blockmap, sizeof(blockmap), 4, 2);
    put_u16(blockmap, sizeof(blockmap), 6, 2);
    put_u16(blockmap, sizeof(blockmap), 8, 8);
    put_u16(blockmap, sizeof(blockmap), 10, 8);
    put_u16(blockmap, sizeof(blockmap), 12, 8);
    put_u16(blockmap, sizeof(blockmap), 14, 8);
    put_u16(blockmap, sizeof(blockmap), 16, 0);
    put_u16(blockmap, sizeof(blockmap), 18, 1);
    put_u16(blockmap, sizeof(blockmap), 20, 2);
    put_u16(blockmap, sizeof(blockmap), 22, 3);
    put_u16(blockmap, sizeof(blockmap), 24, 0xffff);

    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "PLAYPAL", playpal, 14 * 256 * 3);
    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "COLORMAP", colormap, 34 * 256);
    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "PNAMES", pnames.data, pnames.size);
    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "TEXTURE1", texture1.data, texture1.size);
    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "F_START", NULL, 0);
    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "F_SKY1", flat, sizeof(flat));
    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "F_END", NULL, 0);
    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "S_START", NULL, 0);
    add_fixture_sprite_lumps(&lumps, &lump_count, &lump_cap, wad.data, &cursor, patch.data, patch.size);
    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "S_END", NULL, 0);
    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "SYNTHPCH", patch.data, patch.size);
    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "D_INTRO", FIXTURE_MUS_SCORE_END, sizeof(FIXTURE_MUS_SCORE_END));
    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "D_E1M1", FIXTURE_MUS_SCORE_END, sizeof(FIXTURE_MUS_SCORE_END));
    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "E1M1", NULL, 0);
    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "THINGS", things, sizeof(things));
    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "LINEDEFS", linedefs, sizeof(linedefs));
    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "SIDEDEFS", sidedefs, sizeof(sidedefs));
    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "VERTEXES", vertexes, sizeof(vertexes));
    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "SEGS", segs, sizeof(segs));
    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "SSECTORS", ssectors, sizeof(ssectors));
    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "NODES", NULL, 0);
    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "SECTORS", sector, sizeof(sector));
    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "REJECT", reject, sizeof(reject));
    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "BLOCKMAP", blockmap, sizeof(blockmap));
    add_startup_patch_lumps(&lumps, &lump_count, &lump_cap, wad.data, &cursor, patch.data, patch.size);

    uint32_t directory_offset = cursor;
    if ((uint64_t)directory_offset + lump_count * 16 > FIXTURE_WAD_SIZE)
        die("generated WAD directory overflow");
    for (size_t i = 0; i < lump_count; i++) {
        size_t off = directory_offset + i * 16;
        put_u32(wad.data, wad.size, off, lumps[i].filepos);
        put_u32(wad.data, wad.size, off + 4, lumps[i].size);
        memcpy(wad.data + off + 8, lumps[i].name, 8);
    }
    memcpy(wad.data, "IWAD", 4);
    put_u32(wad.data, wad.size, 4, (uint32_t)lump_count);
    put_u32(wad.data, wad.size, 8, directory_offset);

    const char pattern[] = "vibe-os hard-path IDE FAT16 WAD fixture\n";
    size_t fill_start = directory_offset + lump_count * 16;
    for (size_t off = fill_start; off < wad.size; off += sizeof(pattern) - 1) {
        size_t n = sizeof(pattern) - 1;
        if (off + n > wad.size)
            n = wad.size - off;
        memcpy(wad.data + off, pattern, n);
    }

    free(lumps);
    free(patch.data);
    free(pnames.data);
    free(texture1.data);
    free(playpal);
    free(colormap);
    return wad;
}

static Blob load_external_wad(const char* path)
{
    Blob wad = read_file(path);
    if (wad.size > MAX_PRIMARY_WAD_BYTES)
        die_path(path, "WAD exceeds primary asset load limit");
    if (wad.size < 12)
        die_path(path, "too small to be a WAD");
    if (memcmp(wad.data, "IWAD", 4) != 0 && memcmp(wad.data, "PWAD", 4) != 0)
        die_path(path, "does not start with IWAD or PWAD");
    uint32_t lump_count = get_u32(wad.data, wad.size, 4);
    uint32_t directory_offset = get_u32(wad.data, wad.size, 8);
    uint64_t directory_end = (uint64_t)directory_offset + (uint64_t)lump_count * 16;
    if (lump_count == 0)
        die_path(path, "WAD has no lumps");
    if (directory_end > wad.size)
        die_path(path, "WAD directory is outside the file");
    for (uint32_t i = 0; i < lump_count; i++) {
        size_t entry = (size_t)directory_offset + (size_t)i * 16;
        uint32_t lump_offset = get_u32(wad.data, wad.size, entry);
        uint32_t lump_size = get_u32(wad.data, wad.size, entry + 4);
        uint64_t lump_end = (uint64_t)lump_offset + lump_size;
        if (lump_size == 0) {
            if (lump_offset > wad.size)
                die_path(path, "WAD marker lump points outside the file");
        } else if (lump_end > wad.size) {
            die_path(path, "WAD lump data is outside the file");
        }
    }
    return wad;
}

static void validate_quake_pak(const char* path, const Blob* pak)
{
    if (pak->size < 12)
        die_path(path, "too small to be a Quake PAK");
    if (memcmp(pak->data, "PACK", 4) != 0)
        die_path(path, "does not start with PACK");

    uint32_t directory_offset = get_u32(pak->data, pak->size, 4);
    uint32_t directory_size = get_u32(pak->data, pak->size, 8);
    uint64_t directory_end = (uint64_t)directory_offset + directory_size;
    if (directory_size == 0 || directory_size % PAK_DIRECTORY_ENTRY_SIZE != 0)
        die_path(path, "PAK directory size is invalid");
    if (directory_end > pak->size)
        die_path(path, "PAK directory is outside the file");

    uint32_t entry_count = directory_size / PAK_DIRECTORY_ENTRY_SIZE;
    for (uint32_t i = 0; i < entry_count; i++) {
        size_t entry = (size_t)directory_offset + (size_t)i * PAK_DIRECTORY_ENTRY_SIZE;
        uint32_t file_offset = get_u32(pak->data, pak->size, entry + 56);
        uint32_t file_size = get_u32(pak->data, pak->size, entry + 60);
        uint64_t file_end = (uint64_t)file_offset + file_size;
        if (pak->data[entry] == 0)
            die_path(path, "PAK entry has an empty name");
        if (file_end > pak->size)
            die_path(path, "PAK entry data is outside the file");
    }
}

static void write_mbr_and_bpb(Image* image, const char* stage1_path, const char* stage2_path, const char* kernel_path)
{
    uint8_t* mbr = image->data;
    if (stage1_path) {
        Blob stage1 = read_file(stage1_path);
        if (stage1.size != SECTOR_SIZE)
            die_path(stage1_path, "stage1 must be exactly 512 bytes");
        memcpy(mbr, stage1.data, SECTOR_SIZE);
        free(stage1.data);
        write_padded_file(image, STAGE2_LBA, STAGE2_SECTORS, stage2_path, "stage2");
        write_padded_file(image, KERNEL_LBA, KERNEL_SECTORS, kernel_path, "kernel");
    } else {
        mbr[0] = 0xeb;
        mbr[1] = 0x3c;
        mbr[2] = 0x90;
    }

    memcpy(mbr + 440, MBR_DISK_ID, sizeof(MBR_DISK_ID) - 1);
    size_t entry = 446;
    mbr[entry] = 0x80;
    mbr[entry + 1] = 0x01;
    mbr[entry + 2] = 0x01;
    mbr[entry + 3] = 0x00;
    mbr[entry + 4] = 0x06;
    mbr[entry + 5] = 0xfe;
    mbr[entry + 6] = 0xff;
    mbr[entry + 7] = 0xff;
    put_u32(mbr, SECTOR_SIZE, entry + 8, PARTITION_START);
    put_u32(mbr, SECTOR_SIZE, entry + 12, PARTITION_SECTORS);
    put_u16(mbr, SECTOR_SIZE, 510, 0xaa55);

    uint8_t* boot = image->data + sector_offset(PARTITION_START);
    boot[0] = 0xeb;
    boot[1] = 0x3c;
    boot[2] = 0x90;
    memcpy(boot + 3, FAT_OEM_NAME, sizeof(FAT_OEM_NAME) - 1);
    put_u16(boot, SECTOR_SIZE, 11, SECTOR_SIZE);
    boot[13] = SECTORS_PER_CLUSTER;
    put_u16(boot, SECTOR_SIZE, 14, RESERVED_SECTORS);
    boot[16] = FAT_COUNT;
    put_u16(boot, SECTOR_SIZE, 17, ROOT_ENTRIES);
    put_u16(boot, SECTOR_SIZE, 19, 0);
    boot[21] = 0xf8;
    put_u16(boot, SECTOR_SIZE, 22, SECTORS_PER_FAT);
    put_u16(boot, SECTOR_SIZE, 24, 63);
    put_u16(boot, SECTOR_SIZE, 26, 16);
    put_u32(boot, SECTOR_SIZE, 28, PARTITION_START);
    put_u32(boot, SECTOR_SIZE, 32, PARTITION_SECTORS);
    boot[36] = 0x80;
    boot[38] = 0x29;
    put_u32(boot, SECTOR_SIZE, 39, 0xd00d0001);
    memcpy(boot + 43, FAT_VOLUME_LABEL, sizeof(FAT_VOLUME_LABEL) - 1);
    memcpy(boot + 54, "FAT16   ", 8);
    put_u16(boot, SECTOR_SIZE, 510, 0xaa55);
}

static void package_default_assets(Image* image)
{
    uint8_t pal[DEFAULT_PI4_PALETTE_BYTES];
    char path[4][11];
    size_t count = 0;

    char state_path[1][11];
    memcpy(state_path[0], STATE_DIR_NAME, 11);
    ensure_directory_path(image, state_path, 1, FAT_ATTR_DIRECTORY);

    parse_path83(DEFAULT_PI4_ASSET_README_PATH, path, &count, 4);
    write_file_path(image, path, count, DEFAULT_PI4_ASSET_README, sizeof(DEFAULT_PI4_ASSET_README) - 1, FAT_ATTR_ARCHIVE | FAT_ATTR_READ_ONLY);
    parse_path83(DEFAULT_PI4_ASSET_MAP_PATH, path, &count, 4);
    write_file_path(image, path, count, DEFAULT_PI4_ASSET_MAP, sizeof(DEFAULT_PI4_ASSET_MAP) - 1, FAT_ATTR_ARCHIVE | FAT_ATTR_READ_ONLY);
    for (size_t i = 0; i < sizeof(pal); i++)
        pal[i] = (uint8_t)i;
    parse_path83(DEFAULT_PI4_ASSET_PALETTE_PATH, path, &count, 4);
    write_file_path(image, path, count, pal, sizeof(pal), FAT_ATTR_ARCHIVE | FAT_ATTR_READ_ONLY);
}

static size_t package_extra_asset(Image* image, const char* display, const char* host_path, int proof_manifest_enabled, int* out_is_quake_pak)
{
    char path[8][11];
    size_t count = 0;
    parse_path83(display, path, &count, 8);
    if (count < 2)
        die("--asset path must include a directory component");
    int is_quake_pak = asset_path_is_quake_pak0(path, count);
    *out_is_quake_pak = is_quake_pak;
    if (proof_manifest_enabled && is_quake_pak)
        reject_repo_local_external_asset(host_path, "external Quake PAK");
    Blob data = read_file(host_path);
    if (is_quake_pak)
        validate_quake_pak(host_path, &data);
    size_t size = data.size;
    write_file_path(image, path, count, data.data, data.size, FAT_ATTR_ARCHIVE | FAT_ATTR_READ_ONLY);
    free(data.data);
    return size;
}

static void install_bootable_layout(
    Image* image,
    const char* primary_asset_wad_path,
    const char* stage1_path,
    const char* stage2_path,
    const char* kernel_path,
    const char* user_elf_path,
    const char* legacy_payload_elf_path,
    RootElfArg* root_elves,
    size_t root_elf_count,
    RootFileArg* root_files,
    size_t root_file_count,
    AssetArg* assets,
    size_t asset_count,
    int proof_manifest_enabled)
{
    if ((stage1_path || stage2_path || kernel_path) && !(stage1_path && stage2_path && kernel_path))
        die("stage1, stage2, and kernel paths must be provided together");
    if (legacy_payload_elf_path && !user_elf_path)
        die("legacy root payload ELF packaging requires a user probe ELF path");

    ProofManifest manifest;
    memset(&manifest, 0, sizeof(manifest));
    manifest.enabled = proof_manifest_enabled;
    manifest.primary_asset_external = primary_asset_wad_path != NULL;

    write_mbr_and_bpb(image, stage1_path, stage2_path, kernel_path);

    if (proof_manifest_enabled && primary_asset_wad_path)
        reject_repo_local_external_asset(primary_asset_wad_path, "external Doom WAD");

    Blob primary_asset = primary_asset_wad_path ? load_external_wad(primary_asset_wad_path) : build_generated_wad();
    manifest.primary_asset_size = primary_asset.size;
    uint32_t primary_asset_clusters = 0;
    uint32_t primary_asset_cluster = write_cluster_chain(image, primary_asset.data, primary_asset.size, &primary_asset_clusters);
    if (primary_asset_cluster != 2)
        die("primary WAD asset (DOOM1.WAD) must start at cluster 2");
    (void)primary_asset_clusters;
    write_dir_entry(root_dir(image), ROOT_ENTRIES * 32, root_next_free(image), PRIMARY_ASSET_WAD_NAME, FAT_ATTR_ARCHIVE, primary_asset_cluster, (uint32_t)primary_asset.size);
    free(primary_asset.data);

    if (kernel_path) {
        Blob kernel = read_file(kernel_path);
        write_root_file_entry(image, KERNEL_ELF_NAME, kernel.data, kernel.size);
        free(kernel.data);
    }

    if (user_elf_path) {
        Blob user = read_file(user_elf_path);
        write_root_file_entry(image, USER_PROBE_NAME, user.data, user.size);
        free(user.data);
        if (legacy_payload_elf_path) {
            Blob payload = read_file(legacy_payload_elf_path);
            write_root_file_entry(image, LEGACY_PAYLOAD_ELF_NAME, payload.data, payload.size);
            free(payload.data);
        }
    }

    for (size_t i = 0; i < root_elf_count; i++) {
        Blob elf = read_file(root_elves[i].path);
        write_root_file_entry(image, root_elves[i].name, elf.data, elf.size);
        manifest_note_root_elf(&manifest, root_elves[i].name, elf.size);
        free(elf.data);
    }

    for (size_t i = 0; i < root_file_count; i++) {
        Blob file = read_file(root_files[i].path);
        write_root_file_entry(image, root_files[i].name, file.data, file.size);
        manifest_note_root_file(&manifest, root_files[i].name, file.size);
        free(file.data);
    }

    package_default_assets(image);
    for (size_t i = 0; i < asset_count; i++) {
        int is_quake_pak = 0;
        size_t asset_size = package_extra_asset(image, assets[i].display, assets[i].path, proof_manifest_enabled, &is_quake_pak);
        if (is_quake_pak) {
            manifest.quake_pak_present = 1;
            manifest.quake_pak_size = asset_size;
        }
        manifest_note_asset(&manifest, assets[i].display, asset_size);
    }

    write_proof_manifest(image, &manifest);
    write_root_file_entry(image, DEFAULT_CFG_NAME, DEFAULT_CFG_CONTENT, sizeof(DEFAULT_CFG_CONTENT) - 1);
    for (int slot = 0; slot < 6; slot++) {
        char save_name[11];
        primary_save_slot_name_for_slot(slot, save_name);
        write_empty_root_entry(image, save_name);
    }
    write_empty_root_entry(image, PERSISTENCE_CHECKPOINT_NAME);
    write_empty_root_entry(image, SAVE_REQUEST_NAME);
    write_empty_root_entry(image, LOAD_REQUEST_NAME);

    uint32_t free_clusters = 0;
    for (uint32_t cluster = 2; cluster <= last_data_cluster(); cluster++) {
        if (image->fat[cluster] == 0)
            free_clusters++;
    }
    if (free_clusters < MIN_OS_CREATED_FILE_CLUSTERS)
        die("FAT16 image does not leave enough OS-created file headroom");

    write_fat_copies(image);
    free_proof_manifest(&manifest);
}

static void parse_root_elf_arg(const char* arg, RootElfArg* out)
{
    const char* eq = strchr(arg, '=');
    if (!eq || eq == arg || !eq[1])
        die("--root-elf must be NAME.ELF=PATH");
    char display[64];
    size_t display_len = (size_t)(eq - arg);
    if (display_len >= sizeof(display))
        die("--root-elf display name is too long");
    memcpy(display, arg, display_len);
    display[display_len] = 0;
    root83_from_display(display, out->name);
    reject_protected_root_name(out->name);
    out->path = eq + 1;
}

static void parse_root_file_arg(const char* arg, RootFileArg* out)
{
    const char* eq = strchr(arg, '=');
    if (!eq || eq == arg || !eq[1])
        die("--root-file must be NAME.EXT=PATH");
    char display[64];
    size_t display_len = (size_t)(eq - arg);
    if (display_len >= sizeof(display))
        die("--root-file display name is too long");
    memcpy(display, arg, display_len);
    display[display_len] = 0;
    root_file83_from_display(display, out->name);
    reject_protected_root_name(out->name);
    out->path = eq + 1;
}

static void parse_asset_arg(const char* arg, AssetArg* out)
{
    const char* eq = strchr(arg, '=');
    if (!eq || eq == arg || !eq[1])
        die("--asset must be IMAGE_8.3_PATH=HOST_PATH");
    size_t display_len = (size_t)(eq - arg);
    if (display_len >= sizeof(out->display))
        die("--asset display path is too long");
    memcpy(out->display, arg, display_len);
    out->display[display_len] = 0;
    out->path = eq + 1;
}

static void marker_name_from_symbol(const char* symbol, char out[11])
{
    if (strcmp(symbol, "PERSISTENCE_CHECKPOINT_NAME") == 0) {
        memcpy(out, PERSISTENCE_CHECKPOINT_NAME, 11);
    } else if (strcmp(symbol, "SAVE_REQUEST_NAME") == 0) {
        memcpy(out, SAVE_REQUEST_NAME, 11);
    } else if (strcmp(symbol, "LOAD_REQUEST_NAME") == 0) {
        memcpy(out, LOAD_REQUEST_NAME, 11);
    } else {
        die("unknown root marker symbol");
    }
}

static void mutate_root_marker(const char* image_path, const char* symbol, const char* payload, int write_marker)
{
    Blob blob = read_file(image_path);
    Image image;
    char name[11];

    if (blob.size != (size_t)IMAGE_SECTORS * SECTOR_SIZE)
        die_path(image_path, "unexpected disk image size");
    image.data = blob.data;
    image.size = blob.size;
    memset(image.fat, 0, sizeof(image.fat));
    load_fat_copy(&image);
    marker_name_from_symbol(symbol, name);

    delete_root_file_entry(&image, name);
    if (write_marker)
        write_root_file_entry(&image, name, (const uint8_t*)payload, strlen(payload));

    write_fat_copies(&image);
    write_file(image_path, image.data, image.size);
    free(image.data);
}

static void usage(void)
{
    die("usage: make_wad_image [--require-real-assets] [--require-file FAT_PATH] --inspect IMAGE\n"
        "       make_wad_image [--proof-manifest] [--primary-asset-wad PATH|--wad PATH] [--root-elf NAME.ELF=PATH] [--root-file NAME.EXT=PATH] [--asset IMAGE_8.3_PATH=HOST_PATH] OUTPUT [STAGE1 STAGE2 KERNEL [USER_ELF [LEGACY_PAYLOAD_ELF]]]\n"
        "       make_wad_image --write-root-marker SYMBOL PAYLOAD IMAGE\n"
        "       make_wad_image --delete-root-marker SYMBOL IMAGE\n"
        "       make_wad_image --check-persistence IMAGE [--baseline-image IMAGE] [--reboot-baseline-image IMAGE] [--write-status FILE] [--save-write-status FILE] [--load-status FILE] [--reboot-status FILE] [--require-default] [--require-dynamic-fat-proof] [--require-save-slot N] [--require-save-description N=TEXT]");
}

int main(int argc, char** argv)
{
    const char* primary_asset_wad_path = NULL;
    const char* inspect_path = NULL;
    int proof_manifest_enabled = 0;
    int require_real_assets = 0;
    const char** inspect_required_files = NULL;
    size_t inspect_required_file_count = 0;
    RootElfArg* root_elves = NULL;
    size_t root_elf_count = 0;
    RootFileArg* root_files = NULL;
    size_t root_file_count = 0;
    AssetArg* assets = NULL;
    size_t asset_count = 0;
    const char** positional = (const char**)xcalloc((size_t)argc, sizeof(char*));
    size_t positional_count = 0;

    if (argc == 5 && strcmp(argv[1], "--write-root-marker") == 0) {
        mutate_root_marker(argv[4], argv[2], argv[3], 1);
        free(positional);
        return 0;
    }
    if (argc == 4 && strcmp(argv[1], "--delete-root-marker") == 0) {
        mutate_root_marker(argv[3], argv[2], "", 0);
        free(positional);
        return 0;
    }
    if (argc >= 3 && strcmp(argv[1], "--check-persistence") == 0) {
        PersistenceCheck check;
        memset(&check, 0, sizeof(check));
        const char* image_path = argv[2];
        for (int i = 3; i < argc; i++) {
            if (strcmp(argv[i], "--baseline-image") == 0) {
                if (++i >= argc)
                    usage();
                check.baseline_image = argv[i];
            } else if (strcmp(argv[i], "--reboot-baseline-image") == 0) {
                if (++i >= argc)
                    usage();
                check.reboot_baseline_image = argv[i];
            } else if (strcmp(argv[i], "--write-status") == 0) {
                if (++i >= argc)
                    usage();
                check.write_status = argv[i];
            } else if (strcmp(argv[i], "--save-write-status") == 0) {
                if (++i >= argc)
                    usage();
                check.save_write_status = argv[i];
            } else if (strcmp(argv[i], "--load-status") == 0) {
                if (++i >= argc)
                    usage();
                check.load_status = argv[i];
            } else if (strcmp(argv[i], "--reboot-status") == 0) {
                if (++i >= argc)
                    usage();
                check.reboot_status = argv[i];
            } else if (strcmp(argv[i], "--require-default") == 0) {
                check.require_default = 1;
            } else if (strcmp(argv[i], "--require-dynamic-fat-proof") == 0) {
                check.require_dynamic_fat_proof = 1;
            } else if (strcmp(argv[i], "--require-save-slot") == 0) {
                if (++i >= argc)
                    usage();
                persistence_check_add_slot(&check, argv[i]);
            } else if (strcmp(argv[i], "--require-save-description") == 0) {
                if (++i >= argc)
                    usage();
                parse_save_description(&check, argv[i]);
            } else {
                usage();
            }
        }
        check_persistence_image(image_path, &check);
        free(positional);
        return 0;
    }

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--primary-asset-wad") == 0 || strcmp(argv[i], "--wad") == 0) {
            if (++i >= argc)
                usage();
            primary_asset_wad_path = argv[i];
        } else if (strcmp(argv[i], "--proof-manifest") == 0) {
            proof_manifest_enabled = 1;
        } else if (strcmp(argv[i], "--inspect") == 0) {
            if (++i >= argc)
                usage();
            inspect_path = argv[i];
        } else if (strcmp(argv[i], "--require-real-assets") == 0) {
            require_real_assets = 1;
        } else if (strcmp(argv[i], "--require-file") == 0) {
            if (++i >= argc)
                usage();
            inspect_required_files = (const char**)xrealloc(
                inspect_required_files,
                (inspect_required_file_count + 1) * sizeof(inspect_required_files[0]));
            inspect_required_files[inspect_required_file_count++] = argv[i];
        } else if (strcmp(argv[i], "--root-elf") == 0) {
            if (++i >= argc)
                usage();
            root_elves = (RootElfArg*)xrealloc(root_elves, (root_elf_count + 1) * sizeof(root_elves[0]));
            parse_root_elf_arg(argv[i], &root_elves[root_elf_count]);
            for (size_t existing = 0; existing < root_elf_count; existing++) {
                if (name_eq(root_elves[existing].name, root_elves[root_elf_count].name))
                    die("duplicate --root-elf entry");
            }
            root_elf_count++;
        } else if (strcmp(argv[i], "--root-file") == 0) {
            if (++i >= argc)
                usage();
            root_files = (RootFileArg*)xrealloc(root_files, (root_file_count + 1) * sizeof(root_files[0]));
            parse_root_file_arg(argv[i], &root_files[root_file_count]);
            for (size_t existing = 0; existing < root_file_count; existing++) {
                if (name_eq(root_files[existing].name, root_files[root_file_count].name))
                    die("duplicate --root-file entry");
            }
            root_file_count++;
        } else if (strcmp(argv[i], "--asset") == 0) {
            if (++i >= argc)
                usage();
            assets = (AssetArg*)xrealloc(assets, (asset_count + 1) * sizeof(assets[0]));
            parse_asset_arg(argv[i], &assets[asset_count++]);
        } else if (argv[i][0] == '-') {
            usage();
        } else {
            positional[positional_count++] = argv[i];
        }
    }

    if (inspect_path) {
        if (positional_count || primary_asset_wad_path || proof_manifest_enabled || root_elf_count || root_file_count || asset_count)
            usage();
        inspect_image(inspect_path, require_real_assets, inspect_required_files, inspect_required_file_count);
        free(inspect_required_files);
        free(root_elves);
        free(root_files);
        free(assets);
        free(positional);
        return 0;
    }
    if (require_real_assets || inspect_required_file_count)
        usage();

    if (!(positional_count == 1 || positional_count == 4 || positional_count == 5 || positional_count == 6))
        usage();
    for (size_t i = 0; i < root_elf_count; i++) {
        for (size_t j = 0; j < i; j++) {
            if (name_eq(root_elves[i].name, root_elves[j].name))
                die("duplicate --root-elf FAT16 name");
        }
    }
    for (size_t i = 0; i < root_file_count; i++) {
        for (size_t j = 0; j < i; j++) {
            if (name_eq(root_files[i].name, root_files[j].name))
                die("duplicate --root-file FAT16 name");
        }
        for (size_t j = 0; j < root_elf_count; j++) {
            if (name_eq(root_files[i].name, root_elves[j].name))
                die("--root-file conflicts with --root-elf FAT16 name");
        }
    }

    Image image;
    image.size = (size_t)IMAGE_SECTORS * SECTOR_SIZE;
    image.data = (uint8_t*)xcalloc(image.size, 1);
    memset(image.fat, 0, sizeof(image.fat));

    const char* stage1 = positional_count >= 4 ? positional[1] : NULL;
    const char* stage2 = positional_count >= 4 ? positional[2] : NULL;
    const char* kernel = positional_count >= 4 ? positional[3] : NULL;
    const char* user_elf = positional_count >= 5 ? positional[4] : NULL;
    const char* legacy_payload_elf = positional_count == 6 ? positional[5] : NULL;
    if (legacy_payload_elf) {
        for (size_t i = 0; i < root_elf_count; i++) {
            if (name_eq(root_elves[i].name, LEGACY_PAYLOAD_ELF_NAME))
                die("legacy payload ELF conflicts with --root-elf");
        }
        for (size_t i = 0; i < root_file_count; i++) {
            if (name_eq(root_files[i].name, LEGACY_PAYLOAD_ELF_NAME))
                die("legacy payload ELF conflicts with --root-file");
        }
    }

    install_bootable_layout(
        &image,
        primary_asset_wad_path,
        stage1,
        stage2,
        kernel,
        user_elf,
        legacy_payload_elf,
        root_elves,
        root_elf_count,
        root_files,
        root_file_count,
        assets,
        asset_count,
        proof_manifest_enabled);

    write_file(positional[0], image.data, image.size);
    free(image.data);
    free(root_elves);
    free(root_files);
    free(inspect_required_files);
    free(assets);
    free(positional);
    return 0;
}
