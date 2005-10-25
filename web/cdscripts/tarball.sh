#!/bin/bash
#
# Build-Depends: mkisofs, crosshurd, fakeroot
#
# Copyright 2004, 2005  Robert Millan <rmh@aybabtu.com>
# See /usr/share/common-licenses/GPL for license terms.

set -ex

if [ "$UID" != "0" ] ; then
  # I call that incest, don't you?
  sudo $0 $@
  exit 0
fi

if ! dpkg -s crosshurd > /dev/null ; then
  echo Install crosshurd and try again
  exit 1
fi

tmp=`mktemp -d`
pwd=`pwd`
export GZIP=--best

for i in dhcp3-client popularity-contest ; do
  if ! grep -qx $i /etc/crosshurd/packages/{common,kfreebsd-gnu} ; then
    echo "Please add $i to /etc/crosshurd/packages/"
    exit 1
  fi
done

if test -e base.tgz ; then
  tar --same-owner -xzpf base.tgz -C ${tmp}
else
  /usr/share/crosshurd/makehurddir.sh ${tmp} i486 kfreebsd-gnu
fi

if test -e native-install ; then
  cp native-install ${tmp}/
fi

# having dialog pre-installed makes it a bit prettier
dpkg --extract ${tmp}/var/cache/apt/archives/dialog_*.deb ${tmp}/

# this command is called by f-i after untarring, let's exploit that
cp startup ${tmp}/bin/mtree
chmod +x ${tmp}/bin/mtree

# crosshurd gathers some defaults from host machine, we don't really want that
echo -n > ${tmp}/etc/resolv.conf
echo "127.0.0.1		localhost" > ${tmp}/etc/hosts
echo debian > ${tmp}/etc/hostname

if test -e ${pwd}/base.tgz ; then
  mv ${pwd}/base.tgz{,.old}
fi
(cd ${tmp} && tar --same-owner -czpf ${pwd}/base.tgz ./*)
rm -rf ${tmp} ${pwd}/base.tgz.old
