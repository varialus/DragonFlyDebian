/* Test whether RT signals are really available.
   Copyright (C) 2008 Free Software Foundation, Inc.
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

#include <sys/sysctl.h>
#include <errno.h>
#include <string.h>

#include <kernel-features.h>

static int
kernel_has_rtsig (void)
{
#if __ASSUME_REALTIME_SIGNALS
  return 1;
#else

  int request[2] = { CTL_KERN, KERN_OSRELDATE};
  size_t len;
  int val;

  len = sizeof (val);
  if (__sysctl (request, 2, &val, &len, NULL, 0) < 0)
      return 0;
  if ( val < 700050) /* FreeBSD 7.0 is 700055 */
      return 0;
  return 1;
#endif
}
