/* Copyright (C) 2004 Free Software Foundation, Inc.
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

#include <errno.h>
#include <unistd.h>
#include <sys/syscall.h>

#ifndef SYS_break
#define SYS_break SYS_obreak
#endif

extern void _end;

/* sbrk.c expects this.  */
void *__curbrk = &_end;


/* Set the end of the process's data space to ADDR.
   Return 0 if successful, -1 if not.  */
int
__brk (addr)
     void *addr;
{



  if (addr < &_end)
    return 0;

  if (syscall (SYS_break, addr) == -1)
    {
      __set_errno (ENOMEM);
      return -1;
    }

  __curbrk = addr;
  return 0;
}
stub_warning (brk)

weak_alias (__brk, brk)
#include <stub-tag.h>
