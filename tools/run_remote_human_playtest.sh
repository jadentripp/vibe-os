#!/usr/bin/env bash
set -euo pipefail

BUILD_DIR="${BUILD_DIR:-build}"
MONITOR_SOCKET="${MONITOR_SOCKET:-build/play-now/monitor.sock}"
OUTPUT_DIR="${OUTPUT_DIR:-/tmp/vibe-os-human-proof}"
TARBALL="${TARBALL:-/tmp/vibe-os-human-proof.tgz}"
AUDIO_MODE="${AUDIO_MODE:-status-only}"
PLAYTESTER=""
SCRIPTED_PROOF_RUN_ID=""
COMMIT_ARG=()

usage() {
  cat <<'EOF'
Usage: tools/run_remote_human_playtest.sh --playtester NAME --scripted-proof-run-id RUN_ID [options]

Run this from a second SSH shell on the disposable remote Linux host while
tools/play_now_remote.sh is running QEMU there. The script prompts for each
manual Doom action, captures the status page through the remote QEMU monitor,
builds the allowlisted human proof bundle, validates it before download, and
prints the exact local download/check commands.

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
  --commit HASH                  Commit under test; defaults to git HEAD.
  -h, --help                     Show this help.
EOF
}

die() {
  echo "remote human playtest failed: $*" >&2
  exit 1
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
    --commit)
      [ "$#" -ge 2 ] || die "--commit requires a value"
      COMMIT_ARG=(--commit "$2")
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
[ -d "$BUILD_DIR" ] || die "build directory does not exist: $BUILD_DIR"
[ -S "$MONITOR_SOCKET" ] || die "remote QEMU monitor socket does not exist: $MONITOR_SOCKET"

case "$AUDIO_MODE" in
  status-only|listener-pass|audio-proof-json-pass|not-tested) ;;
  *) die "--audio must be status-only, listener-pass, audio-proof-json-pass, or not-tested" ;;
esac

output_parent="$(dirname "$OUTPUT_DIR")"
output_base="$(basename "$OUTPUT_DIR")"
mkdir -p "$output_parent"
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

echo "Remote human Doom proof capture"
echo "  build dir:        $BUILD_DIR"
echo "  monitor socket:   $MONITOR_SOCKET"
echo "  proof output dir: $OUTPUT_DIR"
echo "  proof tarball:    $TARBALL"
echo
echo "Keep QEMU running in the other remote SSH shell. Do not download WADs,"
echo "disk images, framebuffer data, screenshots, status binaries, or raw audio."
echo

for index in "${!PHASES[@]}"; do
  phase="${PHASES[$index]}"
  prompt="${PHASE_PROMPTS[$index]}"
  echo "[$phase] $prompt"
  printf "Press Enter when ready to capture %s..." "$phase"
  read -r _
  python3 tools/collect_human_playtest_bundle.py \
    --build-dir "$BUILD_DIR" \
    --monitor-socket "$MONITOR_SOCKET" \
    --capture-phase "$phase"
  echo
done

python3 tools/collect_human_playtest_bundle.py \
  --build-dir "$BUILD_DIR" \
  --output-dir "$OUTPUT_DIR" \
  --playtester "$PLAYTESTER" \
  --scripted-proof-run-id "$SCRIPTED_PROOF_RUN_ID" \
  --audio "$AUDIO_MODE" \
  "${COMMIT_ARG[@]}" \
  --confirm-remote-vnc \
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
  python3 tools/check_cloud_playability_artifacts.py --human-session ./vibe-os-human-proof
EOF
echo
echo "Compare the local post-download human verification OK line with the"
echo "pre-download human verification OK line printed above."
