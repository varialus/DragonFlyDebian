/*
 * Copyright (c) 1982, 1986, 1989, 1993
 *	The Regents of the University of California.  All rights reserved.
 * (c) UNIX System Laboratories, Inc.
 * All or some portions of this file are derived from material licensed
 * to the University of California by American Telephone and Telegraph
 * Co. or Unix System Laboratories, Inc. and are reproduced herein with
 * the permission of UNIX System Laboratories, Inc.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *	This product includes software developed by the University of
 *	California, Berkeley and its contributors.
 * 4. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 *	@(#)buf.h	8.9 (Berkeley) 3/30/95
 * $FreeBSD: src/sys/sys/buf.h,v 1.88.2.7 2001/12/25 01:44:44 dillon Exp $
 */

#ifndef _SYS_BUF_H_
#define	_SYS_BUF_H_

#include <sys/queue.h>
#include <sys/lock.h>

struct buf;
struct mount;
struct vnode;

/*
 * To avoid including <ufs/ffs/softdep.h> 
 */   
LIST_HEAD(workhead, worklist);
/*
 * These are currently used only by the soft dependency code, hence
 * are stored once in a global variable. If other subsystems wanted
 * to use these hooks, a pointer to a set of bio_ops could be added
 * to each buffer.
 */
extern struct bio_ops {
	void	(*io_start) __P((struct buf *));
	void	(*io_complete) __P((struct buf *));
	void	(*io_deallocate) __P((struct buf *));
	int	(*io_fsync) __P((struct vnode *));
	int	(*io_sync) __P((struct mount *));
	void	(*io_movedeps) __P((struct buf *, struct buf *));
	int	(*io_countdeps) __P((struct buf *, int));
} bioops;

struct iodone_chain {
	long	ic_prev_flags;
	void	(*ic_prev_iodone) __P((struct buf *));
	void	*ic_prev_iodone_chain;
	struct {
		long	ia_long;
		void	*ia_ptr;
	}	ic_args[5];
};

/*
 * The buffer header describes an I/O operation in the kernel.
 *
 * NOTES:
 *	b_bufsize, b_bcount.  b_bufsize is the allocation size of the
 *	buffer, either DEV_BSIZE or PAGE_SIZE aligned.  b_bcount is the
 *	originally requested buffer size and can serve as a bounds check
 *	against EOF.  For most, but not all uses, b_bcount == b_bufsize.
 *
 *	b_dirtyoff, b_dirtyend.  Buffers support piecemeal, unaligned
 *	ranges of dirty data that need to be written to backing store.
 *	The range is typically clipped at b_bcount ( not b_bufsize ).
 *
 *	b_resid.  Number of bytes remaining in I/O.  After an I/O operation
 *	completes, b_resid is usually 0 indicating 100% success.
 */
struct buf {
	LIST_ENTRY(buf) b_hash;		/* Hash chain. */
	TAILQ_ENTRY(buf) b_vnbufs;	/* Buffer's associated vnode. */
	TAILQ_ENTRY(buf) b_freelist;	/* Free list position if not active. */
	TAILQ_ENTRY(buf) b_act;		/* Device driver queue when active. *new* */
	long	b_flags;		/* B_* flags. */
	unsigned short b_qindex;	/* buffer queue index */
	unsigned char b_xflags;		/* extra flags */
	struct lock b_lock;		/* Buffer lock */
	int	b_error;		/* Errno value. */
	long	b_bufsize;		/* Allocated buffer size. */
	long	b_runningbufspace;	/* when I/O is running, pipelining */
	long	b_bcount;		/* Valid bytes in buffer. */
	long	b_resid;		/* Remaining I/O. */
	dev_t	b_dev;			/* Device associated with buffer. */
	caddr_t	b_data;			/* Memory, superblocks, indirect etc. */
	caddr_t	b_kvabase;		/* base kva for buffer */
	int	b_kvasize;		/* size of kva for buffer */
	daddr_t	b_lblkno;		/* Logical block number. */
	daddr_t	b_blkno;		/* Underlying physical block number. */
	off_t	b_offset;		/* Offset into file */
					/* Function to call upon completion. */
	void	(*b_iodone) __P((struct buf *));
					/* For nested b_iodone's. */
	struct	iodone_chain *b_iodone_chain;
	struct	vnode *b_vp;		/* Device vnode. */
	int	b_dirtyoff;		/* Offset in buffer of dirty region. */
	int	b_dirtyend;		/* Offset of end of dirty region. */
	struct	ucred *b_rcred;		/* Read credentials reference. */
	struct	ucred *b_wcred;		/* Write credentials reference. */
	daddr_t	b_pblkno;               /* physical block number */
	void	*b_saveaddr;		/* Original b_addr for physio. */
	void	*b_driver1;		/* for private use by the driver */
	void	*b_driver2;		/* for private use by the driver */
	void	*b_caller1;		/* for private use by the caller */
	void	*b_caller2;		/* for private use by the caller */
	union	pager_info {
		void	*pg_spc;
		int	pg_reqpage;
	} b_pager;
	union	cluster_info {
		TAILQ_HEAD(cluster_list_head, buf) cluster_head;
		TAILQ_ENTRY(buf) cluster_entry;
	} b_cluster;
	struct	vm_page *b_pages[btoc(MAXPHYS)];
	int		b_npages;
	struct	workhead b_dep;		/* List of filesystem dependencies. */
	struct chain_info {		/* buffer chaining */
		struct buf *parent;
		int count;
	} b_chain;
};

#define b_spc	b_pager.pg_spc

/*
 * These flags are kept in b_flags.
 *
 * Notes:
 *
 *	B_ASYNC		VOP calls on bp's are usually async whether or not
 *			B_ASYNC is set, but some subsystems, such as NFS, like 
 *			to know what is best for the caller so they can
 *			optimize the I/O.
 *
 *	B_PAGING	Indicates that bp is being used by the paging system or
 *			some paging system and that the bp is not linked into
 *			the b_vp's clean/dirty linked lists or ref counts.
 *			Buffer vp reassignments are illegal in this case.
 *
 *	B_CACHE		This may only be set if the buffer is entirely valid.
 *			The situation where B_DELWRI is set and B_CACHE is
 *			clear MUST be committed to disk by getblk() so 
 *			B_DELWRI can also be cleared.  See the comments for
 *			getblk() in kern/vfs_bio.c.  If B_CACHE is clear,
 *			the caller is expected to clear B_ERROR|B_INVAL,
 *			set B_READ, and initiate an I/O.
 *
 *			The 'entire buffer' is defined to be the range from
 *			0 through b_bcount.
 *
 *	B_MALLOC	Request that the buffer be allocated from the malloc
 *			pool, DEV_BSIZE aligned instead of PAGE_SIZE aligned.
 *
 *	B_CLUSTEROK	This flag is typically set for B_DELWRI buffers
 *			by filesystems that allow clustering when the buffer
 *			is fully dirty and indicates that it may be clustered
 *			with other adjacent dirty buffers.  Note the clustering
 *			may not be used with the stage 1 data write under NFS
 *			but may be used for the commit rpc portion.
 *
 *	B_VMIO		Indicates that the buffer is tied into an VM object.
 *			The buffer's data is always PAGE_SIZE aligned even
 *			if b_bufsize and b_bcount are not.  ( b_bufsize is 
 *			always at least DEV_BSIZE aligned, though ).
 *	
 *	B_DIRECT	Hint that we should attempt to completely free
 *			the pages underlying the buffer.   B_DIRECT is 
 *			sticky until the buffer is released and typically
 *			only has an effect when B_RELBUF is also set.
 *
 *	B_NOWDRAIN	This flag should be set when a device (like VN)
 *			does a turn-around VOP_WRITE from its strategy
 *			routine.  This flag prevents bwrite() from blocking
 *			in wdrain, avoiding a deadlock situation.
 */

#define	B_AGE		0x00000001	/* Move to age queue when I/O done. */
#define	B_NEEDCOMMIT	0x00000002	/* Append-write in progress. */
#define	B_ASYNC		0x00000004	/* Start I/O, do not wait. */
#define	B_DIRECT	0x00000008	/* direct I/O flag (pls free vmio) */
#define	B_DEFERRED	0x00000010	/* Skipped over for cleaning */
#define	B_CACHE		0x00000020	/* Bread found us in the cache. */
#define	B_CALL		0x00000040	/* Call b_iodone from biodone. */
#define	B_DELWRI	0x00000080	/* Delay I/O until buffer reused. */
#define	B_FREEBUF	0x00000100	/* Instruct driver: free blocks */
#define	B_DONE		0x00000200	/* I/O completed. */
#define	B_EINTR		0x00000400	/* I/O was interrupted */
#define	B_ERROR		0x00000800	/* I/O error occurred. */
#define	B_SCANNED	0x00001000	/* VOP_FSYNC funcs mark written bufs */
#define	B_INVAL		0x00002000	/* Does not contain valid info. */
#define	B_LOCKED	0x00004000	/* Locked in core (not reusable). */
#define	B_NOCACHE	0x00008000	/* Do not cache block after use. */
#define	B_MALLOC	0x00010000	/* malloced b_data */
#define	B_CLUSTEROK	0x00020000	/* Pagein op, so swap() can count it. */
#define	B_PHYS		0x00040000	/* I/O to user memory. */
#define	B_RAW		0x00080000	/* Set by physio for raw transfers. */
#define	B_READ		0x00100000	/* Read buffer. */
#define	B_DIRTY		0x00200000	/* Needs writing later. */
#define	B_RELBUF	0x00400000	/* Release VMIO buffer. */
#define	B_WANT		0x00800000	/* Used by vm_pager.c */
#define	B_WRITE		0x00000000	/* Write buffer (pseudo flag). */
#define	B_WRITEINPROG	0x01000000	/* Write in progress. */
#define	B_XXX		0x02000000	/* Debugging flag. */
#define	B_PAGING	0x04000000	/* volatile paging I/O -- bypass VMIO */
#define	B_ORDERED	0x08000000	/* Must guarantee I/O ordering */
#define B_RAM		0x10000000	/* Read ahead mark (flag) */
#define B_VMIO		0x20000000	/* VMIO flag */
#define B_CLUSTER	0x40000000	/* pagein op, so swap() can count it */
#define B_NOWDRAIN	0x80000000	/* Avoid wdrain deadlock */

#define PRINT_BUF_FLAGS "\20\40nowdrain\37cluster\36vmio\35ram\34ordered" \
	"\33paging\32xxx\31writeinprog\30want\27relbuf\26dirty" \
	"\25read\24raw\23phys\22clusterok\21malloc\20nocache" \
	"\17locked\16inval\15scanned\14error\13eintr\12done\11freebuf" \
	"\10delwri\7call\6cache\4direct\3async\2needcommit\1age"

/*
 * These flags are kept in b_xflags.
 */
#define	BX_VNDIRTY	0x00000001	/* On vnode dirty list */
#define	BX_VNCLEAN	0x00000002	/* On vnode clean list */
#define	BX_BKGRDWRITE	0x00000004	/* Do writes in background */
#define	BX_BKGRDINPROG	0x00000008	/* Background write in progress */
#define	BX_BKGRDWAIT	0x00000010	/* Background write waiting */
#define BX_AUTOCHAINDONE 0x00000020	/* pager I/O chain auto mode */

#define	NOOFFSET	(-1LL)		/* No buffer offset calculated yet */

#ifdef _KERNEL
/*
 * Buffer locking
 */
struct simplelock buftimelock;		/* Interlock on setting prio and timo */
extern char *buf_wmesg;			/* Default buffer lock message */
#define BUF_WMESG "bufwait"
#include <sys/proc.h>			/* XXX for curproc */
/*
 * Initialize a lock.
 */
#define BUF_LOCKINIT(bp) \
	lockinit(&(bp)->b_lock, PRIBIO + 4, buf_wmesg, 0, 0)
/*
 *
 * Get a lock sleeping non-interruptably until it becomes available.
 */
static __inline int BUF_LOCK __P((struct buf *, int));
static __inline int
BUF_LOCK(struct buf *bp, int locktype)
{
	int s, ret;

	s = splbio();
	simple_lock(&buftimelock);
	locktype |= LK_INTERLOCK;
	bp->b_lock.lk_wmesg = buf_wmesg;
	bp->b_lock.lk_prio = PRIBIO + 4;
	/* bp->b_lock.lk_timo = 0;   not necessary */
	ret = lockmgr(&(bp)->b_lock, locktype, &buftimelock, curproc);
	splx(s);
	return ret;
}
/*
 * Get a lock sleeping with specified interruptably and timeout.
 */
static __inline int BUF_TIMELOCK __P((struct buf *, int, char *, int, int));
static __inline int
BUF_TIMELOCK(struct buf *bp, int locktype, char *wmesg, int catch, int timo)
{
	int s, ret;

	s = splbio();
	simple_lock(&buftimelock);
	locktype |= LK_INTERLOCK | LK_TIMELOCK;
	bp->b_lock.lk_wmesg = wmesg;
	bp->b_lock.lk_prio = (PRIBIO + 4) | catch;
	bp->b_lock.lk_timo = timo;
	ret = lockmgr(&(bp)->b_lock, (locktype), &buftimelock, curproc);
	splx(s);
	return ret;
}
/*
 * Release a lock. Only the acquiring process may free the lock unless
 * it has been handed off to biodone.
 */
static __inline void BUF_UNLOCK __P((struct buf *));
static __inline void
BUF_UNLOCK(struct buf *bp)
{
	int s;

	s = splbio();
	lockmgr(&(bp)->b_lock, LK_RELEASE, NULL, curproc);
	splx(s);
}

/*
 * Free a buffer lock.
 */
#define BUF_LOCKFREE(bp) 			\
	if (BUF_REFCNT(bp) > 0)			\
		panic("free locked buf")
/*
 * When initiating asynchronous I/O, change ownership of the lock to the
 * kernel. Once done, the lock may legally released by biodone. The
 * original owning process can no longer acquire it recursively, but must
 * wait until the I/O is completed and the lock has been freed by biodone.
 */
static __inline void BUF_KERNPROC __P((struct buf *));
static __inline void
BUF_KERNPROC(struct buf *bp)
{
	struct proc *p = curproc;

	if (p != NULL && bp->b_lock.lk_lockholder == p->p_pid)
		p->p_locks--;
	bp->b_lock.lk_lockholder = LK_KERNPROC;
}
/*
 * Find out the number of references to a lock.
 */
static __inline int BUF_REFCNT __P((struct buf *));
static __inline int
BUF_REFCNT(struct buf *bp)
{
	int s, ret;

	s = splbio();
	ret = lockcount(&(bp)->b_lock);
	splx(s);
	return ret;
}

#endif /* _KERNEL */

struct buf_queue_head {
	TAILQ_HEAD(buf_queue, buf) queue;
	daddr_t	last_pblkno;
	struct	buf *insert_point;
	struct	buf *switch_point;
};

/*
 * This structure describes a clustered I/O.  It is stored in the b_saveaddr
 * field of the buffer on which I/O is done.  At I/O completion, cluster
 * callback uses the structure to parcel I/O's to individual buffers, and
 * then free's this structure.
 */
struct cluster_save {
	long	bs_bcount;		/* Saved b_bcount. */
	long	bs_bufsize;		/* Saved b_bufsize. */
	void	*bs_saveaddr;		/* Saved b_addr. */
	int	bs_nchildren;		/* Number of associated buffers. */
	struct buf **bs_children;	/* List of associated buffers. */
};

#ifdef _KERNEL
static __inline void bufq_init __P((struct buf_queue_head *head));

static __inline void bufq_insert_tail __P((struct buf_queue_head *head,
					   struct buf *bp));

static __inline void bufq_remove __P((struct buf_queue_head *head,
				      struct buf *bp));

static __inline struct buf *bufq_first __P((struct buf_queue_head *head));

static __inline void
bufq_init(struct buf_queue_head *head)
{
	TAILQ_INIT(&head->queue);
	head->last_pblkno = 0;
	head->insert_point = NULL;
	head->switch_point = NULL;
}

static __inline void
bufq_insert_tail(struct buf_queue_head *head, struct buf *bp)
{
	if ((bp->b_flags & B_ORDERED) != 0) {
		head->insert_point = bp;
		head->switch_point = NULL;
	}
	TAILQ_INSERT_TAIL(&head->queue, bp, b_act);
}

static __inline void
bufq_remove(struct buf_queue_head *head, struct buf *bp)
{
	if (bp == head->switch_point)
		head->switch_point = TAILQ_NEXT(bp, b_act);
	if (bp == head->insert_point) {
		head->insert_point = TAILQ_PREV(bp, buf_queue, b_act);
		if (head->insert_point == NULL)
			head->last_pblkno = 0;
	} else if (bp == TAILQ_FIRST(&head->queue))
		head->last_pblkno = bp->b_pblkno;
	TAILQ_REMOVE(&head->queue, bp, b_act);
	if (TAILQ_FIRST(&head->queue) == head->switch_point)
		head->switch_point = NULL;
}

static __inline struct buf *
bufq_first(struct buf_queue_head *head)
{
	return (TAILQ_FIRST(&head->queue));
}

#endif /* _KERNEL */

/*
 * Definitions for the buffer free lists.
 */
#define BUFFER_QUEUES	6	/* number of free buffer queues */

#define QUEUE_NONE	0	/* on no queue */
#define QUEUE_LOCKED	1	/* locked buffers */
#define QUEUE_CLEAN	2	/* non-B_DELWRI buffers */
#define QUEUE_DIRTY	3	/* B_DELWRI buffers */
#define QUEUE_EMPTYKVA	4	/* empty buffer headers w/KVA assignment */
#define QUEUE_EMPTY	5	/* empty buffer headers */

/*
 * Zero out the buffer's data area.
 */
#define	clrbuf(bp) {							\
	bzero((bp)->b_data, (u_int)(bp)->b_bcount);			\
	(bp)->b_resid = 0;						\
}

/* Flags to low-level allocation routines. */
#define B_CLRBUF	0x01	/* Request allocated buffer be cleared. */
#define B_SYNC		0x02	/* Do all allocations synchronously. */

#ifdef _KERNEL
extern int	nbuf;			/* The number of buffer headers */
extern int	maxswzone;		/* Max KVA for swap structures */
extern int	maxbcache;		/* Max KVA for buffer cache */
extern int	runningbufspace;
extern int      buf_maxio;              /* nominal maximum I/O for buffer */
extern struct	buf *buf;		/* The buffer headers. */
extern char	*buffers;		/* The buffer contents. */
extern int	bufpages;		/* Number of memory pages in the buffer pool. */
extern struct	buf *swbuf;		/* Swap I/O buffer headers. */
extern int	nswbuf;			/* Number of swap I/O buffer headers. */
extern TAILQ_HEAD(swqueue, buf) bswlist;
extern TAILQ_HEAD(bqueues, buf) bufqueues[BUFFER_QUEUES];

struct uio;

caddr_t bufhashinit __P((caddr_t));
void	bufinit __P((void));
void	bwillwrite __P((void));
int	buf_dirty_count_severe __P((void));
void	bremfree __P((struct buf *));
int	bread __P((struct vnode *, daddr_t, int,
	    struct ucred *, struct buf **));
int	breadn __P((struct vnode *, daddr_t, int, daddr_t *, int *, int,
	    struct ucred *, struct buf **));
int	bwrite __P((struct buf *));
void	bdwrite __P((struct buf *));
void	bawrite __P((struct buf *));
void	bdirty __P((struct buf *));
void	bundirty __P((struct buf *));
int	bowrite __P((struct buf *));
void	brelse __P((struct buf *));
void	bqrelse __P((struct buf *));
int	vfs_bio_awrite __P((struct buf *));
struct buf *     getpbuf __P((int *));
struct buf *incore __P((struct vnode *, daddr_t));
struct buf *gbincore __P((struct vnode *, daddr_t));
int	inmem __P((struct vnode *, daddr_t));
struct buf *getblk __P((struct vnode *, daddr_t, int, int, int));
struct buf *geteblk __P((int));
int	biowait __P((struct buf *));
void	biodone __P((struct buf *));

void	cluster_callback __P((struct buf *));
int	cluster_read __P((struct vnode *, u_quad_t, daddr_t, long,
	    struct ucred *, long, int, struct buf **));
int	cluster_wbuild __P((struct vnode *, long, daddr_t, int));
void	cluster_write __P((struct buf *, u_quad_t, int));
int	physio __P((dev_t dev, struct uio *uio, int ioflag));
#define physread physio
#define physwrite physio
void	vfs_bio_set_validclean __P((struct buf *, int base, int size));
void	vfs_bio_clrbuf __P((struct buf *));
void	vfs_busy_pages __P((struct buf *, int clear_modify));
void	vfs_unbusy_pages __P((struct buf *));
void	vwakeup __P((struct buf *));
void	vmapbuf __P((struct buf *));
void	vunmapbuf __P((struct buf *));
void	relpbuf __P((struct buf *, int *));
void	brelvp __P((struct buf *));
void	bgetvp __P((struct vnode *, struct buf *));
void	pbgetvp __P((struct vnode *, struct buf *));
void	pbrelvp __P((struct buf *));
int	allocbuf __P((struct buf *bp, int size));
void	reassignbuf __P((struct buf *, struct vnode *));
void	pbreassignbuf __P((struct buf *, struct vnode *));
struct	buf *trypbuf __P((int *));

#endif /* _KERNEL */

#endif /* !_SYS_BUF_H_ */
