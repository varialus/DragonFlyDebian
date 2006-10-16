/*-
 * Copyright (c) 1982, 1986, 1990 The Regents of the University of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
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
 *	@(#)ioctl.h	8.6 (Berkeley) 3/28/94
 */

#ifndef	_IOCTLS_H_
#define	_IOCTLS_H_

#include <sys/ioccom.h>

#include <sys/ttycom.h>

/*
 *	@(#)ioctl.h	8.6 (Berkeley) 3/28/94
 */

#define	TIOCGSIZE	TIOCGWINSZ
#define	TIOCSSIZE	TIOCSWINSZ

#include <sys/filio.h>

#include <sys/sockio.h>

#ifndef _SYS_IOCTL_COMPAT_H_
#ifndef BURN_BRIDGES

#undef		ECHO				/* see bits/termios.h */
#undef		MDMBUF				/* see bits/termios.h */
#undef		TOSTOP				/* see bits/termios.h */
#undef		FLUSHO				/* see bits/termios.h */
#undef		PENDIN				/* see bits/termios.h */
#undef		NOFLSH				/* see bits/termios.h */

#include <sys/ioctl_compat.h>

#define		TAB3 XTABS			/* expand tabs on output */

#endif /* !BURN_BRIDGES */
#endif /* !_SYS_IOCTL_COMPAT_H_ */

#endif /* !_IOCTLS_H_ */
