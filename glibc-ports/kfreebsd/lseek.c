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

extern __off_t __syscall_lseek (int __fd, __off_t __offset, int __whence) __THROW;
libc_hidden_proto (__syscall_lseek)
extern __off_t __syscall_freebsd6_lseek (int __fd, int __unused1, __off_t __offset,
				int __whence) __THROW;
libc_hidden_proto (__syscall_freebsd6_lseek)

__off_t
__libc_lseek (int fd, __off_t offset, int whence)
{
  __off_t result;

  /* First try the new syscall. */
  result = INLINE_SYSCALL (lseek, 3, fd, offset, whence);

#ifndef __ASSUME_LSEEK_SYSCALL
  if (result == -1 && errno == ENOSYS)
    /* New syscall not available, us the old one. */
    result = INLINE_SYSCALL (freebsd6_lseek, 4, fd, 0, offset, whence);
#endif

  return result;
}

weak_alias (__libc_lseek, __lseek)
libc_hidden_def (__lseek)
weak_alias (__libc_lseek, lseek)

/* 'lseek64' is the same as 'lseek', because __off64_t == __off_t.  */
strong_alias (__libc_lseek, __libc_lseek64)
weak_alias (__libc_lseek64, __lseek64)
weak_alias (__lseek64, lseek64)

/* 'llseek' is the same as 'lseek', because __off64_t == __off_t.  */
strong_alias (__libc_lseek, __llseek)
weak_alias (__llseek, llseek)
