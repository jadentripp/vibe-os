NASM ?= nasm
QEMU ?= qemu-system-x86_64
CLANG ?= clang
HOST_CC ?= cc
LLD_LINK ?= lld-link
HOST_CFLAGS ?= -std=c99 -Wall -Wextra -Werror -O2
NC ?= nc
KERNEL_EXTRA_NASMFLAGS ?=
USER_ABI_PROBE_NASMFLAGS ?=
QEMU_ACCEL ?= tcg
QEMU_MACHINE := pc,accel=$(QEMU_ACCEL)
QEMU_EXTRA_ARGS ?=
ALLOW_LOCAL_VM ?= 0
DOOM_WAD ?=
QUAKE_PAK ?=
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
PERSISTENCE_REBOOT_BASELINE_IMAGE ?=
PERSISTENCE_REBOOT_STATUS ?=
PERSISTENCE_WRITE_STATUS ?=
PERSISTENCE_SAVE_WRITE_STATUS ?=
PERSISTENCE_LOAD_STATUS ?=
PERSISTENCE_REQUIRE_DEFAULT ?= 0
PERSISTENCE_REQUIRE_SAVE_SLOT ?=
PERSISTENCE_REQUIRE_SAVE_DESCRIPTION ?=
PERSISTENCE_REQUIRE_DYNAMIC_FAT_PROOF ?= 0
AHCI_STATUS ?=

BUILD_DIR := build
STAGE2_LBA ?= 1
STAGE1_BIN := $(BUILD_DIR)/stage1.bin
STAGE2_BIN := $(BUILD_DIR)/stage2.bin
KERNEL_OBJ := $(BUILD_DIR)/kernel.o
C_RUNTIME_OBJ := $(BUILD_DIR)/c_runtime_probe.o
KERNEL_ELF := $(BUILD_DIR)/kernel.elf
LINK_ELF32 := $(BUILD_DIR)/link_elf32
USER_CRT0_OBJ := $(BUILD_DIR)/user_crt0.o
USER_PROBE_OBJ := $(BUILD_DIR)/user_probe.o
USER_PROBE_ELF := $(BUILD_DIR)/user_probe.elf
USER_ABI_PROBE_OBJ := $(BUILD_DIR)/user_abi_probe.o
USER_RUNTIME_OBJ := $(BUILD_DIR)/user_runtime.o
USER_ABI_PROBE_ELF := $(BUILD_DIR)/abi_probe.elf
IMAGE := $(BUILD_DIR)/disk.img
IMAGE_BUILDER := $(BUILD_DIR)/make_wad_image
UEFI_BUILD_DIR := $(BUILD_DIR)/uefi
UEFI_LOADER_OBJ := $(UEFI_BUILD_DIR)/loader.obj
UEFI_LOADER_EFI := $(UEFI_BUILD_DIR)/BOOTX64.EFI
UEFI_DUAL_IMAGE := $(UEFI_BUILD_DIR)/uefi-fat16.img
C_RUNTIME_SRC := kernel/c_runtime_probe.asm
USER_PROBE_ASM_SRC := user/probe.asm
USER_ABI_PROBE_ASM_SRC := user/abi_probe.asm
USER_RUNTIME_ASM_SRC := user/runtime.asm
VIBE_STATUS_CHECK_SRC := tools/vibe_status_check.c
DOOM_SRC_DIR := third_party/doom/linuxdoom-1.10
DOOM_PORT_INCLUDE_DIR := doom_port/include
DOOM_PORT_BUILD_DIR := $(BUILD_DIR)/doom
DOOM_ELF := $(BUILD_DIR)/doom.elf
DOOM_SYMBOLS := $(BUILD_DIR)/doom.symbols
DOOM_BASE := 0x01000000
DOOM_ORIGINAL_SRCS := $(filter-out $(DOOM_SRC_DIR)/i_%.c,$(wildcard $(DOOM_SRC_DIR)/*.c))
DOOM_ORIGINAL_OBJS := $(DOOM_ORIGINAL_SRCS:$(DOOM_SRC_DIR)/%.c=$(DOOM_PORT_BUILD_DIR)/%.o)
DOOM_PORT_ASM_SRCS := doom_port/input.asm doom_port/libc.asm doom_port/music.asm doom_port/platform.asm doom_port/save_debug.asm doom_port/start.asm
DOOM_PORT_OBJS := $(DOOM_PORT_ASM_SRCS:doom_port/%.asm=$(DOOM_PORT_BUILD_DIR)/port_%.o)
FREESTANDING_I386_CFLAGS := -target i386-unknown-elf -ffreestanding -fno-builtin -fno-strict-aliasing -fno-stack-protector -fno-pic -fno-asynchronous-unwind-tables -fno-unwind-tables -m32 -march=i386 -mno-sse -mno-mmx -msoft-float -O2
DOOM_ORIGINAL_CFLAGS := $(FREESTANDING_I386_CFLAGS) -std=gnu89 -DNORMALUNIX -DLINUX -I$(DOOM_PORT_INCLUDE_DIR) -I$(DOOM_SRC_DIR)
DOOM_G_GAME_CFLAGS := -DG_BuildTiccmd=doom_original_G_BuildTiccmd -DG_Ticker=doom_original_G_Ticker
DOOM_P_SAVEG_CFLAGS := -DP_ArchivePlayers=doom_original_P_ArchivePlayers -DP_UnArchivePlayers=doom_original_P_UnArchivePlayers -DP_ArchiveWorld=doom_original_P_ArchiveWorld -DP_UnArchiveWorld=doom_original_P_UnArchiveWorld -DP_ArchiveThinkers=doom_original_P_ArchiveThinkers -DP_UnArchiveThinkers=doom_original_P_UnArchiveThinkers -DP_ArchiveSpecials=doom_original_P_ArchiveSpecials -DP_UnArchiveSpecials=doom_original_P_UnArchiveSpecials
QUAKE_SRC_DIR := third_party/quake/WinQuake
QUAKE_PORT_INCLUDE_DIR := quake_port/include
QUAKE_PORT_BUILD_DIR := $(BUILD_DIR)/quake
QUAKE_ELF := $(BUILD_DIR)/quake.elf
QUAKE_SYMBOLS := $(BUILD_DIR)/quake.symbols
QUAKE_BASE := 0x01000000
QUAKE_ORIGINAL_SRC_NAMES := \
	cl_demo cl_input cl_main cl_parse cl_tent chase cmd common console crc cvar \
	draw d_edge d_fill d_init d_modech d_part d_polyse d_scan d_sky d_sprite \
	d_surf d_vars d_zpoint host host_cmd keys mathlib menu model net_loop \
	net_main net_none net_vcr nonintel pr_cmds pr_edict pr_exec r_aclip \
	r_alias r_bsp r_draw r_edge r_efrag r_light r_main r_misc r_part r_sky \
	r_sprite r_surf r_vars sbar screen snd_dma snd_mem snd_mix sv_main sv_move \
	sv_phys sv_user view wad world zone
QUAKE_ORIGINAL_OBJS := $(addprefix $(QUAKE_PORT_BUILD_DIR)/,$(addsuffix .o,$(QUAKE_ORIGINAL_SRC_NAMES)))
QUAKE_PORT_ASM_SRCS := quake_port/cd.asm quake_port/input.asm quake_port/math.asm quake_port/setjmp.asm quake_port/snd.asm quake_port/start.asm quake_port/sys.asm quake_port/vid.asm
QUAKE_DOOM_LIBC_OBJ := $(QUAKE_PORT_BUILD_DIR)/doom_libc.o
QUAKE_PORT_OBJS := $(QUAKE_PORT_ASM_SRCS:quake_port/%.asm=$(QUAKE_PORT_BUILD_DIR)/port_%.o) $(QUAKE_DOOM_LIBC_OBJ)
QUAKE_FREESTANDING_I386_CFLAGS := -target i386-unknown-elf -ffreestanding -fno-builtin -fno-strict-aliasing -fno-stack-protector -fno-pic -fno-asynchronous-unwind-tables -fno-unwind-tables -m32 -march=i386 -mno-sse -mno-mmx -O2
QUAKE_ORIGINAL_CFLAGS := $(QUAKE_FREESTANDING_I386_CFLAGS) -std=gnu89 -fcommon -U__i386__ -Dstricmp=strcasecmp -I$(QUAKE_PORT_INCLUDE_DIR) -I$(DOOM_PORT_INCLUDE_DIR) -I$(QUAKE_SRC_DIR)
IMAGE_QUAKE_PAK_ARGS :=
ifneq ($(strip $(QUAKE_PAK)),)
IMAGE_QUAKE_PAK_ARGS := --asset /ID1/PAK0.PAK=$(QUAKE_PAK)
endif
IMAGE_ASSET_DEPS :=
ifneq ($(strip $(DOOM_WAD)),)
IMAGE_ASSET_DEPS += $(DOOM_WAD)
endif
ifneq ($(strip $(QUAKE_PAK)),)
IMAGE_ASSET_DEPS += $(QUAKE_PAK)
endif

STAGE2_MAX_BYTES := 8192
KERNEL_ELF_MAX_BYTES := 163840
USER_PROBE_ELF_MAX_BYTES := 16384
USER_ABI_PROBE_ELF_MAX_BYTES := 24576
IMAGE_ROOT_ELF_ARGS := --root-elf ABIPROBE.ELF=$(USER_ABI_PROBE_ELF) --root-elf QUAKE.ELF=$(QUAKE_ELF)

.PHONY: all build-only test assembly-native-check no-python-check doom-compile doom-link quake-compile quake-link run run-headless smoke quake-status-proof-check playability-host-check image-builder-tool image-builder-inspect uefi-loader-object uefi-loader-pe uefi-dual-image persistence-image-check clean check-tools vm-consent vm-status-proof-check FORCE

all: $(IMAGE)

build-only: $(IMAGE) doom-link quake-link
	@printf "Build-only check OK: %s, %s, %s, and %s are present.\n" "$(IMAGE)" "$(DOOM_ELF)" "$(QUAKE_ELF)" "$(USER_ABI_PROBE_ELF)"

test: no-python-check $(IMAGE) doom-link quake-link vm-status-proof-check assembly-native-check
	@printf "Assembly-first host checks OK: image build, Doom link, guest status validator, and assembly-native guest build audit passed.\n"

no-python-check:
	@set -e; \
	files="$$(git ls-files '*.py' ':(exclude)third_party/**' ':(exclude)build/**' ':(exclude)out/**')"; \
	if [ -n "$$files" ]; then \
		printf "Tracked Python is not allowed in the vibe-os build/proof path:\n%s\n" "$$files" >&2; \
		exit 1; \
	fi; \
	printf "No tracked Python in the vibe-os build/proof path.\n"

assembly-native-check:
	@set -e; \
	recipes="$$( $(MAKE) --no-print-directory -B -n ALLOW_LOCAL_VM=0 DOOM_WAD= build-only )"; \
	for path in \
		kernel/c_runtime_probe.asm \
		user/probe.asm \
		user/runtime.asm \
		user/abi_probe.asm \
		doom_port/input.asm \
		doom_port/libc.asm \
		doom_port/music.asm \
		doom_port/platform.asm \
		doom_port/save_debug.asm \
		doom_port/start.asm \
		quake_port/cd.asm \
		quake_port/input.asm \
		quake_port/math.asm \
		quake_port/setjmp.asm \
		quake_port/snd.asm \
		quake_port/start.asm \
		quake_port/sys.asm \
		quake_port/vid.asm; do \
		printf "%s\n" "$$recipes" | grep -Eq "nasm -f elf32([[:space:]][^[:space:]]+)*[[:space:]]+$$path[[:space:]]+-o[[:space:]]" || { \
			printf "Guest assembly build audit missing NASM recipe for %s\n" "$$path" >&2; \
			exit 1; \
		}; \
	done; \
	bad_guest_c="$$(printf "%s\n" "$$recipes" | grep -E ' -c (kernel|user|doom_port|quake_port)/.*\.c|clang .* (kernel|user|doom_port|quake_port)/.*\.c' || true)"; \
	if [ -n "$$bad_guest_c" ]; then \
		printf "Project-owned C is still compiled into guest artifacts:\n%s\n" "$$bad_guest_c" >&2; \
		exit 1; \
	fi; \
	for path in \
		kernel/c_runtime_probe.c \
		user/probe.c \
		user/abi_probe.c \
		user/runtime.c \
		doom_port/input.c \
		doom_port/libc.c \
		doom_port/music.c \
		doom_port/platform.c \
		doom_port/save_debug.c \
		doom_port/start.c \
		quake_port/cd.c \
		quake_port/input.c \
		quake_port/math.c \
		quake_port/setjmp.c \
		quake_port/snd.c \
		quake_port/start.c \
		quake_port/sys.c \
		quake_port/vid.c; do \
		if [ -e "$$path" ]; then \
			printf "Legacy project-owned guest C source still exists: %s\n" "$$path" >&2; \
			exit 1; \
		fi; \
	done; \
	printf "Assembly-native guest build audit OK: project-owned guest artifacts are NASM-owned.\n"

doom-compile: $(DOOM_ORIGINAL_OBJS)
	@printf "Compiled %s original Doom source files for freestanding i386.\n" "$$(printf '%s\n' $(DOOM_ORIGINAL_OBJS) | wc -l | tr -d ' ')"

doom-link: $(DOOM_ELF)
	@printf "Linked freestanding Doom ELF at %s\n" "$(DOOM_ELF)"

quake-compile: $(QUAKE_ORIGINAL_OBJS)
	@printf "Compiled %s original Quake source files for freestanding i386.\n" "$$(printf '%s\n' $(QUAKE_ORIGINAL_OBJS) | wc -l | tr -d ' ')"

quake-link: $(QUAKE_ELF)
	@printf "Linked freestanding Quake ELF at %s\n" "$(QUAKE_ELF)"

playability-host-check:
	@printf "Running host-only playability readiness checks; local QEMU remains disabled.\n"
	$(MAKE) --no-print-directory clean
	$(MAKE) --no-print-directory ALLOW_LOCAL_VM=0 DOOM_WAD= build-only
	$(MAKE) --no-print-directory ALLOW_LOCAL_VM=0 DOOM_WAD= test
	git diff --check
	git diff --cached --check
	@printf "Playability host check OK: assembly build path and minimal host status proof passed without local QEMU.\n"

check-tools:
	@command -v $(NASM) >/dev/null || { echo "missing nasm"; exit 1; }
	@command -v $(QEMU) >/dev/null || { echo "missing qemu-system-x86_64"; exit 1; }
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

$(QUAKE_PORT_BUILD_DIR):
	@mkdir -p $(QUAKE_PORT_BUILD_DIR)

$(UEFI_BUILD_DIR):
	@mkdir -p $(UEFI_BUILD_DIR)

$(STAGE1_BIN): boot/stage1.asm | $(BUILD_DIR)
	$(NASM) -f bin $< -o $@

$(STAGE2_BIN): boot/stage2.asm | $(BUILD_DIR)
	$(NASM) -f bin -D STAGE2_LBA=$(STAGE2_LBA) $< -o $@
	@test $$(wc -c < $@) -le $(STAGE2_MAX_BYTES) || { echo "stage2 exceeds $(STAGE2_MAX_BYTES) bytes"; exit 1; }

$(KERNEL_OBJ): kernel/kernel.asm | $(BUILD_DIR)
	$(NASM) -f elf32 -D ELF_KERNEL $(KERNEL_EXTRA_NASMFLAGS) $< -o $@

$(C_RUNTIME_OBJ): $(C_RUNTIME_SRC) | $(BUILD_DIR)
	$(NASM) -f elf32 $< -o $@

$(LINK_ELF32): tools/link_elf32.c | $(BUILD_DIR)
	$(HOST_CC) $(HOST_CFLAGS) $< -o $@

$(IMAGE_BUILDER): tools/make_wad_image.c | $(BUILD_DIR)
	$(HOST_CC) $(HOST_CFLAGS) $< -o $@

image-builder-tool: $(IMAGE_BUILDER)

image-builder-inspect: $(IMAGE_BUILDER) $(IMAGE)
	$(IMAGE_BUILDER) --inspect "$(IMAGE)"

$(UEFI_LOADER_OBJ): boot/uefi/loader.asm | $(UEFI_BUILD_DIR)
	$(NASM) -f win64 $< -o $@

$(UEFI_LOADER_EFI): $(UEFI_LOADER_OBJ) | $(UEFI_BUILD_DIR)
	@command -v $(LLD_LINK) >/dev/null || { echo "missing $(LLD_LINK); install lld or set LLD_LINK=/path/to/lld-link"; exit 1; }
	$(LLD_LINK) /nologo /subsystem:efi_application /entry:efi_main /nodefaultlib /section:.text,ERW /out:$@ $(UEFI_LOADER_OBJ)
	@grep -a -q "VIBEUEFI step=entry" $@
	@grep -a -q "VIBEUEFI step=kernel-handoff" $@

uefi-loader-object: $(UEFI_LOADER_OBJ)

uefi-loader-pe: $(UEFI_LOADER_EFI)

$(UEFI_DUAL_IMAGE): $(STAGE1_BIN) $(STAGE2_BIN) $(KERNEL_ELF) $(USER_PROBE_ELF) $(USER_ABI_PROBE_ELF) $(DOOM_ELF) $(QUAKE_ELF) $(IMAGE_BUILDER) $(UEFI_LOADER_EFI) $(IMAGE_ASSET_DEPS) | $(UEFI_BUILD_DIR)
	@if [ -n "$(DOOM_WAD)" ]; then \
		$(IMAGE_BUILDER) --wad "$(DOOM_WAD)" $(IMAGE_QUAKE_PAK_ARGS) --asset EFI/BOOT/BOOTX64.EFI=$(UEFI_LOADER_EFI) --asset VIBEOS/KERNEL.ELF=$(KERNEL_ELF) $(IMAGE_ROOT_ELF_ARGS) $@ $(STAGE1_BIN) $(STAGE2_BIN) $(KERNEL_ELF) $(USER_PROBE_ELF) $(DOOM_ELF); \
	else \
		$(IMAGE_BUILDER) $(IMAGE_QUAKE_PAK_ARGS) --asset EFI/BOOT/BOOTX64.EFI=$(UEFI_LOADER_EFI) --asset VIBEOS/KERNEL.ELF=$(KERNEL_ELF) $(IMAGE_ROOT_ELF_ARGS) $@ $(STAGE1_BIN) $(STAGE2_BIN) $(KERNEL_ELF) $(USER_PROBE_ELF) $(DOOM_ELF); \
	fi
	@printf "Built dual BIOS/UEFI FAT16 image %s\n" "$@"

uefi-dual-image: $(UEFI_DUAL_IMAGE)

$(KERNEL_ELF): $(KERNEL_OBJ) $(C_RUNTIME_OBJ) $(LINK_ELF32) | $(BUILD_DIR)
	$(LINK_ELF32) -o $@ --base 0x10000 $(KERNEL_OBJ) $(C_RUNTIME_OBJ)
	@test $$(wc -c < $@) -le $(KERNEL_ELF_MAX_BYTES) || { echo "kernel ELF exceeds $(KERNEL_ELF_MAX_BYTES) bytes"; exit 1; }

$(USER_CRT0_OBJ): user/crt0.asm | $(BUILD_DIR)
	$(NASM) -f elf32 $< -o $@

$(USER_PROBE_OBJ): $(USER_PROBE_ASM_SRC) | $(BUILD_DIR)
	$(NASM) -f elf32 $< -o $@

$(USER_ABI_PROBE_OBJ): $(USER_ABI_PROBE_ASM_SRC) user/runtime.h doom_port/include/vibe_os.h FORCE | $(BUILD_DIR)
	$(NASM) -f elf32 $(USER_ABI_PROBE_NASMFLAGS) $< -o $@

$(USER_RUNTIME_OBJ): $(USER_RUNTIME_ASM_SRC) user/runtime.h doom_port/include/vibe_os.h | $(BUILD_DIR)
	$(NASM) -f elf32 $< -o $@

$(DOOM_PORT_BUILD_DIR)/%.o: $(DOOM_SRC_DIR)/%.c Makefile | $(DOOM_PORT_BUILD_DIR)
	$(CLANG) $(DOOM_ORIGINAL_CFLAGS) -c $< -o $@

$(DOOM_PORT_BUILD_DIR)/g_game.o: $(DOOM_SRC_DIR)/g_game.c Makefile | $(DOOM_PORT_BUILD_DIR)
	$(CLANG) $(DOOM_ORIGINAL_CFLAGS) $(DOOM_G_GAME_CFLAGS) -c $< -o $@

$(DOOM_PORT_BUILD_DIR)/p_saveg.o: $(DOOM_SRC_DIR)/p_saveg.c Makefile | $(DOOM_PORT_BUILD_DIR)
	$(CLANG) $(DOOM_ORIGINAL_CFLAGS) $(DOOM_P_SAVEG_CFLAGS) -c $< -o $@

$(DOOM_PORT_BUILD_DIR)/port_input.o: doom_port/input.asm Makefile | $(DOOM_PORT_BUILD_DIR)
	$(NASM) -f elf32 $< -o $@

$(DOOM_PORT_BUILD_DIR)/port_libc.o: doom_port/libc.asm Makefile | $(DOOM_PORT_BUILD_DIR)
	$(NASM) -f elf32 $< -o $@

$(DOOM_PORT_BUILD_DIR)/port_music.o: doom_port/music.asm Makefile | $(DOOM_PORT_BUILD_DIR)
	$(NASM) -f elf32 $< -o $@

$(DOOM_PORT_BUILD_DIR)/port_platform.o: doom_port/platform.asm Makefile | $(DOOM_PORT_BUILD_DIR)
	$(NASM) -f elf32 $< -o $@

$(DOOM_PORT_BUILD_DIR)/port_save_debug.o: doom_port/save_debug.asm Makefile | $(DOOM_PORT_BUILD_DIR)
	$(NASM) -f elf32 $< -o $@

$(DOOM_PORT_BUILD_DIR)/port_start.o: doom_port/start.asm Makefile | $(DOOM_PORT_BUILD_DIR)
	$(NASM) -f elf32 $< -o $@

$(DOOM_PORT_BUILD_DIR)/port_%.o: doom_port/%.asm Makefile | $(DOOM_PORT_BUILD_DIR)
	$(NASM) -f elf32 $< -o $@

$(DOOM_ELF): $(DOOM_ORIGINAL_OBJS) $(DOOM_PORT_OBJS) $(LINK_ELF32) | $(BUILD_DIR)
	$(LINK_ELF32) -o $@ --base $(DOOM_BASE) --map $(DOOM_SYMBOLS) $(DOOM_ORIGINAL_OBJS) $(DOOM_PORT_OBJS)

$(QUAKE_PORT_BUILD_DIR)/%.o: $(QUAKE_SRC_DIR)/%.c Makefile | $(QUAKE_PORT_BUILD_DIR)
	$(CLANG) $(QUAKE_ORIGINAL_CFLAGS) -c $< -o $@

$(QUAKE_PORT_BUILD_DIR)/port_%.o: quake_port/%.asm Makefile | $(QUAKE_PORT_BUILD_DIR)
	$(NASM) -f elf32 $< -o $@

$(QUAKE_DOOM_LIBC_OBJ): doom_port/libc.asm Makefile | $(QUAKE_PORT_BUILD_DIR)
	$(NASM) -f elf32 $< -o $@

$(QUAKE_ELF): $(QUAKE_ORIGINAL_OBJS) $(QUAKE_PORT_OBJS) $(LINK_ELF32) | $(BUILD_DIR)
	$(LINK_ELF32) -o $@ --base $(QUAKE_BASE) --map $(QUAKE_SYMBOLS) $(QUAKE_ORIGINAL_OBJS) $(QUAKE_PORT_OBJS)

$(USER_PROBE_ELF): $(USER_CRT0_OBJ) $(USER_PROBE_OBJ) $(LINK_ELF32) | $(BUILD_DIR)
	$(LINK_ELF32) -o $@ --base 0x00e80000 $(USER_CRT0_OBJ) $(USER_PROBE_OBJ)
	@test $$(wc -c < $@) -le $(USER_PROBE_ELF_MAX_BYTES) || { echo "user probe ELF exceeds $(USER_PROBE_ELF_MAX_BYTES) bytes"; exit 1; }

$(USER_ABI_PROBE_ELF): $(USER_CRT0_OBJ) $(USER_RUNTIME_OBJ) $(USER_ABI_PROBE_OBJ) $(LINK_ELF32) | $(BUILD_DIR)
	$(LINK_ELF32) -o $@ --base 0x00e80000 $(USER_CRT0_OBJ) $(USER_RUNTIME_OBJ) $(USER_ABI_PROBE_OBJ)
	@test $$(wc -c < $@) -le $(USER_ABI_PROBE_ELF_MAX_BYTES) || { echo "ABI probe ELF exceeds $(USER_ABI_PROBE_ELF_MAX_BYTES) bytes"; exit 1; }

$(IMAGE): $(STAGE1_BIN) $(STAGE2_BIN) $(KERNEL_ELF) $(USER_PROBE_ELF) $(USER_ABI_PROBE_ELF) $(DOOM_ELF) $(QUAKE_ELF) $(IMAGE_BUILDER) $(IMAGE_ASSET_DEPS)
	@if [ -n "$(DOOM_WAD)" ]; then \
		$(IMAGE_BUILDER) --wad "$(DOOM_WAD)" $(IMAGE_QUAKE_PAK_ARGS) $(IMAGE_ROOT_ELF_ARGS) $@ $(STAGE1_BIN) $(STAGE2_BIN) $(KERNEL_ELF) $(USER_PROBE_ELF) $(DOOM_ELF); \
	else \
		$(IMAGE_BUILDER) $(IMAGE_QUAKE_PAK_ARGS) $(IMAGE_ROOT_ELF_ARGS) $@ $(STAGE1_BIN) $(STAGE2_BIN) $(KERNEL_ELF) $(USER_PROBE_ELF) $(DOOM_ELF); \
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
	grep -q "vibe-os v0.2" $(BUILD_DIR)/status.txt; \
	if [ "$(SMOKE_SKIP_ASSERTIONS)" = "1" ]; then \
		trap - EXIT; \
		printf "Smoke capture OK: QEMU status snapshots captured; proof gates are expected to run separately.\n"; \
		exit 0; \
	fi; \
	grep -q "pg=ON" $(BUILD_DIR)/status.txt; \
		grep -q "pmm=OK" $(BUILD_DIR)/status.txt; \
		grep -q "vmm=OK" $(BUILD_DIR)/status.txt; \
		grep -q "e820map=" $(BUILD_DIR)/status.txt; \
		grep -q "pmmuse=" $(BUILD_DIR)/status.txt; \
		grep -q "pmmtype=" $(BUILD_DIR)/status.txt; \
		grep -q "pmmchk=OK" $(BUILD_DIR)/status.txt; \
		grep -q "pmmalloc=" $(BUILD_DIR)/status.txt; \
		grep -q "pmmdeny=" $(BUILD_DIR)/status.txt; \
		grep -q "uguard=0000000F" $(BUILD_DIR)/status.txt; \
		grep -q "vmmguard=0000000F/00000000" $(BUILD_DIR)/status.txt; \
		grep -q "kreloc=HIGH" $(BUILD_DIR)/status.txt; \
	grep -q "krelocstep=KPMAIN_HIGH" $(BUILD_DIR)/status.txt; \
	grep -q "kerneip=" $(BUILD_DIR)/status.txt; \
	grep -q "kernesp=" $(BUILD_DIR)/status.txt; \
	grep -q "kerncr3=00090000" $(BUILD_DIR)/status.txt; \
	grep -q "kernvirt=C0010000" $(BUILD_DIR)/status.txt; \
	grep -q "kernphys=00010000" $(BUILD_DIR)/status.txt; \
	grep -q "khiexec=OK" $(BUILD_DIR)/status.txt; \
	grep -q "khieip=" $(BUILD_DIR)/status.txt; \
	grep -q "khiesp=" $(BUILD_DIR)/status.txt; \
	grep -q "khicr3=00090000" $(BUILD_DIR)/status.txt; \
	grep -q "khiva=" $(BUILD_DIR)/status.txt; \
	grep -q "khipa=" $(BUILD_DIR)/status.txt; \
	grep -q "khistk=" $(BUILD_DIR)/status.txt; \
	grep -q "khistkpa=" $(BUILD_DIR)/status.txt; \
	grep -q "khipt=" $(BUILD_DIR)/status.txt; \
	grep -q "khifree=" $(BUILD_DIR)/status.txt; \
	grep -q "khixlat=" $(BUILD_DIR)/status.txt; \
	grep -q "khisxlat=" $(BUILD_DIR)/status.txt; \
	grep -q "khislot=" $(BUILD_DIR)/status.txt; \
	grep -q "khislotpa=" $(BUILD_DIR)/status.txt; \
	grep -q "khisword=48485354" $(BUILD_DIR)/status.txt; \
	grep -q "khiret=" $(BUILD_DIR)/status.txt; \
	grep -q "kpexec=OK" $(BUILD_DIR)/status.txt; \
	grep -q "kpeip=" $(BUILD_DIR)/status.txt; \
	grep -q "kpesp=" $(BUILD_DIR)/status.txt; \
	grep -q "kpecr3=00090000" $(BUILD_DIR)/status.txt; \
	grep -q "kpeva=" $(BUILD_DIR)/status.txt; \
	grep -q "kpepa=" $(BUILD_DIR)/status.txt; \
	grep -q "kpestk=" $(BUILD_DIR)/status.txt; \
	grep -q "kpestkpa=" $(BUILD_DIR)/status.txt; \
	grep -q "kpexlat=" $(BUILD_DIR)/status.txt; \
	grep -q "kpesxlat=" $(BUILD_DIR)/status.txt; \
	grep -q "kpeslot=" $(BUILD_DIR)/status.txt; \
	grep -q "kpeslotpa=" $(BUILD_DIR)/status.txt; \
	grep -q "kpesword=4B504558" $(BUILD_DIR)/status.txt; \
	grep -q "kperet=" $(BUILD_DIR)/status.txt; \
	grep -q "vmmhi=OK" $(BUILD_DIR)/status.txt; \
	grep -q "vmmhva=C0000000" $(BUILD_DIR)/status.txt; \
	grep -q "vmmhpa=" $(BUILD_DIR)/status.txt; \
	grep -q "vmmhpt=" $(BUILD_DIR)/status.txt; \
	grep -q "vmmhfree=" $(BUILD_DIR)/status.txt; \
	grep -q "libc=OK" $(BUILD_DIR)/status.txt; \
	grep -q "c=OK" $(BUILD_DIR)/status.txt; \
	grep -q "fpu=OK" $(BUILD_DIR)/status.txt; \
	grep -q "fpucr0=" $(BUILD_DIR)/status.txt; \
	grep -q "fpucw=0000037F" $(BUILD_DIR)/status.txt; \
	grep -q "fpusw=00000000/00000005/00000000" $(BUILD_DIR)/status.txt; \
	grep -q "fpufault=" $(BUILD_DIR)/status.txt; \
	grep -q "fpuctx=" $(BUILD_DIR)/status.txt; \
	grep -q "usr=OK" $(BUILD_DIR)/status.txt; \
	grep -q "wad=OK" $(BUILD_DIR)/status.txt; \
	grep -q "lmp=OK" $(BUILD_DIR)/status.txt; \
	grep -q "exec=OK" $(BUILD_DIR)/status.txt; \
	grep -q "path=DOOM.ELF" $(BUILD_DIR)/status.txt; \
	grep -q "uexec=OK" $(BUILD_DIR)/status.txt; \
	grep -q "upath=USERPROB.ELF" $(BUILD_DIR)/status.txt; \
	grep -q "upid=" $(BUILD_DIR)/status.txt; \
	grep -q "uentry=" $(BUILD_DIR)/status.txt; \
	grep -q "doom=OK" $(BUILD_DIR)/status.txt; \
	grep -Eq "doomrun=(RUN|EXIT)" $(BUILD_DIR)/status.txt; \
	grep -q "doomexit=" $(BUILD_DIR)/status.txt; \
	grep -q "doomfault=" $(BUILD_DIR)/status.txt; \
	grep -q "doomfaultip=" $(BUILD_DIR)/status.txt; \
	grep -q "doomfaultv=" $(BUILD_DIR)/status.txt; \
	grep -q "doomfaulterr=" $(BUILD_DIR)/status.txt; \
	grep -q " fault=" $(BUILD_DIR)/status.txt; \
	grep -Eq " pf=([0-9A-F]{8}/){4}[0-9A-F]{8}" $(BUILD_DIR)/status.txt; \
	grep -Eq "faultsrc=(NONE|EXPECT|USER|DOOM|QUAKE|KERNEL)" $(BUILD_DIR)/status.txt; \
	grep -Eq "faultmode=(NONE|USER|KERNEL)" $(BUILD_DIR)/status.txt; \
	grep -Eq "faultcontain=([0-9A-F]{8}/){4}[0-9A-F]{8}" $(BUILD_DIR)/status.txt; \
	grep -Eq " regs=([0-9A-F]{8}/){7}[0-9A-F]{8}" $(BUILD_DIR)/status.txt; \
	grep -Eq " segs=([0-9A-F]{8}/){5}[0-9A-F]{8}" $(BUILD_DIR)/status.txt; \
	grep -Eq " proc=([0-9A-F]{8}/){8}[0-9A-F]{8}" $(BUILD_DIR)/status.txt; \
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
	grep -q "doomsav=" $(BUILD_DIR)/status.txt; \
	grep -q "saverd=" $(BUILD_DIR)/status.txt; \
	grep -q "savewr=" $(BUILD_DIR)/status.txt; \
	grep -q "saveclose=" $(BUILD_DIR)/status.txt; \
	grep -q "savemode=" $(BUILD_DIR)/status.txt; \
	grep -q "saveact=" $(BUILD_DIR)/status.txt; \
	grep -q "savedesc=" $(BUILD_DIR)/status.txt; \
	grep -q "savestm=" $(BUILD_DIR)/status.txt; \
	grep -q "savethk=" $(BUILD_DIR)/status.txt; \
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
	grep -q "pcmd=" $(BUILD_DIR)/status.txt; \
	grep -q "pangle=" $(BUILD_DIR)/status.txt; \
	grep -q "pangledelta=" $(BUILD_DIR)/status.txt; \
	grep -q "pammo=" $(BUILD_DIR)/status.txt; \
	grep -q "prefire=" $(BUILD_DIR)/status.txt; \
	grep -q "pweapon=" $(BUILD_DIR)/status.txt; \
	grep -q "doomsound=" $(BUILD_DIR)/status.txt; \
	grep -q "sfxmix=" $(BUILD_DIR)/status.txt; \
	grep -q "sfxq=" $(BUILD_DIR)/status.txt; \
	grep -q "sfxbytes=" $(BUILD_DIR)/status.txt; \
	grep -q "sfxdma=" $(BUILD_DIR)/status.txt; \
	grep -q "sfxsrc=" $(BUILD_DIR)/status.txt; \
	grep -q "sfxlast=" $(BUILD_DIR)/status.txt; \
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
	grep -q "musicstream=" $(BUILD_DIR)/status.txt; \
	grep -q "musicpull=" $(BUILD_DIR)/status.txt; \
	grep -q "musicrend=" $(BUILD_DIR)/status.txt; \
	grep -q "sb16=" $(BUILD_DIR)/status.txt; \
		grep -q "dma=" $(BUILD_DIR)/status.txt; \
		grep -q "play=" $(BUILD_DIR)/status.txt; \
		grep -q "voiceq=" $(BUILD_DIR)/status.txt; \
		grep -q "musicq=" $(BUILD_DIR)/status.txt; \
		grep -q "adev=" $(BUILD_DIR)/status.txt; \
		grep -q "pcm=" $(BUILD_DIR)/status.txt; \
		grep -q "pcmbuf=" $(BUILD_DIR)/status.txt; \
			grep -q "pcmstream=" $(BUILD_DIR)/status.txt; \
			grep -q "pcmwrite=" $(BUILD_DIR)/status.txt; \
			grep -q "pcmdev=" $(BUILD_DIR)/status.txt; \
			grep -q "pcmqueue=" $(BUILD_DIR)/status.txt; \
			grep -q "pcmpull=" $(BUILD_DIR)/status.txt; \
		grep -q "pcmirq=" $(BUILD_DIR)/status.txt; \
		grep -q "pcmdma=" $(BUILD_DIR)/status.txt; \
		grep -Eq "audio=(SB16|NONE)" $(BUILD_DIR)/status.txt; \
			grep -q "inputqueue=" $(BUILD_DIR)/status.txt; \
			grep -Eq "inputdepth=([0-9A-F]{8}:){1}[0-9A-F]{8}" $(BUILD_DIR)/status.txt; \
				grep -Eq "inputstat=([0-9A-F]{8}:){3}[0-9A-F]{8}" $(BUILD_DIR)/status.txt; \
				grep -Eq "inputpolicy=([0-9A-F]{8}:){1}[0-9A-F]{8}" $(BUILD_DIR)/status.txt; \
				grep -Eq "inputdev=([0-9A-F]{8}:){1}[0-9A-F]{8}" $(BUILD_DIR)/status.txt; \
				grep -Eq "inputdevices=([0-9A-F]{8}:){4}[0-9A-F]{8}" $(BUILD_DIR)/status.txt; \
				grep -q "inputmods=" $(BUILD_DIR)/status.txt; \
				grep -q "inputpoll=" $(BUILD_DIR)/status.txt; \
			grep -Eq "inputlast=([0-9A-F]{8}:){2}[0-9A-F]{8}" $(BUILD_DIR)/status.txt; \
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
		grep -q "path=DOOM.ELF" $(BUILD_DIR)/status.txt; \
		grep -q "doomopen=OK" $(BUILD_DIR)/status.txt; \
		grep -q "doomread=OK" $(BUILD_DIR)/status.txt; \
		grep -q "gameplay=OK" $(BUILD_DIR)/status.txt; \
		perl -ne '$$ok = 1 if /gmap=([0-9A-F]{8})/ && hex($$1) == 0x00000101; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
		perl -ne '$$ok = 1 if /doomframe=([0-9A-F]{8})/ && hex($$1) > 0; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
	fi; \
	if [ "$(SMOKE_REQUIRE_HUMAN_PLAYABILITY_PROOF)" = "1" ]; then \
		echo "SMOKE_REQUIRE_HUMAN_PLAYABILITY_PROOF needs a C replacement before it can be used."; \
		exit 1; \
	fi; \
	if [ "$(SMOKE_REQUIRE_AUDIO_CONTINUITY)" = "1" ]; then \
		grep -q "audio=SB16" $(BUILD_DIR)/status.txt; \
		perl -ne '$$ok = 1 if /sfxbytes=([0-9A-F]{8})/ && hex($$1) > 0; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
		perl -ne '$$ok = 1 if /musicpull=([0-9A-F]{8})/ && hex($$1) > 0; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
		perl -ne '$$ok = 1 if /pcmwrite=([0-9A-F]{8})/ && hex($$1) > 0; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
	fi; \
		if [ -n "$(SMOKE_SENDKEYS)" ] || [ "$(SMOKE_REQUIRE_KEY_EVENT)" = "1" ]; then \
				perl -ne '$$ok = 1 if /inputqueue=([0-9A-F]{8})/ && hex($$1) > 0; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
				perl -ne '$$ok = 1 if /inputpoll=([0-9A-F]{8})/ && hex($$1) > 0; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
				perl -ne '$$ok = 1 if /keyirq=([0-9A-F]{8})/ && hex($$1) > 0; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
			perl -ne '$$ok = 1 if /keyqueue=([0-9A-F]{8})/ && hex($$1) > 0; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
			perl -ne '$$ok = 1 if /keypoll=([0-9A-F]{8})/ && hex($$1) > 0; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
			perl -ne '$$ok = 1 if /keyseen=([0-9A-F]{8})/ && hex($$1) > 0; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
		fi; \
	perl -ne '$$ok = 1 if /heap=OK free=([0-9A-F]{8})/ && hex($$1) >= 0x00700000; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
	perl -ne '$$ok = 1 if /ticks=([0-9A-F]{8})/ && hex($$1) > 0; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
	trap - EXIT; \
	printf "Smoke boot OK: protected-mode kernel status, Ring 3 probe, Doom ELF load, indexed-frame present, and PIT ticks verified in cloud VM memory.\n"

quake-status-proof-check:
	@set -e; \
	test -s $(BUILD_DIR)/status.txt; \
	grep -q "path=QUAKE.ELF" $(BUILD_DIR)/status.txt; \
	grep -q "quake=OK" $(BUILD_DIR)/status.txt; \
	grep -q "quakerun=RUN" $(BUILD_DIR)/status.txt; \
	grep -q "quakeopen=OK" $(BUILD_DIR)/status.txt; \
	grep -q "quakeread=OK" $(BUILD_DIR)/status.txt; \
	grep -q "qgame=OK" $(BUILD_DIR)/status.txt; \
	grep -q "panic=NONE" $(BUILD_DIR)/status.txt; \
	grep -q "shutdown=NONE" $(BUILD_DIR)/status.txt; \
	grep -q "gfx=OK" $(BUILD_DIR)/status.txt; \
	grep -q "audio=SB16" $(BUILD_DIR)/status.txt; \
	grep -q "preempt=OK" $(BUILD_DIR)/status.txt; \
	grep -q "heap=OK" $(BUILD_DIR)/status.txt; \
	perl -ne '$$ok = 1 if /quakepresent=([0-9A-F]{8})/ && hex($$1) > 0; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
	perl -ne '$$ok = 1 if /qframe=([0-9A-F]{8})\/([0-9A-F]{8})/ && hex($$1) > 0 && hex($$2) > 0; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
	perl -ne '$$ok = 1 if /qinput=([0-9A-F]{8})\// && hex($$1) > 0; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
	perl -ne '$$ok = 1 if /qaudio=([0-9A-F]{8})\// && hex($$1) > 0; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
	printf "Quake proof status OK: QUAKE.ELF, PAK reads, rendered frames, input, audio, process, memory, preemption, panic, and shutdown gates passed.\n"

vm-status-proof-check:
	BUILD_DIR="$(abspath $(BUILD_DIR))" HOST_CC="$(HOST_CC)" tools/test_vibe_status_check.sh

persistence-image-check: $(IMAGE_BUILDER)
	@set -e; \
	set -- --check-persistence "$(IMAGE)"; \
	if [ -n "$(PERSISTENCE_BASELINE_IMAGE)" ]; then set -- "$$@" --baseline-image "$(PERSISTENCE_BASELINE_IMAGE)"; fi; \
	if [ -n "$(PERSISTENCE_REBOOT_BASELINE_IMAGE)" ]; then set -- "$$@" --reboot-baseline-image "$(PERSISTENCE_REBOOT_BASELINE_IMAGE)"; fi; \
	if [ -n "$(PERSISTENCE_REBOOT_STATUS)" ]; then set -- "$$@" --reboot-status "$(PERSISTENCE_REBOOT_STATUS)"; fi; \
	if [ -n "$(PERSISTENCE_WRITE_STATUS)" ]; then set -- "$$@" --write-status "$(PERSISTENCE_WRITE_STATUS)"; fi; \
	if [ -n "$(PERSISTENCE_SAVE_WRITE_STATUS)" ]; then set -- "$$@" --save-write-status "$(PERSISTENCE_SAVE_WRITE_STATUS)"; fi; \
	if [ -n "$(PERSISTENCE_LOAD_STATUS)" ]; then set -- "$$@" --load-status "$(PERSISTENCE_LOAD_STATUS)"; fi; \
	if [ "$(PERSISTENCE_REQUIRE_DEFAULT)" = "1" ]; then set -- "$$@" --require-default; fi; \
	if [ "$(PERSISTENCE_REQUIRE_DYNAMIC_FAT_PROOF)" = "1" ]; then set -- "$$@" --require-dynamic-fat-proof; fi; \
	for slot in $(PERSISTENCE_REQUIRE_SAVE_SLOT); do set -- "$$@" --require-save-slot "$$slot"; done; \
	if [ -n "$(PERSISTENCE_REQUIRE_SAVE_DESCRIPTION)" ]; then set -- "$$@" --require-save-description "$(PERSISTENCE_REQUIRE_SAVE_DESCRIPTION)"; fi; \
	$(IMAGE_BUILDER) "$$@"

clean:
	rm -rf $(BUILD_DIR)
