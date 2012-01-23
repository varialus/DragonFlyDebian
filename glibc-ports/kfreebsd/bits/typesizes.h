/* bits/typesizes.h -- underlying types for *_t.  kFreeBSD version.
   Copyright (C) 2002, 2003, 2010, 2012 Free Software Foundation, Inc.
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

#ifndef _BITS_TYPES_H
# error "Never include <bits/typesizes.h> directly; use <sys/types.h> instead."
#endif

#ifndef	_BITS_TYPESIZES_H
#define	_BITS_TYPESIZES_H	1

/* See <bits/types.h> for the meaning of these macros.  This file exists so
   that <bits/types.h> need not vary across different GNU platforms.  */

#define __DEV_T_TYPE		__U32_TYPE
#define __UID_T_TYPE		__U32_TYPE
#define __GID_T_TYPE		__U32_TYPE
#define __INO_T_TYPE		__U32_TYPE
#define __INO64_T_TYPE		__UQUAD_TYPE
#define __MODE_T_TYPE		__U16_TYPE
#define __NLINK_T_TYPE		__U16_TYPE
#define __OFF_T_TYPE		__SQUAD_TYPE
#define __OFF64_T_TYPE		__SQUAD_TYPE
#define __PID_T_TYPE		__S32_TYPE
#define __RLIM_T_TYPE		__SQUAD_TYPE
#define __RLIM64_T_TYPE		__SQUAD_TYPE
#define	__BLKCNT_T_TYPE		__SQUAD_TYPE
#define	__BLKCNT64_T_TYPE	__SQUAD_TYPE
#define	__FSBLKCNT_T_TYPE	__ULONGWORD_TYPE
#define	__FSBLKCNT64_T_TYPE	__UQUAD_TYPE
#define	__FSFILCNT_T_TYPE	__ULONGWORD_TYPE
#define	__FSFILCNT64_T_TYPE	__UQUAD_TYPE
#define	__ID_T_TYPE		__U32_TYPE

#if defined(__arm__) || defined(__powerpc__)
#define __CLOCK_T_TYPE		__U32_TYPE
#elif defined(__i386__)
/* clock_t is unsigned in FreeBSD/i386, but it's too late to fix that now... */
#define __CLOCK_T_TYPE		__S32_TYPE
#else
#define __CLOCK_T_TYPE		__S32_TYPE
#endif

/*
 * This one is a bit tricky.  It needs to match the size
 * in the sys/${arch}/include/_types.h typedefs.
 *
 * However, for i386 and amd64 we started with __SLONGWORD_TYPE
 * and we need to maintain ABI.  Even if size is the same, using
 * a different type may affect C++ ABI (this distinction is
 * necessary to implement function overload), so it must stay
 * with __SLONGWORD_TYPE.
 */
#if defined(__i386__) || defined(__amd64__) || defined(__powerpc__)
#define __TIME_T_TYPE		__SLONGWORD_TYPE
#else
#define __TIME_T_TYPE		__S64_TYPE
#endif

#define __USECONDS_T_TYPE	__U32_TYPE
#define __SUSECONDS_T_TYPE	__SLONGWORD_TYPE
#define __DADDR_T_TYPE		__SQUAD_TYPE
#define __SWBLK_T_TYPE		__S32_TYPE
#define __KEY_T_TYPE		__SLONGWORD_TYPE
#define __CLOCKID_T_TYPE	__S32_TYPE
#define __TIMER_T_TYPE		__S32_TYPE
#define __BLKSIZE_T_TYPE	__U32_TYPE
#define __FSID_T_TYPE		union { int __val[2]; int val[2]; }
#define __SSIZE_T_TYPE		__SWORD_TYPE

/* Number of descriptors that can fit in an `fd_set'.  */
#define	__FD_SETSIZE		1024


#endif /* bits/typesizes.h */
