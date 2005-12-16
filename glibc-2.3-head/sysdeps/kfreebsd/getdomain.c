/* Copyright (C) 2002 Free Software Foundation, Inc.
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

#include <unistd.h>
#include <sys/sysctl.h>
#include <sys/param.h>
#include <errno.h>
#include <string.h>

/* Put the name of the current NIS domain in no more than LEN bytes of NAME.
   The result is null-terminated if LEN is large enough for the full
   name and the terminator.  */

int
getdomainname (char *name, size_t len)
{
  /* Fetch the "kern.domainname" sysctl value.  */
  int request[2] = { CTL_KERN, KERN_NISDOMAINNAME };
#if 1
  size_t result_len = len;

  if (__sysctl (request, 2, name, &result_len, NULL, 0) < 0)
    {
      if (errno == ENOMEM)
	__set_errno (ENAMETOOLONG);
      return -1;
    }

  if (result_len == len)
    {
      __set_errno (ENAMETOOLONG);
      return -1;
    }

  name[result_len] = '\0';
  return 0;
#else
  char buf[MAXHOSTNAMELEN + 1];
  char *result;
  size_t result_len;
  char *bufend;
  size_t buflen;

  if (len >= MAXHOSTNAMELEN)
    {
      result = name;
      result_len = len - 1;
    }
  else
    {
      /* Use a temporary buffer, so that we can detect the ENAMETOOLONG
	 condition.  (Well, we could also rely on the ENOMEM error code.)  */
      result = buf;
      result_len = MAXHOSTNAMELEN;
    }

  if (__sysctl (request, 2, result, &result_len, NULL, 0) < 0)
    return -1;

  /* If we used no temporary buffer, we are done.  */
  if (result == name)
    {
      result[resultlen] = '\0';
      return 0;
    }

  /* See if the result fits in the caller's buffer.  */
  bufend = memchr (buf, '\0', result_len);
  if (bufend == NULL)
    {
      bufend = buf + result_len;
      *bufend = '\0';
    }
  buflen = bufend - buf + 1;

  /* Copy into the caller's buffer.  */
  memcpy (name, buf, len < buflen ? len : buflen);

  if (len < buflen)
    {
      __set_errno (ENAMETOOLONG);
      return -1;
    }
  return 0;
#endif
}
libc_hidden_def (getdomainname)
