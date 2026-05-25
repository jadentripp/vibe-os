#!/usr/bin/env bash
set -euo pipefail

PUBLIC_SHAREWARE_WAD_GZ_URL="${PUBLIC_SHAREWARE_WAD_GZ_URL:-https://archive.org/download/wadarchive/DATA/5b.zip/5b%2F2e249b9c5133ec987b3ea77596381dc0d6bc1d%2F5b2e249b9c5133ec987b3ea77596381dc0d6bc1d.wad.gz}"
PUBLIC_QUAKE_SHAREWARE_URL="${PUBLIC_QUAKE_SHAREWARE_URL:-https://www.libsdl.org/projects/quake/data/quakesw-1.0.6.tar.gz}"
EXPECTED_WAD_SHA1="${EXPECTED_WAD_SHA1:-5b2e249b9c5133ec987b3ea77596381dc0d6bc1d}"
EXPECTED_QUAKE_PAK_SHA1="${EXPECTED_QUAKE_PAK_SHA1:-36b42dc7b6313fd9cabc0be8b9e9864840929735}"
VIBE_PLAY_DATA_DIR="${VIBE_PLAY_DATA_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/vibe-os}"
PLAY_BUILD_DIR="${PLAY_BUILD_DIR:-build/play}"
MAKE_BIN="${MAKE:-make}"
QEMU_EXTRA_ARGS="${QEMU_EXTRA_ARGS:-}"
PREPARE_ONLY=0

usage() {
  cat <<'EOF'
Usage: tools/play_local.sh [--prepare-only]

Prepare public shareware Doom and Quake data outside the repo, build one
vibe-os disk image with both generic payload slots, and launch the OS launcher.

Environment overrides:
  DOOM_WAD=/path/to/DOOM1.WAD       Use an existing WAD instead of the cache.
  QUAKE_PAK=/path/to/PAK0.PAK       Use an existing PAK instead of the cache.
  VIBE_PLAY_DATA_DIR=/path/cache    Cache directory for downloaded game data.
  PLAY_BUILD_DIR=build/play         Build directory for the local play image.
  QEMU_EXTRA_ARGS='...'             Extra arguments passed to QEMU.

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
  require_tool qemu-system-x86_64
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

echo "Starting vibe-os. Pick Doom or Quake from the guest launcher."
exec "$MAKE_BIN" --no-print-directory \
  BUILD_DIR="$PLAY_BUILD_DIR" \
  ALLOW_LOCAL_VM=1 \
  DOOM_WAD="$doom_wad" \
  QUAKE_PAK="$quake_pak" \
  QEMU_EXTRA_ARGS="$QEMU_EXTRA_ARGS" \
  run
