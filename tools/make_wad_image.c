#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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
    MAX_KERNEL_WAD_BYTES = 0x00500000,
    MIN_OS_CREATED_FILE_CLUSTERS = 4096,
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
static const char DOOM_ELF_NAME[] = "DOOM    ELF";
static const char DOOM_WAD_NAME[] = "DOOM1   WAD";
static const char DEFAULT_CFG_NAME[] = "DEFAULT CFG";
static const char PERSISTENCE_CHECKPOINT_NAME[] = "PERSIST CHK";
static const char SAVE_REQUEST_NAME[] = "SAVEREQ CHK";
static const char LOAD_REQUEST_NAME[] = "LOADREQ CHK";
static const char STATE_DIR_NAME[] = "STATE      ";
static const char DOOMSAV_TEMPLATE_NAME[] = "DOOMSAV DSG";

static const char* const switch_textures[] = {
    "SW1BRCOM", "SW2BRCOM", "SW1BRN1", "SW2BRN1", "SW1BRN2", "SW2BRN2",
    "SW1BRNGN", "SW2BRNGN", "SW1BROWN", "SW2BROWN", "SW1COMM", "SW2COMM",
    "SW1COMP", "SW2COMP", "SW1DIRT", "SW2DIRT", "SW1EXIT", "SW2EXIT",
    "SW1GRAY", "SW2GRAY", "SW1GRAY1", "SW2GRAY1", "SW1METAL", "SW2METAL",
    "SW1PIPE", "SW2PIPE", "SW1SLAD", "SW2SLAD", "SW1STARG", "SW2STARG",
    "SW1STON1", "SW2STON1", "SW1STON2", "SW2STON2", "SW1STONE", "SW2STONE",
    "SW1STRTN", "SW2STRTN",
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

static void inspect_image(const char* path)
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
    printf("image_size=%zu\n", image.size);
    printf("partition_lba=%u\n", part_lba);
    printf("partition_sectors=%u\n", part_sectors);
    printf("root_lba=%u\n", root_lba());
    printf("data_lba=%u\n", data_lba());
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
    }
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

static void doomsav_name_for_slot(int slot, char out[11])
{
    if (slot < 0 || slot > 5)
        die("save slot must be 0..5");
    memcpy(out, DOOMSAV_TEMPLATE_NAME, 11);
    out[7] = (char)('0' + slot);
}

static void check_save_slot(const Blob* image, const Blob* baseline, const Blob* reboot_baseline, int slot, const char* description)
{
    char name[11];
    doomsav_name_for_slot(slot, name);
    FatFileInfo info = find_root_file(image, name);
    if (!info.present)
        die("required DOOMSAV slot is missing from the FAT root");
    if (info.attr & FAT_ATTR_DIRECTORY)
        die("required DOOMSAV slot is a directory");
    if (info.size < 64)
        die("required DOOMSAV slot is too small to be a real Doom save");
    if (!root_file_changed_from_baseline(image, baseline, name))
        die("required DOOMSAV slot did not change from the persistence baseline");
    if (reboot_baseline && !root_file_equal(image, reboot_baseline, name))
        die("required DOOMSAV slot changed across reboot/load proof");

    Blob data = read_root_file_blob(image, &info, "DOOMSAV slot");
    if (description) {
        size_t len = strlen(description);
        if (len > 24)
            die("required save description is longer than Doom's save title field");
        if (data.size < 24 || memcmp(data.data, description, len) != 0)
            die("required DOOMSAV slot does not contain the requested description");
    }
    if (data.size < 40 || memcmp(data.data + 24, "version ", 8) != 0)
        die("required DOOMSAV slot does not contain a Doom version header");
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
            die_path(path, "save write status did not prove DOOMSAV bytes and calls");
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
    if (status_has_literal(&status, "doomerr=") && status_hex_field(&status, "doomerr") != 0)
        die_path(path, "reboot status reported a Doom error");
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
        die_path(path, "load status did not prove DOOMSAV reads");
    if (status_has_literal(&status, "panic=") && !status_has_literal(&status, "panic=NONE"))
        die_path(path, "load status reported a panic");
    if (status_has_literal(&status, "doomerr=") && status_hex_field(&status, "doomerr") != 0)
        die_path(path, "load status reported a Doom error");
    free(status.data);
}

static int check_dynamic_fat_status(const char* path)
{
    Blob status = read_optional_text_file(path);
    if (!status.data)
        return 0;
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
        check_save_slot(
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

static int name_eq(const char lhs[11], const char rhs[11])
{
    return memcmp(lhs, rhs, 11) == 0;
}

static void reject_protected_root_name(const char name[11])
{
    if (name_eq(name, DOOM_WAD_NAME) || name_eq(name, USER_PROBE_NAME) || name_eq(name, DOOM_ELF_NAME))
        die("--root-elf tries to replace a protected boot/game entry");
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
    uint8_t things[10] = {0};

    for (size_t i = 0; i < 14 * 256 * 3; i++)
        playpal[i] = (uint8_t)(i % 64);
    for (size_t i = 0; i < 34 * 256; i++)
        colormap[i] = (uint8_t)(i & 0xff);

    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "PLAYPAL", playpal, 14 * 256 * 3);
    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "COLORMAP", colormap, 34 * 256);
    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "PNAMES", pnames.data, pnames.size);
    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "TEXTURE1", texture1.data, texture1.size);
    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "F_START", NULL, 0);
    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "F_END", NULL, 0);
    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "S_START", NULL, 0);
    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "S_END", NULL, 0);
    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "SYNTHPCH", patch.data, patch.size);
    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "D_INTRO", NULL, 0);
    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "E1M1", NULL, 0);
    add_lump(&lumps, &lump_count, &lump_cap, wad.data, &cursor, "THINGS", things, sizeof(things));
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

    const char pattern[] = "Aurora hard-path IDE FAT16 WAD fixture\n";
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
    if (wad.size > MAX_KERNEL_WAD_BYTES)
        die_path(path, "WAD exceeds kernel load limit");
    if (wad.size < 12)
        die_path(path, "too small to be a WAD");
    if (memcmp(wad.data, "IWAD", 4) != 0 && memcmp(wad.data, "PWAD", 4) != 0)
        die_path(path, "does not start with IWAD or PWAD");
    uint32_t lump_count = get_u32(wad.data, wad.size, 4);
    uint32_t directory_offset = get_u32(wad.data, wad.size, 8);
    uint64_t directory_end = (uint64_t)directory_offset + (uint64_t)lump_count * 16;
    if (directory_end > wad.size)
        die_path(path, "WAD directory is outside the file");
    return wad;
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

    memcpy(mbr + 440, "AOSD", 4);
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
    memcpy(boot + 3, "AURORA  ", 8);
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
    memcpy(boot + 43, "AURORA WAD ", 11);
    memcpy(boot + 54, "FAT16   ", 8);
    put_u16(boot, SECTOR_SIZE, 510, 0xaa55);
}

static void package_default_assets(Image* image)
{
    static const uint8_t readme[] = "vibe-os FAT16 one-level asset file\n";
    static const uint8_t map[] = "name=E1M1\nmusic=D_E1M1\n";
    uint8_t pal[32];
    char path[4][11];
    size_t count = 0;

    char state_path[1][11];
    memcpy(state_path[0], STATE_DIR_NAME, 11);
    ensure_directory_path(image, state_path, 1, FAT_ATTR_DIRECTORY);

    parse_path83("/assets/readme.txt", path, &count, 4);
    write_file_path(image, path, count, readme, sizeof(readme) - 1, FAT_ATTR_ARCHIVE | FAT_ATTR_READ_ONLY);
    parse_path83("/assets/maps/e1m1.map", path, &count, 4);
    write_file_path(image, path, count, map, sizeof(map) - 1, FAT_ATTR_ARCHIVE | FAT_ATTR_READ_ONLY);
    for (size_t i = 0; i < sizeof(pal); i++)
        pal[i] = (uint8_t)i;
    parse_path83("/assets/textures/pal0.bin", path, &count, 4);
    write_file_path(image, path, count, pal, sizeof(pal), FAT_ATTR_ARCHIVE | FAT_ATTR_READ_ONLY);
}

static void package_extra_asset(Image* image, const char* display, const char* host_path)
{
    char path[8][11];
    size_t count = 0;
    parse_path83(display, path, &count, 8);
    if (count < 2)
        die("--asset path must include a directory component");
    Blob data = read_file(host_path);
    write_file_path(image, path, count, data.data, data.size, FAT_ATTR_ARCHIVE | FAT_ATTR_READ_ONLY);
    free(data.data);
}

static void install_bootable_layout(
    Image* image,
    const char* wad_path,
    const char* stage1_path,
    const char* stage2_path,
    const char* kernel_path,
    const char* user_elf_path,
    const char* doom_elf_path,
    RootElfArg* root_elves,
    size_t root_elf_count,
    AssetArg* assets,
    size_t asset_count)
{
    if ((stage1_path || stage2_path || kernel_path) && !(stage1_path && stage2_path && kernel_path))
        die("stage1, stage2, and kernel paths must be provided together");
    if (doom_elf_path && !user_elf_path)
        die("doom ELF packaging requires a user probe ELF path");

    write_mbr_and_bpb(image, stage1_path, stage2_path, kernel_path);

    Blob wad = wad_path ? load_external_wad(wad_path) : build_generated_wad();
    uint32_t wad_clusters = 0;
    uint32_t wad_cluster = write_cluster_chain(image, wad.data, wad.size, &wad_clusters);
    if (wad_cluster != 2)
        die("DOOM1.WAD must start at cluster 2");
    (void)wad_clusters;
    write_dir_entry(root_dir(image), ROOT_ENTRIES * 32, root_next_free(image), DOOM_WAD_NAME, FAT_ATTR_ARCHIVE, wad_cluster, (uint32_t)wad.size);
    free(wad.data);

    if (user_elf_path) {
        Blob user = read_file(user_elf_path);
        write_root_file_entry(image, USER_PROBE_NAME, user.data, user.size);
        free(user.data);
        if (doom_elf_path) {
            Blob doom = read_file(doom_elf_path);
            write_root_file_entry(image, DOOM_ELF_NAME, doom.data, doom.size);
            free(doom.data);
        }
    }

    for (size_t i = 0; i < root_elf_count; i++) {
        Blob elf = read_file(root_elves[i].path);
        write_root_file_entry(image, root_elves[i].name, elf.data, elf.size);
        free(elf.data);
    }

    package_default_assets(image);
    for (size_t i = 0; i < asset_count; i++)
        package_extra_asset(image, assets[i].display, assets[i].path);

    write_empty_root_entry(image, DEFAULT_CFG_NAME);
    for (int slot = 0; slot < 6; slot++) {
        char save_name[12] = "DOOMSAV DSG";
        save_name[7] = (char)('0' + slot);
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
    die("usage: make_wad_image [--inspect IMAGE] [--wad PATH] [--root-elf NAME.ELF=PATH] [--asset IMAGE_8.3_PATH=HOST_PATH] OUTPUT [STAGE1 STAGE2 KERNEL [USER_ELF [DOOM_ELF]]]\n"
        "       make_wad_image --write-root-marker SYMBOL PAYLOAD IMAGE\n"
        "       make_wad_image --delete-root-marker SYMBOL IMAGE\n"
        "       make_wad_image --check-persistence IMAGE [--baseline-image IMAGE] [--reboot-baseline-image IMAGE] [--write-status FILE] [--save-write-status FILE] [--load-status FILE] [--reboot-status FILE] [--require-default] [--require-dynamic-fat-proof] [--require-save-slot N] [--require-save-description N=TEXT]");
}

int main(int argc, char** argv)
{
    const char* wad_path = NULL;
    const char* inspect_path = NULL;
    RootElfArg* root_elves = NULL;
    size_t root_elf_count = 0;
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
        if (strcmp(argv[i], "--wad") == 0) {
            if (++i >= argc)
                usage();
            wad_path = argv[i];
        } else if (strcmp(argv[i], "--inspect") == 0) {
            if (++i >= argc)
                usage();
            inspect_path = argv[i];
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
        if (positional_count || wad_path || root_elf_count || asset_count)
            usage();
        inspect_image(inspect_path);
        free(root_elves);
        free(assets);
        free(positional);
        return 0;
    }

    if (!(positional_count == 1 || positional_count == 4 || positional_count == 5 || positional_count == 6))
        usage();
    for (size_t i = 0; i < root_elf_count; i++) {
        for (size_t j = 0; j < i; j++) {
            if (name_eq(root_elves[i].name, root_elves[j].name))
                die("duplicate --root-elf FAT16 name");
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
    const char* doom_elf = positional_count == 6 ? positional[5] : NULL;

    install_bootable_layout(
        &image,
        wad_path,
        stage1,
        stage2,
        kernel,
        user_elf,
        doom_elf,
        root_elves,
        root_elf_count,
        assets,
        asset_count);

    write_file(positional[0], image.data, image.size);
    free(image.data);
    free(root_elves);
    free(assets);
    free(positional);
    return 0;
}
