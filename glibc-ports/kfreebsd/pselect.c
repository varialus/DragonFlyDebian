/* Copyright (C) 2006, 2007, 2010 Free Software Foundation, Inc.
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

#include <errno.h>
#include <signal.h>
#include <time.h>
#include <sys/poll.h>
#include <kernel-features.h>
#include <sysdep-cancel.h>


#ifndef __ASSUME_PSELECT
static int __generic_pselect (int nfds, fd_set *readfds, fd_set *writefds,
			      fd_set *exceptfds,
			      const struct timespec *timeout,
			      const sigset_t *sigmask);
#endif

extern int __syscall_pselect (int nfds, fd_set *readfds, fd_set *writefds,
			      fd_set *exceptfds,
			      const struct timespec *timeout,
			      const sigset_t *sigmask) __THROW;

int 
__pselect (int nfds, fd_set *readfds, fd_set *writefds,
			      fd_set *exceptfds,
			      const struct timespec *timeout,
			      const sigset_t *sigmask)
{
  int result;

  if (SINGLE_THREAD_P)
    result = INLINE_SYSCALL (pselect, 6, nfds, readfds, writefds, exceptfds, 
			     timeout, sigmask);
  else
    {
      int oldtype = LIBC_CANCEL_ASYNC ();
      result = INLINE_SYSCALL (pselect, 6, nfds, readfds, writefds, exceptfds, 
  			       timeout, sigmask);
      LIBC_CANCEL_RESET (oldtype);
    }

#ifndef __ASSUME_PSELECT
  if (result == -1 && errno == ENOSYS)
    return __generic_pselect (nfds, readfds, writefds, exceptfds,
                                timeout, sigmask);
#endif

  return result;
}
weak_alias (__pselect, pselect)
strong_alias (__pselect, __libc_pselect)

#ifndef __ASSUME_PSELECT
# define __pselect static __generic_pselect
# include <misc/pselect.c>
#endif
