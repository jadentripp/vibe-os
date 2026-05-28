#include <errno.h>
#include <fcntl.h>
#include <stdint.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/un.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

#define MAX_SERIAL_BYTES (1024u * 1024u)
#define MAX_FRAMEBUFFER_BYTES (64u * 1024u * 1024u)
#define STATUS_PREFIX "vibe-status"
#define STATUS_PREFIX_LEN 11u
#define WATCH_LINE_MAX 32768u
#define FNV64_OFFSET UINT64_C(14695981039346656037)
#define FNV64_PRIME UINT64_C(1099511628211)
#define HMP_FRAME0_CAPTURE_MS 1500u
#define HMP_INPUT_START_MS 1750u
#define HMP_INPUT_DEFAULT_DELAY_MS 500u
#define HMP_KEY_HOLD_MS 750u
#define HMP_LAUNCHER_FRAME_SETTLE_MS 1500u
#define HMP_FRAME1_SETTLE_MS 500u
#define HMP_SCREEN_DUMP_WAIT_MS 3000u

struct framebuffer_frame_info {
    unsigned width;
    unsigned height;
    size_t image_bytes;
    size_t pixel_bytes;
    uint64_t hash;
    uint64_t pixel_hash;
    int nonblank;
};

static int connect_monitor_once(const char* monitor_path);
static int send_monitor_key(int monitor_fd, char key);
static int send_screendump(int monitor_fd, const char* frame_path);
static int send_screendump_and_wait(int monitor_fd, const char* frame_path);
static int write_all(int fd, const char* data, size_t size);
static int set_nonblock(int fd);
static int parse_long_strict(const char* text, long min_value, long max_value,
    long* out);

static void usage(const char* argv0)
{
    fprintf(stderr, "usage: %s [--exec] QEMU SERIAL KERNEL8_IMG PI4_FAT16_IMAGE\n", argv0);
    fprintf(stderr, "       %s --live QEMU SERIAL KERNEL8_IMG PI4_FAT16_IMAGE\n", argv0);
    fprintf(stderr, "       %s --live-command QEMU SERIAL KERNEL8_IMG PI4_FAT16_IMAGE\n", argv0);
    fprintf(stderr, "       %s --live-smoke SECONDS QEMU SERIAL KERNEL8_IMG PI4_FAT16_IMAGE\n", argv0);
    fprintf(stderr, "       %s --local-smoke SECONDS RAW_STATUS MARKED_STATUS QEMU file:SERIAL KERNEL8_IMG PI4_FAT16_IMAGE\n", argv0);
    fprintf(stderr, "       %s --local-input-smoke SECONDS INPUT RAW_STATUS MARKED_STATUS SERIAL_CAPTURE QEMU KERNEL8_IMG PI4_FAT16_IMAGE\n", argv0);
    fprintf(stderr, "       %s --local-input-framebuffer-smoke SECONDS INPUT RAW_STATUS MARKED_STATUS SERIAL_CAPTURE FRAMEBUFFER_REPORT FRAME0_PPM FRAME1_PPM QEMU KERNEL8_IMG PI4_FAT16_IMAGE\n", argv0);
    fprintf(stderr, "       %s --framebuffer-artifact-check FRAMEBUFFER_REPORT FRAME0_PPM FRAME1_PPM\n", argv0);
}

static int local_vm_allowed(void)
{
    const char* allow = getenv("ALLOW_LOCAL_VM");

    return allow && strcmp(allow, "1") == 0;
}

static int shell_safe_char(char c)
{
    return (c >= 'A' && c <= 'Z') ||
        (c >= 'a' && c <= 'z') ||
        (c >= '0' && c <= '9') ||
        c == '_' || c == '-' || c == '.' || c == '/' || c == ':' ||
        c == ',' || c == '=' || c == '+' || c == '@' || c == '%';
}

static void print_shell_arg(const char* arg)
{
    const char* p = arg;
    int safe = *p != '\0';

    for (; *p; p++) {
        if (!shell_safe_char(*p)) {
            safe = 0;
            break;
        }
    }
    if (safe) {
        fputs(arg, stdout);
        return;
    }

    fputc('\'', stdout);
    for (p = arg; *p; p++) {
        if (*p == '\'') {
            fputs("'\\''", stdout);
        } else {
            fputc(*p, stdout);
        }
    }
    fputc('\'', stdout);
}

static char* make_drive_arg(const char* image)
{
    const char prefix[] = "file=";
    const char suffix[] = ",if=sd,format=raw";
    size_t len = sizeof(prefix) - 1u + strlen(image) + sizeof(suffix);
    char* out = (char*)malloc(len);

    if (!out) {
        fprintf(stderr, "pi4_qemu_command: out of memory\n");
        exit(2);
    }
    snprintf(out, len, "%s%s%s", prefix, image, suffix);
    return out;
}

static char* join_suffix(const char* text, const char* suffix)
{
    size_t len = strlen(text) + strlen(suffix) + 1u;
    char* out = (char*)malloc(len);

    if (!out) {
        fprintf(stderr, "pi4_qemu_command: out of memory\n");
        exit(2);
    }
    snprintf(out, len, "%s%s", text, suffix);
    return out;
}

static char* make_monitor_arg(const char* monitor_path)
{
    const char prefix[] = "unix:";
    const char suffix[] = ",server,nowait";
    size_t len = sizeof(prefix) - 1u + strlen(monitor_path) + sizeof(suffix);
    char* out = (char*)malloc(len);

    if (!out) {
        fprintf(stderr, "pi4_qemu_command: out of memory\n");
        exit(2);
    }
    snprintf(out, len, "%s%s%s", prefix, monitor_path, suffix);
    return out;
}

static void require_nonempty_file(const char* label, const char* path)
{
    struct stat st;

    if (stat(path, &st) != 0) {
        fprintf(stderr, "pi4_qemu_command: missing %s %s: %s\n",
            label, path, strerror(errno));
        exit(1);
    }
    if (!S_ISREG(st.st_mode)) {
        fprintf(stderr, "pi4_qemu_command: %s is not a regular file: %s\n",
            label, path);
        exit(1);
    }
    if (st.st_size <= 0) {
        fprintf(stderr, "pi4_qemu_command: %s is empty: %s\n", label, path);
        exit(1);
    }
}

static unsigned parse_seconds(const char* text)
{
    char* end = NULL;
    unsigned long value = strtoul(text, &end, 10);

    if (!text[0] || *end || value > 3600ul) {
        fprintf(stderr, "pi4_qemu_command: invalid local smoke seconds: %s\n", text);
        exit(2);
    }
    return (unsigned)value;
}

static void print_command(char* const* cmd)
{
    size_t i;

    for (i = 0; cmd[i]; i++) {
        if (i != 0u) {
            fputc(' ', stdout);
        }
        print_shell_arg(cmd[i]);
    }
    fputc('\n', stdout);
}

static const char* visible_display_arg(void)
{
    const char* env = getenv("PI4_QEMU_DISPLAY");

    if (env && env[0])
        return env;
#ifdef __APPLE__
    return "cocoa,zoom-to-fit=on,full-screen=on";
#elif defined(__linux__)
    return "gtk,zoom-to-fit=on,full-screen=on";
#else
    return NULL;
#endif
}

static int env_flag_enabled(const char* name, int default_enabled)
{
    const char* env = getenv(name);

    if (!env || !env[0])
        return default_enabled;
    return strcmp(env, "0") != 0;
}

static int live_mouse_serial_enabled(int usb_mouse)
{
    return env_flag_enabled("PI4_QEMU_MOUSE_SERIAL", !usb_mouse);
}

static int live_usb_keyboard_enabled(void)
{
    const char* env = getenv("PI4_QEMU_USB_KEYBOARD");

    if (env && env[0])
        return strcmp(env, "0") != 0;
    return 1;
}

static int live_usb_mouse_enabled(void)
{
    return env_flag_enabled("PI4_QEMU_USB_MOUSE", 1);
}

static int input_smoke_visible_display_enabled(void)
{
    return env_flag_enabled("PI4_QEMU_INPUT_SMOKE_DISPLAY", 0);
}

static unsigned hmp_key_hold_ms(void)
{
    const char* env = getenv("PI4_QEMU_HMP_KEY_HOLD_MS");
    long parsed = 0;

    if (env && env[0] && parse_long_strict(env, 1, 10000, &parsed))
        return (unsigned)parsed;
    return HMP_KEY_HOLD_MS;
}

static unsigned framebuffer_frame1_settle_ms(void)
{
    const char* env = getenv("PI4_QEMU_FRAME1_SETTLE_MS");
    long parsed = 0;

    if (env && env[0] && parse_long_strict(env, 0, 300000, &parsed))
        return (unsigned)parsed;
    if (env && env[0]) {
        fprintf(stderr, "pi4_qemu_command: invalid PI4_QEMU_FRAME1_SETTLE_MS=%s\n",
            env);
        exit(2);
    }
    return HMP_FRAME1_SETTLE_MS;
}

static void build_command(char* const* argv, char* drive_arg, char** cmd,
    int visible_display, int force_usb_input, const char* monitor_arg,
    int* out_n)
{
    int n = 0;
    const char* display_arg = visible_display ? visible_display_arg() : NULL;
    int usb_input = visible_display || force_usb_input;
    int usb_mouse = force_usb_input ? live_usb_mouse_enabled() :
        (visible_display && live_usb_mouse_enabled());
    int mouse_serial = visible_display && live_mouse_serial_enabled(usb_mouse);
    int usb_keyboard = force_usb_input ? live_usb_keyboard_enabled() :
        (visible_display && live_usb_keyboard_enabled());

    cmd[n++] = argv[0];
    cmd[n++] = "-accel";
    cmd[n++] = "tcg,thread=multi";
    cmd[n++] = "-M";
    cmd[n++] = usb_input ? "raspi4b,usb=on" : "raspi4b";
    cmd[n++] = "-cpu";
    cmd[n++] = "cortex-a72";
    cmd[n++] = "-m";
    cmd[n++] = "2G";
    cmd[n++] = "-kernel";
    cmd[n++] = argv[2];
    cmd[n++] = "-drive";
    cmd[n++] = drive_arg;
    cmd[n++] = "-serial";
    cmd[n++] = argv[1];
    if (mouse_serial) {
        cmd[n++] = "-serial";
        cmd[n++] = "msmouse";
    }
    if (visible_display && display_arg) {
        cmd[n++] = "-display";
        cmd[n++] = (char*)display_arg;
    } else if (!visible_display) {
        cmd[n++] = "-display";
        cmd[n++] = "none";
    }
    if (usb_keyboard) {
        cmd[n++] = "-device";
        cmd[n++] = "usb-kbd,display=default";
    }
    if (usb_mouse) {
        cmd[n++] = "-device";
        cmd[n++] = "usb-mouse";
    }
    cmd[n++] = "-monitor";
    cmd[n++] = monitor_arg ? (char*)monitor_arg : "none";
    cmd[n++] = "-no-reboot";
    cmd[n++] = "-no-shutdown";
    cmd[n] = NULL;
    *out_n = n;
}

static void exec_command_or_die(char* const* cmd)
{
    execvp(cmd[0], cmd);
    fprintf(stderr, "pi4_qemu_command: exec %s failed: %s\n", cmd[0], strerror(errno));
    _exit(errno == ENOENT ? 127 : 126);
}

static int run_command_for_seconds(char* const* cmd, unsigned seconds)
{
    pid_t pid = fork();
    unsigned elapsed = 0;
    int status = 0;

    if (pid < 0) {
        fprintf(stderr, "pi4_qemu_command: fork failed: %s\n", strerror(errno));
        return 2;
    }
    if (pid == 0)
        exec_command_or_die(cmd);

    while (elapsed < seconds) {
        pid_t got = waitpid(pid, &status, WNOHANG);
        if (got == pid)
            return 0;
        if (got < 0) {
            if (errno == EINTR)
                continue;
            fprintf(stderr, "pi4_qemu_command: waitpid failed: %s\n", strerror(errno));
            return 2;
        }
        sleep(1);
        elapsed++;
    }

    kill(pid, SIGTERM);
    sleep(1);
    for (;;) {
        pid_t got = waitpid(pid, &status, WNOHANG);

        if (got == pid)
            return 0;
        if (got == 0) {
            kill(pid, SIGKILL);
            break;
        }
        if (got < 0) {
            if (errno == EINTR)
                continue;
            if (errno == ECHILD)
                return 0;
            fprintf(stderr, "pi4_qemu_command: waitpid after SIGTERM failed: %s\n",
                strerror(errno));
            return 2;
        }
    }
    while (waitpid(pid, &status, 0) < 0) {
        if (errno != EINTR) {
            if (errno == ECHILD)
                return 0;
            fprintf(stderr, "pi4_qemu_command: waitpid after kill failed: %s\n", strerror(errno));
            return 2;
        }
    }
    return 0;
}

static void sleep_millis(unsigned millis)
{
    struct timespec req;

    req.tv_sec = millis / 1000u;
    req.tv_nsec = (long)(millis % 1000u) * 1000000l;
    while (nanosleep(&req, &req) < 0) {
        if (errno != EINTR)
            break;
    }
}

static int wait_for_file_stable(const char* path, unsigned timeout_ms)
{
    unsigned elapsed_ms = 0;
    off_t last_size = -1;
    unsigned stable_polls = 0;

    while (elapsed_ms <= timeout_ms) {
        struct stat st;

        if (stat(path, &st) == 0 && st.st_size > 0) {
            if (st.st_size == last_size) {
                stable_polls++;
                if (stable_polls >= 2u)
                    return 0;
            } else {
                last_size = st.st_size;
                stable_polls = 0;
            }
        }
        sleep_millis(50u);
        elapsed_ms += 50u;
    }
    fprintf(stderr, "pi4_qemu_command: timed out waiting for screendump %s\n", path);
    return 2;
}

static int is_status_line(const char* line, const char* end);
static char* copy_line(const char* line, const char* end);

struct status_line_watch {
    char line[WATCH_LINE_MAX];
    size_t line_len;
    int line_started_after_input;
    int launcher_ready;
    int seen_after_input;
    char* ready_status;
};

static int line_has_token_value(const char* line, const char* token)
{
    size_t token_len = strlen(token);
    const char* p = line;

    while ((p = strstr(p, token)) != NULL) {
        if ((p == line || p[-1] == ' ' || p[-1] == '\t') &&
            (p[token_len] == '\0' || p[token_len] == ' ' ||
                p[token_len] == '\t' || p[token_len] == '\r' ||
                p[token_len] == '\n'))
            return 1;
        p++;
    }
    return 0;
}

static int field_has_nonzero_hex(const char* line, const char* key)
{
    size_t key_len = strlen(key);
    const char* p = line;

    while (*p) {
        while (*p == ' ' || *p == '\t')
            p++;
        if (strncmp(p, key, key_len) == 0 && p[key_len] == '=') {
            p += key_len + 1u;
            while (*p && *p != ' ' && *p != '\t' &&
                *p != '\r' && *p != '\n') {
                if ((*p >= '1' && *p <= '9') ||
                    (*p >= 'a' && *p <= 'f') ||
                    (*p >= 'A' && *p <= 'F'))
                    return 1;
                p++;
            }
            return 0;
        }
        while (*p && *p != ' ' && *p != '\t')
            p++;
    }
    return 0;
}

static int line_pi4userfile_has_magic(const char* line, const char* magic)
{
    const char* field = strstr(line, "pi4userfile=");
    const char* end = NULL;
    const char* found = NULL;

    if (!field)
        return 0;
    end = field;
    while (*end && *end != ' ' && *end != '\t' &&
        *end != '\r' && *end != '\n')
        end++;
    found = strstr(field, magic);
    return found && found < end;
}

static int line_has_pi4_user_file_asset_magic(const char* line)
{
    return line_pi4userfile_has_magic(line, "0x0000000044415749") ||
        line_pi4userfile_has_magic(line, "0x0000000044415750") ||
        line_pi4userfile_has_magic(line, "0x000000004b434150") ||
        line_pi4userfile_has_magic(line, "0x000000004B434150");
}

static int line_has_pi4_user_file_full_ops(const char* line)
{
    const char* field = strstr(line, "pi4userfile=0x0000000000000007/");
    return field != NULL;
}

static int line_has_pi4_user_file_selected_asset_magic(const char* line)
{
    if (strstr(line, "path=PAYLOAD1.ELF") || strstr(line, "upath=PAYLOAD1.ELF") ||
        strstr(line, "path=/APPS/QUAKE/APP.ELF") ||
        strstr(line, "upath=/APPS/QUAKE/APP.ELF"))
        return line_pi4userfile_has_magic(line, "0x000000004b434150") ||
            line_pi4userfile_has_magic(line, "0x000000004B434150");
    if (strstr(line, "path=PAYLOAD0.ELF") || strstr(line, "upath=PAYLOAD0.ELF") ||
        strstr(line, "path=/APPS/DOOM/APP.ELF") ||
        strstr(line, "upath=/APPS/DOOM/APP.ELF"))
        return line_pi4userfile_has_magic(line, "0x0000000044415749") ||
            line_pi4userfile_has_magic(line, "0x0000000044415750");
    return line_has_pi4_user_file_asset_magic(line);
}

static int line_has_pi4_app_exec_path(const char* line)
{
    return strstr(line, "path=/APPS/DOOM/APP.ELF") ||
        strstr(line, "upath=/APPS/DOOM/APP.ELF") ||
        strstr(line, "path=/APPS/QUAKE/APP.ELF") ||
        strstr(line, "upath=/APPS/QUAKE/APP.ELF");
}

static int line_fbchange_proves_changed_frame(const char* line)
{
    const char* field = line;

    while ((field = strstr(field, "fbchange=")) != NULL) {
        const char* p = field + strlen("fbchange=");
        uint64_t value[4];
        size_t i;

        if (field != line && field[-1] != ' ' && field[-1] != '\t') {
            field++;
            continue;
        }
        for (i = 0; i < 4u; i++) {
            char* end = NULL;
            unsigned long long parsed = strtoull(p, &end, 0);
            if (end == p)
                return 0;
            value[i] = (uint64_t)parsed;
            if (i < 3u) {
                if (*end != '/')
                    return 0;
                p = end + 1;
            } else if (*end != '\0' && *end != ' ' && *end != '\t' &&
                *end != '\r' && *end != '\n') {
                return 0;
            }
        }
        return value[0] != 0u && value[1] != 0u && value[0] != value[1] &&
            value[2] != 0u && value[3] != 0u;
    }
    return 0;
}

static int status_line_reflects_scripted_input(const char* line)
{
    return line_has_token_value(line, "pi4exec=OK") &&
        (strstr(line, "path=PAYLOAD") != NULL ||
            strstr(line, "path=/APPS/") != NULL ||
            field_has_nonzero_hex(line, "pi4payloadreq")) &&
        field_has_nonzero_hex(line, "pi4inputevt") &&
        field_has_nonzero_hex(line, "pi4payloadvfs") &&
        (line_has_pi4_user_file_full_ops(line) ||
            line_has_pi4_app_exec_path(line)) &&
        (line_has_pi4_user_file_selected_asset_magic(line) ||
            line_has_pi4_app_exec_path(line)) &&
        line_fbchange_proves_changed_frame(line) &&
        line_has_token_value(line, "pi4runtime=OK") &&
        line_has_token_value(line, "panic=NONE") &&
        line_has_token_value(line, "shutdown=NONE");
}

static int status_line_reflects_launcher_ready(const char* line)
{
    return line_has_token_value(line, "pi4runtime=OK") &&
        line_has_token_value(line, "exec=OK") &&
        line_has_token_value(line, "path=INIT.ELF") &&
        line_has_token_value(line, "uexec=OK") &&
        line_has_token_value(line, "upath=INIT.ELF") &&
        line_has_token_value(line, "pi4fb=OK") &&
        line_has_token_value(line, "pi4vfs=OK") &&
        line_has_token_value(line, "panic=NONE") &&
        line_has_token_value(line, "shutdown=NONE");
}

static int watched_line_is_ready_status(const struct status_line_watch* watch)
{
    if (!watch->line_started_after_input || watch->line_len < STATUS_PREFIX_LEN)
        return 0;
    if (!is_status_line(watch->line, watch->line + watch->line_len))
        return 0;
    return status_line_reflects_scripted_input(watch->line);
}

static void status_line_watch_feed(struct status_line_watch* watch,
    const char* data, size_t size, int input_sent)
{
    size_t i;

    for (i = 0; i < size; i++) {
        char c = data[i];

        if (watch->line_len == 0u)
            watch->line_started_after_input = input_sent;
        if (watch->line_len + 1u < sizeof(watch->line)) {
            watch->line[watch->line_len] = c;
            watch->line[watch->line_len + 1u] = '\0';
        }
        watch->line_len++;
        if (c == '\n' || c == '\r') {
            if (is_status_line(watch->line, watch->line + watch->line_len) &&
                status_line_reflects_launcher_ready(watch->line))
                watch->launcher_ready = 1;
            if (watched_line_is_ready_status(watch)) {
                free(watch->ready_status);
                watch->ready_status = copy_line(watch->line,
                    watch->line + watch->line_len);
                watch->seen_after_input = 1;
            }
            watch->line_len = 0u;
            watch->line[0] = '\0';
            watch->line_started_after_input = input_sent;
        }
    }
}

static int append_available_serial(int fd, FILE* out,
    struct status_line_watch* watch, int input_sent)
{
    char buffer[4096];

    for (;;) {
        ssize_t got = read(fd, buffer, sizeof(buffer));

        if (got > 0) {
            if (fwrite(buffer, 1u, (size_t)got, out) != (size_t)got) {
                fprintf(stderr, "pi4_qemu_command: serial capture write failed\n");
                return 2;
            }
            if (watch)
                status_line_watch_feed(watch, buffer, (size_t)got, input_sent);
            continue;
        }
        if (got == 0)
            return 0;
        if (errno == EINTR)
            continue;
        if (errno == EAGAIN || errno == EWOULDBLOCK)
            return 0;
        fprintf(stderr, "pi4_qemu_command: serial pipe read failed: %s\n", strerror(errno));
        return 2;
    }
}

static int write_input_script(int fd, const char* input, size_t* sent)
{
    size_t len = strlen(input);

    while (*sent < len) {
        ssize_t wrote = write(fd, input + *sent, len - *sent);

        if (wrote > 0) {
            *sent += (size_t)wrote;
            continue;
        }
        if (wrote == 0)
            return 0;
        if (errno == EINTR)
            continue;
        if (errno == EAGAIN || errno == EWOULDBLOCK)
            return 0;
        if (errno == EPIPE)
            return 0;
        fprintf(stderr, "pi4_qemu_command: serial input write failed: %s\n", strerror(errno));
        return 2;
    }
    return 0;
}

static int parse_long_strict(const char* text, long min_value, long max_value,
    long* out)
{
    char* end = NULL;
    long value;

    if (!text[0])
        return 0;
    errno = 0;
    value = strtol(text, &end, 10);
    if (errno || *end || value < min_value || value > max_value)
        return 0;
    *out = value;
    return 1;
}

static int input_uses_hmp_actions(const char* input)
{
    return strchr(input, '=') != NULL;
}

static int hmp_key_token_is_safe(const char* token)
{
    const unsigned char* p = (const unsigned char*)token;

    if (!*p)
        return 0;
    for (; *p; p++) {
        if ((*p >= 'A' && *p <= 'Z') ||
            (*p >= 'a' && *p <= 'z') ||
            (*p >= '0' && *p <= '9') ||
            *p == '-' || *p == '_' || *p == '.')
            continue;
        return 0;
    }
    return 1;
}

static int send_monitor_key_token(int monitor_fd, const char* token)
{
    char command[80];
    int n;

    if (!hmp_key_token_is_safe(token)) {
        fprintf(stderr, "pi4_qemu_command: unsafe HMP sendkey token: %s\n", token);
        return 2;
    }
    n = snprintf(command, sizeof(command), "sendkey %s %u\n", token,
        hmp_key_hold_ms());
    if (n < 0 || (size_t)n >= sizeof(command)) {
        fprintf(stderr, "pi4_qemu_command: sendkey command is too long\n");
        return 2;
    }
    return write_all(monitor_fd, command, (size_t)n);
}

static int send_monitor_key_name(int monitor_fd, const char* name)
{
    if (name[0] && !name[1])
        return send_monitor_key(monitor_fd, name[0]);
    if (strcmp(name, "space") == 0)
        name = "spc";
    else if (strcmp(name, "enter") == 0 || strcmp(name, "return") == 0)
        name = "ret";
    else if (strcmp(name, "escape") == 0)
        name = "esc";
    return send_monitor_key_token(monitor_fd, name);
}

static int send_monitor_text(int monitor_fd, const char* text)
{
    const char* p;

    if (!text[0]) {
        fprintf(stderr, "pi4_qemu_command: empty HMP text action\n");
        return 2;
    }
    for (p = text; *p; p++) {
        if (send_monitor_key(monitor_fd, *p) != 0)
            return 2;
    }
    return 0;
}

static int send_monitor_mouse_move(int monitor_fd, const char* value)
{
    const char* sep = strchr(value, ':');
    char dx_text[32];
    char dy_text[32];
    char command[96];
    long dx;
    long dy;
    int n;

    if (!sep || strchr(sep + 1, ':') ||
        (size_t)(sep - value) >= sizeof(dx_text) ||
        strlen(sep + 1) >= sizeof(dy_text)) {
        fprintf(stderr, "pi4_qemu_command: mouse action must be mouse=DX:DY\n");
        return 2;
    }
    memcpy(dx_text, value, (size_t)(sep - value));
    dx_text[sep - value] = '\0';
    strcpy(dy_text, sep + 1);
    if (!parse_long_strict(dx_text, -32768, 32767, &dx) ||
        !parse_long_strict(dy_text, -32768, 32767, &dy)) {
        fprintf(stderr, "pi4_qemu_command: mouse action has invalid delta: %s\n", value);
        return 2;
    }
    n = snprintf(command, sizeof(command), "mouse_move %ld %ld\n", dx, dy);
    if (n < 0 || (size_t)n >= sizeof(command)) {
        fprintf(stderr, "pi4_qemu_command: mouse_move command is too long\n");
        return 2;
    }
    return write_all(monitor_fd, command, (size_t)n);
}

static int send_monitor_mouse_button(int monitor_fd, const char* value)
{
    char command[64];
    long buttons;
    int n;

    if (!parse_long_strict(value, 0, 7, &buttons)) {
        fprintf(stderr, "pi4_qemu_command: mouse button action must be 0..7: %s\n",
            value);
        return 2;
    }
    n = snprintf(command, sizeof(command), "mouse_button %ld\n", buttons);
    if (n < 0 || (size_t)n >= sizeof(command)) {
        fprintf(stderr, "pi4_qemu_command: mouse_button command is too long\n");
        return 2;
    }
    return write_all(monitor_fd, command, (size_t)n);
}

static int send_monitor_input_action(int monitor_fd, const char* input,
    size_t* offset, unsigned* delay_ms)
{
    size_t len = strlen(input);
    size_t start;
    size_t end;
    char action[256];
    char* eq;
    long pause_ms;

    *delay_ms = HMP_INPUT_DEFAULT_DELAY_MS;
    if (!input_uses_hmp_actions(input)) {
        if (*offset >= len)
            return 0;
        if (send_monitor_key(monitor_fd, input[*offset]) != 0)
            return 2;
        (*offset)++;
        return 0;
    }

    while (*offset < len &&
        (input[*offset] == ',' || input[*offset] == ';' ||
         input[*offset] == ' ' || input[*offset] == '\t'))
        (*offset)++;
    if (*offset >= len)
        return 0;

    start = *offset;
    while (*offset < len && input[*offset] != ',' && input[*offset] != ';')
        (*offset)++;
    end = *offset;
    while (start < end && (input[start] == ' ' || input[start] == '\t'))
        start++;
    while (end > start &&
        (input[end - 1u] == ' ' || input[end - 1u] == '\t'))
        end--;
    if (end == start || end - start >= sizeof(action)) {
        fprintf(stderr, "pi4_qemu_command: invalid HMP input action\n");
        return 2;
    }
    memcpy(action, input + start, end - start);
    action[end - start] = '\0';

    eq = strchr(action, '=');
    if (!eq || eq == action || !eq[1]) {
        fprintf(stderr, "pi4_qemu_command: HMP input action must be name=value: %s\n",
            action);
        return 2;
    }
    *eq = '\0';
    if (strcmp(action, "text") == 0)
        return send_monitor_text(monitor_fd, eq + 1);
    if (strcmp(action, "key") == 0 || strcmp(action, "sendkey") == 0)
        return send_monitor_key_name(monitor_fd, eq + 1);
    if (strcmp(action, "mouse") == 0 || strcmp(action, "mousemove") == 0)
        return send_monitor_mouse_move(monitor_fd, eq + 1);
    if (strcmp(action, "mousebtn") == 0 ||
        strcmp(action, "mousebutton") == 0)
        return send_monitor_mouse_button(monitor_fd, eq + 1);
    if (strcmp(action, "wait") == 0 || strcmp(action, "pause") == 0) {
        if (!parse_long_strict(eq + 1, 1, 10000, &pause_ms)) {
            fprintf(stderr, "pi4_qemu_command: wait action must be 1..10000 ms: %s\n",
                eq + 1);
            return 2;
        }
        *delay_ms = (unsigned)pause_ms;
        return 0;
    }

    fprintf(stderr, "pi4_qemu_command: unknown HMP input action: %s\n", action);
    return 2;
}

static void terminate_child(pid_t pid)
{
    int status;

    kill(pid, SIGTERM);
    sleep_millis(250u);
    for (;;) {
        pid_t got = waitpid(pid, &status, WNOHANG);

        if (got == pid)
            return;
        if (got == 0) {
            kill(pid, SIGKILL);
            break;
        }
        if (got < 0) {
            if (errno == EINTR)
                continue;
            return;
        }
    }
    while (waitpid(pid, &status, 0) < 0) {
        if (errno != EINTR)
            return;
    }
}

static int run_command_with_pipe_input(char* const* cmd, unsigned seconds,
    const char* input, const char* pipe_base, const char* serial_capture_path,
    const char* monitor_path, const char* frame0_path, const char* frame1_path,
    int monitor_input, char** ready_status_out)
{
    char* in_path = join_suffix(pipe_base, ".in");
    char* out_path = join_suffix(pipe_base, ".out");
    int to_child[2] = { -1, -1 };
    int from_child[2] = { -1, -1 };
    FILE* capture = NULL;
    pid_t pid;
    int in_fd = -1;
    int out_fd = -1;
    int monitor_fd = -1;
    int status = 0;
    unsigned elapsed_ms = 0;
    unsigned limit_ms = seconds * 1000u;
    size_t sent = 0;
    size_t input_len = strlen(input);
    unsigned next_input_ms = monitor_input ? HMP_INPUT_START_MS : 1000u;
    unsigned launcher_frame_ready_ms = 0;
    unsigned frame1_ready_ms = 0;
    int child_done = 0;
    int frame0_done = 0;
    int frame1_done = 0;
    int launcher_frame_armed = 0;
    int frame1_armed = 0;
    int launcher_ready_reported = 0;
    int input_reported = 0;
    struct status_line_watch watch;

    if (ready_status_out)
        *ready_status_out = NULL;
    memset(&watch, 0, sizeof(watch));

    unlink(in_path);
    unlink(out_path);
    if (monitor_path) {
        unlink(monitor_path);
        if (frame0_path)
            unlink(frame0_path);
        if (frame1_path)
            unlink(frame1_path);
    }
    if (pipe(to_child) != 0 || pipe(from_child) != 0) {
        fprintf(stderr, "pi4_qemu_command: pipe failed: %s\n", strerror(errno));
        if (to_child[0] >= 0)
            close(to_child[0]);
        if (to_child[1] >= 0)
            close(to_child[1]);
        if (from_child[0] >= 0)
            close(from_child[0]);
        if (from_child[1] >= 0)
            close(from_child[1]);
        free(in_path);
        free(out_path);
        return 2;
    }
    if (set_nonblock(to_child[1]) != 0 || set_nonblock(from_child[0]) != 0) {
        fprintf(stderr, "pi4_qemu_command: failed to configure QEMU stdio pipes\n");
        close(to_child[0]);
        close(to_child[1]);
        close(from_child[0]);
        close(from_child[1]);
        free(in_path);
        free(out_path);
        return 2;
    }

    capture = fopen(serial_capture_path, "wb");
    if (!capture) {
        fprintf(stderr, "pi4_qemu_command: %s: %s\n", serial_capture_path, strerror(errno));
        close(to_child[0]);
        close(to_child[1]);
        close(from_child[0]);
        close(from_child[1]);
        unlink(in_path);
        unlink(out_path);
        free(in_path);
        free(out_path);
        return 2;
    }

    pid = fork();
    if (pid < 0) {
        fprintf(stderr, "pi4_qemu_command: fork failed: %s\n", strerror(errno));
        fclose(capture);
        close(to_child[0]);
        close(to_child[1]);
        close(from_child[0]);
        close(from_child[1]);
        unlink(in_path);
        unlink(out_path);
        free(in_path);
        free(out_path);
        return 2;
    }
    if (pid == 0) {
        close(to_child[1]);
        close(from_child[0]);
        if (dup2(to_child[0], STDIN_FILENO) < 0 ||
            dup2(from_child[1], STDOUT_FILENO) < 0)
            _exit(126);
        close(to_child[0]);
        close(from_child[1]);
        exec_command_or_die(cmd);
    }
    close(to_child[0]);
    close(from_child[1]);
    in_fd = to_child[1];
    out_fd = from_child[0];

    while (elapsed_ms < limit_ms) {
        pid_t got;

        if (out_fd < 0) {
            out_fd = open(out_path, O_RDONLY | O_NONBLOCK);
            if (out_fd < 0 && errno != ENXIO && errno != ENOENT) {
                fprintf(stderr, "pi4_qemu_command: open %s failed: %s\n", out_path, strerror(errno));
                terminate_child(pid);
                fclose(capture);
                unlink(in_path);
                unlink(out_path);
                free(watch.ready_status);
                free(in_path);
                free(out_path);
                return 2;
            }
        }
        if (in_fd < 0) {
            in_fd = open(in_path, O_RDWR | O_NONBLOCK);
            if (in_fd < 0 && errno != ENXIO && errno != ENOENT) {
                fprintf(stderr, "pi4_qemu_command: open %s failed: %s\n", in_path, strerror(errno));
                terminate_child(pid);
                fclose(capture);
                if (out_fd >= 0)
                    close(out_fd);
                unlink(in_path);
                unlink(out_path);
                free(watch.ready_status);
                free(in_path);
                free(out_path);
                return 2;
            }
        }
        if (monitor_path && monitor_fd < 0)
            monitor_fd = connect_monitor_once(monitor_path);
        if (monitor_input && monitor_fd >= 0 && !frame0_done &&
            watch.launcher_ready && !launcher_frame_armed) {
            launcher_frame_ready_ms = elapsed_ms + HMP_LAUNCHER_FRAME_SETTLE_MS;
            launcher_frame_armed = 1;
        }
        if (monitor_fd >= 0 && !frame0_done &&
            ((!monitor_input && elapsed_ms >= HMP_FRAME0_CAPTURE_MS) ||
                (monitor_input && launcher_frame_armed &&
                    elapsed_ms >= launcher_frame_ready_ms))) {
            if (send_screendump_and_wait(monitor_fd, frame0_path) != 0) {
                terminate_child(pid);
                fclose(capture);
                if (in_fd >= 0)
                    close(in_fd);
                if (out_fd >= 0)
                    close(out_fd);
                close(monitor_fd);
                unlink(in_path);
                unlink(out_path);
                unlink(monitor_path);
                free(watch.ready_status);
                free(in_path);
                free(out_path);
                return 2;
            }
            frame0_done = 1;
            if (monitor_input && next_input_ms < elapsed_ms + 250u)
                next_input_ms = elapsed_ms + 250u;
        }
        if (out_fd >= 0 &&
            append_available_serial(out_fd, capture, &watch,
                sent >= input_len) != 0) {
            terminate_child(pid);
            fclose(capture);
            if (in_fd >= 0)
                close(in_fd);
            close(out_fd);
            if (monitor_fd >= 0)
                close(monitor_fd);
            unlink(in_path);
            unlink(out_path);
            if (monitor_path)
                unlink(monitor_path);
            free(watch.ready_status);
            free(in_path);
            free(out_path);
            return 2;
        }
        if (watch.launcher_ready && !launcher_ready_reported) {
            fprintf(stderr, "pi4_qemu_command: launcher ready; starting scripted input when pipe is writable\n");
            launcher_ready_reported = 1;
        }
        if (monitor_input && frame0_done && watch.launcher_ready &&
            elapsed_ms >= next_input_ms && sent < input_len) {
            if (monitor_fd >= 0) {
                unsigned delay_ms = HMP_INPUT_DEFAULT_DELAY_MS;

                if (send_monitor_input_action(monitor_fd, input, &sent,
                        &delay_ms) != 0) {
                    terminate_child(pid);
                    fclose(capture);
                    if (in_fd >= 0)
                        close(in_fd);
                    if (out_fd >= 0)
                        close(out_fd);
                    close(monitor_fd);
                    unlink(in_path);
                    unlink(out_path);
                    if (monitor_path)
                        unlink(monitor_path);
                    free(watch.ready_status);
                    free(in_path);
                    free(out_path);
                    return 2;
                }
                next_input_ms = elapsed_ms + delay_ms;
            }
        } else if (!monitor_input && (!monitor_path || watch.launcher_ready) &&
            elapsed_ms >= 1000u && in_fd >= 0 && sent < input_len) {
            size_t before = sent;

            if (write_input_script(in_fd, input, &sent) != 0) {
                terminate_child(pid);
                fclose(capture);
                if (out_fd >= 0)
                    close(out_fd);
                close(in_fd);
                if (monitor_fd >= 0)
                    close(monitor_fd);
                unlink(in_path);
                unlink(out_path);
                if (monitor_path)
                    unlink(monitor_path);
                free(watch.ready_status);
                free(in_path);
                free(out_path);
                return 2;
            }
            if (sent != before && !input_reported) {
                fprintf(stderr,
                    "pi4_qemu_command: serial input wrote %zu/%zu bytes\n",
                    sent, input_len);
                input_reported = 1;
            }
        }
        if (out_fd >= 0 && sent >= input_len &&
            append_available_serial(out_fd, capture, &watch, 1) != 0) {
            terminate_child(pid);
            fclose(capture);
            if (in_fd >= 0)
                close(in_fd);
            close(out_fd);
            if (monitor_fd >= 0)
                close(monitor_fd);
            unlink(in_path);
            unlink(out_path);
            if (monitor_path)
                unlink(monitor_path);
            free(watch.ready_status);
            free(in_path);
            free(out_path);
            return 2;
        }
        if (monitor_fd >= 0 && watch.seen_after_input && !frame1_armed) {
            frame1_ready_ms = elapsed_ms + framebuffer_frame1_settle_ms();
            frame1_armed = 1;
        }
        if (monitor_fd >= 0 && watch.seen_after_input && !frame1_done &&
            frame1_armed && elapsed_ms >= frame1_ready_ms) {
            if (!frame0_done) {
                if (send_screendump_and_wait(monitor_fd, frame0_path) != 0) {
                    terminate_child(pid);
                    fclose(capture);
                    if (in_fd >= 0)
                        close(in_fd);
                    if (out_fd >= 0)
                        close(out_fd);
                    close(monitor_fd);
                    unlink(in_path);
                    unlink(out_path);
                    if (monitor_path)
                        unlink(monitor_path);
                    free(watch.ready_status);
                    free(in_path);
                    free(out_path);
                    return 2;
                }
                frame0_done = 1;
            }
            if (send_screendump_and_wait(monitor_fd, frame1_path) != 0) {
                terminate_child(pid);
                fclose(capture);
                if (in_fd >= 0)
                    close(in_fd);
                if (out_fd >= 0)
                    close(out_fd);
                close(monitor_fd);
                unlink(in_path);
                unlink(out_path);
                if (monitor_path)
                    unlink(monitor_path);
                free(watch.ready_status);
                free(in_path);
                free(out_path);
                return 2;
            }
            frame1_done = 1;
        }
        if (sent >= input_len && watch.seen_after_input &&
            (!monitor_path || frame1_done))
            break;

        got = waitpid(pid, &status, WNOHANG);
        if (got == pid) {
            child_done = 1;
            break;
        }
        if (got < 0 && errno != EINTR) {
            fprintf(stderr, "pi4_qemu_command: waitpid failed: %s\n", strerror(errno));
            fclose(capture);
            if (in_fd >= 0)
                close(in_fd);
            if (out_fd >= 0)
                close(out_fd);
            if (monitor_fd >= 0)
                close(monitor_fd);
            unlink(in_path);
            unlink(out_path);
            if (monitor_path)
                unlink(monitor_path);
            free(watch.ready_status);
            free(in_path);
            free(out_path);
            return 2;
        }
        sleep_millis(100u);
        elapsed_ms += 100u;
    }

    if (monitor_input && sent < input_len) {
        fprintf(stderr,
            "pi4_qemu_command: HMP monitor input did not send the complete script\n");
        if (!child_done)
            terminate_child(pid);
        fclose(capture);
        if (in_fd >= 0)
            close(in_fd);
        if (out_fd >= 0)
            close(out_fd);
        if (monitor_fd >= 0)
            close(monitor_fd);
        unlink(in_path);
        unlink(out_path);
        if (monitor_path)
            unlink(monitor_path);
        free(watch.ready_status);
        free(in_path);
        free(out_path);
        return 2;
    }
    if (sent < input_len || !watch.seen_after_input) {
        fprintf(stderr,
            "pi4_qemu_command: input smoke incomplete: launcher_ready=%d sent=%zu/%zu post_input_status=%d frame0=%d frame1=%d monitor_input=%d\n",
            watch.launcher_ready, sent, input_len, watch.seen_after_input,
            frame0_done, frame1_done, monitor_input);
    }

    if (monitor_fd >= 0 && sent >= input_len && !frame1_done && frame1_path) {
        if (!frame0_done && frame0_path) {
            if (send_screendump_and_wait(monitor_fd, frame0_path) != 0) {
                if (!child_done)
                    terminate_child(pid);
                fclose(capture);
                if (in_fd >= 0)
                    close(in_fd);
                if (out_fd >= 0)
                    close(out_fd);
                close(monitor_fd);
                unlink(in_path);
                unlink(out_path);
                if (monitor_path)
                    unlink(monitor_path);
                free(watch.ready_status);
                free(in_path);
                free(out_path);
                return 2;
            }
            frame0_done = 1;
        }
        if (send_screendump_and_wait(monitor_fd, frame1_path) != 0) {
            if (!child_done)
                terminate_child(pid);
            fclose(capture);
            if (in_fd >= 0)
                close(in_fd);
            if (out_fd >= 0)
                close(out_fd);
            close(monitor_fd);
            unlink(in_path);
            unlink(out_path);
            if (monitor_path)
                unlink(monitor_path);
            free(watch.ready_status);
            free(in_path);
            free(out_path);
            return 2;
        }
        frame1_done = 1;
    }

    if (!child_done)
        terminate_child(pid);
    if (out_fd >= 0) {
        unsigned drain;

        for (drain = 0; drain < 10u; drain++) {
            if (append_available_serial(out_fd, capture, NULL, 0) != 0)
                break;
            sleep_millis(50u);
        }
    }

    if (in_fd >= 0)
        close(in_fd);
    if (out_fd >= 0)
        close(out_fd);
    if (monitor_fd >= 0)
        close(monitor_fd);
    fclose(capture);
    unlink(in_path);
    unlink(out_path);
    if (monitor_path)
        unlink(monitor_path);
    if (ready_status_out) {
        *ready_status_out = watch.ready_status;
        watch.ready_status = NULL;
    }
    free(watch.ready_status);
    free(in_path);
    free(out_path);
    return 0;
}

static char* read_file_limited(const char* path, size_t* out_size)
{
    FILE* file = fopen(path, "rb");
    size_t used = 0;
    size_t cap = 4096u;
    char* data = NULL;

    if (!file) {
        if (errno == ENOENT) {
            *out_size = 0;
            return NULL;
        }
        fprintf(stderr, "pi4_qemu_command: %s: %s\n", path, strerror(errno));
        exit(2);
    }

    data = (char*)malloc(cap);
    if (!data) {
        fclose(file);
        fprintf(stderr, "pi4_qemu_command: out of memory\n");
        exit(2);
    }

    for (;;) {
        size_t got;

        if (used + 1u >= cap) {
            size_t next_cap = cap * 2u;
            char* next = NULL;

            if (next_cap > MAX_SERIAL_BYTES + 1u)
                next_cap = MAX_SERIAL_BYTES + 1u;
            if (next_cap == cap) {
                fclose(file);
                free(data);
                fprintf(stderr, "pi4_qemu_command: serial capture exceeds %u bytes\n",
                    MAX_SERIAL_BYTES);
                exit(2);
            }
            next = (char*)realloc(data, next_cap);
            if (!next) {
                fclose(file);
                free(data);
                fprintf(stderr, "pi4_qemu_command: out of memory\n");
                exit(2);
            }
            data = next;
            cap = next_cap;
        }

        got = fread(data + used, 1, cap - used - 1u, file);
        used += got;
        if (got == 0) {
            if (ferror(file)) {
                fclose(file);
                free(data);
                fprintf(stderr, "pi4_qemu_command: %s: read failed\n", path);
                exit(2);
            }
            break;
        }
    }

    fclose(file);
    data[used] = '\0';
    *out_size = used;
    return data;
}

static unsigned char* read_binary_file_limited(const char* path, size_t* out_size,
    size_t max_bytes)
{
    FILE* file = fopen(path, "rb");
    long size = 0;
    unsigned char* data = NULL;
    size_t got = 0;

    if (!file) {
        fprintf(stderr, "pi4_qemu_command: %s: %s\n", path, strerror(errno));
        return NULL;
    }
    if (fseek(file, 0, SEEK_END) != 0) {
        fprintf(stderr, "pi4_qemu_command: %s: seek failed\n", path);
        fclose(file);
        return NULL;
    }
    size = ftell(file);
    if (size < 0 || (size_t)size > max_bytes) {
        fprintf(stderr, "pi4_qemu_command: %s: framebuffer artifact size is invalid\n",
            path);
        fclose(file);
        return NULL;
    }
    if (fseek(file, 0, SEEK_SET) != 0) {
        fprintf(stderr, "pi4_qemu_command: %s: rewind failed\n", path);
        fclose(file);
        return NULL;
    }
    data = (unsigned char*)malloc((size_t)size + 1u);
    if (!data) {
        fprintf(stderr, "pi4_qemu_command: out of memory\n");
        fclose(file);
        return NULL;
    }
    got = fread(data, 1u, (size_t)size, file);
    if (got != (size_t)size || ferror(file)) {
        fprintf(stderr, "pi4_qemu_command: %s: read failed\n", path);
        free(data);
        fclose(file);
        return NULL;
    }
    fclose(file);
    data[size] = 0u;
    *out_size = (size_t)size;
    return data;
}

static uint64_t fnv1a64(const unsigned char* data, size_t size)
{
    uint64_t hash = FNV64_OFFSET;
    size_t i;

    for (i = 0; i < size; i++) {
        hash ^= (uint64_t)data[i];
        hash *= FNV64_PRIME;
    }
    return hash;
}

static void skip_ppm_ws_and_comments(const unsigned char* data, size_t size,
    size_t* offset)
{
    for (;;) {
        while (*offset < size &&
            (data[*offset] == ' ' || data[*offset] == '\t' ||
             data[*offset] == '\r' || data[*offset] == '\n'))
            (*offset)++;
        if (*offset >= size || data[*offset] != '#')
            return;
        while (*offset < size && data[*offset] != '\n')
            (*offset)++;
    }
}

static int next_ppm_token(const unsigned char* data, size_t size, size_t* offset,
    char* token, size_t token_size)
{
    size_t used = 0;

    skip_ppm_ws_and_comments(data, size, offset);
    if (*offset >= size)
        return 0;
    while (*offset < size &&
        data[*offset] != ' ' && data[*offset] != '\t' &&
        data[*offset] != '\r' && data[*offset] != '\n' &&
        data[*offset] != '#') {
        if (used + 1u >= token_size)
            return 0;
        token[used++] = (char)data[*offset];
        (*offset)++;
    }
    token[used] = '\0';
    return used != 0u;
}

static int parse_ppm_uint_token(const char* token, unsigned* out)
{
    char* end = NULL;
    unsigned long value = strtoul(token, &end, 10);

    if (!token[0] || *end || value == 0ul || value > 65535ul)
        return 0;
    *out = (unsigned)value;
    return 1;
}

static int parse_ppm_frame(const char* path, struct framebuffer_frame_info* info)
{
    size_t size = 0;
    unsigned char* data = read_binary_file_limited(path, &size, MAX_FRAMEBUFFER_BYTES);
    size_t offset = 0;
    size_t expected_pixels = 0;
    const unsigned char* pixels = NULL;
    char token[32];
    unsigned maxval = 0;
    size_t i;

    if (!data)
        return 2;
    if (!next_ppm_token(data, size, &offset, token, sizeof(token)) ||
        strcmp(token, "P6") != 0) {
        fprintf(stderr, "pi4_qemu_command: %s: expected binary P6 PPM screendump\n",
            path);
        free(data);
        return 1;
    }
    if (!next_ppm_token(data, size, &offset, token, sizeof(token)) ||
        !parse_ppm_uint_token(token, &info->width)) {
        fprintf(stderr, "pi4_qemu_command: %s: invalid PPM width\n", path);
        free(data);
        return 1;
    }
    if (!next_ppm_token(data, size, &offset, token, sizeof(token)) ||
        !parse_ppm_uint_token(token, &info->height)) {
        fprintf(stderr, "pi4_qemu_command: %s: invalid PPM height\n", path);
        free(data);
        return 1;
    }
    if (!next_ppm_token(data, size, &offset, token, sizeof(token)) ||
        !parse_ppm_uint_token(token, &maxval) || maxval > 255u) {
        fprintf(stderr, "pi4_qemu_command: %s: invalid PPM maxval\n", path);
        free(data);
        return 1;
    }
    if (offset >= size ||
        !(data[offset] == ' ' || data[offset] == '\t' ||
          data[offset] == '\r' || data[offset] == '\n')) {
        fprintf(stderr, "pi4_qemu_command: %s: missing PPM pixel separator\n", path);
        free(data);
        return 1;
    }
    offset++;
    expected_pixels = (size_t)info->width * (size_t)info->height * 3u;
    if (info->width == 0u || info->height == 0u ||
        expected_pixels / 3u / (size_t)info->width != (size_t)info->height ||
        size - offset != expected_pixels) {
        fprintf(stderr, "pi4_qemu_command: %s: unexpected PPM pixel data size\n", path);
        free(data);
        return 1;
    }

    pixels = data + offset;
    info->image_bytes = size;
    info->pixel_bytes = expected_pixels;
    info->hash = fnv1a64(data, size);
    info->pixel_hash = fnv1a64(pixels, expected_pixels);
    info->nonblank = 0;
    for (i = 1u; i < expected_pixels; i++) {
        if (pixels[i] != pixels[0]) {
            info->nonblank = 1;
            break;
        }
    }
    free(data);
    return 0;
}

static int write_framebuffer_report(const char* report_path, const char* frame0_path,
    const char* frame1_path, const struct framebuffer_frame_info* frame0,
    const struct framebuffer_frame_info* frame1)
{
    FILE* out = fopen(report_path, "wb");

    if (!out) {
        fprintf(stderr, "pi4_qemu_command: %s: %s\n", report_path, strerror(errno));
        return 2;
    }
    fprintf(out, "schema=pi4-framebuffer-artifact-v1\n");
    fprintf(out, "source=qemu-screendump\n");
    fprintf(out, "evidence_class=local-qemu-framebuffer\n");
    fprintf(out, "hardware=unclaimed\n");
    fprintf(out, "green_gate=false\n");
    fprintf(out, "hardware_proof=unclaimed\n");
    fprintf(out, "audio=unclaimed\n");
    fprintf(out, "frame_evidence=nonblank-changed-pixels\n");
    fprintf(out, "frame0_path=%s\n", frame0_path);
    fprintf(out, "frame0_width=%u\n", frame0->width);
    fprintf(out, "frame0_height=%u\n", frame0->height);
    fprintf(out, "frame0_image_bytes=%zu\n", frame0->image_bytes);
    fprintf(out, "frame0_bytes=%zu\n", frame0->pixel_bytes);
    fprintf(out, "frame0_hash=%016llx\n", (unsigned long long)frame0->hash);
    fprintf(out, "frame0_hash_kind=fnv1a64-ppm-image\n");
    fprintf(out, "frame0_pixel_hash=%016llx\n",
        (unsigned long long)frame0->pixel_hash);
    fprintf(out, "frame0_pixel_hash_kind=fnv1a64-rgb-pixels\n");
    fprintf(out, "frame0_nonblank=%s\n", frame0->nonblank ? "true" : "false");
    fprintf(out, "frame1_path=%s\n", frame1_path);
    fprintf(out, "frame1_width=%u\n", frame1->width);
    fprintf(out, "frame1_height=%u\n", frame1->height);
    fprintf(out, "frame1_image_bytes=%zu\n", frame1->image_bytes);
    fprintf(out, "frame1_bytes=%zu\n", frame1->pixel_bytes);
    fprintf(out, "frame1_hash=%016llx\n", (unsigned long long)frame1->hash);
    fprintf(out, "frame1_hash_kind=fnv1a64-ppm-image\n");
    fprintf(out, "frame1_pixel_hash=%016llx\n",
        (unsigned long long)frame1->pixel_hash);
    fprintf(out, "frame1_pixel_hash_kind=fnv1a64-rgb-pixels\n");
    fprintf(out, "frame1_nonblank=%s\n", frame1->nonblank ? "true" : "false");
    fprintf(out, "frames_changed=%s\n",
        frame0->pixel_hash != frame1->pixel_hash ? "true" : "false");
    fprintf(out, "exact_images_changed=%s\n",
        frame0->hash != frame1->hash ? "true" : "false");
    fprintf(out, "framebuffer_artifact=%s\n",
        frame0->nonblank && frame1->nonblank &&
            frame0->pixel_hash != frame1->pixel_hash ? "OK" : "BAD");
    if (fclose(out) != 0) {
        fprintf(stderr, "pi4_qemu_command: %s: close failed\n", report_path);
        return 2;
    }
    return 0;
}

static int validate_framebuffer_artifact(const char* report_path,
    const char* frame0_path, const char* frame1_path)
{
    struct framebuffer_frame_info frame0;
    struct framebuffer_frame_info frame1;
    int rc;

    memset(&frame0, 0, sizeof(frame0));
    memset(&frame1, 0, sizeof(frame1));
    rc = parse_ppm_frame(frame0_path, &frame0);
    if (rc != 0)
        return rc;
    rc = parse_ppm_frame(frame1_path, &frame1);
    if (rc != 0)
        return rc;
    rc = write_framebuffer_report(report_path, frame0_path, frame1_path,
        &frame0, &frame1);
    if (rc != 0)
        return rc;
    if (!frame0.nonblank || !frame1.nonblank) {
        fprintf(stderr, "pi4_qemu_command: framebuffer screendumps must both be nonblank\n");
        return 1;
    }
    if (frame0.pixel_hash == frame1.pixel_hash) {
        fprintf(stderr, "pi4_qemu_command: framebuffer screendump pixels did not change\n");
        return 1;
    }
    return 0;
}

static int monitor_path_is_safe(const char* path)
{
    const unsigned char* p = (const unsigned char*)path;

    for (; *p; p++) {
        if (*p <= ' ' || *p == '\'' || *p == '"' || *p == '\\')
            return 0;
    }
    return path[0] != '\0';
}

static int connect_monitor_once(const char* monitor_path)
{
    int fd = socket(AF_UNIX, SOCK_STREAM, 0);
    struct sockaddr_un addr;

    if (fd < 0)
        return -1;
    memset(&addr, 0, sizeof(addr));
    addr.sun_family = AF_UNIX;
    if (strlen(monitor_path) >= sizeof(addr.sun_path)) {
        close(fd);
        return -1;
    }
    strcpy(addr.sun_path, monitor_path);
    if (connect(fd, (struct sockaddr*)&addr, sizeof(addr)) != 0) {
        close(fd);
        return -1;
    }
    return fd;
}

static int write_all(int fd, const char* data, size_t size)
{
    size_t sent = 0;

    while (sent < size) {
        ssize_t wrote = write(fd, data + sent, size - sent);

        if (wrote > 0) {
            sent += (size_t)wrote;
            continue;
        }
        if (wrote < 0 && errno == EINTR)
            continue;
        return 2;
    }
    return 0;
}

static int set_nonblock(int fd)
{
    int flags = fcntl(fd, F_GETFL, 0);

    if (flags < 0)
        return 2;
    if (fcntl(fd, F_SETFL, flags | O_NONBLOCK) < 0)
        return 2;
    return 0;
}

static int send_screendump(int monitor_fd, const char* frame_path)
{
    char command[1024];
    int n;

    if (!monitor_path_is_safe(frame_path)) {
        fprintf(stderr, "pi4_qemu_command: unsafe screendump path: %s\n", frame_path);
        return 2;
    }
    n = snprintf(command, sizeof(command), "screendump %s\n", frame_path);
    if (n < 0 || (size_t)n >= sizeof(command)) {
        fprintf(stderr, "pi4_qemu_command: screendump command is too long\n");
        return 2;
    }
    return write_all(monitor_fd, command, (size_t)n);
}

static int send_screendump_and_wait(int monitor_fd, const char* frame_path)
{
    int rc = send_screendump(monitor_fd, frame_path);

    if (rc != 0)
        return rc;
    return wait_for_file_stable(frame_path, HMP_SCREEN_DUMP_WAIT_MS);
}

static int hmp_sendkey_token(char key, char* token, size_t token_size)
{
    if ((key >= 'a' && key <= 'z') || (key >= '0' && key <= '9')) {
        if (token_size < 2u)
            return 0;
        token[0] = key;
        token[1] = '\0';
        return 1;
    }
    if (key >= 'A' && key <= 'Z') {
        if (token_size < sizeof("shift-a"))
            return 0;
        snprintf(token, token_size, "shift-%c", key - 'A' + 'a');
        return 1;
    }
    switch (key) {
    case ' ':
        snprintf(token, token_size, "spc");
        return 1;
    case '\n':
    case '\r':
        snprintf(token, token_size, "ret");
        return 1;
    case '\t':
        snprintf(token, token_size, "tab");
        return 1;
    case 27:
        snprintf(token, token_size, "esc");
        return 1;
    default:
        return 0;
    }
}

static int send_monitor_key(int monitor_fd, char key)
{
    char token[32];
    char command[80];
    int n;

    if (!hmp_sendkey_token(key, token, sizeof(token))) {
        fprintf(stderr, "pi4_qemu_command: unsupported HMP sendkey input byte: 0x%02x\n",
            (unsigned int)(unsigned char)key);
        return 2;
    }
    n = snprintf(command, sizeof(command), "sendkey %s %u\n", token,
        hmp_key_hold_ms());
    if (n < 0 || (size_t)n >= sizeof(command)) {
        fprintf(stderr, "pi4_qemu_command: sendkey command is too long\n");
        return 2;
    }
    return write_all(monitor_fd, command, (size_t)n);
}

static int line_has_prefix(const char* line, const char* end, const char* prefix)
{
    size_t len = strlen(prefix);

    return (size_t)(end - line) >= len && strncmp(line, prefix, len) == 0;
}

static void copy_line_value(char* out, size_t out_size, const char* line,
    const char* end, const char* prefix)
{
    size_t prefix_len = strlen(prefix);
    size_t len = (size_t)(end - line);

    if (len < prefix_len) {
        out[0] = '\0';
        return;
    }
    line += prefix_len;
    len -= prefix_len;
    while (len > 0u && (*line == ' ' || *line == '\t')) {
        line++;
        len--;
    }
    while (len > 0u && (line[len - 1u] == '\r' || line[len - 1u] == '\n'))
        len--;
    if (len >= out_size)
        len = out_size - 1u;
    memcpy(out, line, len);
    out[len] = '\0';
}

static char* copy_line(const char* line, const char* end)
{
    size_t len = (size_t)(end - line);
    char* out = NULL;

    while (len > 0u && (line[len - 1u] == '\r' || line[len - 1u] == '\n'))
        len--;
    out = (char*)malloc(len + 1u);
    if (!out) {
        fprintf(stderr, "pi4_qemu_command: out of memory\n");
        exit(2);
    }
    memcpy(out, line, len);
    out[len] = '\0';
    return out;
}

static int is_status_line(const char* line, const char* end)
{
    return (size_t)(end - line) >= STATUS_PREFIX_LEN &&
        strncmp(line, STATUS_PREFIX, STATUS_PREFIX_LEN) == 0 &&
        ((size_t)(end - line) == STATUS_PREFIX_LEN ||
            line[STATUS_PREFIX_LEN] == ' ' ||
            line[STATUS_PREFIX_LEN] == '\t' ||
            line[STATUS_PREFIX_LEN] == '\r' ||
            line[STATUS_PREFIX_LEN] == '\n');
}

static char* find_last_status_line(const char* data, char* last_stage,
    size_t last_stage_size, char* last_code, size_t last_code_size)
{
    const char* cursor = data;
    char* status = NULL;

    last_stage[0] = '\0';
    last_code[0] = '\0';
    while (*cursor) {
        const char* line = cursor;
        const char* end = strchr(cursor, '\n');

        if (!end)
            end = cursor + strlen(cursor);
        else
            end++;

        if (is_status_line(line, end)) {
            free(status);
            status = copy_line(line, end);
        } else if (line_has_prefix(line, end, "status: stage ")) {
            copy_line_value(last_stage, last_stage_size, line, end, "status: stage ");
        } else if (line_has_prefix(line, end, "0x")) {
            size_t len = (size_t)(end - line);

            while (len > 0u && (line[len - 1u] == '\r' || line[len - 1u] == '\n'))
                len--;
            if (len >= last_code_size)
                len = last_code_size - 1u;
            memcpy(last_code, line, len);
            last_code[len] = '\0';
        }

        cursor = end;
    }
    return status;
}

static int token_has_key(const char* token, size_t token_len, const char* key)
{
    size_t key_len = strlen(key);

    return token_len > key_len && token[key_len] == '=' &&
        strncmp(token, key, key_len) == 0;
}

static int local_qemu_marker_token(const char* token, size_t token_len)
{
    return token_has_key(token, token_len, "local_qemu_only") ||
        token_has_key(token, token_len, "evidence_class") ||
        token_has_key(token, token_len, "smoke_gate") ||
        token_has_key(token, token_len, "hardware") ||
        token_has_key(token, token_len, "green_gate") ||
        token_has_key(token, token_len, "hardware_proof") ||
        token_has_key(token, token_len, "audio");
}

static void write_status_without_local_markers(FILE* out, const char* status)
{
    const char* p = status;
    int wrote = 0;

    while (*p) {
        const char* token;
        size_t token_len;

        while (*p == ' ' || *p == '\t' || *p == '\r' || *p == '\n')
            p++;
        if (!*p)
            break;
        token = p;
        while (*p && *p != ' ' && *p != '\t' &&
            *p != '\r' && *p != '\n')
            p++;
        token_len = (size_t)(p - token);
        if (local_qemu_marker_token(token, token_len))
            continue;
        if (wrote)
            fputc(' ', out);
        fwrite(token, 1u, token_len, out);
        wrote = 1;
    }
    if (!wrote)
        fputs(STATUS_PREFIX, out);
}

static void write_no_status(const char* marked_status_path, const char* evidence_class,
    const char* smoke_gate, const char* last_stage, const char* last_code)
{
    FILE* out = fopen(marked_status_path, "wb");

    if (!out) {
        fprintf(stderr, "pi4_qemu_command: %s: %s\n", marked_status_path, strerror(errno));
        exit(2);
    }
    fprintf(out,
        "local-qemu-smoke status=NO_VIBE_STATUS local_qemu_only=true evidence_class=%s smoke_gate=%s hardware=unclaimed green_gate=false hardware_proof=unclaimed audio=unclaimed",
        evidence_class, smoke_gate);
    if (last_stage[0])
        fprintf(out, " last_stage=%s", last_stage);
    if (last_code[0])
        fprintf(out, " last_code=%s", last_code);
    fputc('\n', out);
    fclose(out);
}

static void write_raw_status(const char* raw_status_path, const char* status)
{
    FILE* out = fopen(raw_status_path, "wb");

    if (!out) {
        fprintf(stderr, "pi4_qemu_command: %s: %s\n", raw_status_path, strerror(errno));
        exit(2);
    }
    fprintf(out, "%s\n", status);
    fclose(out);
}

static void write_marked_status(const char* marked_status_path, const char* status,
    const char* evidence_class, const char* smoke_gate)
{
    FILE* out = fopen(marked_status_path, "wb");

    if (!out) {
        fprintf(stderr, "pi4_qemu_command: %s: %s\n", marked_status_path, strerror(errno));
        exit(2);
    }
    write_status_without_local_markers(out, status);
    fprintf(out,
        " local_qemu_only=true evidence_class=%s smoke_gate=%s hardware=unclaimed green_gate=false hardware_proof=unclaimed audio=unclaimed",
        evidence_class, smoke_gate);
    fputc('\n', out);
    fclose(out);
}

static int run_local_smoke(unsigned seconds, const char* raw_status_path,
    const char* marked_status_path, char* const* cmd, const char* serial_arg)
{
    const char* serial_path = NULL;
    size_t serial_size = 0;
    char* serial = NULL;
    char* status = NULL;
    char last_stage[128];
    char last_code[128];

    if (strncmp(serial_arg, "file:", 5) != 0 || serial_arg[5] == '\0') {
        fprintf(stderr, "pi4_qemu_command: --local-smoke requires a file:SERIAL target\n");
        return 2;
    }
    if (!local_vm_allowed()) {
        fprintf(stderr, "pi4_qemu_command: refusing to execute local VM without ALLOW_LOCAL_VM=1\n");
        return 1;
    }

    serial_path = serial_arg + 5;
    if (run_command_for_seconds(cmd, seconds) != 0)
        return 2;

    serial = read_file_limited(serial_path, &serial_size);
    if (!serial || serial_size == 0u) {
        free(serial);
        fprintf(stderr, "pi4_qemu_command: Pi 4 local QEMU smoke produced no serial output\n");
        return 1;
    }

    status = find_last_status_line(serial, last_stage, sizeof(last_stage),
        last_code, sizeof(last_code));
    if (!status) {
        write_no_status(marked_status_path, "local-qemu-smoke",
            "pi4-local-qemu-smoke", last_stage, last_code);
        free(serial);
        return 0;
    }

    write_raw_status(raw_status_path, status);
    write_marked_status(marked_status_path, status, "local-qemu-smoke",
        "pi4-local-qemu-smoke");
    free(status);
    free(serial);
    return 0;
}

static int run_local_input_smoke(unsigned seconds, const char* input,
    const char* raw_status_path, const char* marked_status_path,
    const char* serial_capture_path, const char* pipe_base, char* const* cmd,
    const char* monitor_path, const char* framebuffer_report_path,
    const char* frame0_path, const char* frame1_path)
{
    size_t serial_size = 0;
    char* serial = NULL;
    char* ready_status = NULL;
    char* status = NULL;
    char last_stage[128] = "";
    char last_code[128] = "";

    if (!local_vm_allowed()) {
        fprintf(stderr, "pi4_qemu_command: refusing to execute local VM without ALLOW_LOCAL_VM=1\n");
        return 1;
    }
    if (run_command_with_pipe_input(cmd, seconds, input, pipe_base,
            serial_capture_path, monitor_path, frame0_path, frame1_path,
            monitor_path != NULL && input_uses_hmp_actions(input),
            &ready_status) != 0)
        return 2;

    if (framebuffer_report_path &&
        validate_framebuffer_artifact(framebuffer_report_path,
            frame0_path, frame1_path) != 0) {
        free(ready_status);
        return 1;
    }

    status = ready_status;
    ready_status = NULL;
    if (!status) {
        serial = read_file_limited(serial_capture_path, &serial_size);
        if (!serial || serial_size == 0u) {
            free(serial);
            fprintf(stderr, "pi4_qemu_command: Pi 4 local input smoke produced no serial output\n");
            return 1;
        }
        status = find_last_status_line(serial, last_stage, sizeof(last_stage),
            last_code, sizeof(last_code));
    }
    if (!status) {
        write_no_status(marked_status_path, "local-qemu-input-smoke",
            "pi4-local-qemu-input-smoke", last_stage, last_code);
        free(serial);
        return 0;
    }

    write_raw_status(raw_status_path, status);
    write_marked_status(marked_status_path, status, "local-qemu-input-smoke",
        "pi4-local-qemu-input-smoke");
    free(status);
    free(serial);
    return 0;
}

int main(int argc, char** argv)
{
    int exec_mode = 0;
    int live_mode = 0;
    int command_only_mode = 0;
    int live_smoke_mode = 0;
    int local_smoke_mode = 0;
    int local_input_smoke_mode = 0;
    int local_input_framebuffer_smoke_mode = 0;
    int argi = 1;
    unsigned local_smoke_seconds = 0;
    const char* local_input = NULL;
    const char* raw_status_path = NULL;
    const char* marked_status_path = NULL;
    const char* serial_capture_path = NULL;
    const char* framebuffer_report_path = NULL;
    const char* frame0_path = NULL;
    const char* frame1_path = NULL;
    char* drive_arg;
    char* cmd[36];
    int n = 0;

    if (argc > 1 && strcmp(argv[1], "--framebuffer-artifact-check") == 0) {
        if (argc != 5) {
            usage(argv[0]);
            return 2;
        }
        return validate_framebuffer_artifact(argv[2], argv[3], argv[4]);
    }
    if (argc > 1 && strcmp(argv[1], "--exec") == 0) {
        exec_mode = 1;
        argi = 2;
    } else if (argc > 1 && strcmp(argv[1], "--live") == 0) {
        exec_mode = 1;
        live_mode = 1;
        argi = 2;
    } else if (argc > 1 && strcmp(argv[1], "--live-command") == 0) {
        live_mode = 1;
        command_only_mode = 1;
        argi = 2;
    } else if (argc > 1 && strcmp(argv[1], "--live-smoke") == 0) {
        live_mode = 1;
        live_smoke_mode = 1;
        if (argc != 7) {
            usage(argv[0]);
            return 2;
        }
        local_smoke_seconds = parse_seconds(argv[2]);
        argi = 3;
    } else if (argc > 1 && strcmp(argv[1], "--local-smoke") == 0) {
        local_smoke_mode = 1;
        if (argc != 9) {
            usage(argv[0]);
            return 2;
        }
        local_smoke_seconds = parse_seconds(argv[2]);
        raw_status_path = argv[3];
        marked_status_path = argv[4];
        argi = 5;
    } else if (argc > 1 && strcmp(argv[1], "--local-input-smoke") == 0) {
        local_input_smoke_mode = 1;
        if (argc != 10) {
            usage(argv[0]);
            return 2;
        }
        local_smoke_seconds = parse_seconds(argv[2]);
        local_input = argv[3];
        raw_status_path = argv[4];
        marked_status_path = argv[5];
        serial_capture_path = argv[6];
    } else if (argc > 1 && strcmp(argv[1], "--local-input-framebuffer-smoke") == 0) {
        local_input_framebuffer_smoke_mode = 1;
        if (argc != 13) {
            usage(argv[0]);
            return 2;
        }
        local_smoke_seconds = parse_seconds(argv[2]);
        local_input = argv[3];
        raw_status_path = argv[4];
        marked_status_path = argv[5];
        serial_capture_path = argv[6];
        framebuffer_report_path = argv[7];
        frame0_path = argv[8];
        frame1_path = argv[9];
    }
    if (local_input_smoke_mode || local_input_framebuffer_smoke_mode) {
        char* pipe_base = join_suffix(serial_capture_path, ".pipe");
        char* serial_arg = join_suffix("stdio", "");
        char* monitor_path = NULL;
        char* monitor_arg = NULL;
        char* input_argv[4];
        int rc;
        int qemu_arg = local_input_framebuffer_smoke_mode ? 10 : 7;

        input_argv[0] = argv[qemu_arg];
        input_argv[1] = serial_arg;
        input_argv[2] = argv[qemu_arg + 1];
        input_argv[3] = argv[qemu_arg + 2];
        require_nonempty_file("kernel8 image", input_argv[2]);
        require_nonempty_file("Pi 4 FAT16 image", input_argv[3]);
        drive_arg = make_drive_arg(argv[qemu_arg + 2]);
        if (local_input_framebuffer_smoke_mode) {
            monitor_path = join_suffix(framebuffer_report_path, ".monitor");
            monitor_arg = make_monitor_arg(monitor_path);
        }
        build_command(input_argv, drive_arg, cmd,
            input_smoke_visible_display_enabled(),
            local_input_framebuffer_smoke_mode, monitor_arg, &n);
        print_command(cmd);
        fflush(stdout);
        rc = run_local_input_smoke(local_smoke_seconds, local_input,
            raw_status_path, marked_status_path, serial_capture_path,
            pipe_base, cmd, monitor_path, framebuffer_report_path,
            frame0_path, frame1_path);
        free(monitor_arg);
        free(monitor_path);
        free(serial_arg);
        free(pipe_base);
        free(drive_arg);
        (void)n;
        return rc;
    }
    if (argc - argi != 4) {
        usage(argv[0]);
        return 2;
    }

    require_nonempty_file("kernel8 image", argv[argi + 2]);
    require_nonempty_file("Pi 4 FAT16 image", argv[argi + 3]);
    drive_arg = make_drive_arg(argv[argi + 3]);
    build_command((char* const*)&argv[argi], drive_arg, cmd, live_mode, 0, NULL, &n);

    print_command(cmd);
    fflush(stdout);
    if (command_only_mode) {
        free(drive_arg);
        return 0;
    }
    if (live_smoke_mode) {
        int rc;

        if (!local_vm_allowed()) {
            fprintf(stderr, "pi4_qemu_command: refusing to execute local VM without ALLOW_LOCAL_VM=1\n");
            free(drive_arg);
            return 1;
        }
        rc = run_command_for_seconds(cmd, local_smoke_seconds);
        free(drive_arg);
        return rc;
    }
    if (local_smoke_mode) {
        int rc = run_local_smoke(local_smoke_seconds, raw_status_path,
            marked_status_path, cmd, argv[argi + 1]);
        free(drive_arg);
        return rc;
    }
    if (!exec_mode) {
        free(drive_arg);
        return 0;
    }
    if (!local_vm_allowed()) {
        if (live_mode) {
            free(drive_arg);
            return 0;
        }
        fprintf(stderr, "pi4_qemu_command: refusing to execute local VM without ALLOW_LOCAL_VM=1\n");
        free(drive_arg);
        return 1;
    }

    (void)n;
    exec_command_or_die(cmd);
}
