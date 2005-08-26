#!/bin/bash
#
# Build-Depends: mkisofs, crosshurd, fakeroot
#
# Copyright 2004, 2005 Robert Millan <rmh@aybabtu.com>
# See /usr/share/common-licenses/GPL for license terms.

set -ex

if [ "$version" = "" ] ; then
  version=unreleased
fi

if [ "$UID" != "0" ] ; then
  # I call that incest, don't you?
  fakeroot $0 $@
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

cpu="i486"
system="kfreebsd-gnu"
uname="GNU/kFreeBSD"
tmp1=`mktemp -d`
tmp2=`mktemp`
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
cat > root/startup << __EOF__
#!/bin/bash
set -e
trap "echo \"Something wicked happened.  Press enter for rescue shell.\" ; read i ; bash" 0
mdconfig -a -t malloc -o compress -s 32m -u md0
mkfs.ufs /dev/md0
mount -o rw -t ufs /dev/md0 /ramdisk
echo "Populating ramdisk node \(this might take a while\) ..."
for i in /* ; do
  case \${i} in
    /bin|/usr|/boot|/lib|/libexec|/sbin|/base)
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
    /var)
      mkdir -p /ramdisk/var
      for i in \${i}/* ; do
        case \${i} in
          /var/lib|/var/cache)
            mkdir -p /ramdisk/\${i}
            mount -t nullfs /\${i} /ramdisk/\${i}
          ;;
          *)
            cp -a /\${i} /ramdisk/\${i}
          ;;
        esac
      done
    ;;
    /ramdisk|/*-RELEASE)
    ;;
    /*)
      cp -a /\${i} /ramdisk/\${i}
    ;;
  esac
done
# doesn't work as expected (i.e. you still need -f to halt)
#mknod -m 600 /ramdisk/etc/.initctl p
export TERM=cons25

# attempt to setup network via DHCP
if which dhclient3 >/dev/null 2>/dev/null ; then
  chroot /ramdisk dhclient3 >/dev/null 2>/dev/null &
fi

# make /etc/init.d/checkroot happy
# (we don't use <<EOF because bash requires a tempfile to do that)
echo "/dev/md0	/	ufs		rw	1 1" > /ramdisk/etc/fstab

while chroot /ramdisk ; do true ; done
echo "chrooted shell exitted with non-zero status.  NOT respawning."
while bash ; do true ; done
echo "Ok, you get what you wanted ..."
halt -f
__EOF__
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
# -r messes up file permissions, use -R instead
mkisofs -b boot/cdboot -no-emul-boot \
  -o ${pwd}/livecd-${version}.iso -R .

rm -rf ${tmp1} ${tmp2} &
cd ${pwd}/
