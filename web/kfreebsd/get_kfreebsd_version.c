/*
  get_kfreebsd_version. A function that emulates __FreeBSD_*version macro
  values in runtime by gathering information from uname ().

  Copyright 2004, Robert Millan <robertmh@gnu.org>

  This code is PUBLIC DOMAIN. You can do anything you like with it, even
  remove this note. I'm not responsible for any bad consequences of using
  this code.
*/

#include <sys/utsname.h>
int
get_kfreebsd_version ()
{
  struct utsname uts;
  int major; int minor, v[2];

  uname (&uts);
  sscanf (uts.release, "%d.%d", &major, &minor);

  /* __FreeBSD_version scheme doesn't support two-digit major numbers */
  if (major >= 9)
    major = 9;

  /* The two minor number digits were strangely swapped before 5.x */
  if (major >= 5)
    {
      v[0] = minor/10;
      v[1] = minor%10;
    }
  else
    {
      v[0] = minor%10;
      v[1] = minor/10;
    }
  return major*100000+v[0]*10000+v[1]*1000;
}
