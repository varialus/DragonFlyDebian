/*
 * Copyright (c) 1982, 1986, 1989, 1991, 1993
 *	The Regents of the University of California.  All rights reserved.
 * (c) UNIX System Laboratories, Inc.
 * All or some portions of this file are derived from material licensed
 * to the University of California by American Telephone and Telegraph
 * Co. or Unix System Laboratories, Inc. and are reproduced herein with
 * the permission of UNIX System Laboratories, Inc.
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
 *	@(#)signal.h	8.4 (Berkeley) 5/4/95
 * $FreeBSD: src/sys/sys/signal.h,v 1.23.2.2 2001/04/19 01:38:35 alfred Exp $
 */

#ifndef	_SYS_SIGNAL_H_
#define	_SYS_SIGNAL_H_

#include <sys/cdefs.h>
#include <sys/_posix.h>

/*
 * sigset_t macros.
 */
#define	_SIG_WORDS	4
#define	_SIG_MAXSIG	128
#define	_SIG_IDX(sig)	((sig) - 1)
#define	_SIG_WORD(sig)	(_SIG_IDX(sig) >> 5)
#define	_SIG_BIT(sig)	(1 << (_SIG_IDX(sig) & 31))
#define	_SIG_VALID(sig)	((sig) < _SIG_MAXSIG && (sig) > 0)

/*
 * System defined signals.
 */
#define	SIGHUP		1	/* hangup */
#define	SIGINT		2	/* interrupt */
#define	SIGQUIT		3	/* quit */
#define	SIGILL		4	/* illegal instr. (not reset when caught) */
#ifndef _POSIX_SOURCE
#define	SIGTRAP		5	/* trace trap (not reset when caught) */
#endif
#define	SIGABRT		6	/* abort() */
#ifndef _POSIX_SOURCE
#define	SIGIOT		SIGABRT	/* compatibility */
#define	SIGEMT		7	/* EMT instruction */
#endif
#define	SIGFPE		8	/* floating point exception */
#define	SIGKILL		9	/* kill (cannot be caught or ignored) */
#ifndef _POSIX_SOURCE
#define	SIGBUS		10	/* bus error */
#endif
#define	SIGSEGV		11	/* segmentation violation */
#ifndef _POSIX_SOURCE
#define	SIGSYS		12	/* non-existent system call invoked */
#endif
#define	SIGPIPE		13	/* write on a pipe with no one to read it */
#define	SIGALRM		14	/* alarm clock */
#define	SIGTERM		15	/* software termination signal from kill */
#ifndef _POSIX_SOURCE
#define	SIGURG		16	/* urgent condition on IO channel */
#endif
#define	SIGSTOP		17	/* sendable stop signal not from tty */
#define	SIGTSTP		18	/* stop signal from tty */
#define	SIGCONT		19	/* continue a stopped process */
#define	SIGCHLD		20	/* to parent on child stop or exit */
#define	SIGTTIN		21	/* to readers pgrp upon background tty read */
#define	SIGTTOU		22	/* like TTIN if (tp->t_local&LTOSTOP) */
#ifndef _POSIX_SOURCE
#define	SIGIO		23	/* input/output possible signal */
#define	SIGXCPU		24	/* exceeded CPU time limit */
#define	SIGXFSZ		25	/* exceeded file size limit */
#define	SIGVTALRM	26	/* virtual time alarm */
#define	SIGPROF		27	/* profiling time alarm */
#define	SIGWINCH	28	/* window size changes */
#define	SIGINFO		29	/* information request */
#endif
#define	SIGUSR1		30	/* user defined signal 1 */
#define	SIGUSR2		31	/* user defined signal 2 */

/*-
 * Type of a signal handling function.
 *
 * Language spec sez signal handlers take exactly one arg, even though we
 * actually supply three.  Ugh!
 *
 * We don't try to hide the difference by leaving out the args because
 * that would cause warnings about conformant programs.  Nonconformant
 * programs can avoid the warnings by casting to (__sighandler_t *) or
 * sig_t before calling signal() or assigning to sa_handler or sv_handler.
 *
 * The kernel should reverse the cast before calling the function.  It
 * has no way to do this, but on most machines 1-arg and 3-arg functions
 * have the same calling protocol so there is no problem in practice.
 * A bit in sa_flags could be used to specify the number of args.
 */
typedef void __sighandler_t __P((int));

#define	SIG_DFL		((__sighandler_t *)0)
#define	SIG_IGN		((__sighandler_t *)1)
#define	SIG_ERR		((__sighandler_t *)-1)

#if defined(_P1003_1B_VISIBLE) || defined(_KERNEL)
union sigval {
	/* Members as suggested by Annex C of POSIX 1003.1b. */
	int	sigval_int;
	void	*sigval_ptr;
};

struct sigevent {
	int	sigev_notify;		/* Notification type */
	union {
		int	__sigev_signo;	/* Signal number */
		int	__sigev_notify_kqueue;
	} __sigev_u;
	union sigval sigev_value;	/* Signal value */
};
#define sigev_signo		__sigev_u.__sigev_signo
#define sigev_notify_kqueue	__sigev_u.__sigev_notify_kqueue

#define	SIGEV_NONE	0		/* No async notification */
#define	SIGEV_SIGNAL	1		/* Generate a queued signal */
#define SIGEV_KEVENT	3		/* Generate a kevent */

typedef struct __siginfo {
	int	si_signo;		/* signal number */
	int	si_errno;		/* errno association */
	/*
	 * Cause of signal, one of the SI_ macros or signal-specific
	 * values, i.e. one of the FPE_... values for SIGFPE. This
	 * value is equivalent to the second argument to an old-style
	 * FreeBSD signal handler.
	 */
	int	si_code;		/* signal code */
	int	si_pid;			/* sending process */
	unsigned int si_uid;		/* sender's ruid */
	int	si_status;		/* exit value */
	void	*si_addr;		/* faulting instruction */
	union sigval si_value;		/* signal value */
	long	si_band;		/* band event for SIGPOLL */
	int	__spare__[7];		/* gimme some slack */
} siginfo_t;
#endif /* _P1003_1B_VISIBLE */

typedef struct __sigset {
	unsigned int	__bits[_SIG_WORDS];
} sigset_t;

/*
 * XXX - there are some nasty dependencies on include file order. Now that
 * sigset_t has been defined we can include the MD header.
 */     
#include <machine/signal.h>     /* sig_atomic_t; trap codes; sigcontext */

#if !defined(_ANSI_SOURCE)

struct __siginfo;

/*
 * Signal vector "template" used in sigaction call.
 */
struct	sigaction {
	union {
		void    (*__sa_handler) __P((int));
		void    (*__sa_sigaction) __P((int, struct __siginfo *,
					       void *));
	} __sigaction_u;		/* signal handler */
	int	sa_flags;		/* see signal options below */
	sigset_t sa_mask;		/* signal mask to apply */
};

/* if SA_SIGINFO is set, sa_sigaction is to be used instead of sa_handler. */
#define	sa_handler	__sigaction_u.__sa_handler

#define SA_NOCLDSTOP	0x0008	/* do not generate SIGCHLD on child stop */

#if !defined(_POSIX_SOURCE)

#define	sa_sigaction	__sigaction_u.__sa_sigaction

#define SA_ONSTACK	0x0001	/* take signal on signal stack */
#define SA_RESTART	0x0002	/* restart system call on signal return */
#define	SA_RESETHAND	0x0004	/* reset to SIG_DFL when taking signal */
#define	SA_NODEFER	0x0010	/* don't mask the signal we're delivering */
#define	SA_NOCLDWAIT	0x0020	/* don't keep zombies around */
#define	SA_SIGINFO	0x0040	/* signal handler with SA_SIGINFO args */
#ifdef COMPAT_SUNOS
#define	SA_USERTRAMP	0x0100	/* do not bounce off kernel's sigtramp */
#endif

#define NSIG		32	/* number of old signals (counting 0) */

/* POSIX 1003.1b required values. */
#define SI_USER		0x10001
#define SI_QUEUE	0x10002
#define SI_TIMER	0x10003
#define SI_ASYNCIO	0x10004
#define SI_MESGQ	0x10005

/* Additional FreeBSD values. */
#define SI_UNDEFINED	0

typedef void __siginfohandler_t __P((int, struct __siginfo *, void *));

typedef	__sighandler_t	*sig_t;	/* type of pointer to a signal function */

#ifdef	_BSD_SIZE_T_
typedef	_BSD_SIZE_T_	size_t;
#undef	_BSD_SIZE_T_
#endif

/*
 * Structure used in sigaltstack call.
 */
typedef struct sigaltstack {
	char	*ss_sp;			/* signal stack base */
	size_t	ss_size;		/* signal stack length */
	int	ss_flags;		/* SS_DISABLE and/or SS_ONSTACK */
} stack_t;

#define	SS_ONSTACK	0x0001	/* take signal on alternate stack */
#define	SS_DISABLE	0x0004	/* disable taking signals on alternate stack */
#define	MINSIGSTKSZ	8192			/* minimum allowable stack */
#define	SIGSTKSZ	(MINSIGSTKSZ + 32768)	/* recommended stack size */

/* Have enough typedefs for this now.  XXX */
#include <sys/ucontext.h>

/*
 * 4.3 compatibility:
 * Signal vector "template" used in sigvec call.
 */
struct	sigvec {
	__sighandler_t *sv_handler;	/* signal handler */
	int	sv_mask;		/* signal mask to apply */
	int	sv_flags;		/* see signal options below */
};

#define SV_ONSTACK	SA_ONSTACK
#define SV_INTERRUPT	SA_RESTART	/* same bit, opposite sense */
#define SV_RESETHAND	SA_RESETHAND
#define SV_NODEFER	SA_NODEFER
#define SV_NOCLDSTOP	SA_NOCLDSTOP
#define SV_SIGINFO	SA_SIGINFO
#define sv_onstack sv_flags	/* isn't compatibility wonderful! */

/*
 * Structure used in sigstack call.
 */
struct	sigstack {
	char	*ss_sp;			/* signal stack pointer */
	int	ss_onstack;		/* current status */
};

/*
 * Macro for converting signal number to a mask suitable for
 * sigblock().
 */
#define sigmask(m)	(1 << ((m)-1))

#define	BADSIG		SIG_ERR

#endif /* !_POSIX_SOURCE */

/*
 * Flags for sigprocmask:
 */
#define	SIG_BLOCK	1	/* block specified signal set */
#define	SIG_UNBLOCK	2	/* unblock specified signal set */
#define	SIG_SETMASK	3	/* set specified signal set */

#endif /* !_ANSI_SOURCE */

/*
 * For historical reasons; programs expect signal's return value to be
 * defined by <sys/signal.h>.
 */
__BEGIN_DECLS
__sighandler_t *signal __P((int, __sighandler_t *));
__END_DECLS

#endif	/* !_SYS_SIGNAL_H_ */
