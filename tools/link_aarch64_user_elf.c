#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum {
    ET_REL = 1,
    ET_EXEC = 2,
    EM_AARCH64 = 183,
    EV_CURRENT = 1,
    ELFCLASS64 = 2,
    ELFDATA2LSB = 1,
    PT_LOAD = 1,
    PF_X = 0x1,
    PF_W = 0x2,
    PF_R = 0x4,
    SHT_PROGBITS = 1,
    SHT_SYMTAB = 2,
    SHT_RELA = 4,
    SHT_REL = 9,
    SHT_NOBITS = 8,
    SHF_WRITE = 0x1,
    SHF_ALLOC = 0x2,
    SHF_EXECINSTR = 0x4,
    SHN_UNDEF = 0,
    SHN_ABS = 0xfff1,
    SHN_COMMON = 0xfff2,
    STB_LOCAL = 0,
    STB_GLOBAL = 1,
    STB_WEAK = 2,
    STT_NOTYPE = 0,
    STT_OBJECT = 1,
    STT_FUNC = 2,
    STT_SECTION = 3,
    R_AARCH64_NONE = 0,
    R_AARCH64_ABS64 = 257,
    R_AARCH64_ADR_PREL_LO21 = 274,
    R_AARCH64_ADR_PREL_PG_HI21 = 275,
    R_AARCH64_ADD_ABS_LO12_NC = 277,
    R_AARCH64_LDST8_ABS_LO12_NC = 278,
    R_AARCH64_JUMP26 = 282,
    R_AARCH64_CALL26 = 283,
    R_AARCH64_LDST16_ABS_LO12_NC = 284,
    R_AARCH64_LDST32_ABS_LO12_NC = 285,
    R_AARCH64_LDST64_ABS_LO12_NC = 286,
    R_AARCH64_LDST128_ABS_LO12_NC = 299,
    ELF64_EHDR_SIZE = 64,
    ELF64_PHDR_SIZE = 56,
    LOAD_OFFSET = 0x1000,
    LOAD_ALIGN = 0x1000,
    PI4_USER_BASE = 0x00e80000,
};

typedef enum {
    SEG_TEXT = 0,
    SEG_RODATA = 1,
    SEG_DATA = 2,
    SEG_COUNT = 3,
    SEG_NONE = -1
} SegmentKind;

typedef struct {
    const char* name;
    uint32_t type;
    uint64_t flags;
    uint64_t offset;
    uint64_t size;
    uint32_t link;
    uint32_t info;
    uint64_t align;
    uint64_t entsize;
    uint64_t out_off;
    uint64_t out_addr;
    SegmentKind segment;
    int placed;
} Section;

typedef struct {
    const char* name;
    uint16_t shndx;
    uint64_t value;
    uint64_t size;
    uint8_t info;
    uint64_t common_addr;
    int common_allocated;
} Symbol;

typedef struct {
    int present;
    uint64_t start;
    uint64_t file_end;
    uint64_t mem_end;
} SegmentLayout;

typedef struct {
    const char* path;
    uint8_t* data;
    size_t size;
    Section* sections;
    size_t section_count;
    Symbol* symbols;
    size_t symbol_count;
} Object;

typedef struct {
    const Object* obj;
    const Section* rel;
    const Section* target;
    size_t entry_index;
    uint64_t offset;
    uint32_t type;
    size_t sym_index;
} RelocationContext;

static void die_relocation(const RelocationContext* ctx, const char* message);
static void die_relocation_symbol(const RelocationContext* ctx, const Object* sym_obj, const Symbol* sym, const char* message);
static int symbol_defined(const Symbol* sym);
static int symbol_is_common(const Symbol* sym);
static uint8_t symbol_bind(const Symbol* sym);
static uint64_t defined_symbol_value(const Object* obj, const Symbol* sym);

typedef struct {
    Object* objects;
    size_t object_count;
    SegmentLayout segments[SEG_COUNT];
    uint64_t base;
    uint64_t image_file_size;
    uint64_t image_mem_size;
    uint64_t bss_start;
    uint64_t bss_end;
} Link;

static void die(const char* message)
{
    fprintf(stderr, "link_aarch64_user_elf: %s\n", message);
    exit(1);
}

static void die_path(const char* path, const char* message)
{
    fprintf(stderr, "link_aarch64_user_elf: %s: %s\n", path, message);
    exit(1);
}

static void* xcalloc(size_t count, size_t size)
{
    void* ptr = calloc(count, size);
    if (!ptr)
        die("out of memory");
    return ptr;
}

static uint16_t u16(const uint8_t* data, size_t size, size_t off)
{
    if (off > size || 2 > size - off)
        die("unexpected end of file");
    return (uint16_t)data[off] | ((uint16_t)data[off + 1] << 8);
}

static uint32_t u32(const uint8_t* data, size_t size, size_t off)
{
    if (off > size || 4 > size - off)
        die("unexpected end of file");
    return (uint32_t)data[off]
        | ((uint32_t)data[off + 1] << 8)
        | ((uint32_t)data[off + 2] << 16)
        | ((uint32_t)data[off + 3] << 24);
}

static uint64_t u64(const uint8_t* data, size_t size, size_t off)
{
    uint64_t lo = u32(data, size, off);
    uint64_t hi = u32(data, size, off + 4);
    return lo | (hi << 32);
}

static void put_u16(uint8_t* data, size_t size, size_t off, uint16_t value)
{
    if (off > size || 2 > size - off)
        die("write past output");
    data[off] = (uint8_t)value;
    data[off + 1] = (uint8_t)(value >> 8);
}

static void put_u32(uint8_t* data, size_t size, size_t off, uint32_t value)
{
    if (off > size || 4 > size - off)
        die("write past output");
    data[off] = (uint8_t)value;
    data[off + 1] = (uint8_t)(value >> 8);
    data[off + 2] = (uint8_t)(value >> 16);
    data[off + 3] = (uint8_t)(value >> 24);
}

static void put_u64(uint8_t* data, size_t size, size_t off, uint64_t value)
{
    put_u32(data, size, off, (uint32_t)value);
    put_u32(data, size, off + 4, (uint32_t)(value >> 32));
}

static size_t checked_size(uint64_t value)
{
    if (value > (uint64_t)SIZE_MAX)
        die("output is too large for this host");
    return (size_t)value;
}

static uint64_t align_up(uint64_t value, uint64_t alignment)
{
    if (alignment <= 1)
        return value;
    if (alignment & (alignment - 1))
        die("section alignment is not a power of two");
    if (value > UINT64_MAX - (alignment - 1))
        die("section alignment overflow");
    return (value + alignment - 1) & ~(alignment - 1);
}

static int range_fits(uint64_t off, uint64_t size, uint64_t limit)
{
    return off <= limit && size <= limit - off;
}

static uint8_t* read_file(const char* path, size_t* out_size)
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
    uint8_t* data = (uint8_t*)xcalloc((size_t)end ? (size_t)end : 1, 1);
    if (end && fread(data, 1, (size_t)end, f) != (size_t)end)
        die_path(path, "read failed");
    fclose(f);
    *out_size = (size_t)end;
    return data;
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

static int starts_with(const char* text, const char* prefix)
{
    return strncmp(text, prefix, strlen(prefix)) == 0;
}

static const char* cstr_at(const uint8_t* table, uint64_t table_size, uint32_t off)
{
    if ((uint64_t)off >= table_size)
        die("string table offset out of range");
    const char* text = (const char*)table + off;
    if (!memchr(text, 0, (size_t)(table_size - off)))
        die("unterminated string table entry");
    return text;
}

static SegmentKind classify_section(const Section* sec)
{
    if ((sec->flags & SHF_ALLOC) == 0)
        return SEG_NONE;
    if (sec->type != SHT_PROGBITS && sec->type != SHT_NOBITS)
        die("unsupported allocated section type");
    if (starts_with(sec->name, ".text"))
        return SEG_TEXT;
    if (starts_with(sec->name, ".rodata"))
        return SEG_RODATA;
    if (starts_with(sec->name, ".data") || starts_with(sec->name, ".bss"))
        return SEG_DATA;
    if (sec->flags & SHF_EXECINSTR)
        return SEG_TEXT;
    if (sec->flags & SHF_WRITE)
        return SEG_DATA;
    return SEG_RODATA;
}

static void parse_sections(Object* obj, const char* path)
{
    if (obj->size < ELF64_EHDR_SIZE || memcmp(obj->data, "\177ELF", 4) != 0)
        die_path(path, "not an ELF file");
    if (obj->data[4] != ELFCLASS64 || obj->data[5] != ELFDATA2LSB)
        die_path(path, "expected ELF64 little-endian");
    if (u16(obj->data, obj->size, 16) != ET_REL || u16(obj->data, obj->size, 18) != EM_AARCH64)
        die_path(path, "expected AArch64 relocatable ELF");

    uint64_t shoff = u64(obj->data, obj->size, 40);
    uint16_t shentsize = u16(obj->data, obj->size, 58);
    uint16_t shnum = u16(obj->data, obj->size, 60);
    uint16_t shstrndx = u16(obj->data, obj->size, 62);
    if (shentsize < 64)
        die_path(path, "section header size too small");
    if (shstrndx >= shnum)
        die_path(path, "section string table index out of range");
    if (!range_fits(shoff, (uint64_t)shentsize * shnum, obj->size))
        die_path(path, "section headers out of range");

    size_t shstr_off = (size_t)(shoff + (uint64_t)shstrndx * shentsize);
    uint64_t shstr_data_off = u64(obj->data, obj->size, shstr_off + 24);
    uint64_t shstr_size = u64(obj->data, obj->size, shstr_off + 32);
    if (!range_fits(shstr_data_off, shstr_size, obj->size))
        die_path(path, "section string table out of range");
    const uint8_t* shstr = obj->data + shstr_data_off;

    obj->section_count = shnum;
    obj->sections = (Section*)xcalloc(shnum ? shnum : 1, sizeof(obj->sections[0]));
    for (uint16_t i = 0; i < shnum; i++) {
        size_t off = (size_t)(shoff + (uint64_t)i * shentsize);
        Section* sec = &obj->sections[i];
        sec->name = cstr_at(shstr, shstr_size, u32(obj->data, obj->size, off));
        sec->type = u32(obj->data, obj->size, off + 4);
        sec->flags = u64(obj->data, obj->size, off + 8);
        sec->offset = u64(obj->data, obj->size, off + 24);
        sec->size = u64(obj->data, obj->size, off + 32);
        sec->link = u32(obj->data, obj->size, off + 40);
        sec->info = u32(obj->data, obj->size, off + 44);
        sec->align = u64(obj->data, obj->size, off + 48);
        sec->entsize = u64(obj->data, obj->size, off + 56);
        sec->segment = classify_section(sec);
        if (sec->type != SHT_NOBITS && !range_fits(sec->offset, sec->size, obj->size))
            die_path(path, "section data out of range");
    }
}

static void parse_symbols(Object* obj, const char* path)
{
    for (size_t i = 0; i < obj->section_count; i++) {
        Section* symtab = &obj->sections[i];
        if (symtab->type != SHT_SYMTAB)
            continue;
        if (symtab->link >= obj->section_count)
            die_path(path, "symbol string table link out of range");
        Section* strtab = &obj->sections[symtab->link];
        if (symtab->entsize < 24)
            die_path(path, "symbol table entry size too small");
        if (symtab->size % symtab->entsize)
            die_path(path, "symbol table size is not a multiple of entry size");
        if (!range_fits(strtab->offset, strtab->size, obj->size))
            die_path(path, "symbol string table out of range");

        const uint8_t* strings = obj->data + strtab->offset;
        obj->symbol_count = (size_t)(symtab->size / symtab->entsize);
        obj->symbols = (Symbol*)xcalloc(obj->symbol_count ? obj->symbol_count : 1, sizeof(obj->symbols[0]));
        for (size_t sym_index = 0; sym_index < obj->symbol_count; sym_index++) {
            uint64_t off = symtab->offset + (uint64_t)sym_index * symtab->entsize;
            size_t sym_off = checked_size(off);
            Symbol* sym = &obj->symbols[sym_index];
            sym->name = cstr_at(strings, strtab->size, u32(obj->data, obj->size, sym_off));
            sym->info = obj->data[sym_off + 4];
            sym->shndx = u16(obj->data, obj->size, sym_off + 6);
            sym->value = u64(obj->data, obj->size, sym_off + 8);
            sym->size = u64(obj->data, obj->size, sym_off + 16);
        }
        return;
    }
    die_path(path, "missing symbol table");
}

static void update_segment(Link* link, const Section* sec)
{
    SegmentLayout* seg = &link->segments[sec->segment];
    uint64_t end = sec->out_off + sec->size;
    if (!seg->present) {
        seg->present = 1;
        seg->start = sec->out_off;
        seg->file_end = sec->out_off;
        seg->mem_end = sec->out_off;
    }
    if (sec->type != SHT_NOBITS && end > seg->file_end)
        seg->file_end = end;
    if (end > seg->mem_end)
        seg->mem_end = end;
}

static void place_section(Link* link, Section* sec, uint64_t* cursor, int* saw_bss)
{
    uint64_t align = sec->align ? sec->align : 1;
    *cursor = align_up(*cursor, align);
    sec->out_off = *cursor;
    sec->out_addr = link->base + *cursor;
    sec->placed = 1;
    if (sec->type == SHT_NOBITS) {
        if (!*saw_bss) {
            link->bss_start = sec->out_addr;
            *saw_bss = 1;
        }
        link->bss_end = sec->out_addr + sec->size;
    } else if (*cursor + sec->size > link->image_file_size) {
        link->image_file_size = *cursor + sec->size;
    }
    update_segment(link, sec);
    *cursor += sec->size;
}

static void place_matching(Link* link, uint64_t* cursor, SegmentKind segment, int nobits, const char* exact_name, int* saw_bss)
{
    for (size_t obj_index = 0; obj_index < link->object_count; obj_index++) {
        Object* obj = &link->objects[obj_index];
        for (size_t i = 1; i < obj->section_count; i++) {
            Section* sec = &obj->sections[i];
            if (sec->placed || sec->segment != segment)
                continue;
            if ((sec->type == SHT_NOBITS) != nobits)
                continue;
            if (exact_name && strcmp(sec->name, exact_name) != 0)
                continue;
            place_section(link, sec, cursor, saw_bss);
        }
    }
}

static const Symbol* find_non_common_defined_global(const Link* link, const char* name, const Object** out_obj)
{
    const Symbol* found = NULL;
    const Object* found_obj = NULL;
    for (size_t obj_index = 0; obj_index < link->object_count; obj_index++) {
        const Object* obj = &link->objects[obj_index];
        for (size_t i = 0; i < obj->symbol_count; i++) {
            const Symbol* sym = &obj->symbols[i];
            if (!symbol_defined(sym) || symbol_is_common(sym) || !sym->name[0] || strcmp(sym->name, name) != 0)
                continue;
            if (symbol_bind(sym) == STB_LOCAL)
                continue;
            if (found && symbol_bind(found) != STB_WEAK && symbol_bind(sym) != STB_WEAK) {
                fprintf(stderr, "link_aarch64_user_elf: duplicate symbol: %s\n", name);
                exit(1);
            }
            if (!found || symbol_bind(found) == STB_WEAK) {
                found = sym;
                found_obj = obj;
            }
        }
    }
    *out_obj = found_obj;
    return found;
}

static int common_symbol_matches(const Symbol* left, const Symbol* right)
{
    if (!symbol_is_common(left) || !symbol_is_common(right))
        return 0;
    if (!left->name[0] || !right->name[0])
        return left == right;
    if (symbol_bind(left) == STB_LOCAL || symbol_bind(right) == STB_LOCAL)
        return left == right;
    return strcmp(left->name, right->name) == 0;
}

static void mark_matching_common_symbols(Link* link, Symbol* representative, uint64_t addr, uint64_t* out_size, uint64_t* out_align)
{
    uint64_t size = representative->size;
    uint64_t align = representative->value ? representative->value : 1;
    for (size_t obj_index = 0; obj_index < link->object_count; obj_index++) {
        Object* obj = &link->objects[obj_index];
        for (size_t i = 0; i < obj->symbol_count; i++) {
            Symbol* sym = &obj->symbols[i];
            if (!common_symbol_matches(representative, sym))
                continue;
            if (sym->size > size)
                size = sym->size;
            if (sym->value > align)
                align = sym->value;
        }
    }
    if (!align)
        align = 1;
    if (align & (align - 1))
        die("common symbol alignment is not a power of two");
    for (size_t obj_index = 0; obj_index < link->object_count; obj_index++) {
        Object* obj = &link->objects[obj_index];
        for (size_t i = 0; i < obj->symbol_count; i++) {
            Symbol* sym = &obj->symbols[i];
            if (!common_symbol_matches(representative, sym))
                continue;
            sym->common_addr = addr;
            sym->common_allocated = 1;
        }
    }
    *out_size = size;
    *out_align = align;
}

static void update_common_segment(Link* link, uint64_t start, uint64_t end, int* saw_bss)
{
    if (end <= start)
        return;
    if (!*saw_bss) {
        link->bss_start = link->base + start;
        *saw_bss = 1;
    }
    link->bss_end = link->base + end;
    SegmentLayout* seg = &link->segments[SEG_DATA];
    if (!seg->present) {
        seg->present = 1;
        seg->start = start;
        seg->file_end = start;
        seg->mem_end = start;
    }
    if (end > seg->mem_end)
        seg->mem_end = end;
}

static void place_common_symbols(Link* link, uint64_t* cursor, int* saw_bss)
{
    for (size_t obj_index = 0; obj_index < link->object_count; obj_index++) {
        Object* obj = &link->objects[obj_index];
        for (size_t i = 0; i < obj->symbol_count; i++) {
            Symbol* sym = &obj->symbols[i];
            if (!symbol_is_common(sym) || sym->common_allocated)
                continue;
            if (sym->name[0] && symbol_bind(sym) != STB_LOCAL) {
                const Object* real_obj = NULL;
                const Symbol* real_sym = find_non_common_defined_global(link, sym->name, &real_obj);
                if (real_sym && real_obj) {
                    uint64_t addr = defined_symbol_value(real_obj, real_sym);
                    uint64_t ignored_size = 0;
                    uint64_t ignored_align = 0;
                    mark_matching_common_symbols(link, sym, addr, &ignored_size, &ignored_align);
                    continue;
                }
            }
            uint64_t common_size = 0;
            uint64_t common_align = 0;
            mark_matching_common_symbols(link, sym, 0, &common_size, &common_align);
            *cursor = align_up(*cursor, common_align);
            uint64_t start = *cursor;
            uint64_t end = start + common_size;
            if (end < start)
                die("common symbol allocation overflow");
            mark_matching_common_symbols(link, sym, link->base + start, &common_size, &common_align);
            update_common_segment(link, start, end, saw_bss);
            *cursor = end;
        }
    }
}

static void layout_sections(Link* link)
{
    uint64_t cursor = 0;
    int saw_bss = 0;

    place_matching(link, &cursor, SEG_TEXT, 0, ".text.pi4_abi_probe.entry", &saw_bss);
    place_matching(link, &cursor, SEG_TEXT, 0, NULL, &saw_bss);
    place_matching(link, &cursor, SEG_RODATA, 0, NULL, &saw_bss);
    place_matching(link, &cursor, SEG_DATA, 0, NULL, &saw_bss);
    place_matching(link, &cursor, SEG_DATA, 1, NULL, &saw_bss);
    place_common_symbols(link, &cursor, &saw_bss);

    if (!link->segments[SEG_TEXT].present || link->segments[SEG_TEXT].file_end == link->segments[SEG_TEXT].start)
        die("missing loadable text");
    if (!saw_bss) {
        link->bss_start = link->base + cursor;
        link->bss_end = link->bss_start;
    }
    link->image_mem_size = cursor;
}

static uint8_t symbol_bind(const Symbol* sym)
{
    return sym->info >> 4;
}

static uint8_t symbol_type(const Symbol* sym)
{
    return sym->info & 0xf;
}

static int symbol_type_supported_for_relocation(const Symbol* sym)
{
    uint8_t type = symbol_type(sym);
    return type == STT_NOTYPE || type == STT_OBJECT || type == STT_FUNC || type == STT_SECTION;
}

static int symbol_bind_supported_for_relocation(const Symbol* sym)
{
    uint8_t bind = symbol_bind(sym);
    return bind == STB_LOCAL || bind == STB_GLOBAL || bind == STB_WEAK;
}

static int symbol_defined(const Symbol* sym)
{
    return sym->shndx != SHN_UNDEF;
}

static int symbol_is_common(const Symbol* sym)
{
    return sym->shndx == SHN_COMMON;
}

static uint64_t synthetic_symbol_value(const Link* link, const char* name, int* found)
{
    *found = 1;
    if (strcmp(name, "__pi4_user_image_base") == 0)
        return link->base;
    if (strcmp(name, "__pi4_user_image_end") == 0)
        return link->base + link->image_mem_size;
    if (strcmp(name, "__pi4_user_bss_start") == 0 || strcmp(name, "__bss_start") == 0)
        return link->bss_start;
    if (strcmp(name, "__pi4_user_bss_end") == 0 || strcmp(name, "__bss_end") == 0)
        return link->bss_end;
    *found = 0;
    return 0;
}

static uint64_t defined_symbol_value(const Object* obj, const Symbol* sym)
{
    if (sym->shndx == SHN_ABS)
        return sym->value;
    if (symbol_is_common(sym)) {
        if (!sym->common_allocated)
            die("common symbol was not allocated");
        return sym->common_addr;
    }
    if (sym->shndx >= obj->section_count)
        die("symbol section out of range");
    const Section* sec = &obj->sections[sym->shndx];
    if (!sec->placed)
        die("symbol is not in a loadable section");
    return sec->out_addr + sym->value;
}

static uint64_t defined_symbol_value_for_relocation(const Object* obj, const Symbol* sym, const RelocationContext* ctx)
{
    if (!symbol_bind_supported_for_relocation(sym))
        die_relocation_symbol(ctx, obj, sym, "unsupported resolved symbol binding");
    if (!symbol_type_supported_for_relocation(sym))
        die_relocation_symbol(ctx, obj, sym, "unsupported resolved symbol type");
    if (sym->shndx == SHN_ABS)
        return sym->value;
    if (symbol_is_common(sym)) {
        if (!sym->common_allocated)
            die_relocation_symbol(ctx, obj, sym, "common symbol was not allocated");
        return sym->common_addr;
    }
    if (sym->shndx >= obj->section_count)
        die_relocation_symbol(ctx, obj, sym, "symbol section index is out of range");
    const Section* sec = &obj->sections[sym->shndx];
    if (!sec->placed)
        die_relocation_symbol(ctx, obj, sym, "symbol is not in a loadable section");
    return sec->out_addr + sym->value;
}

static const Symbol* find_defined_global(const Link* link, const char* name, const Object** out_obj)
{
    const Symbol* found = NULL;
    const Object* found_obj = NULL;
    const Symbol* found_common = NULL;
    const Object* found_common_obj = NULL;
    for (size_t obj_index = 0; obj_index < link->object_count; obj_index++) {
        const Object* obj = &link->objects[obj_index];
        for (size_t i = 0; i < obj->symbol_count; i++) {
            const Symbol* sym = &obj->symbols[i];
            if (!symbol_defined(sym) || !sym->name[0] || strcmp(sym->name, name) != 0)
                continue;
            if (symbol_bind(sym) == STB_LOCAL)
                continue;
            if (symbol_is_common(sym)) {
                if (!found_common || symbol_bind(found_common) == STB_WEAK) {
                    found_common = sym;
                    found_common_obj = obj;
                }
                continue;
            }
            if (found && symbol_bind(found) != STB_WEAK && symbol_bind(sym) != STB_WEAK) {
                fprintf(stderr, "link_aarch64_user_elf: duplicate symbol: %s\n", name);
                exit(1);
            }
            if (!found || symbol_bind(found) == STB_WEAK) {
                found = sym;
                found_obj = obj;
            }
        }
    }
    if (found) {
        *out_obj = found_obj;
        return found;
    }
    *out_obj = found_common_obj;
    return found_common;
}

static uint64_t symbol_value(const Link* link, const Object* obj, size_t index, const RelocationContext* ctx)
{
    if (index >= obj->symbol_count)
        die_relocation(ctx, "relocation symbol index out of range");
    const Symbol* sym = &obj->symbols[index];
    if (!symbol_bind_supported_for_relocation(sym))
        die_relocation_symbol(ctx, obj, sym, "unsupported relocation symbol binding");
    if (!symbol_type_supported_for_relocation(sym))
        die_relocation_symbol(ctx, obj, sym, "unsupported relocation symbol type");
    if (sym->shndx == SHN_UNDEF) {
        int found = 0;
        uint64_t value = synthetic_symbol_value(link, sym->name, &found);
        if (found)
            return value;
        const Object* found_obj = NULL;
        const Symbol* found_sym = find_defined_global(link, sym->name, &found_obj);
        if (found_sym && found_obj)
            return defined_symbol_value_for_relocation(found_obj, found_sym, ctx);
        if (!sym->name[0])
            die_relocation_symbol(ctx, obj, sym, "relocation references an unnamed undefined symbol");
        die_relocation_symbol(ctx, obj, sym, "unresolved symbol");
    }
    return defined_symbol_value_for_relocation(obj, sym, ctx);
}

static uint64_t find_entry(const Link* link)
{
    const Object* crt0 = &link->objects[0];
    const Symbol* found = NULL;
    for (size_t i = 0; i < crt0->symbol_count; i++) {
        const Symbol* sym = &crt0->symbols[i];
        if (!symbol_defined(sym) || strcmp(sym->name, "_start") != 0)
            continue;
        if (symbol_bind(sym) == STB_LOCAL)
            die_path(crt0->path, "_start entry symbol must not be local");
        if (symbol_type(sym) != STT_FUNC && symbol_type(sym) != STT_NOTYPE)
            die_path(crt0->path, "_start entry symbol must be a function");
        if (sym->shndx == SHN_ABS || sym->shndx >= crt0->section_count)
            die_path(crt0->path, "_start entry symbol must be in executable text");
        const Section* sec = &crt0->sections[sym->shndx];
        if (!sec->placed || sec->segment != SEG_TEXT || (sec->flags & SHF_EXECINSTR) == 0)
            die_path(crt0->path, "_start entry symbol must be in executable text");
        if (found)
            die_path(crt0->path, "duplicate _start entry symbol");
        found = sym;
    }
    if (!found)
        die_path(crt0->path, "first input must define CRT0 _start entry symbol");
    return defined_symbol_value(crt0, found);
}

static void patch_adr(uint8_t* out, size_t out_size, uint64_t off, int64_t delta)
{
    if (!range_fits(off, 4, out_size))
        die("ADR relocation target outside output");
    if (delta < -(1LL << 20) || delta > ((1LL << 20) - 1))
        die("ADR relocation is out of +/-1 MiB range");
    size_t patch_off = checked_size(off);
    uint32_t insn = u32(out, out_size, patch_off);
    if ((insn & 0x9f000000u) != 0x10000000u)
        die("ADR relocation target is not an ADR instruction");
    uint64_t imm = (uint64_t)delta & 0x1fffff;
    insn &= ~0x60ffffe0u;
    insn |= (uint32_t)((imm & 0x3u) << 29);
    insn |= (uint32_t)(((imm >> 2) & 0x7ffffu) << 5);
    put_u32(out, out_size, patch_off, insn);
}

static void patch_adrp(uint8_t* out, size_t out_size, uint64_t off, uint64_t value, uint64_t place)
{
    uint64_t value_page = value & ~0xfffull;
    uint64_t place_page = place & ~0xfffull;
    int64_t delta = ((int64_t)value_page - (int64_t)place_page) >> 12;
    if (!range_fits(off, 4, out_size))
        die("ADRP relocation target outside output");
    if (delta < -(1LL << 20) || delta > ((1LL << 20) - 1))
        die("ADRP relocation is out of +/-4 GiB range");
    size_t patch_off = checked_size(off);
    uint32_t insn = u32(out, out_size, patch_off);
    if ((insn & 0x9f000000u) != 0x90000000u)
        die("ADRP relocation target is not an ADRP instruction");
    uint64_t imm = (uint64_t)delta & 0x1fffff;
    insn &= ~0x60ffffe0u;
    insn |= (uint32_t)((imm & 0x3u) << 29);
    insn |= (uint32_t)(((imm >> 2) & 0x7ffffu) << 5);
    put_u32(out, out_size, patch_off, insn);
}

static void patch_add_lo12(uint8_t* out, size_t out_size, uint64_t off, uint64_t value)
{
    if (!range_fits(off, 4, out_size))
        die("ADD_LO12 relocation target outside output");
    size_t patch_off = checked_size(off);
    uint32_t insn = u32(out, out_size, patch_off);
    if ((insn & 0x7f000000u) != 0x11000000u)
        die("ADD_LO12 relocation target is not an ADD-immediate instruction");
    if (insn & (1u << 22))
        die("ADD_LO12 relocation target uses a shifted immediate");
    insn &= ~(0xfffu << 10);
    insn |= (uint32_t)((value & 0xfffu) << 10);
    put_u32(out, out_size, patch_off, insn);
}

static int ldst_abs_lo12_scale(uint32_t type)
{
    switch (type) {
    case R_AARCH64_LDST8_ABS_LO12_NC:
        return 0;
    case R_AARCH64_LDST16_ABS_LO12_NC:
        return 1;
    case R_AARCH64_LDST32_ABS_LO12_NC:
        return 2;
    case R_AARCH64_LDST64_ABS_LO12_NC:
        return 3;
    case R_AARCH64_LDST128_ABS_LO12_NC:
        return 4;
    default:
        return -1;
    }
}

static void patch_ldst_abs_lo12(uint8_t* out, size_t out_size, uint64_t off, uint64_t value, unsigned scale)
{
    if (!range_fits(off, 4, out_size))
        die("LDST_LO12 relocation target outside output");
    size_t patch_off = checked_size(off);
    uint32_t insn = u32(out, out_size, patch_off);
    if ((insn & 0x3b000000u) != 0x39000000u)
        die("LDST_LO12 relocation target is not a load/store unsigned-immediate instruction");
    unsigned encoded_scale = (insn >> 30) & 0x3u;
    if (insn & (1u << 26))
        encoded_scale += ((insn >> 23) & 0x1u) << 2;
    if (encoded_scale != scale)
        die("LDST_LO12 relocation target size does not match relocation");
    if (scale && (value & ((1ull << scale) - 1)) != 0)
        die("LDST_LO12 relocation target is not aligned for access size");
    insn &= ~(0xfffu << 10);
    insn |= (uint32_t)(((value & 0xfffu) >> scale) << 10);
    put_u32(out, out_size, patch_off, insn);
}

static void patch_branch26(uint8_t* out, size_t out_size, uint64_t off, int64_t delta, uint32_t opcode)
{
    if (!range_fits(off, 4, out_size))
        die("branch relocation target outside output");
    if ((delta & 0x3) != 0)
        die("branch relocation target is not 4-byte aligned");
    int64_t imm = delta >> 2;
    if (imm < -(1LL << 25) || imm > ((1LL << 25) - 1))
        die("branch relocation is out of +/-128 MiB range");
    size_t patch_off = checked_size(off);
    uint32_t insn = u32(out, out_size, patch_off);
    if ((insn & 0xfc000000u) != opcode)
        die("branch relocation target has the wrong opcode");
    insn &= 0xfc000000u;
    insn |= (uint32_t)((uint64_t)imm & 0x03ffffffu);
    put_u32(out, out_size, patch_off, insn);
}

static const char* relocation_name(uint32_t type)
{
    switch (type) {
    case R_AARCH64_NONE:
        return "R_AARCH64_NONE";
    case R_AARCH64_ABS64:
        return "R_AARCH64_ABS64";
    case R_AARCH64_ADR_PREL_LO21:
        return "R_AARCH64_ADR_PREL_LO21";
    case R_AARCH64_ADR_PREL_PG_HI21:
        return "R_AARCH64_ADR_PREL_PG_HI21";
    case R_AARCH64_ADD_ABS_LO12_NC:
        return "R_AARCH64_ADD_ABS_LO12_NC";
    case R_AARCH64_LDST8_ABS_LO12_NC:
        return "R_AARCH64_LDST8_ABS_LO12_NC";
    case R_AARCH64_JUMP26:
        return "R_AARCH64_JUMP26";
    case R_AARCH64_CALL26:
        return "R_AARCH64_CALL26";
    case R_AARCH64_LDST16_ABS_LO12_NC:
        return "R_AARCH64_LDST16_ABS_LO12_NC";
    case R_AARCH64_LDST32_ABS_LO12_NC:
        return "R_AARCH64_LDST32_ABS_LO12_NC";
    case R_AARCH64_LDST64_ABS_LO12_NC:
        return "R_AARCH64_LDST64_ABS_LO12_NC";
    case R_AARCH64_LDST128_ABS_LO12_NC:
        return "R_AARCH64_LDST128_ABS_LO12_NC";
    default:
        return "UNKNOWN";
    }
}

static void die_relocation_section(const Object* obj, const Section* rel, const Section* target, const char* message)
{
    fprintf(stderr, "link_aarch64_user_elf: %s: %s -> %s: %s\n",
        obj->path,
        rel->name[0] ? rel->name : "<unnamed-relocations>",
        target->name[0] ? target->name : "<unnamed-target>",
        message);
    exit(1);
}

static void die_relocation(const RelocationContext* ctx, const char* message)
{
    fprintf(stderr,
        "link_aarch64_user_elf: %s: %s -> %s relocation %zu offset 0x%llx type %s(%u) symbol %zu: %s\n",
        ctx->obj->path,
        ctx->rel->name[0] ? ctx->rel->name : "<unnamed-relocations>",
        ctx->target->name[0] ? ctx->target->name : "<unnamed-target>",
        ctx->entry_index,
        (unsigned long long)ctx->offset,
        relocation_name(ctx->type),
        ctx->type,
        ctx->sym_index,
        message);
    exit(1);
}

static const char* relocation_symbol_name(const Object* obj, const Symbol* sym)
{
    if (sym->name[0])
        return sym->name;
    if (symbol_type(sym) == STT_SECTION && sym->shndx < obj->section_count)
        return obj->sections[sym->shndx].name;
    return "<unnamed>";
}

static void die_relocation_symbol(const RelocationContext* ctx, const Object* sym_obj, const Symbol* sym, const char* message)
{
    fprintf(stderr,
        "link_aarch64_user_elf: %s: %s -> %s relocation %zu offset 0x%llx type %s(%u) symbol %zu (%s): %s\n",
        ctx->obj->path,
        ctx->rel->name[0] ? ctx->rel->name : "<unnamed-relocations>",
        ctx->target->name[0] ? ctx->target->name : "<unnamed-target>",
        ctx->entry_index,
        (unsigned long long)ctx->offset,
        relocation_name(ctx->type),
        ctx->type,
        ctx->sym_index,
        relocation_symbol_name(sym_obj, sym),
        message);
    exit(1);
}

static uint64_t relocation_width(uint32_t type)
{
    switch (type) {
    case R_AARCH64_NONE:
        return 0;
    case R_AARCH64_ADR_PREL_LO21:
    case R_AARCH64_ADR_PREL_PG_HI21:
    case R_AARCH64_ADD_ABS_LO12_NC:
    case R_AARCH64_LDST8_ABS_LO12_NC:
    case R_AARCH64_LDST16_ABS_LO12_NC:
    case R_AARCH64_LDST32_ABS_LO12_NC:
    case R_AARCH64_LDST64_ABS_LO12_NC:
    case R_AARCH64_LDST128_ABS_LO12_NC:
    case R_AARCH64_JUMP26:
    case R_AARCH64_CALL26:
        return 4;
    case R_AARCH64_ABS64:
        return 8;
    default:
        return UINT64_MAX;
    }
}

static void apply_relocations(const Link* link, const Object* obj, uint8_t* out, size_t out_size)
{
    for (size_t rel_index = 0; rel_index < obj->section_count; rel_index++) {
        const Section* rel = &obj->sections[rel_index];
        if (rel->type != SHT_RELA && rel->type != SHT_REL)
            continue;
        if (rel->info >= obj->section_count)
            die("relocation target section out of range");
        if (rel->link >= obj->section_count || obj->sections[rel->link].type != SHT_SYMTAB)
            die("RELA section does not link to the symbol table");
        const Section* target = &obj->sections[rel->info];
        if (!target->placed)
            continue;
        if (rel->type == SHT_REL)
            die_relocation_section(obj, rel, target, "REL relocation sections are unsupported; AArch64 user objects must use RELA");
        if (target->type == SHT_NOBITS)
            die("cannot relocate into NOBITS section");
        if (rel->entsize != 24)
            die("unsupported RELA entry size");
        if (rel->size % 24)
            die("RELA section size is not a multiple of entry size");
        size_t count = (size_t)(rel->size / 24);
        for (size_t i = 0; i < count; i++) {
            uint64_t off = rel->offset + (uint64_t)i * 24;
            uint64_t r_offset = u64(obj->data, obj->size, checked_size(off));
            uint64_t r_info = u64(obj->data, obj->size, checked_size(off + 8));
            int64_t addend = (int64_t)u64(obj->data, obj->size, checked_size(off + 16));
            uint32_t type = (uint32_t)r_info;
            size_t sym_index = (size_t)(r_info >> 32);
            RelocationContext ctx;
            ctx.obj = obj;
            ctx.rel = rel;
            ctx.target = target;
            ctx.entry_index = i;
            ctx.offset = r_offset;
            ctx.type = type;
            ctx.sym_index = sym_index;
            uint64_t width = relocation_width(type);
            if (width == UINT64_MAX)
                die_relocation(&ctx, "unsupported AArch64 relocation");
            if (type == R_AARCH64_NONE)
                continue;
            if (!range_fits(r_offset, width, target->size))
                die_relocation(&ctx, "relocation target range is outside section");
            uint64_t value = symbol_value(link, obj, sym_index, &ctx) + (uint64_t)addend;
            uint64_t place = target->out_addr + r_offset;
            uint64_t patch_off = (uint64_t)LOAD_OFFSET + target->out_off + r_offset;
            int ldst_scale = ldst_abs_lo12_scale(type);
            if (type == R_AARCH64_ADR_PREL_LO21) {
                patch_adr(out, out_size, patch_off, (int64_t)value - (int64_t)place);
            } else if (type == R_AARCH64_ADR_PREL_PG_HI21) {
                patch_adrp(out, out_size, patch_off, value, place);
            } else if (type == R_AARCH64_ADD_ABS_LO12_NC) {
                patch_add_lo12(out, out_size, patch_off, value);
            } else if (ldst_scale >= 0) {
                patch_ldst_abs_lo12(out, out_size, patch_off, value, (unsigned)ldst_scale);
            } else if (type == R_AARCH64_CALL26) {
                patch_branch26(out, out_size, patch_off, (int64_t)value - (int64_t)place, 0x94000000u);
            } else if (type == R_AARCH64_JUMP26) {
                patch_branch26(out, out_size, patch_off, (int64_t)value - (int64_t)place, 0x14000000u);
            } else if (type == R_AARCH64_ABS64) {
                if (!range_fits(patch_off, 8, out_size))
                    die("ABS64 relocation target outside output");
                put_u64(out, out_size, checked_size(patch_off), value);
            }
        }
    }
}

static uint16_t collect_segments(const Link* link, SegmentKind out_segments[SEG_COUNT])
{
    uint16_t count = 0;
    for (int i = 0; i < SEG_COUNT; i++) {
        const SegmentLayout* seg = &link->segments[i];
        if (seg->present && seg->mem_end > seg->start)
            out_segments[count++] = (SegmentKind)i;
    }
    return count;
}

static uint32_t phdr_flags(SegmentKind segment)
{
    if (segment == SEG_TEXT)
        return PF_R | PF_X;
    if (segment == SEG_RODATA)
        return PF_R;
    return PF_R | PF_W;
}

static void write_elf_header(uint8_t* out, size_t out_size, uint64_t entry, uint16_t phnum)
{
    if (ELF64_EHDR_SIZE + (uint64_t)phnum * ELF64_PHDR_SIZE > LOAD_OFFSET)
        die("program headers exceed reserved ELF header area");
    out[0] = 0x7f;
    out[1] = 'E';
    out[2] = 'L';
    out[3] = 'F';
    out[4] = ELFCLASS64;
    out[5] = ELFDATA2LSB;
    out[6] = EV_CURRENT;
    put_u16(out, out_size, 16, ET_EXEC);
    put_u16(out, out_size, 18, EM_AARCH64);
    put_u32(out, out_size, 20, EV_CURRENT);
    put_u64(out, out_size, 24, entry);
    put_u64(out, out_size, 32, ELF64_EHDR_SIZE);
    put_u64(out, out_size, 40, 0);
    put_u32(out, out_size, 48, 0);
    put_u16(out, out_size, 52, ELF64_EHDR_SIZE);
    put_u16(out, out_size, 54, ELF64_PHDR_SIZE);
    put_u16(out, out_size, 56, phnum);
    put_u16(out, out_size, 58, 0);
    put_u16(out, out_size, 60, 0);
    put_u16(out, out_size, 62, SHN_UNDEF);
}

static void write_program_header(uint8_t* out, size_t out_size, size_t index, const Link* link, SegmentKind segment)
{
    const SegmentLayout* seg = &link->segments[segment];
    size_t off = ELF64_EHDR_SIZE + index * ELF64_PHDR_SIZE;
    uint64_t file_off = (uint64_t)LOAD_OFFSET + seg->start;
    uint64_t vaddr = link->base + seg->start;
    uint64_t filesz = seg->file_end - seg->start;
    uint64_t memsz = seg->mem_end - seg->start;
    put_u32(out, out_size, off, PT_LOAD);
    put_u32(out, out_size, off + 4, phdr_flags(segment));
    put_u64(out, out_size, off + 8, file_off);
    put_u64(out, out_size, off + 16, vaddr);
    put_u64(out, out_size, off + 24, vaddr);
    put_u64(out, out_size, off + 32, filesz);
    put_u64(out, out_size, off + 40, memsz);
    put_u64(out, out_size, off + 48, LOAD_ALIGN);
}

static uint8_t* build_elf(Link* link, size_t* out_size)
{
    if (!link->image_file_size)
        die("no allocated file-backed sections");
    uint64_t total_size = (uint64_t)LOAD_OFFSET + link->image_file_size;
    uint8_t* out = (uint8_t*)xcalloc(checked_size(total_size), 1);
    *out_size = checked_size(total_size);

    SegmentKind phdr_segments[SEG_COUNT];
    uint16_t phnum = collect_segments(link, phdr_segments);
    write_elf_header(out, *out_size, find_entry(link), phnum);
    for (uint16_t i = 0; i < phnum; i++)
        write_program_header(out, *out_size, i, link, phdr_segments[i]);

    for (size_t obj_index = 0; obj_index < link->object_count; obj_index++) {
        const Object* obj = &link->objects[obj_index];
        for (size_t i = 1; i < obj->section_count; i++) {
            const Section* sec = &obj->sections[i];
            if (!sec->placed || sec->type == SHT_NOBITS || !sec->size)
                continue;
            uint64_t out_off = (uint64_t)LOAD_OFFSET + sec->out_off;
            if (out_off + sec->size > total_size)
                die("section output range is outside image");
            memcpy(out + checked_size(out_off), obj->data + sec->offset, checked_size(sec->size));
        }
    }
    for (size_t obj_index = 0; obj_index < link->object_count; obj_index++)
        apply_relocations(link, &link->objects[obj_index], out, *out_size);
    return out;
}

static uint64_t parse_u64_arg(const char* text)
{
    char* end = NULL;
    errno = 0;
    unsigned long long value = strtoull(text, &end, 0);
    if (errno || !end || *end) {
        fprintf(stderr, "link_aarch64_user_elf: invalid address: %s\n", text);
        exit(1);
    }
    return (uint64_t)value;
}

int main(int argc, char** argv)
{
    const char* output = NULL;
    const char** inputs = (const char**)xcalloc((size_t)argc, sizeof(inputs[0]));
    size_t input_count = 0;
    uint64_t base = PI4_USER_BASE;

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-o") == 0) {
            if (++i >= argc)
                die("-o requires an output path");
            output = argv[i];
        } else if (strcmp(argv[i], "--base") == 0) {
            if (++i >= argc)
                die("--base requires an address");
            base = parse_u64_arg(argv[i]);
        } else if (argv[i][0] == '-') {
            fprintf(stderr, "link_aarch64_user_elf: unknown option %s\n", argv[i]);
            return 1;
        } else {
            inputs[input_count++] = argv[i];
        }
    }

    if (!output || !input_count) {
        fprintf(stderr, "usage: link_aarch64_user_elf -o OUTPUT [--base 0xADDR] INPUT.o [INPUT.o ...]\n");
        free(inputs);
        return 1;
    }

    Link link;
    memset(&link, 0, sizeof(link));
    link.base = base;
    link.object_count = input_count;
    link.objects = (Object*)xcalloc(input_count, sizeof(link.objects[0]));
    for (size_t i = 0; i < input_count; i++) {
        Object* obj = &link.objects[i];
        obj->path = inputs[i];
        obj->data = read_file(inputs[i], &obj->size);
        parse_sections(obj, inputs[i]);
        parse_symbols(obj, inputs[i]);
    }
    layout_sections(&link);

    size_t elf_size = 0;
    uint8_t* elf = build_elf(&link, &elf_size);
    write_file(output, elf, elf_size);

    free(elf);
    for (size_t i = 0; i < input_count; i++) {
        free(link.objects[i].symbols);
        free(link.objects[i].sections);
        free(link.objects[i].data);
    }
    free(link.objects);
    free(inputs);
    return 0;
}
