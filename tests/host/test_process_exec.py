from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[2]


def read_kernel():
    return (ROOT / "kernel" / "kernel.asm").read_text()


class ProcessExecContractTests(unittest.TestCase):
    def test_boot_doom_routes_through_generic_exec_launcher(self):
        kernel = read_kernel()
        boot_flow = kernel.split("user_probe_finished:", 1)[1].split("doom_user_finished:", 1)[0]
        self.assertIn("call process_boot_launch_doom", boot_flow)
        self.assertNotIn("call doom_user_run", boot_flow)
        launcher = kernel.split("process_boot_launch_doom:", 1)[1].split("user_probe_run:", 1)[0]
        self.assertIn("mov esi, exec_path_doom", launcher)
        self.assertIn("mov edi, process_doom", launcher)
        self.assertIn("call process_exec_path", launcher)
        self.assertIn("call doom_user_run", launcher)

    def test_process_exec_resolves_path_through_table_and_fat(self):
        kernel = read_kernel()
        exec_path = kernel.split("process_exec_path:", 1)[1].split("process_exec_resolve_path:", 1)[0]
        resolver = kernel.split("process_exec_resolve_path:", 1)[1].split("process_exec_prepare_elf_image:", 1)[0]
        self.assertIn("process_exec_table:", kernel)
        self.assertIn('exec_path_doom db "DOOM.ELF", 0', kernel)
        self.assertIn("dd exec_path_doom, doom_elf_name_83, DOOM_ELF_LOAD_ADDR, DOOM_ELF_MAX_BYTES", kernel)
        self.assertIn("call process_exec_resolve_path", exec_path)
        self.assertIn("call fat_find_file", exec_path)
        self.assertIn("call fat_load_file", exec_path)
        self.assertIn("mov esi, [process_exec_load_addr]", exec_path)
        self.assertIn("cmp dword [esi], ELF_MAGIC", exec_path)
        self.assertIn("call kernel_streq", resolver)

    def test_exec_launcher_is_not_a_doom_only_fat_loader(self):
        kernel = read_kernel()
        exec_path = kernel.split("process_exec_path:", 1)[1].split("process_exec_resolve_path:", 1)[0]
        self.assertNotIn("call fat_find_doom_elf", exec_path)
        self.assertNotIn("call fat_load_doom_elf", exec_path)
        self.assertNotIn("mov edi, doom_elf_name_83", exec_path)
        self.assertIn("mov edi, [process_exec_name83]", exec_path)
        self.assertIn("mov edi, [process_exec_load_addr]", exec_path)
        self.assertIn("mov ecx, [process_exec_max_bytes]", exec_path)

    def test_exec_status_is_reported_to_smoke_and_cli_status(self):
        kernel = read_kernel()
        write_smoke = kernel.split("write_smoke_status:", 1)[1].split("smoke_copy_string:", 1)[0]
        self.assertIn('smoke_exec_text db "exec=", 0', kernel)
        self.assertIn('smoke_exec_path_text db " path=", 0', kernel)
        self.assertIn("cmp byte [process_exec_status], 1", write_smoke)
        self.assertIn("mov esi, [process_exec_path_ptr]", write_smoke)
        self.assertIn('process_exec_prefix db "Process exec: ", 0', kernel)
        self.assertIn('process_exec_path_prefix db "Exec path: ", 0', kernel)
        self.assertIn("process_exec_status db 0", kernel)

    def test_sys_exec_abi_constant_is_reserved(self):
        kernel = read_kernel()
        header = (ROOT / "doom_port" / "include" / "vibe_os.h").read_text()
        handler = kernel.split("syscall_handler:", 1)[1].split("user_range_validate:", 1)[0]
        self.assertIn("SYS_EXEC equ 16", kernel)
        self.assertIn("cmp eax, SYS_EXEC", handler)
        self.assertIn(".exec:", handler)
        self.assertIn("VIBE_SYS_EXEC = 16", header)
