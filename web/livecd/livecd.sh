#!/bin/bash
#
# Build-Depends: mkisofs, crosshurd, fakeroot
#
# Copyright 2004, 2005 Robert Millan <rmh@debian.org>
# See /usr/share/common-licenses/GPL for license terms.

set -ex

version=unreleased

if [ "$UID" != "0" ] ; then
  # I call that incest, don't you?
  fakeroot $0 $@
  exit 0
fi

for i in mkisofs crosshurd ; do
  if ! dpkg -s ${i} > /dev/null ; then
    echo Install ${i} and try again
    exit 1
  fi
done

if ! test -e cdboot ; then
  echo Get cdboot from the same place you got this script, then try again
  exit 1
fi

cpu="i386"
system="kfreebsd-gnu"
uname="GNU/kFreeBSD"
tmp1=`tempfile` && rm -f ${tmp1} && mkdir -p ${tmp1}
tmp2=`tempfile`
pwd=`pwd`

if ! test -e base.tgz ; then ./tarball.sh ; fi
tar -C ${tmp1} --same-owner -xzpf base.tgz
mkdir ${tmp1}/base
cp base.tgz ${tmp1}/base/

##################
#  add some trickery
###########################

cd ${tmp1}

rm -f var/cache/apt/archives/*.deb
rm -rf var/cache/apt/lists

# grub is disabled for now
#mkdir -p boot/grub
#cp lib/grub/${cpu}-*/stage2_eltorito boot/grub/
#cat > boot/grub/menu.lst << EOF
#timeout 30
#default 0
#title  ${uname} (cdrom 0)
#root (cd)
#kernel /boot/kfreebsd.gz root=cd9660:acd0
#title  ${uname} (cdrom 1)
#root (cd)
#kernel /boot/kfreebsd.gz root=cd9660:acd1
#EOF

# this is only used by grub
#gzip -c9 boot/kernel/kernel > boot/kfreebsd.gz

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

# filesystem tables
cat > etc/fstab << EOF
/dev/acd0	/	cd9660		ro	1 1
EOF
ln -s /proc/mounts etc/mtab

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
cat > root/startup << EOF
#!/bin/bash
set -e
mdconfig -a -t malloc -o compress -s 16m -u md0
mkfs.ufs /dev/md0
mount -o rw -t ufs /dev/md0 /ramdisk
for i in /* ; do
  case \${i} in
    /bin|/usr|/boot|/lib|/sbin|/base)
      mkdir -p /ramdisk/\${i}
      mount -t nullfs /\${i} /ramdisk/\${i}
    ;;
    /dev)
      mkdir -p /ramdisk/dev
      mount -t devfs null /ramdisk/dev
    ;;
    /proc)
      mkdir -p /ramdisk/proc
      mount -t linprocfs null /ramdisk/proc
    ;;
    /ramdisk|/*-RELEASE|/root)
    ;;
    /*)
      cp -a /\${i} /ramdisk/\${i}
    ;;
  esac
done
# doesn't work as expected (i.e. you still need -f to halt)
#mknod -m 600 /ramdisk/etc/.initctl p
export TERM=cons25
# sysvinit inside the chroot doesn't work
#cp /usr/share/sysvinit/inittab /ramdisk/etc/
while ! test -e /ramdisk/tmp/get_me_the_hell_outta_here ; do
  chroot /ramdisk
  echo warning: shell died, respawning
done
echo
echo congrats, you escaped the chroot
while true ; do bash ; done
EOF
chmod +x root/startup

# hacks for being a FreeBSD compliant [tm] cdrom
for i in 5 6 ; do for j in 0 1 2 3 4 5 6 7 8 9 ; do
  ln -sf . $i.$j-RELEASE
done ; done
ln -s ../base/base.tgz root/


#########################
#                    ignition!
#################################
cp ${pwd}/cdboot boot/
mkisofs -b boot/cdboot -no-emul-boot \
  -o ${pwd}/livecd-${version}.iso -r .

rm -rf ${tmp1} ${tmp2} &
cd ${pwd}/
