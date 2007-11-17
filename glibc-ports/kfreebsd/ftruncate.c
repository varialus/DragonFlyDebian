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

#include <unistd.h>
#include <sys/types.h>
#include <sysdep.h>

/* The real system call has a word of padding before the 64-bit off_t
   argument.  */
extern int __syscall_freebsd6_ftruncate (int __fd, int __unused1,
				__off_t __length) __THROW;
libc_hidden_proto (__syscall_freebsd6_ftruncate)

int
__ftruncate (int fd, __off_t length)
{
  /* We pass 2 arguments in 4 words.  */
  return INLINE_SYSCALL (freebsd6_ftruncate, 2, fd, 0, length);
}

weak_alias (__ftruncate, ftruncate)

/* 'ftruncate64' is the same as 'ftruncate', because __off64_t == __off_t.  */
strong_alias (__ftruncate, __ftruncate64)
weak_alias (__ftruncate64, ftruncate64)
