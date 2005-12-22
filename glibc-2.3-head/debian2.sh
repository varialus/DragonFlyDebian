#!/bin/sh
set -ex

pwd=`pwd`

if [ "$1" = "" ] ; then
  echo "Usage: $0 ..../glibc-2.3-head/  (to be run from debian source tree)"
  exit 1
fi

cat << EOF > debian/patches/kfreebsd-sysdeps.dpatch
#! /bin/sh -e

# All lines beginning with \`# DP:' are a description of the patch.
# DP: Description: sysdeps to support GNU/kFreeBSD
# DP: Related bugs:
# DP: Upstream status: Not submitted
# DP: Status Details:
# DP: Date: 2005-12-20

PATCHLEVEL=0

if [ \$# -ne 2 ]; then
    echo >&2 "\`basename \$0\`: script expects -patch|-unpatch as argument"
    exit 1
fi
case "\$1" in
    -patch) patch -d "\$2" -f --no-backup-if-mismatch -p\$PATCHLEVEL < \$0;;
    -unpatch) patch -d "\$2" -f --no-backup-if-mismatch -R -p\$PATCHLEVEL  < \$0;;
    *)
        echo >&2 "\`basename \$0\`: script expects -patch|-unpatch as argument"
        exit 1
esac
exit 0

EOF

# sysdeps dir
tmp=`mktemp -d`
mkdir -p ${tmp}/sysdeps/unix/bsd/bsd4.4 ${tmp}/linuxthreads/sysdeps/unix/bsd/bsd4.4
cp -a $1/sysdeps/kfreebsd ${tmp}/sysdeps/unix/bsd/bsd4.4/
cp -a $1/linuxthreads/kfreebsd ${tmp}/linuxthreads/sysdeps/unix/bsd/bsd4.4/
(cd ${tmp} && diff -x .svn -Nurd null sysdeps/ ) >> debian/patches/kfreebsd-sysdeps.dpatch
(cd ${tmp} && diff -x .svn -Nurd null linuxthreads/ ) >> debian/patches/kfreebsd-sysdeps.dpatch
rm -rf ${tmp}
echo kfreebsd-sysdeps >> debian/patches/00list

cp $1/patches/* debian/patches/
ls $1/patches | sed -e "s,\.dpatch$,,g" >> debian/patches/00list

patch -p1 < $0
exit 0

diff -u glibc-2.3.5/debian/control.in/main glibc-2.3.5/debian/control.in/main
--- glibc-2.3.5/debian/control.in/main
+++ glibc-2.3.5/debian/control.in/main
@@ -1,7 +1,7 @@
 Source: @glibc@
 Section: libs
 Priority: required
-Build-Depends: gettext (>= 0.10.37-1), make (>= 3.80-1), dpkg-dev (>= 1.13.5), debianutils (>= 1.13.1), tar (>= 1.13.11), bzip2, texinfo (>= 4.0), linux-kernel-headers (>= 2.6.13+0rc3-2) [!hurd-i386], mig (>= 1.3-2) [hurd-i386], hurd-dev (>= 20020608-1) [hurd-i386], gnumach-dev [hurd-i386], texi2html, file, gcc-4.0 [!powerpc !m68k !hppa !hurd-i386], gcc-3.4 (>= 3.4.4-6) [powerpc], gcc-3.4 [m68k hppa], gcc-3.3 [hurd-i386], autoconf, binutils (>= 2.14.90.0.7-5), sed (>= 4.0.5-4), gawk, debhelper (>= 4.1.76), libc6-dev-amd64 [i386], libc6-dev-ppc64 [powerpc]
+Build-Depends: gettext (>= 0.10.37-1), make (>= 3.80-1), dpkg-dev (>= 1.13.5), debianutils (>= 1.13.1), tar (>= 1.13.11), bzip2, texinfo (>= 4.0), linux-kernel-headers (>= 2.6.13+0rc3-2) [!hurd-i386 !kfreebsd-i386], mig (>= 1.3-2) [hurd-i386], hurd-dev (>= 20020608-1) [hurd-i386], gnumach-dev [hurd-i386], kfreebsd-kernel-headers (>= 0.01) [kfreebsd-i386], texi2html, file, gcc-4.0 [!powerpc !m68k !hppa !hurd-i386], gcc-3.4 (>= 3.4.4-6) [powerpc], gcc-3.4 [m68k hppa], gcc-3.3 [hurd-i386], autoconf, binutils (>= 2.14.90.0.7-5), sed (>= 4.0.5-4), gawk, debhelper (>= 4.1.76), libc6-dev-amd64 [i386], libc6-dev-ppc64 [powerpc]
 Build-Depends-Indep: perl, po-debconf
 Maintainer: GNU Libc Maintainers <debian-glibc@lists.debian.org>
 Uploaders: Ben Collins <bcollins@debian.org>, GOTO Masanori <gotom@debian.org>, Philip Blundell <pb@nexus.co.uk>, Jeff Bailey <jbailey@raspberryginger.com>, Daniel Jacobowitz <dan@debian.org>, Clint Adams <schizo@debian.org>
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
diff -u glibc-2.3.5/debian/control glibc-2.3.5/debian/control
--- glibc-2.3.5/debian/control
+++ glibc-2.3.5/debian/control
@@ -1,7 +1,7 @@
 Source: glibc
 Section: libs
 Priority: required
-Build-Depends: gettext (>= 0.10.37-1), make (>= 3.80-1), dpkg-dev (>= 1.13.5), debianutils (>= 1.13.1), tar (>= 1.13.11), bzip2, texinfo (>= 4.0), linux-kernel-headers (>= 2.6.13+0rc3-2) [!hurd-i386], mig (>= 1.3-2) [hurd-i386], hurd-dev (>= 20020608-1) [hurd-i386], gnumach-dev [hurd-i386], texi2html, file, gcc-4.0 [!powerpc !m68k !hppa !hurd-i386], gcc-3.4 (>= 3.4.4-6) [powerpc], gcc-3.4 [m68k hppa], gcc-3.3 [hurd-i386], autoconf, binutils (>= 2.14.90.0.7-5), sed (>= 4.0.5-4), gawk, debhelper (>= 4.1.76), libc6-dev-amd64 [i386], libc6-dev-ppc64 [powerpc]
+Build-Depends: gettext (>= 0.10.37-1), make (>= 3.80-1), dpkg-dev (>= 1.13.5), debianutils (>= 1.13.1), tar (>= 1.13.11), bzip2, texinfo (>= 4.0), linux-kernel-headers (>= 2.6.13+0rc3-2) [!hurd-i386 !kfreebsd-i386], mig (>= 1.3-2) [hurd-i386], hurd-dev (>= 20020608-1) [hurd-i386], gnumach-dev [hurd-i386], kfreebsd-kernel-headers (>= 0.01), texi2html, file, gcc-4.0 [!powerpc !m68k !hppa !hurd-i386], gcc-3.4 (>= 3.4.4-6) [powerpc], gcc-3.4 [m68k hppa], gcc-3.3 [hurd-i386], autoconf, binutils (>= 2.14.90.0.7-5), sed (>= 4.0.5-4), gawk, debhelper (>= 4.1.76), libc6-dev-amd64 [i386], libc6-dev-ppc64 [powerpc]
 Build-Depends-Indep: perl, po-debconf
 Maintainer: GNU Libc Maintainers <debian-glibc@lists.debian.org>
 Uploaders: Ben Collins <bcollins@debian.org>, GOTO Masanori <gotom@debian.org>, Philip Blundell <pb@nexus.co.uk>, Jeff Bailey <jbailey@raspberryginger.com>, Daniel Jacobowitz <dan@debian.org>, Clint Adams <schizo@debian.org>
@@ -26,7 +26,7 @@
 Provides: i18ndata
 Depends: ${locale:Depends}, debconf | debconf-2.0
 Conflicts: localebin, wg15-locale, i18ndata, locale-ja, locale-ko, locale-vi, locale-zh
-Replaces: localebin, wg15-locale, libc6-bin, i18ndata, glibc2, locale-ja, locale-ko, locale-vi, locale-zh
+Replaces: localebin, wg15-locale, libc0.1-bin, i18ndata, glibc2, locale-ja, locale-ko, locale-vi, locale-zh
 Description: GNU C Library: National Language (locale) data [support]
  Machine-readable data files, shared objects and programs used by the
  C library for localization (l10n) and internationalization (i18n) support.
@@ -38,7 +38,7 @@
  by default. This created a package that unpacked to an excess of 30 megs.
 
 Package: nscd
-Architecture: alpha amd64 arm armeb i386 m68k mips mipsel powerpc sparc ia64 hppa s390 sh3 sh4 sh3eb sh4eb freebsd-i386
+Architecture: alpha amd64 arm armeb i386 m68k mips mipsel powerpc sparc ia64 hppa s390 sh3 sh4 sh3eb sh4eb kfreebsd-i386
 Section: admin
 Priority: optional
 Depends: libc6 (>= ${Source-Version})
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
@@ -276,22 +276,22 @@
  and the standard math library, as well as many others.
  Timezone data is also included.
 
-Package: libc1-dev
-Architecture: freebsd-i386
+Package: libc0.1-dev
+Architecture: kfreebsd-i386
 Section: libdevel
 Priority: standard
-Depends: libc1 (= ${Source-Version})
+Depends: libc0.1 (= ${Source-Version})
 Recommends: gcc | c-compiler
 Description: GNU C Library: Development Libraries and Header Files
  Contains the symlinks, headers, and object files needed to compile
  and link programs which use the standard C library.
 
-Package: libc1-dbg
-Architecture: freebsd-i386
+Package: libc0.1-dbg
+Architecture: kfreebsd-i386
 Section: libdevel
 Priority: extra
 Provides: libc-dbg
-Depends: libc1 (= ${Source-Version})
+Depends: libc0.1 (= ${Source-Version})
 Description: GNU C Library: Libraries with debugging symbols
  Contains unstripped shared libraries.
  This package is provided primarily to provide a backtrace with
@@ -300,22 +300,22 @@
  used by placing that directory in LD_LIBRARY_PATH.
  Most people will not need this package.
 
-Package: libc1-prof
-Architecture: freebsd-i386
+Package: libc0.1-prof
+Architecture: kfreebsd-i386
 Section: libdevel
 Priority: extra
-Depends: libc1 (= ${Source-Version})
+Depends: libc0.1 (= ${Source-Version})
 Description: GNU C Library: Profiling Libraries
  Static libraries compiled with profiling info (-pg) suitable for use
  with gprof.
 
-Package: libc1-pic
-Architecture: freebsd-i386
+Package: libc0.1-pic
+Architecture: kfreebsd-i386
 Section: libdevel
 Priority: optional
 Conflicts: libc-pic
 Provides: libc-pic, glibc-pic
-Depends: libc1 (= ${Source-Version})
+Depends: libc0.1 (= ${Source-Version})
 Description: GNU C Library: PIC archive library
  Contains an archive library (ar file) composed of individual shared objects.
  This is used for creating a library which is a smaller subset of the
@@ -323,12 +323,13 @@
  boot floppies. If you are not making your own set of Debian boot floppies
  using the `boot-floppies' package, you probably don't need this package.
 
-Package: libc1-udeb
+Package: libc0.1-udeb
 XC-Package-Type: udeb
-Architecture: freebsd-i386
+Architecture: kfreebsd-i386
 Section: debian-installer
 Priority: extra
-Provides: libc1, libc-udeb, ${locale:Depends}
+Provides: libc0.1, libc-udeb, ${locale:Depends}
+Depends: libnss-dns-udeb, libnss-files-udeb
 Description: GNU C Library: Shared libraries - udeb
  Contains the standard libraries that are used by nearly all programs on
  the system. This package includes shared versions of the standard C library
@@ -428,7 +429,7 @@
 Architecture: sparc
 Section: libs
 Priority: extra
-Pre-Depends: libc6 (= ${Source-Version})
+Pre-Depends: libc0.1 (= ${Source-Version})
 Description: GNU C Library: Shared libraries [v9 optimized]
  Contains the standard libraries that are used by nearly all programs on
  the system. This package includes shared versions of the standard C
@@ -446,7 +447,7 @@
 Architecture: sparc
 Section: libs
 Priority: extra
-Pre-Depends: libc6 (= ${Source-Version})
+Pre-Depends: libc0.1 (= ${Source-Version})
 Description: GNU C Library: Shared libraries [v9b optimized]
  Contains the standard libraries that are used by nearly all programs on
  the system. This package includes shared versions of the standard C
@@ -464,7 +465,7 @@
 Architecture: i386
 Section: libs
 Priority: extra
-Pre-Depends: libc6 (= ${Source-Version})
+Pre-Depends: libc0.1 (= ${Source-Version})
 Description: GNU C Library: Shared libraries [i686 optimized]
  Contains the standard libraries that are used by nearly all programs on
  the system. This package includes shared versions of the standard C
--- glibc-2.3.5.orig/debian/sysdeps/kfreebsd.mk
+++ glibc-2.3.5/debian/sysdeps/kfreebsd.mk
@@ -0,0 +1,60 @@
+GLIBC_OVERLAYS ?= $(shell ls glibc-linuxthreads* glibc-ports* glibc-libidn*)
+MIN_KERNEL_SUPPORTED := 5.2.0
+libc = libc0.1
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
+
+libc_extra_config_options = $(extra_config_options) --with-tls --with-__thread --disable-compatible-utmp
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
