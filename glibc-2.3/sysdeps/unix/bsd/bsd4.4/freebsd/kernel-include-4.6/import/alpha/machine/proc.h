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

/* $FreeBSD: src/sys/alpha/include/proc.h,v 1.7.2.1 2000/08/03 21:10:58 peter Exp $ */
/* From: NetBSD: proc.h,v 1.3 1997/04/06 08:47:36 cgd Exp */

/*
 * Copyright (c) 1994, 1995 Carnegie-Mellon University.
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

#ifndef _MACHINE_PROC_H_
#define	_MACHINE_PROC_H_

#include <sys/types.h>
#include <machine/types.h>

/*
 * Machine-dependent part of the proc struct for the Alpha.
 */

struct mdbpt {
	vm_offset_t	addr;
	u_int32_t	contents;
};

struct mdproc {
	u_long		md_flags;
	struct	trapframe *md_tf;	/* trap/syscall registers */
	struct pcb	*md_pcbpaddr;	/* phys addr of the pcb */
	struct mdbpt	md_sstep[2];	/* two single step breakpoints */
	u_int64_t	md_hae;		/* user HAE register value */
	void            *osf_sigtramp;  /* user-level signal trampoline */
};

#define	MDP_FPUSED	0x0001		/* Process used the FPU */
#define MDP_STEP1	0x0002		/* Single step normal instruction */
#define MDP_STEP2	0x0004		/* Single step branch instruction */
#define MDP_HAEUSED	0x0008		/* Process used the HAE */
#define MDP_UAC_NOPRINT	0x0010		/* Don't print unaligned traps */
#define MDP_UAC_NOFIX	0x0020		/* Don't fixup unaligned traps */
#define MDP_UAC_SIGBUS	0x0040		/* Deliver SIGBUS upon
					   unaligned access */
#define MDP_UAC_MASK	(MDP_UAC_NOPRINT | MDP_UAC_NOFIX | MDP_UAC_SIGBUS)

#endif /* !_MACHINE_PROC_H_ */
