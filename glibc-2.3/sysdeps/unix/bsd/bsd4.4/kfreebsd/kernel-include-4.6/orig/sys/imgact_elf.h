/*-
 * Copyright (c) 1995-1996 S�ren Schmidt
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer
 *    in this position and unchanged.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software withough specific prior written permission
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * $FreeBSD: src/sys/sys/imgact_elf.h,v 1.17.2.1 2000/07/06 22:26:40 obrien Exp $
 */

#ifndef _SYS_IMGACT_ELF_H_
#define _SYS_IMGACT_ELF_H_

#include <machine/elf.h>

#ifdef _KERNEL

#define AUXARGS_ENTRY(pos, id, val) {suword(pos++, id); suword(pos++, val);}

#if ELF_TARG_CLASS == ELFCLASS32

/*
 * Structure used to pass infomation from the loader to the
 * stack fixup routine.
 */
typedef struct {
	Elf32_Sword	execfd;
	Elf32_Word	phdr;
	Elf32_Word	phent;
	Elf32_Word	phnum;
	Elf32_Word	pagesz;
	Elf32_Word	base;
	Elf32_Word	flags;
	Elf32_Word	entry;
	Elf32_Word	trace;
} Elf32_Auxargs;

typedef struct {
	int brand;
	const char *compat_3_brand;	/* pre Binutils 2.10 method (FBSD 3) */
	const char *emul_path;
	const char *interp_path;
        struct sysentvec *sysvec;
} Elf32_Brandinfo;

#define MAX_BRANDS      8

int	elf_brand_inuse        __P((Elf32_Brandinfo *entry));
int	elf_insert_brand_entry __P((Elf32_Brandinfo *entry));
int	elf_remove_brand_entry __P((Elf32_Brandinfo *entry));

#else /* !(ELF_TARG_CLASS == ELFCLASS32) */

/*
 * Structure used to pass infomation from the loader to the
 * stack fixup routine.
 */
typedef struct {
	Elf64_Sword	execfd;
	Elf64_Addr	phdr;
	Elf64_Word	phent;
	Elf64_Word	phnum;
	Elf64_Word	pagesz;
	Elf64_Addr	base;
	Elf64_Word	flags;
	Elf64_Addr	entry;
	Elf64_Word	trace;
} Elf64_Auxargs;

typedef struct {
	int brand;
	const char *compat_3_brand;	/* pre Binutils 2.10 method (FBSD 3) */
	const char *emul_path;
	const char *interp_path;
        struct sysentvec *sysvec;
} Elf64_Brandinfo;

#define MAX_BRANDS      8

int	elf_brand_inuse        __P((Elf64_Brandinfo *entry));
int	elf_insert_brand_entry __P((Elf64_Brandinfo *entry));
int	elf_remove_brand_entry __P((Elf64_Brandinfo *entry));

#endif /* ELF_TARG_CLASS == ELFCLASS32 */

struct proc;

int	elf_coredump __P((struct proc *, struct vnode *, off_t));

#endif /* _KERNEL */

#endif /* !_SYS_IMGACT_ELF_H_ */
