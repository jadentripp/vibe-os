from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[2]


def read_kernel():
    return (ROOT / "kernel" / "kernel.asm").read_text()


class ProcessExecContractTests(unittest.TestCase):
    def test_boot_doom_routes_through_userland_sys_exec(self):
        kernel = read_kernel()
        probe = (ROOT / "user" / "probe.c").read_text()
        boot_flow = kernel.split("user_probe_finished:", 1)[1].split("doom_user_finished:", 1)[0]
        boot_entry = kernel.split(".c_runtime_done:", 1)[1].split("user_probe_finished:", 1)[0]
        self.assertIn("call write_smoke_status", boot_entry)
        self.assertIn("call process_boot_launch_doom", boot_flow)
        self.assertNotIn("call doom_user_run", boot_flow)
        launcher = kernel.split("process_boot_launch_doom:", 1)[1].split("user_probe_run:", 1)[0]
        self.assertIn("cmp dword [sys_exec_successes], 0", launcher)
        self.assertIn("mov byte [doom_run_status], 4", launcher)
        self.assertNotIn("call doom_user_run", launcher)
        self.assertIn("SYS_EXEC = 16", probe)
        self.assertIn("trigger_expected_fault();", probe)
        self.assertIn("char *abi_probe_argv[] = {(char *)abi_probe_path, (char *)0};", probe)
        self.assertIn("return sys_execv(abi_probe_path, abi_probe_argv) == 0 ? 0 : 1;", probe)
        self.assertNotIn("return sys_execv(doom_path, doom_argv) == 0 ? 0 : 1;", probe)

    def test_initial_user_probe_gets_real_arg_stack_before_crt0(self):
        kernel = read_kernel()
        probe = (ROOT / "user" / "probe.c").read_text()
        user_probe_run = kernel.split("user_probe_run:", 1)[1].split(".fail:", 1)[0]
        for source in (
            "mov esi, exec_path_user_probe",
            "xor edi, edi",
            "call process_exec_path",
            "mov byte [boot_user_exec_status], 1",
            "call sys_exec_stage_kernel_arg",
            "call process_seed_initial_user_context",
            "call process_activate",
            "call process_exec_seed_argv_stack",
            "push dword [process_user_probe + PROC_SAVED_ESP]",
            "xor eax, eax",
            "xor ebp, ebp",
        ):
            self.assertIn(source, user_probe_run)
        self.assertLess(
            user_probe_run.index("call process_exec_path"),
            user_probe_run.index("call sys_exec_stage_kernel_arg"),
        )
        self.assertLess(
            user_probe_run.index("call sys_exec_stage_kernel_arg"),
            user_probe_run.index("call process_exec_seed_argv_stack"),
        )
        self.assertLess(
            user_probe_run.index("call process_seed_initial_user_context"),
            user_probe_run.index("call process_activate", user_probe_run.index("call sys_exec_stage_kernel_arg")),
        )
        self.assertLess(
            user_probe_run.index("call process_exec_seed_argv_stack"),
            user_probe_run.index("push dword [process_user_probe + PROC_SAVED_ESP]"),
        )
        self.assertNotIn("mov edi, USER_HEAP_START", user_probe_run)
        self.assertNotIn("(USER_HEAP_END - USER_HEAP_START) / 4", user_probe_run)
        for source in (
            "USER_PROBE_EXPECTED_FLAGS equ 0x0003ffff",
            "PROBE_FLAG_PROCESS_ABI = 0x800u",
            "PROBE_FLAG_NEGATIVE_SYSCALLS = 0x1000u",
            "PROBE_FLAG_WAIT_REAP = 0x2000u",
            "PROBE_FLAG_FTRUNCATE = 0x4000u",
            "PROBE_FLAG_SBRK_SHRINK = 0x8000u",
            "PROBE_FLAG_LISTDIR = 0x10000u",
            "PROBE_FLAG_DUP = 0x20000u",
            "PROBE_FLAG_DUP = 0x20000u",
            "SYS_GETPID = 25",
            "SYS_LISTDIR = 30",
            "int user_main(int argc, char **argv, char **envp)",
            'probe_streq(argv[0], "USERPROB.ELF")',
            "argv[1] == (char *)0",
            "envp[0] == (char *)0",
            "int pid = syscall3(SYS_GETPID, 0, 0, 0);",
            "pid > 0",
        ):
            self.assertIn(source, kernel if source.startswith("USER_PROBE_EXPECTED") else probe)

    def test_process_exec_resolves_table_paths_and_generic_fat16_elves(self):
        kernel = read_kernel()
        exec_path = kernel.split("process_exec_path:", 1)[1].split("process_exec_resolve_path:", 1)[0]
        resolver = kernel.split("process_exec_resolve_path:", 1)[1].split("process_exec_prepare_elf_image:", 1)[0]
        generic = kernel.split("process_exec_resolve_generic_root83:", 1)[1].split("process_exec_prepare_elf_image:", 1)[0]
        self.assertIn("process_exec_table:", kernel)
        self.assertIn("PROCESS_EXEC_TABLE_COUNT equ 2", kernel)
        self.assertIn("PROCESS_EXEC_ENTRY_BYTES equ 20", kernel)
        self.assertIn("PROCESS_EXEC_TARGET equ 16", kernel)
        self.assertIn('exec_path_doom db "DOOM.ELF", 0', kernel)
        self.assertIn('exec_path_user_probe db "USERPROB.ELF", 0', kernel)
        self.assertIn("dd exec_path_doom, doom_elf_name_83, DOOM_ELF_LOAD_ADDR, DOOM_ELF_MAX_BYTES, process_doom", kernel)
        self.assertIn("dd exec_path_user_probe, user_elf_name_83, USER_ELF_LOAD_ADDR, USER_ELF_MAX_BYTES, process_user_probe", kernel)
        self.assertIn("call process_exec_resolve_path", exec_path)
        self.assertIn("call fat_find_file", exec_path)
        self.assertIn("call fat_load_file", exec_path)
        self.assertIn("mov esi, [process_exec_load_addr]", exec_path)
        self.assertIn("cmp dword [esi], ELF_MAGIC", exec_path)
        self.assertIn("call process_exec_resolve_generic_root83", resolver)
        self.assertIn("call kernel_streq", resolver)
        self.assertIn("mov eax, [ebx + PROCESS_EXEC_TARGET]", resolver)
        self.assertIn("mov [process_exec_target], eax", resolver)
        for source in (
            "process_exec_name83_buffer times 11 db 0",
            "mov edi, process_exec_name83_buffer",
            "mov ecx, SYS_EXEC_PATH_MAX - 1",
            ".skip_prefix:",
            ".skip_dot_prefix:",
            "cmp al, '/'",
            "cmp al, 0x5c",
            "cmp al, '.'",
            "add esi, 2",
            "sub al, 32",
            "cmp byte [process_exec_name83_buffer + 8], 'E'",
            "cmp byte [process_exec_name83_buffer + 9], 'L'",
            "cmp byte [process_exec_name83_buffer + 10], 'F'",
            "mov dword [process_exec_name83], process_exec_name83_buffer",
            "mov dword [process_exec_load_addr], USER_ELF_LOAD_ADDR",
            "mov dword [process_exec_max_bytes], USER_ELF_MAX_BYTES",
            "call process_alloc_generic_exec_slot",
            "mov [process_exec_target], esi",
        ):
            self.assertIn(source, kernel if source.startswith("process_exec_name83_buffer") else generic)

    def test_exec_launcher_is_not_a_doom_only_fat_loader(self):
        kernel = read_kernel()
        exec_path = kernel.split("process_exec_path:", 1)[1].split("process_exec_resolve_path:", 1)[0]
        resolver = kernel.split("process_exec_resolve_path:", 1)[1].split("process_exec_prepare_elf_image:", 1)[0]
        self.assertNotIn("call fat_find_doom_elf", exec_path)
        self.assertNotIn("call fat_load_doom_elf", exec_path)
        self.assertNotIn("mov edi, doom_elf_name_83", exec_path)
        self.assertIn("mov edi, [process_exec_name83]", exec_path)
        self.assertIn("mov edi, [process_exec_load_addr]", exec_path)
        self.assertIn("mov ecx, [process_exec_max_bytes]", exec_path)
        self.assertIn(".try_generic_root83:", resolver)
        self.assertIn("call process_exec_resolve_generic_root83", resolver)

    def test_storage_boot_no_longer_preloads_user_or_doom_with_special_loaders(self):
        kernel = read_kernel()
        storage = kernel.split("storage_init:", 1)[1].split("ata_io_delay:", 1)[0]
        user_probe_run = kernel.split("user_probe_run:", 1)[1].split(".fail:", 1)[0]
        self.assertNotIn("fat_find_user_elf:", kernel)
        self.assertNotIn("fat_load_user_elf:", kernel)
        self.assertNotIn("fat_find_doom_elf:", kernel)
        self.assertNotIn("fat_load_doom_elf:", kernel)
        self.assertNotIn("doom_user_run:", kernel)
        self.assertNotIn("call user_elf_prepare", user_probe_run)
        self.assertNotIn("call doom_elf_prepare", storage)
        self.assertIn("call process_exec_path", user_probe_run)
        self.assertIn("call fat_find_file", kernel.split("process_exec_path:", 1)[1].split("process_exec_resolve_path:", 1)[0])

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
        self.assertIn("sys_exec_handoffs dd 0", kernel)
        self.assertIn("sys_exec_scheduled dd 0", kernel)
        self.assertIn("sys_exec_rollbacks dd 0", kernel)
        self.assertIn('smoke_execerr_text db " execerr=", 0', kernel)
        self.assertIn('smoke_execres_text db " execres=", 0', kernel)
        self.assertIn('smoke_exec_target_text db " target=", 0', kernel)
        self.assertIn('smoke_exec_ppid_text db " ppid=", 0', kernel)
        self.assertIn('smoke_exec_entry_text db " entry=", 0', kernel)
        self.assertIn('smoke_exec_stack_text db " stack=", 0', kernel)
        self.assertIn('smoke_exec_argc_text db " argc=", 0', kernel)
        self.assertIn('smoke_exec_argv_ptr_text db " argv=", 0', kernel)
        self.assertIn('smoke_exec_envp_ptr_text db " envp=", 0', kernel)
        self.assertIn('smoke_exec_argv_text db " argv0=", 0', kernel)
        self.assertIn('smoke_exec_envp0_text db " envp0=", 0', kernel)
        self.assertIn('smoke_exec_argvsrc_text db " argvsrc=", 0', kernel)
        self.assertIn('smoke_userexec_text db " uexec=", 0', kernel)
        self.assertIn('smoke_userexec_path_text db " upath=", 0', kernel)
        self.assertIn('smoke_userexec_pid_text db " upid=", 0', kernel)
        self.assertIn('smoke_userexec_entry_text db " uentry=", 0', kernel)
        self.assertIn('smoke_abiexec_text db " abiexec=", 0', kernel)
        self.assertIn('smoke_abiexec_path_text db " abipath=", 0', kernel)
        self.assertIn('smoke_abiprobe_text db " abiprobe=", 0', kernel)
        self.assertIn('smoke_abiflags_text db " abiflags=", 0', kernel)
        self.assertIn('smoke_procpool_text db " procpool=", 0', kernel)
        self.assertIn('smoke_pidseq_text db " pidseq=", 0', kernel)
        self.assertIn('smoke_fdexec_text db " fdexec=", 0', kernel)
        self.assertIn('smoke_fddup_text db " fdup=", 0', kernel)
        self.assertIn('smoke_pwait_text db " wait=", 0', kernel)
        self.assertIn('smoke_vmreap_text db " vmreap=", 0', kernel)
        self.assertIn("mov edx, [sys_exec_handoffs]", write_smoke)
        self.assertIn("mov edx, [sys_exec_scheduled]", write_smoke)
        self.assertIn("mov edx, [sys_exec_rollbacks]", write_smoke)
        self.assertIn("mov edx, [process_exec_last_error]", write_smoke)
        self.assertIn("mov edx, [sys_exec_last_result]", write_smoke)
        self.assertIn("mov edx, [sys_exec_last_target_pid]", write_smoke)
        self.assertIn("mov edx, [sys_exec_last_parent_pid]", write_smoke)
        self.assertIn("mov edx, [sys_exec_last_target_entry]", write_smoke)
        self.assertIn("mov edx, [sys_exec_last_target_stack]", write_smoke)
        self.assertIn("mov edx, [sys_exec_last_argc]", write_smoke)
        self.assertIn("mov edx, [sys_exec_last_argv]", write_smoke)
        self.assertIn("mov edx, [sys_exec_last_envp]", write_smoke)
        self.assertIn("mov edx, [sys_exec_last_argv_source]", write_smoke)
        self.assertIn("mov edx, [sys_exec_last_envp0]", write_smoke)
        self.assertIn("cmp byte [boot_user_exec_status], 1", write_smoke)
        self.assertIn("mov esi, exec_path_user_probe", write_smoke)
        self.assertIn("mov edx, [boot_user_exec_pid]", write_smoke)
        self.assertIn("mov edx, [boot_user_exec_entry]", write_smoke)
        self.assertIn("cmp byte [abi_probe_exec_status], 1", write_smoke)
        self.assertIn("cmp byte [abi_probe_status], 1", write_smoke)
        self.assertIn("mov esi, exec_path_abi_probe", write_smoke)
        self.assertIn("mov edx, [abi_probe_exec_pid]", write_smoke)
        self.assertIn("mov edx, [abi_probe_exec_parent_pid]", write_smoke)
        self.assertIn("mov edx, [abi_probe_exec_entry]", write_smoke)
        self.assertIn("mov edx, [abi_probe_exec_argc]", write_smoke)
        self.assertIn("mov edx, [abi_probe_exec_argv_source]", write_smoke)
        self.assertIn("mov edx, [abi_probe_flags_seen]", write_smoke)
        for source in (
            "mov edx, PROCESS_SLOT_COUNT",
            "mov edx, PROCESS_GENERIC_SLOT_COUNT",
            "mov edx, [process_slot_reuses]",
            "mov edx, [process_generic_slot_allocations]",
            "mov edx, [process_generic_slot_failures]",
            "mov edx, [process_next_pid]",
            "mov edx, [process_last_reused_pid]",
            "mov edx, [process_last_slot_generation]",
            "mov edx, [fd_exec_handoffs]",
            "mov edx, [fd_exec_inherited]",
            "mov edx, [fd_exec_closed]",
            "mov edx, [fd_owner_closes]",
            "mov edx, [fd_dup_calls]",
            "mov edx, [fd_dup2_calls]",
            "mov edx, [fd_dup3_calls]",
            "mov edx, [fd_dup_shared]",
            "mov edx, [fd_dup_cloexec]",
            "mov edx, [process_wait_attempts]",
            "mov edx, [process_wait_reaps]",
            "mov edx, [process_wait_failures]",
            "mov edx, [process_wait_nohang_returns]",
            "mov edx, [process_wait_seeded_children]",
            "mov edx, [process_wait_last_reaped_pid]",
            "mov edx, [process_wait_last_status]",
            "mov edx, [process_vm_teardowns]",
            "mov edx, [process_vm_pages_cleared]",
            "mov edx, [process_wait_vm_reaps]",
            "mov edx, [process_wait_vm_pages_reclaimed]",
            "mov edx, [process_wait_last_vm_pages_reclaimed]",
        ):
            self.assertIn(source, write_smoke)

    def test_sys_exec_dispatch_validates_prepares_and_hands_off_exec(self):
        kernel = read_kernel()
        header = (ROOT / "doom_port" / "include" / "vibe_os.h").read_text()
        handler = kernel.split("syscall_handler:", 1)[1].split("user_range_validate:", 1)[0]
        self.assertIn("SYS_EXEC equ 16", kernel)
        self.assertIn("cmp eax, SYS_EXEC", handler)
        self.assertIn(".exec:", handler)
        self.assertIn("mov [sys_exec_frame_ptr], esp", handler)
        self.assertIn("inc dword [sys_exec_attempts]", handler)
        self.assertIn("call sys_exec_copy_user_path", handler)
        self.assertIn("mov esi, sys_exec_path_buffer", handler)
        self.assertIn("xor edi, edi", handler)
        self.assertNotIn("mov edi, process_doom", handler)
        self.assertNotIn("cmp byte [current_user_kind], USER_KIND_DOOM", handler.split(".exec:", 1)[1].split(".exec_einval:", 1)[0])
        self.assertIn("call process_exec_path", handler)
        self.assertIn("call process_exec_handoff_current", handler)
        self.assertIn("inc dword [sys_exec_successes]", handler)
        self.assertIn("jmp .exec_handoff_return", handler)
        self.assertIn("VIBE_SYS_EXEC = 16", header)

    def test_preempt_probe_cannot_clobber_boot_user_probe_status(self):
        kernel = read_kernel()
        user_probe_handler = kernel.split(".user_probe:", 1)[1].split(".expect_fault:", 1)[0]

        self.assertIn("cmp byte [current_user_kind], USER_KIND_PREEMPT_PROBE", user_probe_handler)
        self.assertIn("je .user_probe_skip", user_probe_handler)
        self.assertLess(
            user_probe_handler.index("je .user_probe_skip"),
            user_probe_handler.index("mov [user_probe_magic_seen], ebx"),
        )
        self.assertIn(".user_probe_skip:", user_probe_handler)
        skip_path = user_probe_handler.split(".user_probe_skip:", 1)[1]
        self.assertIn("xor eax, eax", skip_path)
        self.assertIn("jmp .return", skip_path)

    def test_user_probe_exercises_classified_negative_syscall_contracts(self):
        kernel = read_kernel()
        probe = (ROOT / "user" / "probe.c").read_text()
        for source in (
            "PROBE_FLAG_NEGATIVE_SYSCALLS = 0x1000u",
            "PROBE_FLAG_WAIT_REAP = 0x2000u",
            "PROBE_FLAG_FTRUNCATE = 0x4000u",
            "PROBE_FLAG_SBRK_SHRINK = 0x8000u",
            "PROBE_FLAG_LISTDIR = 0x10000u",
            "ERRNO_EINVAL = 22",
            "WAIT_OPTION_WNOHANG = 0x1u",
            "WAIT_PROOF_EXIT_STATUS = 0x2a",
            "WAIT_PROOF_CHILD_PID = 3",
            "static int sys_waitpid(uint32_t pid, int *status, uint32_t options)",
            "int wait_status = 0;",
            "sys_waitpid((uint32_t)-1, &wait_status, WAIT_OPTION_WNOHANG) == WAIT_PROOF_CHILD_PID",
            "wait_status == WAIT_PROOF_EXIT_STATUS",
            "sys_waitpid((uint32_t)-1, 0, WAIT_OPTION_WNOHANG) == -ERRNO_ECHILD",
            "flags |= PROBE_FLAG_WAIT_REAP;",
            "syscall3(0x7fffffffu, 0, 0, 0) == -ERRNO_ENOSYS",
            "syscall3(SYS_MMAP, 0, 0, mmap_flags) == -ERRNO_EINVAL",
            "syscall3(SYS_MMAP, 0, 4096, mmap_fixed_flags) == -ERRNO_EINVAL",
            "syscall3(SYS_MUNMAP, 0, 4096, 0) == -ERRNO_EINVAL",
            "syscall3(SYS_WAITPID, (uint32_t)-1, USER_FAULT_ADDR, 0) == -ERRNO_EINVAL",
            "flags |= PROBE_FLAG_NEGATIVE_SYSCALLS;",
            "flags |= PROBE_FLAG_LISTDIR;",
            "flags |= PROBE_FLAG_DUP;",
        ):
            self.assertIn(source, probe)
        handler = kernel.split("syscall_handler:", 1)[1].split(".user_probe:", 1)[0]
        self.assertIn("jmp .bad_syscall_enosys", handler)

    def test_live_doom_user_status_accepts_ready_or_running_scheduler_state(self):
        kernel = read_kernel()
        write_smoke = kernel.split("write_smoke_status:", 1)[1].split("smoke_copy_string:", 1)[0]
        draw_status = kernel.split("draw_heap_status:", 1)[1].split(".wad_status:", 1)[0]

        for status_path in (write_smoke, draw_status):
            with self.subTest(status_path=status_path[:24]):
                self.assertIn("cmp byte [doom_run_status], 1", status_path)
                self.assertIn("je .user_check_live_doom", status_path)
                self.assertIn("cmp byte [doom_run_status], 2", status_path)
                self.assertIn("je .user_ok_from_doom", status_path)
                self.assertIn(".user_check_live_doom:", status_path)
                self.assertIn("mov eax, [process_doom + PROC_STATE]", status_path)
                self.assertIn("cmp eax, PROC_STATE_READY", status_path)
                self.assertIn("je .user_ok_from_doom", status_path)
                self.assertIn("cmp eax, PROC_STATE_RUNNING", status_path)
                self.assertIn("jne .user_fail_text", status_path)

    def test_sys_exec_resets_diagnostics_and_accepts_bounded_argv(self):
        kernel = read_kernel()
        handler = kernel.split(".exec:", 1)[1].split(".exec_path_failed:", 1)[0]
        for source in (
            "mov dword [process_exec_path_ptr], 0",
            "mov dword [process_exec_target], 0",
            "mov dword [process_exec_entry], 0",
            "mov dword [process_exec_last_error], 0",
            "mov dword [sys_exec_last_parent_pid], 0xffffffff",
            "mov dword [sys_exec_last_target_pid], 0xffffffff",
            "mov dword [sys_exec_last_target_entry], 0",
            "mov dword [sys_exec_last_target_stack], 0",
            "mov dword [sys_exec_last_argc], 0",
            "mov dword [sys_exec_last_argv], 0",
            "mov dword [sys_exec_last_envp], 0",
            "mov dword [sys_exec_last_argv0], 0",
            "mov dword [sys_exec_last_envp0], 0",
            "mov dword [sys_exec_last_argv_source], 0",
            "cmp dword [sys_exec_flags_arg], 0",
            "jne .exec_einval",
            "call sys_exec_copy_argv",
            "jc .exec_einval",
        ):
            self.assertIn(source, handler)
        exec_einval = kernel.split(".exec_einval:", 1)[1].split(".exec_path_failed:", 1)[0]
        self.assertIn("mov dword [process_exec_last_error], -ERRNO_EINVAL", exec_einval)

    def test_exec_handoff_does_not_save_a_return_context_for_the_old_process(self):
        kernel = read_kernel()
        handler = kernel.split(".exec:", 1)[1].split(".bad_syscall:", 1)[0]
        handoff_return = kernel.split(".exec_handoff_return:", 1)[1].split(".bad_syscall:", 1)[0]
        self.assertIn("call process_exec_handoff_current", handler)
        self.assertIn("jmp .exec_handoff_return", handler)
        self.assertNotIn("jmp .return", handler.split("inc dword [sys_exec_successes]", 1)[1].split(".exec_einval:", 1)[0])
        self.assertNotIn("call process_save_syscall_return_context", handoff_return)
        self.assertIn("iretd", handoff_return)

    def test_exec_prepare_supports_user_probe_as_second_target(self):
        kernel = read_kernel()
        exec_path = kernel.split("process_exec_path:", 1)[1].split("process_exec_resolve_path:", 1)[0]
        prepare = kernel.split("process_exec_prepare_elf_image:", 1)[1].split("kernel_streq:", 1)[0]
        self.assertIn("call process_is_user_exec_target", exec_path)
        self.assertIn("mov [user_elf_first_cluster], ax", exec_path)
        self.assertIn("mov [user_elf_size], eax", exec_path)
        self.assertIn("mov [user_elf_sectors_read], eax", exec_path)
        self.assertIn("mov byte [user_elf_status], 1", exec_path)
        self.assertIn("call process_is_user_exec_target", prepare)
        self.assertIn("call user_elf_prepare", prepare)
        self.assertIn("mov eax, [user_entry_addr]", prepare)

    def test_generic_root_exec_uses_bounded_dynamic_process_pool(self):
        kernel = read_kernel()
        generic = kernel.split("process_exec_resolve_generic_root83:", 1)[1].split("process_exec_prepare_elf_image:", 1)[0]
        allocator = kernel.split("process_alloc_generic_exec_slot:", 1)[1].split("process_retire_exec_slot:", 1)[0]
        page_spaces = kernel.split("process_vm_init_page_spaces:", 1)[1].split("vmm_mark_process_user_range:", 1)[0]
        for source in (
            "PROCESS_SLOT_COUNT equ 6",
            "PROCESS_GENERIC_SLOT_COUNT equ 2",
            "USER_KIND_GENERIC equ 4",
            "PROC_GENERIC0_PAGE_DIR_ADDR equ 0x00089000",
            "PROC_GENERIC1_PAGE_DIR_ADDR equ 0x0008b000",
            "process_generic0:",
            "process_generic1:",
            "process_generic_exec_slots:",
            "process_generic_slot_allocations dd 0",
            "process_generic_slot_failures dd 0",
            "process_last_generic_slot dd 0",
        ):
            self.assertIn(source, kernel)
        self.assertIn("call process_alloc_generic_exec_slot", generic)
        self.assertIn("mov [process_exec_target], esi", generic)
        for source in (
            "mov edi, process_generic_exec_slots",
            "mov ecx, PROCESS_GENERIC_SLOT_COUNT",
            "cmp dword [esi + PROC_STATE], PROC_STATE_UNUSED",
            "cmp dword [esi + PROC_PARENT_PID], 0xffffffff",
            "cmp dword [esi + PROC_STATE], PROC_STATE_EXITED",
            "cmp dword [esi + PROC_STATE], PROC_STATE_FAULTED",
            "mov [process_last_generic_slot], esi",
            "inc dword [process_generic_slot_allocations]",
            "inc dword [process_generic_slot_failures]",
            "mov dword [process_exec_last_error], -ERRNO_ENOMEM",
        ):
            self.assertIn(source, allocator)
        for source in (
            "mov edi, PROC_GENERIC0_PAGE_DIR_ADDR",
            "mov edi, PROC_GENERIC1_PAGE_DIR_ADDR",
            "PROC_GENERIC0_PDE3_TABLE_ADDR | PTE_USER_FLAGS",
            "PROC_GENERIC1_PDE3_TABLE_ADDR | PTE_USER_FLAGS",
        ):
            self.assertIn(source, page_spaces)

    def test_generic_exec_targets_share_userland_argv_envp_and_fd_handoff(self):
        kernel = read_kernel()
        generic = kernel.split("process_exec_resolve_generic_root83:", 1)[1].split("process_exec_prepare_elf_image:", 1)[0]
        user_targets = kernel.split("process_is_user_exec_target:", 1)[1].split("process_alloc_generic_exec_slot:", 1)[0]
        prepare = kernel.split("process_exec_prepare_elf_image:", 1)[1].split("process_exec_handoff_current:", 1)[0]
        handoff = kernel.split("process_exec_handoff_current:", 1)[1].split("process_exec_seed_argv_stack:", 1)[0]
        argv = kernel.split("process_exec_seed_argv_stack:", 1)[1].split("process_exec_patch_syscall_frame:", 1)[0]

        self.assertIn("call process_alloc_generic_exec_slot", generic)
        self.assertIn("mov dword [process_exec_load_addr], USER_ELF_LOAD_ADDR", generic)
        self.assertIn("mov [process_exec_target], esi", generic)
        self.assertNotIn("process_doom", generic)
        for source in (
            "cmp eax, process_user_probe",
            "cmp eax, process_generic0",
            "cmp eax, process_generic1",
        ):
            self.assertIn(source, user_targets)
        for source in (
            "call process_is_user_exec_target",
            "call user_elf_prepare",
            "mov eax, [user_entry_addr]",
        ):
            self.assertIn(source, prepare)
        self.assertIn("call fd_exec_handoff", handoff)
        self.assertIn("call process_reset_user_exec_target", handoff)
        self.assertLess(
            handoff.index("call fd_exec_handoff"),
            handoff.index("call process_seed_initial_user_context"),
        )
        for source in (
            "mov eax, [edx + PROC_STACK_TOP]",
            "cmp eax, [edx + PROC_STACK_BOTTOM]",
            "mov [edx + PROC_ARGC], eax",
            "mov [edx + PROC_ARGV], eax",
            "mov [edx + PROC_ENVP], eax",
            "mov [edx + PROC_ARGV0], eax",
            "mov [edx + PROC_SAVED_ESP], eax",
            "mov dword [ebx + ecx * 4], 0",
            "mov dword [ebx + ecx * 4 + 4], 0",
        ):
            self.assertIn(source, argv)
        self.assertNotIn("DOOM_USER_STACK", argv)
        self.assertNotIn("process_doom", argv)

    def test_user_probe_chains_through_abi_probe_before_doom(self):
        kernel = read_kernel()
        probe = (ROOT / "user" / "probe.c").read_text()
        abi_probe = (ROOT / "user" / "abi_probe.c").read_text()
        handler = kernel.split(".user_probe:", 1)[1].split(".expect_fault:", 1)[0]
        recorder = kernel.split("process_record_abi_exec_success:", 1)[1].split("kernel_streq:", 1)[0]

        for source in (
            'const char abi_probe_path[] = "ABIPROBE.ELF";',
            "char *abi_probe_argv[] = {(char *)abi_probe_path, (char *)0};",
            "return sys_execv(abi_probe_path, abi_probe_argv) == 0 ? 0 : 1;",
        ):
            self.assertIn(source, probe)
        for source in (
            '#include "runtime.h"',
            "ABI_PROBE_MAGIC = 0xA81B10BEu",
            "ABI_PROBE_SUCCESS_FLAGS",
            'const char doom_path[] = "DOOM.ELF";',
            "vibe_user_report_probe(ABI_PROBE_MAGIC, flags);",
            "vibe_user_execv(doom_path, doom_argv)",
        ):
            self.assertIn(source, abi_probe)
        for source in (
            "ABI_PROBE_MAGIC equ 0xA81B10BE",
            "ABI_PROBE_EXPECTED_FLAGS equ 0x00000007",
            "exec_path_abi_probe db \"ABIPROBE.ELF\", 0",
            "abi_probe_status db 0",
            "abi_probe_exec_status db 0",
        ):
            self.assertIn(source, kernel)
        self.assertIn("cmp ebx, ABI_PROBE_MAGIC", handler)
        self.assertIn("mov [abi_probe_magic_seen], ebx", handler)
        self.assertIn("mov [abi_probe_flags_seen], ecx", handler)
        self.assertIn("cmp ecx, ABI_PROBE_EXPECTED_FLAGS", handler)
        self.assertIn("mov byte [abi_probe_status], 1", handler)
        self.assertIn("mov edi, exec_path_abi_probe", recorder)
        self.assertIn("mov byte [abi_probe_exec_status], 1", recorder)
        self.assertIn("mov [abi_probe_exec_pid], eax", recorder)
        self.assertIn("mov [abi_probe_exec_parent_pid], eax", recorder)
        self.assertIn("mov [abi_probe_exec_argv_source], eax", recorder)

    def test_sys_exec_copies_a_bounded_user_path_and_reports_status(self):
        kernel = read_kernel()
        copy_path = kernel.split("sys_exec_copy_user_path:", 1)[1].split("user_range_validate:", 1)[0]
        write_smoke = kernel.split("write_smoke_status:", 1)[1].split("smoke_copy_string:", 1)[0]
        self.assertIn("SYS_EXEC_PATH_MAX equ 16", kernel)
        self.assertIn("call user_range_validate", copy_path)
        self.assertIn("mov edi, sys_exec_path_buffer", copy_path)
        self.assertIn("mov ecx, SYS_EXEC_PATH_MAX", copy_path)
        self.assertIn("rep stosb", copy_path)
        self.assertIn("mov al, [esi + ecx]", copy_path)
        self.assertIn("mov [edi + ecx], al", copy_path)
        self.assertIn("cmp ecx, SYS_EXEC_PATH_MAX - 1", copy_path)
        self.assertIn("sys_exec_path_buffer times SYS_EXEC_PATH_MAX db 0", kernel)
        self.assertIn("sys_exec_attempts dd 0", kernel)
        self.assertIn("sys_exec_successes dd 0", kernel)
        self.assertIn("sys_exec_failures dd 0", kernel)
        self.assertIn('smoke_execsys_text db " execsys=", 0', kernel)
        self.assertIn("mov edx, [sys_exec_attempts]", write_smoke)

    def test_exec_active_target_is_rejected_before_destructive_load(self):
        kernel = read_kernel()
        exec_path = kernel.split("process_exec_path:", 1)[1].split(".target_safe:", 1)[0]
        handler = kernel.split(".exec:", 1)[1].split(".exec_einval:", 1)[0]
        self.assertIn("process_exec_reject_active_target db 0", kernel)
        self.assertIn("mov byte [process_exec_reject_active_target], 1", handler)
        self.assertIn("cmp byte [process_exec_reject_active_target], 1", exec_path)
        self.assertIn("mov eax, [current_process_ptr]", exec_path)
        self.assertIn("cmp eax, [process_exec_target]", exec_path)
        self.assertIn("mov dword [process_exec_last_error], -ERRNO_EACCES", exec_path)
        self.assertNotIn("call fat_load_file", exec_path)

    def test_exec_handoff_marks_lifecycle_and_activates_target_process(self):
        kernel = read_kernel()
        handoff = kernel.split("process_exec_handoff_current:", 1)[1].split("process_exec_seed_argv_stack:", 1)[0]
        seed = kernel.split("process_seed_initial_user_context:", 1)[1].split("process_activate:", 1)[0]
        for source in (
            "call process_reset_doom",
            "call process_reset_user_exec_target",
            "call process_seed_initial_user_context",
            "call process_activate",
            "call process_exec_seed_argv_stack",
            "call pic_unmask_timer_keyboard",
            "call process_exec_patch_syscall_frame",
            "call process_retire_exec_slot",
            "mov [scheduler_next_process_ptr], esi",
            "inc dword [sys_exec_scheduled]",
            "call process_activate",
            "inc dword [sys_exec_handoffs]",
        ):
            self.assertIn(source, handoff)
        self.assertLess(
            handoff.index("call process_activate"),
            handoff.index("call process_exec_seed_argv_stack"),
        )
        self.assertLess(
            handoff.index("call process_exec_seed_argv_stack"),
            handoff.index("call pic_unmask_timer_keyboard"),
        )
        user_probe_run = kernel.split("user_probe_run:", 1)[1].split(".fail:", 1)[0]
        self.assertIn("push dword 0x00000202", user_probe_run)
        for source in (
            "mov [esi + PROC_SAVED_EIP], eax",
            "mov [esi + PROC_SAVED_ESP], eax",
            "mov dword [esi + PROC_SAVED_EFLAGS], 0x00000202",
            "mov dword [esi + PROC_SAVED_CS], USER_CODE_SEG",
            "mov dword [esi + PROC_SAVED_SS], USER_DATA_SEG",
            "or dword [esi + PROC_VM_FLAGS], PROC_FLAG_IRQ_FRAME_VALID",
        ):
            self.assertIn(source, seed)

    def test_exec_reuses_slots_with_fresh_pid_and_vm_cleanup(self):
        kernel = read_kernel()
        exec_path = kernel.split("process_exec_path:", 1)[1].split("process_exec_resolve_path:", 1)[0]
        reuse = kernel.split("process_reuse_exec_target_slot:", 1)[1].split("process_retire_exec_slot:", 1)[0]
        teardown = kernel.split("process_teardown_user_vm:", 1)[1].split("process_restore_user_stack_vm:", 1)[0]
        retire_exec = kernel.split("process_retire_exec_slot:", 1)[1].split("process_retire_current_exit_slot:", 1)[0]
        retire_exit = kernel.split("process_retire_current_exit_slot:", 1)[1].split("clear_fault_record:", 1)[0]
        mark_exit = kernel.split("process_mark_current_exited:", 1)[1].split("process_mark_current_faulted:", 1)[0]

        for source in (
            "process_next_pid dd 4",
            "process_slot_reuses dd 0",
            "process_vm_teardowns dd 0",
            "process_vm_pages_cleared dd 0",
            "process_wait_vm_reaps dd 0",
            "process_wait_vm_pages_reclaimed dd 0",
            "process_wait_last_vm_pages_reclaimed dd 0",
            "process_wait_vm_pages_before dd 0",
            "process_exit_teardowns dd 0",
            "process_exec_teardowns dd 0",
            "process_last_reused_pid dd 0xffffffff",
            "process_last_slot_generation dd 0",
        ):
            self.assertIn(source, kernel)
        self.assertLess(
            exec_path.index("call process_reuse_exec_target_slot"),
            exec_path.index("call fat_find_file"),
        )
        self.assertIn("call process_retire_exec_slot", exec_path.split(".fail:", 1)[1])
        for source in (
            "call process_teardown_user_vm",
            "call process_restore_user_stack_vm",
            "inc dword [process_slot_reuses]",
            "mov eax, [process_next_pid]",
            "mov [esi + PROC_PID], eax",
            "mov [process_last_reused_pid], eax",
            "mov [process_next_pid], eax",
            "mov dword [esi + PROC_PARENT_PID], 0xffffffff",
            "mov dword [esi + PROC_EXIT_STATUS], 0",
            "mov dword [esi + PROC_EXEC_COUNT], 0",
            "mov dword [esi + PROC_ARGC], 0",
            "mov dword [esi + PROC_ARGV], 0",
            "mov dword [esi + PROC_ENVP], 0",
            "mov dword [esi + PROC_ARGV0], 0",
            "inc dword [esi + PROC_SLOT_GENERATION]",
            "mov dword [esi + PROC_STATE], PROC_STATE_UNUSED",
        ):
            self.assertIn(source, reuse)
        for source in (
            "mov ebx, [esi + PROC_PAGE_DIR]",
            "mov edi, [esi + PROC_VM_REGIONS]",
            "mov ecx, [esi + PROC_VM_REGION_COUNT]",
            "test dword [edi + VM_REGION_FLAGS], VM_REGION_USER",
            "call process_clear_user_range",
            "mov [esi + PROC_BRK], eax",
        ):
            self.assertIn(source, teardown)
        self.assertIn("inc dword [process_exec_teardowns]", retire_exec)
        self.assertIn("mov dword [esi + PROC_STATE], PROC_STATE_EXITED", retire_exec)
        self.assertIn("inc dword [process_exit_teardowns]", retire_exit)
        self.assertIn("call process_retire_current_exit_slot", mark_exit)

    def test_wait_reap_runs_child_vm_teardown_and_restores_preempt_probe_image(self):
        kernel = read_kernel()
        wait = kernel.split("process_waitpid_current:", 1)[1].split("scheduler_prepare_live_preempt_probe:", 1)[0]
        scheduler_prepare = kernel.split("scheduler_prepare_live_preempt_probe:", 1)[1].split("scheduler_capture_preempt_spin:", 1)[0]
        restore_image = kernel.split("process_restore_user_image_vm:", 1)[1].split("process_reuse_exec_target_slot:", 1)[0]
        clear_page = kernel.split("vmm_clear_process_page:", 1)[1].split("vmm_clear_process_guard_page:", 1)[0]
        clear_range = kernel.split("process_clear_user_range:", 1)[1].split("process_teardown_user_vm:", 1)[0]

        for source in (
            "call fd_close_owned_by_process",
            "mov eax, [process_vm_pages_cleared]",
            "mov [process_wait_vm_pages_before], eax",
            "call process_teardown_user_vm",
            "sub eax, [process_wait_vm_pages_before]",
            "mov [process_wait_last_vm_pages_reclaimed], eax",
            "add [process_wait_vm_pages_reclaimed], eax",
            "inc dword [process_wait_vm_reaps]",
            "mov dword [esi + PROC_STATE], PROC_STATE_UNUSED",
        ):
            self.assertIn(source, wait)
        self.assertIn("call process_restore_user_image_vm", scheduler_prepare)
        self.assertIn("call process_restore_user_stack_vm", scheduler_prepare)
        self.assertLess(
            scheduler_prepare.index("call process_restore_user_image_vm"),
            scheduler_prepare.index("call process_restore_user_stack_vm"),
        )
        for source in (
            "mov eax, [esi + PROC_BASE]",
            "mov edx, [esi + PROC_HEAP_START]",
            "call vmm_mark_process_user_range",
        ):
            self.assertIn(source, restore_image)
        self.assertIn("test dword [edi], PTE_PRESENT", clear_page)
        self.assertIn("stc", clear_page)
        self.assertIn("jc .clear_heap_metadata", clear_range)
        self.assertLess(clear_range.index("call vmm_clear_process_page"), clear_range.index("inc dword [process_vm_pages_cleared]"))

    def test_late_exec_handoff_failure_restores_caller_before_rollback(self):
        kernel = read_kernel()
        process_doc = (ROOT / "docs" / "process-exec.md").read_text()
        gap_doc = (ROOT / "docs" / "post-checkpoint-gaps.md").read_text()
        handoff = kernel.split("process_exec_handoff_current:", 1)[1].split("process_exec_seed_argv_stack:", 1)[0]
        late_rollback = handoff.split(".eio_after_activate:", 1)[1].split(".eio:", 1)[0]

        self.assertIn("call process_activate", handoff)
        self.assertIn("call process_exec_seed_argv_stack", handoff)
        self.assertIn("jc .eio_after_activate", handoff)
        self.assertIn("call process_exec_patch_syscall_frame", handoff)
        self.assertIn("push esi", late_rollback)
        self.assertIn("mov esi, edi", late_rollback)
        self.assertIn("call process_activate", late_rollback)
        self.assertIn("pop esi", late_rollback)
        self.assertIn("call process_retire_exec_slot", late_rollback)
        self.assertIn("jmp .eio", late_rollback)
        self.assertLess(
            handoff.index("call process_activate"),
            handoff.index("call process_exec_seed_argv_stack"),
        )
        self.assertLess(
            handoff.index("call process_exec_seed_argv_stack"),
            handoff.index(".eio_after_activate:"),
        )
        self.assertIn("switches the caller back to RUNNING", process_doc)
        self.assertIn("retires the half-prepared target slot", process_doc)
        self.assertIn("rollback counter no longer leaves a half-prepared target running", gap_doc)

    def test_exec_patches_live_syscall_frame_for_target_iret(self):
        kernel = read_kernel()
        patch = kernel.split("process_exec_patch_syscall_frame:", 1)[1].split("kernel_streq:", 1)[0]
        for source in (
            "SYSCALL_FRAME_EIP equ 24",
            "SYSCALL_FRAME_CS equ 28",
            "SYSCALL_FRAME_EFLAGS equ 32",
            "SYSCALL_FRAME_ESP equ 36",
            "SYSCALL_FRAME_SS equ 40",
            "mov ebx, [sys_exec_frame_ptr]",
            "mov [ebx + SYSCALL_FRAME_EIP], eax",
            "mov [ebx + SYSCALL_FRAME_CS], eax",
            "mov [ebx + SYSCALL_FRAME_EFLAGS], eax",
            "mov [ebx + SYSCALL_FRAME_ESP], eax",
            "mov [ebx + SYSCALL_FRAME_SS], eax",
        ):
            self.assertIn(source, kernel if source.startswith("SYSCALL_") else patch)

    def test_exec_seeds_argc_argv_stack_from_copied_path(self):
        kernel = read_kernel()
        argv = kernel.split("process_exec_seed_argv_stack:", 1)[1].split("process_exec_patch_syscall_frame:", 1)[0]
        for source in (
            "SYS_EXEC_ARGC_DEFAULT equ 1",
            "SYS_EXEC_ARGV_SLOT_BYTES equ 12",
            "SYS_EXEC_ARG_MAX equ 8",
            "SYS_EXEC_ARG_STR_MAX equ 64",
            "SYS_EXEC_ARG_FRAME_BASE_BYTES equ 12",
            "SYS_EXEC_ARGV_SOURCE_DEFAULT equ 1",
            "SYS_EXEC_ARGV_SOURCE_USER equ 2",
            "sys_exec_last_argc dd 0",
            "sys_exec_last_argv dd 0",
            "sys_exec_last_argv0 dd 0",
            "sys_exec_last_argv_source dd 0",
            "sys_exec_arg_target_ptrs times SYS_EXEC_ARG_MAX dd 0",
            "sys_exec_arg_strings times SYS_EXEC_ARG_MAX * SYS_EXEC_ARG_STR_MAX db 0",
        ):
            self.assertIn(source, kernel)
        for source in (
            "cmp dword [sys_exec_argc], 0",
            "cmp dword [sys_exec_argc], SYS_EXEC_ARG_MAX",
            "sub eax, SYS_EXEC_ARG_STR_MAX",
            "cmp eax, [edx + PROC_STACK_BOTTOM]",
            "mov esi, sys_exec_arg_strings",
            "mov ecx, SYS_EXEC_ARG_STR_MAX",
            "mov [sys_exec_arg_target_ptrs + ecx * 4], eax",
            "add ebx, SYS_EXEC_ARG_FRAME_BASE_BYTES",
            "mov [edi], ecx",
            "mov [ebx + esi * 4], eax",
            "mov dword [ebx + ecx * 4], 0",
            "mov dword [ebx + ecx * 4 + 4], 0",
            "lea eax, [ebx + ecx * 4 + 4]",
            "mov [edx + PROC_SAVED_ESP], eax",
        ):
            self.assertIn(source, argv)
        copy_argv = kernel.split("sys_exec_copy_argv:", 1)[1].split("sys_exec_copy_user_arg_string:", 1)[0]
        stage_kernel_arg = kernel.split("sys_exec_stage_kernel_arg:", 1)[1].split("sys_exec_copy_argv:", 1)[0]
        for source in (
            "call sys_exec_clear_args",
            "cmp dword [sys_exec_user_argv_arg], 0",
            "jne .copy_user_argv",
            "mov dword [sys_exec_argc], SYS_EXEC_ARGC_DEFAULT",
            "cmp ecx, SYS_EXEC_ARG_MAX",
            "call user_range_validate",
            "call sys_exec_copy_user_arg_string",
            "mov [sys_exec_argc], eax",
            "mov dword [sys_exec_last_argv_source], SYS_EXEC_ARGV_SOURCE_DEFAULT",
            "mov dword [sys_exec_last_argv_source], SYS_EXEC_ARGV_SOURCE_USER",
        ):
            self.assertIn(source, copy_argv)
        for source in (
            "call sys_exec_clear_args",
            "mov edi, sys_exec_arg_strings",
            "mov ecx, SYS_EXEC_ARG_STR_MAX",
            "lodsb",
            "stosb",
            "mov byte [sys_exec_arg_strings + SYS_EXEC_ARG_STR_MAX - 1], 0",
            "mov dword [sys_exec_argc], SYS_EXEC_ARGC_DEFAULT",
            "mov dword [sys_exec_last_argv_source], SYS_EXEC_ARGV_SOURCE_DEFAULT",
        ):
            self.assertIn(source, stage_kernel_arg)

    def test_public_exec_abi_exposes_generic_bounds_and_empty_envp_contract(self):
        kernel = read_kernel()
        header = (ROOT / "doom_port" / "include" / "vibe_os.h").read_text()
        libc = (ROOT / "doom_port" / "libc.c").read_text()
        process_doc = (ROOT / "docs" / "process-exec.md").read_text()
        vm_doc = (ROOT / "docs" / "process-vm.md").read_text()

        for kernel_source, header_source in (
            ("SYS_EXEC_PATH_MAX equ 16", "VIBE_EXEC_PATH_MAX = 16"),
            ("SYS_EXEC_ARG_MAX equ 8", "VIBE_EXEC_ARG_MAX = 8"),
            ("SYS_EXEC_ARG_STR_MAX equ 64", "VIBE_EXEC_ARG_STR_MAX = 64"),
            ("SYS_EXEC_ARGV_SOURCE_DEFAULT equ 1", "VIBE_EXEC_ARGV_SOURCE_DEFAULT = 1"),
            ("SYS_EXEC_ARGV_SOURCE_USER equ 2", "VIBE_EXEC_ARGV_SOURCE_USER = 2"),
        ):
            self.assertIn(kernel_source, kernel)
            self.assertIn(header_source, header)
        for source in (
            "execve accepts NULL or empty envp only",
            "root-level FAT16 .ELF names use reusable",
            "O_CLOEXEC",
            "VIBE_EXEC_* exposes the current path and argv bounds",
        ):
            self.assertIn(source, header)
        for source in (
            "if (envp && envp[0])",
            "errno = ENOSYS",
            "return execv(path, argv);",
        ):
            self.assertIn(source, libc)
        for source in (
            "The same handoff contract applies to table-backed programs and generic",
            "`VIBE_EXEC_ARG_MAX` argv strings",
            "`VIBE_EXEC_ARG_STR_MAX`",
            "an empty `envp` vector",
            "not opened with",
            "`O_CLOEXEC`",
            "That is the reusable contract for post-Doom games and tools.",
        ):
            self.assertIn(source, process_doc)
        for source in (
            "Once selected, they use the same process\nhandoff machinery as table-backed Doom",
            "kernel-seeded empty `envp`",
            "`O_CLOEXEC` close-on-exec cleanup",
            "future root-level game or tool ELFs",
        ):
            self.assertIn(source, vm_doc)

    def test_process_records_capture_exec_parent_and_user_abi_metadata(self):
        kernel = read_kernel()
        reset = kernel.split("process_reset_accounting:", 1)[1].split("clear_fault_record:", 1)[0]
        handoff = kernel.split("process_exec_handoff_current:", 1)[1].split("process_exec_seed_argv_stack:", 1)[0]
        argv = kernel.split("process_exec_seed_argv_stack:", 1)[1].split("process_exec_patch_syscall_frame:", 1)[0]
        user_probe_run = kernel.split("user_probe_run:", 1)[1].split(".fail:", 1)[0]
        for source in (
            "PROCESS_RECORD_BYTES equ 168",
            "PROC_PARENT_PID equ 128",
            "PROC_EXIT_STATUS equ 132",
            "PROC_EXEC_COUNT equ 136",
            "PROC_ARGC equ 140",
            "PROC_ARGV equ 144",
            "PROC_ENVP equ 148",
            "PROC_ARGV0 equ 152",
            "PROC_SLOT_GENERATION equ 156",
            "sys_exec_last_parent_pid dd 0xffffffff",
            "sys_exec_last_envp dd 0",
            "sys_exec_last_envp0 dd 0",
        ):
            self.assertIn(source, kernel)
        for source in (
            "mov dword [esi + PROC_PARENT_PID], 0xffffffff",
            "mov dword [esi + PROC_EXIT_STATUS], 0",
            "mov dword [esi + PROC_EXEC_COUNT], 0",
            "mov dword [esi + PROC_ARGC], 0",
            "mov dword [esi + PROC_ARGV], 0",
            "mov dword [esi + PROC_ENVP], 0",
            "mov dword [esi + PROC_ARGV0], 0",
        ):
            self.assertIn(source, reset)
        for source in (
            "mov eax, [edi + PROC_PID]",
            "mov [esi + PROC_PARENT_PID], eax",
            "mov eax, [esi + PROC_PARENT_PID]",
            "mov [sys_exec_last_parent_pid], eax",
            "inc dword [esi + PROC_EXEC_COUNT]",
        ):
            self.assertIn(source, handoff)
        for source in (
            "mov [edx + PROC_ARGC], eax",
            "mov [edx + PROC_ARGV], eax",
            "mov [sys_exec_last_envp], eax",
            "mov [edx + PROC_ENVP], eax",
            "mov [sys_exec_last_envp0], eax",
            "mov [edx + PROC_ARGV0], eax",
        ):
            self.assertIn(source, argv)
        self.assertIn("mov dword [process_user_probe + PROC_PARENT_PID], 0", user_probe_run)
        self.assertIn("inc dword [process_user_probe + PROC_EXEC_COUNT]", user_probe_run)

    def test_waitpid_scans_children_and_reaps_exited_records(self):
        kernel = read_kernel()
        waitpid = kernel.split("process_waitpid_current:", 1)[1].split("scheduler_prepare_live_preempt_probe:", 1)[0]
        seed = kernel.split("process_seed_wait_reap_probe_child:", 1)[1].split("process_reset_doom:", 1)[0]
        user_probe_run = kernel.split("user_probe_run:", 1)[1].split(".fail:", 1)[0]
        handler = kernel.split(".waitpid:", 1)[1].split(".getpid:", 1)[0]
        for source in (
            "WAIT_OPTION_WNOHANG equ 0x1",
            "WAIT_SUPPORTED_OPTIONS equ WAIT_OPTION_WNOHANG",
            "WAIT_PROOF_EXIT_STATUS equ 0x0000002a",
            "process_wait_attempts dd 0",
            "process_wait_reaps dd 0",
            "process_wait_failures dd 0",
            "process_wait_last_reaped_pid dd 0xffffffff",
            "process_wait_seen_live_child dd 0",
            "process_wait_nohang_returns dd 0",
            "process_wait_seeded_children dd 0",
            "process_wait_seeded_child_pid dd 0xffffffff",
        ):
            self.assertIn(source, kernel)
        for source in (
            "mov esi, process_preempt_probe",
            "call process_reset_preempt_probe",
            "mov eax, [current_pid]",
            "mov [esi + PROC_PARENT_PID], eax",
            "mov dword [esi + PROC_EXIT_STATUS], WAIT_PROOF_EXIT_STATUS",
            "mov dword [esi + PROC_STATE], PROC_STATE_EXITED",
            "mov [process_wait_seeded_child_pid], eax",
            "inc dword [process_wait_seeded_children]",
        ):
            self.assertIn(source, seed)
        self.assertIn("call process_seed_wait_reap_probe_child", user_probe_run)
        for source in (
            "call process_waitpid_current",
            "jc .bad_syscall_from_eax",
            "jmp .return",
        ):
            self.assertIn(source, handler)
        for source in (
            "inc dword [process_wait_attempts]",
            "mov eax, edx",
            "and eax, 0xfffffffe",
            "jne .einval",
            "cmp ebx, 0xffffffff",
            "cmp ebx, 0",
            "call user_range_validate",
            "mov esi, process_table",
            "mov edi, PROCESS_SLOT_COUNT",
            "cmp esi, process_kernel",
            "cmp esi, eax",
            "cmp eax, [current_pid]",
            "mov eax, [process_wait_last_pid_arg]",
            "cmp eax, PROC_STATE_EXITED",
            "cmp eax, PROC_STATE_FAULTED",
            "mov dword [process_wait_seen_live_child], 1",
            ".live_child:",
            "test dword [process_wait_last_options], WAIT_OPTION_WNOHANG",
            "jnz .nohang",
            ".nohang:",
            "inc dword [process_wait_nohang_returns]",
            "xor eax, eax",
            "mov [process_wait_last_reaped_pid], eax",
            "mov [process_wait_last_status], ebx",
            "mov [ecx], ebx",
            "inc dword [process_wait_reaps]",
            "call fd_close_owned_by_process",
            "mov dword [esi + PROC_STATE], PROC_STATE_UNUSED",
            "mov dword [esi + PROC_PARENT_PID], 0xffffffff",
            "mov eax, -ERRNO_ENOSYS",
            "mov eax, -ERRNO_EINVAL",
            "mov eax, -ERRNO_ECHILD",
        ):
            self.assertIn(source, waitpid)

    def test_faulted_process_exit_status_is_wait_reapable(self):
        kernel = read_kernel()
        faulted = kernel.split("process_mark_current_faulted:", 1)[1].split("process_waitpid_current:", 1)[0]
        waitpid = kernel.split("process_waitpid_current:", 1)[1].split("scheduler_prepare_live_preempt_probe:", 1)[0]

        self.assertIn("PROCESS_FAULT_EXIT_STATUS_BASE equ 0x00000080", kernel)
        for source in (
            "mov eax, [fault_vector]",
            "and eax, 0xff",
            "or eax, PROCESS_FAULT_EXIT_STATUS_BASE",
            "mov [esi + PROC_EXIT_STATUS], eax",
            "mov dword [esi + PROC_STATE], PROC_STATE_FAULTED",
        ):
            self.assertIn(source, faulted)
        self.assertLess(
            faulted.index("mov [esi + PROC_EXIT_STATUS], eax"),
            faulted.index("mov dword [esi + PROC_STATE], PROC_STATE_FAULTED"),
        )
        self.assertIn("cmp eax, PROC_STATE_FAULTED", waitpid)
        self.assertIn("mov ebx, [esi + PROC_EXIT_STATUS]", waitpid)
        self.assertIn("mov [process_wait_last_status], ebx", waitpid)

    def test_timer_irq_rewrites_the_live_interrupt_frame_for_preemption(self):
        kernel = read_kernel()
        irq_timer = kernel.split("irq_timer:", 1)[1].split("irq_keyboard:", 1)[0]
        tick = kernel.split("scheduler_tick:", 1)[1].split("process_save_irq_context:", 1)[0]

        for source in (
            "pushad",
            "inc dword [timer_ticks]",
            "mov ebx, esp",
            "call scheduler_tick",
            "out 0x20, al",
            "popad",
            "iretd",
        ):
            self.assertIn(source, irq_timer)
        self.assertLess(irq_timer.index("mov ebx, esp"), irq_timer.index("call scheduler_tick"))
        self.assertLess(irq_timer.index("call scheduler_tick"), irq_timer.index("out 0x20, al"))
        self.assertLess(irq_timer.index("popad"), irq_timer.index("iretd"))
        for source in (
            "mov eax, [ebx + 36]",
            "test eax, 3",
            "jz .skip_preempt",
            "call process_save_irq_context",
            "call scheduler_select_next_ready",
            "call process_activate",
            "call process_restore_irq_context",
            "inc dword [scheduler_irq_frame_rewrites]",
            "mov eax, [ebx + 32]",
            "mov [scheduler_last_irq_frame_eip], eax",
            "mov eax, [ebx + 36]",
            "mov [scheduler_last_irq_frame_cs], eax",
            "mov eax, [ebx + 44]",
            "mov [scheduler_last_irq_frame_esp], eax",
            "mov eax, [ebx + 48]",
            "mov [scheduler_last_irq_frame_ss], eax",
            "inc dword [scheduler_irq_context_switches]",
        ):
            self.assertIn(source, tick)
        self.assertLess(tick.index("call process_save_irq_context"), tick.index("call scheduler_select_next_ready"))
        self.assertLess(tick.index("call process_activate"), tick.index("call process_restore_irq_context"))
        self.assertLess(tick.index("call process_restore_irq_context"), tick.index("inc dword [scheduler_irq_frame_rewrites]"))

    def test_process_activation_switches_address_space_and_kernel_stack(self):
        kernel = read_kernel()
        activate = kernel.split("process_activate:", 1)[1].split("process_return_to_kernel:", 1)[0]
        tick = kernel.split("scheduler_tick:", 1)[1].split("process_save_irq_context:", 1)[0]

        for source in (
            "mov dword [ebx + PROC_STATE], PROC_STATE_READY",
            "mov [current_process_ptr], esi",
            "mov eax, [esi + PROC_PAGE_DIR]",
            "mov cr3, eax",
            "mov eax, [esi + PROC_KERNEL_STACK_TOP]",
            "mov [tss_esp0], eax",
            "mov word [tss_ss0], DATA_SEG",
            "mov dword [esi + PROC_STATE], PROC_STATE_RUNNING",
            "inc dword [scheduler_context_switches]",
        ):
            self.assertIn(source, activate)
        self.assertLess(activate.index("mov cr3, eax"), activate.index("mov [tss_esp0], eax"))
        self.assertLess(activate.index("mov [tss_esp0], eax"), activate.index("mov dword [esi + PROC_STATE], PROC_STATE_RUNNING"))
        for source in (
            "mov eax, [esi + PROC_PAGE_DIR]",
            "mov [scheduler_last_preempt_from_cr3], eax",
            "mov eax, [esi + PROC_KERNEL_STACK_TOP]",
            "mov [scheduler_last_preempt_from_kstack], eax",
            "mov eax, [esi + PROC_PAGE_DIR]",
            "mov [scheduler_last_preempt_to_cr3], eax",
            "mov eax, [esi + PROC_KERNEL_STACK_TOP]",
            "mov [scheduler_last_preempt_to_kstack], eax",
        ):
            self.assertIn(source, tick)

    def test_scheduler_selects_only_ready_user_irq_frames(self):
        kernel = read_kernel()
        selector = kernel.split("scheduler_select_next_ready:", 1)[1].split("scheduler_preempt_self_test:", 1)[0]

        for source in (
            "cmp dword [edi + PROC_STATE], PROC_STATE_READY",
            "test dword [edi + PROC_VM_FLAGS], PROC_FLAG_IRQ_FRAME_VALID",
            "test dword [edi + PROC_SAVED_CS], 3",
            "cmp dword [edi + PROC_SAVED_EIP], 0",
            "mov [scheduler_next_process_ptr], edi",
            "mov [scheduler_next_pid], edx",
        ):
            self.assertIn(source, selector)
        self.assertLess(
            selector.index("cmp dword [edi + PROC_STATE], PROC_STATE_READY"),
            selector.index("test dword [edi + PROC_VM_FLAGS], PROC_FLAG_IRQ_FRAME_VALID"),
        )
        self.assertLess(
            selector.index("test dword [edi + PROC_VM_FLAGS], PROC_FLAG_IRQ_FRAME_VALID"),
            selector.index("test dword [edi + PROC_SAVED_CS], 3"),
        )
        self.assertLess(
            selector.index("test dword [edi + PROC_SAVED_CS], 3"),
            selector.index("cmp dword [edi + PROC_SAVED_EIP], 0"),
        )

    def test_anonymous_mmap_tail_munmap_reclaims_brk_backed_pages(self):
        kernel = read_kernel()
        probe = (ROOT / "user" / "probe.c").read_text()
        sbrk = kernel.split(".sbrk:", 1)[1].split(".open:", 1)[0]
        mmap = kernel.split(".mmap:", 1)[1].split(".munmap:", 1)[0]
        munmap = kernel.split(".munmap:", 1)[1].split(".ioctl:", 1)[0]
        scheduler_init = kernel.split("scheduler_init:", 1)[1].split("process_reset_user_probe:", 1)[0]
        for source in (
            "process_mmap_allocations dd 0",
            "process_mmap_pages_mapped dd 0",
            "process_sbrk_shrink_calls dd 0",
            "process_sbrk_pages_released dd 0",
            "process_munmap_attempts dd 0",
            "process_munmap_pages_released dd 0",
            "process_munmap_non_tail_kept dd 0",
            "process_munmap_holes_punched dd 0",
            "process_munmap_pages_unmapped dd 0",
            "process_last_munmap_base dd 0",
            "process_last_munmap_end dd 0",
            "process_heap_mark_range:",
            "process_heap_clear_range:",
            "process_heap_range_is_mapped:",
            "VM_OBJECT_KIND_NONE equ 0",
            "VM_OBJECT_KIND_ANON_BRK equ 1",
            "process_mmap_last_object_kind dd 0",
            "process_mmap_last_base dd 0",
            "process_mmap_last_end dd 0",
            "process_mmap_last_prot dd 0",
            "process_mmap_last_flags dd 0",
        ):
            self.assertIn(source, kernel)
        for source in (
            "mov dword [process_mmap_allocations], 0",
            "mov dword [process_mmap_pages_mapped], 0",
            "mov dword [process_mmap_last_object_kind], VM_OBJECT_KIND_NONE",
            "mov dword [process_mmap_last_base], 0",
            "mov dword [process_mmap_last_end], 0",
            "mov dword [process_mmap_last_prot], 0",
            "mov dword [process_mmap_last_flags], 0",
            "mov dword [process_sbrk_shrink_calls], 0",
            "mov dword [process_sbrk_pages_released], 0",
            "mov dword [process_munmap_attempts], 0",
            "mov dword [process_munmap_pages_released], 0",
            "mov dword [process_munmap_non_tail_kept], 0",
            "mov dword [process_munmap_holes_punched], 0",
            "mov dword [process_munmap_pages_unmapped], 0",
            "mov dword [process_last_munmap_base], 0",
            "mov dword [process_last_munmap_end], 0",
        ):
            self.assertIn(source, scheduler_init)
        for source in (
            "test ebx, 0x80000000",
            "jnz .sbrk_shrink",
            "mov [sbrk_old_brk], eax",
            "mov [sbrk_new_brk], edx",
            "mov edi, [sbrk_old_brk]",
            "mov ecx, [sbrk_new_brk]",
            "rep stosb",
            "mov eax, [sbrk_old_brk]",
            "mov edx, [sbrk_new_brk]",
            "call process_heap_mark_range",
            ".sbrk_shrink:",
            "cmp edx, [esi + PROC_HEAP_START]",
            "call process_clear_user_range",
            "add [process_sbrk_pages_released], eax",
            "inc dword [process_sbrk_shrink_calls]",
            "mov eax, [sbrk_old_brk]",
        ):
            self.assertIn(source, sbrk)
        for source in (
            "add [process_mmap_pages_mapped], eax",
            "inc dword [process_mmap_allocations]",
            "call process_heap_mark_range",
            "mov dword [process_mmap_last_object_kind], VM_OBJECT_KIND_ANON_BRK",
            "mov [process_mmap_last_base], eax",
            "mov [process_mmap_last_end], eax",
            "mov [process_mmap_last_prot], eax",
            "mov [process_mmap_last_flags], eax",
            "mov eax, [mmap_base_arg]",
        ):
            self.assertIn(source, mmap)
        self.assertIn(
            "mov eax, [esi + PROC_BRK]\n"
            "    add eax, PAGE_SIZE - 1\n"
            "    jc .bad_syscall_enomem\n"
            "    and eax, 0xfffff000\n"
            "    mov [mmap_base_arg], eax",
            mmap,
        )
        for source in (
            "inc dword [process_munmap_attempts]",
            "and eax, PAGE_SIZE - 1",
            "jnz .bad_syscall_einval",
            "add eax, PAGE_SIZE - 1",
            "and eax, 0xfffff000",
            "mov [mmap_end_arg], eax",
            "call user_range_validate",
            "mov [process_last_munmap_base], eax",
            "mov [process_last_munmap_end], eax",
            "cmp eax, [esi + PROC_BRK]",
            "jne .munmap_keep_non_tail",
            "call process_clear_user_range",
            "mov cr3, ebx",
            "mov [esi + PROC_BRK], eax",
            "add [process_munmap_pages_released], eax",
            ".munmap_keep_non_tail:",
            "inc dword [process_munmap_non_tail_kept]",
            "inc dword [process_munmap_holes_punched]",
            "add [process_munmap_pages_unmapped], eax",
        ):
            self.assertIn(source, munmap)
        validator = kernel.split("user_range_validate:", 1)[1].split("doom_log_char:", 1)[0]
        self.assertIn("call process_heap_range_is_mapped", validator)
        self.assertIn("unsigned char *hole = sys_mmap(8192", probe)
        self.assertIn("sys_sbrk(-4096) == trim + 4096", probe)
        self.assertIn("sys_write(1, trim + 4096, 1) == -ERRNO_EINVAL", probe)
        self.assertIn("sys_munmap(hole, 4096) == 0", probe)
        self.assertIn("sys_write(1, hole, 1) == -ERRNO_EINVAL", probe)
        self.assertIn("if (mmap_hole_ok && sys_munmap(video, DOOM_FRAME_BYTES + DOOM_PALETTE_BYTES) == 0)", probe)
        self.assertIn("flags |= PROBE_FLAG_MMAP;", probe)

    def test_fd_table_records_owner_generation_and_exec_inheritance_metadata(self):
        kernel = read_kernel()
        fd_reset = kernel.split("fd_reset_all:", 1)[1].split("fd_alloc:", 1)[0]
        fd_alloc = kernel.split("fd_alloc:", 1)[1].split("fd_lookup:", 1)[0]
        fd_lookup_descriptor = kernel.split("fd_lookup_descriptor:", 1)[1].split("fd_lookup:", 1)[0]
        fd_lookup = kernel.split("fd_lookup:", 1)[1].split("fd_clear_slot:", 1)[0]
        close_handler = kernel.split(".close:", 1)[1].split(".audio:", 1)[0]
        for source in (
            "FD_INHERIT_EXEC equ 0x1",
            "O_CLOEXEC equ 0x0800",
            "fd_owner_pids times USER_FD_COUNT dd 0xffffffff",
            "fd_open_generations times USER_FD_COUNT dd 0",
            "fd_inherit_flags times USER_FD_COUNT dd 0",
            "fd_description_roots times USER_FD_COUNT dd 0",
            "fd_refcounts times USER_FD_COUNT dd 0",
            "fd_exec_handoffs dd 0",
            "fd_exec_inherited dd 0",
            "fd_exec_closed dd 0",
            "fd_owner_closes dd 0",
        ):
            self.assertIn(source, kernel)
        for source in (
            "mov dword [fd_owner_pids + ebx * 4], 0xffffffff",
            "mov dword [fd_inherit_flags + ebx * 4], 0",
            "mov dword [fd_description_roots + ebx * 4], 0",
            "mov dword [fd_refcounts + ebx * 4], 0",
        ):
            self.assertIn(source, fd_reset)
        for source in (
            "mov eax, [current_pid]",
            "mov [fd_owner_pids + ebx * 4], eax",
            "inc dword [fd_open_generations + ebx * 4]",
            "mov [fd_description_roots + ebx * 4], ebx",
            "mov dword [fd_refcounts + ebx * 4], 1",
            "test dword [syscall_open_flags], O_CLOEXEC",
            "jnz .no_exec_inherit",
            "mov dword [fd_inherit_flags + ebx * 4], FD_INHERIT_EXEC",
            ".no_exec_inherit:",
            "mov dword [fd_inherit_flags + ebx * 4], 0",
            ".inherit_done:",
        ):
            self.assertIn(source, fd_alloc)
        for source in (
            "mov edx, [current_pid]",
            "cmp [fd_owner_pids + eax * 4], edx",
            "jne .fail",
        ):
            self.assertIn(source, fd_lookup_descriptor)
        for source in (
            "mov edx, [fd_description_roots + eax * 4]",
            "cmp byte [fd_status + edx], FD_STATUS_OPEN",
            "cmp dword [fd_refcounts + edx * 4], 0",
            "mov [file_io_fd_slot], eax",
        ):
            self.assertIn(source, fd_lookup)
        for source in (
            "call fd_lookup_descriptor",
            "call fd_close_slot",
        ):
            self.assertIn(source, close_handler)

    def test_fd_exec_handoff_retags_inheritable_fds_and_closes_teardown_owners(self):
        kernel = read_kernel()
        handoff = kernel.split("process_exec_handoff_current:", 1)[1].split("process_exec_seed_argv_stack:", 1)[0]
        fd_handoff = kernel.split("fd_exec_handoff:", 1)[1].split("writable_fd_index:", 1)[0]
        close_owned = kernel.split("fd_close_owned_by_pid:", 1)[1].split("fd_close_owned_by_process:", 1)[0]
        close_process = kernel.split("fd_close_owned_by_process:", 1)[1].split("fd_exec_handoff:", 1)[0]
        reuse = kernel.split("process_reuse_exec_target_slot:", 1)[1].split("process_retire_exec_slot:", 1)[0]
        retire_exec = kernel.split("process_retire_exec_slot:", 1)[1].split("process_retire_current_exit_slot:", 1)[0]
        retire_exit = kernel.split("process_retire_current_exit_slot:", 1)[1].split("clear_fault_record:", 1)[0]
        faulted = kernel.split("process_mark_current_faulted:", 1)[1].split("process_waitpid_current:", 1)[0]

        self.assertNotIn("call fd_reset_all", handoff)
        for source in (
            "mov eax, [edi + PROC_PID]",
            "mov edx, [esi + PROC_PID]",
            "call fd_exec_handoff",
        ):
            self.assertIn(source, handoff)
        for source in (
            "mov [fd_last_exec_from_pid], eax",
            "mov [fd_last_exec_to_pid], edx",
            "inc dword [fd_exec_handoffs]",
            "cmp [fd_owner_pids + ebx * 4], esi",
            "test dword [fd_inherit_flags + ebx * 4], FD_INHERIT_EXEC",
            "jz .close_on_exec",
            "mov [fd_owner_pids + ebx * 4], edx",
            "inc dword [fd_exec_inherited]",
            ".close_on_exec:",
            "call fd_close_slot",
            "inc dword [fd_exec_closed]",
        ):
            self.assertIn(source, fd_handoff)
        for source in (
            "mov [fd_last_closed_owner_pid], edx",
            "cmp [fd_owner_pids + ebx * 4], edx",
            "call fd_close_slot",
            "inc dword [fd_owner_closes]",
        ):
            self.assertIn(source, close_owned)
        for source in (
            "cmp esi, process_kernel",
            "mov eax, [esi + PROC_PID]",
            "call fd_close_owned_by_pid",
        ):
            self.assertIn(source, close_process)
        for lifecycle in (reuse, retire_exec, retire_exit, faulted):
            with self.subTest(lifecycle=lifecycle[:32]):
                self.assertIn("call fd_close_owned_by_process", lifecycle)

    def test_dup_syscalls_share_open_file_descriptions(self):
        kernel = read_kernel()
        probe = (ROOT / "user" / "probe.c").read_text()
        header = (ROOT / "doom_port" / "include" / "vibe_os.h").read_text()
        unistd = (ROOT / "doom_port" / "include" / "unistd.h").read_text()
        libc = (ROOT / "doom_port" / "libc.c").read_text()
        handler = kernel.split("syscall_handler:", 1)[1].split("user_range_validate:", 1)[0]
        fd_clone = kernel.split("fd_clone_descriptor:", 1)[1].split("fd_close_slot:", 1)[0]
        fd_close = kernel.split("fd_close_slot:", 1)[1].split("fd_close_owned_by_pid:", 1)[0]
        for source in (
            "SYS_DUP equ 32",
            "SYS_DUP2 equ 33",
            "SYS_DUP3 equ 34",
            "cmp eax, SYS_DUP",
            "je .dup",
            "cmp eax, SYS_DUP2",
            "je .dup2",
            "cmp eax, SYS_DUP3",
            "je .dup3",
            "VIBE_SYS_DUP = 32",
            "VIBE_SYS_DUP2 = 33",
            "VIBE_SYS_DUP3 = 34",
        ):
            self.assertIn(source, kernel if source.startswith("SYS_") or source.startswith("cmp ") or source.startswith("je ") else header)
        for source in (
            "int dup(int oldfd);",
            "int dup2(int oldfd, int newfd);",
            "int dup3(int oldfd, int newfd, int flags);",
        ):
            self.assertIn(source, unistd)
        for source in (
            "int dup(int oldfd)",
            "int dup2(int oldfd, int newfd)",
            "int dup3(int oldfd, int newfd, int flags)",
            "vibe_syscall3(VIBE_SYS_DUP",
            "vibe_syscall3(VIBE_SYS_DUP2",
            "vibe_syscall3(VIBE_SYS_DUP3",
            "clone_save_fd_tracking(oldfd, raw)",
        ):
            self.assertIn(source, libc)
        for source in (
            "mov [fd_description_roots + edi * 4], ebx",
            "inc dword [fd_refcounts + ebx * 4]",
            "mov eax, [fd_offsets + ebx * 4]",
            "mov [fd_offsets + edi * 4], eax",
            "mov [fd_inherit_flags + edi * 4], edx",
            "inc dword [fd_dup_shared]",
        ):
            self.assertIn(source, fd_clone)
        for source in (
            ".promote_root:",
            ".alias_found:",
            "mov [fd_description_roots + edi * 4], edi",
            "mov [fd_description_roots + ebx * 4], edi",
            "call fd_clear_slot",
        ):
            self.assertIn(source, fd_close)
        for source in (
            ".dup:",
            ".dup2:",
            ".dup3:",
            "inc dword [fd_dup_calls]",
            "inc dword [fd_dup2_calls]",
            "inc dword [fd_dup3_calls]",
            "and eax, 0xfffff7ff",
            "cmp ebx, ecx",
            "je .bad_syscall_einval",
            "call fd_clone_descriptor",
            "inc dword [fd_dup_cloexec]",
        ):
            self.assertIn(source, handler)
        for source in (
            "PROBE_FLAG_DUP = 0x20000u",
            "static int sys_dup(int fd)",
            "static int sys_dup2(int oldfd, int newfd)",
            "static int sys_dup3(int oldfd, int newfd, uint32_t flags)",
            "sys_dup(defaults)",
            "sys_dup2(dup_fd, DUP2_TARGET_FD) == DUP2_TARGET_FD",
            "sys_dup3(defaults, DUP3_TARGET_FD, O_CLOEXEC) == DUP3_TARGET_FD",
            "sys_dup2(dup_fd, dup_fd) == dup_fd",
            "sys_dup3(dup_fd, dup_fd, 0) == -ERRNO_EINVAL",
            "flags |= PROBE_FLAG_DUP;",
        ):
            self.assertIn(source, probe)

    def test_user_crt0_passes_argc_argv_and_empty_envp_to_user_main(self):
        crt0 = (ROOT / "user" / "crt0.asm").read_text()
        start = crt0.split("start:", 1)[1].split(".halt:", 1)[0]
        for source in (
            "mov eax, [esp]",
            "lea ebx, [esp + 4]",
            "lea ecx, [ebx + eax * 4 + 4]",
            "push ecx",
            "push ebx",
            "push eax",
            "call user_main",
            "add esp, 12",
        ):
            self.assertIn(source, start)

    def test_scheduler_preemption_selftest_uses_seeded_context_helper(self):
        kernel = read_kernel()
        selftest = kernel.split("scheduler_preempt_self_test:", 1)[1].split("process_boot_launch_doom:", 1)[0]
        self.assertIn("mov esi, process_preempt_probe", selftest)
        self.assertIn("mov dword [esi + PROC_ENTRY], USER_CODE_ADDR", selftest)
        self.assertIn("call process_seed_initial_user_context", selftest)
        self.assertIn("cmp dword [scheduler_next_process_ptr], process_preempt_probe", selftest)

    def test_expected_probe_fault_recovers_then_execs_abi_probe(self):
        kernel = read_kernel()
        probe = (ROOT / "user" / "probe.c").read_text()
        expect_fault = kernel.split(".expect_fault:", 1)[1].split(".write:", 1)[0]
        exception = kernel.split("exception_common:", 1)[1].split("irq_timer:", 1)[0]
        self.assertIn("mov [user_fault_recovery], ebx", expect_fault)
        self.assertIn("call user_range_validate", expect_fault)
        self.assertIn("EXCEPTION_FRAME_EIP equ 8", kernel)
        self.assertIn("EXPECTED_FAULT_INSTRUCTION_BYTES equ 2", kernel)
        self.assertIn("mov eax, [user_fault_recovery]", exception)
        self.assertIn("mov [esp + EXCEPTION_FRAME_EIP], eax", exception)
        self.assertIn("add dword [esp + EXCEPTION_FRAME_EIP], EXPECTED_FAULT_INSTRUCTION_BYTES", exception)
        self.assertIn("add esp, 8", exception)
        self.assertIn("iretd", exception.split(".expected_fault_return:", 1)[1])
        self.assertNotIn("jmp user_probe_finished", exception.split(".not_expected_user_fault:", 1)[0])
        self.assertNotIn("call process_mark_current_faulted", exception.split(".not_expected_user_fault:", 1)[0])
        self.assertIn('"movl $1f, %%ebx', probe)
        self.assertIn('"int $0x80', probe)
        self.assertIn('"1:', probe)
        self.assertNotIn("&&after_expected_fault", probe)
        self.assertIn("return sys_execv(abi_probe_path, abi_probe_argv) == 0 ? 0 : 1;", probe)

    def test_split_doom_elf_segments_still_count_as_loaded(self):
        kernel = read_kernel()
        write_smoke = kernel.split("write_smoke_status:", 1)[1].split("smoke_copy_string:", 1)[0]
        draw_status = kernel.split("draw_doom_status:", 1)[1].split("draw_heap_status:", 1)[0]
        self.assertIn("inc byte [doom_load_segment_count]", kernel)
        self.assertIn("cmp byte [doom_load_segment_count], 0", write_smoke)
        self.assertIn("je .doom_fail", write_smoke)
        self.assertNotIn("cmp byte [doom_load_segment_count], 1", write_smoke)
        self.assertIn("cmp byte [doom_load_segment_count], 0", draw_status)
        self.assertIn("je .fail", draw_status)
        self.assertNotIn("cmp byte [doom_load_segment_count], 1", draw_status)

    def test_process_exec_doc_keeps_fixed_slot_process_gap_honest(self):
        process_doc = (ROOT / "docs" / "process-exec.md").read_text()

        for phrase in (
            "arbitrary root-level FAT16 `.ELF` paths",
            "two-entry generic probe-class pool",
            "dynamic target selection",
            "switches the caller back to RUNNING",
            "empty `envp` contract",
            "not a robust Unix",
            "`fork`/`exec` split",
            "wait blocking",
            "fork-time descriptor table cloning",
            "unbounded dynamic child slots",
            "address-space",
        ):
            with self.subTest(phrase=phrase):
                self.assertIn(phrase, process_doc)

    def test_posix_general_os_gaps_are_executable_contracts(self):
        kernel = read_kernel()
        header = (ROOT / "doom_port" / "include" / "vibe_os.h").read_text()
        unistd = (ROOT / "doom_port" / "include" / "unistd.h").read_text()
        libc = (ROOT / "doom_port" / "libc.c").read_text()
        mman = (ROOT / "doom_port" / "include" / "sys" / "mman.h").read_text()
        process_doc = (ROOT / "docs" / "process-exec.md").read_text()
        runtime_doc = (ROOT / "docs" / "doom-libc-runtime.md").read_text()
        probe = (ROOT / "user" / "probe.c").read_text()
        include_dir = ROOT / "doom_port" / "include"

        fork_handler = kernel.split(".fork:", 1)[1].split(".waitpid:", 1)[0]
        mmap_handler = kernel.split(".mmap:", 1)[1].split(".munmap:", 1)[0]
        ioctl_handler = kernel.split(".ioctl:", 1)[1].split(".ioctl_fbinfo:", 1)[0]

        for source in (
            "SYS_FORK equ 23",
            "cmp eax, SYS_FORK",
            "je .fork",
        ):
            self.assertIn(source, kernel)
        self.assertIn("jmp .bad_syscall_enosys", fork_handler)
        self.assertIn("pid_t fork(void)", libc)
        self.assertIn("vibe_syscall3(VIBE_SYS_FORK, 0, 0, 0)", libc)
        self.assertIn("syscall3(SYS_FORK, 0, 0, 0) == -ERRNO_ENOSYS", probe)

        for source in (
            "FD_INHERIT_EXEC equ 0x1",
            "fd_owner_pids times USER_FD_COUNT dd 0xffffffff",
            "fd_open_generations times USER_FD_COUNT dd 0",
            "fd_inherit_flags times USER_FD_COUNT dd 0",
            "fd_description_roots times USER_FD_COUNT dd 0",
            "fd_refcounts times USER_FD_COUNT dd 0",
            "SYS_DUP equ 32",
            "SYS_DUP2 equ 33",
            "SYS_DUP3 equ 34",
        ):
            self.assertIn(source, kernel)
        for source in (
            "VIBE_SYS_DUP",
            "VIBE_SYS_DUP2",
            "VIBE_SYS_DUP3",
        ):
            self.assertIn(source, header)
        for source in (
            "VIBE_SYS_SIGNAL",
            "VIBE_SYS_SIGACTION",
            "VIBE_SYS_KILL",
            "VIBE_SYS_TTY",
        ):
            self.assertNotIn(source, header)
        for source in (
            "int dup(",
            "int dup2(",
            "int dup3(",
        ):
            self.assertIn(source, unistd)
            self.assertIn(source, libc)
        for source in (
            "int isatty(",
        ):
            self.assertNotIn(source, unistd)
            self.assertNotIn(source, libc)

        self.assertIn("#define MAP_SHARED 0x01", mman)
        self.assertIn("#define MAP_FIXED 0x10", mman)
        self.assertIn("test dword [mmap_flags_arg], MMAP_MAP_FIXED", mmap_handler)
        self.assertIn("jnz .bad_syscall_einval", mmap_handler)
        self.assertIn("if (!(flags & MAP_ANONYMOUS) || fd != -1 || !(flags & MAP_PRIVATE) || (flags & MAP_SHARED))", libc)
        self.assertIn("syscall3(SYS_MMAP, 0, 4096, mmap_fixed_flags) == -ERRNO_EINVAL", probe)

        self.assertFalse((include_dir / "signal.h").exists())
        self.assertFalse((include_dir / "termios.h").exists())
        self.assertIn("cmp ebx, IOCTL_DISPLAY_FD", ioctl_handler)
        self.assertIn("jne .bad_syscall_enotty", ioctl_handler)
        self.assertIn("syscall_failed(raw, ENOTTY)", libc)

        for phrase in (
            "## POSIX Gap Decomposition",
            "Address-space cloning, copy-on-write or eager page copies",
            "Public `dup`, `dup2`, and `dup3` syscalls/libc wrappers",
            "Fork-time descriptor table cloning",
            "File-backed mappings, `MAP_SHARED`, `MAP_FIXED`",
            "`signal`, `sigaction`, `kill`, signal masks",
            "`termios`, `isatty`, controlling terminals",
            "Dynamically allocated process records, unbounded child slots",
        ):
            with self.subTest(phrase=phrase):
                self.assertIn(phrase, process_doc)
        for phrase in (
            "## General-OS Gap Contract",
            "`fork` exists only as a classified syscall/libc surface.",
            "Descriptor lifetime and fd duplication now have a bounded Unix-open-file-description milestone.",
            "VM allocation is anonymous/private and brk-backed.",
            "POSIX signal delivery is absent.",
            "Terminal/tty behavior is absent.",
            "Dynamic process lifetimes are bounded.",
        ):
            with self.subTest(phrase=phrase):
                self.assertIn(phrase, runtime_doc)
