/* Copyright (C) 1995-1998, 2000, 2002 Free Software Foundation, Inc.
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
#include <sys/types.h>
#include <sys/ptrace.h>
#include <stdarg.h>

#include <sysdep.h>
#include <sys/syscall.h>

extern int __syscall_ptrace (enum __ptrace_request request, pid_t pid,
			     void *addr, void *data);

int
ptrace (enum __ptrace_request request, ...)
{
  int res, ret;
  va_list ap;
  pid_t pid;
  void *addr, *data;

  /* Usually 4 arguments are given, except when request == PTRACE_TRACEME.
     But it doesn't harm to peek at the stack in this case as well.  */
  va_start (ap, request);
  pid = va_arg (ap, pid_t);
  addr = va_arg (ap, void *);
  data = va_arg (ap, void *);
  va_end (ap);

  switch (request)
    {
    case PTRACE_PEEKTEXT:
    case PTRACE_PEEKDATA:
#ifdef PTRACE_PEEKUSER
    case PTRACE_PEEKUSER:
#endif
      res = INLINE_SYSCALL (ptrace, 4, request, pid, addr, &ret);
      if (res >= 0)
	{
	  /* ret can be -1 even for successful operation.  */
	  __set_errno (0);
	  return ret;
	}
      break;

    default:
      res = INLINE_SYSCALL (ptrace, 4, request, pid, addr, data);
      break;
    }

  return res;
}
