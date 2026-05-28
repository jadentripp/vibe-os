BITS 32
section .text
global user_main
align 16
user_main:
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	and	esp, -8
	sub	esp, 176
	mov	esi, dword [ebp + 12]
	mov	edi, dword [ebp + 8]
	mov	word [esp + 120], 10
	mov	dword [esp + 116], 1700949874
	mov	dword [esp + 112], 1881162528
	mov	dword [esp + 108], 1919251317
	mov	word [esp + 96], 68
	mov	dword [esp + 92], 1096232497
	mov	dword [esp + 88], 1297043268
	mov	byte [esp + 48], 0
	mov	dword [esp + 44], 1179403566
	mov	dword [esp + 40], 1161973586
	mov	dword [esp + 36], 1346978369
	mov	dword [esp + 60], 5461061
	mov	dword [esp + 56], 1397965103
	mov	dword [esp + 83], 5527636
	mov	dword [esp + 80], 1412318541
	mov	dword [esp + 76], 1145128274
	mov	dword [esp + 72], 793990213
	mov	dword [esp + 68], 1397965103
	mov	dword [esp + 167], 5527636
	mov	dword [esp + 164], 1412318541
	mov	dword [esp + 160], 1145128274
	mov	dword [esp + 156], 792876371
	mov	dword [esp + 152], 793990213
	mov	dword [esp + 148], 1397965103
	mov	dword [esp + 144], 4671043
	mov	dword [esp + 140], 777276501
	mov	dword [esp + 136], 1095124292
	mov	dword [esp + 16], 682863
	mov	dword [esp + 12], 762606441
	mov	dword [esp + 8], 1936876912
	lea	eax, [esp + 36]
	mov	dword [esp + 100], eax
	mov	dword [esp + 104], 0
	mov	eax, dword [L__const.user_main.abi_probe_envp+8]
	mov	dword [esp + 132], eax
	mov	eax, dword [L__const.user_main.abi_probe_envp+4]
	mov	dword [esp + 128], eax
	mov	eax, dword [L__const.user_main.abi_probe_envp]
	mov	dword [esp + 124], eax
	mov	dword [esp], 0
	mov	eax, 25
	xor	ebx, ebx
	xor	ecx, ecx
	xor	edx, edx
	int	128
	cmp	edi, 1
	setne	cl
	test	esi, esi
	sete	dl
	or	dl, cl
	jne	LBB0_12
	mov	edi, dword [esi]
	test	edi, edi
	je	LBB0_12
	movzx	edx, byte [edi]
	mov	dword [esp], 0
	test	dl, dl
	je	LBB0_6
	inc	edi
	mov	ecx, L.str.2
align 16
LBB0_4:
	cmp	dl, byte [ecx]
	jne	LBB0_8
	inc	ecx
	movzx	edx, byte [edi]
	inc	edi
	test	dl, dl
	jne	LBB0_4
	jmp	LBB0_7
LBB0_6:
	mov	ecx, L.str.2
LBB0_7:
	xor	edx, edx
LBB0_8:
	cmp	dl, byte [ecx]
	jne	LBB0_12
	mov	ecx, dword [ebp + 16]
	test	ecx, ecx
	je	LBB0_12
	cmp	dword [esi + 4], 0
	jne	LBB0_12
	cmp	dword [ecx], 0
	sete	cl
	test	eax, eax
	setg	al
	and	al, cl
	movzx	eax, al
	shl	eax, 11
	mov	dword [esp], eax
LBB0_12:
	lea	ecx, [esp + 108]
	mov	eax, 4
	mov	ebx, 1
	mov	edx, 13
	int	128
	xor	ecx, ecx
	cmp	eax, 13
	sete	cl
	mov	edi, ecx
	mov	eax, 5
	mov	ebx, 64
	xor	ecx, ecx
	xor	edx, edx
	int	128
	mov	esi, eax
	test	eax, eax
	jg	LBB0_14
	or	dword [esp], edi
	jmp	LBB0_15
LBB0_14:
	mov	eax, dword [esp]
	lea	eax, [eax + edi + 2]
	mov	dword [esp], eax
LBB0_15:
	mov	eax, 5
	mov	ebx, 4096
	xor	ecx, ecx
	xor	edx, edx
	int	128
	test	eax, eax
	jle	LBB0_19
	mov	edi, eax
	mov	eax, 5
	mov	ebx, -4096
	xor	ecx, ecx
	xor	edx, edx
	int	128
	mov	ecx, eax
	test	eax, eax
	setns	al
	add	edi, 4096
	cmp	edi, ecx
	sete	dl
	and	dl, al
	cmp	dl, 1
	jne	LBB0_19
	mov	eax, 4
	mov	ebx, 1
	mov	edx, 1
	int	128
	cmp	eax, -22
	jne	LBB0_19
	add	dword [esp], 32768
LBB0_19:
	test	esi, esi
	setle	byte [esp + 4]
	lea	ebx, [esp + 88]
	mov	eax, 6
	xor	ecx, ecx
	xor	edx, edx
	int	128
	mov	ebx, eax
	test	eax, eax
	sets	al
	mov	esi, dword [esp]
	or	esi, 4
	or	al, byte [esp + 4]
	jne	LBB0_23
	mov	eax, 7
	mov	ecx, user_main.header
	mov	edx, 12
	int	128
	cmp	eax, 12
	jne	LBB0_24
	cmp	dword [user_main.header], 1145132873
	jne	LBB0_24
	mov	esi, dword [esp]
	or	esi, 12
	jmp	LBB0_24
LBB0_23:
	test	ebx, ebx
	js	LBB0_27
LBB0_24:
	mov	eax, 8
	mov	ecx, 4
	xor	edx, edx
	int	128
	cmp	eax, 4
	jne	LBB0_26
	or	esi, 16
LBB0_26:
	mov	dword [esp], esi
LBB0_27:
	mov	eax, 30
	mov	ebx, L.str.3
	mov	ecx, user_main.root_entries
	mov	edx, 16
	int	128
	mov	dword [esp + 64], eax
	test	eax, eax
	jle	LBB0_103
	mov	dword [esp + 28], 0
	mov	eax, user_main.root_entries+1
	mov	dword [esp + 24], 0
	mov	dword [esp + 20], 0
	mov	dword [esp + 32], 0
	xor	esi, esi
	jmp	LBB0_31
align 16
LBB0_29:
	mov	dword [esp + 32], ecx
LBB0_30:
	mov	esi, dword [esp + 4]
	inc	esi
	add	eax, 32
	cmp	esi, dword [esp + 64]
	je	LBB0_78
LBB0_31:
	mov	dword [esp + 4], esi
	shl	esi, 5
	movzx	edx, byte [esi + user_main.root_entries]
	mov	edi, L.str.4
	test	dl, dl
	je	LBB0_35
	mov	ecx, eax
	mov	ebx, edx
align 16
LBB0_33:
	cmp	bl, byte [edi]
	jne	LBB0_36
	inc	edi
	movzx	ebx, byte [ecx]
	inc	ecx
	test	bl, bl
	jne	LBB0_33
LBB0_35:
	xor	ebx, ebx
LBB0_36:
	lea	esi, [esi + user_main.root_entries]
	cmp	bl, byte [edi]
	jne	LBB0_42
	cmp	dword [esi + 16], 5
	jb	LBB0_42
	test	byte [esi + 21], -128
	je	LBB0_42
	cmp	dword [esi + 24], 2
	mov	ecx, 1
	jae	LBB0_41
	mov	ecx, dword [esp + 28]
LBB0_41:
	mov	dword [esp + 28], ecx
align 16
LBB0_42:
	xor	edi, edi
	test	dl, dl
	je	LBB0_47
	mov	ebx, edx
align 16
LBB0_44:
	cmp	bl, byte [edi + L.str.2]
	jne	LBB0_49
	movzx	ebx, byte [eax + edi]
	inc	edi
	test	bl, bl
	jne	LBB0_44
	lea	ecx, [edi + L.str.2]
	jmp	LBB0_48
align 16
LBB0_47:
	mov	ecx, L.str.2
LBB0_48:
	xor	ebx, ebx
	cmp	bl, byte [ecx]
	je	LBB0_50
	jmp	LBB0_55
align 16
LBB0_49:
	lea	ecx, [edi + L.str.2]
	cmp	bl, byte [ecx]
	jne	LBB0_55
LBB0_50:
	cmp	dword [esi + 16], 5
	jb	LBB0_55
	test	byte [esi + 21], -128
	je	LBB0_55
	cmp	dword [esi + 24], 2
	mov	ecx, 1
	jae	LBB0_54
	mov	ecx, dword [esp + 24]
LBB0_54:
	mov	dword [esp + 24], ecx
align 16
LBB0_55:
	xor	edi, edi
	test	dl, dl
	je	LBB0_60
	mov	ebx, edx
align 16
LBB0_57:
	cmp	bl, byte [esp + edi + 36]
	jne	LBB0_62
	movzx	ebx, byte [eax + edi]
	inc	edi
	test	bl, bl
	jne	LBB0_57
	lea	ecx, [esp + edi + 36]
	jmp	LBB0_61
align 16
LBB0_60:
	lea	ecx, [esp + 36]
LBB0_61:
	xor	ebx, ebx
	cmp	bl, byte [ecx]
	je	LBB0_63
	jmp	LBB0_68
align 16
LBB0_62:
	lea	ecx, [esp + edi + 36]
	cmp	bl, byte [ecx]
	jne	LBB0_68
LBB0_63:
	cmp	dword [esi + 16], 5
	jb	LBB0_68
	test	byte [esi + 21], -128
	je	LBB0_68
	cmp	dword [esi + 24], 2
	mov	ecx, 1
	jae	LBB0_67
	mov	ecx, dword [esp + 20]
LBB0_67:
	mov	dword [esp + 20], ecx
align 16
LBB0_68:
	xor	edi, edi
	test	dl, dl
	je	LBB0_72
align 16
LBB0_69:
	cmp	dl, byte [edi + L.str.5]
	jne	LBB0_74
	movzx	edx, byte [eax + edi]
	inc	edi
	test	dl, dl
	jne	LBB0_69
	lea	ecx, [edi + L.str.5]
	jmp	LBB0_73
align 16
LBB0_72:
	mov	ecx, L.str.5
LBB0_73:
	xor	edx, edx
	cmp	dl, byte [ecx]
	jne	LBB0_30
	jmp	LBB0_75
align 16
LBB0_74:
	lea	ecx, [edi + L.str.5]
	cmp	dl, byte [ecx]
	jne	LBB0_30
LBB0_75:
	test	byte [esi + 21], 64
	je	LBB0_30
	cmp	dword [esi + 24], 2
	mov	ecx, 1
	jae	LBB0_29
	mov	ecx, dword [esp + 32]
	jmp	LBB0_29
LBB0_78:
	lea	ebx, [esp + 56]
	mov	eax, 30
	mov	ecx, user_main.asset_entries
	mov	edx, 4
	int	128
	mov	esi, eax
	lea	ebx, [esp + 68]
	mov	eax, 6
	xor	ecx, ecx
	xor	edx, edx
	int	128
	mov	edi, eax
	xor	ecx, ecx
	test	esi, esi
	jle	LBB0_94
	movzx	eax, byte [user_main.asset_entries]
	xor	ecx, ecx
	test	al, al
	je	LBB0_83
align 16
LBB0_80:
	cmp	al, byte [ecx + L.str.6]
	jne	LBB0_91
	movzx	eax, byte [ecx + user_main.asset_entries+1]
	inc	ecx
	test	al, al
	jne	LBB0_80
	lea	ecx, [ecx + L.str.6]
	jmp	LBB0_84
LBB0_83:
	mov	ecx, L.str.6
LBB0_84:
	xor	eax, eax
	cmp	al, byte [ecx]
	jne	LBB0_93
	jmp	LBB0_85
LBB0_91:
	lea	ecx, [ecx + L.str.6]
	cmp	al, byte [ecx]
	jne	LBB0_93
LBB0_85:
	movzx	eax, byte [user_main.asset_entries+21]
	shr	al, 7
	test	edi, edi
	setns	cl
	and	cl, al
	cmp	cl, 1
	jne	LBB0_93
	mov	eax, 7
	mov	ebx, edi
	mov	ecx, user_main.readback
	mov	edx, 35
	int	128
	cmp	eax, 35
	jne	LBB0_118
	movzx	eax, byte [user_main.readback]
	xor	ecx, ecx
	test	al, al
	je	LBB0_119
align 16
LBB0_88:
	cmp	al, byte [ecx + L__const.user_main.asset_payload]
	jne	LBB0_120
	movzx	eax, byte [ecx + user_main.readback+1]
	inc	ecx
	test	al, al
	jne	LBB0_88
	lea	ecx, [ecx + L__const.user_main.asset_payload]
	xor	eax, eax
	jmp	LBB0_121
LBB0_118:
	xor	ecx, ecx
	jmp	LBB0_95
LBB0_119:
	mov	ecx, L__const.user_main.asset_payload
	xor	eax, eax
	jmp	LBB0_121
LBB0_120:
	lea	ecx, [ecx + L__const.user_main.asset_payload]
LBB0_121:
	cmp	al, byte [ecx]
	jne	LBB0_93
	mov	eax, 8
	mov	ebx, edi
	mov	ecx, -5
	mov	edx, 2
	int	128
	cmp	eax, 30
	jne	LBB0_93
	mov	eax, 7
	mov	ebx, edi
	mov	ecx, user_main.readback
	mov	edx, 5
	int	128
	xor	ecx, ecx
	cmp	eax, 5
	jne	LBB0_94
	cmp	byte [user_main.readback], 102
	jne	LBB0_94
	cmp	byte [user_main.readback+1], 105
	jne	LBB0_94
	cmp	byte [user_main.readback+2], 108
	jne	LBB0_94
	cmp	byte [user_main.readback+3], 101
	jne	LBB0_94
	cmp	byte [user_main.readback+4], 10
	jne	LBB0_94
	lea	ebx, [esp + 68]
	mov	eax, 18
	mov	ecx, user_main.statbuf
	xor	edx, edx
	int	128
	xor	ecx, ecx
	test	eax, eax
	jne	LBB0_94
	cmp	dword [user_main.statbuf+28], 35
	jne	LBB0_94
	test	byte [user_main.statbuf+9], -128
	jne	LBB0_227
LBB0_93:
	xor	ecx, ecx
LBB0_94:
	test	edi, edi
	js	LBB0_96
LBB0_95:
	mov	eax, 12
	mov	ebx, edi
	mov	esi, ecx
	xor	ecx, ecx
	xor	edx, edx
	int	128
	mov	ecx, esi
LBB0_96:
	cmp	dword [esp + 28], 0
	je	LBB0_103
	cmp	dword [esp + 24], 0
	je	LBB0_103
	cmp	dword [esp + 20], 0
	je	LBB0_103
	cmp	dword [esp + 32], 0
	je	LBB0_103
	test	cl, cl
	je	LBB0_103
	mov	eax, 30
	mov	ebx, L.str.7
	mov	ecx, user_main.root_entries
	mov	edx, 1
	int	128
	cmp	eax, -22
	jne	LBB0_103
	add	dword [esp], 65536
LBB0_103:
	lea	ebx, [esp + 136]
	mov	eax, 6
	mov	ecx, 770
	mov	edx, 438
	int	128
	test	eax, eax
	js	LBB0_149
	mov	edi, eax
	lea	ecx, [esp + 8]
	mov	eax, 4
	mov	ebx, edi
	mov	edx, 11
	int	128
	cmp	eax, 11
	jne	LBB0_109
	mov	eax, 8
	mov	ebx, edi
	xor	ecx, ecx
	xor	edx, edx
	int	128
	test	eax, eax
	jne	LBB0_109
	mov	eax, 7
	mov	ebx, edi
	mov	ecx, user_main.readback
	mov	edx, 11
	int	128
	cmp	eax, 11
	jne	LBB0_109
	movzx	eax, byte [esp + 8]
	movzx	ecx, byte [esp + 9]
	xor	al, byte [user_main.readback]
	xor	cl, byte [user_main.readback+1]
	or	cl, al
	movzx	edx, byte [esp + 10]
	xor	dl, byte [user_main.readback+2]
	movzx	eax, byte [esp + 11]
	xor	al, byte [user_main.readback+3]
	or	al, dl
	or	al, cl
	movzx	ecx, byte [esp + 12]
	xor	cl, byte [user_main.readback+4]
	movzx	edx, byte [esp + 13]
	xor	dl, byte [user_main.readback+5]
	or	dl, cl
	movzx	ecx, byte [esp + 14]
	xor	cl, byte [user_main.readback+6]
	or	cl, dl
	or	cl, al
	movzx	eax, byte [esp + 15]
	xor	al, byte [user_main.readback+7]
	movzx	edx, byte [esp + 16]
	xor	dl, byte [user_main.readback+8]
	or	dl, al
	or	dl, cl
	movzx	eax, byte [esp + 17]
	xor	al, byte [user_main.readback+9]
	movzx	ecx, byte [user_main.readback+10]
	xor	cl, byte [esp + 18]
	or	cl, al
	or	cl, dl
	jne	LBB0_109
	or	dword [esp], 64
LBB0_109:
	mov	eax, 27
	mov	ebx, edi
	mov	ecx, 4
	xor	edx, edx
	int	128
	test	eax, eax
	jne	LBB0_139
	mov	eax, 8
	mov	ebx, edi
	mov	ecx, -2
	mov	edx, 2
	int	128
	cmp	eax, 2
	jne	LBB0_139
	mov	eax, 7
	mov	ebx, edi
	mov	ecx, user_main.readback
	int	128
	cmp	eax, 2
	jne	LBB0_139
	cmp	byte [user_main.readback], 114
	jne	LBB0_139
	cmp	byte [user_main.readback+1], 115
	jne	LBB0_139
	mov	eax, 27
	mov	ebx, edi
	mov	ecx, 8
	xor	edx, edx
	int	128
	test	eax, eax
	jne	LBB0_139
	mov	eax, 8
	mov	ebx, edi
	mov	ecx, 4
	xor	edx, edx
	int	128
	cmp	eax, 4
	jne	LBB0_139
	mov	eax, 7
	mov	ebx, edi
	mov	ecx, user_main.readback
	mov	edx, 4
	int	128
	movzx	ecx, byte [user_main.readback+3]
	or	cl, byte [user_main.readback+2]
	or	cl, byte [user_main.readback+1]
	or	cl, byte [user_main.readback]
	je	LBB0_135
	mov	ecx, dword [esp]
	jmp	LBB0_136
LBB0_135:
	mov	ecx, dword [esp]
	or	ecx, 16384
LBB0_136:
	cmp	eax, 4
	je	LBB0_138
	mov	ecx, dword [esp]
LBB0_138:
	mov	dword [esp], ecx
LBB0_139:
	mov	eax, 8
	mov	ebx, edi
	xor	ecx, ecx
	xor	edx, edx
	int	128
	test	eax, eax
	je	LBB0_183
LBB0_140:
	mov	eax, 12
	mov	ebx, 8
	xor	ecx, ecx
	xor	edx, edx
	int	128
LBB0_141:
	mov	eax, 35
	mov	ebx, edi
	mov	ecx, 1
	xor	edx, edx
	int	128
	test	eax, eax
	jne	LBB0_149
	mov	eax, 35
	mov	ebx, edi
	mov	ecx, 2
	mov	edx, 1
	int	128
	test	eax, eax
	jne	LBB0_149
	mov	eax, 35
	mov	ebx, edi
	mov	ecx, 1
	xor	edx, edx
	int	128
	cmp	eax, 1
	jne	LBB0_149
	mov	eax, 35
	mov	ebx, edi
	mov	ecx, 2
	xor	edx, edx
	int	128
	test	eax, eax
	jne	LBB0_149
	mov	eax, 35
	mov	ebx, edi
	mov	ecx, 1
	xor	edx, edx
	int	128
	test	eax, eax
	jne	LBB0_149
	mov	eax, 35
	mov	ebx, edi
	mov	ecx, 2
	mov	edx, 17
	int	128
	cmp	eax, -22
	jne	LBB0_149
	mov	eax, 35
	mov	ebx, 99
	mov	ecx, 1
	xor	edx, edx
	int	128
	cmp	eax, -9
	jne	LBB0_149
	add	dword [esp], 262144
LBB0_149:
	mov	eax, 20
	xor	ebx, ebx
	mov	ecx, 8192
	mov	edx, 2228227
	int	128
	mov	byte [esp + 4], 1
	test	eax, eax
	jle	LBB0_153
	mov	esi, eax
	mov	byte [eax], 120
	mov	byte [eax + 4096], 121
	mov	eax, 21
	mov	ebx, esi
	mov	ecx, 4096
	xor	edx, edx
	int	128
	test	eax, eax
	jne	LBB0_153
	mov	eax, 4
	mov	ebx, 1
	mov	ecx, esi
	mov	edx, 1
	int	128
	cmp	eax, -22
	jne	LBB0_153
	add	esi, 4096
	mov	eax, 21
	mov	ebx, esi
	mov	ecx, 4096
	xor	edx, edx
	int	128
	test	eax, eax
	setne	byte [esp + 4]
LBB0_153:
	mov	eax, 20
	xor	ebx, ebx
	mov	ecx, 64768
	mov	edx, 2228227
	int	128
	mov	edi, eax
	xor	eax, eax
	test	edi, edi
	jle	LBB0_172
align 16
LBB0_154:
	mov	byte [edi + eax], al
	inc	eax
	cmp	eax, 64000
	jne	LBB0_154
	mov	esi, edi
	add	esi, 64000
	xor	eax, eax
	mov	ecx, -768
	mov	dl, -1
align 16
LBB0_156:
	mov	byte [edi + ecx + 64768], al
	mov	byte [edi + ecx + 64769], dl
	mov	ebx, eax
	shr	ebx, 1
	mov	byte [edi + ecx + 64770], bl
	inc	eax
	dec	dl
	add	ecx, 3
	jne	LBB0_156
	mov	eax, 10
	mov	ebx, edi
	mov	ecx, esi
	xor	edx, edx
	int	128
	test	eax, eax
	jne	LBB0_159
	or	dword [esp], 32
LBB0_159:
	mov	eax, 22
	mov	ebx, 1
	mov	ecx, 22017
	mov	edx, user_main.fbinfo
	int	128
	test	eax, eax
	jne	LBB0_167
	cmp	dword [user_main.fbinfo+16], 64000
	jne	LBB0_167
	cmp	dword [user_main.fbinfo+20], 768
	jne	LBB0_167
	cmp	dword [user_main.fbinfo+76], 320
	jne	LBB0_167
	cmp	dword [user_main.fbinfo+80], 200
	jne	LBB0_167
	cmp	dword [user_main.fbinfo+72], 1
	jne	LBB0_167
	mov	eax, dword [user_main.fbinfo+68]
	not	eax
	test	al, 35
	jne	LBB0_167
	or	dword [esp], 256
LBB0_167:
	mov	dword [user_main.present], edi
	mov	dword [user_main.present+4], esi
	mov	dword [user_main.present+8], 320
	mov	dword [user_main.present+12], 200
	mov	eax, 22
	mov	ecx, 22018
	mov	edx, user_main.present
	int	128
	test	eax, eax
	jne	LBB0_169
	or	dword [esp], 512
LBB0_169:
	cmp	byte [esp + 4], 0
	jne	LBB0_172
	mov	eax, 21
	mov	ebx, edi
	mov	ecx, 64768
	xor	edx, edx
	int	128
	test	eax, eax
	jne	LBB0_172
	or	dword [esp], 128
LBB0_172:
	mov	dword [esp + 52], 0
	lea	ecx, [esp + 52]
	mov	eax, 24
	mov	ebx, -1
	mov	edx, 1
	int	128
	cmp	eax, 3
	jne	LBB0_176
	cmp	dword [esp + 52], 42
	jne	LBB0_176
	mov	eax, 24
	xor	ecx, ecx
	int	128
	cmp	eax, -10
	jne	LBB0_176
	or	dword [esp], 9216
LBB0_176:
	mov	eax, 2147483647
	xor	ebx, ebx
	xor	ecx, ecx
	xor	edx, edx
	int	128
	cmp	eax, -38
	jne	LBB0_182
	mov	eax, 20
	xor	ebx, ebx
	xor	ecx, ecx
	mov	edx, 2228227
	int	128
	cmp	eax, -22
	jne	LBB0_182
	mov	eax, 20
	xor	ebx, ebx
	mov	ecx, 4096
	mov	edx, 3276803
	int	128
	cmp	eax, -22
	jne	LBB0_182
	mov	eax, 21
	xor	ebx, ebx
	xor	edx, edx
	int	128
	cmp	eax, -22
	jne	LBB0_182
	mov	eax, 24
	mov	ebx, -1
	mov	ecx, 65536
	xor	edx, edx
	int	128
	cmp	eax, -22
	jne	LBB0_182
	or	dword [esp], 4096
LBB0_182:
	mov	eax, 1
	mov	ebx, 324508639
	mov	ecx, dword [esp]
	xor	edx, edx
	int	128
	mov	eax, 3
	mov	ebx, Ltmp0
	xor	ecx, ecx
	xor	edx, edx
	int	128
	mov	eax, 65536
	mov	eax, dword [eax]
Ltmp0:
	lea	ebx, [esp + 36]
	lea	ecx, [esp + 100]
	lea	edx, [esp + 124]
	mov	eax, 16
	int	128
	xor	ecx, ecx
	test	eax, eax
	setne	cl
	mov	eax, ecx
	lea	esp, [ebp - 12]
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
LBB0_183:
	mov	eax, 32
	mov	ebx, edi
	xor	ecx, ecx
	xor	edx, edx
	int	128
	test	eax, eax
	js	LBB0_140
	mov	esi, eax
	mov	eax, 7
	mov	ebx, esi
	mov	ecx, user_main.readback
	mov	edx, 4
	int	128
	cmp	eax, 4
	jne	LBB0_224
	cmp	byte [user_main.readback], 112
	jne	LBB0_224
	cmp	byte [user_main.readback+1], 101
	jne	LBB0_224
	cmp	byte [user_main.readback+2], 114
	jne	LBB0_224
	mov	byte [esp + 4], 1
	cmp	byte [user_main.readback+3], 115
	jne	LBB0_225
	mov	eax, 7
	mov	ebx, edi
	int	128
	cmp	eax, 4
	jne	LBB0_225
	cmp	byte [user_main.readback], 0
	jne	LBB0_225
	cmp	byte [user_main.readback+1], 0
	jne	LBB0_225
	cmp	byte [user_main.readback+2], 0
	jne	LBB0_225
	cmp	byte [user_main.readback+3], 0
	jne	LBB0_225
	mov	eax, 8
	mov	ebx, edi
	xor	ecx, ecx
	xor	edx, edx
	int	128
	test	eax, eax
	jne	LBB0_225
	mov	eax, 33
	mov	ebx, esi
	mov	ecx, 8
	xor	edx, edx
	int	128
	cmp	eax, 8
	jne	LBB0_225
	mov	eax, 7
	mov	ebx, 8
	mov	ecx, user_main.readback
	mov	edx, 4
	int	128
	cmp	eax, 4
	jne	LBB0_225
	cmp	byte [user_main.readback], 112
	jne	LBB0_225
	cmp	byte [user_main.readback+1], 101
	jne	LBB0_225
	cmp	byte [user_main.readback+2], 114
	jne	LBB0_225
	cmp	byte [user_main.readback+3], 115
	jne	LBB0_225
	mov	eax, 7
	mov	ebx, edi
	int	128
	cmp	eax, 4
	jne	LBB0_225
	cmp	byte [user_main.readback], 0
	jne	LBB0_225
	cmp	byte [user_main.readback+1], 0
	jne	LBB0_225
	cmp	byte [user_main.readback+2], 0
	jne	LBB0_225
	cmp	byte [user_main.readback+3], 0
	jne	LBB0_225
	mov	eax, 8
	mov	ebx, edi
	xor	ecx, ecx
	xor	edx, edx
	int	128
	test	eax, eax
	jne	LBB0_225
	mov	eax, 34
	mov	ebx, edi
	mov	ecx, 9
	mov	edx, 2048
	int	128
	cmp	eax, 9
	jne	LBB0_225
	mov	eax, 7
	mov	ebx, 9
	mov	ecx, user_main.readback
	mov	edx, 4
	int	128
	cmp	eax, 4
	jne	LBB0_225
	cmp	byte [user_main.readback], 112
	jne	LBB0_225
	cmp	byte [user_main.readback+1], 101
	jne	LBB0_225
	cmp	byte [user_main.readback+2], 114
	jne	LBB0_225
	cmp	byte [user_main.readback+3], 115
	jne	LBB0_225
	mov	eax, 7
	mov	ebx, edi
	int	128
	cmp	eax, 4
	jne	LBB0_225
	cmp	byte [user_main.readback], 0
	jne	LBB0_225
	cmp	byte [user_main.readback+1], 0
	jne	LBB0_225
	cmp	byte [user_main.readback+2], 0
	jne	LBB0_225
	cmp	byte [user_main.readback+3], 0
	jne	LBB0_225
	mov	eax, 33
	mov	ebx, esi
	mov	ecx, esi
	xor	edx, edx
	int	128
	cmp	eax, esi
	jne	LBB0_225
	mov	eax, 34
	mov	ebx, esi
	mov	ecx, esi
	xor	edx, edx
	int	128
	cmp	eax, -22
	jne	LBB0_225
	mov	eax, 32
	mov	ebx, 99
	xor	ecx, ecx
	xor	edx, edx
	int	128
	cmp	eax, -9
	setne	byte [esp + 4]
	jmp	LBB0_225
LBB0_224:
	mov	byte [esp + 4], 1
LBB0_225:
	mov	eax, 12
	mov	ebx, esi
	xor	ecx, ecx
	xor	edx, edx
	int	128
	mov	eax, 12
	mov	ebx, 8
	xor	ecx, ecx
	xor	edx, edx
	int	128
	cmp	byte [esp + 4], 0
	jne	LBB0_141
	add	dword [esp], 131072
	jmp	LBB0_141
LBB0_227:
	lea	ebx, [esp + 56]
	mov	eax, 18
	mov	ecx, user_main.statbuf
	xor	edx, edx
	int	128
	xor	ecx, ecx
	test	eax, eax
	jne	LBB0_94
	test	byte [user_main.statbuf+9], 64
	je	LBB0_93
	lea	ebx, [esp + 68]
	mov	eax, 6
	mov	ecx, 2
	mov	edx, 438
	int	128
	cmp	eax, -13
	jne	LBB0_93
	lea	ebx, [esp + 68]
	mov	eax, 30
	mov	ecx, user_main.asset_entries
	mov	edx, 1
	int	128
	cmp	eax, -20
	jne	LBB0_93
	lea	ebx, [esp + 148]
	mov	eax, 6
	xor	ecx, ecx
	xor	edx, edx
	int	128
	cmp	eax, -22
	sete	cl
	jmp	LBB0_94
Lfunc_end0:
section .rodata.str1.1 progbits alloc noexec nowrite align=1
L__const.user_main.hello:
db `user C probe\n`, 0
L__const.user_main.abi_probe_path:
db `/SYSTEM/ABIPROBE.ELF`, 0
L__const.user_main.asset_readme_path:
db `/ASSETS/README.TXT`, 0
L__const.user_main.asset_deep_path:
db `/ASSETS/SUB/README.TXT`, 0
L__const.user_main.asset_payload:
db `vibe-os FAT16 one-level asset file\n`, 0
L__const.user_main.default_path:
db `DEFAULT.CFG`, 0
L__const.user_main.writable_payload:
db `persist-ok\n`, 0
L.str:
db `PROBE_LAUNCHER=USERPROB`, 0
L.str.1:
db `ABI_ENV=present`, 0
section .rodata progbits alloc noexec nowrite align=4
align 4
L__const.user_main.abi_probe_envp:
dd L.str
dd L.str.1
dd 0
section .rodata.str1.1
L.str.2:
db `USERPROB.ELF`, 0
L.str.3:
db `/`, 0
L.str.4:
db `DOOM1.WAD`, 0
L.str.5:
db `ASSETS`, 0
L.str.6:
db `README.TXT`, 0
L.str.7:
db `doom`, 0

section .bss
alignb 4
user_main.header resb 12
user_main.readback resb 40
alignb 4
user_main.fbinfo resb 84
alignb 4
user_main.present resb 16
alignb 4
user_main.root_entries resb 512
alignb 4
user_main.asset_entries resb 128
alignb 4
user_main.statbuf resb 44
