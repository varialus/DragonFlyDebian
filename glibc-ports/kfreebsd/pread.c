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
#include <sysdep-cancel.h>
#include <errno.h>

extern ssize_t __syscall_pread (int __fd, void *__buf, size_t __nbytes,
				__off_t __offset) __THROW;
libc_hidden_proto(__syscall_pread)
extern ssize_t __syscall_freebsd6_pread (int __fd, void *__buf, size_t __nbytes,
				int __unused1, __off_t __offset) __THROW;
libc_hidden_proto(__syscall_freebsd6_pread)

ssize_t
__libc_pread (int fd, void *buf, size_t nbytes, __off_t offset)
{
  ssize_t result;
  int oldtype;

  if (!SINGLE_THREAD_P)
    {
      oldtype = LIBC_CANCEL_ASYNC ();
    }

  /* First try the new syscall. */
  result = INLINE_SYSCALL (pread, 4, fd, buf, nbytes, offset);
#ifndef __ASSUME_PREAD_SYSCALL
  if (result == -1 && errno == ENOSYS)
    /* New syscall not available, us the old one. */
    result = INLINE_SYSCALL (freebsd6_pread, 5, fd, buf, nbytes, 0, offset);
#endif

  if (!SINGLE_THREAD_P)
    {
      LIBC_CANCEL_RESET (oldtype);
    }
  return result;
}

strong_alias (__libc_pread, __pread)
weak_alias (__pread, pread)

/* 'pread64' is the same as 'pread', because __off64_t == __off_t.  */
strong_alias (__libc_pread, __libc_pread64)
weak_alias (__libc_pread64, __pread64)
weak_alias (__libc_pread64, pread64)
