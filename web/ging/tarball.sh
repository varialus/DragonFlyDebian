#!/bin/bash
#
# Build-Depends: mkisofs, crosshurd, fakeroot
#
# Copyright 2004, 2005  Robert Millan <rmh@aybabtu.com>
# See /usr/share/common-licenses/GPL for license terms.

set -ex

if [ "$UID" != "0" ] ; then
  sudo $0 $@
  exit 0
fi

if ! dpkg -s crosshurd > /dev/null ; then
  echo Install crosshurd and try again
  exit 1
fi

. vars

tmp1=`mktemp -d`

# BEGIN package stuff
######################################################################
/usr/share/crosshurd/makehurddir.sh ${tmp1} ${cpu} ${system}

cat > ${tmp1}/etc/apt/apt.conf << __EOF__
APT::Get::AllowUnauthenticated "yes";
__EOF__
mount -t devfs null ${tmp1}/dev
chroot ${tmp1} /native-install

if test -e ./packages ; then packages=`grep -v "^#" ./packages | tr "\n" " "` ; fi
chroot ${tmp1} apt-get update
chroot ${tmp1} apt-get -y install ${packages} || true
######################################################################
# END package stuff

chroot ${tmp1} apt-get clean

set +x
echo "Spawning a shell.  The following packages are supposedly installed:"
echo ${packages}
echo "System size: `du -hs ${tmp1}`"
chroot ${tmp1} || true
set -x

chroot ${tmp1} apt-get clean
rm -f ${tmp1}/native-install

# everything must be unmounted before tarring
umount -f ${tmp1}/dev
umount -f ${tmp1}/proc

cd ${tmp1} && tar --same-owner -czpf ${pwd}/base.tgz ./*
rm -rf ${tmp1}
