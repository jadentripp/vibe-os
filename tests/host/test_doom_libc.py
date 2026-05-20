import os
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


class DoomLibcAllocatorTests(unittest.TestCase):
    def test_allocator_reuses_freed_blocks_and_realloc_preserves_data(self):
        source = ROOT / "tests" / "host" / "doom_libc_allocator_test.c"

        with tempfile.TemporaryDirectory() as tmp:
            binary = Path(tmp) / "doom_libc_allocator_test"
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
