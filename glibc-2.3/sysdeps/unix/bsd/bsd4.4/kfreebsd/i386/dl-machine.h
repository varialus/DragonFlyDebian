/* Dynamic linker magic for glibc on FreeBSD.
   Copyright (C) 2002 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by Bruno Haible <bruno@clisp.org>, 2002.

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

/* FreeBSD on i386 can emulate three ABIs (= sets of system calls):
   The native FreeBSD ABI, Linux and SysV.  Without additional kernel
   modules, only the FreeBSD ABI is supported.  For this reason, we use
   this ABI, and we have to label every executable as using this ABI,
   by writing the string "FreeBSD" at byte offset 8 (= EI_ABIVERSION)
   of every executable.  Strictly speaking, only ld.so and the
   executables would need this labelling.  But it's easiest to mark
   every executable and every shared object the same way.  */
#define VALID_ELF_HEADER(e_ident, expected, size) \
  (memcmp (e_ident, expected, EI_ABIVERSION) == 0			      \
   && memcmp ((const char *) (e_ident) + EI_ABIVERSION, "FreeBSD", 8) == 0)
#define VALID_ELF_OSABI(osabi) ((osabi) == ELFOSABI_SYSV)
#define VALID_ELF_ABIVERSION(abi) (memcmp (&(abi), "FreeBSD", 8) == 0)

#include_next "dl-machine.h"
