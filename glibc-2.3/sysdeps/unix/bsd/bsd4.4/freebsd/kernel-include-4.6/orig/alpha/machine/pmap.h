/*
 * Copyright (c) 1991 Regents of the University of California.
 * All rights reserved.
 *
 * This code is derived from software contributed to Berkeley by
 * the Systems Programming Group of the University of Utah Computer
 * Science Department and William Jolitz of UUNET Technologies Inc.
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
 * Derived from hp300 version by Mike Hibler, this version by William
 * Jolitz uses a recursive map [a pde points to the page directory] to
 * map the page tables using the pagetables themselves. This is done to
 * reduce the impact on kernel virtual memory for lots of sparse address
 * space, and to reduce the cost of memory to each process.
 *
 *	from: hp300: @(#)pmap.h	7.2 (Berkeley) 12/16/90
 *	from: @(#)pmap.h	7.4 (Berkeley) 5/12/91
 *	from: i386 pmap.h,v 1.54 1997/11/20 19:30:35 bde Exp
 * $FreeBSD: src/sys/alpha/include/pmap.h,v 1.6.2.1 2000/08/04 22:31:05 peter Exp $
 */

#ifndef _MACHINE_PMAP_H_
#define	_MACHINE_PMAP_H_

/*
 * Define meanings for a few software bits in the pte
 */
#define	PG_V		ALPHA_PTE_VALID
#define	PG_FOR		ALPHA_PTE_FAULT_ON_READ
#define	PG_FOW		ALPHA_PTE_FAULT_ON_WRITE
#define	PG_FOE		ALPHA_PTE_FAULT_ON_EXECUTE
#define	PG_ASM		ALPHA_PTE_ASM
#define	PG_GH		ALPHA_PTE_GRANULARITY
#define	PG_KRE		ALPHA_PTE_KR
#define	PG_URE		ALPHA_PTE_UR
#define	PG_KWE		ALPHA_PTE_KW
#define	PG_UWE		ALPHA_PTE_UW
#define	PG_PROT		ALPHA_PTE_PROT
#define PG_SHIFT	32

#define PG_W		0x00010000 /* software wired */
#define PG_MANAGED	0x00020000 /* software managed */

/*
 * Pte related macros
 */
#define VADDR(l1, l2, l3)	(((l1) << ALPHA_L1SHIFT)	\
				 + ((l2) << ALPHA_L2SHIFT)	\
				 + ((l3) << ALPHA_L3SHIFT)

#ifndef NKPT
#define	NKPT			9	/* initial number of kernel page tables */
#endif
#define NKLEV2MAPS		255	/* max number of lev2 page tables */
#define NKLEV3MAPS		(NKLEV2MAPS << ALPHA_PTSHIFT) /* max number of lev3 page tables */

/*
 * The *PTDI values control the layout of virtual memory
 *
 * XXX This works for now, but I am not real happy with it, I'll fix it
 * right after I fix locore.s and the magic 28K hole
 *
 * SMP_PRIVPAGES: The per-cpu address space is 0xff80000 -> 0xffbfffff
 */
#define PTLEV1I		(NPTEPG-1)	/* Lev0 entry that points to Lev0 */
#define K0SEGLEV1I	(NPTEPG/2)
#define K1SEGLEV1I	(K0SEGLEV1I+(NPTEPG/4))

#define NUSERLEV2MAPS	(NPTEPG/2)
#define NUSERLEV3MAPS	(NUSERLEV2MAPS << ALPHA_PTSHIFT)

#ifndef LOCORE

#include <sys/queue.h>

typedef alpha_pt_entry_t pt_entry_t;

#define PTESIZE		sizeof(pt_entry_t) /* for assembly files */

/*
 * Address of current address space page table maps
 */
#ifdef _KERNEL
extern pt_entry_t PTmap[];	/* lev3 page tables */
extern pt_entry_t PTlev2[];	/* lev2 page tables */
extern pt_entry_t PTlev1[];	/* lev1 page table */
extern pt_entry_t PTlev1pte;	/* pte that maps lev1 page table */
#endif

#ifdef _KERNEL
/*
 * virtual address to page table entry and
 * to physical address.
 * Note: this work recursively, thus vtopte of a pte will give
 * the corresponding lev1 that in turn maps it.
 */
#define	vtopte(va)	(PTmap + (alpha_btop(va) \
				  & ((1 << 3*ALPHA_PTSHIFT)-1)))

/*
 *	Routine:	pmap_kextract
 *	Function:
 *		Extract the physical page address associated
 *		kernel virtual address.
 */
static __inline vm_offset_t
pmap_kextract(vm_offset_t va)
{
	vm_offset_t pa;
	if (va >= ALPHA_K0SEG_BASE && va <= ALPHA_K0SEG_END)
		pa = ALPHA_K0SEG_TO_PHYS(va);
	else
		pa = alpha_ptob(ALPHA_PTE_TO_PFN(*vtopte(va)))
			| (va & PAGE_MASK);
	return pa;
}

#define	vtophys(va)	pmap_kextract(((vm_offset_t) (va)))

extern vm_offset_t alpha_XXX_dmamap_or;

static __inline vm_offset_t
alpha_XXX_dmamap(vm_offset_t va)
{
       return (pmap_kextract(va) | alpha_XXX_dmamap_or);
}

#endif /* _KERNEL */

/*
 * Pmap stuff
 */
struct	pv_entry;

struct md_page {
	int pv_list_count;
	int			pv_flags;
	TAILQ_HEAD(,pv_entry)	pv_list;
};

#define PV_TABLE_MOD		0x01 /* modified */
#define PV_TABLE_REF		0x02 /* referenced */

struct pmap {
	pt_entry_t		*pm_lev1;	/* KVA of lev0map */
	vm_object_t		pm_pteobj;	/* Container for pte's */
	TAILQ_HEAD(,pv_entry)	pm_pvlist;	/* list of mappings in pmap */
	int			pm_count;	/* reference count */
	int			pm_flags;	/* pmap flags */
	int			pm_active;	/* active flag */
	int			pm_asn;		/* address space number */
	u_int			pm_asngen;	/* generation number of pm_asn */
	struct pmap_statistics	pm_stats;	/* pmap statistics */
	struct	vm_page		*pm_ptphint;	/* pmap ptp hint */
};

#define pmap_resident_count(pmap) (pmap)->pm_stats.resident_count

#define PM_FLAG_LOCKED	0x1
#define PM_FLAG_WANTED	0x2

typedef struct pmap	*pmap_t;

#ifdef _KERNEL
extern pmap_t		kernel_pmap;
#endif

/*
 * For each vm_page_t, there is a list of all currently valid virtual
 * mappings of that page.  An entry is a pv_entry_t, the list is pv_table.
 */
typedef struct pv_entry {
	pmap_t		pv_pmap;	/* pmap where mapping lies */
	vm_offset_t	pv_va;		/* virtual address for mapping */
	TAILQ_ENTRY(pv_entry)	pv_list;
	TAILQ_ENTRY(pv_entry)	pv_plist;
	vm_page_t	pv_ptem;	/* VM page for pte */
} *pv_entry_t;

#define	PV_ENTRY_NULL	((pv_entry_t) 0)

#define	PV_CI		0x01	/* all entries must be cache inhibited */
#define	PV_PTPAGE	0x02	/* entry maps a page table page */

#ifdef	_KERNEL

extern caddr_t	CADDR1;
extern pt_entry_t *CMAP1;
extern vm_offset_t avail_end;
extern vm_offset_t avail_start;
extern vm_offset_t clean_eva;
extern vm_offset_t clean_sva;
extern vm_offset_t phys_avail[];
extern char *ptvmmap;		/* poor name! */
extern vm_offset_t virtual_avail;
extern vm_offset_t virtual_end;

vm_offset_t pmap_steal_memory __P((vm_size_t));
void	pmap_bootstrap __P((vm_offset_t, u_int));
void	pmap_setdevram __P((unsigned long long basea, vm_offset_t sizea));
int	pmap_uses_prom_console __P((void));
pmap_t	pmap_kernel __P((void));
void	*pmap_mapdev __P((vm_offset_t, vm_size_t));
unsigned *pmap_pte __P((pmap_t, vm_offset_t)) __pure2;
vm_page_t pmap_use_pt __P((pmap_t, vm_offset_t));
void	pmap_set_opt	__P((unsigned *));
void	pmap_set_opt_bsp	__P((void));
void	pmap_deactivate __P((struct proc *p));
void	pmap_emulate_reference __P((struct proc *p, vm_offset_t v, int user, int write));

#endif /* _KERNEL */

#endif /* !LOCORE */

#endif /* !_MACHINE_PMAP_H_ */
