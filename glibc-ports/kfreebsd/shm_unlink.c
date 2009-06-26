/* Copyright (C) 2009 Free Software Foundation, Inc.
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

#include <sys/stat.h>
#include <sys/mman.h>
#include <unistd.h>
#include <errno.h>
#include <sysdep.h>

extern int __syscall_shm_unlink (const char *name);
libc_hidden_proto (__syscall_shm_unlink)

libc_hidden_proto (__unlink)

/* Unlink a shared memory object.  */
int
shm_unlink (const char *name)
{
  /* First try the new syscall. */
  int result = INLINE_SYSCALL (shm_unlink, 1, name);

#ifndef __ASSUME_POSIXSHM_SYSCALL
  /* New syscall not available, simply unlink the file. */
  if (result == -1 && errno == ENOSYS)
# ifdef NOT_IN_libc
    return unlink (name);
# else
    return __unlink (name);
# endif
#endif

  return result;
}
