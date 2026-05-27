#!/usr/bin/env bash
set -euo pipefail

PUBLIC_SHAREWARE_WAD_GZ_URL="${PUBLIC_SHAREWARE_WAD_GZ_URL:-https://archive.org/download/wadarchive/DATA/5b.zip/5b%2F2e249b9c5133ec987b3ea77596381dc0d6bc1d%2F5b2e249b9c5133ec987b3ea77596381dc0d6bc1d.wad.gz}"
DOOM_WAD_URL="${DOOM_WAD_URL:-$PUBLIC_SHAREWARE_WAD_GZ_URL}"
WAD_PATH="${WAD_PATH:-/tmp/vibe-os-DOOM1.WAD}"
PLAY_MODE="${VIBE_PLAY_MODE:-${VIBE_PLAY_KIND:-pi4}}"
VNC_DISPLAY="${VNC_DISPLAY:-1}"
NOVNC_PORT="${NOVNC_PORT:-6080}"
NOVNC_WEB_ROOT="${NOVNC_WEB_ROOT:-}"
NOVNC_VNC_PATH="${NOVNC_VNC_PATH:-/vnc.html?autoconnect=1&resize=scale}"
PLAY_BUILD_DIR="${PLAY_BUILD_DIR:-build/play-now}"
DIAGNOSTICS_SCRIPT="${DIAGNOSTICS_SCRIPT:-/tmp/vibe-os-play-now-diagnostics.sh}"
STOP_SCRIPT="${STOP_SCRIPT:-/tmp/vibe-os-play-now-stop.sh}"
PLAY_NOW_PID_FILE="${PLAY_NOW_PID_FILE:-/tmp/vibe-os-play-now.pid}"
PLAY_NOW_PORT_FILE="${PLAY_NOW_PORT_FILE:-/tmp/vibe-os-play-now.novnc-port}"
NOVNC_READY_WAIT_SECONDS="${NOVNC_READY_WAIT_SECONDS:-30}"
NOVNC_READY_WAIT_INTERVAL="${NOVNC_READY_WAIT_INTERVAL:-1}"
PI4_QEMU="${PI4_HW_EQUIVALENT_QEMU:-qemu-system-aarch64}"
PI4_QEMU_INPUT_ARGS="-M raspi4b,usb=on -device usb-kbd -device usb-mouse"
PI4_KERNEL8_IMG="${PI4_KERNEL8_IMG:-build/pi4/kernel8.img}"
PI4_IMAGE="${PI4_IMAGE:-build/pi4/pi4-fat16.img}"
PI4_REAL_ASSET_IMAGE="${PI4_REAL_ASSET_IMAGE:-${PI4_EXACT_BOOT_IMAGE:-}}"
if [ -z "$PI4_REAL_ASSET_IMAGE" ]; then
  if [ "$PI4_IMAGE" != "build/pi4/pi4-fat16.img" ]; then
    PI4_REAL_ASSET_IMAGE="$PI4_IMAGE"
  else
    PI4_REAL_ASSET_IMAGE="build/pi4/pi4-real-assets-fat16.img"
  fi
fi
PI4_REAL_ASSET_HANDOFF="${PI4_REAL_ASSET_HANDOFF:-build/pi4/pi4-real-assets-handoff.txt}"
RUN_PREFLIGHT_ONLY=0
REQUIRE_NOVNC=0
VNC_PORT=""
NOVNC_WEB_ROOT_RESOLVED=""

usage() {
  cat <<'EOF'
Usage: tools/play_now_remote.sh [--pi4|--x86|--mode MODE] [--preflight|--dry-run] [--require-novnc]

Run on a disposable remote Linux host or GitHub Codespace. The default path
prepares public Doom and Quake shareware assets outside the repo, builds the
Pi 4 real-assets desktop image, exposes QEMU over loopback-only VNC, and starts
a scaled noVNC bridge when available.

Modes:
  --pi4                   Build and boot the Pi 4 hardware-equivalent image
                          with qemu-system-aarch64 raspi4b, real WAD/PAK
                          assets, USB keyboard/mouse, and the in-OS
                          Doom/Quake launcher. Default.
                          This is remote visible play, not real Raspberry Pi
                          hardware proof.
  --x86                   Build and boot the legacy x86 Doom image.
  --mode MODE             MODE may be x86 or pi4.

Options:
  --preflight, --dry-run  Check host safety and dependencies, then exit before
                          fetching a WAD, building, or launching QEMU.
  --require-novnc         Fail preflight if noVNC/websockify is unavailable.
  -h, --help              Show this help.

Environment:
  PI4_REAL_ASSET_IMAGE=/path/pi4-fat16.img
                          Exact Pi 4 image path to build and boot. The legacy
                          PI4_IMAGE name is accepted as a compatibility alias
                          only when PI4_REAL_ASSET_IMAGE is not set.
  PI4_REAL_ASSET_HANDOFF=/path/handoff.txt
                          Exact-image handoff written next to the image.
  NOVNC_VNC_PATH='/vnc.html?autoconnect=1&resize=scale'
                          noVNC page/options. The default autoconnects and
                          scales the guest desktop to the browser window.

Pi 4 visible play:
  The launcher prepares and boots PI4_REAL_ASSET_IMAGE, not the fixture image.
  Open the noVNC URL fullscreen with resize=scale, click the canvas once, then
  select Doom with 1/click or Quake with 2/click inside the vibe-os desktop.
EOF
}

fail_remote() {
  echo "play-now remote failed: $*" >&2
  exit 1
}

require_tool() {
  command -v "$1" >/dev/null 2>&1 || fail_remote "missing required remote tool: $1"
}

validate_play_mode() {
  case "$PLAY_MODE" in
    x86|pi4)
      ;;
    *)
      fail_remote "PLAY_MODE must be x86 or pi4, got '$PLAY_MODE'"
      ;;
  esac
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

validate_novnc_path() {
  case "$NOVNC_VNC_PATH" in
    *$'\n'*|*$'\r'*|*' '*|*'	'*|*\'*)
      fail_remote "NOVNC_VNC_PATH must not contain whitespace or quotes, got '$NOVNC_VNC_PATH'"
      ;;
  esac
  case "$NOVNC_VNC_PATH" in
    /vnc.html|/vnc.html\?*)
      ;;
    /*)
      fail_remote "NOVNC_VNC_PATH must point at /vnc.html with noVNC options, got '$NOVNC_VNC_PATH'"
      ;;
    *)
      fail_remote "NOVNC_VNC_PATH must start with /vnc.html, got '$NOVNC_VNC_PATH'"
      ;;
  esac
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
  ( : >/dev/tcp/127.0.0.1/"$port" ) >/dev/null 2>&1
  return $?
}

print_command() {
  local label="$1"
  local arg

  shift
  printf "%s" "$label"
  for arg in "$@"; do
    printf " %q" "$arg"
  done
  printf "\n"
}

sha256_file() {
  local path="$1"

  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$path" | awk '{ print $1 }'
    return 0
  fi
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$path" | awk '{ print $1 }'
    return 0
  fi
  printf "unavailable"
}

print_pi4_visible_handoff() {
  echo "Pi 4 prepared image: $PI4_REAL_ASSET_IMAGE"
  echo "Pi 4 handoff file: $PI4_REAL_ASSET_HANDOFF"
  echo "Pi 4 kernel image: $PI4_KERNEL8_IMG"
  echo "Pi 4 QEMU display: -display vnc=127.0.0.1:$VNC_DISPLAY"
  echo "Pi 4 noVNC path: $NOVNC_VNC_PATH on local port $NOVNC_PORT"
  echo "Pi 4 noVNC view: open the URL in browser fullscreen; resize=scale keeps the guest desktop fitted to the window."
  echo "Pi 4 focus: click the noVNC canvas once before keyboard or mouse input."
  echo "Pi 4 launcher: press 1/click Doom or press 2/click Quake inside vibe-os."
  echo "Pi 4 QEMU input args: $PI4_QEMU_INPUT_ARGS"
}

print_remote_play_controls() {
  cat <<'EOF'
Visible play controls:
  noVNC focus: click the scaled canvas once before typing or using the mouse.
  Launcher: 1/click Doom, 2/click Quake, or W/S plus Enter from inside vibe-os.
  Pi Doom: W/Up forward, S/Down back, A/Left and D/Right turn, Space/Enter/Ctrl or left mouse fires.
  Pi Quake: WASD moves, arrows look, Ctrl/Enter or left mouse fires, Space/Shift jumps, Escape toggles menu.
  x86 Doom: arrows move/turn, Ctrl fires, Space uses, Escape opens menu.
EOF
}

print_pi4_handoff_summary() {
  local handoff="$1"

  echo "Pi 4 handoff summary:"
  grep -E '^(image_abs|image_sha256|exact_boot_image_abs|exact_boot_image_sha256|kernel_abs|kernel_sha256|doom_wad_sha1|quake_pak_sha1|qemu_display|qemu_input|novnc_browser_path|launcher_focus|launcher_select_doom|launcher_select_quake|hardware_proof)=' "$handoff" || true
}

wait_for_novnc_ready() {
  local url="http://127.0.0.1:$NOVNC_PORT$NOVNC_VNC_PATH"
  local wait_started

  echo "Waiting up to ${NOVNC_READY_WAIT_SECONDS}s for noVNC to serve $NOVNC_VNC_PATH on 127.0.0.1:$NOVNC_PORT"
  wait_started=$SECONDS
  while [ $((SECONDS - wait_started)) -lt "$NOVNC_READY_WAIT_SECONDS" ]; do
    if ! kill -0 "$WEBSOCKIFY_PID" >/dev/null 2>&1; then
      wait "$WEBSOCKIFY_PID" 2>/dev/null || true
      fail_remote "websockify exited before noVNC was ready; see $PLAY_BUILD_DIR/novnc.log"
    fi
    if command -v curl >/dev/null 2>&1 && curl --fail --silent --max-time 2 "$url" >/dev/null 2>&1; then
      echo "noVNC ready: $url"
      return 0
    fi
    if ! command -v curl >/dev/null 2>&1 && loopback_port_in_use "$NOVNC_PORT"; then
      echo "noVNC TCP listener ready on 127.0.0.1:$NOVNC_PORT"
      return 0
    fi
    sleep "$NOVNC_READY_WAIT_INTERVAL"
  done

  fail_remote "noVNC did not become ready on 127.0.0.1:$NOVNC_PORT before timeout; see $PLAY_BUILD_DIR/novnc.log"
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
    printf 'https://%s-%s.%s%s\n' \
      "$CODESPACE_NAME" \
      "$NOVNC_PORT" \
      "$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN" \
      "$NOVNC_VNC_PATH"
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
  printf '{ "running": %s, "pid": "%s", "mode": "$PLAY_MODE", "novnc_port": "%s", "serial_log": "%s" }\\n' \
    "\$running" "\$pid" "\$(cat "\$port_file" 2>/dev/null || true)" "\$serial_log"
  exit 0
fi

if [ "\${1:-}" = "--watch" ]; then
  interval="\${VIBE_PLAY_WATCH_SECONDS:-10}"
  case "\$interval" in
    ''|*[!0-9]*)
      interval=10
      ;;
  esac
  while true; do
    date -u +"watch_utc=%Y-%m-%dT%H:%M:%SZ"
    "\$0"
    sleep "\$interval"
  done
fi

echo "vibe-os play-now diagnostics"
echo "mode: $PLAY_MODE"
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
  tr ' ' '\\n' < "\$serial_log" | grep -E '^(panic|shutdown|doomrun|gameplay|audio|doompresent|dtick|preempt|inputqueue|musicbuf|mixunder|pi4[a-z0-9]*|fbgeom|fbpresent|fbabi)=' | tail -40 || true
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
  echo "mode: $PLAY_MODE"
  echo "platform: $(uname -s)"
  echo "noVNC port: $NOVNC_PORT"
  echo "noVNC browser path: $NOVNC_VNC_PATH"
  echo "QEMU VNC display: :$VNC_DISPLAY (127.0.0.1:$VNC_PORT)"
  echo "visible display: open noVNC in browser fullscreen; resize=scale keeps the guest framebuffer zoomed to the window"
  echo "launcher controls: click the noVNC canvas first, then press 1/click Doom or press 2/click Quake"
  print_remote_play_controls
  echo "noVNC readiness timeout: ${NOVNC_READY_WAIT_SECONDS}s"
  echo "required tools:"
  for tool in "${REQUIRED_TOOLS[@]}"; do
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
  if [ "$PLAY_MODE" = "pi4" ]; then
    echo "Pi 4 image path: $PI4_IMAGE"
    echo "Pi 4 exact real-assets image path: $PI4_REAL_ASSET_IMAGE"
    echo "Pi 4 real-assets handoff: $PI4_REAL_ASSET_HANDOFF"
    echo "Pi 4 kernel path: $PI4_KERNEL8_IMG"
    echo "Pi 4 visible input: noVNC/QEMU USB keyboard and USB mouse"
    echo "Pi 4 guest UX: fullscreen launcher desktop with Doom and Quake choices inside the OS"
    echo "Pi 4 visible command: printed after the exact real-assets image is built, before QEMU launch"
    echo "Pi 4 proof boundary: visible play is not a final proof gate; use status/workflow gates for proof claims"
  fi
  echo "dry-run: QEMU was not launched"
  echo "next: run ./tools/play_now_remote.sh --$PLAY_MODE --require-novnc on the remote host"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --x86)
      PLAY_MODE=x86
      ;;
    --pi4)
      PLAY_MODE=pi4
      ;;
    --mode|--kind)
      [ "$#" -ge 2 ] || fail_remote "$1 requires x86 or pi4"
      PLAY_MODE="$2"
      shift
      ;;
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

validate_play_mode
validate_tcp_port NOVNC_PORT "$NOVNC_PORT"
validate_vnc_display "$VNC_DISPLAY"
validate_novnc_path
if [ "$NOVNC_PORT" -eq "$VNC_PORT" ]; then
  fail_remote "NOVNC_PORT and VNC_DISPLAY both map to 127.0.0.1:$NOVNC_PORT; choose different ports"
fi

if [ "$(uname -s)" = "Darwin" ] && [ "${ALLOW_LOCAL_VM:-0}" != "1" ]; then
  cat >&2 <<'EOF'
Refusing to run QEMU on macOS.

Use this script inside a disposable remote Linux host, GitHub Codespace, or
cloud VM. The supported play-now path keeps QEMU off the local Mac.
EOF
  exit 1
fi

REQUIRED_TOOLS=(make nasm clang)
case "$PLAY_MODE" in
  x86)
    REQUIRED_TOOLS+=(qemu-system-x86_64 curl)
    ;;
  pi4)
    REQUIRED_TOOLS+=("$PI4_QEMU" git curl gzip tar unzip)
    ;;
esac

for tool in "${REQUIRED_TOOLS[@]}"; do
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

if [ "$PLAY_MODE" = "x86" ]; then
  ensure_wad_path_outside_repo
fi
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
echo "Remote artifact policy: WADs, PAKs, disk images, pixels, raw audio, logs, tokens, and one-time codes stay on this disposable host."
echo "Proof boundary: this visible-play launcher is for remote inspection only; it does not replace status/proof gates."
print_remote_play_controls
case "$PLAY_MODE" in
  x86)
    echo "Fetching/validating shareware DOOM1.WAD into $WAD_PATH"
    fetch_shareware_wad
    echo "Building vibe-os x86 disk image with shareware Doom data"
    rm -f build/disk.img
    make DOOM_WAD="$WAD_PATH"
    ;;
  pi4)
    echo "Building exact Pi 4 real-assets desktop image for visible remote play"
    make ALLOW_LOCAL_VM=0 pi4-hw-equivalent-artifact-policy
    make ALLOW_LOCAL_VM=0 PI4_REAL_ASSET_IMAGE="$PI4_REAL_ASSET_IMAGE" PI4_REAL_ASSET_HANDOFF="$PI4_REAL_ASSET_HANDOFF" pi4-prepared-real-assets-image
    test -s "$PI4_KERNEL8_IMG" || fail_remote "missing Pi 4 kernel image after build: $PI4_KERNEL8_IMG"
    test -s "$PI4_REAL_ASSET_IMAGE" || fail_remote "missing Pi 4 real-assets FAT image after build: $PI4_REAL_ASSET_IMAGE"
    test -s "$PI4_REAL_ASSET_HANDOFF" || fail_remote "missing Pi 4 real-assets handoff after build: $PI4_REAL_ASSET_HANDOFF"
    echo "Pi 4 real-assets handoff: $PI4_REAL_ASSET_HANDOFF"
    print_pi4_handoff_summary "$PI4_REAL_ASSET_HANDOFF"
    echo "Exact Pi 4 real-assets image: $PI4_REAL_ASSET_IMAGE"
    echo "Pi 4 real-assets image sha256: $(sha256_file "$PI4_REAL_ASSET_IMAGE")"
    echo "Pi 4 kernel: $PI4_KERNEL8_IMG"
    echo "Pi 4 kernel sha256: $(sha256_file "$PI4_KERNEL8_IMG")"
    print_pi4_visible_handoff
    print_command "Exact remote replay command:" "PI4_REAL_ASSET_IMAGE=$PI4_REAL_ASSET_IMAGE" "PI4_REAL_ASSET_HANDOFF=$PI4_REAL_ASSET_HANDOFF" ./tools/play_now_remote.sh --pi4 --require-novnc
    ;;
esac
mkdir -p "$PLAY_BUILD_DIR"

if command -v websockify >/dev/null 2>&1 && [ -n "$NOVNC_WEB_ROOT_RESOLVED" ]; then
  websockify --web="$NOVNC_WEB_ROOT_RESOLVED" "127.0.0.1:$NOVNC_PORT" "127.0.0.1:$VNC_PORT" \
    >"$PLAY_BUILD_DIR/novnc.log" 2>&1 &
  WEBSOCKIFY_PID="$!"
  wait_for_novnc_ready
  echo "noVNC web root: $NOVNC_WEB_ROOT_RESOLVED"
  echo "noVNC tunnel/local URL: http://127.0.0.1:$NOVNC_PORT$NOVNC_VNC_PATH"
  if codespaces_url="$(codespaces_novnc_url)" && [ -n "$codespaces_url" ]; then
    echo "Codespaces noVNC URL: $codespaces_url"
  fi
  echo "In Codespaces, forward port $NOVNC_PORT and open the forwarded URL with path $NOVNC_VNC_PATH."
  echo "noVNC default: autoconnect=1 and resize=scale; open the URL in browser fullscreen for the largest play surface."
else
  echo "noVNC not found; use SSH VNC tunnel instead:"
  echo "  ssh -L $VNC_PORT:127.0.0.1:$VNC_PORT user@remote-host"
  echo "Then connect a VNC client to localhost:$VNC_PORT."
fi

echo "Starting remote $PLAY_MODE QEMU VNC display :$VNC_DISPLAY on 127.0.0.1:$VNC_PORT"
case "$PLAY_MODE" in
  x86)
    echo "Launcher: press 1 or click Doom."
    echo "Audio: this quick VNC path exposes display/input; audio proof remains status-only here."
    qemu_cmd=(
      qemu-system-x86_64
      -machine pc,accel=tcg
      -m 128M
      -audiodev none,id=snd0
      -device sb16,audiodev=snd0
      -drive file=build/disk.img,format=raw,if=ide,index=0,media=disk
      -boot c
      -display "vnc=127.0.0.1:$VNC_DISPLAY"
      -serial "file:$PLAY_BUILD_DIR/serial.log"
      -monitor "unix:$PLAY_BUILD_DIR/monitor.sock,server,nowait"
      -no-reboot
      -no-shutdown
    )
    ;;
  pi4)
    print_pi4_visible_handoff
    echo "After launch: keep focus in the noVNC canvas for gameplay keyboard and mouse input."
    print_remote_play_controls
    echo "Pi input: QEMU keyboard and mouse are wired as Pi USB HID devices."
    echo "Pi screendump monitor socket stays remote: $PLAY_BUILD_DIR/monitor.sock"
    qemu_cmd=(
      "$PI4_QEMU"
      -M raspi4b,usb=on
      -cpu cortex-a72
      -m 2G
      -kernel "$PI4_KERNEL8_IMG"
      -drive "file=$PI4_REAL_ASSET_IMAGE,if=sd,format=raw"
      -serial "file:$PLAY_BUILD_DIR/serial.log"
      -display "vnc=127.0.0.1:$VNC_DISPLAY"
      -device usb-kbd
      -device usb-mouse
      -monitor "unix:$PLAY_BUILD_DIR/monitor.sock,server,nowait"
      -no-reboot
      -no-shutdown
    )
    ;;
esac
print_command "Exact visible-play QEMU command:" "${qemu_cmd[@]}"
"${qemu_cmd[@]}" &
QEMU_PID="$!"
sleep 1
if ! kill -0 "$QEMU_PID" >/dev/null 2>&1; then
  wait "$QEMU_PID" 2>/dev/null || true
  fail_remote "QEMU exited immediately; see $PLAY_BUILD_DIR/serial.log and $PLAY_BUILD_DIR/novnc.log if present"
fi
wait "$QEMU_PID"
