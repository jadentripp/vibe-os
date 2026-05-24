#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum {
    SHT_SYMTAB = 2,
    SHT_NOBITS = 8,
    SHT_REL = 9,
    SHF_WRITE = 0x1,
    SHF_ALLOC = 0x2,
    SHF_EXECINSTR = 0x4,
    SHN_UNDEF = 0,
    SHN_COMMON = 0xfff2,
    R_386_32 = 1,
    R_386_PC32 = 2,
    ELF_HEADER_SIZE = 52,
    PROGRAM_HEADER_SIZE = 32,
    SEGMENT_OFFSET = 0x1000,
    PAGE_SIZE = 0x1000,
    PF_X = 0x1,
    PF_W = 0x2,
    PF_R = 0x4,
};

typedef struct ObjectFile ObjectFile;

typedef struct {
    ObjectFile* obj;
    uint32_t index;
    char* name;
    uint32_t type;
    uint32_t flags;
    uint32_t offset;
    uint32_t size;
    uint32_t align;
    uint32_t link;
    uint32_t info;
    uint32_t entsize;
    uint32_t out_addr;
    uint32_t mem_off;
    int segment;
} Section;

typedef struct {
    ObjectFile* obj;
    uint32_t index;
    char* name;
    uint32_t value;
    uint32_t size;
    uint8_t info;
    uint16_t shndx;
} Symbol;

struct ObjectFile {
    char* path;
    uint8_t* data;
    size_t size;
    Section* sections;
    size_t section_count;
    Symbol* symbols;
    size_t symbol_count;
    Section** rel_sections;
    size_t rel_count;
};

typedef struct {
    uint32_t flags;
    uint32_t mem_off;
    uint32_t vaddr;
    uint32_t filesz;
    uint32_t memsz;
    uint32_t offset;
} Segment;

typedef struct {
    Section** items;
    size_t count;
    size_t cap;
} SectionVec;

typedef struct {
    Segment* items;
    size_t count;
    size_t cap;
} SegmentVec;

typedef struct {
    char* name;
    Symbol* symbol;
} GlobalSymbol;

typedef struct {
    GlobalSymbol* items;
    size_t count;
    size_t cap;
} GlobalVec;

typedef struct {
    uint32_t address;
    uint32_t size;
    const char* type;
    const char* bind;
    const char* section;
    const char* object;
    const char* symbol;
} MapRow;

typedef struct {
    MapRow* items;
    size_t count;
    size_t cap;
} MapVec;

static void die(const char* message)
{
    fprintf(stderr, "link_elf32: %s\n", message);
    exit(1);
}

static void die_path(const char* path, const char* message)
{
    fprintf(stderr, "link_elf32: %s: %s\n", path, message);
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

static char* xstrdup0(const char* text)
{
    size_t len = strlen(text);
    char* out = (char*)xcalloc(len + 1, 1);
    memcpy(out, text, len);
    return out;
}

static char* xstrdup_range(const uint8_t* data, size_t data_size, size_t offset)
{
    size_t end = offset;
    if (offset >= data_size)
        return xstrdup0("");
    while (end < data_size && data[end] != 0)
        end++;
    char* out = (char*)xcalloc(end - offset + 1, 1);
    memcpy(out, data + offset, end - offset);
    return out;
}

static uint32_t align_up(uint32_t value, uint32_t alignment)
{
    if (alignment <= 1)
        return value;
    return (value + alignment - 1) & ~(alignment - 1);
}

static uint16_t u16(const uint8_t* data, size_t size, size_t offset)
{
    if (offset + 2 > size)
        die("unexpected end of file");
    return (uint16_t)data[offset] | ((uint16_t)data[offset + 1] << 8);
}

static uint32_t u32(const uint8_t* data, size_t size, size_t offset)
{
    if (offset + 4 > size)
        die("unexpected end of file");
    return (uint32_t)data[offset]
        | ((uint32_t)data[offset + 1] << 8)
        | ((uint32_t)data[offset + 2] << 16)
        | ((uint32_t)data[offset + 3] << 24);
}

static uint32_t mem_u32(const uint8_t* data, size_t size, size_t offset)
{
    return u32(data, size, offset);
}

static void put_u16(uint8_t* data, size_t size, size_t offset, uint16_t value)
{
    if (offset + 2 > size)
        die("write past output");
    data[offset] = (uint8_t)value;
    data[offset + 1] = (uint8_t)(value >> 8);
}

static void put_u32(uint8_t* data, size_t size, size_t offset, uint32_t value)
{
    if (offset + 4 > size)
        die("write past output");
    data[offset] = (uint8_t)value;
    data[offset + 1] = (uint8_t)(value >> 8);
    data[offset + 2] = (uint8_t)(value >> 16);
    data[offset + 3] = (uint8_t)(value >> 24);
}

static void vec_sections_push(SectionVec* vec, Section* section)
{
    if (vec->count == vec->cap) {
        vec->cap = vec->cap ? vec->cap * 2 : 32;
        vec->items = (Section**)xrealloc(vec->items, vec->cap * sizeof(vec->items[0]));
    }
    vec->items[vec->count++] = section;
}

static void vec_segments_push(SegmentVec* vec, Segment segment)
{
    if (vec->count == vec->cap) {
        vec->cap = vec->cap ? vec->cap * 2 : 8;
        vec->items = (Segment*)xrealloc(vec->items, vec->cap * sizeof(vec->items[0]));
    }
    vec->items[vec->count++] = segment;
}

static void vec_globals_push(GlobalVec* vec, const char* name, Symbol* symbol)
{
    if (vec->count == vec->cap) {
        vec->cap = vec->cap ? vec->cap * 2 : 128;
        vec->items = (GlobalSymbol*)xrealloc(vec->items, vec->cap * sizeof(vec->items[0]));
    }
    vec->items[vec->count].name = xstrdup0(name);
    vec->items[vec->count].symbol = symbol;
    vec->count++;
}

static void vec_map_push(MapVec* vec, MapRow row)
{
    if (vec->count == vec->cap) {
        vec->cap = vec->cap ? vec->cap * 2 : 1024;
        vec->items = (MapRow*)xrealloc(vec->items, vec->cap * sizeof(vec->items[0]));
    }
    vec->items[vec->count++] = row;
}

static uint8_t symbol_bind(const Symbol* sym)
{
    return sym->info >> 4;
}

static uint8_t symbol_type(const Symbol* sym)
{
    return sym->info & 0x0f;
}

static int symbol_defined(const Symbol* sym)
{
    return sym->shndx != SHN_UNDEF;
}

static int symbol_is_common(const Symbol* sym)
{
    if (sym->shndx >= sym->obj->section_count)
        return sym->shndx == SHN_COMMON;
    return strcmp(sym->obj->sections[sym->shndx].name, ".common") == 0;
}

static const char* bind_name(const Symbol* sym)
{
    switch (symbol_bind(sym)) {
    case 0:
        return "LOCAL";
    case 1:
        return "GLOBAL";
    case 2:
        return "WEAK";
    default:
        return "BIND";
    }
}

static const char* type_name(const Symbol* sym)
{
    switch (symbol_type(sym)) {
    case 0:
        return "NOTYPE";
    case 1:
        return "OBJECT";
    case 2:
        return "FUNC";
    case 3:
        return "SECTION";
    case 4:
        return "FILE";
    default:
        return "TYPE";
    }
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

static void parse_symbols(ObjectFile* obj, Section* symtab)
{
    if (symtab->link >= obj->section_count)
        die_path(obj->path, "symbol table string link out of range");
    Section* strtab = &obj->sections[symtab->link];
    if (!symtab->entsize)
        die_path(obj->path, "symbol table has zero entry size");
    if (symtab->offset + symtab->size > obj->size || strtab->offset + strtab->size > obj->size)
        die_path(obj->path, "symbol table out of range");

    obj->symbol_count = symtab->size / symtab->entsize;
    obj->symbols = (Symbol*)xcalloc(obj->symbol_count, sizeof(Symbol));
    for (size_t index = 0; index < obj->symbol_count; index++) {
        size_t off = symtab->offset + index * symtab->entsize;
        Symbol* sym = &obj->symbols[index];
        sym->obj = obj;
        sym->index = (uint32_t)index;
        sym->name = xstrdup_range(obj->data + strtab->offset, strtab->size, u32(obj->data, obj->size, off));
        sym->value = u32(obj->data, obj->size, off + 4);
        sym->size = u32(obj->data, obj->size, off + 8);
        sym->info = obj->data[off + 12];
        sym->shndx = u16(obj->data, obj->size, off + 14);
    }
}

static void assign_common_symbols(ObjectFile* obj)
{
    uint32_t cursor = 0;
    uint32_t max_align = 1;
    int has_common = 0;

    for (size_t index = 0; index < obj->symbol_count; index++) {
        Symbol* sym = &obj->symbols[index];
        if (sym->shndx != SHN_COMMON || !sym->size)
            continue;
        uint32_t align = sym->value ? sym->value : 1;
        cursor = align_up(cursor, align);
        sym->value = cursor;
        cursor += sym->size;
        if (align > max_align)
            max_align = align;
        has_common = 1;
    }

    if (!has_common)
        return;

    uint32_t index = (uint32_t)obj->section_count;
    obj->sections = (Section*)xrealloc(obj->sections, (obj->section_count + 1) * sizeof(obj->sections[0]));
    Section* sec = &obj->sections[index];
    memset(sec, 0, sizeof(*sec));
    sec->obj = obj;
    sec->index = index;
    sec->name = xstrdup0(".common");
    sec->type = SHT_NOBITS;
    sec->flags = SHF_ALLOC | SHF_WRITE;
    sec->size = cursor;
    sec->align = max_align;
    sec->segment = -1;
    obj->section_count++;

    for (size_t sym_index = 0; sym_index < obj->symbol_count; sym_index++) {
        Symbol* sym = &obj->symbols[sym_index];
        if (sym->shndx == SHN_COMMON)
            sym->shndx = (uint16_t)index;
    }
}

static void parse_object(ObjectFile* obj, const char* path)
{
    memset(obj, 0, sizeof(*obj));
    obj->path = xstrdup0(path);
    obj->data = read_file(path, &obj->size);

    if (obj->size < ELF_HEADER_SIZE || memcmp(obj->data, "\177ELF", 4) != 0)
        die_path(path, "not an ELF file");
    if (obj->data[4] != 1 || obj->data[5] != 1)
        die_path(path, "expected ELF32 little-endian");
    if (u16(obj->data, obj->size, 16) != 1 || u16(obj->data, obj->size, 18) != 3)
        die_path(path, "expected i386 relocatable ELF");

    uint32_t shoff = u32(obj->data, obj->size, 32);
    uint16_t shentsize = u16(obj->data, obj->size, 46);
    uint16_t shnum = u16(obj->data, obj->size, 48);
    uint16_t shstrndx = u16(obj->data, obj->size, 50);
    if (shentsize < 40)
        die_path(path, "section header size too small");
    if ((uint64_t)shoff + (uint64_t)shentsize * shnum > obj->size)
        die_path(path, "section headers out of range");

    obj->section_count = shnum;
    obj->sections = (Section*)xcalloc(shnum ? shnum : 1, sizeof(Section));

    const uint8_t* shstr = NULL;
    size_t shstr_size = 0;
    if (shstrndx != SHN_UNDEF && shstrndx < shnum) {
        size_t off = shoff + (size_t)shstrndx * shentsize;
        uint32_t str_off = u32(obj->data, obj->size, off + 16);
        uint32_t str_size = u32(obj->data, obj->size, off + 20);
        if ((uint64_t)str_off + str_size > obj->size)
            die_path(path, "section string table out of range");
        shstr = obj->data + str_off;
        shstr_size = str_size;
    }

    for (uint16_t index = 0; index < shnum; index++) {
        size_t off = shoff + (size_t)index * shentsize;
        Section* sec = &obj->sections[index];
        uint32_t sh_name = u32(obj->data, obj->size, off);
        sec->obj = obj;
        sec->index = index;
        sec->name = shstr ? xstrdup_range(shstr, shstr_size, sh_name) : xstrdup0("");
        sec->type = u32(obj->data, obj->size, off + 4);
        sec->flags = u32(obj->data, obj->size, off + 8);
        sec->offset = u32(obj->data, obj->size, off + 16);
        sec->size = u32(obj->data, obj->size, off + 20);
        sec->link = u32(obj->data, obj->size, off + 24);
        sec->info = u32(obj->data, obj->size, off + 28);
        sec->align = u32(obj->data, obj->size, off + 32);
        sec->entsize = u32(obj->data, obj->size, off + 36);
        sec->segment = -1;
        if (sec->type != SHT_NOBITS && (uint64_t)sec->offset + sec->size > obj->size)
            die_path(path, "section data out of range");
    }

    for (size_t index = 1; index < obj->section_count; index++) {
        Section* sec = &obj->sections[index];
        if (sec->type == SHT_SYMTAB)
            parse_symbols(obj, sec);
    }

    assign_common_symbols(obj);

    for (size_t index = 1; index < obj->section_count; index++) {
        Section* sec = &obj->sections[index];
        if (sec->type == SHT_REL) {
            obj->rel_sections = (Section**)xrealloc(obj->rel_sections, (obj->rel_count + 1) * sizeof(obj->rel_sections[0]));
            obj->rel_sections[obj->rel_count++] = sec;
        }
    }
}

static uint32_t symbol_address(Symbol* sym);

static Symbol* find_global(GlobalVec* globals, const char* name)
{
    for (size_t i = 0; i < globals->count; i++) {
        if (strcmp(globals->items[i].name, name) == 0)
            return globals->items[i].symbol;
    }
    return NULL;
}

static GlobalSymbol* find_global_slot(GlobalVec* globals, const char* name)
{
    for (size_t i = 0; i < globals->count; i++) {
        if (strcmp(globals->items[i].name, name) == 0)
            return &globals->items[i];
    }
    return NULL;
}

static void collect_global_symbols(ObjectFile* objects, size_t object_count, GlobalVec* globals)
{
    for (size_t obj_index = 0; obj_index < object_count; obj_index++) {
        ObjectFile* obj = &objects[obj_index];
        for (size_t sym_index = 0; sym_index < obj->symbol_count; sym_index++) {
            Symbol* sym = &obj->symbols[sym_index];
            if (!sym->name[0] || !symbol_defined(sym) || symbol_bind(sym) == 0)
                continue;
            GlobalSymbol* existing_slot = find_global_slot(globals, sym->name);
            if (existing_slot) {
                int existing_common = symbol_is_common(existing_slot->symbol);
                int sym_common = symbol_is_common(sym);
                if (existing_common && sym_common)
                    continue;
                if (sym_common)
                    continue;
                if (existing_common) {
                    existing_slot->symbol = sym;
                    continue;
                }
                fprintf(stderr, "link_elf32: duplicate symbol: %s\n", sym->name);
                exit(1);
            }
            vec_globals_push(globals, sym->name, sym);
        }
    }
}

static uint32_t symbol_address(Symbol* sym)
{
    if (!symbol_defined(sym)) {
        fprintf(stderr, "link_elf32: undefined symbol has no address: %s\n", sym->name);
        exit(1);
    }
    if (sym->shndx >= sym->obj->section_count)
        die_path(sym->obj->path, "symbol section out of range");
    Section* sec = &sym->obj->sections[sym->shndx];
    if (!(sec->flags & SHF_ALLOC)) {
        fprintf(stderr, "link_elf32: symbol is not in an allocated section: %s\n", sym->name);
        exit(1);
    }
    return sec->out_addr + sym->value;
}

static uint32_t relocation_symbol_value(Symbol* sym, GlobalVec* globals)
{
    if (sym->shndx == SHN_UNDEF) {
        Symbol* global = find_global(globals, sym->name);
        if (!global) {
            fprintf(stderr, "link_elf32: unresolved symbol: %s\n", sym->name);
            exit(1);
        }
        return symbol_address(global);
    }
    if (symbol_is_common(sym)) {
        Symbol* global = find_global(globals, sym->name);
        if (global)
            return symbol_address(global);
    }
    return symbol_address(sym);
}

static void layout_group(
    ObjectFile* objects,
    size_t object_count,
    int flags,
    int group_kind,
    uint32_t base,
    uint32_t* cursor,
    SectionVec* ordered,
    SegmentVec* segments)
{
    SectionVec grouped = {0};
    for (size_t obj_index = 0; obj_index < object_count; obj_index++) {
        ObjectFile* obj = &objects[obj_index];
        for (size_t sec_index = 1; sec_index < obj->section_count; sec_index++) {
            Section* sec = &obj->sections[sec_index];
            if (!(sec->flags & SHF_ALLOC))
                continue;
            int exec = !!(sec->flags & SHF_EXECINSTR);
            int write = !!(sec->flags & SHF_WRITE);
            int match = (group_kind == 0 && exec)
                || (group_kind == 1 && !write && !exec)
                || (group_kind == 2 && write);
            if (match)
                vec_sections_push(&grouped, sec);
        }
    }
    if (!grouped.count) {
        free(grouped.items);
        return;
    }

    *cursor = align_up(*cursor, PAGE_SIZE);
    uint32_t segment_start = *cursor;
    uint32_t file_size = 0;
    size_t segment_index = segments->count;
    for (size_t i = 0; i < grouped.count; i++) {
        Section* sec = grouped.items[i];
        uint32_t align = sec->align ? sec->align : 1;
        *cursor = align_up(*cursor, align);
        sec->mem_off = *cursor;
        sec->out_addr = base + *cursor;
        sec->segment = (int)segment_index;
        vec_sections_push(ordered, sec);
        *cursor += sec->size;
        if (sec->type != SHT_NOBITS)
            file_size = *cursor - segment_start;
    }

    Segment segment;
    memset(&segment, 0, sizeof(segment));
    segment.flags = (uint32_t)flags;
    segment.mem_off = segment_start;
    segment.vaddr = base + segment_start;
    segment.filesz = file_size;
    segment.memsz = *cursor - segment_start;
    vec_segments_push(segments, segment);
    free(grouped.items);
}

static void layout_sections(
    ObjectFile* objects,
    size_t object_count,
    uint32_t base,
    SectionVec* ordered,
    SegmentVec* segments,
    uint32_t* mem_size)
{
    uint32_t cursor = 0;
    layout_group(objects, object_count, PF_R | PF_X, 0, base, &cursor, ordered, segments);
    layout_group(objects, object_count, PF_R, 1, base, &cursor, ordered, segments);
    layout_group(objects, object_count, PF_R | PF_W, 2, base, &cursor, ordered, segments);
    *mem_size = cursor;
}

static void apply_relocations(ObjectFile* objects, size_t object_count, uint8_t* memory, size_t memory_size, GlobalVec* globals)
{
    for (size_t obj_index = 0; obj_index < object_count; obj_index++) {
        ObjectFile* obj = &objects[obj_index];
        for (size_t rel_index = 0; rel_index < obj->rel_count; rel_index++) {
            Section* rel = obj->rel_sections[rel_index];
            if (rel->info >= obj->section_count)
                die_path(obj->path, "relocation target section out of range");
            Section* target = &obj->sections[rel->info];
            if (!(target->flags & SHF_ALLOC))
                continue;
            if (rel->entsize && rel->entsize != 8)
                die_path(obj->path, "unsupported relocation entry size");
            size_t count = rel->size / 8;
            for (size_t index = 0; index < count; index++) {
                size_t off = rel->offset + index * 8;
                uint32_t rel_offset = u32(obj->data, obj->size, off);
                uint32_t rel_info = u32(obj->data, obj->size, off + 4);
                uint32_t sym_index = rel_info >> 8;
                uint32_t rel_type = rel_info & 0xff;
                if (sym_index >= obj->symbol_count)
                    die_path(obj->path, "relocation symbol out of range");
                if (rel_offset + 4 > target->size)
                    die_path(obj->path, "relocation offset out of target range");
                Symbol* sym = &obj->symbols[sym_index];
                size_t patch_off = (size_t)target->mem_off + rel_offset;
                uint32_t place = target->out_addr + rel_offset;
                uint32_t addend = mem_u32(memory, memory_size, patch_off);
                uint32_t value = relocation_symbol_value(sym, globals);
                if (rel_type == R_386_32)
                    put_u32(memory, memory_size, patch_off, value + addend);
                else if (rel_type == R_386_PC32)
                    put_u32(memory, memory_size, patch_off, value + addend - place);
                else {
                    fprintf(stderr, "link_elf32: %s: unsupported relocation type %u\n", obj->path, rel_type);
                    exit(1);
                }
            }
        }
    }
}

static int map_row_cmp(const void* a, const void* b)
{
    const MapRow* lhs = (const MapRow*)a;
    const MapRow* rhs = (const MapRow*)b;
    if (lhs->address != rhs->address)
        return lhs->address < rhs->address ? -1 : 1;
    int name_cmp = strcmp(lhs->symbol, rhs->symbol);
    if (name_cmp)
        return name_cmp;
    return strcmp(lhs->object, rhs->object);
}

static void write_symbol_map(const char* path, ObjectFile* objects, size_t object_count)
{
    MapVec rows = {0};
    for (size_t obj_index = 0; obj_index < object_count; obj_index++) {
        ObjectFile* obj = &objects[obj_index];
        for (size_t sym_index = 0; sym_index < obj->symbol_count; sym_index++) {
            Symbol* sym = &obj->symbols[sym_index];
            if (!sym->name[0] || !symbol_defined(sym) || sym->shndx >= obj->section_count)
                continue;
            Section* sec = &obj->sections[sym->shndx];
            if (!(sec->flags & SHF_ALLOC))
                continue;
            MapRow row;
            row.address = symbol_address(sym);
            row.size = sym->size;
            row.type = type_name(sym);
            row.bind = bind_name(sym);
            row.section = sec->name;
            row.object = obj->path;
            row.symbol = sym->name;
            vec_map_push(&rows, row);
        }
    }
    qsort(rows.items, rows.count, sizeof(rows.items[0]), map_row_cmp);

    FILE* f = fopen(path, "w");
    if (!f)
        die_path(path, strerror(errno));
    fprintf(f, "# vibe-os-symbol-map-v1\n");
    fprintf(f, "# address\tsize\ttype\tbind\tsection\tobject\tsymbol\n");
    for (size_t i = 0; i < rows.count; i++) {
        MapRow* row = &rows.items[i];
        fprintf(
            f,
            "%08X\t%08X\t%s\t%s\t%s\t%s\t%s\n",
            row->address,
            row->size,
            row->type,
            row->bind,
            row->section,
            row->object,
            row->symbol);
    }
    fclose(f);
    free(rows.items);
}

static uint8_t* build_executable(
    ObjectFile* objects,
    size_t object_count,
    uint32_t base,
    size_t* out_size)
{
    SectionVec ordered = {0};
    SegmentVec segments = {0};
    uint32_t mem_size = 0;
    layout_sections(objects, object_count, base, &ordered, &segments, &mem_size);
    if (!segments.count)
        die("no allocated sections");

    uint8_t* memory = (uint8_t*)xcalloc(mem_size ? mem_size : 1, 1);
    for (size_t i = 0; i < ordered.count; i++) {
        Section* sec = ordered.items[i];
        if (sec->type == SHT_NOBITS)
            continue;
        memcpy(memory + sec->mem_off, sec->obj->data + sec->offset, sec->size);
    }

    GlobalVec globals = {0};
    collect_global_symbols(objects, object_count, &globals);
    Symbol* start = find_global(&globals, "start");
    if (!start)
        die("missing kernel entry symbol: start");

    apply_relocations(objects, object_count, memory, mem_size, &globals);

    uint32_t file_cursor = SEGMENT_OFFSET;
    for (size_t i = 0; i < segments.count; i++) {
        Segment* segment = &segments.items[i];
        segment->offset = align_up(file_cursor, PAGE_SIZE);
        if (segment->filesz)
            file_cursor = segment->offset + align_up(segment->filesz, 16);
    }

    uint8_t* elf = (uint8_t*)xcalloc(file_cursor ? file_cursor : 1, 1);
    *out_size = file_cursor;

    elf[0] = 0x7f;
    elf[1] = 'E';
    elf[2] = 'L';
    elf[3] = 'F';
    elf[4] = 1;
    elf[5] = 1;
    elf[6] = 1;
    put_u16(elf, *out_size, 16, 2);
    put_u16(elf, *out_size, 18, 3);
    put_u32(elf, *out_size, 20, 1);
    put_u32(elf, *out_size, 24, symbol_address(start));
    put_u32(elf, *out_size, 28, ELF_HEADER_SIZE);
    put_u32(elf, *out_size, 32, 0);
    put_u32(elf, *out_size, 36, 0);
    put_u16(elf, *out_size, 40, ELF_HEADER_SIZE);
    put_u16(elf, *out_size, 42, PROGRAM_HEADER_SIZE);
    put_u16(elf, *out_size, 44, (uint16_t)segments.count);
    put_u16(elf, *out_size, 46, 0);
    put_u16(elf, *out_size, 48, 0);
    put_u16(elf, *out_size, 50, 0);

    for (size_t i = 0; i < segments.count; i++) {
        Segment* segment = &segments.items[i];
        size_t off = ELF_HEADER_SIZE + i * PROGRAM_HEADER_SIZE;
        put_u32(elf, *out_size, off, 1);
        put_u32(elf, *out_size, off + 4, segment->offset);
        put_u32(elf, *out_size, off + 8, segment->vaddr);
        put_u32(elf, *out_size, off + 12, segment->vaddr);
        put_u32(elf, *out_size, off + 16, segment->filesz);
        put_u32(elf, *out_size, off + 20, segment->memsz);
        put_u32(elf, *out_size, off + 24, segment->flags);
        put_u32(elf, *out_size, off + 28, PAGE_SIZE);
        if (segment->filesz)
            memcpy(elf + segment->offset, memory + segment->mem_off, segment->filesz);
    }

    free(memory);
    free(ordered.items);
    free(segments.items);
    for (size_t i = 0; i < globals.count; i++)
        free(globals.items[i].name);
    free(globals.items);
    return elf;
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

static uint32_t parse_u32_arg(const char* text)
{
    char* end = NULL;
    errno = 0;
    unsigned long value = strtoul(text, &end, 0);
    if (errno || !end || *end || value > 0xfffffffful) {
        fprintf(stderr, "link_elf32: invalid address: %s\n", text);
        exit(1);
    }
    return (uint32_t)value;
}

int main(int argc, char** argv)
{
    const char* output = NULL;
    const char* map_path = NULL;
    uint32_t base = 0;
    int have_base = 0;
    char** inputs = (char**)xcalloc((size_t)argc, sizeof(char*));
    size_t input_count = 0;

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-o") == 0) {
            if (++i >= argc)
                die("-o requires an output path");
            output = argv[i];
        } else if (strcmp(argv[i], "--base") == 0) {
            if (++i >= argc)
                die("--base requires an address");
            base = parse_u32_arg(argv[i]);
            have_base = 1;
        } else if (strcmp(argv[i], "--map") == 0) {
            if (++i >= argc)
                die("--map requires an output path");
            map_path = argv[i];
        } else if (argv[i][0] == '-') {
            fprintf(stderr, "link_elf32: unknown option %s\n", argv[i]);
            return 1;
        } else {
            inputs[input_count++] = argv[i];
        }
    }

    if (!output || !have_base || !input_count) {
        fprintf(stderr, "usage: link_elf32 -o OUTPUT --base 0xADDR [--map MAP] INPUT.o...\n");
        return 1;
    }

    ObjectFile* objects = (ObjectFile*)xcalloc(input_count, sizeof(ObjectFile));
    for (size_t i = 0; i < input_count; i++)
        parse_object(&objects[i], inputs[i]);

    size_t elf_size = 0;
    uint8_t* elf = build_executable(objects, input_count, base, &elf_size);
    write_file(output, elf, elf_size);
    if (map_path)
        write_symbol_map(map_path, objects, input_count);

    free(elf);
    free(inputs);
    return 0;
}
