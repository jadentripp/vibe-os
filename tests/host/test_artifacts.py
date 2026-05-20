import struct
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
BUILD = ROOT / "build"
SECTOR_SIZE = 512
USER_BASE = 0x00E80000
DOOM_BASE = 0x01000000
DOOM_HEAP_START = 0x01900000
DOOM_LIMIT = 0x02000000
MAX_KERNEL_WAD_BYTES = 0x00500000


def u16(data, offset):
    return struct.unpack_from("<H", data, offset)[0]


def u32(data, offset):
    return struct.unpack_from("<I", data, offset)[0]


def read(path):
    return path.read_bytes()


def clusters_for_size(size):
    return max(1, (size + SECTOR_SIZE - 1) // SECTOR_SIZE)


def make_test_wad(total_size):
    wad = bytearray(total_size)
    lumps = [
        ("PLAYPAL", bytes((i % 64 for i in range(14 * 256 * 3)))),
        ("COLORMAP", bytes((i % 256 for i in range(34 * 256)))),
    ]
    cursor = 12
    entries = []
    for name, data in lumps:
        wad[cursor:cursor + len(data)] = data
        entries.append((cursor, len(data), name.encode("ascii").ljust(8, b"\0")))
        cursor += len(data)
    directory = cursor
    for index, (filepos, size, name) in enumerate(entries):
        off = directory + index * 16
        struct.pack_into("<II8s", wad, off, filepos, size, name)
    wad[0:4] = b"IWAD"
    struct.pack_into("<II", wad, 4, len(entries), directory)
    return bytes(wad)


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
        self.assertGreaterEqual(lump_count, 12)
        names = []
        for index in range(lump_count):
            entry = directory + index * 16
            names.append(wad[entry + 8:entry + 16].rstrip(b"\0").decode("ascii"))
        self.assertIn("PLAYPAL", names)
        self.assertIn("COLORMAP", names)
        self.assertIn("PNAMES", names)
        self.assertIn("TEXTURE1", names)
        self.assertIn("F_START", names)
        self.assertIn("F_END", names)
        self.assertIn("S_START", names)
        self.assertIn("S_END", names)

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


class ExternalWadImageTests(unittest.TestCase):
    def test_image_builder_can_package_external_real_wad_sized_file(self):
        wad = make_test_wad(2 * 1024 * 1024 + 123)

        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            wad_path = tmpdir / "DOOM1.WAD"
            image_path = tmpdir / "disk.img"
            wad_path.write_bytes(wad)

            subprocess.run(
                [
                    sys.executable,
                    str(ROOT / "tools" / "make_wad_image.py"),
                    "--wad",
                    str(wad_path),
                    str(image_path),
                ],
                check=True,
                cwd=ROOT,
            )

            image = image_path.read_bytes()

        partition_lba = u32(image, 446 + 8)
        boot = partition_lba * SECTOR_SIZE
        reserved = u16(image, boot + 14)
        fat_count = image[boot + 16]
        root_entries = u16(image, boot + 17)
        sectors_per_fat = u16(image, boot + 22)
        root_lba = partition_lba + reserved + fat_count * sectors_per_fat
        root_size = root_entries * 32
        root = image[root_lba * SECTOR_SIZE:root_lba * SECTOR_SIZE + root_size]
        data_lba = root_lba + ((root_entries * 32 + SECTOR_SIZE - 1) // SECTOR_SIZE)

        self.assertEqual(root[0:11], b"DOOM1   WAD")
        self.assertEqual(u16(root, 26), 2)
        self.assertEqual(u32(root, 28), len(wad))
        wad_start = data_lba * SECTOR_SIZE
        self.assertEqual(image[wad_start:wad_start + len(wad)], wad)

    def test_image_builder_rejects_wads_larger_than_kernel_loader_limit(self):
        wad = make_test_wad(MAX_KERNEL_WAD_BYTES + 1)

        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            wad_path = tmpdir / "too-large.wad"
            image_path = tmpdir / "disk.img"
            wad_path.write_bytes(wad)
            result = subprocess.run(
                [
                    sys.executable,
                    str(ROOT / "tools" / "make_wad_image.py"),
                    "--wad",
                    str(wad_path),
                    str(image_path),
                ],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("exceeds kernel WAD load limit", result.stderr)


class SourceContractTests(unittest.TestCase):
    def test_local_vm_targets_are_opt_in(self):
        makefile = (ROOT / "Makefile").read_text()
        gitignore = (ROOT / ".gitignore").read_text()
        real_wad_workflow = (ROOT / ".github" / "workflows" / "real-wad-smoke.yml").read_text()
        self.assertIn("ALLOW_LOCAL_VM ?= 0", makefile)
        self.assertIn("DOOM_WAD ?=", makefile)
        self.assertIn("SMOKE_EXPECT_PROBE_GFX ?= 1", makefile)
        self.assertIn("SMOKE_REJECT_DOOMLOG ?=", makefile)
        self.assertIn("SMOKE_SENDKEYS ?=", makefile)
        self.assertIn("SMOKE_REQUIRE_DOOM_PRESENT ?= 0", makefile)
        self.assertIn("--wad", makefile)
        self.assertIn("run: vm-consent", makefile)
        self.assertIn("smoke: vm-consent", makefile)
        self.assertIn("*.wad", gitignore)
        self.assertIn("*.WAD", gitignore)
        self.assertIn("workflow_dispatch:", real_wad_workflow)
        self.assertIn("REAL_DOOM_WAD_URL", real_wad_workflow)
        self.assertIn("SMOKE_EXPECT_PROBE_GFX=0", real_wad_workflow)
        self.assertIn("SMOKE_REQUIRE_DOOM_PRESENT=1", real_wad_workflow)
        self.assertIn('SMOKE_SENDKEYS="spc"', real_wad_workflow)
        self.assertIn("SMOKE_REJECT_DOOMLOG=", real_wad_workflow)
        self.assertNotIn("build/disk.img", real_wad_workflow)
        self.assertNotIn("build/gfx.bin", real_wad_workflow)

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
        image_tool = (ROOT / "tools" / "make_wad_image.py").read_text()
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
        self.assertIn("WAD_MAX_BYTES equ 0x00500000", kernel)
        self.assertIn("MAX_KERNEL_WAD_BYTES = 0x00500000", image_tool)

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
        self.assertIn("DOOM_LOG_BYTES equ 160", kernel)
        self.assertIn("doom_log_char:", kernel)
        self.assertIn("doom_log_buffer times DOOM_LOG_BYTES db 0", kernel)
        self.assertIn("doomrun=", kernel)
        self.assertIn("doomopen=", kernel)
        self.assertIn("doomread=", kernel)
        self.assertIn("doomlog=", kernel)
        self.assertIn('grep -Eq "doomrun=(RUN|EXIT)"', makefile)
        self.assertIn('grep -q "doomopen=OK"', makefile)
        self.assertIn('grep -q "doomread=OK"', makefile)
        self.assertIn('grep -q "doomlog="', makefile)

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
        self.assertIn('!strcmp(name, "HOME")', libc)
        self.assertIn('!strcmp(name, "DOOMWADDIR")', libc)

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
        self.assertIn("mov dword [doom_present_count], 0", kernel)
        self.assertIn("mov byte [present_status], 0", kernel)
        self.assertIn('smoke_doompresent_text db " doompresent="', kernel)
        self.assertIn("mov edx, [doom_present_count]", kernel)
        self.assertIn("write_smoke_status:", kernel)
        self.assertIn("VIBE_SYS_PRESENT = 10", header)
        self.assertIn("vibe_syscall3(VIBE_SYS_PRESENT", platform)
        self.assertIn("PROBE_FLAG_PRESENT = 0x20u", probe)
        self.assertIn("SYS_PRESENT = 10", probe)
        self.assertIn('grep -q "gfx=OK"', makefile)
        self.assertIn('grep -q "doompresent="', makefile)
        self.assertIn('if [ "$(SMOKE_REQUIRE_DOOM_PRESENT)" = "1" ]; then', makefile)
        self.assertIn("/doompresent=([0-9A-F]{8})/", makefile)
        self.assertIn('hex($$1) > 0; END { exit($$ok ? 0 : 1) }', makefile)
        self.assertIn("pmemsave 0x9d000 1024", makefile)
        self.assertIn("pmemsave 0xa0000 64000", makefile)

    def test_doom_keyboard_events_flow_through_kernel_syscall(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()
        platform = (ROOT / "doom_port" / "platform.c").read_text()
        header = (ROOT / "doom_port" / "include" / "vibe_os.h").read_text()
        self.assertIn("SYS_POLL_KEY equ 11", kernel)
        self.assertIn("SYS_POLL_KEY", kernel)
        self.assertIn("KEY_EVENT_VALID equ 0x00010000", kernel)
        self.assertIn("key_event_queue times KEY_QUEUE_SIZE dd 0", kernel)
        self.assertIn("keyboard_queue_scancode:", kernel)
        self.assertIn("doom_scancode_map:", kernel)
        self.assertIn("irq_keyboard:", kernel)
        self.assertIn("inc dword [keyboard_irq_count]", kernel)
        self.assertIn("pic_unmask_timer_keyboard:", kernel)
        self.assertIn("mov eax, irq_keyboard", kernel)
        self.assertIn("call pic_unmask_timer_keyboard", kernel)
        self.assertIn("DOOM_KEY_UPARROW", kernel)
        self.assertIn("DOOM_KEY_RCTRL", kernel)
        self.assertIn("mov dword [keyboard_irq_count], 0", kernel)
        self.assertIn("keyboard_irq_count dd 0", kernel)
        self.assertIn("keyboard_event_count dd 0", kernel)
        self.assertIn("doom_key_event_count dd 0", kernel)
        self.assertIn('smoke_keyirq_text db " keyirq="', kernel)
        self.assertIn('smoke_keyqueue_text db " keyqueue="', kernel)
        self.assertIn('smoke_keypoll_text db " keypoll="', kernel)
        self.assertIn("mov edx, [keyboard_irq_count]", kernel)
        self.assertIn("mov edx, [keyboard_event_count]", kernel)
        self.assertIn("mov edx, [doom_key_event_count]", kernel)
        self.assertIn("VIBE_SYS_POLL_KEY = 11", header)
        self.assertIn("VIBE_KEY_EVENT_VALID", header)
        self.assertIn("VIBE_KEY_EVENT_DOWN", header)
        self.assertIn("#include \"d_event.h\"", platform)
        self.assertIn("#include \"d_main.h\"", platform)
        makefile = (ROOT / "Makefile").read_text()
        self.assertIn("for key in $(SMOKE_SENDKEYS); do", makefile)
        self.assertIn('printf "sendkey %s\\n" "$$key"', makefile)
        self.assertIn('if [ -n "$(SMOKE_SENDKEYS)" ]; then', makefile)
        self.assertIn('grep -q "keyirq="', makefile)
        self.assertIn('grep -q "keyqueue="', makefile)
        self.assertIn('grep -q "keypoll="', makefile)
        self.assertIn("/keyirq=([0-9A-F]{8})/", makefile)
        self.assertIn("/keyqueue=([0-9A-F]{8})/", makefile)
        self.assertIn("/keypoll=([0-9A-F]{8})/", makefile)
        self.assertIn("vibe_syscall3(VIBE_SYS_POLL_KEY", platform)
        self.assertIn("ev_keydown", platform)
        self.assertIn("ev_keyup", platform)
        self.assertIn("D_PostEvent(&event)", platform)


if __name__ == "__main__":
    unittest.main()
