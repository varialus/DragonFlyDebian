#!/bin/bash -e

# Status: in BTS.

cp debian/control{,.in}
cat $0 | patch -p1
which type-handling
fakeroot debian/rules clean
exit 0

diff -ur xmbmon-2.04.old/debian/control.in xmbmon-2.04/debian/control.in
--- xmbmon-2.04.old/debian/control.in	2004-09-17 18:12:06.000000000 +0200
+++ xmbmon-2.04/debian/control.in	2004-09-17 18:09:04.000000000 +0200
@@ -2,11 +2,11 @@
 Section: admin
 Priority: optional
 Maintainer: Alberto Gonzalez Iniesta <agi@agi.as>
-Build-Depends: debhelper (>> 4.0.1), libxt-dev, libxaw7-dev
+Build-Depends: debhelper (>> 4.0.1), libxt-dev, libxaw7-dev, type-handling (>= 0.2.1)
 Standards-Version: 3.6.1
 
 Package: xmbmon
-Architecture: i386 hurd-i386 ia64 amd64
+Architecture: @arches@
 Suggests: mbmon
 Depends: ${shlibs:Depends}
 Enhances: rrdtool
@@ -17,7 +17,7 @@
  This package contains the graphical client.
 
 Package: mbmon
-Architecture: i386 hurd-i386 ia64 amd64
+Architecture: @arches@
 Depends: ${shlibs:Depends}
 Suggests: xmbmon
 Description: Hardware monitoring without kernel dependencies (text client)
diff -ur xmbmon-2.04.old/debian/rules xmbmon-2.04/debian/rules
--- xmbmon-2.04.old/debian/rules	2004-09-17 18:05:42.000000000 +0200
+++ xmbmon-2.04/debian/rules	2004-09-17 18:08:50.000000000 +0200
@@ -57,6 +57,11 @@
 	-test -r /usr/share/misc/config.guess && \
 	  cp -f /usr/share/misc/config.guess config.guess
 	rm -f config.log
+
+	cat debian/control.in \
+	| sed "s/@arches@/`type-handling i386,ia64,x86_64 linux-gnu,kfreebsd-gnu,gnu`/g" \
+	> debian/control
+
 	dh_clean
 
 install: build
