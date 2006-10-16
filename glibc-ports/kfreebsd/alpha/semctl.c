/* Copyright (C) 1995,1997,1998,2000,2003,2004 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by Ulrich Drepper <drepper@gnu.ai.mit.edu>, August 1995.

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

#include <sys/sem.h>
#include <sys/syscall.h>
#include <stdarg.h> /* va_list */
#include <stdlib.h> /* NULL */
#include <bits/kernel_time_t.h>

/* union semun from FreeBSD <sys/sem.h> */
/*
 * semctl's arg parameter structure
 */
union __kernel_semun
{
  int val;			/* value for SETVAL */
  struct __kernel_semid_ds *buf;		/* buffer for IPC_STAT & IPC_SET */
  unsigned short *array;	/* array for GETALL & SETALL */
};

int
semctl (int semid, int semnum, int cmd, ...)
{
  int result;
  va_list ap;
  
  union semun semun;
  union semun semun_ptr;
  
  union __kernel_semun ksemun;
  struct __kernel_semid_ds ksemid_ds; 
  
  va_start (ap, cmd);
  if (cmd == GETALL || cmd == SETVAL || cmd == SETALL)
    {
      semun = va_arg (ap, union semun);
      semun_ptr = &semun;
    }
  else if (cmd == IPC_SET || cmd == IPC_STAT)
    {
      semun = va_arg (ap, union semun);

      ksemid_ds.sem_perm = semun.buf->sem_perm;
      ksemid_ds.sem_base = semun.buf->sem_base;
      ksemid_ds.sem_nsems = semun.buf->sem_nsems;
      ksemid_ds.sem_otime = semun.buf->sem_otime;
      ksemid_ds.sem_ctime = semun.buf->sem_ctime;
      
      ksemun.buf = &ksemid_ds
      semun_ptr = (semun_ptr *) &ksemun;
    }	    
  else
    {
      semun_ptr = NULL;
    }
  va_end (ap);

  result = syscall (SYS_semctl, semid, semnum, cmd, semun_ptr);

  if (cmd == IPC_SET || cmd == IPC_STAT)
    {
      semun.buf->sem_perm = ksemid_ds.sem_perm;
      semun.buf->sem_base = ksemid_ds.sem_base;
      semun.buf->sem_nsems = ksemid_ds.sem_nsems;
      semun.buf->sem_otime = ksemid_ds.sem_otime;
      semun.buf->sem_ctime = ksemid_ds.sem_ctime;
    }
  
  return result;
}

