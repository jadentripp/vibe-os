NASM ?= nasm
QEMU ?= qemu-system-x86_64
PYTHON ?= python3
CLANG ?= clang
QEMU_ACCEL ?= tcg
QEMU_MACHINE := pc,accel=$(QEMU_ACCEL)
ALLOW_LOCAL_VM ?= 0

BUILD_DIR := build
STAGE1_BIN := $(BUILD_DIR)/stage1.bin
STAGE2_BIN := $(BUILD_DIR)/stage2.bin
KERNEL_OBJ := $(BUILD_DIR)/kernel.o
C_RUNTIME_OBJ := $(BUILD_DIR)/c_runtime_probe.o
KERNEL_ELF := $(BUILD_DIR)/kernel.elf
USER_CRT0_OBJ := $(BUILD_DIR)/user_crt0.o
USER_PROBE_C_OBJ := $(BUILD_DIR)/user_probe_c.o
USER_PROBE_ELF := $(BUILD_DIR)/user_probe.elf
IMAGE := $(BUILD_DIR)/disk.img
C_RUNTIME_SRC := kernel/c_runtime_probe.c
USER_PROBE_C_SRC := user/probe.c
DOOM_SRC_DIR := third_party/doom/linuxdoom-1.10
DOOM_PORT_INCLUDE_DIR := doom_port/include
DOOM_PORT_BUILD_DIR := $(BUILD_DIR)/doom
DOOM_ELF := $(BUILD_DIR)/doom.elf
DOOM_BASE := 0x01000000
DOOM_ORIGINAL_SRCS := $(filter-out $(DOOM_SRC_DIR)/i_%.c,$(wildcard $(DOOM_SRC_DIR)/*.c))
DOOM_ORIGINAL_OBJS := $(DOOM_ORIGINAL_SRCS:$(DOOM_SRC_DIR)/%.c=$(DOOM_PORT_BUILD_DIR)/%.o)
DOOM_PORT_SRCS := doom_port/libc.c doom_port/platform.c doom_port/start.c
DOOM_PORT_OBJS := $(DOOM_PORT_SRCS:doom_port/%.c=$(DOOM_PORT_BUILD_DIR)/port_%.o)
FREESTANDING_I386_CFLAGS := -target i386-unknown-elf -ffreestanding -fno-builtin -fno-stack-protector -fno-pic -fno-asynchronous-unwind-tables -fno-unwind-tables -m32 -march=i386 -mno-sse -mno-mmx -msoft-float -O2
DOOM_ORIGINAL_CFLAGS := $(FREESTANDING_I386_CFLAGS) -std=gnu89 -DNORMALUNIX -DLINUX -I$(DOOM_PORT_INCLUDE_DIR) -I$(DOOM_SRC_DIR)

STAGE2_MAX_BYTES := 8192
KERNEL_ELF_MAX_BYTES := 49152
USER_PROBE_ELF_MAX_BYTES := 8192

.PHONY: all test doom-compile doom-link run run-headless smoke clean check-tools vm-consent

all: $(IMAGE)

test: $(IMAGE) doom-link
	$(PYTHON) -m unittest discover -s tests/host -p 'test_*.py'

doom-compile: $(DOOM_ORIGINAL_OBJS)
	@printf "Compiled %s original Doom source files for freestanding i386.\n" "$$(printf '%s\n' $(DOOM_ORIGINAL_OBJS) | wc -l | tr -d ' ')"

doom-link: $(DOOM_ELF)
	@printf "Linked freestanding Doom ELF at %s\n" "$(DOOM_ELF)"

check-tools:
	@command -v $(NASM) >/dev/null || { echo "missing nasm"; exit 1; }
	@command -v $(QEMU) >/dev/null || { echo "missing qemu-system-x86_64"; exit 1; }
	@command -v $(PYTHON) >/dev/null || { echo "missing python3"; exit 1; }
	@command -v $(CLANG) >/dev/null || { echo "missing clang"; exit 1; }

vm-consent:
	@if [ "$(ALLOW_LOCAL_VM)" != "1" ]; then \
		echo "Local QEMU execution is disabled by default."; \
		echo "Build-only targets are still allowed: make"; \
		echo "Rerun with ALLOW_LOCAL_VM=1 to use run, run-headless, or smoke."; \
		exit 1; \
	fi

$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

$(DOOM_PORT_BUILD_DIR):
	@mkdir -p $(DOOM_PORT_BUILD_DIR)

$(STAGE1_BIN): boot/stage1.asm | $(BUILD_DIR)
	$(NASM) -f bin $< -o $@

$(STAGE2_BIN): boot/stage2.asm | $(BUILD_DIR)
	$(NASM) -f bin $< -o $@
	@test $$(wc -c < $@) -le $(STAGE2_MAX_BYTES) || { echo "stage2 exceeds $(STAGE2_MAX_BYTES) bytes"; exit 1; }

$(KERNEL_OBJ): kernel/kernel.asm | $(BUILD_DIR)
	$(NASM) -f elf32 -D ELF_KERNEL $< -o $@

$(C_RUNTIME_OBJ): $(C_RUNTIME_SRC) | $(BUILD_DIR)
	$(CLANG) $(FREESTANDING_I386_CFLAGS) -c $< -o $@

$(KERNEL_ELF): $(KERNEL_OBJ) $(C_RUNTIME_OBJ) tools/link_elf32.py | $(BUILD_DIR)
	$(PYTHON) tools/link_elf32.py -o $@ --base 0x10000 $(KERNEL_OBJ) $(C_RUNTIME_OBJ)
	@test $$(wc -c < $@) -le $(KERNEL_ELF_MAX_BYTES) || { echo "kernel ELF exceeds $(KERNEL_ELF_MAX_BYTES) bytes"; exit 1; }

$(USER_CRT0_OBJ): user/crt0.asm | $(BUILD_DIR)
	$(NASM) -f elf32 $< -o $@

$(USER_PROBE_C_OBJ): $(USER_PROBE_C_SRC) | $(BUILD_DIR)
	$(CLANG) $(FREESTANDING_I386_CFLAGS) -c $< -o $@

$(DOOM_PORT_BUILD_DIR)/%.o: $(DOOM_SRC_DIR)/%.c | $(DOOM_PORT_BUILD_DIR)
	$(CLANG) $(DOOM_ORIGINAL_CFLAGS) -c $< -o $@

$(DOOM_PORT_BUILD_DIR)/port_%.o: doom_port/%.c | $(DOOM_PORT_BUILD_DIR)
	$(CLANG) $(DOOM_ORIGINAL_CFLAGS) -c $< -o $@

$(DOOM_ELF): $(DOOM_ORIGINAL_OBJS) $(DOOM_PORT_OBJS) tools/link_elf32.py | $(BUILD_DIR)
	$(PYTHON) tools/link_elf32.py -o $@ --base $(DOOM_BASE) $(DOOM_ORIGINAL_OBJS) $(DOOM_PORT_OBJS)

$(USER_PROBE_ELF): $(USER_CRT0_OBJ) $(USER_PROBE_C_OBJ) tools/link_elf32.py | $(BUILD_DIR)
	$(PYTHON) tools/link_elf32.py -o $@ --base 0x00e80000 $(USER_CRT0_OBJ) $(USER_PROBE_C_OBJ)
	@test $$(wc -c < $@) -le $(USER_PROBE_ELF_MAX_BYTES) || { echo "user probe ELF exceeds $(USER_PROBE_ELF_MAX_BYTES) bytes"; exit 1; }

$(IMAGE): $(STAGE1_BIN) $(STAGE2_BIN) $(KERNEL_ELF) $(USER_PROBE_ELF) $(DOOM_ELF) tools/make_wad_image.py
	$(PYTHON) tools/make_wad_image.py $@ $(STAGE1_BIN) $(STAGE2_BIN) $(KERNEL_ELF) $(USER_PROBE_ELF) $(DOOM_ELF)
	@printf "Built %s\n" "$@"

run: vm-consent check-tools $(IMAGE)
	$(QEMU) -machine $(QEMU_MACHINE) -drive file=$(IMAGE),format=raw,if=ide,index=0,media=disk -boot c

run-headless: vm-consent check-tools $(IMAGE)
	$(QEMU) -machine $(QEMU_MACHINE) -drive file=$(IMAGE),format=raw,if=ide,index=0,media=disk -boot c -display none -monitor none

smoke: vm-consent check-tools $(IMAGE)
	@rm -f $(BUILD_DIR)/monitor.sock $(BUILD_DIR)/vga.bin $(BUILD_DIR)/vga.txt $(BUILD_DIR)/status.bin $(BUILD_DIR)/status.txt $(BUILD_DIR)/gfx.bin
	@set -e; \
	$(QEMU) -machine $(QEMU_MACHINE) -drive file=$(IMAGE),format=raw,if=ide,index=0,media=disk -boot c -display none -serial none -monitor unix:$(BUILD_DIR)/monitor.sock,server,nowait -no-reboot -no-shutdown & \
	pid=$$!; \
	sleep 5; \
	printf "pmemsave 0xb8000 4000 $(BUILD_DIR)/vga.bin\npmemsave 0x9d000 1024 $(BUILD_DIR)/status.bin\npmemsave 0xa0000 64000 $(BUILD_DIR)/gfx.bin\nquit\n" | nc -U $(BUILD_DIR)/monitor.sock >/dev/null; \
	wait $$pid >/dev/null 2>&1 || true; \
	test -s $(BUILD_DIR)/status.bin; \
	perl -e 'local $$/; $$d = <>; for ($$i = 0; $$i < length($$d); $$i += 2) { $$c = ord(substr($$d, $$i, 1)); print chr($$c || 32); }' $(BUILD_DIR)/vga.bin > $(BUILD_DIR)/vga.txt; \
	perl -e 'local $$/; $$d = <>; $$d =~ s/\0/ /g; print $$d' $(BUILD_DIR)/status.bin > $(BUILD_DIR)/status.txt; \
	grep -q "Aurora OS v0.2" $(BUILD_DIR)/status.txt; \
	grep -q "pg=ON" $(BUILD_DIR)/status.txt; \
	grep -q "pmm=OK" $(BUILD_DIR)/status.txt; \
	grep -q "vmm=OK" $(BUILD_DIR)/status.txt; \
	grep -q "libc=OK" $(BUILD_DIR)/status.txt; \
	grep -q "c=OK" $(BUILD_DIR)/status.txt; \
	grep -q "usr=OK" $(BUILD_DIR)/status.txt; \
	grep -q "wad=OK" $(BUILD_DIR)/status.txt; \
	grep -q "lmp=OK" $(BUILD_DIR)/status.txt; \
	grep -q "doom=OK" $(BUILD_DIR)/status.txt; \
	grep -Eq "doomrun=(RUN|EXIT)" $(BUILD_DIR)/status.txt; \
	grep -q "doomopen=OK" $(BUILD_DIR)/status.txt; \
	grep -q "doomread=OK" $(BUILD_DIR)/status.txt; \
	grep -q "gfx=OK" $(BUILD_DIR)/status.txt; \
	grep -q "heap=OK" $(BUILD_DIR)/status.txt; \
	test -s $(BUILD_DIR)/gfx.bin; \
	perl -e 'local $$/; $$d = <>; exit(length($$d) == 64000 && ord(substr($$d, 0, 1)) == 0 && ord(substr($$d, 1, 1)) == 1 && ord(substr($$d, 320, 1)) == 64 && ord(substr($$d, 63999, 1)) == 255 ? 0 : 1)' $(BUILD_DIR)/gfx.bin; \
	perl -ne '$$ok = 1 if /heap=OK free=([0-9A-F]{8})/ && hex($$1) >= 0x00700000; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
	perl -ne '$$ok = 1 if /ticks=([0-9A-F]{8})/ && hex($$1) > 0; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
	printf "Smoke boot OK: protected-mode kernel status, Ring 3 probe, Doom ELF load, indexed-frame present, and PIT ticks verified in cloud VM memory.\n"

clean:
	rm -rf $(BUILD_DIR)
