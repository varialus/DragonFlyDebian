#!/bin/sh
set -ex

if [ "$1" = "" ] ; then
  echo "Usage: $0 ..../glibc-2.3-head/  (to be run from debian source tree)"
  exit 1
fi

# sysdeps dir
tmp=`mktemp -d`
mkdir -p ${tmp}/glibc-ports-2.3.5/sysdeps/unix/bsd/bsd4.4 ${tmp}/linuxthreads/sysdeps/unix/bsd/bsd4.4
cp -a $1/sysdeps/kfreebsd ${tmp}/glibc-ports-2.3.5/sysdeps/unix/bsd/bsd4.4/
cp -a $1/linuxthreads/kfreebsd ${tmp}/linuxthreads/sysdeps/unix/bsd/bsd4.4/
echo "kfreebsd-sysdeps.diff -p0" >> debian/patches/series
(cd ${tmp} && diff -x .svn -Nurd null glibc-ports-2.3.5/ ) > debian/patches/kfreebsd-sysdeps.diff
(cd ${tmp} && diff -x .svn -Nurd null linuxthreads/ ) >> debian/patches/kfreebsd-sysdeps.diff
rm -rf ${tmp}

for i in `ls $1/patches` ; do
  cat $1/patches/$i/* > debian/patches/kfreebsd-$i.diff
  echo "kfreebsd-$i.diff -p0" >> debian/patches/series
done

patch -p1 < $0

# re-generate debian/control
debian/rules debian/control

exit 0

diff -u glibc-2.3.5/debian/control.in/main glibc-2.3.5/debian/control.in/main
--- glibc-2.3.5/debian/control.in/main
+++ glibc-2.3.5/debian/control.in/main
@@ -1,7 +1,7 @@
 Source: @glibc@
 Section: libs
 Priority: required
-Build-Depends: gettext (>= 0.10.37-1), make (>= 3.80-1), dpkg-dev (>= 1.13.5), debianutils (>= 1.13.1), tar (>= 1.13.11), bzip2, texinfo (>= 4.0), linux-kernel-headers (>= 2.6.13+0rc3-2) [!hurd-i386], mig (>= 1.3-2) [hurd-i386], hurd-dev (>= 20020608-1) [hurd-i386], gnumach-dev [hurd-i386], texi2html, file, gcc-4.0 [!powerpc !m68k !hppa !hurd-i386], gcc-3.4 (>= 3.4.4-6) [powerpc], gcc-3.4 [m68k hppa], gcc-3.3 [hurd-i386], autoconf, binutils (>= 2.16.1cvs20051109-1), sed (>= 4.0.5-4), gawk, debhelper (>= 4.1.76), libc6-dev-amd64 [i386], libc6-dev-ppc64 [powerpc], quilt
+Build-Depends: gettext (>= 0.10.37-1), make (>= 3.80-1), dpkg-dev (>= 1.13.5), debianutils (>= 1.13.1), tar (>= 1.13.11), bzip2, texinfo (>= 4.0), linux-kernel-headers (>= 2.6.13+0rc3-2) [!hurd-i386 !kfreebsd-i386], mig (>= 1.3-2) [hurd-i386], hurd-dev (>= 20020608-1) [hurd-i386], gnumach-dev [hurd-i386], kfreebsd-kernel-headers (>= 0.01) [kfreebsd-i386], texi2html, file, gcc-4.0 [!powerpc !m68k !hppa !hurd-i386], gcc-3.4 (>= 3.4.4-6) [powerpc], gcc-3.4 [m68k hppa], gcc-3.3 [hurd-i386], autoconf, binutils (>= 2.16.1cvs20051109-1), sed (>= 4.0.5-4), gawk, debhelper (>= 4.1.76), libc6-dev-amd64 [i386], libc6-dev-ppc64 [powerpc], quilt
 Build-Depends-Indep: perl, po-debconf, po4a
 Maintainer: GNU Libc Maintainers <debian-glibc@lists.debian.org>
 Uploaders: Ben Collins <bcollins@debian.org>, GOTO Masanori <gotom@debian.org>, Philip Blundell <pb@nexus.co.uk>, Jeff Bailey <jbailey@raspberryginger.com>, Daniel Jacobowitz <dan@debian.org>, Clint Adams <schizo@debian.org>, Denis Barbier <barbier@debian.org>
--- glibc-2.3.5/debian/sysdeps/kfreebsd-gnu.mk
+++ glibc-2.3.5.orig/debian/sysdeps/kfreebsd-gnu.mk
@@ -1,11 +0,0 @@
-# This is for a Glibc-using FreeBSD system.
-
-GLIBC_OVERLAYS ?= $(shell ls glibc-linuxthreads* glibc-ports* glibc-libidn*)
-
-libc = libc1
-
-# Linuxthreads Config
-threads = yes
-libc_add-ons = linuxthreads $(add-ons)
-
-extra_config_options = $(extra_config_options) --disable-compatible-utmp --enable-kernel-include=4.6
diff -u glibc-2.3.5/debian/sysdeps/linux.mk glibc-2.3.5/debian/sysdeps/linux.mk
--- glibc-2.3.5/debian/sysdeps/linux.mk
+++ glibc-2.3.5/debian/sysdeps/linux.mk
@@ -39,7 +39,7 @@
 nptl_MIN_KERNEL_SUPPORTED = 2.6.0
 nptl_LIBDIR = /tls
 
-LINUX_HEADER_DIR = $(stamp)mkincludedir
+KERNEL_HEADER_DIR = $(stamp)mkincludedir
 $(stamp)mkincludedir:
 	rm -rf debian/include
 	mkdir debian/include
diff -u glibc-2.3.5/debian/rules.d/build.mk glibc-2.3.5/debian/rules.d/build.mk
--- glibc-2.3.5/debian/rules.d/build.mk
+++ glibc-2.3.5/debian/rules.d/build.mk
@@ -13,7 +13,7 @@
 
 
 $(patsubst %,mkbuilddir_%,$(GLIBC_PASSES)) :: mkbuilddir_% : $(stamp)mkbuilddir_%
-$(stamp)mkbuilddir_%: $(stamp)patch-stamp $(LINUX_HEADER_DIR)
+$(stamp)mkbuilddir_%: $(stamp)patch-stamp $(KERNEL_HEADER_DIR)
 	@echo Making builddir for $(curpass)
 	test -d $(DEB_BUILDDIR) || mkdir $(DEB_BUILDDIR)
 	touch $@
--- glibc-2.3.5/debian/control.in/opt~	2006-01-12 14:48:52.000000000 +0100
+++ glibc-2.3.5/debian/control.in/opt	2006-01-12 14:49:46.000000000 +0100
@@ -56,3 +56,23 @@
  Most notably, IBM's JDK. If you experience problems with such
  applications, you will need to remove this package.
 
+Package: libc0.1-i686
+Architecture: kfreebsd-i386
+Section: libs
+Priority: extra
+Pre-Depends: @libc@ (= ${Source-Version})
+Description: GNU C Library: Shared libraries [i686 optimized]
+ Contains the standard libraries that are used by nearly all programs on
+ the system. This package includes shared versions of the standard C
+ library and the standard math library, as well as many others.
+ .
+ This set of libraries is optimized for i686 machines, and will only be
+ used on an i686 class CPU (check the output of `uname -m').  This includes 
+ Pentium Pro, Pentium II/III/IV, Celeron CPU's and similar class CPU's
+ (including clones such as AMD Athlon/Opteron, VIA C3 Nehemiah, but not VIA 
+ C3 Ezla).  
+  .
+ WARNING: Some third-party binaries may not work well with these libraries.
+ Most notably, IBM's JDK. If you experience problems with such
+ applications, you will need to remove this package.
+
diff -u glibc-2.3.5/debian/rules.d/control.mk glibc-2.3.5/debian/rules.d/control.mk
--- glibc-2.3.5/debian/rules.d/control.mk
+++ glibc-2.3.5/debian/rules.d/control.mk
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
--- glibc-2.3.5.orig/debian/sysdeps/kfreebsd.mk
+++ glibc-2.3.5/debian/sysdeps/kfreebsd.mk
@@ -0,0 +1,74 @@
+GLIBC_OVERLAYS ?= $(shell ls glibc-linuxthreads* glibc-ports* glibc-libidn*)
+MIN_KERNEL_SUPPORTED := 5.4.0
+libc = libc0.1
+add-ons = glibc-ports-2.3.5
+
+GLIBC_PASSES += i686
+DEB_ARCH_REGULAR_PACKAGES += libc0.1-i686
+
+# Support multiple makes at once based on number of processors
+# Common wisdom says parallel make can be up to 2n+1.
+# Should we do that to get faster builds?
+NJOBS:=$(shell getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)
+ifeq ($(NJOBS),-1)
+ NJOBS:=1
+endif
+
+ifeq ($(NJOBS),0)
+ NJOBS=1
+endif
+
+# Linuxthreads Config
+threads = yes
+libc_add-ons = linuxthreads $(add-ons)
+libc_extra_config_options = $(extra_config_options) --with-tls --with-__thread --disable-compatible-utmp
+
+# We use -march=i686 and glibc's i686 routines use cmov, so require it.
+# A Debian-local glibc patch adds cmov to the search path.
+i686_add-ons = linuxthreads $(add-ons)
+i686_configure_target=i686-kfreebsd
+i686_configure_build=i686-kfreebsd
+i686_extra_cflags = -march=i686 -mtune=i686 -g1 -O3
+i686_LIBDIR = /i686/cmov
+i686_extra_config_options = $(extra_config_options) --disable-profile --with-tls --with-__thread --disable-compatible-utmp
+
+ifndef KFREEBSD_SOURCE
+  KFREEBSD_HEADERS := /usr/include
+else
+  KFREEBSD_HEADERS := $(KFREEBSD_SOURCE)/sys
+endif
+
+# Minimum Kernel supported
+with_headers = --with-headers=$(shell pwd)/debian/include --enable-kernel=$(call xx,MIN_KERNEL_SUPPORTED)
+
+KERNEL_HEADER_DIR = $(stamp)mkincludedir
+$(stamp)mkincludedir:
+	rm -rf debian/include
+	mkdir debian/include
+	ln -s $(KFREEBSD_HEADERS)/machine debian/include
+	ln -s $(KFREEBSD_HEADERS)/net debian/include
+	ln -s $(KFREEBSD_HEADERS)/netatalk debian/include
+	ln -s $(KFREEBSD_HEADERS)/netipx debian/include
+	ln -s $(KFREEBSD_HEADERS)/osreldate.h debian/include
+	ln -s $(KFREEBSD_HEADERS)/sys debian/include
+	ln -s $(KFREEBSD_HEADERS)/vm debian/include
+
+	# To make configure happy if libc0.1-dev is not installed.
+	touch debian/include/assert.h
+
+	touch $@
+
+# Also to make configure happy.
+export CPPFLAGS = -isystem $(shell pwd)/debian/include
+
+# This round of ugliness decomposes the FreeBSD kernel version number
+# into an integer so it can be easily compared and then does so.
+CURRENT_KERNEL_VERSION=$(shell uname -r)
+define kernel_check
+(minimum=$$((`echo $(1) | sed 's/\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\)/\1 \* 10000 + \2 \* 100 + \3/'`)); \
+current=$$((`echo $(CURRENT_KERNEL_VERSION) | sed 's/\([0-9]*\)\.\([0-9]*\).*/\1 \* 10000 + \2 \* 100/'`)); \
+if [ $$current -lt $$minimum ]; then \
+  false; \
+fi)
+endef
+
--- glibc-2.3.5.old/debian/sysdeps/depflags.pl	2005-12-23 00:40:20.000000000 +0100
+++ glibc-2.3.5/debian/sysdeps/depflags.pl	2005-12-23 00:44:38.000000000 +0100
@@ -33,6 +33,13 @@
 		'ppp (<= 2.2.0f-24)', 'libgdbmg1-dev (<= 1.7.3-24)');
     push @{$libc_dev_c{'Depends'}}, 'linux-kernel-headers';
 }
+if ($DEB_HOST_GNU_SYSTEM eq "kfreebsd-gnu") {
+    push @{$libc_c{'Suggests'}}, 'locales';
+    push @{$libc_c{'Replaces'}}, 'libc0.1-dev (<< 2.3.2.ds1-14)';
+    push @{$libc_dev_c{'Recommends'}}, 'c-compiler';
+    push @{$libc_dev_c{'Replaces'}}, 'kfreebsd-kernel-headers (<< 0.11)';
+    push @{$libc_dev_c{'Depends'}}, 'kfreebsd-kernel-headers (>= 0.11)';
+}
 
 # ${glibc}-doc is suggested by $libc_c and $libc_dev_c.
 push @{$libc_c{'Suggests'}}, "${glibc}-doc";
--- glibc-2.3.5/debian/rules~  2005-12-23 11:32:12.000000000 +0100
+++ glibc-2.3.5/debian/rules   2005-12-23 11:38:31.000000000 +0100
@@ -45,6 +45,7 @@
 DEB_HOST_ARCH         ?= $(shell dpkg-architecture -qDEB_HOST_ARCH)
 DEB_HOST_GNU_CPU      ?= $(shell dpkg-architecture -qDEB_HOST_GNU_CPU)
 DEB_HOST_GNU_TYPE     ?= $(shell dpkg-architecture -qDEB_HOST_GNU_TYPE)
+DEB_HOST_GNU_SYSTEM   ?= $(shell dpkg-architecture -qDEB_HOST_GNU_SYSTEM)
 DEB_HOST_ARCH_OS      ?= $(shell dpkg-architecture -qDEB_HOST_ARCH_OS)
 DEB_BUILD_ARCH        ?= $(shell dpkg-architecture -qDEB_BUILD_ARCH)
 DEB_BUILD_GNU_CPU     ?= $(shell dpkg-architecture -qDEB_BUILD_GNU_CPU)
