import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


class AtaPioContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.kernel = (ROOT / "kernel" / "kernel.asm").read_text()
        cls.triage_doc = (ROOT / "docs" / "cloud-status-triage.md").read_text()
        cls.persistence_doc = (ROOT / "docs" / "persistent-fat16.md").read_text()

    def test_ata_waits_are_bounded_and_record_failures(self):
        kernel = self.kernel
        not_busy = kernel.split("ata_wait_not_busy:", 1)[1].split("ata_wait_drq:", 1)[0]
        drq = kernel.split("ata_wait_drq:", 1)[1].split("ata_wait_ready:", 1)[0]
        ready = kernel.split("ata_wait_ready:", 1)[1].split("ata_read_sector:", 1)[0]

        for source in (
            "ATA_ERROR equ 0x01f1",
            "ATA_STATUS_BSY equ 0x80",
            "ATA_WAIT_POLL_LIMIT equ 0x20000",
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

    def test_commands_wait_for_drq_to_clear_around_transfers(self):
        ready = self.kernel.split("ata_wait_ready:", 1)[1].split("ata_read_sector:", 1)[0]
        read_sector = self.kernel.split("ata_read_sector:", 1)[1].split("ata_write_sector:", 1)[0]
        write_sector = self.kernel.split("ata_write_sector:", 1)[1].split("fat_name_match:", 1)[0]

        self.assertIn("mov dword [ata_wait_phase], ATA_WAIT_READY", ready)
        self.assertIn("test al, ATA_STATUS_DRQ", ready)
        self.assertIn("jz .ok", ready)

        self.assertGreaterEqual(read_sector.count("call ata_wait_ready"), 2)
        self.assertGreaterEqual(write_sector.count("call ata_wait_ready"), 2)
        self.assertIn("out dx, al\n    call ata_io_delay\n\n    call ata_wait_drq", read_sector)
        self.assertIn("mov dword [ata_wait_phase], ATA_WAIT_DATA", read_sector)
        self.assertIn("mov ecx, 256\n.read_word:\n    in ax, dx", read_sector)
        self.assertIn("mov [edi], ax\n    add edi, 2\n    loop .read_word", read_sector)
        self.assertIn("loop .read_word\n    mov dword [ata_wait_phase], ATA_WAIT_IDLE", read_sector)
        self.assertIn("out dx, al\n    call ata_io_delay\n\n    call ata_wait_drq", write_sector)
        self.assertIn("mov dword [ata_wait_phase], ATA_WAIT_DATA", write_sector)
        self.assertIn("mov ecx, 256\n.write_word:\n    mov ax, [esi]", write_sector)
        self.assertIn("out dx, ax\n    add esi, 2\n    loop .write_word", write_sector)
        self.assertIn("loop .write_word\n    mov dword [ata_wait_phase], ATA_WAIT_IDLE", write_sector)
        self.assertNotIn("rep insw", read_sector)
        self.assertNotIn("rep outsw", write_sector)

    def test_writable_root_updates_use_cached_root_sector(self):
        kernel = self.kernel
        cache_read = kernel.split("fat_read_root_sector:", 1)[1].split("fat_write_root_sector:", 1)[0]
        cache_write = kernel.split("fat_write_root_sector:", 1)[1].split("fat_name_match:", 1)[0]
        update = kernel.split("fat_update_writable_size:", 1)[1].split("fat_truncate_writable_file:", 1)[0]

        for source in (
            "ROOT_SECTOR_CACHE_ADDR equ 0x0008d000",
            "root_sector_cache_valid db 0",
            "root_sector_cache_lba dd 0",
            "mov byte [root_sector_cache_valid], 0",
            "fat_read_root_sector:",
            "fat_write_root_sector:",
        ):
            with self.subTest(source=source):
                self.assertIn(source, kernel)

        self.assertIn("cmp byte [root_sector_cache_valid], 1", cache_read)
        self.assertIn("cmp [root_sector_cache_lba], ebx", cache_read)
        self.assertIn("mov esi, ROOT_SECTOR_CACHE_ADDR", cache_read)
        self.assertIn("mov edi, SECTOR_BUFFER_ADDR", cache_read)
        self.assertIn("call ata_read_sector", cache_read)
        self.assertIn("mov [root_sector_cache_lba], ebx", cache_write)
        self.assertIn("call ata_write_sector", cache_write)
        self.assertIn("call fat_read_root_sector", update)
        self.assertIn("call fat_write_root_sector", update)

    def test_fat_cluster_walks_use_cached_fat_sector(self):
        kernel = self.kernel
        cache_read = kernel.split("fat_read_fat_sector:", 1)[1].split("fat_name_match:", 1)[0]
        next_cluster = kernel.split("fat_next_cluster:", 1)[1].split("fat_write_cluster_entry:", 1)[0]
        writer = kernel.split("fat_write_cluster_entry:", 1)[1].split("fat_zero_cluster:", 1)[0]

        for source in (
            "FAT_SECTOR_CACHE_ADDR equ 0x0008e000",
            "fat_sector_cache_valid db 0",
            "fat_sector_cache_lba dd 0",
            "mov byte [fat_sector_cache_valid], 0",
            "fat_read_fat_sector:",
        ):
            with self.subTest(source=source):
                self.assertIn(source, kernel)

        self.assertIn("cmp byte [fat_sector_cache_valid], 1", cache_read)
        self.assertIn("cmp [fat_sector_cache_lba], ebx", cache_read)
        self.assertIn("mov esi, FAT_SECTOR_CACHE_ADDR", cache_read)
        self.assertIn("mov edi, SECTOR_BUFFER_ADDR", cache_read)
        self.assertIn("call ata_read_sector", cache_read)
        self.assertIn("mov [fat_sector_cache_lba], ebx", cache_read)
        self.assertIn("call fat_read_fat_sector", next_cluster)
        self.assertNotIn("call ata_read_sector", next_cluster)
        self.assertIn("call fat_read_fat_sector", writer)
        self.assertIn("mov byte [fat_sector_cache_valid], 0", writer)

    def test_sector_caches_do_not_overlap_pmm_frame_map(self):
        kernel = self.kernel

        def constant(name):
            match = re.search(rf"^{name} equ (0x[0-9a-fA-F]+|[0-9]+)$", kernel, re.MULTILINE)
            self.assertIsNotNone(match, name)
            return int(match.group(1), 0)

        root_cache = constant("ROOT_SECTOR_CACHE_ADDR")
        fat_cache = constant("FAT_SECTOR_CACHE_ADDR")
        sector_buffer = constant("SECTOR_BUFFER_ADDR")
        pmm_map = constant("PMM_FRAME_MAP_ADDR")
        managed_pages = (constant("PMM_MANAGED_END") - constant("PMM_MANAGED_START")) // constant("PAGE_SIZE")
        pmm_map_end = pmm_map + managed_pages

        self.assertLess(root_cache + 512, pmm_map)
        self.assertLess(fat_cache + 512, pmm_map)
        self.assertGreaterEqual(fat_cache, root_cache + 512)
        self.assertGreaterEqual(sector_buffer, pmm_map_end)

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
            "mov edx, [ata_last_lba]",
            "mov edx, [ata_last_status]",
            "mov edx, [ata_last_error]",
            "mov edx, [ata_wait_failures]",
            "mov edx, [ata_wait_timeouts]",
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

    def test_docs_and_triage_track_ata_storage_stalls(self):
        for phrase in (
            "`ata-storage-stalled`",
            "`atawait=BUSY`, `atawait=DRQ`, `atawait=READY`, or `atawait=DATA`",
            "`ataop`, `atawait`, `atalba`, `atastat`, `ataerr`, `atafail`, and `atatmo`",
        ):
            with self.subTest(phrase=phrase):
                self.assertIn(phrase, self.triage_doc)

        for phrase in (
            "ATA PIO waits are bounded and status-reported",
            "commands only start once stale `DRQ` is clear",
            "`ataop`, `atawait`, `atalba`, `atastat`, `ataerr`, `atafail`, and `atatmo`",
            "startup/gameplay wait",
        ):
            with self.subTest(phrase=phrase):
                self.assertIn(phrase, self.persistence_doc)


if __name__ == "__main__":
    unittest.main()
