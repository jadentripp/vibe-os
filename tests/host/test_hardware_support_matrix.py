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
        boot_doc = (ROOT / "docs" / "boot-loader-vm.md").read_text()
        gap_doc = (ROOT / "docs" / "post-checkpoint-gaps.md").read_text()
        tests_readme = (ROOT / "tests" / "README.md").read_text()
        runbook = (ROOT / "docs" / "runbooks" / "remote-doom-playtest.md").read_text()

        for text, phrase in (
            (readme, "not broad PC or physical hardware compatibility"),
            (readme, "docs/hardware-support.md"),
            (readme, "boot/uefi/README.md"),
            (readme, "pci="),
            (boot_doc, "contract-only UEFI scaffold"),
            (boot_doc, "SUPPORT[UEFI] remains unclaimed"),
            (boot_doc, "PCI_STATUS[QEMU_BUS0_CONFIG]"),
            (gap_doc, "check_hardware_support_matrix.py"),
            (gap_doc, "UEFI_BOOT[...]"),
            (gap_doc, "PCI_STATUS[...]"),
            (gap_doc, "pciprobe="),
            (gap_doc, "UEFI, PCI enumeration, AHCI, USB, SMP, APIC, HPET, and physical hardware remain unclaimed"),
            (tests_readme, "tools/check_hardware_support_matrix.py"),
            (tests_readme, "boot/uefi/README.md"),
            (tests_readme, "pciprobe="),
            (runbook, "does not prove vibe-os boots directly on physical hardware"),
        ):
            with self.subTest(phrase=phrase):
                self.assertContainsPhrase(text, phrase)

    def test_pci_status_probe_is_bounded_and_not_a_support_claim(self):
        rows = check_hardware_support_matrix.validate_repo_contract(ROOT)
        matrix = (ROOT / "docs" / "hardware-support.md").read_text()
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()
        pci_rows = check_hardware_support_matrix._validate_pci_status_rows(matrix)

        self.assertEqual(rows["PCI_ENUMERATION"]["status"], "unclaimed")
        self.assertEqual(rows["PCI_ENUMERATION"]["scope"], "none")
        self.assertEqual(rows["PCI_ENUMERATION"]["evidence"], "none")
        self.assertEqual(pci_rows["QEMU_BUS0_CONFIG"]["status"], "status-only")
        self.assertEqual(pci_rows["QEMU_BUS0_CONFIG"]["scope"], "qemu-pci-bus0")
        for source in (
            "PCI_SCAN_DEVICE_COUNT equ 32",
            "PCI_SCAN_FUNCTION_COUNT equ 8",
            "call pci_scan_qemu",
            "pci_scan_qemu:",
            'smoke_pci_text db " pci="',
            'smoke_pciprobe_text db " pciprobe="',
            'smoke_pcicount_text db " pcicount="',
            'smoke_pcifirst_text db " pcifirst="',
            'smoke_pciid_text db " pciid="',
            'smoke_pciclass_text db " pciclass="',
        ):
            with self.subTest(source=source):
                self.assertIn(source, kernel)

    def test_uefi_scaffold_is_contract_only_and_unclaimed(self):
        rows = check_hardware_support_matrix.validate_repo_contract(ROOT)
        uefi_rows = check_hardware_support_matrix._validate_uefi_scaffold(ROOT)
        makefile = (ROOT / "Makefile").read_text()

        self.assertEqual(rows["UEFI"]["status"], "unclaimed")
        self.assertEqual(rows["UEFI"]["scope"], "none")
        self.assertEqual(rows["UEFI"]["proof"], "future-boot-path-proof")
        self.assertEqual(rows["UEFI"]["evidence"], "none")
        self.assertEqual(
            set(uefi_rows),
            {
                "ENTRY",
                "ESP_STORAGE",
                "FRAMEBUFFER",
                "MEMORY_MAP",
                "EXIT_BOOT_SERVICES",
                "KERNEL_HANDOFF",
                "BUILD_INTEGRATION",
            },
        )
        for row_id, row in uefi_rows.items():
            with self.subTest(row_id=row_id):
                self.assertEqual(row["status"], "unimplemented")
                self.assertEqual(row["evidence"], "none")
        self.assertNotIn("boot/uefi", makefile)

    def test_cli_reports_contract_success(self):
        result = subprocess.run(
            [sys.executable, str(TOOLS / "check_hardware_support_matrix.py")],
            cwd=ROOT,
            capture_output=True,
            text=True,
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("hardware support matrix OK", result.stdout)

    def test_checker_validates_bounded_pci_status_fields(self):
        status = (
            "Aurora OS v0.2 pci=OK pciprobe=00000100 pcicount=00000004 "
            "pcifirst=00000000 pciid=12378086 pciclass=06000000"
        )

        fields = check_hardware_support_matrix.validate_pci_status_text(status)
        self.assertEqual(fields["pci"], "OK")

        none_status = (
            "Aurora OS v0.2 pci=NONE pciprobe=00000100 pcicount=00000000 "
            "pcifirst=00000000 pciid=00000000 pciclass=00000000"
        )
        self.assertEqual(check_hardware_support_matrix.validate_pci_status_text(none_status)["pci"], "NONE")

        with self.assertRaisesRegex(AssertionError, "pciprobe="):
            check_hardware_support_matrix.validate_pci_status_text(status.replace("pciprobe=00000100", "pciprobe=00000200"))
        with self.assertRaisesRegex(AssertionError, "pcifirst="):
            check_hardware_support_matrix.validate_pci_status_text(status.replace("pcifirst=00000000", "pcifirst=00002000"))
        with self.assertRaisesRegex(AssertionError, "status missing PCI fields"):
            check_hardware_support_matrix.validate_pci_status_text("Aurora OS v0.2 pci=OK")

    def test_checker_rejects_claimed_scope_broadening(self):
        matrix = (ROOT / "docs" / "hardware-support.md").read_text()
        broadened = matrix.replace(
            "SUPPORT[IDE_ATA_PIO] status=claimed scope=qemu-ide",
            "SUPPORT[IDE_ATA_PIO] status=claimed scope=pc-storage",
        )

        with self.assertRaisesRegex(AssertionError, "IDE_ATA_PIO scope must stay qemu-ide"):
            check_hardware_support_matrix._validate_support_rows(broadened)

    def test_checker_rejects_uefi_scaffold_becoming_claimed_without_evidence(self):
        scaffold = (ROOT / "boot" / "uefi" / "README.md").read_text()
        broadened = scaffold.replace(
            "UEFI_BOOT[ENTRY] status=unimplemented",
            "UEFI_BOOT[ENTRY] status=implemented",
        )

        with self.assertRaisesRegex(AssertionError, r"UEFI_BOOT\[ENTRY\] must stay status=unimplemented"):
            check_hardware_support_matrix._validate_uefi_boot_rows(broadened)


if __name__ == "__main__":
    unittest.main()
