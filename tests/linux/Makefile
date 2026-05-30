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
REPO_ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../..)
LINK_ELF32 ?= $(REPO_ROOT)/build/link_elf32
BASE      ?= 0x08048000

BINARIES := hello_write

.PHONY: all clean
all: $(BINARIES)

# link_elf32 is produced by the top-level Makefile.
$(LINK_ELF32):
	$(MAKE) -C $(REPO_ROOT) build/link_elf32

%.o: %.asm
	$(NASM) -f elf32 $< -o $@

%: %.o $(LINK_ELF32)
	$(LINK_ELF32) -o $@ --base $(BASE) $<

clean:
	rm -f *.o $(BINARIES)
