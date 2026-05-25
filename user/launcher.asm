BITS 32

%define SCREEN_W 320
%define SCREEN_H 200
%define FRAME_BYTES 64000
%define PALETTE_BYTES 768

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

%define COLOR_BG 1
%define COLOR_PANEL 2
%define COLOR_SELECTED 3
%define COLOR_BUTTON 4
%define COLOR_TEXT 15

%define DOOM_X 48
%define DOOM_Y 72
%define QUAKE_X 48
%define QUAKE_Y 125
%define BUTTON_W 224
%define BUTTON_H 42

extern vibe_user_present_indexed_checked
extern vibe_user_poll_input
extern vibe_user_sleep_ticks
extern vibe_user_write_all
extern vibe_user_sbrk

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
    mov dword [launcher_selected], 0
    mov dword [launcher_focus], 1
    mov dword [launcher_cursor_x], 160
    mov dword [launcher_cursor_y], 104

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
    push edi
    xor eax, eax
    mov ecx, PALETTE_BYTES
    mov edi, [launcher_palette_ptr]
    rep stosb

    mov edi, [launcher_palette_ptr]
    mov byte [edi + COLOR_BG * 3 + 0], 8
    mov byte [edi + COLOR_BG * 3 + 1], 12
    mov byte [edi + COLOR_BG * 3 + 2], 18

    mov byte [edi + COLOR_PANEL * 3 + 0], 20
    mov byte [edi + COLOR_PANEL * 3 + 1], 28
    mov byte [edi + COLOR_PANEL * 3 + 2], 38

    mov byte [edi + COLOR_SELECTED * 3 + 0], 45
    mov byte [edi + COLOR_SELECTED * 3 + 1], 102
    mov byte [edi + COLOR_SELECTED * 3 + 2], 163

    mov byte [edi + COLOR_BUTTON * 3 + 0], 32
    mov byte [edi + COLOR_BUTTON * 3 + 1], 42
    mov byte [edi + COLOR_BUTTON * 3 + 2], 54

    mov byte [edi + COLOR_TEXT * 3 + 0], 238
    mov byte [edi + COLOR_TEXT * 3 + 1], 242
    mov byte [edi + COLOR_TEXT * 3 + 2], 255

    pop edi
    ret

align 16
launcher_ensure_buffers:
    cmp dword [launcher_frame_ptr], 0
    jne .ready

    push launcher_alloc_base
    push FRAME_BYTES + PALETTE_BYTES
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
    mov edx, SCREEN_H
    mov edi, COLOR_BG
    call launcher_fill_rect

    mov eax, 18
    mov ebx, 12
    mov ecx, 284
    mov edx, 176
    mov edi, COLOR_PANEL
    call launcher_fill_rect

    mov eax, 88
    mov ebx, 24
    mov esi, launcher_title_text
    call launcher_draw_text

    mov eax, 62
    mov ebx, 48
    mov esi, launcher_subtitle_text
    call launcher_draw_text

    mov eax, DOOM_X
    mov ebx, DOOM_Y
    mov ecx, BUTTON_W
    mov edx, BUTTON_H
    mov edi, COLOR_BUTTON
    cmp dword [launcher_focus], 1
    jne .doom_not_focused
    mov edi, COLOR_SELECTED
.doom_not_focused:
    call launcher_fill_rect

    mov eax, QUAKE_X
    mov ebx, QUAKE_Y
    mov ecx, BUTTON_W
    mov edx, BUTTON_H
    mov edi, COLOR_BUTTON
    cmp dword [launcher_focus], 2
    jne .quake_not_focused
    mov edi, COLOR_SELECTED
.quake_not_focused:
    call launcher_fill_rect

    mov eax, 113
    mov ebx, 87
    mov esi, launcher_doom_text
    call launcher_draw_text

    mov eax, 104
    mov ebx, 140
    mov esi, launcher_quake_text
    call launcher_draw_text

    call launcher_draw_cursor
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
    add eax, [launcher_input_event + INPUT_EVENT_VALUE1]
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
    cmp eax, DOOM_X
    jl .check_quake
    cmp eax, DOOM_X + BUTTON_W - 1
    jg .check_quake
    cmp ebx, DOOM_Y
    jl .check_quake
    cmp ebx, DOOM_Y + BUTTON_H - 1
    jg .check_quake
    mov eax, 1
    ret

.check_quake:
    cmp eax, QUAKE_X
    jl .none
    cmp eax, QUAKE_X + BUTTON_W - 1
    jg .none
    cmp ebx, QUAKE_Y
    jl .none
    cmp ebx, QUAKE_Y + BUTTON_H - 1
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
    add dword [launcher_text_x], 12
    jmp .next

.glyph:
    push esi
    call launcher_glyph_for_ascii
    test esi, esi
    je .skip_glyph
    call launcher_draw_glyph
.skip_glyph:
    pop esi
    add dword [launcher_text_x], 12
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
    mov eax, [launcher_text_x]
    lea eax, [eax + ecx * 2]
    mov ebx, [launcher_text_y]
    lea ebx, [ebx + edi * 2]
    push ecx
    mov cl, COLOR_TEXT
    call launcher_plot_2x2
    pop ecx
.skip_pixel:
    inc ecx
    jmp .col_loop

.next_row:
    inc edi
    jmp .row_loop

.done:
    pop edi
    pop edx
    pop ecx
    pop ebx
    ret

align 16
launcher_plot_2x2:
    push eax
    push ebx
    call launcher_plot_pixel_clipped
    pop ebx
    pop eax
    inc eax
    push eax
    push ebx
    call launcher_plot_pixel_clipped
    pop ebx
    pop eax
    inc ebx
    push eax
    push ebx
    call launcher_plot_pixel_clipped
    pop ebx
    pop eax
    inc eax
    call launcher_plot_pixel_clipped
    ret

align 16
launcher_draw_cursor:
    push ebx
    push ecx
    push edx
    mov dword [launcher_cursor_scratch], -4

.horizontal:
    mov edx, [launcher_cursor_scratch]
    cmp edx, 5
    jge .vertical_start
    mov eax, [launcher_cursor_x]
    add eax, edx
    mov ebx, [launcher_cursor_y]
    mov cl, COLOR_TEXT
    call launcher_plot_pixel_clipped
    inc dword [launcher_cursor_scratch]
    jmp .horizontal

.vertical_start:
    mov dword [launcher_cursor_scratch], -4

.vertical:
    mov ecx, [launcher_cursor_scratch]
    cmp ecx, 5
    jge .done
    mov eax, [launcher_cursor_x]
    mov ebx, [launcher_cursor_y]
    add ebx, ecx
    mov cl, COLOR_TEXT
    call launcher_plot_pixel_clipped
    inc dword [launcher_cursor_scratch]
    jmp .vertical

.done:
    pop edx
    pop ecx
    pop ebx
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
launcher_title_text db `VIBE OS`, 0
launcher_subtitle_text db `SELECT PAYLOAD`, 0
launcher_doom_text db `1 DOOM`, 0
launcher_quake_text db `2 QUAKE`, 0

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
launcher_alloc_base dd 0
launcher_selected dd 0
launcher_focus dd 1
launcher_cursor_x dd 160
launcher_cursor_y dd 104
launcher_text_x dd 0
launcher_text_y dd 0
launcher_cursor_scratch dd 0

section .bss
align 16
launcher_input_event resb INPUT_EVENT_BYTES
