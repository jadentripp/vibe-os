#include "runtime.h"

enum {
    ABI_PROBE_MAGIC = 0xA81B10BEu,
    ABI_PROBE_FLAG_ARGS = 0x00000001u,
    ABI_PROBE_FLAG_CLOCK = 0x00000002u,
    ABI_PROBE_FLAG_ROOT = 0x00000004u,
    ABI_PROBE_FLAG_FCNTL = 0x00000008u,
    ABI_PROBE_FLAG_FORK = 0x00000010u,
    ABI_PROBE_SUCCESS_FLAGS = ABI_PROBE_FLAG_ARGS | ABI_PROBE_FLAG_CLOCK | ABI_PROBE_FLAG_ROOT | ABI_PROBE_FLAG_FCNTL | ABI_PROBE_FLAG_FORK,
    ABI_PROBE_F_GETFD = 1,
    ABI_PROBE_F_SETFD = 2,
    ABI_PROBE_FD_CLOEXEC = 1,
    ABI_PROBE_SEEK_SET = 0,
    ABI_PROBE_SEEK_CUR = 1,
    ABI_PROBE_FORK_WAIT_STATUS = 0x2a,
    ABI_PROBE_FORK_WAIT_SPINS = 200000,
};

static int root_contains(const vibe_dirent_t* entries, int count, const char* name)
{
    for (int index = 0; index < count; ++index) {
        if (vibe_dirent_is_regular_file(&entries[index]) && vibe_user_streq(entries[index].name, name))
            return 1;
    }
    return 0;
}

static int child_saw_inherited_wad(void)
{
    unsigned char magic[4];

    for (int fd = 3; fd < 3 + 16; ++fd) {
        if (vibe_user_read(fd, magic, sizeof(magic)) != (int)sizeof(magic))
            continue;
        if (magic[0] == 'I' && magic[1] == 'W' && magic[2] == 'A' && magic[3] == 'D')
            return 1;
        if (magic[0] == 'P' && magic[1] == 'W' && magic[2] == 'A' && magic[3] == 'D')
            return 1;
    }
    return 0;
}

static int prove_fork_clone(const char* wad_path)
{
    int status = 0;
    int child;
    int fork_wad = vibe_user_open(wad_path, 0, 0);

    if (fork_wad < 0)
        return 0;
    if (vibe_user_lseek(fork_wad, 0, ABI_PROBE_SEEK_SET) != 0) {
        (void)vibe_user_close(fork_wad);
        return 0;
    }

    child = vibe_user_fork();
    if (child == 0)
        return child_saw_inherited_wad() ? ABI_PROBE_FORK_WAIT_STATUS : 31;
    if (child < 0) {
        (void)vibe_user_close(fork_wad);
        return 0;
    }

    for (int spin = 0; spin < ABI_PROBE_FORK_WAIT_SPINS; ++spin) {
        int reaped = vibe_user_waitpid(child, &status, VIBE_USER_WNOHANG);
        if (reaped == child) {
            int shared_offset = vibe_user_lseek(fork_wad, 0, ABI_PROBE_SEEK_CUR);
            (void)vibe_user_close(fork_wad);
            return status == ABI_PROBE_FORK_WAIT_STATUS && shared_offset == 4;
        }
        if (reaped < 0) {
            (void)vibe_user_close(fork_wad);
            return 0;
        }
    }

    (void)vibe_user_close(fork_wad);
    return 0;
}

int user_main(int argc, char** argv, char** envp)
{
    static vibe_dirent_t root_entries[16];
    static vibe_clock_time_t now;
    const char doom_path[] = "DOOM.ELF";
    const char wad_path[] = "DOOM1.WAD";
    char* doom_argv[] = { (char*)doom_path, 0 };
    unsigned int flags = 0;
    int pid = vibe_user_getpid();
    int root_count = vibe_user_listdir("/", root_entries, 16);
    int clock_ok = vibe_user_clock_monotonic(&now) == 0;
    int wad;

    if (argc != 1 || !argv || !argv[0] || !vibe_user_streq(argv[0], "ABIPROBE.ELF"))
        return 10;
    if (argv[1] || !envp || envp[0])
        return 11;
    flags |= ABI_PROBE_FLAG_ARGS;
    if (pid <= 0)
        return 12;
    if (!clock_ok || now.frequency_hz != VIBE_CLOCK_MONOTONIC_HZ)
        return 13;
    flags |= ABI_PROBE_FLAG_CLOCK;
    if (root_count <= 0)
        return 14;
    if (!root_contains(root_entries, root_count, "ABIPROBE.ELF"))
        return 15;
    if (!root_contains(root_entries, root_count, "USERPROB.ELF"))
        return 16;
    if (!root_contains(root_entries, root_count, "DOOM.ELF"))
        return 17;
    flags |= ABI_PROBE_FLAG_ROOT;

    wad = vibe_user_open(wad_path, 0, 0);
    if (wad < 0)
        return 18;
    if (vibe_user_fcntl(wad, ABI_PROBE_F_GETFD, 0) != 0)
        return 19;
    if (vibe_user_fcntl(wad, ABI_PROBE_F_SETFD, ABI_PROBE_FD_CLOEXEC) != 0)
        return 20;
    if (vibe_user_fcntl(wad, ABI_PROBE_F_GETFD, 0) != ABI_PROBE_FD_CLOEXEC)
        return 21;
    if (vibe_user_fcntl(wad, ABI_PROBE_F_SETFD, 0) != 0)
        return 22;
    if (vibe_user_close(wad) != 0)
        return 23;
    flags |= ABI_PROBE_FLAG_FCNTL;
    if (!prove_fork_clone(wad_path))
        return 24;
    flags |= ABI_PROBE_FLAG_FORK;

    vibe_user_write_all(1, "abi probe ok\n");
    vibe_user_report_probe(ABI_PROBE_MAGIC, flags);
    if (flags != ABI_PROBE_SUCCESS_FLAGS)
        return 25;

    return vibe_user_execv(doom_path, doom_argv) == 0 ? 0 : 26;
}
