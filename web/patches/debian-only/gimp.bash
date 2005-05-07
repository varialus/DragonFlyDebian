#!/bin/bash
set -e

patch -p1 < $0
which type-handling
fakeroot debian/rules clean
exit

diff -ur gimp-2.2.6.old/debian/control.in gimp-2.2.6/debian/control.in
--- gimp-2.2.6.old/debian/control.in	2005-05-06 01:32:20.000000000 +0200
+++ gimp-2.2.6/debian/control.in	2005-05-06 01:35:00.000000000 +0200
@@ -3,7 +3,7 @@
 Section: graphics
 Maintainer: Ari Pollak <ari@debian.org>
 Standards-Version: 3.6.1
-Build-Depends: debhelper (>= 4.2.21), gettext, intltool, aalib1-dev, libgtk2.0-dev (>= 2.4.4-1), libgtkhtml2-dev (>= 2.0.0), libgimpprint1-dev (>= 4.2.6), libjpeg62-dev, libmpeg-dev, libart-2.0-dev, libpng-dev, xlibs-dev, zlib1g-dev, slang1-dev, libtiff4-dev, python-dev, python-gtk2-dev, libexif-dev (>= 0.6.9), libmng-dev, librsvg2-dev (>= 2.7.2-2), libfontconfig1-dev (>= 2.2.0), libwmf-dev (>= 0.2.8-1.1), sharutils, sed (>= 3.95), libasound2-dev (>= 1.0.0)
+Build-Depends: debhelper (>= 4.2.21), gettext, intltool, aalib1-dev, libgtk2.0-dev (>= 2.4.4-1), libgtkhtml2-dev (>= 2.0.0), libgimpprint1-dev (>= 4.2.6), libjpeg62-dev, libmpeg-dev, libart-2.0-dev, libpng-dev, xlibs-dev, zlib1g-dev, slang1-dev, libtiff4-dev, python-dev, python-gtk2-dev, libexif-dev (>= 0.6.9), libmng-dev, librsvg2-dev (>= 2.7.2-2), libfontconfig1-dev (>= 2.2.0), libwmf-dev (>= 0.2.8-1.1), sharutils, sed (>= 3.95), libasound2-dev (>= 1.0.0) [@linux-gnu@], type-handling (>= 0.2.1)
 
 Package: libgimp2.0
 Architecture: any
diff -ur gimp-2.2.6.old/debian/rules gimp-2.2.6/debian/rules
--- gimp-2.2.6.old/debian/rules	2005-05-05 14:09:26.000000000 +0200
+++ gimp-2.2.6/debian/rules	2005-05-06 01:37:02.000000000 +0200
@@ -80,6 +80,8 @@
 ifneq "$(wildcard /usr/share/misc/config.guess)" ""
 	cp -f /usr/share/misc/config.guess config.guess
 endif
+	sed -e "s/@linux-gnu@/`type-handling any linux-gnu`/g" \
+	< debian/control.in > debian/control
 
 	dh_clean
 
