import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
DOOM_BASE = 0x01000000
DOOM_HEAP_START = 0x01900000


def u16(data, offset):
    return int.from_bytes(data[offset:offset + 2], "little")


def u32(data, offset):
    return int.from_bytes(data[offset:offset + 4], "little")


class DoomRuntimeContractTests(unittest.TestCase):
    def test_port_layer_owns_doom_syscall_contract(self):
        header = (ROOT / "doom_port" / "include" / "vibe_os.h").read_text()
        errno_h = (ROOT / "doom_port" / "include" / "errno.h").read_text()
        fcntl = (ROOT / "doom_port" / "include" / "fcntl.h").read_text()
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()
        libc = (ROOT / "doom_port" / "libc.c").read_text()

        self.assertIn("Failure returns -errno", header)
        for token in (
            "#define ENOENT 2",
            "#define EBADF 9",
            "#define ECHILD 10",
            "#define ENOMEM 12",
            "#define EINVAL 22",
            "#define EMFILE 24",
            "#define ENOTTY 25",
            "#define ENOSYS 38",
        ):
            with self.subTest(token=token):
                self.assertIn(token, errno_h)
        self.assertIn("#define O_ACCMODE 0x0003", fcntl)
        self.assertIn("static int validate_open_flags", libc)
        self.assertIn("access_mode == O_ACCMODE", libc)
        self.assertIn("raw < -1", libc)
        for token in (
            "ERRNO_ENOENT equ 2",
            "ERRNO_EBADF equ 9",
            "ERRNO_ECHILD equ 10",
            "ERRNO_ENOMEM equ 12",
            "ERRNO_EINVAL equ 22",
            "ERRNO_EMFILE equ 24",
            "ERRNO_ENOTTY equ 25",
            "ERRNO_ENOSYS equ 38",
            ".bad_syscall_ebadf:",
            ".bad_syscall_echild:",
            ".bad_syscall_emfile:",
            ".bad_syscall_enotty:",
            ".bad_syscall_enosys:",
        ):
            with self.subTest(token=token):
                self.assertIn(token, kernel)

    def test_posix_process_memory_and_device_abi_is_declared_and_classified(self):
        header = (ROOT / "doom_port" / "include" / "vibe_os.h").read_text()
        libc = (ROOT / "doom_port" / "libc.c").read_text()
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()
        probe = (ROOT / "user" / "probe.c").read_text()
        mman = (ROOT / "doom_port" / "include" / "sys" / "mman.h").read_text()
        ioctl_h = (ROOT / "doom_port" / "include" / "sys" / "ioctl.h").read_text()
        wait_h = (ROOT / "doom_port" / "include" / "sys" / "wait.h").read_text()

        for token in (
            "VIBE_SYS_MMAP = 20",
            "VIBE_SYS_MUNMAP = 21",
            "VIBE_SYS_IOCTL = 22",
            "VIBE_SYS_FORK = 23",
            "VIBE_SYS_WAITPID = 24",
            "VIBE_SYS_GETPID = 25",
            "VIBE_IOCTL_FBINFO",
            "VIBE_IOCTL_PRESENT_INDEXED",
            "typedef struct vibe_fb_info",
            "typedef struct vibe_present_indexed",
        ):
            self.assertIn(token, header)
        for token in ("MAP_ANONYMOUS", "MAP_FAILED", "PROT_READ", "PROT_WRITE"):
            self.assertIn(token, mman)
        self.assertIn("int ioctl(int fd, unsigned long request, void* arg);", ioctl_h)
        self.assertIn("pid_t waitpid(pid_t pid, int* status, int options);", wait_h)
        for token in (
            "void* mmap(",
            "int munmap(",
            "int ioctl(",
            "pid_t fork(void)",
            "pid_t waitpid(",
            "pid_t getpid(void)",
            "int execv(",
            "int execve(",
            "int execl(",
            "return waitpid((pid_t)-1, status, 0);",
        ):
            self.assertIn(token, libc)
        for token in (
            "SYS_MMAP equ 20",
            "SYS_MUNMAP equ 21",
            "SYS_IOCTL equ 22",
            "SYS_FORK equ 23",
            "SYS_WAITPID equ 24",
            "SYS_GETPID equ 25",
            ".mmap:",
            ".munmap:",
            ".ioctl:",
            ".fork:",
            ".waitpid:",
            ".getpid:",
            "call vmm_mark_process_user_write_range",
            "VIBE_IOCTL_FBINFO equ 0x00005601",
            "VIBE_IOCTL_PRESENT_INDEXED equ 0x00005602",
            "jmp .bad_syscall_enosys",
            "jmp .bad_syscall_echild",
        ):
            self.assertIn(token, kernel)
        for token in (
            "PROBE_FLAG_MMAP = 0x80u",
            "PROBE_FLAG_IOCTL_FBINFO = 0x100u",
            "PROBE_FLAG_IOCTL_PRESENT = 0x200u",
            "PROBE_FLAG_FORK_WAIT = 0x400u",
            "SYS_MMAP = 20",
            "SYS_IOCTL = 22",
        ):
            self.assertIn(token, probe)

    def test_original_doom_sources_do_not_depend_on_vibe_syscalls(self):
        doom_src = ROOT / "third_party" / "doom" / "linuxdoom-1.10"
        forbidden = ("VIBE_SYS_", "vibe_syscall3", "doom_port", "vibe_os.h")
        for path in doom_src.glob("*.[ch]"):
            text = path.read_text(errors="ignore")
            for token in forbidden:
                with self.subTest(path=path.name, token=token):
                    self.assertNotIn(token, text)

    def test_doom_user_entry_and_static_argv_contract_are_explicit(self):
        start = (ROOT / "doom_port" / "start.c").read_text()
        linker = (ROOT / "tools" / "link_elf32.py").read_text()
        makefile = (ROOT / "Makefile").read_text()
        elf = (ROOT / "build" / "doom.elf").read_bytes()

        self.assertIn('static char arg0[] = "vibe-doom";', start)
        self.assertIn('static char arg_warp[] = "-warp";', start)
        self.assertIn("static char* argv_storage[]", start)
        self.assertIn("myargc = 6;", start)
        self.assertIn("myargv = argv_storage;", start)
        self.assertIn("void start(void)", start)
        self.assertIn("D_DoomMain();", start)
        self.assertIn("exit(0);", start)
        self.assertIn('raise ValueError("missing kernel entry symbol: start")', linker)
        self.assertIn('globals_by_name["start"].address()', linker)
        self.assertIn("doom_port/start.c", makefile)

        entry = u32(elf, 24)
        self.assertGreaterEqual(entry, DOOM_BASE)
        self.assertLess(entry, DOOM_HEAP_START)

    def test_doom_first_wad_lookup_flows_through_port_libc(self):
        original = (ROOT / "third_party" / "doom" / "linuxdoom-1.10" / "d_main.c").read_text()
        libc = (ROOT / "doom_port" / "libc.c").read_text()

        for token in (
            'doomwaddir = getenv("DOOMWADDIR");',
            'sprintf(doom1wad, "%s/doom1.wad", doomwaddir);',
            "if ( !access (doom1wad,R_OK) )",
        ):
            with self.subTest(token=token):
                self.assertIn(token, original)

        for token in (
            'if (!strcmp(name, "DOOMWADDIR"))',
            'return ".";',
            'if (!strcasecmp(slash, "doom1.wad"))',
            'return "DOOM1.WAD";',
            "fd = open(path, flags);",
            "close(fd);",
        ):
            with self.subTest(token=token):
                self.assertIn(token, libc)

    def test_port_quit_preserves_original_defaults_save_behavior(self):
        original = (ROOT / "third_party" / "doom" / "linuxdoom-1.10" / "i_system.c").read_text()
        platform = (ROOT / "doom_port" / "platform.c").read_text()

        for token in (
            "D_QuitNetGame ();",
            "I_ShutdownSound();",
            "I_ShutdownMusic();",
            "M_SaveDefaults ();",
            "I_ShutdownGraphics();",
            "exit(0);",
        ):
            self.assertIn(token, original)

        for token in (
            "D_QuitNetGame();",
            "I_ShutdownSound();",
            "I_ShutdownMusic();",
            "M_SaveDefaults();",
            "I_ShutdownGraphics();",
            "exit(0);",
        ):
            self.assertIn(token, platform)

    def test_doom_port_has_no_host_linux_platform_api_escape_hatches(self):
        forbidden = (
            "#include <sys/socket.h>",
            "#include <X11/",
            "socket(",
            "recvfrom(",
            "sendto(",
            "popen(",
            "system(",
            "/dev/dsp",
            "XOpenDisplay",
            "forkpty(",
        )
        for path in (ROOT / "doom_port").glob("**/*.[ch]"):
            text = path.read_text(errors="ignore")
            for token in forbidden:
                with self.subTest(path=path.relative_to(ROOT), token=token):
                    self.assertNotIn(token, text)

    def test_kernel_smoke_exposes_file_runtime_counters_not_fat_internals(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()
        makefile = (ROOT / "Makefile").read_text()
        docs = (ROOT / "docs" / "doom-libc-runtime.md").read_text()

        for token in (
            "doom_close_count",
            "doom_error_count",
            "doom_last_open_flags",
            "doom_last_open_mode",
            "smoke_doomclose_text",
            "smoke_doommode_text",
            "smoke_doomerr_text",
        ):
            with self.subTest(token=token):
                self.assertIn(token, kernel)

        self.assertIn('grep -q "doomclose="', makefile)
        self.assertIn('grep -q "doommode="', makefile)
        self.assertIn("`doomopen`, `doomread`, `doomwrite`, `doomseek`, `doomclose`", docs)


if __name__ == "__main__":
    unittest.main()
