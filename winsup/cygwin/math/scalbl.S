/**
 * This file has no copyright assigned and is placed in the Public Domain.
 * This file is part of the mingw-w64 runtime package.
 * No warranty is given; refer to the file DISCLAIMER.PD within this package.
 */
#include <_mingw_mac.h>

	.file	"scalbl.S"
	.text
#if defined(__x86_64__)
	.align 8
#elif defined(__i386__)
	.align 4
#endif
.globl __MINGW_USYMBOL(scalbl)
	.def	__MINGW_USYMBOL(scalbl);	.scl	2;	.type	32;	.endef
__MINGW_USYMBOL(scalbl):
#if defined(__x86_64__)
	subq  $24, %rsp
	fldt	(%r8)
	fldt	(%rdx)
	fscale
	fstp	%st(1)
	movq	%rcx,%rax
	movq	$0,8(%rcx)
	fstpt	(%rcx)
	addq $24, %rsp
	ret
#elif defined(__i386__)
	fildl	16(%esp)
	fldt	4(%esp)
	fscale
	fstp	%st(1)
	ret
#elif defined(__aarch64__)
	// TODO
#else
	.error "Not supported on your platform yet"
#endif
