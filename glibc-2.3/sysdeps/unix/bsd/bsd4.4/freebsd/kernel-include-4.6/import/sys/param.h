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

/*-
 * Copyright (c) 1982, 1986, 1989, 1993
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
 *	@(#)param.h	8.3 (Berkeley) 4/4/95
 * $FreeBSD: src/sys/sys/param.h,v 1.61.2.31 2002/06/26 16:49:28 obrien Exp $
 */

#ifndef _SYS_PARAM_H
#define _SYS_PARAM_H	1

#define BSD 199506			/* System version (year & month). */
#define BSD4_3	1
#define BSD4_4	1

/* 
 * __FreeBSD_version numbers are documented in the Porter's Handbook.
 * If you bump the version for any reason, you should update the documentation
 * there.
 * Currently this lives here:
 *	doc/en_US.ISO8859-1/books/porters-handbook/book.sgml
 */
#undef __FreeBSD_version
#define __FreeBSD_version 460101	/* Master, propagated to newvers */

/* Some inet code expects that this file defines the 'u_int32_t' type.  */
#include <sys/types.h>

#include <limits.h>

#define MAXCOMLEN	16		/* max command name remembered */
#define MAXINTERP	32		/* max interpreter file name length */
#define MAXLOGNAME	17		/* max login name length (incl. NUL) */
#define MAXUPRC		CHILD_MAX	/* max simultaneous processes */
#define NCARGS		ARG_MAX		/* max bytes for an exec function */
#define NGROUPS		NGROUPS_MAX	/* max number groups */
#define NOFILE		OPEN_MAX	/* max open files per process */
#define NOGROUP		65535		/* marker for empty group set member */
#define MAXHOSTNAMELEN	256		/* max hostname size */

#include <machine/param.h>

/*
 * Priorities.  Note that with 32 run queues, differences less than 4 are
 * insignificant.
 */
#define PSWP	0
#define PVM	4
#define PINOD	8
#define PRIBIO	16
#define PVFS	20
#define PZERO	22		/* No longer magic, shouldn't be here.  XXX */
#define PSOCK	24
#define PWAIT	32
#define PCONFIG	32
#define PLOCK	36
#define PPAUSE	40
#define PUSER	50
#define MAXPRI	127		/* Priorities range from 0 through MAXPRI. */

#define PRIMASK	0x0ff
#define PCATCH	0x100		/* OR'd with pri for tsleep to check signals */

#define NBPW	sizeof(int)	/* number of bytes per word (integer) */

#define CMASK	022		/* default file mask: S_IWGRP|S_IWOTH */

#define NODEV	(dev_t)(-1)	/* non-existent device */

/*
 * File system parameters and macros.
 *
 * MAXBSIZE -	Filesystems are made out of blocks of at most MAXBSIZE bytes
 *		per block.  MAXBSIZE may be made larger without effecting
 *		any existing filesystems as long as it does not exceed MAXPHYS,
 *		and may be made smaller at the risk of not being able to use
 *		filesystems which require a block size exceeding MAXBSIZE.
 *
 * BKVASIZE -	Nominal buffer space per buffer, in bytes.  BKVASIZE is the
 *		minimum KVM memory reservation the kernel is willing to make.
 *		Filesystems can of course request smaller chunks.  Actual 
 *		backing memory uses a chunk size of a page (PAGE_SIZE).
 *
 *		If you make BKVASIZE too small you risk seriously fragmenting
 *		the buffer KVM map which may slow things down a bit.  If you
 *		make it too big the kernel will not be able to optimally use 
 *		the KVM memory reserved for the buffer cache and will wind 
 *		up with too-few buffers.
 *
 *		The default is 16384, roughly 2x the block size used by a
 *		normal UFS filesystem.
 */
#define MAXBSIZE	65536	/* must be power of 2 */
#define BKVASIZE	16384	/* must be power of 2 */
#define BKVAMASK	(BKVASIZE-1)
#define MAXFRAG 	8

/*
 * MAXPATHLEN defines the longest permissible path length after expanding
 * symbolic links. It is used to allocate a temporary buffer from the buffer
 * pool in which to do the name expansion, hence should be a power of two,
 * and must be less than or equal to MAXBSIZE.  MAXSYMLINKS defines the
 * maximum number of symbolic links that may be expanded in a path name.
 * It should be set high enough to allow all legitimate uses, but halt
 * infinite loops reasonably quickly.
 */
#define MAXPATHLEN	PATH_MAX
#define MAXSYMLINKS	32

/* Bit map related macros. */
#define setbit(a,i)	((a)[(i)/NBBY] |= 1<<((i)%NBBY))
#define clrbit(a,i)	((a)[(i)/NBBY] &= ~(1<<((i)%NBBY)))
#define isset(a,i)	((a)[(i)/NBBY] & (1<<((i)%NBBY)))
#define isclr(a,i)	(((a)[(i)/NBBY] & (1<<((i)%NBBY))) == 0)

/* Macros for counting and rounding. */
#ifndef howmany
#define howmany(x, y)	(((x)+((y)-1))/(y))
#endif
#define rounddown(x, y)	(((x)/(y))*(y))
#define roundup(x, y)	((((x)+((y)-1))/(y))*(y))  /* to any y */
#define roundup2(x, y)	(((x)+((y)-1))&(~((y)-1))) /* if y is powers of two */
#define powerof2(x)	((((x)-1)&(x))==0)

/* Macros for min/max. */
#define MIN(a,b) (((a)<(b))?(a):(b))
#define MAX(a,b) (((a)>(b))?(a):(b))

/*
 * Scale factor for scaled integers used to count %cpu time and load avgs.
 *
 * The number of CPU `tick's that map to a unique `%age' can be expressed
 * by the formula (1 / (2 ^ (FSHIFT - 11))).  The maximum load average that
 * can be calculated (assuming 32 bits) can be closely approximated using
 * the formula (2 ^ (2 * (16 - FSHIFT))) for (FSHIFT < 15).
 *
 * For the scheduler to maintain a 1:1 mapping of CPU `tick' to `%age',
 * FSHIFT must be at least 11; this gives us a maximum load avg of ~1024.
 */
#define FSHIFT	11		/* bits to right of fixed binary point */
#define FSCALE	(1<<FSHIFT)

#define dbtoc(db)			/* calculates devblks to pages */ \
	((db + (ctodb(1) - 1)) >> (PAGE_SHIFT - DEV_BSHIFT))
 
#define ctodb(db)			/* calculates pages to devblks */ \
	((db) << (PAGE_SHIFT - DEV_BSHIFT))

#endif	/* _SYS_PARAM_H */
