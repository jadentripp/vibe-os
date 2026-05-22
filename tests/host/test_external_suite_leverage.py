import gzip
import importlib.util
import os
import re
import struct
import subprocess
import sys
import tempfile
import unittest
import zipfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
MAKE_WAD_IMAGE = ROOT / "tools" / "make_wad_image.py"
CHECK_REPO_HYGIENE = ROOT / "tools" / "check_repo_hygiene.py"
LINK_ELF32 = ROOT / "tools" / "link_elf32.py"
CLANG = os.environ.get("CLANG", "clang")


def load_tool(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


make_wad_image = load_tool("make_wad_image_external_suite", MAKE_WAD_IMAGE)
check_repo_hygiene = load_tool("check_repo_hygiene_external_suite", CHECK_REPO_HYGIENE)
_BASE_IMAGE = None


def u16(data, offset):
    return struct.unpack_from("<H", data, offset)[0]


def u32(data, offset):
    return struct.unpack_from("<I", data, offset)[0]


def fresh_image():
    global _BASE_IMAGE
    if _BASE_IMAGE is None:
        _BASE_IMAGE = bytes(
            make_wad_image.install_bootable_layout(
                bytearray(make_wad_image.IMAGE_SECTORS * make_wad_image.SECTOR_SIZE)
            )
        )
    return bytearray(_BASE_IMAGE)


def minimal_wad(kind=b"IWAD"):
    wad = bytearray(28)
    wad[0:4] = kind
    struct.pack_into("<II", wad, 4, 1, 12)
    struct.pack_into("<II8s", wad, 12, 0, 0, b"EMPTY\0\0\0")
    return bytes(wad)


def parse_syscall_numbers():
    header = (ROOT / "doom_port" / "include" / "vibe_os.h").read_text()
    kernel = (ROOT / "kernel" / "kernel.asm").read_text()
    header_numbers = {
        name: int(value)
        for name, value in re.findall(r"\bVIBE_SYS_([A-Z0-9_]+)\s*=\s*(\d+)", header)
    }
    kernel_numbers = {
        name: int(value)
        for name, value in re.findall(r"^SYS_([A-Z0-9_]+)\s+equ\s+(\d+)", kernel, re.MULTILINE)
    }
    return header_numbers, kernel_numbers


def compile_i386_object(tmpdir, name, source):
    obj = tmpdir / f"{name}.o"
    result = subprocess.run(
        [
            CLANG,
            "-target",
            "i386-unknown-elf",
            "-std=gnu89",
            "-ffreestanding",
            "-fno-builtin",
            "-fno-stack-protector",
            "-fno-pic",
            "-fno-asynchronous-unwind-tables",
            "-fno-unwind-tables",
            "-m32",
            "-x",
            "c",
            "-c",
            "-",
            "-o",
            str(obj),
        ],
        cwd=ROOT,
        input=source,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if result.returncode != 0:
        raise AssertionError(result.stdout + result.stderr)
    return obj


def elf_load_segments(data):
    if data[:4] != b"\x7fELF":
        raise AssertionError("missing ELF magic")
    if data[4] != 1 or data[5] != 1:
        raise AssertionError("expected ELF32 little-endian")
    phoff = u32(data, 28)
    phentsize = u16(data, 42)
    phnum = u16(data, 44)
    headers = []
    for index in range(phnum):
        offset = phoff + index * phentsize
        header = struct.unpack_from("<IIIIIIII", data, offset)
        if header[0] == 1:
            headers.append(header)
    return u32(data, 24), headers


class ExternalSuiteLeverageTests(unittest.TestCase):
    def test_libc_conformance_subset_host_harness_passes(self):
        source = ROOT / "tests" / "host" / "libc_conformance_subset_test.c"
        with tempfile.TemporaryDirectory() as tmp:
            binary = Path(tmp) / "libc_conformance_subset_test"
            subprocess.run(
                [
                    CLANG,
                    "-std=gnu89",
                    "-Wall",
                    "-Wextra",
                    "-Wno-pointer-to-int-cast",
                    "-Wno-void-pointer-to-int-cast",
                    "-I",
                    str(ROOT / "doom_port" / "include"),
                    str(source),
                    "-o",
                    str(binary),
                ],
                check=True,
                cwd=ROOT,
            )
            subprocess.run([str(binary)], check=True, cwd=ROOT)

    def test_syscall_numbers_match_public_header_and_kernel_table(self):
        header_numbers, kernel_numbers = parse_syscall_numbers()

        # The public header is the ABI small games and tools compile against.
        # Any VIBE_SYS_* number exported there must match the kernel table.
        for name in sorted(header_numbers):
            with self.subTest(syscall=name):
                self.assertIn(name, kernel_numbers)
                self.assertEqual(header_numbers[name], kernel_numbers[name])

    def test_public_abi_layout_compiles_as_an_i386_contract(self):
        abi_source = r"""
            #include "fcntl.h"
            #include "sys/stat.h"
            #include "vibe_os.h"

            #define CHECK(name, expr) typedef char check_##name[(expr) ? 1 : -1]

            CHECK(open_flags, O_ACCMODE == 0x0003 && O_CLOEXEC == 0x0800);
            CHECK(syscall_fcntl, VIBE_SYS_FCNTL == 35);
            CHECK(clock_bytes, sizeof(vibe_clock_time_t) == 16);
            CHECK(dirent_bytes, sizeof(vibe_dirent_t) == VIBE_DIRENT_BYTES);
            CHECK(dirent_attr_offset, __builtin_offsetof(vibe_dirent_t, attributes) == 28);
            CHECK(input_queue_usable, VIBE_INPUT_EVENT_QUEUE_USABLE_CAPACITY == 63);
            CHECK(input_overflow_policy, VIBE_INPUT_QUEUE_OVERFLOW_DROP_OLDEST == 1);
            CHECK(input_event_bytes, sizeof(vibe_input_event_t) == VIBE_INPUT_EVENT_BYTES);
            CHECK(input_event_value0_offset, __builtin_offsetof(vibe_input_event_t, value0) == 16);
            CHECK(input_status_bytes, sizeof(vibe_input_status_t) == VIBE_INPUT_STATUS_BYTES);
            CHECK(input_status_keys_offset, __builtin_offsetof(vibe_input_status_t, keyboard_state) == 48);
            CHECK(input_status_mouse_offset, __builtin_offsetof(vibe_input_status_t, mouse_delta_x_total) == 96);
            CHECK(input_status_policy_offset, __builtin_offsetof(vibe_input_status_t, overflow_policy) == 120);
            CHECK(input_status_current_bytes, VIBE_INPUT_STATUS_BYTES == 132);
            CHECK(input_status_abi_version, VIBE_INPUT_ABI_VERSION == 2);
            CHECK(audio_voice_bytes, sizeof(vibe_audio_voice_desc_t) == VIBE_AUDIO_VOICE_DESC_BYTES);
            CHECK(audio_device_bytes, sizeof(vibe_audio_device_info_t) == VIBE_AUDIO_DEVICE_INFO_BYTES);
            CHECK(audio_ring_bytes, sizeof(vibe_audio_pcm_ring_info_t) == VIBE_AUDIO_PCM_RING_INFO_BYTES);
            CHECK(audio_stream_bytes, sizeof(vibe_audio_stream_info_t) == VIBE_AUDIO_STREAM_INFO_BYTES);
            CHECK(fb_info_bytes, sizeof(vibe_fb_info_t) == 84);
            CHECK(fb_info_caps_offset, __builtin_offsetof(vibe_fb_info_t, capabilities) == 68);
            CHECK(present_indexed_bytes, sizeof(vibe_present_indexed_t) == 16);
            CHECK(exec_bounds, VIBE_EXEC_PATH_MAX == 16 && VIBE_EXEC_ARG_MAX == 8);
            CHECK(stat_size_offset, __builtin_offsetof(struct stat, st_size) == 28);
            CHECK(stat_bytes, sizeof(struct stat) == 44);
        """
        result = subprocess.run(
            [
                CLANG,
                "-target",
                "i386-unknown-elf",
                "-std=gnu89",
                "-ffreestanding",
                "-Wall",
                "-Wextra",
                "-Werror",
                "-I",
                str(ROOT / "doom_port" / "include"),
                "-x",
                "c",
                "-fsyntax-only",
                "-",
            ],
            cwd=ROOT,
            input=abi_source,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_fat_fuzz_fixtures_catch_duplicate_shared_orphaned_and_looped_clusters(self):
        cases = []

        def duplicate_entry(fs):
            name_a = b"FUZZA   TXT"
            name_b = b"FUZZB   TXT"
            fs.write_root_file(name_a, b"A" * (make_wad_image.cluster_size() + 3))
            entry_a = fs.root_entry_offset(name_a)
            entry_b = fs.create_or_reuse_root_entry(name_b)
            fs.image[entry_b:entry_b + 32] = fs.image[entry_a:entry_a + 32]

        cases.append(("duplicate", duplicate_entry, "duplicate live FAT16 directory entry"))

        def shared_cluster(fs):
            name_a = b"SHAREA  BIN"
            name_b = b"SHAREB  BIN"
            chain_a = fs.write_root_file(name_a, b"A" * (make_wad_image.cluster_size() + 1))
            fs.write_root_file(name_b, b"B" * make_wad_image.cluster_size())
            entry_b = fs.root_entry_offset(name_b)
            make_wad_image.write_le16(fs.image, entry_b + 26, chain_a[0])

        cases.append(("shared", shared_cluster, "is shared by"))

        def orphaned_cluster(fs):
            name = b"ORPHAN  BIN"
            fs.write_root_file(name, b"O" * make_wad_image.cluster_size())
            fs.image[fs.root_entry_offset(name)] = 0xE5

        cases.append(("orphaned", orphaned_cluster, "not reachable from any live root entry"))

        def looped_chain(fs):
            name = b"LOOP    BIN"
            chain = fs.write_root_file(name, b"L" * (make_wad_image.cluster_size() * 2 + 1))
            fs.set_fat_entry(chain[-1], chain[0])

        cases.append(("looped", looped_chain, "contains a loop"))

        for label, mutate, pattern in cases:
            with self.subTest(label=label):
                fs = make_wad_image.Fat16Image(fresh_image())
                mutate(fs)
                with self.assertRaisesRegex(ValueError, pattern):
                    fs.validate_allocated_clusters_reachable()

    def test_elf_loader_fixtures_link_good_objects_and_reject_bad_ones(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            good = compile_i386_object(
                tmpdir,
                "good",
                """
                const unsigned int ro_marker = 0x12345678u;
                unsigned int rw_marker = 7u;
                unsigned char bss_marker[32];
                void helper(void) { rw_marker += ro_marker; }
                void start(void) { helper(); bss_marker[0] = (unsigned char)rw_marker; }
                """,
            )
            linked = tmpdir / "good.elf"
            symbol_map = tmpdir / "good.symbols"
            result = subprocess.run(
                [
                    sys.executable,
                    str(LINK_ELF32),
                    "-o",
                    str(linked),
                    "--base",
                    "0x00300000",
                    "--map",
                    str(symbol_map),
                    str(good),
                ],
                cwd=ROOT,
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            entry, load_segments = elf_load_segments(linked.read_bytes())
            self.assertGreaterEqual(entry, 0x00300000)
            self.assertTrue(any((segment[6] & 0x5) == 0x5 for segment in load_segments))
            self.assertTrue(any((segment[6] & 0x6) == 0x6 for segment in load_segments))
            self.assertIn("start", symbol_map.read_text())
            self.assertIn("bss_marker", symbol_map.read_text())

            dup_a = compile_i386_object(
                tmpdir,
                "dup_a",
                "int duplicate_symbol = 1; void start(void) { }",
            )
            dup_b = compile_i386_object(
                tmpdir,
                "dup_b",
                "int duplicate_symbol = 2;",
            )
            duplicate = subprocess.run(
                [
                    sys.executable,
                    str(LINK_ELF32),
                    "-o",
                    str(tmpdir / "duplicate.elf"),
                    "--base",
                    "0x00300000",
                    str(dup_a),
                    str(dup_b),
                ],
                cwd=ROOT,
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            self.assertNotEqual(duplicate.returncode, 0)
            self.assertIn("duplicate symbol: duplicate_symbol", duplicate.stderr)

            no_start = compile_i386_object(tmpdir, "no_start", "int only_data = 3;")
            missing = subprocess.run(
                [
                    sys.executable,
                    str(LINK_ELF32),
                    "-o",
                    str(tmpdir / "missing.elf"),
                    "--base",
                    "0x00300000",
                    str(no_start),
                ],
                cwd=ROOT,
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            self.assertNotEqual(missing.returncode, 0)
            self.assertIn("missing kernel entry symbol: start", missing.stderr)

    def test_wad_boundary_fixtures_accept_iwad_pwad_and_reject_parser_spoofing(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            for kind in (b"IWAD", b"PWAD"):
                with self.subTest(kind=kind):
                    path = tmpdir / f"{kind.decode('ascii').lower()}.wad"
                    path.write_bytes(minimal_wad(kind))
                    loaded = make_wad_image.load_external_wad(path)
                    self.assertEqual(loaded[0:4], kind)

            bad_magic = tmpdir / "bad-magic.wad"
            bad_magic.write_bytes(b"NOPE" + b"\0" * 24)
            with self.assertRaisesRegex(ValueError, "does not start with IWAD or PWAD"):
                make_wad_image.load_external_wad(bad_magic)

            tiny = tmpdir / "tiny.wad"
            tiny.write_bytes(b"IWAD")
            with self.assertRaisesRegex(ValueError, "too small to be a WAD"):
                make_wad_image.load_external_wad(tiny)

            outside = bytearray(28)
            outside[0:4] = b"IWAD"
            struct.pack_into("<II", outside, 4, 1, 64)
            outside_path = tmpdir / "outside.wad"
            outside_path.write_bytes(outside)
            with self.assertRaisesRegex(ValueError, "directory outside the file"):
                make_wad_image.load_external_wad(outside_path)

    def test_artifact_hygiene_sniffs_renamed_payloads_and_upload_paths(self):
        self.assertEqual(
            check_repo_hygiene.forbidden_magic_label(b"IWAD" + b"\0" * 12),
            "WAD/IWAD payload",
        )
        self.assertTrue(
            check_repo_hygiene.path_matches(
                "build/disk.img",
                check_repo_hygiene.FORBIDDEN_UPLOAD_PATTERNS,
            )
        )
        uploads = check_repo_hygiene.upload_path_lines(
            """
            steps:
              - uses: actions/upload-artifact@v4
                with:
                  name: proof
                  path: |
                    build/status.txt
                    build/disk.img
            """
        )
        self.assertIn("build/status.txt", uploads)
        self.assertIn("build/disk.img", uploads)

        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            gzip_path = tmpdir / "renamed-proof.dat"
            with gzip.open(gzip_path, "wb") as handle:
                handle.write(b"IWAD" + b"\0" * 64)

            zip_path = tmpdir / "renamed-proof.bundle"
            with zipfile.ZipFile(zip_path, "w") as archive:
                archive.writestr("payload.bin", b"PWAD" + b"\0" * 64)

            old_root = check_repo_hygiene.ROOT
            check_repo_hygiene.ROOT = tmpdir
            try:
                gzip_prefix = gzip_path.read_bytes()[:check_repo_hygiene.ARCHIVE_PREFIX_BYTES]
                zip_prefix = zip_path.read_bytes()[:check_repo_hygiene.ARCHIVE_PREFIX_BYTES]
                self.assertIn(
                    "gzip-compressed WAD/IWAD payload",
                    check_repo_hygiene.archive_wad_violation(gzip_path.name, gzip_prefix),
                )
                self.assertIn(
                    "contains WAD/PWAD payload",
                    check_repo_hygiene.archive_wad_violation(zip_path.name, zip_prefix),
                )
            finally:
                check_repo_hygiene.ROOT = old_root


if __name__ == "__main__":
    unittest.main()
