import os
import subprocess
import tempfile
import textwrap
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


class PlayNowRemoteTests(unittest.TestCase):
    def _write_stub_tool(self, directory, name, body):
        path = Path(directory) / name
        path.write_text(body)
        path.chmod(0o755)
        return path

    def _codespaces_stub_env(self, tmp, git_mode="clean"):
        bin_dir = Path(tmp) / "bin"
        bin_dir.mkdir()
        gh_log = Path(tmp) / "gh.log"
        self._write_stub_tool(
            bin_dir,
            "gh",
            textwrap.dedent(
                """\
                #!/usr/bin/env bash
                set -euo pipefail
                echo "$*" >> "$GH_LOG"
                if [ "$1" = "auth" ] && [ "$2" = "status" ]; then
                  exit 0
                fi
                echo "unexpected gh command: $*" >&2
                exit 64
                """
            ),
        )
        self._write_stub_tool(
            bin_dir,
            "git",
            textwrap.dedent(
                """\
                #!/usr/bin/env bash
                set -euo pipefail
                mode="${FAKE_GIT_MODE:-clean}"
                case "$*" in
                  "rev-parse --is-inside-work-tree")
                    exit 0
                    ;;
                  "branch --show-current")
                    echo "jt/doom-gameplay-proof"
                    exit 0
                    ;;
                  "status --porcelain=v1 --untracked-files=all")
                    if [ "$mode" = "dirty" ]; then
                      echo " M tools/play_now_codespaces.sh"
                    fi
                    exit 0
                    ;;
                  "rev-parse --abbrev-ref --symbolic-full-name @{u}")
                    echo "origin/jt/doom-gameplay-proof"
                    exit 0
                    ;;
                  "rev-list --left-right --count origin/jt/doom-gameplay-proof...HEAD")
                    if [ "$mode" = "ahead" ]; then
                      echo "0 2"
                    else
                      echo "0 0"
                    fi
                    exit 0
                    ;;
                esac
                echo "unexpected git command: $*" >&2
                exit 64
                """
            ),
        )
        env = os.environ.copy()
        env.update(
            {
                "PATH": f"{bin_dir}{os.pathsep}{env['PATH']}",
                "GH_LOG": str(gh_log),
                "FAKE_GIT_MODE": git_mode,
            }
        )
        return env, gh_log

    def test_codespaces_launcher_is_one_command_and_mac_safe(self):
        script = (ROOT / "tools" / "play_now_codespaces.sh").read_text()
        docs = [
            (ROOT / "README.md").read_text(),
            (ROOT / "docs" / "runbooks" / "play-now-cloud.md").read_text(),
            (ROOT / "docs" / "runbooks" / "codespaces-play-now.md").read_text(),
        ]

        for needle in (
            "Usage: tools/play_now_codespaces.sh [options]",
            "codespace create",
            "gh \"${create_args[@]}\"",
            "--devcontainer-path \".devcontainer/devcontainer.json\"",
            "--idle-timeout \"$IDLE_TIMEOUT\"",
            "--retention-period \"$RETENTION_PERIOD\"",
            "--preflight, --dry-run",
            "require_clean_pushed_git_state",
            "local git working tree is dirty",
            "differs from upstream",
            "play-now Codespaces preflight OK",
            "machine: ${CODESPACE_MACHINE:-default}",
            "noVNC port: $NOVNC_PORT (private)",
            "dry-run: Codespace was not created or modified",
            "gh codespace ssh -c \"$CODESPACE_NAME\" -- env VIBE_PLAY_REF=\"$REF\" bash -lc \"$payload\"",
            "./tools/play_now_remote.sh --preflight",
            "nohup ./tools/play_now_remote.sh",
            "gh codespace ports visibility \"$NOVNC_PORT:private\"",
            "gh codespace ports",
            "vnc.html?autoconnect=1",
            "Delete when done: gh codespace delete -c \\\"$CODESPACE_NAME\\\" --force",
            "Codespaces runs pushed git state",
        ):
            with self.subTest(needle=needle):
                self.assertIn(needle, script)

        for forbidden in (
            "qemu-system-x86_64",
            "make DOOM_WAD",
            "prepare_shareware_wad.py",
            "gh codespace cp",
            "scp ",
            "build/disk.img",
            "DOOM1.WAD",
            "doom-audio.wav",
            "git add",
        ):
            with self.subTest(forbidden=forbidden):
                self.assertNotIn(forbidden, script)

        self.assertTrue((ROOT / "tools" / "play_now_codespaces.sh").stat().st_mode & 0o111)
        for doc in docs:
            self.assertIn("./tools/play_now_codespaces.sh", doc)
            self.assertIn("disposable", doc)
            self.assertIn("Codespace", doc)

    def test_codespaces_launcher_dry_run_does_not_create_or_mutate_codespaces(self):
        with tempfile.TemporaryDirectory() as tmp:
            env, gh_log = self._codespaces_stub_env(tmp)
            result = subprocess.run(
                [
                    "bash",
                    str(ROOT / "tools" / "play_now_codespaces.sh"),
                    "--dry-run",
                    "--repo",
                    "jadentripp/vibe-os",
                    "--ref",
                    "jt/doom-gameplay-proof",
                    "--machine",
                    "basicLinux32gb",
                    "--no-open",
                ],
                cwd=ROOT,
                env=env,
                capture_output=True,
                text=True,
            )

            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("play-now Codespaces preflight OK", result.stdout)
            self.assertIn("repo: jadentripp/vibe-os", result.stdout)
            self.assertIn("ref: jt/doom-gameplay-proof", result.stdout)
            self.assertIn("machine: basicLinux32gb", result.stdout)
            self.assertIn("noVNC port: 6080 (private)", result.stdout)
            self.assertIn("dry-run: Codespace was not created or modified", result.stdout)
            self.assertEqual(result.stderr, "")

            log = gh_log.read_text()
            self.assertIn("auth status -h github.com", log)
            self.assertNotIn("codespace create", log)
            self.assertNotIn("codespace ssh", log)
            self.assertNotIn("codespace ports", log)

    def test_codespaces_launcher_refuses_dirty_or_unpushed_state_before_codespaces(self):
        for mode, message in (
            ("dirty", "local git working tree is dirty"),
            ("ahead", "differs from upstream"),
        ):
            with self.subTest(mode=mode), tempfile.TemporaryDirectory() as tmp:
                env, gh_log = self._codespaces_stub_env(tmp, git_mode=mode)
                result = subprocess.run(
                    [
                        "bash",
                        str(ROOT / "tools" / "play_now_codespaces.sh"),
                        "--dry-run",
                        "--repo",
                        "jadentripp/vibe-os",
                        "--ref",
                        "jt/doom-gameplay-proof",
                    ],
                    cwd=ROOT,
                    env=env,
                    capture_output=True,
                    text=True,
                )

                self.assertEqual(result.returncode, 1)
                self.assertIn(message, result.stderr)
                log = gh_log.read_text()
                self.assertNotIn("codespace create", log)
                self.assertNotIn("codespace ssh", log)

    def test_play_now_script_is_remote_first_and_repo_safe(self):
        script = (ROOT / "tools" / "play_now_remote.sh").read_text()
        doc = (ROOT / "docs" / "runbooks" / "play-now-cloud.md").read_text()

        for needle in (
            'Usage: tools/play_now_remote.sh [--preflight|--dry-run]',
            '--preflight|--dry-run',
            'uname -s',
            'Refusing to run QEMU on macOS',
            'ALLOW_LOCAL_VM:-0',
            'python3 tools/check_play_now_remote.py',
            'if [ "$RUN_PREFLIGHT_ONLY" = "1" ]; then',
            '/tmp/vibe-os-DOOM1.WAD',
            'tools/prepare_shareware_wad.py',
            'make DOOM_WAD="$WAD_PATH"',
            'websockify --web=/usr/share/novnc',
            '/vnc.html?autoconnect=1',
            'codespaces_novnc_url()',
            'Codespaces noVNC URL:',
            '-display "vnc=127.0.0.1:$VNC_DISPLAY"',
            '-drive file=build/disk.img,format=raw,if=ide,index=0,media=disk',
            '-audiodev none,id=snd0',
            '-device sb16,audiodev=snd0',
        ):
            with self.subTest(needle=needle):
                self.assertIn(needle, script)

        for forbidden in (
            'git add',
            'actions/upload-artifact',
            'build/gfx.bin',
            'build/doom-audio.wav',
        ):
            with self.subTest(forbidden=forbidden):
                self.assertNotIn(forbidden, script)

        for needle in (
            'Fastest safe path',
            'GitHub Codespaces',
            'forward port',
            'VNC does not carry game audio',
            'cloud `real-wad-smoke.yml` aggregate audio proof',
        ):
            with self.subTest(needle=needle):
                self.assertIn(needle, doc)

    def test_runbooks_do_not_document_local_mac_vm_override(self):
        for runbook in (
            "play-now-cloud.md",
            "codespaces-play-now.md",
            "cloud-interactive-playtest.md",
        ):
            text = (ROOT / "docs" / "runbooks" / runbook).read_text()
            with self.subTest(runbook=runbook):
                self.assertNotIn("ALLOW_LOCAL_VM=1", text)
                self.assertNotIn("brew install qemu", text)


if __name__ == "__main__":
    unittest.main()
