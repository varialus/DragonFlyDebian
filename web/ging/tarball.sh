#!/bin/bash
#
# Build-Depends: mkisofs, crosshurd, fakeroot
#
# Copyright 2004, 2005  Robert Millan <rmh@aybabtu.com>
# See /usr/share/common-licenses/GPL for license terms.

set -ex

version=0.1.0

if [ "$UID" != "0" ] ; then
  # I call that incest, don't you?
  sudo $0 $@
  exit 0
fi

if ! dpkg -s crosshurd > /dev/null ; then
  echo Install crosshurd and try again
  exit 1
fi

cpu="i486"
system="kfreebsd-gnu"
uname="GNU/kFreeBSD"
tmp1=`mktemp -d`
pwd=`pwd`
export GZIP=--best

/usr/share/crosshurd/makehurddir.sh ${tmp1} ${cpu} ${system}

# password-less login
cat > ${tmp1}/etc/passwd << EOF  
root::0:0:root:/root:/bin/bash
EOF
cat > ${tmp1}/etc/inittab << EOF
id:S:initdefault:
~~:S:wait:/sbin/sulogin -e
ca:12345:ctrlaltdel:/sbin/shutdown -t1 -a -r now
EOF

# maybe-missing kernel package
cd ${tmp1} && dpkg --extract var/cache/apt/archives/kfreebsd-image-5.*.deb .

echo ging > ${tmp1}/etc/hostname
cat > ${tmp1}/etc/hosts << __EOF__
127.0.0.1	localhost ging
__EOF__

echo > ${tmp1}/etc/motd

cat > ${tmp1}/etc/issue << __EOF__
Ging $version \n \l

__EOF__

cat > ${tmp1}/etc/apt/apt.conf << __EOF__
APT::Get::AllowUnauthenticated "yes";
__EOF__
chroot ${tmp1} /native-install

if test -e ./packages ; then packages=`grep -v "^#" ./packages | tr "\n" " "` ; fi
chroot ${tmp1} apt-get update
chroot ${tmp1} apt-get -y install ${packages} || true

username="ging"
chroot ${tmp1} adduser --disabled-password $username
sed -i ${tmp1}/etc/shadow -e "s/^ging:\*:/ging::/g"
echo "case \`tty\` in /dev/ttyv*) xinit /usr/bin/gnome-session ;; esac" >> ${tmp1}/home/$username/.bashrc

cat > ${tmp1}/etc/sudoers << __EOF__
$username ALL=NOPASSWD: ALL
__EOF__

# avoid messed-up file with "ed0"
cat > ${tmp1}/etc/network/interfaces << __EOF__
auto lo0
iface lo0 inet loopback
__EOF__

echo "Spawning a shell.  The following packages are supposedly installed:"
echo ${packages}
chroot ${tmp1}

rm -f ${tmp1}/var/cache/apt/archives/*.deb ${tmp1}/native-install

# if X server wrapper is installed, allow console users to run it
if test -e ${tmp1}/etc/X11/Xwrapper.config ; then
  sed -i ${tmp1}/etc/X11/Xwrapper.config -e "s/^allowed_users=.*/allowed_users=console/g"
fi

# if X server auto-configurator is installed, enable it
if test -e ${tmp1}/etc/init.d/xserver-xorg ; then
  cat > ${tmp1}/etc/default/xorg << __EOF__
GENERATE_XCFG_AT_BOOT=true
__EOF__
fi

# crosshurd uses host machine /etc/resolv.conf.  we don't really want that
echo -e "127.0.0.1\t\tlocalhost" > ${tmp1}/etc/resolv.conf

cd ${tmp1} && tar --same-owner -czpf ${pwd}/base.tgz ./*
rm -rf ${tmp1}
