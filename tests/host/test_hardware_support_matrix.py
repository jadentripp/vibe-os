import subprocess
import sys
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
TOOLS = ROOT / "tools"
sys.path.insert(0, str(TOOLS))
try:
    import check_hardware_support_matrix
finally:
    sys.path.pop(0)


class HardwareSupportMatrixTests(unittest.TestCase):
    def assertContainsPhrase(self, text, phrase):
        self.assertIn(" ".join(phrase.split()), " ".join(text.split()))

    def test_matrix_rows_define_claimed_and_unclaimed_device_classes(self):
        rows = check_hardware_support_matrix.validate_repo_contract(ROOT)

        claimed = {support_id for support_id, row in rows.items() if row["status"] == "claimed"}
        unclaimed = {support_id for support_id, row in rows.items() if row["status"] == "unclaimed"}

        self.assertEqual(
            claimed,
            {
                "BIOS_BOOT",
                "IDE_ATA_PIO",
                "FAT16",
                "PS2_KEYBOARD",
                "PS2_MOUSE",
                "PIT",
                "VBE_VGA",
                "SB16",
            },
        )
        self.assertEqual(
            unclaimed,
            {
                "UEFI",
                "PCI_ENUMERATION",
                "AHCI",
                "USB",
                "SMP",
                "APIC",
                "HPET",
                "PHYSICAL_HARDWARE",
            },
        )
        expected_scopes = {
            "BIOS_BOOT": "qemu-bios",
            "IDE_ATA_PIO": "qemu-ide",
            "FAT16": "generated-disk-image",
            "PS2_KEYBOARD": "qemu-ps2",
            "PS2_MOUSE": "qemu-ps2",
            "PIT": "qemu-pit",
            "VBE_VGA": "qemu-vbe-vga",
            "SB16": "qemu-sb16",
        }
        for support_id in claimed:
            with self.subTest(support_id=support_id):
                self.assertEqual(rows[support_id]["scope"], expected_scopes[support_id])
                self.assertNotEqual(rows[support_id]["evidence"], "none")
        for support_id in unclaimed:
            with self.subTest(support_id=support_id):
                self.assertEqual(rows[support_id]["scope"], "none")
                self.assertEqual(rows[support_id]["evidence"], "none")

    def test_hardware_boundary_is_visible_from_main_claim_surfaces(self):
        readme = (ROOT / "README.md").read_text()
        gap_doc = (ROOT / "docs" / "post-checkpoint-gaps.md").read_text()
        tests_readme = (ROOT / "tests" / "README.md").read_text()
        runbook = (ROOT / "docs" / "runbooks" / "remote-doom-playtest.md").read_text()

        for text, phrase in (
            (readme, "not broad PC or physical hardware compatibility"),
            (readme, "docs/hardware-support.md"),
            (gap_doc, "check_hardware_support_matrix.py"),
            (gap_doc, "UEFI, PCI enumeration, AHCI, USB, SMP, APIC, HPET, and physical hardware remain unclaimed"),
            (tests_readme, "tools/check_hardware_support_matrix.py"),
            (runbook, "does not prove vibe-os boots directly on physical hardware"),
        ):
            with self.subTest(phrase=phrase):
                self.assertContainsPhrase(text, phrase)

    def test_cli_reports_contract_success(self):
        result = subprocess.run(
            [sys.executable, str(TOOLS / "check_hardware_support_matrix.py")],
            cwd=ROOT,
            capture_output=True,
            text=True,
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("hardware support matrix OK", result.stdout)

    def test_checker_rejects_claimed_scope_broadening(self):
        matrix = (ROOT / "docs" / "hardware-support.md").read_text()
        broadened = matrix.replace(
            "SUPPORT[IDE_ATA_PIO] status=claimed scope=qemu-ide",
            "SUPPORT[IDE_ATA_PIO] status=claimed scope=pc-storage",
        )

        with self.assertRaisesRegex(AssertionError, "IDE_ATA_PIO scope must stay qemu-ide"):
            check_hardware_support_matrix._validate_support_rows(broadened)


if __name__ == "__main__":
    unittest.main()
