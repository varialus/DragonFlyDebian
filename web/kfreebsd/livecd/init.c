/*
 * init wrapper for GNU/kFreeBSD
 *
 * $Id$
 *
 * Copyright (C) 2003  Robert Millan <rmh@debian.org>
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

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/stat.h>

/* kFreeBSD stuff */
#include <sys/param.h>
#include <sys/mount.h>
#include <isofs/cd9660/cd9660_mount.h>

/* how about /dev/ttyv0 ? */
#ifndef TTY
#define TTY "/dev/console"
#endif

static char *device;
static char *fstype;
static char *init;

int init_abort ();
#ifndef __GLIBC__
int getline (char **lineptr, size_t *n, FILE *stream)
{ return 1; }
#endif

int
main ()
{
  size_t sz;
  int len, pid, err;
  struct iso_args iso;
  struct stat my_stat;

  close (0); close (1); close (2);

  int tty = open (TTY, O_RDWR);
  dup (0); dup (0);

  stdin = fdopen (0, "r");
  if (stdin == NULL)
    exit (errno);
  stdout = fdopen (1, "w");
  if (stdout == NULL)
    exit (errno);
  stderr = fdopen (2, "w");
  if (stderr == NULL)
    exit (errno);

  if (fprintf (stdout, "stdout works\n") < 0)
    exit (errno);
  if (fprintf (stderr, "stderr works\n") < 0)
    exit (errno);

  printf ("\nDevice [/dev/acd0]: ");
  device = NULL; sz = 0;
  len = getline (&device, &sz, stdin);
  if (len == 1)
    device = strdup ("/dev/acd0");
  else
    device[len - 1] = '\0';

/*
  printf ("Fstype [cd9660]: ");
  fstype = NULL; sz = 0;
  len = getline (&fstype, &sz, stdin);
  if (len == 1)
*/
    fstype = strdup ("cd9660");
/*
  else
    fstype[len - 1] = '\0';
*/

  printf ("Init [/sbin/init]: ");
  init = NULL; sz = 0;
  len = getline (&init, &sz, stdin);
  if (len == 1)
    init = strdup ("/bin/bash");
  else
    init[len - 1] = '\0';

  if ((stat ("/mnt", &my_stat) == -1) && (errno = ENOENT))
    {
      fprintf (stderr, "/mnt does not exist, creating\n");
      if (mkdir ("/mnt", 0755) == -1)
        {
          fprintf (stderr, "mkdir failed: %s\n", strerror (errno));
          init_abort ();
        }
    }

  printf ("mount -t %s %s /mnt\n", fstype, device);
  iso.fspec = device;
  iso.flags = ISOFSMNT_EXTATT;
  err = mount (fstype, "/mnt", MNT_RDONLY, &iso);
  if (err == -1)
    {
      fprintf (stderr, "mount failed: %s\n", strerror (errno));
      init_abort ();
    }

/*
  printf ("mount -t devfs devfs /mnt/dev\n");
  err = mount ("devfs", "/mnt/dev", 0, "devfs");
  if (err == -1)
    {
      fprintf (stderr, "mount failed: %s\n", strerror (errno));
      init_abort ();
    }
*/

  pid = fork ();
  switch (pid)
    {
      case -1:
        fprintf (stderr, "fork() failed: %s\n", strerror (errno));
        break;
      case 0:
        printf ("chroot /mnt\n");
        if (chroot ("/mnt") == -1)
          {
            fprintf (stderr, "chroot() failed: %s\n", strerror (errno));
            init_abort ();
          }
        printf ("chdir /\n");
        if (chdir ("/") == -1)
          {
            fprintf (stderr, "chdir() failed: %s\n", strerror (errno));
            init_abort ();
          }
        printf ("executing %s -i\n", init);
        execl (init, init, "-i", NULL);
        fprintf (stderr, "execl() failed: %s\n", strerror (errno));
        exit (1);
      default:
        waitpid (pid, NULL, 0);
    }

  init_abort ();

  /* should never reach this point, but we want gcc happy */
  return 0;
}

int
init_abort ()
{
  int pid;
  int err;

/*
  printf ("umount /mnt/dev\n");
  err = unmount ("/mnt/dev", 0);
  if (err == -1)
    {
      fprintf (stderr, "unmount failed: %s\n", strerror (errno));
    }
*/

  printf ("umount /mnt\n");
  err = unmount ("/mnt", 0);
  if (err == -1)
    {
      fprintf (stderr, "unmount failed: %s\n", strerror (errno));
    }


  free (device);
  free (fstype);
  free (init);
  fprintf (stderr, "init: Aborted.\n");

  /* loop forever, so that user can read errors */
  while (1) {};

  /* should never reach this point, but we want gcc happy */
  return 0;
}

