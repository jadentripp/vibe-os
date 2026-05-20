import struct
import subprocess
import sys
import tempfile
import unittest
import importlib.util
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
BUILD = ROOT / "build"
TOOL = ROOT / "tools" / "make_wad_image.py"
spec = importlib.util.spec_from_file_location("make_wad_image", TOOL)
make_wad_image = importlib.util.module_from_spec(spec)
spec.loader.exec_module(make_wad_image)
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
        self.assertTrue(any(name == ".bss" and kind == 8 and size >= 12 for name, kind, size in sections))

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

    def fat_chain(self, cluster, limit=8192):
        chain = []
        while cluster < 0xFFF8:
            if cluster < 2:
                raise AssertionError("invalid FAT16 cluster in chain")
            chain.append(cluster)
            if len(chain) > limit:
                raise AssertionError("FAT16 chain did not terminate")
            cluster = self.fat_entry(cluster)
        return chain

    def free_data_clusters(self):
        boot = self.partition_lba * SECTOR_SIZE
        total_sectors = u16(self.image, boot + 19) or u32(self.image, boot + 32)
        root_sectors = (self.root_entries * 32 + SECTOR_SIZE - 1) // SECTOR_SIZE
        data_sectors = total_sectors - self.reserved - self.fat_count * self.sectors_per_fat - root_sectors
        clusters = data_sectors // self.image[boot + 13]
        return sum(1 for cluster in range(2, clusters + 2) if self.fat_entry(cluster) == 0)

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

    def test_fat_root_contains_dynamic_writable_placeholders(self):
        entries = self.root_entries_by_name()
        for raw_name, _capacity in make_wad_image.WRITABLE_DYNAMIC_FILES:
            name = raw_name.decode("ascii")
            with self.subTest(name=name):
                entry = entries[name]
                self.assertEqual(entry["size"], 0)
                self.assertEqual(entry["cluster"], 0)

        self.assertGreaterEqual(
            self.free_data_clusters(),
            make_wad_image.MIN_OS_CREATED_FILE_CLUSTERS,
        )

    def test_fat16_mutator_allocates_reuses_and_truncates_root_83_file(self):
        image = bytearray(self.image)
        fs = make_wad_image.Fat16Image(image)
        name = b"DYNTEST TXT"
        payload = b"dynamic fat write\n" * 40
        before_free = fs.free_data_clusters()

        chain = fs.write_root_file(name, payload)
        entry = fs.root_entry_offset(name)

        self.assertIsNotNone(entry)
        self.assertEqual(u16(image, entry + 26), chain[0])
        self.assertEqual(u32(image, entry + 28), len(payload))
        self.assertEqual(fs.fat_entry(chain[0]), chain[1] if len(chain) > 1 else 0xFFFF)
        self.assertEqual(fs.fat_entry(chain[-1]), 0xFFFF)
        first_data = fs.data_lba * SECTOR_SIZE + (chain[0] - 2) * SECTOR_SIZE
        self.assertEqual(image[first_data:first_data + len(payload[:SECTOR_SIZE])], payload[:SECTOR_SIZE])
        self.assertEqual(fs.free_data_clusters(), before_free - len(chain))

        reused = fs.create_or_reuse_root_entry(name)
        self.assertEqual(reused, entry)

        freed = fs.truncate_root_file(name)
        self.assertEqual(freed, chain)
        self.assertEqual(u16(image, entry + 26), 0)
        self.assertEqual(u32(image, entry + 28), 0)
        for cluster in chain:
            self.assertEqual(fs.fat_entry(cluster), 0)
        self.assertEqual(fs.free_data_clusters(), before_free)

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
        entries = {}
        for off in range(0, root_size, 32):
            name = root[off:off + 11]
            if name[0] == 0:
                break
            entries[name.decode("ascii")] = {
                "cluster": u16(root, off + 26),
                "size": u32(root, off + 28),
            }
        self.assertIn("DEFAULT CFG", entries)
        self.assertIn("DOOMSAV0DSG", entries)
        self.assertEqual(entries["DEFAULT CFG"]["size"], 0)
        self.assertEqual(entries["DOOMSAV0DSG"]["size"], 0)

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
        smoke_runner = (ROOT / "tests" / "run_smoke_qemu.sh").read_text()
        gitignore = (ROOT / ".gitignore").read_text()
        os_smoke_workflow = (ROOT / ".github" / "workflows" / "os-smoke.yml").read_text()
        real_wad_workflow = (ROOT / ".github" / "workflows" / "real-wad-smoke.yml").read_text()
        self.assertIn("ALLOW_LOCAL_VM ?= 0", makefile)
        self.assertIn("DOOM_WAD ?=", makefile)
        self.assertIn("SMOKE_EXPECT_PROBE_GFX ?= 1", makefile)
        self.assertIn("SMOKE_REJECT_DOOMLOG ?=", makefile)
        self.assertIn("SMOKE_SENDKEYS ?=", makefile)
        self.assertIn("SMOKE_REQUIRE_DOOM_PRESENT ?= 0", makefile)
        self.assertIn("SMOKE_REQUIRE_KEY_EVENT ?= 0", makefile)
        self.assertIn("SMOKE_REQUIRE_DOOM_GAMEPLAY ?= 0", makefile)
        self.assertIn("SMOKE_NC_TIMEOUT ?= 3", makefile)
        self.assertIn("SMOKE_QEMU_TIMEOUT ?= 30", makefile)
        self.assertIn("SMOKE_EARLY_SECONDS ?= 2", makefile)
        self.assertIn("SMOKE_SETTLE_SECONDS ?= 5", makefile)
        self.assertIn("SMOKE_CAPTURE_GFX ?= 1", makefile)
        self.assertIn("--wad", makefile)
        self.assertIn('"$NC" -w "$SMOKE_NC_TIMEOUT" -U "$monitor_sock"', smoke_runner)
        self.assertIn("tests/run_smoke_qemu.sh", makefile)
        self.assertIn('-serial "file:$serial_log"', smoke_runner)
        self.assertIn("capture_snapshot early", smoke_runner)
        self.assertIn("QEMU smoke timed out", smoke_runner)
        self.assertIn("QEMU exited unexpectedly", smoke_runner)
        self.assertIn("run: vm-consent", makefile)
        self.assertIn("smoke: vm-consent", makefile)
        self.assertIn("*.wad", gitignore)
        self.assertIn("*.WAD", gitignore)
        self.assertIn("workflow_dispatch:", real_wad_workflow)
        self.assertIn("wad_url:", real_wad_workflow)
        self.assertIn("REAL_DOOM_WAD_URL", real_wad_workflow)
        self.assertIn("PUBLIC_SHAREWARE_WAD_GZ_URL", real_wad_workflow)
        self.assertIn("archive.org/download/wadarchive", real_wad_workflow)
        self.assertIn("EXPECTED_WAD_SHA1: 5b2e249b9c5133ec987b3ea77596381dc0d6bc1d", real_wad_workflow)
        self.assertIn('EXPECTED_WAD_BYTES: "4196020"', real_wad_workflow)
        self.assertIn("gzip.decompress", real_wad_workflow)
        self.assertIn("zipfile.ZipFile", real_wad_workflow)
        self.assertIn("hashlib.sha1", real_wad_workflow)
        self.assertIn("SMOKE_EXPECT_PROBE_GFX=0", real_wad_workflow)
        self.assertIn("SMOKE_CAPTURE_GFX=0", real_wad_workflow)
        self.assertIn("SMOKE_QEMU_TIMEOUT=45", real_wad_workflow)
        self.assertIn("SMOKE_EARLY_SECONDS=2", real_wad_workflow)
        self.assertIn("SMOKE_SETTLE_SECONDS=20", real_wad_workflow)
        self.assertIn("SMOKE_REQUIRE_DOOM_PRESENT=1", real_wad_workflow)
        self.assertIn("SMOKE_REQUIRE_DOOM_GAMEPLAY=1", real_wad_workflow)
        self.assertIn("SMOKE_REQUIRE_KEY_EVENT=1", real_wad_workflow)
        self.assertIn('SMOKE_SENDKEYS="spc"', real_wad_workflow)
        self.assertIn("SMOKE_REJECT_DOOMLOG=", real_wad_workflow)
        self.assertIn("timeout-minutes: 2", real_wad_workflow)
        self.assertIn("Show smoke diagnostics", real_wad_workflow)
        self.assertIn("build/status*.bin", real_wad_workflow)
        self.assertIn("build/status*.txt", real_wad_workflow)
        self.assertIn("build/vga*.txt", real_wad_workflow)
        self.assertIn("build/*.log", real_wad_workflow)
        self.assertNotIn("build/disk.img", real_wad_workflow)
        self.assertNotIn("build/gfx.bin", real_wad_workflow)
        self.assertNotIn("build/private", real_wad_workflow)
        os_upload_block = os_smoke_workflow.split("uses: actions/upload-artifact@v4", 1)[1]
        self.assertNotIn("build/gfx.bin", os_upload_block)

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
        self.assertIn("push dword [current_user_stack_top]", kernel)
        self.assertIn("push dword [current_user_entry]", kernel)
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

    def test_doom_autostarts_e1m1_and_reports_gameplay_state(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()
        platform = (ROOT / "doom_port" / "platform.c").read_text()
        start = (ROOT / "doom_port" / "start.c").read_text()
        header = (ROOT / "doom_port" / "include" / "vibe_os.h").read_text()
        makefile = (ROOT / "Makefile").read_text()
        for source in (
            'static char arg_warp[] = "-warp";',
            'static char arg_episode[] = "1";',
            'static char arg_map[] = "1";',
            'static char arg_skill[] = "-skill";',
            'myargc = 6;',
        ):
            self.assertIn(source, start)
        self.assertIn("VIBE_SYS_GAMEPLAY_STATUS = 15", header)
        self.assertIn("static void report_gameplay_status(void)", platform)
        self.assertIn("VIBE_SYS_GAMEPLAY_STATUS", platform)
        self.assertIn("(unsigned long)gametic", platform)
        self.assertIn("(unsigned long)leveltime", platform)
        for source in (
            "SYS_GAMEPLAY_STATUS equ 15",
            "cmp eax, SYS_GAMEPLAY_STATUS",
            ".gameplay_status:",
            "doom_gameplay_status dd 0",
            "doom_gameplay_report_count dd 0",
            "doom_game_state dd 0",
            "doom_game_map_pair dd 0",
            "doom_game_tic dd 0",
            "doom_level_time dd 0",
            'smoke_gameplay_text db " gameplay="',
            'smoke_gstate_text db " gstate="',
            'smoke_gmap_text db " gmap="',
            'smoke_gtic_text db " gtic="',
            'smoke_leveltime_text db " leveltime="',
        ):
            self.assertIn(source, kernel)
        self.assertIn('grep -q "gameplay="', makefile)
        self.assertIn('grep -q "gameplay=OK"', makefile)
        self.assertIn("/gstate=([0-9A-F]{8})/", makefile)
        self.assertIn("hex($$1) == 0x00000101", makefile)
        self.assertIn("/leveltime=([0-9A-F]{8})/", makefile)

    def test_user_syscalls_validate_against_current_process_window(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()
        validator = kernel.split("user_range_validate:", 1)[1].split("page_fault_handler:", 1)[0]
        self.assertIn("mov esi, [current_process_ptr]", validator)
        self.assertIn("mov edi, [esi + PROC_VM_REGIONS]", validator)
        self.assertIn("mov ecx, [esi + PROC_VM_REGION_COUNT]", validator)
        self.assertIn("cmp eax, [edi + VM_REGION_BASE]", validator)
        self.assertIn("cmp edx, ebx", validator)
        self.assertIn("test dword [edi + VM_REGION_FLAGS], VM_REGION_HEAP", validator)
        self.assertIn("mov ebx, [esi + PROC_BRK]", validator)
        self.assertNotIn("cmp eax, [current_user_base]", validator)
        self.assertNotIn("cmp edx, [current_user_end]", validator)
        self.assertNotIn("cmp eax, USER_CODE_ADDR", validator)
        self.assertNotIn("cmp edx, USER_HEAP_END", validator)
        sbrk = kernel.split(".sbrk:", 1)[1].split(".open:", 1)[0]
        self.assertIn("mov esi, [current_process_ptr]", sbrk)
        self.assertIn("mov eax, [esi + PROC_BRK]", sbrk)
        self.assertIn("cmp edx, [esi + PROC_HEAP_END]", sbrk)
        self.assertIn("mov [esi + PROC_BRK], edx", sbrk)

    def test_kernel_has_dynamic_fat16_writable_file_path(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()
        probe = (ROOT / "user" / "probe.c").read_text()
        libc = (ROOT / "doom_port" / "libc.c").read_text()
        image_tool = (ROOT / "tools" / "make_wad_image.py").read_text()
        for source in (
            "WRITABLE_DEFAULT_NAME = b\"DEFAULT CFG\"",
            "WRITABLE_SAVE_NAMES",
            "WRITABLE_DYNAMIC_FILES",
            "MIN_OS_CREATED_FILE_CLUSTERS",
            "allocate_cluster_chain",
            "free_cluster_chain",
            "truncate_root_file",
        ):
            self.assertIn(source, image_tool)
        for source in (
            "USER_FD_WRITABLE_BASE equ 4",
            "WRITABLE_FILE_COUNT equ 7",
            "ATA_CMD_WRITE_SECTORS equ 0x30",
            "ata_write_sector:",
            "fat_find_writable_files:",
            "fat_create_root_file:",
            "fat_alloc_cluster:",
            "fat_write_cluster_entry:",
            "fat_free_chain:",
            "fat_file_lba_for_write:",
            "fat_truncate_writable_file:",
            "fat_update_writable_size:",
            "user_file_read:",
            "user_file_write:",
            "user_file_lseek:",
            "DEFAULT CFG",
            "DOOMSAV0DSG",
            "SYS_CLOSE equ 12",
        ):
            self.assertIn(source, kernel)
        writer = kernel.split("user_file_write:", 1)[1].split("user_file_lseek:", 1)[0]
        self.assertIn("call fat_file_lba_for_write", writer)
        self.assertNotIn("call fat_file_lba_for_offset", writer)
        self.assertIn("PROBE_FLAG_WRITABLE_FILE = 0x40u", probe)
        self.assertIn("DEFAULT.CFG", probe)
        self.assertIn('return "DEFAULT.CFG";', libc)

    def test_kernel_has_real_process_table_and_scheduler_accounting(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()
        for source in (
            "PROCESS_SLOT_COUNT equ 3",
            "PROCESS_RECORD_BYTES equ 128",
            "PROC_SAVED_EIP equ 76",
            "PROC_QUANTUM_TICKS equ 100",
            "PROC_PAGE_DIR equ 108",
            "PROC_VM_REGIONS equ 112",
            "PROC_VM_REGION_COUNT equ 116",
            "PROC_FLAG_IRQ_FRAME_VALID equ 0x1",
            "SCHEDULER_QUANTUM_TICKS equ 5",
            "process_table:",
            "process_kernel:",
            "process_user_probe:",
            "process_doom:",
            "scheduler_init:",
            "process_activate:",
            "process_return_to_kernel:",
            "scheduler_tick:",
            "scheduler_select_next_ready:",
        ):
            self.assertIn(source, kernel)
        self.assertIn("dd 0, USER_KIND_NONE, PROC_STATE_READY", kernel)
        self.assertIn("dd 1, USER_KIND_PROBE, PROC_STATE_READY", kernel)
        self.assertIn("dd 2, USER_KIND_DOOM, PROC_STATE_READY", kernel)
        self.assertIn("call scheduler_init", kernel)
        self.assertIn("mov [current_process_ptr], esi", kernel)
        self.assertIn("mov [current_pid], eax", kernel)
        self.assertIn("inc dword [scheduler_context_switches]", kernel)

    def test_kernel_has_per_process_page_directories_and_vm_regions(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()
        for source in (
            "PTE_KERNEL_FLAGS equ PTE_PRESENT | PTE_WRITE",
            "PTE_USER_FLAGS equ PTE_PRESENT | PTE_WRITE | PTE_USER",
            "PROC_PROBE_PAGE_DIR_ADDR equ 0x00080000",
            "PROC_DOOM_PAGE_DIR_ADDR equ 0x00082000",
            "process_vm_init_page_spaces:",
            "vmm_mark_process_user_range:",
            "vmm_mark_process_user_page:",
            "vmm_clear_process_page:",
            "process_user_probe_vm_regions:",
            "process_doom_vm_regions:",
            "dd PROC_PROBE_PAGE_DIR_ADDR, process_user_probe_vm_regions, 2, 0, 0",
            "dd PROC_DOOM_PAGE_DIR_ADDR, process_doom_vm_regions, 3, 0, 0",
            "mov cr3, eax",
        ):
            self.assertIn(source, kernel)
        paging_init = kernel.split("paging_init:", 1)[1].split("pmm_init:", 1)[0]
        self.assertIn("or ebx, PTE_KERNEL_FLAGS", paging_init)
        self.assertIn("call process_vm_init_page_spaces", paging_init)
        self.assertIn("PROC_PROBE_PDE3_TABLE_ADDR | PTE_USER_FLAGS", paging_init)
        self.assertIn("PROC_DOOM_PDE4_TABLE_ADDR | PTE_USER_FLAGS", paging_init)
        self.assertIn("mov edx, USER_STACK_TOP", paging_init)
        self.assertIn("mov edx, DOOM_USER_HEAP_START", paging_init)
        self.assertIn("mov eax, DOOM_USER_STACK_BOTTOM", paging_init)
        self.assertIn("mov edx, DOOM_USER_STACK_TOP", paging_init)
        self.assertIn("mov eax, USER_CODE_ADDR - PAGE_SIZE", paging_init)
        self.assertIn("mov eax, USER_HEAP_END", paging_init)
        self.assertNotIn("call vmm_mark_user_identity_page", paging_init)
        sbrk = kernel.split(".sbrk:", 1)[1].split(".open:", 1)[0]
        self.assertIn("call vmm_mark_process_user_range", sbrk)
        self.assertIn("mov cr3, ebx", sbrk)

    def test_timer_path_saves_task_context_and_round_robin_state(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()
        irq_timer = kernel.split("irq_timer:", 1)[1].split("irq_keyboard:", 1)[0]
        scheduler = kernel.split("scheduler_tick:", 1)[1].split("process_save_irq_context:", 1)[0]
        save_irq = kernel.split("process_save_irq_context:", 1)[1].split("process_restore_irq_context:", 1)[0]
        restore_irq = kernel.split("process_restore_irq_context:", 1)[1].split("process_save_syscall_return_context:", 1)[0]
        save_syscall = kernel.split("process_save_syscall_return_context:", 1)[1].split("scheduler_select_next_ready:", 1)[0]
        selector = kernel.split("scheduler_select_next_ready:", 1)[1].split("scheduler_preempt_self_test:", 1)[0]
        selftest = kernel.split("scheduler_preempt_self_test:", 1)[1].split("user_probe_run:", 1)[0]
        self.assertIn("mov ebx, esp", irq_timer)
        self.assertIn("call scheduler_tick", irq_timer)
        self.assertIn("inc dword [scheduler_tick_count]", scheduler)
        self.assertIn("inc dword [esi + PROC_TICKS]", scheduler)
        self.assertIn("inc dword [esi + PROC_QUANTUM_TICKS]", scheduler)
        self.assertIn("test eax, 3", scheduler)
        self.assertIn("inc dword [scheduler_preempt_attempts]", scheduler)
        self.assertIn("call scheduler_select_next_ready", scheduler)
        self.assertIn("mov esi, [scheduler_next_process_ptr]", scheduler)
        self.assertIn("call process_activate", scheduler)
        self.assertIn("call process_restore_irq_context", scheduler)
        self.assertIn("inc dword [scheduler_preempt_switches]", scheduler)
        self.assertIn("inc dword [scheduler_preempt_skips]", scheduler)
        for field in ("PROC_SAVED_EAX", "PROC_SAVED_EIP", "PROC_SAVED_EFLAGS", "PROC_SAVED_CS", "PROC_SAVED_ESP", "PROC_SAVED_SS"):
            self.assertIn(field, save_irq)
            self.assertIn(field, restore_irq)
            self.assertIn(field, save_syscall)
        self.assertIn("or dword [esi + PROC_VM_FLAGS], PROC_FLAG_IRQ_FRAME_VALID", save_irq)
        self.assertIn("and dword [esi + PROC_VM_FLAGS], 0xfffffffe", save_irq)
        self.assertIn("test dword [edi + PROC_VM_FLAGS], PROC_FLAG_IRQ_FRAME_VALID", selector)
        self.assertIn("test dword [edi + PROC_SAVED_CS], 3", selector)
        self.assertIn("cmp dword [edi + PROC_SAVED_EIP], 0", selector)
        self.assertIn("mov [scheduler_next_process_ptr], edi", selector)
        self.assertIn("scheduler_preempt_selftest_frame times 13 dd 0", kernel)
        self.assertIn("scheduler_preempt_selftest_status db 0", kernel)
        self.assertIn("call scheduler_preempt_self_test", kernel)
        self.assertIn("call process_restore_irq_context", selftest)
        self.assertIn("cmp dword [scheduler_next_process_ptr], process_user_probe", selftest)
        self.assertIn('smoke_preempt_text db " preempt="', kernel)
        self.assertIn('smoke_pself_text db " pself="', kernel)

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
        smoke_runner = (ROOT / "tests" / "run_smoke_qemu.sh").read_text()
        self.assertIn("set_video_mode13:", stage2)
        self.assertIn("mov ax, 0x0013", stage2)
        self.assertIn("try_set_vbe_lfb:", stage2)
        self.assertIn("mov ax, 0x4f00", stage2)
        self.assertIn("mov ax, 0x4f01", stage2)
        self.assertIn("mov ax, 0x4f02", stage2)
        self.assertIn("BOOT_VIDEO_FB_ADDR", stage2)
        self.assertIn("BOOT_VIDEO_FLAG_XRGB8888", stage2)
        self.assertIn("SMOKE_STATUS_ADDR equ 0x0009d000", kernel)
        self.assertIn("SYS_PRESENT equ 10", kernel)
        self.assertIn("VGA_GRAPHICS_BUFFER equ 0x000a0000", kernel)
        self.assertIn("VIDEO_BACKEND_LFB_XRGB8888 equ 2", kernel)
        self.assertIn("FB_PAGE_TABLE_ADDR equ 0x0009c000", kernel)
        self.assertIn("framebuffer_map_lfb:", kernel)
        self.assertIn("framebuffer_init:", kernel)
        self.assertIn("present_indexed_frame:", kernel)
        self.assertIn("present_copy_indexed_shadow:", kernel)
        self.assertIn("present_lfb_xrgb8888:", kernel)
        self.assertIn("mov [edi + 4], eax", kernel)
        self.assertIn("mov [ebp + 4], eax", kernel)
        self.assertIn("mov dword [doom_present_count], 0", kernel)
        self.assertIn("mov byte [present_status], 0", kernel)
        self.assertIn('smoke_doompresent_text db " doompresent="', kernel)
        self.assertIn('smoke_fb_text db " fb="', kernel)
        self.assertIn('smoke_lfb_text db "LFB"', kernel)
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
        self.assertIn("pmemsave 0x9d000 1024", smoke_runner)
        self.assertIn("pmemsave 0xa0000 64000", smoke_runner)

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
        smoke_runner = (ROOT / "tests" / "run_smoke_qemu.sh").read_text()
        self.assertIn("for key in $SMOKE_SENDKEYS; do", smoke_runner)
        self.assertIn('send_monitor "sendkey $key" "sendkey $key\\n"', smoke_runner)
        self.assertIn('if [ -n "$SMOKE_SENDKEYS" ]; then', smoke_runner)
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

    def test_doom_mouse_events_flow_through_ps2_aux_and_syscall(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()
        platform = (ROOT / "doom_port" / "platform.c").read_text()
        header = (ROOT / "doom_port" / "include" / "vibe_os.h").read_text()
        makefile = (ROOT / "Makefile").read_text()
        mouse_doc = (ROOT / "docs" / "mouse-input.md").read_text()
        for source in (
            "SYS_POLL_MOUSE equ 14",
            "PS2_COMMAND_ENABLE_AUX equ 0xa8",
            "PS2_COMMAND_WRITE_AUX equ 0xd4",
            "PS2_MOUSE_SET_DEFAULTS equ 0xf6",
            "PS2_MOUSE_ENABLE_DATA equ 0xf4",
            "MOUSE_EVENT_VALID equ 0x01000000",
            "ps2_mouse_init:",
            "ps2_mouse_send_command:",
            "irq_mouse:",
            "mouse_queue_byte:",
            "mouse_decode_packet:",
            "mouse_event_queue times MOUSE_QUEUE_SIZE dd 0",
            "doom_mouse_event_count dd 0",
            'smoke_mouse_text db " mouse="',
            'smoke_mouseirq_text db " mouseirq="',
            'smoke_mousepkt_text db " mousepkt="',
            'smoke_mousepoll_text db " mousepoll="',
            "mov eax, irq_mouse",
            "idt_start + (44 * 8)",
            "out 0xa0, al",
        ):
            self.assertIn(source, kernel)
        for source in (
            "VIBE_SYS_POLL_MOUSE = 14",
            "VIBE_MOUSE_EVENT_VALID = 0x01000000u",
        ):
            self.assertIn(source, header)
        self.assertIn("vibe_syscall3(VIBE_SYS_POLL_MOUSE", platform)
        self.assertIn("event.type = ev_mouse", platform)
        self.assertIn("vibe_mouse_delta", platform)
        self.assertIn('grep -Eq "mouse=(OK|NONE)"', makefile)
        self.assertIn('grep -q "mouseirq="', makefile)
        self.assertIn('grep -q "mousepkt="', makefile)
        self.assertIn('grep -q "mousepoll="', makefile)
        self.assertIn("PS/2 auxiliary device", mouse_doc)
        self.assertIn("SYS_POLL_MOUSE", mouse_doc)

    def test_doom_sound_calls_flow_to_sb16_audio_scaffold(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()
        platform = (ROOT / "doom_port" / "platform.c").read_text()
        header = (ROOT / "doom_port" / "include" / "vibe_os.h").read_text()
        makefile = (ROOT / "Makefile").read_text()
        audio_doc = (ROOT / "docs" / "audio.md").read_text()
        for source in (
            "SYS_AUDIO equ 13",
            "SB16_BASE equ 0x0220",
            "SB16_DSP_RESET equ SB16_BASE + 0x06",
            "SB16_DSP_RESET_ACK equ 0xaa",
            "SB16_DSP_GET_VERSION equ 0xe1",
            "SB16_DSP_SPEAKER_ON equ 0xd1",
            "SB16_DSP_EXIT_8BIT_AUTO equ 0xda",
            "SB16_DSP_SET_TIME_CONSTANT equ 0x40",
            "SB16_DSP_SET_BLOCK_SIZE equ 0x48",
            "SB16_DSP_8BIT_AUTO_OUT equ 0x1c",
            "SB16_DMA8_CHANNEL equ 1",
            "SB16_DMA16_CHANNEL equ 5",
            "SB16_IRQ_LINE equ 5",
            "SB16_DMA_BUFFER_BYTES equ 4096",
            "SB16_DMA_BLOCK_BYTES equ SB16_DMA_BUFFER_BYTES / 2",
            "DMA8_MASK_REG equ 0x0a",
            "DMA8_MODE_REG equ 0x0b",
            "DMA8_CLEAR_FLIPFLOP_REG equ 0x0c",
            "DMA8_CH1_ADDR_REG equ 0x02",
            "DMA8_CH1_COUNT_REG equ 0x03",
            "DMA8_CH1_PAGE_REG equ 0x83",
            "DMA8_CH1_AUTO_READ_MODE equ 0x59",
            "audio_init:",
            "sb16_probe:",
            "sb16_reset_dsp:",
            "sb16_configure_mixer:",
            "sb16_program_dma8:",
            "sb16_start_playback:",
            "sb16_stop_playback:",
            "irq_audio:",
            "sb16_write_dsp:",
            "sb16_read_dsp:",
            "cmp eax, SYS_AUDIO",
            "cmp ebx, AUDIO_CMD_INIT",
            "cmp ebx, AUDIO_CMD_SHUTDOWN",
            "doom_sound_call_count dd 0",
            "doom_sound_start_count dd 0",
            "sb16_irq_count dd 0",
            "sb16_dma_program_count dd 0",
            "align 4096",
            "sb16_dma_buffer times SB16_DMA_BUFFER_BYTES db 0x80",
            'smoke_doomsound_text db " doomsound="',
            'smoke_audio_text db " audio="',
        ):
            self.assertIn(source, kernel)
        for source in (
            "VIBE_SYS_AUDIO = 13",
            "VIBE_AUDIO_START_SFX = 2",
            "VIBE_AUDIO_UPDATE_SFX = 4",
        ):
            self.assertIn(source, header)
        self.assertIn("vibe_syscall3(VIBE_SYS_AUDIO, VIBE_AUDIO_INIT", platform)
        self.assertIn("vibe_syscall3(VIBE_SYS_AUDIO, VIBE_AUDIO_START_SFX", platform)
        self.assertIn("vibe_syscall3(VIBE_SYS_AUDIO, VIBE_AUDIO_STOP_SFX", platform)
        self.assertIn("vibe_syscall3(VIBE_SYS_AUDIO, VIBE_AUDIO_UPDATE_SFX", platform)
        self.assertIn('grep -q "doomsound="', makefile)
        self.assertIn('grep -Eq "audio=(SB16|NONE)"', makefile)
        self.assertIn("test: $(IMAGE) doom-link", makefile)
        self.assertNotIn("test: vm-consent", makefile)
        self.assertIn("Sound Blaster 16", audio_doc)
        self.assertIn("8-bit DMA playback", audio_doc)


if __name__ == "__main__":
    unittest.main()
