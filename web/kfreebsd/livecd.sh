#!/bin/bash -ex
#
# Build-Depends: wget, gnupg, mkisofs, crosshurd

[ "$UID" == "0" ]

version=5

rm -rf *~ out
mkdir -p stand/boot/grub out

# GRUB stuff
cp /lib/grub/i386-pc/stage2_eltorito stand/boot/grub/
cat > stand/boot/grub/menu.lst << EOF
timeout 30
default 0
title  GNU/kFreeBSD (cdrom 0)
root (cd)
kernel /boot/kfreebsd.gz root=cd9660:acd0
title  GNU/kFreeBSD (cdrom 1)
root (cd)
kernel /boot/kfreebsd.gz root=cd9660:acd1
EOF

# add this to make it safe
cp /boot/device.hints stand/boot/
cat >> stand/boot/device.hints << EOF
hint.acpi.0.disabled=1
loader.acpi_disabled_by_user=1
hint.apic.0.disabled=1
hw.ata.ata_dma=0
hw.ata.atapi_dma=0
hw.ata.wc=0
hw.eisa_slots=0
EOF

# prepare the base system
cat > stand/etc/issue << EOF
Debian GNU/kFreeBSD testing/unstable \n \l

You may login as root, with no password.

EOF
cat > stand/etc/fstab << EOF
/dev/acd0 / cd9660 ro 1 1
EOF
# keep inetutils-syslogd from bitching
cp stand/{bin/true,usr/sbin/syslogd}

# ignition!
mkisofs -b boot/grub/stage2_eltorito \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -o out/livecd${version}.iso -r stand
