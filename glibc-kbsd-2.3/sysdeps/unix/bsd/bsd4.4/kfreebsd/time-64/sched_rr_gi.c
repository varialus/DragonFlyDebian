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
#include <time.h>
#include <sched.h>
#include <sys/types.h>

extern int __syscall_sched_rr_get_interval (pid_t pid,
					    struct __kernel_timespec *t);

int
__sched_rr_get_interval (pid_t pid, struct timespec *t)
{
  struct __kernel_timespec kt;
  int retval;

  if (t == NULL)
    {
      errno = EFAULT;
      return -1;
    }
  retval = __syscall_sched_rr_get_interval (pid, &kt);
  if (retval >= 0)
    {
      t->tv_sec  = kt.tv_sec;
      t->tv_nsec = kt.tv_nsec;
    }
  return retval;
}

weak_alias (__sched_rr_get_interval, sched_rr_get_interval)
