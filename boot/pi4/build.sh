#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
OUT_DIR=${OUT_DIR:-/tmp/vibe-os-pi4}
START_SRC="$ROOT/boot/pi4/start.S"
INPUT_SRC="$ROOT/boot/pi4/input.S"
STORAGE_SRC="$ROOT/boot/pi4/storage.S"
LINKER_SRC="$ROOT/tools/link_aarch64_flat.c"
LINKER="$OUT_DIR/link_aarch64_flat"

shell_quote() {
    quoted=$(printf "%s" "$1" | sed "s/'/'\\\\''/g")
    printf "'%s'" "$quoted"
}

want_pi4_qemu_handoff() {
    case "${PI4_QEMU_HANDOFF:-0}" in
        1|true|TRUE|yes|YES|on|ON)
            return 0
            ;;
    esac
    case "${PRINT_QEMU:-0}" in
        1|true|TRUE|yes|YES|on|ON)
            return 0
            ;;
    esac
    return 1
}

print_pi4_qemu_handoff() {
    qemu=${PI4_QEMU:-qemu-system-aarch64}
    qemu_machine=${PI4_QEMU_MACHINE:-raspi4b}
    qemu_mem=${PI4_QEMU_MEM:-2G}
    qemu_serial=${PI4_QEMU_SERIAL:-stdio}
    qemu_display=${PI4_QEMU_DISPLAY:-none}
    qemu_extra=${PI4_QEMU_EXTRA_ARGS:-}

    printf 'pi4 artifacts:\n'
    printf '  out_dir=%s\n' "$OUT_DIR"
    printf '  kernel8_img=%s/kernel8.img\n' "$OUT_DIR"
    printf '  kernel8_map=%s/kernel8.map\n' "$OUT_DIR"
    printf '  kernel8_dis=%s/kernel8.dis\n' "$OUT_DIR"
    printf '  aggregate_source=%s/pi4-kernel.S\n' "$OUT_DIR"
    printf '  firmware_config=%s/boot/pi4/config.txt\n' "$ROOT"
    printf 'pi4 qemu handoff: this script did not run QEMU and built kernel8.img only.\n'
    printf 'pi4 proof boundary: a user-run emulator is not real Raspberry Pi hardware proof.\n'
    printf 'pi4 makefile handoff: run make pi4-qemu-prep from the repo root for the inspected FAT16 image and raspi4b command.\n'
    printf 'pi4 user-run qemu command:\n  '
    shell_quote "$qemu"
    printf ' -M '
    shell_quote "$qemu_machine"
    printf ' -m '
    shell_quote "$qemu_mem"
    printf ' -serial '
    shell_quote "$qemu_serial"
    printf ' -display '
    shell_quote "$qemu_display"
    printf ' -kernel '
    shell_quote "$OUT_DIR/kernel8.img"
    if [ -n "$qemu_extra" ]; then
        printf ' %s' "$qemu_extra"
    fi
    printf '\n'
}

find_tool() {
    for tool in "$@"; do
        if command -v "$tool" >/dev/null 2>&1; then
            command -v "$tool"
            return 0
        fi
        if command -v xcrun >/dev/null 2>&1; then
            found=$(xcrun --find "$tool" 2>/dev/null || true)
            if [ -n "$found" ]; then
                printf '%s\n' "$found"
                return 0
            fi
        fi
    done
    return 1
}

CC=${CC:-clang}
if ! command -v "$CC" >/dev/null 2>&1; then
    printf 'missing C/assembler driver: %s\n' "$CC" >&2
    exit 1
fi

if [ -z "${OBJDUMP:-}" ]; then
    OBJDUMP=$(find_tool llvm-objdump aarch64-none-elf-objdump objdump) || {
        printf 'missing objdump: install llvm-objdump or aarch64-none-elf-objdump\n' >&2
        exit 1
    }
fi

mkdir -p "$OUT_DIR"

"${HOST_CC:-cc}" -std=c99 -Wall -Wextra -Werror -O2 "$LINKER_SRC" -o "$LINKER"
"$CC" --target=aarch64-none-elf -ffreestanding -nostdlib -Wall -Wextra \
    -c "$INPUT_SRC" -o "$OUT_DIR/pi4-input.o"
"$CC" --target=aarch64-none-elf -ffreestanding -nostdlib -Wall -Wextra \
    -c "$STORAGE_SRC" -o "$OUT_DIR/pi4-storage.o"
{
    printf '.equ PI4_VIBE_DISPLAY_FD, 1\n'
    printf '.equ PI4_VIBE_EINVAL, 22\n'
    printf '.equ PI4_VIBE_INPUT_DEVICE_KEYBOARD, 1\n'
    printf '.equ PI4_VIBE_INPUT_DEVICE_MOUSE, 2\n'
    printf '.equ PI4_VIBE_INPUT_CAP_POLL_EVENT, 0x00000004\n'
    printf '.equ PI4_VIBE_INPUT_CAP_STATUS, 0x00000008\n'
    printf '.equ PI4_VIBE_INPUT_CAP_DEVICE_STATUS, 0x00000010\n'
    printf '.equ PI4_VIBE_FB_BACKEND_XRGB8888_LFB, 2\n'
    printf '.equ PI4_VIBE_FB_CAP_PRESENT_INDEXED, 0x00000001\n'
    printf '.equ PI4_VIBE_FB_CAP_PRESENT_RGB_PALETTE, 0x00000002\n'
    printf '.equ PI4_VIBE_FB_CAP_XRGB8888_LFB, 0x00000004\n'
    printf '.equ PI4_VIBE_FB_CAP_DIRTY_SOURCE_RECT, 0x00000010\n'
    printf '.equ PI4_VIBE_FB_FORMAT_INDEX8_RGB24, 1\n'
    printf '.equ PI4_VIBE_FB_RGB24_PALETTE_BYTES, 768\n'
    printf '.equ PI4_VIBE_USER_ABI_VERSION, 1\n'
    printf '.equ PI4_VIBE_INPUT_EVENT_BYTES, 56\n'
    printf '.equ PI4_VIBE_INPUT_STATUS_BYTES, 264\n'
    printf '.equ PI4_VIBE_INPUT_DEVICE_STATUS_BYTES, 128\n'
    printf '.equ PI4_VIBE_FB_INFO_BYTES, 168\n'
    printf '.global msg_status_pi4exec_tuple\n'
    printf '.global pi4_status_pi4exec_sysno\n'
    printf '.global pi4_status_pi4exec_path\n'
    printf '.global pi4_status_pi4exec_argv\n'
    printf '.global pi4_status_pi4exec_envp\n'
    printf '.global pi4_status_pi4exec_result\n'
    printf '.global pi4_status_pi4exec_count\n'
    printf '#include "%s"\n' "$START_SRC"
    printf '#include "%s"\n' "$INPUT_SRC"
    printf '#include "%s"\n' "$STORAGE_SRC"
} >"$OUT_DIR/pi4-kernel.S"
"$CC" --target=aarch64-none-elf -ffreestanding -nostdlib -Wall -Wextra \
    -DVIBE_PI4_RUNTIME_H -c "$OUT_DIR/pi4-kernel.S" -o "$OUT_DIR/pi4-start.o"
"$LINKER" -o "$OUT_DIR/kernel8.img" --base 0x80000 --map "$OUT_DIR/kernel8.map" "$OUT_DIR/pi4-start.o"
grep -a -q 'arch=AARCH64 machine=PI4' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4el=EL1' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4vec=OK' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4svc=OK' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4sysframe=' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4dtb=OK' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4dtbroot=' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4boarddtb=OK' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4model=' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4compat=' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4soc=WAIT' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4socdtb=OK' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4socrange=' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4socrangelen=' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4gicdtb=OK' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4gicdtb=WAIT' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4gicnode=' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4giccompat=' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4gicreg=' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4gicreglen=' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4gicmmio=OK' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4gicmmio=WAIT' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4gicbase=' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4giccfg=OK' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4giccfg=WAIT' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4gicctl=' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4giciidr=' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4irq=WAIT' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4irq=OK' "$OUT_DIR/kernel8.img"
grep -a -q 'irqctl=GIC' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4gic=' "$OUT_DIR/kernel8.img"
grep -a -q 'clocksrc=ARMTMR' "$OUT_DIR/kernel8.img"
grep -a -q 'clockhz=' "$OUT_DIR/kernel8.img"
grep -a -q 'clocktick=' "$OUT_DIR/kernel8.img"
grep -a -q 'clockirq=' "$OUT_DIR/kernel8.img"
grep -a -q 'ticks=' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4timer=WAIT' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4timer=OK' "$OUT_DIR/kernel8.img"
! grep -a -q 'hwproof=' "$OUT_DIR/kernel8.img"
! grep -a -q 'hardware proof' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4mailbox=WAIT' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4mailbox=OK' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4fbmail=' "$OUT_DIR/kernel8.img"
grep -a -q 'gfx=OK' "$OUT_DIR/kernel8.img"
grep -a -q 'gfx=WAIT' "$OUT_DIR/kernel8.img"
grep -a -q 'fb=PI4FB' "$OUT_DIR/kernel8.img"
grep -a -q 'fb=WAIT' "$OUT_DIR/kernel8.img"
grep -a -q 'fbgeom=' "$OUT_DIR/kernel8.img"
grep -a -q 'fbpresent=' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4fb=OK' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4fb=WAIT' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4uabi=WAIT' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4elf=OK' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4elfsrc=EMBEDDED' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4elfsrc=VFS' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4elfprobe=' "$OUT_DIR/kernel8.img"
grep -a -q 'embedded elf64 el0 probe launched' "$OUT_DIR/kernel8.img"
grep -a -q 'PI4ELFPROBE' "$OUT_DIR/kernel8.img"
grep -a -q '/SYSTEM/INIT.ELF' "$OUT_DIR/kernel8.img"
grep -a -q '/APPS/DOOM/APP.ELF' "$OUT_DIR/kernel8.img"
grep -a -q '/APPS/QUAKE/APP.ELF' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4sd=WAIT' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4fat=WAIT' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4vfs=WAIT' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4root=' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4init=' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4initbuf=' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4blk=' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4blkreq=' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4blkpio=' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4sdctl=' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4sdregs=' "$OUT_DIR/kernel8.img"
grep -a -q 'WAIT' "$OUT_DIR/kernel8.img"
grep -a -q 'ENOSYS' "$OUT_DIR/kernel8.img"
grep -a -q 'EINVAL' "$OUT_DIR/kernel8.img"
grep -a -q 'EMMC2' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4input=UART' "$OUT_DIR/kernel8.img"
grep -a -q 'pi4usb=WAIT' "$OUT_DIR/kernel8.img"
! grep -a -q 'pi4sd=OK' "$OUT_DIR/kernel8.img"
! grep -a -q 'pi4fat=OK' "$OUT_DIR/kernel8.img"
! grep -a -q 'pi4vfs=OK' "$OUT_DIR/kernel8.img"
! grep -a -q 'pi4usb=OK' "$OUT_DIR/kernel8.img"
grep -q 'section=.pi4_input_state' "$OUT_DIR/kernel8.map"
grep -q 'section=.text.pi4_storage' "$OUT_DIR/kernel8.map"
grep -q 'section=.rodata.pi4_storage' "$OUT_DIR/kernel8.map"
grep -q 'section=.pi4_storage_status' "$OUT_DIR/kernel8.map"
grep -q 'section=.bss.pi4_start_storage' "$OUT_DIR/kernel8.map"
grep -q 'section=.bss.pi4_storage' "$OUT_DIR/kernel8.map"
! grep -q 'section=.bss.pi4_input' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_validate_dtb addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_scan_soc_ranges addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_scan_board_identity addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_scan_gic_dtb addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_prepare_gic_mmio addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_configure_gic addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_run_timer_irq_probe addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_mailbox_call addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_framebuffer_init addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_uart_write_mailbox_fb_tuple addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_uart_write_gic_tuple addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_uart_write_gic_mmio_tuple addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_uart_write_gic_cfg_tuple addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_uart_write_irq_tuple addr=' "$OUT_DIR/kernel8.map"
grep -q 'section=.pi4_mailbox' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_fb_mailbox_msg addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4socdtb addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4boarddtb addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4mailbox addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4fb addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_gfx addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_fb addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4gicdtb addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4gicmmio addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4giccfg addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4irq addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4timer addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4socrange_bus addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4socrange_periph addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4socrange_span addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4socrange_node addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4socrange_len addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4gic_node addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4gic_depth addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4gic_interrupt addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4giccompat_ptr addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4giccompat_len addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4giccompat_hash addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4gicreg0 addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4gicreg1 addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4gicreg2 addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4gicreg3 addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4gicreg4 addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4gicreg5 addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4gicreg6 addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4gicreg7 addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4gicreg_len addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4gic_dist_base addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4gic_cpu_base addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4gic_dist_len addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4gic_cpu_len addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4gic_dist_ctlr addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4gic_cpu_ctlr addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4gic_cpu_pmr addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4gic_cpu_bpr addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4gic_dist_typer addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4gic_dist_iidr addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4gic_cpu_iidr addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_timer_freq addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_timer_tick addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_timer_irq_id addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_timer_iar_id addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_timer_eoi_id addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_timer_ticks addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_irqframe_elr_el1 addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_irqframe_spsr_el1 addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_irqframe_sp_el0 addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_irqframe_x0 addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_irqframe_x15 addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_irqframe_x30 addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_irq_gic_dist_ctlr addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_irq_gic_cpu_ctlr addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_mbox_base addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_mbox_req addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_mbox_resp addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_mbox_fail addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_fb_bus_base addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_fb_cpu_base addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_fb_size addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_fb_pitch addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_fb_width addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_fb_height addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_fb_depth addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_fb_format addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_fb_write addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_fb_sample addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4model_ptr addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4model_len addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4model_hash addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4compat_ptr addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4compat_len addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_status_pi4compat_hash addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_el1_vectors' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_el1_lower_aarch64_sync_exception' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_el1_lower_aarch64_irq_exception' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_lower_el_irq_record_timer_frame' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_lower_el_irq_restore_eret' "$OUT_DIR/kernel8.map"
grep -q 'section=.pi4_user_elf' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_prepare_embedded_elf_probe addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_embedded_el0_elf addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_embedded_el0_elf_phdr addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_el0_svc_probe addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_uart_input_init addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_uart_input_poll addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_uart_input_pop addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_uart_input_snapshot addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_prepare_storage_handoff addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_try_launch_nonembedded_init addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_nonembedded_init_elf_buffer addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_nonembedded_init_elf_bytes addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_nonembedded_init_stack_base addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_nonembedded_init_stack_top addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_start_storage_mbr_sector_buffer addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_start_storage_bpb_sector_buffer addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_start_storage_root_dir_buffer addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_start_storage_init_elf_buffer addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_reset_status addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_read_blocks addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_block_read addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_probe_controller_status addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_boot_media_probe addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_probe_boot_sector_buffers addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_parse_mbr addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_parse_fat_bpb addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_parse_fat_root addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_match_short_name addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_record_file_metadata addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_name_init_elf addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_name_app_elf addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_name_app_txt addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_block_scratch addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_boot_bpb_sector addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_root_dir_scratch addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_magic addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_version addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_pi4sd addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_pi4fat addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_pi4vfs addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_mbr addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_bpb addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_fat_type addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_root addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_init_elf addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_app0_elf addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_app1_elf addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_block addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_block_controller addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_block_lba addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_block_count addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_block_buffer addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_block_max_count addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_block_bytes addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_block_result addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_block_command addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_block_transfer_mode addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_block_argument addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_block_copied_bytes addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_block_copied_sectors addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_block_pio_words addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_block_int_status addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_block_error_status addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_block_present_before addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_block_present_after addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_sdctl_legacy_base addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_sdctl_arm_base addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_sdctl_span addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_sdctl_host_version addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_sdctl_caps0 addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_sdctl_caps1 addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_sdctl_present addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_sdctl_host_control addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_sdctl_power_control addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_sdctl_clock_control addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_sdctl_software_reset addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_sdctl_int_status addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_boot_mbr_sector_buffer addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_boot_bpb_sector_buffer addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_boot_root_dir_buffer_ptr addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_boot_root_dir_buffer_bytes addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_boot_parse_mask addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_mbr_signature addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_mbr_part_index addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_mbr_part_boot addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_mbr_part_type addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_mbr_part_lba addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_mbr_part_sectors addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_bpb_signature addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_bpb_partition_lba addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_bpb_bytes_per_sector addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_bpb_sectors_per_cluster addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_bpb_reserved_sectors addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_bpb_fat_count addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_bpb_root_entries addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_bpb_total_sectors addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_bpb_fat_sectors addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_bpb_root_dir_sectors addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_bpb_fat_span_sectors addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_bpb_first_data_rel_lba addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_bpb_cluster_count addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_bpb_fat0_lba addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_bpb_root_dir_lba addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_bpb_data_lba addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_bpb_hidden_sectors addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_bpb_root_cluster addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_root_dir_lba addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_root_dir_sectors addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_root_cluster addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_root_data_lba addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_root_entries_scanned addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_root_buffer_bytes addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_root_found_mask addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_init_elf_entry_index addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_init_elf_attr addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_init_elf_cluster addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_init_elf_size addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_init_elf_plan_lba addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_init_elf_plan_sectors addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_init_elf_plan_bytes addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_init_elf_read_count addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_app0_elf_entry_index addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_app0_elf_attr addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_app0_elf_cluster addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_app0_elf_size addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_app0_elf_plan_lba addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_app0_elf_plan_sectors addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_app0_elf_plan_bytes addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_app0_elf_read_count addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_app1_elf_entry_index addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_app1_elf_attr addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_app1_elf_cluster addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_app1_elf_size addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_app1_elf_plan_lba addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_app1_elf_plan_sectors addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_app1_elf_plan_bytes addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_app1_elf_read_count addr=' "$OUT_DIR/kernel8.map"
grep -q 'symbol=pi4_storage_status_words addr=' "$OUT_DIR/kernel8.map"
grep -Eq '\.equ[[:space:]]+PI4_GICD_CTLR,[[:space:]]+0x000' "$START_SRC"
grep -Eq '\.equ[[:space:]]+PI4_GICD_TYPER,[[:space:]]+0x004' "$START_SRC"
grep -Eq '\.equ[[:space:]]+PI4_GICD_IIDR,[[:space:]]+0x008' "$START_SRC"
grep -Eq '\.equ[[:space:]]+PI4_GICC_CTLR,[[:space:]]+0x0000' "$START_SRC"
grep -Eq '\.equ[[:space:]]+PI4_GICC_PMR,[[:space:]]+0x0004' "$START_SRC"
grep -Eq '\.equ[[:space:]]+PI4_GICC_BPR,[[:space:]]+0x0008' "$START_SRC"
grep -Eq '\.equ[[:space:]]+PI4_GICC_IAR,[[:space:]]+0x000c' "$START_SRC"
grep -Eq '\.equ[[:space:]]+PI4_GICC_EOIR,[[:space:]]+0x0010' "$START_SRC"
grep -Eq '\.equ[[:space:]]+PI4_GICC_IIDR,[[:space:]]+0x00fc' "$START_SRC"
grep -Eq '\.equ[[:space:]]+PI4_MAILBOX_BASE,[[:space:]]+PI4_PERIPHERAL_BASE \+ 0x0000b880' "$START_SRC"
grep -Eq '\.equ[[:space:]]+PI4_MAILBOX_PROPERTY_CHANNEL,[[:space:]]+8' "$START_SRC"
"$OBJDUMP" -dr "$OUT_DIR/pi4-start.o" > "$OUT_DIR/kernel8.dis"
grep -q '<pi4_validate_dtb>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_scan_soc_ranges>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_scan_board_identity>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_scan_gic_dtb>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_prepare_gic_mmio>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_configure_gic>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_run_timer_irq_probe>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_mailbox_call>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_framebuffer_init>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_el1_irq_spx_exception>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_el1_lower_aarch64_irq_exception>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_lower_el_irq_record_timer_frame>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_lower_el_irq_restore_eret>:' "$OUT_DIR/kernel8.dis"
grep -q 'tbz.*#0x1f' "$OUT_DIR/kernel8.dis"
grep -q 'tbnz.*#0x1e' "$OUT_DIR/kernel8.dis"
grep -q 'cmp.*#0x20' "$OUT_DIR/kernel8.dis"
grep -q 'lsl.*#32' "$OUT_DIR/kernel8.dis"
grep -q 'mrs.*CNTFRQ_EL0' "$OUT_DIR/kernel8.dis"
grep -q 'msr.*CNTP_TVAL_EL0' "$OUT_DIR/kernel8.dis"
grep -q 'msr.*CNTP_CTL_EL0' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_uart_write_gic_tuple>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_uart_write_gic_mmio_tuple>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_uart_write_gic_cfg_tuple>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_uart_write_irq_tuple>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_uart_input_init>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_uart_input_poll>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_uart_input_pop>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_uart_input_snapshot>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_prepare_storage_handoff>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_try_launch_nonembedded_init>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_storage_reset_status>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_storage_read_blocks>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_storage_probe_controller_status>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_storage_boot_media_probe>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_storage_probe_boot_sector_buffers>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_storage_parse_mbr>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_storage_parse_fat_bpb>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_storage_parse_fat_root>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_storage_match_short_name>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_storage_record_file_metadata>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_uart_write_storage_status_tuple>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_uart_write_storage_root_tuple>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_uart_write_storage_vfs_file_tuples>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_uart_write_storage_block_status>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_sync_storage_status>:' "$OUT_DIR/kernel8.dis"
grep -q 'rev.*w' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_prepare_embedded_elf_probe>:' "$OUT_DIR/kernel8.dis"
grep -q '<pi4_el0_svc_probe>:' "$OUT_DIR/kernel8.dis"
grep -q 'svc.*#0x40' "$OUT_DIR/kernel8.dis"
grep -q 'eret' "$OUT_DIR/kernel8.dis"

printf 'wrote %s/kernel8.img\n' "$OUT_DIR"
if want_pi4_qemu_handoff; then
    print_pi4_qemu_handoff
fi
