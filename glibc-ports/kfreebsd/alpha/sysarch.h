/* Parameters for the architecture specific system call.  alpha version.
   Copyright (C) 2002 Free Software Foundation, Inc.
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

#ifndef _SYSARCH_H
#define _SYSARCH_H	1

#include <features.h>

/* Function that can be used as first argument to 'sysarch'.  */
enum
  {
    ALPHA_SETHAE = 0,
#define ALPHA_SETHAE ALPHA_SETHAE
    /* Arg is 'unsigned long *'.  Returns the current pcb_fp_control.  */
    ALPHA_GET_FPMASK = 1,
#define ALPHA_GET_FPMASK ALPHA_GET_FPMASK
    /* Arg is 'unsigned long *'.  Sets the pcb_fp_control and returns its
       old value in the same memory location.  */
    ALPHA_SET_FPMASK = 2,
#define ALPHA_SET_FPMASK ALPHA_SET_FPMASK
    ALPHA_GET_UAC = 3,
#define ALPHA_GET_UAC ALPHA_GET_UAC
    ALPHA_SET_UAC = 4
#define ALPHA_SET_UAC ALPHA_SET_UAC
  };

__BEGIN_DECLS

extern int sysarch (int __cmd, void *__arg);

#ifdef _LIBC
extern int __sysarch (int __cmd, void *__arg);
#endif

__END_DECLS

#endif /* _SYSARCH_H */
