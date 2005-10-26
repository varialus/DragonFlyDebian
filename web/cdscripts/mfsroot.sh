#!/bin/bash
#
# Copyright 2005 Robert Millan <rmh@aybabtu.com>
# See /usr/share/common-licenses/GPL for license terms.
set -ex

if [ "$UID" != "0" ] ; then
  sudo $0 $@
  exit 0
fi

pwd=`pwd`
mnt=`mktemp -d`

rm -f mfsroot.gz

dd if=/dev/zero of=mfsroot bs=1M count=4
md=`mdconfig -a -t vnode -f mfsroot`
mkfs.ufs /dev/${md}
mount /dev/${md} ${mnt}

mkdir -p ${mnt}/{stand/etc,boot,lib}
for i in bin sbin ; do ln -s stand ${mnt}/$i ; done

cp /boot/{boot*,mbr} ${mnt}/boot/

# "persuade" sysinstall to tell the user to switch to ttyv2.  This is very tricky.
# We're editing an ELF file with sed.  Just make sure both strings have exactly
# the same size, and everything will work.
zcat sysinstall.gz | \
sed -e "s,Attempting to install all selected distributions\.\.,Press ALT-F3 to proceed with GNU/kFreeBSD setup...,g" \
< sysinstall > ${mnt}/stand/sysinstall
chmod 755 ${mnt}/stand/sysinstall

# freebsd commands.  always try to reduce this list!
for i in \
  -sh [ arp boot_crunch camcontrol cpio dhclient find fsck_ffs gunzip gzip \
  hostname ifconfig minigzip mount_nfs ppp pwd rm route rtsol sed sh \
  slattach test tunefs usbd usbdevs zcat
do
  ln ${mnt}/stand/sysinstall ${mnt}/stand/$i
done

# debian commands
for i in ld.so.1 libc.so.0.1 libufs.so.2 ; do
  cp /lib/$i ${mnt}/lib/
done
cp `which mkfs.ufs` ${mnt}/stand/newfs

umount ${mnt}
mdconfig -d -u ${md}

gzip -9 mfsroot
