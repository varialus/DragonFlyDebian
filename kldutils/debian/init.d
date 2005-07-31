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
for i in load stat unload ; do
  test -x /sbin/kld$i || exit 1
done
modules="`sed -e \"s/#.*//g\" -e \"/^\( \|\t\)*$/d\" /etc/modules`"

set -e

[ "${modules}" != "" ]

case "$1" in
  start)
	echo -n "Loading kernel modules:"
	for i in ${modules} ; do
	  if ! kldstat -n $i >/dev/null 2>/dev/null ; then
	    kldload $i
	    echo -n " $i"
	  else
	    echo -n " $i (already loaded)"
	  fi
	done
	echo "."
	;;
  stop)
	echo -n "Unloading kernel modules:"
	for i in ${modules} ; do
	  if kldstat -n $i >/dev/null 2>/dev/null ; then
	    kldunload $i
	    echo -n " $i"
	  else
	    echo -n " $i (not loaded)"
	  fi
	done
	echo "."
	;;
  *)
	echo "Usage: $0 {start|stop}" >&2
	exit 1
	;;
esac

exit 0
