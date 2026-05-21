import subprocess
import sys
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


class UserlandAbiContractTests(unittest.TestCase):
    def test_generic_userland_abi_checker_passes(self):
        result = subprocess.run(
            [sys.executable, "tools/check_userland_abi_contract.py"],
            cwd=ROOT,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        self.assertEqual(
            result.returncode,
            0,
            result.stdout + result.stderr,
        )
        self.assertIn("Userland ABI contract OK", result.stdout)
        self.assertIn("copy-backed file-private mmap", result.stdout)


if __name__ == "__main__":
    unittest.main()
