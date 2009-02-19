/* Machine-dependent pthreads configuration and inline functions.
   ix86 version for FreeBSD.
   Copyright (C) 1996-2001, 2002 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by Petr Salinger, 2005.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public License as
   published by the Free Software Foundation; either version 2.1 of the
   License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; see the file COPYING.LIB.  If not,
   write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA.  */

#ifndef _FREEBSD_PT_MACHINE_H
#define _FREEBSD_PT_MACHINE_H   1

/*
  some parts are common with linux/i386 version

  linux specific parts should be in
  linuxthreads/sysdeps/unix/sysv/linux/i386/
  but they are included directly in
  linuxthreads/sysdeps/i386/

  so include them

 */

#include <linuxthreads/sysdeps/i386/pt-machine.h>
#include <linuxthreads/sysdeps/i386/useldt.h>

/* hack them */

#ifndef __ASSEMBLER__

#undef INIT_THREAD_SELF
#undef FREE_THREAD

/* The P4 and above really want some help to prevent overheating.  */
#define BUSY_WAIT_NOP   __asm__ ("rep; nop")

/* and add few FreeBSD specifics */

#include <sysarch.h>

/* Initialize the thread-unique value. */

#define INIT_THREAD_SELF(descr, nr)		\
{						\
  long tmp;					\
  tmp = (long) descr;				\
  if (sysarch(I386_SET_GSBASE, &tmp)  != 0)	\
  {						\
    abort();					\
  }						\
}

#define FREE_THREAD(descr, nr) do { } while (0)

#endif /* __ASSEMBLER__ */

/* We want the OS to assign stack addresses.  */
#define FLOATING_STACKS 1

/* Maximum size of the stack if the rlimit is unlimited.  */
#define ARCH_STACK_MAX_SIZE     8*1024*1024

#endif /* _FREEBSD_PT_MACHINE_H  */
