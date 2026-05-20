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
        self.assertIn('smoke_exec_target_text db " target=", 0', kernel)
        self.assertIn('smoke_exec_argv_text db " argv0=", 0', kernel)
        self.assertIn("mov edx, [sys_exec_handoffs]", write_smoke)
        self.assertIn("mov edx, [sys_exec_scheduled]", write_smoke)
        self.assertIn("mov edx, [sys_exec_rollbacks]", write_smoke)
        self.assertIn("mov edx, [sys_exec_last_target_pid]", write_smoke)

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
            "call process_exec_patch_syscall_frame",
            "mov dword [edi + PROC_STATE], PROC_STATE_EXITED",
            "and dword [edi + PROC_VM_FLAGS], 0xfffffffe",
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
        for source in (
            "mov [esi + PROC_SAVED_EIP], eax",
            "mov [esi + PROC_SAVED_ESP], eax",
            "mov dword [esi + PROC_SAVED_EFLAGS], 0x00000202",
            "mov dword [esi + PROC_SAVED_CS], USER_CODE_SEG",
            "mov dword [esi + PROC_SAVED_SS], USER_DATA_SEG",
            "or dword [esi + PROC_VM_FLAGS], PROC_FLAG_IRQ_FRAME_VALID",
        ):
            self.assertIn(source, seed)

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
            "sys_exec_last_argc dd 0",
            "sys_exec_last_argv dd 0",
            "sys_exec_last_argv0 dd 0",
        ):
            self.assertIn(source, kernel)
        for source in (
            "sub eax, SYS_EXEC_PATH_MAX",
            "mov [sys_exec_argv0_ptr], eax",
            "mov esi, sys_exec_path_buffer",
            "rep movsb",
            "sub eax, SYS_EXEC_ARGV_SLOT_BYTES",
            "mov dword [edi], SYS_EXEC_ARGC_DEFAULT",
            "mov [edi + 4], eax",
            "mov dword [edi + 8], 0",
            "mov [edx + PROC_SAVED_ESP], eax",
        ):
            self.assertIn(source, argv)

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
        self.assertIn("sys_expect_fault(&&after_expected_fault);", probe)
        self.assertIn("after_expected_fault:", probe)
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
