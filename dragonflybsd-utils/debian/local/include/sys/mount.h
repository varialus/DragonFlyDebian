#ifndef _WRAP_SYS_MOUNT_H
#define _WRAP_SYS_MOUNT_H 1

#define export_args __export_args_82
#define oexport_args __oexport_args_82
#include_next <sys/mount.h>
#undef export_args
#undef oexport_args

#ifndef MNT_SUJ
#define     MNT_SUJ         0x0000000100000000ULL /* using journaled soft updates */
#endif

/*
 * Old export arguments without security flavor list
 */
struct oexport_args {
	int	ex_flags;		/* export related flags */
	uid_t	ex_root;		/* mapping for root uid */
	struct	xucred ex_anon;		/* mapping for anonymous user */
	struct	sockaddr *ex_addr;	/* net address to which exported */
	u_char	ex_addrlen;		/* and the net address length */
	struct	sockaddr *ex_mask;	/* mask of valid bits in saddr */
	u_char	ex_masklen;		/* and the smask length */
	char	*ex_indexfile;		/* index file for WebNFS URLs */
};

/*
 * Export arguments for local filesystem mount calls.
 */
#define	MAXSECFLAVORS	5
struct export_args {
	int	ex_flags;		/* export related flags */
	uid_t	ex_root;		/* mapping for root uid */
	struct	xucred ex_anon;		/* mapping for anonymous user */
	struct	sockaddr *ex_addr;	/* net address to which exported */
	u_char	ex_addrlen;		/* and the net address length */
	struct	sockaddr *ex_mask;	/* mask of valid bits in saddr */
	u_char	ex_masklen;		/* and the smask length */
	char	*ex_indexfile;		/* index file for WebNFS URLs */
	int	ex_numsecflavors;	/* security flavor count */
	int	ex_secflavors[MAXSECFLAVORS]; /* list of security flavors */
};

#endif
