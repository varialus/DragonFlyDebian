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

/* Convert a 'struct stat32' to 'struct stat'.  */
static inline void
stat32_to_stat (const struct stat32 *p32, struct stat *q)
{
  q->st_dev = p32->st_dev;
  q->st_ino = p32->st_ino;
  q->st_mode = p32->st_mode;
  q->st_nlink = p32->st_nlink;
  q->st_uid = p32->st_uid;
  q->st_gid = p32->st_gid;
  q->st_rdev = p32->st_rdev;
  q->st_atime = p32->st_atime;
  q->st_atimensec = p32->st_atimensec;
  q->st_mtime = p32->st_mtime;
  q->st_mtimensec = p32->st_mtimensec;
  q->st_ctime = p32->st_ctime;
  q->st_ctimensec = p32->st_ctimensec;
  q->st_size = p32->st_size;
  q->st_blocks = p32->st_blocks;
  q->st_blksize = p32->st_blksize;
  q->st_flags = p32->st_flags;
  q->st_gen = p32->st_gen;
  memcpy (q->__unused1, p32->__unused1, sizeof (p32->__unused1));
}

/* Convert a 'struct stat32' to 'struct stat64'.  */
static inline void
stat32_to_stat64 (const struct stat32 *p32, struct stat64 *q)
{
  q->st_dev = p32->st_dev;
  q->st_ino = p32->st_ino;
  q->st_mode = p32->st_mode;
  q->st_nlink = p32->st_nlink;
  q->st_uid = p32->st_uid;
  q->st_gid = p32->st_gid;
  q->st_rdev = p32->st_rdev;
  q->st_atime = p32->st_atime;
  q->st_atimensec = p32->st_atimensec;
  q->st_mtime = p32->st_mtime;
  q->st_mtimensec = p32->st_mtimensec;
  q->st_ctime = p32->st_ctime;
  q->st_ctimensec = p32->st_ctimensec;
  q->st_size = p32->st_size;
  q->st_blocks = p32->st_blocks;
  q->st_blksize = p32->st_blksize;
  q->st_flags = p32->st_flags;
  q->st_gen = p32->st_gen;
  memcpy (q->__unused1, p32->__unused1, sizeof (p32->__unused1));
}
