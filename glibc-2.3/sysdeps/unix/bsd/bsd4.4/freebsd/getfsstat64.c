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

#include <sys/mount.h>

#include "statfsconv.c"

int
__getfsstat64 (struct statfs64 *buf, long bufsize, int flags)
{
  long bufcount;
  struct statfs *smallbuf;
  int count, i;

  if (bufsize < 0)
    bufsize = 0;
  bufcount = bufsize / sizeof (struct statfs64);

  /* Since sizeof (struct statfs) <= sizeof (struct statfs64), we can use
     buf as temporary buffer.  */
  smallbuf = (struct statfs *) buf;

  count = __getfsstat (smallbuf, bufcount * sizeof (struct statfs), flags);
  if (count > 0)
    for (i = count - 1; i >= 0; i--)
      /* Convert a 'struct statfs' to 'struct statfs64'.  */
      statfs_to_statfs64 (&smallbuf[i], &buf[i]);

  return count;
}

weak_alias (__getfsstat64, getfsstat64)
