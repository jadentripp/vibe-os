#!/bin/sh
# Run focused Linux M1 personality smokes and preserve per-case proof files.
set -eu

cd "$(dirname "$0")/.."

MAKE_BIN=${MAKE:-make}
OUT_DIR=${LINUX_M1_SMOKE_MATRIX_DIR:-build/linux-m1-smoke-matrix}
SMOKE_QEMU_TIMEOUT_VALUE=${SMOKE_QEMU_TIMEOUT:-45}
BASE_NASMFLAGS="-D LINUX_M1_SMOKE"
EXTRA_NASMFLAGS=${LINUX_M1_EXTRA_NASMFLAGS:-}
DEFAULT_CASES="hello auxv tls startup exec-limits dir fd pipe fork clone3"
ALL_CASES="hello auxv tls startup exec-limits dir fd pipe fork clone3 proc-exe tmpdir dev-null llseek time futex thread rseq busybox-echo busybox-true busybox-sh busybox-ls busybox-cat busybox-cp busybox-grep busybox-sleep busybox-ps"

usage() {
    cat <<'EOF'
usage: tools/linux_m1_smoke_matrix.sh [--list] [case...]

Runs focused Linux M1 smoke selectors, preserves build/status.txt and
build/serial.log under build/linux-m1-smoke-matrix/, and asserts guest-visible
status plus serial evidence.

Environment:
  SMOKE_QEMU_TIMEOUT              QEMU timeout per case (default: 45)
  LINUX_M1_EXTRA_NASMFLAGS        extra NASM flags appended to each case
  LINUX_M1_SMOKE_MATRIX_DIR       proof output directory
  MAKE                            make binary
EOF
}

die() {
    echo "error: $*" >&2
    exit 2
}

log() {
    printf '[linux-m1-matrix] %s\n' "$*"
}

normalize_case() {
    case "$1" in
        proc-self-exe) printf '%s\n' "proc-exe" ;;
        devnull) printf '%s\n' "dev-null" ;;
        busybox|busybox-echo) printf '%s\n' "busybox-echo" ;;
        *) printf '%s\n' "$1" ;;
    esac
}

case_config() {
    CASE_NAME=$1
    CASE_SELECTOR=
    CASE_FLAGS=
    CASE_PATH=
    CASE_ASSETS=
    CASE_SERIAL=
    CASE_EXIT=
    CASE_LAST_UNIMPL_NR=00000000
    CASE_STATUS_FIELDS="exec=OK"

    case "$CASE_NAME" in
        hello)
            CASE_PATH=/BIN/HELLO.ELF
            CASE_ASSETS=/BIN/HELLO.ELF
            CASE_SERIAL="hello from linux personality"
            CASE_EXIT=0000002A
            CASE_STATUS_FIELDS="$CASE_STATUS_FIELDS argc=00000001 argvsrc=00000001"
            ;;
        auxv)
            CASE_SELECTOR=LINUX_M1_AUXV_SMOKE
            CASE_FLAGS="-D $CASE_SELECTOR"
            CASE_PATH=/BIN/AUXV.ELF
            CASE_ASSETS=/BIN/AUXV.ELF
            CASE_SERIAL="auxv end"
            CASE_EXIT=00000000
            CASE_STATUS_FIELDS="$CASE_STATUS_FIELDS argc=00000001 argvsrc=00000001"
            ;;
        tls)
            CASE_SELECTOR=LINUX_M1_TLS_SMOKE
            CASE_FLAGS="-D $CASE_SELECTOR"
            CASE_PATH=/BIN/TLS.ELF
            CASE_ASSETS=/BIN/TLS.ELF
            CASE_SERIAL="tls ok"
            CASE_EXIT=00000000
            CASE_STATUS_FIELDS="$CASE_STATUS_FIELDS argc=00000001 argvsrc=00000001"
            ;;
        startup)
            CASE_SELECTOR=LINUX_M1_STARTUP_SMOKE
            CASE_FLAGS="-D $CASE_SELECTOR"
            CASE_PATH=/BIN/STARTUP.ELF
            CASE_ASSETS=/BIN/STARTUP.ELF
            CASE_SERIAL="startup ok"
            CASE_EXIT=00000007
            CASE_STATUS_FIELDS="$CASE_STATUS_FIELDS argc=00000001 argvsrc=00000001"
            ;;
        exec-limits)
            CASE_SELECTOR=LINUX_M1_EXEC_LIMITS_SMOKE
            CASE_FLAGS="-D $CASE_SELECTOR"
            CASE_PATH=/BIN/XLIMIT.ELF
            CASE_ASSETS=/BIN/XLIMIT.ELF
            CASE_SERIAL="exec limits ok"
            CASE_EXIT=00000009
            CASE_STATUS_FIELDS="$CASE_STATUS_FIELDS argc=0000000A argvsrc=00000002"
            ;;
        dir)
            CASE_SELECTOR=LINUX_M1_DIR_SMOKE
            CASE_FLAGS="-D $CASE_SELECTOR"
            CASE_PATH=/BIN/DIR.ELF
            CASE_ASSETS=/BIN/DIR.ELF
            CASE_SERIAL="dir ok"
            CASE_EXIT=0000000F
            CASE_STATUS_FIELDS="$CASE_STATUS_FIELDS argc=00000001 argvsrc=00000001"
            ;;
        fd)
            CASE_SELECTOR=LINUX_M1_FD_SMOKE
            CASE_FLAGS="-D $CASE_SELECTOR"
            CASE_PATH=/BIN/FD.ELF
            CASE_ASSETS=/BIN/FD.ELF
            CASE_SERIAL="fd ok"
            CASE_EXIT=00000011
            CASE_STATUS_FIELDS="$CASE_STATUS_FIELDS argc=00000001 argvsrc=00000001"
            ;;
        pipe)
            CASE_SELECTOR=LINUX_M1_PIPE_SMOKE
            CASE_FLAGS="-D $CASE_SELECTOR"
            CASE_PATH=/BIN/PIPE.ELF
            CASE_ASSETS=/BIN/PIPE.ELF
            CASE_SERIAL="pipe ok"
            CASE_EXIT=00000013
            CASE_STATUS_FIELDS="$CASE_STATUS_FIELDS argc=00000001 argvsrc=00000001"
            ;;
        fork)
            CASE_SELECTOR=LINUX_M1_FORK_SMOKE
            CASE_FLAGS="-D $CASE_SELECTOR"
            CASE_PATH=/BIN/FORK.ELF
            CASE_ASSETS=/BIN/FORK.ELF
            CASE_SERIAL="fork ok"
            CASE_EXIT=00000015
            CASE_STATUS_FIELDS="$CASE_STATUS_FIELDS argc=00000001 argvsrc=00000001"
            ;;
        clone3)
            CASE_SELECTOR=LINUX_M1_CLONE3_SMOKE
            CASE_FLAGS="-D $CASE_SELECTOR"
            CASE_PATH=/BIN/CLONE3.ELF
            CASE_ASSETS=/BIN/CLONE3.ELF
            CASE_SERIAL="clone3 ok"
            CASE_EXIT=00000031
            CASE_STATUS_FIELDS="$CASE_STATUS_FIELDS argc=00000001 argvsrc=00000001"
            ;;
        proc-exe)
            CASE_SELECTOR=LINUX_M1_PROC_SELF_EXE_SMOKE
            CASE_FLAGS="-D $CASE_SELECTOR"
            CASE_PATH=/BIN/PROCEXE.ELF
            CASE_ASSETS=/BIN/PROCEXE.ELF
            CASE_SERIAL="proc self exe ok"
            CASE_EXIT=00000019
            CASE_STATUS_FIELDS="$CASE_STATUS_FIELDS argc=00000001 argvsrc=00000001"
            ;;
        tmpdir)
            CASE_SELECTOR=LINUX_M1_TMPDIR_SMOKE
            CASE_FLAGS="-D $CASE_SELECTOR"
            CASE_PATH=/BIN/TMPDIR.ELF
            CASE_ASSETS=/BIN/TMPDIR.ELF
            CASE_SERIAL="tmpdir ok"
            CASE_EXIT=00000017
            CASE_STATUS_FIELDS="$CASE_STATUS_FIELDS argc=00000001 argvsrc=00000001"
            ;;
        dev-null)
            CASE_SELECTOR=LINUX_M1_DEV_NULL_SMOKE
            CASE_FLAGS="-D $CASE_SELECTOR"
            CASE_PATH=/BIN/DEVNULL.ELF
            CASE_ASSETS=/BIN/DEVNULL.ELF
            CASE_SERIAL="devnull ok"
            CASE_EXIT=00000017
            CASE_STATUS_FIELDS="$CASE_STATUS_FIELDS argc=00000001 argvsrc=00000001"
            ;;
        llseek)
            CASE_SELECTOR=LINUX_M1_LLSEEK_SMOKE
            CASE_FLAGS="-D $CASE_SELECTOR"
            CASE_PATH=/BIN/LLSEEK.ELF
            CASE_ASSETS=/BIN/LLSEEK.ELF
            CASE_SERIAL="llseek ok"
            CASE_EXIT=00000023
            CASE_STATUS_FIELDS="$CASE_STATUS_FIELDS argc=00000001 argvsrc=00000001"
            ;;
        time)
            CASE_SELECTOR=LINUX_M1_TIME_SMOKE
            CASE_FLAGS="-D $CASE_SELECTOR"
            CASE_PATH=/BIN/TIME.ELF
            CASE_ASSETS=/BIN/TIME.ELF
            CASE_SERIAL="time ok"
            CASE_EXIT=00000020
            CASE_STATUS_FIELDS="$CASE_STATUS_FIELDS argc=00000001 argvsrc=00000001"
            ;;
        futex)
            CASE_SELECTOR=LINUX_M1_FUTEX_SMOKE
            CASE_FLAGS="-D $CASE_SELECTOR"
            CASE_PATH=/BIN/FUTEX.ELF
            CASE_ASSETS=/BIN/FUTEX.ELF
            CASE_SERIAL="futex ok"
            CASE_EXIT=00000020
            CASE_STATUS_FIELDS="$CASE_STATUS_FIELDS argc=00000001 argvsrc=00000001"
            ;;
        thread)
            CASE_SELECTOR=LINUX_M1_THREAD_SMOKE
            CASE_FLAGS="-D $CASE_SELECTOR"
            CASE_PATH=/BIN/THREAD.ELF
            CASE_ASSETS=/BIN/THREAD.ELF
            CASE_SERIAL="thread ok"
            CASE_EXIT=00000021
            CASE_STATUS_FIELDS="$CASE_STATUS_FIELDS argc=00000001 argvsrc=00000001"
            ;;
        rseq)
            CASE_SELECTOR=LINUX_M1_RSEQ_SMOKE
            CASE_FLAGS="-D $CASE_SELECTOR"
            CASE_PATH=/BIN/RSEQ.ELF
            CASE_ASSETS=/BIN/RSEQ.ELF
            CASE_SERIAL="rseq ok"
            CASE_EXIT=00000022
            CASE_STATUS_FIELDS="$CASE_STATUS_FIELDS argc=00000001 argvsrc=00000001"
            ;;
        busybox-echo)
            CASE_SELECTOR=LINUX_M1_BUSYBOX_SMOKE
            CASE_FLAGS="-D $CASE_SELECTOR"
            CASE_PATH=/BIN/BUSYBOX.ELF
            CASE_ASSETS=/BIN/BUSYBOX.ELF
            CASE_SERIAL="busybox-ok"
            CASE_EXIT=00000000
            CASE_STATUS_FIELDS="$CASE_STATUS_FIELDS argc=00000003 argvsrc=00000002"
            ;;
        busybox-true)
            CASE_SELECTOR=LINUX_M1_BUSYBOX_TRUE_SMOKE
            CASE_FLAGS="-D $CASE_SELECTOR"
            CASE_PATH=/BIN/BUSYBOX.ELF
            CASE_ASSETS=/BIN/BUSYBOX.ELF
            CASE_EXIT=00000000
            CASE_STATUS_FIELDS="$CASE_STATUS_FIELDS argc=00000002 argvsrc=00000002"
            ;;
        busybox-sh)
            CASE_SELECTOR=LINUX_M1_BUSYBOX_SH_SMOKE
            CASE_FLAGS="-D $CASE_SELECTOR"
            CASE_PATH=/BIN/BUSYBOX.ELF
            CASE_ASSETS=/BIN/BUSYBOX.ELF
            CASE_SERIAL="busybox-ok"
            CASE_EXIT=00000000
            CASE_STATUS_FIELDS="$CASE_STATUS_FIELDS argc=00000004 argvsrc=00000002"
            ;;
        busybox-ls)
            CASE_SELECTOR=LINUX_M1_BUSYBOX_LS_SMOKE
            CASE_FLAGS="-D $CASE_SELECTOR"
            CASE_PATH=/BIN/BUSYBOX.ELF
            CASE_ASSETS=/BIN/BUSYBOX.ELF
            CASE_SERIAL="HELLO.ELF"
            CASE_EXIT=00000000
            CASE_STATUS_FIELDS="$CASE_STATUS_FIELDS argc=00000003 argvsrc=00000002"
            ;;
        busybox-cat)
            CASE_SELECTOR=LINUX_M1_BUSYBOX_CAT_SMOKE
            CASE_FLAGS="-D $CASE_SELECTOR"
            CASE_PATH=/BIN/BUSYBOX.ELF
            CASE_ASSETS="/BIN/BUSYBOX.ELF /ETC/CATOK.TXT"
            CASE_SERIAL="busybox cat ok"
            CASE_EXIT=00000000
            CASE_STATUS_FIELDS="$CASE_STATUS_FIELDS argc=00000003 argvsrc=00000002"
            ;;
        busybox-cp)
            CASE_SELECTOR=LINUX_M1_BUSYBOX_CP_SMOKE
            CASE_FLAGS="-D $CASE_SELECTOR"
            CASE_PATH=/BIN/BUSYBOX.ELF
            CASE_ASSETS="/BIN/BUSYBOX.ELF /ETC/CATOK.TXT"
            CASE_EXIT=00000000
            CASE_STATUS_FIELDS="$CASE_STATUS_FIELDS argc=00000004 argvsrc=00000002"
            ;;
        busybox-grep)
            CASE_SELECTOR=LINUX_M1_BUSYBOX_GREP_SMOKE
            CASE_FLAGS="-D $CASE_SELECTOR"
            CASE_PATH=/BIN/BUSYBOX.ELF
            CASE_ASSETS="/BIN/BUSYBOX.ELF /ETC/CATOK.TXT"
            CASE_SERIAL="busybox cat ok"
            CASE_EXIT=00000000
            CASE_STATUS_FIELDS="$CASE_STATUS_FIELDS argc=00000004 argvsrc=00000002"
            ;;
        busybox-sleep)
            CASE_SELECTOR=LINUX_M1_BUSYBOX_SLEEP_SMOKE
            CASE_FLAGS="-D $CASE_SELECTOR"
            CASE_PATH=/BIN/BUSYBOX.ELF
            CASE_ASSETS=/BIN/BUSYBOX.ELF
            CASE_EXIT=00000000
            CASE_STATUS_FIELDS="$CASE_STATUS_FIELDS argc=00000003 argvsrc=00000002"
            ;;
        busybox-ps)
            CASE_SELECTOR=LINUX_M1_BUSYBOX_PS_SMOKE
            CASE_FLAGS="-D $CASE_SELECTOR"
            CASE_PATH=/BIN/BUSYBOX.ELF
            CASE_ASSETS=/BIN/BUSYBOX.ELF
            CASE_SERIAL="busybox ps"
            CASE_EXIT=00000000
            CASE_STATUS_FIELDS="$CASE_STATUS_FIELDS argc=00000002 argvsrc=00000002"
            ;;
        *)
            return 1
            ;;
    esac

    CASE_STATUS_FIELDS="$CASE_STATUS_FIELDS path=$CASE_PATH"
    return 0
}

selector_available() {
    selector=$1
    [ -z "$selector" ] && return 0
    grep -F -q "$selector" kernel/kernel.asm
}

print_list() {
    printf 'default: %s\n' "$DEFAULT_CASES"
    printf 'cases:\n'
    for c in $ALL_CASES; do
        case_config "$c" || continue
        if selector_available "$CASE_SELECTOR"; then
            state=available
        else
            state=missing-selector
        fi
        printf '  %-14s %s' "$c" "$state"
        if [ -n "$CASE_SELECTOR" ]; then
            printf ' selector=%s' "$CASE_SELECTOR"
        fi
        printf '\n'
    done
}

extract_assignment() {
    name=$1
    file=$2
    awk -v name="$name" '
        index($0, name "=\"") == 1 {
            value = substr($0, length(name) + 3)
            if (substr(value, length(value), 1) == "\"") {
                value = substr(value, 1, length(value) - 1)
            }
            print value
            found = 1
        }
        END { if (!found) exit 1 }
    ' "$file"
}

case_list_needs_busybox() {
    for case_name in $cases; do
        case_config "$case_name" || continue
        for asset in $CASE_ASSETS; do
            if [ "$asset" = "/BIN/BUSYBOX.ELF" ]; then
                return 0
            fi
        done
    done
    return 1
}

prepare_build_inputs() {
    log "building Linux smoke input binaries"
    "$MAKE_BIN" build/link_elf32
    "$MAKE_BIN" -C tests/linux
    if command -v "${ZIG:-zig}" >/dev/null 2>&1; then
        "$MAKE_BIN" -C tests/linux real-libc
    else
        echo "warning: zig not found; skipping generated musl/glibc Linux probes" >&2
    fi

    if case_list_needs_busybox; then
        if [ -d build/busybox-src/busybox-1.35.0 ] && [ "${VIBE_SKIP_BUSYBOX_BUILD:-0}" != "1" ]; then
            tools/build_busybox_vibe.sh
        fi
    fi
}

prepare_rootfs_vars() {
    mkdir -p "$OUT_DIR"
    prepare_build_inputs
    ROOTFS_DRY_RUN="$OUT_DIR/mkrootfs.dry-run.txt"
    log "collecting rootfs assets with tools/mkrootfs.sh --dry-run"
    VIBE_SKIP_BUSYBOX_BUILD=1 tools/mkrootfs.sh --dry-run > "$ROOTFS_DRY_RUN"
    IMAGE_EXTRA_ROOT_ELF_ARGS_VALUE=$(extract_assignment IMAGE_EXTRA_ROOT_ELF_ARGS "$ROOTFS_DRY_RUN")
    IMAGE_EXTRA_ROOT_ELF_DEPS_VALUE=$(extract_assignment IMAGE_EXTRA_ROOT_ELF_DEPS "$ROOTFS_DRY_RUN")
}

rootfs_has_asset() {
    asset=$1
    case " $IMAGE_EXTRA_ROOT_ELF_ARGS_VALUE " in
        *" --asset $asset="*) return 0 ;;
        *) return 1 ;;
    esac
}

field_value() {
    field=$1
    file=$2
    awk -v field="$field" '
        {
            prefix = field "="
            for (i = 1; i <= NF; i++) {
                if (index($i, prefix) == 1) {
                    print substr($i, length(prefix) + 1)
                    exit
                }
            }
        }
    ' "$file"
}

linuxm1_part() {
    part=$1
    file=$2
    value=$(field_value linuxm1 "$file")
    [ -n "$value" ] || return 1
    printf '%s\n' "$value" | awk -F/ -v part="$part" '{ print $part }'
}

file_contains() {
    file=$1
    needle=$2
    awk -v needle="$needle" 'index($0, needle) { found = 1 } END { exit(found ? 0 : 1) }' "$file"
}

assert_note() {
    printf '  assertion failed: %s\n' "$*" >&2
}

assert_field_equals() {
    status_file=$1
    field=$2
    expected=$3
    actual=$(field_value "$field" "$status_file")
    if [ "$actual" != "$expected" ]; then
        assert_note "$field expected $expected, got ${actual:-<missing>}"
        return 1
    fi
    return 0
}

assert_field_if_present() {
    status_file=$1
    field=$2
    expected=$3
    actual=$(field_value "$field" "$status_file")
    if [ -n "$actual" ] && [ "$actual" != "$expected" ]; then
        assert_note "$field expected $expected, got $actual"
        return 1
    fi
    return 0
}

assert_linuxm1_part() {
    status_file=$1
    part=$2
    expected=$3
    actual=$(linuxm1_part "$part" "$status_file" || true)
    if [ "$actual" != "$expected" ]; then
        assert_note "linuxm1 part $part expected $expected, got ${actual:-<missing>}"
        return 1
    fi
    return 0
}

assert_linux_last_unimpl_nr() {
    status_file=$1
    expected=$2
    actual=$(linuxm1_part 8 "$status_file" || true)
    if [ "$actual" != "$expected" ]; then
        assert_note "linux_last_unimpl_nr expected $expected, got ${actual:-<missing>}"
        return 1
    fi
    return 0
}

assert_case() {
    status_file=$1
    serial_file=$2
    failures=0

    if [ ! -s "$status_file" ]; then
        assert_note "missing status proof file $status_file"
        return 1
    fi

    for pair in $CASE_STATUS_FIELDS; do
        field=${pair%%=*}
        expected=${pair#*=}
        if ! assert_field_equals "$status_file" "$field" "$expected"; then
            failures=$((failures + 1))
        fi
    done

    for pair in "faultsrc=NONE" "panic=NONE" "shutdown=NONE" "pmmchk=OK"; do
        field=${pair%%=*}
        expected=${pair#*=}
        if ! assert_field_if_present "$status_file" "$field" "$expected"; then
            failures=$((failures + 1))
        fi
    done

    if ! assert_linuxm1_part "$status_file" 1 00000002; then failures=$((failures + 1)); fi
    if ! assert_linuxm1_part "$status_file" 2 00000001; then failures=$((failures + 1)); fi
    if ! assert_linuxm1_part "$status_file" 3 00000001; then failures=$((failures + 1)); fi
    if ! assert_linuxm1_part "$status_file" 4 00000000; then failures=$((failures + 1)); fi
    if ! assert_linuxm1_part "$status_file" 5 00000001; then failures=$((failures + 1)); fi
    if [ -n "$CASE_EXIT" ] && ! assert_linuxm1_part "$status_file" 6 "$CASE_EXIT"; then failures=$((failures + 1)); fi
    if ! assert_linuxm1_part "$status_file" 7 00000000; then failures=$((failures + 1)); fi
    if ! assert_linux_last_unimpl_nr "$status_file" "$CASE_LAST_UNIMPL_NR"; then failures=$((failures + 1)); fi

    if [ -n "$CASE_SERIAL" ]; then
        if [ ! -s "$serial_file" ]; then
            assert_note "missing serial proof file $serial_file"
            failures=$((failures + 1))
        elif ! file_contains "$serial_file" "$CASE_SERIAL"; then
            assert_note "serial log missing substring: $CASE_SERIAL"
            failures=$((failures + 1))
        fi
    fi

    [ "$failures" -eq 0 ]
}

assert_case_side_effects() {
    case_name=$1
    case "$CASE_NAME" in
        busybox-cp)
            inspect_file="$OUT_DIR/$case_name.inspect.txt"
            if ! build/make_wad_image --require-file CP.TXT --inspect build/disk.img > "$inspect_file" 2>&1; then
                assert_note "busybox-cp did not leave /CP.TXT in build/disk.img; see $inspect_file"
                return 1
            fi
            if ! awk '
                ($0 ~ /=CP[.]TXT / || $0 ~ /path=CP[.]TXT /) && index($0, "size=15") { found = 1 }
                END { exit(found ? 0 : 1) }
            ' "$inspect_file"; then
                assert_note "busybox-cp /CP.TXT proof missing size=15 in $inspect_file"
                return 1
            fi
            ;;
    esac
    return 0
}

copy_case_artifacts() {
    case_name=$1
    status_dst="$OUT_DIR/$case_name.status.txt"
    serial_dst="$OUT_DIR/$case_name.serial.log"
    rm -f "$status_dst" "$serial_dst"
    [ -f build/status.txt ] && cp build/status.txt "$status_dst"
    [ -f build/serial.log ] && cp build/serial.log "$serial_dst"
}

run_case() {
    case_name=$1
    case_config "$case_name" || die "unknown case: $case_name"

    if ! selector_available "$CASE_SELECTOR"; then
        echo "case $case_name requires missing selector $CASE_SELECTOR" >&2
        return 1
    fi

    for asset in $CASE_ASSETS; do
        if ! rootfs_has_asset "$asset"; then
            echo "case $case_name rootfs asset missing from mkrootfs dry-run: $asset" >&2
            return 1
        fi
    done

    flags="$BASE_NASMFLAGS"
    [ -n "$CASE_FLAGS" ] && flags="$flags $CASE_FLAGS"
    [ -n "$EXTRA_NASMFLAGS" ] && flags="$flags $EXTRA_NASMFLAGS"

    log "running $case_name ($flags)"
    rc=0
    "$MAKE_BIN" smoke \
        ALLOW_LOCAL_VM=1 \
        SMOKE_SKIP_ASSERTIONS=1 \
        SMOKE_CAPTURE_GFX=0 \
        SMOKE_INPUT_SCRIPT= \
        SMOKE_QEMU_TIMEOUT="$SMOKE_QEMU_TIMEOUT_VALUE" \
        KERNEL_EXTRA_NASMFLAGS="$flags" \
        IMAGE_EXTRA_ROOT_ELF_ARGS="$IMAGE_EXTRA_ROOT_ELF_ARGS_VALUE" \
        IMAGE_EXTRA_ROOT_ELF_DEPS="$IMAGE_EXTRA_ROOT_ELF_DEPS_VALUE" || rc=$?

    copy_case_artifacts "$case_name"
    status_file="$OUT_DIR/$case_name.status.txt"
    serial_file="$OUT_DIR/$case_name.serial.log"

    if [ "$rc" -ne 0 ]; then
        echo "case $case_name make smoke failed with status $rc" >&2
        return 1
    fi

    if ! assert_case "$status_file" "$serial_file"; then
        echo "case $case_name failed assertions" >&2
        return 1
    fi

    if ! assert_case_side_effects "$case_name"; then
        echo "case $case_name failed side-effect assertions" >&2
        return 1
    fi

    log "passed $case_name: $status_file $serial_file"
    return 0
}

cases=
while [ "$#" -gt 0 ]; do
    case "$1" in
        --list)
            print_list
            exit 0
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            break
            ;;
        -*)
            usage >&2
            exit 2
            ;;
        *)
            c=$(normalize_case "$1")
            case_config "$c" || die "unknown case: $1"
            cases="${cases:+$cases }$c"
            ;;
    esac
    shift
done

while [ "$#" -gt 0 ]; do
    c=$(normalize_case "$1")
    case_config "$c" || die "unknown case: $1"
    cases="${cases:+$cases }$c"
    shift
done

if [ -z "$cases" ]; then
    cases=$DEFAULT_CASES
fi

prepare_rootfs_vars

passed=0
failed=0
for c in $cases; do
    if run_case "$c"; then
        passed=$((passed + 1))
    else
        failed=$((failed + 1))
    fi
done

log "summary: passed=$passed failed=$failed output=$OUT_DIR"
[ "$failed" -eq 0 ]
