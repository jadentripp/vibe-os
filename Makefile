NASM ?= nasm
QEMU ?= qemu-system-x86_64
CLANG ?= clang
AARCH64_CC ?= clang
HOST_CC ?= cc
LLD_LINK ?= lld-link
HOST_CFLAGS ?= -std=c99 -Wall -Wextra -Werror -O2
HOST_UNAME_S := $(shell uname -s)
HOST_NASM_FORMAT ?= $(if $(filter Darwin,$(HOST_UNAME_S)),macho64,elf64)
HOST_NASM_DEFS ?= $(if $(filter Darwin,$(HOST_UNAME_S)),-D MACHO64,)
# NASM-built host objects use absolute relocations that a PIE link rejects.
# Linux GCC defaults to -pie, so force -no-pie there; Darwin's linker doesn't need it.
HOST_NO_PIE ?= $(if $(filter Darwin,$(HOST_UNAME_S)),,-no-pie)
NC ?= nc
KERNEL_EXTRA_NASMFLAGS ?=
USER_ABI_PROBE_NASMFLAGS ?=
QEMU_ACCEL ?= tcg
QEMU_MACHINE := pc,accel=$(QEMU_ACCEL)
QEMU_EXTRA_ARGS ?=
ALLOW_LOCAL_VM ?= 0
DOOM_WAD ?=
QUAKE_PAK ?=
PRIMARY_ASSET ?= $(DOOM_WAD)
SECONDARY_PACKAGE ?= $(QUAKE_PAK)
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
C_COMPAT_INCLUDE_ROOT := $(BUILD_DIR)/c_compat
C_COMPAT_HEADERS_STAMP := $(C_COMPAT_INCLUDE_ROOT)/.headers.stamp
STAGE2_LBA ?= 1
STAGE1_BIN := $(BUILD_DIR)/stage1.bin
STAGE2_BIN := $(BUILD_DIR)/stage2.bin
KERNEL_OBJ := $(BUILD_DIR)/kernel.o
C_RUNTIME_OBJ := $(BUILD_DIR)/c_runtime_probe.o
KERNEL_ELF := $(BUILD_DIR)/kernel.elf
LINK_ELF32 := $(BUILD_DIR)/link_elf32
LINK_ELF32_SRC := tools/link_elf32.asm
LINK_ELF32_OBJ := $(BUILD_DIR)/link_elf32.o
LINK_AARCH64_FLAT := $(BUILD_DIR)/link_aarch64_flat
LINK_AARCH64_FLAT_SRC := tools/link_aarch64_flat.$(HOST_NASM_FORMAT).s
LINK_AARCH64_FLAT_OBJ := $(BUILD_DIR)/link_aarch64_flat.o
LINK_AARCH64_USER_ELF := $(BUILD_DIR)/link_aarch64_user_elf
LINK_AARCH64_USER_ELF_SRC := tools/link_aarch64_user_elf.$(HOST_NASM_FORMAT).s
LINK_AARCH64_USER_ELF_OBJ := $(BUILD_DIR)/link_aarch64_user_elf.o
USER_CRT0_OBJ := $(BUILD_DIR)/user_crt0.o
USER_LAUNCHER_CRT0_OBJ := $(BUILD_DIR)/user_launcher_crt0.o
USER_PROBE_OBJ := $(BUILD_DIR)/user_probe.o
USER_PROBE_ELF := $(BUILD_DIR)/user_probe.elf
USER_ABI_PROBE_OBJ := $(BUILD_DIR)/user_abi_probe.o
USER_RUNTIME_OBJ := $(BUILD_DIR)/user_runtime.o
USER_LAUNCHER_OBJ := $(BUILD_DIR)/user_launcher.o
USER_LAUNCHER_MAIN_OBJ := $(BUILD_DIR)/user_launcher_main.o
USER_ABI_PROBE_ELF := $(BUILD_DIR)/abi_probe.elf
USER_LAUNCHER_ELF := $(BUILD_DIR)/launcher.elf
IMAGE := $(BUILD_DIR)/disk.img
IMAGE_BUILDER := $(BUILD_DIR)/make_wad_image
IMAGE_BUILDER_SRC := $(if $(filter Darwin,$(HOST_UNAME_S)),tools/make_wad_image.macho64.s,tools/make_wad_image.elf64.s)
IMAGE_BUILDER_OBJ := $(BUILD_DIR)/make_wad_image.o
UEFI_BUILD_DIR := $(BUILD_DIR)/uefi
UEFI_LOADER_OBJ := $(UEFI_BUILD_DIR)/loader.obj
UEFI_LOADER_EFI := $(UEFI_BUILD_DIR)/BOOTX64.EFI
UEFI_DUAL_IMAGE := $(UEFI_BUILD_DIR)/uefi-fat16.img
PI4_BUILD_DIR := $(BUILD_DIR)/pi4
PI4_CONFIG_TXT := boot/pi4/config.txt
PI4_TRYBOOT_TXT := boot/pi4/tryboot.txt
PI4_KERNEL_INPUT_OBJ := $(PI4_BUILD_DIR)/pi4-input.o
PI4_KERNEL_STORAGE_OBJ := $(PI4_BUILD_DIR)/pi4-storage.o
PI4_KERNEL_NET_OBJ := $(PI4_BUILD_DIR)/pi4-net.o
PI4_KERNEL_AGGREGATE_SRC := $(PI4_BUILD_DIR)/pi4-kernel.S
PI4_KERNEL_OBJ := $(PI4_BUILD_DIR)/pi4-start.o
PI4_KERNEL8_IMG := $(PI4_BUILD_DIR)/kernel8.img
PI4_KERNEL8_MAP := $(PI4_BUILD_DIR)/kernel8.map
PI4_IMAGE := $(PI4_BUILD_DIR)/pi4-fat16.img
PI4_IMAGE_INSPECT_TXT := $(PI4_BUILD_DIR)/pi4-image-inspect.txt
PI4_NET_STATUS_SEED := $(PI4_BUILD_DIR)/VIBESTAT.BIN
PI4_HW_EQUIVALENT_QEMU ?= qemu-system-aarch64
PI4_QEMU_DISPLAY ?= $(if $(filter Darwin,$(HOST_UNAME_S)),cocoa,zoom-to-fit=on,none)
PI4_QEMU_SERIAL ?= stdio
PI4_QEMU_AUDIO_ID ?= pi4snd
ifeq ($(HOST_UNAME_S),Darwin)
PI4_QEMU_AUDIODEV_LIVE ?= coreaudio,id=$(PI4_QEMU_AUDIO_ID)
else
PI4_QEMU_AUDIODEV_LIVE ?= wav,id=$(PI4_QEMU_AUDIO_ID),path=$(PI4_BUILD_DIR)/pi4-local-qemu-live-audio.wav
endif
PI4_QEMU_AUDIODEV_SMOKE ?= wav,id=$(PI4_QEMU_AUDIO_ID),path=$(PI4_BUILD_DIR)/pi4-local-qemu-audio.wav
PI4_QEMU_AUDIO_ARGS_LIVE ?= -audiodev $(PI4_QEMU_AUDIODEV_LIVE) -device usb-audio,audiodev=$(PI4_QEMU_AUDIO_ID)
PI4_QEMU_AUDIO_ARGS_SMOKE ?= -audiodev $(PI4_QEMU_AUDIODEV_SMOKE) -device usb-audio,audiodev=$(PI4_QEMU_AUDIO_ID)
PI4_QEMU_ARGS := -M raspi4b,usb=on -cpu cortex-a72 -m 2G -kernel $(PI4_KERNEL8_IMG) -drive file=$(PI4_IMAGE),if=sd,format=raw -serial $(PI4_QEMU_SERIAL) -display $(PI4_QEMU_DISPLAY) -device usb-kbd -device usb-mouse $(PI4_QEMU_AUDIO_ARGS_LIVE) -monitor none -no-reboot -no-shutdown
PI4_LOCAL_QEMU_SMOKE_SECONDS ?= 12
PI4_LOCAL_QEMU_SELECT_DELAY_SECONDS ?= 6
PI4_LOCAL_QEMU_SELECT_SETTLE_SECONDS ?= 12
PI4_LOCAL_QEMU_DOOM_SELECT_PORT ?= 39241
PI4_LOCAL_QEMU_QUAKE_SELECT_PORT ?= 39242
PI4_LOCAL_QEMU_SERIAL_LOG := $(PI4_BUILD_DIR)/local-qemu-serial.log
PI4_LOCAL_QEMU_DOOM_SERIAL_LOG := $(PI4_BUILD_DIR)/local-qemu-doom-uart-select.log
PI4_LOCAL_QEMU_QUAKE_SERIAL_LOG := $(PI4_BUILD_DIR)/local-qemu-quake-uart-select.log
PI4_LOCAL_QEMU_FRAMEBUFFER_LOG := $(PI4_BUILD_DIR)/local-qemu-launcher-framebuffer.log
PI4_LOCAL_QEMU_FRAMEBUFFER_PPM := $(PI4_BUILD_DIR)/local-qemu-launcher-framebuffer.ppm
PI4_LOCAL_QEMU_MONITOR_SOCK := $(PI4_BUILD_DIR)/local-qemu-monitor.sock
PI4_REAL_HW_DIR := $(PI4_BUILD_DIR)/real-hw
PI4_REAL_TRYBOOT_TOOL := tools/pi4_real_tryboot.sh
PI4_REAL_TRYBOOT_MANIFEST := $(PI4_REAL_HW_DIR)/tryboot-manifest.txt
PI4_REAL_SSH_HOST ?=
PI4_REAL_SSH ?= ssh
PI4_REAL_SCP ?= scp
PI4_REAL_BOOT_MOUNT ?= /boot/firmware
PI4_REAL_VIBE_DIR ?= $(PI4_REAL_BOOT_MOUNT)/vibe
PI4_REAL_NET_STATUS_FILE ?= $(PI4_REAL_BOOT_MOUNT)/VIBESTAT.BIN
PI4_REAL_TRYBOOT_CANDIDATE ?= $(PI4_REAL_BOOT_MOUNT)/tryboot.vibe-os.txt
PI4_REAL_TRYBOOT_ACTIVE ?= $(PI4_REAL_BOOT_MOUNT)/tryboot.txt
PI4_REAL_ALLOW_REBOOT ?= 0
PI4_BOOT_ASM_SRCS := boot/pi4/kernel_prelude.S boot/pi4/start.S boot/pi4/input.S boot/pi4/storage.S boot/pi4/net.S
PI4_USER_ASM_SRCS := user/pi4_crt0.S user/pi4_runtime.S user/pi4_abi_probe.S user/pi4_launcher.S user/pi4_launcher_assets.S user/pi4_launcher_art.S
PI4_DOOM_ASM_SRCS := doom_port/pi4_start.S
PI4_QUAKE_ASM_SRCS := quake_port/pi4_app.S
PI4_ASM_SRCS := $(PI4_BOOT_ASM_SRCS) $(PI4_USER_ASM_SRCS) $(PI4_DOOM_ASM_SRCS) $(PI4_QUAKE_ASM_SRCS)
PI4_USER_CRT0_OBJ := $(PI4_BUILD_DIR)/pi4-crt0.o
PI4_USER_RUNTIME_OBJ := $(PI4_BUILD_DIR)/pi4-runtime.o
PI4_USER_ABI_PROBE_OBJ := $(PI4_BUILD_DIR)/pi4-abi-probe.o
PI4_USER_LAUNCHER_OBJ := $(PI4_BUILD_DIR)/pi4-launcher.o
PI4_USER_LAUNCHER_ASSETS_OBJ := $(PI4_BUILD_DIR)/pi4-launcher-assets.o
PI4_USER_LAUNCHER_ART_OBJ := $(PI4_BUILD_DIR)/pi4-launcher-art.o
PI4_DOOM_OBJ := $(PI4_BUILD_DIR)/pi4-doom-start.o
PI4_QUAKE_APP_OBJ := $(PI4_BUILD_DIR)/pi4-quake-app.o
PI4_ABI_PROBE_ELF := $(PI4_BUILD_DIR)/ABIPROBE.ELF
PI4_LAUNCHER_ELF := $(PI4_BUILD_DIR)/INIT.ELF
PI4_DOOM_ELF := $(PI4_BUILD_DIR)/DOOM.APP.ELF
PI4_QUAKE_ELF := $(PI4_BUILD_DIR)/QUAKE.APP.ELF
PI4_USER_ELF_MAX_BYTES := 524288
PI4_AARCH64_USER_FLAGS := --target=aarch64-none-elf -ffreestanding -nostdlib -Wall -Wextra -I. -Iuser
PI4_APP_INDEX_TXT := user/pi4_apps_index.txt
PI4_APP_DOOM_MANIFEST_TXT := user/pi4_app_doom.txt
PI4_APP_QUAKE_MANIFEST_TXT := user/pi4_app_quake.txt
PI4_APP_RECORD_ARGS := --asset /SYSTEM/INIT.ELF=$(PI4_LAUNCHER_ELF) --asset /SYSTEM/ABIPROBE.ELF=$(PI4_ABI_PROBE_ELF) --asset /APPS/INDEX.TXT=$(PI4_APP_INDEX_TXT) --asset /APPS/DOOM/MANIFEST.TXT=$(PI4_APP_DOOM_MANIFEST_TXT) --asset /APPS/DOOM/APP.ELF=$(PI4_DOOM_ELF) --asset /APPS/QUAKE/MANIFEST.TXT=$(PI4_APP_QUAKE_MANIFEST_TXT) --asset /APPS/QUAKE/APP.ELF=$(PI4_QUAKE_ELF)
PI4_APP_RECORD_DEPS := $(PI4_APP_INDEX_TXT) $(PI4_APP_DOOM_MANIFEST_TXT) $(PI4_APP_QUAKE_MANIFEST_TXT) $(PI4_DOOM_ELF) $(PI4_QUAKE_ELF)
export PI4_REAL_SSH_HOST PI4_REAL_SSH PI4_REAL_SCP
export PI4_REAL_BOOT_MOUNT PI4_REAL_VIBE_DIR PI4_REAL_NET_STATUS_FILE PI4_REAL_TRYBOOT_CANDIDATE PI4_REAL_TRYBOOT_ACTIVE
export PI4_REAL_ALLOW_REBOOT PI4_REAL_TRYBOOT_MANIFEST
export PI4_KERNEL8_IMG PI4_TRYBOOT_TXT PI4_LAUNCHER_ELF PI4_ABI_PROBE_ELF
export PI4_APP_INDEX_TXT PI4_APP_DOOM_MANIFEST_TXT PI4_DOOM_ELF
export PI4_APP_QUAKE_MANIFEST_TXT PI4_QUAKE_ELF
PROJECT_C_ALLOWLIST := tools/project_c_allowlist.txt
C_RUNTIME_SRC := kernel/c_runtime_probe.asm
USER_PROBE_ASM_SRC := user/probe.asm
USER_LAUNCHER_CRT0_ASM_SRC := user/launcher_crt0.asm
USER_ABI_PROBE_ASM_SRC := user/abi_probe.asm
USER_RUNTIME_ASM_SRC := user/runtime.asm
USER_LAUNCHER_ASM_SRC := user/launcher.asm
USER_LAUNCHER_MAIN_ASM_SRC := user/launcher_main.asm
USER_LIBC_ASM_SRC := user/libc.asm
VIBE_STATUS_CHECK_SRC := tools/vibe_status_check.asm
VIBE_STATUS_CHECK_OBJ := $(BUILD_DIR)/vibe_status_check.o
VIBE_STATUS_CHECK := $(BUILD_DIR)/vibe_status_check
DOOM_SRC_DIR := third_party/doom/linuxdoom-1.10
DOOM_PORT_INCLUDE_DIR := $(C_COMPAT_INCLUDE_ROOT)/doom
DOOM_PORT_BUILD_DIR := $(BUILD_DIR)/doom
DOOM_ELF := $(BUILD_DIR)/doom-app.elf
DOOM_SYMBOLS := $(BUILD_DIR)/doom.symbols
DOOM_BASE := 0x01000000
DOOM_ORIGINAL_SRCS := $(filter-out $(DOOM_SRC_DIR)/i_%.c,$(wildcard $(DOOM_SRC_DIR)/*.c))
DOOM_ORIGINAL_OBJS := $(DOOM_ORIGINAL_SRCS:$(DOOM_SRC_DIR)/%.c=$(DOOM_PORT_BUILD_DIR)/%.o)
DOOM_PORT_ASM_SRCS := doom_port/input.asm doom_port/music.asm doom_port/platform.asm doom_port/save_debug.asm doom_port/start.asm
DOOM_USER_LIBC_OBJ := $(DOOM_PORT_BUILD_DIR)/user_libc.o
DOOM_PORT_OBJS := $(DOOM_PORT_ASM_SRCS:doom_port/%.asm=$(DOOM_PORT_BUILD_DIR)/port_%.o) $(DOOM_USER_LIBC_OBJ)
FREESTANDING_I386_CFLAGS := -target i386-unknown-elf -ffreestanding -fno-builtin -fno-strict-aliasing -fno-stack-protector -fno-pic -fno-asynchronous-unwind-tables -fno-unwind-tables -m32 -march=i386 -mno-sse -mno-mmx -msoft-float -O2
DOOM_ORIGINAL_CFLAGS := $(FREESTANDING_I386_CFLAGS) -std=gnu89 -DNORMALUNIX -DLINUX -I$(DOOM_PORT_INCLUDE_DIR) -I$(DOOM_SRC_DIR)
DOOM_G_GAME_CFLAGS := -DG_BuildTiccmd=doom_original_G_BuildTiccmd -DG_Ticker=doom_original_G_Ticker
DOOM_P_SAVEG_CFLAGS := -DP_ArchivePlayers=doom_original_P_ArchivePlayers -DP_UnArchivePlayers=doom_original_P_UnArchivePlayers -DP_ArchiveWorld=doom_original_P_ArchiveWorld -DP_UnArchiveWorld=doom_original_P_UnArchiveWorld -DP_ArchiveThinkers=doom_original_P_ArchiveThinkers -DP_UnArchiveThinkers=doom_original_P_UnArchiveThinkers -DP_ArchiveSpecials=doom_original_P_ArchiveSpecials -DP_UnArchiveSpecials=doom_original_P_UnArchiveSpecials
QUAKE_SRC_DIR := third_party/quake/WinQuake
QUAKE_PORT_INCLUDE_DIR := $(C_COMPAT_INCLUDE_ROOT)/quake
QUAKE_PORT_BUILD_DIR := $(BUILD_DIR)/quake
QUAKE_ELF := $(BUILD_DIR)/quake-app.elf
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
QUAKE_USER_LIBC_OBJ := $(QUAKE_PORT_BUILD_DIR)/user_libc.o
QUAKE_PORT_OBJS := $(QUAKE_PORT_ASM_SRCS:quake_port/%.asm=$(QUAKE_PORT_BUILD_DIR)/port_%.o) $(QUAKE_USER_LIBC_OBJ)
QUAKE_FREESTANDING_I386_CFLAGS := -target i386-unknown-elf -ffreestanding -fno-builtin -fno-strict-aliasing -fno-stack-protector -fno-pic -fno-asynchronous-unwind-tables -fno-unwind-tables -m32 -march=i386 -mno-sse -mno-mmx -O2
QUAKE_ORIGINAL_CFLAGS := $(QUAKE_FREESTANDING_I386_CFLAGS) -std=gnu89 -fcommon -U__i386__ -Dstricmp=strcasecmp -I$(QUAKE_PORT_INCLUDE_DIR) -I$(DOOM_PORT_INCLUDE_DIR) -I$(QUAKE_SRC_DIR)
IMAGE_SECONDARY_PACKAGE_ARGS :=
ifneq ($(strip $(SECONDARY_PACKAGE)),)
IMAGE_SECONDARY_PACKAGE_ARGS := --asset /ID1/PAK0.PAK=$(SECONDARY_PACKAGE)
endif
IMAGE_ASSET_DEPS :=
ifneq ($(strip $(PRIMARY_ASSET)),)
IMAGE_ASSET_DEPS += $(PRIMARY_ASSET)
endif
ifneq ($(strip $(SECONDARY_PACKAGE)),)
IMAGE_ASSET_DEPS += $(SECONDARY_PACKAGE)
endif

STAGE2_MAX_BYTES := 8192
KERNEL_ELF_MAX_BYTES := 184320
USER_PROBE_ELF_MAX_BYTES := 16384
USER_ABI_PROBE_ELF_MAX_BYTES := 32768
INIT_APP_ELF_MAX_BYTES := 262144
APP_INDEX_TXT := user/apps_index.txt
APP_DOOM_MANIFEST_TXT := user/app_doom_manifest.txt
APP_QUAKE_MANIFEST_TXT := user/app_quake_manifest.txt
IMAGE_APP_ARGS := --asset /SYSTEM/INIT.ELF=$(USER_LAUNCHER_ELF) --asset /SYSTEM/ABIPROBE.ELF=$(USER_ABI_PROBE_ELF) --asset /APPS/INDEX.TXT=$(APP_INDEX_TXT) --asset /APPS/DOOM/MANIFEST.TXT=$(APP_DOOM_MANIFEST_TXT) --asset /APPS/DOOM/APP.ELF=$(DOOM_ELF) --asset /APPS/QUAKE/MANIFEST.TXT=$(APP_QUAKE_MANIFEST_TXT) --asset /APPS/QUAKE/APP.ELF=$(QUAKE_ELF)
IMAGE_EXTRA_ROOT_ELF_ARGS ?=
IMAGE_EXTRA_ROOT_ELF_DEPS ?=
IMAGE_ROOT_ELF_ARGS := $(IMAGE_APP_ARGS) $(IMAGE_EXTRA_ROOT_ELF_ARGS)

.PHONY: all build-only test clean check-tools FORCE
.PHONY: no-python-check project-c-inventory assembly-native-check
.PHONY: doom-compile doom-link quake-compile quake-link
.PHONY: play play-image run run-headless smoke persistence-image-check
.PHONY: quake-status-proof-check playability-host-check vm-consent vm-status-proof-check
.PHONY: image-builder-tool image-builder-inspect status-checker-tool
.PHONY: uefi-loader-object uefi-loader-pe uefi-dual-image
.PHONY: pi4-assembly-source-gate pi4-code-gates pi4-kernel8 pi4-user-elves pi4-doom-app pi4-quake-app
.PHONY: pi4-image pi4-image-inspect pi4-qemu-command
.PHONY: pi4-local-qemu-live pi4-local-qemu-smoke pi4-local-qemu-launcher-framebuffer
.PHONY: pi4-local-qemu-uart-select-doom pi4-local-qemu-uart-select-quake pi4-local-qemu-uart-select-apps
.PHONY: pi4-real-tryboot-manifest pi4-real-tryboot-stage pi4-real-tryboot-preflight pi4-real-tryboot-arm

all: $(IMAGE)

build-only: $(IMAGE) doom-link quake-link
	@printf "Build-only check OK: %s, %s, %s, %s, and %s are present.\n" "$(IMAGE)" "$(USER_LAUNCHER_ELF)" "$(DOOM_ELF)" "$(QUAKE_ELF)" "$(USER_ABI_PROBE_ELF)"

test: no-python-check project-c-inventory $(IMAGE) doom-link quake-link vm-status-proof-check assembly-native-check
	@printf "Assembly-first host checks OK: image build, Doom link, guest status validator, project C inventory, and assembly-native guest build audit passed.\n"

no-python-check:
	@set -e; \
	files="$$(git ls-files '*.py' ':(exclude)third_party/**' ':(exclude)build/**' ':(exclude)out/**')"; \
	if [ -n "$$files" ]; then \
		printf "Tracked Python is not allowed in the vibe-os build/proof path:\n%s\n" "$$files" >&2; \
		exit 1; \
	fi; \
	printf "No tracked Python in the vibe-os build/proof path.\n"

project-c-inventory:
	@set -e; \
	mkdir -p "$(BUILD_DIR)"; \
	actual="$(BUILD_DIR)/project-c-actual.txt"; \
	allow="$(BUILD_DIR)/project-c-allowlist.txt"; \
	find . -type f \( -name '*.c' -o -name '*.h' \) \
		-not -path './.git/*' \
		-not -path './build/*' \
		-not -path './third_party/*' \
		-print | sed 's#^\./##' | sort > "$$actual"; \
	sed '/^[[:space:]]*$$/d' "$(PROJECT_C_ALLOWLIST)" | sort > "$$allow"; \
	if ! diff -u "$$allow" "$$actual"; then \
		echo "project C/header inventory drifted; update $(PROJECT_C_ALLOWLIST) intentionally" >&2; \
		exit 1; \
	fi; \
	count="$$(wc -l < "$$actual" | tr -d ' ')"; \
	if [ -s "$$actual" ]; then \
		lines="$$(xargs wc -l < "$$actual" | awk 'END { print $$1 }')"; \
	else \
		lines=0; \
	fi; \
	printf "Project C/header inventory OK: %s files, %s lines remain outside third_party.\n" "$$count" "$$lines"

assembly-native-check:
	@MAKE="$(MAKE)" tools/check_assembly_native.sh

doom-compile: $(DOOM_ORIGINAL_OBJS)
	@printf "Compiled %s original Doom source files for freestanding i386.\n" "$$(printf '%s\n' $(DOOM_ORIGINAL_OBJS) | wc -l | tr -d ' ')"

doom-link: $(DOOM_ELF)
	@printf "Linked freestanding Doom app ELF at %s\n" "$(DOOM_ELF)"

quake-compile: $(QUAKE_ORIGINAL_OBJS)
	@printf "Compiled %s original Quake source files for freestanding i386.\n" "$$(printf '%s\n' $(QUAKE_ORIGINAL_OBJS) | wc -l | tr -d ' ')"

quake-link: $(QUAKE_ELF)
	@printf "Linked freestanding Quake app ELF at %s\n" "$(QUAKE_ELF)"

play:
	@tools/play_local.sh

play-image:
	@tools/play_local.sh --prepare-only

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
		echo "Rerun with ALLOW_LOCAL_VM=1 to use run, run-headless, smoke, pi4-local-qemu-live, or pi4-local-qemu-smoke."; \
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

$(PI4_BUILD_DIR):
	@mkdir -p $(PI4_BUILD_DIR)

$(PI4_REAL_HW_DIR):
	@mkdir -p $(PI4_REAL_HW_DIR)

$(C_COMPAT_HEADERS_STAMP): tools/install_c_compat_headers.sh | $(BUILD_DIR)
	bash tools/install_c_compat_headers.sh "$(C_COMPAT_INCLUDE_ROOT)"
	touch $@

$(STAGE1_BIN): boot/stage1.asm | $(BUILD_DIR)
	$(NASM) -f bin $< -o $@

$(STAGE2_BIN): boot/stage2.asm | $(BUILD_DIR)
	$(NASM) -f bin -D STAGE2_LBA=$(STAGE2_LBA) $< -o $@
	@test $$(wc -c < $@) -le $(STAGE2_MAX_BYTES) || { echo "stage2 exceeds $(STAGE2_MAX_BYTES) bytes"; exit 1; }

$(KERNEL_OBJ): kernel/kernel.asm | $(BUILD_DIR)
	$(NASM) -f elf32 -D ELF_KERNEL $(KERNEL_EXTRA_NASMFLAGS) $< -o $@

$(C_RUNTIME_OBJ): $(C_RUNTIME_SRC) | $(BUILD_DIR)
	$(NASM) -f elf32 $< -o $@

$(LINK_ELF32_OBJ): $(LINK_ELF32_SRC) | $(BUILD_DIR)
	$(NASM) -f $(HOST_NASM_FORMAT) $(HOST_NASM_DEFS) $< -o $@

$(LINK_ELF32): $(LINK_ELF32_OBJ) | $(BUILD_DIR)
	$(HOST_CC) $(HOST_NO_PIE) $< -o $@

$(LINK_AARCH64_FLAT_OBJ): $(LINK_AARCH64_FLAT_SRC) | $(BUILD_DIR)
	$(HOST_CC) -c $< -o $@

$(LINK_AARCH64_FLAT): $(LINK_AARCH64_FLAT_OBJ) | $(BUILD_DIR)
	$(HOST_CC) $(HOST_NO_PIE) $< -o $@

$(LINK_AARCH64_USER_ELF_OBJ): $(LINK_AARCH64_USER_ELF_SRC) | $(BUILD_DIR)
	$(HOST_CC) -c $< -o $@

$(LINK_AARCH64_USER_ELF): $(LINK_AARCH64_USER_ELF_OBJ) | $(BUILD_DIR)
	$(HOST_CC) $(HOST_NO_PIE) $< -o $@

$(IMAGE_BUILDER_OBJ): $(IMAGE_BUILDER_SRC) | $(BUILD_DIR)
	$(HOST_CC) -c $< -o $@

$(IMAGE_BUILDER): $(IMAGE_BUILDER_OBJ) | $(BUILD_DIR)
	$(HOST_CC) $(HOST_NO_PIE) $< -o $@

image-builder-tool: $(IMAGE_BUILDER)

$(VIBE_STATUS_CHECK_OBJ): $(VIBE_STATUS_CHECK_SRC) | $(BUILD_DIR)
	$(NASM) -f $(HOST_NASM_FORMAT) $(HOST_NASM_DEFS) $< -o $@

$(VIBE_STATUS_CHECK): $(VIBE_STATUS_CHECK_OBJ) | $(BUILD_DIR)
	$(HOST_CC) $(HOST_NO_PIE) $< -o $@

status-checker-tool: $(VIBE_STATUS_CHECK)

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

$(UEFI_DUAL_IMAGE): $(STAGE1_BIN) $(STAGE2_BIN) $(KERNEL_ELF) $(USER_PROBE_ELF) $(USER_LAUNCHER_ELF) $(USER_ABI_PROBE_ELF) $(DOOM_ELF) $(QUAKE_ELF) $(APP_INDEX_TXT) $(APP_DOOM_MANIFEST_TXT) $(APP_QUAKE_MANIFEST_TXT) $(IMAGE_BUILDER) $(UEFI_LOADER_EFI) $(IMAGE_ASSET_DEPS) $(IMAGE_EXTRA_ROOT_ELF_DEPS) | $(UEFI_BUILD_DIR)
	@if [ -n "$(PRIMARY_ASSET)" ]; then \
		$(IMAGE_BUILDER) --primary-asset-wad "$(PRIMARY_ASSET)" $(IMAGE_SECONDARY_PACKAGE_ARGS) --asset EFI/BOOT/BOOTX64.EFI=$(UEFI_LOADER_EFI) --asset VIBEOS/KERNEL.ELF=$(KERNEL_ELF) $(IMAGE_ROOT_ELF_ARGS) $@ $(STAGE1_BIN) $(STAGE2_BIN) $(KERNEL_ELF) $(USER_PROBE_ELF); \
	else \
		$(IMAGE_BUILDER) $(IMAGE_SECONDARY_PACKAGE_ARGS) --asset EFI/BOOT/BOOTX64.EFI=$(UEFI_LOADER_EFI) --asset VIBEOS/KERNEL.ELF=$(KERNEL_ELF) $(IMAGE_ROOT_ELF_ARGS) $@ $(STAGE1_BIN) $(STAGE2_BIN) $(KERNEL_ELF) $(USER_PROBE_ELF); \
	fi
	@printf "Built dual BIOS/UEFI FAT16 image %s\n" "$@"

uefi-dual-image: $(UEFI_DUAL_IMAGE)

pi4-assembly-source-gate:
	@set -e; \
	expected="$$(printf '%s\n' $(PI4_ASM_SRCS) | LC_ALL=C sort)"; \
	actual="$$( { \
		find boot/pi4 -type f \( -name '*.S' -o -name '*.s' \) -print 2>/dev/null; \
		find user -maxdepth 1 -type f \( -name 'pi4_*.S' -o -name 'pi4_*.s' \) -print 2>/dev/null; \
		find doom_port -maxdepth 1 -type f \( -name 'pi4_*.S' -o -name 'pi4_*.s' \) -print 2>/dev/null; \
		find quake_port -maxdepth 1 -type f \( -name 'pi4_*.S' -o -name 'pi4_*.s' \) -print 2>/dev/null; \
	} | LC_ALL=C sort )"; \
	if [ "$$actual" != "$$expected" ]; then \
		printf "Pi 4 assembly source wiring is stale.\nExpected:\n%s\nActual:\n%s\n" "$$expected" "$$actual" >&2; \
		exit 1; \
	fi; \
	printf "Pi 4 assembly source gate OK: boot, user, launcher, Doom, and Quake sources are wired.\n"

pi4-code-gates: no-python-check project-c-inventory pi4-assembly-source-gate $(PI4_KERNEL_OBJ) $(PI4_KERNEL_INPUT_OBJ) $(PI4_KERNEL_STORAGE_OBJ) $(PI4_KERNEL_NET_OBJ) $(PI4_LAUNCHER_ELF) $(PI4_ABI_PROBE_ELF) $(PI4_DOOM_ELF) $(PI4_QUAKE_ELF)
	@printf "Pi 4 code gates OK: built the assembly kernel object and linked /SYSTEM plus /APPS AArch64 ELFs.\n"

$(PI4_KERNEL_INPUT_OBJ): boot/pi4/input.S Makefile | $(PI4_BUILD_DIR)
	$(AARCH64_CC) --target=aarch64-none-elf -ffreestanding -nostdlib -Wall -Wextra -c $< -o $@

$(PI4_KERNEL_STORAGE_OBJ): boot/pi4/storage.S Makefile | $(PI4_BUILD_DIR)
	$(AARCH64_CC) --target=aarch64-none-elf -ffreestanding -nostdlib -Wall -Wextra -c $< -o $@

$(PI4_KERNEL_NET_OBJ): boot/pi4/net.S Makefile | $(PI4_BUILD_DIR)
	$(AARCH64_CC) --target=aarch64-none-elf -ffreestanding -nostdlib -Wall -Wextra -c $< -o $@

$(PI4_KERNEL_AGGREGATE_SRC): $(PI4_BOOT_ASM_SRCS) Makefile | $(PI4_BUILD_DIR)
	@{ for src in $(PI4_BOOT_ASM_SRCS); do printf '#include "%s"\n' "$(abspath .)/$$src"; done; } > $@

$(PI4_KERNEL_OBJ): $(PI4_KERNEL_AGGREGATE_SRC) Makefile | $(PI4_BUILD_DIR)
	$(AARCH64_CC) --target=aarch64-none-elf -ffreestanding -nostdlib -Wall -Wextra -c $(PI4_KERNEL_AGGREGATE_SRC) -o $@

$(PI4_KERNEL8_IMG): $(PI4_KERNEL_OBJ) $(LINK_AARCH64_FLAT) | $(PI4_BUILD_DIR)
	$(LINK_AARCH64_FLAT) -o $@ --base 0x80000 --map $(PI4_KERNEL8_MAP) $(PI4_KERNEL_OBJ)
	@grep -a -q "vibe-os pi4" $@
	@grep -a -q "arch=AARCH64 machine=PI4" $@

pi4-kernel8: $(PI4_KERNEL8_IMG)
	@printf "Built Raspberry Pi 4 kernel image %s\n" "$(PI4_KERNEL8_IMG)"

$(PI4_USER_CRT0_OBJ): user/pi4_crt0.S user/pi4_runtime.inc Makefile | $(PI4_BUILD_DIR)
	$(AARCH64_CC) $(PI4_AARCH64_USER_FLAGS) -c $< -o $@

$(PI4_USER_RUNTIME_OBJ): user/pi4_runtime.S user/pi4_runtime.inc Makefile | $(PI4_BUILD_DIR)
	$(AARCH64_CC) $(PI4_AARCH64_USER_FLAGS) -c $< -o $@

$(PI4_USER_ABI_PROBE_OBJ): user/pi4_abi_probe.S user/pi4_runtime.inc Makefile | $(PI4_BUILD_DIR)
	$(AARCH64_CC) $(PI4_AARCH64_USER_FLAGS) -c $< -o $@

$(PI4_USER_LAUNCHER_OBJ): user/pi4_launcher.S user/pi4_runtime.inc Makefile | $(PI4_BUILD_DIR)
	$(AARCH64_CC) $(PI4_AARCH64_USER_FLAGS) -c $< -o $@

$(PI4_USER_LAUNCHER_ASSETS_OBJ): user/pi4_launcher_assets.S user/pi4_runtime.inc Makefile | $(PI4_BUILD_DIR)
	$(AARCH64_CC) $(PI4_AARCH64_USER_FLAGS) -c $< -o $@

$(PI4_USER_LAUNCHER_ART_OBJ): user/pi4_launcher_art.S user/pi4_runtime.inc Makefile | $(PI4_BUILD_DIR)
	$(AARCH64_CC) $(PI4_AARCH64_USER_FLAGS) -c $< -o $@

$(PI4_DOOM_OBJ): doom_port/pi4_start.S user/pi4_runtime.inc Makefile | $(PI4_BUILD_DIR)
	$(AARCH64_CC) $(PI4_AARCH64_USER_FLAGS) -c $< -o $@

$(PI4_QUAKE_APP_OBJ): quake_port/pi4_app.S user/pi4_runtime.inc Makefile | $(PI4_BUILD_DIR)
	$(AARCH64_CC) $(PI4_AARCH64_USER_FLAGS) -c $< -o $@

$(PI4_ABI_PROBE_ELF): $(PI4_USER_CRT0_OBJ) $(PI4_USER_RUNTIME_OBJ) $(PI4_USER_ABI_PROBE_OBJ) $(LINK_AARCH64_USER_ELF) | $(PI4_BUILD_DIR)
	$(LINK_AARCH64_USER_ELF) -o $@ $(PI4_USER_CRT0_OBJ) $(PI4_USER_RUNTIME_OBJ) $(PI4_USER_ABI_PROBE_OBJ)
	@test $$(wc -c < $@) -le $(PI4_USER_ELF_MAX_BYTES) || { echo "Pi 4 ABI probe ELF exceeds $(PI4_USER_ELF_MAX_BYTES) bytes"; exit 1; }

$(PI4_LAUNCHER_ELF): $(PI4_USER_CRT0_OBJ) $(PI4_USER_RUNTIME_OBJ) $(PI4_USER_LAUNCHER_OBJ) $(PI4_USER_LAUNCHER_ASSETS_OBJ) $(PI4_USER_LAUNCHER_ART_OBJ) $(LINK_AARCH64_USER_ELF) | $(PI4_BUILD_DIR)
	$(LINK_AARCH64_USER_ELF) -o $@ $(PI4_USER_CRT0_OBJ) $(PI4_USER_RUNTIME_OBJ) $(PI4_USER_LAUNCHER_OBJ) $(PI4_USER_LAUNCHER_ASSETS_OBJ) $(PI4_USER_LAUNCHER_ART_OBJ)
	@test $$(wc -c < $@) -le $(PI4_USER_ELF_MAX_BYTES) || { echo "Pi 4 launcher ELF exceeds $(PI4_USER_ELF_MAX_BYTES) bytes"; exit 1; }

$(PI4_DOOM_ELF): $(PI4_USER_CRT0_OBJ) $(PI4_USER_RUNTIME_OBJ) $(PI4_DOOM_OBJ) $(LINK_AARCH64_USER_ELF) | $(PI4_BUILD_DIR)
	$(LINK_AARCH64_USER_ELF) -o $@ $(PI4_USER_CRT0_OBJ) $(PI4_USER_RUNTIME_OBJ) $(PI4_DOOM_OBJ)
	@test $$(wc -c < $@) -le $(PI4_USER_ELF_MAX_BYTES) || { echo "Pi 4 Doom app ELF exceeds $(PI4_USER_ELF_MAX_BYTES) bytes"; exit 1; }
	@LC_ALL=C strings $@ | grep -F -q "vibe-os pi4 /APPS/DOOM/APP.ELF Doom AArch64 runtime glue"

$(PI4_QUAKE_ELF): $(PI4_USER_CRT0_OBJ) $(PI4_USER_RUNTIME_OBJ) $(PI4_QUAKE_APP_OBJ) $(LINK_AARCH64_USER_ELF) | $(PI4_BUILD_DIR)
	$(LINK_AARCH64_USER_ELF) -o $@ $(PI4_USER_CRT0_OBJ) $(PI4_USER_RUNTIME_OBJ) $(PI4_QUAKE_APP_OBJ)
	@test $$(wc -c < $@) -le $(PI4_USER_ELF_MAX_BYTES) || { echo "Pi 4 Quake app ELF exceeds $(PI4_USER_ELF_MAX_BYTES) bytes"; exit 1; }
	@LC_ALL=C strings $@ | grep -F -q "vibe-os pi4 /APPS/QUAKE/APP.ELF Quake AArch64 app"

pi4-doom-app: $(PI4_DOOM_ELF)
	@printf "Built Pi 4 Doom app at %s\n" "$(PI4_DOOM_ELF)"

pi4-quake-app: $(PI4_QUAKE_ELF)
	@printf "Built Pi 4 Quake app at %s\n" "$(PI4_QUAKE_ELF)"

pi4-user-elves: $(PI4_LAUNCHER_ELF) $(PI4_ABI_PROBE_ELF) $(PI4_DOOM_ELF) $(PI4_QUAKE_ELF)
	@printf "Built Pi 4 user ELFs: %s, %s, %s, %s\n" "$(PI4_LAUNCHER_ELF)" "$(PI4_ABI_PROBE_ELF)" "$(PI4_DOOM_ELF)" "$(PI4_QUAKE_ELF)"

$(PI4_NET_STATUS_SEED): | $(PI4_BUILD_DIR)
	@dd if=/dev/zero of="$@" bs=512 count=1 >/dev/null 2>&1

$(PI4_IMAGE): $(PI4_KERNEL8_IMG) $(PI4_CONFIG_TXT) $(PI4_NET_STATUS_SEED) $(PI4_LAUNCHER_ELF) $(PI4_ABI_PROBE_ELF) $(PI4_APP_RECORD_DEPS) $(IMAGE_BUILDER) $(IMAGE_ASSET_DEPS) | $(PI4_BUILD_DIR)
	@if [ -n "$(PRIMARY_ASSET)" ]; then \
		$(IMAGE_BUILDER) --proof-manifest --primary-asset-wad "$(PRIMARY_ASSET)" $(IMAGE_SECONDARY_PACKAGE_ARGS) --root-file KERNEL8.IMG=$(PI4_KERNEL8_IMG) --root-file CONFIG.TXT=$(PI4_CONFIG_TXT) --root-file VIBESTAT.BIN=$(PI4_NET_STATUS_SEED) $(PI4_APP_RECORD_ARGS) $@; \
	else \
		$(IMAGE_BUILDER) --proof-manifest $(IMAGE_SECONDARY_PACKAGE_ARGS) --root-file KERNEL8.IMG=$(PI4_KERNEL8_IMG) --root-file CONFIG.TXT=$(PI4_CONFIG_TXT) --root-file VIBESTAT.BIN=$(PI4_NET_STATUS_SEED) $(PI4_APP_RECORD_ARGS) $@; \
	fi
	@printf "Built Raspberry Pi 4 FAT16 image %s with /SYSTEM plus /APPS app installs.\n" "$@"

pi4-image: $(PI4_IMAGE)

pi4-image-inspect: $(IMAGE_BUILDER) $(PI4_IMAGE)
	$(IMAGE_BUILDER) --inspect "$(PI4_IMAGE)" > "$(PI4_IMAGE_INSPECT_TXT)"
	@cat "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "manifest_file=KERNEL8.IMG state=present" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "manifest_file=CONFIG.TXT state=present" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "manifest_file=VIBESTAT.BIN state=present" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "manifest_file=/SYSTEM/INIT.ELF state=present" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "manifest_file=/APPS/INDEX.TXT state=present" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "app_exec=/APPS/DOOM/APP.ELF state=present model=generic-aarch64-el0-elf-by-path app=doom" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "app_exec=/APPS/QUAKE/APP.ELF state=present model=generic-aarch64-el0-elf-by-path app=quake" "$(PI4_IMAGE_INSPECT_TXT)"
	@! grep -a -E -q "PAYLOAD[0-9]+\\.ELF" "$(PI4_IMAGE)"

pi4-real-tryboot-manifest: $(PI4_KERNEL8_IMG) $(PI4_TRYBOOT_TXT) $(PI4_LAUNCHER_ELF) $(PI4_ABI_PROBE_ELF) $(PI4_APP_INDEX_TXT) $(PI4_APP_DOOM_MANIFEST_TXT) $(PI4_DOOM_ELF) $(PI4_APP_QUAKE_MANIFEST_TXT) $(PI4_QUAKE_ELF) $(PI4_REAL_TRYBOOT_TOOL) | $(PI4_REAL_HW_DIR)
	@"$(PI4_REAL_TRYBOOT_TOOL)" manifest

pi4-real-tryboot-stage: pi4-real-tryboot-manifest $(PI4_REAL_TRYBOOT_TOOL)
	@"$(PI4_REAL_TRYBOOT_TOOL)" stage

pi4-real-tryboot-preflight: pi4-real-tryboot-stage $(PI4_REAL_TRYBOOT_TOOL)
	@"$(PI4_REAL_TRYBOOT_TOOL)" preflight

pi4-real-tryboot-arm: pi4-real-tryboot-preflight $(PI4_REAL_TRYBOOT_TOOL)
	@"$(PI4_REAL_TRYBOOT_TOOL)" arm

pi4-qemu-command: $(PI4_IMAGE)
	@printf '%s %s\n' "$(PI4_HW_EQUIVALENT_QEMU)" "$(PI4_QEMU_ARGS)"

pi4-local-qemu-live: vm-consent $(PI4_IMAGE)
	@command -v "$(PI4_HW_EQUIVALENT_QEMU)" >/dev/null || { echo "missing $(PI4_HW_EQUIVALENT_QEMU)" >&2; exit 127; }
	@printf "Booting exact Pi 4 image: %s\n" "$(PI4_IMAGE)"
	@printf "Launcher uses /SYSTEM/INIT.ELF and discovers /APPS/DOOM and /APPS/QUAKE from FAT/VFS manifests.\n"
	$(PI4_HW_EQUIVALENT_QEMU) $(PI4_QEMU_ARGS)

pi4-local-qemu-smoke: vm-consent $(PI4_IMAGE)
	@command -v "$(PI4_HW_EQUIVALENT_QEMU)" >/dev/null || { echo "missing $(PI4_HW_EQUIVALENT_QEMU)" >&2; exit 127; }
	@rm -f "$(PI4_LOCAL_QEMU_SERIAL_LOG)"
	@printf "Booting exact Pi 4 image headlessly for %s seconds: %s\n" "$(PI4_LOCAL_QEMU_SMOKE_SECONDS)" "$(PI4_IMAGE)"
	@set -e; \
	"$(PI4_HW_EQUIVALENT_QEMU)" -M raspi4b,usb=on -cpu cortex-a72 -m 2G -kernel "$(PI4_KERNEL8_IMG)" -drive file="$(PI4_IMAGE)",if=sd,format=raw -serial file:"$(PI4_LOCAL_QEMU_SERIAL_LOG)" -display none -device usb-kbd -device usb-mouse $(PI4_QEMU_AUDIO_ARGS_SMOKE) -monitor none -no-reboot -no-shutdown & \
	pid=$$!; \
	sleep "$(PI4_LOCAL_QEMU_SMOKE_SECONDS)"; \
	if kill -0 "$$pid" >/dev/null 2>&1; then kill "$$pid" >/dev/null 2>&1 || true; fi; \
	wait "$$pid" >/dev/null 2>&1 || true; \
	test -s "$(PI4_LOCAL_QEMU_SERIAL_LOG)"; \
	tail -n 80 "$(PI4_LOCAL_QEMU_SERIAL_LOG)"; \
	grep -a -F -q "vibe-status arch=AARCH64 machine=PI4" "$(PI4_LOCAL_QEMU_SERIAL_LOG)"

pi4-local-qemu-launcher-framebuffer: vm-consent $(PI4_IMAGE)
	@command -v "$(PI4_HW_EQUIVALENT_QEMU)" >/dev/null || { echo "missing $(PI4_HW_EQUIVALENT_QEMU)" >&2; exit 127; }
	@rm -f "$(PI4_LOCAL_QEMU_FRAMEBUFFER_LOG)" "$(PI4_LOCAL_QEMU_FRAMEBUFFER_PPM)" "$(PI4_LOCAL_QEMU_MONITOR_SOCK)"
	@printf "Booting exact Pi 4 image and dumping the launcher framebuffer.\n"
	@set -e; \
	"$(PI4_HW_EQUIVALENT_QEMU)" -M raspi4b,usb=on -cpu cortex-a72 -m 2G -kernel "$(PI4_KERNEL8_IMG)" -drive file="$(PI4_IMAGE)",if=sd,format=raw -serial file:"$(PI4_LOCAL_QEMU_FRAMEBUFFER_LOG)" -display vnc=127.0.0.1:8 -device usb-kbd -device usb-mouse $(PI4_QEMU_AUDIO_ARGS_SMOKE) -monitor unix:"$(PI4_LOCAL_QEMU_MONITOR_SOCK)",server,nowait -no-reboot -no-shutdown & \
	qpid=$$!; \
	for _ in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do \
		test -S "$(PI4_LOCAL_QEMU_MONITOR_SOCK)" && break; \
		sleep 0.2; \
	done; \
	sleep "$(PI4_LOCAL_QEMU_SELECT_DELAY_SECONDS)"; \
	printf 'screendump %s\nquit\n' "$(PI4_LOCAL_QEMU_FRAMEBUFFER_PPM)" | "$(NC)" -U "$(PI4_LOCAL_QEMU_MONITOR_SOCK)" >/dev/null 2>&1 || true; \
	wait "$$qpid" >/dev/null 2>&1 || true; \
	test -s "$(PI4_LOCAL_QEMU_FRAMEBUFFER_LOG)"; \
	test -s "$(PI4_LOCAL_QEMU_FRAMEBUFFER_PPM)"; \
	file "$(PI4_LOCAL_QEMU_FRAMEBUFFER_PPM)"; \
	grep -a -F -q "exec=OK path=/SYSTEM/INIT.ELF" "$(PI4_LOCAL_QEMU_FRAMEBUFFER_LOG)"; \
	grep -a -F -q "fbpresent=" "$(PI4_LOCAL_QEMU_FRAMEBUFFER_LOG)"; \
	grep -a -F -q "fbchange=" "$(PI4_LOCAL_QEMU_FRAMEBUFFER_LOG)"; \
	grep -a -F -q "pi4runtime=OK" "$(PI4_LOCAL_QEMU_FRAMEBUFFER_LOG)"; \
	grep -a -F -q "panic=NONE" "$(PI4_LOCAL_QEMU_FRAMEBUFFER_LOG)"; \
	grep -a -F -q "shutdown=NONE" "$(PI4_LOCAL_QEMU_FRAMEBUFFER_LOG)"

pi4-local-qemu-uart-select-doom: vm-consent $(PI4_IMAGE)
	@command -v "$(PI4_HW_EQUIVALENT_QEMU)" >/dev/null || { echo "missing $(PI4_HW_EQUIVALENT_QEMU)" >&2; exit 127; }
	@rm -f "$(PI4_LOCAL_QEMU_DOOM_SERIAL_LOG)" "$(PI4_BUILD_DIR)/local-qemu-doom-uart.fifo"
	@mkfifo "$(PI4_BUILD_DIR)/local-qemu-doom-uart.fifo"
	@printf "Booting exact Pi 4 image and selecting Doom through the live UART input lane.\n"
	@set -e; \
	fifo="$(PI4_BUILD_DIR)/local-qemu-doom-uart.fifo"; \
	"$(PI4_HW_EQUIVALENT_QEMU)" -M raspi4b,usb=on -cpu cortex-a72 -m 2G -kernel "$(PI4_KERNEL8_IMG)" -drive file="$(PI4_IMAGE)",if=sd,format=raw -serial tcp:127.0.0.1:$(PI4_LOCAL_QEMU_DOOM_SELECT_PORT),server,nowait -display none -device usb-kbd -device usb-mouse $(PI4_QEMU_AUDIO_ARGS_SMOKE) -monitor none -no-reboot -no-shutdown & \
	qpid=$$!; \
	sleep 2; \
	"$(NC)" 127.0.0.1 "$(PI4_LOCAL_QEMU_DOOM_SELECT_PORT)" < "$$fifo" > "$(PI4_LOCAL_QEMU_DOOM_SERIAL_LOG)" & \
	ncpid=$$!; \
	exec 3>"$$fifo"; \
	sleep "$(PI4_LOCAL_QEMU_SELECT_DELAY_SECONDS)"; \
	printf '1' >&3; \
	sleep "$(PI4_LOCAL_QEMU_SELECT_SETTLE_SECONDS)"; \
	exec 3>&-; \
	kill "$$ncpid" >/dev/null 2>&1 || true; \
	if kill -0 "$$qpid" >/dev/null 2>&1; then kill "$$qpid" >/dev/null 2>&1 || true; fi; \
	wait "$$ncpid" >/dev/null 2>&1 || true; \
	wait "$$qpid" >/dev/null 2>&1 || true; \
	rm -f "$$fifo"; \
	grep -a -F -q "path=/APPS/DOOM/APP.ELF" "$(PI4_LOCAL_QEMU_DOOM_SERIAL_LOG)"; \
	grep -a -F -q "pi4exec=OK" "$(PI4_LOCAL_QEMU_DOOM_SERIAL_LOG)"; \
	grep -a -F -q "pi4appvfs=0x000000000000000e/0x00000000464f4f4b" "$(PI4_LOCAL_QEMU_DOOM_SERIAL_LOG)"; \
	grep -a -F -q "pi4preempt=OK" "$(PI4_LOCAL_QEMU_DOOM_SERIAL_LOG)"; \
	grep -a -F -q "pi4audio=OK" "$(PI4_LOCAL_QEMU_DOOM_SERIAL_LOG)"; \
	grep -a -F -q "pi4audiohw=USB-AUDIO" "$(PI4_LOCAL_QEMU_DOOM_SERIAL_LOG)"; \
	grep -a -F -q "panic=NONE" "$(PI4_LOCAL_QEMU_DOOM_SERIAL_LOG)"; \
	grep -a -F -q "shutdown=NONE" "$(PI4_LOCAL_QEMU_DOOM_SERIAL_LOG)"; \
	test -s "$(PI4_BUILD_DIR)/pi4-local-qemu-audio.wav"; \
	perl -e 'my $$p=shift; open my $$fh,"<:raw",$$p or die $$!; read $$fh,my $$b,-s $$fh; my $$d=substr($$b,44); my $$n=($$d=~tr/\x00\x80//c); die "flat Pi audio capture\n" unless $$n > 0; print "pi4audio_wav_bytes=",length($$b)," pi4audio_wav_nonflat=$$n/",length($$d),"\n";' "$(PI4_BUILD_DIR)/pi4-local-qemu-audio.wav"; \
	last_status="$$(grep -a "pi4audio=OK" "$(PI4_LOCAL_QEMU_DOOM_SERIAL_LOG)" | tail -n 1)"; \
	printf '%s\n' "$$last_status" | tr ' ' '\n' | grep -E '^(path|upath|pi4exec|pi4appreq|pi4appvfs|pi4inputevt|fbpresent|fbchange|pi4preempt|pi4mem|pi4vfs|pi4audio|pi4audiohw|pi4audiousb|pi4audioq|pi4audiocount|panic|shutdown)='

pi4-local-qemu-uart-select-quake: vm-consent $(PI4_IMAGE)
	@command -v "$(PI4_HW_EQUIVALENT_QEMU)" >/dev/null || { echo "missing $(PI4_HW_EQUIVALENT_QEMU)" >&2; exit 127; }
	@rm -f "$(PI4_LOCAL_QEMU_QUAKE_SERIAL_LOG)" "$(PI4_BUILD_DIR)/local-qemu-quake-uart.fifo"
	@mkfifo "$(PI4_BUILD_DIR)/local-qemu-quake-uart.fifo"
	@printf "Booting exact Pi 4 image and selecting Quake through the live UART input lane.\n"
	@set -e; \
	fifo="$(PI4_BUILD_DIR)/local-qemu-quake-uart.fifo"; \
	"$(PI4_HW_EQUIVALENT_QEMU)" -M raspi4b,usb=on -cpu cortex-a72 -m 2G -kernel "$(PI4_KERNEL8_IMG)" -drive file="$(PI4_IMAGE)",if=sd,format=raw -serial tcp:127.0.0.1:$(PI4_LOCAL_QEMU_QUAKE_SELECT_PORT),server,nowait -display none -device usb-kbd -device usb-mouse $(PI4_QEMU_AUDIO_ARGS_SMOKE) -monitor none -no-reboot -no-shutdown & \
	qpid=$$!; \
	sleep 2; \
	"$(NC)" 127.0.0.1 "$(PI4_LOCAL_QEMU_QUAKE_SELECT_PORT)" < "$$fifo" > "$(PI4_LOCAL_QEMU_QUAKE_SERIAL_LOG)" & \
	ncpid=$$!; \
	exec 3>"$$fifo"; \
	sleep "$(PI4_LOCAL_QEMU_SELECT_DELAY_SECONDS)"; \
	printf '2' >&3; \
	sleep "$(PI4_LOCAL_QEMU_SELECT_SETTLE_SECONDS)"; \
	exec 3>&-; \
	kill "$$ncpid" >/dev/null 2>&1 || true; \
	if kill -0 "$$qpid" >/dev/null 2>&1; then kill "$$qpid" >/dev/null 2>&1 || true; fi; \
	wait "$$ncpid" >/dev/null 2>&1 || true; \
	wait "$$qpid" >/dev/null 2>&1 || true; \
	rm -f "$$fifo"; \
	grep -a -F -q "path=/APPS/QUAKE/APP.ELF" "$(PI4_LOCAL_QEMU_QUAKE_SERIAL_LOG)"; \
	grep -a -F -q "pi4exec=OK" "$(PI4_LOCAL_QEMU_QUAKE_SERIAL_LOG)"; \
	grep -a -F -q "pi4appvfs=0x000000000000000f/0x00000000464f4f4b" "$(PI4_LOCAL_QEMU_QUAKE_SERIAL_LOG)"; \
	grep -a -F -q "pi4preempt=OK" "$(PI4_LOCAL_QEMU_QUAKE_SERIAL_LOG)"; \
	grep -a -F -q "pi4audio=OK" "$(PI4_LOCAL_QEMU_QUAKE_SERIAL_LOG)"; \
	grep -a -F -q "pi4audiohw=USB-AUDIO" "$(PI4_LOCAL_QEMU_QUAKE_SERIAL_LOG)"; \
	grep -a -F -q "panic=NONE" "$(PI4_LOCAL_QEMU_QUAKE_SERIAL_LOG)"; \
	grep -a -F -q "shutdown=NONE" "$(PI4_LOCAL_QEMU_QUAKE_SERIAL_LOG)"; \
	test -s "$(PI4_BUILD_DIR)/pi4-local-qemu-audio.wav"; \
	perl -e 'my $$p=shift; open my $$fh,"<:raw",$$p or die $$!; read $$fh,my $$b,-s $$fh; my $$d=substr($$b,44); my $$n=($$d=~tr/\x00\x80//c); die "flat Pi audio capture\n" unless $$n > 0; print "pi4audio_wav_bytes=",length($$b)," pi4audio_wav_nonflat=$$n/",length($$d),"\n";' "$(PI4_BUILD_DIR)/pi4-local-qemu-audio.wav"; \
	last_status="$$(grep -a "pi4audio=OK" "$(PI4_LOCAL_QEMU_QUAKE_SERIAL_LOG)" | tail -n 1)"; \
	printf '%s\n' "$$last_status" | tr ' ' '\n' | grep -E '^(path|upath|pi4exec|pi4appreq|pi4appvfs|pi4inputevt|fbpresent|fbchange|pi4preempt|pi4mem|pi4vfs|pi4audio|pi4audiohw|pi4audiousb|pi4audioq|pi4audiocount|panic|shutdown)='

pi4-local-qemu-uart-select-apps: pi4-local-qemu-uart-select-doom pi4-local-qemu-uart-select-quake
	@printf "Pi 4 QEMU app selection OK for Doom and Quake through the live UART input lane.\n"

$(KERNEL_ELF): $(KERNEL_OBJ) $(C_RUNTIME_OBJ) $(LINK_ELF32) | $(BUILD_DIR)
	$(LINK_ELF32) -o $@ --base 0x10000 $(KERNEL_OBJ) $(C_RUNTIME_OBJ)
	@test $$(wc -c < $@) -le $(KERNEL_ELF_MAX_BYTES) || { echo "kernel ELF exceeds $(KERNEL_ELF_MAX_BYTES) bytes"; exit 1; }

$(USER_CRT0_OBJ): user/crt0.asm | $(BUILD_DIR)
	$(NASM) -f elf32 $< -o $@

$(USER_LAUNCHER_CRT0_OBJ): $(USER_LAUNCHER_CRT0_ASM_SRC) | $(BUILD_DIR)
	$(NASM) -f elf32 $< -o $@

$(USER_PROBE_OBJ): $(USER_PROBE_ASM_SRC) | $(BUILD_DIR)
	$(NASM) -f elf32 $< -o $@

$(USER_ABI_PROBE_OBJ): $(USER_ABI_PROBE_ASM_SRC) FORCE | $(BUILD_DIR)
	$(NASM) -f elf32 $(USER_ABI_PROBE_NASMFLAGS) $< -o $@

$(USER_RUNTIME_OBJ): $(USER_RUNTIME_ASM_SRC) | $(BUILD_DIR)
	$(NASM) -f elf32 $< -o $@

$(USER_LAUNCHER_OBJ): $(USER_LAUNCHER_ASM_SRC) | $(BUILD_DIR)
	$(NASM) -f elf32 $< -o $@

$(USER_LAUNCHER_MAIN_OBJ): $(USER_LAUNCHER_MAIN_ASM_SRC) | $(BUILD_DIR)
	$(NASM) -f elf32 $< -o $@

$(USER_LAUNCHER_ELF): $(USER_LAUNCHER_CRT0_OBJ) $(USER_RUNTIME_OBJ) $(USER_LAUNCHER_OBJ) $(USER_LAUNCHER_MAIN_OBJ) $(LINK_ELF32) | $(BUILD_DIR)
	$(LINK_ELF32) -o $@ --base 0x00e80000 $(USER_LAUNCHER_CRT0_OBJ) $(USER_RUNTIME_OBJ) $(USER_LAUNCHER_OBJ) $(USER_LAUNCHER_MAIN_OBJ)
	@test $$(wc -c < $@) -le $(INIT_APP_ELF_MAX_BYTES) || { echo "init app ELF exceeds $(INIT_APP_ELF_MAX_BYTES) bytes"; exit 1; }

$(DOOM_PORT_BUILD_DIR)/%.o: $(DOOM_SRC_DIR)/%.c Makefile $(C_COMPAT_HEADERS_STAMP) | $(DOOM_PORT_BUILD_DIR)
	$(CLANG) $(DOOM_ORIGINAL_CFLAGS) -c $< -o $@

$(DOOM_PORT_BUILD_DIR)/g_game.o: $(DOOM_SRC_DIR)/g_game.c Makefile $(C_COMPAT_HEADERS_STAMP) | $(DOOM_PORT_BUILD_DIR)
	$(CLANG) $(DOOM_ORIGINAL_CFLAGS) $(DOOM_G_GAME_CFLAGS) -c $< -o $@

$(DOOM_PORT_BUILD_DIR)/p_saveg.o: $(DOOM_SRC_DIR)/p_saveg.c Makefile $(C_COMPAT_HEADERS_STAMP) | $(DOOM_PORT_BUILD_DIR)
	$(CLANG) $(DOOM_ORIGINAL_CFLAGS) $(DOOM_P_SAVEG_CFLAGS) -c $< -o $@

$(DOOM_PORT_BUILD_DIR)/port_input.o: doom_port/input.asm Makefile | $(DOOM_PORT_BUILD_DIR)
	$(NASM) -f elf32 $< -o $@

$(DOOM_USER_LIBC_OBJ): $(USER_LIBC_ASM_SRC) Makefile | $(DOOM_PORT_BUILD_DIR)
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

$(QUAKE_PORT_BUILD_DIR)/%.o: $(QUAKE_SRC_DIR)/%.c Makefile $(C_COMPAT_HEADERS_STAMP) | $(QUAKE_PORT_BUILD_DIR)
	$(CLANG) $(QUAKE_ORIGINAL_CFLAGS) -c $< -o $@

$(QUAKE_PORT_BUILD_DIR)/port_%.o: quake_port/%.asm Makefile | $(QUAKE_PORT_BUILD_DIR)
	$(NASM) -f elf32 $< -o $@

$(QUAKE_USER_LIBC_OBJ): $(USER_LIBC_ASM_SRC) Makefile | $(QUAKE_PORT_BUILD_DIR)
	$(NASM) -f elf32 $< -o $@

$(QUAKE_ELF): $(QUAKE_ORIGINAL_OBJS) $(QUAKE_PORT_OBJS) $(LINK_ELF32) | $(BUILD_DIR)
	$(LINK_ELF32) -o $@ --base $(QUAKE_BASE) --map $(QUAKE_SYMBOLS) $(QUAKE_ORIGINAL_OBJS) $(QUAKE_PORT_OBJS)

$(USER_PROBE_ELF): $(USER_CRT0_OBJ) $(USER_PROBE_OBJ) $(LINK_ELF32) | $(BUILD_DIR)
	$(LINK_ELF32) -o $@ --base 0x00e80000 $(USER_CRT0_OBJ) $(USER_PROBE_OBJ)
	@test $$(wc -c < $@) -le $(USER_PROBE_ELF_MAX_BYTES) || { echo "user probe ELF exceeds $(USER_PROBE_ELF_MAX_BYTES) bytes"; exit 1; }

$(USER_ABI_PROBE_ELF): $(USER_CRT0_OBJ) $(USER_RUNTIME_OBJ) $(USER_ABI_PROBE_OBJ) $(USER_LAUNCHER_OBJ) $(LINK_ELF32) | $(BUILD_DIR)
	$(LINK_ELF32) -o $@ --base 0x00e80000 $(USER_CRT0_OBJ) $(USER_RUNTIME_OBJ) $(USER_LAUNCHER_OBJ) $(USER_ABI_PROBE_OBJ)
	@test $$(wc -c < $@) -le $(USER_ABI_PROBE_ELF_MAX_BYTES) || { echo "ABI probe ELF exceeds $(USER_ABI_PROBE_ELF_MAX_BYTES) bytes"; exit 1; }

$(IMAGE): $(STAGE1_BIN) $(STAGE2_BIN) $(KERNEL_ELF) $(USER_PROBE_ELF) $(USER_LAUNCHER_ELF) $(USER_ABI_PROBE_ELF) $(DOOM_ELF) $(QUAKE_ELF) $(APP_INDEX_TXT) $(APP_DOOM_MANIFEST_TXT) $(APP_QUAKE_MANIFEST_TXT) $(IMAGE_BUILDER) $(IMAGE_ASSET_DEPS) $(IMAGE_EXTRA_ROOT_ELF_DEPS)
	@if [ -n "$(PRIMARY_ASSET)" ]; then \
		$(IMAGE_BUILDER) --primary-asset-wad "$(PRIMARY_ASSET)" $(IMAGE_SECONDARY_PACKAGE_ARGS) $(IMAGE_ROOT_ELF_ARGS) $@ $(STAGE1_BIN) $(STAGE2_BIN) $(KERNEL_ELF) $(USER_PROBE_ELF); \
	else \
		$(IMAGE_BUILDER) $(IMAGE_SECONDARY_PACKAGE_ARGS) $(IMAGE_ROOT_ELF_ARGS) $@ $(STAGE1_BIN) $(STAGE2_BIN) $(KERNEL_ELF) $(USER_PROBE_ELF); \
	fi
	@printf "Built %s\n" "$@"

run: vm-consent check-tools $(IMAGE)
	$(QEMU) -machine $(QEMU_MACHINE) -drive file=$(IMAGE),format=raw,if=ide,index=0,media=disk -boot c $(QEMU_EXTRA_ARGS)

run-headless: vm-consent check-tools $(IMAGE)
	$(QEMU) -machine $(QEMU_MACHINE) -drive file=$(IMAGE),format=raw,if=ide,index=0,media=disk -boot c -display none -monitor none $(QEMU_EXTRA_ARGS)

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
	grep -q "path=/APPS/DOOM/APP.ELF" $(BUILD_DIR)/status.txt; \
	grep -q "uexec=OK" $(BUILD_DIR)/status.txt; \
	grep -q "upath=/SYSTEM/INIT.ELF" $(BUILD_DIR)/status.txt; \
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
		grep -q "path=/APPS/DOOM/APP.ELF" $(BUILD_DIR)/status.txt; \
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
	printf "Smoke boot OK: protected-mode kernel status, Ring 3 probe, primary payload ELF load, indexed-frame present, and PIT ticks verified in cloud VM memory.\n"

quake-status-proof-check:
	@set -e; \
	test -s $(BUILD_DIR)/status.txt; \
	grep -q "path=/APPS/QUAKE/APP.ELF" $(BUILD_DIR)/status.txt; \
	grep -q "quake=OK" $(BUILD_DIR)/status.txt; \
	grep -q "quakerun=RUN" $(BUILD_DIR)/status.txt; \
	grep -q "quakeopen=OK" $(BUILD_DIR)/status.txt; \
	grep -q "quakeread=OK" $(BUILD_DIR)/status.txt; \
	grep -q "qgame=OK" $(BUILD_DIR)/status.txt; \
	grep -q "panic=NONE" $(BUILD_DIR)/status.txt; \
	grep -q "shutdown=NONE" $(BUILD_DIR)/status.txt; \
	grep -q "gfx=OK" $(BUILD_DIR)/status.txt; \
	grep -q "audio=SB16" $(BUILD_DIR)/status.txt; \
	grep -q "heap=OK" $(BUILD_DIR)/status.txt; \
	perl -ne '$$ok = 1 if /preempt=([0-9A-F]{8})/ && hex($$1) > 0; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
	perl -ne '$$ok = 1 if /quakepak=([0-9A-F]{8})\/([0-9A-F]{8})\/([0-9A-F]{8})\/([0-9A-F]{8})/ && hex($$1) > 0 && hex($$4) == 0x4B434150; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
	perl -ne '$$ok = 1 if /quakepresent=([0-9A-F]{8})/ && hex($$1) > 0; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
	perl -ne '$$ok = 1 if /qframe=([0-9A-F]{8})\/([0-9A-F]{8})/ && hex($$1) > 0 && hex($$2) > 0; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
	perl -ne '$$ok = 1 if /qinput=([0-9A-F]{8})\// && hex($$1) > 0; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
	perl -ne '$$ok = 1 if /qaudio=([0-9A-F]{8})\// && hex($$1) > 0; END { exit($$ok ? 0 : 1) }' $(BUILD_DIR)/status.txt; \
	printf "Quake proof status OK: /APPS/QUAKE/APP.ELF, PAK reads, rendered frames, input, audio, process, memory, preemption, panic, and shutdown gates passed.\n"

vm-status-proof-check:
	BUILD_DIR="$(abspath $(BUILD_DIR))" HOST_CC="$(HOST_CC)" HOST_NO_PIE="$(HOST_NO_PIE)" tools/test_vibe_status_check.sh

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
