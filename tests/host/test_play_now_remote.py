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
        git_log = Path(tmp) / "git.log"
        self._write_stub_tool(
            bin_dir,
            "gh",
            textwrap.dedent(
                """\
                #!/usr/bin/env bash
                set -euo pipefail
                echo "$*" >> "$GH_LOG"
                if [ "$1" = "auth" ] && [ "$2" = "status" ]; then
                  if [ "${FAKE_GH_AUTH_FAIL:-0}" = "1" ]; then
                    echo "not logged in" >&2
                    exit 1
                  fi
                  exit 0
                fi
                if [ "$1" = "repo" ] && [ "$2" = "view" ]; then
                  if [ "${FAKE_REPO_MISSING:-0}" = "1" ]; then
                    echo "repository not found" >&2
                    exit 1
                  fi
                  echo "jadentripp/vibe-os"
                  exit 0
                fi
                if [ "$1" = "api" ] && [[ "$*" == *"/repos/jadentripp/vibe-os"* ]] && [[ "$*" != *"/contents/"* ]]; then
                  if [ "${FAKE_REPO_ID_FAIL:-0}" = "1" ]; then
                    echo '{"message":"API rate limit exceeded","status":"403"}'
                    exit 1
                  fi
                  echo "${FAKE_REPO_DATABASE_ID:-123456789}"
                  exit 0
                fi
                if [ "$1" = "api" ] && [[ "$*" == *"/repos/jadentripp/vibe-os/contents/"* ]]; then
                  if [ "${FAKE_PLAY_PAYLOAD_MISSING:-0}" = "1" ]; then
                    echo "missing play payload" >&2
                    exit 69
                  fi
                  echo '{"type":"file"}'
                  exit 0
                fi
                if [ "$1" = "api" ] && [[ "$*" == *"/user/codespaces?per_page=1"* ]]; then
                  if [ "${FAKE_CODESPACE_SCOPE_FAIL:-0}" = "1" ]; then
                    echo "missing codespace scope" >&2
                    exit 68
                  fi
                  echo '{"total_count":0,"codespaces":[]}'
                  exit 0
                fi
                if [ "$1" = "codespace" ] && [ "${2:-}" = "create" ]; then
                  exit 0
                fi
                if [ "$1" = "codespace" ] && [ "${2:-}" = "list" ]; then
                  echo "${FAKE_CODESPACE_NAME:-vibe-play-created}"
                  exit 0
                fi
                if [ "$1" = "codespace" ] && [ "${2:-}" = "ssh" ]; then
                  expected_port="${EXPECTED_NOVNC_PORT:-6080}"
                  case "$*" in
                    *"NOVNC_PORT=$expected_port"*)
                      exit 0
                      ;;
                  esac
                  echo "missing expected NOVNC_PORT=$expected_port in ssh command: $*" >&2
                  exit 65
                fi
                if [ "$1" = "codespace" ] && [ "${2:-}" = "ports" ] && [ "${3:-}" = "visibility" ]; then
                  if [ "${FAKE_VISIBILITY_FAIL:-0}" = "1" ]; then
                    echo "visibility failed" >&2
                    exit 66
                  fi
                  exit 0
                fi
                if [ "$1" = "codespace" ] && [ "${2:-}" = "ports" ]; then
                  expected_port="${EXPECTED_NOVNC_PORT:-6080}"
                  case "$*" in
                    *"sourcePort == $expected_port"*)
                      printf '%s\\n' "${FAKE_BROWSE_URL:-https://vibe-play-${expected_port}.app.github.dev/}"
                      exit 0
                      ;;
                  esac
                  echo "unexpected noVNC port query: $*" >&2
                  exit 67
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
                echo "$*" >> "$GIT_LOG"
                mode="${FAKE_GIT_MODE:-clean}"
                if [ "$1" = "ls-remote" ]; then
                  if [ "${FAKE_REF_MISSING:-0}" = "1" ]; then
                    exit 2
                  fi
                  ref="${@: -1}"
                  printf '0123456789abcdef0123456789abcdef01234567\\trefs/heads/%s\\n' "$ref"
                  exit 0
                fi
                if [ "$1" = "check-ref-format" ] && [ "${2:-}" = "--branch" ]; then
                  ref="${@: -1}"
                  case "$ref" in
                    *..*|*@{*|*\\\\*|*~*|*^*|*:*|*\\?*|*\\**|*\\[*|refs/*|-*|*' '*|*$'\\t'*)
                      exit 1
                      ;;
                  esac
                  printf '%s\\n' "$ref"
                  exit 0
                fi
                if [ "$1" = "init" ]; then
                  exit 0
                fi
                if [ "$1" = "remote" ] && [ "${2:-}" = "add" ]; then
                  exit 0
                fi
                if [ "$1" = "remote" ] && [ "${2:-}" = "get-url" ]; then
                  echo "https://github.com/jadentripp/vibe-os.git"
                  exit 0
                fi
                if [ "$1" = "fetch" ]; then
                  if [ "${FAKE_REF_MISSING:-0}" = "1" ]; then
                    exit 2
                  fi
                  exit 0
                fi
                if [ "$1" = "cat-file" ] && [ "${2:-}" = "-e" ]; then
                  if [ "${FAKE_PLAY_PAYLOAD_MISSING:-0}" = "1" ]; then
                    exit 69
                  fi
                  exit 0
                fi
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
                "GIT_LOG": str(git_log),
                "FAKE_GIT_MODE": git_mode,
            }
        )
        return env, gh_log, git_log

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
            "--web-url",
            "require_clean_pushed_git_state",
            "git check-ref-format --branch",
            "validate_codespace_name",
            "local git working tree is dirty",
            "differs from upstream",
            "print_web_fallback_hint",
            "codespaces_create_url",
            "play-now Codespaces preflight OK",
            "machine: ${CODESPACE_MACHINE:-default}",
            "noVNC port: $NOVNC_PORT (private)",
            "GitHub Codespaces API: accessible",
            "GitHub repo/ref: verified",
            "remote play payload: verified on selected ref",
            "local gh Codespaces API: not required for this browser path",
            "local gh auth: optional for this browser path",
            "explicit GitHub repo/ref selected; local checkout dirt is ignored",
            "clean and pushed for the inferred current branch",
            "local artifact transfer: none",
            "dry-run: Codespace was not created or modified",
            "remote_start_payload | gh codespace ssh -c \"$CODESPACE_NAME\" -- env VIBE_PLAY_REF=\"$REF\" NOVNC_PORT=\"$NOVNC_PORT\" bash -s",
            "./tools/play_now_remote.sh --preflight",
            "NOVNC_PORT=$NOVNC_PORT nohup ./tools/play_now_remote.sh",
            "gh codespace ports visibility \"$NOVNC_PORT:private\"",
            "gh codespace ports",
            "vnc.html?autoconnect=1",
            ".devcontainer/play-now-welcome.sh",
            "Makefile",
            "tools/play_now_cloud_shell.sh",
            "tools/prepare_shareware_wad.py",
            "tools/make_wad_image.py",
            "Delete when done: gh codespace delete -c \\\"$CODESPACE_NAME\\\" --force",
            "Codespaces runs pushed git state",
        ):
            with self.subTest(needle=needle):
                self.assertIn(needle, script)

        for forbidden in (
            "qemu-system-x86_64",
            "make DOOM_WAD",
            "python3 tools/prepare_shareware_wad.py",
            "gh codespace cp",
            "scp ",
            "bash -lc \"$payload\"",
            "build/disk.img",
            "DOOM1.WAD",
            "doom-audio.wav",
            "git add",
        ):
            with self.subTest(forbidden=forbidden):
                self.assertNotIn(forbidden, script)

        self.assertTrue((ROOT / "tools" / "play_now_codespaces.sh").stat().st_mode & 0o111)
        self.assertTrue((ROOT / "tools" / "play_now_cloud_shell.sh").stat().st_mode & 0o111)
        self.assertTrue((ROOT / ".devcontainer" / "play-now-welcome.sh").stat().st_mode & 0o111)
        devcontainer = (ROOT / ".devcontainer" / "devcontainer.json").read_text()
        self.assertIn('"postAttachCommand": ".devcontainer/play-now-welcome.sh"', devcontainer)
        for doc in docs:
            self.assertIn("./tools/play_now_codespaces.sh", doc)
            self.assertIn("--web-url", doc)
            self.assertIn("disposable", doc)
            self.assertIn("Codespace", doc)

    def test_codespaces_launcher_dry_run_does_not_create_or_mutate_codespaces(self):
        with tempfile.TemporaryDirectory() as tmp:
            env, gh_log, git_log = self._codespaces_stub_env(tmp)
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
            self.assertIn("GitHub repo/ref: verified", result.stdout)
            self.assertIn("remote play payload: verified on selected ref", result.stdout)
            self.assertIn("git state: explicit GitHub repo/ref selected; local checkout dirt is ignored", result.stdout)
            self.assertIn("local artifact transfer: none", result.stdout)
            self.assertIn("dry-run: Codespace was not created or modified", result.stdout)
            self.assertEqual(result.stderr, "")

            log = gh_log.read_text()
            self.assertIn("auth status -h github.com", log)
            self.assertIn("api -H Accept: application/vnd.github+json /repos/jadentripp/vibe-os --jq .id", log)
            self.assertIn("api -H Accept: application/vnd.github+json /user/codespaces?per_page=1", log)
            self.assertNotIn("codespace create", log)
            self.assertNotIn("codespace ssh", log)
            self.assertNotIn("codespace ports", log)
            git_calls = git_log.read_text()
            self.assertIn("ls-remote --heads https://github.com/jadentripp/vibe-os.git jt/doom-gameplay-proof", git_calls)
            self.assertIn("fetch --depth=1 --filter=blob:none origin refs/heads/jt/doom-gameplay-proof", git_calls)
            self.assertIn("cat-file -e FETCH_HEAD:.devcontainer/devcontainer.json", git_calls)
            self.assertIn("cat-file -e FETCH_HEAD:Makefile", git_calls)
            self.assertIn("cat-file -e FETCH_HEAD:tools/play_now_remote.sh", git_calls)
            self.assertIn("cat-file -e FETCH_HEAD:tools/prepare_shareware_wad.py", git_calls)
            self.assertIn("cat-file -e FETCH_HEAD:tools/make_wad_image.py", git_calls)

    def test_codespaces_launcher_web_url_mode_does_not_need_codespaces_api_scope(self):
        with tempfile.TemporaryDirectory() as tmp:
            env, gh_log, git_log = self._codespaces_stub_env(tmp)
            env["FAKE_CODESPACE_SCOPE_FAIL"] = "1"
            result = subprocess.run(
                [
                    "bash",
                    str(ROOT / "tools" / "play_now_codespaces.sh"),
                    "--web-url",
                    "--repo",
                    "jadentripp/vibe-os",
                    "--ref",
                    "jt/play-now-access-next",
                    "--no-open",
                ],
                cwd=ROOT,
                env=env,
                capture_output=True,
                text=True,
            )

            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("play-now browser Codespaces path", result.stdout)
            self.assertIn("repo: jadentripp/vibe-os", result.stdout)
            self.assertIn("ref: jt/play-now-access-next", result.stdout)
            self.assertIn("local gh Codespaces API: not required", result.stdout)
            self.assertIn(
                "https://github.com/codespaces/new?hide_repo_select=true&repo=123456789&ref=jt%2Fplay-now-access-next&devcontainer_path=.devcontainer%2Fdevcontainer.json",
                result.stdout,
            )
            self.assertIn("./tools/play_now_remote.sh --preflight --require-novnc", result.stdout)
            self.assertIn("./tools/play_now_remote.sh --require-novnc", result.stdout)
            self.assertIn("/vnc.html?autoconnect=1", result.stdout)
            self.assertIn("dry-run: Codespace was not created or modified", result.stdout)
            self.assertEqual(result.stderr, "")

            log = gh_log.read_text()
            self.assertIn("api -H Accept: application/vnd.github+json /repos/jadentripp/vibe-os --jq .id", log)
            self.assertNotIn("/user/codespaces?per_page=1", log)
            self.assertNotIn("codespace create", log)
            self.assertNotIn("codespace ssh", log)
            self.assertIn("ls-remote --heads https://github.com/jadentripp/vibe-os.git jt/play-now-access-next", git_log.read_text())

    def test_codespaces_launcher_web_url_mode_does_not_need_gh_auth(self):
        with tempfile.TemporaryDirectory() as tmp:
            env, gh_log, git_log = self._codespaces_stub_env(tmp)
            env["FAKE_GH_AUTH_FAIL"] = "1"
            result = subprocess.run(
                [
                    "bash",
                    str(ROOT / "tools" / "play_now_codespaces.sh"),
                    "--web-url",
                    "--repo",
                    "jadentripp/vibe-os",
                    "--ref",
                    "main",
                    "--no-open",
                ],
                cwd=ROOT,
                env=env,
                capture_output=True,
                text=True,
            )

            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("play-now browser Codespaces path", result.stdout)
            self.assertIn("repo: jadentripp/vibe-os", result.stdout)
            self.assertIn("ref: main", result.stdout)
            self.assertIn("local gh auth: optional for this browser path", result.stdout)
            self.assertIn("Codespaces create URL:\nhttps://github.com/codespaces/new", result.stdout)
            self.assertIn("./tools/play_now_remote.sh --require-novnc", result.stdout)
            self.assertEqual(result.stderr, "")

            log = gh_log.read_text()
            self.assertIn("auth status -h github.com", log)
            self.assertNotIn("/user/codespaces?per_page=1", log)
            self.assertNotIn("codespace create", log)
            self.assertIn(
                "ls-remote --heads https://github.com/jadentripp/vibe-os.git main",
                git_log.read_text(),
            )

    def test_codespaces_launcher_web_url_mode_falls_back_when_repo_id_api_is_limited(self):
        with tempfile.TemporaryDirectory() as tmp:
            env, gh_log, git_log = self._codespaces_stub_env(tmp)
            env["FAKE_REPO_ID_FAIL"] = "1"
            result = subprocess.run(
                [
                    "bash",
                    str(ROOT / "tools" / "play_now_codespaces.sh"),
                    "--web-url",
                    "--repo",
                    "jadentripp/vibe-os",
                    "--ref",
                    "jt/play-now-access-next",
                    "--no-open",
                ],
                cwd=ROOT,
                env=env,
                capture_output=True,
                text=True,
            )

            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("Codespaces create URL:\nhttps://github.com/codespaces/new", result.stdout)
            self.assertNotIn("API rate limit exceeded", result.stdout)
            self.assertIn("repo: jadentripp/vibe-os", result.stdout)
            self.assertIn("ref: jt/play-now-access-next", result.stdout)
            self.assertEqual(result.stderr, "")

            log = gh_log.read_text()
            self.assertIn("api -H Accept: application/vnd.github+json /repos/jadentripp/vibe-os --jq .id", log)
            self.assertNotIn("/user/codespaces?per_page=1", log)
            self.assertIn("ls-remote --heads https://github.com/jadentripp/vibe-os.git jt/play-now-access-next", git_log.read_text())

    def test_codespaces_launcher_requires_codespaces_api_scope_before_create(self):
        with tempfile.TemporaryDirectory() as tmp:
            env, gh_log, git_log = self._codespaces_stub_env(tmp)
            env["FAKE_CODESPACE_SCOPE_FAIL"] = "1"
            result = subprocess.run(
                [
                    "bash",
                    str(ROOT / "tools" / "play_now_codespaces.sh"),
                    "--dry-run",
                    "--repo",
                    "jadentripp/vibe-os",
                    "--ref",
                    "jt/doom-gameplay-proof",
                    "--no-open",
                ],
                cwd=ROOT,
                env=env,
                capture_output=True,
                text=True,
            )

            self.assertEqual(result.returncode, 1)
            self.assertIn("gh auth refresh -h github.com -s codespace", result.stderr)
            self.assertIn("Browser Codespaces URL:", result.stderr)
            self.assertIn("https://github.com/codespaces/new?hide_repo_select=true&repo=123456789&ref=jt%2Fdoom-gameplay-proof&devcontainer_path=.devcontainer%2Fdevcontainer.json", result.stderr)
            self.assertIn("./tools/play_now_remote.sh --require-novnc", result.stderr)
            log = gh_log.read_text()
            self.assertIn("/user/codespaces?per_page=1", log)
            self.assertNotIn("codespace create", log)

    def test_codespaces_launcher_requires_remote_play_payload_before_create(self):
        with tempfile.TemporaryDirectory() as tmp:
            env, gh_log, git_log = self._codespaces_stub_env(tmp)
            env["FAKE_PLAY_PAYLOAD_MISSING"] = "1"
            result = subprocess.run(
                [
                    "bash",
                    str(ROOT / "tools" / "play_now_codespaces.sh"),
                    "--dry-run",
                    "--repo",
                    "jadentripp/vibe-os",
                    "--ref",
                    "jt/doom-gameplay-proof",
                    "--no-open",
                ],
                cwd=ROOT,
                env=env,
                capture_output=True,
                text=True,
            )

            self.assertEqual(result.returncode, 1)
            self.assertIn("missing required play-now path", result.stderr)
            self.assertIn(".devcontainer/devcontainer.json", result.stderr)
            log = gh_log.read_text()
            self.assertNotIn("/user/codespaces?per_page=1", log)
            self.assertNotIn("codespace create", log)
            self.assertIn("cat-file -e FETCH_HEAD:.devcontainer/devcontainer.json", git_log.read_text())

    def test_codespaces_launcher_default_display_name_fits_gh_limit(self):
        with tempfile.TemporaryDirectory() as tmp:
            env, _, _ = self._codespaces_stub_env(tmp)
            result = subprocess.run(
                [
                    "bash",
                    str(ROOT / "tools" / "play_now_codespaces.sh"),
                    "--dry-run",
                    "--repo",
                    "jadentripp/vibe-os",
                    "--ref",
                    "jt/doom-gameplay-proof-with-a-very-long-proof-branch-name",
                    "--no-open",
                ],
                cwd=ROOT,
                env=env,
                capture_output=True,
                text=True,
            )

            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            display_line = next(
                line for line in result.stdout.splitlines() if line.startswith("codespace: create ")
            )
            display_name = display_line.removeprefix("codespace: create ")
            self.assertLessEqual(len(display_name), 48)
            self.assertTrue(display_name.startswith("vibe-play-"))

    def test_codespaces_launcher_passes_custom_novnc_port_and_opens_private_vnc_path(self):
        with tempfile.TemporaryDirectory() as tmp:
            env, gh_log, _ = self._codespaces_stub_env(tmp)
            env.update(
                {
                    "NOVNC_PORT": "6173",
                    "EXPECTED_NOVNC_PORT": "6173",
                    "FAKE_BROWSE_URL": "https://vibe-play-6173.app.github.dev/",
                }
            )
            result = subprocess.run(
                [
                    "bash",
                    str(ROOT / "tools" / "play_now_codespaces.sh"),
                    "--repo",
                    "jadentripp/vibe-os",
                    "--ref",
                    "jt/doom-gameplay-proof",
                    "--codespace",
                    "vibe-play-existing",
                    "--no-open",
                ],
                cwd=ROOT,
                env=env,
                capture_output=True,
                text=True,
            )

            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("Starting vibe-os Doom inside Codespace 'vibe-play-existing'", result.stdout)
            self.assertIn("noVNC port 6173 is private", result.stdout)
            self.assertIn(
                "Open Doom noVNC: https://vibe-play-6173.app.github.dev/vnc.html?autoconnect=1",
                result.stdout,
            )
            self.assertIn(
                "Controls: arrows move/turn, Ctrl fires, Space uses, Escape opens menu.",
                result.stdout,
            )
            self.assertEqual(result.stderr, "")

            log = gh_log.read_text()
            self.assertIn(
                "codespace ssh -c vibe-play-existing -- env VIBE_PLAY_REF=jt/doom-gameplay-proof NOVNC_PORT=6173 bash -s",
                log,
            )
            self.assertNotIn("bash -lc", log)
            self.assertIn("codespace ports visibility 6173:private -c vibe-play-existing", log)
            self.assertNotIn("codespace create", log)

    def test_codespaces_launcher_fails_closed_when_novnc_port_cannot_be_marked_private(self):
        with tempfile.TemporaryDirectory() as tmp:
            env, gh_log, _ = self._codespaces_stub_env(tmp)
            env.update(
                {
                    "EXPECTED_NOVNC_PORT": "6080",
                    "FAKE_VISIBILITY_FAIL": "1",
                }
            )
            result = subprocess.run(
                [
                    "bash",
                    str(ROOT / "tools" / "play_now_codespaces.sh"),
                    "--repo",
                    "jadentripp/vibe-os",
                    "--ref",
                    "jt/doom-gameplay-proof",
                    "--codespace",
                    "vibe-play-existing",
                    "--no-open",
                ],
                cwd=ROOT,
                env=env,
                capture_output=True,
                text=True,
            )

            self.assertEqual(result.returncode, 1)
            self.assertIn("could not mark noVNC port 6080 private", result.stderr)
            self.assertNotIn("Open Doom noVNC", result.stdout)
            self.assertIn("codespace ports visibility 6080:private", gh_log.read_text())

    def test_codespaces_launcher_explicit_repo_ref_ignores_dirty_or_unpushed_local_checkout(self):
        for mode in ("dirty", "ahead"):
            with self.subTest(mode=mode), tempfile.TemporaryDirectory() as tmp:
                env, gh_log, git_log = self._codespaces_stub_env(tmp, git_mode=mode)
                result = subprocess.run(
                    [
                        "bash",
                        str(ROOT / "tools" / "play_now_codespaces.sh"),
                        "--dry-run",
                        "--repo",
                        "jadentripp/vibe-os",
                        "--ref",
                        "jt/doom-gameplay-proof",
                        "--no-open",
                    ],
                    cwd=ROOT,
                    env=env,
                    capture_output=True,
                    text=True,
                )

                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertIn(
                    "git state: explicit GitHub repo/ref selected; local checkout dirt is ignored",
                    result.stdout,
                )
                self.assertEqual(result.stderr, "")
                self.assertIn(
                    "ls-remote --heads https://github.com/jadentripp/vibe-os.git jt/doom-gameplay-proof",
                    git_log.read_text(),
                )
                log = gh_log.read_text()
                self.assertIn("api -H Accept: application/vnd.github+json /repos/jadentripp/vibe-os --jq .id", log)
                self.assertNotIn("codespace create", log)
                self.assertNotIn("codespace ssh", log)

    def test_codespaces_launcher_env_repo_ref_ignores_dirty_local_checkout(self):
        with tempfile.TemporaryDirectory() as tmp:
            env, _, _ = self._codespaces_stub_env(tmp, git_mode="dirty")
            env.update(
                {
                    "VIBE_REPO": "jadentripp/vibe-os",
                    "VIBE_REF": "jt/doom-gameplay-proof",
                }
            )
            result = subprocess.run(
                [
                    "bash",
                    str(ROOT / "tools" / "play_now_codespaces.sh"),
                    "--dry-run",
                    "--no-open",
                ],
                cwd=ROOT,
                env=env,
                capture_output=True,
                text=True,
            )

            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("repo: jadentripp/vibe-os", result.stdout)
            self.assertIn("ref: jt/doom-gameplay-proof", result.stdout)
            self.assertIn(
                "git state: explicit GitHub repo/ref selected; local checkout dirt is ignored",
                result.stdout,
            )

    def test_codespaces_launcher_refuses_missing_remote_branch_before_codespaces(self):
        with tempfile.TemporaryDirectory() as tmp:
            env, gh_log, _ = self._codespaces_stub_env(tmp)
            env["FAKE_REF_MISSING"] = "1"
            result = subprocess.run(
                [
                    "bash",
                    str(ROOT / "tools" / "play_now_codespaces.sh"),
                    "--dry-run",
                    "--repo",
                    "jadentripp/vibe-os",
                    "--ref",
                    "jt/not-pushed",
                    "--no-open",
                ],
                cwd=ROOT,
                env=env,
                capture_output=True,
                text=True,
            )

            self.assertEqual(result.returncode, 1)
            self.assertIn("GitHub branch 'jt/not-pushed' was not found", result.stderr)
            log = gh_log.read_text() if gh_log.exists() else ""
            self.assertNotIn("/user/codespaces?per_page=1", log)
            self.assertNotIn("codespace create", log)

    def test_codespaces_launcher_refuses_invalid_branch_name_before_codespaces(self):
        with tempfile.TemporaryDirectory() as tmp:
            env, gh_log, git_log = self._codespaces_stub_env(tmp)
            result = subprocess.run(
                [
                    "bash",
                    str(ROOT / "tools" / "play_now_codespaces.sh"),
                    "--dry-run",
                    "--repo",
                    "jadentripp/vibe-os",
                    "--ref",
                    "bad..branch",
                    "--no-open",
                ],
                cwd=ROOT,
                env=env,
                capture_output=True,
                text=True,
            )

            self.assertEqual(result.returncode, 1)
            self.assertIn("ref must be a valid Git branch name", result.stderr)
            self.assertIn("check-ref-format --branch bad..branch", git_log.read_text())
            log = gh_log.read_text() if gh_log.exists() else ""
            self.assertNotIn("/user/codespaces?per_page=1", log)
            self.assertNotIn("codespace create", log)

    def test_codespaces_launcher_refuses_dirty_or_unpushed_inferred_branch_before_codespaces(self):
        for mode, message in (
            ("dirty", "local git working tree is dirty"),
            ("ahead", "differs from upstream"),
        ):
            with self.subTest(mode=mode), tempfile.TemporaryDirectory() as tmp:
                env, gh_log, _ = self._codespaces_stub_env(tmp, git_mode=mode)
                result = subprocess.run(
                    [
                        "bash",
                        str(ROOT / "tools" / "play_now_codespaces.sh"),
                        "--dry-run",
                        "--repo",
                        "jadentripp/vibe-os",
                    ],
                    cwd=ROOT,
                    env=env,
                    capture_output=True,
                    text=True,
                )

                self.assertEqual(result.returncode, 1)
                self.assertIn(message, result.stderr)
                log = gh_log.read_text() if gh_log.exists() else ""
                self.assertNotIn("codespace create", log)
                self.assertNotIn("codespace ssh", log)

    def test_remote_script_rejects_invalid_novnc_port_before_any_play_action(self):
        env = os.environ.copy()
        env["NOVNC_PORT"] = "70000"
        result = subprocess.run(
            [
                "bash",
                str(ROOT / "tools" / "play_now_remote.sh"),
                "--preflight",
            ],
            cwd=ROOT,
            env=env,
            capture_output=True,
            text=True,
        )

        self.assertEqual(result.returncode, 1)
        self.assertIn("NOVNC_PORT must be between 1 and 65535", result.stderr)
        self.assertNotIn("Fetching/validating", result.stdout)

    def test_remote_script_rejects_invalid_vnc_display_before_any_play_action(self):
        env = os.environ.copy()
        env["VNC_DISPLAY"] = "bad"
        result = subprocess.run(
            [
                "bash",
                str(ROOT / "tools" / "play_now_remote.sh"),
                "--preflight",
            ],
            cwd=ROOT,
            env=env,
            capture_output=True,
            text=True,
        )

        self.assertEqual(result.returncode, 1)
        self.assertIn("VNC_DISPLAY must be a non-negative integer", result.stderr)
        self.assertNotIn("Fetching/validating", result.stdout)

    def test_cloud_shell_bootstrap_refuses_macos_before_remote_setup(self):
        with tempfile.TemporaryDirectory() as tmp:
            bin_dir = Path(tmp) / "bin"
            bin_dir.mkdir()
            self._write_stub_tool(
                bin_dir,
                "uname",
                "#!/usr/bin/env bash\nprintf 'Darwin\\n'\n",
            )
            env = os.environ.copy()
            env["PATH"] = f"{bin_dir}{os.pathsep}{env['PATH']}"
            result = subprocess.run(
                [
                    "bash",
                    str(ROOT / "tools" / "play_now_cloud_shell.sh"),
                    "--preflight-only",
                    "--no-install",
                ],
                cwd=ROOT,
                env=env,
                capture_output=True,
                text=True,
            )

            self.assertEqual(result.returncode, 1)
            self.assertIn("Refusing to bootstrap a QEMU play host on macOS", result.stderr)
            self.assertNotIn("Remote checkout:", result.stdout)

    def test_play_now_script_is_remote_first_and_repo_safe(self):
        script = (ROOT / "tools" / "play_now_remote.sh").read_text()
        doc = (ROOT / "docs" / "runbooks" / "play-now-cloud.md").read_text()

        for needle in (
            'Usage: tools/play_now_remote.sh [--preflight|--dry-run] [--require-novnc]',
            '--preflight|--dry-run',
            '--require-novnc',
            'uname -s',
            'Refusing to run QEMU on macOS',
            'ALLOW_LOCAL_VM:-0',
            'validate_tcp_port NOVNC_PORT "$NOVNC_PORT"',
            'validate_vnc_display "$VNC_DISPLAY"',
            'ensure_wad_path_outside_repo',
            'ensure_loopback_port_free "QEMU VNC" "$VNC_PORT"',
            'python3 tools/check_play_now_remote.py',
            'if [ "$RUN_PREFLIGHT_ONLY" = "1" ]; then',
            '/tmp/vibe-os-DOOM1.WAD',
            'tools/prepare_shareware_wad.py',
            'rm -f build/disk.img',
            'Reusing cached objects when valid',
            'make DOOM_WAD="$WAD_PATH"',
            'NOVNC_WEB_ROOTS=(',
            'resolve_novnc_web_root',
            'websockify --web="$NOVNC_WEB_ROOT_RESOLVED"',
            '/vnc.html?autoconnect=1',
            'codespaces_novnc_url()',
            'Codespaces noVNC URL:',
            'QEMU_PID="$!"',
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
            '--web-url',
            'tools/play_now_cloud_shell.sh',
            'forward port',
            'VNC does not carry game audio',
            'cloud `real-wad-smoke.yml` aggregate audio proof',
        ):
            with self.subTest(needle=needle):
                self.assertIn(needle, doc)

        cloud_shell = (ROOT / "tools" / "play_now_cloud_shell.sh").read_text()
        for needle in (
            'Refusing to bootstrap a QEMU play host on macOS',
            'VIBE_REF:-main',
            'apt-get install -y --no-install-recommends',
            'qemu-system-x86',
            'git clone --depth=1 --branch "$REF"',
            './tools/play_now_remote.sh --preflight --require-novnc',
            'exec ./tools/play_now_remote.sh --require-novnc',
        ):
            with self.subTest(needle=needle):
                self.assertIn(needle, cloud_shell)

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
