import os
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


class LibcRuntimeReadinessTests(unittest.TestCase):
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
