#include <stdio.h>
#include <sched.h>
#include <errno.h>

/*
  sched_getparam () returns a weird priority value.

  Examples: -1045002480, -1047721320, -1051899692, -1045637360 ...

  This is an upstream bug in the kernel (see kern/76485).  Since we use
  LinuxThreads, threads are processes too and thread priorities have weird
  values too.

  As a result, libgthread (from glib) when built on these conditions produces
  runtime errors that break gnome-terminal, nautilus, etc.
  (we have a hacked libgthread that won't do this, though)
*/

int
main ()
{
  struct sched_param sched;

  if (sched_getparam (getpid (), &sched) == -1)
    {
      perror ("sched_getparam");
      return 1;
    }

  printf ("priority = %d\n", sched.sched_priority);

  return 0;
}
