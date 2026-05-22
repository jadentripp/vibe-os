import os
import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
BUILD = Path(os.environ.get("VIBE_HOST_TEST_BUILD_DIR") or ROOT / "build")
SECTOR_SIZE = 512


def read(path):
    return path.read_bytes()


def text(path):
    return path.read_text()


def doc_text(name):
    txt_path = ROOT / "docs" / f"{name}.txt"
    if txt_path.exists():
        return text(txt_path)
    return text(ROOT / "docs" / f"{name}.md")


def equ_value(source, name):
    match = re.search(rf"^{re.escape(name)}\s+equ\s+([^\n;]+)", source, re.MULTILINE)
    if not match:
        raise AssertionError(f"missing {name} equ")
    return int(match.group(1).strip(), 0)


def make_var_value(source, name):
    match = re.search(rf"^{re.escape(name)}\s*:?=\s*([0-9]+)", source, re.MULTILINE)
    if not match:
        raise AssertionError(f"missing {name} make variable")
    return int(match.group(1))


def py_const_value(source, name):
    match = re.search(rf"^{re.escape(name)}\s*=\s*([0-9]+)", source, re.MULTILINE)
    if not match:
        raise AssertionError(f"missing {name} python constant")
    return int(match.group(1))


class BootLoaderVmContractTests(unittest.TestCase):
    def test_raw_boot_layout_constants_match_builder_makefile_and_docs(self):
        stage1 = text(ROOT / "boot" / "stage1.asm")
        stage2 = text(ROOT / "boot" / "stage2.asm")
        image_builder = text(ROOT / "tools" / "make_wad_image.py")
        makefile = text(ROOT / "Makefile")
        readme = text(ROOT / "README.md")

        stage2_lba = equ_value(stage1, "STAGE2_LBA")
        stage2_sectors = equ_value(stage1, "STAGE2_SECTORS")
        kernel_lba = equ_value(stage2, "KERNEL_LBA")
        kernel_sectors = equ_value(stage2, "KERNEL_SECTORS")
        partition_start = py_const_value(image_builder, "PARTITION_START")

        self.assertEqual(stage2_lba, py_const_value(image_builder, "STAGE2_LBA"))
        self.assertEqual(stage2_sectors, py_const_value(image_builder, "STAGE2_SECTORS"))
        self.assertEqual(stage2_sectors, equ_value(stage2, "STAGE2_SECTORS"))
        self.assertEqual(kernel_lba, py_const_value(image_builder, "KERNEL_LBA"))
        self.assertEqual(kernel_sectors, py_const_value(image_builder, "KERNEL_SECTORS"))
        self.assertEqual(kernel_lba, stage2_lba + stage2_sectors)
        self.assertLessEqual(kernel_lba + kernel_sectors, partition_start)
        self.assertEqual(make_var_value(makefile, "STAGE2_MAX_BYTES"), stage2_sectors * SECTOR_SIZE)
        self.assertEqual(make_var_value(makefile, "KERNEL_ELF_MAX_BYTES"), kernel_sectors * SECTOR_SIZE)
        normalized_readme = " ".join(readme.split())
        self.assertTrue(
            (
                f"LBA {stage2_lba}-{stage2_lba + stage2_sectors - 1}: Stage 2 bootloader"
                in normalized_readme
            )
            or (
                f"LBA {stage2_lba}-{stage2_lba + stage2_sectors - 1} is Stage 2"
                in normalized_readme
            )
        )
        self.assertIn(
            f"LBA {kernel_lba}-{kernel_lba + kernel_sectors - 1}: protected-mode kernel ELF image",
            readme,
        )
        self.assertIn("dw STAGE2_SECTORS", stage1)
        self.assertIn("dq STAGE2_LBA", stage1)
        self.assertEqual(equ_value(stage2, "KERNEL_READ_CHUNK_SECTORS"), 64)
        self.assertIn("call load_kernel_elf_sectors", stage2)
        self.assertIn("mov word [kernel_load_remaining], KERNEL_SECTORS", stage2)
        self.assertIn("cmp ax, KERNEL_READ_CHUNK_SECTORS", stage2)
        self.assertIn("kernel_packet_lba:", stage2)

    def test_disk_image_contains_raw_boot_regions_before_fat_partition(self):
        image_builder = text(ROOT / "tools" / "make_wad_image.py")
        partition_start = py_const_value(image_builder, "PARTITION_START")
        stage2_lba = py_const_value(image_builder, "STAGE2_LBA")
        stage2_sectors = py_const_value(image_builder, "STAGE2_SECTORS")
        kernel_lba = py_const_value(image_builder, "KERNEL_LBA")
        kernel_sectors = py_const_value(image_builder, "KERNEL_SECTORS")

        image = read(BUILD / "disk.img")
        stage1 = read(BUILD / "stage1.bin")
        stage2 = read(BUILD / "stage2.bin")
        kernel = read(BUILD / "kernel.elf")

        self.assertEqual(image[0:440], stage1[0:440])
        self.assertEqual(image[510:512], b"\x55\xaa")
        self.assertEqual(int.from_bytes(image[446 + 8:446 + 12], "little"), partition_start)
        self.assertEqual(image[stage2_lba * SECTOR_SIZE:stage2_lba * SECTOR_SIZE + len(stage2)], stage2)
        stage2_padding = image[
            stage2_lba * SECTOR_SIZE + len(stage2):(stage2_lba + stage2_sectors) * SECTOR_SIZE
        ]
        self.assertEqual(stage2_padding, b"\0" * len(stage2_padding))
        self.assertEqual(image[kernel_lba * SECTOR_SIZE:kernel_lba * SECTOR_SIZE + len(kernel)], kernel)
        kernel_padding = image[
            kernel_lba * SECTOR_SIZE + len(kernel):(kernel_lba + kernel_sectors) * SECTOR_SIZE
        ]
        self.assertEqual(kernel_padding, b"\0" * len(kernel_padding))
        self.assertLessEqual((kernel_lba + kernel_sectors) * SECTOR_SIZE, partition_start * SECTOR_SIZE)

    def test_stage2_performs_protected_mode_elf_handoff(self):
        stage1 = text(ROOT / "boot" / "stage1.asm")
        stage2 = text(ROOT / "boot" / "stage2.asm")

        for source in (stage1, stage2):
            self.assertIn("call require_edd", source)
            self.assertIn("DISK_RETRIES equ 3", source)
            self.assertIn("disk_use_edd db 0", source)
            self.assertIn("mov ah, 0x42", source)
            self.assertIn("int 0x13", source)
            self.assertIn("xor ah, ah", source)
            self.assertIn("dec byte [disk_retries_left]", source)

        self.assertIn("jmp 0x0000:stage1_entry", stage1)
        self.assertIn("stage1_entry:", stage1)
        self.assertIn("read_stage2_chs:", stage1)
        self.assertIn("read_kernel_packet_chs:", stage2)
        self.assertIn("cmp word [stage2_packet_sectors], STAGE2_SECTORS", stage1)
        self.assertIn("cmp ax, [kernel_packet_requested_sectors]", stage2)
        for source in (stage1, stage2):
            self.assertIn("ensure_chs_geometry:", source)
            self.assertIn("read_one_sector_chs:", source)
            self.assertIn("mov ax, 0x0201", source)
        self.assertIn("kernel_packet_requested_sectors dw 0", stage2)

        for source in (
            "enable_a20:",
            "call clear_boot_info",
            "call initialize_bios_boot_handoff",
            "call validate_boot_info_handoff",
            "call test_a20",
            "call enable_a20_fast",
            "call enable_a20_8042",
            "jc a20_error",
            "in al, 0x92",
            "or al, 0x02",
            "cmp byte [A20_TEST_LOW_OFF], 0x00",
            "cmp dword [VBE_INFO_ADDR], 0x41534556",
            "cmp word [VBE_INFO_ADDR + 4], 0x0200",
            "VBE_MAX_MODES equ 128",
            "call validate_vbe_mode_info",
            "validate_boot_info_handoff:",
            "add eax, [BOOT_VIDEO_FB_ADDR]",
            "lgdt [gdt_descriptor]",
            "or eax, 0x00000001",
            "mov cr0, eax",
            "jmp CODE_SEG:protected_entry",
            "bits 32",
            "protected_entry:",
            "mov esp, 0x70000",
            "call elf_load_kernel",
            "jmp eax",
            "mov word [BOOT_LOADER_STATUS_ADDR], BOOT_LOADER_STATUS_OK",
        ):
            self.assertIn(source, stage2)
        enable_a20_block = stage2.split("enable_a20:", 1)[1].split("enable_a20_fast:", 1)[0]
        self.assertIn("or dword [BOOT_LOADER_FLAGS_ADDR], BOOT_LOADER_FLAG_A20", enable_a20_block)
        kernel_chs_reader = stage2.split("read_kernel_packet_chs:", 1)[1].split("ensure_chs_geometry:", 1)[0]
        self.assertNotIn("BOOT_LOADER_FLAG_A20", kernel_chs_reader)

        for source in (
            "BOOT_LOADER_MAGIC_ADDR equ BOOT_INFO_ADDR + 48",
            "BOOT_LOADER_VERSION_ADDR equ BOOT_INFO_ADDR + 52",
            "BOOT_LOADER_FLAGS_ADDR equ BOOT_INFO_ADDR + 56",
            "BOOT_LOADER_KERNEL_ENTRY_ADDR equ BOOT_INFO_ADDR + 64",
            "BOOT_LOADER_ELF_LOADS_ADDR equ BOOT_INFO_ADDR + 68",
            "BOOT_LOADER_MAGIC equ 0x534f4942",
            "BOOT_LOADER_FLAG_STAGE2_REACHED equ 0x00000001",
            "BOOT_LOADER_FLAG_KERNEL_EDD_READ equ 0x00000004",
            "BOOT_LOADER_FLAG_KERNEL_CHS_READ equ 0x00000008",
            "BOOT_LOADER_FLAG_A20 equ 0x00000080",
            "BOOT_LOADER_FLAG_GDT_LOADED equ 0x00000100",
            "BOOT_LOADER_FLAG_PROTECTED_MODE equ 0x00000200",
            "BOOT_LOADER_FLAG_ELF_VALID equ 0x00000400",
            "BOOT_LOADER_FLAG_ENTRY_COVERED equ 0x00000800",
            "BOOT_LOADER_FLAG_E820_BOUNDED equ 0x00001000",
            "BOOT_LOADER_FLAG_VIDEO_VALID equ 0x00002000",
            "BOOT_LOADER_FLAG_ELF_PHDR_VALID equ 0x00004000",
            "BOOT_LOADER_FLAG_CHS_GEOMETRY equ 0x00008000",
            "BOOT_LOADER_REQUIRED_PROTECTED_FLAGS equ",
            "initialize_bios_boot_handoff:",
            "mov dword [BOOT_LOADER_MAGIC_ADDR], BOOT_LOADER_MAGIC",
            "mov word [BOOT_LOADER_STAGE2_SECTORS_ADDR], STAGE2_SECTORS",
            "or dword [BOOT_LOADER_FLAGS_ADDR], BOOT_LOADER_FLAG_EDD_PRESENT",
            "or dword [BOOT_LOADER_FLAGS_ADDR], BOOT_LOADER_FLAG_KERNEL_EDD_READ",
            "or dword [BOOT_LOADER_FLAGS_ADDR], BOOT_LOADER_FLAG_KERNEL_CHS_READ",
            "or dword [BOOT_LOADER_FLAGS_ADDR], BOOT_LOADER_FLAG_E820 | BOOT_LOADER_FLAG_E820_BOUNDED",
            "or dword [BOOT_LOADER_FLAGS_ADDR], BOOT_LOADER_FLAG_VBE_LFB | BOOT_LOADER_FLAG_VIDEO_VALID",
            "or dword [BOOT_LOADER_FLAGS_ADDR], BOOT_LOADER_FLAG_MODE13 | BOOT_LOADER_FLAG_VIDEO_VALID",
            "or dword [BOOT_LOADER_FLAGS_ADDR], BOOT_LOADER_FLAG_CHS_GEOMETRY",
            "or dword [BOOT_LOADER_FLAGS_ADDR], BOOT_LOADER_FLAG_GDT_LOADED",
            "or dword [BOOT_LOADER_FLAGS_ADDR], BOOT_LOADER_FLAG_PROTECTED_MODE",
            "call validate_protected_kernel_handoff",
            "validate_protected_kernel_handoff:",
            "mov ebx, BOOT_LOADER_REQUIRED_PROTECTED_FLAGS",
            "test eax, BOOT_LOADER_FLAG_KERNEL_EDD_READ",
            "test eax, BOOT_LOADER_FLAG_EDD_PRESENT",
            "test eax, BOOT_LOADER_FLAG_KERNEL_CHS_READ",
            "test eax, BOOT_LOADER_FLAG_CHS_GEOMETRY",
            "and edx, BOOT_LOADER_FLAG_VBE_LFB | BOOT_LOADER_FLAG_MODE13",
            "cmp dword [BOOT_LOADER_KERNEL_ENTRY_ADDR], KERNEL_PHYS",
        ):
            self.assertIn(source, stage2)

        elf_loader = stage2.split("elf_load_kernel:", 1)[1].split("elf_fail:", 1)[0]
        for source in (
            "cmp dword [esi], ELF_MAGIC",
            "cmp byte [esi + 4], ELFCLASS32",
            "cmp byte [esi + 5], ELFDATA2LSB",
            "cmp byte [esi + 6], ELF_VERSION_CURRENT",
            "cmp word [esi + 16], ET_EXEC",
            "cmp word [esi + 18], EM_386",
            "cmp dword [esi + 20], ELF_VERSION_CURRENT",
            "cmp word [esi + 40], ELF_HEADER_SIZE",
            "cmp word [esi + 42], 32",
            "cmp ecx, ELF_MAX_PHDRS",
            "cmp eax, KERNEL_ELF_MAX_BYTES",
            "cmp dword [ebx], PT_LOAD",
            "cmp edi, [ebx + 8]",
            "cmp edi, KERNEL_PHYS",
            "cmp eax, edx",
            "test eax, eax",
            "jb elf_fail",
            "cmp esi, KERNEL_LOAD_LIMIT",
            "rep movsb",
            "rep stosb",
            "mov byte [elf_entry_covered], 1",
            "test ebp, ebp",
            "cmp byte [elf_entry_covered], 1",
            "mov eax, [KERNEL_ELF_PHYS + 24]",
            "mov [BOOT_LOADER_ELF_LOADS_ADDR], ebp",
            "mov [BOOT_LOADER_KERNEL_ENTRY_ADDR], eax",
            "or dword [BOOT_LOADER_FLAGS_ADDR], BOOT_LOADER_FLAG_ELF_VALID | BOOT_LOADER_FLAG_ENTRY_COVERED | BOOT_LOADER_FLAG_ELF_PHDR_VALID",
        ):
            self.assertIn(source, elf_loader)

    def test_bios_e820_boot_info_is_consumed_by_pmm_status(self):
        stage2 = text(ROOT / "boot" / "stage2.asm")
        kernel = text(ROOT / "kernel" / "kernel.asm")

        for source in (
            "BOOT_E820_MAGIC_ADDR equ BOOT_INFO_ADDR + 36",
            "BOOT_E820_COUNT equ BOOT_INFO_ADDR + 40",
            "BOOT_E820_ENTRY_SIZE_ADDR equ BOOT_INFO_ADDR + 42",
            "BOOT_E820_MAP_ADDR_PTR equ BOOT_INFO_ADDR + 44",
            "E820_SMAP equ 0x534d4150",
            "E820_ENTRY_SIZE equ 24",
            "E820_MAX_ENTRIES equ 32",
            "E820_MAP_END equ E820_MAP_ADDR + E820_ENTRY_SIZE * E820_MAX_ENTRIES",
            "call collect_e820_map",
            "mov eax, 0xe820",
            "mov edx, E820_SMAP",
            "mov ecx, E820_ENTRY_SIZE",
            "cmp di, E820_MAP_END",
            "cmp ecx, 20",
            "test dword [es:di + 20], 1",
            "mov dword [BOOT_E820_MAGIC_ADDR], BOOT_E820_MAGIC",
        ):
            self.assertIn(source, stage2)

        pmm_init = kernel.split("pmm_init:", 1)[1].split("pmm_reserve_pages:", 1)[0]
        self.assertIn("PMM_SOURCE_E820 equ 2", kernel)
        for source in (
            "PMM_FRAME_USED equ 0",
            "PMM_FRAME_FREE equ 1",
            "PMM_FRAME_RESERVED equ 2",
        ):
            self.assertIn(source, kernel)
        for source in (
            "cmp dword [BOOT_E820_MAGIC_ADDR], BOOT_E820_MAGIC",
            "movzx ecx, word [BOOT_E820_COUNT]",
            "movzx eax, word [BOOT_E820_ENTRY_SIZE_ADDR]",
            "mov esi, [BOOT_E820_MAP_ADDR_PTR]",
            "call pmm_scan_e820_entry",
            "call pmm_mark_e820_usable_entry",
            "call pmm_reserve_e820_entry",
            "mov byte [pmm_source], PMM_SOURCE_E820",
        ):
            self.assertIn(source, pmm_init)

        for source in (
            "pmm_scan_e820_entry:",
            "pmm_validate_e820_handoff:",
            "pmm_mark_e820_usable_entry:",
            "pmm_reserve_e820_entry:",
            "pmm_reserve_tracked_hardware_ranges:",
            "pmm_probe_exclusions:",
            "pmm_page_is_free:",
            "pmm_refresh_frame_counters:",
            "mov al, PMM_FRAME_RESERVED",
            "mov eax, [pmm_dma_base]",
            "mov eax, [pmm_mmio_base]",
            "cmp byte [edi], PMM_FRAME_USED",
            "pmm_e820_entry_size dd 0",
            "pmm_e820_map_ptr dd 0",
            "pmm_e820_map_end dd 0",
            "pmm_e820_usable_entries dd 0",
            "pmm_e820_usable_pages dd 0",
            "pmm_e820_reserved_pages dd 0",
            "pmm_managed_start dd 0",
            "pmm_managed_end dd 0",
            "pmm_scan_free_pages dd 0",
            "pmm_scan_used_pages dd 0",
            "pmm_scan_reserved_pages dd 0",
            'smoke_e820_text db " e820=", 0',
            'smoke_e820sz_text db " e820sz=", 0',
            'smoke_e820map_text db " e820map=", 0',
            'smoke_e820use_text db " e820use=", 0',
            'smoke_e820res_text db " e820res=", 0',
            'smoke_pmmwin_text db " pmmwin=", 0',
            'smoke_pmmmap_text db " pmmmap=", 0',
            'smoke_pmmguard_text db " pmmguard=", 0',
            'smoke_pmmuse_text db " pmmuse=", 0',
            'smoke_pmmtype_text db " pmmtype=", 0',
            'smoke_pmmchk_text db " pmmchk=", 0',
            'smoke_pmmalloc_text db " pmmalloc=", 0',
            'smoke_pmmdeny_text db " pmmdeny=", 0',
            'smoke_uguard_text db " uguard=", 0',
            'smoke_vmmguard_text db " vmmguard=", 0',
            'smoke_pmmdma_text db " pmmdma=", 0',
            'smoke_pmmio_text db " pmmio=", 0',
        ):
            self.assertIn(source, kernel)

        for source in (
            "BOOT_LOADER_MAGIC_ADDR equ BOOT_INFO_ADDR + 48",
            "BOOT_LOADER_STATUS_ADDR equ BOOT_INFO_ADDR + 54",
            "BOOT_LOADER_FLAGS_ADDR equ BOOT_INFO_ADDR + 56",
            "BOOT_LOADER_KERNEL_ENTRY_ADDR equ BOOT_INFO_ADDR + 64",
            "BOOT_LOADER_ELF_LOADS_ADDR equ BOOT_INFO_ADDR + 68",
            "BOOT_LOADER_REQUIRED_FLAGS equ BOOT_LOADER_FLAG_STAGE2_REACHED",
            "BOOT_LOADER_FLAG_E820_BOUNDED equ 0x00001000",
            "BOOT_LOADER_FLAG_VIDEO_VALID equ 0x00002000",
            "BOOT_LOADER_FLAG_ELF_PHDR_VALID equ 0x00004000",
            "BOOT_LOADER_FLAG_CHS_GEOMETRY equ 0x00008000",
            "BIOS_BOOT_EXPECTED_STAGE2_SECTORS equ 16",
            "BIOS_BOOT_EXPECTED_KERNEL_SECTORS equ 320",
            "BIOS_BOOT_STATUS_OK equ 1",
            "call bios_boot_probe",
            "bios_boot_probe:",
            "cmp dword [BOOT_LOADER_MAGIC_ADDR], BOOT_LOADER_MAGIC",
            "mov [bios_boot_flags], eax",
            "cmp dword [bios_boot_loader_status], BOOT_LOADER_STATUS_OK",
            "test eax, BOOT_LOADER_FLAG_KERNEL_EDD_READ | BOOT_LOADER_FLAG_KERNEL_CHS_READ",
            "test eax, BOOT_LOADER_FLAG_KERNEL_EDD_READ",
            "test eax, BOOT_LOADER_FLAG_EDD_PRESENT",
            "test eax, BOOT_LOADER_FLAG_KERNEL_CHS_READ",
            "test eax, BOOT_LOADER_FLAG_CHS_GEOMETRY",
            "test eax, BOOT_LOADER_FLAG_VBE_LFB | BOOT_LOADER_FLAG_MODE13",
            "and edx, BOOT_LOADER_FLAG_VBE_LFB | BOOT_LOADER_FLAG_MODE13",
            "cmp dword [bios_boot_kernel_entry], start",
            "cmp dword [bios_boot_stage2_sectors], BIOS_BOOT_EXPECTED_STAGE2_SECTORS",
            "cmp dword [bios_boot_kernel_sectors], BIOS_BOOT_EXPECTED_KERNEL_SECTORS",
            "mov byte [bios_boot_status], BIOS_BOOT_STATUS_OK",
            "bios_boot_flags dd 0",
            "bios_boot_kernel_entry dd 0",
            "bios_boot_elf_loads dd 0",
            'smoke_biosboot_text db " biosboot=", 0',
            'smoke_biosflags_text db " biosflags=", 0',
            'smoke_biosentry_text db " biosentry=", 0',
            'smoke_biosspan_text db " biosspan=", 0',
            "mov esi, smoke_biosboot_text",
        ):
            self.assertIn(source, kernel)

        checker = text(ROOT / "tools" / "check_vm_status_proof.py")
        for source in (
            "def validate_firmware_boot_handoff",
            'BIOS_BOOT_REQUIRED_FLAGS = (',
            'BIOS_BOOT_DISK_FLAGS = BOOT_LOADER_FLAG_KERNEL_EDD_READ | BOOT_LOADER_FLAG_KERNEL_CHS_READ',
            'BIOS_BOOT_VIDEO_FLAGS = BOOT_LOADER_FLAG_VBE_LFB | BOOT_LOADER_FLAG_MODE13',
            '_exact(fields, "biosboot", "OK")',
            '_hex(fields, "biosflags")',
            '_hex_tuple(fields, "biosentry", 2, "/")',
            '_hex_tuple(fields, "biosspan", 3, "/")',
            "validate_firmware_boot_handoff(fields)",
        ):
            self.assertIn(source, checker)

    def test_kernel_paging_keeps_kernel_supervisor_and_user_windows_explicit(self):
        kernel = text(ROOT / "kernel" / "kernel.asm")

        for source in (
            "PTE_KERNEL_FLAGS equ PTE_PRESENT | PTE_WRITE",
            "PTE_USER_READ_FLAGS equ PTE_PRESENT | PTE_USER",
            "PTE_USER_WRITE_FLAGS equ PTE_PRESENT | PTE_WRITE | PTE_USER",
            "PAGING_TABLE_COUNT equ 8",
            "PAGING_MAPPED_BYTES equ PAGING_TABLE_COUNT * 0x00400000",
            "USER_FAULT_ADDR equ 0x00010000",
        ):
            self.assertIn(source, kernel)

        paging_before_processes = kernel.split("paging_init:", 1)[1].split("call process_vm_init_page_spaces", 1)[0]
        self.assertIn("or ebx, PTE_KERNEL_FLAGS", paging_before_processes)
        self.assertIn("PAGING_TABLES_ADDR | PTE_KERNEL_FLAGS", paging_before_processes)
        self.assertNotIn("PTE_USER", paging_before_processes)

        process_vm = kernel.split("process_vm_init_page_spaces:", 1)[1].split("vmm_mark_process_user_range:", 1)[0]
        self.assertIn("PROC_PROBE_PAGE_DIR_ADDR + (3 * 4)", process_vm)
        for pde in range(4, 8):
            self.assertIn(f"PROC_DOOM_PAGE_DIR_ADDR + ({pde} * 4)", process_vm)
        self.assertNotIn("PROC_PROBE_PAGE_DIR_ADDR + (0 * 4)", process_vm)
        self.assertNotIn("PROC_DOOM_PAGE_DIR_ADDR + (0 * 4)", process_vm)
        self.assertIn("mov eax, USER_CODE_ADDR - PAGE_SIZE", process_vm)
        self.assertIn("call vmm_clear_process_guard_page", process_vm)
        self.assertIn("mov eax, USER_STACK_BOTTOM", process_vm)
        self.assertIn("mov eax, USER_HEAP_END", process_vm)
        self.assertIn("mov eax, DOOM_USER_BASE - PAGE_SIZE", process_vm)
        self.assertIn("mov eax, DOOM_USER_STACK_BOTTOM", process_vm)
        self.assertIn("mov eax, DOOM_USER_STACK_TOP", process_vm)

        user_page_marker = kernel.split("vmm_mark_process_user_page:", 1)[1].split("vmm_clear_process_page:", 1)[0]
        self.assertIn("or edx, PTE_USER_WRITE_FLAGS", user_page_marker)
        self.assertIn("or ebx, ecx", user_page_marker)
        self.assertNotIn("or ebx, PTE_USER_FLAGS", user_page_marker)

        find_pte = kernel.split("vmm_find_process_pte:", 1)[1].split("vmm_clear_process_guard_page:", 1)[0]
        self.assertIn("jz .fail", find_pte)
        self.assertIn("stc", find_pte)
        self.assertNotIn(".done:\n    clc", find_pte)

        pmm_init = kernel.split("pmm_init:", 1)[1].split("pmm_reserve_pages:", 1)[0]
        for source in ("mov eax, HEAP_START", "mov eax, USER_CODE_ADDR", "mov eax, DOOM_USER_BASE"):
            self.assertIn(source, pmm_init)
        self.assertGreaterEqual(pmm_init.count("call pmm_reserve_pages"), 3)

        heap_init = kernel.split("heap_init:", 1)[1].split("kalloc:", 1)[0]
        self.assertIn("mov eax, [pmm_managed_end]", heap_init)
        self.assertIn("cmp eax, HEAP_START + HEAP_SIZE", heap_init)
        self.assertNotIn("BOOT_INFO_ADDR + 4", heap_init)

        pointer_validator = kernel.split("user_range_validate:", 1)[1].split("doom_log_char:", 1)[0]
        self.assertIn("call process_heap_range_is_mapped", pointer_validator)
        self.assertIn("call user_range_pages_present", pointer_validator)
        self.assertIn("user_range_pages_present:", pointer_validator)
        self.assertIn("call vmm_find_process_pte", pointer_validator)
        self.assertIn("test edx, PTE_PRESENT", pointer_validator)
        self.assertIn("test edx, PTE_USER", pointer_validator)

        for source in (
            "KERNEL_HIGHER_HALF_BASE equ 0xc0000000",
            "KERNEL_HIGHER_HALF_PDE_INDEX equ KERNEL_HIGHER_HALF_BASE >> 22",
            "VMM_HIGH_TEST_VADDR equ KERNEL_HIGHER_HALF_BASE",
            "KERNEL_RELOCATION_STATUS_LOW_IDENTITY equ 1",
            "KERNEL_RELOCATION_LIVE_STATUS_OK equ 1",
            "KERNEL_RELOCATION_LIVE_MAGIC equ 0x4b524c56",
            "KERNEL_HIGH_ALIAS_STATUS_OK equ 1",
            "KERNEL_HIGH_EXEC_STATUS_OK equ 1",
            "KERNEL_HIGH_EXEC_STACK_MAGIC equ 0x48485354",
            "KERNEL_PERSISTENT_ALIAS_STATUS_OK equ 1",
            "KERNEL_PERSISTENT_EXEC_STATUS_OK equ 1",
            "KERNEL_PERSISTENT_EXEC_STACK_MAGIC equ 0x4b504558",
            "KERNEL_PERSISTENT_ALIAS_BYTES equ 0x00020000",
            "KERNEL_PERSISTENT_ALIAS_PAGES equ KERNEL_PERSISTENT_ALIAS_BYTES / PAGE_SIZE",
            "KERNEL_STACK_ALIAS_PAGES equ (KERNEL_STACK_TOP - KERNEL_STACK_LOW) / PAGE_SIZE",
            "KERNEL_PERSISTENT_DIR_MASK equ 0x0000003f",
            "kernel_relocation_probe:",
            "kernel_translate_current_vaddr:",
            "kernel_high_alias_self_test:",
            "kernel_high_exec_self_test:",
            "kernel_high_exec_trampoline:",
            "kernel_persistent_alias_self_test:",
            "kernel_persistent_high_exec_self_test:",
            "kernel_persistent_high_exec_trampoline:",
            "kernel_persistent_map_range:",
            "kernel_persistent_alias_install_process_dirs:",
            "kernel_relocation_live_switch_self_test:",
            "kernel_relocation_live_switch_trampoline:",
            "kernel_relocation_status db 0",
            "kernel_high_alias_status db 0",
            "kernel_high_exec_status db 0",
            "kernel_persistent_alias_status db 0",
            "kernel_relocation_live_status db 0",
            "kernel_relocation_eip dd 0",
            "kernel_relocation_esp dd 0",
            "kernel_relocation_cr3 dd 0",
            "kernel_relocation_virt dd 0",
            "kernel_relocation_phys dd 0",
            "kernel_relocation_live_eip dd 0",
            "kernel_relocation_live_esp dd 0",
            "kernel_relocation_live_cr3 dd 0",
            "kernel_relocation_live_return_cr3 dd 0",
            "kernel_relocation_live_code_vaddr dd 0",
            "kernel_relocation_live_code_phys dd 0",
            "kernel_relocation_live_stack_vaddr dd 0",
            "kernel_relocation_live_stack_phys dd 0",
            "kernel_relocation_live_data_vaddr dd 0",
            "kernel_relocation_live_data_phys dd 0",
            "kernel_relocation_live_code_xlat dd 0",
            "kernel_relocation_live_stack_xlat dd 0",
            "kernel_relocation_live_data_xlat dd 0",
            "kernel_relocation_live_low_xlat dd 0",
            "kernel_relocation_live_magic dd 0",
            "kernel_high_alias_vaddr dd 0",
            "kernel_high_alias_phys dd 0",
            "kernel_high_alias_table dd 0",
            "kernel_high_alias_reclaimed dd 0",
            "kernel_high_alias_low_word dd 0",
            "kernel_high_alias_high_word dd 0",
            "kernel_high_exec_eip dd 0",
            "kernel_high_exec_esp dd 0",
            "kernel_high_exec_cr3 dd 0",
            "kernel_high_exec_vaddr dd 0",
            "kernel_high_exec_phys dd 0",
            "kernel_high_exec_stack_vaddr dd 0",
            "kernel_high_exec_stack_phys dd 0",
            "kernel_high_exec_table dd 0",
            "kernel_high_exec_reclaimed dd 0",
            "kernel_high_exec_xlat dd 0",
            "kernel_high_exec_stack_xlat dd 0",
            "kernel_high_exec_stack_probe_vaddr dd 0",
            "kernel_high_exec_stack_probe_phys dd 0",
            "kernel_high_exec_stack_probe_word dd 0",
            "kernel_high_exec_return_eip dd 0",
            "kernel_persistent_alias_vaddr dd 0",
            "kernel_persistent_alias_phys dd 0",
            "kernel_persistent_alias_pages dd 0",
            "kernel_persistent_alias_table dd 0",
            "kernel_persistent_alias_cr3 dd 0",
            "kernel_persistent_alias_dir_mask dd 0",
            "kernel_persistent_alias_xlat dd 0",
            "kernel_persistent_alias_last_xlat dd 0",
            "kernel_persistent_alias_low_word dd 0",
            "kernel_persistent_alias_high_word dd 0",
            "kernel_persistent_stack_vaddr dd 0",
            "kernel_persistent_stack_phys dd 0",
            "kernel_persistent_stack_pages dd 0",
            "kernel_persistent_stack_xlat dd 0",
            "kernel_persistent_exec_status db 0",
            "kernel_persistent_exec_eip dd 0",
            "kernel_persistent_exec_esp dd 0",
            "kernel_persistent_exec_cr3 dd 0",
            "kernel_persistent_exec_vaddr dd 0",
            "kernel_persistent_exec_phys dd 0",
            "kernel_persistent_exec_stack_vaddr dd 0",
            "kernel_persistent_exec_stack_phys dd 0",
            "kernel_persistent_exec_xlat dd 0",
            "kernel_persistent_exec_stack_xlat dd 0",
            "kernel_persistent_exec_stack_probe_vaddr dd 0",
            "kernel_persistent_exec_stack_probe_phys dd 0",
            "kernel_persistent_exec_stack_probe_word dd 0",
            "kernel_persistent_exec_return_eip dd 0",
            'smoke_kreloc_text db " kreloc=", 0',
            'smoke_krelocstep_text db " krelocstep=", 0',
            'smoke_kerneip_text db " kerneip=", 0',
            'smoke_kernesp_text db " kernesp=", 0',
            'smoke_kerncr3_text db " kerncr3=", 0',
            'smoke_kernvirt_text db " kernvirt=", 0',
            'smoke_kernphys_text db " kernphys=", 0',
            'smoke_krelive_text db " krelive=", 0',
            'smoke_krelivex_text db " krelivex=", 0',
            'smoke_krelivep_text db " krelivep=", 0',
            'smoke_kmap_text db " kmap=", 0',
            'smoke_kmapva_text db " kmapva=", 0',
            'smoke_kmappa_text db " kmappa=", 0',
            'smoke_kmappt_text db " kmappt=", 0',
            'smoke_kmapfree_text db " kmapfree=", 0',
            'smoke_kmaplo_text db " kmaplo=", 0',
            'smoke_kmaphi_text db " kmaphi=", 0',
            'smoke_khiexec_text db " khiexec=", 0',
            'smoke_khieip_text db " khieip=", 0',
            'smoke_khiesp_text db " khiesp=", 0',
            'smoke_khicr3_text db " khicr3=", 0',
            'smoke_khiva_text db " khiva=", 0',
            'smoke_khipa_text db " khipa=", 0',
            'smoke_khistk_text db " khistk=", 0',
            'smoke_khistkpa_text db " khistkpa=", 0',
            'smoke_khipt_text db " khipt=", 0',
            'smoke_khifree_text db " khifree=", 0',
            'smoke_khixlat_text db " khixlat=", 0',
            'smoke_khisxlat_text db " khisxlat=", 0',
            'smoke_khislot_text db " khislot=", 0',
            'smoke_khislotpa_text db " khislotpa=", 0',
            'smoke_khisword_text db " khisword=", 0',
            'smoke_khiret_text db " khiret=", 0',
            'smoke_kpmap_text db " kpmap=", 0',
            'smoke_kpva_text db " kpva=", 0',
            'smoke_kppa_text db " kppa=", 0',
            'smoke_kppages_text db " kppages=", 0',
            'smoke_kppt_text db " kppt=", 0',
            'smoke_kpcr3_text db " kpcr3=", 0',
            'smoke_kpdirs_text db " kpdirs=", 0',
            'smoke_kpxlat_text db " kpxlat=", 0',
            'smoke_kplast_text db " kplast=", 0',
            'smoke_kplo_text db " kplo=", 0',
            'smoke_kphi_text db " kphi=", 0',
            'smoke_kpsva_text db " kpsva=", 0',
            'smoke_kpspa_text db " kpspa=", 0',
            'smoke_kpspages_text db " kpspages=", 0',
            'smoke_kpsxlat_text db " kpsxlat=", 0',
            'smoke_kpexec_text db " kpexec=", 0',
            'smoke_kpeip_text db " kpeip=", 0',
            'smoke_kpesp_text db " kpesp=", 0',
            'smoke_kpecr3_text db " kpecr3=", 0',
            'smoke_kpeva_text db " kpeva=", 0',
            'smoke_kpepa_text db " kpepa=", 0',
            'smoke_kpestk_text db " kpestk=", 0',
            'smoke_kpestkpa_text db " kpestkpa=", 0',
            'smoke_kpexlat_text db " kpexlat=", 0',
            'smoke_kpesxlat_text db " kpesxlat=", 0',
            'smoke_kpeslot_text db " kpeslot=", 0',
            'smoke_kpeslotpa_text db " kpeslotpa=", 0',
            'smoke_kpesword_text db " kpesword=", 0',
            'smoke_kperet_text db " kperet=", 0',
            "vmm_dynamic_page_tables dd 0",
            "vmm_active_page_tables dd 0",
            "vmm_reclaimed_page_tables dd 0",
            "vmm_last_reclaimed_page_table dd 0",
            "vmm_high_test_phys dd 0",
            "vmm_high_test_table dd 0",
            "vmm_high_test_reclaimed dd 0",
            "vmm_high_mapping_status db 0",
        ):
            self.assertIn(source, kernel)

        vmm_map = kernel.split("vmm_map_page:", 1)[1].split("vmm_unmap_page:", 1)[0]
        self.assertIn("call pmm_alloc_page", vmm_map)
        self.assertIn("inc dword [vmm_dynamic_page_tables]", vmm_map)
        self.assertIn("inc dword [vmm_active_page_tables]", vmm_map)
        self.assertIn("and ebx, PTE_USER", vmm_map)
        self.assertNotIn("cmp edx, PAGING_TOTAL_PAGES", vmm_map)

        vmm_unmap = kernel.split("vmm_unmap_page:", 1)[1].split("vmm_identity_page:", 1)[0]
        for source in (
            "mov [vmm_map_pde_ptr], edi",
            "mov [vmm_map_table_addr], edx",
            ".scan_table:",
            "cmp eax, PMM_MANAGED_START",
            "cmp eax, PMM_MANAGED_END",
            "mov dword [edi], 0",
            "mov [vmm_last_reclaimed_page_table], eax",
            "call pmm_free_page",
            "dec dword [vmm_active_page_tables]",
            "inc dword [vmm_reclaimed_page_tables]",
        ):
            self.assertIn(source, vmm_unmap)

        vmm_self_test = kernel.split("vmm_self_test:", 1)[1].split("heap_init:", 1)[0]
        self.assertIn("mov eax, VMM_HIGH_TEST_VADDR", vmm_self_test)
        self.assertIn("cmp eax, ebx", vmm_self_test)
        self.assertIn("je .high_free_fail", vmm_self_test)
        self.assertIn("mov [vmm_high_test_phys], ebx", vmm_self_test)
        self.assertIn("mov [vmm_high_test_table], eax", vmm_self_test)
        self.assertIn("mov dword [VMM_HIGH_TEST_VADDR], VMM_HIGH_TEST_MAGIC", vmm_self_test)
        self.assertIn("call vmm_unmap_page", vmm_self_test)
        self.assertIn("mov [vmm_high_test_reclaimed], eax", vmm_self_test)
        self.assertIn("cmp eax, [vmm_high_test_table]", vmm_self_test)
        self.assertIn("jne .high_free_fail", vmm_self_test)
        self.assertIn("mov byte [vmm_high_mapping_status], 1", vmm_self_test)

        relocation_probe = kernel.split("kernel_relocation_probe:", 1)[1].split("kernel_translate_current_vaddr:", 1)[0]
        for source in (
            "mov [kernel_relocation_esp], esp",
            "mov [kernel_relocation_cr3], eax",
            "mov [kernel_relocation_eip], eax",
            "mov eax, start",
            "call kernel_translate_current_vaddr",
            "cmp eax, KERNEL_HIGHER_HALF_BASE",
            "cmp eax, PAGING_DIR_ADDR",
            "cmp eax, [kernel_relocation_virt]",
            "mov byte [kernel_relocation_status], KERNEL_RELOCATION_STATUS_LOW_IDENTITY",
        ):
            self.assertIn(source, relocation_probe)

        high_alias_probe = kernel.split("kernel_high_alias_self_test:", 1)[1].split("framebuffer_map_lfb:", 1)[0]
        for source in (
            "add eax, KERNEL_HIGHER_HALF_BASE",
            "mov [kernel_high_alias_vaddr], eax",
            "call kernel_translate_current_vaddr",
            "cmp eax, 0xffffffff",
            "cmp eax, KERNEL_HIGHER_HALF_BASE",
            "mov [kernel_high_alias_phys], eax",
            "call vmm_map_page",
            "mov [kernel_high_alias_table], eax",
            "mov esi, start",
            "mov [kernel_high_alias_low_word], eax",
            "mov [kernel_high_alias_high_word], ebx",
            "mov byte [kernel_high_alias_status], KERNEL_HIGH_ALIAS_STATUS_OK",
            "call vmm_unmap_page",
            "mov [kernel_high_alias_reclaimed], eax",
            "cmp eax, [kernel_high_alias_table]",
        ):
            self.assertIn(source, high_alias_probe)

        high_exec_probe = kernel.split("kernel_high_exec_self_test:", 1)[1].split("kernel_high_exec_trampoline:", 1)[0]
        for source in (
            "mov [kernel_high_exec_saved_low_esp], esp",
            "mov eax, kernel_high_exec_trampoline",
            "add eax, KERNEL_HIGHER_HALF_BASE",
            "mov [kernel_high_exec_vaddr], eax",
            "call kernel_translate_current_vaddr",
            "cmp eax, KERNEL_STACK_LOW",
            "cmp eax, KERNEL_STACK_TOP",
            "mov [kernel_high_exec_stack_phys], eax",
            "mov [kernel_high_exec_stack_vaddr], eax",
            "call vmm_map_page",
            "mov [kernel_high_exec_table], eax",
            "mov [kernel_high_exec_xlat], eax",
            "mov [kernel_high_exec_stack_xlat], eax",
            "mov esp, ebx",
            "call eax",
            "mov esp, [kernel_high_exec_saved_low_esp]",
            "cmp dword [ebx], KERNEL_HIGH_EXEC_STACK_MAGIC",
            "mov [kernel_high_exec_stack_probe_phys], ebx",
            "cmp eax, PAGING_DIR_ADDR",
            "call vmm_unmap_page",
            "mov [kernel_high_exec_reclaimed], eax",
            "cmp eax, [kernel_high_exec_table]",
        ):
            self.assertIn(source, high_exec_probe)

        high_exec_trampoline = kernel.split("kernel_high_exec_trampoline:", 1)[1].split("framebuffer_map_lfb:", 1)[0]
        for source in (
            "call .capture_eip",
            "mov [kernel_high_exec_eip], eax",
            "mov [kernel_high_exec_return_eip], eax",
            "push dword KERNEL_HIGH_EXEC_STACK_MAGIC",
            "mov [kernel_high_exec_stack_probe_vaddr], esp",
            "mov [kernel_high_exec_stack_probe_word], eax",
            "mov [kernel_high_exec_esp], esp",
            "mov [kernel_high_exec_cr3], eax",
            "mov byte [kernel_high_exec_status], KERNEL_HIGH_EXEC_STATUS_OK",
            "ret",
        ):
            self.assertIn(source, high_exec_trampoline)

        persistent_alias_probe = kernel.split("kernel_persistent_alias_self_test:", 1)[1].split("framebuffer_map_lfb:", 1)[0]
        for source in (
            "mov byte [kernel_persistent_alias_status], KERNEL_PERSISTENT_ALIAS_STATUS_FAIL",
            "mov dword [kernel_persistent_alias_pages], KERNEL_PERSISTENT_ALIAS_PAGES",
            "mov dword [kernel_persistent_stack_pages], KERNEL_STACK_ALIAS_PAGES",
            "mov [kernel_persistent_alias_cr3], eax",
            "call kernel_persistent_map_range",
            "call kernel_persistent_alias_install_process_dirs",
            "cmp dword [kernel_persistent_alias_dir_mask], KERNEL_PERSISTENT_DIR_MASK",
            "call kernel_translate_current_vaddr",
            "mov [kernel_persistent_alias_xlat], eax",
            "mov [kernel_persistent_alias_last_xlat], eax",
            "mov [kernel_persistent_stack_xlat], eax",
            "mov [kernel_persistent_alias_high_word], eax",
            "call kernel_persistent_high_exec_self_test",
            "cmp byte [kernel_persistent_exec_status], KERNEL_PERSISTENT_EXEC_STATUS_OK",
            "mov byte [kernel_persistent_alias_status], KERNEL_PERSISTENT_ALIAS_STATUS_OK",
            "PROC_PROBE_PAGE_DIR_ADDR + (KERNEL_HIGHER_HALF_PDE_INDEX * 4)",
            "PROC_PREEMPT_PAGE_DIR_ADDR + (KERNEL_HIGHER_HALF_PDE_INDEX * 4)",
            "PROC_DOOM_PAGE_DIR_ADDR + (KERNEL_HIGHER_HALF_PDE_INDEX * 4)",
            "PROC_GENERIC0_PAGE_DIR_ADDR + (KERNEL_HIGHER_HALF_PDE_INDEX * 4)",
            "PROC_GENERIC1_PAGE_DIR_ADDR + (KERNEL_HIGHER_HALF_PDE_INDEX * 4)",
        ):
            self.assertIn(source, persistent_alias_probe)

        persistent_exec_probe = kernel.split("kernel_persistent_high_exec_self_test:", 1)[1].split("kernel_persistent_high_exec_trampoline:", 1)[0]
        for source in (
            "mov [kernel_persistent_exec_saved_low_esp], esp",
            "mov eax, kernel_persistent_high_exec_trampoline",
            "mov [kernel_persistent_exec_phys], eax",
            "mov [kernel_persistent_exec_vaddr], eax",
            "mov [kernel_persistent_exec_stack_phys], eax",
            "mov [kernel_persistent_exec_stack_vaddr], eax",
            "mov [kernel_persistent_exec_xlat], eax",
            "mov [kernel_persistent_exec_stack_xlat], eax",
            "mov esp, ebx",
            "call eax",
            "mov esp, [kernel_persistent_exec_saved_low_esp]",
            "cmp dword [ebx], KERNEL_PERSISTENT_EXEC_STACK_MAGIC",
            "mov [kernel_persistent_exec_stack_probe_phys], ebx",
            "cmp eax, [kernel_persistent_alias_cr3]",
            "cmp eax, start",
        ):
            self.assertIn(source, persistent_exec_probe)

        persistent_exec_trampoline = kernel.split("kernel_persistent_high_exec_trampoline:", 1)[1].split("kernel_persistent_map_range:", 1)[0]
        for source in (
            "call .capture_eip",
            "mov [kernel_persistent_exec_eip], eax",
            "mov [kernel_persistent_exec_return_eip], eax",
            "push dword KERNEL_PERSISTENT_EXEC_STACK_MAGIC",
            "mov [kernel_persistent_exec_stack_probe_vaddr], esp",
            "mov [kernel_persistent_exec_stack_probe_word], eax",
            "mov [kernel_persistent_exec_esp], esp",
            "mov [kernel_persistent_exec_cr3], eax",
            "mov byte [kernel_persistent_exec_status], KERNEL_PERSISTENT_EXEC_STATUS_OK",
            "ret",
        ):
            self.assertIn(source, persistent_exec_trampoline)

        relocation_live_probe = kernel.split("kernel_relocation_live_switch_self_test:", 1)[1].split("kernel_relocation_live_switch_trampoline:", 1)[0]
        for source in (
            "call kernel_relocation_live_clear",
            "mov [kernel_relocation_live_saved_low_esp], esp",
            "cmp byte [kernel_relocation_dir_status], KERNEL_RELOCATION_DIR_STATUS_OK",
            "mov [kernel_relocation_live_code_vaddr], eax",
            "call kernel_translate_dir_vaddr",
            "mov [kernel_relocation_live_code_xlat], eax",
            "mov [kernel_relocation_live_stack_vaddr], eax",
            "mov [kernel_relocation_live_stack_xlat], eax",
            "mov [kernel_relocation_live_data_vaddr], eax",
            "mov [kernel_relocation_live_data_xlat], eax",
            "mov [kernel_relocation_live_low_xlat], eax",
            "cmp eax, 0xffffffff",
            "add ebx, [kernel_relocation_live_stack_vaddr]",
            "add eax, [kernel_relocation_live_code_vaddr]",
            "call eax",
            "cmp dword [kernel_relocation_live_magic], KERNEL_RELOCATION_LIVE_MAGIC",
            "cmp dword [kernel_relocation_live_return_cr3], PAGING_DIR_ADDR",
            "cmp eax, [kernel_relocation_dir_addr]",
        ):
            self.assertIn(source, relocation_live_probe)

        relocation_live_trampoline = kernel.split("kernel_relocation_live_switch_trampoline:", 1)[1].split("kernel_high_alias_self_test:", 1)[0]
        for source in (
            "mov eax, [kernel_relocation_dir_addr]",
            "mov cr3, eax",
            "mov edi, KERNEL_HIGHER_HALF_BASE + kernel_relocation_live_eip",
            "mov edi, KERNEL_HIGHER_HALF_BASE + kernel_relocation_live_esp",
            "mov edi, KERNEL_HIGHER_HALF_BASE + kernel_relocation_live_cr3",
            "mov edi, KERNEL_HIGHER_HALF_BASE + kernel_relocation_live_magic",
            "mov dword [edi], KERNEL_RELOCATION_LIVE_MAGIC",
            "mov edi, KERNEL_HIGHER_HALF_BASE + kernel_relocation_live_status",
            "mov byte [edi], KERNEL_RELOCATION_LIVE_STATUS_OK",
            "mov eax, PAGING_DIR_ADDR",
            "mov [kernel_relocation_live_return_cr3], eax",
            "ret",
        ):
            self.assertIn(source, relocation_live_trampoline)

        vmm_self_test = kernel.split("vmm_self_test:", 1)[1].split("heap_init:", 1)[0]
        self.assertIn("call kernel_high_alias_self_test", vmm_self_test)
        self.assertIn(
            "cmp byte [kernel_high_alias_status], KERNEL_HIGH_ALIAS_STATUS_OK",
            vmm_self_test,
        )
        self.assertIn("call kernel_high_exec_self_test", vmm_self_test)
        self.assertIn(
            "cmp byte [kernel_high_exec_status], KERNEL_HIGH_EXEC_STATUS_OK",
            vmm_self_test,
        )
        self.assertIn("call kernel_persistent_alias_self_test", vmm_self_test)
        self.assertIn(
            "cmp byte [kernel_persistent_alias_status], KERNEL_PERSISTENT_ALIAS_STATUS_OK",
            vmm_self_test,
        )
        self.assertIn("call kernel_relocation_dir_self_test", vmm_self_test)
        self.assertIn("call kernel_relocation_live_switch_self_test", kernel)

    def test_boot_vm_docs_state_current_limits_without_overclaiming(self):
        boot_doc = doc_text("architecture")
        uefi_scaffold = text(ROOT / "boot" / "uefi" / "CONTRACT.txt")
        process_doc = doc_text("architecture")
        readme = text(ROOT / "README.md")
        tests_readme = text(ROOT / "tests" / "strategy.txt")

        for source in (
            "no GRUB",
            "0x00040000",
            "0x00010000",
            "CR0.PE",
            "PT_LOAD",
            "supervisor",
            "identity-mapped",
            "not higher-half",
            "no NX",
            "fixed low-memory",
            "vmmhi=OK",
            "vmmhfree=",
            "preemption as a live-user-workload proof",
            "generated-WAD",
            "without `--require-preempt`",
            "real-WAD smoke and\nsoak workflows",
            "KERNEL_RELOCATION_GAP[current]=high-alias-only",
            "KERNEL_RELOCATION_GAP[current]=persistent-high-alias-window",
            "KERNEL_RELOCATION_GAP[current]=persistent-high-mainline",
            "KERNEL_RELOCATION_GAP[missing]=dedicated-relocation-page-directory",
            "KERNEL_RELOCATION_GAP[current]=bounded-relocation-cr3-switch",
            "`vmmhi=OK` is not a kernel relocation claim",
            "`kreloc=HIGH`",
            "`krelocstep=KPMAIN_HIGH`",
            "`kreloc=OK`",
            "`kerneip=`",
            "`kernesp=`",
            "`kerncr3=`",
            "`kernvirt=`",
            "`kernphys=`",
            "`krelive=OK`",
            "`krelivex=`",
            "`krelivep=`",
            "`kmap=OK`",
            "`kmapva=`",
            "`kmappa=`",
            "`kmappt=`",
            "`kmapfree=`",
            "`kmaplo=`",
            "`kmaphi=`",
            "`khiexec=OK`",
            "`kpexec=OK`",
            "`khieip=`",
            "`khiesp=`",
            "`khicr3=`",
            "`khiva=`",
            "`khipa=`",
            "`khistk=`",
            "`khistkpa=`",
            "`khipt=`",
            "`khifree=`",
            "`khixlat=`",
            "`khisxlat=`",
            "`khislot=`",
            "`khislotpa=`",
            "`khisword=`",
            "`khiret=`",
            "`kpmap=OK`",
            "`kpva=`",
            "`kppa=`",
            "`kppages=`",
            "`kppt=`",
            "`kpcr3=`",
            "`kpdirs=`",
            "`kpxlat=`",
            "`kplast=`",
            "`kplo=`",
            "`kphi=`",
            "`kpsva=`",
            "`kpspa=`",
            "`kpspages=`",
            "`kpsxlat=`",
        ):
            self.assertIn(source, boot_doc)
        self.assertIn("docs/architecture.txt", readme)
        self.assertIn("Boot/loader/VM contract", tests_readme)
        self.assertIn("fixed low-memory page-table pages", process_doc)
        self.assertIn("KERNEL_RELOCATION_GAP[current]=high-alias-only", process_doc)
        self.assertIn("KERNEL_RELOCATION_GAP[current]=persistent-high-alias-window", process_doc)
        self.assertIn("KERNEL_RELOCATION_GAP[current]=persistent-high-mainline", process_doc)
        self.assertIn("KERNEL_RELOCATION_GAP[missing]=dedicated-relocation-page-directory", process_doc)
        self.assertIn("KERNEL_RELOCATION_GAP[current]=bounded-relocation-cr3-switch", process_doc)
        self.assertIn("`vmmhi=OK` is not a kernel relocation claim", process_doc)
        self.assertIn("`kpmap=OK` is not a kernel relocation claim", process_doc)
        self.assertIn("records a single last-mapping object descriptor tagged", process_doc)
        self.assertIn("not a reusable object table or lookup structure yet", process_doc)
        self.assertIn("this remains a brk-backed", process_doc)
        self.assertIn("boot/uefi/CONTRACT.txt", readme)
        self.assertIn("boot/uefi/build_host_artifacts.py", readme)
        self.assertIn("UEFI loader/proof boundary", boot_doc)
        self.assertIn("host-built-uefi-loader-no-kernel-entry-proof", boot_doc)
        self.assertIn("UEFI_BOOT[KERNEL_HANDOFF] status=source-implemented", uefi_scaffold)
        self.assertIn("proof=future-cloud-kernel-entry", uefi_scaffold)
        self.assertIn("UEFI_HOST_ARTIFACT[NO_VM_BOOT]", uefi_scaffold)
        self.assertIn("SUPPORT[UEFI] remains unclaimed", uefi_scaffold)
        self.assertNotIn("UEFI_BOOT[ENTRY] status=implemented", uefi_scaffold)

    def test_uefi_handoff_has_kernel_owned_entry_marker_contract(self):
        loader = text(ROOT / "boot" / "uefi" / "loader.asm")
        kernel = text(ROOT / "kernel" / "kernel.asm")
        makefile = text(ROOT / "Makefile")
        proof_script = text(ROOT / "boot" / "uefi" / "ovmf_cloud_proof.py")

        self.assertEqual(
            equ_value(loader, "KERNEL_MAX_BYTES"),
            make_var_value(makefile, "KERNEL_ELF_MAX_BYTES"),
        )

        for source in (
            "mov edx, UEFI_HANDOFF_MAGIC",
            "mov ebx, BOOT_INFO_ADDR",
            "mov ecx, UEFI32_HANDOFF_BLOCK_ADDR",
            "mov esi, UEFI32_E820_MAP_ADDR",
            "mov eax, [UEFI32_HANDOFF_BLOCK_ADDR + UEFI_HANDOFF_ENTRY32_OFF]",
            "jmp eax",
            "KERNEL_PHYS equ 0x00010000",
            "KERNEL_LOAD_LIMIT equ 0x00040000",
            "ELF32_MAX_PHDRS equ 16",
            "ELF32_PHDR_P_ALIGN equ 28",
            "cmp byte [rsi + ELF32_E_IDENT_VERSION], ELF_VERSION_CURRENT",
            "cmp word [rsi + ELF32_E_EHSIZE], ELF32_HEADER_SIZE",
            "cmp r15d, ELF32_MAX_PHDRS",
            "cmp dword [rbx + ELF32_PHDR_P_ALIGN], PAGE_SIZE",
            "cmp r13d, [rbx + ELF32_PHDR_P_VADDR]",
            "cmp r13d, KERNEL_PHYS",
            "cmp eax, KERNEL_LOAD_LIMIT",
            "mov byte [kernel_entry_covered], 1",
            "cmp byte [kernel_entry_covered], 1",
            "prepare_handoff_material:",
            "validate_uefi_boot_info:",
            "validate_low_handoff_copy:",
            "msg_step_low_handoff_copy",
            "msg_error_low_handoff_copy",
            "cmp byte [abs UEFI32_TRAMPOLINE_ADDR], 0xfa",
            "cmp byte [abs UEFI64_TRANSITION_ADDR], 0xfa",
            "msg_error_boot_info",
            "msg_error_handoff_precondition",
            "UEFI_MEMORY_DESCRIPTOR_MIN_BYTES equ 32",
            "cmp qword [memory_map_descriptor_size], UEFI_MEMORY_DESCRIPTOR_MIN_BYTES",
            "cmp rax, MEMORY_MAP_BUFFER_BYTES",
            "msg_error_memory_map_shape",
        ):
            self.assertIn(source, loader)

        self.assertIn("get_memory_map:\n    push rbp", loader)

        for source in (
            "UEFI_HANDOFF_MAGIC equ 0x444e4855",
            "UEFI32_HANDOFF_BLOCK_ADDR equ 0x00009000",
            "UEFI_DEBUGCON_PORT equ 0x0402",
            "mov [boot_entry_eax], eax",
            "mov [boot_entry_ebx], ebx",
            "mov [boot_entry_ecx], ecx",
            "mov [boot_entry_edx], edx",
            "mov [boot_entry_esi], esi",
            "call uefi_entry_probe",
            "uefi_entry_probe:",
            "cmp dword [boot_entry_edx], UEFI_HANDOFF_MAGIC",
            "cmp dword [boot_entry_ecx], UEFI32_HANDOFF_BLOCK_ADDR",
            "cmp dword [uefi_handoff_entry32], start",
            "cmp dword [uefi_handoff_stack32], KERNEL_STACK_TOP",
            "cmp dword [uefi_handoff_boot_info32], BOOT_INFO_ADDR",
            "cmp dword [uefi_handoff_e820_map32], UEFI32_E820_MAP_ADDR",
            "mov byte [uefi_entry_status], UEFI_ENTRY_STATUS_OK",
            "uefi_debug_write_entry_marker:",
            'uefi_marker_prefix db "VIBEKERN step=uefi-entry status=", 0',
            'smoke_uefi_text db " uefi=", 0',
            'smoke_uefiregs_text db " uefiregs=", 0',
            'smoke_uefifb_text db " uefifb=", 0',
            "boot_entry_eax dd 0",
            "uefi_handoff_loaded_segments dd 0",
            "uefi_bootinfo_e820_count dd 0",
        ):
            self.assertIn(source, kernel)

        for source in (
            "line.startswith(\"VIBEKERN \")",
            "KERNEL_ENTRY_REQUIRED_FIELDS",
            "def _valid_kernel_entry_marker",
            "\"kernel_booted\": parsed_markers[\"kernel_booted\"]",
            "\"kernel_handoff_after_exit_boot_services\": parsed_markers[",
            "\"kernel_entry_status\": parsed_markers[\"kernel_entry_status\"]",
            "\"kernel_entry_evidence\": parsed_markers[\"kernel_entry_evidence\"]",
            "\"kernel_entry_after_exit_boot_services\": parsed_markers[\"kernel_entry_after_exit_boot_services\"]",
            "KERNEL_ENTRY_REQUIRED_FLAG_MASK",
            "\"kernel_debugcon_markers\": parsed_markers[\"kernel_markers\"]",
            "\"proof_target\": \"kernel-entry-debugcon-marker\"",
            "\"kernel_status_evidence_required\": True",
            "UEFI OVMF proof failed: the kernel did not emit its UEFI entry marker after ExitBootServices.",
        ):
            self.assertIn(source, proof_script)

    def test_uefi_ovmf_workflow_is_manual_cloud_scaffold(self):
        workflow = text(ROOT / ".github" / "workflows" / "uefi-ovmf-proof.yml")
        scaffold = text(ROOT / "boot" / "uefi" / "CONTRACT.txt")
        proof_script = text(ROOT / "boot" / "uefi" / "ovmf_cloud_proof.py")

        for source in (
            "workflow_dispatch:",
            "proof_mode:",
            "runs-on: ubuntu-latest",
            "inputs.proof_mode != 'contract'",
            "qemu-system-x86 ovmf",
            "make DOOM_WAD= build/kernel.elf",
            "boot/uefi/ovmf_cloud_proof.py",
            "tools/check_hardware_support_matrix.py",
            "build/uefi-ovmf-proof/**/*.json",
        ):
            self.assertIn(source, workflow)
        for forbidden in (
            "\n  push:",
            "\n  pull_request:",
            "ALLOW_LOCAL_VM=1",
            "esp.img",
            "BOOTX64.EFI",
            "*.img",
            "*.fd",
            "*.log",
        ):
            self.assertNotIn(forbidden, workflow)

        for source in (
            "GITHUB_ACTIONS",
            "RUNNER_OS",
            "platform.system() == \"Darwin\"",
            "support_claim",
            "unclaimed",
            "uefi_boot_rows_moved",
            "local_mac_qemu_required",
            "ExitBootServices",
            "debugcon_markers",
            "exit_boot_services",
            "mode == \"prove\"",
        ):
            self.assertIn(source, proof_script)
        self.assertIn("UEFI_CLOUD_PROOF[WORKFLOW_DISPATCH]", scaffold)
        self.assertIn("contract checks must not require local Mac QEMU", " ".join(scaffold.split()))
        self.assertNotIn("UEFI_BOOT_DEVICE[OVMF_BOOT] status=implemented", scaffold)


if __name__ == "__main__":
    unittest.main()
