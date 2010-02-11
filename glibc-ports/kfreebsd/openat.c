/* Copyright (C) 2005, 2006, 2007 Free Software Foundation, Inc.
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
#include <stdarg.h>
#include <stddef.h>
#include <stdio.h>
#include <unistd.h>
#include <sysdep.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/sysctl.h>
#include <sys/user.h>
#include <kernel-features.h>
#include <sysdep-cancel.h>
#include <not-cancel.h>

extern int __syscall_openat (int fd, const char *path, int flag, mode_t mode);
libc_hidden_proto (__syscall_openat)

# ifndef __ASSUME_ATFCTS
int __have_atfcts = 0;
#endif

/* Open FILE with access OFLAG.  Interpret relative paths relative to
   the directory associated with FD.  If OFLAG includes O_CREAT, a
   third argument is the file protection.  */
int
__openat_nocancel (fd, file, oflag, mode)
     int fd;
     const char *file;
     int oflag;
     mode_t mode;
{
# ifndef __ASSUME_ATFCTS
  if (__have_atfcts >= 0)
# endif
    {
      int result = INLINE_SYSCALL (openat, 4, fd, file, oflag, mode);
# ifndef __ASSUME_ATFCTS
      if (result == -1 && errno == ENOSYS)
	__have_atfcts = -1;
      else
# endif
	return result;
    }

#ifndef __ASSUME_ATFCTS
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
  return INLINE_SYSCALL (open, 3, file, oflag, mode);
#endif
}

strong_alias (__openat_nocancel, __openat64_nocancel)

/* Open FILE with access OFLAG.  Interpret relative paths relative to
   the directory associated with FD.  If OFLAG includes O_CREAT, a
   third argument is the file protection.  */
int
__openat (fd, file, oflag)
     int fd;
     const char *file;
     int oflag;
{
  int mode = 0;
  int result;

  if (oflag & O_CREAT)
    {
      va_list arg;
      va_start (arg, oflag);
      mode = va_arg (arg, int);
      va_end (arg);
    }

# ifndef __ASSUME_ATFCTS
  if (__have_atfcts >= 0)
# endif
    {
      if (SINGLE_THREAD_P)
	{
	  result = INLINE_SYSCALL (openat, 4, fd, file, oflag, mode);
	}
      else
	{
	  int oldtype = LIBC_CANCEL_ASYNC ();
	  result = INLINE_SYSCALL (openat, 4, fd, file, oflag, mode);
	  LIBC_CANCEL_RESET (oldtype);
	}
# ifndef __ASSUME_ATFCTS
      if (result == -1 && errno == ENOSYS)
	__have_atfcts = -1;
# endif
    }

#ifndef __ASSUME_ATFCTS
  if (__have_atfcts < 0)
    {
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
      if (SINGLE_THREAD_P)
	{
	  result = INLINE_SYSCALL (open, 3, file, oflag, mode);
	}
      else
	{
	  int oldtype = LIBC_CANCEL_ASYNC ();
	  result = INLINE_SYSCALL (open, 3, file, oflag, mode);
	  LIBC_CANCEL_RESET (oldtype);
	}

    }
#endif

#if 0
/* At least 8.0 kernel seems be fine and this workaround does not respect "sysctl vfs.timestamp_precision" */

  if (result >= 0 && (oflag & O_TRUNC))
    {
      /* Set the modification time.  The kernel ought to do this.  */
      int saved_errno = errno;
      struct timeval tv[2];

      if (__gettimeofday (&tv[1], NULL) >= 0)
	{
	  struct stat statbuf;

	  if (__fxstat (_STAT_VER, result, &statbuf) >= 0)
	    {
	      tv[0].tv_sec = statbuf.st_atime;
	      tv[0].tv_usec = 0;

#ifdef NOT_IN_libc
	      futimes (fd, tv);
#else
	      __futimes (fd, tv);
#endif
	    }
	}
      __set_errno (saved_errno);
    }
#endif

  return result;
}

libc_hidden_def (__openat)
weak_alias (__openat, openat)

/* 'openat64' is the same as 'openat', because __off64_t == __off_t.  */
strong_alias (__openat, __openat64)
libc_hidden_def (__openat64)
weak_alias (__openat64, openat64)

int
__openat_2 (fd, file, oflag)
     int fd;
     const char *file;
     int oflag;
{
  if (oflag & O_CREAT)
    __fortify_fail ("invalid openat call: O_CREAT without mode");

  return __openat (fd, file, oflag);
}

strong_alias (__openat_2, __openat64_2)
stub_warning(openat)
stub_warning(openat64)
