#!/bin/bash -e

# Status: in BTS

cp debian/control{,.in}
cat $0 | patch -p1
which type-handling
fakeroot debian/rules clean
exit 0

diff -ur jack-audio-connection-kit-0.98.1.old/debian/control.in jack-audio-connection-kit-0.98.1/debian/control.in
--- jack-audio-connection-kit-0.98.1.old/debian/control.in	2004-09-18 19:38:58.000000000 +0200
+++ jack-audio-connection-kit-0.98.1/debian/control.in	2004-09-18 20:31:24.000000000 +0200
@@ -3,9 +3,10 @@
 Priority: optional
 Maintainer: Junichi Uekawa <dancer@debian.org>
 Uploaders: Guenter Geiger (Debian/GNU) <geiger@debian.org>, Robert Jordens <jordens@debian.org>
-Build-Depends: debhelper (>> 4.1.0), cdbs, dh-buildinfo, libasound2-dev, 
- libsndfile1-dev, doxygen, libcap-dev, autotools-dev, libreadline4-dev,
- libraw1394-dev,
+Build-Depends: debhelper (>> 4.1.0), cdbs, dh-buildinfo,
+ libasound2-dev [@linux-gnu@], libsndfile1-dev, doxygen,
+ libcap-dev [@linux-gnu@], autotools-dev, libreadline4-dev,
+ libraw1394-dev [@linux-gnu@], type-handling (>= 0.2.1),
  autoconf, automake1.7, libtool
 Build-Conflicts: libcap2-dev
 Standards-Version: 3.6.1
@@ -39,7 +40,7 @@
 Package: libjack0.80.0-dev
 Architecture: any
 Section: libdevel
-Depends: libjack0.80.0-0 (= ${Source-Version}), libasound2-dev, libglib1.2-dev, pkg-config
+Depends: libjack0.80.0-0 (= ${Source-Version})@libasound@, libglib1.2-dev, pkg-config
 Provides: libjack-dev
 Conflicts: libjack-dev 
 Replaces: libjack-dev, libjack0.71.2-0 (<< 0.75.0-1)
diff -ur jack-audio-connection-kit-0.98.1.old/debian/rules jack-audio-connection-kit-0.98.1/debian/rules
--- jack-audio-connection-kit-0.98.1.old/debian/rules	2004-09-18 19:28:44.000000000 +0200
+++ jack-audio-connection-kit-0.98.1/debian/rules	2004-09-19 09:36:35.000000000 +0200
@@ -8,6 +8,9 @@
 #
 # $Id: rules 342 2004-03-25 14:00:53Z rj $
 #
+include /usr/share/cdbs/1/rules/buildvars.mk
+DEB_HOST_GNU_TYPE	= i386-gnu
+DEB_BUILD_GNU_TYPE	= i386-gnu
 
 include /usr/share/cdbs/1/class/makefile.mk
 DEB_UPSTREAM_VERSION := $(shell echo $(DEB_VERSION) | sed 's/-[^-]*//')
@@ -22,18 +25,22 @@
 
 #unused, TODO get this soname from configure.in
 #DEB_SONAME_VERSION := 0.91.1-0
-DEB_CONFIGURE_EXTRA_FLAGS := --enable-capabilities --enable-resize \
+DEB_CONFIGURE_EXTRA_FLAGS := --enable-resize \
 	--enable-timestamps --enable-iec61883 --with-oldtrans \
-	--with-default-tmpdir=/dev/shm --disable-ensure-mlock
+	--disable-ensure-mlock
 	# --enable-posix-shm
 # to avoid stripping when nostrip is set in DEB_BUILD_OPTIONS
 ifeq (,$(findstring nostrip,$(DEB_BUILD_OPTIONS)))
   DEB_CONFIGURE_EXTRA_FLAGS += --enable-stripped-jackd
 endif
 
+ifeq ($(DEB_HOST_GNU_SYSTEM),linux)
+  DEB_CONFIGURE_EXTRA_FLAGS += --enable-capabilities --with-default-tmpdir=/dev/shm 
+endif
+
 ifeq (,$(findstring noopt,$(DEB_BUILD_OPTIONS)))
 # do optimization for the different architectures
-ifneq (,$(findstring i386,$(DEB_BUILD_ARCH)))
+ifneq (,$(findstring i386,$(DEB_HOST_GNU_CPU)))
 		DEB_CONFIGURE_EXTRA_FLAGS += --enable-optimize
 		OPTI_FLAGS := -D_REENTRANT -O3 -fomit-frame-pointer -ffast-math -fstrength-reduce -funroll-loops -fmove-all-movables
 		CXXFLAGS += $(OPTI_FLAGS)
@@ -59,11 +66,21 @@
 	dh_buildinfo
 
 binary-predeb/jackd::
+ifeq ($(DEB_HOST_GNU_SYSTEM),linux)
 	chown root.audio debian/jackd/usr/bin/jackstart
 	chmod u=rwxs,g=rx,o=r debian/jackd/usr/bin/jackstart
+endif
+
+ifeq ($(DEB_HOST_GNU_SYSTEM),linux)
+libasound = , libasound2-dev
+endif
 
 clean::
 	-rm -f debian/stamp-autotools-maintregen-arch
+	cat debian/control.in \
+	| sed "s/@linux-gnu@/`type-handling any linux-gnu`/g" \
+	| sed "s/@libasound@/$(libasound)/g" \
+	> debian/control
                                                                                 
 .PHONY: faq
 # this target fetches the FAQ from the JACK homepage
