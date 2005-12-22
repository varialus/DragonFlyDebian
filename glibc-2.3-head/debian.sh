#!/bin/sh
set -ex

pwd=`pwd`

if [ "$1" = "" ] ; then
  echo "Usage: $0 ..../glibc-2.3-head/  (to be run from debian source tree)"
  exit 1
fi

# sysdeps dir
tmp=`mktemp -d`
mkdir -p ${tmp}/sysdeps/unix/bsd/bsd4.4 ${tmp}/linuxthreads/sysdeps/unix/bsd/bsd4.4
cp -a $1/sysdeps/kfreebsd ${tmp}/sysdeps/unix/bsd/bsd4.4/
cp -a $1/linuxthreads/kfreebsd ${tmp}/linuxthreads/sysdeps/unix/bsd/bsd4.4/
find ${tmp} -name "\.svn" | (while read i ; do rm -rf $i ; done)
(cd ${tmp} && tar -cjf ${pwd}/glibc-kfreebsd.tar.bz2 sysdeps linuxthreads)
rm -rf ${tmp}

# our patches (must be in dpatch format)
cp $1/patches/* debian/patches/
ls $1/patches | sed -e "s,\.dpatch$,,g" >> debian/patches/00list

# kfreebsd has to be renamed, yet again
if test -e debian/sysdeps/kfreebsd-gnu.mk ; then
  mv debian/sysdeps/kfreebsd-gnu.mk debian/sysdeps/kfreebsd.mk
fi

patch -p1 < $0

# re-generate debian/control
debian/rules debian/control

exit 0

diff -ur glibc-2.3.5.old/debian/control.in/main glibc-2.3.5/debian/control.in/main
--- glibc-2.3.5.old/debian/control.in/main	2005-12-21 21:26:37.000000000 +0100
+++ glibc-2.3.5/debian/control.in/main	2005-12-21 22:52:45.000000000 +0100
@@ -1,7 +1,7 @@
 Source: @glibc@
 Section: libs
 Priority: required
-Build-Depends: gettext (>= 0.10.37-1), make (>= 3.80-1), dpkg-dev (>= 1.13.5), debianutils (>= 1.13.1), tar (>= 1.13.11), bzip2, texinfo (>= 4.0), linux-kernel-headers (>= 2.6.13+0rc3-2) [!hurd-i386], mig (>= 1.3-2) [hurd-i386], hurd-dev (>= 20020608-1) [hurd-i386], gnumach-dev [hurd-i386], texi2html, file, gcc-4.0 [!powerpc !m68k !hppa !hurd-i386], gcc-3.4 (>= 3.4.4-6) [powerpc], gcc-3.4 [m68k hppa], gcc-3.3 [hurd-i386], autoconf, binutils (>= 2.14.90.0.7-5), sed (>= 4.0.5-4), gawk, debhelper (>= 4.1.76), libc6-dev-amd64 [i386], libc6-dev-ppc64 [powerpc]
+Build-Depends: gettext (>= 0.10.37-1), make (>= 3.80-1), dpkg-dev (>= 1.13.5), debianutils (>= 1.13.1), tar (>= 1.13.11), bzip2, texinfo (>= 4.0), linux-kernel-headers (>= 2.6.13+0rc3-2) [!hurd-i386 !kfreebsd-i386], kfreebsd-kernel-headers [kfreebsd-i386], mig (>= 1.3-2) [hurd-i386], hurd-dev (>= 20020608-1) [hurd-i386], gnumach-dev [hurd-i386], texi2html, file, gcc-4.0 [!powerpc !m68k !hppa !hurd-i386], gcc-3.4 (>= 3.4.4-6) [powerpc], gcc-3.4 [m68k hppa], gcc-3.3 [hurd-i386], autoconf, binutils (>= 2.14.90.0.7-5), sed (>= 4.0.5-4), gawk, debhelper (>= 4.1.76), libc6-dev-amd64 [i386], libc6-dev-ppc64 [powerpc]
 Build-Depends-Indep: perl, po-debconf
 Maintainer: GNU Libc Maintainers <debian-glibc@lists.debian.org>
 Uploaders: Ben Collins <bcollins@debian.org>, GOTO Masanori <gotom@debian.org>, Philip Blundell <pb@nexus.co.uk>, Jeff Bailey <jbailey@raspberryginger.com>, Daniel Jacobowitz <dan@debian.org>, Clint Adams <schizo@debian.org>
diff -ur glibc-2.3.5.old/debian/rules.d/control.mk glibc-2.3.5/debian/rules.d/control.mk
--- glibc-2.3.5.old/debian/rules.d/control.mk	2005-12-21 21:26:39.000000000 +0100
+++ glibc-2.3.5/debian/rules.d/control.mk	2005-12-21 22:55:45.000000000 +0100
@@ -1,6 +1,6 @@
-control_deps := $(addprefix debian/control.in/, libc6 libc6.1 libc0.3 libc1 sparc64 s390x ppc64 opt amd64)
+control_deps := $(addprefix debian/control.in/, libc6 libc6.1 libc0.3 libc0.1 sparc64 s390x ppc64 opt amd64)
 
-threads_archs := alpha amd64 arm armeb i386 m68k mips mipsel powerpc sparc ia64 hppa s390 sh3 sh4 sh3eb sh4eb freebsd-i386
+threads_archs := alpha amd64 arm armeb i386 m68k mips mipsel powerpc sparc ia64 hppa s390 sh3 sh4 sh3eb sh4eb kfreebsd-i386
 
 debian/control.in/libc6: debian/control.in/libc debian/rules.d/control.mk
 	sed -e 's%@libc@%libc6%g' \
@@ -12,8 +12,8 @@
 debian/control.in/libc0.3: debian/control.in/libc debian/rules.d/control.mk
 	sed -e 's%@libc@%libc0.3%g;s%@archs@%hurd-i386%g;s/nscd, //' < $< > $@
 
-debian/control.in/libc1: debian/control.in/libc debian/rules.d/control.mk
-	sed -e 's%@libc@%libc1%g;s%@archs@%freebsd-i386%g' < $< > $@
+debian/control.in/libc0.1: debian/control.in/libc debian/rules.d/control.mk
+	sed -e 's%@libc@%libc0.1%g;s%@archs@%kfreebsd-i386%g' < $< > $@
 
 debian/control: debian/control.in/main $(control_deps) \
 		   debian/rules.d/control.mk # debian/sysdeps/depflags.pl
@@ -21,7 +21,7 @@
 	cat debian/control.in/libc6		>> $@T
 	cat debian/control.in/libc6.1		>> $@T
 	cat debian/control.in/libc0.3		>> $@T
-	cat debian/control.in/libc1		>> $@T
+	cat debian/control.in/libc0.1		>> $@T
 	cat debian/control.in/sparc64		>> $@T
 	cat debian/control.in/s390x		>> $@T
 	cat debian/control.in/amd64		>> $@T
diff -ur glibc-2.3.5.old/debian/sysdeps/kfreebsd.mk glibc-2.3.5/debian/sysdeps/kfreebsd.mk
--- glibc-2.3.5.old/debian/sysdeps/kfreebsd.mk	2005-12-21 21:26:38.000000000 +0100
+++ glibc-2.3.5/debian/sysdeps/kfreebsd.mk	2005-12-21 21:57:10.000000000 +0100
@@ -1,11 +1,9 @@
-# This is for a Glibc-using FreeBSD system.
-
-GLIBC_OVERLAYS ?= $(shell ls glibc-linuxthreads* glibc-ports* glibc-libidn*)
-
-libc = libc1
+GLIBC_OVERLAYS ?= $(shell ls glibc-linuxthreads* glibc-ports* glibc-libidn* glibc-kfreebsd*)
+MIN_KERNEL_SUPPORTED := 5.0
+libc = libc0.1
 
 # Linuxthreads Config
 threads = yes
 libc_add-ons = linuxthreads $(add-ons)
 
-extra_config_options = $(extra_config_options) --disable-compatible-utmp --enable-kernel-include=4.6
+extra_config_options += --without-tls
--- glibc-2.3.5/debian/control.in/libc.old      2005-12-21 21:26:37.000000000 +0100
+++ glibc-2.3.5/debian/control.in/libc  2005-12-21 23:21:46.000000000 +0100
@@ -3,6 +3,7 @@
 Section: libs
 Priority: required
 Provides: ${locale:Depends}
+Replaces: @libc@-dev (<< 2.3.2.ds1-14)
 Description: GNU C Library: Shared libraries and Timezone data
  Contains the standard libraries that are used by nearly all programs on
  the system. This package includes shared versions of the standard C library
