/* Header file for manipulating realtime priority.  FreeBSD version.
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

/*
 * Copyright (c) 1994, Henrik Vestergaard Draboel
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
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *	This product includes software developed by (name).
 * 4. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 * $FreeBSD: src/sys/sys/rtprio.h,v 1.9 1999/12/29 04:24:46 peter Exp $
 */

#ifndef _SYS_RTPRIO_H_
#define _SYS_RTPRIO_H_

#include <features.h>

#include <sys/types.h>

/*
 * Process realtime-priority specifications to rtprio.
 */

/* priority types */

#define RTP_PRIO_REALTIME	0
#define RTP_PRIO_NORMAL		1
#define RTP_PRIO_IDLE		2

/* RTP_PRIO_FIFO is POSIX.1B SCHED_FIFO.
 */

#define RTP_PRIO_FIFO_BIT	4
#define RTP_PRIO_FIFO		(RTP_PRIO_REALTIME | RTP_PRIO_FIFO_BIT)
#define RTP_PRIO_BASE(P)	((P) & ~RTP_PRIO_FIFO_BIT)
#define RTP_PRIO_IS_REALTIME(P) (RTP_PRIO_BASE(P) == RTP_PRIO_REALTIME)
#define RTP_PRIO_NEED_RR(P)	((P) != RTP_PRIO_FIFO)

/* priority range */
#define RTP_PRIO_MIN		0	/* Highest priority */
#define RTP_PRIO_MAX		31	/* Lowest priority */

/*
 * rtprio() syscall functions
 */
#define RTP_LOOKUP		0
#define RTP_SET			1

struct rtprio {
	u_short type;
	u_short prio;
};

__BEGIN_DECLS

extern int rtprio (int __function, __pid_t __pid, struct rtprio *__rtp)
     __THROW;

#ifdef _LIBC
extern int __rtprio (int __function, __pid_t __pid, struct rtprio *__rtp);
#endif

__END_DECLS

#endif	/* !_SYS_RTPRIO_H_ */
