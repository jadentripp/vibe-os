import importlib.util
import gzip
import subprocess
import tarfile
import tempfile
import unittest
import zipfile
from pathlib import Path
from unittest import mock


ROOT = Path(__file__).resolve().parents[2]
TOOL = ROOT / "tools" / "check_repo_hygiene.py"
spec = importlib.util.spec_from_file_location("check_repo_hygiene", TOOL)
check_repo_hygiene = importlib.util.module_from_spec(spec)
spec.loader.exec_module(check_repo_hygiene)


class RepoHygieneTests(unittest.TestCase):
    def test_current_repo_hygiene_check_passes(self):
        result = subprocess.run(
            ["python3", "tools/check_repo_hygiene.py"],
            cwd=ROOT,
            capture_output=True,
            text=True,
            check=False,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("pristine Doom vendor tree", result.stdout)
        self.assertIn("forbidden uploads", result.stdout)
        self.assertIn("token-shaped secrets", result.stdout)

    def test_pristine_doom_policy_is_machine_checked(self):
        self.assertEqual(check_repo_hygiene.UPSTREAM_COMMIT, "a77dfb96cb91780ca334d0d4cfd86957558007e0")
        self.assertEqual(check_repo_hygiene.UPSTREAM_TREE_FILE_COUNT, 126)
        self.assertEqual(
            check_repo_hygiene.upstream_tree_sha256(),
            "38ef8b80b6848e934c72d27cbbfa013c1e184544e9ddb6f100c4a15e565e3b83",
        )
        self.assertEqual(check_repo_hygiene.UPSTREAM_IMPORTED_TREE_FILE_COUNT, 165)
        self.assertEqual(
            check_repo_hygiene.upstream_imported_tree_sha256(),
            "7778ac7309e54a25199338402f488c806f625f57b7d774359bf2ff5440aa6e66",
        )
        self.assertEqual(check_repo_hygiene.vendor_policy_violations(), [])

    def test_tracked_artifact_patterns_cover_wads_images_audio_and_pixels(self):
        forbidden_paths = (
            "DOOM1.WAD",
            "assets/shareware.iwad",
            "assets/shareware.wad.gz",
            "assets/doom1.wad.zip",
            "assets/doom1.pwad.tar.gz",
            "build/disk.img",
            "build/disk.vdi",
            "build/disk.vmdk",
            "build/disk.vhdx",
            "build/disk.dsk",
            "proofs/frame.ppm",
            "proofs/screenshot.jpg",
            "proofs/frame.tiff",
            "proofs/frame.rgba",
            "proofs/pixels/frame.txt",
            "capture/doom-audio.wav",
            "capture/doom-audio.pcm",
            "capture/doom-audio.caf",
            "capture/sfx.raw",
            "capture/music.opus",
            "capture/music.m4a",
            "music/e1m1.mid",
            "music/d_intro.mus",
            "music/doom.sf2",
            "music/tracker.mod",
        )
        for path in forbidden_paths:
            with self.subTest(path=path):
                self.assertTrue(
                    check_repo_hygiene.path_matches(
                        path,
                        check_repo_hygiene.FORBIDDEN_PATH_PATTERNS,
                    )
                )

    def test_disguised_wad_magic_is_rejected(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            (root / "notes").mkdir()
            (root / "notes" / "proof.dat").write_bytes(b"placeholder")
            with (
                mock.patch.object(check_repo_hygiene, "ROOT", root),
                mock.patch.object(check_repo_hygiene, "read_file_prefix", return_value=b"IWAD\x00\x00"),
            ):
                violations = check_repo_hygiene.find_violations(["notes/proof.dat"])
        self.assertEqual(
            violations,
            ["notes/proof.dat: WAD/IWAD payload is tracked under a non-WAD extension"],
        )

    def test_deleted_tracked_paths_are_ignored_during_worktree_checks(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            with mock.patch.object(check_repo_hygiene, "ROOT", root):
                violations = check_repo_hygiene.find_violations(["docs/deleted.md"])
        self.assertEqual(violations, [])

    def test_disguised_compressed_wad_payloads_are_rejected(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            (root / "proof-gzip.dat").write_bytes(gzip.compress(b"IWAD\x00\x00\x00\x00"))
            with zipfile.ZipFile(root / "proof-zip.bundle", "w") as archive:
                archive.writestr("renamed.dat", b"PWAD\x00\x00\x00\x00")
            with tarfile.open(root / "proof-tar.bundle", "w") as archive:
                wad_path = root / "DOOM1.WAD"
                wad_path.write_bytes(b"not-real-game-data")
                archive.add(wad_path, arcname="nested/DOOM1.WAD")

            with mock.patch.object(check_repo_hygiene, "ROOT", root):
                violations = check_repo_hygiene.find_violations(
                    ["proof-gzip.dat", "proof-zip.bundle", "proof-tar.bundle"]
                )

        self.assertEqual(
            violations,
            [
                "proof-gzip.dat: gzip-compressed WAD/IWAD payload is tracked under a non-WAD extension",
                "proof-zip.bundle: archive member 'renamed.dat' contains WAD/PWAD payload",
                "proof-tar.bundle: tar archive member 'nested/DOOM1.WAD' is a WAD path",
            ],
        )

    def test_secret_scan_rejects_tokens_codespaces_env_and_browser_codes(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            classic_token = "ghp_" + ("A" * 36)
            fine_grained_token = "github_pat_" + ("B" * 22) + "_" + ("C" * 59)
            codespaces_token = "GITHUB_CODESPACES_TOKEN=" + ("D" * 32)
            browser_code = "Copy your one-time browser code: " + "ABCD" + "-1234"
            (root / "notes.txt").write_text(
                "\n".join(
                    [
                        f"token={classic_token}",
                        f"fine_grained={fine_grained_token}",
                        codespaces_token,
                    ]
                )
            )
            (root / "browser-auth.txt").write_text(browser_code)

            with mock.patch.object(check_repo_hygiene, "ROOT", root):
                violations = check_repo_hygiene.find_violations(["notes.txt", "browser-auth.txt"])

        self.assertTrue(any("GitHub token-shaped string" in violation for violation in violations))
        self.assertTrue(
            any("GitHub fine-grained token-shaped string" in violation for violation in violations)
        )
        self.assertTrue(any("Codespaces environment leak" in violation for violation in violations))
        self.assertTrue(any("one-time browser auth code" in violation for violation in violations))

    def test_secret_scan_allows_placeholders_and_explicit_false_positives(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            example_token = "ghp_" + ("E" * 36)
            (root / "examples.md").write_text(
                "\n".join(
                    [
                        "GITHUB_TOKEN=${{ secrets.GITHUB_TOKEN }}",
                        "Authorization: Bearer [redacted]",
                        "Copy your one-time browser code: <browser-code>",
                        f"example literal {example_token}  # repo-hygiene: allow-secret-example",
                        r"regex fixture: gh[pousr]_[A-Za-z0-9_]{36,}",
                    ]
                )
            )

            with mock.patch.object(check_repo_hygiene, "ROOT", root):
                violations = check_repo_hygiene.find_violations(["examples.md"])

        self.assertEqual(violations, [])

    def test_secret_patterns_do_not_flag_checker_or_redaction_regexes(self):
        paths = (
            "tools/check_repo_hygiene.py",
            "tools/collect_human_playtest_bundle.py",
            "tools/play_now_remote.sh",
        )
        for path in paths:
            with self.subTest(path=path):
                text = (ROOT / path).read_text(errors="ignore")
                self.assertEqual(check_repo_hygiene.secret_content_violations(path, text), [])

    def test_imported_vendor_manifest_rejects_extra_tracked_vendor_files(self):
        tracked = check_repo_hygiene.tracked_files() + [
            "third_party/doom/linuxdoom-1.10/vibe_os_port.c",
        ]
        with mock.patch.object(check_repo_hygiene, "tracked_files", return_value=tracked):
            violations = check_repo_hygiene.vendor_policy_violations()
        self.assertTrue(
            any("imported upstream tree has" in violation for violation in violations),
            violations,
        )
        self.assertTrue(
            any("imported upstream tree hash" in violation for violation in violations),
            violations,
        )

    def test_gitignore_covers_common_forbidden_artifact_spillover(self):
        ignored = {
            line.strip()
            for line in (ROOT / ".gitignore").read_text().splitlines()
            if line.strip() and not line.lstrip().startswith("#")
        }
        for pattern in (
            "*.[Ww][Aa][Dd].gz",
            "*.[Ii][Ww][Aa][Dd].gz",
            "*.[Pp][Ww][Aa][Dd].gz",
            "*.[Ww][Aa][Dd].zip",
            "*.[Ii][Ww][Aa][Dd].zip",
            "*.[Pp][Ww][Aa][Dd].zip",
            "*.[Ww][Aa][Dd].tar.gz",
            "*.[Ii][Ww][Aa][Dd].tar.gz",
            "*.[Pp][Ww][Aa][Dd].tar.gz",
            "*.dsk",
            "*.ima",
            "*.vdi",
            "*.vmdk",
            "*.vhd",
            "*.vhdx",
            "*.dmg",
            "*.qcow",
            "*.wav",
            "*.wave",
            "*.pcm",
            "*.mp3",
            "*.ogg",
            "*.oga",
            "*.opus",
            "*.m4a",
            "*.aac",
            "*.wma",
            "*.flac",
            "*.aiff",
            "*.aif",
            "*.au",
            "*.snd",
            "*.caf",
            "*.mid",
            "*.midi",
            "*.mus",
            "*.sf2",
            "*.sf3",
            "*.voc",
            "*.mod",
            "*.s3m",
            "*.xm",
            "*.it",
            "*.jpg",
            "*.jpeg",
            "*.webp",
            "*.gif",
            "*.tif",
            "*.tiff",
            "*.tga",
            "*.xpm",
            "*.rgb",
            "*.rgba",
            "screenshots/",
            "pixels/",
            "screenshot*.txt",
            "pixel*.txt",
        ):
            with self.subTest(pattern=pattern):
                self.assertIn(pattern, ignored)

    def test_upload_path_parser_reads_multiline_artifact_paths(self):
        workflow = """
name: proof
jobs:
  test:
    steps:
      - name: Upload diagnostics
        uses: actions/upload-artifact@v4
        with:
          name: proof
          path: |
            build/status*.txt
            build/doom.symbols
            build/*.log
"""
        self.assertEqual(
            check_repo_hygiene.upload_path_lines(workflow),
            ["build/status*.txt", "build/doom.symbols", "build/*.log"],
        )

    def test_real_wad_workflow_uploads_reject_assets_images_audio_and_pixels(self):
        workflow = """
name: Real WAD smoke
jobs:
  test:
    env:
      WAD_PATH: /tmp/DOOM1.WAD
    steps:
      - uses: actions/upload-artifact@v4
        with:
          path: |
            build/status*.txt
            build/disk.img
            build/gfx.bin
            build/doom-audio.wav
            build/shareware.wad.zip
            build/persistence-*/*.bin
"""
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            workflow_path = root / ".github" / "workflows" / "real-wad-smoke.yml"
            workflow_path.parent.mkdir(parents=True)
            workflow_path.write_text(workflow)
            with mock.patch.object(check_repo_hygiene, "ROOT", root):
                violations = check_repo_hygiene.workflow_upload_violations(
                    [".github/workflows/real-wad-smoke.yml"]
                )

        self.assertEqual(len(violations), 5)
        self.assertTrue(any("build/disk.img" in violation for violation in violations))
        self.assertTrue(any("build/gfx.bin" in violation for violation in violations))
        self.assertTrue(any("build/doom-audio.wav" in violation for violation in violations))
        self.assertTrue(any("build/shareware.wad.zip" in violation for violation in violations))
        self.assertTrue(any("build/persistence-*/*.bin" in violation for violation in violations))

    def test_real_wad_workflow_uploads_are_allowlisted(self):
        workflow = """
name: Real WAD smoke
jobs:
  test:
    env:
      EXPECTED_WAD_SHA1: 5b2e249b9c5133ec987b3ea77596381dc0d6bc1d
    steps:
      - uses: actions/upload-artifact@v4
        with:
          path: |
            build/status*.txt
            build/doom.symbols
            build/persistence-write/save-proof.json
            build/persistence-write/smoke.log
            build/evidence.tar
"""
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            workflow_path = root / ".github" / "workflows" / "real-wad-smoke.yml"
            workflow_path.parent.mkdir(parents=True)
            workflow_path.write_text(workflow)
            with mock.patch.object(check_repo_hygiene, "ROOT", root):
                violations = check_repo_hygiene.workflow_upload_violations(
                    [".github/workflows/real-wad-smoke.yml"]
                )

        self.assertEqual(
            violations,
            [
                ".github/workflows/real-wad-smoke.yml: real-WAD upload path "
                "'build/evidence.tar' is not in the status/log/ELF/symbol/JSON "
                "diagnostic allowlist"
            ],
        )

    def test_real_wad_soak_json_metadata_upload_is_allowlisted(self):
        workflow = """
name: Real WAD soak
jobs:
  soak:
    env:
      WAD_PATH: /tmp/DOOM1.WAD
    steps:
      - uses: actions/upload-artifact@v4
        with:
          path: ${{ runner.temp }}/real-wad-soak/*.json
"""
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            workflow_path = root / ".github" / "workflows" / "real-wad-soak.yml"
            workflow_path.parent.mkdir(parents=True)
            workflow_path.write_text(workflow)
            with mock.patch.object(check_repo_hygiene, "ROOT", root):
                violations = check_repo_hygiene.workflow_upload_violations(
                    [".github/workflows/real-wad-soak.yml"]
                )

        self.assertEqual(violations, [])

    def test_current_workflow_uploads_do_not_include_forbidden_real_wad_payloads(self):
        workflows = [
            ".github/workflows/os-smoke.yml",
            ".github/workflows/real-wad-smoke.yml",
            ".github/workflows/real-wad-soak.yml",
        ]
        self.assertEqual(check_repo_hygiene.workflow_upload_violations(workflows), [])

    def test_real_wad_workflow_mirrors_persistence_phase_text_to_status_uploads(self):
        workflow = (ROOT / ".github" / "workflows" / "real-wad-smoke.yml").read_text()
        self.assertIn("triage_file=\"${file%.txt}.triage.txt\"", workflow)
        self.assertIn("python3 tools/triage_cloud_status.py \"$file\" | tee \"$triage_file\"", workflow)
        self.assertIn("cp \"$file\" \"build/status.${phase}.${name}\"", workflow)
        self.assertIn("build/status*.txt", workflow)
        self.assertNotIn("build/persistence-*/*.txt", check_repo_hygiene.upload_path_lines(workflow))

    def test_docs_keep_legit_but_playable_first_positioning(self):
        readme = " ".join((ROOT / "README.md").read_text().split())
        provenance = " ".join((ROOT / "docs" / "doom-provenance.md").read_text().split())
        runtime = " ".join((ROOT / "docs" / "doom-libc-runtime.md").read_text().split())

        for text, token in (
            (readme, '"legit but playable first"'),
            (readme, "official id Software public release"),
            (readme, "disposable remote run"),
            (provenance, '"legit but playable first"'),
            (provenance, "original Doom engine drop stays original"),
            (provenance, "keep proprietary game data and rendered proof assets out of git"),
            (provenance, "renamed raw WAD payloads plus gzip, zip, and tar containers"),
            (runtime, "Compressed WAD archives"),
            (runtime, "are treated as game assets too."),
        ):
            with self.subTest(token=token):
                self.assertIn(token, text)

    def test_top_level_readme_stays_concise_claim_surface(self):
        violations = check_repo_hygiene.readme_policy_violations(ROOT)
        self.assertEqual(violations, [])

    def test_top_level_readme_policy_rejects_task_lists_and_proof_ledgers(self):
        readme = "\n".join(
            [
                "# vibe-os",
                "",
                "Concise claim surface.",
                "",
                "TODO: paste the latest cloud result here.",
                "Checklist for the release proof:",
                "- [ ] rerun cloud smoke before release",
                "- Latest proof commit abcdef0123456789abcdef0123456789abcdef01",
                "- scripted_proof_run_id=26156172979",
                "- GAP[PLAYABLE]: collect phase_hash_after_fire evidence",
                "- This is a Doom-capable OS and fully playable on real hardware.",
            ]
        )
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            (root / "README.md").write_text(readme)
            violations = check_repo_hygiene.readme_policy_violations(root)

        self.assertTrue(any("task-list checkbox" in violation for violation in violations))
        self.assertTrue(any("TODO/checklist language" in violation for violation in violations))
        self.assertTrue(any("commit hash" in violation for violation in violations))
        self.assertTrue(any("run ID" in violation for violation in violations))
        self.assertTrue(any("gap ledger row" in violation for violation in violations))
        self.assertTrue(any("proof transcript field" in violation for violation in violations))
        self.assertTrue(any("overclaiming phrase" in violation for violation in violations))

    def test_detailed_docs_may_retain_exact_source_evidence(self):
        provenance = (ROOT / "docs" / "doom-provenance.md").read_text()
        self.assertIn(check_repo_hygiene.UPSTREAM_COMMIT, provenance)


if __name__ == "__main__":
    unittest.main()
