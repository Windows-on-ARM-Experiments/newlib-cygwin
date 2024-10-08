/*
   Copyright (c) 2015-2024, Synopsys, Inc. All rights reserved.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are met:

   1) Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.

   2) Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

   3) Neither the name of the Synopsys, Inc., nor the names of its contributors
   may be used to endorse or promote products derived from this software
   without specific prior written permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
   ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
   POSSIBILITY OF SUCH DAMAGE.
*/

/*
   The startup code for the ARC family of processors does the following before
   transferring control to user defined main label:
       1.  Set sp to __stack_top (link time variable)
       2.  Set fp to zero
       3.  Zero out the bss section (for uninitialized globals)
   After returning from main, the processor is halted and the pipeline is
   flushed out.

   We expect argc in r0 and argv in r1.  These are saved in r13 / r14 during
   the initialization code.
*/

#include "arc-symbols.h"

/* Compatibility with older ARC GCC, that doesn't provide some of the
   preprocessor defines used by newlib and libgloss for ARC.  */
#if defined (__Xbarrel_shifter) && !defined (__ARC_BARREL_SHIFTER__)
#define __ARC_BARREL_SHIFTER__ 1
#endif

#if defined (__EM__) && !defined (__ARCEM__)
#define __ARCEM__ 1
#endif

#if defined (__HS__) && !defined (__ARCHS__)
#define __ARCHS__ 1
#endif

	.extern main

#if defined (__ARCEM__) || defined (__ARCHS__)
	.section .ivt, "a", @progbits

; Helper macro to define weak symbols to include into interrupt vector table.
; User code may define those functions in them, so user function will be
; referenced in the IVT. By default all handlers point to _exit_halt - so they
; always cause application halt, because if application causes an exception or
; interrupt, but doesn't set a handler for it - something is wrong in
; application. Exception is "start" entry of IVT, which points to __start
; function.
#define IVT_ENTRY(name) \
    .word name `\
    .weak name `\
    .set name, _exit_halt

; handler's name,          number, name,       offset in IVT (hex/dec)
.word __start                ; 0   program entry point  0x0     0
IVT_ENTRY(memory_error)      ; 1   memory_error         0x4     4
IVT_ENTRY(instruction_error) ; 2   instruction_error    0x8     8
IVT_ENTRY(EV_MachineCheck)   ; 3   EV_MachineCheck      0xC     12
IVT_ENTRY(EV_TLBMissI)       ; 4   EV_TLBMissI          0x10    16
IVT_ENTRY(EV_TLBMissD)       ; 5   EV_TLBMissD          0x14    20
IVT_ENTRY(EV_ProtV)          ; 6   EV_ProtV             0x18    24
IVT_ENTRY(EV_PrivilegeV)     ; 7   EV_PrivilegeV        0x1C    28
IVT_ENTRY(EV_SWI)            ; 8   EV_SWI               0x20    32
IVT_ENTRY(EV_Trap)           ; 9   EV_Trap              0x24    36
IVT_ENTRY(EV_Extension)      ; 10  EV_Extension         0x28    40
IVT_ENTRY(EV_DivZero)        ; 11  EV_DivZero           0x2C    44
IVT_ENTRY(EV_DCError)        ; 12  EV_DCError           0x30    48
IVT_ENTRY(EV_Maligned)       ; 13  EV_Maligned          0x34    52
IVT_ENTRY(EV_Ex14)           ; 14  unused               0x38    56
IVT_ENTRY(EV_Ex15)           ; 15  unused               0x3C    60
IVT_ENTRY(IRQ_Timer0)        ; 16  Timer 0              0x40    64
IVT_ENTRY(IRQ_Timer1)        ; 17  Timer 1              0x44    68
IVT_ENTRY(IRQ_18)            ; 18                       0x48    72
IVT_ENTRY(IRQ_19)            ; 19                       0x4C    76
IVT_ENTRY(IRQ_20)            ; 20                       0x50    80

	.section .text.__startup, "ax", @progbits
#else
	.text
#endif /* __ARCEM__ || __ARCHS__ */

	.global	__start
	.type	__start, @function
	.align 4
#ifdef __ARC601__
; Startup code for the ARC601 processor
__start:
	mov	gp, SMALL_DATA_BASE
	mov	sp, STACK_TOP		; Point to top of stack
	mov	r5, 0			; Zero value
	mov_s	r2, SMALL_DATA_BSS_START	; r2 = start of the bss section
	sub	r3, SMALL_DATA_BSS_START, r2	; r3 = size of the bss section in bytes

	asr_s	r3, r3
	asr_s	r3, r3			; r3 = size of bss in words

.Lbss_loop:
	cmp	r3, 0xff		; Check for max lp_count
	mov.le	lp_count, r3
	mov.gt	lp_count, 0xff
	lpnz	2f			; Loop to zero bss
	st.ab	r5,[r2, 4]		; Write word of zeros
	nop
2:
	sub.f	r3, r3, 0xff		; Decrement word count
	jp	.Lbss_loop

#else	/* __ARC601__ */

; Startup code for the ARC600, ARC700 and ARCv2 processors
; NOTE:  The following restrictions apply on zero overhead loops (other
; restrictions are not pertinent to this code)
; - loop end should be 4 instruction words away from the lp_count setting
;   instruction
; - loop body should have at least two instruction words
__start:
#if defined (__ARCHS__)
	; Allow unaligned accesses.
	lr	r2, [0xA]
	bset	r2, r2, 19
	flag	r2
#endif

#if defined (__ARC_CODE_DENSITY__)
	;; Initialize jli_base
	sr	__JLI_TABLE__,[jli_base]
#endif
	mov	gp, SMALL_DATA_BASE
	mov_s	r2, SMALL_DATA_BSS_START	; r2 = start of the bss section
	sub	r3, SMALL_DATA_BSS_END, r2	; r3 = size of the bss section in bytes
	; set up the loop counter register to the size (in words) of the bss section
#if defined (__ARC_BARREL_SHIFTER__)
	asr.f        lp_count, r3, 2
#else
	asr_s        r13, r3
	asr.f        lp_count, r13
#endif
#if defined (__ARC600__)
	; loop to zero out the bss.  Enter loop only if lp_count != 0
	lpnz	.Lend_zbss
	add	r3, pcl, 20
	sr	r3, [2]			; LP_END
	; initialize stack pointer, and this instruction has 2 words
	mov	sp, STACK_TOP
	mov_s	r3, 0
	st.ab	r3, [r2, 4]		; zero out the word
.Lend_zbss:
#else
	mov	sp, STACK_TOP	; initialize stack pointer
	mov_s	r3,0
	; loop to zero out the bss.  Enter loop only if lp_count != 0
	lpnz	.Lend_zbss
	st.ab	r3,[r2, 4]		; zero out the word
	nop
.Lend_zbss:
#endif

#endif /* !__ARC601__ */

;;; Clear the registers.
	mov_s	r0,0
	mov_s	r1,0
	mov_s	r2,0
	mov_s	r3,0
#ifndef __ARC_RF16__
	mov	r4,0
	mov	r5,0
	mov	r6,0
	mov	r7,0
	mov	r8,0
	mov	r9,0
#endif
	mov	r10,0
	mov	r11,0
	mov_s	r12,0
	mov_s	r13,0
	mov_s	r14,0
	mov_s	r15,0
#ifndef __ARC_RF16__
	mov	r16,0
	mov	r17,0
	mov	r18,0
	mov	r19,0
	mov	r20,0
	mov	r21,0
	mov	r22,0
	mov	r23,0
	mov	r24,0
	mov	r25,0
#endif
	mov	r27,0
	;; SP (r28) is initialized
#if defined (__ARCEM__) || defined (__ARCHS__)
	mov	ilink,0
	mov	r30,0
#else
	mov	ilink1,0
	mov	ilink2,0
#endif /* ARCv2 */

	;; Call constructors
	jl	_init

;;; Setup fini routines to be called from exit
	mov_s	r0, _fini
	jl	atexit

#ifdef PROFILE_SUPPORT /* Defined in gcrt0.S.  */
	mov	r0,__start
	mov	r1,_etext
	jl	_monstartup
#endif /* PROFILE_SUPPORT */

; branch to main
	mov	fp,0			; initialize frame pointer
	jl	__setup_argv_and_call_main

#ifdef PROFILE_SUPPORT
	mov	r13, r0		; Save return code
	jl	_mcleanup
	mov	r0, r13
#endif /* PROFILE_SUPPORT */

	; r0 contains exit code
	j	exit
	.size	__start, .-__start

;;; arc-main-helper.o object can be used to replace this function and
;;; properly set up arguments and/or other low-level stuff.
	.section .text.__setup_argv_and_call_main,"ax",@progbits
	.weak	__setup_argv_and_call_main
	.type	__setup_argv_and_call_main, @function
	.align 4

__setup_argv_and_call_main:
	push_s	blink
; Call main with argc = 0 and *argv[] = 0
	mov	r0, 0
	mov	r1, 0
	jl	main
	pop_s	blink
	j_s	[blink]

.section .text._exit_halt,"ax",@progbits
.global	 _exit_halt
.type	 _exit_halt, @function
	.align 4
_exit_halt:
	; r0 contains exit code
	flag	1
#if defined (__ARC600__) || defined (__ARC700__)
	; ARCompact requires 3 nops after flag 1
	nop
	nop
	nop
#endif
	b	_exit_halt
.align 4
