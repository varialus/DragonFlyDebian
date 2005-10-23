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

. vars
cd tmp

##################
#  add some trickery
###########################

# misc cleanup
chroot . apt-get clean
rm -rf var/cache/apt/lists
dirs="tmp var/lock var/tmp"
rm -rf ${dirs}
mkdir -p ${dirs}
chmod 1777 ${dirs}

# if X server auto-configurator is installed, enable it
if test -e etc/init.d/xserver-xorg ; then
  rm -f etc/X11/xorg.conf*
  touch etc/X11/xorg.conf
  cat > etc/default/xorg << __EOF__
GENERATE_XCFG_AT_BOOT=true
__EOF__
fi

# if kdm is installed, tell it to auto-login as ging
if test -e etc/kde3/kdm/kdmrc ; then
  sed -i etc/kde3/kdm/kdmrc \
  -e "s/^#AutoLoginEnable=.*/AutoLoginEnable=true/g" \
  -e "s/^#AutoLoginUser=.*/AutoLoginUser=${username}/g"
fi

# shut up silly warning
if test -e boot/kernel/linker.hints ; then
  touch boot/kernel/linker.hints
fi

# some splash customisation
if ! grep -q "^loader_color=\"YES\"" boot/loader.conf ; then
  echo "loader_color=\"YES\"" >> boot/loader.conf
fi
sed -i boot/beastie.4th -e "s/Debian/Ging/g"

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

# crosshurd gathers some defaults from host machine, we don't really want that
echo -n > etc/resolv.conf
echo "127.0.0.1		localhost $hostname" > etc/hosts
echo $hostname > etc/hostname

# filesystem tables
cat > etc/fstab << EOF
/dev/acd0	/	cd9660		ro	0 0
EOF
ln -sf /proc/mounts etc/mtab

# activate startup script
sed -i boot/loader.conf -e "s,^#init_path=.*,init_path=\"/root/startup\",g"

mkdir -p ramdisk
sed -e "s/@version@/${version}/g" \
  < ${pwd}/startup > root/startup
chmod +x root/startup

#########################
#                    ignition!
#################################
# -r messes up file permissions, use -R instead
mkisofs -b boot/cdboot -no-emul-boot \
  -o ${pwd}/${distribution}-${version}.iso -R .

cd ${pwd}/
