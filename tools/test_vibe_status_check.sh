#!/usr/bin/env sh
set -eu

ROOT="${ROOT:-$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)}"
BUILD_DIR="${BUILD_DIR:-$ROOT/build}"
HOST_CC="${HOST_CC:-cc}"
MAKE_CMD="${MAKE:-make}"
SCOPE="${VIBE_STATUS_CHECK_SCOPE:-all}"
CHECKER="$BUILD_DIR/vibe_status_check"
PI4_EVIDENCE="$BUILD_DIR/pi4_status_evidence"
PI4_QEMU_COMMAND="$BUILD_DIR/pi4_qemu_command"
PI4_HW_OK="$ROOT/tests/fixtures/pi4_status_hardware_evidence_ok.txt"
PI4_HW_BAD="$BUILD_DIR/pi4_status_hardware_evidence_bad.txt"
PI4_HW_AUDIO_QUEUE_BAD="$BUILD_DIR/pi4_status_hardware_evidence_audio_queue_bad.txt"
PI4_PREEMPT_WAIT_BAD="$BUILD_DIR/pi4_status_hardware_preempt_wait_bad.txt"
PI4_LOCAL_QEMU_BAD="$ROOT/tests/fixtures/pi4_status_bad_local_qemu_overclaim.txt"
PI4_LOCAL_QEMU_CLASS_BAD="$BUILD_DIR/pi4_status_local_qemu_smoke_marker_bad.txt"
PI4_LOCAL_QEMU_INPUT_CLASS_BAD="$BUILD_DIR/pi4_status_local_qemu_input_smoke_marker_bad.txt"
PI4_LOCAL_QEMU_FINAL_CLASS_BAD="$BUILD_DIR/pi4_status_local_qemu_final_marker_bad.txt"
PI4_AUDIO_HW_UNPROVEN="$BUILD_DIR/pi4_status_audio_hardware_unproven.txt"
PI4_FINAL_GATES_AUDIO_OK="$BUILD_DIR/pi4_final_gates_audio_hardware_unproven_ok.txt"
PI4_FINAL_GATES_AUDIO_BAD="$BUILD_DIR/pi4_final_gates_audio_hardware_unproven_bad.txt"
PI4_FINAL_GATES_AUDIO_IMPLICIT_BAD="$BUILD_DIR/pi4_final_gates_audio_implicit_hardware_bad.txt"
PI4_FINAL_GATES_PROCESS_BAD="$BUILD_DIR/pi4_final_gates_process_summary_bad.txt"
PI4_FINAL_GATES_MEMORY_BAD="$BUILD_DIR/pi4_final_gates_memory_summary_bad.txt"
PI4_FINAL_GATES_PREEMPT_BAD="$BUILD_DIR/pi4_final_gates_preempt_summary_bad.txt"
PI4_PROCESS_STATUS_BAD="$BUILD_DIR/pi4_status_process_summary_bad.txt"
PI4_MEMORY_STATUS_BAD="$BUILD_DIR/pi4_status_memory_summary_bad.txt"
PI4_FINAL_GATES_LOCAL_QEMU_BAD="$BUILD_DIR/pi4_final_gates_local_qemu_audio_bad.txt"
PI4_FINAL_GATES_LOCAL_QEMU_AUDIO_OK_BAD="$BUILD_DIR/pi4_final_gates_local_qemu_audio_ok_bad.txt"
PI4_LOCAL_QEMU_APP_GATES_OK="$BUILD_DIR/pi4_final_gates_local_qemu_app_ok.txt"
PI4_LOCAL_QEMU_APP_GATES_FB_BAD="$BUILD_DIR/pi4_final_gates_local_qemu_app_fb_bad.txt"
PI4_LOCAL_QEMU_APP_GATES_FB_UNCHANGED_BAD="$BUILD_DIR/pi4_final_gates_local_qemu_app_fb_unchanged_bad.txt"
PI4_LOCAL_QEMU_APP_DOOM_OK="$BUILD_DIR/pi4_status_local_qemu_doom_app_ok.txt"
PI4_LOCAL_QEMU_APP_QUAKE_OK="$BUILD_DIR/pi4_status_local_qemu_quake_app_ok.txt"
PI4_LOCAL_QEMU_APP_DOOM_ASSET_BAD="$BUILD_DIR/pi4_status_local_qemu_doom_app_asset_bad.txt"
PI4_LOCAL_QEMU_APP_QUAKE_ASSET_BAD="$BUILD_DIR/pi4_status_local_qemu_quake_app_asset_bad.txt"
PI4_LOCAL_QEMU_APP_CLICK_BAD="$BUILD_DIR/pi4_status_local_qemu_app_click_bad.txt"
PI4_LOCAL_QEMU_APP_FRAME_BAD="$BUILD_DIR/pi4_status_local_qemu_app_frame_bad.txt"
PI4_LOCAL_QEMU_APP_PANIC_BAD="$BUILD_DIR/pi4_status_local_qemu_app_panic_bad.txt"
PI4_LOCAL_QEMU_APP_SHUTDOWN_BAD="$BUILD_DIR/pi4_status_local_qemu_app_shutdown_bad.txt"
PI4_LOCAL_QEMU_DOOM_LAUNCH_ONLY_BAD="$ROOT/tests/fixtures/pi4_status_bad_local_qemu_doom_launch_only.txt"
PI4_LOCAL_QEMU_QUAKE_LAUNCH_ONLY_BAD="$ROOT/tests/fixtures/pi4_status_bad_local_qemu_quake_launch_only.txt"
PI4_FINAL_GATES_ASSETS_OK="$BUILD_DIR/pi4_final_gates_real_assets_ok.txt"
PI4_FINAL_GATES_SINGLE_ARTIFACT_OK="$BUILD_DIR/pi4_final_gates_single_artifact_ok.txt"
PI4_FINAL_GATES_SINGLE_ARTIFACT_BAD="$BUILD_DIR/pi4_final_gates_single_artifact_bad.txt"
PI4_SINGLE_ARTIFACT_GUARD_BUILD_DIR="$BUILD_DIR/pi4_single_artifact_guard"
PI4_STORAGE_OVERCLAIM_BAD="$ROOT/tests/fixtures/pi4_status_bad_storage_wait_overclaim.txt"
PI4_STORAGE_MISSING_WAD_BAD="$BUILD_DIR/pi4_status_storage_missing_wad_bad.txt"
PI4_STORAGE_PAK_CLAIM_BAD="$BUILD_DIR/pi4_status_storage_pak_claim_bad.txt"
PI4_STORAGE_WAD_PAK_OK="$BUILD_DIR/pi4_status_storage_wad_pak_ok.txt"
PI4_STORAGE_WAD_ZERO_BAD="$BUILD_DIR/pi4_status_storage_zero_wad_bad.txt"
PI4_STORAGE_PAK_ZERO_BAD="$BUILD_DIR/pi4_status_storage_zero_pak_bad.txt"
PI4_EXEC_APP_VFS_OK="$BUILD_DIR/pi4_status_exec_app_vfs_ok.txt"
PI4_EXEC_APP_VFS_MISMATCH_BAD="$BUILD_DIR/pi4_status_exec_app_vfs_mismatch_bad.txt"
PI4_EXEC_APP_VFS_MISSING_BAD="$BUILD_DIR/pi4_status_exec_app_vfs_missing_bad.txt"
PI4_INPUT_LIVE_OK="$BUILD_DIR/pi4_status_input_live_ok.txt"
PI4_INPUT_LIVE_SCRIPTED_BAD="$BUILD_DIR/pi4_status_input_live_scripted_bad.txt"
PI4_QEMU_EARLY_FAKE="$BUILD_DIR/pi4_qemu_fake_status_after_input.sh"
PI4_QEMU_EARLY_RAW="$BUILD_DIR/pi4_qemu_early_status_raw.txt"
PI4_QEMU_EARLY_MARKED="$BUILD_DIR/pi4_qemu_early_status_marked.txt"
PI4_QEMU_EARLY_SERIAL="$BUILD_DIR/pi4_qemu_early_status_serial.txt"
PI4_QEMU_EARLY_STDOUT="$BUILD_DIR/pi4_qemu_early_status_stdout.txt"
PI4_QEMU_LIVE_FAKE="$BUILD_DIR/pi4_qemu_live_fake.sh"
PI4_QEMU_LIVE_MARKER="$BUILD_DIR/pi4_qemu_live_marker.txt"
PI4_QEMU_LIVE_STDOUT="$BUILD_DIR/pi4_qemu_live_stdout.txt"
PI4_QEMU_HMP_FAKE_C="$BUILD_DIR/pi4_qemu_hmp_fake.c"
PI4_QEMU_HMP_FAKE="$BUILD_DIR/pi4_qemu_hmp_fake"
PI4_QEMU_HMP_RAW="$BUILD_DIR/pi4_qemu_hmp_status_raw.txt"
PI4_QEMU_HMP_MARKED="$BUILD_DIR/pi4_qemu_hmp_status_marked.txt"
PI4_QEMU_HMP_SERIAL="$BUILD_DIR/pi4_qemu_hmp_status_serial.txt"
PI4_QEMU_HMP_STDOUT="$BUILD_DIR/pi4_qemu_hmp_stdout.txt"
PI4_QEMU_HMP_MONITOR_LOG="$BUILD_DIR/pi4_qemu_hmp_monitor.log"
PI4_QEMU_HMP_FB_FRAME0="$BUILD_DIR/pi4_qemu_hmp_frame0.ppm"
PI4_QEMU_HMP_FB_FRAME1="$BUILD_DIR/pi4_qemu_hmp_frame1.ppm"
PI4_QEMU_HMP_FB_REPORT="$BUILD_DIR/pi4_qemu_hmp_framebuffer_report.txt"
PI4_FB_FRAME0="$BUILD_DIR/pi4_framebuffer_frame0.ppm"
PI4_FB_FRAME1="$BUILD_DIR/pi4_framebuffer_frame1.ppm"
PI4_FB_REPORT="$BUILD_DIR/pi4_framebuffer_report.txt"
PI4_FB_BAD_REPORT="$BUILD_DIR/pi4_framebuffer_report_bad.txt"
PI4_SERIAL_LAST_OK="$BUILD_DIR/pi4_status_serial_last_ok.txt"
PI4_SERIAL_LAST_BAD="$BUILD_DIR/pi4_status_serial_last_bad.txt"
X86_IMAGE_BUILDER_DRYRUN="$BUILD_DIR/x86_image_builder_dryrun.txt"
X86_UEFI_IMAGE_BUILDER_DRYRUN="$BUILD_DIR/x86_uefi_image_builder_dryrun.txt"
X86_DOOM_BAD="$BUILD_DIR/vm_status_x86_doom_bad.txt"
X86_QUAKE_OK="$BUILD_DIR/vm_status_x86_quake_ok.txt"
X86_QUAKE_BAD="$BUILD_DIR/vm_status_x86_quake_bad.txt"
X86_QUAKE_KIND_BAD="$BUILD_DIR/vm_status_x86_quake_kind_bad.txt"
PI4_CLAIM_OK="$BUILD_DIR/pi4_status_launcher_claim_none.txt"
PI4_CLAIM_BAD="$BUILD_DIR/pi4_status_launcher_claim_bad.txt"
PI4_SINGLE_ARTIFACT_SHA="0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
PI4_SINGLE_ARTIFACT_OTHER_SHA="fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210"

case "$SCOPE" in
  all|x86) ;;
  *)
    echo "unsupported VIBE_STATUS_CHECK_SCOPE=$SCOPE" >&2
    exit 2
    ;;
esac

mkdir -p "$BUILD_DIR"
"$HOST_CC" -std=c99 -Wall -Wextra -Werror -O2 \
  "$ROOT/tools/vibe_status_check.c" -o "$CHECKER"
if [ "$SCOPE" = "all" ]; then
"$HOST_CC" -std=c99 -Wall -Wextra -Werror -O2 \
  "$ROOT/tools/pi4_status_evidence.c" -o "$PI4_EVIDENCE"
"$HOST_CC" -std=c99 -Wall -Wextra -Werror -O2 \
  "$ROOT/tools/pi4_qemu_command.c" -o "$PI4_QEMU_COMMAND"

printf 'P6\n2 1\n255\n\000\000\000\377\000\000' > "$PI4_FB_FRAME0"
printf 'P6\n2 1\n255\n\000\000\000\000\377\000' > "$PI4_FB_FRAME1"
printf 'fake-kernel8\n' > "$BUILD_DIR/fake-kernel8.img"
printf 'fake-pi4-fat16\n' > "$BUILD_DIR/fake-pi4-fat16.img"
"$PI4_QEMU_COMMAND" --framebuffer-artifact-check \
  "$PI4_FB_REPORT" "$PI4_FB_FRAME0" "$PI4_FB_FRAME1"
grep -F -q "schema=pi4-framebuffer-artifact-v1" "$PI4_FB_REPORT"
grep -F -q "framebuffer_artifact=OK" "$PI4_FB_REPORT"
grep -F -q "frame0_nonblank=true" "$PI4_FB_REPORT"
grep -F -q "frame1_nonblank=true" "$PI4_FB_REPORT"
grep -F -q "frames_changed=true" "$PI4_FB_REPORT"
if "$PI4_QEMU_COMMAND" --framebuffer-artifact-check \
  "$PI4_FB_BAD_REPORT" "$PI4_FB_FRAME0" "$PI4_FB_FRAME0" >/tmp/pi4-framebuffer-artifact-bad.out 2>&1; then
  echo "pi4_qemu_command accepted unchanged framebuffer screendumps" >&2
  cat /tmp/pi4-framebuffer-artifact-bad.out >&2
  exit 1
fi

cat > "$PI4_QEMU_EARLY_FAKE" <<'EOF_QEMU_EARLY_FAKE'
#!/usr/bin/env sh
set -eu

serial=""
while [ "$#" -gt 0 ]; do
  arg="$1"
  shift
  case "$arg" in
    -serial)
      test "$#" -gt 0 || { echo "fake qemu missing -serial value" >&2; exit 2; }
      serial="$1"
      shift
      ;;
  esac
done

case "$serial" in
  stdio)
    pipe_base=""
    ;;
  pipe:*) pipe_base="${serial#pipe:}" ;;
  *) echo "fake qemu missing pipe serial" >&2; exit 2 ;;
esac

if [ "$serial" = "stdio" ]; then
  exec 3>&1
  exec 4<&0
else
  exec 3>"$pipe_base.out"
  exec 4<"$pipe_base.in"
fi
printf '%s\n' 'vibe-status arch=AARCH64 machine=PI4 image=PI4 artifact=BAD stale=before-input' >&3
scripted_input="$(dd bs=1 count=2 <&4 2>/dev/null || true)"
printf 'vibe-status arch=AARCH64 machine=PI4 image=PI4 artifact=OK post_input=OK scripted_input=%s path=/APPS/DOOM/APP.ELF pi4exec=OK pi4inputevt=0x1/0x0/0x0/0x1/0x0 pi4appvfs=0xE/0x464f4f4b pi4userfile=0x0000000000000007/0x4/0x0/0x1/0x3/0x4006b4/0x0/0x10/0x10/0x0000000044415749/0x1/0x1/0x1 fbchange=0x1/0x2/0x1/0x1 pi4runtime=OK panic=NONE shutdown=NONE\n' "$scripted_input" >&3
sleep 20
EOF_QEMU_EARLY_FAKE
chmod +x "$PI4_QEMU_EARLY_FAKE"
rm -f "$PI4_QEMU_EARLY_RAW" "$PI4_QEMU_EARLY_MARKED" \
  "$PI4_QEMU_EARLY_SERIAL" "$PI4_QEMU_EARLY_STDOUT"
qemu_early_start="$(date +%s)"
ALLOW_LOCAL_VM=1 "$PI4_QEMU_COMMAND" --local-input-smoke 6 "1w" \
  "$PI4_QEMU_EARLY_RAW" "$PI4_QEMU_EARLY_MARKED" \
  "$PI4_QEMU_EARLY_SERIAL" "$PI4_QEMU_EARLY_FAKE" \
  "$BUILD_DIR/fake-kernel8.img" "$BUILD_DIR/fake-pi4-fat16.img" \
  > "$PI4_QEMU_EARLY_STDOUT"
qemu_early_elapsed="$(( $(date +%s) - qemu_early_start ))"
if [ "$qemu_early_elapsed" -ge 5 ]; then
  echo "pi4_qemu_command waited for the fixed timeout after post-input vibe-status" >&2
  cat "$PI4_QEMU_EARLY_STDOUT" >&2
  exit 1
fi
grep -F -q "post_input=OK" "$PI4_QEMU_EARLY_RAW"
grep -F -q "scripted_input=1w" "$PI4_QEMU_EARLY_RAW"
if grep -F -q "stale=before-input" "$PI4_QEMU_EARLY_RAW"; then
  echo "pi4_qemu_command selected a stale pre-input vibe-status line" >&2
  cat "$PI4_QEMU_EARLY_RAW" >&2
  exit 1
fi
grep -F -q "stale=before-input" "$PI4_QEMU_EARLY_SERIAL"
grep -F -q "post_input=OK" "$PI4_QEMU_EARLY_SERIAL"
grep -F -q "evidence_class=local-qemu-input-smoke" "$PI4_QEMU_EARLY_MARKED"
grep -F -q "smoke_gate=pi4-local-qemu-input-smoke" "$PI4_QEMU_EARLY_MARKED"
grep -F -q "hardware_proof=unclaimed" "$PI4_QEMU_EARLY_MARKED"

cat > "$PI4_QEMU_HMP_FAKE_C" <<'EOF_QEMU_HMP_FAKE_C'
#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/un.h>
#include <unistd.h>

static void die(const char* message)
{
    perror(message);
    exit(2);
}

static void copy_checked(char* out, size_t out_size, const char* text)
{
    size_t len = strlen(text);

    if (len >= out_size) {
        fprintf(stderr, "fake qemu value too long: %s\n", text);
        exit(2);
    }
    memcpy(out, text, len + 1u);
}

static int serial_pipe_paths(const char* arg, char* out_path, size_t out_size)
{
    if (strcmp(arg, "stdio") == 0)
        return 1;
    if (strncmp(arg, "pipe:", 5) != 0 || !arg[5]) {
        fprintf(stderr, "fake qemu missing pipe serial\n");
        exit(2);
    }
    if (snprintf(out_path, out_size, "%s.out", arg + 5) >= (int)out_size) {
        fprintf(stderr, "fake qemu serial path too long\n");
        exit(2);
    }
    return 0;
}

static void monitor_socket_path(const char* arg, char* out, size_t out_size)
{
    const char* start;
    const char* end;
    size_t len;

    if (strncmp(arg, "unix:", 5) != 0) {
        fprintf(stderr, "fake qemu missing unix monitor\n");
        exit(2);
    }
    start = arg + 5;
    end = strchr(start, ',');
    if (!end)
        end = start + strlen(start);
    len = (size_t)(end - start);
    if (len == 0u || len >= out_size) {
        fprintf(stderr, "fake qemu monitor path invalid\n");
        exit(2);
    }
    memcpy(out, start, len);
    out[len] = '\0';
}

static void write_all_fd(int fd, const char* data)
{
    size_t len = strlen(data);
    size_t sent = 0;

    while (sent < len) {
        ssize_t wrote = write(fd, data + sent, len - sent);

        if (wrote > 0) {
            sent += (size_t)wrote;
            continue;
        }
        if (wrote < 0 && errno == EINTR)
            continue;
        die("write");
    }
}

static void write_frame(const char* path, int index)
{
    static const unsigned char frame0[] = {
        'P', '6', '\n', '2', ' ', '1', '\n', '2', '5', '5', '\n',
        0, 0, 0, 255, 0, 0
    };
    static const unsigned char frame1[] = {
        'P', '6', '\n', '2', ' ', '1', '\n', '2', '5', '5', '\n',
        0, 0, 0, 0, 255, 0
    };
    const unsigned char* data = index == 0 ? frame0 : frame1;
    size_t len = index == 0 ? sizeof(frame0) : sizeof(frame1);
    FILE* out = fopen(path, "wb");

    if (!out)
        die("fopen frame");
    if (fwrite(data, 1u, len, out) != len) {
        fprintf(stderr, "fake qemu frame write failed\n");
        exit(2);
    }
    if (fclose(out) != 0)
        die("fclose frame");
}

static int read_monitor_line(int fd, char* line, size_t line_size)
{
    size_t used = 0;

    while (used + 1u < line_size) {
        char c;
        ssize_t got = read(fd, &c, 1u);

        if (got > 0) {
            line[used++] = c;
            if (c == '\n')
                break;
            continue;
        }
        if (got == 0)
            break;
        if (errno == EINTR)
            continue;
        die("read monitor");
    }
    line[used] = '\0';
    return used != 0u;
}

int main(int argc, char** argv)
{
    char serial_arg[512] = "";
    char monitor_arg[512] = "";
    char serial_out_path[512];
    char monitor_path[512];
    const char* log_path = getenv("PI4_QEMU_HMP_MONITOR_LOG");
    FILE* log;
    int listen_fd;
    int monitor_fd;
    int serial_fd;
    int serial_stdio;
    int frame_count = 0;
    int input_count = 0;
    int saw_key_1 = 0;
    int saw_key_w = 0;
    int saw_mouse_move = 0;
    int saw_mouse_down = 0;
    int saw_mouse_up = 0;
    int wrote_status = 0;
    int i;
    struct sockaddr_un addr;

    for (i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-serial") == 0 && i + 1 < argc)
            copy_checked(serial_arg, sizeof(serial_arg), argv[++i]);
        else if (strcmp(argv[i], "-monitor") == 0 && i + 1 < argc)
            copy_checked(monitor_arg, sizeof(monitor_arg), argv[++i]);
        else if ((strcmp(argv[i], "-M") == 0 || strcmp(argv[i], "-cpu") == 0 ||
                  strcmp(argv[i], "-m") == 0 || strcmp(argv[i], "-kernel") == 0 ||
                  strcmp(argv[i], "-drive") == 0 || strcmp(argv[i], "-display") == 0 ||
                  strcmp(argv[i], "-device") == 0) && i + 1 < argc)
            i++;
    }
    if (!serial_arg[0] || !monitor_arg[0] || !log_path) {
        fprintf(stderr, "fake qemu missing serial, monitor, or log path\n");
        return 2;
    }
    serial_stdio = serial_pipe_paths(serial_arg, serial_out_path, sizeof(serial_out_path));
    monitor_socket_path(monitor_arg, monitor_path, sizeof(monitor_path));

    log = fopen(log_path, "wb");
    if (!log)
        die("fopen log");

    listen_fd = socket(AF_UNIX, SOCK_STREAM, 0);
    if (listen_fd < 0)
        die("socket");
    memset(&addr, 0, sizeof(addr));
    addr.sun_family = AF_UNIX;
    if (strlen(monitor_path) >= sizeof(addr.sun_path)) {
        fprintf(stderr, "fake qemu monitor path too long\n");
        return 2;
    }
    strcpy(addr.sun_path, monitor_path);
    unlink(monitor_path);
    if (bind(listen_fd, (struct sockaddr*)&addr, sizeof(addr)) != 0)
        die("bind");
    if (listen(listen_fd, 1) != 0)
        die("listen");

    serial_fd = serial_stdio ? dup(STDOUT_FILENO) : open(serial_out_path, O_WRONLY);
    if (serial_fd < 0)
        die("open serial out");
    write_all_fd(serial_fd,
        "vibe-status arch=AARCH64 machine=PI4 image=PI4 artifact=BAD stale=before-hmp\n");
    write_all_fd(serial_fd,
        "vibe-status arch=AARCH64 machine=PI4 image=PI4 artifact=OK exec=OK path=/SYSTEM/INIT.ELF uexec=OK upath=/SYSTEM/INIT.ELF pi4fb=OK pi4vfs=OK pi4runtime=OK panic=NONE shutdown=NONE\n");

    monitor_fd = accept(listen_fd, NULL, NULL);
    if (monitor_fd < 0)
        die("accept");

    for (;;) {
        char line[1024];

        if (!read_monitor_line(monitor_fd, line, sizeof(line)))
            break;
        fputs(line, log);
        fflush(log);
        if (strncmp(line, "screendump ", 11) == 0) {
            char* path = line + 11;
            char* nl = strchr(path, '\n');

            if (nl)
                *nl = '\0';
            fprintf(log, "frame%d_input_count=%d\n", frame_count, input_count);
            fflush(log);
            write_frame(path, frame_count);
            frame_count++;
            if (frame_count >= 2 && wrote_status)
                sleep(20);
        } else if (strncmp(line, "sendkey 1 ", 10) == 0) {
            input_count++;
            saw_key_1 = 1;
        } else if (strncmp(line, "sendkey w ", 10) == 0) {
            input_count++;
            saw_key_w = 1;
        } else if (strcmp(line, "mouse_move 12 -5\n") == 0) {
            input_count++;
            saw_mouse_move = 1;
        } else if (strcmp(line, "mouse_button 1\n") == 0) {
            input_count++;
            saw_mouse_down = 1;
        } else if (strcmp(line, "mouse_button 0\n") == 0) {
            input_count++;
            saw_mouse_up = 1;
        }
        if (!wrote_status && saw_key_1 && saw_key_w && saw_mouse_move &&
            saw_mouse_down && saw_mouse_up) {
            write_all_fd(serial_fd,
                "vibe-status arch=AARCH64 machine=PI4 image=PI4 artifact=OK hmp_input=OK path=/APPS/DOOM/APP.ELF upath=/APPS/DOOM/APP.ELF pi4exec=OK pi4inputevt=0x1/0x0/0x1/0x1/0x0 pi4appvfs=0xE/0x464f4f4b pi4userfile=0x0000000000000007/0x4/0x0/0x1/0x3/0x4006b4/0x0/0x10/0x10/0x0000000044415749/0x1/0x1/0x1 fbchange=0x1/0x2/0x1/0x1 pi4runtime=OK panic=NONE shutdown=NONE\n");
            wrote_status = 1;
        }
    }
    close(monitor_fd);
    close(listen_fd);
    close(serial_fd);
    fclose(log);
    return 0;
}
EOF_QEMU_HMP_FAKE_C
"$HOST_CC" -std=c99 -Wall -Wextra -Werror -O2 \
  "$PI4_QEMU_HMP_FAKE_C" -o "$PI4_QEMU_HMP_FAKE"
rm -f "$PI4_QEMU_HMP_RAW" "$PI4_QEMU_HMP_MARKED" \
  "$PI4_QEMU_HMP_SERIAL" "$PI4_QEMU_HMP_STDOUT" \
  "$PI4_QEMU_HMP_MONITOR_LOG" "$PI4_QEMU_HMP_FB_FRAME0" \
  "$PI4_QEMU_HMP_FB_FRAME1" "$PI4_QEMU_HMP_FB_REPORT"
PI4_QEMU_HMP_MONITOR_LOG="$PI4_QEMU_HMP_MONITOR_LOG" \
  ALLOW_LOCAL_VM=1 "$PI4_QEMU_COMMAND" --local-input-framebuffer-smoke 8 \
  "text=1w,mouse=12:-5,mousebtn=1,mousebtn=0" \
  "$PI4_QEMU_HMP_RAW" "$PI4_QEMU_HMP_MARKED" \
  "$PI4_QEMU_HMP_SERIAL" "$PI4_QEMU_HMP_FB_REPORT" \
  "$PI4_QEMU_HMP_FB_FRAME0" "$PI4_QEMU_HMP_FB_FRAME1" \
  "$PI4_QEMU_HMP_FAKE" "$BUILD_DIR/fake-kernel8.img" \
  "$BUILD_DIR/fake-pi4-fat16.img" > "$PI4_QEMU_HMP_STDOUT"
grep -F -q "hmp_input=OK" "$PI4_QEMU_HMP_RAW"
grep -F -q "stale=before-hmp" "$PI4_QEMU_HMP_SERIAL"
if grep -F -q "stale=before-hmp" "$PI4_QEMU_HMP_RAW"; then
  echo "pi4_qemu_command selected a stale pre-HMP vibe-status line" >&2
  cat "$PI4_QEMU_HMP_RAW" >&2
  exit 1
fi
grep -F -q "frame0_input_count=0" "$PI4_QEMU_HMP_MONITOR_LOG"
grep -F -q "sendkey 1 750" "$PI4_QEMU_HMP_MONITOR_LOG"
grep -F -q "sendkey w 750" "$PI4_QEMU_HMP_MONITOR_LOG"
grep -F -q "mouse_move 12 -5" "$PI4_QEMU_HMP_MONITOR_LOG"
grep -F -q "mouse_button 1" "$PI4_QEMU_HMP_MONITOR_LOG"
grep -F -q "mouse_button 0" "$PI4_QEMU_HMP_MONITOR_LOG"
grep -F -q "framebuffer_artifact=OK" "$PI4_QEMU_HMP_FB_REPORT"
grep -F -q "frame0_nonblank=true" "$PI4_QEMU_HMP_FB_REPORT"
grep -F -q "frame1_nonblank=true" "$PI4_QEMU_HMP_FB_REPORT"
grep -F -q "frames_changed=true" "$PI4_QEMU_HMP_FB_REPORT"
grep -F -q -- "-monitor unix:" "$PI4_QEMU_HMP_STDOUT"
grep -F -q -- "-device usb-kbd" "$PI4_QEMU_HMP_STDOUT"
grep -F -q -- "-device usb-mouse" "$PI4_QEMU_HMP_STDOUT"

cat > "$PI4_QEMU_LIVE_FAKE" <<'EOF_QEMU_LIVE_FAKE'
#!/usr/bin/env sh
set -eu

: "${PI4_QEMU_LIVE_MARKER:?}"
machine=""
cpu=""
memory=""
kernel=""
drive=""
serial=""
monitor=""
display=""
while [ "$#" -gt 0 ]; do
  arg="$1"
  shift
  case "$arg" in
    -M)
      machine="$1"
      shift
      ;;
    -cpu)
      cpu="$1"
      shift
      ;;
    -m)
      memory="$1"
      shift
      ;;
    -kernel)
      kernel="$1"
      shift
      ;;
    -drive)
      drive="$1"
      shift
      ;;
    -serial)
      serial="$1"
      shift
      ;;
    -monitor)
      monitor="$1"
      shift
      ;;
    -display)
      display="$1"
      shift
      ;;
    -no-reboot|-no-shutdown)
      ;;
  esac
done

[ "$machine" = "raspi4b,usb=on" ] || { echo "live qemu missing raspi4b USB machine" >&2; exit 2; }
[ "$cpu" = "cortex-a72" ] || { echo "live qemu missing cortex-a72 cpu" >&2; exit 2; }
[ "$memory" = "2G" ] || { echo "live qemu missing 2G memory" >&2; exit 2; }
[ -n "$kernel" ] || { echo "live qemu missing kernel8 image" >&2; exit 2; }
case "$drive" in
  file=*,if=sd,format=raw)
    ;;
  *)
    echo "live qemu missing raw SD image drive" >&2
    exit 2
    ;;
esac
[ "$serial" = "stdio" ] || { echo "live qemu serial is not stdio" >&2; exit 2; }
[ "$monitor" = "none" ] || { echo "live qemu monitor is not disabled" >&2; exit 2; }
case "$display" in
  none)
    echo "live qemu hid the framebuffer with -display none" >&2
    exit 2
    ;;
  *full-screen*|*vnc*|"")
    ;;
  *)
    echo "live qemu display is not a visible fullscreen/vnc handoff: $display" >&2
    exit 2
    ;;
esac
: > "$PI4_QEMU_LIVE_MARKER"
sleep 20
EOF_QEMU_LIVE_FAKE
chmod +x "$PI4_QEMU_LIVE_FAKE"
rm -f "$PI4_QEMU_LIVE_MARKER" "$PI4_QEMU_LIVE_STDOUT"
PI4_QEMU_LIVE_MARKER="$PI4_QEMU_LIVE_MARKER" \
  ALLOW_LOCAL_VM=1 "$PI4_QEMU_COMMAND" --live-smoke 1 \
  "$PI4_QEMU_LIVE_FAKE" stdio \
  "$BUILD_DIR/fake-kernel8.img" "$BUILD_DIR/fake-pi4-fat16.img" \
  > "$PI4_QEMU_LIVE_STDOUT"
test -e "$PI4_QEMU_LIVE_MARKER"
grep -F -q -- "-serial stdio" "$PI4_QEMU_LIVE_STDOUT"
grep -F -q -- "-monitor none" "$PI4_QEMU_LIVE_STDOUT"
if grep -F -q -- "-display none" "$PI4_QEMU_LIVE_STDOUT"; then
  echo "pi4_qemu_command live mode hid the framebuffer with -display none" >&2
  cat "$PI4_QEMU_LIVE_STDOUT" >&2
  exit 1
fi
if grep -F -q -- "-display" "$PI4_QEMU_LIVE_STDOUT" && \
  ! grep -E -q -- "-display [^[:space:]]*(full-screen|vnc)" "$PI4_QEMU_LIVE_STDOUT"; then
  echo "pi4_qemu_command live mode did not expose a fullscreen/vnc framebuffer" >&2
  cat "$PI4_QEMU_LIVE_STDOUT" >&2
  exit 1
fi

GUARD_TMP="$BUILD_DIR/source_guard_selftest"
rm -rf "$GUARD_TMP"
mkdir -p "$GUARD_TMP/boot/pi4" "$GUARD_TMP/doom_port" "$GUARD_TMP/quake_port" \
  "$GUARD_TMP/user" "$GUARD_TMP/build/generated"
trap 'rm -rf "$GUARD_TMP"' EXIT HUP INT TERM
touch \
  "$GUARD_TMP/boot/pi4/start.S" \
  "$GUARD_TMP/boot/pi4/input.S" \
  "$GUARD_TMP/boot/pi4/storage.S" \
  "$GUARD_TMP/doom_port/pi4_engine_start.S" \
  "$GUARD_TMP/doom_port/pi4_start.S" \
  "$GUARD_TMP/quake_port/pi4_app.S" \
  "$GUARD_TMP/user/pi4_crt0.S" \
  "$GUARD_TMP/user/pi4_runtime.S" \
  "$GUARD_TMP/user/pi4_abi_probe.S" \
  "$GUARD_TMP/user/pi4_launcher.S" \
  "$GUARD_TMP/user/pi4_launcher_assets.S" \
  "$GUARD_TMP/boot/pi4/unwired.S" \
  "$GUARD_TMP/build/generated/probe.py"
if "$MAKE_CMD" -C "$GUARD_TMP" -f "$ROOT/Makefile" --no-print-directory no-python-check >/tmp/vibe-no-python-guard-bad.out 2>&1; then
  echo "no-python-check accepted generated Python outside third_party" >&2
  cat /tmp/vibe-no-python-guard-bad.out >&2
  exit 1
fi
rm -f "$GUARD_TMP/build/generated/probe.py"
if "$MAKE_CMD" -C "$GUARD_TMP" -f "$ROOT/Makefile" --no-print-directory pi4-assembly-source-gate >/tmp/vibe-pi4-asm-guard-bad.out 2>&1; then
  echo "pi4-assembly-source-gate accepted unwired Pi assembly source" >&2
  cat /tmp/vibe-pi4-asm-guard-bad.out >&2
  exit 1
fi
rm -f "$GUARD_TMP/boot/pi4/unwired.S"
"$MAKE_CMD" -C "$GUARD_TMP" -f "$ROOT/Makefile" --no-print-directory no-python-check pi4-assembly-source-gate
rm -rf "$GUARD_TMP"
trap - EXIT HUP INT TERM
fi

"$MAKE_CMD" -C "$ROOT" --no-print-directory x86-pi4-real-assets-isolation-check

"$MAKE_CMD" -C "$ROOT" --no-print-directory -B -n ALLOW_LOCAL_VM=0 DOOM_WAD= image-builder-inspect > "$X86_IMAGE_BUILDER_DRYRUN"
for root_elf in INIT.ELF ABIPROBE.ELF
do
  if ! grep -F -q -- "--root-elf $root_elf=" "$X86_IMAGE_BUILDER_DRYRUN"; then
    echo "x86 image-builder dry run lost root ELF wiring for $root_elf" >&2
    exit 1
  fi
  if ! grep -F -q -- "--require-file $root_elf" "$X86_IMAGE_BUILDER_DRYRUN"; then
    echo "x86 image-builder inspect dry run stopped requiring built FAT file $root_elf" >&2
    exit 1
  fi
done
for app_file in /SYSTEM/INIT.ELF /SYSTEM/ABIPROBE.ELF /APPS/INDEX.TXT /APPS/DOOM/APP.TXT /APPS/DOOM/APP.ELF /APPS/QUAKE/APP.TXT /APPS/QUAKE/APP.ELF
do
  if ! grep -F -q -- "--asset $app_file=" "$X86_IMAGE_BUILDER_DRYRUN"; then
    echo "x86 image-builder dry run lost app install wiring for $app_file" >&2
    exit 1
  fi
  if ! grep -F -q -- "--require-file $app_file" "$X86_IMAGE_BUILDER_DRYRUN"; then
    echo "x86 image-builder inspect dry run stopped requiring app FAT file $app_file" >&2
    exit 1
  fi
done
grep -F -q -- "make_wad_image" "$X86_IMAGE_BUILDER_DRYRUN"
grep -F -q -- "disk.img" "$X86_IMAGE_BUILDER_DRYRUN"
for pi4_marker in build/pi4 KERNEL8.IMG CONFIG.TXT pi4-fat16.img
do
  if grep -F -q -- "$pi4_marker" "$X86_IMAGE_BUILDER_DRYRUN"; then
    echo "x86 BIOS image-builder dry run leaked Pi 4 image wiring: $pi4_marker" >&2
    exit 1
  fi
done

"$MAKE_CMD" -C "$ROOT" --no-print-directory -B -n ALLOW_LOCAL_VM=0 DOOM_WAD= uefi-dual-image > "$X86_UEFI_IMAGE_BUILDER_DRYRUN"
for uefi_asset in EFI/BOOT/BOOTX64.EFI VIBEOS/KERNEL.ELF
do
  if ! grep -F -q -- "--asset $uefi_asset=" "$X86_UEFI_IMAGE_BUILDER_DRYRUN"; then
    echo "x86 UEFI image-builder dry run lost asset wiring for $uefi_asset" >&2
    exit 1
  fi
done
for root_elf in INIT.ELF ABIPROBE.ELF
do
  if ! grep -F -q -- "--root-elf $root_elf=" "$X86_UEFI_IMAGE_BUILDER_DRYRUN"; then
    echo "x86 UEFI image-builder dry run lost root ELF wiring for $root_elf" >&2
    exit 1
  fi
done
for app_file in /SYSTEM/INIT.ELF /SYSTEM/ABIPROBE.ELF /APPS/INDEX.TXT /APPS/DOOM/APP.TXT /APPS/DOOM/APP.ELF /APPS/QUAKE/APP.TXT /APPS/QUAKE/APP.ELF
do
  if ! grep -F -q -- "--asset $app_file=" "$X86_UEFI_IMAGE_BUILDER_DRYRUN"; then
    echo "x86 UEFI image-builder dry run lost app install wiring for $app_file" >&2
    exit 1
  fi
done
for pi4_marker in build/pi4 KERNEL8.IMG CONFIG.TXT pi4-fat16.img
do
  if grep -F -q -- "$pi4_marker" "$X86_UEFI_IMAGE_BUILDER_DRYRUN"; then
    echo "x86 UEFI image-builder dry run leaked Pi 4 image wiring: $pi4_marker" >&2
    exit 1
  fi
done

"$CHECKER" --repo-contract
"$CHECKER" --require-exec --require-preempt --require-vfs-abi --require-device-abi \
  "$ROOT/tests/fixtures/vm_status_krelhaz_ok.txt"
sed 's|doom=OK|quake=OK|' \
  "$ROOT/tests/fixtures/vm_status_krelhaz_ok.txt" > "$X86_DOOM_BAD"
if "$CHECKER" --require-exec --require-preempt "$X86_DOOM_BAD" >/tmp/vibe-status-check-x86-doom-bad.out 2>&1; then
  echo "vibe_status_check accepted Doom app status without doom=OK" >&2
  cat /tmp/vibe-status-check-x86-doom-bad.out >&2
  exit 1
fi
sed 's|path=/APPS/DOOM/APP\.ELF|path=/APPS/QUAKE/APP.ELF|; s|doom=OK|quake=OK|; s|pkind=00000002:00000003|pkind=00000005:00000003|' \
  "$ROOT/tests/fixtures/vm_status_krelhaz_ok.txt" > "$X86_QUAKE_OK"
"$CHECKER" --require-exec --require-preempt "$X86_QUAKE_OK"
sed 's|path=/APPS/DOOM/APP\.ELF|path=/APPS/QUAKE/APP.ELF|; s|doom=OK|quake=OK|' \
  "$ROOT/tests/fixtures/vm_status_krelhaz_ok.txt" > "$X86_QUAKE_KIND_BAD"
if "$CHECKER" --require-exec --require-preempt "$X86_QUAKE_KIND_BAD" >/tmp/vibe-status-check-x86-quake-kind-bad.out 2>&1; then
  echo "vibe_status_check accepted Quake app status with the Doom app process kind" >&2
  cat /tmp/vibe-status-check-x86-quake-kind-bad.out >&2
  exit 1
fi
sed 's|path=/APPS/DOOM/APP\.ELF|path=/APPS/QUAKE/APP.ELF|' \
  "$ROOT/tests/fixtures/vm_status_krelhaz_ok.txt" > "$X86_QUAKE_BAD"
if "$CHECKER" --require-exec --require-preempt "$X86_QUAKE_BAD" >/tmp/vibe-status-check-x86-quake-bad.out 2>&1; then
  echo "vibe_status_check accepted Quake app status without quake=OK" >&2
  cat /tmp/vibe-status-check-x86-quake-bad.out >&2
  exit 1
fi
if [ "$SCOPE" = "all" ]; then
"$CHECKER" "$ROOT/tests/fixtures/pi4_status_giccfg_ok.txt"
"$CHECKER" "$ROOT/tests/fixtures/pi4_status_timer_irq_ok.txt"
"$CHECKER" "$ROOT/tests/fixtures/pi4_status_fb_ok.txt"
"$CHECKER" "$ROOT/tests/fixtures/pi4_status_uabi_ok.txt"
"$CHECKER" "$ROOT/tests/fixtures/pi4_status_process_ok.txt"
"$CHECKER" "$PI4_HW_OK"
"$PI4_EVIDENCE" "$PI4_HW_OK"
"$MAKE_CMD" -C "$ROOT" --no-print-directory pi4-launcher-state-manifest-check
cp "$PI4_HW_OK" "$PI4_CLAIM_OK"
if ! grep -q 'app_launch_claim=' "$PI4_CLAIM_OK"; then
  awk '
    BEGIN { done = 0 }
    /^vibe-status([ \t]|$)/ && !done {
      print $0 " app_launch_claim=none"
      done = 1
      next
    }
    { print }
    END { if (!done) exit 1 }
  ' "$PI4_CLAIM_OK" > "$PI4_CLAIM_OK.tmp"
  mv "$PI4_CLAIM_OK.tmp" "$PI4_CLAIM_OK"
fi
"$CHECKER" "$PI4_CLAIM_OK"
"$PI4_EVIDENCE" "$PI4_CLAIM_OK"
if grep -q 'app_launch_claim=' "$PI4_HW_OK"; then
  sed 's/app_launch_claim=[^[:space:]]*/app_launch_claim=doom/' "$PI4_HW_OK" > "$PI4_CLAIM_BAD"
else
  awk '
    BEGIN { done = 0 }
    /^vibe-status([ \t]|$)/ && !done {
      print $0 " app_launch_claim=doom"
      done = 1
      next
    }
    { print }
    END { if (!done) exit 1 }
  ' "$PI4_HW_OK" > "$PI4_CLAIM_BAD"
fi
if "$CHECKER" "$PI4_CLAIM_BAD" >/tmp/vibe-status-check-launcher-claim-bad.out 2>&1; then
  echo "vibe_status_check accepted a Pi 4 app launch overclaim" >&2
  cat /tmp/vibe-status-check-launcher-claim-bad.out >&2
  exit 1
fi
if "$PI4_EVIDENCE" "$PI4_CLAIM_BAD" >/tmp/pi4-status-evidence-launcher-claim-bad.out 2>&1; then
  echo "pi4_status_evidence accepted a Pi 4 app launch overclaim" >&2
  cat /tmp/pi4-status-evidence-launcher-claim-bad.out >&2
  exit 1
fi
{
  printf '%s\n' 'uart: boot banner before the first status line'
  printf '%s\n' 'vibe-status arch=AARCH64 machine=PI4 image=PI4 artifact=BAD'
  printf '%s\n' 'uart: later capture contains the real guest status'
  cat "$PI4_HW_OK"
  printf '%s\n' 'uart: trailing monitor prompt'
} > "$PI4_SERIAL_LAST_OK"
"$PI4_EVIDENCE" "$PI4_SERIAL_LAST_OK"
{
  cat "$PI4_HW_OK"
  printf '%s\n' 'uart: stale good status above must not mask the final line'
  printf '%s\n' 'vibe-status arch=AARCH64 machine=PI4 image=PI4 artifact=BAD'
} > "$PI4_SERIAL_LAST_BAD"
if "$PI4_EVIDENCE" "$PI4_SERIAL_LAST_BAD" >/tmp/pi4-status-evidence-serial-last-bad.out 2>&1; then
  echo "pi4_status_evidence accepted stale serial evidence instead of validating the last vibe-status line" >&2
  cat /tmp/pi4-status-evidence-serial-last-bad.out >&2
  exit 1
fi
if "$PI4_EVIDENCE" "$ROOT/tests/fixtures/pi4_status_giccfg_ok.txt" >/tmp/pi4-status-evidence-incomplete.out 2>&1; then
  echo "pi4_status_evidence accepted incomplete Pi 4 hardware-equivalent evidence" >&2
  cat /tmp/pi4-status-evidence-incomplete.out >&2
  exit 1
fi
sed 's|pi4audiocap=0000000000000007|pi4audiocap=NONE|' \
  "$PI4_HW_OK" > "$PI4_HW_BAD"
if "$PI4_EVIDENCE" "$PI4_HW_BAD" >/tmp/pi4-status-evidence-hardware-bad.out 2>&1; then
  echo "pi4_status_evidence accepted Pi 4 hardware evidence without audio caps" >&2
  cat /tmp/pi4-status-evidence-hardware-bad.out >&2
  exit 1
fi
sed 's|pi4audioq=[^[:space:]]*|pi4audioq=0000000000001000/0000000000002000/0000000000000001/0000000000000000|' \
  "$PI4_HW_OK" > "$PI4_HW_AUDIO_QUEUE_BAD"
if "$PI4_EVIDENCE" "$PI4_HW_AUDIO_QUEUE_BAD" >/tmp/pi4-status-evidence-audio-queue-bad.out 2>&1; then
  echo "pi4_status_evidence accepted Pi 4 audio OK with an overfull PCM queue" >&2
  cat /tmp/pi4-status-evidence-audio-queue-bad.out >&2
  exit 1
fi
sed \
  -e 's|pi4audio=OK|pi4audio=HARDWARE-UNPROVEN|' \
  -e 's|pi4audiocap=0000000000000007|pi4audiocap=0000000000000003|' \
  -e 's|pi4audioq=[^[:space:]]*|pi4audioq=NONE|' \
  -e 's|pi4audioabi=[^[:space:]]*|pi4audioabi=NONE|' \
  "$PI4_HW_OK" > "$PI4_AUDIO_HW_UNPROVEN"
"$CHECKER" "$PI4_AUDIO_HW_UNPROVEN"
cat > "$PI4_FINAL_GATES_AUDIO_OK" <<EOF_GATES_OK
storage=green
input=green
graphics=green
process=green
memory=green
preemption=green
audio=hardware-unproven
hardware=unclaimed
green_gate=false
hardware_proof=unclaimed
EOF_GATES_OK
"$CHECKER" --pi4-final-gates "$PI4_FINAL_GATES_AUDIO_OK" "$PI4_AUDIO_HW_UNPROVEN"
sed 's|audio=hardware-unproven|audio=green|' \
  "$PI4_FINAL_GATES_AUDIO_OK" > "$PI4_FINAL_GATES_AUDIO_BAD"
if "$CHECKER" --pi4-final-gates "$PI4_FINAL_GATES_AUDIO_BAD" "$PI4_AUDIO_HW_UNPROVEN" >/tmp/vibe-status-check-final-gates-audio-bad.out 2>&1; then
  echo "vibe_status_check accepted audio=green final gate for pi4audio=HARDWARE-UNPROVEN" >&2
  cat /tmp/vibe-status-check-final-gates-audio-bad.out >&2
  exit 1
fi
cat > "$PI4_FINAL_GATES_AUDIO_IMPLICIT_BAD" <<EOF_GATES_IMPLICIT_BAD
storage=green
input=green
graphics=green
process=green
memory=green
preemption=green
audio=green
hardware=maybe
green_gate=true
hardware_proof=claimed
EOF_GATES_IMPLICIT_BAD
if "$CHECKER" --pi4-final-gates "$PI4_FINAL_GATES_AUDIO_IMPLICIT_BAD" "$PI4_HW_OK" >/tmp/vibe-status-check-final-gates-audio-implicit-bad.out 2>&1; then
  echo "vibe_status_check accepted audio=green final gate without explicit hardware=claimed evidence" >&2
  cat /tmp/vibe-status-check-final-gates-audio-implicit-bad.out >&2
  exit 1
fi
sed \
  -e 's| preempt=[^[:space:]]* pirq=[^[:space:]]* pctx=[^[:space:]]* pfrom=[^[:space:]]* pto=[^[:space:]]* pi4preempt=OK| pi4preempt=WAIT|' \
  -e 's|pi4sched=[^[:space:]]*|pi4sched=0000000000000001/0000000000000001/0000000000000001/0000000000000000/0000000000000001/0000000000000001|' \
  "$PI4_HW_OK" > "$PI4_PREEMPT_WAIT_BAD"
"$CHECKER" "$PI4_PREEMPT_WAIT_BAD"
if "$PI4_EVIDENCE" "$PI4_PREEMPT_WAIT_BAD" >/tmp/pi4-status-evidence-preempt-wait-bad.out 2>&1; then
  echo "pi4_status_evidence accepted Pi 4 hardware-equivalent evidence with pi4preempt=WAIT" >&2
  cat /tmp/pi4-status-evidence-preempt-wait-bad.out >&2
  exit 1
fi
cat > "$PI4_FINAL_GATES_PROCESS_BAD" <<EOF_PROCESS_GATES_BAD
storage=green
input=green
graphics=green
process=green
memory=wait
preemption=wait
audio=green
hardware=claimed
green_gate=true
hardware_proof=claimed
EOF_PROCESS_GATES_BAD
sed \
  -e 's|pi4uabi=OK|pi4uabi=WAIT|' \
  -e 's|pi4runtime=OK|pi4runtime=WAIT|' \
  "$PI4_HW_OK" > "$PI4_PROCESS_STATUS_BAD"
if "$CHECKER" --pi4-final-gates "$PI4_FINAL_GATES_PROCESS_BAD" "$PI4_PROCESS_STATUS_BAD" >/tmp/vibe-status-check-final-gates-process-bad.out 2>&1; then
  echo "vibe_status_check accepted process=green without captured pi4uabi/pi4runtime process status" >&2
  cat /tmp/vibe-status-check-final-gates-process-bad.out >&2
  exit 1
fi
cat > "$PI4_FINAL_GATES_MEMORY_BAD" <<EOF_MEMORY_GATES_BAD
storage=green
input=green
graphics=green
process=wait
memory=green
preemption=wait
audio=green
hardware=claimed
green_gate=true
hardware_proof=claimed
EOF_MEMORY_GATES_BAD
sed 's|pi4mem=OK|pi4mem=WAIT|' \
  "$PI4_HW_OK" > "$PI4_MEMORY_STATUS_BAD"
if "$CHECKER" --pi4-final-gates "$PI4_FINAL_GATES_MEMORY_BAD" "$PI4_MEMORY_STATUS_BAD" >/tmp/vibe-status-check-final-gates-memory-bad.out 2>&1; then
  echo "vibe_status_check accepted memory=green without captured pi4mem=OK status" >&2
  cat /tmp/vibe-status-check-final-gates-memory-bad.out >&2
  exit 1
fi
cat > "$PI4_FINAL_GATES_PREEMPT_BAD" <<EOF_PREEMPT_GATES_BAD
storage=green
input=green
graphics=green
process=wait
memory=wait
preemption=green
audio=green
hardware=claimed
green_gate=true
hardware_proof=claimed
EOF_PREEMPT_GATES_BAD
if "$CHECKER" --pi4-final-gates "$PI4_FINAL_GATES_PREEMPT_BAD" "$PI4_PREEMPT_WAIT_BAD" >/tmp/vibe-status-check-final-gates-preempt-bad.out 2>&1; then
  echo "vibe_status_check accepted preemption=green without captured pi4preempt=OK switch status" >&2
  cat /tmp/vibe-status-check-final-gates-preempt-bad.out >&2
  exit 1
fi
if "$CHECKER" "$PI4_LOCAL_QEMU_BAD" >/tmp/vibe-status-check-local-qemu-bad.out 2>&1; then
  echo "vibe_status_check accepted local-QEMU-only capture as Pi 4 green proof" >&2
  cat /tmp/vibe-status-check-local-qemu-bad.out >&2
  exit 1
fi
if "$PI4_EVIDENCE" "$PI4_LOCAL_QEMU_BAD" >/tmp/pi4-status-evidence-local-qemu-bad.out 2>&1; then
  echo "pi4_status_evidence accepted local-QEMU-only capture as real Pi 4 hardware proof" >&2
  cat /tmp/pi4-status-evidence-local-qemu-bad.out >&2
  exit 1
fi
awk '
  BEGIN { done = 0 }
  /^vibe-status([ \t]|$)/ && !done {
    print $0 " evidence_class=local-qemu-smoke smoke_gate=pi4-local-qemu-smoke green_gate=false hardware_proof=unclaimed"
    done = 1
    next
  }
  { print }
  END { if (!done) exit 1 }
' "$PI4_HW_OK" > "$PI4_LOCAL_QEMU_CLASS_BAD"
if "$CHECKER" "$PI4_LOCAL_QEMU_CLASS_BAD" >/tmp/vibe-status-check-local-qemu-class-bad.out 2>&1; then
  echo "vibe_status_check accepted smoke-marked local QEMU capture as Pi 4 green proof" >&2
  cat /tmp/vibe-status-check-local-qemu-class-bad.out >&2
  exit 1
fi
if "$PI4_EVIDENCE" "$PI4_LOCAL_QEMU_CLASS_BAD" >/tmp/pi4-status-evidence-local-qemu-class-bad.out 2>&1; then
  echo "pi4_status_evidence accepted smoke-marked local QEMU capture as real Pi 4 hardware proof" >&2
  cat /tmp/pi4-status-evidence-local-qemu-class-bad.out >&2
  exit 1
fi
awk '
  BEGIN { done = 0 }
  /^vibe-status([ \t]|$)/ && !done {
    print $0 " evidence_class=local-qemu-input-smoke smoke_gate=pi4-local-qemu-input-smoke"
    done = 1
    next
  }
  { print }
  END { if (!done) exit 1 }
' "$PI4_HW_OK" > "$PI4_LOCAL_QEMU_INPUT_CLASS_BAD"
if "$PI4_EVIDENCE" "$PI4_LOCAL_QEMU_INPUT_CLASS_BAD" >/tmp/pi4-status-evidence-local-qemu-input-class-bad.out 2>&1; then
  echo "pi4_status_evidence accepted input-smoke-marked local QEMU capture as real Pi 4 hardware proof" >&2
  cat /tmp/pi4-status-evidence-local-qemu-input-class-bad.out >&2
  exit 1
fi
awk '
  BEGIN { done = 0 }
  /^vibe-status([ \t]|$)/ && !done {
    print $0 " evidence_class=local-qemu-final-gates"
    done = 1
    next
  }
  { print }
  END { if (!done) exit 1 }
' "$PI4_HW_OK" > "$PI4_LOCAL_QEMU_FINAL_CLASS_BAD"
if "$CHECKER" "$PI4_LOCAL_QEMU_FINAL_CLASS_BAD" >/tmp/vibe-status-check-local-qemu-final-class-bad.out 2>&1; then
  echo "vibe_status_check accepted final-gate-marked local QEMU capture as Pi 4 green proof" >&2
  cat /tmp/vibe-status-check-local-qemu-final-class-bad.out >&2
  exit 1
fi
if "$PI4_EVIDENCE" "$PI4_LOCAL_QEMU_FINAL_CLASS_BAD" >/tmp/pi4-status-evidence-local-qemu-final-class-bad.out 2>&1; then
  echo "pi4_status_evidence accepted final-gate-marked local QEMU capture as real Pi 4 hardware proof" >&2
  cat /tmp/pi4-status-evidence-local-qemu-final-class-bad.out >&2
  exit 1
fi
cat > "$PI4_FINAL_GATES_LOCAL_QEMU_BAD" <<EOF_LOCAL_QEMU_GATES_BAD
storage=green
input=green
graphics=green
process=green
memory=green
preemption=green
audio=green
hardware=unclaimed
green_gate=false
hardware_proof=unclaimed
EOF_LOCAL_QEMU_GATES_BAD
if "$CHECKER" --pi4-final-gates "$PI4_FINAL_GATES_LOCAL_QEMU_BAD" "$PI4_LOCAL_QEMU_INPUT_CLASS_BAD" >/tmp/vibe-status-check-final-gates-local-qemu-bad.out 2>&1; then
  echo "vibe_status_check accepted audio=green final gate from local-QEMU input-smoke evidence" >&2
  cat /tmp/vibe-status-check-final-gates-local-qemu-bad.out >&2
  exit 1
fi
cat > "$PI4_FINAL_GATES_LOCAL_QEMU_AUDIO_OK_BAD" <<EOF_LOCAL_QEMU_AUDIO_OK_GATES_BAD
storage=wait
input=wait
graphics=wait
process=wait
memory=wait
preemption=wait
audio=hardware-unproven
hardware=unclaimed
green_gate=false
hardware_proof=unclaimed
evidence_class=local-qemu-final-gates
EOF_LOCAL_QEMU_AUDIO_OK_GATES_BAD
if "$CHECKER" --pi4-final-gates "$PI4_FINAL_GATES_LOCAL_QEMU_AUDIO_OK_BAD" "$PI4_LOCAL_QEMU_INPUT_CLASS_BAD" >/tmp/vibe-status-check-final-gates-local-qemu-audio-ok-bad.out 2>&1; then
  echo "vibe_status_check accepted local-QEMU pi4audio=OK capture under a hardware-unproven final gate" >&2
  cat /tmp/vibe-status-check-final-gates-local-qemu-audio-ok-bad.out >&2
  exit 1
fi
cat > "$PI4_LOCAL_QEMU_APP_GATES_OK" <<EOF_LOCAL_QEMU_APP_GATES_OK
storage=wait
input=green
graphics=green
process=green
memory=green
preemption=green
audio=wait
hardware=unclaimed
green_gate=false
hardware_proof=unclaimed
evidence_class=local-qemu-final-gates
framebuffer_artifact=green
framebuffer_artifact_source=qemu-screendump
doom_framebuffer_artifact=green
doom_framebuffer_report=build/pi4/local-qemu-doom-framebuffer.txt
doom_framebuffer_frame0_hash=1111111111111111
doom_framebuffer_frame1_hash=2222222222222222
quake_framebuffer_artifact=green
quake_framebuffer_report=build/pi4/local-qemu-quake-framebuffer.txt
quake_framebuffer_frame0_hash=3333333333333333
quake_framebuffer_frame1_hash=4444444444444444
launcher_doom_exec=green
launcher_quake_exec=green
app_launch_status_fields=pi4exec,pi4execreq,pi4appreq,pi4appvfs,path,upath,pi4inputevt,fbpresent,fbchange
EOF_LOCAL_QEMU_APP_GATES_OK
cat > "$PI4_LOCAL_QEMU_APP_DOOM_OK" <<EOF_LOCAL_QEMU_DOOM_OK
vibe-status arch=AARCH64 machine=PI4 image=PI4
pi4sd=WAIT pi4fat=WAIT pi4vfs=WAIT
pi4audio=WAIT pi4audiohw=NONE pi4audiommio=NONE pi4audiomailbox=WAIT pi4audiocap=NONE pi4audioq=NONE pi4audioabi=NONE
local_qemu_only=true evidence_class=local-qemu-input-smoke smoke_gate=pi4-local-qemu-input-smoke green_gate=false hardware_proof=unclaimed
pi4irq=OK pi4timer=OK irqctl=GIC pi4gic=0000000000000001/0000000000000001/000000000000001E/000000000000001E clocksrc=ARMTMR clockhz=000000000337F980 clocktick=00000000000851EB clockirq=000000000000001E ticks=0000000000000001
pi4mem=OK pi4kmap=0000000000080000/00000000000B0000/0000000000098000/0000000000099000 pi4stack=00000000000A0000/00000000000A4000/00000000000A4000/00000000000A5000 pi4umem=0000000000083000/0000000000083100/0000000000083040/0000000000000100 pi4ualloc=0000000000083000/0000000000083100/0000000000000100/00000000000A4000/00000000000A5000/0000000000001000/000000000000000F/0000000000000002 pi4fbmap=0000000001000000/0000000000300000/0000000000000A00/0000000000000020 pi4ptable=00000000000A5000/0000000000000004/0000000000000040/0000000000000002
pi4svc=OK pi4uabi=OK pi4elf=OK pi4elfsrc=VFS exec=OK path=/APPS/DOOM/APP.ELF uexec=OK upath=/APPS/DOOM/APP.ELF pi4elfentry=0000000000084000 pi4elfphdr=0000000000084040/0000000000000038/0000000000000001 pi4elfload=0000000000084000/0000000000084000/0000000000002000/0000000000002000/0000000000000005/0000000000001000 uentry=0000000000084000 execsys=0000000000000001/0000000000000001 pi4ustack=00000000000A3000/00000000000A4000/0000000000001000/0000000000000001 execmap=0000000000084000/0000000000002000/0000000000000005 pstat=0000000000000002/0000000000000003/0000000000000002/0000000000000002/0000000000000001/0000000000000001 procpool=0000000000000002/0000000000000004 pidseq=0000000000000002/0000000000000003 pi4runtime=OK
preempt=0000000000000001 pirq=0000000000000001 pctx=0000000000000001 pfrom=0000000000000002 pto=0000000000000001 pi4preempt=OK pi4ctx=00000000000A5100/0000000000000040/0000000000000001/0000000000000001/0000000000000002/0000000000084000/00000000000A3000/00000000000003C0/0000000000000003 pi4sched=0000000000000001/0000000000000001/0000000000000000/0000000000000001/0000000000000001/0000000000000002
pi4exec=OK pi4execreq=0000000000000010/0000000000086000/0000000000086080/0000000000000000/0000000000000000/0000000000000001
pi4appreq=0000000000086000/0000000000000001/0000000000000020/0000000000086080/0000000000000012/000000000000000E
pi4appvfs=000000000000000E/00000000464F4F4B/0000000000000001/0000000000000020/0000000000000002/0000000000000001/0000000000000200/0000000000000001/0000000000000001/0000000000000400
pi4userfile=0000000000000007/0000000000000004/0000000000000000/0000000000000001/0000000000000003/0000000000001000/0000000000000000/0000000000000010/0000000000000010/0000000044415749/0000000000000001/0000000000000001/0000000000000001
pi4fb=OK fbpresent=0000000000000002/0000000000000010/00000000CAFEBABE/00000000FACEB00C fbchange=0000000000000000/00000000FACEB00C/0000000000000001/0000000000000001
pi4inputevt=0000000000000001/0000000000000000/0000000000000001/0000000000000001/0000000000000000
panic=NONE shutdown=NONE
EOF_LOCAL_QEMU_DOOM_OK
cat > "$PI4_LOCAL_QEMU_APP_QUAKE_OK" <<EOF_LOCAL_QEMU_QUAKE_OK
vibe-status arch=AARCH64 machine=PI4 image=PI4
pi4sd=WAIT pi4fat=WAIT pi4vfs=WAIT
pi4audio=WAIT pi4audiohw=NONE pi4audiommio=NONE pi4audiomailbox=WAIT pi4audiocap=NONE pi4audioq=NONE pi4audioabi=NONE
local_qemu_only=true evidence_class=local-qemu-input-smoke smoke_gate=pi4-local-qemu-input-smoke green_gate=false hardware_proof=unclaimed
pi4irq=OK pi4timer=OK irqctl=GIC pi4gic=0000000000000001/0000000000000001/000000000000001E/000000000000001E clocksrc=ARMTMR clockhz=000000000337F980 clocktick=00000000000851EB clockirq=000000000000001E ticks=0000000000000001
pi4mem=OK pi4kmap=0000000000080000/00000000000B0000/0000000000098000/0000000000099000 pi4stack=00000000000A0000/00000000000A4000/00000000000A4000/00000000000A5000 pi4umem=0000000000083000/0000000000083100/0000000000083040/0000000000000100 pi4ualloc=0000000000083000/0000000000083100/0000000000000100/00000000000A4000/00000000000A5000/0000000000001000/000000000000000F/0000000000000002 pi4fbmap=0000000001000000/0000000000300000/0000000000000A00/0000000000000020 pi4ptable=00000000000A5000/0000000000000004/0000000000000040/0000000000000002
pi4svc=OK pi4uabi=OK pi4elf=OK pi4elfsrc=VFS exec=OK path=/APPS/QUAKE/APP.ELF uexec=OK upath=/APPS/QUAKE/APP.ELF pi4elfentry=0000000000084000 pi4elfphdr=0000000000084040/0000000000000038/0000000000000001 pi4elfload=0000000000084000/0000000000084000/0000000000002000/0000000000002000/0000000000000005/0000000000001000 uentry=0000000000084000 execsys=0000000000000001/0000000000000001 pi4ustack=00000000000A3000/00000000000A4000/0000000000001000/0000000000000001 execmap=0000000000084000/0000000000002000/0000000000000005 pstat=0000000000000002/0000000000000003/0000000000000002/0000000000000002/0000000000000001/0000000000000001 procpool=0000000000000002/0000000000000004 pidseq=0000000000000002/0000000000000003 pi4runtime=OK
preempt=0000000000000001 pirq=0000000000000001 pctx=0000000000000001 pfrom=0000000000000002 pto=0000000000000001 pi4preempt=OK pi4ctx=00000000000A5100/0000000000000040/0000000000000001/0000000000000001/0000000000000002/0000000000084000/00000000000A3000/00000000000003C0/0000000000000003 pi4sched=0000000000000001/0000000000000001/0000000000000000/0000000000000001/0000000000000001/0000000000000002
pi4exec=OK pi4execreq=0000000000000010/0000000000086000/0000000000086080/0000000000000000/0000000000000000/0000000000000001
pi4appreq=0000000000086000/0000000000000001/0000000000000020/0000000000086080/0000000000000013/000000000000000F
pi4appvfs=000000000000000F/00000000464F4F4B/0000000000000001/0000000000000020/0000000000000002/0000000000000001/0000000000000200/0000000000000001/0000000000000001/0000000000000400
pi4userfile=0000000000000007/0000000000000004/0000000000000001/0000000000000002/0000000000000004/0000000000200000/0000000000000000/0000000000000010/0000000000000010/000000004B434150/0000000000000001/0000000000000001/0000000000000001
pi4fb=OK fbpresent=0000000000000002/0000000000000010/00000000CAFEBABE/00000000FACEB00C fbchange=0000000000000000/00000000FACEB00C/0000000000000001/0000000000000001
pi4inputevt=0000000000000000/0000000000000001/0000000000000001/0000000000000000/0000000000000001
panic=NONE shutdown=NONE
EOF_LOCAL_QEMU_QUAKE_OK
"$CHECKER" --pi4-final-gates "$PI4_LOCAL_QEMU_APP_GATES_OK" "$PI4_LOCAL_QEMU_APP_DOOM_OK" "$PI4_LOCAL_QEMU_APP_QUAKE_OK"
sed '/^framebuffer_artifact=/d; /^framebuffer_artifact_source=/d; /^doom_framebuffer_/d; /^quake_framebuffer_/d' \
  "$PI4_LOCAL_QEMU_APP_GATES_OK" > "$PI4_LOCAL_QEMU_APP_GATES_FB_BAD"
if "$CHECKER" --pi4-final-gates "$PI4_LOCAL_QEMU_APP_GATES_FB_BAD" "$PI4_LOCAL_QEMU_APP_DOOM_OK" "$PI4_LOCAL_QEMU_APP_QUAKE_OK" >/tmp/vibe-status-check-final-gates-framebuffer-bad.out 2>&1; then
  echo "vibe_status_check accepted local QEMU graphics=green final gates without framebuffer hash artifacts" >&2
  cat /tmp/vibe-status-check-final-gates-framebuffer-bad.out >&2
  exit 1
fi
sed 's/doom_framebuffer_frame1_hash=2222222222222222/doom_framebuffer_frame1_hash=1111111111111111/' \
  "$PI4_LOCAL_QEMU_APP_GATES_OK" > "$PI4_LOCAL_QEMU_APP_GATES_FB_UNCHANGED_BAD"
if "$CHECKER" --pi4-final-gates "$PI4_LOCAL_QEMU_APP_GATES_FB_UNCHANGED_BAD" "$PI4_LOCAL_QEMU_APP_DOOM_OK" "$PI4_LOCAL_QEMU_APP_QUAKE_OK" >/tmp/vibe-status-check-final-gates-framebuffer-unchanged-bad.out 2>&1; then
  echo "vibe_status_check accepted unchanged local QEMU framebuffer artifact hashes" >&2
  cat /tmp/vibe-status-check-final-gates-framebuffer-unchanged-bad.out >&2
  exit 1
fi
if "$CHECKER" --pi4-final-gates "$PI4_LOCAL_QEMU_APP_GATES_OK" "$PI4_LOCAL_QEMU_DOOM_LAUNCH_ONLY_BAD" "$PI4_LOCAL_QEMU_APP_QUAKE_OK" >/tmp/vibe-status-check-final-gates-doom-launch-only-bad.out 2>&1; then
  echo "vibe_status_check accepted Pi 4 Doom local QEMU app proof from ELF launch alone" >&2
  cat /tmp/vibe-status-check-final-gates-doom-launch-only-bad.out >&2
  exit 1
fi
if "$CHECKER" --pi4-final-gates "$PI4_LOCAL_QEMU_APP_GATES_OK" "$PI4_LOCAL_QEMU_APP_DOOM_OK" "$PI4_LOCAL_QEMU_QUAKE_LAUNCH_ONLY_BAD" >/tmp/vibe-status-check-final-gates-quake-launch-only-bad.out 2>&1; then
  echo "vibe_status_check accepted Pi 4 Quake local QEMU app proof without input progress" >&2
  cat /tmp/vibe-status-check-final-gates-quake-launch-only-bad.out >&2
  exit 1
fi
sed 's|pi4inputevt=0000000000000001/0000000000000000/0000000000000001/0000000000000001/0000000000000000|pi4inputevt=0000000000000001/0000000000000000/0000000000000000/0000000000000001/0000000000000000|' \
  "$PI4_LOCAL_QEMU_APP_DOOM_OK" > "$PI4_LOCAL_QEMU_APP_CLICK_BAD"
if "$CHECKER" --pi4-final-gates "$PI4_LOCAL_QEMU_APP_GATES_OK" "$PI4_LOCAL_QEMU_APP_CLICK_BAD" "$PI4_LOCAL_QEMU_APP_QUAKE_OK" >/tmp/vibe-status-check-final-gates-click-bad.out 2>&1; then
  echo "vibe_status_check accepted Pi 4 app gameplay proof without mouse/click launcher input" >&2
  cat /tmp/vibe-status-check-final-gates-click-bad.out >&2
  exit 1
fi
sed '/^pi4userfile=/d' "$PI4_LOCAL_QEMU_APP_DOOM_OK" > "$PI4_LOCAL_QEMU_APP_DOOM_ASSET_BAD"
if "$CHECKER" --pi4-final-gates "$PI4_LOCAL_QEMU_APP_GATES_OK" "$PI4_LOCAL_QEMU_APP_DOOM_ASSET_BAD" "$PI4_LOCAL_QEMU_APP_QUAKE_OK" >/tmp/vibe-status-check-final-gates-doom-asset-bad.out 2>&1; then
  echo "vibe_status_check accepted Pi 4 Doom app gameplay proof without real WAD VFS read evidence" >&2
  cat /tmp/vibe-status-check-final-gates-doom-asset-bad.out >&2
  exit 1
fi
sed '/^pi4userfile=/d' "$PI4_LOCAL_QEMU_APP_QUAKE_OK" > "$PI4_LOCAL_QEMU_APP_QUAKE_ASSET_BAD"
if "$CHECKER" --pi4-final-gates "$PI4_LOCAL_QEMU_APP_GATES_OK" "$PI4_LOCAL_QEMU_APP_DOOM_OK" "$PI4_LOCAL_QEMU_APP_QUAKE_ASSET_BAD" >/tmp/vibe-status-check-final-gates-quake-asset-bad.out 2>&1; then
  echo "vibe_status_check accepted Pi 4 Quake app gameplay proof without real PAK VFS read evidence" >&2
  cat /tmp/vibe-status-check-final-gates-quake-asset-bad.out >&2
  exit 1
fi
sed 's|fbchange=0000000000000000/00000000FACEB00C/0000000000000001/0000000000000001|fbchange=00000000FACEB00C/00000000FACEB00C/0000000000000001/0000000000000001|' \
  "$PI4_LOCAL_QEMU_APP_DOOM_OK" > "$PI4_LOCAL_QEMU_APP_FRAME_BAD"
if "$CHECKER" --pi4-final-gates "$PI4_LOCAL_QEMU_APP_GATES_OK" "$PI4_LOCAL_QEMU_APP_FRAME_BAD" "$PI4_LOCAL_QEMU_APP_QUAKE_OK" >/tmp/vibe-status-check-final-gates-frame-progress-bad.out 2>&1; then
  echo "vibe_status_check accepted Pi 4 app gameplay proof without rendered frame progress" >&2
  cat /tmp/vibe-status-check-final-gates-frame-progress-bad.out >&2
  exit 1
fi
sed 's|panic=NONE shutdown=NONE|panic=ASSERT shutdown=NONE|' \
  "$PI4_LOCAL_QEMU_APP_DOOM_OK" > "$PI4_LOCAL_QEMU_APP_PANIC_BAD"
if "$CHECKER" --pi4-final-gates "$PI4_LOCAL_QEMU_APP_GATES_OK" "$PI4_LOCAL_QEMU_APP_PANIC_BAD" "$PI4_LOCAL_QEMU_APP_QUAKE_OK" >/tmp/vibe-status-check-final-gates-panic-bad.out 2>&1; then
  echo "vibe_status_check accepted Pi 4 app gameplay proof with panic!=NONE" >&2
  cat /tmp/vibe-status-check-final-gates-panic-bad.out >&2
  exit 1
fi
sed 's|panic=NONE shutdown=NONE|panic=NONE shutdown=REBOOT|' \
  "$PI4_LOCAL_QEMU_APP_DOOM_OK" > "$PI4_LOCAL_QEMU_APP_SHUTDOWN_BAD"
if "$CHECKER" --pi4-final-gates "$PI4_LOCAL_QEMU_APP_GATES_OK" "$PI4_LOCAL_QEMU_APP_SHUTDOWN_BAD" "$PI4_LOCAL_QEMU_APP_QUAKE_OK" >/tmp/vibe-status-check-final-gates-shutdown-bad.out 2>&1; then
  echo "vibe_status_check accepted Pi 4 app gameplay proof with shutdown!=NONE" >&2
  cat /tmp/vibe-status-check-final-gates-shutdown-bad.out >&2
  exit 1
fi
awk '
  BEGIN {
    done = 0
    pak0 = "0000000000006000/0000000000000020/0000000000000019/0000000000200000/00000000000009B8/0000000000001000/0000000000200000/0000000000001000"
  }
  /^vibe-status([ \t]|$)/ && !done {
    sub(/pi4assets=0000000000000003\/0000000000000002\/000000000000000B/, "pi4assets=0000000000000003/0000000000000002/000000000000000F")
    print $0 " pi4pak0=" pak0
    done = 1
    next
  }
  { print }
  END { if (!done) exit 1 }
' "$PI4_HW_OK" > "$PI4_STORAGE_WAD_PAK_OK"
cat > "$PI4_FINAL_GATES_ASSETS_OK" <<EOF_ASSET_GATES_OK
storage=green
storage_assets=real-wad-and-pak
storage_status_fields=pi4wad,pi4pak0
input=green
graphics=green
process=green
memory=green
preemption=green
audio=green
hardware=claimed
green_gate=true
hardware_proof=claimed
EOF_ASSET_GATES_OK
"$CHECKER" --pi4-final-gates "$PI4_FINAL_GATES_ASSETS_OK" "$PI4_STORAGE_WAD_PAK_OK"
sed 's|pi4wad=[^[:space:]]*|pi4wad=0000000000000000/0000000000000000/0000000000000000/0000000000000000/0000000000000000/0000000000000000/0000000000000000/0000000000000000|' \
  "$PI4_STORAGE_WAD_PAK_OK" > "$PI4_STORAGE_WAD_ZERO_BAD"
if "$CHECKER" --pi4-final-gates "$PI4_FINAL_GATES_ASSETS_OK" "$PI4_STORAGE_WAD_ZERO_BAD" >/tmp/vibe-status-check-final-gates-storage-wad-bad.out 2>&1; then
  echo "vibe_status_check accepted storage=green final gate with zero pi4wad tuple" >&2
  cat /tmp/vibe-status-check-final-gates-storage-wad-bad.out >&2
  exit 1
fi
sed 's|pi4pak0=[^[:space:]]*|pi4pak0=0000000000000000/0000000000000000/0000000000000000/0000000000000000/0000000000000000/0000000000000000/0000000000000000/0000000000000000|' \
  "$PI4_STORAGE_WAD_PAK_OK" > "$PI4_STORAGE_PAK_ZERO_BAD"
if "$CHECKER" --pi4-final-gates "$PI4_FINAL_GATES_ASSETS_OK" "$PI4_STORAGE_PAK_ZERO_BAD" >/tmp/vibe-status-check-final-gates-storage-pak-bad.out 2>&1; then
  echo "vibe_status_check accepted storage=green real-asset final gate with zero pi4pak0 tuple" >&2
  cat /tmp/vibe-status-check-final-gates-storage-pak-bad.out >&2
  exit 1
fi
cat > "$PI4_FINAL_GATES_SINGLE_ARTIFACT_OK" <<EOF_SINGLE_ARTIFACT_OK
storage=green
input=green
graphics=green
process=green
memory=green
preemption=green
audio=hardware-unproven
hardware=unclaimed
green_gate=false
hardware_proof=unclaimed
single_artifact=green
single_artifact_image=build/pi4/pi4-fat16.img
single_artifact_sha256=$PI4_SINGLE_ARTIFACT_SHA
EOF_SINGLE_ARTIFACT_OK
"$CHECKER" --pi4-final-gates-single-artifact "$PI4_FINAL_GATES_SINGLE_ARTIFACT_OK" "$PI4_SINGLE_ARTIFACT_SHA"
sed "s|$PI4_SINGLE_ARTIFACT_SHA|$PI4_SINGLE_ARTIFACT_OTHER_SHA|" \
  "$PI4_FINAL_GATES_SINGLE_ARTIFACT_OK" > "$PI4_FINAL_GATES_SINGLE_ARTIFACT_BAD"
if "$CHECKER" --pi4-final-gates-single-artifact "$PI4_FINAL_GATES_SINGLE_ARTIFACT_BAD" "$PI4_SINGLE_ARTIFACT_SHA" >/tmp/vibe-status-check-single-artifact-bad.out 2>&1; then
  echo "vibe_status_check accepted stale Pi 4 single_artifact_sha256 final gate" >&2
  cat /tmp/vibe-status-check-single-artifact-bad.out >&2
  exit 1
fi
rm -rf "$PI4_SINGLE_ARTIFACT_GUARD_BUILD_DIR"
mkdir -p "$PI4_SINGLE_ARTIFACT_GUARD_BUILD_DIR/pi4"
printf '%s' 'pi4 single artifact guard image' > "$PI4_SINGLE_ARTIFACT_GUARD_BUILD_DIR/pi4/pi4-fat16.img"
make_guard_sha="$(
  shasum -a 256 "$PI4_SINGLE_ARTIFACT_GUARD_BUILD_DIR/pi4/pi4-fat16.img" |
    sed 's/[[:space:]].*//'
)"
cat > "$PI4_SINGLE_ARTIFACT_GUARD_BUILD_DIR/pi4/local-qemu-real-assets-final-gates.txt" <<EOF_MAKE_GUARD_OK
single_artifact=green
single_artifact_image=$PI4_SINGLE_ARTIFACT_GUARD_BUILD_DIR/pi4/pi4-fat16.img
single_artifact_sha256=$make_guard_sha
EOF_MAKE_GUARD_OK
"$MAKE_CMD" -C "$ROOT" --no-print-directory \
  BUILD_DIR="$PI4_SINGLE_ARTIFACT_GUARD_BUILD_DIR" \
  PI4_FINAL_GATES_GUARD="$PI4_SINGLE_ARTIFACT_GUARD_BUILD_DIR/pi4/local-qemu-real-assets-final-gates.txt" \
  pi4-final-gates-single-artifact-guard
sed "s|$make_guard_sha|$PI4_SINGLE_ARTIFACT_OTHER_SHA|" \
  "$PI4_SINGLE_ARTIFACT_GUARD_BUILD_DIR/pi4/local-qemu-real-assets-final-gates.txt" \
  > "$PI4_SINGLE_ARTIFACT_GUARD_BUILD_DIR/pi4/local-qemu-real-assets-final-gates-stale.txt"
if "$MAKE_CMD" -C "$ROOT" --no-print-directory \
  BUILD_DIR="$PI4_SINGLE_ARTIFACT_GUARD_BUILD_DIR" \
  PI4_FINAL_GATES_GUARD="$PI4_SINGLE_ARTIFACT_GUARD_BUILD_DIR/pi4/local-qemu-real-assets-final-gates-stale.txt" \
  pi4-final-gates-single-artifact-guard >/tmp/vibe-pi4-single-artifact-guard-bad.out 2>&1; then
  echo "pi4-final-gates-single-artifact-guard accepted stale final-gates SHA" >&2
  cat /tmp/vibe-pi4-single-artifact-guard-bad.out >&2
  exit 1
fi
if "$CHECKER" "$PI4_STORAGE_OVERCLAIM_BAD" >/tmp/vibe-status-check-storage-overclaim-bad.out 2>&1; then
  echo "vibe_status_check accepted Pi 4 storage WAIT capture with FAT/VFS overclaim evidence" >&2
  cat /tmp/vibe-status-check-storage-overclaim-bad.out >&2
  exit 1
fi
if "$PI4_EVIDENCE" "$PI4_STORAGE_OVERCLAIM_BAD" >/tmp/pi4-status-evidence-storage-overclaim-bad.out 2>&1; then
  echo "pi4_status_evidence accepted Pi 4 storage WAIT capture with FAT/VFS overclaim evidence" >&2
  cat /tmp/pi4-status-evidence-storage-overclaim-bad.out >&2
  exit 1
fi
sed 's| pi4wad=[^[:space:]]*||' "$PI4_HW_OK" > "$PI4_STORAGE_MISSING_WAD_BAD"
if "$CHECKER" "$PI4_STORAGE_MISSING_WAD_BAD" >/tmp/vibe-status-check-storage-missing-wad-bad.out 2>&1; then
  echo "vibe_status_check accepted Pi 4 storage-green evidence without a full WAD read" >&2
  cat /tmp/vibe-status-check-storage-missing-wad-bad.out >&2
  exit 1
fi
if "$PI4_EVIDENCE" "$PI4_STORAGE_MISSING_WAD_BAD" >/tmp/pi4-status-evidence-storage-missing-wad-bad.out 2>&1; then
  echo "pi4_status_evidence accepted Pi 4 storage-green evidence without a full WAD read" >&2
  cat /tmp/pi4-status-evidence-storage-missing-wad-bad.out >&2
  exit 1
fi
sed 's|pi4assets=0000000000000003/0000000000000002/000000000000000B|pi4assets=0000000000000003/0000000000000002/000000000000000F|' \
  "$PI4_HW_OK" > "$PI4_STORAGE_PAK_CLAIM_BAD"
if "$CHECKER" "$PI4_STORAGE_PAK_CLAIM_BAD" >/tmp/vibe-status-check-storage-pak-claim-bad.out 2>&1; then
  echo "vibe_status_check accepted Pi 4 PAK coverage without a full PAK read" >&2
  cat /tmp/vibe-status-check-storage-pak-claim-bad.out >&2
  exit 1
fi
if "$PI4_EVIDENCE" "$PI4_STORAGE_PAK_CLAIM_BAD" >/tmp/pi4-status-evidence-storage-pak-claim-bad.out 2>&1; then
  echo "pi4_status_evidence accepted Pi 4 PAK coverage without a full PAK read" >&2
  cat /tmp/pi4-status-evidence-storage-pak-claim-bad.out >&2
  exit 1
fi
awk '
  BEGIN {
    done = 0
    appreq = "0000000000086000/0000000000000001/0000000000000020/0000000000086080/0000000000000012/000000000000000E"
    appvfs = "000000000000000E/00000000464F4F4B/0000000000002000/0000000000000020/0000000000000003/0000000000010000/0000000000000908/0000000000000080/0000000000010000/0000000000000080"
  }
  /^vibe-status([ \t]|$)/ && !done {
    for (i = 1; i <= NF; i++) {
      if ($i == "path=/SYSTEM/INIT.ELF") {
        $i = "path=/APPS/DOOM/APP.ELF"
      } else if ($i == "upath=/SYSTEM/INIT.ELF") {
        $i = "upath=/APPS/DOOM/APP.ELF"
      }
    }
    print $0 " pi4exec=OK pi4execreq=0000000000000010/0000000000086000/0000000000086080/0000000000000000/0000000000000000/0000000000000001 pi4appreq=" appreq " pi4appvfs=" appvfs
    done = 1
    next
  }
  { print }
  END { if (!done) exit 1 }
' "$PI4_HW_OK" > "$PI4_EXEC_APP_VFS_OK"
"$CHECKER" "$PI4_EXEC_APP_VFS_OK"
sed 's|pi4appvfs=[^[:space:]]*|pi4appvfs=000000000000000F/00000000464F4F4B/0000000000002000/0000000000000020/0000000000000003/0000000000010000/0000000000000908/0000000000000080/0000000000010000/0000000000000080|' \
  "$PI4_EXEC_APP_VFS_OK" > "$PI4_EXEC_APP_VFS_MISMATCH_BAD"
if "$CHECKER" "$PI4_EXEC_APP_VFS_MISMATCH_BAD" >/tmp/vibe-status-check-exec-app-vfs-mismatch-bad.out 2>&1; then
  echo "vibe_status_check accepted Pi 4 /APPS launch proof with mismatched app VFS evidence" >&2
  cat /tmp/vibe-status-check-exec-app-vfs-mismatch-bad.out >&2
  exit 1
fi
sed 's| pi4appvfs=[^[:space:]]*||' "$PI4_EXEC_APP_VFS_OK" > "$PI4_EXEC_APP_VFS_MISSING_BAD"
if "$CHECKER" "$PI4_EXEC_APP_VFS_MISSING_BAD" >/tmp/vibe-status-check-exec-app-vfs-missing-bad.out 2>&1; then
  echo "vibe_status_check accepted Pi 4 exec OK without an app ELF VFS read" >&2
  cat /tmp/vibe-status-check-exec-app-vfs-missing-bad.out >&2
  exit 1
fi
if "$PI4_EVIDENCE" "$PI4_EXEC_APP_VFS_MISSING_BAD" >/tmp/pi4-status-evidence-exec-app-vfs-missing-bad.out 2>&1; then
  echo "pi4_status_evidence accepted Pi 4 exec OK without an app ELF VFS read" >&2
  cat /tmp/pi4-status-evidence-exec-app-vfs-missing-bad.out >&2
  exit 1
fi
awk '
  BEGIN { done = 0 }
  /^vibe-status([ \t]|$)/ && !done {
    for (i = 1; i <= NF; i++) {
      if ($i == "pi4input=UART") {
        $i = "pi4input=UART-LIVE"
      }
    }
    print
    done = 1
    next
  }
  { print }
  END { if (!done) exit 1 }
' "$PI4_HW_OK" > "$PI4_INPUT_LIVE_OK"
"$CHECKER" "$PI4_INPUT_LIVE_OK"
awk '
  BEGIN { done = 0 }
  /^vibe-status([ \t]|$)/ && !done {
    for (i = 1; i <= NF; i++) {
      if ($i == "pi4input=UART") {
        $i = "pi4input=UART-LIVE"
      }
    }
    print $0 " scripted_input=1w"
    done = 1
    next
  }
  { print }
  END { if (!done) exit 1 }
' "$PI4_HW_OK" > "$PI4_INPUT_LIVE_SCRIPTED_BAD"
if "$CHECKER" "$PI4_INPUT_LIVE_SCRIPTED_BAD" >/tmp/vibe-status-check-input-live-scripted-bad.out 2>&1; then
  echo "vibe_status_check accepted UART-LIVE status with scripted UART metadata" >&2
  cat /tmp/vibe-status-check-input-live-scripted-bad.out >&2
  exit 1
fi
for bad in \
  pi4_status_bad_local_qemu_overclaim.txt \
  pi4_status_bad_input_usb_wait_overclaim.txt \
  pi4_status_bad_storage_wait_overclaim.txt \
  pi4_status_bad_audio_ok_missing_cap.txt \
  pi4_status_bad_audio_ok_missing_queue.txt \
  pi4_status_bad_irq_overclaim.txt \
  pi4_status_bad_irq_zero_ticks.txt \
  pi4_status_bad_fb_overclaim.txt \
  pi4_status_bad_fb_wait_overclaim.txt \
  pi4_status_bad_uabi_embedded_overclaim.txt \
  pi4_status_bad_process_wait_overclaim.txt \
  pi4_status_bad_exec_stub_doom_overclaim.txt \
  pi4_status_bad_exec_stub_quake_overclaim.txt \
  pi4_status_bad_uabi_missing_execsys.txt \
  pi4_status_bad_runtime_missing_stack.txt \
  pi4_status_bad_runtime_panic_overclaim.txt \
  pi4_status_bad_preempt_ok_missing_switch.txt \
  pi4_status_bad_storage_ok_missing_read_count.txt \
  pi4_status_bad_storage_ok_missing_mbr.txt \
  pi4_status_bad_storage_ok_missing_bpb.txt \
  pi4_status_bad_storage_ok_missing_root.txt \
  pi4_status_bad_storage_ok_missing_file_read.txt \
  pi4_status_bad_storage_ok_missing_assets.txt
do
  if "$CHECKER" "$ROOT/tests/fixtures/$bad" >/tmp/vibe-status-check-pi4-bad.out 2>&1; then
    echo "vibe_status_check accepted bad Pi 4 fixture: $bad" >&2
    cat /tmp/vibe-status-check-pi4-bad.out >&2
    exit 1
  fi
done
if "$PI4_EVIDENCE" "$ROOT/tests/fixtures/pi4_status_bad_audio_ok_missing_cap.txt" >/tmp/pi4-status-evidence-audio-bad.out 2>&1; then
  echo "pi4_status_evidence accepted Pi 4 audio OK without capability evidence" >&2
  cat /tmp/pi4-status-evidence-audio-bad.out >&2
  exit 1
fi
if "$PI4_EVIDENCE" "$ROOT/tests/fixtures/pi4_status_bad_exec_stub_doom_overclaim.txt" >/tmp/pi4-status-evidence-exec-bad.out 2>&1; then
  echo "pi4_status_evidence accepted Pi 4 Doom launch proof from exec stub" >&2
  cat /tmp/pi4-status-evidence-exec-bad.out >&2
  exit 1
fi
if "$PI4_EVIDENCE" "$ROOT/tests/fixtures/pi4_status_bad_preempt_ok_missing_switch.txt" >/tmp/pi4-status-evidence-preempt-bad.out 2>&1; then
  echo "pi4_status_evidence accepted Pi 4 preemption proof without switch evidence" >&2
  cat /tmp/pi4-status-evidence-preempt-bad.out >&2
  exit 1
fi
for bad in \
  pi4_status_bad_storage_ok_missing_read_count.txt \
  pi4_status_bad_storage_ok_missing_mbr.txt \
  pi4_status_bad_storage_ok_missing_bpb.txt \
  pi4_status_bad_storage_ok_missing_root.txt \
  pi4_status_bad_storage_ok_missing_file_read.txt \
  pi4_status_bad_storage_ok_missing_assets.txt
do
  if "$PI4_EVIDENCE" "$ROOT/tests/fixtures/$bad" >/tmp/pi4-status-evidence-storage-bad.out 2>&1; then
    echo "pi4_status_evidence accepted false Pi 4 storage-green evidence: $bad" >&2
    cat /tmp/pi4-status-evidence-storage-bad.out >&2
    exit 1
  fi
done
fi

DEVICE_OK="$BUILD_DIR/vm_status_devices_ok.txt"
DEVICE_BAD="$BUILD_DIR/vm_status_devices_bad.txt"
cp "$ROOT/tests/fixtures/vm_status_krelhaz_ok.txt" "$DEVICE_OK"
{
  printf ' %s' 'inputqueue=00000004'
  printf ' %s' 'inputdepth=00000001:00000001'
  printf ' %s' 'inputstat=00000004:00000002:00000001:0000003F'
  printf ' %s' 'inputpolicy=00000001:0000003F'
  printf ' %s' 'inputdev=00000001:00000001'
  printf ' %s' 'inputdevices=00000002:00000003:0000001F:00000001:00000001'
  printf ' %s' 'inabi=0000000F/0000000F/00000008/00000004/00000000'
  printf ' %s' 'inputmods=00000003'
  printf ' %s' 'inputlast=00000020:00000002:00000002'
  printf ' %s' 'audio=SB16'
  printf ' %s' 'adev=00000001:00000001:0000000F'
  printf ' %s' 'pcmbuf=00001000:00000800:00000000:00000000'
  printf ' %s' 'pcmstream=00000002:50430001:00000001:00000040:00000040'
  printf ' %s' 'pcmqueue=00010000:00000040:00000000:00000000:00000000:00000040'
  printf ' %s' 'pcmpull=00000002:00000001:00000001'
  printf ' %s' 'pcmdma=00000001:00000000:00000000:00008000:00000000:00000FFF'
  printf ' %s' 'audabi=000001FF/000001FF/00000100/00000010'
  printf ' %s' 'execcopy=00000003/00000003/00000003/00089000/00082000/01000000/01001000/00000200/00000300'
  printf ' %s' 'vfsops=00000001/00000001/00000001/00000001/00000001/00000001/00000001/00000001/00000001/00000001'
  printf ' %s' 'vfsabi=000003FF/000003FF/00000200'
  printf ' %s' 'fatdyn=00000003/00000000/00000002/00000002/00000001/00000002/00000003/0000000E/00000000'
  printf ' %s' 'fatacct=0000D317/000027D8/0000FAEF/0000FAF0/00000000'
  printf ' %s' 'fatabi=000001FF/000001FF/00000100/00000002/00000000'
  printf ' %s' 'fb=LFB'
  printf ' %s' 'fbdev=00000001:00000002:00000003:00000001'
  printf ' %s' 'fbcap=00000017'
  printf ' %s' 'fbsrc=00000001:00000140:000000C8:00000140:000000F0:00000100:00000003'
  printf ' %s' 'fbacct=00000001:00000001:00000000:00000000:00000000:00000001:0000FA00:0000FA00:00000300'
  printf ' %s' 'fbabi=0000000F/0000000F/00000001/00000000/00000004'
  printf ' %s' 'fbpresent=00000002:00000001:00000001:00000000:00000003:00000004:00000002:00000140:000000C8'
  printf ' %s' 'fbinfo=00000001:00000003:00000004'
  printf ' %s' 'fbmmio=E0000000:00000080:00000380:00000000'
  printf ' %s' 'fbpolicy=ASP'
  printf ' %s' 'fbgeom=00000000:00000014:00000140:000000F0:00000001'
  printf ' %s\n' 'fbdirty=00000000:00000000:00000140:000000C8:00000001'
} >> "$DEVICE_OK"
"$CHECKER" --require-exec --require-preempt --require-vfs-abi --require-device-abi "$DEVICE_OK"
sed 's/inputstat=00000004:00000002:00000001:0000003F/inputstat=00000004:00000002:00000002:0000003F/' \
  "$DEVICE_OK" > "$DEVICE_BAD"
if "$CHECKER" --require-exec --require-preempt --require-vfs-abi --require-device-abi "$DEVICE_BAD" >/tmp/vibe-status-check-devices-bad.out 2>&1; then
  echo "vibe_status_check accepted inconsistent device status accounting" >&2
  cat /tmp/vibe-status-check-devices-bad.out >&2
  exit 1
fi
sed 's|inabi=0000000F/0000000F/00000008/00000004/00000000|inabi=0000000B/0000000F/00000008/00000004/00000000|' \
  "$DEVICE_OK" > "$DEVICE_BAD"
if "$CHECKER" --require-exec --require-preempt --require-vfs-abi --require-device-abi "$DEVICE_BAD" >/tmp/vibe-status-check-inabi-bad.out 2>&1; then
  echo "vibe_status_check accepted incomplete generic input ABI proof" >&2
  cat /tmp/vibe-status-check-inabi-bad.out >&2
  exit 1
fi
sed 's|execcopy=00000003/00000003/00000003/00089000/00082000|execcopy=00000003/00000003/00000002/00089000/00082000|' \
  "$DEVICE_OK" > "$DEVICE_BAD"
if "$CHECKER" --require-exec --require-preempt --require-vfs-abi --require-device-abi "$DEVICE_BAD" >/tmp/vibe-status-check-execcopy-bad.out 2>&1; then
  echo "vibe_status_check accepted unbalanced exec CR3 copy accounting" >&2
  cat /tmp/vibe-status-check-execcopy-bad.out >&2
  exit 1
fi
sed 's|vfsabi=000003FF/000003FF/00000200|vfsabi=000003FE/000003FF/00000200|' \
  "$DEVICE_OK" > "$DEVICE_BAD"
if "$CHECKER" --require-exec --require-preempt --require-vfs-abi --require-device-abi "$DEVICE_BAD" >/tmp/vibe-status-check-vfsabi-bad.out 2>&1; then
  echo "vibe_status_check accepted incomplete generic VFS ABI proof" >&2
  cat /tmp/vibe-status-check-vfsabi-bad.out >&2
  exit 1
fi
sed 's|fatabi=000001FF/000001FF/00000100/00000002/00000000|fatabi=000001BF/000001FF/00000100/00000002/00000000|' \
  "$DEVICE_OK" > "$DEVICE_BAD"
if "$CHECKER" --require-exec --require-preempt --require-vfs-abi --require-device-abi "$DEVICE_BAD" >/tmp/vibe-status-check-fatabi-bad.out 2>&1; then
  echo "vibe_status_check accepted incomplete generic FAT operation proof" >&2
  cat /tmp/vibe-status-check-fatabi-bad.out >&2
  exit 1
fi
sed 's|audabi=000001FF/000001FF/00000100/00000010|audabi=000001DF/000001FF/00000100/00000010|' \
  "$DEVICE_OK" > "$DEVICE_BAD"
if "$CHECKER" --require-exec --require-preempt --require-vfs-abi --require-device-abi "$DEVICE_BAD" >/tmp/vibe-status-check-audabi-bad.out 2>&1; then
  echo "vibe_status_check accepted incomplete generic audio ABI proof" >&2
  cat /tmp/vibe-status-check-audabi-bad.out >&2
  exit 1
fi
sed 's|fbabi=0000000F/0000000F/00000001/00000000/00000004|fbabi=0000000B/0000000F/00000001/00000000/00000004|' \
  "$DEVICE_OK" > "$DEVICE_BAD"
if "$CHECKER" --require-exec --require-preempt --require-vfs-abi --require-device-abi "$DEVICE_BAD" >/tmp/vibe-status-check-fbabi-bad.out 2>&1; then
  echo "vibe_status_check accepted incomplete generic framebuffer ABI proof" >&2
  cat /tmp/vibe-status-check-fbabi-bad.out >&2
  exit 1
fi
sed 's|preemptabi=000001FF/000001FF/00000100/00000001/00000001|preemptabi=000001DF/000001FF/00000100/00000001/00000001|' \
  "$DEVICE_OK" > "$DEVICE_BAD"
if "$CHECKER" --require-exec --require-preempt --require-vfs-abi --require-device-abi "$DEVICE_BAD" >/tmp/vibe-status-check-preemptabi-bad.out 2>&1; then
  echo "vibe_status_check accepted incomplete timer-preemption ABI proof" >&2
  cat /tmp/vibe-status-check-preemptabi-bad.out >&2
  exit 1
fi
sed 's|khabi=000007FF/000007FF/00000200/00000002/00000001|khabi=000003FF/000007FF/00000100/00000002/00000001|' \
  "$DEVICE_OK" > "$DEVICE_BAD"
if "$CHECKER" --require-exec --require-preempt --require-vfs-abi --require-device-abi "$DEVICE_BAD" >/tmp/vibe-status-check-khabi-bad.out 2>&1; then
  echo "vibe_status_check accepted incomplete higher-half kernel ABI proof" >&2
  cat /tmp/vibe-status-check-khabi-bad.out >&2
  exit 1
fi
sed 's|khdata=0000000A/00000200/00000400|khdata=0000000A/00000100/00000400|' \
  "$DEVICE_OK" > "$DEVICE_BAD"
if "$CHECKER" --require-exec --require-preempt --require-vfs-abi --require-device-abi "$DEVICE_BAD" >/tmp/vibe-status-check-khdata-bad.out 2>&1; then
  echo "vibe_status_check accepted low-identity higher-half data bookkeeping" >&2
  cat /tmp/vibe-status-check-khdata-bad.out >&2
  exit 1
fi
sed 's|krelabi=000003FF/000003FF/00000200/00000001/00000001|krelabi=000001FF/000003FF/00000100/00000001/00000001|' \
  "$DEVICE_OK" > "$DEVICE_BAD"
if "$CHECKER" --require-exec --require-preempt --require-vfs-abi --require-device-abi "$DEVICE_BAD" >/tmp/vibe-status-check-krelabi-bad.out 2>&1; then
  echo "vibe_status_check accepted incomplete relocation-directory ABI proof" >&2
  cat /tmp/vibe-status-check-krelabi-bad.out >&2
  exit 1
fi

for bad in \
  vm_status_krelhaz_bad_identity_return.txt \
  vm_status_krelhaz_bad_high_return.txt \
  vm_status_krelhaz_bad_mismatch.txt
do
  if "$CHECKER" "$ROOT/tests/fixtures/$bad" >/tmp/vibe-status-check-bad.out 2>&1; then
    echo "vibe_status_check accepted bad fixture: $bad" >&2
    cat /tmp/vibe-status-check-bad.out >&2
    exit 1
  fi
done

rm -f /tmp/vibe-status-check-bad.out
rm -f /tmp/vibe-status-check-devices-bad.out
rm -f /tmp/vibe-status-check-inabi-bad.out
rm -f /tmp/vibe-status-check-execcopy-bad.out
rm -f /tmp/vibe-status-check-vfsabi-bad.out
rm -f /tmp/vibe-status-check-fatabi-bad.out
rm -f /tmp/vibe-status-check-audabi-bad.out
rm -f /tmp/pi4-status-evidence-audio-bad.out
rm -f /tmp/pi4-status-evidence-audio-queue-bad.out
rm -f /tmp/pi4-framebuffer-artifact-bad.out
rm -f /tmp/pi4-status-evidence-hardware-bad.out
rm -f /tmp/pi4-status-evidence-incomplete.out
rm -f /tmp/pi4-status-evidence-local-qemu-bad.out
rm -f /tmp/pi4-status-evidence-local-qemu-class-bad.out
rm -f /tmp/pi4-status-evidence-local-qemu-final-class-bad.out
rm -f /tmp/pi4-status-evidence-local-qemu-input-class-bad.out
rm -f /tmp/pi4-status-evidence-launcher-claim-bad.out
rm -f /tmp/pi4-status-evidence-preempt-bad.out
rm -f /tmp/pi4-status-evidence-serial-last-bad.out
rm -f /tmp/pi4-status-evidence-storage-bad.out
rm -f /tmp/pi4-status-evidence-storage-missing-wad-bad.out
rm -f /tmp/pi4-status-evidence-storage-overclaim-bad.out
rm -f /tmp/pi4-status-evidence-storage-pak-claim-bad.out
rm -f /tmp/vibe-no-python-guard-bad.out
rm -f /tmp/vibe-pi4-asm-guard-bad.out
rm -f /tmp/vibe-pi4-single-artifact-guard-bad.out
rm -f /tmp/vibe-status-check-fbabi-bad.out
rm -f /tmp/vibe-status-check-final-gates-audio-bad.out
rm -f /tmp/vibe-status-check-final-gates-audio-implicit-bad.out
rm -f /tmp/vibe-status-check-final-gates-click-bad.out
rm -f /tmp/vibe-status-check-final-gates-doom-asset-bad.out
rm -f /tmp/vibe-status-check-final-gates-doom-launch-only-bad.out
rm -f /tmp/vibe-status-check-final-gates-framebuffer-bad.out
rm -f /tmp/vibe-status-check-final-gates-framebuffer-unchanged-bad.out
rm -f /tmp/vibe-status-check-final-gates-frame-progress-bad.out
rm -f /tmp/vibe-status-check-final-gates-local-qemu-bad.out
rm -f /tmp/vibe-status-check-final-gates-memory-bad.out
rm -f /tmp/vibe-status-check-final-gates-panic-bad.out
rm -f /tmp/vibe-status-check-final-gates-preempt-bad.out
rm -f /tmp/vibe-status-check-final-gates-process-bad.out
rm -f /tmp/vibe-status-check-final-gates-quake-asset-bad.out
rm -f /tmp/vibe-status-check-final-gates-quake-launch-only-bad.out
rm -f /tmp/vibe-status-check-final-gates-shutdown-bad.out
rm -f /tmp/vibe-status-check-final-gates-storage-pak-bad.out
rm -f /tmp/vibe-status-check-final-gates-storage-wad-bad.out
rm -f /tmp/vibe-status-check-launcher-claim-bad.out
rm -f /tmp/vibe-status-check-local-qemu-bad.out
rm -f /tmp/vibe-status-check-local-qemu-class-bad.out
rm -f /tmp/vibe-status-check-local-qemu-final-class-bad.out
rm -f /tmp/vibe-status-check-preemptabi-bad.out
rm -f /tmp/vibe-status-check-khabi-bad.out
rm -f /tmp/vibe-status-check-khdata-bad.out
rm -f /tmp/vibe-status-check-krelabi-bad.out
rm -f /tmp/vibe-status-check-pi4-bad.out
rm -f /tmp/vibe-status-check-single-artifact-bad.out
rm -f /tmp/vibe-status-check-storage-missing-wad-bad.out
rm -f /tmp/vibe-status-check-storage-overclaim-bad.out
rm -f /tmp/vibe-status-check-storage-pak-claim-bad.out
rm -f /tmp/pi4-status-evidence-exec-app-vfs-missing-bad.out
rm -f /tmp/vibe-status-check-exec-app-vfs-mismatch-bad.out
rm -f /tmp/vibe-status-check-exec-app-vfs-missing-bad.out
rm -f /tmp/vibe-status-check-x86-doom-bad.out
rm -f /tmp/vibe-status-check-x86-quake-bad.out
rm -f /tmp/vibe-status-check-x86-quake-kind-bad.out
if [ "$SCOPE" = "x86" ]; then
  echo "vibe_status_check x86 self-test OK"
else
  echo "vibe_status_check self-test OK"
fi
