BITS 32
extern vibe_user_syscall3
extern vibe_user_syscall2
extern vibe_user_syscall1
extern vibe_user_syscall0
extern vibe_user_getpid
extern vibe_user_getppid
extern vibe_user_process_status
extern vibe_user_process_status_current
extern vibe_user_clock_monotonic
extern vibe_user_yield
extern vibe_user_sleep_ticks
extern vibe_user_streq
extern vibe_user_listdir
extern vibe_user_file_size
extern vibe_user_file_read_all
extern vibe_user_file_read_at
extern vibe_user_file_write_at
extern vibe_user_open
extern vibe_user_write
extern vibe_user_read
extern vibe_user_lseek
extern vibe_user_pwrite
extern vibe_user_fstat
extern vibe_user_ftruncate
extern vibe_user_close
extern vibe_user_unlink
extern vibe_user_stat
extern vibe_user_pread
extern vibe_user_fork
extern vibe_user_exit
extern vibe_user_waitpid
extern vibe_user_mmap_file_private
extern vibe_user_munmap
extern vibe_user_fb_get_info
extern vibe_user_fb_can_present_indexed
extern vibe_user_present_indexed_checked
extern vibe_user_audio_device_start
extern vibe_user_audio_device_info
extern vibe_user_audio_pcm_ring_info
extern vibe_user_audio_pcm_open
extern vibe_user_audio_pcm_write_desc
extern vibe_user_audio_stream_info
extern vibe_user_audio_pcm_buffered_bytes
extern vibe_user_audio_pcm_drain
extern vibe_user_audio_pcm_close
extern vibe_user_fcntl
extern vibe_user_poll_input
extern vibe_user_input_status
extern vibe_user_input_device_status
extern vibe_user_write_all
extern vibe_user_report_probe
extern vibe_user_execv
section .text
global user_main

align 16
user_main:

    push	ebp
    mov	ebp, esp
    push	ebx
    push	edi
    push	esi
    sub	esp, 52
    mov	esi, dword [ebp + 12]
    mov	edi, dword [ebp + 8]
    mov	byte [ebp - 32], 0
    mov	dword [ebp - 36], 1179403566
    mov	dword [ebp - 40], 1297043268
    mov	byte [ebp - 56], 0
    mov	dword [ebp - 60], 1179403566
    mov	dword [ebp - 64], 1162891086
    mov	word [ebp - 20], 68
    mov	dword [ebp - 24], 1096232497
    mov	dword [ebp - 28], 1297043268
%ifdef BOOT_PAYLOAD_QUAKE
    mov	dword [ebp - 52], L.str.5
%else
    lea	eax, [ebp - 40]
    mov	dword [ebp - 52], eax
%endif
    mov	dword [ebp - 48], 0
    call	vibe_user_getpid
    mov	dword [ebp - 16], eax
    push	16
    push	user_main.root_entries
    push	L.str
    call	vibe_user_listdir
    add	esp, 12
    mov	dword [ebp - 44], eax
    push	user_main.now
    call	vibe_user_clock_monotonic
    add	esp, 4
    mov	ebx, eax
    cmp	edi, 1
    setne	cl
    test	esi, esi
    sete	dl
    mov	eax, 10
    or	dl, cl
    jne	LBB0_40

    mov	ecx, dword [esi]
    test	ecx, ecx
    je	LBB0_40

    push	L.str.1
    push	ecx
    call	vibe_user_streq
    add	esp, 8
    mov	ecx, eax
    mov	eax, 10
    test	ecx, ecx
    je	LBB0_40

    mov	edi, dword [ebp + 16]
    test	edi, edi
    mov	eax, 11
    je	LBB0_40

    cmp	dword [esi + 4], 0
    jne	LBB0_40

    mov	ecx, dword [edi]
    test	ecx, ecx
    je	LBB0_40

    push	L.str.2
    push	ecx
    call	vibe_user_streq
    add	esp, 8
    test	eax, eax
    je	LBB0_39

    mov	eax, dword [edi + 4]
    test	eax, eax
    je	LBB0_39

    push	L.str.3
    push	eax
    call	vibe_user_streq
    add	esp, 8
    test	eax, eax
    je	LBB0_39

    cmp	dword [edi + 8], 0
    mov	eax, 11
    jne	LBB0_40

    cmp	dword [ebp - 16], 0
    jle	LBB0_41

    test	ebx, ebx
    mov	eax, 13
    jne	LBB0_40

    cmp	dword [user_main.now+4], 100
    jne	LBB0_40

    mov	ecx, dword [ebp - 16]
    call	prove_process_services
    test	eax, eax
    je	LBB0_42

    mov	esi, dword [ebp - 44]
    test	esi, esi
    jle	LBB0_43

    mov	ecx, esi
    mov	edx, L.str.1
    call	root_contains
    test	eax, eax
    je	LBB0_44

    mov	ecx, esi
    mov	edx, L.str.4
    call	root_contains
    test	eax, eax
    je	LBB0_45

    mov	ecx, esi
    mov	edx, L.str.5
    call	root_contains
    test	eax, eax
    je	LBB0_46

    call	prove_generic_file_services
    mov	ecx, eax
    mov	eax, 35
    test	ecx, ecx
    je	LBB0_40

    lea	eax, [ebp - 28]
    push	0
    push	0
    push	eax
    call	vibe_user_open
    add	esp, 12
    test	eax, eax
    js	LBB0_47

    mov	esi, eax
    push	0
    push	1
    push	eax
    call	vibe_user_fcntl
    add	esp, 12
    mov	ecx, eax
    mov	eax, 19
    test	ecx, ecx
    jne	LBB0_40

    push	1
    push	2
    push	esi
    call	vibe_user_fcntl
    add	esp, 12
    mov	ecx, eax
    mov	eax, 20
    test	ecx, ecx
    jne	LBB0_40

    push	0
    push	1
    push	esi
    call	vibe_user_fcntl
    add	esp, 12
    mov	ecx, eax
    mov	eax, 21
    cmp	ecx, 1
    jne	LBB0_40

    push	0
    push	2
    push	esi
    call	vibe_user_fcntl
    add	esp, 12
    mov	ecx, eax
    mov	eax, 22
    test	ecx, ecx
    jne	LBB0_40

    push	esi
    call	vibe_user_close
    add	esp, 4
    mov	ecx, eax
    mov	eax, 23
    test	ecx, ecx
    jne	LBB0_40

    lea	ecx, [ebp - 28]
    call	prove_file_private_mapping
    test	eax, eax
    je	LBB0_48

    lea	ecx, [ebp - 28]
    call	prove_fork_clone
    test	eax, eax
    mov	eax, 24
    je	LBB0_40

    lea	edx, [ebp - 52]
    mov	ecx, L.str.6
    push	edi
    call	vibe_user_execve
    add	esp, 4
    mov	ecx, eax
    mov	eax, 28
    cmp	ecx, -22
    jne	LBB0_40

    lea	ecx, [ebp - 64]
    lea	esi, [ebp - 52]
    mov	edx, esi
    push	edi
    call	vibe_user_execve
    add	esp, 4
    mov	ecx, eax
    mov	eax, 29
    cmp	ecx, -2
    jne	LBB0_40

    push	user_main.input_status
    call	vibe_user_input_status
    add	esp, 4
    mov	ecx, eax
    mov	eax, 30
    test	ecx, ecx
    jne	LBB0_40

    call	vibe_input_status_abi_is_current
    test	eax, eax
    je	LBB0_49

    mov	eax, dword [user_main.input_status+28]
    not	eax
    test	al, 13
    jne	LBB0_52

    cmp	dword [user_main.input_status+120], 1
    jne	LBB0_52

    cmp	dword [user_main.input_status+124], 1
    jne	LBB0_52

    push	user_main.input_event
    call	vibe_user_poll_input
    add	esp, 4
    test	eax, eax
    js	LBB0_52

    push	user_main.keyboard_status
    push	1
    call	vibe_user_input_device_status
    add	esp, 8
    test	eax, eax
    je	LBB0_54
LBB0_52:
    mov	eax, 32
    jmp	LBB0_40
LBB0_39:
    mov	eax, 11
LBB0_40:
    add	esp, 52
    pop	esi
    pop	edi
    pop	ebx
    pop	ebp
    ret
LBB0_41:
    mov	eax, 12
    jmp	LBB0_40
LBB0_42:
    mov	eax, 34
    jmp	LBB0_40
LBB0_43:
    mov	eax, 14
    jmp	LBB0_40
LBB0_44:
    mov	eax, 15
    jmp	LBB0_40
LBB0_45:
    mov	eax, 16
    jmp	LBB0_40
LBB0_46:
    mov	eax, 17
    jmp	LBB0_40
LBB0_47:
    mov	eax, 18
    jmp	LBB0_40
LBB0_48:
    mov	eax, 24
    jmp	LBB0_40
LBB0_49:
    mov	eax, 31
    jmp	LBB0_40
LBB0_54:
    cmp	dword [user_main.keyboard_status], 2
    jne	LBB0_52

    cmp	dword [user_main.keyboard_status+4], 64
    jne	LBB0_52

    mov	eax, dword [user_main.keyboard_status+8]
    dec	eax
    cmp	eax, 1
    ja	LBB0_52

    cmp	dword [user_main.keyboard_status+12], 1
    jne	LBB0_52

    mov	eax, dword [user_main.keyboard_status+16]
    not	eax
    test	al, 9
    jne	LBB0_52

    mov	ecx, user_main.keyboard_status
    call	vibe_input_device_status_counters_are_consistent
    test	eax, eax
    je	LBB0_52

    push	user_main.mouse_status
    push	2
    call	vibe_user_input_device_status
    add	esp, 8
    test	eax, eax
    jne	LBB0_52

    cmp	dword [user_main.mouse_status], 2
    jne	LBB0_52

    cmp	dword [user_main.mouse_status+4], 64
    jne	LBB0_52

    mov	eax, dword [user_main.mouse_status+8]
    dec	eax
    cmp	eax, 1
    ja	LBB0_52

    mov	eax, dword [user_main.mouse_status+16]
    not	eax
    test	al, 14
    jne	LBB0_52

    mov	ecx, user_main.mouse_status
    call	vibe_input_device_status_counters_are_consistent
    test	eax, eax
    mov	eax, 32
    je	LBB0_40

    call	prove_framebuffer_device
    test	eax, eax
    je	LBB0_82

    call	prove_audio_device
    test	eax, eax
    mov	eax, 35
    je	LBB0_40

    push	L.str.7
    push	1
    call	vibe_user_write_all
    add	esp, 8
    push	1023
    push	-1474621250
    call	vibe_user_report_probe
    add	esp, 8
    push	esi
%ifdef BOOT_PAYLOAD_QUAKE
    push	L.str.5
%else
    lea	eax, [ebp - 40]
    push	eax
%endif
    call	vibe_user_execv
    add	esp, 8
    mov	ecx, eax
    test	eax, eax
    je	LBB0_70

    mov	ecx, 26
LBB0_70:
    mov	eax, ecx
    jmp	LBB0_40
LBB0_82:
    mov	eax, 33
    jmp	LBB0_40
Lfunc_end0:

align 16
prove_process_services:

    push	ebp
    mov	ebp, esp
    push	edi
    push	esi
    sub	esp, 96
    mov	esi, ecx
    lea	edi, [ebp - 88]
    push	edi
    call	vibe_user_process_status_current
    add	esp, 4
    mov	ecx, eax
    xor	eax, eax
    test	ecx, ecx
    je	LBB1_2
LBB1_1:
    add	esp, 96
    pop	esi
    pop	edi
    pop	ebp
    ret
LBB1_2:
    cmp	dword [ebp - 88], 1
    jne	LBB1_1

    cmp	dword [ebp - 84], 64
    jne	LBB1_1

    cmp	dword [ebp - 80], esi
    jne	LBB1_1

    cmp	dword [ebp - 72], 2
    jne	LBB1_1

    mov	ecx, dword [ebp - 68]
    cmp	ecx, 4
    je	LBB1_8

    cmp	ecx, 1
    jne	LBB1_1
LBB1_8:
    call	vibe_user_getppid
    test	eax, eax
    jle	LBB1_16

    cmp	eax, dword [ebp - 76]
    jne	LBB1_16

    push	edi
    push	esi
    call	vibe_user_process_status
    add	esp, 8
    test	eax, eax
    jne	LBB1_16

    cmp	dword [ebp - 80], esi
    jne	LBB1_16

    push	edi
    push	-1
    call	vibe_user_process_status
    add	esp, 8
    cmp	eax, -22
    jne	LBB1_16

    lea	eax, [ebp - 104]
    push	eax
    call	vibe_user_clock_monotonic
    add	esp, 4
    test	eax, eax
    jne	LBB1_16

    call	vibe_user_yield
    test	eax, eax
    jne	LBB1_16

    push	1
    call	vibe_user_sleep_ticks
    add	esp, 4
    test	eax, eax
    jne	LBB1_16

    lea	eax, [ebp - 24]
    push	eax
    call	vibe_user_clock_monotonic
    add	esp, 4
    test	eax, eax
    jne	LBB1_16

    mov	eax, dword [ebp - 24]
    cmp	eax, dword [ebp - 104]
    jbe	LBB1_16

    push	edi
    call	vibe_user_process_status_current
    add	esp, 4
    test	eax, eax
    mov	eax, 0
    jne	LBB1_1

    cmp	dword [ebp - 80], esi
    sete	al
    mov	ecx, dword [ebp - 24]
    cmp	dword [ebp - 32], ecx
    setae	cl
    and	cl, al
    movzx	eax, cl
    jmp	LBB1_1
LBB1_16:
    xor	eax, eax
    jmp	LBB1_1
Lfunc_end1:

align 16
root_contains:

    push	ebp
    mov	ebp, esp
    push	ebx
    push	edi
    push	esi
    mov	esi, edx
    mov	edi, ecx
    mov	ebx, user_main.root_entries
    jmp	LBB2_1
align 16
LBB2_5:
    add	ebx, 32
    dec	edi
    je	LBB2_6
LBB2_1:
    cmp	byte [ebx], 0
    je	LBB2_5

    test	byte [ebx + 28], 16
    jne	LBB2_5

    push	esi
    push	ebx
    call	vibe_user_streq
    add	esp, 8
    test	eax, eax
    je	LBB2_5

    mov	eax, 1
    jmp	LBB2_7
LBB2_6:
    xor	eax, eax
LBB2_7:
    pop	esi
    pop	edi
    pop	ebx
    pop	ebp
    ret
Lfunc_end2:

align 16
prove_generic_file_services:

    push	ebp
    mov	ebp, esp
    push	ebx
    push	edi
    push	esi
    and	esp, -8
    sub	esp, 168
    mov	dword [esp + 68], 5461061
    mov	dword [esp + 64], 1397965103
    mov	dword [esp + 116], 7633012
    mov	dword [esp + 112], 778399076
    mov	dword [esp + 108], 1634038319
    mov	dword [esp + 104], 1937007987
    mov	dword [esp + 100], 1935748910
    mov	word [esp + 96], 80
    mov	dword [esp + 92], 1095577137
    mov	dword [esp + 88], 1295074607
    mov	dword [esp + 84], 1397768525
    mov	dword [esp + 80], 793990213
    mov	dword [esp + 76], 1397965103
    mov	dword [esp + 59], 4543553
    mov	dword [esp + 56], 1096045404
    mov	dword [esp + 48], 7627108
    mov	dword [esp + 44], 778989417
    mov	dword [esp + 40], 1936942451
    mov	dword [esp + 36], 795178081
    mov	dword [esp + 32], 1953705774
    mov	word [esp + 16], 10
    mov	dword [esp + 12], 1702125940
    mov	dword [esp + 8], 1932358502
    mov	dword [esp + 4], 761881185
    mov	dword [esp + 20], 0
    mov	dword [esp], 0
    mov	dword [esp + 28], 0
    push	16
    push	prove_generic_file_services.entries
    push	L.str
    call	vibe_user_listdir
    add	esp, 12
    mov	ebx, eax
    xor	eax, eax
    test	ebx, ebx
    jle	LBB3_106

    mov	edi, prove_generic_file_services.entries
    mov	esi, ebx
align 16
LBB3_3:
    push	L.str.8
    push	edi
    call	vibe_user_streq
    add	esp, 8
    test	eax, eax
    jne	LBB3_4

    add	edi, 32
    dec	esi
    jne	LBB3_3
    jmp	LBB3_105
LBB3_4:
    test	byte [edi + 28], 16
    je	LBB3_105

    mov	edi, prove_generic_file_services.entries
align 16
LBB3_7:
    push	L.str.9
    push	edi
    call	vibe_user_streq
    add	esp, 8
    test	eax, eax
    jne	LBB3_8

    add	edi, 32
    dec	ebx
    jne	LBB3_7
    jmp	LBB3_105
LBB3_8:
    test	byte [edi + 28], 16
    je	LBB3_105

    lea	eax, [esp + 64]
    push	16
    push	prove_generic_file_services.entries
    push	eax
    call	vibe_user_listdir
    add	esp, 12
    test	eax, eax
    jle	LBB3_105

    mov	esi, eax
    mov	edi, prove_generic_file_services.entries
    mov	ebx, eax
align 16
LBB3_12:
    push	L.str.10
    push	edi
    call	vibe_user_streq
    add	esp, 8
    test	eax, eax
    jne	LBB3_13

    add	edi, 32
    dec	ebx
    jne	LBB3_12
LBB3_105:
    xor	eax, eax
LBB3_106:
    lea	esp, [ebp - 12]
    pop	esi
    pop	edi
    pop	ebx
    pop	ebp
    ret
LBB3_13:
    cmp	byte [edi], 0
    mov	eax, 0
    je	LBB3_106

    test	byte [edi + 28], 16
    jne	LBB3_106

    mov	edi, prove_generic_file_services.entries
LBB3_17:
    push	L.str.11
    push	edi
    call	vibe_user_streq
    add	esp, 8
    test	eax, eax
    jne	LBB3_18

    add	edi, 32
    dec	esi
    jne	LBB3_17
    jmp	LBB3_105
LBB3_18:
    test	byte [edi + 28], 16
    je	LBB3_105

    lea	esi, [esp + 20]
    lea	edi, [esp + 100]
    push	esi
    push	edi
    call	vibe_user_file_size
    add	esp, 8
    test	eax, eax
    jne	LBB3_105

    cmp	dword [esp + 20], 35
    jne	LBB3_105

    mov	ebx, esp
    push	ebx
    push	80
    push	prove_generic_file_services.buffer
    push	edi
    call	vibe_user_file_read_all
    add	esp, 16
    test	eax, eax
    jne	LBB3_105

    mov	eax, dword [esp]
    cmp	eax, dword [esp + 20]
    jne	LBB3_105

    test	eax, eax
    je	LBB3_27

    xor	ecx, ecx
LBB3_26:
    movzx	edx, byte [ecx + prove_generic_file_services.buffer]
    cmp	dl, byte [ecx + L__const.prove_generic_file_services.asset_expected]
    jne	LBB3_105

    inc	ecx
    cmp	eax, ecx
    jne	LBB3_26
LBB3_27:
    push	ebx
    push	5
    push	prove_generic_file_services.buffer
    push	8
    push	edi
    call	vibe_user_file_read_at
    add	esp, 20
    test	eax, eax
    jne	LBB3_105

    cmp	dword [esp], 5
    jne	LBB3_105

    cmp	byte [prove_generic_file_services.buffer], 70
    jne	LBB3_105

    cmp	byte [prove_generic_file_services.buffer+1], 65
    jne	LBB3_105

    cmp	byte [prove_generic_file_services.buffer+2], 84
    jne	LBB3_105

    cmp	byte [prove_generic_file_services.buffer+3], 49
    jne	LBB3_105

    cmp	byte [prove_generic_file_services.buffer+4], 54
    jne	LBB3_105

    push	0
    push	1
    push	edi
    call	vibe_user_open
    add	esp, 12
    cmp	eax, -13
    jne	LBB3_105

    lea	eax, [esp + 76]
    push	esi
    push	eax
    call	vibe_user_file_size
    add	esp, 8
    cmp	eax, -22
    jne	LBB3_105

    lea	esi, [esp + 120]
    lea	eax, [esp + 56]
    push	esi
    push	eax
    call	vibe_user_stat
    add	esp, 8
    test	eax, eax
    jne	LBB3_105

    mov	eax, 61440
    and	eax, dword [esp + 128]
    cmp	eax, 16384
    jne	LBB3_105

    lea	eax, [esp + 32]
    push	0
    push	770
    push	eax
    call	vibe_user_open
    add	esp, 12
    test	eax, eax
    js	LBB3_105

    mov	edi, eax
    lea	eax, [esp + 4]
    push	13
    push	eax
    push	edi
    call	vibe_user_write
    add	esp, 12
    cmp	eax, 13
    jne	LBB3_104

    push	0
    push	0
    push	edi
    call	vibe_user_lseek
    add	esp, 12
    test	eax, eax
    jne	LBB3_104

    push	13
    push	prove_generic_file_services.buffer
    push	edi
    call	vibe_user_read
    add	esp, 12
    cmp	eax, 13
    jne	LBB3_104

    movzx	eax, byte [prove_generic_file_services.buffer]
    cmp	al, byte [esp + 4]
    jne	LBB3_104

    movzx	eax, byte [prove_generic_file_services.buffer+1]
    cmp	al, byte [esp + 5]
    jne	LBB3_104

    movzx	eax, byte [prove_generic_file_services.buffer+2]
    cmp	al, byte [esp + 6]
    jne	LBB3_104

    movzx	eax, byte [prove_generic_file_services.buffer+3]
    cmp	al, byte [esp + 7]
    jne	LBB3_104

    movzx	eax, byte [prove_generic_file_services.buffer+4]
    cmp	al, byte [esp + 8]
    jne	LBB3_104

    movzx	eax, byte [prove_generic_file_services.buffer+5]
    cmp	al, byte [esp + 9]
    jne	LBB3_104

    movzx	eax, byte [prove_generic_file_services.buffer+6]
    cmp	al, byte [esp + 10]
    jne	LBB3_104

    movzx	eax, byte [prove_generic_file_services.buffer+7]
    cmp	al, byte [esp + 11]
    jne	LBB3_104

    movzx	eax, byte [prove_generic_file_services.buffer+8]
    cmp	al, byte [esp + 12]
    jne	LBB3_104

    movzx	eax, byte [prove_generic_file_services.buffer+9]
    cmp	al, byte [esp + 13]
    jne	LBB3_104

    movzx	eax, byte [prove_generic_file_services.buffer+10]
    cmp	al, byte [esp + 14]
    jne	LBB3_104

    movzx	eax, byte [prove_generic_file_services.buffer+11]
    cmp	al, byte [esp + 15]
    jne	LBB3_104

    movzx	eax, byte [prove_generic_file_services.buffer+12]
    cmp	al, byte [esp + 16]
    jne	LBB3_104

    push	0
    push	3
    push	edi
    call	vibe_user_lseek
    add	esp, 12
    cmp	eax, 3
    jne	LBB3_104

    push	4
    push	3
    push	L.str.13
    push	edi
    call	vibe_user_pwrite
    add	esp, 16
    cmp	eax, 3
    jne	LBB3_104

    push	1
    push	0
    push	edi
    call	vibe_user_lseek
    add	esp, 12
    cmp	eax, 3
    jne	LBB3_104

    push	0
    push	0
    push	edi
    call	vibe_user_lseek
    add	esp, 12
    test	eax, eax
    je	LBB3_59
LBB3_104:
    push	edi
    call	vibe_user_close
    add	esp, 4
    lea	eax, [esp + 32]
    push	eax
    call	vibe_user_unlink
    add	esp, 4
    jmp	LBB3_105
LBB3_59:
    push	13
    push	prove_generic_file_services.buffer
    push	edi
    call	vibe_user_read
    add	esp, 12
    cmp	eax, 13
    jne	LBB3_104

    cmp	byte [prove_generic_file_services.buffer], 97
    jne	LBB3_104

    cmp	byte [prove_generic_file_services.buffer+1], 98
    jne	LBB3_104

    cmp	byte [prove_generic_file_services.buffer+2], 105
    jne	LBB3_104

    cmp	byte [prove_generic_file_services.buffer+3], 45
    jne	LBB3_104

    cmp	byte [prove_generic_file_services.buffer+4], 71
    jne	LBB3_104

    cmp	byte [prove_generic_file_services.buffer+5], 69
    jne	LBB3_104

    cmp	byte [prove_generic_file_services.buffer+6], 78
    jne	LBB3_104

    cmp	byte [prove_generic_file_services.buffer+7], 115
    jne	LBB3_104

    cmp	byte [prove_generic_file_services.buffer+8], 116
    jne	LBB3_104

    cmp	byte [prove_generic_file_services.buffer+9], 97
    jne	LBB3_104

    cmp	byte [prove_generic_file_services.buffer+10], 116
    jne	LBB3_104

    cmp	byte [prove_generic_file_services.buffer+11], 101
    jne	LBB3_104

    cmp	byte [prove_generic_file_services.buffer+12], 10
    jne	LBB3_104

    push	esi
    push	edi
    call	vibe_user_fstat
    add	esp, 8
    test	eax, eax
    jne	LBB3_104

    cmp	dword [esp + 148], 13
    jne	LBB3_104

    mov	dword [esp + 52], 80
    mov	dword [esp + 24], prove_generic_file_services.buffer
    mov	dl, 65
    xor	eax, eax
LBB3_76:
    movzx	ebx, al
    imul	ebx, ebx, 101
    mov	dh, al
    sub	dh, bh
    shr	dh, 1
    add	dh, bh
    shr	dh, 4
    movzx	ebx, dh
    lea	ecx, [ebx + 2*ebx]
    shl	ecx, 3
    sub	ecx, ebx
    mov	dh, dl
    sub	dh, cl
    mov	ecx, dword [esp + 24]
    mov	byte [ecx], dh
    inc	ecx
    mov	dword [esp + 24], ecx
    inc	dl
    inc	al
    dec	dword [esp + 52]
    jne	LBB3_76

    push	0
    push	0
    push	edi
    call	vibe_user_lseek
    add	esp, 12
    test	eax, eax
    jne	LBB3_104

    mov	ebx, 24
LBB3_79:
    push	80
    push	prove_generic_file_services.buffer
    push	edi
    call	vibe_user_write
    add	esp, 12
    cmp	eax, 80
    jne	LBB3_104

    dec	ebx
    jne	LBB3_79

    push	esi
    push	edi
    call	vibe_user_fstat
    add	esp, 8
    test	eax, eax
    jne	LBB3_104

    cmp	dword [esp + 148], 1920
    jne	LBB3_104

    push	1
    push	edi
    call	vibe_user_ftruncate
    add	esp, 8
    test	eax, eax
    jne	LBB3_104

    push	2
    push	0
    push	edi
    call	vibe_user_lseek
    add	esp, 12
    cmp	eax, 1
    jne	LBB3_104

    push	0
    push	0
    push	edi
    call	vibe_user_lseek
    add	esp, 12
    test	eax, eax
    jne	LBB3_104

    push	1
    push	prove_generic_file_services.buffer
    push	edi
    call	vibe_user_read
    add	esp, 12
    cmp	eax, 1
    jne	LBB3_104

    cmp	byte [prove_generic_file_services.buffer], 65
    jne	LBB3_104

    push	4
    push	edi
    call	vibe_user_ftruncate
    add	esp, 8
    test	eax, eax
    jne	LBB3_104

    push	2
    push	0
    push	edi
    call	vibe_user_lseek
    add	esp, 12
    cmp	eax, 4
    jne	LBB3_104

    push	0
    push	edi
    call	vibe_user_ftruncate
    add	esp, 8
    test	eax, eax
    jne	LBB3_104

    push	edi
    call	vibe_user_close
    add	esp, 4
    test	eax, eax
    jne	LBB3_105

    lea	eax, [esp + 32]
    push	eax
    call	vibe_user_unlink
    add	esp, 4
    test	eax, eax
    jne	LBB3_105

    push	esi
    lea	eax, [esp + 36]
    push	eax
    call	vibe_user_stat
    add	esp, 8
    cmp	eax, -2
    jne	LBB3_105

    lea	eax, [esp + 28]
    push	eax
    push	2
    push	L.str.14
    push	2
    lea	eax, [esp + 48]
    push	eax
    call	vibe_user_file_write_at
    add	esp, 20
    test	eax, eax
    jne	LBB3_105

    cmp	dword [esp + 28], 2
    jne	LBB3_105

    mov	eax, esp
    push	eax
    push	80
    push	prove_generic_file_services.buffer
    lea	eax, [esp + 44]
    push	eax
    call	vibe_user_file_read_all
    add	esp, 16
    test	eax, eax
    jne	LBB3_105

    cmp	dword [esp], 4
    jne	LBB3_105

    cmp	byte [prove_generic_file_services.buffer], 0
    jne	LBB3_105

    cmp	byte [prove_generic_file_services.buffer+1], 0
    jne	LBB3_105

    cmp	byte [prove_generic_file_services.buffer+2], 120
    jne	LBB3_105

    cmp	byte [prove_generic_file_services.buffer+3], 121
    jne	LBB3_105

    lea	eax, [esp + 32]
    push	eax
    call	vibe_user_unlink
    add	esp, 4
    test	eax, eax
    mov	eax, 0
    jne	LBB3_106

    push	esi
    lea	eax, [esp + 36]
    push	eax
    call	vibe_user_stat
    add	esp, 8
    cmp	eax, -2
    mov	eax, 0
    sete	al
    jmp	LBB3_106
Lfunc_end3:

align 16
prove_file_private_mapping:

    push	ebp
    mov	ebp, esp
    push	ebx
    push	edi
    push	esi
    sub	esp, 12
    mov	dword [ebp - 20], 0
    mov	dword [ebp - 24], 0
    mov	byte [ebp - 13], 0
    push	0
    push	0
    push	ecx
    call	vibe_user_open
    add	esp, 12
    test	eax, eax
    js	LBB4_1

    mov	esi, eax
    push	0
    push	7
    push	eax
    call	vibe_user_lseek
    add	esp, 12
    xor	edi, edi
    cmp	eax, 7
    jne	LBB4_21

    lea	eax, [ebp - 20]
    push	0
    push	esi
    push	3
    push	4096
    push	eax
    call	vibe_user_mmap_file_private
    add	esp, 20
    test	eax, eax
    jne	LBB4_21

    push	1
    push	0
    push	esi
    call	vibe_user_lseek
    add	esp, 12
    xor	edi, edi
    cmp	eax, 7
    jne	LBB4_19

    mov	eax, dword [ebp - 20]
    movzx	ecx, byte [eax]
    cmp	ecx, 80
    je	LBB4_7

    xor	edi, edi
    cmp	ecx, 73
    jne	LBB4_20
LBB4_7:
    xor	edi, edi
    cmp	byte [eax + 1], 87
    jne	LBB4_19

    cmp	byte [eax + 2], 65
    jne	LBB4_19

    cmp	byte [eax + 3], 68
    jne	LBB4_19

    mov	byte [eax], 88
    push	0
    push	0
    push	esi
    call	vibe_user_lseek
    add	esp, 12
    test	eax, eax
    jne	LBB4_19

    lea	eax, [ebp - 13]
    push	1
    push	eax
    push	esi
    call	vibe_user_read
    add	esp, 12
    cmp	eax, 1
    jne	LBB4_19

    movzx	eax, byte [ebp - 13]
    cmp	eax, 80
    je	LBB4_14

    cmp	eax, 73
    jne	LBB4_19
LBB4_14:
    push	4096
    push	dword [ebp - 20]
    call	vibe_user_munmap
    add	esp, 8
    xor	edi, edi
    test	eax, eax
    jne	LBB4_21

    mov	dword [ebp - 20], 0
    push	2
    push	0
    push	esi
    call	vibe_user_lseek
    add	esp, 12
    cmp	eax, 2
    jl	LBB4_21

    add	eax, -2
    lea	ecx, [ebp - 24]
    push	eax
    push	esi
    push	3
    push	4096
    push	ecx
    call	vibe_user_mmap_file_private
    add	esp, 20
    test	eax, eax
    jne	LBB4_21

    mov	ebx, dword [ebp - 24]
    mov	ecx, ebx
    call	mapped_tail_is_zero
    mov	edi, eax
    test	ebx, ebx
    je	LBB4_19

    push	4096
    push	ebx
    call	vibe_user_munmap
    add	esp, 8
LBB4_19:
    mov	eax, dword [ebp - 20]
    test	eax, eax
    je	LBB4_21
LBB4_20:
    push	4096
    push	eax
    call	vibe_user_munmap
    add	esp, 8
LBB4_21:
    push	esi
    call	vibe_user_close
    add	esp, 4
    jmp	LBB4_22
LBB4_1:
    xor	edi, edi
LBB4_22:
    mov	eax, edi
    add	esp, 12
    pop	esi
    pop	edi
    pop	ebx
    pop	ebp
    ret
Lfunc_end4:

align 16
prove_fork_clone:

    push	ebp
    mov	ebp, esp
    push	ebx
    push	edi
    push	esi
    sub	esp, 28
    mov	dword [ebp - 20], 0
    mov	dword [ebp - 24], 0
    push	0
    push	0
    push	ecx
    call	vibe_user_open
    add	esp, 12
    xor	ebx, ebx
    test	eax, eax
    js	LBB5_23

    mov	esi, eax
    push	0
    push	0
    push	eax
    call	vibe_user_lseek
    add	esp, 12
    test	eax, eax
    je	LBB5_2
LBB5_21:
    push	esi
    call	vibe_user_close
LBB5_22:
    add	esp, 4
LBB5_23:
    mov	eax, ebx
    add	esp, 28
    pop	esi
    pop	edi
    pop	ebx
    pop	ebp
    ret
LBB5_2:
    call	vibe_user_fork
    test	eax, eax
    je	LBB5_3

    js	LBB5_21

    mov	edi, eax
    lea	eax, [ebp - 20]
    push	0
    push	eax
    push	edi
    call	vibe_user_waitpid
    add	esp, 12
    cmp	eax, edi
    jne	LBB5_21

    push	1
    push	0
    push	edi
    call	vibe_user_waitpid
    add	esp, 12
    mov	dword [ebp - 36], eax
    push	1
    push	0
    push	esi
    call	vibe_user_lseek
    add	esp, 12
    mov	dword [ebp - 40], eax
    call	vibe_user_fork
    test	eax, eax
    je	LBB5_13

    js	LBB5_21

    mov	dword [ebp - 32], eax
    lea	edx, [ebp - 20]
    mov	ecx, edi
    call	vibe_user_waitpid_nohang_reap_exact
    cmp	eax, -10
    jne	LBB5_21

    lea	edx, [ebp - 24]
    mov	edi, dword [ebp - 32]
    mov	ecx, edi
    call	vibe_user_waitpid_nohang_reap_exact
    mov	dword [ebp - 28], eax
    push	esi
    call	vibe_user_close
    add	esp, 4
    cmp	dword [ebp - 20], 42
    jne	LBB5_23

    cmp	dword [ebp - 28], edi
    jne	LBB5_23

    cmp	dword [ebp - 24], 42
    jne	LBB5_23

    cmp	dword [ebp - 40], 4
    jne	LBB5_23

    xor	ebx, ebx
    cmp	dword [ebp - 36], -10
    sete	bl
    jmp	LBB5_23
LBB5_3:
    mov	esi, 3
    lea	edi, [ebp - 16]
    jmp	LBB5_4
align 16
LBB5_7:
    inc	esi
    cmp	esi, 19
    je	LBB5_8
LBB5_4:
    push	4
    push	edi
    push	esi
    call	vibe_user_read
    add	esp, 12
    cmp	eax, 4
    jne	LBB5_7

    movzx	eax, byte [ebp - 16]
    movzx	ecx, byte [ebp - 15]
    mov	ch, al
    xor	ch, 73
    xor	cl, 87
    or	ch, cl
    movzx	edx, byte [ebp - 14]
    xor	dl, 65
    or	ch, dl
    mov	ah, byte [ebp - 13]
    xor	ah, 68
    mov	ebx, 42
    or	ch, ah
    je	LBB5_9

    xor	al, 80
    or	al, cl
    or	al, dl
    or	al, ah
    jne	LBB5_7
    jmp	LBB5_9
LBB5_8:
    mov	ebx, 31
LBB5_9:
    push	ebx
    call	vibe_user_exit
    jmp	LBB5_22
LBB5_13:
    push	42
    call	vibe_user_exit
    add	esp, 4
    mov	ebx, 42
    jmp	LBB5_23
Lfunc_end5:

align 16
vibe_user_execve:

    push	ebp
    mov	ebp, esp
    push	edi
    push	esi
    test	ecx, ecx
    je	LBB6_100

    cmp	byte [ecx], 0
    je	LBB6_100

    cmp	byte [ecx + 1], 0
    je	LBB6_17

    cmp	byte [ecx + 2], 0
    je	LBB6_17

    cmp	byte [ecx + 3], 0
    je	LBB6_17

    cmp	byte [ecx + 4], 0
    je	LBB6_17

    cmp	byte [ecx + 5], 0
    je	LBB6_17

    cmp	byte [ecx + 6], 0
    je	LBB6_17

    cmp	byte [ecx + 7], 0
    je	LBB6_17

    cmp	byte [ecx + 8], 0
    je	LBB6_17

    cmp	byte [ecx + 9], 0
    je	LBB6_17

    cmp	byte [ecx + 10], 0
    je	LBB6_17

    cmp	byte [ecx + 11], 0
    je	LBB6_17

    cmp	byte [ecx + 12], 0
    je	LBB6_17

    cmp	byte [ecx + 13], 0
    je	LBB6_17

    cmp	byte [ecx + 14], 0
    je	LBB6_17

    cmp	byte [ecx + 15], 0
    jne	LBB6_100
LBB6_17:
    mov	esi, dword [edx]
    test	esi, esi
    je	LBB6_100

    mov	eax, dword [ebp + 8]
    xor	edi, edi
align 16
LBB6_19:
    cmp	byte [esi + edi], 0
    je	LBB6_21

    inc	edi
    cmp	edi, 64
    jne	LBB6_19
    jmp	LBB6_100
LBB6_21:
    test	edi, edi
    je	LBB6_100

    mov	esi, dword [edx + 4]
    test	esi, esi
    je	LBB6_58

    xor	edi, edi
align 16
LBB6_24:
    cmp	byte [esi + edi], 0
    je	LBB6_26

    inc	edi
    cmp	edi, 64
    jne	LBB6_24
    jmp	LBB6_100
LBB6_26:
    test	edi, edi
    je	LBB6_100

    mov	esi, dword [edx + 8]
    test	esi, esi
    je	LBB6_58

    xor	edi, edi
LBB6_29:
    cmp	byte [esi + edi], 0
    je	LBB6_31

    inc	edi
    cmp	edi, 64
    jne	LBB6_29
    jmp	LBB6_100
LBB6_31:
    test	edi, edi
    je	LBB6_100

    mov	esi, dword [edx + 12]
    test	esi, esi
    je	LBB6_58

    xor	edi, edi
LBB6_34:
    cmp	byte [esi + edi], 0
    je	LBB6_36

    inc	edi
    cmp	edi, 64
    jne	LBB6_34
    jmp	LBB6_100
LBB6_36:
    test	edi, edi
    je	LBB6_100

    mov	esi, dword [edx + 16]
    test	esi, esi
    je	LBB6_58

    xor	edi, edi
LBB6_39:
    cmp	byte [esi + edi], 0
    je	LBB6_41

    inc	edi
    cmp	edi, 64
    jne	LBB6_39
    jmp	LBB6_100
LBB6_41:
    test	edi, edi
    je	LBB6_100

    mov	esi, dword [edx + 20]
    test	esi, esi
    je	LBB6_58

    xor	edi, edi
LBB6_44:
    cmp	byte [esi + edi], 0
    je	LBB6_46

    inc	edi
    cmp	edi, 64
    jne	LBB6_44
    jmp	LBB6_100
LBB6_46:
    test	edi, edi
    je	LBB6_100

    mov	esi, dword [edx + 24]
    test	esi, esi
    je	LBB6_58

    xor	edi, edi
LBB6_49:
    cmp	byte [esi + edi], 0
    je	LBB6_51

    inc	edi
    cmp	edi, 64
    jne	LBB6_49
    jmp	LBB6_100
LBB6_51:
    test	edi, edi
    je	LBB6_100

    mov	esi, dword [edx + 28]
    test	esi, esi
    je	LBB6_58

    xor	edi, edi
LBB6_54:
    cmp	byte [esi + edi], 0
    je	LBB6_56

    inc	edi
    cmp	edi, 64
    jne	LBB6_54
    jmp	LBB6_100
LBB6_56:
    test	edi, edi
    je	LBB6_100

    cmp	dword [edx + 32], 0
    jne	LBB6_100
LBB6_58:
    mov	esi, dword [eax]
    test	esi, esi
    je	LBB6_98

    xor	edi, edi
align 16
LBB6_60:
    cmp	byte [esi + edi], 0
    je	LBB6_99

    inc	edi
    cmp	edi, 64
    jne	LBB6_60
    jmp	LBB6_100
LBB6_99:
    test	edi, edi
    je	LBB6_100

    mov	esi, dword [eax + 4]
    test	esi, esi
    je	LBB6_98

    xor	edi, edi
LBB6_64:
    cmp	byte [esi + edi], 0
    je	LBB6_66

    inc	edi
    cmp	edi, 64
    jne	LBB6_64
    jmp	LBB6_100
LBB6_66:
    test	edi, edi
    je	LBB6_100

    mov	esi, dword [eax + 8]
    test	esi, esi
    je	LBB6_98

    xor	edi, edi
LBB6_69:
    cmp	byte [esi + edi], 0
    je	LBB6_71

    inc	edi
    cmp	edi, 64
    jne	LBB6_69
    jmp	LBB6_100
LBB6_71:
    test	edi, edi
    je	LBB6_100

    mov	esi, dword [eax + 12]
    test	esi, esi
    je	LBB6_98

    xor	edi, edi
LBB6_74:
    cmp	byte [esi + edi], 0
    je	LBB6_76

    inc	edi
    cmp	edi, 64
    jne	LBB6_74
    jmp	LBB6_100
LBB6_76:
    test	edi, edi
    je	LBB6_100

    mov	esi, dword [eax + 16]
    test	esi, esi
    je	LBB6_98

    xor	edi, edi
LBB6_79:
    cmp	byte [esi + edi], 0
    je	LBB6_81

    inc	edi
    cmp	edi, 64
    jne	LBB6_79
    jmp	LBB6_100
LBB6_81:
    test	edi, edi
    je	LBB6_100

    mov	esi, dword [eax + 20]
    test	esi, esi
    je	LBB6_98

    xor	edi, edi
LBB6_84:
    cmp	byte [esi + edi], 0
    je	LBB6_86

    inc	edi
    cmp	edi, 64
    jne	LBB6_84
    jmp	LBB6_100
LBB6_86:
    test	edi, edi
    je	LBB6_100

    mov	esi, dword [eax + 24]
    test	esi, esi
    je	LBB6_98

    xor	edi, edi
LBB6_89:
    cmp	byte [esi + edi], 0
    je	LBB6_91

    inc	edi
    cmp	edi, 64
    jne	LBB6_89
    jmp	LBB6_100
LBB6_91:
    test	edi, edi
    je	LBB6_100

    mov	esi, dword [eax + 28]
    test	esi, esi
    je	LBB6_98

    xor	edi, edi
LBB6_94:
    cmp	byte [esi + edi], 0
    je	LBB6_96

    inc	edi
    cmp	edi, 64
    jne	LBB6_94
    jmp	LBB6_100
LBB6_96:
    test	edi, edi
    je	LBB6_100

    cmp	dword [eax + 32], 0
    je	LBB6_98
LBB6_100:
    mov	eax, -22
LBB6_101:
    pop	esi
    pop	edi
    pop	ebp
    ret
LBB6_98:
    push	eax
    push	edx
    push	ecx
    push	16
    call	vibe_user_syscall3
    add	esp, 16
    jmp	LBB6_101
Lfunc_end6:

align 16
vibe_input_status_abi_is_current:

    push	ebp
    mov	ebp, esp
    mov	ecx, dword [user_main.input_status]
    xor	ecx, 2
    mov	eax, dword [user_main.input_status+4]
    xor	eax, 28
    or	eax, ecx
    mov	ecx, dword [user_main.input_status+8]
    xor	ecx, 64
    mov	edx, dword [user_main.input_status+112]
    xor	edx, 132
    or	edx, ecx
    or	edx, eax
    mov	ecx, dword [user_main.input_status+116]
    xor	ecx, 63
    or	ecx, edx
    mov	edx, dword [user_main.input_status+120]
    xor	edx, 1
    xor	eax, eax
    or	edx, ecx
    sete	al
    pop	ebp
    ret
Lfunc_end7:

align 16
vibe_input_device_status_counters_are_consistent:

    push	ebp
    mov	ebp, esp
    xor	eax, eax
    test	ecx, ecx
    je	LBB8_6

    cmp	dword [ecx], 2
    jne	LBB8_6

    cmp	dword [ecx + 4], 64
    jne	LBB8_6

    mov	edx, dword [ecx + 8]
    dec	edx
    cmp	edx, 1
    ja	LBB8_6

    mov	edx, dword [ecx + 24]
    cmp	dword [ecx + 28], edx
    ja	LBB8_6

    xor	eax, eax
    cmp	dword [ecx + 32], edx
    setbe	al
LBB8_6:
    pop	ebp
    ret
Lfunc_end8:

align 16
prove_framebuffer_device:

    push	ebp
    mov	ebp, esp
    push	ebx
    push	edi
    push	esi
    sub	esp, 192
    lea	esi, [ebp - 120]
    push	esi
    call	vibe_user_fb_get_info
    add	esp, 4
    mov	ecx, eax
    xor	eax, eax
    test	ecx, ecx
    je	LBB9_2
LBB9_1:
    add	esp, 192
    pop	esi
    pop	edi
    pop	ebx
    pop	ebp
    ret
LBB9_2:
    mov	ecx, dword [ebp - 52]
    not	ecx
    test	cl, 19
    jne	LBB9_1

    cmp	dword [ebp - 48], 1
    jne	LBB9_1

    mov	edi, dword [ebp - 44]
    mov	ebx, dword [ebp - 40]
    test	edi, edi
    sete	cl
    test	ebx, ebx
    sete	dl
    or	dl, cl
    jne	LBB9_1

    mov	eax, ebx
    mul	edi
    mov	edx, 0
    jo	LBB9_7

    mov	edx, ebx
    imul	edx, edi
LBB9_7:
    lea	eax, [edx - 64001]
    cmp	eax, -64000
    mov	eax, 0
    jb	LBB9_1

    mov	dword [ebp - 16], ebx
    mov	dword [ebp - 20], edi
    mov	edi, -3
    mov	al, -1
    xor	ebx, ebx
align 16
LBB9_9:
    mov	byte [edi + framebuffer_probe_palette+3], bl
    mov	byte [edi + framebuffer_probe_palette+4], al
    lea	ecx, [edi + 3]
    mov	byte [edi + framebuffer_probe_palette+5], cl
    inc	bl
    dec	al
    cmp	ecx, 765
    mov	edi, ecx
    jb	LBB9_9

    xor	eax, eax
align 16
LBB9_11:
    mov	ecx, eax
    shr	ecx, 8
    add	ecx, eax
    or	cl, 1
    mov	byte [eax + framebuffer_probe_frame], cl
    inc	eax
    cmp	edx, eax
    jne	LBB9_11

    mov	dword [ebp - 36], framebuffer_probe_frame
    mov	dword [ebp - 32], framebuffer_probe_palette
    mov	eax, dword [ebp - 20]
    mov	dword [ebp - 28], eax
    mov	eax, dword [ebp - 16]
    mov	dword [ebp - 24], eax
    lea	edi, [ebp - 36]
    push	edi
    push	esi
    call	vibe_user_fb_can_present_indexed
    add	esp, 8
    mov	ecx, eax
    xor	eax, eax
    test	ecx, ecx
    je	LBB9_1

    push	edi
    call	vibe_user_present_indexed_checked
    add	esp, 4
    test	eax, eax
    jne	LBB9_14

    lea	eax, [ebp - 204]
    push	eax
    call	vibe_user_fb_get_info
    add	esp, 4
    test	eax, eax
    je	LBB9_17
LBB9_14:
    xor	eax, eax
    jmp	LBB9_1
LBB9_17:
    test	byte [ebp - 136], 16
    mov	eax, 0
    je	LBB9_1

    lea	ecx, [ebp - 204]
    call	vibe_fb_info_dirty_rect_is_bounded
    jmp	LBB9_1
Lfunc_end9:

align 16
prove_audio_device:

    push	ebp
    mov	ebp, esp
    push	esi
    sub	esp, 272
    lea	eax, [ebp - 276]
    push	0
    push	eax
    push	9
    push	13
    call	vibe_user_syscall3
    add	esp, 16
    test	eax, eax
    mov	eax, 1
    jne	LBB10_18

    cmp	dword [ebp - 272], 1
    jne	LBB10_18

    cmp	dword [ebp - 276], 0
    je	LBB10_18

    mov	ecx, dword [ebp - 248]
    not	ecx
    xor	eax, eax
    test	cl, 5
    jne	LBB10_18

    push	0
    push	0
    push	1
    push	13
    call	vibe_user_syscall3
    add	esp, 16
    test	eax, eax
    js	LBB10_17

    lea	eax, [ebp - 180]
    push	0
    push	eax
    push	10
    push	13
    call	vibe_user_syscall3
    add	esp, 16
    test	eax, eax
    jne	LBB10_17

    cmp	dword [ebp - 180], 1
    mov	eax, 0
    jne	LBB10_18

    cmp	dword [ebp - 176], 2
    jne	LBB10_18

    cmp	dword [ebp - 172], 11025
    jne	LBB10_18

    cmp	dword [ebp - 168], 0
    je	LBB10_18

    cmp	dword [ebp - 164], 0
    je	LBB10_18

    mov	eax, -64
    xor	ecx, ecx
align 16
LBB10_12:
    mov	edx, ecx
    and	dl, 63
    add	dl, 96
    mov	byte [eax + audio_probe_samples+64], dl
    add	cl, 5
    inc	eax
    jne	LBB10_12

    mov	dword [ebp - 132], 0
    mov	dword [ebp - 128], 0
    mov	dword [ebp - 124], 11025
    mov	dword [ebp - 120], 2
    mov	dword [ebp - 116], 1
    mov	dword [ebp - 112], 0
    mov	dword [ebp - 108], 0
    mov	dword [ebp - 104], 0
    mov	dword [ebp - 100], 0
    mov	dword [ebp - 96], 0
    mov	dword [ebp - 92], 0
    mov	dword [ebp - 88], 0
    mov	dword [ebp - 84], 0
    mov	dword [ebp - 80], 0
    mov	dword [ebp - 76], 0
    mov	dword [ebp - 72], 0
    lea	eax, [ebp - 132]
    push	eax
    push	0
    push	14
    push	13
    call	vibe_user_syscall3
    add	esp, 16
    mov	esi, eax
    xor	eax, eax
    test	esi, esi
    jle	LBB10_18

    mov	dword [ebp - 68], audio_probe_samples
    mov	dword [ebp - 64], 64
    mov	dword [ebp - 60], 11025
    mov	dword [ebp - 56], 2
    mov	dword [ebp - 52], 1
    mov	dword [ebp - 48], 0
    mov	dword [ebp - 44], 0
    mov	dword [ebp - 40], 0
    mov	dword [ebp - 36], 0
    mov	dword [ebp - 32], 0
    mov	dword [ebp - 28], 0
    mov	dword [ebp - 24], 0
    mov	dword [ebp - 20], 0
    mov	dword [ebp - 16], 0
    mov	dword [ebp - 12], 0
    mov	dword [ebp - 8], 0
    lea	eax, [ebp - 68]
    push	eax
    push	esi
    push	13
    push	13
    call	vibe_user_syscall3
    add	esp, 16
    cmp	eax, 64
    jne	LBB10_17

    lea	eax, [ebp - 228]
    push	eax
    push	esi
    push	11
    push	13
    call	vibe_user_syscall3
    add	esp, 16
    test	eax, eax
    je	LBB10_21
LBB10_17:
    xor	eax, eax
LBB10_18:
    add	esp, 272
    pop	esi
    pop	ebp
    ret
LBB10_21:
    cmp	dword [ebp - 220], esi
    mov	eax, 0
    jne	LBB10_18

    cmp	dword [ebp - 228], 2
    jne	LBB10_18

    test	byte [ebp - 224], 1
    je	LBB10_18

    push	0
    push	esi
    push	7
    push	13
    call	vibe_user_syscall3
    add	esp, 16
    cmp	eax, 64
    jl	LBB10_17

    push	0
    push	esi
    push	15
    push	13
    call	vibe_user_syscall3
    add	esp, 16
    test	eax, eax
    mov	eax, 0
    js	LBB10_18

    push	0
    push	esi
    push	16
    push	13
    call	vibe_user_syscall3
    add	esp, 16
    mov	ecx, eax
    xor	eax, eax
    test	ecx, ecx
    sete	al
    jmp	LBB10_18
Lfunc_end10:

align 16
mapped_tail_is_zero:

    push	ebp
    mov	ebp, esp
    xor	eax, eax
    cmp	byte [ecx + 2], 0
    je	LBB11_1
LBB11_14:
    pop	ebp
    ret
LBB11_1:
    cmp	byte [ecx + 3], 0
    jne	LBB11_14

    cmp	byte [ecx + 4], 0
    jne	LBB11_14

    cmp	byte [ecx + 5], 0
    jne	LBB11_14

    cmp	byte [ecx + 6], 0
    jne	LBB11_14

    cmp	byte [ecx + 7], 0
    jne	LBB11_14

    cmp	byte [ecx + 8], 0
    jne	LBB11_14

    cmp	byte [ecx + 9], 0
    jne	LBB11_14

    cmp	byte [ecx + 10], 0
    jne	LBB11_14

    cmp	byte [ecx + 11], 0
    jne	LBB11_14

    cmp	byte [ecx + 12], 0
    jne	LBB11_14

    cmp	byte [ecx + 13], 0
    jne	LBB11_14

    cmp	byte [ecx + 14], 0
    jne	LBB11_14

    xor	eax, eax
    cmp	byte [ecx + 15], 0
    sete	al
    pop	ebp
    ret
Lfunc_end11:

align 16
vibe_user_waitpid_nohang_reap_exact:

    push	ebp
    mov	ebp, esp
    push	ebx
    push	edi
    push	esi
    mov	esi, edx
    mov	edi, ecx
    mov	ebx, 200000
align 16
LBB12_1:
    push	1
    push	esi
    push	edi
    call	vibe_user_waitpid
    add	esp, 12
    cmp	eax, edi
    je	LBB12_8

    test	eax, eax
    js	LBB12_8

    jne	LBB12_4

    call	vibe_user_yield
    test	eax, eax
    js	LBB12_8

    dec	ebx
    jne	LBB12_1

    xor	eax, eax
    jmp	LBB12_8
LBB12_4:
    mov	eax, -10
LBB12_8:
    pop	esi
    pop	edi
    pop	ebx
    pop	ebp
    ret
Lfunc_end12:

align 16
vibe_fb_info_dirty_rect_is_bounded:

    push	ebp
    mov	ebp, esp
    push	ebx
    push	edi
    push	esi
    push	eax
    test	byte [ecx + 68], 16
    je	LBB13_1

    mov	edi, dword [ecx + 76]
    test	edi, edi
    je	LBB13_1

    mov	eax, dword [ecx + 80]
    test	eax, eax
    je	LBB13_1

    mov	esi, dword [ecx + 64]
    test	esi, esi
    je	LBB13_15

    xor	ebx, ebx
    mov	dword [ebp - 16], eax
    mul	edi
    mov	eax, 0
    jo	LBB13_7

    mov	eax, dword [ebp - 16]
    imul	eax, edi
LBB13_7:
    cmp	esi, eax
    ja	LBB13_26

    mov	edx, dword [ecx + 56]
    test	edx, edx
    je	LBB13_1

    mov	eax, dword [ecx + 60]
    test	eax, eax
    je	LBB13_1

    sub	edi, dword [ecx + 48]
    jbe	LBB13_1

    mov	esi, dword [ebp - 16]
    sub	esi, dword [ecx + 52]
    setbe	cl
    cmp	edx, edi
    seta	dl
    or	dl, cl
    jne	LBB13_1

    cmp	eax, esi
    setbe	bl
    jmp	LBB13_26
LBB13_15:
    cmp	dword [ecx + 48], 0
    jne	LBB13_1

    cmp	dword [ecx + 52], 0
    jne	LBB13_1

    cmp	dword [ecx + 56], 0
    je	LBB13_25
LBB13_1:
    xor	ebx, ebx
LBB13_26:
    movzx	eax, bl
    add	esp, 4
    pop	esi
    pop	edi
    pop	ebx
    pop	ebp
    ret
LBB13_25:
    cmp	dword [ecx + 60], 0
    sete	bl
    jmp	LBB13_26
Lfunc_end13:

section .rodata
L__const.user_main.missing_path:
db `NOPE.ELF`, 0

L__const.user_main.wad_path:
db `DOOM1.WAD`, 0

L.str:
db `/`, 0

L.str.1:
db `ABIPROBE.ELF`, 0

L.str.2:
db `PROBE_LAUNCHER=USERPROB`, 0

L.str.3:
db `ABI_ENV=present`, 0

L.str.4:
db `USERPROB.ELF`, 0

L.str.5:
%ifdef BOOT_PAYLOAD_QUAKE
db `PAYLOAD1.ELF`, 0
%else
db `PAYLOAD0.ELF`, 0
%endif

L.str.6:
times 1 db 0

L.str.7:
db `abi probe ok\n`, 0

L__const.prove_generic_file_services.asset_file:
db `./assets/readme.txt`, 0

L__const.prove_generic_file_services.nested_asset:
db `/ASSETS/MAPS/E1M1.MAP`, 0

L__const.prove_generic_file_services.state_dir:
db `\\STATE`, 0

L__const.prove_generic_file_services.state_file:
db `./state/session.dat`, 0

L__const.prove_generic_file_services.asset_expected:
db `vibe-os FAT16 one-level asset file\n`, 0

L__const.prove_generic_file_services.state_payload:
db `abi-fs-state\n`, 0

L.str.8:
db `ASSETS`, 0

L.str.9:
db `STATE`, 0

L.str.10:
db `README.TXT`, 0

L.str.11:
db `MAPS`, 0

L.str.13:
db `GEN`, 0

L.str.14:
db `xy`, 0

section .bss
align 4
user_main.root_entries resb 512
align 4
user_main.now resb 16
align 4
user_main.input_event resb 28
align 4
user_main.input_status resb 132
align 4
user_main.keyboard_status resb 64
align 4
user_main.mouse_status resb 64
align 4
prove_generic_file_services.entries resb 512
prove_generic_file_services.buffer resb 80
framebuffer_probe_palette resb 768
framebuffer_probe_frame resb 64000
audio_probe_samples resb 64
