/*
  Compatibility with k*BSD-based non-BSD systems (e.g. GNU/k*BSD)

  Copyright 2004, Robert Millan <robertmh@gnu.org>

  This code is PUBLIC DOMAIN. You can do anything you like with it, even
  remove this note. I'm not responsible for any bad consequences of using
  this code.
*/

#if defined(__FreeBSD__) && !defined(__FreeBSD_kernel__)
# define __FreeBSD_kernel__ __FreeBSD__
#endif
#ifdef __FreeBSD_kernel__
# include <osreldate.h>
# ifndef __FreeBSD_kernel_version
#  define __FreeBSD_kernel_version __FreeBSD_version
# endif
#endif

#if defined(__NetBSD__) && !defined(__NetBSD_kernel__)
# define __NetBSD_kernel__ __NetBSD__
#endif

#if defined(__OpenBSD__) && !defined(__OpenBSD_kernel__)
# define __OpenBSD_kernel__ __OpenBSD__
#endif
