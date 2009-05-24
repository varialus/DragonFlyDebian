/* Dynamic linker system dependencies for GNU/kFreeBSD.
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

/* For SHARED, use the generic dynamic linker system interface code. */
/* otherwise the code is in dl-support.c */

#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/utsname.h>
#include <ldsodefs.h>
#include <kernel-features.h>

#ifdef SHARED
# include <elf/dl-sysdep.c>
#endif

int
attribute_hidden
_dl_discover_osversion (void)
{
  char bufmem[64];
  char *buf = bufmem;
  unsigned int version;
  int parts;
  char *cp;
  struct utsname uts;

  /* Try the uname syscall */
  if (__uname (&uts))
    return -1;

  /* Now convert it into a number.  The string consists of at most
     three parts.  */
  version = 0;
  parts = 0;
  buf = uts.release;
  cp = buf;
  while ((*cp >= '0') && (*cp <= '9'))
    {
      unsigned int here = *cp++ - '0';

      while ((*cp >= '0') && (*cp <= '9'))
	{
	  here *= 10;
	  here += *cp++ - '0';
	}

      ++parts;
      version <<= 8;
      version |= here;

      if (*cp++ != '.' || parts == 3)
	/* Another part following?  */
	break;
    }

  if (parts < 3)
    version <<= 8 * (3 - parts);

  return version;
}
