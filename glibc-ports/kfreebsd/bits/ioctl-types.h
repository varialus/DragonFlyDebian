/* Structure types for pre-termios terminal ioctls.  FreeBSD version.
   Copyright (C) 1996, 1997, 2002 Free Software Foundation, Inc.
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

#ifndef _SYS_IOCTL_H
# error "Never use <bits/ioctl-types.h> directly; include <sys/ioctl.h> instead."
#endif

/* Type of ARG for TIOCGETC and TIOCSETC requests.  */
/* struct tchars is defined in <sys/ioctl_compat.h> */
#define	_IOT_tchars	/* Hurd ioctl type field.  */ \
  _IOT (_IOTS (char), 6, 0, 0, 0, 0)

/* Type of ARG for TIOCGLTC and TIOCSLTC requests.  */
/* struct ltchars is defined in <sys/ioctl_compat.h> */ 
#define	_IOT_ltchars	/* Hurd ioctl type field.  */ \
  _IOT (_IOTS (char), 6, 0, 0, 0, 0)

/* Type of ARG for TIOCGETP and TIOCSETP requests (and gtty and stty).  */
/* struct sgttyb  is defined in <sys/ioctl_compat.h> */
#define	_IOT_sgttyb	/* Hurd ioctl type field.  */ \
  _IOT (_IOTS (char), 6, _IOTS (short int), 1, 0, 0)

/* Type of ARG for TIOCGWINSZ and TIOCSWINSZ requests.  */
/* struct winsize is defined in <sys/ttycom.h> */
#define	_IOT_winsize	/* Hurd ioctl type field.  */ \
  _IOT (_IOTS (unsigned short int), 4, 0, 0, 0, 0)

/* Many systems that have TIOCGWINSZ define TIOCGSIZE for source
   compatibility with Sun; they define `struct ttysize' to have identical
   layout as `struct winsize' and #define TIOCGSIZE to be TIOCGWINSZ
   (likewise TIOCSSIZE and TIOCSWINSZ).  */
/* struct ttysize is in FreeBSD originally defined in <sys/ioctl.h>,
   which is replaced by GLIBC version -> define here */
struct ttysize
{
  unsigned short int ts_lines;
  unsigned short int ts_cols;
  unsigned short int ts_xxx;
  unsigned short int ts_yyy;
};
#define	_IOT_ttysize	_IOT_winsize
