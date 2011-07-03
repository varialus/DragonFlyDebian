/* Copyright (C) 2007 Free Software Foundation, Inc.
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

#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>


int
__unlockpt (int fd)
{
  struct stat64 st;

  /* there is no need/way to do unlocking of slave pseudo-terminal device,
     just check whether fd might be valid master pseudo-terminal device */

  if (__fxstat64 (_STAT_VER, fd, &st) < 0)
    return -1;

  if (!(S_ISCHR (st.st_mode)))
  {
    __set_errno (ENOTTY);
    return -1;
  }

  return 0;
}

weak_alias (__unlockpt, unlockpt)
