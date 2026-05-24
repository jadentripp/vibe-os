BITS 32

%define VIBE_DOOM_INPUT_NONE 0
%define VIBE_DOOM_INPUT_KEYDOWN 1
%define VIBE_DOOM_INPUT_KEYUP 2
%define VIBE_DOOM_INPUT_MOUSE 3
%define VIBE_DOOM_MOUSE_RELATIVE_SCALE 4

%define VIBE_DOOM_KEY_RIGHTARROW 0xAE
%define VIBE_DOOM_KEY_LEFTARROW 0xAC
%define VIBE_DOOM_KEY_UPARROW 0xAD
%define VIBE_DOOM_KEY_DOWNARROW 0xAF
%define VIBE_DOOM_KEY_ESCAPE 27
%define VIBE_DOOM_KEY_ENTER 13
%define VIBE_DOOM_KEY_TAB 9
%define VIBE_DOOM_KEY_F1 0xBB
%define VIBE_DOOM_KEY_F2 0xBC
%define VIBE_DOOM_KEY_F3 0xBD
%define VIBE_DOOM_KEY_F4 0xBE
%define VIBE_DOOM_KEY_F5 0xBF
%define VIBE_DOOM_KEY_F6 0xC0
%define VIBE_DOOM_KEY_F7 0xC1
%define VIBE_DOOM_KEY_F8 0xC2
%define VIBE_DOOM_KEY_F9 0xC3
%define VIBE_DOOM_KEY_F10 0xC4
%define VIBE_DOOM_KEY_F11 0xD7
%define VIBE_DOOM_KEY_F12 0xD8
%define VIBE_DOOM_KEY_BACKSPACE 127
%define VIBE_DOOM_KEY_EQUALS 0x3D
%define VIBE_DOOM_KEY_MINUS 0x2D
%define VIBE_DOOM_KEY_RSHIFT 0xB6
%define VIBE_DOOM_KEY_RCTRL 0x9D
%define VIBE_DOOM_KEY_RALT 0xB8

%define VIBE_KEY_EVENT_DOWN 0x00000100
%define VIBE_KEY_EVENT_VALID 0x00010000
%define VIBE_MOUSE_EVENT_VALID 0x01000000

%define VIBE_INPUT_DEVICE_KEYBOARD 1
%define VIBE_INPUT_DEVICE_MOUSE 2
%define VIBE_INPUT_EVENT_KEY 1
%define VIBE_INPUT_EVENT_MOUSE_PACKET 2
%define VIBE_INPUT_KEY_PRESSED 1
%define VIBE_INPUT_KEY_RELEASED 0
%define VIBE_INPUT_KEY_PS2_SET1_SCANCODE_MASK 0x7F
%define VIBE_INPUT_KEY_PS2_SET1_EXTENDED 0x80
%define VIBE_INPUT_MOUSE_BUTTON_MASK 0x07

%define VIBE_INPUT_EVENT_DEVICE_ID 4
%define VIBE_INPUT_EVENT_TYPE 8
%define VIBE_INPUT_EVENT_CODE 12
%define VIBE_INPUT_EVENT_VALUE0 16
%define VIBE_INPUT_EVENT_VALUE1 20

%define DOOM_EVENT_TYPE 0
%define DOOM_EVENT_DATA1 4
%define DOOM_EVENT_DATA2 8
%define DOOM_EVENT_DATA3 12

%define MOUSE_DELTA_MAX 0x1FFFFFFF
%define MOUSE_DELTA_MIN 0xE0000000

section .text

global vibe_doom_translate_input_event
global vibe_doom_translate_key_event
global vibe_doom_translate_mouse_event

vibe_doom_translate_input_event:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi

    mov esi, [ebp + 8]
    mov edi, [ebp + 12]
    test edi, edi
    jz .return_zero

    call clear_doom_input_event

    test esi, esi
    jz .return_zero

    cmp dword [esi + VIBE_INPUT_EVENT_DEVICE_ID], VIBE_INPUT_DEVICE_KEYBOARD
    jne .check_mouse
    cmp dword [esi + VIBE_INPUT_EVENT_TYPE], VIBE_INPUT_EVENT_KEY
    jne .check_mouse

    mov ebx, [esi + VIBE_INPUT_EVENT_VALUE0]
    cmp ebx, VIBE_INPUT_KEY_PRESSED
    je .translate_key
    cmp ebx, VIBE_INPUT_KEY_RELEASED
    jne .return_zero

.translate_key:
    mov eax, [esi + VIBE_INPUT_EVENT_CODE]
    call doom_key_from_ps2_set1_code
    test eax, eax
    jz .return_zero

    mov dword [edi + DOOM_EVENT_TYPE], VIBE_DOOM_INPUT_KEYUP
    test ebx, ebx
    jz .store_key
    mov dword [edi + DOOM_EVENT_TYPE], VIBE_DOOM_INPUT_KEYDOWN
.store_key:
    mov [edi + DOOM_EVENT_DATA1], eax
    mov eax, 1
    jmp .done

.check_mouse:
    cmp dword [esi + VIBE_INPUT_EVENT_DEVICE_ID], VIBE_INPUT_DEVICE_MOUSE
    jne .return_zero
    cmp dword [esi + VIBE_INPUT_EVENT_TYPE], VIBE_INPUT_EVENT_MOUSE_PACKET
    jne .return_zero

    mov eax, [esi + VIBE_INPUT_EVENT_CODE]
    mov ebx, [esi + VIBE_INPUT_EVENT_VALUE0]
    mov ecx, [esi + VIBE_INPUT_EVENT_VALUE1]
    call fill_mouse_event
    mov eax, 1
    jmp .done

.return_zero:
    xor eax, eax
.done:
    pop edi
    pop esi
    pop ebx
    leave
    ret

vibe_doom_translate_key_event:
    push ebp
    mov ebp, esp
    push ebx
    push edi

    mov eax, [ebp + 8]
    mov edi, [ebp + 12]
    test edi, edi
    jz .return_zero

    call clear_doom_input_event

    test eax, VIBE_KEY_EVENT_VALID
    jz .return_zero

    mov ebx, eax
    and eax, 0xFF
    test eax, eax
    jz .return_zero

    mov dword [edi + DOOM_EVENT_TYPE], VIBE_DOOM_INPUT_KEYUP
    test ebx, VIBE_KEY_EVENT_DOWN
    jz .store_key
    mov dword [edi + DOOM_EVENT_TYPE], VIBE_DOOM_INPUT_KEYDOWN
.store_key:
    mov [edi + DOOM_EVENT_DATA1], eax
    mov eax, 1
    jmp .done

.return_zero:
    xor eax, eax
.done:
    pop edi
    pop ebx
    leave
    ret

vibe_doom_translate_mouse_event:
    push ebp
    mov ebp, esp
    push ebx
    push edi

    mov edx, [ebp + 8]
    mov edi, [ebp + 12]
    test edi, edi
    jz .return_zero

    call clear_doom_input_event

    test edx, VIBE_MOUSE_EVENT_VALID
    jz .return_zero

    mov eax, edx
    and eax, VIBE_INPUT_MOUSE_BUTTON_MASK

    mov ebx, edx
    shr ebx, 8
    movsx ebx, bl

    mov ecx, edx
    shr ecx, 16
    movsx ecx, cl

    call fill_mouse_event
    mov eax, 1
    jmp .done

.return_zero:
    xor eax, eax
.done:
    pop edi
    pop ebx
    leave
    ret

clear_doom_input_event:
    mov dword [edi + DOOM_EVENT_TYPE], VIBE_DOOM_INPUT_NONE
    mov dword [edi + DOOM_EVENT_DATA1], 0
    mov dword [edi + DOOM_EVENT_DATA2], 0
    mov dword [edi + DOOM_EVENT_DATA3], 0
    ret

doom_key_from_ps2_set1_code:
    mov edx, eax
    and edx, VIBE_INPUT_KEY_PS2_SET1_SCANCODE_MASK
    test eax, VIBE_INPUT_KEY_PS2_SET1_EXTENDED
    jnz .extended

    movzx eax, byte [normal_key_map + edx]
    ret

.extended:
    cmp edx, 0x48
    je .up
    cmp edx, 0x50
    je .down
    cmp edx, 0x4B
    je .left
    cmp edx, 0x4D
    je .right
    cmp edx, 0x1C
    je .enter
    cmp edx, 0x1D
    je .ctrl
    cmp edx, 0x38
    je .alt
    cmp edx, 0x53
    je .backspace
    xor eax, eax
    ret
.up:
    mov eax, VIBE_DOOM_KEY_UPARROW
    ret
.down:
    mov eax, VIBE_DOOM_KEY_DOWNARROW
    ret
.left:
    mov eax, VIBE_DOOM_KEY_LEFTARROW
    ret
.right:
    mov eax, VIBE_DOOM_KEY_RIGHTARROW
    ret
.enter:
    mov eax, VIBE_DOOM_KEY_ENTER
    ret
.ctrl:
    mov eax, VIBE_DOOM_KEY_RCTRL
    ret
.alt:
    mov eax, VIBE_DOOM_KEY_RALT
    ret
.backspace:
    mov eax, VIBE_DOOM_KEY_BACKSPACE
    ret

fill_mouse_event:
    mov dword [edi + DOOM_EVENT_TYPE], VIBE_DOOM_INPUT_MOUSE

    and eax, VIBE_INPUT_MOUSE_BUTTON_MASK
    xor edx, edx
    test eax, 0x01
    jz .no_left
    or edx, 0x01
.no_left:
    test eax, 0x04
    jz .no_middle
    or edx, 0x02
.no_middle:
    test eax, 0x02
    jz .no_right
    or edx, 0x04
.no_right:
    mov [edi + DOOM_EVENT_DATA1], edx

    mov eax, ebx
    call scale_doom_mouse_delta
    mov [edi + DOOM_EVENT_DATA2], eax

    mov eax, ecx
    call scale_doom_mouse_delta
    mov [edi + DOOM_EVENT_DATA3], eax
    ret

scale_doom_mouse_delta:
    cmp eax, MOUSE_DELTA_MAX
    jg .too_high
    cmp eax, MOUSE_DELTA_MIN
    jl .too_low
    shl eax, 2
    ret
.too_high:
    mov eax, 0x7FFFFFFF
    ret
.too_low:
    mov eax, 0x80000000
    ret

section .rodata

normal_key_map:
    db 0
    db VIBE_DOOM_KEY_ESCAPE
    db '1', '2', '3', '4', '5', '6', '7', '8', '9', '0'
    db VIBE_DOOM_KEY_MINUS
    db VIBE_DOOM_KEY_EQUALS
    db VIBE_DOOM_KEY_BACKSPACE
    db VIBE_DOOM_KEY_TAB
    db 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'
    db '[', ']'
    db VIBE_DOOM_KEY_ENTER
    db VIBE_DOOM_KEY_RCTRL
    db 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'
    db ';', 39, '`'
    db VIBE_DOOM_KEY_RSHIFT
    db 92
    db 'z', 'x', 'c', 'v', 'b', 'n', 'm'
    db ',', '.', '/'
    db VIBE_DOOM_KEY_RSHIFT
    db 0
    db VIBE_DOOM_KEY_RALT
    db ' '
    db 0
    db VIBE_DOOM_KEY_F1
    db VIBE_DOOM_KEY_F2
    db VIBE_DOOM_KEY_F3
    db VIBE_DOOM_KEY_F4
    db VIBE_DOOM_KEY_F5
    db VIBE_DOOM_KEY_F6
    db VIBE_DOOM_KEY_F7
    db VIBE_DOOM_KEY_F8
    db VIBE_DOOM_KEY_F9
    db VIBE_DOOM_KEY_F10
    db 0, 0, 0
    db VIBE_DOOM_KEY_UPARROW
    db 0
    db VIBE_DOOM_KEY_MINUS
    db VIBE_DOOM_KEY_LEFTARROW
    db 0
    db VIBE_DOOM_KEY_RIGHTARROW
    db VIBE_DOOM_KEY_EQUALS
    db 0
    db VIBE_DOOM_KEY_DOWNARROW
    db 0, 0
    db VIBE_DOOM_KEY_BACKSPACE
    times 3 db 0
    db VIBE_DOOM_KEY_F11
    db VIBE_DOOM_KEY_F12
    times 39 db 0
