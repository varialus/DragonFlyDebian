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
#include <sys/sysctl.h>
#include <ldsodefs.h>
#include <kernel-features.h>

#ifdef SHARED
# include <elf/dl-sysdep.c>
#endif

int
attribute_hidden
_dl_discover_osversion (void)
{
  int request[2] = { CTL_KERN, KERN_OSRELDATE };
  size_t len;
  int version;

  len = sizeof(version);
  if (__sysctl (request, 2, &version, &len, NULL, 0) < 0)
    return -1;
    
/*
 *   scheme is:  <major><two digit minor>Rxx
 *		'R' is 0 if release branch or x.0-CURRENT before RELENG_*_0
 *		is created, otherwise 1.
 */

  /* Convert to the GLIBC versioning system */
  return ((version / 100000) << 16)		/* major */
	 | (((version % 100000) / 1000) << 8)   /* minor 	0 -  99 */
	 | ((version % 200));			/* subrelease 	0 - 199 */
}
