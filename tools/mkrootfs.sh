#!/bin/sh
# mkrootfs.sh - build the Linux personality M-1 test binaries and produce a
# disk image with them injected onto the guest FAT filesystem under /BIN.
#
# This repo has no mtools; guest files are placed by the project's own
# assembly image builder (make_wad_image) via `--asset /PATH=hostfile`. The
# top-level Makefile already exposes IMAGE_EXTRA_ROOT_ELF_ARGS /
# IMAGE_EXTRA_ROOT_ELF_DEPS as the hook for adding extra root files, so this
# script just drives a normal image build with the test binaries added.
#
# Usage: tools/mkrootfs.sh [--dry-run]
#   Rebuilds build/disk.img containing /BIN/HELLO.ELF, /BIN/AUXV.ELF,
#   /BIN/TLS.ELF, /BIN/STARTUP.ELF, /BIN/XLIMIT.ELF, /BIN/DIR.ELF,
#   /BIN/FD.ELF, /BIN/DEVNULL.ELF, /BIN/PIPE.ELF, /BIN/FORK.ELF,
#   /BIN/PROCEXE.ELF, /BIN/TMPDIR.ELF, /BIN/PROCID.ELF,
#   /BIN/LDSOHDR.ELF, and the current browser-startup syscall probes. If present,
#   tests/linux/linux_doom is installed as /BIN/LDOOM.ELF, and
#   build/busybox-i386/busybox-vibe is installed as /BIN/BUSYBOX.ELF.
#   If present, real-libc artifacts are also installed under /BIN and /LIB.
#   --dry-run prints the image-builder hook without creating build/disk.img.
set -eu

cd "$(dirname "$0")/.."

case "${1:-}" in
    "")
        DRY_RUN=0
        ;;
    --dry-run)
        DRY_RUN=1
        ;;
    -h|--help)
        echo "usage: tools/mkrootfs.sh [--dry-run]"
        exit 0
        ;;
    *)
        echo "usage: tools/mkrootfs.sh [--dry-run]" >&2
        exit 2
        ;;
esac

# 1. Build the repo linker, then the Linux test binaries.
make build/link_elf32
make -C tests/linux

find_glibc_lib_pair() {
    if [ -n "${VIBE_GLIBC_LIB_DIR:-}" ]; then
        if [ -f "$VIBE_GLIBC_LIB_DIR/ld-linux.so.2" ] && [ -f "$VIBE_GLIBC_LIB_DIR/libc.so.6" ]; then
            printf '%s %s\n' "$VIBE_GLIBC_LIB_DIR/ld-linux.so.2" "$VIBE_GLIBC_LIB_DIR/libc.so.6"
            return 0
        fi
        if [ -f "$VIBE_GLIBC_LIB_DIR/libld.so.2" ] && [ -f "$VIBE_GLIBC_LIB_DIR/libc.so.6" ]; then
            printf '%s %s\n' "$VIBE_GLIBC_LIB_DIR/libld.so.2" "$VIBE_GLIBC_LIB_DIR/libc.so.6"
            return 0
        fi
        return 1
    fi

    for dir in build/glibc-i386/lib/i386-linux-gnu build/glibc-i386/lib32; do
        if [ -f "$dir/ld-linux.so.2" ] && [ -f "$dir/libc.so.6" ]; then
            printf '%s %s\n' "$dir/ld-linux.so.2" "$dir/libc.so.6"
            return 0
        fi
    done

    zig_cache_dir="${ZIG_CACHE_DIR:-${HOME:-}/.cache/zig}"
    if [ ! -d "$zig_cache_dir/o" ]; then
        return 1
    fi

    for ldso in "$zig_cache_dir"/o/*/libld.so.2; do
        [ -f "$ldso" ] || continue
        dir=${ldso%/*}
        if [ -f "$dir/libc.so.6" ]; then
            printf '%s %s\n' "$dir/libld.so.2" "$dir/libc.so.6"
            return 0
        fi
    done

    return 1
}

# 2. Collect --asset args for every built binary under /BIN.
ASSETS="--asset /BIN/HELLO.ELF=tests/linux/hello_write --asset /BIN/AUXV.ELF=tests/linux/auxv_dump --asset /BIN/TLS.ELF=tests/linux/tls_probe --asset /BIN/STARTUP.ELF=tests/linux/startup_probe --asset /BIN/XLIMIT.ELF=tests/linux/exec_limits_probe --asset /BIN/DIR.ELF=tests/linux/dir_probe --asset /BIN/FD.ELF=tests/linux/fd_probe --asset /BIN/DEVNULL.ELF=tests/linux/dev_null_probe --asset /BIN/PIPE.ELF=tests/linux/pipe_probe --asset /BIN/FORK.ELF=tests/linux/fork_probe --asset /BIN/PROCEXE.ELF=tests/linux/proc_self_exe_probe --asset /BIN/TMPDIR.ELF=tests/linux/tmp_dir_probe --asset /BIN/PROCID.ELF=tests/linux/procid_probe --asset /BIN/LIBMAGIC.ELF=tests/linux/libmagic_probe --asset /BIN/LDSOHDR.ELF=tests/linux/ldso_header_probe --asset /BIN/WRITEV.ELF=tests/linux/writev_probe --asset /BIN/EVENTFD.ELF=tests/linux/eventfd_probe --asset /BIN/EPOLL.ELF=tests/linux/epoll_probe --asset /BIN/TIMERFD.ELF=tests/linux/timerfd_probe --asset /BIN/FUTEX.ELF=tests/linux/futex_probe --asset /BIN/THREAD.ELF=tests/linux/thread_probe"
DEPS="tests/linux/hello_write tests/linux/auxv_dump tests/linux/tls_probe tests/linux/startup_probe tests/linux/exec_limits_probe tests/linux/dir_probe tests/linux/fd_probe tests/linux/dev_null_probe tests/linux/pipe_probe tests/linux/fork_probe tests/linux/proc_self_exe_probe tests/linux/tmp_dir_probe tests/linux/procid_probe tests/linux/libmagic_probe tests/linux/ldso_header_probe tests/linux/writev_probe tests/linux/eventfd_probe tests/linux/epoll_probe tests/linux/timerfd_probe tests/linux/futex_probe tests/linux/thread_probe"

if [ -f tests/linux/hello_musl ]; then
    ASSETS="$ASSETS --asset /BIN/MUSL.ELF=tests/linux/hello_musl"
    DEPS="$DEPS tests/linux/hello_musl"
fi

if [ -f build/busybox-i386/busybox-vibe ]; then
    ASSETS="$ASSETS --asset /BIN/BUSYBOX.ELF=build/busybox-i386/busybox-vibe"
    DEPS="$DEPS build/busybox-i386/busybox-vibe"
fi

if [ -f tests/linux/linux_doom ]; then
    ASSETS="$ASSETS --asset /BIN/LDOOM.ELF=tests/linux/linux_doom"
    DEPS="$DEPS tests/linux/linux_doom"
fi

if [ -f tests/linux/hello_glibc ]; then
    ASSETS="$ASSETS --asset /BIN/GLIBC.ELF=tests/linux/hello_glibc"
    DEPS="$DEPS tests/linux/hello_glibc"
    if GLIBC_LIB_PAIR=$(find_glibc_lib_pair); then
        set -- $GLIBC_LIB_PAIR
        GLIBC_LDSO=$1
        GLIBC_LIBC=$2
        # The current image builder stores 8.3 names, so these are metadata
        # smoke aliases for /lib/ld-linux.so.2 and /lib/libc.so.6.
        ASSETS="$ASSETS --asset /LIB/LDLINUX.SO2=$GLIBC_LDSO --asset /LIB/LIBC.SO6=$GLIBC_LIBC"
        DEPS="$DEPS $GLIBC_LDSO $GLIBC_LIBC"
    else
        echo "warning: tests/linux/hello_glibc exists, but glibc ld.so/libc.so.6 were not found" >&2
    fi
fi

if [ "$DRY_RUN" = "1" ]; then
    echo "IMAGE_EXTRA_ROOT_ELF_ARGS=\"$ASSETS\""
    echo "IMAGE_EXTRA_ROOT_ELF_DEPS=\"$DEPS\""
    exit 0
fi

# 3. Rebuild the disk image with the test binaries injected.
make DOOM_WAD= ALLOW_LOCAL_VM=0 \
     IMAGE_EXTRA_ROOT_ELF_ARGS="$ASSETS" \
     IMAGE_EXTRA_ROOT_ELF_DEPS="$DEPS"

echo "Injected Linux test binaries into build/disk.img:"
echo "  $ASSETS"
