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

#ifndef _SEMAPHORE_H
#define _SEMAPHORE_H	1

#include <bits/semaphore.h>

#define SEM_FAILED __SEM_FAILED

typedef struct __sem_t sem_t;

__BEGIN_DECLS

/* Initialize the semaphore and set the initial value - as in LinuxThreads
   pshared must be zero right now.  */
extern int sem_init (sem_t *sem, int pshared, unsigned int value);

/* Destroys the semaphore.  */
extern int sem_destroy (sem_t *sem);

/* Wait until the count is > 0, and then decrease it.  */
extern int sem_wait (sem_t *sem);

/* Non-blocking variant of sem_wait.  Returns -1 if count == 0.  */
extern int sem_trywait (sem_t *sem);

/* Increments the count.  */
extern int sem_post (sem_t *sem);

/* Return the value of the semaphore.  */
extern int sem_getvalue (sem_t *sem, int *sval);

/* Close a named semaphore.  */
extern int    sem_close(sem_t *sem);

/* Open a named semaphore.  */
extern sem_t *sem_open(const char *name, int oflag, ...);

__END_DECLS

#endif /* semaphore.h */
