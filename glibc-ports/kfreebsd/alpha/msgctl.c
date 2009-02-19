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
#include <sys/msg.h>
#include <bits/kernel_time_t.h>

extern int __syscall_msgctl (int msqid, int cmd, struct __kernel_msqid_ds *buf);

int
__msgctl (int msqid, int cmd, struct msqid_ds *buf)
{
  struct __kernel_msqid_ds kmsqid_ds;
  int retval;

  kmsqid_ds.msg_perm = msqid_ds->msg_perm;
  kmsqid_ds.__msg_first = msqid_ds->__msg_first;
  kmsqid_ds.__msg_last = msqid_ds->__msg_last;
  kmsqid_ds.__msg_cbytes = msqid_ds->__msg_cbytes;
  kmsqid_ds.msg_qnum = msqid_ds->msg_qnum;
  kmsqid_ds.msg_qbytes = msqid_ds->msg_qbytes;
  kmsqid_ds.msg_lspid = msqid_ds->msg_lspid;
  kmsqid_ds.msg_lrpid = msqid_ds->msg_lrpid;
  kmsqid_ds.msg_stime = msqid_ds->msg_stime;
  kmsqid_ds.msg_rtime = msqid_ds->msg_rtime;
  kmsqid_ds.msg_ctime = msqid_ds->msg_ctime;

  retval = __syscall_msgctl (msqid, cmd, &kmsqid_ds);

  msqid_ds->msg_perm = kmsqid_ds.msg_perm;
  msqid_ds->__msg_first = kmsqid_ds.__msg_first;
  msqid_ds->__msg_last = kmsqid_ds.__msg_last;
  msqid_ds->__msg_cbytes = kmsqid_ds.__msg_cbytes;
  msqid_ds->msg_qnum = kmsqid_ds.msg_qnum;
  msqid_ds->msg_qbytes = kmsqid_ds.msg_qbytes;
  msqid_ds->msg_lspid = kmsqid_ds.msg_lspid;
  msqid_ds->msg_lrpid = kmsqid_ds.msg_lrpid;
  msqid_ds->msg_stime = kmsqid_ds.msg_stime;
  msqid_ds->msg_rtime = kmsqid_ds.msg_rtime;
  msqid_ds->msg_ctime = kmsqid_ds.msg_ctime;

  return retval;
}

weak_alias (__msgctl, msgctl)
