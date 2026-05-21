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
        abi_probe = (ROOT / "user" / "abi_probe.c").read_text()
        makefile = (ROOT / "Makefile").read_text()
        runtime_doc = (ROOT / "docs" / "architecture.md").read_text()

        for token in (
            "int vibe_user_syscall3(",
            "int vibe_user_syscall_errno(",
            "int vibe_user_write_all(",
            "int vibe_user_open(const char* path, unsigned long flags, unsigned long mode);",
            "int vibe_user_read(int fd, void* buffer, unsigned long count);",
            "int vibe_user_lseek(int fd, long offset, unsigned long whence);",
            "int vibe_user_pread(int fd, void* buffer, unsigned long count, long offset);",
            "int vibe_user_close(int fd);",
            "int vibe_user_getpid(void);",
            "int vibe_user_dup(int oldfd);",
            "int vibe_user_dup2(int oldfd, int newfd);",
            "int vibe_user_dup3(int oldfd, int newfd, unsigned long flags);",
            "int vibe_user_fcntl(int fd, int cmd, unsigned long arg);",
            "int vibe_user_clock_monotonic(",
            "int vibe_user_listdir(",
            "int vibe_user_execv(",
            "void vibe_user_report_probe(",
        ):
            with self.subTest(token=token):
                self.assertIn(token, header)

        for token in (
            "int $0x80",
            "vibe_user_syscall_errno",
            "VIBE_SYS_CLOCK_GETTIME",
            "VIBE_SYS_LISTDIR",
            "VIBE_SYS_READ",
            "VIBE_SYS_LSEEK",
            "VIBE_SYS_EXEC",
            "VIBE_SYS_DUP",
            "VIBE_SYS_DUP2",
            "VIBE_SYS_DUP3",
            "VIBE_SYS_FCNTL",
            "VIBE_SYS_USER_PROBE",
        ):
            with self.subTest(token=token):
                self.assertIn(token, source)

        self.assertIn('#include "runtime.h"', abi_probe)
        self.assertNotIn("static inline int syscall3", abi_probe)
        self.assertNotIn('"int $0x80"', abi_probe)
        self.assertIn("vibe_user_clock_monotonic(&now)", abi_probe)
        self.assertIn("vibe_user_fcntl(wad, ABI_PROBE_F_SETFD, ABI_PROBE_FD_CLOEXEC)", abi_probe)
        self.assertIn("vibe_user_execv(doom_path, doom_argv)", abi_probe)
        self.assertIn("USER_RUNTIME_C_SRC := user/runtime.c", makefile)
        self.assertIn("$(USER_RUNTIME_C_OBJ) $(USER_ABI_PROBE_C_OBJ)", makefile)
        self.assertIn("`user/runtime.h` and `user/runtime.c`", runtime_doc)
        self.assertIn("small non-Doom user programs", runtime_doc)

    def test_user_runtime_stays_inside_current_general_os_contract(self):
        header = (ROOT / "user" / "runtime.h").read_text()
        source = (ROOT / "user" / "runtime.c").read_text()
        process_doc = (ROOT / "docs" / "architecture.md").read_text()
        runtime_doc = (ROOT / "docs" / "architecture.md").read_text()

        for token in (
            "VIBE_SYS_EXEC",
            "VIBE_SYS_GETPID",
            "VIBE_SYS_OPEN",
            "VIBE_SYS_READ",
            "VIBE_SYS_LSEEK",
            "VIBE_SYS_CLOSE",
            "VIBE_SYS_FCNTL",
            "VIBE_SYS_CLOCK_GETTIME",
            "VIBE_SYS_LISTDIR",
            "VIBE_SYS_USER_PROBE",
        ):
            with self.subTest(token=token):
                self.assertIn(token, source)

        for token in (
            "VIBE_SYS_FORK",
            "VIBE_SYS_WAITPID",
            "VIBE_SYS_MMAP",
            "VIBE_SYS_MUNMAP",
            "VIBE_SYS_IOCTL",
            "VIBE_SYS_SIGNAL",
            "VIBE_SYS_TTY",
        ):
            with self.subTest(token=token):
                self.assertNotIn(token, header)
                self.assertNotIn(token, source)

        for token in (
            "vibe_user_fork",
            "vibe_user_wait",
            "vibe_user_mmap",
            "vibe_user_signal",
            "vibe_user_tty",
        ):
            with self.subTest(token=token):
                self.assertNotIn(token, header)
                self.assertNotIn(token, source)

        self.assertIn("## POSIX Gap Decomposition", process_doc)
        self.assertIn("## General-OS Gap Contract", runtime_doc)
        self.assertIn("small non-Doom user programs", runtime_doc)

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
