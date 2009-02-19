/* Copyright (C) 2005, 2006 Free Software Foundation, Inc.
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

#include <errno.h>
#include <fcntl.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <kernel-features.h>
#include <sysdep-cancel.h>
#include <not-cancel.h>

int
__openat_nocancel (fd, file, oflag, mode)
     int fd;
     const char *file;
     int oflag;
     mode_t mode;
{
  if (fd != AT_FDCWD && file[0] != '/')
    {
      /* Check FD is associated with a directory.  */
      struct stat64 st;
      if (__fxstat64 (_STAT_VER, fd, &st) != 0)
	/* errno is already set correctly.  */
        return -1;

      if (!S_ISDIR (st.st_mode))
	__set_errno (ENOTDIR);
      else
	__set_errno (ENOSYS);
      return -1;
    }
  return INLINE_SYSCALL (open, 3, file, oflag, mode);
}


/* Open FILE with access OFLAG.  Interpret relative paths relative to
   the directory associated with FD.  If OFLAG includes O_CREAT, a
   third argument is the file protection.  */
int
__openat (fd, file, oflag)
     int fd;
     const char *file;
     int oflag;
{
  mode_t mode = 0;
  if (oflag & O_CREAT)
    {
      va_list arg;
      va_start (arg, oflag);
      mode = va_arg (arg, int);
      va_end (arg);
    }

  if (SINGLE_THREAD_P)
    return __openat_nocancel (fd, file, oflag, mode);

  int oldtype = LIBC_CANCEL_ASYNC ();

  int res = __openat_nocancel (fd, file, oflag, mode);

  LIBC_CANCEL_RESET (oldtype);

  return res;
}
libc_hidden_def (__openat)
weak_alias (__openat, openat)

/* openat64 is just the same as openat for us.  */
strong_alias (__openat, __openat64)
strong_alias (__openat_nocancel, __openat64_nocancel)
libc_hidden_weak (__openat64)
weak_alias (__openat64, openat64)

stub_warning (openat)
stub_warning (openat64)

int
__openat_2 (fd, file, oflag)
     int fd;
     const char *file;
     int oflag;
{
  if (oflag & O_CREAT)
    __fortify_fail ("invalid openat call: O_CREAT without mode");

  return __openat (fd, file, oflag);
}

strong_alias (__openat_2, __openat64_2)
stub_warning (__openat_2)
stub_warning (__openat64_2)
