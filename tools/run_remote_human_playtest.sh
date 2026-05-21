#!/usr/bin/env bash
set -euo pipefail

BUILD_DIR="${BUILD_DIR:-build}"
MONITOR_SOCKET="${MONITOR_SOCKET:-build/play-now/monitor.sock}"
OUTPUT_DIR="${OUTPUT_DIR:-/tmp/vibe-os-human-proof}"
TARBALL="${TARBALL:-/tmp/vibe-os-human-proof.tgz}"
AUDIO_MODE="${AUDIO_MODE:-status-only}"
SLOWDOWN_MODE="${SLOWDOWN_MODE:-}"
SLOWDOWN_NOTES="${SLOWDOWN_NOTES:-}"
PLAYTESTER=""
SCRIPTED_PROOF_RUN_ID=""
COMMIT_VALUE=""

usage() {
  cat <<'EOF'
Usage: tools/run_remote_human_playtest.sh --playtester NAME --scripted-proof-run-id RUN_ID [options]

Run this from a second SSH shell on the disposable remote Linux host while
tools/play_now_remote.sh is running QEMU there. The script prompts for each
manual Doom action, captures the status page through the remote QEMU monitor,
builds the allowlisted human proof bundle, validates it before download, and
prints the exact local download/check commands.
For a read-only command plan first, run:
  python3 tools/collect_human_playtest_bundle.py --print-template --build-dir build --output-dir /tmp/vibe-os-human-proof --playtester NAME --scripted-proof-run-id RUN_ID
For a shorter phase checklist only, run:
  python3 tools/collect_human_playtest_bundle.py --print-phase-guide

Required:
  --playtester NAME              Initials or handle for the human session.
  --scripted-proof-run-id ID     Passing GitHub Actions Real WAD smoke run ID.

Options:
  --build-dir PATH               Remote build dir with ELF/status/log files.
                                 Default: build
  --monitor-socket PATH          Remote QEMU monitor socket.
                                 Default: build/play-now/monitor.sock
  --output-dir PATH              Empty remote scratch proof dir outside repo.
                                 Default: /tmp/vibe-os-human-proof
  --tarball PATH                 Remote tarball path for the allowlisted bundle.
                                 Default: /tmp/vibe-os-human-proof.tgz
  --audio MODE                   status-only, listener-pass,
                                 audio-proof-json-pass, or not-tested.
                                 Default: status-only
  --slowdown LEVEL               not-observed, mild, moderate, or severe.
                                 If omitted, the helper prompts after capture.
  --slowdown-notes TEXT          Short status-only slowdown note. If omitted,
                                 the helper prompts after capture.
  --commit HASH                  Commit under test; defaults to git HEAD.
  -h, --help                     Show this help.
EOF
}

die() {
  echo "remote human playtest failed: $*" >&2
  exit 1
}

validate_human_labels() {
  [[ "$PLAYTESTER" =~ ^[A-Za-z0-9._-]{2,64}$ ]] || {
    die "--playtester must be 2-64 characters: letters, numbers, dot, underscore, or dash"
  }
  [[ "$SCRIPTED_PROOF_RUN_ID" =~ ^[0-9]{6,32}$ ]] || {
    die "--scripted-proof-run-id must be a 6-32 digit GitHub Actions run ID"
  }
  if [ -n "$COMMIT_VALUE" ]; then
    [[ "$COMMIT_VALUE" =~ ^([0-9A-Fa-f]{7,40}|unknown)$ ]] || {
      die "--commit must be a 7-40 character hex commit or 'unknown'"
    }
  fi
}

validate_slowdown_fields() {
  if [ -n "$SLOWDOWN_MODE" ]; then
    case "$SLOWDOWN_MODE" in
      not-observed|mild|moderate|severe) ;;
      *) die "--slowdown must be not-observed, mild, moderate, or severe" ;;
    esac
  fi
  if [ -n "$SLOWDOWN_NOTES" ]; then
    [ "${#SLOWDOWN_NOTES}" -le 160 ] || die "--slowdown-notes must be 160 characters or fewer"
    case "$SLOWDOWN_NOTES" in
      *"="*|*$'\n'*|*$'\r'*|*$'\t'*)
        die "--slowdown-notes must be single-line status text without key separators"
        ;;
    esac
  fi
}

validate_remote_scratch_paths() {
  python3 - "$OUTPUT_DIR" "$TARBALL" <<'PY'
from pathlib import Path
import subprocess
import sys


def is_relative_to(path: Path, parent: Path) -> bool:
    try:
        path.relative_to(parent)
    except ValueError:
        return False
    return True


def absolute_without_symlink_resolution(raw: str) -> Path:
    path = Path(raw).expanduser()
    if not path.is_absolute():
        path = Path.cwd() / path
    return path.absolute()


output_raw, tarball_raw = sys.argv[1:3]
try:
    repo_root = Path(
        subprocess.check_output(
            ["git", "rev-parse", "--show-toplevel"],
            text=True,
            stderr=subprocess.DEVNULL,
        ).strip()
    ).resolve()
except Exception:
    repo_root = Path.cwd().resolve()

checks = (
    ("proof output directory", Path(output_raw).expanduser()),
    ("proof tarball", Path(tarball_raw).expanduser()),
)
for label, raw_path in checks:
    lexical = absolute_without_symlink_resolution(str(raw_path))
    resolved = raw_path.resolve(strict=False)
    if is_relative_to(lexical, repo_root) or is_relative_to(resolved, repo_root):
        print(f"{label} must live outside the git checkout: {lexical}", file=sys.stderr)
        sys.exit(1)
    if lexical == Path(lexical.anchor):
        print(f"{label} must not be the filesystem root: {lexical}", file=sys.stderr)
        sys.exit(1)

tarball = absolute_without_symlink_resolution(tarball_raw)
suffixes = "".join(tarball.suffixes)
if suffixes not in (".tgz", ".tar.gz"):
    print("proof tarball must end in .tgz or .tar.gz", file=sys.stderr)
    sys.exit(1)
if tarball.exists() and tarball.is_dir():
    print(f"proof tarball path is a directory: {tarball}", file=sys.stderr)
    sys.exit(1)

output = absolute_without_symlink_resolution(output_raw)
try:
    tarball.relative_to(output)
except ValueError:
    pass
else:
    print("proof tarball must not be inside the proof output directory", file=sys.stderr)
    sys.exit(1)
PY
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --playtester)
      [ "$#" -ge 2 ] || die "--playtester requires a value"
      PLAYTESTER="$2"
      shift
      ;;
    --scripted-proof-run-id)
      [ "$#" -ge 2 ] || die "--scripted-proof-run-id requires a value"
      SCRIPTED_PROOF_RUN_ID="$2"
      shift
      ;;
    --build-dir)
      [ "$#" -ge 2 ] || die "--build-dir requires a value"
      BUILD_DIR="$2"
      shift
      ;;
    --monitor-socket)
      [ "$#" -ge 2 ] || die "--monitor-socket requires a value"
      MONITOR_SOCKET="$2"
      shift
      ;;
    --output-dir)
      [ "$#" -ge 2 ] || die "--output-dir requires a value"
      OUTPUT_DIR="$2"
      shift
      ;;
    --tarball)
      [ "$#" -ge 2 ] || die "--tarball requires a value"
      TARBALL="$2"
      shift
      ;;
    --audio)
      [ "$#" -ge 2 ] || die "--audio requires a value"
      AUDIO_MODE="$2"
      shift
      ;;
    --slowdown)
      [ "$#" -ge 2 ] || die "--slowdown requires a value"
      SLOWDOWN_MODE="$2"
      shift
      ;;
    --slowdown-notes)
      [ "$#" -ge 2 ] || die "--slowdown-notes requires a value"
      SLOWDOWN_NOTES="$2"
      shift
      ;;
    --commit)
      [ "$#" -ge 2 ] || die "--commit requires a value"
      COMMIT_VALUE="$2"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown argument: $1"
      ;;
  esac
  shift
done

[ -n "$PLAYTESTER" ] || die "--playtester is required"
[ -n "$SCRIPTED_PROOF_RUN_ID" ] || die "--scripted-proof-run-id is required"
validate_human_labels
validate_slowdown_fields

case "$(uname -s)" in
  Darwin)
    cat >&2 <<'EOF'
Refusing to run the remote human playtest helper on macOS.

Run tools/play_now_remote.sh and this helper inside the disposable remote Linux
host or Codespace. The Mac should only SSH, view noVNC/VNC, download the final
allowlisted proof tarball, and run host-only checkers.
EOF
    exit 1
    ;;
esac

command -v python3 >/dev/null 2>&1 || die "missing python3"
command -v tar >/dev/null 2>&1 || die "missing tar"
validate_remote_scratch_paths
[ -d "$BUILD_DIR" ] || die "build directory does not exist: $BUILD_DIR"
[ -S "$MONITOR_SOCKET" ] || die "remote QEMU monitor socket does not exist: $MONITOR_SOCKET"

if [ -z "$COMMIT_VALUE" ]; then
  command -v git >/dev/null 2>&1 || die "missing git; pass --commit HASH explicitly"
  COMMIT_VALUE="$(git rev-parse --short=12 HEAD 2>/dev/null || true)"
  [ -n "$COMMIT_VALUE" ] || die "could not resolve git HEAD; pass --commit HASH explicitly"
fi

case "$AUDIO_MODE" in
  status-only|listener-pass|audio-proof-json-pass|not-tested) ;;
  *) die "--audio must be status-only, listener-pass, audio-proof-json-pass, or not-tested" ;;
esac

output_parent="$(dirname "$OUTPUT_DIR")"
output_base="$(basename "$OUTPUT_DIR")"
tarball_parent="$(dirname "$TARBALL")"
mkdir -p "$output_parent" "$tarball_parent"
rm -f "$TARBALL"

PHASES=(
  early
  after-start
  after-fire
  after-move
  after-use
  after-mouse
  after-menu
  final
)

PHASE_PROMPTS=(
  "Before pressing any Doom controls, press Enter to capture the baseline."
  "Confirm E1M1 or the playable Doom view is visible in VNC, then press Enter."
  "Press Ctrl/fire in VNC, wait for a visible response, then press Enter."
  "Hold an arrow key long enough to move or turn, then press Enter."
  "Press Space/use in VNC, wait for Doom to accept it, then press Enter."
  "Move the mouse and click once through VNC, then press Enter."
  "Press Escape and confirm the Doom menu opens, then press Enter."
  "Let the session run long enough to cross the duration gate, then press Enter."
)

PHASE_STATUS_FILES=(
  status.early.txt
  status.after-start.txt
  status.after-fire.txt
  status.after-move.txt
  status.after-use.txt
  status.after-mouse.txt
  status.after-menu.txt
  status.txt
)

PHASE_EXPECTED_SIGNALS=(
  "baseline counters before manual input"
  "gameplay=OK, E1M1, menu inactive"
  "keyseen fire bit plus attack/refire/ammo status"
  "movement key bit plus position or turn progress"
  "use key bit plus use-command status"
  "mouse counters, button, and nonzero movement delta"
  "menu key bit plus menu-active status"
  "duration gate crossed and all manual action bits retained"
)

echo "Remote human Doom proof capture"
echo "  build dir:        $BUILD_DIR"
echo "  monitor socket:   $MONITOR_SOCKET"
echo "  commit:           $COMMIT_VALUE"
echo "  scripted run ID:  $SCRIPTED_PROOF_RUN_ID"
echo "  proof output dir: $OUTPUT_DIR"
echo "  proof tarball:    $TARBALL"
echo
echo "Keep QEMU running in the other remote SSH shell. Do not download WADs,"
echo "disk images, framebuffer data, screenshots, status binaries, or raw audio."
echo
echo "Phase capture plan:"
for index in "${!PHASES[@]}"; do
  echo "  ${PHASES[$index]} -> ${PHASE_STATUS_FILES[$index]}: ${PHASE_EXPECTED_SIGNALS[$index]}"
done
echo "  duration gate: final must be at least 350 gtic and leveltime ticks after after-start"
echo
echo "Before continuing, confirm the scripted Real WAD smoke run ID is green:"
echo "  https://github.com/jadentripp/vibe-os/actions/runs/$SCRIPTED_PROOF_RUN_ID"
printf "Press Enter after confirming that linked run is green..."
read -r _
echo

for index in "${!PHASES[@]}"; do
  phase="${PHASES[$index]}"
  prompt="${PHASE_PROMPTS[$index]}"
  echo "[$phase] $prompt"
  echo "Expected status signal: ${PHASE_EXPECTED_SIGNALS[$index]}"
  echo "Collector output file: ${PHASE_STATUS_FILES[$index]}"
  printf "Press Enter when ready to capture %s..." "$phase"
  read -r _
  python3 tools/collect_human_playtest_bundle.py \
    --build-dir "$BUILD_DIR" \
    --monitor-socket "$MONITOR_SOCKET" \
    --capture-phase "$phase"
  echo
done

if [ -z "$SLOWDOWN_MODE" ]; then
  while true; do
    printf "Slowdown observed? [not-observed/mild/moderate/severe] "
    read -r SLOWDOWN_MODE
    case "$SLOWDOWN_MODE" in
      not-observed|mild|moderate|severe) break ;;
      *) echo "Please enter not-observed, mild, moderate, or severe." ;;
    esac
  done
fi

if [ -z "$SLOWDOWN_NOTES" ]; then
  printf "Short slowdown note, status-only, no logs/env/screenshots: "
  read -r SLOWDOWN_NOTES
  [ -n "$SLOWDOWN_NOTES" ] || SLOWDOWN_NOTES="not-observed-during-capture"
fi
validate_slowdown_fields

python3 tools/collect_human_playtest_bundle.py \
  --build-dir "$BUILD_DIR" \
  --output-dir "$OUTPUT_DIR" \
  --playtester "$PLAYTESTER" \
  --scripted-proof-run-id "$SCRIPTED_PROOF_RUN_ID" \
  --audio "$AUDIO_MODE" \
  --slowdown "$SLOWDOWN_MODE" \
  --slowdown-notes "$SLOWDOWN_NOTES" \
  --commit "$COMMIT_VALUE" \
  --confirm-scripted-proof-green \
  --confirm-remote-vnc \
  --confirm-e1m1-visible \
  --confirm-keyboard-fire \
  --confirm-keyboard-move \
  --confirm-keyboard-use \
  --confirm-mouse-action \
  --confirm-menu-escape \
  --confirm-slowdown-notes \
  --confirm-phase-actions \
  --confirm-phase-status-hashes \
  --confirm-no-forbidden-artifacts \
  --confirm-post-download-verification

tar -C "$output_parent" -czf "$TARBALL" "$output_base"

echo
echo "Remote allowlisted human proof bundle is ready: $TARBALL"
echo "Download only that tarball, then run these on the Mac from the repo root:"
if [ -n "${VIBE_CLOUD_HOST:-}" ]; then
  echo "  scp \"\$VIBE_CLOUD_HOST:$TARBALL\" ./vibe-os-human-proof.tgz"
else
  echo "  scp user@remote-host:$TARBALL ./vibe-os-human-proof.tgz"
fi
cat <<'EOF'
  rm -rf ./vibe-os-human-proof
  tar -xzf ./vibe-os-human-proof.tgz
EOF
echo "  python3 tools/check_cloud_playability_artifacts.py --human-session ./vibe-os-human-proof --expected-commit \"$COMMIT_VALUE\" --expected-scripted-proof-run-id \"$SCRIPTED_PROOF_RUN_ID\""
echo "  python3 tools/check_human_playability_proof.py --require-human-session --human-notes ./vibe-os-human-proof/human-playtest-notes.txt --expected-commit \"$COMMIT_VALUE\" --expected-scripted-proof-run-id \"$SCRIPTED_PROOF_RUN_ID\" ./vibe-os-human-proof/status.txt"
echo
echo "Compare the local post-download human verification OK line with the"
echo "pre-download human verification OK line printed above."
