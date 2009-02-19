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

#include <sys/types.h>
#include <sys/mman.h>
#include <unistd.h>
#include <errno.h>
#include <sysdep.h>

/* The real system call has a word of padding before the 64-bit off_t
   argument.  */
extern void *__syscall_freebsd6_mmap (void *__addr, size_t __len, int __prot,
			     int __flags, int __fd, int __unused1,
			     __off_t __offset) __THROW;
libc_hidden_proto (__syscall_freebsd6_mmap)

extern ssize_t __syscall_freebsd6_pread (int __fd, void *__buf, size_t __nbytes,
                                int __unused1, __off_t __offset) __THROW;

libc_hidden_proto (__syscall_freebsd6_pread)
void *
__mmap (void *addr, size_t len, int prot, int flags, int fd, __off_t offset)
{
  void *result;

  /* Validity checks not done by the kernel.  */
  if ((flags & MAP_FIXED) || (offset != 0))
    {
      int pagesize = __getpagesize ();

      if (((flags & MAP_FIXED)
	   && (__builtin_expect (pagesize & (pagesize - 1), 0)
	       ? (unsigned long) addr % pagesize
	       : (unsigned long) addr & (pagesize - 1)))
	  || (__builtin_expect (pagesize & (pagesize - 1), 0)
	      ? offset % pagesize
	      : offset & (pagesize - 1)))
	{
	  __set_errno (EINVAL);
	  return (void *) (-1);
	}
    }

  /* We pass 7 arguments in 8 words.  */
  /* for ANON mapping we must pass -1 in place of fd */
  if (flags & MAP_ANON)
    return INLINE_SYSCALL (freebsd6_mmap, 7, addr, len, prot, flags, -1, 0, offset);
  result = INLINE_SYSCALL (freebsd6_mmap, 7, addr, len, prot, flags, fd, 0, offset);

  if (result != (void *) (-1) && fd >= 0 && len > 0)
    {
      /* Force an update of the atime.  POSIX:2001 mandates that this happens
	 at some time between the mmap() call and the first page-in.  Since
	 the FreeBSD 4.0 kernel doesn't update the atime upon a page-in, we
	 do it here.  */
      char dummy;

      INLINE_SYSCALL (freebsd6_pread, 5, fd, &dummy, 1, 0, offset);
    }

  return result;
}

weak_alias (__mmap, mmap)

/* 'mmap64' is the same as 'mmap', because __off64_t == __off_t.  */
strong_alias (__mmap, __mmap64)
weak_alias (__mmap64, mmap64)
