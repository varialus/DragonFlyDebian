/* Copyright (C) 2010 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by Robert Millan.

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

#include <linuxthreads/sysdeps/unix/sysv/linux/mips/sysdep-cancel.h>

/* workarounds for http://sources.redhat.com/bugzilla/show_bug.cgi?id=12300 */
#ifdef __ASSEMBLER__
# if !defined NOT_IN_libc || defined IS_IN_libpthread || defined IS_IN_librt
#  define RTLD_SINGLE_THREAD_P(reg) SINGLE_THREAD_P(reg)
# endif
#else
# define RTLD_SINGLE_THREAD_P SINGLE_THREAD_P
#endif
