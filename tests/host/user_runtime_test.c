#define VIBE_USER_RUNTIME_HOST_TEST 1

#include "../../user/runtime.h"

#define MOCK_MAX_WRITES 4
#define MOCK_MAX_DIRENTS 4

static char mock_write_buffer[64];
static int mock_write_length;
static int mock_exec_count;
static const char* mock_exec_path;
static int mock_close_count;
static int mock_probe_count;
static unsigned long mock_probe_magic;
static unsigned long mock_probe_flags;
static int mock_force_legacy_error;

int vibe_user_syscall3(unsigned int number, unsigned long arg0, unsigned long arg1, unsigned long arg2)
{
    if (number == VIBE_SYS_WRITE) {
        const char* text = (const char*)arg1;
        unsigned long length = arg2;
        unsigned long index;

        (void)arg0;
        if (mock_force_legacy_error)
            return -1;
        for (index = 0; index < length && index < sizeof(mock_write_buffer); ++index)
            mock_write_buffer[index] = text[index];
        mock_write_length = (int)length;
        return (int)length;
    }

    if (number == VIBE_SYS_OPEN)
        return arg0 && arg1 == 0 && arg2 == 0 ? 4 : -22;

    if (number == VIBE_SYS_CLOSE) {
        if (arg0 != 4)
            return -9;
        ++mock_close_count;
        return 0;
    }

    if (number == VIBE_SYS_GETPID)
        return 7;

    if (number == VIBE_SYS_DUP)
        return arg0 == 4 ? 5 : -9;

    if (number == VIBE_SYS_DUP2)
        return arg0 == 4 && arg1 == 8 ? 8 : -9;

    if (number == VIBE_SYS_DUP3)
        return arg0 == 4 && arg1 == 9 && arg2 == 0x0800u ? 9 : -22;

    if (number == VIBE_SYS_FCNTL) {
        if (arg0 != 4)
            return -9;
        if (arg1 == 1)
            return 1;
        if (arg1 == 2 && arg2 <= 1)
            return 0;
        return -22;
    }

    if (number == VIBE_SYS_CLOCK_GETTIME) {
        vibe_clock_time_t* out = (vibe_clock_time_t*)arg1;
        if (arg0 != VIBE_CLOCK_MONOTONIC || !out || arg2 != sizeof(*out))
            return -22;
        out->ticks = 12;
        out->frequency_hz = VIBE_CLOCK_MONOTONIC_HZ;
        out->milliseconds = 120;
        out->flags = 0;
        return 0;
    }

    if (number == VIBE_SYS_LISTDIR) {
        vibe_dirent_t* entries = (vibe_dirent_t*)arg1;
        if (!entries || arg2 < MOCK_MAX_DIRENTS)
            return -22;
        entries[0].name[0] = 'T';
        entries[0].name[1] = 'O';
        entries[0].name[2] = 'O';
        entries[0].name[3] = 'L';
        entries[0].name[4] = 0;
        return 1;
    }

    if (number == VIBE_SYS_EXEC) {
        ++mock_exec_count;
        mock_exec_path = (const char*)arg0;
        return arg1 ? 0 : -22;
    }

    if (number == VIBE_SYS_USER_PROBE) {
        ++mock_probe_count;
        mock_probe_magic = arg0;
        mock_probe_flags = arg1;
        return 0;
    }

    return -38;
}

#include "../../user/runtime.c"

static int fail(int code)
{
    return code;
}

int main(void)
{
    vibe_clock_time_t now;
    vibe_dirent_t entries[MOCK_MAX_DIRENTS];
    char* argv[] = { "TOOL.ELF", 0 };

    if (vibe_user_syscall_errno(-13, 5) != 13)
        return fail(1);
    if (vibe_user_syscall_errno(-1, 22) != 22)
        return fail(2);
    if (vibe_user_syscall_errno(0, 5) != 0)
        return fail(3);
    if (!vibe_user_streq("ABIPROBE.ELF", "ABIPROBE.ELF") || vibe_user_streq("A", "B"))
        return fail(4);
    if (vibe_user_write_all(1, "hello") != 0 || mock_write_length != 5 || mock_write_buffer[0] != 'h')
        return fail(5);
    mock_force_legacy_error = 1;
    if (vibe_user_write_all(1, "bad") != -5)
        return fail(6);
    mock_force_legacy_error = 0;
    if (vibe_user_getpid() != 7)
        return fail(7);
    if (vibe_user_dup(4) != 5 || vibe_user_dup2(4, 8) != 8 || vibe_user_dup3(4, 9, 0x0800u) != 9)
        return fail(8);
    if (vibe_user_open("TOOL.TXT", 0, 0) != 4 || vibe_user_fcntl(4, 1, 0) != 1 || vibe_user_fcntl(4, 2, 1) != 0)
        return fail(13);
    if (vibe_user_close(4) != 0 || mock_close_count != 1)
        return fail(14);
    if (vibe_user_clock_monotonic(&now) != 0 || now.frequency_hz != VIBE_CLOCK_MONOTONIC_HZ)
        return fail(9);
    if (vibe_user_listdir("/", entries, MOCK_MAX_DIRENTS) != 1 || !vibe_user_streq(entries[0].name, "TOOL"))
        return fail(10);
    if (vibe_user_execv("TOOL.ELF", argv) != 0 || mock_exec_count != 1 || !vibe_user_streq(mock_exec_path, "TOOL.ELF"))
        return fail(11);
    vibe_user_report_probe(0x1234u, 0x55u);
    if (mock_probe_count != 1 || mock_probe_magic != 0x1234u || mock_probe_flags != 0x55u)
        return fail(12);

    return 0;
}
