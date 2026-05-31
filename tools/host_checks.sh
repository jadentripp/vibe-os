#!/usr/bin/env bash
set -euo pipefail

mode="${1:-}"
if [ -z "$mode" ]; then
  echo "usage: tools/host_checks.sh {no-python|project-c-inventory|pi4-assembly-source-gate|pi4-image-inspect|playability-host-check|quake-status-proof|persistence-image-check}" >&2
  exit 2
fi

BUILD_DIR="${BUILD_DIR:-build}"
MAKE_BIN="${MAKE:-make}"
PROJECT_C_ALLOWLIST="${PROJECT_C_ALLOWLIST:-tools/project_c_allowlist.txt}"
IMAGE="${IMAGE:-$BUILD_DIR/disk.img}"
IMAGE_BUILDER="${IMAGE_BUILDER:-$BUILD_DIR/make_wad_image}"
PI4_IMAGE="${PI4_IMAGE:-$BUILD_DIR/pi4/pi4-fat16.img}"
PI4_IMAGE_INSPECT_TXT="${PI4_IMAGE_INSPECT_TXT:-$BUILD_DIR/pi4/pi4-image-inspect.txt}"
PI4_ASM_SRCS="${PI4_ASM_SRCS:-}"
PERSISTENCE_BASELINE_IMAGE="${PERSISTENCE_BASELINE_IMAGE:-}"
PERSISTENCE_REBOOT_BASELINE_IMAGE="${PERSISTENCE_REBOOT_BASELINE_IMAGE:-}"
PERSISTENCE_REBOOT_STATUS="${PERSISTENCE_REBOOT_STATUS:-}"
PERSISTENCE_WRITE_STATUS="${PERSISTENCE_WRITE_STATUS:-}"
PERSISTENCE_SAVE_WRITE_STATUS="${PERSISTENCE_SAVE_WRITE_STATUS:-}"
PERSISTENCE_LOAD_STATUS="${PERSISTENCE_LOAD_STATUS:-}"
PERSISTENCE_REQUIRE_DEFAULT="${PERSISTENCE_REQUIRE_DEFAULT:-0}"
PERSISTENCE_REQUIRE_DYNAMIC_FAT_PROOF="${PERSISTENCE_REQUIRE_DYNAMIC_FAT_PROOF:-0}"
PERSISTENCE_REQUIRE_SAVE_SLOT="${PERSISTENCE_REQUIRE_SAVE_SLOT:-}"
PERSISTENCE_REQUIRE_SAVE_DESCRIPTION="${PERSISTENCE_REQUIRE_SAVE_DESCRIPTION:-}"

no_python_check() {
  local files
  files="$(git ls-files '*.py' ':(exclude)third_party/**' ':(exclude)build/**' ':(exclude)out/**')"
  if [ -n "$files" ]; then
    printf "Tracked Python is not allowed in the vibe-os build/proof path:\n%s\n" "$files" >&2
    exit 1
  fi
  printf "No tracked Python in the vibe-os build/proof path.\n"
}

project_c_inventory() {
  local actual allow count lines

  mkdir -p "$BUILD_DIR"
  actual="$BUILD_DIR/project-c-actual.txt"
  allow="$BUILD_DIR/project-c-allowlist.txt"
  find . -type f \( -name '*.c' -o -name '*.h' \) \
    -not -path './.git/*' \
    -not -path './build/*' \
    -not -path './third_party/*' \
    -print | sed 's#^\./##' | sort > "$actual"
  sed '/^[[:space:]]*$/d' "$PROJECT_C_ALLOWLIST" | sort > "$allow"
  if ! diff -u "$allow" "$actual"; then
    echo "project C/header inventory drifted; update $PROJECT_C_ALLOWLIST intentionally" >&2
    exit 1
  fi
  count="$(wc -l < "$actual" | tr -d ' ')"
  if [ -s "$actual" ]; then
    lines="$(xargs wc -l < "$actual" | awk 'END { print $1 }')"
  else
    lines=0
  fi
  printf "Project C/header inventory OK: %s files, %s lines remain outside third_party.\n" "$count" "$lines"
}

pi4_assembly_source_gate() {
  local expected actual

  expected="$(printf '%s\n' $PI4_ASM_SRCS | LC_ALL=C sort)"
  actual="$( {
    find boot/pi4 -type f \( -name '*.S' -o -name '*.s' \) -print 2>/dev/null
    find user -maxdepth 1 -type f \( -name 'pi4_*.S' -o -name 'pi4_*.s' \) -print 2>/dev/null
    find doom_port -maxdepth 1 -type f \( -name 'pi4_*.S' -o -name 'pi4_*.s' \) -print 2>/dev/null
    find quake_port -maxdepth 1 -type f \( -name 'pi4_*.S' -o -name 'pi4_*.s' \) -print 2>/dev/null
  } | LC_ALL=C sort )"
  if [ "$actual" != "$expected" ]; then
    printf "Pi 4 assembly source wiring is stale.\nExpected:\n%s\nActual:\n%s\n" "$expected" "$actual" >&2
    exit 1
  fi
  printf "Pi 4 assembly source gate OK: boot, user, launcher, Doom, and Quake sources are wired.\n"
}

pi4_image_inspect() {
  mkdir -p "$(dirname "$PI4_IMAGE_INSPECT_TXT")"
  "$IMAGE_BUILDER" --inspect "$PI4_IMAGE" > "$PI4_IMAGE_INSPECT_TXT"
  cat "$PI4_IMAGE_INSPECT_TXT"
  grep -F -q "manifest_file=KERNEL8.IMG state=present" "$PI4_IMAGE_INSPECT_TXT"
  grep -F -q "manifest_file=CONFIG.TXT state=present" "$PI4_IMAGE_INSPECT_TXT"
  grep -F -q "manifest_file=VIBESTAT.BIN state=present" "$PI4_IMAGE_INSPECT_TXT"
  grep -F -q "manifest_file=/SYSTEM/INIT.ELF state=present" "$PI4_IMAGE_INSPECT_TXT"
  grep -F -q "manifest_file=/APPS/INDEX.TXT state=present" "$PI4_IMAGE_INSPECT_TXT"
  grep -F -q "app_exec=/APPS/DOOM/APP.ELF state=present model=generic-aarch64-el0-elf-by-path app=doom" "$PI4_IMAGE_INSPECT_TXT"
  grep -F -q "app_exec=/APPS/QUAKE/APP.ELF state=present model=generic-aarch64-el0-elf-by-path app=quake" "$PI4_IMAGE_INSPECT_TXT"
  ! grep -a -E -q "PAYLOAD[0-9]+\\.ELF" "$PI4_IMAGE"
}

playability_host_check() {
  printf "Running host-only playability readiness checks; local QEMU remains disabled.\n"
  "$MAKE_BIN" --no-print-directory clean
  "$MAKE_BIN" --no-print-directory ALLOW_LOCAL_VM=0 DOOM_WAD= build-only
  "$MAKE_BIN" --no-print-directory ALLOW_LOCAL_VM=0 DOOM_WAD= test
  git diff --check
  git diff --cached --check
  printf "Playability host check OK: assembly build path and minimal host status proof passed without local QEMU.\n"
}

quake_status_proof() {
  local status_txt

  status_txt="$BUILD_DIR/status.txt"
  test -s "$status_txt"
  grep -q "path=/APPS/QUAKE/APP.ELF" "$status_txt"
  grep -q "quake=OK" "$status_txt"
  grep -q "quakerun=RUN" "$status_txt"
  grep -q "quakeopen=OK" "$status_txt"
  grep -q "quakeread=OK" "$status_txt"
  grep -q "qgame=OK" "$status_txt"
  grep -q "panic=NONE" "$status_txt"
  grep -q "shutdown=NONE" "$status_txt"
  grep -q "gfx=OK" "$status_txt"
  grep -q "audio=SB16" "$status_txt"
  grep -q "heap=OK" "$status_txt"
  perl -ne '$ok = 1 if /preempt=([0-9A-F]{8})/ && hex($1) > 0; END { exit($ok ? 0 : 1) }' "$status_txt"
  perl -ne '$ok = 1 if /quakepak=([0-9A-F]{8})\/([0-9A-F]{8})\/([0-9A-F]{8})\/([0-9A-F]{8})/ && hex($1) > 0 && hex($4) == 0x4B434150; END { exit($ok ? 0 : 1) }' "$status_txt"
  perl -ne '$ok = 1 if /quakepresent=([0-9A-F]{8})/ && hex($1) > 0; END { exit($ok ? 0 : 1) }' "$status_txt"
  perl -ne '$ok = 1 if /qframe=([0-9A-F]{8})\/([0-9A-F]{8})/ && hex($1) > 0 && hex($2) > 0; END { exit($ok ? 0 : 1) }' "$status_txt"
  perl -ne '$ok = 1 if /qinput=([0-9A-F]{8})\// && hex($1) > 0; END { exit($ok ? 0 : 1) }' "$status_txt"
  perl -ne '$ok = 1 if /qaudio=([0-9A-F]{8})\// && hex($1) > 0; END { exit($ok ? 0 : 1) }' "$status_txt"
  printf "Quake proof status OK: /APPS/QUAKE/APP.ELF, PAK reads, rendered frames, input, audio, process, memory, preemption, panic, and shutdown gates passed.\n"
}

persistence_image_check() {
  local -a args
  local slot

  args=( --check-persistence "$IMAGE" )
  if [ -n "$PERSISTENCE_BASELINE_IMAGE" ]; then args+=( --baseline-image "$PERSISTENCE_BASELINE_IMAGE" ); fi
  if [ -n "$PERSISTENCE_REBOOT_BASELINE_IMAGE" ]; then args+=( --reboot-baseline-image "$PERSISTENCE_REBOOT_BASELINE_IMAGE" ); fi
  if [ -n "$PERSISTENCE_REBOOT_STATUS" ]; then args+=( --reboot-status "$PERSISTENCE_REBOOT_STATUS" ); fi
  if [ -n "$PERSISTENCE_WRITE_STATUS" ]; then args+=( --write-status "$PERSISTENCE_WRITE_STATUS" ); fi
  if [ -n "$PERSISTENCE_SAVE_WRITE_STATUS" ]; then args+=( --save-write-status "$PERSISTENCE_SAVE_WRITE_STATUS" ); fi
  if [ -n "$PERSISTENCE_LOAD_STATUS" ]; then args+=( --load-status "$PERSISTENCE_LOAD_STATUS" ); fi
  if [ "$PERSISTENCE_REQUIRE_DEFAULT" = "1" ]; then args+=( --require-default ); fi
  if [ "$PERSISTENCE_REQUIRE_DYNAMIC_FAT_PROOF" = "1" ]; then args+=( --require-dynamic-fat-proof ); fi
  for slot in $PERSISTENCE_REQUIRE_SAVE_SLOT; do
    args+=( --require-save-slot "$slot" )
  done
  if [ -n "$PERSISTENCE_REQUIRE_SAVE_DESCRIPTION" ]; then args+=( --require-save-description "$PERSISTENCE_REQUIRE_SAVE_DESCRIPTION" ); fi
  "$IMAGE_BUILDER" "${args[@]}"
}

case "$mode" in
  no-python)
    no_python_check
    ;;
  project-c-inventory)
    project_c_inventory
    ;;
  pi4-assembly-source-gate)
    pi4_assembly_source_gate
    ;;
  pi4-image-inspect)
    pi4_image_inspect
    ;;
  playability-host-check)
    playability_host_check
    ;;
  quake-status-proof)
    quake_status_proof
    ;;
  persistence-image-check)
    persistence_image_check
    ;;
  *)
    echo "unknown host check '$mode'" >&2
    exit 2
    ;;
esac
