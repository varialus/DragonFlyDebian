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
 * $FreeBSD: src/sys/i386/include/pmap.h,v 1.65.2.3 2001/10/03 07:15:37 peter Exp $
 */

#ifndef _MACHINE_PMAP_H_
#define	_MACHINE_PMAP_H_

/*
 * Page-directory and page-table entires follow this format, with a few
 * of the fields not present here and there, depending on a lot of things.
 */
				/* ---- Intel Nomenclature ---- */
#define	PG_V		0x001	/* P	Valid			*/
#define PG_RW		0x002	/* R/W	Read/Write		*/
#define PG_U		0x004	/* U/S  User/Supervisor		*/
#define	PG_NC_PWT	0x008	/* PWT	Write through		*/
#define	PG_NC_PCD	0x010	/* PCD	Cache disable		*/
#define PG_A		0x020	/* A	Accessed		*/
#define	PG_M		0x040	/* D	Dirty			*/
#define	PG_PS		0x080	/* PS	Page size (0=4k,1=4M)	*/
#define	PG_G		0x100	/* G	Global			*/
#define	PG_AVAIL1	0x200	/*    /	Available for system	*/
#define	PG_AVAIL2	0x400	/*   <	programmers use		*/
#define	PG_AVAIL3	0x800	/*    \				*/


/* Our various interpretations of the above */
#define PG_W		PG_AVAIL1	/* "Wired" pseudoflag */
#define	PG_MANAGED	PG_AVAIL2
#define	PG_FRAME	(~PAGE_MASK)
#define	PG_PROT		(PG_RW|PG_U)	/* all protection bits . */
#define PG_N		(PG_NC_PWT|PG_NC_PCD)	/* Non-cacheable */

/*
 * Page Protection Exception bits
 */

#define PGEX_P		0x01	/* Protection violation vs. not present */
#define PGEX_W		0x02	/* during a Write cycle */
#define PGEX_U		0x04	/* access from User mode (UPL) */

/*
 * Size of Kernel address space.  This is the number of page table pages
 * (4MB each) to use for the kernel.  256 pages == 1 Gigabyte.
 * This **MUST** be a multiple of 4 (eg: 252, 256, 260, etc).
 */
#ifndef KVA_PAGES
#define KVA_PAGES	256
#endif

/*
 * Pte related macros
 */
#define VADDR(pdi, pti) ((vm_offset_t)(((pdi)<<PDRSHIFT)|((pti)<<PAGE_SHIFT)))

#ifndef NKPT
#define	NKPT		30	/* actual number of kernel page tables */
#endif
#ifndef NKPDE
#ifdef SMP
#define NKPDE	(KVA_PAGES - 2)	/* addressable number of page tables/pde's */
#else
#define NKPDE	(KVA_PAGES - 1)	/* addressable number of page tables/pde's */
#endif
#endif

/*
 * The *PTDI values control the layout of virtual memory
 *
 * XXX This works for now, but I am not real happy with it, I'll fix it
 * right after I fix locore.s and the magic 28K hole
 *
 * SMP_PRIVPAGES: The per-cpu address space is 0xff80000 -> 0xffbfffff
 */
#define	APTDPTDI	(NPDEPG-1)	/* alt ptd entry that points to APTD */
#ifdef SMP
#define MPPTDI		(APTDPTDI-1)	/* per cpu ptd entry */
#define	KPTDI		(MPPTDI-NKPDE)	/* start of kernel virtual pde's */
#else
#define	KPTDI		(APTDPTDI-NKPDE)/* start of kernel virtual pde's */
#endif	/* SMP */
#define	PTDPTDI		(KPTDI-1)	/* ptd entry that points to ptd! */
#define	UMAXPTDI	(PTDPTDI-1)	/* ptd entry for user space end */
#define	UMAXPTEOFF	(NPTEPG)	/* pte entry for user space end */

/*
 * XXX doesn't really belong here I guess...
 */
#define ISA_HOLE_START    0xa0000
#define ISA_HOLE_LENGTH (0x100000-ISA_HOLE_START)

#ifndef LOCORE

#include <sys/queue.h>

typedef unsigned int *pd_entry_t;
typedef unsigned int *pt_entry_t;

#define PDESIZE		sizeof(pd_entry_t) /* for assembly files */
#define PTESIZE		sizeof(pt_entry_t) /* for assembly files */

/*
 * Address of current and alternate address space page table maps
 * and directories.
 */
#ifdef _KERNEL
extern pt_entry_t PTmap[], APTmap[], Upte;
extern pd_entry_t PTD[], APTD[], PTDpde, APTDpde, Upde;

extern pd_entry_t IdlePTD;	/* physical address of "Idle" state directory */
#endif

#ifdef _KERNEL
/*
 * virtual address to page table entry and
 * to physical address. Likewise for alternate address space.
 * Note: these work recursively, thus vtopte of a pte will give
 * the corresponding pde that in turn maps it.
 */
#define	vtopte(va)	(PTmap + i386_btop(va))

#define	avtopte(va)	(APTmap + i386_btop(va))

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
	if ((pa = (vm_offset_t) PTD[va >> PDRSHIFT]) & PG_PS) {
		pa = (pa & ~(NBPDR - 1)) | (va & (NBPDR - 1));
	} else {
		pa = *(vm_offset_t *)vtopte(va);
		pa = (pa & PG_FRAME) | (va & PAGE_MASK);
	}
	return pa;
}

#if 0
#define	vtophys(va)	(((vm_offset_t) (*vtopte(va))&PG_FRAME) | ((vm_offset_t)(va) & PAGE_MASK))
#else
#define	vtophys(va)	pmap_kextract(((vm_offset_t) (va)))
#endif

#define	avtophys(va)	(((vm_offset_t) (*avtopte(va))&PG_FRAME) | ((vm_offset_t)(va) & PAGE_MASK))

#endif

/*
 * Pmap stuff
 */
struct	pv_entry;

struct md_page {
	int pv_list_count;
	TAILQ_HEAD(,pv_entry)	pv_list;
};

struct pmap {
	pd_entry_t		*pm_pdir;	/* KVA of page directory */
	vm_object_t		pm_pteobj;	/* Container for pte's */
	TAILQ_HEAD(,pv_entry)	pm_pvlist;	/* list of mappings in pmap */
	int			pm_count;	/* reference count */
	int			pm_active;	/* active on cpus */
	struct pmap_statistics	pm_stats;	/* pmap statistics */
	struct	vm_page		*pm_ptphint;	/* pmap ptp hint */
};

#define pmap_resident_count(pmap) (pmap)->pm_stats.resident_count

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

#define NPPROVMTRR		8
#define PPRO_VMTRRphysBase0	0x200
#define PPRO_VMTRRphysMask0	0x201
struct ppro_vmtrr {
	u_int64_t base, mask;
};
extern struct ppro_vmtrr PPro_vmtrr[NPPROVMTRR];

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

void	pmap_bootstrap __P(( vm_offset_t, vm_offset_t));
pmap_t	pmap_kernel __P((void));
void	*pmap_mapdev __P((vm_offset_t, vm_size_t));
void	pmap_unmapdev __P((vm_offset_t, vm_size_t));
unsigned *pmap_pte __P((pmap_t, vm_offset_t)) __pure2;
vm_page_t pmap_use_pt __P((pmap_t, vm_offset_t));
#ifdef SMP
void	pmap_set_opt __P((void));
#endif

#endif /* _KERNEL */

#endif /* !LOCORE */

#endif /* !_MACHINE_PMAP_H_ */
