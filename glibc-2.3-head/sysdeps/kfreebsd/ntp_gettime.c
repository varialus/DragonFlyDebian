/* Copyright (C) 2002 Free Software Foundation, Inc.
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

#include <sys/timex.h>
#include <sys/sysctl.h>
#include <stddef.h>

#ifndef ntptimeval
#define ntptimeval ntptimeval4
#endif

int
ntp_gettime (struct ntptimeval *ntv)
{
  /* Fetch sysctl value of "kern.ntp_pll.gettime".  */
  /* The 'struct ntptimeval' has grown in size.  */
  union
    {
      struct ntptimeval3 tv3;
      struct ntptimeval4 tv4;
    } tv;
  size_t size = sizeof (tv);
  int request[2] = { CTL_KERN, KERN_NTP_PLL };

  if (__sysctl (request, 2, &tv, &size, NULL, 0) >= 0)
    {
      if (size == sizeof (struct ntptimeval3))
	{
	  if (ntv)
	    {
	      ntv->time = tv.tv3.time;
	      ntv->maxerror = tv.tv3.maxerror;
	      ntv->esterror = tv.tv3.esterror;
	      ntv->tai = 0;
	      ntv->time_state = tv.tv3.time_state;
	    }
	  return tv.tv3.time_state;
	}
      if (size == sizeof (struct ntptimeval4))
	{
	  if (ntv)
	    *ntv = tv.tv4;
	  return tv.tv4.time_state;
	}
    }
  return TIME_ERROR;
}
