/* Machine-dependent processor state structure for FreeBSD.  i386 version.
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
    int mc_onstack;		/* Nonzero if running on sigstack.  */

    /* Segment registers.  */
    int mc_gs;
    int mc_fs;
    int mc_es;
    int mc_ds;

    /* "General" registers.  These members are in the order that the i386
       `pusha' and `popa' instructions use (`popa' ignores %esp).  */
    int mc_edi;
    int mc_esi;
    int mc_ebp;
    int mc_isp;			/* Not used; sc_esp is used instead.  */
    int mc_ebx;
    int mc_edx;
    int mc_ecx;
    int mc_eax;

    int mc_trapno;
    int mc_err;

    int mc_eip;			/* Instruction pointer.  */
    int mc_cs;			/* Code segment register.  */

    int mc_efl;			/* Processor flags.  */

    int mc_esp;			/* This stack pointer is used.  */
    int mc_ss;			/* Stack segment register.  */

    int mc_fpregs[28];
    int mc_spare[17];
  } mcontext_t;

/* Traditional BSD names for some members.  */
#define mc_eflags	mc_efl
