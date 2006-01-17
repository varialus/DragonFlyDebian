/* Machine-dependent signal context structure for FreeBSD.  alpha version.
   Copyright (C) 1991-1992,1994,1997,2001-2002 Free Software Foundation, Inc.
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

#if !defined _SIGNAL_H && !defined _SYS_UCONTEXT_H
# error "Never use <bits/sigcontext.h> directly; include <signal.h> instead."
#endif

#ifndef _BITS_SIGCONTEXT_H
#define _BITS_SIGCONTEXT_H  1

/* State of this thread when the signal was taken.  */
struct sigcontext
  {
    __sigset_t sc_mask;		/* Blocked signals to restore.  */
    long sc_onstack;		/* Nonzero if running on sigstack.  */

    /* General registers.  */
    unsigned long sc_regs[32];
    long sc_ps;
    long sc_pc;			/* Process counter.  */

    /* Trap arguments.  */
    unsigned long sc_traparg_a0;
    unsigned long sc_traparg_a1;
    unsigned long sc_traparg_a2;

    /* Floating-point registers.  */
    unsigned long sc_fpregs[32];
    unsigned long sc_fpcr;
    unsigned long sc_fp_control;
    long sc_ownedfp;
    long sc_format;              /* see mcontext_t */
    long sc_spare[6];            /* XXX */
  };

/* Traditional BSD names for some members.  */
#define sc_sp		sc_regs[30]	/* Stack pointer.  */
#define sc_fp		sc_regs[15]	/* Frame pointer.  */


#if 0 /* XXX These need verification.  */

/* Codes for SIGFPE.  */
#define FPE_INTDIV	1 /* integer divide by zero */
#define FPE_INTOVF	2 /* integer overflow */
#define FPE_FLTDIV	3 /* floating divide by zero */
#define FPE_FLTOVF	4 /* floating overflow */
#define FPE_FLTUND	5 /* floating underflow */
#define FPE_FLTINX	6 /* floating loss of precision */
#define FPE_SUBRNG_FAULT	0x7 /* BOUNDS instruction failed */
#define FPE_FLTDNR_FAULT	0x8 /* denormalized operand */
#define FPE_EMERR_FAULT		0xa /* mysterious emulation error 33 */
#define FPE_EMBND_FAULT		0xb /* emulation BOUNDS instruction failed */

/* Codes for SIGILL.  */
#define ILL_PRIVIN_FAULT	1
#define ILL_ALIGN_FAULT		14
#define ILL_FPOP_FAULT		24

/* Codes for SIGBUS.  */
#define BUS_PAGE_FAULT		12
#define BUS_SEGNP_FAULT		26
#define BUS_STK_FAULT		27
#define BUS_SEGM_FAULT		29

#endif

#endif /* _BITS_SIGCONTEXT_H */
