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
extern int __libc_sa_len_internal (sa_family_t __af);

extern int __syscall_connect (int fd, __CONST_SOCKADDR_ARG addr, 
			      socklen_t addrlen);

/* Open a connection on socket FD to peer at ADDR (which LEN bytes long).
   For connectionless socket types, just set the default address to send to
   and the only address from which to accept transmissions.
   Return 0 on success, -1 for errors.  */

int
__libc_connect (int fd, __CONST_SOCKADDR_ARG addr, socklen_t addrlen)
{
  socklen_t new_addrlen;
	
#ifndef NOT_IN_libc
  new_addrlen = INTUSE(__libc_sa_len) ((addr.__sockaddr__)->sa_family);
#else
  new_addrlen = __libc_sa_len ((addr.__sockaddr__)->sa_family);
#endif

  /* Only allow a smaller size, otherwise it could lead to
    stack corruption */
  if (new_addrlen < addrlen)
    addrlen = new_addrlen;
		
  /* We pass 3 arguments.  */
  if (SINGLE_THREAD_P)
    return INLINE_SYSCALL (connect, 3, fd, addr, addrlen);
  
  int oldtype = LIBC_CANCEL_ASYNC ();
  int result = INLINE_SYSCALL (connect, 3, fd, addr, addrlen);
  LIBC_CANCEL_RESET (oldtype);
  return result;
}

strong_alias (__libc_connect, __connect_internal)
weak_alias (__libc_connect, __connect)
weak_alias (__libc_connect, connect)