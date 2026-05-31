// Raspberry Pi 4 aggregate-kernel assembly prelude.
//
// These constants and cross-unit symbols are consumed when the Pi boot,
// input, storage, and network assembly sources are compiled as one kernel
// image. Keep them in source control instead of generating them from Make.

.equ PI4_VIBE_DISPLAY_FD, 1
.equ PI4_VIBE_EINVAL, 22
.equ PI4_VIBE_INPUT_DEVICE_KEYBOARD, 1
.equ PI4_VIBE_INPUT_DEVICE_MOUSE, 2
.equ PI4_VIBE_INPUT_CAP_POLL_EVENT, 0x00000004
.equ PI4_VIBE_INPUT_CAP_STATUS, 0x00000008
.equ PI4_VIBE_INPUT_CAP_DEVICE_STATUS, 0x00000010
.equ PI4_VIBE_FB_BACKEND_XRGB8888_LFB, 2
.equ PI4_VIBE_FB_CAP_PRESENT_INDEXED, 0x00000001
.equ PI4_VIBE_FB_CAP_PRESENT_RGB_PALETTE, 0x00000002
.equ PI4_VIBE_FB_CAP_XRGB8888_LFB, 0x00000004
.equ PI4_VIBE_FB_CAP_DIRTY_SOURCE_RECT, 0x00000010
.equ PI4_VIBE_FB_CAP_PRESENT_FULLSCREEN_SCALE, 0x00000020
.equ PI4_VIBE_FB_FORMAT_INDEX8_RGB24, 1
.equ PI4_VIBE_FB_RGB24_PALETTE_BYTES, 768
.equ PI4_VIBE_USER_ABI_VERSION, 1
.equ PI4_VIBE_INPUT_EVENT_BYTES, 56
.equ PI4_VIBE_INPUT_STATUS_BYTES, 264
.equ PI4_VIBE_INPUT_DEVICE_STATUS_BYTES, 128
.equ PI4_VIBE_FB_INFO_BYTES, 168

.global msg_status_pi4exec_tuple
.global pi4_status_pi4exec_sysno
.global pi4_status_pi4exec_path
.global pi4_status_pi4exec_argv
.global pi4_status_pi4exec_envp
.global pi4_status_pi4exec_result
.global pi4_status_pi4exec_count
