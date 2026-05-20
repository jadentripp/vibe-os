import importlib.util
import struct
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
TOOL = ROOT / "tools" / "make_wad_image.py"

spec = importlib.util.spec_from_file_location("make_wad_image", TOOL)
make_wad_image = importlib.util.module_from_spec(spec)
spec.loader.exec_module(make_wad_image)


def u16(data, offset):
    return struct.unpack_from("<H", data, offset)[0]


def u32(data, offset):
    return struct.unpack_from("<I", data, offset)[0]


def lump_name(raw):
    return raw.rstrip(b"\0").decode("ascii")


def parse_lumps(wad):
    if wad[:4] != b"IWAD":
        raise AssertionError("generated fixture must be an IWAD-shaped file")
    lump_count = u32(wad, 4)
    directory = u32(wad, 8)
    if directory + lump_count * 16 > len(wad):
        raise AssertionError("WAD directory extends beyond fixture")

    lumps = []
    for index in range(lump_count):
        entry = directory + index * 16
        filepos = u32(wad, entry)
        size = u32(wad, entry + 4)
        name = lump_name(wad[entry + 8:entry + 16])
        if size and filepos + size > directory:
            raise AssertionError(f"{name} overlaps or extends beyond the WAD directory")
        lumps.append({
            "index": index,
            "name": name,
            "filepos": filepos,
            "size": size,
            "data": wad[filepos:filepos + size],
        })
    return lumps


def assert_synthetic_patch(testcase, data):
    testcase.assertEqual(u16(data, 0), 1)
    testcase.assertEqual(u16(data, 2), 1)
    testcase.assertEqual(u16(data, 4), 0)
    testcase.assertEqual(u16(data, 6), 0)
    column = u32(data, 8)
    testcase.assertLessEqual(column + 6, len(data))
    testcase.assertEqual(data[column:column + 6], b"\x00\x01\x00\x00\x00\xff")


class GeneratedWadTests(unittest.TestCase):
    def setUp(self):
        self.wad = make_wad_image.build_wad()
        self.lumps = parse_lumps(self.wad)
        self.by_name = {lump["name"]: lump for lump in self.lumps}

    def test_fixture_has_public_startup_lumps_but_not_doom_game_data(self):
        self.assertEqual(len(self.wad), make_wad_image.FIXTURE_WAD_SIZE)
        for name in (
            "PLAYPAL",
            "COLORMAP",
            "PNAMES",
            "TEXTURE1",
            "F_START",
            "F_END",
            "S_START",
            "S_END",
            "D_INTRO",
            "TITLEPIC",
            "STCFN033",
            "STFDEAD0",
        ):
            self.assertIn(name, self.by_name)

        self.assertNotIn("TEXTURE2", self.by_name)
        self.assertNotIn("DEMO1", self.by_name)
        # The public fixture is not a shareware-WAD replacement. Once startup
        # reaches attract-mode playback, the next intentional contract is DEMO1
        # and then complete E1M1 gameplay lumps supplied by a real external WAD.

    def test_pnames_references_only_the_generated_patch_lump(self):
        pnames = self.by_name["PNAMES"]["data"]
        self.assertEqual(u32(pnames, 0), 1)
        self.assertEqual(lump_name(pnames[4:12]), make_wad_image.SYNTHETIC_PATCH_NAME)
        assert_synthetic_patch(self, self.by_name[make_wad_image.SYNTHETIC_PATCH_NAME]["data"])

    def test_texture1_has_shareware_switch_placeholders(self):
        texture1 = self.by_name["TEXTURE1"]["data"]
        expected = make_wad_image.SHAREWARE_SWITCH_TEXTURES
        self.assertEqual(u32(texture1, 0), len(expected))

        directory_end = 4 + len(expected) * 4
        for index, name in enumerate(expected):
            offset = u32(texture1, 4 + index * 4)
            self.assertGreaterEqual(offset, directory_end)
            self.assertLessEqual(offset + 32, len(texture1))
            self.assertEqual(lump_name(texture1[offset:offset + 8]), name)
            self.assertEqual(u32(texture1, offset + 8), 0)
            self.assertEqual(u16(texture1, offset + 12), 1)
            self.assertEqual(u16(texture1, offset + 14), 1)
            self.assertEqual(u32(texture1, offset + 16), 0)
            self.assertEqual(u16(texture1, offset + 20), 1)
            self.assertEqual(u16(texture1, offset + 26), 0)

    def test_flat_and_sprite_ranges_are_empty_markers(self):
        names = [lump["name"] for lump in self.lumps]
        self.assertEqual(names.index("F_END"), names.index("F_START") + 1)
        self.assertEqual(names.index("S_END"), names.index("S_START") + 1)

    def test_startup_patch_lumps_are_valid_one_pixel_patches(self):
        for name in make_wad_image.startup_patch_names():
            with self.subTest(name=name):
                self.assertIn(name, self.by_name)
                assert_synthetic_patch(self, self.by_name[name]["data"])


if __name__ == "__main__":
    unittest.main()
