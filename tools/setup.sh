#!/usr/bin/env bash
# tools/setup.sh - install the vibe-os build and proof toolchain on a fresh box.
#
# vibe-os proves itself by building the kernel and booting it in QEMU, so a
# usable dev box needs an assembler, a C compiler + LLD, make, QEMU (x86 and
# AArch64), netcat (to read the guest status page over the QEMU monitor), a few
# archive/inspection utilities, Zig (for the Linux-personality static
# musl/glibc binaries), and OVMF (for the UEFI proof). This script installs that
# set on macOS (Homebrew), Debian/Ubuntu (apt), and Fedora/Amazon Linux (dnf),
# then prints a verification report.
#
# It is idempotent: already-present tools are skipped, so it is safe to re-run.
# Pure shell on purpose - the build enforces a no-python gate.
#
# Usage:
#   tools/setup.sh                 # install the full proof toolchain (default)
#   tools/setup.sh --minimal       # x86 build+smoke only (no Pi4 QEMU, Zig, OVMF)
#   tools/setup.sh --with-cloud-play  # also install noVNC + websockify (Codespaces)
#   tools/setup.sh --skip-zig      # skip the Zig install
#   tools/setup.sh --skip-qemu     # skip QEMU (build-only box)
#   tools/setup.sh --check         # verify only; install nothing
#   tools/setup.sh --help
#
# Env overrides:
#   ZIG_VERSION (default 0.13.0)   ZIG_INSTALL_DIR (default /usr/local/lib)
#   SUDO (default: "sudo" when not root)
set -euo pipefail

cd "$(dirname "$0")/.."

# ---- options ---------------------------------------------------------------
WANT_QEMU=1
WANT_PI4=1
WANT_ZIG=1
WANT_OVMF=1
WANT_CLOUD_PLAY=0
CHECK_ONLY=0

usage() { sed -n '2,30p' "$0" | sed 's/^# \{0,1\}//'; }

while [ $# -gt 0 ]; do
  case "$1" in
    --minimal)        WANT_PI4=0; WANT_ZIG=0; WANT_OVMF=0 ;;
    --with-cloud-play) WANT_CLOUD_PLAY=1 ;;
    --skip-zig)       WANT_ZIG=0 ;;
    --skip-qemu)      WANT_QEMU=0; WANT_PI4=0 ;;
    --check)          CHECK_ONLY=1 ;;
    -h|--help)        usage; exit 0 ;;
    *) echo "setup.sh: unknown option '$1' (try --help)" >&2; exit 2 ;;
  esac
  shift
done

log()  { printf '\033[1;34m[setup]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[setup] WARN:\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m[setup] ERROR:\033[0m %s\n' "$*" >&2; exit 1; }

# ---- platform detection ----------------------------------------------------
OS="$(uname -s)"
ARCH="$(uname -m)"
PM=""        # package manager: brew | apt | dnf
case "$OS" in
  Darwin) PM="brew" ;;
  Linux)
    if   command -v apt-get >/dev/null 2>&1; then PM="apt"
    elif command -v dnf     >/dev/null 2>&1; then PM="dnf"
    elif command -v yum     >/dev/null 2>&1; then PM="dnf"
    else die "no supported package manager found (need apt-get or dnf/yum)"; fi ;;
  *) die "unsupported OS '$OS' (supported: macOS, Linux)";;
esac
log "platform: $OS/$ARCH  package-manager: $PM"

# ---- sudo handling ---------------------------------------------------------
SUDO="${SUDO-}"
if [ "$PM" != "brew" ] && [ "$(id -u)" -ne 0 ]; then
  if [ -z "${SUDO:-}" ]; then
    if command -v sudo >/dev/null 2>&1; then SUDO="sudo"
    else die "not root and 'sudo' not found; re-run as root or install sudo"; fi
  fi
fi

# dnf on some hosts uses yum
DNF="dnf"; command -v dnf >/dev/null 2>&1 || DNF="yum"

# ---- build the package lists -----------------------------------------------
# Two groups so one unavailable emulator package can't abort the whole install:
#   CORE_PKGS - build/util tools (strict; must succeed)
#   EMU_PKGS  - QEMU + UEFI firmware (varies by distro; tolerant on dnf)
#
# Each tool is mapped to its package, and a package is queued ONLY when its
# command is missing. That keeps the script idempotent and avoids distro
# conflicts for already-present base tools (e.g. Amazon Linux's curl vs
# curl-minimal, which collide if you re-request 'curl'). One package can back
# several commands (brew 'llvm' provides clang + ld.lld), so the list is
# de-duplicated. curl/unzip/gzip/file/xz are preinstalled on macOS.
core_pairs() {  # "command:package" per manager
  case "$PM" in
    apt) printf '%s\n' nasm:nasm clang:clang ld.lld:lld make:make cc:gcc objcopy:binutils \
                       git:git cmp:diffutils nc:netcat-openbsd curl:curl unzip:unzip gzip:gzip file:file xz:xz-utils ;;
    dnf) printf '%s\n' nasm:nasm clang:clang ld.lld:lld make:make cc:gcc objcopy:binutils \
                       git:git cmp:diffutils nc:nmap-ncat curl:curl unzip:unzip gzip:gzip file:file xz:xz ;;
    brew) printf '%s\n' nasm:nasm clang:llvm ld.lld:llvm make:make git:git ;;
  esac
}

dedup() { [ "$#" -gt 0 ] && printf '%s\n' "$@" | awk '!seen[$0]++'; }

CORE_PKGS=()
while IFS=: read -r _cmd _pkg; do
  [ -n "${_cmd:-}" ] || continue
  command -v "$_cmd" >/dev/null 2>&1 || CORE_PKGS+=("$_pkg")
done <<EOF
$(core_pairs)
EOF
[ "${#CORE_PKGS[@]}" -gt 0 ] && CORE_PKGS=($(dedup "${CORE_PKGS[@]}")) || true

EMU_PKGS=()
if [ "$WANT_QEMU" = 1 ] && ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
  case "$PM" in apt) EMU_PKGS+=(qemu-system-x86);; dnf) EMU_PKGS+=(qemu-system-x86);; brew) EMU_PKGS+=(qemu);; esac
fi
if [ "$WANT_PI4" = 1 ] && ! command -v qemu-system-aarch64 >/dev/null 2>&1; then
  case "$PM" in apt) EMU_PKGS+=(qemu-system-arm);; dnf) EMU_PKGS+=(qemu-system-aarch64);; brew) EMU_PKGS+=(qemu);; esac
fi
if [ "$WANT_OVMF" = 1 ]; then
  case "$PM" in apt) EMU_PKGS+=(ovmf);; dnf) EMU_PKGS+=(edk2-ovmf);; brew) : ;; esac  # brew bundles edk2 firmware with qemu
fi
[ "${#EMU_PKGS[@]}" -gt 0 ] && EMU_PKGS=($(dedup "${EMU_PKGS[@]}")) || true

# ---- install ---------------------------------------------------------------
install_core() {
  if [ "${#CORE_PKGS[@]}" -eq 0 ]; then log "build tools already present; nothing to install"; return 0; fi
  log "installing build tools: ${CORE_PKGS[*]}"
  case "$PM" in
    apt)
      $SUDO apt-get update -y
      $SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${CORE_PKGS[@]}"
      ;;
    dnf)
      $SUDO "$DNF" install -y "${CORE_PKGS[@]}"
      ;;
    brew)
      command -v brew >/dev/null 2>&1 || die "Homebrew not found. Install it from https://brew.sh first."
      # Ensure the Xcode Command Line Tools (clang/make/headers) are present.
      xcode-select -p >/dev/null 2>&1 || { log "requesting Xcode Command Line Tools..."; xcode-select --install || true; }
      brew install "${CORE_PKGS[@]}"
      ;;
  esac
}

install_emulation() {
  [ "${#EMU_PKGS[@]}" -gt 0 ] || return 0
  log "installing emulation (QEMU/OVMF): ${EMU_PKGS[*]}"
  case "$PM" in
    apt)  $SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${EMU_PKGS[@]}" ;;
    brew) brew install "${EMU_PKGS[@]}" ;;
    dnf)
      if ! $SUDO "$DNF" install -y "${EMU_PKGS[@]}"; then
        warn "QEMU/OVMF not installable via $DNF. Amazon Linux 2023's default repos do not ship"
        warn "qemu-system-* or edk2-ovmf. Build tools above still work for assembling the kernel,"
        warn "but run the QEMU boot-proof on macOS (brew), Debian/Ubuntu (apt), Codespaces, or Fedora."
      fi
      ;;
  esac
}

install_cloud_play() {
  [ "$WANT_CLOUD_PLAY" = 1 ] || return 0
  log "installing optional cloud-play deps (noVNC + websockify)"
  case "$PM" in
    apt) $SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends novnc websockify || warn "cloud-play deps failed (apt)";;
    dnf) $SUDO "$DNF" install -y novnc python3-websockify || warn "cloud-play deps not available via dnf; on Codespaces use the Debian devcontainer";;
    brew) warn "cloud-play (noVNC/websockify) is a Linux/Codespaces path; skipping on macOS";;
  esac
}

# Zig: brew on macOS; pinned static tarball on Linux.
install_zig() {
  [ "$WANT_ZIG" = 1 ] || return 0
  if command -v zig >/dev/null 2>&1; then log "zig already present: $(zig version)"; return 0; fi
  if [ "$PM" = "brew" ]; then brew install zig; return 0; fi

  local ver="${ZIG_VERSION:-0.13.0}"
  local zarch="$ARCH"   # x86_64 or aarch64 match Zig's linux tarball naming
  local url="https://ziglang.org/download/${ver}/zig-linux-${zarch}-${ver}.tar.xz"
  local libdir="${ZIG_INSTALL_DIR:-/usr/local/lib}"
  local tmp; tmp="$(mktemp -d)"
  log "downloading Zig ${ver} for linux-${zarch}"
  if ! curl -fSL "$url" -o "$tmp/zig.tar.xz"; then
    warn "Zig download failed ($url). Install Zig manually and re-run, or use --skip-zig."
    rm -rf "$tmp"; return 0
  fi
  $SUDO mkdir -p "$libdir"
  $SUDO tar -C "$libdir" -xJf "$tmp/zig.tar.xz"
  $SUDO ln -sf "$libdir/zig-linux-${zarch}-${ver}/zig" /usr/local/bin/zig
  rm -rf "$tmp"
  log "zig installed: $(zig version 2>/dev/null || echo '(not on PATH - add /usr/local/bin)')"
}

if [ "$CHECK_ONLY" = 0 ]; then
  install_core
  install_emulation
  install_cloud_play
  install_zig
else
  log "--check: skipping installation"
fi

# ---- verification ----------------------------------------------------------
MISSING_REQUIRED=0
ok()   { printf '  \033[1;32mOK  \033[0m %-22s %s\n' "$1" "${2:-}"; }
miss() { printf '  \033[1;31mMISS\033[0m %-22s %s\n' "$1" "${2:-}"; }
note() { printf '  \033[1;33m--  \033[0m %-22s %s\n' "$1" "${2:-}"; }

ver1() { "$@" 2>&1 | head -n1; }

check_req() {  # check_req <display> <cmd...>
  local name="$1"; shift
  if command -v "$1" >/dev/null 2>&1; then ok "$name" "$(ver1 "$@")"; else miss "$name" "(required)"; MISSING_REQUIRED=1; fi
}
check_opt() {
  local name="$1"; shift
  if command -v "$1" >/dev/null 2>&1; then ok "$name" "$(ver1 "$@")"; else note "$name" "(optional, not installed)"; fi
}

echo
log "verification report"
check_req "nasm"               nasm -v
check_req "clang"              clang --version
# LLD ships as ld.lld (ELF) and/or lld-link (PE, used for the UEFI loader).
if command -v ld.lld >/dev/null 2>&1; then ok "lld (ld.lld)" "$(ver1 ld.lld --version)";
elif command -v lld-link >/dev/null 2>&1; then ok "lld (lld-link)" "$(ver1 lld-link --version)";
else miss "lld" "(required for UEFI link)"; MISSING_REQUIRED=1; fi
check_req "make"               make --version
check_req "cc (host C)"        cc --version
check_req "git"                git --version
check_req "cmp (diffutils)"    cmp --version
check_req "curl"               curl --version
check_req "unzip"              unzip -v
check_req "gzip"               gzip --version
check_req "file"               file --version
check_req "xz"                 xz --version
if [ "$WANT_QEMU" = 1 ]; then check_req "qemu-system-x86_64" qemu-system-x86_64 --version; fi
# netcat: command name is always 'nc' regardless of provider.
if command -v nc >/dev/null 2>&1; then ok "netcat (nc)" "$(command -v nc)"; else miss "netcat (nc)" "(required for QEMU monitor)"; MISSING_REQUIRED=1; fi

if [ "$WANT_PI4"  = 1 ]; then check_opt "qemu-system-aarch64" qemu-system-aarch64 --version; fi
if [ "$WANT_ZIG"  = 1 ]; then check_opt "zig"                  zig version; fi
if [ "$WANT_OVMF" = 1 ]; then
  ovmf=""
  for c in /usr/share/OVMF/OVMF_CODE.fd /usr/share/edk2/ovmf/OVMF_CODE.fd \
           /usr/share/edk2/x64/OVMF_CODE.fd /usr/share/qemu/edk2-x86_64-code.fd \
           /opt/homebrew/share/qemu/edk2-x86_64-code.fd; do
    [ -f "$c" ] && { ovmf="$c"; break; }
  done
  if [ -n "$ovmf" ]; then ok "OVMF firmware" "$ovmf"; else note "OVMF firmware" "(not found; UEFI proof only)"; fi
fi
if [ "$WANT_CLOUD_PLAY" = 1 ]; then check_opt "websockify" websockify --version; fi

echo
if [ "$MISSING_REQUIRED" -ne 0 ]; then
  die "some REQUIRED tools are missing (see MISS lines above)."
fi
log "all required tools present. Build x86:  make play     Pi4:  make ALLOW_LOCAL_VM=1 pi4-local-qemu-live"
[ "$WANT_ZIG" = 1 ] && command -v zig >/dev/null 2>&1 && log "Linux-personality binaries: make -C tests/linux"
log "done."
