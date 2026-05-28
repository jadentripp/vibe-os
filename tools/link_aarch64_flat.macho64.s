	.build_version macos, 26, 0	sdk_version 26, 5
	.section	__TEXT,__text,regular,pure_instructions
	.globl	_main                           ## -- Begin function main
	.p2align	4
_main:                                  ## @main
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$184, %rsp
	cmpl	$2, %edi
	jl	LBB0_23
## %bb.1:
	movq	%rsi, %r14
	movl	%edi, %r15d
	movq	$0, -56(%rbp)                   ## 8-byte Folded Spill
	movl	$1, %r13d
	movq	$0, -96(%rbp)                   ## 8-byte Folded Spill
	movq	$0, -48(%rbp)                   ## 8-byte Folded Spill
	movq	$0, -176(%rbp)                  ## 8-byte Folded Spill
	movq	$0, -136(%rbp)                  ## 8-byte Folded Spill
	jmp	LBB0_2
	.p2align	4
LBB0_14:                                ##   in Loop: Header=BB0_2 Depth=1
	incl	%r13d
	cmpl	%r15d, %r13d
	jge	LBB0_190
## %bb.15:                              ##   in Loop: Header=BB0_2 Depth=1
	movslq	%r13d, %rax
	movq	(%r14,%rax,8), %rax
	movq	%rax, -176(%rbp)                ## 8-byte Spill
LBB0_19:                                ##   in Loop: Header=BB0_2 Depth=1
	incl	%r13d
	cmpl	%r15d, %r13d
	jge	LBB0_20
LBB0_2:                                 ## =>This Inner Loop Header: Depth=1
	movslq	%r13d, %rax
	movq	(%r14,%rax,8), %rbx
	movzbl	(%rbx), %r12d
	cmpb	$45, %r12b
	jne	LBB0_7
## %bb.3:                               ##   in Loop: Header=BB0_2 Depth=1
	cmpb	$111, 1(%rbx)
	jne	LBB0_7
## %bb.4:                               ##   in Loop: Header=BB0_2 Depth=1
	cmpb	$0, 2(%rbx)
	je	LBB0_5
	.p2align	4
LBB0_7:                                 ##   in Loop: Header=BB0_2 Depth=1
	movq	%rbx, %rdi
	leaq	L_.str.2(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_8
## %bb.13:                              ##   in Loop: Header=BB0_2 Depth=1
	movq	%rbx, %rdi
	leaq	L_.str.4(%rip), %rsi
	callq	_strcmp
	testl	%eax, %eax
	je	LBB0_14
## %bb.16:                              ##   in Loop: Header=BB0_2 Depth=1
	cmpb	$45, %r12b
	je	LBB0_17
## %bb.18:                              ##   in Loop: Header=BB0_2 Depth=1
	cmpq	$0, -48(%rbp)                   ## 8-byte Folded Reload
	movq	%rbx, -48(%rbp)                 ## 8-byte Spill
	je	LBB0_19
	jmp	LBB0_191
	.p2align	4
LBB0_8:                                 ##   in Loop: Header=BB0_2 Depth=1
	incl	%r13d
	cmpl	%r15d, %r13d
	jge	LBB0_188
## %bb.9:                               ##   in Loop: Header=BB0_2 Depth=1
	movslq	%r13d, %rax
	movq	(%r14,%rax,8), %rbx
	movq	$0, -192(%rbp)
	callq	___error
	movl	$0, (%rax)
	movq	%rbx, %rdi
	leaq	-192(%rbp), %rsi
	xorl	%edx, %edx
	callq	_strtoull
	movq	%rax, -96(%rbp)                 ## 8-byte Spill
	callq	___error
	cmpl	$0, (%rax)
	jne	LBB0_189
## %bb.10:                              ##   in Loop: Header=BB0_2 Depth=1
	movq	-192(%rbp), %rax
	testq	%rax, %rax
	je	LBB0_189
## %bb.11:                              ##   in Loop: Header=BB0_2 Depth=1
	cmpb	$0, (%rax)
	jne	LBB0_189
## %bb.12:                              ##   in Loop: Header=BB0_2 Depth=1
	movl	$1, %eax
	movq	%rax, -56(%rbp)                 ## 8-byte Spill
	jmp	LBB0_19
LBB0_5:                                 ##   in Loop: Header=BB0_2 Depth=1
	incl	%r13d
	cmpl	%r15d, %r13d
	jge	LBB0_187
## %bb.6:                               ##   in Loop: Header=BB0_2 Depth=1
	movslq	%r13d, %rax
	movq	(%r14,%rax,8), %rax
	movq	%rax, -136(%rbp)                ## 8-byte Spill
	jmp	LBB0_19
LBB0_20:
	cmpq	$0, -136(%rbp)                  ## 8-byte Folded Reload
	je	LBB0_23
## %bb.21:
	cmpl	$0, -56(%rbp)                   ## 4-byte Folded Reload
	je	LBB0_23
## %bb.22:
	cmpq	$0, -48(%rbp)                   ## 8-byte Folded Reload
	je	LBB0_23
## %bb.24:
	leaq	L_.str.11(%rip), %rsi
	movq	-48(%rbp), %rdi                 ## 8-byte Reload
	callq	_fopen
	testq	%rax, %rax
	je	LBB0_192
## %bb.25:
	movq	%rax, %r12
	movq	%rax, %rdi
	xorl	%esi, %esi
	movl	$2, %edx
	callq	_fseek
	testl	%eax, %eax
	jne	LBB0_193
## %bb.26:
	movq	%r12, %rdi
	callq	_ftell
	movq	%rax, -72(%rbp)                 ## 8-byte Spill
	testq	%rax, %rax
	js	LBB0_194
## %bb.27:
	movq	%r12, %rdi
	xorl	%esi, %esi
	xorl	%edx, %edx
	callq	_fseek
	testl	%eax, %eax
	jne	LBB0_193
## %bb.28:
	movq	-72(%rbp), %rbx                 ## 8-byte Reload
	cmpq	$1, %rbx
	movq	%rbx, %rdi
	adcq	$0, %rdi
	movl	$1, %esi
	callq	_calloc
	testq	%rax, %rax
	je	LBB0_195
## %bb.29:
	testq	%rbx, %rbx
	je	LBB0_30
## %bb.32:
	movq	%rbx, %rdx
	movl	$1, %esi
	movq	%rax, -64(%rbp)                 ## 8-byte Spill
	movq	%rax, %rdi
	movq	%r12, %rcx
	callq	_fread
	cmpq	%rbx, %rax
	jne	LBB0_196
## %bb.33:
	movq	%r12, %rdi
	callq	_fclose
	cmpq	$64, %rbx
	movq	-64(%rbp), %rsi                 ## 8-byte Reload
	jb	LBB0_31
## %bb.34:
	cmpl	$1179403647, (%rsi)             ## imm = 0x464C457F
	jne	LBB0_31
## %bb.35:
	cmpb	$2, 4(%rsi)
	jne	LBB0_197
## %bb.36:
	cmpb	$1, 5(%rsi)
	jne	LBB0_197
## %bb.37:
	cmpw	$1, 16(%rsi)
	jne	LBB0_198
## %bb.38:
	cmpw	$183, 18(%rsi)
	jne	LBB0_198
## %bb.39:
	movzwl	58(%rsi), %r9d
	cmpq	$63, %r9
	jbe	LBB0_199
## %bb.40:
	movzwl	60(%rsi), %edi
	movzwl	62(%rsi), %eax
	cmpw	%di, %ax
	jae	LBB0_200
## %bb.41:
	movq	%rbx, %r8
	movl	40(%rsi), %ebx
	movl	44(%rsi), %r14d
	shlq	$32, %r14
	leaq	(%r14,%rbx), %rcx
	movq	%rdi, %rdx
	imulq	%r9, %rdx
	addq	%rcx, %rdx
	cmpq	%r8, %rdx
	ja	LBB0_201
## %bb.42:
	imulq	%r9, %rax
	leaq	(%rax,%rcx), %rdx
	addq	$28, %rdx
	cmpq	%r8, %rdx
	ja	LBB0_202
## %bb.43:
	addq	%rcx, %rax
	leaq	32(%rax), %rcx
	cmpq	%r8, %rcx
	ja	LBB0_203
## %bb.44:
	leaq	36(%rax), %rcx
	cmpq	%r8, %rcx
	ja	LBB0_204
## %bb.45:
	movq	%rdi, -112(%rbp)                ## 8-byte Spill
	leaq	40(%rax), %rcx
	cmpq	%r8, %rcx
	ja	LBB0_205
## %bb.46:
	movq	%r9, -88(%rbp)                  ## 8-byte Spill
	movq	24(%rsi,%rax), %r15
	movq	32(%rsi,%rax), %r12
	leaq	(%r12,%r15), %rax
	cmpq	%r8, %rax
	ja	LBB0_206
## %bb.47:
	movl	$88, %esi
	movq	-112(%rbp), %r13                ## 8-byte Reload
	movq	%r13, %rdi
	callq	_calloc
	testq	%rax, %rax
	je	LBB0_207
## %bb.48:
	movq	-64(%rbp), %r8                  ## 8-byte Reload
	addq	%r8, %r15
	imulq	$88, %r13, %rdx
	leaq	(%r14,%rbx), %r13
	addq	$64, %r13
	xorl	%r14d, %r14d
	movq	-72(%rbp), %r10                 ## 8-byte Reload
	movq	%rax, -56(%rbp)                 ## 8-byte Spill
	movq	%rdx, -144(%rbp)                ## 8-byte Spill
	jmp	LBB0_49
	.p2align	4
LBB0_51:                                ##   in Loop: Header=BB0_49 Depth=1
	addq	$88, %r14
	addq	-88(%rbp), %r13                 ## 8-byte Folded Reload
	movq	-144(%rbp), %rdx                ## 8-byte Reload
	cmpq	%r14, %rdx
	je	LBB0_52
LBB0_49:                                ## =>This Inner Loop Header: Depth=1
	leaq	-60(%r13), %rcx
	cmpq	%r10, %rcx
	ja	LBB0_50
## %bb.53:                              ##   in Loop: Header=BB0_49 Depth=1
	movl	-64(%r8,%r13), %ebx
	movq	%r12, %rdx
	subq	%rbx, %rdx
	jbe	LBB0_208
## %bb.54:                              ##   in Loop: Header=BB0_49 Depth=1
	addq	%r15, %rbx
	movq	%rbx, %rdi
	xorl	%esi, %esi
	callq	_memchr
	testq	%rax, %rax
	je	LBB0_209
## %bb.55:                              ##   in Loop: Header=BB0_49 Depth=1
	movq	-56(%rbp), %rax                 ## 8-byte Reload
	movq	%rbx, (%rax,%r14)
	leaq	-56(%r13), %rcx
	movq	-72(%rbp), %r10                 ## 8-byte Reload
	cmpq	%r10, %rcx
	movq	-64(%rbp), %r8                  ## 8-byte Reload
	ja	LBB0_210
## %bb.56:                              ##   in Loop: Header=BB0_49 Depth=1
	movl	-60(%r8,%r13), %r9d
	movl	%r9d, 8(%rax,%r14)
	leaq	-52(%r13), %rcx
	cmpq	%r10, %rcx
	ja	LBB0_211
## %bb.57:                              ##   in Loop: Header=BB0_49 Depth=1
	leaq	-48(%r13), %rcx
	cmpq	%r10, %rcx
	ja	LBB0_212
## %bb.58:                              ##   in Loop: Header=BB0_49 Depth=1
	movl	-56(%r8,%r13), %ecx
	movl	-52(%r8,%r13), %edx
	shlq	$32, %rdx
	orq	%rcx, %rdx
	movq	%rdx, 16(%rax,%r14)
	leaq	-36(%r13), %rdx
	cmpq	%r10, %rdx
	ja	LBB0_213
## %bb.59:                              ##   in Loop: Header=BB0_49 Depth=1
	leaq	-32(%r13), %rdx
	cmpq	%r10, %rdx
	ja	LBB0_214
## %bb.60:                              ##   in Loop: Header=BB0_49 Depth=1
	movq	-40(%r8,%r13), %rdx
	movq	%rdx, 24(%rax,%r14)
	leaq	-28(%r13), %rsi
	cmpq	%r10, %rsi
	ja	LBB0_215
## %bb.61:                              ##   in Loop: Header=BB0_49 Depth=1
	leaq	-24(%r13), %rsi
	cmpq	%r10, %rsi
	ja	LBB0_216
## %bb.62:                              ##   in Loop: Header=BB0_49 Depth=1
	movq	-32(%r8,%r13), %rsi
	movq	%rsi, 32(%rax,%r14)
	leaq	-20(%r13), %rdi
	cmpq	%r10, %rdi
	ja	LBB0_217
## %bb.63:                              ##   in Loop: Header=BB0_49 Depth=1
	movl	-24(%r8,%r13), %edi
	movl	%edi, 40(%rax,%r14)
	leaq	-16(%r13), %rdi
	cmpq	%r10, %rdi
	ja	LBB0_218
## %bb.64:                              ##   in Loop: Header=BB0_49 Depth=1
	movl	-20(%r8,%r13), %edi
	movl	%edi, 44(%rax,%r14)
	leaq	-12(%r13), %rdi
	cmpq	%r10, %rdi
	ja	LBB0_219
## %bb.65:                              ##   in Loop: Header=BB0_49 Depth=1
	leaq	-8(%r13), %rdi
	cmpq	%r10, %rdi
	ja	LBB0_220
## %bb.66:                              ##   in Loop: Header=BB0_49 Depth=1
	movq	-16(%r8,%r13), %rdi
	movq	%rdi, 48(%rax,%r14)
	leaq	-4(%r13), %rdi
	cmpq	%r10, %rdi
	ja	LBB0_221
## %bb.67:                              ##   in Loop: Header=BB0_49 Depth=1
	cmpq	%r10, %r13
	ja	LBB0_222
## %bb.68:                              ##   in Loop: Header=BB0_49 Depth=1
	movq	-8(%r8,%r13), %rdi
	movq	%rdi, 56(%rax,%r14)
	shrl	%ecx
	andl	$1, %ecx
	movl	%ecx, 80(%rax,%r14)
	cmpl	$8, %r9d
	je	LBB0_51
## %bb.69:                              ##   in Loop: Header=BB0_49 Depth=1
	addq	%rdx, %rsi
	cmpq	%r10, %rsi
	jbe	LBB0_51
## %bb.70:
	leaq	L_.str.25(%rip), %rsi
	movq	-48(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB0_23:
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rcx
	leaq	L_.str.8(%rip), %rdi
	movl	$69, %esi
	movl	$1, %edx
	callq	_fwrite
	movl	$1, %eax
	jmp	LBB0_186
LBB0_52:
	xorl	%ebx, %ebx
	movq	-112(%rbp), %rcx                ## 8-byte Reload
	.p2align	4
LBB0_72:                                ## =>This Inner Loop Header: Depth=1
	cmpl	$2, 8(%rax,%rbx)
	je	LBB0_73
## %bb.71:                              ##   in Loop: Header=BB0_72 Depth=1
	addq	$88, %rbx
	cmpq	%rbx, %rdx
	jne	LBB0_72
## %bb.235:
	leaq	L_.str.32(%rip), %rsi
	movq	-48(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB0_73:
	movl	40(%rax,%rbx), %edx
	cmpl	%edx, %ecx
	jbe	LBB0_223
## %bb.74:
	movq	56(%rax,%rbx), %r15
	testq	%r15, %r15
	je	LBB0_224
## %bb.75:
	imulq	$88, %rdx, %rcx
	movq	24(%rax,%rcx), %r14
	movq	32(%rax,%rcx), %rcx
	movq	%rcx, -88(%rbp)                 ## 8-byte Spill
	addq	%r14, %rcx
	cmpq	%r10, %rcx
	ja	LBB0_225
## %bb.76:
	movq	32(%rax,%rbx), %r12
	movq	%r12, %rax
	orq	%r15, %rax
	shrq	$32, %rax
	je	LBB0_77
## %bb.78:
	movq	%r12, %rax
	xorl	%edx, %edx
	divq	%r15
	jmp	LBB0_79
LBB0_17:
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.6(%rip), %rsi
	movq	%rbx, %rdx
	xorl	%eax, %eax
	callq	_fprintf
	movl	$1, %eax
	jmp	LBB0_186
LBB0_77:
	movl	%r12d, %eax
	xorl	%edx, %edx
	divl	%r15d
                                        ## kill: def $eax killed $eax def $rax
LBB0_79:
	cmpq	%r12, %r15
	movl	$1, %edi
	movq	%rax, -80(%rbp)                 ## 8-byte Spill
	cmovbeq	%rax, %rdi
	movl	$40, %esi
	callq	_calloc
	movq	%rax, -160(%rbp)                ## 8-byte Spill
	testq	%rax, %rax
	je	LBB0_226
## %bb.80:
	movq	%r15, -184(%rbp)                ## 8-byte Spill
	movq	%r12, -208(%rbp)                ## 8-byte Spill
	cmpq	%r12, %r15
	movq	-64(%rbp), %rcx                 ## 8-byte Reload
	movq	-56(%rbp), %r9                  ## 8-byte Reload
	movq	-72(%rbp), %rdx                 ## 8-byte Reload
	ja	LBB0_91
## %bb.81:
	movq	%rcx, %r15
	addq	%r14, %r15
	movq	24(%r9,%rbx), %r12
	movq	-160(%rbp), %rax                ## 8-byte Reload
	leaq	32(%rax), %r13
	addq	$24, %r12
	xorl	%r14d, %r14d
	.p2align	4
LBB0_82:                                ## =>This Inner Loop Header: Depth=1
	leaq	-20(%r12), %rax
	cmpq	%rdx, %rax
	ja	LBB0_227
## %bb.83:                              ##   in Loop: Header=BB0_82 Depth=1
	movl	-24(%rcx,%r12), %ebx
	movq	-88(%rbp), %rdx                 ## 8-byte Reload
	subq	%rbx, %rdx
	jbe	LBB0_228
## %bb.84:                              ##   in Loop: Header=BB0_82 Depth=1
	addq	%r15, %rbx
	movq	%rbx, %rdi
	xorl	%esi, %esi
	callq	_memchr
	testq	%rax, %rax
	je	LBB0_229
## %bb.85:                              ##   in Loop: Header=BB0_82 Depth=1
	movq	%rbx, -32(%r13)
	movq	-64(%rbp), %rcx                 ## 8-byte Reload
	movzbl	-20(%rcx,%r12), %eax
	movb	%al, (%r13)
	leaq	-16(%r12), %rax
	movq	-72(%rbp), %rdx                 ## 8-byte Reload
	cmpq	%rdx, %rax
	ja	LBB0_230
## %bb.86:                              ##   in Loop: Header=BB0_82 Depth=1
	movzwl	-18(%rcx,%r12), %eax
	movw	%ax, -24(%r13)
	leaq	-12(%r12), %rax
	cmpq	%rdx, %rax
	movq	-56(%rbp), %r9                  ## 8-byte Reload
	movq	-80(%rbp), %rsi                 ## 8-byte Reload
	ja	LBB0_231
## %bb.87:                              ##   in Loop: Header=BB0_82 Depth=1
	leaq	-8(%r12), %rax
	cmpq	%rdx, %rax
	ja	LBB0_232
## %bb.88:                              ##   in Loop: Header=BB0_82 Depth=1
	movq	-16(%rcx,%r12), %rax
	movq	%rax, -16(%r13)
	leaq	-4(%r12), %rax
	cmpq	%rdx, %rax
	ja	LBB0_233
## %bb.89:                              ##   in Loop: Header=BB0_82 Depth=1
	cmpq	%rdx, %r12
	ja	LBB0_234
## %bb.90:                              ##   in Loop: Header=BB0_82 Depth=1
	movq	-8(%rcx,%r12), %rax
	movq	%rax, -8(%r13)
	incq	%r14
	addq	$40, %r13
	addq	-184(%rbp), %r12                ## 8-byte Folded Reload
	cmpq	%rsi, %r14
	jb	LBB0_82
LBB0_91:
	movq	-112(%rbp), %rbx                ## 8-byte Reload
	cmpw	$2, %bx
	jb	LBB0_92
## %bb.103:
	movq	-144(%rbp), %rax                ## 8-byte Reload
	addq	$-88, %rax
	xorl	%ecx, %ecx
	movl	$1, %edx
	xorl	%r10d, %r10d
	xorl	%r15d, %r15d
	jmp	LBB0_104
	.p2align	4
LBB0_109:                               ##   in Loop: Header=BB0_104 Depth=1
	movq	%r15, 152(%r9,%rcx)
	movq	-96(%rbp), %rsi                 ## 8-byte Reload
	addq	%r15, %rsi
	movq	%rsi, 160(%r9,%rcx)
	addq	120(%r9,%rcx), %r15
	cmpq	%r10, %r15
	cmovaq	%r15, %r10
LBB0_110:                               ##   in Loop: Header=BB0_104 Depth=1
	addq	$88, %rcx
	cmpq	%rcx, %rax
	je	LBB0_111
LBB0_104:                               ## =>This Inner Loop Header: Depth=1
	cmpl	$0, 168(%r9,%rcx)
	je	LBB0_110
## %bb.105:                             ##   in Loop: Header=BB0_104 Depth=1
	cmpl	$8, 96(%r9,%rcx)
	je	LBB0_110
## %bb.106:                             ##   in Loop: Header=BB0_104 Depth=1
	movq	136(%r9,%rcx), %rsi
	cmpq	$2, %rsi
	cmovbq	%rdx, %rsi
	jb	LBB0_109
## %bb.107:                             ##   in Loop: Header=BB0_104 Depth=1
	leaq	-1(%rsi), %rdi
	testq	%rdi, %rsi
	jne	LBB0_236
## %bb.108:                             ##   in Loop: Header=BB0_104 Depth=1
	leaq	(%r15,%rsi), %rdi
	decq	%rdi
	negq	%rsi
	andq	%rdi, %rsi
	movq	%rsi, %r15
	jmp	LBB0_109
LBB0_92:
	xorl	%r10d, %r10d
	movq	-96(%rbp), %rax                 ## 8-byte Reload
	movq	%rax, -104(%rbp)                ## 8-byte Spill
	xorl	%r15d, %r15d
	movq	%rax, -168(%rbp)                ## 8-byte Spill
	jmp	LBB0_101
LBB0_111:
	xorl	%ecx, %ecx
	movl	$1, %edx
	movq	$0, -104(%rbp)                  ## 8-byte Folded Spill
	movq	$0, -128(%rbp)                  ## 8-byte Folded Spill
	xorl	%esi, %esi
	jmp	LBB0_93
	.p2align	4
LBB0_98:                                ##   in Loop: Header=BB0_93 Depth=1
	movq	%r15, 152(%r9,%rcx)
	movq	-96(%rbp), %rdi                 ## 8-byte Reload
	addq	%r15, %rdi
	movq	%rdi, 160(%r9,%rcx)
	testl	%esi, %esi
	movq	-104(%rbp), %rsi                ## 8-byte Reload
	cmoveq	%rdi, %rsi
	movq	%rsi, -104(%rbp)                ## 8-byte Spill
	movq	120(%r9,%rcx), %rsi
	addq	%rsi, %rdi
	movq	%rdi, -128(%rbp)                ## 8-byte Spill
	addq	%rsi, %r15
	movl	$1, %esi
LBB0_99:                                ##   in Loop: Header=BB0_93 Depth=1
	addq	$88, %rcx
	cmpq	%rcx, %rax
	je	LBB0_100
LBB0_93:                                ## =>This Inner Loop Header: Depth=1
	cmpl	$0, 168(%r9,%rcx)
	je	LBB0_99
## %bb.94:                              ##   in Loop: Header=BB0_93 Depth=1
	cmpl	$8, 96(%r9,%rcx)
	jne	LBB0_99
## %bb.95:                              ##   in Loop: Header=BB0_93 Depth=1
	movq	136(%r9,%rcx), %rdi
	cmpq	$2, %rdi
	cmovbq	%rdx, %rdi
	jb	LBB0_98
## %bb.96:                              ##   in Loop: Header=BB0_93 Depth=1
	leaq	-1(%rdi), %r8
	testq	%r8, %rdi
	jne	LBB0_236
## %bb.97:                              ##   in Loop: Header=BB0_93 Depth=1
	leaq	(%r15,%rdi), %r8
	decq	%r8
	negq	%rdi
	andq	%r8, %rdi
	movq	%rdi, %r15
	jmp	LBB0_98
LBB0_100:
	movq	-96(%rbp), %rax                 ## 8-byte Reload
	leaq	(%r15,%rax), %rcx
	testl	%esi, %esi
	movq	-104(%rbp), %rax                ## 8-byte Reload
	cmoveq	%rcx, %rax
	movq	%rax, -104(%rbp)                ## 8-byte Spill
	movq	-128(%rbp), %rax                ## 8-byte Reload
	movq	%rcx, -168(%rbp)                ## 8-byte Spill
	cmoveq	%rcx, %rax
LBB0_101:
	movq	%rax, -128(%rbp)                ## 8-byte Spill
	testq	%r10, %r10
	je	LBB0_102
## %bb.112:
	movl	$1, %esi
	movq	%r10, -120(%rbp)                ## 8-byte Spill
	movq	%r10, %rdi
	callq	_calloc
	movq	%rax, -88(%rbp)                 ## 8-byte Spill
	testq	%rax, %rax
	je	LBB0_237
## %bb.113:
	cmpw	$2, %bx
	movq	-64(%rbp), %r8                  ## 8-byte Reload
	movq	-56(%rbp), %r9                  ## 8-byte Reload
	movq	-72(%rbp), %rdi                 ## 8-byte Reload
	movq	-80(%rbp), %r10                 ## 8-byte Reload
	movq	-120(%rbp), %r11                ## 8-byte Reload
	jb	LBB0_120
## %bb.114:
	movq	-144(%rbp), %rax                ## 8-byte Reload
	leaq	-88(%rax), %rbx
	xorl	%r14d, %r14d
	jmp	LBB0_115
LBB0_159:                               ##   in Loop: Header=BB0_115 Depth=1
	addq	-88(%rbp), %rdi                 ## 8-byte Folded Reload
	movq	112(%r9,%r14), %rsi
	addq	%r8, %rsi
	callq	_memcpy
	movq	-56(%rbp), %r9                  ## 8-byte Reload
	movq	-64(%rbp), %r8                  ## 8-byte Reload
	movq	-72(%rbp), %rdi                 ## 8-byte Reload
	movq	-80(%rbp), %r10                 ## 8-byte Reload
	movq	-120(%rbp), %r11                ## 8-byte Reload
	.p2align	4
LBB0_160:                               ##   in Loop: Header=BB0_115 Depth=1
	addq	$88, %r14
	cmpq	%r14, %rbx
	je	LBB0_120
LBB0_115:                               ## =>This Inner Loop Header: Depth=1
	cmpl	$0, 168(%r9,%r14)
	je	LBB0_160
## %bb.116:                             ##   in Loop: Header=BB0_115 Depth=1
	cmpl	$8, 96(%r9,%r14)
	je	LBB0_160
## %bb.117:                             ##   in Loop: Header=BB0_115 Depth=1
	movq	120(%r9,%r14), %rdx
	testq	%rdx, %rdx
	je	LBB0_160
## %bb.118:                             ##   in Loop: Header=BB0_115 Depth=1
	movq	152(%r9,%r14), %rdi
	leaq	(%rdi,%rdx), %rax
	cmpq	%r11, %rax
	jbe	LBB0_159
## %bb.119:
	callq	_main.cold.16
LBB0_120:
	movq	%r15, -200(%rbp)                ## 8-byte Spill
	xorl	%eax, %eax
	movq	-88(%rbp), %rbx                 ## 8-byte Reload
	jmp	LBB0_121
	.p2align	4
LBB0_156:                               ##   in Loop: Header=BB0_121 Depth=1
	movq	-216(%rbp), %rax                ## 8-byte Reload
	incq	%rax
	cmpq	-112(%rbp), %rax                ## 8-byte Folded Reload
	je	LBB0_157
LBB0_121:                               ## =>This Loop Header: Depth=1
                                        ##     Child Loop BB0_128 Depth 2
	movq	%rax, -216(%rbp)                ## 8-byte Spill
	imulq	$88, %rax, %rsi
	cmpl	$4, 8(%r9,%rsi)
	jne	LBB0_156
## %bb.122:                             ##   in Loop: Header=BB0_121 Depth=1
	addq	%r9, %rsi
	movl	44(%rsi), %eax
	cmpl	%eax, -112(%rbp)                ## 4-byte Folded Reload
	jbe	LBB0_238
## %bb.123:                             ##   in Loop: Header=BB0_121 Depth=1
	imulq	$88, %rax, %rax
	movq	%rax, -48(%rbp)                 ## 8-byte Spill
	cmpl	$0, 80(%r9,%rax)
	je	LBB0_156
## %bb.124:                             ##   in Loop: Header=BB0_121 Depth=1
	movq	56(%rsi), %rax
	testq	%rax, %rax
	je	LBB0_126
## %bb.125:                             ##   in Loop: Header=BB0_121 Depth=1
	cmpq	$24, %rax
	jne	LBB0_239
LBB0_126:                               ##   in Loop: Header=BB0_121 Depth=1
	movq	32(%rsi), %rcx
	movq	%rcx, %rax
	movabsq	$-6148914691236517205, %rdx     ## imm = 0xAAAAAAAAAAAAAAAB
	mulq	%rdx
	cmpq	$24, %rcx
	jb	LBB0_156
## %bb.127:                             ##   in Loop: Header=BB0_121 Depth=1
	movq	%rdx, %r12
	addq	%r9, -48(%rbp)                  ## 8-byte Folded Spill
	shrq	$4, %r12
	movq	24(%rsi), %r15
	addq	$24, %r15
	jmp	LBB0_128
	.p2align	4
LBB0_151:                               ##   in Loop: Header=BB0_128 Depth=2
	andl	$31, %edx
	movl	%ecx, %esi
	andl	$28, %esi
	leal	(%rdx,%rsi,8), %edx
	movb	%dl, (%rbx,%rax)
	movl	%ecx, %edx
	shrl	$5, %edx
	movb	%dl, 1(%rbx,%rax)
	movl	%ecx, %edx
	shrl	$13, %edx
	movb	%dl, 2(%rbx,%rax)
	shlb	$5, %cl
	andb	$96, %cl
	orb	$16, %cl
LBB0_155:                               ##   in Loop: Header=BB0_128 Depth=2
	movb	%cl, 3(%rbx,%rax)
	addq	$24, %r15
	decq	%r12
	je	LBB0_156
LBB0_128:                               ##   Parent Loop BB0_121 Depth=1
                                        ## =>  This Inner Loop Header: Depth=2
	leaq	-20(%r15), %rax
	cmpq	%rdi, %rax
	ja	LBB0_240
## %bb.129:                             ##   in Loop: Header=BB0_128 Depth=2
	leaq	-16(%r15), %rax
	cmpq	%rdi, %rax
	ja	LBB0_241
## %bb.130:                             ##   in Loop: Header=BB0_128 Depth=2
	leaq	-12(%r15), %rax
	cmpq	%rdi, %rax
	ja	LBB0_242
## %bb.131:                             ##   in Loop: Header=BB0_128 Depth=2
	leaq	-8(%r15), %rax
	cmpq	%rdi, %rax
	ja	LBB0_243
## %bb.132:                             ##   in Loop: Header=BB0_128 Depth=2
	leaq	-4(%r15), %rax
	cmpq	%rdi, %rax
	ja	LBB0_244
## %bb.133:                             ##   in Loop: Header=BB0_128 Depth=2
	cmpq	%rdi, %r15
	ja	LBB0_245
## %bb.134:                             ##   in Loop: Header=BB0_128 Depth=2
	movl	-12(%r8,%r15), %eax
	cmpq	%rax, %r10
	jbe	LBB0_246
## %bb.135:                             ##   in Loop: Header=BB0_128 Depth=2
	movq	-24(%r8,%r15), %rbx
	movl	-16(%r8,%r15), %r13d
	movq	-8(%r8,%r15), %r14
	leaq	(%rax,%rax,4), %rcx
	movq	-160(%rbp), %rdx                ## 8-byte Reload
	leaq	(%rdx,%rcx,8), %rax
	movzwl	8(%rdx,%rcx,8), %ecx
	cmpl	$65521, %ecx                    ## imm = 0xFFF1
	je	LBB0_142
## %bb.136:                             ##   in Loop: Header=BB0_128 Depth=2
	testl	%ecx, %ecx
	jne	LBB0_143
## %bb.137:                             ##   in Loop: Header=BB0_128 Depth=2
	movq	(%rax), %rdi
	movq	%rdi, -152(%rbp)                ## 8-byte Spill
	leaq	L_.str.45(%rip), %rsi
	callq	_strcmp
	movq	-120(%rbp), %r11                ## 8-byte Reload
	movq	-80(%rbp), %r10                 ## 8-byte Reload
	movq	-72(%rbp), %rdi                 ## 8-byte Reload
	movq	-56(%rbp), %r9                  ## 8-byte Reload
	movq	-64(%rbp), %r8                  ## 8-byte Reload
	movq	-104(%rbp), %rcx                ## 8-byte Reload
	testl	%eax, %eax
	je	LBB0_146
## %bb.138:                             ##   in Loop: Header=BB0_128 Depth=2
	movq	-152(%rbp), %rdi                ## 8-byte Reload
	leaq	L_.str.46(%rip), %rsi
	callq	_strcmp
	movq	-120(%rbp), %r11                ## 8-byte Reload
	movq	-80(%rbp), %r10                 ## 8-byte Reload
	movq	-72(%rbp), %rdi                 ## 8-byte Reload
	movq	-56(%rbp), %r9                  ## 8-byte Reload
	movq	-64(%rbp), %r8                  ## 8-byte Reload
	movq	-128(%rbp), %rcx                ## 8-byte Reload
	testl	%eax, %eax
	je	LBB0_146
## %bb.139:                             ##   in Loop: Header=BB0_128 Depth=2
	movq	-152(%rbp), %rdi                ## 8-byte Reload
	leaq	L_.str.47(%rip), %rsi
	callq	_strcmp
	movq	-120(%rbp), %r11                ## 8-byte Reload
	movq	-80(%rbp), %r10                 ## 8-byte Reload
	movq	-72(%rbp), %rdi                 ## 8-byte Reload
	movq	-56(%rbp), %r9                  ## 8-byte Reload
	movq	-64(%rbp), %r8                  ## 8-byte Reload
	movq	-96(%rbp), %rcx                 ## 8-byte Reload
	testl	%eax, %eax
	je	LBB0_146
## %bb.140:                             ##   in Loop: Header=BB0_128 Depth=2
	movq	-152(%rbp), %rdi                ## 8-byte Reload
	leaq	L_.str.48(%rip), %rsi
	callq	_strcmp
	movq	-120(%rbp), %r11                ## 8-byte Reload
	movq	-80(%rbp), %r10                 ## 8-byte Reload
	movq	-72(%rbp), %rdi                 ## 8-byte Reload
	movq	-56(%rbp), %r9                  ## 8-byte Reload
	movq	-64(%rbp), %r8                  ## 8-byte Reload
	movq	-168(%rbp), %rcx                ## 8-byte Reload
	testl	%eax, %eax
	je	LBB0_146
	jmp	LBB0_141
	.p2align	4
LBB0_142:                               ##   in Loop: Header=BB0_128 Depth=2
	movq	16(%rax), %rcx
	jmp	LBB0_146
	.p2align	4
LBB0_143:                               ##   in Loop: Header=BB0_128 Depth=2
	cmpw	%cx, -112(%rbp)                 ## 2-byte Folded Reload
	jbe	LBB0_247
## %bb.144:                             ##   in Loop: Header=BB0_128 Depth=2
	imulq	$88, %rcx, %rdx
	cmpl	$0, 80(%r9,%rdx)
	je	LBB0_248
## %bb.145:                             ##   in Loop: Header=BB0_128 Depth=2
	addq	%r9, %rdx
	movq	16(%rax), %rcx
	addq	72(%rdx), %rcx
LBB0_146:                               ##   in Loop: Header=BB0_128 Depth=2
	addq	%r14, %rcx
	movq	-48(%rbp), %rax                 ## 8-byte Reload
	movq	64(%rax), %rax
	addq	%rbx, %rax
	cmpl	$257, %r13d                     ## imm = 0x101
	je	LBB0_152
## %bb.147:                             ##   in Loop: Header=BB0_128 Depth=2
	cmpl	$274, %r13d                     ## imm = 0x112
	jne	LBB0_254
## %bb.148:                             ##   in Loop: Header=BB0_128 Depth=2
	leaq	4(%rax), %rdx
	cmpq	%r11, %rdx
	ja	LBB0_249
## %bb.149:                             ##   in Loop: Header=BB0_128 Depth=2
	movq	-48(%rbp), %rdx                 ## 8-byte Reload
	addq	72(%rdx), %rbx
	subq	%rbx, %rcx
	leaq	-1048576(%rcx), %rdx
	cmpq	$-2097153, %rdx                 ## imm = 0xFFDFFFFF
	jbe	LBB0_250
## %bb.150:                             ##   in Loop: Header=BB0_128 Depth=2
	movq	-88(%rbp), %rbx                 ## 8-byte Reload
	movl	(%rbx,%rax), %edx
	movl	%edx, %esi
	andl	$-1627389952, %esi              ## imm = 0x9F000000
	cmpl	$268435456, %esi                ## imm = 0x10000000
	je	LBB0_151
	jmp	LBB0_251
	.p2align	4
LBB0_152:                               ##   in Loop: Header=BB0_128 Depth=2
	leaq	8(%rax), %rdx
	cmpq	%r11, %rdx
	ja	LBB0_252
## %bb.153:                             ##   in Loop: Header=BB0_128 Depth=2
	leaq	4(%rax), %rdx
	cmpq	%r11, %rdx
	movq	-88(%rbp), %rbx                 ## 8-byte Reload
	ja	LBB0_253
## %bb.154:                             ##   in Loop: Header=BB0_128 Depth=2
	movb	%cl, (%rbx,%rax)
	movb	%ch, 1(%rbx,%rax)
	movl	%ecx, %esi
	shrl	$16, %esi
	movb	%sil, 2(%rbx,%rax)
	movl	%ecx, %esi
	shrl	$24, %esi
	movb	%sil, 3(%rbx,%rax)
	movq	%rcx, %rsi
	shrq	$32, %rsi
	movb	%sil, 4(%rbx,%rax)
	movq	%rcx, %rsi
	shrq	$40, %rsi
	movb	%sil, 5(%rbx,%rax)
	movq	%rcx, %rsi
	shrq	$48, %rsi
	movb	%sil, 6(%rbx,%rax)
	shrq	$56, %rcx
	movq	%rdx, %rax
	jmp	LBB0_155
LBB0_157:
	leaq	L_.str.53(%rip), %rsi
	movq	-136(%rbp), %rdi                ## 8-byte Reload
	callq	_fopen
	testq	%rax, %rax
	je	LBB0_158
## %bb.161:
	movq	%rax, %r14
	movl	$1, %esi
	movq	%rbx, %rdi
	movq	-120(%rbp), %rbx                ## 8-byte Reload
	movq	%rbx, %rdx
	movq	%rax, %rcx
	callq	_fwrite
	cmpq	%rbx, %rax
	jne	LBB0_255
## %bb.162:
	movq	%r14, %rdi
	callq	_fclose
	movq	-176(%rbp), %rbx                ## 8-byte Reload
	testq	%rbx, %rbx
	je	LBB0_185
## %bb.163:
	leaq	L_.str.55(%rip), %rsi
	movq	%rbx, %rdi
	callq	_fopen
	testq	%rax, %rax
	je	LBB0_256
## %bb.164:
	movq	%rax, %r15
	movq	-96(%rbp), %rbx                 ## 8-byte Reload
	movq	-120(%rbp), %r14                ## 8-byte Reload
	leaq	(%r14,%rbx), %r12
	leaq	L_.str.56(%rip), %rdi
	movl	$30, %esi
	movl	$1, %edx
	movq	%rax, %rcx
	callq	_fwrite
	leaq	L_.str.57(%rip), %rsi
	movq	%r15, %rdi
	movq	%rbx, %rdx
	xorl	%eax, %eax
	callq	_fprintf
	leaq	L_.str.58(%rip), %rsi
	movq	%r15, %rdi
	movq	%r14, %rdx
	xorl	%eax, %eax
	callq	_fprintf
	leaq	L_.str.59(%rip), %rsi
	movq	%r15, %rdi
	movq	%r12, %rdx
	xorl	%eax, %eax
	callq	_fprintf
	leaq	L_.str.60(%rip), %rsi
	movq	%r15, %rdi
	movq	-200(%rbp), %rdx                ## 8-byte Reload
	xorl	%eax, %eax
	callq	_fprintf
	leaq	L_.str.61(%rip), %rsi
	movq	%r15, %rdi
	movq	-104(%rbp), %rbx                ## 8-byte Reload
	movq	%rbx, %rdx
	movq	-128(%rbp), %rcx                ## 8-byte Reload
	xorl	%eax, %eax
	callq	_fprintf
	cmpq	%r12, %rbx
	leaq	L_.str.64(%rip), %rax
	leaq	L_.str.63(%rip), %r12
	movq	%r12, %rdx
	cmovbq	%rax, %rdx
	leaq	L_.str.62(%rip), %rsi
	movq	%r15, %rdi
	xorl	%eax, %eax
	callq	_fprintf
	cmpw	$2, -112(%rbp)                  ## 2-byte Folded Reload
	movq	-56(%rbp), %rax                 ## 8-byte Reload
	movq	-144(%rbp), %rcx                ## 8-byte Reload
	jb	LBB0_175
## %bb.165:
	addq	$-88, %rcx
	leaq	L_.str.65(%rip), %r14
	xorl	%r13d, %r13d
	movq	%rcx, %rbx
	jmp	LBB0_166
	.p2align	4
LBB0_169:                               ##   in Loop: Header=BB0_166 Depth=1
	addq	$88, %r13
	cmpq	%r13, %rcx
	je	LBB0_170
LBB0_166:                               ## =>This Inner Loop Header: Depth=1
	cmpl	$0, 168(%rax,%r13)
	je	LBB0_169
## %bb.167:                             ##   in Loop: Header=BB0_166 Depth=1
	cmpl	$8, 96(%rax,%r13)
	je	LBB0_169
## %bb.168:                             ##   in Loop: Header=BB0_166 Depth=1
	movq	160(%rax,%r13), %rcx
	movq	152(%rax,%r13), %r8
	movq	88(%rax,%r13), %rdx
	movq	-56(%rbp), %rax                 ## 8-byte Reload
	movq	120(%rax,%r13), %r9
	movq	%r12, (%rsp)
	movq	%r15, %rdi
	movq	%r14, %rsi
	xorl	%eax, %eax
	callq	_fprintf
	movq	%rbx, %rcx
	movq	-56(%rbp), %rax                 ## 8-byte Reload
	jmp	LBB0_169
LBB0_170:
	leaq	L_.str.65(%rip), %r14
	xorl	%r12d, %r12d
	leaq	L_.str.64(%rip), %r13
	jmp	LBB0_171
	.p2align	4
LBB0_174:                               ##   in Loop: Header=BB0_171 Depth=1
	addq	$88, %r12
	cmpq	%r12, %rcx
	je	LBB0_175
LBB0_171:                               ## =>This Inner Loop Header: Depth=1
	cmpl	$0, 168(%rax,%r12)
	je	LBB0_174
## %bb.172:                             ##   in Loop: Header=BB0_171 Depth=1
	cmpl	$8, 96(%rax,%r12)
	jne	LBB0_174
## %bb.173:                             ##   in Loop: Header=BB0_171 Depth=1
	movq	160(%rax,%r12), %rcx
	movq	152(%rax,%r12), %r8
	movq	88(%rax,%r12), %rdx
	movq	-56(%rbp), %rax                 ## 8-byte Reload
	movq	120(%rax,%r12), %r9
	movq	%r13, (%rsp)
	movq	%r15, %rdi
	movq	%r14, %rsi
	xorl	%eax, %eax
	callq	_fprintf
	movq	%rbx, %rcx
	movq	-56(%rbp), %rax                 ## 8-byte Reload
	jmp	LBB0_174
LBB0_175:
	leaq	L_.str.67(%rip), %r12
	leaq	L_.str.47(%rip), %rdx
	leaq	L_.str.66(%rip), %r14
	movq	%r15, %rdi
	movq	%r12, %rsi
	movq	-96(%rbp), %rcx                 ## 8-byte Reload
	movq	%r14, %r8
	xorl	%r9d, %r9d
	xorl	%eax, %eax
	callq	_fprintf
	leaq	L_.str.48(%rip), %rdx
	movq	%r15, %rdi
	movq	%r12, %rsi
	movq	-168(%rbp), %rcx                ## 8-byte Reload
	movq	%r14, %r8
	xorl	%r9d, %r9d
	xorl	%eax, %eax
	callq	_fprintf
	leaq	L_.str.45(%rip), %rdx
	movq	%r15, %rdi
	movq	%r12, %rsi
	movq	-104(%rbp), %rcx                ## 8-byte Reload
	movq	%r14, %r8
	xorl	%r9d, %r9d
	xorl	%eax, %eax
	callq	_fprintf
	leaq	L_.str.46(%rip), %rdx
	movq	%r15, %rdi
	movq	%r12, %rsi
	movq	-128(%rbp), %rcx                ## 8-byte Reload
	movq	%r14, %r8
	xorl	%r9d, %r9d
	xorl	%eax, %eax
	callq	_fprintf
	movq	-56(%rbp), %rcx                 ## 8-byte Reload
	movq	-208(%rbp), %rax                ## 8-byte Reload
	cmpq	%rax, -184(%rbp)                ## 8-byte Folded Reload
	movq	-80(%rbp), %rsi                 ## 8-byte Reload
	jbe	LBB0_176
LBB0_184:
	movq	%r15, %rdi
	callq	_fclose
LBB0_185:
	movq	-88(%rbp), %rdi                 ## 8-byte Reload
	callq	_free
	movq	-160(%rbp), %rdi                ## 8-byte Reload
	callq	_free
	movq	-56(%rbp), %rdi                 ## 8-byte Reload
	callq	_free
	movq	-64(%rbp), %rdi                 ## 8-byte Reload
	callq	_free
	xorl	%eax, %eax
LBB0_186:
	addq	$184, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB0_176:
	movq	-160(%rbp), %rbx                ## 8-byte Reload
	addq	$24, %rbx
	leaq	L_.str.67(%rip), %r12
	xorl	%r14d, %r14d
	jmp	LBB0_177
	.p2align	4
LBB0_183:                               ##   in Loop: Header=BB0_177 Depth=1
	incq	%r14
	addq	$40, %rbx
	cmpq	%rsi, %r14
	jae	LBB0_184
LBB0_177:                               ## =>This Inner Loop Header: Depth=1
	movq	-24(%rbx), %rdx
	testq	%rdx, %rdx
	je	LBB0_183
## %bb.178:                             ##   in Loop: Header=BB0_177 Depth=1
	cmpb	$0, (%rdx)
	je	LBB0_183
## %bb.179:                             ##   in Loop: Header=BB0_177 Depth=1
	movzwl	-16(%rbx), %eax
	testq	%rax, %rax
	je	LBB0_183
## %bb.180:                             ##   in Loop: Header=BB0_177 Depth=1
	cmpw	%ax, -112(%rbp)                 ## 2-byte Folded Reload
	jbe	LBB0_183
## %bb.181:                             ##   in Loop: Header=BB0_177 Depth=1
	imulq	$88, %rax, %rax
	cmpl	$0, 80(%rcx,%rax)
	je	LBB0_183
## %bb.182:                             ##   in Loop: Header=BB0_177 Depth=1
	addq	%rcx, %rax
	movq	-8(%rbx), %rcx
	movq	(%rbx), %r9
	addq	72(%rax), %rcx
	movq	(%rax), %r8
	movq	%r15, %rdi
	movq	%r12, %rsi
	xorl	%eax, %eax
	callq	_fprintf
	movq	-80(%rbp), %rsi                 ## 8-byte Reload
	movq	-56(%rbp), %rcx                 ## 8-byte Reload
	jmp	LBB0_183
LBB0_240:
	callq	_main.cold.33
LBB0_241:
	callq	_main.cold.32
LBB0_242:
	callq	_main.cold.31
LBB0_243:
	callq	_main.cold.30
LBB0_244:
	callq	_main.cold.29
LBB0_245:
	callq	_main.cold.28
LBB0_246:
	callq	_main.cold.18
LBB0_252:
	callq	_main.cold.22
LBB0_249:
	callq	_main.cold.25
LBB0_251:
	callq	_main.cold.23
LBB0_253:
	callq	_main.cold.21
LBB0_250:
	callq	_main.cold.24
LBB0_254:
	movl	%r13d, %edi
	callq	_main.cold.26
LBB0_247:
	callq	_main.cold.20
LBB0_248:
	callq	_main.cold.27
LBB0_189:
	movq	%rbx, %rdi
	callq	_main.cold.4
LBB0_222:
	callq	_main.cold.40
LBB0_219:
	callq	_main.cold.43
LBB0_212:
	callq	_main.cold.50
LBB0_220:
	callq	_main.cold.42
LBB0_217:
	callq	_main.cold.45
LBB0_210:
	callq	_main.cold.52
LBB0_211:
	callq	_main.cold.51
LBB0_50:
	callq	_main.cold.54
LBB0_209:
	callq	_main.cold.53
LBB0_215:
	callq	_main.cold.47
LBB0_213:
	callq	_main.cold.49
LBB0_214:
	callq	_main.cold.48
LBB0_216:
	callq	_main.cold.46
LBB0_218:
	callq	_main.cold.44
LBB0_221:
	callq	_main.cold.41
LBB0_208:
	callq	_main.cold.6
LBB0_191:
	callq	_main.cold.1
LBB0_188:
	callq	_main.cold.3
LBB0_227:
	callq	_main.cold.14
LBB0_229:
	callq	_main.cold.13
LBB0_230:
	callq	_main.cold.12
LBB0_231:
	callq	_main.cold.11
LBB0_232:
	callq	_main.cold.10
LBB0_233:
	callq	_main.cold.9
LBB0_234:
	callq	_main.cold.8
LBB0_228:
	callq	_main.cold.7
LBB0_238:
	callq	_main.cold.17
LBB0_190:
	callq	_main.cold.2
LBB0_141:
	movq	-152(%rbp), %rdi                ## 8-byte Reload
	callq	_main.cold.19
LBB0_187:
	callq	_main.cold.5
LBB0_236:
	callq	_main.cold.15
LBB0_239:
	callq	_main.cold.34
LBB0_193:
	leaq	L_.str.12(%rip), %rsi
	movq	-48(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB0_197:
	leaq	L_.str.19(%rip), %rsi
	movq	-48(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB0_198:
	leaq	L_.str.20(%rip), %rsi
	movq	-48(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB0_192:
	movq	-48(%rbp), %rdi                 ## 8-byte Reload
	callq	_main.cold.61
LBB0_194:
	leaq	L_.str.13(%rip), %rsi
	movq	-48(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB0_195:
	callq	_main.cold.60
LBB0_30:
	movq	%r12, %rdi
	callq	_fclose
LBB0_31:
	leaq	L_.str.18(%rip), %rsi
	movq	-48(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB0_196:
	leaq	L_.str.14(%rip), %rsi
	movq	-48(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB0_199:
	leaq	L_.str.21(%rip), %rsi
	movq	-48(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB0_200:
	leaq	L_.str.22(%rip), %rsi
	movq	-48(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB0_201:
	leaq	L_.str.23(%rip), %rsi
	movq	-48(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB0_202:
	callq	_main.cold.59
LBB0_203:
	callq	_main.cold.58
LBB0_204:
	callq	_main.cold.57
LBB0_205:
	callq	_main.cold.56
LBB0_206:
	leaq	L_.str.24(%rip), %rsi
	movq	-48(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB0_207:
	callq	_main.cold.55
LBB0_223:
	leaq	L_.str.29(%rip), %rsi
	movq	-48(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB0_224:
	leaq	L_.str.30(%rip), %rsi
	movq	-48(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB0_225:
	leaq	L_.str.31(%rip), %rsi
	movq	-48(%rbp), %rdi                 ## 8-byte Reload
	callq	_die_path
LBB0_226:
	callq	_main.cold.39
LBB0_102:
	callq	_main.cold.38
LBB0_237:
	callq	_main.cold.37
LBB0_158:
	movq	-136(%rbp), %rdi                ## 8-byte Reload
	callq	_main.cold.36
LBB0_255:
	leaq	L_.str.54(%rip), %rsi
	movq	-136(%rbp), %rdi                ## 8-byte Reload
	callq	_die_path
LBB0_256:
	movq	%rbx, %rdi
	callq	_main.cold.35
                                        ## -- End function
	.p2align	4                               ## -- Begin function die
_die:                                   ## @die
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, %rdx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.9(%rip), %rsi
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function die_path
_die_path:                              ## @die_path
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rsi, %rcx
	movq	%rdi, %rdx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.15(%rip), %rsi
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.1
_main.cold.1:                           ## @main.cold.1
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.7(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.2
_main.cold.2:                           ## @main.cold.2
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.5(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.3
_main.cold.3:                           ## @main.cold.3
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.3(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.4
_main.cold.4:                           ## @main.cold.4
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, %rdx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.10(%rip), %rsi
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.5
_main.cold.5:                           ## @main.cold.5
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.1(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.6
_main.cold.6:                           ## @main.cold.6
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.27(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.7
_main.cold.7:                           ## @main.cold.7
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.27(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.8
_main.cold.8:                           ## @main.cold.8
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.26(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.9
_main.cold.9:                           ## @main.cold.9
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.26(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.10
_main.cold.10:                          ## @main.cold.10
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.26(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.11
_main.cold.11:                          ## @main.cold.11
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.26(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.12
_main.cold.12:                          ## @main.cold.12
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.26(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.13
_main.cold.13:                          ## @main.cold.13
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.28(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.14
_main.cold.14:                          ## @main.cold.14
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.26(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.15
_main.cold.15:                          ## @main.cold.15
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.33(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.16
_main.cold.16:                          ## @main.cold.16
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.36(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.17
_main.cold.17:                          ## @main.cold.17
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.37(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.18
_main.cold.18:                          ## @main.cold.18
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.41(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.19
_main.cold.19:                          ## @main.cold.19
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, %rdx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.42(%rip), %rsi
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.20
_main.cold.20:                          ## @main.cold.20
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.43(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.21
_main.cold.21:                          ## @main.cold.21
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.52(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.22
_main.cold.22:                          ## @main.cold.22
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.39(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.23
_main.cold.23:                          ## @main.cold.23
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.51(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.24
_main.cold.24:                          ## @main.cold.24
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.50(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.25
_main.cold.25:                          ## @main.cold.25
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.49(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.26
_main.cold.26:                          ## @main.cold.26
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	movl	%edi, %edx
	movq	___stderrp@GOTPCREL(%rip), %rax
	movq	(%rax), %rdi
	leaq	L_.str.40(%rip), %rsi
	xorl	%eax, %eax
	callq	_fprintf
	pushq	$1
	popq	%rdi
	callq	_exit
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.27
_main.cold.27:                          ## @main.cold.27
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.44(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.28
_main.cold.28:                          ## @main.cold.28
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.26(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.29
_main.cold.29:                          ## @main.cold.29
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.26(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.30
_main.cold.30:                          ## @main.cold.30
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.26(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.31
_main.cold.31:                          ## @main.cold.31
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.26(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.32
_main.cold.32:                          ## @main.cold.32
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.26(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.33
_main.cold.33:                          ## @main.cold.33
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.26(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.34
_main.cold.34:                          ## @main.cold.34
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.38(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.35
_main.cold.35:                          ## @main.cold.35
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%rbx
	pushq	%rax
	movq	%rdi, %rbx
	callq	___error
	movl	(%rax), %edi
	callq	_strerror
	movq	%rbx, %rdi
	movq	%rax, %rsi
	callq	_die_path
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.36
_main.cold.36:                          ## @main.cold.36
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%rbx
	pushq	%rax
	movq	%rdi, %rbx
	callq	___error
	movl	(%rax), %edi
	callq	_strerror
	movq	%rbx, %rdi
	movq	%rax, %rsi
	callq	_die_path
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.37
_main.cold.37:                          ## @main.cold.37
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.16(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.38
_main.cold.38:                          ## @main.cold.38
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.34(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.39
_main.cold.39:                          ## @main.cold.39
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.16(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.40
_main.cold.40:                          ## @main.cold.40
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.26(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.41
_main.cold.41:                          ## @main.cold.41
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.26(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.42
_main.cold.42:                          ## @main.cold.42
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.26(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.43
_main.cold.43:                          ## @main.cold.43
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.26(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.44
_main.cold.44:                          ## @main.cold.44
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.26(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.45
_main.cold.45:                          ## @main.cold.45
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.26(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.46
_main.cold.46:                          ## @main.cold.46
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.26(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.47
_main.cold.47:                          ## @main.cold.47
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.26(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.48
_main.cold.48:                          ## @main.cold.48
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.26(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.49
_main.cold.49:                          ## @main.cold.49
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.26(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.50
_main.cold.50:                          ## @main.cold.50
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.26(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.51
_main.cold.51:                          ## @main.cold.51
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.26(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.52
_main.cold.52:                          ## @main.cold.52
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.26(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.53
_main.cold.53:                          ## @main.cold.53
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.28(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.54
_main.cold.54:                          ## @main.cold.54
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.26(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.55
_main.cold.55:                          ## @main.cold.55
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.16(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.56
_main.cold.56:                          ## @main.cold.56
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.26(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.57
_main.cold.57:                          ## @main.cold.57
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.26(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.58
_main.cold.58:                          ## @main.cold.58
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.26(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.59
_main.cold.59:                          ## @main.cold.59
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.26(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.60
_main.cold.60:                          ## @main.cold.60
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	L_.str.16(%rip), %rdi
	callq	_die
                                        ## -- End function
	.p2align	4                               ## -- Begin function main.cold.61
_main.cold.61:                          ## @main.cold.61
## %bb.0:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%rbx
	pushq	%rax
	movq	%rdi, %rbx
	callq	___error
	movl	(%rax), %edi
	callq	_strerror
	movq	%rbx, %rdi
	movq	%rax, %rsi
	callq	_die_path
                                        ## -- End function
	.section	__TEXT,__cstring,cstring_literals
L_.str.1:                               ## @.str.1
	.asciz	"-o requires an output path"

L_.str.2:                               ## @.str.2
	.asciz	"--base"

L_.str.3:                               ## @.str.3
	.asciz	"--base requires an address"

L_.str.4:                               ## @.str.4
	.asciz	"--map"

L_.str.5:                               ## @.str.5
	.asciz	"--map requires an output path"

L_.str.6:                               ## @.str.6
	.asciz	"link_aarch64_flat: unknown option %s\n"

L_.str.7:                               ## @.str.7
	.asciz	"only one input object is supported"

L_.str.8:                               ## @.str.8
	.asciz	"usage: link_aarch64_flat -o OUTPUT --base 0xADDR [--map MAP] INPUT.o\n"

L_.str.9:                               ## @.str.9
	.asciz	"link_aarch64_flat: %s\n"

L_.str.10:                              ## @.str.10
	.asciz	"link_aarch64_flat: invalid address: %s\n"

L_.str.11:                              ## @.str.11
	.asciz	"rb"

L_.str.12:                              ## @.str.12
	.asciz	"seek failed"

L_.str.13:                              ## @.str.13
	.asciz	"tell failed"

L_.str.14:                              ## @.str.14
	.asciz	"read failed"

L_.str.15:                              ## @.str.15
	.asciz	"link_aarch64_flat: %s: %s\n"

L_.str.16:                              ## @.str.16
	.asciz	"out of memory"

L_.str.17:                              ## @.str.17
	.asciz	"\177ELF"

L_.str.18:                              ## @.str.18
	.asciz	"not an ELF file"

L_.str.19:                              ## @.str.19
	.asciz	"expected ELF64 little-endian"

L_.str.20:                              ## @.str.20
	.asciz	"expected AArch64 relocatable ELF"

L_.str.21:                              ## @.str.21
	.asciz	"section header size too small"

L_.str.22:                              ## @.str.22
	.asciz	"section string table index out of range"

L_.str.23:                              ## @.str.23
	.asciz	"section headers out of range"

L_.str.24:                              ## @.str.24
	.asciz	"section string table out of range"

L_.str.25:                              ## @.str.25
	.asciz	"section data out of range"

L_.str.26:                              ## @.str.26
	.asciz	"unexpected end of file"

L_.str.27:                              ## @.str.27
	.asciz	"string table offset out of range"

L_.str.28:                              ## @.str.28
	.asciz	"unterminated string table entry"

L_.str.29:                              ## @.str.29
	.asciz	"symbol string table link out of range"

L_.str.30:                              ## @.str.30
	.asciz	"symbol table has zero entry size"

L_.str.31:                              ## @.str.31
	.asciz	"symbol string table out of range"

L_.str.32:                              ## @.str.32
	.asciz	"missing symbol table"

L_.str.33:                              ## @.str.33
	.asciz	"section alignment is not a power of two"

L_.str.34:                              ## @.str.34
	.asciz	"no allocated file-backed sections"

L_.str.36:                              ## @.str.36
	.asciz	"section output range is outside image"

L_.str.37:                              ## @.str.37
	.asciz	"relocation target section out of range"

L_.str.38:                              ## @.str.38
	.asciz	"unsupported RELA entry size"

L_.str.39:                              ## @.str.39
	.asciz	"ABS64 relocation target outside output"

L_.str.40:                              ## @.str.40
	.asciz	"link_aarch64_flat: unsupported AArch64 relocation %u\n"

L_.str.41:                              ## @.str.41
	.asciz	"relocation symbol index out of range"

L_.str.42:                              ## @.str.42
	.asciz	"link_aarch64_flat: unresolved symbol: %s\n"

L_.str.43:                              ## @.str.43
	.asciz	"symbol section out of range"

L_.str.44:                              ## @.str.44
	.asciz	"symbol is not in an allocated section"

L_.str.45:                              ## @.str.45
	.asciz	"__bss_start"

L_.str.46:                              ## @.str.46
	.asciz	"__bss_end"

L_.str.47:                              ## @.str.47
	.asciz	"__pi4_image_base"

L_.str.48:                              ## @.str.48
	.asciz	"__pi4_image_end"

L_.str.49:                              ## @.str.49
	.asciz	"ADR relocation target outside output"

L_.str.50:                              ## @.str.50
	.asciz	"ADR relocation is out of +/-1 MiB range"

L_.str.51:                              ## @.str.51
	.asciz	"ADR relocation target is not an ADR instruction"

L_.str.52:                              ## @.str.52
	.asciz	"write past output"

L_.str.53:                              ## @.str.53
	.asciz	"wb"

L_.str.54:                              ## @.str.54
	.asciz	"write failed"

L_.str.55:                              ## @.str.55
	.asciz	"w"

L_.str.56:                              ## @.str.56
	.asciz	"# vibe-os-aarch64-flat-map-v1\n"

L_.str.57:                              ## @.str.57
	.asciz	"base=0x%016llX\n"

L_.str.58:                              ## @.str.58
	.asciz	"file_size=0x%016llX\n"

L_.str.59:                              ## @.str.59
	.asciz	"file_end=0x%016llX\n"

L_.str.60:                              ## @.str.60
	.asciz	"mem_size=0x%016llX\n"

L_.str.61:                              ## @.str.61
	.asciz	"bss=0x%016llX/0x%016llX\n"

L_.str.62:                              ## @.str.62
	.asciz	"bss_after_file=%s\n"

L_.str.63:                              ## @.str.63
	.asciz	"YES"

L_.str.64:                              ## @.str.64
	.asciz	"NO"

L_.str.65:                              ## @.str.65
	.asciz	"section=%s addr=0x%016llX off=0x%016llX size=0x%016llX file=%s\n"

L_.str.66:                              ## @.str.66
	.asciz	"synthetic"

L_.str.67:                              ## @.str.67
	.asciz	"symbol=%s addr=0x%016llX section=%s size=0x%016llX\n"

.subsections_via_symbols
