#!/usr/bin/env bash
set -euo pipefail

BUILD_DIR="${BUILD_DIR:-build}"
MONITOR_SOCKET="${MONITOR_SOCKET:-build/play-now/monitor.sock}"
OUTPUT_DIR="${OUTPUT_DIR:-/tmp/vibe-os-human-proof}"
TARBALL="${TARBALL:-/tmp/vibe-os-human-proof.tgz}"
AUDIO_MODE="${AUDIO_MODE:-}"
AUDIO_NOTES="${AUDIO_NOTES:-}"
SLOWDOWN_MODE="${SLOWDOWN_MODE:-}"
SLOWDOWN_NOTES="${SLOWDOWN_NOTES:-}"
NOVNC_FOCUS_MODE="${NOVNC_FOCUS_MODE:-}"
NOVNC_FOCUS_NOTES="${NOVNC_FOCUS_NOTES:-}"
PLAYTESTER=""
REVIEWER=""
SCRIPTED_PROOF_RUN_ID=""
COMMIT_VALUE=""
REF_VALUE="${VIBE_PLAY_REF:-}"
START_NOTE=""
FIRE_NOTE=""
MOVE_NOTE=""
USE_NOTE=""
MOUSE_NOTE=""
MENU_NOTE=""
FINAL_NOTE=""

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
  --reviewer NAME                Reviewer handle for the status-only review
                                 manifest. Defaults to --playtester.
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
                                 Default: prompt; Enter selects status-only.
  --audio-notes TEXT             Short status-only audio note. If omitted,
                                 the helper derives one from --audio.
  --slowdown LEVEL               not-observed, mild, moderate, or severe.
                                 If omitted, the helper prompts after capture.
  --slowdown-notes TEXT          Short status-only slowdown note. If omitted,
                                 the helper prompts after capture.
  --novnc-focus MODE             canvas-focused-before-actions,
                                 focus-retaken-during-session, or
                                 focus-issues-observed. Default: prompt.
  --novnc-focus-notes TEXT       Short status-only noVNC focus note. If
                                 omitted, the helper prompts after capture.
  --start-note TEXT              Status-only note after E1M1/start capture.
  --fire-note TEXT               Status-only note after Ctrl/fire capture.
  --move-note TEXT               Status-only note after arrow move capture.
  --use-note TEXT                Status-only note after Space/use capture.
  --mouse-note TEXT              Status-only note after mouse move/click capture.
  --menu-note TEXT               Status-only note after Escape/menu capture.
  --final-note TEXT              Status-only note after final duration capture.
  --commit HASH                  Commit under test; defaults to git HEAD.
  --ref REF                      Git ref under test; defaults to VIBE_PLAY_REF
                                 or the current git branch.
  -h, --help                     Show this help.
EOF
}

die() {
  echo "remote human playtest failed: $*" >&2
  exit 1
}

remote_cpu_count() {
  getconf _NPROCESSORS_ONLN 2>/dev/null || echo unknown
}

remote_memory_mb() {
  awk '/^MemTotal:/ { printf "%d", int($2 / 1024); found=1 } END { if (!found) print "unknown" }' /proc/meminfo 2>/dev/null || echo unknown
}

remote_machine_label() {
  printf "%s cpus=%s memory_mb=%s" "$(uname -srm 2>/dev/null || echo remote-host)" "$(remote_cpu_count)" "$(remote_memory_mb)"
}

phase_status_hash() {
  python3 - "$1" <<'PY'
import hashlib
import sys
from pathlib import Path

path = Path(sys.argv[1])
print(hashlib.sha256(path.read_bytes()).hexdigest())
PY
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
  if [ -n "$REF_VALUE" ]; then
    [[ "$REF_VALUE" =~ ^[A-Za-z0-9._/@+-]{1,160}$ ]] || {
      die "--ref may contain only letters, numbers, dot, underscore, slash, at, plus, or dash"
    }
  fi
  if [ -n "$REVIEWER" ]; then
    [[ "$REVIEWER" =~ ^[A-Za-z0-9._-]{2,64}$ ]] || {
      die "--reviewer must be 2-64 characters: letters, numbers, dot, underscore, or dash"
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

validate_observation_notes() {
  local label="$1"
  local value="$2"

  if [ -n "$value" ]; then
    [ "${#value}" -le 160 ] || die "$label must be 160 characters or fewer"
    case "$value" in
      *"="*|*$'\n'*|*$'\r'*|*$'\t'*)
        die "$label must be single-line status text without key separators"
        ;;
    esac
  fi
}

prompt_phase_note() {
  local var_name="$1"
  local label="$2"
  local prompt="$3"
  local current="${!var_name:-}"

  while [ -z "$current" ]; do
    printf "%s: " "$prompt"
    read -r current
    if [ -z "$current" ]; then
      echo "Please enter a short status-only note; no screenshots, audio, WAD paths, or env dumps."
    fi
  done
  validate_observation_notes "$label" "$current"
  printf -v "$var_name" '%s' "$current"
}

validate_novnc_focus_fields() {
  if [ -n "$NOVNC_FOCUS_MODE" ]; then
    case "$NOVNC_FOCUS_MODE" in
      canvas-focused-before-actions|focus-retaken-during-session|focus-issues-observed) ;;
      *) die "--novnc-focus must be canvas-focused-before-actions, focus-retaken-during-session, or focus-issues-observed" ;;
    esac
  fi
  validate_observation_notes "--novnc-focus-notes" "$NOVNC_FOCUS_NOTES"
  validate_observation_notes "--audio-notes" "$AUDIO_NOTES"
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
    --reviewer)
      [ "$#" -ge 2 ] || die "--reviewer requires a value"
      REVIEWER="$2"
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
    --audio-notes)
      [ "$#" -ge 2 ] || die "--audio-notes requires a value"
      AUDIO_NOTES="$2"
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
    --novnc-focus)
      [ "$#" -ge 2 ] || die "--novnc-focus requires a value"
      NOVNC_FOCUS_MODE="$2"
      shift
      ;;
    --novnc-focus-notes)
      [ "$#" -ge 2 ] || die "--novnc-focus-notes requires a value"
      NOVNC_FOCUS_NOTES="$2"
      shift
      ;;
    --start-note)
      [ "$#" -ge 2 ] || die "--start-note requires a value"
      START_NOTE="$2"
      shift
      ;;
    --fire-note)
      [ "$#" -ge 2 ] || die "--fire-note requires a value"
      FIRE_NOTE="$2"
      shift
      ;;
    --move-note)
      [ "$#" -ge 2 ] || die "--move-note requires a value"
      MOVE_NOTE="$2"
      shift
      ;;
    --use-note)
      [ "$#" -ge 2 ] || die "--use-note requires a value"
      USE_NOTE="$2"
      shift
      ;;
    --mouse-note)
      [ "$#" -ge 2 ] || die "--mouse-note requires a value"
      MOUSE_NOTE="$2"
      shift
      ;;
    --menu-note)
      [ "$#" -ge 2 ] || die "--menu-note requires a value"
      MENU_NOTE="$2"
      shift
      ;;
    --final-note)
      [ "$#" -ge 2 ] || die "--final-note requires a value"
      FINAL_NOTE="$2"
      shift
      ;;
    --commit)
      [ "$#" -ge 2 ] || die "--commit requires a value"
      COMMIT_VALUE="$2"
      shift
      ;;
    --ref)
      [ "$#" -ge 2 ] || die "--ref requires a value"
      REF_VALUE="$2"
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
[ -n "$REVIEWER" ] || REVIEWER="$PLAYTESTER"
validate_human_labels
validate_slowdown_fields
validate_novnc_focus_fields

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
if [ -z "$REF_VALUE" ]; then
  command -v git >/dev/null 2>&1 || die "missing git; pass --ref REF explicitly"
  REF_VALUE="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  [ -n "$REF_VALUE" ] || die "could not resolve git ref; pass --ref REF explicitly"
fi
validate_human_labels

if [ -n "$AUDIO_MODE" ]; then
  case "$AUDIO_MODE" in
    status-only|listener-pass|audio-proof-json-pass|not-tested) ;;
    *) die "--audio must be status-only, listener-pass, audio-proof-json-pass, or not-tested" ;;
  esac
fi

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
  "Click the noVNC canvas, confirm E1M1 or the playable Doom view is visible, then press Enter."
  "Click the noVNC canvas if focus is unclear, press Ctrl/fire, wait for a visible weapon/action response, then press Enter."
  "Hold an arrow key long enough to see movement or turning, then press Enter."
  "Press Space/use and wait for Doom to accept it, then press Enter."
  "Move the mouse and click once through VNC; wait for visible turn/click response, then press Enter."
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

PHASE_HASH_KEYS=(
  phase_hash_early
  phase_hash_after_start
  phase_hash_after_fire
  phase_hash_after_move
  phase_hash_after_use
  phase_hash_after_mouse
  phase_hash_after_menu
  phase_hash_final
)

echo "Remote human Doom proof capture"
echo "  build dir:        $BUILD_DIR"
echo "  monitor socket:   $MONITOR_SOCKET"
echo "  commit:           $COMMIT_VALUE"
echo "  ref:              $REF_VALUE"
echo "  scripted run ID:  $SCRIPTED_PROOF_RUN_ID"
echo "  playtester:       $PLAYTESTER"
echo "  reviewer:         $REVIEWER"
echo "  proof output dir: $OUTPUT_DIR"
echo "  proof tarball:    $TARBALL"
MACHINE_LABEL="$(remote_machine_label)"
echo "  remote machine:   $MACHINE_LABEL"
if [ -n "$AUDIO_MODE" ]; then
  echo "  audio mode:       $AUDIO_MODE"
else
  echo "  audio mode:       prompt after capture"
fi
if [ -n "$NOVNC_FOCUS_MODE" ]; then
  echo "  noVNC focus:      $NOVNC_FOCUS_MODE"
else
  echo "  noVNC focus:      prompt after capture"
fi
echo
echo "Keep QEMU running in the other remote SSH shell. Do not download WADs,"
echo "disk images, framebuffer data, screenshots, status binaries, or raw audio."
echo
echo "Phase capture plan:"
for index in "${!PHASES[@]}"; do
  echo "  ${PHASES[$index]} -> ${PHASE_STATUS_FILES[$index]} (${PHASE_HASH_KEYS[$index]}): ${PHASE_EXPECTED_SIGNALS[$index]}"
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
  status_path="$BUILD_DIR/${PHASE_STATUS_FILES[$index]}"
  echo "Phase status hash: ${PHASE_HASH_KEYS[$index]}=$(phase_status_hash "$status_path")"
  case "$phase" in
    after-start)
      prompt_phase_note START_NOTE "--start-note" "Status-only start note (what the human saw after E1M1/start)"
      ;;
    after-fire)
      prompt_phase_note FIRE_NOTE "--fire-note" "Status-only fire note (visible Ctrl/fire response)"
      ;;
    after-move)
      prompt_phase_note MOVE_NOTE "--move-note" "Status-only move note (visible arrow movement or turning)"
      ;;
    after-use)
      prompt_phase_note USE_NOTE "--use-note" "Status-only use note (visible Space/use response)"
      ;;
    after-mouse)
      prompt_phase_note MOUSE_NOTE "--mouse-note" "Status-only mouse note (visible movement/click response)"
      ;;
    after-menu)
      prompt_phase_note MENU_NOTE "--menu-note" "Status-only menu note (visible Escape menu response)"
      ;;
    final)
      prompt_phase_note FINAL_NOTE "--final-note" "Status-only final note (duration window and final state)"
      ;;
  esac
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

if [ -z "$AUDIO_MODE" ]; then
  while true; do
    printf "Audio observation? [status-only/listener-pass/audio-proof-json-pass/not-tested] "
    read -r AUDIO_MODE
    AUDIO_MODE="${AUDIO_MODE:-status-only}"
    case "$AUDIO_MODE" in
      status-only|listener-pass|audio-proof-json-pass|not-tested) break ;;
      *) echo "Please enter status-only, listener-pass, audio-proof-json-pass, or not-tested." ;;
    esac
  done
fi
case "$AUDIO_MODE" in
  status-only)
    echo "Audio evidence recorded as status-only SB16 continuity; no VNC audio claim is made."
    ;;
  listener-pass)
    echo "Audio evidence recorded as human listener-pass via remote audio forwarding."
    ;;
  audio-proof-json-pass)
    echo "Audio evidence recorded as aggregate audio-proof.json; collector will require that JSON."
    ;;
  not-tested)
    echo "Audio evidence recorded as not-tested for this manual VNC session."
    ;;
esac
if [ -z "$AUDIO_NOTES" ]; then
  case "$AUDIO_MODE" in
    status-only) AUDIO_NOTES="vnc-display-input-only-sb16-status" ;;
    listener-pass) AUDIO_NOTES="remote-audio-forwarding-listener-confirmed" ;;
    audio-proof-json-pass) AUDIO_NOTES="aggregate-audio-proof-json-validated" ;;
    not-tested) AUDIO_NOTES="audio-not-tested-in-manual-session" ;;
  esac
fi
validate_observation_notes "--audio-notes" "$AUDIO_NOTES"

if [ -z "$NOVNC_FOCUS_MODE" ]; then
  while true; do
    printf "noVNC focus observation? [canvas-focused-before-actions/focus-retaken-during-session/focus-issues-observed] "
    read -r NOVNC_FOCUS_MODE
    NOVNC_FOCUS_MODE="${NOVNC_FOCUS_MODE:-canvas-focused-before-actions}"
    case "$NOVNC_FOCUS_MODE" in
      canvas-focused-before-actions|focus-retaken-during-session|focus-issues-observed) break ;;
      *) echo "Please enter canvas-focused-before-actions, focus-retaken-during-session, or focus-issues-observed." ;;
    esac
  done
fi

if [ -z "$NOVNC_FOCUS_NOTES" ]; then
  printf "Short noVNC focus note, status-only, no logs/env/screenshots: "
  read -r NOVNC_FOCUS_NOTES
  [ -n "$NOVNC_FOCUS_NOTES" ] || NOVNC_FOCUS_NOTES="canvas-clicked-before-each-manual-action"
fi
validate_novnc_focus_fields

python3 tools/collect_human_playtest_bundle.py \
  --build-dir "$BUILD_DIR" \
  --output-dir "$OUTPUT_DIR" \
  --playtester "$PLAYTESTER" \
  --reviewer "$REVIEWER" \
  --scripted-proof-run-id "$SCRIPTED_PROOF_RUN_ID" \
  --machine-label "$MACHINE_LABEL" \
  --start-note "$START_NOTE" \
  --fire-note "$FIRE_NOTE" \
  --move-note "$MOVE_NOTE" \
  --use-note "$USE_NOTE" \
  --mouse-note "$MOUSE_NOTE" \
  --menu-note "$MENU_NOTE" \
  --final-note "$FINAL_NOTE" \
  --audio "$AUDIO_MODE" \
  --audio-notes "$AUDIO_NOTES" \
  --slowdown "$SLOWDOWN_MODE" \
  --slowdown-notes "$SLOWDOWN_NOTES" \
  --novnc-focus "$NOVNC_FOCUS_MODE" \
  --novnc-focus-notes "$NOVNC_FOCUS_NOTES" \
  --commit "$COMMIT_VALUE" \
  --ref "$REF_VALUE" \
  --confirm-scripted-proof-green \
  --confirm-remote-vnc \
  --confirm-e1m1-visible \
  --confirm-keyboard-fire \
  --confirm-keyboard-move \
  --confirm-keyboard-use \
  --confirm-mouse-action \
  --confirm-menu-escape \
  --confirm-audio-observation \
  --confirm-slowdown-notes \
  --confirm-novnc-focus-observation \
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
