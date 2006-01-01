/* Copyright (C) 2005 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by Aurelien Jarno <aurelien@aurel32.net>, 2005.

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

#include <sys/socket.h>
#include <sysdep.h>
#include <sysdep-cancel.h>

/* According to POSIX.1-2004 the len argument specifies the length of
   the sockaddr structure pointed to by the addrarg argument. However
   the FreeBSD kernel waits the actual length of the address stored 
   there. The code below emulate this behaviour.  */

extern int __libc_sa_len (sa_family_t __af);

extern ssize_t __syscall_sendto (int fd, __const __ptr_t buf, 
		                 size_t n, int flags, 
				 __CONST_SOCKADDR_ARG addr, 
				 socklen_t addrlen);

/* Send N bytes of BUF on socket FD to peer at address ADDR (which is
 *    ADDR_LEN bytes long).  Returns the number sent, or -1 for errors.  */

int
__libc_sendto (int fd, __const __ptr_t buf, size_t n, int flags,
	       __CONST_SOCKADDR_ARG addr, socklen_t addrlen)
{
  socklen_t new_addrlen = __libc_sa_len ((addr.__sockaddr__)->sa_family);

  /* Only allow a smaller size, otherwise it could lead to
    stack corruption */
  if (new_addrlen < addrlen)
    addrlen = new_addrlen;
		
  /* We pass 6 arguments.  */
  if (SINGLE_THREAD_P)
    return INLINE_SYSCALL (sendto, 6, fd, buf, n, flags, addr, addrlen);
  
  int oldtype = LIBC_CANCEL_ASYNC ();
  int result = INLINE_SYSCALL (sendto, 6, fd, buf, n, flags, addr, addrlen);
  LIBC_CANCEL_RESET (oldtype);
  return result;
}

weak_alias (__libc_sendto, __sendto)
weak_alias (__libc_sendto, sendto)
