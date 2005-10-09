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

if test -e base.tgz ; then
  tar --same-owner -xzpf base.tgz -C ${tmp}
else
  /usr/share/crosshurd/makehurddir.sh ${tmp} i486 kfreebsd-gnu
fi

# !!!! FIXME: ultra-ugly hack!!
base_url="http://ftp.gnuab.org/debian/pool-kfreebsd-i386/main/k/kfreebsd-5"
(cd ${tmp}/var/cache/apt/archives/ && \
  wget -c ${base_url}/kfreebsd-image-5{,.4-1}-{4,5,6}86_5.4-1_kfreebsd-i386.deb)

if test -e native-install ; then
  cp native-install ${tmp}/
fi

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
