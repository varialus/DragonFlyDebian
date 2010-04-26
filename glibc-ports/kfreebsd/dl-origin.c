/* Find path of executable.
   Copyright (C) 1998, 1999, 2000, 2002, 2004 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by Ulrich Drepper <drepper@cygnus.com>, 1998.

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

#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/param.h>
#include <ldsodefs.h>
#include <sysdep.h>

#include <dl-dst.h>

/* On Linux >= 2.1 systems which have the dcache implementation we can get
   the path of the application from the /proc/self/exe symlink.  Try this
   first and fall back on the generic method if necessary.  */


const char *_self_program_name_from_auxv attribute_hidden;

static int
_dl_self_name(char *buf, int buflen)
{
  int len;
  
  len = __readlink("/proc/self/exe", buf, buflen);

  if (len > 0 && buf[0] == '/')
    return len;

  if (_self_program_name_from_auxv)
  {
    strncpy(buf, _self_program_name_from_auxv, buflen);
    buf[buflen - 1] = 0;
    return strlen(buf);
  };
  
  return -1;
}



const char *
_dl_get_origin (void)
{
  char linkval[PATH_MAX];
  char *result;
  int len;

  len = _dl_self_name(linkval, sizeof(linkval));

  if (len > 0)
    {
      /* We can use this value.  */
      while (len > 1 && linkval[len - 1] != '/')
	--len;
      result = (char *) malloc (len + 1);
      if (result == NULL)
	result = (char *) -1;
      else if (len == 1)
	memcpy (result, "/", 2);
      else
	*((char *) __mempcpy (result, linkval, len - 1)) = '\0';
    }
  else
    {
      result = (char *) -1;
      /* We use the environment variable LD_ORIGIN_PATH.  If it is set make
	 a copy and strip out trailing slashes.  */
      if (GLRO(dl_origin_path) != NULL)
	{
	  size_t len = strlen (GLRO(dl_origin_path));
	  result = (char *) malloc (len + 1);
	  if (result == NULL)
	    result = (char *) -1;
	  else
	    {
	      char *cp = __mempcpy (result, GLRO(dl_origin_path), len);
	      while (cp > result + 1 && cp[-1] == '/')
		--cp;
	      *cp = '\0';
	    }
	}
    }

  return result;
}
