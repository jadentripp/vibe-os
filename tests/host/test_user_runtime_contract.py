import os
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


class UserRuntimeContractTests(unittest.TestCase):
    def test_user_runtime_is_reusable_outside_doom_port(self):
        header = (ROOT / "user" / "runtime.h").read_text()
        source = (ROOT / "user" / "runtime.c").read_text()
        crt0 = (ROOT / "user" / "crt0.asm").read_text()
        abi_probe = (ROOT / "user" / "abi_probe.c").read_text()
        makefile = (ROOT / "Makefile").read_text()
        runtime_doc = (ROOT / "docs" / "architecture.txt").read_text()

        for token in (
            "int vibe_user_syscall3(",
            "int vibe_user_syscall_errno(",
            "static inline int vibe_user_result_is_error(",
            "static inline int vibe_user_result_errno(",
            "int vibe_user_write_all(",
            "int vibe_user_write_full(int fd, const void* buffer, unsigned long count, unsigned long* out_written);",
            "int vibe_user_read_full(int fd, void* buffer, unsigned long count, unsigned long* out_read);",
            "int vibe_user_read_exact(int fd, void* buffer, unsigned long count, unsigned long* out_read);",
            "int vibe_user_sbrk(long increment, void** previous_break);",
            "int vibe_user_open(const char* path, unsigned long flags, unsigned long mode);",
            "int vibe_user_write(int fd, const void* buffer, unsigned long count);",
            "int vibe_user_read(int fd, void* buffer, unsigned long count);",
            "int vibe_user_lseek(int fd, long offset, unsigned long whence);",
            "int vibe_user_pread(int fd, void* buffer, unsigned long count, long offset);",
            "int vibe_user_close(int fd);",
            "int vibe_user_unlink(const char* path);",
            "int vibe_user_stat(const char* path, struct stat* out);",
            "int vibe_user_fstat(int fd, struct stat* out);",
            "int vibe_user_ftruncate(int fd, long length);",
            "VIBE_USER_O_RDONLY",
            "VIBE_USER_O_RDWR",
            "VIBE_USER_SEEK_CUR",
            "int vibe_user_getpid(void);",
            "int vibe_user_fork(void);",
            "int vibe_user_waitpid(long pid, int* status, unsigned long options);",
            "int vibe_user_waitpid_nohang_reap(long pid, int* status, unsigned long max_polls);",
            "int vibe_user_waitpid_nohang_reap_exact(long pid, int* status, unsigned long max_polls)",
            "int vibe_user_dup(int oldfd);",
            "int vibe_user_dup2(int oldfd, int newfd);",
            "int vibe_user_dup3(int oldfd, int newfd, unsigned long flags);",
            "int vibe_user_fcntl(int fd, int cmd, unsigned long arg);",
            "int vibe_user_process_status(long pid, vibe_process_status_t* out);",
            "int vibe_user_process_status_current(vibe_process_status_t* out);",
            "int vibe_user_yield(void);",
            "int vibe_user_sleep_ticks(unsigned long ticks);",
            "int vibe_user_sleep_milliseconds(unsigned long milliseconds);",
            "int vibe_user_get_cloexec(int fd, int* out)",
            "int vibe_user_set_cloexec(int fd, int enabled)",
            "int vibe_user_mmap(void** out, unsigned long length, unsigned long prot, unsigned long flags);",
            "int vibe_user_mmap_anon(void** out, unsigned long length, unsigned long prot);",
            "int vibe_user_mmap_file(",
            "int vibe_user_mmap_file_private(void** out, unsigned long length, unsigned long prot, int fd, long offset);",
            "int vibe_user_munmap(void* addr, unsigned long length);",
            "unsigned long vibe_user_heap_capabilities(void);",
            "unsigned long vibe_user_vm_capabilities(void);",
            "int vibe_user_clock_gettime(",
            "int vibe_user_clock_monotonic(",
            "unsigned long vibe_user_monotonic_milliseconds(void);",
            "int vibe_user_poll_input(vibe_input_event_t* event);",
            "int vibe_user_drain_input(vibe_input_event_t* events, unsigned long max_events);",
            "int vibe_user_input_status(vibe_input_status_t* status);",
            "int vibe_user_input_device_status(unsigned long device_id, vibe_input_device_status_t* status);",
            "static inline int vibe_user_audio_device_start(void)",
            "static inline int vibe_user_audio_device_info(vibe_audio_device_info_t* info)",
            "static inline int vibe_user_audio_pcm_ring_info(vibe_audio_pcm_ring_info_t* info)",
            "static inline int vibe_user_audio_stream_info(unsigned long handle, vibe_audio_stream_info_t* info)",
            "static inline int vibe_user_audio_pcm_open(const vibe_audio_pcm_desc_t* format)",
            "static inline int vibe_user_audio_pcm_write(",
            "static inline int vibe_user_audio_pcm_write_desc(",
            "static inline int vibe_user_audio_pcm_drain(unsigned long handle)",
            "static inline int vibe_user_audio_pcm_close(unsigned long handle)",
            "static inline int vibe_user_audio_stream_open(const vibe_audio_pcm_desc_t* format)",
            "static inline int vibe_user_audio_stream_write(",
            "static inline int vibe_user_audio_stream_drain(unsigned long handle)",
            "static inline int vibe_user_audio_stream_close(unsigned long handle)",
            "static inline int vibe_user_audio_pcm_buffered_bytes(unsigned long handle)",
            "static inline int vibe_user_audio_pcm_pull_state(unsigned long handle)",
            "int vibe_user_listdir(",
            "int vibe_user_file_size(const char* path, unsigned long* out_size);",
            "int vibe_user_file_read_at(",
            "int vibe_user_file_read_all(",
            "int vibe_user_dirent_name_eq(",
            "int vibe_user_listdir_find(",
            "int vibe_user_validate_exec_argv(",
            "int vibe_user_validate_exec_envp(",
            "int vibe_user_execv(",
            "int vibe_user_execv_checked(",
            "int vibe_user_execve_checked(",
            "int vibe_user_execve(",
            "void vibe_user_report_probe(",
        ):
            with self.subTest(token=token):
                self.assertIn(token, header)

        for token in (
            "static inline int vibe_user_waitpid_nohang_reap_exact(",
            "static inline int vibe_user_get_cloexec(",
            "static inline int vibe_user_set_cloexec(",
            "static inline int vibe_user_listdir_find(",
            "static inline int vibe_user_validate_exec_argv(",
            "static inline int vibe_user_validate_exec_envp(",
            "static inline int vibe_user_execve_checked(",
            "static inline int vibe_user_execve(",
        ):
            with self.subTest(token=token):
                self.assertIn(token, header)

        for token in (
            "int $0x80",
            "vibe_user_syscall_errno",
            "vibe_user_result_errno(raw_result, fallback_errno)",
            "int vibe_user_write_full(int fd, const void* buffer, unsigned long count, unsigned long* out_written)",
            "int vibe_user_read_full(int fd, void* buffer, unsigned long count, unsigned long* out_read)",
            "int vibe_user_read_exact(int fd, void* buffer, unsigned long count, unsigned long* out_read)",
            "__vibe_syscall0(number)",
            "__vibe_syscall1(number, arg0)",
            "__vibe_syscall2(number, arg0, arg1)",
            "__vibe_syscall3(number, arg0, arg1, arg2)",
            "VIBE_SYS_SBRK",
            "VIBE_SYS_FORK",
            "VIBE_SYS_WAITPID",
            "vibe_user_waitpid_nohang_reap",
            "VIBE_SYS_MMAP",
            "VIBE_SYS_MUNMAP",
            "vibe_user_mmap_file",
            "vibe_user_pread",
            "VIBE_SYS_CLOCK_GETTIME",
            "vibe_user_clock_gettime",
            "vibe_user_monotonic_milliseconds",
            "VIBE_SYS_POLL_INPUT",
            "vibe_user_poll_input",
            "vibe_user_drain_input",
            "VIBE_SYS_INPUT_STATUS",
            "vibe_user_input_status",
            "VIBE_SYS_INPUT_DEVICE_STATUS",
            "vibe_user_input_device_status",
            "VIBE_SYS_LISTDIR",
            "VIBE_SYS_READ",
            "VIBE_SYS_STAT",
            "VIBE_SYS_FSTAT",
            "VIBE_SYS_FTRUNCATE",
            "VIBE_SYS_UNLINK",
            "VIBE_SYS_LSEEK",
            "vibe_user_file_size",
            "vibe_user_file_read_at",
            "vibe_user_file_read_all",
            "VIBE_SYS_EXEC",
            "vibe_user_syscall3(VIBE_SYS_EXEC, (unsigned long)path, (unsigned long)argv, 0)",
            "VIBE_SYS_DUP",
            "VIBE_SYS_DUP2",
            "VIBE_SYS_DUP3",
            "VIBE_SYS_FCNTL",
            "VIBE_SYS_PROCESS_STATUS",
            "VIBE_SYS_YIELD",
            "VIBE_SYS_SLEEP_TICKS",
            "vibe_user_process_status",
            "vibe_user_sleep_ticks",
            "VIBE_SYS_USER_PROBE",
        ):
            with self.subTest(token=token):
                self.assertIn(token, source)

        self.assertIn('#include "runtime.h"', abi_probe)
        self.assertNotIn("static inline int syscall3", abi_probe)
        self.assertNotIn('"int $0x80"', abi_probe)
        self.assertIn("vibe_user_clock_monotonic(&now)", abi_probe)
        self.assertIn("ABI_PROBE_FLAG_INPUT = 0x00000040u", abi_probe)
        self.assertIn("ABI_PROBE_FLAG_FRAMEBUFFER = 0x00000080u", abi_probe)
        self.assertIn("ABI_PROBE_FLAG_PROCESS = 0x00000100u", abi_probe)
        self.assertIn("ABI_PROBE_FLAG_FILES = 0x00000200u", abi_probe)
        self.assertIn("prove_process_services(pid)", abi_probe)
        self.assertIn("prove_generic_file_services()", abi_probe)
        self.assertIn('vibe_user_listdir(asset_dir, entries, 16)', abi_probe)
        self.assertIn('vibe_user_file_read_all(asset_file, buffer, sizeof(buffer), &bytes_read)', abi_probe)
        self.assertIn('vibe_user_open(\n        state_file,\n        VIBE_USER_O_CREAT | VIBE_USER_O_RDWR | VIBE_USER_O_TRUNC', abi_probe)
        self.assertIn("vibe_user_ftruncate(fd, 4)", abi_probe)
        self.assertIn("vibe_user_unlink(state_file)", abi_probe)
        self.assertIn("vibe_user_process_status_current(&status)", abi_probe)
        self.assertIn("vibe_user_yield() != 0", abi_probe)
        self.assertIn("vibe_user_sleep_ticks(1) != 0", abi_probe)
        self.assertIn("vibe_user_input_status(&input_status)", abi_probe)
        self.assertIn("vibe_user_input_device_status(VIBE_INPUT_DEVICE_KEYBOARD", abi_probe)
        self.assertIn("vibe_user_input_device_status(VIBE_INPUT_DEVICE_MOUSE", abi_probe)
        self.assertIn("vibe_input_status_abi_is_current(&input_status)", abi_probe)
        self.assertIn("vibe_input_status_uses_drop_oldest(&input_status)", abi_probe)
        self.assertIn("vibe_input_status_keyboard_is_ready(&input_status)", abi_probe)
        self.assertIn("vibe_input_device_record_is_ready(&keyboard_status)", abi_probe)
        self.assertIn("flags |= ABI_PROBE_FLAG_INPUT;", abi_probe)
        self.assertIn("flags |= ABI_PROBE_FLAG_FRAMEBUFFER;", abi_probe)
        self.assertIn("flags |= ABI_PROBE_FLAG_PROCESS;", abi_probe)
        self.assertIn("flags |= ABI_PROBE_FLAG_FILES;", abi_probe)
        self.assertIn("prove_framebuffer_device()", abi_probe)
        self.assertIn("prove_audio_device()", abi_probe)
        self.assertIn("vibe_user_audio_pcm_open(&format)", abi_probe)
        self.assertIn("vibe_user_audio_pcm_write_desc((unsigned long)handle, &write_desc)", abi_probe)
        self.assertIn("vibe_user_audio_pcm_drain((unsigned long)handle)", abi_probe)
        self.assertIn("vibe_user_audio_pcm_close((unsigned long)handle)", abi_probe)
        self.assertIn("vibe_user_fcntl(wad, ABI_PROBE_F_SETFD, ABI_PROBE_FD_CLOEXEC)", abi_probe)
        self.assertIn("prove_file_private_mapping(wad_path)", abi_probe)
        self.assertIn("vibe_user_waitpid(child, &status, 0)", abi_probe)
        self.assertIn("duplicate_reap == -ABI_PROBE_ERRNO_ECHILD", abi_probe)
        self.assertIn('vibe_user_streq(envp[0], "PROBE_LAUNCHER=USERPROB")', abi_probe)
        self.assertIn('vibe_user_streq(envp[1], "ABI_ENV=present")', abi_probe)
        self.assertIn('vibe_user_execve("", doom_argv, envp) != -22', abi_probe)
        self.assertIn("vibe_user_execv(doom_path, doom_argv)", abi_probe)
        self.assertIn("USER_RUNTIME_C_SRC := user/runtime.c", makefile)
        self.assertIn("$(USER_RUNTIME_C_OBJ) $(USER_ABI_PROBE_C_OBJ)", makefile)
        self.assertIn("`user/runtime.h` and `user/runtime.c`", runtime_doc)
        self.assertIn("small non-Doom user programs", runtime_doc)
        self.assertIn("copy-backed private file mapping", runtime_doc)

        for token in (
            "global __vibe_syscall0",
            "global __vibe_syscall1",
            "global __vibe_syscall2",
            "global __vibe_syscall3",
            "VIBE_USER_ABI_VERSION equ 1",
            "VIBE_USER_STACK_ABI_VERSION equ 1",
            "SYSCALL_TRAP_VECTOR equ 0x80",
            "SYSCALL_MAX_ARGS equ 3",
            "__vibe_syscall0:",
            "__vibe_syscall1:",
            "__vibe_syscall2:",
            "__vibe_syscall3:",
            "push ebx",
            "int 0x80",
            "cld",
            "pop ebx",
        ):
            with self.subTest(token=token):
                self.assertIn(token, crt0)

    def test_user_runtime_stays_inside_current_general_os_contract(self):
        header = (ROOT / "user" / "runtime.h").read_text()
        source = (ROOT / "user" / "runtime.c").read_text()
        process_doc = (ROOT / "docs" / "architecture.txt").read_text()
        runtime_doc = (ROOT / "docs" / "architecture.txt").read_text()

        for token in (
            "VIBE_SYS_EXEC",
            "VIBE_SYS_GETPID",
            "VIBE_SYS_SBRK",
            "VIBE_SYS_FORK",
            "VIBE_SYS_WAITPID",
            "VIBE_SYS_OPEN",
            "VIBE_SYS_WRITE",
            "VIBE_SYS_READ",
            "VIBE_SYS_STAT",
            "VIBE_SYS_FSTAT",
            "VIBE_SYS_FTRUNCATE",
            "VIBE_SYS_UNLINK",
            "VIBE_SYS_LSEEK",
            "VIBE_SYS_CLOSE",
            "VIBE_SYS_FCNTL",
            "VIBE_SYS_PROCESS_STATUS",
            "VIBE_SYS_YIELD",
            "VIBE_SYS_SLEEP_TICKS",
            "vibe_user_process_status",
            "vibe_user_sleep_ticks",
            "VIBE_SYS_MMAP",
            "VIBE_SYS_MUNMAP",
            "VIBE_SYS_CLOCK_GETTIME",
            "vibe_user_clock_gettime",
            "vibe_user_monotonic_milliseconds",
            "VIBE_SYS_POLL_INPUT",
            "VIBE_SYS_INPUT_STATUS",
            "VIBE_USER_SYS_DISPLAY_IOCTL",
            "vibe_user_fb_get_info",
            "vibe_user_present_indexed_checked",
            "VIBE_SYS_LISTDIR",
            "VIBE_SYS_USER_PROBE",
        ):
            with self.subTest(token=token):
                self.assertIn(token, source)

        for token in (
            "VIBE_EXEC_ARG_MAX",
            "VIBE_EXEC_ARG_STR_MAX",
        ):
            with self.subTest(token=token):
                self.assertIn(token, header)

        for token in (
            "VIBE_SYS_IOCTL",
            "VIBE_SYS_SIGNAL",
            "VIBE_SYS_TTY",
        ):
            with self.subTest(token=token):
                self.assertNotIn(token, header)
                self.assertNotIn(token, source)

        for token in (
            "vibe_user_ioctl",
            "vibe_user_signal",
            "vibe_user_tty",
        ):
            with self.subTest(token=token):
                self.assertNotIn(token, header)
                self.assertNotIn(token, source)

        self.assertIn("## POSIX Gap Decomposition", process_doc)
        self.assertIn("## General-OS Gap Contract", runtime_doc)
        self.assertIn("small non-Doom user programs", runtime_doc)
        self.assertIn("USER_RUNTIME_CONTRACT[WAIT_REAP_HELPER]", runtime_doc)
        self.assertIn("USER_RUNTIME_CONTRACT[EXEC_ENV_HELPER]", runtime_doc)
        self.assertIn("USER_RUNTIME_CONTRACT[LISTDIR_FIND_HELPER]", runtime_doc)
        self.assertIn("USER_RUNTIME_CONTRACT[FILE_READ_HELPERS]", runtime_doc)
        self.assertIn("USER_RUNTIME_CONTRACT[BUFFER_IO_HELPERS]", runtime_doc)
        self.assertIn("USER_RUNTIME_CONTRACT[GENERIC_STATE_FILE]", runtime_doc)
        self.assertIn("USER_RUNTIME_CONTRACT[FD_CLOEXEC_HELPER]", runtime_doc)
        self.assertIn("USER_RUNTIME_CONTRACT[INPUT_HELPERS]", runtime_doc)
        self.assertIn("USER_RUNTIME_CONTRACT[FILE_PRIVATE_MMAP]", runtime_doc)

    def test_user_runtime_has_host_proof(self):
        source = ROOT / "tests" / "host" / "user_runtime_test.c"

        with tempfile.TemporaryDirectory() as tmp:
            binary = Path(tmp) / "user_runtime_test"
            subprocess.run(
                [
                    os.environ.get("CLANG", "clang"),
                    "-std=gnu89",
                    "-Wall",
                    "-Wextra",
                    "-I",
                    str(ROOT / "doom_port" / "include"),
                    "-I",
                    str(ROOT / "user"),
                    str(source),
                    "-o",
                    str(binary),
                ],
                check=True,
                cwd=ROOT,
            )
            subprocess.run([str(binary)], check=True, cwd=ROOT)


if __name__ == "__main__":
    unittest.main()
