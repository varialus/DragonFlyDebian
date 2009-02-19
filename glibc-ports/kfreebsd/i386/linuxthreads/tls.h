/* Definition for thread-local data handling.  linuxthreads/i386 version.
   Copyright (C) 2002, 2003, 2004 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Modification for FreeBSD by Petr Salinger, 2005.

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

#ifndef _FREEBSD_TLS_H
#define _FREEBSD_TLS_H

#include <linuxthreads/sysdeps/i386/tls.h>

/* We can support TLS only if the floating-stack support is available.
   To avoid bothering with the TLS support code at all,
   use configure --without-tls.

   We need USE_TLS to be consistently defined, for ldsodefs.h conditionals.
   But some of the code below can cause problems in building libpthread
*/

#if defined HAVE_TLS_SUPPORT \
    && (defined FLOATING_STACKS || !defined IS_IN_libpthread)

# ifndef __ASSEMBLER__

#undef TLS_INIT_TP
#undef TLS_SETUP_GS_SEGMENT

#include <sysarch.h>
#include <sys/syscall.h>


/* Code to initially initialize the thread pointer.  This might need
   special attention since 'errno' is not yet available and if the
   operation can cause a failure 'errno' must not be touched. */

#  define TLS_DO_SET_GSBASE(descr)		\
({                                      	\
  long base = (long) descr;             	\
  int result;                           	\
  asm volatile (                        	\
                "pushl %3\n\t"          	\
                "pushl %2\n\t"          	\
                "pushl %1\n\t"       		\
                "int $0x80\n\t"         	\
                "popl %3\n\t"        		\
                "popl %3\n\t"        		\
                "popl %3\n\t"        		\
                : "=a" (result)         	\
                : "0" (SYS_sysarch),     	\
                  "i" (I386_SET_GSBASE),       	\
                  "d" (&base)			\
                : "memory", "cc" );    		\
  result;                                       \
})

#   define TLS_SETUP_GS_SEGMENT(descr, secondcall)                            \
  (TLS_DO_SET_GSBASE(descr)                                                   \
   ? "set_thread_area failed when setting up thread-local storage\n" : NULL)

/*   The value of this macro is null if successful, or an error string.  */

#  define TLS_INIT_TP(descr, secondcall)				      \
  ({									      \
    void *_descr = (descr);						      \
    tcbhead_t *head = _descr;						      \
									      \
    head->tcb = _descr;							      \
    /* For now the thread descriptor is at the same address.  */	      \
    head->self = _descr;						      \
									      \
    INIT_SYSINFO;							      \
    TLS_SETUP_GS_SEGMENT (_descr, secondcall);				      \
  })

# endif /* __ASSEMBLER__ */

#endif	/* HAVE_TLS_SUPPORT && (FLOATING_STACKS || !IS_IN_libpthread) */

#endif	/* _FREEBSD_TLS_H */
