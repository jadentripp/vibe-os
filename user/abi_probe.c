#include "runtime.h"
#include "sys/stat.h"

enum {
    ABI_PROBE_MAGIC = 0xA81B10BEu,
    ABI_PROBE_FLAG_ARGS = 0x00000001u,
    ABI_PROBE_FLAG_CLOCK = 0x00000002u,
    ABI_PROBE_FLAG_ROOT = 0x00000004u,
    ABI_PROBE_FLAG_FCNTL = 0x00000008u,
    ABI_PROBE_FLAG_FORK = 0x00000010u,
    ABI_PROBE_FLAG_EXEC_ENV = 0x00000020u,
    ABI_PROBE_FLAG_INPUT = 0x00000040u,
    ABI_PROBE_FLAG_FRAMEBUFFER = 0x00000080u,
    ABI_PROBE_FLAG_PROCESS = 0x00000100u,
    ABI_PROBE_FLAG_FILES = 0x00000200u,
    ABI_PROBE_SUCCESS_FLAGS = ABI_PROBE_FLAG_ARGS | ABI_PROBE_FLAG_CLOCK | ABI_PROBE_FLAG_ROOT | ABI_PROBE_FLAG_FCNTL | ABI_PROBE_FLAG_FORK | ABI_PROBE_FLAG_EXEC_ENV | ABI_PROBE_FLAG_INPUT | ABI_PROBE_FLAG_FRAMEBUFFER | ABI_PROBE_FLAG_PROCESS | ABI_PROBE_FLAG_FILES,
    ABI_PROBE_SEEK_SET = 0,
    ABI_PROBE_SEEK_CUR = 1,
    ABI_PROBE_SEEK_END = 2,
    ABI_PROBE_ERRNO_ENOENT = 2,
    ABI_PROBE_ERRNO_EACCES = 13,
    ABI_PROBE_ERRNO_EINVAL = 22,
    ABI_PROBE_ERRNO_ECHILD = 10,
    ABI_PROBE_F_GETFD = VIBE_USER_F_GETFD,
    ABI_PROBE_F_SETFD = VIBE_USER_F_SETFD,
    ABI_PROBE_FD_CLOEXEC = VIBE_USER_FD_CLOEXEC,
    ABI_PROBE_FORK_WAIT_STATUS = 0x2a,
    ABI_PROBE_FORK_WAIT_SPINS = 200000,
    ABI_PROBE_MAP_BYTES = 4096,
    ABI_PROBE_FAT_TAIL_CHUNKS = 24,
};

static unsigned char framebuffer_probe_frame[320 * 200];
static unsigned char framebuffer_probe_palette[VIBE_FB_RGB24_PALETTE_BYTES];
static unsigned char audio_probe_samples[64];

static int prove_process_services(int pid)
{
    vibe_process_status_t status;
    vibe_clock_time_t before;
    vibe_clock_time_t after;
    int parent_pid;

    if (vibe_user_process_status_current(&status) != 0)
        return 0;
    if (status.abi_version != VIBE_PROCESS_STATUS_ABI_VERSION || status.status_bytes != VIBE_PROCESS_STATUS_BYTES)
        return 0;
    if (status.pid != (unsigned long)pid || status.state != VIBE_PROCESS_STATE_RUNNING)
        return 0;
    if (status.kind != VIBE_PROCESS_KIND_PROBE && status.kind != VIBE_PROCESS_KIND_GENERIC)
        return 0;
    parent_pid = vibe_user_getppid();
    if (parent_pid <= 0 || (unsigned long)parent_pid != status.parent_pid)
        return 0;
    if (vibe_user_process_status(pid, &status) != 0 || status.pid != (unsigned long)pid)
        return 0;
    if (vibe_user_process_status(-1, &status) != -22)
        return 0;
    if (vibe_user_clock_monotonic(&before) != 0)
        return 0;
    if (vibe_user_yield() != 0)
        return 0;
    if (vibe_user_sleep_ticks(1) != 0)
        return 0;
    if (vibe_user_clock_monotonic(&after) != 0)
        return 0;
    if (after.ticks <= before.ticks)
        return 0;
    if (vibe_user_process_status_current(&status) != 0)
        return 0;
    return status.pid == (unsigned long)pid && status.scheduler_ticks >= after.ticks;
}

static int root_contains(const vibe_dirent_t* entries, int count, const char* name)
{
    for (int index = 0; index < count; ++index) {
        if (vibe_dirent_is_regular_file(&entries[index]) && vibe_user_streq(entries[index].name, name))
            return 1;
    }
    return 0;
}

static int dir_contains(const vibe_dirent_t* entries, int count, const char* name, int want_directory)
{
    for (int index = 0; index < count; ++index) {
        if (!vibe_user_streq(entries[index].name, name))
            continue;
        if (want_directory)
            return vibe_dirent_is_directory(&entries[index]);
        return vibe_dirent_is_regular_file(&entries[index]);
    }
    return 0;
}

static int bytes_equal(const unsigned char* left, const char* right, unsigned long count)
{
    for (unsigned long index = 0; index < count; ++index) {
        if (left[index] != (unsigned char)right[index])
            return 0;
    }
    return 1;
}

static int prove_generic_file_services(void)
{
    static vibe_dirent_t entries[16];
    static unsigned char buffer[80];
    const char asset_dir[] = "/ASSETS";
    const char asset_file[] = "./assets/readme.txt";
    const char nested_asset[] = "/ASSETS/MAPS/E1M1.MAP";
    const char state_dir[] = "\\STATE";
    const char state_file[] = "./state/session.dat";
    const char asset_expected[] = "vibe-os FAT16 one-level asset file\n";
    const char state_payload[] = "abi-fs-state\n";
    const char state_pwrite_expected[] = "abi-GENstate\n";
    struct stat st;
    unsigned long size = 0;
    unsigned long bytes_read = 0;
    unsigned long bytes_written = 0;
    unsigned long large_size = 0;
    int count;
    int fd;
    int chunk;
    int index;

    count = vibe_user_listdir("/", entries, 16);
    if (count <= 0)
        return 0;
    if (!dir_contains(entries, count, "ASSETS", 1))
        return 0;
    if (!dir_contains(entries, count, "STATE", 1))
        return 0;

    count = vibe_user_listdir(asset_dir, entries, 16);
    if (count <= 0)
        return 0;
    if (!dir_contains(entries, count, "README.TXT", 0))
        return 0;
    if (!dir_contains(entries, count, "MAPS", 1))
        return 0;

    if (vibe_user_file_size(asset_file, &size) != 0)
        return 0;
    if (size != sizeof(asset_expected) - 1)
        return 0;
    if (vibe_user_file_read_all(asset_file, buffer, sizeof(buffer), &bytes_read) != 0)
        return 0;
    if (bytes_read != size)
        return 0;
    if (!bytes_equal(buffer, asset_expected, size))
        return 0;
    if (vibe_user_file_read_at(asset_file, 8, buffer, 5, &bytes_read) != 0)
        return 0;
    if (bytes_read != 5 || !bytes_equal(buffer, "FAT16", 5))
        return 0;
    if (vibe_user_open(asset_file, VIBE_USER_O_WRONLY, 0) != -ABI_PROBE_ERRNO_EACCES)
        return 0;
    if (vibe_user_file_size(nested_asset, &size) != -ABI_PROBE_ERRNO_EINVAL)
        return 0;

    if (vibe_user_stat(state_dir, &st) != 0 || !S_ISDIR(st.st_mode))
        return 0;
    fd = vibe_user_open(
        state_file,
        VIBE_USER_O_CREAT | VIBE_USER_O_RDWR | VIBE_USER_O_TRUNC,
        0);
    if (fd < 0)
        return 0;
    if (vibe_user_write(fd, state_payload, sizeof(state_payload) - 1) != (int)(sizeof(state_payload) - 1))
        goto fail_fd;
    if (vibe_user_lseek(fd, 0, VIBE_USER_SEEK_SET) != 0)
        goto fail_fd;
    if (vibe_user_read(fd, buffer, sizeof(state_payload) - 1) != (int)(sizeof(state_payload) - 1))
        goto fail_fd;
    if (!bytes_equal(buffer, state_payload, sizeof(state_payload) - 1))
        goto fail_fd;
    if (vibe_user_lseek(fd, 3, VIBE_USER_SEEK_SET) != 3)
        goto fail_fd;
    if (vibe_user_pwrite(fd, "GEN", 3, 4) != 3)
        goto fail_fd;
    if (vibe_user_lseek(fd, 0, VIBE_USER_SEEK_CUR) != 3)
        goto fail_fd;
    if (vibe_user_lseek(fd, 0, VIBE_USER_SEEK_SET) != 0)
        goto fail_fd;
    if (vibe_user_read(fd, buffer, sizeof(state_pwrite_expected) - 1) != (int)(sizeof(state_pwrite_expected) - 1))
        goto fail_fd;
    if (!bytes_equal(buffer, state_pwrite_expected, sizeof(state_pwrite_expected) - 1))
        goto fail_fd;
    if (vibe_user_fstat(fd, &st) != 0 || st.st_size != (off_t)(sizeof(state_payload) - 1))
        goto fail_fd;
    for (index = 0; index < (int)sizeof(buffer); ++index)
        buffer[index] = (unsigned char)('A' + (index % 23));
    if (vibe_user_lseek(fd, 0, VIBE_USER_SEEK_SET) != 0)
        goto fail_fd;
    for (chunk = 0; chunk < ABI_PROBE_FAT_TAIL_CHUNKS; ++chunk) {
        if (vibe_user_write(fd, buffer, sizeof(buffer)) != (int)sizeof(buffer))
            goto fail_fd;
        large_size += sizeof(buffer);
    }
    if (vibe_user_fstat(fd, &st) != 0 || st.st_size != (off_t)large_size)
        goto fail_fd;
    if (vibe_user_ftruncate(fd, 1) != 0)
        goto fail_fd;
    if (vibe_user_lseek(fd, 0, VIBE_USER_SEEK_END) != 1)
        goto fail_fd;
    if (vibe_user_lseek(fd, 0, VIBE_USER_SEEK_SET) != 0)
        goto fail_fd;
    if (vibe_user_read(fd, buffer, 1) != 1 || buffer[0] != 'A')
        goto fail_fd;
    if (vibe_user_ftruncate(fd, 4) != 0)
        goto fail_fd;
    if (vibe_user_lseek(fd, 0, VIBE_USER_SEEK_END) != 4)
        goto fail_fd;
    if (vibe_user_ftruncate(fd, 0) != 0)
        goto fail_fd;
    if (vibe_user_close(fd) != 0)
        return 0;
    if (vibe_user_unlink(state_file) != 0)
        return 0;
    if (vibe_user_stat(state_file, &st) != -ABI_PROBE_ERRNO_ENOENT)
        return 0;
    if (vibe_user_file_write_at(state_file, 2, "xy", 2, &bytes_written) != 0 || bytes_written != 2)
        return 0;
    if (vibe_user_file_read_all(state_file, buffer, sizeof(buffer), &bytes_read) != 0)
        return 0;
    if (bytes_read != 4 || buffer[0] != 0 || buffer[1] != 0 || buffer[2] != 'x' || buffer[3] != 'y')
        return 0;
    if (vibe_user_unlink(state_file) != 0)
        return 0;
    if (vibe_user_stat(state_file, &st) != -ABI_PROBE_ERRNO_ENOENT)
        return 0;

    return 1;

fail_fd:
    (void)vibe_user_close(fd);
    (void)vibe_user_unlink(state_file);
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
    int helper_status = 0;
    int child;
    int helper_child;
    int reaped;
    int fork_wad = vibe_user_open(wad_path, 0, 0);

    if (fork_wad < 0)
        return 0;
    if (vibe_user_lseek(fork_wad, 0, ABI_PROBE_SEEK_SET) != 0) {
        (void)vibe_user_close(fork_wad);
        return 0;
    }

    child = vibe_user_fork();
    if (child == 0) {
        int child_status = child_saw_inherited_wad() ? ABI_PROBE_FORK_WAIT_STATUS : 31;
        vibe_user_exit(child_status);
        return child_status;
    }
    if (child < 0) {
        (void)vibe_user_close(fork_wad);
        return 0;
    }

    reaped = vibe_user_waitpid(child, &status, 0);
    if (reaped == child) {
        int duplicate_reap = vibe_user_waitpid(child, 0, VIBE_USER_WNOHANG);
        int shared_offset = vibe_user_lseek(fork_wad, 0, ABI_PROBE_SEEK_CUR);
        helper_child = vibe_user_fork();
        if (helper_child == 0) {
            vibe_user_exit(ABI_PROBE_FORK_WAIT_STATUS);
            return ABI_PROBE_FORK_WAIT_STATUS;
        }
        if (helper_child < 0) {
            (void)vibe_user_close(fork_wad);
            return 0;
        }
        reaped = vibe_user_waitpid_nohang_reap_exact(child, &status, ABI_PROBE_FORK_WAIT_SPINS);
        if (reaped != -ABI_PROBE_ERRNO_ECHILD) {
            (void)vibe_user_close(fork_wad);
            return 0;
        }
        reaped = vibe_user_waitpid_nohang_reap_exact(helper_child, &helper_status, ABI_PROBE_FORK_WAIT_SPINS);
        (void)vibe_user_close(fork_wad);
        return status == ABI_PROBE_FORK_WAIT_STATUS
            && reaped == helper_child
            && helper_status == ABI_PROBE_FORK_WAIT_STATUS
            && shared_offset == 4
            && duplicate_reap == -ABI_PROBE_ERRNO_ECHILD;
    }
    if (reaped < 0) {
        (void)vibe_user_close(fork_wad);
        return 0;
    }

    (void)vibe_user_close(fork_wad);
    return 0;
}

static int mapped_tail_is_zero(const unsigned char* mapped, unsigned long start)
{
    unsigned long index;

    for (index = start; index < 16; ++index) {
        if (mapped[index] != 0)
            return 0;
    }
    return 1;
}

static int prove_file_private_mapping(const char* wad_path)
{
    unsigned char* mapped = 0;
    unsigned char* tail = 0;
    unsigned char original_first = 0;
    int fd = vibe_user_open(wad_path, 0, 0);
    int file_size;
    int tail_offset;
    int tail_live_bytes;
    int ok = 0;

    if (fd < 0)
        return 0;
    if (vibe_user_lseek(fd, 7, ABI_PROBE_SEEK_SET) != 7)
        goto out;
    if (vibe_user_mmap_file_private(
            (void**)&mapped,
            ABI_PROBE_MAP_BYTES,
            VIBE_USER_PROT_READ | VIBE_USER_PROT_WRITE,
            fd,
            0) != 0)
        goto out;
    if (vibe_user_lseek(fd, 0, ABI_PROBE_SEEK_CUR) != 7)
        goto out_unmap_mapped;
    if (!((mapped[0] == 'I' || mapped[0] == 'P') && mapped[1] == 'W' && mapped[2] == 'A' && mapped[3] == 'D'))
        goto out_unmap_mapped;

    mapped[0] = 'X';
    if (vibe_user_lseek(fd, 0, ABI_PROBE_SEEK_SET) != 0)
        goto out_unmap_mapped;
    if (vibe_user_read(fd, &original_first, 1) != 1)
        goto out_unmap_mapped;
    if (!(original_first == 'I' || original_first == 'P'))
        goto out_unmap_mapped;
    if (vibe_user_munmap(mapped, ABI_PROBE_MAP_BYTES) != 0)
        goto out;
    mapped = 0;

    file_size = vibe_user_lseek(fd, 0, ABI_PROBE_SEEK_END);
    if (file_size < 2)
        goto out;
    tail_offset = file_size - 2;
    tail_live_bytes = file_size - tail_offset;
    if (vibe_user_mmap_file_private(
            (void**)&tail,
            ABI_PROBE_MAP_BYTES,
            VIBE_USER_PROT_READ | VIBE_USER_PROT_WRITE,
            fd,
            tail_offset) != 0)
        goto out;
    if (!mapped_tail_is_zero(tail, (unsigned long)tail_live_bytes))
        goto out_unmap_tail;
    ok = 1;

out_unmap_tail:
    if (tail)
        (void)vibe_user_munmap(tail, ABI_PROBE_MAP_BYTES);
out_unmap_mapped:
    if (mapped)
        (void)vibe_user_munmap(mapped, ABI_PROBE_MAP_BYTES);
out:
    (void)vibe_user_close(fd);
    return ok;
}

static int prove_framebuffer_device(void)
{
    vibe_fb_info_t info;
    vibe_fb_info_t after;
    vibe_present_indexed_t present;
    unsigned long frame_bytes;
    unsigned long index;

    if (vibe_user_fb_get_info(&info) != 0)
        return 0;
    if (!vibe_fb_info_supports_indexed_rgb24(&info))
        return 0;
    if (!vibe_fb_info_has_capability(&info, VIBE_FB_CAP_DIRTY_SOURCE_RECT))
        return 0;
    if (!vibe_fb_info_present_size_is_accepted(&info, info.max_present_width, info.max_present_height))
        return 0;

    frame_bytes = vibe_fb_info_present_frame_bytes(&info);
    if (frame_bytes == 0 || frame_bytes > sizeof(framebuffer_probe_frame))
        return 0;
    if (vibe_fb_info_present_palette_bytes(&info) != sizeof(framebuffer_probe_palette))
        return 0;

    for (index = 0; index < sizeof(framebuffer_probe_palette); index += 3) {
        unsigned long color = index / 3;
        framebuffer_probe_palette[index] = (unsigned char)color;
        framebuffer_probe_palette[index + 1] = (unsigned char)(255u - color);
        framebuffer_probe_palette[index + 2] = (unsigned char)((color * 3u) & 0xffu);
    }

    for (index = 0; index < frame_bytes; ++index)
        framebuffer_probe_frame[index] = (unsigned char)(((index + (index >> 8)) & 0xffu) | 1u);

    vibe_present_indexed_init(
        &present,
        framebuffer_probe_frame,
        framebuffer_probe_palette,
        info.max_present_width,
        info.max_present_height);
    if (!vibe_user_fb_can_present_indexed(&info, &present))
        return 0;
    if (vibe_user_present_indexed_checked(&present) != 0)
        return 0;
    if (vibe_user_fb_get_info(&after) != 0)
        return 0;
    if (!vibe_fb_info_has_capability(&after, VIBE_FB_CAP_DIRTY_SOURCE_RECT))
        return 0;
    if (!vibe_fb_info_dirty_rect_is_bounded(&after))
        return 0;
    return 1;
}

static int prove_audio_device(void)
{
    vibe_audio_device_info_t device;
    vibe_audio_pcm_ring_info_t ring;
    vibe_audio_stream_info_t stream;
    vibe_audio_pcm_desc_t format;
    vibe_audio_pcm_desc_t write_desc;
    unsigned long index;
    int handle;
    int queued;

    if (vibe_user_audio_device_info(&device) != 0)
        return 1;
    if (!vibe_audio_device_is_ready(&device))
        return 1;
    if (!vibe_audio_device_has_capability(
            &device,
            VIBE_AUDIO_CAP_PCM_RING | VIBE_AUDIO_CAP_PULL_STREAM))
        return 0;
    if (vibe_user_audio_device_start() < 0)
        return 0;
    if (vibe_user_audio_pcm_ring_info(&ring) != 0)
        return 0;
    if (!vibe_audio_pcm_ring_is_u8_stereo(&ring))
        return 0;
    if (ring.sample_rate != 11025 || ring.ring_bytes == 0 || ring.period_bytes == 0)
        return 0;

    for (index = 0; index < sizeof(audio_probe_samples); ++index)
        audio_probe_samples[index] = (unsigned char)(96u + ((index * 5u) & 63u));

    vibe_audio_pcm_desc_init(
        &format,
        0,
        0,
        11025,
        2,
        VIBE_AUDIO_FORMAT_U8_STEREO);
    handle = vibe_user_audio_pcm_open(&format);
    if (handle <= 0)
        return 0;

    vibe_audio_pcm_desc_init(
        &write_desc,
        audio_probe_samples,
        sizeof(audio_probe_samples),
        11025,
        2,
        VIBE_AUDIO_FORMAT_U8_STEREO);
    if (vibe_user_audio_pcm_write_desc((unsigned long)handle, &write_desc) != (int)sizeof(audio_probe_samples))
        return 0;
    if (vibe_user_audio_stream_info((unsigned long)handle, &stream) != 0)
        return 0;
    if (!vibe_audio_stream_matches_handle(&stream, (unsigned long)handle)
        || !vibe_audio_stream_uses_pull(&stream))
        return 0;
    queued = vibe_user_audio_pcm_buffered_bytes((unsigned long)handle);
    if (queued < (int)sizeof(audio_probe_samples))
        return 0;
    if (vibe_user_audio_pcm_drain((unsigned long)handle) < 0)
        return 0;
    if (vibe_user_audio_pcm_close((unsigned long)handle) != 0)
        return 0;

    return 1;
}

int user_main(int argc, char** argv, char** envp)
{
    static vibe_dirent_t root_entries[16];
    static vibe_clock_time_t now;
    static vibe_input_event_t input_event;
    static vibe_input_status_t input_status;
    static vibe_input_device_status_t keyboard_status;
    static vibe_input_device_status_t mouse_status;
    const char doom_path[] = "DOOM.ELF";
    const char missing_path[] = "NOPE.ELF";
    const char wad_path[] = "DOOM1.WAD";
    char* doom_argv[] = { (char*)doom_path, 0 };
    unsigned int flags = 0;
    int pid = vibe_user_getpid();
    int root_count = vibe_user_listdir("/", root_entries, 16);
    int clock_ok = vibe_user_clock_monotonic(&now) == 0;
    int wad;

    if (argc != 1 || !argv || !argv[0] || !vibe_user_streq(argv[0], "ABIPROBE.ELF"))
        return 10;
    if (argv[1] || !envp || !envp[0] || !vibe_user_streq(envp[0], "PROBE_LAUNCHER=USERPROB"))
        return 11;
    if (!envp[1] || !vibe_user_streq(envp[1], "ABI_ENV=present") || envp[2])
        return 11;
    flags |= ABI_PROBE_FLAG_ARGS;
    if (pid <= 0)
        return 12;
    if (!clock_ok || now.frequency_hz != VIBE_CLOCK_MONOTONIC_HZ)
        return 13;
    flags |= ABI_PROBE_FLAG_CLOCK;
    if (!prove_process_services(pid))
        return 34;
    flags |= ABI_PROBE_FLAG_PROCESS;
    if (root_count <= 0)
        return 14;
    if (!root_contains(root_entries, root_count, "ABIPROBE.ELF"))
        return 15;
    if (!root_contains(root_entries, root_count, "USERPROB.ELF"))
        return 16;
    if (!root_contains(root_entries, root_count, "DOOM.ELF"))
        return 17;
    flags |= ABI_PROBE_FLAG_ROOT;
    if (!prove_generic_file_services())
        return 35;
    flags |= ABI_PROBE_FLAG_FILES;

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
    if (!prove_file_private_mapping(wad_path))
        return 24;
    if (!prove_fork_clone(wad_path))
        return 24;
    flags |= ABI_PROBE_FLAG_FORK;
    if (vibe_user_execve("", doom_argv, envp) != -22)
        return 28;
    if (vibe_user_execve(missing_path, doom_argv, envp) != -ABI_PROBE_ERRNO_ENOENT)
        return 29;
    flags |= ABI_PROBE_FLAG_EXEC_ENV;
    if (vibe_user_input_status(&input_status) != 0)
        return 30;
    if (!vibe_input_status_abi_is_current(&input_status))
        return 31;
    if (!vibe_input_status_has_capability(&input_status, VIBE_INPUT_CAP_KEYBOARD)
        || !vibe_input_status_has_capability(&input_status, VIBE_INPUT_CAP_POLL_EVENT)
        || !vibe_input_status_has_capability(&input_status, VIBE_INPUT_CAP_STATUS))
        return 32;
    if (!vibe_input_status_uses_drop_oldest(&input_status)
        || !vibe_input_status_keyboard_is_ready(&input_status))
        return 32;
    if (vibe_user_poll_input(&input_event) < 0)
        return 32;
    if (vibe_user_input_device_status(VIBE_INPUT_DEVICE_KEYBOARD, &keyboard_status) != 0
        || !vibe_input_device_record_is_ready(&keyboard_status)
        || !vibe_input_device_status_has_capability(&keyboard_status, VIBE_INPUT_DEVICE_CAP_KEYS)
        || !vibe_input_device_status_has_capability(&keyboard_status, VIBE_INPUT_DEVICE_CAP_STATE_SNAPSHOT)
        || !vibe_input_device_status_counters_are_consistent(&keyboard_status))
        return 32;
    if (vibe_user_input_device_status(VIBE_INPUT_DEVICE_MOUSE, &mouse_status) != 0
        || !vibe_input_device_status_abi_is_current(&mouse_status)
        || !vibe_input_device_status_has_capability(&mouse_status, VIBE_INPUT_DEVICE_CAP_RELATIVE_POINTER)
        || !vibe_input_device_status_has_capability(&mouse_status, VIBE_INPUT_DEVICE_CAP_BUTTONS)
        || !vibe_input_device_status_has_capability(&mouse_status, VIBE_INPUT_DEVICE_CAP_STATE_SNAPSHOT)
        || !vibe_input_device_status_counters_are_consistent(&mouse_status))
        return 32;
    flags |= ABI_PROBE_FLAG_INPUT;
    if (!prove_framebuffer_device())
        return 33;
    flags |= ABI_PROBE_FLAG_FRAMEBUFFER;
    if (!prove_audio_device())
        return 35;

    vibe_user_write_all(1, "abi probe ok\n");
    vibe_user_report_probe(ABI_PROBE_MAGIC, flags);
    if (flags != ABI_PROBE_SUCCESS_FLAGS)
        return 25;

    return vibe_user_execv(doom_path, doom_argv) == 0 ? 0 : 26;
}
