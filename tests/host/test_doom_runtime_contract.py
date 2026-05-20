import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


class DoomRuntimeContractTests(unittest.TestCase):
    def test_port_layer_owns_doom_syscall_contract(self):
        header = (ROOT / "doom_port" / "include" / "vibe_os.h").read_text()
        fcntl = (ROOT / "doom_port" / "include" / "fcntl.h").read_text()
        libc = (ROOT / "doom_port" / "libc.c").read_text()

        self.assertIn("Failure returns -errno", header)
        self.assertIn("#define O_ACCMODE 0x0003", fcntl)
        self.assertIn("static int validate_open_flags", libc)
        self.assertIn("access_mode == O_ACCMODE", libc)
        self.assertIn("raw < -1", libc)

    def test_original_doom_sources_do_not_depend_on_vibe_syscalls(self):
        doom_src = ROOT / "third_party" / "doom" / "linuxdoom-1.10"
        forbidden = ("VIBE_SYS_", "vibe_syscall3", "doom_port", "vibe_os.h")
        for path in doom_src.glob("*.[ch]"):
            text = path.read_text(errors="ignore")
            for token in forbidden:
                with self.subTest(path=path.name, token=token):
                    self.assertNotIn(token, text)

    def test_kernel_smoke_exposes_file_runtime_counters_not_fat_internals(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()
        makefile = (ROOT / "Makefile").read_text()
        docs = (ROOT / "docs" / "doom-libc-runtime.md").read_text()

        for token in (
            "doom_close_count",
            "doom_error_count",
            "doom_last_open_flags",
            "doom_last_open_mode",
            "smoke_doomclose_text",
            "smoke_doommode_text",
            "smoke_doomerr_text",
        ):
            with self.subTest(token=token):
                self.assertIn(token, kernel)

        self.assertIn('grep -q "doomclose="', makefile)
        self.assertIn('grep -q "doommode="', makefile)
        self.assertIn("`doomopen`, `doomread`, `doomwrite`, `doomseek`, `doomclose`", docs)


if __name__ == "__main__":
    unittest.main()
