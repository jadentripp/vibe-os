#!/usr/bin/env bash
set -euo pipefail

PUBLIC_SHAREWARE_WAD_GZ_URL="${PUBLIC_SHAREWARE_WAD_GZ_URL:-https://archive.org/download/wadarchive/DATA/5b.zip/5b%2F2e249b9c5133ec987b3ea77596381dc0d6bc1d%2F5b2e249b9c5133ec987b3ea77596381dc0d6bc1d.wad.gz}"
DOOM_WAD_URL="${DOOM_WAD_URL:-$PUBLIC_SHAREWARE_WAD_GZ_URL}"
WAD_PATH="${WAD_PATH:-/tmp/vibe-os-DOOM1.WAD}"
VNC_DISPLAY="${VNC_DISPLAY:-1}"
NOVNC_PORT="${NOVNC_PORT:-6080}"
PLAY_BUILD_DIR="${PLAY_BUILD_DIR:-build/play-now}"

usage() {
  cat <<'EOF'
Usage: tools/play_now_remote.sh [--preflight|--dry-run]

Run on a disposable remote Linux host or GitHub Codespace. The default path
fetches the public shareware WAD into /tmp, builds the disk image, exposes QEMU
over loopback-only VNC, and starts a noVNC bridge when available.

Options:
  --preflight, --dry-run  Check host safety and dependencies, then exit before
                         fetching a WAD, building, or launching QEMU.
  -h, --help             Show this help.
EOF
}

RUN_PREFLIGHT_ONLY=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --preflight|--dry-run)
      RUN_PREFLIGHT_ONLY=1
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
  cat >&2 <<'EOF'
Refusing to run QEMU on macOS.

Use this script inside a disposable remote Linux host, GitHub Codespace, or
cloud VM. The supported play-now path keeps QEMU off the local Mac.
EOF
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "missing python3" >&2
  echo "Ubuntu setup: sudo apt-get update && sudo apt-get install -y nasm qemu-system-x86 clang make netcat-openbsd curl novnc websockify" >&2
  exit 1
fi

python3 tools/check_play_now_remote.py
if [ "$RUN_PREFLIGHT_ONLY" = "1" ]; then
  exit 0
fi

codespaces_novnc_url() {
  if [ -n "${CODESPACE_NAME:-}" ] && [ -n "${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-}" ]; then
    printf 'https://%s-%s.%s/vnc.html?autoconnect=1\n' \
      "$CODESPACE_NAME" \
      "$NOVNC_PORT" \
      "$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN"
  fi
}

cleanup() {
  if [ -n "${WEBSOCKIFY_PID:-}" ]; then
    kill "$WEBSOCKIFY_PID" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT INT TERM

mkdir -p "$PLAY_BUILD_DIR"

echo "Fetching/validating shareware DOOM1.WAD into $WAD_PATH"
python3 tools/prepare_shareware_wad.py \
  --url "$DOOM_WAD_URL" \
  --output "$WAD_PATH"

echo "Building vibe-os Doom disk image"
make DOOM_WAD="$WAD_PATH"

if command -v websockify >/dev/null 2>&1 && [ -d /usr/share/novnc ]; then
  websockify --web=/usr/share/novnc "127.0.0.1:$NOVNC_PORT" "127.0.0.1:$((5900 + VNC_DISPLAY))" \
    >"$PLAY_BUILD_DIR/novnc.log" 2>&1 &
  WEBSOCKIFY_PID="$!"
  echo "noVNC tunnel/local URL: http://127.0.0.1:$NOVNC_PORT/vnc.html?autoconnect=1"
  if codespaces_url="$(codespaces_novnc_url)" && [ -n "$codespaces_url" ]; then
    echo "Codespaces noVNC URL: $codespaces_url"
  fi
  echo "In Codespaces, forward port $NOVNC_PORT and open the forwarded URL with path /vnc.html?autoconnect=1."
else
  echo "noVNC not found; use SSH VNC tunnel instead:"
  echo "  ssh -L $((5900 + VNC_DISPLAY)):127.0.0.1:$((5900 + VNC_DISPLAY)) user@remote-host"
  echo "Then connect a VNC client to localhost:$((5900 + VNC_DISPLAY))."
fi

echo "Starting remote QEMU VNC display :$VNC_DISPLAY on 127.0.0.1:$((5900 + VNC_DISPLAY))"
echo "Controls: arrows move/turn, Ctrl fires, Space uses, Escape opens menu."
exec qemu-system-x86_64 \
  -machine pc,accel=tcg \
  -m 128M \
  -audiodev none,id=snd0 \
  -device sb16,audiodev=snd0 \
  -drive file=build/disk.img,format=raw,if=ide,index=0,media=disk \
  -boot c \
  -display "vnc=127.0.0.1:$VNC_DISPLAY" \
  -serial "file:$PLAY_BUILD_DIR/serial.log" \
  -monitor "unix:$PLAY_BUILD_DIR/monitor.sock,server,nowait" \
  -no-reboot \
  -no-shutdown
