/* Copyright (C) 1992,1993,1995-2000,2002,2003,2004
   Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by Ulrich Drepper, <drepper@gnu.org>, August 1995.

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

#ifndef _FREEBSD_I386_SYSDEP_H
#define _FREEBSD_I386_SYSDEP_H 1

/* There is some commonality.  */
#include <sysdeps/unix/i386/sysdep.h>
#include <bp-sym.h>
#include <bp-asm.h>
/* Defines RTLD_PRIVATE_ERRNO and USE_DL_SYSINFO.  */
#include <dl-sysdep.h>
#include <tls.h>

#ifdef __ASSEMBLER__

/* We don't want the label for the error handle to be global when we define
   it here.  */
#ifdef PIC
# define SYSCALL_ERROR_LABEL 0f
#else
# define SYSCALL_ERROR_LABEL syscall_error
#endif

#undef	PSEUDO
#define	PSEUDO(name, syscall_name, args)				      \
  .text;								      \
  ENTRY (name)								      \
    DO_CALL (syscall_name, args);					      \
    jb SYSCALL_ERROR_LABEL;						      \
  L(pseudo_end):

#undef	PSEUDO_END
#define	PSEUDO_END(name)						      \
  SYSCALL_ERROR_HANDLER							      \
  END (name)

#undef	PSEUDO_NOERRNO
#define	PSEUDO_NOERRNO(name, syscall_name, args)			      \
  .text;								      \
  ENTRY (name)								      \
    DO_CALL (syscall_name, args)

#undef	PSEUDO_END_NOERRNO
#define	PSEUDO_END_NOERRNO(name)					      \
  END (name)

#define ret_NOERRNO ret

/* The function has to return the error code.  */
#undef	PSEUDO_ERRVAL
#define	PSEUDO_ERRVAL(name, syscall_name, args) \
  .text;								      \
  ENTRY (name)								      \
    DO_CALL (syscall_name, args);					      \

#undef	PSEUDO_END_ERRVAL
#define	PSEUDO_END_ERRVAL(name) \
  END (name)

#define ret_ERRVAL ret

#ifndef PIC
# define SYSCALL_ERROR_HANDLER	/* Nothing here; code in sysdep.S is used.  */
#else

# ifndef HAVE_HIDDEN
#  define SETUP_PIC_REG(reg) \
  call 1f;								      \
  .subsection 1;							      \
1:movl (%esp), %e##reg;							      \
  ret;									      \
  .previous
# else
#  define SETUP_PIC_REG(reg) \
  .section .gnu.linkonce.t.__i686.get_pc_thunk.reg,"ax",@progbits;	      \
  .globl __i686.get_pc_thunk.reg;					      \
  .hidden __i686.get_pc_thunk.reg;					      \
  .type __i686.get_pc_thunk.reg,@function;				      \
__i686.get_pc_thunk.reg:						      \
  movl (%esp), %e##reg;							      \
  ret;									      \
  .size __i686.get_pc_thunk.reg, . - __i686.get_pc_thunk.reg;		      \
  .previous;								      \
  call __i686.get_pc_thunk.reg
# endif

# if RTLD_PRIVATE_ERRNO
#  define SYSCALL_ERROR_HANDLER						      \
0:SETUP_PIC_REG(cx);							      \
  addl $_GLOBAL_OFFSET_TABLE_, %ecx;					      \
  movl %eax, rtld_errno@GOTOFF(%ecx);					      \
  orl $-1, %eax;							      \
  jmp L(pseudo_end);

# elif defined _LIBC_REENTRANT

#  if USE___THREAD
#   ifndef NOT_IN_libc
#    define SYSCALL_ERROR_ERRNO __libc_errno
#   else
#    define SYSCALL_ERROR_ERRNO errno
#   endif
#   define SYSCALL_ERROR_HANDLER					      \
0:SETUP_PIC_REG (cx);							      \
  addl $_GLOBAL_OFFSET_TABLE_, %ecx;					      \
  movl SYSCALL_ERROR_ERRNO@GOTNTPOFF(%ecx), %ecx;			      \
  SYSCALL_ERROR_HANDLER_TLS_STORE (%eax, %ecx);				      \
  orl $-1, %eax;							      \
  jmp L(pseudo_end);
#   ifndef NO_TLS_DIRECT_SEG_REFS
#    define SYSCALL_ERROR_HANDLER_TLS_STORE(src, destoff)		      \
  movl src, %gs:(destoff)
#   else
#    define SYSCALL_ERROR_HANDLER_TLS_STORE(src, destoff)		      \
  addl %gs:0, destoff;							      \
  movl src, (destoff)
#   endif
#  else
#   define SYSCALL_ERROR_HANDLER					      \
0:pushl %ebx;								      \
  SETUP_PIC_REG (bx);							      \
  addl $_GLOBAL_OFFSET_TABLE_, %ebx;					      \
  pushl %eax;								      \
  PUSH_ERRNO_LOCATION_RETURN;						      \
  call BP_SYM (__errno_location)@PLT;					      \
  POP_ERRNO_LOCATION_RETURN;						      \
  popl %ecx;								      \
  popl %ebx;								      \
  movl %ecx, (%eax);							      \
  orl $-1, %eax;							      \
  jmp L(pseudo_end);
/* A quick note: it is assumed that the call to `__errno_location' does
   not modify the stack!  */
#  endif
# else
/* Store (%eax) into errno through the GOT.  */
#  define SYSCALL_ERROR_HANDLER						      \
0:SETUP_PIC_REG(cx);							      \
  addl $_GLOBAL_OFFSET_TABLE_, %ecx;					      \
  movl errno@GOT(%ecx), %ecx;						      \
  movl %eax, (%ecx);							      \
  orl $-1, %eax;							      \
  jmp L(pseudo_end);
# endif	/* _LIBC_REENTRANT */
#endif	/* PIC */

/* 
    FreeBSD expects the system call arguments on the stack,
   syscall number is in %eax.
   return value is in %eax + %edx
   error is signaled via cflags.
   all other data registers are preserved

	syscall number	%eax	     call-clobbered

   The stack layout upon entering the function is:

	20(%esp)	Arg# 5
	16(%esp)	Arg# 4
	12(%esp)	Arg# 3
	 8(%esp)	Arg# 2
	 4(%esp)	Arg# 1
	  (%esp)	Return address

   (Of course a function with say 3 arguments does not have entries for
   arguments 4 and 5.)

*/

#undef	DO_CALL
#define DO_CALL(syscall_name, args)			      		      \
    movl $SYS_ify (syscall_name), %eax;					      \
    int $0x80								      \

#else	/* !__ASSEMBLER__ */

#include <syscalls-inline.h>

/* Consistency check for position-independent code.  */
#ifdef __PIC__
# define check_consistency()						      \
  ({ int __res;								      \
     __asm__ __volatile__						      \
       ("call __i686.get_pc_thunk.cx;"					      \
	"addl $_GLOBAL_OFFSET_TABLE_, %%ecx;"				      \
	"subl %%ebx, %%ecx;"						      \
	"je 1f;"							      \
	"ud2;"								      \
	"1:\n"								      \
	".section .gnu.linkonce.t.__i686.get_pc_thunk.cx,\"ax\",@progbits;"   \
	".globl __i686.get_pc_thunk.cx;"				      \
	".hidden __i686.get_pc_thunk.cx;"				      \
	".type __i686.get_pc_thunk.cx,@function;"			      \
	"__i686.get_pc_thunk.cx:"					      \
	"movl (%%esp), %%ecx;"						      \
	"ret;"								      \
	".previous"							      \
	: "=c" (__res));						      \
     __res; })
#endif

#endif	/* __ASSEMBLER__ */

#endif /* _FREEBSD_I386_SYSDEP_H */
