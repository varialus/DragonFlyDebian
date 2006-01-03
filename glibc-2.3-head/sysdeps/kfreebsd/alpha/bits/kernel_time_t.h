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


/* This header files describe the way that structures using time_t 
   are represented in the kernel */

#ifndef _BITS_KERNEL_TIME_T_H
#define _BITS_TIME_H 1

#include <bits/types.h>
#include <sys/msg.h>

/* This structure corresponds to the newer FreeBSD 'struct timespec' */
struct __kernel_timespec
  {
    int tv_sec;			/* Seconds.  */
    long int tv_nsec;		/* Nanoseconds.  */
  };

/* This structure corresponds to the newer FreeBSD 'struct timeval' */
struct __kernel_timeval
  {
    int tv_sec;			/* Seconds.  */
    __suseconds_t tv_usec;	/* Microseconds.  */
  };

/* This structure corresponds to the newer FreeBSD 'struct itimerval' */
struct __kernel_itimerval
  {
    /* Value to put into `it_value' when the timer expires.  */
    struct __kernel_timeval it_interval;
    /* Time to the next timer expiration.  */
    struct __kernel_timeval it_value;
  };

/* This structure corresponds to the newer FreeBSD 'struct rusage' */
struct __kernel_rusage
  {
    /* Total amount of user time used.  */
    struct __kernel_timeval ru_utime;
    /* Total amount of system time used.  */
    struct __kernel_timeval ru_stime;
    /* Maximum resident set size (in kilobytes).  */
    long int ru_maxrss;
    /* Amount of sharing of text segment memory
       with other processes (kilobyte-seconds).  */
    long int ru_ixrss;
    /* Amount of data segment memory used (kilobyte-seconds).  */
    long int ru_idrss;
    /* Amount of stack memory used (kilobyte-seconds).  */
    long int ru_isrss;
    /* Number of soft page faults (i.e. those serviced by reclaiming
       a page from the list of pages awaiting reallocation.  */
    long int ru_minflt;
    /* Number of hard page faults (i.e. those that required I/O).  */
    long int ru_majflt;
    /* Number of times a process was swapped out of physical memory.  */
    long int ru_nswap;
    /* Number of input operations via the file system.  Note: This
       and `ru_oublock' do not include operations with the cache.  */
    long int ru_inblock;
    /* Number of output operations via the file system.  */
    long int ru_oublock;
    /* Number of IPC messages sent.  */
    long int ru_msgsnd;
    /* Number of IPC messages received.  */
    long int ru_msgrcv;
    /* Number of signals delivered.  */
    long int ru_nsignals;
    /* Number of voluntary context switches, i.e. because the process
       gave up the process before it had to (usually to wait for some
       resource to be available).  */
    long int ru_nvcsw;
    /* Number of involuntary context switches, i.e. a higher priority process
       became runnable or the current process used up its time slice.  */
    long int ru_nivcsw;
  };

/* This structure corresponds to the newer FreeBSD 'struct msqid_ds' */
struct __kernel_msqid_ds
{
  struct ipc_perm msg_perm;	/* structure describing operation permission */
  void *__msg_first;
  void *__msg_last;
  msglen_t __msg_cbytes;	/* current number of bytes on queue */
  msgqnum_t msg_qnum;		/* number of messages currently on queue */
  msglen_t msg_qbytes;		/* max number of bytes allowed on queue */
  __pid_t msg_lspid;		/* pid of last msgsnd() */
  __pid_t msg_lrpid;		/* pid of last msgrcv() */
  int msg_stime;		/* time of last msgsnd command */
  long __unused1;
  int msg_rtime;		/* time of last msgrcv command */
  long __unused2;
  int msg_ctime;		/* time of last change */
  long __unused3;
  long __unused4[4];
};

/* This structure corresponds to the newer FreeBSD 'struct shmid_ds' */
struct __kernel_shmid_ds
  {
    struct ipc_perm shm_perm;		/* operation permission struct */
    int shm_segsz;			/* size of segment in bytes */
    __pid_t shm_lpid;			/* pid of last shmop */
    __pid_t shm_cpid;			/* pid of creator */
    shmatt_t shm_nattch;		/* number of current attaches */
    int shm_atime;			/* time of last shmat() */
    int shm_dtime;			/* time of last shmdt() */
    int shm_ctime;			/* time of last change by shmctl() */
    void *__shm_internal;
  };

#endif
