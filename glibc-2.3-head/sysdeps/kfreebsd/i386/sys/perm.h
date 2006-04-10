/* Copyright (C) 1996, 1999, 2002 Free Software Foundation, Inc.
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

#ifndef _SYS_PERM_H
#define _SYS_PERM_H	1

#include <features.h>

__BEGIN_DECLS

/* Set port input/output permissions.  */
extern int ioperm (unsigned long int __from, unsigned long int __num,
		   int __turn_on) __THROW;


/* Change I/O privilege level.  */
extern int iopl (int __level) __THROW;

extern int i386_set_ioperm (unsigned int __from, unsigned int __num,
			    int __turn_on) __THROW;

/* Retrieve a contiguous range of port input/output permissions.  */
extern int i386_get_ioperm (unsigned int __from, unsigned int *__num,
			    int *__turned_on) __THROW;

__END_DECLS

#endif	/* _SYS_PERM_H */
