/* Initialization code run first thing by the ELF startup code.  Linux version.
   Copyright (C) 1995-1999, 2000, 2001, 2002 Free Software Foundation, Inc.
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

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sysdep.h>
#include <fpu_control.h>
#include <sys/param.h>
#include <sys/types.h>
#include <libc-internal.h>

#include <ldsodefs.h>
#ifndef SHARED
# include "dl-osinfo.h"
#endif

/* _FPU_INITIAL is the value of the floating-point control word, at
   the moment the kernel passes control to the program.  _FPU_DEFAULT
   is the default value of the floating-point control word, at the
   moment when control gets passed to the main() function.  */
#ifndef _FPU_INITIAL
# define _FPU_INITIAL _FPU_DEFAULT
#endif

/* The function is called from assembly stubs the compiler can't see.  */
static void init (int, char **, char **) __attribute__ ((unused));

extern int _dl_starting_up;
weak_extern (_dl_starting_up)

/* Set nonzero if we have to be prepared for more then one libc being
   used in the process.  Safe assumption if initializer never runs.  */
int __libc_multiple_libcs attribute_hidden = 1;

/* Remember the command line argument and enviroment contents for
   later calls of initializers for dynamic libraries.  */
int __libc_argc attribute_hidden;
char **__libc_argv attribute_hidden;


static void
init (int argc, char **argv, char **envp)
{
#ifdef USE_NONOPTION_FLAGS
  extern void __getopt_clean_environment (char **);
#endif
  /* The next variable is only here to work around a bug in gcc <= 2.7.2.2.
     If the address would be taken inside the expression the optimizer
     would try to be too smart and throws it away.  Grrr.  */
  int *dummy_addr = &_dl_starting_up;

  __libc_multiple_libcs = dummy_addr && !_dl_starting_up;

  /* Make sure we don't initialize twice.  */
  if (!__libc_multiple_libcs)
    {
#ifndef SHARED
# ifdef DL_SYSDEP_OSCHECK
      DL_SYSDEP_OSCHECK (__libc_fatal);
# endif
#endif

      /* Set the FPU control word to the proper default value if the
	 kernel would use a different value.  */
      if (__fpu_control != _FPU_INITIAL)
	__setfpucw (__fpu_control);
    }

  /* Save the command-line arguments.  */
  __libc_argc = argc;
  __libc_argv = argv;
  __environ = envp;

#ifndef SHARED
  __libc_init_secure ();

  /* First the initialization which normally would be done by the
     dynamic linker.  */
  _dl_non_dynamic_init ();
#endif

  __init_misc (argc, argv, envp);

#ifdef USE_NONOPTION_FLAGS
  /* This is a hack to make the special getopt in GNU libc working.  */
  __getopt_clean_environment (envp);
#endif

#ifdef SHARED
  __libc_global_ctors ();
#endif
}

#ifdef SHARED

strong_alias (init, _init);

extern void __libc_init_first (void);

void
__libc_init_first (void)
{
}

#else
extern void __libc_init_first (int argc, char **argv, char **envp);

void
__libc_init_first (int argc, char **argv, char **envp)
{
  init (argc, argv, envp);
}
#endif


/* This function is defined here so that if this file ever gets into
   ld.so we will get a link error.  Having this file silently included
   in ld.so causes disaster, because the _init definition above will
   cause ld.so to gain an init function, which is not a cool thing. */

extern void _dl_start (void) __attribute__ ((noreturn));

void
_dl_start (void)
{
  abort ();
}
