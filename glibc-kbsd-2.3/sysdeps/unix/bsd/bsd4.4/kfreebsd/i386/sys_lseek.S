/* Copyright (C) 2002 Free Software Foundation, Inc.
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

#include <sysdep.h>

/* lseek returns a 64-bit result in %eax, %edx.  This means that in the
   error case we have to set both %eax and %edx to -1.  */

#undef SYSCALL_ERROR_LABEL
#define SYSCALL_ERROR_LABEL 0f

#undef SYSCALL_ERROR_HANDLER
#ifndef PIC
#ifdef _LIBC_REENTRANT
#define SYSCALL_ERROR_HANDLER						      \
0:pushl %eax;								      \
  PUSH_ERRNO_LOCATION_RETURN;						      \
  call BP_SYM (__errno_location);					      \
  POP_ERRNO_LOCATION_RETURN;						      \
  popl %ecx;								      \
  movl $-1, %edx;							      \
  movl %ecx, (%eax);							      \
  movl %edx, %eax;							      \
  ret;
/* A quick note: it is assumed that the call to `__errno_location' does
   not modify the stack!  */
#else
#define SYSCALL_ERROR_HANDLER						      \
0:movl $-1, %edx;							      \
  movl %eax, errno;							      \
  movl %edx, %eax;							      \
  ret;
#endif	/* _LIBC_REENTRANT */
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
  movl $-1, %edx;							      \
  movl %ecx, (%eax);							      \
  movl %edx, %eax;							      \
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
  movl $-1, %edx;							      \
  movl %eax, (%ecx);							      \
  movl %edx, %eax;							      \
  ret;
#endif	/* _LIBC_REENTRANT */
#endif	/* PIC */

PSEUDO (__syscall_lseek, lseek, 4)
	ret
PSEUDO_END(__syscall_lseek)
