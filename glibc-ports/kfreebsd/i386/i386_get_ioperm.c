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

#include <sys/perm.h>
#include <sysarch.h>

int
i386_get_ioperm (unsigned long int from, unsigned long int *num, int *turned_on)
{
  struct i386_ioperm_args args;

  args.start = from;

  if (__sysarch (I386_GET_IOPERM, &args) < 0)
    return -1;

  *num = args.length;
  *turned_on = args.enable;

  return 0;
}
