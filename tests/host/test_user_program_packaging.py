import importlib.util
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
BUILD = ROOT / "build"
TOOL = ROOT / "tools" / "make_wad_image.py"
spec = importlib.util.spec_from_file_location("make_wad_image", TOOL)
make_wad_image = importlib.util.module_from_spec(spec)
spec.loader.exec_module(make_wad_image)


class UserProgramPackagingTests(unittest.TestCase):
    def test_abi_probe_is_freestanding_and_uses_public_non_doom_abi(self):
        source = (ROOT / "user" / "abi_probe.c").read_text()

        for token in (
            '#include "runtime.h"',
            "int user_main(int argc, char** argv, char** envp)",
            "VIBE_CLOCK_MONOTONIC",
            'vibe_user_streq(argv[0], "ABIPROBE.ELF")',
            'root_contains(root_entries, root_count, "ABIPROBE.ELF")',
            'vibe_user_write_all(1, "abi probe ok\\n")',
            "vibe_user_getpid()",
            "vibe_user_clock_monotonic(&now)",
            "vibe_user_listdir(\"/\", root_entries, 16)",
            "vibe_user_execv(doom_path, doom_argv)",
        ):
            self.assertIn(token, source)

        self.assertNotIn("third_party/doom", source)
        self.assertNotIn("doom_main", source)
        self.assertNotIn("VIBE_SYS_GAMEPLAY_STATUS", source)
        self.assertNotIn("VIBE_SYS_PRESENT", source)

    def test_makefile_builds_and_packages_abi_probe_without_launching_it(self):
        makefile = (ROOT / "Makefile").read_text()
        user_probe = (ROOT / "user" / "probe.c").read_text()

        for token in (
            "USER_ABI_PROBE_C_SRC := user/abi_probe.c",
            "USER_RUNTIME_C_SRC := user/runtime.c",
            "USER_ABI_PROBE_ELF := $(BUILD_DIR)/abi_probe.elf",
            "--root-elf ABIPROBE.ELF=$(USER_ABI_PROBE_ELF)",
            "$(USER_ABI_PROBE_ELF): $(USER_CRT0_OBJ) $(USER_RUNTIME_C_OBJ) $(USER_ABI_PROBE_C_OBJ) tools/link_elf32.py",
            "$(IMAGE): $(STAGE1_BIN) $(STAGE2_BIN) $(KERNEL_ELF) $(USER_PROBE_ELF) $(USER_ABI_PROBE_ELF) $(DOOM_ELF)",
        ):
            self.assertIn(token, makefile)

        self.assertIn('const char abi_probe_path[] = "ABIPROBE.ELF";', user_probe)
        self.assertIn("saw_abi_probe", user_probe)
        self.assertIn("sys_execv(abi_probe_path", user_probe)

    def test_generated_fat_image_contains_second_root_elf(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        abi_probe = (BUILD / "abi_probe.elf").read_bytes()
        fs = make_wad_image.Fat16Image(image)

        meta = fs.root_file_metadata(b"ABIPROBEELF")

        self.assertIsNotNone(meta)
        self.assertFalse(meta["is_directory"])
        self.assertEqual(meta["size"], len(abi_probe))
        self.assertEqual(fs.read_root_file(b"ABIPROBEELF"), abi_probe)
        self.assertEqual(abi_probe[:4], b"\x7fELF")
        self.assertGreater(meta["cluster"], fs.root_file_metadata(b"DOOM    ELF")["cluster"])

    def test_image_builder_packages_arbitrary_extra_root_elves(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            tool_elf = tmpdir / "tool.elf"
            game_elf = tmpdir / "game.elf"
            image = tmpdir / "disk.img"
            tool_payload = b"\x7fELFtool payload"
            game_payload = b"\x7fELFgame payload"
            tool_elf.write_bytes(tool_payload)
            game_elf.write_bytes(game_payload)

            subprocess.run(
                [
                    sys.executable,
                    str(TOOL),
                    "--root-elf",
                    f"TOOL.ELF={tool_elf}",
                    "--root-elf",
                    f"GAME.ELF={game_elf}",
                    str(image),
                ],
                cwd=ROOT,
                check=True,
            )

            fs = make_wad_image.Fat16Image(bytearray(image.read_bytes()))

        self.assertEqual(fs.read_root_file(b"TOOL    ELF"), tool_payload)
        self.assertEqual(fs.read_root_file(b"GAME    ELF"), game_payload)

    def test_image_builder_rejects_non_elf_or_protected_extra_root_names(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            payload = tmpdir / "payload.bin"
            image = tmpdir / "disk.img"
            payload.write_bytes(b"\x7fELF")

            for spec_value, message in (
                (f"TOOL.BIN={payload}", "must use .ELF"),
                (f"DOOM.ELF={payload}", "protected"),
                (f"LONGTOOLNAME.ELF={payload}", "must fit 8.3"),
            ):
                with self.subTest(spec_value=spec_value):
                    result = subprocess.run(
                        [
                            sys.executable,
                            str(TOOL),
                            "--root-elf",
                            spec_value,
                            str(image),
                        ],
                        cwd=ROOT,
                        text=True,
                        stdout=subprocess.PIPE,
                        stderr=subprocess.PIPE,
                    )

                    self.assertNotEqual(result.returncode, 0)
                    self.assertIn(message, result.stderr)


if __name__ == "__main__":
    unittest.main()
