import os
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


class LibcRuntimeReadinessTests(unittest.TestCase):
    def test_public_runtime_header_declares_generic_game_tool_wrappers(self):
        header = (ROOT / "doom_port" / "include" / "vibe_os.h").read_text()
        libc = (ROOT / "doom_port" / "libc.c").read_text()

        for token in (
            "int vibe_poll_input(vibe_input_event_t* event);",
            "int vibe_input_status(vibe_input_status_t* status);",
            "int vibe_present_indexed(const vibe_present_indexed_t* present);",
            "`vibe_poll_input` and `vibe_input_status`",
            "`vibe_present_indexed` presents a `vibe_present_indexed_t`",
        ):
            with self.subTest(token=token):
                self.assertIn(token, header)

        for token in (
            "int vibe_poll_input(vibe_input_event_t* event)",
            "VIBE_SYS_POLL_INPUT",
            "(unsigned long)sizeof(*event)",
            "int vibe_input_status(vibe_input_status_t* status)",
            "VIBE_SYS_INPUT_STATUS",
            "(unsigned long)sizeof(*status)",
            "int vibe_present_indexed(const vibe_present_indexed_t* present)",
            "ioctl(VIBE_DISPLAY_FD, VIBE_IOCTL_PRESENT_INDEXED",
        ):
            with self.subTest(token=token):
                self.assertIn(token, libc)

    def test_generic_runtime_contracts_have_host_proof(self):
        source = ROOT / "tests" / "host" / "libc_runtime_readiness_test.c"

        with tempfile.TemporaryDirectory() as tmp:
            binary = Path(tmp) / "libc_runtime_readiness_test"
            subprocess.run(
                [
                    os.environ.get("CLANG", "clang"),
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


if __name__ == "__main__":
    unittest.main()
