import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
BUILD = ROOT / "build"
SECTOR_SIZE = 512


def read(path):
    return path.read_bytes()


def text(path):
    return path.read_text()


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
        self.assertEqual(kernel_lba, py_const_value(image_builder, "KERNEL_LBA"))
        self.assertEqual(kernel_sectors, py_const_value(image_builder, "KERNEL_SECTORS"))
        self.assertEqual(kernel_lba, stage2_lba + stage2_sectors)
        self.assertLessEqual(kernel_lba + kernel_sectors, partition_start)
        self.assertEqual(make_var_value(makefile, "STAGE2_MAX_BYTES"), stage2_sectors * SECTOR_SIZE)
        self.assertEqual(make_var_value(makefile, "KERNEL_ELF_MAX_BYTES"), kernel_sectors * SECTOR_SIZE)
        self.assertIn(f"LBA {stage2_lba}-{stage2_lba + stage2_sectors - 1}: Stage 2 bootloader", readme)
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
            self.assertIn("mov ah, 0x42", source)
            self.assertIn("int 0x13", source)

        for source in (
            "enable_a20:",
            "in al, 0x92",
            "or al, 0x02",
            "lgdt [gdt_descriptor]",
            "or eax, 0x00000001",
            "mov cr0, eax",
            "jmp CODE_SEG:protected_entry",
            "bits 32",
            "protected_entry:",
            "mov esp, 0x70000",
            "call elf_load_kernel",
            "jmp eax",
        ):
            self.assertIn(source, stage2)

        elf_loader = stage2.split("elf_load_kernel:", 1)[1].split("elf_fail:", 1)[0]
        for source in (
            "cmp dword [esi], ELF_MAGIC",
            "cmp byte [esi + 4], ELFCLASS32",
            "cmp byte [esi + 5], ELFDATA2LSB",
            "cmp word [esi + 16], ET_EXEC",
            "cmp word [esi + 18], EM_386",
            "cmp word [esi + 42], 32",
            "cmp dword [ebx], PT_LOAD",
            "cmp eax, edx",
            "jb elf_fail",
            "rep movsb",
            "rep stosb",
            "test ebp, ebp",
            "mov eax, [KERNEL_ELF_PHYS + 24]",
        ):
            self.assertIn(source, elf_loader)

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
        self.assertIn("mov eax, USER_HEAP_END", process_vm)

        user_page_marker = kernel.split("vmm_mark_process_user_page:", 1)[1].split("vmm_clear_process_page:", 1)[0]
        self.assertIn("or edx, PTE_USER_WRITE_FLAGS", user_page_marker)
        self.assertIn("or ebx, ecx", user_page_marker)
        self.assertNotIn("or ebx, PTE_USER_FLAGS", user_page_marker)

        pmm_init = kernel.split("pmm_init:", 1)[1].split("pmm_reserve_pages:", 1)[0]
        for source in ("mov eax, HEAP_START", "mov eax, USER_CODE_ADDR", "mov eax, DOOM_USER_BASE"):
            self.assertIn(source, pmm_init)
        self.assertGreaterEqual(pmm_init.count("call pmm_reserve_pages"), 3)

        for source in (
            "KERNEL_HIGHER_HALF_BASE equ 0xc0000000",
            "KERNEL_HIGHER_HALF_PDE_INDEX equ KERNEL_HIGHER_HALF_BASE >> 22",
            "VMM_HIGH_TEST_VADDR equ KERNEL_HIGHER_HALF_BASE",
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

    def test_boot_vm_docs_state_current_limits_without_overclaiming(self):
        boot_doc = text(ROOT / "docs" / "boot-loader-vm.md")
        uefi_scaffold = text(ROOT / "boot" / "uefi" / "README.md")
        process_doc = text(ROOT / "docs" / "process-vm.md")
        readme = text(ROOT / "README.md")
        tests_readme = text(ROOT / "tests" / "README.md")

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
        ):
            self.assertIn(source, boot_doc)
        self.assertIn("docs/boot-loader-vm.md", readme)
        self.assertIn("Boot/loader/VM contract", tests_readme)
        self.assertIn("fixed low-memory page-table pages", process_doc)
        self.assertIn("records a single last-mapping object descriptor tagged", process_doc)
        self.assertIn("not a reusable object table or lookup structure yet", process_doc)
        self.assertIn("this remains a brk-backed", process_doc)
        self.assertIn("boot/uefi/README.md", readme)
        self.assertIn("contract-only UEFI scaffold", boot_doc)
        self.assertIn("status=unimplemented", uefi_scaffold)
        self.assertIn("SUPPORT[UEFI] remains unclaimed", uefi_scaffold)
        self.assertNotIn("UEFI_BOOT[ENTRY] status=implemented", uefi_scaffold)


if __name__ == "__main__":
    unittest.main()
