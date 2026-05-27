#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum {
    EM_AARCH64 = 183,
    ET_REL = 1,
    ELFCLASS64 = 2,
    ELFDATA2LSB = 1,
    SHT_PROGBITS = 1,
    SHT_SYMTAB = 2,
    SHT_NOBITS = 8,
    SHT_RELA = 4,
    SHF_ALLOC = 0x2,
    SHN_UNDEF = 0,
    SHN_ABS = 0xfff1,
    R_AARCH64_ABS64 = 257,
    R_AARCH64_ADR_PREL_LO21 = 274,
};

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
    int alloc;
} Section;

typedef struct {
    const char* name;
    uint16_t shndx;
    uint64_t value;
    uint64_t size;
    uint8_t info;
} Symbol;

typedef struct {
    uint8_t* data;
    size_t size;
    Section* sections;
    size_t section_count;
    Symbol* symbols;
    size_t symbol_count;
    uint64_t base;
    uint64_t image_file_size;
    uint64_t image_mem_size;
    uint64_t bss_start;
    uint64_t bss_end;
} Object;

static void die(const char* message)
{
    fprintf(stderr, "link_aarch64_flat: %s\n", message);
    exit(1);
}

static void die_path(const char* path, const char* message)
{
    fprintf(stderr, "link_aarch64_flat: %s: %s\n", path, message);
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
    if (off + 2 > size)
        die("unexpected end of file");
    return (uint16_t)data[off] | ((uint16_t)data[off + 1] << 8);
}

static uint32_t u32(const uint8_t* data, size_t size, size_t off)
{
    if (off + 4 > size)
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

static void put_u32(uint8_t* data, size_t size, size_t off, uint32_t value)
{
    if (off + 4 > size)
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

static uint64_t align_up(uint64_t value, uint64_t alignment)
{
    if (alignment <= 1)
        return value;
    if (alignment & (alignment - 1))
        die("section alignment is not a power of two");
    return (value + alignment - 1) & ~(alignment - 1);
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

static const char* cstr_at(const uint8_t* table, uint64_t table_size, uint32_t off)
{
    if ((uint64_t)off >= table_size)
        die("string table offset out of range");
    const char* text = (const char*)table + off;
    if (!memchr(text, 0, (size_t)(table_size - off)))
        die("unterminated string table entry");
    return text;
}

static void parse_sections(Object* obj, const char* path)
{
    if (obj->size < 64 || memcmp(obj->data, "\177ELF", 4) != 0)
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
    if (shoff + (uint64_t)shentsize * shnum > obj->size)
        die_path(path, "section headers out of range");

    size_t shstr_off = (size_t)(shoff + (uint64_t)shstrndx * shentsize);
    uint64_t shstr_data_off = u64(obj->data, obj->size, shstr_off + 24);
    uint64_t shstr_size = u64(obj->data, obj->size, shstr_off + 32);
    if (shstr_data_off + shstr_size > obj->size)
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
        sec->alloc = (sec->flags & SHF_ALLOC) != 0;
        if (sec->type != SHT_NOBITS && sec->offset + sec->size > obj->size)
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
        if (!symtab->entsize)
            die_path(path, "symbol table has zero entry size");
        if (strtab->offset + strtab->size > obj->size)
            die_path(path, "symbol string table out of range");

        const uint8_t* strings = obj->data + strtab->offset;
        obj->symbol_count = (size_t)(symtab->size / symtab->entsize);
        obj->symbols = (Symbol*)xcalloc(obj->symbol_count ? obj->symbol_count : 1, sizeof(obj->symbols[0]));
        for (size_t sym_index = 0; sym_index < obj->symbol_count; sym_index++) {
            uint64_t off = symtab->offset + (uint64_t)sym_index * symtab->entsize;
            Symbol* sym = &obj->symbols[sym_index];
            sym->name = cstr_at(strings, strtab->size, u32(obj->data, obj->size, (size_t)off));
            sym->info = obj->data[off + 4];
            sym->shndx = u16(obj->data, obj->size, (size_t)off + 6);
            sym->value = u64(obj->data, obj->size, (size_t)off + 8);
            sym->size = u64(obj->data, obj->size, (size_t)off + 16);
        }
        return;
    }
    die_path(path, "missing symbol table");
}

static void layout_sections(Object* obj)
{
    uint64_t cursor = 0;
    int saw_bss = 0;
    for (size_t pass = 0; pass < 2; pass++) {
        for (size_t i = 1; i < obj->section_count; i++) {
            Section* sec = &obj->sections[i];
            if (!sec->alloc)
                continue;
            int is_bss = sec->type == SHT_NOBITS;
            if ((pass == 0 && is_bss) || (pass == 1 && !is_bss))
                continue;
            uint64_t align = sec->align ? sec->align : 1;
            cursor = align_up(cursor, align);
            sec->out_off = cursor;
            sec->out_addr = obj->base + cursor;
            if (is_bss) {
                if (!saw_bss) {
                    obj->bss_start = sec->out_addr;
                    saw_bss = 1;
                }
                obj->bss_end = sec->out_addr + sec->size;
            } else {
                uint64_t end = cursor + sec->size;
                if (end > obj->image_file_size)
                    obj->image_file_size = end;
            }
            cursor += sec->size;
        }
    }
    if (!saw_bss) {
        obj->bss_start = obj->base + cursor;
        obj->bss_end = obj->bss_start;
    }
    obj->image_mem_size = cursor;
}

static uint64_t synthetic_symbol_value(const Object* obj, const char* name, int* found)
{
    *found = 1;
    if (strcmp(name, "__bss_start") == 0)
        return obj->bss_start;
    if (strcmp(name, "__bss_end") == 0)
        return obj->bss_end;
    if (strcmp(name, "__pi4_image_base") == 0)
        return obj->base;
    if (strcmp(name, "__pi4_image_end") == 0)
        return obj->base + obj->image_mem_size;
    *found = 0;
    return 0;
}

static uint64_t symbol_value(const Object* obj, size_t index)
{
    if (index >= obj->symbol_count)
        die("relocation symbol index out of range");
    const Symbol* sym = &obj->symbols[index];
    if (sym->shndx == SHN_UNDEF) {
        int found = 0;
        uint64_t value = synthetic_symbol_value(obj, sym->name, &found);
        if (found)
            return value;
        fprintf(stderr, "link_aarch64_flat: unresolved symbol: %s\n", sym->name);
        exit(1);
    }
    if (sym->shndx == SHN_ABS)
        return sym->value;
    if (sym->shndx >= obj->section_count)
        die("symbol section out of range");
    const Section* sec = &obj->sections[sym->shndx];
    if (!sec->alloc)
        die("symbol is not in an allocated section");
    return sec->out_addr + sym->value;
}

static void patch_adr(uint8_t* out, size_t out_size, uint64_t off, int64_t delta)
{
    if (off + 4 > out_size)
        die("ADR relocation target outside output");
    if (delta < -(1LL << 20) || delta > ((1LL << 20) - 1))
        die("ADR relocation is out of +/-1 MiB range");
    uint32_t insn = u32(out, out_size, (size_t)off);
    if ((insn & 0x9f000000u) != 0x10000000u)
        die("ADR relocation target is not an ADR instruction");
    uint64_t imm = (uint64_t)delta & 0x1fffff;
    insn &= ~0x60ffffe0u;
    insn |= (uint32_t)((imm & 0x3u) << 29);
    insn |= (uint32_t)(((imm >> 2) & 0x7ffffu) << 5);
    put_u32(out, out_size, (size_t)off, insn);
}

static void apply_relocations(const Object* obj, uint8_t* out, size_t out_size)
{
    for (size_t rel_index = 0; rel_index < obj->section_count; rel_index++) {
        const Section* rel = &obj->sections[rel_index];
        if (rel->type != SHT_RELA)
            continue;
        if (rel->info >= obj->section_count)
            die("relocation target section out of range");
        const Section* target = &obj->sections[rel->info];
        if (!target->alloc)
            continue;
        if (rel->entsize && rel->entsize != 24)
            die("unsupported RELA entry size");
        size_t count = (size_t)(rel->size / 24);
        for (size_t i = 0; i < count; i++) {
            uint64_t off = rel->offset + (uint64_t)i * 24;
            uint64_t r_offset = u64(obj->data, obj->size, (size_t)off);
            uint64_t r_info = u64(obj->data, obj->size, (size_t)off + 8);
            int64_t addend = (int64_t)u64(obj->data, obj->size, (size_t)off + 16);
            uint32_t type = (uint32_t)r_info;
            size_t sym_index = (size_t)(r_info >> 32);
            uint64_t value = symbol_value(obj, sym_index) + (uint64_t)addend;
            uint64_t place = target->out_addr + r_offset;
            uint64_t patch_off = target->out_off + r_offset;
            if (type == R_AARCH64_ADR_PREL_LO21) {
                patch_adr(out, out_size, patch_off, (int64_t)value - (int64_t)place);
            } else if (type == R_AARCH64_ABS64) {
                if (patch_off + 8 > out_size)
                    die("ABS64 relocation target outside output");
                put_u64(out, out_size, (size_t)patch_off, value);
            } else {
                fprintf(stderr, "link_aarch64_flat: unsupported AArch64 relocation %u\n", type);
                exit(1);
            }
        }
    }
}

static uint8_t* build_flat_image(Object* obj, size_t* out_size)
{
    if (!obj->image_file_size)
        die("no allocated file-backed sections");
    if (obj->image_file_size > (uint64_t)SIZE_MAX)
        die("output is too large for this host");
    uint8_t* out = (uint8_t*)xcalloc((size_t)obj->image_file_size, 1);
    *out_size = (size_t)obj->image_file_size;
    for (size_t i = 1; i < obj->section_count; i++) {
        const Section* sec = &obj->sections[i];
        if (!sec->alloc || sec->type == SHT_NOBITS || !sec->size)
            continue;
        if (sec->out_off + sec->size > obj->image_file_size)
            die("section output range is outside image");
        memcpy(out + sec->out_off, obj->data + sec->offset, (size_t)sec->size);
    }
    apply_relocations(obj, out, *out_size);
    return out;
}

static void write_section_map_line(FILE* f, const Section* sec)
{
    fprintf(
        f,
        "section=%s addr=0x%016llX off=0x%016llX size=0x%016llX file=%s\n",
        sec->name,
        (unsigned long long)sec->out_addr,
        (unsigned long long)sec->out_off,
        (unsigned long long)sec->size,
        sec->type == SHT_NOBITS ? "NO" : "YES");
}

static void write_symbol_map_line(FILE* f, const char* name, uint64_t addr, const char* section, uint64_t size)
{
    fprintf(
        f,
        "symbol=%s addr=0x%016llX section=%s size=0x%016llX\n",
        name,
        (unsigned long long)addr,
        section,
        (unsigned long long)size);
}

static void write_map_sections(FILE* f, const Object* obj)
{
    for (size_t pass = 0; pass < 2; pass++) {
        for (size_t i = 1; i < obj->section_count; i++) {
            const Section* sec = &obj->sections[i];
            if (!sec->alloc)
                continue;
            int is_bss = sec->type == SHT_NOBITS;
            if ((pass == 0 && is_bss) || (pass == 1 && !is_bss))
                continue;
            write_section_map_line(f, sec);
        }
    }
}

static void write_synthetic_symbol_map_line(FILE* f, const char* name, uint64_t addr)
{
    write_symbol_map_line(f, name, addr, "synthetic", 0);
}

static void write_map(const char* path, const Object* obj)
{
    FILE* f = fopen(path, "w");
    if (!f)
        die_path(path, strerror(errno));
    uint64_t file_end = obj->base + obj->image_file_size;
    fprintf(f, "# vibe-os-aarch64-flat-map-v1\n");
    fprintf(f, "base=0x%016llX\n", (unsigned long long)obj->base);
    fprintf(f, "file_size=0x%016llX\n", (unsigned long long)obj->image_file_size);
    fprintf(f, "file_end=0x%016llX\n", (unsigned long long)file_end);
    fprintf(f, "mem_size=0x%016llX\n", (unsigned long long)obj->image_mem_size);
    fprintf(f, "bss=0x%016llX/0x%016llX\n", (unsigned long long)obj->bss_start, (unsigned long long)obj->bss_end);
    fprintf(f, "bss_after_file=%s\n", obj->bss_start >= file_end ? "YES" : "NO");
    write_map_sections(f, obj);
    write_synthetic_symbol_map_line(f, "__pi4_image_base", obj->base);
    write_synthetic_symbol_map_line(f, "__pi4_image_end", obj->base + obj->image_mem_size);
    write_synthetic_symbol_map_line(f, "__bss_start", obj->bss_start);
    write_synthetic_symbol_map_line(f, "__bss_end", obj->bss_end);
    for (size_t i = 0; i < obj->symbol_count; i++) {
        const Symbol* sym = &obj->symbols[i];
        if (!sym->name || !sym->name[0] || sym->shndx == SHN_UNDEF || sym->shndx >= obj->section_count)
            continue;
        const Section* sec = &obj->sections[sym->shndx];
        if (!sec->alloc)
            continue;
        write_symbol_map_line(f, sym->name, sec->out_addr + sym->value, sec->name, sym->size);
    }
    fclose(f);
}

static uint64_t parse_u64_arg(const char* text)
{
    char* end = NULL;
    errno = 0;
    unsigned long long value = strtoull(text, &end, 0);
    if (errno || !end || *end) {
        fprintf(stderr, "link_aarch64_flat: invalid address: %s\n", text);
        exit(1);
    }
    return (uint64_t)value;
}

int main(int argc, char** argv)
{
    const char* output = NULL;
    const char* map = NULL;
    const char* input = NULL;
    uint64_t base = 0;
    int have_base = 0;

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-o") == 0) {
            if (++i >= argc)
                die("-o requires an output path");
            output = argv[i];
        } else if (strcmp(argv[i], "--base") == 0) {
            if (++i >= argc)
                die("--base requires an address");
            base = parse_u64_arg(argv[i]);
            have_base = 1;
        } else if (strcmp(argv[i], "--map") == 0) {
            if (++i >= argc)
                die("--map requires an output path");
            map = argv[i];
        } else if (argv[i][0] == '-') {
            fprintf(stderr, "link_aarch64_flat: unknown option %s\n", argv[i]);
            return 1;
        } else if (!input) {
            input = argv[i];
        } else {
            die("only one input object is supported");
        }
    }

    if (!output || !have_base || !input) {
        fprintf(stderr, "usage: link_aarch64_flat -o OUTPUT --base 0xADDR [--map MAP] INPUT.o\n");
        return 1;
    }

    Object obj;
    memset(&obj, 0, sizeof(obj));
    obj.base = base;
    obj.data = read_file(input, &obj.size);
    parse_sections(&obj, input);
    parse_symbols(&obj, input);
    layout_sections(&obj);

    size_t image_size = 0;
    uint8_t* image = build_flat_image(&obj, &image_size);
    write_file(output, image, image_size);
    if (map)
        write_map(map, &obj);

    free(image);
    free(obj.symbols);
    free(obj.sections);
    free(obj.data);
    return 0;
}
