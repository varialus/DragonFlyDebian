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

#ifdef _KERNEL

/*
 * Storage for ACLs and support structures
 */
#ifdef MALLOC_DECLARE
MALLOC_DECLARE(M_ACL);
#endif

#else /* !_KERNEL */

/*
 * Syscall interface -- use the library calls instead as the syscalls
 * have strict acl entry ordering requirements
 */
__BEGIN_DECLS
int	__acl_aclcheck_fd(int _filedes, acl_type_t _type, struct acl *_aclp);
int	__acl_aclcheck_file(const char *_path, acl_type_t _type,
	    struct acl *_aclp);
int	__acl_delete_fd(int _filedes, acl_type_t _type);
int	__acl_delete_file(const char *_path_p, acl_type_t _type);
int	__acl_get_fd(int _filedes, acl_type_t _type, struct acl *_aclp);
int	__acl_get_file(const char *_path, acl_type_t _type, struct acl *_aclp);
int	__acl_set_fd(int _filedes, acl_type_t _type, struct acl *_aclp);
int	__acl_set_file(const char *_path, acl_type_t _type, struct acl *_aclp);
__END_DECLS

/*
 * Supported POSIX.1e ACL manipulation and assignment/retrieval API
 * _np calls are local extensions that reflect an environment capable of
 * opening file descriptors of directories, and allowing additional
 * ACL type for different file systems (i.e., AFS)
 */
__BEGIN_DECLS
int	acl_delete_fd_np(int _filedes, acl_type_t _type);
int	acl_delete_file_np(const char *_path_p, acl_type_t _type);
int	acl_delete_def_file(const char *_path_p);
acl_t	acl_dup(acl_t _acl);
int	acl_free(void *_obj_p);
acl_t	acl_from_text(const char *_buf_p);
acl_t	acl_get_fd(int _fd);
acl_t	acl_get_fd_np(int fd, acl_type_t _type);
acl_t	acl_get_file(const char *_path_p, acl_type_t _type);
acl_t	acl_init(int _count);
int	acl_set_fd(int _fd, acl_t _acl);
int	acl_set_fd_np(int _fd, acl_t _acl, acl_type_t _type);
int	acl_set_file(const char *_path_p, acl_type_t _type, acl_t _acl);
char	*acl_to_text(acl_t _acl, ssize_t *_len_p);
int	acl_valid(acl_t _acl);
int	acl_valid_fd_np(int _fd, acl_type_t _type, acl_t _acl);
int	acl_valid_file_np(const char *_path_p, acl_type_t _type, acl_t _acl);
__END_DECLS

#endif /* !_KERNEL */

#endif /* !_SYS_ACL_H */
