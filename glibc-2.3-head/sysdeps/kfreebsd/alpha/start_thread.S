/* Copyright (C) 2002 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by Bruno Haible <bruno@clisp.org>, 2002.

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

/* __start_thread (flags, stack, func, arg)
   calls __rfork (flags), and in the child sets the stack pointer and then
   calls _exit (func (arg)).
   It cannot be done in portable C.  */

#include <sysdep.h>
#define SIG_SETMASK	3

	.text
ENTRY (__start_thread)
	/* There is a window of a few instructions, right after the rfork
	   system call, where the handling of a signal would write garbage
	   into the stack shared by the parent and the child (assuming
	   RFMEM is set in flags).  To solve this: 1. We block all signals
	   around the rfork system call and unblock them afterwards in
	   the parent and in the child (but only after changing the stack
	   pointer).  2. The child accesses only values passed in registers
	   and on its own stack.  This way, if the parent is scheduled to
	   run first, and handles a signal, it will not affect the child;
	   and if the child runs first, and handles a signal, it will use
	   the child's stack and not affect the parent.
	   We need to pass 7 words of info to the child: stack, func, arg,
	   and the signal mask to restore.  Since we have only 4 call-saved
	   registers available (%ebx, %esi, %edi, %ebp), we pass only the
	   stack pointer in a register, and the rest through the child's
	   stack.  */
	lda	sp,-56(sp)
	stq	ra,0(sp)
	stq	s0,8(sp)
	stq	s1,16(sp)
	stq	s2,24(sp)
	stq	s3,32(sp)
	.prologue 1

	/* Save arguments.  */
	mov	a0,s1		/* flags */
	mov	a1,s0		/* stack */
	mov	a2,s2		/* func */
	mov	a3,s3		/* arg */

	and	a0,32,t0	/* flags & RFMEM */
	beq	t0,$simple

	/* Block all signals.  */
	lda	t0,-1
	stq	t0,40(sp)
	stq	t0,48(sp)
	lda	a0,SIG_SETMASK
	lda	a1,40(sp)
	mov	a1,a2
	lda	v0,SYS_sigprocmask
	call_pal PAL_callsys
	bne	a3,$error

	/* Copy all info to the child's stack.  */
	lda	s0,-32(s0)	/* room for func, arg, sigset_t */
	andnot	s0,7,s0		/* make it 8-bytes aligned */
	stq	s2,8(s0)	/* func */
	stq	s3,0(s0)	/* arg */
	ldq	t0,40(sp)	/* sigset_t word 0 */
	ldq	t1,48(sp)	/* sigset_t word 1 */
	stq	t0,16(s0)
	stq	t1,24(s0)

	/* Perform the rfork system call.  */
	mov	s1,a0		/* flags */
	lda	v0,SYS_rfork
	call_pal PAL_callsys
	bne	a3,$error

	/* a4 is now 0 for the parent and 1 for the child.  */
	bne	a4,$child

	/* Save the child pid, currently in v0.  */
	mov	v0,s1

	/* Restore the previous signal mask.  */
	lda	a0,SIG_SETMASK
	lda	a1,40(sp)
	mov	zero,a2
	lda	v0,SYS_sigprocmask
	call_pal PAL_callsys

	/* Return the child pid, currently in s1.  */
	mov	s1,v0
$retv0:	ldq	ra,0(sp)
	ldq	s0,8(sp)
	ldq	s1,16(sp)
	ldq	s2,24(sp)
	ldq	s3,32(sp)
	lda	sp,56(sp)
	ret	zero,(ra),1

$child:	/* Here we are in the child thread.  */

	/* Set the stack pointer.  */
	mov	s0,sp

	/* Restore the previous signal mask.  */
	lda	a0,SIG_SETMASK
	lda	a1,16(sp)
	mov	zero,a2
	lda	v0,SYS_sigprocmask
	call_pal PAL_callsys

$child1:
	/* Call func (arg).  */
	ldq	a0,0(sp)
	ldq	pv,8(sp)
	jsr	ra,(pv),0

	/* Tail-call _exit.  */
	br	gp,$here
$here:	ldgp	gp,0(gp)
	mov	v0,a0
	jmp	zero,_exit

$simple:/* Simple case without signal mask handling.  */

	/* Copy all info to the child's stack.  */
	lda	s0,-16(s0)	/* room for func, arg */
	andnot	s0,7,s0		/* make it 8-bytes aligned */
	stq	s2,8(s0)	/* func */
	stq	s3,0(s0)	/* arg */

	/* Perform the rfork system call.  */
	mov	s1,a0		/* flags */
	lda	v0,SYS_rfork
	call_pal PAL_callsys
	bne	a3,$error

	/* a4 is now 0 for the parent and 1 for the child.  */
	/* If in the parent, return the child pid, currently in v0.  */
	beq	a4,$retv0

$simple_child:/* Here we are in the child thread.  */

	/* Set the stack pointer.  */
	mov	s0,sp

	br	zero,$child1

$error:	ldq	ra,0(sp)
	ldq	s0,8(sp)
	ldq	s1,16(sp)
	ldq	s2,24(sp)
	ldq	s3,32(sp)
	lda	sp,56(sp)
#if 0 /* Not needed: The PSEUDO_END expansion starts with this label.  */
	br	zero,1996f
#endif

PSEUDO_END (__start_thread)
