#!/bin/bash -e

# Status: in BTS.

cp debian/control{,.in}
cat $0 | patch -p1
which type-handling
fakeroot debian/rules clean
exit 0

diff -ur aalib-1.4p5.old/debian/control.in aalib-1.4p5/debian/control.in
--- aalib-1.4p5.old/debian/control.in	2004-07-31 20:06:26.000000000 +0200
+++ aalib-1.4p5/debian/control.in	2004-07-31 19:47:03.000000000 +0200
@@ -2,7 +2,7 @@
 Section: libs
 Priority: optional
 Maintainer: Joey Hess <joeyh@debian.org>
-Build-Depends: debhelper (>= 4.1.1), slang1-dev, libx11-dev, libncurses5-dev, libgpmg1-dev [!hurd-i386], autoconf, libtool (>= 1.3.5), automake1.7, dpkg-dev (>= 1.9.0)
+Build-Depends: debhelper (>= 4.1.1), slang1-dev, libx11-dev, libncurses5-dev, libgpmg1-dev [@linux-gnu@], autoconf, libtool (>= 1.3.5), automake1.7, dpkg-dev (>= 1.9.0), type-handling (>= 0.2.1)
 Standards-Version: 3.5.10.0
 
 Package: aalib1-dev
diff -ur aalib-1.4p5.old/debian/rules aalib-1.4p5/debian/rules
--- aalib-1.4p5.old/debian/rules	2004-07-31 20:05:45.000000000 +0200
+++ aalib-1.4p5/debian/rules	2004-07-31 19:47:46.000000000 +0200
@@ -31,6 +31,9 @@
 		ltmain.sh configure doc/Makefile.in src/Makefile.in \
 		man/Makefile.in doc/Makefile src/Makefile man/Makefile \
 		src/config.h.in
+	cat debian/control.in \
+	| sed "s/@linux-gnu@/`type-handling any linux-gnu`/g" \
+	> debian/control
 
 install: DH_OPTIONS=
 install: build
