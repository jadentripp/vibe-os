BITS 32

%define SYS_GAMEPLAY_STATUS 15
%define QUAKE_STATUS_INIT 0x51000000
%define QUAKE_INIT_INPUT 0x00000008
%define QUAKE_STATUS_INPUT 0x53000000

%define VIBE_INPUT_DEVICE_KEYBOARD 1
%define VIBE_INPUT_DEVICE_MOUSE 2
%define VIBE_INPUT_EVENT_KEY 1
%define VIBE_INPUT_EVENT_MOUSE_PACKET 2
%define VIBE_INPUT_KEY_PRESSED 1
%define VIBE_INPUT_KEY_PS2_SET1_SCANCODE_MASK 0x7f
%define VIBE_INPUT_KEY_PS2_SET1_EXTENDED 0x80
%define VIBE_INPUT_MOUSE_BUTTON_MASK 0x07

%define K_ESCAPE 27
%define K_ENTER 13
%define K_TAB 9
%define K_SPACE 32
%define K_BACKSPACE 127
%define K_UPARROW 128
%define K_DOWNARROW 129
%define K_LEFTARROW 130
%define K_RIGHTARROW 131
%define K_ALT 132
%define K_CTRL 133
%define K_SHIFT 134
%define K_F1 135
%define K_F2 136
%define K_F3 137
%define K_F4 138
%define K_F5 139
%define K_F6 140
%define K_F7 141
%define K_F8 142
%define K_F9 143
%define K_F10 144
%define K_F11 145
%define K_F12 146
%define K_INS 147
%define K_DEL 148
%define K_PGDN 149
%define K_PGUP 150
%define K_HOME 151
%define K_END 152
%define K_MOUSE1 200
%define K_MOUSE2 201
%define K_MOUSE3 202

%define USERCMD_FORWARDMOVE 12
%define USERCMD_SIDEMOVE 16

section .text

global IN_Init
global IN_Shutdown
global IN_Commands
global IN_Move
global IN_ClearStates
global quake_pump_input

extern Key_Event
extern memset
extern vibe_poll_input
extern vibe_syscall3

IN_Init:
    push dword 0
    push dword 0
    push dword QUAKE_STATUS_INIT | QUAKE_INIT_INPUT
    push dword SYS_GAMEPLAY_STATUS
    call vibe_syscall3
    add esp, 16
    ret

IN_Shutdown:
    ret

IN_Commands:
    jmp quake_pump_input

IN_ClearStates:
    push ebp
    mov ebp, esp
    push dword 256
    push dword 0
    push dword quake_key_state
    call memset
    add esp, 12
    mov dword [quake_mouse_buttons], 0
    mov dword [quake_mouse_delta_x], 0
    mov dword [quake_mouse_delta_y], 0
    pop ebp
    ret

IN_Move:
    push ebp
    mov ebp, esp
    mov edx, [ebp + 8]
    test edx, edx
    jz .done

    cmp byte [quake_key_state + 'w'], 0
    jne .forward
    cmp byte [quake_key_state + K_UPARROW], 0
    je .check_back
.forward:
    mov dword [edx + USERCMD_FORWARDMOVE], 0x43480000
    jmp .check_side

.check_back:
    cmp byte [quake_key_state + 's'], 0
    jne .back
    cmp byte [quake_key_state + K_DOWNARROW], 0
    je .check_side
.back:
    mov dword [edx + USERCMD_FORWARDMOVE], 0xc3480000

.check_side:
    cmp byte [quake_key_state + 'd'], 0
    jne .right
    cmp byte [quake_key_state + K_RIGHTARROW], 0
    je .check_left
.right:
    mov dword [edx + USERCMD_SIDEMOVE], 0x43480000
    jmp .done

.check_left:
    cmp byte [quake_key_state + 'a'], 0
    jne .left
    cmp byte [quake_key_state + K_LEFTARROW], 0
    je .done
.left:
    mov dword [edx + USERCMD_SIDEMOVE], 0xc3480000

.done:
    pop ebp
    ret

quake_pump_input:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    sub esp, 32
    mov dword [ebp - 32], 64

.poll_loop:
    lea eax, [ebp - 28]
    push eax
    call vibe_poll_input
    add esp, 4
    cmp eax, 0
    jle .report

    inc dword [quake_input_events]
    cmp dword [ebp - 24], VIBE_INPUT_DEVICE_KEYBOARD
    jne .check_mouse
    cmp dword [ebp - 20], VIBE_INPUT_EVENT_KEY
    jne .next_event

    mov eax, [ebp - 16]
    call quake_key_from_ps2_set1_code
    test eax, eax
    jz .next_event
    mov esi, eax
    xor ebx, ebx
    cmp dword [ebp - 12], VIBE_INPUT_KEY_PRESSED
    sete bl
    cmp esi, 256
    jae .emit_key
    mov [quake_key_state + esi], bl

.emit_key:
    push ebx
    push esi
    call Key_Event
    add esp, 8
    jmp .next_event

.check_mouse:
    cmp dword [ebp - 24], VIBE_INPUT_DEVICE_MOUSE
    jne .next_event
    cmp dword [ebp - 20], VIBE_INPUT_EVENT_MOUSE_PACKET
    jne .next_event

    mov eax, [ebp - 16]
    and eax, VIBE_INPUT_MOUSE_BUTTON_MASK
    mov ebx, [quake_mouse_buttons]
    cmp eax, ebx
    je .mouse_motion
    mov [quake_mouse_buttons], eax
    call emit_mouse_button_changes

.mouse_motion:
    mov eax, [ebp - 12]
    add [quake_mouse_delta_x], eax
    mov eax, [ebp - 8]
    add [quake_mouse_delta_y], eax

.next_event:
    dec dword [ebp - 32]
    jnz .poll_loop

.report:
    mov eax, [quake_mouse_buttons]
    push eax
    push dword [quake_input_events]
    push dword QUAKE_STATUS_INPUT
    push dword SYS_GAMEPLAY_STATUS
    call vibe_syscall3
    add esp, 16
    add esp, 32
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

emit_mouse_button_changes:
    push eax
    push ebx
    push ecx
    push edx
    mov ecx, eax
    xor edx, ebx

    test edx, 0x01
    jz .check_right
    mov eax, K_MOUSE1
    mov ebx, ecx
    and ebx, 0x01
    call emit_mouse_key

.check_right:
    test edx, 0x02
    jz .check_middle
    mov eax, K_MOUSE2
    mov ebx, ecx
    and ebx, 0x02
    call emit_mouse_key

.check_middle:
    test edx, 0x04
    jz .done
    mov eax, K_MOUSE3
    mov ebx, ecx
    and ebx, 0x04
    call emit_mouse_key

.done:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

emit_mouse_key:
    xor ebx, 0
    setnz bl
    mov [quake_key_state + eax], bl
    push ebx
    push eax
    call Key_Event
    add esp, 8
    ret

quake_key_from_ps2_set1_code:
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
    cmp edx, 0x4b
    je .left
    cmp edx, 0x4d
    je .right
    cmp edx, 0x1c
    je .enter
    cmp edx, 0x1d
    je .ctrl
    cmp edx, 0x38
    je .alt
    cmp edx, 0x52
    je .ins
    cmp edx, 0x53
    je .del
    cmp edx, 0x49
    je .pgup
    cmp edx, 0x51
    je .pgdn
    cmp edx, 0x47
    je .home
    cmp edx, 0x4f
    je .end
    xor eax, eax
    ret
.up:
    mov eax, K_UPARROW
    ret
.down:
    mov eax, K_DOWNARROW
    ret
.left:
    mov eax, K_LEFTARROW
    ret
.right:
    mov eax, K_RIGHTARROW
    ret
.enter:
    mov eax, K_ENTER
    ret
.ctrl:
    mov eax, K_CTRL
    ret
.alt:
    mov eax, K_ALT
    ret
.ins:
    mov eax, K_INS
    ret
.del:
    mov eax, K_DEL
    ret
.pgup:
    mov eax, K_PGUP
    ret
.pgdn:
    mov eax, K_PGDN
    ret
.home:
    mov eax, K_HOME
    ret
.end:
    mov eax, K_END
    ret

section .rodata
normal_key_map:
    db 0
    db K_ESCAPE
    db '1','2','3','4','5','6','7','8','9','0'
    db '-','=',K_BACKSPACE,K_TAB
    db 'q','w','e','r','t','y','u','i','o','p'
    db '[',']',K_ENTER,K_CTRL
    db 'a','s','d','f','g','h','j','k','l'
    db ';',39,'`',K_SHIFT,92
    db 'z','x','c','v','b','n','m'
    db ',','.','/',K_SHIFT
    times 0x38 - ($ - normal_key_map) db 0
    db K_ALT
    db K_SPACE
    times 0x3b - ($ - normal_key_map) db 0
    db K_F1,K_F2,K_F3,K_F4,K_F5,K_F6,K_F7,K_F8,K_F9,K_F10
    times 0x57 - ($ - normal_key_map) db 0
    db K_F11,K_F12
    times 128 - ($ - normal_key_map) db 0

section .bss
align 4
quake_input_events resd 1
quake_mouse_buttons resd 1
quake_mouse_delta_x resd 1
quake_mouse_delta_y resd 1
quake_key_state resb 256
