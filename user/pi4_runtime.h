#ifndef VIBE_PI4_RUNTIME_H
#define VIBE_PI4_RUNTIME_H

#define PI4_VIBE_SVC_IMM 0x80
#define PI4_VIBE_SYSCALL_MAX_ARGS 3

#define PI4_VIBE_SYS_READ 0
#define PI4_VIBE_SYS_WRITE 4
#define PI4_VIBE_SYS_OPEN 5
#define PI4_VIBE_SYS_LSEEK 8
#define PI4_VIBE_SYS_CLOSE 12
#define PI4_VIBE_SYS_AUDIO 13
#define PI4_VIBE_SYS_EXEC 16
#define PI4_VIBE_SYS_UNLINK 17
#define PI4_VIBE_SYS_STAT 18
#define PI4_VIBE_SYS_FSTAT 19
#define PI4_VIBE_SYS_EXIT 2
#define PI4_VIBE_SYS_IOCTL 22
#define PI4_VIBE_SYS_GETPID 25
#define PI4_VIBE_SYS_POLL_INPUT 28
#define PI4_VIBE_SYS_CLOCK_GETTIME 29
#define PI4_VIBE_SYS_INPUT_STATUS 31
#define PI4_VIBE_SYS_INPUT_DEVICE_STATUS 39
#define PI4_VIBE_SYS_FILE_SIZE 40

#define PI4_VIBE_DISPLAY_FD 1
#define PI4_VIBE_FD_DOOM1_WAD 3
#define PI4_VIBE_FD_PAK0_PAK 4
#define PI4_VIBE_FD_MANIFEST_TXT 7
#define PI4_VIBE_FD_ASSET_README 8
#define PI4_VIBE_FD_ASSET_MAP 9
#define PI4_VIBE_FD_ASSET_PALETTE 10
#define PI4_VIBE_FD_APP_INDEX 11
#define PI4_VIBE_FD_APP_DOOM_MANIFEST 12
#define PI4_VIBE_FD_APP_QUAKE_MANIFEST 13
#define PI4_VIBE_APP_INDEX_PATH "/APPS/INDEX.TXT"
#define PI4_VIBE_DOOM_APP_MANIFEST_PATH "/APPS/DOOM/APP.TXT"
#define PI4_VIBE_DOOM_APP_PATH "/APPS/DOOM/APP.ELF"
#define PI4_VIBE_QUAKE_APP_MANIFEST_PATH "/APPS/QUAKE/APP.TXT"
#define PI4_VIBE_QUAKE_APP_PATH "/APPS/QUAKE/APP.ELF"
#define PI4_VIBE_QUAKE_PAK0_PATH "/ID1/PAK0.PAK"
#define PI4_VIBE_IOCTL_FBINFO 0x00005601
#define PI4_VIBE_IOCTL_PRESENT_INDEXED 0x00005602

#define PI4_VIBE_EIO 5
#define PI4_VIBE_ENOENT 2
#define PI4_VIBE_EBADF 9
#define PI4_VIBE_EINVAL 22
#define PI4_VIBE_ENOSYS 38
#define PI4_VIBE_EOVERFLOW 75

#define PI4_VIBE_O_RDONLY 0
#define PI4_VIBE_SEEK_SET 0
#define PI4_VIBE_SEEK_CUR 1
#define PI4_VIBE_SEEK_END 2
#define PI4_VIBE_S_IFREG 0100000
#define PI4_VIBE_S_IRUSR 0000400
#define PI4_VIBE_STAT_BYTES 44
#define PI4_VIBE_STAT_MODE_OFFSET 8
#define PI4_VIBE_STAT_SIZE_OFFSET 28
#define PI4_VIBE_LSEEK_SCRATCH_BYTES 65536

#define PI4_VIBE_APP_DOOM 0
#define PI4_VIBE_APP_QUAKE 1
#define PI4_VIBE_APP_COUNT 2
#define PI4_VIBE_EXEC_REQUEST_ABI_VERSION 1
#define PI4_VIBE_EXEC_REQUEST_BYTES 32
#define PI4_VIBE_EXEC_REQUEST_PATH_MAX_BYTES 64
#define PI4_VIBE_EXEC_REQUEST_ABI_VERSION_OFFSET 0
#define PI4_VIBE_EXEC_REQUEST_BYTES_OFFSET 8
/*
 * Exec requests are app-path-first. The word at offset 16 stays reserved so
 * the ABI remains fixed; callers set it to PI4_VIBE_EXEC_REQUEST_COMPAT_NONE
 * and provide app_path.
 */
#define PI4_VIBE_EXEC_REQUEST_COMPAT_TOKEN_OFFSET 16
#define PI4_VIBE_EXEC_REQUEST_APP_PATH_OFFSET 24
#define PI4_VIBE_EXEC_REQUEST_COMPAT_NONE -1
#define PI4_VIBE_EXEC_REQUEST_PATH_OFFSET \
    PI4_VIBE_EXEC_REQUEST_APP_PATH_OFFSET

#define PI4_VIBE_INPUT_DEVICE_KEYBOARD 1
#define PI4_VIBE_INPUT_DEVICE_MOUSE 2
#define PI4_VIBE_INPUT_DEVICE_UART 3
#define PI4_VIBE_INPUT_DEVICE_USB 4
#define PI4_VIBE_INPUT_DEVICE_STATUS_WAIT 0
#define PI4_VIBE_INPUT_DEVICE_STATUS_READY 1
#define PI4_VIBE_INPUT_EVENT_NONE 0
#define PI4_VIBE_INPUT_ABI_VERSION PI4_VIBE_USER_ABI_VERSION
#define PI4_VIBE_INPUT_EVENT_QUEUE_CAPACITY 8
#define PI4_VIBE_INPUT_EVENT_QUEUE_USABLE_CAPACITY 7
#define PI4_VIBE_INPUT_EVENT_VALUE_COUNT 3
#define PI4_VIBE_INPUT_KEY_STATE_BITS 256
#define PI4_VIBE_INPUT_CAP_KEYBOARD 0x00000001
#define PI4_VIBE_INPUT_CAP_MOUSE 0x00000002
#define PI4_VIBE_INPUT_CAP_POLL_EVENT 0x00000004
#define PI4_VIBE_INPUT_CAP_STATUS 0x00000008
#define PI4_VIBE_INPUT_CAP_DEVICE_STATUS 0x00000010
#define PI4_VIBE_INPUT_CAP_UART_SERIAL 0x00000020
#define PI4_VIBE_INPUT_DEVICE_CAP_KEYS 0x00000001
#define PI4_VIBE_INPUT_DEVICE_CAP_RELATIVE_POINTER 0x00000002
#define PI4_VIBE_INPUT_DEVICE_CAP_BUTTONS 0x00000004
#define PI4_VIBE_INPUT_DEVICE_CAP_STATE_SNAPSHOT 0x00000008
#define PI4_VIBE_INPUT_EVENT_KEY 1
#define PI4_VIBE_INPUT_EVENT_MOUSE_PACKET 2
#define PI4_VIBE_INPUT_EVENT_UART 3
#define PI4_VIBE_INPUT_KEY_RELEASED 0
#define PI4_VIBE_INPUT_KEY_PRESSED 1
#define PI4_VIBE_INPUT_ACTION_RELEASED PI4_VIBE_INPUT_KEY_RELEASED
#define PI4_VIBE_INPUT_ACTION_PRESSED PI4_VIBE_INPUT_KEY_PRESSED
#define PI4_VIBE_INPUT_KEY_PS2_SET1_SCANCODE_MASK 0x7f
#define PI4_VIBE_INPUT_KEY_PS2_SET1_EXTENDED 0x80
#define PI4_VIBE_INPUT_KEY_PS2_SET1_ESCAPE 0x01
#define PI4_VIBE_INPUT_KEY_PS2_SET1_1 0x02
#define PI4_VIBE_INPUT_KEY_PS2_SET1_2 0x03
#define PI4_VIBE_INPUT_KEY_PS2_SET1_3 0x04
#define PI4_VIBE_INPUT_KEY_PS2_SET1_4 0x05
#define PI4_VIBE_INPUT_KEY_PS2_SET1_5 0x06
#define PI4_VIBE_INPUT_KEY_PS2_SET1_6 0x07
#define PI4_VIBE_INPUT_KEY_PS2_SET1_7 0x08
#define PI4_VIBE_INPUT_KEY_PS2_SET1_TAB 0x0f
#define PI4_VIBE_INPUT_KEY_PS2_SET1_W 0x11
#define PI4_VIBE_INPUT_KEY_PS2_SET1_ENTER 0x1c
#define PI4_VIBE_INPUT_KEY_PS2_SET1_LEFT_CTRL 0x1d
#define PI4_VIBE_INPUT_KEY_PS2_SET1_A 0x1e
#define PI4_VIBE_INPUT_KEY_PS2_SET1_S 0x1f
#define PI4_VIBE_INPUT_KEY_PS2_SET1_D 0x20
#define PI4_VIBE_INPUT_KEY_PS2_SET1_LEFT_SHIFT 0x2a
#define PI4_VIBE_INPUT_KEY_PS2_SET1_RIGHT_SHIFT 0x36
#define PI4_VIBE_INPUT_KEY_PS2_SET1_LEFT_ALT 0x38
#define PI4_VIBE_INPUT_KEY_PS2_SET1_SPACE 0x39
#define PI4_VIBE_INPUT_KEY_PS2_SET1_LEFT 0x4b
#define PI4_VIBE_INPUT_KEY_PS2_SET1_RIGHT 0x4d
#define PI4_VIBE_INPUT_KEY_PS2_SET1_UP 0x48
#define PI4_VIBE_INPUT_KEY_PS2_SET1_DOWN 0x50
#define PI4_VIBE_INPUT_KEY_PS2_SET1_RIGHT_CTRL \
    (PI4_VIBE_INPUT_KEY_PS2_SET1_LEFT_CTRL | \
     PI4_VIBE_INPUT_KEY_PS2_SET1_EXTENDED)
#define PI4_VIBE_INPUT_KEY_PS2_SET1_RIGHT_ALT \
    (PI4_VIBE_INPUT_KEY_PS2_SET1_LEFT_ALT | \
     PI4_VIBE_INPUT_KEY_PS2_SET1_EXTENDED)
#define PI4_VIBE_INPUT_KEY_USB_HID_USAGE_NONE 0
#define PI4_VIBE_INPUT_KEY_USB_HID_USAGE_ESCAPE 0x29
#define PI4_VIBE_INPUT_KEY_USB_HID_USAGE_1 0x1e
#define PI4_VIBE_INPUT_KEY_USB_HID_USAGE_2 0x1f
#define PI4_VIBE_INPUT_KEY_USB_HID_USAGE_3 0x20
#define PI4_VIBE_INPUT_KEY_USB_HID_USAGE_4 0x21
#define PI4_VIBE_INPUT_KEY_USB_HID_USAGE_5 0x22
#define PI4_VIBE_INPUT_KEY_USB_HID_USAGE_6 0x23
#define PI4_VIBE_INPUT_KEY_USB_HID_USAGE_7 0x24
#define PI4_VIBE_INPUT_KEY_USB_HID_USAGE_A 0x04
#define PI4_VIBE_INPUT_KEY_USB_HID_USAGE_D 0x07
#define PI4_VIBE_INPUT_KEY_USB_HID_USAGE_W 0x1a
#define PI4_VIBE_INPUT_KEY_USB_HID_USAGE_S 0x16
#define PI4_VIBE_INPUT_KEY_USB_HID_USAGE_ENTER 0x28
#define PI4_VIBE_INPUT_KEY_USB_HID_USAGE_SPACE 0x2c
#define PI4_VIBE_INPUT_KEY_USB_HID_USAGE_LEFT 0x50
#define PI4_VIBE_INPUT_KEY_USB_HID_USAGE_RIGHT 0x4f
#define PI4_VIBE_INPUT_KEY_USB_HID_USAGE_UP 0x52
#define PI4_VIBE_INPUT_KEY_USB_HID_USAGE_DOWN 0x51
#define PI4_VIBE_INPUT_KEY_USB_HID_USAGE_KP_1 0x59
#define PI4_VIBE_INPUT_KEY_USB_HID_USAGE_KP_2 0x5a
#define PI4_VIBE_INPUT_KEY_USB_HID_USAGE_LEFT_CTRL 0xe0
#define PI4_VIBE_INPUT_KEY_USB_HID_USAGE_LEFT_SHIFT 0xe1
#define PI4_VIBE_INPUT_KEY_USB_HID_USAGE_RIGHT_CTRL 0xe4
#define PI4_VIBE_INPUT_KEY_USB_HID_USAGE_RIGHT_SHIFT 0xe5
#define PI4_VIBE_INPUT_EVENT_KEY_TOKEN 0x80000000
#define PI4_VIBE_INPUT_EVENT_KEY_TOKEN_CODE_MASK 0xff
#define PI4_VIBE_INPUT_EVENT_KEY_TOKEN_HID_SHIFT 8
#define PI4_VIBE_INPUT_EVENT_KEY_TOKEN_ACTION_SHIFT 24
#define PI4_VIBE_INPUT_EVENT_KEY_TOKEN_FIELD_MASK 0xff
#define PI4_VIBE_INPUT_MOUSE_BUTTON_LEFT 0x01
#define PI4_VIBE_INPUT_MOUSE_BUTTON_RIGHT 0x02
#define PI4_VIBE_INPUT_MOUSE_BUTTON_MIDDLE 0x04
#define PI4_VIBE_INPUT_MOUSE_BUTTON_MASK 0x07
#define PI4_VIBE_INPUT_MOUSE_AXIS_X 0
#define PI4_VIBE_INPUT_MOUSE_AXIS_Y 1
#define PI4_VIBE_INPUT_MOD_SHIFT 0x00000001
#define PI4_VIBE_INPUT_MOD_CTRL 0x00000002
#define PI4_VIBE_INPUT_MOD_ALT 0x00000004
#define PI4_VIBE_INPUT_SOURCE_UNKNOWN 0
#define PI4_VIBE_INPUT_SOURCE_UART_SERIAL 1
#define PI4_VIBE_INPUT_SOURCE_MSMOUSE 2
#define PI4_VIBE_INPUT_SOURCE_USB_HID_KEYBOARD 3
#define PI4_VIBE_INPUT_SOURCE_USB_HID_MOUSE 4
#define PI4_VIBE_UART_EVENT_NONE 0
#define PI4_VIBE_UART_EVENT_SELECT_1 1
#define PI4_VIBE_UART_EVENT_SELECT_2 2
#define PI4_VIBE_UART_EVENT_CONFIRM 3
#define PI4_VIBE_UART_EVENT_UP 4
#define PI4_VIBE_UART_EVENT_DOWN 5
#define PI4_VIBE_UART_EVENT_MAX 5
#define PI4_VIBE_INPUT_QUEUE_OVERFLOW_DROP_NEWEST 2

#define PI4_VIBE_FB_BACKEND_XRGB8888_LFB 2
#define PI4_VIBE_FB_CAP_PRESENT_INDEXED 0x00000001
#define PI4_VIBE_FB_CAP_PRESENT_RGB_PALETTE 0x00000002
#define PI4_VIBE_FB_CAP_XRGB8888_LFB 0x00000004
#define PI4_VIBE_FB_CAP_DIRTY_SOURCE_RECT 0x00000010
#define PI4_VIBE_FB_CAP_PRESENT_FULLSCREEN_SCALE 0x00000020
#define PI4_VIBE_FB_FORMAT_INDEX8_RGB24 1
#define PI4_VIBE_FB_RGB24_PALETTE_BYTES (256 * 3)
#define PI4_VIBE_FB_PRESENT_WIDTH 1280
#define PI4_VIBE_FB_PRESENT_HEIGHT 720
#define PI4_VIBE_FB_PRESENT_FRAME_BYTES \
    (PI4_VIBE_FB_PRESENT_WIDTH * PI4_VIBE_FB_PRESENT_HEIGHT)
#define PI4_VIBE_FB_MODE13_WIDTH 320
#define PI4_VIBE_FB_MODE13_HEIGHT 200
#define PI4_VIBE_FB_MODE13_ASPECT_HEIGHT 240
#define PI4_VIBE_FB_POLICY_MODE13 1
#define PI4_VIBE_FB_POLICY_ASPECT 2
#define PI4_VIBE_FB_POLICY_SQUARE 3
#define PI4_VIBE_FB_POLICY_FULLSCREEN_STRETCH 4

#define PI4_VIBE_CLOCK_MONOTONIC 1
#define PI4_VIBE_CLOCK_MONOTONIC_HZ 100
#define PI4_VIBE_CLOCK_FLAG_KERNEL_OWNED 0x00000001
#define PI4_VIBE_CLOCK_TIME_BYTES 32
#define PI4_VIBE_CLOCK_TIME_TICKS_OFFSET 0
#define PI4_VIBE_CLOCK_TIME_FREQUENCY_HZ_OFFSET 8
#define PI4_VIBE_CLOCK_TIME_MILLISECONDS_OFFSET 16
#define PI4_VIBE_CLOCK_TIME_FLAGS_OFFSET 24

#define PI4_VIBE_AUDIO_DEVICE_NONE 0
#define PI4_VIBE_AUDIO_DEVICE_SB16 1
#define PI4_VIBE_AUDIO_DEVICE_PI4_PWM 2
#define PI4_VIBE_AUDIO_FD 0x00004155
#define PI4_VIBE_IOCTL_AUDIO_DEVICE_INFO 0x00004101
#define PI4_VIBE_IOCTL_AUDIO_PCM_RING_INFO 0x00004102
#define PI4_VIBE_IOCTL_AUDIO_STREAM_INFO 0x00004103
#define PI4_VIBE_AUDIO_DEVICE_STATUS_NONE 0
#define PI4_VIBE_AUDIO_DEVICE_STATUS_READY 1
#define PI4_VIBE_AUDIO_DEVICE_STATUS_ABSENT 2
#define PI4_VIBE_AUDIO_FORMAT_U8_STEREO 1
#define PI4_VIBE_AUDIO_CAP_MMIO_WINDOW 0x00000001
#define PI4_VIBE_AUDIO_CAP_MAILBOX_CLOCK 0x00000002
#define PI4_VIBE_AUDIO_CAP_PCM_QUEUE 0x00000004
#define PI4_VIBE_AUDIO_CAP_FULL_MASK \
    (PI4_VIBE_AUDIO_CAP_MMIO_WINDOW | \
     PI4_VIBE_AUDIO_CAP_MAILBOX_CLOCK | \
     PI4_VIBE_AUDIO_CAP_PCM_QUEUE)
#define PI4_VIBE_AUDIO_CAP_PCM_RING PI4_VIBE_AUDIO_CAP_PCM_QUEUE
#define PI4_VIBE_AUDIO_DEVICE_START 1
#define PI4_VIBE_AUDIO_MIXER_START 2
#define PI4_VIBE_AUDIO_MIXER_STOP 3
#define PI4_VIBE_AUDIO_MIXER_UPDATE 4
#define PI4_VIBE_AUDIO_DEVICE_SHUTDOWN 5
#define PI4_VIBE_AUDIO_MIXER_IS_PLAYING 6
#define PI4_VIBE_AUDIO_PCM_BUFFERED_BYTES 7
#define PI4_VIBE_AUDIO_PCM_PULL_STATE 8
#define PI4_VIBE_AUDIO_DEVICE_INFO 9
#define PI4_VIBE_AUDIO_PCM_RING_INFO 10
#define PI4_VIBE_AUDIO_STREAM_INFO 11
#define PI4_VIBE_AUDIO_PCM_WRITE 12
#define PI4_VIBE_AUDIO_PCM_WRITE_DESC 13
#define PI4_VIBE_AUDIO_PCM_OPEN 14
#define PI4_VIBE_AUDIO_PCM_DRAIN 15
#define PI4_VIBE_AUDIO_PCM_CLOSE 16
#define PI4_VIBE_AUDIO_STREAM_NONE 0
#define PI4_VIBE_AUDIO_STREAM_PUSH 1
#define PI4_VIBE_AUDIO_STREAM_PULL 2
#define PI4_VIBE_AUDIO_STREAM_FLAG_PULL 0x00000001
#define PI4_VIBE_AUDIO_STREAM_FLAG_REFILL_PENDING 0x00000002
#define PI4_VIBE_AUDIO_STREAM_FLAG_ACTIVE 0x00000004
#define PI4_VIBE_AUDIO_PCM_LIFECYCLE_IDLE 0
#define PI4_VIBE_AUDIO_PCM_LIFECYCLE_OPEN 1
#define PI4_VIBE_AUDIO_PCM_LIFECYCLE_WRITTEN 2
#define PI4_VIBE_AUDIO_PCM_LIFECYCLE_DRAINING 3
#define PI4_VIBE_AUDIO_PCM_LIFECYCLE_CLOSED 4
#define PI4_VIBE_AUDIO_FLAG_LOOP 0x00000001
#define PI4_VIBE_AUDIO_FLAG_MUSIC 0x00000002
#define PI4_VIBE_AUDIO_FLAG_ASSET_SFX 0x00000004
#define PI4_VIBE_AUDIO_FLAG_STREAM_FINAL 0x00000008
#define PI4_VIBE_AUDIO_FLAG_STREAM 0x00000010
#define PI4_VIBE_AUDIO_VOICE_DESC_BYTES 128
#define PI4_VIBE_AUDIO_PCM_DESC_BYTES 128
#define PI4_VIBE_AUDIO_DEVICE_INFO_BYTES 96
#define PI4_VIBE_AUDIO_PCM_RING_INFO_BYTES 96
#define PI4_VIBE_AUDIO_STREAM_INFO_BYTES 96
#define PI4_VIBE_AUDIO_STREAM_INFO_HANDLE_OFFSET 16

#define PI4_VIBE_USER_ABI_VERSION 1
#define PI4_VIBE_USER_STACK_ABI_VERSION 1
#define PI4_VIBE_USER_ARG_MAX 8
#define PI4_VIBE_USER_ENV_MAX 8
#define PI4_VIBE_USER_AUX_MAX 16
#define PI4_VIBE_USER_START_FLAG_ARGV_BOUNDED 0x00000001
#define PI4_VIBE_USER_START_FLAG_ENVP_BOUNDED 0x00000002
#define PI4_VIBE_USER_START_FLAG_AUXV_PRESENT 0x00000004
#define PI4_VIBE_USER_START_FLAG_STACK_ALIGNED 0x00000008
#define PI4_VIBE_USER_START_FLAG_AUXV_BOUNDED 0x00000010
#define PI4_VIBE_USER_START_REQUIRED_FLAGS 0x0000001f
#define PI4_VIBE_USER_START_FAIL_STATUS 0x96

#define PI4_VIBE_AT_NULL 0
#define PI4_VIBE_AT_PHDR 3
#define PI4_VIBE_AT_PHENT 4
#define PI4_VIBE_AT_PHNUM 5
#define PI4_VIBE_AT_PAGESZ 6
#define PI4_VIBE_AT_ENTRY 9

#define PI4_VIBE_INPUT_EVENT_BYTES 56
#define PI4_VIBE_INPUT_STATUS_BYTES 264
#define PI4_VIBE_INPUT_DEVICE_STATUS_BYTES 128
#define PI4_VIBE_FB_INFO_BYTES 168
#define PI4_VIBE_FB_INFO_DIRTY_X_OFFSET 96
#define PI4_VIBE_FB_INFO_DIRTY_Y_OFFSET 104
#define PI4_VIBE_FB_INFO_DIRTY_WIDTH_OFFSET 112
#define PI4_VIBE_FB_INFO_DIRTY_HEIGHT_OFFSET 120
#define PI4_VIBE_FB_INFO_DIRTY_COUNT_OFFSET 128
#define PI4_VIBE_FB_INFO_CAPABILITIES_OFFSET 136
#define PI4_VIBE_FB_INFO_PRESENT_FORMAT_OFFSET 144
#define PI4_VIBE_FB_INFO_MAX_PRESENT_WIDTH_OFFSET 152
#define PI4_VIBE_FB_INFO_MAX_PRESENT_HEIGHT_OFFSET 160
#define PI4_VIBE_PRESENT_INDEXED_BYTES 32
#define PI4_VIBE_PRESENT_INDEXED_FRAME_OFFSET 0
#define PI4_VIBE_PRESENT_INDEXED_PALETTE_OFFSET 8
#define PI4_VIBE_PRESENT_INDEXED_WIDTH_OFFSET 16
#define PI4_VIBE_PRESENT_INDEXED_HEIGHT_OFFSET 24

#define PI4_VIBE_INPUT_EVENT_TIMESTAMP_OFFSET 0
#define PI4_VIBE_INPUT_EVENT_DEVICE_ID_OFFSET 8
#define PI4_VIBE_INPUT_EVENT_TYPE_OFFSET 16
#define PI4_VIBE_INPUT_EVENT_CODE_OFFSET 24
#define PI4_VIBE_INPUT_EVENT_VALUE0_OFFSET 32
#define PI4_VIBE_INPUT_EVENT_VALUE1_OFFSET 40
#define PI4_VIBE_INPUT_EVENT_VALUE2_OFFSET 48

#define PI4_VIBE_INPUT_STATUS_ABI_VERSION_OFFSET 0
#define PI4_VIBE_INPUT_STATUS_EVENT_BYTES_OFFSET 8
#define PI4_VIBE_INPUT_STATUS_QUEUE_CAPACITY_OFFSET 16
#define PI4_VIBE_INPUT_STATUS_QUEUED_EVENTS_OFFSET 24
#define PI4_VIBE_INPUT_STATUS_TOTAL_EVENTS_OFFSET 32
#define PI4_VIBE_INPUT_STATUS_POLLED_EVENTS_OFFSET 40
#define PI4_VIBE_INPUT_STATUS_DROPPED_EVENTS_OFFSET 48
#define PI4_VIBE_INPUT_STATUS_CAPABILITIES_OFFSET 56
#define PI4_VIBE_INPUT_STATUS_KEYBOARD_IRQ_COUNT_OFFSET 64
#define PI4_VIBE_INPUT_STATUS_KEYBOARD_EVENT_COUNT_OFFSET 72
#define PI4_VIBE_INPUT_STATUS_KEYBOARD_DOWN_COUNT_OFFSET 80
#define PI4_VIBE_INPUT_STATUS_KEYBOARD_LAST_CODE_OFFSET 88
#define PI4_VIBE_INPUT_STATUS_KEYBOARD_STATE_OFFSET 96
#define PI4_VIBE_INPUT_STATUS_MOUSE_IRQ_COUNT_OFFSET 160
#define PI4_VIBE_INPUT_STATUS_MOUSE_PACKET_COUNT_OFFSET 168
#define PI4_VIBE_INPUT_STATUS_MOUSE_SYNC_LOSS_COUNT_OFFSET 176
#define PI4_VIBE_INPUT_STATUS_MOUSE_BUTTONS_OFFSET 184
#define PI4_VIBE_INPUT_STATUS_MOUSE_DELTA_X_TOTAL_OFFSET 192
#define PI4_VIBE_INPUT_STATUS_MOUSE_DELTA_Y_TOTAL_OFFSET 200
#define PI4_VIBE_INPUT_STATUS_LAST_EVENT_DEVICE_ID_OFFSET 208
#define PI4_VIBE_INPUT_STATUS_LAST_EVENT_TYPE_OFFSET 216
#define PI4_VIBE_INPUT_STATUS_STATUS_BYTES_OFFSET 224
#define PI4_VIBE_INPUT_STATUS_QUEUE_USABLE_CAPACITY_OFFSET 232
#define PI4_VIBE_INPUT_STATUS_OVERFLOW_POLICY_OFFSET 240
#define PI4_VIBE_INPUT_STATUS_KEYBOARD_STATUS_OFFSET 248
#define PI4_VIBE_INPUT_STATUS_MOUSE_STATUS_OFFSET 256

#define PI4_VIBE_INPUT_DEVICE_STATUS_ABI_VERSION_OFFSET 0
#define PI4_VIBE_INPUT_DEVICE_STATUS_STATUS_BYTES_OFFSET 8
#define PI4_VIBE_INPUT_DEVICE_STATUS_DEVICE_ID_OFFSET 16
#define PI4_VIBE_INPUT_DEVICE_STATUS_STATUS_OFFSET 24
#define PI4_VIBE_INPUT_DEVICE_STATUS_CAPABILITIES_OFFSET 32
#define PI4_VIBE_INPUT_DEVICE_STATUS_IRQ_COUNT_OFFSET 40
#define PI4_VIBE_INPUT_DEVICE_STATUS_EVENT_COUNT_OFFSET 48
#define PI4_VIBE_INPUT_DEVICE_STATUS_POLLED_EVENTS_OFFSET 56
#define PI4_VIBE_INPUT_DEVICE_STATUS_DROPPED_EVENTS_OFFSET 64
#define PI4_VIBE_INPUT_DEVICE_STATUS_LAST_TIMESTAMP_OFFSET 72
#define PI4_VIBE_INPUT_DEVICE_STATUS_LAST_EVENT_TYPE_OFFSET 80
#define PI4_VIBE_INPUT_DEVICE_STATUS_LAST_CODE_OFFSET 88
#define PI4_VIBE_INPUT_DEVICE_STATUS_ACTIVE_STATE_OFFSET 96
#define PI4_VIBE_INPUT_DEVICE_STATUS_AXIS_X_TOTAL_OFFSET 104
#define PI4_VIBE_INPUT_DEVICE_STATUS_AXIS_Y_TOTAL_OFFSET 112
#define PI4_VIBE_INPUT_DEVICE_STATUS_RESERVED0_OFFSET 120

#define PI4_VIBE_FB_INFO_WIDTH_OFFSET 0
#define PI4_VIBE_FB_INFO_HEIGHT_OFFSET 8
#define PI4_VIBE_FB_INFO_PITCH_OFFSET 16
#define PI4_VIBE_FB_INFO_BACKEND_OFFSET 24
#define PI4_VIBE_FB_INFO_FRAME_BYTES_OFFSET 32
#define PI4_VIBE_FB_INFO_PALETTE_BYTES_OFFSET 40
#define PI4_VIBE_FB_INFO_SCALE_OFFSET 48
#define PI4_VIBE_FB_INFO_VIEW_X_OFFSET 56
#define PI4_VIBE_FB_INFO_VIEW_Y_OFFSET 64
#define PI4_VIBE_FB_INFO_VIEW_WIDTH_OFFSET 72
#define PI4_VIBE_FB_INFO_VIEW_HEIGHT_OFFSET 80
#define PI4_VIBE_FB_INFO_POLICY_OFFSET 88
#define PI4_VIBE_ABI_PROBE_STATE_ENTERED 1
#define PI4_VIBE_ABI_PROBE_STATE_WRAPPERS_DONE 2

#define PI4_VIBE_ABI_PROBE_STATUS_MAGIC_OFFSET 0
#define PI4_VIBE_ABI_PROBE_STATUS_STATE_OFFSET 8
#define PI4_VIBE_ABI_PROBE_STATUS_ARGC_OFFSET 16
#define PI4_VIBE_ABI_PROBE_STATUS_ARGV_OFFSET 24
#define PI4_VIBE_ABI_PROBE_STATUS_ENVP_OFFSET 32
#define PI4_VIBE_ABI_PROBE_STATUS_START_FLAGS_OFFSET 40
#define PI4_VIBE_ABI_PROBE_STATUS_GETPID_OFFSET 48
#define PI4_VIBE_ABI_PROBE_STATUS_INPUT_STATUS_OFFSET 56
#define PI4_VIBE_ABI_PROBE_STATUS_POLL_INPUT_OFFSET 64
#define PI4_VIBE_ABI_PROBE_STATUS_PRESENT_OFFSET 72
#define PI4_VIBE_ABI_PROBE_STATUS_EXIT_CODE_OFFSET 80
#define PI4_VIBE_ABI_PROBE_STATUS_AUXV_OFFSET 88
#define PI4_VIBE_ABI_PROBE_STATUS_ENTRY_STACK_OFFSET 96
#define PI4_VIBE_ABI_PROBE_STATUS_AUX0_TYPE_OFFSET 104
#define PI4_VIBE_ABI_PROBE_STATUS_AUX0_VALUE_OFFSET 112
#define PI4_VIBE_ABI_PROBE_STATUS_AUX_NULL_OFF_OFFSET 120
#define PI4_VIBE_ABI_PROBE_STATUS_FB_INFO_OFFSET 128
#define PI4_VIBE_ABI_PROBE_STATUS_EXEC_REQUEST_OFFSET 136
#define PI4_VIBE_ABI_PROBE_STATUS_EXEC_REQ_PTR_OFFSET 144
#define PI4_VIBE_ABI_PROBE_STATUS_EXIT_WRAPPER_OFFSET 152
#define PI4_VIBE_ABI_PROBE_STATUS_INPUT_KEYBOARD_STATUS_OFFSET 160
#define PI4_VIBE_ABI_PROBE_STATUS_INPUT_MOUSE_STATUS_OFFSET 168
#define PI4_VIBE_ABI_PROBE_STATUS_INPUT_UART_STATUS_OFFSET 176
#define PI4_VIBE_ABI_PROBE_STATUS_DRAIN_INPUT_OFFSET 184
#define PI4_VIBE_ABI_PROBE_STATUS_BYTES 192

#ifndef __ASSEMBLER__

typedef unsigned long pi4_vibe_word_t;
typedef long pi4_vibe_sword_t;

struct stat;

typedef struct pi4_vibe_input_event {
    pi4_vibe_word_t timestamp;
    pi4_vibe_word_t device_id;
    pi4_vibe_word_t type;
    pi4_vibe_word_t code;
    pi4_vibe_sword_t value0;
    pi4_vibe_sword_t value1;
    pi4_vibe_sword_t value2;
} pi4_vibe_input_event_t;

static inline void pi4_vibe_input_make_key_event(
    pi4_vibe_input_event_t* event,
    pi4_vibe_word_t timestamp,
    pi4_vibe_word_t code,
    int pressed)
{
    if (!event)
        return;

    event->timestamp = timestamp;
    event->device_id = PI4_VIBE_INPUT_DEVICE_KEYBOARD;
    event->type = PI4_VIBE_INPUT_EVENT_KEY;
    event->code = code;
    event->value0 = pressed ? PI4_VIBE_INPUT_KEY_PRESSED : PI4_VIBE_INPUT_KEY_RELEASED;
    event->value1 = 0;
    event->value2 = PI4_VIBE_INPUT_SOURCE_UNKNOWN;
}

static inline void pi4_vibe_input_make_mouse_packet_event(
    pi4_vibe_input_event_t* event,
    pi4_vibe_word_t timestamp,
    pi4_vibe_word_t buttons,
    pi4_vibe_sword_t delta_x,
    pi4_vibe_sword_t delta_y)
{
    if (!event)
        return;

    event->timestamp = timestamp;
    event->device_id = PI4_VIBE_INPUT_DEVICE_MOUSE;
    event->type = PI4_VIBE_INPUT_EVENT_MOUSE_PACKET;
    event->code = buttons & PI4_VIBE_INPUT_MOUSE_BUTTON_MASK;
    event->value0 = delta_x;
    event->value1 = delta_y;
    event->value2 = PI4_VIBE_INPUT_SOURCE_UNKNOWN;
}

static inline pi4_vibe_word_t pi4_vibe_input_event_source(
    const pi4_vibe_input_event_t* event)
{
    return event ? (pi4_vibe_word_t)event->value2 :
        PI4_VIBE_INPUT_SOURCE_UNKNOWN;
}

static inline int pi4_vibe_input_source_is_usb_hid(
    pi4_vibe_word_t source)
{
    return source == PI4_VIBE_INPUT_SOURCE_USB_HID_KEYBOARD ||
        source == PI4_VIBE_INPUT_SOURCE_USB_HID_MOUSE;
}

static inline int pi4_vibe_input_source_is_keyboard(
    pi4_vibe_word_t source)
{
    return source == PI4_VIBE_INPUT_SOURCE_USB_HID_KEYBOARD;
}

static inline int pi4_vibe_input_source_is_mouse(
    pi4_vibe_word_t source)
{
    return source == PI4_VIBE_INPUT_SOURCE_MSMOUSE ||
        source == PI4_VIBE_INPUT_SOURCE_USB_HID_MOUSE;
}

static inline pi4_vibe_word_t pi4_vibe_input_source_physical_device_id(
    pi4_vibe_word_t source)
{
    if (pi4_vibe_input_source_is_usb_hid(source))
        return PI4_VIBE_INPUT_DEVICE_USB;
    if (source == PI4_VIBE_INPUT_SOURCE_UART_SERIAL)
        return PI4_VIBE_INPUT_DEVICE_UART;
    if (source == PI4_VIBE_INPUT_SOURCE_MSMOUSE)
        return PI4_VIBE_INPUT_DEVICE_MOUSE;
    return PI4_VIBE_INPUT_SOURCE_UNKNOWN;
}

static inline pi4_vibe_word_t pi4_vibe_input_source_logical_device_id(
    pi4_vibe_word_t source)
{
    if (source == PI4_VIBE_INPUT_SOURCE_USB_HID_KEYBOARD)
        return PI4_VIBE_INPUT_DEVICE_KEYBOARD;
    if (pi4_vibe_input_source_is_mouse(source))
        return PI4_VIBE_INPUT_DEVICE_MOUSE;
    if (source == PI4_VIBE_INPUT_SOURCE_UART_SERIAL)
        return PI4_VIBE_INPUT_DEVICE_UART;
    return PI4_VIBE_INPUT_SOURCE_UNKNOWN;
}

static inline int pi4_vibe_input_event_source_is_usb_hid(
    const pi4_vibe_input_event_t* event)
{
    return pi4_vibe_input_source_is_usb_hid(
        pi4_vibe_input_event_source(event));
}

static inline pi4_vibe_word_t pi4_vibe_input_event_physical_device_id(
    const pi4_vibe_input_event_t* event)
{
    pi4_vibe_word_t source;
    pi4_vibe_word_t physical_device_id;

    if (!event)
        return 0;
    source = pi4_vibe_input_event_source(event);
    physical_device_id = pi4_vibe_input_source_physical_device_id(source);
    if (physical_device_id)
        return physical_device_id;
    return event->device_id;
}

static inline int pi4_vibe_input_event_is_physical_usb(
    const pi4_vibe_input_event_t* event)
{
    return pi4_vibe_input_event_physical_device_id(event) ==
        PI4_VIBE_INPUT_DEVICE_USB;
}

static inline pi4_vibe_word_t pi4_vibe_input_event_logical_device_id(
    const pi4_vibe_input_event_t* event)
{
    pi4_vibe_word_t logical_device_id;

    if (!event)
        return 0;
    logical_device_id = pi4_vibe_input_source_logical_device_id(
        pi4_vibe_input_event_source(event));
    if (logical_device_id)
        return logical_device_id;
    if (event->type == PI4_VIBE_INPUT_EVENT_KEY &&
        (event->device_id == PI4_VIBE_INPUT_DEVICE_KEYBOARD ||
            event->device_id == PI4_VIBE_INPUT_DEVICE_USB))
        return PI4_VIBE_INPUT_DEVICE_KEYBOARD;
    if (event->type == PI4_VIBE_INPUT_EVENT_MOUSE_PACKET &&
        (event->device_id == PI4_VIBE_INPUT_DEVICE_MOUSE ||
            event->device_id == PI4_VIBE_INPUT_DEVICE_USB))
        return PI4_VIBE_INPUT_DEVICE_MOUSE;
    if (event->type == PI4_VIBE_INPUT_EVENT_UART &&
        event->device_id == PI4_VIBE_INPUT_DEVICE_UART)
        return PI4_VIBE_INPUT_DEVICE_UART;
    return event->device_id;
}

static inline int pi4_vibe_input_device_id_is_logical(
    pi4_vibe_word_t device_id)
{
    return device_id == PI4_VIBE_INPUT_DEVICE_KEYBOARD ||
        device_id == PI4_VIBE_INPUT_DEVICE_MOUSE ||
        device_id == PI4_VIBE_INPUT_DEVICE_UART;
}

static inline int pi4_vibe_input_device_id_is_physical(
    pi4_vibe_word_t device_id)
{
    return device_id == PI4_VIBE_INPUT_DEVICE_KEYBOARD ||
        device_id == PI4_VIBE_INPUT_DEVICE_MOUSE ||
        device_id == PI4_VIBE_INPUT_DEVICE_UART ||
        device_id == PI4_VIBE_INPUT_DEVICE_USB;
}

static inline int pi4_vibe_input_event_matches_device(
    const pi4_vibe_input_event_t* event,
    pi4_vibe_word_t device_id)
{
    if (!event)
        return 0;
    if (pi4_vibe_input_device_id_is_logical(device_id))
        return pi4_vibe_input_event_logical_device_id(event) == device_id;
    if (device_id == PI4_VIBE_INPUT_DEVICE_USB)
        return pi4_vibe_input_event_physical_device_id(event) == device_id;
    return event->device_id == device_id;
}

static inline int pi4_vibe_input_event_is_key(
    const pi4_vibe_input_event_t* event)
{
    return event &&
        pi4_vibe_input_event_logical_device_id(event) ==
            PI4_VIBE_INPUT_DEVICE_KEYBOARD &&
        event->type == PI4_VIBE_INPUT_EVENT_KEY;
}

static inline int pi4_vibe_input_event_is_mouse_packet(
    const pi4_vibe_input_event_t* event)
{
    return event &&
        pi4_vibe_input_event_logical_device_id(event) ==
            PI4_VIBE_INPUT_DEVICE_MOUSE &&
        event->type == PI4_VIBE_INPUT_EVENT_MOUSE_PACKET;
}

static inline int pi4_vibe_input_event_is_uart_serial(
    const pi4_vibe_input_event_t* event)
{
    return event &&
        pi4_vibe_input_event_logical_device_id(event) ==
            PI4_VIBE_INPUT_DEVICE_UART &&
        event->type == PI4_VIBE_INPUT_EVENT_UART;
}

static inline int pi4_vibe_input_event_is_usb_hid_keyboard(
    const pi4_vibe_input_event_t* event)
{
    return pi4_vibe_input_event_is_key(event) &&
        pi4_vibe_input_event_source(event) ==
            PI4_VIBE_INPUT_SOURCE_USB_HID_KEYBOARD;
}

static inline int pi4_vibe_input_event_is_usb_hid_mouse(
    const pi4_vibe_input_event_t* event)
{
    return pi4_vibe_input_event_is_mouse_packet(event) &&
        pi4_vibe_input_event_source(event) ==
            PI4_VIBE_INPUT_SOURCE_USB_HID_MOUSE;
}

static inline int pi4_vibe_input_event_is_msmouse(
    const pi4_vibe_input_event_t* event)
{
    return pi4_vibe_input_event_is_mouse_packet(event) &&
        pi4_vibe_input_event_source(event) == PI4_VIBE_INPUT_SOURCE_MSMOUSE;
}

static inline pi4_vibe_word_t pi4_vibe_input_event_uart_code(
    const pi4_vibe_input_event_t* event)
{
    if (!pi4_vibe_input_event_is_uart_serial(event))
        return PI4_VIBE_UART_EVENT_NONE;
    return event->code;
}

static inline pi4_vibe_word_t pi4_vibe_input_key_code(
    const pi4_vibe_input_event_t* event)
{
    return pi4_vibe_input_event_is_key(event) ? event->code : 0;
}

static inline pi4_vibe_word_t pi4_vibe_input_event_action(
    const pi4_vibe_input_event_t* event)
{
    return event ? (pi4_vibe_word_t)event->value0 : 0;
}

static inline pi4_vibe_word_t pi4_vibe_input_key_usb_hid_usage(
    const pi4_vibe_input_event_t* event)
{
    pi4_vibe_word_t token_usage;
    if (!pi4_vibe_input_event_is_key(event))
        return PI4_VIBE_INPUT_KEY_USB_HID_USAGE_NONE;
    if (!pi4_vibe_input_event_source_is_usb_hid(event) &&
        !pi4_vibe_input_event_is_physical_usb(event))
        return PI4_VIBE_INPUT_KEY_USB_HID_USAGE_NONE;
    if (event->value1)
        return (pi4_vibe_word_t)event->value1;
    token_usage = (event->code >> PI4_VIBE_INPUT_EVENT_KEY_TOKEN_HID_SHIFT) &
        PI4_VIBE_INPUT_EVENT_KEY_TOKEN_FIELD_MASK;
    if (token_usage)
        return token_usage;
    if (event->device_id == PI4_VIBE_INPUT_DEVICE_USB)
        return event->code & PI4_VIBE_INPUT_EVENT_KEY_TOKEN_FIELD_MASK;
    return PI4_VIBE_INPUT_KEY_USB_HID_USAGE_NONE;
}

static inline pi4_vibe_word_t pi4_vibe_input_ps2_set1_key_code(
    pi4_vibe_word_t scancode,
    int extended)
{
    return (scancode & PI4_VIBE_INPUT_KEY_PS2_SET1_SCANCODE_MASK)
        | (extended ? PI4_VIBE_INPUT_KEY_PS2_SET1_EXTENDED : 0);
}

static inline pi4_vibe_word_t pi4_vibe_input_key_ps2_set1_scancode(
    const pi4_vibe_input_event_t* event)
{
    return pi4_vibe_input_key_code(event) &
        PI4_VIBE_INPUT_KEY_PS2_SET1_SCANCODE_MASK;
}

static inline int pi4_vibe_input_key_ps2_set1_is_extended(
    const pi4_vibe_input_event_t* event)
{
    return (pi4_vibe_input_key_code(event) &
        PI4_VIBE_INPUT_KEY_PS2_SET1_EXTENDED) != 0;
}

static inline int pi4_vibe_input_key_is_pressed(
    const pi4_vibe_input_event_t* event)
{
    return pi4_vibe_input_event_is_key(event) &&
        event->value0 == PI4_VIBE_INPUT_KEY_PRESSED;
}

static inline int pi4_vibe_input_key_is_released(
    const pi4_vibe_input_event_t* event)
{
    return pi4_vibe_input_event_is_key(event) &&
        event->value0 == PI4_VIBE_INPUT_KEY_RELEASED;
}

static inline int pi4_vibe_input_mouse_button_is_supported(
    pi4_vibe_word_t button)
{
    return button &&
        (button & ~PI4_VIBE_INPUT_MOUSE_BUTTON_MASK) == 0;
}

static inline pi4_vibe_word_t pi4_vibe_input_mouse_buttons(
    const pi4_vibe_input_event_t* event)
{
    if (!pi4_vibe_input_event_is_mouse_packet(event))
        return 0;
    return event->code & PI4_VIBE_INPUT_MOUSE_BUTTON_MASK;
}

static inline int pi4_vibe_input_mouse_button_is_down(
    const pi4_vibe_input_event_t* event,
    pi4_vibe_word_t button)
{
    return pi4_vibe_input_mouse_button_is_supported(button) &&
        (pi4_vibe_input_mouse_buttons(event) & button) == button;
}

static inline int pi4_vibe_input_mouse_has_buttons(
    const pi4_vibe_input_event_t* event)
{
    return pi4_vibe_input_mouse_buttons(event) != 0;
}

static inline pi4_vibe_sword_t pi4_vibe_input_mouse_delta_x(
    const pi4_vibe_input_event_t* event)
{
    return pi4_vibe_input_event_is_mouse_packet(event) ? event->value0 : 0;
}

static inline pi4_vibe_sword_t pi4_vibe_input_mouse_delta_y(
    const pi4_vibe_input_event_t* event)
{
    return pi4_vibe_input_event_is_mouse_packet(event) ? event->value1 : 0;
}

static inline pi4_vibe_sword_t pi4_vibe_input_mouse_delta(
    const pi4_vibe_input_event_t* event,
    pi4_vibe_word_t axis)
{
    if (axis == PI4_VIBE_INPUT_MOUSE_AXIS_X)
        return pi4_vibe_input_mouse_delta_x(event);
    if (axis == PI4_VIBE_INPUT_MOUSE_AXIS_Y)
        return pi4_vibe_input_mouse_delta_y(event);
    return 0;
}

static inline int pi4_vibe_input_mouse_has_motion(
    const pi4_vibe_input_event_t* event)
{
    return pi4_vibe_input_event_is_mouse_packet(event) &&
        (event->value0 != 0 || event->value1 != 0);
}

typedef struct pi4_vibe_input_status {
    pi4_vibe_word_t abi_version;
    pi4_vibe_word_t event_bytes;
    pi4_vibe_word_t queue_capacity;
    pi4_vibe_word_t queued_events;
    pi4_vibe_word_t total_events;
    pi4_vibe_word_t polled_events;
    pi4_vibe_word_t dropped_events;
    pi4_vibe_word_t capabilities;
    pi4_vibe_word_t keyboard_irq_count;
    pi4_vibe_word_t keyboard_event_count;
    pi4_vibe_word_t keyboard_down_count;
    pi4_vibe_word_t keyboard_last_code;
    pi4_vibe_word_t keyboard_state[8];
    pi4_vibe_word_t mouse_irq_count;
    pi4_vibe_word_t mouse_packet_count;
    pi4_vibe_word_t mouse_sync_loss_count;
    pi4_vibe_word_t mouse_buttons;
    pi4_vibe_sword_t mouse_delta_x_total;
    pi4_vibe_sword_t mouse_delta_y_total;
    pi4_vibe_word_t last_event_device_id;
    pi4_vibe_word_t last_event_type;
    pi4_vibe_word_t status_bytes;
    pi4_vibe_word_t queue_usable_capacity;
    pi4_vibe_word_t overflow_policy;
    pi4_vibe_word_t keyboard_status;
    pi4_vibe_word_t mouse_status;
} pi4_vibe_input_status_t;

typedef struct pi4_vibe_input_device_status {
    pi4_vibe_word_t abi_version;
    pi4_vibe_word_t status_bytes;
    pi4_vibe_word_t device_id;
    pi4_vibe_word_t status;
    pi4_vibe_word_t capabilities;
    pi4_vibe_word_t irq_count;
    pi4_vibe_word_t event_count;
    pi4_vibe_word_t polled_events;
    pi4_vibe_word_t dropped_events;
    pi4_vibe_word_t last_timestamp;
    pi4_vibe_word_t last_event_type;
    pi4_vibe_word_t last_code;
    pi4_vibe_word_t active_state;
    pi4_vibe_sword_t axis_x_total;
    pi4_vibe_sword_t axis_y_total;
    pi4_vibe_word_t reserved0;
} pi4_vibe_input_device_status_t;

static inline int pi4_vibe_input_status_abi_is_current(
    const pi4_vibe_input_status_t* status)
{
    return status &&
        status->abi_version == PI4_VIBE_INPUT_ABI_VERSION &&
        status->event_bytes == PI4_VIBE_INPUT_EVENT_BYTES &&
        status->queue_capacity == PI4_VIBE_INPUT_EVENT_QUEUE_CAPACITY &&
        status->status_bytes == PI4_VIBE_INPUT_STATUS_BYTES &&
        status->queue_usable_capacity ==
            PI4_VIBE_INPUT_EVENT_QUEUE_USABLE_CAPACITY &&
        status->overflow_policy == PI4_VIBE_INPUT_QUEUE_OVERFLOW_DROP_NEWEST;
}

static inline int pi4_vibe_input_status_has_capability(
    const pi4_vibe_input_status_t* status,
    pi4_vibe_word_t capability)
{
    return status && (status->capabilities & capability) == capability;
}

static inline int pi4_vibe_input_device_status_is_ready(
    pi4_vibe_word_t device_status)
{
    return device_status == PI4_VIBE_INPUT_DEVICE_STATUS_READY;
}

static inline int pi4_vibe_input_status_keyboard_is_ready(
    const pi4_vibe_input_status_t* status)
{
    return status &&
        pi4_vibe_input_device_status_is_ready(status->keyboard_status);
}

static inline int pi4_vibe_input_status_mouse_is_ready(
    const pi4_vibe_input_status_t* status)
{
    return status &&
        pi4_vibe_input_device_status_is_ready(status->mouse_status);
}

static inline int pi4_vibe_input_status_uart_is_ready(
    const pi4_vibe_input_status_t* status)
{
    return pi4_vibe_input_status_has_capability(
        status,
        PI4_VIBE_INPUT_CAP_UART_SERIAL);
}

static inline int pi4_vibe_input_status_device_is_ready(
    const pi4_vibe_input_status_t* status,
    pi4_vibe_word_t device_id)
{
    if (device_id == PI4_VIBE_INPUT_DEVICE_KEYBOARD)
        return pi4_vibe_input_status_keyboard_is_ready(status);
    if (device_id == PI4_VIBE_INPUT_DEVICE_MOUSE)
        return pi4_vibe_input_status_mouse_is_ready(status);
    if (device_id == PI4_VIBE_INPUT_DEVICE_UART)
        return pi4_vibe_input_status_uart_is_ready(status);
    if (device_id == PI4_VIBE_INPUT_DEVICE_USB)
        return pi4_vibe_input_status_keyboard_is_ready(status) ||
            pi4_vibe_input_status_mouse_is_ready(status);
    return 0;
}

static inline pi4_vibe_word_t pi4_vibe_input_status_usable_capacity(
    const pi4_vibe_input_status_t* status)
{
    if (!status || !status->queue_usable_capacity)
        return PI4_VIBE_INPUT_EVENT_QUEUE_USABLE_CAPACITY;
    return status->queue_usable_capacity;
}

static inline int pi4_vibe_input_status_counters_are_consistent(
    const pi4_vibe_input_status_t* status)
{
    pi4_vibe_word_t usable;

    if (!pi4_vibe_input_status_abi_is_current(status))
        return 0;
    usable = pi4_vibe_input_status_usable_capacity(status);
    if (usable > status->queue_capacity)
        return 0;
    if (status->queued_events > usable)
        return 0;
    return status->total_events ==
        status->queued_events + status->polled_events + status->dropped_events;
}

static inline int pi4_vibe_input_status_key_is_down(
    const pi4_vibe_input_status_t* status,
    pi4_vibe_word_t code)
{
    return status &&
        code < PI4_VIBE_INPUT_KEY_STATE_BITS &&
        (status->keyboard_state[code >> 6] &
            (1ul << (code & 63))) != 0;
}

static inline int pi4_vibe_input_status_ps2_set1_key_is_down(
    const pi4_vibe_input_status_t* status,
    pi4_vibe_word_t scancode,
    int extended)
{
    return pi4_vibe_input_status_key_is_down(
        status,
        pi4_vibe_input_ps2_set1_key_code(scancode, extended));
}

static inline pi4_vibe_word_t pi4_vibe_input_status_keyboard_modifiers(
    const pi4_vibe_input_status_t* status)
{
    pi4_vibe_word_t modifiers = 0;

    if (pi4_vibe_input_status_ps2_set1_key_is_down(status, 0x2a, 0) ||
        pi4_vibe_input_status_ps2_set1_key_is_down(status, 0x36, 0))
        modifiers |= PI4_VIBE_INPUT_MOD_SHIFT;
    if (pi4_vibe_input_status_ps2_set1_key_is_down(status, 0x1d, 0) ||
        pi4_vibe_input_status_ps2_set1_key_is_down(status, 0x1d, 1))
        modifiers |= PI4_VIBE_INPUT_MOD_CTRL;
    if (pi4_vibe_input_status_ps2_set1_key_is_down(status, 0x38, 0))
        modifiers |= PI4_VIBE_INPUT_MOD_ALT;
    return modifiers;
}

static inline pi4_vibe_word_t pi4_vibe_input_status_mouse_buttons(
    const pi4_vibe_input_status_t* status)
{
    return status ? status->mouse_buttons & PI4_VIBE_INPUT_MOUSE_BUTTON_MASK : 0;
}

static inline int pi4_vibe_input_device_status_abi_is_current(
    const pi4_vibe_input_device_status_t* status)
{
    return status &&
        status->abi_version == PI4_VIBE_INPUT_ABI_VERSION &&
        status->status_bytes == PI4_VIBE_INPUT_DEVICE_STATUS_BYTES &&
        (status->device_id == PI4_VIBE_INPUT_DEVICE_KEYBOARD ||
            status->device_id == PI4_VIBE_INPUT_DEVICE_MOUSE ||
            status->device_id == PI4_VIBE_INPUT_DEVICE_UART ||
            status->device_id == PI4_VIBE_INPUT_DEVICE_USB);
}

static inline int pi4_vibe_input_device_record_is_ready(
    const pi4_vibe_input_device_status_t* status)
{
    return pi4_vibe_input_device_status_abi_is_current(status) &&
        status->status == PI4_VIBE_INPUT_DEVICE_STATUS_READY;
}

static inline int pi4_vibe_input_device_status_has_capability(
    const pi4_vibe_input_device_status_t* status,
    pi4_vibe_word_t capability)
{
    return pi4_vibe_input_device_status_abi_is_current(status) &&
        (status->capabilities & capability) == capability;
}

static inline int pi4_vibe_input_device_status_supports_keyboard(
    const pi4_vibe_input_device_status_t* status)
{
    return pi4_vibe_input_device_status_has_capability(
        status,
        PI4_VIBE_INPUT_DEVICE_CAP_KEYS);
}

static inline int pi4_vibe_input_device_status_supports_mouse(
    const pi4_vibe_input_device_status_t* status)
{
    return pi4_vibe_input_device_status_has_capability(
        status,
        PI4_VIBE_INPUT_DEVICE_CAP_RELATIVE_POINTER) ||
        pi4_vibe_input_device_status_has_capability(
            status,
            PI4_VIBE_INPUT_DEVICE_CAP_BUTTONS);
}

static inline pi4_vibe_word_t pi4_vibe_input_device_status_logical_device_id(
    const pi4_vibe_input_device_status_t* status)
{
    int supports_keyboard;
    int supports_mouse;

    if (!pi4_vibe_input_device_status_abi_is_current(status))
        return 0;
    if (status->device_id != PI4_VIBE_INPUT_DEVICE_USB)
        return status->device_id;
    supports_keyboard =
        pi4_vibe_input_device_status_supports_keyboard(status);
    supports_mouse = pi4_vibe_input_device_status_supports_mouse(status);
    if (supports_keyboard && !supports_mouse)
        return PI4_VIBE_INPUT_DEVICE_KEYBOARD;
    if (supports_mouse && !supports_keyboard)
        return PI4_VIBE_INPUT_DEVICE_MOUSE;
    return PI4_VIBE_INPUT_DEVICE_USB;
}

static inline pi4_vibe_word_t pi4_vibe_input_device_status_physical_device_id(
    const pi4_vibe_input_device_status_t* status)
{
    if (!pi4_vibe_input_device_status_abi_is_current(status))
        return 0;
    return status->device_id;
}

static inline int pi4_vibe_input_device_status_counters_are_consistent(
    const pi4_vibe_input_device_status_t* status)
{
    return pi4_vibe_input_device_status_abi_is_current(status) &&
        status->polled_events <= status->event_count &&
        status->dropped_events <= status->event_count;
}

static inline pi4_vibe_word_t pi4_vibe_input_device_status_keyboard_modifiers(
    const pi4_vibe_input_device_status_t* status)
{
    if (!pi4_vibe_input_device_status_abi_is_current(status) ||
        pi4_vibe_input_device_status_logical_device_id(status) !=
            PI4_VIBE_INPUT_DEVICE_KEYBOARD)
        return 0;
    return status->active_state &
        (PI4_VIBE_INPUT_MOD_SHIFT |
            PI4_VIBE_INPUT_MOD_CTRL |
            PI4_VIBE_INPUT_MOD_ALT);
}

static inline pi4_vibe_word_t pi4_vibe_input_device_status_mouse_buttons(
    const pi4_vibe_input_device_status_t* status)
{
    if (!pi4_vibe_input_device_status_abi_is_current(status) ||
        pi4_vibe_input_device_status_logical_device_id(status) !=
            PI4_VIBE_INPUT_DEVICE_MOUSE)
        return 0;
    return status->active_state & PI4_VIBE_INPUT_MOUSE_BUTTON_MASK;
}

typedef struct pi4_vibe_fb_info {
    pi4_vibe_word_t width;
    pi4_vibe_word_t height;
    pi4_vibe_word_t pitch;
    pi4_vibe_word_t backend;
    pi4_vibe_word_t frame_bytes;
    pi4_vibe_word_t palette_bytes;
    pi4_vibe_word_t scale;
    pi4_vibe_word_t view_x;
    pi4_vibe_word_t view_y;
    pi4_vibe_word_t view_width;
    pi4_vibe_word_t view_height;
    pi4_vibe_word_t policy;
    pi4_vibe_word_t dirty_x;
    pi4_vibe_word_t dirty_y;
    pi4_vibe_word_t dirty_width;
    pi4_vibe_word_t dirty_height;
    pi4_vibe_word_t dirty_count;
    pi4_vibe_word_t capabilities;
    pi4_vibe_word_t present_format;
    pi4_vibe_word_t max_present_width;
    pi4_vibe_word_t max_present_height;
} pi4_vibe_fb_info_t;

typedef struct pi4_vibe_present_indexed {
    const void* frame;
    const void* palette;
    pi4_vibe_word_t width;
    pi4_vibe_word_t height;
} pi4_vibe_present_indexed_t;

static inline pi4_vibe_word_t pi4_vibe_present_indexed_frame_bytes(
    const pi4_vibe_present_indexed_t* present)
{
    if (!present || !present->width || !present->height)
        return 0;
    if (present->width > ~0ul / present->height)
        return 0;
    return present->width * present->height;
}

static inline int pi4_vibe_present_indexed_descriptor_is_valid(
    const pi4_vibe_present_indexed_t* present)
{
    return present &&
        present->frame &&
        present->palette &&
        pi4_vibe_present_indexed_frame_bytes(present) != 0;
}

static inline int pi4_vibe_fb_info_has_capability(
    const pi4_vibe_fb_info_t* info,
    pi4_vibe_word_t capability)
{
    return info && (info->capabilities & capability) == capability;
}

static inline pi4_vibe_word_t pi4_vibe_fb_info_framebuffer_bytes(
    const pi4_vibe_fb_info_t* info)
{
    return info ? info->frame_bytes : 0;
}

static inline int pi4_vibe_fb_info_is_xrgb8888_lfb(
    const pi4_vibe_fb_info_t* info)
{
    return info &&
        info->backend == PI4_VIBE_FB_BACKEND_XRGB8888_LFB &&
        pi4_vibe_fb_info_has_capability(
            info,
            PI4_VIBE_FB_CAP_XRGB8888_LFB);
}

static inline int pi4_vibe_fb_info_supports_indexed_rgb24(
    const pi4_vibe_fb_info_t* info)
{
    return info &&
        pi4_vibe_fb_info_is_xrgb8888_lfb(info) &&
        pi4_vibe_fb_info_has_capability(
            info,
            PI4_VIBE_FB_CAP_PRESENT_INDEXED) &&
        pi4_vibe_fb_info_has_capability(
            info,
            PI4_VIBE_FB_CAP_PRESENT_RGB_PALETTE) &&
        info->present_format == PI4_VIBE_FB_FORMAT_INDEX8_RGB24;
}

static inline int pi4_vibe_fb_info_present_size_is_accepted(
    const pi4_vibe_fb_info_t* info,
    pi4_vibe_word_t width,
    pi4_vibe_word_t height)
{
    if (!info || !width || !height ||
        !pi4_vibe_fb_info_supports_indexed_rgb24(info))
        return 0;
    if (info->max_present_width && width > info->max_present_width)
        return 0;
    if (info->max_present_height && height > info->max_present_height)
        return 0;
    return 1;
}

static inline int pi4_vibe_fb_info_accepts_present_indexed(
    const pi4_vibe_fb_info_t* info,
    const pi4_vibe_present_indexed_t* present)
{
    return pi4_vibe_present_indexed_descriptor_is_valid(present) &&
        pi4_vibe_fb_info_present_size_is_accepted(
            info,
            present->width,
            present->height);
}

typedef struct pi4_vibe_clock_time {
    pi4_vibe_word_t ticks;
    pi4_vibe_word_t frequency_hz;
    pi4_vibe_word_t milliseconds;
    pi4_vibe_word_t flags;
} pi4_vibe_clock_time_t;

typedef struct pi4_vibe_exec_request {
    pi4_vibe_word_t abi_version;
    pi4_vibe_word_t request_bytes;
    pi4_vibe_word_t compatibility_token;
    const char* app_path;
} pi4_vibe_exec_request_t;

typedef struct pi4_vibe_audio_voice_desc {
    const unsigned char* samples;
    pi4_vibe_word_t length;
    pi4_vibe_word_t volume;
    pi4_vibe_word_t separation;
    pi4_vibe_word_t pitch;
    pi4_vibe_word_t sound_id;
    pi4_vibe_word_t flags;
    pi4_vibe_word_t sample_rate;
    pi4_vibe_word_t music_format;
    pi4_vibe_word_t music_note_events;
    pi4_vibe_word_t music_control_events;
    pi4_vibe_word_t music_active_voice_peak;
    pi4_vibe_word_t music_emitted_samples;
    pi4_vibe_word_t music_stream_start;
    pi4_vibe_word_t music_stream_end;
    pi4_vibe_word_t music_stream_loop_count;
} pi4_vibe_audio_voice_desc_t;

typedef struct pi4_vibe_audio_pcm_desc {
    const unsigned char* samples;
    pi4_vibe_word_t length;
    pi4_vibe_word_t sample_rate;
    pi4_vibe_word_t channels;
    pi4_vibe_word_t format;
    pi4_vibe_word_t flags;
    pi4_vibe_word_t reserved0;
    pi4_vibe_word_t reserved1;
    pi4_vibe_word_t reserved2;
    pi4_vibe_word_t reserved3;
    pi4_vibe_word_t reserved4;
    pi4_vibe_word_t reserved5;
    pi4_vibe_word_t reserved6;
    pi4_vibe_word_t reserved7;
    pi4_vibe_word_t reserved8;
    pi4_vibe_word_t reserved9;
} pi4_vibe_audio_pcm_desc_t;

typedef struct pi4_vibe_audio_device_info {
    pi4_vibe_word_t device_kind;
    pi4_vibe_word_t status;
    pi4_vibe_word_t sample_rate;
    pi4_vibe_word_t channels;
    pi4_vibe_word_t format;
    pi4_vibe_word_t ring_bytes;
    pi4_vibe_word_t period_bytes;
    pi4_vibe_word_t capabilities;
    pi4_vibe_word_t active_voices;
    pi4_vibe_word_t irq_count;
    pi4_vibe_word_t refill_count;
    pi4_vibe_word_t playback_start_count;
} pi4_vibe_audio_device_info_t;

typedef struct pi4_vibe_audio_pcm_ring_info {
    pi4_vibe_word_t format;
    pi4_vibe_word_t channels;
    pi4_vibe_word_t sample_rate;
    pi4_vibe_word_t ring_bytes;
    pi4_vibe_word_t period_bytes;
    pi4_vibe_word_t write_offset;
    pi4_vibe_word_t active_half;
    pi4_vibe_word_t queued_bytes;
    pi4_vibe_word_t mixed_bytes;
    pi4_vibe_word_t underrun_count;
    pi4_vibe_word_t overwrite_count;
    pi4_vibe_word_t clip_count;
} pi4_vibe_audio_pcm_ring_info_t;

typedef struct pi4_vibe_audio_stream_info {
    pi4_vibe_word_t stream_mode;
    pi4_vibe_word_t flags;
    pi4_vibe_word_t handle;
    pi4_vibe_word_t pull_request_count;
    pi4_vibe_word_t pull_refill_count;
    pi4_vibe_word_t pending_pull_requests;
    pi4_vibe_word_t queued_bytes;
    pi4_vibe_word_t low_water_bytes;
    pi4_vibe_word_t active_streams;
    pi4_vibe_word_t underrun_count;
    pi4_vibe_word_t drop_count;
    pi4_vibe_word_t position_bytes;
} pi4_vibe_audio_stream_info_t;

static inline int pi4_vibe_audio_device_info_is_ready(
    const pi4_vibe_audio_device_info_t* info)
{
    return info &&
        info->status == PI4_VIBE_AUDIO_DEVICE_STATUS_READY &&
        info->device_kind != PI4_VIBE_AUDIO_DEVICE_NONE;
}

static inline int pi4_vibe_audio_device_info_has_capability(
    const pi4_vibe_audio_device_info_t* info,
    pi4_vibe_word_t capability)
{
    return pi4_vibe_audio_device_info_is_ready(info) &&
        (info->capabilities & capability) == capability;
}

static inline int pi4_vibe_audio_device_info_has_pcm_queue(
    const pi4_vibe_audio_device_info_t* info)
{
    return pi4_vibe_audio_device_info_is_ready(info) &&
        pi4_vibe_audio_device_info_has_capability(
            info,
            PI4_VIBE_AUDIO_CAP_PCM_QUEUE) &&
        info->ring_bytes != 0 &&
        info->period_bytes != 0 &&
        info->period_bytes <= info->ring_bytes;
}

static inline int pi4_vibe_audio_device_info_is_pi4_device(
    const pi4_vibe_audio_device_info_t* info)
{
    return info && info->device_kind == PI4_VIBE_AUDIO_DEVICE_PI4_PWM;
}

static inline int pi4_vibe_audio_device_info_is_playback_ready(
    const pi4_vibe_audio_device_info_t* info)
{
    return pi4_vibe_audio_device_info_is_pi4_device(info) &&
        pi4_vibe_audio_device_info_has_pcm_queue(info) &&
        info->sample_rate != 0 &&
        info->channels == 2 &&
        info->format == PI4_VIBE_AUDIO_FORMAT_U8_STEREO &&
        (info->capabilities & PI4_VIBE_AUDIO_CAP_FULL_MASK) ==
            PI4_VIBE_AUDIO_CAP_FULL_MASK;
}

static inline int pi4_vibe_audio_device_info_is_hardware_unproven(
    const pi4_vibe_audio_device_info_t* info)
{
    return info &&
        info->device_kind != PI4_VIBE_AUDIO_DEVICE_NONE &&
        info->status == PI4_VIBE_AUDIO_DEVICE_STATUS_ABSENT &&
        info->capabilities != 0 &&
        (info->capabilities & ~PI4_VIBE_AUDIO_CAP_FULL_MASK) == 0;
}

static inline int pi4_vibe_audio_pcm_ring_info_is_ready(
    const pi4_vibe_audio_pcm_ring_info_t* info)
{
    return info &&
        info->format == PI4_VIBE_AUDIO_FORMAT_U8_STEREO &&
        info->channels == 2 &&
        info->sample_rate != 0 &&
        info->ring_bytes != 0 &&
        info->period_bytes != 0 &&
        info->period_bytes <= info->ring_bytes;
}

static inline int pi4_vibe_audio_pcm_ring_info_counters_are_bounded(
    const pi4_vibe_audio_pcm_ring_info_t* info)
{
    return pi4_vibe_audio_pcm_ring_info_is_ready(info) &&
        info->write_offset < info->ring_bytes &&
        info->queued_bytes <= info->ring_bytes;
}

static inline int pi4_vibe_audio_stream_info_matches_handle(
    const pi4_vibe_audio_stream_info_t* info,
    pi4_vibe_word_t handle)
{
    return info &&
        handle != 0 &&
        info->handle == handle &&
        info->stream_mode != PI4_VIBE_AUDIO_STREAM_NONE;
}

static inline int pi4_vibe_audio_stream_info_refills_are_ordered(
    const pi4_vibe_audio_stream_info_t* info)
{
    pi4_vibe_word_t pending;

    if (!info || info->pull_refill_count > info->pull_request_count)
        return 0;

    pending = info->pull_request_count - info->pull_refill_count;
    return info->pending_pull_requests == pending;
}

static inline int pi4_vibe_audio_stream_info_needs_refill(
    const pi4_vibe_audio_stream_info_t* info)
{
    return info &&
        pi4_vibe_audio_stream_info_refills_are_ordered(info) &&
        info->pending_pull_requests != 0 &&
        (info->flags & PI4_VIBE_AUDIO_STREAM_FLAG_REFILL_PENDING) != 0;
}

static inline int pi4_vibe_audio_stream_info_is_active_push(
    const pi4_vibe_audio_stream_info_t* info,
    pi4_vibe_word_t handle)
{
    return pi4_vibe_audio_stream_info_matches_handle(info, handle) &&
        info->stream_mode == PI4_VIBE_AUDIO_STREAM_PUSH &&
        (info->flags & PI4_VIBE_AUDIO_STREAM_FLAG_ACTIVE) != 0 &&
        pi4_vibe_audio_stream_info_refills_are_ordered(info);
}

extern pi4_vibe_word_t vibe_user_argc;
extern char** vibe_user_argv;
extern char** vibe_user_environ;
extern pi4_vibe_word_t* vibe_user_auxv;
extern pi4_vibe_word_t vibe_user_start_status;
extern pi4_vibe_word_t vibe_user_entry_stack;

long vibe_user_syscall0(unsigned int number);
long vibe_user_syscall1(unsigned int number, pi4_vibe_word_t arg0);
long vibe_user_syscall2(unsigned int number, pi4_vibe_word_t arg0, pi4_vibe_word_t arg1);
long vibe_user_syscall3(
    unsigned int number,
    pi4_vibe_word_t arg0,
    pi4_vibe_word_t arg1,
    pi4_vibe_word_t arg2);
long vibe_user_syscall_errno(long raw_result, long fallback_errno);
long vibe_user_errno_from_result(long raw_result, long fallback_errno);
long vibe_user_open(const char* path, pi4_vibe_word_t flags, pi4_vibe_word_t mode);
long vibe_user_write(pi4_vibe_word_t fd, const void* buffer, pi4_vibe_word_t bytes);
long vibe_user_ioctl(pi4_vibe_word_t fd, pi4_vibe_word_t request, void* arg);
long vibe_user_read(pi4_vibe_word_t fd, void* buffer, pi4_vibe_word_t bytes);
long vibe_user_pread(
    pi4_vibe_word_t fd,
    void* buffer,
    pi4_vibe_word_t bytes,
    pi4_vibe_sword_t offset);
long vibe_user_lseek(pi4_vibe_word_t fd, pi4_vibe_sword_t offset, pi4_vibe_word_t whence);
long vibe_user_close(pi4_vibe_word_t fd);
long vibe_user_stat(const char* path, struct stat* out);
long vibe_user_fstat(pi4_vibe_word_t fd, struct stat* out);
long vibe_user_file_open(const char* path);
long vibe_user_file_size(pi4_vibe_word_t fd);
long vibe_user_file_size_path(const char* path, pi4_vibe_word_t* out_size);
long vibe_user_file_read(pi4_vibe_word_t fd, void* buffer, pi4_vibe_word_t bytes);
long vibe_user_file_read_at(
    const char* path,
    pi4_vibe_sword_t offset,
    void* buffer,
    pi4_vibe_word_t bytes,
    pi4_vibe_word_t* out_read);
long vibe_user_file_seek(pi4_vibe_word_t fd, pi4_vibe_sword_t offset, pi4_vibe_word_t whence);
long vibe_user_file_close(pi4_vibe_word_t fd);
void vibe_user_file_probe_assets(void);
void vibe_user_exit(int status);
void vibe_user_exit_status(int status);
long vibe_user_exec_request(
    const pi4_vibe_exec_request_t* request,
    char* const argv[],
    char* const envp[]);
long vibe_user_execv_app(const char* app_path, char* const argv[]);
long vibe_user_execv(const char* app_path, char* const argv[]);
long vibe_user_fb_get_info(pi4_vibe_fb_info_t* info);
long vibe_user_fb_can_present_indexed(
    const pi4_vibe_fb_info_t* info,
    const pi4_vibe_present_indexed_t* present);
long vibe_user_fb_present_indexed(const pi4_vibe_present_indexed_t* present);
long vibe_user_present_indexed(const pi4_vibe_present_indexed_t* present);
long vibe_user_fb_present_indexed_checked(const pi4_vibe_present_indexed_t* present);
long vibe_user_present_indexed_checked(const pi4_vibe_present_indexed_t* present);
long vibe_user_input_poll(pi4_vibe_input_event_t* event);
long vibe_user_poll_input(pi4_vibe_input_event_t* event);
long vibe_user_drain_input(
    pi4_vibe_input_event_t* events,
    pi4_vibe_word_t max_events);
long vibe_user_input_poll_uart_event(pi4_vibe_word_t* code);
long vibe_user_poll_uart_event(pi4_vibe_word_t* code);
long vibe_user_input_status(pi4_vibe_input_status_t* status);
long vibe_user_input_device_status(
    pi4_vibe_word_t device_id,
    pi4_vibe_input_device_status_t* status);
long vibe_user_input_keyboard_status(pi4_vibe_input_device_status_t* status);
long vibe_user_input_mouse_status(pi4_vibe_input_device_status_t* status);
long vibe_user_input_uart_status(pi4_vibe_input_device_status_t* status);
long vibe_user_input_usb_status(pi4_vibe_input_device_status_t* status);
pi4_vibe_word_t vibe_user_input_event_source(
    const pi4_vibe_input_event_t* event);
pi4_vibe_word_t vibe_user_input_event_physical_device_id(
    const pi4_vibe_input_event_t* event);
pi4_vibe_word_t vibe_user_input_event_logical_device_id(
    const pi4_vibe_input_event_t* event);
long vibe_user_input_event_is_key(const pi4_vibe_input_event_t* event);
long vibe_user_input_event_is_mouse_packet(
    const pi4_vibe_input_event_t* event);
long vibe_user_input_event_is_uart_serial(
    const pi4_vibe_input_event_t* event);
long vibe_user_input_event_is_usb_hid(const pi4_vibe_input_event_t* event);
long vibe_user_clock_gettime(
    pi4_vibe_word_t clock_id,
    pi4_vibe_clock_time_t* out);
long vibe_user_clock_monotonic(pi4_vibe_clock_time_t* out);
pi4_vibe_word_t vibe_user_monotonic_ticks(void);
pi4_vibe_word_t vibe_user_monotonic_milliseconds(void);
pi4_vibe_word_t vibe_user_clock_ticks_to_milliseconds(
    pi4_vibe_word_t ticks,
    pi4_vibe_word_t frequency_hz);
long vibe_user_audio_device_start(void);
long vibe_user_audio_device_shutdown(void);
long vibe_user_audio_mixer_start(
    pi4_vibe_word_t handle,
    const pi4_vibe_audio_voice_desc_t* desc);
long vibe_user_audio_mixer_stop(pi4_vibe_word_t handle);
long vibe_user_audio_mixer_update(
    pi4_vibe_word_t handle,
    const pi4_vibe_audio_voice_desc_t* desc);
long vibe_user_audio_mixer_is_playing(pi4_vibe_word_t handle);
long vibe_user_audio_pcm_buffered_bytes(pi4_vibe_word_t handle);
long vibe_user_audio_pcm_pull_state(pi4_vibe_word_t handle);
long vibe_user_audio_device_info(pi4_vibe_audio_device_info_t* info);
long vibe_user_audio_pcm_ring_info(pi4_vibe_audio_pcm_ring_info_t* info);
long vibe_user_audio_stream_info(
    pi4_vibe_word_t handle,
    pi4_vibe_audio_stream_info_t* info);
long vibe_user_audio_device_info_ioctl(pi4_vibe_audio_device_info_t* info);
long vibe_user_audio_pcm_ring_info_ioctl(pi4_vibe_audio_pcm_ring_info_t* info);
long vibe_user_audio_stream_info_ioctl(
    pi4_vibe_word_t handle,
    pi4_vibe_audio_stream_info_t* info);
long vibe_user_audio_pcm_open(const pi4_vibe_audio_pcm_desc_t* format);
long vibe_user_audio_pcm_write(
    pi4_vibe_word_t handle,
    const pi4_vibe_audio_voice_desc_t* desc);
long vibe_user_audio_pcm_write_desc(
    pi4_vibe_word_t handle,
    const pi4_vibe_audio_pcm_desc_t* desc);
long vibe_user_audio_pcm_drain(pi4_vibe_word_t handle);
long vibe_user_audio_pcm_close(pi4_vibe_word_t handle);
long vibe_user_audio_stream_open(const pi4_vibe_audio_pcm_desc_t* format);
long vibe_user_audio_stream_write(
    pi4_vibe_word_t handle,
    const pi4_vibe_audio_voice_desc_t* desc);
long vibe_user_audio_stream_drain(pi4_vibe_word_t handle);
long vibe_user_audio_stream_close(pi4_vibe_word_t handle);

#endif

#endif
