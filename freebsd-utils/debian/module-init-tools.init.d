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
  which kld$i >/dev/null || exit 1
done
modules="`shopt -s nullglob ; cat /etc/modules /etc/modules.d/* \
  | sed -e \"s/#.*//g\" -e \"/^\( \|\t\)*$/d\" | sort | uniq`"

set -e

for i in ${modules} ; do
  if ! kldstat -n $i >/dev/null 2>/dev/null ; then
    echo "Loading $i ..."
    kldload $i || true
    echo "... done."
  else
    echo "Not loading $i (already loaded)"
  fi
done

exit 0
