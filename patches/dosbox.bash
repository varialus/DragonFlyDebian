#!/bin/bash -e

cat $0 | patch -p1
which type-handling
fakeroot debian/rules clean
exit 0

diff -ur dosbox-0.61.old/debian/control.in dosbox-0.61/debian/control.in
--- dosbox-0.61.old/debian/control.in	2004-10-28 03:23:17.000000000 +0200
+++ dosbox-0.61/debian/control.in	2004-10-28 03:24:37.000000000 +0200
@@ -2,7 +2,7 @@
 Section: otherosfs
 Priority: optional
 Maintainer: Peter Veenstra <H.P.Veenstra@student.rug.nl>
-Build-Depends: debhelper (>> 4.0.0), libsdl1.2-dev , libpng12-dev, libsdl-net1.2-dev, libasound2-dev, alsa-headers, linux-kernel-headers 
+Build-Depends: debhelper (>> 4.0.0), libsdl1.2-dev , libpng12-dev, libsdl-net1.2-dev, libasound2-dev [@linux-gnu@], alsa-headers [@linux-gnu@], type-handling (>= 0.2.1)
 Standards-Version: 3.6.1
 
 Package: dosbox
diff -ur dosbox-0.61.old/debian/rules dosbox-0.61/debian/rules
--- dosbox-0.61.old/debian/rules	2004-10-28 03:22:03.000000000 +0200
+++ dosbox-0.61/debian/rules	2004-10-28 03:25:39.000000000 +0200
@@ -56,6 +56,9 @@
 	cp -f /usr/share/misc/config.guess config.guess
 endif
 
+	cat debian/control.in \
+	| sed "s/@linux-gnu@/`type-handling any linux-gnu`/g" \
+	> debian/control
 
 	dh_clean
 
