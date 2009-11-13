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
#include <sys/stat.h>
#include <sys/sysctl.h>
#include <sys/user.h>
#include <kernel-features.h>
#include <bp-checks.h>

#include "stat16conv.c"

extern int __syscall_fstatat (int fd, const char *path,
			      struct stat16 *buf, int flag);
libc_hidden_proto (__syscall_fstatat)

/* Get information about the file NAME relative to FD in ST.  */
int
__fxstatat64 (int vers, int fd, const char *file, struct stat64 *st, int flag)
{
# ifndef __ASSUME_ATFCTS
  if (__have_atfcts >= 0)
# endif
    {
      int result;

      if (__builtin_expect (vers == _STAT_VER, 1))
	{
	  struct stat16 buf16;
	  result =
	    INLINE_SYSCALL (fstatat, 4, fd, CHECK_STRING (file),
			    __ptrvalue (&buf16), flag);
	  if (result == 0)
	    stat16_to_stat64 (&buf16, st);
	}
      else
	{
	  __set_errno (EINVAL);
	  return -1;
	}
# ifndef __ASSUME_ATFCTS
      if (result == -1 && errno == ENOSYS)
	__have_atfcts = -1;
      else
# endif
	return result;
    }

#ifndef __ASSUME_ATFCTS
  if (flag & ~AT_SYMLINK_NOFOLLOW)
    {
      __set_errno (EINVAL);
      return -1;
    }

  if (fd != AT_FDCWD && file[0] != '/')
    {
      int mib[4];
      size_t kf_len = 0;
      char *kf_buf, *kf_bufp;
      size_t filelen;

      if (fd < 0)
	{
	  __set_errno (EBADF);
	  return -1;
	}

      filelen = strlen (file);
      if (__builtin_expect (filelen == 0, 0))
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

      kf_buf = alloca (kf_len + filelen);
      if (__sysctl (mib, 4, kf_buf, &kf_len, NULL, 0) != 0)
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
	      if (kf->kf_type != KF_TYPE_VNODE ||
		  kf->kf_vnode_type != KF_VTYPE_VDIR)
		{
		  __set_errno (ENOTDIR);
		  return -1;
		}

	      strcat (kf->kf_path, "/");
	      strcat (kf->kf_path, file);
	      file = kf->kf_path;
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

  if (flag & AT_SYMLINK_NOFOLLOW)
    return __lxstat64 (vers, file, st);
  else
    return __xstat64 (vers, file, st);
#endif
}

libc_hidden_def (__fxstatat64)
stub_warning(fstatat64)
