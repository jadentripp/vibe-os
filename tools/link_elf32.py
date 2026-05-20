#!/usr/bin/env python3
import struct
import sys


SHT_SYMTAB = 2
SHT_NOBITS = 8
SHT_REL = 9
SHF_WRITE = 0x1
SHF_ALLOC = 0x2
SHF_EXECINSTR = 0x4
SHN_UNDEF = 0
R_386_32 = 1
R_386_PC32 = 2

ELF_HEADER_SIZE = 52
PROGRAM_HEADER_SIZE = 32
SEGMENT_OFFSET = 0x1000
PAGE_SIZE = 0x1000

PF_X = 0x1
PF_W = 0x2
PF_R = 0x4

SYMBOL_BINDINGS = {
    0: "LOCAL",
    1: "GLOBAL",
    2: "WEAK",
}

SYMBOL_TYPES = {
    0: "NOTYPE",
    1: "OBJECT",
    2: "FUNC",
    3: "SECTION",
    4: "FILE",
}


def align_up(value, alignment):
    if alignment <= 1:
        return value
    return (value + alignment - 1) & ~(alignment - 1)


def u16(data, offset):
    return struct.unpack_from("<H", data, offset)[0]


def u32(data, offset):
    return struct.unpack_from("<I", data, offset)[0]


def put_u32(data, offset, value):
    struct.pack_into("<I", data, offset, value & 0xFFFFFFFF)


def cstr(data, offset):
    end = data.find(b"\0", offset)
    if end < 0:
        end = len(data)
    return data[offset:end].decode("ascii")


class Section:
    def __init__(self, obj, index, name, sh_type, flags, offset, size, align, link, info, entsize):
        self.obj = obj
        self.index = index
        self.name = name
        self.type = sh_type
        self.flags = flags
        self.offset = offset
        self.size = size
        self.align = align
        self.link = link
        self.info = info
        self.entsize = entsize
        self.out_off = None
        self.out_addr = None
        self.mem_off = None
        self.segment = None

    @property
    def alloc(self):
        return bool(self.flags & SHF_ALLOC)

    def bytes(self):
        if self.type == SHT_NOBITS:
            return b"\0" * self.size
        return self.obj.data[self.offset:self.offset + self.size]


class Symbol:
    def __init__(self, obj, index, name, value, size, info, shndx):
        self.obj = obj
        self.index = index
        self.name = name
        self.value = value
        self.size = size
        self.info = info
        self.shndx = shndx

    @property
    def bind(self):
        return self.info >> 4

    @property
    def defined(self):
        return self.shndx != SHN_UNDEF

    def address(self):
        if not self.defined:
            raise ValueError(f"undefined symbol has no address: {self.name}")
        section = self.obj.sections[self.shndx]
        if not section.alloc:
            raise ValueError(f"symbol is not in an allocated section: {self.name}")
        return section.out_addr + self.value


class ObjectFile:
    def __init__(self, path):
        self.path = path
        with open(path, "rb") as f:
            self.data = f.read()
        self.sections = []
        self.symbols = []
        self.rel_sections = []
        self._parse()

    def _parse(self):
        data = self.data
        if data[0:4] != b"\x7fELF":
            raise ValueError(f"{self.path}: not an ELF file")
        if data[4] != 1 or data[5] != 1:
            raise ValueError(f"{self.path}: expected ELF32 little-endian")
        if u16(data, 16) != 1 or u16(data, 18) != 3:
            raise ValueError(f"{self.path}: expected i386 relocatable ELF")

        shoff = u32(data, 32)
        shentsize = u16(data, 46)
        shnum = u16(data, 48)
        shstrndx = u16(data, 50)
        raw_sections = []

        for index in range(shnum):
            off = shoff + index * shentsize
            raw_sections.append(
                (
                    u32(data, off),
                    u32(data, off + 4),
                    u32(data, off + 8),
                    u32(data, off + 16),
                    u32(data, off + 20),
                    u32(data, off + 24),
                    u32(data, off + 28),
                    u32(data, off + 32),
                    u32(data, off + 36),
                )
            )

        shstr = b""
        if shstrndx != SHN_UNDEF:
            sh_name, _type, _flags, sh_offset, sh_size, _link, _info, _align, _entsize = raw_sections[shstrndx]
            shstr = data[sh_offset:sh_offset + sh_size]

        self.sections = [None]
        for index in range(1, shnum):
            sh_name, sh_type, flags, offset, size, link, info, align, entsize = raw_sections[index]
            self.sections.append(
                Section(self, index, cstr(shstr, sh_name), sh_type, flags, offset, size, align, link, info, entsize)
            )

        for section in self.sections[1:]:
            if section.type == SHT_SYMTAB:
                self._parse_symbols(section)
            elif section.type == SHT_REL:
                self.rel_sections.append(section)

    def _parse_symbols(self, section):
        strtab = self.sections[section.link].bytes()
        count = section.size // section.entsize
        self.symbols = []
        for index in range(count):
            off = section.offset + index * section.entsize
            self.symbols.append(
                Symbol(
                    self,
                    index,
                    cstr(strtab, u32(self.data, off)),
                    u32(self.data, off + 4),
                    u32(self.data, off + 8),
                    self.data[off + 12],
                    u16(self.data, off + 14),
                )
            )


def collect_global_symbols(objects):
    globals_by_name = {}
    for obj in objects:
        for sym in obj.symbols:
            if sym.name and sym.defined and sym.bind != 0:
                if sym.name in globals_by_name:
                    raise ValueError(f"duplicate symbol: {sym.name}")
                globals_by_name[sym.name] = sym
    return globals_by_name


def layout_sections(objects, base):
    groups = [
        ("rx", PF_R | PF_X, lambda section: bool(section.flags & SHF_EXECINSTR)),
        ("ro", PF_R, lambda section: not (section.flags & SHF_WRITE) and not (section.flags & SHF_EXECINSTR)),
        ("rw", PF_R | PF_W, lambda section: bool(section.flags & SHF_WRITE)),
    ]
    alloc_sections = [
        section
        for obj in objects
        for section in obj.sections[1:]
        if section.alloc
    ]
    cursor = 0
    ordered = []
    segments = []

    for _name, flags, predicate in groups:
        grouped = [section for section in alloc_sections if predicate(section)]
        if not grouped:
            continue
        cursor = align_up(cursor, PAGE_SIZE)
        segment_start = cursor
        file_size = 0
        for section in grouped:
            cursor = align_up(cursor, max(section.align, 1))
            section.mem_off = cursor
            section.out_addr = base + cursor
            section.segment = len(segments)
            ordered.append(section)
            cursor += section.size
            if section.type != SHT_NOBITS:
                file_size = cursor - segment_start
        mem_size = cursor - segment_start
        segments.append(
            {
                "flags": flags,
                "mem_off": segment_start,
                "vaddr": base + segment_start,
                "filesz": file_size,
                "memsz": mem_size,
                "sections": grouped,
            }
        )

    return ordered, segments, cursor


def symbol_address(sym, globals_by_name):
    if sym.shndx == SHN_UNDEF:
        if sym.name not in globals_by_name:
            raise ValueError(f"unresolved symbol: {sym.name}")
        return globals_by_name[sym.name].address()
    return sym.address()


def apply_relocations(objects, memory, globals_by_name):
    for obj in objects:
        for rel_section in obj.rel_sections:
            target = obj.sections[rel_section.info]
            if not target.alloc:
                continue
            count = rel_section.size // 8
            for index in range(count):
                off = rel_section.offset + index * 8
                rel_offset = u32(obj.data, off)
                rel_info = u32(obj.data, off + 4)
                sym_index = rel_info >> 8
                rel_type = rel_info & 0xFF
                sym = obj.symbols[sym_index]
                patch_off = target.mem_off + rel_offset
                place = target.out_addr + rel_offset
                addend = u32(memory, patch_off)
                value = symbol_address(sym, globals_by_name)

                if rel_type == R_386_32:
                    put_u32(memory, patch_off, value + addend)
                elif rel_type == R_386_PC32:
                    put_u32(memory, patch_off, value + addend - place)
                else:
                    raise ValueError(f"{obj.path}: unsupported relocation type {rel_type}")


def symbol_bind_name(sym):
    return SYMBOL_BINDINGS.get(sym.info >> 4, f"BIND{sym.info >> 4}")


def symbol_type_name(sym):
    return SYMBOL_TYPES.get(sym.info & 0x0F, f"TYPE{sym.info & 0x0F}")


def build_symbol_map(objects):
    rows = []
    for obj in objects:
        for sym in obj.symbols:
            if not sym.name or not sym.defined:
                continue
            if sym.shndx >= len(obj.sections):
                continue
            section = obj.sections[sym.shndx]
            if not section.alloc:
                continue
            rows.append(
                (
                    sym.address(),
                    sym.size,
                    symbol_type_name(sym),
                    symbol_bind_name(sym),
                    section.name,
                    obj.path,
                    sym.name,
                )
            )
    rows.sort(key=lambda row: (row[0], row[6], row[5]))
    lines = [
        "# vibe-os-symbol-map-v1",
        "# address\tsize\ttype\tbind\tsection\tobject\tsymbol",
    ]
    for address, size, sym_type, bind, section, obj_path, name in rows:
        lines.append(
            f"{address:08X}\t{size:08X}\t{sym_type}\t{bind}\t"
            f"{section}\t{obj_path}\t{name}"
        )
    return "\n".join(lines) + "\n"


def build_executable(objects, base):
    ordered, segments, mem_size = layout_sections(objects, base)
    memory = bytearray(mem_size)
    for section in ordered:
        if section.type != SHT_NOBITS:
            memory[section.mem_off:section.mem_off + section.size] = section.bytes()

    globals_by_name = collect_global_symbols(objects)
    apply_relocations(objects, memory, globals_by_name)

    if "start" not in globals_by_name:
        raise ValueError("missing kernel entry symbol: start")

    if not segments:
        raise ValueError("no allocated sections")

    phnum = len(segments)
    file_cursor = SEGMENT_OFFSET
    for segment in segments:
        file_cursor = align_up(file_cursor, PAGE_SIZE)
        segment["offset"] = file_cursor
        file_cursor += align_up(segment["filesz"], 16)

    elf = bytearray(file_cursor)

    ident = bytearray(16)
    ident[0:4] = b"\x7fELF"
    ident[4] = 1
    ident[5] = 1
    ident[6] = 1
    struct.pack_into(
        "<16sHHIIIIIHHHHHH",
        elf,
        0,
        bytes(ident),
        2,
        3,
        1,
        globals_by_name["start"].address(),
        ELF_HEADER_SIZE,
        0,
        0,
        ELF_HEADER_SIZE,
        PROGRAM_HEADER_SIZE,
        phnum,
        0,
        0,
        0,
    )
    for index, segment in enumerate(segments):
        struct.pack_into(
            "<IIIIIIII",
            elf,
            ELF_HEADER_SIZE + index * PROGRAM_HEADER_SIZE,
            1,
            segment["offset"],
            segment["vaddr"],
            segment["vaddr"],
            segment["filesz"],
            segment["memsz"],
            segment["flags"],
            PAGE_SIZE,
        )
        if segment["filesz"]:
            start = segment["mem_off"]
            end = start + segment["filesz"]
            elf[segment["offset"]:segment["offset"] + segment["filesz"]] = memory[start:end]
    return bytes(elf), build_symbol_map(objects)


def parse_args(argv):
    output = None
    base = None
    map_path = None
    inputs = []
    index = 0
    while index < len(argv):
        arg = argv[index]
        if arg == "-o":
            index += 1
            if index >= len(argv):
                raise SystemExit("link_elf32.py: -o requires an output path")
            output = argv[index]
        elif arg == "--base":
            index += 1
            if index >= len(argv):
                raise SystemExit("link_elf32.py: --base requires an address")
            base = int(argv[index], 0)
        elif arg == "--map":
            index += 1
            if index >= len(argv):
                raise SystemExit("link_elf32.py: --map requires an output path")
            map_path = argv[index]
        elif arg.startswith("-"):
            raise SystemExit(f"link_elf32.py: unknown option {arg}")
        else:
            inputs.append(arg)
        index += 1

    if output is None or base is None or not inputs:
        raise SystemExit("usage: link_elf32.py -o OUTPUT --base 0xADDR [--map MAP] INPUT.o...")
    return output, base, map_path, inputs


def main():
    output, base, map_path, input_paths = parse_args(sys.argv[1:])

    objects = [ObjectFile(path) for path in input_paths]
    elf, symbol_map = build_executable(objects, base)

    with open(output, "wb") as f:
        f.write(elf)
    if map_path is not None:
        with open(map_path, "w", encoding="ascii") as f:
            f.write(symbol_map)


if __name__ == "__main__":
    main()
