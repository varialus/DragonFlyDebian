#!/bin/bash
#
# Build-Depends: mkisofs, crosshurd, fakeroot
#
# Copyright 2004, 2005  Robert Millan <rmh@aybabtu.com>
# See /usr/share/common-licenses/GPL for license terms.

set -ex

version=0.1.0.rc1

if [ "$UID" != "0" ] ; then
  # I call that incest, don't you?
  sudo $0 $@
  exit 0
fi

if ! dpkg -s crosshurd > /dev/null ; then
  echo Install crosshurd and try again
  exit 1
fi

username="ging"
hostname="ging"

cpu="i486"
system="kfreebsd-gnu"
uname="GNU/kFreeBSD"
tmp1=`mktemp -d`
pwd=`pwd`
export GZIP=--best

# BEGIN package stuff
######################################################################
/usr/share/crosshurd/makehurddir.sh ${tmp1} ${cpu} ${system}
(set -e ; cd ${tmp1}/var/cache/apt/archives/ && wget -c \
  http://ftp.gnuab.org/debian/obsolete/2005-10-06/openssl/libssl0.9.7_0.9.7g-2+kbsd_kfreebsd-i386.deb)

cat > ${tmp1}/etc/apt/apt.conf << __EOF__
APT::Get::AllowUnauthenticated "yes";
__EOF__
mount -t devfs null ${tmp1}/dev
chroot ${tmp1} /native-install

if test -e ./packages ; then packages=`grep -v "^#" ./packages | tr "\n" " "` ; fi
chroot ${tmp1} apt-get update
chroot ${tmp1} apt-get -y install ${packages} kfreebsd-image-5-686 || true
######################################################################
# END package stuff

# password-less login
cat > ${tmp1}/etc/passwd << EOF  
root::0:0:root:/root:/bin/bash
EOF
cat > ${tmp1}/etc/inittab << EOF
id:S:initdefault:
~~:S:wait:/sbin/sulogin -e
ca:12345:ctrlaltdel:/sbin/shutdown -t1 -a -r now
EOF

echo > ${tmp1}/etc/motd

cat > ${tmp1}/etc/issue << __EOF__
Ging $version \n \l

__EOF__

chroot ${tmp1} adduser --disabled-password ${username}
sed -i ${tmp1}/etc/shadow -e "s/^${username}:\*:/${username}::/g"

cat > ${tmp1}/etc/sudoers << __EOF__
${username} ALL=NOPASSWD: ALL
__EOF__

chroot ${tmp1} apt-get clean

set +x
echo "Spawning a shell.  The following packages are supposedly installed:"
echo ${packages}
echo "System size: `du -hs ${tmp1}`"
chroot ${tmp1}
set -x

chroot ${tmp1} apt-get clean
rm -f ${tmp1}/native-install

# if X server auto-configurator is installed, enable it
if test -e ${tmp1}/etc/init.d/xserver-xorg ; then
  cat > ${tmp1}/etc/default/xorg << __EOF__
GENERATE_XCFG_AT_BOOT=true
__EOF__
fi

# enable DMA on atapi
if ! grep -q "^hw\.ata\.atapi_dma=1" ${tmp1}/boot/loader.conf ; then
  echo "hw.ata.atapi_dma=1" >> ${tmp1}/boot/loader.conf
fi

# crosshurd gathers some defaults from host machine, we don't really want that
echo -n > ${tmp1}/etc/resolv.conf
echo "127.0.0.1		localhost $hostname" > ${tmp1}/etc/hosts
echo $hostname > ${tmp1}/etc/hostname

# everything must be unmounted before tarring
umount -f ${tmp1}/dev
umount -f ${tmp1}/proc

cd ${tmp1} && tar --same-owner -czpf ${pwd}/base.tgz ./*
rm -rf ${tmp1}
