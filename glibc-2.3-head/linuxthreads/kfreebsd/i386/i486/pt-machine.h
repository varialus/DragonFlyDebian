/* Machine-dependent pthreads configuration and inline functions.
   i486 version for kfreebsd.
   Copyright (C) 1996-2001, 2002 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by Richard Henderson <rth@tamu.edu>.

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

#ifndef _PT_MACHINE_H
#define _PT_MACHINE_H	1

#ifndef PT_EI
# define PT_EI extern inline
#endif

#ifndef ASSEMBLER

#include <stddef.h>	/* For offsetof.  */
#include <stdlib.h>	/* For abort().	 */
#include <sysarch.h>

extern long int testandset (int *spinlock);
extern int __compare_and_swap (long int *p, long int oldval, long int newval);

/* Get some notion of the current stack.  Need not be exactly the top
   of the stack, just something somewhere in the current frame.  */
#define CURRENT_STACK_FRAME  __builtin_frame_address (0)


/* Spinlock implementation; required.  */
PT_EI long int
testandset (int *spinlock)
{
  long int ret;

  __asm__ __volatile__ (
	"xchgl %0, %1"
	: "=r" (ret), "=m" (*spinlock)
	: "0" (1), "m" (*spinlock)
	: "memory");

  return ret;
}


/* Compare-and-swap for semaphores.  It's always available on i486+.  */
#define HAS_COMPARE_AND_SWAP

PT_EI int
__compare_and_swap (long int *p, long int oldval, long int newval)
{
  char ret;
  long int readval;

  __asm__ __volatile__ ("lock; cmpxchgl %3, %1; sete %0"
			: "=q" (ret), "=m" (*p), "=a" (readval)
			: "r" (newval), "m" (*p), "a" (oldval)
			: "memory");
  return ret;
}
#endif

/* The P4 and above really want some help to prevent overheating.  */
#define BUSY_WAIT_NOP	__asm__ ("rep; nop")


/* Return the thread descriptor for the current thread.

   The contained asm must *not* be marked volatile since otherwise
   assignments like
	pthread_descr self = thread_self();
   do not get optimized away.  */
   
#define THREAD_SELF \
({									      \
  register pthread_descr __self;					      \
  __asm__ ("movl %%gs:%c1,%0" : "=r" (__self)				      \
	   : "i" (offsetof (struct _pthread_descr_struct,		      \
			    p_header.data.self)));			      \
  __self;								      \
})

/* Initialize the thread-unique value. */

#ifndef I386_SET_GSBASE
#define I386_SET_GSBASE   10
#endif

// extern int sysarch(int cmd, void * param);

#define INIT_THREAD_SELF(descr, nr)		\
{						\
  long tmp;					\
  tmp = (long) descr;				\
  if (sysarch(I386_SET_GSBASE, &tmp)  != 0)	\
  {						\
    abort();					\
  }						\
}

/* Read member of the thread descriptor directly.  */
#define THREAD_GETMEM(descr, member) \
({									      \
  __typeof__ (descr->member) __value;					      \
  if (sizeof (__value) == 1)						      \
    __asm__ __volatile__ ("movb %%gs:%P2,%b0"				      \
			  : "=q" (__value)				      \
			  : "0" (0),					      \
			    "i" (offsetof (struct _pthread_descr_struct,      \
					   member)));			      \
  else if (sizeof (__value) == 4)					      \
    __asm__ __volatile__ ("movl %%gs:%P1,%0"				      \
			  : "=r" (__value)				      \
			  : "i" (offsetof (struct _pthread_descr_struct,      \
					   member)));			      \
  else									      \
    {									      \
      if (sizeof (__value) != 8)					      \
	/* There should not be any value with a size other than 1, 4 or 8.  */\
	abort ();							      \
									      \
      __asm__ __volatile__ ("movl %%gs:%P1,%%eax\n\t"			      \
			    "movl %%gs:%P2,%%edx"			      \
			    : "=A" (__value)				      \
			    : "i" (offsetof (struct _pthread_descr_struct,    \
					     member)),			      \
			      "i" (offsetof (struct _pthread_descr_struct,    \
					     member) + 4));		      \
    }									      \
  __value;								      \
})

/* Same as THREAD_GETMEM, but the member offset can be non-constant.  */
#define THREAD_GETMEM_NC(descr, member) \
({									      \
  __typeof__ (descr->member) __value;					      \
  if (sizeof (__value) == 1)						      \
    __asm__ __volatile__ ("movb %%gs:(%2),%b0"				      \
			  : "=q" (__value)				      \
			  : "0" (0),					      \
			    "r" (offsetof (struct _pthread_descr_struct,      \
					   member)));			      \
  else if (sizeof (__value) == 4)					      \
    __asm__ __volatile__ ("movl %%gs:(%1),%0"				      \
			  : "=r" (__value)				      \
			  : "r" (offsetof (struct _pthread_descr_struct,      \
					   member)));			      \
  else									      \
    {									      \
      if (sizeof (__value) != 8)					      \
	/* There should not be any value with a size other than 1, 4 or 8.  */\
	abort ();							      \
									      \
      __asm__ __volatile__ ("movl %%gs:(%1),%%eax\n\t"			      \
			    "movl %%gs:4(%1),%%edx"			      \
			    : "=&A" (__value)				      \
			    : "r" (offsetof (struct _pthread_descr_struct,    \
					     member)));			      \
    }									      \
  __value;								      \
})

/* Same as THREAD_SETMEM, but the member offset can be non-constant.  */
#define THREAD_SETMEM(descr, member, value) \
({									      \
  __typeof__ (descr->member) __value = (value);				      \
  if (sizeof (__value) == 1)						      \
    __asm__ __volatile__ ("movb %0,%%gs:%P1" :				      \
			  : "q" (__value),				      \
			    "i" (offsetof (struct _pthread_descr_struct,      \
					   member)));			      \
  else if (sizeof (__value) == 4)					      \
    __asm__ __volatile__ ("movl %0,%%gs:%P1" :				      \
			  : "r" (__value),				      \
			    "i" (offsetof (struct _pthread_descr_struct,      \
					   member)));			      \
  else									      \
    {									      \
      if (sizeof (__value) != 8)					      \
	/* There should not be any value with a size other than 1, 4 or 8.  */\
	abort ();							      \
									      \
      __asm__ __volatile__ ("movl %%eax,%%gs:%P1\n\n"			      \
			    "movl %%edx,%%gs:%P2" :			      \
			    : "A" (__value),				      \
			      "i" (offsetof (struct _pthread_descr_struct,    \
					     member)),			      \
			      "i" (offsetof (struct _pthread_descr_struct,    \
					     member) + 4));		      \
    }									      \
})

/* Set member of the thread descriptor directly.  */
#define THREAD_SETMEM_NC(descr, member, value) \
({									      \
  __typeof__ (descr->member) __value = (value);				      \
  if (sizeof (__value) == 1)						      \
    __asm__ __volatile__ ("movb %0,%%gs:(%1)" :				      \
			  : "q" (__value),				      \
			    "r" (offsetof (struct _pthread_descr_struct,      \
					   member)));			      \
  else if (sizeof (__value) == 4)					      \
    __asm__ __volatile__ ("movl %0,%%gs:(%1)" :				      \
			  : "r" (__value),				      \
			    "r" (offsetof (struct _pthread_descr_struct,      \
					   member)));			      \
  else									      \
    {									      \
      if (sizeof (__value) != 8)					      \
	/* There should not be any value with a size other than 1, 4 or 8.  */\
	abort ();							      \
									      \
      __asm__ __volatile__ ("movl %%eax,%%gs:(%1)\n\t"			      \
			    "movl %%edx,%%gs:4(%1)" :			      \
			    : "A" (__value),				      \
			      "r" (offsetof (struct _pthread_descr_struct,    \
					     member)));			      \
    }									      \
})

/* We want the OS to assign stack addresses.  */
#define FLOATING_STACKS	1

/* Maximum size of the stack if the rlimit is unlimited.  */
#define ARCH_STACK_MAX_SIZE	8*1024*1024

#endif /* pt-machine.h */
