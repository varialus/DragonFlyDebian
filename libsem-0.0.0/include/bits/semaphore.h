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
 *	POSIX Threads Extension: Semaphores			<semaphore.h>
 */

#ifndef _BITS_SEMAPHORE_H
#define _BITS_SEMAPHORE_H	1

#include <pthread.h>
#include <limits.h>

#define __SEM_FAILED NULL

#define __SEM_VALUE_MAX UINT_MAX

#define __SEM_ID_NONE 0
#define __SEM_ID_LOCAL 0xFAAF	/* Anything non-zero is good enough.  */

struct __local_sem_t 
{
  unsigned int count;
  pthread_mutex_t count_lock;
  pthread_cond_t count_cond;
};

struct __shared_sem_t
{
  /* Not used yet.  */
};

struct __named_sem_t
{
  /* Not used yet.  */
};

struct __sem_t
{
  int id;
  union {
    struct __local_sem_t local;
    struct __shared_sem_t shared;
    struct __named_sem_t named;
  } __data;
};

#endif /* bits/semaphore.h */

