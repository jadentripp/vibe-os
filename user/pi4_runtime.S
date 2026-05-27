#include "pi4_runtime.h"

.arch armv8-a

.equ PI4_VIBE_PATH_NORMALIZE_MAX_BYTES, 128

.section .text.pi4_runtime, "ax", %progbits

.balign 16
.global __vibe_syscall0
.global vibe_user_syscall0
.type __vibe_syscall0, %function
.type vibe_user_syscall0, %function
__vibe_syscall0:
vibe_user_syscall0:
    uxtw x8, w0
    svc #PI4_VIBE_SVC_IMM
    ret
.size __vibe_syscall0, . - __vibe_syscall0
.size vibe_user_syscall0, . - vibe_user_syscall0

.balign 16
.global __vibe_syscall1
.global vibe_user_syscall1
.type __vibe_syscall1, %function
.type vibe_user_syscall1, %function
__vibe_syscall1:
vibe_user_syscall1:
    uxtw x8, w0
    mov x0, x1
    svc #PI4_VIBE_SVC_IMM
    ret
.size __vibe_syscall1, . - __vibe_syscall1
.size vibe_user_syscall1, . - vibe_user_syscall1

.balign 16
.global __vibe_syscall2
.global vibe_user_syscall2
.type __vibe_syscall2, %function
.type vibe_user_syscall2, %function
__vibe_syscall2:
vibe_user_syscall2:
    uxtw x8, w0
    mov x0, x1
    mov x1, x2
    svc #PI4_VIBE_SVC_IMM
    ret
.size __vibe_syscall2, . - __vibe_syscall2
.size vibe_user_syscall2, . - vibe_user_syscall2

.balign 16
.global __vibe_syscall3
.global vibe_user_syscall3
.type __vibe_syscall3, %function
.type vibe_user_syscall3, %function
__vibe_syscall3:
vibe_user_syscall3:
    uxtw x8, w0
    mov x0, x1
    mov x1, x2
    mov x2, x3
    svc #PI4_VIBE_SVC_IMM
    ret
.size __vibe_syscall3, . - __vibe_syscall3
.size vibe_user_syscall3, . - vibe_user_syscall3

.balign 16
.global vibe_user_write
.type vibe_user_write, %function
vibe_user_write:
    cbz x2, .Lpi4_runtime_write_zero
    cbz x1, .Lpi4_runtime_inval
    mov x8, #PI4_VIBE_SYS_WRITE
    svc #PI4_VIBE_SVC_IMM
    ret
.Lpi4_runtime_write_zero:
    mov x0, xzr
    ret
.size vibe_user_write, . - vibe_user_write

.balign 16
.global vibe_user_ioctl
.type vibe_user_ioctl, %function
vibe_user_ioctl:
    mov x9, #PI4_VIBE_AUDIO_FD
    cmp x0, x9
    b.ne .Lpi4_runtime_ioctl_syscall
    mov x9, #PI4_VIBE_IOCTL_AUDIO_DEVICE_INFO
    cmp x1, x9
    b.eq .Lpi4_runtime_ioctl_audio_device_info
    mov x9, #PI4_VIBE_IOCTL_AUDIO_PCM_RING_INFO
    cmp x1, x9
    b.eq .Lpi4_runtime_ioctl_audio_ring_info
    mov x9, #PI4_VIBE_IOCTL_AUDIO_STREAM_INFO
    cmp x1, x9
    b.eq .Lpi4_runtime_ioctl_audio_stream_info
.Lpi4_runtime_ioctl_syscall:
    mov x8, #PI4_VIBE_SYS_IOCTL
    svc #PI4_VIBE_SVC_IMM
    ret
.Lpi4_runtime_ioctl_audio_device_info:
    mov x0, x2
    b vibe_user_audio_device_info
.Lpi4_runtime_ioctl_audio_ring_info:
    mov x0, x2
    b vibe_user_audio_pcm_ring_info
.Lpi4_runtime_ioctl_audio_stream_info:
    cbz x2, .Lpi4_runtime_inval
    ldr x0, [x2, #PI4_VIBE_AUDIO_STREAM_INFO_HANDLE_OFFSET]
    mov x1, x2
    b vibe_user_audio_stream_info
.size vibe_user_ioctl, . - vibe_user_ioctl

.balign 16
.global vibe_user_syscall_errno
.global vibe_user_errno_from_result
.type vibe_user_syscall_errno, %function
.type vibe_user_errno_from_result, %function
vibe_user_syscall_errno:
vibe_user_errno_from_result:
    cmp x0, #0
    b.ge .Lpi4_runtime_errno_zero
    cmn x0, #1
    b.eq .Lpi4_runtime_errno_fallback
    neg x0, x0
    ret
.Lpi4_runtime_errno_fallback:
    cmp x1, #0
    b.gt .Lpi4_runtime_errno_use_fallback
    mov x0, #PI4_VIBE_EIO
    ret
.Lpi4_runtime_errno_use_fallback:
    mov x0, x1
    ret
.Lpi4_runtime_errno_zero:
    mov x0, xzr
    ret
.size vibe_user_syscall_errno, . - vibe_user_syscall_errno
.size vibe_user_errno_from_result, . - vibe_user_errno_from_result

.balign 16
.global vibe_user_open
.global vibe_user_file_open
.type vibe_user_open, %function
.type vibe_user_file_open, %function
vibe_user_open:
    cbz x0, .Lpi4_runtime_inval
    b .Lpi4_runtime_open_syscall
vibe_user_file_open:
    cbz x0, .Lpi4_runtime_inval
    mov x1, xzr
    mov x2, xzr
.Lpi4_runtime_open_syscall:
    str x30, [sp, #-16]!
    bl .Lpi4_runtime_normalize_asset_path
    mov x9, x0
    mov x8, #PI4_VIBE_SYS_OPEN
    svc #PI4_VIBE_SVC_IMM
    cmp x0, #PI4_VIBE_FD_DOOM1_WAD
    b.eq .Lpi4_runtime_open_reset_doom
    cmp x0, #PI4_VIBE_FD_PAK0_PAK
    b.eq .Lpi4_runtime_open_reset_pak
    b .Lpi4_runtime_open_done
.Lpi4_runtime_open_reset_doom:
    adrp x10, .Lpi4_runtime_doom_offset_shadow
    add x10, x10, :lo12:.Lpi4_runtime_doom_offset_shadow
    str xzr, [x10]
    adrp x10, .Lpi4_runtime_open_probe
    add x10, x10, :lo12:.Lpi4_runtime_open_probe
    mov x1, x10
    mov x2, #4
    mov x8, #PI4_VIBE_SYS_READ
    svc #PI4_VIBE_SVC_IMM
    cmp x0, #4
    b.eq .Lpi4_runtime_open_check_doom_magic
    cmp x0, #0
    b.lt .Lpi4_runtime_open_done
    b .Lpi4_runtime_open_asset_stub
.Lpi4_runtime_open_check_doom_magic:
    ldrb w11, [x10]
    cmp w11, #0x49
    b.eq .Lpi4_runtime_open_check_doom_wad
    cmp w11, #0x50
    b.ne .Lpi4_runtime_open_asset_stub
.Lpi4_runtime_open_check_doom_wad:
    ldrb w11, [x10, #1]
    cmp w11, #0x57
    b.ne .Lpi4_runtime_open_asset_stub
    ldrb w11, [x10, #2]
    cmp w11, #0x41
    b.ne .Lpi4_runtime_open_asset_stub
    ldrb w11, [x10, #3]
    cmp w11, #0x44
    b.ne .Lpi4_runtime_open_asset_stub
    mov x0, x9
    mov x1, xzr
    mov x2, xzr
    mov x8, #PI4_VIBE_SYS_OPEN
    svc #PI4_VIBE_SVC_IMM
    cmp x0, #PI4_VIBE_FD_DOOM1_WAD
    b.eq .Lpi4_runtime_open_reset_doom_done
    cmp x0, #0
    b.lt .Lpi4_runtime_open_done
    b .Lpi4_runtime_open_reset_failed
.Lpi4_runtime_open_reset_doom_done:
    adrp x10, .Lpi4_runtime_doom_offset_shadow
    add x10, x10, :lo12:.Lpi4_runtime_doom_offset_shadow
    str xzr, [x10]
    b .Lpi4_runtime_open_done
.Lpi4_runtime_open_reset_pak:
    adrp x10, .Lpi4_runtime_pak_offset_shadow
    add x10, x10, :lo12:.Lpi4_runtime_pak_offset_shadow
    str xzr, [x10]
    adrp x10, .Lpi4_runtime_open_probe
    add x10, x10, :lo12:.Lpi4_runtime_open_probe
    mov x1, x10
    mov x2, #4
    mov x8, #PI4_VIBE_SYS_READ
    svc #PI4_VIBE_SVC_IMM
    cmp x0, #4
    b.eq .Lpi4_runtime_open_check_pak_magic
    cmp x0, #0
    b.lt .Lpi4_runtime_open_done
    b .Lpi4_runtime_open_asset_stub
.Lpi4_runtime_open_check_pak_magic:
    ldrb w11, [x10]
    cmp w11, #0x50
    b.ne .Lpi4_runtime_open_asset_stub
    ldrb w11, [x10, #1]
    cmp w11, #0x41
    b.ne .Lpi4_runtime_open_asset_stub
    ldrb w11, [x10, #2]
    cmp w11, #0x43
    b.ne .Lpi4_runtime_open_asset_stub
    ldrb w11, [x10, #3]
    cmp w11, #0x4b
    b.ne .Lpi4_runtime_open_asset_stub
    mov x0, x9
    mov x1, xzr
    mov x2, xzr
    mov x8, #PI4_VIBE_SYS_OPEN
    svc #PI4_VIBE_SVC_IMM
    cmp x0, #PI4_VIBE_FD_PAK0_PAK
    b.eq .Lpi4_runtime_open_reset_pak_done
    cmp x0, #0
    b.lt .Lpi4_runtime_open_done
    b .Lpi4_runtime_open_reset_failed
.Lpi4_runtime_open_reset_pak_done:
    adrp x10, .Lpi4_runtime_pak_offset_shadow
    add x10, x10, :lo12:.Lpi4_runtime_pak_offset_shadow
    str xzr, [x10]
    b .Lpi4_runtime_open_done
.Lpi4_runtime_open_asset_stub:
    mov x0, #PI4_VIBE_ENOENT
    neg x0, x0
    b .Lpi4_runtime_open_done
.Lpi4_runtime_open_reset_failed:
    mov x0, #PI4_VIBE_EIO
    neg x0, x0
.Lpi4_runtime_open_done:
    ldr x30, [sp], #16
    ret
.size vibe_user_open, . - vibe_user_open
.size vibe_user_file_open, . - vibe_user_file_open

.balign 16
.global vibe_user_file_size
.type vibe_user_file_size, %function
vibe_user_file_size:
    mov x8, #PI4_VIBE_SYS_FILE_SIZE
    svc #PI4_VIBE_SVC_IMM
    ret
.size vibe_user_file_size, . - vibe_user_file_size

.balign 16
.global vibe_user_file_size_path
.type vibe_user_file_size_path, %function
vibe_user_file_size_path:
    cbz x0, .Lpi4_runtime_inval
    cbz x1, .Lpi4_runtime_inval
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    str x19, [sp, #16]
    mov x19, x1
    add x1, sp, #24
    bl vibe_user_stat
    cmp x0, #0
    b.lt .Lpi4_runtime_file_size_path_done
    ldr w9, [sp, #(24 + PI4_VIBE_STAT_SIZE_OFFSET)]
    str x9, [x19]
    mov x0, xzr
.Lpi4_runtime_file_size_path_done:
    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #80
    ret
.size vibe_user_file_size_path, . - vibe_user_file_size_path

.balign 16
.global vibe_user_read
.global vibe_user_file_read
.type vibe_user_read, %function
.type vibe_user_file_read, %function
vibe_user_read:
vibe_user_file_read:
    cbz x2, .Lpi4_runtime_read_zero
    cbz x1, .Lpi4_runtime_inval
    mov x9, x0
    mov x10, x1
    mov x11, x2
    mov x12, xzr

.Lpi4_runtime_read_loop:
    mov x0, x9
    mov x1, x10
    mov x2, x11
    mov x8, #PI4_VIBE_SYS_READ
    svc #PI4_VIBE_SVC_IMM
    cmp x0, #0
    b.lt .Lpi4_runtime_read_error
    cbz x0, .Lpi4_runtime_read_finish
    cmp x9, #PI4_VIBE_FD_DOOM1_WAD
    b.eq .Lpi4_runtime_read_advance_doom
    cmp x9, #PI4_VIBE_FD_PAK0_PAK
    b.eq .Lpi4_runtime_read_advance_pak
    b .Lpi4_runtime_read_advance_done
.Lpi4_runtime_read_advance_doom:
    adrp x13, .Lpi4_runtime_doom_offset_shadow
    add x13, x13, :lo12:.Lpi4_runtime_doom_offset_shadow
    b .Lpi4_runtime_read_advance
.Lpi4_runtime_read_advance_pak:
    adrp x13, .Lpi4_runtime_pak_offset_shadow
    add x13, x13, :lo12:.Lpi4_runtime_pak_offset_shadow
.Lpi4_runtime_read_advance:
    ldr x14, [x13]
    add x14, x14, x0
    str x14, [x13]
.Lpi4_runtime_read_advance_done:
    add x12, x12, x0
    add x10, x10, x0
    sub x11, x11, x0
    cbnz x11, .Lpi4_runtime_read_loop
.Lpi4_runtime_read_finish:
    mov x0, x12
    ret
.Lpi4_runtime_read_error:
    cbnz x12, .Lpi4_runtime_read_finish
    ret
.Lpi4_runtime_read_zero:
    mov x0, xzr
    ret
.size vibe_user_read, . - vibe_user_read
.size vibe_user_file_read, . - vibe_user_file_read

.balign 16
.global vibe_user_pread
.type vibe_user_pread, %function
vibe_user_pread:
    cbz x2, .Lpi4_runtime_pread_zero
    cbz x1, .Lpi4_runtime_inval
    tbnz x3, #63, .Lpi4_runtime_inval
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    mov x1, xzr
    mov x2, #PI4_VIBE_SEEK_CUR
    bl vibe_user_lseek
    cmp x0, #0
    b.lt .Lpi4_runtime_pread_done
    str x0, [sp, #48]
    mov x0, x19
    mov x1, x22
    mov x2, #PI4_VIBE_SEEK_SET
    bl vibe_user_lseek
    cmp x0, #0
    b.lt .Lpi4_runtime_pread_seek_failed
    mov x0, x19
    mov x1, x20
    mov x2, x21
    bl vibe_user_read
    str x0, [sp, #56]
    b .Lpi4_runtime_pread_restore
.Lpi4_runtime_pread_seek_failed:
    str x0, [sp, #56]
.Lpi4_runtime_pread_restore:
    mov x0, x19
    ldr x1, [sp, #48]
    mov x2, #PI4_VIBE_SEEK_SET
    bl vibe_user_lseek
    ldr x0, [sp, #56]
.Lpi4_runtime_pread_done:
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret
.Lpi4_runtime_pread_zero:
    mov x0, xzr
    ret
.size vibe_user_pread, . - vibe_user_pread

.balign 16
.global vibe_user_file_read_at
.type vibe_user_file_read_at, %function
vibe_user_file_read_at:
    cbz x0, .Lpi4_runtime_inval
    cbz x3, .Lpi4_runtime_file_read_at_zero
    cbz x2, .Lpi4_runtime_inval
    tbnz x1, #63, .Lpi4_runtime_inval
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x19, x1
    mov x20, x2
    mov x21, x3
    mov x22, x4
    cbz x22, .Lpi4_runtime_file_read_at_open
    str xzr, [x22]
.Lpi4_runtime_file_read_at_open:
    bl vibe_user_file_open
    cmp x0, #0
    b.lt .Lpi4_runtime_file_read_at_done
    mov x23, x0
    mov x1, x19
    mov x2, #PI4_VIBE_SEEK_SET
    bl vibe_user_lseek
    cmp x0, #0
    b.lt .Lpi4_runtime_file_read_at_close
    mov x0, x23
    mov x1, x20
    mov x2, x21
    bl vibe_user_file_read
    cmp x0, #0
    b.lt .Lpi4_runtime_file_read_at_close
    cbz x22, .Lpi4_runtime_file_read_at_success
    str x0, [x22]
.Lpi4_runtime_file_read_at_success:
    mov x24, xzr
    b .Lpi4_runtime_file_read_at_close_with_saved
.Lpi4_runtime_file_read_at_close:
    mov x24, x0
.Lpi4_runtime_file_read_at_close_with_saved:
    mov x0, x23
    bl vibe_user_file_close
    mov x0, x24
.Lpi4_runtime_file_read_at_done:
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret
.Lpi4_runtime_file_read_at_zero:
    cbz x4, .Lpi4_runtime_file_read_at_zero_done
    str xzr, [x4]
.Lpi4_runtime_file_read_at_zero_done:
    mov x0, xzr
    ret
.size vibe_user_file_read_at, . - vibe_user_file_read_at

.balign 16
.global vibe_user_close
.global vibe_user_file_close
.type vibe_user_close, %function
.type vibe_user_file_close, %function
vibe_user_close:
vibe_user_file_close:
    mov x8, #PI4_VIBE_SYS_CLOSE
    svc #PI4_VIBE_SVC_IMM
    ret
.size vibe_user_close, . - vibe_user_close
.size vibe_user_file_close, . - vibe_user_file_close

.balign 16
.global vibe_user_fstat
.type vibe_user_fstat, %function
vibe_user_fstat:
    cbz x1, .Lpi4_runtime_inval
    mov x8, #PI4_VIBE_SYS_FSTAT
    svc #PI4_VIBE_SVC_IMM
    ret
.size vibe_user_fstat, . - vibe_user_fstat

.balign 16
.global vibe_user_stat
.type vibe_user_stat, %function
vibe_user_stat:
    cbz x0, .Lpi4_runtime_inval
    cbz x1, .Lpi4_runtime_inval
    mov x8, #PI4_VIBE_SYS_STAT
    svc #PI4_VIBE_SVC_IMM
    ret
.size vibe_user_stat, . - vibe_user_stat

.balign 16
.global vibe_user_lseek
.global vibe_user_file_seek
.type vibe_user_lseek, %function
.type vibe_user_file_seek, %function
vibe_user_lseek:
vibe_user_file_seek:
    mov x8, #PI4_VIBE_SYS_LSEEK
    svc #PI4_VIBE_SVC_IMM
    ret
.size vibe_user_lseek, . - vibe_user_lseek
.size vibe_user_file_seek, . - vibe_user_file_seek

.balign 16
.global vibe_user_file_probe_assets
.type vibe_user_file_probe_assets, %function
vibe_user_file_probe_assets:
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]

    adrp x9, .Lpi4_runtime_asset_probe_done
    add x9, x9, :lo12:.Lpi4_runtime_asset_probe_done
    ldr x10, [x9]
    cbnz x10, .Lpi4_runtime_asset_probe_done_return
    mov x10, #1
    str x10, [x9]

    adrp x9, vibe_user_argv
    add x9, x9, :lo12:vibe_user_argv
    ldr x9, [x9]
    cbz x9, .Lpi4_runtime_asset_probe_done_return
    ldr x19, [x9]
    cbz x19, .Lpi4_runtime_asset_probe_done_return

    mov x0, x19
    adrp x1, .Lpi4_runtime_payload0_path
    add x1, x1, :lo12:.Lpi4_runtime_payload0_path
    bl .Lpi4_runtime_path_eq16
    cbnz x0, .Lpi4_runtime_probe_doom_wad

    mov x0, x19
    adrp x1, .Lpi4_runtime_payload1_path
    add x1, x1, :lo12:.Lpi4_runtime_payload1_path
    bl .Lpi4_runtime_path_eq16
    cbnz x0, .Lpi4_runtime_probe_quake_pak
    b .Lpi4_runtime_asset_probe_done_return

.Lpi4_runtime_probe_doom_wad:
    adrp x20, .Lpi4_runtime_doom1_wad_path
    add x20, x20, :lo12:.Lpi4_runtime_doom1_wad_path
    b .Lpi4_runtime_probe_asset

.Lpi4_runtime_probe_quake_pak:
    adrp x20, .Lpi4_runtime_pak0_path
    add x20, x20, :lo12:.Lpi4_runtime_pak0_path

.Lpi4_runtime_probe_asset:
    mov x0, x20
    bl vibe_user_file_open
    cmp x0, #0
    b.lt .Lpi4_runtime_asset_probe_done_return
    mov x19, x0
    bl vibe_user_file_size
    mov x0, x19
    add x1, sp, #48
    mov x2, #16
    bl vibe_user_file_read

.Lpi4_runtime_asset_probe_done_return:
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret
.size vibe_user_file_probe_assets, . - vibe_user_file_probe_assets

.balign 16
.global vibe_user_exit
.global vibe_user_exit_status
.type vibe_user_exit, %function
.type vibe_user_exit_status, %function
vibe_user_exit:
vibe_user_exit_status:
    sxtw x0, w0
    mov x8, #PI4_VIBE_SYS_EXIT
    svc #PI4_VIBE_SVC_IMM
.Lpi4_exit_halt:
    wfe
    b .Lpi4_exit_halt
.size vibe_user_exit, . - vibe_user_exit
.size vibe_user_exit_status, . - vibe_user_exit_status

.balign 16
.global vibe_user_execv
.global vibe_user_execv_payload
.global vibe_user_exec_request
.type vibe_user_execv, %function
.type vibe_user_execv_payload, %function
.type vibe_user_exec_request, %function
vibe_user_execv:
    cbz x0, .Lpi4_runtime_inval
    cbz x1, .Lpi4_runtime_inval
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    mov x19, x0
    mov x20, x1
    adrp x1, .Lpi4_runtime_payload0_path
    add x1, x1, :lo12:.Lpi4_runtime_payload0_path
    bl .Lpi4_runtime_path_suffix_eq
    cbnz x0, .Lpi4_runtime_execv_slot0
    mov x0, x19
    adrp x1, .Lpi4_runtime_payload1_path
    add x1, x1, :lo12:.Lpi4_runtime_payload1_path
    bl .Lpi4_runtime_path_suffix_eq
    cbnz x0, .Lpi4_runtime_execv_slot1
    mov x0, #-PI4_VIBE_EINVAL
    b .Lpi4_runtime_execv_done
.Lpi4_runtime_execv_slot0:
    mov x0, #PI4_VIBE_PAYLOAD_SLOT0
    b .Lpi4_runtime_execv_have_slot
.Lpi4_runtime_execv_slot1:
    mov x0, #PI4_VIBE_PAYLOAD_SLOT1
.Lpi4_runtime_execv_have_slot:
    add x1, sp, #32
    str x0, [x1, #PI4_VIBE_EXEC_REQUEST_PAYLOAD_SLOT_OFFSET]
    mov x2, #PI4_VIBE_EXEC_REQUEST_ABI_VERSION
    str x2, [x1, #PI4_VIBE_EXEC_REQUEST_ABI_VERSION_OFFSET]
    mov x2, #PI4_VIBE_EXEC_REQUEST_BYTES
    str x2, [x1, #PI4_VIBE_EXEC_REQUEST_BYTES_OFFSET]
    str x19, [x1, #PI4_VIBE_EXEC_REQUEST_PATH_OFFSET]
    mov x0, x1
    mov x1, x20
    adrp x2, .Lpi4_runtime_empty_envp
    add x2, x2, :lo12:.Lpi4_runtime_empty_envp
    bl vibe_user_exec_request
.Lpi4_runtime_execv_done:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret
.size vibe_user_execv, . - vibe_user_execv
vibe_user_execv_payload:
    cbz x1, .Lpi4_runtime_inval
    cbz x2, .Lpi4_runtime_inval
    cmp x0, #PI4_VIBE_PAYLOAD_SLOT_COUNT
    b.hs .Lpi4_runtime_inval
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    str x19, [sp, #16]
    mov x19, x2
    add x3, sp, #32
    str x0, [x3, #PI4_VIBE_EXEC_REQUEST_PAYLOAD_SLOT_OFFSET]
    mov x4, #PI4_VIBE_EXEC_REQUEST_ABI_VERSION
    str x4, [x3, #PI4_VIBE_EXEC_REQUEST_ABI_VERSION_OFFSET]
    mov x4, #PI4_VIBE_EXEC_REQUEST_BYTES
    str x4, [x3, #PI4_VIBE_EXEC_REQUEST_BYTES_OFFSET]
    str x1, [x3, #PI4_VIBE_EXEC_REQUEST_PATH_OFFSET]
    mov x0, x3
    mov x1, x19
    adrp x2, .Lpi4_runtime_empty_envp
    add x2, x2, :lo12:.Lpi4_runtime_empty_envp
    bl vibe_user_exec_request
    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #64
    ret
.size vibe_user_execv_payload, . - vibe_user_execv_payload
vibe_user_exec_request:
    cbz x0, .Lpi4_runtime_inval
    cbz x1, .Lpi4_runtime_inval
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    str x21, [sp, #32]
    mov x19, x0
    mov x20, x1
    mov x21, x2
    ldr x3, [x19, #PI4_VIBE_EXEC_REQUEST_ABI_VERSION_OFFSET]
    cmp x3, #PI4_VIBE_EXEC_REQUEST_ABI_VERSION
    b.ne .Lpi4_runtime_exec_request_inval
    ldr x3, [x19, #PI4_VIBE_EXEC_REQUEST_BYTES_OFFSET]
    cmp x3, #PI4_VIBE_EXEC_REQUEST_BYTES
    b.ne .Lpi4_runtime_exec_request_inval
    ldr x6, [x19, #PI4_VIBE_EXEC_REQUEST_PAYLOAD_SLOT_OFFSET]
    ldr x0, [x19, #PI4_VIBE_EXEC_REQUEST_PATH_OFFSET]
    cbz x0, .Lpi4_runtime_exec_request_inval
    cmp x6, #PI4_VIBE_PAYLOAD_SLOT0
    b.eq .Lpi4_runtime_exec_request_slot0
    cmp x6, #PI4_VIBE_PAYLOAD_SLOT1
    b.eq .Lpi4_runtime_exec_request_slot1
    b .Lpi4_runtime_exec_request_inval

.Lpi4_runtime_exec_request_slot0:
    adrp x1, .Lpi4_runtime_payload0_path
    add x1, x1, :lo12:.Lpi4_runtime_payload0_path
    bl .Lpi4_runtime_path_suffix_eq
    cbz x0, .Lpi4_runtime_exec_request_inval
    b .Lpi4_runtime_exec_request_syscall

.Lpi4_runtime_exec_request_slot1:
    adrp x1, .Lpi4_runtime_payload1_path
    add x1, x1, :lo12:.Lpi4_runtime_payload1_path
    bl .Lpi4_runtime_path_suffix_eq
    cbz x0, .Lpi4_runtime_exec_request_inval

.Lpi4_runtime_exec_request_syscall:
    mov x0, x19
    mov x1, x20
    mov x2, x21
    mov x8, #PI4_VIBE_SYS_EXEC
    svc #PI4_VIBE_SVC_IMM
    b .Lpi4_runtime_exec_request_done

.Lpi4_runtime_exec_request_inval:
    mov x0, #-PI4_VIBE_EINVAL

.Lpi4_runtime_exec_request_done:
    ldr x21, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret
.size vibe_user_exec_request, . - vibe_user_exec_request

.balign 16
.global vibe_user_fb_get_info
.type vibe_user_fb_get_info, %function
vibe_user_fb_get_info:
    cbz x0, .Lpi4_runtime_inval
    mov x2, x0
    mov x0, #PI4_VIBE_DISPLAY_FD
    mov w1, #PI4_VIBE_IOCTL_FBINFO
    mov x8, #PI4_VIBE_SYS_IOCTL
    svc #PI4_VIBE_SVC_IMM
    ret
.size vibe_user_fb_get_info, . - vibe_user_fb_get_info

.balign 16
.global vibe_user_present_indexed
.global vibe_user_fb_present_indexed
.type vibe_user_present_indexed, %function
.type vibe_user_fb_present_indexed, %function
vibe_user_present_indexed:
vibe_user_fb_present_indexed:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    mov x9, x0
    bl .Lpi4_runtime_present_indexed_frame_bytes
    cbz x0, .Lpi4_runtime_present_indexed_inval
    mov x2, x9
    mov x0, #PI4_VIBE_DISPLAY_FD
    mov w1, #PI4_VIBE_IOCTL_PRESENT_INDEXED
    mov x8, #PI4_VIBE_SYS_IOCTL
    svc #PI4_VIBE_SVC_IMM
    ldp x29, x30, [sp], #16
    ret
.Lpi4_runtime_present_indexed_inval:
    mov x0, #-PI4_VIBE_EINVAL
    ldp x29, x30, [sp], #16
    ret
.size vibe_user_present_indexed, . - vibe_user_present_indexed
.size vibe_user_fb_present_indexed, . - vibe_user_fb_present_indexed

.balign 16
.global vibe_user_fb_can_present_indexed
.type vibe_user_fb_can_present_indexed, %function
vibe_user_fb_can_present_indexed:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    mov x9, x0
    mov x10, x1
    mov x0, x1
    bl .Lpi4_runtime_present_indexed_frame_bytes
    cbz x0, .Lpi4_runtime_return_false
    mov x7, x0
    mov x0, x9
    ldr x3, [x10, #PI4_VIBE_PRESENT_INDEXED_WIDTH_OFFSET]
    ldr x4, [x10, #PI4_VIBE_PRESENT_INDEXED_HEIGHT_OFFSET]
    cbz x0, .Lpi4_runtime_return_true
    ldr x5, [x0, #PI4_VIBE_FB_INFO_BACKEND_OFFSET]
    cmp x5, #PI4_VIBE_FB_BACKEND_XRGB8888_LFB
    b.ne .Lpi4_runtime_return_false
    ldr x5, [x0, #PI4_VIBE_FB_INFO_FRAME_BYTES_OFFSET]
    cmp x5, x7
    b.lo .Lpi4_runtime_return_false
    ldr x5, [x0, #PI4_VIBE_FB_INFO_PALETTE_BYTES_OFFSET]
    cmp x5, #PI4_VIBE_FB_RGB24_PALETTE_BYTES
    b.lo .Lpi4_runtime_return_false
    ldr x5, [x0, #PI4_VIBE_FB_INFO_CAPABILITIES_OFFSET]
    mov x6, #(PI4_VIBE_FB_CAP_PRESENT_INDEXED | PI4_VIBE_FB_CAP_PRESENT_RGB_PALETTE | PI4_VIBE_FB_CAP_XRGB8888_LFB)
    and x5, x5, x6
    cmp x5, x6
    b.ne .Lpi4_runtime_return_false
    ldr x5, [x0, #PI4_VIBE_FB_INFO_PRESENT_FORMAT_OFFSET]
    cmp x5, #PI4_VIBE_FB_FORMAT_INDEX8_RGB24
    b.ne .Lpi4_runtime_return_false
    ldr x5, [x0, #PI4_VIBE_FB_INFO_MAX_PRESENT_WIDTH_OFFSET]
    cbz x5, .Lpi4_runtime_check_height
    cmp x3, x5
    b.hi .Lpi4_runtime_return_false
.Lpi4_runtime_check_height:
    ldr x5, [x0, #PI4_VIBE_FB_INFO_MAX_PRESENT_HEIGHT_OFFSET]
    cbz x5, .Lpi4_runtime_return_true
    cmp x4, x5
    b.hi .Lpi4_runtime_return_false
.Lpi4_runtime_return_true:
    mov x0, #1
    ldp x29, x30, [sp], #16
    ret
.Lpi4_runtime_return_false:
    mov x0, xzr
    ldp x29, x30, [sp], #16
    ret
.size vibe_user_fb_can_present_indexed, . - vibe_user_fb_can_present_indexed

.Lpi4_runtime_present_indexed_frame_bytes:
    cbz x0, .Lpi4_runtime_present_indexed_frame_bytes_invalid
    ldr x1, [x0, #PI4_VIBE_PRESENT_INDEXED_FRAME_OFFSET]
    cbz x1, .Lpi4_runtime_present_indexed_frame_bytes_invalid
    ldr x1, [x0, #PI4_VIBE_PRESENT_INDEXED_PALETTE_OFFSET]
    cbz x1, .Lpi4_runtime_present_indexed_frame_bytes_invalid
    ldr x1, [x0, #PI4_VIBE_PRESENT_INDEXED_WIDTH_OFFSET]
    cbz x1, .Lpi4_runtime_present_indexed_frame_bytes_invalid
    ldr x2, [x0, #PI4_VIBE_PRESENT_INDEXED_HEIGHT_OFFSET]
    cbz x2, .Lpi4_runtime_present_indexed_frame_bytes_invalid
    mul x0, x1, x2
    umulh x3, x1, x2
    cbnz x3, .Lpi4_runtime_present_indexed_frame_bytes_invalid
    cbz x0, .Lpi4_runtime_present_indexed_frame_bytes_invalid
    ret
.Lpi4_runtime_present_indexed_frame_bytes_invalid:
    mov x0, xzr
    ret

.balign 16
.global vibe_user_present_indexed_checked
.global vibe_user_fb_present_indexed_checked
.type vibe_user_present_indexed_checked, %function
.type vibe_user_fb_present_indexed_checked, %function
vibe_user_present_indexed_checked:
vibe_user_fb_present_indexed_checked:
    cbz x0, .Lpi4_runtime_inval
    stp x29, x30, [sp, #-224]!
    mov x29, sp
    str x19, [sp, #16]
    mov x19, x0
    add x0, sp, #32
    bl vibe_user_fb_get_info
    cbnz x0, .Lpi4_runtime_present_checked_done
    add x0, sp, #32
    mov x1, x19
    bl vibe_user_fb_can_present_indexed
    cbz x0, .Lpi4_runtime_present_checked_inval
    mov x0, x19
    bl vibe_user_present_indexed
    b .Lpi4_runtime_present_checked_done
.Lpi4_runtime_present_checked_inval:
    mov x0, #-PI4_VIBE_EINVAL
.Lpi4_runtime_present_checked_done:
    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #224
    ret
.size vibe_user_present_indexed_checked, . - vibe_user_present_indexed_checked
.size vibe_user_fb_present_indexed_checked, . - vibe_user_fb_present_indexed_checked

.balign 16
.global vibe_user_poll_input
.global vibe_user_input_poll
.type vibe_user_poll_input, %function
.type vibe_user_input_poll, %function
vibe_user_poll_input:
vibe_user_input_poll:
    cbz x0, .Lpi4_runtime_inval
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x19, [sp, #16]
    mov x19, x0
    mov x1, #PI4_VIBE_INPUT_EVENT_BYTES
    mov x2, xzr
    mov x8, #PI4_VIBE_SYS_POLL_INPUT
    svc #PI4_VIBE_SVC_IMM
    cmp x0, #1
    b.ne .Lpi4_runtime_poll_input_done
    mov x1, x19
    bl .Lpi4_runtime_decode_input_event
    mov x0, #1
.Lpi4_runtime_poll_input_done:
    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size vibe_user_poll_input, . - vibe_user_poll_input
.size vibe_user_input_poll, . - vibe_user_input_poll

.Lpi4_runtime_decode_input_event:
    ldr x4, [x1, #PI4_VIBE_INPUT_EVENT_CODE_OFFSET]
    tbz x4, #31, .Lpi4_runtime_normalize_input_event
    and x5, x4, #PI4_VIBE_INPUT_EVENT_KEY_TOKEN_CODE_MASK
    ubfx x6, x4, #PI4_VIBE_INPUT_EVENT_KEY_TOKEN_ACTION_SHIFT, #8
    ubfx x7, x4, #PI4_VIBE_INPUT_EVENT_KEY_TOKEN_HID_SHIFT, #8
    mov x8, #PI4_VIBE_INPUT_DEVICE_KEYBOARD
    str x8, [x1, #PI4_VIBE_INPUT_EVENT_DEVICE_ID_OFFSET]
    mov x8, #PI4_VIBE_INPUT_EVENT_KEY
    str x8, [x1, #PI4_VIBE_INPUT_EVENT_TYPE_OFFSET]
    str x5, [x1, #PI4_VIBE_INPUT_EVENT_CODE_OFFSET]
    str x6, [x1, #PI4_VIBE_INPUT_EVENT_VALUE0_OFFSET]
    str x7, [x1, #PI4_VIBE_INPUT_EVENT_VALUE1_OFFSET]
    mov x8, #PI4_VIBE_INPUT_SOURCE_UNKNOWN
    cbz x7, .Lpi4_runtime_decode_key_source_ready
    mov x8, #PI4_VIBE_INPUT_SOURCE_USB_HID_KEYBOARD
.Lpi4_runtime_decode_key_source_ready:
    str x8, [x1, #PI4_VIBE_INPUT_EVENT_VALUE2_OFFSET]
.Lpi4_runtime_normalize_input_event:
    ldr x4, [x1, #PI4_VIBE_INPUT_EVENT_TYPE_OFFSET]
    cmp x4, #PI4_VIBE_INPUT_EVENT_KEY
    b.eq .Lpi4_runtime_normalize_key_event
    cmp x4, #PI4_VIBE_INPUT_EVENT_MOUSE_PACKET
    b.eq .Lpi4_runtime_normalize_mouse_event
    cmp x4, #PI4_VIBE_INPUT_EVENT_UART
    b.eq .Lpi4_runtime_normalize_uart_event
    b .Lpi4_runtime_decode_input_done
.Lpi4_runtime_normalize_key_event:
    ldr x5, [x1, #PI4_VIBE_INPUT_EVENT_DEVICE_ID_OFFSET]
    ldr x6, [x1, #PI4_VIBE_INPUT_EVENT_VALUE1_OFFSET]
    ldr x7, [x1, #PI4_VIBE_INPUT_EVENT_VALUE2_OFFSET]
    cmp x7, #PI4_VIBE_INPUT_SOURCE_USB_HID_KEYBOARD
    b.eq .Lpi4_runtime_normalize_key_logical
    cmp x5, #PI4_VIBE_INPUT_DEVICE_USB
    b.eq .Lpi4_runtime_normalize_key_usb_source
    cbz x6, .Lpi4_runtime_decode_input_done
.Lpi4_runtime_normalize_key_usb_source:
    mov x7, #PI4_VIBE_INPUT_SOURCE_USB_HID_KEYBOARD
    str x7, [x1, #PI4_VIBE_INPUT_EVENT_VALUE2_OFFSET]
.Lpi4_runtime_normalize_key_logical:
    mov x8, #PI4_VIBE_INPUT_DEVICE_KEYBOARD
    str x8, [x1, #PI4_VIBE_INPUT_EVENT_DEVICE_ID_OFFSET]
    b .Lpi4_runtime_decode_input_done
.Lpi4_runtime_normalize_mouse_event:
    ldr x6, [x1, #PI4_VIBE_INPUT_EVENT_CODE_OFFSET]
    and x6, x6, #PI4_VIBE_INPUT_MOUSE_BUTTON_MASK
    str x6, [x1, #PI4_VIBE_INPUT_EVENT_CODE_OFFSET]
    ldr x5, [x1, #PI4_VIBE_INPUT_EVENT_DEVICE_ID_OFFSET]
    ldr x7, [x1, #PI4_VIBE_INPUT_EVENT_VALUE2_OFFSET]
    cmp x7, #PI4_VIBE_INPUT_SOURCE_USB_HID_MOUSE
    b.eq .Lpi4_runtime_normalize_mouse_logical
    cmp x5, #PI4_VIBE_INPUT_DEVICE_USB
    b.ne .Lpi4_runtime_decode_input_done
    mov x7, #PI4_VIBE_INPUT_SOURCE_USB_HID_MOUSE
    str x7, [x1, #PI4_VIBE_INPUT_EVENT_VALUE2_OFFSET]
.Lpi4_runtime_normalize_mouse_logical:
    mov x8, #PI4_VIBE_INPUT_DEVICE_MOUSE
    str x8, [x1, #PI4_VIBE_INPUT_EVENT_DEVICE_ID_OFFSET]
    b .Lpi4_runtime_decode_input_done
.Lpi4_runtime_normalize_uart_event:
    mov x8, #PI4_VIBE_INPUT_DEVICE_UART
    str x8, [x1, #PI4_VIBE_INPUT_EVENT_DEVICE_ID_OFFSET]
    ldr x7, [x1, #PI4_VIBE_INPUT_EVENT_VALUE2_OFFSET]
    cbnz x7, .Lpi4_runtime_decode_input_done
    mov x7, #PI4_VIBE_INPUT_SOURCE_UART_SERIAL
    str x7, [x1, #PI4_VIBE_INPUT_EVENT_VALUE2_OFFSET]
.Lpi4_runtime_decode_input_done:
    ret

.balign 16
.global vibe_user_input_event_source
.type vibe_user_input_event_source, %function
vibe_user_input_event_source:
    cbz x0, .Lpi4_runtime_input_event_source_unknown
    ldr x0, [x0, #PI4_VIBE_INPUT_EVENT_VALUE2_OFFSET]
    ret
.Lpi4_runtime_input_event_source_unknown:
    mov x0, #PI4_VIBE_INPUT_SOURCE_UNKNOWN
    ret
.size vibe_user_input_event_source, . - vibe_user_input_event_source

.balign 16
.global vibe_user_input_event_physical_device_id
.type vibe_user_input_event_physical_device_id, %function
vibe_user_input_event_physical_device_id:
    cbz x0, .Lpi4_runtime_input_event_device_none
    ldr x1, [x0, #PI4_VIBE_INPUT_EVENT_VALUE2_OFFSET]
    cmp x1, #PI4_VIBE_INPUT_SOURCE_USB_HID_KEYBOARD
    b.eq .Lpi4_runtime_input_event_physical_usb
    cmp x1, #PI4_VIBE_INPUT_SOURCE_USB_HID_MOUSE
    b.eq .Lpi4_runtime_input_event_physical_usb
    cmp x1, #PI4_VIBE_INPUT_SOURCE_UART_SERIAL
    b.eq .Lpi4_runtime_input_event_physical_uart
    cmp x1, #PI4_VIBE_INPUT_SOURCE_MSMOUSE
    b.eq .Lpi4_runtime_input_event_physical_mouse
    ldr x0, [x0, #PI4_VIBE_INPUT_EVENT_DEVICE_ID_OFFSET]
    ret
.Lpi4_runtime_input_event_physical_usb:
    mov x0, #PI4_VIBE_INPUT_DEVICE_USB
    ret
.Lpi4_runtime_input_event_physical_uart:
    mov x0, #PI4_VIBE_INPUT_DEVICE_UART
    ret
.Lpi4_runtime_input_event_physical_mouse:
    mov x0, #PI4_VIBE_INPUT_DEVICE_MOUSE
    ret
.Lpi4_runtime_input_event_device_none:
    mov x0, xzr
    ret
.size vibe_user_input_event_physical_device_id, . - vibe_user_input_event_physical_device_id

.balign 16
.global vibe_user_input_event_logical_device_id
.type vibe_user_input_event_logical_device_id, %function
vibe_user_input_event_logical_device_id:
    cbz x0, .Lpi4_runtime_input_event_device_none
    ldr x1, [x0, #PI4_VIBE_INPUT_EVENT_VALUE2_OFFSET]
    cmp x1, #PI4_VIBE_INPUT_SOURCE_USB_HID_KEYBOARD
    b.eq .Lpi4_runtime_input_event_logical_keyboard
    cmp x1, #PI4_VIBE_INPUT_SOURCE_USB_HID_MOUSE
    b.eq .Lpi4_runtime_input_event_logical_mouse
    cmp x1, #PI4_VIBE_INPUT_SOURCE_MSMOUSE
    b.eq .Lpi4_runtime_input_event_logical_mouse
    cmp x1, #PI4_VIBE_INPUT_SOURCE_UART_SERIAL
    b.eq .Lpi4_runtime_input_event_logical_uart
    ldr x2, [x0, #PI4_VIBE_INPUT_EVENT_TYPE_OFFSET]
    cmp x2, #PI4_VIBE_INPUT_EVENT_KEY
    b.eq .Lpi4_runtime_input_event_logical_key_type
    cmp x2, #PI4_VIBE_INPUT_EVENT_MOUSE_PACKET
    b.eq .Lpi4_runtime_input_event_logical_mouse_type
    cmp x2, #PI4_VIBE_INPUT_EVENT_UART
    b.eq .Lpi4_runtime_input_event_logical_uart_type
    ldr x0, [x0, #PI4_VIBE_INPUT_EVENT_DEVICE_ID_OFFSET]
    ret
.Lpi4_runtime_input_event_logical_key_type:
    ldr x1, [x0, #PI4_VIBE_INPUT_EVENT_DEVICE_ID_OFFSET]
    cmp x1, #PI4_VIBE_INPUT_DEVICE_KEYBOARD
    b.eq .Lpi4_runtime_input_event_logical_keyboard
    cmp x1, #PI4_VIBE_INPUT_DEVICE_USB
    b.eq .Lpi4_runtime_input_event_logical_keyboard
    ldr x0, [x0, #PI4_VIBE_INPUT_EVENT_DEVICE_ID_OFFSET]
    ret
.Lpi4_runtime_input_event_logical_mouse_type:
    ldr x1, [x0, #PI4_VIBE_INPUT_EVENT_DEVICE_ID_OFFSET]
    cmp x1, #PI4_VIBE_INPUT_DEVICE_MOUSE
    b.eq .Lpi4_runtime_input_event_logical_mouse
    cmp x1, #PI4_VIBE_INPUT_DEVICE_USB
    b.eq .Lpi4_runtime_input_event_logical_mouse
    ldr x0, [x0, #PI4_VIBE_INPUT_EVENT_DEVICE_ID_OFFSET]
    ret
.Lpi4_runtime_input_event_logical_uart_type:
    ldr x1, [x0, #PI4_VIBE_INPUT_EVENT_DEVICE_ID_OFFSET]
    cmp x1, #PI4_VIBE_INPUT_DEVICE_UART
    b.eq .Lpi4_runtime_input_event_logical_uart
    ldr x0, [x0, #PI4_VIBE_INPUT_EVENT_DEVICE_ID_OFFSET]
    ret
.Lpi4_runtime_input_event_logical_keyboard:
    mov x0, #PI4_VIBE_INPUT_DEVICE_KEYBOARD
    ret
.Lpi4_runtime_input_event_logical_mouse:
    mov x0, #PI4_VIBE_INPUT_DEVICE_MOUSE
    ret
.Lpi4_runtime_input_event_logical_uart:
    mov x0, #PI4_VIBE_INPUT_DEVICE_UART
    ret
.size vibe_user_input_event_logical_device_id, . - vibe_user_input_event_logical_device_id

.balign 16
.global vibe_user_input_event_is_key
.type vibe_user_input_event_is_key, %function
vibe_user_input_event_is_key:
    cbz x0, .Lpi4_runtime_input_event_bool_false
    ldr x1, [x0, #PI4_VIBE_INPUT_EVENT_TYPE_OFFSET]
    cmp x1, #PI4_VIBE_INPUT_EVENT_KEY
    b.ne .Lpi4_runtime_input_event_bool_false
    b .Lpi4_runtime_input_event_is_logical_keyboard
.size vibe_user_input_event_is_key, . - vibe_user_input_event_is_key

.balign 16
.global vibe_user_input_event_is_mouse_packet
.type vibe_user_input_event_is_mouse_packet, %function
vibe_user_input_event_is_mouse_packet:
    cbz x0, .Lpi4_runtime_input_event_bool_false
    ldr x1, [x0, #PI4_VIBE_INPUT_EVENT_TYPE_OFFSET]
    cmp x1, #PI4_VIBE_INPUT_EVENT_MOUSE_PACKET
    b.ne .Lpi4_runtime_input_event_bool_false
    b .Lpi4_runtime_input_event_is_logical_mouse
.size vibe_user_input_event_is_mouse_packet, . - vibe_user_input_event_is_mouse_packet

.balign 16
.global vibe_user_input_event_is_uart_serial
.type vibe_user_input_event_is_uart_serial, %function
vibe_user_input_event_is_uart_serial:
    cbz x0, .Lpi4_runtime_input_event_bool_false
    ldr x1, [x0, #PI4_VIBE_INPUT_EVENT_TYPE_OFFSET]
    cmp x1, #PI4_VIBE_INPUT_EVENT_UART
    b.ne .Lpi4_runtime_input_event_bool_false
    b .Lpi4_runtime_input_event_is_logical_uart
.size vibe_user_input_event_is_uart_serial, . - vibe_user_input_event_is_uart_serial

.balign 16
.global vibe_user_input_event_is_usb_hid
.type vibe_user_input_event_is_usb_hid, %function
vibe_user_input_event_is_usb_hid:
    cbz x0, .Lpi4_runtime_input_event_bool_false
    ldr x1, [x0, #PI4_VIBE_INPUT_EVENT_VALUE2_OFFSET]
    cmp x1, #PI4_VIBE_INPUT_SOURCE_USB_HID_KEYBOARD
    b.eq .Lpi4_runtime_input_event_bool_true
    cmp x1, #PI4_VIBE_INPUT_SOURCE_USB_HID_MOUSE
    b.eq .Lpi4_runtime_input_event_bool_true
    b .Lpi4_runtime_input_event_bool_false
.size vibe_user_input_event_is_usb_hid, . - vibe_user_input_event_is_usb_hid

.Lpi4_runtime_input_event_is_logical_keyboard:
    ldr x1, [x0, #PI4_VIBE_INPUT_EVENT_VALUE2_OFFSET]
    cmp x1, #PI4_VIBE_INPUT_SOURCE_USB_HID_KEYBOARD
    b.eq .Lpi4_runtime_input_event_bool_true
    ldr x1, [x0, #PI4_VIBE_INPUT_EVENT_DEVICE_ID_OFFSET]
    cmp x1, #PI4_VIBE_INPUT_DEVICE_KEYBOARD
    b.eq .Lpi4_runtime_input_event_bool_true
    cmp x1, #PI4_VIBE_INPUT_DEVICE_USB
    b.eq .Lpi4_runtime_input_event_bool_true
    b .Lpi4_runtime_input_event_bool_false

.Lpi4_runtime_input_event_is_logical_mouse:
    ldr x1, [x0, #PI4_VIBE_INPUT_EVENT_VALUE2_OFFSET]
    cmp x1, #PI4_VIBE_INPUT_SOURCE_USB_HID_MOUSE
    b.eq .Lpi4_runtime_input_event_bool_true
    cmp x1, #PI4_VIBE_INPUT_SOURCE_MSMOUSE
    b.eq .Lpi4_runtime_input_event_bool_true
    ldr x1, [x0, #PI4_VIBE_INPUT_EVENT_DEVICE_ID_OFFSET]
    cmp x1, #PI4_VIBE_INPUT_DEVICE_MOUSE
    b.eq .Lpi4_runtime_input_event_bool_true
    cmp x1, #PI4_VIBE_INPUT_DEVICE_USB
    b.eq .Lpi4_runtime_input_event_bool_true
    b .Lpi4_runtime_input_event_bool_false

.Lpi4_runtime_input_event_is_logical_uart:
    ldr x1, [x0, #PI4_VIBE_INPUT_EVENT_VALUE2_OFFSET]
    cmp x1, #PI4_VIBE_INPUT_SOURCE_UART_SERIAL
    b.eq .Lpi4_runtime_input_event_bool_true
    ldr x1, [x0, #PI4_VIBE_INPUT_EVENT_DEVICE_ID_OFFSET]
    cmp x1, #PI4_VIBE_INPUT_DEVICE_UART
    b.eq .Lpi4_runtime_input_event_bool_true
    b .Lpi4_runtime_input_event_bool_false

.Lpi4_runtime_input_event_bool_true:
    mov x0, #1
    ret
.Lpi4_runtime_input_event_bool_false:
    mov x0, xzr
    ret

.balign 16
.global vibe_user_drain_input
.type vibe_user_drain_input, %function
vibe_user_drain_input:
    cbz x0, .Lpi4_runtime_inval
    cbz x1, .Lpi4_runtime_drain_zero
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    mov x19, x0
    mov x20, x1
    mov x21, xzr
.Lpi4_runtime_drain_next:
    mov x0, x19
    bl vibe_user_poll_input
    cmp x0, #0
    b.lt .Lpi4_runtime_drain_error
    cbz x0, .Lpi4_runtime_drain_done
    add x21, x21, #1
    cmp x21, x20
    b.hs .Lpi4_runtime_drain_done
    add x19, x19, #PI4_VIBE_INPUT_EVENT_BYTES
    b .Lpi4_runtime_drain_next
.Lpi4_runtime_drain_error:
    cbnz x21, .Lpi4_runtime_drain_done
    mov x21, x0
.Lpi4_runtime_drain_done:
    mov x0, x21
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret
.Lpi4_runtime_drain_zero:
    mov x0, xzr
    ret
.size vibe_user_drain_input, . - vibe_user_drain_input

.balign 16
.global vibe_user_input_status
.type vibe_user_input_status, %function
vibe_user_input_status:
    cbz x0, .Lpi4_runtime_inval
    mov x1, #PI4_VIBE_INPUT_STATUS_BYTES
    mov x2, xzr
    mov x8, #PI4_VIBE_SYS_INPUT_STATUS
    svc #PI4_VIBE_SVC_IMM
    ret
.size vibe_user_input_status, . - vibe_user_input_status

.balign 16
.global vibe_user_input_device_status
.type vibe_user_input_device_status, %function
vibe_user_input_device_status:
    cbz x1, .Lpi4_runtime_inval
    mov x2, #PI4_VIBE_INPUT_DEVICE_STATUS_BYTES
    mov x8, #PI4_VIBE_SYS_INPUT_DEVICE_STATUS
    svc #PI4_VIBE_SVC_IMM
    ret
.size vibe_user_input_device_status, . - vibe_user_input_device_status

.balign 16
.global vibe_user_input_keyboard_status
.type vibe_user_input_keyboard_status, %function
vibe_user_input_keyboard_status:
    mov x1, x0
    mov x0, #PI4_VIBE_INPUT_DEVICE_KEYBOARD
    b vibe_user_input_device_status
.size vibe_user_input_keyboard_status, . - vibe_user_input_keyboard_status

.balign 16
.global vibe_user_input_mouse_status
.type vibe_user_input_mouse_status, %function
vibe_user_input_mouse_status:
    mov x1, x0
    mov x0, #PI4_VIBE_INPUT_DEVICE_MOUSE
    b vibe_user_input_device_status
.size vibe_user_input_mouse_status, . - vibe_user_input_mouse_status

.balign 16
.global vibe_user_input_uart_status
.type vibe_user_input_uart_status, %function
vibe_user_input_uart_status:
    mov x1, x0
    mov x0, #PI4_VIBE_INPUT_DEVICE_UART
    b vibe_user_input_device_status
.size vibe_user_input_uart_status, . - vibe_user_input_uart_status

.balign 16
.global vibe_user_input_usb_status
.type vibe_user_input_usb_status, %function
vibe_user_input_usb_status:
    mov x1, x0
    mov x0, #PI4_VIBE_INPUT_DEVICE_USB
    b vibe_user_input_device_status
.size vibe_user_input_usb_status, . - vibe_user_input_usb_status

.balign 16
.global vibe_user_clock_gettime
.type vibe_user_clock_gettime, %function
vibe_user_clock_gettime:
    cbz x1, .Lpi4_runtime_inval
    mov x2, #PI4_VIBE_CLOCK_TIME_BYTES
    mov x8, #PI4_VIBE_SYS_CLOCK_GETTIME
    svc #PI4_VIBE_SVC_IMM
    ret
.size vibe_user_clock_gettime, . - vibe_user_clock_gettime

.balign 16
.global vibe_user_clock_monotonic
.type vibe_user_clock_monotonic, %function
vibe_user_clock_monotonic:
    cbz x0, .Lpi4_runtime_inval
    mov x1, x0
    mov x0, #PI4_VIBE_CLOCK_MONOTONIC
    b vibe_user_clock_gettime
.size vibe_user_clock_monotonic, . - vibe_user_clock_monotonic

.balign 16
.global vibe_user_monotonic_ticks
.type vibe_user_monotonic_ticks, %function
vibe_user_monotonic_ticks:
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    mov x0, #PI4_VIBE_CLOCK_MONOTONIC
    add x1, sp, #16
    bl vibe_user_clock_gettime
    cbnz x0, .Lpi4_runtime_ticks_fail
    ldr x0, [sp, #(16 + PI4_VIBE_CLOCK_TIME_TICKS_OFFSET)]
    b .Lpi4_runtime_ticks_done
.Lpi4_runtime_ticks_fail:
    mov x0, xzr
.Lpi4_runtime_ticks_done:
    ldp x29, x30, [sp], #48
    ret
.size vibe_user_monotonic_ticks, . - vibe_user_monotonic_ticks

.balign 16
.global vibe_user_monotonic_milliseconds
.type vibe_user_monotonic_milliseconds, %function
vibe_user_monotonic_milliseconds:
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    mov x0, #PI4_VIBE_CLOCK_MONOTONIC
    add x1, sp, #16
    bl vibe_user_clock_gettime
    cbnz x0, .Lpi4_runtime_milliseconds_fail
    ldr x0, [sp, #(16 + PI4_VIBE_CLOCK_TIME_MILLISECONDS_OFFSET)]
    b .Lpi4_runtime_milliseconds_done
.Lpi4_runtime_milliseconds_fail:
    mov x0, xzr
.Lpi4_runtime_milliseconds_done:
    ldp x29, x30, [sp], #48
    ret
.size vibe_user_monotonic_milliseconds, . - vibe_user_monotonic_milliseconds

.balign 16
.global vibe_user_clock_ticks_to_milliseconds
.type vibe_user_clock_ticks_to_milliseconds, %function
vibe_user_clock_ticks_to_milliseconds:
    cbz x1, .Lpi4_runtime_ticks_to_ms_zero
    udiv x2, x0, x1
    msub x0, x2, x1, x0
    mov x3, #1000
    mul x2, x2, x3
    mul x0, x0, x3
    udiv x0, x0, x1
    add x0, x0, x2
    ret
.Lpi4_runtime_ticks_to_ms_zero:
    mov x0, xzr
    ret
.size vibe_user_clock_ticks_to_milliseconds, . - vibe_user_clock_ticks_to_milliseconds

.balign 16
.weak clock
.type clock, %function
clock:
    b vibe_user_monotonic_milliseconds
.size clock, . - clock

.balign 16
.weak clock_gettime
.type clock_gettime, %function
clock_gettime:
    cbz x1, .Lpi4_runtime_inval
    cmp x0, #PI4_VIBE_CLOCK_MONOTONIC
    b.ne .Lpi4_runtime_inval
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    str x19, [sp, #16]
    mov x19, x1
    add x1, sp, #24
    bl vibe_user_clock_monotonic
    cbnz x0, .Lpi4_runtime_clock_gettime_done
    ldr x9, [sp, #(24 + PI4_VIBE_CLOCK_TIME_MILLISECONDS_OFFSET)]
    mov x10, #1000
    udiv x11, x9, x10
    msub x9, x11, x10, x9
    str x11, [x19]
    mov x10, #0x4240
    movk x10, #0xf, lsl #16
    mul x9, x9, x10
    str x9, [x19, #8]
.Lpi4_runtime_clock_gettime_done:
    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #64
    ret
.size clock_gettime, . - clock_gettime

.balign 16
.global vibe_user_audio_device_start
.type vibe_user_audio_device_start, %function
vibe_user_audio_device_start:
    mov x0, #PI4_VIBE_AUDIO_DEVICE_START
    mov x1, xzr
    mov x2, xzr
    mov x8, #PI4_VIBE_SYS_AUDIO
    svc #PI4_VIBE_SVC_IMM
    ret
.size vibe_user_audio_device_start, . - vibe_user_audio_device_start

.balign 16
.global vibe_user_audio_device_shutdown
.type vibe_user_audio_device_shutdown, %function
vibe_user_audio_device_shutdown:
    mov x0, #PI4_VIBE_AUDIO_DEVICE_SHUTDOWN
    mov x1, xzr
    mov x2, xzr
    mov x8, #PI4_VIBE_SYS_AUDIO
    svc #PI4_VIBE_SVC_IMM
    ret
.size vibe_user_audio_device_shutdown, . - vibe_user_audio_device_shutdown

.balign 16
.global vibe_user_audio_mixer_start
.type vibe_user_audio_mixer_start, %function
vibe_user_audio_mixer_start:
    cbz x1, .Lpi4_runtime_inval
    mov x2, x1
    mov x1, x0
    mov x0, #PI4_VIBE_AUDIO_MIXER_START
    mov x8, #PI4_VIBE_SYS_AUDIO
    svc #PI4_VIBE_SVC_IMM
    ret
.size vibe_user_audio_mixer_start, . - vibe_user_audio_mixer_start

.balign 16
.global vibe_user_audio_mixer_stop
.type vibe_user_audio_mixer_stop, %function
vibe_user_audio_mixer_stop:
    mov x1, x0
    mov x0, #PI4_VIBE_AUDIO_MIXER_STOP
    mov x2, xzr
    mov x8, #PI4_VIBE_SYS_AUDIO
    svc #PI4_VIBE_SVC_IMM
    ret
.size vibe_user_audio_mixer_stop, . - vibe_user_audio_mixer_stop

.balign 16
.global vibe_user_audio_mixer_update
.type vibe_user_audio_mixer_update, %function
vibe_user_audio_mixer_update:
    cbz x1, .Lpi4_runtime_inval
    mov x2, x1
    mov x1, x0
    mov x0, #PI4_VIBE_AUDIO_MIXER_UPDATE
    mov x8, #PI4_VIBE_SYS_AUDIO
    svc #PI4_VIBE_SVC_IMM
    ret
.size vibe_user_audio_mixer_update, . - vibe_user_audio_mixer_update

.balign 16
.global vibe_user_audio_mixer_is_playing
.type vibe_user_audio_mixer_is_playing, %function
vibe_user_audio_mixer_is_playing:
    mov x1, x0
    mov x0, #PI4_VIBE_AUDIO_MIXER_IS_PLAYING
    mov x2, xzr
    mov x8, #PI4_VIBE_SYS_AUDIO
    svc #PI4_VIBE_SVC_IMM
    ret
.size vibe_user_audio_mixer_is_playing, . - vibe_user_audio_mixer_is_playing

.balign 16
.global vibe_user_audio_pcm_buffered_bytes
.type vibe_user_audio_pcm_buffered_bytes, %function
vibe_user_audio_pcm_buffered_bytes:
    mov x1, x0
    mov x0, #PI4_VIBE_AUDIO_PCM_BUFFERED_BYTES
    mov x2, xzr
    mov x8, #PI4_VIBE_SYS_AUDIO
    svc #PI4_VIBE_SVC_IMM
    ret
.size vibe_user_audio_pcm_buffered_bytes, . - vibe_user_audio_pcm_buffered_bytes

.balign 16
.global vibe_user_audio_pcm_pull_state
.type vibe_user_audio_pcm_pull_state, %function
vibe_user_audio_pcm_pull_state:
    mov x1, x0
    mov x0, #PI4_VIBE_AUDIO_PCM_PULL_STATE
    mov x2, xzr
    mov x8, #PI4_VIBE_SYS_AUDIO
    svc #PI4_VIBE_SVC_IMM
    ret
.size vibe_user_audio_pcm_pull_state, . - vibe_user_audio_pcm_pull_state

.balign 16
.global vibe_user_audio_device_info
.type vibe_user_audio_device_info, %function
vibe_user_audio_device_info:
    cbz x0, .Lpi4_runtime_inval
    mov x1, x0
    mov x0, #PI4_VIBE_AUDIO_DEVICE_INFO
    mov x2, xzr
    mov x8, #PI4_VIBE_SYS_AUDIO
    svc #PI4_VIBE_SVC_IMM
    ret
.size vibe_user_audio_device_info, . - vibe_user_audio_device_info

.balign 16
.global vibe_user_audio_pcm_ring_info
.type vibe_user_audio_pcm_ring_info, %function
vibe_user_audio_pcm_ring_info:
    cbz x0, .Lpi4_runtime_inval
    mov x1, x0
    mov x0, #PI4_VIBE_AUDIO_PCM_RING_INFO
    mov x2, xzr
    mov x8, #PI4_VIBE_SYS_AUDIO
    svc #PI4_VIBE_SVC_IMM
    ret
.size vibe_user_audio_pcm_ring_info, . - vibe_user_audio_pcm_ring_info

.balign 16
.global vibe_user_audio_stream_info
.type vibe_user_audio_stream_info, %function
vibe_user_audio_stream_info:
    cbz x1, .Lpi4_runtime_inval
    mov x2, x1
    mov x1, x0
    mov x0, #PI4_VIBE_AUDIO_STREAM_INFO
    mov x8, #PI4_VIBE_SYS_AUDIO
    svc #PI4_VIBE_SVC_IMM
    ret
.size vibe_user_audio_stream_info, . - vibe_user_audio_stream_info

.balign 16
.global vibe_user_audio_device_info_ioctl
.type vibe_user_audio_device_info_ioctl, %function
vibe_user_audio_device_info_ioctl:
    cbz x0, .Lpi4_runtime_inval
    mov x2, x0
    mov x0, #PI4_VIBE_AUDIO_FD
    mov x1, #PI4_VIBE_IOCTL_AUDIO_DEVICE_INFO
    b vibe_user_ioctl
.size vibe_user_audio_device_info_ioctl, . - vibe_user_audio_device_info_ioctl

.balign 16
.global vibe_user_audio_pcm_ring_info_ioctl
.type vibe_user_audio_pcm_ring_info_ioctl, %function
vibe_user_audio_pcm_ring_info_ioctl:
    cbz x0, .Lpi4_runtime_inval
    mov x2, x0
    mov x0, #PI4_VIBE_AUDIO_FD
    mov x1, #PI4_VIBE_IOCTL_AUDIO_PCM_RING_INFO
    b vibe_user_ioctl
.size vibe_user_audio_pcm_ring_info_ioctl, . - vibe_user_audio_pcm_ring_info_ioctl

.balign 16
.global vibe_user_audio_stream_info_ioctl
.type vibe_user_audio_stream_info_ioctl, %function
vibe_user_audio_stream_info_ioctl:
    cbz x1, .Lpi4_runtime_inval
    str x0, [x1, #PI4_VIBE_AUDIO_STREAM_INFO_HANDLE_OFFSET]
    mov x2, x1
    mov x0, #PI4_VIBE_AUDIO_FD
    mov x1, #PI4_VIBE_IOCTL_AUDIO_STREAM_INFO
    b vibe_user_ioctl
.size vibe_user_audio_stream_info_ioctl, . - vibe_user_audio_stream_info_ioctl

.balign 16
.global vibe_user_audio_pcm_open
.global vibe_user_audio_stream_open
.type vibe_user_audio_pcm_open, %function
.type vibe_user_audio_stream_open, %function
vibe_user_audio_pcm_open:
vibe_user_audio_stream_open:
    mov x2, x0
    mov x0, #PI4_VIBE_AUDIO_PCM_OPEN
    mov x1, xzr
    mov x8, #PI4_VIBE_SYS_AUDIO
    svc #PI4_VIBE_SVC_IMM
    ret
.size vibe_user_audio_pcm_open, . - vibe_user_audio_pcm_open
.size vibe_user_audio_stream_open, . - vibe_user_audio_stream_open

.balign 16
.global vibe_user_audio_pcm_write
.global vibe_user_audio_stream_write
.type vibe_user_audio_pcm_write, %function
.type vibe_user_audio_stream_write, %function
vibe_user_audio_pcm_write:
vibe_user_audio_stream_write:
    cbz x0, .Lpi4_runtime_inval
    cbz x1, .Lpi4_runtime_inval
    mov x2, x1
    mov x1, x0
    mov x0, #PI4_VIBE_AUDIO_PCM_WRITE
    mov x8, #PI4_VIBE_SYS_AUDIO
    svc #PI4_VIBE_SVC_IMM
    ret
.size vibe_user_audio_pcm_write, . - vibe_user_audio_pcm_write
.size vibe_user_audio_stream_write, . - vibe_user_audio_stream_write

.balign 16
.global vibe_user_audio_pcm_write_desc
.type vibe_user_audio_pcm_write_desc, %function
vibe_user_audio_pcm_write_desc:
    cbz x0, .Lpi4_runtime_inval
    cbz x1, .Lpi4_runtime_inval
    mov x2, x1
    mov x1, x0
    mov x0, #PI4_VIBE_AUDIO_PCM_WRITE_DESC
    mov x8, #PI4_VIBE_SYS_AUDIO
    svc #PI4_VIBE_SVC_IMM
    ret
.size vibe_user_audio_pcm_write_desc, . - vibe_user_audio_pcm_write_desc

.balign 16
.global vibe_user_audio_pcm_drain
.global vibe_user_audio_stream_drain
.type vibe_user_audio_pcm_drain, %function
.type vibe_user_audio_stream_drain, %function
vibe_user_audio_pcm_drain:
vibe_user_audio_stream_drain:
    cbz x0, .Lpi4_runtime_inval
    mov x1, x0
    mov x0, #PI4_VIBE_AUDIO_PCM_DRAIN
    mov x2, xzr
    mov x8, #PI4_VIBE_SYS_AUDIO
    svc #PI4_VIBE_SVC_IMM
    ret
.size vibe_user_audio_pcm_drain, . - vibe_user_audio_pcm_drain
.size vibe_user_audio_stream_drain, . - vibe_user_audio_stream_drain

.balign 16
.global vibe_user_audio_pcm_close
.global vibe_user_audio_stream_close
.type vibe_user_audio_pcm_close, %function
.type vibe_user_audio_stream_close, %function
vibe_user_audio_pcm_close:
vibe_user_audio_stream_close:
    cbz x0, .Lpi4_runtime_inval
    mov x1, x0
    mov x0, #PI4_VIBE_AUDIO_PCM_CLOSE
    mov x2, xzr
    mov x8, #PI4_VIBE_SYS_AUDIO
    svc #PI4_VIBE_SVC_IMM
    ret
.size vibe_user_audio_pcm_close, . - vibe_user_audio_pcm_close
.size vibe_user_audio_stream_close, . - vibe_user_audio_stream_close

.balign 16
.global vibe_user_poll_uart_event
.global vibe_user_input_poll_uart_event
.type vibe_user_poll_uart_event, %function
.type vibe_user_input_poll_uart_event, %function
vibe_user_poll_uart_event:
vibe_user_input_poll_uart_event:
    cbz x0, .Lpi4_runtime_inval
    stp x29, x30, [sp, #-96]!
    mov x29, sp
    str x19, [sp, #16]
    mov x19, x0
    bl vibe_user_file_probe_assets
    str xzr, [x19]
    add x0, sp, #32
    bl vibe_user_poll_input
    cmp x0, #1
    b.ne .Lpi4_runtime_poll_uart_done
    ldr x1, [sp, #(32 + PI4_VIBE_INPUT_EVENT_DEVICE_ID_OFFSET)]
    cmp x1, #PI4_VIBE_INPUT_DEVICE_UART
    b.ne .Lpi4_runtime_poll_uart_none
    ldr x1, [sp, #(32 + PI4_VIBE_INPUT_EVENT_TYPE_OFFSET)]
    cmp x1, #PI4_VIBE_INPUT_EVENT_UART
    b.ne .Lpi4_runtime_poll_uart_none
    ldr x1, [sp, #(32 + PI4_VIBE_INPUT_EVENT_CODE_OFFSET)]
    str x1, [x19]
    mov x0, #1
    b .Lpi4_runtime_poll_uart_done
.Lpi4_runtime_poll_uart_none:
    mov x0, xzr
.Lpi4_runtime_poll_uart_done:
    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #96
    ret
.size vibe_user_poll_uart_event, . - vibe_user_poll_uart_event
.size vibe_user_input_poll_uart_event, . - vibe_user_input_poll_uart_event

.balign 16
.weak open
.type open, %function
open:
    mov x2, xzr
    b vibe_user_open
.size open, . - open

.balign 16
.weak read
.type read, %function
read:
    b vibe_user_read
.size read, . - read

.balign 16
.weak pread
.type pread, %function
pread:
    b vibe_user_pread
.size pread, . - pread

.balign 16
.weak write
.type write, %function
write:
    b vibe_user_write
.size write, . - write

.balign 16
.weak lseek
.type lseek, %function
lseek:
    b vibe_user_lseek
.size lseek, . - lseek

.balign 16
.weak close
.type close, %function
close:
    b vibe_user_close
.size close, . - close

.balign 16
.weak stat
.type stat, %function
stat:
    b vibe_user_stat
.size stat, . - stat

.balign 16
.weak fstat
.type fstat, %function
fstat:
    b vibe_user_fstat
.size fstat, . - fstat

.balign 16
.weak ioctl
.type ioctl, %function
ioctl:
    b vibe_user_ioctl
.size ioctl, . - ioctl

.balign 16
.weak exit
.type exit, %function
exit:
    b vibe_user_exit
.size exit, . - exit

.balign 16
.weak _exit
.type _exit, %function
_exit:
    b vibe_user_exit
.size _exit, . - _exit

.balign 16
.weak vibe_input_status
.type vibe_input_status, %function
vibe_input_status:
    b vibe_user_input_status
.size vibe_input_status, . - vibe_input_status

.balign 16
.weak vibe_input_device_status
.type vibe_input_device_status, %function
vibe_input_device_status:
    b vibe_user_input_device_status
.size vibe_input_device_status, . - vibe_input_device_status

.balign 16
.weak vibe_poll_input
.type vibe_poll_input, %function
vibe_poll_input:
    b vibe_user_poll_input
.size vibe_poll_input, . - vibe_poll_input

.balign 16
.weak vibe_drain_input
.type vibe_drain_input, %function
vibe_drain_input:
    b vibe_user_drain_input
.size vibe_drain_input, . - vibe_drain_input

.balign 16
.weak vibe_audio_device_info_ioctl
.type vibe_audio_device_info_ioctl, %function
vibe_audio_device_info_ioctl:
    b vibe_user_audio_device_info_ioctl
.size vibe_audio_device_info_ioctl, . - vibe_audio_device_info_ioctl

.balign 16
.weak vibe_audio_pcm_ring_info_ioctl
.type vibe_audio_pcm_ring_info_ioctl, %function
vibe_audio_pcm_ring_info_ioctl:
    b vibe_user_audio_pcm_ring_info_ioctl
.size vibe_audio_pcm_ring_info_ioctl, . - vibe_audio_pcm_ring_info_ioctl

.balign 16
.weak vibe_audio_stream_info_ioctl
.type vibe_audio_stream_info_ioctl, %function
vibe_audio_stream_info_ioctl:
    b vibe_user_audio_stream_info_ioctl
.size vibe_audio_stream_info_ioctl, . - vibe_audio_stream_info_ioctl

.Lpi4_runtime_zero_buffer:
    cbz x1, .Lpi4_runtime_zero_done
.Lpi4_runtime_zero_next:
    strb wzr, [x0], #1
    subs x1, x1, #1
    b.ne .Lpi4_runtime_zero_next
.Lpi4_runtime_zero_done:
    ret

.Lpi4_runtime_file_state:
    cmp x0, #PI4_VIBE_FD_DOOM1_WAD
    b.eq .Lpi4_runtime_file_state_doom
    cmp x0, #PI4_VIBE_FD_PAK0_PAK
    b.eq .Lpi4_runtime_file_state_pak
    mov x0, xzr
    mov x1, xzr
    ret
.Lpi4_runtime_file_state_doom:
    adrp x0, .Lpi4_runtime_doom_offset_shadow
    add x0, x0, :lo12:.Lpi4_runtime_doom_offset_shadow
    adrp x1, .Lpi4_runtime_doom1_wad_path
    add x1, x1, :lo12:.Lpi4_runtime_doom1_wad_path
    ret
.Lpi4_runtime_file_state_pak:
    adrp x0, .Lpi4_runtime_pak_offset_shadow
    add x0, x0, :lo12:.Lpi4_runtime_pak_offset_shadow
    adrp x1, .Lpi4_runtime_pak0_path
    add x1, x1, :lo12:.Lpi4_runtime_pak0_path
    ret

.Lpi4_runtime_normalize_asset_path:
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    str x21, [sp, #32]
    mov x19, x0
    mov x20, x1
    mov x21, x2

    mov x0, x19
    adrp x1, .Lpi4_runtime_doom1_wad_path
    add x1, x1, :lo12:.Lpi4_runtime_doom1_wad_path
    bl .Lpi4_runtime_path_suffix_eq
    cbnz x0, .Lpi4_runtime_normalize_doom

    mov x0, x19
    adrp x1, .Lpi4_runtime_pak0_suffix
    add x1, x1, :lo12:.Lpi4_runtime_pak0_suffix
    bl .Lpi4_runtime_path_suffix_eq
    cbnz x0, .Lpi4_runtime_normalize_pak

    mov x0, x19
    b .Lpi4_runtime_normalize_done

.Lpi4_runtime_normalize_doom:
    adrp x0, .Lpi4_runtime_doom1_wad_path
    add x0, x0, :lo12:.Lpi4_runtime_doom1_wad_path
    b .Lpi4_runtime_normalize_done

.Lpi4_runtime_normalize_pak:
    adrp x0, .Lpi4_runtime_pak0_path
    add x0, x0, :lo12:.Lpi4_runtime_pak0_path

.Lpi4_runtime_normalize_done:
    mov x1, x20
    mov x2, x21
    ldr x21, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret

.Lpi4_runtime_inval:
    mov x0, #-PI4_VIBE_EINVAL
    ret

.Lpi4_runtime_path_suffix_eq:
    cbz x0, .Lpi4_runtime_path_suffix_eq_no
    cbz x1, .Lpi4_runtime_path_suffix_eq_no
    mov x9, x0
    mov x10, x1
    mov x11, xzr
.Lpi4_runtime_path_suffix_path_len_next:
    cmp x11, #PI4_VIBE_PATH_NORMALIZE_MAX_BYTES
    b.hs .Lpi4_runtime_path_suffix_eq_no
    ldrb w12, [x9, x11]
    cbz w12, .Lpi4_runtime_path_suffix_path_len_done
    add x11, x11, #1
    b .Lpi4_runtime_path_suffix_path_len_next
.Lpi4_runtime_path_suffix_path_len_done:
    mov x12, xzr
.Lpi4_runtime_path_suffix_suffix_len_next:
    cmp x12, #PI4_VIBE_PATH_NORMALIZE_MAX_BYTES
    b.hs .Lpi4_runtime_path_suffix_eq_no
    ldrb w13, [x10, x12]
    cbz w13, .Lpi4_runtime_path_suffix_suffix_len_done
    add x12, x12, #1
    b .Lpi4_runtime_path_suffix_suffix_len_next
.Lpi4_runtime_path_suffix_suffix_len_done:
    cbz x12, .Lpi4_runtime_path_suffix_eq_no
    cmp x11, x12
    b.lo .Lpi4_runtime_path_suffix_eq_no
    sub x13, x11, x12
    cbz x13, .Lpi4_runtime_path_suffix_compare
    sub x14, x13, #1
    ldrb w15, [x9, x14]
    cmp w15, #0x2f
    b.eq .Lpi4_runtime_path_suffix_compare
    cmp w15, #0x5c
    b.ne .Lpi4_runtime_path_suffix_eq_no

.Lpi4_runtime_path_suffix_compare:
    mov x14, xzr
.Lpi4_runtime_path_suffix_compare_next:
    cmp x14, x12
    b.hs .Lpi4_runtime_path_suffix_eq_yes
    ldrb w15, [x9, x13]
    ldrb w16, [x10, x14]
    cmp w15, #0x5c
    b.ne .Lpi4_runtime_path_suffix_left_sep_folded
    mov w15, #0x2f
.Lpi4_runtime_path_suffix_left_sep_folded:
    cmp w16, #0x5c
    b.ne .Lpi4_runtime_path_suffix_right_sep_folded
    mov w16, #0x2f
.Lpi4_runtime_path_suffix_right_sep_folded:
    sub w17, w15, #0x61
    cmp w17, #25
    b.hi .Lpi4_runtime_path_suffix_left_case_folded
    sub w15, w15, #0x20
.Lpi4_runtime_path_suffix_left_case_folded:
    sub w17, w16, #0x61
    cmp w17, #25
    b.hi .Lpi4_runtime_path_suffix_right_case_folded
    sub w16, w16, #0x20
.Lpi4_runtime_path_suffix_right_case_folded:
    cmp w15, w16
    b.ne .Lpi4_runtime_path_suffix_eq_no
    add x13, x13, #1
    add x14, x14, #1
    b .Lpi4_runtime_path_suffix_compare_next
.Lpi4_runtime_path_suffix_eq_yes:
    mov x0, #1
    ret
.Lpi4_runtime_path_suffix_eq_no:
    mov x0, xzr
    ret

.Lpi4_runtime_path_eq16:
    mov x2, xzr
.Lpi4_runtime_path_eq16_next:
    ldrb w3, [x0, x2]
    ldrb w4, [x1, x2]
    sub w5, w3, #0x61
    cmp w5, #25
    b.hi .Lpi4_runtime_path_eq16_left_folded
    sub w3, w3, #0x20
.Lpi4_runtime_path_eq16_left_folded:
    sub w5, w4, #0x61
    cmp w5, #25
    b.hi .Lpi4_runtime_path_eq16_right_folded
    sub w4, w4, #0x20
.Lpi4_runtime_path_eq16_right_folded:
    cmp w3, w4
    b.ne .Lpi4_runtime_path_eq16_no
    cbz w4, .Lpi4_runtime_path_eq16_yes
    add x2, x2, #1
    cmp x2, #PI4_VIBE_EXEC_REQUEST_PATH_MAX_BYTES
    b.lo .Lpi4_runtime_path_eq16_next
.Lpi4_runtime_path_eq16_no:
    mov x0, xzr
    ret
.Lpi4_runtime_path_eq16_yes:
    mov x0, #1
    ret

.section .rodata.pi4_runtime, "a", %progbits
.balign 8
.Lpi4_runtime_payload0_path:
    .asciz "PAYLOAD0.ELF"
.Lpi4_runtime_payload1_path:
    .asciz "PAYLOAD1.ELF"
.balign 8
.Lpi4_runtime_empty_envp:
    .quad 0
.Lpi4_runtime_doom1_wad_path:
    .asciz "DOOM1.WAD"
.global pi4_quake_pak_path
.type pi4_quake_pak_path, %object
pi4_quake_pak_path:
.Lpi4_runtime_pak0_path:
    .asciz "/ID1/PAK0.PAK"
.size pi4_quake_pak_path, . - pi4_quake_pak_path
.Lpi4_runtime_pak0_suffix:
    .asciz "ID1/PAK0.PAK"
.balign 8
.global pi4_quake_text_pak_missing
.type pi4_quake_text_pak_missing, %object
pi4_quake_text_pak_missing:
    .asciz "PAK MISSING"
.size pi4_quake_text_pak_missing, . - pi4_quake_text_pak_missing
.global pi4_quake_text_pak_file
.type pi4_quake_text_pak_file, %object
pi4_quake_text_pak_file:
    .asciz "PAK FILE"
.size pi4_quake_text_pak_file, . - pi4_quake_text_pak_file
.global pi4_quake_text_pak_ok
.type pi4_quake_text_pak_ok, %object
pi4_quake_text_pak_ok:
    .asciz "PAK OK"
.size pi4_quake_text_pak_ok, . - pi4_quake_text_pak_ok
.global pi4_quake_text_menu
.type pi4_quake_text_menu, %object
pi4_quake_text_menu:
    .asciz "MENU"
.size pi4_quake_text_menu, . - pi4_quake_text_menu
.global pi4_quake_text_menu_resume
.type pi4_quake_text_menu_resume, %object
pi4_quake_text_menu_resume:
    .asciz "RESUME"
.size pi4_quake_text_menu_resume, . - pi4_quake_text_menu_resume
.global pi4_quake_text_menu_jump
.type pi4_quake_text_menu_jump, %object
pi4_quake_text_menu_jump:
    .asciz "JUMP"
.size pi4_quake_text_menu_jump, . - pi4_quake_text_menu_jump

.section .bss.pi4_runtime, "aw", %nobits
.balign 8
.Lpi4_runtime_asset_probe_done:
    .skip 8
.Lpi4_runtime_doom_offset_shadow:
    .skip 8
.Lpi4_runtime_pak_offset_shadow:
    .skip 8
.Lpi4_runtime_open_probe:
    .skip 4
.balign 16
.Lpi4_runtime_lseek_scratch:
    .skip PI4_VIBE_LSEEK_SCRATCH_BYTES
.global pi4_quake_pak_header
.type pi4_quake_pak_header, %object
pi4_quake_pak_header:
    .skip 16
.size pi4_quake_pak_header, . - pi4_quake_pak_header

.section .note.GNU-stack, "", %progbits
