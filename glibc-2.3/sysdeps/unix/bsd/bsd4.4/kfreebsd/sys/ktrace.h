/* 'ktrace' system call debugger support interface.  FreeBSD version.
   Copyright (C) 2002 Free Software Foundation, Inc.
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

#ifndef _SYS_KTRACE_H
#define _SYS_KTRACE_H	1

#include <features.h>

/* Define MAXCOMLEN.  */
#include <sys/param.h>

/* Define register_t.  */
#include <sys/types.h>

/* Define __sighandler_t, __sigset_t.  */
#include <signal.h>

/* Define 'struct timeval'.  */
#define __need_timeval
#include <bits/time.h>


/* Structure of records written to the system call trace log file.
   A header of type ktr_header, followed by a variable length buffer.  */

struct ktr_header
  {
    int ktr_len;			/* Length of ktr_buf.  */
    short ktr_type;			/* Trace record type.  */
    __pid_t ktr_pid;			/* Process id.  */
    char ktr_comm[MAXCOMLEN+1];		/* Command name.  */
    struct timeval ktr_time;		/* Timestamp.  */
    void *ktr_buf;			/* Pointer to ktr_len bytes.
					   (Ignore in the log file.)  */
  };

/* Possible values of ktr_type.  */
enum
{
  KTR_SYSCALL = 1,		/* System call record.  */
#define KTR_SYSCALL KTR_SYSCALL
  KTR_SYSRET = 2,		/* Return from system call record.  */
#define KTR_SYSRET KTR_SYSRET
  KTR_NAMEI = 3,		/* Namei record.  */
#define KTR_NAMEI KTR_NAMEI
  KTR_GENIO = 4,		/* Generic process I/O record.  */
#define KTR_GENIO KTR_GENIO
  KTR_PSIG = 5,			/* Processed signal record.  */
#define KTR_PSIG KTR_PSIG
  KTR_CSW = 6,			/* Context switch record.  */
#define KTR_CSW KTR_CSW
  KTR_USER = 7			/* User defined record.  */
#define KTR_USER KTR_USER
};

/* ktr_buf for KTR_SYSCALL: System call record.  */
struct ktr_syscall
  {
    short ktr_code;			/* Syscall number.  */
    short ktr_narg;			/* Number of arguments.  */
    register_t ktr_args __flexarr;
  };

/* ktr_buf for KTR_SYSRET: Return from system call record.  */
struct ktr_sysret
  {
    short ktr_code;			/* Syscall number.  */
    short ktr_eosys;
    int ktr_error;
    register_t ktr_retval;
  };

/* ktr_buf for KTR_NAMEI: Namei record.
   It contains the pathname.  */

/* ktr_buf for KTR_GENIO: Generic process I/O record.  */
enum uio_rw
{
  UIO_READ,
  UIO_WRITE
};
struct ktr_genio
  {
    int ktr_fd;				/* File descriptor.  */
    enum uio_rw ktr_rw;			/* I/O direction.  */
    char ktr_data __flexarr;		/* Data successfully read/written.  */
  };

/* ktr_buf for KTR_PSIG: Processed signal record.  */
struct ktr_psig
  {
    int signo;
    __sighandler_t action;
    int code;
    sigset_t mask;
  };

/* ktr_buf for KTR_CSW: Context switch record.  */
struct ktr_csw
  {
    int out;				/* 1 if switch out, 0 if switch in.  */
    int user;				/* 1 if usermode, 0 if kernel mode.  */
  };

/* Maximum size of ktr_buf for KTR_USER: User defined record.  */
#define KTR_USER_MAXLEN	2048


/* The OP_FLAGS argument of ktrace() consists of an operation and
   some flags.  This macro extracts the operation.  */
#define KTROP(op_flags) ((op_flags) & 3)

/* Possible values for operation in OP_FLAGS argument of ktrace().  */
enum
{
  KTROP_SET = 0,			/* Set trace facilities.  */
#define KTROP_SET KTROP_SET
  KTROP_CLEAR = 1,			/* Clear trace facilities.  */
#define KTROP_CLEAR KTROP_CLEAR
  KTROP_CLEARFILE = 2			/* Stop all tracing to file.  */
#define KTROP_CLEARFILE KTROP_CLEARFILE
};

/* Possible flags to be ORed into OP_FLAGS argument of ktrace().  */
enum
{
  KTRFLAG_DESCEND = 4	/* Perform operation on all children processes too.  */
#define KTRFLAG_DESCEND KTRFLAG_DESCEND
};


/* The FAC is an OR of some trace facilities.  */
enum
{
  KTRFAC_SYSCALL = 1 << KTR_SYSCALL,	/* Trace system calls.  */
#define KTRFAC_SYSCALL KTRFAC_SYSCALL
  KTRFAC_SYSRET = 1 << KTR_SYSRET,	/* Trace system call returns.  */
#define KTRFAC_SYSRET KTRFAC_SYSRET
  KTRFAC_NAMEI = 1 << KTR_NAMEI,	/* Trace namei operations.  */
#define KTRFAC_NAMEI KTRFAC_NAMEI
  KTRFAC_GENIO = 1 << KTR_GENIO,	/* Trace generic process I/O.  */
#define KTRFAC_GENIO KTRFAC_GENIO
  KTRFAC_PSIG = 1 << KTR_PSIG,		/* Trace signal processing.  */
#define KTRFAC_PSIG KTRFAC_PSIG
  KTRFAC_CSW = 1 << KTR_CSW,		/* Trace context switches.  */
#define KTRFAC_CSW KTRFAC_CSW
  KTRFAC_USER = 1 << KTR_USER,		/* Trace user defined records.  */
#define KTRFAC_USER KTRFAC_USER
  KTRFAC_INHERIT = 1 << 30	    /* Inherit trace flags to new children.  */
#define KTRFAC_INHERIT KTRFAC_INHERIT
};


__BEGIN_DECLS

/* Enable system call tracing for the process PID.
   Trace records will be written to TRACEFILE; this file is truncated.  If
   OP_FLAGS contains KTROP_CLEAR, TRACEFILE may be NULL.
   FAC contains the facilities to switch on or off.  */
extern int ktrace (__const char *__tracefile, int __op_flags, int __fac,
		   __pid_t pid) __THROW;

/* Write a user defined record to the current process' trace log file.  */
extern int utrace (__const void *__buf, size_t __len) __THROW;

__END_DECLS

#endif /* _SYS_KTRACE_H */
