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

#include <sys/utsname.h>
#include <sys/sysctl.h>
#include <errno.h>
#include <string.h>

/* Dummy values used as a fallback.  */
#define UNAME_SYSNAME	"FreeBSD"
#define UNAME_RELEASE	"4.0"
#define UNAME_VERSION	"GENERIC"
#define UNAME_MACHINE	"mmix"

/* Put information about the system in NAME.  */
int
__uname (struct utsname *name)
{
  /* Fill nodename: "uname -n".  Fetch sysctl "kern.hostname".  */
  {
    int request[2] = { CTL_KERN, KERN_HOSTNAME };
    size_t len = sizeof (name->nodename);
    if (__sysctl (request, 2, name->nodename, &len, NULL, 0) >= 0)
      {
	if (len < sizeof (name->nodename))
	  name->nodename[len] = '\0';
      }
    else
      {
	if (errno != ENOMEM)
	  strncpy (name->nodename, "localhost", sizeof (name->nodename));
      }
  }

  /* Fill sysname: "uname -s".  Fetch sysctl "kern.ostype".  */
  {
    int request[2] = { CTL_KERN, KERN_OSTYPE };
    size_t len = sizeof (name->sysname);
    if (__sysctl (request, 2, name->sysname, &len, NULL, 0) >= 0)
      {
	if (len < sizeof (name->sysname))
	  name->sysname[len] = '\0';
      }
    else
      {
	if (errno != ENOMEM)
	  strncpy (name->sysname, UNAME_SYSNAME, sizeof (name->sysname));
      }
  }

  /* Fill release: "uname -r".  Fetch sysctl "kern.osrelease".  */
  {
    int request[2] = { CTL_KERN, KERN_OSRELEASE };
    size_t len = sizeof (name->release);
    if (__sysctl (request, 2, name->release, &len, NULL, 0) >= 0)
      {
	if (len < sizeof (name->release))
	  name->release[len] = '\0';
      }
    else
      {
	if (errno != ENOMEM)
	  strncpy (name->release, UNAME_RELEASE, sizeof (name->release));
      }
  }

  /* Fill version: "uname -v".  Fetch sysctl "kern.version".  */
  {
    int request[2] = { CTL_KERN, KERN_VERSION };
    size_t len = sizeof (name->version);
    if (__sysctl (request, 2, name->version, &len, NULL, 0) >= 0)
      {
	if (len < sizeof (name->version))
	  name->version[len] = '\0';
      }
    else
      {
	if (errno != ENOMEM)
	  strncpy (name->version, UNAME_VERSION, sizeof (name->version));
      }

    /* Remove trailing whitespace.  Turn non-trailing whitespace to
       spaces.  */
    {
      char *p0 = name->version;
      char *p = p0 + __strnlen (p0, sizeof (name->version));

      while (p > p0 && (p[-1] == '\t' || p[-1] == '\n' || p[-1] == ' '))
	*--p = '\0';

      while (p > p0)
	{
	  --p;
	  if (*p == '\t' || *p == '\n')
	    *p = ' ';
	}
    }
  }

  /* Fill machine: "uname -m".  Fetch sysctl "hw.machine".  */
  {
    int request[2] = { CTL_HW, HW_MACHINE };
    size_t len = sizeof (name->machine);
    if (__sysctl (request, 2, name->machine, &len, NULL, 0) >= 0)
      {
	if (len < sizeof (name->machine))
	  name->machine[len] = '\0';
      }
    else
      {
	if (errno != ENOMEM)
	  strncpy (name->machine, UNAME_MACHINE, sizeof (name->machine));
      }
  }

  return 0;
}
libc_hidden_def (__uname)

weak_alias (__uname, uname)
libc_hidden_def (uname)
