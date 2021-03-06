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

extern int __syscall_linkat (int fd1, const char *path1, int fd2,
			       const char *path2, int flags);
libc_hidden_proto (__syscall_linkat)

/* Make a link to FROM named TO but relative paths in TO and FROM are
   interpreted relative to FROMFD and TOFD respectively.  */
int
linkat (fromfd, from, tofd, to, flags)
     int fromfd;
     const char *from;
     int tofd;
     const char *to;
     int flags;
{
# ifndef __ASSUME_ATFCTS
  if (__have_atfcts >= 0)
# endif
    {
      int result = INLINE_SYSCALL (linkat, 5, fromfd, from, tofd, to, flags);
# ifndef __ASSUME_ATFCTS
      if (result == -1 && errno == ENOSYS)
	__have_atfcts = -1;
      else
# endif
	return result;
    }

#ifndef __ASSUME_ATFCTS
  /* Without kernel support we cannot handle AT_SYMLINK_FOLLOW.  */
  if (flags != 0)
    {
      __set_errno (EINVAL);
      return -1;
    }

  if ((fromfd != AT_FDCWD && from[0] != '/')
      || (tofd != AT_FDCWD && to[0] != '/'))
    {
      int mib[4];
      size_t kf_len = 0;
      char *kf_buf, *kf_bufp;
      size_t fromlen, tolen;

      if ((fromfd < 0) || (tofd < 0))
	{
	  __set_errno (EBADF);
	  return -1;
	}

      fromlen = strlen (from);
      tolen = strlen (to);
      if (__builtin_expect (fromlen == 0, 0)
	  || __builtin_expect (tolen == 0, 0))
	{
	  __set_errno (ENOENT);
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

      if (fromfd != AT_FDCWD && from[0] != '/')
	{
	  kf_bufp = kf_buf;
	  while (kf_bufp < kf_buf + kf_len)
	    {
	      struct kinfo_file *kf =
		(struct kinfo_file *) (uintptr_t) kf_bufp;

	      if (kf->kf_fd == fromfd)
		{
		  char *buf;
		  if (kf->kf_type != KF_TYPE_VNODE ||
		      kf->kf_vnode_type != KF_VTYPE_VDIR)
		    {
		      __set_errno (ENOTDIR);
		      return -1;
		    }

		  buf = alloca (strlen (kf->kf_path) + fromlen + 2);
		  strcpy(buf, kf->kf_path);
		  strcat (buf, "/");
		  strcat (buf, from);
		  from = buf;
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

      if (tofd != AT_FDCWD && to[0] != '/')
	{
	  kf_bufp = kf_buf;
	  while (kf_bufp < kf_buf + kf_len)
	    {
	      struct kinfo_file *kf =
		(struct kinfo_file *) (uintptr_t) kf_bufp;

	      if (kf->kf_fd == tofd)
		{
		  char *buf;
		  if (kf->kf_type != KF_TYPE_VNODE ||
		      kf->kf_vnode_type != KF_VTYPE_VDIR)
		    {
		      __set_errno (ENOTDIR);
		      return -1;
		    }

		  buf = alloca (strlen (kf->kf_path) + tolen + 2);
		  strcpy(buf, kf->kf_path);
		  strcat (buf, "/");
		  strcat (buf, to);
		  to = buf;
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
  
  return __link (from, to);
#endif
}
