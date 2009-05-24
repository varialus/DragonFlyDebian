/* Set flags signalling availability of kernel features based on given
   kernel version number.
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

#ifndef __KFREEBSD_KERNEL_VERSION
/* We assume the worst; all kernels should be supported.  */
# define __KFREEBSD_KERNEL_VERSION	0
#endif

/* The encoding for __KFREEBSD_KERNEL_VERSION is defined the following
   way: the major, minor, and subminor all get a byte with the major
   number being in the highest byte.  This means we can do numeric
   comparisons.

   In the following we will define certain symbols depending on
   whether the describes kernel feature is available in the kernel
   version given by __KFREEBSD_KERNEL_VERSION.  We are not always exactly
   recording the correct versions in which the features were
   introduced.  If somebody cares these values can afterwards be
   corrected.  */

/* No real-time signals in FreeBSD 5.x or 6.x.  */
#define __ASSUME_REALTIME_SIGNALS	0

/* Use signals #32, #33, #34 for internal linuxthreads communication */
#define PTHREAD_SIGBASE 32

