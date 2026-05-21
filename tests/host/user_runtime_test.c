#define VIBE_USER_RUNTIME_HOST_TEST 1

#include "../../user/runtime.h"

#define MOCK_MAX_WRITES 4
#define MOCK_MAX_DIRENTS 4
#define MOCK_MMAP_BASE 0x00408000u
#define MOCK_MMAP_BYTES 12288u

static char mock_write_buffer[64];
static const char mock_read_data[] = "abcdef";
static unsigned char mock_mmap_region[MOCK_MMAP_BYTES];
static int mock_write_length;
static int mock_file_pos;
static int mock_brk = 0x00400000;
static int mock_wait_reaped;
static int mock_munmap_count;
static int mock_exec_count;
static const char* mock_exec_path;
static unsigned long mock_exec_argv;
static int mock_close_count;
static int mock_probe_count;
static unsigned long mock_probe_magic;
static unsigned long mock_probe_flags;
static int mock_force_legacy_error;
static int mock_fd_flags;

static char* mock_user_buffer(unsigned long address, unsigned long count)
{
    if (address >= MOCK_MMAP_BASE
        && count <= MOCK_MMAP_BYTES
        && address - MOCK_MMAP_BASE <= MOCK_MMAP_BYTES - count)
        return (char*)mock_mmap_region + (address - MOCK_MMAP_BASE);
    return (char*)address;
}

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

    if (number == VIBE_SYS_SBRK) {
        long increment = (long)arg0;
        int old = mock_brk;
        int next = mock_brk + (int)increment;

        if (next < 0x00400000 || next > 0x00410000)
            return -12;
        mock_brk = next;
        return old;
    }

    if (number == VIBE_SYS_OPEN)
        return arg0 && arg1 == 0 && arg2 == 0 ? 4 : -22;

    if (number == VIBE_SYS_READ) {
        char* out = mock_user_buffer(arg1, arg2);
        int count = (int)arg2;
        int available;
        int index;

        if (arg0 != 4 || (!out && count))
            return -22;
        available = (int)sizeof(mock_read_data) - 1 - mock_file_pos;
        if (available < 0)
            available = 0;
        if (count > available)
            count = available;
        for (index = 0; index < count; ++index)
            out[index] = mock_read_data[mock_file_pos + index];
        mock_file_pos += count;
        return count;
    }

    if (number == VIBE_SYS_LSEEK) {
        int offset = (int)arg1;
        int next;

        if (arg0 != 4)
            return -9;
        if (arg2 == 0)
            next = offset;
        else if (arg2 == 1)
            next = mock_file_pos + offset;
        else if (arg2 == 2)
            next = (int)sizeof(mock_read_data) - 1 + offset;
        else
            return -22;
        if (next < 0)
            return -22;
        mock_file_pos = next;
        return mock_file_pos;
    }

    if (number == VIBE_SYS_CLOSE) {
        if (arg0 != 4)
            return -9;
        ++mock_close_count;
        return 0;
    }

    if (number == VIBE_SYS_GETPID)
        return 7;

    if (number == VIBE_SYS_FORK)
        return -38;

    if (number == VIBE_SYS_WAITPID) {
        int* status = (int*)arg1;

        if (((long)arg0 != -1 && (long)arg0 != 3) || arg2 != VIBE_USER_WNOHANG)
            return -22;
        if (mock_wait_reaped)
            return -10;
        if (status)
            *status = 0x2a;
        mock_wait_reaped = 1;
        return 3;
    }

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
            return mock_fd_flags;
        if (arg1 == 2 && arg2 <= 1) {
            mock_fd_flags = (int)arg2;
            return 0;
        }
        return -22;
    }

    if (number == VIBE_SYS_MMAP) {
        unsigned long prot = arg2 & 0xffffu;
        unsigned long flags = arg2 >> 16;
        unsigned long index;

        if (arg0 != 0 || arg1 == 0)
            return -22;
        if (flags != (VIBE_USER_MAP_PRIVATE | VIBE_USER_MAP_ANONYMOUS))
            return -22;
        if ((prot & (VIBE_USER_PROT_READ | VIBE_USER_PROT_WRITE)) != (VIBE_USER_PROT_READ | VIBE_USER_PROT_WRITE))
            return -22;
        for (index = 0; index < MOCK_MMAP_BYTES; ++index)
            mock_mmap_region[index] = 0;
        return MOCK_MMAP_BASE;
    }

    if (number == VIBE_SYS_MUNMAP) {
        if (arg0 != MOCK_MMAP_BASE || (arg1 != 4096 && arg1 != 8192) || arg2 != 0)
            return -22;
        ++mock_munmap_count;
        return 0;
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
        mock_exec_argv = arg1;
        return arg0 ? 0 : -22;
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
    char read_buffer[4];
    char* argv[] = { "TOOL.ELF", 0 };
    char* empty_env[] = { 0 };
    char* nonempty_env[] = { "A=B", 0 };
    char long_path[VIBE_EXEC_PATH_MAX + 1];
    char long_arg[VIBE_EXEC_ARG_STR_MAX + 1];
    unsigned long argc = 0;
    void* old_break = 0;
    void* mapped = 0;
    void* file_mapped = 0;
    int wait_status = 0;
    int index;

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
    if (vibe_user_fork() != -38)
        return fail(19);
    if (vibe_user_waitpid(-1, &wait_status, VIBE_USER_WNOHANG) != 3 || wait_status != 0x2a)
        return fail(20);
    if (vibe_user_waitpid(-1, &wait_status, VIBE_USER_WNOHANG) != -10)
        return fail(21);
    mock_wait_reaped = 0;
    wait_status = 0;
    if (vibe_user_waitpid_nohang_reap(3, &wait_status, 3) != 3 || wait_status != 0x2a)
        return fail(37);
    if (vibe_user_waitpid_nohang_reap(3, &wait_status, 0) != -22)
        return fail(38);
    mock_wait_reaped = 0;
    wait_status = 0;
    if (vibe_user_waitpid_nohang_reap_exact(3, &wait_status, 3) != 3 || wait_status != 0x2a)
        return fail(43);
    if (vibe_user_waitpid_nohang_reap_exact(-1, &wait_status, 3) != -22)
        return fail(44);
    if (vibe_user_sbrk(4096, &old_break) != 0 || old_break != (void*)0x00400000)
        return fail(22);
    if (vibe_user_sbrk(-4096, &old_break) != 0 || old_break != (void*)0x00401000)
        return fail(23);
    if (vibe_user_sbrk(4096, 0) != -22)
        return fail(24);
    if (vibe_user_mmap_anon(&mapped, 4096, VIBE_USER_PROT_READ | VIBE_USER_PROT_WRITE) != 0 || mapped != (void*)0x00408000)
        return fail(25);
    if (vibe_user_mmap(&mapped, 4096, VIBE_USER_PROT_READ, VIBE_USER_MAP_FIXED) != -22)
        return fail(26);
    if (vibe_user_munmap(mapped, 4096) != 0 || mock_munmap_count != 1)
        return fail(27);
    if (vibe_user_munmap(0, 4096) != -22)
        return fail(28);
    if ((vibe_user_heap_capabilities() & (VIBE_HEAP_CAP_SBRK_GROW | VIBE_HEAP_CAP_SBRK_SHRINK)) != (VIBE_HEAP_CAP_SBRK_GROW | VIBE_HEAP_CAP_SBRK_SHRINK))
        return fail(29);
    if ((vibe_user_vm_capabilities() & (VIBE_VM_CAP_ANON_PRIVATE | VIBE_VM_CAP_NONTAIL_MUNMAP_HOLES | VIBE_USER_VM_CAP_FILE_PRIVATE_COPY)) != (VIBE_VM_CAP_ANON_PRIVATE | VIBE_VM_CAP_NONTAIL_MUNMAP_HOLES | VIBE_USER_VM_CAP_FILE_PRIVATE_COPY))
        return fail(30);
    mock_file_pos = 1;
    if (vibe_user_mmap_file_private(&file_mapped, 4096, VIBE_USER_PROT_READ | VIBE_USER_PROT_WRITE, 4, 2) != 0 || file_mapped != (void*)MOCK_MMAP_BASE)
        return fail(31);
    if (mock_mmap_region[0] != 'c' || mock_mmap_region[1] != 'd' || mock_mmap_region[2] != 'e' || mock_mmap_region[3] != 'f')
        return fail(32);
    if (mock_file_pos != 1)
        return fail(33);
    if (vibe_user_munmap(file_mapped, 4096) != 0 || mock_munmap_count != 2)
        return fail(34);
    mock_file_pos = 2;
    if (vibe_user_mmap_file_private(&file_mapped, 8192, VIBE_USER_PROT_READ | VIBE_USER_PROT_WRITE, 4, 5) != 0 || file_mapped != (void*)MOCK_MMAP_BASE)
        return fail(39);
    if (mock_mmap_region[0] != 'f' || mock_mmap_region[1] != 0 || mock_mmap_region[4096] != 0)
        return fail(40);
    if (mock_file_pos != 2)
        return fail(41);
    if (vibe_user_munmap(file_mapped, 8192) != 0 || mock_munmap_count != 3)
        return fail(42);
    if (vibe_user_mmap_file(&file_mapped, 4096, VIBE_USER_PROT_READ | VIBE_USER_PROT_WRITE, VIBE_USER_MAP_SHARED, 4, 0) != -22)
        return fail(35);
    if (vibe_user_mmap_file_private(&file_mapped, 8192, VIBE_USER_PROT_READ | VIBE_USER_PROT_WRITE, 3, 0) != -9 || file_mapped != 0 || mock_munmap_count != 4)
        return fail(36);
    if (vibe_user_dup(4) != 5 || vibe_user_dup2(4, 8) != 8 || vibe_user_dup3(4, 9, 0x0800u) != 9)
        return fail(8);
    if (vibe_user_open("TOOL.TXT", 0, 0) != 4 || vibe_user_fcntl(4, 1, 0) != 0 || vibe_user_fcntl(4, 2, 1) != 0)
        return fail(13);
    if (vibe_user_get_cloexec(4, &wait_status) != 0 || wait_status != 1)
        return fail(45);
    if (vibe_user_set_cloexec(4, 0) != 0 || vibe_user_get_cloexec(4, &wait_status) != 0 || wait_status != 0)
        return fail(46);
    if (vibe_user_get_cloexec(4, 0) != -22)
        return fail(47);
    if (vibe_user_lseek(4, 6, 0) != 6)
        return fail(15);
    if (vibe_user_pread(4, read_buffer, 3, 2) != 3
        || read_buffer[0] != 'c'
        || read_buffer[1] != 'd'
        || read_buffer[2] != 'e')
        return fail(16);
    if (vibe_user_lseek(4, 0, 1) != 6)
        return fail(17);
    if (vibe_user_pread(4, read_buffer, 1, -1) != -22)
        return fail(18);
    if (vibe_user_close(4) != 0 || mock_close_count != 1)
        return fail(14);
    if (vibe_user_clock_monotonic(&now) != 0 || now.frequency_hz != VIBE_CLOCK_MONOTONIC_HZ)
        return fail(9);
    if (vibe_user_listdir("/", entries, MOCK_MAX_DIRENTS) != 1 || !vibe_user_streq(entries[0].name, "TOOL"))
        return fail(10);
    if (vibe_user_listdir_find("/", "TOOL", entries) != 1 || !vibe_user_streq(entries[0].name, "TOOL"))
        return fail(48);
    if (vibe_user_listdir_find("/", "MISSING", entries) != 0)
        return fail(49);
    if (!vibe_user_dirent_name_eq(entries, "TOOL") || vibe_user_dirent_name_eq(0, "TOOL"))
        return fail(50);
    if (vibe_user_validate_exec_argv("TOOL.ELF", argv, &argc) != 0 || argc != 1)
        return fail(51);
    if (vibe_user_validate_exec_argv("TOOL.ELF", 0, &argc) != 0 || argc != 1)
        return fail(52);
    long_path[0] = 'A';
    long_path[1] = 'B';
    long_path[2] = 'C';
    long_path[3] = 'D';
    long_path[4] = 'E';
    long_path[5] = 'F';
    long_path[6] = 'G';
    long_path[7] = 'H';
    long_path[8] = 'I';
    long_path[9] = 'J';
    long_path[10] = 'K';
    long_path[11] = 'L';
    long_path[12] = 'M';
    long_path[13] = 'N';
    long_path[14] = 'O';
    long_path[15] = 'P';
    long_path[16] = 0;
    if (vibe_user_validate_exec_argv(long_path, argv, &argc) != -22)
        return fail(53);
    for (index = 0; index < VIBE_EXEC_ARG_STR_MAX; ++index)
        long_arg[index] = 'A';
    long_arg[VIBE_EXEC_ARG_STR_MAX] = 0;
    argv[0] = long_arg;
    if (vibe_user_validate_exec_argv("TOOL.ELF", argv, &argc) != -22)
        return fail(54);
    argv[0] = "TOOL.ELF";
    if (vibe_user_execv("TOOL.ELF", argv) != 0 || mock_exec_count != 1 || !vibe_user_streq(mock_exec_path, "TOOL.ELF"))
        return fail(11);
    if (vibe_user_execv_checked("", argv) != -22 || mock_exec_count != 1)
        return fail(55);
    if (vibe_user_execve("TOOL.ELF", argv, nonempty_env) != -38 || mock_exec_count != 1)
        return fail(56);
    if (vibe_user_execve("TOOL.ELF", 0, empty_env) != 0 || mock_exec_count != 2 || mock_exec_argv != 0)
        return fail(57);
    vibe_user_report_probe(0x1234u, 0x55u);
    if (mock_probe_count != 1 || mock_probe_magic != 0x1234u || mock_probe_flags != 0x55u)
        return fail(12);

    return 0;
}
