/*
 * Copyright (c) 1991, 1993
 *	The Regents of the University of California.  All rights reserved.
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
 *	@(#)signalvar.h	8.6 (Berkeley) 2/19/95
 * $FreeBSD: src/sys/sys/signalvar.h,v 1.34.2.1 2000/05/16 06:58:05 dillon Exp $
 */

#ifndef	_SYS_SIGNALVAR_H_		/* tmp for user.h */
#define	_SYS_SIGNALVAR_H_

#include <sys/signal.h>
#include <sys/proc.h>
#include <machine/smp.h>

/*
 * Kernel signal definitions and data structures,
 * not exported to user programs.
 */

/*
 * Process signal actions and state, needed only within the process
 * (not necessarily resident).
 */
struct	sigacts {
	sig_t	ps_sigact[_SIG_MAXSIG];	/* disposition of signals */
	sigset_t ps_catchmask[_SIG_MAXSIG];	/* signals to be blocked */
	sigset_t ps_sigonstack;		/* signals to take on sigstack */
	sigset_t ps_sigintr;		/* signals that interrupt syscalls */
	sigset_t ps_sigreset;		/* signals that reset when caught */
	sigset_t ps_signodefer;		/* signals not masked while handled */
	sigset_t ps_siginfo;		/* signals that want SA_SIGINFO args */
	sigset_t ps_osigset;		/* signals that use osigset_t */
	sigset_t ps_usertramp;		/* SunOS compat; libc sigtramp XXX */
};

/*
 * Compatibility.
 */
typedef struct {
	struct osigcontext si_sc;
	int		si_signo;
	int		si_code;
	union sigval	si_value;
} osiginfo_t;

struct	osigaction {
	union {
		void    (*__sa_handler) __P((int));
		void    (*__sa_sigaction) __P((int, osiginfo_t *, void *));
	} __sigaction_u;		/* signal handler */
	osigset_t	sa_mask;	/* signal mask to apply */
	int		sa_flags;	/* see signal options below */
};

typedef void __osiginfohandler_t __P((int, osiginfo_t *, void *));

/* additional signal action values, used only temporarily/internally */
#define	SIG_CATCH	((__sighandler_t *)2)
#define SIG_HOLD        ((__sighandler_t *)3)

/*
 * get signal action for process and signal; currently only for current process
 */
#define SIGACTION(p, sig)	(p->p_sigacts->ps_sigact[_SIG_IDX(sig)])

/*
 * sigset_t manipulation macros
 */
#define SIGADDSET(set, signo)						\
	(set).__bits[_SIG_WORD(signo)] |= _SIG_BIT(signo)

#define SIGDELSET(set, signo)						\
	(set).__bits[_SIG_WORD(signo)] &= ~_SIG_BIT(signo)

#define SIGEMPTYSET(set)						\
	do {								\
		int __i;						\
		for (__i = 0; __i < _SIG_WORDS; __i++)			\
			(set).__bits[__i] = 0;				\
	} while (0)

#define SIGFILLSET(set)							\
	do {								\
		int __i;						\
		for (__i = 0; __i < _SIG_WORDS; __i++)			\
			(set).__bits[__i] = ~(unsigned int)0;		\
	} while (0)

#define SIGISMEMBER(set, signo)						\
	((set).__bits[_SIG_WORD(signo)] & _SIG_BIT(signo))

#define SIGISEMPTY(set)		__sigisempty(&(set))
#define SIGNOTEMPTY(set)	(!__sigisempty(&(set)))

#define SIGSETEQ(set1, set2)	__sigseteq(&(set1), &(set2))
#define SIGSETNEQ(set1, set2)	(!__sigseteq(&(set1), &(set2)))

#define SIGSETOR(set1, set2)						\
	do {								\
		int __i;						\
		for (__i = 0; __i < _SIG_WORDS; __i++)			\
			(set1).__bits[__i] |= (set2).__bits[__i];	\
	} while (0)

#define SIGSETAND(set1, set2)						\
	do {								\
		int __i;						\
		for (__i = 0; __i < _SIG_WORDS; __i++)			\
			(set1).__bits[__i] &= (set2).__bits[__i];	\
	} while (0)

#define SIGSETNAND(set1, set2)						\
	do {								\
		int __i;						\
		for (__i = 0; __i < _SIG_WORDS; __i++)			\
			(set1).__bits[__i] &= ~(set2).__bits[__i];	\
	} while (0)

#define SIGSETLO(set1, set2)	((set1).__bits[0] = (set2).__bits[0])
#define SIGSETOLD(set, oset)	((set).__bits[0] = (oset))

#define SIG_CANTMASK(set)						\
	SIGDELSET(set, SIGKILL), SIGDELSET(set, SIGSTOP)

#define SIG_STOPSIGMASK(set)						\
	SIGDELSET(set, SIGSTOP), SIGDELSET(set, SIGTSTP),		\
	SIGDELSET(set, SIGTTIN), SIGDELSET(set, SIGTTOU)

#define SIG_CONTSIGMASK(set)						\
	SIGDELSET(set, SIGCONT)

#define sigcantmask	(sigmask(SIGKILL) | sigmask(SIGSTOP))

#define SIG2OSIG(sig, osig)	osig = (sig).__bits[0]
#define OSIG2SIG(osig, sig)	SIGEMPTYSET(sig); (sig).__bits[0] = osig

static __inline int
__sigisempty(sigset_t *set)
{
	int i;

	for (i = 0; i < _SIG_WORDS; i++) {
		if (set->__bits[i])
			return (0);
	}
	return (1);
}

static __inline int
__sigseteq(sigset_t *set1, sigset_t *set2)
{
	int i;

	for (i = 0; i < _SIG_WORDS; i++) {
		if (set1->__bits[i] != set2->__bits[i])
			return (0);
	}
	return (1);
}

#ifdef _KERNEL

struct pgrp;
struct proc;
struct sigio;

extern int sugid_coredump;	/* Sysctl variable kern.sugid_coredump */

/*
 * Machine-independent functions:
 */
void	check_sigacts __P((void));
void	execsigs __P((struct proc *p));
void	gsignal __P((int pgid, int sig));
int	issignal __P((struct proc *p));
void	killproc __P((struct proc *p, char *why));
void	pgsigio __P((struct sigio *, int signum, int checkctty));
void	pgsignal __P((struct pgrp *pgrp, int sig, int checkctty));
void	postsig __P((int sig));
void	psignal __P((struct proc *p, int sig));
void	sigexit __P((struct proc *p, int signum));
void	siginit __P((struct proc *p));
void	trapsignal __P((struct proc *p, int sig, u_long code));
int	__cursig __P((struct proc *p));

/*
 * Machine-dependent functions:
 */
void	sendsig __P((sig_t action, int sig, sigset_t *retmask, u_long code));

/*
 * Inline functions:
 */
#define	CURSIG(p)	__cursig(p)

/*
 * Determine signal that should be delivered to process p, the current
 * process, 0 if none.  If there is a pending stop signal with default
 * action, the process stops in issignal().
 *
 * MP SAFE
 */
extern __inline int __cursig(struct proc *p)
{
	sigset_t tmpset;
	int r;

	tmpset = p->p_siglist;
	SIGSETNAND(tmpset, p->p_sigmask);
	if (SIGISEMPTY(p->p_siglist) ||
	     (!(p->p_flag & P_TRACED) && SIGISEMPTY(tmpset))) {
		return(0);
	}
	get_mplock();
	r = issignal(p);
	rel_mplock();
	return(r);
}

#endif	/* _KERNEL */

#endif	/* !_SYS_SIGNALVAR_H_ */
