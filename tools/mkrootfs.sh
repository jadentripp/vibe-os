#!/bin/sh
# mkrootfs.sh — build the Linux personality M-1 test binaries and produce a
# disk image with them injected onto the guest FAT filesystem under /BIN.
#
# This repo has no mtools; guest files are placed by the project's own
# assembly image builder (make_wad_image) via `--asset /PATH=hostfile`. The
# top-level Makefile already exposes IMAGE_EXTRA_ROOT_ELF_ARGS /
# IMAGE_EXTRA_ROOT_ELF_DEPS as the hook for adding extra root files, so this
# script just drives a normal image build with the test binaries added.
#
# Usage: tools/mkrootfs.sh
#   Rebuilds build/disk.img containing /BIN/HELLO.ELF (and future test bins).
set -eu

cd "$(dirname "$0")/.."
ROOT="$(pwd)"

# 1. Build the repo linker, then the Linux test binaries.
make build/link_elf32
make -C tests/linux

# 2. Collect --asset args for every built binary under /BIN.
ASSETS="--asset /BIN/HELLO.ELF=tests/linux/hello_write"
DEPS="tests/linux/hello_write"
if [ -f tests/linux/auxv_dump ]; then
    ASSETS="$ASSETS --asset /BIN/AUXVD.ELF=tests/linux/auxv_dump"
    DEPS="$DEPS tests/linux/auxv_dump"
fi
if [ -f tests/linux/tls_probe ]; then
    ASSETS="$ASSETS --asset /BIN/TLSPROBE.ELF=tests/linux/tls_probe"
    DEPS="$DEPS tests/linux/tls_probe"
fi

# 3. Rebuild the disk image with the test binaries injected.
make DOOM_WAD= ALLOW_LOCAL_VM=0 \
     IMAGE_EXTRA_ROOT_ELF_ARGS="$ASSETS" \
     IMAGE_EXTRA_ROOT_ELF_DEPS="$DEPS"

echo "Injected Linux test binaries into build/disk.img:"
echo "  $ASSETS"
