/* xstat using FreeBSD stat, nstat system calls.
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
#include <bits/stat16.h>
#include <bits/stat32.h>
#include <bp-checks.h>

#include "stat32conv.c"

extern int __syscall_stat (const char *__unbounded, struct stat16 *__unbounded);
extern int __syscall_nstat (const char *__unbounded, struct stat32 *__unbounded);

int
__xstat (int vers, const char *file, struct stat *buf)
{
  if (__builtin_expect (vers == _STAT_VER, 1))
    {
      struct stat32 buf32;
      int result = __syscall_nstat (CHECK_STRING (file), __ptrvalue (&buf32));
      if (result == 0)
	stat32_to_stat (&buf32, buf);
      return result;
    }
  else if (__builtin_expect (vers == _STAT_VER_nstat, 1))
    return __syscall_nstat (CHECK_STRING (file),
			    CHECK_1 ((struct stat32 *) buf));
  else if (__builtin_expect (vers == _STAT_VER_stat, 1))
    return __syscall_stat (CHECK_STRING (file),
			   CHECK_1 ((struct stat16 *) buf));
  else
    {
      __set_errno (EINVAL);
      return -1;
    }
}
hidden_def (__xstat)

weak_alias (__xstat, _xstat)
