/* Copyright (C) 2005 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by Aurelien Jarno <aurelien@aurel32.net>, 2005.

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

ssize_t
__libc_pread64 (int fd, void *buf, size_t nbytes, __off64_t offset)
{
  /* 'pread64' is the same as 'pread', because __off64_t == __off_t.  */
  return __libc_pread(fd, buf, nbytes, (__off_t) offset);
}

strong_alias (__libc_pread64, __pread64)
weak_alias (__libc_pread64, pread64)
