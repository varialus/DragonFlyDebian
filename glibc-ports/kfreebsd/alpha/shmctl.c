/* Copyright (C) 2006 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by Aurelien Jarno <aurelien@aurel32.net>, 2006.

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

#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <bits/kernel_time_t.h>

extern int __syscall_msgctl (int shmid, int cmd, struct __kernel_shmid_ds *buf);

int
__msgctl (int shmid, int cmd, struct shmid_ds *buf)
{
  struct __kernel_shmid_ds kshmid_ds;
  int retval;

  kshmid_ds.shm_perm = shmid_ds->shm_perm;
  kshmid_ds.shm_segsz = shmid_ds->shm_segsz;
  kshmid_ds.shm_lpid = shmid_ds->shm_lpid;
  kshmid_ds.shm_cpid = shmid_ds->shm_cpid;
  kshmid_ds.shm_nattch = shmid_ds->shm_nattch;
  kshmid_ds.shm_atime = shmid_ds->shm_atime;
  kshmid_ds.shm_dtime = shmid_ds->shm_dtime;
  kshmid_ds.shm_ctime = shmid_ds->shm_ctime;
  kshmid_ds.__shm_internal = shmid_ds->__shm_internal;

  retval = __syscall_shmctl (shmid, cmd, &kshmid_ds);

  shmid_ds->shm_perm = kshmid_ds.shm_perm;
  shmid_ds->shm_segsz = kshmid_ds.shm_segsz;
  shmid_ds->shm_lpid = kshmid_ds.shm_lpid;
  shmid_ds->shm_cpid = kshmid_ds.shm_cpid;
  shmid_ds->shm_nattch = kshmid_ds.shm_nattch;
  shmid_ds->shm_atime = kshmid_ds.shm_atime;
  shmid_ds->shm_dtime = kshmid_ds.shm_dtime;
  shmid_ds->shm_ctime = kshmid_ds.shm_ctime;
  shmid_ds->__shm_internal = kshmid_ds.__shm_internal;

  return retval;
}

weak_alias (__shmctl, shmctl)
