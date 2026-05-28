#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREPARE_ASSETS_SH="${PREPARE_ASSETS_SH:-$SCRIPT_DIR/prepare_game_assets.sh}"
VIBE_PLAY_DATA_DIR="${VIBE_PLAY_DATA_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/vibe-os}"
PLAY_BUILD_DIR="${PLAY_BUILD_DIR:-build/play}"
MAKE_BIN="${MAKE:-make}"
QEMU_BIN="${QEMU:-qemu-system-x86_64}"
QEMU_EXTRA_ARGS="${QEMU_EXTRA_ARGS:-}"
VIBE_QEMU_ACCEL="${VIBE_QEMU_ACCEL:-auto}"
VIBE_QEMU_CPU="${VIBE_QEMU_CPU:-auto}"
VIBE_QEMU_DISPLAY="${VIBE_QEMU_DISPLAY:-auto}"
VIBE_QEMU_FULLSCREEN="${VIBE_QEMU_FULLSCREEN:-auto}"
VIBE_QEMU_ZOOM_TO_FIT="${VIBE_QEMU_ZOOM_TO_FIT:-auto}"
VIBE_QEMU_AUDIO="${VIBE_QEMU_AUDIO:-auto}"
PLAY_IMAGE="$PLAY_BUILD_DIR/disk.img"
PREPARE_ONLY=0

usage() {
  cat <<'EOF'
Usage: tools/play_local.sh [--prepare-only]

Prepare public shareware Doom and Quake data outside the repo, build one
ignored vibe-os disk image with both installed app directories, and launch the OS
launcher. On macOS, local QEMU execution is disabled by default; use
--prepare-only for the safe local handoff, or set ALLOW_LOCAL_VM=1 explicitly.
For the Raspberry Pi 4 desktop/play path, prefer make pi4-qemu-command for the
exact visible handoff or tools/play_now_codespaces.sh --pi4 for remote noVNC;
this script is the legacy x86 local launcher.

Environment overrides:
  DOOM_WAD=/path/to/DOOM1.WAD       Use an existing WAD instead of the cache.
  QUAKE_PAK=/path/to/PAK0.PAK       Use an existing PAK instead of the cache.
  VIBE_PLAY_DATA_DIR=/path/cache    Outside-repo cache directory passed to the
                                    reusable asset preparation helper.
  PREPARE_ASSETS_SH=tools/prepare_game_assets.sh
                                    Asset helper used for WAD/PAK validation.
  PLAY_BUILD_DIR=build/play         Build directory for the local play image.
  QEMU_EXTRA_ARGS='...'             Extra arguments passed to QEMU.
  VIBE_QEMU_ACCEL=auto|tcg|hvf      CPU accelerator. On Intel macOS, auto
                                    tries HVF first and falls back to TCG.
  VIBE_QEMU_CPU=auto|default|MODEL  Guest CPU model. On Intel macOS with HVF,
                                    auto uses Penryn to avoid AMD SVM warnings.
  VIBE_QEMU_DISPLAY=auto|default|none|BACKEND
                                    Display backend. On macOS, auto uses cocoa
                                    when available so the native QEMU window is
                                    explicit instead of backend-dependent.
  VIBE_QEMU_FULLSCREEN=auto|on|off  Fullscreen mode for the Cocoa display.
                                    On macOS, auto starts fullscreen.
  VIBE_QEMU_ZOOM_TO_FIT=auto|on|off Scale the guest framebuffer to the Cocoa
                                    window. On macOS, auto enables scaling.
  VIBE_QEMU_AUDIO=auto|off|BACKEND  Audio backend. On macOS, auto uses
                                    coreaudio when available.

Options:
  --prepare-only                    Download/cache data and build the image,
                                    but do not launch local QEMU.
  --dry-run                         Alias for --prepare-only; it still writes
                                    the ignored play image. For a no-write
                                    asset check, use prepare_game_assets.sh
                                    --dry-run.
  ALLOW_LOCAL_VM=1                  Required to launch QEMU on macOS.
  -h, --help                        Show this help.
EOF
}

print_play_controls() {
  cat <<'EOF'
Visible play controls:
  QEMU focus: click the guest window once before typing or using the mouse.
  Launcher: 1/click Doom, 2/click Quake, or W/S plus Enter from inside vibe-os.
  Doom: arrows move/turn, Ctrl fires, Space uses, Escape opens menu.
  Quake: WASD/arrows move, mouse aims, Ctrl or left mouse fires, Space jumps, Escape opens menu.
EOF
}

fail_play() {
  echo "play failed: $*" >&2
  exit 1
}

require_tool() {
  command -v "$1" >/dev/null 2>&1 || fail_play "missing required tool: $1"
}

qemu_help_has_backend() {
  local option="$1"
  local backend="$2"

  ( "$QEMU_BIN" "$option" help 2>&1 || true ) | awk -v backend="$backend" '
    $1 == backend || $0 == backend { found = 1 }
    END { exit found ? 0 : 1 }
  '
}

normalize_auto_bool() {
  local value="$1"
  local name="$2"

  case "$value" in
    auto|"")
      printf "auto\n"
      ;;
    on|yes|true|1)
      printf "on\n"
      ;;
    off|no|false|0)
      printf "off\n"
      ;;
    *)
      fail_play "$name must be auto, on, or off"
      ;;
  esac
}

cocoa_display_arg() {
  local zoom_to_fit
  local full_screen
  local display="cocoa"

  zoom_to_fit="$(normalize_auto_bool "$VIBE_QEMU_ZOOM_TO_FIT" "VIBE_QEMU_ZOOM_TO_FIT")"
  full_screen="$(normalize_auto_bool "$VIBE_QEMU_FULLSCREEN" "VIBE_QEMU_FULLSCREEN")"

  if [ "$zoom_to_fit" = "auto" ]; then
    zoom_to_fit="on"
  fi
  if [ "$full_screen" = "auto" ]; then
    full_screen="on"
  fi

  display="$display,zoom-to-fit=$zoom_to_fit,full-screen=$full_screen"
  printf "%s\n" "$display"
}

configure_qemu_machine_arg() {
  qemu_machine_arg="pc,accel=tcg"

  case "$VIBE_QEMU_ACCEL" in
    auto|"")
      if [ "$(uname -s)" = "Darwin" ] \
        && [ "$(uname -m)" = "x86_64" ] \
        && qemu_help_has_backend "-accel" "hvf"; then
        qemu_machine_arg="pc,accel=hvf:tcg"
      fi
      ;;
    tcg|hvf|kvm|whpx)
      qemu_machine_arg="pc,accel=$VIBE_QEMU_ACCEL"
      ;;
    *)
      fail_play "VIBE_QEMU_ACCEL must be auto, tcg, hvf, kvm, or whpx"
      ;;
  esac
}

configure_qemu_cpu_args() {
  qemu_cpu_args=()

  case "$VIBE_QEMU_CPU" in
    auto|"")
      if [ "$(uname -s)" = "Darwin" ] \
        && [ "$(uname -m)" = "x86_64" ]; then
        case "$qemu_machine_arg" in
          *accel=hvf*)
            qemu_cpu_args=(-cpu Penryn)
            ;;
        esac
      fi
      ;;
    default|none)
      ;;
    *)
      qemu_cpu_args=(-cpu "$VIBE_QEMU_CPU")
      ;;
  esac
}

configure_qemu_display_args() {
  qemu_display_args=()

  case "$VIBE_QEMU_DISPLAY" in
    auto)
      if [ "$(uname -s)" = "Darwin" ] && qemu_help_has_backend "-display" "cocoa"; then
        qemu_display_args=(-display "$(cocoa_display_arg)")
      fi
      ;;
    default|"")
      ;;
    none)
      qemu_display_args=(-display none)
      ;;
    cocoa)
      qemu_display_args=(-display "$(cocoa_display_arg)")
      ;;
    *)
      qemu_display_args=(-display "$VIBE_QEMU_DISPLAY")
      ;;
  esac
}

configure_qemu_audio_args() {
  local backend=""

  qemu_audio_args=()

  case "$VIBE_QEMU_AUDIO" in
    auto)
      if [ "$(uname -s)" = "Darwin" ] && qemu_help_has_backend "-audiodev" "coreaudio"; then
        backend="coreaudio"
      elif qemu_help_has_backend "-audiodev" "pipewire"; then
        backend="pipewire"
      elif qemu_help_has_backend "-audiodev" "pa"; then
        backend="pa"
      elif qemu_help_has_backend "-audiodev" "alsa"; then
        backend="alsa"
      elif qemu_help_has_backend "-audiodev" "none"; then
        backend="none"
      fi
      ;;
    off|none|"")
      ;;
    *)
      backend="$VIBE_QEMU_AUDIO"
      ;;
  esac

  if [ -n "$backend" ]; then
    qemu_audio_args=(-audiodev "$backend,id=snd0" -device sb16,audiodev=snd0)
  fi
}

configure_qemu_extra_args() {
  qemu_extra_args=()

  if [ -n "$QEMU_EXTRA_ARGS" ]; then
    # Match the existing Makefile convention: QEMU_EXTRA_ARGS is a simple
    # whitespace-separated list of extra QEMU arguments.
    read -r -a qemu_extra_args <<< "$QEMU_EXTRA_ARGS"
  fi
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --prepare-only|--dry-run)
      PREPARE_ONLY=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if [ "$PREPARE_ONLY" != "1" ] \
  && [ "$(uname -s)" = "Darwin" ] \
  && [ "${ALLOW_LOCAL_VM:-0}" != "1" ]; then
  cat >&2 <<'EOF'
Local QEMU execution is disabled by default on macOS.

Use --prepare-only to build the ignored local play image without booting a VM,
or use the remote Pi 4 visible-play path for the fullscreen Doom/Quake desktop:
  ./tools/play_now_codespaces.sh --pi4 --repo OWNER/REPO --ref BRANCH
Set ALLOW_LOCAL_VM=1 only when you intentionally want this Mac to launch QEMU.
EOF
  exit 1
fi

for tool in "$MAKE_BIN" sed; do
  require_tool "$tool"
done
[ -x "$PREPARE_ASSETS_SH" ] || fail_play "asset helper is not executable: $PREPARE_ASSETS_SH"

if [ "$PREPARE_ONLY" != "1" ]; then
  require_tool "$QEMU_BIN"
fi

asset_paths="$(VIBE_ASSET_CACHE_DIR="$VIBE_PLAY_DATA_DIR" "$PREPARE_ASSETS_SH" --format paths)"
doom_wad="$(printf "%s\n" "$asset_paths" | sed -n '1p')"
quake_pak="$(printf "%s\n" "$asset_paths" | sed -n '2p')"
[ -n "$doom_wad" ] || fail_play "asset helper did not return a DOOM1.WAD path"
[ -n "$quake_pak" ] || fail_play "asset helper did not return a PAK0.PAK path"

echo "Using DOOM1.WAD: $doom_wad"
echo "Using PAK0.PAK: $quake_pak"
echo "Building vibe-os play image in $PLAY_BUILD_DIR"
rm -f "$PLAY_IMAGE"
"$MAKE_BIN" --no-print-directory \
  BUILD_DIR="$PLAY_BUILD_DIR" \
  ALLOW_LOCAL_VM=0 \
  DOOM_WAD="$doom_wad" \
  QUAKE_PAK="$quake_pak" \
  build-only
test -s "$PLAY_IMAGE" || fail_play "expected build did not produce local play image: $PLAY_IMAGE"

if [ "$PREPARE_ONLY" = "1" ]; then
  echo "Prepared $PLAY_IMAGE without launching local QEMU."
  exit 0
fi

configure_qemu_display_args
configure_qemu_audio_args
configure_qemu_extra_args
configure_qemu_machine_arg
configure_qemu_cpu_args

rm -f "$PLAY_BUILD_DIR/monitor.sock" "$PLAY_BUILD_DIR/qemu.log" "$PLAY_BUILD_DIR/serial.log"
echo "Using exact local play image: $PLAY_IMAGE"
echo "Starting vibe-os. Click the QEMU window once, then press 1/click Doom or press 2/click Quake from the guest launcher."
print_play_controls
if [ "$(uname -s)" = "Darwin" ]; then
  echo "Local QEMU launch was explicitly enabled with ALLOW_LOCAL_VM=1."
  echo "Display default: cocoa,zoom-to-fit=on,full-screen=on unless VIBE_QEMU_DISPLAY/FULLSCREEN/ZOOM_TO_FIT override it."
fi
echo "If the QEMU window stays black, quit it and check $PLAY_BUILD_DIR/serial.log."
set -- \
  -machine "$qemu_machine_arg" \
  -m 128M \
  -vga none \
  -device "VGA,vgamem_mb=32,xres=2560,yres=1440" \
  -drive "file=$PLAY_IMAGE,format=raw,if=ide,index=0,media=disk" \
  -boot c
if [ ${#qemu_display_args[@]} -gt 0 ]; then
  set -- "$@" "${qemu_display_args[@]}"
fi
if [ ${#qemu_cpu_args[@]} -gt 0 ]; then
  set -- "$@" "${qemu_cpu_args[@]}"
fi
set -- "$@" \
  -serial "file:$PLAY_BUILD_DIR/serial.log" \
  -monitor "unix:$PLAY_BUILD_DIR/monitor.sock,server,nowait" \
  -D "$PLAY_BUILD_DIR/qemu.log" \
  -d guest_errors \
  -no-reboot \
  -no-shutdown
if [ ${#qemu_audio_args[@]} -gt 0 ]; then
  set -- "$@" "${qemu_audio_args[@]}"
fi
if [ ${#qemu_extra_args[@]} -gt 0 ]; then
  set -- "$@" "${qemu_extra_args[@]}"
fi
exec "$QEMU_BIN" "$@"
