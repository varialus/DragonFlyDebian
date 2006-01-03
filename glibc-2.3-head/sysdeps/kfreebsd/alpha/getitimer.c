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

extern int __syscall_getitimer (int which, struct __kernel_itimerval *value);

int
__getitimer (enum __itimer_which which, struct itimerval *value)
{
  struct __kernel_itimerval kvalue;
  int retval;

  if (value == NULL)
    {
      errno = EFAULT;
      return -1;
    }
  retval = __syscall_getitimer (which, &kvalue);
  if (retval >= 0)
    {
      value->it_interval.tv_sec  = kvalue.it_interval.tv_sec;
      value->it_interval.tv_usec = kvalue.it_interval.tv_usec;
      value->it_value.tv_sec  = kvalue.it_value.tv_sec;
      value->it_value.tv_usec = kvalue.it_value.tv_usec;
    }
  return retval;
}

weak_alias (__getitimer, getitimer)
