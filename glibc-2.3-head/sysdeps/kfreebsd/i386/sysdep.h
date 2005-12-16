/* Copyright (C) 1991-1993, 1995-2000, 2002 Free Software Foundation, Inc.
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

#ifndef _FREEBSD_I386_SYSDEP_H
#define _FREEBSD_I386_SYSDEP_H 1

/* There is some commonality.  */
#include <sysdeps/unix/i386/sysdep.h>
#include <bp-sym.h>
#include <bp-asm.h>

#ifdef __ASSEMBLER__

/* We don't want the label for the error handler to be global when we define
   it here.  */
#ifdef PIC
# define SYSCALL_ERROR_LABEL 0f
#else
# define SYSCALL_ERROR_LABEL syscall_error
#endif

#undef	PSEUDO
#define	PSEUDO(name, syscall_name, args)				      \
  .text;								      \
  ENTRY (name)								      \
    DO_CALL (syscall_name, args);					      \
    jb SYSCALL_ERROR_LABEL;

#undef	PSEUDO_END
#define	PSEUDO_END(name)						      \
  SYSCALL_ERROR_HANDLER							      \
  END (name)

#undef  PSEUDO_NOERRNO
#define PSEUDO_NOERRNO(name, syscall_name, args)			      \
  .text;								      \
  ENTRY (name)								      \
    DO_CALL (syscall_name, args)

#undef  PSEUDO_END_NOERRNO
#define PSEUDO_END_NOERRNO(name)					      \
  END (name)

#define ret_NOERRNO ret

#ifndef PIC
#define SYSCALL_ERROR_HANDLER	/* Nothing here; code in sysdep.S is used.  */
#else
/* Store %eax into errno through the GOT.  */
#ifdef _LIBC_REENTRANT
#define SYSCALL_ERROR_HANDLER						      \
0:pushl %ebx;								      \
  call 1f;								      \
  .subsection 1;							      \
1:movl (%esp), %ebx;							      \
  ret;									      \
  .previous;								      \
  addl $_GLOBAL_OFFSET_TABLE_, %ebx;					      \
  pushl %eax;								      \
  PUSH_ERRNO_LOCATION_RETURN;						      \
  call BP_SYM (__errno_location)@PLT;					      \
  POP_ERRNO_LOCATION_RETURN;						      \
  popl %ecx;								      \
  popl %ebx;								      \
  movl %ecx, (%eax);							      \
  movl $-1, %eax;							      \
  ret;
/* A quick note: it is assumed that the call to `__errno_location' does
   not modify the stack!  */
#else
#define SYSCALL_ERROR_HANDLER						      \
0:call 1f;								      \
  .subsection 1;							      \
1:movl (%esp), %ecx;							      \
  ret;									      \
  .previous;								      \
  addl $_GLOBAL_OFFSET_TABLE_, %ecx;					      \
  movl errno@GOT(%ecx), %ecx;						      \
  movl %eax, (%ecx);							      \
  movl $-1, %eax;							      \
  ret;
#endif	/* _LIBC_REENTRANT */
#endif	/* PIC */

/* FreeBSD expects the system call arguments on the stack.  */
#undef DO_CALL
#define DO_CALL(syscall_name, args)					      \
  movl $SYS_ify (syscall_name), %eax;					      \
  int $0x80

#endif	/* __ASSEMBLER__ */

#endif /* freebsd/i386/sysdep.h */
