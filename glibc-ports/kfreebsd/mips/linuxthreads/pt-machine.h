/* Machine-dependent pthreads configuration and inline functions.
   MIPS kFreeBSD version.
   Copyright (C) 2001, 2002, 2003, 2004, 2010 Free Software Foundation, Inc.
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

#ifndef _FREEBSD_PT_MACHINE_H
#define _FREEBSD_PT_MACHINE_H   1

/*
  almost all parts are common with linux version
 */

#include <linuxthreads/sysdeps/mips/pt-machine.h>

#ifndef __ASSEMBLER__

/* and only one FreeBSD specifics */

#include <machine/sysarch.h>

/* Initialize the thread-unique value. */

#undef INIT_THREAD_SELF
#define INIT_THREAD_SELF(descr, nr)			\
  {							\
    if (sysarch (MIPS_SET_TLS, descr) != 0)		\
      {							\
	abort();					\
      }							\
  }

#endif /* !__ASSEMBLER__ */

#endif /* pt-machine.h */
