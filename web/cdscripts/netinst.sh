#!/bin/bash
#
# Build-Depends: mkisofs, crosshurd, sudo
#
# Copyright 2004, 2005 Robert Millan <rmh@aybabtu.com>
# See /usr/share/common-licenses/GPL for license terms.

set -ex

version=unreleased
cdname=debian-${version}-kfreebsd-i386-netinst.iso

if [ "$UID" != "0" ] ; then
  # I call that incest, don't you?
  sudo $0 $@
  exit 0
fi

for i in mkisofs ; do
  if ! dpkg -s ${i} | grep -q "^Status: .* installed$" > /dev/null ; then
    echo Install ${i} and try again
    exit 1
  fi
done

pwd=`pwd`
tmp=`mktemp -d`

installer="5.4-RELEASE-i386-bootonly.iso"

if ! test -e ${installer} ; then
  wget -c ftp://ftp.freebsd.org/pub/FreeBSD/ISO-IMAGES-i386/5.4/${installer}
fi

if ! test -e base.tgz ; then ./tarball.sh ; fi

case `uname -s` in
  Linux) mount ./${installer} /mnt -o loop ;;
  GNU/kFreeBSD) echo FIXME ; exit 1 ;;
esac
cp -a /mnt/* ${tmp}/
umount /mnt
mkdir ${tmp}/base/
cp base.tgz ${tmp}/base/

# hacks for being a FreeBSD compliant [tm] cdrom
for i in 5 6 ; do for j in 0 1 2 3 4 5 6 7 8 9 ; do
  ln -sf . ${tmp}/$i.$j-RELEASE
done ; done

#########################
#                    ignition!
#################################
(cd ${tmp} && mkisofs -b boot/cdboot -no-emul-boot \
  -r -J -V mylabel -publisher mypublisher \
  -o ${pwd}/${cdname} .)

rm -rf ${tmp} &
