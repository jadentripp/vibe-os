#!/bin/sh
# Print image-builder hooks for the ignored Debian sid i386 Chromium artifacts.
#
# This is intentionally a staging helper only: it does not download packages,
# build the image, or run a VM smoke. The guest paths mirror kernel/kernel.asm's
# current Linux library alias contract.
set -eu

LC_ALL=C
export LC_ALL

cd "$(dirname "$0")/.."

CHROMIUM_DIR=${CHROMIUM_I386_DIR:-build/chromium-i386}
RUNTIME_DIR=${CHROMIUM_RUNTIME_I386_DIR:-build/chromium-runtime-i386}
CHROMIUM_ELF=${CHROMIUM_I386_ELF:-$CHROMIUM_DIR/root/usr/lib/chromium/chromium}
ICU_DAT=${CHROMIUM_I386_ICU_DAT:-$CHROMIUM_DIR/common-root/usr/lib/chromium/icudtl.dat}

MODE=env

usage() {
    cat <<'EOF'
usage: tools/chromium_i386_smoke_assets.sh [--dry-run|--list]

Print IMAGE_EXTRA_ROOT_ELF_ARGS and IMAGE_EXTRA_ROOT_ELF_DEPS for the current
ignored build/chromium-i386 and build/chromium-runtime-i386 artifacts.

  --dry-run  Print make variable assignments. This is the default.
  --list     Print one guest=host asset mapping per line.
  -h, --help Show this help text.

Environment overrides:
  CHROMIUM_I386_DIR
  CHROMIUM_RUNTIME_I386_DIR
  CHROMIUM_I386_ELF
  CHROMIUM_I386_ICU_DAT

No files are generated and no VM smoke is run.
EOF
}

case "${1:---dry-run}" in
    --dry-run)
        MODE=env
        ;;
    --list)
        MODE=list
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

fail() {
    echo "chromium_i386_smoke_assets: $*" >&2
    exit 1
}

[ -f "$CHROMIUM_ELF" ] || fail "missing Chromium ELF: $CHROMIUM_ELF"
[ -f "$ICU_DAT" ] || fail "missing Chromium ICU data: $ICU_DAT"
[ -d "$RUNTIME_DIR" ] || fail "missing Chromium runtime dir: $RUNTIME_DIR"

if command -v llvm-objdump >/dev/null 2>&1; then
    OBJDUMP=$(command -v llvm-objdump)
elif command -v xcrun >/dev/null 2>&1 && OBJDUMP=$(xcrun -find llvm-objdump 2>/dev/null); then
    :
elif command -v objdump >/dev/null 2>&1; then
    OBJDUMP=$(command -v objdump)
else
    fail "need llvm-objdump, xcrun llvm-objdump, or objdump to inspect ELF NEEDED entries"
fi

dump_needed() {
    file=$1
    awk -F '	' -v file="$file" '$1 == file { print $2 }' "$NEEDED_INDEX"
}

tmp_base=${TMPDIR:-/tmp}/vibe-chromium-assets.$$
mkdir "$tmp_base" || fail "could not create temporary work dir: $tmp_base"
trap 'rm -rf "$tmp_base"' EXIT HUP INT TERM

QUEUE=$tmp_base/queue
NEXT_QUEUE=$tmp_base/queue.next
SEEN=$tmp_base/seen
MISSING=$tmp_base/missing
LIB_INDEX=$tmp_base/lib-index
DYNAMIC_DUMP=$tmp_base/dynamic-dump
NEEDED_INDEX=$tmp_base/needed-index
: > "$QUEUE"
: > "$SEEN"
: > "$MISSING"

find "$RUNTIME_DIR" \( -type f -o -type l \) \
    \( -name 'lib*.so' -o -name 'lib*.so.[0-9]*' -o -name 'ld-linux.so.2' \) \
    ! -name '*.py' -print |
    sort |
    while IFS= read -r path; do
        printf '%s\t%s\n' "${path##*/}" "$path"
    done > "$LIB_INDEX"

LIB_PATHS=$(awk -F '	' '{ print $2 }' "$LIB_INDEX")
"$OBJDUMP" -p "$CHROMIUM_ELF" $LIB_PATHS > "$DYNAMIC_DUMP"
awk '
/:	file format/ {
    path = $0
    sub(/:[[:space:]]*file format.*/, "", path)
    next
}
$1 == "NEEDED" {
    print path "\t" $2
}
' "$DYNAMIC_DUMP" > "$NEEDED_INDEX"

enqueue_needed() {
    needed=$1
    [ -n "$needed" ] || return 0
    if grep -Fxq "$needed" "$SEEN" 2>/dev/null; then
        return 0
    fi
    if grep -Fxq "$needed" "$QUEUE" 2>/dev/null; then
        return 0
    fi
    printf '%s\n' "$needed" >> "$QUEUE"
}

find_lib_by_name() {
    needed=$1
    awk -F '	' -v needed="$needed" '$1 == needed { print $2; exit }' "$LIB_INDEX"
}

upper_alnum_8() {
    printf '%s' "$1" | tr '[:lower:]' '[:upper:]' | tr -cd 'A-Z0-9' | cut -c 1-8
}

upper_alnum_1() {
    printf '%s' "$1" | tr '[:lower:]' '[:upper:]' | tr -cd 'A-Z0-9' | cut -c 1
}

library_guest_path() {
    name=$1

    case "$name" in
        ld-linux.so.2)
            printf '%s\n' /LIB/LDLINUX.SO2
            return 0
            ;;
        libc.so.6)
            printf '%s\n' /LIB/LIBC.SO6
            return 0
            ;;
        libglib-2.0.so.0*)
            printf '%s\n' /LIB/GLIB20.SO0
            return 0
            ;;
        libgobject-2.0.so.0*)
            printf '%s\n' /LIB/GOBJ20.SO0
            return 0
            ;;
        libgio-2.0.so.0*)
            printf '%s\n' /LIB/GIO20.SO0
            return 0
            ;;
        libharfbuzz-subset.so.0*)
            printf '%s\n' /LIB/HBSUBSET.SO0
            return 0
            ;;
    esac

    case "$name" in
        lib*.so*)
            ;;
        *)
            return 1
            ;;
    esac

    stem=${name#lib}
    stem=${stem%%.so*}
    base=$(upper_alnum_8 "$stem")
    [ -n "$base" ] || return 1

    rest=${name#*.so}
    version=
    case "$rest" in
        .*)
            version=$(upper_alnum_1 "${rest#.}")
            ;;
    esac

    printf '/LIB/%s.SO%s\n' "$base" "$version"
}

ASSETS=
DEPS=
GUEST_PATHS=
ASSET_LINES=

add_asset() {
    guest=$1
    host=$2

    [ -e "$host" ] || fail "asset host path does not exist: $host"

    case " $GUEST_PATHS " in
        *" $guest "*)
            return 0
            ;;
    esac

    GUEST_PATHS="${GUEST_PATHS:+$GUEST_PATHS }$guest"
    ASSETS="${ASSETS:+$ASSETS }--asset $guest=$host"
    DEPS="${DEPS:+$DEPS }$host"
    ASSET_LINES="${ASSET_LINES}${guest}=${host}
"
}

add_asset /BIN/CHROMIUM.ELF "$CHROMIUM_ELF"
add_asset /BIN/ICUDTL.DAT "$ICU_DAT"

for needed in $(dump_needed "$CHROMIUM_ELF"); do
    enqueue_needed "$needed"
done

while [ -s "$QUEUE" ]; do
    needed=$(sed -n '1p' "$QUEUE")
    sed '1d' "$QUEUE" > "$NEXT_QUEUE"
    mv "$NEXT_QUEUE" "$QUEUE"

    if grep -Fxq "$needed" "$SEEN" 2>/dev/null; then
        continue
    fi
    printf '%s\n' "$needed" >> "$SEEN"

    host=$(find_lib_by_name "$needed")
    if [ -z "$host" ]; then
        printf '%s\n' "$needed" >> "$MISSING"
        continue
    fi

    guest=$(library_guest_path "$needed") || fail "cannot map library name to guest alias: $needed"
    add_asset "$guest" "$host"

    for child_needed in $(dump_needed "$host"); do
        enqueue_needed "$child_needed"
    done
done

if [ -s "$MISSING" ]; then
    echo "missing recursive Chromium runtime libraries:" >&2
    sed 's/^/  /' "$MISSING" >&2
    exit 1
fi

case "$MODE" in
    env)
        printf 'IMAGE_EXTRA_ROOT_ELF_ARGS="%s"\n' "$ASSETS"
        printf 'IMAGE_EXTRA_ROOT_ELF_DEPS="%s"\n' "$DEPS"
        ;;
    list)
        printf '%s' "$ASSET_LINES"
        ;;
esac
