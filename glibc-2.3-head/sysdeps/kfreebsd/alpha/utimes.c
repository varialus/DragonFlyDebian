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

#include <stddef.h>
#include <sys/time.h>
#include <bits/kernel_time_t.h>

extern int __syscall_utimes (const char *file,
			     const struct __kernel_timeval tvp[2]);

int
__utimes (const char *file, const struct timeval tvp[2])
{
  if (tvp != NULL)
    {
      struct __kernel_timeval ktv[2];

      ktv[0].tv_sec  = tvp[0].tv_sec;
      ktv[0].tv_usec = tvp[0].tv_usec;
      ktv[1].tv_sec  = tvp[1].tv_sec;
      ktv[1].tv_usec = tvp[1].tv_usec;
      return __syscall_utimes (file, ktv);
    }
  else
    return __syscall_utimes (file, NULL);
}

weak_alias (__utimes, utimes)
