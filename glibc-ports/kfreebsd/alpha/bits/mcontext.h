/* Machine-dependent processor state structure for FreeBSD.  alpha version.
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

#if !defined _SYS_UCONTEXT_H
# error "Never use <bits/mcontext.h> directly; include <sys/ucontext.h> instead."
#endif

/* Whole processor state.  */
typedef struct
  {
    long mc_onstack;		/* Nonzero if running on sigstack.  */

    /* General registers.  */
    unsigned long mc_regs[32];
    long mc_ps;
    long mc_pc;			/* Process counter.  */

    /* Trap arguments.  */
    unsigned long mc_traparg_a0;
    unsigned long mc_traparg_a1;
    unsigned long mc_traparg_a2;

    /* Floating-point registers.  */
    unsigned long mc_fpregs[32];
    unsigned long mc_fpcr;
    unsigned long mc_fp_control;
#define _MC_FPOWNED_NONE        0       /* FP state not used */
#define _MC_FPOWNED_FPU         1       /* FP state came from FPU */
#define _MC_FPOWNED_PCB         2       /* FP state came from PCB */
    long mc_ownedfp;
#define _MC_REV0_SIGFRAME       1       /* context is a signal frame */
#define _MC_REV0_TRAPFRAME      2       /* context is a trap frame */
    long    mc_format;
    long    mc_thrptr;                  /* Thread pointer */
    long    mc_spare[5];
  } mcontext_t;
