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
USER_PROBE_OBJ := $(BUILD_DIR)/user_probe.o
USER_PROBE_ELF := $(BUILD_DIR)/user_probe.elf
IMAGE := $(BUILD_DIR)/disk.img
C_RUNTIME_SRC := kernel/c_runtime_probe.c

STAGE2_MAX_BYTES := 8192
KERNEL_ELF_MAX_BYTES := 49152
USER_PROBE_ELF_MAX_BYTES := 8192

.PHONY: all run run-headless smoke clean check-tools vm-consent

all: $(IMAGE)

check-tools:
	@command -v $(NASM) >/dev/null || { echo "missing nasm"; exit 1; }
	@command -v $(QEMU) >/dev/null || { echo "missing qemu-system-x86_64"; exit 1; }
	@command -v $(PYTHON) >/dev/null || { echo "missing python3"; exit 1; }
	@command -v $(CLANG) >/dev/null || { echo "missing clang"; exit 1; }

vm-consent:
	@if [ "$(ALLOW_LOCAL_VM)" != "1" ]; then \
		echo "Refusing to run a local VM on this Mac."; \
		echo "Build-only targets are still allowed: make"; \
		echo "For zero risk to this laptop, run QEMU only on a disposable remote host or separate machine."; \
		echo "If you explicitly accept local VM risk, rerun with ALLOW_LOCAL_VM=1."; \
		exit 1; \
	fi

$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

$(STAGE1_BIN): boot/stage1.asm | $(BUILD_DIR)
	$(NASM) -f bin $< -o $@

$(STAGE2_BIN): boot/stage2.asm | $(BUILD_DIR)
	$(NASM) -f bin $< -o $@
	@test $$(wc -c < $@) -le $(STAGE2_MAX_BYTES) || { echo "stage2 exceeds $(STAGE2_MAX_BYTES) bytes"; exit 1; }

$(KERNEL_OBJ): kernel/kernel.asm | $(BUILD_DIR)
	$(NASM) -f elf32 -D ELF_KERNEL $< -o $@

$(C_RUNTIME_OBJ): $(C_RUNTIME_SRC) | $(BUILD_DIR)
	$(CLANG) -target i386-unknown-elf -ffreestanding -fno-builtin -fno-stack-protector -fno-pic -fno-asynchronous-unwind-tables -fno-unwind-tables -m32 -march=i386 -mno-sse -mno-mmx -msoft-float -O2 -c $< -o $@

$(KERNEL_ELF): $(KERNEL_OBJ) $(C_RUNTIME_OBJ) tools/link_elf32.py | $(BUILD_DIR)
	$(PYTHON) tools/link_elf32.py -o $@ --base 0x10000 $(KERNEL_OBJ) $(C_RUNTIME_OBJ)
	@test $$(wc -c < $@) -le $(KERNEL_ELF_MAX_BYTES) || { echo "kernel ELF exceeds $(KERNEL_ELF_MAX_BYTES) bytes"; exit 1; }

$(USER_PROBE_OBJ): user/probe.asm | $(BUILD_DIR)
	$(NASM) -f elf32 $< -o $@

$(USER_PROBE_ELF): $(USER_PROBE_OBJ) tools/link_elf32.py | $(BUILD_DIR)
	$(PYTHON) tools/link_elf32.py -o $@ --base 0x00e80000 $(USER_PROBE_OBJ)
	@test $$(wc -c < $@) -le $(USER_PROBE_ELF_MAX_BYTES) || { echo "user probe ELF exceeds $(USER_PROBE_ELF_MAX_BYTES) bytes"; exit 1; }

$(IMAGE): $(STAGE1_BIN) $(STAGE2_BIN) $(KERNEL_ELF) $(USER_PROBE_ELF) tools/make_wad_image.py
	$(PYTHON) tools/make_wad_image.py $@ $(STAGE1_BIN) $(STAGE2_BIN) $(KERNEL_ELF) $(USER_PROBE_ELF)
	@printf "Built %s\n" "$@"

run: vm-consent check-tools $(IMAGE)
	$(QEMU) -machine $(QEMU_MACHINE) -drive file=$(IMAGE),format=raw,if=ide,index=0,media=disk -boot c

run-headless: vm-consent check-tools $(IMAGE)
	$(QEMU) -machine $(QEMU_MACHINE) -drive file=$(IMAGE),format=raw,if=ide,index=0,media=disk -boot c -display none -monitor none

smoke: vm-consent check-tools $(IMAGE)
	@rm -f $(BUILD_DIR)/monitor.sock $(BUILD_DIR)/vga.bin $(BUILD_DIR)/vga.txt
	@set -e; \
	$(QEMU) -machine $(QEMU_MACHINE) -drive file=$(IMAGE),format=raw,if=ide,index=0,media=disk -boot c -display none -serial none -monitor unix:$(BUILD_DIR)/monitor.sock,server,nowait -no-reboot -no-shutdown & \
	pid=$$!; \
	sleep 1; \
	printf "pmemsave 0xb8000 4000 $(BUILD_DIR)/vga.bin\nquit\n" | nc -U $(BUILD_DIR)/monitor.sock >/dev/null; \
	wait $$pid >/dev/null 2>&1 || true; \
	test -s $(BUILD_DIR)/vga.bin; \
	perl -e 'local $$/; $$d = <>; for ($$i = 0; $$i < length($$d); $$i += 2) { $$c = ord(substr($$d, $$i, 1)); print chr($$c || 32); }' $(BUILD_DIR)/vga.bin > $(BUILD_DIR)/vga.txt; \
	grep -q "Aurora OS v0.2" $(BUILD_DIR)/vga.txt; \
	grep -q "32-bit protected mode kernel online" $(BUILD_DIR)/vga.txt; \
	grep -q "aurora>" $(BUILD_DIR)/vga.txt; \
	grep -q "pg=ON" $(BUILD_DIR)/vga.txt; \
	grep -q "pmm=OK" $(BUILD_DIR)/vga.txt; \
	grep -q "vmm=OK" $(BUILD_DIR)/vga.txt; \
	grep -q "libc=OK" $(BUILD_DIR)/vga.txt; \
	grep -q "c=OK" $(BUILD_DIR)/vga.txt; \
	grep -q "usr=OK" $(BUILD_DIR)/vga.txt; \
	grep -q "wad=OK" $(BUILD_DIR)/vga.txt; \
	grep -q "lmp=OK" $(BUILD_DIR)/vga.txt; \
	grep -q "heap=OK" $(BUILD_DIR)/vga.txt; \
	perl -ne '$$ok = 1 if /heap=OK free=([0-9A-F]{8})/ && hex($$1) >= 0x00700000; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/vga.txt; \
	perl -ne '$$ok = 1 if /ticks=([0-9A-F]{8})/ && hex($$1) > 0; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/vga.txt; \
	printf "Smoke boot OK: protected-mode banner, Ring 3 probe, Doom-scale heap self-test, and PIT ticks reached VGA text buffer.\n"

clean:
	rm -rf $(BUILD_DIR)
