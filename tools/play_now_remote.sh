#!/usr/bin/env bash
set -euo pipefail

PUBLIC_SHAREWARE_WAD_GZ_URL="${PUBLIC_SHAREWARE_WAD_GZ_URL:-https://archive.org/download/wadarchive/DATA/5b.zip/5b%2F2e249b9c5133ec987b3ea77596381dc0d6bc1d%2F5b2e249b9c5133ec987b3ea77596381dc0d6bc1d.wad.gz}"
DOOM_WAD_URL="${DOOM_WAD_URL:-$PUBLIC_SHAREWARE_WAD_GZ_URL}"
WAD_PATH="${WAD_PATH:-/tmp/vibe-os-DOOM1.WAD}"
VNC_DISPLAY="${VNC_DISPLAY:-1}"
NOVNC_PORT="${NOVNC_PORT:-6080}"
NOVNC_WEB_ROOT="${NOVNC_WEB_ROOT:-}"
PLAY_BUILD_DIR="${PLAY_BUILD_DIR:-build/play-now}"
DIAGNOSTICS_SCRIPT="${DIAGNOSTICS_SCRIPT:-/tmp/vibe-os-play-now-diagnostics.sh}"
STOP_SCRIPT="${STOP_SCRIPT:-/tmp/vibe-os-play-now-stop.sh}"
PLAY_NOW_PID_FILE="${PLAY_NOW_PID_FILE:-/tmp/vibe-os-play-now.pid}"
PLAY_NOW_PORT_FILE="${PLAY_NOW_PORT_FILE:-/tmp/vibe-os-play-now.novnc-port}"
RUN_PREFLIGHT_ONLY=0
REQUIRE_NOVNC=0
VNC_PORT=""
NOVNC_WEB_ROOT_RESOLVED=""

usage() {
  cat <<'EOF'
Usage: tools/play_now_remote.sh [--preflight|--dry-run] [--require-novnc]

Run on a disposable remote Linux host or GitHub Codespace. The default path
fetches the public shareware WAD into /tmp, builds the disk image, exposes QEMU
over loopback-only VNC, and starts a noVNC bridge when available.

Options:
  --preflight, --dry-run  Check host safety and dependencies, then exit before
                          fetching a WAD, building, or launching QEMU.
  --require-novnc         Fail preflight if noVNC/websockify is unavailable.
  -h, --help              Show this help.
EOF
}

fail_remote() {
  echo "play-now remote failed: $*" >&2
  exit 1
}

require_tool() {
  command -v "$1" >/dev/null 2>&1 || fail_remote "missing required remote tool: $1"
}

validate_tcp_port() {
  local name="$1"
  local value="$2"

  case "$value" in
    ''|*[!0-9]*)
      fail_remote "$name must be a TCP port number, got '$value'"
      ;;
  esac
  if [ "$value" -lt 1 ] || [ "$value" -gt 65535 ]; then
    fail_remote "$name must be between 1 and 65535, got '$value'"
  fi
}

validate_vnc_display() {
  local value="$1"
  local display

  case "$value" in
    ''|*[!0-9]*)
      fail_remote "VNC_DISPLAY must be a non-negative integer, got '$value'"
      ;;
  esac
  display=$((10#$value))
  if [ "$display" -gt 59635 ]; then
    fail_remote "VNC_DISPLAY must map to a TCP port between 5900 and 65535, got '$value'"
  fi
  VNC_PORT=$((5900 + display))
}

loopback_port_in_use() {
  local port="$1"

  if command -v nc >/dev/null 2>&1; then
    nc -z 127.0.0.1 "$port" >/dev/null 2>&1
    return $?
  fi
  if command -v ss >/dev/null 2>&1; then
    ss -ltn "sport = :$port" 2>/dev/null | grep -q "127.0.0.1:$port"
    return $?
  fi
  return 1
}

ensure_loopback_port_free() {
  local label="$1"
  local port="$2"

  if loopback_port_in_use "$port"; then
    fail_remote "$label port 127.0.0.1:$port is already in use; stop the old remote play session or choose another port"
  fi
}

resolve_novnc_web_root() {
  local root

  if [ -n "$NOVNC_WEB_ROOT" ]; then
    [ -d "$NOVNC_WEB_ROOT" ] || fail_remote "NOVNC_WEB_ROOT does not exist: $NOVNC_WEB_ROOT"
    printf "%s\n" "$NOVNC_WEB_ROOT"
    return 0
  fi

  for root in /usr/share/novnc /usr/local/share/novnc /opt/homebrew/share/novnc; do
    if [ -d "$root" ]; then
      printf "%s\n" "$root"
      return 0
    fi
  done
  return 0
}

absolute_path() {
  local path="$1"
  local dir
  local base

  dir="$(dirname "$path")"
  base="$(basename "$path")"
  mkdir -p "$dir"
  dir="$(cd "$dir" && pwd)"
  printf "%s/%s\n" "$dir" "$base"
}

ensure_wad_path_outside_repo() {
  local wad_abs
  local repo_root

  wad_abs="$(absolute_path "$WAD_PATH")"
  repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
  repo_root="$(cd "$repo_root" && pwd)"
  case "$wad_abs" in
    "$repo_root"|"$repo_root"/*)
      fail_remote "WAD_PATH must stay outside the git checkout; refusing repo-local path: $wad_abs"
      ;;
  esac
}

file_magic_hex() {
  od -An -N"$1" -tx1 "$2" | tr -d ' \n'
}

validate_wad() {
  local path="$1"
  local magic
  local size

  [ -s "$path" ] || fail_remote "WAD is empty: $path"
  magic="$(dd if="$path" bs=4 count=1 2>/dev/null || true)"
  if [ "$magic" != "IWAD" ] && [ "$magic" != "PWAD" ]; then
    fail_remote "downloaded file is not a Doom WAD: $path"
  fi
  size="$(wc -c < "$path" | tr -d ' ')"
  if [ "$size" -lt 1048576 ]; then
    fail_remote "WAD is too small to be DOOM1.WAD: $size bytes"
  fi
}

fetch_shareware_wad() {
  local tmp
  local magic2
  local magic4
  local member

  tmp="$(mktemp "${TMPDIR:-/tmp}/vibe-os-wad.XXXXXX")"
  curl --fail --silent --show-error --location "$DOOM_WAD_URL" --output "$tmp"
  magic2="$(file_magic_hex 2 "$tmp")"
  magic4="$(file_magic_hex 4 "$tmp")"

  if [ "$magic2" = "1f8b" ]; then
    require_tool gzip
    gzip -cd "$tmp" > "$WAD_PATH"
  elif [ "$magic4" = "504b0304" ]; then
    require_tool unzip
    member="$(unzip -Z -1 "$tmp" | awk 'toupper($0) ~ /(^|\/)DOOM1[.]WAD$/ { print; exit }')"
    [ -n "$member" ] || fail_remote "zip did not contain DOOM1.WAD"
    unzip -p "$tmp" "$member" > "$WAD_PATH"
  elif [ "$magic4" = "49574144" ] || [ "$magic4" = "50574144" ]; then
    cp "$tmp" "$WAD_PATH"
  else
    rm -f "$tmp"
    fail_remote "downloaded file is not a WAD, gzip-compressed WAD, or zip containing DOOM1.WAD"
  fi

  rm -f "$tmp"
  validate_wad "$WAD_PATH"
}

codespaces_novnc_url() {
  if [ -n "${CODESPACE_NAME:-}" ] && [ -n "${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-}" ]; then
    printf 'https://%s-%s.%s/vnc.html?autoconnect=1\n' \
      "$CODESPACE_NAME" \
      "$NOVNC_PORT" \
      "$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN"
  fi
}

write_play_now_metadata() {
  printf "%s\n" "$NOVNC_PORT" > "$PLAY_NOW_PORT_FILE"
}

cleanup_play_now_metadata() {
  rm -f "$PLAY_NOW_PID_FILE" "$PLAY_NOW_PORT_FILE"
}

write_helpers() {
  local repo_dir
  local play_build_abs

  repo_dir="$(pwd)"
  mkdir -p "$PLAY_BUILD_DIR"
  play_build_abs="$(cd "$PLAY_BUILD_DIR" && pwd)"

  cat > "$STOP_SCRIPT" <<EOF_STOP
#!/usr/bin/env bash
set -euo pipefail
if [ -s "$PLAY_NOW_PID_FILE" ]; then
  pid="\$(cat "$PLAY_NOW_PID_FILE")"
  if kill -0 "\$pid" >/dev/null 2>&1; then
    kill "\$pid"
    echo "stopped vibe-os play-now pid \$pid"
  else
    echo "vibe-os play-now pid \$pid was not running"
  fi
else
  echo "no vibe-os play-now pid file found"
fi
EOF_STOP
  chmod +x "$STOP_SCRIPT"

  cat > "$DIAGNOSTICS_SCRIPT" <<EOF_DIAG
#!/usr/bin/env bash
set -euo pipefail
repo_dir="$repo_dir"
play_build_dir="$play_build_abs"
pid_file="$PLAY_NOW_PID_FILE"
port_file="$PLAY_NOW_PORT_FILE"
serial_log="\$play_build_dir/serial.log"
novnc_log="\$play_build_dir/novnc.log"

if [ "\${1:-}" = "--json" ]; then
  pid="\$(cat "\$pid_file" 2>/dev/null || true)"
  running=false
  if [ -n "\$pid" ] && kill -0 "\$pid" >/dev/null 2>&1; then
    running=true
  fi
  printf '{ "running": %s, "pid": "%s", "novnc_port": "%s", "serial_log": "%s" }\\n' \
    "\$running" "\$pid" "\$(cat "\$port_file" 2>/dev/null || true)" "\$serial_log"
  exit 0
fi

echo "vibe-os play-now diagnostics"
echo "repo: \$repo_dir"
if [ -s "\$pid_file" ]; then
  pid="\$(cat "\$pid_file")"
  if kill -0 "\$pid" >/dev/null 2>&1; then
    echo "play-now pid: \$pid (running)"
    ps -p "\$pid" -o pid=,etime=,pcpu=,pmem=,comm= 2>/dev/null | sed 's/^/play-now process: /' || true
  else
    echo "play-now pid: \$pid (not running)"
  fi
else
  echo "play-now pid: missing"
fi
if [ -s "\$serial_log" ]; then
  echo
  echo "latest guest status fields:"
  tr ' ' '\\n' < "\$serial_log" | grep -E '^(panic|shutdown|doomrun|gameplay|audio|doompresent|dtick|preempt|inputqueue|musicbuf|mixunder)=' | tail -40 || true
fi
if [ -s "\$novnc_log" ]; then
  echo
  echo "noVNC log tail:"
  tail -20 "\$novnc_log"
fi
EOF_DIAG
  chmod +x "$DIAGNOSTICS_SCRIPT"
}

print_preflight() {
  echo "play-now remote preflight OK"
  echo "platform: $(uname -s)"
  echo "noVNC port: $NOVNC_PORT"
  echo "QEMU VNC display: :$VNC_DISPLAY (127.0.0.1:$VNC_PORT)"
  echo "required tools:"
  for tool in make nasm clang qemu-system-x86_64 curl; do
    echo "  $tool: $(command -v "$tool")"
  done
  echo "optional noVNC:"
  if command -v websockify >/dev/null 2>&1 && [ -n "${NOVNC_WEB_ROOT_RESOLVED:-}" ]; then
    echo "  websockify: $(command -v websockify)"
    echo "  web root: $NOVNC_WEB_ROOT_RESOLVED"
    echo "  browser proxy: available"
  else
    echo "  browser proxy: unavailable"
  fi
  echo "dry-run: QEMU was not launched"
  echo "next: run ./tools/play_now_remote.sh on the remote host"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --preflight|--dry-run)
      RUN_PREFLIGHT_ONLY=1
      ;;
    --require-novnc)
      REQUIRE_NOVNC=1
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

validate_tcp_port NOVNC_PORT "$NOVNC_PORT"
validate_vnc_display "$VNC_DISPLAY"
if [ "$NOVNC_PORT" -eq "$VNC_PORT" ]; then
  fail_remote "NOVNC_PORT and VNC_DISPLAY both map to 127.0.0.1:$NOVNC_PORT; choose different ports"
fi

for tool in make nasm clang qemu-system-x86_64 curl; do
  require_tool "$tool"
done

if command -v websockify >/dev/null 2>&1; then
  NOVNC_WEB_ROOT_RESOLVED="$(resolve_novnc_web_root)"
fi
if [ "$REQUIRE_NOVNC" = "1" ] && { ! command -v websockify >/dev/null 2>&1 || [ -z "$NOVNC_WEB_ROOT_RESOLVED" ]; }; then
  fail_remote "noVNC was required but websockify or a noVNC web root is unavailable"
fi

if [ "$RUN_PREFLIGHT_ONLY" = "1" ]; then
  print_preflight
  exit 0
fi

ensure_wad_path_outside_repo
ensure_loopback_port_free "QEMU VNC" "$VNC_PORT"
if command -v websockify >/dev/null 2>&1 && [ -n "$NOVNC_WEB_ROOT_RESOLVED" ]; then
  ensure_loopback_port_free "noVNC" "$NOVNC_PORT"
fi

write_helpers
write_play_now_metadata
echo "$$" > "$PLAY_NOW_PID_FILE"

cleanup() {
  if [ -n "${QEMU_PID:-}" ]; then
    kill "$QEMU_PID" >/dev/null 2>&1 || true
    wait "$QEMU_PID" 2>/dev/null || true
  fi
  if [ -n "${WEBSOCKIFY_PID:-}" ]; then
    kill "$WEBSOCKIFY_PID" >/dev/null 2>&1 || true
    wait "$WEBSOCKIFY_PID" 2>/dev/null || true
  fi
  cleanup_play_now_metadata
}
terminate() {
  cleanup
  exit 130
}
trap cleanup EXIT
trap terminate INT TERM

echo "Diagnostics helper: $DIAGNOSTICS_SCRIPT"
echo "Stop helper: $STOP_SCRIPT"
echo "Fetching/validating shareware DOOM1.WAD into $WAD_PATH"
echo "Remote artifact policy: WADs, disk images, pixels, raw audio, logs, tokens, and one-time codes stay on this disposable host."
fetch_shareware_wad

echo "Building vibe-os disk image with shareware Doom data"
rm -f build/disk.img
make DOOM_WAD="$WAD_PATH"
mkdir -p "$PLAY_BUILD_DIR"

if command -v websockify >/dev/null 2>&1 && [ -n "$NOVNC_WEB_ROOT_RESOLVED" ]; then
  websockify --web="$NOVNC_WEB_ROOT_RESOLVED" "127.0.0.1:$NOVNC_PORT" "127.0.0.1:$VNC_PORT" \
    >"$PLAY_BUILD_DIR/novnc.log" 2>&1 &
  WEBSOCKIFY_PID="$!"
  sleep 1
  if ! kill -0 "$WEBSOCKIFY_PID" >/dev/null 2>&1; then
    wait "$WEBSOCKIFY_PID" 2>/dev/null || true
    fail_remote "websockify exited before noVNC was ready; see $PLAY_BUILD_DIR/novnc.log"
  fi
  echo "noVNC web root: $NOVNC_WEB_ROOT_RESOLVED"
  echo "noVNC tunnel/local URL: http://127.0.0.1:$NOVNC_PORT/vnc.html?autoconnect=1"
  if codespaces_url="$(codespaces_novnc_url)" && [ -n "$codespaces_url" ]; then
    echo "Codespaces noVNC URL: $codespaces_url"
  fi
  echo "In Codespaces, forward port $NOVNC_PORT and open the forwarded URL with path /vnc.html?autoconnect=1."
else
  echo "noVNC not found; use SSH VNC tunnel instead:"
  echo "  ssh -L $VNC_PORT:127.0.0.1:$VNC_PORT user@remote-host"
  echo "Then connect a VNC client to localhost:$VNC_PORT."
fi

echo "Starting remote QEMU VNC display :$VNC_DISPLAY on 127.0.0.1:$VNC_PORT"
echo "Launcher: press 1 or click Doom. In Doom, arrows move/turn, Ctrl fires, Space uses, Escape opens menu."
echo "Audio: this quick VNC path exposes display/input; audio proof remains status-only here."
qemu-system-x86_64 \
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
  -no-shutdown &
QEMU_PID="$!"
sleep 1
if ! kill -0 "$QEMU_PID" >/dev/null 2>&1; then
  wait "$QEMU_PID" 2>/dev/null || true
  fail_remote "QEMU exited immediately; see $PLAY_BUILD_DIR/serial.log and $PLAY_BUILD_DIR/novnc.log if present"
fi
wait "$QEMU_PID"
