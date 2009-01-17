#!/bin/bash
#
# Build-Depends: mkisofs, crosshurd, sudo
#
# Copyright 2004, 2005 Robert Millan <rmh@aybabtu.com>
# See /usr/share/common-licenses/GPL for license terms.

set -ex

. config

if [ "$UID" != "0" ] ; then
  sudo $0 $@
  exit 0
fi

for i in mkisofs ; do
  if ! which mkisofs > /dev/null ; then
    echo Install ${i} and try again
    exit 1
  fi
done

pwd=`pwd`
tmp=`mktemp -d`

if ! test -e base.tgz ; then ./tarball.sh ; fi
if ! test -e mfsroot.gz ; then ./mfsroot.sh ; fi

# get kernel and loader (this must be before loader.conf, so that it gets overwritten)
tmp1=`mktemp -d`
tar -C ${tmp1} -xzf base.tgz
case ${distribution_lowcase} in
  debian)
    dpkg --extract ${tmp1}/var/cache/apt/archives/kfreebsd-loader_*_${DEB_HOST_ARCH}.deb ${tmp}/
    kfreebsd_image=`echo ${tmp1}/var/cache/apt/archives/kfreebsd-image-7.*-*_${DEB_HOST_ARCH}.deb`
    dpkg --extract ${kfreebsd_image} ${tmp}/
    kfreebsd_version=`echo ${kfreebsd_image} | sed -e "s,.*/kfreebsd-image-,,g" -e "s,_.*,,g"`
  ;;
  *)
    # assume it's already in the tarball
    cp -a ${tmp1}/boot ${tmp}/
    echo -n "kfreebsd_version: "
    read kfreebsd_version
  ;;
esac
rm -rf ${tmp1} &
mv ${tmp}/boot/kfreebsd-${kfreebsd_version}.gz ${tmp}/boot/kernel/kernel.gz
mv ${tmp}/lib/modules/${kfreebsd_version}/* ${tmp}/boot/kernel/

# put mfsroot and other extras
echo "CD_VERSION = ${kfreebsd_version}" > ${tmp}/cdrom.inf
cat > ${tmp}/boot/loader.conf << EOF
mfsroot_load="YES"
mfsroot_type="mfs_root"
mfsroot_name="/boot/mfsroot"
loader_color="YES"
EOF
case ${distribution_lowcase} in
  gentoo) zcat mfsroot.gz | sed -e "s/Debian/Gentoo/g" | gzip -c9 > ${tmp}/boot/mfsroot.gz ;;
  *) cp mfsroot.gz ${tmp}/boot/ ;;
esac

# copy our base into it
mkdir ${tmp}/base/
cp base.tgz ${tmp}/base/

# hack for being a FreeBSD compliant [tm] cdrom
ln -sf . ${tmp}/${kfreebsd_version}

#########################
#                    ignition!
#################################
# -V argument *must* be 32 char long at most, we have 18 chars for $version + $cpu
(cd ${tmp} && mkisofs -b boot/cdboot -no-emul-boot \
  -r -J -V "${distribution} ${version} ${DEB_HOST_ARCH_CPU} Bin-1" \
  -o ${pwd}/${cdname} .)

rm -rf ${tmp} &
