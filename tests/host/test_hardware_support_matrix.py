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


def doc_text(name):
    txt_path = ROOT / "docs" / f"{name}.txt"
    if txt_path.exists():
        return txt_path.read_text()
    return (ROOT / "docs" / f"{name}.md").read_text()


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
            "inputdepth": "00000000:00000000",
            "inputstat": "00000008:00000008:00000000:0000003F",
            "inputpolicy": "00000001:0000003F",
            "inputdev": "00000001:00000001",
            "inputdevices": "00000002:00000003:0000001F:00000004:00000001",
            "inputmods": "00000000",
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
            "fbdev": "00000001:00000002:00000002:00000001",
            "fbmmio": "E0000000:000004B0:00000380:00000000",
            "fbinfo": "00000001:00000001:00000002",
            "fbcap": "0000003F",
            "fbsrc": "00000001:00000140:000000C8:00000140:000000F0:00000100:00000003",
            "fbacct": "00000001:00000001:00000000:00000000:00000000:00000001:00000100:0000FA00:00000300",
            "fbpresent": "00000002:00000000:00000002:00000000:00000001:00000002:00000002:00000140:000000C8",
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
            "pciprobe": "00010000",
            "pcimiss": "0000FFFC",
            "pcicount": "00000004",
            "pcihbus": "00000000",
            "pcifirst": "00000000",
            "pciid": "12378086",
            "pciclass": "06000000",
            "pcitable": "OK",
            "pcitabcap": "00000100",
            "pcitabuse": "00000004",
            "pciover": "00000000",
            "pcilast": "00000100",
            "pciclassh": "89ABCDEF",
            "pcimulti": "00000001",
            "pciclsms": "00000001",
            "pciclsbr": "00000001",
            "pciclspb": "00000000",
            "pcibrbus": "FFFFFFFF",
            "pciclsmm": "00000001",
            "pcidiag": "000000FF",
            "pciapi": "OK",
            "pcilookms": "00000100",
            "pcilookbr": "00000000",
            "pcilookid": "00000000",
            "pcilookmiss": "FFFFFFFF",
            "pcicons": "OK",
            "pcilookide": "00000100",
            "pcilookahci": "FFFFFFFF",
            "pcilookaud": "00000200",
            "pcilookhda": "FFFFFFFF",
            "blkctrl": "00000001:00000100:FFFFFFFF",
            "blkrej": "00000000:00000000",
            "ahcibar": "FFFFFFFF:FFFFFFFF:00000000:00000000",
            "ahcireq": "0000007F:00000000:00000005",
            "clocksrc": "PIT",
            "clockirq": "00000040",
            "clocktick": "00000040",
            "clockhz": "00000064",
            "clockms": "00000280",
            "clockdoom": "00000016",
            "clocksch": "00000008",
            "clockpirq": "00000008",
            "irqctl": "PIC",
            "apic": "NONE",
            "hpet": "NONE",
        }
        fields.update(overrides)
        return "Aurora OS v0.2 " + " ".join(f"{key}={value}" for key, value in fields.items())

    def test_matrix_rows_define_claimed_and_unclaimed_device_classes(self):
        rows = check_hardware_support_matrix.validate_repo_contract(ROOT)
        matrix = doc_text("architecture")
        target = check_hardware_support_matrix._validate_current_target_row(matrix)

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
                "ACPI_TABLES",
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
        self.assertEqual(target["machine"], "qemu-legacy-pc")
        self.assertEqual(
            set(target["includes"].split(",")),
            {"bios", "ide-ata-pio", "ps2-keyboard", "ps2-mouse", "pit", "vbe-vga", "sb16"},
        )
        self.assertEqual(
            set(target["excludes"].split(",")),
            {
                "uefi",
                "physical-hardware",
                "acpi-tables",
                "general-pci",
                "ahci-sata",
                "usb-input-storage",
                "apic-ioapic",
                "hpet",
                "smp",
                "arbitrary-disk-install",
            },
        )

    def test_hardware_boundary_is_visible_from_main_claim_surfaces(self):
        readme = (ROOT / "README.md").read_text()
        boot_doc = doc_text("architecture")
        gap_doc = doc_text("proof")
        hardware_doc = doc_text("architecture")
        tests_readme = (ROOT / "tests" / "strategy.txt").read_text()
        runbook = doc_text("play")

        for text, phrase in (
            (readme, "That evidence is limited to the emulated device model"),
            (readme, "docs/architecture.txt"),
            (readme, "boot/uefi/CONTRACT.txt"),
            (readme, "boot/uefi/build_host_artifacts.py"),
            (readme, "pci="),
            (boot_doc, "UEFI loader/proof boundary"),
            (boot_doc, "SUPPORT[UEFI] remains unclaimed"),
            (boot_doc, "UEFI_HOST_ARTIFACT[PE_COFF_LOADER]"),
            (boot_doc, "host-buildable PE/COFF loader and FAT16 ESP artifacts"),
            (boot_doc, "manual GitHub Actions OVMF loader proof"),
            (boot_doc, "contract mode that is QEMU-free"),
            (boot_doc, "PCI_STATUS[QEMU_PCI_CONFIG]"),
            (gap_doc, "check_hardware_support_matrix.py"),
            (gap_doc, "UEFI_BOOT[...]"),
            (gap_doc, "UEFI_HOST_ARTIFACT[...]"),
            (gap_doc, "ovmf_cloud_proof.py"),
            (gap_doc, "support_claim=unclaimed"),
            (gap_doc, "host-built-uefi-loader-no-kernel-entry-proof"),
            (gap_doc, "PCI_STATUS[...]"),
            (gap_doc, "PCI_TABLE[...]"),
            (gap_doc, "pciprobe="),
            (gap_doc, "pcitabcap="),
            (gap_doc, "UEFI, ACPI table discovery, PCI enumeration, AHCI, USB, SMP, APIC, HPET, and physical hardware remain unclaimed"),
            (hardware_doc, "Input, audio, and FAT16 are reusable OS-facing syscall/header contracts"),
            (hardware_doc, "CURRENT_TARGET[QEMU_LEGACY_PC]"),
            (hardware_doc, "QEMU BIOS/IDE/PS2/VBE/SB16 is the supported target"),
            (hardware_doc, "QEMU_DEVICE_MODEL[PCI_CONFIG_STATUS]"),
            (hardware_doc, "BOOT_DEVICE_BOUNDARY[UEFI_ESP_KERNEL_FILE]"),
            (hardware_doc, "UEFI_CLOUD_PROOF[WORKFLOW_DISPATCH]"),
            (hardware_doc, "json-manifests-only"),
            (hardware_doc, "PCI_TABLE_API[READ_ONLY_LOOKUP]"),
            (hardware_doc, "PCI_TABLE_CONSUMER[STORAGE_CLASS_PROBE]"),
            (hardware_doc, "PCI_TABLE_CONSUMER[AUDIO_CLASS_PROBE]"),
            (hardware_doc, "BLOCK_DRIVER_BOUNDARY[OPS_TABLE]"),
            (hardware_doc, "BLOCK_DRIVER_BOUNDARY[PCI_STORAGE_PROBE]"),
            (hardware_doc, "BLOCK_DRIVER_BOUNDARY[UNSUPPORTED_CONTROLLER_REJECTION]"),
            (hardware_doc, "BLOCK_DRIVER_BOUNDARY[AHCI_BAR_HBA_PROOF]"),
            (hardware_doc, "NEXT_IMPLEMENTATION_CONTRACT[PCI_DRIVER_TABLE_API]"),
            (hardware_doc, "installation to arbitrary disks are outside the claim"),
            (hardware_doc, "The reusable contracts do not widen the hardware claim"),
            (hardware_doc, "USB HID, AC97/HDA/USB audio, arbitrary FAT media, long filenames, physical sound cards, and real PC hardware remain unclaimed"),
            (hardware_doc, "VM/process legitimacy gate is adjacent to, but separate from, the hardware matrix"),
            (hardware_doc, "machine-required only in the real-WAD smoke and soak workflows"),
            (tests_readme, "tools/check_hardware_support_matrix.py"),
            (tests_readme, "boot/uefi/CONTRACT.txt"),
            (tests_readme, "pciprobe="),
            (tests_readme, "pciapi="),
            (tests_readme, "pcilookahci="),
            (tests_readme, "ahcibar="),
            (tests_readme, "ahcireq="),
            (tests_readme, "pcilookhda="),
            (runbook, "does not prove vibe-os boots directly on physical hardware"),
        ):
            with self.subTest(phrase=phrase):
                self.assertContainsPhrase(text, phrase)

    def test_pci_status_probe_is_bounded_and_not_a_support_claim(self):
        rows = check_hardware_support_matrix.validate_repo_contract(ROOT)
        matrix = doc_text("architecture")
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()
        pci_rows = check_hardware_support_matrix._validate_pci_status_rows(matrix)

        self.assertEqual(rows["PCI_ENUMERATION"]["status"], "unclaimed")
        self.assertEqual(rows["PCI_ENUMERATION"]["scope"], "none")
        self.assertEqual(rows["PCI_ENUMERATION"]["evidence"], "none")
        self.assertEqual(pci_rows["QEMU_PCI_CONFIG"]["status"], "status-only")
        self.assertEqual(pci_rows["QEMU_PCI_CONFIG"]["scope"], "qemu-pci-config")
        pci_table_rows = check_hardware_support_matrix._validate_pci_table_rows(matrix)
        self.assertEqual(
            pci_table_rows["QEMU_PCI_CLASS_TABLE"]["layout"],
            "packed-bdf-vendor-device-class-progif-header",
        )
        self.assertEqual(pci_table_rows["QEMU_PCI_CLASS_TABLE"]["capacity"], "256")
        pci_api_rows = check_hardware_support_matrix._validate_pci_table_api_rows(matrix)
        self.assertEqual(pci_api_rows["READ_ONLY_LOOKUP"]["contract"], "kernel-maintained-read-only-table")
        self.assertEqual(pci_api_rows["READ_ONLY_LOOKUP"]["lookup"], "index-vendor-device-class-subclass-progif")
        self.assertEqual(pci_api_rows["READ_ONLY_LOOKUP"]["consumers"], "future-drivers")
        pci_consumer_rows = check_hardware_support_matrix._validate_pci_table_consumer_rows(matrix)
        self.assertEqual(pci_consumer_rows["STORAGE_CLASS_PROBE"]["consumes"], "read-only-lookup")
        self.assertEqual(pci_consumer_rows["STORAGE_CLASS_PROBE"]["lookup"], "ide-ahci-class")
        self.assertEqual(pci_consumer_rows["STORAGE_CLASS_PROBE"]["drivers"], "none")
        self.assertEqual(pci_consumer_rows["AUDIO_CLASS_PROBE"]["consumes"], "read-only-lookup")
        self.assertEqual(pci_consumer_rows["AUDIO_CLASS_PROBE"]["lookup"], "multimedia-audio-hda-class")
        self.assertEqual(pci_consumer_rows["AUDIO_CLASS_PROBE"]["drivers"], "none")
        pci_contract_rows = check_hardware_support_matrix._validate_pci_table_contract_rows(matrix)
        self.assertEqual(pci_contract_rows["QEMU_PCI_SCAN"]["buses"], "256")
        self.assertEqual(pci_contract_rows["QEMU_PCI_SCAN"]["devices"], "32")
        self.assertEqual(pci_contract_rows["QEMU_PCI_SCAN"]["functions"], "8")
        self.assertEqual(pci_contract_rows["QEMU_PCI_SCAN"]["table_capacity"], "256")
        self.assertEqual(pci_contract_rows["ENTRY_LAYOUT"]["dwords"], "4")
        self.assertEqual(
            pci_contract_rows["ENTRY_LAYOUT"]["fields"],
            "bus,device,function,vendor-id,device-id,base-class,subclass,prog-if,header",
        )
        self.assertEqual(pci_contract_rows["NO_DRIVER_BINDING"]["drivers"], "none")
        block_driver_rows = check_hardware_support_matrix._validate_block_driver_boundary_rows(matrix)
        self.assertEqual(block_driver_rows["OPS_TABLE"]["contract"], "sector-read-write-flush-ops")
        self.assertEqual(block_driver_rows["PCI_STORAGE_PROBE"]["active"], "ata-pio")
        self.assertEqual(block_driver_rows["UNSUPPORTED_CONTROLLER_REJECTION"]["active"], "none")
        self.assertEqual(block_driver_rows["AHCI_BAR_HBA_PROOF"]["contract"], "bar5-mmio-hba-identify-sector-read-required")
        self.assertEqual(block_driver_rows["AHCI_BAR_HBA_PROOF"]["active"], "none")
        self.assertContainsPhrase(matrix, "The PCI table contract is intentionally narrower")
        for source in (
            "PCI_CONFIG_BRIDGE_BUS_REG equ 0x18",
            "PCI_CONFIG_BAR5_REG equ 0x24",
            "PCI_SCAN_BUS_COUNT equ 256",
            "PCI_SCAN_DEVICE_COUNT equ 32",
            "PCI_SCAN_FUNCTION_COUNT equ 8",
            "PCI_SCAN_BUS_PROBES equ PCI_SCAN_DEVICE_COUNT * PCI_SCAN_FUNCTION_COUNT",
            "PCI_SCAN_FUNCTION_PROBES equ PCI_SCAN_BUS_COUNT * PCI_SCAN_BUS_PROBES",
            "PCI_TABLE_ENTRY_DWORDS equ 4",
            "PCI_TABLE_ENTRY_SHIFT equ 4",
            "PCI_TABLE_MAX_ENTRIES equ PCI_SCAN_BUS_PROBES",
            "PCI_SUBCLASS_IDE equ 0x01",
            "PCI_SUBCLASS_AHCI equ 0x06",
            "PCI_SUBCLASS_AUDIO equ 0x01",
            "PCI_SUBCLASS_HDA equ 0x03",
            "PCI_SUBCLASS_PCI_BRIDGE equ 0x04",
            "PCI_PROGIF_AHCI equ 0x01",
            "AHCI_BAR_STATE_MMIO equ 1",
            "AHCI_PROOF_REQUIRED_MASK equ 0x0000007f",
            "AHCI_GUARD_NO_SILENT_BIND equ 0x00000001",
            "AHCI_GUARD_UNSUPPORTED_REJECTED equ 0x00000002",
            "AHCI_GUARD_ATA_ONLY_OPS equ 0x00000004",
            "PCI_LOOKUP_ID_ANY equ 0xffff",
            "PCI_DIAG_SCAN_COMPLETE equ 0x00000001",
            "PCI_DIAG_TABLE_BOUNDED equ 0x00000002",
            "PCI_DIAG_ABSENT_COUNTED equ 0x00000004",
            "PCI_DIAG_CONFIG_DISABLED equ 0x00000008",
            "PCI_DIAG_INDEX_GUARD equ 0x00000010",
            "PCI_DIAG_ID_LOOKUP equ 0x00000020",
            "PCI_DIAG_CLASS_LOOKUP equ 0x00000040",
            "PCI_DIAG_STATUS_ONLY_CONSUMER equ 0x00000080",
            "BLOCK_DEVICE_AHCI equ 2",
            "BLOCK_OPS_READ_OFFSET equ 0",
            "BLOCK_OPS_WRITE_OFFSET equ 4",
            "BLOCK_OPS_FLUSH_OFFSET equ 8",
            "BLOCK_ERROR_UNSUPPORTED_CONTROLLER equ 7",
            "call pci_scan_qemu",
            "call block_driver_probe_storage_classes",
            "pci_scan_qemu:",
            "cmp dword [pci_scan_bus_index], PCI_SCAN_BUS_COUNT",
            "inc dword [pci_absent_count]",
            "mov [pci_highest_bus], eax",
            "mov [pci_bridge_bus_info], eax",
            "mov edi, pci_device_table",
            "PCI_TABLE_LOCATION_OFFSET",
            "PCI_TABLE_VENDOR_DEVICE_OFFSET",
            "PCI_TABLE_CLASS_OFFSET",
            "pci_table_entry_by_index:",
            "pci_table_find_first_by_class:",
            "pci_table_find_first_by_id:",
            "pci_config_read_dword_by_bdf:",
            "block_driver_install_ata_pio_ops:",
            "block_driver_probe_storage_classes:",
            "block_driver_record_ahci_probe:",
            "block_ata_pio_ops:",
            "call dword [block_driver_read_op]",
            "call dword [block_driver_write_op]",
            "call dword [block_driver_flush_op]",
            "or dword [pci_diag_flags], PCI_DIAG_SCAN_COMPLETE",
            "or dword [pci_diag_flags], PCI_DIAG_TABLE_BOUNDED",
            "or dword [pci_diag_flags], PCI_DIAG_ABSENT_COUNTED",
            "or dword [pci_diag_flags], PCI_DIAG_CONFIG_DISABLED",
            "or dword [pci_diag_flags], PCI_DIAG_INDEX_GUARD",
            "or dword [pci_diag_flags], PCI_DIAG_ID_LOOKUP",
            "or dword [pci_diag_flags], PCI_DIAG_CLASS_LOOKUP",
            "or dword [pci_diag_flags], PCI_DIAG_STATUS_ONLY_CONSUMER",
            "mov byte [pci_table_consumer_status], 1",
            "pci_device_table times PCI_TABLE_MAX_ENTRIES * PCI_TABLE_ENTRY_DWORDS dd 0",
            'smoke_pci_text db " pci="',
            'smoke_pciprobe_text db " pciprobe="',
            'smoke_pcimiss_text db " pcimiss="',
            'smoke_pcicount_text db " pcicount="',
            'smoke_pcihbus_text db " pcihbus="',
            'smoke_pcifirst_text db " pcifirst="',
            'smoke_pciid_text db " pciid="',
            'smoke_pciclass_text db " pciclass="',
            'smoke_pcitable_text db " pcitable="',
            'smoke_pcitabcap_text db " pcitabcap="',
            'smoke_pcitabuse_text db " pcitabuse="',
            'smoke_pciover_text db " pciover="',
            'smoke_pcilast_text db " pcilast="',
            'smoke_pciclassh_text db " pciclassh="',
            'smoke_pcimulti_text db " pcimulti="',
            'smoke_pciclsms_text db " pciclsms="',
            'smoke_pciclsbr_text db " pciclsbr="',
            'smoke_pciclspb_text db " pciclspb="',
            'smoke_pcibrbus_text db " pcibrbus="',
            'smoke_pciclsmm_text db " pciclsmm="',
            'smoke_pcidiag_text db " pcidiag="',
            'smoke_pciapi_text db " pciapi="',
            'smoke_pcilookms_text db " pcilookms="',
            'smoke_pcilookbr_text db " pcilookbr="',
            'smoke_pcilookid_text db " pcilookid="',
            'smoke_pcilookmiss_text db " pcilookmiss="',
            'smoke_pcicons_text db " pcicons="',
            'smoke_pcilookide_text db " pcilookide="',
            'smoke_pcilookahci_text db " pcilookahci="',
            'smoke_pcilookaud_text db " pcilookaud="',
            'smoke_pcilookhda_text db " pcilookhda="',
            'smoke_blkctrl_text db " blkctrl="',
            'smoke_blkrej_text db " blkrej="',
            'smoke_ahcibar_text db " ahcibar="',
            'smoke_ahcireq_text db " ahcireq="',
        ):
            with self.subTest(source=source):
                self.assertIn(source, kernel)

    def test_unclaimed_hardware_has_future_proof_and_negative_claim_rows(self):
        check_hardware_support_matrix.validate_repo_contract(ROOT)
        matrix = doc_text("architecture")
        proof_rows = check_hardware_support_matrix._validate_proof_requirement_rows(matrix)
        negative_rows = check_hardware_support_matrix._validate_negative_claim_rows(matrix)

        expected_unclaimed = {
            "UEFI",
            "ACPI_TABLES",
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

        self.assertEqual(proof_rows["UEFI"]["requires"], "pe32-esp-gop-mmap-exitbs-boot")
        self.assertEqual(proof_rows["PCI_ENUMERATION"]["requires"], "all-bdfs-class-subclass-progif-table")
        self.assertEqual(proof_rows["AHCI"]["requires"], "pci-ahci-bar5-hba-identify-sector-read-no-ide-fallback")
        self.assertEqual(proof_rows["USB"]["requires"], "host-controller-hid-mass-storage")
        self.assertEqual(proof_rows["ACPI_TABLES"]["requires"], "rsdp-rsdt-xsdt-madt-hpet-checksum")
        self.assertEqual(proof_rows["APIC"]["requires"], "madt-lapic-ioapic-pic-masked")
        self.assertEqual(proof_rows["SMP"]["requires"], "ap-startup-percpu-progress")
        self.assertEqual(proof_rows["HPET"]["requires"], "acpi-hpet-mmio-counter-comparator")
        self.assertEqual(proof_rows["PHYSICAL_HARDWARE"]["requires"], "machine-inventory-status-reboot-capture")
        self.assertEqual(negative_rows["AHCI"]["claim"], "no-ahci-sata-driver")
        self.assertEqual(negative_rows["ACPI_TABLES"]["claim"], "no-acpi-table-parser")
        self.assertEqual(negative_rows["USB"]["claim"], "no-usb-input-or-storage-stack")
        self.assertEqual(negative_rows["APIC"]["claim"], "no-apic-ioapic-routing")
        self.assertEqual(negative_rows["PHYSICAL_HARDWARE"]["claim"], "no-physical-machine-proof")

    def test_next_hardware_unlock_is_pci_enumeration(self):
        matrix = doc_text("architecture")
        next_rows = check_hardware_support_matrix._validate_next_unlock_rows(matrix)
        contract_rows = check_hardware_support_matrix._validate_next_implementation_contract_rows(matrix)

        self.assertEqual(set(next_rows), {"PCI_ENUMERATION"})
        self.assertEqual(next_rows["PCI_ENUMERATION"]["priority"], "first")
        self.assertEqual(next_rows["PCI_ENUMERATION"]["scope"], "qemu-pci")
        self.assertEqual(next_rows["PCI_ENUMERATION"]["proof"], "cloud-class-table")
        self.assertEqual(next_rows["PCI_ENUMERATION"]["evidence"], "none")
        self.assertEqual(set(contract_rows), {"PCI_DRIVER_TABLE_API"})
        self.assertEqual(contract_rows["PCI_DRIVER_TABLE_API"]["status"], "host-checked")
        self.assertEqual(
            contract_rows["PCI_DRIVER_TABLE_API"]["requires"],
            "read-only-index-id-class-progif-lookup",
        )
        self.assertEqual(contract_rows["PCI_DRIVER_TABLE_API"]["unlocks"], "ahci-sata,usb,hda-audio")
        self.assertEqual(contract_rows["PCI_DRIVER_TABLE_API"]["evidence"], "pciapi-pcilookid-status-fields")
        self.assertContainsPhrase(matrix, "PCI enumeration is the next implementable hardware-class unlock")

    def test_qemu_device_models_and_boot_device_boundaries_are_machine_readable(self):
        matrix = doc_text("architecture")
        qemu_rows = check_hardware_support_matrix._validate_qemu_device_model_rows(matrix)
        boot_rows = check_hardware_support_matrix._validate_boot_device_boundary_rows(matrix)

        self.assertEqual(qemu_rows["IDE_ATA_PIO"]["device"], "piix-ide")
        self.assertEqual(qemu_rows["PCI_CONFIG_STATUS"]["status"], "status-only")
        self.assertEqual(qemu_rows["PCI_CONFIG_STATUS"]["device"], "pci-config-ports")
        for row_id, row in qemu_rows.items():
            with self.subTest(row_id=row_id):
                self.assertEqual(row["machine"], "qemu-legacy-pc")

        self.assertEqual(boot_rows["BIOS_IDE_RAW_LBA"]["status"], "claimed")
        self.assertEqual(boot_rows["BIOS_IDE_RAW_LBA"]["device"], "qemu-ide")
        for row_id in ("UEFI_ESP_KERNEL_FILE", "AHCI_SATA_DISK", "USB_MASS_STORAGE", "PHYSICAL_MACHINE"):
            with self.subTest(row_id=row_id):
                self.assertEqual(boot_rows[row_id]["status"], "future")
                self.assertEqual(boot_rows[row_id]["evidence"], "none")
        self.assertContainsPhrase(matrix, "The boot-device boundary is intentionally separate")

    def test_claimed_hardware_rows_name_machine_checked_status_counters(self):
        matrix = doc_text("architecture")
        rows = check_hardware_support_matrix._validate_status_proof_rows(matrix)

        self.assertEqual(
            set(rows),
            {"PIT", "IDE_ATA_PIO", "PS2_KEYBOARD", "PS2_MOUSE", "VBE_VGA", "SB16"},
        )
        self.assertEqual(rows["PIT"]["fields"][0:3], ("clocksrc", "clockirq", "clocktick"))
        self.assertEqual(rows["IDE_ATA_PIO"]["fields"][0:3], ("ata", "ataop", "atawait"))
        self.assertIn("inputpolicy", rows["PS2_KEYBOARD"]["fields"])
        self.assertIn("inputdev", rows["PS2_KEYBOARD"]["fields"])
        self.assertIn("inputdevices", rows["PS2_KEYBOARD"]["fields"])
        self.assertIn("inputmods", rows["PS2_KEYBOARD"]["fields"])
        self.assertIn("keyirq", rows["PS2_KEYBOARD"]["fields"])
        self.assertIn("inputpolicy", rows["PS2_MOUSE"]["fields"])
        self.assertIn("inputdevices", rows["PS2_MOUSE"]["fields"])
        self.assertIn("mousepkt", rows["PS2_MOUSE"]["fields"])
        self.assertIn("fbdev", rows["VBE_VGA"]["fields"])
        self.assertIn("fbmmio", rows["VBE_VGA"]["fields"])
        self.assertIn("fbcap", rows["VBE_VGA"]["fields"])
        self.assertIn("fbsrc", rows["VBE_VGA"]["fields"])
        self.assertIn("fbacct", rows["VBE_VGA"]["fields"])
        self.assertIn("fbgeom", rows["VBE_VGA"]["fields"])
        self.assertIn("audioirq", rows["SB16"]["fields"])
        self.assertContainsPhrase(matrix, "minimum aggregate status fields")

    def test_interrupt_timer_boundary_rows_are_precise_and_unclaimed(self):
        matrix = doc_text("architecture")
        rows = check_hardware_support_matrix._validate_interrupt_timer_boundary_rows(matrix)

        self.assertEqual(
            set(rows),
            {"LEGACY_PIC_PIT", "ACPI_TABLES", "LOCAL_APIC", "IOAPIC", "HPET"},
        )
        self.assertEqual(rows["LEGACY_PIC_PIT"]["status"], "active")
        self.assertEqual(rows["LEGACY_PIC_PIT"]["route"], "pic")
        self.assertEqual(rows["LEGACY_PIC_PIT"]["clock"], "pit")
        self.assertEqual(rows["LOCAL_APIC"]["requires"], "lapic-mmio-or-msr-spurious-eoi-timer")
        self.assertEqual(rows["IOAPIC"]["requires"], "madt-ioapic-redirection-pic-masked")
        self.assertEqual(rows["HPET"]["requires"], "hpet-table-mmio-counter-comparator")
        for row_id in ("ACPI_TABLES", "LOCAL_APIC", "IOAPIC", "HPET"):
            with self.subTest(row_id=row_id):
                self.assertEqual(rows[row_id]["status"], "future")
                self.assertEqual(rows[row_id]["evidence"], "none")
        self.assertContainsPhrase(matrix, "not Doom-specific hooks")

    def test_uefi_loader_proof_boundary_is_intermediate_and_unclaimed(self):
        rows = check_hardware_support_matrix.validate_repo_contract(ROOT)
        uefi_rows = check_hardware_support_matrix._validate_uefi_scaffold(ROOT)
        scaffold = (ROOT / "boot" / "uefi" / "CONTRACT.txt").read_text()
        uefi_device_rows = check_hardware_support_matrix._validate_uefi_boot_device_rows(scaffold)
        uefi_host_rows = check_hardware_support_matrix._validate_uefi_host_artifact_rows(scaffold)
        uefi_cloud_rows = check_hardware_support_matrix._validate_uefi_cloud_proof_rows(scaffold)
        uefi_artifacts = check_hardware_support_matrix.validate_uefi_host_artifact_build(ROOT)
        uefi_cloud = check_hardware_support_matrix.validate_uefi_ovmf_cloud_scaffold(ROOT)
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
        self.assertEqual(uefi_rows["ENTRY"]["status"], "host-built")
        self.assertEqual(uefi_rows["ESP_STORAGE"]["status"], "loader-implemented")
        self.assertEqual(uefi_rows["FRAMEBUFFER"]["status"], "loader-implemented")
        self.assertEqual(uefi_rows["MEMORY_MAP"]["status"], "loader-implemented")
        self.assertEqual(uefi_rows["EXIT_BOOT_SERVICES"]["status"], "cloud-proof-target")
        self.assertEqual(uefi_rows["KERNEL_HANDOFF"]["status"], "source-implemented")
        self.assertEqual(uefi_rows["KERNEL_HANDOFF"]["proof"], "future-cloud-kernel-entry")
        self.assertEqual(uefi_rows["BUILD_INTEGRATION"]["status"], "host-built")
        self.assertEqual(
            set(uefi_device_rows),
            {"ESP_IMAGE", "OVMF_BOOT", "NO_RAW_LBA_FALLBACK", "PHYSICAL_MEDIA"},
        )
        self.assertEqual(uefi_device_rows["ESP_IMAGE"]["requires"], "fat-esp-kernel-file")
        self.assertEqual(uefi_device_rows["ESP_IMAGE"]["status"], "host-built")
        self.assertEqual(uefi_device_rows["OVMF_BOOT"]["status"], "cloud-proof-target")
        self.assertEqual(
            uefi_device_rows["NO_RAW_LBA_FALLBACK"]["requires"],
            "no-stage2-raw-lba-dependency",
        )
        self.assertEqual(uefi_device_rows["NO_RAW_LBA_FALLBACK"]["status"], "host-checked")
        self.assertEqual(uefi_device_rows["PHYSICAL_MEDIA"]["status"], "unimplemented")
        self.assertEqual(uefi_device_rows["PHYSICAL_MEDIA"]["evidence"], "none")
        self.assertEqual(
            set(uefi_host_rows),
            {"PE_COFF_LOADER", "ESP_FAT_IMAGE", "NO_VM_BOOT"},
        )
        self.assertEqual(
            set(uefi_cloud_rows),
            {"WORKFLOW_DISPATCH", "OVMF_ATTEMPT", "SUPPORT_GUARD", "ARTIFACT_POLICY"},
        )
        self.assertEqual(uefi_host_rows["PE_COFF_LOADER"]["status"], "host-buildable")
        self.assertEqual(uefi_host_rows["ESP_FAT_IMAGE"]["proof"], "host-fat-directory-check")
        self.assertEqual(uefi_host_rows["NO_VM_BOOT"]["kind"], "no-ovmf-or-qemu-execution")
        self.assertEqual(uefi_cloud_rows["WORKFLOW_DISPATCH"]["runner"], "github-actions-ubuntu")
        self.assertEqual(uefi_cloud_rows["OVMF_ATTEMPT"]["mode"], "manual-qemu-ovmf-debugcon")
        self.assertEqual(uefi_cloud_rows["SUPPORT_GUARD"]["mode"], "support-uefi-unclaimed")
        self.assertEqual(uefi_cloud["manifest"]["mode"], "contract")
        self.assertEqual(uefi_cloud["manifest"]["support_claim"], "unclaimed")
        self.assertTrue(uefi_cloud["manifest"]["uefi_boot_rows_moved"])
        self.assertFalse(uefi_cloud["manifest"]["local_mac_qemu_required"])
        self.assertEqual(uefi_cloud["manifest"]["ovmf"]["execution"], "not-run")
        self.assertEqual(
            uefi_cloud["manifest"]["ovmf"]["proof_target"],
            "kernel-entry-debugcon-marker",
        )
        self.assertEqual(
            uefi_artifacts["manifest"]["claim"],
            "host-built-uefi-loader-no-kernel-entry-proof",
        )
        self.assertEqual(uefi_artifacts["manifest"]["vm_execution"], "not-run")
        self.assertEqual(
            uefi_artifacts["manifest"]["kernel_handoff"],
            "source-implemented-pending-ovmf-kernel-entry-marker",
        )
        self.assertIn("exit-boot-services", uefi_artifacts["manifest"]["efi_loader_features"])
        self.assertIn("elf32-pt-load-placement", uefi_artifacts["manifest"]["efi_loader_features"])
        self.assertIn("bios-compatible-elf32-contract", uefi_artifacts["manifest"]["efi_loader_features"])
        self.assertIn("pre-exit-boot-info-validation", uefi_artifacts["manifest"]["efi_loader_features"])
        self.assertIn("uefi64-to-protected32-transition", uefi_artifacts["manifest"]["efi_loader_features"])
        self.assertEqual(uefi_artifacts["pe"]["subsystem"], 10)
        self.assertEqual(uefi_artifacts["pe"]["machine"], "x86_64")
        self.assertEqual(uefi_artifacts["pe"]["loader_kind"], "uefi-loader-proof-application")
        self.assertEqual(uefi_artifacts["esp"]["filesystem"], "FAT16")
        self.assertGreater(uefi_artifacts["esp"]["bootx64_size"], 0)
        self.assertContainsPhrase(scaffold, "future boot-device proof boundary")
        self.assertContainsPhrase(scaffold, "host-built-uefi-loader-no-kernel-entry-proof")
        self.assertContainsPhrase(scaffold, "64-bit UEFI to 32-bit protected-mode transition")
        self.assertContainsPhrase(scaffold, "kernel-owned `VIBEKERN` entry/status marker")
        self.assertContainsPhrase(scaffold, "contract checks must not require local Mac QEMU")
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
            "Aurora OS v0.2 pci=OK pciprobe=00010000 pcimiss=0000FFFC pcicount=00000004 "
            "pcihbus=00000000 pcifirst=00000000 pciid=12378086 pciclass=06000000 "
            "pcitable=OK pcitabcap=00000100 pcitabuse=00000004 pciover=00000000 "
            "pcilast=00000100 pciclassh=89ABCDEF pcimulti=00000001 "
            "pciclsms=00000001 pciclsbr=00000001 pciclspb=00000000 "
            "pcibrbus=FFFFFFFF pciclsmm=00000001 pcidiag=000000FF pciapi=OK "
            "pcilookms=00000100 pcilookbr=00000000 pcilookid=00000000 pcilookmiss=FFFFFFFF "
            "pcicons=OK pcilookide=00000100 pcilookahci=FFFFFFFF "
            "pcilookaud=00000200 pcilookhda=FFFFFFFF "
            "blkctrl=00000001:00000100:FFFFFFFF blkrej=00000000:00000000 "
            "ahcibar=FFFFFFFF:FFFFFFFF:00000000:00000000 ahcireq=0000007F:00000000:00000005"
        )

        fields = check_hardware_support_matrix.validate_pci_status_text(status)
        self.assertEqual(fields["pci"], "OK")

        none_status = (
            "Aurora OS v0.2 pci=NONE pciprobe=00010000 pcimiss=00010000 pcicount=00000000 "
            "pcihbus=00000000 pcifirst=00000000 pciid=00000000 pciclass=00000000 "
            "pcitable=OK pcitabcap=00000100 pcitabuse=00000000 pciover=00000000 "
            "pcilast=00000000 pciclassh=00000000 pcimulti=00000000 "
            "pciclsms=00000000 pciclsbr=00000000 pciclspb=00000000 "
            "pcibrbus=FFFFFFFF pciclsmm=00000000 pcidiag=000000DF pciapi=OK "
            "pcilookms=FFFFFFFF pcilookbr=FFFFFFFF pcilookid=FFFFFFFF pcilookmiss=FFFFFFFF "
            "pcicons=OK pcilookide=FFFFFFFF pcilookahci=FFFFFFFF "
            "pcilookaud=FFFFFFFF pcilookhda=FFFFFFFF "
            "blkctrl=00000001:FFFFFFFF:FFFFFFFF blkrej=00000000:00000000 "
            "ahcibar=FFFFFFFF:FFFFFFFF:00000000:00000000 ahcireq=0000007F:00000000:00000005"
        )
        self.assertEqual(check_hardware_support_matrix.validate_pci_status_text(none_status)["pci"], "NONE")

        with self.assertRaisesRegex(AssertionError, "pciprobe="):
            check_hardware_support_matrix.validate_pci_status_text(status.replace("pciprobe=00010000", "pciprobe=00000200"))
        with self.assertRaisesRegex(AssertionError, "pcimiss="):
            check_hardware_support_matrix.validate_pci_status_text(status.replace("pcimiss=0000FFFC", "pcimiss=0000FFFB"))
        with self.assertRaisesRegex(AssertionError, "pcitabuse="):
            check_hardware_support_matrix.validate_pci_status_text(status.replace("pcitabuse=00000004", "pcitabuse=00000003"))
        with self.assertRaisesRegex(AssertionError, "pciover="):
            check_hardware_support_matrix.validate_pci_status_text(status.replace("pciover=00000000", "pciover=00000001"))
        with self.assertRaisesRegex(AssertionError, "pciapi="):
            check_hardware_support_matrix.validate_pci_status_text(status.replace("pciapi=OK", "pciapi=FAIL"))
        with self.assertRaisesRegex(AssertionError, "pcicons="):
            check_hardware_support_matrix.validate_pci_status_text(status.replace("pcicons=OK", "pcicons=FAIL"))
        with self.assertRaisesRegex(AssertionError, "pcilookmiss="):
            check_hardware_support_matrix.validate_pci_status_text(status.replace("pcilookmiss=FFFFFFFF", "pcilookmiss=00000000"))
        with self.assertRaisesRegex(AssertionError, "pcilookid="):
            check_hardware_support_matrix.validate_pci_status_text(status.replace("pcilookid=00000000", "pcilookid=00000100"))
        with self.assertRaisesRegex(AssertionError, "pcilookms="):
            check_hardware_support_matrix.validate_pci_status_text(status.replace("pcilookms=00000100", "pcilookms=FFFFFFFF"))
        with self.assertRaisesRegex(AssertionError, "pciclassh="):
            check_hardware_support_matrix.validate_pci_status_text(status.replace("pciclassh=89ABCDEF", "pciclassh=00000000"))
        with self.assertRaisesRegex(AssertionError, "pciclspb="):
            check_hardware_support_matrix.validate_pci_status_text(status.replace("pciclspb=00000000", "pciclspb=00000002"))
        with self.assertRaisesRegex(AssertionError, "pcibrbus="):
            check_hardware_support_matrix.validate_pci_status_text(status.replace("pcibrbus=FFFFFFFF", "pcibrbus=00010100"))
        with self.assertRaisesRegex(AssertionError, "pcidiag="):
            check_hardware_support_matrix.validate_pci_status_text(status.replace("pcidiag=000000FF", "pcidiag=0000000F"))
        with self.assertRaisesRegex(AssertionError, "blkctrl="):
            check_hardware_support_matrix.validate_pci_status_text(status.replace("blkctrl=00000001:00000100:FFFFFFFF", "blkctrl=00000001:00000000:FFFFFFFF"))
        with self.assertRaisesRegex(AssertionError, "blkrej="):
            check_hardware_support_matrix.validate_pci_status_text(
                status.replace("pcilookahci=FFFFFFFF", "pcilookahci=00000300").replace(
                    "blkctrl=00000001:00000100:FFFFFFFF",
                    "blkctrl=00000001:00000100:00000300",
                )
            )
        ahci_seen_status = (
            status.replace("pcilookahci=FFFFFFFF", "pcilookahci=00000300")
            .replace("blkctrl=00000001:00000100:FFFFFFFF", "blkctrl=00000001:00000100:00000300")
            .replace("blkrej=00000000:00000000", "blkrej=00000001:00000002")
            .replace("ahcibar=FFFFFFFF:FFFFFFFF:00000000:00000000", "ahcibar=00000300:FEBF1000:FEBF1000:00000001")
            .replace("ahcireq=0000007F:00000000:00000005", "ahcireq=0000007F:00000003:00000007")
        )
        self.assertEqual(check_hardware_support_matrix.validate_pci_status_text(ahci_seen_status)["pcilookahci"], "00000300")
        with self.assertRaisesRegex(AssertionError, "ahcireq="):
            check_hardware_support_matrix.validate_pci_status_text(
                ahci_seen_status.replace("ahcireq=0000007F:00000003:00000007", "ahcireq=0000007F:0000007F:00000007")
            )
        with self.assertRaisesRegex(AssertionError, "ahcibar="):
            check_hardware_support_matrix.validate_pci_status_text(
                ahci_seen_status.replace("ahcibar=00000300:FEBF1000:FEBF1000:00000001", "ahcibar=00000301:FEBF1000:FEBF1000:00000001")
            )
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
            ({"clocksrc": "HPET"}, "clocksrc="),
            ({"clockirq": "00000000"}, "clockirq="),
            ({"clocktick": "0000003F"}, "clockirq="),
            ({"clockhz": "000003E8"}, "clockhz="),
            ({"clockms": "0000027F"}, "clockms="),
            ({"irqctl": "APIC"}, "irqctl="),
            ({"apic": "OK"}, "apic="),
            ({"hpet": "OK"}, "hpet="),
            ({"ata": "FAIL"}, "ata="),
            ({"atawait": "DRQ"}, "atawait="),
            ({"inputpolicy": "00000002:0000003F"}, "inputpolicy="),
            ({"inputdev": "00000002:00000001"}, "inputdev="),
            ({"inputdevices": "00000001:00000003:0000001F:00000004:00000001"}, "inputdevices="),
            ({"inputmods": "00000008"}, "inputmods="),
            ({"keyirq": "00000000"}, "keyirq="),
            ({"mouse": "NONE"}, "mouse="),
            ({"mousedelta": "00000000:00000000"}, "mousedelta="),
            ({"fb": "GOP"}, "fb="),
            ({"fbpresent": "00000002:00000000:00000002"}, "fbpresent="),
            ({"fbsrc": "00000001:00000140:000000C7:00000140:000000F0:00000100:00000003"}, "fbsrc="),
            ({"fbacct": "00000001:00000001:00000000:00000001:00000000:00000001:00000100:0000FA00:00000300"}, "fbacct="),
            ({"doompresent": "00000000"}, "doompresent="),
            ({"audio": "NONE"}, "audio="),
            ({"sb16": "00000000:00000000"}, "sb16="),
            ({"musicpull": "00000000:00000000"}, "musicpull="),
            ({"pciprobe": "00000020"}, "pciprobe="),
            ({"blkctrl": "00000002:00000100:FFFFFFFF"}, "blkctrl="),
            ({"pcilookahci": "00000300", "blkctrl": "00000001:00000100:00000300"}, "blkrej="),
            ({"ahcireq": "0000007F:0000007F:00000005"}, "ahcireq="),
            ({"ahcibar": "00000300:FFFFFFFF:00000000:00000000"}, "ahcibar="),
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
        matrix = doc_text("architecture")
        broadened = matrix.replace(
            "SUPPORT[IDE_ATA_PIO] status=claimed scope=qemu-ide",
            "SUPPORT[IDE_ATA_PIO] status=claimed scope=pc-storage",
        )

        with self.assertRaisesRegex(AssertionError, "IDE_ATA_PIO scope must stay qemu-ide"):
            check_hardware_support_matrix._validate_support_rows(broadened)

    def test_checker_rejects_current_target_broadening(self):
        matrix = doc_text("architecture")
        broadened = matrix.replace(
            "excludes=uefi,physical-hardware,acpi-tables,general-pci,ahci-sata,usb-input-storage,apic-ioapic,hpet,smp,arbitrary-disk-install",
            "excludes=uefi,physical-hardware,general-pci",
        )

        with self.assertRaisesRegex(AssertionError, r"CURRENT_TARGET\[QEMU_LEGACY_PC\] excludes"):
            check_hardware_support_matrix._validate_current_target_row(broadened)

    def test_checker_rejects_uefi_scaffold_becoming_claimed_without_evidence(self):
        scaffold = (ROOT / "boot" / "uefi" / "CONTRACT.txt").read_text()
        broadened = scaffold.replace(
            "UEFI_BOOT[ENTRY] status=host-built",
            "UEFI_BOOT[ENTRY] status=claimed",
        )

        with self.assertRaisesRegex(AssertionError, r"UEFI_BOOT\[ENTRY\] status must stay host-built"):
            check_hardware_support_matrix._validate_uefi_boot_rows(broadened)

    def test_checker_rejects_retired_negative_claim_without_proof(self):
        matrix = doc_text("architecture")
        broadened = matrix.replace(
            "NEGATIVE_CLAIM[USB] status=active",
            "NEGATIVE_CLAIM[USB] status=retired",
        )

        with self.assertRaisesRegex(AssertionError, r"NEGATIVE_CLAIM\[USB\] must stay status=active"):
            check_hardware_support_matrix._validate_negative_claim_rows(broadened)

    def test_checker_rejects_future_proof_requirement_claiming_evidence(self):
        matrix = doc_text("architecture")
        broadened = matrix.replace(
            "PROOF_REQUIREMENT[APIC] status=future artifact=apic-cloud-irq requires=madt-lapic-ioapic-pic-masked evidence=none",
            "PROOF_REQUIREMENT[APIC] status=future artifact=apic-cloud-irq requires=madt-lapic-ioapic-pic-masked evidence=status.txt",
        )

        with self.assertRaisesRegex(AssertionError, r"PROOF_REQUIREMENT\[APIC\] must keep evidence=none"):
            check_hardware_support_matrix._validate_proof_requirement_rows(broadened)

    def test_checker_rejects_interrupt_timer_boundary_overclaim(self):
        matrix = doc_text("architecture")
        apic_claimed = matrix.replace(
            "INTERRUPT_TIMER_BOUNDARY[LOCAL_APIC] status=future",
            "INTERRUPT_TIMER_BOUNDARY[LOCAL_APIC] status=active",
        )
        hpet_evidence = matrix.replace(
            "INTERRUPT_TIMER_BOUNDARY[HPET] status=future route=hpet clock=hpet-comparator requires=hpet-table-mmio-counter-comparator proof=hpet-status-counters evidence=none",
            "INTERRUPT_TIMER_BOUNDARY[HPET] status=future route=hpet clock=hpet-comparator requires=hpet-table-mmio-counter-comparator proof=hpet-status-counters evidence=status.txt",
        )

        with self.assertRaisesRegex(AssertionError, r"INTERRUPT_TIMER_BOUNDARY\[LOCAL_APIC\] status"):
            check_hardware_support_matrix._validate_interrupt_timer_boundary_rows(apic_claimed)
        with self.assertRaisesRegex(AssertionError, r"INTERRUPT_TIMER_BOUNDARY\[HPET\] evidence"):
            check_hardware_support_matrix._validate_interrupt_timer_boundary_rows(hpet_evidence)

    def test_checker_rejects_ahci_or_usb_support_overclaim(self):
        matrix = doc_text("architecture")
        ahci_claimed = matrix.replace(
            "SUPPORT[AHCI] status=unclaimed scope=none proof=future-ahci-sata-storage-proof evidence=none",
            "SUPPORT[AHCI] status=claimed scope=qemu-ahci proof=cloud-smoke evidence=status.txt",
        )
        usb_claimed = matrix.replace(
            "SUPPORT[USB] status=unclaimed scope=none proof=future-usb-input-storage-proof evidence=none",
            "SUPPORT[USB] status=claimed scope=qemu-usb proof=cloud-smoke evidence=status.txt",
        )

        with self.assertRaisesRegex(AssertionError, "AHCI must be status=unclaimed"):
            check_hardware_support_matrix._validate_support_rows(ahci_claimed)
        with self.assertRaisesRegex(AssertionError, "USB must be status=unclaimed"):
            check_hardware_support_matrix._validate_support_rows(usb_claimed)

    def test_checker_rejects_pci_table_contract_broadening(self):
        matrix = doc_text("architecture")
        broadened_bus = matrix.replace(
            "PCI_TABLE_CONTRACT[QEMU_PCI_SCAN] status=status-only buses=256",
            "PCI_TABLE_CONTRACT[QEMU_PCI_SCAN] status=status-only buses=all",
        )
        with self.assertRaisesRegex(AssertionError, "missing PCI_TABLE_CONTRACT rows"):
            check_hardware_support_matrix._validate_pci_table_contract_rows(broadened_bus)

        broadened_driver = matrix.replace(
            "PCI_TABLE_CONTRACT[NO_DRIVER_BINDING] status=guardrail consumers=status-only drivers=none",
            "PCI_TABLE_CONTRACT[NO_DRIVER_BINDING] status=guardrail consumers=status-only drivers=ahci",
        )
        with self.assertRaisesRegex(
            AssertionError,
            r"PCI_TABLE_CONTRACT\[NO_DRIVER_BINDING\] drivers must stay none",
        ):
            check_hardware_support_matrix._validate_pci_table_contract_rows(broadened_driver)

        broadened_api_status = matrix.replace(
            "PCI_TABLE_API[READ_ONLY_LOOKUP] status=status-only",
            "PCI_TABLE_API[READ_ONLY_LOOKUP] status=claimed",
        )
        with self.assertRaisesRegex(AssertionError, r"PCI_TABLE_API\[READ_ONLY_LOOKUP\] status"):
            check_hardware_support_matrix._validate_pci_table_api_rows(broadened_api_status)

        broadened_api_consumers = matrix.replace(
            "consumers=future-drivers",
            "consumers=ahci-usb",
        )
        with self.assertRaisesRegex(AssertionError, r"PCI_TABLE_API\[READ_ONLY_LOOKUP\] consumers"):
            check_hardware_support_matrix._validate_pci_table_api_rows(broadened_api_consumers)

    def test_checker_rejects_qemu_device_model_broadening(self):
        matrix = doc_text("architecture")
        broadened_machine = matrix.replace(
            "QEMU_DEVICE_MODEL[SB16] status=claimed machine=qemu-legacy-pc",
            "QEMU_DEVICE_MODEL[SB16] status=claimed machine=physical-pc",
        )
        with self.assertRaisesRegex(AssertionError, r"QEMU_DEVICE_MODEL\[SB16\] machine"):
            check_hardware_support_matrix._validate_qemu_device_model_rows(broadened_machine)

        broadened_status = matrix.replace(
            "QEMU_DEVICE_MODEL[PCI_CONFIG_STATUS] status=status-only",
            "QEMU_DEVICE_MODEL[PCI_CONFIG_STATUS] status=claimed",
        )
        with self.assertRaisesRegex(AssertionError, r"QEMU_DEVICE_MODEL\[PCI_CONFIG_STATUS\] status"):
            check_hardware_support_matrix._validate_qemu_device_model_rows(broadened_status)

    def test_checker_rejects_future_boot_device_becoming_claimed_without_evidence(self):
        matrix = doc_text("architecture")
        broadened = matrix.replace(
            "BOOT_DEVICE_BOUNDARY[USB_MASS_STORAGE] status=future",
            "BOOT_DEVICE_BOUNDARY[USB_MASS_STORAGE] status=claimed",
        )

        with self.assertRaisesRegex(AssertionError, r"BOOT_DEVICE_BOUNDARY\[USB_MASS_STORAGE\] status"):
            check_hardware_support_matrix._validate_boot_device_boundary_rows(broadened)

    def test_checker_rejects_uefi_boot_device_claims_without_evidence(self):
        scaffold = (ROOT / "boot" / "uefi" / "CONTRACT.txt").read_text()
        broadened = scaffold.replace(
            "UEFI_BOOT_DEVICE[OVMF_BOOT] status=cloud-proof-target",
            "UEFI_BOOT_DEVICE[OVMF_BOOT] status=implemented",
        )

        with self.assertRaisesRegex(
            AssertionError,
            r"UEFI_BOOT_DEVICE\[OVMF_BOOT\] status must stay cloud-proof-target",
        ):
            check_hardware_support_matrix._validate_uefi_boot_device_rows(broadened)

    def test_checker_rejects_uefi_host_artifact_overclaim(self):
        scaffold = (ROOT / "boot" / "uefi" / "CONTRACT.txt").read_text()
        broadened = scaffold.replace(
            "UEFI_HOST_ARTIFACT[PE_COFF_LOADER] status=host-buildable",
            "UEFI_HOST_ARTIFACT[PE_COFF_LOADER] status=claimed",
        )

        with self.assertRaisesRegex(
            AssertionError,
            r"UEFI_HOST_ARTIFACT\[PE_COFF_LOADER\] status must stay host-buildable",
        ):
            check_hardware_support_matrix._validate_uefi_host_artifact_rows(broadened)

    def test_checker_rejects_uefi_cloud_proof_overclaim(self):
        scaffold = (ROOT / "boot" / "uefi" / "CONTRACT.txt").read_text()
        broadened = scaffold.replace(
            "UEFI_CLOUD_PROOF[OVMF_ATTEMPT] status=scaffolded",
            "UEFI_CLOUD_PROOF[OVMF_ATTEMPT] status=proven",
        )

        with self.assertRaisesRegex(
            AssertionError,
            r"UEFI_CLOUD_PROOF\[OVMF_ATTEMPT\] status must stay scaffolded",
        ):
            check_hardware_support_matrix._validate_uefi_cloud_proof_rows(broadened)

    def test_checker_rejects_unsupported_hardware_implementation_wording(self):
        for claim in (
            "The UEFI " + "boot is implemented now.",
            "The ACPI " + "table parser is implemented now.",
            "The AHCI " + "driver is available now.",
            "The USB " + "stack is wired now.",
            "The SM" + "P is implemented now.",
            "The APIC " + "routing is available now.",
            "The HPET " + "timer works now.",
            "It boots directly on " + "physical hardware.",
        ):
            with self.subTest(claim=claim):
                with self.assertRaisesRegex(AssertionError, "possible unbounded hardware claim"):
                    check_hardware_support_matrix._validate_no_unbounded_claims("fixture.md", claim)

        check_hardware_support_matrix._validate_no_unbounded_claims(
            "fixture.md",
            "UEFI boot is not implemented and remains future proof work.",
        )
        check_hardware_support_matrix._validate_no_unbounded_claims(
            "fixture.md",
            "ACPI table discovery is not implemented and remains future proof work.",
        )


if __name__ == "__main__":
    unittest.main()
