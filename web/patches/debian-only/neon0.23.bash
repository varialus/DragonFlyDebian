#!/bin/bash
set -e

cp debian/control{,.in}
patch -p1 < $0
which type-handling
fakeroot debian/rules clean
exit

diff -ur neon0.23-0.23.9.dfsg.3.old/debian/control.in neon0.23-0.23.9.dfsg.3/debian/control.in
--- neon0.23-0.23.9.dfsg.3.old/debian/control.in	2005-05-05 19:01:15.000000000 +0200
+++ neon0.23-0.23.9.dfsg.3/debian/control.in	2005-05-05 19:10:54.000000000 +0200
@@ -3,12 +3,12 @@
 Priority: optional
 Maintainer: Debian OpenOffice Team <debian-openoffice@lists.debian.org>
 Uploaders: Rene Engelhard <rene@debian.org>, Chris Halls <halls@debian.org>
-Build-Depends: debhelper (>= 4.0.0), libxml2-dev, libssl-dev, zlib1g-dev | libz-dev, dpatch, autotools-dev
+Build-Depends: debhelper (>= 4.0.0), libxml2-dev, libssl-dev, zlib1g-dev | libz-dev, dpatch, autotools-dev, type-handling (>= 0.2.1)
 Standards-Version: 3.6.1
 
 Package: libneon23
 Section: oldlibs
-Architecture: i386 powerpc s390 sparc
+Architecture: @arch@
 Depends: ${shlibs:Depends}
 Description: An HTTP and WebDAV client library [old version]
  neon is an HTTP and WebDAV client library, with a C language API.
@@ -41,7 +41,7 @@
 Package: libneon23-dev
 Section: libdevel
 Priority: extra
-Architecture: i386 powerpc sparc s390
+Architecture: @arch@
 Conflicts: libneon-dev
 Provides: libneon-dev
 Replaces: libneon-dev
diff -ur neon0.23-0.23.9.dfsg.3.old/debian/rules neon0.23-0.23.9.dfsg.3/debian/rules
--- neon0.23-0.23.9.dfsg.3.old/debian/rules	2005-05-05 14:09:49.000000000 +0200
+++ neon0.23-0.23.9.dfsg.3/debian/rules	2005-05-05 19:10:32.000000000 +0200
@@ -45,7 +45,8 @@
 	-rm -rf Makefile src/Makefile test/Makefile config.h config.cache config.log config.status
 	-rm -rf libtool neon-config src/.libs src/*.o
 	dh_clean
-
+	sed -e "s/@arch@/`type-handling i386,powerpc,s390,sparc any`/g" \
+	< debian/control.in > debian/control
 
 install: install-stamp
 install-stamp: build-stamp
