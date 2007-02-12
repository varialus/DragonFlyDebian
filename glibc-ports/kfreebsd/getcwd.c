/* Determine current working directory.  FreeBSD version.
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

#include <errno.h>
#include <limits.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <sysdep.h>
#include <bp-checks.h>

/* The system calls only makes a lookup in the VFS cache, which can easily
   fail.  Therefore we use the generic version as a fallback.  */
extern int __syscall_getcwd (char *__unbounded buf, unsigned int size);
static char *generic_getcwd (char *buf, size_t size) internal_function;

char *
__getcwd (char *buf, size_t size)
{
  char tmpbuf[PATH_MAX];

  if (INLINE_SYSCALL (getcwd, 2, tmpbuf, PATH_MAX) >= 0)
    {
      size_t len = strlen (tmpbuf) + 1;

      if (size == 0)
	{
	  if (__builtin_expect (buf != NULL, 0))
	    {
	      __set_errno (EINVAL);
	      return NULL;
	    }

	  buf = (char *) malloc (len);
	  if (__builtin_expect (buf == NULL, 0))
	    {
	      __set_errno (ENOMEM);
	      return NULL;
	    }
	}
      else
	{
	  if (size < len)
	    {
	      __set_errno (ERANGE);
	      return NULL;
	    }

	  if (buf == NULL)
	    {
	      buf = (char *) malloc (size);
	      if (__builtin_expect (buf == NULL, 0))
		{
		  __set_errno (ENOMEM);
		  return NULL;
		}
	    }
	}

      memcpy (buf, tmpbuf, len);
      return buf;
    }
#if IS_IN_rtld
  return NULL;
#else  
  return generic_getcwd (buf, size);
#endif  
}

weak_alias (__getcwd, getcwd)

#if !IS_IN_rtld
/* Get the code for the generic version.  */
#define GETCWD_RETURN_TYPE	static char * internal_function
#define __getcwd		generic_getcwd
#include <sysdeps/posix/getcwd.c>
#endif
