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

mkdir -p ${mnt}/{boot,dev,etc,lib,stand/etc}
for i in bin sbin ; do ln -s stand ${mnt}/$i ; done

cp /boot/{boot*,mbr} ${mnt}/boot/

# "persuade" sysinstall to tell the user to switch to ttyv2.  This is very tricky.
# We're editing an ELF file with sed.  Just make sure both strings have exactly
# the same size, and everything will work.
sed sysinstall \
  -e "s,Attempting to install all selected distributions\.\.,Press ALT-F3 to proceed with GNU/kFreeBSD setup...,g" \
  -e "s,Visit the general configuration menu for a chance to set,Debian GNU/kFreeBSD installation complete.  Answer \"No\" ,g" \
  -e "s,any last options?,below and reboot.,g" \
  -e "s,Begin a standard installation (recommended),-------disabled-option-do-not-pick---------,g" \
> ${mnt}/stand/sysinstall
chmod 755 ${mnt}/stand/sysinstall

# freebsd commands.  most of these will have to be replaced by native debian
# commands, someday...
for i in \
  -sh [ arp boot_crunch camcontrol cpio dhclient find fsck_ffs gunzip gzip \
  hostname ifconfig minigzip mount_nfs newfs ppp pwd rm route rtsol sed sh \
  slattach test tunefs usbd usbdevs zcat
do
  ln ${mnt}/stand/sysinstall ${mnt}/stand/$i
done

for i in {stand/,}etc/group ; do
  echo "operator:*:5:root" > ${mnt}/$i
done

umount ${mnt}
mdconfig -d -u ${md}
rmdir ${mnt}

gzip -9 mfsroot
