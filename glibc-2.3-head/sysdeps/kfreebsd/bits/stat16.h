/* Copyright (C) 2002 Free Software Foundation, Inc.
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

/* This structure corresponds to the original FreeBSD 'struct stat'
   (i.e. _STAT_VER_stat), and is used by the fhstat() system call.  */
struct stat16
  {
    __dev_t st_dev;		/* Device containing the file.  */
    __ino_t st_ino;		/* File serial number.  */

    __uint16_t st_mode;		/* File mode.  */
    __uint16_t st_nlink;	/* Link count.  */

    __uid_t st_uid;		/* User ID of the file's owner.  */
    __gid_t st_gid;		/* Group ID of the file's group.  */

    __dev_t st_rdev;		/* Device number, if device.  */

    long int st_atime;		/* Time of last access.  */
    long int st_atimensec;	/* Nanoseconds of last access.  */
    long int st_mtime;		/* Time of last modification.  */
    long int st_mtimensec;	/* Nanoseconds of last modification.  */
    long int st_ctime;		/* Time of last status change.  */
    long int st_ctimensec;	/* Nanoseconds of last status change.  */

    __off_t st_size;		/* Size of file, in bytes.  */

    __blkcnt_t st_blocks;	/* Number of 512-byte blocks allocated.  */

    __blksize_t st_blksize;	/* Optimal block size for I/O.  */

    __uint32_t st_flags;	/* User defined flags.  */

    __uint32_t st_gen;		/* Generation number.  */

    __uint32_t __unused1;
    __quad_t __unused2[2];
  };
