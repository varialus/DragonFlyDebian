/* Header file for Access Control Lists.  FreeBSD version.
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

/*-
 * Copyright (c) 1999, 2000 Robert N. M. Watson
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
 * $FreeBSD: src/sys/sys/acl.h,v 1.8 2000/01/28 15:22:51 rwatson Exp $
 */

/* 
 * Userland/kernel interface for Access Control Lists.
 *
 * The POSIX.1e implementation page may be reached at:
 * http://www.watson.org/fbsd-hardening/posix1e/
 */

#ifndef _SYS_ACL_H
#define	_SYS_ACL_H

#include <features.h>
#include <sys/types.h>

/*
 * POSIX.1e ACL types and related constants
 */

#define	ACL_MAX_ENTRIES		32 /* maximum entries in an ACL */
#define	_POSIX_ACL_PATH_MAX     ACL_MAX_ENTRIES

typedef int	acl_type_t;
typedef int	acl_tag_t;
typedef mode_t	acl_perm_t;

struct acl_entry {
	acl_tag_t	ae_tag;
	uid_t		ae_id;
	acl_perm_t	ae_perm;
};
typedef struct acl_entry	*acl_entry_t;

struct acl {
	int			acl_cnt;
	struct acl_entry	acl_entry[ACL_MAX_ENTRIES];
};
typedef struct acl	*acl_t;

/*
 * Possible valid values for a_tag of acl_entry_t
 */
#define	ACL_USER_OBJ	0x00000001
#define	ACL_USER	0x00000002
#define	ACL_GROUP_OBJ	0x00000004
#define	ACL_GROUP	0x00000008
#define	ACL_MASK	0x00000010
#define	ACL_OTHER	0x00000020
#define	ACL_OTHER_OBJ	ACL_OTHER

/*
 * Possible valid values a_type_t arguments
 */
#define	ACL_TYPE_ACCESS		0x00000000
#define	ACL_TYPE_DEFAULT	0x00000001
#define	ACL_TYPE_AFS		0x00000002
#define	ACL_TYPE_CODA		0x00000003
#define	ACL_TYPE_NTFS		0x00000004
#define	ACL_TYPE_NWFS		0x00000005

/*
 * Possible flags in a_perm field
 */
#define	ACL_PERM_EXEC	0x0001
#define	ACL_PERM_WRITE	0x0002
#define	ACL_PERM_READ	0x0004
#define	ACL_PERM_NONE	0x0000
#define	ACL_PERM_BITS	(ACL_PERM_EXEC | ACL_PERM_WRITE | ACL_PERM_READ)
#define	ACL_POSIX1E_BITS	(ACL_PERM_EXEC | ACL_PERM_WRITE | ACL_PERM_READ)

/*
 * Syscall interface, defined in libc.
 * You should use the libposix1e library calls instead as the syscalls
 * have strict acl entry ordering requirements
 */
__BEGIN_DECLS
extern int __acl_aclcheck_fd (int __fd, acl_type_t __type,
			      struct acl *__aclp) __THROW;
extern int __acl_aclcheck_file (__const char *__path, acl_type_t __type,
				struct acl *__aclp) __THROW;
extern int __acl_delete_fd (int __fd, acl_type_t __type) __THROW;
extern int __acl_delete_file (__const char *__path, acl_type_t __type) __THROW;
extern int __acl_get_fd (int __fd, acl_type_t __type,
			 struct acl *__aclp) __THROW;
extern int __acl_get_file (__const char *_path, acl_type_t __type,
			   struct acl *__aclp) __THROW;
extern int __acl_set_fd (int __fd, acl_type_t __type,
			 struct acl *__aclp) __THROW;
extern int __acl_set_file (__const char *__path, acl_type_t __type,
			   struct acl *_aclp) __THROW;
__END_DECLS

/*
 * Supported POSIX.1e ACL manipulation and assignment/retrieval API,
 * defined in libposix1e.
 * _np calls are local extensions that reflect an environment capable of
 * opening file descriptors of directories, and allowing additional
 * ACL type for different file systems (i.e., AFS)
 */
__BEGIN_DECLS
extern int acl_delete_fd_np (int __fd,
			     acl_type_t __type) __THROW;
extern int acl_delete_file_np (__const char *__path,
			       acl_type_t __type) __THROW;
extern int acl_delete_def_file (__const char *__path) __THROW;
extern acl_t acl_dup (acl_t __acl) __THROW;
extern int acl_free (void *__obj) __THROW;
extern acl_t acl_from_text (__const char *__buf) __THROW;
extern acl_t acl_get_fd (int __fd) __THROW;
extern acl_t acl_get_fd_np (int __fd, acl_type_t __type) __THROW;
extern acl_t acl_get_file (__const char *__path, acl_type_t __type) __THROW;
extern acl_t acl_init (int __count) __THROW;
extern int acl_set_fd (int __fd,
		       acl_t __acl) __THROW;
extern int acl_set_fd_np (int __fd,
			  acl_t __acl, acl_type_t __type) __THROW;
extern int acl_set_file (__const char *__path,
			 acl_type_t __type, acl_t __acl) __THROW;
extern char *acl_to_text (acl_t __acl, ssize_t *__lenp) __THROW;
extern int acl_valid (acl_t __acl) __THROW;
extern int acl_valid_fd_np (int __fd,
			    acl_type_t __type, acl_t __acl) __THROW;
extern int acl_valid_file_np (__const char *__path,
			      acl_type_t __type, acl_t __acl) __THROW;
__END_DECLS

#endif /* !_SYS_ACL_H */
