/* Save current context.
   Copyright (C) 2001-2002 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by Ulrich Drepper <drepper@redhat.com>, 2001.

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

#include <sysdep.h>

#include "ucontext_i.h"


ENTRY(__getcontext)
	/* Load address of the context data structure.  */
	movl	4(%esp), %eax

	/* Return value of getcontext.  EAX is the only register whose
	   value is not preserved.  */
	movl	$0, oEAX(%eax)

	/* Save the 32-bit register values and the return address.  */
	movl	%ecx, oECX(%eax)
	movl	%edx, oEDX(%eax)
	movl	%edi, oEDI(%eax)
	movl	%esi, oESI(%eax)
	movl	%ebp, oEBP(%eax)
	movl	(%esp), %ecx
	movl	%ecx, oEIP(%eax)
	leal	4(%esp), %ecx		/* Exclude the return address.  */
	movl	%ecx, oESP(%eax)
	movl	%ebx, oEBX(%eax)

	/* Save the FS segment register.  We don't touch the GS register
	   since it is used for threads.  */
	xorl	%edx, %edx
	movw	%fs, %dx
	movl	%edx, oFS(%eax)

	/* Save the floating-point registers.  */
	leal	oFPREGSMEM(%eax), %ecx
	/* Save the floating-point context.  */
	fnstenv	(%ecx)

	/* Save the current signal mask.  */
	pushl	%ebx
	leal	oSIGMASK(%eax), %eax
	pushl	%eax
	pushl	$0
	pushl	$SIG_BLOCK
	pushl	$0			/* Dummy return address.  */
	movl	$SYS_sigprocmask, %eax
	int	$0x80
	addl	$16, %esp
	popl	%ebx
	jb	SYSCALL_ERROR_LABEL	/* Jump to error handler if error.  */

	/* All done, return 0 for success.  */
	xorl	%eax, %eax
	ret

PSEUDO_END(__getcontext)

weak_alias(__getcontext, getcontext)
