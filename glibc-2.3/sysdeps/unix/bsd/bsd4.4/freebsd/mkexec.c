/* Make a shared library executable.
   Copyright (C) 2002 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by Bruno Haible <bruno@clisp.org>, 2002.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public License as
   published by the Free Software Foundation; either version 2 of the
   License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with the GNU C Library; see the file COPYING.LIB.  If not,
   write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA.  */

/* FreeBSD by default refuses to exec ld.so because it is build as a shared
   library.  We need to change its ELF e_type value from ET_DYN to ET_EXEC
   so that FreeBSD executes it.  */

#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <fcntl.h>

/* Simplified ELF header struct.  */
struct elf_header
{
  unsigned char e_ident[16];
  unsigned short e_type;
};

/* Values of e_type.  */
#define ET_EXEC	2
#define ET_DYN	3

int
main (int argc, char *argv[])
{
  int fd;
  struct elf_header hdr;

  if (argc != 2)
    {
      fprintf (stderr, "usage: mkexec ld.so\n");
      exit (1);
    }

  fd = open (argv[1], O_RDWR);
  if (fd < 0)
    {
      perror ("mkexec: open");
      exit (1);
    }

  lseek (fd, (off_t) 0, SEEK_SET);
  if (read (fd, &hdr, sizeof (hdr)) != sizeof (hdr))
    {
      perror("mkexec: read");
      exit (1);
    }

  if (hdr.e_type != ET_EXEC)
    {
      if (hdr.e_type != ET_DYN)
	{
	  fprintf (stderr, "mkexec: %s: not a shared library\n", argv[1]);
	  exit (1);
 	}

      hdr.e_type = ET_EXEC;

      lseek (fd, (off_t) 0, SEEK_SET);
      if (write (fd, &hdr, sizeof (hdr)) != sizeof (hdr))
	{
	  perror("mkexec: write");
	  exit (1);
	}
    }

  close (fd);

  return 0;
}
