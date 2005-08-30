#!/bin/bash
#
# Build-Depends: mkisofs, crosshurd, fakeroot
#
# Copyright 2004, 2005  Robert Millan <rmh@aybabtu.com>
# See /usr/share/common-licenses/GPL for license terms.

set -ex

if [ "$UID" != "0" ] ; then
  # I call that incest, don't you?
  sudo $0 $@
  exit 0
fi

if ! dpkg -s crosshurd > /dev/null ; then
  echo Install crosshurd and try again
  exit 1
fi

tmp=`mktemp -d`
pwd=`pwd`
export GZIP=--best

if test -e base.tgz ; then
  tar --same-owner -xzpf base.tgz -C ${tmp}
else
  /usr/share/crosshurd/makehurddir.sh ${tmp} i486 kfreebsd-gnu
fi

if test -e native-install ; then
  cp native-install ${tmp}/
fi

# this command is called by f-i after untarring, let's exploit that
cat > ${tmp}/bin/mtree << __EOF__
#!/bin/bash
set -ex
# be idempotent
if ! test -e /native-install ; then
  exit 0
fi

# f-i's /etc/fstab is more accurate than native-install's
mv /etc/fstab /etc/fstab.freebsd

# ttyv0 is sysinstall, ttyv1 is tar/cpio, ttyv3 is a chrooted shell
# ttyv2 will be for native-install
if ! /native-install </dev/ttyv2 >/dev/ttyv2 2>/tmp/native-install.log ; then
  echo native-install exitted with non-zero status, spawning debug shell > /dev/ttyv2
  bash </dev/ttyv2 >/dev/ttyv2 2>/dev/ttyv2
fi

# restore files messed up by f-i
for i in /etc/protocols /etc/services ; do
  mv \${i}.dpkg-dist \${i}
done

# restore f-i's /etc/fstab, and add linprocfs
mv /etc/fstab.freebsd /etc/fstab
echo "null	/proc	linprocfs	rw	0 0" >> /etc/fstab

rm -f /native-install
__EOF__
chmod +x ${tmp}/bin/mtree

# maybe-missing kernel package
cd ${tmp} && dpkg --extract var/cache/apt/archives/kfreebsd-image-5.*.deb .

# crosshurd gathers some defaults from host machine, we don't really want that
echo -n > ${tmp}/etc/resolv.conf
echo "127.0.0.1		localhost" > ${tmp}/etc/hosts
echo debian > ${tmp}/etc/hostname

mv ${pwd}/base.tgz{,.old}
(cd ${tmp} && tar --same-owner -czpf ${pwd}/base.tgz ./*)
rm -rf ${tmp} ${pwd}/base.tgz.old
