/* Copyright (C) 2001-2002 Free Software Foundation, Inc.
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

#include <sys/socket.h>
#include <sysdep.h>

/* The real syscall's name.  See sysdeps/unix/inet/syscalls.list.  */
#define __syscall_sendto __libc_sendto

/* Send N bytes of BUF to socket FD.
   Return the number of bytes sent or -1.  */

ssize_t
__libc_send (int fd, const void *buf, size_t n, int flags)
{
  return INLINE_SYSCALL (sendto, 6, fd, buf, n, flags, NULL, 0);
}

weak_alias (__libc_send, __send)
libc_hidden_weak (__send)

weak_alias (__send, send)
