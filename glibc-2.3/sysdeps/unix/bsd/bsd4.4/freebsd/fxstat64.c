/* fxstat using FreeBSD fstat, nfstat system calls.
   Copyright (C) 1991,1995-1997,2000,2002 Free Software Foundation, Inc.
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
#include <sys/stat.h>
#include <bits/stat32.h>
#include <bp-checks.h>

#include "stat32conv.c"

extern int __syscall_nfstat (int, struct stat32 *__unbounded);

int
__fxstat64 (int vers, int fd, struct stat64 *buf)
{
  if (__builtin_expect (vers == _STAT_VER, 1))
    {
      struct stat32 buf32;
      int result = __syscall_nfstat (fd, __ptrvalue (&buf32));
      if (result == 0)
	stat32_to_stat64 (&buf32, buf);
      return result;
    }
  else
    {
      __set_errno (EINVAL);
      return -1;
    }
}
hidden_def (__fxstat64)
