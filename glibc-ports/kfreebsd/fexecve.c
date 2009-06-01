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

#include <errno.h>
#include <fcntl.h>
#include <stddef.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <sysdep.h>
#include <unistd.h>
#include <sys/sysctl.h>
#include <sys/user.h>
#include <kernel-features.h>

extern int __syscall_fexecve (int fd, char *const argv[], char *const envp[]);
libc_hidden_proto (__syscall_fexecve);

/* Execute the file FD refers to, overlaying the running program image.
   ARGV and ENVP are passed to the new program, as for `execve'.  */
int
fexecve (fd, argv, envp)
     int fd;
     char *const argv[];
     char *const envp[];
{
# ifndef __ASSUME_ATFCTS
  if (__have_atfcts >= 0)
# endif
    {
      int result = INLINE_SYSCALL (fexecve, 3, fd, argv, envp);
# ifndef __ASSUME_ATFCTS
      if (result == -1 && errno == ENOSYS)
	__have_atfcts = -1;
      else
# endif
	return result;
    }

#ifndef __ASSUME_ATFCTS
  if (fd < 0 || argv == NULL || envp == NULL)
    {
      __set_errno (EINVAL);
      return -1;
    }

  int mib[4];
  size_t kf_len = 0;
  char *kf_buf, *kf_bufp;

  mib[0] = CTL_KERN;
  mib[1] = KERN_PROC;
  mib[2] = KERN_PROC_FILEDESC;
  mib[3] = __getpid ();

  if (sysctl (mib, 4, NULL, &kf_len, NULL, 0) != 0)
    {
      __set_errno (ENOSYS);
      return -1;
    }

  kf_buf = alloca (kf_len);
  if (sysctl (mib, 4, kf_buf, &kf_len, NULL, 0) != 0)
    {
      __set_errno (ENOSYS);
      return -1;
    }

  kf_bufp = kf_buf;
  while (kf_bufp < kf_buf + kf_len)
    {
      struct kinfo_file *kf = (struct kinfo_file *) (uintptr_t) kf_bufp;

      if (kf->kf_fd == fd)
	{
	  if (kf->kf_type == KF_TYPE_VNODE &&
	      kf->kf_vnode_type == KF_VTYPE_VREG)
	    return __execve (kf->kf_path, argv, envp);
	  break;
	}
      kf_bufp += kf->kf_structsize;
    }

  __set_errno (EINVAL);
  return -1;
#endif
}
