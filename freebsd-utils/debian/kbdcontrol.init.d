#! /bin/sh
#
# skeleton	example file to build /etc/init.d/ scripts.
#		This file should be used to construct scripts for /etc/init.d.
#
#		Written by Miquel van Smoorenburg <miquels@cistron.nl>.
#		Modified for Debian 
#		by Ian Murdock <imurdock@gnu.ai.mit.edu>.
#
# Version:	@(#)skeleton  1.9  26-Feb-2001  miquels@cistron.nl
#

set -e

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
which kbdcontrol >/dev/null

if test -e /etc/kbdcontrol.conf ; then
  echo -n "Loading console keymap..."
  kbdcontrol -l `grep -v ^# /etc/kbdcontrol.conf` < /dev/console
  echo "done."
fi

exit 0
