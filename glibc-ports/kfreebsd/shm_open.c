/* Copyright (C) 2009 Free Software Foundation, Inc.
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

#include <sys/stat.h>
#include <sys/mman.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <sysdep.h>

extern int __syscall_shm_open (const char *path, int flags, mode_t mode);
libc_hidden_proto (__syscall_shm_open);

/* Open shared memory object.   */
int
shm_open (const char *name, int oflag, mode_t mode)
{
  /* First try the new syscall. */
  int fd = INLINE_SYSCALL (shm_open, 3, name, oflag, mode);

#ifndef __ASSUME_POSIXSHM_SYSCALL
  /* New syscall not available, use fallback code.  */
  if (fd == -1 && errno == ENOSYS)
    {
      struct stat stab;

      if ((oflag & O_ACCMODE) == O_WRONLY)
	return (EINVAL);

      fd = __open (name, oflag, mode);
      if (fd != -1)
	{
	  if (__fstat (fd, &stab) != 0 || !S_ISREG (stab.st_mode))
	    {
	      __close (fd);
	      __set_errno (EINVAL);
	      return -1;
	    }

	  if (__fcntl (fd, F_SETFL, (int) FPOSIXSHM) != 0)
	    {
	      __close (fd);
	      return -1;
	    }
	}
    }
#endif

  return fd;
}
