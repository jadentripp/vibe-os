#!/usr/bin/env bash
set -euo pipefail

action="${1:-}"

usage() {
  cat <<'EOF'
Usage: tools/pi4_real_tryboot.sh manifest|stage|preflight|arm

Build-system helper for reversible Raspberry Pi 4 tryboot tests. The Makefile
sets the artifact paths; callers must set PI4_REAL_SSH_HOST for real hardware
actions, for example:

  make pi4-real-tryboot-arm PI4_REAL_SSH_HOST=pi.example.invalid PI4_REAL_ALLOW_REBOOT=1

SSH identity, host aliases, known-host handling, and other local policy belong
in the user's SSH config. Advanced callers can override PI4_REAL_SSH and
PI4_REAL_SCP if they need wrapper commands.
EOF
}

fail_tryboot() {
  echo "pi4 real tryboot failed: $*" >&2
  exit 1
}

require_file() {
  [ -f "$1" ] || fail_tryboot "missing required file: $1"
}

sha256_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{ print $1 }'
  else
    shasum -a 256 "$1" | awk '{ print $1 }'
  fi
}

remote_quote() {
  printf "'%s'" "$(printf "%s" "$1" | sed "s/'/'\\\\''/g")"
}

require_host() {
  [ -n "$PI4_REAL_SSH_HOST" ] || fail_tryboot "set PI4_REAL_SSH_HOST=pi.example.invalid
}

ssh_pi() {
  # PI4_REAL_SSH is intentionally a command string so local SSH config can
  # remain the default while labs can still pass a wrapper command.
  $PI4_REAL_SSH "$PI4_REAL_SSH_HOST" "$@"
}

scp_to_pi() {
  $PI4_REAL_SCP "$1" "$PI4_REAL_SSH_HOST:$2"
}

require_artifacts() {
  require_file "$PI4_KERNEL8_IMG"
  require_file "$PI4_TRYBOOT_TXT"
  require_file "$PI4_LAUNCHER_ELF"
  require_file "$PI4_ABI_PROBE_ELF"
  require_file "$PI4_APP_INDEX_TXT"
  require_file "$PI4_APP_DOOM_MANIFEST_TXT"
  require_file "$PI4_DOOM_ELF"
  require_file "$PI4_APP_QUAKE_MANIFEST_TXT"
  require_file "$PI4_QUAKE_ELF"
}

write_manifest() {
  require_artifacts
  mkdir -p "$(dirname "$PI4_REAL_TRYBOOT_MANIFEST")"
  {
    printf "schema=vibe-os-pi4-real-tryboot-manifest-v1\n"
    printf "created_utc=%s\n" "$(date -u "+%Y-%m-%dT%H:%M:%SZ")"
    printf "normal_boot_preserved=%s/config.txt,%s/kernel8.img\n" "$PI4_REAL_BOOT_MOUNT" "$PI4_REAL_BOOT_MOUNT"
    printf "tryboot_candidate=%s\n" "$PI4_REAL_TRYBOOT_CANDIDATE"
    printf "tryboot_active=%s\n" "$PI4_REAL_TRYBOOT_ACTIVE"
    for artifact in \
      "$PI4_KERNEL8_IMG" \
      "$PI4_TRYBOOT_TXT" \
      "$PI4_LAUNCHER_ELF" \
      "$PI4_ABI_PROBE_ELF" \
      "$PI4_APP_INDEX_TXT" \
      "$PI4_APP_DOOM_MANIFEST_TXT" \
      "$PI4_DOOM_ELF" \
      "$PI4_APP_QUAKE_MANIFEST_TXT" \
      "$PI4_QUAKE_ELF"; do
      printf "%s  %s\n" "$(sha256_file "$artifact")" "$artifact"
    done
    wc -c \
      "$PI4_KERNEL8_IMG" \
      "$PI4_TRYBOOT_TXT" \
      "$PI4_LAUNCHER_ELF" \
      "$PI4_ABI_PROBE_ELF" \
      "$PI4_APP_INDEX_TXT" \
      "$PI4_APP_DOOM_MANIFEST_TXT" \
      "$PI4_DOOM_ELF" \
      "$PI4_APP_QUAKE_MANIFEST_TXT" \
      "$PI4_QUAKE_ELF"
  } > "$PI4_REAL_TRYBOOT_MANIFEST"
  cat "$PI4_REAL_TRYBOOT_MANIFEST"
}

stage_tryboot() {
  require_host
  require_artifacts

  local tmp="/tmp/vibe-os-pi4-stage-$$"
  local qtmp qboot qvibe
  qtmp="$(remote_quote "$tmp")"
  qboot="$(remote_quote "$PI4_REAL_BOOT_MOUNT")"
  qvibe="$(remote_quote "$PI4_REAL_VIBE_DIR")"

  ssh_pi "rm -rf $qtmp; mkdir -p $qtmp/vibe $qtmp/SYSTEM $qtmp/APPS/DOOM $qtmp/APPS/QUAKE"
  scp_to_pi "$PI4_KERNEL8_IMG" "$tmp/vibe/kernel8.img"
  scp_to_pi "$PI4_TRYBOOT_TXT" "$tmp/tryboot.vibe-os.txt"
  scp_to_pi "$PI4_LAUNCHER_ELF" "$tmp/SYSTEM/INIT.ELF"
  scp_to_pi "$PI4_ABI_PROBE_ELF" "$tmp/SYSTEM/ABIPROBE.ELF"
  scp_to_pi "$PI4_APP_INDEX_TXT" "$tmp/APPS/INDEX.TXT"
  scp_to_pi "$PI4_APP_DOOM_MANIFEST_TXT" "$tmp/APPS/DOOM/MANIFEST.TXT"
  scp_to_pi "$PI4_DOOM_ELF" "$tmp/APPS/DOOM/APP.ELF"
  scp_to_pi "$PI4_APP_QUAKE_MANIFEST_TXT" "$tmp/APPS/QUAKE/MANIFEST.TXT"
  scp_to_pi "$PI4_QUAKE_ELF" "$tmp/APPS/QUAKE/APP.ELF"

  ssh_pi "set -e; \
    sudo mkdir -p $qvibe $qboot/SYSTEM $qboot/APPS/DOOM $qboot/APPS/QUAKE; \
    sudo install -m 0644 $qtmp/vibe/kernel8.img $qvibe/kernel8.img; \
    sudo install -m 0644 $qtmp/tryboot.vibe-os.txt $(remote_quote "$PI4_REAL_TRYBOOT_CANDIDATE"); \
    sudo install -m 0644 $qtmp/SYSTEM/INIT.ELF $qboot/SYSTEM/INIT.ELF; \
    sudo install -m 0644 $qtmp/SYSTEM/ABIPROBE.ELF $qboot/SYSTEM/ABIPROBE.ELF; \
    sudo install -m 0644 $qtmp/APPS/INDEX.TXT $qboot/APPS/INDEX.TXT; \
    sudo install -m 0644 $qtmp/APPS/DOOM/MANIFEST.TXT $qboot/APPS/DOOM/MANIFEST.TXT; \
    sudo install -m 0644 $qtmp/APPS/DOOM/APP.ELF $qboot/APPS/DOOM/APP.ELF; \
    sudo install -m 0644 $qtmp/APPS/QUAKE/MANIFEST.TXT $qboot/APPS/QUAKE/MANIFEST.TXT; \
    sudo install -m 0644 $qtmp/APPS/QUAKE/APP.ELF $qboot/APPS/QUAKE/APP.ELF; \
    rm -rf $qtmp; \
    sync"
  printf "Staged Pi 4 tryboot files on %s without replacing the normal config.txt or kernel8.img.\n" "$PI4_REAL_SSH_HOST"
}

preflight_tryboot() {
  require_host
  ssh_pi "set -e; \
    echo \"host=\$(hostname) kernel=\$(uname -r)\"; \
    test -f $(remote_quote "$PI4_REAL_BOOT_MOUNT/config.txt"); \
    test -f $(remote_quote "$PI4_REAL_BOOT_MOUNT/kernel8.img"); \
    test -f $(remote_quote "$PI4_REAL_VIBE_DIR/kernel8.img"); \
    test -f $(remote_quote "$PI4_REAL_TRYBOOT_CANDIDATE"); \
    test ! -f $(remote_quote "$PI4_REAL_TRYBOOT_ACTIVE"); \
    for p in /proc/device-tree/chosen/bootloader/partition /proc/device-tree/chosen/bootloader/tryboot /proc/device-tree/chosen/bootloader/rsts; do \
      [ -e \"\$p\" ] && printf \"%s \" \"\$p\" && od -An -tx4 \"\$p\" || true; \
    done; \
    sha256sum \
      $(remote_quote "$PI4_REAL_VIBE_DIR/kernel8.img") \
      $(remote_quote "$PI4_REAL_TRYBOOT_CANDIDATE") \
      $(remote_quote "$PI4_REAL_BOOT_MOUNT/SYSTEM/INIT.ELF") \
      $(remote_quote "$PI4_REAL_BOOT_MOUNT/SYSTEM/ABIPROBE.ELF") \
      $(remote_quote "$PI4_REAL_BOOT_MOUNT/APPS/DOOM/APP.ELF") \
      $(remote_quote "$PI4_REAL_BOOT_MOUNT/APPS/QUAKE/APP.ELF"); \
    printf \"tryboot_preflight=OK normal_boot=config.txt,kernel8.img active_tryboot=absent\n\""
}

arm_tryboot() {
  require_host
  [ "$PI4_REAL_ALLOW_REBOOT" = "1" ] || fail_tryboot "refusing to reboot hardware; set PI4_REAL_ALLOW_REBOOT=1"

  local rc=0
  ssh_pi "set -e; \
    sudo cp $(remote_quote "$PI4_REAL_TRYBOOT_CANDIDATE") $(remote_quote "$PI4_REAL_TRYBOOT_ACTIVE"); \
    sync; \
    echo \"tryboot_active=armed\"; \
    sudo /usr/sbin/reboot \"0 tryboot\"" || rc=$?
  if [ "$rc" != "0" ] && [ "$rc" != "255" ]; then
    exit "$rc"
  fi
  printf "Tryboot reboot command sent to %s.\n" "$PI4_REAL_SSH_HOST"
}

PI4_REAL_SSH_HOST=pi.example.invalid
PI4_REAL_SSH="${PI4_REAL_SSH:-ssh}"
PI4_REAL_SCP="${PI4_REAL_SCP:-scp}"
PI4_REAL_BOOT_MOUNT="${PI4_REAL_BOOT_MOUNT:-/boot/firmware}"
PI4_REAL_VIBE_DIR="${PI4_REAL_VIBE_DIR:-$PI4_REAL_BOOT_MOUNT/vibe}"
PI4_REAL_TRYBOOT_CANDIDATE="${PI4_REAL_TRYBOOT_CANDIDATE:-$PI4_REAL_BOOT_MOUNT/tryboot.vibe-os.txt}"
PI4_REAL_TRYBOOT_ACTIVE="${PI4_REAL_TRYBOOT_ACTIVE:-$PI4_REAL_BOOT_MOUNT/tryboot.txt}"
PI4_REAL_ALLOW_REBOOT="${PI4_REAL_ALLOW_REBOOT:-0}"

case "$action" in
  manifest)
    write_manifest
    ;;
  stage)
    stage_tryboot
    ;;
  preflight)
    preflight_tryboot
    ;;
  arm)
    arm_tryboot
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac
