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


/* Mounting and unmounting filesystems.  */

/* Possible value for FLAGS parameter of 'mount' and 'unmount', that
   correspond to flags visible in 'struct statfs'.  */
enum
{
  MNT_RDONLY = 1 << 0,		/* Mount read-only.  */
#define MNT_RDONLY MNT_RDONLY
  MNT_SYNCHRONOUS = 1 << 1,	/* Writes are synced at once.  */
#define MNT_SYNCHRONOUS	MNT_SYNCHRONOUS
  MNT_NOEXEC = 1 << 2,		/* Disallow program execution.  */
#define MNT_NOEXEC MNT_NOEXEC
  MNT_NOSUID = 1 << 3,		/* Ignore suid and sgid bits.  */
#define MNT_NOSUID MNT_NOSUID
  MNT_NODEV = 1 << 4,		/* Disallow access to device special files.  */
#define MNT_NODEV MNT_NODEV
  MNT_UNION = 1 << 5,		/* Translucent/union mount.  */
#define MNT_UNION MNT_UNION
  MNT_ASYNC = 1 << 6,		/* Writes can be delayed.  */
#define MNT_ASYNC MNT_ASYNC
  MNT_EXRDONLY = 1 << 7,	/* NFS: Export read-only.  */
#define MNT_EXRDONLY MNT_EXRDONLY
  MNT_EXPORTED = 1 << 8,	/* NFS: Export.  */
#define MNT_EXPORTED MNT_EXPORTED
  MNT_DEFEXPORTED = 1 << 9,	/* NFS: Export to the world.  */
#define MNT_DEFEXPORTED MNT_DEFEXPORTED
  MNT_EXPORTANON = 1 << 10,	/* NFS: Map all uids to the anonymous uid.  */
#define MNT_EXPORTANON MNT_EXPORTANON
  MNT_EXKERB = 1 << 11,		/* NFS: Use Kerberos uid mapping.  */
#define MNT_EXKERB MNT_EXKERB
  MNT_SUIDDIR = 1 << 20,	/* File creation in suid directories...  */
#define MNT_SUIDDIR MNT_SUIDDIR
  MNT_SOFTDEP = 1 << 21,	/* Soft mount.  */
#define MNT_SOFTDEP MNT_SOFTDEP
  MNT_NOATIME = 1 << 28,	/* Do not update access times.  */
#define MNT_NOATIME MNT_NOATIME
  MNT_EXPUBLIC = 1 << 29,	/* WebNFS: Public export.  */
#define MNT_EXPUBLIC MNT_EXPUBLIC
  MNT_NOCLUSTERR = 1 << 30,	/* Disable read clustering.  */
#define MNT_NOCLUSTERR MNT_NOCLUSTERR
  MNT_NOCLUSTERW = 1 << 31	/* Disable write clustering.  */
#define MNT_NOCLUSTERW MNT_NOCLUSTERW
};

/* Other flags, set by the kernel and visible in userland.  */
enum
{
  MNT_LOCAL = 1 << 12,		/* Locally stored filesystem.  */
#define MNT_LOCAL MNT_LOCAL
  MNT_QUOTA = 1 << 13,		/* Quotas are enabled.  */
#define MNT_QUOTA MNT_QUOTA
  MNT_ROOTFS = 1 << 14,		/* Root filesystem (questionable).  */
#define MNT_ROOTFS MNT_ROOTFS
  MNT_USER = 1 << 15,		/* Mounted by a user.  */
#define MNT_USER MNT_USER
  MNT_IGNORE = 1 << 23		/* Not listed by 'df'.  */
#define MNT_IGNORE MNT_IGNORE
};

/* Other possible value for FLAGS parameter of 'mount' and 'unmount'.  */
enum
{
  MNT_UPDATE = 1 << 16,		/* No new mount, only an update.  */
#define MNT_UPDATE MNT_UPDATE
  MNT_DELEXPORT = 1 << 17,	/* Delete the export host lists.  */
#define MNT_DELEXPORT MNT_DELEXPORT
  MNT_RELOAD = 1 << 18,		/* Reload filesystem data.  */
#define MNT_RELOAD MNT_RELOAD
  MNT_FORCE = 1 << 19,		/* Mount even if unclean.  Dangerous!  */
#define MNT_FORCE MNT_FORCE
  MNT_NOSYMFOLLOW = 1 << 22	/* Don't follow symlinks during mount().  */
#define MNT_NOSYMFOLLOW MNT_NOSYMFOLLOW
};

/* Retrieving the list of mounted filesystems.  */

#include <bits/statfs.h>

/* Possible value for FLAGS parameter of 'getfsstat'.  */
enum
{
  MNT_WAIT = 1,			/* Wait synchronously.  */
#define MNT_WAIT MNT_WAIT
  MNT_NOWAIT = 2,		/* May start I/O asynchronously.  */
#define MNT_NOWAIT MNT_NOWAIT
  MNT_LAZY = 3			/* Related to filesystem syncer.  */
#define MNT_LAZY MNT_LAZY
};

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

/* File identifier.  */
#define MAXFIDSZ 16
struct fid
  {
    unsigned short fid_len;		/* Length of data in bytes.  */
    unsigned short __unused1;
    char fid_data[MAXFIDSZ];		/* Data (variable length).  */
  };

/* File handle.  */
typedef struct fhandle
  {
    __fsid_t fh_fsid;			/* File system id of mount point.  */
    struct fid fh_fid;			/* File sys specific id.  */
  } fhandle_t;

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
