#!/bin/bash -ex
#
# Build-Depends: grub, kfreebsd5, mkisofs and maybe something else..

[ "$UID" == "0" ]

rm -rf *~ tmp out
mkdir -p tmp/root/boot/grub out

# GRUB stuff
cp /usr/lib/grub/i386-pc/{stage1,stage2} tmp/root/boot/grub/
cp /usr/lib/grub/i386-pc/e2fs_stage1_5 tmp/root/boot/grub/
	#cp /usr/lib/grub/i386-pc/iso9660_stage1_5 tmp/root/boot/grub/
cat > tmp/root/boot/grub/menu.lst << EOF
timeout 30
default 0
title  GNU/kFreeBSD (cdrom 0)
root (fd0)
kernel /boot/kfreebsd.gz root=cd9660:acd0
title  GNU/kFreeBSD (cdrom 1)
root (fd0)
kernel /boot/kfreebsd.gz root=cd9660:acd1
EOF

# kernel of FreeBSD stuff
cp /boot/kfreebsd.gz tmp/root/boot/
cp /boot/device.hints tmp/root/boot/
# add this to make it safe
cat >> tmp/root/boot/device.hints << EOF
hint.acpi.0.disabled=1
loader.acpi_disabled_by_user=1
hint.apic.0.disabled=1
hw.ata.ata_dma=0
hw.ata.atapi_dma=0
hw.ata.wc=0
hw.eisa_slots=0
EOF
tar -C tmp/root -cf tmp/tmp.tar boot
mkbimage -t 2.88 -d tmp -s ext2 -f tmp/tmp.tar

# prepare the base system
cp tmp/2.88.image stand/2.88.image
cat > stand/etc/issue << EOF
Debian GNU/kFreeBSD testing/unstable \n \l

You may login as root, with no password.

EOF
# keep inetutils-syslogd from bitching
cp stand/{bin/true,usr/sbin/syslogd}

# ignition!
mkisofs -b 2.88.image -c boot.catalog -o out/livecd.iso -r stand
