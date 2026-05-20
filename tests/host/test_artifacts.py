import struct
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
BUILD = ROOT / "build"
SECTOR_SIZE = 512
USER_BASE = 0x00E80000
DOOM_BASE = 0x01000000
DOOM_HEAP_START = 0x01900000
DOOM_LIMIT = 0x02000000


def u16(data, offset):
    return struct.unpack_from("<H", data, offset)[0]


def u32(data, offset):
    return struct.unpack_from("<I", data, offset)[0]


def read(path):
    return path.read_bytes()


def clusters_for_size(size):
    return max(1, (size + SECTOR_SIZE - 1) // SECTOR_SIZE)


class Elf32:
    def __init__(self, data):
        self.data = data
        if data[:4] != b"\x7fELF":
            raise AssertionError("missing ELF magic")
        if data[4] != 1 or data[5] != 1:
            raise AssertionError("expected ELF32 little-endian")
        self.kind = u16(data, 16)
        self.machine = u16(data, 18)
        self.entry = u32(data, 24)
        self.phoff = u32(data, 28)
        self.shoff = u32(data, 32)
        self.phentsize = u16(data, 42)
        self.phnum = u16(data, 44)
        self.shentsize = u16(data, 46)
        self.shnum = u16(data, 48)
        self.shstrndx = u16(data, 50)

    def program_headers(self):
        headers = []
        for index in range(self.phnum):
            off = self.phoff + index * self.phentsize
            headers.append(struct.unpack_from("<IIIIIIII", self.data, off))
        return headers

    def section_headers(self):
        headers = []
        for index in range(self.shnum):
            off = self.shoff + index * self.shentsize
            headers.append(struct.unpack_from("<IIIIIIIIII", self.data, off))
        return headers

    def section_name_table(self):
        if self.shstrndx == 0 or self.shstrndx >= self.shnum:
            return b""
        sh = self.section_headers()[self.shstrndx]
        return self.data[sh[4]:sh[4] + sh[5]]


def cstr(data, offset):
    end = data.find(b"\0", offset)
    if end < 0:
        end = len(data)
    return data[offset:end].decode("ascii")


class BuildArtifactTests(unittest.TestCase):
    def test_stage1_is_bootable_mbr_sector(self):
        stage1 = read(BUILD / "stage1.bin")
        self.assertEqual(len(stage1), SECTOR_SIZE)
        self.assertEqual(stage1[510:512], b"\x55\xaa")

    def test_stage2_and_kernel_fit_reserved_raw_lbas(self):
        self.assertLessEqual((BUILD / "stage2.bin").stat().st_size, 16 * SECTOR_SIZE)
        self.assertLessEqual((BUILD / "kernel.elf").stat().st_size, 96 * SECTOR_SIZE)

    def test_kernel_elf32_load_segment(self):
        elf = Elf32(read(BUILD / "kernel.elf"))
        self.assertEqual(elf.kind, 2)
        self.assertEqual(elf.machine, 3)
        self.assertEqual(elf.entry, 0x10000)
        self.assertEqual(elf.phnum, 1)
        p_type, p_offset, p_vaddr, p_paddr, p_filesz, p_memsz, p_flags, p_align = elf.program_headers()[0]
        self.assertEqual(p_type, 1)
        self.assertEqual(p_offset, 0x1000)
        self.assertEqual(p_vaddr, 0x10000)
        self.assertEqual(p_paddr, 0x10000)
        self.assertEqual(p_filesz, p_memsz)
        self.assertEqual(p_flags, 0x7)
        self.assertEqual(p_align, 0x1000)

    def test_user_probe_is_small_c_backed_user_elf(self):
        elf = Elf32(read(BUILD / "user_probe.elf"))
        self.assertEqual(elf.kind, 2)
        self.assertEqual(elf.machine, 3)
        self.assertEqual(elf.entry, USER_BASE)
        self.assertEqual(elf.phnum, 1)
        p_type, p_offset, p_vaddr, p_paddr, p_filesz, p_memsz, p_flags, p_align = elf.program_headers()[0]
        self.assertEqual(p_type, 1)
        self.assertEqual(p_offset, 0x1000)
        self.assertEqual(p_vaddr, USER_BASE)
        self.assertEqual(p_paddr, USER_BASE)
        self.assertLessEqual(p_memsz, 0x1000)
        self.assertEqual(p_filesz, p_memsz)
        self.assertEqual(p_flags, 0x7)
        self.assertEqual(p_align, 0x1000)

    def test_user_c_object_contains_bss_for_linker_nobits_coverage(self):
        obj = Elf32(read(BUILD / "user_probe_c.o"))
        shstr = obj.section_name_table()
        sections = []
        for sh in obj.section_headers():
            name = cstr(shstr, sh[0]) if shstr else ""
            sections.append((name, sh[1], sh[5]))
        self.assertIn((".bss", 8, 12), sections)

    def test_doom_elf_fits_kernel_doom_load_window(self):
        elf = Elf32(read(BUILD / "doom.elf"))
        self.assertEqual(elf.kind, 2)
        self.assertEqual(elf.machine, 3)
        self.assertGreaterEqual(elf.entry, DOOM_BASE)
        self.assertLess(elf.entry, DOOM_LIMIT)
        self.assertEqual(elf.phnum, 1)
        p_type, p_offset, p_vaddr, p_paddr, p_filesz, p_memsz, p_flags, p_align = elf.program_headers()[0]
        self.assertEqual(p_type, 1)
        self.assertEqual(p_offset, 0x1000)
        self.assertEqual(p_vaddr, DOOM_BASE)
        self.assertEqual(p_paddr, DOOM_BASE)
        self.assertEqual(p_filesz, p_memsz)
        self.assertLessEqual(p_paddr + p_memsz, DOOM_HEAP_START)
        self.assertLessEqual(p_paddr + p_memsz, DOOM_LIMIT)
        self.assertEqual(p_flags, 0x7)
        self.assertEqual(p_align, 0x1000)


class DiskImageTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.image = read(BUILD / "disk.img")
        cls.partition_lba = u32(cls.image, 446 + 8)
        boot = cls.partition_lba * SECTOR_SIZE
        cls.reserved = u16(cls.image, boot + 14)
        cls.fat_count = cls.image[boot + 16]
        cls.root_entries = u16(cls.image, boot + 17)
        cls.sectors_per_fat = u16(cls.image, boot + 22)
        cls.root_lba = cls.partition_lba + cls.reserved + cls.fat_count * cls.sectors_per_fat
        cls.root_size = cls.root_entries * 32
        cls.root = cls.image[cls.root_lba * SECTOR_SIZE:cls.root_lba * SECTOR_SIZE + cls.root_size]
        cls.data_lba = cls.root_lba + ((cls.root_entries * 32 + SECTOR_SIZE - 1) // SECTOR_SIZE)

    def root_entries_by_name(self):
        entries = {}
        for off in range(0, self.root_size, 32):
            name = self.root[off:off + 11]
            if name[0] == 0:
                break
            entries[name.decode("ascii")] = {
                "cluster": u16(self.root, off + 26),
                "size": u32(self.root, off + 28),
            }
        return entries

    def cluster_bytes(self, cluster, size):
        lba = self.data_lba + (cluster - 2)
        start = lba * SECTOR_SIZE
        return self.image[start:start + size]

    def fat_entry(self, cluster):
        fat_lba = self.partition_lba + self.reserved
        return u16(self.image, fat_lba * SECTOR_SIZE + cluster * 2)

    def test_mbr_partition_and_fat_bpb(self):
        self.assertEqual(self.image[510:512], b"\x55\xaa")
        self.assertEqual(self.image[446 + 4], 0x06)
        self.assertEqual(self.partition_lba, 2048)
        boot = self.partition_lba * SECTOR_SIZE
        self.assertEqual(self.image[boot + 510:boot + 512], b"\x55\xaa")
        self.assertEqual(u16(self.image, boot + 11), SECTOR_SIZE)
        self.assertEqual(self.image[boot + 13], 1)
        self.assertEqual(self.fat_count, 2)

    def test_fat_root_contains_wad_and_user_elf(self):
        entries = self.root_entries_by_name()
        self.assertEqual(entries["DOOM1   WAD"]["size"], 1024 * 1024)
        self.assertEqual(entries["DOOM1   WAD"]["cluster"], 2)
        self.assertEqual(entries["USERPROBELF"]["size"], (BUILD / "user_probe.elf").stat().st_size)
        self.assertGreater(entries["USERPROBELF"]["cluster"], entries["DOOM1   WAD"]["cluster"])
        self.assertEqual(entries["DOOM    ELF"]["size"], (BUILD / "doom.elf").stat().st_size)
        self.assertGreater(entries["DOOM    ELF"]["cluster"], entries["USERPROBELF"]["cluster"])

    def test_wad_fixture_header_and_lumps(self):
        wad = self.cluster_bytes(2, 1024 * 1024)
        self.assertEqual(wad[:4], b"IWAD")
        lump_count = u32(wad, 4)
        directory = u32(wad, 8)
        self.assertEqual(lump_count, 4)
        names = []
        for index in range(lump_count):
            entry = directory + index * 16
            names.append(wad[entry + 8:entry + 16].rstrip(b"\0").decode("ascii"))
        self.assertIn("PLAYPAL", names)
        self.assertIn("COLORMAP", names)

    def test_user_elf_bytes_are_present_in_fat_data_area(self):
        entries = self.root_entries_by_name()
        user = entries["USERPROBELF"]
        image_bytes = self.cluster_bytes(user["cluster"], user["size"])
        self.assertEqual(image_bytes, read(BUILD / "user_probe.elf"))
        self.assertEqual(self.fat_entry(user["cluster"]), user["cluster"] + 1)

    def test_doom_elf_bytes_are_present_in_fat_data_area(self):
        entries = self.root_entries_by_name()
        doom = entries["DOOM    ELF"]
        image_bytes = self.cluster_bytes(doom["cluster"], doom["size"])
        self.assertEqual(image_bytes, read(BUILD / "doom.elf"))
        self.assertEqual(image_bytes[:4], b"\x7fELF")
        clusters = clusters_for_size(doom["size"])
        self.assertEqual(self.fat_entry(doom["cluster"]), doom["cluster"] + 1)
        self.assertEqual(self.fat_entry(doom["cluster"] + clusters - 1), 0xFFFF)


class SourceContractTests(unittest.TestCase):
    def test_local_vm_targets_are_opt_in(self):
        makefile = (ROOT / "Makefile").read_text()
        self.assertIn("ALLOW_LOCAL_VM ?= 0", makefile)
        self.assertIn("run: vm-consent", makefile)
        self.assertIn("smoke: vm-consent", makefile)

    def test_user_probe_is_c_not_assembly_only(self):
        self.assertTrue((ROOT / "user" / "probe.c").exists())
        self.assertTrue((ROOT / "user" / "crt0.asm").exists())
        self.assertFalse((ROOT / "user" / "probe.asm").exists())

    def test_syscall_handler_preserves_c_caller_registers(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()
        handler = kernel.split("syscall_handler:", 1)[1].split("user_range_validate:", 1)[0]
        for instruction in ("push ebx", "push ecx", "push edx", "push esi", "push edi", "push ebp"):
            self.assertIn(instruction, handler)
        for instruction in ("pop ebp", "pop edi", "pop esi", "pop edx", "pop ecx", "pop ebx"):
            self.assertIn(instruction, handler)
        self.assertIn(".return:", handler)

    def test_kernel_has_doom_elf_load_window_and_status(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()
        for source in (
            "PAGING_TABLE_COUNT equ 8",
            "PMM_MANAGED_END equ 0x02000000",
            "DOOM_ELF_LOAD_ADDR equ 0x01000000",
            "DOOM_ELF_LIMIT equ 0x02000000",
            "DOOM_USER_HEAP_START equ 0x01900000",
            "DOOM_USER_HEAP_END equ 0x01f00000",
            "DOOM_USER_STACK_BOTTOM equ DOOM_USER_HEAP_END",
            "DOOM_USER_STACK_TOP equ DOOM_ELF_LIMIT",
            "fat_load_doom_elf:",
            "doom_elf_prepare:",
            "doom_user_run:",
            "draw_doom_status:",
        ):
            self.assertIn(source, kernel)
        makefile = (ROOT / "Makefile").read_text()
        self.assertIn('grep -q "doom=OK"', makefile)

    def test_kernel_launches_loaded_doom_elf_in_ring3_smoke(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()
        makefile = (ROOT / "Makefile").read_text()
        self.assertIn("USER_KIND_DOOM equ 2", kernel)
        self.assertIn("call doom_user_run", kernel)
        self.assertIn("push dword DOOM_USER_STACK_TOP", kernel)
        self.assertIn("push dword [doom_entry_addr]", kernel)
        self.assertIn("mov byte [doom_run_status], 1", kernel)
        self.assertIn("mov byte [doom_run_status], 2", kernel)
        self.assertIn("doom_user_fault:", kernel)
        self.assertIn("doom_open_count", kernel)
        self.assertIn("doom_read_count", kernel)
        self.assertIn("doom_wad_magic_seen", kernel)
        self.assertIn("doomrun=", kernel)
        self.assertIn("doomopen=", kernel)
        self.assertIn("doomread=", kernel)
        self.assertIn('grep -Eq "doomrun=(RUN|EXIT)"', makefile)
        self.assertIn('grep -q "doomopen=OK"', makefile)
        self.assertIn('grep -q "doomread=OK"', makefile)

    def test_user_syscalls_validate_against_current_process_window(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()
        validator = kernel.split("user_range_validate:", 1)[1].split("page_fault_handler:", 1)[0]
        self.assertIn("cmp eax, [current_user_base]", validator)
        self.assertIn("cmp edx, [current_user_end]", validator)
        self.assertNotIn("cmp eax, USER_CODE_ADDR", validator)
        self.assertNotIn("cmp edx, USER_HEAP_END", validator)
        sbrk = kernel.split(".sbrk:", 1)[1].split(".open:", 1)[0]
        self.assertIn("mov eax, [current_user_brk]", sbrk)
        self.assertIn("cmp edx, [current_user_heap_end]", sbrk)

    def test_doom_port_uses_kernel_time_syscall(self):
        platform = (ROOT / "doom_port" / "platform.c").read_text()
        libc = (ROOT / "doom_port" / "libc.c").read_text()
        header = (ROOT / "doom_port" / "include" / "vibe_os.h").read_text()
        self.assertIn("VIBE_SYS_TIME = 9", header)
        self.assertIn("int vibe_syscall3", header)
        self.assertIn("int vibe_syscall3(", libc)
        self.assertIn("return vibe_syscall3(VIBE_SYS_TIME, 0, 0, 0);", platform)

    def test_doom_port_and_probe_have_indexed_frame_present_syscall(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()
        stage2 = (ROOT / "boot" / "stage2.asm").read_text()
        platform = (ROOT / "doom_port" / "platform.c").read_text()
        header = (ROOT / "doom_port" / "include" / "vibe_os.h").read_text()
        probe = (ROOT / "user" / "probe.c").read_text()
        makefile = (ROOT / "Makefile").read_text()
        self.assertIn("set_video_mode13:", stage2)
        self.assertIn("mov ax, 0x0013", stage2)
        self.assertIn("SMOKE_STATUS_ADDR equ 0x0009d000", kernel)
        self.assertIn("SYS_PRESENT equ 10", kernel)
        self.assertIn("VGA_GRAPHICS_BUFFER equ 0x000a0000", kernel)
        self.assertIn("present_indexed_frame:", kernel)
        self.assertIn("write_smoke_status:", kernel)
        self.assertIn("VIBE_SYS_PRESENT = 10", header)
        self.assertIn("vibe_syscall3(VIBE_SYS_PRESENT", platform)
        self.assertIn("PROBE_FLAG_PRESENT = 0x20u", probe)
        self.assertIn("SYS_PRESENT = 10", probe)
        self.assertIn('grep -q "gfx=OK"', makefile)
        self.assertIn("pmemsave 0x9d000 1024", makefile)
        self.assertIn("pmemsave 0xa0000 64000", makefile)


if __name__ == "__main__":
    unittest.main()
