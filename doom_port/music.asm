BITS 32
extern memcpy
extern memset
section .text
global vibe_music_init

align 16
vibe_music_init:

    push	ebp
    mov	ebp, esp
    mov	dword [vibe_music_songs], 0
    mov	dword [vibe_music_songs+4], 0
    mov	dword [vibe_music_songs+8], 0
    mov	dword [vibe_music_songs+12], 0
    mov	dword [vibe_music_songs+16], 0
    mov	dword [vibe_music_songs+20], 11025
    mov	dword [vibe_music_songs+24], 127
    mov	dword [vibe_music_songs+28], 0
    mov	dword [vibe_music_songs+32], 0
    mov	dword [vibe_music_songs+36], 0
    mov	dword [vibe_music_songs+40], 0
    mov	dword [vibe_music_songs+44], 0
    mov	dword [vibe_music_songs+48], 0
    mov	dword [vibe_music_songs+52], 0
    mov	dword [vibe_music_songs+56], 0
    mov	dword [vibe_music_songs+60], 0
    mov	dword [vibe_music_songs+64], 0
    mov	dword [vibe_music_songs+68], 11025
    mov	dword [vibe_music_songs+72], 127
    mov	dword [vibe_music_songs+76], 0
    mov	dword [vibe_music_songs+80], 0
    mov	dword [vibe_music_songs+84], 0
    mov	dword [vibe_music_songs+88], 0
    mov	dword [vibe_music_songs+92], 0
    mov	dword [vibe_music_songs+96], 0
    mov	dword [vibe_music_songs+100], 0
    mov	dword [vibe_music_songs+104], 0
    mov	dword [vibe_music_songs+108], 0
    mov	dword [vibe_music_songs+112], 0
    mov	dword [vibe_music_songs+116], 11025
    mov	dword [vibe_music_songs+120], 127
    mov	dword [vibe_music_songs+124], 0
    mov	dword [vibe_music_songs+128], 0
    mov	dword [vibe_music_songs+132], 0
    mov	dword [vibe_music_songs+136], 0
    mov	dword [vibe_music_songs+140], 0
    mov	dword [vibe_music_songs+144], 0
    mov	dword [vibe_music_songs+148], 0
    mov	dword [vibe_music_songs+152], 0
    mov	dword [vibe_music_songs+156], 0
    mov	dword [vibe_music_songs+160], 0
    mov	dword [vibe_music_songs+164], 11025
    mov	dword [vibe_music_songs+168], 127
    mov	dword [vibe_music_songs+172], 0
    mov	dword [vibe_music_songs+176], 0
    mov	dword [vibe_music_songs+180], 0
    mov	dword [vibe_music_songs+184], 0
    mov	dword [vibe_music_songs+188], 0
    mov	dword [vibe_music_songs+192], 0
    mov	dword [vibe_music_songs+196], 0
    mov	dword [vibe_music_songs+200], 0
    mov	dword [vibe_music_songs+204], 0
    mov	dword [vibe_music_songs+208], 0
    mov	dword [vibe_music_songs+212], 11025
    mov	dword [vibe_music_songs+216], 127
    mov	dword [vibe_music_songs+220], 0
    mov	dword [vibe_music_songs+224], 0
    mov	dword [vibe_music_songs+228], 0
    mov	dword [vibe_music_songs+232], 0
    mov	dword [vibe_music_songs+236], 0
    mov	dword [vibe_music_songs+240], 0
    mov	dword [vibe_music_songs+244], 0
    mov	dword [vibe_music_songs+248], 0
    mov	dword [vibe_music_songs+252], 0
    mov	dword [vibe_music_songs+256], 0
    mov	dword [vibe_music_songs+260], 11025
    mov	dword [vibe_music_songs+264], 127
    mov	dword [vibe_music_songs+268], 0
    mov	dword [vibe_music_songs+272], 0
    mov	dword [vibe_music_songs+276], 0
    mov	dword [vibe_music_songs+280], 0
    mov	dword [vibe_music_songs+284], 0
    mov	dword [vibe_music_songs+288], 0
    mov	dword [vibe_music_songs+292], 0
    mov	dword [vibe_music_songs+296], 0
    mov	dword [vibe_music_songs+300], 0
    mov	dword [vibe_music_songs+304], 0
    mov	dword [vibe_music_songs+308], 11025
    mov	dword [vibe_music_songs+312], 127
    mov	dword [vibe_music_songs+316], 0
    mov	dword [vibe_music_songs+320], 0
    mov	dword [vibe_music_songs+324], 0
    mov	dword [vibe_music_songs+328], 0
    mov	dword [vibe_music_songs+332], 0
    mov	dword [vibe_music_songs+336], 0
    mov	dword [vibe_music_songs+340], 0
    mov	dword [vibe_music_songs+344], 0
    mov	dword [vibe_music_songs+348], 0
    mov	dword [vibe_music_songs+352], 0
    mov	dword [vibe_music_songs+356], 11025
    mov	dword [vibe_music_songs+360], 127
    mov	dword [vibe_music_songs+364], 0
    mov	dword [vibe_music_songs+368], 0
    mov	dword [vibe_music_songs+372], 0
    mov	dword [vibe_music_songs+376], 0
    mov	dword [vibe_music_songs+380], 0
    pop	ebp
    ret
Lfunc_end0:

global vibe_music_detect

align 16
vibe_music_detect:

    push	ebp
    mov	ebp, esp
    mov	ecx, dword [ebp + 8]
    xor	eax, eax
    test	ecx, ecx
    je	LBB1_9

    cmp	byte [ecx], 77
    jne	LBB1_8

    movzx	eax, byte [ecx + 1]
    cmp	eax, 84
    je	LBB1_6

    cmp	eax, 85
    jne	LBB1_8

    cmp	byte [ecx + 2], 83
    jne	LBB1_8

    mov	eax, 1
    cmp	byte [ecx + 3], 26
    jne	LBB1_8
LBB1_9:
    pop	ebp
    ret
LBB1_6:
    cmp	byte [ecx + 2], 104
    jne	LBB1_8

    mov	eax, 2
    cmp	byte [ecx + 3], 100
    je	LBB1_9
LBB1_8:
    xor	eax, eax
    pop	ebp
    ret
Lfunc_end1:

global vibe_music_register_song

align 16
vibe_music_register_song:

    push	ebp
    mov	ebp, esp
    push	esi
    mov	ecx, dword [ebp + 8]
    xor	eax, eax
    test	ecx, ecx
    je	LBB2_11

    cmp	byte [ecx], 77
    jne	LBB2_11

    movzx	edx, byte [ecx + 1]
    cmp	edx, 84
    je	LBB2_6

    cmp	edx, 85
    jne	LBB2_11

    cmp	byte [ecx + 2], 83
    jne	LBB2_11

    mov	edx, 1
    cmp	byte [ecx + 3], 26
    je	LBB2_8
    jmp	LBB2_11
LBB2_6:
    cmp	byte [ecx + 2], 104
    jne	LBB2_11

    mov	edx, 2
    cmp	byte [ecx + 3], 100
    jne	LBB2_11
LBB2_8:
    cmp	dword [vibe_music_songs+8], 0
    je	LBB2_9

    cmp	dword [vibe_music_songs+56], 0
    je	LBB2_13

    cmp	dword [vibe_music_songs+104], 0
    je	LBB2_15

    cmp	dword [vibe_music_songs+152], 0
    je	LBB2_17

    cmp	dword [vibe_music_songs+200], 0
    je	LBB2_19

    cmp	dword [vibe_music_songs+248], 0
    je	LBB2_21

    cmp	dword [vibe_music_songs+296], 0
    je	LBB2_23

    cmp	dword [vibe_music_songs+344], 0
    jne	LBB2_11

    mov	esi, vibe_music_songs+336
    mov	eax, 8
    jmp	LBB2_10
LBB2_9:
    mov	esi, vibe_music_songs
    mov	eax, 1
    jmp	LBB2_10
LBB2_13:
    mov	esi, vibe_music_songs+48
    mov	eax, 2
    jmp	LBB2_10
LBB2_15:
    mov	esi, vibe_music_songs+96
    mov	eax, 3
    jmp	LBB2_10
LBB2_17:
    mov	esi, vibe_music_songs+144
    mov	eax, 4
    jmp	LBB2_10
LBB2_19:
    mov	esi, vibe_music_songs+192
    mov	eax, 5
    jmp	LBB2_10
LBB2_21:
    mov	esi, vibe_music_songs+240
    mov	eax, 6
    jmp	LBB2_10
LBB2_23:
    mov	esi, vibe_music_songs+288
    mov	eax, 7
LBB2_10:
    mov	dword [esi], ecx
    mov	dword [esi + 4], edx
    mov	dword [esi + 8], 1
    mov	dword [esi + 12], 0
    mov	dword [esi + 16], 0
    mov	dword [esi + 20], 11025
    mov	dword [esi + 24], 127
    mov	dword [esi + 28], 0
    mov	dword [esi + 32], 0
    mov	dword [esi + 36], 0
    mov	dword [esi + 40], 0
    mov	dword [esi + 44], 0
LBB2_11:
    pop	esi
    pop	ebp
    ret
Lfunc_end2:

global vibe_music_unregister_song

align 16
vibe_music_unregister_song:

    push	ebp
    mov	ebp, esp
    mov	eax, dword [ebp + 8]
    test	eax, eax
    jle	LBB3_3

    dec	eax
    cmp	eax, 7
    ja	LBB3_3

    shl	eax, 4
    mov	dword [eax + 2*eax + vibe_music_songs], 0
    mov	dword [eax + 2*eax + vibe_music_songs+4], 0
    mov	dword [eax + 2*eax + vibe_music_songs+8], 0
    mov	dword [eax + 2*eax + vibe_music_songs+12], 0
    mov	dword [eax + 2*eax + vibe_music_songs+16], 0
    mov	dword [eax + 2*eax + vibe_music_songs+20], 11025
    mov	dword [eax + 2*eax + vibe_music_songs+24], 127
    mov	dword [eax + 2*eax + vibe_music_songs+28], 0
    mov	dword [eax + 2*eax + vibe_music_songs+32], 0
    mov	dword [eax + 2*eax + vibe_music_songs+36], 0
    mov	dword [eax + 2*eax + vibe_music_songs+40], 0
    mov	dword [eax + 2*eax + vibe_music_songs+44], 0
LBB3_3:
    pop	ebp
    ret
Lfunc_end3:

global vibe_music_render_pcm

align 16
vibe_music_render_pcm:

    push	ebp
    mov	ebp, esp
    mov	ecx, dword [ebp + 8]
    mov	edx, dword [ebp + 12]
    push	dword [ebp + 32]
    push	dword [ebp + 28]
    push	dword [ebp + 24]
    push	dword [ebp + 20]
    push	0
    push	dword [ebp + 16]
    call	render_pcm_window
    add	esp, 24
    pop	ebp
    ret
Lfunc_end4:

align 16
render_pcm_window:

    push	ebp
    mov	ebp, esp
    push	ebx
    push	edi
    push	esi
    sub	esp, 452
    mov	esi, edx
    mov	edx, dword [ebp + 28]
    mov	al, 1
    test	ecx, ecx
    je	LBB5_10

    cmp	byte [ecx], 77
    jne	LBB5_10

    movzx	edi, byte [ecx + 1]
    cmp	edi, 84
    je	LBB5_7

    cmp	edi, 85
    jne	LBB5_10

    cmp	byte [ecx + 2], 83
    jne	LBB5_10

    cmp	byte [ecx + 3], 26
    jne	LBB5_10

    mov	ebx, 1
    mov	al, 1
    mov	dword [ebp - 16], eax
    xor	eax, eax
    jmp	LBB5_11
LBB5_7:
    cmp	byte [ecx + 2], 104
    jne	LBB5_10

    cmp	byte [ecx + 3], 100
    jne	LBB5_10

    mov	ebx, 2
    xor	eax, eax
    mov	dword [ebp - 16], 0
    jmp	LBB5_11
LBB5_10:
    mov	dword [ebp - 16], 0
    xor	ebx, ebx
LBB5_11:
    mov	edi, dword [ebp + 8]
    test	edx, edx
    je	LBB5_13

    mov	dword [edx], ebx
    mov	dword [edx + 4], 0
    mov	dword [edx + 8], 0
    mov	dword [edx + 12], 0
    mov	dword [edx + 16], 0
    mov	dword [edx + 20], 0
    mov	dword [edx + 24], 0
    mov	dword [edx + 28], 0
    mov	dword [edx + 32], 0
    mov	dword [edx + 36], 0
    mov	dword [edx + 40], 0
    mov	dword [edx + 44], 0
    mov	dword [edx + 48], 0
    mov	dword [edx + 52], 0
    mov	dword [edx + 56], 0
    mov	dword [edx + 60], 0
    mov	dword [edx + 64], 0
    mov	dword [edx + 68], 0
    mov	dword [edx + 72], 0
    mov	dword [edx + 76], 0
    mov	dword [edx + 80], 0
    mov	dword [edx + 84], 0
    mov	dword [edx + 88], 0
    mov	dword [edx + 92], 0
    mov	dword [edx + 96], 0
LBB5_13:
    test	esi, esi
    sete	dh
    test	edi, edi
    sete	dl
    or	dl, dh
    jne	LBB5_18

    mov	dword [ebp - 44], ebx
    mov	ebx, dword [ebp + 16]
    xor	edx, edx
align 16
LBB5_15:
    mov	byte [esi + edx], -128
    inc	edx
    cmp	edi, edx
    jne	LBB5_15

    test	al, al
    je	LBB5_19
LBB5_18:
    xor	ecx, ecx
LBB5_53:
    mov	eax, ecx
    add	esp, 452
    pop	esi
    pop	edi
    pop	ebx
    pop	ebp
    ret
LBB5_19:
    mov	eax, -256
align 16
LBB5_20:
    mov	dword [ebp + eax - 208], 0
    mov	word [ebp + eax - 204], 0
    mov	dword [ebp + eax - 200], 0
    mov	dword [ebp + eax - 196], 0
    add	eax, 16
    jne	LBB5_20

    mov	eax, -16
    mov	edx, dword [ebp + 12]
align 16
LBB5_22:
    mov	byte [ebp + eax - 192], 100
    mov	byte [ebp + eax - 176], 127
    mov	byte [ebp + eax - 160], 64
    mov	byte [ebp + eax - 144], 0
    mov	byte [ebp + eax - 128], 0
    mov	dword [ebp + 4*eax - 64], 8192
    inc	eax
    jne	LBB5_22

    test	ebx, ebx
    mov	eax, 11025
    je	LBB5_25

    mov	eax, ebx
LBB5_25:
    mov	dword [ebp - 20], ecx
    mov	dword [ebp - 48], eax
    mov	dword [ebp - 64], eax
    mov	eax, dword [ebp + 20]
    cmp	eax, 127
    jb	LBB5_27

    mov	eax, 127
LBB5_27:
    mov	dword [ebp - 52], eax
    mov	dword [ebp - 60], eax
    mov	dword [ebp - 40], esi
    mov	dword [ebp - 36], edi
    mov	dword [ebp - 32], edx
    mov	dword [ebp - 28], 0
    mov	dword [ebp - 24], 0
    xor	edx, edx
    xor	ebx, ebx
align 16
LBB5_28:


    mov	dword [ebp - 56], edx
    cmp	byte [ebp - 16], 0
    je	LBB5_30

    mov	ecx, dword [ebp - 20]
    lea	edx, [ebp - 464]
    push	dword [ebp + 28]
    lea	eax, [ebp - 40]
    push	eax
    call	render_mus_pass
    jmp	LBB5_31
align 16
LBB5_30:
    mov	ecx, dword [ebp - 20]
    lea	edx, [ebp - 464]
    push	dword [ebp + 28]
    lea	eax, [ebp - 40]
    push	eax
    call	render_midi_pass
LBB5_31:
    add	esp, 8
    test	eax, eax
    je	LBB5_44

    mov	eax, dword [ebp - 28]
    mov	ecx, dword [ebp - 24]
    cmp	ecx, edi
    jae	LBB5_46

    cmp	dword [ebp + 24], 0
    mov	edx, dword [ebp - 56]
    je	LBB5_42

    cmp	eax, edx
    je	LBB5_42

    mov	edx, dword [ebp + 28]
    test	edx, edx
    je	LBB5_37

    inc	dword [edx + 60]
LBB5_37:
    mov	edx, -256
align 16
LBB5_38:

    mov	dword [ebp + edx - 208], 0
    mov	word [ebp + edx - 204], 0
    mov	dword [ebp + edx - 200], 0
    mov	dword [ebp + edx - 196], 0
    add	edx, 16
    jne	LBB5_38

    mov	edx, -16
align 16
LBB5_40:

    mov	byte [ebp + edx - 192], 100
    mov	byte [ebp + edx - 176], 127
    mov	byte [ebp + edx - 160], 64
    mov	byte [ebp + edx - 144], 0
    mov	byte [ebp + edx - 128], 0
    mov	dword [ebp + 4*edx - 64], 8192
    inc	edx
    jne	LBB5_40

    mov	edx, dword [ebp - 48]
    mov	dword [ebp - 64], edx
    mov	edx, dword [ebp - 52]
    mov	dword [ebp - 60], edx
    inc	ebx
    cmp	ebx, 256
    mov	edx, eax
    jne	LBB5_28
LBB5_42:
    mov	edx, eax
    or	edx, ecx
    mov	ebx, dword [ebp + 28]
    je	LBB5_49

    add	eax, edi
    sub	eax, ecx
    lea	ecx, [ebp - 464]
    lea	edx, [ebp - 40]
    push	ebx
    push	eax
    call	synth_render_until
    add	esp, 8
    mov	ecx, dword [ebp - 24]
    jmp	LBB5_47
align 16
LBB5_44:
    mov	byte [esi], -128
    inc	esi
    dec	edi
    jne	LBB5_44

    mov	eax, 68
    xor	edx, edx
    mov	ebx, dword [ebp + 28]
    test	ebx, ebx
    mov	ecx, 0
    jne	LBB5_52
    jmp	LBB5_53
LBB5_46:
    or	eax, ecx
    mov	ebx, dword [ebp + 28]
    je	LBB5_49
LBB5_47:
    test	ebx, ebx
    je	LBB5_53

    mov	dword [ebx + 68], ecx
    mov	edx, dword [ebp + 12]
    mov	dword [ebx + 72], edx
    add	edx, ecx
    mov	eax, 76
    jmp	LBB5_52
align 16
LBB5_49:
    mov	byte [esi], -128
    inc	esi
    dec	edi
    jne	LBB5_49

    test	ebx, ebx
    je	LBB5_18

    mov	eax, dword [ebp - 44]
    mov	dword [ebx], eax
    mov	dword [ebx + 4], 0
    mov	dword [ebx + 8], 0
    mov	dword [ebx + 12], 0
    mov	dword [ebx + 16], 0
    mov	dword [ebx + 20], 0
    mov	dword [ebx + 24], 0
    mov	dword [ebx + 28], 0
    mov	dword [ebx + 32], 0
    mov	dword [ebx + 36], 0
    mov	dword [ebx + 40], 0
    mov	dword [ebx + 44], 0
    mov	dword [ebx + 48], 0
    mov	dword [ebx + 52], 0
    mov	dword [ebx + 56], 0
    mov	dword [ebx + 60], 0
    mov	dword [ebx + 64], 0
    mov	dword [ebx + 68], 0
    mov	dword [ebx + 72], 0
    mov	dword [ebx + 76], 0
    mov	dword [ebx + 80], 0
    mov	dword [ebx + 84], 0
    mov	dword [ebx + 88], 0
    mov	dword [ebx + 92], 0
    xor	edx, edx
    mov	eax, 96
    xor	ecx, ecx
LBB5_52:
    mov	dword [ebx + eax], edx
    jmp	LBB5_53
Lfunc_end5:

global vibe_music_stream_begin

align 16
vibe_music_stream_begin:

    push	ebp
    mov	ebp, esp
    push	ebx
    push	edi
    push	esi
    sub	esp, 436
    mov	eax, dword [ebp + 8]
    test	eax, eax
    jle	LBB6_27

    dec	eax
    cmp	eax, 7
    ja	LBB6_27

    shl	eax, 4
    cmp	dword [eax + 2*eax + vibe_music_songs+8], 0
    je	LBB6_27

    mov	ecx, dword [ebp + 12]
    lea	esi, [eax + 2*eax + vibe_music_songs]
    test	ecx, ecx
    mov	eax, 11025
    je	LBB6_5

    mov	eax, ecx
LBB6_5:
    mov	dword [ebp - 20], eax
    mov	edi, dword [ebp + 20]
    mov	ebx, dword [ebp + 16]
    mov	ecx, dword [esi]
    xor	eax, eax
    test	ecx, ecx
    je	LBB6_22

    cmp	byte [ecx], 77
    jne	LBB6_22

    movzx	edx, byte [ecx + 1]
    cmp	edx, 84
    je	LBB6_11

    cmp	edx, 85
    jne	LBB6_22

    cmp	byte [ecx + 2], 83
    jne	LBB6_22

    mov	dl, 1
    cmp	byte [ecx + 3], 26
    je	LBB6_13
    jmp	LBB6_22
LBB6_11:
    cmp	byte [ecx + 2], 104
    jne	LBB6_22

    xor	edx, edx
    cmp	byte [ecx + 3], 100
    mov	eax, 0
    jne	LBB6_22
LBB6_13:
    mov	eax, -256
align 16
LBB6_14:
    mov	dword [ebp + eax - 192], 0
    mov	word [ebp + eax - 188], 0
    mov	dword [ebp + eax - 184], 0
    mov	dword [ebp + eax - 180], 0
    add	eax, 16
    jne	LBB6_14

    mov	eax, -16
align 16
LBB6_16:
    mov	byte [ebp + eax - 176], 100
    mov	byte [ebp + eax - 160], 127
    mov	byte [ebp + eax - 144], 64
    mov	byte [ebp + eax - 128], 0
    mov	byte [ebp + eax - 112], 0
    mov	dword [ebp + 4*eax - 48], 8192
    inc	eax
    jne	LBB6_16

    mov	eax, dword [ebp - 20]
    mov	dword [ebp - 48], eax
    mov	dword [ebp - 44], 127
    lea	eax, [ebp - 13]
    mov	dword [ebp - 40], eax
    mov	dword [ebp - 36], 1
    mov	dword [ebp - 32], -1
    mov	dword [ebp - 28], 0
    mov	dword [ebp - 24], 0
    lea	eax, [ebp - 40]
    test	dl, dl
    je	LBB6_19

    lea	edx, [ebp - 448]
    push	0
    push	eax
    call	render_mus_pass
    jmp	LBB6_20
LBB6_19:
    lea	edx, [ebp - 448]
    push	0
    push	eax
    call	render_midi_pass
LBB6_20:
    add	esp, 8
    test	eax, eax
    je	LBB6_22

    mov	eax, dword [ebp - 28]
LBB6_22:
    xor	ecx, ecx
    test	eax, eax
    setne	cl
    mov	dword [esi + 12], ecx
    mov	dword [esi + 16], edi
    mov	ecx, dword [ebp - 20]
    mov	dword [esi + 20], ecx
    cmp	ebx, 127
    jb	LBB6_24

    mov	ebx, 127
LBB6_24:
    mov	dword [esi + 24], ebx
    mov	dword [esi + 28], 0
    mov	dword [esi + 32], eax
    test	edi, edi
    je	LBB6_26

    mov	edi, eax
LBB6_26:
    mov	dword [esi + 36], edi
    mov	dword [esi + 40], 0
    mov	dword [esi + 44], 0
LBB6_27:
    add	esp, 436
    pop	esi
    pop	edi
    pop	ebx
    pop	ebp
    ret
Lfunc_end6:

global vibe_music_stream_stop

align 16
vibe_music_stream_stop:

    push	ebp
    mov	ebp, esp
    mov	eax, dword [ebp + 8]
    test	eax, eax
    jle	LBB7_3

    dec	eax
    cmp	eax, 7
    ja	LBB7_3

    lea	eax, [eax + 2*eax]
    shl	eax, 4
    mov	dword [eax + vibe_music_songs+12], 0
LBB7_3:
    pop	ebp
    ret
Lfunc_end7:

global vibe_music_stream_set_volume

align 16
vibe_music_stream_set_volume:

    push	ebp
    mov	ebp, esp
    mov	eax, dword [ebp + 8]
    test	eax, eax
    jle	LBB8_6

    dec	eax
    cmp	eax, 7
    ja	LBB8_6

    shl	eax, 4
    cmp	dword [eax + 2*eax + vibe_music_songs+8], 0
    je	LBB8_6

    mov	ecx, dword [ebp + 12]
    lea	eax, [eax + 2*eax + vibe_music_songs]
    cmp	ecx, 127
    jb	LBB8_5

    mov	ecx, 127
LBB8_5:
    mov	dword [eax + 24], ecx
LBB8_6:
    pop	ebp
    ret
Lfunc_end8:

global vibe_music_stream_position

align 16
vibe_music_stream_position:

    push	ebp
    mov	ebp, esp
    mov	ecx, dword [ebp + 8]
    xor	eax, eax
    test	ecx, ecx
    jle	LBB9_4

    dec	ecx
    cmp	ecx, 7
    ja	LBB9_4

    shl	ecx, 4
    cmp	dword [ecx + 2*ecx + vibe_music_songs+8], 0
    je	LBB9_4

    lea	eax, [ecx + 2*ecx + vibe_music_songs]
    mov	eax, dword [eax + 28]
LBB9_4:
    pop	ebp
    ret
Lfunc_end9:

global vibe_music_stream_song_samples

align 16
vibe_music_stream_song_samples:

    push	ebp
    mov	ebp, esp
    mov	ecx, dword [ebp + 8]
    xor	eax, eax
    test	ecx, ecx
    jle	LBB10_4

    dec	ecx
    cmp	ecx, 7
    ja	LBB10_4

    shl	ecx, 4
    cmp	dword [ecx + 2*ecx + vibe_music_songs+8], 0
    je	LBB10_4

    lea	eax, [ecx + 2*ecx + vibe_music_songs]
    mov	eax, dword [eax + 32]
LBB10_4:
    pop	ebp
    ret
Lfunc_end10:

global vibe_music_stream_loop_samples

align 16
vibe_music_stream_loop_samples:

    push	ebp
    mov	ebp, esp
    mov	ecx, dword [ebp + 8]
    xor	eax, eax
    test	ecx, ecx
    jle	LBB11_4

    dec	ecx
    cmp	ecx, 7
    ja	LBB11_4

    shl	ecx, 4
    cmp	dword [ecx + 2*ecx + vibe_music_songs+8], 0
    je	LBB11_4

    lea	eax, [ecx + 2*ecx + vibe_music_songs]
    mov	eax, dword [eax + 36]
LBB11_4:
    pop	ebp
    ret
Lfunc_end11:

global vibe_music_stream_loop_count

align 16
vibe_music_stream_loop_count:

    push	ebp
    mov	ebp, esp
    mov	ecx, dword [ebp + 8]
    xor	eax, eax
    test	ecx, ecx
    jle	LBB12_4

    dec	ecx
    cmp	ecx, 7
    ja	LBB12_4

    shl	ecx, 4
    cmp	dword [ecx + 2*ecx + vibe_music_songs+8], 0
    je	LBB12_4

    lea	eax, [ecx + 2*ecx + vibe_music_songs]
    mov	eax, dword [eax + 40]
LBB12_4:
    pop	ebp
    ret
Lfunc_end12:

global vibe_music_stream_snapshot

align 16
vibe_music_stream_snapshot:

    push	ebp
    mov	ebp, esp
    push	esi
    mov	ecx, dword [ebp + 12]
    xor	eax, eax
    test	ecx, ecx
    je	LBB13_7

    mov	edx, dword [ebp + 8]
    mov	dword [ecx], 0
    mov	dword [ecx + 4], 0
    mov	dword [ecx + 8], 0
    mov	dword [ecx + 12], 0
    mov	dword [ecx + 16], 0
    mov	dword [ecx + 20], 0
    mov	dword [ecx + 24], 0
    mov	dword [ecx + 28], 0
    mov	dword [ecx + 32], 0
    test	edx, edx
    jle	LBB13_7

    dec	edx
    cmp	edx, 7
    ja	LBB13_7

    shl	edx, 4
    cmp	dword [edx + 2*edx + vibe_music_songs+8], 0
    je	LBB13_7

    lea	eax, [edx + 2*edx + vibe_music_songs]
    mov	edx, dword [eax + 4]
    cmp	dword [eax + 12], 1
    mov	esi, 5
    sbb	esi, 0
    cmp	dword [eax + 16], 0
    je	LBB13_6

    or	esi, 2
LBB13_6:
    mov	dword [ecx], edx
    mov	dword [ecx + 4], esi
    mov	edx, dword [eax + 20]
    mov	dword [ecx + 8], edx
    mov	edx, dword [eax + 24]
    mov	dword [ecx + 12], edx
    mov	edx, dword [eax + 28]
    mov	dword [ecx + 16], edx
    mov	edx, dword [eax + 32]
    mov	dword [ecx + 20], edx
    mov	edx, dword [eax + 36]
    mov	dword [ecx + 24], edx
    mov	edx, dword [eax + 40]
    mov	dword [ecx + 28], edx
    mov	eax, dword [eax + 44]
    mov	dword [ecx + 32], eax
    mov	eax, 1
LBB13_7:
    pop	esi
    pop	ebp
    ret
Lfunc_end13:

global vibe_music_stream_render

align 16
vibe_music_stream_render:

    push	ebp
    mov	ebp, esp
    push	ebx
    push	edi
    push	esi
    sub	esp, 48
    mov	ebx, dword [ebp + 20]
    mov	edi, dword [ebp + 16]
    mov	esi, dword [ebp + 12]
    mov	eax, dword [ebp + 8]
    test	eax, eax
    jle	LBB14_10

    dec	eax
    cmp	eax, 7
    ja	LBB14_7

    shl	eax, 4
    cmp	dword [eax + 2*eax + vibe_music_songs+8], 0
    je	LBB14_7

    lea	eax, [eax + 2*eax + vibe_music_songs]
    mov	edx, dword [eax + 4]
    cmp	dword [eax + 12], 0
    je	LBB14_17

    mov	dword [ebp - 52], edx
    mov	edx, dword [eax + 28]
    mov	ecx, dword [eax + 32]
    mov	dword [ebp - 24], ecx
    mov	ecx, dword [eax + 36]
    test	ecx, ecx
    mov	dword [ebp - 20], eax
    mov	dword [ebp - 60], ecx
    mov	dword [ebp - 32], edx
    je	LBB14_21

    mov	eax, edx
    xor	edx, edx
    div	ecx
    mov	dword [ebp - 48], eax
    mov	dword [ebp - 44], edx
    mov	edx, dword [ebp - 20]
    lea	ecx, [edx + 44]
    mov	eax, dword [edx + 16]
    mov	dword [ebp - 40], eax
    test	eax, eax
    mov	eax, dword [edx + 44]
    mov	dword [ebp - 56], eax
    je	LBB14_22

    mov	dword [ebp - 36], ecx
    cmp	dword [ebp - 24], 0
    setne	byte [ebp - 13]
    jmp	LBB14_29
LBB14_7:
    test	esi, esi
    sete	al
    test	edi, edi
    sete	cl
    or	cl, al
    jne	LBB14_12
align 16
LBB14_8:
    mov	byte [esi], -128
    inc	esi
    dec	edi
    jne	LBB14_8
    jmp	LBB14_12
LBB14_10:
    test	esi, esi
    sete	al
    test	edi, edi
    sete	cl
    or	cl, al
    jne	LBB14_12
align 16
LBB14_11:
    mov	byte [esi], -128
    inc	esi
    dec	edi
    jne	LBB14_11
LBB14_12:
    test	ebx, ebx
    je	LBB14_42

    mov	dword [ebx], 0
LBB14_14:
    mov	dword [ebx + 4], 0
    mov	dword [ebx + 8], 0
    mov	dword [ebx + 12], 0
    mov	dword [ebx + 16], 0
    mov	dword [ebx + 20], 0
    mov	dword [ebx + 24], 0
    mov	dword [ebx + 28], 0
    mov	dword [ebx + 32], 0
    mov	dword [ebx + 36], 0
    mov	dword [ebx + 40], 0
    mov	dword [ebx + 44], 0
    mov	dword [ebx + 48], 0
    mov	dword [ebx + 52], 0
    mov	dword [ebx + 56], 0
    mov	dword [ebx + 60], 0
    mov	dword [ebx + 64], 0
    mov	dword [ebx + 68], 0
    mov	dword [ebx + 72], 0
    mov	dword [ebx + 76], 0
    mov	dword [ebx + 80], 0
    mov	dword [ebx + 84], 0
    xor	ecx, ecx
    xor	esi, esi
    xor	eax, eax
LBB14_15:
    mov	dword [ebx + 88], ecx
    mov	dword [ebx + 92], esi
    mov	dword [ebx + 96], eax
    jmp	LBB14_16
LBB14_17:
    test	esi, esi
    sete	al
    test	edi, edi
    sete	cl
    or	cl, al
    jne	LBB14_19
align 16
LBB14_18:
    mov	byte [esi], -128
    inc	esi
    dec	edi
    jne	LBB14_18
LBB14_19:
    test	ebx, ebx
    je	LBB14_42

    mov	dword [ebx], edx
    jmp	LBB14_14
LBB14_21:
    lea	edx, [eax + 44]
    mov	ecx, dword [eax + 16]
    mov	eax, dword [eax + 44]
    mov	dword [ebp - 56], eax
    mov	dword [ebp - 48], 0
    jmp	LBB14_23
LBB14_22:
    mov	edx, ecx
    xor	ecx, ecx
LBB14_23:
    test	ecx, ecx
    sete	al
    cmp	dword [ebp - 24], 0
    setne	ah
    and	al, ah
    cmp	al, 1
    jne	LBB14_28

    mov	eax, dword [ebp - 24]
    mov	ecx, dword [ebp - 32]
    sub	eax, ecx
    jbe	LBB14_43

    cmp	edi, eax
    mov	dword [ebp - 28], edi
    jb	LBB14_27

    mov	dword [ebp - 28], eax
LBB14_27:
    mov	dword [ebp - 36], edx
    mov	dword [ebp - 40], 0
    mov	byte [ebp - 13], 1
    mov	dword [ebp - 44], ecx
    jmp	LBB14_30
LBB14_28:
    mov	byte [ebp - 13], ah
    mov	dword [ebp - 36], edx
    mov	eax, dword [ebp - 32]
    mov	dword [ebp - 44], eax
    mov	dword [ebp - 40], ecx
LBB14_29:
    mov	dword [ebp - 28], edi
LBB14_30:
    mov	eax, dword [ebp - 20]
    mov	ecx, dword [eax]
    mov	edx, esi
    push	ebx
    push	dword [ebp - 40]
    push	dword [eax + 24]
    push	dword [eax + 20]
    push	dword [ebp - 44]
    push	dword [ebp - 28]
    call	render_pcm_window
    add	esp, 24
    test	eax, eax
    je	LBB14_39

    mov	ecx, dword [ebp - 32]
    add	ecx, eax
    mov	edi, dword [ebp - 60]
    test	edi, edi
    je	LBB14_34

    mov	esi, eax
    mov	eax, ecx
    xor	edx, edx
    div	edi
    mov	edx, eax
    mov	eax, esi
    sub	edx, dword [ebp - 48]
    jbe	LBB14_34

    mov	esi, dword [ebp - 20]
    add	dword [esi + 40], edx
LBB14_34:
    mov	edx, dword [ebp - 20]
    mov	dword [edx + 28], ecx
    cmp	dword [edx + 16], 0
    sete	dl
    and	dl, byte [ebp - 13]
    cmp	dl, 1
    jne	LBB14_37

    cmp	ecx, dword [ebp - 24]
    jb	LBB14_37

    mov	edx, dword [ebp - 20]
    mov	dword [edx + 12], 0
LBB14_37:
    mov	esi, dword [ebp - 56]
    lea	edx, [esi + 1]
    mov	edi, dword [ebp - 36]
    mov	dword [edi], edx
    test	ebx, ebx
    je	LBB14_16

    mov	edx, dword [ebp - 32]
    mov	dword [ebx + 72], edx
    mov	dword [ebx + 76], ecx
    mov	ecx, dword [ebp - 24]
    mov	dword [ebx + 80], ecx
    mov	ecx, dword [ebp - 60]
    mov	dword [ebx + 84], ecx
    mov	ecx, dword [ebp - 20]
    mov	ecx, dword [ecx + 40]
    jmp	LBB14_15
LBB14_39:
    test	esi, esi
    sete	al
    test	edi, edi
    sete	cl
    or	cl, al
    jne	LBB14_41
align 16
LBB14_40:
    mov	byte [esi], -128
    inc	esi
    dec	edi
    jne	LBB14_40
    jmp	LBB14_41
LBB14_43:
    mov	eax, dword [ebp - 20]
    mov	dword [eax + 12], 0
    test	esi, esi
    sete	al
    test	edi, edi
    sete	cl
    or	cl, al
    jne	LBB14_41
align 16
LBB14_44:
    mov	byte [esi], -128
    inc	esi
    dec	edi
    jne	LBB14_44
LBB14_41:
    test	ebx, ebx
    mov	eax, dword [ebp - 52]
    je	LBB14_42

    mov	dword [ebx], eax
    jmp	LBB14_14
LBB14_42:
    xor	eax, eax
LBB14_16:
    add	esp, 48
    pop	esi
    pop	edi
    pop	ebx
    pop	ebp
    ret
Lfunc_end14:

global vibe_music_render_song

align 16
vibe_music_render_song:

    push	ebp
    mov	ebp, esp
    mov	eax, dword [ebp + 8]
    test	eax, eax
    jle	LBB15_4

    dec	eax
    cmp	eax, 7
    ja	LBB15_4

    shl	eax, 4
    cmp	dword [eax + 2*eax + vibe_music_songs+8], 0
    je	LBB15_4

    mov	edx, dword [ebp + 12]
    lea	eax, [eax + 2*eax + vibe_music_songs]
    mov	ecx, dword [eax]
    push	dword [ebp + 32]
    push	dword [ebp + 28]
    push	dword [ebp + 24]
    push	dword [ebp + 20]
    push	0
    push	dword [ebp + 16]
    call	render_pcm_window
    add	esp, 24
    pop	ebp
    ret
LBB15_4:
    xor	eax, eax
    pop	ebp
    ret
Lfunc_end15:

align 16
render_mus_pass:

    push	ebp
    mov	ebp, esp
    push	ebx
    push	edi
    push	esi
    sub	esp, 28
    mov	esi, edx
    movzx	eax, word [ecx + 4]
    mov	dword [ebp - 28], ecx
    movzx	ebx, word [ecx + 6]
    cmp	ebx, 16
    setae	cl
    test	ax, ax
    setne	dl
    and	dl, cl
    xor	edi, edi
    cmp	dl, 1
    jne	LBB16_163

    mov	edx, ebx
    mov	ebx, dword [ebp + 12]
    movzx	eax, ax
    add	eax, edx
    mov	dword [ebp - 24], eax
    mov	dword [ebp - 36], esi
    jmp	LBB16_3
align 16
LBB16_2:
    mov	esi, dword [ebp - 36]
    cmp	edx, dword [ebp - 24]
    jae	LBB16_163
LBB16_3:









    mov	ecx, dword [ebp + 8]
    mov	eax, dword [ecx + 16]
    mov	edi, 1
    cmp	eax, dword [ecx + 4]
    jae	LBB16_163

    mov	eax, dword [ebp - 28]
    mov	dword [ebp - 20], edx
    movzx	ecx, byte [eax + edx]
    mov	dword [ebp - 40], ecx
    and	ecx, 15
    cmp	ecx, 9
    mov	eax, ecx
    sbb	eax, -1
    cmp	ecx, 15
    mov	edx, 9
    je	LBB16_6

    mov	edx, eax
LBB16_6:
    mov	ecx, dword [ebp - 40]
    shr	ecx, 4
    and	ecx, 7
    cmp	ecx, 6
    ja	LBB16_161

    mov	eax, dword [ebp - 20]
    inc	eax
    mov	dword [ebp - 16], edx
    mov	edi, ebx
    jmp	dword [4*ecx + LJTI16_0]
LBB16_8:
    cmp	dword [ebp - 24], eax
    jbe	LBB16_161

    mov	ecx, dword [ebp - 28]
    movzx	eax, byte [ecx + eax]
    and	al, 127
    mov	ecx, -256
    jmp	LBB16_12
LBB16_10:
    mov	byte [esi + ecx + 260], dl
    mov	ebx, edi
align 16
LBB16_11:
    add	ecx, 16
    je	LBB16_56
LBB16_12:

    cmp	byte [esi + ecx + 256], 0
    je	LBB16_11

    movzx	edx, byte [esi + ecx + 257]
    cmp	dword [ebp - 16], edx
    mov	edx, dword [ebp - 16]
    jne	LBB16_11

    cmp	al, byte [esi + ecx + 258]
    jne	LBB16_11

    mov	ebx, edx
    mov	dl, 1
    cmp	byte [esi + ebx + 320], 0
    jne	LBB16_10

    mov	byte [esi + ecx + 256], 0
    xor	edx, edx
    jmp	LBB16_10
LBB16_17:
    cmp	dword [ebp - 24], eax
    jbe	LBB16_161

    mov	ecx, dword [ebp - 20]
    lea	ebx, [ecx + 2]
    mov	eax, dword [ebp - 28]
    movzx	eax, byte [eax + ecx + 1]
    test	al, al
    js	LBB16_61

    mov	dword [ebp - 16], ebx
    mov	ebx, edx
    movzx	edx, byte [esi + edx + 256]
    jmp	LBB16_63
LBB16_20:
    cmp	dword [ebp - 24], eax
    jbe	LBB16_161

    mov	eax, dword [ebp - 28]
    mov	ecx, dword [ebp - 20]
    movzx	eax, byte [eax + ecx + 1]
    add	ecx, 2
    mov	dword [ebp - 20], ecx
    and	eax, 127
    cmp	eax, 14
    je	LBB16_73

    cmp	eax, 11
    mov	edi, 1
    je	LBB16_64

    cmp	eax, 10
    jne	LBB16_79

    mov	eax, -256
    jmp	LBB16_26
align 16
LBB16_25:
    add	eax, 16
    je	LBB16_80
LBB16_26:

    cmp	byte [esi + eax + 256], 0
    je	LBB16_25

    movzx	ecx, byte [esi + eax + 257]
    cmp	edx, ecx
    jne	LBB16_25

    mov	byte [esi + eax + 256], 0
    mov	byte [esi + eax + 260], 0
    jmp	LBB16_25
LBB16_29:
    cmp	dword [ebp - 24], eax
    jbe	LBB16_161

    mov	ecx, dword [ebp - 28]
    movzx	eax, byte [ecx + eax]
    and	eax, 127
    shl	eax, 7
    mov	dword [esi + 4*edx + 336], eax
    mov	ebx, -256
    jmp	LBB16_33
align 16
LBB16_31:
    mov	dword [esi + ebx + 268], ecx
LBB16_32:
    add	ebx, 16
    je	LBB16_58
LBB16_33:

    cmp	byte [esi + ebx + 256], 0
    je	LBB16_32

    movzx	eax, byte [esi + ebx + 257]
    cmp	edx, eax
    jne	LBB16_32

    mov	esi, dword [esi + 4*edx + 336]
    cmp	esi, 16383
    mov	dword [ebp - 32], esi
    jb	LBB16_37

    mov	esi, 16383
LBB16_37:
    mov	eax, dword [ebp - 36]
    movzx	eax, byte [eax + ebx + 258]
    cmp	al, 127
    jb	LBB16_39

    mov	al, 127
LBB16_39:
    mov	ecx, dword [ebp - 36]
    mov	ecx, dword [ecx + 400]
    test	ecx, ecx
    mov	edi, 11025
    je	LBB16_41

    mov	edi, ecx
LBB16_41:
    movzx	eax, al
    mov	ecx, dword [4*eax + vibe_music_note_freq_x16]
    shl	ecx, 12
    mov	eax, ecx
    xor	edx, edx
    div	edi
    cmp	eax, 65535
    jb	LBB16_43

    mov	eax, 65535
LBB16_43:
    cmp	edi, ecx
    mov	ecx, 1
    ja	LBB16_45

    mov	ecx, eax
LBB16_45:
    cmp	dword [ebp - 32], 8192
    mov	edx, dword [ebp - 16]
    jb	LBB16_47

    add	esi, -8192
    imul	esi, ecx
    shr	esi, 15
    add	ecx, esi
    jmp	LBB16_49
LBB16_47:
    mov	eax, 8192
    sub	eax, esi
    imul	eax, ecx
    shr	eax, 15
    sub	ecx, eax
    ja	LBB16_49

    mov	ecx, 1
LBB16_49:
    mov	esi, dword [ebp - 36]
    cmp	ecx, 1
    adc	ecx, 0
    cmp	ecx, 65535
    jb	LBB16_31

    mov	ecx, 65535
    jmp	LBB16_31
LBB16_51:
    mov	ecx, dword [ebp - 24]
    sub	ecx, eax
    cmp	ecx, 1
    jbe	LBB16_161

    mov	eax, dword [ebp - 28]
    mov	edi, dword [ebp - 20]
    movzx	ecx, byte [eax + edi + 1]
    and	ecx, 127
    lea	ebx, [edi + 3]
    mov	dword [ebp - 16], ebx
    cmp	ecx, 11
    ja	LBB16_93

    movzx	eax, byte [eax + edi + 2]
    and	al, 127
    jmp	dword [4*ecx + LJTI16_1]
LBB16_54:
    mov	ebx, dword [ebp + 12]
    test	ebx, ebx
    mov	byte [esi + edx + 304], al
    mov	edi, 1
    je	LBB16_91

    inc	dword [ebx + 16]
    jmp	LBB16_119
LBB16_56:
    mov	eax, dword [ebp - 20]
    add	eax, 2
    test	ebx, ebx
    je	LBB16_60

    inc	dword [ebx + 8]
    jmp	LBB16_60
LBB16_58:
    mov	eax, dword [ebp - 20]
    add	eax, 2
    mov	ebx, dword [ebp + 12]
    test	ebx, ebx
    je	LBB16_60

    inc	dword [ebx + 32]
LBB16_60:
    mov	edx, eax
    mov	edi, 1
    cmp	byte [ebp - 40], 0
    jns	LBB16_2
    jmp	LBB16_122
LBB16_61:
    cmp	ebx, dword [ebp - 24]
    jae	LBB16_159

    mov	ecx, dword [ebp - 28]
    mov	ebx, edx
    mov	edx, dword [ebp - 20]
    movzx	edx, byte [ecx + edx + 2]
    mov	ecx, dword [ebp - 20]
    add	ecx, 3
    and	dl, 127
    mov	byte [esi + ebx + 256], dl
    mov	dword [ebp - 16], ecx
LBB16_63:
    mov	ecx, esi
    and	eax, 127
    movzx	esi, dl
    mov	edx, ebx
    mov	ebx, edi
    push	edi
    push	esi
    push	eax
    call	synth_note_on
    add	esp, 12
    mov	edi, 1
    mov	edx, dword [ebp - 16]
    cmp	byte [ebp - 40], 0
    jns	LBB16_2
    jmp	LBB16_122
LBB16_64:
    mov	eax, -256
    jmp	LBB16_67
LBB16_65:
    mov	byte [esi + eax + 256], 0
align 16
LBB16_66:
    add	eax, 16
    je	LBB16_71
LBB16_67:

    cmp	byte [esi + eax + 256], 0
    je	LBB16_66

    movzx	ecx, byte [esi + eax + 257]
    cmp	edx, ecx
    jne	LBB16_66

    cmp	byte [esi + edx + 320], 0
    je	LBB16_65

    mov	byte [esi + eax + 260], 1
    jmp	LBB16_66
LBB16_71:
    test	ebx, ebx
    je	LBB16_133

    inc	dword [ebx + 40]
    mov	eax, dword [ebp - 20]
    jmp	LBB16_81
LBB16_73:
    mov	byte [esi + edx + 256], 100
    mov	byte [esi + edx + 272], 127
    mov	byte [esi + edx + 288], 64
    mov	byte [esi + edx + 304], 0
    mov	byte [esi + edx + 320], 0
    mov	dword [esi + 4*edx + 336], 8192
    mov	eax, -256
    mov	edi, 1
    jmp	LBB16_75
align 16
LBB16_74:
    add	eax, 16
    je	LBB16_80
LBB16_75:

    cmp	byte [esi + eax + 256], 0
    je	LBB16_74

    cmp	byte [esi + eax + 260], 0
    je	LBB16_74

    movzx	ecx, byte [esi + eax + 257]
    cmp	edx, ecx
    jne	LBB16_74

    mov	byte [esi + eax + 256], 0
    mov	byte [esi + eax + 260], 0
    jmp	LBB16_74
LBB16_79:
    add	al, -14
    cmp	al, -3
    jbe	LBB16_161
LBB16_80:
    test	ebx, ebx
    mov	eax, dword [ebp - 20]
    je	LBB16_82
LBB16_81:
    inc	dword [ebx + 12]
LBB16_82:
    mov	edx, eax
    cmp	byte [ebp - 40], 0
    jns	LBB16_2
    jmp	LBB16_122
LBB16_83:
    mov	eax, -256
    mov	edi, 1
    mov	ebx, dword [ebp + 12]
    jmp	LBB16_86
LBB16_84:
    mov	byte [esi + eax + 256], 0
align 16
LBB16_85:
    add	eax, 16
    je	LBB16_90
LBB16_86:

    cmp	byte [esi + eax + 256], 0
    je	LBB16_85

    movzx	ecx, byte [esi + eax + 257]
    cmp	edx, ecx
    jne	LBB16_85

    cmp	byte [esi + edx + 320], 0
    je	LBB16_84

    mov	byte [esi + eax + 260], 1
    jmp	LBB16_85
LBB16_92:
    mov	byte [esi + edx + 256], al
LBB16_93:
    mov	ebx, dword [ebp + 12]
    test	ebx, ebx
    mov	edi, 1
    mov	edx, dword [ebp - 16]
    jne	LBB16_120
    jmp	LBB16_121
LBB16_94:
    xor	eax, eax
    mov	edi, 1
    mov	ebx, dword [ebp + 12]
    jmp	LBB16_96
align 16
LBB16_95:
    inc	eax
    cmp	eax, 16
    je	LBB16_90
LBB16_96:


    mov	ecx, -256
    jmp	LBB16_99
LBB16_97:
    mov	byte [esi + ecx + 256], 0
align 16
LBB16_98:
    add	ecx, 16
    je	LBB16_95
LBB16_99:


    cmp	byte [esi + ecx + 256], 0
    je	LBB16_98

    movzx	edx, byte [esi + ecx + 257]
    cmp	eax, edx
    jne	LBB16_98

    cmp	byte [esi + eax + 320], 0
    je	LBB16_97

    mov	byte [esi + ecx + 260], 1
    jmp	LBB16_98
LBB16_90:
    test	ebx, ebx
    je	LBB16_91

    inc	dword [ebx + 40]
    jmp	LBB16_119
LBB16_105:
    mov	ebx, dword [ebp + 12]
    test	ebx, ebx
    mov	byte [esi + edx + 288], al
    mov	edi, 1
    je	LBB16_91

    inc	dword [ebx + 20]
    jmp	LBB16_119
LBB16_107:
    mov	ebx, dword [ebp + 12]
    test	ebx, ebx
    mov	byte [esi + edx + 272], al
    mov	edi, 1
    je	LBB16_91

    inc	dword [ebx + 24]
    jmp	LBB16_119
LBB16_109:
    cmp	al, 64
    movzx	ecx, byte [esi + edx + 320]
    setae	byte [esi + edx + 320]
    test	cl, cl
    mov	edi, 1
    mov	ebx, dword [ebp + 12]
    je	LBB16_117

    cmp	al, 63
    ja	LBB16_117

    mov	eax, -256
    jmp	LBB16_113
align 16
LBB16_112:
    add	eax, 16
    je	LBB16_117
LBB16_113:

    cmp	byte [esi + eax + 256], 0
    je	LBB16_112

    cmp	byte [esi + eax + 260], 0
    je	LBB16_112

    movzx	ecx, byte [esi + eax + 257]
    cmp	edx, ecx
    jne	LBB16_112

    mov	byte [esi + eax + 256], 0
    mov	byte [esi + eax + 260], 0
    jmp	LBB16_112
LBB16_117:
    test	ebx, ebx
    je	LBB16_91

    inc	dword [ebx + 28]
LBB16_119:
    mov	edx, dword [ebp - 16]
LBB16_120:
    inc	dword [ebx + 12]
    cmp	byte [ebp - 40], 0
    jns	LBB16_2
    jmp	LBB16_122
LBB16_91:
    mov	edx, dword [ebp - 16]
align 16
LBB16_121:
    cmp	byte [ebp - 40], 0
    jns	LBB16_2
LBB16_122:
    xor	edi, edi
    mov	ecx, dword [ebp - 24]
    mov	dword [ebp - 16], edx
    sub	ecx, edx
    mov	esi, dword [ebp - 36]
    jb	LBB16_124

    mov	edi, ecx
LBB16_124:
    mov	edx, edi
    mov	edi, dword [ebp - 28]
    jbe	LBB16_159

    mov	eax, dword [ebp - 16]
    movzx	ecx, byte [edi + eax]
    mov	ebx, ecx
    and	ebx, 127
    test	cl, cl
    js	LBB16_127

    inc	eax
    mov	dword [ebp - 16], eax
    jmp	LBB16_137
LBB16_127:
    cmp	edx, 1
    je	LBB16_159

    mov	ecx, dword [ebp - 16]
    movzx	eax, byte [edi + ecx + 1]
    mov	dword [ebp - 32], eax
    mov	eax, ebx
    shl	eax, 7
    mov	ebx, dword [ebp - 32]
    and	ebx, 127
    or	ebx, eax
    cmp	byte [ebp - 32], 0
    js	LBB16_130

    add	ecx, 2
    mov	dword [ebp - 16], ecx
    jmp	LBB16_137
LBB16_130:
    cmp	edx, 2
    je	LBB16_159

    mov	ecx, dword [ebp - 16]
    movzx	eax, byte [edi + ecx + 2]
    mov	dword [ebp - 32], eax
    mov	eax, ebx
    shl	eax, 7
    mov	ebx, dword [ebp - 32]
    and	ebx, 127
    or	ebx, eax
    cmp	byte [ebp - 32], 0
    js	LBB16_134

    add	ecx, 3
    mov	dword [ebp - 16], ecx
    jmp	LBB16_137
LBB16_133:
    mov	edx, dword [ebp - 20]
    cmp	byte [ebp - 40], 0
    jns	LBB16_2
    jmp	LBB16_122
LBB16_134:
    cmp	edx, 3
    je	LBB16_159

    mov	eax, dword [ebp - 16]
    movzx	eax, byte [edi + eax + 3]
    test	al, al
    js	LBB16_159

    add	dword [ebp - 16], 4
    shl	ebx, 7
    and	eax, 127
    or	ebx, eax
align 16
LBB16_137:
    mov	ecx, dword [esi + 400]
    mov	eax, ecx
    shr	eax, 2
    mov	edx, 981706811
    mul	edx
    shr	edx, 3
    cmp	ecx, 140
    mov	ecx, 1
    jb	LBB16_138

    mov	ecx, edx
    test	ebx, ebx
    je	LBB16_141
LBB16_139:
    test	ecx, ecx
    jne	LBB16_142
    jmp	LBB16_143
align 16
LBB16_138:
    test	ebx, ebx
    jne	LBB16_139
LBB16_141:
    mov	ecx, edx
    test	ecx, ecx
    je	LBB16_143
LBB16_142:
    mov	eax, ecx
    mul	ebx
    mov	edx, -1
    jo	LBB16_144
LBB16_143:
    imul	ecx, ebx
    mov	edx, ecx
LBB16_144:
    mov	eax, dword [ebp + 8]
    mov	eax, dword [eax + 12]
    add	edx, eax
    mov	ecx, -1
    jb	LBB16_146

    mov	ecx, edx
LBB16_146:
    cmp	eax, -1
    mov	edi, 1
    mov	ebx, dword [ebp + 12]
    je	LBB16_148

    mov	eax, ecx
LBB16_148:
    mov	ecx, esi
    mov	edx, dword [ebp + 8]
    push	ebx
    push	eax
    call	synth_render_until
    add	esp, 8
    mov	edx, dword [ebp - 16]
    cmp	edx, dword [ebp - 24]
    jb	LBB16_3
    jmp	LBB16_163
LBB16_161:
    xor	edi, edi
    test	ebx, ebx
    je	LBB16_163

    inc	dword [ebx + 56]
    jmp	LBB16_163
LBB16_159:
    xor	edi, edi
    mov	eax, dword [ebp + 12]
    test	eax, eax
    je	LBB16_163

    inc	dword [eax + 56]
    jmp	LBB16_163
LBB16_150:
    test	ebx, ebx
    je	LBB16_152

    inc	dword [ebx + 52]
LBB16_152:
    mov	byte [esi], 0
    mov	byte [esi + 4], 0
    mov	byte [esi + 16], 0
    mov	byte [esi + 20], 0
    mov	byte [esi + 32], 0
    mov	byte [esi + 36], 0
    mov	byte [esi + 48], 0
    mov	byte [esi + 52], 0
    mov	byte [esi + 64], 0
    mov	byte [esi + 68], 0
    mov	byte [esi + 80], 0
    mov	byte [esi + 84], 0
    mov	byte [esi + 96], 0
    mov	byte [esi + 100], 0
    mov	byte [esi + 112], 0
    mov	byte [esi + 116], 0
    mov	byte [esi + 128], 0
    mov	byte [esi + 132], 0
    mov	byte [esi + 144], 0
    mov	byte [esi + 148], 0
    mov	byte [esi + 160], 0
    mov	byte [esi + 164], 0
    mov	byte [esi + 176], 0
    mov	byte [esi + 180], 0
    mov	byte [esi + 192], 0
    mov	byte [esi + 196], 0
    mov	byte [esi + 208], 0
    mov	byte [esi + 212], 0
    mov	byte [esi + 224], 0
    mov	byte [esi + 228], 0
    mov	byte [esi + 240], 0
    mov	byte [esi + 244], 0
    mov	edi, 1
LBB16_163:
    mov	eax, edi
    add	esp, 28
    pop	esi
    pop	edi
    pop	ebx
    pop	ebp
    ret
Lfunc_end16:
section .rodata
align 4
LJTI16_0:
dd LBB16_8
dd LBB16_17
dd LBB16_29
dd LBB16_20
dd LBB16_51
dd LBB16_161
dd LBB16_150
LJTI16_1:
dd LBB16_54
dd LBB16_93
dd LBB16_93
dd LBB16_92
dd LBB16_105
dd LBB16_107
dd LBB16_93
dd LBB16_93
dd LBB16_109
dd LBB16_93
dd LBB16_83
dd LBB16_94

section .text
align 16
render_midi_pass:

    push	ebp
    mov	ebp, esp
    push	ebx
    push	edi
    push	esi
    sub	esp, 36
    mov	esi, dword [ecx + 4]
    bswap	esi
    lea	edi, [esi - 65]
    xor	eax, eax
    cmp	edi, -59
    jb	LBB17_144

    movzx	ebx, byte [ecx + 11]
    or	bl, byte [ecx + 10]
    je	LBB17_144

    cmp	byte [ecx + esi + 8], 77
    jne	LBB17_144

    lea	esi, [ecx + esi + 8]
    cmp	byte [esi + 1], 84
    jne	LBB17_144

    cmp	byte [esi + 2], 114
    jne	LBB17_144

    cmp	byte [esi + 3], 107
    jne	LBB17_144

    mov	eax, dword [esi + 4]
    bswap	eax
    mov	dword [ebp - 36], eax
    test	eax, eax
    je	LBB17_143

    movzx	eax, word [ecx + 12]
    rol	ax, 8
    movzx	eax, ax
    lea	ecx, [eax - 1]
    cmp	ecx, 32767
    jb	LBB17_8

    mov	dword [ebp - 48], 96000
    jmp	LBB17_10
LBB17_8:
    imul	eax, eax, 1000
    mov	dword [ebp - 48], eax
LBB17_10:
    add	esi, 8
    mov	dword [ebp - 44], 0
    mov	dword [ebp - 40], 500000
    xor	ebx, ebx
    mov	dword [ebp - 20], edx
    mov	dword [ebp - 16], esi
    jmp	LBB17_11
LBB17_72:
    add	ebx, edi
LBB17_142:
    cmp	ebx, dword [ebp - 36]
    jae	LBB17_143
LBB17_11:


    mov	ecx, dword [ebp + 8]
    mov	eax, dword [ecx + 16]
    cmp	eax, dword [ecx + 4]
    jae	LBB17_143

    xor	edi, edi
    mov	eax, dword [ebp - 36]
    sub	eax, ebx
    jb	LBB17_14

    mov	edi, eax
LBB17_14:
    movzx	eax, byte [esi + ebx]
    mov	ecx, eax
    and	ecx, 127
    test	al, al
    js	LBB17_15

    inc	ebx
    jmp	LBB17_26
LBB17_15:
    xor	eax, eax
    cmp	edi, 1
    je	LBB17_144

    movzx	edx, byte [esi + ebx + 1]
    mov	esi, ecx
    shl	esi, 7
    mov	ecx, edx
    and	ecx, 127
    or	ecx, esi
    test	dl, dl
    js	LBB17_19

    add	ebx, 2
    jmp	LBB17_18
LBB17_19:
    cmp	edi, 2
    je	LBB17_144

    mov	esi, dword [ebp - 16]
    movzx	esi, byte [esi + ebx + 2]
    mov	dword [ebp - 24], esi
    mov	esi, ecx
    shl	esi, 7
    mov	ecx, dword [ebp - 24]
    and	ecx, 127
    or	ecx, esi
    cmp	byte [ebp - 24], 0
    js	LBB17_22

    mov	edx, ebx
    add	edx, 3
    mov	ebx, edx
LBB17_18:
    mov	esi, dword [ebp - 16]
    mov	edx, dword [ebp - 20]
LBB17_26:
    test	ecx, ecx
    mov	dword [ebp - 24], ebx
    je	LBB17_27

    mov	esi, 1
    cmp	dword [ebp - 40], 1000
    mov	ebx, 1
    jb	LBB17_30

    mov	eax, dword [ebp - 40]
    mov	edx, 274877907
    mul	edx
    mov	ebx, edx
    mov	edx, dword [ebp - 20]
    shr	ebx, 6
LBB17_30:
    imul	ebx, dword [edx + 400]
    mov	eax, ebx
    xor	edx, edx
    mov	edi, dword [ebp - 48]
    div	edi
    cmp	edi, ebx
    ja	LBB17_32

    mov	esi, eax
LBB17_32:
    mov	eax, esi
    mul	ecx
    mov	edi, -1
    mov	ebx, dword [ebp - 24]
    jo	LBB17_34

    imul	esi, ecx
    mov	edi, esi
LBB17_34:
    mov	edx, dword [ebp - 20]
    mov	esi, dword [ebp - 16]
    jmp	LBB17_35
LBB17_27:
    xor	edi, edi
LBB17_35:
    mov	eax, dword [ebp + 8]
    mov	eax, dword [eax + 12]
    add	edi, eax
    mov	ecx, -1
    jb	LBB17_37

    mov	ecx, edi
LBB17_37:
    cmp	eax, -1
    je	LBB17_39

    mov	eax, ecx
LBB17_39:
    mov	ecx, edx
    mov	edx, dword [ebp + 8]
    push	dword [ebp + 12]
    push	eax
    call	synth_render_until
    add	esp, 8
    xor	eax, eax
    cmp	ebx, dword [ebp - 36]
    jae	LBB17_144

    movzx	ebx, byte [esi + ebx]
    test	bl, bl
    js	LBB17_42

    mov	edi, dword [ebp - 44]
    test	edi, edi
    mov	dword [ebp - 32], ebx
    mov	edx, dword [ebp - 20]
    jne	LBB17_45
    jmp	LBB17_144
LBB17_42:
    cmp	bl, -16
    mov	ecx, ebx
    mov	edx, dword [ebp - 20]
    jb	LBB17_44

    mov	ecx, dword [ebp - 44]
LBB17_44:
    mov	dword [ebp - 32], 0
    mov	edi, ebx
    mov	dword [ebp - 44], ecx
LBB17_45:
    mov	ecx, dword [ebp - 24]
    inc	ecx
    cmp	edi, 240
    je	LBB17_73

    cmp	edi, 247
    je	LBB17_73

    cmp	edi, 255
    jne	LBB17_89

    cmp	ecx, dword [ebp - 36]
    mov	ebx, dword [ebp - 24]
    jae	LBB17_144

    lea	esi, [ebx + 2]
    xor	eax, eax
    mov	ecx, dword [ebp - 36]
    sub	ecx, esi
    mov	edi, 0
    jb	LBB17_51

    mov	edi, ecx
LBB17_51:
    mov	esi, dword [ebp - 16]
    jbe	LBB17_144

    movzx	ecx, byte [esi + ebx + 1]
    mov	byte [ebp - 32], cl
    movzx	edx, byte [esi + ebx + 2]
    mov	ecx, ebx
    mov	ebx, edx
    and	ebx, 127
    test	dl, dl
    js	LBB17_53

    add	ecx, 3
    jmp	LBB17_63
LBB17_73:
    xor	eax, eax
    mov	edi, dword [ebp - 36]
    sub	edi, ecx
    mov	ecx, 0
    jb	LBB17_75

    mov	ecx, edi
LBB17_75:
    mov	ebx, dword [ebp - 24]
    jbe	LBB17_144

    mov	dword [ebp - 32], ecx
    movzx	ecx, byte [esi + ebx + 1]
    mov	edi, ecx
    and	edi, 127
    test	cl, cl
    js	LBB17_77

    add	ebx, 2
    jmp	LBB17_87
LBB17_89:
    mov	esi, edi
    and	esi, 240
    and	edi, 15
    mov	dword [ebp - 28], edi
    mov	edi, esi
    or	esi, 16
    cmp	esi, 208
    jne	LBB17_97

    test	bl, bl
    mov	esi, dword [ebp - 16]
    js	LBB17_92

    mov	ebx, ecx
    mov	ecx, dword [ebp - 32]
    jmp	LBB17_94
LBB17_77:
    cmp	dword [ebp - 32], 1
    je	LBB17_144

    movzx	ecx, byte [esi + ebx + 2]
    mov	esi, edi
    shl	esi, 7
    mov	edi, ecx
    and	edi, 127
    or	edi, esi
    test	cl, cl
    js	LBB17_80

    add	ebx, 3
    mov	esi, dword [ebp - 16]
    jmp	LBB17_87
LBB17_53:
    cmp	edi, 1
    je	LBB17_144

    mov	ecx, dword [ebp - 24]
    movzx	edx, byte [esi + ecx + 3]
    mov	esi, ebx
    shl	esi, 7
    mov	ebx, edx
    and	ebx, 127
    or	ebx, esi
    test	dl, dl
    js	LBB17_56

    add	ecx, 4
    jmp	LBB17_63
LBB17_97:
    test	bl, bl
    mov	esi, dword [ebp - 16]
    jns	LBB17_100

    cmp	ecx, dword [ebp - 36]
    jae	LBB17_144

    mov	ebx, edi
    mov	ecx, dword [ebp - 24]
    movzx	edi, byte [esi + ecx + 1]
    mov	dword [ebp - 32], edi
    add	ecx, 2
    mov	edi, ebx
LBB17_100:
    cmp	ecx, dword [ebp - 36]
    jae	LBB17_144

    lea	ebx, [ecx + 1]
    add	edi, -128
    shr	edi, 4
    cmp	edi, 6
    ja	LBB17_142

    movzx	eax, byte [esi + ecx]
    jmp	dword [4*edi + LJTI17_0]
LBB17_103:
    mov	ecx, edx
    mov	edx, dword [ebp - 28]
    push	dword [ebp + 12]
    push	dword [ebp - 32]
    call	synth_note_off
    jmp	LBB17_141
LBB17_80:
    cmp	dword [ebp - 32], 2
    je	LBB17_144

    mov	esi, dword [ebp - 16]
    mov	ebx, dword [ebp - 24]
    movzx	ecx, byte [esi + ebx + 3]
    mov	esi, edi
    shl	esi, 7
    mov	edi, ecx
    and	edi, 127
    or	edi, esi
    test	cl, cl
    js	LBB17_83

    add	ebx, 4
    mov	esi, dword [ebp - 16]
    jmp	LBB17_87
LBB17_92:
    cmp	ecx, dword [ebp - 36]
    mov	ebx, dword [ebp - 24]
    jae	LBB17_144

    movzx	ecx, byte [esi + ebx + 1]
    add	ebx, 2
LBB17_94:
    cmp	edi, 192
    jne	LBB17_142

    and	cl, 127
    mov	eax, dword [ebp + 12]
    test	eax, eax
    mov	edi, dword [ebp - 28]
    mov	byte [edx + edi + 304], cl
    je	LBB17_142

    inc	dword [eax + 16]
    jmp	LBB17_142
LBB17_22:
    cmp	edi, 3
    mov	edx, dword [ebp - 20]
    je	LBB17_144

    mov	esi, dword [ebp - 16]
    mov	edi, ebx
    movzx	ebx, byte [esi + ebx + 3]
    test	bl, bl
    js	LBB17_144

    add	edi, 4
    shl	ecx, 7
    and	ebx, 127
    or	ecx, ebx
    mov	ebx, edi
    jmp	LBB17_26
LBB17_56:
    cmp	edi, 2
    je	LBB17_144

    mov	esi, dword [ebp - 16]
    mov	ecx, dword [ebp - 24]
    movzx	edx, byte [esi + ecx + 4]
    mov	esi, ebx
    shl	esi, 7
    mov	ebx, edx
    and	ebx, 127
    or	ebx, esi
    mov	dword [ebp - 28], ebx
    test	dl, dl
    js	LBB17_59

    add	ecx, 5
    mov	ebx, dword [ebp - 28]
    jmp	LBB17_63
LBB17_83:
    cmp	dword [ebp - 32], 3
    je	LBB17_144

    mov	esi, dword [ebp - 16]
    mov	ebx, dword [ebp - 24]
    movzx	ecx, byte [esi + ebx + 4]
    test	cl, cl
    js	LBB17_144

    add	ebx, 5
    shl	edi, 7
    and	ecx, 127
    or	edi, ecx
LBB17_87:
    mov	ecx, dword [ebp - 36]
    sub	ecx, ebx
    cmp	edi, ecx
    ja	LBB17_144

    add	edi, ebx
    mov	ebx, edi
    jmp	LBB17_142
LBB17_105:
    mov	edi, dword [ebp - 32]
    cmp	edi, 63
    jle	LBB17_106

    cmp	edi, 120
    jg	LBB17_119

    cmp	edi, 64
    je	LBB17_128

    cmp	edi, 120
    jne	LBB17_137

    mov	eax, -256
    jmp	LBB17_115
LBB17_118:
    add	eax, 16
    je	LBB17_137
LBB17_115:

    cmp	byte [edx + eax + 256], 0
    je	LBB17_118

    movzx	ecx, byte [edx + eax + 257]
    cmp	dword [ebp - 28], ecx
    jne	LBB17_118

    mov	byte [edx + eax + 256], 0
    mov	byte [edx + eax + 260], 0
    jmp	LBB17_118
LBB17_104:
    mov	ecx, edx
    mov	edx, dword [ebp - 28]
    push	dword [ebp + 12]
    push	eax
    push	dword [ebp - 32]
    call	synth_note_on
    mov	edx, dword [ebp - 20]
    add	esp, 12
    jmp	LBB17_142
LBB17_140:
    and	eax, 127
    shl	eax, 7
    mov	edi, dword [ebp - 32]
    and	edi, 127
    or	edi, eax
    mov	ecx, edx
    mov	edx, dword [ebp - 28]
    push	dword [ebp + 12]
    push	edi
    call	synth_set_pitch_bend
LBB17_141:
    mov	edx, dword [ebp - 20]
    add	esp, 8
    jmp	LBB17_142
LBB17_59:
    cmp	edi, 3
    je	LBB17_144

    mov	esi, dword [ebp - 16]
    mov	ecx, dword [ebp - 24]
    movzx	ebx, byte [esi + ecx + 5]
    test	bl, bl
    js	LBB17_144

    add	ecx, 6
    mov	edx, dword [ebp - 28]
    shl	edx, 7
    and	ebx, 127
    or	edx, ebx
    mov	ebx, edx
LBB17_63:
    mov	edx, dword [ebp - 20]
    mov	esi, dword [ebp - 36]
    sub	esi, ecx
    cmp	ebx, esi
    mov	esi, dword [ebp - 16]
    ja	LBB17_144

    movzx	eax, byte [ebp - 32]
    cmp	al, 47
    je	LBB17_65

    mov	edi, ecx
    cmp	al, 81
    jne	LBB17_72

    cmp	ebx, 3
    jne	LBB17_72

    mov	dword [ebp - 24], edi
    movzx	eax, byte [esi + edi]
    shl	eax, 16
    mov	ecx, dword [ebp - 24]
    movzx	ecx, byte [esi + ecx + 1]
    shl	ecx, 8
    or	ecx, eax
    mov	eax, dword [ebp - 24]
    movzx	eax, byte [esi + eax + 2]
    or	eax, ecx
    test	eax, eax
    mov	dword [ebp - 40], 500000
    je	LBB17_70

    mov	dword [ebp - 40], eax
LBB17_70:
    mov	eax, dword [ebp + 12]
    test	eax, eax
    je	LBB17_72

    inc	dword [eax + 48]
    jmp	LBB17_72
LBB17_106:
    cmp	edi, 7
    je	LBB17_136

    cmp	edi, 10
    je	LBB17_126

    cmp	edi, 11
    jne	LBB17_137

    and	al, 127
    cmp	dword [ebp + 12], 0
    mov	ecx, dword [ebp - 28]
    mov	byte [edx + ecx + 272], al
    je	LBB17_142

    mov	eax, dword [ebp + 12]
    inc	dword [eax + 24]
    inc	dword [eax + 12]
    jmp	LBB17_142
LBB17_119:
    cmp	edi, 121
    je	LBB17_130

    cmp	edi, 123
    jne	LBB17_137

    mov	eax, -256
    mov	esi, dword [ebp - 28]
    jmp	LBB17_122
LBB17_131:
    mov	byte [edx + eax + 256], 0
LBB17_132:
    add	eax, 16
    je	LBB17_133
LBB17_122:

    cmp	byte [edx + eax + 256], 0
    je	LBB17_132

    movzx	ecx, byte [edx + eax + 257]
    cmp	esi, ecx
    jne	LBB17_132

    cmp	byte [edx + esi + 320], 0
    je	LBB17_131

    mov	byte [edx + eax + 260], 1
    jmp	LBB17_132
LBB17_136:
    and	al, 127
    mov	ecx, dword [ebp - 28]
    mov	byte [edx + ecx + 256], al
    jmp	LBB17_137
LBB17_128:
    and	eax, 127
    mov	ecx, edx
    mov	edx, dword [ebp - 28]
    push	eax
    call	synth_set_sustain
    add	esp, 4
    mov	eax, dword [ebp + 12]
    test	eax, eax
    je	LBB17_129

    inc	dword [eax + 28]
    mov	edx, dword [ebp - 20]
    jmp	LBB17_139
LBB17_130:
    mov	ecx, edx
    mov	edx, dword [ebp - 28]
    call	synth_reset_channel_controls
    mov	edx, dword [ebp - 20]
LBB17_137:
    mov	eax, dword [ebp + 12]
    test	eax, eax
    je	LBB17_142
LBB17_139:
    inc	dword [eax + 12]
    jmp	LBB17_142
LBB17_133:
    cmp	dword [ebp + 12], 0
    je	LBB17_134

    mov	eax, dword [ebp + 12]
    inc	dword [eax + 40]
    mov	esi, dword [ebp - 16]
    inc	dword [eax + 12]
    jmp	LBB17_142
LBB17_126:
    and	al, 127
    cmp	dword [ebp + 12], 0
    mov	ecx, dword [ebp - 28]
    mov	byte [edx + ecx + 288], al
    je	LBB17_142

    mov	eax, dword [ebp + 12]
    inc	dword [eax + 20]
    inc	dword [eax + 12]
    jmp	LBB17_142
LBB17_129:
    mov	edx, dword [ebp - 20]
    jmp	LBB17_142
LBB17_134:
    mov	esi, dword [ebp - 16]
    jmp	LBB17_142
LBB17_65:
    mov	ecx, edx
    call	synth_all_sounds_off
LBB17_143:
    mov	eax, 1
LBB17_144:
    add	esp, 36
    pop	esi
    pop	edi
    pop	ebx
    pop	ebp
    ret
Lfunc_end17:
section .rodata
align 4
LJTI17_0:
dd LBB17_103
dd LBB17_104
dd LBB17_142
dd LBB17_105
dd LBB17_142
dd LBB17_142
dd LBB17_140

section .text
align 16
synth_render_until:

    push	ebp
    mov	ebp, esp
    push	ebx
    push	edi
    push	esi
    sub	esp, 24
    mov	edi, edx
    mov	eax, dword [edx + 12]
    cmp	eax, dword [ebp + 8]
    jae	LBB18_39

    mov	dword [ebp - 28], edi
    mov	dword [ebp - 24], ecx
    jmp	LBB18_2
align 16
LBB18_36:
    mov	ebx, dword [edi]
    mov	edx, dword [edi + 16]
    lea	esi, [edx + 1]
    mov	dword [edi + 16], esi
    mov	byte [ebx + edx], al
LBB18_37:
    mov	eax, dword [ebp - 32]
    inc	eax
    cmp	eax, dword [ebp + 8]
    je	LBB18_38
LBB18_2:

    mov	dword [ebp - 32], eax
    mov	eax, dword [edi + 16]
    cmp	eax, dword [edi + 4]
    jae	LBB18_3

    xor	esi, esi
    mov	edi, -256
    xor	ebx, ebx
    jmp	LBB18_5
align 16
LBB18_16:
    mov	esi, dword [ebp - 16]
    mov	ebx, dword [ebp - 20]
    mov	ecx, dword [ebp - 24]
LBB18_20:
    add	esi, eax
    add	edx, dword [ecx + edi + 268]
    movzx	eax, dx
    mov	dword [ecx + edi + 264], eax
    inc	ebx
LBB18_21:
    add	edi, 16
    je	LBB18_22
LBB18_5:

    cmp	byte [ecx + edi + 256], 0
    je	LBB18_21

    mov	dword [ebp - 20], ebx
    mov	dword [ebp - 16], esi
    movzx	eax, byte [ecx + edi + 259]
    movzx	esi, byte [ecx + edi + 257]
    movzx	edx, byte [ecx + esi + 256]
    imul	edx, eax
    imul	eax, edx, 517
    shr	eax, 16
    sub	edx, eax
    movzx	edx, dx
    shr	edx, 1
    add	edx, eax
    shr	edx, 6
    movzx	eax, byte [ecx + esi + 272]
    imul	eax, edx
    mov	edx, 33818641
    mul	edx
    mov	ebx, edx
    imul	ebx, dword [ecx + 404]
    mov	eax, ebx
    mov	edx, 33818641
    mul	edx
    sub	ebx, edx
    shr	ebx, 1
    add	ebx, edx
    shr	ebx, 6
    movzx	eax, byte [ecx + esi + 288]
    mov	ecx, esi
    cmp	eax, 65
    jae	LBB18_7

    mov	edx, 64
    sub	edx, eax
    mov	eax, edx
    jmp	LBB18_9
align 16
LBB18_7:
    add	eax, -64
LBB18_9:
    shr	eax, 1
    mov	edx, 127
    sub	edx, eax
    imul	ebx, edx
    mov	eax, dword [ebp - 24]
    cmp	byte [eax + edi + 260], 0
    mov	esi, 127
    je	LBB18_11

    mov	esi, 254
LBB18_11:
    mov	eax, ebx
    xor	edx, edx
    div	esi
    cmp	eax, 1
    adc	eax, 0
    cmp	eax, 127
    jb	LBB18_13

    mov	eax, 127
LBB18_13:
    cmp	ecx, 9
    mov	ecx, dword [ebp - 24]
    mov	edx, dword [ecx + edi + 264]
    movzx	ebx, dx
    jne	LBB18_17

    movzx	esi, byte [ecx + edi + 258]
    shl	esi, 9
    mov	dword [ebp - 36], ebx
    movzx	ebx, byte [ecx + edi + 261]
    shl	ebx, 4
    xor	ebx, esi
    xor	ebx, dword [ebp - 36]
    mov	ecx, ebx
    shr	ecx, 7
    xor	ecx, ebx
    mov	ebx, ecx
    shr	ebx, 3
    xor	ebx, ecx
    test	bl, 1
    jne	LBB18_16

    neg	eax
    jmp	LBB18_16
align 16
LBB18_17:
    movzx	esi, byte [ecx + edi + 261]
    shr	esi, 1
    and	esi, 12
    cmp	ebx, dword [esi + Lswitch.table.synth_render_until]
    mov	ebx, dword [ebp - 20]
    jb	LBB18_19

    neg	eax
LBB18_19:
    mov	esi, dword [ebp - 16]
    jmp	LBB18_20
align 16
LBB18_22:
    test	ebx, ebx
    je	LBB18_23

    cmp	ebx, 5
    mov	edi, dword [ebp - 28]
    jae	LBB18_26

    mov	ebx, 4
LBB18_26:
    mov	eax, esi
    cdq
    idiv	ebx
    mov	esi, eax
    cmp	esi, -129
    jg	LBB18_30
LBB18_28:
    xor	eax, eax
    cmp	dword [ebp + 12], 0
    jne	LBB18_29
    jmp	LBB18_34
align 16
LBB18_23:
    mov	edi, dword [ebp - 28]
    cmp	esi, -129
    jle	LBB18_28
LBB18_30:
    cmp	dword [ebp + 12], 0
    sete	al
    cmp	esi, 128
    setl	dl
    cmp	esi, 127
    jl	LBB18_32

    mov	esi, 127
LBB18_32:
    or	dl, al
    mov	eax, 255
    je	LBB18_29

    sub	esi, -128
    mov	eax, esi
    jmp	LBB18_34
align 16
LBB18_29:
    mov	edx, dword [ebp + 12]
    inc	dword [edx + 64]
LBB18_34:
    mov	edx, dword [edi + 8]
    test	edx, edx
    je	LBB18_36

    dec	edx
    mov	dword [edi + 8], edx
    jmp	LBB18_37
LBB18_3:
    mov	eax, dword [ebp - 32]
    jmp	LBB18_39
LBB18_38:
    mov	eax, dword [ebp + 8]
LBB18_39:
    mov	dword [edi + 12], eax
    add	esp, 24
    pop	esi
    pop	edi
    pop	ebx
    pop	ebp
    ret
Lfunc_end18:

align 16
synth_note_off:

    push	ebp
    mov	ebp, esp
    push	ebx
    push	edi
    push	esi
    mov	esi, -256
    mov	eax, dword [ebp + 12]
    mov	edi, dword [ebp + 8]
    jmp	LBB19_1
LBB19_6:
    mov	byte [ecx + esi + 260], bl
align 16
LBB19_7:
    add	esi, 16
    je	LBB19_8
LBB19_1:
    cmp	byte [ecx + esi + 256], 0
    je	LBB19_7

    movzx	ebx, byte [ecx + esi + 257]
    cmp	edx, ebx
    jne	LBB19_7

    movzx	ebx, byte [ecx + esi + 258]
    cmp	edi, ebx
    jne	LBB19_7

    mov	bl, 1
    cmp	byte [ecx + edx + 320], 0
    jne	LBB19_6

    mov	byte [ecx + esi + 256], 0
    xor	ebx, ebx
    jmp	LBB19_6
LBB19_8:
    test	eax, eax
    je	LBB19_10

    inc	dword [eax + 8]
LBB19_10:
    pop	esi
    pop	edi
    pop	ebx
    pop	ebp
    ret
Lfunc_end19:

align 16
synth_note_on:

    push	ebp
    mov	ebp, esp
    push	ebx
    push	edi
    push	esi
    sub	esp, 12
    mov	dword [ebp - 16], edx
    mov	edx, dword [ebp + 12]
    mov	eax, dword [ebp + 8]
    cmp	eax, 127
    jb	LBB20_2

    mov	eax, 127
LBB20_2:
    mov	edi, dword [ebp + 16]
    test	edx, edx
    je	LBB20_3

    cmp	edx, 127
    jb	LBB20_15

    mov	edx, 127
LBB20_15:
    lea	esi, [ecx + 2]
    xor	edi, edi
    jmp	LBB20_16
align 16
LBB20_19:
    inc	edi
    add	esi, 16
    cmp	edi, 16
    je	LBB20_20
LBB20_16:
    cmp	byte [esi - 2], 0
    je	LBB20_19

    movzx	ebx, byte [esi - 1]
    cmp	dword [ebp - 16], ebx
    jne	LBB20_19

    movzx	ebx, byte [esi]
    cmp	eax, ebx
    jne	LBB20_19
    jmp	LBB20_80
LBB20_20:
    cmp	byte [ecx], 0
    je	LBB20_21

    cmp	byte [ecx + 16], 0
    je	LBB20_23

    cmp	byte [ecx + 32], 0
    je	LBB20_25

    cmp	byte [ecx + 48], 0
    je	LBB20_27

    cmp	byte [ecx + 64], 0
    je	LBB20_29

    cmp	byte [ecx + 80], 0
    je	LBB20_31

    cmp	byte [ecx + 96], 0
    je	LBB20_33

    cmp	byte [ecx + 112], 0
    je	LBB20_35

    cmp	byte [ecx + 128], 0
    je	LBB20_37

    cmp	byte [ecx + 144], 0
    je	LBB20_39

    cmp	byte [ecx + 160], 0
    je	LBB20_41

    cmp	byte [ecx + 176], 0
    je	LBB20_43

    cmp	byte [ecx + 192], 0
    je	LBB20_45

    cmp	byte [ecx + 208], 0
    je	LBB20_47

    cmp	byte [ecx + 224], 0
    je	LBB20_49

    cmp	byte [ecx + 240], 0
    je	LBB20_51

    mov	dword [ebp - 20], edx
    movzx	edx, byte [ecx + 19]
    movzx	ebx, byte [ecx + 35]
    mov	byte [ebp - 24], bl
    xor	ebx, ebx
    cmp	dl, byte [ecx + 3]
    setb	bl
    mov	edi, ebx
    shl	ebx, 4
    movzx	edx, byte [ebp - 24]
    cmp	dl, byte [ecx + ebx + 3]
    mov	esi, 2
    jb	LBB20_54

    mov	esi, edi
LBB20_54:
    movzx	ebx, byte [ecx + 51]
    mov	edi, esi
    shl	edi, 4
    cmp	bl, byte [ecx + edi + 3]
    mov	edi, 3
    jb	LBB20_56

    mov	edi, esi
LBB20_56:
    movzx	ebx, byte [ecx + 67]
    mov	esi, edi
    shl	esi, 4
    cmp	bl, byte [ecx + esi + 3]
    mov	esi, 4
    mov	edx, dword [ebp - 20]
    jb	LBB20_58

    mov	esi, edi
LBB20_58:
    movzx	ebx, byte [ecx + 83]
    mov	edi, esi
    shl	edi, 4
    cmp	bl, byte [ecx + edi + 3]
    mov	edi, 5
    jb	LBB20_60

    mov	edi, esi
LBB20_60:
    movzx	ebx, byte [ecx + 99]
    mov	esi, edi
    shl	esi, 4
    cmp	bl, byte [ecx + esi + 3]
    mov	esi, 6
    jb	LBB20_62

    mov	esi, edi
LBB20_62:
    movzx	ebx, byte [ecx + 115]
    mov	edi, esi
    shl	edi, 4
    cmp	bl, byte [ecx + edi + 3]
    mov	edi, 7
    jb	LBB20_64

    mov	edi, esi
LBB20_64:
    movzx	ebx, byte [ecx + 131]
    mov	esi, edi
    shl	esi, 4
    cmp	bl, byte [ecx + esi + 3]
    mov	esi, 8
    jb	LBB20_66

    mov	esi, edi
LBB20_66:
    movzx	ebx, byte [ecx + 147]
    mov	edi, esi
    shl	edi, 4
    cmp	bl, byte [ecx + edi + 3]
    mov	edi, 9
    jb	LBB20_68

    mov	edi, esi
LBB20_68:
    movzx	ebx, byte [ecx + 163]
    mov	esi, edi
    shl	esi, 4
    cmp	bl, byte [ecx + esi + 3]
    mov	esi, 10
    jb	LBB20_70

    mov	esi, edi
LBB20_70:
    movzx	ebx, byte [ecx + 179]
    mov	edi, esi
    shl	edi, 4
    cmp	bl, byte [ecx + edi + 3]
    mov	edi, 11
    jb	LBB20_72

    mov	edi, esi
LBB20_72:
    movzx	ebx, byte [ecx + 195]
    mov	esi, edi
    shl	esi, 4
    cmp	bl, byte [ecx + esi + 3]
    mov	esi, 12
    jb	LBB20_74

    mov	esi, edi
LBB20_74:
    movzx	ebx, byte [ecx + 211]
    mov	edi, esi
    shl	edi, 4
    cmp	bl, byte [ecx + edi + 3]
    mov	edi, 13
    jb	LBB20_76

    mov	edi, esi
LBB20_76:
    movzx	ebx, byte [ecx + 227]
    mov	esi, edi
    shl	esi, 4
    cmp	bl, byte [ecx + esi + 3]
    mov	esi, 14
    jb	LBB20_78

    mov	esi, edi
LBB20_78:
    movzx	ebx, byte [ecx + 243]
    mov	edi, esi
    shl	edi, 4
    cmp	bl, byte [ecx + edi + 3]
    mov	edi, 15
    jb	LBB20_80

    mov	edi, esi
    jmp	LBB20_80
LBB20_3:
    mov	edx, -256
    jmp	LBB20_4
LBB20_9:
    mov	byte [ecx + edx + 260], bl
align 16
LBB20_10:
    add	edx, 16
    je	LBB20_11
LBB20_4:
    cmp	byte [ecx + edx + 256], 0
    je	LBB20_10

    movzx	esi, byte [ecx + edx + 257]
    cmp	dword [ebp - 16], esi
    jne	LBB20_10

    movzx	esi, byte [ecx + edx + 258]
    cmp	eax, esi
    jne	LBB20_10

    mov	bl, 1
    mov	esi, dword [ebp - 16]
    cmp	byte [ecx + esi + 320], 0
    jne	LBB20_9

    mov	byte [ecx + edx + 256], 0
    xor	ebx, ebx
    jmp	LBB20_9
LBB20_11:
    test	edi, edi
    je	LBB20_99

    inc	dword [edi + 8]
    jmp	LBB20_99
LBB20_21:
    xor	edi, edi
    jmp	LBB20_80
LBB20_23:
    mov	edi, 1
    jmp	LBB20_80
LBB20_25:
    mov	edi, 2
    jmp	LBB20_80
LBB20_27:
    mov	edi, 3
    jmp	LBB20_80
LBB20_29:
    mov	edi, 4
    jmp	LBB20_80
LBB20_31:
    mov	edi, 5
    jmp	LBB20_80
LBB20_33:
    mov	edi, 6
    jmp	LBB20_80
LBB20_35:
    mov	edi, 7
    jmp	LBB20_80
LBB20_37:
    mov	edi, 8
    jmp	LBB20_80
LBB20_39:
    mov	edi, 9
    jmp	LBB20_80
LBB20_41:
    mov	edi, 10
    jmp	LBB20_80
LBB20_43:
    mov	edi, 11
    jmp	LBB20_80
LBB20_45:
    mov	edi, 12
    jmp	LBB20_80
LBB20_47:
    mov	edi, 13
    jmp	LBB20_80
LBB20_49:
    mov	edi, 14
    jmp	LBB20_80
LBB20_51:
    mov	edi, 15
LBB20_80:
    shl	edi, 4
    mov	byte [ecx + edi], 1
    mov	ebx, dword [ebp - 16]
    mov	byte [ecx + edi + 1], bl
    mov	byte [ecx + edi + 2], al
    mov	byte [ecx + edi + 3], dl
    mov	byte [ecx + edi + 4], 0
    movzx	edx, byte [ecx + ebx + 304]
    mov	byte [ecx + edi + 5], dl
    mov	dword [ecx + edi + 8], 0
    mov	edx, dword [ecx + 400]
    mov	esi, dword [ecx + 4*ebx + 336]
    cmp	esi, 16383
    mov	dword [ebp - 20], esi
    jb	LBB20_82

    mov	esi, 16383
LBB20_82:
    mov	dword [ebp - 24], esi
    test	edx, edx
    mov	ebx, 11025
    je	LBB20_84

    mov	ebx, edx
LBB20_84:
    mov	esi, dword [4*eax + vibe_music_note_freq_x16]
    shl	esi, 12
    mov	eax, esi
    xor	edx, edx
    div	ebx
    cmp	eax, 65535
    jb	LBB20_86

    mov	eax, 65535
LBB20_86:
    cmp	ebx, esi
    mov	edx, 1
    ja	LBB20_88

    mov	edx, eax
LBB20_88:
    cmp	dword [ebp - 20], 8192
    mov	esi, dword [ebp - 24]
    jb	LBB20_90

    add	esi, -8192
    imul	esi, edx
    shr	esi, 15
    add	edx, esi
    jmp	LBB20_92
LBB20_90:
    mov	eax, 8192
    sub	eax, esi
    imul	eax, edx
    shr	eax, 15
    sub	edx, eax
    ja	LBB20_92

    mov	edx, 1
LBB20_92:
    add	edi, ecx
    cmp	edx, 1
    adc	edx, 0
    cmp	edx, 65535
    jb	LBB20_94

    mov	edx, 65535
LBB20_94:
    mov	dword [edi + 12], edx
    mov	edx, dword [ebp + 16]
    test	edx, edx
    je	LBB20_99

    inc	dword [edx + 4]
    cmp	dword [ebp - 16], 9
    jne	LBB20_97

    inc	dword [edx + 36]
LBB20_97:
    xor	eax, eax
    cmp	byte [ecx + 16], 0
    setne	al
    cmp	byte [ecx], 1
    sbb	eax, -1
    cmp	byte [ecx + 32], 1
    sbb	eax, -1
    cmp	byte [ecx + 48], 1
    sbb	eax, -1
    cmp	byte [ecx + 64], 1
    sbb	eax, -1
    cmp	byte [ecx + 80], 1
    sbb	eax, -1
    cmp	byte [ecx + 96], 1
    sbb	eax, -1
    cmp	byte [ecx + 112], 1
    sbb	eax, -1
    cmp	byte [ecx + 128], 1
    sbb	eax, -1
    cmp	byte [ecx + 144], 1
    sbb	eax, -1
    cmp	byte [ecx + 160], 1
    sbb	eax, -1
    cmp	byte [ecx + 176], 1
    sbb	eax, -1
    cmp	byte [ecx + 192], 1
    sbb	eax, -1
    cmp	byte [ecx + 208], 1
    sbb	eax, -1
    cmp	byte [ecx + 224], 1
    sbb	eax, -1
    cmp	byte [ecx + 240], 1
    sbb	eax, -1
    cmp	eax, dword [edx + 44]
    jbe	LBB20_99

    mov	dword [edx + 44], eax
LBB20_99:
    add	esp, 12
    pop	esi
    pop	edi
    pop	ebx
    pop	ebp
    ret
Lfunc_end20:

align 16
synth_set_pitch_bend:

    push	ebp
    mov	ebp, esp
    push	ebx
    push	edi
    push	esi
    sub	esp, 12
    mov	eax, dword [ebp + 8]
    mov	dword [ecx + 4*edx + 336], eax
    mov	ebx, -256
    mov	dword [ebp - 20], edx
    jmp	LBB21_1
align 16
LBB21_19:
    mov	dword [ecx + ebx + 268], edx
    mov	edx, dword [ebp - 20]
LBB21_20:
    add	ebx, 16
    je	LBB21_21
LBB21_1:
    cmp	byte [ecx + ebx + 256], 0
    je	LBB21_20

    movzx	eax, byte [ecx + ebx + 257]
    cmp	edx, eax
    jne	LBB21_20

    mov	eax, dword [ecx + 4*edx + 336]
    cmp	eax, 16383
    mov	dword [ebp - 24], eax
    jb	LBB21_5

    mov	eax, 16383
LBB21_5:
    mov	dword [ebp - 16], eax
    movzx	eax, byte [ecx + ebx + 258]
    cmp	al, 127
    jb	LBB21_7

    mov	al, 127
LBB21_7:
    mov	edx, dword [ecx + 400]
    test	edx, edx
    mov	esi, 11025
    je	LBB21_9

    mov	esi, edx
LBB21_9:
    movzx	eax, al
    mov	edi, dword [4*eax + vibe_music_note_freq_x16]
    shl	edi, 12
    mov	eax, edi
    xor	edx, edx
    div	esi
    cmp	eax, 65535
    jb	LBB21_11

    mov	eax, 65535
LBB21_11:
    cmp	esi, edi
    mov	edx, 1
    ja	LBB21_13

    mov	edx, eax
LBB21_13:
    cmp	dword [ebp - 24], 8192
    jb	LBB21_15

    mov	eax, dword [ebp - 16]
    add	eax, -8192
    imul	eax, edx
    shr	eax, 15
    add	edx, eax
    jmp	LBB21_17
LBB21_15:
    mov	eax, 8192
    sub	eax, dword [ebp - 16]
    imul	eax, edx
    shr	eax, 15
    sub	edx, eax
    ja	LBB21_17

    mov	edx, 1
LBB21_17:
    cmp	edx, 1
    adc	edx, 0
    cmp	edx, 65535
    jb	LBB21_19

    mov	edx, 65535
    jmp	LBB21_19
LBB21_21:
    mov	eax, dword [ebp + 12]
    test	eax, eax
    je	LBB21_23

    inc	dword [eax + 32]
LBB21_23:
    add	esp, 12
    pop	esi
    pop	edi
    pop	ebx
    pop	ebp
    ret
Lfunc_end21:

align 16
synth_reset_channel_controls:

    push	ebp
    mov	ebp, esp
    push	esi
    mov	byte [ecx + edx + 256], 100
    mov	byte [ecx + edx + 272], 127
    mov	byte [ecx + edx + 288], 64
    mov	byte [ecx + edx + 304], 0
    mov	byte [ecx + edx + 320], 0
    mov	dword [ecx + 4*edx + 336], 8192
    mov	eax, -256
    jmp	LBB22_1
align 16
LBB22_5:
    add	eax, 16
    je	LBB22_6
LBB22_1:
    cmp	byte [ecx + eax + 256], 0
    je	LBB22_5

    cmp	byte [ecx + eax + 260], 0
    je	LBB22_5

    movzx	esi, byte [ecx + eax + 257]
    cmp	edx, esi
    jne	LBB22_5

    mov	byte [ecx + eax + 256], 0
    mov	byte [ecx + eax + 260], 0
    jmp	LBB22_5
LBB22_6:
    pop	esi
    pop	ebp
    ret
Lfunc_end22:

align 16
synth_set_sustain:

    push	ebp
    mov	ebp, esp
    push	esi
    cmp	byte [ecx + edx + 320], 0
    sete	al
    cmp	dword [ebp + 8], 64
    setae	ah
    setae	byte [ecx + edx + 320]
    or	ah, al
    test	ah, 1
    je	LBB23_1
LBB23_7:
    pop	esi
    pop	ebp
    ret
LBB23_1:
    mov	eax, -256
    jmp	LBB23_2
align 16
LBB23_6:
    add	eax, 16
    je	LBB23_7
LBB23_2:
    cmp	byte [ecx + eax + 256], 0
    je	LBB23_6

    cmp	byte [ecx + eax + 260], 0
    je	LBB23_6

    movzx	esi, byte [ecx + eax + 257]
    cmp	edx, esi
    jne	LBB23_6

    mov	byte [ecx + eax + 256], 0
    mov	byte [ecx + eax + 260], 0
    jmp	LBB23_6
Lfunc_end23:

align 16
synth_all_sounds_off:

    push	ebp
    mov	ebp, esp
    mov	byte [ecx], 0
    mov	byte [ecx + 4], 0
    mov	byte [ecx + 16], 0
    mov	byte [ecx + 20], 0
    mov	byte [ecx + 32], 0
    mov	byte [ecx + 36], 0
    mov	byte [ecx + 48], 0
    mov	byte [ecx + 52], 0
    mov	byte [ecx + 64], 0
    mov	byte [ecx + 68], 0
    mov	byte [ecx + 80], 0
    mov	byte [ecx + 84], 0
    mov	byte [ecx + 96], 0
    mov	byte [ecx + 100], 0
    mov	byte [ecx + 112], 0
    mov	byte [ecx + 116], 0
    mov	byte [ecx + 128], 0
    mov	byte [ecx + 132], 0
    mov	byte [ecx + 144], 0
    mov	byte [ecx + 148], 0
    mov	byte [ecx + 160], 0
    mov	byte [ecx + 164], 0
    mov	byte [ecx + 176], 0
    mov	byte [ecx + 180], 0
    mov	byte [ecx + 192], 0
    mov	byte [ecx + 196], 0
    mov	byte [ecx + 208], 0
    mov	byte [ecx + 212], 0
    mov	byte [ecx + 224], 0
    mov	byte [ecx + 228], 0
    mov	byte [ecx + 240], 0
    mov	byte [ecx + 244], 0
    pop	ebp
    ret
Lfunc_end24:

section .bss
align 4
vibe_music_songs resb 384
section .rodata
align 4
vibe_music_note_freq_x16:
dd 131
dd 139
dd 147
dd 156
dd 165
dd 175
dd 185
dd 196
dd 208
dd 220
dd 233
dd 247
dd 262
dd 277
dd 294
dd 311
dd 330
dd 349
dd 370
dd 392
dd 415
dd 440
dd 466
dd 494
dd 523
dd 554
dd 587
dd 622
dd 659
dd 698
dd 740
dd 784
dd 831
dd 880
dd 932
dd 988
dd 1047
dd 1109
dd 1175
dd 1245
dd 1319
dd 1397
dd 1480
dd 1568
dd 1661
dd 1760
dd 1865
dd 1976
dd 2093
dd 2217
dd 2349
dd 2489
dd 2637
dd 2794
dd 2960
dd 3136
dd 3322
dd 3520
dd 3729
dd 3951
dd 4186
dd 4435
dd 4699
dd 4978
dd 5274
dd 5588
dd 5920
dd 6272
dd 6645
dd 7040
dd 7459
dd 7902
dd 8372
dd 8870
dd 9397
dd 9956
dd 10548
dd 11175
dd 11840
dd 12544
dd 13290
dd 14080
dd 14917
dd 15804
dd 16744
dd 17740
dd 18795
dd 19912
dd 21096
dd 22351
dd 23680
dd 25088
dd 26580
dd 28160
dd 29834
dd 31609
dd 33488
dd 35479
dd 37589
dd 39824
dd 42192
dd 44701
dd 47359
dd 50175
dd 53159
dd 56320
dd 59669
dd 63217
dd 66976
dd 70959
dd 75178
dd 79649
dd 84385
dd 89402
dd 94719
dd 100351
dd 106318
dd 112640
dd 119338
dd 126434
dd 133952
dd 141918
dd 150356
dd 159297
dd 168769
dd 178805
dd 189437
dd 200702

section .rodata
align 4
Lswitch.table.synth_render_until:
dd 32768
dd 24576
dd 40960
dd 16384
