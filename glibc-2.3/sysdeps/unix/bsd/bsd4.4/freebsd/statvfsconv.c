/* Convert between 'struct statfs' and 'struct statvfs', 'struct statvfs64'.
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
#include <sys/mount.h>
#include <sys/syslimits.h>

/* Convert a 'struct statfs' to 'struct statvfs'.  */
static inline void
statfs_to_statvfs (const struct statfs *p32, struct statvfs *p)
{
  /* FIXME: What is the difference between f_bsize and f_frsize in
     'struct statvfs64'?  */
  p->f_bsize = p32->f_bsize;
  p->f_frsize = p32->f_bsize;

  p->f_blocks = p32->f_blocks;
  p->f_bfree = p32->f_bfree;
  p->f_bavail = p32->f_bavail;

  p->f_files = p32->f_files;
  p->f_ffree = p32->f_ffree;
  p->f_favail = p32->f_ffree;	/* Hmm.  May be filesystem dependent.  */

  p->f_fsid = p32->f_fsid;
  p->f_flag =
    (p32->f_flags & MNT_RDONLY ? ST_RDONLY : 0)
    | (p32->f_flags & MNT_NOSUID ? ST_NOSUID : 0)
    | (p32->f_flags & MNT_NODEV ? ST_NODEV : 0)
    | (p32->f_flags & MNT_NOEXEC ? ST_NOEXEC : 0)
    | (p32->f_flags & MNT_SYNCHRONOUS ? ST_SYNCHRONOUS : 0);
  p->f_namemax = PATH_MAX;	/* Hmm.  May be filesystem dependent.  */
  memset (p->f_spare, '\0', sizeof (p->f_spare));
}

/* Convert a 'struct statfs' to 'struct statvfs64'.  */
static inline void
statfs_to_statvfs64 (const struct statfs *p32, struct statvfs64 *p)
{
  /* FIXME: What is the difference between f_bsize and f_frsize in
     'struct statvfs64'?  */
  p->f_bsize = p32->f_bsize;
  p->f_frsize = p32->f_bsize;

  p->f_blocks = p32->f_blocks;
  p->f_bfree = p32->f_bfree;
  p->f_bavail = p32->f_bavail;

  p->f_files = p32->f_files;
  p->f_ffree = p32->f_ffree;
  p->f_favail = p32->f_ffree;	/* Hmm.  May be filesystem dependent.  */

  p->f_fsid = p32->f_fsid;
  p->f_flag =
    (p32->f_flags & MNT_RDONLY ? ST_RDONLY : 0)
    | (p32->f_flags & MNT_NOSUID ? ST_NOSUID : 0)
    | (p32->f_flags & MNT_NODEV ? ST_NODEV : 0)
    | (p32->f_flags & MNT_NOEXEC ? ST_NOEXEC : 0)
    | (p32->f_flags & MNT_SYNCHRONOUS ? ST_SYNCHRONOUS : 0);
  p->f_namemax = PATH_MAX;	/* Hmm.  May be filesystem dependent.  */
  memset (p->f_spare, '\0', sizeof (p->f_spare));
}
