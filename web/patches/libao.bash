#!/bin/bash -e

# Status: in BTS.

cp debian/control{,.in}
cat $0 | patch -p1
fakeroot debian/rules clean
exit 0

diff -ur libao-0.8.5.old/debian/control.in libao-0.8.5/debian/control.in
--- libao-0.8.5.old/debian/control.in	2004-09-19 17:28:59.000000000 +0200
+++ libao-0.8.5/debian/control.in	2004-09-19 17:30:11.000000000 +0200
@@ -2,7 +2,7 @@
 Section: libs
 Priority: optional
 Maintainer: Christopher L Cheney <ccheney@debian.org>
-Build-Depends: autotools-dev, debhelper (>> 4.0.18), devscripts, gawk, libartsc0-dev, libasound2-dev, libaudio-dev, libesd0-dev, libxt-dev, xlibs-static-dev
+Build-Depends: autotools-dev, debhelper (>> 4.0.18), devscripts, gawk, libartsc0-dev, libasound2-dev [@linux-gnu@], libaudio-dev, libesd0-dev, libxt-dev, xlibs-static-dev, type-handling (>= 0.2.1)
 Standards-Version: 3.6.1.0
 
 Package: libao2
diff -ur libao-0.8.5.old/debian/libao-dev.install libao-0.8.5/debian/libao-dev.install
--- libao-0.8.5.old/debian/libao-dev.install	2003-09-11 21:38:27.000000000 +0200
+++ libao-0.8.5/debian/libao-dev.install	2004-09-19 17:39:01.000000000 +0200
@@ -1,16 +1,8 @@
 debian/tmp/usr/include/ao/ao.h
 debian/tmp/usr/include/ao/os_types.h
 debian/tmp/usr/include/ao/plugin.h
-debian/tmp/usr/lib/ao/plugins-2/libalsa09.a
-debian/tmp/usr/lib/ao/plugins-2/libalsa09.la
-debian/tmp/usr/lib/ao/plugins-2/libarts.a
-debian/tmp/usr/lib/ao/plugins-2/libarts.la
-debian/tmp/usr/lib/ao/plugins-2/libesd.a
-debian/tmp/usr/lib/ao/plugins-2/libesd.la
-debian/tmp/usr/lib/ao/plugins-2/libnas.a
-debian/tmp/usr/lib/ao/plugins-2/libnas.la
-debian/tmp/usr/lib/ao/plugins-2/liboss.a
-debian/tmp/usr/lib/ao/plugins-2/liboss.la
+debian/tmp/usr/lib/ao/plugins-2/lib*.a
+debian/tmp/usr/lib/ao/plugins-2/lib*.la
 debian/tmp/usr/lib/libao.a
 debian/tmp/usr/lib/libao.la
 debian/tmp/usr/lib/libao.so
diff -ur libao-0.8.5.old/debian/libao2.install libao-0.8.5/debian/libao2.install
--- libao-0.8.5.old/debian/libao2.install	2003-09-03 06:26:37.000000000 +0200
+++ libao-0.8.5/debian/libao2.install	2004-09-19 17:38:30.000000000 +0200
@@ -1,7 +1,3 @@
 debian/libao.conf	etc/
-debian/tmp/usr/lib/ao/plugins-2/libalsa09.so
-debian/tmp/usr/lib/ao/plugins-2/libarts.so
-debian/tmp/usr/lib/ao/plugins-2/libesd.so
-debian/tmp/usr/lib/ao/plugins-2/libnas.so
-debian/tmp/usr/lib/ao/plugins-2/liboss.so
+debian/tmp/usr/lib/ao/plugins-2/lib*.so
 debian/tmp/usr/lib/libao.so.*
diff -ur libao-0.8.5.old/debian/rules libao-0.8.5/debian/rules
--- libao-0.8.5.old/debian/rules	2004-03-17 06:56:48.000000000 +0100
+++ libao-0.8.5/debian/rules	2004-09-19 17:32:12.000000000 +0200
@@ -89,6 +89,10 @@
 		$(MAKE) cvs-clean ;\
 	fi
 
+	cat debian/control.in \
+	| sed "s/@linux-gnu@/`type-handling any linux-gnu`/g" \
+	> debian/control
+
 	dh_clean
 
 install: install-indep install-arch
