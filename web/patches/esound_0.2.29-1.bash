#!/bin/bash -e

Status: in BTS

cp debian/control{,.in}
cat $0 | patch -p1
which type-handling
sudo debian/rules clean
cp /usr/share/misc/config.{guess,sub} ./
exit 0

diff -ur esound-0.2.29.old/audio_oss.c esound-0.2.29/audio_oss.c
--- esound-0.2.29.old/audio_oss.c	2004-08-01 22:43:29.000000000 +0200
+++ esound-0.2.29/audio_oss.c	2004-08-01 22:43:49.000000000 +0200
@@ -12,7 +12,7 @@
 
 
 /* FreeBSD uses a different identifier? what other BSDs? */
-#ifdef __FreeBSD__
+#if defined(__FreeBSD__) || defined(__FreeBSD_kernel__)
 #define SNDCTL_DSP_SETDUPLEX DSP_CAP_DUPLEX
 #endif
 
diff -ur esound-0.2.29.old/configure esound-0.2.29/configure
--- esound-0.2.29.old/configure	2004-08-01 22:43:28.000000000 +0200
+++ esound-0.2.29/configure	2004-08-01 22:43:49.000000000 +0200
@@ -8083,7 +8083,7 @@
 echo $ac_n "checking if your platform supports esddsp""... $ac_c" 1>&6
 echo "configure:8085: checking if your platform supports esddsp" >&5
 case "$host_os" in
-  linux* | freebsd* | bsdi4* )
+  linux* | freebsd* | kfreebsd*-gnu | bsdi4* )
     dsp_ok=yes
     ;;
 esac
diff -ur esound-0.2.29.old/configure.in esound-0.2.29/configure.in
--- esound-0.2.29.old/configure.in	2004-08-01 22:43:28.000000000 +0200
+++ esound-0.2.29/configure.in	2004-08-01 22:43:49.000000000 +0200
@@ -366,7 +366,7 @@
 
 AC_MSG_CHECKING([if your platform supports esddsp])
 case "$host_os" in
-  linux* | freebsd* | bsdi4* )
+  linux* | freebsd* | kfreebsd*-gnu | bsdi4* )
     dsp_ok=yes
     ;;
 esac
diff -ur esound-0.2.29.old/debian/control.in esound-0.2.29/debian/control.in
--- esound-0.2.29.old/debian/control.in	2004-08-01 22:48:10.000000000 +0200
+++ esound-0.2.29/debian/control.in	2004-08-01 22:43:49.000000000 +0200
@@ -3,7 +3,7 @@
 Priority: optional
 Maintainer: Ryan Murray <rmurray@debian.org>
 Standards-Version: 3.5.8
-Build-Depends: libaudiofile-dev, libasound2-dev [alpha arm hppa i386 ia64 m68k mips mipsel powerpc s390 sparc], debhelper (>= 3), libwrap0-dev
+Build-Depends: libaudiofile-dev, libasound2-dev [@linux-gnu@], debhelper (>= 3), libwrap0-dev, type-handling (>= 0.2.1)
 
 Package: esound
 Architecture: any
@@ -57,7 +57,7 @@
  use libesd0.
 
 Package: libesd-alsa0
-Architecture: alpha arm hppa i386 ia64 m68k mips mipsel powerpc s390 sh sparc
+Architecture: @linux-gnu@
 Section: libs
 Depends: ${shlibs:Depends}, esound-common (>= ${Source-Version})
 Suggests: esound
diff -ur esound-0.2.29.old/debian/rules esound-0.2.29/debian/rules
--- esound-0.2.29.old/debian/rules	2004-08-01 22:43:29.000000000 +0200
+++ esound-0.2.29/debian/rules	2004-08-01 22:45:48.000000000 +0200
@@ -1,23 +1,34 @@
 #!/usr/bin/make -f
 
-DEB_BUILD_ARCH:=$(shell dpkg --print-installation-architecture)
+DEB_BUILD_GNU_CPU	?= $(shell dpkg-architecture -qDEB_BUILD_GNU_CPU)
+DEB_BUILD_GNU_SYSTEM	?= $(shell dpkg-architecture -qDEB_BUILD_GNU_SYSTEM)
 
 INSTALL:=$(shell pwd)/debian/tmp
 INSTALL_ALSA:=$(INSTALL)-alsa
 export DH_COMPAT=3
 
-ifeq ($(DEB_BUILD_ARCH),hurd-i386)
-	CONFIG_OPTS:=--disable-local-sound
-	SHLIB:="libesd0 (>= 0.2.29-1)"
-	build-targets:=build-debstamp
-	install-targets:=install-debstamp
-	binary-targets:=normal
-else
-	CONFIG_OPTS:=
-	SHLIB:="libesd0 (>= 0.2.29-1) | libesd-alsa0 (>= 0.2.29-1)"
-	build-targets:=build-debstamp build-alsa-debstamp
-	install-targets:=install-debstamp install-alsa-debstamp
-	binary-targets:=alsa normal
+CONFIG_OPTS:=
+SHLIB:="libesd0 (>= 0.2.29-1)"
+build-targets:=build-debstamp
+install-targets:=install-debstamp
+binary-targets:=normal
+
+ifeq (,$(findstring $(DEB_BUILD_GNU_SYSTEM),linux kfreebsd-gnu))
+	CONFIG_OPTS+=--disable-local-sound
+endif
+
+ifeq ($(DEB_BUILD_GNU_SYSTEM),linux)
+	SHLIB+=" | libesd-alsa0 (>= 0.2.29-1)"
+	build-targets+=build-alsa-debstamp
+	install-targets+=install-debstamp
+	binary-targets+=alsa
+endif
+
+ifeq ($(DEB_BUILD_GNU_SYSTEM),kfreebsd-gnu)
+CONFIG_OPTS += $(DEB_BUILD_GNU_CPU)-linux-gnu
+endif
+ifeq ($(DEB_BUILD_GNU_SYSTEM),knetbsd-gnu)
+CONFIG_OPTS += $(DEB_BUILD_GNU_CPU)-gnu
 endif
 
 build: $(build-targets)
@@ -47,6 +58,9 @@
 	-rm -rf debian/tmp `find debian/* -type d ! -name CVS` debian/files* core
 	-rm -f debian/*substvars debian/shlibs.local debian/shlibs
 	-rm -f docs/*.1
+	cat debian/control.in \
+	| sed "s/@linux-gnu@/`type-handling any linux-gnu`/g" \
+	> debian/control
 	dh_clean
 
 install: $(install-targets)
@@ -54,6 +68,7 @@
 	dh_testdir
 	dh_testroot
 	dh_clean
+	dh_installdirs
 	$(MAKE) -C build-normal DESTDIR=$(INSTALL) install
 	mkdir -p $(INSTALL)/usr/share/man/man1
 	cp docs/*.1 $(INSTALL)/usr/share/man/man1
@@ -63,6 +78,7 @@
 install-alsa-debstamp: build-alsa-debstamp
 	dh_testdir
 	dh_testroot
+	dh_installdirs
 	$(MAKE) -C build-alsa DESTDIR=$(INSTALL_ALSA) install-libLTLIBRARIES
 	touch $@
 
diff -ur esound-0.2.29.old/esddsp.c esound-0.2.29/esddsp.c
--- esound-0.2.29.old/esddsp.c	2004-08-01 22:43:28.000000000 +0200
+++ esound-0.2.29/esddsp.c	2004-08-01 22:43:49.000000000 +0200
@@ -65,7 +65,7 @@
 #define REAL_LIBC ((void *) -1L)
 #endif
 
-#if defined(__FreeBSD__) || defined(__bsdi__)
+#if defined(__FreeBSD__) || defined(__FreeBSD_kernel__) || defined(__bsdi__)
 typedef unsigned long request_t;
 #else
 typedef int request_t;
