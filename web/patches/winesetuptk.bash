#!/bin/bash -e

# Status: in BTS

cp debian/control{,.in}
cat $0 | patch -p1
which type-handling
fakeroot debian/rules clean
exit 0

diff -ur winesetuptk-0.7.old/debian/control.in winesetuptk-0.7/debian/control.in
--- winesetuptk-0.7.old/debian/control.in	2004-12-01 19:17:00.000000000 +0100
+++ winesetuptk-0.7/debian/control.in	2004-12-01 19:19:42.000000000 +0100
@@ -2,11 +2,11 @@
 Section: otherosfs
 Priority: optional
 Maintainer: Ove Kaaven <ovek@arcticnet.no>
-Build-Depends: debhelper, xlibs-dev
+Build-Depends: debhelper, xlibs-dev, type-handling (>= 0.2.1)
 Standards-Version: 3.1.1
 
 Package: winesetuptk
-Architecture: i386
+Architecture: @i386@
 Depends: ${shlibs:Depends}
 Provides: winesetup
 Description: Windows Emulator (Configuration and Setup Tool)
diff -ur winesetuptk-0.7.old/debian/rules winesetuptk-0.7/debian/rules
--- winesetuptk-0.7.old/debian/rules	2004-12-01 19:11:29.000000000 +0100
+++ winesetuptk-0.7/debian/rules	2004-12-01 19:19:26.000000000 +0100
@@ -47,6 +47,10 @@
 	./build.sh --distclean
 	-rm -rf tcltk-winesetuptk-0.7/local
 
+	sed \
+	    -e "s/@i386@/`type-handling i386 any`/g" \
+	< debian/control.in > debian/control
+
 	dh_clean
 
 install: build
