/* Operating system specific code  for generic dynamic loader functions.
   Copyright (C) 2006 Free Software Foundation, Inc.
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

#include <string.h>
#include <fcntl.h>
#include <sys/sysctl.h>
#include <sys/utsname.h>
#include <kernel-features.h>

#ifndef MIN
# define MIN(a,b) (((a)<(b))?(a):(b))
#endif

#ifdef SHARED
/* This is the function used in the dynamic linker to print the fatal error
   message.  */
static inline void
__attribute__ ((__noreturn__))
dl_fatal (const char *str)
{
  _dl_dprintf (2, str);
  _exit (1);
}
#endif


#define DL_SYSDEP_OSCHECK(FATAL) \
  do {									      \
    /* Test whether the kernel is new enough.  This test is only	      \
       performed if the library is not compiled to run on all		      \
       kernels.  */							      \
    if (__KFREEBSD_KERNEL_VERSION > 0)					      \
      {									      \
	char bufmem[64];						      \
	char *buf = bufmem;						      \
	unsigned int version;						      \
	int parts;							      \
	char *cp;							      \
	struct utsname uts;						      \
									      \
	/* Try the uname syscall */					      \
	if (! __uname (&uts))					      	      \
	  {							      	      \
	    /* Now convert it into a number.  The string consists of at most  \
	       three parts.  */						      \
	    version = 0;						      \
	    parts = 0;							      \
            buf = uts.release;						      \
	    cp = buf;							      \
	    while ((*cp >= '0') && (*cp <= '9'))			      \
	      {								      \
	        unsigned int here = *cp++ - '0';			      \
									      \
	        while ((*cp >= '0') && (*cp <= '9'))			      \
	          {							      \
		    here *= 10;						      \
		    here += *cp++ - '0';				      \
	          }							      \
									      \
	        ++parts;						      \
	        version *= 100;						      \
	        version |= here;					      \
									      \
	        if (*cp++ != '.')					      \
	          /* Another part following?  */			      \
	          break;						      \
	      }								      \
									      \
	    if (parts == 2)						      \
	      version *= 100;						      \
									      \
	    if (parts == 1)						      \
	      version *= 10000;						      \
									      \
	    /* Now we can test with the required version.  */		      \
	    if (version < __KFREEBSD_KERNEL_VERSION)			      \
	      /* Not sufficent.  */					      \
	      FATAL ("FATAL: kernel too old\n");			      \
									      \
	    GLRO(dl_osversion) = version;				      \
          }								      \
      }									      \
  } while (0)

static inline uintptr_t __attribute__ ((always_inline))
_dl_setup_stack_chk_guard (void)
{
  uintptr_t ret;
#ifdef ENABLE_STACKGUARD_RANDOMIZE 
  int fd = __open ("/dev/urandom", O_RDONLY);
  if (fd >= 0)
    {
      ssize_t reslen = __read (fd, &ret, sizeof (ret));
      __close (fd);
      if (reslen == (ssize_t) sizeof (ret))
        return ret;
    }
#endif
  ret = 0;
  unsigned char *p = (unsigned char *) &ret;
  p[sizeof (ret) - 1] = 255;
  p[sizeof (ret) - 2] = '\n';
  return ret;
}
