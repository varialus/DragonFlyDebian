#!/bin/bash -e

# Status: in BTS.

cat $0 | patch -p1
which type-handling
fakeroot debian/rules clean
exit 0

diff -ur links2-2.1pre15.old/debian/control.in links2-2.1pre15/debian/control.in
--- links2-2.1pre15.old/debian/control.in	2004-10-14 23:38:06.000000000 +0200
+++ links2-2.1pre15/debian/control.in	2004-10-14 23:38:46.000000000 +0200
@@ -2,7 +2,7 @@
 Section: net
 Priority: optional
 Maintainer: Gürkan Sengün <gurkan@linuks.mine.nu>
-Build-Depends: debhelper (>= 4.0.0), libpng12-dev | libpng3-dev, libtiff4-dev, libjpeg62-dev, xlibs-dev, libgpmg1-dev
+Build-Depends: debhelper (>= 4.0.0), libpng12-dev | libpng3-dev, libtiff4-dev, libjpeg62-dev, xlibs-dev, libgpmg1-dev [@linux-gnu@], type-handling (>= 0.2.1)
 Standards-Version: 3.6.1.1
 
 Package: links2
diff -ur links2-2.1pre15.old/debian/rules links2-2.1pre15/debian/rules
--- links2-2.1pre15.old/debian/rules	2004-10-14 23:18:03.000000000 +0200
+++ links2-2.1pre15/debian/rules	2004-10-14 23:39:18.000000000 +0200
@@ -53,6 +53,9 @@
 	cp -f /usr/share/misc/config.guess config.guess
 endif
 
+	cat debian/control.in \
+	| sed "s/@linux-gnu@/`type-handling any linux-gnu`/g" \
+	> debian/control
 
 	dh_clean 
 
