/* Header file for Extended File Attributes.  FreeBSD version.
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
 * Copyright (c) 1999 Robert N. M. Watson
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
 * $FreeBSD: src/sys/sys/extattr.h,v 1.3 2000/01/19 06:07:34 rwatson Exp $
 */
/*
 * Userland/kernel interface for Extended File System Attributes
 *
 * This code from the FreeBSD POSIX.1e implementation.  While the syscalls
 * are fully implemented, invoking the VFS vnops and VFS calls as necessary,
 * no file systems shipped with this version of FreeBSD implement these
 * calls.  Extensions to UFS/FFS to support extended attributes are
 * available from the POSIX.1e implementation page, or possibly in a more
 * recent version of FreeBSD.
 *
 * The POSIX.1e implementation page may be reached at:
 *   http://www.watson.org/fbsd-hardening/posix1e/
 */

#ifndef _SYS_EXTATTR_H_
#define	_SYS_EXTATTR_H_

#include <features.h>

struct iovec;

__BEGIN_DECLS

extern int extattrctl (__const char *__path, int __cmd, const char *__attrname,
		       char *__arg) __THROW;
extern int extattr_delete_file (__const char *__path, __const char *__attrname)
     __THROW;
extern int extattr_get_file (__const char *__path, __const char *__attrname,
			     struct iovec *__iovp, unsigned int __iovcnt)
     __THROW;
extern int extattr_set_file (__const char *__path, __const char *__attrname,
			     struct iovec *__iovp, unsigned int __iovcnt)
     __THROW;

__END_DECLS

#endif /* !_SYS_EXTATTR_H_ */
