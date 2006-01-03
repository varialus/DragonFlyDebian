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
#include <errno.h>
#include <sys/time.h>
#include <bits/kernel_time_t.h>

extern int __syscall_setitimer (int which,
				const struct __kernel_itimerval *new,
				struct __kernel_itimerval *old);

int
__setitimer (enum __itimer_which which,
	     const struct itimerval *new, struct itimerval *old)
{
  int retval;
  struct __kernel_itimerval knew;

  if (new == NULL)
    {
      errno = EFAULT;
      return -1;
    }
  knew.it_interval.tv_sec  = new->it_interval.tv_sec;
  knew.it_interval.tv_usec = new->it_interval.tv_usec;
  knew.it_value.tv_sec  = new->it_value.tv_sec;
  knew.it_value.tv_usec = new->it_value.tv_usec;
  if (old != NULL)
    {
      struct __kernel_itimerval kold;

      retval = __syscall_setitimer (which, &knew, &kold);
      if (retval >= 0)
	{
	  old->it_interval.tv_sec  = kold.it_interval.tv_sec;
	  old->it_interval.tv_usec = kold.it_interval.tv_usec;
	  old->it_value.tv_sec  = kold.it_value.tv_sec;
	  old->it_value.tv_usec = kold.it_value.tv_usec;
	}
    }
  else
    retval = __syscall_setitimer (which, &knew, NULL);
  return retval;
}

weak_alias (__setitimer, setitimer)
