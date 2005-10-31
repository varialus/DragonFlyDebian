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

if test -d ./tmp ; then
  echo ./tmp already exists, aborting
  exit 1
fi

# BEGIN package stuff
######################################################################
/usr/share/crosshurd/makehurddir.sh ./tmp ${cpu} ${system}

cat > ./tmp/etc/apt/apt.conf << __EOF__
APT::Get::AllowUnauthenticated "yes";
__EOF__
mount -t devfs null ./tmp/dev
chroot ./tmp /native-install

if test -e ./packages ; then
  packages=`grep -v "^#" ./packages | tr "\n" " "`
  if [ "${OPTS}" = "qemu" ] ; then
    packages=`echo "${packages}" | sed -e "s/\(kfreebsd-image-[^ ]*\)-.86/\1-686/g"`
  fi
fi

chroot ./tmp apt-get update
chroot ./tmp apt-get -y install ${packages} || true
######################################################################
# END package stuff

chroot ./tmp apt-get clean

set +x
echo "The following packages are supposedly installed: ${packages}"
echo "System size: `du -hs ./tmp`"
set -x

chroot ./tmp apt-get clean
rm -f ./tmp/native-install

# unmounted everything when done
umount -f ./tmp/dev
umount -f ./tmp/proc
