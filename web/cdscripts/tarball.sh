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

. config

tmp=`mktemp -d`

for i in dhcp3-client popularity-contest netbase ; do
  if ! grep -qx $i /etc/crosshurd/packages/{common,kfreebsd-gnu} ; then
    echo "Please add $i to /etc/crosshurd/packages/"
    exit 1
  fi
done

if test -e base.tgz ; then
  tar --same-owner -xzpf base.tgz -C ${tmp}
else
  /usr/share/crosshurd/makehurddir.sh ${tmp} ${DEB_HOST_GNU_CPU} kfreebsd-gnu
fi

if test -e native-install ; then
  cp native-install ${tmp}/
fi

# copy localdebs into the directory tree
if test -d localdebs ; then
  cp localdebs/* ${tmp}/var/cache/apt/archives/
fi

# having dialog pre-installed makes it a bit prettier
for i in dialog libncursesw5 ; do
  dpkg --extract ${tmp}/var/cache/apt/archives/${i}_*.deb ${tmp}/
done

# extract libraries needed by freebsd-utils. Dunno why crosshurd 
# does not do that itself
for i in libbsd0 libfreebsd0 ; do
  dpkg --extract ${tmp}/var/cache/apt/archives/${i}_*.deb ${tmp}/
done

# Remove the root passwd
sed -i -e 's#^root:\*:0*#root::0#g' ${tmp}/usr/share/base-passwd/passwd.master

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
