#!/usr/bin/env bash
set -euo pipefail

mode="${1:-}"
target="${2:-}"

usage() {
  echo "usage: tools/build_images.sh bios|uefi|pi4 target-image" >&2
}

require_var() {
  local name="$1"
  if [ -z "${!name:-}" ]; then
    echo "missing required environment variable: $name" >&2
    exit 2
  fi
}

add_split_args() {
  local words="${1:-}"
  if [ -n "$words" ]; then
    # Keep compatibility with the Makefile's existing space-separated override
    # surface for advanced image-builder flags.
    local extra=( $words )
    args+=( "${extra[@]}" )
  fi
}

add_game_assets() {
  if [ -n "${PRIMARY_ASSET:-}" ]; then
    args+=( --primary-asset-wad "$PRIMARY_ASSET" )
  fi
  if [ -n "${SECONDARY_PACKAGE:-}" ]; then
    args+=( --asset "/ID1/PAK0.PAK=$SECONDARY_PACKAGE" )
  fi
}

add_x86_app_assets() {
  require_var USER_LAUNCHER_ELF
  require_var USER_ABI_PROBE_ELF
  require_var APP_INDEX_TXT
  require_var APP_DOOM_MANIFEST_TXT
  require_var DOOM_ELF
  require_var APP_QUAKE_MANIFEST_TXT
  require_var QUAKE_ELF

  args+=(
    --asset "/SYSTEM/INIT.ELF=$USER_LAUNCHER_ELF"
    --asset "/SYSTEM/ABIPROBE.ELF=$USER_ABI_PROBE_ELF"
    --asset "/APPS/INDEX.TXT=$APP_INDEX_TXT"
    --asset "/APPS/DOOM/MANIFEST.TXT=$APP_DOOM_MANIFEST_TXT"
    --asset "/APPS/DOOM/APP.ELF=$DOOM_ELF"
    --asset "/APPS/QUAKE/MANIFEST.TXT=$APP_QUAKE_MANIFEST_TXT"
    --asset "/APPS/QUAKE/APP.ELF=$QUAKE_ELF"
  )
  add_split_args "${IMAGE_EXTRA_ROOT_ELF_ARGS:-}"
}

add_pi4_app_assets() {
  require_var PI4_LAUNCHER_ELF
  require_var PI4_ABI_PROBE_ELF
  require_var PI4_APP_INDEX_TXT
  require_var PI4_APP_DOOM_MANIFEST_TXT
  require_var PI4_DOOM_ELF
  require_var PI4_APP_QUAKE_MANIFEST_TXT
  require_var PI4_QUAKE_ELF

  args+=(
    --asset "/SYSTEM/INIT.ELF=$PI4_LAUNCHER_ELF"
    --asset "/SYSTEM/ABIPROBE.ELF=$PI4_ABI_PROBE_ELF"
    --asset "/APPS/INDEX.TXT=$PI4_APP_INDEX_TXT"
    --asset "/APPS/DOOM/MANIFEST.TXT=$PI4_APP_DOOM_MANIFEST_TXT"
    --asset "/APPS/DOOM/APP.ELF=$PI4_DOOM_ELF"
    --asset "/APPS/QUAKE/MANIFEST.TXT=$PI4_APP_QUAKE_MANIFEST_TXT"
    --asset "/APPS/QUAKE/APP.ELF=$PI4_QUAKE_ELF"
  )
}

if [ -z "$mode" ] || [ -z "$target" ]; then
  usage
  exit 2
fi

require_var IMAGE_BUILDER
args=()

case "$mode" in
  bios)
    require_var STAGE1_BIN
    require_var STAGE2_BIN
    require_var KERNEL_ELF
    require_var USER_PROBE_ELF

    add_game_assets
    add_x86_app_assets
    "$IMAGE_BUILDER" "${args[@]}" "$target" "$STAGE1_BIN" "$STAGE2_BIN" "$KERNEL_ELF" "$USER_PROBE_ELF"
    printf "Built %s\n" "$target"
    ;;
  uefi)
    require_var UEFI_LOADER_EFI
    require_var STAGE1_BIN
    require_var STAGE2_BIN
    require_var KERNEL_ELF
    require_var USER_PROBE_ELF

    add_game_assets
    args+=( --asset "EFI/BOOT/BOOTX64.EFI=$UEFI_LOADER_EFI" )
    args+=( --asset "VIBEOS/KERNEL.ELF=$KERNEL_ELF" )
    add_x86_app_assets
    "$IMAGE_BUILDER" "${args[@]}" "$target" "$STAGE1_BIN" "$STAGE2_BIN" "$KERNEL_ELF" "$USER_PROBE_ELF"
    printf "Built dual BIOS/UEFI FAT16 image %s\n" "$target"
    ;;
  pi4)
    require_var PI4_KERNEL8_IMG
    require_var PI4_CONFIG_TXT
    require_var PI4_NET_STATUS_SEED

    args+=( --proof-manifest )
    add_game_assets
    args+=(
      --root-file "KERNEL8.IMG=$PI4_KERNEL8_IMG"
      --root-file "CONFIG.TXT=$PI4_CONFIG_TXT"
      --root-file "VIBESTAT.BIN=$PI4_NET_STATUS_SEED"
    )
    add_pi4_app_assets
    "$IMAGE_BUILDER" "${args[@]}" "$target"
    printf "Built Raspberry Pi 4 FAT16 image %s with /SYSTEM plus /APPS app installs.\n" "$target"
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    usage
    exit 2
    ;;
esac
