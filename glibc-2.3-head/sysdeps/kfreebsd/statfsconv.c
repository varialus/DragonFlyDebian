/* Convert between different 'struct statfs' formats.
   Copyright (C) 2002 Free Software Foundation, Inc.
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

#include <string.h>

/* Convert a 'struct statfs' to 'struct statfs64'.  */
static inline void
statfs_to_statfs64 (const struct statfs *p32, struct statfs64 *p64)
{
  p64->__unused1 = p32->__unused1;
  p64->f_bsize = p32->f_bsize;
  p64->f_iosize = p32->f_iosize;
  p64->f_blocks = p32->f_blocks;
  p64->f_bfree = p32->f_bfree;
  p64->f_bavail = p32->f_bavail;
  p64->f_files = p32->f_files;
  p64->f_ffree = p32->f_ffree;
  p64->f_fsid = p32->f_fsid;
  p64->f_owner = p32->f_owner;
  p64->f_type = p32->f_type;
  p64->f_flags = p32->f_flags;
  p64->f_syncwrites = p32->f_syncwrites;
  p64->f_asyncwrites = p32->f_asyncwrites;
  memcpy (p64->f_fstypename, p32->f_fstypename, sizeof (p32->f_fstypename));
  memcpy (p64->f_mntonname, p32->f_mntonname, sizeof (p32->f_mntonname));
  p64->f_syncreads = p32->f_syncreads;
  p64->f_asyncreads = p32->f_asyncreads;
  p64->__unused2 = p32->__unused2;
  memcpy (p64->f_mntfromname, p32->f_mntfromname, sizeof (p32->f_mntfromname));
  p64->__unused3 = p32->__unused3;
  memcpy (p64->__unused4, p32->__unused4, sizeof (p32->__unused4));
}
