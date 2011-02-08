/* Copyright (C) 1998, 2002 Free Software Foundation, Inc.
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
#include <paths.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/sysmacros.h>
#include <sys/sysctl.h>
#include <unistd.h>


/* Static buffer for `ptsname'.  */
static char buffer[sizeof (_PATH_TTY) + 2];


/* Return the pathname of the pseudo terminal slave associated with
   the master FD is open on, or NULL on errors.
   The returned storage is good until the next call to this function.  */
char *
ptsname (int fd)
{
  return __ptsname_r (fd, buffer, sizeof (buffer)) != 0 ? NULL : buffer;
}

/* The are declared in getpt.c.  */
extern const char __libc_ptyname1[] attribute_hidden;
extern const char __libc_ptyname2[] attribute_hidden;


int
__ptsname_internal (int fd, char *buf, size_t buflen, struct stat64 *stp)
{
  int saved_errno = errno;
  char *p;

  if (buf == NULL)
    {
      __set_errno (EINVAL);
      return EINVAL;
    }

  /* Don't call isatty (fd) - it usually fails with errno = EAGAIN.  */

  if (__fxstat64 (_STAT_VER, fd, stp) < 0)
    return errno;

  /* Check if FD really is a master pseudo terminal.  */
  if (!(S_ISCHR (stp->st_mode)))
    {
      __set_errno (ENOTTY);
      return ENOTTY;
    }

  if (buflen < sizeof (_PATH_TTY) + 2)
    {
      __set_errno (ERANGE);
      return ERANGE;
    }

  /* Construct the slave's pathname.  */
  /* instead of strlen(_PATH_DEV) we use (sizeof (_PATH_DEV) - 1)  */
  p = __mempcpy (buf, _PATH_DEV, sizeof (_PATH_DEV) - 1);
  buflen -= (sizeof (_PATH_DEV) - 1);
  if(__sysctlbyname("kern.devname", p, &buflen, &stp->st_rdev, sizeof (stp->st_rdev)) < 0)
    return errno;
  p[0] = 't';

  if (__xstat64 (_STAT_VER, buf, stp) < 0)
    return errno;

  /* Check if the pathname we're about to return might be
     slave pseudo terminal of the given master pseudo terminal.  */
  if (!(S_ISCHR (stp->st_mode)))
    {
      /* This really is a configuration problem.  */
      __set_errno (ENOTTY);
      return ENOTTY;
    }

  __set_errno (saved_errno);
  return 0;
}


/* Store at most BUFLEN characters of the pathname of the slave pseudo
   terminal associated with the master FD is open on in BUF.
   Return 0 on success, otherwise an error number.  */
int
__ptsname_r (int fd, char *buf, size_t buflen)
{
  struct stat64 st;
  return __ptsname_internal (fd, buf, buflen, &st);
}
weak_alias (__ptsname_r, ptsname_r)
