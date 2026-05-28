NASM ?= nasm
QEMU ?= qemu-system-x86_64
CLANG ?= clang
AARCH64_CC ?= clang
AARCH64_NM ?= nm
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
PI4_REAL_DOOM_WAD ?= $(DOOM_WAD)
PI4_REAL_QUAKE_PAK ?= $(QUAKE_PAK)
PI4_REQUIRE_REAL_ASSETS ?= 0
PRIMARY_ASSET ?= $(DOOM_WAD)
SECONDARY_PACKAGE ?= $(QUAKE_PAK)
SMOKE_EXPECT_PROBE_GFX ?= 1
SMOKE_REJECT_DOOMLOG ?=
SMOKE_SENDKEYS ?=
SMOKE_INPUT_SCRIPT ?= launcher-select:1,wait-status=path:/APPS/DOOM/APP.ELF:30:1,wait-status=doom:OK:30:1
SMOKE_REQUIRE_DOOM_PRESENT ?= 0
SMOKE_REQUIRE_KEY_EVENT ?= 0
SMOKE_REQUIRE_DOOM_GAMEPLAY ?= 0
SMOKE_REQUIRE_REAL_WAD_PROOF ?= 0
SMOKE_REQUIRE_HUMAN_PLAYABILITY_PROOF ?= 0
SMOKE_REQUIRE_AUDIO_CONTINUITY ?= 0
SMOKE_SKIP_ASSERTIONS ?= 0
SMOKE_NC_TIMEOUT ?= 3
SMOKE_QEMU_TIMEOUT ?= 75
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
REAL_ASSET_CACHE_DIR ?= /tmp/vibe-os-game-assets
REAL_ASSET_SUBBUILD := $(MAKE)
PI4_LOCAL_QEMU_LIVE_IMAGE_DEPS ?= $(PI4_EXACT_BOOT_IMAGE_DEPS)
STAGE2_LBA ?= 1
STAGE1_BIN := $(BUILD_DIR)/stage1.bin
STAGE2_BIN := $(BUILD_DIR)/stage2.bin
KERNEL_OBJ := $(BUILD_DIR)/kernel.o
C_RUNTIME_OBJ := $(BUILD_DIR)/c_runtime_probe.o
KERNEL_ELF := $(BUILD_DIR)/kernel.elf
LINK_ELF32 := $(BUILD_DIR)/link_elf32
LINK_AARCH64_FLAT := $(BUILD_DIR)/link_aarch64_flat
LINK_AARCH64_USER_ELF := $(BUILD_DIR)/link_aarch64_user_elf
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
IMAGE_INSPECT_TXT := $(BUILD_DIR)/image-builder-inspect.txt
PI4_STATUS_EVIDENCE := $(BUILD_DIR)/pi4_status_evidence
PI4_QEMU_COMMAND := $(BUILD_DIR)/pi4_qemu_command
UEFI_BUILD_DIR := $(BUILD_DIR)/uefi
UEFI_LOADER_OBJ := $(UEFI_BUILD_DIR)/loader.obj
UEFI_LOADER_EFI := $(UEFI_BUILD_DIR)/BOOTX64.EFI
UEFI_DUAL_IMAGE := $(UEFI_BUILD_DIR)/uefi-fat16.img
PI4_BUILD_DIR := $(BUILD_DIR)/pi4
PI4_KERNEL_INPUT_OBJ := $(PI4_BUILD_DIR)/pi4-input.o
PI4_KERNEL_STORAGE_OBJ := $(PI4_BUILD_DIR)/pi4-storage.o
PI4_KERNEL_AGGREGATE_SRC := $(PI4_BUILD_DIR)/pi4-kernel.S
PI4_KERNEL_OBJ := $(PI4_BUILD_DIR)/pi4-start.o
PI4_KERNEL_OBJS := $(PI4_KERNEL_INPUT_OBJ) $(PI4_KERNEL_STORAGE_OBJ)
PI4_KERNEL8_IMG := $(PI4_BUILD_DIR)/kernel8.img
PI4_KERNEL8_MAP := $(PI4_BUILD_DIR)/kernel8.map
PI4_KERNEL8_DIS := $(PI4_BUILD_DIR)/kernel8.dis
PI4_HOST_PROOF_JSON := $(BUILD_DIR)/pi4-host-proof.json
PI4_HOST_PROOF_MAX_BYTES := 4096
PI4_EVIDENCE_SUMMARY := $(BUILD_DIR)/pi4-evidence-summary.txt
PI4_EVIDENCE_SUMMARY_MAX_BYTES := 2048
PI4_EVIDENCE_SURFACE_FILES := Makefile .gitignore .github/workflows/pi4-host-check.yml .github/workflows/pi4-hw-equivalent.yml tools/pi4_status_evidence.c tools/vibe_status_check.c tests/fixtures/pi4_status_hardware_evidence_ok.txt
PI4_NEXT_RISKY_RUNTIME_SURFACE := real-pi4-hardware-final-gate-sd-fat-vfs-wad-pak-launch-audio-preempt-panic-none-shutdown-none
PI4_STATUS_EVIDENCE_OK := $(PI4_BUILD_DIR)/pi4-status-evidence-ok.txt
PI4_STATUS_SERIAL_LAST_OK := $(PI4_BUILD_DIR)/pi4-status-serial-last-ok.txt
PI4_STATUS_SERIAL_LAST_BAD := $(PI4_BUILD_DIR)/pi4-status-serial-last-bad.txt
PI4_CONFIG_TXT := boot/pi4/config.txt
PI4_IMAGE := $(PI4_BUILD_DIR)/pi4-fat16.img
PI4_IMAGE_INSPECT_TXT := $(PI4_BUILD_DIR)/pi4-image-inspect.txt
PI4_REAL_ASSET_IMAGE := $(PI4_BUILD_DIR)/pi4-real-assets-fat16.img
PI4_REAL_ASSET_IMAGE_INSPECT_TXT := $(PI4_BUILD_DIR)/pi4-real-assets-image-inspect.txt
PI4_REAL_ASSET_HANDOFF := $(PI4_BUILD_DIR)/pi4-real-assets-handoff.txt
PI4_EXACT_BOOT_IMAGE ?= $(PI4_REAL_ASSET_IMAGE)
PI4_EXACT_BOOT_IMAGE_INSPECT_TXT ?= $(PI4_REAL_ASSET_IMAGE_INSPECT_TXT)
PI4_EXACT_BOOT_IMAGE_DEPS ?= pi4-prepared-real-assets-image
PI4_REAL_ASSET_PROOF_IMAGE ?= $(PI4_REAL_ASSET_IMAGE)
PI4_REAL_ASSET_PROOF_IMAGE_INSPECT_TXT ?= $(PI4_REAL_ASSET_IMAGE_INSPECT_TXT)
PI4_LOCAL_QEMU_LIVE_IMAGE = $(PI4_EXACT_BOOT_IMAGE)
PI4_HW_EQUIVALENT_QEMU ?= qemu-system-aarch64
PI4_HW_EQUIVALENT_SERIAL ?= stdio
PI4_HW_EQUIVALENT_IMAGE ?= $(PI4_EXACT_BOOT_IMAGE)
PI4_HW_EQUIVALENT_IMAGE_DEPS ?= $(PI4_EXACT_BOOT_IMAGE_DEPS)
PI4_HW_EQUIVALENT_REAL_ASSET_IMAGE ?= $(PI4_EXACT_BOOT_IMAGE)
PI4_HW_EQUIVALENT_REAL_ASSET_IMAGE_INSPECT_TXT ?= $(PI4_EXACT_BOOT_IMAGE_INSPECT_TXT)
PI4_HW_EQUIVALENT_REAL_ASSET_IMAGE_DEPS ?= $(PI4_EXACT_BOOT_IMAGE_DEPS)
PI4_HW_EQUIVALENT_REAL_ASSET_SECONDS ?= $(PI4_LOCAL_QEMU_REAL_ASSET_SECONDS)
PI4_HW_EQUIVALENT_QEMU_ARGS := -M raspi4b,usb=on -cpu cortex-a72 -m 2G -kernel $(PI4_KERNEL8_IMG) -drive file=$(PI4_HW_EQUIVALENT_IMAGE),if=sd,format=raw -serial $(PI4_HW_EQUIVALENT_SERIAL) -display none -device usb-kbd -device usb-mouse -monitor none -no-reboot -no-shutdown
PI4_LOCAL_QEMU_SECONDS ?= 8
PI4_LOCAL_QEMU_REAL_ASSET_SECONDS ?= 60
PI4_LOCAL_QEMU_LIVE_SERIAL ?= stdio
PI4_LOCAL_QEMU_LIVE_SECONDS ?= 2
PI4_LOCAL_QEMU_DOOM_SECONDS ?= 90
PI4_LOCAL_QEMU_QUAKE_SECONDS ?= 180
PI4_LOCAL_QEMU_DOOM_FRAME1_SETTLE_MS ?= 20000
PI4_LOCAL_QEMU_QUAKE_FRAME1_SETTLE_MS ?= 120000
PI4_LOCAL_QEMU_DOOM_INPUT ?= key=1,mousebtn=1,mousebtn=0,wait=6000,key=w
PI4_LOCAL_QEMU_QUAKE_INPUT ?= key=2,mouse=127:0,mouse=127:0,mouse=127:0,mouse=127:0,mouse=127:0,mousebtn=1,mousebtn=0,wait=6000,key=s
PI4_QEMU_USB_KEYBOARD ?= 1
PI4_QEMU_USB_MOUSE ?= 1
PI4_LOCAL_QEMU_SERIAL := $(PI4_BUILD_DIR)/local-qemu-serial.txt
PI4_LOCAL_QEMU_STATUS_RAW := $(PI4_BUILD_DIR)/local-qemu-status-raw.txt
PI4_LOCAL_QEMU_STATUS := $(PI4_BUILD_DIR)/local-qemu-status.txt
PI4_LOCAL_QEMU_DOOM_SERIAL := $(PI4_BUILD_DIR)/local-qemu-doom-serial.txt
PI4_LOCAL_QEMU_DOOM_STATUS_RAW := $(PI4_BUILD_DIR)/local-qemu-doom-status-raw.txt
PI4_LOCAL_QEMU_DOOM_STATUS := $(PI4_BUILD_DIR)/local-qemu-doom-status.txt
PI4_LOCAL_QEMU_DOOM_FB_REPORT := $(PI4_BUILD_DIR)/local-qemu-doom-framebuffer.txt
PI4_LOCAL_QEMU_DOOM_FB_FRAME0 := $(PI4_BUILD_DIR)/local-qemu-doom-frame0.ppm
PI4_LOCAL_QEMU_DOOM_FB_FRAME1 := $(PI4_BUILD_DIR)/local-qemu-doom-frame1.ppm
PI4_LOCAL_QEMU_QUAKE_SERIAL := $(PI4_BUILD_DIR)/local-qemu-quake-serial.txt
PI4_LOCAL_QEMU_QUAKE_STATUS_RAW := $(PI4_BUILD_DIR)/local-qemu-quake-status-raw.txt
PI4_LOCAL_QEMU_QUAKE_STATUS := $(PI4_BUILD_DIR)/local-qemu-quake-status.txt
PI4_LOCAL_QEMU_QUAKE_FB_REPORT := $(PI4_BUILD_DIR)/local-qemu-quake-framebuffer.txt
PI4_LOCAL_QEMU_QUAKE_FB_FRAME0 := $(PI4_BUILD_DIR)/local-qemu-quake-frame0.ppm
PI4_LOCAL_QEMU_QUAKE_FB_FRAME1 := $(PI4_BUILD_DIR)/local-qemu-quake-frame1.ppm
PI4_LOCAL_QEMU_FINAL_GATES := $(PI4_BUILD_DIR)/local-qemu-final-gates.txt
PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES := $(PI4_BUILD_DIR)/local-qemu-real-assets-final-gates.txt
PI4_FINAL_GATES_GUARD ?= $(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)
PI4_HOST_FINAL_GATES_GUARD ?= $(BUILD_DIR)/pi4-host-final-gates-single-artifact.txt
PI4_LOCAL_QEMU_IMAGE_SHA_BEFORE := $(PI4_BUILD_DIR)/local-qemu-image.sha256.before
PI4_LOCAL_QEMU_IMAGE_SHA_AFTER := $(PI4_BUILD_DIR)/local-qemu-image.sha256.after
PI4_BOOT_ASM_SRCS := boot/pi4/start.S boot/pi4/input.S boot/pi4/storage.S
PI4_USER_ASM_SRCS := user/pi4_crt0.S user/pi4_runtime.S user/pi4_abi_probe.S user/pi4_launcher.S user/pi4_launcher_assets.S
PI4_DOOM_OPTIONAL_ASM_SRCS := $(wildcard doom_port/pi4_engine_start.S)
PI4_DOOM_ASM_SRCS := doom_port/pi4_start.S $(PI4_DOOM_OPTIONAL_ASM_SRCS)
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
PI4_USER_OBJS := $(PI4_USER_CRT0_OBJ) $(PI4_USER_RUNTIME_OBJ) $(PI4_USER_ABI_PROBE_OBJ) $(PI4_USER_LAUNCHER_OBJ) $(PI4_USER_LAUNCHER_ASSETS_OBJ) $(PI4_USER_LAUNCHER_ART_OBJ) $(PI4_DOOM_OBJ) $(PI4_QUAKE_APP_OBJ)
PI4_ABI_PROBE_ELF := $(PI4_BUILD_DIR)/ABIPROBE.ELF
PI4_LAUNCHER_ELF := $(PI4_BUILD_DIR)/INIT.ELF
PI4_DOOM_ELF := $(PI4_BUILD_DIR)/DOOM.APP.ELF
PI4_QUAKE_ELF := $(PI4_BUILD_DIR)/QUAKE.APP.ELF
PI4_LAUNCHER_STATE_MANIFEST_ELF ?= $(PI4_LAUNCHER_ELF)
PI4_APP_DOOM_ELF ?= $(PI4_DOOM_ELF)
PI4_APP_QUAKE_ELF ?= $(PI4_QUAKE_ELF)
APP_INDEX_TXT := user/pi4_apps_index.txt
APP_DOOM_MANIFEST_TXT := user/pi4_app_doom.txt
APP_QUAKE_MANIFEST_TXT := user/pi4_app_quake.txt
PI4_APP_INDEX_TXT := $(APP_INDEX_TXT)
PI4_APP_DOOM_MANIFEST_TXT := $(APP_DOOM_MANIFEST_TXT)
PI4_APP_QUAKE_MANIFEST_TXT := $(APP_QUAKE_MANIFEST_TXT)
PI4_APP_INSTALL_ARGS := --asset /SYSTEM/INIT.ELF=$(PI4_LAUNCHER_ELF) --asset /SYSTEM/ABIPROBE.ELF=$(PI4_ABI_PROBE_ELF) --asset /APPS/INDEX.TXT=$(PI4_APP_INDEX_TXT) --asset /APPS/DOOM/APP.TXT=$(PI4_APP_DOOM_MANIFEST_TXT) --asset /APPS/DOOM/APP.ELF=$(PI4_APP_DOOM_ELF) --asset /APPS/QUAKE/APP.TXT=$(PI4_APP_QUAKE_MANIFEST_TXT) --asset /APPS/QUAKE/APP.ELF=$(PI4_APP_QUAKE_ELF)
PI4_APP_INSTALL_DEPS := $(PI4_APP_INDEX_TXT) $(PI4_APP_DOOM_MANIFEST_TXT) $(PI4_APP_QUAKE_MANIFEST_TXT) $(PI4_APP_DOOM_ELF) $(PI4_APP_QUAKE_ELF)
PI4_ROOT_ELF_ARGS := --root-elf INIT.ELF=$(PI4_LAUNCHER_ELF) --root-elf ABIPROBE.ELF=$(PI4_ABI_PROBE_ELF)
C_RUNTIME_SRC := kernel/c_runtime_probe.asm
USER_PROBE_ASM_SRC := user/probe.asm
USER_LAUNCHER_CRT0_ASM_SRC := user/launcher_crt0.asm
USER_ABI_PROBE_ASM_SRC := user/abi_probe.asm
USER_RUNTIME_ASM_SRC := user/runtime.asm
USER_LAUNCHER_ASM_SRC := user/launcher.asm
USER_LAUNCHER_MAIN_ASM_SRC := user/launcher_main.asm
USER_LIBC_ASM_SRC := user/libc.asm
USER_INCLUDE_DIR := user/include
VIBE_STATUS_CHECK_SRC := tools/vibe_status_check.c
VIBE_STATUS_CHECK := $(BUILD_DIR)/vibe_status_check
AARCH64_FLAT_LINK_SRC := tools/link_aarch64_flat.c
AARCH64_USER_LINK_SRC := tools/link_aarch64_user_elf.c
PI4_STATUS_EVIDENCE_SRC := tools/pi4_status_evidence.c
PI4_QEMU_COMMAND_SRC := tools/pi4_qemu_command.c
DOOM_SRC_DIR := third_party/doom/linuxdoom-1.10
DOOM_PORT_INCLUDE_DIR := doom_port/include
DOOM_PORT_BUILD_DIR := $(BUILD_DIR)/doom
DOOM_ELF := $(BUILD_DIR)/doom.app.elf
DOOM_SYMBOLS := $(BUILD_DIR)/doom.symbols
DOOM_BASE := 0x01000000
DOOM_ORIGINAL_SRCS := $(filter-out $(DOOM_SRC_DIR)/i_%.c,$(wildcard $(DOOM_SRC_DIR)/*.c))
DOOM_ORIGINAL_OBJS := $(DOOM_ORIGINAL_SRCS:$(DOOM_SRC_DIR)/%.c=$(DOOM_PORT_BUILD_DIR)/%.o)
DOOM_PORT_ASM_SRCS := doom_port/input.asm doom_port/music.asm doom_port/platform.asm doom_port/save_debug.asm doom_port/start.asm
DOOM_USER_LIBC_OBJ := $(DOOM_PORT_BUILD_DIR)/user_libc.o
DOOM_PORT_OBJS := $(DOOM_PORT_ASM_SRCS:doom_port/%.asm=$(DOOM_PORT_BUILD_DIR)/port_%.o) $(DOOM_USER_LIBC_OBJ)
FREESTANDING_I386_CFLAGS := -target i386-unknown-elf -ffreestanding -fno-builtin -fno-strict-aliasing -fno-stack-protector -fno-pic -fno-asynchronous-unwind-tables -fno-unwind-tables -m32 -march=i386 -mno-sse -mno-mmx -msoft-float -O2
DOOM_ORIGINAL_CFLAGS := $(FREESTANDING_I386_CFLAGS) -std=gnu89 -DNORMALUNIX -DLINUX -I$(USER_INCLUDE_DIR) -I$(DOOM_PORT_INCLUDE_DIR) -I$(DOOM_SRC_DIR)
DOOM_G_GAME_CFLAGS := -DG_BuildTiccmd=doom_original_G_BuildTiccmd -DG_Ticker=doom_original_G_Ticker
DOOM_P_SAVEG_CFLAGS := -DP_ArchivePlayers=doom_original_P_ArchivePlayers -DP_UnArchivePlayers=doom_original_P_UnArchivePlayers -DP_ArchiveWorld=doom_original_P_ArchiveWorld -DP_UnArchiveWorld=doom_original_P_UnArchiveWorld -DP_ArchiveThinkers=doom_original_P_ArchiveThinkers -DP_UnArchiveThinkers=doom_original_P_UnArchiveThinkers -DP_ArchiveSpecials=doom_original_P_ArchiveSpecials -DP_UnArchiveSpecials=doom_original_P_UnArchiveSpecials
PI4_DOOM_ENGINE_BUILD_DIR := $(PI4_BUILD_DIR)/doom-engine
PI4_DOOM_ENGINE_ELF := $(PI4_BUILD_DIR)/DOOM.ENGINE.APP.ELF
PI4_DOOM_ENGINE_MISSING_SYMBOLS := $(PI4_DOOM_ENGINE_BUILD_DIR)/missing-symbols.txt
PI4_DOOM_ENGINE_LINK_REPORT := $(PI4_DOOM_ENGINE_BUILD_DIR)/link-report.txt
PI4_DOOM_ENGINE_START_OBJ := $(PI4_DOOM_ENGINE_BUILD_DIR)/pi4_engine_start.o
PI4_DOOM_ENGINE_PORT_C_SRCS := doom_port/pi4_engine_platform.c doom_port/pi4_engine_m_misc.c doom_port/pi4_engine_libc.c doom_port/pi4_engine_r_data.c doom_port/pi4_engine_w_wad.c doom_port/pi4_engine_z_zone.c doom_port/pi4_engine_p_setup.c doom_port/pi4_engine_r_things.c doom_port/pi4_engine_r_segs.c
PI4_DOOM_ENGINE_PORT_C_OBJS := $(PI4_DOOM_ENGINE_PORT_C_SRCS:doom_port/%.c=$(PI4_DOOM_ENGINE_BUILD_DIR)/%.o)
PI4_DOOM_ENGINE_ORIGINAL_SRCS := $(filter-out $(DOOM_SRC_DIR)/i_%.c $(DOOM_SRC_DIR)/m_misc.c $(DOOM_SRC_DIR)/r_data.c $(DOOM_SRC_DIR)/w_wad.c $(DOOM_SRC_DIR)/z_zone.c $(DOOM_SRC_DIR)/p_setup.c $(DOOM_SRC_DIR)/r_things.c $(DOOM_SRC_DIR)/r_segs.c,$(wildcard $(DOOM_SRC_DIR)/*.c))
PI4_DOOM_ENGINE_ORIGINAL_OBJS := $(PI4_DOOM_ENGINE_ORIGINAL_SRCS:$(DOOM_SRC_DIR)/%.c=$(PI4_DOOM_ENGINE_BUILD_DIR)/%.o)
PI4_DOOM_ENGINE_OBJS := $(PI4_USER_CRT0_OBJ) $(PI4_USER_RUNTIME_OBJ) $(PI4_DOOM_ENGINE_START_OBJ) $(PI4_DOOM_ENGINE_ORIGINAL_OBJS) $(PI4_DOOM_ENGINE_PORT_C_OBJS)
PI4_AARCH64_ENGINE_CFLAGS := --target=aarch64-none-elf -ffreestanding -fno-builtin -fno-strict-aliasing -fno-stack-protector -fno-pic -fno-asynchronous-unwind-tables -fno-unwind-tables -mstrict-align -fno-vectorize -fno-slp-vectorize
PI4_DOOM_ENGINE_ORIGINAL_CFLAGS := $(PI4_AARCH64_ENGINE_CFLAGS) -O2 -std=gnu89 -DNORMALUNIX -DLINUX -Iuser -Iuser/include -I$(DOOM_PORT_INCLUDE_DIR) -I$(DOOM_SRC_DIR)
PI4_DOOM_ENGINE_PORT_CFLAGS := $(PI4_AARCH64_ENGINE_CFLAGS) -O2 -std=gnu99 -Iuser -Iuser/include -I$(DOOM_PORT_INCLUDE_DIR) -I$(DOOM_SRC_DIR)
QUAKE_SRC_DIR := third_party/quake/WinQuake
QUAKE_PORT_INCLUDE_DIR := quake_port/include
QUAKE_PORT_BUILD_DIR := $(BUILD_DIR)/quake
QUAKE_ELF := $(BUILD_DIR)/quake.app.elf
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
QUAKE_ORIGINAL_CFLAGS := $(QUAKE_FREESTANDING_I386_CFLAGS) -std=gnu89 -fcommon -U__i386__ -Dstricmp=strcasecmp -I$(USER_INCLUDE_DIR) -I$(QUAKE_PORT_INCLUDE_DIR) -I$(DOOM_PORT_INCLUDE_DIR) -I$(QUAKE_SRC_DIR)
QUAKE_PI4_ENGINE_BUILD_DIR := $(PI4_BUILD_DIR)/quake-engine
QUAKE_PI4_ENGINE_ELF := $(PI4_BUILD_DIR)/QUAKE.ENGINE.APP.ELF
QUAKE_PI4_ENGINE_PORT_NAMES := cd input setjmp start sys vid
QUAKE_PI4_ENGINE_PORT_OBJS := $(addprefix $(QUAKE_PI4_ENGINE_BUILD_DIR)/port_,$(addsuffix .o,$(QUAKE_PI4_ENGINE_PORT_NAMES)))
QUAKE_PI4_ENGINE_RUNTIME_OBJS := $(QUAKE_PI4_ENGINE_BUILD_DIR)/port_runtime.o $(QUAKE_PI4_ENGINE_BUILD_DIR)/port_state.o $(QUAKE_PI4_ENGINE_BUILD_DIR)/port_pr_load.o $(QUAKE_PI4_ENGINE_BUILD_DIR)/port_sv_spawn.o $(QUAKE_PI4_ENGINE_BUILD_DIR)/port_render_trace.o $(QUAKE_PI4_ENGINE_BUILD_DIR)/port_d_surf.o
QUAKE_PI4_ENGINE_ORIGINAL_SRC_NAMES := $(filter-out snd_dma snd_mem snd_mix,$(QUAKE_ORIGINAL_SRC_NAMES)) snd_null
QUAKE_PI4_ENGINE_ORIGINAL_OBJS := $(addprefix $(QUAKE_PI4_ENGINE_BUILD_DIR)/,$(addsuffix .o,$(QUAKE_PI4_ENGINE_ORIGINAL_SRC_NAMES)))
QUAKE_PI4_ENGINE_OBJS := $(QUAKE_PI4_ENGINE_PORT_OBJS) $(QUAKE_PI4_ENGINE_RUNTIME_OBJS) $(QUAKE_PI4_ENGINE_ORIGINAL_OBJS)
QUAKE_PI4_ENGINE_MISSING_SYMBOLS := $(QUAKE_PI4_ENGINE_BUILD_DIR)/missing-runtime-symbols.txt
QUAKE_PI4_ENGINE_LINK_REPORT := $(QUAKE_PI4_ENGINE_BUILD_DIR)/link-report.txt
QUAKE_PI4_ENGINE_CFLAGS := $(PI4_AARCH64_ENGINE_CFLAGS) -O2 -std=gnu89 -fcommon -U__i386__ -Dstricmp=strcasecmp -Iuser -I$(USER_INCLUDE_DIR) -I$(QUAKE_PORT_INCLUDE_DIR) -I$(DOOM_PORT_INCLUDE_DIR) -I$(QUAKE_SRC_DIR)
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

PI4_REAL_ASSET_GOALS := pi4-real-assets-require pi4-real-assets-image pi4-real-assets-image-inspect pi4-local-qemu-real-assets-input-smoke pi4-local-qemu-real-assets-final-gates
ifneq ($(filter $(PI4_REAL_ASSET_GOALS),$(MAKECMDGOALS)),)
ifeq ($(strip $(PI4_REAL_DOOM_WAD)),)
$(error PI4 real-assets targets require DOOM_WAD=/absolute/path/to/DOOM1.WAD or PI4_REAL_DOOM_WAD=/absolute/path/to/DOOM1.WAD; use pi4-prepared-real-assets-image or pi4-prepared-real-assets-final-gates to fill REAL_ASSET_CACHE_DIR=$(REAL_ASSET_CACHE_DIR))
endif
ifeq ($(strip $(PI4_REAL_QUAKE_PAK)),)
$(error PI4 real-assets targets require QUAKE_PAK=/absolute/path/to/PAK0.PAK or PI4_REAL_QUAKE_PAK=/absolute/path/to/PAK0.PAK; use pi4-prepared-real-assets-image or pi4-prepared-real-assets-final-gates to fill REAL_ASSET_CACHE_DIR=$(REAL_ASSET_CACHE_DIR))
endif
endif

PI4_IMAGE_INSPECT_REAL_ASSET_ARGS = $(if $(filter 1,$(PI4_REQUIRE_REAL_ASSETS)),--require-real-assets)

STAGE2_MAX_BYTES := 8192
KERNEL_ELF_MAX_BYTES := 163840
USER_PROBE_ELF_MAX_BYTES := 16384
USER_ABI_PROBE_ELF_MAX_BYTES := 32768
INIT_APP_ELF_MAX_BYTES := 262144
PI4_USER_ELF_MAX_BYTES := 262144
PI4_AARCH64_USER_FLAGS := --target=aarch64-none-elf -ffreestanding -nostdlib -Wall -Wextra -Iuser -Iuser/include
PI4_AARCH64_USER_CFLAGS := $(PI4_AARCH64_USER_FLAGS) -O2 -mstrict-align -fno-stack-protector -fno-asynchronous-unwind-tables -fno-unwind-tables -fno-pic -fno-vectorize -fno-slp-vectorize
X86_APP_INSTALL_ARGS := --asset /SYSTEM/INIT.ELF=$(USER_LAUNCHER_ELF) --asset /SYSTEM/ABIPROBE.ELF=$(USER_ABI_PROBE_ELF) --asset /APPS/INDEX.TXT=$(APP_INDEX_TXT) --asset /APPS/DOOM/APP.TXT=$(APP_DOOM_MANIFEST_TXT) --asset /APPS/DOOM/APP.ELF=$(DOOM_ELF) --asset /APPS/QUAKE/APP.TXT=$(APP_QUAKE_MANIFEST_TXT) --asset /APPS/QUAKE/APP.ELF=$(QUAKE_ELF)
X86_APP_INSTALL_DEPS := $(APP_INDEX_TXT) $(APP_DOOM_MANIFEST_TXT) $(APP_QUAKE_MANIFEST_TXT)
X86_CORE_ROOT_ELFS := INIT.ELF ABIPROBE.ELF
X86_REQUIRED_ROOT_ELFS := $(X86_CORE_ROOT_ELFS)
X86_REQUIRED_APP_FILES := /SYSTEM/INIT.ELF /SYSTEM/ABIPROBE.ELF /APPS/INDEX.TXT /APPS/DOOM/APP.TXT /APPS/DOOM/APP.ELF /APPS/QUAKE/APP.TXT /APPS/QUAKE/APP.ELF
IMAGE_INSPECT_REQUIRED_FILE_ARGS := $(foreach root_elf,$(X86_REQUIRED_ROOT_ELFS),--require-file $(root_elf)) $(foreach app_file,$(X86_REQUIRED_APP_FILES),--require-file $(app_file))
IMAGE_EXTRA_ROOT_ELF_ARGS ?=
IMAGE_EXTRA_ROOT_ELF_DEPS ?=
IMAGE_ROOT_ELF_ARGS := --root-elf INIT.ELF=$(USER_LAUNCHER_ELF) --root-elf ABIPROBE.ELF=$(USER_ABI_PROBE_ELF) $(IMAGE_EXTRA_ROOT_ELF_ARGS)

.PHONY: all build-only test assembly-native-check no-python-check third-party-pristine-check doom-compile doom-link quake-compile quake-link x86-image-builder-wiring-check x86-uefi-image-builder-wiring-check x86-pi4-real-assets-isolation-check x86-status-proof-check x86-preservation-host-check prepare-real-assets prepare-real-assets-dry-run play play-image run run-headless smoke quake-status-proof-check playability-host-check image-builder-tool image-builder-inspect uefi-loader-object uefi-loader-pe uefi-dual-image pi4-assembly-source-gate pi4-code-gates pi4-kernel8 pi4-user-elves pi4-doom-app pi4-quake-app pi4-quake-engine-app pi4-engine-apps-linked pi4-launcher-state-manifest-check pi4-image pi4-image-inspect pi4-prepared-real-assets-image pi4-prepared-real-assets-final-gates pi4-final-gates-single-artifact-guard pi4-doom-quake-app-image-inspect pi4-qemu-command pi4-qemu-prep pi4-qemu-run pi4-local-qemu-live pi4-local-qemu-live-smoke pi4-local-qemu-smoke pi4-local-qemu-doom-input-smoke pi4-local-qemu-quake-input-smoke pi4-local-qemu-input-smoke pi4-local-qemu-final-gates pi4-local-qemu-real-assets-input-smoke pi4-local-qemu-real-assets-final-gates pi4-hw-equivalent-qemu-args pi4-hw-equivalent-qemu-command pi4-hw-equivalent-run pi4-hw-equivalent-real-assets-qemu-command pi4-hw-equivalent-real-assets-run pi4-hw-equivalent-real-assets-input-smoke pi4-hw-equivalent-real-assets-final-gates pi4-status-evidence-ok-fixture pi4-status-evidence-check pi4-evidence-summary pi4-host-artifact-policy pi4-hw-equivalent-artifact-policy pi4-host-check pi4-host-proof-json persistence-image-check clean check-tools vm-consent vm-status-proof-check FORCE
.PHONY: pi4-hw-equivalent-final-gates-policy pi4-remote-visible-play-help

all: $(IMAGE)

build-only: $(IMAGE) doom-link quake-link
	@printf "Build-only check OK: %s, %s, %s, %s, and %s are present.\n" "$(IMAGE)" "$(USER_LAUNCHER_ELF)" "$(DOOM_ELF)" "$(QUAKE_ELF)" "$(USER_ABI_PROBE_ELF)"

test: no-python-check third-party-pristine-check x86-preservation-host-check assembly-native-check
	@printf "Assembly-first host checks OK: x86 preservation, guest status validator, and assembly-native guest build audit passed.\n"

no-python-check:
	@set -e; \
	files="$$(find . \( -path './.git' -o -path './third_party' \) -prune -o -type f -name '*.py' -print | LC_ALL=C sort)"; \
	if [ -n "$$files" ]; then \
		printf "Python is not allowed in the vibe-os build/proof path, including untracked or generated files:\n%s\n" "$$files" >&2; \
		exit 1; \
	fi; \
	printf "No Python in the vibe-os build/proof path.\n"

third-party-pristine-check:
	@set -e; \
	if ! git diff --quiet -- third_party; then \
		printf "third_party must stay pristine; unstaged changes found:\n" >&2; \
		git diff --name-only -- third_party >&2; \
		exit 1; \
	fi; \
	if ! git diff --cached --quiet -- third_party; then \
		printf "third_party must stay pristine; staged changes found:\n" >&2; \
		git diff --cached --name-only -- third_party >&2; \
		exit 1; \
	fi; \
	untracked="$$(git ls-files --others --exclude-standard -- third_party | LC_ALL=C sort)"; \
	if [ -n "$$untracked" ]; then \
		printf "third_party must stay pristine; untracked files found:\n%s\n" "$$untracked" >&2; \
		exit 1; \
	fi; \
	printf "third_party pristine check OK: no tracked, staged, or untracked local changes.\n"

assembly-native-check:
	@set -e; \
	recipes="$$( $(MAKE) --no-print-directory -B -n ALLOW_LOCAL_VM=0 DOOM_WAD= build-only )"; \
	for path in \
		kernel/c_runtime_probe.asm \
		user/probe.asm \
		user/launcher_crt0.asm \
		user/launcher_main.asm \
		user/runtime.asm \
		user/abi_probe.asm \
		user/launcher.asm \
		user/libc.asm \
		doom_port/input.asm \
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
		user/libc.c \
		doom_port/input.c \
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
	@printf "Linked freestanding Doom app ELF at %s\n" "$(DOOM_ELF)"

quake-compile: $(QUAKE_ORIGINAL_OBJS)
	@printf "Compiled %s original Quake source files for freestanding i386.\n" "$$(printf '%s\n' $(QUAKE_ORIGINAL_OBJS) | wc -l | tr -d ' ')"

quake-link: $(QUAKE_ELF)
	@printf "Linked freestanding Quake app ELF at %s\n" "$(QUAKE_ELF)"

prepare-real-assets:
	@printf "Preparing public shareware WAD/PAK into external cache: %s\n" "$(REAL_ASSET_CACHE_DIR)"
	@VIBE_ASSET_CACHE_DIR="$(REAL_ASSET_CACHE_DIR)" tools/prepare_game_assets.sh

prepare-real-assets-dry-run:
	@printf "Dry-running public shareware asset preparation; no downloads or files will be written. Cache: %s\n" "$(REAL_ASSET_CACHE_DIR)"
	@VIBE_ASSET_CACHE_DIR="$(REAL_ASSET_CACHE_DIR)" tools/prepare_game_assets.sh --dry-run

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
		echo "Rerun with ALLOW_LOCAL_VM=1 to use run, run-headless, smoke, pi4-qemu-run, pi4-local-qemu-live, pi4-local-qemu-smoke, pi4-local-qemu-real-assets-final-gates, or pi4-prepared-real-assets-final-gates."; \
		exit 1; \
	fi

$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

$(DOOM_PORT_BUILD_DIR):
	@mkdir -p $(DOOM_PORT_BUILD_DIR)

$(QUAKE_PORT_BUILD_DIR):
	@mkdir -p $(QUAKE_PORT_BUILD_DIR)

$(QUAKE_PI4_ENGINE_BUILD_DIR):
	@mkdir -p $(QUAKE_PI4_ENGINE_BUILD_DIR)

$(UEFI_BUILD_DIR):
	@mkdir -p $(UEFI_BUILD_DIR)

$(PI4_BUILD_DIR):
	@mkdir -p $(PI4_BUILD_DIR)

$(PI4_DOOM_ENGINE_BUILD_DIR):
	@mkdir -p $(PI4_DOOM_ENGINE_BUILD_DIR)

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

$(LINK_AARCH64_FLAT): $(AARCH64_FLAT_LINK_SRC) | $(BUILD_DIR)
	$(HOST_CC) $(HOST_CFLAGS) $< -o $@

$(LINK_AARCH64_USER_ELF): $(AARCH64_USER_LINK_SRC) | $(BUILD_DIR)
	$(HOST_CC) $(HOST_CFLAGS) $< -o $@

$(IMAGE_BUILDER): tools/make_wad_image.c | $(BUILD_DIR)
	$(HOST_CC) $(HOST_CFLAGS) $< -o $@

$(PI4_STATUS_EVIDENCE): $(PI4_STATUS_EVIDENCE_SRC) | $(BUILD_DIR)
	$(HOST_CC) $(HOST_CFLAGS) $< -o $@

$(PI4_QEMU_COMMAND): $(PI4_QEMU_COMMAND_SRC) | $(BUILD_DIR)
	@$(HOST_CC) $(HOST_CFLAGS) $< -o $@

$(VIBE_STATUS_CHECK): $(VIBE_STATUS_CHECK_SRC) | $(BUILD_DIR)
	@$(HOST_CC) $(HOST_CFLAGS) $< -o $@

image-builder-tool: $(IMAGE_BUILDER)

image-builder-inspect: $(IMAGE_BUILDER) $(IMAGE)
	$(IMAGE_BUILDER) --inspect "$(IMAGE)" $(IMAGE_INSPECT_REQUIRED_FILE_ARGS) > "$(IMAGE_INSPECT_TXT)"
	@cat "$(IMAGE_INSPECT_TXT)"
	@grep -q "schema=vibe-os-c-image-inspect-v1" "$(IMAGE_INSPECT_TXT)"
	@grep -E -q "root\[[0-9]+\]=DOOM1\.WAD attr=0x20 cluster=[0-9]+ size=[1-9][0-9]*" "$(IMAGE_INSPECT_TXT)"
	@grep -E -q "root\[[0-9]+\]=INIT\.ELF attr=0x20 cluster=[0-9]+ size=[1-9][0-9]*" "$(IMAGE_INSPECT_TXT)"
	@grep -E -q "root\[[0-9]+\]=ABIPROBE\.ELF attr=0x20 cluster=[0-9]+ size=[1-9][0-9]*" "$(IMAGE_INSPECT_TXT)"
	@grep -E -q "root\[[0-9]+\]=KERNEL\.ELF attr=0x20 cluster=[0-9]+ size=[1-9][0-9]*" "$(IMAGE_INSPECT_TXT)"
	@grep -E -q "root\[[0-9]+\]=USERPROB\.ELF attr=0x20 cluster=[0-9]+ size=[1-9][0-9]*" "$(IMAGE_INSPECT_TXT)"
	@for root_elf in $(X86_REQUIRED_ROOT_ELFS); do \
		grep -E -q "required_file=$$root_elf state=present size=[1-9][0-9]* cluster=[0-9]+" "$(IMAGE_INSPECT_TXT)" || { \
			printf "x86 image inspect did not prove required FAT file %s\n" "$$root_elf" >&2; \
			exit 1; \
		}; \
	done; \
	for app_file in $(X86_REQUIRED_APP_FILES); do \
		grep -E -q "required_file=$$app_file state=present size=[1-9][0-9]* cluster=[0-9]+" "$(IMAGE_INSPECT_TXT)" || { \
			printf "x86 image inspect did not prove required app file %s\n" "$$app_file" >&2; \
			exit 1; \
		}; \
	done

x86-image-builder-wiring-check:
	@set -e; \
	args="$(IMAGE_ROOT_ELF_ARGS)"; \
	app_args="$(X86_APP_INSTALL_ARGS)"; \
	for root_elf in $(X86_REQUIRED_ROOT_ELFS); do \
		printf '%s\n' "$$args" | grep -F -q -- "--root-elf $$root_elf=" || { \
			printf "x86 image builder root ELF wiring is missing %s\n" "$$root_elf" >&2; \
			exit 1; \
		}; \
	done; \
	for app_file in $(X86_REQUIRED_APP_FILES); do \
		printf '%s\n' "$$app_args" | grep -F -q -- "--asset $$app_file=" || { \
			printf "x86 image builder app install wiring is missing %s\n" "$$app_file" >&2; \
			exit 1; \
		}; \
	done; \
	printf "x86 image builder wiring OK: BIOS image installs /SYSTEM plus /APPS app files only.\n"

x86-uefi-image-builder-wiring-check: | $(BUILD_DIR)
	@set -e; \
	dryrun="$(BUILD_DIR)/x86-uefi-image-builder-dryrun.txt"; \
	$(MAKE) --no-print-directory -B -n ALLOW_LOCAL_VM=0 DOOM_WAD= uefi-dual-image > "$$dryrun"; \
	for needle in \
		"--asset EFI/BOOT/BOOTX64.EFI=$(UEFI_LOADER_EFI)" \
		"--asset VIBEOS/KERNEL.ELF=$(KERNEL_ELF)" \
		"--root-elf INIT.ELF=$(USER_LAUNCHER_ELF)" \
		"--root-elf ABIPROBE.ELF=$(USER_ABI_PROBE_ELF)" \
		"--asset /SYSTEM/INIT.ELF=$(USER_LAUNCHER_ELF)" \
		"--asset /SYSTEM/ABIPROBE.ELF=$(USER_ABI_PROBE_ELF)" \
		"--asset /APPS/INDEX.TXT=$(APP_INDEX_TXT)" \
		"--asset /APPS/DOOM/APP.TXT=$(APP_DOOM_MANIFEST_TXT)" \
		"--asset /APPS/DOOM/APP.ELF=$(DOOM_ELF)" \
		"--asset /APPS/QUAKE/APP.TXT=$(APP_QUAKE_MANIFEST_TXT)" \
		"--asset /APPS/QUAKE/APP.ELF=$(QUAKE_ELF)"; do \
		grep -F -q -- "$$needle" "$$dryrun" || { \
			printf "x86 UEFI image builder dry run lost %s\n" "$$needle" >&2; \
			exit 1; \
		}; \
		done; \
	printf "x86 UEFI image builder wiring OK: dual image keeps loader, kernel, bootstrap root ELFs, and /APPS install tree.\n"

x86-pi4-real-assets-isolation-check:
	@set -e; \
	x86_args="$(IMAGE_ROOT_ELF_ARGS)"; \
	for forbidden in \
		"$(PI4_BUILD_DIR)" \
		"$(PI4_LAUNCHER_ELF)" \
		"$(PI4_ABI_PROBE_ELF)" \
		"$(PI4_DOOM_ELF)" \
		"$(PI4_QUAKE_ELF)" \
		KERNEL8.IMG \
		CONFIG.TXT; do \
		case "$$x86_args" in \
			*"$$forbidden"*) \
				printf "x86 image builder root ELF args leaked Pi 4 wiring: %s\n" "$$forbidden" >&2; \
				exit 1; \
				;; \
		esac; \
	done; \
	real_assets_block="$$(awk '/^pi4-real-assets-require:/{seen=1} /^pi4-doom-quake-app-image-inspect:/{seen=0} seen {print}' Makefile)"; \
	bad_refs="$$(printf '%s\n' "$$real_assets_block" | grep -E 'IMAGE_ROOT_ELF_ARGS|UEFI_|STAGE1|STAGE2|[$$][(](KERNEL_ELF|USER_PROBE_ELF|USER_LAUNCHER_ELF|USER_ABI_PROBE_ELF|DOOM_ELF|QUAKE_ELF)[)]|DOOM_SRC_DIR|QUAKE_SRC_DIR|third_party' || true)"; \
	if [ -n "$$bad_refs" ]; then \
		printf "Pi 4 real-assets targets must not reference x86 image wiring or third_party sources:\n%s\n" "$$bad_refs" >&2; \
		exit 1; \
	fi; \
	printf "x86/Pi real-assets isolation OK: Pi asset targets stay off x86 image wiring and third_party source paths.\n"

x86-status-proof-check:
	BUILD_DIR="$(abspath $(BUILD_DIR))" HOST_CC="$(HOST_CC)" VIBE_STATUS_CHECK_SCOPE=x86 tools/test_vibe_status_check.sh

x86-preservation-host-check: x86-image-builder-wiring-check x86-uefi-image-builder-wiring-check x86-pi4-real-assets-isolation-check image-builder-inspect uefi-loader-object doom-link quake-link x86-status-proof-check
	@printf "x86 preservation host check OK: BIOS image-builder, UEFI image wiring, UEFI loader object, Doom app, Quake app, and status-proof validators are wired without local VM.\n"

$(UEFI_LOADER_OBJ): boot/uefi/loader.asm | $(UEFI_BUILD_DIR)
	$(NASM) -f win64 $< -o $@

$(UEFI_LOADER_EFI): $(UEFI_LOADER_OBJ) | $(UEFI_BUILD_DIR)
	@command -v $(LLD_LINK) >/dev/null || { echo "missing $(LLD_LINK); install lld or set LLD_LINK=/path/to/lld-link"; exit 1; }
	$(LLD_LINK) /nologo /subsystem:efi_application /entry:efi_main /nodefaultlib /section:.text,ERW /out:$@ $(UEFI_LOADER_OBJ)
	@grep -a -q "VIBEUEFI step=entry" $@
	@grep -a -q "VIBEUEFI step=kernel-handoff" $@

uefi-loader-object: $(UEFI_LOADER_OBJ)
	@grep -a -q "VIBEUEFI step=entry" "$(UEFI_LOADER_OBJ)"
	@grep -a -q "VIBEUEFI step=kernel-handoff" "$(UEFI_LOADER_OBJ)"
	@printf "UEFI loader object proof OK: serial status markers are present.\n"

uefi-loader-pe: $(UEFI_LOADER_EFI)

$(UEFI_DUAL_IMAGE): $(STAGE1_BIN) $(STAGE2_BIN) $(KERNEL_ELF) $(USER_PROBE_ELF) $(USER_LAUNCHER_ELF) $(USER_ABI_PROBE_ELF) $(DOOM_ELF) $(QUAKE_ELF) $(IMAGE_BUILDER) $(UEFI_LOADER_EFI) $(IMAGE_ASSET_DEPS) $(IMAGE_EXTRA_ROOT_ELF_DEPS) $(X86_APP_INSTALL_DEPS) | $(UEFI_BUILD_DIR)
	@if [ -n "$(PRIMARY_ASSET)" ]; then \
		$(IMAGE_BUILDER) --primary-asset-wad "$(PRIMARY_ASSET)" $(IMAGE_SECONDARY_PACKAGE_ARGS) --asset EFI/BOOT/BOOTX64.EFI=$(UEFI_LOADER_EFI) --asset VIBEOS/KERNEL.ELF=$(KERNEL_ELF) $(IMAGE_ROOT_ELF_ARGS) $(X86_APP_INSTALL_ARGS) $@ $(STAGE1_BIN) $(STAGE2_BIN) $(KERNEL_ELF) $(USER_PROBE_ELF); \
	else \
		$(IMAGE_BUILDER) $(IMAGE_SECONDARY_PACKAGE_ARGS) --asset EFI/BOOT/BOOTX64.EFI=$(UEFI_LOADER_EFI) --asset VIBEOS/KERNEL.ELF=$(KERNEL_ELF) $(IMAGE_ROOT_ELF_ARGS) $(X86_APP_INSTALL_ARGS) $@ $(STAGE1_BIN) $(STAGE2_BIN) $(KERNEL_ELF) $(USER_PROBE_ELF); \
	fi
	@printf "Built dual BIOS/UEFI FAT16 image %s\n" "$@"

uefi-dual-image: $(UEFI_DUAL_IMAGE)

pi4-assembly-source-gate:
	@set -e; \
	expected="$$(printf '%s\n' $(PI4_ASM_SRCS) | LC_ALL=C sort)"; \
		actual="$$( { \
			if [ -d boot/pi4 ]; then find boot/pi4 -type f \( -name '*.S' -o -name '*.s' \) -print; fi; \
			if [ -d user ]; then find user -maxdepth 1 -type f \( -name 'pi4_*.S' -o -name 'pi4_*.s' \) -print; fi; \
			if [ -d doom_port ]; then find doom_port -maxdepth 1 -type f \( -name 'pi4_*.S' -o -name 'pi4_*.s' \) -print; fi; \
			if [ -d quake_port ]; then find quake_port -maxdepth 1 -type f \( -name 'pi4_*.S' -o -name 'pi4_*.s' \) -print; fi; \
		} | LC_ALL=C sort )"; \
	if [ "$$actual" != "$$expected" ]; then \
		printf "Pi 4 assembly source list is stale.\nExpected wired sources:\n%s\nActual Pi 4 sources:\n%s\n" "$$expected" "$$actual" >&2; \
		exit 1; \
	fi; \
	printf "Pi 4 assembly source gate OK: all boot/user/Doom/Quake Pi sources are wired.\n"

pi4-code-gates: no-python-check third-party-pristine-check pi4-assembly-source-gate $(PI4_KERNEL_OBJ) $(PI4_KERNEL_OBJS) $(PI4_USER_OBJS) $(PI4_LAUNCHER_ELF) $(PI4_ABI_PROBE_ELF) $(PI4_DOOM_ELF) $(PI4_QUAKE_ELF) pi4-launcher-state-manifest-check
	@printf "Pi 4 code gates OK: compiled all Pi assembly sources and linked INIT.ELF/ABIPROBE.ELF plus Doom/Quake app ELFs.\n"

$(PI4_KERNEL_INPUT_OBJ): boot/pi4/input.S | $(PI4_BUILD_DIR)
	$(AARCH64_CC) --target=aarch64-none-elf -ffreestanding -nostdlib -Wall -Wextra -c $< -o $@

$(PI4_KERNEL_STORAGE_OBJ): boot/pi4/storage.S | $(PI4_BUILD_DIR)
	$(AARCH64_CC) --target=aarch64-none-elf -ffreestanding -nostdlib -Wall -Wextra -c $< -o $@

$(PI4_KERNEL_AGGREGATE_SRC): boot/pi4/start.S boot/pi4/input.S boot/pi4/storage.S | $(PI4_BUILD_DIR)
	@{ \
		printf '.equ PI4_VIBE_DISPLAY_FD, 1\n'; \
		printf '.equ PI4_VIBE_EINVAL, 22\n'; \
		printf '.equ PI4_VIBE_INPUT_DEVICE_KEYBOARD, 1\n'; \
		printf '.equ PI4_VIBE_INPUT_DEVICE_MOUSE, 2\n'; \
		printf '.equ PI4_VIBE_INPUT_CAP_POLL_EVENT, 0x00000004\n'; \
		printf '.equ PI4_VIBE_INPUT_CAP_STATUS, 0x00000008\n'; \
		printf '.equ PI4_VIBE_INPUT_CAP_DEVICE_STATUS, 0x00000010\n'; \
		printf '.equ PI4_VIBE_FB_BACKEND_XRGB8888_LFB, 2\n'; \
		printf '.equ PI4_VIBE_FB_CAP_PRESENT_INDEXED, 0x00000001\n'; \
		printf '.equ PI4_VIBE_FB_CAP_PRESENT_RGB_PALETTE, 0x00000002\n'; \
		printf '.equ PI4_VIBE_FB_CAP_XRGB8888_LFB, 0x00000004\n'; \
		printf '.equ PI4_VIBE_FB_CAP_DIRTY_SOURCE_RECT, 0x00000010\n'; \
		printf '.equ PI4_VIBE_FB_FORMAT_INDEX8_RGB24, 1\n'; \
		printf '.equ PI4_VIBE_FB_RGB24_PALETTE_BYTES, 768\n'; \
		printf '.equ PI4_VIBE_USER_ABI_VERSION, 1\n'; \
		printf '.equ PI4_VIBE_INPUT_EVENT_BYTES, 56\n'; \
		printf '.equ PI4_VIBE_INPUT_STATUS_BYTES, 264\n'; \
		printf '.equ PI4_VIBE_INPUT_DEVICE_STATUS_BYTES, 128\n'; \
		printf '.equ PI4_VIBE_FB_INFO_BYTES, 168\n'; \
		printf '.global msg_status_pi4exec_tuple\n'; \
		printf '.global pi4_status_pi4exec_sysno\n'; \
		printf '.global pi4_status_pi4exec_path\n'; \
		printf '.global pi4_status_pi4exec_argv\n'; \
		printf '.global pi4_status_pi4exec_envp\n'; \
		printf '.global pi4_status_pi4exec_result\n'; \
		printf '.global pi4_status_pi4exec_count\n'; \
		printf '#include "%s"\n' "$(abspath boot/pi4/start.S)"; \
		printf '#include "%s"\n' "$(abspath boot/pi4/input.S)"; \
		printf '#include "%s"\n' "$(abspath boot/pi4/storage.S)"; \
	} > $@

$(PI4_KERNEL_OBJ): $(PI4_KERNEL_AGGREGATE_SRC) $(PI4_KERNEL_OBJS) | $(PI4_BUILD_DIR)
	$(AARCH64_CC) --target=aarch64-none-elf -ffreestanding -nostdlib -Wall -Wextra -DVIBE_PI4_RUNTIME_H -c $(PI4_KERNEL_AGGREGATE_SRC) -o $@

$(PI4_KERNEL8_IMG): $(PI4_KERNEL_OBJ) $(LINK_AARCH64_FLAT) | $(PI4_BUILD_DIR)
	$(LINK_AARCH64_FLAT) -o $@ --base 0x80000 --map $(PI4_KERNEL8_MAP) $(PI4_KERNEL_OBJ)
	@grep -a -q "vibe-os pi4" $@
	@grep -a -q "arch=AARCH64 machine=PI4" $@
	@grep -a -q "pi4el=EL1" $@
	@grep -a -q "pi4vec=OK" $@
	@grep -a -q "pi4svc=OK" $@
	@grep -a -q "pi4sysframe=" $@
	@grep -a -q "pi4dtb=OK" $@
	@grep -a -q "pi4dtbroot=" $@
	@grep -a -q "pi4boarddtb=OK" $@
	@grep -a -q "pi4model=" $@
	@grep -a -q "pi4compat=" $@
	@grep -a -q "pi4soc=WAIT" $@
	@grep -a -q "pi4socdtb=OK" $@
	@grep -a -q "pi4socrange=" $@
	@grep -a -q "pi4socrangelen=" $@
	@grep -a -q "pi4gicdtb=OK" $@
	@grep -a -q "pi4gicdtb=WAIT" $@
	@grep -a -q "pi4gicnode=" $@
	@grep -a -q "pi4giccompat=" $@
	@grep -a -q "pi4gicreg=" $@
	@grep -a -q "pi4gicreglen=" $@
	@grep -a -q "pi4gicmmio=OK" $@
	@grep -a -q "pi4gicmmio=WAIT" $@
	@grep -a -q "pi4gicbase=" $@
	@grep -a -q "pi4giccfg=OK" $@
	@grep -a -q "pi4giccfg=WAIT" $@
	@grep -a -q "pi4gicctl=" $@
	@grep -a -q "pi4giciidr=" $@
	@grep -a -q "pi4irq=WAIT" $@
	@grep -a -q "pi4irq=OK" $@
	@grep -a -q "irqctl=GIC" $@
	@grep -a -q "pi4gic=" $@
	@grep -a -q "clocksrc=ARMTMR" $@
	@grep -a -q "clockhz=" $@
	@grep -a -q "clocktick=" $@
	@grep -a -q "clockirq=" $@
	@grep -a -q "ticks=" $@
	@grep -a -q "pi4timer=WAIT" $@
	@grep -a -q "pi4timer=OK" $@
	@! grep -a -q "hwproof=" $@
	@! grep -a -q "hardware proof" $@
	@grep -a -q "pi4mailbox=WAIT" $@
	@grep -a -q "pi4mailbox=OK" $@
	@grep -a -q "pi4fbmail=" $@
	@grep -a -q "gfx=OK" $@
	@grep -a -q "gfx=WAIT" $@
	@grep -a -q "fb=PI4FB" $@
	@grep -a -q "fb=WAIT" $@
	@grep -a -q "fbgeom=" $@
	@grep -a -q "fbpresent=" $@
	@grep -a -q "pi4fb=OK" $@
	@grep -a -q "pi4fb=WAIT" $@
	@grep -a -q "pi4uabi=WAIT" $@
	@grep -a -q "pi4elf=OK" $@
	@grep -a -q "pi4elfsrc=EMBEDDED" $@
	@grep -a -q "pi4elfprobe=" $@
	@grep -a -q "embedded elf64 el0 probe launched" $@
	@grep -a -q "PI4ELFPROBE" $@
	@grep -a -q "pi4sd=WAIT" $@
	@grep -a -q "pi4fat=WAIT" $@
	@grep -a -q "pi4vfs=WAIT" $@
	@grep -a -q "pi4input=UART-LIVE" $@
	@grep -a -q "pi4usb=WAIT" $@
	@! grep -a -q "pi4sd=OK" $@
	@! grep -a -q "pi4fat=OK" $@
	@! grep -a -q "pi4vfs=OK" $@
	@! grep -a -q "pi4usb=OK" $@
	@grep -q "section=.text.boot" $(PI4_KERNEL8_MAP)
	@grep -q "section=.pi4_user_elf" $(PI4_KERNEL8_MAP)
	@grep -q "section=.bss.stack" $(PI4_KERNEL8_MAP)
	@grep -q "file_end=0x" $(PI4_KERNEL8_MAP)
	@grep -q "bss_after_file=YES" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=__pi4_image_base addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=__pi4_image_end addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=__bss_start addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=__bss_end addr=" $(PI4_KERNEL8_MAP)
	@grep -q "section=.pi4_input_state" $(PI4_KERNEL8_MAP)
	@grep -q "section=.text.pi4_storage" $(PI4_KERNEL8_MAP)
	@grep -q "section=.rodata.pi4_storage" $(PI4_KERNEL8_MAP)
	@grep -q "section=.pi4_storage_status" $(PI4_KERNEL8_MAP)
	@grep -q "section=.bss.pi4_storage" $(PI4_KERNEL8_MAP)
	@! grep -q "section=.bss.pi4_input" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_validate_dtb addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_scan_soc_ranges addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_scan_board_identity addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_scan_gic_dtb addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_prepare_gic_mmio addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_configure_gic addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_run_timer_irq_probe addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_mailbox_call addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_framebuffer_init addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_uart_write_mailbox_fb_tuple addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_uart_write_gic_tuple addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_uart_write_gic_mmio_tuple addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_uart_write_gic_cfg_tuple addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_uart_write_irq_tuple addr=" $(PI4_KERNEL8_MAP)
	@grep -q "section=.pi4_mailbox" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_fb_mailbox_msg addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4socdtb addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4boarddtb addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4mailbox addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4fb addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_gfx addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_fb addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4gicdtb addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4gicmmio addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4giccfg addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4irq addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4timer addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4socrange_bus addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4socrange_periph addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4socrange_span addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4socrange_node addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4socrange_len addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4gic_node addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4gic_depth addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4gic_interrupt addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4giccompat_ptr addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4giccompat_len addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4giccompat_hash addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4gicreg0 addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4gicreg1 addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4gicreg2 addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4gicreg3 addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4gicreg4 addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4gicreg5 addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4gicreg6 addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4gicreg7 addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4gicreg_len addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4gic_dist_base addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4gic_cpu_base addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4gic_dist_len addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4gic_cpu_len addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4gic_dist_ctlr addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4gic_cpu_ctlr addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4gic_cpu_pmr addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4gic_cpu_bpr addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4gic_dist_typer addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4gic_dist_iidr addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4gic_cpu_iidr addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_timer_freq addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_timer_tick addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_timer_irq_id addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_timer_iar_id addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_timer_eoi_id addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_timer_ticks addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_irqframe_elr_el1 addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_irqframe_spsr_el1 addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_irqframe_sp_el0 addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_irqframe_x0 addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_irqframe_x15 addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_irqframe_x30 addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_irq_gic_dist_ctlr addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_irq_gic_cpu_ctlr addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_mbox_base addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_mbox_req addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_mbox_resp addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_mbox_fail addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_fb_bus_base addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_fb_cpu_base addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_fb_size addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_fb_pitch addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_fb_width addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_fb_height addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_fb_depth addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_fb_format addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_fb_write addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_fb_sample addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4model_ptr addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4model_len addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4model_hash addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4compat_ptr addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4compat_len addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_status_pi4compat_hash addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_el1_vectors" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_el1_lower_aarch64_sync_exception" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_el1_lower_aarch64_irq_exception" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_lower_el_irq_record_timer_frame" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_lower_el_irq_restore_eret" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_prepare_embedded_elf_probe addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_embedded_el0_elf addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_embedded_el0_elf_phdr addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_el0_svc_probe addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_uart_input_init addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_uart_input_poll addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_uart_input_pop addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_uart_input_snapshot addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_reset_status addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_read_blocks addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_block_read addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_probe_controller_status addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_boot_media_probe addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_probe_boot_sector_buffers addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_parse_mbr addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_parse_fat_bpb addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_parse_fat_root addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_match_short_name addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_record_file_metadata addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_pi4sd addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_pi4fat addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_pi4vfs addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_mbr addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_bpb addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_fat_type addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_root addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_init_elf addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_app0_elf addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_app1_elf addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_block addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_block_controller addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_block_lba addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_block_count addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_block_buffer addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_block_max_count addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_block_bytes addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_block_result addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_block_command addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_block_transfer_mode addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_block_argument addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_block_copied_bytes addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_block_copied_sectors addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_block_pio_words addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_block_int_status addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_block_error_status addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_block_present_before addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_block_present_after addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_sdctl_legacy_base addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_sdctl_arm_base addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_sdctl_span addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_sdctl_host_version addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_sdctl_caps0 addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_sdctl_caps1 addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_sdctl_present addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_sdctl_host_control addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_sdctl_power_control addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_sdctl_clock_control addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_sdctl_software_reset addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_sdctl_int_status addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_boot_mbr_sector_buffer addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_boot_bpb_sector_buffer addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_boot_parse_mask addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_mbr_signature addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_mbr_part_index addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_mbr_part_boot addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_mbr_part_type addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_mbr_part_lba addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_mbr_part_sectors addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_bpb_signature addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_bpb_partition_lba addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_bpb_bytes_per_sector addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_bpb_sectors_per_cluster addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_bpb_reserved_sectors addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_bpb_fat_count addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_bpb_root_entries addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_bpb_total_sectors addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_bpb_fat_sectors addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_bpb_root_dir_sectors addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_bpb_fat_span_sectors addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_bpb_first_data_rel_lba addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_bpb_cluster_count addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_bpb_fat0_lba addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_bpb_root_dir_lba addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_bpb_data_lba addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_bpb_hidden_sectors addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_bpb_root_cluster addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_root_dir_lba addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_root_dir_sectors addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_root_cluster addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_root_data_lba addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_root_entries_scanned addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_root_buffer_bytes addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_root_found_mask addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_init_elf_entry_index addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_init_elf_attr addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_init_elf_cluster addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_init_elf_size addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_init_elf_plan_lba addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_init_elf_plan_sectors addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_init_elf_plan_bytes addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_init_elf_read_count addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_app0_elf_entry_index addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_app0_elf_attr addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_app0_elf_cluster addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_app0_elf_size addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_app0_elf_plan_lba addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_app0_elf_plan_sectors addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_app0_elf_plan_bytes addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_app0_elf_read_count addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_app1_elf_entry_index addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_app1_elf_attr addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_app1_elf_cluster addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_app1_elf_size addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_app1_elf_plan_lba addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_app1_elf_plan_sectors addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_app1_elf_plan_bytes addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_app1_elf_read_count addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_status_words addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_name_init_elf addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_name_app_elf addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_name_app_txt addr=" $(PI4_KERNEL8_MAP)
	@grep -q "symbol=pi4_storage_block_scratch addr=" $(PI4_KERNEL8_MAP)
	@grep -Eq "\.equ[[:space:]]+PI4_GICD_CTLR,[[:space:]]+0x000" boot/pi4/start.S
	@grep -Eq "\.equ[[:space:]]+PI4_GICD_TYPER,[[:space:]]+0x004" boot/pi4/start.S
	@grep -Eq "\.equ[[:space:]]+PI4_GICD_IIDR,[[:space:]]+0x008" boot/pi4/start.S
	@grep -Eq "\.equ[[:space:]]+PI4_GICC_CTLR,[[:space:]]+0x0000" boot/pi4/start.S
	@grep -Eq "\.equ[[:space:]]+PI4_GICC_PMR,[[:space:]]+0x0004" boot/pi4/start.S
	@grep -Eq "\.equ[[:space:]]+PI4_GICC_BPR,[[:space:]]+0x0008" boot/pi4/start.S
	@grep -Eq "\.equ[[:space:]]+PI4_GICC_IAR,[[:space:]]+0x000c" boot/pi4/start.S
	@grep -Eq "\.equ[[:space:]]+PI4_GICC_EOIR,[[:space:]]+0x0010" boot/pi4/start.S
	@grep -Eq "\.equ[[:space:]]+PI4_GICC_IIDR,[[:space:]]+0x00fc" boot/pi4/start.S
	@grep -Eq "\.equ[[:space:]]+PI4_MAILBOX_BASE,[[:space:]]+PI4_PERIPHERAL_BASE \+ 0x0000b880" boot/pi4/start.S
	@grep -Eq "\.equ[[:space:]]+PI4_MAILBOX_PROPERTY_CHANNEL,[[:space:]]+8" boot/pi4/start.S
	@objdump_tool="$$(command -v llvm-objdump 2>/dev/null || command -v aarch64-none-elf-objdump 2>/dev/null || command -v objdump 2>/dev/null || true)"; \
	if [ -z "$$objdump_tool" ] && command -v xcrun >/dev/null 2>&1; then \
		objdump_tool="$$(xcrun --find llvm-objdump 2>/dev/null || true)"; \
	fi; \
	if [ -z "$$objdump_tool" ]; then \
		printf "missing objdump: install llvm-objdump or aarch64-none-elf-objdump\n" >&2; \
		exit 1; \
	fi; \
	"$$objdump_tool" -dr $(PI4_KERNEL_OBJ) > $(PI4_KERNEL8_DIS); \
	grep -q "<pi4_scan_gic_dtb>:" $(PI4_KERNEL8_DIS); \
	grep -q "<pi4_prepare_gic_mmio>:" $(PI4_KERNEL8_DIS); \
	grep -q "<pi4_configure_gic>:" $(PI4_KERNEL8_DIS); \
	grep -q "<pi4_run_timer_irq_probe>:" $(PI4_KERNEL8_DIS); \
	grep -q "<pi4_mailbox_call>:" $(PI4_KERNEL8_DIS); \
	grep -q "<pi4_framebuffer_init>:" $(PI4_KERNEL8_DIS); \
	grep -q "<pi4_el1_irq_spx_exception>:" $(PI4_KERNEL8_DIS); \
	grep -q "<pi4_el1_lower_aarch64_irq_exception>:" $(PI4_KERNEL8_DIS); \
	grep -q "<pi4_lower_el_irq_record_timer_frame>:" $(PI4_KERNEL8_DIS); \
	grep -q "<pi4_lower_el_irq_restore_eret>:" $(PI4_KERNEL8_DIS); \
	grep -q "tbz.*#0x1f" $(PI4_KERNEL8_DIS); \
	grep -q "tbnz.*#0x1e" $(PI4_KERNEL8_DIS); \
	grep -q "cmp.*#0x20" $(PI4_KERNEL8_DIS); \
	grep -q "lsl.*#32" $(PI4_KERNEL8_DIS); \
	grep -q "mrs.*CNTFRQ_EL0" $(PI4_KERNEL8_DIS); \
	grep -q "msr.*CNTP_TVAL_EL0" $(PI4_KERNEL8_DIS); \
	grep -q "msr.*CNTP_CTL_EL0" $(PI4_KERNEL8_DIS); \
	grep -q "<pi4_uart_write_gic_tuple>:" $(PI4_KERNEL8_DIS); \
	grep -q "<pi4_uart_write_gic_mmio_tuple>:" $(PI4_KERNEL8_DIS); \
	grep -q "<pi4_uart_write_gic_cfg_tuple>:" $(PI4_KERNEL8_DIS); \
	grep -q "<pi4_uart_write_irq_tuple>:" $(PI4_KERNEL8_DIS); \
	grep -q "<pi4_scan_soc_ranges>:" $(PI4_KERNEL8_DIS); \
	grep -q "<pi4_uart_input_init>:" $(PI4_KERNEL8_DIS); \
	grep -q "<pi4_uart_input_poll>:" $(PI4_KERNEL8_DIS); \
	grep -q "<pi4_uart_input_pop>:" $(PI4_KERNEL8_DIS); \
	grep -q "<pi4_uart_input_snapshot>:" $(PI4_KERNEL8_DIS); \
	grep -q "<pi4_storage_reset_status>:" $(PI4_KERNEL8_DIS); \
	grep -q "<pi4_storage_read_blocks>:" $(PI4_KERNEL8_DIS); \
	grep -q "<pi4_storage_probe_controller_status>:" $(PI4_KERNEL8_DIS); \
	grep -q "<pi4_storage_boot_media_probe>:" $(PI4_KERNEL8_DIS); \
	grep -q "<pi4_storage_probe_boot_sector_buffers>:" $(PI4_KERNEL8_DIS); \
	grep -q "<pi4_storage_parse_mbr>:" $(PI4_KERNEL8_DIS); \
	grep -q "<pi4_storage_parse_fat_bpb>:" $(PI4_KERNEL8_DIS); \
	grep -q "<pi4_storage_parse_fat_root>:" $(PI4_KERNEL8_DIS); \
	grep -q "<pi4_storage_match_short_name>:" $(PI4_KERNEL8_DIS); \
	grep -q "<pi4_storage_record_file_metadata>:" $(PI4_KERNEL8_DIS); \
	grep -q "bl.*<pi4_storage_match_short_name>" $(PI4_KERNEL8_DIS); \
	grep -q "mov.*#0x200" $(PI4_KERNEL8_DIS); \
	grep -q "rev.*w" $(PI4_KERNEL8_DIS)

pi4-kernel8: $(PI4_KERNEL8_IMG)
	@printf "Built Raspberry Pi 4 AArch64 kernel image %s\n" "$(PI4_KERNEL8_IMG)"

$(PI4_USER_CRT0_OBJ): user/pi4_crt0.S user/pi4_runtime.h | $(PI4_BUILD_DIR)
	$(AARCH64_CC) $(PI4_AARCH64_USER_FLAGS) -c $< -o $@

$(PI4_USER_RUNTIME_OBJ): user/pi4_runtime.S user/pi4_runtime.h | $(PI4_BUILD_DIR)
	$(AARCH64_CC) $(PI4_AARCH64_USER_FLAGS) -c $< -o $@

$(PI4_USER_ABI_PROBE_OBJ): user/pi4_abi_probe.S user/pi4_runtime.h | $(PI4_BUILD_DIR)
	$(AARCH64_CC) $(PI4_AARCH64_USER_FLAGS) -c $< -o $@

$(PI4_USER_LAUNCHER_OBJ): user/pi4_launcher.S user/pi4_runtime.h | $(PI4_BUILD_DIR)
	$(AARCH64_CC) $(PI4_AARCH64_USER_FLAGS) -c $< -o $@

$(PI4_USER_LAUNCHER_ASSETS_OBJ): user/pi4_launcher_assets.S | $(PI4_BUILD_DIR)
	$(AARCH64_CC) $(PI4_AARCH64_USER_FLAGS) -c $< -o $@

$(PI4_USER_LAUNCHER_ART_OBJ): user/pi4_launcher_art.c user/pi4_runtime.h Makefile | $(PI4_BUILD_DIR)
	$(AARCH64_CC) $(PI4_AARCH64_USER_CFLAGS) -c $< -o $@

$(PI4_DOOM_OBJ): doom_port/pi4_start.S user/pi4_runtime.h | $(PI4_BUILD_DIR)
	$(AARCH64_CC) $(PI4_AARCH64_USER_FLAGS) -c $< -o $@

$(PI4_QUAKE_APP_OBJ): quake_port/pi4_app.S user/pi4_runtime.h | $(PI4_BUILD_DIR)
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

pi4-quake-app: $(PI4_QUAKE_ELF)
	@printf "Built Raspberry Pi 4 AArch64 Quake app %s; launch and hardware proof remain unclaimed.\n" "$(PI4_QUAKE_ELF)"

$(PI4_DOOM_ENGINE_BUILD_DIR)/%.o: $(DOOM_SRC_DIR)/%.c Makefile | $(PI4_DOOM_ENGINE_BUILD_DIR)
	$(AARCH64_CC) $(PI4_DOOM_ENGINE_ORIGINAL_CFLAGS) -c $< -o $@

$(PI4_DOOM_ENGINE_BUILD_DIR)/pi4_engine_start.o: doom_port/pi4_engine_start.S user/pi4_runtime.h Makefile | $(PI4_DOOM_ENGINE_BUILD_DIR)
	$(AARCH64_CC) $(PI4_AARCH64_USER_FLAGS) -c $< -o $@

$(PI4_DOOM_ENGINE_BUILD_DIR)/pi4_engine_%.o: doom_port/pi4_engine_%.c user/pi4_runtime.h Makefile | $(PI4_DOOM_ENGINE_BUILD_DIR)
	$(AARCH64_CC) $(PI4_DOOM_ENGINE_PORT_CFLAGS) -c $< -o $@

$(PI4_DOOM_ENGINE_MISSING_SYMBOLS): $(PI4_DOOM_ENGINE_OBJS) | $(PI4_DOOM_ENGINE_BUILD_DIR)
	@set -e; \
	undef="$(PI4_DOOM_ENGINE_BUILD_DIR)/undefined.tmp"; \
	def="$(PI4_DOOM_ENGINE_BUILD_DIR)/defined.tmp"; \
	$(AARCH64_NM) -P $(PI4_DOOM_ENGINE_OBJS) | awk '$$2 == "U" {print $$1}' | LC_ALL=C sort -u > "$$undef"; \
	$(AARCH64_NM) -P $(PI4_DOOM_ENGINE_OBJS) | awk '$$2 != "U" && $$2 != "" {print $$1}' | LC_ALL=C sort -u > "$$def"; \
	comm -23 "$$undef" "$$def" > "$@"; \
	rm -f "$$undef" "$$def"

$(PI4_DOOM_ENGINE_LINK_REPORT): $(PI4_DOOM_ENGINE_MISSING_SYMBOLS) $(LINK_AARCH64_USER_ELF) $(PI4_DOOM_ENGINE_OBJS) | $(PI4_DOOM_ENGINE_BUILD_DIR)
	@set -e; \
	{ \
		printf "schema=vibe-os-pi4-doom-engine-bridge-report-v1\n"; \
		printf "original_c_objects=%s\n" "$$(printf '%s\n' $(PI4_DOOM_ENGINE_ORIGINAL_OBJS) | wc -l | tr -d ' ')"; \
		printf "port_objects=%s\n" "$$(printf '%s\n' $(PI4_DOOM_ENGINE_PORT_C_OBJS) $(PI4_DOOM_ENGINE_START_OBJ) | wc -l | tr -d ' ')"; \
		printf "missing_symbols_file=%s\n" "$(PI4_DOOM_ENGINE_MISSING_SYMBOLS)"; \
		missing_count="$$(wc -l < "$(PI4_DOOM_ENGINE_MISSING_SYMBOLS)" | tr -d ' ')"; \
		printf "missing_symbol_count=%s\n" "$$missing_count"; \
		if [ "$$missing_count" != "0" ]; then \
			printf "status=missing-symbols\n"; \
			printf "smallest_next_runtime_abi_gap=resolve the symbols listed below before attempting a Pi user ELF link\n"; \
			sed 's/^/missing_symbol=/' "$(PI4_DOOM_ENGINE_MISSING_SYMBOLS)"; \
		else \
			if $(LINK_AARCH64_USER_ELF) -o "$(PI4_DOOM_ENGINE_ELF)" $(PI4_DOOM_ENGINE_OBJS) > "$(PI4_DOOM_ENGINE_BUILD_DIR)/linker.stdout" 2> "$(PI4_DOOM_ENGINE_BUILD_DIR)/linker.stderr"; then \
				printf "status=linked\n"; \
				printf "app=%s\n" "$(PI4_DOOM_ENGINE_ELF)"; \
				printf "app_bytes=%s\n" "$$(wc -c < "$(PI4_DOOM_ENGINE_ELF)" | tr -d ' ')"; \
			printf "smallest_next_runtime_abi_gap=package PI4_APP_DOOM_ELF=%s and prove VFS WAD reads on Pi runtime\n" "$(PI4_DOOM_ENGINE_ELF)"; \
			else \
				printf "status=linker-failed\n"; \
				printf "linker_stderr=%s\n" "$(PI4_DOOM_ENGINE_BUILD_DIR)/linker.stderr"; \
				printf "smallest_next_runtime_abi_gap=extend link_aarch64_user_elf for the first unsupported AArch64 relocation or section reported by the linker\n"; \
				sed 's/^/linker_error=/' "$(PI4_DOOM_ENGINE_BUILD_DIR)/linker.stderr"; \
			fi; \
		fi; \
	} > "$@"

pi4-doom-app: $(PI4_DOOM_ENGINE_LINK_REPORT)
	@cat "$(PI4_DOOM_ENGINE_LINK_REPORT)"

$(QUAKE_PI4_ENGINE_BUILD_DIR)/%.o: $(QUAKE_SRC_DIR)/%.c Makefile | $(QUAKE_PI4_ENGINE_BUILD_DIR)
	$(AARCH64_CC) $(QUAKE_PI4_ENGINE_CFLAGS) -c $< -o $@

$(QUAKE_PI4_ENGINE_BUILD_DIR)/common.o: $(QUAKE_SRC_DIR)/common.c Makefile | $(QUAKE_PI4_ENGINE_BUILD_DIR)
	$(AARCH64_CC) $(QUAKE_PI4_ENGINE_CFLAGS) -DSys_Printf=pi4_quake_common_sys_printf -c $< -o $@

$(QUAKE_PI4_ENGINE_BUILD_DIR)/sv_main.o: $(QUAKE_SRC_DIR)/sv_main.c Makefile | $(QUAKE_PI4_ENGINE_BUILD_DIR)
	$(AARCH64_CC) $(QUAKE_PI4_ENGINE_CFLAGS) -DSV_SpawnServer=pi4_quake_original_SV_SpawnServer -c $< -o $@

$(QUAKE_PI4_ENGINE_BUILD_DIR)/pr_edict.o: $(QUAKE_SRC_DIR)/pr_edict.c Makefile | $(QUAKE_PI4_ENGINE_BUILD_DIR)
	$(AARCH64_CC) $(QUAKE_PI4_ENGINE_CFLAGS) -DPR_LoadProgs=pi4_quake_original_PR_LoadProgs -c $< -o $@

$(QUAKE_PI4_ENGINE_BUILD_DIR)/view.o: $(QUAKE_SRC_DIR)/view.c Makefile | $(QUAKE_PI4_ENGINE_BUILD_DIR)
	$(AARCH64_CC) $(QUAKE_PI4_ENGINE_CFLAGS) -DV_RenderView=pi4_quake_original_V_RenderView -c $< -o $@

$(QUAKE_PI4_ENGINE_BUILD_DIR)/r_main.o: $(QUAKE_SRC_DIR)/r_main.c Makefile | $(QUAKE_PI4_ENGINE_BUILD_DIR)
	$(AARCH64_CC) $(QUAKE_PI4_ENGINE_CFLAGS) -DR_RenderView=pi4_quake_original_R_RenderView -DR_EdgeDrawing=pi4_quake_original_R_EdgeDrawing -c $< -o $@

$(QUAKE_PI4_ENGINE_BUILD_DIR)/r_edge.o: $(QUAKE_SRC_DIR)/r_edge.c Makefile | $(QUAKE_PI4_ENGINE_BUILD_DIR)
	$(AARCH64_CC) $(QUAKE_PI4_ENGINE_CFLAGS) -DR_ScanEdges=pi4_quake_original_R_ScanEdges -c $< -o $@

$(QUAKE_PI4_ENGINE_BUILD_DIR)/d_surf.o: $(QUAKE_SRC_DIR)/d_surf.c Makefile | $(QUAKE_PI4_ENGINE_BUILD_DIR)
	$(AARCH64_CC) $(QUAKE_PI4_ENGINE_CFLAGS) -DD_SCAlloc=pi4_quake_original_D_SCAlloc -DD_CacheSurface=pi4_quake_original_D_CacheSurface -c $< -o $@

$(QUAKE_PI4_ENGINE_BUILD_DIR)/screen.o: $(QUAKE_SRC_DIR)/screen.c Makefile | $(QUAKE_PI4_ENGINE_BUILD_DIR)
	$(AARCH64_CC) $(QUAKE_PI4_ENGINE_CFLAGS) -DSCR_UpdateScreen=pi4_quake_original_SCR_UpdateScreen -c $< -o $@

$(QUAKE_PI4_ENGINE_BUILD_DIR)/port_%.o: quake_port/pi4_engine/%.S user/pi4_runtime.h Makefile | $(QUAKE_PI4_ENGINE_BUILD_DIR)
	$(AARCH64_CC) $(PI4_AARCH64_USER_FLAGS) -c $< -o $@

$(QUAKE_PI4_ENGINE_BUILD_DIR)/port_runtime.o: quake_port/pi4_engine/runtime.c user/pi4_runtime.h Makefile | $(QUAKE_PI4_ENGINE_BUILD_DIR)
	$(AARCH64_CC) $(QUAKE_PI4_ENGINE_CFLAGS) -c $< -o $@

$(QUAKE_PI4_ENGINE_BUILD_DIR)/port_state.o: quake_port/pi4_engine/state.c Makefile | $(QUAKE_PI4_ENGINE_BUILD_DIR)
	$(AARCH64_CC) $(QUAKE_PI4_ENGINE_CFLAGS) -c $< -o $@

$(QUAKE_PI4_ENGINE_BUILD_DIR)/port_pr_load.o: quake_port/pi4_engine/pr_load.c Makefile | $(QUAKE_PI4_ENGINE_BUILD_DIR)
	$(AARCH64_CC) $(QUAKE_PI4_ENGINE_CFLAGS) -c $< -o $@

$(QUAKE_PI4_ENGINE_BUILD_DIR)/port_sv_spawn.o: quake_port/pi4_engine/sv_spawn.c Makefile | $(QUAKE_PI4_ENGINE_BUILD_DIR)
	$(AARCH64_CC) $(QUAKE_PI4_ENGINE_CFLAGS) -c $< -o $@

$(QUAKE_PI4_ENGINE_BUILD_DIR)/port_render_trace.o: quake_port/pi4_engine/render_trace.c Makefile | $(QUAKE_PI4_ENGINE_BUILD_DIR)
	$(AARCH64_CC) $(QUAKE_PI4_ENGINE_CFLAGS) -c $< -o $@

$(QUAKE_PI4_ENGINE_BUILD_DIR)/port_d_surf.o: quake_port/pi4_engine/d_surf.c Makefile | $(QUAKE_PI4_ENGINE_BUILD_DIR)
	$(AARCH64_CC) $(QUAKE_PI4_ENGINE_CFLAGS) -c $< -o $@

$(QUAKE_PI4_ENGINE_MISSING_SYMBOLS): $(PI4_USER_CRT0_OBJ) $(PI4_USER_RUNTIME_OBJ) $(QUAKE_PI4_ENGINE_OBJS) | $(QUAKE_PI4_ENGINE_BUILD_DIR)
	@set -e; \
	undef="$(QUAKE_PI4_ENGINE_BUILD_DIR)/undefined.tmp"; \
	def="$(QUAKE_PI4_ENGINE_BUILD_DIR)/defined.tmp"; \
	$(AARCH64_NM) -P $(PI4_USER_CRT0_OBJ) $(PI4_USER_RUNTIME_OBJ) $(QUAKE_PI4_ENGINE_OBJS) | awk '$$2 == "U" {print $$1}' | LC_ALL=C sort -u > "$$undef"; \
	$(AARCH64_NM) -P $(PI4_USER_CRT0_OBJ) $(PI4_USER_RUNTIME_OBJ) $(QUAKE_PI4_ENGINE_OBJS) | awk '$$2 != "U" && $$2 != "" {print $$1}' | LC_ALL=C sort -u > "$$def"; \
	comm -23 "$$undef" "$$def" > "$@"; \
	rm -f "$$undef" "$$def"

$(QUAKE_PI4_ENGINE_LINK_REPORT): $(QUAKE_PI4_ENGINE_MISSING_SYMBOLS) $(LINK_AARCH64_USER_ELF) $(PI4_USER_CRT0_OBJ) $(PI4_USER_RUNTIME_OBJ) $(QUAKE_PI4_ENGINE_OBJS) | $(QUAKE_PI4_ENGINE_BUILD_DIR)
	@set -e; \
	{ \
		printf "schema=vibe-os-pi4-quake-engine-bridge-report-v1\n"; \
		printf "original_c_objects=%s\n" "$$(printf '%s\n' $(QUAKE_PI4_ENGINE_ORIGINAL_OBJS) | wc -l | tr -d ' ')"; \
		printf "port_objects=%s\n" "$$(printf '%s\n' $(QUAKE_PI4_ENGINE_PORT_OBJS) | wc -l | tr -d ' ')"; \
		printf "missing_symbols_file=%s\n" "$(QUAKE_PI4_ENGINE_MISSING_SYMBOLS)"; \
		missing_count="$$(wc -l < "$(QUAKE_PI4_ENGINE_MISSING_SYMBOLS)" | tr -d ' ')"; \
		printf "missing_symbol_count=%s\n" "$$missing_count"; \
		if [ "$$missing_count" != "0" ]; then \
			printf "status=missing-symbols\n"; \
			printf "smallest_next_runtime_abi_gap=provide the missing AArch64 libc/math/stdio symbols and real Pi file-size/read semantics before attempting a Quake app ELF link\n"; \
			sed 's/^/missing_symbol=/' "$(QUAKE_PI4_ENGINE_MISSING_SYMBOLS)"; \
		else \
			if $(LINK_AARCH64_USER_ELF) -o "$(QUAKE_PI4_ENGINE_ELF)" $(PI4_USER_CRT0_OBJ) $(PI4_USER_RUNTIME_OBJ) $(QUAKE_PI4_ENGINE_OBJS) > "$(QUAKE_PI4_ENGINE_BUILD_DIR)/linker.stdout" 2> "$(QUAKE_PI4_ENGINE_BUILD_DIR)/linker.stderr"; then \
				printf "status=linked\n"; \
				printf "app=%s\n" "$(QUAKE_PI4_ENGINE_ELF)"; \
				printf "app_bytes=%s\n" "$$(wc -c < "$(QUAKE_PI4_ENGINE_ELF)" | tr -d ' ')"; \
				printf "smallest_next_runtime_abi_gap=package PI4_APP_QUAKE_ELF=%s and prove VFS PAK reads on Pi runtime\n" "$(QUAKE_PI4_ENGINE_ELF)"; \
			else \
				printf "status=linker-failed\n"; \
				printf "linker_stderr=%s\n" "$(QUAKE_PI4_ENGINE_BUILD_DIR)/linker.stderr"; \
				printf "smallest_next_runtime_abi_gap=extend link_aarch64_user_elf for the first unsupported AArch64 relocation or section reported by the linker\n"; \
				sed 's/^/linker_error=/' "$(QUAKE_PI4_ENGINE_BUILD_DIR)/linker.stderr"; \
			fi; \
		fi; \
	} > "$@"

pi4-quake-engine-app: $(QUAKE_PI4_ENGINE_LINK_REPORT)
	@cat "$(QUAKE_PI4_ENGINE_LINK_REPORT)"

pi4-engine-apps-linked: pi4-doom-app pi4-quake-engine-app
	@set -e; \
	grep -q '^status=linked$$' "$(PI4_DOOM_ENGINE_LINK_REPORT)" || { echo "Pi 4 Doom engine app is not linked; refusing to package a non-playable live image." >&2; exit 1; }; \
	test -s "$(PI4_DOOM_ENGINE_ELF)" || { echo "missing linked Pi 4 Doom engine app: $(PI4_DOOM_ENGINE_ELF)" >&2; exit 1; }; \
	grep -q '^status=linked$$' "$(QUAKE_PI4_ENGINE_LINK_REPORT)" || { echo "Pi 4 Quake engine app is not linked; refusing to package a non-playable live image." >&2; exit 1; }; \
	test -s "$(QUAKE_PI4_ENGINE_ELF)" || { echo "missing linked Pi 4 Quake engine app: $(QUAKE_PI4_ENGINE_ELF)" >&2; exit 1; }; \
	printf "Pi 4 engine app_exec ELFs linked for live image: %s -> /APPS/DOOM/APP.ELF, %s -> /APPS/QUAKE/APP.ELF.\n" "$(PI4_DOOM_ENGINE_ELF)" "$(QUAKE_PI4_ENGINE_ELF)"

pi4-launcher-state-manifest-check: $(PI4_LAUNCHER_STATE_MANIFEST_ELF)
	@set -e; \
	manifest="$$(LC_ALL=C strings "$(PI4_LAUNCHER_STATE_MANIFEST_ELF)")"; \
	require_line() { \
		line="$$1"; \
		printf '%s\n' "$$manifest" | grep -F -x -q "$$line" || { \
			printf "Pi 4 launcher state manifest missing line: %s\n" "$$line" >&2; \
			exit 1; \
		}; \
	}; \
	for line in \
		"schema=vibe-os-pi4-launcher-apps-v1" \
		"app_model=manifest-vfs-exec" \
		"app_index_schema=vibe-os-app-index-v1" \
		"app_visible_capacity=2" \
		"app_discovery_source=/APPS/INDEX.TXT" \
		"app_discovery_runtime=read-app-count-and-indexed-manifest-keys" \
		"app_metadata_runtime=manifest-name-exec-asset-icon" \
		"launcher_state_schema=vibe-os-pi4-launcher-state-v2" \
		"launcher_state_magic=PI4LAUNC" \
		"launcher_state_bytes=392" \
		"launcher_state.offset.selected_index=64" \
		"launcher_state.offset.selected_path=88" \
		"launcher_state.offset.present_count=104" \
		"launcher_state.offset.input_action=288" \
		"launcher_state.offset.move_count=304" \
		"launcher_state.offset.record_action_count=312" \
		"launcher_state.offset.present_status=320" \
		"launcher_state.offset.exec_request_compat=352" \
		"launcher_state.offset.exec_request_path=360" \
		"launcher_state.offset.exec_attempt_state=376" \
		"launcher_state.offset.exec_request_count=384" \
		"app_launch_claim=generic-path-exec-syscall"; do \
		require_line "$$line"; \
	done; \
	claim_count="$$(printf '%s\n' "$$manifest" | grep -E -c '^app_launch_claim=' || true)"; \
	if [ "$$claim_count" != "1" ]; then \
		printf "Pi 4 launcher state manifest must contain exactly one app_launch_claim= line, got %s\n" "$$claim_count" >&2; \
		exit 1; \
	fi; \
	if printf '%s\n' "$$manifest" | grep -E -x 'app\.[01]\.state=absent' >/dev/null; then \
		printf "Pi 4 launcher manifest must show desktop apps as present for the playable picker.\n" >&2; \
		exit 1; \
	fi; \
	if printf '%s\n' "$$manifest" | grep -E -x 'app_launch_claim=none' >/dev/null; then \
		printf "Pi 4 launcher manifest must expose the exec syscall launch path used by the desktop picker.\n" >&2; \
		exit 1; \
	fi; \
	printf "Pi 4 launcher state manifest OK: %s carries desktop app launch metadata.\n" "$(PI4_LAUNCHER_STATE_MANIFEST_ELF)"

pi4-user-elves: $(PI4_LAUNCHER_ELF) $(PI4_ABI_PROBE_ELF) $(PI4_DOOM_ELF) $(PI4_QUAKE_ELF) pi4-launcher-state-manifest-check
	@printf "Built Raspberry Pi 4 AArch64 user ELFs %s, %s, %s, and %s\n" "$(PI4_LAUNCHER_ELF)" "$(PI4_ABI_PROBE_ELF)" "$(PI4_DOOM_ELF)" "$(PI4_QUAKE_ELF)"

$(PI4_IMAGE): $(PI4_KERNEL8_IMG) $(PI4_CONFIG_TXT) $(PI4_LAUNCHER_ELF) $(PI4_ABI_PROBE_ELF) $(IMAGE_BUILDER) $(IMAGE_ASSET_DEPS) $(PI4_APP_INSTALL_DEPS) FORCE | $(PI4_BUILD_DIR)
	@if [ -n "$(PRIMARY_ASSET)" ]; then \
		$(IMAGE_BUILDER) --proof-manifest --primary-asset-wad "$(PRIMARY_ASSET)" $(IMAGE_SECONDARY_PACKAGE_ARGS) --root-file KERNEL8.IMG=$(PI4_KERNEL8_IMG) --root-file CONFIG.TXT=$(PI4_CONFIG_TXT) $(PI4_ROOT_ELF_ARGS) $(PI4_APP_INSTALL_ARGS) $@; \
	else \
		$(IMAGE_BUILDER) --proof-manifest $(IMAGE_SECONDARY_PACKAGE_ARGS) --root-file KERNEL8.IMG=$(PI4_KERNEL8_IMG) --root-file CONFIG.TXT=$(PI4_CONFIG_TXT) $(PI4_ROOT_ELF_ARGS) $(PI4_APP_INSTALL_ARGS) $@; \
	fi
	@printf "Built Raspberry Pi 4 FAT16 image %s with /SYSTEM plus /APPS app_exec paths only.\n" "$@"

pi4-image: $(PI4_IMAGE)

.PHONY: pi4-real-assets-require pi4-real-assets-image pi4-real-assets-image-inspect

pi4-real-assets-require:
	@set -e; \
	asset_paths="$$(DOOM_WAD="$(PI4_REAL_DOOM_WAD)" QUAKE_PAK="$(PI4_REAL_QUAKE_PAK)" tools/prepare_game_assets.sh --format paths)"; \
	doom_abs="$$(printf "%s\n" "$$asset_paths" | sed -n '1p')"; \
	quake_abs="$$(printf "%s\n" "$$asset_paths" | sed -n '2p')"; \
	test -n "$$doom_abs" || { echo "PI4 real-assets helper did not return DOOM_WAD" >&2; exit 1; }; \
	test -n "$$quake_abs" || { echo "PI4 real-assets helper did not return QUAKE_PAK" >&2; exit 1; }; \
	printf "Pi 4 real-assets inputs OK: DOOM_WAD=%s QUAKE_PAK=%s\n" "$$doom_abs" "$$quake_abs"

pi4-real-assets-image: pi4-real-assets-require
	$(MAKE) --no-print-directory DOOM_WAD="$(PI4_REAL_DOOM_WAD)" QUAKE_PAK="$(PI4_REAL_QUAKE_PAK)" PRIMARY_ASSET="$(PI4_REAL_DOOM_WAD)" SECONDARY_PACKAGE="$(PI4_REAL_QUAKE_PAK)" PI4_REQUIRE_REAL_ASSETS=1 pi4-image-inspect
	@printf "Pi 4 real-assets image ready: %s installs /SYSTEM/INIT.ELF plus /APPS manifests/APP.ELF files, with external DOOM1.WAD and /ID1/PAK0.PAK inputs.\n" "$(PI4_IMAGE)"

pi4-real-assets-image-inspect: pi4-real-assets-image

pi4-prepared-real-assets-image: tools/prepare_game_assets.sh pi4-engine-apps-linked
	@set -e; \
	sha256_file() { \
		if command -v sha256sum >/dev/null 2>&1; then \
			sha256sum "$$1" | awk '{ print $$1 }'; \
		else \
			shasum -a 256 "$$1" | awk '{ print $$1 }'; \
		fi; \
	}; \
	sha1_file() { \
		if command -v sha1sum >/dev/null 2>&1; then \
			sha1sum "$$1" | awk '{ print $$1 }'; \
		else \
			shasum -a 1 "$$1" | awk '{ print $$1 }'; \
		fi; \
	}; \
	file_size() { wc -c < "$$1" | tr -d ' '; }; \
	manifest_size_for() { \
		label="$$1"; \
		pattern="$$2"; \
		line="$$(grep -m 1 -F "$$pattern" "$(PI4_REAL_ASSET_IMAGE_INSPECT_TXT)")" || { echo "prepared Pi 4 image inspect is missing $$label: $$pattern" >&2; exit 1; }; \
		size="$$(printf "%s\n" "$$line" | sed -n 's/.* size=\([0-9][0-9]*\).*/\1/p')"; \
		test -n "$$size" || { echo "prepared Pi 4 image inspect line lacks size for $$label: $$line" >&2; exit 1; }; \
		printf "%s\n" "$$size"; \
	}; \
	require_manifest_size() { \
		label="$$1"; \
		pattern="$$2"; \
		path="$$3"; \
		manifest_size="$$(manifest_size_for "$$label" "$$pattern")"; \
		actual_size="$$(file_size "$$path")"; \
		if [ "$$manifest_size" != "$$actual_size" ]; then \
			echo "prepared Pi 4 exact handoff drift: $$label image manifest size $$manifest_size does not match $$path size $$actual_size" >&2; \
			exit 1; \
		fi; \
	}; \
	abs_path() { \
		path="$$1"; \
		case "$$path" in /*) ;; *) path="$$repo_root/$$path" ;; esac; \
		dir="$$(dirname "$$path")"; \
		base="$$(basename "$$path")"; \
		if [ -d "$$dir" ]; then dir="$$(cd "$$dir" && pwd -P)"; fi; \
		printf "%s/%s\n" "$$dir" "$$base"; \
	}; \
	asset_repo_state() { \
		path="$$1"; \
		case "$$path" in /*) abs="$$path" ;; *) abs="$$(abs_path "$$path")" ;; esac; \
		case "$$abs" in \
			"$$repo_root"| "$$repo_root"/*) \
				echo "repo-local game asset is not allowed in the Pi play handoff: $$abs" >&2; \
				exit 1; \
				;; \
			*) \
				printf "outside-repo"; \
				;; \
		esac; \
	}; \
	require_build_artifact_path() { \
		path="$$1"; \
		abs="$$(abs_path "$$path")"; \
		case "$$abs" in "$$repo_root"/build/*) ;; \
			*) echo "generated Pi 4 handoff artifact must stay under build/: $$path" >&2; exit 1 ;; \
		esac; \
	}; \
	repo_root="$$(pwd -P)"; \
	grep -E -q '^[[:space:]]*build/[[:space:]]*$$' .gitignore || { echo "generated Pi 4 handoff artifacts require build/ in .gitignore" >&2; exit 1; }; \
	for generated_path in "$(PI4_KERNEL8_IMG)" "$(PI4_DOOM_ENGINE_ELF)" "$(QUAKE_PI4_ENGINE_ELF)" "$(PI4_REAL_ASSET_IMAGE)" "$(PI4_REAL_ASSET_IMAGE_INSPECT_TXT)" "$(PI4_REAL_ASSET_HANDOFF)"; do \
		require_build_artifact_path "$$generated_path"; \
	done; \
	rm -f "$(PI4_REAL_ASSET_IMAGE)" "$(PI4_REAL_ASSET_IMAGE_INSPECT_TXT)" "$(PI4_REAL_ASSET_HANDOFF)"; \
	printf "Preparing Pi 4 real WAD/PAK inputs with external cache: %s\n" "$(REAL_ASSET_CACHE_DIR)" >&2; \
	asset_paths="$$(VIBE_ASSET_CACHE_DIR="$(REAL_ASSET_CACHE_DIR)" tools/prepare_game_assets.sh --format paths)"; \
	doom_wad="$$(printf "%s\n" "$$asset_paths" | sed -n '1p')"; \
	quake_pak="$$(printf "%s\n" "$$asset_paths" | sed -n '2p')"; \
	test -n "$$doom_wad" || { echo "prepare helper did not return DOOM_WAD" >&2; exit 1; }; \
	test -n "$$quake_pak" || { echo "prepare helper did not return QUAKE_PAK" >&2; exit 1; }; \
	printf "Packaging exact Pi 4 image from DOOM_WAD=%s and QUAKE_PAK=%s\n" "$$doom_wad" "$$quake_pak" >&2; \
	if ! $(REAL_ASSET_SUBBUILD) --no-print-directory DOOM_WAD="$$doom_wad" QUAKE_PAK="$$quake_pak" PI4_APP_DOOM_ELF="$(PI4_DOOM_ENGINE_ELF)" PI4_APP_QUAKE_ELF="$(QUAKE_PI4_ENGINE_ELF)" PI4_IMAGE="$(PI4_REAL_ASSET_IMAGE)" PI4_IMAGE_INSPECT_TXT="$(PI4_REAL_ASSET_IMAGE_INSPECT_TXT)" pi4-real-assets-image; then \
		rm -f "$(PI4_REAL_ASSET_IMAGE)" "$(PI4_REAL_ASSET_IMAGE_INSPECT_TXT)" "$(PI4_REAL_ASSET_HANDOFF)"; \
		exit 1; \
	fi; \
	test -s "$(PI4_REAL_ASSET_IMAGE)" || { echo "prepared Pi 4 image is missing: $(PI4_REAL_ASSET_IMAGE)" >&2; exit 1; }; \
	test -s "$(PI4_REAL_ASSET_IMAGE_INSPECT_TXT)" || { echo "prepared Pi 4 image inspect is missing: $(PI4_REAL_ASSET_IMAGE_INSPECT_TXT)" >&2; exit 1; }; \
	require_manifest_size "kernel8" "manifest_file=KERNEL8.IMG state=present" "$(PI4_KERNEL8_IMG)"; \
	require_manifest_size "config" "manifest_file=CONFIG.TXT state=present" "$(PI4_CONFIG_TXT)"; \
	require_manifest_size "init" "manifest_file=INIT.ELF state=present" "$(PI4_LAUNCHER_ELF)"; \
	require_manifest_size "abiprobe" "manifest_file=ABIPROBE.ELF state=present" "$(PI4_ABI_PROBE_ELF)"; \
	require_manifest_size "system_init" "manifest_file=/SYSTEM/INIT.ELF state=present" "$(PI4_LAUNCHER_ELF)"; \
	require_manifest_size "system_abiprobe" "manifest_file=/SYSTEM/ABIPROBE.ELF state=present" "$(PI4_ABI_PROBE_ELF)"; \
	require_manifest_size "app_index" "manifest_file=/APPS/INDEX.TXT state=present" "$(PI4_APP_INDEX_TXT)"; \
	require_manifest_size "doom_app_manifest" "manifest_file=/APPS/DOOM/APP.TXT state=present" "$(PI4_APP_DOOM_MANIFEST_TXT)"; \
	require_manifest_size "quake_app_manifest" "manifest_file=/APPS/QUAKE/APP.TXT state=present" "$(PI4_APP_QUAKE_MANIFEST_TXT)"; \
	require_manifest_size "doom_app_exec" "manifest_file=/APPS/DOOM/APP.ELF state=present" "$(PI4_DOOM_ENGINE_ELF)"; \
	require_manifest_size "quake_app_exec" "manifest_file=/APPS/QUAKE/APP.ELF state=present" "$(QUAKE_PI4_ENGINE_ELF)"; \
	require_manifest_size "doom_wad" "manifest_file=DOOM1.WAD state=present" "$$doom_wad"; \
	require_manifest_size "quake_pak" "manifest_file=/ID1/PAK0.PAK state=present" "$$quake_pak"; \
	for generated_path in "$(PI4_KERNEL8_IMG)" "$(PI4_DOOM_ENGINE_ELF)" "$(QUAKE_PI4_ENGINE_ELF)" "$(PI4_REAL_ASSET_IMAGE)" "$(PI4_REAL_ASSET_IMAGE_INSPECT_TXT)" "$(PI4_REAL_ASSET_HANDOFF)"; do \
		require_build_artifact_path "$$generated_path"; \
	done; \
	image_sha="$$(sha256_file "$(PI4_REAL_ASSET_IMAGE)")"; \
	kernel_sha="$$(sha256_file "$(PI4_KERNEL8_IMG)")"; \
	doom_app_exec_sha="$$(sha256_file "$(PI4_DOOM_ENGINE_ELF)")"; \
	quake_app_exec_sha="$$(sha256_file "$(QUAKE_PI4_ENGINE_ELF)")"; \
	inspect_sha="$$(sha256_file "$(PI4_REAL_ASSET_IMAGE_INSPECT_TXT)")"; \
	doom_sha="$$(sha1_file "$$doom_wad")"; \
	quake_sha="$$(sha1_file "$$quake_pak")"; \
	image_abs="$$(abs_path "$(PI4_REAL_ASSET_IMAGE)")"; \
	kernel_abs="$$(abs_path "$(PI4_KERNEL8_IMG)")"; \
	doom_app_exec_abs="$$(abs_path "$(PI4_DOOM_ENGINE_ELF)")"; \
	quake_app_exec_abs="$$(abs_path "$(QUAKE_PI4_ENGINE_ELF)")"; \
	inspect_abs="$$(abs_path "$(PI4_REAL_ASSET_IMAGE_INSPECT_TXT)")"; \
	handoff_abs="$$(abs_path "$(PI4_REAL_ASSET_HANDOFF)")"; \
	doom_repo_state="$$(asset_repo_state "$$doom_wad")"; \
	quake_repo_state="$$(asset_repo_state "$$quake_pak")"; \
	handoff_inspect_line() { \
		label="$$1"; \
		pattern="$$2"; \
		line="$$(grep -m 1 -F "$$pattern" "$(PI4_REAL_ASSET_IMAGE_INSPECT_TXT)")" || { echo "prepared Pi 4 image inspect is missing $$label: $$pattern" >&2; exit 1; }; \
		printf "%s=%s\n" "$$label" "$$line"; \
	}; \
	{ \
		printf "schema=vibe-os-pi4-real-assets-handoff-v1\n"; \
		printf "image=%s\n" "$(PI4_REAL_ASSET_IMAGE)"; \
		printf "image_abs=%s\n" "$$image_abs"; \
		printf "image_sha256=%s\n" "$$image_sha"; \
		printf "image_size=%s\n" "$$(file_size "$(PI4_REAL_ASSET_IMAGE)")"; \
		printf "image_git_ignored=yes\n"; \
		printf "kernel=%s\n" "$(PI4_KERNEL8_IMG)"; \
		printf "kernel_abs=%s\n" "$$kernel_abs"; \
		printf "kernel_sha256=%s\n" "$$kernel_sha"; \
		printf "kernel_size=%s\n" "$$(file_size "$(PI4_KERNEL8_IMG)")"; \
		printf "kernel_git_ignored=yes\n"; \
		printf "doom_app_exec_source=%s\n" "$(PI4_DOOM_ENGINE_ELF)"; \
		printf "doom_app_exec_source_abs=%s\n" "$$doom_app_exec_abs"; \
		printf "doom_app_exec_sha256=%s\n" "$$doom_app_exec_sha"; \
		printf "doom_app_exec_size=%s\n" "$$(file_size "$(PI4_DOOM_ENGINE_ELF)")"; \
		printf "doom_app_exec_git_ignored=yes\n"; \
		printf "quake_app_exec_source=%s\n" "$(QUAKE_PI4_ENGINE_ELF)"; \
		printf "quake_app_exec_source_abs=%s\n" "$$quake_app_exec_abs"; \
		printf "quake_app_exec_sha256=%s\n" "$$quake_app_exec_sha"; \
		printf "quake_app_exec_size=%s\n" "$$(file_size "$(QUAKE_PI4_ENGINE_ELF)")"; \
		printf "quake_app_exec_git_ignored=yes\n"; \
		printf "inspect=%s\n" "$(PI4_REAL_ASSET_IMAGE_INSPECT_TXT)"; \
		printf "inspect_abs=%s\n" "$$inspect_abs"; \
		printf "inspect_sha256=%s\n" "$$inspect_sha"; \
		printf "inspect_git_ignored=yes\n"; \
		printf "handoff=%s\n" "$(PI4_REAL_ASSET_HANDOFF)"; \
		printf "handoff_abs=%s\n" "$$handoff_abs"; \
		printf "handoff_git_ignored=yes\n"; \
		printf "doom_wad=%s\n" "$$doom_wad"; \
		printf "doom_wad_sha1=%s\n" "$$doom_sha"; \
		printf "doom_wad_size=%s\n" "$$(file_size "$$doom_wad")"; \
		printf "doom_wad_repo_state=%s\n" "$$doom_repo_state"; \
		printf "quake_pak=%s\n" "$$quake_pak"; \
		printf "quake_pak_sha1=%s\n" "$$quake_sha"; \
		printf "quake_pak_size=%s\n" "$$(file_size "$$quake_pak")"; \
		printf "quake_pak_repo_state=%s\n" "$$quake_repo_state"; \
		printf "asset_cache_dir=%s\n" "$(REAL_ASSET_CACHE_DIR)"; \
		printf "image_inspected=yes\n"; \
		printf "manifest_source=%s\n" "$(PI4_REAL_ASSET_IMAGE_INSPECT_TXT)"; \
		printf "app_layout=/SYSTEM/INIT.ELF,/APPS/INDEX.TXT,/APPS/<APP>/APP.TXT,/APPS/<APP>/APP.ELF\n"; \
		printf "app_discovery_model=vfs-app-index\n"; \
		printf "app_launch_model=generic-vfs-path-exec\n"; \
		printf "app_exec_model=generic-aarch64-el0-elf-by-path\n"; \
		printf "system_init=/SYSTEM/INIT.ELF\n"; \
		printf "app_index=/APPS/INDEX.TXT\n"; \
		printf "doom_app_manifest=/APPS/DOOM/APP.TXT\n"; \
		printf "doom_app_exec=/APPS/DOOM/APP.ELF\n"; \
		printf "doom_app_icon=wad:TITLEPIC\n"; \
		printf "quake_app_manifest=/APPS/QUAKE/APP.TXT\n"; \
		printf "quake_app_exec=/APPS/QUAKE/APP.ELF\n"; \
		printf "quake_app_icon=pak:gfx/conback.lmp\n"; \
		handoff_inspect_line "manifest_path" "manifest_path=/PROOF/MANIFEST.TXT state=present"; \
		handoff_inspect_line "manifest_kernel_file" "kernel_file=KERNEL8.IMG"; \
		handoff_inspect_line "manifest_kernel" "manifest_file=KERNEL8.IMG state=present"; \
		handoff_inspect_line "manifest_config_file" "config_file=CONFIG.TXT"; \
		handoff_inspect_line "manifest_config" "manifest_file=CONFIG.TXT state=present"; \
		handoff_inspect_line "manifest_app_layout" "app_layout=system-init-plus-apps-tree"; \
		handoff_inspect_line "manifest_app_discovery_model" "app_discovery_model=vfs-app-index"; \
		handoff_inspect_line "manifest_app_launch_model" "app_launch_model=generic-vfs-path-exec"; \
		handoff_inspect_line "manifest_app_exec_model" "app_exec_model=generic-aarch64-el0-elf-by-path"; \
		handoff_inspect_line "manifest_system_init_path" "system_init=/SYSTEM/INIT.ELF"; \
		handoff_inspect_line "manifest_system_init_file" "manifest_file=/SYSTEM/INIT.ELF state=present"; \
		handoff_inspect_line "manifest_system_abiprobe_path" "system_abiprobe=/SYSTEM/ABIPROBE.ELF"; \
		handoff_inspect_line "manifest_system_abiprobe_file" "manifest_file=/SYSTEM/ABIPROBE.ELF state=present"; \
		handoff_inspect_line "manifest_app_index_path" "app_index=/APPS/INDEX.TXT"; \
		handoff_inspect_line "manifest_app_index_file" "manifest_file=/APPS/INDEX.TXT state=present"; \
		handoff_inspect_line "manifest_app_index_status" "app_index_manifest=/APPS/INDEX.TXT state=present"; \
		handoff_inspect_line "manifest_doom_app_manifest_path" "app.0.manifest=/APPS/DOOM/APP.TXT"; \
		handoff_inspect_line "manifest_doom_app_manifest_file" "manifest_file=/APPS/DOOM/APP.TXT state=present"; \
		handoff_inspect_line "manifest_doom_app_manifest_status" "app_manifest=/APPS/DOOM/APP.TXT state=present"; \
		handoff_inspect_line "manifest_doom_app_exec_path" "app.0.exec=/APPS/DOOM/APP.ELF"; \
		handoff_inspect_line "manifest_doom_app_exec_file" "manifest_file=/APPS/DOOM/APP.ELF state=present"; \
		handoff_inspect_line "manifest_doom_app_exec_status" "app_exec=/APPS/DOOM/APP.ELF state=present"; \
		handoff_inspect_line "manifest_doom_app_launch" "app.0.launch=generic-path-exec"; \
		handoff_inspect_line "manifest_doom_app_exec_model" "app.0.exec_model=generic-aarch64-el0-elf-by-path"; \
		handoff_inspect_line "manifest_doom_app_resource" "app.0.resource=/DOOM1.WAD"; \
		handoff_inspect_line "manifest_doom_app_icon" "app.0.icon=wad:TITLEPIC"; \
		handoff_inspect_line "manifest_quake_app_manifest_path" "app.1.manifest=/APPS/QUAKE/APP.TXT"; \
		handoff_inspect_line "manifest_quake_app_manifest_file" "manifest_file=/APPS/QUAKE/APP.TXT state=present"; \
		handoff_inspect_line "manifest_quake_app_manifest_status" "app_manifest=/APPS/QUAKE/APP.TXT state=present"; \
		handoff_inspect_line "manifest_quake_app_exec_path" "app.1.exec=/APPS/QUAKE/APP.ELF"; \
		handoff_inspect_line "manifest_quake_app_exec_file" "manifest_file=/APPS/QUAKE/APP.ELF state=present"; \
		handoff_inspect_line "manifest_quake_app_exec_status" "app_exec=/APPS/QUAKE/APP.ELF state=present"; \
		handoff_inspect_line "manifest_quake_app_launch" "app.1.launch=generic-path-exec"; \
		handoff_inspect_line "manifest_quake_app_exec_model" "app.1.exec_model=generic-aarch64-el0-elf-by-path"; \
		handoff_inspect_line "manifest_quake_app_resource" "app.1.resource=/ID1/PAK0.PAK"; \
		handoff_inspect_line "manifest_quake_app_icon" "app.1.icon=pak:gfx/conback.lmp"; \
		handoff_inspect_line "manifest_init" "manifest_file=INIT.ELF state=present"; \
		handoff_inspect_line "manifest_abiprobe" "manifest_file=ABIPROBE.ELF state=present"; \
		handoff_inspect_line "manifest_doom_wad" "manifest_file=DOOM1.WAD state=present"; \
		handoff_inspect_line "manifest_doom_asset" "manifest_asset=DOOM1.WAD kind=doom-wad source=external"; \
		handoff_inspect_line "manifest_quake_pak" "manifest_file=/ID1/PAK0.PAK state=present"; \
		handoff_inspect_line "manifest_quake_asset" "manifest_asset=/ID1/PAK0.PAK kind=quake-pak source=external"; \
		handoff_inspect_line "manifest_asset_handoff" "manifest_asset_handoff=OK"; \
		handoff_inspect_line "manifest_real_assets" "real_asset_manifest=OK"; \
		printf "manifest_kernel_size_matches_file=yes\n"; \
		printf "manifest_config_size_matches_file=yes\n"; \
		printf "manifest_init_size_matches_file=yes\n"; \
		printf "manifest_abiprobe_size_matches_file=yes\n"; \
		printf "manifest_doom_app_exec_size_matches_file=yes\n"; \
		printf "manifest_quake_app_exec_size_matches_file=yes\n"; \
		printf "manifest_doom_wad_size_matches_file=yes\n"; \
		printf "manifest_quake_pak_size_matches_file=yes\n"; \
		printf "exact_boot_image=%s\n" "$(PI4_REAL_ASSET_IMAGE)"; \
		printf "exact_boot_image_abs=%s\n" "$$image_abs"; \
		printf "exact_boot_image_sha256=%s\n" "$$image_sha"; \
			printf "exact_boot_image_inspect=%s\n" "$(PI4_REAL_ASSET_IMAGE_INSPECT_TXT)"; \
			printf "exact_boot_image_inspect_abs=%s\n" "$$inspect_abs"; \
			printf "qemu_boot_target=pi4-local-qemu-live\n"; \
			printf "qemu_command_handoff=make pi4-qemu-command\n"; \
			printf "qemu_user_command=make ALLOW_LOCAL_VM=1 pi4-local-qemu-live\n"; \
			printf "hw_equivalent_command=make ALLOW_LOCAL_VM=1 pi4-hw-equivalent-run\n"; \
			printf "hw_equivalent_real_assets_command=make ALLOW_LOCAL_VM=1 pi4-hw-equivalent-real-assets-run\n"; \
			printf "ci_prepare_command=make pi4-prepared-real-assets-image\n"; \
			printf "ci_qemu_command_source=make --no-print-directory PI4_HW_EQUIVALENT_IMAGE=%s pi4-hw-equivalent-qemu-command\n" "$(PI4_REAL_ASSET_IMAGE)"; \
			printf "remote_prepare_command=make pi4-prepared-real-assets-image\n"; \
			printf "remote_visible_codespaces_command=./tools/play_now_codespaces.sh --pi4 --repo OWNER/REPO --ref BRANCH\n"; \
			printf "remote_visible_preflight_command=PI4_REAL_ASSET_IMAGE=%s PI4_REAL_ASSET_HANDOFF=%s ./tools/play_now_remote.sh --pi4 --preflight --require-novnc\n" "$(PI4_REAL_ASSET_IMAGE)" "$(PI4_REAL_ASSET_HANDOFF)"; \
			printf "remote_visible_command=PI4_REAL_ASSET_IMAGE=%s PI4_REAL_ASSET_HANDOFF=%s ./tools/play_now_remote.sh --pi4 --require-novnc\n" "$(PI4_REAL_ASSET_IMAGE)" "$(PI4_REAL_ASSET_HANDOFF)"; \
			printf "qemu_drive_arg=file=%s,if=sd,format=raw\n" "$(PI4_REAL_ASSET_IMAGE)"; \
			printf "qemu_kernel_arg=%s\n" "$(PI4_KERNEL8_IMG)"; \
			printf "qemu_display=native-fullscreen-zoomed-or-novnc-scale\n"; \
			printf "qemu_input=usb-keyboard-usb-mouse\n"; \
			printf "novnc_browser_path=/vnc.html?autoconnect=1&resize=scale\n"; \
		printf "launcher_focus=click-qemu-or-novnc-canvas-first\n"; \
		printf "launcher_select_doom=press-1-or-click-Doom\n"; \
		printf "launcher_select_quake=press-2-or-click-Quake\n"; \
		printf "local_qemu_executed=no\n"; \
		printf "hardware_proof=unclaimed\n"; \
	} > "$(PI4_REAL_ASSET_HANDOFF)"; \
	printf "Pi 4 real-assets handoff ready; local QEMU was not started.\n"; \
	cat "$(PI4_REAL_ASSET_HANDOFF)"

pi4-prepared-real-assets-final-gates: tools/prepare_game_assets.sh pi4-engine-apps-linked
	@set -e; \
	printf "Preparing Pi 4 real WAD/PAK inputs with external cache: %s\n" "$(REAL_ASSET_CACHE_DIR)" >&2; \
	asset_paths="$$(VIBE_ASSET_CACHE_DIR="$(REAL_ASSET_CACHE_DIR)" tools/prepare_game_assets.sh --format paths)"; \
	doom_wad="$$(printf "%s\n" "$$asset_paths" | sed -n '1p')"; \
	quake_pak="$$(printf "%s\n" "$$asset_paths" | sed -n '2p')"; \
	test -n "$$doom_wad" || { echo "prepare helper did not return DOOM_WAD" >&2; exit 1; }; \
	test -n "$$quake_pak" || { echo "prepare helper did not return QUAKE_PAK" >&2; exit 1; }; \
	printf "Packaging exact Pi 4 final-gates image from DOOM_WAD=%s and QUAKE_PAK=%s\n" "$$doom_wad" "$$quake_pak" >&2; \
		$(REAL_ASSET_SUBBUILD) --no-print-directory DOOM_WAD="$$doom_wad" QUAKE_PAK="$$quake_pak" PI4_APP_DOOM_ELF="$(PI4_DOOM_ENGINE_ELF)" PI4_APP_QUAKE_ELF="$(QUAKE_PI4_ENGINE_ELF)" PI4_REAL_ASSET_PROOF_IMAGE="$(PI4_REAL_ASSET_PROOF_IMAGE)" PI4_REAL_ASSET_PROOF_IMAGE_INSPECT_TXT="$(PI4_REAL_ASSET_PROOF_IMAGE_INSPECT_TXT)" ALLOW_LOCAL_VM="$(ALLOW_LOCAL_VM)" PI4_LOCAL_QEMU_REAL_ASSET_SECONDS="$(PI4_LOCAL_QEMU_REAL_ASSET_SECONDS)" pi4-local-qemu-real-assets-final-gates

pi4-final-gates-single-artifact-guard: $(VIBE_STATUS_CHECK)
	@set -e; \
	gates="$(PI4_FINAL_GATES_GUARD)"; \
	if [ ! -e "$$gates" ]; then \
		printf "Pi 4 final gates single-artifact guard skipped: %s not present.\n" "$$gates"; \
		exit 0; \
	fi; \
	test -s "$(PI4_IMAGE)" || { echo "missing current Pi 4 image for single-artifact guard: $(PI4_IMAGE)" >&2; exit 1; }; \
	current_sha="$$(shasum -a 256 "$(PI4_IMAGE)" | cut -d ' ' -f 1)"; \
	$(VIBE_STATUS_CHECK) --pi4-final-gates-single-artifact "$$gates" "$$current_sha"; \
	printf "Pi 4 final gates single-artifact guard OK: %s matches %s\n" "$$gates" "$(PI4_IMAGE)"

pi4-doom-quake-app-image-inspect: $(PI4_DOOM_ELF) $(PI4_QUAKE_ELF)
	@printf "Packaging Pi AArch64 Doom and Quake app ELFs into Pi 4 app directories; Pi launch and hardware proof remain unclaimed.\n"
	$(MAKE) --no-print-directory PI4_APP_DOOM_ELF="$(PI4_DOOM_ELF)" PI4_APP_QUAKE_ELF="$(PI4_QUAKE_ELF)" pi4-image-inspect

pi4-qemu-command: $(PI4_QEMU_COMMAND) $(PI4_EXACT_BOOT_IMAGE_DEPS)
	@printf "Pi 4 exact boot image path: %s\n" "$(PI4_EXACT_BOOT_IMAGE)"
	@set -e; \
	test -n "$(strip $(PI4_EXACT_BOOT_IMAGE_DEPS))" || { echo "Pi 4 exact boot image deps are empty; refusing stale handoff." >&2; exit 1; }; \
	test -s "$(PI4_EXACT_BOOT_IMAGE)" || { echo "missing Pi 4 exact boot image: $(PI4_EXACT_BOOT_IMAGE)" >&2; exit 1; }; \
	test -s "$(PI4_REAL_ASSET_HANDOFF)" || { echo "missing prepared Pi 4 handoff: $(PI4_REAL_ASSET_HANDOFF)" >&2; exit 1; }; \
	sha256_file() { \
		if command -v sha256sum >/dev/null 2>&1; then sha256sum "$$1" | awk '{ print $$1 }'; \
		else shasum -a 256 "$$1" | awk '{ print $$1 }'; fi; \
	}; \
	handoff_field() { key="$$1"; sed -n "s/^$${key}=//p" "$(PI4_REAL_ASSET_HANDOFF)" | tail -n 1; }; \
	actual_image_sha="$$(sha256_file "$(PI4_EXACT_BOOT_IMAGE)")"; \
	actual_kernel_sha="$$(sha256_file "$(PI4_KERNEL8_IMG)")"; \
	handoff_image="$$(handoff_field image)"; \
	handoff_exact_image="$$(handoff_field exact_boot_image)"; \
	handoff_image_sha="$$(handoff_field image_sha256)"; \
	handoff_exact_sha="$$(handoff_field exact_boot_image_sha256)"; \
	handoff_kernel="$$(handoff_field kernel)"; \
	handoff_kernel_sha="$$(handoff_field kernel_sha256)"; \
	handoff_drive_arg="$$(handoff_field qemu_drive_arg)"; \
	handoff_doom_app_exec="$$(handoff_field doom_app_exec)"; \
	handoff_quake_app_exec="$$(handoff_field quake_app_exec)"; \
	handoff_doom_app_exec_source="$$(handoff_field doom_app_exec_source)"; \
	handoff_quake_app_exec_source="$$(handoff_field quake_app_exec_source)"; \
	test "$$handoff_image" = "$(PI4_EXACT_BOOT_IMAGE)" || { echo "prepared Pi 4 handoff image path is stale: $$handoff_image != $(PI4_EXACT_BOOT_IMAGE)" >&2; exit 1; }; \
	test "$$handoff_exact_image" = "$(PI4_EXACT_BOOT_IMAGE)" || { echo "prepared Pi 4 exact boot image path is stale: $$handoff_exact_image != $(PI4_EXACT_BOOT_IMAGE)" >&2; exit 1; }; \
	test "$$handoff_image_sha" = "$$actual_image_sha" || { echo "prepared Pi 4 handoff image SHA is stale: $$handoff_image_sha != $$actual_image_sha" >&2; exit 1; }; \
	test "$$handoff_exact_sha" = "$$actual_image_sha" || { echo "prepared Pi 4 exact boot image SHA is stale: $$handoff_exact_sha != $$actual_image_sha" >&2; exit 1; }; \
	test "$$handoff_kernel" = "$(PI4_KERNEL8_IMG)" || { echo "prepared Pi 4 handoff kernel path is stale: $$handoff_kernel != $(PI4_KERNEL8_IMG)" >&2; exit 1; }; \
	test "$$handoff_kernel_sha" = "$$actual_kernel_sha" || { echo "prepared Pi 4 handoff kernel SHA is stale: $$handoff_kernel_sha != $$actual_kernel_sha" >&2; exit 1; }; \
	test "$$handoff_drive_arg" = "file=$(PI4_EXACT_BOOT_IMAGE),if=sd,format=raw" || { echo "prepared Pi 4 handoff QEMU drive arg is stale: $$handoff_drive_arg" >&2; exit 1; }; \
	test "$$handoff_doom_app_exec" = "/APPS/DOOM/APP.ELF" || { echo "prepared Pi 4 handoff Doom app_exec is stale: $$handoff_doom_app_exec" >&2; exit 1; }; \
	test "$$handoff_quake_app_exec" = "/APPS/QUAKE/APP.ELF" || { echo "prepared Pi 4 handoff Quake app_exec is stale: $$handoff_quake_app_exec" >&2; exit 1; }; \
	test "$$handoff_doom_app_exec_source" = "$(PI4_DOOM_ENGINE_ELF)" || { echo "prepared Pi 4 handoff Doom app_exec source is stale: $$handoff_doom_app_exec_source" >&2; exit 1; }; \
	test "$$handoff_quake_app_exec_source" = "$(QUAKE_PI4_ENGINE_ELF)" || { echo "prepared Pi 4 handoff Quake app_exec source is stale: $$handoff_quake_app_exec_source" >&2; exit 1; }; \
	printf "Prepared handoff file for exact boot image: %s\n" "$(PI4_REAL_ASSET_HANDOFF)"; \
	printf "Verified exact boot image SHA256: %s\n" "$$actual_image_sha"
	@printf "Not executed. Real Raspberry Pi hardware proof remains unclaimed.\n"
	@printf "One-command local visible handoff: make ALLOW_LOCAL_VM=1 pi4-local-qemu-live\n"
	@printf "One-command remote noVNC handoff from this Mac: ./tools/play_now_codespaces.sh --pi4 --repo OWNER/REPO --ref BRANCH\n"
	@printf "Exact visible QEMU command follows; it is printed only, not executed.\n"
	@ALLOW_LOCAL_VM=0 PI4_QEMU_USB_KEYBOARD="$(PI4_QEMU_USB_KEYBOARD)" PI4_QEMU_USB_MOUSE="$(PI4_QEMU_USB_MOUSE)" PI4_QEMU_MOUSE_SERIAL="$(PI4_QEMU_MOUSE_SERIAL)" $(PI4_QEMU_COMMAND) --live "$(PI4_HW_EQUIVALENT_QEMU)" "$(PI4_LOCAL_QEMU_LIVE_SERIAL)" "$(PI4_KERNEL8_IMG)" "$(PI4_EXACT_BOOT_IMAGE)"
	@printf "Headless CI/proof command source remains: make pi4-hw-equivalent-qemu-command\n"

pi4-qemu-prep: $(PI4_QEMU_COMMAND)
	@printf "Preparing Pi 4 local/user QEMU handoff; VM execution remains disabled.\n"
	@printf "Build and inspection stay host-only here; opt in separately before booting a local emulator.\n"
	$(MAKE) --no-print-directory ALLOW_LOCAL_VM=0 pi4-host-artifact-policy
	$(MAKE) --no-print-directory ALLOW_LOCAL_VM=0 pi4-hw-equivalent-artifact-policy
	$(MAKE) --no-print-directory ALLOW_LOCAL_VM=0 $(PI4_EXACT_BOOT_IMAGE_DEPS)
	@printf "Pi 4 exact boot image ready: %s\n" "$(PI4_EXACT_BOOT_IMAGE)"
	@printf "Artifact policy OK. Local/user QEMU command follows and is not executed.\n"
	@cat "$(PI4_REAL_ASSET_HANDOFF)"
	@printf "Print the visible handoff again with: make pi4-qemu-command\n"
	@printf "Boot the visible native QEMU window with: make ALLOW_LOCAL_VM=1 pi4-local-qemu-live\n"
	@printf "Or use remote noVNC from this Mac with: ./tools/play_now_codespaces.sh --pi4 --repo OWNER/REPO --ref BRANCH\n"
	@printf "Headless hardware-equivalent command source: make pi4-hw-equivalent-qemu-command\n"
	@printf "Hardware-equivalent CI status JSON: run .github/workflows/pi4-hw-equivalent.yml on the intended ref; it uses the same prepared real-assets image path.\n"
	@printf "Real Raspberry Pi hardware proof remains unclaimed.\n"
	@ALLOW_LOCAL_VM=0 PI4_QEMU_USB_KEYBOARD="$(PI4_QEMU_USB_KEYBOARD)" PI4_QEMU_USB_MOUSE="$(PI4_QEMU_USB_MOUSE)" PI4_QEMU_MOUSE_SERIAL="$(PI4_QEMU_MOUSE_SERIAL)" $(PI4_QEMU_COMMAND) --live "$(PI4_HW_EQUIVALENT_QEMU)" "$(PI4_LOCAL_QEMU_LIVE_SERIAL)" "$(PI4_KERNEL8_IMG)" "$(PI4_EXACT_BOOT_IMAGE)"

pi4-remote-visible-play-help:
	@printf "Pi 4 visible play is remote-only from this Mac; do not run local QEMU here.\n"
	@printf "Best one-command handoff from this Mac: ./tools/play_now_codespaces.sh --pi4 --repo OWNER/REPO --ref BRANCH\n"
	@printf "The Codespaces helper starts the remote launcher, marks noVNC private, prints the scaled URL, and opens it on macOS when possible.\n"
	@printf "Browser-only Codespaces path: ./tools/play_now_codespaces.sh --pi4 --repo OWNER/REPO --ref BRANCH --web-url\n"
	@printf "Inside the remote host, prepare the exact image first: make pi4-prepared-real-assets-image\n"
	@printf "Inside the remote host, dry-run first: PI4_REAL_ASSET_IMAGE=%s PI4_REAL_ASSET_HANDOFF=%s ./tools/play_now_remote.sh --pi4 --preflight --require-novnc\n" "$(PI4_EXACT_BOOT_IMAGE)" "$(PI4_REAL_ASSET_HANDOFF)"
	@printf "Inside the remote host, start play: PI4_REAL_ASSET_IMAGE=%s PI4_REAL_ASSET_HANDOFF=%s ./tools/play_now_remote.sh --pi4 --require-novnc\n" "$(PI4_EXACT_BOOT_IMAGE)" "$(PI4_REAL_ASSET_HANDOFF)"
	@printf "The remote launcher prints the exact build/pi4 image/kernel paths, hashes, and visible QEMU argv before launch.\n"
	@printf "Open noVNC in browser fullscreen, click the scaled canvas once, then press 1/click Doom or press 2/click Quake.\n"
	@printf "Visible play is not a proof gate; status/workflow gates remain the proof surface.\n"
	@printf "Keep WADs, PAKs, disk images, screenshots, raw audio, VM logs, tokens, and one-time codes on the disposable remote host.\n"

pi4-qemu-run: vm-consent $(PI4_QEMU_COMMAND) $(PI4_EXACT_BOOT_IMAGE_DEPS)
	@ALLOW_LOCAL_VM="$(ALLOW_LOCAL_VM)" $(PI4_QEMU_COMMAND) --exec "$(PI4_HW_EQUIVALENT_QEMU)" "$(PI4_HW_EQUIVALENT_SERIAL)" "$(PI4_KERNEL8_IMG)" "$(PI4_EXACT_BOOT_IMAGE)"

pi4-local-qemu-live: $(PI4_QEMU_COMMAND)
	@set -e; \
	test -n "$(strip $(PI4_LOCAL_QEMU_LIVE_IMAGE_DEPS))" || { echo "Pi 4 live image deps are empty; refusing stale image handoff." >&2; exit 1; }; \
	if [ "$(ALLOW_LOCAL_VM)" = "1" ]; then \
			command -v "$(PI4_HW_EQUIVALENT_QEMU)" >/dev/null || { echo "missing $(PI4_HW_EQUIVALENT_QEMU)" >&2; exit 127; }; \
			printf "Preparing exact Pi 4 real WAD/PAK image for visible QEMU handoff.\n"; \
			$(MAKE) --no-print-directory $(PI4_LOCAL_QEMU_LIVE_IMAGE_DEPS) || exit $$?; \
	else \
			printf "Local QEMU execution is disabled by default.\n"; \
			printf "Preparing exact Pi 4 real WAD/PAK image for command-only visible handoff.\n"; \
			$(MAKE) --no-print-directory ALLOW_LOCAL_VM=0 $(PI4_LOCAL_QEMU_LIVE_IMAGE_DEPS) || exit $$?; \
	fi; \
	test -s "$(PI4_LOCAL_QEMU_LIVE_IMAGE)" || { echo "missing prepared Pi 4 live image: $(PI4_LOCAL_QEMU_LIVE_IMAGE)" >&2; exit 1; }; \
	test -s "$(PI4_REAL_ASSET_HANDOFF)" || { echo "missing prepared Pi 4 handoff: $(PI4_REAL_ASSET_HANDOFF)" >&2; exit 1; }; \
	sha256_file() { \
		if command -v sha256sum >/dev/null 2>&1; then sha256sum "$$1" | awk '{ print $$1 }'; \
		else shasum -a 256 "$$1" | awk '{ print $$1 }'; fi; \
	}; \
	handoff_field() { key="$$1"; sed -n "s/^$${key}=//p" "$(PI4_REAL_ASSET_HANDOFF)" | tail -n 1; }; \
	actual_image_sha="$$(sha256_file "$(PI4_LOCAL_QEMU_LIVE_IMAGE)")"; \
	actual_kernel_sha="$$(sha256_file "$(PI4_KERNEL8_IMG)")"; \
	handoff_image="$$(handoff_field image)"; \
	handoff_exact_image="$$(handoff_field exact_boot_image)"; \
	handoff_image_sha="$$(handoff_field image_sha256)"; \
	handoff_exact_sha="$$(handoff_field exact_boot_image_sha256)"; \
	handoff_kernel="$$(handoff_field kernel)"; \
	handoff_kernel_sha="$$(handoff_field kernel_sha256)"; \
	handoff_drive_arg="$$(handoff_field qemu_drive_arg)"; \
	handoff_doom_app_exec="$$(handoff_field doom_app_exec)"; \
	handoff_quake_app_exec="$$(handoff_field quake_app_exec)"; \
	handoff_doom_app_exec_source="$$(handoff_field doom_app_exec_source)"; \
	handoff_quake_app_exec_source="$$(handoff_field quake_app_exec_source)"; \
	test "$$handoff_image" = "$(PI4_LOCAL_QEMU_LIVE_IMAGE)" || { echo "prepared Pi 4 live handoff image path is stale: $$handoff_image != $(PI4_LOCAL_QEMU_LIVE_IMAGE)" >&2; exit 1; }; \
	test "$$handoff_exact_image" = "$(PI4_LOCAL_QEMU_LIVE_IMAGE)" || { echo "prepared Pi 4 live exact image path is stale: $$handoff_exact_image != $(PI4_LOCAL_QEMU_LIVE_IMAGE)" >&2; exit 1; }; \
	test "$$handoff_image_sha" = "$$actual_image_sha" || { echo "prepared Pi 4 live handoff image SHA is stale: $$handoff_image_sha != $$actual_image_sha" >&2; exit 1; }; \
	test "$$handoff_exact_sha" = "$$actual_image_sha" || { echo "prepared Pi 4 live exact image SHA is stale: $$handoff_exact_sha != $$actual_image_sha" >&2; exit 1; }; \
	test "$$handoff_kernel" = "$(PI4_KERNEL8_IMG)" || { echo "prepared Pi 4 live handoff kernel path is stale: $$handoff_kernel != $(PI4_KERNEL8_IMG)" >&2; exit 1; }; \
	test "$$handoff_kernel_sha" = "$$actual_kernel_sha" || { echo "prepared Pi 4 live handoff kernel SHA is stale: $$handoff_kernel_sha != $$actual_kernel_sha" >&2; exit 1; }; \
	test "$$handoff_drive_arg" = "file=$(PI4_LOCAL_QEMU_LIVE_IMAGE),if=sd,format=raw" || { echo "prepared Pi 4 live handoff QEMU drive arg is stale: $$handoff_drive_arg" >&2; exit 1; }; \
	test "$$handoff_doom_app_exec" = "/APPS/DOOM/APP.ELF" || { echo "prepared Pi 4 live handoff Doom app_exec is stale: $$handoff_doom_app_exec" >&2; exit 1; }; \
	test "$$handoff_quake_app_exec" = "/APPS/QUAKE/APP.ELF" || { echo "prepared Pi 4 live handoff Quake app_exec is stale: $$handoff_quake_app_exec" >&2; exit 1; }; \
	test "$$handoff_doom_app_exec_source" = "$(PI4_DOOM_ENGINE_ELF)" || { echo "prepared Pi 4 live handoff Doom app_exec source is stale: $$handoff_doom_app_exec_source" >&2; exit 1; }; \
	test "$$handoff_quake_app_exec_source" = "$(QUAKE_PI4_ENGINE_ELF)" || { echo "prepared Pi 4 live handoff Quake app_exec source is stale: $$handoff_quake_app_exec_source" >&2; exit 1; }; \
	printf "Pi 4 live image handoff verified: %s sha256=%s\n" "$(PI4_LOCAL_QEMU_LIVE_IMAGE)" "$$actual_image_sha"; \
	for line in \
		"app_layout=/SYSTEM/INIT.ELF,/APPS/INDEX.TXT,/APPS/<APP>/APP.TXT,/APPS/<APP>/APP.ELF" \
		"app_discovery_model=vfs-app-index" \
		"app_launch_model=generic-vfs-path-exec" \
		"app_exec_model=generic-aarch64-el0-elf-by-path" \
		"doom_app_exec=/APPS/DOOM/APP.ELF" \
		"quake_app_exec=/APPS/QUAKE/APP.ELF" \
		"qemu_boot_target=pi4-local-qemu-live" \
		"qemu_user_command=make ALLOW_LOCAL_VM=1 pi4-local-qemu-live" \
		"launcher_select_doom=press-1-or-click-Doom" \
		"launcher_select_quake=press-2-or-click-Quake" \
		"hardware_proof=unclaimed"; do \
		grep -F -x -q "$$line" "$(PI4_REAL_ASSET_HANDOFF)" || { echo "prepared Pi 4 live handoff missing: $$line" >&2; exit 1; }; \
	done; \
	grep -E -q '^doom_app_exec_source=.*DOOM\.ENGINE\.APP\.ELF$$' "$(PI4_REAL_ASSET_HANDOFF)" || { echo "prepared Pi 4 live handoff missing Doom app_exec source path" >&2; exit 1; }; \
	grep -E -q '^quake_app_exec_source=.*QUAKE\.ENGINE\.APP\.ELF$$' "$(PI4_REAL_ASSET_HANDOFF)" || { echo "prepared Pi 4 live handoff missing Quake app_exec source path" >&2; exit 1; }; \
	if [ "$(ALLOW_LOCAL_VM)" = "1" ]; then \
			printf "Using freshly prepared and inspected Pi 4 real WAD/PAK image: %s\n" "$(PI4_LOCAL_QEMU_LIVE_IMAGE)"; \
			printf "Starting local Pi 4 QEMU fullscreen/zoomed play target.\n"; \
	else \
			printf "Command-only visible handoff; exact image prepared and local VM not booted.\n"; \
			printf "Allowed host one-command launch: make ALLOW_LOCAL_VM=1 pi4-local-qemu-live\n"; \
			printf "Host-only image preparation refresh: make pi4-prepared-real-assets-image\n"; \
			printf "Remote visible fallback from this Mac: make pi4-remote-visible-play-help\n"; \
	fi
	@if [ "$(ALLOW_LOCAL_VM)" = "1" ]; then \
			printf "Prepared handoff summary: %s\n" "$(PI4_REAL_ASSET_HANDOFF)"; \
			grep -E '^(image_abs|image_sha256|exact_boot_image_abs|exact_boot_image_sha256|kernel_abs|kernel_sha256|doom_app_exec|doom_app_exec_source|quake_app_exec|quake_app_exec_source|doom_wad_sha1|quake_pak_sha1|qemu_display|qemu_input|launcher_select_doom|launcher_select_quake|hardware_proof)=' "$(PI4_REAL_ASSET_HANDOFF)" || true; \
	elif [ -s "$(PI4_REAL_ASSET_HANDOFF)" ]; then \
			printf "Prepared handoff summary: %s\n" "$(PI4_REAL_ASSET_HANDOFF)"; \
			grep -E '^(image_abs|image_sha256|exact_boot_image_abs|exact_boot_image_sha256|kernel_abs|kernel_sha256|doom_app_exec|doom_app_exec_source|quake_app_exec|quake_app_exec_source|doom_wad_sha1|quake_pak_sha1|qemu_display|qemu_input|launcher_select_doom|launcher_select_quake|hardware_proof)=' "$(PI4_REAL_ASSET_HANDOFF)" || true; \
	else \
			printf "No prepared handoff file yet; prepare it separately with: make pi4-prepared-real-assets-image\n"; \
	fi
	@printf "Launcher: click the QEMU/noVNC canvas once, then press 1/click Doom or press 2/click Quake inside vibe-os.\n"
	@printf "Display default: macOS QEMU uses cocoa,zoom-to-fit=on,full-screen=on; set PI4_QEMU_DISPLAY to override.\n"
	@if [ "$(PI4_QEMU_USB_MOUSE)" != "0" ]; then \
			printf "QEMU window: fullscreen/zoomed framebuffer with USB keyboard and USB mouse on the Pi DWC2 root port.\n"; \
		printf "Input mode active: QEMU-window keyboard uses -device usb-kbd; QEMU-window mouse movement/clicks use -device usb-mouse.\n"; \
		printf "Input mode default: USB keyboard and USB mouse are enabled; set PI4_QEMU_USB_MOUSE=0 to fall back to -serial msmouse.\n"; \
	else \
		printf "QEMU window: fullscreen/zoomed framebuffer with USB keyboard on the Pi DWC2 root port and mouse clicks bridged through QEMU msmouse.\n"; \
		printf "Input mode active: QEMU-window keyboard uses -device usb-kbd; QEMU-window mouse movement/clicks use -serial msmouse.\n"; \
		printf "Input mode optional: set PI4_QEMU_USB_MOUSE=1 to restore the default -device usb-mouse path.\n"; \
	fi
	@printf "Exact user command: make ALLOW_LOCAL_VM=1 pi4-local-qemu-live\n"
	@printf "Remote noVNC command from this Mac: ./tools/play_now_codespaces.sh --pi4 --repo OWNER/REPO --ref BRANCH\n"
	@printf "Exact QEMU command follows; real Raspberry Pi hardware proof remains unclaimed.\n"
	@ALLOW_LOCAL_VM="$(ALLOW_LOCAL_VM)" PI4_QEMU_USB_KEYBOARD="$(PI4_QEMU_USB_KEYBOARD)" PI4_QEMU_USB_MOUSE="$(PI4_QEMU_USB_MOUSE)" PI4_QEMU_MOUSE_SERIAL="$(PI4_QEMU_MOUSE_SERIAL)" $(PI4_QEMU_COMMAND) --live "$(PI4_HW_EQUIVALENT_QEMU)" "$(PI4_LOCAL_QEMU_LIVE_SERIAL)" "$(PI4_KERNEL8_IMG)" "$(PI4_LOCAL_QEMU_LIVE_IMAGE)"

pi4-local-qemu-live-smoke: vm-consent $(PI4_QEMU_COMMAND) pi4-prepared-real-assets-image
	@command -v "$(PI4_HW_EQUIVALENT_QEMU)" >/dev/null || { echo "missing $(PI4_HW_EQUIVALENT_QEMU)" >&2; exit 127; }
	@printf "Using prepared exact Pi 4 real WAD/PAK image for local live command smoke.\n"
	@printf "Starting local Pi 4 QEMU live command smoke for %s seconds; this opens the visible framebuffer briefly and is not a proof gate.\n" "$(PI4_LOCAL_QEMU_LIVE_SECONDS)"
	@printf "Exact user command: make ALLOW_LOCAL_VM=1 pi4-local-qemu-live\n"
	@printf "Exact QEMU smoke command follows; real Raspberry Pi hardware proof remains unclaimed.\n"
	@ALLOW_LOCAL_VM="$(ALLOW_LOCAL_VM)" PI4_QEMU_USB_KEYBOARD="$(PI4_QEMU_USB_KEYBOARD)" PI4_QEMU_USB_MOUSE="$(PI4_QEMU_USB_MOUSE)" PI4_QEMU_MOUSE_SERIAL="$(PI4_QEMU_MOUSE_SERIAL)" $(PI4_QEMU_COMMAND) --live-smoke "$(PI4_LOCAL_QEMU_LIVE_SECONDS)" "$(PI4_HW_EQUIVALENT_QEMU)" "$(PI4_LOCAL_QEMU_LIVE_SERIAL)" "$(PI4_KERNEL8_IMG)" "$(PI4_LOCAL_QEMU_LIVE_IMAGE)"

pi4-local-qemu-smoke: vm-consent $(PI4_QEMU_COMMAND) $(PI4_IMAGE)
	@command -v "$(PI4_HW_EQUIVALENT_QEMU)" >/dev/null || { echo "missing $(PI4_HW_EQUIVALENT_QEMU)" >&2; exit 127; }
	@rm -f "$(PI4_LOCAL_QEMU_SERIAL)" "$(PI4_LOCAL_QEMU_STATUS_RAW)" "$(PI4_LOCAL_QEMU_STATUS)"
	@printf "Starting local Pi 4 QEMU smoke for %s seconds; this is not real Raspberry Pi hardware proof.\n" "$(PI4_LOCAL_QEMU_SECONDS)"
	@ALLOW_LOCAL_VM="$(ALLOW_LOCAL_VM)" $(PI4_QEMU_COMMAND) --local-smoke "$(PI4_LOCAL_QEMU_SECONDS)" "$(PI4_LOCAL_QEMU_STATUS_RAW)" "$(PI4_LOCAL_QEMU_STATUS)" "$(PI4_HW_EQUIVALENT_QEMU)" "file:$(PI4_LOCAL_QEMU_SERIAL)" "$(PI4_KERNEL8_IMG)" "$(PI4_IMAGE)"
	@set -e; \
		if ! test -s "$(PI4_LOCAL_QEMU_SERIAL)"; then \
			echo "Pi 4 local QEMU smoke produced no serial output." >&2; \
			exit 1; \
		fi; \
		if grep -a -F -q "status=NO_VIBE_STATUS" "$(PI4_LOCAL_QEMU_STATUS)"; then \
			last_stage="$$(sed -n 's/.* last_stage=\([^[:space:]]*\).*/\1/p' "$(PI4_LOCAL_QEMU_STATUS)" | tail -n 1)"; \
			last_code="$$(sed -n 's/.* last_code=\([^[:space:]]*\).*/\1/p' "$(PI4_LOCAL_QEMU_STATUS)" | tail -n 1)"; \
			printf "Pi 4 local QEMU smoke captured serial but no vibe-status: serial=%s status=%s\n" "$(PI4_LOCAL_QEMU_SERIAL)" "$(PI4_LOCAL_QEMU_STATUS)"; \
			printf "Local QEMU smoke is red/partial at stage=%s code=%s; no Pi 4 green gate or hardware proof is claimed.\n" "$${last_stage:-unknown}" "$${last_code:-unknown}"; \
			exit 0; \
		fi; \
		if ! test -s "$(PI4_LOCAL_QEMU_STATUS_RAW)"; then \
			echo "Pi 4 local QEMU smoke helper did not write raw vibe-status evidence." >&2; \
			exit 1; \
		fi; \
		for field in \
			"arch=AARCH64" "machine=PI4" "artifact=OK" "pi4boot=OK" "pi4uart=OK" \
			"pi4vec=OK" "pi4svc=OK" "pi4elf=OK" \
			"gfx=OK" "fb=PI4FB" "pi4fb=OK" "pi4input=UART-LIVE" \
			"panic=NONE" "shutdown=NONE"; \
		do \
			grep -a -F -q "$$field" "$(PI4_LOCAL_QEMU_STATUS)" || { echo "Pi 4 local QEMU smoke missing $$field" >&2; cat "$(PI4_LOCAL_QEMU_STATUS)" >&2; exit 1; }; \
		done; \
		grep -a -E -q '(^| )pi4elfsrc=(EMBEDDED|VFS)( |$$)' "$(PI4_LOCAL_QEMU_STATUS)" || { echo "Pi 4 local QEMU smoke missing pi4elfsrc status" >&2; cat "$(PI4_LOCAL_QEMU_STATUS)" >&2; exit 1; }; \
		grep -a -E -q '(^| )pi4blk=(OK|ENOSYS)( |$$)' "$(PI4_LOCAL_QEMU_STATUS)" || { echo "Pi 4 local QEMU smoke missing pi4blk status" >&2; cat "$(PI4_LOCAL_QEMU_STATUS)" >&2; exit 1; }; \
		grep -a -E -q '(^| )pi4sdctl=(EMMC2|EMMC|ENOSYS)( |$$)' "$(PI4_LOCAL_QEMU_STATUS)" || { echo "Pi 4 local QEMU smoke missing pi4sdctl status" >&2; cat "$(PI4_LOCAL_QEMU_STATUS)" >&2; exit 1; }; \
		grep -a -E -q '(^| )pi4timer=(OK|WAIT)( |$$)' "$(PI4_LOCAL_QEMU_STATUS)" || { echo "Pi 4 local QEMU smoke missing pi4timer status" >&2; cat "$(PI4_LOCAL_QEMU_STATUS)" >&2; exit 1; }; \
		grep -a -E -q '(^| )pi4preempt=(OK|WAIT)( |$$)' "$(PI4_LOCAL_QEMU_STATUS)" || { echo "Pi 4 local QEMU smoke missing pi4preempt status" >&2; cat "$(PI4_LOCAL_QEMU_STATUS)" >&2; exit 1; }; \
		printf "Pi 4 local QEMU smoke OK: serial=%s raw_status=%s marked_status=%s\n" "$(PI4_LOCAL_QEMU_SERIAL)" "$(PI4_LOCAL_QEMU_STATUS_RAW)" "$(PI4_LOCAL_QEMU_STATUS)"; \
		printf "Marked status carries local_qemu_only=true evidence_class=local-qemu-smoke smoke_gate=pi4-local-qemu-smoke green_gate=false hardware_proof=unclaimed.\n"; \
		printf "Local QEMU is boot/runtime smoke only; green storage/input/graphics/audio/process/memory/preemption gates still require hardware-equivalent evidence.\n"

pi4-local-qemu-doom-input-smoke: vm-consent $(PI4_QEMU_COMMAND) $(VIBE_STATUS_CHECK) pi4-image-inspect
	@command -v "$(PI4_HW_EQUIVALENT_QEMU)" >/dev/null || { echo "missing $(PI4_HW_EQUIVALENT_QEMU)" >&2; exit 127; }
	@rm -f "$(PI4_LOCAL_QEMU_DOOM_SERIAL)" "$(PI4_LOCAL_QEMU_DOOM_STATUS_RAW)" "$(PI4_LOCAL_QEMU_DOOM_STATUS)" "$(PI4_LOCAL_QEMU_DOOM_FB_REPORT)" "$(PI4_LOCAL_QEMU_DOOM_FB_FRAME0)" "$(PI4_LOCAL_QEMU_DOOM_FB_FRAME1)"
	@shasum -a 256 "$(PI4_IMAGE)" > "$(PI4_LOCAL_QEMU_IMAGE_SHA_BEFORE)"
	@printf "Starting local Pi 4 QEMU Doom input smoke: scripted input selects Doom, launches it, then sends gameplay input w.\n"
	@ALLOW_LOCAL_VM="$(ALLOW_LOCAL_VM)" PI4_QEMU_FRAME1_SETTLE_MS="$(PI4_LOCAL_QEMU_DOOM_FRAME1_SETTLE_MS)" $(PI4_QEMU_COMMAND) --local-input-framebuffer-smoke "$(PI4_LOCAL_QEMU_DOOM_SECONDS)" "$(PI4_LOCAL_QEMU_DOOM_INPUT)" "$(PI4_LOCAL_QEMU_DOOM_STATUS_RAW)" "$(PI4_LOCAL_QEMU_DOOM_STATUS)" "$(PI4_LOCAL_QEMU_DOOM_SERIAL)" "$(PI4_LOCAL_QEMU_DOOM_FB_REPORT)" "$(PI4_LOCAL_QEMU_DOOM_FB_FRAME0)" "$(PI4_LOCAL_QEMU_DOOM_FB_FRAME1)" "$(PI4_HW_EQUIVALENT_QEMU)" "$(PI4_KERNEL8_IMG)" "$(PI4_IMAGE)"
	@shasum -a 256 "$(PI4_IMAGE)" > "$(PI4_LOCAL_QEMU_IMAGE_SHA_AFTER)"
	@cmp "$(PI4_LOCAL_QEMU_IMAGE_SHA_BEFORE)" "$(PI4_LOCAL_QEMU_IMAGE_SHA_AFTER)"
	@$(VIBE_STATUS_CHECK) --pi4-local-qemu "$(PI4_LOCAL_QEMU_DOOM_STATUS_RAW)"
	@grep -a -F -q "evidence_class=local-qemu-input-smoke" "$(PI4_LOCAL_QEMU_DOOM_STATUS)"
	@grep -a -F -q "smoke_gate=pi4-local-qemu-input-smoke" "$(PI4_LOCAL_QEMU_DOOM_STATUS)"
	@grep -a -F -q "hardware_proof=unclaimed" "$(PI4_LOCAL_QEMU_DOOM_STATUS)"
	@grep -a -F -q "pi4exec=OK" "$(PI4_LOCAL_QEMU_DOOM_STATUS_RAW)"
	@grep -a -E -q '(^| )pi4appreq=0x[0-9a-fA-F]+/0x0*1/0x0*20/0x[0-9a-fA-F]+/0x0*12/0x0*c( |$$)' "$(PI4_LOCAL_QEMU_DOOM_STATUS_RAW)"
	@grep -a -E -q '(^| )pi4appvfs=0x0*c/0x0*464f4f4b' "$(PI4_LOCAL_QEMU_DOOM_STATUS_RAW)"
	@grep -a -E -q '(^| )pi4inputevt=.*0x0*1' "$(PI4_LOCAL_QEMU_DOOM_STATUS_RAW)"
	@grep -a -F -q "pi4fb=OK" "$(PI4_LOCAL_QEMU_DOOM_STATUS_RAW)"
	@grep -a -E -q '(^| )fbpresent=0x0*[1-9a-fA-F][0-9a-fA-F]*' "$(PI4_LOCAL_QEMU_DOOM_STATUS_RAW)"
	@grep -a -E -q '(^| )fbchange=.*0x0*1( |$$)' "$(PI4_LOCAL_QEMU_DOOM_STATUS_RAW)"
	@grep -a -F -q "pi4mem=OK" "$(PI4_LOCAL_QEMU_DOOM_STATUS_RAW)"
	@grep -a -F -q "pi4ualloc=" "$(PI4_LOCAL_QEMU_DOOM_STATUS_RAW)"
	@grep -a -F -q "pstat=" "$(PI4_LOCAL_QEMU_DOOM_STATUS_RAW)"
	@grep -F -q "framebuffer_artifact=OK" "$(PI4_LOCAL_QEMU_DOOM_FB_REPORT)"
	@grep -F -q "frame0_nonblank=true" "$(PI4_LOCAL_QEMU_DOOM_FB_REPORT)"
	@grep -F -q "frame1_nonblank=true" "$(PI4_LOCAL_QEMU_DOOM_FB_REPORT)"
	@grep -F -q "frames_changed=true" "$(PI4_LOCAL_QEMU_DOOM_FB_REPORT)"
	@grep -a -F -q "panic=NONE" "$(PI4_LOCAL_QEMU_DOOM_STATUS_RAW)"
	@grep -a -F -q "shutdown=NONE" "$(PI4_LOCAL_QEMU_DOOM_STATUS_RAW)"
	@printf "Pi 4 local QEMU Doom input smoke OK: %s -> %s, framebuffer artifact=%s, single artifact hash stable.\n" "$(PI4_IMAGE)" "$(PI4_LOCAL_QEMU_DOOM_STATUS_RAW)" "$(PI4_LOCAL_QEMU_DOOM_FB_REPORT)"

pi4-local-qemu-quake-input-smoke: vm-consent $(PI4_QEMU_COMMAND) $(VIBE_STATUS_CHECK) pi4-image-inspect
	@command -v "$(PI4_HW_EQUIVALENT_QEMU)" >/dev/null || { echo "missing $(PI4_HW_EQUIVALENT_QEMU)" >&2; exit 127; }
	@rm -f "$(PI4_LOCAL_QEMU_QUAKE_SERIAL)" "$(PI4_LOCAL_QEMU_QUAKE_STATUS_RAW)" "$(PI4_LOCAL_QEMU_QUAKE_STATUS)" "$(PI4_LOCAL_QEMU_QUAKE_FB_REPORT)" "$(PI4_LOCAL_QEMU_QUAKE_FB_FRAME0)" "$(PI4_LOCAL_QEMU_QUAKE_FB_FRAME1)"
	@shasum -a 256 "$(PI4_IMAGE)" > "$(PI4_LOCAL_QEMU_IMAGE_SHA_BEFORE)"
	@printf "Starting local Pi 4 QEMU Quake input smoke: scripted input selects Quake, launches it, then sends gameplay input s.\n"
	@ALLOW_LOCAL_VM="$(ALLOW_LOCAL_VM)" PI4_QEMU_FRAME1_SETTLE_MS="$(PI4_LOCAL_QEMU_QUAKE_FRAME1_SETTLE_MS)" $(PI4_QEMU_COMMAND) --local-input-framebuffer-smoke "$(PI4_LOCAL_QEMU_QUAKE_SECONDS)" "$(PI4_LOCAL_QEMU_QUAKE_INPUT)" "$(PI4_LOCAL_QEMU_QUAKE_STATUS_RAW)" "$(PI4_LOCAL_QEMU_QUAKE_STATUS)" "$(PI4_LOCAL_QEMU_QUAKE_SERIAL)" "$(PI4_LOCAL_QEMU_QUAKE_FB_REPORT)" "$(PI4_LOCAL_QEMU_QUAKE_FB_FRAME0)" "$(PI4_LOCAL_QEMU_QUAKE_FB_FRAME1)" "$(PI4_HW_EQUIVALENT_QEMU)" "$(PI4_KERNEL8_IMG)" "$(PI4_IMAGE)"
	@shasum -a 256 "$(PI4_IMAGE)" > "$(PI4_LOCAL_QEMU_IMAGE_SHA_AFTER)"
	@cmp "$(PI4_LOCAL_QEMU_IMAGE_SHA_BEFORE)" "$(PI4_LOCAL_QEMU_IMAGE_SHA_AFTER)"
	@$(VIBE_STATUS_CHECK) --pi4-local-qemu "$(PI4_LOCAL_QEMU_QUAKE_STATUS_RAW)"
	@grep -a -F -q "evidence_class=local-qemu-input-smoke" "$(PI4_LOCAL_QEMU_QUAKE_STATUS)"
	@grep -a -F -q "smoke_gate=pi4-local-qemu-input-smoke" "$(PI4_LOCAL_QEMU_QUAKE_STATUS)"
	@grep -a -F -q "hardware_proof=unclaimed" "$(PI4_LOCAL_QEMU_QUAKE_STATUS)"
	@grep -a -F -q "pi4exec=OK" "$(PI4_LOCAL_QEMU_QUAKE_STATUS_RAW)"
	@grep -a -E -q '(^| )pi4appreq=0x[0-9a-fA-F]+/0x0*1/0x0*20/0x[0-9a-fA-F]+/0x0*13/0x0*d( |$$)' "$(PI4_LOCAL_QEMU_QUAKE_STATUS_RAW)"
	@grep -a -E -q '(^| )pi4appvfs=0x0*d/0x0*464f4f4b' "$(PI4_LOCAL_QEMU_QUAKE_STATUS_RAW)"
	@grep -a -E -q '(^| )pi4inputevt=.*0x0*1' "$(PI4_LOCAL_QEMU_QUAKE_STATUS_RAW)"
	@grep -a -F -q "pi4fb=OK" "$(PI4_LOCAL_QEMU_QUAKE_STATUS_RAW)"
	@grep -a -E -q '(^| )fbpresent=0x0*[1-9a-fA-F][0-9a-fA-F]*' "$(PI4_LOCAL_QEMU_QUAKE_STATUS_RAW)"
	@grep -a -E -q '(^| )fbchange=.*0x0*1( |$$)' "$(PI4_LOCAL_QEMU_QUAKE_STATUS_RAW)"
	@grep -a -F -q "pi4mem=OK" "$(PI4_LOCAL_QEMU_QUAKE_STATUS_RAW)"
	@grep -a -F -q "pi4ualloc=" "$(PI4_LOCAL_QEMU_QUAKE_STATUS_RAW)"
	@grep -a -F -q "pstat=" "$(PI4_LOCAL_QEMU_QUAKE_STATUS_RAW)"
	@grep -F -q "framebuffer_artifact=OK" "$(PI4_LOCAL_QEMU_QUAKE_FB_REPORT)"
	@grep -F -q "frame0_nonblank=true" "$(PI4_LOCAL_QEMU_QUAKE_FB_REPORT)"
	@grep -F -q "frame1_nonblank=true" "$(PI4_LOCAL_QEMU_QUAKE_FB_REPORT)"
	@grep -F -q "frames_changed=true" "$(PI4_LOCAL_QEMU_QUAKE_FB_REPORT)"
	@grep -a -F -q "panic=NONE" "$(PI4_LOCAL_QEMU_QUAKE_STATUS_RAW)"
	@grep -a -F -q "shutdown=NONE" "$(PI4_LOCAL_QEMU_QUAKE_STATUS_RAW)"
	@printf "Pi 4 local QEMU Quake input smoke OK: %s -> %s, framebuffer artifact=%s, single artifact hash stable.\n" "$(PI4_IMAGE)" "$(PI4_LOCAL_QEMU_QUAKE_STATUS_RAW)" "$(PI4_LOCAL_QEMU_QUAKE_FB_REPORT)"

pi4-local-qemu-input-smoke: pi4-local-qemu-doom-input-smoke pi4-local-qemu-quake-input-smoke
	@printf "Pi 4 local QEMU input smoke OK for Doom and Quake launcher selections.\n"

pi4-local-qemu-final-gates: pi4-local-qemu-input-smoke $(VIBE_STATUS_CHECK)
	@set -e; \
		doom_audio="$$(tr ' ' '\n' < "$(PI4_LOCAL_QEMU_DOOM_STATUS_RAW)" | sed -n 's/^pi4audio=//p' | tail -n 1)"; \
		quake_audio="$$(tr ' ' '\n' < "$(PI4_LOCAL_QEMU_QUAKE_STATUS_RAW)" | sed -n 's/^pi4audio=//p' | tail -n 1)"; \
		doom_fb0="$$(sed -n 's/^frame0_hash=//p' "$(PI4_LOCAL_QEMU_DOOM_FB_REPORT)" | tail -n 1)"; \
		doom_fb1="$$(sed -n 's/^frame1_hash=//p' "$(PI4_LOCAL_QEMU_DOOM_FB_REPORT)" | tail -n 1)"; \
		quake_fb0="$$(sed -n 's/^frame0_hash=//p' "$(PI4_LOCAL_QEMU_QUAKE_FB_REPORT)" | tail -n 1)"; \
		quake_fb1="$$(sed -n 's/^frame1_hash=//p' "$(PI4_LOCAL_QEMU_QUAKE_FB_REPORT)" | tail -n 1)"; \
		case "$$doom_audio:$$quake_audio" in \
			*HARDWARE-UNPROVEN*|*WAIT*) audio_gate=hardware-unproven ;; \
			OK:OK) echo "local QEMU captured pi4audio=OK; refusing final gates because audio OK requires real Pi hardware evidence" >&2; exit 1 ;; \
			*) echo "unknown captured Pi 4 audio states: doom=$$doom_audio quake=$$quake_audio" >&2; exit 1 ;; \
		esac; \
		printf "storage=green\n" > "$(PI4_LOCAL_QEMU_FINAL_GATES)"; \
		printf "input=green\n" >> "$(PI4_LOCAL_QEMU_FINAL_GATES)"; \
		printf "graphics=green\n" >> "$(PI4_LOCAL_QEMU_FINAL_GATES)"; \
		printf "process=green\n" >> "$(PI4_LOCAL_QEMU_FINAL_GATES)"; \
		printf "memory=green\n" >> "$(PI4_LOCAL_QEMU_FINAL_GATES)"; \
		printf "preemption=green\n" >> "$(PI4_LOCAL_QEMU_FINAL_GATES)"; \
		printf "audio=%s\n" "$$audio_gate" >> "$(PI4_LOCAL_QEMU_FINAL_GATES)"; \
		printf "hardware=unclaimed\n" >> "$(PI4_LOCAL_QEMU_FINAL_GATES)"; \
		printf "green_gate=false\n" >> "$(PI4_LOCAL_QEMU_FINAL_GATES)"; \
		printf "hardware_proof=unclaimed\n" >> "$(PI4_LOCAL_QEMU_FINAL_GATES)"; \
		printf "evidence_class=local-qemu-final-gates\n" >> "$(PI4_LOCAL_QEMU_FINAL_GATES)"; \
		printf "framebuffer_artifact=green\n" >> "$(PI4_LOCAL_QEMU_FINAL_GATES)"; \
		printf "framebuffer_artifact_source=qemu-screendump\n" >> "$(PI4_LOCAL_QEMU_FINAL_GATES)"; \
		printf "doom_framebuffer_artifact=green\n" >> "$(PI4_LOCAL_QEMU_FINAL_GATES)"; \
		printf "doom_framebuffer_report=%s\n" "$(PI4_LOCAL_QEMU_DOOM_FB_REPORT)" >> "$(PI4_LOCAL_QEMU_FINAL_GATES)"; \
		printf "doom_framebuffer_frame0_hash=%s\n" "$$doom_fb0" >> "$(PI4_LOCAL_QEMU_FINAL_GATES)"; \
		printf "doom_framebuffer_frame1_hash=%s\n" "$$doom_fb1" >> "$(PI4_LOCAL_QEMU_FINAL_GATES)"; \
		printf "quake_framebuffer_artifact=green\n" >> "$(PI4_LOCAL_QEMU_FINAL_GATES)"; \
		printf "quake_framebuffer_report=%s\n" "$(PI4_LOCAL_QEMU_QUAKE_FB_REPORT)" >> "$(PI4_LOCAL_QEMU_FINAL_GATES)"; \
		printf "quake_framebuffer_frame0_hash=%s\n" "$$quake_fb0" >> "$(PI4_LOCAL_QEMU_FINAL_GATES)"; \
		printf "quake_framebuffer_frame1_hash=%s\n" "$$quake_fb1" >> "$(PI4_LOCAL_QEMU_FINAL_GATES)"; \
		printf "capture_audio_doom=%s\n" "$$doom_audio" >> "$(PI4_LOCAL_QEMU_FINAL_GATES)"; \
		printf "capture_audio_quake=%s\n" "$$quake_audio" >> "$(PI4_LOCAL_QEMU_FINAL_GATES)"; \
		printf "single_artifact=green\n" >> "$(PI4_LOCAL_QEMU_FINAL_GATES)"; \
		printf "single_artifact_image=%s\n" "$(PI4_IMAGE)" >> "$(PI4_LOCAL_QEMU_FINAL_GATES)"; \
		printf "single_artifact_sha256=%s\n" "$$(cut -d ' ' -f 1 "$(PI4_LOCAL_QEMU_IMAGE_SHA_AFTER)")" >> "$(PI4_LOCAL_QEMU_FINAL_GATES)"; \
		printf "single_artifact_inspect=%s\n" "$(PI4_IMAGE_INSPECT_TXT)" >> "$(PI4_LOCAL_QEMU_FINAL_GATES)"; \
		printf "doom_serial=%s\n" "$(PI4_LOCAL_QEMU_DOOM_SERIAL)" >> "$(PI4_LOCAL_QEMU_FINAL_GATES)"; \
		printf "doom_status=%s\n" "$(PI4_LOCAL_QEMU_DOOM_STATUS_RAW)" >> "$(PI4_LOCAL_QEMU_FINAL_GATES)"; \
		printf "quake_serial=%s\n" "$(PI4_LOCAL_QEMU_QUAKE_SERIAL)" >> "$(PI4_LOCAL_QEMU_FINAL_GATES)"; \
		printf "quake_status=%s\n" "$(PI4_LOCAL_QEMU_QUAKE_STATUS_RAW)" >> "$(PI4_LOCAL_QEMU_FINAL_GATES)"
	@$(VIBE_STATUS_CHECK) --pi4-final-gates "$(PI4_LOCAL_QEMU_FINAL_GATES)" "$(PI4_LOCAL_QEMU_DOOM_STATUS_RAW)" "$(PI4_LOCAL_QEMU_QUAKE_STATUS_RAW)" "$(PI4_LOCAL_QEMU_DOOM_STATUS)" "$(PI4_LOCAL_QEMU_QUAKE_STATUS)"
	@cat "$(PI4_LOCAL_QEMU_FINAL_GATES)"

pi4-local-qemu-real-assets-input-smoke: pi4-real-assets-require pi4-engine-apps-linked
	@$(MAKE) --no-print-directory ALLOW_LOCAL_VM="$(ALLOW_LOCAL_VM)" DOOM_WAD="$(PI4_REAL_DOOM_WAD)" QUAKE_PAK="$(PI4_REAL_QUAKE_PAK)" PRIMARY_ASSET="$(PI4_REAL_DOOM_WAD)" SECONDARY_PACKAGE="$(PI4_REAL_QUAKE_PAK)" PI4_APP_DOOM_ELF="$(PI4_DOOM_ENGINE_ELF)" PI4_APP_QUAKE_ELF="$(QUAKE_PI4_ENGINE_ELF)" PI4_IMAGE="$(PI4_REAL_ASSET_PROOF_IMAGE)" PI4_IMAGE_INSPECT_TXT="$(PI4_REAL_ASSET_PROOF_IMAGE_INSPECT_TXT)" PI4_REQUIRE_REAL_ASSETS=1 PI4_LOCAL_QEMU_SECONDS="$(PI4_LOCAL_QEMU_REAL_ASSET_SECONDS)" pi4-local-qemu-input-smoke
	@set -e; \
	for status in "$(PI4_LOCAL_QEMU_DOOM_STATUS_RAW)" "$(PI4_LOCAL_QEMU_QUAKE_STATUS_RAW)"; do \
		grep -a -F -q "pi4vfs=OK" "$$status" || { echo "Pi 4 real-assets smoke missing pi4vfs=OK in $$status" >&2; cat "$$status" >&2; exit 1; }; \
		grep -a -E -q '(^| )pi4wad=0x[0-9A-Fa-f]+(/0x[0-9A-Fa-f]+){7}( |$$)' "$$status" || { echo "Pi 4 real-assets smoke missing full pi4wad read tuple in $$status" >&2; cat "$$status" >&2; exit 1; }; \
		grep -a -E -q '(^| )pi4pak0=0x[0-9A-Fa-f]+(/0x[0-9A-Fa-f]+){7}( |$$)' "$$status" || { echo "Pi 4 real-assets smoke missing full pi4pak0 read tuple in $$status" >&2; cat "$$status" >&2; exit 1; }; \
	done
	@grep -a -F -q "pi4exec=OK" "$(PI4_LOCAL_QEMU_DOOM_STATUS_RAW)"
	@grep -a -E -q '(^| )pi4appreq=0x[0-9a-fA-F]+/0x0*1/0x0*20/0x[0-9a-fA-F]+/0x0*12/0x0*c( |$$)' "$(PI4_LOCAL_QEMU_DOOM_STATUS_RAW)"
	@grep -a -F -q "pi4exec=OK" "$(PI4_LOCAL_QEMU_QUAKE_STATUS_RAW)"
	@grep -a -E -q '(^| )pi4appreq=0x[0-9a-fA-F]+/0x0*1/0x0*20/0x[0-9a-fA-F]+/0x0*13/0x0*d( |$$)' "$(PI4_LOCAL_QEMU_QUAKE_STATUS_RAW)"
	@printf "Pi 4 local QEMU real-assets input smoke OK: full WAD/PAK FAT/VFS reads and Doom/Quake launcher execs validated from captured serial status.\n"

pi4-local-qemu-real-assets-final-gates: pi4-local-qemu-real-assets-input-smoke $(VIBE_STATUS_CHECK)
	@set -e; \
		doom_audio="$$(tr ' ' '\n' < "$(PI4_LOCAL_QEMU_DOOM_STATUS_RAW)" | sed -n 's/^pi4audio=//p' | tail -n 1)"; \
		quake_audio="$$(tr ' ' '\n' < "$(PI4_LOCAL_QEMU_QUAKE_STATUS_RAW)" | sed -n 's/^pi4audio=//p' | tail -n 1)"; \
		doom_fb0="$$(sed -n 's/^frame0_hash=//p' "$(PI4_LOCAL_QEMU_DOOM_FB_REPORT)" | tail -n 1)"; \
		doom_fb1="$$(sed -n 's/^frame1_hash=//p' "$(PI4_LOCAL_QEMU_DOOM_FB_REPORT)" | tail -n 1)"; \
		quake_fb0="$$(sed -n 's/^frame0_hash=//p' "$(PI4_LOCAL_QEMU_QUAKE_FB_REPORT)" | tail -n 1)"; \
		quake_fb1="$$(sed -n 's/^frame1_hash=//p' "$(PI4_LOCAL_QEMU_QUAKE_FB_REPORT)" | tail -n 1)"; \
		case "$$doom_audio:$$quake_audio" in \
			*HARDWARE-UNPROVEN*|*WAIT*) audio_gate=hardware-unproven ;; \
			OK:OK) echo "local QEMU captured pi4audio=OK; refusing final gates because audio OK requires real Pi hardware evidence" >&2; exit 1 ;; \
			*) echo "unknown captured Pi 4 audio states: doom=$$doom_audio quake=$$quake_audio" >&2; exit 1 ;; \
		esac; \
		printf "storage=green\n" > "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"; \
		printf "storage_assets=real-wad-and-pak\n" >> "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"; \
		printf "storage_status_fields=pi4wad,pi4pak0\n" >> "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"; \
		printf "launcher_doom_exec=green\n" >> "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"; \
		printf "launcher_quake_exec=green\n" >> "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"; \
		printf "input=green\n" >> "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"; \
		printf "graphics=green\n" >> "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"; \
		printf "process=green\n" >> "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"; \
		printf "memory=green\n" >> "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"; \
		printf "preemption=green\n" >> "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"; \
		printf "audio=%s\n" "$$audio_gate" >> "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"; \
		printf "hardware=unclaimed\n" >> "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"; \
		printf "green_gate=false\n" >> "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"; \
		printf "hardware_proof=unclaimed\n" >> "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"; \
		printf "evidence_class=local-qemu-final-gates\n" >> "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"; \
		printf "framebuffer_artifact=green\n" >> "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"; \
		printf "framebuffer_artifact_source=qemu-screendump\n" >> "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"; \
		printf "doom_framebuffer_artifact=green\n" >> "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"; \
		printf "doom_framebuffer_report=%s\n" "$(PI4_LOCAL_QEMU_DOOM_FB_REPORT)" >> "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"; \
		printf "doom_framebuffer_frame0_hash=%s\n" "$$doom_fb0" >> "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"; \
		printf "doom_framebuffer_frame1_hash=%s\n" "$$doom_fb1" >> "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"; \
		printf "quake_framebuffer_artifact=green\n" >> "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"; \
		printf "quake_framebuffer_report=%s\n" "$(PI4_LOCAL_QEMU_QUAKE_FB_REPORT)" >> "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"; \
		printf "quake_framebuffer_frame0_hash=%s\n" "$$quake_fb0" >> "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"; \
		printf "quake_framebuffer_frame1_hash=%s\n" "$$quake_fb1" >> "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"; \
		printf "capture_audio_doom=%s\n" "$$doom_audio" >> "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"; \
		printf "capture_audio_quake=%s\n" "$$quake_audio" >> "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"; \
		printf "single_artifact=green\n" >> "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"; \
		printf "single_artifact_image=%s\n" "$(PI4_REAL_ASSET_PROOF_IMAGE)" >> "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"; \
		printf "single_artifact_sha256=%s\n" "$$(cut -d ' ' -f 1 "$(PI4_LOCAL_QEMU_IMAGE_SHA_AFTER)")" >> "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"; \
		printf "single_artifact_inspect=%s\n" "$(PI4_REAL_ASSET_PROOF_IMAGE_INSPECT_TXT)" >> "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"; \
		printf "doom_serial=%s\n" "$(PI4_LOCAL_QEMU_DOOM_SERIAL)" >> "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"; \
		printf "doom_status=%s\n" "$(PI4_LOCAL_QEMU_DOOM_STATUS_RAW)" >> "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"; \
		printf "quake_serial=%s\n" "$(PI4_LOCAL_QEMU_QUAKE_SERIAL)" >> "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"; \
		printf "quake_status=%s\n" "$(PI4_LOCAL_QEMU_QUAKE_STATUS_RAW)" >> "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"
	@$(VIBE_STATUS_CHECK) --pi4-final-gates "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)" "$(PI4_LOCAL_QEMU_DOOM_STATUS_RAW)" "$(PI4_LOCAL_QEMU_QUAKE_STATUS_RAW)" "$(PI4_LOCAL_QEMU_DOOM_STATUS)" "$(PI4_LOCAL_QEMU_QUAKE_STATUS)"
	@cat "$(PI4_LOCAL_QEMU_REAL_ASSETS_FINAL_GATES)"

pi4-hw-equivalent-qemu-args:
	@printf '%s\n' '$(PI4_HW_EQUIVALENT_QEMU_ARGS)'

pi4-hw-equivalent-qemu-command:
	@printf '%s %s\n' '$(PI4_HW_EQUIVALENT_QEMU)' '$(PI4_HW_EQUIVALENT_QEMU_ARGS)'

pi4-hw-equivalent-real-assets-qemu-command: $(PI4_HW_EQUIVALENT_REAL_ASSET_IMAGE_DEPS)
	@$(MAKE) --no-print-directory PI4_HW_EQUIVALENT_IMAGE="$(PI4_HW_EQUIVALENT_REAL_ASSET_IMAGE)" PI4_HW_EQUIVALENT_SERIAL="$(PI4_HW_EQUIVALENT_SERIAL)" pi4-hw-equivalent-qemu-command

pi4-hw-equivalent-real-assets-input-smoke: $(PI4_HW_EQUIVALENT_REAL_ASSET_IMAGE_DEPS)
	@set -e; \
	asset_paths="$$(VIBE_ASSET_CACHE_DIR="$(REAL_ASSET_CACHE_DIR)" tools/prepare_game_assets.sh --format paths)"; \
	doom_wad="$$(printf "%s\n" "$$asset_paths" | sed -n '1p')"; \
	quake_pak="$$(printf "%s\n" "$$asset_paths" | sed -n '2p')"; \
	test -n "$$doom_wad" || { echo "prepare helper did not return DOOM_WAD" >&2; exit 1; }; \
	test -n "$$quake_pak" || { echo "prepare helper did not return QUAKE_PAK" >&2; exit 1; }; \
	$(REAL_ASSET_SUBBUILD) --no-print-directory ALLOW_LOCAL_VM="$(ALLOW_LOCAL_VM)" DOOM_WAD="$$doom_wad" QUAKE_PAK="$$quake_pak" PI4_REAL_ASSET_PROOF_IMAGE="$(PI4_HW_EQUIVALENT_REAL_ASSET_IMAGE)" PI4_REAL_ASSET_PROOF_IMAGE_INSPECT_TXT="$(PI4_HW_EQUIVALENT_REAL_ASSET_IMAGE_INSPECT_TXT)" PI4_APP_DOOM_ELF="$(PI4_DOOM_ENGINE_ELF)" PI4_APP_QUAKE_ELF="$(QUAKE_PI4_ENGINE_ELF)" PI4_LOCAL_QEMU_REAL_ASSET_SECONDS="$(PI4_HW_EQUIVALENT_REAL_ASSET_SECONDS)" pi4-local-qemu-real-assets-input-smoke

pi4-hw-equivalent-real-assets-final-gates: $(PI4_HW_EQUIVALENT_REAL_ASSET_IMAGE_DEPS)
	@$(MAKE) --no-print-directory ALLOW_LOCAL_VM="$(ALLOW_LOCAL_VM)" PI4_REAL_ASSET_PROOF_IMAGE="$(PI4_HW_EQUIVALENT_REAL_ASSET_IMAGE)" PI4_REAL_ASSET_PROOF_IMAGE_INSPECT_TXT="$(PI4_HW_EQUIVALENT_REAL_ASSET_IMAGE_INSPECT_TXT)" PI4_LOCAL_QEMU_REAL_ASSET_SECONDS="$(PI4_HW_EQUIVALENT_REAL_ASSET_SECONDS)" pi4-prepared-real-assets-final-gates

pi4-hw-equivalent-real-assets-run:
	@$(MAKE) --no-print-directory ALLOW_LOCAL_VM="$(ALLOW_LOCAL_VM)" PI4_HW_EQUIVALENT_IMAGE="$(PI4_HW_EQUIVALENT_REAL_ASSET_IMAGE)" PI4_HW_EQUIVALENT_IMAGE_DEPS="$(PI4_HW_EQUIVALENT_REAL_ASSET_IMAGE_DEPS)" pi4-hw-equivalent-run

pi4-hw-equivalent-run:
	@if [ "$(ALLOW_LOCAL_VM)" != "1" ]; then \
		echo "Local Pi 4 hardware-equivalent QEMU execution is disabled by default."; \
		echo "This target is a user handoff only and is not real Raspberry Pi hardware proof."; \
		echo "Inspect the exact command with: make pi4-hw-equivalent-qemu-command"; \
		echo "Prepare and inspect the exact real WAD/PAK Pi image with: make pi4-qemu-prep"; \
		echo "For allowed remote visible play from this Mac: make pi4-remote-visible-play-help"; \
		echo "Rerun with ALLOW_LOCAL_VM=1 to boot the local/user QEMU emulator."; \
		exit 1; \
	fi
	@if [ -n "$(strip $(PI4_HW_EQUIVALENT_IMAGE_DEPS))" ]; then \
		$(MAKE) --no-print-directory $(PI4_HW_EQUIVALENT_IMAGE_DEPS); \
	fi
	@test -s "$(PI4_HW_EQUIVALENT_IMAGE)" || { echo "missing exact Pi 4 boot image: $(PI4_HW_EQUIVALENT_IMAGE)" >&2; exit 1; }
	@printf "Booting exact Pi 4 image: %s\n" "$(PI4_HW_EQUIVALENT_IMAGE)"
	@printf "Starting local/user Pi 4 hardware-equivalent QEMU emulator; real Raspberry Pi hardware proof remains unclaimed.\n"
	@printf "Serial status evidence still must pass tools/pi4_status_evidence or the GitHub Actions hardware-equivalent lane.\n"
	$(PI4_HW_EQUIVALENT_QEMU) $(PI4_HW_EQUIVALENT_QEMU_ARGS)

pi4-image-inspect: $(IMAGE_BUILDER) $(PI4_IMAGE)
	$(IMAGE_BUILDER) $(PI4_IMAGE_INSPECT_REAL_ASSET_ARGS) --inspect "$(PI4_IMAGE)" > "$(PI4_IMAGE_INSPECT_TXT)"
	@cat "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -q "path=PROOF/MANIFEST.TXT" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -q "manifest_path=/PROOF/MANIFEST.TXT state=present" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -q "manifest_file=KERNEL8.IMG state=present" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -q "manifest_file=CONFIG.TXT state=present" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -q "manifest_file=INIT.ELF state=present" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -q "manifest_file=ABIPROBE.ELF state=present" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "app_layout=system-init-plus-apps-tree" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "app_discovery_model=vfs-app-index" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "app_launch_model=generic-vfs-path-exec" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "app_exec_model=generic-aarch64-el0-elf-by-path" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "system_init=/SYSTEM/INIT.ELF" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "system_abiprobe=/SYSTEM/ABIPROBE.ELF" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "manifest_file=/SYSTEM/INIT.ELF state=present" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "manifest_file=/SYSTEM/ABIPROBE.ELF state=present" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "app_index=/APPS/INDEX.TXT" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "manifest_file=/APPS/INDEX.TXT state=present" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "app_index_manifest=/APPS/INDEX.TXT state=present" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "app.0.id=doom" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "app.0.name=DOOM" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "app.0.manifest=/APPS/DOOM/APP.TXT" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "app.0.exec=/APPS/DOOM/APP.ELF" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "app.0.launch=generic-path-exec" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "app.0.exec_model=generic-aarch64-el0-elf-by-path" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "app.0.resource=/DOOM1.WAD" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "app.0.icon=wad:TITLEPIC" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "manifest_file=/APPS/DOOM/APP.TXT state=present" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "manifest_file=/APPS/DOOM/APP.ELF state=present" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "app_manifest=/APPS/DOOM/APP.TXT state=present" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "app_exec=/APPS/DOOM/APP.ELF state=present model=generic-aarch64-el0-elf-by-path app=doom" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "app_icon=wad:TITLEPIC state=manifest app=doom" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "app_resource=/DOOM1.WAD state=present app=doom" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "app.1.id=quake" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "app.1.name=Quake" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "app.1.manifest=/APPS/QUAKE/APP.TXT" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "app.1.exec=/APPS/QUAKE/APP.ELF" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "app.1.launch=generic-path-exec" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "app.1.exec_model=generic-aarch64-el0-elf-by-path" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "app.1.resource=/ID1/PAK0.PAK" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "app.1.icon=pak:gfx/conback.lmp" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "manifest_file=/APPS/QUAKE/APP.TXT state=present" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "manifest_file=/APPS/QUAKE/APP.ELF state=present" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "app_manifest=/APPS/QUAKE/APP.TXT state=present" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "app_exec=/APPS/QUAKE/APP.ELF state=present model=generic-aarch64-el0-elf-by-path app=quake" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -F -q "app_icon=pak:gfx/conback.lmp state=manifest app=quake" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -q "manifest_file=DOOM1.WAD state=present" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -q "manifest_file=/ASSETS/README.TXT state=present" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -q "manifest_file=/ASSETS/MAPS/E1M1.MAP state=present" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -q "manifest_file=/ASSETS/TEXTURES/PAL0.BIN state=present" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -q "pi4_manifest=OK" "$(PI4_IMAGE_INSPECT_TXT)"
	@if [ "$(PI4_REQUIRE_REAL_ASSETS)" = "1" ]; then \
		grep -q "real_asset_manifest=OK" "$(PI4_IMAGE_INSPECT_TXT)"; \
		grep -q "checked_files_include_pak=true" "$(PI4_IMAGE_INSPECT_TXT)"; \
		grep -q "manifest_file=/ID1/PAK0.PAK state=present" "$(PI4_IMAGE_INSPECT_TXT)"; \
	fi
	@grep -a -q "schema=vibe-os-pi4-image-manifest-v1" "$(PI4_IMAGE)"
	@grep -a -q "kernel_file=KERNEL8.IMG" "$(PI4_IMAGE)"
	@grep -a -q "config_file=CONFIG.TXT" "$(PI4_IMAGE)"
	@grep -a -q "app_layout=system-init-plus-apps-tree" "$(PI4_IMAGE)"
	@grep -a -q "app_discovery_model=vfs-app-index" "$(PI4_IMAGE)"
	@grep -a -q "app_exec_model=generic-aarch64-el0-elf-by-path" "$(PI4_IMAGE)"
	@grep -a -q "system_init=/SYSTEM/INIT.ELF" "$(PI4_IMAGE)"
	@grep -a -q "system_abiprobe=/SYSTEM/ABIPROBE.ELF" "$(PI4_IMAGE)"
	@grep -a -q "app_index=/APPS/INDEX.TXT" "$(PI4_IMAGE)"
	@grep -a -q "app.0.manifest=/APPS/DOOM/APP.TXT" "$(PI4_IMAGE)"
	@grep -a -q "app.0.exec=/APPS/DOOM/APP.ELF" "$(PI4_IMAGE)"
	@grep -a -q "app.0.exec_model=generic-aarch64-el0-elf-by-path" "$(PI4_IMAGE)"
	@grep -a -q "app.0.icon=wad:TITLEPIC" "$(PI4_IMAGE)"
	@grep -a -q "app.1.manifest=/APPS/QUAKE/APP.TXT" "$(PI4_IMAGE)"
	@grep -a -q "app.1.exec=/APPS/QUAKE/APP.ELF" "$(PI4_IMAGE)"
	@grep -a -q "app.1.exec_model=generic-aarch64-el0-elf-by-path" "$(PI4_IMAGE)"
	@grep -a -q "app.1.icon=pak:gfx/conback.lmp" "$(PI4_IMAGE)"
	@grep -a -E -q "root_elf_count=2" "$(PI4_IMAGE)"
	@grep -a -E -q "root_elf\.[0-9]+\.file=INIT\.ELF" "$(PI4_IMAGE)"
	@grep -a -E -q "root_elf\.[0-9]+\.file=ABIPROBE\.ELF" "$(PI4_IMAGE)"
	@grep -q "primary_asset_file=DOOM1.WAD" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -q "primary_asset_kind=doom-wad" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -q "primary_asset_state=present" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -q "primary_asset_evidence=packaged-file-only" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -q "primary_asset_hardware_proof=unclaimed" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -E -q "primary_asset_size=[1-9][0-9]*" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -a -q "default_asset_count=3" "$(PI4_IMAGE)"
	@grep -a -q "default_asset.0.file=/ASSETS/README.TXT" "$(PI4_IMAGE)"
	@grep -a -E -q "default_asset.0.size=[1-9][0-9]*" "$(PI4_IMAGE)"
	@grep -a -q "default_asset.1.file=/ASSETS/MAPS/E1M1.MAP" "$(PI4_IMAGE)"
	@grep -a -E -q "default_asset.1.size=[1-9][0-9]*" "$(PI4_IMAGE)"
	@grep -a -q "default_asset.2.file=/ASSETS/TEXTURES/PAL0.BIN" "$(PI4_IMAGE)"
	@grep -a -E -q "default_asset.2.size=[1-9][0-9]*" "$(PI4_IMAGE)"
	@if [ -n "$(PRIMARY_ASSET)" ]; then \
		grep -q "primary_asset_source=external" "$(PI4_IMAGE_INSPECT_TXT)"; \
		grep -q "primary_asset_repo_state=outside-repo" "$(PI4_IMAGE_INSPECT_TXT)"; \
	else \
		grep -q "primary_asset_source=generated-fixture" "$(PI4_IMAGE_INSPECT_TXT)"; \
		grep -q "primary_asset_repo_state=generated-by-builder" "$(PI4_IMAGE_INSPECT_TXT)"; \
	fi
	@grep -q "quake_pak_file=/ID1/PAK0.PAK" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -q "quake_pak_kind=quake-pak" "$(PI4_IMAGE_INSPECT_TXT)"
	@grep -q "quake_pak_hardware_proof=unclaimed" "$(PI4_IMAGE_INSPECT_TXT)"
	@if [ -n "$(SECONDARY_PACKAGE)" ]; then \
		grep -q "quake_pak_state=present" "$(PI4_IMAGE_INSPECT_TXT)"; \
		grep -q "quake_pak_source=external" "$(PI4_IMAGE_INSPECT_TXT)"; \
		grep -q "quake_pak_repo_state=outside-repo" "$(PI4_IMAGE_INSPECT_TXT)"; \
		grep -q "quake_pak_evidence=packaged-file-only" "$(PI4_IMAGE_INSPECT_TXT)"; \
		grep -E -q "quake_pak_size=[1-9][0-9]*" "$(PI4_IMAGE_INSPECT_TXT)"; \
		grep -q "asset_count=1" "$(PI4_IMAGE_INSPECT_TXT)"; \
		grep -q "asset.0.file=/ID1/PAK0.PAK" "$(PI4_IMAGE_INSPECT_TXT)"; \
		grep -q "asset.0.kind=quake-pak0" "$(PI4_IMAGE_INSPECT_TXT)"; \
		grep -q "asset.0.source=external-host-input" "$(PI4_IMAGE_INSPECT_TXT)"; \
		grep -q "asset.0.repo_state=outside-repo" "$(PI4_IMAGE_INSPECT_TXT)"; \
		grep -q "asset.0.evidence=packaged-file-only" "$(PI4_IMAGE_INSPECT_TXT)"; \
		grep -q "asset.0.hardware_proof=unclaimed" "$(PI4_IMAGE_INSPECT_TXT)"; \
		grep -F -q "app_resource=/ID1/PAK0.PAK state=present app=quake" "$(PI4_IMAGE_INSPECT_TXT)"; \
	else \
		grep -q "quake_pak_state=absent" "$(PI4_IMAGE_INSPECT_TXT)"; \
		grep -q "quake_pak_source=absent" "$(PI4_IMAGE_INSPECT_TXT)"; \
		grep -q "quake_pak_repo_state=absent" "$(PI4_IMAGE_INSPECT_TXT)"; \
		grep -q "quake_pak_evidence=absent" "$(PI4_IMAGE_INSPECT_TXT)"; \
		grep -q "asset_count=0" "$(PI4_IMAGE_INSPECT_TXT)"; \
		grep -F -q "app_resource=/ID1/PAK0.PAK state=absent app=quake" "$(PI4_IMAGE_INSPECT_TXT)"; \
		! grep -q "quake_pak_source=external" "$(PI4_IMAGE_INSPECT_TXT)"; \
	fi

$(PI4_STATUS_EVIDENCE_OK): Makefile tests/fixtures/pi4_status_hardware_evidence_ok.txt FORCE | $(PI4_BUILD_DIR)
	@cp tests/fixtures/pi4_status_hardware_evidence_ok.txt $@
	@if ! grep -q 'app_launch_claim=' $@; then \
		awk 'BEGIN { done = 0 } /^vibe-status([ \t]|$$)/ && !done { print $$0 " app_launch_claim=none"; done = 1; next } { print } END { if (!done) exit 1 }' $@ > $@.tmp; \
		mv $@.tmp $@; \
	fi

pi4-status-evidence-ok-fixture: $(PI4_STATUS_EVIDENCE_OK)
	@printf "Generated Pi 4 status evidence fixture %s\n" "$(PI4_STATUS_EVIDENCE_OK)"

pi4-status-evidence-check: $(PI4_STATUS_EVIDENCE) $(PI4_STATUS_EVIDENCE_OK)
	$(PI4_STATUS_EVIDENCE) $(PI4_STATUS_EVIDENCE_OK)
	@{ \
		printf '%s\n' 'uart: boot banner before the first status line'; \
		printf '%s\n' 'vibe-status arch=AARCH64 machine=PI4 image=PI4 artifact=BAD'; \
		printf '%s\n' 'uart: later capture contains the real guest status'; \
		cat $(PI4_STATUS_EVIDENCE_OK); \
		printf '%s\n' 'uart: trailing monitor prompt'; \
	} > $(PI4_STATUS_SERIAL_LAST_OK)
	$(PI4_STATUS_EVIDENCE) $(PI4_STATUS_SERIAL_LAST_OK)
	@{ \
		cat $(PI4_STATUS_EVIDENCE_OK); \
		printf '%s\n' 'uart: stale good status above must not mask the final line'; \
		printf '%s\n' 'vibe-status arch=AARCH64 machine=PI4 image=PI4 artifact=BAD'; \
	} > $(PI4_STATUS_SERIAL_LAST_BAD)
	@if $(PI4_STATUS_EVIDENCE) $(PI4_STATUS_SERIAL_LAST_BAD) >/tmp/vibe-pi4-status-evidence-serial-last-bad.out 2>&1; then \
		echo "pi4_status_evidence accepted stale serial evidence instead of validating the last vibe-status line" >&2; \
		cat /tmp/vibe-pi4-status-evidence-serial-last-bad.out >&2; \
		exit 1; \
	fi
	@if $(PI4_STATUS_EVIDENCE) tests/fixtures/pi4_status_bad_irq_overclaim.txt >/tmp/vibe-pi4-status-evidence-bad.out 2>&1; then \
		echo "pi4_status_evidence accepted premature pi4irq=OK without timer/IRQ proof" >&2; \
		cat /tmp/vibe-pi4-status-evidence-bad.out >&2; \
		exit 1; \
	fi
	@rm -f /tmp/vibe-pi4-status-evidence-bad.out
	@rm -f /tmp/vibe-pi4-status-evidence-serial-last-bad.out

pi4-host-artifact-policy:
	@set -e; \
	workflow=".github/workflows/pi4-host-check.yml"; \
	makefile="Makefile"; \
	ignore_file=".gitignore"; \
	test -s "$$workflow" || { echo "missing Pi 4 host workflow: $$workflow" >&2; exit 1; }; \
	test -s "$$ignore_file" || { echo "missing artifact ignore policy: $$ignore_file" >&2; exit 1; }; \
	for ignored_path in \
		build/pi4/kernel8.img \
		build/pi4/pi4-fat16.img \
		build/pi4/pi4-image-inspect.txt \
		build/pi4/pi4-real-assets-fat16.img \
		build/pi4/pi4-real-assets-image-inspect.txt \
		build/pi4/pi4-real-assets-handoff.txt \
		build/pi4/pi4-status-serial-last-ok.txt \
		build/pi4/pi4-status-serial-last-bad.txt \
		build/pi4/pi4-qemu.log \
		build/pi4-hw-equivalent/serial.capture \
		build/pi4-hw-equivalent/doom.serial.capture \
		build/pi4-hw-equivalent/doom-local-qemu-status.raw \
		build/pi4-hw-equivalent/doom-local-qemu-status.marked \
		build/pi4-hw-equivalent/doom-framebuffer.report \
		build/pi4-hw-equivalent/doom-framebuffer-frame0.ppm \
		build/pi4-hw-equivalent/doom-framebuffer-frame1.ppm \
		build/pi4-hw-equivalent/quake.serial.capture \
		build/pi4-hw-equivalent/quake-local-qemu-status.raw \
		build/pi4-hw-equivalent/quake-local-qemu-status.marked \
		build/pi4-hw-equivalent/quake-framebuffer.report \
		build/pi4-hw-equivalent/quake-framebuffer-frame0.ppm \
		build/pi4-hw-equivalent/quake-framebuffer-frame1.ppm \
		build/pi4-hw-equivalent/serial.status \
		build/pi4-hw-equivalent/status.json \
		build/pi4-evidence-summary.txt \
		build/pi4-host-proof.json; do \
		git check-ignore -q -- "$$ignored_path" || { \
			printf "generated host artifact must stay ignored by %s: %s\n" "$$ignore_file" "$$ignored_path" >&2; \
			exit 1; \
		}; \
	done; \
	if grep -nE 'q[e]mu-system|ALLOW_LOCAL_[V]M=1|make[[:space:]].*s[m]oke|run-[h]eadless|make[[:space:]].*r[u]n' "$$workflow"; then \
		echo "pi4-host-check.yml must not invoke emulator, VM, smoke, or local run proof paths." >&2; \
		exit 1; \
	fi; \
	upload_count="$$(grep -c 'uses: actions/upload-artifact@v[4]' "$$workflow")"; \
	if [ "$$upload_count" != "1" ]; then \
		echo "pi4-host-check.yml must keep exactly one artifact upload step." >&2; \
		exit 1; \
	fi; \
	grep -q '^[[:space:]]*make no-python-check$$' "$$workflow"; \
	grep -q '^[[:space:]]*make pi4-assembly-source-gate$$' "$$workflow"; \
	grep -q 'r[u]n: make x86-preservation-host-check' "$$workflow"; \
	grep -q 'r[u]n: make pi4-code-gates' "$$workflow"; \
	grep -q 'r[u]n: make pi4-hw-equivalent-final-gates-policy' "$$workflow"; \
	grep -q 'r[u]n: make pi4-host-proof-json' "$$workflow"; \
	grep -q 'name: pi4-host-check-status' "$$workflow"; \
	grep -q 'path: build/pi4-host-proof.json' "$$workflow"; \
	grep -q '"proof_scope": "host-handoff-only"' "$$makefile"; \
	grep -q '"hardware_equivalent_status": "unclaimed"' "$$makefile"; \
	grep -q '"hardware_equivalent_status_requires_serial_parser": true' "$$makefile"; \
	grep -q '"serial_parser_passed": false' "$$makefile"; \
	grep -q '"handoff_paths_repo_relative_only": true' "$$makefile"; \
	if grep -nE 'path:[[:space:]]*build/pi4(/|[[:space:]]|$$)' "$$workflow"; then \
		echo "pi4-host-check.yml must not upload generated build/pi4 images, logs, or captures." >&2; \
		exit 1; \
	fi; \
	if grep -nEi 'path: .*\.(img|iso|log|txt|png|ppm|bmp|wav|raw|pak|wad)([[:space:]]|$$)' "$$workflow"; then \
		echo "pi4-host-check.yml must not upload images, logs, assets, or raw captures." >&2; \
		exit 1; \
	fi; \
	printf "Pi 4 host artifact policy OK: generated images/logs stay ignored and status JSON is the only uploaded artifact.\n"

pi4-hw-equivalent-artifact-policy:
	@set -e; \
	workflow=".github/workflows/pi4-hw-equivalent.yml"; \
	makefile="Makefile"; \
	test -s "$$workflow" || { echo "missing Pi 4 hardware-equivalent workflow: $$workflow" >&2; exit 1; }; \
	grep -q '^PI4_HW_EQUIVALENT_QEMU ?= q[e]mu-system-aarch64' "$$makefile"; \
	grep -q '^PI4_HW_EQUIVALENT_IMAGE ?= $$(PI4_EXACT_BOOT_IMAGE)' "$$makefile"; \
	grep -q '^PI4_HW_EQUIVALENT_IMAGE_DEPS ?= $$(PI4_EXACT_BOOT_IMAGE_DEPS)' "$$makefile"; \
	grep -q '^PI4_HW_EQUIVALENT_REAL_ASSET_IMAGE ?= $$(PI4_EXACT_BOOT_IMAGE)' "$$makefile"; \
	grep -q '^PI4_LOCAL_QEMU_LIVE_IMAGE_DEPS ?= $$(PI4_EXACT_BOOT_IMAGE_DEPS)' "$$makefile"; \
	grep -q '^PI4_LOCAL_QEMU_LIVE_IMAGE = $$(PI4_EXACT_BOOT_IMAGE)' "$$makefile"; \
	grep -q '^PI4_HW_EQUIVALENT_QEMU_ARGS := .*raspi4b.*$$(PI4_KERNEL8_IMG).*file=$$(PI4_HW_EQUIVALENT_IMAGE).*$$(PI4_HW_EQUIVALENT_SERIAL).*' "$$makefile"; \
	grep -q '^pi4-hw-equivalent-qemu-command:' "$$makefile"; \
	grep -q '^pi4-qemu-command: $$(PI4_QEMU_COMMAND) $$(PI4_EXACT_BOOT_IMAGE_DEPS)' "$$makefile"; \
	grep -q '^pi4-hw-equivalent-run:' "$$makefile"; \
	grep -q '^pi4-hw-equivalent-real-assets-final-gates:' "$$makefile"; \
	grep -q 'prepared Pi 4 exact handoff drift' "$$makefile"; \
	grep -q 'manifest_doom_app_exec_size_matches_file=yes' "$$makefile"; \
	grep -q 'manifest_quake_app_exec_size_matches_file=yes' "$$makefile"; \
	grep -q 'Rerun with ALLOW_LOCAL_VM=1 to boot the local/user QEMU emulator' "$$makefile"; \
	grep -q 'q[e]mu-system-aarch64' "$$workflow"; \
	grep -q 'G[I]THUB_ACTIONS' "$$workflow"; \
	grep -q 'raspi4b' "$$workflow"; \
	grep -q 'make --no-print-directory PI4_HW_EQUIVALENT_SERIAL="file:$$serial_capture" pi4-hw-equivalent-qemu-command' "$$workflow"; \
	grep -q 'make pi4-prepared-real-assets-image' "$$workflow"; \
	grep -q 'make build/vibe_status_check' "$$workflow"; \
	grep -q 'PI4_HW_EQUIVALENT_IMAGE="$$real_asset_image"' "$$workflow"; \
	grep -q 'build/pi4_status_evidence' "$$workflow"; \
	grep -q 'build/pi4_qemu_command' "$$workflow"; \
	grep -q 'build/vibe_status_check --pi4-final-gates "$$final_gates_file"' "$$workflow"; \
	grep -q 'build/vibe_status_check --pi4-final-gates-single-artifact "$$final_gates_file" "$$image_sha_after"' "$$workflow"; \
	grep -q -- '--local-input-framebuffer-smoke' "$$workflow"; \
	grep -q '"real_hardware_proof": "unclaimed"' "$$workflow"; \
	grep -q '"local_user_qemu_real_hardware_proof": false' "$$workflow"; \
	grep -q '"qemu_command_matches_user_handoff": true' "$$workflow"; \
	grep -q '"serial_parser_passed":' "$$workflow"; \
	grep -q '"framebuffer_artifact": {' "$$workflow"; \
	grep -q '"contains_framebuffer_hashes": true' "$$workflow"; \
	grep -q '"single_artifact": {' "$$workflow"; \
	grep -q '"sha256_before": "$$image_sha_before"' "$$workflow"; \
	grep -q '"sha256_after": "$$image_sha_after"' "$$workflow"; \
	grep -q '"image_sha_stable": $$single_artifact_stable' "$$workflow"; \
	grep -q '"final_gates": {' "$$workflow"; \
	grep -q '"storage": $$storage_read_gate_passed' "$$workflow"; \
	grep -q '"framebuffer": $$framebuffer_final_gate_passed' "$$workflow"; \
	grep -q '"single_artifact": $$single_artifact_stable' "$$workflow"; \
	grep -q '"audio": "unclaimed"' "$$workflow"; \
	grep -q '"hardware": "unclaimed"' "$$workflow"; \
	grep -q '"green_gate": false' "$$workflow"; \
	upload_count="$$(grep -c 'uses: actions/upload-artifact@v[4]' "$$workflow")"; \
	if [ "$$upload_count" != "1" ]; then \
		echo "pi4-hw-equivalent.yml must keep exactly one artifact upload step." >&2; \
		exit 1; \
	fi; \
	grep -q 'name: pi4-hw-equivalent-status' "$$workflow"; \
	grep -q 'path: build/pi4-hw-equivalent/status.json' "$$workflow"; \
	if grep -nE 'path:[[:space:]]*build/pi4(/|[[:space:]]|$$)' "$$workflow"; then \
		echo "pi4-hw-equivalent.yml must not upload generated build/pi4 images, logs, or captures." >&2; \
		exit 1; \
	fi; \
	if grep -nEi 'path: .*\.(img|iso|log|txt|png|ppm|bmp|wav|raw|pak|wad)([[:space:]]|$$)' "$$workflow"; then \
		echo "pi4-hw-equivalent.yml must not upload images, logs, assets, or raw captures." >&2; \
		exit 1; \
	fi; \
	printf "Pi 4 hardware-equivalent artifact policy OK: status JSON is the only uploaded artifact.\n"

pi4-hw-equivalent-final-gates-policy: pi4-hw-equivalent-artifact-policy
	@set -e; \
	workflow=".github/workflows/pi4-hw-equivalent.yml"; \
	grep -q 'image_sha_before=.*real_asset_image' "$$workflow"; \
	grep -q 'image_sha_after=.*real_asset_image' "$$workflow"; \
	grep -q 'single_artifact_stable=true' "$$workflow"; \
	grep -q 'framebuffer_final_gate_passed=true' "$$workflow"; \
	grep -q 'doom_launcher_input="key=1,mousebtn=1,mousebtn=0,wait=6000,key=w"' "$$workflow"; \
	grep -q 'quake_launcher_input="key=2,mouse=127:0,mouse=127:0,mouse=127:0,mouse=127:0,mouse=127:0,mousebtn=1,mousebtn=0,wait=6000,key=s"' "$$workflow"; \
	grep -q 'tuple_component_nonzero "$$doom_input_events" 1' "$$workflow"; \
	grep -q 'tuple_component_nonzero "$$doom_input_events" 4' "$$workflow"; \
	grep -q 'tuple_component_nonzero "$$quake_input_events" 2' "$$workflow"; \
	grep -q 'tuple_component_nonzero "$$quake_input_events" 5' "$$workflow"; \
	grep -q 'visible_mouse_keyboard_gate_passed=true' "$$workflow"; \
	grep -q '"visible_mouse_keyboard_selection": $$visible_mouse_keyboard_gate_passed' "$$workflow"; \
	grep -q 'app_launch_status_fields=pi4exec,pi4execreq,pi4appreq,pi4appvfs,path,upath,pi4inputevt,fbpresent,fbchange' "$$workflow"; \
	grep -q 'audio=hardware-unproven' "$$workflow"; \
	grep -q 'audio_state="missing"' "$$workflow"; \
	grep -q 'status_value_present pi4audio' "$$workflow"; \
	grep -q '"claim": "partial hardware-equivalent storage/framebuffer status only; audio and real hardware remain unclaimed"' "$$workflow"; \
	grep -q 'Pi 4 hardware-equivalent visible input gate did not prove Doom click, Quake move/click, and gameplay key progress' "$$workflow"; \
	grep -q 'Pi 4 hardware-equivalent single-artifact gate did not preserve the Pi image hash' "$$workflow"; \
	grep -q 'local QEMU captured pi4audio=OK; refusing hardware-equivalent final gates' "$$workflow"; \
	grep -q 'raw_image_uploaded": false' "$$workflow"; \
	if grep -nEi '"(audio|hardware)": "(green|ok|claimed|real-pi)"' "$$workflow"; then \
		echo "pi4-hw-equivalent.yml must not claim audio or real hardware in the emulator final gate JSON." >&2; \
		exit 1; \
	fi; \
	printf "Pi 4 hardware-equivalent final-gate policy OK: storage/framebuffer are status-derived, single-artifact SHA is stable, and audio/hardware stay unclaimed.\n"

$(PI4_EVIDENCE_SUMMARY): Makefile .gitignore FORCE | $(BUILD_DIR)
	@set -e; \
	changed="$$(git diff --name-only -- $(PI4_EVIDENCE_SURFACE_FILES) 2>/dev/null | LC_ALL=C sort)"; \
	if [ -z "$$changed" ]; then changed="none"; fi; \
	{ \
		printf 'schema=pi4-evidence-summary-v1\n'; \
		printf 'proof_scope=generated-status-only\n'; \
		printf 'changed_surface_evidence_files:\n'; \
		printf '%s\n' "$$changed" | sed 's/^/- /'; \
		printf 'next_riskiest_missing_runtime_surface=%s\n' "$(PI4_NEXT_RISKY_RUNTIME_SURFACE)"; \
		printf 'runtime_claim=unclaimed\n'; \
		printf 'replaces_code_proof=false\n'; \
	} > "$@"; \
	bytes="$$(wc -c < "$@")"; \
	if [ "$$bytes" -gt "$(PI4_EVIDENCE_SUMMARY_MAX_BYTES)" ]; then \
		echo "$@ exceeds $(PI4_EVIDENCE_SUMMARY_MAX_BYTES) bytes" >&2; \
		exit 1; \
	fi; \
	output="$@"; \
	repo_root="$$(git rev-parse --show-toplevel)"; \
	ignore_path="$$output"; \
	case "$$output" in \
		/*) \
			case "$$output" in \
				"$$repo_root"/*) ignore_path="$${output#"$$repo_root"/}" ;; \
				*) ignore_path="" ;; \
			esac; \
			;; \
	esac; \
	if [ -n "$$ignore_path" ]; then \
		git check-ignore -q -- "$$ignore_path" || { \
			printf "generated evidence summary must stay ignored by .gitignore: %s\n" "$$output" >&2; \
			exit 1; \
		}; \
	fi

pi4-evidence-summary: $(PI4_EVIDENCE_SUMMARY)
	@cat "$(PI4_EVIDENCE_SUMMARY)"

pi4-host-check: no-python-check pi4-host-artifact-policy pi4-hw-equivalent-artifact-policy pi4-hw-equivalent-final-gates-policy pi4-code-gates pi4-kernel8 pi4-image-inspect pi4-status-evidence-check pi4-evidence-summary
	@git diff --check
	@$(MAKE) --no-print-directory PI4_FINAL_GATES_GUARD="$(PI4_HOST_FINAL_GATES_GUARD)" pi4-final-gates-single-artifact-guard
	@printf "Pi 4 host check OK: AArch64 kernel8 image and FAT16 Pi image built without local QEMU.\n"

pi4-host-proof-json: pi4-host-check
	@mkdir -p $(BUILD_DIR)
	@set -e; \
	json_escape() { printf '%s' "$$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }; \
	ref="$$(json_escape "$${GITHUB_REF_NAME:-}")"; \
	sha="$$(json_escape "$${GITHUB_SHA:-}")"; \
	run_id="$$(json_escape "$${GITHUB_RUN_ID:-}")"; \
	run_attempt="$$(json_escape "$${GITHUB_RUN_ATTEMPT:-}")"; \
	{ \
		printf '{\n'; \
		printf '  "schema": "pi4-host-proof-v1",\n'; \
		printf '  "workflow": "pi4-host-check.yml",\n'; \
		printf '  "ref": "%s",\n' "$$ref"; \
		printf '  "sha": "%s",\n' "$$sha"; \
		printf '  "run_id": "%s",\n' "$$run_id"; \
		printf '  "run_attempt": "%s",\n' "$$run_attempt"; \
		printf '  "runner": "github-actions-ubuntu",\n'; \
		printf '  "host_static_only": true,\n'; \
		printf '  "local_vm_required": false,\n'; \
		printf '  "proof_scope": "host-handoff-only",\n'; \
		printf '  "hardware_proof": "unclaimed",\n'; \
		printf '  "hardware_equivalent_status": "unclaimed",\n'; \
		printf '  "hardware_equivalent_status_requires_serial_parser": true,\n'; \
		printf '  "serial_parser_passed": false,\n'; \
		printf '  "bootable_artifact_built_and_inspected": true,\n'; \
		printf '  "uploaded_artifact_kind": "status-json-only",\n'; \
		printf '  "user_handoff": {\n'; \
		printf '    "kernel_image_path": "%s",\n' "$(PI4_KERNEL8_IMG)"; \
		printf '    "fat16_image_path": "%s",\n' "$(PI4_IMAGE)"; \
		printf '    "qemu_command_source": "make pi4-hw-equivalent-qemu-command",\n'; \
		printf '    "qemu_run_target": "make ALLOW_LOCAL_VM=1 pi4-hw-equivalent-run",\n'; \
		printf '    "local_qemu_execution": "user-opt-in-only",\n'; \
		printf '    "hardware_proof": "unclaimed"\n'; \
		printf '  },\n'; \
		printf '  "commands": [\n'; \
		printf '    "make no-python-check",\n'; \
		printf '    "make pi4-assembly-source-gate",\n'; \
		printf '    "make x86-preservation-host-check",\n'; \
		printf '    "make pi4-code-gates",\n'; \
		printf '    "make pi4-hw-equivalent-final-gates-policy",\n'; \
		printf '    "make pi4-launcher-state-manifest-check",\n'; \
		printf '    "make pi4-kernel8",\n'; \
		printf '    "sh boot/pi4/build.sh",\n'; \
		printf '    "make pi4-host-check"\n'; \
		printf '  ],\n'; \
		printf '  "code_gates": {\n'; \
		printf '    "no_python_source_tree": true,\n'; \
		printf '    "pi4_assembly_source_list_static": true,\n'; \
		printf '    "pi4_all_assembly_sources_compiled": true,\n'; \
		printf '    "pi4_user_elves_linked": true,\n'; \
		printf '    "pi4_launcher_state_manifest_static": true,\n'; \
		printf '    "pi4_kernel8_linked": true,\n'; \
		printf '    "pi4_storage_read_root_vfs_symbols_gated": true,\n'; \
		printf '    "pi4_image_inspected": true,\n'; \
		printf '    "x86_bios_image_builder_inspected": true,\n'; \
		printf '    "x86_uefi_loader_object_built": true,\n'; \
		printf '    "x86_doom_app_elf_linked": true,\n'; \
		printf '    "x86_quake_app_elf_linked": true,\n'; \
		printf '    "x86_app_tree_elves_wired": true,\n'; \
		printf '    "pi4_host_validators_compile": true,\n'; \
		printf '    "pi4_status_evidence_fixtures": true,\n'; \
		printf '    "artifact_upload_status_json_only": true,\n'; \
		printf '    "pi4_hw_equivalent_final_gate_policy": true\n'; \
		printf '  },\n'; \
		printf '  "artifact_policy": {\n'; \
		printf '    "status_only": true,\n'; \
		printf '    "contains_wad_data": false,\n'; \
		printf '    "contains_pak_data": false,\n'; \
		printf '    "contains_disk_image": false,\n'; \
		printf '    "contains_screenshots": false,\n'; \
		printf '    "contains_pixels": false,\n'; \
		printf '    "contains_raw_audio": false,\n'; \
		printf '    "contains_logs": false,\n'; \
		printf '    "handoff_paths_repo_relative_only": true,\n'; \
		printf '    "contains_secrets": false\n'; \
		printf '  }\n'; \
		printf '}\n'; \
	} > $(PI4_HOST_PROOF_JSON); \
	bytes="$$(wc -c < $(PI4_HOST_PROOF_JSON))"; \
	if [ "$$bytes" -gt "$(PI4_HOST_PROOF_MAX_BYTES)" ]; then \
		echo "$(PI4_HOST_PROOF_JSON) exceeds $(PI4_HOST_PROOF_MAX_BYTES) bytes" >&2; \
		exit 1; \
	fi; \
	if grep -nEi '"[^"]+": ".*\.(img|iso|log|txt|png|ppm|bmp|wav|raw|pak|wad)"' $(PI4_HOST_PROOF_JSON) | grep -Ev '"(kernel_image_path|fat16_image_path)": "build/pi4/(kernel8|pi4-fat16)\.img"'; then \
		echo "$(PI4_HOST_PROOF_JSON) must not point at raw images, logs, assets, captures, or media outside the user handoff image paths." >&2; \
		exit 1; \
	fi; \
	grep -q '"kernel_image_path": "build/pi4/kernel8.img"' $(PI4_HOST_PROOF_JSON); \
	grep -q '"fat16_image_path": "build/pi4/pi4-fat16.img"' $(PI4_HOST_PROOF_JSON); \
	if grep -nE '"[^"]+_path":' $(PI4_HOST_PROOF_JSON) | grep -Ev '"(kernel_image_path|fat16_image_path)":'; then \
		echo "$(PI4_HOST_PROOF_JSON) must not add non-handoff path fields." >&2; \
		exit 1; \
	fi; \
	if grep -nE '"[^"]+_path": "(/|~|[^"]*\.\.|[A-Za-z]:)' $(PI4_HOST_PROOF_JSON); then \
		echo "$(PI4_HOST_PROOF_JSON) must mention only repo-relative handoff paths." >&2; \
		exit 1; \
	fi; \
	printf "Wrote Pi 4 host status JSON %s (%s bytes).\n" "$(PI4_HOST_PROOF_JSON)" "$$bytes"

$(KERNEL_ELF): $(KERNEL_OBJ) $(C_RUNTIME_OBJ) $(LINK_ELF32) | $(BUILD_DIR)
	$(LINK_ELF32) -o $@ --base 0x10000 $(KERNEL_OBJ) $(C_RUNTIME_OBJ)
	@test $$(wc -c < $@) -le $(KERNEL_ELF_MAX_BYTES) || { echo "kernel ELF exceeds $(KERNEL_ELF_MAX_BYTES) bytes"; exit 1; }

$(USER_CRT0_OBJ): user/crt0.asm | $(BUILD_DIR)
	$(NASM) -f elf32 $< -o $@

$(USER_LAUNCHER_CRT0_OBJ): $(USER_LAUNCHER_CRT0_ASM_SRC) | $(BUILD_DIR)
	$(NASM) -f elf32 $< -o $@

$(USER_PROBE_OBJ): $(USER_PROBE_ASM_SRC) | $(BUILD_DIR)
	$(NASM) -f elf32 $< -o $@

$(USER_ABI_PROBE_OBJ): $(USER_ABI_PROBE_ASM_SRC) user/runtime.h user/include/vibe_os.h FORCE | $(BUILD_DIR)
	$(NASM) -f elf32 $(USER_ABI_PROBE_NASMFLAGS) $< -o $@

$(USER_RUNTIME_OBJ): $(USER_RUNTIME_ASM_SRC) user/runtime.h user/include/vibe_os.h | $(BUILD_DIR)
	$(NASM) -f elf32 $< -o $@

$(USER_LAUNCHER_OBJ): $(USER_LAUNCHER_ASM_SRC) | $(BUILD_DIR)
	$(NASM) -f elf32 $< -o $@

$(USER_LAUNCHER_MAIN_OBJ): $(USER_LAUNCHER_MAIN_ASM_SRC) | $(BUILD_DIR)
	$(NASM) -f elf32 $< -o $@

$(USER_LAUNCHER_ELF): $(USER_LAUNCHER_CRT0_OBJ) $(USER_RUNTIME_OBJ) $(USER_LAUNCHER_OBJ) $(USER_LAUNCHER_MAIN_OBJ) $(LINK_ELF32) | $(BUILD_DIR)
	$(LINK_ELF32) -o $@ --base 0x00e80000 $(USER_LAUNCHER_CRT0_OBJ) $(USER_RUNTIME_OBJ) $(USER_LAUNCHER_OBJ) $(USER_LAUNCHER_MAIN_OBJ)
	@test $$(wc -c < $@) -le $(INIT_APP_ELF_MAX_BYTES) || { echo "init app ELF exceeds $(INIT_APP_ELF_MAX_BYTES) bytes"; exit 1; }

$(DOOM_PORT_BUILD_DIR)/%.o: $(DOOM_SRC_DIR)/%.c Makefile | $(DOOM_PORT_BUILD_DIR)
	$(CLANG) $(DOOM_ORIGINAL_CFLAGS) -c $< -o $@

$(DOOM_PORT_BUILD_DIR)/g_game.o: $(DOOM_SRC_DIR)/g_game.c Makefile | $(DOOM_PORT_BUILD_DIR)
	$(CLANG) $(DOOM_ORIGINAL_CFLAGS) $(DOOM_G_GAME_CFLAGS) -c $< -o $@

$(DOOM_PORT_BUILD_DIR)/p_saveg.o: $(DOOM_SRC_DIR)/p_saveg.c Makefile | $(DOOM_PORT_BUILD_DIR)
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

$(QUAKE_PORT_BUILD_DIR)/%.o: $(QUAKE_SRC_DIR)/%.c Makefile | $(QUAKE_PORT_BUILD_DIR)
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

$(IMAGE): $(STAGE1_BIN) $(STAGE2_BIN) $(KERNEL_ELF) $(USER_PROBE_ELF) $(USER_LAUNCHER_ELF) $(USER_ABI_PROBE_ELF) $(DOOM_ELF) $(QUAKE_ELF) $(IMAGE_BUILDER) $(IMAGE_ASSET_DEPS) $(IMAGE_EXTRA_ROOT_ELF_DEPS) $(X86_APP_INSTALL_DEPS)
	@if [ -n "$(PRIMARY_ASSET)" ]; then \
		$(IMAGE_BUILDER) --primary-asset-wad "$(PRIMARY_ASSET)" $(IMAGE_SECONDARY_PACKAGE_ARGS) $(IMAGE_ROOT_ELF_ARGS) $(X86_APP_INSTALL_ARGS) $@ $(STAGE1_BIN) $(STAGE2_BIN) $(KERNEL_ELF) $(USER_PROBE_ELF); \
	else \
		$(IMAGE_BUILDER) $(IMAGE_SECONDARY_PACKAGE_ARGS) $(IMAGE_ROOT_ELF_ARGS) $(X86_APP_INSTALL_ARGS) $@ $(STAGE1_BIN) $(STAGE2_BIN) $(KERNEL_ELF) $(USER_PROBE_ELF); \
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
	grep -q "upath=INIT.ELF" $(BUILD_DIR)/status.txt; \
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
	printf "Smoke boot OK: protected-mode kernel status, Ring 3 probe, primary app ELF load, indexed-frame present, and PIT ticks verified in cloud VM memory.\n"

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
