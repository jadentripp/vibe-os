# Build static Linux i386 test binaries with the repo's own toolchain.
#
# On this host there is no GNU `as --32` / `ld -m elf_i386` / musl-gcc, so the
# binaries are assembled with NASM (-f elf32) and linked with the repo's
# build/link_elf32 (the same linker that builds the kernel and the Doom/Quake
# app ELFs). link_elf32's entry symbol is `start`.
#
# Usage:
#   make -C tests/linux            # build all test binaries
#   make -C tests/linux clean
NASM      ?= nasm
ZIG       ?= zig
REPO_ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../..)
LINK_ELF32 ?= $(REPO_ROOT)/build/link_elf32
# vibe-os maps a fixed user window (USER_CODE_ADDR=0x00e80000 .. 0x01400000)
# per process and the loader copies into it; link the M-1 hand-asm binaries
# at USER_CODE_ADDR so they reuse that window. (Real glibc at 0x08048000 needs
# the out-of-window mapping extension handled in Task 7.)
BASE      ?= 0x00e80000
LINUX_CFLAGS ?= -Os -no-pie -march=i386 -mno-sse -mno-sse2
LINUX_LDFLAGS ?= -Wl,--image-base=$(BASE)
LDOOM_BASE ?= 0x01000000
DOOM_SRC_DIR := $(REPO_ROOT)/third_party/doom/linuxdoom-1.10
DOOM_ORIGINAL_SRCS := $(filter-out $(DOOM_SRC_DIR)/i_%.c,$(wildcard $(DOOM_SRC_DIR)/*.c))
LDOOM_CFLAGS ?= -Os -std=gnu89 -fcommon -no-pie -march=i386 -mno-sse -mno-sse2 -Wno-implicit-function-declaration -Wno-int-conversion -DNORMALUNIX -DLINUX -I$(DOOM_SRC_DIR)
LDOOM_LDFLAGS ?= -static -Wl,--image-base=$(LDOOM_BASE) -Wl,--strip-all

BINARIES := hello_write auxv_dump tls_probe startup_probe exec_limits_probe execve_probe vfork_exec_probe vfork_child_probe vfork_exit_group_probe vfork_exit_group_child dir_probe fd_probe dev_null_probe llseek_probe pipe_probe fork_probe clone3_probe proc_self_exe_probe tmp_dir_probe procid_probe libmagic_probe ldso_header_probe ldso_reloc_probe writev_probe eventfd_probe epoll_probe timerfd_probe futex_probe thread_probe rseq_probe

.PHONY: all clean real-libc linux-doom
all: $(BINARIES)
real-libc: hello_musl hello_glibc libc_probe
linux-doom: linux_doom

# link_elf32 is produced by the top-level Makefile.
$(LINK_ELF32):
	$(MAKE) -C $(REPO_ROOT) build/link_elf32

%.o: %.asm
	$(NASM) -f elf32 $< -o $@

%: %.o $(LINK_ELF32)
	$(LINK_ELF32) -o $@ --base $(BASE) $<

hello_musl: hello_musl.c
	$(ZIG) cc -target x86-linux-musl -static $(LINUX_CFLAGS) $(LINUX_LDFLAGS) $< -o $@

hello_glibc: hello_glibc.c
	$(ZIG) cc -target x86-linux-gnu $(LINUX_CFLAGS) $(LINUX_LDFLAGS) $< -o $@

libc_probe: libc_probe.c
	$(ZIG) cc -target x86-linux-gnu $(LINUX_CFLAGS) $(LINUX_LDFLAGS) $< -o $@

linux_doom: linux_doom_headless.c $(DOOM_ORIGINAL_SRCS)
	$(ZIG) cc -target x86-linux-musl $(LDOOM_CFLAGS) $(LDOOM_LDFLAGS) $^ -o $@

clean:
	rm -f *.o $(BINARIES) hello_musl hello_glibc libc_probe linux_doom
