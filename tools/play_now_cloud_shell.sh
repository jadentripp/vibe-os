#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${VIBE_REPO_URL:-https://github.com/jadentripp/vibe-os.git}"
REF="${VIBE_REF:-main}"
WORKDIR="${VIBE_PLAY_DIR:-$HOME/vibe-os-play-now}"
START_REMOTE=1
INSTALL_DEPS=1

usage() {
  cat <<'EOF'
Usage: tools/play_now_cloud_shell.sh [options]

Bootstrap vibe-os Doom on a disposable remote Linux shell without using local
GitHub CLI Codespaces scope. This script is for Codespaces, cloud VMs, or other
throwaway Linux hosts. It refuses macOS before installing packages or starting
the remote play script.

Options:
  --repo-url URL       Git repository to clone. Default: public vibe-os repo.
  --ref BRANCH         Branch to play. Default: VIBE_REF or main.
  --dir PATH           Remote checkout directory. Default: ~/vibe-os-play-now.
  --preflight-only     Install/clone/check only; do not start QEMU/noVNC.
  --no-install         Skip apt dependency installation.
  -h, --help           Show this help.
EOF
}

fail_cloud_shell() {
  echo "play-now cloud shell failed: $*" >&2
  exit 1
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --repo-url)
      [ "$#" -ge 2 ] || fail_cloud_shell "--repo-url requires a value"
      REPO_URL="$2"
      shift
      ;;
    --ref|--branch)
      [ "$#" -ge 2 ] || fail_cloud_shell "--ref requires a branch name"
      REF="$2"
      shift
      ;;
    --dir)
      [ "$#" -ge 2 ] || fail_cloud_shell "--dir requires a path"
      WORKDIR="$2"
      shift
      ;;
    --preflight-only|--dry-run)
      START_REMOTE=0
      ;;
    --no-install)
      INSTALL_DEPS=0
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      fail_cloud_shell "unknown argument: $1"
      ;;
  esac
  shift
done

case "$(uname -s)" in
  Darwin)
    cat >&2 <<'EOF'
Refusing to bootstrap a QEMU play host on macOS.

Run this inside a disposable Linux Codespace, cloud shell, or remote VM.
EOF
    exit 1
    ;;
  Linux)
    ;;
  *)
    fail_cloud_shell "unsupported host OS: $(uname -s); use a disposable Linux host"
    ;;
esac

install_dependencies() {
  if [ "$INSTALL_DEPS" != "1" ]; then
    return 0
  fi
  command -v apt-get >/dev/null 2>&1 || {
    cat >&2 <<'EOF'
apt-get is not available on this host. Install these packages, then rerun:
  git make nasm clang qemu-system-x86 netcat-openbsd curl python3 novnc websockify
EOF
    exit 1
  }

  local sudo_cmd=()
  if [ "$(id -u)" != "0" ]; then
    command -v sudo >/dev/null 2>&1 || fail_cloud_shell "sudo is required to install packages on this host"
    sudo_cmd=(sudo)
  fi

  "${sudo_cmd[@]}" apt-get update
  "${sudo_cmd[@]}" apt-get install -y --no-install-recommends \
    git \
    make \
    nasm \
    clang \
    qemu-system-x86 \
    netcat-openbsd \
    curl \
    python3 \
    novnc \
    websockify
}

checkout_repo() {
  if [ -d "$WORKDIR/.git" ]; then
    cd "$WORKDIR"
    git fetch --depth=1 origin "$REF"
    git checkout --detach FETCH_HEAD
    return 0
  fi

  rm -rf "$WORKDIR"
  git clone --depth=1 --branch "$REF" "$REPO_URL" "$WORKDIR" || {
    rm -rf "$WORKDIR"
    git clone "$REPO_URL" "$WORKDIR"
    cd "$WORKDIR"
    git fetch --depth=1 origin "$REF"
    git checkout --detach FETCH_HEAD
    return 0
  }
  cd "$WORKDIR"
}

install_dependencies
checkout_repo

echo "Remote checkout: $WORKDIR"
echo "Remote ref: $(git rev-parse --short HEAD)"
echo "Remote artifact policy: keep WADs, disk images, pixels, raw audio, screenshots, logs, tokens, and one-time codes on this disposable host."

./tools/play_now_remote.sh --preflight --require-novnc

if [ "$START_REMOTE" != "1" ]; then
  cat <<EOF
play-now cloud shell preflight OK

Start from the remote checkout when ready:
  cd "$WORKDIR"
  ./tools/play_now_remote.sh --require-novnc

Then open forwarded private port \${NOVNC_PORT:-6080} with:
  /vnc.html?autoconnect=1
EOF
  exit 0
fi

echo "Starting vibe-os Doom on this disposable remote host."
exec ./tools/play_now_remote.sh --require-novnc
