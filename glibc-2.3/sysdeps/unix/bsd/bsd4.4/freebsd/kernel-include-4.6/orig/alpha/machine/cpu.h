/* $FreeBSD: src/sys/alpha/include/cpu.h,v 1.13.2.1 2000/05/24 14:20:58 gallatin Exp $ */
/* From: NetBSD: cpu.h,v 1.18 1997/09/23 23:17:49 mjacob Exp */

/*
 * Copyright (c) 1988 University of Utah.
 * Copyright (c) 1982, 1990, 1993
 *	The Regents of the University of California.  All rights reserved.
 *
 * This code is derived from software contributed to Berkeley by
 * the Systems Programming Group of the University of Utah Computer
 * Science Department.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *	This product includes software developed by the University of
 *	California, Berkeley and its contributors.
 * 4. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 * from: Utah $Hdr: cpu.h 1.16 91/03/25$
 *
 *	@(#)cpu.h	8.4 (Berkeley) 1/5/94
 */

#ifndef _ALPHA_CPU_H_
#define _ALPHA_CPU_H_

/*
 * Exported definitions unique to Alpha cpu support.
 */

#include <machine/frame.h>

/*
 * Arguments to hardclock and gatherstats encapsulate the previous
 * machine state in an opaque clockframe.  One the Alpha, we use
 * what we push on an interrupt (a trapframe).
 */
struct clockframe {
	struct trapframe	cf_tf;
};
#define	CLKF_USERMODE(framep)						\
	(((framep)->cf_tf.tf_regs[FRAME_PS] & ALPHA_PSL_USERMODE) != 0)
#define	CLKF_BASEPRI(framep)						\
	(((framep)->cf_tf.tf_regs[FRAME_PS] & ALPHA_PSL_IPL_MASK) == 0)
#define	CLKF_PC(framep)		((framep)->cf_tf.tf_regs[FRAME_PC])
#define	CLKF_INTR(framep)	(intr_nesting_level >= 2)

/*
 * Preempt the current process if in interrupt from user mode,
 * or after the current trap/syscall if in system mode.
 */
#define	need_resched()		do { want_resched = 1; aston(); } while (0)

#define	resched_wanted()	want_resched

/*
 * Give a profiling tick to the current process when the user profiling
 * buffer pages are invalid.  On the hp300, request an ast to send us
 * through trap, marking the proc as needing a profiling tick.
 */
#define	need_proftick(p) \
	do { (p)->p_flag |= P_OWEUPC; aston(); } while (0)

/*
 * Notify the current process (p) that it has a signal pending,
 * process as soon as possible.
 */
#define	signotify(p)	aston()

#define	aston()		(astpending = 1)

#ifdef _KERNEL
extern u_int32_t intr_nesting_level;	/* bookeeping only; counts software intr */
extern u_int32_t want_resched;		/* resched() was called */
#endif


/*
 * CTL_MACHDEP definitions.
 */
#define	CPU_CONSDEV		1	/* dev_t: console terminal device */
#define	CPU_ROOT_DEVICE		2	/* string: root device name */
#define	CPU_UNALIGNED_PRINT	3	/* int: print unaligned accesses */
#define	CPU_UNALIGNED_FIX	4	/* int: fix unaligned accesses */
#define	CPU_UNALIGNED_SIGBUS	5	/* int: SIGBUS unaligned accesses */
#define	CPU_BOOTED_KERNEL	6	/* string: booted kernel name */
#define	CPU_ADJKERNTZ		7	/* int:	timezone offset	(seconds) */
#define	CPU_DISRTCSET		8	/* int: disable resettodr() call */
#define	CPU_WALLCLOCK		9	/* int:	indicates wall CMOS clock */
#define	CPU_MAXID		9	/* 9 valid machdep IDs */

#define	CTL_MACHDEP_NAMES { \
	{ 0, 0 }, \
	{ "console_device", CTLTYPE_STRUCT }, \
	{ "root_device", CTLTYPE_STRING }, \
	{ "unaligned_print", CTLTYPE_INT }, \
	{ "unaligned_fix", CTLTYPE_INT }, \
	{ "unaligned_sigbus", CTLTYPE_INT }, \
	{ "booted_kernel", CTLTYPE_STRING }, \
	{ "adjkerntz", CTLTYPE_INT }, \
	{ "disable_rtc_set", CTLTYPE_INT }, \
	{ "wall_cmos_clock", CTLTYPE_INT }, \
}

#ifdef _KERNEL

struct pcb;
struct proc;
struct reg;
struct rpb;
struct trapframe;

extern struct proc *fpcurproc;
extern struct rpb *hwrpb;
extern volatile int mc_expected, mc_received;

void	XentArith __P((u_int64_t, u_int64_t, u_int64_t));	/* MAGIC */
void	XentIF __P((u_int64_t, u_int64_t, u_int64_t));		/* MAGIC */
void	XentInt __P((u_int64_t, u_int64_t, u_int64_t));		/* MAGIC */
void	XentMM __P((u_int64_t, u_int64_t, u_int64_t));		/* MAGIC */
void	XentRestart __P((void));				/* MAGIC */
void	XentSys __P((u_int64_t, u_int64_t, u_int64_t));		/* MAGIC */
void	XentUna __P((u_int64_t, u_int64_t, u_int64_t));		/* MAGIC */
void	alpha_init __P((u_long, u_long, u_long, u_long, u_long));
int	alpha_pa_access __P((u_long));
void	alpha_fpstate_check __P((struct proc *p));
void	alpha_fpstate_save __P((struct proc *p, int write));
void	alpha_fpstate_drop __P((struct proc *p));
void	alpha_fpstate_switch __P((struct proc *p));
void	ast __P((struct trapframe *));
int	badaddr	__P((void *, size_t));
int	badaddr_read __P((void *, size_t, void *));
void	child_return __P((struct proc *p));
u_int64_t console_restart __P((u_int64_t, u_int64_t, u_int64_t));
void	do_sir __P((void));
void	dumpconf __P((void));
void	exception_return __P((void));				/* MAGIC */
void	frametoreg __P((struct trapframe *, struct reg *));
long	fswintrberr __P((void));				/* MAGIC */
void	init_prom_interface __P((struct rpb*));
void	interrupt
	__P((unsigned long, unsigned long, unsigned long, struct trapframe *));
void	machine_check
	__P((unsigned long, struct trapframe *, unsigned long, unsigned long));
u_int64_t hwrpb_checksum __P((void));
void	hwrpb_restart_setup __P((void));
void	regdump __P((struct trapframe *));
void	regtoframe __P((struct reg *, struct trapframe *));
void	savectx __P((struct pcb *));
void	set_iointr __P((void (*)(void *, unsigned long)));
void    switch_exit __P((struct proc *));			/* MAGIC */
void	switch_trampoline __P((void));				/* MAGIC */
void	syscall __P((u_int64_t, struct trapframe *));
void	trap __P((unsigned long, unsigned long, unsigned long, unsigned long,
	    struct trapframe *));

#endif /* _KERNEL */

#endif /* _ALPHA_CPU_H_ */
