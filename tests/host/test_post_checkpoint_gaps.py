import importlib.util
import os
import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
BUILD = Path(os.environ.get("VIBE_HOST_TEST_BUILD_DIR") or ROOT / "build")
TOOL = ROOT / "tools" / "make_wad_image.py"
spec = importlib.util.spec_from_file_location("make_wad_image", TOOL)
make_wad_image = importlib.util.module_from_spec(spec)
spec.loader.exec_module(make_wad_image)

GAP_TOOL = ROOT / "tools" / "check_playability_gap_ledger.py"
gap_spec = importlib.util.spec_from_file_location("check_playability_gap_ledger", GAP_TOOL)
check_playability_gap_ledger = importlib.util.module_from_spec(gap_spec)
gap_spec.loader.exec_module(check_playability_gap_ledger)


class PostCheckpointGapTests(unittest.TestCase):
    def assertContainsPhrase(self, text, phrase):
        self.assertIn(" ".join(phrase.split()), " ".join(text.split()))

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
        runtime_doc = (ROOT / "docs" / "architecture.txt").read_text()
        gap_doc = (ROOT / "docs" / "proof.txt").read_text()

        for source in (
            'smoke_doomexit_text db " doomexit="',
            'smoke_doomfault_text db " doomfault="',
            'smoke_doomfaultip_text db " doomfaultip="',
            'smoke_doomfaultv_text db " doomfaultv="',
            'smoke_doomfaulterr_text db " doomfaulterr="',
            'smoke_pfframe_text db " pf="',
            'smoke_faultsrc_text db " faultsrc="',
            'smoke_faultmode_text db " faultmode="',
            'smoke_faultcontain_text db " faultcontain="',
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
        self.assertIn('grep -Eq " pf=([0-9A-F]{8}/){4}[0-9A-F]{8}"', makefile)
        self.assertIn('grep -Eq "faultsrc=(NONE|EXPECT|USER|DOOM|KERNEL)"', makefile)
        self.assertIn('grep -Eq "faultmode=(NONE|USER|KERNEL)"', makefile)
        self.assertIn('grep -Eq "faultcontain=([0-9A-F]{8}/){4}[0-9A-F]{8}"', makefile)
        self.assertIn('grep -Eq " regs=([0-9A-F]{8}/){7}[0-9A-F]{8}"', makefile)
        self.assertIn('grep -Eq " segs=([0-9A-F]{8}/){5}[0-9A-F]{8}"', makefile)
        self.assertIn('grep -Eq " proc=([0-9A-F]{8}/){8}[0-9A-F]{8}"', makefile)
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

    def test_save_config_persistence_has_image_and_reboot_snapshot_gates(self):
        image = bytearray((BUILD / "disk.img").read_bytes())
        fs = make_wad_image.Fat16Image(image)
        gap_doc = (ROOT / "docs" / "proof.txt").read_text()
        persistent_doc = (ROOT / "docs" / "architecture.txt").read_text()

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
        self.assertIn("Run `26151623245` passes that reboot proof for `DEFAULT.CFG`", gap_doc)
        self.assertIn("Historical run `26156172979` passes the save-slot reboot proof", gap_doc)
        self.assertIn("passes save/load persistence", gap_doc)
        self.assertIn("persistence-proof-green", gap_doc)
        self.assertIn("captures the fresh baseline immediately after rebuilding", gap_doc)
        self.assertIn("same disk image is booted again", gap_doc)
        self.assertIn("reboot comparison now requires the fresh baseline", gap_doc)
        self.assertIn("Run `26157926297` on commit `6b5319e` passes the opt-in", gap_doc)
        self.assertIn("guest_exit_observed=true", gap_doc)
        self.assertIn("after-write snapshot", persistent_doc)
        self.assertIn("requires `--baseline-image` too", persistent_doc)
        self.assertIn("This is enough for Doom defaults and save slots", persistent_doc)

    def test_docs_keep_large_post_checkpoint_gaps_explicit(self):
        readme = (ROOT / "README.md").read_text()
        tests_readme = (ROOT / "tests" / "strategy.txt").read_text()
        gap_doc = (ROOT / "docs" / "proof.txt").read_text()
        playable_doc = (ROOT / "docs" / "proof.txt").read_text()
        process_doc = (ROOT / "docs" / "architecture.txt").read_text()
        persistence_doc = (ROOT / "docs" / "architecture.txt").read_text()
        hardware_doc = (ROOT / "docs" / "architecture.txt").read_text()

        self.assertIn("docs/proof.txt", readme)
        self.assertIn("test_post_checkpoint_gaps.py", tests_readme)
        self.assertIn("tools/check_playability_gap_ledger.py", tests_readme)
        self.assertIn("not by itself a claim that the current branch is human-playable", playable_doc)
        for claim_boundary in (
            "Nothing is missing for this exact shutdown/panic proof gate",
            "panic=KEXC",
            "shutdown=HALT",
            "shutdown=REBOOT",
            "shutdown=POWEROFF",
            "This is not a full POSIX environment",
            "passes save/load persistence",
            "persistence-proof-green",
            "DOOMSAV0.DSG",
            "25718",
            "Unknown tclass 112 in savegame",
            "savestm=",
            "savethk=",
            "Do not call the project Doom-capable",
            "fixed-slot launch/switch contract",
            "vmmhi=OK",
            "vmmhfree=",
            "not a robust",
            "full POSIX environment",
            "storage boot path",
            "check_hardware_support_matrix.py",
            "SUPPORT[...]",
            "check_human_playability_proof.py --require-human-session",
            "at least 350 Doom ticks",
            "rejects forbidden WAD/disk/pixel/raw-audio artifacts",
            "User-Facing Legitimacy Roadmap",
            "Playable now:",
            "scripted-cloud playable in the disposable QEMU proof lane",
            "playable through the repo's cloud proof lane with status-only artifacts",
            "does not yet mean a finished, general-purpose OS or a recorded human playtest bundle",
            "Next playability polish:",
            "formal remote VNC human playtest bundle for the current commit",
            "--require-human-session",
            "human audio quality notes without uploading raw Doom audio",
            "hardware-paced kernel pull/refill stream",
            "Legit general-OS milestones:",
            "non-identity higher-half contract",
            "dynamic child lifetimes",
            "real `fork`",
            "fd duplication",
            "file-backed `mmap`",
            "install/recovery and hardware support outside the current generated FAT16 image",
            "QEMU BIOS/IDE/PS2/VBE/SB16 device model",
            "machine-readable proof boundary before they become user-facing claims",
            "Post-Playable Hardware/Runtime Backlog",
            "These rows are intentionally not proof claims",
            "POST_PLAYABLE_GAP[FULL_KRELOC_OK] status=open",
            "POST_PLAYABLE_GAP[UEFI_KERNEL_HANDOFF] status=open",
            "POST_PLAYABLE_GAP[STORAGE_INSTALL_RECOVERY] status=open",
            "POST_PLAYABLE_GAP[HUMAN_PLAYTEST_BUNDLE] status=open",
            "POST_PLAYABLE_GAP[HARDWARE_PACED_AUDIO_STREAM] status=open",
            "POST_PLAYABLE_GAP[PROCESS_MODEL_LIMITS] status=open",
            "kreloc=OK",
            "krelocstep=FULL",
            "actual UEFI kernel handoff",
            "blank disk to bootable vibe-os",
            "damaged media repair-or-refuse behavior",
            "no WAD/disk/pixel/screenshot/raw-audio artifacts",
            "Payload service now arrives through command 12 / `VIBE_AUDIO_STREAM_WRITE`",
            "kernel-owned PCM stream evidence through the checker",
            "full `fork`/`exec` split",
            "teardown/reclamation evidence",
        ):
            with self.subTest(claim_boundary=claim_boundary):
                self.assertContainsPhrase(gap_doc, claim_boundary)
        self.assertIn("not a robust Unix", process_doc)
        self.assertIn("fork`/`exec` split", process_doc)
        self.assertIn("storage boot", persistence_doc)
        self.assertIn("path story", persistence_doc)
        self.assertIn("not yet a broader storage boot", persistence_doc)
        self.assertIn("SUPPORT[PHYSICAL_HARDWARE] status=unclaimed", hardware_doc)
        self.assertContainsPhrase(hardware_doc, "QEMU evidence alone can only claim")
        self.assertContainsPhrase(
            process_doc,
            "POST_PLAYABLE_GAP[PROCESS_MODEL_LIMITS]",
        )
        self.assertContainsPhrase(
            hardware_doc,
            "The actual UEFI kernel handoff remains a post-playable gap",
        )
        self.assertContainsPhrase(
            persistence_doc,
            "POST_PLAYABLE_GAP[STORAGE_INSTALL_RECOVERY]",
        )
        self.assertContainsPhrase(
            process_doc,
            "POST_PLAYABLE_GAP[FULL_KRELOC_OK]",
        )
        self.assertContainsPhrase(
            hardware_doc,
            "POST_PLAYABLE_GAP[HARDWARE_PACED_AUDIO_STREAM]",
        )

    def test_latest_cloud_evidence_tracks_run_but_not_playable_claim(self):
        gap_doc = (ROOT / "docs" / "proof.txt").read_text()

        for phrase in (
            "Latest Cloud Evidence",
            "latest full real-WAD cloud run",
            "26213330282",
            "26213233516",
            "26211510477",
            "26206176284",
            "7390468",
            "musicrend= rendered sample delta must keep pace",
            "26203744974",
            "f9a688e",
            "passes save/load persistence",
            "persistence-proof-green",
            "25718",
            "Unknown tclass 112 in savegame",
            "savestm=",
            "savethk=",
            "historical repair context",
            "human-facing Doom-capable proof",
            "26165681561",
            "c525952",
            "scripted gameplay transition",
            "26165678183",
            "26156172979",
            "eabd307",
            "audio-proof.json",
            "artifact hygiene",
            "26150621804",
            "1db3a7a",
            "usr=FAIL",
            "26149350434",
            "da9c136",
            "playability-status-green",
            "doomrun=RUN",
            "doomopen=OK",
            "doomread=OK",
            "IWAD",
            "Frame/gameplay counters are active",
            "SB16/audio counters",
            "preemption counters are active",
            "scripted `usr=OK`, `use`, mouse effect",
            "full-lane green",
            "check_audio_continuity_proof.py",
            "26149570191",
            "memset+0x20",
            "doomfaultip=01029F20",
            "audio-proof.json",
            "Stronger gameplay proof",
            "remote human playtest",
            "26146035600",
            "269dbb8",
            "FindResponseFile+0x34",
            "doomfaultip=01003224",
            "26146488906",
            "34eb98d",
            "W_AddFile+0x246",
            "doomfaultip=01024D06",
            "historical repair",
            "blocker after",
        ):
            with self.subTest(phrase=phrase):
                self.assertContainsPhrase(gap_doc, phrase)

        for phrase in (
            "The current first runtime blocker is the Ring 3 page fault",
            "until that is fixed, WAD open/read",
            "Current-head smoke status",
            "is the current scripted cloud truth-serum run for the current runtime code",
            "is the current scripted cloud proof that passes the serious real-WAD gates for the current runtime code",
            "Nothing is missing for this exact commit's scripted cloud-boot gate",
            "Nothing is missing for this exact commit's scripted real-gameplay gate",
        ):
            with self.subTest(stale_phrase=phrase):
                self.assertNotIn(phrase, gap_doc)

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
        self.assertEqual(
            {gap_id: gap["status"] for gap_id, gap in gaps.items()},
            {
                "CLOUD_BOOT": "proven",
                "REAL_GAMEPLAY": "proven",
                "HUMAN_PLAYTEST": "open",
                "PERSISTENCE": "proven",
                "AUDIO": "proven",
                "VM_POSIX": "open",
                "SHUTDOWN_PANIC": "proven",
                "HARDWARE_LIMITS": "open",
            },
        )
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

    def test_post_playable_backlog_rows_are_machine_readable(self):
        rows = check_playability_gap_ledger.validate_post_playable_backlog(ROOT)

        self.assertEqual(
            set(rows),
            {
                "FULL_KRELOC_OK",
                "UEFI_KERNEL_HANDOFF",
                "STORAGE_INSTALL_RECOVERY",
                "HUMAN_PLAYTEST_BUNDLE",
                "HARDWARE_PACED_AUDIO_STREAM",
                "PROCESS_MODEL_LIMITS",
            },
        )
        self.assertEqual({row["status"] for row in rows.values()}, {"open"})
        self.assertEqual(
            {row_id: row["category"] for row_id, row in rows.items()},
            {
                "FULL_KRELOC_OK": "runtime-relocation",
                "UEFI_KERNEL_HANDOFF": "uefi-handoff",
                "STORAGE_INSTALL_RECOVERY": "storage-install-recovery",
                "HUMAN_PLAYTEST_BUNDLE": "human-playtest",
                "HARDWARE_PACED_AUDIO_STREAM": "audio-runtime",
                "PROCESS_MODEL_LIMITS": "process-model",
            },
        )
        self.assertEqual(
            {row_id: row["gate"] for row_id, row in rows.items()},
            {
                "FULL_KRELOC_OK": "vm-status-kreloc-full",
                "UEFI_KERNEL_HANDOFF": "ovmf-kernel-entry-proof",
                "STORAGE_INSTALL_RECOVERY": "installer-recovery-proof",
                "HUMAN_PLAYTEST_BUNDLE": "human-playtest-bundle-review",
                "HARDWARE_PACED_AUDIO_STREAM": "kernel-owned-audio-stream-proof",
                "PROCESS_MODEL_LIMITS": "process-model-expansion-proof",
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
