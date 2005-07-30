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

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
test -x /sbin/kldload || exit 1
modules="`grep -vs \"^#\" /etc/modules`"

set -e

[ "${modules}" != "" ]

case "$1" in
  start)
	echo -n "Loading kernel modules:"
	for i in ${modules} ; do
	  kldload $i
	  echo -n " $i"
	done
	echo "."
	;;
  stop)
	echo -n "Unloading kernel modules:"
	for i in ${modules} ; do
	  kldunload $i || true
	  echo -n " $i"
	done
	echo "."
	;;
  *)
	echo "Usage: $0 {start|stop}" >&2
	exit 1
	;;
esac

exit 0
