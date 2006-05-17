/* Copyright (C) 2002, 2003, 2004 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by Jakub Jelinek <jakub@redhat.com>, 2002.
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

#include <sysdep.h>
#include <tls.h>
#include <pt-machine.h>
#ifndef __ASSEMBLER__
# include <linuxthreads/internals.h>
#endif

#if !defined NOT_IN_libc || defined IS_IN_libpthread || defined IS_IN_librt

# undef PSEUDO
# define PSEUDO(name, syscall_name, args)				      \
  .text;								      \
  ENTRY (name)								      \
    SINGLE_THREAD_P;							      \
    jne L(pseudo_cancel);						      \
    DO_CALL (syscall_name, args);					      \
    jb SYSCALL_ERROR_LABEL;						      \
    ret;								      \
  L(pseudo_cancel):							      \
    CENABLE								      \
    movl %eax, %ecx;							      \
    movl $SYS_ify (syscall_name), %eax;					      \
    int $0x80;								      \
    PUSHRESULT;							      	      \
    movl %ecx, %eax; 							      \
    CDISABLE;							 	      \
    POPRESULT;							      	      \
    jb SYSCALL_ERROR_LABEL;						      \
  L(pseudo_end):

/* 
  on FreeBSD some syscalls return result in pair edx+eax, 
  therefore proper way would be

# define PUSHRESULT	pushl %edx; pushl %eax; pushfl		
# define POPRESULT	popfl; popl %eax; popl %edx
 
  for FreeBSD 5.4 affected syscalls are
  
	lseek()
	fork()
	vfork()
	rfork()
	pipe()
   
   none of them is cancelable, therefore
*/

# define PUSHRESULT	pushl %eax; cfi_adjust_cfa_offset (4);  pushfl;    cfi_adjust_cfa_offset (4)
# define POPRESULT	popfl;      cfi_adjust_cfa_offset (-4); popl %eax; cfi_adjust_cfa_offset (-4)

# ifdef IS_IN_libpthread
#  define CENABLE	call __pthread_enable_asynccancel;
#  define CDISABLE	call __pthread_disable_asynccancel
# elif defined IS_IN_librt
#  ifdef PIC
#   define CENABLE	pushl %ebx; \
			cfi_adjust_cfa_offset (4); \
			cfi_rel_offset (ebx, 0); \
			call __i686.get_pc_thunk.bx; \
			addl     $_GLOBAL_OFFSET_TABLE_, %ebx; \
			call __librt_enable_asynccancel@PLT; \
			popl %ebx; \
			cfi_adjust_cfa_offset (-4); \
			cfi_restore (ebx);
#   define CDISABLE	pushl %ebx; \
			cfi_adjust_cfa_offset (4); \
			cfi_rel_offset (ebx, 0); \
			call __i686.get_pc_thunk.bx; \
			addl     $_GLOBAL_OFFSET_TABLE_, %ebx; \
			call __librt_disable_asynccancel@PLT; \
			popl %ebx; \
			cfi_adjust_cfa_offset (-4); \
			cfi_restore (ebx);
#  else
#   define CENABLE	call __librt_enable_asynccancel;
#   define CDISABLE	call __librt_disable_asynccancel
#  endif
# else
#  define CENABLE	call __libc_enable_asynccancel;
#  define CDISABLE	call __libc_disable_asynccancel
# endif

#if !defined NOT_IN_libc
# define __local_multiple_threads __libc_multiple_threads
#elif defined IS_IN_libpthread
# define __local_multiple_threads __pthread_multiple_threads
#else
# define __local_multiple_threads __librt_multiple_threads
#endif

# ifndef __ASSEMBLER__
#  if defined FLOATING_STACKS && USE___THREAD && defined PIC
#   define SINGLE_THREAD_P \
  __builtin_expect (THREAD_GETMEM (THREAD_SELF,				      \
				   p_header.data.multiple_threads) == 0, 1)
#  else
extern int __local_multiple_threads
#   if !defined NOT_IN_libc || defined IS_IN_libpthread
  attribute_hidden;
#   else
  ;
#   endif
#   define SINGLE_THREAD_P __builtin_expect (__local_multiple_threads == 0, 1)
#  endif
# else
#  if !defined PIC
#   define SINGLE_THREAD_P cmpl $0, __local_multiple_threads
#  elif defined FLOATING_STACKS && USE___THREAD
#   define SINGLE_THREAD_P cmpl $0, %gs:MULTIPLE_THREADS_OFFSET
#  else
#   if !defined NOT_IN_libc || defined IS_IN_libpthread
#    define __SINGLE_THREAD_CMP cmpl $0, __local_multiple_threads@GOTOFF(%ecx)
#   else
#    define __SINGLE_THREAD_CMP \
  movl __local_multiple_threads@GOT(%ecx), %ecx;\
  cmpl $0, (%ecx)
#   endif
#   if !defined HAVE_HIDDEN || !USE___THREAD
#    define SINGLE_THREAD_P \
  SETUP_PIC_REG (cx);				\
  addl $_GLOBAL_OFFSET_TABLE_, %ecx;		\
  __SINGLE_THREAD_CMP
#   else
#    define SINGLE_THREAD_P \
  call __i686.get_pc_thunk.cx;			\
  addl $_GLOBAL_OFFSET_TABLE_, %ecx;		\
  __SINGLE_THREAD_CMP
#   endif
#  endif
# endif

#elif !defined __ASSEMBLER__

/* This code should never be used but we define it anyhow.  */
# define SINGLE_THREAD_P (1)

#endif
