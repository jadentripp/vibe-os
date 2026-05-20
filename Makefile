NASM ?= nasm
QEMU ?= qemu-system-x86_64
PYTHON ?= python3
CLANG ?= clang
NC ?= nc
KERNEL_EXTRA_NASMFLAGS ?=
QEMU_ACCEL ?= tcg
QEMU_MACHINE := pc,accel=$(QEMU_ACCEL)
QEMU_EXTRA_ARGS ?=
ALLOW_LOCAL_VM ?= 0
DOOM_WAD ?=
SMOKE_EXPECT_PROBE_GFX ?= 1
SMOKE_REJECT_DOOMLOG ?=
SMOKE_SENDKEYS ?=
SMOKE_INPUT_SCRIPT ?=
SMOKE_REQUIRE_DOOM_PRESENT ?= 0
SMOKE_REQUIRE_KEY_EVENT ?= 0
SMOKE_REQUIRE_DOOM_GAMEPLAY ?= 0
SMOKE_REQUIRE_REAL_WAD_PROOF ?= 0
SMOKE_REQUIRE_HUMAN_PLAYABILITY_PROOF ?= 0
SMOKE_REQUIRE_AUDIO_CONTINUITY ?= 0
SMOKE_SKIP_ASSERTIONS ?= 0
SMOKE_NC_TIMEOUT ?= 3
SMOKE_QEMU_TIMEOUT ?= 30
SMOKE_EARLY_SECONDS ?= 2
SMOKE_SETTLE_SECONDS ?= 5
SMOKE_SHUTDOWN_TIMEOUT ?= 5
SMOKE_CAPTURE_GFX ?= 1
SMOKE_EXPECT_GUEST_EXIT ?= 0
SMOKE_GUEST_EXIT_KEYS ?=
SMOKE_NO_REBOOT ?= 1
SMOKE_NO_SHUTDOWN ?= 1
PERSISTENCE_BASELINE_IMAGE ?=
PERSISTENCE_REQUIRE_DEFAULT ?= 0
PERSISTENCE_REQUIRE_SAVE_SLOT ?=

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
DOOM_SYMBOLS := $(BUILD_DIR)/doom.symbols
DOOM_BASE := 0x01000000
DOOM_ORIGINAL_SRCS := $(filter-out $(DOOM_SRC_DIR)/i_%.c,$(wildcard $(DOOM_SRC_DIR)/*.c))
DOOM_ORIGINAL_OBJS := $(DOOM_ORIGINAL_SRCS:$(DOOM_SRC_DIR)/%.c=$(DOOM_PORT_BUILD_DIR)/%.o)
DOOM_PORT_SRCS := doom_port/input.c doom_port/libc.c doom_port/music.c doom_port/platform.c doom_port/start.c
DOOM_PORT_OBJS := $(DOOM_PORT_SRCS:doom_port/%.c=$(DOOM_PORT_BUILD_DIR)/port_%.o)
FREESTANDING_I386_CFLAGS := -target i386-unknown-elf -ffreestanding -fno-builtin -fno-stack-protector -fno-pic -fno-asynchronous-unwind-tables -fno-unwind-tables -m32 -march=i386 -mno-sse -mno-mmx -msoft-float -O2
DOOM_ORIGINAL_CFLAGS := $(FREESTANDING_I386_CFLAGS) -std=gnu89 -DNORMALUNIX -DLINUX -I$(DOOM_PORT_INCLUDE_DIR) -I$(DOOM_SRC_DIR)

STAGE2_MAX_BYTES := 8192
KERNEL_ELF_MAX_BYTES := 98304
USER_PROBE_ELF_MAX_BYTES := 12288

.PHONY: all build-only test doom-compile doom-link run run-headless smoke playability-gap-check hardware-support-check vm-safety-check shutdown-panic-proof-check audio-continuity-check audible-audio-proof-check cloud-playability-check persistence-image-check clean check-tools vm-consent

all: $(IMAGE)

build-only: $(IMAGE) doom-link
	@printf "Build-only check OK: %s and %s are present.\n" "$(IMAGE)" "$(DOOM_ELF)"

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
	$(NASM) -f elf32 -D ELF_KERNEL $(KERNEL_EXTRA_NASMFLAGS) $< -o $@

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
	$(PYTHON) tools/link_elf32.py -o $@ --base $(DOOM_BASE) --map $(DOOM_SYMBOLS) $(DOOM_ORIGINAL_OBJS) $(DOOM_PORT_OBJS)

$(USER_PROBE_ELF): $(USER_CRT0_OBJ) $(USER_PROBE_C_OBJ) tools/link_elf32.py | $(BUILD_DIR)
	$(PYTHON) tools/link_elf32.py -o $@ --base 0x00e80000 $(USER_CRT0_OBJ) $(USER_PROBE_C_OBJ)
	@test $$(wc -c < $@) -le $(USER_PROBE_ELF_MAX_BYTES) || { echo "user probe ELF exceeds $(USER_PROBE_ELF_MAX_BYTES) bytes"; exit 1; }

$(IMAGE): $(STAGE1_BIN) $(STAGE2_BIN) $(KERNEL_ELF) $(USER_PROBE_ELF) $(DOOM_ELF) tools/make_wad_image.py
	@if [ -n "$(DOOM_WAD)" ]; then \
		$(PYTHON) tools/make_wad_image.py --wad "$(DOOM_WAD)" $@ $(STAGE1_BIN) $(STAGE2_BIN) $(KERNEL_ELF) $(USER_PROBE_ELF) $(DOOM_ELF); \
	else \
		$(PYTHON) tools/make_wad_image.py $@ $(STAGE1_BIN) $(STAGE2_BIN) $(KERNEL_ELF) $(USER_PROBE_ELF) $(DOOM_ELF); \
	fi
	@printf "Built %s\n" "$@"

run: vm-consent check-tools $(IMAGE)
	$(QEMU) -machine $(QEMU_MACHINE) -drive file=$(IMAGE),format=raw,if=ide,index=0,media=disk -boot c

run-headless: vm-consent check-tools $(IMAGE)
	$(QEMU) -machine $(QEMU_MACHINE) -drive file=$(IMAGE),format=raw,if=ide,index=0,media=disk -boot c -display none -monitor none

smoke: vm-consent check-tools $(IMAGE)
	@QEMU="$(QEMU)" \
		QEMU_MACHINE="$(QEMU_MACHINE)" \
		QEMU_EXTRA_ARGS="$(QEMU_EXTRA_ARGS)" \
		IMAGE="$(IMAGE)" \
		BUILD_DIR="$(BUILD_DIR)" \
		NC="$(NC)" \
		SMOKE_NC_TIMEOUT="$(SMOKE_NC_TIMEOUT)" \
		SMOKE_QEMU_TIMEOUT="$(SMOKE_QEMU_TIMEOUT)" \
		SMOKE_EARLY_SECONDS="$(SMOKE_EARLY_SECONDS)" \
		SMOKE_SETTLE_SECONDS="$(SMOKE_SETTLE_SECONDS)" \
		SMOKE_SHUTDOWN_TIMEOUT="$(SMOKE_SHUTDOWN_TIMEOUT)" \
		SMOKE_CAPTURE_GFX="$(SMOKE_CAPTURE_GFX)" \
		SMOKE_EXPECT_GUEST_EXIT="$(SMOKE_EXPECT_GUEST_EXIT)" \
		SMOKE_GUEST_EXIT_KEYS="$(SMOKE_GUEST_EXIT_KEYS)" \
		SMOKE_NO_REBOOT="$(SMOKE_NO_REBOOT)" \
		SMOKE_NO_SHUTDOWN="$(SMOKE_NO_SHUTDOWN)" \
		SMOKE_SENDKEYS="$(SMOKE_SENDKEYS)" \
		SMOKE_INPUT_SCRIPT="$(SMOKE_INPUT_SCRIPT)" \
		tests/run_smoke_qemu.sh
	@set -e; \
	dump_diagnostics() { \
		rc=$$?; \
		if [ $$rc -ne 0 ]; then \
			echo "Smoke assertion failed with status $$rc."; \
			for status_file in "$(BUILD_DIR)"/status*.txt; do \
				if [ -f "$$status_file" ]; then echo "---- $$status_file ----"; cat "$$status_file"; fi; \
			done; \
			if [ -f "$(BUILD_DIR)/smoke.log" ]; then echo "---- smoke.log ----"; tail -200 "$(BUILD_DIR)/smoke.log"; fi; \
			if [ -f "$(BUILD_DIR)/qemu.log" ]; then echo "---- qemu.log ----"; tail -200 "$(BUILD_DIR)/qemu.log"; fi; \
			if [ -f "$(BUILD_DIR)/serial.log" ]; then echo "---- serial.log ----"; tail -200 "$(BUILD_DIR)/serial.log"; fi; \
		fi; \
		exit $$rc; \
	}; \
	trap dump_diagnostics EXIT; \
	test -s $(BUILD_DIR)/status.bin; \
	grep -q "Aurora OS v0.2" $(BUILD_DIR)/status.txt; \
	if [ "$(SMOKE_SKIP_ASSERTIONS)" = "1" ]; then \
		trap - EXIT; \
		printf "Smoke capture OK: QEMU status snapshots captured; proof gates are expected to run separately.\n"; \
		exit 0; \
	fi; \
	grep -q "pg=ON" $(BUILD_DIR)/status.txt; \
	grep -q "pmm=OK" $(BUILD_DIR)/status.txt; \
	grep -q "vmm=OK" $(BUILD_DIR)/status.txt; \
	grep -q "libc=OK" $(BUILD_DIR)/status.txt; \
	grep -q "c=OK" $(BUILD_DIR)/status.txt; \
	grep -q "usr=OK" $(BUILD_DIR)/status.txt; \
	grep -q "wad=OK" $(BUILD_DIR)/status.txt; \
	grep -q "lmp=OK" $(BUILD_DIR)/status.txt; \
	grep -q "exec=OK" $(BUILD_DIR)/status.txt; \
		grep -q "path=DOOM.ELF" $(BUILD_DIR)/status.txt; \
		grep -q "doom=OK" $(BUILD_DIR)/status.txt; \
		grep -Eq "doomrun=(RUN|EXIT)" $(BUILD_DIR)/status.txt; \
		grep -q "doomexit=" $(BUILD_DIR)/status.txt; \
		grep -q "doomfault=" $(BUILD_DIR)/status.txt; \
		grep -q "doomfaultip=" $(BUILD_DIR)/status.txt; \
		grep -q "doomfaultv=" $(BUILD_DIR)/status.txt; \
		grep -q "doomfaulterr=" $(BUILD_DIR)/status.txt; \
		grep -q " fault=" $(BUILD_DIR)/status.txt; \
		grep -Eq "panic=(NONE|KEXC)" $(BUILD_DIR)/status.txt; \
			grep -Eq "shutdown=(NONE|HALT|REBOOT|POWEROFF)" $(BUILD_DIR)/status.txt; \
	grep -q "doomopen=OK" $(BUILD_DIR)/status.txt; \
	grep -q "doomread=OK" $(BUILD_DIR)/status.txt; \
	grep -q "doomwrite=" $(BUILD_DIR)/status.txt; \
	grep -q "doomseek=" $(BUILD_DIR)/status.txt; \
	grep -q "doomwad=" $(BUILD_DIR)/status.txt; \
	grep -q "doomclose=" $(BUILD_DIR)/status.txt; \
	grep -q "doomsbrk=" $(BUILD_DIR)/status.txt; \
	grep -q "doomerr=" $(BUILD_DIR)/status.txt; \
	grep -q "doomerrno=" $(BUILD_DIR)/status.txt; \
	grep -q "doommode=" $(BUILD_DIR)/status.txt; \
	grep -q "doomlog=" $(BUILD_DIR)/status.txt; \
	grep -q "doompresent=" $(BUILD_DIR)/status.txt; \
	grep -q "doompal=" $(BUILD_DIR)/status.txt; \
	grep -q "doomframe=" $(BUILD_DIR)/status.txt; \
	grep -q "doomnonzero=" $(BUILD_DIR)/status.txt; \
	grep -q "doomcolors=" $(BUILD_DIR)/status.txt; \
	grep -q "doomsamp=" $(BUILD_DIR)/status.txt; \
	grep -q "doominit=" $(BUILD_DIR)/status.txt; \
	grep -q "gameplay=" $(BUILD_DIR)/status.txt; \
	grep -q "gstate=" $(BUILD_DIR)/status.txt; \
	grep -q "gmap=" $(BUILD_DIR)/status.txt; \
	grep -q "gtic=" $(BUILD_DIR)/status.txt; \
	grep -q "leveltime=" $(BUILD_DIR)/status.txt; \
	grep -q "dtick=" $(BUILD_DIR)/status.txt; \
	grep -q "gflags=" $(BUILD_DIR)/status.txt; \
	grep -q "gaction=" $(BUILD_DIR)/status.txt; \
	grep -q "pflags=" $(BUILD_DIR)/status.txt; \
	grep -q "pbuttons=" $(BUILD_DIR)/status.txt; \
	grep -q "ppos=" $(BUILD_DIR)/status.txt; \
	grep -q "pdelta=" $(BUILD_DIR)/status.txt; \
	grep -q "doomsound=" $(BUILD_DIR)/status.txt; \
	grep -q "sfxmix=" $(BUILD_DIR)/status.txt; \
	grep -q "voices=" $(BUILD_DIR)/status.txt; \
	grep -q "sfxvoices=" $(BUILD_DIR)/status.txt; \
	grep -q "audioirq=" $(BUILD_DIR)/status.txt; \
	grep -q "ack8=" $(BUILD_DIR)/status.txt; \
	grep -q "ack16=" $(BUILD_DIR)/status.txt; \
	grep -q "refill=" $(BUILD_DIR)/status.txt; \
	grep -q "half=" $(BUILD_DIR)/status.txt; \
	grep -q "mixwrap=" $(BUILD_DIR)/status.txt; \
	grep -q "mixover=" $(BUILD_DIR)/status.txt; \
	grep -q "mixunder=" $(BUILD_DIR)/status.txt; \
	grep -q "mixclip=" $(BUILD_DIR)/status.txt; \
	grep -q "steal=" $(BUILD_DIR)/status.txt; \
	grep -q "pitchclamp=" $(BUILD_DIR)/status.txt; \
	grep -q "panclamp=" $(BUILD_DIR)/status.txt; \
	grep -q "musicvoices=" $(BUILD_DIR)/status.txt; \
	grep -q "musicmix=" $(BUILD_DIR)/status.txt; \
	grep -q "musicloop=" $(BUILD_DIR)/status.txt; \
	grep -q "musicpos=" $(BUILD_DIR)/status.txt; \
	grep -q "musicbuf=" $(BUILD_DIR)/status.txt; \
	grep -q "musicunder=" $(BUILD_DIR)/status.txt; \
	grep -q "musicdrops=" $(BUILD_DIR)/status.txt; \
	grep -q "sb16=" $(BUILD_DIR)/status.txt; \
	grep -q "dma=" $(BUILD_DIR)/status.txt; \
	grep -q "play=" $(BUILD_DIR)/status.txt; \
	grep -q "voiceq=" $(BUILD_DIR)/status.txt; \
	grep -q "musicq=" $(BUILD_DIR)/status.txt; \
	grep -Eq "audio=(SB16|NONE)" $(BUILD_DIR)/status.txt; \
		grep -q "keyirq=" $(BUILD_DIR)/status.txt; \
		grep -q "keyqueue=" $(BUILD_DIR)/status.txt; \
		grep -q "keypoll=" $(BUILD_DIR)/status.txt; \
		grep -q "keyseen=" $(BUILD_DIR)/status.txt; \
		grep -q "keylast=" $(BUILD_DIR)/status.txt; \
		grep -Eq "mouse=(OK|NONE)" $(BUILD_DIR)/status.txt; \
		grep -q "mouseirq=" $(BUILD_DIR)/status.txt; \
		grep -q "mousepkt=" $(BUILD_DIR)/status.txt; \
		grep -q "mousepoll=" $(BUILD_DIR)/status.txt; \
		grep -q "mousebtn=" $(BUILD_DIR)/status.txt; \
		grep -q "mousedelta=" $(BUILD_DIR)/status.txt; \
		grep -q "gfx=OK" $(BUILD_DIR)/status.txt; \
	grep -Eq "fb=(LFB|M13)" $(BUILD_DIR)/status.txt; \
	grep -Eq "fbpolicy=(ASP|SQ|M13)" $(BUILD_DIR)/status.txt; \
	grep -Eq "fbgeom=([0-9A-F]{8}:){4}[0-9A-F]{8}" $(BUILD_DIR)/status.txt; \
	grep -Eq "fbdirty=([0-9A-F]{8}:){4}[0-9A-F]{8}" $(BUILD_DIR)/status.txt; \
	grep -q "heap=OK" $(BUILD_DIR)/status.txt; \
	if [ "$(SMOKE_CAPTURE_GFX)" = "1" ]; then \
		test -s $(BUILD_DIR)/gfx.bin; \
		if [ "$(SMOKE_EXPECT_PROBE_GFX)" = "1" ]; then \
			if perl -ne '$$ok = 1 if /doompresent=([0-9A-F]{8})/ && hex($$1) > 0; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; then \
				test $$(wc -c < $(BUILD_DIR)/gfx.bin) -eq 64000; \
			else \
				perl -e 'local $$/; $$d = <>; exit(length($$d) == 64000 && ord(substr($$d, 0, 1)) == 0 && ord(substr($$d, 1, 1)) == 1 && ord(substr($$d, 320, 1)) == 64 && ord(substr($$d, 63999, 1)) == 255 ? 0 : 1)' $(BUILD_DIR)/gfx.bin; \
			fi; \
		else \
			test $$(wc -c < $(BUILD_DIR)/gfx.bin) -eq 64000; \
		fi; \
	fi; \
	if [ -n "$(SMOKE_REJECT_DOOMLOG)" ]; then \
		! grep -Eq "$(SMOKE_REJECT_DOOMLOG)" $(BUILD_DIR)/status.txt; \
	fi; \
	if [ "$(SMOKE_REQUIRE_DOOM_PRESENT)" = "1" ]; then \
		perl -ne '$$ok = 1 if /doompresent=([0-9A-F]{8})/ && hex($$1) > 0; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
	fi; \
	if [ "$(SMOKE_REQUIRE_DOOM_GAMEPLAY)" = "1" ]; then \
		grep -q "gameplay=OK" $(BUILD_DIR)/status.txt; \
		perl -ne '$$ok = 1 if /gstate=([0-9A-F]{8})/ && hex($$1) == 0; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
		perl -ne '$$ok = 1 if /gmap=([0-9A-F]{8})/ && hex($$1) == 0x00000101; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
		perl -ne '$$ok = 1 if /gtic=([0-9A-F]{8})/ && hex($$1) > 0; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
		perl -ne '$$ok = 1 if /leveltime=([0-9A-F]{8})/ && hex($$1) > 0; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
	fi; \
	if [ "$(SMOKE_REQUIRE_REAL_WAD_PROOF)" = "1" ]; then \
		real_wad_args="--baseline $(BUILD_DIR)/status.after-start.txt --start $(BUILD_DIR)/status.after-start.txt"; \
		if [ -f "$(BUILD_DIR)/status.after-fire.txt" ]; then real_wad_args="$$real_wad_args --fire $(BUILD_DIR)/status.after-fire.txt"; fi; \
		if [ -f "$(BUILD_DIR)/status.after-move.txt" ]; then real_wad_args="$$real_wad_args --movement $(BUILD_DIR)/status.after-move.txt"; fi; \
		if [ -f "$(BUILD_DIR)/status.after-use.txt" ]; then real_wad_args="$$real_wad_args --use $(BUILD_DIR)/status.after-use.txt"; fi; \
		if [ -f "$(BUILD_DIR)/status.after-mouse.txt" ]; then real_wad_args="$$real_wad_args --mouse $(BUILD_DIR)/status.after-mouse.txt"; fi; \
		if [ -f "$(BUILD_DIR)/status.after-menu.txt" ]; then real_wad_args="$$real_wad_args --menu $(BUILD_DIR)/status.after-menu.txt"; fi; \
		$(PYTHON) tools/check_real_wad_proof.py $$real_wad_args $(BUILD_DIR)/status.txt; \
	fi; \
	if [ "$(SMOKE_REQUIRE_HUMAN_PLAYABILITY_PROOF)" = "1" ]; then \
		human_args="--baseline $(BUILD_DIR)/status.after-start.txt --start $(BUILD_DIR)/status.after-start.txt"; \
		if [ -f "$(BUILD_DIR)/status.after-fire.txt" ]; then human_args="$$human_args --fire $(BUILD_DIR)/status.after-fire.txt"; fi; \
		if [ -f "$(BUILD_DIR)/status.after-move.txt" ]; then human_args="$$human_args --movement $(BUILD_DIR)/status.after-move.txt"; fi; \
		if [ -f "$(BUILD_DIR)/status.after-use.txt" ]; then human_args="$$human_args --use $(BUILD_DIR)/status.after-use.txt"; fi; \
		if [ -f "$(BUILD_DIR)/status.after-mouse.txt" ]; then human_args="$$human_args --mouse $(BUILD_DIR)/status.after-mouse.txt"; fi; \
		if [ -f "$(BUILD_DIR)/status.after-menu.txt" ]; then human_args="$$human_args --menu $(BUILD_DIR)/status.after-menu.txt"; fi; \
		$(PYTHON) tools/check_human_playability_proof.py $$human_args $(BUILD_DIR)/status.txt; \
	fi; \
	if [ "$(SMOKE_REQUIRE_AUDIO_CONTINUITY)" = "1" ]; then \
		audio_args="--baseline $(BUILD_DIR)/status.after-start.txt"; \
		if [ -f "$(BUILD_DIR)/status.after-fire.txt" ]; then audio_args="$$audio_args --fire $(BUILD_DIR)/status.after-fire.txt"; fi; \
		if [ -f "$(BUILD_DIR)/status.after-move.txt" ]; then audio_args="$$audio_args --movement $(BUILD_DIR)/status.after-move.txt"; fi; \
		if [ -f "$(BUILD_DIR)/status.after-use.txt" ]; then audio_args="$$audio_args --use $(BUILD_DIR)/status.after-use.txt"; fi; \
		if [ -f "$(BUILD_DIR)/status.after-menu.txt" ]; then audio_args="$$audio_args --menu $(BUILD_DIR)/status.after-menu.txt"; fi; \
		$(PYTHON) tools/check_audio_continuity_proof.py $$audio_args $(BUILD_DIR)/status.txt; \
	fi; \
	if [ -n "$(SMOKE_SENDKEYS)" ] || [ "$(SMOKE_REQUIRE_KEY_EVENT)" = "1" ]; then \
			perl -ne '$$ok = 1 if /keyirq=([0-9A-F]{8})/ && hex($$1) > 0; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
			perl -ne '$$ok = 1 if /keyqueue=([0-9A-F]{8})/ && hex($$1) > 0; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
			perl -ne '$$ok = 1 if /keypoll=([0-9A-F]{8})/ && hex($$1) > 0; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
			perl -ne '$$ok = 1 if /keyseen=([0-9A-F]{8})/ && hex($$1) > 0; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
		fi; \
	perl -ne '$$ok = 1 if /heap=OK free=([0-9A-F]{8})/ && hex($$1) >= 0x00700000; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
	perl -ne '$$ok = 1 if /ticks=([0-9A-F]{8})/ && hex($$1) > 0; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
	trap - EXIT; \
	printf "Smoke boot OK: protected-mode kernel status, Ring 3 probe, Doom ELF load, indexed-frame present, and PIT ticks verified in cloud VM memory.\n"

playability-gap-check:
	$(PYTHON) tools/check_playability_gap_ledger.py

hardware-support-check:
	$(PYTHON) tools/check_hardware_support_matrix.py

vm-safety-check:
	$(PYTHON) tools/check_vm_safety_contract.py

shutdown-panic-proof-check:
	$(PYTHON) tools/check_shutdown_panic_proof.py --repo-contract

audio-continuity-check:
	$(PYTHON) tools/check_audio_continuity_proof.py --repo-contract

audible-audio-proof-check:
	$(PYTHON) tools/check_audible_audio_proof.py --repo-contract

cloud-playability-check: playability-gap-check hardware-support-check vm-safety-check shutdown-panic-proof-check audio-continuity-check audible-audio-proof-check
	$(PYTHON) tools/check_cloud_playability_artifacts.py --repo-contract

persistence-image-check: $(IMAGE)
	@set -e; \
	args=""; \
	if [ -n "$(PERSISTENCE_BASELINE_IMAGE)" ]; then args="$$args --baseline-image $(PERSISTENCE_BASELINE_IMAGE)"; fi; \
	if [ -n "$(PERSISTENCE_REBOOT_BASELINE_IMAGE)" ]; then args="$$args --reboot-baseline-image $(PERSISTENCE_REBOOT_BASELINE_IMAGE)"; fi; \
	if [ "$(PERSISTENCE_REQUIRE_DEFAULT)" = "1" ]; then args="$$args --require-default"; fi; \
	for slot in $(PERSISTENCE_REQUIRE_SAVE_SLOT); do args="$$args --require-save-slot $$slot"; done; \
	$(PYTHON) tools/check_doom_persistence_image.py $$args "$(IMAGE)"

clean:
	rm -rf $(BUILD_DIR)
