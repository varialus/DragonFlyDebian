#include <pthread.h>
#include <stdio.h>
#include <sys/syscall.h>

/*
  This code produces a segfault on kfreebsd-gnu

  Interestingly enough, if you replace syscall() with the Glibc
  sched_get_priority_max() function stub, the error disappears.  If you
  remove one of the two syscall() invocations (which are identical), the
  error also disappears.

  This could be the same bug that breaks emacs21 (segfault during install).

  It could be the same bug that breaks GNUstep, too:
  http://lists.alioth.debian.org/pipermail/glibc-bsd-devel/2004-December/000344.html
*/

main ()
  {
    printf ("%d\n", syscall (SYS_sched_get_priority_max, SCHED_OTHER));
    printf ("%d\n", syscall (SYS_sched_get_priority_max, SCHED_OTHER));
  }
