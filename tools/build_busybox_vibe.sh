#!/bin/sh
# Build the static i386 BusyBox artifact used by Linux M1a guest smokes.
set -eu

cd "$(dirname "$0")/.."

src=${BUSYBOX_SRC_DIR:-build/busybox-src/busybox-1.35.0}
out=${BUSYBOX_OUT:-build/busybox-i386/busybox-vibe}
cfg="$src/.config"
zig_bin=${ZIG:-zig}
hostcc=${HOSTCC:-cc}

if [ ! -f "$cfg" ]; then
    echo "error: BusyBox source/config not found: $cfg" >&2
    echo "       expected the existing ignored source tree under build/busybox-src" >&2
    exit 1
fi

if ! command -v "$zig_bin" >/dev/null 2>&1; then
    echo "error: zig not found; set ZIG=/path/to/zig" >&2
    exit 1
fi

set_bool() {
    name=$1
    value=$2
    tmp=$cfg.tmp.$$

    case "$value" in
        y)
            line="$name=y"
            ;;
        n)
            line="# $name is not set"
            ;;
        *)
            echo "error: set_bool expects y or n for $name" >&2
            exit 1
            ;;
    esac

    awk -v name="$name" -v line="$line" '
        $0 == "# " name " is not set" || index($0, name "=") == 1 {
            if (!done) {
                print line
                done = 1
            }
            next
        }
        { print }
        END {
            if (!done) {
                print line
            }
        }
    ' "$cfg" > "$tmp"
    mv "$tmp" "$cfg"
}

jobs=${JOBS:-}
if [ -z "$jobs" ]; then
    jobs=$(getconf _NPROCESSORS_ONLN 2>/dev/null || true)
fi
case "$jobs" in
    ""|*[!0-9]*)
        jobs=4
        ;;
esac

# Keep the M1a applet set useful but modest: shell plus the first coreutils
# needed for docs acceptance, with optional feature growth held back.
set_bool CONFIG_STATIC y
set_bool CONFIG_CAT y
set_bool CONFIG_CP y
set_bool CONFIG_ECHO y
set_bool CONFIG_GREP y
set_bool CONFIG_HEAD y
set_bool CONFIG_LN y
set_bool CONFIG_LS y
set_bool CONFIG_MKDIR y
set_bool CONFIG_MV y
set_bool CONFIG_PRINTF y
set_bool CONFIG_PWD y
set_bool CONFIG_PS y
set_bool CONFIG_RM y
set_bool CONFIG_SLEEP y
set_bool CONFIG_STAT y
set_bool CONFIG_TAIL y
set_bool CONFIG_TEST y
set_bool CONFIG_TEST1 y
set_bool CONFIG_TRUE y
set_bool CONFIG_WC y
set_bool CONFIG_ASH y
set_bool CONFIG_SH_IS_ASH y
set_bool CONFIG_FEATURE_SH_STANDALONE y

set_bool CONFIG_FEATURE_CP_LONG_OPTIONS n
set_bool CONFIG_FEATURE_CP_REFLINK n
set_bool CONFIG_FEATURE_GREP_CONTEXT n
set_bool CONFIG_FEATURE_FANCY_HEAD n
set_bool CONFIG_FEATURE_FANCY_SLEEP n
set_bool CONFIG_FEATURE_FANCY_TAIL n
set_bool CONFIG_FEATURE_LS_COLOR n
set_bool CONFIG_FEATURE_LS_COLOR_IS_DEFAULT n
set_bool CONFIG_FEATURE_LS_FILETYPES n
set_bool CONFIG_FEATURE_LS_FOLLOWLINKS n
set_bool CONFIG_FEATURE_LS_RECURSIVE n
set_bool CONFIG_FEATURE_LS_SORTFILES n
set_bool CONFIG_FEATURE_LS_TIMESTAMPS n
set_bool CONFIG_FEATURE_LS_USERNAME n
set_bool CONFIG_FEATURE_LS_WIDTH n
set_bool CONFIG_FEATURE_PS_ADDITIONAL_COLUMNS n
set_bool CONFIG_FEATURE_PS_LONG n
set_bool CONFIG_FEATURE_PS_TIME n
set_bool CONFIG_FEATURE_PS_UNUSUAL_SYSTEMS n
set_bool CONFIG_FEATURE_PS_WIDE n
set_bool CONFIG_FEATURE_STAT_FILESYSTEM n
set_bool CONFIG_FEATURE_STAT_FORMAT n
set_bool CONFIG_TEST2 n
set_bool CONFIG_FEATURE_TEST_64 n
set_bool CONFIG_FEATURE_WC_LARGE n

cc="$zig_bin cc -target x86-linux-musl"
target_ar="$zig_bin ar"
target_ranlib="$zig_bin ranlib"

(
    cd "$src"
    yes "" | make CC="$cc" HOSTCC="$hostcc" AR="$target_ar" RANLIB="$target_ranlib" SKIP_STRIP=y oldconfig >/dev/null
    make CC="$cc" HOSTCC="$hostcc" AR="$target_ar" RANLIB="$target_ranlib" SKIP_STRIP=y -j"$jobs" busybox
)

mkdir -p "$(dirname "$out")"
cp "$src/busybox" "$out"
chmod +x "$out"

echo "built $out"
