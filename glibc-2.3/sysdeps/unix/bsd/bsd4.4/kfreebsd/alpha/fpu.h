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

#ifndef _FPU_H
#define _FPU_H	1


/* Usage of the fpcr register.
   The rounding mode bits (in FPCR_DYN_MASK) can be modified in user mode
   and will be preserved by the kernel when a software assisted floating-
   point operation or an exception occurs.  All other bits will be set by
   the kernel when a software assisted floating-point operation or an
   exception occurs.  */

#if 0 /* Only Linux, not FreeBSD */
#define FPCR_DNOD	(1UL<<47)	/* denorm INV trap disable */
#define FPCR_DNZ	(1UL<<48)	/* denorms to zero */
#endif
#define FPCR_INVD	(1UL<<49)	/* invalid op disable (opt.) */
#define FPCR_DZED	(1UL<<50)	/* division by zero disable (opt.) */
#define FPCR_OVFD	(1UL<<51)	/* overflow disable (optional) */
#define FPCR_INV	(1UL<<52)	/* invalid operation */
#define FPCR_DZE	(1UL<<53)	/* division by zero */
#define FPCR_OVF	(1UL<<54)	/* overflow */
#define FPCR_UNF	(1UL<<55)	/* underflow */
#define FPCR_INE	(1UL<<56)	/* inexact */
#define FPCR_IOV	(1UL<<57)	/* integer overflow */
#define FPCR_UNDZ	(1UL<<60)	/* underflow to zero (opt.) */
#define FPCR_UNFD	(1UL<<61)	/* underflow disable (opt.) */
#define FPCR_INED	(1UL<<62)	/* inexact disable (opt.) */
#define FPCR_SUM	(1UL<<63)	/* summary bit, an OR of bits 52..56 */

#define FPCR_DYN_SHIFT	58		/* first dynamic rounding mode bit */
#define FPCR_DYN_CHOPPED (0x0UL << FPCR_DYN_SHIFT)	/* towards 0 */
#define FPCR_DYN_MINUS	 (0x1UL << FPCR_DYN_SHIFT)	/* towards -INF */
#define FPCR_DYN_NORMAL	 (0x2UL << FPCR_DYN_SHIFT)	/* towards nearest */
#define FPCR_DYN_PLUS	 (0x3UL << FPCR_DYN_SHIFT)	/* towards +INF */
#define FPCR_DYN_MASK	 (0x3UL << FPCR_DYN_SHIFT)

#define FPCR_MASK	0xffff800000000000


/* IEEE traps are enabled depending on a control word (not to be confused
   with fpcr!) which can be read using __ieee_get_fp_control() and written
   using __ieee_set_fp_control().  The bits in these control word are
   as follows (compatible with Linux and OSF/1).  */

/* Trap enable bits.  Get copied (inverted) to bits 49,50,51,61,62,47
   of fpcr in the kernel.  */
#define IEEE_TRAP_ENABLE_INV	(1UL<<1)	/* invalid op */
#define IEEE_TRAP_ENABLE_DZE	(1UL<<2)	/* division by zero */
#define IEEE_TRAP_ENABLE_OVF	(1UL<<3)	/* overflow */
#define IEEE_TRAP_ENABLE_UNF	(1UL<<4)	/* underflow */
#define IEEE_TRAP_ENABLE_INE	(1UL<<5)	/* inexact */
#if 0 /* Only Linux, not FreeBSD */
#define IEEE_TRAP_ENABLE_DNO	(1UL<<6)	/* denorm */
#endif
#define IEEE_TRAP_ENABLE_MASK	(IEEE_TRAP_ENABLE_INV | IEEE_TRAP_ENABLE_DZE |\
				 IEEE_TRAP_ENABLE_OVF | IEEE_TRAP_ENABLE_UNF |\
				 IEEE_TRAP_ENABLE_INE/*| IEEE_TRAP_ENABLE_DNO*/)

#if 0 /* Only Linux, not FreeBSD */

/* Denorm and Underflow flushing. */
/* Get copied to bits 48,60 of fpcr in the kernel.  */
#define IEEE_MAP_DMZ		(1UL<<12)	/* Map denorm inputs to zero */
#define IEEE_MAP_UMZ		(1UL<<13)	/* Map underflowed outputs to zero */

#define IEEE_MAP_MASK		(IEEE_MAP_DMZ | IEEE_MAP_UMZ)

#endif

/* Status bits.  Get copied to bits 52,53,54,55,56 of fpcr in the kernel.  */
#define IEEE_STATUS_INV		(1UL<<17)	/* invalid op */
#define IEEE_STATUS_DZE		(1UL<<18)	/* division by zero */
#define IEEE_STATUS_OVF		(1UL<<19)	/* overflow */
#define IEEE_STATUS_UNF		(1UL<<20)	/* underflow */
#define IEEE_STATUS_INE		(1UL<<21)	/* inexact */
#if 0 /* Only Linux, not FreeBSD */
#define IEEE_STATUS_DNO		(1UL<<22)	/* denorm */
#endif

#define IEEE_STATUS_MASK	(IEEE_STATUS_INV | IEEE_STATUS_DZE |	\
				 IEEE_STATUS_OVF | IEEE_STATUS_UNF |	\
				 IEEE_STATUS_INE /* | IEEE_STATUS_DNO */)

#define IEEE_SW_MASK		(IEEE_TRAP_ENABLE_MASK |		\
				 IEEE_STATUS_MASK /* | IEEE_MAP_MASK */)

#if 0 /* Only Linux, not FreeBSD */

#define IEEE_CURRENT_RM_SHIFT	32
#define IEEE_CURRENT_RM_MASK	(3UL<<IEEE_CURRENT_RM_SHIFT)

#endif

#define IEEE_INHERIT    (1UL<<63)	/* inherit on thread create? */


#if 0 /* Unused.  */

/* Exception summary bits.  */
#define EXCSUM_SWC	(1LL << 0)	/* Software completion */
#define EXCSUM_INV	(1LL << 1)	/* Invalid operation */
#define EXCSUM_DZE	(1LL << 2)	/* Division by zero */
#define EXCSUM_OVF	(1LL << 3)	/* Overflow */
#define EXCSUM_UNF	(1LL << 4)	/* Underflow */
#define EXCSUM_INE	(1LL << 5)	/* Inexact result */
#define EXCSUM_IOV	(1LL << 6)	/* Integer overflow */

#endif

#endif /* _FPU_H */
