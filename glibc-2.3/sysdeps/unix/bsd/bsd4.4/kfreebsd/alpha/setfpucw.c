/* Set FP exception mask and rounding mode.
   Copyright (C) 1996, 1997, 1998, 2002 Free Software Foundation, Inc.
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

#include <fpu_control.h>
#include <fpu.h>

extern unsigned long __ieee_get_fp_control (void);
extern void __ieee_set_fp_control (unsigned long);


static inline unsigned long
rdfpcr (void)
{
  unsigned long fpcr;
  asm ("excb; mf_fpcr %0" : "=f"(fpcr));
  return fpcr;
}

static inline void
wrfpcr (unsigned long fpcr)
{
  asm volatile ("mt_fpcr %0; excb" : : "f"(fpcr));
}


void
__setfpucw (fpu_control_t fpu_control)
{
  if (!fpu_control)
    fpu_control = _FPU_DEFAULT;

  /* Note that the fpu_control argument, as defined in <fpu_control.h>,
     consists of bits that are not directly related to the bits of the
     fpcr and fp_control registers.  In particular, the precision control
     (_FPU_EXTENDED, _FPU_DOUBLE, _FPU_SINGLE) and the interrupt mask
     _FPU_MASK_UM are without effect.  */

  /* First, set dynamic rounding mode: */
  {
    unsigned long fpcr;

    fpcr = rdfpcr();
    fpcr &= ~FPCR_DYN_MASK;
    switch (fpu_control & 0xc00)
      {
      case _FPU_RC_NEAREST:	fpcr |= FPCR_DYN_NORMAL; break;
      case _FPU_RC_DOWN:	fpcr |= FPCR_DYN_MINUS; break;
      case _FPU_RC_UP:		fpcr |= FPCR_DYN_PLUS; break;
      case _FPU_RC_ZERO:	fpcr |= FPCR_DYN_CHOPPED; break;
      }
    wrfpcr(fpcr);
  }

  /* Now tell kernel about traps that we like to hear about: */
  {
    unsigned long old_fpcw, fpcw;

    old_fpcw = fpcw = __ieee_get_fp_control ();
    fpcw &= ~IEEE_TRAP_ENABLE_MASK;

    if (!(fpu_control & _FPU_MASK_IM)) fpcw |= IEEE_TRAP_ENABLE_INV;
    if (!(fpu_control & _FPU_MASK_DM)) fpcw |= IEEE_TRAP_ENABLE_UNF;
    if (!(fpu_control & _FPU_MASK_ZM)) fpcw |= IEEE_TRAP_ENABLE_DZE;
    if (!(fpu_control & _FPU_MASK_OM)) fpcw |= IEEE_TRAP_ENABLE_OVF;
    if (!(fpu_control & _FPU_MASK_PM)) fpcw |= IEEE_TRAP_ENABLE_INE;

    if (fpcw != old_fpcw)
      __ieee_set_fp_control (fpcw);
  }

  __fpu_control = fpu_control;	/* update global copy */
}
