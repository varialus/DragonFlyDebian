/* Copyright (C) 2002 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by Bruno Haible <bruno@clisp.org>, 2002.

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

#include <sys/poll.h>
#include <sysdep.h>
#include <errno.h>

/* nfds_t is defined as 'unsigned long int' in <sys/poll.h>, but the poll
   system call expects an 'unsigned int' as second argument.  */

extern int __syscall_poll (struct pollfd *fds, unsigned int nfds, int timeout);

int
__poll (struct pollfd *fds, nfds_t nfds, int timeout)
{
  unsigned int infds = nfds;

  if (infds == nfds)
    return INLINE_SYSCALL (poll, 3, fds, infds, timeout);
  else
    {
      /* NFDS doesn't fit into an unsigned int.  FDS cannot point to such
	 a big chunk of valid memory.  */
      __set_errno (EFAULT);
      return -1;
    }
}
libc_hidden_def (__poll)

weak_alias (__poll, poll)
