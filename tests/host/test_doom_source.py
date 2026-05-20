import hashlib
import re
import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
DOOM_ROOT = ROOT / "third_party" / "doom"
DOOM_SRC = DOOM_ROOT / "linuxdoom-1.10"
BUILD = ROOT / "build" / "doom"
DOOM_ELF = ROOT / "build" / "doom.elf"
DOOM_SYMBOLS = ROOT / "build" / "doom.symbols"
DOOM_BASE = 0x01000000

UPSTREAM_COMMIT = "a77dfb96cb91780ca334d0d4cfd86957558007e0"
UPSTREAM_TREE_FILE_COUNT = 126
UPSTREAM_TREE_SHA256 = "38ef8b80b6848e934c72d27cbbfa013c1e184544e9ddb6f100c4a15e565e3b83"
ORIGINAL_PLATFORM_SRCS = ("i_main.c", "i_net.c", "i_sound.c", "i_system.c", "i_video.c")
REQUIRED_PORT_SRCS = {"doom_port/libc.c", "doom_port/platform.c", "doom_port/start.c"}

PRISTINE_HASHES = {
    "README.TXT": "360d81775941de3c4ddc8e49b50024da4ac32cabdc4b86ba660514f58bfeeedb",
    "LICENSE.TXT": "32b1062f7da84967e7019d01ab805935caa7ab7321a7ced0e30ebe75e5df1670",
    "linuxdoom-1.10/README.b": "f2e4c3a41755e47190f7b872e926da2b6fd01eca972b0379d58644f9f445f93e",
    "linuxdoom-1.10/m_bbox.c": "98f3aea4f43d4d75fe452a25a65678fbd8368cfef3928b869767996e2165f42c",
    "linuxdoom-1.10/m_fixed.c": "a4472841bc8890c5d5a41b325ecf56d10d7026a7489967aa29100b5dee759fea",
    "linuxdoom-1.10/m_random.c": "8d89f5cfcbbd0170e46b55538c4c272b3cf5b5d7dce91023b8aa8d9b922b21ee",
    "linuxdoom-1.10/m_swap.c": "3622bd59399d7c0b740014fe75f2c2e222e4940a76782755298050e640e2f4bb",
}


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def upstream_manifest_paths():
    paths = [Path("README.TXT"), Path("LICENSE.TXT")]
    paths.extend(
        sorted(
            Path("linuxdoom-1.10") / path.name
            for path in (DOOM_SRC).glob("*.[ch]")
        )
    )
    return paths


def upstream_tree_sha256():
    digest = hashlib.sha256()
    for relpath in upstream_manifest_paths():
        digest.update(relpath.as_posix().encode("utf-8"))
        digest.update(b"\0")
        digest.update(sha256(DOOM_ROOT / relpath).encode("ascii"))
        digest.update(b"\n")
    return digest.hexdigest()


def u16(data, offset):
    return int.from_bytes(data[offset:offset + 2], "little")


def u32(data, offset):
    return int.from_bytes(data[offset:offset + 4], "little")


class DoomSourceTests(unittest.TestCase):
    def test_origin_records_official_id_release(self):
        origin = (DOOM_ROOT / "ORIGIN.md").read_text()
        self.assertIn("https://github.com/id-Software/DOOM", origin)
        self.assertIn(UPSTREAM_COMMIT, origin)
        self.assertIn("keep this vendor tree pristine", origin)

    def test_selected_upstream_files_are_pristine(self):
        for relpath, expected in PRISTINE_HASHES.items():
            with self.subTest(relpath=relpath):
                self.assertEqual(sha256(DOOM_ROOT / relpath), expected)

    def test_upstream_linuxdoom_manifest_is_pristine(self):
        paths = upstream_manifest_paths()
        self.assertEqual(len(paths), UPSTREAM_TREE_FILE_COUNT)
        self.assertEqual(upstream_tree_sha256(), UPSTREAM_TREE_SHA256)

    def test_third_party_doom_worktree_is_pristine(self):
        result = subprocess.run(
            [
                "git",
                "status",
                "--porcelain=v1",
                "--untracked-files=all",
                "--",
                "third_party/doom",
            ],
            cwd=ROOT,
            capture_output=True,
            text=True,
            check=False,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, "", result.stdout)

    def test_linuxdoom_tree_is_the_real_engine_drop(self):
        source_files = sorted(DOOM_SRC.glob("*.c"))
        header_files = sorted(DOOM_SRC.glob("*.h"))
        self.assertGreaterEqual(len(source_files), 60)
        self.assertGreaterEqual(len(header_files), 60)
        for name in ("d_main.c", "g_game.c", "r_main.c", "w_wad.c", "z_zone.c"):
            self.assertTrue((DOOM_SRC / name).exists())

    def test_original_doom_modules_compile_as_freestanding_i386_objects(self):
        compiled_sources = [
            path for path in DOOM_SRC.glob("*.c")
            if not path.name.startswith("i_")
        ]
        self.assertEqual(len(compiled_sources), 57)
        for source in compiled_sources:
            with self.subTest(name=source.name):
                obj = BUILD / f"{source.stem}.o"
                self.assertTrue(obj.exists())
                self.assertGreater(obj.stat().st_size, 0)
        self.assertTrue((BUILD / "d_net.o").exists())

    def test_linux_platform_sources_are_not_used_as_the_os_port(self):
        for name in ORIGINAL_PLATFORM_SRCS:
            with self.subTest(name=name):
                self.assertFalse((BUILD / f"{Path(name).stem}.o").exists())

    def test_makefile_keeps_original_engine_and_port_boundary_clear(self):
        makefile = (ROOT / "Makefile").read_text()
        port_match = re.search(r"^DOOM_PORT_SRCS := (.+)$", makefile, re.MULTILINE)
        self.assertIsNotNone(port_match)
        port_sources = set(port_match.group(1).split())
        self.assertIn("DOOM_SRC_DIR := third_party/doom/linuxdoom-1.10", makefile)
        self.assertIn(
            "DOOM_ORIGINAL_SRCS := $(filter-out $(DOOM_SRC_DIR)/i_%.c,$(wildcard $(DOOM_SRC_DIR)/*.c))",
            makefile,
        )
        self.assertIn(
            "DOOM_ORIGINAL_OBJS := $(DOOM_ORIGINAL_SRCS:$(DOOM_SRC_DIR)/%.c=$(DOOM_PORT_BUILD_DIR)/%.o)",
            makefile,
        )
        self.assertTrue(REQUIRED_PORT_SRCS.issubset(port_sources))
        for source in port_sources:
            with self.subTest(port_source=source):
                self.assertTrue(source.startswith("doom_port/"))
                self.assertTrue(source.endswith(".c"))
                self.assertNotIn("third_party/doom", source)
                self.assertTrue((ROOT / source).exists())
        self.assertIn("$(DOOM_PORT_BUILD_DIR)/%.o: $(DOOM_SRC_DIR)/%.c", makefile)
        self.assertIn("$(DOOM_PORT_BUILD_DIR)/port_%.o: doom_port/%.c", makefile)
        self.assertIn(
            "tools/link_elf32.py -o $@ --base $(DOOM_BASE) --map $(DOOM_SYMBOLS) $(DOOM_ORIGINAL_OBJS) $(DOOM_PORT_OBJS)",
            makefile,
        )
        for forbidden in ("doomgeneric", "chocolate", "crispy", "prboom", "sourceport"):
            self.assertNotIn(forbidden, makefile.lower())

    def test_no_wrapper_engine_or_binary_game_artifacts_are_tracked(self):
        result = subprocess.run(
            ["python3", "tools/check_repo_hygiene.py"],
            cwd=ROOT,
            capture_output=True,
            text=True,
            check=False,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_repo_hygiene_scans_for_shortcut_runtime_paths(self):
        checker = (ROOT / "tools" / "check_repo_hygiene.py").read_text()
        for token in (
            "vendor_tree_status",
            "FORBIDDEN_RUNTIME_CONTENT",
            "RUNTIME_SOURCE_PREFIXES",
            "third_party/doom must remain a pristine vendor tree",
            "runtime/build source references",
            "shortcut Doom engine or host API token",
            "sdl_init",
            "xopendisplay",
        ):
            with self.subTest(token=token):
                self.assertIn(token.lower(), checker.lower())

    def test_original_doom_links_against_vibe_os_platform_layer(self):
        data = DOOM_ELF.read_bytes()
        self.assertEqual(data[:4], b"\x7fELF")
        self.assertEqual(data[4], 1)
        self.assertEqual(data[5], 1)
        self.assertEqual(u16(data, 16), 2)
        self.assertEqual(u16(data, 18), 3)
        self.assertGreaterEqual(u32(data, 24), DOOM_BASE)
        self.assertGreaterEqual(u16(data, 44), 2)
        program_header = u32(data, 28)
        self.assertEqual(u32(data, program_header), 1)
        self.assertEqual(u32(data, program_header + 8), DOOM_BASE)
        load_segments = [
            program_header + index * u16(data, 42)
            for index in range(u16(data, 44))
            if u32(data, program_header + index * u16(data, 42)) == 1
        ]
        self.assertTrue(any(u32(data, ph + 24) & 0x1 for ph in load_segments))
        self.assertTrue(any(u32(data, ph + 24) & 0x2 for ph in load_segments))
        self.assertTrue(all((u32(data, ph + 24) & 0x2) == 0 for ph in load_segments if u32(data, ph + 24) & 0x1))
        self.assertGreater(max(u32(data, ph + 8) + u32(data, ph + 20) for ph in load_segments), DOOM_BASE + 8 * 1024 * 1024)

    def test_original_doom_symbol_map_is_available_for_cloud_fault_triage(self):
        text = DOOM_SYMBOLS.read_text()
        self.assertIn("# vibe-os-symbol-map-v1", text)
        self.assertRegex(
            text,
            r"(?m)^[0-9A-F]{8}\t[0-9A-F]{8}\tFUNC\tGLOBAL\t\.text\t.*\tD_DoomMain$",
        )
        self.assertRegex(
            text,
            r"(?m)^[0-9A-F]{8}\t[0-9A-F]{8}\tFUNC\tGLOBAL\t\.text\t.*\tW_CheckNumForName$",
        )


if __name__ == "__main__":
    unittest.main()
