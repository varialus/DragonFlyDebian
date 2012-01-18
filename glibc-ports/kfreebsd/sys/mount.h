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

/* Retrieving the list of mounted filesystems.  */

#include <sys/stat.h>
#include <sys/statfs.h>
#include <sys/ucred.h>
#include <sys/queue.h>

/*
 * File identifier.
 * These are unique per filesystem on a single machine.
 */
#define	MAXFIDSZ	16

struct fid {
	__u_short	fid_len;		/* length of data in bytes */
	__u_short	fid_reserved;		/* force longword alignment */
	char		fid_data[MAXFIDSZ];	/* data (variable length) */
};

/*
 * filesystem statistics
 */
#define	MFSNAMELEN	16		/* length of type name including null */
#define	MNAMELEN	88		/* size of on/from name bufs */
#define	STATFS_VERSION	0x20030518	/* current version number */


/*
 * User specifiable flags.
 */
#define	MNT_RDONLY	0x00000001	/* read only filesystem */
#define	MNT_SYNCHRONOUS	0x00000002	/* filesystem written synchronously */
#define	MNT_NOEXEC	0x00000004	/* can't exec from filesystem */
#define	MNT_NOSUID	0x00000008	/* don't honor setuid bits on fs */
#define	MNT_NODEV	0x00000010	/* don't interpret special files */
#define	MNT_UNION	0x00000020	/* union with underlying filesystem */
#define	MNT_ASYNC	0x00000040	/* filesystem written asynchronously */
#define	MNT_SUIDDIR	0x00100000	/* special handling of SUID on dirs */
#define	MNT_SOFTDEP	0x00200000	/* soft updates being done */
#define	MNT_NOSYMFOLLOW	0x00400000	/* do not follow symlinks */
#define	MNT_GJOURNAL	0x02000000	/* GEOM journal support enabled */
#define	MNT_JAILDEVFS	0x02000000	/* jail-friendly DEVFS behaviour */
#define	MNT_MULTILABEL	0x04000000	/* MAC support for individual objects */
#define	MNT_ACLS	0x08000000	/* ACL support enabled */
#define	MNT_NOATIME	0x10000000	/* disable update of file access time */
#define	MNT_NOCLUSTERR	0x40000000	/* disable cluster read */
#define	MNT_NOCLUSTERW	0x80000000	/* disable cluster write */
#define	MNT_NFS4ACLS	0x00000010

/*
 * NFS export related mount flags.
 */
#define	MNT_EXRDONLY	0x00000080	/* exported read only */
#define	MNT_EXPORTED	0x00000100	/* filesystem is exported */
#define	MNT_DEFEXPORTED	0x00000200	/* exported to the world */
#define	MNT_EXPORTANON	0x00000400	/* use anon uid mapping for everyone */
#define	MNT_EXKERB	0x00000800	/* exported with Kerberos uid mapping */
#define	MNT_EXPUBLIC	0x20000000	/* public export (WebNFS) */

/*
 * Flags set by internal operations,
 * but visible to the user.
 * XXX some of these are not quite right.. (I've never seen the root flag set)
 */
#define	MNT_LOCAL	0x00001000	/* filesystem is stored locally */
#define	MNT_QUOTA	0x00002000	/* quotas are enabled on filesystem */
#define	MNT_ROOTFS	0x00004000	/* identifies the root filesystem */
#define	MNT_USER	0x00008000	/* mounted by a user */
#define	MNT_IGNORE	0x00800000	/* do not show entry in df */

/*
 * Mask of flags that are visible to statfs().
 * XXX I think that this could now become (~(MNT_CMDFLAGS))
 * but the 'mount' program may need changing to handle this.
 */
#define	MNT_VISFLAGMASK	(MNT_RDONLY	| MNT_SYNCHRONOUS | MNT_NOEXEC	| \
			MNT_NOSUID	| MNT_NODEV	| MNT_UNION	| \
			MNT_ASYNC	| MNT_EXRDONLY	| MNT_EXPORTED	| \
			MNT_DEFEXPORTED	| MNT_EXPORTANON| MNT_EXKERB	| \
			MNT_LOCAL	| MNT_USER	| MNT_QUOTA	| \
			MNT_ROOTFS	| MNT_NOATIME	| MNT_NOCLUSTERR| \
			MNT_NOCLUSTERW	| MNT_SUIDDIR	| MNT_SOFTDEP	| \
			MNT_IGNORE	| MNT_EXPUBLIC	| MNT_NOSYMFOLLOW | \
			MNT_JAILDEVFS	| MNT_MULTILABEL | MNT_ACLS)

/* Mask of flags that can be updated. */
#define	MNT_UPDATEMASK (MNT_NOSUID	| MNT_NOEXEC	| MNT_NODEV	| \
			MNT_SYNCHRONOUS	| MNT_UNION	| MNT_ASYNC	| \
			MNT_NOATIME | \
			MNT_NOSYMFOLLOW	| MNT_IGNORE	| MNT_JAILDEVFS	| \
			MNT_NOCLUSTERR	| MNT_NOCLUSTERW | MNT_SUIDDIR	| \
			MNT_ACLS	| MNT_USER)

/*
 * External filesystem command modifier flags.
 * Unmount can use the MNT_FORCE flag.
 * XXX These are not STATES and really should be somewhere else.
 */
#define	MNT_UPDATE	0x00010000	/* not a real mount, just an update */
#define	MNT_DELEXPORT	0x00020000	/* delete export host lists */
#define	MNT_RELOAD	0x00040000	/* reload filesystem data */
#define	MNT_FORCE	0x00080000	/* force unmount or readonly change */
#define	MNT_SNAPSHOT	0x01000000	/* snapshot the filesystem */
#define	MNT_BYFSID	0x08000000	/* specify filesystem by ID. */
#define MNT_CMDFLAGS   (MNT_UPDATE	| MNT_DELEXPORT	| MNT_RELOAD	| \
			MNT_FORCE	| MNT_SNAPSHOT	| MNT_BYFSID)
/*
 * Internal filesystem control flags stored in mnt_kern_flag.
 *
 * MNTK_UNMOUNT locks the mount entry so that name lookup cannot proceed
 * past the mount point.  This keeps the subtree stable during mounts
 * and unmounts.
 *
 * MNTK_UNMOUNTF permits filesystems to detect a forced unmount while
 * dounmount() is still waiting to lock the mountpoint. This allows
 * the filesystem to cancel operations that might otherwise deadlock
 * with the unmount attempt (used by NFS).
 */
#define MNTK_UNMOUNTF	0x00000001	/* forced unmount in progress */
#define MNTK_ASYNC      0x00000002      /* filtered async flag */
#define MNTK_SOFTDEP    0x00000004      /* async disabled by softdep */
#define MNTK_NOINSMNTQ  0x00000008      /* insmntque is not allowed */
#define MNTK_UNMOUNT	0x01000000	/* unmount in progress */
#define	MNTK_MWAIT	0x02000000	/* waiting for unmount to finish */
#define MNTK_WANTRDWR	0x04000000	/* upgrade to read/write requested */
#define MNTK_SUSPEND2   0x04000000      /* block secondary writes */
#define	MNTK_SUSPEND	0x08000000	/* request write suspension */
#define	MNTK_SUSPENDED	0x10000000	/* write operations are suspended */
#define MNTK_MPSAFE     0x20000000      /* Filesystem is MPSAFE. */
#define MNTK_NOKNOTE    0x80000000      /* Don't send KNOTEs from VOP hooks */
#define MNTK_LOOKUP_SHARED      0x40000000 /* FS supports shared lock lookups */

/*
 * Sysctl CTL_VFS definitions.
 *
 * Second level identifier specifies which filesystem. Second level
 * identifier VFS_VFSCONF returns information about all filesystems.
 * Second level identifier VFS_GENERIC is non-terminal.
 */
#define	VFS_VFSCONF		0	/* get configured filesystems */
#define	VFS_GENERIC		0	/* generic filesystem information */
/*
 * Third level identifiers for VFS_GENERIC are given below; third
 * level identifiers for specific filesystems are given in their
 * mount specific header files.
 */
#define VFS_MAXTYPENUM	1	/* int: highest defined filesystem type */
#define VFS_CONF	2	/* struct: vfsconf for filesystem given
				   as next argument */

/*
 * Flags for various system call interfaces.
 *
 * waitfor flags to vfs_sync() and getfsstat()
 */
#define MNT_WAIT	1	/* synchronously wait for I/O to complete */
#define MNT_NOWAIT	2	/* start all I/O, but do not wait for it */
#define MNT_LAZY	3	/* push data not written by filesystem syncer */
#define	MNT_SUSPEND	4	/* Suspend file system after sync */

/*
 * Generic file handle
 */
struct fhandle {
	__fsid_t	fh_fsid;	/* Filesystem id of mount point */
	struct		fid fh_fid;	/* Filesys specific id */
};
typedef struct fhandle	fhandle_t;

/*
 * Old export arguments without security flavor list
 */
struct oexport_args {
	int	ex_flags;		/* export related flags */
	uid_t	ex_root;		/* mapping for root uid */
	struct	xucred ex_anon;		/* mapping for anonymous user */
	struct	sockaddr *ex_addr;	/* net address to which exported */
	__u_char ex_addrlen;		/* and the net address length */
	struct	sockaddr *ex_mask;	/* mask of valid bits in saddr */
	__u_char ex_masklen;		/* and the smask length */
	char	*ex_indexfile;		/* index file for WebNFS URLs */
};

/*
 * Export arguments for local filesystem mount calls.
 */
struct export_args {
	int		ex_flags;		/* export related flags */
	uid_t		ex_root;		/* mapping for root uid */
	struct		xucred ex_anon;		/* mapping for anonymous user */
	struct		sockaddr *ex_addr;	/* net address to which exported */
	__u_char	ex_addrlen;		/* and the net address length */
	struct		sockaddr *ex_mask;	/* mask of valid bits in saddr */
	__u_char	ex_masklen;		/* and the smask length */
	char		*ex_indexfile;		/* index file for WebNFS URLs */
};

/*
 * Structure holding information for a publicly exported filesystem
 * (WebNFS). Currently the specs allow just for one such filesystem.
 */
struct nfs_public {
	int		np_valid;	/* Do we hold valid information */
	fhandle_t	np_handle;	/* Filehandle for pub fs (internal) */
	struct mount	*np_mount;	/* Mountpoint of exported fs */
	char		*np_index;	/* Index file */
};

/*
 * Filesystem configuration information. One of these exists for each
 * type of filesystem supported by the kernel. These are searched at
 * mount time to identify the requested filesystem.
 *
 * XXX: Never change the first two arguments!
 */
struct vfsconf {
	__u_int	vfc_version;		/* ABI version number */
	char	vfc_name[MFSNAMELEN];	/* filesystem type name */
	struct	vfsops *vfc_vfsops;	/* filesystem operations vector */
	int	vfc_typenum;		/* historic filesystem type number */
	int	vfc_refcount;		/* number mounted of this type */
	int	vfc_flags;		/* permanent flags */
	struct	vfsoptdecl *vfc_opts;	/* mount options */
	TAILQ_ENTRY(vfsconf) vfc_list;	/* list of vfscons */
};

/* Userland version of the struct vfsconf. */
struct xvfsconf {
	struct	vfsops *vfc_vfsops;	/* filesystem operations vector */
	char	vfc_name[MFSNAMELEN];	/* filesystem type name */
	int	vfc_typenum;		/* historic filesystem type number */
	int	vfc_refcount;		/* number mounted of this type */
	int	vfc_flags;		/* permanent flags */
	struct	vfsconf *vfc_next;	/* next in list */
};

#ifndef BURN_BRIDGES
struct ovfsconf {
	void	*vfc_vfsops;
	char	vfc_name[32];
	int	vfc_index;
	int	vfc_refcount;
	int	vfc_flags;
};
#endif

/*
 * NB: these flags refer to IMPLEMENTATION properties, not properties of
 * any actual mounts; i.e., it does not make sense to change the flags.
 */
#define	VFCF_STATIC	0x00010000	/* statically compiled into kernel */
#define	VFCF_NETWORK	0x00020000	/* may get data over the network */
#define	VFCF_READONLY	0x00040000	/* writes are not implemented */
#define VFCF_SYNTHETIC	0x00080000	/* data does not represent real files */
#define	VFCF_LOOPBACK	0x00100000	/* aliases some other mounted FS */
#define	VFCF_UNICODE	0x00200000	/* stores file names as Unicode*/
#define VFCF_JAIL       0x00400000      /* can be mounted from within a jail */

typedef u_int32_t fsctlop_t;

struct vfsidctl {
	int		vc_vers;	/* should be VFSIDCTL_VERS1 (below) */
	__fsid_t	vc_fsid;	/* fsid to operate on. */
	char		vc_fstypename[MFSNAMELEN];
					/* type of fs 'nfs' or '*' */
	fsctlop_t	vc_op;		/* operation VFS_CTL_* (below) */
	void		*vc_ptr;	/* pointer to data structure. */
	size_t		vc_len;		/* sizeof said structure. */
	u_int32_t	vc_spare[12];	/* spare (must be zero). */
};

/* vfsidctl API version. */
#define VFS_CTL_VERS1	0x01

/*
 * New style VFS sysctls, do not reuse/conflict with the namespace for
 * private sysctls.
 * All "global" sysctl ops have the 33rd bit set:
 * 0x...1....
 * Private sysctl ops should have the 33rd bit unset.
 */
#define VFS_CTL_QUERY	0x00010001	/* anything wrong? (vfsquery) */
#define VFS_CTL_TIMEO	0x00010002	/* set timeout for vfs notification */
#define VFS_CTL_NOLOCKS	0x00010003	/* disable file locking */

struct vfsquery {
	u_int32_t	vq_flags;
	u_int32_t	vq_spare[31];
};

/* vfsquery flags */
#define VQ_NOTRESP	0x0001	/* server down */
#define VQ_NEEDAUTH	0x0002	/* server bad auth */
#define VQ_LOWDISK	0x0004	/* we're low on space */
#define VQ_MOUNT	0x0008	/* new filesystem arrived */
#define VQ_UNMOUNT	0x0010	/* filesystem has left */
#define VQ_DEAD		0x0020	/* filesystem is dead, needs force unmount */
#define VQ_ASSIST	0x0040	/* filesystem needs assistance from external
				   program */
#define VQ_NOTRESPLOCK	0x0080	/* server lockd down */
#define VQ_FLAG0100	0x0100	/* placeholder */
#define VQ_FLAG0200	0x0200	/* placeholder */
#define VQ_FLAG0400	0x0400	/* placeholder */
#define VQ_FLAG0800	0x0800	/* placeholder */
#define VQ_FLAG1000	0x1000	/* placeholder */
#define VQ_FLAG2000	0x2000	/* placeholder */
#define VQ_FLAG4000	0x4000	/* placeholder */
#define VQ_FLAG8000	0x8000	/* placeholder */


struct iovec;
struct uio;

__BEGIN_DECLS

/* Mounting and unmounting filesystems.  */
int	mount(const char *, const char *, int, void *);
int	nmount(struct iovec *, unsigned int, int);
int	unmount(const char *, int);

/* C library stuff */
int	getvfsbyname(const char *, struct xvfsconf *);

/* getfsstat() appears in BSD 4.4.  A variant of this API is found on OSF/1,
   but on that system the user also needs to include <sys/fs_types.h>.  */

#ifndef __USE_FILE_OFFSET64
extern int getfsstat (struct statfs *__buf, long __bufsize,
		      int __flags) __THROW;
#else
# ifdef __REDIRECT
extern int __REDIRECT (getfsstat,
		       (struct statfs *__buf, long __bufsize, int __flags),
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
		       (struct statfs **__mntbufp, int __flags),
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

__BEGIN_DECLS

/* Return in *FHP the file handle corresponding to the file or directory
   PATH.  */
extern int getfh (__const char *__path, fhandle_t *__fhp) __THROW;

/* Return in *FHP the file handle corresponding to the file or directory
   PATH.  */
extern int lgetfh (__const char *__path, fhandle_t *__fhp) __THROW;

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
		       (__const fhandle_t *__fhp, struct stat *__buf),
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
		       (__const fhandle_t *__fhp, struct statfs *__buf),
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
