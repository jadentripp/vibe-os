#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: tools/play_now_cloud_shell.sh

Bootstrap a disposable Ubuntu shell for vibe-os play-now, then run the shell-only
remote launcher. This helper is intentionally thin; the OS work lives in the
bootloader, kernel, drivers, runtime, and Doom platform layer.
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

repo="${VIBE_REPO:-jadentripp/vibe-os}"
ref="${VIBE_REF:-main}"
workdir="${VIBE_WORKDIR:-/tmp/vibe-os-cloud-play}"

if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y --no-install-recommends \
    git make nasm clang qemu-system-x86 netcat-openbsd curl gzip unzip novnc websockify
fi

rm -rf "$workdir"
git clone --depth=1 --branch "$ref" "https://github.com/$repo.git" "$workdir"
cd "$workdir"
exec ./tools/play_now_remote.sh --require-novnc
