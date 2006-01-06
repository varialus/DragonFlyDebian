/* Copyright (C) 2001, 2002, 2003, 2004 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Modification for FreeBSD contributed by Petr Salinger, 2006.

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

/*
   The parameters are passed in registers:
   rdi: flags for rfork
   rsi: child_stack
   rdx: func
   rcx: arg
*/

#include <sysdep.h>
#define _ERRNO_H        1
#include <bits/errno.h>
#include <asm-syntax.h>
#include <bp-sym.h>
#include <bp-asm.h>

	.text
ENTRY (__start_thread)
        movq    $-EINVAL,%rax
        testq   %rdx,%rdx               /* no NULL function pointers */
        jz      SYSCALL_ERROR_LABEL
        testq   %rsi,%rsi               /* no NULL stack pointers */
        jz      SYSCALL_ERROR_LABEL

        /* Insert the argument onto the new stack.  */
        subq    $16,%rsi
        movq    %rcx,8(%rsi)

        /* Save the function pointer.  It will be popped off in the child */
        movq    %rdx,0(%rsi)

        /* Do the system call.  */
	movq    $SYS_ify(rfork),%rax
        /* End FDE now, because in the child the unwind info will be
           wrong.  */
        cfi_endproc;
        syscall			/* rdi and rsi are extra preserved */

        jb SYSCALL_ERROR_LABEL

	testq   %rdx,%rdx	/*  0 for the parent and 1 for the child */
	jnz     L(thread_start)

L(pseudo_end):
        ret

L(thread_start):

	/* set up stack */
	movq	%rsi, %rsp

        /* Clear the frame pointer.  The ABI suggests this be done, to mark
           the outermost frame obviously.  */
        xorq    %rbp, %rbp

        /* Set up arguments for the function call.  */
        popq    %rax            /* Function to call.  */
        popq    %rdi            /* Argument.  */
        call    *%rax

        /* Call exit with return value from function call. */
        movq    %rax, %rdi
        call    HIDDEN_JUMPTARGET (_exit)

        cfi_startproc;

PSEUDO_END (__start_thread)
