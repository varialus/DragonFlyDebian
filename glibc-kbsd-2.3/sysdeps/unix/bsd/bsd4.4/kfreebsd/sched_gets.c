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

#include <sched.h>
#include <sys/types.h>
#include <errno.h>
#include <sys/rtprio.h>

extern int __syscall_sched_getscheduler (pid_t pid);

/* Retrieve scheduling algorithm for a particular purpose.  */
int
__sched_getscheduler (pid_t pid)
{
  int ret;

  ret = __syscall_sched_getscheduler (pid);

  /* FreeBSD (at least versions 4.0 and 4.6) always returns error EPERM, but
     fortunately the same information can be retrieved through the rtprio()
     system call.  */
  if (ret < 0 && errno == EPERM)
    {
      struct rtprio rtp;

      ret = __rtprio (RTP_LOOKUP, pid, &rtp);
      if (ret >= 0)
	{
	  switch (rtp.type)
	    {
	    case RTP_PRIO_REALTIME:
	      ret = SCHED_RR;
	      break;

	    case RTP_PRIO_FIFO:
	      ret = SCHED_FIFO;
	      break;

	    default:
	      ret = SCHED_OTHER;
	      break;
	    }
	}
    }

  return ret;
}

weak_alias (__sched_getscheduler, sched_getscheduler)
