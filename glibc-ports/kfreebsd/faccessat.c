/* Test for access to file, relative to open directory.  Linux version.
   Copyright (C) 2006 Free Software Foundation, Inc.
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
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#include <sys/user.h>
#include <kernel-features.h>
#include <sysdep.h>

extern int __syscall_faccessat (int fd, const char *path, int mode, int flag);
libc_hidden_proto (__syscall_faccessat)

int
faccessat (fd, file, mode, flag)
     int fd;
     const char *file;
     int mode;
     int flag;
{
# ifndef __ASSUME_ATFCTS
  if (__have_atfcts >= 0)
# endif
    {
      int result = INLINE_SYSCALL (faccessat, 4, fd, file, mode, flag);
# ifndef __ASSUME_ATFCTS
      if (result == -1 && errno == ENOSYS)
	__have_atfcts = -1;
      else
# endif
	return result;
    }

#ifndef __ASSUME_ATFCTS
  if (flag & ~(AT_SYMLINK_NOFOLLOW | AT_EACCESS))
    {
      __set_errno (EINVAL);
      return -1;
    }

  if ((!(flag & AT_EACCESS) || !__libc_enable_secure)
      && !(flag & AT_SYMLINK_NOFOLLOW))
    {
      /* If we are not set-uid or set-gid, access does the same.  */
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
	      struct kinfo_file *kf =
		(struct kinfo_file *) (uintptr_t) kf_bufp;

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

      return __access (file, mode);
    }
#endif

  struct stat64 stats;
  if (fstatat64 (fd, file, &stats, flag & AT_SYMLINK_NOFOLLOW))
    return -1;

  mode &= (X_OK | W_OK | R_OK);	/* Clear any bogus bits. */
#if R_OK != S_IROTH || W_OK != S_IWOTH || X_OK != S_IXOTH
# error Oops, portability assumptions incorrect.
#endif

  if (mode == F_OK)
    return 0;			/* The file exists. */

  uid_t uid = (flag & AT_EACCESS) ? __geteuid () : __getuid ();

  /* The super-user can read and write any file, and execute any file
     that anyone can execute. */
  if (uid == 0 && ((mode & X_OK) == 0
		   || (stats.st_mode & (S_IXUSR | S_IXGRP | S_IXOTH))))
    return 0;

  int granted = (uid == stats.st_uid
		 ? (unsigned int) (stats.st_mode & (mode << 6)) >> 6
		 : (stats.st_gid == ((flag & AT_EACCESS)
				     ? __getegid () : __getgid ())
		    || __group_member (stats.st_gid))
		 ? (unsigned int) (stats.st_mode & (mode << 3)) >> 3
		 : (stats.st_mode & mode));

  if (granted == mode)
    return 0;

  __set_errno (EACCES);
  return -1;
}
stub_warning(faccessat)
