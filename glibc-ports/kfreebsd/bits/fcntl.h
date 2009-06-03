/* O_*, F_*, FD_* bit values for FreeBSD.
   Copyright (C) 1991-1992, 1997, 2002 Free Software Foundation, Inc.
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

#ifndef	_FCNTL_H
# error "Never use <bits/fcntl.h> directly; include <fcntl.h> instead."
#endif

#include <sys/types.h>
#include <bits/wordsize.h>
#ifdef __USE_GNU
# include <bits/uio.h>
#endif


/* open/fcntl - O_SYNC is only implemented on blocks devices and on files
   located on an ext2 file system */
#define O_ACCMODE	   0003
#define O_RDONLY	     00
#define O_WRONLY	     01
#define O_RDWR		     02
#define O_CREAT		  01000	/* not fcntl */
#define O_EXCL		  04000	/* not fcntl */
#define O_NOCTTY	0100000	/* not fcntl */
#define O_TRUNC		  02000	/* not fcntl */
#define O_APPEND	    010
#define O_NONBLOCK	     04
#define O_NDELAY	O_NONBLOCK
#define O_SYNC		   0200
#define O_FSYNC		 O_SYNC
#define O_ASYNC		   0100

#ifdef __USE_GNU
# define O_DIRECT	0200000	/* Direct disk access.	*/
enum { O_DIRECTORY = 0 };	/* Must be a directory.	 */
enum { O_NOATIME = 0};          /* Do not set atime.  */
# define O_NOFOLLOW	   0400	/* Do not follow links.	 */
#endif

#ifdef __USE_BSD
#define O_SHLOCK	    020 /* Open with shared file lock.  */
#define O_EXLOCK	    040 /* Open with shared exclusive lock.  */
#endif

/* For now FreeBSD has synchronisity options for data and read operations.
   We define the symbols here but let them do the same as O_SYNC since
   this is a superset.	*/
#if defined __USE_POSIX199309 || defined __USE_UNIX98
# define O_DSYNC	O_SYNC	/* Synchronize data.  */
# define O_RSYNC	O_SYNC	/* Synchronize read operations.	 */
#endif

/* Since 'off_t' is 64-bit, O_LARGEFILE is a no-op.  */
#define O_LARGEFILE	0

#ifdef __USE_BSD
/* Bits in the file status flags returned by F_GETFL.
   These are all the O_* flags, plus FREAD and FWRITE, which are
   independent bits set by which of O_RDONLY, O_WRONLY, and O_RDWR, was
   given to `open'.  */
#define FREAD		1
#define	FWRITE		2
#endif

/*
 * We are out of bits in f_flag (which is a short).  However,
 * the flag bits not set in FMASK are only meaningful in the
 * initial open syscall.  Those bits can thus be given a
 * different meaning for fcntl(2).
 */
#if __USE_BSD
/*
 * Set by shm_open(3) to get automatic MAP_ASYNC behavior
 * for POSIX shared memory objects (which are otherwise
 * implemented as plain files).
 */
#define FPOSIXSHM	O_NOFOLLOW
#endif

/* Values for the second argument to `fcntl'.  */
#define F_DUPFD		0	/* Duplicate file descriptor.  */
#define F_GETFD		1	/* Get file descriptor flags.  */
#define F_SETFD		2	/* Set file descriptor flags.  */
#define F_GETFL		3	/* Get file status flags.  */
#define F_SETFL		4	/* Set file status flags.  */
#define F_GETLK		7	/* Get record locking info.  */
#define F_SETLK		8	/* Set record locking info (non-blocking).  */
#define F_SETLKW	9	/* Set record locking info (blocking).	*/
/* Not necessary, we always have 64-bit offsets.  */
#define F_GETLK64	7	/* Get record locking info.  */
#define F_SETLK64	8	/* Set record locking info (non-blocking).  */
#define F_SETLKW64	9	/* Set record locking info (blocking).	*/

#if defined __USE_BSD || defined __USE_UNIX98
# define F_SETOWN	5	/* Get owner of socket (receiver of SIGIO).  */
# define F_GETOWN	6	/* Set owner of socket (receiver of SIGIO).  */
#endif

/* For F_[GET|SET]FD.  */
#define FD_CLOEXEC	1	/* actually anything with low bit set goes */

/* For posix fcntl() and `l_type' field of a `struct flock' for lockf().  */
#define F_RDLCK		1	/* Read lock.  */
#define F_WRLCK		3	/* Write lock.	*/
#define F_UNLCK		2	/* Remove lock.	 */

#ifdef __USE_BSD
/* Operations for bsd flock(), also used by the kernel implementation.	*/
# define LOCK_SH	1	/* shared lock */
# define LOCK_EX	2	/* exclusive lock */
# define LOCK_NB	4	/* or'd with one of the above to prevent
				   blocking */
# define LOCK_UN	8	/* remove lock */
#endif

struct flock
  {
    __off_t l_start;	/* Offset where the lock begins.  */
    __off_t l_len;	/* Size of the locked area; zero means until EOF.  */
    __pid_t l_pid;	/* Process holding the lock.  */
    short int l_type;	/* Type of lock: F_RDLCK, F_WRLCK, or F_UNLCK.	*/
    short int l_whence;	/* Where `l_start' is relative to (like `lseek').  */
    int	__l_sysid;	/* remote system id or zero for local */
  };

#ifdef __USE_LARGEFILE64
struct flock64
  {
    __off64_t l_start;	/* Offset where the lock begins.  */
    __off64_t l_len;	/* Size of the locked area; zero means until EOF.  */
    __pid_t l_pid;	/* Process holding the lock.  */
    short int l_type;	/* Type of lock: F_RDLCK, F_WRLCK, or F_UNLCK.	*/
    short int l_whence;	/* Where `l_start' is relative to (like `lseek').  */
    int	__l_sysid;	/* remote system id or zero for local */
  };
#endif

/* Define some more compatibility macros to be backward compatible with
   BSD systems which did not managed to hide these kernel macros.  */
#ifdef	__USE_BSD
# define FAPPEND	O_APPEND
# define FFSYNC		O_FSYNC
# define FASYNC		O_ASYNC
# define FNONBLOCK	O_NONBLOCK
# define FNDELAY	O_NDELAY

#define FCREAT		O_CREAT
#define FEXCL		O_EXCL
#define FTRUNC		O_TRUNC
#define FNOCTTY		O_NOCTTY
#define FSYNC		O_SYNC
#endif /* Use BSD.  */

