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

/* Convert a 'struct stat16' to 'struct stat'.  */
static inline void
stat16_to_stat (const struct stat16 *p16, struct stat *q)
{
  q->st_dev = p16->st_dev;
  q->st_ino = p16->st_ino;
  q->st_mode = p16->st_mode;
  q->st_nlink = p16->st_nlink;
  q->st_uid = p16->st_uid;
  q->st_gid = p16->st_gid;
  q->st_rdev = p16->st_rdev;
  q->st_atime = p16->st_atime;
  q->st_atimensec = p16->st_atimensec;
  q->st_mtime = p16->st_mtime;
  q->st_mtimensec = p16->st_mtimensec;
  q->st_ctime = p16->st_ctime;
  q->st_ctimensec = p16->st_ctimensec;
  q->st_size = p16->st_size;
  q->st_blocks = p16->st_blocks;
  q->st_blksize = p16->st_blksize;
  q->st_flags = p16->st_flags;
  q->st_gen = p16->st_gen;
  memcpy (q->__unused1, p16->__unused2, sizeof (p16->__unused2));
}

/* Convert a 'struct stat16' to 'struct stat64'.  */
static inline void
stat16_to_stat64 (const struct stat16 *p16, struct stat64 *q)
{
  q->st_dev = p16->st_dev;
  q->st_ino = p16->st_ino;
  q->st_mode = p16->st_mode;
  q->st_nlink = p16->st_nlink;
  q->st_uid = p16->st_uid;
  q->st_gid = p16->st_gid;
  q->st_rdev = p16->st_rdev;
  q->st_atime = p16->st_atime;
  q->st_atimensec = p16->st_atimensec;
  q->st_mtime = p16->st_mtime;
  q->st_mtimensec = p16->st_mtimensec;
  q->st_ctime = p16->st_ctime;
  q->st_ctimensec = p16->st_ctimensec;
  q->st_size = p16->st_size;
  q->st_blocks = p16->st_blocks;
  q->st_blksize = p16->st_blksize;
  q->st_flags = p16->st_flags;
  q->st_gen = p16->st_gen;
  memcpy (q->__unused1, p16->__unused2, sizeof (p16->__unused2));
}
