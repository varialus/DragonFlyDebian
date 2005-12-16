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

#include <sys/sysctl.h>
#include <string.h>

/* Read or write system parameters.  */
int
__sysctlbyname (const char *name, void *oldval, size_t *oldlenp, void *newval, size_t newlen)
{
  int request[CTL_MAXNAME];
  size_t requestlen = sizeof (request);

  /* Convert the string NAME to a binary encoded request.  The kernel
     contains a routine for doing this, called "name2oid".  But the way
     to call it is a little bit strange.  */
  int name2oid_request[2] = { 0, 3 };
  if (__sysctl (name2oid_request, 2, request, &requestlen,
		(void *) name, strlen (name))
      < 0)
    return -1;

  /* Now call sysctl using the binary encoded request.  */
  return __sysctl (request, requestlen / sizeof (int),
		   oldval, oldlenp, newval, newlen);
}

weak_alias (__sysctlbyname, sysctlbyname)
