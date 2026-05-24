BITS 32
extern D_PostEvent
extern D_QuitNetGame
extern G_LoadGame
extern G_SaveGame
extern M_SaveDefaults
extern S_sfx
extern W_CacheLumpNum
extern W_CheckNumForName
extern W_GetNumForName
extern W_LumpLength
extern Z_Malloc
extern automapactive
extern consoleplayer
extern defaultfile
extern doom_original_G_BuildTiccmd
extern doom_original_G_Ticker
extern doomcom
extern exit
extern fclose
extern fopen
extern fprintf
extern fread
extern gameaction
extern gameepisode
extern gamemap
extern gamestate
extern gametic
extern leveltime
extern malloc
extern memcmp
extern memcpy
extern memset
extern menuactive
extern netcmds
extern netgame
extern paused
extern playeringame
extern players
extern savedescription
extern savegameslot
extern screens
extern sendsave
extern singletics
extern stat
extern stderr
extern strlen
extern strncpy
extern ticdup
extern vibe_audio_device_shutdown
extern vibe_audio_device_start
extern vibe_audio_mixer_is_playing
extern vibe_audio_mixer_start
extern vibe_audio_mixer_stop
extern vibe_audio_mixer_update
extern vibe_audio_pcm_pull_state
extern vibe_audio_stream_info
extern vibe_audio_stream_write
extern vibe_doom_save_stream_note_error
extern vibe_doom_translate_input_event
extern vibe_monotonic_milliseconds
extern vibe_music_init
extern vibe_music_register_song
extern vibe_music_stream_begin
extern vibe_music_stream_render
extern vibe_music_stream_set_volume
extern vibe_music_stream_stop
extern vibe_music_unregister_song
extern vibe_poll_input
extern vibe_present_indexed_checked
extern vibe_syscall3
extern vsnprintf
section .text
global I_Init
align 16
I_Init:
	push	ebp
	mov	ebp, esp
	push	0
	push	0
	push	1073741826
	push	15
	call	vibe_syscall3
	add	esp, 16
	pop	ebp
	jmp	cache_persistence_requests
Lfunc_end0:
align 16
cache_persistence_requests:
	push	ebp
	mov	ebp, esp
	sub	esp, 44
	cmp	byte [default_config_checkpoint_request_checked], 0
	jne	LBB1_4
	test	byte [default_config_checkpoint_requested], 1
	jne	LBB1_4
	mov	byte [default_config_checkpoint_request_checked], 1
	lea	eax, [ebp - 44]
	push	eax
	push	L.str.3
	call	stat
	add	esp, 8
	test	eax, eax
	je	LBB1_3
LBB1_4:
	cmp	byte [save_checkpoint_requested], 0
	jne	LBB1_10
LBB1_5:
	cmp	byte [save_checkpoint_request_checked], 0
	jne	LBB1_10
	mov	byte [save_checkpoint_request_checked], 1
	mov	dword [save_checkpoint_slot], 0
	lea	eax, [ebp - 44]
	push	eax
	push	L.str.4
	call	stat
	add	esp, 8
	test	eax, eax
	js	LBB1_9
	mov	eax, dword [ebp - 16]
	lea	ecx, [eax - 7]
	cmp	ecx, -6
	jae	LBB1_8
LBB1_9:
	mov	byte [save_checkpoint_requested], 0
	mov	byte [save_checkpoint_request_checked], 0
	cmp	byte [load_checkpoint_requested], 0
	je	LBB1_11
	jmp	LBB1_16
LBB1_3:
	mov	byte [default_config_checkpoint_requested], 1
	cmp	byte [save_checkpoint_requested], 0
	je	LBB1_5
LBB1_10:
	cmp	byte [load_checkpoint_requested], 0
	jne	LBB1_16
LBB1_11:
	cmp	byte [load_checkpoint_request_checked], 0
	jne	LBB1_16
	mov	byte [load_checkpoint_request_checked], 1
	mov	dword [load_checkpoint_slot], 0
	lea	eax, [ebp - 44]
	push	eax
	push	L.str.5
	call	stat
	add	esp, 8
	test	eax, eax
	js	LBB1_15
	mov	eax, dword [ebp - 16]
	lea	ecx, [eax - 7]
	cmp	ecx, -6
	jae	LBB1_14
LBB1_15:
	mov	byte [load_checkpoint_requested], 0
	mov	byte [load_checkpoint_request_checked], 0
	jmp	LBB1_16
LBB1_8:
	dec	eax
	mov	dword [save_checkpoint_slot], eax
	mov	byte [save_checkpoint_requested], 1
	cmp	byte [load_checkpoint_requested], 0
	je	LBB1_11
	jmp	LBB1_16
LBB1_14:
	dec	eax
	mov	dword [load_checkpoint_slot], eax
	mov	byte [load_checkpoint_requested], 1
LBB1_16:
	add	esp, 44
	pop	ebp
	ret
Lfunc_end1:
global I_ZoneBase
align 16
I_ZoneBase:
	push	ebp
	mov	ebp, esp
	push	esi
	mov	esi, dword [ebp + 8]
	push	0
	push	0
	push	1073741828
	push	15
	call	vibe_syscall3
	add	esp, 16
	call	cache_persistence_requests
	mov	dword [esi], 8388608
	mov	eax, doom_zone
	pop	esi
	pop	ebp
	ret
Lfunc_end2:
global I_GetTime
align 16
I_GetTime:
	push	ebp
	mov	ebp, esp
	call	vibe_monotonic_milliseconds
	imul	eax, eax, 35
	mov	ecx, 274877907
	mul	ecx
	mov	eax, edx
	shr	eax, 6
	pop	ebp
	ret
Lfunc_end3:
global I_StartFrame
align 16
I_StartFrame:
	push	ebp
	mov	ebp, esp
	pop	ebp
	ret
Lfunc_end4:
global I_StartTic
align 16
I_StartTic:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 60
	push	0
	push	0
	push	1073741952
	push	15
	call	vibe_syscall3
	add	esp, 16
	call	pump_music_stream
	mov	esi, 64
	lea	edi, [ebp - 72]
	lea	ebx, [ebp - 28]
	jmp	LBB5_1
LBB5_10:
	mov	dword [ebp - 44], 2
	mov	eax, dword [ebp - 24]
LBB5_11:
	mov	dword [ebp - 40], eax
	mov	eax, dword [ebp - 20]
	mov	ecx, dword [ebp - 16]
	mov	dword [ebp - 36], eax
	mov	dword [ebp - 32], ecx
	lea	eax, [ebp - 44]
	push	eax
	call	D_PostEvent
	add	esp, 4
LBB5_12:
	dec	esi
	je	LBB5_13
LBB5_1:
	push	edi
	call	vibe_poll_input
	add	esp, 4
	test	eax, eax
	jle	LBB5_13
	push	ebx
	push	edi
	call	vibe_doom_translate_input_event
	add	esp, 8
	test	eax, eax
	je	LBB5_12
	mov	eax, dword [ebp - 28]
	cmp	eax, 3
	je	LBB5_10
	cmp	eax, 2
	je	LBB5_8
	cmp	eax, 1
	jne	LBB5_12
	mov	eax, dword [ebp - 24]
	movzx	ecx, al
	cmp	byte [ecx + vibe_key_down], 0
	jne	LBB5_12
	mov	byte [ecx + vibe_key_down], 1
	mov	dword [ebp - 44], 0
	jmp	LBB5_11
LBB5_8:
	mov	eax, dword [ebp - 24]
	movzx	ecx, al
	cmp	byte [ecx + vibe_key_down], 0
	je	LBB5_12
	mov	byte [ecx + vibe_key_down], 0
	mov	dword [ebp - 44], 1
	jmp	LBB5_11
LBB5_13:
	add	esp, 60
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
Lfunc_end5:
align 16
pump_music_stream:
	cmp	dword [current_music_handle], 0
	jle	LBB6_36
	test	byte [current_music_paused], 1
	jne	LBB6_36
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 48
	call	vibe_monotonic_milliseconds
	imul	eax, eax, 35
	mov	ecx, 274877907
	mul	ecx
	mov	esi, edx
	shr	esi, 6
	mov	eax, dword [current_music_next_tic]
	test	eax, eax
	setne	cl
	cmp	esi, eax
	setl	al
	test	cl, al
	jne	LBB6_35
	movzx	eax, word [current_music_handle]
	or	eax, 1297416192
	push	eax
	call	vibe_audio_mixer_is_playing
	add	esp, 4
	test	eax, eax
	mov	edi, dword [current_music_handle]
	jle	LBB6_19
	test	edi, edi
	je	LBB6_15
	lea	ebx, [ebp - 60]
	push	48
	push	0
	push	ebx
	call	memset
	add	esp, 12
	movzx	edi, di
	or	edi, 1297416192
	push	ebx
	push	edi
	call	vibe_audio_stream_info
	add	esp, 8
	test	eax, eax
	jne	LBB6_15
	cmp	dword [ebp - 52], edi
	jne	LBB6_15
	mov	eax, dword [ebp - 48]
	mov	ecx, dword [ebp - 44]
	mov	edx, eax
	sub	edx, ecx
	jb	LBB6_15
	cmp	dword [ebp - 40], edx
	jne	LBB6_15
	mov	edx, dword [ebp - 24]
	mov	edi, dword [ebp - 20]
	cmp	edx, dword [current_music_under_seen]
	jne	LBB6_11
	cmp	edi, dword [current_music_drop_seen]
	je	LBB6_12
LBB6_11:
	mov	dword [current_music_under_seen], edx
	mov	dword [current_music_drop_seen], edi
LBB6_12:
	cmp	dword [ebp - 60], 2
	jne	LBB6_14
	mov	edx, dword [ebp - 56]
	test	dl, 1
	jne	LBB6_37
LBB6_14:
	mov	dword [current_music_refill_seen], ecx
	inc	esi
	jmp	LBB6_34
LBB6_15:
	movzx	eax, word [current_music_handle]
	or	eax, 1297416192
	push	eax
	call	vibe_audio_pcm_pull_state
	add	esp, 4
	mov	edi, eax
	test	eax, eax
	jg	LBB6_17
	xor	edi, edi
LBB6_17:
	cmp	edi, dword [current_music_pull_seen]
	jne	LBB6_26
	inc	esi
	jmp	LBB6_34
LBB6_19:
	mov	ecx, edi
	call	submit_music_stream_chunk
	test	eax, eax
	je	LBB6_33
	mov	edi, dword [current_music_handle]
	test	edi, edi
	je	LBB6_28
	lea	ebx, [ebp - 60]
	push	48
	push	0
	push	ebx
	call	memset
	add	esp, 12
	movzx	edi, di
	or	edi, 1297416192
	push	ebx
	push	edi
	call	vibe_audio_stream_info
	add	esp, 8
	test	eax, eax
	jne	LBB6_28
	cmp	dword [ebp - 52], edi
	jne	LBB6_28
	mov	ecx, dword [ebp - 48]
	mov	eax, dword [ebp - 44]
	mov	edx, ecx
	sub	edx, eax
	jb	LBB6_28
	cmp	dword [ebp - 40], edx
	jne	LBB6_28
LBB6_25:
	mov	dword [current_music_pull_seen], ecx
	mov	dword [current_music_refill_seen], eax
	mov	eax, dword [ebp - 24]
	mov	ecx, dword [ebp - 20]
	mov	dword [current_music_under_seen], eax
	mov	dword [current_music_drop_seen], ecx
	jmp	LBB6_31
LBB6_26:
	mov	ecx, dword [current_music_handle]
	call	submit_music_stream_chunk
	test	eax, eax
	je	LBB6_33
	mov	dword [current_music_pull_seen], edi
	jmp	LBB6_31
LBB6_28:
	movzx	eax, word [current_music_handle]
	or	eax, 1297416192
	push	eax
	call	vibe_audio_pcm_pull_state
	add	esp, 4
	test	eax, eax
	jg	LBB6_30
	xor	eax, eax
LBB6_30:
	mov	dword [current_music_pull_seen], eax
LBB6_31:
	add	esi, 6
	jmp	LBB6_34
LBB6_37:
	test	dl, 2
	je	LBB6_14
	cmp	eax, ecx
	je	LBB6_14
	cmp	eax, dword [current_music_pull_seen]
	jbe	LBB6_14
	mov	dword [current_music_pull_seen], eax
	mov	ecx, dword [current_music_handle]
	call	submit_music_stream_chunk
	test	eax, eax
	je	LBB6_33
	mov	edi, dword [current_music_handle]
	test	edi, edi
	je	LBB6_46
	push	48
	push	0
	push	ebx
	call	memset
	add	esp, 12
	movzx	edi, di
	or	edi, 1297416192
	push	ebx
	push	edi
	call	vibe_audio_stream_info
	add	esp, 8
	test	eax, eax
	jne	LBB6_46
	cmp	dword [ebp - 52], edi
	jne	LBB6_46
	mov	ecx, dword [ebp - 48]
	mov	eax, dword [ebp - 44]
	mov	edx, ecx
	sub	edx, eax
	jb	LBB6_46
	cmp	dword [ebp - 40], edx
	je	LBB6_25
LBB6_46:
	inc	dword [current_music_refill_seen]
	jmp	LBB6_31
LBB6_33:
	xor	esi, esi
LBB6_34:
	mov	dword [current_music_next_tic], esi
LBB6_35:
	add	esp, 48
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
LBB6_36:
	ret
Lfunc_end6:
global I_BaseTiccmd
align 16
I_BaseTiccmd:
	push	ebp
	mov	ebp, esp
	push	8
	push	0
	push	empty_ticcmd
	call	memset
	add	esp, 12
	mov	eax, empty_ticcmd
	pop	ebp
	ret
Lfunc_end7:
global I_Quit
align 16
I_Quit:
	push	ebp
	mov	ebp, esp
	push	esi
	call	D_QuitNetGame
	call	vibe_audio_device_shutdown
	mov	esi, dword [current_music_handle]
	test	esi, esi
	je	LBB8_2
	movzx	eax, si
	or	eax, 1297416192
	push	eax
	call	vibe_audio_mixer_stop
	add	esp, 4
	push	esi
	call	vibe_music_stream_stop
	add	esp, 4
LBB8_2:
	mov	dword [current_music_handle], 0
	mov	dword [current_music_looping], 0
	mov	byte [current_music_paused], 0
	mov	dword [current_music_next_tic], 0
	mov	dword [current_music_pull_seen], 0
	mov	dword [current_music_refill_seen], 0
	mov	dword [current_music_under_seen], 0
	mov	dword [current_music_drop_seen], 0
	call	M_SaveDefaults
	push	0
	call	exit
	add	esp, 4
	pop	esi
	pop	ebp
	ret
Lfunc_end8:
global I_ShutdownSound
align 16
I_ShutdownSound:
	push	ebp
	mov	ebp, esp
	pop	ebp
	jmp	vibe_audio_device_shutdown
Lfunc_end9:
global I_ShutdownMusic
align 16
I_ShutdownMusic:
	push	ebp
	mov	ebp, esp
	push	esi
	mov	esi, dword [current_music_handle]
	test	esi, esi
	je	LBB10_2
	movzx	eax, si
	or	eax, 1297416192
	push	eax
	call	vibe_audio_mixer_stop
	add	esp, 4
	push	esi
	call	vibe_music_stream_stop
	add	esp, 4
LBB10_2:
	mov	dword [current_music_handle], 0
	mov	dword [current_music_looping], 0
	mov	byte [current_music_paused], 0
	mov	dword [current_music_next_tic], 0
	mov	dword [current_music_pull_seen], 0
	mov	dword [current_music_refill_seen], 0
	mov	dword [current_music_under_seen], 0
	mov	dword [current_music_drop_seen], 0
	pop	esi
	pop	ebp
	ret
Lfunc_end10:
global I_ShutdownGraphics
align 16
I_ShutdownGraphics:
	push	ebp
	mov	ebp, esp
	pop	ebp
	ret
Lfunc_end11:
global I_AllocLow
align 16
I_AllocLow:
	push	ebp
	mov	ebp, esp
	push	edi
	push	esi
	mov	edi, dword [ebp + 8]
	xor	esi, esi
	test	edi, edi
	jle	LBB12_3
	add	edi, 180224
	push	edi
	call	malloc
	add	esp, 4
	test	eax, eax
	je	LBB12_3
	push	edi
	push	0
	push	eax
	mov	esi, eax
	call	memset
	add	esp, 12
LBB12_3:
	mov	eax, esi
	pop	esi
	pop	edi
	pop	ebp
	ret
Lfunc_end12:
global I_Tactile
align 16
I_Tactile:
	push	ebp
	mov	ebp, esp
	pop	ebp
	ret
Lfunc_end13:
global I_Error
align 16
I_Error:
	push	ebp
	mov	ebp, esp
	push	esi
	sub	esp, 260
	mov	eax, dword [ebp + 8]
	lea	ecx, [ebp + 12]
	mov	dword [ebp - 8], ecx
	lea	esi, [ebp - 264]
	push	ecx
	push	eax
	push	256
	push	esi
	call	vsnprintf
	add	esp, 16
	call	vibe_doom_save_stream_note_error
	push	esi
	push	L.str.1
	push	dword [stderr]
	call	fprintf
	add	esp, 12
	push	1
	call	exit
	add	esp, 264
	pop	esi
	pop	ebp
	ret
Lfunc_end14:
global I_InitGraphics
align 16
I_InitGraphics:
	push	ebp
	mov	ebp, esp
	push	0
	push	0
	push	1073741856
	push	15
	call	vibe_syscall3
	add	esp, 16
	pop	ebp
	ret
Lfunc_end15:
global I_SetPalette
align 16
I_SetPalette:
	push	ebp
	mov	ebp, esp
	push	esi
	mov	esi, dword [ebp + 8]
	push	0
	push	0
	push	1073741888
	push	15
	call	vibe_syscall3
	add	esp, 16
	push	768
	push	esi
	push	active_palette
	call	memcpy
	add	esp, 12
	pop	esi
	pop	ebp
	ret
Lfunc_end16:
global I_UpdateNoBlit
align 16
I_UpdateNoBlit:
	push	ebp
	mov	ebp, esp
	pop	ebp
	ret
Lfunc_end17:
global G_BuildTiccmd
align 16
G_BuildTiccmd:
	push	ebp
	mov	ebp, esp
	push	esi
	sub	esp, 44
	mov	esi, dword [ebp + 8]
	cmp	byte [save_checkpoint_done], 0
	jne	LBB18_22
	cmp	dword [gamestate], 0
	sete	al
	cmp	dword [gameepisode], 0
	setg	cl
	cmp	dword [gamemap], 0
	setg	dl
	and	dl, cl
	cmp	dword [gametic], 0
	setg	cl
	and	cl, al
	and	cl, dl
	cmp	dword [leveltime], 32
	setge	dl
	mov	eax, dword [consoleplayer]
	cmp	eax, 4
	setb	ch
	and	ch, dl
	and	ch, cl
	mov	cl, 1
	cmp	ch, 1
	jne	LBB18_4
	cmp	dword [4*eax + playeringame], 0
	je	LBB18_4
	imul	eax, eax, 280
	cmp	dword [eax + players], 0
	sete	cl
LBB18_4:
	test	cl, cl
	jne	LBB18_22
	cmp	dword [menuactive], 0
	jne	LBB18_22
	cmp	dword [sendsave], 0
	jne	LBB18_22
	cmp	byte [savedescription], 0
	jne	LBB18_22
	cmp	dword [gameaction], 0
	jne	LBB18_22
	cmp	byte [save_checkpoint_requested], 1
	jne	LBB18_11
	mov	eax, dword [save_checkpoint_slot]
LBB18_15:
	push	checkpoint_save_slot_if_needed.description
	push	eax
	call	G_SaveGame
	add	esp, 8
	mov	byte [save_checkpoint_started], 1
	movzx	eax, byte [savedescription]
	test	eax, eax
	je	LBB18_16
	xor	eax, -2128831035
	imul	eax, eax, 16777619
	mov	ecx, 1
align 16
LBB18_18:
	movzx	edx, byte [ecx + savedescription]
	test	edx, edx
	je	LBB18_21
	xor	eax, edx
	imul	eax, eax, 16777619
	inc	ecx
	cmp	ecx, 32
	jne	LBB18_18
	mov	ecx, 32
	jmp	LBB18_21
LBB18_11:
	cmp	byte [save_checkpoint_request_checked], 0
	jne	LBB18_22
	mov	byte [save_checkpoint_request_checked], 1
	mov	dword [save_checkpoint_slot], 0
	lea	eax, [ebp - 48]
	push	eax
	push	L.str.4
	call	stat
	add	esp, 8
	test	eax, eax
	js	LBB18_31
	mov	eax, dword [ebp - 20]
	lea	ecx, [eax - 7]
	cmp	ecx, -6
	jae	LBB18_14
LBB18_31:
	mov	byte [save_checkpoint_requested], 0
	mov	byte [save_checkpoint_request_checked], 0
	jmp	LBB18_22
LBB18_16:
	xor	ecx, ecx
	xor	eax, eax
LBB18_21:
	mov	dword [save_checkpoint_desc_len], ecx
	mov	dword [save_checkpoint_desc_hash], eax
	call	report_save_action_status
LBB18_22:
	push	esi
	call	doom_original_G_BuildTiccmd
	add	esp, 4
	test	esi, esi
	je	LBB18_30
	cmp	dword [singletics], 0
	je	LBB18_30
	movzx	eax, byte [esi + 7]
	and	al, -125
	cmp	al, -126
	jne	LBB18_30
	mov	ecx, dword [ticdup]
	cmp	ecx, 2
	jge	LBB18_27
	mov	ecx, 1
LBB18_27:
	mov	eax, dword [gametic]
	cdq
	idiv	ecx
	mov	ecx, eax
	mov	edx, 715827883
	imul	edx
	mov	eax, edx
	shr	eax, 31
	shr	edx, 1
	add	edx, eax
	shl	edx, 2
	lea	edx, [edx + 2*edx]
	mov	eax, ecx
	sub	eax, edx
	jns	LBB18_29
	neg	edx
	lea	eax, [ecx + edx + 12]
LBB18_29:
	mov	ecx, dword [consoleplayer]
	lea	ecx, [ecx + 2*ecx]
	shl	ecx, 5
	mov	edx, dword [esi]
	mov	esi, dword [esi + 4]
	mov	dword [ecx + 8*eax + netcmds+4], esi
	mov	dword [ecx + 8*eax + netcmds], edx
LBB18_30:
	add	esp, 44
	pop	esi
	pop	ebp
	ret
LBB18_14:
	dec	eax
	mov	dword [save_checkpoint_slot], eax
	mov	byte [save_checkpoint_requested], 1
	jmp	LBB18_15
Lfunc_end18:
global G_Ticker
align 16
G_Ticker:
	push	ebp
	mov	ebp, esp
	push	ebx
	call	doom_original_G_Ticker
	movzx	edx, byte [save_checkpoint_started]
	not	dl
	movzx	eax, byte [save_checkpoint_promoted]
	movzx	ecx, byte [save_checkpoint_done]
	mov	ch, al
	or	ch, cl
	or	ch, dl
	not	ch
	mov	edx, dword [gameaction]
	cmp	edx, 4
	sete	bl
	mov	ah, byte [savedescription]
	test	ah, ah
	setne	bh
	and	bh, bl
	and	bh, ch
	cmp	bh, 1
	jne	LBB19_27
	mov	eax, dword [consoleplayer]
	cmp	eax, 3
	ja	LBB19_26
	lea	eax, [eax + 2*eax]
	shl	eax, 5
	movzx	ecx, byte [eax + netcmds+7]
	and	cl, -125
	cmp	cl, -126
	jne	LBB19_4
	lea	ecx, [eax + netcmds+7]
	mov	byte [ecx], 0
LBB19_4:
	movzx	ecx, byte [eax + netcmds+15]
	and	cl, -125
	cmp	cl, -126
	jne	LBB19_6
	lea	ecx, [eax + netcmds+15]
	mov	byte [ecx], 0
LBB19_6:
	movzx	ecx, byte [eax + netcmds+23]
	and	cl, -125
	cmp	cl, -126
	jne	LBB19_8
	lea	ecx, [eax + netcmds+23]
	mov	byte [ecx], 0
LBB19_8:
	movzx	ecx, byte [eax + netcmds+31]
	and	cl, -125
	cmp	cl, -126
	jne	LBB19_10
	lea	ecx, [eax + netcmds+31]
	mov	byte [ecx], 0
LBB19_10:
	movzx	ecx, byte [eax + netcmds+39]
	and	cl, -125
	cmp	cl, -126
	jne	LBB19_12
	lea	ecx, [eax + netcmds+39]
	mov	byte [ecx], 0
LBB19_12:
	movzx	ecx, byte [eax + netcmds+47]
	and	cl, -125
	cmp	cl, -126
	jne	LBB19_14
	lea	ecx, [eax + netcmds+47]
	mov	byte [ecx], 0
LBB19_14:
	movzx	ecx, byte [eax + netcmds+55]
	and	cl, -125
	cmp	cl, -126
	jne	LBB19_16
	lea	ecx, [eax + netcmds+55]
	mov	byte [ecx], 0
LBB19_16:
	movzx	ecx, byte [eax + netcmds+63]
	and	cl, -125
	cmp	cl, -126
	jne	LBB19_18
	lea	ecx, [eax + netcmds+63]
	mov	byte [ecx], 0
LBB19_18:
	movzx	ecx, byte [eax + netcmds+71]
	and	cl, -125
	cmp	cl, -126
	jne	LBB19_20
	lea	ecx, [eax + netcmds+71]
	mov	byte [ecx], 0
LBB19_20:
	movzx	ecx, byte [eax + netcmds+79]
	and	cl, -125
	cmp	cl, -126
	jne	LBB19_22
	lea	ecx, [eax + netcmds+79]
	mov	byte [ecx], 0
LBB19_22:
	movzx	ecx, byte [eax + netcmds+87]
	and	cl, -125
	cmp	cl, -126
	jne	LBB19_24
	lea	ecx, [eax + netcmds+87]
	mov	byte [ecx], 0
LBB19_24:
	movzx	ecx, byte [eax + netcmds+95]
	and	cl, -125
	cmp	cl, -126
	jne	LBB19_26
	lea	eax, [eax + netcmds+95]
	mov	byte [eax], 0
LBB19_26:
	mov	byte [save_checkpoint_promoted], 1
LBB19_42:
	pop	ebx
	pop	ebp
	jmp	report_save_action_status
LBB19_27:
	cmp	dword [sendsave], 0
	sete	ch
	not	cl
	and	al, cl
	and	al, ch
	test	ah, ah
	sete	cl
	test	edx, edx
	sete	dl
	and	dl, cl
	and	dl, al
	cmp	dl, 1
	jne	LBB19_29
	mov	byte [save_checkpoint_done], 1
	call	report_save_action_status
LBB19_29:
	cmp	byte [load_checkpoint_started], 1
	jne	LBB19_43
	test	byte [load_checkpoint_done], 1
	jne	LBB19_43
	mov	eax, dword [gamestate]
	or	eax, dword [gameaction]
	sete	dh
	mov	eax, dword [leveltime]
	cmp	eax, 32
	setge	bl
	mov	ecx, dword [consoleplayer]
	cmp	ecx, 4
	setb	dl
	and	dl, bl
	and	dl, dh
	cmp	byte [load_checkpoint_post_tic_pending], 0
	je	LBB19_32
	test	dl, dl
	je	LBB19_43
	cmp	dword [4*ecx + playeringame], 0
	je	LBB19_43
	imul	ecx, ecx, 280
	cmp	dword [ecx + players], 0
	je	LBB19_43
	cmp	eax, dword [load_checkpoint_post_tic_leveltime]
	jle	LBB19_43
	mov	eax, dword [gametic]
	cmp	eax, dword [load_checkpoint_post_tic_gametic]
	je	LBB19_43
	mov	byte [load_checkpoint_done], 1
	jmp	LBB19_42
LBB19_32:
	test	dl, dl
	je	LBB19_43
	cmp	dword [4*ecx + playeringame], 0
	je	LBB19_43
	imul	ecx, ecx, 280
	cmp	dword [ecx + players], 0
	je	LBB19_43
	mov	byte [load_checkpoint_post_tic_pending], 1
	mov	dword [load_checkpoint_post_tic_leveltime], eax
	mov	eax, dword [gametic]
	mov	dword [load_checkpoint_post_tic_gametic], eax
	jmp	LBB19_42
LBB19_43:
	pop	ebx
	pop	ebp
	ret
Lfunc_end19:
align 16
report_save_action_status:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	xor	ebx, ebx
	cmp	dword [sendsave], 0
	setne	bl
	cmp	dword [menuactive], 0
	je	LBB20_2
	or	ebx, 2
LBB20_2:
	movzx	eax, byte [save_checkpoint_started]
	or	al, byte [save_checkpoint_requested]
	movzx	ecx, al
	and	ecx, 1
	neg	ecx
	and	ecx, 8
	movzx	edx, byte [save_checkpoint_done]
	test	dl, dl
	jne	LBB20_3
	or	ebx, ecx
	jmp	LBB20_5
LBB20_3:
	lea	ebx, [ebx + ecx + 16]
LBB20_5:
	mov	ah, byte [load_checkpoint_started]
	or	ah, byte [load_checkpoint_requested]
	movzx	ecx, ah
	and	ecx, 1
	neg	ecx
	and	ecx, 32
	or	ecx, ebx
	mov	dh, byte [load_checkpoint_done]
	test	dh, dh
	je	LBB20_7
	or	ecx, 64
LBB20_7:
	movzx	esi, byte [savedescription]
	test	esi, esi
	je	LBB20_12
	xor	esi, -2128831035
	imul	esi, esi, 16777619
	mov	edi, 1
align 16
LBB20_9:
	movzx	ebx, byte [edi + savedescription]
	test	ebx, ebx
	je	LBB20_15
	xor	esi, ebx
	imul	esi, esi, 16777619
	inc	edi
	cmp	edi, 32
	jne	LBB20_9
	mov	edi, 32
	jmp	LBB20_15
LBB20_12:
	mov	edi, dword [save_checkpoint_desc_len]
	test	edi, edi
	je	LBB20_13
	mov	esi, dword [save_checkpoint_desc_hash]
LBB20_15:
	or	ecx, 4
LBB20_16:
	or	al, dl
	or	ah, dh
	test	ah, 1
	jne	LBB20_17
	mov	edx, dword [savegameslot]
	test	al, 1
	jne	LBB20_20
	jmp	LBB20_21
LBB20_17:
	mov	edx, dword [load_checkpoint_slot]
	test	al, 1
	je	LBB20_21
LBB20_20:
	mov	edx, dword [save_checkpoint_slot]
LBB20_21:
	mov	eax, dword [gameaction]
	shl	eax, 8
	movzx	eax, ax
	or	ecx, eax
	movzx	eax, dl
	shl	eax, 16
	or	eax, ecx
	or	eax, 268435456
	push	edi
	push	esi
	push	eax
	push	15
	call	vibe_syscall3
	add	esp, 16
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
LBB20_13:
	xor	esi, esi
	xor	edi, edi
	jmp	LBB20_16
Lfunc_end20:
global I_FinishUpdate
align 16
I_FinishUpdate:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 64
	push	0
	push	0
	push	1073742080
	push	15
	call	vibe_syscall3
	add	esp, 16
	call	pump_music_stream
	mov	edx, dword [gametic]
	xor	eax, eax
	cmp	dword [menuactive], 0
	setne	byte [ebp - 17]
	mov	ecx, dword [leveltime]
	test	ecx, ecx
	mov	edi, ecx
	jg	LBB21_2
	mov	edi, edx
LBB21_2:
	mov	esi, dword [gameepisode]
	mov	ebx, dword [gamemap]
	test	edx, edx
	je	LBB21_4
	mov	edi, edx
LBB21_4:
	mov	dword [ebp - 16], edi
	movzx	edx, byte [gamestate]
	shl	esi, 8
	movzx	esi, si
	movzx	edi, bl
	movzx	ebx, byte [ebp - 17]
	mov	al, bl
	shl	eax, 24
	cmp	dword [automapactive], 0
	je	LBB21_6
	or	eax, 33554432
LBB21_6:
	or	esi, edx
	shl	edi, 16
	cmp	dword [paused], 0
	je	LBB21_8
	or	eax, 67108864
LBB21_8:
	or	esi, edi
	cmp	dword [singletics], 0
	je	LBB21_10
	or	eax, 134217728
LBB21_10:
	mov	edx, dword [ebp - 16]
	or	esi, eax
	push	ecx
	push	edx
	push	esi
	push	15
	call	vibe_syscall3
	add	esp, 16
	mov	byte [ebp - 20], 0
	mov	dword [ebp - 24], 1735615534
	mov	dword [ebp - 28], 813064563
	mov	dword [ebp - 32], 1836019556
	cmp	byte [load_checkpoint_done], 0
	jne	LBB21_27
	cmp	byte [load_checkpoint_started], 0
	jne	LBB21_27
	cmp	dword [gamestate], 0
	sete	al
	cmp	dword [gameepisode], 0
	setg	cl
	cmp	dword [gamemap], 0
	setg	dl
	and	dl, cl
	cmp	dword [gametic], 0
	setg	cl
	and	cl, al
	and	cl, dl
	cmp	dword [leveltime], 32
	setge	dl
	mov	eax, dword [consoleplayer]
	cmp	eax, 4
	setb	ch
	and	ch, dl
	and	ch, cl
	mov	cl, 1
	cmp	ch, 1
	jne	LBB21_15
	cmp	dword [4*eax + playeringame], 0
	je	LBB21_15
	imul	eax, eax, 280
	cmp	dword [eax + players], 0
	sete	cl
LBB21_15:
	test	cl, cl
	jne	LBB21_27
	cmp	dword [menuactive], 0
	jne	LBB21_27
	cmp	dword [sendsave], 0
	jne	LBB21_27
	cmp	byte [savedescription], 0
	jne	LBB21_27
	cmp	dword [gameaction], 0
	jne	LBB21_27
	cmp	byte [load_checkpoint_requested], 1
	jne	LBB21_22
	mov	eax, dword [load_checkpoint_slot]
LBB21_26:
	mov	ecx, eax
	add	cl, 48
	mov	byte [ebp - 25], cl
	mov	dword [savegameslot], eax
	mov	byte [load_checkpoint_started], 1
	mov	byte [load_checkpoint_post_tic_pending], 0
	call	report_save_action_status
	lea	eax, [ebp - 32]
	push	eax
	call	G_LoadGame
	add	esp, 4
	jmp	LBB21_27
LBB21_22:
	cmp	byte [load_checkpoint_request_checked], 0
	jne	LBB21_27
	mov	byte [load_checkpoint_request_checked], 1
	mov	dword [load_checkpoint_slot], 0
	lea	eax, [ebp - 76]
	push	eax
	push	L.str.5
	call	stat
	add	esp, 8
	test	eax, eax
	js	LBB21_101
	mov	eax, dword [ebp - 48]
	lea	ecx, [eax - 7]
	cmp	ecx, -6
	jae	LBB21_25
LBB21_101:
	mov	byte [load_checkpoint_requested], 0
	mov	byte [load_checkpoint_request_checked], 0
LBB21_27:
	call	report_save_action_status
	cmp	dword [menuactive], 0
	je	LBB21_29
	or	byte [playable_proof_flags], 16
LBB21_29:
	mov	eax, dword [gameaction]
	mov	edx, dword [consoleplayer]
	cmp	edx, 4
	jae	LBB21_30
	cmp	dword [4*edx + playeringame], 0
	mov	ecx, dword [playable_proof_flags]
	je	LBB21_32
	imul	ebx, edx, 280
	lea	esi, [ebx + players]
	mov	edi, ecx
	or	edi, 1
	mov	dword [playable_proof_flags], edi
	movzx	edx, byte [ebx + players+15]
	cmp	byte [ebx + players+8], 0
	jne	LBB21_36
	cmp	byte [esi + 9], 0
	je	LBB21_37
LBB21_36:
	or	ecx, 3
	mov	dword [playable_proof_flags], ecx
	mov	edi, ecx
LBB21_37:
	cmp	word [esi + 10], 0
	sete	bl
	je	LBB21_39
	or	edi, 256
LBB21_39:
	lea	ecx, [4*edx]
	and	ecx, 12
	or	ecx, edi
	test	dl, 3
	sete	bh
	test	bh, bl
	jne	LBB21_41
	mov	dword [playable_proof_flags], ecx
LBB21_41:
	cmp	dword [esi + 200], 0
	jle	LBB21_43
	or	ecx, 128
	mov	dword [playable_proof_flags], ecx
LBB21_43:
	mov	edi, dword [playable_initial_clip]
	test	edi, edi
	mov	ebx, dword [esi + 156]
	js	LBB21_44
	cmp	ebx, edi
	je	LBB21_47
	or	ecx, 64
	mov	dword [playable_proof_flags], ecx
	jmp	LBB21_47
LBB21_30:
	xor	esi, esi
	mov	ecx, dword [playable_proof_flags]
	jmp	LBB21_33
LBB21_32:
	xor	esi, esi
LBB21_33:
	xor	edi, edi
	xor	edx, edx
	jmp	LBB21_58
LBB21_44:
	mov	dword [playable_initial_clip], ebx
LBB21_47:
	mov	ebx, dword [esi]
	test	ebx, ebx
	je	LBB21_48
	mov	esi, dword [ebx + 12]
	mov	edi, dword [ebx + 16]
	cmp	byte [playable_origin_set], 0
	mov	dword [ebp - 16], edx
	je	LBB21_50
	cmp	esi, dword [playable_origin_x]
	jne	LBB21_53
	cmp	edi, dword [playable_origin_y]
	je	LBB21_54
LBB21_53:
	or	ecx, 32
	mov	dword [playable_proof_flags], ecx
	jmp	LBB21_54
LBB21_48:
	xor	esi, esi
	xor	edi, edi
	jmp	LBB21_57
LBB21_50:
	mov	byte [playable_origin_set], 1
	mov	dword [playable_origin_x], esi
	mov	dword [playable_origin_y], edi
	mov	edx, dword [ebx + 32]
	mov	dword [playable_origin_angle], edx
LBB21_54:
	mov	edx, dword [ebx + 32]
	cmp	edx, dword [playable_origin_angle]
	je	LBB21_56
	or	ecx, 256
	mov	dword [playable_proof_flags], ecx
LBB21_56:
	mov	edx, dword [ebp - 16]
LBB21_57:
	shl	edx, 16
LBB21_58:
	or	ecx, edx
	shl	eax, 24
	or	eax, ecx
	or	eax, -2147483648
	push	edi
	push	esi
	push	eax
	push	15
	call	vibe_syscall3
	add	esp, 16
	mov	eax, dword [consoleplayer]
	cmp	eax, 3
	ja	LBB21_62
	cmp	dword [4*eax + playeringame], 0
	je	LBB21_62
	imul	ecx, eax, 280
	mov	eax, dword [ecx + players]
	test	eax, eax
	je	LBB21_62
	lea	edx, [ecx + players]
	movzx	ecx, byte [edx + 15]
	movzx	esi, byte [edx + 8]
	shl	esi, 8
	or	esi, ecx
	movzx	ecx, byte [edx + 9]
	shl	ecx, 16
	or	ecx, esi
	movzx	edi, word [edx + 156]
	mov	esi, dword [edx + 112]
	mov	edx, dword [edx + 200]
	movzx	edx, dl
	shl	edx, 16
	or	edx, edi
	shl	esi, 24
	or	esi, edx
	push	esi
	push	dword [eax + 32]
	push	ecx
	push	26
	call	vibe_syscall3
	add	esp, 16
LBB21_62:
	cmp	byte [default_config_checkpoint_checked], 0
	jne	LBB21_98
	cmp	dword [defaultfile], 0
	je	LBB21_98
	cmp	dword [gamestate], 0
	sete	al
	cmp	dword [gameepisode], 0
	setg	cl
	cmp	dword [gamemap], 0
	setg	dl
	and	dl, cl
	cmp	dword [gametic], 0
	setg	cl
	and	cl, al
	and	cl, dl
	cmp	dword [leveltime], 32
	setge	dl
	mov	eax, dword [consoleplayer]
	cmp	eax, 4
	setb	ch
	and	ch, dl
	and	ch, cl
	cmp	ch, 1
	jne	LBB21_98
	cmp	dword [4*eax + playeringame], 0
	je	LBB21_98
	imul	eax, eax, 280
	cmp	dword [eax + players], 0
	je	LBB21_98
	movzx	eax, byte [default_config_checkpoint_request_checked]
	movzx	ecx, byte [default_config_checkpoint_requested]
	mov	edx, eax
	or	dl, cl
	test	dl, 1
	je	LBB21_68
	not	al
	or	al, cl
	test	al, 1
	jne	LBB21_72
	jmp	LBB21_98
LBB21_68:
	mov	byte [default_config_checkpoint_request_checked], 1
	lea	eax, [ebp - 76]
	push	eax
	push	L.str.3
	call	stat
	add	esp, 8
	test	eax, eax
	je	LBB21_70
	cmp	byte [default_config_checkpoint_requested], 0
	jne	LBB21_72
	jmp	LBB21_98
LBB21_70:
	mov	byte [default_config_checkpoint_requested], 1
LBB21_72:
	mov	byte [default_config_checkpoint_checked], 1
	mov	ecx, dword [defaultfile]
	test	ecx, ecx
	mov	eax, L.str.6
	je	LBB21_74
	mov	eax, ecx
LBB21_74:
	push	L.str.7
	push	eax
	call	fopen
	add	esp, 8
	test	eax, eax
	je	LBB21_97
	push	eax
	push	16384
	push	1
	push	default_config_check_buffer
	mov	esi, eax
	call	fread
	add	esp, 16
	mov	edi, eax
	push	esi
	call	fclose
	add	esp, 4
	mov	byte [edi + default_config_check_buffer], 0
	mov	dword [ebp - 16], edi
	test	edi, edi
	je	LBB21_97
	mov	eax, dword [ebp - 16]
	cmp	byte [eax + default_config_check_buffer-1], 10
	jne	LBB21_97
	push	L.str.8
	call	strlen
	add	esp, 4
	test	eax, eax
	je	LBB21_82
	mov	edi, eax
	mov	ebx, dword [ebp - 16]
	sub	ebx, eax
	jb	LBB21_97
	xor	esi, esi
LBB21_81:
	lea	eax, [esi + default_config_check_buffer]
	push	edi
	push	L.str.8
	push	eax
	call	memcmp
	add	esp, 12
	test	eax, eax
	je	LBB21_82
	inc	esi
	cmp	esi, ebx
	jbe	LBB21_81
	jmp	LBB21_97
LBB21_25:
	dec	eax
	mov	dword [load_checkpoint_slot], eax
	mov	byte [load_checkpoint_requested], 1
	jmp	LBB21_26
LBB21_82:
	push	L.str.9
	call	strlen
	add	esp, 4
	test	eax, eax
	je	LBB21_87
	mov	edi, eax
	mov	ebx, dword [ebp - 16]
	sub	ebx, eax
	jb	LBB21_97
	xor	esi, esi
LBB21_86:
	lea	eax, [esi + default_config_check_buffer]
	push	edi
	push	L.str.9
	push	eax
	call	memcmp
	add	esp, 12
	test	eax, eax
	je	LBB21_87
	inc	esi
	cmp	esi, ebx
	jbe	LBB21_86
	jmp	LBB21_97
LBB21_87:
	push	L.str.10
	call	strlen
	add	esp, 4
	test	eax, eax
	je	LBB21_92
	mov	edi, eax
	mov	ebx, dword [ebp - 16]
	sub	ebx, eax
	jb	LBB21_97
	xor	esi, esi
LBB21_91:
	lea	eax, [esi + default_config_check_buffer]
	push	edi
	push	L.str.10
	push	eax
	call	memcmp
	add	esp, 12
	test	eax, eax
	je	LBB21_92
	inc	esi
	cmp	esi, ebx
	jbe	LBB21_91
	jmp	LBB21_97
LBB21_92:
	push	L.str.11
	call	strlen
	add	esp, 4
	test	eax, eax
	je	LBB21_98
	mov	edi, eax
	sub	dword [ebp - 16], eax
	jb	LBB21_97
	xor	esi, esi
LBB21_96:
	lea	eax, [esi + default_config_check_buffer]
	push	edi
	push	L.str.11
	push	eax
	call	memcmp
	add	esp, 12
	test	eax, eax
	je	LBB21_98
	inc	esi
	cmp	esi, dword [ebp - 16]
	jbe	LBB21_96
LBB21_97:
	call	M_SaveDefaults
LBB21_98:
	mov	eax, dword [screens]
	test	eax, eax
	je	LBB21_100
	mov	dword [ebp - 76], eax
	mov	dword [ebp - 72], active_palette
	mov	dword [ebp - 68], 320
	mov	dword [ebp - 64], 200
	lea	eax, [ebp - 76]
	push	eax
	call	vibe_present_indexed_checked
	add	esp, 4
LBB21_100:
	add	esp, 64
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
Lfunc_end21:
global I_WaitVBL
align 16
I_WaitVBL:
	push	ebp
	mov	ebp, esp
	pop	ebp
	ret
Lfunc_end22:
global I_ReadScreen
align 16
I_ReadScreen:
	mov	eax, dword [screens]
	test	eax, eax
	je	LBB23_2
	push	ebp
	mov	ebp, esp
	push	64000
	push	eax
	push	dword [ebp + 8]
	call	memcpy
	add	esp, 12
	pop	ebp
LBB23_2:
	ret
Lfunc_end23:
global I_BeginRead
align 16
I_BeginRead:
	push	ebp
	mov	ebp, esp
	pop	ebp
	ret
Lfunc_end24:
global I_EndRead
align 16
I_EndRead:
	push	ebp
	mov	ebp, esp
	pop	ebp
	ret
Lfunc_end25:
global I_InitNetwork
align 16
I_InitNetwork:
	push	ebp
	mov	ebp, esp
	push	0
	push	0
	push	1073741832
	push	15
	call	vibe_syscall3
	add	esp, 16
	push	140
	push	0
	push	local_doomcom
	call	memset
	add	esp, 12
	mov	dword [singletics], 1
	mov	dword [local_doomcom], 305419896
	mov	dword [local_doomcom+12], 65537
	mov	word [local_doomcom+16], 0
	mov	dword [local_doomcom+28], 65536
	mov	dword [doomcom], local_doomcom
	mov	dword [netgame], 0
	pop	ebp
	ret
Lfunc_end26:
global I_NetCmd
align 16
I_NetCmd:
	mov	eax, dword [doomcom]
	test	eax, eax
	je	LBB27_2
	push	ebp
	mov	ebp, esp
	mov	word [eax + 8], -1
	pop	ebp
LBB27_2:
	ret
Lfunc_end27:
global I_InitSound
align 16
I_InitSound:
	push	ebp
	mov	ebp, esp
	push	0
	push	0
	push	1073741840
	push	15
	call	vibe_syscall3
	add	esp, 16
	call	vibe_music_init
	pop	ebp
	jmp	vibe_audio_device_start
Lfunc_end28:
global I_UpdateSound
align 16
I_UpdateSound:
	push	ebp
	mov	ebp, esp
	pop	ebp
	jmp	pump_music_stream
Lfunc_end29:
global I_SubmitSound
align 16
I_SubmitSound:
	push	ebp
	mov	ebp, esp
	pop	ebp
	jmp	pump_music_stream
Lfunc_end30:
global I_SetChannels
align 16
I_SetChannels:
	push	ebp
	mov	ebp, esp
	push	0
	push	0
	push	1073741840
	push	15
	call	vibe_syscall3
	add	esp, 16
	pop	ebp
	ret
Lfunc_end31:
global I_GetSfxLumpNum
align 16
I_GetSfxLumpNum:
	push	ebp
	mov	ebp, esp
	sub	esp, 12
	mov	eax, dword [ebp + 8]
	mov	word [ebp - 9], 29540
	lea	ecx, [ebp - 7]
	push	6
	push	dword [eax]
	push	ecx
	call	strncpy
	add	esp, 12
	mov	byte [ebp - 1], 0
	lea	eax, [ebp - 9]
	push	eax
	call	W_CheckNumForName
	add	esp, 4
	test	eax, eax
	jns	LBB32_2
	push	L.str.2
	call	W_GetNumForName
	add	esp, 4
LBB32_2:
	add	esp, 12
	pop	ebp
	ret
Lfunc_end32:
global I_StartSound
align 16
I_StartSound:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 88
	mov	edx, dword [ebp + 8]
	mov	eax, dword [next_sound_handle]
	mov	dword [ebp - 36], eax
	inc	eax
	mov	dword [next_sound_handle], eax
	lea	ecx, [4*edx]
	mov	eax, S_sfx
	mov	esi, dword [ecx + 8*ecx + S_sfx+12]
	test	esi, esi
	jne	LBB33_2
	lea	esi, [ecx + 8*ecx + S_sfx]
LBB33_2:
	mov	ecx, esi
	sub	ecx, eax
	lea	eax, [ecx - 1]
	cmp	eax, 3923
	jae	LBB33_3
	cmp	esi, S_sfx
	je	LBB33_4
	movzx	eax, cx
	shr	eax, 2
	imul	eax, eax, -29127
	movzx	edx, ax
	jmp	LBB33_7
LBB33_3:
	lea	eax, [edx - 1]
	cmp	eax, 108
	jae	LBB33_4
LBB33_7:
	mov	edi, dword [4*edx + cached_sfx_samples]
	test	edi, edi
	je	LBB33_9
	mov	eax, dword [4*edx + cached_sfx_lengths]
	mov	dword [ebp - 16], eax
	mov	eax, dword [4*edx + cached_sfx_rates]
	mov	dword [ebp - 20], eax
	mov	ebx, dword [4*edx + cached_sfx_flags]
	jmp	LBB33_21
LBB33_9:
	mov	edi, edx
	mov	eax, dword [esi + 32]
	test	eax, eax
	js	LBB33_10
	cmp	dword [esi + 24], 0
	je	LBB33_14
LBB33_15:
	push	eax
	call	W_LumpLength
	add	esp, 4
	mov	ebx, dword [esi + 24]
	cmp	eax, 9
	setge	cl
	test	ebx, ebx
	setne	dl
	and	dl, cl
	cmp	dl, 1
	jne	LBB33_4
	mov	dword [ebp - 32], edi
	lea	ecx, [eax - 8]
	mov	dword [ebp - 24], ecx
	lea	esi, [eax + 503]
	and	esi, -512
	movzx	ecx, word [ebx + 2]
	test	cx, cx
	mov	edx, 11025
	je	LBB33_18
	mov	edx, ecx
LBB33_18:
	movzx	ecx, dx
	mov	dword [ebp - 20], ecx
	mov	ecx, dword [ebx + 4]
	cmp	word [ebx], 3
	sete	dl
	test	ecx, ecx
	setne	dh
	and	dh, dl
	add	eax, 504
	cmp	ecx, eax
	setbe	al
	and	al, dh
	movzx	eax, al
	shl	eax, 2
	mov	dword [ebp - 28], eax
	push	0
	push	1
	push	esi
	call	Z_Malloc
	add	esp, 12
	mov	dword [ebp - 16], esi
	mov	edi, eax
	add	ebx, 8
	mov	esi, dword [ebp - 24]
	push	esi
	push	ebx
	push	eax
	call	memcpy
	add	esp, 12
	mov	eax, dword [ebp - 16]
	mov	ebx, eax
	sub	eax, esi
	jbe	LBB33_20
	mov	ecx, edi
	add	ecx, esi
	push	eax
	push	128
	push	ecx
	call	memset
	add	esp, 12
LBB33_20:
	mov	esi, dword [ebp - 32]
	mov	dword [4*esi + cached_sfx_samples], edi
	mov	dword [4*esi + cached_sfx_lengths], ebx
	mov	eax, dword [ebp - 20]
	mov	dword [4*esi + cached_sfx_rates], eax
	mov	ebx, dword [ebp - 28]
	mov	dword [4*esi + cached_sfx_flags], ebx
	jmp	LBB33_21
LBB33_4:
	mov	dword [ebp - 16], 0
	mov	dword [ebp - 20], 11025
	xor	ebx, ebx
	xor	edi, edi
LBB33_21:
	lea	esi, [ebp - 100]
	push	64
	push	0
	push	esi
	call	memset
	add	esp, 12
	mov	dword [ebp - 100], edi
	mov	eax, dword [ebp - 16]
	mov	dword [ebp - 96], eax
	mov	eax, dword [ebp + 12]
	movzx	eax, al
	mov	dword [ebp - 92], eax
	mov	eax, dword [ebp + 16]
	movzx	eax, al
	mov	dword [ebp - 88], eax
	mov	eax, dword [ebp + 20]
	movzx	eax, al
	mov	dword [ebp - 84], eax
	mov	eax, dword [ebp + 8]
	mov	dword [ebp - 80], eax
	mov	dword [ebp - 76], ebx
	mov	eax, dword [ebp - 20]
	mov	dword [ebp - 72], eax
	push	esi
	mov	esi, dword [ebp - 36]
	push	esi
	call	vibe_audio_mixer_start
	add	esp, 8
	mov	eax, esi
	add	esp, 88
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
LBB33_10:
	mov	word [ebp - 100], 29540
	lea	eax, [ebp - 98]
	push	6
	push	dword [esi]
	push	eax
	call	strncpy
	add	esp, 12
	mov	byte [ebp - 92], 0
	lea	eax, [ebp - 100]
	push	eax
	call	W_CheckNumForName
	add	esp, 4
	test	eax, eax
	jns	LBB33_12
	push	L.str.2
	call	W_GetNumForName
	add	esp, 4
LBB33_12:
	mov	dword [esi + 32], eax
	cmp	dword [esi + 24], 0
	jne	LBB33_15
LBB33_14:
	push	1
	push	eax
	call	W_CacheLumpNum
	add	esp, 8
	mov	dword [esi + 24], eax
	mov	eax, dword [esi + 32]
	jmp	LBB33_15
Lfunc_end33:
global I_StopSound
align 16
I_StopSound:
	push	ebp
	mov	ebp, esp
	pop	ebp
	jmp	vibe_audio_mixer_stop
Lfunc_end34:
global I_SoundIsPlaying
align 16
I_SoundIsPlaying:
	push	ebp
	mov	ebp, esp
	push	dword [ebp + 8]
	call	vibe_audio_mixer_is_playing
	add	esp, 4
	xor	ecx, ecx
	test	eax, eax
	setg	cl
	mov	eax, ecx
	pop	ebp
	ret
Lfunc_end35:
global I_UpdateSoundParams
align 16
I_UpdateSoundParams:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 64
	movzx	edi, byte [ebp + 20]
	movzx	ebx, byte [ebp + 16]
	movzx	esi, byte [ebp + 12]
	lea	eax, [ebp - 76]
	push	64
	push	0
	push	eax
	call	memset
	add	esp, 12
	mov	dword [ebp - 68], esi
	mov	dword [ebp - 64], ebx
	mov	dword [ebp - 60], edi
	lea	eax, [ebp - 76]
	push	eax
	push	dword [ebp + 8]
	call	vibe_audio_mixer_update
	add	esp, 72
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
Lfunc_end36:
global I_InitMusic
align 16
I_InitMusic:
	push	ebp
	mov	ebp, esp
	pop	ebp
	jmp	vibe_music_init
Lfunc_end37:
global I_SetMusicVolume
align 16
I_SetMusicVolume:
	push	ebp
	mov	ebp, esp
	mov	ecx, dword [ebp + 8]
	test	ecx, ecx
	mov	eax, ecx
	jle	LBB38_1
	cmp	ecx, 16
	jl	LBB38_3
LBB38_4:
	cmp	eax, 127
	jb	LBB38_6
LBB38_5:
	mov	eax, 127
LBB38_6:
	mov	dword [current_music_volume], eax
	mov	ecx, dword [current_music_handle]
	test	ecx, ecx
	jle	LBB38_8
	push	eax
	push	ecx
	call	vibe_music_stream_set_volume
	add	esp, 8
LBB38_8:
	pop	ebp
	ret
LBB38_1:
	xor	eax, eax
	cmp	ecx, 16
	jge	LBB38_4
LBB38_3:
	lea	eax, [8*eax + 7]
	cmp	eax, 127
	jae	LBB38_5
	jmp	LBB38_6
Lfunc_end38:
global I_PauseSong
align 16
I_PauseSong:
	push	ebp
	mov	ebp, esp
	mov	eax, dword [ebp + 8]
	test	eax, eax
	jle	LBB39_2
	mov	byte [current_music_paused], 1
	movzx	eax, ax
	or	eax, 1297416192
	push	eax
	call	vibe_audio_mixer_stop
	add	esp, 4
LBB39_2:
	pop	ebp
	ret
Lfunc_end39:
global I_ResumeSong
align 16
I_ResumeSong:
	push	ebp
	mov	ebp, esp
	cmp	dword [ebp + 8], 0
	jle	LBB40_2
	test	byte [current_music_paused], 1
	je	LBB40_2
	mov	byte [current_music_paused], 0
	mov	dword [current_music_next_tic], 0
	pop	ebp
	jmp	pump_music_stream
LBB40_2:
	pop	ebp
	ret
Lfunc_end40:
global I_RegisterSong
align 16
I_RegisterSong:
	push	ebp
	mov	ebp, esp
	pop	ebp
	jmp	vibe_music_register_song
Lfunc_end41:
global I_PlaySong
align 16
I_PlaySong:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	mov	esi, dword [ebp + 8]
	test	esi, esi
	jle	LBB42_4
	mov	edi, dword [ebp + 12]
	mov	ebx, dword [current_music_handle]
	test	ebx, ebx
	setle	al
	cmp	ebx, esi
	sete	cl
	or	cl, al
	jne	LBB42_3
	movzx	eax, bx
	or	eax, 1297416192
	push	eax
	call	vibe_audio_mixer_stop
	add	esp, 4
	push	ebx
	call	vibe_music_stream_stop
	add	esp, 4
LBB42_3:
	mov	dword [current_music_handle], esi
	mov	dword [current_music_looping], edi
	mov	byte [current_music_paused], 0
	mov	dword [current_music_next_tic], 0
	mov	dword [current_music_pull_seen], 0
	mov	dword [current_music_refill_seen], 0
	mov	dword [current_music_under_seen], 0
	mov	dword [current_music_drop_seen], 0
	push	edi
	push	dword [current_music_volume]
	push	11025
	push	esi
	call	vibe_music_stream_begin
	add	esp, 16
LBB42_4:
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
Lfunc_end42:
global I_StopSong
align 16
I_StopSong:
	push	ebp
	mov	ebp, esp
	push	esi
	mov	esi, dword [ebp + 8]
	test	esi, esi
	jle	LBB43_3
	movzx	eax, si
	or	eax, 1297416192
	push	eax
	call	vibe_audio_mixer_stop
	add	esp, 4
	push	esi
	call	vibe_music_stream_stop
	add	esp, 4
	cmp	dword [current_music_handle], esi
	jne	LBB43_3
	mov	dword [current_music_handle], 0
	mov	dword [current_music_looping], 0
	mov	byte [current_music_paused], 0
	mov	dword [current_music_next_tic], 0
	mov	dword [current_music_pull_seen], 0
	mov	dword [current_music_refill_seen], 0
	mov	dword [current_music_under_seen], 0
	mov	dword [current_music_drop_seen], 0
LBB43_3:
	pop	esi
	pop	ebp
	ret
Lfunc_end43:
global I_UnRegisterSong
align 16
I_UnRegisterSong:
	push	ebp
	mov	ebp, esp
	push	esi
	mov	esi, dword [ebp + 8]
	test	esi, esi
	jle	LBB44_4
	cmp	esi, dword [current_music_handle]
	jne	LBB44_4
	movzx	eax, si
	or	eax, 1297416192
	push	eax
	call	vibe_audio_mixer_stop
	add	esp, 4
	push	esi
	call	vibe_music_stream_stop
	add	esp, 4
	cmp	dword [current_music_handle], esi
	jne	LBB44_4
	mov	dword [current_music_handle], 0
	mov	dword [current_music_looping], 0
	mov	byte [current_music_paused], 0
	mov	dword [current_music_next_tic], 0
	mov	dword [current_music_pull_seen], 0
	mov	dword [current_music_refill_seen], 0
	mov	dword [current_music_under_seen], 0
	mov	dword [current_music_drop_seen], 0
LBB44_4:
	pop	esi
	pop	ebp
	jmp	vibe_music_unregister_song
Lfunc_end44:
align 16
submit_music_stream_chunk:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 164
	mov	esi, ecx
	mov	ebx, dword [current_music_buffer]
	xor	ebx, 1
	mov	eax, ebx
	shl	eax, 15
	lea	eax, [eax + music_pcm]
	lea	ecx, [ebp - 176]
	push	ecx
	push	32768
	push	eax
	push	esi
	call	vibe_music_stream_render
	add	esp, 16
	test	eax, eax
	je	LBB45_1
	mov	edi, eax
	mov	dword [current_music_buffer], ebx
	lea	ebx, [ebp - 76]
	push	64
	push	0
	push	ebx
	call	memset
	add	esp, 12
	mov	eax, dword [current_music_buffer]
	shl	eax, 15
	lea	eax, [eax + music_pcm]
	mov	dword [ebp - 76], eax
	mov	dword [ebp - 72], edi
	mov	dword [ebp - 68], 127
	mov	dword [ebp - 64], 128
	mov	dword [ebp - 60], 128
	mov	dword [ebp - 56], 1297437513
	mov	dword [ebp - 52], 2
	cmp	dword [current_music_looping], 0
	setne	cl
	mov	eax, dword [ebp - 100]
	mov	edx, dword [ebp - 96]
	test	edx, edx
	sete	ch
	or	ch, cl
	cmp	eax, edx
	setb	cl
	or	cl, ch
	jne	LBB45_5
	mov	dword [ebp - 52], 10
LBB45_5:
	mov	dword [ebp - 48], 11025
	mov	ecx, dword [ebp - 176]
	mov	edx, dword [ebp - 168]
	mov	dword [ebp - 44], ecx
	add	edx, dword [ebp - 172]
	mov	dword [ebp - 40], edx
	mov	ecx, dword [ebp - 160]
	add	ecx, dword [ebp - 164]
	add	ecx, dword [ebp - 156]
	add	ecx, dword [ebp - 152]
	add	ecx, dword [ebp - 148]
	add	ecx, dword [ebp - 144]
	add	ecx, dword [ebp - 128]
	add	ecx, dword [ebp - 124]
	add	ecx, dword [ebp - 136]
	mov	dword [ebp - 36], ecx
	mov	ecx, dword [ebp - 132]
	mov	dword [ebp - 32], ecx
	mov	ecx, dword [ebp - 108]
	mov	edx, dword [ebp - 104]
	mov	dword [ebp - 28], ecx
	mov	dword [ebp - 24], edx
	mov	dword [ebp - 20], eax
	mov	eax, dword [ebp - 88]
	mov	dword [ebp - 16], eax
	movzx	eax, si
	or	eax, 1297416192
	push	ebx
	push	eax
	call	vibe_audio_stream_write
	add	esp, 8
	mov	eax, 1
	jmp	LBB45_6
LBB45_1:
	xor	eax, eax
	cmp	dword [current_music_handle], esi
	jne	LBB45_6
	movzx	eax, si
	or	eax, 1297416192
	push	eax
	call	vibe_audio_mixer_stop
	add	esp, 4
	mov	dword [current_music_handle], 0
	mov	dword [current_music_next_tic], 0
	push	esi
	call	vibe_music_stream_stop
	xor	eax, eax
	add	esp, 4
LBB45_6:
	add	esp, 164
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
Lfunc_end45:
section .data
global mb_used
align 4
mb_used:
dd 8
section .bss
global sndserver
alignb 4
sndserver:
resd 1
section .rodata
L.str:
db `sndserver`, 0
section .data
global sndserver_filename
align 4
sndserver_filename:
dd L.str
section .rodata
L.str.1:
db `doom error: %s\n`, 0
L.str.2:
db `dspistol`, 0
section .data
align 4
next_sound_handle:
dd 1
align 4
current_music_volume:
dd 127
section .rodata
L.str.3:
db `PERSIST.CHK`, 0
L.str.4:
db `SAVEREQ.CHK`, 0
L.str.5:
db `LOADREQ.CHK`, 0
section .data
checkpoint_save_slot_if_needed.description:
db `VIBE SAVE`, 0
section .rodata
L__const.checkpoint_load_slot_if_needed.path:
db `doomsav0.dsg`, 0
section .data
align 4
playable_initial_clip:
dd 4294967295
section .rodata
L.str.6:
db `DEFAULT.CFG`, 0
L.str.7:
db `r`, 0
L.str.8:
db `mouse_sensitivity`, 0
L.str.9:
db `use_mouse`, 0
L.str.10:
db `screenblocks`, 0
L.str.11:
db `chatmacro0`, 0

section .bss
doom_zone resb 8388608
vibe_key_down resb 256
alignb 2
empty_ticcmd resb 8
active_palette resb 768
alignb 4
save_checkpoint_started resb 1
alignb 4
save_checkpoint_promoted resb 1
alignb 4
save_checkpoint_done resb 1
alignb 4
load_checkpoint_started resb 1
alignb 4
load_checkpoint_done resb 1
alignb 4
load_checkpoint_post_tic_pending resb 1
alignb 4
load_checkpoint_post_tic_leveltime resb 4
alignb 4
load_checkpoint_post_tic_gametic resb 4
alignb 4
local_doomcom resb 140
alignb 4
current_music_handle resb 4
alignb 4
current_music_looping resb 4
alignb 4
current_music_paused resb 1
alignb 4
current_music_next_tic resb 4
alignb 4
current_music_pull_seen resb 4
alignb 4
current_music_refill_seen resb 4
alignb 4
current_music_under_seen resb 4
alignb 4
current_music_drop_seen resb 4
alignb 4
default_config_checkpoint_request_checked resb 1
alignb 4
default_config_checkpoint_requested resb 1
alignb 4
save_checkpoint_requested resb 1
alignb 4
save_checkpoint_request_checked resb 1
alignb 4
save_checkpoint_slot resb 4
alignb 4
load_checkpoint_requested resb 1
alignb 4
load_checkpoint_request_checked resb 1
alignb 4
load_checkpoint_slot resb 4
alignb 4
current_music_buffer resb 4
music_pcm resb 65536
alignb 4
save_checkpoint_desc_len resb 4
alignb 4
save_checkpoint_desc_hash resb 4
alignb 4
playable_proof_flags resb 4
alignb 4
playable_origin_set resb 1
alignb 4
playable_origin_x resb 4
alignb 4
playable_origin_y resb 4
alignb 4
playable_origin_angle resb 4
alignb 4
default_config_checkpoint_checked resb 1
default_config_check_buffer resb 16385
alignb 4
cached_sfx_samples resb 436
alignb 4
cached_sfx_lengths resb 436
alignb 4
cached_sfx_rates resb 436
alignb 4
cached_sfx_flags resb 436
