import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


def strip_asm_comments(source: str) -> str:
    return "\n".join(line.split(";", 1)[0] for line in source.splitlines())


def normalize_doc(source: str) -> str:
    return " ".join(source.split())


class AtaPioContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.kernel = (ROOT / "kernel" / "kernel.asm").read_text()
        cls.triage_doc = (ROOT / "docs" / "proof.txt").read_text()
        cls.persistence_doc = (ROOT / "docs" / "architecture.txt").read_text()

    def test_ata_waits_are_bounded_and_record_failures(self):
        kernel = self.kernel
        not_busy = kernel.split("ata_wait_not_busy:", 1)[1].split("ata_wait_drq:", 1)[0]
        drq = kernel.split("ata_wait_drq:", 1)[1].split("ata_wait_ready:", 1)[0]
        ready = kernel.split("ata_wait_ready:", 1)[1].split("ata_read_sector:", 1)[0]

        for source in (
            "ATA_ERROR equ 0x01f1",
            "ATA_STATUS_BSY equ 0x80",
            "ATA_WAIT_POLL_LIMIT equ 0x20000",
            "ATA_OP_FLUSH equ 3",
            "ATA_WAIT_READY equ 3",
            "ATA_WAIT_DATA equ 4",
            "ata_wait_failures dd 0",
            "ata_wait_timeouts dd 0",
            "ata_wait_error_failures dd 0",
        ):
            with self.subTest(source=source):
                self.assertIn(source, kernel)

        for wait_body in (not_busy, drq, ready):
            with self.subTest(wait=wait_body.splitlines()[0]):
                self.assertIn("mov ecx, ATA_WAIT_POLL_LIMIT", wait_body)
                self.assertIn("mov [ata_last_status], eax", wait_body)
                self.assertIn("inc dword [ata_wait_failures]", wait_body)
                self.assertIn("inc dword [ata_wait_timeouts]", wait_body)
                self.assertIn("mov dx, ATA_ERROR", wait_body)
                self.assertIn("inc dword [ata_wait_error_failures]", wait_body)
                self.assertNotIn("mov ecx, 0x100000", wait_body)

    def test_drq_wait_ignores_error_bits_while_busy(self):
        drq = self.kernel.split("ata_wait_drq:", 1)[1].split("ata_wait_ready:", 1)[0]

        self.assertLess(
            drq.index("test al, ATA_STATUS_BSY"),
            drq.index("test al, ATA_STATUS_DF | ATA_STATUS_ERR"),
        )
        self.assertLess(
            drq.index("test al, ATA_STATUS_DF | ATA_STATUS_ERR"),
            drq.index("test al, ATA_STATUS_DRQ"),
        )

    def test_pio_data_transfers_use_explicit_word_loops(self):
        read = self.kernel.split("ata_read_sector:", 1)[1].split("ata_write_sector:", 1)[0]
        write = self.kernel.split("ata_write_sector:", 1)[1].split("fat_name_match:", 1)[0]

        for instruction in ("rep insw", "rep outsw"):
            with self.subTest(instruction=instruction):
                self.assertNotIn(instruction, read)
                self.assertNotIn(instruction, write)

        for source in (
            ".read_word:",
            "in ax, dx",
            "mov [edi], ax",
            "add edi, 2",
            "loop .read_word",
        ):
            with self.subTest(read_source=source):
                self.assertIn(source, read)

        for source in (
            ".write_word:",
            "mov ax, [esi]",
            "out dx, ax",
            "add esi, 2",
            "loop .write_word",
        ):
            with self.subTest(write_source=source):
                self.assertIn(source, write)

    def test_commands_wait_for_drq_to_clear_around_transfers(self):
        ready = self.kernel.split("ata_wait_ready:", 1)[1].split("ata_read_sector:", 1)[0]
        read_sector = self.kernel.split("ata_read_sector:", 1)[1].split("ata_write_sector:", 1)[0]
        write_sector = self.kernel.split("ata_write_sector:", 1)[1].split("fat_cache_root_dir:", 1)[0]

        self.assertIn("mov dword [ata_wait_phase], ATA_WAIT_READY", ready)
        self.assertIn("test al, ATA_STATUS_DRQ", ready)
        self.assertIn("jz .ok", ready)
        self.assertIn("ata_select_lba28_sector:", self.kernel)
        self.assertIn("mov dx, ATA_DRIVE_HEAD", self.kernel)
        self.assertIn("mov dx, ATA_SECTOR_COUNT", self.kernel)

        self.assertGreaterEqual(read_sector.count("call ata_wait_ready"), 2)
        self.assertGreaterEqual(write_sector.count("call ata_wait_ready"), 2)
        self.assertIn("call ata_select_lba28_sector", read_sector)
        self.assertIn("call ata_select_lba28_sector", write_sector)
        self.assertIn("out dx, al\n    call ata_io_delay\n\n    call ata_wait_drq", read_sector)
        self.assertIn("mov dword [ata_wait_phase], ATA_WAIT_DATA", read_sector)
        self.assertIn("mov ecx, 256\n.read_word:\n    in ax, dx", read_sector)
        self.assertIn("mov [edi], ax\n    add edi, 2\n    loop .read_word", read_sector)
        self.assertIn("loop .read_word\n    mov dword [ata_wait_phase], ATA_WAIT_IDLE\n    call ata_io_delay\n    call ata_wait_ready", read_sector)
        self.assertIn("out dx, al\n    call ata_io_delay\n\n    call ata_wait_drq", write_sector)
        self.assertIn("mov dword [ata_wait_phase], ATA_WAIT_DATA", write_sector)
        self.assertIn("mov ecx, 256\n.write_word:\n    mov ax, [esi]", write_sector)
        self.assertIn("out dx, ax\n    add esi, 2\n    loop .write_word", write_sector)
        self.assertIn("loop .write_word\n    mov dword [ata_wait_phase], ATA_WAIT_IDLE\n    call ata_io_delay\n    call ata_wait_ready", write_sector)
        self.assertNotIn("rep insw", read_sector)
        self.assertNotIn("rep outsw", write_sector)

    def test_storage_status_reports_last_ata_wait_state(self):
        kernel = self.kernel
        smoke = kernel.split("write_smoke_status:", 1)[1].split("smoke_write_hex32:", 1)[0]

        for source in (
            'smoke_ata_text db " ata="',
            'smoke_ataop_text db " ataop="',
            'smoke_atawait_text db " atawait="',
            'smoke_atalba_text db " atalba="',
            'smoke_atastat_text db " atastat="',
            'smoke_ataerr_text db " ataerr="',
            'smoke_atafail_text db " atafail="',
            'smoke_atatmo_text db " atatmo="',
            'smoke_atairq_text db " atairq="',
            'smoke_ataflush_text db " ataflush="',
            "mov edx, [ata_last_lba]",
            "mov edx, [ata_last_status]",
            "mov edx, [ata_last_error]",
            "mov edx, [ata_wait_failures]",
            "mov edx, [ata_wait_timeouts]",
            "mov edx, [ata_irq_count]",
            "mov edx, [ata_flush_count]",
        ):
            with self.subTest(source=source):
                self.assertIn(source, kernel)

        self.assertIn("cmp dword [ata_wait_phase], ATA_WAIT_BUSY", smoke)
        self.assertIn("cmp dword [ata_wait_phase], ATA_WAIT_DRQ", smoke)
        self.assertIn("cmp dword [ata_wait_phase], ATA_WAIT_READY", smoke)
        self.assertIn("cmp dword [ata_wait_phase], ATA_WAIT_DATA", smoke)
        self.assertIn("smoke_busy_text", smoke)
        self.assertIn("smoke_drq_text", smoke)
        self.assertIn("smoke_ready_text", smoke)
        self.assertIn("smoke_data_text", smoke)

    def test_generic_block_device_surface_wraps_ata_pio(self):
        kernel = self.kernel
        block = kernel.split("block_device_init:", 1)[1].split("fat_cache_root_dir:", 1)[0]
        fat_and_files = strip_asm_comments(
            kernel.split("fat_cache_root_dir:", 1)[1].split("irq_ide_primary:", 1)[0]
        )

        for source in (
            "BLOCK_DEVICE_ATA_PIO equ 1",
            "BLOCK_DEVICE_AHCI equ 2",
            "BLOCK_OPS_READ_OFFSET equ 0",
            "BLOCK_OPS_WRITE_OFFSET equ 4",
            "BLOCK_OPS_FLUSH_OFFSET equ 8",
            "BLOCK_OPS_DWORDS equ 3",
            "BLOCK_OP_READ equ 1",
            "BLOCK_OP_WRITE equ 2",
            "BLOCK_OP_FLUSH equ 3",
            "BLOCK_STATUS_OK equ 1",
            "BLOCK_STATUS_FAIL equ 2",
            "BLOCK_SECTOR_BYTES equ 512",
            "BLOCK_ERROR_NO_FAT_PARTITION equ 5",
            "BLOCK_ERROR_PARTITION_RANGE equ 6",
            "BLOCK_ERROR_UNSUPPORTED_CONTROLLER equ 7",
            "BLOCK_PARTITION_RAW equ 1",
            "BLOCK_PARTITION_MBR_FAT16 equ 2",
            "MBR_PARTITION_TABLE_OFFSET equ 446",
            "MBR_PARTITION_TYPE_FAT16_LARGE equ 0x06",
            "block_device_kind dd 0",
            "block_device_status dd 0",
            "block_last_op dd 0",
            "block_last_lba dd 0",
            "block_last_partition_lba dd 0",
            "block_last_count dd 0",
            "block_transfer_count dd 0",
            "block_flush_count dd 0",
            "block_error_count dd 0",
            "block_last_error dd 0",
            "block_driver_read_op dd 0",
            "block_driver_write_op dd 0",
            "block_driver_flush_op dd 0",
            "block_driver_supported_bdf dd PCI_LOOKUP_NOT_FOUND",
            "block_driver_ahci_bdf dd PCI_LOOKUP_NOT_FOUND",
            "block_ata_pio_ops:",
            "block_partition_status dd 0",
            "block_partition_error dd 0",
            "block_partition_lba_base dd 0",
            "block_partition_sector_count dd 0",
        ):
            with self.subTest(source=source):
                self.assertIn(source, kernel)

        for source in (
            "block_driver_install_ata_pio_ops:",
            "call dword [block_driver_read_op]",
            "call dword [block_driver_write_op]",
            "call dword [block_driver_flush_op]",
            "inc dword [block_transfer_count]",
            "inc dword [block_flush_count]",
            "inc dword [block_error_count]",
            "call block_selected_validate",
            "call block_selected_translate_lba",
        ):
            with self.subTest(block_source=source):
                self.assertIn(source, block)

        for low_level_call in (
            "call ata_read_sector",
            "call ata_write_sector",
            "call ata_flush_cache",
        ):
            with self.subTest(low_level_call=low_level_call):
                self.assertNotIn(low_level_call, fat_and_files)

        for selected_block_call in (
            "call block_selected_read_sector",
            "call block_selected_write_sector",
            "call block_selected_read_sectors",
            "call block_selected_write_sectors",
        ):
            with self.subTest(selected_block_call=selected_block_call):
                self.assertIn(selected_block_call, fat_and_files)

    def test_mbr_partition_handoff_is_block_layer_owned(self):
        kernel = self.kernel
        storage = kernel.split("storage_init:", 1)[1].split("ata_io_delay:", 1)[0]
        partition = kernel.split("block_partition_select_fat16:", 1)[1].split(
            "block_selected_validate:", 1
        )[0]
        selected = kernel.split("block_selected_validate:", 1)[1].split(
            "fat_cache_root_dir:", 1
        )[0]

        self.assertIn("call block_partition_select_fat16", storage)
        self.assertIn("mov dword [fat_lba_base], 0", storage)
        self.assertIn("call block_selected_read_sector", storage)
        self.assertNotIn("SECTOR_BUFFER_ADDR + 454", storage)

        for source in (
            "cmp word [SECTOR_BUFFER_ADDR + MBR_SIGNATURE_OFFSET], MBR_SIGNATURE_VALUE",
            "MBR_PARTITION_TABLE_OFFSET",
            "MBR_PARTITION_COUNT",
            "MBR_PARTITION_TYPE_FAT16_CHS",
            "MBR_PARTITION_TYPE_FAT16_LARGE",
            "MBR_PARTITION_TYPE_FAT16_LBA",
            "mov [block_partition_lba_base], ecx",
            "mov [block_partition_sector_count], edx",
            "add eax, edx\n    jc .next_entry",
            "mov dword [block_partition_status], BLOCK_PARTITION_MBR_FAT16",
            "mov dword [block_partition_status], BLOCK_PARTITION_RAW",
            "BLOCK_ERROR_NO_FAT_PARTITION",
        ):
            with self.subTest(partition_source=source):
                self.assertIn(source, partition)

        for source in (
            "cmp dword [block_partition_status], BLOCK_PARTITION_RAW",
            "cmp dword [block_partition_status], BLOCK_PARTITION_MBR_FAT16",
            "mov [block_last_partition_lba], eax",
            "add eax, [block_partition_lba_base]",
            "add edx, ecx",
            "cmp eax, [block_partition_sector_count]",
            "cmp edx, [block_partition_sector_count]",
            "mov dword [block_last_error], BLOCK_ERROR_PARTITION_RANGE",
            "inc dword [block_error_count]",
        ):
            with self.subTest(selected_source=source):
                self.assertIn(source, selected)

    def test_storage_status_reports_generic_block_device_state(self):
        kernel = self.kernel
        smoke = kernel.split("write_smoke_status:", 1)[1].split("smoke_write_hex32:", 1)[0]

        for source in (
            'smoke_blkdev_text db " blkdev="',
            'smoke_blkop_text db " blkop="',
            'smoke_blkstat_text db " blkstat="',
            'smoke_blklba_text db " blklba="',
            'smoke_blkplba_text db " blkplba="',
            'smoke_blkcnt_text db " blkcnt="',
            'smoke_blkxfer_text db " blkxfer="',
            'smoke_blkerr_text db " blkerr="',
            'smoke_blkecode_text db " blkecode="',
            'smoke_blkpart_text db " blkpart="',
            'smoke_blkpbase_text db " blkpbase="',
            'smoke_blkpcnt_text db " blkpcnt="',
            'smoke_blkperr_text db " blkperr="',
            'smoke_blkctrl_text db " blkctrl="',
            'smoke_blkrej_text db " blkrej="',
            'smoke_atapio_text db "ATAPIO"',
            'smoke_raw_text db "RAW"',
            'smoke_mbr_text db "MBR"',
            'smoke_flush_text db "FLUSH"',
            "mov edx, [block_last_lba]",
            "mov edx, [block_last_partition_lba]",
            "mov edx, [block_last_count]",
            "mov edx, [block_transfer_count]",
            "mov edx, [block_flush_count]",
            "mov edx, [block_error_count]",
            "mov edx, [block_last_error]",
            "mov edx, [block_partition_lba_base]",
            "mov edx, [block_partition_sector_count]",
            "mov edx, [block_partition_error]",
            "mov edx, [block_driver_supported_bdf]",
            "mov edx, [block_driver_ahci_bdf]",
            "mov edx, [block_driver_reject_count]",
            "mov edx, [block_driver_last_rejected_kind]",
        ):
            with self.subTest(source=source):
                self.assertIn(source, kernel)

        self.assertIn("cmp dword [block_device_kind], BLOCK_DEVICE_ATA_PIO", smoke)
        self.assertIn("cmp dword [block_last_op], BLOCK_OP_READ", smoke)
        self.assertIn("cmp dword [block_last_op], BLOCK_OP_WRITE", smoke)
        self.assertIn("cmp dword [block_last_op], BLOCK_OP_FLUSH", smoke)
        self.assertIn("cmp dword [block_device_status], BLOCK_STATUS_OK", smoke)
        self.assertIn("cmp dword [block_device_status], BLOCK_STATUS_FAIL", smoke)
        self.assertIn("cmp dword [block_partition_status], BLOCK_PARTITION_RAW", smoke)
        self.assertIn("cmp dword [block_partition_status], BLOCK_PARTITION_MBR_FAT16", smoke)
        self.assertIn("cmp dword [block_partition_status], BLOCK_PARTITION_FAIL", smoke)

    def test_docs_and_triage_track_ata_storage_stalls(self):
        triage_doc = normalize_doc(self.triage_doc)
        persistence_doc = normalize_doc(self.persistence_doc)

        for phrase in (
            "`ata-storage-stalled`",
            "`atawait=BUSY`, `atawait=DRQ`, `atawait=READY`, or `atawait=DATA`",
            "`ataop`, `atawait`, `atalba`, `atastat`, `ataerr`, `atafail`, and `atatmo`",
            "`blkdev`, `blkop`, `blkstat`, `blklba`, `blkplba`, `blkcnt`, `blkxfer`, and `blkerr`",
            "`blkecode`, `blkpart`, `blkpbase`, `blkpcnt`, and `blkperr`",
        ):
            with self.subTest(phrase=phrase):
                self.assertIn(phrase, triage_doc)

        for phrase in (
            "ATA PIO waits are bounded and status-reported",
            "commands only start once stale `DRQ` is clear",
            "`ataop`, `atawait`, `atalba`, `atastat`, `ataerr`, `atafail`, and `atatmo`",
            "`blkdev`, `blkop`, `blkstat`, `blklba`, `blkplba`, `blkcnt`, `blkxfer`, and `blkerr`",
            "`blkecode`, `blkpart`, `blkpbase`, `blkpcnt`, and `blkperr`",
            "FAT, config, save, and program-load code share that block interface",
            "FAT keeps partition-relative sector numbers",
            "MBR/FAT16 partition handoff",
            "selected-partition range checks",
            "startup/gameplay wait",
        ):
            with self.subTest(phrase=phrase):
                self.assertIn(phrase, persistence_doc)


if __name__ == "__main__":
    unittest.main()
