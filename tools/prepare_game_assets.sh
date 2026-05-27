#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd -P "$SCRIPT_DIR/.." && pwd -P)"

default_asset_cache_dir() {
  if [ -n "${VIBE_PLAY_DATA_DIR:-}" ]; then
    printf "%s\n" "$VIBE_PLAY_DATA_DIR"
    return
  fi

  case "${XDG_CACHE_HOME:-}" in
    /*)
      printf "%s/vibe-os/game-assets\n" "${XDG_CACHE_HOME%/}"
      return
      ;;
  esac

  if [ -n "${HOME:-}" ]; then
    printf "%s/.cache/vibe-os/game-assets\n" "$HOME"
    return
  fi

  case "${TMPDIR:-}" in
    /*)
      printf "%s/vibe-os-game-assets\n" "${TMPDIR%/}"
      ;;
    *)
      printf "/tmp/vibe-os-game-assets\n"
      ;;
  esac
}

PUBLIC_SHAREWARE_WAD_GZ_URL="${PUBLIC_SHAREWARE_WAD_GZ_URL:-https://archive.org/download/wadarchive/DATA/5b.zip/5b%2F2e249b9c5133ec987b3ea77596381dc0d6bc1d%2F5b2e249b9c5133ec987b3ea77596381dc0d6bc1d.wad.gz}"
PUBLIC_QUAKE_SHAREWARE_URL="${PUBLIC_QUAKE_SHAREWARE_URL:-https://www.libsdl.org/projects/quake/data/quakesw-1.0.6.tar.gz}"
EXPECTED_WAD_SHA1="${EXPECTED_WAD_SHA1:-5b2e249b9c5133ec987b3ea77596381dc0d6bc1d}"
EXPECTED_QUAKE_PAK_SHA1="${EXPECTED_QUAKE_PAK_SHA1:-36b42dc7b6313fd9cabc0be8b9e9864840929735}"
VIBE_ASSET_CACHE_DIR="${VIBE_ASSET_CACHE_DIR:-$(default_asset_cache_dir)}"
DRY_RUN=0
OUTPUT_FORMAT="human"

usage() {
  cat <<'EOF'
Usage: tools/prepare_game_assets.sh [--dry-run] [--format human|paths]

Prepare public shareware DOOM1.WAD and Quake PAK0.PAK for vibe-os without
Python. Cached downloads go to VIBE_ASSET_CACHE_DIR, which defaults outside
this checkout: VIBE_PLAY_DATA_DIR when set, then XDG_CACHE_HOME, then
$HOME/.cache/vibe-os/game-assets, then /tmp.

The helper validates each prepared asset by file magic and expected SHA-1:
  DOOM1.WAD: IWAD/PWAD magic and EXPECTED_WAD_SHA1
  PAK0.PAK:  PACK magic and EXPECTED_QUAKE_PAK_SHA1

Environment overrides:
  DOOM_WAD=/path/to/DOOM1.WAD
      Use an existing public shareware WAD. It must match EXPECTED_WAD_SHA1.
  QUAKE_PAK=/path/to/PAK0.PAK
      Use an existing public shareware PAK. It must match
      EXPECTED_QUAKE_PAK_SHA1.
  VIBE_ASSET_CACHE_DIR=/tmp/vibe-os-game-assets
      Cache directory for downloaded assets. The default is outside the repo.
      Repo-local paths are accepted only under ignored build/, but Pi image
      packaging uses outside-repo real assets so WAD/PAK data stays external
      to the checkout and out of git.
  PUBLIC_SHAREWARE_WAD_GZ_URL=https://...
      Source URL for DOOM1.WAD, DOOM1.WAD.gz, or a zip containing DOOM1.WAD.
  PUBLIC_QUAKE_SHAREWARE_URL=https://...
      Source URL for PAK0.PAK, PAK0.PAK.gz, zip, or tar.gz containing PAK0.PAK.
  EXPECTED_WAD_SHA1=5b2e...
      Expected SHA-1 for the extracted DOOM1.WAD.
  EXPECTED_QUAKE_PAK_SHA1=36b4...
      Expected SHA-1 for the extracted PAK0.PAK.

Options:
  --dry-run
      Validate existing inputs/cached assets when present and print the paths
      that would be used. Missing cache entries are not downloaded, cache
      directories are not created, and no asset files are written.
  --format human
      Print labeled paths. This is the default.
  --format paths
      Print only DOOM1.WAD then PAK0.PAK absolute paths, one per line.
  -h, --help
      Show this help.
EOF
}

fail_prepare() {
  echo "prepare assets failed: $*" >&2
  exit 1
}

log_prepare() {
  echo "$*" >&2
}

require_tool() {
  command -v "$1" >/dev/null 2>&1 || fail_prepare "missing required tool: $1"
}

sha1_file() {
  if command -v sha1sum >/dev/null 2>&1; then
    sha1sum "$1" | awk '{ print $1 }'
  else
    require_tool shasum
    shasum -a 1 "$1" | awk '{ print $1 }'
  fi
}

lower_hex() {
  printf "%s" "$1" | tr '[:upper:]' '[:lower:]'
}

file_magic_hex() {
  od -An -N"$1" -tx1 "$2" | tr -d ' \n'
}

absolute_path() {
  local path="$1"
  local dir
  local base

  case "$path" in
    /*)
      ;;
    *)
      path="$PWD/$path"
      ;;
  esac

  dir="$(dirname "$path")"
  base="$(basename "$path")"
  if [ -d "$dir" ]; then
    dir="$(cd -P "$dir" && pwd -P)"
    printf "%s/%s\n" "$dir" "$base"
  else
    printf "%s\n" "$path"
  fi
}

physical_existing_path() {
  local path="$1"
  local dir
  local base

  [ -e "$path" ] || return 1
  if command -v realpath >/dev/null 2>&1; then
    realpath "$path"
    return
  fi

  [ ! -L "$path" ] || fail_prepare "cannot verify symlinked asset path without realpath: $path"
  dir="$(dirname "$path")"
  base="$(basename "$path")"
  dir="$(cd -P "$dir" && pwd -P)"
  printf "%s/%s\n" "$dir" "$base"
}

absolute_existing_path() {
  local path="$1"

  [ -e "$path" ] || return 1
  physical_existing_path "$path"
}

asset_location_label() {
  local path="$1"
  local abs

  if [ -e "$path" ]; then
    abs="$(physical_existing_path "$path")"
  else
    abs="$(absolute_path "$path")"
  fi
  case "$abs" in
    "$REPO_ROOT/build/"*)
      printf "ignored build cache"
      ;;
    "$REPO_ROOT"|"$REPO_ROOT"/*)
      printf "repo-local path"
      ;;
    *)
      printf "outside-repo cache"
      ;;
  esac
}

ensure_asset_path_allowed() {
  local path="$1"
  local abs

  if [ -e "$path" ]; then
    abs="$(physical_existing_path "$path")"
  else
    abs="$(absolute_path "$path")"
  fi
  case "$abs" in
    "$REPO_ROOT"|"$REPO_ROOT"/*)
      case "$abs" in
        "$REPO_ROOT/build/"*)
          ;;
        *)
          fail_prepare "repo-local game data must stay under ignored build/: $abs"
          ;;
      esac
      ;;
  esac
}

validate_expected_sha1() {
  local path="$1"
  local expected="$2"
  local label="$3"
  local actual

  [ -n "$expected" ] || fail_prepare "$label expected SHA1 is empty"
  actual="$(lower_hex "$(sha1_file "$path")")"
  expected="$(lower_hex "$expected")"
  if [ "$actual" != "$expected" ]; then
    fail_prepare "$label SHA1 mismatch: expected $expected, got $actual"
  fi
}

validate_wad() {
  local path="$1"
  local magic

  [ -s "$path" ] || fail_prepare "DOOM1.WAD is empty or missing: $path"
  magic="$(file_magic_hex 4 "$path")"
  case "$magic" in
    49574144|50574144)
      ;;
    *)
      fail_prepare "DOOM1.WAD does not start with IWAD/PWAD magic: $path"
      ;;
  esac
  validate_expected_sha1 "$path" "$EXPECTED_WAD_SHA1" "DOOM1.WAD"
}

validate_pak() {
  local path="$1"
  local magic

  [ -s "$path" ] || fail_prepare "PAK0.PAK is empty or missing: $path"
  magic="$(file_magic_hex 4 "$path")"
  if [ "$magic" != "5041434b" ]; then
    fail_prepare "PAK0.PAK does not start with PACK magic: $path"
  fi
  validate_expected_sha1 "$path" "$EXPECTED_QUAKE_PAK_SHA1" "PAK0.PAK"
}

download_doom_wad() {
  local target="$1"
  local source_tmp
  local asset_tmp
  local magic2
  local magic4
  local member

  for tool in curl cp mktemp; do
    require_tool "$tool"
  done

  source_tmp="$(mktemp "${TMPDIR:-/tmp}/vibe-os-doom-source.XXXXXX")"
  asset_tmp="$(mktemp "${TMPDIR:-/tmp}/vibe-os-doom-wad.XXXXXX")"
  trap 'rm -f "$source_tmp" "$asset_tmp"' EXIT

  curl --fail --silent --show-error --location "$PUBLIC_SHAREWARE_WAD_GZ_URL" --output "$source_tmp"
  magic2="$(file_magic_hex 2 "$source_tmp")"
  magic4="$(file_magic_hex 4 "$source_tmp")"

  if [ "$magic2" = "1f8b" ]; then
    require_tool gzip
    gzip -cd "$source_tmp" > "$asset_tmp"
  elif [ "$magic4" = "504b0304" ]; then
    require_tool unzip
    member="$(unzip -Z -1 "$source_tmp" | awk 'toupper($0) ~ /(^|\/)DOOM1[.]WAD$/ { print; exit }')"
    [ -n "$member" ] || fail_prepare "zip did not contain DOOM1.WAD"
    unzip -p "$source_tmp" "$member" > "$asset_tmp"
  elif [ "$magic4" = "49574144" ] || [ "$magic4" = "50574144" ]; then
    cp "$source_tmp" "$asset_tmp"
  else
    fail_prepare "downloaded Doom data is not a WAD, gzip-compressed WAD, or zip containing DOOM1.WAD"
  fi

  validate_wad "$asset_tmp"
  mv "$asset_tmp" "$target"
  rm -f "$source_tmp"
  trap - EXIT
}

download_quake_pak() {
  local target="$1"
  local source_tmp
  local asset_tmp
  local magic2
  local magic4
  local member

  for tool in curl cp mktemp; do
    require_tool "$tool"
  done

  source_tmp="$(mktemp "${TMPDIR:-/tmp}/vibe-os-quake-source.XXXXXX")"
  asset_tmp="$(mktemp "${TMPDIR:-/tmp}/vibe-os-quake-pak.XXXXXX")"
  trap 'rm -f "$source_tmp" "$asset_tmp"' EXIT

  curl --fail --silent --show-error --location "$PUBLIC_QUAKE_SHAREWARE_URL" --output "$source_tmp"
  magic2="$(file_magic_hex 2 "$source_tmp")"
  magic4="$(file_magic_hex 4 "$source_tmp")"

  if [ "$magic2" = "1f8b" ]; then
    require_tool gzip
    if tar -tzf "$source_tmp" >/dev/null 2>&1; then
      member="$(tar -tzf "$source_tmp" | awk 'toupper($0) ~ /(^|\/)PAK0[.]PAK$/ { print; exit }')"
      [ -n "$member" ] || fail_prepare "tar archive did not contain PAK0.PAK"
      tar -xOzf "$source_tmp" "$member" > "$asset_tmp"
    else
      gzip -cd "$source_tmp" > "$asset_tmp"
    fi
  elif [ "$magic4" = "504b0304" ]; then
    require_tool unzip
    member="$(unzip -Z -1 "$source_tmp" | awk 'toupper($0) ~ /(^|\/)PAK0[.]PAK$/ { print; exit }')"
    [ -n "$member" ] || fail_prepare "zip did not contain PAK0.PAK"
    unzip -p "$source_tmp" "$member" > "$asset_tmp"
  elif [ "$magic4" = "5041434b" ]; then
    cp "$source_tmp" "$asset_tmp"
  else
    fail_prepare "downloaded Quake data is not a PACK PAK, gzip-compressed PAK, or archive containing PAK0.PAK"
  fi

  validate_pak "$asset_tmp"
  mv "$asset_tmp" "$target"
  rm -f "$source_tmp"
  trap - EXIT
}

prepare_wad() {
  local target="$VIBE_ASSET_CACHE_DIR/DOOM1.WAD"
  local abs

  if [ -n "${DOOM_WAD:-}" ]; then
    [ -f "$DOOM_WAD" ] || fail_prepare "DOOM_WAD does not exist: $DOOM_WAD"
    ensure_asset_path_allowed "$DOOM_WAD"
    validate_wad "$DOOM_WAD"
    abs="$(absolute_existing_path "$DOOM_WAD")"
    log_prepare "Using provided DOOM1.WAD from $(asset_location_label "$abs"): $abs"
    printf "%s\n" "$abs"
    return
  fi

  ensure_asset_path_allowed "$target"
  if [ -e "$target" ]; then
    validate_wad "$target"
    abs="$(absolute_existing_path "$target")"
    log_prepare "Using cached DOOM1.WAD from $(asset_location_label "$abs"): $abs"
    printf "%s\n" "$abs"
    return
  fi

  if [ "$DRY_RUN" = "1" ]; then
    abs="$(absolute_path "$target")"
    log_prepare "Would fetch public shareware DOOM1.WAD into $(asset_location_label "$abs"): $abs"
    printf "%s\n" "$abs"
    return
  fi

  mkdir -p "$VIBE_ASSET_CACHE_DIR"
  abs="$(absolute_path "$target")"
  log_prepare "Fetching public shareware DOOM1.WAD into $(asset_location_label "$abs"): $abs"
  rm -f "$target"
  download_doom_wad "$target"
  absolute_existing_path "$target"
}

prepare_pak() {
  local target="$VIBE_ASSET_CACHE_DIR/PAK0.PAK"
  local abs

  if [ -n "${QUAKE_PAK:-}" ]; then
    [ -f "$QUAKE_PAK" ] || fail_prepare "QUAKE_PAK does not exist: $QUAKE_PAK"
    ensure_asset_path_allowed "$QUAKE_PAK"
    validate_pak "$QUAKE_PAK"
    abs="$(absolute_existing_path "$QUAKE_PAK")"
    log_prepare "Using provided PAK0.PAK from $(asset_location_label "$abs"): $abs"
    printf "%s\n" "$abs"
    return
  fi

  ensure_asset_path_allowed "$target"
  if [ -e "$target" ]; then
    validate_pak "$target"
    abs="$(absolute_existing_path "$target")"
    log_prepare "Using cached PAK0.PAK from $(asset_location_label "$abs"): $abs"
    printf "%s\n" "$abs"
    return
  fi

  if [ "$DRY_RUN" = "1" ]; then
    abs="$(absolute_path "$target")"
    log_prepare "Would fetch public Quake shareware PAK0.PAK into $(asset_location_label "$abs"): $abs"
    printf "%s\n" "$abs"
    return
  fi

  mkdir -p "$VIBE_ASSET_CACHE_DIR"
  abs="$(absolute_path "$target")"
  log_prepare "Fetching public Quake shareware PAK0.PAK into $(asset_location_label "$abs"): $abs"
  rm -f "$target"
  download_quake_pak "$target"
  absolute_existing_path "$target"
}

emit_results() {
  local doom_wad="$1"
  local quake_pak="$2"

  case "$OUTPUT_FORMAT" in
    human)
      printf "DOOM_WAD=%s\n" "$doom_wad"
      printf "QUAKE_PAK=%s\n" "$quake_pak"
      ;;
    paths)
      printf "%s\n" "$doom_wad"
      printf "%s\n" "$quake_pak"
      ;;
    *)
      fail_prepare "unsupported output format: $OUTPUT_FORMAT"
      ;;
  esac
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      ;;
    --format)
      [ "$#" -gt 1 ] || fail_prepare "--format requires human or paths"
      OUTPUT_FORMAT="$2"
      shift
      ;;
    --format=*)
      OUTPUT_FORMAT="${1#--format=}"
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

case "$OUTPUT_FORMAT" in
  human|paths)
    ;;
  *)
    fail_prepare "--format must be human or paths"
    ;;
esac

for tool in awk basename dirname od tr; do
  require_tool "$tool"
done

doom_wad="$(prepare_wad)"
quake_pak="$(prepare_pak)"
emit_results "$doom_wad" "$quake_pak"
