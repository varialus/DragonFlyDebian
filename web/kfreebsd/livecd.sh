#!/bin/bash
#
# Build-Depends: mkisofs, crosshurd, fakeroot
#
# Copyright 2004  Robert Millan <rmh@debian.org>
# See /usr/share/common-licenses/GPL for license terms.

set -ex
version=9

if [ "$UID" != "0" ] ; then
  # I call that incest, don't you?
  fakeroot $0 $@
  exit 0
fi

cpu=`dpkg-architecture -qDEB_BUILD_GNU_CPU`
system="kfreebsd-gnu"
uname="GNU/kFreeBSD"
tmp1=`tempfile` && rm -f ${tmp1} && mkdir -p ${tmp1}
tmp2=`tempfile`
pwd=`pwd`

/usr/share/crosshurd/makehurddir.sh ${tmp1} ${cpu} ${system}

##################
#  add some trickery
###########################

cd ${tmp1}
tar --same-owner -cpf - ./* | gzip -c9 > ${tmp2}
mv ${tmp2} ${tmp1}/root/${cpu}-${system}.tar.gz

if [ "${LIVECD_DEBUG}" != "yes" ] ; then
  rm -f ${tmp1}/var/cache/apt/archives/*.deb
fi

# GRUB stuff
mkdir -p boot/grub
cp lib/grub/${cpu}-*/stage2_eltorito boot/grub/
cat > boot/grub/menu.lst << EOF
timeout 30
default 0
title  ${uname} (cdrom 0)
root (cd)
kernel /boot/kfreebsd.gz root=cd9660:acd0
title  ${uname} (cdrom 1)
root (cd)
kernel /boot/kfreebsd.gz root=cd9660:acd1
EOF

# add this to make it a safe boot
cat >> boot/device.hints << EOF
hint.acpi.0.disabled=1
loader.acpi_disabled_by_user=1
hint.apic.0.disabled=1
hw.ata.ata_dma=0
hw.ata.atapi_dma=0
hw.ata.wc=0
hw.eisa_slots=0
EOF
cat > etc/fstab << EOF
/dev/acd0 / cd9660 ro 1 1
EOF
# keep inetutils-syslogd from bitching
cp bin/true usr/sbin/syslogd

# password-less login
cat > etc/passwd << EOF
root::0:0:root:/root:/bin/bash
EOF
cat > etc/inittab << EOF
id:S:initdefault:
~~:S:wait:/sbin/sulogin -e
ca:12345:ctrlaltdel:/sbin/shutdown -t1 -a -r now
EOF

#########################
#                    ignition!
#################################
mkisofs -b boot/grub/stage2_eltorito \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -o ${pwd}/livecd${version}.iso -r .

cd ${pwd}/
if [ "${LIVECD_DEBUG}" = "yes" ] ; then
  echo tmp1 = ${tmp1}
  echo tmp2 = ${tmp2}
else
  rm -rf ${tmp1} ${tmp2}
fi
