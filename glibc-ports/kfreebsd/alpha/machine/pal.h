/* Copyright (C) 2002 Free Software Foundation, Inc.
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

/* Unprivileged PAL function codes.  (The PAL codes which require
   privileges are useful in the kernel only.)  */

/* Common PAL codes.  */
#define PAL_bpt		128
#define PAL_bugchk	129
#define PAL_callsys	131
#define PAL_imb		134
#define PAL_rduniq	158
#define PAL_wruniq	159
#define PAL_gentrap	170
#define PAL_nphalt	190

/* gentrap causes.  */
#define GEN_INTOVF	-1	/* integer overflow */
#define GEN_INTDIV	-2	/* integer division by zero */
#define GEN_FLTOVF	-3	/* fp overflow */
#define GEN_FLTDIV	-4	/* fp division by zero */
#define GEN_FLTUND	-5	/* fp underflow */
#define GEN_FLTINV	-6	/* invalid fp operand */
#define GEN_FLTINE	-7	/* inexact fp operand */
#define GEN_DECOVF	-8	/* decimal overflow (for COBOL??) */
#define GEN_DECDIV	-9	/* decimal division by zero */
#define GEN_DECINV	-10	/* invalid decimal operand */
#define GEN_ROPRAND	-11	/* reserved operand */
#define GEN_ASSERTERR	-12	/* assertion error */
#define GEN_NULPTRERR	-13	/* null pointer error */
#define GEN_STKOVF	-14	/* stack overflow */
#define GEN_STRLENERR	-15	/* string length error */
#define GEN_SUBSTRERR	-16	/* substring error */
#define GEN_RANGERR	-17	/* range error */
#define GEN_SUBRNG	-18
#define GEN_SUBRNG1	-19
#define GEN_SUBRNG2	-20
#define GEN_SUBRNG3	-21	/* these report range errors for */
#define GEN_SUBRNG4	-22	/* subscripting (indexing) at levels 0..7 */
#define GEN_SUBRNG5	-23
#define GEN_SUBRNG6	-24
#define GEN_SUBRNG7	-25
