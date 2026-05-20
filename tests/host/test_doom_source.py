import hashlib
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
DOOM_ROOT = ROOT / "third_party" / "doom"
DOOM_SRC = DOOM_ROOT / "linuxdoom-1.10"
BUILD = ROOT / "build" / "doom"
DOOM_ELF = ROOT / "build" / "doom.elf"
DOOM_BASE = 0x01000000

UPSTREAM_COMMIT = "a77dfb96cb91780ca334d0d4cfd86957558007e0"

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
        excluded = ("i_main.c", "i_net.c", "i_sound.c", "i_system.c", "i_video.c")
        for name in excluded:
            with self.subTest(name=name):
                self.assertFalse((BUILD / f"{Path(name).stem}.o").exists())

    def test_original_doom_links_against_vibe_os_platform_layer(self):
        data = DOOM_ELF.read_bytes()
        self.assertEqual(data[:4], b"\x7fELF")
        self.assertEqual(data[4], 1)
        self.assertEqual(data[5], 1)
        self.assertEqual(u16(data, 16), 2)
        self.assertEqual(u16(data, 18), 3)
        self.assertGreaterEqual(u32(data, 24), DOOM_BASE)
        self.assertEqual(u16(data, 44), 1)
        program_header = u32(data, 28)
        self.assertEqual(u32(data, program_header), 1)
        self.assertEqual(u32(data, program_header + 8), DOOM_BASE)
        self.assertGreater(u32(data, program_header + 20), 8 * 1024 * 1024)


if __name__ == "__main__":
    unittest.main()
