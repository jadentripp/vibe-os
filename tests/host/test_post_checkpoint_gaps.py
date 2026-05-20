import importlib.util
import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
BUILD = ROOT / "build"
TOOL = ROOT / "tools" / "make_wad_image.py"
spec = importlib.util.spec_from_file_location("make_wad_image", TOOL)
make_wad_image = importlib.util.module_from_spec(spec)
spec.loader.exec_module(make_wad_image)

GAP_TOOL = ROOT / "tools" / "check_playability_gap_ledger.py"
gap_spec = importlib.util.spec_from_file_location("check_playability_gap_ledger", GAP_TOOL)
check_playability_gap_ledger = importlib.util.module_from_spec(gap_spec)
gap_spec.loader.exec_module(check_playability_gap_ledger)


class PostCheckpointGapTests(unittest.TestCase):
    def test_doom_user_fault_diagnostics_capture_exception_frame(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()

        for source in (
            "idt_start + (6 * 8)",
            "idt_start + (12 * 8)",
            "idt_start + (13 * 8)",
            "idt_start + (14 * 8)",
            "exception_invalid_opcode:",
            "exception_stack_fault:",
            "exception_general_protection:",
            "page_fault_handler:",
            "exception_common:",
            "mov [fault_vector], eax",
            "mov [fault_error], eax",
            "mov [fault_eip], eax",
            "mov [fault_cr2], eax",
            "mov [doom_fault_addr], eax",
            "mov [doom_fault_eip], eax",
            "mov [doom_fault_vector], eax",
            "mov [doom_fault_error], eax",
        ):
            with self.subTest(source=source):
                self.assertIn(source, kernel)

    def test_doom_exit_and_fault_diagnostics_are_cloud_visible(self):
        kernel = (ROOT / "kernel" / "kernel.asm").read_text()
        makefile = (ROOT / "Makefile").read_text()
        checker = (ROOT / "tools" / "check_real_wad_proof.py").read_text()
        runtime_doc = (ROOT / "docs" / "doom-libc-runtime.md").read_text()
        gap_doc = (ROOT / "docs" / "post-checkpoint-gaps.md").read_text()

        for source in (
            'smoke_doomexit_text db " doomexit="',
            'smoke_doomfault_text db " doomfault="',
            'smoke_doomfaultip_text db " doomfaultip="',
            'smoke_doomfaultv_text db " doomfaultv="',
            'smoke_doomfaulterr_text db " doomfaulterr="',
            "mov edx, [doom_exit_code]",
            "mov edx, [doom_fault_addr]",
            "mov edx, [doom_fault_eip]",
            "mov edx, [doom_fault_vector]",
            "mov edx, [doom_fault_error]",
            "doom_exit_code dd 0",
            "doom_fault_addr dd 0",
            "doom_fault_eip dd 0",
            "doom_fault_vector dd 0",
            "doom_fault_error dd 0",
        ):
            with self.subTest(source=source):
                self.assertIn(source, kernel)

        self.assertIn('grep -q "doomexit="', makefile)
        self.assertIn('grep -q "doomfault="', makefile)
        self.assertIn('grep -q "doomfaultip="', makefile)
        self.assertIn('grep -q "doomfaultv="', makefile)
        self.assertIn('grep -q "doomfaulterr="', makefile)
        self.assertIn('"doomexit"', checker)
        self.assertIn('"doomfault"', checker)
        self.assertIn('"doomfaultip"', checker)
        self.assertIn('"doomfaultv"', checker)
        self.assertIn('"doomfaulterr"', checker)
        self.assertIn("doomexit= must be zero", checker)
        self.assertIn('("doomfault", "doomfaultip", "doomfaultv", "doomfaulterr")', checker)
        self.assertIn('f"{fault_field}= must be zero', checker)
        self.assertIn("`doomexit`", runtime_doc)
        self.assertIn("`doomfault`", runtime_doc)
        self.assertIn("Doom user faults record `doomrun=FAULT` plus `doomfault=<cr2>`", gap_doc)
        self.assertIn("`doomfaultip=<eip>`", gap_doc)
        self.assertIn("`doomfaultv=<vector>`", gap_doc)
        self.assertIn("`doomfaulterr=<error-code>`", gap_doc)

    def test_save_config_persistence_is_image_proven_but_reboot_gap_is_documented(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        gap_doc = (ROOT / "docs" / "post-checkpoint-gaps.md").read_text()
        persistent_doc = (ROOT / "docs" / "persistent-fat16.md").read_text()

        default_payload = b"use_mouse\t\t1\nscreenblocks\t\t9\n"
        save_payload = b"VIBEOS-SAVE-PROOF" * 1024
        before_free = fs.free_data_clusters()

        default_chain = fs.write_root_file(make_wad_image.WRITABLE_DEFAULT_NAME, default_payload)
        save_chain = fs.write_root_file(make_wad_image.WRITABLE_SAVE_NAMES[0], save_payload)

        self.assertEqual(fs.read_root_file(make_wad_image.WRITABLE_DEFAULT_NAME), default_payload)
        self.assertEqual(fs.read_root_file(make_wad_image.WRITABLE_SAVE_NAMES[0]), save_payload)
        self.assertEqual(
            fs.root_file_metadata(make_wad_image.WRITABLE_DEFAULT_NAME)["size"],
            len(default_payload),
        )
        self.assertEqual(
            fs.root_file_metadata(make_wad_image.WRITABLE_SAVE_NAMES[0])["size"],
            len(save_payload),
        )
        self.assertEqual(
            fs.free_data_clusters(),
            before_free - len(default_chain) - len(save_chain),
        )

        freed = fs.truncate_root_file(make_wad_image.WRITABLE_SAVE_NAMES[0])
        self.assertEqual(freed, save_chain)
        self.assertEqual(fs.root_file_metadata(make_wad_image.WRITABLE_SAVE_NAMES[0])["size"], 0)

        self.assertIn("The FAT16 image has root entries for `DEFAULT.CFG`", gap_doc)
        self.assertIn("There is not yet a cloud reboot proof", gap_doc)
        self.assertIn("same disk image is booted again", gap_doc)
        self.assertIn("This is enough for Doom defaults and save slots", persistent_doc)

    def test_docs_keep_large_post_checkpoint_gaps_explicit(self):
        readme = (ROOT / "README.md").read_text()
        tests_readme = (ROOT / "tests" / "README.md").read_text()
        gap_doc = (ROOT / "docs" / "post-checkpoint-gaps.md").read_text()

        self.assertIn("docs/post-checkpoint-gaps.md", readme)
        self.assertIn("test_post_checkpoint_gaps.py", tests_readme)
        self.assertIn("tools/check_playability_gap_ledger.py", tests_readme)
        for claim_boundary in (
            "There is no cloud proof that an OS-requested",
            "Arbitrary kernel exceptions still fall into `exception_halt`",
            "This is not a full POSIX environment",
            "A previous run is useful",
            "stale once the kernel/runtime changes",
            "Do not call the project Doom-capable",
        ):
            with self.subTest(claim_boundary=claim_boundary):
                self.assertIn(claim_boundary, gap_doc)

    def test_machine_readable_gap_ledger_covers_playability_surface(self):
        gaps = check_playability_gap_ledger.validate_ledger(ROOT)

        self.assertEqual(
            set(gaps),
            {
                "CLOUD_BOOT",
                "REAL_GAMEPLAY",
                "HUMAN_PLAYTEST",
                "PERSISTENCE",
                "AUDIO",
                "VM_POSIX",
                "SHUTDOWN_PANIC",
                "HARDWARE_LIMITS",
            },
        )
        self.assertEqual({gap["status"] for gap in gaps.values()}, {"open"})
        self.assertEqual(
            {gap["category"] for gap in gaps.values()},
            {
                "cloud-boot",
                "real-gameplay",
                "human-playtest",
                "persistence",
                "audio",
                "vm-posix",
                "shutdown-panic",
                "hardware-limits",
            },
        )

    def test_gap_ledger_checker_cli_is_repo_local(self):
        result = subprocess.run(
            ["python3", str(GAP_TOOL)],
            cwd=ROOT,
            check=True,
            text=True,
            capture_output=True,
        )
        self.assertIn("playability gap ledger OK", result.stdout)


if __name__ == "__main__":
    unittest.main()
