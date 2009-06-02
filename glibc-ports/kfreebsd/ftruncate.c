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
#include <errno.h>

extern int __syscall_ftruncate (int __fd, __off_t __length) __THROW;
libc_hidden_proto (__syscall_ftruncate)
extern int __syscall_freebsd6_ftruncate (int __fd, int __unused1,
				__off_t __length) __THROW;
libc_hidden_proto (__syscall_freebsd6_ftruncate)

int
__ftruncate (int fd, __off_t length)
{
  int result;

  /* First try the new syscall. */
  result = INLINE_SYSCALL (ftruncate, 2, fd, length);

#ifndef __ASSUME_TRUNCATE_SYSCALL
  if (result == -1 && errno == ENOSYS)
    /* New syscall not available, us the old one. */
    result = INLINE_SYSCALL (freebsd6_ftruncate, 3, fd, 0, length);
#endif

  return result;
}

weak_alias (__ftruncate, ftruncate)

/* 'ftruncate64' is the same as 'ftruncate', because __off64_t == __off_t.  */
strong_alias (__ftruncate, __ftruncate64)
weak_alias (__ftruncate64, ftruncate64)
