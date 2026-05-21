import subprocess
import sys
import tempfile
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

    def claimed_hardware_status(self, **overrides):
        fields = {
            "ata": "OK",
            "ataop": "READ",
            "atawait": "IDLE",
            "atalba": "00000042",
            "atastat": "00000040",
            "ataerr": "00000000",
            "atafail": "00000000",
            "atatmo": "00000000",
            "inputqueue": "00000008",
            "inputpoll": "00000008",
            "inputlast": "0000002A:00000001:00000001",
            "keyirq": "00000004",
            "keyqueue": "00000004",
            "keypoll": "00000004",
            "keyseen": "00000071",
            "keylast": "0001001B",
            "mouse": "OK",
            "mouseirq": "00000001",
            "mousepkt": "00000001",
            "mousepoll": "00000001",
            "mousebtn": "00000001",
            "mousedelta": "00000018:0000000C",
            "gfx": "OK",
            "fb": "LFB",
            "fbpolicy": "ASP",
            "fbgeom": "00000000:00000000:00000280:000001E0:00000002",
            "fbdirty": "00000000:00000000:00000140:000000C8:00000100",
            "doompresent": "00000002",
            "doompal": "11111111",
            "doomframe": "22222222",
            "doomnonzero": "00001000",
            "doomcolors": "00000040",
            "audio": "SB16",
            "sb16": "00000004:00000005",
            "dma": "00000001",
            "play": "00000001:00000000",
            "audioirq": "00000002",
            "ack8": "00000002",
            "refill": "00000002",
            "sfxdma": "00000002:00000800",
            "musicpull": "00000002:00000002",
            "pcmbuf": "00002000:00000400:00000000:00000001",
            "pci": "OK",
            "pciprobe": "00000100",
            "pcicount": "00000004",
            "pcifirst": "00000000",
            "pciid": "12378086",
            "pciclass": "06000000",
            "pcitable": "OK",
            "pcitabcap": "00000100",
            "pcitabuse": "00000004",
            "pcilast": "00000100",
            "pciclassh": "89ABCDEF",
            "pcimulti": "00000001",
            "pciclsms": "00000001",
            "pciclsbr": "00000001",
        }
        fields.update(overrides)
        return "Aurora OS v0.2 " + " ".join(f"{key}={value}" for key, value in fields.items())

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
        hardware_doc = (ROOT / "docs" / "hardware-support.md").read_text()
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
            (gap_doc, "PCI_TABLE[...]"),
            (gap_doc, "pciprobe="),
            (gap_doc, "pcitabcap="),
            (gap_doc, "UEFI, PCI enumeration, AHCI, USB, SMP, APIC, HPET, and physical hardware remain unclaimed"),
            (hardware_doc, "Input, audio, and FAT16 are reusable OS-facing syscall/header contracts"),
            (hardware_doc, "The reusable contracts do not widen the hardware claim"),
            (hardware_doc, "USB HID, AC97/HDA/USB audio, arbitrary FAT media, long filenames, physical sound cards, and real PC hardware remain unclaimed"),
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
        pci_table_rows = check_hardware_support_matrix._validate_pci_table_rows(matrix)
        self.assertEqual(pci_table_rows["QEMU_BUS0_CLASS_TABLE"]["layout"], "bdf-id-class-header")
        self.assertEqual(pci_table_rows["QEMU_BUS0_CLASS_TABLE"]["capacity"], "256")
        for source in (
            "PCI_SCAN_DEVICE_COUNT equ 32",
            "PCI_SCAN_FUNCTION_COUNT equ 8",
            "PCI_TABLE_ENTRY_DWORDS equ 4",
            "PCI_TABLE_MAX_ENTRIES equ PCI_SCAN_FUNCTION_PROBES",
            "call pci_scan_qemu",
            "pci_scan_qemu:",
            "mov edi, pci_device_table",
            "PCI_TABLE_CLASS_OFFSET",
            "pci_device_table times PCI_TABLE_MAX_ENTRIES * PCI_TABLE_ENTRY_DWORDS dd 0",
            'smoke_pci_text db " pci="',
            'smoke_pciprobe_text db " pciprobe="',
            'smoke_pcicount_text db " pcicount="',
            'smoke_pcifirst_text db " pcifirst="',
            'smoke_pciid_text db " pciid="',
            'smoke_pciclass_text db " pciclass="',
            'smoke_pcitable_text db " pcitable="',
            'smoke_pcitabcap_text db " pcitabcap="',
            'smoke_pcitabuse_text db " pcitabuse="',
            'smoke_pcilast_text db " pcilast="',
            'smoke_pciclassh_text db " pciclassh="',
            'smoke_pcimulti_text db " pcimulti="',
            'smoke_pciclsms_text db " pciclsms="',
            'smoke_pciclsbr_text db " pciclsbr="',
        ):
            with self.subTest(source=source):
                self.assertIn(source, kernel)

    def test_unclaimed_hardware_has_future_proof_and_negative_claim_rows(self):
        check_hardware_support_matrix.validate_repo_contract(ROOT)
        matrix = (ROOT / "docs" / "hardware-support.md").read_text()
        proof_rows = check_hardware_support_matrix._validate_proof_requirement_rows(matrix)
        negative_rows = check_hardware_support_matrix._validate_negative_claim_rows(matrix)

        expected_unclaimed = {
            "UEFI",
            "PCI_ENUMERATION",
            "AHCI",
            "USB",
            "SMP",
            "APIC",
            "HPET",
            "PHYSICAL_HARDWARE",
        }
        self.assertEqual(set(proof_rows), expected_unclaimed)
        self.assertEqual(set(negative_rows), expected_unclaimed)

        for support_id in expected_unclaimed:
            with self.subTest(support_id=support_id):
                self.assertEqual(proof_rows[support_id]["status"], "future")
                self.assertEqual(proof_rows[support_id]["evidence"], "none")
                self.assertEqual(negative_rows[support_id]["status"], "active")
                self.assertNotEqual(negative_rows[support_id]["evidence"], "none")

        self.assertEqual(proof_rows["AHCI"]["requires"], "pci-ahci-bar-identify-read")
        self.assertEqual(proof_rows["USB"]["requires"], "host-controller-hid-storage")
        self.assertEqual(proof_rows["APIC"]["requires"], "lapic-ioapic-pic-masked")
        self.assertEqual(proof_rows["SMP"]["requires"], "ap-startup-percpu-progress")
        self.assertEqual(proof_rows["HPET"]["requires"], "acpi-hpet-mmio-comparator")
        self.assertEqual(negative_rows["PHYSICAL_HARDWARE"]["claim"], "no-physical-machine-proof")

    def test_next_hardware_unlock_is_pci_enumeration(self):
        matrix = (ROOT / "docs" / "hardware-support.md").read_text()
        next_rows = check_hardware_support_matrix._validate_next_unlock_rows(matrix)

        self.assertEqual(set(next_rows), {"PCI_ENUMERATION"})
        self.assertEqual(next_rows["PCI_ENUMERATION"]["priority"], "first")
        self.assertEqual(next_rows["PCI_ENUMERATION"]["scope"], "qemu-pci")
        self.assertEqual(next_rows["PCI_ENUMERATION"]["proof"], "cloud-class-table")
        self.assertEqual(next_rows["PCI_ENUMERATION"]["evidence"], "none")
        self.assertContainsPhrase(matrix, "PCI enumeration is the next implementable hardware-class unlock")

    def test_claimed_hardware_rows_name_machine_checked_status_counters(self):
        matrix = (ROOT / "docs" / "hardware-support.md").read_text()
        rows = check_hardware_support_matrix._validate_status_proof_rows(matrix)

        self.assertEqual(
            set(rows),
            {"IDE_ATA_PIO", "PS2_KEYBOARD", "PS2_MOUSE", "VBE_VGA", "SB16"},
        )
        self.assertEqual(rows["IDE_ATA_PIO"]["fields"][0:3], ("ata", "ataop", "atawait"))
        self.assertIn("keyirq", rows["PS2_KEYBOARD"]["fields"])
        self.assertIn("mousepkt", rows["PS2_MOUSE"]["fields"])
        self.assertIn("fbgeom", rows["VBE_VGA"]["fields"])
        self.assertIn("audioirq", rows["SB16"]["fields"])
        self.assertContainsPhrase(matrix, "minimum aggregate status fields")

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
            "pcifirst=00000000 pciid=12378086 pciclass=06000000 "
            "pcitable=OK pcitabcap=00000100 pcitabuse=00000004 "
            "pcilast=00000100 pciclassh=89ABCDEF pcimulti=00000001 "
            "pciclsms=00000001 pciclsbr=00000001"
        )

        fields = check_hardware_support_matrix.validate_pci_status_text(status)
        self.assertEqual(fields["pci"], "OK")

        none_status = (
            "Aurora OS v0.2 pci=NONE pciprobe=00000100 pcicount=00000000 "
            "pcifirst=00000000 pciid=00000000 pciclass=00000000 "
            "pcitable=OK pcitabcap=00000100 pcitabuse=00000000 "
            "pcilast=00000000 pciclassh=00000000 pcimulti=00000000 "
            "pciclsms=00000000 pciclsbr=00000000"
        )
        self.assertEqual(check_hardware_support_matrix.validate_pci_status_text(none_status)["pci"], "NONE")

        with self.assertRaisesRegex(AssertionError, "pciprobe="):
            check_hardware_support_matrix.validate_pci_status_text(status.replace("pciprobe=00000100", "pciprobe=00000200"))
        with self.assertRaisesRegex(AssertionError, "pcitabuse="):
            check_hardware_support_matrix.validate_pci_status_text(status.replace("pcitabuse=00000004", "pcitabuse=00000003"))
        with self.assertRaisesRegex(AssertionError, "pciclassh="):
            check_hardware_support_matrix.validate_pci_status_text(status.replace("pciclassh=89ABCDEF", "pciclassh=00000000"))
        with self.assertRaisesRegex(AssertionError, "pcifirst="):
            check_hardware_support_matrix.validate_pci_status_text(status.replace("pcifirst=00000000", "pcifirst=00002000"))
        with self.assertRaisesRegex(AssertionError, "status missing PCI fields"):
            check_hardware_support_matrix.validate_pci_status_text("Aurora OS v0.2 pci=OK")

    def test_checker_validates_claimed_hardware_status_counters(self):
        fields = check_hardware_support_matrix.validate_claimed_hardware_status_text(
            self.claimed_hardware_status()
        )
        self.assertEqual(fields["ata"], "OK")
        self.assertEqual(fields["audio"], "SB16")

        for overrides, message in (
            ({"ata": "FAIL"}, "ata="),
            ({"atawait": "DRQ"}, "atawait="),
            ({"keyirq": "00000000"}, "keyirq="),
            ({"mouse": "NONE"}, "mouse="),
            ({"mousedelta": "00000000:00000000"}, "mousedelta="),
            ({"fb": "GOP"}, "fb="),
            ({"doompresent": "00000000"}, "doompresent="),
            ({"audio": "NONE"}, "audio="),
            ({"sb16": "00000000:00000000"}, "sb16="),
            ({"musicpull": "00000000:00000000"}, "musicpull="),
            ({"pciprobe": "00000020"}, "pciprobe="),
        ):
            with self.subTest(overrides=overrides):
                with self.assertRaisesRegex(AssertionError, message):
                    check_hardware_support_matrix.validate_claimed_hardware_status_text(
                        self.claimed_hardware_status(**overrides)
                    )

    def test_cli_validates_claimed_hardware_status_file(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "status.txt"
            path.write_text(self.claimed_hardware_status())
            result = subprocess.run(
                [
                    sys.executable,
                    str(TOOLS / "check_hardware_support_matrix.py"),
                    "--claimed-hardware-status",
                    str(path),
                ],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("claimed hardware status OK", result.stdout)

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

    def test_checker_rejects_retired_negative_claim_without_proof(self):
        matrix = (ROOT / "docs" / "hardware-support.md").read_text()
        broadened = matrix.replace(
            "NEGATIVE_CLAIM[USB] status=active",
            "NEGATIVE_CLAIM[USB] status=retired",
        )

        with self.assertRaisesRegex(AssertionError, r"NEGATIVE_CLAIM\[USB\] must stay status=active"):
            check_hardware_support_matrix._validate_negative_claim_rows(broadened)

    def test_checker_rejects_future_proof_requirement_claiming_evidence(self):
        matrix = (ROOT / "docs" / "hardware-support.md").read_text()
        broadened = matrix.replace(
            "PROOF_REQUIREMENT[APIC] status=future artifact=apic-cloud-irq requires=lapic-ioapic-pic-masked evidence=none",
            "PROOF_REQUIREMENT[APIC] status=future artifact=apic-cloud-irq requires=lapic-ioapic-pic-masked evidence=status.txt",
        )

        with self.assertRaisesRegex(AssertionError, r"PROOF_REQUIREMENT\[APIC\] must keep evidence=none"):
            check_hardware_support_matrix._validate_proof_requirement_rows(broadened)


if __name__ == "__main__":
    unittest.main()
