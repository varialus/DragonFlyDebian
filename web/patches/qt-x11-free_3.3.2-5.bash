#!/bin/bash -e

cp debian/control{,.in}
cat $0 | patch -p1
which type-handling
fakeroot debian/rules clean
exit 0

diff -ur qt-x11-free-3.3.2.old/debian/control.in qt-x11-free-3.3.2/debian/control.in
--- qt-x11-free-3.3.2.old/debian/control.in	2004-08-08 19:07:45.000000000 +0200
+++ qt-x11-free-3.3.2/debian/control.in	2004-08-12 01:30:41.000000000 +0200
@@ -1,5 +1,5 @@
 Source: qt-x11-free
-Build-Depends: debhelper (>= 4.1.26), xlibs-static-dev (>= 4.3.0.dfsg.1-4), libxext-dev (>= 4.3.0.dfsg.1-4), libxrandr-dev (>= 4.3.0.dfsg.1-4), x-dev (>= 4.3.0.dfsg.1-4), libsm-dev (>= 4.3.0.dfsg.1-4), libxmu-dev (>= 4.3.0.dfsg.1-4), libice-dev (>= 4.3.0.dfsg.1-4), libx11-dev (>= 4.3.0.dfsg.1-4), libxt-dev (>= 4.3.0.dfsg.1-4), libjpeg62-dev, zlib1g-dev, libmng-dev (>= 1.0.3), libpng12-0-dev, libfreetype6-dev, libiodbc2-dev, libmysqlclient-dev, flex, postgresql-dev, libaudio-dev, libcupsys2-dev, xlibmesa-gl-dev | libgl-dev, xlibmesa-glu-dev | libglu1-mesa-dev | libglu-dev , libxft-dev, dpatch (>= 1.13), libxrender-dev, libxcursor-dev, firebird2-dev [i386], libsqlite0-dev
+Build-Depends: debhelper (>= 4.1.26), xlibs-static-dev (>= 4.3.0.dfsg.1-4), libxext-dev (>= 4.3.0.dfsg.1-4), libxrandr-dev (>= 4.3.0.dfsg.1-4), x-dev (>= 4.3.0.dfsg.1-4), libsm-dev (>= 4.3.0.dfsg.1-4), libxmu-dev (>= 4.3.0.dfsg.1-4), libice-dev (>= 4.3.0.dfsg.1-4), libx11-dev (>= 4.3.0.dfsg.1-4), libxt-dev (>= 4.3.0.dfsg.1-4), libjpeg62-dev, zlib1g-dev, libmng-dev (>= 1.0.3), libpng12-0-dev, libfreetype6-dev, libiodbc2-dev, libmysqlclient-dev, flex, postgresql-dev, libaudio-dev, libcupsys2-dev, xlibmesa-gl-dev | libgl-dev, xlibmesa-glu-dev | libglu1-mesa-dev | libglu-dev , libxft-dev, dpatch (>= 1.13), libxrender-dev, libxcursor-dev, firebird2-dev [@firebird@], libsqlite0-dev, type-handling (>= 0.2.1)
 Section: libs
 Priority: optional
 Maintainer: Martin Loschwitz <madkiss@debian.org> 
@@ -109,7 +109,7 @@
  to access a PostgreSQL DB.
 
 Package: libqt3c102-ibase
-Architecture: i386
+Architecture: @firebird@
 Section: libs
 Depends: ${shlibs:Depends}
 Description: InterBase/FireBird database driver for Qt3
@@ -123,7 +123,7 @@
  version instead (Read README.Debian for instructions).
 
 Package: libqt3c102-mt-ibase
-Architecture: i386
+Architecture: @firebird@
 Section: libs
 Depends: ${shlibs:Depends}
 Description: InterBase/FireBird database driver for Qt3 (Threaded)
diff -ur qt-x11-free-3.3.2.old/debian/rules qt-x11-free-3.3.2/debian/rules
--- qt-x11-free-3.3.2.old/debian/rules	2004-08-08 18:15:22.000000000 +0200
+++ qt-x11-free-3.3.2/debian/rules	2004-08-12 01:30:41.000000000 +0200
@@ -148,6 +148,10 @@
 	for a in `find . -name 'Makefile'`; do rm -f "$$a"; done
 	-mv Makefile.save Makefile
 
+	cat debian/control.in \
+	| sed "s/@firebird@/`type-handling i386 any`/g" \
+	> debian/control
+
 	dh_clean
 
 install: build
