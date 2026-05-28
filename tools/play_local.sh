#!/usr/bin/env bash
set -euo pipefail

PUBLIC_SHAREWARE_WAD_GZ_URL="${PUBLIC_SHAREWARE_WAD_GZ_URL:-https://archive.org/download/wadarchive/DATA/5b.zip/5b%2F2e249b9c5133ec987b3ea77596381dc0d6bc1d%2F5b2e249b9c5133ec987b3ea77596381dc0d6bc1d.wad.gz}"
PUBLIC_QUAKE_SHAREWARE_URL="${PUBLIC_QUAKE_SHAREWARE_URL:-https://www.libsdl.org/projects/quake/data/quakesw-1.0.6.tar.gz}"
EXPECTED_WAD_SHA1="${EXPECTED_WAD_SHA1:-5b2e249b9c5133ec987b3ea77596381dc0d6bc1d}"
EXPECTED_QUAKE_PAK_SHA1="${EXPECTED_QUAKE_PAK_SHA1:-36b42dc7b6313fd9cabc0be8b9e9864840929735}"
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
PREPARE_ONLY=0

usage() {
  cat <<'EOF'
Usage: tools/play_local.sh [--prepare-only]

Prepare public shareware Doom and Quake data outside the repo, build one
vibe-os disk image with installed Doom and Quake apps, and launch the OS launcher.

Environment overrides:
  DOOM_WAD=/path/to/DOOM1.WAD       Use an existing WAD instead of the cache.
  QUAKE_PAK=/path/to/PAK0.PAK       Use an existing PAK instead of the cache.
  VIBE_PLAY_DATA_DIR=/path/cache    Cache directory for downloaded game data.
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
  --prepare-only, --dry-run         Download/cache data and build the image,
                                    but do not launch local QEMU.
  -h, --help                        Show this help.
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

sha1_file() {
  if command -v sha1sum >/dev/null 2>&1; then
    sha1sum "$1" | awk '{ print $1 }'
  else
    shasum -a 1 "$1" | awk '{ print $1 }'
  fi
}

file_magic_hex() {
  od -An -N"$1" -tx1 "$2" | tr -d ' \n'
}

absolute_existing_path() {
  local path="$1"
  local dir
  local base

  [ -e "$path" ] || return 1
  dir="$(dirname "$path")"
  base="$(basename "$path")"
  dir="$(cd "$dir" && pwd)"
  printf "%s/%s\n" "$dir" "$base"
}

repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || pwd
}

ensure_outside_repo() {
  local path="$1"
  local abs
  local root

  abs="$(absolute_existing_path "$path")" || return 0
  root="$(repo_root)"
  root="$(cd "$root" && pwd)"
  case "$abs" in
    "$root"|"$root"/*)
      fail_play "game data must stay outside the git checkout: $abs"
      ;;
  esac
}

validate_wad_format() {
  local path="$1"
  local magic

  [ -s "$path" ] || return 1
  magic="$(dd if="$path" bs=4 count=1 2>/dev/null || true)"
  [ "$magic" = "IWAD" ] || [ "$magic" = "PWAD" ] || return 1
}

validate_wad() {
  local path="$1"
  local actual_sha1

  validate_wad_format "$path" || return 1
  actual_sha1="$(sha1_file "$path")"
  [ "$actual_sha1" = "$EXPECTED_WAD_SHA1" ] || return 1
}

validate_pak_format() {
  local path="$1"
  local magic
  local size

  [ -s "$path" ] || return 1
  magic="$(dd if="$path" bs=4 count=1 2>/dev/null || true)"
  [ "$magic" = "PACK" ] || return 1
  size="$(wc -c < "$path" | tr -d ' ')"
  [ "$size" -gt 1000000 ] || return 1
}

validate_pak() {
  local path="$1"
  local actual_sha1

  validate_pak_format "$path" || return 1
  actual_sha1="$(sha1_file "$path")"
  [ "$actual_sha1" = "$EXPECTED_QUAKE_PAK_SHA1" ] || return 1
}

download_doom_wad() {
  local target="$1"
  local tmp
  local magic2
  local magic4
  local member

  tmp="$(mktemp "${TMPDIR:-/tmp}/vibe-os-doom-wad.XXXXXX")"
  curl --fail --silent --show-error --location "$PUBLIC_SHAREWARE_WAD_GZ_URL" --output "$tmp"
  magic2="$(file_magic_hex 2 "$tmp")"
  magic4="$(file_magic_hex 4 "$tmp")"

  if [ "$magic2" = "1f8b" ]; then
    require_tool gzip
    gzip -cd "$tmp" > "$target"
  elif [ "$magic4" = "504b0304" ]; then
    require_tool unzip
    member="$(unzip -Z -1 "$tmp" | awk 'toupper($0) ~ /(^|\/)DOOM1[.]WAD$/ { print; exit }')"
    [ -n "$member" ] || fail_play "zip did not contain DOOM1.WAD"
    unzip -p "$tmp" "$member" > "$target"
  elif [ "$magic4" = "49574144" ] || [ "$magic4" = "50574144" ]; then
    cp "$tmp" "$target"
  else
    rm -f "$tmp"
    fail_play "downloaded Doom data is not a WAD, gzip-compressed WAD, or zip containing DOOM1.WAD"
  fi

  rm -f "$tmp"
  validate_wad "$target" || fail_play "downloaded DOOM1.WAD failed validation"
}

download_quake_pak() {
  local target="$1"
  local tmp
  local magic2
  local magic4
  local member

  tmp="$(mktemp "${TMPDIR:-/tmp}/vibe-os-quake-pak.XXXXXX")"
  curl --fail --silent --show-error --location "$PUBLIC_QUAKE_SHAREWARE_URL" --output "$tmp"
  magic2="$(file_magic_hex 2 "$tmp")"
  magic4="$(file_magic_hex 4 "$tmp")"

  if [ "$magic2" = "1f8b" ]; then
    require_tool gzip
    if tar -tzf "$tmp" >/dev/null 2>&1; then
      member="$(tar -tzf "$tmp" | awk 'toupper($0) ~ /(^|\/)PAK0[.]PAK$/ { print; exit }')"
      [ -n "$member" ] || fail_play "tar archive did not contain PAK0.PAK"
      tar -xOzf "$tmp" "$member" > "$target"
    else
      gzip -cd "$tmp" > "$target"
    fi
  elif [ "$magic4" = "504b0304" ]; then
    require_tool unzip
    member="$(unzip -Z -1 "$tmp" | awk 'toupper($0) ~ /(^|\/)PAK0[.]PAK$/ { print; exit }')"
    [ -n "$member" ] || fail_play "zip did not contain PAK0.PAK"
    unzip -p "$tmp" "$member" > "$target"
  elif [ "$magic4" = "5041434b" ]; then
    cp "$tmp" "$target"
  else
    rm -f "$tmp"
    fail_play "downloaded Quake data is not a PACK PAK, gzip-compressed PAK, or archive containing PAK0.PAK"
  fi

  rm -f "$tmp"
  validate_pak "$target" || fail_play "downloaded PAK0.PAK failed validation"
}

prepare_wad() {
  local target="$VIBE_PLAY_DATA_DIR/DOOM1.WAD"

  if [ -n "${DOOM_WAD:-}" ]; then
    [ -f "$DOOM_WAD" ] || fail_play "DOOM_WAD does not exist: $DOOM_WAD"
    ensure_outside_repo "$DOOM_WAD"
    validate_wad_format "$DOOM_WAD" || fail_play "DOOM_WAD is not a valid IWAD/PWAD file: $DOOM_WAD"
    absolute_existing_path "$DOOM_WAD"
    return
  fi

  mkdir -p "$VIBE_PLAY_DATA_DIR"
  if ! validate_wad "$target"; then
    echo "Fetching public shareware DOOM1.WAD into $target" >&2
    rm -f "$target"
    download_doom_wad "$target"
  fi
  ensure_outside_repo "$target"
  absolute_existing_path "$target"
}

prepare_pak() {
  local target="$VIBE_PLAY_DATA_DIR/PAK0.PAK"

  if [ -n "${QUAKE_PAK:-}" ]; then
    [ -f "$QUAKE_PAK" ] || fail_play "QUAKE_PAK does not exist: $QUAKE_PAK"
    ensure_outside_repo "$QUAKE_PAK"
    validate_pak_format "$QUAKE_PAK" || fail_play "QUAKE_PAK is not a valid Quake PACK file: $QUAKE_PAK"
    absolute_existing_path "$QUAKE_PAK"
    return
  fi

  mkdir -p "$VIBE_PLAY_DATA_DIR"
  if ! validate_pak "$target"; then
    echo "Fetching public Quake shareware PAK0.PAK into $target" >&2
    rm -f "$target"
    download_quake_pak "$target"
  fi
  ensure_outside_repo "$target"
  absolute_existing_path "$target"
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

for tool in git "$MAKE_BIN" curl od awk wc dd; do
  require_tool "$tool"
done

if [ "$PREPARE_ONLY" != "1" ]; then
  require_tool "$QEMU_BIN"
fi

doom_wad="$(prepare_wad)"
quake_pak="$(prepare_pak)"

echo "Using DOOM1.WAD: $doom_wad"
echo "Using PAK0.PAK: $quake_pak"
echo "Building vibe-os play image in $PLAY_BUILD_DIR"
rm -f "$PLAY_BUILD_DIR/disk.img"
"$MAKE_BIN" --no-print-directory \
  BUILD_DIR="$PLAY_BUILD_DIR" \
  ALLOW_LOCAL_VM=0 \
  DOOM_WAD="$doom_wad" \
  QUAKE_PAK="$quake_pak" \
  build-only

if [ "$PREPARE_ONLY" = "1" ]; then
  echo "Prepared $PLAY_BUILD_DIR/disk.img without launching local QEMU."
  exit 0
fi

configure_qemu_display_args
configure_qemu_audio_args
configure_qemu_extra_args
configure_qemu_machine_arg
configure_qemu_cpu_args

rm -f "$PLAY_BUILD_DIR/monitor.sock" "$PLAY_BUILD_DIR/qemu.log" "$PLAY_BUILD_DIR/serial.log"
echo "Starting vibe-os. Pick Doom or Quake from the guest launcher."
echo "If the QEMU window stays black, quit it and check $PLAY_BUILD_DIR/serial.log."
set -- \
  -machine "$qemu_machine_arg" \
  -m 128M \
  -vga none \
  -device "VGA,vgamem_mb=32,xres=2560,yres=1440" \
  -drive "file=$PLAY_BUILD_DIR/disk.img,format=raw,if=ide,index=0,media=disk" \
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
