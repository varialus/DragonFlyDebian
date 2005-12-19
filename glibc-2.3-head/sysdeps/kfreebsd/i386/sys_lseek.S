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

PSEUDO_NOERRNO(__syscall_lseek, lseek, 4)
        jnb L(no_error)
	call SYSCALL_ERROR_LABEL;
	orl $-1, %edx; 
L(pseudo_end):
L(no_error):
	ret
PSEUDO_END(__syscall_lseek)
