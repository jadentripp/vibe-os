#include "runtime.h"

enum {
    ABI_PROBE_MAGIC = 0xA81B10BEu,
    ABI_PROBE_FLAG_ARGS = 0x00000001u,
    ABI_PROBE_FLAG_CLOCK = 0x00000002u,
    ABI_PROBE_FLAG_ROOT = 0x00000004u,
    ABI_PROBE_SUCCESS_FLAGS = ABI_PROBE_FLAG_ARGS | ABI_PROBE_FLAG_CLOCK | ABI_PROBE_FLAG_ROOT,
};

static int root_contains(const vibe_dirent_t* entries, int count, const char* name)
{
    for (int index = 0; index < count; ++index) {
        if (vibe_dirent_is_regular_file(&entries[index]) && vibe_user_streq(entries[index].name, name))
            return 1;
    }
    return 0;
}

int user_main(int argc, char** argv, char** envp)
{
    static vibe_dirent_t root_entries[16];
    static vibe_clock_time_t now;
    const char doom_path[] = "DOOM.ELF";
    char* doom_argv[] = { (char*)doom_path, 0 };
    unsigned int flags = 0;
    int pid = vibe_user_getpid();
    int root_count = vibe_user_listdir("/", root_entries, 16);
    int clock_ok = vibe_user_clock_monotonic(&now) == 0;

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

    vibe_user_write_all(1, "abi probe ok\n");
    vibe_user_report_probe(ABI_PROBE_MAGIC, flags);
    if (flags != ABI_PROBE_SUCCESS_FLAGS)
        return 18;

    return vibe_user_execv(doom_path, doom_argv) == 0 ? 0 : 19;
}
