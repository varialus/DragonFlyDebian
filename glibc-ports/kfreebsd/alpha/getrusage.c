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
#include <sys/resource.h>
#include <bits/kernel_time_t.h>

extern int __syscall_getrusage (int who, struct __kernel_rusage *usage);

int
__getrusage (enum __rusage_who who, struct rusage *usage)
{
  struct __kernel_rusage kusage;
  int retval;

  if (usage == NULL)
    {
      errno = EFAULT;
      return -1;
    }
  retval = __syscall_getrusage (who, &kusage);
  if (retval >= 0)
    {
      usage->ru_utime.tv_sec  = kusage.ru_utime.tv_sec;
      usage->ru_utime.tv_usec = kusage.ru_utime.tv_usec;
      usage->ru_stime.tv_sec  = kusage.ru_stime.tv_sec;
      usage->ru_stime.tv_usec = kusage.ru_stime.tv_usec;
      usage->ru_maxrss = kusage.ru_maxrss;
      usage->ru_ixrss = kusage.ru_ixrss;
      usage->ru_idrss = kusage.ru_idrss;
      usage->ru_isrss = kusage.ru_isrss;
      usage->ru_minflt = kusage.ru_minflt;
      usage->ru_majflt = kusage.ru_majflt;
      usage->ru_nswap = kusage.ru_nswap;
      usage->ru_inblock = kusage.ru_inblock;
      usage->ru_oublock = kusage.ru_oublock;
      usage->ru_msgsnd = kusage.ru_msgsnd;
      usage->ru_msgrcv = kusage.ru_msgrcv;
      usage->ru_nsignals = kusage.ru_nsignals;
      usage->ru_nvcsw = kusage.ru_nvcsw;
      usage->ru_nivcsw = kusage.ru_nivcsw;
    }
  return retval;
}

weak_alias (__getrusage, getrusage)
