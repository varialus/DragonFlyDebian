/* Copyright (C) 1993, 1995-1997, 2002 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
   02111-1307 USA.  */

/* Traditional name for the 'brk' system call.  */
#define SYS_brk SYS_obreak

#include <sysdep.h>

#ifdef PIC
.section .bss
	.align 3
	.globl __curbrk
__curbrk: .skip 8
	.type __curbrk,@object
	.size __curbrk,8
#else
.comm __curbrk, 8
#endif

	.text
LEAF(__brk, 8)
	ldgp	gp, 0(t12)
	subq	sp, 8, sp
#ifdef PROF
	.set noat
	lda	AT, _mcount
	jsr	AT, (AT), _mcount
	.set at
#endif
	.prologue 1

	/* Save the requested brk across the system call.  */
	stq	a0, 0(sp)

	ldiq	v0, SYS_brk
	call_pal PAL_callsys

	ldq	a0, 0(sp)

	/* Test for error.  */
	bne	a3, $error

	/* Don't need to handle brk(0) specially, because the kernel doesn't
	   support this way of calling brk anyway.  */

	/* Update __curbrk and return cleanly.  */
	stq	a0, __curbrk
	mov	zero, v0
	addq	sp, 8, sp
	ret

	/* What a horrible way to die.  */
$error:	addq	sp, 8, sp
	jmp	zero, __syscall_error

	END(__brk)

weak_alias (__brk, brk)
