#include <stdio.h>

main ()
  {
    if (gethostbyname ("www.debian.org") == NULL)
      perror ("gethostbyname");
    else
      printf ("Success\n");
  }
