#!/usr/bin/env bash
set -euo pipefail

print_visible_play_controls() {
  cat <<'EOF'
Visible play controls:
  noVNC focus: click the scaled canvas once before typing or using the mouse.
  Launcher: 1/click Doom, 2/click Quake, or W/S plus Enter from inside vibe-os.
  Pi Doom: W/Up forward, S/Down back, A/Left and D/Right turn, Space/Enter/Ctrl or left mouse fires.
  Pi Quake: WASD moves, arrows look, Ctrl/Enter or left mouse fires, Space/Shift jumps, Escape toggles menu.
  x86 Doom: arrows move/turn, Ctrl fires, Space uses, Escape opens menu.
EOF
}

usage() {
  cat <<'EOF'
Usage: tools/play_now_cloud_shell.sh [--pi4|--x86|--mode MODE] [--preflight|--dry-run] [--require-novnc]

Bootstrap a disposable Ubuntu shell for vibe-os play-now, then run the shell-only
remote launcher. This helper is intentionally thin; the OS work lives in the
bootloader, kernel, drivers, runtime, and Doom platform layer.

Use this only inside a disposable Linux host. It is not a local Mac QEMU path,
and visible play over noVNC is separate from status/proof gates.

Modes:
  --pi4                   Boot the Pi 4 hardware-equivalent real-assets
                          desktop over noVNC. Default. The launcher image
                          includes public Doom and Quake assets, USB keyboard
                          and mouse input, and the in-OS Doom/Quake picker;
                          the remote launcher prints the exact image/kernel
                          paths, hashes, and visible QEMU argv before launch.
  --x86                   Boot the legacy x86 Doom image over noVNC.
  --mode MODE             MODE may be x86 or pi4.

Options are passed through to tools/play_now_remote.sh after clone. WADs, PAKs,
disk images, screenshots, raw audio, VM logs, tokens, and one-time codes stay on
the disposable host. The default noVNC page is
/vnc.html?autoconnect=1&resize=scale; open the browser fullscreen, click the
scaled canvas once, then press 1/click Doom or press 2/click Quake. Pi mode
prepares and boots PI4_REAL_ASSET_IMAGE and prints its handoff, sha256, and
QEMU USB input args before launch:
  -M raspi4b,usb=on -device usb-kbd -device usb-mouse
EOF
}

repo="${VIBE_REPO:-jadentripp/vibe-os}"
ref="${VIBE_REF:-main}"
workdir="${VIBE_WORKDIR:-/tmp/vibe-os-cloud-play}"
remote_args=()
mode_seen=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --x86|--pi4)
      remote_args+=("$1")
      mode_seen=1
      ;;
    --preflight|--dry-run|--require-novnc)
      remote_args+=("$1")
      ;;
    --mode|--kind)
      [ "$#" -ge 2 ] || { echo "$1 requires x86 or pi4" >&2; exit 2; }
      remote_args+=("$1" "$2")
      mode_seen=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if [ "$(uname -s)" = "Darwin" ] && [ "${ALLOW_LOCAL_VM:-0}" != "1" ]; then
  echo "Refusing to run QEMU on macOS; use a disposable Linux host." >&2
  exit 1
fi

if [ "$mode_seen" = "0" ]; then
  remote_args=(--pi4 "${remote_args[@]}")
fi

if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y --no-install-recommends \
    ca-certificates git make nasm clang qemu-system-x86 qemu-system-arm netcat-openbsd curl gzip tar unzip novnc websockify
fi

rm -rf "$workdir"
git clone --depth=1 --branch "$ref" "https://github.com/$repo.git" "$workdir"
cd "$workdir"
echo "Starting remote visible play. Pi mode prepares the exact PI4_REAL_ASSET_IMAGE, prints its handoff/hash and QEMU USB keyboard/mouse args, then starts noVNC with autoconnect plus resize=scale."
echo "Open the printed noVNC URL in browser fullscreen, click the scaled canvas once, then press 1/click Doom or press 2/click Quake inside vibe-os."
print_visible_play_controls
exec ./tools/play_now_remote.sh --require-novnc "${remote_args[@]}"
