/* Convert between different 'struct stat' formats.
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

/* Convert a 'struct stat' to 'struct stat64'.  */
static inline void
stat_to_stat64 (const struct stat *p32, struct stat64 *p64)
{
  p64->st_dev = p32->st_dev;
  p64->st_ino = p32->st_ino;
  p64->st_mode = p32->st_mode;
  p64->st_nlink = p32->st_nlink;
  p64->st_uid = p32->st_uid;
  p64->st_gid = p32->st_gid;
  p64->st_rdev = p32->st_rdev;
  p64->st_atime = p32->st_atime;
  p64->st_atimensec = p32->st_atimensec;
  p64->st_mtime = p32->st_mtime;
  p64->st_mtimensec = p32->st_mtimensec;
  p64->st_ctime = p32->st_ctime;
  p64->st_ctimensec = p32->st_ctimensec;
  p64->st_size = p32->st_size;
  p64->st_blocks = p32->st_blocks;
  p64->st_blksize = p32->st_blksize;
  p64->st_flags = p32->st_flags;
  p64->st_gen = p32->st_gen;
  memcpy (p64->__unused1, p32->__unused1, sizeof (p32->__unused1));
}
