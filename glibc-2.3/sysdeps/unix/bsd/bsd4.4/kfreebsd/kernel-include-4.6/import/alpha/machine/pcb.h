/* Copyright (C) 2002 Free Software Foundation, Inc.
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

/* $FreeBSD: src/sys/alpha/include/pcb.h,v 1.3 1999/08/28 00:38:48 peter Exp $ */
/* From: NetBSD: pcb.h,v 1.6 1997/04/06 08:47:33 cgd Exp */

/*
 * Copyright (c) 1994, 1995, 1996 Carnegie-Mellon University.
 * All rights reserved.
 *
 * Author: Chris G. Demetriou
 * 
 * Permission to use, copy, modify and distribute this software and
 * its documentation is hereby granted, provided that both the copyright
 * notice and this permission notice appear in all copies of the
 * software, derivative works or modified versions, and any portions
 * thereof, and that both notices appear in supporting documentation.
 * 
 * CARNEGIE MELLON ALLOWS FREE USE OF THIS SOFTWARE IN ITS "AS IS" 
 * CONDITION.  CARNEGIE MELLON DISCLAIMS ANY LIABILITY OF ANY KIND 
 * FOR ANY DAMAGES WHATSOEVER RESULTING FROM THE USE OF THIS SOFTWARE.
 * 
 * Carnegie Mellon requests users of this software to return to
 *
 *  Software Distribution Coordinator  or  Software.Distribution@CS.CMU.EDU
 *  School of Computer Science
 *  Carnegie Mellon University
 *  Pittsburgh PA 15213-3890
 *
 * any improvements or extensions that they make and grant Carnegie the
 * rights to redistribute these changes.
 */

#include <sys/types.h>

#include <machine/frame.h>
#include <machine/reg.h>

#include <machine/alpha_cpu.h>

/*
 * PCB: process control block
 *
 * In this case, the hardware structure that is the defining element
 * for a process, and the additional state that must be saved by software
 * on a context switch.  Fields marked [HW] are mandated by hardware; fields
 * marked [SW] are for the software.
 *
 * It's said in the VMS PALcode section of the AARM that the pcb address
 * passed to the swpctx PALcode call has to be a physical address.  Not
 * knowing this (and trying a virtual) address proved this correct.
 * So we cache the physical address of the pcb in the md_proc struct.
 */
struct pcb {
	struct alpha_pcb pcb_hw;		/* PALcode defined */
	unsigned long	pcb_context[9];		/* s[0-6], ra, ps	[SW] */
	struct fpreg	pcb_fp;			/* FP registers		[SW] */
	u_int64_t	pcb_fp_control;		/* IEEE control word	[SW] */
	unsigned long	pcb_onfault;		/* for copy faults	[SW] */
	unsigned long	pcb_accessaddr;		/* for [fs]uswintr	[SW] */
};

/*
 * The pcb is augmented with machine-dependent additional data for
 * core dumps. For the Alpha, that's a trap frame and the floating
 * point registers.
 */
struct md_coredump {
	struct	trapframe md_tf;
	struct	fpreg md_fpstate;
};
