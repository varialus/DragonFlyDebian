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

/* The real system call has a word of padding before the 64-bit off_t
   argument.  */
extern __off_t __syscall_lseek (int __fd, int __unused1, __off_t __offset,
				int __whence) __THROW;

__off_t
__libc_lseek (int fd, __off_t offset, int whence)
{
#if 0 /* If the kernel would work right... */
  /* We pass 3 arguments in 5 words.  */
  return INLINE_SYSCALL (lseek, 3, fd, 0, offset, whence);
#else
  /* According to POSIX:2001, if the resulting file offset would become
     negative, this function has to return an EINVAL error and leave the
     file offset unchanged.  But the FreeBSD 4.0 kernel doesn't do this,
     so we emulate it.  */
  if (offset >= 0)
    /* No risk that the file offset could become negative.  */
    return INLINE_SYSCALL (lseek, 3, fd, 0, offset, whence);
  else
    {
      /* Test whether the file offset becomes negative.  */
      __off_t old_position;
      __off_t new_position;
      int saved_errno;

      saved_errno = errno;
      old_position = INLINE_SYSCALL (lseek, 3, fd, 0, 0, SEEK_CUR);
      errno = 0;
      new_position = INLINE_SYSCALL (lseek, 3, fd, 0, offset, whence);
      if (new_position < 0)
	{
	  if (errno == 0)
	    {
	      /* The file offset became negative, and the kernel didn't
		 notice it.  */
	      if (old_position >= 0)
		INLINE_SYSCALL (lseek, 3, fd, 0, old_position, SEEK_SET);
	      new_position = -1;
	      errno = EINVAL;
	    }
	}
      else
	errno = saved_errno;
      return new_position;
    }
#endif
}

weak_alias (__libc_lseek, __lseek)
weak_alias (__lseek, lseek)

/* 'lseek64' is the same as 'lseek', because __off64_t == __off_t.  */
strong_alias (__libc_lseek, __libc_lseek64)
weak_alias (__libc_lseek64, __lseek64)
weak_alias (__lseek64, lseek64)
