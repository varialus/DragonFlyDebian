/* Header file for jail.  FreeBSD version.
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
 * ----------------------------------------------------------------------------
 * "THE BEER-WARE LICENSE" (Revision 42):
 * <phk@FreeBSD.org> wrote this file.  As long as you retain this notice you
 * can do whatever you want with this stuff. If we meet some day, and you think
 * this stuff is worth it, you can buy me a beer in return.   Poul-Henning Kamp
 * ----------------------------------------------------------------------------
 *
 * $FreeBSD: src/sys/sys/jail.h,v 1.8.2.2 2000/11/01 17:58:06 rwatson Exp $
 *
 */

#ifndef _SYS_JAIL_H_
#define _SYS_JAIL_H_

#include <features.h>

#include <sys/types.h>

struct jail {
	u_int32_t	version;
	char		*path;
	char		*hostname;
	u_int32_t	ip_number;
};

#ifndef _KERNEL

__BEGIN_DECLS

extern int jail (struct jail *__jailp) __THROW;

__END_DECLS

#else /* _KERNEL */

#ifdef MALLOC_DECLARE
MALLOC_DECLARE(M_PRISON);
#endif

/*
 * This structure describes a prison.  It is pointed to by all struct
 * proc's of the inmates.  pr_ref keeps track of them and is used to
 * delete the struture when the last inmate is dead.
 */

struct prison {
	int		pr_ref;
	char 		pr_host[MAXHOSTNAMELEN];
	u_int32_t	pr_ip;
	void		*pr_linux;
};

/*
 * Sysctl-set variables that determine global jail policy
 */
extern int	jail_set_hostname_allowed;
extern int	jail_socket_unixiproute_only;
extern int	jail_sysvipc_allowed;

#endif /* !_KERNEL */
#endif /* !_SYS_JAIL_H_ */
