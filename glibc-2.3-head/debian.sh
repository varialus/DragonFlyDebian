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
exit 0

diff -ur glibc-2.3.5.old/debian/control glibc-2.3.5/debian/control
--- glibc-2.3.5.old/debian/control	2005-12-21 21:26:39.000000000 +0100
+++ glibc-2.3.5/debian/control	2005-12-21 21:30:25.000000000 +0100
@@ -1,7 +1,7 @@
 Source: glibc
 Section: libs
 Priority: required
-Build-Depends: gettext (>= 0.10.37-1), make (>= 3.80-1), dpkg-dev (>= 1.13.5), debianutils (>= 1.13.1), tar (>= 1.13.11), bzip2, texinfo (>= 4.0), linux-kernel-headers (>= 2.6.13+0rc3-2) [!hurd-i386], mig (>= 1.3-2) [hurd-i386], hurd-dev (>= 20020608-1) [hurd-i386], gnumach-dev [hurd-i386], texi2html, file, gcc-4.0 [!powerpc !m68k !hppa !hurd-i386], gcc-3.4 (>= 3.4.4-6) [powerpc], gcc-3.4 [m68k hppa], gcc-3.3 [hurd-i386], autoconf, binutils (>= 2.14.90.0.7-5), sed (>= 4.0.5-4), gawk, debhelper (>= 4.1.76), libc6-dev-amd64 [i386], libc6-dev-ppc64 [powerpc]
+Build-Depends: gettext (>= 0.10.37-1), make (>= 3.80-1), dpkg-dev (>= 1.13.5), debianutils (>= 1.13.1), tar (>= 1.13.11), bzip2, texinfo (>= 4.0), linux-kernel-headers (>= 2.6.13+0rc3-2) [!hurd-i386 !kfreebsd-i386], kfreebsd-kernel-headers [kfreebsd-i386], mig (>= 1.3-2) [hurd-i386], hurd-dev (>= 20020608-1) [hurd-i386], gnumach-dev [hurd-i386], texi2html, file, gcc-4.0 [!powerpc !m68k !hppa !hurd-i386], gcc-3.4 (>= 3.4.4-6) [powerpc], gcc-3.4 [m68k hppa], gcc-3.3 [hurd-i386], autoconf, binutils (>= 2.14.90.0.7-5), sed (>= 4.0.5-4), gawk, debhelper (>= 4.1.76), libc6-dev-amd64 [i386], libc6-dev-ppc64 [powerpc]
 Build-Depends-Indep: perl, po-debconf
 Maintainer: GNU Libc Maintainers <debian-glibc@lists.debian.org>
 Uploaders: Ben Collins <bcollins@debian.org>, GOTO Masanori <gotom@debian.org>, Philip Blundell <pb@nexus.co.uk>, Jeff Bailey <jbailey@raspberryginger.com>, Daniel Jacobowitz <dan@debian.org>, Clint Adams <schizo@debian.org>
@@ -265,8 +265,8 @@
  This package contains a minimal set of libraries needed for the Debian
  installer.  Do not install it on a normal system.
 
-Package: libc1
-Architecture: freebsd-i386
+Package: libc0.1
+Architecture: kfreebsd-i386
 Section: libs
 Priority: required
 Provides: ${locale:Depends}
@@ -276,8 +276,8 @@
  and the standard math library, as well as many others.
  Timezone data is also included.
 
-Package: libc1-dev
-Architecture: freebsd-i386
+Package: libc0.1-dev
+Architecture: kfreebsd-i386
 Section: libdevel
 Priority: standard
 Depends: libc1 (= ${Source-Version})
@@ -286,8 +286,8 @@
  Contains the symlinks, headers, and object files needed to compile
  and link programs which use the standard C library.
 
-Package: libc1-dbg
-Architecture: freebsd-i386
+Package: libc0.1-dbg
+Architecture: kfreebsd-i386
 Section: libdevel
 Priority: extra
 Provides: libc-dbg
@@ -300,8 +300,8 @@
  used by placing that directory in LD_LIBRARY_PATH.
  Most people will not need this package.
 
-Package: libc1-prof
-Architecture: freebsd-i386
+Package: libc0.1-prof
+Architecture: kfreebsd-i386
 Section: libdevel
 Priority: extra
 Depends: libc1 (= ${Source-Version})
@@ -309,8 +309,8 @@
  Static libraries compiled with profiling info (-pg) suitable for use
  with gprof.
 
-Package: libc1-pic
-Architecture: freebsd-i386
+Package: libc0.1-pic
+Architecture: kfreebsd-i386
 Section: libdevel
 Priority: optional
 Conflicts: libc-pic
@@ -323,9 +323,9 @@
  boot floppies. If you are not making your own set of Debian boot floppies
  using the `boot-floppies' package, you probably don't need this package.
 
-Package: libc1-udeb
+Package: libc0.1-udeb
 XC-Package-Type: udeb
-Architecture: freebsd-i386
+Architecture: kfreebsd-i386
 Section: debian-installer
 Priority: extra
 Provides: libc1, libc-udeb, ${locale:Depends}
diff -ur glibc-2.3.5.old/debian/sysdeps/kfreebsd.mk glibc-2.3.5/debian/sysdeps/kfreebsd.mk
--- glibc-2.3.5.old/debian/sysdeps/kfreebsd.mk	2005-12-21 21:26:38.000000000 +0100
+++ glibc-2.3.5/debian/sysdeps/kfreebsd.mk	2005-12-21 21:41:16.000000000 +0100
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
