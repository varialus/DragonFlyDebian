#!/bin/bash
#
# Copyright 2005 Robert Millan <rmh@aybabtu.com>
# See /usr/share/common-licenses/GPL for license terms.
set -ex

if [ "$UID" != "0" ] ; then
  sudo $0 $@
  exit 0
fi

if ! test -d tmp ; then ./tarball.sh ; fi

. vars
mnt=`mktemp -d`

rm -f mfsroot${dot_gz}

dd if=/dev/zero of=mfsroot bs=1M count=8
md=`mdconfig -a -t vnode -f mfsroot`
mkfs.ufs /dev/${md}
mount /dev/${md} ${mnt}

mkdir -p ${mnt}/{lib,sbin,dev,cdrom,ramdisk,cloop}

sed -e "s/@version@/${version}/g" -e "s/@ramdisk_size@/${ramdisk_size}/g" \
  "s/@distribution@/${distribution}/g" -e "s/@distribution_lowcase@/${distribution_lowcase}/g"
< startup > ${mnt}/sbin/init
chmod 755 ${mnt}/sbin/init

for i in \
  /bin/sh /bin/bash \
    /lib/ld.so.1 /lib/libc.so.0.1 /lib/libncurses.so.5 /lib/libdl.so.2 \
  /sbin/mdconfig \
    /libexec/ld-elf.so.1 /lib/libc.so.5 \
  /sbin/mount_cd9660 \
    /lib/libkiconv.so.1 \
  ${NULL}
do
  mkdir -p ${mnt}/$i
  rmdir ${mnt}/$i
  cp tmp/$i ${mnt}/$i
done

umount ${mnt}
mdconfig -d -u ${md}
rmdir ${mnt}

if [ "${OPTS}" != "qemu" ] ; then
  ${gzip} mfsroot
fi
