# Doom portability readiness

This port keeps the original Doom source tree under `third_party/doom`
read-only. Portability work belongs in `doom_port`, kernel syscalls, host tools,
and documentation. The host-only boundary checker is:

```sh
python3 tools/check_doom_portability_boundary.py
```

It verifies that `third_party/doom` has no worktree changes, that original Doom
sources do not mention Vibe OS syscall tokens, and that the Makefile keeps the
engine/port split explicit.

## Original files that compile unchanged

The current build compiles 57 original linuxdoom C files from
`third_party/doom/linuxdoom-1.10` without editing the vendor tree. The Makefile
derives that set with:

```make
DOOM_ORIGINAL_SRCS := $(filter-out $(DOOM_SRC_DIR)/i_%.c,$(wildcard $(DOOM_SRC_DIR)/*.c))
```

Two original files, `g_game.c` and `p_saveg.c`, are still original-source
compiles but use preprocessor symbol renames so the port layer can wrap selected
save/load functions for diagnostics and checkpoint requests. That is a link
boundary, not a vendor-source patch.

## Platform files replaced by the port

The original platform layer is intentionally excluded:

| Original file | Replacement | Boundary |
| --- | --- | --- |
| `i_main.c` | `doom_port/start.c` | process entry and static argv handoff |
| `i_system.c` | `doom_port/platform.c` | time, heap bootstrap, quit, error, and low-memory hooks |
| `i_video.c` | `doom_port/platform.c` | palette, indexed framebuffer presentation, and screen reads |
| `i_sound.c` | `doom_port/platform.c` and `doom_port/music.c` | sound/music lifecycle and host-independent audio queueing |
| `i_net.c` | `doom_port/platform.c` | single-player net stubs and tic command dispatch |

The replacement rule is deliberately narrow: `doom_port` may implement the
functions the original engine expects, but `third_party/doom` must not learn
about `VIBE_SYS_*`, `vibe_syscall3`, `vibe_os.h`, or `doom_port`.

## Reusable hooks

The same libc/platform surface, centered in `doom_port/libc.c` and declared
through `doom_port/include`, helps other original C games:

- files: `open`, `read`, `write`, `close`, `lseek`, `access`, `unlink`
- whole-file helpers: `vibe_file_size`, `vibe_file_read_all`
- metadata: `stat`, `fstat`, `mkdir`, `vibe_listdir`
- stdio: `fopen`, `fread`, `fwrite`, `fseek`, `fflush`, `fclose`
- memory: `malloc`, `calloc`, `realloc`, `free`, `mmap`, `munmap`,
  `vibe_mmap_anon`
- capability queries: `vibe_heap_capabilities`, `vibe_vm_capabilities`
- process: `execv`, `execve`, `execl`, `fork`, `waitpid`, `getpid`
- time: `clock_gettime`, `vibe_clock_gettime`, `vibe_clock_monotonic`,
  `vibe_clock_ticks_to_milliseconds`
- devices: `ioctl`, `vibe_fb_get_info`, `vibe_present_indexed`,
  `vibe_present_indexed_checked`
- game/tool runtime wrappers: `vibe_poll_input`, `vibe_input_status`, and
  `vibe_drain_input` so another original C program can consume typed input
  without copying raw syscall numbers from the Doom platform shim.

These hooks are intentionally honest about the present kernel surface. The
framebuffer wrapper can query `vibe_fb_info_t` and preflight an indexed present
against advertised caps, but the kernel still accepts only the current indexed
RGB24 source contract. The memory helpers expose anonymous private mappings and
brk-backed heap growth/shrink; file-backed mappings, shared mappings, a real VMA
table, and broad directory paths are still future kernel work rather than hidden
Doom-specific shortcuts.

Missing future hooks should be added to `doom_port/include` and proved with
host tests before a game-specific workaround is added. If a new game needs a
platform callback like `I_*`, prefer replacing that callback in the port layer
instead of editing the original game module.

## Safe validation

Safe local checks for this boundary are host-only:

```sh
python3 tools/check_doom_portability_boundary.py
python3 -m unittest tests.host.test_doom_portability_boundary
make ALLOW_LOCAL_VM=0 doom-compile doom-link
```

Do not run local QEMU on this Mac. Runtime/playability proof should stay in the
remote or cloud workflows described by the playability runbooks.
