/* Machine-dependent ELF dynamic relocation inline functions.
   FreeBSD i386 specific version of dl_platform_init()
   Copyright (C) 2006 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by Petr Salinger, 2006.

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


/* For FreeBSD we redefine an initialization function.
   This is called very early in dl_sysdep_start.  */

#if 0
Under FreeBSD:
#define AT_EXECPATH     15      /* Path to the executable. */

Under Linux:
#define AT_PLATFORM     15      /* String identifying platform.  */

Filled entries from kernel:

        if (args->execfd != -1)
                AUXARGS_ENTRY(pos, AT_EXECFD, args->execfd);
        AUXARGS_ENTRY(pos, AT_PHDR, args->phdr);    
        AUXARGS_ENTRY(pos, AT_PHENT, args->phent);  
        AUXARGS_ENTRY(pos, AT_PHNUM, args->phnum);  
        AUXARGS_ENTRY(pos, AT_PAGESZ, args->pagesz);
        AUXARGS_ENTRY(pos, AT_FLAGS, args->flags);
        AUXARGS_ENTRY(pos, AT_ENTRY, args->entry);
        AUXARGS_ENTRY(pos, AT_BASE, args->base);
        if (imgp->execpathp != 0)
                AUXARGS_ENTRY(pos, AT_EXECPATH, imgp->execpathp);
        AUXARGS_ENTRY(pos, AT_NULL, 0);
                                                                                                                
#endif

#include_next <dl-machine.h>

#undef  DL_PLATFORM_INIT
#define DL_PLATFORM_INIT dl_platform_kfreebsd_i386_init ()

#ifndef _DL_MACHINE_KFREEBSD
#define _DL_MACHINE_KFREEBSD

#define X86_EFLAGS_AC   0x00040000 /* Alignment Check */
#define X86_EFLAGS_ID   0x00200000 /* CPUID detection flag */

static inline int try_flip_flags(int val)
{
    int ret;
    __asm__(
	"pushfl\n\t"
	"pushfl\n\t"
	"popl %%ecx\n\t"
	"xorl %%ecx,%%eax\n\t"
	"pushl %%eax\n\t"
	"popfl\n\t"
	"pushfl\n\t"
	"popl %%eax\n\t"
	"xorl %%ecx,%%eax\n\t"
	"popfl\n\t"
	: "=a" (ret)
	: "0" (val)
        : "cx"
    );
    return ret;
}

static inline void cpuid(int op, int *eax, int *edx)
{
    __asm__(
	"push %%ebx\n\t"
	"cpuid\n\t"
	"pop %%ebx\n\t"
	: "=a" (*eax),
	  "=d" (*edx)
	: "0" (op)
	: "cx"
    );
}

static inline void __attribute__ ((unused))
dl_platform_kfreebsd_i386_init (void)
{
	/* we don't have reasonable AT_PLATFORM from kernel
	   try to use cpuid to get one, also guess AT_HWCAP */

	int val, hwcap;

	val = try_flip_flags(X86_EFLAGS_AC | X86_EFLAGS_ID);

	if (!(val & X86_EFLAGS_AC))
	{
		/* 386 */
		GLRO(dl_platform) = GLRO(dl_x86_platforms)[0];
		GLRO(dl_hwcap) = 0;
	}
	else if (!(val & X86_EFLAGS_ID))
	{
		/* 486 */
		GLRO(dl_platform) = GLRO(dl_x86_platforms)[1];
		GLRO(dl_hwcap) = 0;
	}
	else
	{
	    cpuid(0, &val, &hwcap);
	    if (val == 0)
	    {
		/* 486 */
		GLRO(dl_platform) = GLRO(dl_x86_platforms)[1];
		GLRO(dl_hwcap) = 0;
	    }
	    else
	    {
		cpuid(1, &val, &hwcap);
		GLRO(dl_hwcap) = hwcap;
		switch (val & 0xf00)
		{
		case 0x400: /* 486 */
			GLRO(dl_platform) = GLRO(dl_x86_platforms)[1];
		break;
		case 0x500: /* 586 */
			GLRO(dl_platform) = GLRO(dl_x86_platforms)[2];
		break;
		default:    /* 686 */
			GLRO(dl_platform) = GLRO(dl_x86_platforms)[3];
		}
            }
	}
}

#endif
