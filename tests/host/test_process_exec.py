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
        self.assertIn('const char doom_path[] = "DOOM.ELF";', probe)
        self.assertIn("trigger_expected_fault();", probe)
        self.assertIn("return sys_exec(doom_path) == 0 ? 0 : 1;", probe)

    def test_initial_user_probe_gets_real_arg_stack_before_crt0(self):
        kernel = read_kernel()
        probe = (ROOT / "user" / "probe.c").read_text()
        user_probe_run = kernel.split("user_probe_run:", 1)[1].split(".fail:", 1)[0]
        for source in (
            "mov esi, exec_path_user_probe",
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
        for source in (
            "USER_PROBE_EXPECTED_FLAGS equ 0x00000fff",
            "PROBE_FLAG_PROCESS_ABI = 0x800u",
            "SYS_GETPID = 25",
            "int user_main(int argc, char **argv, char **envp)",
            'probe_streq(argv[0], "USERPROB.ELF")',
            "argv[1] == (char *)0",
            "envp[0] == (char *)0",
            "syscall3(SYS_GETPID, 0, 0, 0) == 1",
        ):
            self.assertIn(source, kernel if source.startswith("USER_PROBE_EXPECTED") else probe)

    def test_process_exec_resolves_path_through_table_and_fat(self):
        kernel = read_kernel()
        exec_path = kernel.split("process_exec_path:", 1)[1].split("process_exec_resolve_path:", 1)[0]
        resolver = kernel.split("process_exec_resolve_path:", 1)[1].split("process_exec_prepare_elf_image:", 1)[0]
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
        self.assertIn("call kernel_streq", resolver)
        self.assertIn("mov eax, [ebx + PROCESS_EXEC_TARGET]", resolver)
        self.assertIn("mov [process_exec_target], eax", resolver)

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
        self.assertIn("mov edx, [sys_exec_last_envp0]", write_smoke)

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

    def test_live_doom_user_status_accepts_ready_or_running_scheduler_state(self):
        kernel = read_kernel()
        write_smoke = kernel.split("write_smoke_status:", 1)[1].split("smoke_copy_string:", 1)[0]
        draw_status = kernel.split("draw_heap_status:", 1)[1].split(".wad_status:", 1)[0]

        for status_path in (write_smoke, draw_status):
            with self.subTest(status_path=status_path[:24]):
                self.assertIn("cmp byte [doom_run_status], 1", status_path)
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
        self.assertIn("cmp dword [process_exec_target], process_user_probe", exec_path)
        self.assertIn("mov [user_elf_first_cluster], ax", exec_path)
        self.assertIn("mov [user_elf_size], eax", exec_path)
        self.assertIn("mov [user_elf_sectors_read], eax", exec_path)
        self.assertIn("mov byte [user_elf_status], 1", exec_path)
        self.assertIn("cmp dword [process_exec_target], process_user_probe", prepare)
        self.assertIn("call user_elf_prepare", prepare)
        self.assertIn("mov eax, [user_entry_addr]", prepare)

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
            "call process_reset_user_probe",
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
            "sys_exec_last_argc dd 0",
            "sys_exec_last_argv dd 0",
            "sys_exec_last_argv0 dd 0",
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
        ):
            self.assertIn(source, stage_kernel_arg)

    def test_process_records_capture_exec_parent_and_user_abi_metadata(self):
        kernel = read_kernel()
        reset = kernel.split("process_reset_accounting:", 1)[1].split("clear_fault_record:", 1)[0]
        handoff = kernel.split("process_exec_handoff_current:", 1)[1].split("process_exec_seed_argv_stack:", 1)[0]
        argv = kernel.split("process_exec_seed_argv_stack:", 1)[1].split("process_exec_patch_syscall_frame:", 1)[0]
        user_probe_run = kernel.split("user_probe_run:", 1)[1].split(".fail:", 1)[0]
        for source in (
            "PROCESS_RECORD_BYTES equ 160",
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

    def test_expected_probe_fault_recovers_then_execs_doom(self):
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
        self.assertIn("return sys_exec(doom_path) == 0 ? 0 : 1;", probe)

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
            "fixed table entries instead of arbitrary FAT paths",
            "switches the caller back to RUNNING",
            "empty `envp` contract",
            "not a robust Unix",
            "`fork`/`exec` split",
            "`wait`/reap lifecycle",
            "fd inheritance",
            "dynamic child slots",
            "reusable address-space resources",
        ):
            with self.subTest(phrase=phrase):
                self.assertIn(phrase, process_doc)
