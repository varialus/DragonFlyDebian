/* Copyright (C) 2000,02 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Written by Gaël Le Mignot <address@hidden>

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public License as
   published by the Free Software Foundation; either version 2 of the
   License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with the GNU C Library; see the file COPYING.LIB.  If not,
   write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA.  */

/*
 *	POSIX Threads Extension: Semaphores			<semaphore.c>
 */

#include <semaphore.h>
#include <errno.h>


/* Stub functions - unimplemented functionality.  */

/* Open a named semaphore.  */
sem_t *
sem_open (const char * foo, int bar, ...)
{
  errno = ENOSYS;
  return __SEM_FAILED;
}

/* Close a named semaphore.  */
int
sem_close (sem_t * foo)
{
  errno = ENOSYS;
  return -1;
}
