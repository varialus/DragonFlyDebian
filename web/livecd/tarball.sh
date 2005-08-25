#!/bin/bash
#
# Build-Depends: mkisofs, crosshurd, fakeroot
#
# Copyright 2004  Robert Millan <rmh@debian.org>
# See /usr/share/common-licenses/GPL for license terms.

set -ex

if [ "$UID" != "0" ] ; then
  # I call that incest, don't you?
  fakeroot $0 $@
  exit 0
fi

if ! dpkg -s crosshurd > /dev/null ; then
  echo Install crosshurd and try again
  exit 1
fi

cpu="i486"
system="kfreebsd-gnu"
uname="GNU/kFreeBSD"
tmp1=`tempfile` && rm -f ${tmp1} && mkdir -p ${tmp1}
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

# crosshurd uses host machine /etc/resolv.conf.  we don't really want that
echo -n > ${tmp1}/etc/resolv.conf

cd ${tmp1} && tar --same-owner -czpf ${pwd}/base.tgz ./*
rm -rf ${tmp1}
