BITS 32
section .text
global vibe_syscall3
align 16
vibe_syscall3:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	eax, dword [ebp + 8]
	mov	ebx, dword [ebp + 12]
	mov	ecx, dword [ebp + 16]
	mov	edx, dword [ebp + 20]
	int	128
	pop	ebx
	pop	ebp
	ret
Lfunc_end0:
global vibe_syscall_errno
align 16
vibe_syscall_errno:
	push	ebp
	mov	ebp, esp
	mov	ecx, dword [ebp + 8]
	xor	eax, eax
	test	ecx, ecx
	js	LBB1_1
LBB1_5:
	pop	ebp
	ret
LBB1_1:
	cmp	ecx, -1
	je	LBB1_3
	neg	ecx
	mov	eax, ecx
	pop	ebp
	ret
LBB1_3:
	mov	eax, dword [ebp + 12]
	test	eax, eax
	jg	LBB1_5
	mov	eax, 5
	pop	ebp
	ret
Lfunc_end1:
global memcpy
align 16
memcpy:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	esi
	mov	ecx, dword [ebp + 16]
	mov	eax, dword [ebp + 8]
	test	ecx, ecx
	je	LBB2_3
	mov	edx, dword [ebp + 12]
	xor	esi, esi
align 16
LBB2_2:
	movzx	ebx, byte [edx + esi]
	mov	byte [eax + esi], bl
	inc	esi
	cmp	ecx, esi
	jne	LBB2_2
LBB2_3:
	pop	esi
	pop	ebx
	pop	ebp
	ret
Lfunc_end2:
global memmove
align 16
memmove:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	esi
	mov	edx, dword [ebp + 16]
	mov	ecx, dword [ebp + 12]
	mov	eax, dword [ebp + 8]
	cmp	eax, ecx
	jae	LBB3_4
	test	edx, edx
	je	LBB3_7
	xor	esi, esi
align 16
LBB3_3:
	movzx	ebx, byte [ecx + esi]
	mov	byte [eax + esi], bl
	inc	esi
	cmp	edx, esi
	jne	LBB3_3
	jmp	LBB3_7
LBB3_4:
	test	edx, edx
	je	LBB3_7
	mov	esi, edx
align 16
LBB3_6:
	dec	esi
	movzx	ebx, byte [ecx + edx - 1]
	mov	byte [eax + edx - 1], bl
	mov	edx, esi
	jne	LBB3_6
LBB3_7:
	pop	esi
	pop	ebx
	pop	ebp
	ret
Lfunc_end3:
global memset
align 16
memset:
	push	ebp
	mov	ebp, esp
	push	esi
	mov	ecx, dword [ebp + 16]
	mov	eax, dword [ebp + 8]
	test	ecx, ecx
	je	LBB4_3
	mov	edx, dword [ebp + 12]
	mov	esi, eax
align 16
LBB4_2:
	mov	byte [esi], dl
	inc	esi
	dec	ecx
	jne	LBB4_2
LBB4_3:
	pop	esi
	pop	ebp
	ret
Lfunc_end4:
global memcmp
align 16
memcmp:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	mov	ecx, dword [ebp + 16]
	test	ecx, ecx
	je	LBB5_5
	mov	edx, dword [ebp + 12]
	mov	esi, dword [ebp + 8]
	xor	edi, edi
align 16
LBB5_2:
	movzx	eax, byte [esi + edi]
	movzx	ebx, byte [edx + edi]
	cmp	al, bl
	jne	LBB5_3
	inc	edi
	cmp	ecx, edi
	jne	LBB5_2
LBB5_5:
	xor	eax, eax
	jmp	LBB5_6
LBB5_3:
	sub	eax, ebx
LBB5_6:
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
Lfunc_end5:
global memchr
align 16
memchr:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	ecx, dword [ebp + 16]
	xor	eax, eax
	test	ecx, ecx
	je	LBB6_5
	mov	ebx, dword [ebp + 12]
	mov	edx, dword [ebp + 8]
align 16
LBB6_2:
	cmp	byte [edx], bl
	je	LBB6_3
	inc	edx
	dec	ecx
	jne	LBB6_2
	jmp	LBB6_5
LBB6_3:
	mov	eax, edx
LBB6_5:
	pop	ebx
	pop	ebp
	ret
Lfunc_end6:
global strlen
align 16
strlen:
	push	ebp
	mov	ebp, esp
	mov	eax, -1
	mov	ecx, dword [ebp + 8]
align 16
LBB7_1:
	cmp	byte [ecx + eax + 1], 0
	lea	eax, [eax + 1]
	jne	LBB7_1
	pop	ebp
	ret
Lfunc_end7:
global strnlen
align 16
strnlen:
	push	ebp
	mov	ebp, esp
	mov	ecx, dword [ebp + 12]
	test	ecx, ecx
	je	LBB8_1
	mov	edx, dword [ebp + 8]
	xor	eax, eax
align 16
LBB8_3:
	cmp	byte [edx + eax], 0
	je	LBB8_6
	inc	eax
	cmp	ecx, eax
	jne	LBB8_3
	mov	eax, ecx
LBB8_6:
	pop	ebp
	ret
LBB8_1:
	xor	eax, eax
	pop	ebp
	ret
Lfunc_end8:
global strcpy
align 16
strcpy:
	push	ebp
	mov	ebp, esp
	push	ebx
	xor	ecx, ecx
	mov	edx, dword [ebp + 12]
	mov	eax, dword [ebp + 8]
align 16
LBB9_1:
	movzx	ebx, byte [edx + ecx]
	mov	byte [eax + ecx], bl
	inc	ecx
	test	bl, bl
	jne	LBB9_1
	pop	ebx
	pop	ebp
	ret
Lfunc_end9:
global strncpy
align 16
strncpy:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	esi
	mov	ecx, dword [ebp + 16]
	mov	eax, dword [ebp + 8]
	test	ecx, ecx
	je	LBB10_5
	mov	esi, dword [ebp + 12]
	mov	edx, eax
align 16
LBB10_2:
	movzx	ebx, byte [esi]
	test	bl, bl
	je	LBB10_3
	inc	esi
	mov	byte [edx], bl
	inc	edx
	dec	ecx
	jne	LBB10_2
	jmp	LBB10_5
LBB10_3:
	xor	esi, esi
align 16
LBB10_4:
	mov	byte [edx + esi], 0
	inc	esi
	cmp	ecx, esi
	jne	LBB10_4
LBB10_5:
	pop	esi
	pop	ebx
	pop	ebp
	ret
Lfunc_end10:
global strcat
align 16
strcat:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	esi
	mov	ecx, dword [ebp + 12]
	mov	eax, dword [ebp + 8]
	mov	edx, eax
align 16
LBB11_1:
	cmp	byte [edx], 0
	lea	edx, [edx + 1]
	jne	LBB11_1
	xor	esi, esi
align 16
LBB11_3:
	movzx	ebx, byte [ecx + esi]
	mov	byte [edx + esi - 1], bl
	inc	esi
	test	bl, bl
	jne	LBB11_3
	pop	esi
	pop	ebx
	pop	ebp
	ret
Lfunc_end11:
global strncat
align 16
strncat:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	mov	edx, dword [ebp + 16]
	mov	esi, dword [ebp + 12]
	mov	eax, dword [ebp + 8]
	mov	ecx, eax
align 16
LBB12_1:
	mov	edi, ecx
	inc	ecx
	cmp	byte [edi], 0
	jne	LBB12_1
	test	edx, edx
	je	LBB12_7
	neg	edx
	mov	edi, -1
align 16
LBB12_4:
	movzx	ebx, byte [esi + edi + 1]
	test	bl, bl
	je	LBB12_6
	mov	byte [ecx + edi], bl
	lea	ebx, [edx + edi + 1]
	inc	edi
	cmp	ebx, -1
	jne	LBB12_4
LBB12_6:
	add	ecx, edi
	mov	edi, ecx
LBB12_7:
	mov	byte [edi], 0
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
Lfunc_end12:
global strcmp
align 16
strcmp:
	push	ebp
	mov	ebp, esp
	mov	ecx, dword [ebp + 12]
	mov	edx, dword [ebp + 8]
	movzx	eax, byte [edx]
	test	al, al
	je	LBB13_1
	inc	edx
align 16
LBB13_3:
	cmp	al, byte [ecx]
	jne	LBB13_6
	inc	ecx
	movzx	eax, byte [edx]
	inc	edx
	test	al, al
	jne	LBB13_3
	xor	eax, eax
LBB13_6:
	movzx	eax, al
	jmp	LBB13_7
LBB13_1:
	xor	eax, eax
LBB13_7:
	movzx	ecx, byte [ecx]
	sub	eax, ecx
	pop	ebp
	ret
Lfunc_end13:
global strncmp
align 16
strncmp:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	mov	ecx, dword [ebp + 16]
	test	ecx, ecx
	je	LBB14_6
	mov	edx, dword [ebp + 12]
	mov	esi, dword [ebp + 8]
	xor	edi, edi
align 16
LBB14_2:
	movzx	eax, byte [esi + edi]
	test	eax, eax
	movzx	ebx, byte [edx + edi]
	je	LBB14_7
	cmp	al, bl
	jne	LBB14_7
	inc	edi
	cmp	ecx, edi
	jne	LBB14_2
LBB14_6:
	xor	eax, eax
	jmp	LBB14_8
LBB14_7:
	movzx	ecx, bl
	sub	eax, ecx
LBB14_8:
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
Lfunc_end14:
global strcasecmp
align 16
strcasecmp:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	mov	ecx, dword [ebp + 12]
	mov	edx, dword [ebp + 8]
	movzx	eax, byte [edx]
	test	al, al
	je	LBB15_1
	inc	edx
align 16
LBB15_3:
	movzx	esi, al
	lea	edi, [esi - 91]
	cmp	edi, -26
	jb	LBB15_5
	add	esi, 32
LBB15_5:
	movzx	edi, byte [ecx]
	lea	ebx, [edi - 91]
	cmp	ebx, -26
	jb	LBB15_7
	add	edi, 32
LBB15_7:
	cmp	esi, edi
	jne	LBB15_10
	inc	ecx
	movzx	eax, byte [edx]
	inc	edx
	test	al, al
	jne	LBB15_3
	xor	eax, eax
LBB15_10:
	movzx	eax, al
	jmp	LBB15_11
LBB15_1:
	xor	eax, eax
LBB15_11:
	lea	edx, [eax - 91]
	cmp	edx, -26
	jb	LBB15_13
	add	eax, 32
LBB15_13:
	movzx	ecx, byte [ecx]
	lea	edx, [ecx - 91]
	cmp	edx, -26
	jb	LBB15_15
	add	ecx, 32
LBB15_15:
	sub	eax, ecx
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
Lfunc_end15:
global strncasecmp
align 16
strncasecmp:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	push	eax
	cmp	dword [ebp + 16], 0
	je	LBB16_15
	xor	ebx, ebx
align 16
LBB16_2:
	mov	eax, dword [ebp + 8]
	movzx	eax, byte [eax + ebx]
	test	eax, eax
	mov	ecx, dword [ebp + 12]
	movzx	esi, byte [ecx + ebx]
	je	LBB16_3
	lea	ecx, [eax - 91]
	cmp	ecx, -26
	mov	edx, eax
	jb	LBB16_11
	lea	edx, [eax + 32]
LBB16_11:
	lea	edi, [esi - 91]
	lea	ecx, [esi + 32]
	mov	dword [ebp - 16], ecx
	cmp	edi, -26
	mov	ecx, esi
	jb	LBB16_13
	mov	ecx, dword [ebp - 16]
LBB16_13:
	cmp	edx, ecx
	jne	LBB16_4
	inc	ebx
	cmp	dword [ebp + 16], ebx
	jne	LBB16_2
LBB16_15:
	xor	eax, eax
	jmp	LBB16_16
LBB16_3:
	lea	edi, [esi - 91]
	lea	eax, [esi + 32]
	mov	dword [ebp - 16], eax
	xor	eax, eax
LBB16_4:
	lea	ecx, [eax - 91]
	cmp	ecx, -26
	jb	LBB16_6
	add	eax, 32
LBB16_6:
	cmp	edi, -26
	jb	LBB16_8
	mov	esi, dword [ebp - 16]
LBB16_8:
	sub	eax, esi
LBB16_16:
	add	esp, 4
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
Lfunc_end16:
global strchr
align 16
strchr:
	push	ebp
	mov	ebp, esp
	push	esi
	mov	ecx, dword [ebp + 12]
	mov	eax, dword [ebp + 8]
	movzx	edx, byte [eax]
	test	dl, dl
	je	LBB17_4
	movsx	esi, cl
align 16
LBB17_2:
	movsx	edx, dl
	cmp	esi, edx
	je	LBB17_6
	movzx	edx, byte [eax + 1]
	inc	eax
	test	dl, dl
	jne	LBB17_2
LBB17_4:
	test	ecx, ecx
	je	LBB17_6
	xor	eax, eax
LBB17_6:
	pop	esi
	pop	ebp
	ret
Lfunc_end17:
global strrchr
align 16
strrchr:
	push	ebp
	mov	ebp, esp
	push	edi
	push	esi
	mov	ecx, dword [ebp + 8]
	movsx	edx, byte [ebp + 12]
	xor	esi, esi
	jmp	LBB18_1
align 16
LBB18_3:
	inc	ecx
	test	edi, edi
	mov	esi, eax
	je	LBB18_4
LBB18_1:
	movsx	edi, byte [ecx]
	cmp	edx, edi
	mov	eax, ecx
	je	LBB18_3
	mov	eax, esi
	jmp	LBB18_3
LBB18_4:
	pop	esi
	pop	edi
	pop	ebp
	ret
Lfunc_end18:
global strspn
align 16
strspn:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	mov	edx, dword [ebp + 12]
	mov	edi, dword [ebp + 8]
	test	edi, edi
	sete	cl
	test	edx, edx
	sete	ch
	xor	eax, eax
	or	ch, cl
	jne	LBB19_9
	movzx	ebx, byte [edi]
	test	bl, bl
	mov	eax, edi
	je	LBB19_8
	movzx	ecx, byte [edx]
	inc	edx
	mov	eax, edi
LBB19_3:
	test	cl, cl
	mov	esi, edx
	mov	bh, cl
	je	LBB19_4
align 16
LBB19_6:
	cmp	bl, bh
	je	LBB19_7
	mov	bh, byte [esi]
	inc	esi
	test	bh, bh
	jne	LBB19_6
	jmp	LBB19_8
align 16
LBB19_7:
	movzx	ebx, byte [eax + 1]
	inc	eax
	test	bl, bl
	jne	LBB19_3
	jmp	LBB19_8
LBB19_4:
	mov	eax, edi
LBB19_8:
	sub	eax, edi
LBB19_9:
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
Lfunc_end19:
global strcspn
align 16
strcspn:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	mov	edx, dword [ebp + 12]
	mov	edi, dword [ebp + 8]
	test	edi, edi
	sete	cl
	test	edx, edx
	sete	ch
	xor	eax, eax
	or	ch, cl
	jne	LBB20_8
	movzx	ebx, byte [edi]
	test	bl, bl
	mov	eax, edi
	je	LBB20_7
	movzx	ecx, byte [edx]
	inc	edx
	mov	eax, edi
	jmp	LBB20_3
align 16
LBB20_4:
	movzx	ebx, byte [eax + 1]
	inc	eax
	test	bl, bl
	je	LBB20_7
LBB20_3:
	test	cl, cl
	mov	esi, edx
	mov	bh, cl
	je	LBB20_4
align 16
LBB20_6:
	cmp	bl, bh
	je	LBB20_7
	mov	bh, byte [esi]
	inc	esi
	test	bh, bh
	jne	LBB20_6
	jmp	LBB20_4
LBB20_7:
	sub	eax, edi
LBB20_8:
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
Lfunc_end20:
global strpbrk
align 16
strpbrk:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	esi
	mov	edx, dword [ebp + 12]
	mov	ecx, dword [ebp + 8]
	test	ecx, ecx
	sete	bl
	test	edx, edx
	sete	bh
	xor	eax, eax
	or	bh, bl
	jne	LBB21_9
	movzx	ebx, byte [ecx]
	test	bl, bl
	je	LBB21_9
	movzx	eax, byte [edx]
	inc	edx
	jmp	LBB21_3
align 16
LBB21_4:
	movzx	ebx, byte [ecx + 1]
	inc	ecx
	test	bl, bl
	je	LBB21_5
LBB21_3:
	test	al, al
	mov	esi, edx
	mov	bh, al
	je	LBB21_4
align 16
LBB21_7:
	cmp	bl, bh
	je	LBB21_8
	mov	bh, byte [esi]
	inc	esi
	test	bh, bh
	jne	LBB21_7
	jmp	LBB21_4
LBB21_8:
	mov	eax, ecx
LBB21_9:
	pop	esi
	pop	ebx
	pop	ebp
	ret
LBB21_5:
	xor	eax, eax
	jmp	LBB21_9
Lfunc_end21:
global strstr
align 16
strstr:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	push	eax
	mov	edx, dword [ebp + 12]
	mov	ecx, dword [ebp + 8]
	test	ecx, ecx
	sete	bl
	test	edx, edx
	sete	bh
	xor	eax, eax
	or	bh, bl
	jne	LBB22_16
	mov	ah, byte [edx]
	test	ah, ah
	je	LBB22_6
	xor	ebx, ebx
align 16
LBB22_3:
	cmp	byte [edx + ebx + 1], 0
	lea	ebx, [ebx + 1]
	jne	LBB22_3
	mov	al, byte [ecx]
	test	al, al
	je	LBB22_15
	neg	ebx
	mov	byte [ebp - 13], ah
	jmp	LBB22_9
LBB22_7:
	cmp	al, ah
	mov	ah, byte [ebp - 13]
	je	LBB22_6
LBB22_8:
	mov	al, byte [ecx + 1]
	inc	ecx
	test	al, al
	je	LBB22_15
LBB22_9:
	cmp	al, ah
	jne	LBB22_8
	xor	edi, edi
	mov	esi, ebx
align 16
LBB22_11:
	movzx	eax, byte [ecx + edi]
	test	al, al
	mov	ah, byte [edx + edi]
	je	LBB22_7
	cmp	al, ah
	jne	LBB22_7
	inc	edi
	inc	esi
	jne	LBB22_11
LBB22_6:
	mov	eax, ecx
	jmp	LBB22_16
LBB22_15:
	xor	eax, eax
LBB22_16:
	add	esp, 4
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
Lfunc_end22:
global strtok_r
align 16
strtok_r:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	mov	esi, dword [ebp + 16]
	mov	ecx, dword [ebp + 12]
	test	ecx, ecx
	sete	dl
	test	esi, esi
	sete	dh
	xor	eax, eax
	or	dh, dl
	jne	LBB23_21
	mov	edx, dword [ebp + 8]
	test	edx, edx
	jne	LBB23_3
	mov	edx, dword [esi]
	test	edx, edx
	je	LBB23_21
LBB23_3:
	movzx	eax, byte [edx]
	test	al, al
	je	LBB23_10
	mov	ah, byte [ecx]
	test	ah, ah
	je	LBB23_10
	lea	edi, [ecx + 1]
LBB23_6:
	mov	esi, edi
	mov	bl, ah
align 16
LBB23_8:
	cmp	al, bl
	je	LBB23_9
	movzx	ebx, byte [esi]
	inc	esi
	test	bl, bl
	jne	LBB23_8
	jmp	LBB23_10
LBB23_9:
	mov	al, byte [edx + 1]
	inc	edx
	test	al, al
	jne	LBB23_6
LBB23_10:
	movzx	ebx, byte [edx]
	xor	esi, esi
	test	bl, bl
	je	LBB23_11
	movzx	eax, byte [ecx]
	inc	ecx
	mov	edi, edx
	jmp	LBB23_13
align 16
LBB23_14:
	movzx	ebx, byte [edi + 1]
	inc	edi
	test	bl, bl
	je	LBB23_17
LBB23_13:
	test	al, al
	mov	esi, ecx
	mov	bh, al
	je	LBB23_14
align 16
LBB23_16:
	cmp	bl, bh
	je	LBB23_17
	mov	bh, byte [esi]
	inc	esi
	test	bh, bh
	jne	LBB23_16
	jmp	LBB23_14
LBB23_17:
	sub	edi, edx
	cmp	byte [edx + edi], 0
	je	LBB23_18
	mov	esi, edx
	add	esi, edi
	mov	byte [esi], 0
	inc	esi
	jmp	LBB23_20
LBB23_11:
	xor	edx, edx
	jmp	LBB23_20
LBB23_18:
	xor	esi, esi
LBB23_20:
	mov	eax, dword [ebp + 16]
	mov	dword [eax], esi
	mov	eax, edx
LBB23_21:
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
Lfunc_end23:
global strtok
align 16
strtok:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	mov	edx, dword [ebp + 12]
	xor	eax, eax
	test	edx, edx
	je	LBB24_21
	mov	ecx, dword [ebp + 8]
	test	ecx, ecx
	jne	LBB24_3
	mov	ecx, dword [strtok.next_token]
	test	ecx, ecx
	je	LBB24_21
LBB24_3:
	movzx	eax, byte [ecx]
	test	al, al
	je	LBB24_10
	mov	ah, byte [edx]
	test	ah, ah
	je	LBB24_10
	lea	esi, [edx + 1]
LBB24_6:
	mov	edi, esi
	mov	bl, ah
align 16
LBB24_8:
	cmp	al, bl
	je	LBB24_9
	movzx	ebx, byte [edi]
	inc	edi
	test	bl, bl
	jne	LBB24_8
	jmp	LBB24_10
align 16
LBB24_9:
	mov	al, byte [ecx + 1]
	inc	ecx
	test	al, al
	jne	LBB24_6
LBB24_10:
	movzx	ebx, byte [ecx]
	xor	eax, eax
	test	bl, bl
	je	LBB24_11
	movzx	eax, byte [edx]
	inc	edx
	mov	esi, ecx
	jmp	LBB24_13
align 16
LBB24_14:
	movzx	ebx, byte [esi + 1]
	inc	esi
	test	bl, bl
	je	LBB24_17
LBB24_13:
	test	al, al
	mov	edi, edx
	mov	bh, al
	je	LBB24_14
align 16
LBB24_16:
	cmp	bl, bh
	je	LBB24_17
	mov	bh, byte [edi]
	inc	edi
	test	bh, bh
	jne	LBB24_16
	jmp	LBB24_14
LBB24_17:
	sub	esi, ecx
	cmp	byte [ecx + esi], 0
	je	LBB24_18
	mov	eax, ecx
	add	eax, esi
	mov	byte [eax], 0
	inc	eax
	jmp	LBB24_20
LBB24_11:
	xor	ecx, ecx
	jmp	LBB24_20
LBB24_18:
	xor	eax, eax
LBB24_20:
	mov	dword [strtok.next_token], eax
	mov	eax, ecx
LBB24_21:
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
Lfunc_end24:
global strdup
align 16
strdup:
	push	ebp
	mov	ebp, esp
	push	edi
	push	esi
	xor	edi, edi
	mov	esi, dword [ebp + 8]
align 16
LBB25_1:
	cmp	byte [esi + edi], 0
	lea	edi, [edi + 1]
	jne	LBB25_1
	push	edi
	call	malloc
	add	esp, 4
	test	eax, eax
	sete	cl
	test	edi, edi
	sete	dl
	or	dl, cl
	jne	LBB25_5
	neg	edi
	xor	ecx, ecx
align 16
LBB25_4:
	movzx	edx, byte [esi + ecx]
	mov	byte [eax + ecx], dl
	inc	ecx
	inc	edi
	jne	LBB25_4
LBB25_5:
	pop	esi
	pop	edi
	pop	ebp
	ret
Lfunc_end25:
global malloc
align 16
malloc:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	esi
	mov	ecx, dword [ebp + 8]
	xor	eax, eax
	test	ecx, ecx
	je	LBB26_20
	cmp	ecx, -15
	jb	LBB26_3
	mov	dword [errno], 12
	jmp	LBB26_20
LBB26_3:
	lea	esi, [ecx + 15]
	and	esi, -16
	mov	eax, dword [alloc_head]
	jmp	LBB26_4
align 16
LBB26_7:
	mov	eax, dword [eax + 12]
LBB26_4:
	test	eax, eax
	je	LBB26_8
	cmp	dword [eax + 4], 0
	je	LBB26_7
	mov	edx, dword [eax]
	cmp	edx, esi
	jb	LBB26_7
	jmp	LBB26_14
LBB26_8:
	cmp	ecx, -32
	ja	LBB26_21
	lea	ebx, [esi + 16]
	mov	eax, 5
	xor	ecx, ecx
	xor	edx, edx
	int	128
	test	eax, eax
	jle	LBB26_21
	mov	dword [eax], esi
	mov	dword [eax + 4], 0
	mov	ecx, dword [alloc_tail]
	mov	dword [eax + 8], ecx
	mov	dword [eax + 12], 0
	test	ecx, ecx
	je	LBB26_12
	mov	dword [ecx + 12], eax
	jmp	LBB26_13
LBB26_21:
	mov	dword [errno], 12
	xor	eax, eax
	jmp	LBB26_20
LBB26_12:
	mov	dword [alloc_head], eax
LBB26_13:
	mov	dword [alloc_tail], eax
	mov	edx, dword [eax]
LBB26_14:
	mov	dword [eax + 4], 0
	sub	edx, esi
	setbe	cl
	cmp	edx, 32
	setb	ch
	or	ch, cl
	jne	LBB26_19
	lea	ecx, [eax + esi + 16]
	add	edx, -16
	mov	dword [eax + esi + 16], edx
	mov	dword [eax + esi + 20], 1
	mov	dword [eax + esi + 24], eax
	mov	edx, dword [eax + 12]
	mov	dword [eax + esi + 28], edx
	test	edx, edx
	je	LBB26_17
	mov	dword [edx + 8], ecx
	jmp	LBB26_18
LBB26_17:
	mov	dword [alloc_tail], ecx
LBB26_18:
	mov	dword [eax], esi
	mov	dword [eax + 12], ecx
LBB26_19:
	add	eax, 16
LBB26_20:
	pop	esi
	pop	ebx
	pop	ebp
	ret
Lfunc_end26:
global strndup
align 16
strndup:
	push	ebp
	mov	ebp, esp
	push	edi
	push	esi
	mov	eax, dword [ebp + 12]
	mov	esi, dword [ebp + 8]
	xor	edi, edi
	test	eax, eax
	je	LBB27_4
align 16
LBB27_1:
	cmp	byte [esi + edi], 0
	je	LBB27_4
	inc	edi
	cmp	eax, edi
	jne	LBB27_1
	mov	edi, eax
LBB27_4:
	lea	eax, [edi + 1]
	push	eax
	call	malloc
	add	esp, 4
	test	eax, eax
	je	LBB27_9
	test	edi, edi
	je	LBB27_8
	xor	ecx, ecx
align 16
LBB27_7:
	movzx	edx, byte [esi + ecx]
	mov	byte [eax + ecx], dl
	inc	ecx
	cmp	edi, ecx
	jne	LBB27_7
LBB27_8:
	mov	byte [eax + edi], 0
LBB27_9:
	pop	esi
	pop	edi
	pop	ebp
	ret
Lfunc_end27:
global strerror
align 16
strerror:
	push	ebp
	mov	ebp, esp
	mov	eax, dword [ebp + 8]
	dec	eax
	cmp	eax, 74
	ja	LBB28_18
	jmp	dword [4*eax + LJTI28_0]
LBB28_2:
	mov	eax, L.str
	pop	ebp
	ret
LBB28_15:
	mov	eax, L.str.13
	pop	ebp
	ret
LBB28_12:
	mov	eax, L.str.10
	pop	ebp
	ret
LBB28_14:
	mov	eax, L.str.12
	pop	ebp
	ret
LBB28_4:
	mov	eax, L.str.2
	pop	ebp
	ret
LBB28_7:
	mov	eax, L.str.5
	pop	ebp
	ret
LBB28_13:
	mov	eax, L.str.11
	pop	ebp
	ret
LBB28_3:
	mov	eax, L.str.1
	pop	ebp
	ret
LBB28_8:
	mov	eax, L.str.6
	pop	ebp
	ret
LBB28_9:
	mov	eax, L.str.7
	pop	ebp
	ret
LBB28_16:
	mov	eax, L.str.14
	pop	ebp
	ret
LBB28_17:
	mov	eax, L.str.15
	pop	ebp
	ret
LBB28_5:
	mov	eax, L.str.3
	pop	ebp
	ret
LBB28_6:
	mov	eax, L.str.4
	pop	ebp
	ret
LBB28_11:
	mov	eax, L.str.9
	pop	ebp
	ret
LBB28_10:
	mov	eax, L.str.8
	pop	ebp
	ret
LBB28_18:
	mov	eax, L.str.16
	pop	ebp
	ret
Lfunc_end28:
section .rodata
align 4
LJTI28_0:
dd LBB28_2
dd LBB28_3
dd LBB28_18
dd LBB28_18
dd LBB28_4
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_5
dd LBB28_6
dd LBB28_18
dd LBB28_7
dd LBB28_8
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_9
dd LBB28_10
dd LBB28_11
dd LBB28_18
dd LBB28_12
dd LBB28_13
dd LBB28_18
dd LBB28_18
dd LBB28_14
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_15
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_16
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_18
dd LBB28_17
section .text
global strtoul
align 16
strtoul:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 16
	mov	ebx, dword [ebp + 12]
	mov	esi, dword [ebp + 8]
	test	ebx, ebx
	je	LBB29_2
	mov	dword [ebx], esi
LBB29_2:
	test	esi, esi
	je	LBB29_59
	mov	edx, dword [ebp + 16]
	test	edx, edx
	setne	al
	lea	ecx, [edx - 37]
	cmp	ecx, -35
	setb	cl
	test	al, cl
	je	LBB29_4
LBB29_59:
	mov	dword [errno], 22
	xor	eax, eax
LBB29_58:
	add	esp, 16
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
LBB29_4:
	mov	eax, esi
	jmp	LBB29_5
align 16
LBB29_60:
	inc	eax
LBB29_5:
	movzx	ecx, byte [eax]
	movzx	esi, cl
	lea	edi, [esi - 9]
	cmp	edi, 5
	jb	LBB29_60
	cmp	esi, 32
	je	LBB29_60
	cmp	esi, 43
	je	LBB29_9
	cmp	esi, 45
	jne	LBB29_10
LBB29_9:
	cmp	cl, 45
	sete	cl
	mov	dword [ebp - 28], ecx
	inc	eax
	cmp	edx, 16
	je	LBB29_24
LBB29_12:
	test	edx, edx
	jne	LBB29_32
	mov	ch, byte [eax]
	mov	dword [ebp - 24], 10
	cmp	ch, 48
	jne	LBB29_14
	movzx	ecx, byte [eax + 1]
	or	ecx, 32
	cmp	ecx, 120
	jne	LBB29_23
	lea	edi, [eax + 2]
	mov	ch, byte [eax + 2]
	movsx	edx, ch
	lea	esi, [edx - 48]
	cmp	esi, 10
	mov	dword [ebp - 24], 16
	jae	LBB29_18
	mov	dword [ebp - 20], edi
	test	ch, ch
	jne	LBB29_36
	jmp	LBB29_52
LBB29_10:
	mov	dword [ebp - 28], 0
	cmp	edx, 16
	jne	LBB29_12
LBB29_24:
	cmp	byte [eax], 48
	jne	LBB29_32
	movzx	ecx, byte [eax + 1]
	or	ecx, 32
	cmp	ecx, 120
	jne	LBB29_32
	lea	ecx, [eax + 2]
	mov	dword [ebp - 20], ecx
	mov	ch, byte [eax + 2]
	movsx	esi, ch
	lea	edi, [esi - 48]
	cmp	edi, 10
	mov	dword [ebp - 24], 16
	jb	LBB29_35
	lea	ecx, [esi - 97]
	cmp	ecx, 25
	ja	LBB29_29
	add	esi, -87
	mov	edi, dword [ebp - 20]
	jmp	LBB29_31
LBB29_14:
	mov	dword [ebp - 20], eax
LBB29_35:
	test	ch, ch
	jne	LBB29_36
	jmp	LBB29_52
LBB29_18:
	lea	ecx, [edx - 97]
	cmp	ecx, 25
	ja	LBB29_20
	add	edx, -87
	jmp	LBB29_22
LBB29_20:
	lea	ecx, [edx - 65]
	cmp	ecx, 25
	ja	LBB29_23
	add	edx, -55
LBB29_22:
	mov	dword [ebp - 24], 16
	cmp	edx, 16
	jb	LBB29_34
LBB29_23:
	mov	dword [ebp - 24], 8
	jmp	LBB29_33
LBB29_29:
	lea	ecx, [esi - 65]
	cmp	ecx, 25
	mov	edi, dword [ebp - 20]
	ja	LBB29_32
	add	esi, -55
LBB29_31:
	mov	dword [ebp - 24], 16
	cmp	esi, 16
	jb	LBB29_34
LBB29_32:
	mov	dword [ebp - 24], edx
LBB29_33:
	mov	edi, eax
LBB29_34:
	mov	dword [ebp - 20], edi
	mov	ch, byte [edi]
	test	ch, ch
	je	LBB29_52
LBB29_36:
	xor	esi, esi
	mov	byte [ebp - 13], 1
	xor	edi, edi
	jmp	LBB29_37
align 16
LBB29_47:
	mov	edi, dword [ebp - 20]
	mov	ch, byte [edi + esi + 1]
	inc	esi
	test	ch, ch
	mov	edi, edx
	je	LBB29_48
LBB29_37:
	movzx	eax, ch
	lea	ebx, [eax - 48]
	cmp	ebx, 10
	jb	LBB29_44
	mov	edx, eax
	add	dl, -97
	cmp	dl, 25
	ja	LBB29_40
	add	eax, -87
	jmp	LBB29_43
align 16
LBB29_40:
	cmp	al, 55
	jb	LBB29_51
	lea	edx, [eax - 91]
	cmp	edx, -26
	jb	LBB29_51
	add	eax, -55
LBB29_43:
	mov	ebx, eax
LBB29_44:
	cmp	ebx, dword [ebp - 24]
	jge	LBB29_51
	mov	eax, ebx
	not	eax
	xor	edx, edx
	mov	ecx, dword [ebp - 24]
	div	ecx
	cmp	edi, eax
	setbe	al
	movzx	edx, byte [ebp - 13]
	and	dl, al
	mov	eax, edi
	imul	eax, ecx
	add	eax, ebx
	mov	byte [ebp - 13], dl
	test	dl, dl
	mov	edx, eax
	jne	LBB29_47
	mov	edx, edi
	jmp	LBB29_47
LBB29_51:
	test	esi, esi
	mov	ebx, dword [ebp + 12]
	je	LBB29_52
	mov	edx, dword [ebp - 20]
	add	edx, esi
	test	byte [ebp - 13], 1
	mov	eax, edi
	jne	LBB29_49
LBB29_55:
	mov	dword [errno], 34
	mov	eax, -1
	jmp	LBB29_56
LBB29_52:
	xor	eax, eax
	test	ebx, ebx
	je	LBB29_58
	mov	ecx, dword [ebp + 8]
	mov	dword [ebx], ecx
	jmp	LBB29_58
LBB29_48:
	mov	edx, dword [ebp - 20]
	add	edx, esi
	cmp	byte [ebp - 13], 0
	mov	ebx, dword [ebp + 12]
	je	LBB29_55
LBB29_49:
	cmp	byte [ebp - 28], 0
	je	LBB29_56
	neg	eax
LBB29_56:
	test	ebx, ebx
	je	LBB29_58
	mov	dword [ebx], edx
	jmp	LBB29_58
Lfunc_end29:
global strtol
align 16
strtol:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 20
	mov	eax, dword [ebp + 12]
	mov	esi, dword [ebp + 8]
	test	eax, eax
	je	LBB30_2
	mov	dword [eax], esi
LBB30_2:
	test	esi, esi
	je	LBB30_63
	mov	ecx, dword [ebp + 16]
	test	ecx, ecx
	setne	al
	lea	edx, [ecx - 37]
	cmp	edx, -35
	setb	dl
	test	al, dl
	je	LBB30_4
LBB30_63:
	mov	dword [errno], 22
	xor	esi, esi
LBB30_62:
	mov	eax, esi
	add	esp, 20
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
LBB30_4:
	mov	eax, esi
	jmp	LBB30_5
align 16
LBB30_64:
	inc	eax
LBB30_5:
	movzx	edx, byte [eax]
	movzx	esi, dl
	lea	edi, [esi - 9]
	cmp	edi, 5
	jb	LBB30_64
	cmp	esi, 32
	je	LBB30_64
	cmp	esi, 43
	je	LBB30_9
	cmp	esi, 45
	jne	LBB30_10
LBB30_9:
	cmp	dl, 45
	sete	bl
	inc	eax
	cmp	ecx, 16
	je	LBB30_24
LBB30_12:
	test	ecx, ecx
	jne	LBB30_32
	movzx	edx, byte [eax]
	mov	dword [ebp - 24], 10
	cmp	dl, 48
	jne	LBB30_14
	movzx	ecx, byte [eax + 1]
	or	ecx, 32
	cmp	ecx, 120
	jne	LBB30_23
	lea	edi, [eax + 2]
	movzx	edx, byte [eax + 2]
	movsx	ecx, dl
	lea	esi, [ecx - 48]
	cmp	esi, 10
	mov	dword [ebp - 24], 16
	jae	LBB30_18
	mov	dword [ebp - 20], edi
	test	dl, dl
	jne	LBB30_36
	jmp	LBB30_56
LBB30_10:
	xor	ebx, ebx
	cmp	ecx, 16
	jne	LBB30_12
LBB30_24:
	cmp	byte [eax], 48
	jne	LBB30_32
	movzx	edx, byte [eax + 1]
	or	edx, 32
	cmp	edx, 120
	jne	LBB30_32
	lea	edx, [eax + 2]
	mov	dword [ebp - 20], edx
	movzx	edx, byte [eax + 2]
	movsx	esi, dl
	lea	edi, [esi - 48]
	cmp	edi, 10
	mov	dword [ebp - 24], 16
	jb	LBB30_35
	lea	edx, [esi - 97]
	cmp	edx, 25
	ja	LBB30_29
	add	esi, -87
	mov	edi, dword [ebp - 20]
	jmp	LBB30_31
LBB30_14:
	mov	dword [ebp - 20], eax
LBB30_35:
	test	dl, dl
	jne	LBB30_36
	jmp	LBB30_56
LBB30_18:
	lea	edx, [ecx - 97]
	cmp	edx, 25
	ja	LBB30_20
	add	ecx, -87
	jmp	LBB30_22
LBB30_20:
	lea	edx, [ecx - 65]
	cmp	edx, 25
	ja	LBB30_23
	add	ecx, -55
LBB30_22:
	mov	dword [ebp - 24], 16
	cmp	ecx, 16
	jb	LBB30_34
LBB30_23:
	mov	dword [ebp - 24], 8
	jmp	LBB30_33
LBB30_29:
	lea	edx, [esi - 65]
	cmp	edx, 25
	mov	edi, dword [ebp - 20]
	ja	LBB30_32
	add	esi, -55
LBB30_31:
	mov	dword [ebp - 24], 16
	cmp	esi, 16
	jb	LBB30_34
LBB30_32:
	mov	dword [ebp - 24], ecx
LBB30_33:
	mov	edi, eax
LBB30_34:
	mov	dword [ebp - 20], edi
	movzx	edx, byte [edi]
	test	dl, dl
	je	LBB30_56
LBB30_36:
	mov	dword [ebp - 32], ebx
	movzx	eax, bl
	add	eax, 2147483647
	mov	dword [ebp - 28], eax
	xor	edi, edi
	mov	byte [ebp - 13], 1
	xor	ecx, ecx
	mov	ebx, dword [ebp - 24]
	jmp	LBB30_37
align 16
LBB30_47:
	mov	ecx, dword [ebp - 20]
	movzx	edx, byte [ecx + edi + 1]
	inc	edi
	test	dl, dl
	mov	ecx, esi
	je	LBB30_48
LBB30_37:
	movzx	eax, dl
	lea	esi, [eax - 48]
	cmp	esi, 10
	jb	LBB30_44
	mov	edx, eax
	add	dl, -97
	cmp	dl, 25
	ja	LBB30_40
	add	eax, -87
	jmp	LBB30_43
align 16
LBB30_40:
	cmp	al, 55
	jb	LBB30_55
	lea	edx, [eax - 91]
	cmp	edx, -26
	jb	LBB30_55
	add	eax, -55
LBB30_43:
	mov	esi, eax
LBB30_44:
	cmp	esi, dword [ebp - 24]
	jge	LBB30_55
	mov	eax, dword [ebp - 28]
	sub	eax, esi
	xor	edx, edx
	div	ebx
	cmp	ecx, eax
	setbe	al
	movzx	edx, byte [ebp - 13]
	and	dl, al
	mov	eax, ecx
	imul	eax, ebx
	add	eax, esi
	mov	byte [ebp - 13], dl
	test	dl, dl
	mov	esi, eax
	jne	LBB30_47
	mov	esi, ecx
	jmp	LBB30_47
LBB30_55:
	test	edi, edi
	je	LBB30_56
	mov	edx, dword [ebp - 20]
	add	edx, edi
	test	byte [ebp - 13], 1
	mov	eax, ecx
	jne	LBB30_49
LBB30_59:
	mov	eax, dword [ebp + 12]
	test	eax, eax
	mov	dword [errno], 34
	je	LBB30_61
	mov	dword [eax], edx
LBB30_61:
	mov	esi, dword [ebp - 28]
	jmp	LBB30_62
LBB30_56:
	xor	esi, esi
	mov	eax, dword [ebp + 12]
	test	eax, eax
	je	LBB30_62
	mov	ecx, dword [ebp + 8]
	mov	dword [eax], ecx
	jmp	LBB30_62
LBB30_48:
	mov	edx, dword [ebp - 20]
	add	edx, edi
	cmp	byte [ebp - 13], 0
	je	LBB30_59
LBB30_49:
	mov	ecx, dword [ebp + 12]
	test	ecx, ecx
	je	LBB30_51
	mov	dword [ecx], edx
LBB30_51:
	mov	ecx, eax
	neg	ecx
	seto	dl
	mov	esi, -2147483648
	mov	ebx, dword [ebp - 32]
	test	bl, dl
	jne	LBB30_62
	test	bl, bl
	jne	LBB30_54
	mov	ecx, eax
LBB30_54:
	mov	esi, ecx
	jmp	LBB30_62
Lfunc_end30:
section .rodata
align 4
LCPI31_0:
dd 0x41200000
section .rodata
align 8
LCPI31_1:
dq 0x7fefffffffffffff
LCPI31_2:
dq 0xffefffffffffffff
LCPI31_3:
dq 0x7fb9999999999999
section .text
global strtod
align 16
strtod:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 20
	mov	eax, dword [ebp + 12]
	mov	edi, dword [ebp + 8]
	test	eax, eax
	je	LBB31_2
	mov	dword [eax], edi
LBB31_2:
	test	edi, edi
	je	LBB31_55
	lea	edx, [edi + 1]
	jmp	LBB31_4
align 16
LBB31_56:
	inc	edx
LBB31_4:
	mov	ch, byte [edx - 1]
	movzx	eax, ch
	lea	esi, [eax - 9]
	cmp	esi, 5
	jb	LBB31_56
	cmp	eax, 32
	je	LBB31_56
	cmp	eax, 43
	je	LBB31_8
	cmp	eax, 45
	jne	LBB31_9
LBB31_8:
	cmp	ch, 45
	setne	cl
	mov	ch, byte [edx]
	jmp	LBB31_10
LBB31_55:
	mov	dword [errno], 22
	fldz
	jmp	LBB31_54
LBB31_9:
	dec	edx
	mov	cl, 1
LBB31_10:
	mov	bl, ch
	add	bl, -58
	fldz
	cmp	bl, -10
	jb	LBB31_13
	fstp	st0
	fldz
align 16
LBB31_12:
	movzx	eax, ch
	add	eax, -48
	mov	dword [ebp - 32], eax
	fmul	dword [LCPI31_0]
	fiadd	dword [ebp - 32]
	mov	ch, byte [edx + 1]
	inc	edx
	mov	al, ch
	add	al, -58
	cmp	al, -11
	ja	LBB31_12
LBB31_13:
	cmp	ch, 46
	jne	LBB31_19
	mov	ch, byte [edx + 1]
	inc	edx
	mov	al, ch
	add	al, -58
	cmp	al, -10
	jae	LBB31_15
LBB31_19:
	xor	esi, esi
	cmp	bl, -11
	ja	LBB31_17
	fstp	st0
	fldz
	mov	eax, dword [ebp + 12]
	test	eax, eax
	je	LBB31_54
	mov	dword [eax], edi
	jmp	LBB31_54
LBB31_15:
	xor	esi, esi
align 16
LBB31_16:
	movzx	eax, ch
	add	eax, -48
	mov	dword [ebp - 28], eax
	fmul	dword [LCPI31_0]
	fiadd	dword [ebp - 28]
	dec	esi
	mov	ch, byte [edx + 1]
	inc	edx
	mov	al, ch
	add	al, -58
	cmp	al, -10
	jae	LBB31_16
LBB31_17:
	mov	byte [ebp - 13], cl
	movzx	eax, ch
	mov	ch, 1
	xor	edi, edi
	or	eax, 32
	cmp	eax, 101
	jne	LBB31_18
	movzx	eax, byte [edx + 1]
	cmp	eax, 45
	je	LBB31_25
	cmp	eax, 43
	jne	LBB31_24
LBB31_25:
	xor	ecx, ecx
	cmp	al, 45
	setne	cl
	lea	eax, [ecx + ecx - 1]
	mov	dword [ebp - 24], eax
	mov	ch, 1
	lea	ebx, [edx + 2]
	movzx	eax, byte [edx + 2]
	jmp	LBB31_26
LBB31_18:
	mov	dword [ebp - 20], 1
	jmp	LBB31_34
LBB31_24:
	lea	ebx, [edx + 1]
	mov	dword [ebp - 24], 1
LBB31_26:
	mov	cl, al
	add	cl, -58
	mov	dword [ebp - 20], 1
	cmp	cl, -10
	jb	LBB31_34
	xor	ecx, ecx
	xor	edi, edi
	jmp	LBB31_28
align 16
LBB31_32:
	movzx	eax, byte [ebx + 1]
	inc	ebx
	mov	ecx, eax
	add	cl, -58
	cmp	cl, -11
	mov	ecx, edx
	jbe	LBB31_33
LBB31_28:
	cmp	edi, 401
	jge	LBB31_30
	lea	edx, [edi + 4*edi]
	movzx	eax, al
	lea	edi, [eax + 2*edx - 48]
LBB31_30:
	mov	edx, 1
	jge	LBB31_32
	mov	edx, ecx
	jmp	LBB31_32
LBB31_33:
	test	edx, edx
	sete	ch
	mov	edx, ebx
	mov	eax, dword [ebp - 24]
	mov	dword [ebp - 20], eax
LBB31_34:
	mov	eax, dword [ebp + 12]
	test	eax, eax
	je	LBB31_36
	mov	dword [eax], edx
LBB31_36:
	test	ch, ch
	mov	dh, byte [ebp - 13]
	je	LBB31_37
	imul	edi, dword [ebp - 20]
	mov	eax, edi
	add	eax, esi
	jle	LBB31_46
	lea	ecx, [esi + edi + 1]
	fld	qword [LCPI31_3]
	fld	st1
align 16
LBB31_44:
	fucom	st1
	fnstsw	ax
	sahf
	ja	LBB31_45
	fmul	dword [LCPI31_0]
	dec	ecx
	cmp	ecx, 1
	jg	LBB31_44
	jmp	LBB31_49
LBB31_37:
	fstp	st0
	mov	dword [errno], 34
	test	dh, dh
	fldz
	fld	st0
	fchs
	jne	LBB31_39
	fstp	st1
	fldz
LBB31_39:
	fstp	st0
	fld	qword [LCPI31_1]
	fld	qword [LCPI31_2]
	jne	LBB31_41
	fstp	st1
	fldz
LBB31_41:
	fstp	st0
	cmp	dword [ebp - 20], 0
	js	LBB31_53
LBB31_52:
	fstp	st1
	fldz
LBB31_53:
	fstp	st0
LBB31_54:
	add	esp, 20
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
LBB31_46:
	fld	st0
	fldz
	fxch	st1
	jns	LBB31_49
	fstp	st0
	fstp	st0
	fld	st0
	fldz
	fxch	st1
align 16
LBB31_48:
	fstp	st1
	fdiv	dword [LCPI31_0]
	inc	eax
	fldz
	fxch	st1
	jne	LBB31_48
LBB31_49:
	fstp	st1
	fldz
	fxch	st2
	fucomp	st2
	fnstsw	ax
	sahf
	setp	al
	setne	cl
	or	cl, al
	fucom	st1
	fstp	st1
	fnstsw	ax
	sahf
	setnp	al
	sete	dl
	and	dl, al
	and	dl, cl
	cmp	dl, 1
	jne	LBB31_51
	mov	dword [errno], 34
LBB31_51:
	fld	st0
	fchs
	test	dh, dh
	je	LBB31_52
	jmp	LBB31_53
LBB31_45:
	fstp	st2
	fstp	st1
	fstp	st0
	mov	dword [errno], 34
	test	dh, dh
	fld	qword [LCPI31_1]
	fld	qword [LCPI31_2]
	je	LBB31_52
	jmp	LBB31_53
Lfunc_end31:
global atof
align 16
atof:
	push	ebp
	mov	ebp, esp
	push	0
	push	dword [ebp + 8]
	call	strtod
	add	esp, 8
	pop	ebp
	ret
Lfunc_end32:
global atoi
align 16
atoi:
	push	ebp
	mov	ebp, esp
	push	10
	push	0
	push	dword [ebp + 8]
	call	strtol
	add	esp, 12
	pop	ebp
	ret
Lfunc_end33:
global atol
align 16
atol:
	push	ebp
	mov	ebp, esp
	push	10
	push	0
	push	dword [ebp + 8]
	call	strtol
	add	esp, 12
	pop	ebp
	ret
Lfunc_end34:
global labs
align 16
labs:
	push	ebp
	mov	ebp, esp
	mov	eax, dword [ebp + 8]
	mov	ecx, eax
	sar	ecx, 31
	xor	eax, ecx
	sub	eax, ecx
	pop	ebp
	ret
Lfunc_end35:
global qsort
align 16
qsort:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 12
	mov	esi, dword [ebp + 16]
	test	esi, esi
	je	LBB36_11
	cmp	dword [ebp + 12], 2
	jb	LBB36_11
	cmp	dword [ebp + 8], 0
	je	LBB36_11
	cmp	dword [ebp + 20], 0
	je	LBB36_11
	mov	eax, esi
	neg	eax
	mov	dword [ebp - 24], eax
	mov	edi, 1
	mov	ebx, dword [ebp + 8]
	jmp	LBB36_5
align 16
LBB36_10:
	mov	edi, dword [ebp - 20]
	inc	edi
	mov	ebx, dword [ebp - 16]
	add	ebx, esi
	cmp	edi, dword [ebp + 12]
	je	LBB36_11
LBB36_5:
	mov	dword [ebp - 16], ebx
	mov	dword [ebp - 20], edi
align 16
LBB36_6:
	mov	eax, edi
	dec	edi
	mov	ecx, edi
	imul	ecx, esi
	mov	edx, dword [ebp + 8]
	add	ecx, edx
	imul	eax, esi
	add	eax, edx
	push	eax
	push	ecx
	call	dword [ebp + 20]
	add	esp, 8
	test	eax, eax
	jle	LBB36_10
	lea	eax, [ebx + esi]
	xor	ecx, ecx
align 16
LBB36_8:
	movzx	edx, byte [ebx + ecx]
	mov	dh, byte [eax + ecx]
	mov	byte [ebx + ecx], dh
	mov	byte [eax + ecx], dl
	inc	ecx
	cmp	esi, ecx
	jne	LBB36_8
	add	ebx, dword [ebp - 24]
	test	edi, edi
	jne	LBB36_6
	jmp	LBB36_10
LBB36_11:
	add	esp, 12
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
Lfunc_end36:
global bsearch
align 16
bsearch:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	push	eax
	cmp	dword [ebp + 8], 0
	sete	al
	cmp	dword [ebp + 12], 0
	sete	cl
	or	cl, al
	cmp	dword [ebp + 24], 0
	sete	al
	cmp	dword [ebp + 20], 0
	sete	dl
	or	dl, al
	or	dl, cl
	mov	edi, dword [ebp + 16]
	test	edi, edi
	sete	al
	or	al, dl
	jne	LBB37_6
	xor	ebx, ebx
	jmp	LBB37_2
align 16
LBB37_5:
	cmp	ebx, edi
	jae	LBB37_6
LBB37_2:
	mov	dword [ebp - 16], edi
	sub	edi, ebx
	shr	edi, 1
	add	edi, ebx
	mov	esi, edi
	imul	esi, dword [ebp + 20]
	add	esi, dword [ebp + 12]
	push	esi
	push	dword [ebp + 8]
	call	dword [ebp + 24]
	add	esp, 8
	test	eax, eax
	js	LBB37_5
	je	LBB37_7
	inc	edi
	mov	ebx, edi
	mov	edi, dword [ebp - 16]
	jmp	LBB37_5
LBB37_6:
	xor	esi, esi
LBB37_7:
	mov	eax, esi
	add	esp, 4
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
Lfunc_end37:
align 16
alloc_split:
	push	ebp
	mov	ebp, esp
	push	esi
	mov	esi, dword [ecx]
	sub	esi, edx
	setbe	al
	cmp	esi, 32
	setb	ah
	or	ah, al
	jne	LBB38_5
	lea	eax, [ecx + edx + 16]
	add	esi, -16
	mov	dword [ecx + edx + 16], esi
	mov	dword [ecx + edx + 20], 1
	mov	dword [ecx + edx + 24], ecx
	mov	esi, dword [ecx + 12]
	mov	dword [ecx + edx + 28], esi
	test	esi, esi
	je	LBB38_3
	mov	dword [esi + 8], eax
	jmp	LBB38_4
LBB38_3:
	mov	dword [alloc_tail], eax
LBB38_4:
	mov	dword [ecx], edx
	mov	dword [ecx + 12], eax
LBB38_5:
	pop	esi
	pop	ebp
	ret
Lfunc_end38:
global calloc
align 16
calloc:
	push	ebp
	mov	ebp, esp
	push	esi
	mov	esi, dword [ebp + 12]
	mov	ecx, dword [ebp + 8]
	test	esi, esi
	je	LBB39_3
	mov	eax, esi
	mul	ecx
	jno	LBB39_3
	mov	dword [errno], 12
	jmp	LBB39_7
LBB39_3:
	imul	esi, ecx
	push	esi
	call	malloc
	add	esp, 4
	test	eax, eax
	je	LBB39_7
	test	esi, esi
	je	LBB39_8
	xor	ecx, ecx
align 16
LBB39_6:
	mov	byte [eax + ecx], 0
	inc	ecx
	cmp	esi, ecx
	jne	LBB39_6
	jmp	LBB39_8
LBB39_7:
	xor	eax, eax
LBB39_8:
	pop	esi
	pop	ebp
	ret
Lfunc_end39:
global realloc
align 16
realloc:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	mov	edi, dword [ebp + 12]
	mov	ebx, dword [ebp + 8]
	test	ebx, ebx
	je	LBB40_4
	test	edi, edi
	je	LBB40_5
	cmp	edi, -15
	jb	LBB40_7
	mov	dword [errno], 12
	xor	eax, eax
	jmp	LBB40_6
LBB40_4:
	push	edi
	call	malloc
	add	esp, 4
	jmp	LBB40_6
LBB40_5:
	xor	eax, eax
	cmp	dword [ebx - 12], 0
	jne	LBB40_6
	mov	dword [ebx - 12], 1
	mov	ecx, dword [ebx - 4]
	test	ecx, ecx
	je	LBB40_40
	cmp	dword [ecx + 4], 0
	je	LBB40_40
	lea	edx, [ebx - 16]
	mov	esi, dword [ecx]
	mov	edi, dword [ebx - 16]
	lea	esi, [esi + edi + 16]
	mov	dword [ebx - 16], esi
	mov	ecx, dword [ecx + 12]
	mov	dword [ebx - 4], ecx
	test	ecx, ecx
	je	LBB40_39
	mov	dword [ecx + 8], edx
	jmp	LBB40_40
LBB40_7:
	add	edi, 15
	and	edi, -16
	lea	esi, [ebx - 16]
	mov	eax, dword [ebx - 16]
	mov	ecx, eax
	sub	ecx, edi
	jae	LBB40_22
	mov	ecx, dword [ebx - 4]
	test	ecx, ecx
	je	LBB40_11
	cmp	dword [ecx + 4], 0
	je	LBB40_11
	add	eax, 16
	add	eax, dword [ecx]
	setb	cl
	cmp	eax, edi
	setb	al
	or	al, cl
	je	LBB40_31
LBB40_11:
	push	edi
	call	malloc
	add	esp, 4
	test	eax, eax
	je	LBB40_30
	mov	ecx, dword [esi]
	test	ecx, ecx
	je	LBB40_17
	cmp	ecx, edi
	jb	LBB40_15
	mov	ecx, edi
LBB40_15:
	xor	edx, edx
align 16
LBB40_16:
	mov	edi, ebx
	movzx	ebx, byte [ebx + edx]
	mov	byte [eax + edx], bl
	mov	ebx, edi
	inc	edx
	cmp	ecx, edx
	jne	LBB40_16
LBB40_17:
	cmp	dword [ebx - 12], 0
	jne	LBB40_6
	mov	dword [ebx - 12], 1
	mov	ecx, dword [ebx - 4]
	test	ecx, ecx
	je	LBB40_40
	cmp	dword [ecx + 4], 0
	je	LBB40_40
	mov	edx, dword [ecx]
	mov	edi, dword [ebx - 16]
	lea	edx, [edx + edi + 16]
	mov	dword [ebx - 16], edx
	mov	ecx, dword [ecx + 12]
	mov	dword [ebx - 4], ecx
	test	ecx, ecx
	je	LBB40_47
	mov	dword [ecx + 8], esi
	jmp	LBB40_40
LBB40_22:
	setbe	al
	cmp	ecx, 32
	setb	dl
	or	dl, al
	je	LBB40_28
	mov	eax, dword [ebx - 4]
	test	eax, eax
	jne	LBB40_34
	jmp	LBB40_38
LBB40_28:
	lea	eax, [ebx + edi]
	add	ecx, -16
	mov	dword [ebx + edi], ecx
	mov	dword [ebx + edi + 4], 1
	mov	dword [ebx + edi + 8], esi
	mov	ecx, dword [ebx - 4]
	mov	dword [ebx + edi + 12], ecx
	test	ecx, ecx
	je	LBB40_32
	mov	dword [ecx + 8], eax
	jmp	LBB40_33
LBB40_30:
	xor	eax, eax
	jmp	LBB40_6
LBB40_31:
	mov	ecx, esi
	call	alloc_coalesce_next
	mov	ecx, esi
	mov	edx, edi
	call	alloc_split
	mov	eax, ebx
	jmp	LBB40_6
LBB40_32:
	mov	dword [alloc_tail], eax
LBB40_33:
	mov	dword [ebx - 16], edi
	mov	dword [ebx - 4], eax
LBB40_34:
	mov	ecx, dword [eax + 12]
	test	ecx, ecx
	je	LBB40_38
	cmp	dword [ecx + 4], 0
	je	LBB40_38
	mov	edx, dword [ecx]
	mov	esi, dword [eax]
	lea	edx, [edx + esi + 16]
	mov	dword [eax], edx
	mov	ecx, dword [ecx + 12]
	mov	dword [eax + 12], ecx
	test	ecx, ecx
	je	LBB40_46
	mov	dword [ecx + 8], eax
LBB40_38:
	mov	eax, ebx
	jmp	LBB40_6
LBB40_39:
	mov	dword [alloc_tail], edx
LBB40_40:
	mov	ecx, dword [ebx - 8]
	test	ecx, ecx
	je	LBB40_6
	cmp	dword [ecx + 4], 0
	je	LBB40_6
	mov	edx, dword [ecx + 12]
	test	edx, edx
	je	LBB40_6
	cmp	dword [edx + 4], 0
	je	LBB40_6
	mov	esi, dword [edx]
	mov	edi, dword [ecx]
	lea	esi, [esi + edi + 16]
	mov	dword [ecx], esi
	mov	edx, dword [edx + 12]
	mov	dword [ecx + 12], edx
	test	edx, edx
	je	LBB40_49
	mov	dword [edx + 8], ecx
	jmp	LBB40_6
LBB40_46:
	mov	dword [alloc_tail], eax
	mov	eax, ebx
	jmp	LBB40_6
LBB40_49:
	mov	dword [alloc_tail], ecx
LBB40_6:
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
LBB40_47:
	mov	dword [alloc_tail], esi
	jmp	LBB40_40
Lfunc_end40:
global free
align 16
free:
	push	ebp
	mov	ebp, esp
	push	edi
	push	esi
	mov	eax, dword [ebp + 8]
	test	eax, eax
	je	LBB41_14
	cmp	dword [eax - 12], 0
	je	LBB41_2
LBB41_14:
	pop	esi
	pop	edi
	pop	ebp
	ret
LBB41_2:
	mov	dword [eax - 12], 1
	mov	ecx, dword [eax - 4]
	test	ecx, ecx
	je	LBB41_7
	cmp	dword [ecx + 4], 0
	je	LBB41_7
	lea	edx, [eax - 16]
	mov	esi, dword [ecx]
	mov	edi, dword [eax - 16]
	lea	esi, [esi + edi + 16]
	mov	dword [eax - 16], esi
	mov	ecx, dword [ecx + 12]
	mov	dword [eax - 4], ecx
	test	ecx, ecx
	je	LBB41_6
	mov	dword [ecx + 8], edx
	jmp	LBB41_7
LBB41_6:
	mov	dword [alloc_tail], edx
LBB41_7:
	mov	eax, dword [eax - 8]
	test	eax, eax
	je	LBB41_14
	cmp	dword [eax + 4], 0
	je	LBB41_14
	mov	ecx, dword [eax + 12]
	test	ecx, ecx
	je	LBB41_14
	cmp	dword [ecx + 4], 0
	je	LBB41_14
	mov	edx, dword [ecx]
	mov	esi, dword [eax]
	lea	edx, [edx + esi + 16]
	mov	dword [eax], edx
	mov	ecx, dword [ecx + 12]
	mov	dword [eax + 12], ecx
	test	ecx, ecx
	je	LBB41_13
	mov	dword [ecx + 8], eax
	jmp	LBB41_14
LBB41_13:
	mov	dword [alloc_tail], eax
	jmp	LBB41_14
Lfunc_end41:
align 16
alloc_coalesce_next:
	mov	eax, dword [ecx + 12]
	test	eax, eax
	je	LBB42_6
	push	ebp
	mov	ebp, esp
	push	esi
	cmp	dword [eax + 4], 0
	je	LBB42_5
	mov	edx, dword [eax]
	mov	esi, dword [ecx]
	lea	edx, [edx + esi + 16]
	mov	dword [ecx], edx
	mov	eax, dword [eax + 12]
	mov	dword [ecx + 12], eax
	test	eax, eax
	je	LBB42_4
	mov	dword [eax + 8], ecx
	jmp	LBB42_5
LBB42_4:
	mov	dword [alloc_tail], ecx
LBB42_5:
	pop	esi
	pop	ebp
LBB42_6:
	ret
Lfunc_end42:
global _exit
align 16
_exit:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	ebx, dword [ebp + 8]
	mov	eax, 2
	xor	ecx, ecx
	xor	edx, edx
	int	128
align 16
LBB43_1:
	jmp	LBB43_1
Lfunc_end43:
global exit
align 16
exit:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	ebx, dword [ebp + 8]
	mov	eax, 2
	xor	ecx, ecx
	xor	edx, edx
	int	128
align 16
LBB44_1:
	jmp	LBB44_1
Lfunc_end44:
global getenv
align 16
getenv:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	esi
	mov	edx, dword [ebp + 8]
	movzx	ebx, byte [edx]
	test	bl, bl
	je	LBB45_1
	mov	eax, 1
	mov	esi, ebx
align 16
LBB45_3:
	movzx	ecx, byte [eax + L.str.17-1]
	cmp	bl, cl
	jne	LBB45_6
	movzx	ebx, byte [edx + eax]
	inc	eax
	test	bl, bl
	jne	LBB45_3
	movzx	ecx, byte [eax + L.str.17-1]
	xor	ebx, ebx
LBB45_6:
	mov	eax, L.str.18
	cmp	bl, cl
	je	LBB45_14
	inc	edx
	mov	eax, L.str.19
	mov	ecx, esi
align 16
LBB45_8:
	cmp	cl, byte [eax]
	jne	LBB45_11
	inc	eax
	movzx	ecx, byte [edx]
	inc	edx
	test	cl, cl
	jne	LBB45_8
	xor	ecx, ecx
LBB45_11:
	movzx	ecx, cl
	jmp	LBB45_12
LBB45_1:
	mov	eax, L.str.19
	xor	ecx, ecx
LBB45_12:
	movzx	eax, byte [eax]
	cmp	ecx, eax
	mov	eax, L.str.20
	je	LBB45_14
	xor	eax, eax
LBB45_14:
	pop	esi
	pop	ebx
	pop	ebp
	ret
Lfunc_end45:
global rand
align 16
rand:
	push	ebp
	mov	ebp, esp
	imul	eax, dword [rand_state], 1103515245
	add	eax, 12345
	mov	dword [rand_state], eax
	shr	eax, 16
	and	eax, 32767
	pop	ebp
	ret
Lfunc_end46:
global srand
align 16
srand:
	push	ebp
	mov	ebp, esp
	mov	eax, dword [ebp + 8]
	mov	dword [rand_state], eax
	pop	ebp
	ret
Lfunc_end47:
global fabs
align 16
fabs:
	push	ebp
	mov	ebp, esp
	and	esp, -8
	sub	esp, 16
	fld	qword [ebp + 8]
	fstp	qword [esp + 8]
	fld	qword [esp + 8]
	fabs
	fstp	qword [esp]
	fld	qword [esp]
	mov	esp, ebp
	pop	ebp
	ret
Lfunc_end48:
global sqrt
align 16
sqrt:
	push	ebp
	mov	ebp, esp
	and	esp, -8
	sub	esp, 16
	fld	qword [ebp + 8]
	fstp	qword [esp + 8]
	fld	qword [esp + 8]
	fsqrt
	fstp	qword [esp]
	fld	qword [esp]
	mov	esp, ebp
	pop	ebp
	ret
Lfunc_end49:
global floor
align 16
floor:
	push	ebp
	mov	ebp, esp
	and	esp, -8
	sub	esp, 24
	fld	qword [ebp + 8]
	fstp	qword [esp + 16]
	fnstcw	word [esp + 4]
	movzx	eax, word [esp + 4]
	and	eax, -3073
	or	eax, 1024
	mov	word [esp + 6], ax
	fldcw	word [esp + 6]
	fld	qword [esp + 16]
	frndint
	fstp	qword [esp + 8]
	fldcw	word [esp + 4]
	fld	qword [esp + 8]
	mov	esp, ebp
	pop	ebp
	ret
Lfunc_end50:
global ceil
align 16
ceil:
	push	ebp
	mov	ebp, esp
	and	esp, -8
	sub	esp, 24
	fld	qword [ebp + 8]
	fstp	qword [esp + 16]
	fnstcw	word [esp + 4]
	movzx	eax, word [esp + 4]
	and	eax, -3073
	or	eax, 2048
	mov	word [esp + 6], ax
	fldcw	word [esp + 6]
	fld	qword [esp + 16]
	frndint
	fstp	qword [esp + 8]
	fldcw	word [esp + 4]
	fld	qword [esp + 8]
	mov	esp, ebp
	pop	ebp
	ret
Lfunc_end51:
global sin
align 16
sin:
	push	ebp
	mov	ebp, esp
	and	esp, -8
	sub	esp, 16
	fld	qword [ebp + 8]
	fstp	qword [esp + 8]
	fld	qword [esp + 8]
	fsin
	fstp	qword [esp]
	fld	qword [esp]
	mov	esp, ebp
	pop	ebp
	ret
Lfunc_end52:
global cos
align 16
cos:
	push	ebp
	mov	ebp, esp
	and	esp, -8
	sub	esp, 16
	fld	qword [ebp + 8]
	fstp	qword [esp + 8]
	fld	qword [esp + 8]
	fcos
	fstp	qword [esp]
	fld	qword [esp]
	mov	esp, ebp
	pop	ebp
	ret
Lfunc_end53:
global atan
align 16
atan:
	push	ebp
	mov	ebp, esp
	and	esp, -8
	sub	esp, 16
	fld	qword [ebp + 8]
	fstp	qword [esp + 8]
	fld	qword [esp + 8]
	fld1
	fpatan
	fstp	qword [esp]
	fld	qword [esp]
	mov	esp, ebp
	pop	ebp
	ret
Lfunc_end54:
global atan2
align 16
atan2:
	push	ebp
	mov	ebp, esp
	and	esp, -8
	sub	esp, 24
	fld	qword [ebp + 16]
	fld	qword [ebp + 8]
	fstp	qword [esp + 16]
	fstp	qword [esp + 8]
	fld	qword [esp + 16]
	fld	qword [esp + 8]
	fpatan
	fstp	qword [esp]
	fld	qword [esp]
	mov	esp, ebp
	pop	ebp
	ret
Lfunc_end55:
global pow
align 16
pow:
	push	ebp
	mov	ebp, esp
	and	esp, -8
	sub	esp, 24
	fld	qword [ebp + 16]
	fld	qword [ebp + 8]
	fstp	qword [esp + 16]
	fstp	qword [esp + 8]
	fld	qword [esp + 8]
	fld	qword [esp + 16]
	fyl2x
	fld	st0
	frndint
	fxch	st1
	fsub	st0, st1
	f2xm1
	fld1
	faddp	st1, st0
	fscale
	fstp	st1
	fstp	qword [esp]
	fld	qword [esp]
	mov	esp, ebp
	pop	ebp
	ret
Lfunc_end56:
global open
align 16
open:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 8
	mov	ecx, dword [ebp + 8]
	test	ecx, ecx
	je	LBB57_1
	mov	esi, dword [ebp + 12]
	mov	eax, esi
	and	eax, 1027
	cmp	eax, 1024
	je	LBB57_1
	mov	eax, esi
	and	eax, 515
	cmp	eax, 512
	je	LBB57_1
	mov	eax, esi
	and	eax, -3844
	jne	LBB57_1
	mov	eax, esi
	and	eax, 3
	cmp	eax, 3
	je	LBB57_1
	xor	edi, edi
	test	esi, 256
	je	LBB57_8
	lea	eax, [ebp + 20]
	mov	dword [ebp - 20], eax
	mov	edi, dword [ebp + 16]
LBB57_8:
	call	mapped_path
	mov	ebx, eax
	mov	eax, 6
	mov	ecx, esi
	mov	edx, edi
	int	128
	test	eax, eax
	js	LBB57_16
	mov	dword [ebp - 16], eax
	mov	ecx, ebx
	call	is_persist_slot_compat_basename
	test	eax, eax
	je	LBB57_10
	movsx	ebx, byte [ebx + 7]
	cmp	ebx, 48
	mov	eax, dword [ebp - 16]
	jl	LBB57_20
	add	ebx, -48
	cmp	eax, 31
	ja	LBB57_14
	mov	byte [eax + tracked_persist_fd], 1
	mov	byte [eax + tracked_persist_slot], bl
LBB57_14:
	cmp	ebx, 5
	ja	LBB57_20
	shl	ebx, 16
	or	ebx, 536870913
	mov	eax, 15
	mov	ecx, esi
	mov	edx, edi
	int	128
	mov	eax, dword [ebp - 16]
	jmp	LBB57_20
LBB57_1:
	mov	dword [errno], 22
LBB57_19:
	mov	eax, -1
LBB57_20:
	add	esp, 8
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
LBB57_16:
	cmp	eax, -1
	mov	ecx, 2
	je	LBB57_18
	neg	eax
	mov	ecx, eax
LBB57_18:
	mov	dword [errno], ecx
	jmp	LBB57_19
LBB57_10:
	mov	eax, dword [ebp - 16]
	jmp	LBB57_20
Lfunc_end57:
align 16
mapped_path:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 12
	lea	eax, [ecx + 1]
	mov	dword [ebp - 24], ecx
	mov	edx, ecx
	jmp	LBB58_1
align 16
LBB58_6:
	mov	edx, eax
LBB58_7:
	inc	eax
LBB58_1:
	movzx	ecx, byte [eax - 1]
	cmp	ecx, 47
	je	LBB58_6
	cmp	ecx, 92
	je	LBB58_6
	test	ecx, ecx
	jne	LBB58_7
	movzx	ecx, byte [edx]
	xor	edi, edi
	test	cl, cl
	mov	byte [ebp - 13], cl
	mov	dword [ebp - 20], edx
	je	LBB58_5
	lea	ebx, [edx + 1]
	mov	eax, L.str.25
align 16
LBB58_9:
	movzx	edi, cl
	lea	ecx, [edi - 91]
	cmp	ecx, -26
	mov	ecx, edi
	jb	LBB58_11
	lea	ecx, [edi + 32]
LBB58_11:
	movzx	edx, byte [eax]
	lea	esi, [edx - 91]
	cmp	esi, -26
	jb	LBB58_13
	add	edx, 32
LBB58_13:
	cmp	ecx, edx
	jne	LBB58_14
	inc	eax
	movzx	ecx, byte [ebx]
	inc	ebx
	test	cl, cl
	jne	LBB58_9
	mov	edx, dword [ebp - 20]
	xor	edi, edi
	jmp	LBB58_17
LBB58_5:
	mov	eax, L.str.25
	jmp	LBB58_17
LBB58_14:
	mov	edx, dword [ebp - 20]
LBB58_17:
	lea	ecx, [edi - 91]
	cmp	ecx, -26
	jb	LBB58_19
	add	edi, 32
LBB58_19:
	movzx	ecx, byte [eax]
	lea	eax, [ecx - 91]
	cmp	eax, -26
	jb	LBB58_21
	add	ecx, 32
LBB58_21:
	mov	eax, L.str.26
	cmp	edi, ecx
	je	LBB58_88
	xor	esi, esi
	movzx	ecx, byte [ebp - 13]
	test	cl, cl
	je	LBB58_23
	lea	ebx, [edx + 1]
	mov	eax, L.str.27
align 16
LBB58_25:
	movzx	edx, cl
	lea	ecx, [edx - 91]
	cmp	ecx, -26
	mov	ecx, edx
	jb	LBB58_27
	lea	ecx, [edx + 32]
LBB58_27:
	movzx	edi, byte [eax]
	lea	esi, [edi - 91]
	cmp	esi, -26
	jb	LBB58_29
	add	edi, 32
LBB58_29:
	cmp	ecx, edi
	jne	LBB58_30
	inc	eax
	movzx	ecx, byte [ebx]
	inc	ebx
	test	cl, cl
	jne	LBB58_25
	mov	edx, dword [ebp - 20]
	xor	esi, esi
	jmp	LBB58_33
LBB58_23:
	mov	eax, L.str.27
	jmp	LBB58_33
LBB58_30:
	mov	esi, edx
	mov	edx, dword [ebp - 20]
LBB58_33:
	lea	ecx, [esi - 91]
	cmp	ecx, -26
	jb	LBB58_35
	add	esi, 32
LBB58_35:
	movzx	ecx, byte [eax]
	lea	eax, [ecx - 91]
	cmp	eax, -26
	jb	LBB58_37
	add	ecx, 32
LBB58_37:
	mov	eax, L.str.28
	cmp	esi, ecx
	je	LBB58_88
	xor	esi, esi
	movzx	ecx, byte [ebp - 13]
	test	cl, cl
	je	LBB58_39
	lea	ebx, [edx + 1]
	mov	eax, L.str.29
align 16
LBB58_41:
	movzx	edx, cl
	lea	ecx, [edx - 91]
	cmp	ecx, -26
	mov	ecx, edx
	jb	LBB58_43
	lea	ecx, [edx + 32]
LBB58_43:
	movzx	edi, byte [eax]
	lea	esi, [edi - 91]
	cmp	esi, -26
	jb	LBB58_45
	add	edi, 32
LBB58_45:
	cmp	ecx, edi
	jne	LBB58_46
	inc	eax
	movzx	ecx, byte [ebx]
	inc	ebx
	test	cl, cl
	jne	LBB58_41
	mov	edx, dword [ebp - 20]
	xor	esi, esi
	jmp	LBB58_49
LBB58_39:
	mov	eax, L.str.29
	jmp	LBB58_49
LBB58_46:
	mov	esi, edx
	mov	edx, dword [ebp - 20]
LBB58_49:
	lea	ecx, [esi - 91]
	cmp	ecx, -26
	jb	LBB58_51
	add	esi, 32
LBB58_51:
	movzx	ecx, byte [eax]
	lea	eax, [ecx - 91]
	cmp	eax, -26
	jb	LBB58_53
	add	ecx, 32
LBB58_53:
	mov	eax, L.str.30
	cmp	esi, ecx
	je	LBB58_88
	xor	esi, esi
	movzx	ecx, byte [ebp - 13]
	test	cl, cl
	je	LBB58_55
	lea	ebx, [edx + 1]
	mov	eax, L.str.31
align 16
LBB58_57:
	movzx	edx, cl
	lea	ecx, [edx - 91]
	cmp	ecx, -26
	mov	ecx, edx
	jb	LBB58_59
	lea	ecx, [edx + 32]
LBB58_59:
	movzx	edi, byte [eax]
	lea	esi, [edi - 91]
	cmp	esi, -26
	jb	LBB58_61
	add	edi, 32
LBB58_61:
	cmp	ecx, edi
	jne	LBB58_62
	inc	eax
	movzx	ecx, byte [ebx]
	inc	ebx
	test	cl, cl
	jne	LBB58_57
	mov	edx, dword [ebp - 20]
	xor	esi, esi
	jmp	LBB58_65
LBB58_55:
	mov	eax, L.str.31
	jmp	LBB58_65
LBB58_62:
	mov	esi, edx
	mov	edx, dword [ebp - 20]
LBB58_65:
	lea	ecx, [esi - 91]
	cmp	ecx, -26
	jb	LBB58_67
	add	esi, 32
LBB58_67:
	movzx	ecx, byte [eax]
	lea	eax, [ecx - 91]
	cmp	eax, -26
	jb	LBB58_69
	add	ecx, 32
LBB58_69:
	mov	eax, L.str.33
	cmp	esi, ecx
	je	LBB58_88
	xor	edi, edi
	movzx	ecx, byte [ebp - 13]
	test	cl, cl
	je	LBB58_71
	lea	edi, [edx + 1]
	mov	ebx, L.str.32
align 16
LBB58_73:
	movzx	ecx, cl
	lea	eax, [ecx - 91]
	cmp	eax, -26
	mov	eax, ecx
	jb	LBB58_75
	lea	eax, [ecx + 32]
LBB58_75:
	movzx	edx, byte [ebx]
	lea	esi, [edx - 91]
	cmp	esi, -26
	jb	LBB58_77
	add	edx, 32
LBB58_77:
	cmp	eax, edx
	jne	LBB58_78
	inc	ebx
	movzx	ecx, byte [edi]
	inc	edi
	test	cl, cl
	jne	LBB58_73
	mov	eax, L.str.33
	xor	edi, edi
	jmp	LBB58_81
LBB58_71:
	mov	ebx, L.str.32
	jmp	LBB58_81
LBB58_78:
	mov	edi, ecx
	mov	eax, L.str.33
LBB58_81:
	lea	ecx, [edi - 91]
	cmp	ecx, -26
	jb	LBB58_83
	add	edi, 32
LBB58_83:
	movzx	edx, byte [ebx]
	lea	ecx, [edx - 91]
	cmp	ecx, -26
	jb	LBB58_85
	add	edx, 32
LBB58_85:
	mov	esi, dword [ebp - 20]
	cmp	edi, edx
	je	LBB58_88
	mov	ecx, esi
	call	is_persist_slot_compat_basename
	test	eax, eax
	mov	eax, dword [ebp - 24]
	je	LBB58_88
	movzx	eax, byte [esi + 7]
	mov	byte [mapped_path.compat_persist_slot_path+7], al
	mov	eax, mapped_path.compat_persist_slot_path
LBB58_88:
	add	esp, 12
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
Lfunc_end58:
global read
align 16
read:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	edx, dword [ebp + 16]
	mov	ecx, dword [ebp + 12]
	test	ecx, ecx
	setne	al
	test	edx, edx
	sete	ah
	or	ah, al
	jne	LBB59_3
	mov	dword [errno], 22
LBB59_2:
	mov	eax, -1
	jmp	LBB59_16
LBB59_3:
	mov	ebx, dword [ebp + 8]
	mov	eax, 7
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB59_6
	cmp	ebx, 31
	ja	LBB59_15
	cmp	byte [ebx + tracked_persist_fd], 0
	je	LBB59_15
	movzx	ebx, byte [ebx + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB59_15
	shl	ebx, 16
	or	ebx, 536870914
	mov	eax, 15
	xor	edx, edx
	int	128
LBB59_15:
	mov	eax, ecx
	jmp	LBB59_16
LBB59_6:
	xor	eax, eax
	test	ecx, ecx
	js	LBB59_7
LBB59_16:
	pop	ebx
	pop	ebp
	ret
LBB59_7:
	cmp	ecx, -1
	mov	eax, 5
	je	LBB59_9
	neg	ecx
	mov	eax, ecx
LBB59_9:
	mov	dword [errno], eax
	jmp	LBB59_2
Lfunc_end59:
global write
align 16
write:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	edx, dword [ebp + 16]
	mov	ecx, dword [ebp + 12]
	test	ecx, ecx
	setne	al
	test	edx, edx
	sete	ah
	or	ah, al
	jne	LBB60_3
	mov	dword [errno], 22
LBB60_2:
	mov	eax, -1
	jmp	LBB60_16
LBB60_3:
	mov	ebx, dword [ebp + 8]
	mov	eax, 4
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB60_6
	cmp	ebx, 31
	ja	LBB60_15
	cmp	byte [ebx + tracked_persist_fd], 0
	je	LBB60_15
	movzx	ebx, byte [ebx + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB60_15
	shl	ebx, 16
	or	ebx, 536870916
	mov	eax, 15
	xor	edx, edx
	int	128
LBB60_15:
	mov	eax, ecx
	jmp	LBB60_16
LBB60_6:
	xor	eax, eax
	test	ecx, ecx
	js	LBB60_7
LBB60_16:
	pop	ebx
	pop	ebp
	ret
LBB60_7:
	cmp	ecx, -1
	mov	eax, 5
	je	LBB60_9
	neg	ecx
	mov	eax, ecx
LBB60_9:
	mov	dword [errno], eax
	jmp	LBB60_2
Lfunc_end60:
global close
align 16
close:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	push	eax
	mov	esi, dword [ebp + 8]
	mov	edi, -1
	cmp	esi, 31
	ja	LBB61_3
	cmp	byte [esi + tracked_persist_fd], 0
	je	LBB61_3
	movzx	edi, byte [esi + tracked_persist_slot]
LBB61_3:
	mov	eax, 12
	mov	ebx, esi
	xor	ecx, ecx
	xor	edx, edx
	int	128
	mov	ecx, eax
	or	ecx, edi
	js	LBB61_8
	cmp	edi, 5
	ja	LBB61_6
	shl	edi, 16
	or	edi, 536870920
	mov	dword [ebp - 16], eax
	mov	eax, 15
	mov	ebx, edi
	xor	ecx, ecx
	xor	edx, edx
	int	128
	mov	eax, dword [ebp - 16]
LBB61_6:
	cmp	esi, 31
	ja	LBB61_12
	mov	byte [esi + tracked_persist_fd], 0
	mov	byte [esi + tracked_persist_slot], 0
	jmp	LBB61_12
LBB61_8:
	test	eax, eax
	jns	LBB61_12
	cmp	eax, -1
	mov	ecx, 9
	je	LBB61_11
	neg	eax
	mov	ecx, eax
LBB61_11:
	mov	dword [errno], ecx
	mov	eax, -1
LBB61_12:
	add	esp, 4
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
Lfunc_end61:
global dup
align 16
dup:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	ebx, dword [ebp + 8]
	mov	eax, 32
	xor	ecx, ecx
	xor	edx, edx
	int	128
	test	eax, eax
	js	LBB62_8
	cmp	ebx, 31
	ja	LBB62_5
	cmp	byte [ebx + tracked_persist_fd], 0
	je	LBB62_5
	cmp	eax, 31
	ja	LBB62_11
	movzx	edx, byte [ebx + tracked_persist_slot]
	mov	cl, 1
	jmp	LBB62_7
LBB62_5:
	cmp	eax, 31
	ja	LBB62_11
	xor	ecx, ecx
	xor	edx, edx
LBB62_7:
	mov	byte [eax + tracked_persist_fd], cl
	mov	byte [eax + tracked_persist_slot], dl
	jmp	LBB62_11
LBB62_8:
	cmp	eax, -1
	mov	ecx, 9
	je	LBB62_10
	neg	eax
	mov	ecx, eax
LBB62_10:
	mov	dword [errno], ecx
	mov	eax, -1
LBB62_11:
	pop	ebx
	pop	ebp
	ret
Lfunc_end62:
global dup2
align 16
dup2:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	ebx, dword [ebp + 8]
	mov	ecx, dword [ebp + 12]
	mov	eax, 33
	xor	edx, edx
	int	128
	test	eax, eax
	js	LBB63_8
	cmp	ebx, 31
	ja	LBB63_5
	cmp	byte [ebx + tracked_persist_fd], 0
	je	LBB63_5
	cmp	eax, 31
	ja	LBB63_11
	movzx	edx, byte [ebx + tracked_persist_slot]
	mov	cl, 1
	jmp	LBB63_7
LBB63_5:
	cmp	eax, 31
	ja	LBB63_11
	xor	ecx, ecx
	xor	edx, edx
LBB63_7:
	mov	byte [eax + tracked_persist_fd], cl
	mov	byte [eax + tracked_persist_slot], dl
	jmp	LBB63_11
LBB63_8:
	cmp	eax, -1
	mov	ecx, 9
	je	LBB63_10
	neg	eax
	mov	ecx, eax
LBB63_10:
	mov	dword [errno], ecx
	mov	eax, -1
LBB63_11:
	pop	ebx
	pop	ebp
	ret
Lfunc_end63:
global dup3
align 16
dup3:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	edx, dword [ebp + 16]
	test	edx, -2049
	je	LBB64_2
	mov	dword [errno], 22
LBB64_13:
	mov	eax, -1
LBB64_14:
	pop	ebx
	pop	ebp
	ret
LBB64_2:
	mov	ecx, dword [ebp + 12]
	mov	ebx, dword [ebp + 8]
	mov	eax, 34
	int	128
	test	eax, eax
	js	LBB64_10
	cmp	ebx, 31
	ja	LBB64_7
	cmp	byte [ebx + tracked_persist_fd], 0
	je	LBB64_7
	cmp	eax, 31
	ja	LBB64_14
	movzx	edx, byte [ebx + tracked_persist_slot]
	mov	cl, 1
	jmp	LBB64_9
LBB64_7:
	cmp	eax, 31
	ja	LBB64_14
	xor	ecx, ecx
	xor	edx, edx
LBB64_9:
	mov	byte [eax + tracked_persist_fd], cl
	mov	byte [eax + tracked_persist_slot], dl
	jmp	LBB64_14
LBB64_10:
	cmp	eax, -1
	mov	ecx, 9
	je	LBB64_12
	neg	eax
	mov	ecx, eax
LBB64_12:
	mov	dword [errno], ecx
	jmp	LBB64_13
Lfunc_end64:
global fcntl
align 16
fcntl:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	esi
	push	eax
	mov	ecx, dword [ebp + 12]
	cmp	ecx, 1
	je	LBB65_1
	mov	esi, 22
	cmp	ecx, 2
	jne	LBB65_7
	lea	eax, [ebp + 20]
	mov	dword [ebp - 12], eax
	mov	edx, dword [ebp + 16]
	cmp	edx, 1
	jbe	LBB65_4
	jmp	LBB65_7
LBB65_1:
	xor	edx, edx
LBB65_4:
	mov	ebx, dword [ebp + 8]
	mov	eax, 35
	int	128
	test	eax, eax
	jns	LBB65_8
	cmp	eax, -1
	mov	esi, 9
	je	LBB65_7
	neg	eax
	mov	esi, eax
LBB65_7:
	mov	dword [errno], esi
	mov	eax, -1
LBB65_8:
	add	esp, 4
	pop	esi
	pop	ebx
	pop	ebp
	ret
Lfunc_end65:
global lseek
align 16
lseek:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	ebx, dword [ebp + 8]
	mov	ecx, dword [ebp + 12]
	mov	edx, dword [ebp + 16]
	mov	eax, 8
	int	128
	test	eax, eax
	jns	LBB66_4
	cmp	eax, -1
	mov	ecx, 22
	je	LBB66_3
	neg	eax
	mov	ecx, eax
LBB66_3:
	mov	dword [errno], ecx
	mov	eax, -1
LBB66_4:
	pop	ebx
	pop	ebp
	ret
Lfunc_end66:
global pread
align 16
pread:
	push	ebp
	mov	ebp, esp
	mov	ecx, dword [ebp + 8]
	mov	edx, dword [ebp + 12]
	push	0
	push	dword [ebp + 20]
	push	dword [ebp + 16]
	call	positioned_io
	add	esp, 12
	pop	ebp
	ret
Lfunc_end67:
align 16
positioned_io:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 12
	mov	esi, dword [ebp + 12]
	mov	edi, 22
	test	esi, esi
	js	LBB68_2
	mov	ebx, dword [ebp + 8]
	test	edx, edx
	sete	al
	test	ebx, ebx
	setne	ah
	test	al, ah
	je	LBB68_4
LBB68_2:
	mov	dword [errno], edi
	mov	eax, -1
LBB68_3:
	add	esp, 12
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
LBB68_4:
	mov	edi, ebx
	mov	dword [ebp - 24], edx
	mov	eax, 8
	mov	ebx, ecx
	xor	ecx, ecx
	mov	edx, 1
	int	128
	test	eax, eax
	js	LBB68_12
	mov	dword [ebp - 20], eax
	mov	eax, 8
	mov	dword [ebp - 16], ebx
	mov	ecx, esi
	xor	edx, edx
	int	128
	test	eax, eax
	js	LBB68_14
	cmp	dword [ebp + 16], 0
	je	LBB68_17
	mov	eax, 4
	mov	ebx, dword [ebp - 16]
	mov	ecx, dword [ebp - 24]
	mov	edx, edi
	int	128
	test	eax, eax
	jle	LBB68_23
	mov	esi, eax
	cmp	ebx, 31
	ja	LBB68_29
	cmp	byte [ebx + tracked_persist_fd], 0
	je	LBB68_29
	movzx	ebx, byte [ebx + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB68_22
	shl	ebx, 16
	or	ebx, 536870916
	mov	eax, 15
	mov	ecx, esi
	xor	edx, edx
	int	128
	jmp	LBB68_22
LBB68_12:
	cmp	eax, -1
	mov	edi, 22
	je	LBB68_2
	neg	eax
	mov	edi, eax
	jmp	LBB68_2
LBB68_14:
	cmp	eax, -1
	mov	edi, 22
	je	LBB68_16
	neg	eax
	mov	edi, eax
LBB68_16:
	mov	dword [errno], edi
	mov	eax, 8
	mov	ebx, dword [ebp - 16]
	mov	ecx, dword [ebp - 20]
	xor	edx, edx
	int	128
	jmp	LBB68_2
LBB68_17:
	mov	eax, 7
	mov	ebx, dword [ebp - 16]
	mov	ecx, dword [ebp - 24]
	mov	edx, edi
	int	128
	test	eax, eax
	jle	LBB68_23
	mov	esi, eax
	cmp	ebx, 31
	ja	LBB68_29
	cmp	byte [ebx + tracked_persist_fd], 0
	je	LBB68_29
	movzx	ebx, byte [ebx + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB68_22
	shl	ebx, 16
	or	ebx, 536870914
	mov	eax, 15
	mov	ecx, esi
	xor	edx, edx
	int	128
LBB68_22:
	mov	ebx, dword [ebp - 16]
	jmp	LBB68_29
LBB68_23:
	js	LBB68_26
	xor	esi, esi
	jmp	LBB68_29
LBB68_26:
	cmp	eax, -1
	mov	ecx, 5
	je	LBB68_28
	neg	eax
	mov	ecx, eax
LBB68_28:
	mov	dword [errno], ecx
	mov	esi, -1
LBB68_29:
	mov	edi, dword [errno]
	mov	eax, 8
	mov	ecx, dword [ebp - 20]
	xor	edx, edx
	int	128
	test	eax, eax
	js	LBB68_31
	mov	eax, esi
	test	esi, esi
	jns	LBB68_3
	jmp	LBB68_2
LBB68_31:
	cmp	eax, -1
	mov	ecx, 22
	je	LBB68_33
	neg	eax
	mov	ecx, eax
LBB68_33:
	test	esi, esi
	js	LBB68_2
	mov	edi, ecx
	jmp	LBB68_2
Lfunc_end68:
global pwrite
align 16
pwrite:
	push	ebp
	mov	ebp, esp
	mov	ecx, dword [ebp + 8]
	mov	edx, dword [ebp + 12]
	push	1
	push	dword [ebp + 20]
	push	dword [ebp + 16]
	call	positioned_io
	add	esp, 12
	pop	ebp
	ret
Lfunc_end69:
global vibe_clock_gettime
align 16
vibe_clock_gettime:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	ecx, dword [ebp + 12]
	test	ecx, ecx
	je	LBB70_1
	mov	ebx, dword [ebp + 8]
	mov	eax, 29
	mov	edx, 16
	int	128
	test	eax, eax
	jns	LBB70_6
	cmp	eax, -1
	mov	ecx, 22
	je	LBB70_5
	neg	eax
	mov	ecx, eax
	jmp	LBB70_5
LBB70_1:
	mov	ecx, 22
LBB70_5:
	mov	dword [errno], ecx
	mov	eax, -1
LBB70_6:
	pop	ebx
	pop	ebp
	ret
Lfunc_end70:
global vibe_clock_monotonic
align 16
vibe_clock_monotonic:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	ecx, dword [ebp + 8]
	test	ecx, ecx
	je	LBB71_1
	mov	eax, 29
	mov	ebx, 1
	mov	edx, 16
	int	128
	test	eax, eax
	jns	LBB71_6
	cmp	eax, -1
	mov	ecx, 22
	je	LBB71_5
	neg	eax
	mov	ecx, eax
	jmp	LBB71_5
LBB71_1:
	mov	ecx, 22
LBB71_5:
	mov	dword [errno], ecx
	mov	eax, -1
LBB71_6:
	pop	ebx
	pop	ebp
	ret
Lfunc_end71:
global vibe_clock_ticks_to_milliseconds
align 16
vibe_clock_ticks_to_milliseconds:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	push	eax
	mov	edi, dword [ebp + 12]
	test	edi, edi
	je	LBB72_1
	mov	ecx, dword [ebp + 8]
	mov	eax, ecx
	xor	edx, edx
	div	edi
	xor	ebx, ebx
	mov	esi, -1
	cmp	eax, 4294967
	ja	LBB72_9
	imul	esi, eax, 1000
	mov	dword [ebp - 16], esi
	imul	eax, edi
	cmp	ecx, eax
	jne	LBB72_4
LBB72_8:
	add	ebx, dword [ebp - 16]
	mov	esi, ebx
	jmp	LBB72_9
LBB72_1:
	xor	esi, esi
LBB72_9:
	mov	eax, esi
	add	esp, 4
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
LBB72_4:
	xor	ebx, ebx
	mov	eax, 1000
	xor	esi, esi
	jmp	LBB72_5
align 16
LBB72_7:
	sbb	ebx, -1
	add	ecx, edx
	dec	eax
	mov	esi, ecx
	mov	edi, dword [ebp + 12]
	je	LBB72_8
LBB72_5:
	sub	edi, esi
	mov	ecx, edi
	neg	ecx
	cmp	edx, edi
	jae	LBB72_7
	mov	ecx, esi
	jmp	LBB72_7
Lfunc_end72:
global vibe_monotonic_ticks
align 16
vibe_monotonic_ticks:
	push	ebp
	mov	ebp, esp
	push	ebx
	sub	esp, 16
	lea	ecx, [ebp - 20]
	mov	eax, 29
	mov	ebx, 1
	mov	edx, 16
	int	128
	test	eax, eax
	js	LBB73_2
	mov	eax, dword [ebp - 20]
	jmp	LBB73_5
LBB73_2:
	cmp	eax, -1
	mov	ecx, 22
	je	LBB73_4
	neg	eax
	mov	ecx, eax
LBB73_4:
	mov	dword [errno], ecx
	xor	eax, eax
LBB73_5:
	add	esp, 16
	pop	ebx
	pop	ebp
	ret
Lfunc_end73:
global vibe_monotonic_milliseconds
align 16
vibe_monotonic_milliseconds:
	push	ebp
	mov	ebp, esp
	push	ebx
	sub	esp, 16
	lea	ecx, [ebp - 20]
	mov	eax, 29
	mov	ebx, 1
	mov	edx, 16
	int	128
	test	eax, eax
	js	LBB74_2
	mov	eax, dword [ebp - 12]
	jmp	LBB74_5
LBB74_2:
	cmp	eax, -1
	mov	ecx, 22
	je	LBB74_4
	neg	eax
	mov	ecx, eax
LBB74_4:
	mov	dword [errno], ecx
	xor	eax, eax
LBB74_5:
	add	esp, 16
	pop	ebx
	pop	ebp
	ret
Lfunc_end74:
global clock_gettime
align 16
clock_gettime:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	esi
	sub	esp, 16
	mov	esi, dword [ebp + 12]
	test	esi, esi
	setne	al
	cmp	dword [ebp + 8], 1
	sete	cl
	test	cl, al
	jne	LBB75_2
	mov	dword [errno], 22
	jmp	LBB75_7
LBB75_2:
	lea	ecx, [ebp - 24]
	mov	eax, 29
	mov	ebx, 1
	mov	edx, 16
	int	128
	test	eax, eax
	js	LBB75_4
	mov	ecx, dword [ebp - 16]
	mov	edx, 274877907
	mov	eax, ecx
	mul	edx
	shr	edx, 6
	mov	dword [esi], edx
	imul	eax, edx, 1000
	sub	ecx, eax
	imul	eax, ecx, 1000000
	mov	dword [esi + 4], eax
	xor	eax, eax
	jmp	LBB75_8
LBB75_4:
	cmp	eax, -1
	mov	ecx, 22
	je	LBB75_6
	neg	eax
	mov	ecx, eax
LBB75_6:
	mov	dword [errno], ecx
LBB75_7:
	mov	eax, -1
LBB75_8:
	add	esp, 16
	pop	esi
	pop	ebx
	pop	ebp
	ret
Lfunc_end75:
global clock
align 16
clock:
	push	ebp
	mov	ebp, esp
	push	ebx
	sub	esp, 16
	lea	ecx, [ebp - 20]
	mov	eax, 29
	mov	ebx, 1
	mov	edx, 16
	int	128
	test	eax, eax
	js	LBB76_2
	mov	eax, dword [ebp - 12]
	jmp	LBB76_5
LBB76_2:
	cmp	eax, -1
	mov	ecx, 22
	je	LBB76_4
	neg	eax
	mov	ecx, eax
LBB76_4:
	mov	dword [errno], ecx
	xor	eax, eax
LBB76_5:
	add	esp, 16
	pop	ebx
	pop	ebp
	ret
Lfunc_end76:
global time
align 16
time:
	push	ebp
	mov	ebp, esp
	mov	eax, dword [ebp + 8]
	test	eax, eax
	je	LBB77_2
	mov	dword [eax], -1
LBB77_2:
	mov	dword [errno], 38
	mov	eax, -1
	pop	ebp
	ret
Lfunc_end77:
global ftruncate
align 16
ftruncate:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	ecx, dword [ebp + 12]
	test	ecx, ecx
	js	LBB78_1
	mov	ebx, dword [ebp + 8]
	mov	eax, 27
	xor	edx, edx
	int	128
	test	eax, eax
	jns	LBB78_6
	cmp	eax, -1
	mov	ecx, 5
	je	LBB78_5
	neg	eax
	mov	ecx, eax
	jmp	LBB78_5
LBB78_1:
	mov	ecx, 22
LBB78_5:
	mov	dword [errno], ecx
	mov	eax, -1
LBB78_6:
	pop	ebx
	pop	ebp
	ret
Lfunc_end78:
global truncate
align 16
truncate:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 8
	mov	edi, dword [ebp + 12]
	mov	ecx, dword [ebp + 8]
	test	ecx, ecx
	sete	al
	test	edi, edi
	sets	dl
	or	dl, al
	mov	esi, 22
	je	LBB79_1
LBB79_28:
	mov	dword [errno], esi
LBB79_29:
	mov	eax, -1
LBB79_30:
	add	esp, 8
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
LBB79_1:
	call	mapped_path
	mov	ebx, eax
	mov	eax, 6
	mov	ecx, 1
	xor	edx, edx
	int	128
	test	eax, eax
	js	LBB79_10
	mov	dword [ebp - 16], eax
	mov	ecx, ebx
	call	is_persist_slot_compat_basename
	mov	ecx, dword [ebp - 16]
	test	eax, eax
	je	LBB79_8
	movsx	ebx, byte [ebx + 7]
	cmp	ebx, 48
	jl	LBB79_8
	add	ebx, -48
	cmp	ecx, 31
	ja	LBB79_6
	mov	byte [ecx + tracked_persist_fd], 1
	mov	byte [ecx + tracked_persist_slot], bl
LBB79_6:
	cmp	ebx, 5
	ja	LBB79_8
	shl	ebx, 16
	or	ebx, 536870913
	mov	eax, 15
	mov	ecx, 1
	xor	edx, edx
	int	128
	mov	ecx, dword [ebp - 16]
LBB79_8:
	mov	eax, 27
	mov	ebx, ecx
	mov	ecx, edi
	xor	edx, edx
	int	128
	test	eax, eax
	js	LBB79_12
	mov	esi, dword [errno]
	jmp	LBB79_15
LBB79_10:
	cmp	eax, -1
	mov	esi, 2
	je	LBB79_28
	neg	eax
	mov	esi, eax
	jmp	LBB79_28
LBB79_12:
	cmp	eax, -1
	mov	esi, 5
	je	LBB79_14
	neg	eax
	mov	esi, eax
LBB79_14:
	mov	dword [errno], esi
	mov	eax, -1
LBB79_15:
	mov	ebx, dword [ebp - 16]
	mov	edi, -1
	cmp	ebx, 31
	mov	dword [ebp - 20], eax
	ja	LBB79_18
	cmp	byte [ebx + tracked_persist_fd], 0
	je	LBB79_18
	movzx	edi, byte [ebx + tracked_persist_slot]
LBB79_18:
	mov	eax, 12
	xor	ecx, ecx
	xor	edx, edx
	int	128
	mov	ecx, eax
	or	eax, edi
	js	LBB79_23
	cmp	edi, 5
	ja	LBB79_21
	shl	edi, 16
	or	edi, 536870920
	mov	eax, 15
	mov	ebx, edi
	xor	ecx, ecx
	xor	edx, edx
	int	128
LBB79_21:
	mov	ecx, dword [ebp - 16]
	cmp	ecx, 31
	mov	eax, dword [ebp - 20]
	ja	LBB79_27
	mov	byte [ecx + tracked_persist_fd], 0
	mov	byte [ecx + tracked_persist_slot], 0
	jmp	LBB79_27
LBB79_23:
	test	ecx, ecx
	mov	eax, dword [ebp - 20]
	jns	LBB79_27
	cmp	ecx, -1
	mov	edx, 9
	je	LBB79_26
	neg	ecx
	mov	edx, ecx
LBB79_26:
	mov	dword [errno], edx
	test	eax, eax
	je	LBB79_29
LBB79_27:
	test	eax, eax
	jns	LBB79_30
	jmp	LBB79_28
Lfunc_end79:
global access
align 16
access:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	mov	eax, dword [ebp + 12]
	cmp	eax, 8
	jae	LBB80_10
	shr	eax, 1
	and	eax, 1
	push	eax
	push	dword [ebp + 8]
	call	open
	add	esp, 8
	test	eax, eax
	js	LBB80_11
	mov	esi, eax
	mov	edi, -1
	cmp	eax, 31
	ja	LBB80_5
	cmp	byte [esi + tracked_persist_fd], 0
	je	LBB80_5
	movzx	edi, byte [esi + tracked_persist_slot]
LBB80_5:
	mov	eax, 12
	mov	ebx, esi
	xor	ecx, ecx
	xor	edx, edx
	int	128
	mov	ecx, eax
	or	ecx, edi
	js	LBB80_12
	cmp	edi, 5
	ja	LBB80_8
	shl	edi, 16
	or	edi, 536870920
	mov	eax, 15
	mov	ebx, edi
	xor	ecx, ecx
	xor	edx, edx
	int	128
LBB80_8:
	cmp	esi, 31
	ja	LBB80_9
	mov	byte [esi + tracked_persist_fd], 0
	mov	byte [esi + tracked_persist_slot], 0
	xor	eax, eax
	jmp	LBB80_18
LBB80_10:
	mov	dword [errno], 22
LBB80_11:
	mov	eax, -1
	jmp	LBB80_18
LBB80_12:
	test	eax, eax
	js	LBB80_15
LBB80_9:
	xor	eax, eax
	jmp	LBB80_18
LBB80_15:
	mov	ecx, eax
	cmp	eax, -1
	mov	edx, 9
	mov	eax, 0
	je	LBB80_17
	mov	edx, ecx
	neg	edx
LBB80_17:
	mov	dword [errno], edx
LBB80_18:
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
Lfunc_end80:
global unlink
align 16
unlink:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	ecx, dword [ebp + 8]
	test	ecx, ecx
	je	LBB81_1
	call	mapped_path
	mov	ebx, eax
	mov	eax, 17
	xor	ecx, ecx
	xor	edx, edx
	int	128
	test	eax, eax
	jns	LBB81_6
	cmp	eax, -1
	mov	ecx, 38
	je	LBB81_5
	neg	eax
	mov	ecx, eax
	jmp	LBB81_5
LBB81_1:
	mov	ecx, 22
LBB81_5:
	mov	dword [errno], ecx
	mov	eax, -1
LBB81_6:
	pop	ebx
	pop	ebp
	ret
Lfunc_end81:
global remove
align 16
remove:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	ecx, dword [ebp + 8]
	test	ecx, ecx
	je	LBB82_1
	call	mapped_path
	mov	ebx, eax
	mov	eax, 17
	xor	ecx, ecx
	xor	edx, edx
	int	128
	test	eax, eax
	jns	LBB82_6
	cmp	eax, -1
	mov	ecx, 38
	je	LBB82_5
	neg	eax
	mov	ecx, eax
	jmp	LBB82_5
LBB82_1:
	mov	ecx, 22
LBB82_5:
	mov	dword [errno], ecx
	mov	eax, -1
LBB82_6:
	pop	ebx
	pop	ebp
	ret
Lfunc_end82:
global mkdir
align 16
mkdir:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	push	eax
	mov	edi, dword [ebp + 8]
	test	edi, edi
	je	LBB83_1
	movzx	ebx, byte [edi]
	xor	edx, edx
	test	bl, bl
	mov	byte [ebp - 13], bl
	je	LBB83_4
	inc	edi
	mov	esi, L.str.36
	mov	edx, ebx
align 16
LBB83_6:
	movzx	ebx, dl
	lea	ecx, [ebx - 91]
	cmp	ecx, -26
	mov	edx, ebx
	jb	LBB83_8
	lea	edx, [ebx + 32]
LBB83_8:
	movzx	ecx, byte [esi]
	lea	eax, [ecx - 91]
	cmp	eax, -26
	jb	LBB83_10
	add	ecx, 32
LBB83_10:
	cmp	edx, ecx
	jne	LBB83_11
	inc	esi
	movzx	edx, byte [edi]
	inc	edi
	test	dl, dl
	jne	LBB83_6
	mov	edi, dword [ebp + 8]
	movzx	ebx, byte [ebp - 13]
	xor	edx, edx
	jmp	LBB83_14
LBB83_1:
	mov	ecx, 22
LBB83_2:
	mov	dword [errno], ecx
	mov	eax, -1
	jmp	LBB83_52
LBB83_4:
	mov	esi, L.str.36
	jmp	LBB83_14
LBB83_11:
	mov	edx, ebx
	mov	edi, dword [ebp + 8]
	movzx	ebx, byte [ebp - 13]
LBB83_14:
	lea	eax, [edx - 91]
	cmp	eax, -26
	jb	LBB83_16
	add	edx, 32
LBB83_16:
	movzx	ecx, byte [esi]
	lea	eax, [ecx - 91]
	cmp	eax, -26
	jb	LBB83_18
	add	ecx, 32
LBB83_18:
	cmp	edx, ecx
	je	LBB83_51
	xor	edx, edx
	test	bl, bl
	je	LBB83_20
	inc	edi
	mov	esi, L.str.37
	mov	edx, ebx
align 16
LBB83_22:
	movzx	ebx, dl
	lea	eax, [ebx - 91]
	cmp	eax, -26
	mov	edx, ebx
	jb	LBB83_24
	lea	edx, [ebx + 32]
LBB83_24:
	movzx	ecx, byte [esi]
	lea	eax, [ecx - 91]
	cmp	eax, -26
	jb	LBB83_26
	add	ecx, 32
LBB83_26:
	cmp	edx, ecx
	jne	LBB83_27
	inc	esi
	movzx	edx, byte [edi]
	inc	edi
	test	dl, dl
	jne	LBB83_22
	mov	edi, dword [ebp + 8]
	movzx	ebx, byte [ebp - 13]
	xor	edx, edx
	jmp	LBB83_30
LBB83_20:
	mov	esi, L.str.37
	jmp	LBB83_30
LBB83_27:
	mov	edx, ebx
	mov	edi, dword [ebp + 8]
	movzx	ebx, byte [ebp - 13]
LBB83_30:
	lea	eax, [edx - 91]
	cmp	eax, -26
	jb	LBB83_32
	add	edx, 32
LBB83_32:
	movzx	ecx, byte [esi]
	lea	eax, [ecx - 91]
	cmp	eax, -26
	jb	LBB83_34
	add	ecx, 32
LBB83_34:
	cmp	edx, ecx
	je	LBB83_51
	xor	edx, edx
	test	bl, bl
	je	LBB83_36
	inc	edi
	mov	esi, L.str.38
align 16
LBB83_38:
	mov	edx, edi
	movzx	ecx, bl
	lea	eax, [ecx - 91]
	cmp	eax, -26
	mov	edi, ecx
	jb	LBB83_40
	lea	edi, [ecx + 32]
LBB83_40:
	movzx	ebx, byte [esi]
	lea	eax, [ebx - 91]
	cmp	eax, -26
	jb	LBB83_42
	add	ebx, 32
LBB83_42:
	cmp	edi, ebx
	jne	LBB83_43
	inc	esi
	mov	edi, edx
	movzx	ebx, byte [edx]
	inc	edi
	test	bl, bl
	jne	LBB83_38
	xor	edx, edx
	jmp	LBB83_46
LBB83_36:
	mov	esi, L.str.38
	jmp	LBB83_46
LBB83_43:
	mov	edx, ecx
LBB83_46:
	lea	eax, [edx - 91]
	cmp	eax, -26
	jb	LBB83_48
	add	edx, 32
LBB83_48:
	movzx	eax, byte [esi]
	lea	ecx, [eax - 91]
	cmp	ecx, -26
	jb	LBB83_50
	add	eax, 32
LBB83_50:
	mov	ecx, 38
	cmp	edx, eax
	jne	LBB83_2
LBB83_51:
	xor	eax, eax
LBB83_52:
	add	esp, 4
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
Lfunc_end83:
global fstat
align 16
fstat:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	ecx, dword [ebp + 12]
	test	ecx, ecx
	je	LBB84_1
	mov	ebx, dword [ebp + 8]
	mov	eax, 19
	xor	edx, edx
	int	128
	test	eax, eax
	jns	LBB84_6
	cmp	eax, -1
	mov	ecx, 9
	je	LBB84_5
	neg	eax
	mov	ecx, eax
	jmp	LBB84_5
LBB84_1:
	mov	ecx, 22
LBB84_5:
	mov	dword [errno], ecx
	mov	eax, -1
LBB84_6:
	pop	ebx
	pop	ebp
	ret
Lfunc_end84:
global stat
align 16
stat:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	esi
	mov	esi, dword [ebp + 12]
	mov	ecx, dword [ebp + 8]
	test	ecx, ecx
	sete	al
	test	esi, esi
	sete	dl
	or	dl, al
	mov	edx, 22
	je	LBB85_1
LBB85_4:
	mov	dword [errno], edx
	mov	eax, -1
	jmp	LBB85_5
LBB85_1:
	call	mapped_path
	mov	ebx, eax
	mov	eax, 18
	mov	ecx, esi
	xor	edx, edx
	int	128
	test	eax, eax
	js	LBB85_2
LBB85_5:
	pop	esi
	pop	ebx
	pop	ebp
	ret
LBB85_2:
	cmp	eax, -1
	mov	edx, 2
	je	LBB85_4
	neg	eax
	mov	edx, eax
	jmp	LBB85_4
Lfunc_end85:
global vibe_listdir
align 16
vibe_listdir:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	esi
	mov	ebx, dword [ebp + 8]
	mov	esi, 22
	test	ebx, ebx
	je	LBB86_5
	mov	edx, dword [ebp + 16]
	mov	ecx, dword [ebp + 12]
	test	edx, edx
	setne	al
	test	ecx, ecx
	sete	ah
	test	ah, al
	jne	LBB86_5
	mov	eax, 30
	int	128
	test	eax, eax
	jns	LBB86_6
	cmp	eax, -1
	je	LBB86_5
	neg	eax
	mov	esi, eax
LBB86_5:
	mov	dword [errno], esi
	mov	eax, -1
LBB86_6:
	pop	esi
	pop	ebx
	pop	ebp
	ret
Lfunc_end86:
global vibe_file_size
align 16
vibe_file_size:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	esi
	sub	esp, 44
	mov	esi, dword [ebp + 12]
	mov	ecx, dword [ebp + 8]
	test	ecx, ecx
	setne	al
	test	esi, esi
	setne	dl
	test	al, dl
	je	LBB87_5
	call	mapped_path
	mov	ebx, eax
	lea	ecx, [ebp - 52]
	mov	eax, 18
	xor	edx, edx
	int	128
	test	eax, eax
	js	LBB87_6
	mov	eax, 61440
	and	eax, dword [ebp - 44]
	cmp	eax, 32768
	jne	LBB87_9
	mov	eax, dword [ebp - 24]
	test	eax, eax
	js	LBB87_10
	mov	dword [esi], eax
	xor	eax, eax
	jmp	LBB87_12
LBB87_5:
	mov	dword [errno], 22
	jmp	LBB87_11
LBB87_6:
	cmp	eax, -1
	mov	ecx, 2
	je	LBB87_8
	neg	eax
	mov	ecx, eax
LBB87_8:
	mov	dword [errno], ecx
	jmp	LBB87_11
LBB87_9:
	mov	dword [errno], 21
	jmp	LBB87_11
LBB87_10:
	mov	dword [errno], 75
LBB87_11:
	mov	eax, -1
LBB87_12:
	add	esp, 44
	pop	esi
	pop	ebx
	pop	ebp
	ret
Lfunc_end87:
global vibe_file_read_at
align 16
vibe_file_read_at:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 8
	mov	ecx, dword [ebp + 8]
	test	ecx, ecx
	je	LBB88_18
	mov	edi, dword [ebp + 16]
	cmp	dword [ebp + 20], 0
	sete	al
	test	edi, edi
	setne	dl
	or	dl, al
	je	LBB88_18
	cmp	dword [ebp + 12], 0
	js	LBB88_21
	call	mapped_path
	mov	ebx, eax
	mov	eax, 6
	xor	ecx, ecx
	xor	edx, edx
	int	128
	mov	esi, eax
	test	eax, eax
	js	LBB88_22
	mov	ecx, ebx
	call	is_persist_slot_compat_basename
	test	eax, eax
	je	LBB88_10
	movsx	ebx, byte [ebx + 7]
	cmp	ebx, 48
	jl	LBB88_10
	add	ebx, -48
	cmp	esi, 31
	ja	LBB88_8
	mov	byte [esi + tracked_persist_fd], 1
	mov	byte [esi + tracked_persist_slot], bl
LBB88_8:
	cmp	ebx, 5
	ja	LBB88_10
	shl	ebx, 16
	or	ebx, 536870913
	mov	eax, 15
	xor	ecx, ecx
	xor	edx, edx
	int	128
LBB88_10:
	mov	ecx, esi
	mov	edx, edi
	push	0
	push	dword [ebp + 12]
	push	dword [ebp + 20]
	call	positioned_io
	add	esp, 12
	mov	edi, -1
	cmp	esi, 31
	mov	dword [ebp - 16], eax
	ja	LBB88_13
	cmp	byte [esi + tracked_persist_fd], 0
	je	LBB88_13
	movzx	edi, byte [esi + tracked_persist_slot]
LBB88_13:
	mov	eax, dword [errno]
	mov	dword [ebp - 20], eax
	mov	eax, 12
	mov	ebx, esi
	xor	ecx, ecx
	xor	edx, edx
	int	128
	mov	ecx, eax
	or	ecx, edi
	js	LBB88_24
	cmp	edi, 5
	ja	LBB88_16
	shl	edi, 16
	or	edi, 536870920
	mov	eax, 15
	mov	ebx, edi
	xor	ecx, ecx
	xor	edx, edx
	int	128
LBB88_16:
	cmp	esi, 31
	mov	edx, dword [ebp - 16]
	ja	LBB88_25
	mov	byte [esi + tracked_persist_fd], 0
	mov	byte [esi + tracked_persist_slot], 0
	jmp	LBB88_25
LBB88_18:
	mov	dword [errno], 22
LBB88_19:
	mov	eax, -1
LBB88_20:
	add	esp, 8
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
LBB88_21:
	mov	dword [errno], 75
	jmp	LBB88_19
LBB88_22:
	cmp	esi, -1
	mov	eax, 2
	je	LBB88_32
	neg	esi
	mov	eax, esi
	jmp	LBB88_32
LBB88_24:
	test	eax, eax
	mov	edx, dword [ebp - 16]
	js	LBB88_28
LBB88_25:
	test	edx, edx
	js	LBB88_31
	mov	ecx, dword [ebp + 24]
	xor	eax, eax
	test	ecx, ecx
	je	LBB88_20
	mov	dword [ecx], edx
	jmp	LBB88_20
LBB88_28:
	cmp	eax, -1
	mov	ecx, 9
	je	LBB88_30
	neg	eax
	mov	ecx, eax
LBB88_30:
	mov	dword [errno], ecx
	mov	eax, -1
	test	edx, edx
	jns	LBB88_20
LBB88_31:
	mov	eax, dword [ebp - 20]
LBB88_32:
	mov	dword [errno], eax
	jmp	LBB88_19
Lfunc_end88:
global vibe_file_write_at
align 16
vibe_file_write_at:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 8
	mov	eax, dword [ebp + 8]
	test	eax, eax
	je	LBB89_2
	mov	ebx, dword [ebp + 20]
	mov	esi, dword [ebp + 16]
	test	ebx, ebx
	sete	cl
	test	esi, esi
	setne	dl
	or	dl, cl
	je	LBB89_2
	mov	ecx, dword [ebp + 24]
	test	ecx, ecx
	je	LBB89_5
	mov	dword [ecx], 0
LBB89_5:
	cmp	dword [ebp + 12], 0
	js	LBB89_6
	push	438
	push	258
	push	eax
	call	open
	add	esp, 12
	test	eax, eax
	js	LBB89_24
	mov	edi, eax
	mov	ecx, eax
	mov	edx, esi
	push	1
	push	dword [ebp + 12]
	push	ebx
	call	positioned_io
	add	esp, 12
	mov	esi, -1
	cmp	edi, 31
	mov	dword [ebp - 16], eax
	ja	LBB89_11
	cmp	byte [edi + tracked_persist_fd], 0
	je	LBB89_11
	movzx	esi, byte [edi + tracked_persist_slot]
LBB89_11:
	mov	eax, dword [errno]
	mov	dword [ebp - 20], eax
	mov	eax, 12
	mov	ebx, edi
	xor	ecx, ecx
	xor	edx, edx
	int	128
	mov	ecx, eax
	or	ecx, esi
	js	LBB89_19
	cmp	esi, 5
	ja	LBB89_14
	shl	esi, 16
	or	esi, 536870920
	mov	eax, 15
	mov	ebx, esi
	xor	ecx, ecx
	xor	edx, edx
	int	128
LBB89_14:
	cmp	edi, 31
	mov	edx, dword [ebp - 16]
	ja	LBB89_16
	mov	byte [edi + tracked_persist_fd], 0
	mov	byte [edi + tracked_persist_slot], 0
	jmp	LBB89_16
LBB89_2:
	mov	dword [errno], 22
LBB89_24:
	mov	eax, -1
LBB89_25:
	add	esp, 8
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
LBB89_6:
	mov	dword [errno], 75
	jmp	LBB89_24
LBB89_19:
	test	eax, eax
	mov	edx, dword [ebp - 16]
	js	LBB89_20
LBB89_16:
	test	edx, edx
	js	LBB89_23
	xor	eax, eax
	mov	ecx, dword [ebp + 24]
	test	ecx, ecx
	je	LBB89_25
	mov	dword [ecx], edx
	jmp	LBB89_25
LBB89_20:
	cmp	eax, -1
	mov	ecx, 9
	je	LBB89_22
	neg	eax
	mov	ecx, eax
LBB89_22:
	mov	dword [errno], ecx
	mov	eax, -1
	test	edx, edx
	jns	LBB89_25
LBB89_23:
	mov	eax, dword [ebp - 20]
	mov	dword [errno], eax
	jmp	LBB89_24
Lfunc_end89:
global vibe_file_read_all
align 16
vibe_file_read_all:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 48
	mov	esi, dword [ebp + 8]
	test	esi, esi
	je	LBB90_2
	mov	edi, dword [ebp + 16]
	test	edi, edi
	sete	al
	cmp	dword [ebp + 12], 0
	setne	cl
	or	cl, al
	je	LBB90_2
	mov	ecx, esi
	call	mapped_path
	mov	ebx, eax
	lea	ecx, [ebp - 60]
	mov	eax, 18
	xor	edx, edx
	int	128
	test	eax, eax
	js	LBB90_4
	mov	eax, 61440
	and	eax, dword [ebp - 52]
	mov	ecx, 21
	cmp	eax, 32768
	jne	LBB90_56
	mov	ecx, dword [ebp - 32]
	test	ecx, ecx
	js	LBB90_7
	mov	eax, dword [ebp + 20]
	test	eax, eax
	je	LBB90_10
	mov	dword [eax], ecx
LBB90_10:
	cmp	ecx, edi
	jbe	LBB90_12
	mov	dword [errno], 28
	jmp	LBB90_57
LBB90_2:
	mov	dword [errno], 22
	jmp	LBB90_57
LBB90_4:
	cmp	eax, -1
	mov	ecx, 2
	je	LBB90_56
LBB90_55:
	neg	eax
	mov	ecx, eax
	jmp	LBB90_56
LBB90_7:
	mov	ecx, 75
LBB90_56:
	mov	dword [errno], ecx
LBB90_57:
	mov	eax, -1
LBB90_58:
	add	esp, 48
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
LBB90_12:
	mov	dword [ebp - 16], ecx
	mov	ecx, esi
	call	mapped_path
	mov	ebx, eax
	mov	eax, 6
	xor	ecx, ecx
	xor	edx, edx
	int	128
	mov	edi, eax
	test	eax, eax
	js	LBB90_22
	mov	ecx, ebx
	call	is_persist_slot_compat_basename
	test	eax, eax
	je	LBB90_19
	movsx	ebx, byte [ebx + 7]
	cmp	ebx, 48
	jl	LBB90_19
	add	ebx, -48
	cmp	edi, 31
	ja	LBB90_17
	mov	byte [edi + tracked_persist_fd], 1
	mov	byte [edi + tracked_persist_slot], bl
LBB90_17:
	cmp	ebx, 5
	ja	LBB90_19
	shl	ebx, 16
	or	ebx, 536870913
	mov	eax, 15
	xor	ecx, ecx
	xor	edx, edx
	int	128
LBB90_19:
	mov	edx, dword [ebp - 16]
	test	edx, edx
	mov	eax, dword [ebp + 12]
	je	LBB90_32
	test	eax, eax
	je	LBB90_21
	xor	esi, esi
	jmp	LBB90_26
LBB90_31:
	add	esi, ecx
	mov	edx, dword [ebp - 16]
	cmp	esi, edx
	mov	eax, dword [ebp + 12]
	jae	LBB90_32
LBB90_26:
	sub	edx, esi
	lea	ecx, [eax + esi]
	mov	eax, 7
	mov	ebx, edi
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB90_40
	cmp	edi, 31
	ja	LBB90_31
	cmp	byte [edi + tracked_persist_fd], 0
	je	LBB90_31
	movzx	ebx, byte [edi + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB90_31
	shl	ebx, 16
	or	ebx, 536870914
	mov	eax, 15
	xor	edx, edx
	int	128
	jmp	LBB90_31
LBB90_22:
	cmp	edi, -1
	mov	eax, 2
	je	LBB90_24
	neg	edi
	mov	eax, edi
LBB90_24:
	mov	dword [errno], eax
	jmp	LBB90_57
LBB90_32:
	mov	ebx, edi
	mov	edi, -1
	cmp	ebx, 31
	ja	LBB90_35
	cmp	byte [ebx + tracked_persist_fd], 0
	je	LBB90_35
	movzx	edi, byte [ebx + tracked_persist_slot]
LBB90_35:
	mov	eax, 12
	xor	ecx, ecx
	xor	edx, edx
	int	128
	mov	ecx, eax
	or	ecx, edi
	js	LBB90_53
	mov	esi, ebx
	cmp	edi, 5
	ja	LBB90_38
	shl	edi, 16
	or	edi, 536870920
	mov	eax, 15
	mov	ebx, edi
	xor	ecx, ecx
	xor	edx, edx
	int	128
LBB90_38:
	cmp	esi, 31
	mov	eax, 0
	ja	LBB90_58
	mov	byte [esi + tracked_persist_fd], 0
	mov	byte [esi + tracked_persist_slot], 0
	jmp	LBB90_58
LBB90_53:
	mov	ecx, eax
	test	eax, eax
	mov	eax, 0
	jns	LBB90_58
	mov	eax, ecx
	cmp	ecx, -1
	mov	ecx, 9
	jne	LBB90_55
	jmp	LBB90_56
LBB90_21:
	mov	eax, 22
LBB90_43:
	cmp	edi, 31
	mov	dword [errno], eax
	mov	ebx, edi
	mov	edi, -1
	mov	dword [ebp - 16], eax
	ja	LBB90_46
	cmp	byte [ebx + tracked_persist_fd], 0
	je	LBB90_46
	movzx	edi, byte [ebx + tracked_persist_slot]
LBB90_46:
	mov	eax, 12
	xor	ecx, ecx
	xor	edx, edx
	int	128
	or	eax, edi
	js	LBB90_51
	mov	esi, ebx
	cmp	edi, 5
	ja	LBB90_49
	shl	edi, 16
	or	edi, 536870920
	mov	eax, 15
	mov	ebx, edi
	xor	ecx, ecx
	xor	edx, edx
	int	128
LBB90_49:
	cmp	esi, 31
	ja	LBB90_51
	mov	byte [esi + tracked_persist_fd], 0
	mov	byte [esi + tracked_persist_slot], 0
LBB90_51:
	mov	eax, dword [ebp - 16]
	mov	dword [errno], eax
	jmp	LBB90_57
LBB90_40:
	js	LBB90_41
	push	edi
	call	close
	add	esp, 4
	mov	dword [errno], 5
	jmp	LBB90_57
LBB90_41:
	cmp	ecx, -1
	mov	eax, 5
	je	LBB90_43
	neg	ecx
	mov	eax, ecx
	jmp	LBB90_43
Lfunc_end90:
global vibe_audio_device_start
align 16
vibe_audio_device_start:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	eax, 13
	mov	ebx, 1
	xor	ecx, ecx
	xor	edx, edx
	int	128
	test	eax, eax
	jns	LBB91_4
	cmp	eax, -1
	mov	ecx, 5
	je	LBB91_3
	neg	eax
	mov	ecx, eax
LBB91_3:
	mov	dword [errno], ecx
	mov	eax, -1
LBB91_4:
	pop	ebx
	pop	ebp
	ret
Lfunc_end91:
global vibe_audio_device_shutdown
align 16
vibe_audio_device_shutdown:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	esi
	mov	esi, 5
	mov	eax, 13
	mov	ebx, 5
	xor	ecx, ecx
	xor	edx, edx
	int	128
	test	eax, eax
	jns	LBB92_4
	cmp	eax, -1
	je	LBB92_3
	neg	eax
	mov	esi, eax
LBB92_3:
	mov	dword [errno], esi
	mov	eax, -1
LBB92_4:
	pop	esi
	pop	ebx
	pop	ebp
	ret
Lfunc_end92:
global vibe_audio_mixer_start
align 16
vibe_audio_mixer_start:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	edx, dword [ebp + 12]
	test	edx, edx
	je	LBB93_1
	mov	ecx, dword [ebp + 8]
	mov	eax, 13
	mov	ebx, 2
	int	128
	test	eax, eax
	jns	LBB93_6
	cmp	eax, -1
	mov	ecx, 22
	je	LBB93_5
	neg	eax
	mov	ecx, eax
	jmp	LBB93_5
LBB93_1:
	mov	ecx, 22
LBB93_5:
	mov	dword [errno], ecx
	mov	eax, -1
LBB93_6:
	pop	ebx
	pop	ebp
	ret
Lfunc_end93:
global vibe_audio_mixer_stop
align 16
vibe_audio_mixer_stop:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	ecx, dword [ebp + 8]
	mov	eax, 13
	mov	ebx, 3
	xor	edx, edx
	int	128
	test	eax, eax
	jns	LBB94_4
	cmp	eax, -1
	mov	ecx, 22
	je	LBB94_3
	neg	eax
	mov	ecx, eax
LBB94_3:
	mov	dword [errno], ecx
	mov	eax, -1
LBB94_4:
	pop	ebx
	pop	ebp
	ret
Lfunc_end94:
global vibe_audio_mixer_update
align 16
vibe_audio_mixer_update:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	edx, dword [ebp + 12]
	test	edx, edx
	je	LBB95_1
	mov	ecx, dword [ebp + 8]
	mov	eax, 13
	mov	ebx, 4
	int	128
	test	eax, eax
	jns	LBB95_6
	cmp	eax, -1
	mov	ecx, 22
	je	LBB95_5
	neg	eax
	mov	ecx, eax
	jmp	LBB95_5
LBB95_1:
	mov	ecx, 22
LBB95_5:
	mov	dword [errno], ecx
	mov	eax, -1
LBB95_6:
	pop	ebx
	pop	ebp
	ret
Lfunc_end95:
global vibe_audio_mixer_is_playing
align 16
vibe_audio_mixer_is_playing:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	ecx, dword [ebp + 8]
	mov	eax, 13
	mov	ebx, 6
	xor	edx, edx
	int	128
	test	eax, eax
	jns	LBB96_4
	cmp	eax, -1
	mov	ecx, 22
	je	LBB96_3
	neg	eax
	mov	ecx, eax
LBB96_3:
	mov	dword [errno], ecx
	mov	eax, -1
LBB96_4:
	pop	ebx
	pop	ebp
	ret
Lfunc_end96:
global vibe_audio_pcm_buffered_bytes
align 16
vibe_audio_pcm_buffered_bytes:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	ecx, dword [ebp + 8]
	mov	eax, 13
	mov	ebx, 7
	xor	edx, edx
	int	128
	test	eax, eax
	jns	LBB97_4
	cmp	eax, -1
	mov	ecx, 22
	je	LBB97_3
	neg	eax
	mov	ecx, eax
LBB97_3:
	mov	dword [errno], ecx
	mov	eax, -1
LBB97_4:
	pop	ebx
	pop	ebp
	ret
Lfunc_end97:
global vibe_audio_pcm_pull_state
align 16
vibe_audio_pcm_pull_state:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	ecx, dword [ebp + 8]
	mov	eax, 13
	mov	ebx, 8
	xor	edx, edx
	int	128
	test	eax, eax
	jns	LBB98_4
	cmp	eax, -1
	mov	ecx, 22
	je	LBB98_3
	neg	eax
	mov	ecx, eax
LBB98_3:
	mov	dword [errno], ecx
	mov	eax, -1
LBB98_4:
	pop	ebx
	pop	ebp
	ret
Lfunc_end98:
global vibe_audio_device_info
align 16
vibe_audio_device_info:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	ecx, dword [ebp + 8]
	test	ecx, ecx
	je	LBB99_1
	mov	eax, 13
	mov	ebx, 9
	xor	edx, edx
	int	128
	test	eax, eax
	jns	LBB99_6
	cmp	eax, -1
	mov	ecx, 22
	je	LBB99_5
	neg	eax
	mov	ecx, eax
	jmp	LBB99_5
LBB99_1:
	mov	ecx, 22
LBB99_5:
	mov	dword [errno], ecx
	mov	eax, -1
LBB99_6:
	pop	ebx
	pop	ebp
	ret
Lfunc_end99:
global vibe_audio_pcm_ring_info
align 16
vibe_audio_pcm_ring_info:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	ecx, dword [ebp + 8]
	test	ecx, ecx
	je	LBB100_1
	mov	eax, 13
	mov	ebx, 10
	xor	edx, edx
	int	128
	test	eax, eax
	jns	LBB100_6
	cmp	eax, -1
	mov	ecx, 22
	je	LBB100_5
	neg	eax
	mov	ecx, eax
	jmp	LBB100_5
LBB100_1:
	mov	ecx, 22
LBB100_5:
	mov	dword [errno], ecx
	mov	eax, -1
LBB100_6:
	pop	ebx
	pop	ebp
	ret
Lfunc_end100:
global vibe_audio_stream_info
align 16
vibe_audio_stream_info:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	edx, dword [ebp + 12]
	test	edx, edx
	je	LBB101_1
	mov	ecx, dword [ebp + 8]
	mov	eax, 13
	mov	ebx, 11
	int	128
	test	eax, eax
	jns	LBB101_6
	cmp	eax, -1
	mov	ecx, 22
	je	LBB101_5
	neg	eax
	mov	ecx, eax
	jmp	LBB101_5
LBB101_1:
	mov	ecx, 22
LBB101_5:
	mov	dword [errno], ecx
	mov	eax, -1
LBB101_6:
	pop	ebx
	pop	ebp
	ret
Lfunc_end101:
global vibe_audio_device_info_ioctl
align 16
vibe_audio_device_info_ioctl:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	edx, dword [ebp + 8]
	test	edx, edx
	je	LBB102_1
	mov	eax, 22
	mov	ebx, 16725
	mov	ecx, 16641
	int	128
	test	eax, eax
	jns	LBB102_6
	cmp	eax, -1
	mov	ecx, 25
	je	LBB102_5
	neg	eax
	mov	ecx, eax
	jmp	LBB102_5
LBB102_1:
	mov	ecx, 22
LBB102_5:
	mov	dword [errno], ecx
	mov	eax, -1
LBB102_6:
	pop	ebx
	pop	ebp
	ret
Lfunc_end102:
global ioctl
align 16
ioctl:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	ebx, dword [ebp + 8]
	mov	ecx, dword [ebp + 12]
	mov	edx, dword [ebp + 16]
	mov	eax, 22
	int	128
	test	eax, eax
	jns	LBB103_4
	cmp	eax, -1
	mov	ecx, 25
	je	LBB103_3
	neg	eax
	mov	ecx, eax
LBB103_3:
	mov	dword [errno], ecx
	mov	eax, -1
LBB103_4:
	pop	ebx
	pop	ebp
	ret
Lfunc_end103:
global vibe_audio_pcm_ring_info_ioctl
align 16
vibe_audio_pcm_ring_info_ioctl:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	edx, dword [ebp + 8]
	test	edx, edx
	je	LBB104_1
	mov	eax, 22
	mov	ebx, 16725
	mov	ecx, 16642
	int	128
	test	eax, eax
	jns	LBB104_6
	cmp	eax, -1
	mov	ecx, 25
	je	LBB104_5
	neg	eax
	mov	ecx, eax
	jmp	LBB104_5
LBB104_1:
	mov	ecx, 22
LBB104_5:
	mov	dword [errno], ecx
	mov	eax, -1
LBB104_6:
	pop	ebx
	pop	ebp
	ret
Lfunc_end104:
global vibe_audio_stream_info_ioctl
align 16
vibe_audio_stream_info_ioctl:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	edx, dword [ebp + 12]
	test	edx, edx
	je	LBB105_1
	mov	eax, dword [ebp + 8]
	mov	dword [edx + 8], eax
	mov	eax, 22
	mov	ebx, 16725
	mov	ecx, 16643
	int	128
	test	eax, eax
	jns	LBB105_6
	cmp	eax, -1
	mov	ecx, 25
	je	LBB105_5
	neg	eax
	mov	ecx, eax
	jmp	LBB105_5
LBB105_1:
	mov	ecx, 22
LBB105_5:
	mov	dword [errno], ecx
	mov	eax, -1
LBB105_6:
	pop	ebx
	pop	ebp
	ret
Lfunc_end105:
global vibe_audio_pcm_open
align 16
vibe_audio_pcm_open:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	edx, dword [ebp + 8]
	mov	eax, 13
	mov	ebx, 14
	xor	ecx, ecx
	int	128
	test	eax, eax
	jns	LBB106_4
	cmp	eax, -1
	mov	ecx, 22
	je	LBB106_3
	neg	eax
	mov	ecx, eax
LBB106_3:
	mov	dword [errno], ecx
	mov	eax, -1
LBB106_4:
	pop	ebx
	pop	ebp
	ret
Lfunc_end106:
global vibe_audio_pcm_write
align 16
vibe_audio_pcm_write:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	edx, dword [ebp + 12]
	test	edx, edx
	je	LBB107_1
	mov	ecx, dword [ebp + 8]
	mov	eax, 13
	mov	ebx, 12
	int	128
	test	eax, eax
	jns	LBB107_6
	cmp	eax, -1
	mov	ecx, 22
	je	LBB107_5
	neg	eax
	mov	ecx, eax
	jmp	LBB107_5
LBB107_1:
	mov	ecx, 22
LBB107_5:
	mov	dword [errno], ecx
	mov	eax, -1
LBB107_6:
	pop	ebx
	pop	ebp
	ret
Lfunc_end107:
global vibe_audio_pcm_write_desc
align 16
vibe_audio_pcm_write_desc:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	edx, dword [ebp + 12]
	test	edx, edx
	je	LBB108_1
	mov	ecx, dword [ebp + 8]
	mov	eax, 13
	mov	ebx, 13
	int	128
	test	eax, eax
	jns	LBB108_6
	cmp	eax, -1
	mov	ecx, 22
	je	LBB108_5
	neg	eax
	mov	ecx, eax
	jmp	LBB108_5
LBB108_1:
	mov	ecx, 22
LBB108_5:
	mov	dword [errno], ecx
	mov	eax, -1
LBB108_6:
	pop	ebx
	pop	ebp
	ret
Lfunc_end108:
global vibe_audio_pcm_drain
align 16
vibe_audio_pcm_drain:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	ecx, dword [ebp + 8]
	mov	eax, 13
	mov	ebx, 15
	xor	edx, edx
	int	128
	test	eax, eax
	jns	LBB109_4
	cmp	eax, -1
	mov	ecx, 22
	je	LBB109_3
	neg	eax
	mov	ecx, eax
LBB109_3:
	mov	dword [errno], ecx
	mov	eax, -1
LBB109_4:
	pop	ebx
	pop	ebp
	ret
Lfunc_end109:
global vibe_audio_pcm_close
align 16
vibe_audio_pcm_close:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	ecx, dword [ebp + 8]
	mov	eax, 13
	mov	ebx, 16
	xor	edx, edx
	int	128
	test	eax, eax
	jns	LBB110_4
	cmp	eax, -1
	mov	ecx, 22
	je	LBB110_3
	neg	eax
	mov	ecx, eax
LBB110_3:
	mov	dword [errno], ecx
	mov	eax, -1
LBB110_4:
	pop	ebx
	pop	ebp
	ret
Lfunc_end110:
global vibe_audio_stream_open
align 16
vibe_audio_stream_open:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	edx, dword [ebp + 8]
	mov	eax, 13
	mov	ebx, 14
	xor	ecx, ecx
	int	128
	test	eax, eax
	jns	LBB111_4
	cmp	eax, -1
	mov	ecx, 22
	je	LBB111_3
	neg	eax
	mov	ecx, eax
LBB111_3:
	mov	dword [errno], ecx
	mov	eax, -1
LBB111_4:
	pop	ebx
	pop	ebp
	ret
Lfunc_end111:
global vibe_audio_stream_write
align 16
vibe_audio_stream_write:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	edx, dword [ebp + 12]
	test	edx, edx
	je	LBB112_1
	mov	ecx, dword [ebp + 8]
	mov	eax, 13
	mov	ebx, 12
	int	128
	test	eax, eax
	jns	LBB112_6
	cmp	eax, -1
	mov	ecx, 22
	je	LBB112_5
	neg	eax
	mov	ecx, eax
	jmp	LBB112_5
LBB112_1:
	mov	ecx, 22
LBB112_5:
	mov	dword [errno], ecx
	mov	eax, -1
LBB112_6:
	pop	ebx
	pop	ebp
	ret
Lfunc_end112:
global vibe_audio_stream_drain
align 16
vibe_audio_stream_drain:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	ecx, dword [ebp + 8]
	mov	eax, 13
	mov	ebx, 15
	xor	edx, edx
	int	128
	test	eax, eax
	jns	LBB113_4
	cmp	eax, -1
	mov	ecx, 22
	je	LBB113_3
	neg	eax
	mov	ecx, eax
LBB113_3:
	mov	dword [errno], ecx
	mov	eax, -1
LBB113_4:
	pop	ebx
	pop	ebp
	ret
Lfunc_end113:
global vibe_audio_stream_close
align 16
vibe_audio_stream_close:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	ecx, dword [ebp + 8]
	mov	eax, 13
	mov	ebx, 16
	xor	edx, edx
	int	128
	test	eax, eax
	jns	LBB114_4
	cmp	eax, -1
	mov	ecx, 22
	je	LBB114_3
	neg	eax
	mov	ecx, eax
LBB114_3:
	mov	dword [errno], ecx
	mov	eax, -1
LBB114_4:
	pop	ebx
	pop	ebp
	ret
Lfunc_end114:
global vibe_poll_input
align 16
vibe_poll_input:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	ebx, dword [ebp + 8]
	test	ebx, ebx
	je	LBB115_1
	mov	eax, 28
	mov	ecx, 28
	xor	edx, edx
	int	128
	test	eax, eax
	jns	LBB115_6
	cmp	eax, -1
	mov	ecx, 22
	je	LBB115_5
	neg	eax
	mov	ecx, eax
	jmp	LBB115_5
LBB115_1:
	mov	ecx, 22
LBB115_5:
	mov	dword [errno], ecx
	mov	eax, -1
LBB115_6:
	pop	ebx
	pop	ebp
	ret
Lfunc_end115:
global vibe_drain_input
align 16
vibe_drain_input:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	mov	edi, dword [ebp + 12]
	mov	ebx, dword [ebp + 8]
	test	edi, edi
	setne	al
	test	ebx, ebx
	sete	dl
	mov	ecx, 22
	test	dl, al
	jne	LBB116_8
	test	edi, edi
	je	LBB116_2
	test	ebx, ebx
	je	LBB116_8
	xor	esi, esi
	mov	ecx, 28
	xor	edx, edx
align 16
LBB116_5:
	mov	eax, 28
	int	128
	test	eax, eax
	js	LBB116_6
	je	LBB116_12
	inc	esi
	add	ebx, 28
	cmp	edi, esi
	jne	LBB116_5
	mov	esi, edi
	jmp	LBB116_12
LBB116_2:
	xor	esi, esi
	jmp	LBB116_12
LBB116_6:
	cmp	eax, -1
	mov	ecx, 22
	je	LBB116_8
	neg	eax
	mov	ecx, eax
LBB116_8:
	mov	dword [errno], ecx
	mov	esi, -1
LBB116_12:
	mov	eax, esi
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
Lfunc_end116:
global vibe_input_status
align 16
vibe_input_status:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	ebx, dword [ebp + 8]
	test	ebx, ebx
	je	LBB117_1
	mov	eax, 31
	mov	ecx, 132
	xor	edx, edx
	int	128
	test	eax, eax
	jns	LBB117_6
	cmp	eax, -1
	mov	ecx, 22
	je	LBB117_5
	neg	eax
	mov	ecx, eax
	jmp	LBB117_5
LBB117_1:
	mov	ecx, 22
LBB117_5:
	mov	dword [errno], ecx
	mov	eax, -1
LBB117_6:
	pop	ebx
	pop	ebp
	ret
Lfunc_end117:
global vibe_input_device_status
align 16
vibe_input_device_status:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	ecx, dword [ebp + 12]
	test	ecx, ecx
	je	LBB118_1
	mov	ebx, dword [ebp + 8]
	mov	eax, 39
	mov	edx, 64
	int	128
	test	eax, eax
	jns	LBB118_6
	cmp	eax, -1
	mov	ecx, 22
	je	LBB118_5
	neg	eax
	mov	ecx, eax
	jmp	LBB118_5
LBB118_1:
	mov	ecx, 22
LBB118_5:
	mov	dword [errno], ecx
	mov	eax, -1
LBB118_6:
	pop	ebx
	pop	ebp
	ret
Lfunc_end118:
global vibe_heap_capabilities
align 16
vibe_heap_capabilities:
	push	ebp
	mov	ebp, esp
	mov	eax, 3
	pop	ebp
	ret
Lfunc_end119:
global vibe_vm_capabilities
align 16
vibe_vm_capabilities:
	push	ebp
	mov	ebp, esp
	mov	eax, 65551
	pop	ebp
	ret
Lfunc_end120:
global vibe_mmap_anon
align 16
vibe_mmap_anon:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	ecx, dword [ebp + 8]
	test	ecx, ecx
	je	LBB121_2
	mov	edx, dword [ebp + 12]
	lea	eax, [edx - 1]
	cmp	eax, 7
	jae	LBB121_2
	or	edx, 2228224
	mov	eax, 20
	xor	ebx, ebx
	int	128
	test	eax, eax
	jns	LBB121_8
	cmp	eax, -1
	mov	ecx, 12
	je	LBB121_6
	neg	eax
	mov	ecx, eax
LBB121_6:
	mov	dword [errno], ecx
	jmp	LBB121_7
LBB121_2:
	mov	dword [errno], 22
LBB121_7:
	mov	eax, -1
LBB121_8:
	pop	ebx
	pop	ebp
	ret
Lfunc_end121:
global mmap
align 16
mmap:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	mov	esi, dword [ebp + 12]
	cmp	dword [ebp + 8], 0
	setne	al
	test	esi, esi
	sete	cl
	or	cl, al
	jne	LBB122_2
	mov	edi, dword [ebp + 28]
	mov	eax, dword [ebp + 20]
	test	al, 16
	sete	cl
	test	edi, edi
	setns	dl
	test	cl, dl
	je	LBB122_2
	mov	edx, dword [ebp + 16]
	lea	ecx, [edx - 1]
	cmp	ecx, 7
	setb	cl
	test	eax, -52
	sete	ch
	test	cl, ch
	je	LBB122_2
	mov	ecx, eax
	and	ecx, 3
	cmp	ecx, 2
	jne	LBB122_5
	mov	ecx, dword [ebp + 24]
	cmp	eax, 32
	jae	LBB122_7
	test	ecx, ecx
	js	LBB122_5
	or	edx, 2228224
	mov	eax, 20
	xor	ebx, ebx
	mov	ecx, esi
	int	128
	test	eax, eax
	js	LBB122_9
	mov	ecx, dword [ebp + 24]
	mov	edx, eax
	push	edi
	push	esi
	mov	edi, eax
	call	mmap_copy_file_private
	add	esp, 8
	mov	ecx, eax
	mov	eax, edi
	test	ecx, ecx
	jns	LBB122_17
	mov	edi, dword [errno]
	push	esi
	push	eax
	call	munmap
	add	esp, 8
	mov	dword [errno], edi
	jmp	LBB122_16
LBB122_2:
	mov	dword [errno], 22
LBB122_16:
	mov	eax, -1
LBB122_17:
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
LBB122_7:
	not	ecx
	or	ecx, edi
	je	LBB122_8
LBB122_5:
	mov	dword [errno], 38
	jmp	LBB122_16
LBB122_8:
	or	edx, 2228224
	mov	eax, 20
	xor	ebx, ebx
	mov	ecx, esi
	int	128
	test	eax, eax
	jns	LBB122_17
LBB122_9:
	cmp	eax, -1
	mov	ecx, 12
	je	LBB122_11
	neg	eax
	mov	ecx, eax
LBB122_11:
	mov	dword [errno], ecx
	jmp	LBB122_16
Lfunc_end122:
align 16
mmap_copy_file_private:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 8
	mov	dword [ebp - 20], edx
	mov	dword [ebp - 16], ecx
	mov	esi, dword [ebp + 12]
	xor	esi, 2147483647
	xor	edi, edi
align 16
LBB123_1:
	mov	eax, dword [ebp + 8]
	sub	eax, edi
	jbe	LBB123_7
	cmp	edi, esi
	ja	LBB123_8
	cmp	eax, 2147483647
	jb	LBB123_5
	mov	eax, 2147483647
LBB123_5:
	mov	ecx, dword [ebp - 20]
	lea	edx, [ecx + edi]
	mov	ecx, dword [ebp + 12]
	lea	ebx, [edi + ecx]
	mov	ecx, dword [ebp - 16]
	push	0
	push	ebx
	push	eax
	call	positioned_io
	add	esp, 12
	test	eax, eax
	js	LBB123_9
	add	edi, eax
	test	eax, eax
	jne	LBB123_1
LBB123_7:
	xor	eax, eax
	jmp	LBB123_10
LBB123_8:
	mov	dword [errno], 75
LBB123_9:
	mov	eax, -1
LBB123_10:
	add	esp, 8
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
Lfunc_end123:
global munmap
align 16
munmap:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	ecx, dword [ebp + 12]
	mov	edx, 22
	test	ecx, ecx
	je	LBB124_5
	mov	ebx, dword [ebp + 8]
	lea	eax, [ebx + 1]
	cmp	eax, 2
	jae	LBB124_2
LBB124_5:
	mov	dword [errno], edx
	mov	eax, -1
LBB124_6:
	pop	ebx
	pop	ebp
	ret
LBB124_2:
	mov	eax, 21
	xor	edx, edx
	int	128
	test	eax, eax
	jns	LBB124_6
	cmp	eax, -1
	mov	edx, 22
	je	LBB124_5
	neg	eax
	mov	edx, eax
	jmp	LBB124_5
Lfunc_end124:
global vibe_fb_get_info
align 16
vibe_fb_get_info:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	edx, dword [ebp + 8]
	test	edx, edx
	je	LBB125_1
	mov	eax, 22
	mov	ebx, 1
	mov	ecx, 22017
	int	128
	test	eax, eax
	jns	LBB125_6
	cmp	eax, -1
	mov	ecx, 25
	je	LBB125_5
	neg	eax
	mov	ecx, eax
	jmp	LBB125_5
LBB125_1:
	mov	ecx, 22
LBB125_5:
	mov	dword [errno], ecx
	mov	eax, -1
LBB125_6:
	pop	ebx
	pop	ebp
	ret
Lfunc_end125:
global vibe_fb_can_present_indexed
align 16
vibe_fb_can_present_indexed:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	mov	ecx, dword [ebp + 12]
	xor	eax, eax
	test	ecx, ecx
	je	LBB126_17
	cmp	dword [ecx], 0
	je	LBB126_17
	cmp	dword [ecx + 4], 0
	je	LBB126_17
	mov	edi, dword [ecx + 8]
	test	edi, edi
	je	LBB126_17
	mov	ecx, dword [ecx + 12]
	test	ecx, ecx
	je	LBB126_17
	mov	esi, dword [ebp + 8]
	mov	eax, ecx
	mul	edi
	seto	al
	test	esi, esi
	je	LBB126_6
	test	al, al
	mov	eax, 0
	jne	LBB126_17
	mov	edx, ecx
	imul	edx, edi
	test	edx, edx
	je	LBB126_17
	mov	edx, dword [esi + 68]
	mov	ebx, edx
	not	ebx
	test	bl, 3
	jne	LBB126_17
	cmp	dword [esi + 72], 1
	jne	LBB126_17
	test	dl, 32
	mov	edx, dword [esi + 76]
	jne	LBB126_12
	test	edx, edx
	setne	bl
	cmp	edi, edx
	seta	dl
	test	bl, dl
	jne	LBB126_17
	mov	edx, dword [esi + 80]
	jmp	LBB126_16
LBB126_6:
	xor	eax, eax
LBB126_17:
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
LBB126_12:
	cmp	edi, edx
	jne	LBB126_17
	cmp	ecx, dword [esi + 80]
	mov	edx, ecx
	jne	LBB126_17
LBB126_16:
	test	edx, edx
	sete	al
	cmp	ecx, edx
	setbe	cl
	or	cl, al
	movzx	eax, cl
	jmp	LBB126_17
Lfunc_end126:
global vibe_present_indexed
align 16
vibe_present_indexed:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	edx, dword [ebp + 8]
	mov	ecx, 22
	test	edx, edx
	je	LBB127_8
	cmp	dword [edx], 0
	je	LBB127_8
	cmp	dword [edx + 4], 0
	je	LBB127_8
	cmp	dword [edx + 8], 0
	je	LBB127_8
	cmp	dword [edx + 12], 0
	je	LBB127_8
	mov	eax, 22
	mov	ebx, 1
	mov	ecx, 22018
	int	128
	test	eax, eax
	jns	LBB127_9
	cmp	eax, -1
	mov	ecx, 25
	je	LBB127_8
	neg	eax
	mov	ecx, eax
LBB127_8:
	mov	dword [errno], ecx
	mov	eax, -1
LBB127_9:
	pop	ebx
	pop	ebp
	ret
Lfunc_end127:
global vibe_present_indexed_checked
align 16
vibe_present_indexed_checked:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 88
	mov	esi, dword [ebp + 8]
	mov	edi, 22
	test	esi, esi
	je	LBB128_22
	cmp	dword [esi], 0
	je	LBB128_22
	cmp	dword [esi + 4], 0
	je	LBB128_22
	cmp	dword [esi + 8], 0
	je	LBB128_22
	cmp	dword [esi + 12], 0
	je	LBB128_22
	lea	edx, [ebp - 100]
	mov	eax, 22
	mov	ebx, 1
	mov	ecx, 22017
	int	128
	test	eax, eax
	js	LBB128_20
	mov	ebx, dword [ebp - 32]
	mov	eax, ebx
	not	eax
	test	al, 3
	mov	edi, 38
	jne	LBB128_22
	cmp	dword [ebp - 28], 1
	jne	LBB128_22
	mov	edi, 22
	cmp	dword [esi], 0
	je	LBB128_22
	cmp	dword [esi + 4], 0
	je	LBB128_22
	mov	ecx, dword [esi + 8]
	test	ecx, ecx
	je	LBB128_22
	mov	eax, dword [esi + 12]
	test	eax, eax
	je	LBB128_22
	mov	dword [ebp - 16], eax
	mul	ecx
	jo	LBB128_22
	mov	edx, dword [ebp - 16]
	mov	eax, edx
	imul	eax, ecx
	test	eax, eax
	je	LBB128_22
	test	bl, 32
	mov	eax, dword [ebp - 24]
	jne	LBB128_15
	mov	ebx, edx
	test	eax, eax
	setne	dl
	cmp	ecx, eax
	seta	al
	test	dl, al
	jne	LBB128_22
	mov	eax, dword [ebp - 20]
	test	eax, eax
	setne	cl
	cmp	ebx, eax
	seta	al
	test	cl, al
	je	LBB128_19
	jmp	LBB128_22
LBB128_15:
	cmp	ecx, eax
	jne	LBB128_22
	cmp	edx, dword [ebp - 20]
	jne	LBB128_22
LBB128_19:
	mov	eax, 22
	mov	ebx, 1
	mov	ecx, 22018
	mov	edx, esi
	int	128
	test	eax, eax
	jns	LBB128_23
LBB128_20:
	cmp	eax, -1
	mov	edi, 25
	je	LBB128_22
	neg	eax
	mov	edi, eax
LBB128_22:
	mov	dword [errno], edi
	mov	eax, -1
LBB128_23:
	add	esp, 88
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
Lfunc_end128:
global execv
align 16
execv:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	esi
	mov	ecx, dword [ebp + 8]
	test	ecx, ecx
	je	LBB129_1
	mov	esi, dword [ebp + 12]
	call	mapped_path
	mov	ebx, eax
	mov	eax, 16
	mov	ecx, esi
	xor	edx, edx
	int	128
	test	eax, eax
	jns	LBB129_6
	cmp	eax, -1
	mov	ecx, 2
	je	LBB129_5
	neg	eax
	mov	ecx, eax
	jmp	LBB129_5
LBB129_1:
	mov	ecx, 22
LBB129_5:
	mov	dword [errno], ecx
	mov	eax, -1
LBB129_6:
	pop	esi
	pop	ebx
	pop	ebp
	ret
Lfunc_end129:
global execve
align 16
execve:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	mov	ecx, dword [ebp + 8]
	test	ecx, ecx
	je	LBB130_1
	mov	esi, dword [ebp + 16]
	mov	edi, dword [ebp + 12]
	call	mapped_path
	mov	ebx, eax
	mov	eax, 16
	mov	ecx, edi
	mov	edx, esi
	int	128
	test	eax, eax
	jns	LBB130_6
	cmp	eax, -1
	mov	ecx, 2
	je	LBB130_5
	neg	eax
	mov	ecx, eax
	jmp	LBB130_5
LBB130_1:
	mov	ecx, 22
LBB130_5:
	mov	dword [errno], ecx
	mov	eax, -1
LBB130_6:
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
Lfunc_end130:
global execl
align 16
execl:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	esi
	sub	esp, 36
	mov	ecx, dword [ebp + 8]
	test	ecx, ecx
	mov	edx, 22
	je	LBB131_20
	mov	esi, dword [ebp + 12]
	lea	eax, [ebp + 16]
	mov	dword [ebp - 12], eax
	test	esi, esi
	je	LBB131_2
	mov	eax, dword [ebp - 12]
	mov	dword [ebp - 44], esi
	lea	esi, [eax + 4]
	mov	dword [ebp - 12], esi
	mov	esi, dword [eax]
	test	esi, esi
	je	LBB131_4
	mov	dword [ebp - 40], esi
	lea	esi, [eax + 8]
	mov	dword [ebp - 12], esi
	mov	esi, dword [eax + 4]
	test	esi, esi
	je	LBB131_6
	mov	dword [ebp - 36], esi
	lea	esi, [eax + 12]
	mov	dword [ebp - 12], esi
	mov	esi, dword [eax + 8]
	test	esi, esi
	je	LBB131_8
	mov	dword [ebp - 32], esi
	lea	esi, [eax + 16]
	mov	dword [ebp - 12], esi
	mov	esi, dword [eax + 12]
	test	esi, esi
	je	LBB131_10
	mov	dword [ebp - 28], esi
	lea	esi, [eax + 20]
	mov	dword [ebp - 12], esi
	mov	esi, dword [eax + 16]
	test	esi, esi
	je	LBB131_12
	mov	dword [ebp - 24], esi
	lea	esi, [eax + 24]
	mov	dword [ebp - 12], esi
	mov	esi, dword [eax + 20]
	test	esi, esi
	je	LBB131_14
	mov	dword [ebp - 20], esi
	lea	esi, [eax + 28]
	mov	dword [ebp - 12], esi
	cmp	dword [eax + 24], 0
	jne	LBB131_20
	lea	eax, [ebp - 16]
	jmp	LBB131_17
LBB131_2:
	lea	eax, [ebp - 44]
	jmp	LBB131_17
LBB131_4:
	lea	eax, [ebp - 40]
	jmp	LBB131_17
LBB131_6:
	lea	eax, [ebp - 36]
	jmp	LBB131_17
LBB131_8:
	lea	eax, [ebp - 32]
	jmp	LBB131_17
LBB131_10:
	lea	eax, [ebp - 28]
	jmp	LBB131_17
LBB131_12:
	lea	eax, [ebp - 24]
	jmp	LBB131_17
LBB131_14:
	lea	eax, [ebp - 20]
LBB131_17:
	mov	dword [eax], 0
	call	mapped_path
	mov	ebx, eax
	lea	ecx, [ebp - 44]
	mov	eax, 16
	xor	edx, edx
	int	128
	test	eax, eax
	jns	LBB131_21
	cmp	eax, -1
	mov	edx, 2
	je	LBB131_20
	neg	eax
	mov	edx, eax
LBB131_20:
	mov	dword [errno], edx
	mov	eax, -1
LBB131_21:
	add	esp, 36
	pop	esi
	pop	ebx
	pop	ebp
	ret
Lfunc_end131:
global getpid
align 16
getpid:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	eax, 25
	xor	ebx, ebx
	xor	ecx, ecx
	xor	edx, edx
	int	128
	test	eax, eax
	jns	LBB132_4
	cmp	eax, -1
	mov	ecx, 38
	je	LBB132_3
	neg	eax
	mov	ecx, eax
LBB132_3:
	mov	dword [errno], ecx
	mov	eax, -1
LBB132_4:
	pop	ebx
	pop	ebp
	ret
Lfunc_end132:
global fork
align 16
fork:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	eax, 23
	xor	ebx, ebx
	xor	ecx, ecx
	xor	edx, edx
	int	128
	test	eax, eax
	jns	LBB133_4
	cmp	eax, -1
	mov	ecx, 38
	je	LBB133_3
	neg	eax
	mov	ecx, eax
LBB133_3:
	mov	dword [errno], ecx
	mov	eax, -1
LBB133_4:
	pop	ebx
	pop	ebp
	ret
Lfunc_end133:
global waitpid
align 16
waitpid:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	ebx, dword [ebp + 8]
	mov	ecx, dword [ebp + 12]
	mov	edx, dword [ebp + 16]
	mov	eax, 24
	int	128
	test	eax, eax
	jns	LBB134_4
	cmp	eax, -1
	mov	ecx, 10
	je	LBB134_3
	neg	eax
	mov	ecx, eax
LBB134_3:
	mov	dword [errno], ecx
	mov	eax, -1
LBB134_4:
	pop	ebx
	pop	ebp
	ret
Lfunc_end134:
global wait
align 16
$wait:
	push	ebp
	mov	ebp, esp
	push	ebx
	mov	ecx, dword [ebp + 8]
	mov	eax, 24
	mov	ebx, -1
	xor	edx, edx
	int	128
	test	eax, eax
	jns	LBB135_4
	cmp	eax, -1
	mov	ecx, 10
	je	LBB135_3
	neg	eax
	mov	ecx, eax
LBB135_3:
	mov	dword [errno], ecx
	mov	eax, -1
LBB135_4:
	pop	ebx
	pop	ebp
	ret
Lfunc_end135:
global fopen
align 16
fopen:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 12
	mov	ecx, dword [ebp + 12]
	test	ecx, ecx
	je	LBB136_22
	movzx	eax, byte [ecx]
	test	eax, eax
	je	LBB136_22
	mov	dword [ebp - 20], 0
	mov	dword [ebp - 16], 0
	mov	dword [ebp - 24], 0
	cmp	eax, 97
	je	LBB136_7
	cmp	eax, 114
	je	LBB136_6
	cmp	eax, 119
	jne	LBB136_22
	lea	edx, [ebp - 16]
	mov	eax, 769
	jmp	LBB136_8
LBB136_6:
	lea	edx, [ebp - 20]
	xor	eax, eax
	jmp	LBB136_8
LBB136_7:
	mov	dword [ebp - 16], 1
	lea	edx, [ebp - 24]
	mov	eax, 1281
LBB136_8:
	mov	dword [edx], 1
	movzx	edx, byte [ecx + 1]
	test	edx, edx
	je	LBB136_25
	cmp	edx, 43
	je	LBB136_14
	cmp	edx, 98
	jne	LBB136_22
	movzx	edx, byte [ecx + 2]
	test	edx, edx
	je	LBB136_25
	cmp	edx, 43
	je	LBB136_42
	cmp	edx, 98
	jmp	LBB136_22
LBB136_14:
	mov	esi, 1
	mov	bl, 1
LBB136_15:
	movzx	edi, byte [ecx + esi + 1]
	test	edi, edi
	mov	edx, 1
	je	LBB136_25
	cmp	edi, 43
	je	LBB136_22
	cmp	edi, 98
	jne	LBB136_22
	test	bl, bl
	je	LBB136_22
	movzx	ecx, byte [ecx + esi + 2]
	test	ecx, ecx
	je	LBB136_25
	cmp	ecx, 98
	je	LBB136_22
	cmp	ecx, 43
LBB136_22:
	mov	dword [errno], 22
LBB136_23:
	xor	eax, eax
LBB136_24:
	add	esp, 12
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
LBB136_25:
	mov	ecx, dword [ebp + 8]
	test	edx, edx
	je	LBB136_27
	and	eax, 1792
	or	eax, 2
	mov	dword [ebp - 20], 1
	mov	dword [ebp - 16], 1
LBB136_27:
	push	438
	push	eax
	push	ecx
	call	open
	add	esp, 12
	test	eax, eax
	js	LBB136_23
	mov	esi, eax
	cmp	dword [file_pool+12], 0
	je	LBB136_41
	cmp	dword [file_pool+4148], 0
	je	LBB136_43
	cmp	dword [file_pool+8284], 0
	je	LBB136_44
	cmp	dword [file_pool+12420], 0
	je	LBB136_45
	mov	dword [errno], 24
	mov	edi, -1
	cmp	esi, 31
	ja	LBB136_35
	cmp	byte [esi + tracked_persist_fd], 0
	je	LBB136_35
	movzx	edi, byte [esi + tracked_persist_slot]
LBB136_35:
	mov	eax, 12
	mov	ebx, esi
	xor	ecx, ecx
	xor	edx, edx
	int	128
	mov	ecx, eax
	or	ecx, edi
	js	LBB136_52
	cmp	edi, 5
	ja	LBB136_38
	shl	edi, 16
	or	edi, 536870920
	mov	eax, 15
	mov	ebx, edi
	xor	ecx, ecx
	xor	edx, edx
	int	128
LBB136_38:
	cmp	esi, 31
	ja	LBB136_23
	mov	byte [esi + tracked_persist_fd], 0
	mov	byte [esi + tracked_persist_slot], 0
	jmp	LBB136_23
LBB136_41:
	mov	eax, file_pool
	jmp	LBB136_46
LBB136_42:
	xor	ebx, ebx
	mov	esi, 2
	jmp	LBB136_15
LBB136_43:
	mov	eax, file_pool+4136
	jmp	LBB136_46
LBB136_44:
	mov	eax, file_pool+8272
	jmp	LBB136_46
LBB136_45:
	mov	eax, file_pool+12408
LBB136_46:
	mov	dword [eax + 12], 1
	mov	dword [eax], esi
	mov	dword [eax + 4], 0
	mov	dword [eax + 8], 0
	mov	ecx, dword [ebp - 20]
	mov	dword [eax + 16], ecx
	mov	ecx, dword [ebp - 16]
	mov	dword [eax + 20], ecx
	mov	ecx, dword [ebp - 24]
	mov	dword [eax + 24], ecx
	mov	dword [eax + 28], 0
	mov	dword [eax + 32], 0
	mov	byte [eax + 36], 0
	test	ecx, ecx
	je	LBB136_24
	mov	edi, eax
	mov	eax, 8
	mov	ebx, esi
	xor	ecx, ecx
	mov	edx, 2
	int	128
	test	eax, eax
	js	LBB136_49
	mov	eax, edi
	jmp	LBB136_24
LBB136_49:
	cmp	eax, -1
	mov	ecx, 22
	je	LBB136_51
	neg	eax
	mov	ecx, eax
LBB136_51:
	mov	dword [errno], ecx
	mov	eax, edi
	jmp	LBB136_24
LBB136_52:
	test	eax, eax
	jns	LBB136_23
	mov	ecx, eax
	cmp	eax, -1
	mov	edx, 9
	mov	eax, 0
	je	LBB136_57
	mov	edx, ecx
	neg	edx
LBB136_57:
	mov	dword [errno], edx
	jmp	LBB136_24
Lfunc_end136:
global fread
align 16
fread:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 8
	mov	edi, dword [ebp + 12]
	test	edi, edi
	sete	cl
	cmp	dword [ebp + 16], 0
	sete	dl
	xor	eax, eax
	or	dl, cl
	jne	LBB137_14
	mov	ebx, dword [ebp + 20]
	mov	esi, dword [ebp + 8]
	test	esi, esi
	sete	cl
	test	ebx, ebx
	sete	dl
	or	dl, cl
	jne	LBB137_7
	mov	ecx, dword [ebx + 12]
	test	ecx, ecx
	je	LBB137_6
	cmp	dword [ebx + 16], 0
	je	LBB137_6
	mov	eax, edi
	mov	esi, dword [ebp + 16]
	mul	esi
	jno	LBB137_15
	mov	dword [errno], 75
	xor	eax, eax
LBB137_6:
	mov	dword [ebx + 8], 1
	test	ecx, ecx
	jne	LBB137_10
	jmp	LBB137_12
LBB137_7:
	test	ebx, ebx
	je	LBB137_11
	test	esi, esi
	mov	dword [ebx + 8], 1
	je	LBB137_13
	mov	ecx, dword [ebx + 12]
	test	ecx, ecx
	je	LBB137_12
LBB137_10:
	cmp	dword [ebx + 16], 0
	jne	LBB137_14
	jmp	LBB137_12
LBB137_11:
	test	esi, esi
	je	LBB137_13
LBB137_12:
	mov	dword [errno], 9
	jmp	LBB137_14
LBB137_13:
	mov	dword [errno], 22
LBB137_14:
	add	esp, 8
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
LBB137_15:
	mov	edx, dword [ebx + 28]
	test	edx, edx
	je	LBB137_29
	mov	eax, dword [ebx]
	lea	ecx, [ebx + 37]
	mov	dword [ebp - 20], ecx
	xor	esi, esi
	mov	dword [ebp - 16], eax
	jmp	LBB137_18
align 16
LBB137_17:
	add	esi, ecx
	mov	edx, edi
	cmp	esi, edi
	jae	LBB137_28
LBB137_18:
	mov	edi, edx
	sub	edx, esi
	mov	ecx, dword [ebp - 20]
	add	ecx, esi
	mov	ebx, eax
	mov	eax, 4
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB137_23
	cmp	ebx, 31
	mov	eax, ebx
	ja	LBB137_17
	cmp	byte [eax + tracked_persist_fd], 0
	je	LBB137_17
	movzx	ebx, byte [eax + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB137_17
	shl	ebx, 16
	or	ebx, 536870916
	mov	eax, 15
	xor	edx, edx
	int	128
	mov	eax, dword [ebp - 16]
	jmp	LBB137_17
LBB137_23:
	mov	edx, dword [ebp + 20]
	jns	LBB137_27
	cmp	ecx, -1
	mov	eax, 5
	je	LBB137_26
	neg	ecx
	mov	eax, ecx
LBB137_26:
	mov	dword [errno], eax
LBB137_27:
	mov	dword [edx + 8], 1
	xor	eax, eax
	jmp	LBB137_14
LBB137_28:
	mov	ebx, dword [ebp + 20]
	mov	dword [ebx + 28], 0
	mov	edi, dword [ebp + 12]
	mov	esi, dword [ebp + 16]
LBB137_29:
	imul	esi, edi
	cmp	dword [ebx + 32], 0
	je	LBB137_31
	movzx	eax, byte [ebx + 36]
	mov	ecx, dword [ebp + 8]
	mov	byte [ecx], al
	mov	dword [ebx + 32], 0
	mov	dword [ebx + 4], 0
	mov	edi, 1
	jmp	LBB137_32
LBB137_31:
	xor	edi, edi
LBB137_32:
	mov	ecx, esi
	sub	ecx, edi
	mov	eax, dword [ebp + 16]
	je	LBB137_14
	mov	eax, dword [ebp + 8]
	add	eax, edi
	push	ecx
	push	eax
	push	dword [ebx]
	call	read
	add	esp, 12
	test	eax, eax
	js	LBB137_37
	je	LBB137_38
	add	eax, edi
	cmp	eax, esi
	jae	LBB137_40
	mov	dword [ebx + 4], 1
	jmp	LBB137_40
LBB137_37:
	mov	dword [ebx + 8], 1
	jmp	LBB137_39
LBB137_38:
	mov	dword [ebx + 4], 1
LBB137_39:
	mov	eax, edi
LBB137_40:
	xor	edx, edx
	div	dword [ebp + 12]
	jmp	LBB137_14
Lfunc_end137:
global fwrite
align 16
fwrite:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	mov	eax, dword [ebp + 16]
	mov	edi, dword [ebp + 12]
	test	edi, edi
	sete	cl
	test	eax, eax
	sete	dl
	or	dl, cl
	jne	LBB138_15
	mov	esi, dword [ebp + 20]
	test	esi, esi
	je	LBB138_7
	cmp	dword [esi + 12], 0
	je	LBB138_6
	cmp	dword [esi + 20], 0
	je	LBB138_6
	mov	ecx, eax
	mov	eax, edi
	mul	ecx
	jno	LBB138_8
	mov	dword [errno], 75
	jmp	LBB138_14
LBB138_6:
	mov	dword [esi + 8], 1
LBB138_7:
	mov	dword [errno], 9
LBB138_15:
	xor	eax, eax
LBB138_16:
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
LBB138_8:
	mov	edx, dword [ebp + 8]
	imul	edi, dword [ebp + 16]
	cmp	dword [esi + 24], 0
	je	LBB138_13
	mov	ebx, dword [esi]
	mov	eax, 8
	xor	ecx, ecx
	mov	edx, 2
	int	128
	mov	edx, dword [ebp + 8]
	test	eax, eax
	jns	LBB138_13
	cmp	eax, -1
	mov	ecx, 22
	je	LBB138_12
	neg	eax
	mov	ecx, eax
LBB138_12:
	mov	dword [errno], ecx
LBB138_13:
	mov	ecx, esi
	push	edi
	call	stream_write
	add	esp, 4
	test	eax, eax
	mov	eax, dword [ebp + 16]
	jns	LBB138_16
LBB138_14:
	mov	dword [esi + 8], 1
	jmp	LBB138_15
Lfunc_end138:
align 16
stream_write:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 16
	mov	ebx, edx
	mov	edx, dword [ebp + 8]
	test	edx, edx
	je	LBB139_53
	mov	edi, dword [ecx]
	lea	eax, [edi - 1]
	cmp	eax, 1
	mov	dword [ebp - 24], ebx
	ja	LBB139_9
	test	ebx, ebx
	je	LBB139_46
	xor	esi, esi
	jmp	LBB139_5
align 16
LBB139_4:
	add	esi, ecx
	mov	edx, dword [ebp + 8]
	cmp	esi, edx
	mov	ebx, dword [ebp - 24]
	jae	LBB139_53
LBB139_5:
	sub	edx, esi
	lea	ecx, [ebx + esi]
	mov	eax, 4
	mov	ebx, edi
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB139_42
	cmp	byte [edi + tracked_persist_fd], 0
	je	LBB139_4
	movzx	ebx, byte [edi + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB139_4
	shl	ebx, 16
	or	ebx, 536870916
	mov	eax, 15
	xor	edx, edx
	int	128
	jmp	LBB139_4
LBB139_9:
	cmp	edx, 4097
	mov	eax, dword [ecx + 28]
	mov	dword [ebp - 20], eax
	jb	LBB139_18
	test	eax, eax
	je	LBB139_34
	mov	dword [ebp - 16], ecx
	add	ecx, 37
	mov	dword [ebp - 28], ecx
	xor	esi, esi
	jmp	LBB139_13
align 16
LBB139_12:
	add	esi, ecx
	mov	eax, dword [ebp - 20]
	cmp	esi, eax
	jae	LBB139_33
LBB139_13:
	mov	edx, eax
	sub	edx, esi
	mov	eax, dword [ebp - 28]
	lea	ecx, [eax + esi]
	mov	eax, 4
	mov	ebx, edi
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB139_28
	cmp	edi, 31
	ja	LBB139_12
	cmp	byte [edi + tracked_persist_fd], 0
	je	LBB139_12
	movzx	ebx, byte [edi + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB139_12
	shl	ebx, 16
	or	ebx, 536870916
	mov	eax, 15
	xor	edx, edx
	int	128
	jmp	LBB139_12
LBB139_18:
	add	eax, edx
	cmp	eax, 4097
	jae	LBB139_21
	mov	eax, dword [ebp - 20]
	jmp	LBB139_50
LBB139_21:
	mov	dword [ebp - 16], ecx
	lea	eax, [ecx + 37]
	mov	dword [ebp - 28], eax
	xor	esi, esi
	mov	edx, dword [ebp - 20]
	jmp	LBB139_23
align 16
LBB139_22:
	add	esi, ecx
	mov	edx, dword [ebp - 20]
	cmp	esi, edx
	jae	LBB139_49
LBB139_23:
	sub	edx, esi
	mov	eax, dword [ebp - 28]
	lea	ecx, [eax + esi]
	mov	eax, 4
	mov	ebx, edi
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB139_28
	cmp	edi, 31
	ja	LBB139_22
	cmp	byte [edi + tracked_persist_fd], 0
	je	LBB139_22
	movzx	ebx, byte [edi + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB139_22
	shl	ebx, 16
	or	ebx, 536870916
	mov	eax, 15
	xor	edx, edx
	int	128
	jmp	LBB139_22
LBB139_28:
	mov	edx, dword [ebp - 16]
	jns	LBB139_32
	cmp	ecx, -1
	mov	eax, 5
	je	LBB139_31
	neg	ecx
	mov	eax, ecx
LBB139_31:
	mov	dword [errno], eax
LBB139_32:
	mov	dword [edx + 8], 1
	jmp	LBB139_48
LBB139_33:
	mov	eax, dword [ebp - 16]
	mov	dword [eax + 28], 0
	mov	edi, dword [eax]
	mov	ebx, dword [ebp - 24]
	mov	edx, dword [ebp + 8]
LBB139_34:
	test	ebx, ebx
	je	LBB139_46
	xor	esi, esi
	jmp	LBB139_37
align 16
LBB139_36:
	add	esi, ecx
	mov	edx, dword [ebp + 8]
	cmp	esi, edx
	mov	ebx, dword [ebp - 24]
	jae	LBB139_53
LBB139_37:
	sub	edx, esi
	lea	ecx, [ebx + esi]
	mov	eax, 4
	mov	ebx, edi
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB139_42
	cmp	edi, 31
	ja	LBB139_36
	cmp	byte [edi + tracked_persist_fd], 0
	je	LBB139_36
	movzx	ebx, byte [edi + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB139_36
	shl	ebx, 16
	or	ebx, 536870916
	mov	eax, 15
	xor	edx, edx
	int	128
	jmp	LBB139_36
LBB139_46:
	mov	eax, 22
LBB139_47:
	mov	dword [errno], eax
LBB139_48:
	mov	eax, -1
	jmp	LBB139_54
LBB139_42:
	mov	eax, -1
	jns	LBB139_54
	cmp	ecx, -1
	mov	eax, 5
	je	LBB139_47
	neg	ecx
	mov	eax, ecx
	jmp	LBB139_47
LBB139_49:
	mov	ecx, dword [ebp - 16]
	mov	dword [ecx + 28], 0
	xor	eax, eax
	mov	ebx, dword [ebp - 24]
LBB139_50:
	lea	eax, [ecx + eax + 37]
	xor	esi, esi
align 16
LBB139_51:
	movzx	edx, byte [ebx + esi]
	mov	byte [eax + esi], dl
	mov	edx, dword [ebp + 8]
	inc	esi
	cmp	edx, esi
	jne	LBB139_51
	add	dword [ecx + 28], edx
LBB139_53:
	xor	eax, eax
LBB139_54:
	add	esp, 16
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
Lfunc_end139:
global fseek
align 16
fseek:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 8
	mov	edi, dword [ebp + 8]
	test	edi, edi
	je	LBB140_10
	cmp	dword [edi + 12], 0
	je	LBB140_10
	mov	edx, dword [edi + 28]
	test	edx, edx
	je	LBB140_17
	mov	eax, dword [edi]
	lea	ecx, [edi + 37]
	mov	dword [ebp - 20], ecx
	xor	edi, edi
	mov	dword [ebp - 16], eax
	jmp	LBB140_5
align 16
LBB140_4:
	add	edi, ecx
	mov	edx, esi
	cmp	edi, esi
	jae	LBB140_16
LBB140_5:
	mov	esi, edx
	sub	edx, edi
	mov	ecx, dword [ebp - 20]
	add	ecx, edi
	mov	ebx, eax
	mov	eax, 4
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB140_11
	cmp	ebx, 31
	mov	eax, ebx
	ja	LBB140_4
	cmp	byte [eax + tracked_persist_fd], 0
	je	LBB140_4
	movzx	ebx, byte [eax + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB140_4
	shl	ebx, 16
	or	ebx, 536870916
	mov	eax, 15
	xor	edx, edx
	int	128
	mov	eax, dword [ebp - 16]
	jmp	LBB140_4
LBB140_10:
	mov	dword [errno], 9
LBB140_22:
	mov	eax, -1
LBB140_23:
	add	esp, 8
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
LBB140_11:
	mov	edx, dword [ebp + 8]
	jns	LBB140_15
	cmp	ecx, -1
	mov	eax, 5
	je	LBB140_14
	neg	ecx
	mov	eax, ecx
LBB140_14:
	mov	dword [errno], eax
LBB140_15:
	mov	dword [edx + 8], 1
	jmp	LBB140_22
LBB140_16:
	mov	edi, dword [ebp + 8]
	mov	dword [edi + 28], 0
LBB140_17:
	mov	edx, dword [ebp + 16]
	mov	ecx, dword [ebp + 12]
	cmp	dword [edi + 32], 0
	setne	al
	cmp	edx, 1
	sete	ah
	and	ah, al
	movzx	eax, ah
	sub	ecx, eax
	mov	ebx, dword [edi]
	mov	eax, 8
	int	128
	test	eax, eax
	js	LBB140_19
	mov	dword [edi + 4], 0
	mov	dword [edi + 32], 0
	xor	eax, eax
	jmp	LBB140_23
LBB140_19:
	cmp	eax, -1
	mov	ecx, 22
	je	LBB140_21
	neg	eax
	mov	ecx, eax
LBB140_21:
	mov	dword [errno], ecx
	mov	dword [edi + 8], 1
	jmp	LBB140_22
Lfunc_end140:
global ftell
align 16
ftell:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	esi
	mov	esi, dword [ebp + 8]
	test	esi, esi
	je	LBB141_4
	cmp	dword [esi + 12], 0
	je	LBB141_4
	mov	ebx, dword [esi]
	mov	eax, 8
	xor	ecx, ecx
	mov	edx, 1
	int	128
	test	eax, eax
	js	LBB141_7
	add	eax, dword [esi + 28]
	cmp	dword [esi + 32], 1
	adc	eax, -1
	jmp	LBB141_6
LBB141_4:
	mov	dword [errno], 9
LBB141_5:
	mov	eax, -1
LBB141_6:
	pop	esi
	pop	ebx
	pop	ebp
	ret
LBB141_7:
	cmp	eax, -1
	mov	ecx, 22
	je	LBB141_9
	neg	eax
	mov	ecx, eax
LBB141_9:
	mov	dword [errno], ecx
	mov	dword [esi + 8], 1
	jmp	LBB141_5
Lfunc_end141:
global rewind
align 16
rewind:
	push	ebp
	mov	ebp, esp
	push	esi
	mov	esi, dword [ebp + 8]
	push	0
	push	0
	push	esi
	call	fseek
	add	esp, 12
	test	esi, esi
	je	LBB142_2
	mov	dword [esi + 4], 0
	mov	dword [esi + 8], 0
LBB142_2:
	pop	esi
	pop	ebp
	ret
Lfunc_end142:
global clearerr
align 16
clearerr:
	push	ebp
	mov	ebp, esp
	mov	eax, dword [ebp + 8]
	test	eax, eax
	je	LBB143_2
	mov	dword [eax + 4], 0
	mov	dword [eax + 8], 0
LBB143_2:
	pop	ebp
	ret
Lfunc_end143:
global fclose
align 16
fclose:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 8
	mov	edx, dword [ebp + 8]
	test	edx, edx
	je	LBB144_2
	cmp	dword [edx + 12], 0
	je	LBB144_2
	mov	eax, dword [edx + 28]
	test	eax, eax
	je	LBB144_12
	mov	ecx, dword [edx]
	mov	dword [ebp - 16], ecx
	lea	ecx, [edx + 37]
	mov	dword [ebp - 20], ecx
	xor	edi, edi
	jmp	LBB144_5
align 16
LBB144_10:
	add	edi, ecx
	mov	eax, esi
	cmp	edi, esi
	jae	LBB144_11
LBB144_5:
	mov	esi, eax
	mov	edx, eax
	sub	edx, edi
	mov	eax, dword [ebp - 20]
	lea	ecx, [eax + edi]
	mov	eax, 4
	mov	ebx, dword [ebp - 16]
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB144_13
	cmp	ebx, 31
	ja	LBB144_10
	cmp	byte [ebx + tracked_persist_fd], 0
	je	LBB144_10
	movzx	ebx, byte [ebx + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB144_10
	shl	ebx, 16
	or	ebx, 536870916
	mov	eax, 15
	xor	edx, edx
	int	128
	jmp	LBB144_10
LBB144_2:
	mov	dword [errno], 9
	mov	ecx, -1
	jmp	LBB144_31
LBB144_13:
	mov	edx, dword [ebp + 8]
	jns	LBB144_17
	cmp	ecx, -1
	mov	eax, 5
	je	LBB144_16
	neg	ecx
	mov	eax, ecx
LBB144_16:
	mov	dword [errno], eax
LBB144_17:
	mov	dword [edx + 8], 1
	mov	dword [ebp - 16], -1
	jmp	LBB144_18
LBB144_11:
	mov	edx, dword [ebp + 8]
	mov	dword [edx + 28], 0
LBB144_12:
	mov	dword [ebp - 16], 0
LBB144_18:
	mov	edi, dword [edx]
	mov	esi, -1
	cmp	edi, 31
	ja	LBB144_21
	cmp	byte [edi + tracked_persist_fd], 0
	je	LBB144_21
	movzx	esi, byte [edi + tracked_persist_slot]
LBB144_21:
	mov	eax, 12
	mov	ebx, edi
	xor	ecx, ecx
	xor	edx, edx
	int	128
	mov	ecx, eax
	or	ecx, esi
	js	LBB144_26
	cmp	esi, 5
	ja	LBB144_24
	shl	esi, 16
	or	esi, 536870920
	mov	eax, 15
	mov	ebx, esi
	xor	ecx, ecx
	xor	edx, edx
	int	128
LBB144_24:
	cmp	edi, 31
	mov	edx, dword [ebp + 8]
	mov	ecx, dword [ebp - 16]
	ja	LBB144_30
	mov	byte [edi + tracked_persist_fd], 0
	mov	byte [edi + tracked_persist_slot], 0
	jmp	LBB144_30
LBB144_26:
	test	eax, eax
	mov	edx, dword [ebp + 8]
	mov	ecx, dword [ebp - 16]
	jns	LBB144_30
	cmp	eax, -1
	mov	ecx, 9
	je	LBB144_29
	neg	eax
	mov	ecx, eax
LBB144_29:
	mov	dword [errno], ecx
	mov	ecx, -1
LBB144_30:
	mov	dword [edx], -1
	mov	dword [edx + 4], 1
	mov	eax, ecx
	shr	eax, 31
	mov	dword [edx + 8], eax
	mov	dword [edx + 12], 0
	mov	dword [edx + 16], 0
	mov	dword [edx + 20], 0
	mov	dword [edx + 24], 0
	mov	dword [edx + 28], 0
	mov	dword [edx + 32], 0
LBB144_31:
	mov	eax, ecx
	add	esp, 8
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
Lfunc_end144:
global fflush
align 16
fflush:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 20
	mov	eax, dword [ebp + 8]
	test	eax, eax
	je	LBB145_1
	cmp	dword [eax + 12], 0
	je	LBB145_51
	mov	edx, dword [eax + 28]
	test	edx, edx
	je	LBB145_61
	mov	ecx, dword [eax]
	mov	dword [ebp - 28], ecx
	add	eax, 37
	mov	dword [ebp - 24], eax
	xor	edi, edi
	jmp	LBB145_54
align 16
LBB145_59:
	add	edi, ecx
	mov	edx, esi
	cmp	edi, esi
	jae	LBB145_60
LBB145_54:
	mov	esi, edx
	sub	edx, edi
	mov	eax, dword [ebp - 24]
	lea	ecx, [eax + edi]
	mov	eax, 4
	mov	ebx, dword [ebp - 28]
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB145_62
	cmp	ebx, 31
	ja	LBB145_59
	cmp	byte [ebx + tracked_persist_fd], 0
	je	LBB145_59
	movzx	ebx, byte [ebx + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB145_59
	shl	ebx, 16
	or	ebx, 536870916
	mov	eax, 15
	xor	edx, edx
	int	128
	jmp	LBB145_59
LBB145_1:
	mov	eax, dword [stdout]
	mov	dword [ebp - 16], 0
	test	eax, eax
	je	LBB145_16
	mov	edx, dword [eax + 28]
	test	edx, edx
	je	LBB145_16
	mov	ecx, dword [eax]
	mov	dword [ebp - 28], ecx
	mov	dword [ebp - 20], eax
	add	eax, 37
	mov	dword [ebp - 24], eax
	xor	edi, edi
	jmp	LBB145_4
align 16
LBB145_9:
	add	edi, ecx
	mov	edx, esi
	cmp	edi, esi
	jae	LBB145_10
LBB145_4:
	mov	esi, edx
	sub	edx, edi
	mov	eax, dword [ebp - 24]
	lea	ecx, [eax + edi]
	mov	eax, 4
	mov	ebx, dword [ebp - 28]
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB145_11
	cmp	ebx, 31
	ja	LBB145_9
	cmp	byte [ebx + tracked_persist_fd], 0
	je	LBB145_9
	movzx	ebx, byte [ebx + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB145_9
	shl	ebx, 16
	or	ebx, 536870916
	mov	eax, 15
	xor	edx, edx
	int	128
	jmp	LBB145_9
LBB145_51:
	mov	dword [errno], 9
	jmp	LBB145_67
LBB145_62:
	jns	LBB145_66
	cmp	ecx, -1
	mov	eax, 5
	je	LBB145_65
	neg	ecx
	mov	eax, ecx
LBB145_65:
	mov	dword [errno], eax
LBB145_66:
	mov	eax, dword [ebp + 8]
	mov	dword [eax + 8], 1
LBB145_67:
	mov	dword [ebp - 16], -1
	jmp	LBB145_68
LBB145_60:
	mov	eax, dword [ebp + 8]
	mov	dword [eax + 28], 0
LBB145_61:
	mov	dword [ebp - 16], 0
LBB145_68:
	mov	eax, dword [ebp - 16]
	add	esp, 20
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
LBB145_11:
	jns	LBB145_15
	cmp	ecx, -1
	mov	eax, 5
	je	LBB145_14
	neg	ecx
	mov	eax, ecx
LBB145_14:
	mov	dword [errno], eax
LBB145_15:
	mov	eax, dword [ebp - 20]
	mov	dword [eax + 8], 1
	mov	dword [ebp - 16], -1
	jmp	LBB145_16
LBB145_10:
	mov	eax, dword [ebp - 20]
	mov	dword [eax + 28], 0
	mov	dword [ebp - 16], 0
LBB145_16:
	mov	eax, dword [stderr]
	test	eax, eax
	je	LBB145_31
	mov	edx, dword [eax + 28]
	test	edx, edx
	je	LBB145_31
	mov	ecx, dword [eax]
	mov	dword [ebp - 28], ecx
	mov	dword [ebp - 20], eax
	add	eax, 37
	mov	dword [ebp - 24], eax
	xor	esi, esi
	jmp	LBB145_19
align 16
LBB145_24:
	add	esi, ecx
	mov	edx, edi
	cmp	esi, edi
	jae	LBB145_25
LBB145_19:
	mov	edi, edx
	sub	edx, esi
	mov	eax, dword [ebp - 24]
	lea	ecx, [eax + esi]
	mov	eax, 4
	mov	ebx, dword [ebp - 28]
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB145_26
	cmp	ebx, 31
	ja	LBB145_24
	cmp	byte [ebx + tracked_persist_fd], 0
	je	LBB145_24
	movzx	ebx, byte [ebx + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB145_24
	shl	ebx, 16
	or	ebx, 536870916
	mov	eax, 15
	xor	edx, edx
	int	128
	jmp	LBB145_24
LBB145_26:
	jns	LBB145_30
	cmp	ecx, -1
	mov	eax, 5
	je	LBB145_29
	neg	ecx
	mov	eax, ecx
LBB145_29:
	mov	dword [errno], eax
LBB145_30:
	mov	eax, dword [ebp - 20]
	mov	dword [eax + 8], 1
	mov	dword [ebp - 16], -1
	jmp	LBB145_31
LBB145_25:
	mov	eax, dword [ebp - 20]
	mov	dword [eax + 28], 0
LBB145_31:
	xor	ecx, ecx
	jmp	LBB145_32
LBB145_42:
	mov	eax, dword [ebp - 32]
	mov	dword [eax + 28], 0
LBB145_48:
	mov	ecx, dword [ebp - 20]
LBB145_49:
	inc	ecx
	cmp	ecx, 4
	je	LBB145_68
LBB145_32:
	imul	eax, ecx, 4136
	cmp	dword [eax + file_pool+12], 0
	je	LBB145_49
	lea	eax, [eax + file_pool]
	cmp	dword [eax + 20], 0
	je	LBB145_49
	mov	edx, dword [eax + 28]
	test	edx, edx
	je	LBB145_49
	mov	dword [ebp - 20], ecx
	mov	ecx, dword [eax]
	mov	dword [ebp - 28], ecx
	mov	dword [ebp - 32], eax
	add	eax, 37
	mov	dword [ebp - 24], eax
	xor	esi, esi
	jmp	LBB145_36
align 16
LBB145_41:
	add	esi, ecx
	mov	edx, edi
	cmp	esi, edi
	jae	LBB145_42
LBB145_36:
	mov	edi, edx
	sub	edx, esi
	mov	eax, dword [ebp - 24]
	lea	ecx, [eax + esi]
	mov	eax, 4
	mov	ebx, dword [ebp - 28]
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB145_43
	cmp	ebx, 31
	ja	LBB145_41
	cmp	byte [ebx + tracked_persist_fd], 0
	je	LBB145_41
	movzx	ebx, byte [ebx + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB145_41
	shl	ebx, 16
	or	ebx, 536870916
	mov	eax, 15
	xor	edx, edx
	int	128
	jmp	LBB145_41
LBB145_43:
	jns	LBB145_47
	cmp	ecx, -1
	mov	eax, 5
	je	LBB145_46
	neg	ecx
	mov	eax, ecx
LBB145_46:
	mov	dword [errno], eax
LBB145_47:
	mov	eax, dword [ebp - 32]
	mov	dword [eax + 8], 1
	mov	dword [ebp - 16], -1
	jmp	LBB145_48
Lfunc_end145:
global feof
align 16
feof:
	push	ebp
	mov	ebp, esp
	mov	eax, dword [ebp + 8]
	test	eax, eax
	je	LBB146_1
	mov	eax, dword [eax + 4]
	pop	ebp
	ret
LBB146_1:
	xor	eax, eax
	pop	ebp
	ret
Lfunc_end146:
global ferror
align 16
ferror:
	push	ebp
	mov	ebp, esp
	mov	eax, dword [ebp + 8]
	test	eax, eax
	je	LBB147_1
	mov	eax, dword [eax + 8]
	pop	ebp
	ret
LBB147_1:
	xor	eax, eax
	pop	ebp
	ret
Lfunc_end147:
global setbuf
align 16
setbuf:
	push	ebp
	mov	ebp, esp
	pop	ebp
	ret
Lfunc_end148:
global getchar
align 16
getchar:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	esi
	sub	esp, 1
	mov	esi, dword [stdin]
	test	esi, esi
	je	LBB149_4
	cmp	dword [esi + 12], 0
	je	LBB149_3
	cmp	dword [esi + 16], 0
	je	LBB149_3
	cmp	dword [esi + 32], 0
	je	LBB149_7
	mov	dword [esi + 32], 0
	movzx	eax, byte [esi + 36]
	jmp	LBB149_20
LBB149_3:
	mov	dword [esi + 8], 1
LBB149_4:
	mov	dword [errno], 9
LBB149_19:
	mov	eax, -1
LBB149_20:
	add	esp, 1
	pop	esi
	pop	ebx
	pop	ebp
	ret
LBB149_7:
	mov	ebx, dword [esi]
	lea	ecx, [ebp - 9]
	mov	eax, 7
	mov	edx, 1
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB149_14
	cmp	ebx, 31
	ja	LBB149_12
	cmp	byte [ebx + tracked_persist_fd], 0
	je	LBB149_12
	movzx	ebx, byte [ebx + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB149_12
	shl	ebx, 16
	or	ebx, 536870914
	mov	eax, 15
	xor	edx, edx
	int	128
LBB149_12:
	cmp	ecx, 1
	jne	LBB149_18
	movzx	eax, byte [ebp - 9]
	jmp	LBB149_20
LBB149_14:
	js	LBB149_15
	mov	dword [esi + 4], 1
	jmp	LBB149_19
LBB149_15:
	cmp	ecx, -1
	mov	eax, 5
	je	LBB149_17
	neg	ecx
	mov	eax, ecx
LBB149_17:
	mov	dword [errno], eax
LBB149_18:
	mov	dword [esi + 8], 1
	jmp	LBB149_19
Lfunc_end149:
global fgetc
align 16
fgetc:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	esi
	push	eax
	mov	esi, dword [ebp + 8]
	test	esi, esi
	je	LBB150_4
	cmp	dword [esi + 12], 0
	je	LBB150_3
	cmp	dword [esi + 16], 0
	je	LBB150_3
	cmp	dword [esi + 32], 0
	je	LBB150_7
	mov	dword [esi + 32], 0
	movzx	eax, byte [esi + 36]
	jmp	LBB150_20
LBB150_3:
	mov	dword [esi + 8], 1
LBB150_4:
	mov	dword [errno], 9
LBB150_19:
	mov	eax, -1
LBB150_20:
	add	esp, 4
	pop	esi
	pop	ebx
	pop	ebp
	ret
LBB150_7:
	mov	ebx, dword [esi]
	lea	ecx, [ebp - 9]
	mov	eax, 7
	mov	edx, 1
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB150_14
	cmp	ebx, 31
	ja	LBB150_12
	cmp	byte [ebx + tracked_persist_fd], 0
	je	LBB150_12
	movzx	ebx, byte [ebx + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB150_12
	shl	ebx, 16
	or	ebx, 536870914
	mov	eax, 15
	xor	edx, edx
	int	128
LBB150_12:
	cmp	ecx, 1
	jne	LBB150_18
	movzx	eax, byte [ebp - 9]
	jmp	LBB150_20
LBB150_14:
	js	LBB150_15
	mov	dword [esi + 4], 1
	jmp	LBB150_19
LBB150_15:
	cmp	ecx, -1
	mov	eax, 5
	je	LBB150_17
	neg	ecx
	mov	eax, ecx
LBB150_17:
	mov	dword [errno], eax
LBB150_18:
	mov	dword [esi + 8], 1
	jmp	LBB150_19
Lfunc_end150:
global vsnprintf
align 16
vsnprintf:
	push	ebp
	mov	ebp, esp
	mov	edx, dword [ebp + 12]
	mov	ecx, dword [ebp + 8]
	xor	eax, eax
	cmp	ecx, 1
	setae	al
	lea	eax, [eax + eax - 1]
	push	dword [ebp + 20]
	push	dword [ebp + 16]
	push	eax
	call	format_to
	add	esp, 12
	pop	ebp
	ret
Lfunc_end151:
align 16
format_to:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 72
	mov	dword [ebp - 36], ecx
	mov	dword [ebp - 84], edx
	mov	dword [ebp - 28], edx
	test	ecx, ecx
	mov	dword [ebp - 52], ecx
	mov	dword [ebp - 48], ecx
	je	LBB152_2
	lea	eax, [ebp - 36]
	mov	dword [ebp - 48], eax
LBB152_2:
	mov	eax, dword [ebp + 16]
	mov	dword [ebp - 20], eax
	mov	esi, dword [ebp + 12]
	xor	edi, edi
	mov	ebx, 10249
	jmp	LBB152_5
LBB152_3:
	cmp	ecx, 1
	mov	ebx, 10249
	jne	LBB152_223
LBB152_4:
	inc	edi
	inc	esi
LBB152_5:
	movzx	eax, byte [esi]
	cmp	eax, 37
	je	LBB152_10
	test	eax, eax
	je	LBB152_209
	cmp	dword [ebp - 52], 0
	mov	byte [ebp - 13], al
	je	LBB152_30
	mov	ecx, dword [ebp - 28]
	cmp	ecx, 2
	jb	LBB152_4
	mov	edx, dword [ebp - 36]
	mov	byte [edx], al
	inc	edx
	mov	dword [ebp - 36], edx
	mov	ebx, 10249
	dec	ecx
	mov	dword [ebp - 28], ecx
	inc	edi
	inc	esi
	jmp	LBB152_5
align 16
LBB152_10:
	mov	dword [ebp - 40], edi
	add	esi, 2
	xor	edi, edi
	jmp	LBB152_12
align 16
LBB152_11:
	inc	esi
	mov	edi, eax
LBB152_12:
	movzx	ecx, byte [esi - 1]
	mov	eax, ecx
	add	eax, -32
	cmp	eax, 16
	ja	LBB152_18
	bt	ebx, eax
	jae	LBB152_16
	cmp	cl, 45
	mov	eax, 1
	je	LBB152_11
	mov	eax, edi
	jmp	LBB152_11
align 16
LBB152_16:
	cmp	eax, 16
	jne	LBB152_18
	movzx	ecx, byte [esi]
	mov	dword [ebp - 32], 1
	jmp	LBB152_19
align 16
LBB152_18:
	dec	esi
	mov	dword [ebp - 32], 0
LBB152_19:
	xor	ebx, ebx
	cmp	cl, 42
	jne	LBB152_23
	mov	eax, dword [ebp - 20]
	mov	eax, dword [eax]
	mov	ecx, eax
	sar	ecx, 31
	mov	ebx, eax
	xor	ebx, ecx
	test	eax, eax
	mov	eax, 1
	js	LBB152_22
	mov	eax, edi
LBB152_22:
	add	dword [ebp - 20], 4
	sub	ebx, ecx
	movzx	ecx, byte [esi + 1]
	inc	esi
	mov	edi, eax
LBB152_23:
	mov	eax, ecx
	add	al, -58
	cmp	al, -10
	jb	LBB152_25
align 16
LBB152_24:
	lea	eax, [ebx + 4*ebx]
	movzx	ecx, cl
	lea	ebx, [ecx + 2*eax - 48]
	movzx	ecx, byte [esi + 1]
	inc	esi
	mov	eax, ecx
	add	al, -58
	cmp	al, -11
	ja	LBB152_24
LBB152_25:
	mov	dword [ebp - 44], ebx
	mov	ebx, -1
	cmp	cl, 46
	jne	LBB152_39
	movzx	ecx, byte [esi + 1]
	cmp	cl, 42
	jne	LBB152_36
	mov	eax, dword [ebp - 20]
	mov	ebx, dword [eax]
	test	ebx, ebx
	jns	LBB152_29
	mov	ebx, -1
LBB152_29:
	add	dword [ebp - 20], 4
	movzx	ecx, byte [esi + 2]
	add	esi, 2
	jmp	LBB152_37
LBB152_30:
	cmp	dword [ebp + 8], 0
	js	LBB152_4
	mov	eax, 4
	mov	ebx, dword [ebp + 8]
	lea	ecx, [ebp - 13]
	mov	edx, 1
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB152_219
	cmp	ebx, 31
	ja	LBB152_3
	cmp	byte [ebx + tracked_persist_fd], 0
	je	LBB152_3
	movzx	ebx, byte [ebx + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB152_3
	shl	ebx, 16
	or	ebx, 536870916
	mov	eax, 15
	xor	edx, edx
	int	128
	jmp	LBB152_3
LBB152_36:
	inc	esi
	xor	ebx, ebx
LBB152_37:
	mov	eax, ecx
	add	al, -58
	cmp	al, -10
	jb	LBB152_39
align 16
LBB152_38:
	lea	eax, [ebx + 4*ebx]
	movzx	ecx, cl
	lea	ebx, [ecx + 2*eax - 48]
	movzx	ecx, byte [esi + 1]
	inc	esi
	mov	eax, ecx
	add	al, -58
	cmp	al, -11
	ja	LBB152_38
LBB152_39:
	cmp	cl, 122
	je	LBB152_46
	movzx	eax, cl
	cmp	eax, 108
	je	LBB152_44
	cmp	eax, 104
	jne	LBB152_47
	cmp	byte [esi + 1], 104
	je	LBB152_49
	inc	esi
	jmp	LBB152_50
LBB152_44:
	cmp	byte [esi + 1], 108
	sete	al
	mov	dword [ebp - 24], eax
	je	LBB152_48
	inc	esi
	xor	eax, eax
	jmp	LBB152_52
LBB152_46:
	inc	esi
	mov	al, 1
	jmp	LBB152_51
LBB152_47:
	xor	eax, eax
	mov	dword [ebp - 24], 0
	test	edi, edi
	jne	LBB152_53
	jmp	LBB152_54
LBB152_48:
	add	esi, 2
	xor	eax, eax
	jmp	LBB152_52
LBB152_49:
	add	esi, 2
LBB152_50:
	xor	eax, eax
LBB152_51:
	mov	dword [ebp - 24], 0
LBB152_52:
	movzx	ecx, byte [esi]
	test	edi, edi
	je	LBB152_54
LBB152_53:
	mov	dword [ebp - 32], 0
LBB152_54:
	movzx	edx, cl
	add	edx, -37
	cmp	edx, 83
	ja	LBB152_217
	jmp	dword [4*edx + LJTI152_0]
LBB152_56:
	movsx	eax, cl
	mov	ecx, dword [ebp - 48]
	lea	edx, [ebp - 28]
	push	eax
	push	dword [ebp + 8]
	call	unsupported_format
	add	esp, 8
	test	eax, eax
	js	LBB152_223
	add	dword [ebp - 20], 8
	jmp	LBB152_118
LBB152_58:
	test	al, al
	mov	ecx, dword [ebp - 20]
	jne	LBB152_61
	cmp	byte [ebp - 24], 0
	je	LBB152_61
	mov	eax, dword [ecx]
	add	ecx, 8
	jmp	LBB152_62
LBB152_61:
	mov	eax, dword [ecx]
	add	ecx, 4
LBB152_62:
	mov	dword [ebp - 20], ecx
	mov	ecx, eax
	shr	ecx, 31
	mov	dword [ebp - 24], ecx
	mov	ecx, eax
	sar	ecx, 31
	xor	eax, ecx
	sub	eax, ecx
	mov	ecx, dword [ebp - 48]
	lea	edx, [ebp - 28]
	push	edi
	push	0
	push	dword [ebp - 24]
	jmp	LBB152_109
LBB152_63:
	mov	ecx, dword [ebp - 48]
	lea	edx, [ebp - 28]
	push	edi
	push	0
	push	0
	push	dword [ebp - 32]
	push	ebx
	push	dword [ebp - 44]
	push	16
	mov	edi, dword [ebp - 20]
	push	dword [edi]
	push	dword [ebp + 8]
	call	out_unsigned
	add	esp, 36
	test	eax, eax
	js	LBB152_223
	add	edi, 4
	mov	dword [ebp - 20], edi
	jmp	LBB152_118
LBB152_65:
	test	al, al
	mov	ecx, dword [ebp - 20]
	jne	LBB152_107
	cmp	byte [ebp - 24], 0
	je	LBB152_107
	mov	eax, dword [ecx]
	add	ecx, 8
	jmp	LBB152_108
LBB152_68:
	test	edi, edi
	je	LBB152_119
	mov	eax, dword [ebp + 8]
	mov	ebx, 10249
	jmp	LBB152_180
LBB152_70:
	mov	dword [ebp - 72], edi
	mov	dword [ebp - 24], ebx
	mov	eax, dword [ebp - 20]
	mov	eax, dword [eax]
	test	eax, eax
	mov	dword [ebp - 32], L.str.39
	je	LBB152_72
	mov	dword [ebp - 32], eax
LBB152_72:
	mov	edx, -1
	xor	ecx, ecx
align 16
LBB152_73:
	mov	ebx, ecx
	lea	eax, [edx + 1]
	cmp	dword [ebp - 24], eax
	jbe	LBB152_75
	lea	ecx, [ebx + 1]
	mov	edi, dword [ebp - 32]
	cmp	byte [edi + edx + 1], 0
	mov	edx, eax
	jne	LBB152_73
LBB152_75:
	mov	dword [ebp - 60], ebx
	mov	edi, dword [ebp - 44]
	mov	ecx, edi
	sub	ecx, eax
	mov	dword [ebp - 68], ecx
	jg	LBB152_77
	mov	edi, eax
LBB152_77:
	mov	dword [ebp - 64], eax
	sub	edi, eax
	xor	ecx, ecx
	cmp	dword [ebp - 72], 0
	mov	eax, dword [ebp + 8]
	mov	ebx, 10249
	mov	dword [ebp - 80], edi
	jne	LBB152_144
	test	edi, edi
	jle	LBB152_144
	mov	edi, dword [ebp - 44]
	mov	edx, dword [ebp - 60]
	cmp	edi, edx
	jg	LBB152_81
	mov	edi, edx
LBB152_81:
	mov	eax, dword [ebp - 28]
	mov	dword [ebp - 24], eax
	mov	ecx, dword [ebp - 36]
	mov	dword [ebp - 56], ecx
	sub	edi, edx
	mov	edx, dword [ebp + 8]
	jmp	LBB152_84
align 16
LBB152_82:
	cmp	ecx, 1
	mov	ebx, 10249
	jne	LBB152_223
LBB152_83:
	dec	edi
	je	LBB152_143
LBB152_84:
	cmp	dword [ebp - 52], 0
	mov	byte [ebp - 13], 32
	je	LBB152_87
	mov	eax, dword [ebp - 24]
	cmp	eax, 2
	jb	LBB152_83
	mov	ecx, dword [ebp - 56]
	mov	byte [ecx], 32
	inc	ecx
	mov	dword [ebp - 56], ecx
	dec	eax
	mov	dword [ebp - 24], eax
	jmp	LBB152_83
align 16
LBB152_87:
	test	edx, edx
	js	LBB152_83
	mov	ebx, edx
	mov	eax, 4
	lea	ecx, [ebp - 13]
	mov	edx, 1
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB152_219
	cmp	ebx, 31
	mov	edx, ebx
	ja	LBB152_82
	cmp	byte [edx + tracked_persist_fd], 0
	je	LBB152_82
	movzx	ebx, byte [edx + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB152_82
	shl	ebx, 16
	or	ebx, 536870916
	mov	eax, 15
	xor	edx, edx
	int	128
	mov	edx, dword [ebp + 8]
	jmp	LBB152_82
LBB152_93:
	mov	ecx, dword [ebp - 48]
	lea	edx, [ebp - 28]
	push	110
	push	dword [ebp + 8]
	call	unsupported_format
	add	esp, 8
	test	eax, eax
	js	LBB152_223
	add	dword [ebp - 20], 4
	jmp	LBB152_118
LBB152_95:
	cmp	dword [ebp - 52], 0
	mov	byte [ebp - 13], 37
	je	LBB152_135
	mov	eax, dword [ebp - 28]
	cmp	eax, 2
	mov	edi, dword [ebp - 40]
	mov	ebx, 10249
	jb	LBB152_142
	mov	ecx, dword [ebp - 36]
	mov	byte [ecx], 37
	inc	ecx
	mov	dword [ebp - 36], ecx
	dec	eax
	mov	dword [ebp - 28], eax
	inc	edi
	inc	esi
	jmp	LBB152_5
LBB152_217:
	movsx	eax, cl
	mov	ecx, dword [ebp - 48]
	lea	edx, [ebp - 28]
	push	eax
	push	dword [ebp + 8]
	call	unsupported_format
	add	esp, 8
	test	eax, eax
	jns	LBB152_118
	jmp	LBB152_223
LBB152_98:
	test	al, al
	mov	ecx, dword [ebp - 20]
	jne	LBB152_110
	cmp	byte [ebp - 24], 0
	je	LBB152_110
	mov	eax, dword [ecx]
	add	ecx, 8
	jmp	LBB152_111
LBB152_101:
	test	al, al
	mov	ecx, dword [ebp - 20]
	jne	LBB152_113
	cmp	byte [ebp - 24], 0
	je	LBB152_113
	mov	eax, dword [ecx]
	add	ecx, 8
	jmp	LBB152_114
LBB152_104:
	test	al, al
	mov	ecx, dword [ebp - 20]
	jne	LBB152_115
	cmp	byte [ebp - 24], 0
	je	LBB152_115
	mov	eax, dword [ecx]
	add	ecx, 8
	jmp	LBB152_116
LBB152_107:
	mov	eax, dword [ecx]
	add	ecx, 4
LBB152_108:
	mov	dword [ebp - 20], ecx
	mov	ecx, dword [ebp - 48]
	lea	edx, [ebp - 28]
	push	edi
	push	0
	push	0
LBB152_109:
	push	dword [ebp - 32]
	push	ebx
	push	dword [ebp - 44]
	push	10
	jmp	LBB152_117
LBB152_110:
	mov	eax, dword [ecx]
	add	ecx, 4
LBB152_111:
	mov	dword [ebp - 20], ecx
	mov	ecx, dword [ebp - 48]
	lea	edx, [ebp - 28]
	push	edi
	push	1
	jmp	LBB152_112
LBB152_113:
	mov	eax, dword [ecx]
	add	ecx, 4
LBB152_114:
	mov	dword [ebp - 20], ecx
	mov	ecx, dword [ebp - 48]
	lea	edx, [ebp - 28]
	push	edi
	push	0
LBB152_112:
	push	0
	push	dword [ebp - 32]
	push	ebx
	push	dword [ebp - 44]
	push	16
	jmp	LBB152_117
LBB152_115:
	mov	eax, dword [ecx]
	add	ecx, 4
LBB152_116:
	mov	dword [ebp - 20], ecx
	mov	ecx, dword [ebp - 48]
	lea	edx, [ebp - 28]
	push	edi
	push	0
	push	0
	push	dword [ebp - 32]
	push	ebx
	push	dword [ebp - 44]
	push	8
LBB152_117:
	push	eax
	push	dword [ebp + 8]
	call	out_unsigned
	add	esp, 36
	test	eax, eax
	js	LBB152_223
LBB152_118:
	mov	edi, dword [ebp - 40]
	add	edi, eax
	mov	ebx, 10249
	inc	esi
	jmp	LBB152_5
LBB152_119:
	mov	ecx, dword [ebp - 44]
	cmp	ecx, 2
	mov	eax, dword [ebp + 8]
	jge	LBB152_121
	mov	ecx, 1
LBB152_121:
	dec	ecx
	mov	ebx, 10249
	je	LBB152_179
	mov	edx, dword [ebp - 28]
	mov	dword [ebp - 32], edx
	mov	edx, dword [ebp - 36]
	mov	dword [ebp - 24], edx
	mov	dword [ebp - 56], ecx
	jmp	LBB152_125
align 16
LBB152_123:
	mov	ecx, eax
	mov	eax, dword [ebp + 8]
LBB152_124:
	dec	ecx
	je	LBB152_178
LBB152_125:
	cmp	dword [ebp - 52], 0
	mov	byte [ebp - 13], 32
	je	LBB152_128
	mov	eax, ecx
	mov	ecx, dword [ebp - 32]
	cmp	ecx, 2
	jb	LBB152_123
	mov	edx, dword [ebp - 24]
	mov	byte [edx], 32
	inc	edx
	mov	dword [ebp - 24], edx
	dec	ecx
	mov	dword [ebp - 32], ecx
	jmp	LBB152_123
align 16
LBB152_128:
	test	eax, eax
	js	LBB152_124
	mov	dword [ebp - 60], ecx
	mov	ebx, eax
	mov	eax, 4
	lea	ecx, [ebp - 13]
	mov	edx, 1
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB152_219
	cmp	ebx, 31
	mov	eax, ebx
	ja	LBB152_134
	cmp	byte [eax + tracked_persist_fd], 0
	je	LBB152_134
	movzx	ebx, byte [eax + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB152_134
	shl	ebx, 16
	or	ebx, 536870916
	mov	eax, 15
	xor	edx, edx
	int	128
	mov	eax, dword [ebp + 8]
align 16
LBB152_134:
	cmp	ecx, 1
	mov	ebx, 10249
	mov	ecx, dword [ebp - 60]
	je	LBB152_124
	jmp	LBB152_223
LBB152_135:
	cmp	dword [ebp + 8], 0
	mov	edi, dword [ebp - 40]
	mov	ebx, 10249
	js	LBB152_142
	mov	eax, 4
	mov	ebx, dword [ebp + 8]
	lea	ecx, [ebp - 13]
	mov	edx, 1
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB152_219
	cmp	ebx, 31
	ja	LBB152_141
	cmp	byte [ebx + tracked_persist_fd], 0
	je	LBB152_141
	movzx	ebx, byte [ebx + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB152_141
	shl	ebx, 16
	or	ebx, 536870916
	mov	eax, 15
	xor	edx, edx
	int	128
LBB152_141:
	cmp	ecx, 1
	mov	ebx, 10249
	jne	LBB152_223
LBB152_142:
	inc	edi
	inc	esi
	jmp	LBB152_5
LBB152_143:
	mov	eax, dword [ebp - 24]
	mov	dword [ebp - 28], eax
	mov	eax, edx
	mov	ecx, dword [ebp - 56]
	mov	dword [ebp - 36], ecx
	mov	ecx, dword [ebp - 68]
	test	ecx, ecx
	js	LBB152_223
LBB152_144:
	mov	dword [ebp - 76], ecx
	cmp	dword [ebp - 64], 0
	mov	ecx, dword [ebp - 60]
	je	LBB152_159
	mov	edi, dword [ebp - 28]
	xor	edx, edx
	mov	eax, dword [ebp - 36]
	mov	dword [ebp - 24], eax
	jmp	LBB152_148
align 16
LBB152_146:
	cmp	ecx, 1
	mov	ebx, 10249
	mov	ecx, dword [ebp - 60]
	mov	edx, dword [ebp - 56]
	jne	LBB152_223
LBB152_147:
	inc	edx
	cmp	ecx, edx
	je	LBB152_158
LBB152_148:
	cmp	dword [ebp - 52], 0
	mov	eax, dword [ebp - 32]
	movzx	eax, byte [eax + edx]
	mov	byte [ebp - 13], al
	je	LBB152_151
	cmp	edi, 2
	jb	LBB152_147
	mov	ecx, edx
	mov	edx, edi
	mov	edi, dword [ebp - 24]
	mov	byte [edi], al
	inc	edi
	mov	dword [ebp - 24], edi
	mov	edi, edx
	mov	edx, ecx
	mov	ecx, dword [ebp - 60]
	dec	edi
	jmp	LBB152_147
align 16
LBB152_151:
	mov	ebx, dword [ebp + 8]
	test	ebx, ebx
	js	LBB152_157
	mov	dword [ebp - 56], edx
	mov	eax, 4
	lea	ecx, [ebp - 13]
	mov	edx, 1
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB152_219
	cmp	ebx, 31
	ja	LBB152_146
	cmp	byte [ebx + tracked_persist_fd], 0
	je	LBB152_146
	movzx	ebx, byte [ebx + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB152_146
	shl	ebx, 16
	or	ebx, 536870916
	mov	eax, 15
	xor	edx, edx
	int	128
	jmp	LBB152_146
LBB152_157:
	mov	ebx, 10249
	jmp	LBB152_147
LBB152_158:
	mov	dword [ebp - 28], edi
	mov	eax, dword [ebp - 24]
	mov	dword [ebp - 36], eax
	mov	eax, dword [ebp + 8]
LBB152_159:
	cmp	dword [ebp - 72], 0
	je	LBB152_176
	cmp	dword [ebp - 80], 0
	jle	LBB152_176
	mov	edi, dword [ebp - 44]
	cmp	edi, ecx
	jg	LBB152_163
	mov	edi, ecx
LBB152_163:
	mov	edx, dword [ebp - 28]
	mov	dword [ebp - 32], edx
	mov	edx, dword [ebp - 36]
	sub	edi, ecx
	jmp	LBB152_166
align 16
LBB152_164:
	cmp	ecx, 1
	mov	ebx, 10249
	jne	LBB152_223
LBB152_165:
	dec	edi
	je	LBB152_175
LBB152_166:
	cmp	dword [ebp - 52], 0
	mov	byte [ebp - 13], 32
	je	LBB152_169
	mov	ecx, dword [ebp - 32]
	cmp	ecx, 2
	jb	LBB152_165
	mov	byte [edx], 32
	inc	edx
	dec	ecx
	mov	dword [ebp - 32], ecx
	jmp	LBB152_165
align 16
LBB152_169:
	test	eax, eax
	js	LBB152_165
	mov	dword [ebp - 24], edx
	mov	ebx, eax
	mov	eax, 4
	lea	ecx, [ebp - 13]
	mov	edx, 1
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB152_219
	cmp	ebx, 31
	mov	eax, ebx
	mov	edx, dword [ebp - 24]
	ja	LBB152_164
	cmp	byte [eax + tracked_persist_fd], 0
	je	LBB152_164
	movzx	ebx, byte [eax + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB152_164
	shl	ebx, 16
	or	ebx, 536870916
	mov	eax, 15
	xor	edx, edx
	int	128
	mov	edx, dword [ebp - 24]
	mov	eax, dword [ebp + 8]
	jmp	LBB152_164
LBB152_175:
	mov	eax, dword [ebp - 32]
	mov	dword [ebp - 28], eax
	mov	dword [ebp - 36], edx
	cmp	dword [ebp - 68], 0
	mov	eax, dword [ebp - 44]
	mov	dword [ebp - 64], eax
	js	LBB152_223
LBB152_176:
	mov	eax, dword [ebp - 64]
	add	eax, dword [ebp - 76]
	js	LBB152_223
	add	dword [ebp - 20], 4
	mov	edi, dword [ebp - 40]
	add	edi, eax
	inc	esi
	jmp	LBB152_5
LBB152_178:
	mov	ecx, dword [ebp - 32]
	mov	dword [ebp - 28], ecx
	mov	ecx, dword [ebp - 24]
	mov	dword [ebp - 36], ecx
	mov	ecx, dword [ebp - 56]
LBB152_179:
	add	dword [ebp - 40], ecx
LBB152_180:
	cmp	dword [ebp - 52], 0
	mov	ecx, dword [ebp - 20]
	movzx	ecx, byte [ecx]
	mov	byte [ebp - 13], cl
	je	LBB152_183
	mov	eax, dword [ebp - 28]
	cmp	eax, 2
	jb	LBB152_190
	mov	edx, dword [ebp - 36]
	mov	byte [edx], cl
	inc	edx
	mov	dword [ebp - 36], edx
	dec	eax
	mov	dword [ebp - 28], eax
	jmp	LBB152_190
LBB152_183:
	test	eax, eax
	js	LBB152_190
	mov	eax, 4
	mov	ebx, dword [ebp + 8]
	lea	ecx, [ebp - 13]
	mov	edx, 1
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB152_219
	cmp	ebx, 31
	ja	LBB152_189
	cmp	byte [ebx + tracked_persist_fd], 0
	je	LBB152_189
	movzx	ebx, byte [ebx + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB152_189
	shl	ebx, 16
	or	ebx, 536870916
	mov	eax, 15
	xor	edx, edx
	int	128
LBB152_189:
	cmp	ecx, 1
	mov	ebx, 10249
	jne	LBB152_223
LBB152_190:
	add	dword [ebp - 20], 4
	test	edi, edi
	je	LBB152_206
	mov	edi, dword [ebp - 44]
	cmp	edi, 2
	jge	LBB152_193
	mov	edi, 1
LBB152_193:
	mov	dword [ebp - 44], edi
	dec	edi
	je	LBB152_208
	mov	edx, dword [ebp - 28]
	mov	ecx, dword [ebp - 36]
	mov	eax, dword [ebp + 8]
	jmp	LBB152_197
align 16
LBB152_195:
	cmp	ecx, 1
	mov	ebx, 10249
	mov	ecx, dword [ebp - 32]
	mov	edx, dword [ebp - 24]
	jne	LBB152_223
LBB152_196:
	dec	edi
	je	LBB152_207
LBB152_197:
	cmp	dword [ebp - 52], 0
	mov	byte [ebp - 13], 32
	je	LBB152_200
	cmp	edx, 2
	jb	LBB152_196
	mov	byte [ecx], 32
	inc	ecx
	dec	edx
	jmp	LBB152_196
align 16
LBB152_200:
	test	eax, eax
	js	LBB152_196
	mov	dword [ebp - 24], edx
	mov	dword [ebp - 32], ecx
	mov	ebx, eax
	mov	eax, 4
	lea	ecx, [ebp - 13]
	mov	edx, 1
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB152_219
	cmp	ebx, 31
	mov	eax, ebx
	ja	LBB152_195
	cmp	byte [eax + tracked_persist_fd], 0
	je	LBB152_195
	movzx	ebx, byte [eax + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB152_195
	shl	ebx, 16
	or	ebx, 536870916
	mov	eax, 15
	xor	edx, edx
	int	128
	mov	eax, dword [ebp + 8]
	jmp	LBB152_195
LBB152_206:
	mov	edi, dword [ebp - 40]
	inc	edi
	inc	esi
	jmp	LBB152_5
LBB152_207:
	mov	dword [ebp - 28], edx
	mov	dword [ebp - 36], ecx
LBB152_208:
	mov	edi, dword [ebp - 40]
	add	edi, dword [ebp - 44]
	inc	esi
	jmp	LBB152_5
LBB152_209:
	cmp	dword [ebp - 52], 0
	sete	al
	cmp	dword [ebp - 84], 0
	sete	cl
	or	cl, al
	jne	LBB152_224
	mov	eax, dword [ebp - 36]
	mov	byte [eax], 0
	jmp	LBB152_224
LBB152_219:
	jns	LBB152_223
	cmp	ecx, -1
	mov	eax, 5
	je	LBB152_222
	neg	ecx
	mov	eax, ecx
LBB152_222:
	mov	dword [errno], eax
LBB152_223:
	mov	edi, -1
LBB152_224:
	mov	eax, edi
	add	esp, 72
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
Lfunc_end152:
section .rodata
align 4
LJTI152_0:
dd LBB152_95
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_56
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_56
dd LBB152_56
dd LBB152_56
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_98
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_56
dd LBB152_217
dd LBB152_68
dd LBB152_58
dd LBB152_56
dd LBB152_56
dd LBB152_56
dd LBB152_217
dd LBB152_58
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_217
dd LBB152_93
dd LBB152_104
dd LBB152_63
dd LBB152_217
dd LBB152_217
dd LBB152_70
dd LBB152_217
dd LBB152_65
dd LBB152_217
dd LBB152_217
dd LBB152_101
section .text
global vsprintf
align 16
vsprintf:
	push	ebp
	mov	ebp, esp
	mov	ecx, dword [ebp + 8]
	xor	eax, eax
	cmp	ecx, 1
	setae	al
	lea	eax, [eax + eax - 1]
	mov	edx, -1
	push	dword [ebp + 16]
	push	dword [ebp + 12]
	push	eax
	call	format_to
	add	esp, 12
	pop	ebp
	ret
Lfunc_end153:
global snprintf
align 16
snprintf:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	push	eax
	mov	edx, dword [ebp + 12]
	mov	eax, dword [ebp + 16]
	mov	ecx, dword [ebp + 8]
	lea	esi, [ebp + 20]
	mov	dword [ebp - 16], esi
	xor	ebx, ebx
	cmp	ecx, 1
	setae	bl
	lea	edi, [ebx + ebx - 1]
	push	esi
	push	eax
	push	edi
	call	format_to
	add	esp, 16
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
Lfunc_end154:
global sprintf
align 16
sprintf:
	push	ebp
	mov	ebp, esp
	push	edi
	push	esi
	push	eax
	mov	eax, dword [ebp + 12]
	mov	ecx, dword [ebp + 8]
	lea	esi, [ebp + 16]
	mov	dword [ebp - 12], esi
	xor	edx, edx
	cmp	ecx, 1
	setae	dl
	lea	edi, [edx + edx - 1]
	mov	edx, -1
	push	esi
	push	eax
	push	edi
	call	format_to
	add	esp, 16
	pop	esi
	pop	edi
	pop	ebp
	ret
Lfunc_end155:
global vfprintf
align 16
vfprintf:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 524
	mov	edi, dword [ebp + 8]
	test	edi, edi
	je	LBB156_4
	cmp	dword [edi + 12], 0
	je	LBB156_3
	cmp	dword [edi + 20], 0
	je	LBB156_3
	mov	esi, dword [ebp + 12]
	cmp	dword [edi + 24], 0
	je	LBB156_10
	mov	ebx, dword [edi]
	mov	eax, 8
	xor	ecx, ecx
	mov	edx, 2
	int	128
	test	eax, eax
	jns	LBB156_10
	cmp	eax, -1
	mov	ecx, 22
	je	LBB156_9
	neg	eax
	mov	ecx, eax
LBB156_9:
	mov	dword [errno], ecx
LBB156_10:
	mov	eax, dword [ebp + 16]
	mov	dword [ebp - 24], eax
	lea	ecx, [ebp - 536]
	mov	edx, 512
	push	eax
	push	esi
	push	dword [edi]
	call	format_to
	add	esp, 12
	cmp	eax, 511
	ja	LBB156_13
	lea	edx, [ebp - 536]
	mov	ecx, edi
	push	eax
	mov	esi, eax
	call	stream_write
	add	esp, 4
	mov	ecx, eax
	mov	eax, esi
	test	ecx, ecx
	jns	LBB156_31
	mov	eax, -1
	mov	dword [edi + 8], 1
	jmp	LBB156_31
LBB156_3:
	mov	dword [edi + 8], 1
LBB156_4:
	mov	dword [errno], 9
LBB156_30:
	mov	eax, -1
LBB156_31:
	add	esp, 524
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
LBB156_13:
	test	eax, eax
	js	LBB156_24
	mov	edx, dword [edi + 28]
	test	edx, edx
	je	LBB156_23
	mov	ecx, dword [edi]
	mov	dword [ebp - 20], ecx
	lea	eax, [edi + 37]
	mov	dword [ebp - 16], eax
	xor	esi, esi
	jmp	LBB156_16
align 16
LBB156_21:
	add	esi, ecx
	mov	edx, edi
	cmp	esi, edi
	jae	LBB156_22
LBB156_16:
	mov	edi, edx
	sub	edx, esi
	mov	eax, dword [ebp - 16]
	lea	ecx, [eax + esi]
	mov	eax, 4
	mov	ebx, dword [ebp - 20]
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB156_25
	cmp	ebx, 31
	ja	LBB156_21
	cmp	byte [ebx + tracked_persist_fd], 0
	je	LBB156_21
	movzx	ebx, byte [ebx + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB156_21
	shl	ebx, 16
	or	ebx, 536870916
	mov	eax, 15
	xor	edx, edx
	int	128
	jmp	LBB156_21
LBB156_25:
	mov	edx, dword [ebp + 8]
	jns	LBB156_29
	cmp	ecx, -1
	mov	eax, 5
	je	LBB156_28
	neg	ecx
	mov	eax, ecx
LBB156_28:
	mov	dword [errno], eax
LBB156_29:
	mov	dword [edx + 8], 1
	jmp	LBB156_30
LBB156_22:
	mov	edi, dword [ebp + 8]
	mov	dword [edi + 28], 0
	mov	esi, dword [ebp + 12]
LBB156_23:
	xor	ecx, ecx
	xor	edx, edx
	push	dword [ebp + 16]
	push	esi
	push	dword [edi]
	call	format_to
	add	esp, 12
	test	eax, eax
	jns	LBB156_31
LBB156_24:
	mov	dword [edi + 8], 1
	jmp	LBB156_31
Lfunc_end156:
global fprintf
align 16
fprintf:
	push	ebp
	mov	ebp, esp
	push	eax
	mov	eax, dword [ebp + 8]
	mov	ecx, dword [ebp + 12]
	lea	edx, [ebp + 16]
	mov	dword [ebp - 4], edx
	push	edx
	push	ecx
	push	eax
	call	vfprintf
	add	esp, 16
	pop	ebp
	ret
Lfunc_end157:
global vprintf
align 16
vprintf:
	push	ebp
	mov	ebp, esp
	push	dword [ebp + 12]
	push	dword [ebp + 8]
	push	dword [stdout]
	call	vfprintf
	add	esp, 12
	pop	ebp
	ret
Lfunc_end158:
global printf
align 16
printf:
	push	ebp
	mov	ebp, esp
	push	eax
	mov	eax, dword [ebp + 8]
	lea	ecx, [ebp + 12]
	mov	dword [ebp - 4], ecx
	push	ecx
	push	eax
	push	dword [stdout]
	call	vfprintf
	add	esp, 16
	pop	ebp
	ret
Lfunc_end159:
global sscanf
align 16
sscanf:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 100
	mov	edi, dword [ebp + 12]
	mov	ebx, dword [ebp + 8]
	test	ebx, ebx
	setne	al
	test	edi, edi
	setne	cl
	test	al, cl
	je	LBB160_1
	lea	eax, [ebp + 16]
	mov	dword [ebp - 20], eax
	lea	eax, [ebp - 112]
	neg	eax
	mov	dword [ebp - 40], eax
	xor	esi, esi
	mov	dword [ebp - 28], 0
align 16
LBB160_3:
	movzx	ecx, byte [edi]
	movzx	edx, cl
	lea	eax, [edx - 9]
	cmp	eax, 5
	jb	LBB160_9
	cmp	edx, 32
	je	LBB160_9
	test	edx, edx
	je	LBB160_111
	cmp	edx, 37
	jne	LBB160_7
	movzx	edx, byte [edi + 1]
	cmp	dl, 37
	jne	LBB160_16
	cmp	byte [ebx], 37
	jne	LBB160_111
	add	edi, 2
	jmp	LBB160_23
align 16
LBB160_11:
	movzx	ecx, byte [edi + 1]
	inc	edi
LBB160_9:
	movzx	eax, cl
	lea	ecx, [eax - 9]
	cmp	ecx, 5
	jb	LBB160_11
	cmp	eax, 32
	je	LBB160_11
	jmp	LBB160_12
align 16
LBB160_14:
	inc	ebx
LBB160_12:
	movzx	eax, byte [ebx]
	lea	ecx, [eax - 9]
	cmp	ecx, 5
	jb	LBB160_14
	cmp	eax, 32
	je	LBB160_14
	jmp	LBB160_3
LBB160_7:
	cmp	byte [ebx], cl
	jne	LBB160_111
	inc	edi
LBB160_23:
	inc	esi
	inc	ebx
	jmp	LBB160_3
LBB160_16:
	inc	edi
	mov	ecx, edx
	add	cl, -58
	xor	eax, eax
	cmp	cl, -10
	mov	dword [ebp - 32], esi
	jb	LBB160_19
	xor	eax, eax
align 16
LBB160_18:
	lea	eax, [eax + 4*eax]
	movzx	ecx, dl
	lea	eax, [ecx + 2*eax - 48]
	movzx	edx, byte [edi + 1]
	inc	edi
	mov	ecx, edx
	add	cl, -58
	cmp	cl, -11
	ja	LBB160_18
LBB160_19:
	movzx	edx, dl
	add	edx, -88
	cmp	edx, 32
	ja	LBB160_108
	jmp	dword [4*edx + LJTI160_0]
LBB160_98:
	mov	dword [ebp - 16], eax
	mov	eax, dword [ebp - 20]
	lea	ecx, [eax + 4]
	mov	dword [ebp - 20], ecx
	mov	eax, dword [eax]
	mov	dword [ebp - 24], eax
	mov	esi, ebx
	jmp	LBB160_99
align 16
LBB160_119:
	inc	esi
LBB160_99:
	movzx	edx, byte [esi]
	lea	eax, [edx - 9]
	cmp	eax, 5
	jb	LBB160_119
	cmp	edx, 32
	je	LBB160_119
	mov	ecx, dword [ebp - 16]
	lea	eax, [ecx - 64]
	cmp	eax, -63
	mov	edx, 63
	jb	LBB160_103
	mov	edx, ecx
LBB160_103:
	xor	ecx, ecx
LBB160_104:
	movzx	eax, byte [esi + ecx]
	test	al, al
	je	LBB160_107
	mov	byte [ebp + ecx - 112], al
	inc	ecx
	cmp	edx, ecx
	jne	LBB160_104
	mov	ecx, edx
LBB160_107:
	mov	byte [ebp + ecx - 112], 0
	push	16
	jmp	LBB160_86
LBB160_62:
	mov	dword [ebp - 16], eax
	mov	eax, dword [ebp - 20]
	lea	ecx, [eax + 4]
	mov	dword [ebp - 20], ecx
	mov	eax, dword [eax]
	mov	dword [ebp - 44], eax
	movzx	ecx, byte [edi]
	mov	esi, ebx
	jmp	LBB160_63
align 16
LBB160_116:
	inc	esi
LBB160_63:
	movzx	edx, byte [esi]
	lea	eax, [edx - 9]
	cmp	eax, 5
	jb	LBB160_116
	cmp	edx, 32
	je	LBB160_116
	xor	edx, edx
	cmp	cl, 105
	mov	eax, 0
	je	LBB160_67
	mov	eax, 10
LBB160_67:
	mov	dword [ebp - 24], eax
	mov	ecx, dword [ebp - 16]
	lea	eax, [ecx - 64]
	cmp	eax, -63
	mov	eax, 63
	jb	LBB160_69
	mov	eax, ecx
LBB160_69:
	mov	ecx, eax
LBB160_70:
	movzx	eax, byte [esi + edx]
	test	al, al
	je	LBB160_73
	mov	byte [ebp + edx - 112], al
	inc	edx
	cmp	ecx, edx
	jne	LBB160_70
	mov	edx, ecx
LBB160_73:
	mov	byte [ebp + edx - 112], 0
	push	dword [ebp - 24]
	lea	eax, [ebp - 36]
	push	eax
	lea	eax, [ebp - 112]
	push	eax
	call	strtol
	add	esp, 12
	mov	ecx, dword [ebp - 36]
	lea	edx, [ebp - 112]
	cmp	ecx, edx
	je	LBB160_110
	mov	edx, dword [ebp - 44]
	jmp	LBB160_75
LBB160_54:
	mov	edx, dword [ebp - 20]
	mov	ecx, eax
	lea	eax, [edx + 4]
	mov	dword [ebp - 20], eax
	mov	eax, ecx
	cmp	ecx, 2
	jge	LBB160_56
	mov	eax, 1
LBB160_56:
	mov	edx, dword [edx]
	xor	esi, esi
LBB160_57:
	cmp	byte [ebx + esi], 0
	je	LBB160_110
	inc	esi
	cmp	eax, esi
	jne	LBB160_57
	xor	esi, esi
LBB160_60:
	mov	ecx, eax
	movzx	eax, byte [ebx + esi]
	mov	byte [edx + esi], al
	mov	eax, ecx
	inc	esi
	cmp	ecx, esi
	jne	LBB160_60
	add	ebx, eax
	mov	ecx, 1
	mov	esi, ebx
	jmp	LBB160_39
LBB160_40:
	cmp	byte [edi + 1], 94
	jne	LBB160_108
	cmp	byte [edi + 2], 0
	je	LBB160_108
	cmp	byte [edi + 3], 93
	jne	LBB160_108
	mov	edx, dword [ebp - 20]
	mov	ecx, eax
	lea	eax, [edx + 4]
	mov	dword [ebp - 20], eax
	test	ecx, ecx
	mov	dword [ebp - 16], 99
	jle	LBB160_45
	mov	dword [ebp - 16], ecx
LBB160_45:
	mov	esi, dword [edx]
	movzx	edx, byte [edi + 2]
	xor	ecx, ecx
	mov	eax, dword [ebp - 16]
LBB160_46:
	mov	dh, byte [ebx + ecx]
	test	dh, dh
	je	LBB160_50
	cmp	dl, dh
	je	LBB160_50
	mov	byte [esi + ecx], dh
	inc	ecx
	cmp	eax, ecx
	jne	LBB160_46
	mov	byte [esi + eax], 0
	jmp	LBB160_51
LBB160_76:
	mov	dword [ebp - 16], eax
	mov	eax, dword [ebp - 20]
	lea	ecx, [eax + 4]
	mov	dword [ebp - 20], ecx
	mov	eax, dword [eax]
	mov	dword [ebp - 24], eax
	mov	esi, ebx
	jmp	LBB160_77
align 16
LBB160_117:
	inc	esi
LBB160_77:
	movzx	edx, byte [esi]
	lea	eax, [edx - 9]
	cmp	eax, 5
	jb	LBB160_117
	cmp	edx, 32
	je	LBB160_117
	mov	ecx, dword [ebp - 16]
	lea	eax, [ecx - 64]
	cmp	eax, -63
	mov	edx, 63
	jb	LBB160_81
	mov	edx, ecx
LBB160_81:
	xor	ecx, ecx
LBB160_82:
	movzx	eax, byte [esi + ecx]
	test	al, al
	je	LBB160_85
	mov	byte [ebp + ecx - 112], al
	inc	ecx
	cmp	edx, ecx
	jne	LBB160_82
	mov	ecx, edx
LBB160_85:
	mov	byte [ebp + ecx - 112], 0
	push	10
	jmp	LBB160_86
LBB160_88:
	mov	dword [ebp - 16], eax
	mov	eax, dword [ebp - 20]
	lea	ecx, [eax + 4]
	mov	dword [ebp - 20], ecx
	mov	eax, dword [eax]
	mov	dword [ebp - 24], eax
	mov	esi, ebx
	jmp	LBB160_89
align 16
LBB160_118:
	inc	esi
LBB160_89:
	movzx	edx, byte [esi]
	lea	eax, [edx - 9]
	cmp	eax, 5
	jb	LBB160_118
	cmp	edx, 32
	je	LBB160_118
	mov	ecx, dword [ebp - 16]
	lea	eax, [ecx - 64]
	cmp	eax, -63
	mov	edx, 63
	jb	LBB160_93
	mov	edx, ecx
LBB160_93:
	xor	ecx, ecx
LBB160_94:
	movzx	eax, byte [esi + ecx]
	test	al, al
	je	LBB160_97
	mov	byte [ebp + ecx - 112], al
	inc	ecx
	cmp	edx, ecx
	jne	LBB160_94
	mov	ecx, edx
LBB160_97:
	mov	byte [ebp + ecx - 112], 0
	push	8
LBB160_86:
	lea	eax, [ebp - 36]
	push	eax
	lea	eax, [ebp - 112]
	push	eax
	call	strtoul
	add	esp, 12
	mov	ecx, dword [ebp - 36]
	lea	edx, [ebp - 112]
	cmp	ecx, edx
	je	LBB160_110
	mov	edx, dword [ebp - 24]
LBB160_75:
	mov	dword [edx], eax
	add	esi, dword [ebp - 40]
	add	esi, ecx
LBB160_38:
	mov	ecx, 1
LBB160_39:
	mov	edx, dword [ebp - 28]
	add	edi, ecx
	mov	eax, dword [ebp - 32]
	inc	eax
	inc	edx
	mov	dword [ebp - 28], edx
	mov	ebx, esi
	mov	esi, eax
	jmp	LBB160_3
LBB160_24:
	mov	dword [ebp - 16], eax
	mov	ecx, dword [ebp - 20]
	lea	edx, [ecx + 4]
	mov	dword [ebp - 20], edx
	mov	eax, dword [ecx]
	mov	dword [ebp - 24], eax
	lea	esi, [ebx + 1]
	jmp	LBB160_25
align 16
LBB160_30:
	inc	ebx
	inc	esi
LBB160_25:
	movzx	edx, byte [ebx]
	movzx	ecx, dl
	lea	eax, [ecx - 9]
	cmp	eax, 5
	jb	LBB160_30
	cmp	ecx, 32
	je	LBB160_30
	mov	eax, dword [ebp - 16]
	test	eax, eax
	mov	ecx, 1023
	jle	LBB160_29
	mov	ecx, eax
LBB160_29:
	mov	dword [ebp - 48], ecx
	lea	eax, [ecx - 1]
	mov	dword [ebp - 44], eax
	xor	ecx, ecx
LBB160_32:
	movzx	ebx, dl
	lea	eax, [ebx - 9]
	cmp	eax, 23
	ja	LBB160_33
	mov	dword [ebp - 16], ecx
	mov	ecx, 8388639
	bt	ecx, eax
	mov	ecx, dword [ebp - 16]
	jb	LBB160_37
LBB160_33:
	test	ebx, ebx
	je	LBB160_37
	mov	eax, dword [ebp - 24]
	mov	byte [eax + ecx], dl
	cmp	dword [ebp - 44], ecx
	je	LBB160_35
	movzx	edx, byte [esi]
	inc	esi
	inc	ecx
	jmp	LBB160_32
LBB160_37:
	mov	eax, dword [ebp - 24]
	mov	byte [eax + ecx], 0
	dec	esi
	test	ecx, ecx
	jne	LBB160_38
	jmp	LBB160_109
LBB160_50:
	mov	byte [esi + ecx], 0
	test	ecx, ecx
	je	LBB160_53
LBB160_51:
	add	ebx, ecx
	mov	ecx, 4
	mov	esi, ebx
	jmp	LBB160_39
LBB160_35:
	mov	eax, dword [ebp - 24]
	mov	ecx, dword [ebp - 48]
	mov	byte [eax + ecx], 0
	jmp	LBB160_38
LBB160_1:
	mov	dword [errno], 22
	mov	eax, -1
	jmp	LBB160_115
LBB160_108:
	mov	dword [errno], 22
LBB160_110:
	mov	esi, dword [ebp - 32]
LBB160_111:
	test	esi, esi
	jne	LBB160_114
	cmp	byte [ebx], 0
	je	LBB160_113
LBB160_114:
	mov	eax, dword [ebp - 28]
LBB160_115:
	add	esp, 100
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
LBB160_113:
	mov	eax, -1
	jmp	LBB160_115
LBB160_109:
	mov	ebx, esi
	jmp	LBB160_110
LBB160_53:
	add	ebx, ecx
	jmp	LBB160_110
Lfunc_end160:
section .rodata
align 4
LJTI160_0:
dd LBB160_98
dd LBB160_108
dd LBB160_108
dd LBB160_40
dd LBB160_108
dd LBB160_108
dd LBB160_108
dd LBB160_108
dd LBB160_108
dd LBB160_108
dd LBB160_108
dd LBB160_54
dd LBB160_62
dd LBB160_108
dd LBB160_108
dd LBB160_108
dd LBB160_108
dd LBB160_62
dd LBB160_108
dd LBB160_108
dd LBB160_108
dd LBB160_108
dd LBB160_108
dd LBB160_88
dd LBB160_108
dd LBB160_108
dd LBB160_108
dd LBB160_24
dd LBB160_108
dd LBB160_76
dd LBB160_108
dd LBB160_108
dd LBB160_98
section .text
global getc
align 16
getc:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	esi
	push	eax
	mov	esi, dword [ebp + 8]
	test	esi, esi
	je	LBB161_4
	cmp	dword [esi + 12], 0
	je	LBB161_3
	cmp	dword [esi + 16], 0
	je	LBB161_3
	cmp	dword [esi + 32], 0
	je	LBB161_7
	mov	dword [esi + 32], 0
	movzx	eax, byte [esi + 36]
	jmp	LBB161_20
LBB161_3:
	mov	dword [esi + 8], 1
LBB161_4:
	mov	dword [errno], 9
LBB161_19:
	mov	eax, -1
LBB161_20:
	add	esp, 4
	pop	esi
	pop	ebx
	pop	ebp
	ret
LBB161_7:
	mov	ebx, dword [esi]
	lea	ecx, [ebp - 9]
	mov	eax, 7
	mov	edx, 1
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB161_14
	cmp	ebx, 31
	ja	LBB161_12
	cmp	byte [ebx + tracked_persist_fd], 0
	je	LBB161_12
	movzx	ebx, byte [ebx + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB161_12
	shl	ebx, 16
	or	ebx, 536870914
	mov	eax, 15
	xor	edx, edx
	int	128
LBB161_12:
	cmp	ecx, 1
	jne	LBB161_18
	movzx	eax, byte [ebp - 9]
	jmp	LBB161_20
LBB161_14:
	js	LBB161_15
	mov	dword [esi + 4], 1
	jmp	LBB161_19
LBB161_15:
	cmp	ecx, -1
	mov	eax, 5
	je	LBB161_17
	neg	ecx
	mov	eax, ecx
LBB161_17:
	mov	dword [errno], eax
LBB161_18:
	mov	dword [esi + 8], 1
	jmp	LBB161_19
Lfunc_end161:
global ungetc
align 16
ungetc:
	push	ebp
	mov	ebp, esp
	mov	ecx, dword [ebp + 12]
	mov	eax, dword [ebp + 8]
	cmp	eax, -1
	sete	dl
	test	ecx, ecx
	sete	dh
	or	dh, dl
	jne	LBB162_5
	cmp	dword [ecx + 12], 0
	je	LBB162_8
	cmp	dword [ecx + 16], 0
	je	LBB162_7
	cmp	dword [ecx + 32], 0
	jne	LBB162_7
	mov	byte [ecx + 36], al
	mov	dword [ecx + 32], 1
	mov	dword [ecx + 4], 0
	movzx	eax, al
	pop	ebp
	ret
LBB162_5:
	test	ecx, ecx
	je	LBB162_9
	cmp	dword [ecx + 12], 0
	je	LBB162_8
LBB162_7:
	mov	eax, -1
	cmp	dword [ecx + 16], 0
	je	LBB162_8
	pop	ebp
	ret
LBB162_8:
	mov	dword [ecx + 8], 1
LBB162_9:
	mov	dword [errno], 9
	mov	eax, -1
	pop	ebp
	ret
Lfunc_end162:
global fgets
align 16
fgets:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 8
	mov	esi, dword [ebp + 12]
	mov	eax, dword [ebp + 8]
	test	eax, eax
	setne	dl
	test	esi, esi
	setg	cl
	test	dl, cl
	jne	LBB163_3
	mov	dword [errno], 22
LBB163_2:
	xor	eax, eax
	jmp	LBB163_25
LBB163_3:
	cmp	esi, 1
	jne	LBB163_5
	mov	byte [eax], 0
	jmp	LBB163_25
LBB163_5:
	mov	edx, dword [ebp + 16]
	lea	ebx, [edx + 36]
	dec	esi
	xor	edi, edi
	mov	dword [ebp - 20], ebx
	jmp	LBB163_8
align 16
LBB163_6:
	mov	dword [edx + 32], 0
	mov	ecx, ebx
LBB163_7:
	movzx	ecx, byte [ecx]
	mov	byte [eax + edi], cl
	inc	edi
	cmp	cl, 10
	je	LBB163_24
LBB163_8:
	cmp	esi, edi
	je	LBB163_23
	test	edx, edx
	je	LBB163_20
	cmp	dword [edx + 12], 0
	je	LBB163_19
	cmp	dword [edx + 16], 0
	je	LBB163_19
	cmp	dword [edx + 32], 0
	jne	LBB163_6
	mov	ebx, dword [edx]
	mov	eax, 7
	lea	ecx, [ebp - 13]
	mov	edx, 1
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB163_26
	cmp	ebx, 31
	ja	LBB163_18
	cmp	byte [ebx + tracked_persist_fd], 0
	je	LBB163_18
	movzx	ebx, byte [ebx + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB163_18
	shl	ebx, 16
	or	ebx, 536870914
	mov	eax, 15
	xor	edx, edx
	int	128
align 16
LBB163_18:
	cmp	ecx, 1
	lea	ecx, [ebp - 13]
	mov	eax, dword [ebp + 8]
	mov	edx, dword [ebp + 16]
	mov	ebx, dword [ebp - 20]
	je	LBB163_7
	jmp	LBB163_31
LBB163_19:
	mov	dword [edx + 8], 1
	jmp	LBB163_21
LBB163_20:
	xor	edi, edi
LBB163_21:
	mov	dword [errno], 9
LBB163_22:
	mov	esi, edi
LBB163_23:
	test	esi, esi
	mov	edi, esi
	je	LBB163_2
LBB163_24:
	mov	byte [eax + edi], 0
LBB163_25:
	add	esp, 8
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
LBB163_26:
	js	LBB163_28
	mov	eax, dword [ebp + 16]
	mov	dword [eax + 4], 1
	mov	esi, edi
	mov	eax, dword [ebp + 8]
	jmp	LBB163_23
LBB163_28:
	cmp	ecx, -1
	mov	edx, 5
	mov	eax, dword [ebp + 8]
	je	LBB163_30
	neg	ecx
	mov	edx, ecx
LBB163_30:
	mov	dword [errno], edx
	mov	edx, dword [ebp + 16]
LBB163_31:
	mov	dword [edx + 8], 1
	jmp	LBB163_22
Lfunc_end163:
global fputc
align 16
fputc:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	esi
	push	eax
	mov	esi, dword [ebp + 12]
	movzx	eax, byte [ebp + 8]
	mov	byte [ebp - 9], al
	test	esi, esi
	je	LBB164_11
	cmp	dword [esi + 12], 0
	je	LBB164_10
	cmp	dword [esi + 20], 0
	je	LBB164_10
	cmp	dword [esi + 24], 0
	je	LBB164_8
	mov	ebx, dword [esi]
	mov	eax, 8
	xor	ecx, ecx
	mov	edx, 2
	int	128
	test	eax, eax
	jns	LBB164_8
	cmp	eax, -1
	mov	ecx, 22
	je	LBB164_7
	neg	eax
	mov	ecx, eax
LBB164_7:
	mov	dword [errno], ecx
LBB164_8:
	lea	edx, [ebp - 9]
	mov	ecx, esi
	push	1
	call	stream_write
	add	esp, 4
	test	eax, eax
	js	LBB164_14
	movzx	eax, byte [ebp - 9]
	jmp	LBB164_13
LBB164_10:
	mov	dword [esi + 8], 1
LBB164_11:
	mov	dword [errno], 9
LBB164_12:
	mov	eax, -1
LBB164_13:
	add	esp, 4
	pop	esi
	pop	ebx
	pop	ebp
	ret
LBB164_14:
	mov	dword [esi + 8], 1
	jmp	LBB164_12
Lfunc_end164:
global putc
align 16
putc:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	esi
	push	eax
	mov	esi, dword [ebp + 12]
	movzx	eax, byte [ebp + 8]
	mov	byte [ebp - 9], al
	test	esi, esi
	je	LBB165_11
	cmp	dword [esi + 12], 0
	je	LBB165_10
	cmp	dword [esi + 20], 0
	je	LBB165_10
	cmp	dword [esi + 24], 0
	je	LBB165_8
	mov	ebx, dword [esi]
	mov	eax, 8
	xor	ecx, ecx
	mov	edx, 2
	int	128
	test	eax, eax
	jns	LBB165_8
	cmp	eax, -1
	mov	ecx, 22
	je	LBB165_7
	neg	eax
	mov	ecx, eax
LBB165_7:
	mov	dword [errno], ecx
LBB165_8:
	lea	edx, [ebp - 9]
	mov	ecx, esi
	push	1
	call	stream_write
	add	esp, 4
	test	eax, eax
	js	LBB165_14
	movzx	eax, byte [ebp - 9]
	jmp	LBB165_13
LBB165_10:
	mov	dword [esi + 8], 1
LBB165_11:
	mov	dword [errno], 9
LBB165_12:
	mov	eax, -1
LBB165_13:
	add	esp, 4
	pop	esi
	pop	ebx
	pop	ebp
	ret
LBB165_14:
	mov	dword [esi + 8], 1
	jmp	LBB165_12
Lfunc_end165:
global putchar
align 16
putchar:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	esi
	push	eax
	movzx	eax, byte [ebp + 8]
	mov	esi, dword [stdout]
	mov	byte [ebp - 9], al
	test	esi, esi
	je	LBB166_11
	cmp	dword [esi + 12], 0
	je	LBB166_10
	cmp	dword [esi + 20], 0
	je	LBB166_10
	cmp	dword [esi + 24], 0
	je	LBB166_8
	mov	ebx, dword [esi]
	mov	eax, 8
	xor	ecx, ecx
	mov	edx, 2
	int	128
	test	eax, eax
	jns	LBB166_8
	cmp	eax, -1
	mov	ecx, 22
	je	LBB166_7
	neg	eax
	mov	ecx, eax
LBB166_7:
	mov	dword [errno], ecx
LBB166_8:
	lea	edx, [ebp - 9]
	mov	ecx, esi
	push	1
	call	stream_write
	add	esp, 4
	test	eax, eax
	js	LBB166_14
	movzx	eax, byte [ebp - 9]
	jmp	LBB166_13
LBB166_10:
	mov	dword [esi + 8], 1
LBB166_11:
	mov	dword [errno], 9
LBB166_12:
	mov	eax, -1
LBB166_13:
	add	esp, 4
	pop	esi
	pop	ebx
	pop	ebp
	ret
LBB166_14:
	mov	dword [esi + 8], 1
	jmp	LBB166_12
Lfunc_end166:
global fputs
align 16
fputs:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	mov	esi, dword [ebp + 12]
	mov	edi, dword [ebp + 8]
	test	edi, edi
	sete	al
	test	esi, esi
	sete	cl
	or	cl, al
	jne	LBB167_12
	cmp	dword [esi + 12], 0
	je	LBB167_13
	cmp	dword [esi + 20], 0
	je	LBB167_13
	cmp	dword [esi + 24], 0
	je	LBB167_8
	mov	ebx, dword [esi]
	mov	eax, 8
	xor	ecx, ecx
	mov	edx, 2
	int	128
	test	eax, eax
	jns	LBB167_8
	cmp	eax, -1
	mov	ecx, 22
	je	LBB167_7
	neg	eax
	mov	ecx, eax
LBB167_7:
	mov	dword [errno], ecx
LBB167_8:
	mov	eax, -1
align 16
LBB167_9:
	cmp	byte [edi + eax + 1], 0
	lea	eax, [eax + 1]
	jne	LBB167_9
	mov	ecx, esi
	mov	edx, edi
	push	eax
	call	stream_write
	add	esp, 4
	mov	ecx, eax
	xor	eax, eax
	test	ecx, ecx
	jns	LBB167_18
	mov	dword [esi + 8], 1
	jmp	LBB167_17
LBB167_12:
	test	esi, esi
	je	LBB167_14
LBB167_13:
	mov	dword [esi + 8], 1
LBB167_14:
	test	edi, edi
	mov	eax, 9
	jne	LBB167_16
	mov	eax, 22
LBB167_16:
	mov	dword [errno], eax
LBB167_17:
	mov	eax, -1
LBB167_18:
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
Lfunc_end167:
global puts
align 16
puts:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	push	eax
	mov	edi, dword [ebp + 8]
	mov	esi, dword [stdout]
	test	edi, edi
	sete	al
	test	esi, esi
	sete	cl
	or	cl, al
	jne	LBB168_21
	cmp	dword [esi + 12], 0
	je	LBB168_22
	cmp	dword [esi + 20], 0
	je	LBB168_22
	cmp	dword [esi + 24], 0
	je	LBB168_8
	mov	ebx, dword [esi]
	mov	eax, 8
	xor	ecx, ecx
	mov	edx, 2
	int	128
	test	eax, eax
	jns	LBB168_8
	cmp	eax, -1
	mov	ecx, 22
	je	LBB168_7
	neg	eax
	mov	ecx, eax
LBB168_7:
	mov	dword [errno], ecx
LBB168_8:
	mov	eax, -1
align 16
LBB168_9:
	cmp	byte [edi + eax + 1], 0
	lea	eax, [eax + 1]
	jne	LBB168_9
	mov	ecx, esi
	mov	edx, edi
	push	eax
	call	stream_write
	add	esp, 4
	test	eax, eax
	js	LBB168_28
	mov	esi, dword [stdout]
	mov	byte [ebp - 13], 10
	test	esi, esi
	je	LBB168_30
	cmp	dword [esi + 12], 0
	je	LBB168_29
	cmp	dword [esi + 20], 0
	je	LBB168_29
	cmp	dword [esi + 24], 0
	je	LBB168_19
	mov	ebx, dword [esi]
	mov	eax, 8
	xor	ecx, ecx
	mov	edx, 2
	int	128
	test	eax, eax
	jns	LBB168_19
	cmp	eax, -1
	mov	ecx, 22
	je	LBB168_18
	neg	eax
	mov	ecx, eax
LBB168_18:
	mov	dword [errno], ecx
LBB168_19:
	lea	edx, [ebp - 13]
	mov	ecx, esi
	push	1
	call	stream_write
	add	esp, 4
	test	eax, eax
	js	LBB168_28
	mov	eax, 1
	jmp	LBB168_27
LBB168_21:
	test	esi, esi
	je	LBB168_23
LBB168_22:
	mov	dword [esi + 8], 1
LBB168_23:
	test	edi, edi
	mov	eax, 9
	jne	LBB168_25
	mov	eax, 22
LBB168_25:
	mov	dword [errno], eax
LBB168_26:
	mov	eax, -1
LBB168_27:
	add	esp, 4
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
LBB168_28:
	mov	dword [esi + 8], 1
	jmp	LBB168_26
LBB168_29:
	mov	dword [esi + 8], 1
LBB168_30:
	mov	dword [errno], 9
	jmp	LBB168_26
Lfunc_end168:
global perror
align 16
perror:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 8
	mov	edi, dword [ebp + 8]
	mov	ebx, dword [errno]
	test	edi, edi
	je	LBB169_28
	cmp	byte [edi], 0
	je	LBB169_28
	mov	esi, dword [stderr]
	test	esi, esi
	je	LBB169_6
	cmp	dword [esi + 12], 0
	je	LBB169_5
	cmp	dword [esi + 20], 0
	je	LBB169_5
	cmp	dword [esi + 24], 0
	je	LBB169_12
	mov	dword [ebp - 20], ebx
	mov	ebx, dword [esi]
	mov	eax, 8
	xor	ecx, ecx
	mov	edx, 2
	int	128
	mov	ebx, dword [ebp - 20]
	test	eax, eax
	jns	LBB169_12
	cmp	eax, -1
	mov	ecx, 22
	je	LBB169_11
	neg	eax
	mov	ecx, eax
LBB169_11:
	mov	dword [errno], ecx
LBB169_12:
	mov	eax, -1
align 16
LBB169_13:
	cmp	byte [edi + eax + 1], 0
	lea	eax, [eax + 1]
	jne	LBB169_13
	mov	ecx, esi
	mov	edx, edi
	push	eax
	call	stream_write
	add	esp, 4
	test	eax, eax
	jns	LBB169_16
	mov	dword [esi + 8], 1
	jmp	LBB169_16
LBB169_5:
	mov	dword [esi + 8], 1
LBB169_6:
	mov	dword [errno], 9
LBB169_16:
	mov	esi, dword [stderr]
	test	esi, esi
	je	LBB169_20
	cmp	dword [esi + 12], 0
	je	LBB169_19
	cmp	dword [esi + 20], 0
	je	LBB169_19
	cmp	dword [esi + 24], 0
	je	LBB169_26
	mov	edi, ebx
	mov	ebx, dword [esi]
	mov	eax, 8
	xor	ecx, ecx
	mov	edx, 2
	int	128
	mov	ebx, edi
	test	eax, eax
	jns	LBB169_26
	cmp	eax, -1
	mov	ecx, 22
	je	LBB169_25
	neg	eax
	mov	ecx, eax
LBB169_25:
	mov	dword [errno], ecx
LBB169_26:
	mov	ecx, esi
	mov	edx, L.str.21
	push	2
	call	stream_write
	add	esp, 4
	test	eax, eax
	jns	LBB169_28
	mov	dword [esi + 8], 1
	jmp	LBB169_28
LBB169_19:
	mov	dword [esi + 8], 1
LBB169_20:
	mov	dword [errno], 9
LBB169_28:
	push	ebx
	call	strerror
	add	esp, 4
	mov	esi, dword [stderr]
	test	esi, esi
	je	LBB169_32
	cmp	dword [esi + 12], 0
	je	LBB169_31
	cmp	dword [esi + 20], 0
	je	LBB169_31
	cmp	dword [esi + 24], 0
	je	LBB169_38
	mov	edi, ebx
	mov	ebx, dword [esi]
	mov	dword [ebp - 20], eax
	mov	eax, 8
	xor	ecx, ecx
	mov	edx, 2
	int	128
	mov	ebx, edi
	mov	ecx, eax
	mov	eax, dword [ebp - 20]
	test	ecx, ecx
	jns	LBB169_38
	cmp	ecx, -1
	mov	edx, 22
	je	LBB169_37
	neg	ecx
	mov	edx, ecx
LBB169_37:
	mov	dword [errno], edx
LBB169_38:
	mov	edi, -1
align 16
LBB169_39:
	cmp	byte [eax + edi + 1], 0
	lea	edi, [edi + 1]
	jne	LBB169_39
	mov	ecx, esi
	mov	edx, eax
	push	edi
	call	stream_write
	add	esp, 4
	test	eax, eax
	jns	LBB169_42
	mov	dword [esi + 8], 1
	jmp	LBB169_42
LBB169_31:
	mov	dword [esi + 8], 1
LBB169_32:
	mov	dword [errno], 9
LBB169_42:
	mov	esi, dword [stderr]
	mov	byte [ebp - 13], 10
	test	esi, esi
	je	LBB169_52
	cmp	dword [esi + 12], 0
	je	LBB169_51
	cmp	dword [esi + 20], 0
	je	LBB169_51
	cmp	dword [esi + 24], 0
	je	LBB169_50
	mov	edi, ebx
	mov	ebx, dword [esi]
	mov	eax, 8
	xor	ecx, ecx
	mov	edx, 2
	int	128
	mov	ebx, edi
	test	eax, eax
	jns	LBB169_50
	cmp	eax, -1
	mov	ecx, 22
	je	LBB169_49
	neg	eax
	mov	ecx, eax
LBB169_49:
	mov	dword [errno], ecx
LBB169_50:
	lea	edx, [ebp - 13]
	mov	ecx, esi
	push	1
	call	stream_write
	add	esp, 4
	test	eax, eax
	jns	LBB169_52
LBB169_51:
	mov	dword [esi + 8], 1
LBB169_52:
	mov	dword [errno], ebx
	add	esp, 8
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
Lfunc_end169:
global fscanf
align 16
fscanf:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 32
	mov	edi, dword [ebp + 12]
	mov	esi, dword [ebp + 8]
	test	esi, esi
	setne	al
	test	edi, edi
	setne	cl
	test	al, cl
	je	LBB170_94
	lea	eax, [ebp + 16]
	mov	dword [ebp - 24], eax
	lea	eax, [esi + 36]
	mov	dword [ebp - 36], eax
	xor	ebx, ebx
	mov	dword [ebp - 40], 0
align 16
LBB170_2:
	movzx	eax, byte [edi]
	movzx	ecx, al
	lea	edx, [ecx - 9]
	cmp	edx, 5
	jb	LBB170_12
	cmp	ecx, 32
	je	LBB170_12
	test	ecx, ecx
	je	LBB170_104
	cmp	ecx, 37
	jne	LBB170_15
	movzx	eax, byte [edi + 1]
	cmp	al, 37
	jne	LBB170_35
	cmp	dword [esi + 12], 0
	je	LBB170_95
	cmp	dword [esi + 16], 0
	je	LBB170_95
	cmp	dword [esi + 32], 0
	je	LBB170_27
	mov	dword [esi + 32], 0
	mov	eax, dword [ebp - 36]
	jmp	LBB170_33
align 16
LBB170_11:
	movzx	eax, byte [edi + 1]
	inc	edi
LBB170_12:
	movzx	eax, al
	lea	ecx, [eax - 9]
	cmp	ecx, 5
	jb	LBB170_11
	cmp	eax, 32
	je	LBB170_11
	mov	ecx, esi
	call	scan_skip_space
	jmp	LBB170_2
LBB170_15:
	cmp	dword [esi + 12], 0
	je	LBB170_95
	cmp	dword [esi + 16], 0
	je	LBB170_95
	cmp	dword [esi + 32], 0
	je	LBB170_19
	mov	dword [esi + 32], 0
	mov	eax, dword [ebp - 36]
	jmp	LBB170_25
LBB170_19:
	mov	dword [ebp - 20], ebx
	mov	ebx, dword [esi]
	mov	eax, 7
	lea	ecx, [ebp - 25]
	mov	edx, 1
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB170_97
	cmp	ebx, 31
	ja	LBB170_24
	cmp	byte [ebx + tracked_persist_fd], 0
	je	LBB170_24
	movzx	ebx, byte [ebx + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB170_24
	shl	ebx, 16
	or	ebx, 536870914
	mov	eax, 15
	xor	edx, edx
	int	128
LBB170_24:
	cmp	ecx, 1
	lea	eax, [ebp - 25]
	mov	ebx, dword [ebp - 20]
	jne	LBB170_101
LBB170_25:
	movzx	eax, byte [eax]
	cmp	al, byte [edi]
	jne	LBB170_96
	inc	edi
	inc	dword [ebp - 40]
	jmp	LBB170_2
LBB170_27:
	mov	dword [ebp - 20], ebx
	mov	ebx, dword [esi]
	mov	eax, 7
	lea	ecx, [ebp - 26]
	mov	edx, 1
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB170_97
	cmp	ebx, 31
	ja	LBB170_32
	cmp	byte [ebx + tracked_persist_fd], 0
	je	LBB170_32
	movzx	ebx, byte [ebx + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB170_32
	shl	ebx, 16
	or	ebx, 536870914
	mov	eax, 15
	xor	edx, edx
	int	128
LBB170_32:
	cmp	ecx, 1
	lea	eax, [ebp - 26]
	mov	ebx, dword [ebp - 20]
	jne	LBB170_101
LBB170_33:
	movzx	eax, byte [eax]
	cmp	al, 37
	jne	LBB170_96
	add	edi, 2
	inc	dword [ebp - 40]
	jmp	LBB170_2
LBB170_35:
	inc	edi
	mov	ecx, eax
	add	cl, -58
	xor	edx, edx
	cmp	cl, -10
	jb	LBB170_38
	xor	edx, edx
align 16
LBB170_37:
	lea	ecx, [edx + 4*edx]
	movzx	eax, al
	lea	edx, [eax + 2*ecx - 48]
	movzx	eax, byte [edi + 1]
	inc	edi
	mov	ecx, eax
	add	cl, -58
	cmp	cl, -11
	ja	LBB170_37
LBB170_38:
	movzx	eax, al
	add	eax, -88
	cmp	eax, 32
	ja	LBB170_108
	jmp	dword [4*eax + LJTI170_0]
LBB170_40:
	mov	eax, dword [ebp - 24]
	lea	ecx, [eax + 4]
	mov	dword [ebp - 24], ecx
	mov	dword [ebp - 16], edx
	mov	edx, dword [eax]
	mov	ecx, esi
	push	0
	push	16
	jmp	LBB170_64
LBB170_41:
	mov	dword [ebp - 16], edx
	mov	eax, dword [ebp - 24]
	lea	ecx, [eax + 4]
	mov	dword [ebp - 24], ecx
	mov	edx, dword [eax]
	xor	eax, eax
	cmp	byte [edi], 105
	je	LBB170_43
	mov	eax, 10
LBB170_43:
	mov	ecx, esi
	push	1
	push	eax
	jmp	LBB170_64
LBB170_44:
	mov	eax, dword [ebp - 24]
	lea	ecx, [eax + 4]
	mov	dword [ebp - 24], ecx
	cmp	edx, 2
	jge	LBB170_46
	mov	edx, 1
LBB170_46:
	mov	ecx, dword [eax]
	mov	dword [ebp - 20], ebx
	jmp	LBB170_49
LBB170_47:
	mov	dword [esi + 32], 0
	mov	eax, dword [ebp - 36]
LBB170_48:
	movzx	eax, byte [eax]
	mov	byte [ecx], al
	inc	ecx
	dec	edx
	je	LBB170_87
LBB170_49:
	cmp	dword [esi + 12], 0
	je	LBB170_95
	cmp	dword [esi + 16], 0
	je	LBB170_95
	cmp	dword [esi + 32], 0
	jne	LBB170_47
	mov	dword [ebp - 32], ecx
	mov	dword [ebp - 16], edx
	mov	ebx, dword [esi]
	mov	eax, 7
	lea	ecx, [ebp - 28]
	mov	edx, 1
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB170_109
	cmp	ebx, 31
	ja	LBB170_57
	cmp	byte [ebx + tracked_persist_fd], 0
	je	LBB170_57
	movzx	ebx, byte [ebx + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB170_57
	shl	ebx, 16
	or	ebx, 536870914
	mov	eax, 15
	xor	edx, edx
	int	128
LBB170_57:
	cmp	ecx, 1
	lea	eax, [ebp - 28]
	mov	ebx, dword [ebp - 20]
	mov	edx, dword [ebp - 16]
	mov	ecx, dword [ebp - 32]
	je	LBB170_48
	jmp	LBB170_101
LBB170_58:
	cmp	byte [edi + 1], 94
	jne	LBB170_108
	cmp	byte [edi + 2], 0
	je	LBB170_108
	cmp	byte [edi + 3], 93
	jne	LBB170_108
	mov	eax, dword [ebp - 24]
	lea	ecx, [eax + 4]
	mov	dword [ebp - 24], ecx
	mov	dword [ebp - 16], edx
	mov	edx, dword [eax]
	movzx	eax, byte [edi + 2]
	mov	ecx, esi
	push	eax
	push	dword [ebp - 16]
	call	scan_read_until
	add	esp, 8
	mov	ecx, 4
	jmp	LBB170_65
LBB170_62:
	mov	eax, dword [ebp - 24]
	lea	ecx, [eax + 4]
	mov	dword [ebp - 24], ecx
	mov	dword [ebp - 16], edx
	mov	edx, dword [eax]
	mov	ecx, esi
	push	0
	push	10
	jmp	LBB170_64
LBB170_63:
	mov	eax, dword [ebp - 24]
	lea	ecx, [eax + 4]
	mov	dword [ebp - 24], ecx
	mov	dword [ebp - 16], edx
	mov	edx, dword [eax]
	mov	ecx, esi
	push	0
	push	8
LBB170_64:
	push	dword [ebp - 16]
	call	scan_read_number
	add	esp, 12
	mov	ecx, 1
LBB170_65:
	test	eax, eax
	je	LBB170_104
LBB170_66:
	add	edi, ecx
	inc	dword [ebp - 40]
	inc	ebx
	jmp	LBB170_2
LBB170_67:
	mov	eax, dword [ebp - 24]
	lea	ecx, [eax + 4]
	mov	dword [ebp - 24], ecx
	test	edx, edx
	mov	dword [ebp - 44], 1023
	jle	LBB170_69
	mov	dword [ebp - 44], edx
LBB170_69:
	mov	eax, dword [eax]
	mov	dword [ebp - 32], eax
	mov	ecx, esi
	call	scan_skip_space
	xor	edx, edx
	mov	dword [ebp - 20], ebx
	jmp	LBB170_71
LBB170_70:
	mov	ecx, dword [ebp - 32]
	mov	byte [ecx + edx], al
	inc	edx
	cmp	dword [ebp - 44], edx
	je	LBB170_86
LBB170_71:
	cmp	dword [esi + 12], 0
	je	LBB170_84
	cmp	dword [esi + 16], 0
	je	LBB170_84
	cmp	dword [esi + 32], 0
	mov	dword [ebp - 16], edx
	je	LBB170_75
	mov	dword [esi + 32], 0
	mov	eax, dword [ebp - 36]
	jmp	LBB170_81
LBB170_75:
	mov	ebx, dword [esi]
	mov	eax, 7
	lea	ecx, [ebp - 27]
	mov	edx, 1
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB170_88
	cmp	ebx, 31
	mov	edx, dword [ebp - 16]
	ja	LBB170_80
	cmp	byte [ebx + tracked_persist_fd], 0
	je	LBB170_80
	movzx	ebx, byte [ebx + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB170_80
	shl	ebx, 16
	or	ebx, 536870914
	mov	eax, 15
	xor	edx, edx
	int	128
	mov	edx, dword [ebp - 16]
LBB170_80:
	cmp	ecx, 1
	lea	eax, [ebp - 27]
	mov	ebx, dword [ebp - 20]
	jne	LBB170_93
LBB170_81:
	movzx	eax, byte [eax]
	mov	ecx, eax
	add	ecx, -9
	cmp	ecx, 23
	ja	LBB170_70
	mov	edx, 8388639
	bt	edx, ecx
	mov	edx, dword [ebp - 16]
	jae	LBB170_70
	mov	byte [esi + 36], al
	mov	dword [esi + 32], 1
	mov	dword [esi + 4], 0
	jmp	LBB170_85
LBB170_84:
	mov	dword [esi + 8], 1
	mov	dword [errno], 9
LBB170_85:
	mov	eax, dword [ebp - 32]
	mov	byte [eax + edx], 0
	mov	ecx, 1
	test	edx, edx
	jne	LBB170_66
	jmp	LBB170_104
LBB170_86:
	mov	eax, dword [ebp - 32]
	mov	ecx, dword [ebp - 44]
	mov	byte [eax + ecx], 0
LBB170_87:
	mov	ecx, 1
	jmp	LBB170_66
LBB170_88:
	js	LBB170_90
	mov	dword [esi + 4], 1
	mov	ebx, dword [ebp - 20]
	mov	edx, dword [ebp - 16]
	jmp	LBB170_85
LBB170_90:
	cmp	ecx, -1
	mov	eax, 5
	je	LBB170_92
	neg	ecx
	mov	eax, ecx
LBB170_92:
	mov	dword [errno], eax
	mov	ebx, dword [ebp - 20]
	mov	edx, dword [ebp - 16]
LBB170_93:
	mov	dword [esi + 8], 1
	jmp	LBB170_85
LBB170_94:
	mov	dword [errno], 22
	mov	eax, -1
	jmp	LBB170_107
LBB170_95:
	mov	dword [esi + 8], 1
	mov	dword [errno], 9
	cmp	dword [ebp - 40], 0
	jne	LBB170_105
	jmp	LBB170_106
LBB170_96:
	mov	byte [esi + 36], al
	mov	dword [esi + 32], 1
	mov	dword [esi + 4], 0
	cmp	dword [ebp - 40], 0
	jne	LBB170_105
	jmp	LBB170_106
LBB170_97:
	js	LBB170_98
LBB170_103:
	mov	dword [esi + 4], 1
	mov	ebx, dword [ebp - 20]
	cmp	dword [ebp - 40], 0
	jne	LBB170_105
	jmp	LBB170_106
LBB170_98:
	cmp	ecx, -1
	mov	eax, 5
	mov	ebx, dword [ebp - 20]
	je	LBB170_100
	neg	ecx
	mov	eax, ecx
LBB170_100:
	mov	dword [errno], eax
LBB170_101:
	mov	dword [esi + 8], 1
LBB170_104:
	cmp	dword [ebp - 40], 0
	je	LBB170_106
LBB170_105:
	mov	eax, ebx
	jmp	LBB170_107
LBB170_108:
	mov	dword [errno], 22
	cmp	dword [ebp - 40], 0
	jne	LBB170_105
LBB170_106:
	mov	eax, -1
	cmp	dword [esi + 4], 0
	je	LBB170_105
LBB170_107:
	add	esp, 32
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
LBB170_109:
	jns	LBB170_103
	cmp	ecx, -1
	mov	eax, 5
	je	LBB170_112
	neg	ecx
	mov	eax, ecx
LBB170_112:
	mov	dword [errno], eax
	mov	ebx, dword [ebp - 20]
	jmp	LBB170_101
Lfunc_end170:
section .rodata
align 4
LJTI170_0:
dd LBB170_40
dd LBB170_108
dd LBB170_108
dd LBB170_58
dd LBB170_108
dd LBB170_108
dd LBB170_108
dd LBB170_108
dd LBB170_108
dd LBB170_108
dd LBB170_108
dd LBB170_44
dd LBB170_41
dd LBB170_108
dd LBB170_108
dd LBB170_108
dd LBB170_108
dd LBB170_41
dd LBB170_108
dd LBB170_108
dd LBB170_108
dd LBB170_108
dd LBB170_108
dd LBB170_63
dd LBB170_108
dd LBB170_108
dd LBB170_108
dd LBB170_67
dd LBB170_108
dd LBB170_62
dd LBB170_108
dd LBB170_108
dd LBB170_40
section .text
align 16
scan_skip_space:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 1
	mov	esi, ecx
	cmp	dword [ecx + 12], 0
	je	LBB171_3
	lea	edi, [esi + 36]
	jmp	LBB171_2
align 16
LBB171_5:
	mov	dword [esi + 32], 0
	mov	eax, edi
LBB171_6:
	movzx	eax, byte [eax]
	movzx	ecx, al
	lea	edx, [ecx - 9]
	cmp	edx, 5
	jae	LBB171_7
LBB171_8:
	cmp	dword [esi + 12], 0
	je	LBB171_3
LBB171_2:
	cmp	dword [esi + 16], 0
	je	LBB171_3
	cmp	dword [esi + 32], 0
	jne	LBB171_5
	mov	ebx, dword [esi]
	mov	eax, 7
	lea	ecx, [ebp - 13]
	mov	edx, 1
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB171_15
	cmp	ebx, 31
	ja	LBB171_14
	cmp	byte [ebx + tracked_persist_fd], 0
	je	LBB171_14
	movzx	ebx, byte [ebx + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB171_14
	shl	ebx, 16
	or	ebx, 536870914
	mov	eax, 15
	xor	edx, edx
	int	128
align 16
LBB171_14:
	cmp	ecx, 1
	lea	eax, [ebp - 13]
	je	LBB171_6
	jmp	LBB171_19
LBB171_7:
	cmp	ecx, 32
	je	LBB171_8
	mov	byte [esi + 36], al
	mov	dword [esi + 32], 1
	mov	dword [esi + 4], 0
	jmp	LBB171_21
LBB171_3:
	mov	dword [esi + 8], 1
	mov	dword [errno], 9
LBB171_21:
	add	esp, 1
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
LBB171_15:
	js	LBB171_16
	mov	dword [esi + 4], 1
	jmp	LBB171_21
LBB171_16:
	cmp	ecx, -1
	mov	eax, 5
	je	LBB171_18
	neg	ecx
	mov	eax, ecx
LBB171_18:
	mov	dword [errno], eax
LBB171_19:
	mov	dword [esi + 8], 1
	jmp	LBB171_21
Lfunc_end171:
align 16
scan_read_until:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 16
	mov	edi, ecx
	mov	eax, dword [ebp + 8]
	test	eax, eax
	mov	ecx, 99
	jle	LBB172_2
	mov	ecx, eax
LBB172_2:
	mov	ebx, dword [ebp + 12]
	lea	eax, [edi + 36]
	mov	dword [ebp - 28], eax
	xor	esi, esi
	mov	dword [ebp - 20], edx
	mov	dword [ebp - 24], ecx
align 16
LBB172_3:
	cmp	dword [edi + 12], 0
	je	LBB172_5
	cmp	dword [edi + 16], 0
	je	LBB172_5
	cmp	dword [edi + 32], 0
	je	LBB172_10
	mov	dword [edi + 32], 0
	mov	eax, dword [ebp - 28]
	jmp	LBB172_8
align 16
LBB172_10:
	mov	ebx, dword [edi]
	mov	eax, 7
	lea	ecx, [ebp - 13]
	mov	edx, 1
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB172_16
	cmp	ebx, 31
	ja	LBB172_15
	cmp	byte [ebx + tracked_persist_fd], 0
	je	LBB172_15
	movzx	ebx, byte [ebx + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB172_15
	shl	ebx, 16
	or	ebx, 536870914
	mov	eax, 15
	xor	edx, edx
	int	128
align 16
LBB172_15:
	cmp	ecx, 1
	lea	eax, [ebp - 13]
	mov	edx, dword [ebp - 20]
	mov	ecx, dword [ebp - 24]
	mov	ebx, dword [ebp + 12]
	jne	LBB172_20
LBB172_8:
	movzx	eax, byte [eax]
	cmp	ebx, eax
	je	LBB172_9
	mov	byte [edx + esi], al
	inc	esi
	cmp	ecx, esi
	jne	LBB172_3
	mov	esi, ecx
	jmp	LBB172_23
LBB172_5:
	mov	dword [edi + 8], 1
	mov	dword [errno], 9
	jmp	LBB172_23
LBB172_9:
	mov	byte [edi + 36], al
	mov	dword [edi + 32], 1
	mov	dword [edi + 4], 0
	jmp	LBB172_23
LBB172_16:
	js	LBB172_17
	mov	dword [edi + 4], 1
	mov	edx, dword [ebp - 20]
	jmp	LBB172_23
LBB172_17:
	cmp	ecx, -1
	mov	eax, 5
	mov	edx, dword [ebp - 20]
	je	LBB172_19
	neg	ecx
	mov	eax, ecx
LBB172_19:
	mov	dword [errno], eax
LBB172_20:
	mov	dword [edi + 8], 1
LBB172_23:
	mov	byte [edx + esi], 0
	xor	eax, eax
	test	esi, esi
	setne	al
	add	esp, 16
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
Lfunc_end172:
align 16
scan_read_number:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 84
	mov	edi, edx
	mov	esi, ecx
	mov	eax, dword [ebp + 8]
	lea	ecx, [eax - 64]
	cmp	ecx, -63
	mov	ebx, 63
	jb	LBB173_2
	mov	ebx, eax
LBB173_2:
	mov	ecx, esi
	call	scan_skip_space
	cmp	dword [esi + 12], 0
	je	LBB173_17
	mov	dword [ebp - 24], ebx
	mov	ebx, dword [esi]
	mov	eax, 8
	xor	ecx, ecx
	mov	edx, 1
	int	128
	test	eax, eax
	js	LBB173_18
	add	eax, dword [esi + 28]
	xor	ecx, ecx
	cmp	dword [esi + 32], 0
	setne	cl
	sub	eax, ecx
	mov	ecx, dword [ebp - 24]
	mov	ebx, 0
	js	LBB173_39
	mov	dword [ebp - 28], edi
	mov	dword [ebp - 20], eax
	lea	edx, [esi + 36]
	xor	edi, edi
	mov	dword [ebp - 32], edx
	jmp	LBB173_8
align 16
LBB173_6:
	mov	dword [esi + 32], 0
	mov	eax, edx
LBB173_7:
	movzx	eax, byte [eax]
	mov	byte [ebp + edi - 96], al
	inc	edi
	cmp	ecx, edi
	je	LBB173_22
LBB173_8:
	cmp	dword [esi + 12], 0
	je	LBB173_21
	cmp	dword [esi + 16], 0
	je	LBB173_21
	cmp	dword [esi + 32], 0
	jne	LBB173_6
	mov	ebx, dword [esi]
	mov	eax, 7
	lea	ecx, [ebp - 16]
	mov	edx, 1
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB173_23
	cmp	ebx, 31
	ja	LBB173_16
	cmp	byte [ebx + tracked_persist_fd], 0
	je	LBB173_16
	movzx	ebx, byte [ebx + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB173_16
	shl	ebx, 16
	or	ebx, 536870914
	mov	eax, 15
	xor	edx, edx
	int	128
align 16
LBB173_16:
	cmp	ecx, 1
	lea	eax, [ebp - 16]
	mov	ecx, dword [ebp - 24]
	mov	edx, dword [ebp - 32]
	je	LBB173_7
	jmp	LBB173_28
LBB173_17:
	mov	dword [errno], 9
	jmp	LBB173_38
LBB173_18:
	cmp	eax, -1
	mov	ecx, 22
	je	LBB173_20
	neg	eax
	mov	ecx, eax
LBB173_20:
	mov	dword [errno], ecx
	mov	dword [esi + 8], 1
LBB173_38:
	xor	ebx, ebx
LBB173_39:
	mov	eax, ebx
	add	esp, 84
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
LBB173_21:
	mov	dword [esi + 8], 1
	mov	dword [errno], 9
	jmp	LBB173_29
LBB173_22:
	mov	edi, ecx
	jmp	LBB173_29
LBB173_23:
	js	LBB173_25
	mov	dword [esi + 4], 1
	jmp	LBB173_29
LBB173_25:
	cmp	ecx, -1
	mov	eax, 5
	je	LBB173_27
	neg	ecx
	mov	eax, ecx
LBB173_27:
	mov	dword [errno], eax
LBB173_28:
	mov	dword [esi + 8], 1
LBB173_29:
	mov	byte [ebp + edi - 96], 0
	lea	eax, [ebp - 16]
	lea	ebx, [ebp - 96]
	cmp	dword [ebp + 16], 0
	je	LBB173_31
	push	dword [ebp + 12]
	push	eax
	push	ebx
	call	strtol
	jmp	LBB173_32
LBB173_31:
	push	dword [ebp + 12]
	push	eax
	push	ebx
	call	strtoul
LBB173_32:
	add	esp, 12
	mov	ecx, dword [ebp - 16]
	cmp	ecx, ebx
	je	LBB173_36
	mov	edx, dword [ebp - 28]
	mov	dword [edx], eax
	lea	eax, [ebp - 96]
	sub	ecx, eax
	cmp	ecx, edi
	jge	LBB173_35
	add	ecx, dword [ebp - 20]
	push	0
	push	ecx
	push	esi
	call	fseek
	add	esp, 12
	test	eax, eax
	js	LBB173_38
LBB173_35:
	mov	ebx, 1
	jmp	LBB173_39
LBB173_36:
	xor	ebx, ebx
	test	edi, edi
	je	LBB173_39
	push	0
	push	dword [ebp - 20]
	push	esi
	call	fseek
	add	esp, 12
	jmp	LBB173_39
Lfunc_end173:
align 16
is_persist_slot_compat_basename:
	mov	eax, -13
align 16
LBB174_1:
	cmp	byte [ecx + eax + 13], 0
	lea	eax, [eax + 1]
	jne	LBB174_1
	test	eax, eax
	je	LBB174_4
	xor	eax, eax
	ret
LBB174_4:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	movzx	edx, byte [ecx]
	test	edx, edx
	mov	eax, 100
	je	LBB174_38
	lea	esi, [edx - 91]
	cmp	esi, -26
	mov	esi, edx
	jb	LBB174_7
	lea	esi, [edx + 32]
LBB174_7:
	cmp	esi, 100
	jne	LBB174_39
	movzx	edx, byte [ecx + 1]
	test	edx, edx
	mov	eax, 111
	je	LBB174_38
	lea	esi, [edx - 91]
	cmp	esi, -26
	mov	esi, edx
	jb	LBB174_11
	lea	esi, [edx + 32]
LBB174_11:
	cmp	esi, 111
	jne	LBB174_39
	movzx	edx, byte [ecx + 2]
	test	edx, edx
	je	LBB174_38
	lea	esi, [edx - 91]
	cmp	esi, -26
	mov	esi, edx
	jb	LBB174_15
	lea	esi, [edx + 32]
LBB174_15:
	cmp	esi, 111
	jne	LBB174_39
	movzx	edx, byte [ecx + 3]
	test	edx, edx
	mov	eax, 109
	je	LBB174_38
	lea	esi, [edx - 91]
	cmp	esi, -26
	mov	esi, edx
	jb	LBB174_19
	lea	esi, [edx + 32]
LBB174_19:
	cmp	esi, 109
	jne	LBB174_39
	movzx	edx, byte [ecx + 4]
	test	edx, edx
	mov	eax, 115
	je	LBB174_38
	lea	esi, [edx - 91]
	cmp	esi, -26
	mov	esi, edx
	jb	LBB174_23
	lea	esi, [edx + 32]
LBB174_23:
	cmp	esi, 115
	jne	LBB174_39
	movzx	edx, byte [ecx + 5]
	test	edx, edx
	mov	eax, 97
	je	LBB174_38
	lea	esi, [edx - 91]
	cmp	esi, -26
	mov	esi, edx
	jb	LBB174_27
	lea	esi, [edx + 32]
LBB174_27:
	cmp	esi, 97
	jne	LBB174_39
	movzx	edx, byte [ecx + 6]
	test	edx, edx
	mov	eax, 118
	je	LBB174_38
	lea	esi, [edx - 91]
	cmp	esi, -26
	mov	esi, edx
	jb	LBB174_31
	lea	esi, [edx + 32]
LBB174_31:
	cmp	esi, 118
	jne	LBB174_39
	jmp	LBB174_42
LBB174_38:
	xor	edx, edx
LBB174_39:
	lea	esi, [edx - 91]
	cmp	esi, -26
	jb	LBB174_41
	add	edx, 32
LBB174_41:
	cmp	edx, eax
	jne	LBB174_53
LBB174_42:
	movzx	eax, byte [ecx + 7]
	add	al, -48
	cmp	al, 5
	ja	LBB174_53
	movzx	ebx, byte [ecx + 8]
	xor	esi, esi
	test	bl, bl
	je	LBB174_54
	add	ecx, 9
	mov	eax, L.str.35
align 16
LBB174_45:
	movzx	esi, bl
	lea	edi, [esi - 91]
	cmp	edi, -26
	mov	edi, esi
	jb	LBB174_47
	lea	edi, [esi + 32]
LBB174_47:
	movzx	ebx, byte [eax]
	lea	edx, [ebx - 91]
	cmp	edx, -26
	jb	LBB174_49
	add	ebx, 32
LBB174_49:
	cmp	edi, ebx
	jne	LBB174_55
	inc	eax
	movzx	ebx, byte [ecx]
	inc	ecx
	test	bl, bl
	jne	LBB174_45
	xor	esi, esi
	jmp	LBB174_55
LBB174_53:
	xor	eax, eax
	jmp	LBB174_60
LBB174_54:
	mov	eax, L.str.35
LBB174_55:
	lea	ecx, [esi - 91]
	cmp	ecx, -26
	jb	LBB174_57
	add	esi, 32
LBB174_57:
	movzx	ecx, byte [eax]
	lea	eax, [ecx - 91]
	cmp	eax, -26
	jb	LBB174_59
	add	ecx, 32
LBB174_59:
	xor	eax, eax
	cmp	esi, ecx
	sete	al
LBB174_60:
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
Lfunc_end174:
align 16
out_unsigned:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 64
	mov	dword [ebp - 28], edx
	mov	dword [ebp - 24], ecx
	mov	eax, dword [ebp + 24]
	mov	ecx, dword [ebp + 12]
	or	eax, ecx
	je	LBB175_6
	mov	edi, dword [ebp + 16]
	xor	ebx, ebx
	cmp	dword [ebp + 36], 0
	sete	bl
	shl	ebx, 5
	or	ebx, 65
	xor	esi, esi
	jmp	LBB175_4
align 16
LBB175_2:
	add	edx, ebx
	add	dl, -10
LBB175_3:
	mov	byte [ebp + esi - 73], dl
	inc	esi
	cmp	edi, ecx
	mov	ecx, eax
	ja	LBB175_7
LBB175_4:
	mov	eax, ecx
	xor	edx, edx
	div	edi
	cmp	edx, 10
	jae	LBB175_2
	or	dl, 48
	jmp	LBB175_3
LBB175_6:
	xor	esi, esi
LBB175_7:
	mov	ebx, dword [ebp + 32]
	mov	edi, dword [ebp + 20]
	mov	ecx, dword [ebp + 24]
	sub	ecx, esi
	jle	LBB175_9
	mov	edx, dword [ebp - 24]
	jmp	LBB175_14
LBB175_9:
	lea	eax, [esi + ebx]
	mov	ecx, edi
	sub	ecx, eax
	mov	eax, dword [ebp + 28]
	jg	LBB175_11
	xor	ecx, ecx
LBB175_11:
	test	eax, eax
	mov	edx, dword [ebp - 24]
	je	LBB175_13
	mov	eax, ecx
LBB175_13:
	mov	ecx, dword [ebp + 24]
	sar	ecx, 31
	and	ecx, eax
LBB175_14:
	lea	eax, [esi + ebx]
	mov	dword [ebp - 32], ecx
	add	eax, ecx
	mov	dword [ebp - 20], 0
	sub	edi, eax
	mov	dword [ebp - 40], edi
	mov	dword [ebp - 36], edi
	jg	LBB175_16
	mov	dword [ebp - 36], 0
LBB175_16:
	mov	ebx, dword [ebp + 8]
	cmp	dword [ebp + 40], 0
	mov	ecx, dword [ebp - 28]
	jne	LBB175_31
	cmp	dword [ebp - 36], 0
	jle	LBB175_31
	mov	edi, dword [ebp - 36]
	jmp	LBB175_21
align 16
LBB175_19:
	cmp	ecx, 1
	mov	ecx, dword [ebp - 28]
	mov	edx, dword [ebp - 24]
	mov	ebx, dword [ebp + 8]
	jne	LBB175_95
LBB175_20:
	dec	edi
	je	LBB175_30
LBB175_21:
	test	edx, edx
	mov	byte [ebp - 13], 32
	je	LBB175_24
	cmp	dword [ecx], 2
	jb	LBB175_20
	mov	eax, dword [edx]
	mov	byte [eax], 32
	inc	dword [edx]
	dec	dword [ecx]
	jmp	LBB175_20
align 16
LBB175_24:
	test	ebx, ebx
	js	LBB175_20
	mov	eax, 4
	lea	ecx, [ebp - 13]
	mov	edx, 1
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB175_91
	cmp	dword [ebp + 8], 31
	ja	LBB175_19
	mov	eax, dword [ebp + 8]
	cmp	byte [eax + tracked_persist_fd], 0
	je	LBB175_19
	movzx	ebx, byte [eax + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB175_19
	shl	ebx, 16
	or	ebx, 536870916
	mov	eax, 15
	xor	edx, edx
	int	128
	jmp	LBB175_19
LBB175_30:
	mov	eax, dword [ebp - 40]
	test	eax, eax
	mov	dword [ebp - 20], eax
	js	LBB175_95
LBB175_31:
	cmp	dword [ebp + 32], 0
	je	LBB175_43
	mov	byte [ebp - 13], 45
	test	edx, edx
	je	LBB175_35
	cmp	dword [ecx], 2
	jb	LBB175_42
	mov	eax, dword [edx]
	mov	byte [eax], 45
	inc	dword [edx]
	dec	dword [ecx]
	jmp	LBB175_42
LBB175_35:
	test	ebx, ebx
	js	LBB175_42
	lea	ecx, [ebp - 13]
	mov	eax, 4
	mov	edx, 1
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB175_91
	cmp	ebx, 31
	ja	LBB175_41
	mov	eax, dword [ebp + 8]
	cmp	byte [eax + tracked_persist_fd], 0
	je	LBB175_41
	movzx	ebx, byte [eax + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB175_41
	shl	ebx, 16
	or	ebx, 536870916
	mov	eax, 15
	xor	edx, edx
	int	128
LBB175_41:
	cmp	ecx, 1
	mov	ecx, dword [ebp - 28]
	mov	edx, dword [ebp - 24]
	mov	ebx, dword [ebp + 8]
	jne	LBB175_95
LBB175_42:
	inc	dword [ebp - 20]
LBB175_43:
	mov	edi, dword [ebp - 32]
	test	edi, edi
	jg	LBB175_49
	mov	dword [ebp - 32], 0
LBB175_45:
	test	esi, esi
	je	LBB175_69
	mov	eax, dword [ebp - 20]
	add	eax, esi
	add	eax, dword [ebp - 32]
	mov	dword [ebp - 20], eax
	jmp	LBB175_60
align 16
LBB175_47:
	cmp	ecx, 1
	mov	ecx, dword [ebp - 28]
	mov	edx, dword [ebp - 24]
	mov	ebx, dword [ebp + 8]
	jne	LBB175_95
LBB175_48:
	dec	edi
	je	LBB175_45
LBB175_49:
	test	edx, edx
	mov	byte [ebp - 13], 48
	je	LBB175_52
	cmp	dword [ecx], 2
	jb	LBB175_48
	mov	eax, dword [edx]
	mov	byte [eax], 48
	inc	dword [edx]
	dec	dword [ecx]
	jmp	LBB175_48
align 16
LBB175_52:
	test	ebx, ebx
	js	LBB175_48
	mov	eax, 4
	lea	ecx, [ebp - 13]
	mov	edx, 1
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB175_91
	cmp	dword [ebp + 8], 31
	ja	LBB175_47
	mov	eax, dword [ebp + 8]
	cmp	byte [eax + tracked_persist_fd], 0
	je	LBB175_47
	movzx	ebx, byte [eax + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB175_47
	shl	ebx, 16
	or	ebx, 536870916
	mov	eax, 15
	xor	edx, edx
	int	128
	jmp	LBB175_47
align 16
LBB175_58:
	cmp	ecx, 1
	mov	ecx, dword [ebp - 28]
	mov	edx, dword [ebp - 24]
	mov	ebx, dword [ebp + 8]
	jne	LBB175_95
LBB175_59:
	dec	esi
	je	LBB175_70
LBB175_60:
	test	edx, edx
	movzx	eax, byte [ebp + esi - 74]
	mov	byte [ebp - 13], al
	je	LBB175_63
	cmp	dword [ecx], 2
	jb	LBB175_59
	mov	edi, ecx
	mov	ecx, dword [edx]
	mov	byte [ecx], al
	mov	ecx, edi
	mov	ebx, dword [ebp + 8]
	inc	dword [edx]
	dec	dword [edi]
	jmp	LBB175_59
align 16
LBB175_63:
	test	ebx, ebx
	js	LBB175_59
	mov	eax, 4
	lea	ecx, [ebp - 13]
	mov	edx, 1
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB175_91
	cmp	ebx, 31
	ja	LBB175_58
	mov	eax, dword [ebp + 8]
	cmp	byte [eax + tracked_persist_fd], 0
	je	LBB175_58
	movzx	ebx, byte [eax + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB175_58
	shl	ebx, 16
	or	ebx, 536870916
	mov	eax, 15
	xor	edx, edx
	int	128
	jmp	LBB175_58
LBB175_69:
	mov	eax, dword [ebp - 32]
	add	dword [ebp - 20], eax
LBB175_70:
	cmp	dword [ebp + 40], 0
	mov	esi, dword [ebp - 36]
	je	LBB175_86
	test	esi, esi
	jg	LBB175_75
LBB175_86:
	mov	eax, dword [ebp - 20]
	jmp	LBB175_96
align 16
LBB175_73:
	cmp	ecx, 1
	mov	ecx, dword [ebp - 28]
	mov	edx, dword [ebp - 24]
	mov	ebx, dword [ebp + 8]
	jne	LBB175_95
LBB175_74:
	dec	esi
	je	LBB175_84
LBB175_75:
	test	edx, edx
	mov	byte [ebp - 13], 32
	je	LBB175_78
	cmp	dword [ecx], 2
	jb	LBB175_74
	mov	eax, dword [edx]
	mov	byte [eax], 32
	inc	dword [edx]
	dec	dword [ecx]
	jmp	LBB175_74
align 16
LBB175_78:
	test	ebx, ebx
	js	LBB175_74
	mov	eax, 4
	lea	ecx, [ebp - 13]
	mov	edx, 1
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB175_91
	cmp	ebx, 31
	ja	LBB175_73
	mov	eax, dword [ebp + 8]
	cmp	byte [eax + tracked_persist_fd], 0
	je	LBB175_73
	movzx	ebx, byte [eax + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB175_73
	shl	ebx, 16
	or	ebx, 536870916
	mov	eax, 15
	xor	edx, edx
	int	128
	jmp	LBB175_73
LBB175_91:
	jns	LBB175_95
	cmp	ecx, -1
	mov	eax, 5
	je	LBB175_94
	neg	ecx
	mov	eax, ecx
LBB175_94:
	mov	dword [errno], eax
	jmp	LBB175_95
LBB175_84:
	mov	ecx, dword [ebp - 40]
	test	ecx, ecx
	js	LBB175_95
	mov	eax, dword [ebp - 20]
	add	eax, ecx
	jmp	LBB175_96
LBB175_95:
	mov	eax, -1
LBB175_96:
	add	esp, 64
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
Lfunc_end175:
align 16
unsupported_format:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	esi
	push	eax
	movzx	ebx, byte [ebp + 12]
	mov	byte [ebp - 9], 37
	test	ecx, ecx
	je	LBB176_5
	cmp	dword [edx], 1
	jbe	LBB176_19
	mov	eax, dword [ecx]
	mov	byte [eax], 37
	inc	dword [ecx]
	mov	eax, dword [edx]
	dec	eax
	mov	dword [edx], eax
	test	bl, bl
	je	LBB176_20
	cmp	eax, 2
	jb	LBB176_22
	mov	eax, dword [ecx]
	mov	byte [eax], bl
	inc	dword [ecx]
	dec	dword [edx]
	jmp	LBB176_22
LBB176_5:
	mov	esi, dword [ebp + 8]
	test	esi, esi
	js	LBB176_19
	lea	ecx, [ebp - 9]
	mov	eax, 4
	mov	ebx, esi
	mov	edx, 1
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB176_23
	cmp	esi, 31
	ja	LBB176_11
	cmp	byte [esi + tracked_persist_fd], 0
	je	LBB176_11
	movzx	ebx, byte [esi + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB176_11
	shl	ebx, 16
	or	ebx, 536870916
	mov	eax, 15
	xor	edx, edx
	int	128
LBB176_11:
	cmp	ecx, 1
	jne	LBB176_27
	movzx	eax, byte [ebp + 12]
	test	al, al
	je	LBB176_20
	mov	byte [ebp - 10], al
	lea	ecx, [ebp - 10]
	mov	eax, 4
	mov	ebx, esi
	mov	edx, 1
	int	128
	mov	ecx, eax
	test	eax, eax
	jle	LBB176_23
	cmp	esi, 31
	ja	LBB176_18
	cmp	byte [esi + tracked_persist_fd], 0
	je	LBB176_18
	movzx	ebx, byte [esi + tracked_persist_slot]
	cmp	ebx, 5
	ja	LBB176_18
	shl	ebx, 16
	or	ebx, 536870916
	mov	eax, 15
	xor	edx, edx
	int	128
LBB176_18:
	cmp	ecx, 1
	je	LBB176_22
	jmp	LBB176_27
LBB176_19:
	test	bl, bl
	je	LBB176_20
LBB176_22:
	mov	eax, 2
	jmp	LBB176_28
LBB176_20:
	mov	eax, 1
	jmp	LBB176_28
LBB176_23:
	jns	LBB176_27
	cmp	ecx, -1
	mov	eax, 5
	je	LBB176_26
	neg	ecx
	mov	eax, ecx
LBB176_26:
	mov	dword [errno], eax
LBB176_27:
	mov	eax, -1
LBB176_28:
	add	esp, 4
	pop	esi
	pop	ebx
	pop	ebp
	ret
Lfunc_end176:
section .data
global stdin
align 4
stdin:
dd stdin_file
global stdout
align 4
stdout:
dd stdout_file
global stderr
align 4
stderr:
dd stderr_file
global environ
align 4
environ:
dd empty_environment
section .rodata
L.str:
db `Operation not permitted`, 0
L.str.1:
db `No such file or directory`, 0
L.str.2:
db `I/O error`, 0
L.str.3:
db `Bad file descriptor`, 0
L.str.4:
db `No child processes`, 0
L.str.5:
db `Out of memory`, 0
L.str.6:
db `Permission denied`, 0
L.str.7:
db `Not a directory`, 0
L.str.8:
db `Is a directory`, 0
L.str.9:
db `Invalid argument`, 0
L.str.10:
db `Too many open files`, 0
L.str.11:
db `Inappropriate ioctl for device`, 0
L.str.12:
db `No space left on device`, 0
L.str.13:
db `Result out of range`, 0
L.str.14:
db `Function not implemented`, 0
L.str.15:
db `Value too large`, 0
L.str.16:
db `Unknown error`, 0
section .bss
global errno
alignb 4
errno:
resd 1
section .rodata
L.str.17:
db `HOME`, 0
L.str.18:
db `/`, 0
L.str.19:
db `DOOMWADDIR`, 0
L.str.20:
db `.`, 0
section .data
align 4
rand_state:
dd 1
section .rodata
L.str.21:
db `: `, 0
section .data
align 4
stdin_file:
dd 0
dd 0
dd 0
dd 1
dd 1
dd 0
dd 0
dd 0
dd 0
db 0
times 4096 db 0
times 3 db 0
align 4
stdout_file:
dd 1
dd 0
dd 0
dd 1
dd 0
dd 1
dd 0
dd 0
dd 0
db 0
times 4096 db 0
times 3 db 0
align 4
stderr_file:
dd 2
dd 0
dd 0
dd 1
dd 0
dd 1
dd 0
dd 0
dd 0
db 0
times 4096 db 0
times 3 db 0
mapped_path.compat_persist_slot_path:
db `doomsav0.dsg`, 0
section .rodata
L.str.25:
db `doom1.wad`, 0
L.str.26:
db `DOOM1.WAD`, 0
L.str.27:
db `payload0.elf`, 0
L.str.28:
db `PAYLOAD0.ELF`, 0
L.str.29:
db `userprob.elf`, 0
L.str.30:
db `USERPROB.ELF`, 0
L.str.31:
db `.doomrc`, 0
L.str.32:
db `default.cfg`, 0
L.str.33:
db `DEFAULT.CFG`, 0
L.str.35:
db `.dsg`, 0
L.str.36:
db `c:\\doomdata`, 0
L.str.37:
db `c:/doomdata`, 0
L.str.38:
db `doomdata`, 0
L.str.39:
db `(null)`, 0

section .bss
alignb 4
empty_environment resb 4
alignb 4
strtok.next_token resb 4
alignb 4
file_pool resb 16544
alignb 4
alloc_head resb 4
alignb 4
alloc_tail resb 4
tracked_persist_fd resb 32
tracked_persist_slot resb 32
