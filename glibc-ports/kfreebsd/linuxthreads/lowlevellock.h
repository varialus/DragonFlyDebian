/* Copyright (C) 2007 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
   02111-1307 USA.  */

#ifndef _LOWLEVELLOCK_H
#define _LOWLEVELLOCK_H	1

#include <atomic.h>

typedef union
{
  volatile void *	uv;	/* in fact struct umtx from <sys/umtx.h> */
  volatile int		iv;
  volatile long		lv;
  
} __rtld_mrlock_t;

#define UMTX_OP_WAIT	2	/*  <sys/umtx.h> */
#define UMTX_OP_WAKE	3	/*  <sys/umtx.h> */

extern int __syscall__umtx_op(void *, int, long, void*, void*);

#define lll_futex_wake(futexp, nr) \
  ({									      \
    __syscall__umtx_op(futexp, UMTX_OP_WAKE,			              \
		       (long) nr, NULL, NULL);				      \
  })

#define lll_futex_wait(futexp, val) \
  ({									      \
    __syscall__umtx_op(futexp, UMTX_OP_WAIT,				      \
		       (long) val, NULL, NULL);				      \
  })

#endif	/* lowlevellock.h */
