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
        self.assertIn("#define O_CLOEXEC 0x0800", fcntl)
        self.assertIn("static int validate_open_flags", libc)
        self.assertIn("O_CLOEXEC", libc)
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
            "tail munmap moves brk back",
            "punches validation holes without creating reusable VM objects",
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
            "call process_waitpid_current",
            "ERRNO_ECHILD",
        ):
            self.assertIn(token, kernel)
        for token in (
            "PROBE_FLAG_MMAP = 0x80u",
            "PROBE_FLAG_IOCTL_FBINFO = 0x100u",
            "PROBE_FLAG_IOCTL_PRESENT = 0x200u",
            "PROBE_FLAG_FORK_WAIT = 0x400u",
            "PROBE_FLAG_PROCESS_ABI = 0x800u",
            "PROBE_FLAG_NEGATIVE_SYSCALLS = 0x1000u",
            "SYS_MMAP = 20",
            "SYS_IOCTL = 22",
            "SYS_GETPID = 25",
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

    def test_real_doom_assets_are_runtime_inputs_not_repo_payloads(self):
        docs = (ROOT / "docs" / "doom-libc-runtime.md").read_text()
        docs_words = " ".join(docs.split())
        hygiene = (ROOT / "tools" / "check_repo_hygiene.py").read_text()

        for token in (
            "The repository carries source code, tests, docs, and generated storage fixtures",
            "The WAD is runtime input, not port source.",
            "user-owned or validated shareware WAD outside git",
            "Do not track or upload",
            "WAD files, disk images, raw audio captures, screenshots, framebuffer dumps",
        ):
            with self.subTest(token=token):
                self.assertIn(token, docs_words)
        for token in (
            "FORBIDDEN_TRACKED_MAGIC",
            "FORBIDDEN_UPLOAD_PATTERNS",
            "FORBIDDEN_REAL_WAD_UPLOAD_PATTERNS",
            "REAL_WAD_ALLOWED_UPLOAD_PATTERNS",
            "workflow_upload_violations",
        ):
            with self.subTest(token=token):
                self.assertIn(token, hygiene)

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

    def test_port_alloclow_preserves_original_save_scratch_assumption(self):
        original_video = (ROOT / "third_party" / "doom" / "linuxdoom-1.10" / "v_video.c").read_text()
        original_save = (ROOT / "third_party" / "doom" / "linuxdoom-1.10" / "g_game.c").read_text()
        platform = (ROOT / "doom_port" / "platform.c").read_text()

        for token in (
            "screens[i] = base + i*SCREENWIDTH*SCREENHEIGHT;",
            "save_p = savebuffer = screens[1]+0x4000;",
            "#define SAVEGAMESIZE\t0x2c000",
        ):
            source = original_save if "save" in token or "SAVEGAMESIZE" in token else original_video
            self.assertIn(token, source)

        for token in (
            "#define VIBE_DOOM_SAVE_SCRATCH_BYTES 0x2c000u",
            "bytes = (size_t)length + VIBE_DOOM_SAVE_SCRATCH_BYTES;",
            "memset(mem, 0, bytes);",
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

    def test_save_ticcmd_wrapper_preserves_original_doom_source(self):
        makefile = (ROOT / "Makefile").read_text()
        platform = (ROOT / "doom_port" / "platform.c").read_text()
        original = (ROOT / "third_party" / "doom" / "linuxdoom-1.10" / "g_game.c").read_text()

        self.assertIn("-DG_BuildTiccmd=doom_original_G_BuildTiccmd", makefile)
        self.assertIn("-DG_Ticker=doom_original_G_Ticker", makefile)
        self.assertIn("-fno-strict-aliasing", makefile)
        self.assertIn("$(DOOM_SRC_DIR)/g_game.c Makefile", makefile)
        self.assertIn("void doom_original_G_BuildTiccmd(ticcmd_t* cmd);", platform)
        self.assertIn("void doom_original_G_Ticker(void);", platform)
        self.assertIn("void G_SaveGame(int slot, char* description);", platform)
        self.assertIn("void G_DoSaveGame(void);", platform)
        self.assertIn("checkpoint_save_slot_if_needed();", platform)
        self.assertIn("checkpoint_load_slot_if_needed();", platform)
        self.assertIn("cache_persistence_requests();", platform)
        self.assertIn("#define VIBE_PERSISTENCE_MIN_LEVELTIME 32", platform)
        self.assertIn("if (save_checkpoint_requested)", platform)
        self.assertIn("if (load_checkpoint_requested)", platform)
        self.assertIn("if (!default_config_checkpoint_ready() || !persistence_checkpoint_requested())", platform)
        self.assertIn("savegameslot = save_checkpoint_slot;", platform)
        self.assertIn("strcpy(savedescription, description);", platform)
        self.assertIn("gameaction = ga_savegame;", platform)
        self.assertIn("void G_BuildTiccmd(ticcmd_t* cmd)", platform)
        self.assertIn("doom_original_G_BuildTiccmd(cmd);", platform)
        build_ticcmd = platform.split("void G_BuildTiccmd(ticcmd_t* cmd)", 1)[1].split(
            "void G_Ticker(void)", 1
        )[0]
        self.assertLess(
            build_ticcmd.index("checkpoint_save_slot_if_needed();"),
            build_ticcmd.index("doom_original_G_BuildTiccmd(cmd);"),
        )
        self.assertIn("void G_Ticker(void)", platform)
        self.assertIn("doom_original_G_Ticker();", platform)
        self.assertIn("if (gameaction == ga_savegame && savedescription[0])", platform)
        self.assertIn("G_DoSaveGame();", platform)
        finish_update = platform.split("void I_FinishUpdate(void)", 1)[1].split(
            "void I_WaitVBL", 1
        )[0]
        self.assertIn("checkpoint_load_slot_if_needed();", finish_update)
        self.assertNotIn("checkpoint_save_slot_if_needed();", finish_update)
        self.assertIn("(cmd->buttons & BT_SPECIALMASK) != BTS_SAVEGAME", platform)
        self.assertIn("target_tic = (gametic / divisor) % BACKUPTICS;", platform)
        self.assertIn("netcmds[consoleplayer][target_tic] = *cmd;", platform)
        self.assertIn("if (sendsave)", original)
        self.assertIn("cmd->buttons = BT_SPECIAL | BTS_SAVEGAME", original)
        self.assertNotIn("doom_original_G_BuildTiccmd", original)
        self.assertNotIn("doom_original_G_Ticker", original)

    def test_persistence_marker_requests_are_cached_before_gameplay_checkpoint(self):
        platform = (ROOT / "doom_port" / "platform.c").read_text()

        init_body = platform.split("void I_Init(void)", 1)[1].split("byte* I_ZoneBase", 1)[0]
        zone_body = platform.split("byte* I_ZoneBase(int* size)", 1)[1].split("int I_GetTime", 1)[0]
        cache_body = platform.split("static void cache_persistence_requests(void)", 1)[1].split("static void checkpoint_default_config_if_needed", 1)[0]
        save_request = platform.split("static int save_checkpoint_requested_once(void)", 1)[1].split("static int load_checkpoint_requested_once", 1)[0]
        load_request = platform.split("static int load_checkpoint_requested_once(void)", 1)[1].split("static int default_config_checkpoint_ready", 1)[0]
        config_request = platform.split("static int persistence_checkpoint_requested(void)", 1)[1].split("static int read_persistence_slot_request", 1)[0]

        self.assertIn("cache_persistence_requests();", init_body)
        self.assertIn("cache_persistence_requests();", zone_body)
        self.assertIn("(void)persistence_checkpoint_requested();", cache_body)
        self.assertIn("(void)save_checkpoint_requested_once();", cache_body)
        self.assertIn("(void)load_checkpoint_requested_once();", cache_body)
        self.assertIn("if (save_checkpoint_request_checked)\n        return save_checkpoint_requested;", save_request)
        self.assertIn("if (load_checkpoint_request_checked)\n        return load_checkpoint_requested;", load_request)
        self.assertIn(
            "if (default_config_checkpoint_request_checked)\n        return default_config_checkpoint_requested;",
            config_request,
        )

    def test_kernel_smoke_exposes_file_runtime_counters_not_fat_internals(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()
        makefile = (ROOT / "Makefile").read_text()
        docs = (ROOT / "docs" / "doom-libc-runtime.md").read_text()

        for token in (
            "doom_close_count",
            "doom_error_count",
            "doom_last_error",
            "doom_last_open_flags",
            "doom_last_open_mode",
            "doom_saveload_flags",
            "doom_saveload_slot",
            "doom_saveload_read_bytes",
            "doom_saveload_write_bytes",
            "doom_saveload_last_open_flags",
            "doom_saveload_last_open_mode",
            "doom_saveaction_flags",
            "doom_saveaction_gameaction",
            "doom_saveaction_slot",
            "doom_saveaction_desc_len",
            "doom_saveaction_desc_hash",
            "doom_saveaction_report_count",
            "doom_init_flags",
            "doom_init_report_count",
            "smoke_doomwad_text",
            "smoke_doominit_text",
            "smoke_doomclose_text",
            "smoke_doomerrno_text",
            "smoke_doommode_text",
            "smoke_doomsav_text",
            "smoke_saverd_text",
            "smoke_savewr_text",
            "smoke_saveclose_text",
            "smoke_savemode_text",
            "smoke_saveact_text",
            "smoke_savedesc_text",
            "smoke_doomerr_text",
        ):
            with self.subTest(token=token):
                self.assertIn(token, kernel)

        self.assertIn('grep -q "doomclose="', makefile)
        self.assertIn('grep -q "doomwad="', makefile)
        self.assertIn('grep -q "doominit="', makefile)
        self.assertIn('grep -q "doomerrno="', makefile)
        self.assertIn('grep -q "doommode="', makefile)
        self.assertIn('grep -q "doomsav="', makefile)
        self.assertIn('grep -q "saverd="', makefile)
        self.assertIn('grep -q "savewr="', makefile)
        self.assertIn('grep -q "saveclose="', makefile)
        self.assertIn('grep -q "savemode="', makefile)
        self.assertIn('grep -q "saveact="', makefile)
        self.assertIn('grep -q "savedesc="', makefile)
        self.assertIn("`doomopen`, `doomread`, `doomwad`, `doomwrite`, `doomseek`, `doomclose`", docs)
        self.assertIn("`doomsbrk`, `doomerr`, `doomerrno`, `doommode`, `doomsav`, `saverd`, `savewr`", docs)
        self.assertIn("`--load-status`", docs)


if __name__ == "__main__":
    unittest.main()
