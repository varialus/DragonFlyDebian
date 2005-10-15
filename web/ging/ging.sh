#!/bin/bash
#
# Build-Depends: mkisofs, crosshurd, fakeroot
#
# Copyright 2004, 2005  Robert Millan <rmh@aybabtu.com>
# See /usr/share/common-licenses/GPL for license terms.

set -ex

if [ "$UID" != "0" ] ; then
  sudo $0 $@
  exit 0
fi

for i in mkisofs crosshurd ; do
  if ! dpkg -s ${i} | grep -q "^Status: .* installed$" > /dev/null ; then
    echo Install ${i} and try again
    exit 1
  fi
done

if ! test -e cdboot ; then
  echo Get cdboot from the same place you got this script, then try again
  exit 1
fi

. vars

##################
#  add some trickery
###########################

cd tmp

chroot . apt-get clean
rm -rf var/cache/apt/lists

# if X server auto-configurator is installed, enable it
if test -e etc/init.d/xserver-xorg ; then
  rm -f etc/X11/xorg.conf*
  touch etc/X11/xorg.conf
  cat > ${tmp1}/etc/default/xorg << __EOF__
GENERATE_XCFG_AT_BOOT=true
__EOF__
fi

# shut up silly warning
if test -e boot/kernel/linker.hints ; then
  touch boot/kernel/linker.hints
fi

# enable DMA on atapi
if ! grep -q "^hw\.ata\.atapi_dma=1" boot/loader.conf ; then
  echo "hw.ata.atapi_dma=1" >> boot/loader.conf
fi

# avoid non-sense wizards for kde and gimp
tar --same-owner -xzpf ${pwd}/home_ging.tar.gz

# probe for sound cards
cat > etc/modules.d/ging << EOF
# added for ging $version
snd_driver
EOF

# filesystem tables
cat > etc/fstab << EOF
/dev/acd0	/	cd9660		ro	0 0
EOF
ln -sf /proc/mounts etc/mtab

# setup pseudo-initrd system.
# - init runs /root/startup
# - /root/startup creates an ufs ramdisk
# - then mounts readonly directories as nullfs
# - then copies writable directories into the ramdisk
cat > etc/inittab << EOF
id:S:initdefault:
~~:S:wait:/root/startup
ca:12345:ctrlaltdel:/sbin/shutdown -t1 -a -r now
EOF

mkdir -p ramdisk
cp ${pwd}/startup root/
chmod +x root/startup

#########################
#                    ignition!
#################################
cp ${pwd}/cdboot boot/
# -r messes up file permissions, use -R instead
mkisofs -b boot/cdboot -no-emul-boot \
  -o ${pwd}/${distribution}-${version}.iso -R .

cd ${pwd}/
