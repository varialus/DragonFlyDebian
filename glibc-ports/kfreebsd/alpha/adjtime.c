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

extern int __syscall_adjtime (const struct __kernel_timeval *delta,
			      struct __kernel_timeval *olddelta);

int
__adjtime (const struct timeval *delta, struct timeval *olddelta)
{
  struct __kernel_timeval kdelta;
  int retval;

  kdelta.tv_sec  = delta->tv_sec;
  kdelta.tv_usec = delta->tv_usec;
  if (olddelta != NULL)
    {
      struct __kernel_timeval kolddelta;

      retval = __syscall_adjtime (&kdelta, &kolddelta);
      if (retval >= 0)
	{
	  olddelta->tv_sec  = kolddelta.tv_sec;
	  olddelta->tv_usec = kolddelta.tv_usec;
	}
    }
  else
    retval = __syscall_adjtime (&kdelta, NULL);
  return retval;
}

weak_alias (__adjtime, adjtime)
