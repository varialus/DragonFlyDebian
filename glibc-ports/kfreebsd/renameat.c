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
#include <stdio.h>
#include <sys/sysctl.h>
#include <sys/user.h>
#include <kernel-features.h>

libc_hidden_proto (rename)

extern int __syscall_renameat (int oldfd, const char *old, int newfd,
			       const char *new);
libc_hidden_proto (__syscall_renameat)

/* Rename the file OLD relative to OLDFD to NEW relative to NEWFD.  */
int renameat (oldfd, old, newfd, new)
     int oldfd;
     const char *old;
     int newfd;
     const char *new;
{
# ifndef __ASSUME_ATFCTS
  if (__have_atfcts >= 0)
# endif
    {
      int result = INLINE_SYSCALL (renameat, 4, oldfd, old, newfd, new);
# ifndef __ASSUME_ATFCTS
      if (result == -1 && errno == ENOSYS)
	__have_atfcts = -1;
      else
# endif
	return result;
    }

#ifndef __ASSUME_ATFCTS
  if ((oldfd != AT_FDCWD && old[0] != '/')
      || (newfd != AT_FDCWD && new[0] != '/'))
    {
      int mib[4];
      size_t kf_len = 0;
      char *kf_buf, *kf_bufp;

      if ((oldfd < 0) || (newfd < 0))
	{
	  __set_errno (EBADF);
	  return -1;
	}

      mib[0] = CTL_KERN;
      mib[1] = KERN_PROC;
      mib[2] = KERN_PROC_FILEDESC;
      mib[3] = __getpid ();

      if (__sysctl (mib, 4, NULL, &kf_len, NULL, 0) != 0)
	{
	  __set_errno (ENOSYS);
	  return -1;
	}

      kf_buf = alloca (kf_len);
      if (__sysctl (mib, 4, kf_buf, &kf_len, NULL, 0) != 0)
	{
	  __set_errno (ENOSYS);
	  return -1;
	}

      if (oldfd != AT_FDCWD && old[0] != '/')
	{
	  kf_bufp = kf_buf;
	  while (kf_bufp < kf_buf + kf_len)
	    {
	      struct kinfo_file *kf =
		(struct kinfo_file *) (uintptr_t) kf_bufp;

	      if (kf->kf_fd == oldfd)
		{
		  char *buf;
		  if (kf->kf_type != KF_TYPE_VNODE ||
		      kf->kf_vnode_type != KF_VTYPE_VDIR)
		    {
		      __set_errno (ENOTDIR);
		      return -1;
		    }

		  buf = alloca (strlen (kf->kf_path) + strlen (old) + 2);
		  strcpy(buf, kf->kf_path);
		  strcat (buf, "/");
		  strcat (buf, old);
		  old = buf;
		  break;
		}
	      kf_bufp += kf->kf_structsize;
	    }

	  if (kf_bufp >= kf_buf + kf_len)
	    {
	      __set_errno (EBADF);
	      return -1;
	    }
	}

      if (newfd != AT_FDCWD && new[0] != '/')
	{
	  kf_bufp = kf_buf;
	  while (kf_bufp < kf_buf + kf_len)
	    {
	      struct kinfo_file *kf =
		(struct kinfo_file *) (uintptr_t) kf_bufp;

	      if (kf->kf_fd == newfd)
		{
		  char *buf;
		  if (kf->kf_type != KF_TYPE_VNODE ||
		      kf->kf_vnode_type != KF_VTYPE_VDIR)
		    {
		      __set_errno (ENOTDIR);
		      return -1;
		    }

		  buf = alloca (strlen (kf->kf_path) + strlen (new) + 2);
		  strcpy(buf, kf->kf_path);
		  strcat (buf, "/");
		  strcat (buf, new);
		  new = buf;
		  break;
		}
	      kf_bufp += kf->kf_structsize;
	    }

	  if (kf_bufp >= kf_buf + kf_len)
	    {
	      __set_errno (EBADF);
	      return -1;
	    }
	}
    }

#define __rename rename /* there is no __rename */
  return __rename (old, new);
#endif
}
stub_warning(renameat)
