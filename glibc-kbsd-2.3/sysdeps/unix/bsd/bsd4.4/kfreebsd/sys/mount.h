/* Header file for handling mounted filesystems.  FreeBSD version.
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

#ifndef _SYS_MOUNT_H
#define _SYS_MOUNT_H	1

#include <features.h>
#include "/usr/src/kfreebsd4-headers/sys/mount.h"

/* Mounting and unmounting filesystems.  */

/* Retrieving the list of mounted filesystems.  */

#include <bits/statfs.h>

__BEGIN_DECLS

/* getfsstat() appears in BSD 4.4.  A variant of this API is found on OSF/1,
   but on that system the user also needs to include <sys/fs_types.h>.  */

#ifndef __USE_FILE_OFFSET64
extern int getfsstat (struct statfs *__buf, long __bufsize,
		      int __flags) __THROW;
#else
# ifdef __REDIRECT
extern int __REDIRECT (getfsstat,
		       (struct statfs *__buf, long __bufsize, int __flags)
			 __THROW,
		       getfsstat64);
# else
#  define getfsstat getfsstat64
# endif
#endif
#ifdef __USE_LARGEFILE64
extern int getfsstat64 (struct statfs64 *__buf, long __bufsize,
			int __flags) __THROW;
#endif

#ifdef _LIBC
extern int __getfsstat (struct statfs *__buf, long __bufsize, int __flags);
extern int __getfsstat64 (struct statfs64 *__buf, long __bufsize, int __flags);
#endif

/* getmntinfo() appears in BSD 4.4.  */

#ifndef __USE_FILE_OFFSET64
extern int getmntinfo (struct statfs **__mntbufp, int __flags) __THROW;
#else
# ifdef __REDIRECT
extern int __REDIRECT (getmntinfo,
		       (struct statfs **__mntbufp, int __flags) __THROW,
		       getmntinfo64);
# else
#  define getmntinfo getmntinfo64
# endif
#endif
#ifdef __USE_LARGEFILE64
extern int getmntinfo64 (struct statfs64 **__mntbufp, int __flags) __THROW;
#endif

#ifdef _LIBC
extern int __getmntinfo (struct statfs **__mntbufp, int __flags);
#endif

__END_DECLS


/* Opening files on specified mounted filesystems.
   These system calls are reserved to the superuser, for security reasons.  */

#include <sys/stat.h>

__BEGIN_DECLS

/* Return in *FHP the file handle corresponding to the file or directory
   PATH.  */
extern int getfh (__const char *__path, fhandle_t *__fhp) __THROW;

/* Open a file handle *FHP, using the open() like FLAGS.  Return the
   new file descriptor.  */
extern int fhopen (__const fhandle_t *__fhp, int __flags) __THROW;

/* Get file attributes for the file whose handle is *FHP, and return them
   in *BUF.  Like fhopen + fstat + close.  */
#ifndef __USE_FILE_OFFSET64
extern int fhstat (__const fhandle_t *__fhp, struct stat *__buf) __THROW;
#else
# ifdef __REDIRECT
extern int __REDIRECT (fhstat,
		       (__const fhandle_t *__fhp, struct stat *__buf) __THROW,
		       fhstat64);
# else
#  define fhstat fhstat64
# endif
#endif
#ifdef __USE_LARGEFILE64
extern int fhstat64 (__const fhandle_t *__fhp, struct stat64 *__buf) __THROW;
#endif

/* Return information about the filesystem on which the file resides whose
   handle is *FHP.  Like fhopen + fstatfs + close.  */
#ifndef __USE_FILE_OFFSET64
extern int fhstatfs (__const fhandle_t *__fhp, struct statfs *__buf) __THROW;
#else
# ifdef __REDIRECT
extern int __REDIRECT (fhstatfs,
		       (__const fhandle_t *__fhp, struct statfs *__buf) __THROW,
		       fhstatfs64);
# else
#  define fhstatfs fhstatfs64
# endif
#endif
#ifdef __USE_LARGEFILE64
extern int fhstatfs64 (__const fhandle_t *__fhp,
		       struct statfs64 *__buf) __THROW;
#endif

__END_DECLS

#endif /* _SYS_MOUNT_H */
