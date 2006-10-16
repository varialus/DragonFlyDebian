/* prototypes of generally used "inline syscalls"
   Copyright (C) 2006 Free Software Foundation, Inc.
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

#ifndef KFREEBSD_INLINE_SYSCALLS_H
#define KFREEBSD_INLINE_SYSCALLS_H

#include <sys/types.h>
#define __need_sigset_t
#include <signal.h>

struct iovec;
struct rusage;
struct timespec;

int __syscall_open(const char *path, int flags, ...);
int __syscall_close(int fd);

ssize_t __syscall_read(int fd, void *buf, size_t nbyte);
ssize_t __syscall_write(int fd, const void *buf, size_t nbyte);
ssize_t __syscall_writev(int fd, const struct iovec *iovp, int iovcnt); 

int __syscall_fcntl(int fd, int cmd, ...);
int __syscall_fork(void);
int __syscall_wait4(int pid, int *status, int options, struct rusage *rusage);
int __syscall_sigsuspend (const sigset_t *set);
int __syscall_nanosleep (const struct timespec *requested_time, struct timespec *remaining);

#endif
