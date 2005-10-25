#!/bin/bash
#
# Build-Depends: mkisofs, crosshurd, sudo
#
# Copyright 2004, 2005 Robert Millan <rmh@aybabtu.com>
# See /usr/share/common-licenses/GPL for license terms.

set -ex

version=`date +%Y%m%d`
freebsd=5.4
cpu=i386
cdname=debian-${version}-kfreebsd-${cpu}-install.iso

if [ "$UID" != "0" ] ; then
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

installer="${freebsd}-RELEASE-${cpu}-bootonly.iso"

if ! test -e ${installer} ; then
  wget -c ftp://ftp.freebsd.org/pub/FreeBSD/ISO-IMAGES-${cpu}/${freebsd}/${installer}
fi

if ! test -e base.tgz ; then ./tarball.sh ; fi

# get kernel and loader (this must be before loader.conf, so that it gets overwritten)
tmp1=`mktemp -d`
tar -C ${tmp1} -xzf base.tgz
for i in ${tmp1}/var/cache/apt/archives/kfreebsd-{loader,image-5.*-486}_*_kfreebsd-i386.deb ; do \
  dpkg --extract ${i} ${tmp}/
done
rm -rf ${tmp1}

# get some stuff from freebsd image
case `uname -s` in
  Linux) mount ./${installer} /mnt -o loop ;;
  GNU/kFreeBSD) echo FIXME ; exit 1 ;;
esac
cp /mnt/boot/{loader.conf,mfsroot.gz} ${tmp}/boot/
cp /mnt/cdrom.inf ${tmp}/
umount -d /mnt

# copy our base into it
mkdir ${tmp}/base/
cp base.tgz ${tmp}/base/

# hack for being a FreeBSD compliant [tm] cdrom
ln -sf . ${tmp}/${freebsd}-RELEASE

# "persuade" sysinstall to tell the user to switch to ttyv2
tmp1=`mktemp`
gunzip -c ${tmp}/boot/mfsroot.gz > ${tmp1}
# this is very tricky.  we're editing an ELF file inside an UFS image.  just
# make sure both strings have exactly the same size, and everything will work
sed -e "s,Attempting to install all selected distributions\.\.,Press ALT-F3 to proceed with GNU/kFreeBSD setup...,g" \
< ${tmp1} | gzip -c9 > ${tmp}/boot/mfsroot.gz
rm -f ${tmp1}

#########################
#                    ignition!
#################################
# -V argument *must* be 32 char long at most, we have 18 chars for $version + $cpu
(cd ${tmp} && mkisofs -b boot/cdboot -no-emul-boot \
  -r -J -V "Debian $version $cpu Bin-1" \
  -o ${pwd}/${cdname} .)

rm -rf ${tmp} &
