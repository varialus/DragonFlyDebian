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
extern ssize_t __syscall_pwrite (int __fd, const void *__buf, size_t __nbytes,
				 int __unused1, __off_t __offset) __THROW;

ssize_t
__libc_pwrite (int fd, const void *buf, size_t nbytes, __off_t offset)
{
  /* We pass 5 arguments in 6 words.  */
  return INLINE_SYSCALL (pwrite, 5, fd, buf, nbytes, 0, offset);
}

strong_alias (__libc_pwrite, __pwrite)
weak_alias (__libc_pwrite, pwrite)
