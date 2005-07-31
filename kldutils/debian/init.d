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
modules="`shopt -s nullglob ; cat /etc/modules /etc/modules.d/* | sed -e \"s/#.*//g\" -e \"/^\( \|\t\)*$/d\"`"

set -e

[ "${modules}" != "" ]

case "$1" in
  start)
	for i in ${modules} ; do
	  if ! kldstat -n $i >/dev/null 2>/dev/null ; then
	    echo "Loading $i ..."
	    kldload $i
	  else
	    echo "Not loading $i (already loaded)"
	  fi
	done
	;;
  stop)
	for i in ${modules} ; do
	  if kldstat -n $i >/dev/null 2>/dev/null ; then
	    echo "Unloading $i ..."
	    kldunload $i
	  else
	    echo "Not unloading $i (not loaded)"
	  fi
	done
	;;
  *)
	echo "Usage: $0 {start|stop}" >&2
	exit 1
	;;
esac

exit 0
