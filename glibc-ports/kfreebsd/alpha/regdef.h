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

#ifndef _REGDEF_H
#define _REGDEF_H

/* Common symbolic names for Alpha registers.
   Names taken from binutils/opcodes/alpha-dis.c.
   Register usage info taken from gcc-3.1/gcc/config/alpha/alpha.h.
   NB: "saved" = "call-saved", "nonsaved" = "call-used".  */

#define v0	$0	/* nonsaved, first return value */
#define t0	$1	/* nonsaved, second return value, lexical closure reg */
#define t1	$2	/* nonsaved */
#define t2	$3	/* nonsaved */
#define t3	$4	/* nonsaved */
#define t4	$5	/* nonsaved */
#define t5	$6	/* nonsaved */
#define t6	$7	/* nonsaved */
#define t7	$8	/* nonsaved */
#define s0	$9	/* saved */
#define s1	$10	/* saved */
#define s2	$11	/* saved */
#define s3	$12	/* saved */
#define s4	$13	/* saved */
#define s5	$14	/* saved */
#define s6	$15	/* use only in leaf functions without frame pointer */
#define fp	$15	/* frame pointer */
#define a0	$16	/* nonsaved, argument 1 */
#define a1	$17	/* nonsaved, argument 2 */
#define a2	$18	/* nonsaved, argument 3 */
#define a3	$19	/* nonsaved, argument 4 */
#define a4	$20	/* nonsaved, argument 5 */
#define a5	$21	/* nonsaved, argument 6 */
#define t8	$22	/* nonsaved */
#define t9	$23	/* nonsaved */
#define t10	$24	/* nonsaved */
#define t11	$25	/* nonsaved */
#define ra	$26	/* return address */
#define t12	$27	/* current function's address */
#define pv	$27	/* current function's address */
#define AT	$28	/* nonsaved, assembler temporary */
#define gp	$29	/* global pointer */
#define sp	$30	/* stack pointer */
#define zero	$31	/* reads as zero, writes go to /dev/null */

#endif /* _REGDEF_H */
