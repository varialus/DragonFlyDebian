/*
 * init wrapper for GNU/kFreeBSD
 *
 * $Id$
 *
 * Copyright 2003,2004  Robert Millan <rmh@debian.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */

#define _GNU_SOURCE 1 /* getline */

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <fcntl.h>
#include <string.h>

#include <sys/param.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/syscall.h>
#ifndef SYS_nmount
#define SYS_nmount 378
#endif

#include "uio.h"
#include "mount.h" /* unmount */

/* how about /dev/ttyv0 ? */
#ifndef TTY
#define TTY "/dev/console"
#endif

extern int pmount (char *, char *, int, void *);

int
main (int argc, char **argv)
{
  size_t sz;
  int len;
  struct stat my_stat;
  struct iovec iov[4];

  char *device;
  char *fstype;
  char *init;

  close (2); /* stderr */
  open (TTY, O_WRONLY);
  stderr = fdopen (2, "w");
  if (stderr == NULL)
    exit (1);
  if (fprintf (stderr, "stderr works\n") < 0)
    exit (2);

  close (1); /* stdout */
  dup (2);
  stdout = fdopen (1, "w");
  if (stdout == NULL)
    {
      fprintf (stderr, "fdopen: failed for stdout\n");
      while (1);
    }
  if (fprintf (stdout, "stdout works\n") < 0)
    {
      fprintf (stderr, "fprintf: failed for stdout\n");
      while (1);
    }

  close (0); /* stdin */
  open (TTY, O_RDONLY);
  stdin = fdopen (0, "r");
  if (stdin == NULL)
    {
      fprintf (stderr, "fdopen: failed for stdin\n");
      while (1);
    }

  printf ("\nDevice [/dev/acd0]: ");
  device = NULL; sz = 0;
  len = getline (&device, &sz, stdin);
  if (len == 1)
    device = strdup ("/dev/acd0");
  else
    device[len - 1] = '\0';

  printf ("Fstype [cd9660]: ");
  fstype = NULL; sz = 0;
  len = getline (&fstype, &sz, stdin);
  if (len == 1)
    fstype = strdup ("cd9660");
  else
    fstype[len - 1] = '\0';

  printf ("Init [/bin/bash]: ");
  init = NULL; sz = 0;
  len = getline (&init, &sz, stdin);
  if (len == 1)
    init = strdup ("/bin/bash");
  else
    init[len - 1] = '\0';

  if ((stat ("/mnt", &my_stat) == -1) && (errno = ENOENT))
    {
      fprintf (stderr, "warning: creating /mnt\n");
      if (mkdir ("/mnt", 0755) == -1)
        {
          fprintf (stderr, "mkdir failed: %s\n", strerror (errno));
          goto init_abort;
        }
    }

  /* cd9660 mount */
  printf ("mount -t %s %s /mnt\n", fstype, device);
  if (pmount (fstype, "/mnt", 0, (void *) device) != 0)
    {
      fprintf (stderr, "pmount failed: %s\n", strerror (errno));
      goto init_abort;
    }
  free (device);
  free (fstype);

  /* devfs mount */
  iov[0].iov_base = "fstype";
  iov[0].iov_len = sizeof("fstype");
  iov[1].iov_base = "devfs";
  iov[1].iov_len = strlen(iov[1].iov_base) + 1;;
  iov[2].iov_base = "fspath";
  iov[2].iov_len = sizeof("fspath");
  iov[3].iov_base = "/mnt/dev";
  iov[3].iov_len = sizeof("/mnt/dev");
  printf ("mount -t devfs devfs /mnt/dev\n");
  if (syscall (SYS_nmount, iov, 4, 0) == -1)
    {
      fprintf (stderr, "mount failed: %s\n", strerror (errno));
      goto init_abort;
    }

  /* chroot */
  printf ("chroot /mnt/\n");
  if (chroot ("/mnt/") == -1)
    {
      fprintf (stderr, "chroot() failed: %s\n", strerror (errno));
      goto init_abort;
    }
  printf ("chdir /\n");
  if (chdir ("/") == -1)
    {
      fprintf (stderr, "chdir() failed: %s\n", strerror (errno));
      goto init_abort;
    }

  /* fuck() off */
  int pid = fork ();

  if (pid > 0) while (1);

  char *new_argv[2];
  new_argv[0] = strdup (init);
  new_argv[1] = NULL;

  char *env[1];
  env[0] = NULL;

  printf ("process %d executing %s\n", getpid(), init);
  syscall (SYS_execve, init, new_argv, env);
  fprintf (stderr, "execl() failed: %s\n", strerror (errno));

init_abort:

  printf ("umount /dev\n");
  if (unmount ("/dev", 0) == -1)
    fprintf (stderr, "unmount failed: %s\n", strerror (errno));

  printf ("umount /mnt\n");
  if (unmount ("/mnt", 0) == -1)
    fprintf (stderr, "unmount failed: %s\n", strerror (errno));

  free (device);
  free (fstype);
  free (init);
  fprintf (stderr, "init: Aborted.\n");

  /* loop forever, so that user can read errors */
  while (1);

  /* should never reach this point, but we want gcc happy */
  return 0;
}
