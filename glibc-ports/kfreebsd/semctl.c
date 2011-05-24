/* Copyright (C) 2004, 2010 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by Robert Millan

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

/*-
 * Copyright (c) 2002 Doug Rabson
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 */

#include <sysdep.h>
#include <sys/sem.h>
#include <stdarg.h> /* va_list */
#include <stdlib.h> /* NULL */
#include <unistd.h>

/* union semun from FreeBSD <sys/sem.h> */
/*
 * semctl's arg parameter structure
 */
union semun
{
  int val;			/* value for SETVAL */
  struct semid_ds *buf;		/* buffer for IPC_STAT & IPC_SET */
  unsigned short *array;	/* array for GETALL & SETALL */
};

extern int __syscall_semctl (int semid, int semnum,
                             int cmd, union semun *arg);
libc_hidden_proto (__syscall_semctl)

int
semctl (int semid, int semnum, int cmd, ...)
{
  va_list ap;
  union semun semun;
  union semun *semun_ptr;

  va_start (ap, cmd);
  if (cmd == IPC_SET || cmd == IPC_STAT || cmd == GETALL
      || cmd == SETVAL || cmd == SETALL)
    {
      semun = va_arg (ap, union semun);
      semun_ptr = &semun;
    }
  else
    {
      semun_ptr = NULL;
    }
  va_end (ap);

  return INLINE_SYSCALL (semctl, 4, semid, semnum, cmd, semun_ptr);
}
