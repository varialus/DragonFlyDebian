#!/bin/bash
#
# Copyright 2004, 2005  Robert Millan <rmh@aybabtu.com>
# See /usr/share/common-licenses/GPL for license terms.

set -ex

if [ "$UID" != "0" ] ; then
  sudo $0 $@
  exit 0
fi

if ! test -e mfsroot${dot_gz} ; then ./mfsroot.sh ; fi
if ! test -d tmp ; then ./tarball.sh ; fi

for i in mkisofs ; do
  if ! dpkg -s ${i} | grep -q "^Status: .* installed$" > /dev/null ; then
    echo Install ${i} and try again
    exit 1
  fi
done

. vars
tmp=`mktemp -d`

##################
#  add some trickery
###########################

# get kernel and loader from cloop image (FIXME: exclude this from cloop!)
cp -a ${pwd}/tmp/boot ${tmp}/
if [ "${OPTS}" != "qemu" ] ; then
  ${gzip} ${tmp}/boot/kernel/kernel
fi

# shut up silly warning
if test -e ${tmp}/boot/kernel/linker.hints ; then
  touch ${tmp}/boot/kernel/linker.hints
fi

sed -i ${tmp}/boot/beastie.4th -e "s/Debian/Ging/g"

cat > ${tmp}/boot/loader.conf << EOF
loader_color="YES"
hw.ata.atapi_dma=1
mfsroot_load="YES"
mfsroot_type="mfs_root"
mfsroot_name="/boot/mfsroot"
geom_uzip_load="YES"
linprocfs_load="YES"
nullfs_load="YES"
EOF
cp ${pwd}/mfsroot${dot_gz} ${tmp}/boot/

# copy ging.cloop in
${pwd}/cloop.sh ${tmp}/ging.cloop

#########################
#                    ignition!
#################################
# -r messes up file permissions, use -R instead
(cd ${tmp} && mkisofs -b boot/cdboot -no-emul-boot \
  -o ${pwd}/${distribution}-${version}.iso -R .)

cd ${pwd}/
rm -rf ${tmp} &
