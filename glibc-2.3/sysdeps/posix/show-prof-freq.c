/* Show the profiler frequency.  Use for porting __profile_frequency().
   Copyright (C) 2002 Free Software Foundation, Inc.
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

/* This program shows the profiler frequency.  Its purpose it to port
   __profile_frequency().  Note that you should avoid to put immediate
   constants into the implementation of __profile_frequency() if the
   information is also available through a kernel API; but this program
   can at least help you choosing the right API.  */

#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <sys/time.h>

struct timeval start_time;
struct timeval end_time;

int counter;

static void prof_handler ()
{
  counter++;
}

static void int_handler ()
{
  /* Take end time.  */
  gettimeofday (&end_time, NULL);

  printf ("\n");
  printf ("Number of ITIMER_PROF ticks: %d\n", counter);
  printf ("Frequency of ITIMER_PROF ticks: %g / sec\n",
	  (double) counter
	  / ((end_time.tv_sec + 1e-6 * end_time.tv_usec)
	     - (start_time. tv_sec + 1e-6 * start_time.tv_usec)));
  printf ("For comparison: CLK_TCK = %d\n", CLK_TCK);
  exit (0);
}

int main ()
{
  struct sigaction act;
  struct itimerval timer;

  printf ("Calibrating...\n");

  signal (SIGINT, int_handler);
  signal (SIGALRM, int_handler);

  /* Set up the profiling action.  */
  act.sa_handler = prof_handler;
  act.sa_flags = SA_RESTART;
  sigfillset (&act.sa_mask);
  sigaction (SIGPROF, &act, NULL);

  /* Take start time.  */
  gettimeofday (&start_time, NULL);

  /* Start profiling timer.  */
  timer.it_value.tv_sec  = 0;
  timer.it_value.tv_usec = 1;
  timer.it_interval.tv_sec  = 0;
  timer.it_interval.tv_usec = 1;
  setitimer (ITIMER_PROF, &timer, NULL);

  alarm (10);

  for (;;);
}
