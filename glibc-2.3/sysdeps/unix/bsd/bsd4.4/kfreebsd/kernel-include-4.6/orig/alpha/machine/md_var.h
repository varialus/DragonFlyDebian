/*-
 * Copyright (c) 1998 Doug Rabson
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
 * $FreeBSD: src/sys/alpha/include/md_var.h,v 1.9.2.2 2000/07/04 01:50:44 mjacob Exp $
 */

#ifndef _MACHINE_MD_VAR_H_
#define	_MACHINE_MD_VAR_H_

/*
 * Miscellaneous machine-dependent declarations.
 */

extern	char	sigcode[];
extern	char	esigcode[];
extern	int	szsigcode;
extern	int	Maxmem;
extern	int	busdma_swi_pending;
extern	void	(*netisrs[32]) __P((void));

struct fpreg;
struct proc;
struct reg;
struct cam_sim;
struct pcicfg;

void	busdma_swi __P((void));
void	cpu_halt __P((void));
void	cpu_reset __P((void));
int	is_physical_memory __P((vm_offset_t addr));
void	swi_vm __P((void));
int	vm_page_zero_idle __P((void));
int	fill_regs __P((struct proc *, struct reg *));
int	set_regs __P((struct proc *, struct reg *));
int	fill_fpregs __P((struct proc *, struct fpreg *));
int	set_fpregs __P((struct proc *, struct fpreg *));
void	alpha_register_pci_scsi __P((int bus, int slot, struct cam_sim *sim));
#ifdef _SYS_BUS_H_
struct resource *alpha_platform_alloc_ide_intr(int chan);
int	alpha_platform_release_ide_intr(int chan, struct resource *res);
int	alpha_platform_setup_ide_intr(struct resource *res,
				      driver_intr_t *fn, void *arg,
				      void **cookiep);
int	alpha_platform_teardown_ide_intr(struct resource *res, void *cookie);
int	alpha_platform_pci_setup_intr(device_t dev, device_t child,
				      struct resource *irq,  int flags,
				      driver_intr_t *intr, void *arg,
				      void **cookiep);
int	alpha_platform_pci_teardown_intr(device_t dev, device_t child,
					 struct resource *irq, void *cookie);
#endif
void	alpha_platform_assign_pciintr(struct pcicfg *cfg);

#endif /* !_MACHINE_MD_VAR_H_ */
