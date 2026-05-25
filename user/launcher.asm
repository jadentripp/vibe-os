BITS 32

%define SCREEN_W 2560
%define SCREEN_H 1440
%define FRAME_BYTES 3686400
%define PALETTE_BYTES 768
%define LAUNCHER_ASSET_BYTES 131072
%define FONT_PIXEL_SIZE 11
%define FONT_ADVANCE 72

%define INPUT_DEVICE_KEYBOARD 1
%define INPUT_DEVICE_MOUSE 2
%define INPUT_EVENT_KEY 1
%define INPUT_EVENT_MOUSE_PACKET 2
%define INPUT_KEY_PRESSED 1
%define INPUT_MOUSE_BUTTON_LEFT 1

%define INPUT_EVENT_TIMESTAMP 0
%define INPUT_EVENT_DEVICE_ID 4
%define INPUT_EVENT_TYPE 8
%define INPUT_EVENT_CODE 12
%define INPUT_EVENT_VALUE0 16
%define INPUT_EVENT_VALUE1 20
%define INPUT_EVENT_VALUE2 24
%define INPUT_EVENT_BYTES 28

%define SCANCODE_1 0x02
%define SCANCODE_2 0x03
%define SCANCODE_ENTER 0x1c
%define SCANCODE_W 0x11
%define SCANCODE_S 0x1f
%define SCANCODE_UP 0x48
%define SCANCODE_DOWN 0x50

%define COLOR_DESKTOP_TOP 1
%define COLOR_DESKTOP_MID 2
%define COLOR_DESKTOP_BOTTOM 3
%define COLOR_MENU 4
%define COLOR_MENU_SHADOW 5
%define COLOR_WINDOW 6
%define COLOR_WINDOW_TITLE 7
%define COLOR_WINDOW_EDGE 8
%define COLOR_DOCK 9
%define COLOR_DOCK_EDGE 10
%define COLOR_PAYLOAD0_ICON 11
%define COLOR_PAYLOAD1_ICON 12
%define COLOR_SELECTED 13
%define COLOR_TRAFFIC_RED 14
%define COLOR_TEXT 15

%define WINDOW_X 220
%define WINDOW_Y 160
%define WINDOW_W 2120
%define WINDOW_H 670
%define DOCK_X 390
%define DOCK_Y 1000
%define DOCK_W 1780
%define DOCK_H 400
%define PAYLOAD0_HIT_X 635
%define PAYLOAD0_HIT_Y 1020
%define PAYLOAD1_HIT_X 1475
%define PAYLOAD1_HIT_Y 1020
%define PAYLOAD_HIT_W 470
%define PAYLOAD_HIT_H 365
%define PAYLOAD0_ICON_X 740
%define PAYLOAD0_ICON_Y 1038
%define PAYLOAD1_ICON_X 1580
%define PAYLOAD1_ICON_Y 1038
%define PAYLOAD_ICON_SIZE 240
%define PAYLOAD_ICON_PIXELS PAYLOAD_ICON_SIZE * PAYLOAD_ICON_SIZE
%define LAUNCHER_ART_PAYLOAD0 0x00000001
%define LAUNCHER_ART_PAYLOAD1 0x00000002
%define LAUNCHER_ART_PALETTE_BASE 32
%define LAUNCHER_ART_PALETTE_LEVELS 6
%define LAUNCHER_ART_PALETTE_STEP 51
%define WAD_DIR_ENTRY_BYTES 16
%define PAK_DIR_ENTRY_BYTES 64

extern vibe_user_present_indexed_checked
extern vibe_user_poll_input
extern vibe_user_sleep_ticks
extern vibe_user_write_all
extern vibe_user_sbrk
extern vibe_user_open
extern vibe_user_read
extern vibe_user_lseek
extern vibe_user_close

section .text
global vibe_launcher_choose_payload

align 16
vibe_launcher_choose_payload:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi

    call launcher_ensure_buffers
    test eax, eax
    jne .fallback

    call launcher_init_palette
    call launcher_load_art
    mov dword [launcher_selected], 0
    mov dword [launcher_focus], 1
    mov dword [launcher_cursor_x], 860
    mov dword [launcher_cursor_y], 1215

    push launcher_ready_text
    push 1
    call vibe_user_write_all
    add esp, 8

.loop:
    call launcher_draw
    call launcher_present
    call launcher_drain_input
    mov eax, [launcher_selected]
    test eax, eax
    jne .selected

    push 1
    call vibe_user_sleep_ticks
    add esp, 4
    jmp .loop

.selected:
    cmp eax, 2
    je .quake
    mov eax, payload0_path
    jmp .done

.quake:
    mov eax, payload1_path
    jmp .done

.fallback:
    mov eax, payload0_path

.done:
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

align 16
launcher_init_palette:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    xor eax, eax
    mov ecx, PALETTE_BYTES
    mov edi, [launcher_palette_ptr]
    cld
    rep stosb

    mov edi, [launcher_palette_ptr]
    mov byte [edi + COLOR_DESKTOP_TOP * 3 + 0], 31
    mov byte [edi + COLOR_DESKTOP_TOP * 3 + 1], 73
    mov byte [edi + COLOR_DESKTOP_TOP * 3 + 2], 103

    mov byte [edi + COLOR_DESKTOP_MID * 3 + 0], 51
    mov byte [edi + COLOR_DESKTOP_MID * 3 + 1], 106
    mov byte [edi + COLOR_DESKTOP_MID * 3 + 2], 128

    mov byte [edi + COLOR_DESKTOP_BOTTOM * 3 + 0], 79
    mov byte [edi + COLOR_DESKTOP_BOTTOM * 3 + 1], 132
    mov byte [edi + COLOR_DESKTOP_BOTTOM * 3 + 2], 122

    mov byte [edi + COLOR_MENU * 3 + 0], 44
    mov byte [edi + COLOR_MENU * 3 + 1], 55
    mov byte [edi + COLOR_MENU * 3 + 2], 68

    mov byte [edi + COLOR_MENU_SHADOW * 3 + 0], 92
    mov byte [edi + COLOR_MENU_SHADOW * 3 + 1], 106
    mov byte [edi + COLOR_MENU_SHADOW * 3 + 2], 117

    mov byte [edi + COLOR_WINDOW * 3 + 0], 234
    mov byte [edi + COLOR_WINDOW * 3 + 1], 238
    mov byte [edi + COLOR_WINDOW * 3 + 2], 242

    mov byte [edi + COLOR_WINDOW_TITLE * 3 + 0], 103
    mov byte [edi + COLOR_WINDOW_TITLE * 3 + 1], 131
    mov byte [edi + COLOR_WINDOW_TITLE * 3 + 2], 157

    mov byte [edi + COLOR_WINDOW_EDGE * 3 + 0], 48
    mov byte [edi + COLOR_WINDOW_EDGE * 3 + 1], 61
    mov byte [edi + COLOR_WINDOW_EDGE * 3 + 2], 74

    mov byte [edi + COLOR_DOCK * 3 + 0], 42
    mov byte [edi + COLOR_DOCK * 3 + 1], 53
    mov byte [edi + COLOR_DOCK * 3 + 2], 66

    mov byte [edi + COLOR_DOCK_EDGE * 3 + 0], 118
    mov byte [edi + COLOR_DOCK_EDGE * 3 + 1], 139
    mov byte [edi + COLOR_DOCK_EDGE * 3 + 2], 154

    mov byte [edi + COLOR_PAYLOAD0_ICON * 3 + 0], 190
    mov byte [edi + COLOR_PAYLOAD0_ICON * 3 + 1], 91
    mov byte [edi + COLOR_PAYLOAD0_ICON * 3 + 2], 54

    mov byte [edi + COLOR_PAYLOAD1_ICON * 3 + 0], 59
    mov byte [edi + COLOR_PAYLOAD1_ICON * 3 + 1], 116
    mov byte [edi + COLOR_PAYLOAD1_ICON * 3 + 2], 147

    mov byte [edi + COLOR_SELECTED * 3 + 0], 45
    mov byte [edi + COLOR_SELECTED * 3 + 1], 102
    mov byte [edi + COLOR_SELECTED * 3 + 2], 163

    mov byte [edi + COLOR_TRAFFIC_RED * 3 + 0], 214
    mov byte [edi + COLOR_TRAFFIC_RED * 3 + 1], 68
    mov byte [edi + COLOR_TRAFFIC_RED * 3 + 2], 77

    mov byte [edi + COLOR_TEXT * 3 + 0], 238
    mov byte [edi + COLOR_TEXT * 3 + 1], 242
    mov byte [edi + COLOR_TEXT * 3 + 2], 255

    xor ebx, ebx
.art_r:
    cmp ebx, LAUNCHER_ART_PALETTE_LEVELS
    jae .art_done
    xor ecx, ecx
.art_g:
    cmp ecx, LAUNCHER_ART_PALETTE_LEVELS
    jae .next_art_r
    xor edx, edx
.art_b:
    cmp edx, LAUNCHER_ART_PALETTE_LEVELS
    jae .next_art_g
    mov eax, ebx
    imul eax, 36
    mov esi, ecx
    imul esi, 6
    add eax, esi
    add eax, edx
    add eax, LAUNCHER_ART_PALETTE_BASE
    imul eax, 3
    mov edi, [launcher_palette_ptr]
    add edi, eax
    mov eax, ebx
    imul eax, LAUNCHER_ART_PALETTE_STEP
    mov [edi + 0], al
    mov eax, ecx
    imul eax, LAUNCHER_ART_PALETTE_STEP
    mov [edi + 1], al
    mov eax, edx
    imul eax, LAUNCHER_ART_PALETTE_STEP
    mov [edi + 2], al
    inc edx
    jmp .art_b
.next_art_g:
    inc ecx
    jmp .art_g
.next_art_r:
    inc ebx
    jmp .art_r
.art_done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

align 16
launcher_ensure_buffers:
    cmp dword [launcher_frame_ptr], 0
    jne .ready

    push launcher_alloc_base
    push FRAME_BYTES + PALETTE_BYTES + LAUNCHER_ASSET_BYTES
    call vibe_user_sbrk
    add esp, 8
    test eax, eax
    jne .done

    mov eax, [launcher_alloc_base]
    test eax, eax
    je .alloc_failed
    mov [launcher_frame_ptr], eax
    add eax, FRAME_BYTES
    mov [launcher_palette_ptr], eax
    add eax, PALETTE_BYTES
    mov [launcher_asset_ptr], eax

.ready:
    xor eax, eax
    ret

.alloc_failed:
    mov eax, -12
.done:
    ret

align 16
launcher_draw:
    mov eax, 0
    mov ebx, 0
    mov ecx, SCREEN_W
    mov edx, 384
    mov edi, COLOR_DESKTOP_TOP
    call launcher_fill_rect

    mov eax, 0
    mov ebx, 384
    mov ecx, SCREEN_W
    mov edx, 480
    mov edi, COLOR_DESKTOP_MID
    call launcher_fill_rect

    mov eax, 0
    mov ebx, 864
    mov ecx, SCREEN_W
    mov edx, 336
    mov edi, COLOR_DESKTOP_BOTTOM
    call launcher_fill_rect

    mov eax, 0
    mov ebx, 0
    mov ecx, SCREEN_W
    mov edx, 84
    mov edi, COLOR_MENU
    call launcher_fill_rect

    mov eax, 0
    mov ebx, 84
    mov ecx, SCREEN_W
    mov edx, 6
    mov edi, COLOR_MENU_SHADOW
    call launcher_fill_rect

    mov eax, 41
    mov ebx, 9
    mov esi, launcher_title_text
    call launcher_draw_text

    mov eax, 2075
    mov ebx, 9
    mov esi, launcher_menu_right_text
    call launcher_draw_text

    call launcher_draw_window
    call launcher_draw_dock
    call launcher_draw_cursor
    ret

align 16
launcher_draw_window:
    mov eax, WINDOW_X
    mov ebx, WINDOW_Y
    mov ecx, WINDOW_W
    mov edx, WINDOW_H
    mov edi, COLOR_WINDOW_EDGE
    call launcher_fill_rect

    mov eax, WINDOW_X + 2
    mov ebx, WINDOW_Y + 2
    mov ecx, WINDOW_W - 4
    mov edx, WINDOW_H - 4
    mov edi, COLOR_WINDOW
    call launcher_fill_rect

    mov eax, WINDOW_X + 2
    mov ebx, WINDOW_Y + 2
    mov ecx, WINDOW_W - 4
    mov edx, 117
    mov edi, COLOR_WINDOW_TITLE
    call launcher_fill_rect

    mov eax, WINDOW_X + 49
    mov ebx, WINDOW_Y + 53
    mov ecx, 34
    mov edx, 34
    mov edi, COLOR_TRAFFIC_RED
    call launcher_fill_rect

    mov eax, WINDOW_X + 109
    mov ebx, WINDOW_Y + 53
    mov ecx, 34
    mov edx, 34
    mov edi, COLOR_PAYLOAD0_ICON
    call launcher_fill_rect

    mov eax, WINDOW_X + 169
    mov ebx, WINDOW_Y + 53
    mov ecx, 34
    mov edx, 34
    mov edi, COLOR_PAYLOAD1_ICON
    call launcher_fill_rect

    mov eax, 1028
    mov ebx, WINDOW_Y + 24
    mov esi, launcher_window_title_text
    call launcher_draw_text

    mov eax, WINDOW_X + 34
    mov ebx, WINDOW_Y + 191
    mov ecx, WINDOW_W - 68
    mov edx, 427
    mov edi, COLOR_DESKTOP_TOP
    call launcher_fill_rect

    mov eax, WINDOW_X + 41
    mov ebx, WINDOW_Y + 217
    mov ecx, WINDOW_W - 83
    mov edx, 376
    mov edi, COLOR_DESKTOP_MID
    call launcher_fill_rect

    mov eax, 848
    mov ebx, 461
    mov esi, launcher_desktop_text
    call launcher_draw_text

    ret

align 16
launcher_draw_dock:
    mov eax, DOCK_X
    mov ebx, DOCK_Y
    mov ecx, DOCK_W
    mov edx, DOCK_H
    mov edi, COLOR_DOCK_EDGE
    call launcher_fill_rect

    mov eax, DOCK_X + 2
    mov ebx, DOCK_Y + 2
    mov ecx, DOCK_W - 4
    mov edx, DOCK_H - 4
    mov edi, COLOR_DOCK
    call launcher_fill_rect

    cmp dword [launcher_focus], 1
    jne .payload0_not_focused
    mov eax, PAYLOAD0_HIT_X
    mov ebx, PAYLOAD0_HIT_Y
    mov ecx, PAYLOAD_HIT_W
    mov edx, PAYLOAD_HIT_H
    mov edi, COLOR_SELECTED
    call launcher_fill_rect
.payload0_not_focused:

    cmp dword [launcher_focus], 2
    jne .payload1_not_focused
    mov eax, PAYLOAD1_HIT_X
    mov ebx, PAYLOAD1_HIT_Y
    mov ecx, PAYLOAD_HIT_W
    mov edx, PAYLOAD_HIT_H
    mov edi, COLOR_SELECTED
    call launcher_fill_rect
.payload1_not_focused:

    call launcher_draw_payload0_icon
    call launcher_draw_payload1_icon
    ret

align 16
launcher_draw_payload0_icon:
    mov eax, PAYLOAD0_ICON_X
    mov ebx, PAYLOAD0_ICON_Y
    mov ecx, PAYLOAD_ICON_SIZE
    mov edx, PAYLOAD_ICON_SIZE
    mov edi, COLOR_WINDOW_EDGE
    call launcher_fill_rect

    mov eax, PAYLOAD0_ICON_X + 2
    mov ebx, PAYLOAD0_ICON_Y + 2
    mov ecx, PAYLOAD_ICON_SIZE - 4
    mov edx, PAYLOAD_ICON_SIZE - 4
    mov edi, COLOR_PAYLOAD0_ICON
    call launcher_fill_rect

    test dword [launcher_art_flags], LAUNCHER_ART_PAYLOAD0
    jz .fallback_art
    mov eax, PAYLOAD0_ICON_X
    mov ebx, PAYLOAD0_ICON_Y
    mov esi, launcher_icon0_pixels
    call launcher_draw_icon_pixels
    jmp .label

.fallback_art:
    mov eax, PAYLOAD0_ICON_X + 14
    mov ebx, PAYLOAD0_ICON_Y + 14
    mov ecx, 181
    mov edx, 45
    mov edi, COLOR_TRAFFIC_RED
    call launcher_fill_rect

    mov eax, PAYLOAD0_ICON_X + 22
    mov ebx, PAYLOAD0_ICON_Y + 80
    mov ecx, 195
    mov edx, 130
    mov edi, COLOR_WINDOW_EDGE
    call launcher_fill_rect

    mov eax, PAYLOAD0_ICON_X + 85
    mov ebx, PAYLOAD0_ICON_Y + 101
    mov esi, launcher_payload0_glyph_text
    call launcher_draw_text

.label:
    mov eax, 716
    mov ebx, 1305
    mov esi, launcher_payload0_text
    call launcher_draw_text
    ret

align 16
launcher_draw_payload1_icon:
    mov eax, PAYLOAD1_ICON_X
    mov ebx, PAYLOAD1_ICON_Y
    mov ecx, PAYLOAD_ICON_SIZE
    mov edx, PAYLOAD_ICON_SIZE
    mov edi, COLOR_WINDOW_EDGE
    call launcher_fill_rect

    mov eax, PAYLOAD1_ICON_X + 2
    mov ebx, PAYLOAD1_ICON_Y + 2
    mov ecx, PAYLOAD_ICON_SIZE - 4
    mov edx, PAYLOAD_ICON_SIZE - 4
    mov edi, COLOR_PAYLOAD1_ICON
    call launcher_fill_rect

    test dword [launcher_art_flags], LAUNCHER_ART_PAYLOAD1
    jz .fallback_art
    mov eax, PAYLOAD1_ICON_X
    mov ebx, PAYLOAD1_ICON_Y
    mov esi, launcher_icon1_pixels
    call launcher_draw_icon_pixels
    jmp .label

.fallback_art:
    mov eax, PAYLOAD1_ICON_X + 18
    mov ebx, PAYLOAD1_ICON_Y + 14
    mov ecx, 174
    mov edx, 195
    mov edi, COLOR_DESKTOP_TOP
    call launcher_fill_rect

    mov eax, PAYLOAD1_ICON_X + 90
    mov ebx, PAYLOAD1_ICON_Y + 85
    mov ecx, 70
    mov edx, 94
    mov edi, COLOR_WINDOW_EDGE
    call launcher_fill_rect

    mov eax, PAYLOAD1_ICON_X + 85
    mov ebx, PAYLOAD1_ICON_Y + 101
    mov esi, launcher_payload1_glyph_text
    call launcher_draw_text

.label:
    mov eax, 1520
    mov ebx, 1305
    mov esi, launcher_payload1_text
    call launcher_draw_text
    ret

align 16
launcher_load_art:
    push edi
    xor eax, eax
    mov ecx, PAYLOAD_ICON_PIXELS * 2
    mov edi, launcher_icon0_pixels
    cld
    rep stosb
    mov dword [launcher_art_flags], 0
    call launcher_load_doom_icon
    call launcher_load_quake_icon
    pop edi
    ret

align 16
launcher_load_doom_icon:
    push ebx
    push esi
    push edi
    mov dword [launcher_art_fd], -1

    push 0
    push 0
    push launcher_doom_wad_path
    call vibe_user_open
    add esp, 12
    test eax, eax
    js .done
    mov [launcher_art_fd], eax

    push 12
    push launcher_file_header
    push eax
    call vibe_user_read
    add esp, 12
    cmp eax, 12
    jne .close

    mov al, [launcher_file_header]
    cmp al, 'I'
    je .magic_tail
    cmp al, 'P'
    jne .close
.magic_tail:
    cmp byte [launcher_file_header + 1], 'W'
    jne .close
    cmp byte [launcher_file_header + 2], 'A'
    jne .close
    cmp byte [launcher_file_header + 3], 'D'
    jne .close

    mov eax, [launcher_file_header + 4]
    test eax, eax
    jz .close
    mov [launcher_art_count], eax
    shl eax, 4
    cmp eax, LAUNCHER_ASSET_BYTES
    ja .close
    mov [launcher_art_dir_bytes], eax

    push 0
    push dword [launcher_file_header + 8]
    push dword [launcher_art_fd]
    call vibe_user_lseek
    add esp, 12
    test eax, eax
    js .close

    push dword [launcher_art_dir_bytes]
    push dword [launcher_asset_ptr]
    push dword [launcher_art_fd]
    call vibe_user_read
    add esp, 12
    cmp eax, [launcher_art_dir_bytes]
    jne .close

    mov dword [launcher_doom_titlepic_offset], 0
    mov dword [launcher_doom_titlepic_size], 0
    mov dword [launcher_doom_playpal_offset], 0
    mov dword [launcher_doom_playpal_size], 0
    mov ecx, [launcher_art_count]
    mov edi, [launcher_asset_ptr]
.search:
    test ecx, ecx
    jz .load_found
    cmp byte [edi + 8], 'T'
    jne .maybe_playpal
    cmp byte [edi + 9], 'I'
    jne .maybe_playpal
    cmp byte [edi + 10], 'T'
    jne .maybe_playpal
    cmp byte [edi + 11], 'L'
    jne .maybe_playpal
    cmp byte [edi + 12], 'E'
    jne .maybe_playpal
    cmp byte [edi + 13], 'P'
    jne .maybe_playpal
    cmp byte [edi + 14], 'I'
    jne .maybe_playpal
    cmp byte [edi + 15], 'C'
    jne .maybe_playpal
    mov eax, [edi + 4]
    cmp eax, 8
    jb .next
    cmp eax, LAUNCHER_ASSET_BYTES
    ja .next
    mov [launcher_doom_titlepic_size], eax
    mov eax, [edi]
    mov [launcher_doom_titlepic_offset], eax
    jmp .maybe_done

.maybe_playpal:
    cmp byte [edi + 8], 'P'
    jne .next
    cmp byte [edi + 9], 'L'
    jne .next
    cmp byte [edi + 10], 'A'
    jne .next
    cmp byte [edi + 11], 'Y'
    jne .next
    cmp byte [edi + 12], 'P'
    jne .next
    cmp byte [edi + 13], 'A'
    jne .next
    cmp byte [edi + 14], 'L'
    jne .next
    cmp byte [edi + 15], 0
    jne .next
    mov eax, [edi + 4]
    cmp eax, PALETTE_BYTES
    jb .next
    mov [launcher_doom_playpal_size], eax
    mov eax, [edi]
    mov [launcher_doom_playpal_offset], eax

.maybe_done:
    cmp dword [launcher_doom_titlepic_offset], 0
    je .next
    cmp dword [launcher_doom_playpal_offset], 0
    jne .load_found

.next:
    add edi, WAD_DIR_ENTRY_BYTES
    dec ecx
    jmp .search

.load_found:
    cmp dword [launcher_doom_titlepic_offset], 0
    je .close
    cmp dword [launcher_doom_playpal_offset], 0
    je .close

    push 0
    push dword [launcher_doom_playpal_offset]
    push dword [launcher_art_fd]
    call vibe_user_lseek
    add esp, 12
    test eax, eax
    js .close

    push PALETTE_BYTES
    push launcher_doom_palette
    push dword [launcher_art_fd]
    call vibe_user_read
    add esp, 12
    cmp eax, PALETTE_BYTES
    jne .close

    mov eax, [launcher_doom_titlepic_size]
    mov [launcher_art_size], eax

    push 0
    push dword [launcher_doom_titlepic_offset]
    push dword [launcher_art_fd]
    call vibe_user_lseek
    add esp, 12
    test eax, eax
    js .close

    push dword [launcher_art_size]
    push dword [launcher_asset_ptr]
    push dword [launcher_art_fd]
    call vibe_user_read
    add esp, 12
    cmp eax, [launcher_art_size]
    jne .close

    call launcher_decode_doom_patch_icon
    test eax, eax
    jne .close
    or dword [launcher_art_flags], LAUNCHER_ART_PAYLOAD0
    jmp .close

.close:
    call launcher_close_art_fd
.done:
    pop edi
    pop esi
    pop ebx
    ret

align 16
launcher_decode_doom_patch_icon:
    push ebx
    push esi
    push edi
    mov esi, [launcher_asset_ptr]
    cmp dword [launcher_art_size], 8
    jb .fail
    movzx eax, word [esi + 0]
    test eax, eax
    jz .fail
    cmp eax, 1024
    ja .fail
    mov [launcher_art_width], eax
    movzx eax, word [esi + 2]
    test eax, eax
    jz .fail
    cmp eax, 1024
    ja .fail
    mov [launcher_art_height], eax
    mov eax, [launcher_art_width]
    imul eax, 4
    add eax, 8
    jc .fail
    cmp eax, [launcher_art_size]
    ja .fail
    mov dword [launcher_art_source_x_base], 0
    mov dword [launcher_art_source_y_base], 0
    mov eax, [launcher_art_width]
    mov ebx, [launcher_art_height]
    cmp eax, ebx
    ja .wide_source
    jb .tall_source
    mov [launcher_art_source_span], eax
    jmp .source_ready
.wide_source:
    sub eax, ebx
    shr eax, 1
    mov [launcher_art_source_x_base], eax
    mov [launcher_art_source_span], ebx
    jmp .source_ready
.tall_source:
    sub ebx, eax
    shr ebx, 1
    mov [launcher_art_source_y_base], ebx
    mov [launcher_art_source_span], eax
.source_ready:
    mov dword [launcher_art_dest_y], 0

.dest_y:
    cmp dword [launcher_art_dest_y], PAYLOAD_ICON_SIZE
    jae .ok
    mov eax, [launcher_art_dest_y]
    imul eax, [launcher_art_source_span]
    xor edx, edx
    mov ebx, PAYLOAD_ICON_SIZE
    div ebx
    add eax, [launcher_art_source_y_base]
    mov [launcher_art_source_y], eax
    mov dword [launcher_art_dest_x], 0

.dest_x:
    cmp dword [launcher_art_dest_x], PAYLOAD_ICON_SIZE
    jae .next_dest_y
    mov eax, [launcher_art_dest_x]
    imul eax, [launcher_art_source_span]
    xor edx, edx
    mov ebx, PAYLOAD_ICON_SIZE
    div ebx
    add eax, [launcher_art_source_x_base]
    mov [launcher_art_source_x], eax
    call launcher_doom_patch_sample
    jc .advance_dest_x
    movzx edx, al
    imul edx, 3
    mov al, [launcher_doom_palette + edx + 0]
    mov bl, [launcher_doom_palette + edx + 1]
    mov cl, [launcher_doom_palette + edx + 2]
    call launcher_rgb_to_art_color
    mov edx, [launcher_art_dest_y]
    imul edx, PAYLOAD_ICON_SIZE
    add edx, [launcher_art_dest_x]
    cmp edx, PAYLOAD_ICON_PIXELS
    jae .advance_dest_x
    mov [launcher_icon0_pixels + edx], cl

.advance_dest_x:
    inc dword [launcher_art_dest_x]
    jmp .dest_x

.next_dest_y:
    inc dword [launcher_art_dest_y]
    jmp .dest_y

.ok:
    xor eax, eax
    jmp .done
.fail:
    mov eax, -1
.done:
    pop edi
    pop esi
    pop ebx
    ret

align 16
launcher_doom_patch_sample:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    mov esi, [launcher_asset_ptr]
    mov eax, [launcher_art_source_x]
    cmp eax, [launcher_art_width]
    jae .fail
    mov ebx, eax
    shl ebx, 2
    add ebx, 8
    mov edi, [esi + ebx]
    cmp edi, [launcher_art_size]
    jae .fail
    add edi, esi

.post_loop:
    mov eax, edi
    sub eax, esi
    add eax, 2
    jc .fail
    cmp eax, [launcher_art_size]
    jae .fail
    movzx ebx, byte [edi + 0]
    cmp bl, 0xff
    je .fail
    movzx ecx, byte [edi + 1]
    mov edx, [launcher_art_source_y]
    cmp edx, ebx
    jb .next_post
    mov eax, ebx
    add eax, ecx
    cmp edx, eax
    jae .next_post
    sub edx, ebx
    lea eax, [edi + edx + 3]
    mov ebx, eax
    sub ebx, esi
    cmp ebx, [launcher_art_size]
    jae .fail
    mov al, [eax]
    clc
    jmp .done

.next_post:
    lea edi, [edi + ecx + 4]
    jmp .post_loop

.fail:
    stc

.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

align 16
launcher_load_quake_icon:
    push ebx
    push esi
    push edi
    mov dword [launcher_art_fd], -1

    push 0
    push 0
    push launcher_quake_pak_path
    call vibe_user_open
    add esp, 12
    test eax, eax
    js .done
    mov [launcher_art_fd], eax

    push 12
    push launcher_file_header
    push eax
    call vibe_user_read
    add esp, 12
    cmp eax, 12
    jne .close
    cmp byte [launcher_file_header + 0], 'P'
    jne .close
    cmp byte [launcher_file_header + 1], 'A'
    jne .close
    cmp byte [launcher_file_header + 2], 'C'
    jne .close
    cmp byte [launcher_file_header + 3], 'K'
    jne .close

    mov eax, [launcher_file_header + 8]
    test eax, eax
    jz .close
    cmp eax, LAUNCHER_ASSET_BYTES
    ja .close
    mov [launcher_art_dir_bytes], eax
    xor edx, edx
    mov ebx, PAK_DIR_ENTRY_BYTES
    div ebx
    test eax, eax
    jz .close
    mov [launcher_art_count], eax

    push 0
    push dword [launcher_file_header + 4]
    push dword [launcher_art_fd]
    call vibe_user_lseek
    add esp, 12
    test eax, eax
    js .close

    push dword [launcher_art_dir_bytes]
    push dword [launcher_asset_ptr]
    push dword [launcher_art_fd]
    call vibe_user_read
    add esp, 12
    cmp eax, [launcher_art_dir_bytes]
    jne .close

    mov dword [launcher_quake_conback_offset], 0
    mov dword [launcher_quake_conback_size], 0
    mov dword [launcher_quake_palette_offset], 0
    mov dword [launcher_quake_palette_size], 0
    mov ecx, [launcher_art_count]
    mov edi, [launcher_asset_ptr]
.search:
    test ecx, ecx
    jz .load_found
    cmp byte [edi + 0], 'g'
    jne .next
    cmp byte [edi + 1], 'f'
    jne .next
    cmp byte [edi + 2], 'x'
    jne .next
    cmp byte [edi + 3], '/'
    jne .next
    cmp byte [edi + 4], 'c'
    jne .maybe_palette
    cmp byte [edi + 5], 'o'
    jne .maybe_palette
    cmp byte [edi + 6], 'n'
    jne .maybe_palette
    cmp byte [edi + 7], 'b'
    jne .maybe_palette
    cmp byte [edi + 8], 'a'
    jne .maybe_palette
    cmp byte [edi + 9], 'c'
    jne .maybe_palette
    cmp byte [edi + 10], 'k'
    jne .maybe_palette
    cmp byte [edi + 11], '.'
    jne .maybe_palette
    cmp byte [edi + 12], 'l'
    jne .maybe_palette
    cmp byte [edi + 13], 'm'
    jne .maybe_palette
    cmp byte [edi + 14], 'p'
    jne .maybe_palette
    mov eax, [edi + 60]
    cmp eax, 12
    jb .next
    cmp eax, LAUNCHER_ASSET_BYTES
    ja .next
    mov [launcher_quake_conback_size], eax
    mov eax, [edi + 56]
    mov [launcher_quake_conback_offset], eax
    jmp .maybe_done

.maybe_palette:
    cmp byte [edi + 4], 'p'
    jne .next
    cmp byte [edi + 5], 'a'
    jne .next
    cmp byte [edi + 6], 'l'
    jne .next
    cmp byte [edi + 7], 'e'
    jne .next
    cmp byte [edi + 8], 't'
    jne .next
    cmp byte [edi + 9], 't'
    jne .next
    cmp byte [edi + 10], 'e'
    jne .next
    cmp byte [edi + 11], '.'
    jne .next
    cmp byte [edi + 12], 'l'
    jne .next
    cmp byte [edi + 13], 'm'
    jne .next
    cmp byte [edi + 14], 'p'
    jne .next
    mov eax, [edi + 60]
    cmp eax, PALETTE_BYTES
    jb .next
    mov [launcher_quake_palette_size], eax
    mov eax, [edi + 56]
    mov [launcher_quake_palette_offset], eax

.maybe_done:
    cmp dword [launcher_quake_conback_offset], 0
    je .next
    cmp dword [launcher_quake_palette_offset], 0
    jne .load_found

.next:
    add edi, PAK_DIR_ENTRY_BYTES
    dec ecx
    jmp .search

.load_found:
    cmp dword [launcher_quake_conback_offset], 0
    je .close
    cmp dword [launcher_quake_palette_offset], 0
    je .close

    push 0
    push dword [launcher_quake_palette_offset]
    push dword [launcher_art_fd]
    call vibe_user_lseek
    add esp, 12
    test eax, eax
    js .close

    push PALETTE_BYTES
    push launcher_quake_palette
    push dword [launcher_art_fd]
    call vibe_user_read
    add esp, 12
    cmp eax, PALETTE_BYTES
    jne .close

    mov eax, [launcher_quake_conback_size]
    mov [launcher_art_size], eax

    push 0
    push dword [launcher_quake_conback_offset]
    push dword [launcher_art_fd]
    call vibe_user_lseek
    add esp, 12
    test eax, eax
    js .close

    push dword [launcher_art_size]
    push dword [launcher_asset_ptr]
    push dword [launcher_art_fd]
    call vibe_user_read
    add esp, 12
    cmp eax, [launcher_art_size]
    jne .close

    call launcher_decode_quake_qpic_icon
    test eax, eax
    jne .close
    or dword [launcher_art_flags], LAUNCHER_ART_PAYLOAD1
    jmp .close

.close:
    call launcher_close_art_fd
.done:
    pop edi
    pop esi
    pop ebx
    ret

align 16
launcher_decode_quake_qpic_icon:
    push ebx
    push esi
    push edi
    mov esi, [launcher_asset_ptr]
    cmp dword [launcher_art_size], 12
    jb .fail
    mov eax, [esi + 0]
    test eax, eax
    jz .fail
    cmp eax, 1024
    ja .fail
    mov [launcher_art_width], eax
    mov eax, [esi + 4]
    test eax, eax
    jz .fail
    cmp eax, 1024
    ja .fail
    mov [launcher_art_height], eax
    mov eax, [launcher_art_width]
    mul dword [launcher_art_height]
    add eax, 8
    jc .fail
    cmp eax, [launcher_art_size]
    ja .fail
    mov dword [launcher_art_source_x_base], 0
    mov dword [launcher_art_source_y_base], 0
    mov eax, [launcher_art_width]
    mov ebx, [launcher_art_height]
    cmp eax, ebx
    ja .wide_source
    jb .tall_source
    mov [launcher_art_source_span], eax
    jmp .source_ready
.wide_source:
    sub eax, ebx
    shr eax, 1
    mov [launcher_art_source_x_base], eax
    mov [launcher_art_source_span], ebx
    jmp .source_ready
.tall_source:
    sub ebx, eax
    shr ebx, 1
    mov [launcher_art_source_y_base], ebx
    mov [launcher_art_source_span], eax
.source_ready:

    mov dword [launcher_art_dest_y], 0
.dest_y:
    cmp dword [launcher_art_dest_y], PAYLOAD_ICON_SIZE
    jae .ok
    mov eax, [launcher_art_dest_y]
    imul eax, [launcher_art_source_span]
    xor edx, edx
    mov ebx, PAYLOAD_ICON_SIZE
    div ebx
    add eax, [launcher_art_source_y_base]
    mov [launcher_art_source_y], eax
    mov dword [launcher_art_dest_x], 0
.dest_x:
    cmp dword [launcher_art_dest_x], PAYLOAD_ICON_SIZE
    jae .next_dest_y
    mov eax, [launcher_art_dest_x]
    imul eax, [launcher_art_source_span]
    xor edx, edx
    mov ebx, PAYLOAD_ICON_SIZE
    div ebx
    add eax, [launcher_art_source_x_base]
    mov [launcher_art_source_x], eax
    mov eax, [launcher_art_source_y]
    mul dword [launcher_art_width]
    add eax, [launcher_art_source_x]
    add eax, 8
    cmp eax, [launcher_art_size]
    jae .advance_dest_x
    movzx edx, byte [esi + eax]
    imul edx, 3
    mov al, [launcher_quake_palette + edx + 0]
    mov bl, [launcher_quake_palette + edx + 1]
    mov cl, [launcher_quake_palette + edx + 2]
    call launcher_rgb_to_art_color
    mov edx, [launcher_art_dest_y]
    imul edx, PAYLOAD_ICON_SIZE
    add edx, [launcher_art_dest_x]
    cmp edx, PAYLOAD_ICON_PIXELS
    jae .advance_dest_x
    mov [launcher_icon1_pixels + edx], cl

.advance_dest_x:
    inc dword [launcher_art_dest_x]
    jmp .dest_x

.next_dest_y:
    inc dword [launcher_art_dest_y]
    jmp .dest_y

.ok:
    xor eax, eax
    jmp .done
.fail:
    mov eax, -1
.done:
    pop edi
    pop esi
    pop ebx
    ret

align 16
launcher_rgb_to_art_color:
    push edx
    movzx edx, al
    imul edx, LAUNCHER_ART_PALETTE_LEVELS
    shr edx, 8
    imul edx, 36
    movzx eax, bl
    imul eax, LAUNCHER_ART_PALETTE_LEVELS
    shr eax, 8
    imul eax, 6
    add edx, eax
    movzx eax, cl
    imul eax, LAUNCHER_ART_PALETTE_LEVELS
    shr eax, 8
    add edx, eax
    add edx, LAUNCHER_ART_PALETTE_BASE
    mov cl, dl
    pop edx
    ret

align 16
launcher_close_art_fd:
    cmp dword [launcher_art_fd], 0
    jl .done
    push dword [launcher_art_fd]
    call vibe_user_close
    add esp, 4
    mov dword [launcher_art_fd], -1
.done:
    ret

align 16
launcher_draw_icon_pixels:
    push ebp
    mov ebp, esp
    sub esp, 12
    mov [ebp - 4], eax
    mov [ebp - 8], ebx
    mov [ebp - 12], esi
    push ebx
    push ecx
    push edx
    push esi
    push edi
    xor edi, edi

.y:
    cmp edi, PAYLOAD_ICON_SIZE
    jge .done
    xor edx, edx
.x:
    cmp edx, PAYLOAD_ICON_SIZE
    jge .next_y
    mov esi, [ebp - 12]
    mov eax, edi
    imul eax, PAYLOAD_ICON_SIZE
    add eax, edx
    mov cl, [esi + eax]
    test cl, cl
    jz .skip
    mov eax, [ebp - 4]
    add eax, edx
    mov ebx, [ebp - 8]
    add ebx, edi
    push edx
    push edi
    call launcher_plot_pixel_clipped
    pop edi
    pop edx
.skip:
    inc edx
    jmp .x

.next_y:
    inc edi
    jmp .y

.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    mov esp, ebp
    pop ebp
    ret

align 16
launcher_present:
    mov eax, [launcher_frame_ptr]
    mov dword [launcher_present_desc + 0], eax
    mov eax, [launcher_palette_ptr]
    mov dword [launcher_present_desc + 4], eax
    mov dword [launcher_present_desc + 8], SCREEN_W
    mov dword [launcher_present_desc + 12], SCREEN_H
    push launcher_present_desc
    call vibe_user_present_indexed_checked
    add esp, 4
    ret

align 16
launcher_drain_input:
    push launcher_input_event
    call vibe_user_poll_input
    add esp, 4
    cmp eax, 1
    jne .done
    call launcher_handle_event
    jmp launcher_drain_input
.done:
    ret

align 16
launcher_handle_event:
    cmp dword [launcher_input_event + INPUT_EVENT_DEVICE_ID], INPUT_DEVICE_KEYBOARD
    je launcher_handle_key
    cmp dword [launcher_input_event + INPUT_EVENT_DEVICE_ID], INPUT_DEVICE_MOUSE
    je launcher_handle_mouse
    ret

align 16
launcher_handle_key:
    cmp dword [launcher_input_event + INPUT_EVENT_TYPE], INPUT_EVENT_KEY
    jne .done
    cmp dword [launcher_input_event + INPUT_EVENT_VALUE0], INPUT_KEY_PRESSED
    jne .done

    mov eax, [launcher_input_event + INPUT_EVENT_CODE]
    and eax, 0x7f
    cmp eax, SCANCODE_1
    je .select_doom
    cmp eax, SCANCODE_2
    je .select_quake
    cmp eax, SCANCODE_ENTER
    je .select_focus
    cmp eax, SCANCODE_W
    je .focus_doom
    cmp eax, SCANCODE_UP
    je .focus_doom
    cmp eax, SCANCODE_S
    je .focus_quake
    cmp eax, SCANCODE_DOWN
    je .focus_quake
    ret

.focus_doom:
    mov dword [launcher_focus], 1
    ret

.focus_quake:
    mov dword [launcher_focus], 2
    ret

.select_focus:
    mov eax, [launcher_focus]
    mov [launcher_selected], eax
    ret

.select_doom:
    mov dword [launcher_focus], 1
    mov dword [launcher_selected], 1
    ret

.select_quake:
    mov dword [launcher_focus], 2
    mov dword [launcher_selected], 2
.done:
    ret

align 16
launcher_handle_mouse:
    cmp dword [launcher_input_event + INPUT_EVENT_TYPE], INPUT_EVENT_MOUSE_PACKET
    jne .done

    mov eax, [launcher_cursor_x]
    add eax, [launcher_input_event + INPUT_EVENT_VALUE0]
    call launcher_clip_x
    mov [launcher_cursor_x], eax

    mov eax, [launcher_cursor_y]
    sub eax, [launcher_input_event + INPUT_EVENT_VALUE1]
    call launcher_clip_y
    mov [launcher_cursor_y], eax

    mov eax, [launcher_cursor_x]
    mov ebx, [launcher_cursor_y]
    call launcher_pointer_focus
    test eax, eax
    je .button
    mov [launcher_focus], eax

.button:
    mov eax, [launcher_input_event + INPUT_EVENT_CODE]
    test eax, INPUT_MOUSE_BUTTON_LEFT
    je .done
    mov eax, [launcher_cursor_x]
    mov ebx, [launcher_cursor_y]
    call launcher_pointer_focus
    test eax, eax
    je .done
    mov [launcher_focus], eax
    mov [launcher_selected], eax
.done:
    ret

align 16
launcher_pointer_focus:
    cmp eax, PAYLOAD0_HIT_X
    jl .check_payload1
    cmp eax, PAYLOAD0_HIT_X + PAYLOAD_HIT_W - 1
    jg .check_payload1
    cmp ebx, PAYLOAD0_HIT_Y
    jl .check_payload1
    cmp ebx, PAYLOAD0_HIT_Y + PAYLOAD_HIT_H - 1
    jg .check_payload1
    mov eax, 1
    ret

.check_payload1:
    cmp eax, PAYLOAD1_HIT_X
    jl .none
    cmp eax, PAYLOAD1_HIT_X + PAYLOAD_HIT_W - 1
    jg .none
    cmp ebx, PAYLOAD1_HIT_Y
    jl .none
    cmp ebx, PAYLOAD1_HIT_Y + PAYLOAD_HIT_H - 1
    jg .none
    mov eax, 2
    ret

.none:
    xor eax, eax
    ret

align 16
launcher_clip_x:
    cmp eax, 0
    jge .nonnegative
    xor eax, eax
.nonnegative:
    cmp eax, SCREEN_W - 1
    jle .done
    mov eax, SCREEN_W - 1
.done:
    ret

align 16
launcher_clip_y:
    cmp eax, 0
    jge .nonnegative
    xor eax, eax
.nonnegative:
    cmp eax, SCREEN_H - 1
    jle .done
    mov eax, SCREEN_H - 1
.done:
    ret

align 16
launcher_fill_rect:
    push ebp
    mov ebp, esp
    push esi
    push edi
    sub esp, 20
    mov [ebp - 4], eax
    mov [ebp - 8], ebx
    mov [ebp - 12], ecx
    mov [ebp - 16], edx
    mov [ebp - 20], edi

.row:
    cmp dword [ebp - 16], 0
    jle .done
    mov eax, [ebp - 8]
    imul eax, SCREEN_W
    add eax, [ebp - 4]
    mov edi, [launcher_frame_ptr]
    add edi, eax
    mov ecx, [ebp - 12]
    mov eax, [ebp - 20]
    cld
    rep stosb
    inc dword [ebp - 8]
    dec dword [ebp - 16]
    jmp .row

.done:
    add esp, 20
    pop edi
    pop esi
    pop ebp
    ret

align 16
launcher_draw_text:
    push ebx
    push esi
    push edi
    mov [launcher_text_x], eax
    mov [launcher_text_y], ebx

.next:
    lodsb
    test al, al
    je .done
    cmp al, ' '
    jne .glyph
    add dword [launcher_text_x], FONT_ADVANCE
    jmp .next

.glyph:
    push esi
    call launcher_glyph_for_ascii
    test esi, esi
    je .skip_glyph
    call launcher_draw_glyph
.skip_glyph:
    pop esi
    add dword [launcher_text_x], FONT_ADVANCE
    jmp .next

.done:
    pop edi
    pop esi
    pop ebx
    ret

align 16
launcher_glyph_for_ascii:
    cmp al, 'A'
    jb .digit
    cmp al, 'Z'
    ja .digit
    sub al, 'A'
    movzx eax, al
    imul eax, 7
    lea esi, [font_upper + eax]
    ret

.digit:
    cmp al, '0'
    jb .missing
    cmp al, '9'
    ja .missing
    sub al, '0'
    movzx eax, al
    imul eax, 7
    lea esi, [font_digits + eax]
    ret

.missing:
    xor esi, esi
    ret

align 16
launcher_draw_glyph:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    xor edi, edi

.row_loop:
    cmp edi, 7
    jge .done
    movzx edx, byte [esi + edi]
    xor ecx, ecx

.col_loop:
    cmp ecx, 5
    jge .next_row
    mov eax, 0x10
    shr eax, cl
    test edx, eax
    je .skip_pixel
    mov eax, ecx
    imul eax, FONT_PIXEL_SIZE
    add eax, [launcher_text_x]
    mov ebx, edi
    imul ebx, FONT_PIXEL_SIZE
    add ebx, [launcher_text_y]
    push esi
    push ecx
    mov cl, COLOR_TEXT
    call launcher_plot_2x2
    pop ecx
    pop esi
.skip_pixel:
    inc ecx
    jmp .col_loop

.next_row:
    inc edi
    jmp .row_loop

.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

align 16
launcher_plot_2x2:
    push eax
    push ebx
    push ecx
    push edx
    push edi
    movzx edi, cl
    mov ecx, FONT_PIXEL_SIZE
    mov edx, FONT_PIXEL_SIZE
    call launcher_fill_rect
    pop edi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

align 16
launcher_draw_cursor:
    push ebx
    push ecx
    push edx
    mov dword [launcher_cursor_scratch], -26

.horizontal:
    mov edx, [launcher_cursor_scratch]
    cmp edx, 27
    jge .vertical_start
    mov eax, [launcher_cursor_x]
    add eax, edx
    mov ebx, [launcher_cursor_y]
    mov cl, COLOR_TEXT
    call launcher_plot_cursor_pixel
    inc dword [launcher_cursor_scratch]
    jmp .horizontal

.vertical_start:
    mov dword [launcher_cursor_scratch], -26

.vertical:
    mov ecx, [launcher_cursor_scratch]
    cmp ecx, 27
    jge .done
    mov eax, [launcher_cursor_x]
    mov ebx, [launcher_cursor_y]
    add ebx, ecx
    mov cl, COLOR_TEXT
    call launcher_plot_cursor_pixel
    inc dword [launcher_cursor_scratch]
    jmp .vertical

.done:
    pop edx
    pop ecx
    pop ebx
    ret

align 16
launcher_plot_cursor_pixel:
    push eax
    push ebx
    push ecx
    push edx
    push edi
    movzx edi, cl
    mov ecx, 6
    mov edx, 6
    call launcher_fill_rect
    pop edi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

align 16
launcher_plot_pixel_clipped:
    cmp eax, 0
    jl .done
    cmp eax, SCREEN_W
    jge .done
    cmp ebx, 0
    jl .done
    cmp ebx, SCREEN_H
    jge .done
    push edx
    mov edx, ebx
    imul edx, SCREEN_W
    add edx, eax
    push edi
    mov edi, [launcher_frame_ptr]
    mov [edi + edx], cl
    pop edi
    pop edx
.done:
    ret

section .rodata
payload0_path db `PAYLOAD0.ELF`, 0
payload1_path db `PAYLOAD1.ELF`, 0
launcher_ready_text db `launcher ready\n`, 0
launcher_doom_wad_path db `DOOM1.WAD`, 0
launcher_quake_pak_path db `/ID1/PAK0.PAK`, 0
launcher_title_text db `VIBE OS`, 0
launcher_menu_right_text db `RING 3`, 0
launcher_window_title_text db `PAYLOADS`, 0
launcher_desktop_text db `VIBE DESKTOP`, 0
launcher_payload0_text db `DOOM`, 0
launcher_payload1_text db `QUAKE`, 0
launcher_payload0_glyph_text db `D`, 0
launcher_payload1_glyph_text db `Q`, 0

font_upper:
db 0x0e,0x11,0x11,0x1f,0x11,0x11,0x11
db 0x1e,0x11,0x11,0x1e,0x11,0x11,0x1e
db 0x0e,0x11,0x10,0x10,0x10,0x11,0x0e
db 0x1e,0x11,0x11,0x11,0x11,0x11,0x1e
db 0x1f,0x10,0x10,0x1e,0x10,0x10,0x1f
db 0x1f,0x10,0x10,0x1e,0x10,0x10,0x10
db 0x0e,0x11,0x10,0x13,0x11,0x11,0x0f
db 0x11,0x11,0x11,0x1f,0x11,0x11,0x11
db 0x0e,0x04,0x04,0x04,0x04,0x04,0x0e
db 0x01,0x01,0x01,0x01,0x11,0x11,0x0e
db 0x11,0x12,0x14,0x18,0x14,0x12,0x11
db 0x10,0x10,0x10,0x10,0x10,0x10,0x1f
db 0x11,0x1b,0x15,0x15,0x11,0x11,0x11
db 0x11,0x19,0x15,0x13,0x11,0x11,0x11
db 0x0e,0x11,0x11,0x11,0x11,0x11,0x0e
db 0x1e,0x11,0x11,0x1e,0x10,0x10,0x10
db 0x0e,0x11,0x11,0x11,0x15,0x12,0x0d
db 0x1e,0x11,0x11,0x1e,0x14,0x12,0x11
db 0x0f,0x10,0x10,0x0e,0x01,0x01,0x1e
db 0x1f,0x04,0x04,0x04,0x04,0x04,0x04
db 0x11,0x11,0x11,0x11,0x11,0x11,0x0e
db 0x11,0x11,0x11,0x11,0x11,0x0a,0x04
db 0x11,0x11,0x11,0x15,0x15,0x15,0x0a
db 0x11,0x11,0x0a,0x04,0x0a,0x11,0x11
db 0x11,0x11,0x0a,0x04,0x04,0x04,0x04
db 0x1f,0x01,0x02,0x04,0x08,0x10,0x1f

font_digits:
db 0x0e,0x11,0x13,0x15,0x19,0x11,0x0e
db 0x04,0x0c,0x04,0x04,0x04,0x04,0x0e
db 0x0e,0x11,0x01,0x02,0x04,0x08,0x1f
db 0x1e,0x01,0x01,0x0e,0x01,0x01,0x1e
db 0x02,0x06,0x0a,0x12,0x1f,0x02,0x02
db 0x1f,0x10,0x10,0x1e,0x01,0x01,0x1e
db 0x0e,0x10,0x10,0x1e,0x11,0x11,0x0e
db 0x1f,0x01,0x02,0x04,0x08,0x08,0x08
db 0x0e,0x11,0x11,0x0e,0x11,0x11,0x0e
db 0x0e,0x11,0x11,0x0f,0x01,0x01,0x0e

section .data
launcher_present_desc dd 0, 0, SCREEN_W, SCREEN_H
launcher_frame_ptr dd 0
launcher_palette_ptr dd 0
launcher_asset_ptr dd 0
launcher_alloc_base dd 0
launcher_selected dd 0
launcher_focus dd 1
launcher_cursor_x dd 160
launcher_cursor_y dd 104
launcher_text_x dd 0
launcher_text_y dd 0
launcher_cursor_scratch dd 0
launcher_art_flags dd 0
launcher_art_fd dd -1
launcher_art_count dd 0
launcher_art_dir_bytes dd 0
launcher_art_size dd 0
launcher_art_width dd 0
launcher_art_height dd 0
launcher_art_dest_x dd 0
launcher_art_dest_y dd 0
launcher_art_source_x dd 0
launcher_art_source_y dd 0
launcher_art_source_x_base dd 0
launcher_art_source_y_base dd 0
launcher_art_source_span dd 0
launcher_art_post_offset dd 0
launcher_art_top dd 0
launcher_art_row dd 0
launcher_art_row_count dd 0
launcher_doom_titlepic_offset dd 0
launcher_doom_titlepic_size dd 0
launcher_doom_playpal_offset dd 0
launcher_doom_playpal_size dd 0
launcher_quake_conback_offset dd 0
launcher_quake_conback_size dd 0
launcher_quake_palette_offset dd 0
launcher_quake_palette_size dd 0

section .bss
align 16
launcher_file_header resb 16
launcher_doom_palette resb PALETTE_BYTES
launcher_quake_palette resb PALETTE_BYTES
launcher_icon0_pixels resb PAYLOAD_ICON_PIXELS
launcher_icon1_pixels resb PAYLOAD_ICON_PIXELS
launcher_input_event resb INPUT_EVENT_BYTES
