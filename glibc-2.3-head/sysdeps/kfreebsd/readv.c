/* readv for FreeBSD.
   Copyright (C) 1997-1998, 2000, 2002 Free Software Foundation, Inc.
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
#include <stddef.h>
#include <sys/param.h>
#include <sys/uio.h>

#include <sysdep.h>
#include <sys/syscall.h>
#include <bp-checks.h>

extern ssize_t __syscall_readv (int, __const struct iovec *__unbounded, int);

#define __readv static __inline internal_function __atomic_readv_replacement
#include <sysdeps/posix/readv.c>
#undef __readv

ssize_t
__readv (int fd, const struct iovec *vector, int count)
{
  if (count <= UIO_MAXIOV)
    return INLINE_SYSCALL (readv, 3, fd, CHECK_N (vector, count), count);
  else
    return __atomic_readv_replacement (fd, vector, count);
}

weak_alias (__readv, readv)
