#!/bin/bash -e

# Status: in BTS

cp debian/control{,.in}
cat $0 | patch -p1
which type-handling
fakeroot debian/rules clean
exit 0

diff -ur xmms-1.2.10.old/debian/control.in xmms-1.2.10/debian/control.in
--- xmms-1.2.10.old/debian/control.in   2004-08-04 22:39:54.000000000 +0200
+++ xmms-1.2.10/debian/control.in       2004-08-04 22:30:17.000000000 +0200
@@ -2,7 +2,7 @@
 Section: sound
 Priority: optional
 Maintainer: Josip Rodin <joy-packages@debian.org>
-Build-Depends: debhelper (>= 2), xlibs-dev, libdb3-dev, libglib1.2-dev, libgtk1.2-dev, libaudiofile-dev, libesd0-dev, libmikmod2-dev, xlibmesa-gl-dev | libgl-dev, libxml-dev, libogg-dev, libvorbis-dev (>= 1.0.0-2), gettext, libasound2-dev
+Build-Depends: debhelper (>= 2), xlibs-dev, libdb3-dev, libglib1.2-dev, libgtk1.2-dev, libaudiofile-dev, libesd0-dev, libmikmod2-dev, xlibmesa-gl-dev | libgl-dev, libxml-dev, libogg-dev, libvorbis-dev (>= 1.0.0-2), gettext, libasound2-dev [@linux-gnu@], type-handling (>= 0.2.1)
 Standards-Version: 3.6.1

 Package: xmms
diff -ur xmms-1.2.10.old/debian/rules xmms-1.2.10/debian/rules
--- xmms-1.2.10.old/debian/rules        2004-08-04 22:39:14.000000000 +0200
+++ xmms-1.2.10/debian/rules    2004-08-04 22:30:59.000000000 +0200
@@ -34,6 +34,9 @@
        dh_testroot
        [ ! -f Makefile ] || $(MAKE) distclean
        dh_clean
+       cat debian/control.in \
+       | sed "s/@linux-gnu@/`type-handling any linux-gnu`/g" \
+       > debian/control

 install: build
        dh_testdir
