/* Copyright (C) 2006 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by Robert Millan <robertmh@gnu.org>

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

#include <sys/syscall.h>
#include <sys/utsname.h>
#include <string.h>
#include <unistd.h>

#define SYSNAME		"GNU/kFreeBSD"
#define SYSNAME_LEN	13

/* Check for bounds in pre-processor */
#if SYSNAME_LEN > _UTSNAME_SYSNAME_LENGTH
#error
#endif

int
__uname (struct utsname *uname)
{
  if (syscall (SYS_uname, uname) == -1)
    return -1;

  strcpy (uname->sysname, SYSNAME);

  return 0;
}
weak_alias (__uname, uname)
libc_hidden_def (__uname)
libc_hidden_def (uname)
