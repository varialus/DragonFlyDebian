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

/*
 * ----------------------------------------------------------------------------
 * "THE BEER-WARE LICENSE" (Revision 42):
 * <phk@FreeBSD.org> wrote this file.  As long as you retain this notice you
 * can do whatever you want with this stuff. If we meet some day, and you think
 * this stuff is worth it, you can buy me a beer in return.   Poul-Henning Kamp
 * ----------------------------------------------------------------------------
 *
 * $FreeBSD: src/sys/sys/xrpuio.h,v 1.2 1999/08/28 00:52:12 peter Exp $
 *
 */

#ifndef _SYS_XRPUIO_H_
#define _SYS_XRPUIO_H_

#include <sys/types.h>
#include <sys/ioccom.h>

#define XRPU_MAX_PPS	16
struct xrpu_timecounting {

	/* The timecounter itself */
	u_int		xt_addr_trigger;
	u_int		xt_addr_latch;
	unsigned	xt_mask;
	u_int32_t	xt_frequency;
	char		xt_name[16];

	/* The PPS latches */
	struct {
		u_int	xt_addr_assert;
		u_int	xt_addr_clear;
	} xt_pps[XRPU_MAX_PPS];
};

#define XRPU_IOC_TIMECOUNTING _IOW('6', 1, struct xrpu_timecounting)

#endif /* _SYS_XRPUIO_H_ */
