#!/bin/bash -e

# Status: in BTS

cp debian/control{,.in}
cat $0 | patch -p1
which type-handling
fakeroot debian/rules clean
exit 0

diff -ur gdb-6.1/debian.old/control.in gdb-6.1/debian/control.in
--- gdb-6.1/debian.old/control.in	2004-08-07 03:44:52.000000000 +0200
+++ gdb-6.1/debian/control.in	2004-08-07 03:49:55.000000000 +0200
@@ -3,7 +3,7 @@
 Section: devel
 Priority: standard
 Standards-Version: 3.5.3
-Build-Depends: autoconf, libtool, texinfo (>= 4.6-1), tetex-bin, libncurses5-dev, libreadline4-dev (>= 4.2a-1), bison, gettext, debhelper (>= 4.1.46), dejagnu, gcj [i386 powerpc alpha ia64 s390], gobjc, mig [hurd-i386], cdbs (>= 0.4.17), quilt (>= 0.30-1)
+Build-Depends: autoconf, libtool, texinfo (>= 4.6-1), tetex-bin, libncurses5-dev, libreadline4-dev (>= 4.2a-1), bison, gettext, debhelper (>= 4.1.46), dejagnu, gcj [i386 powerpc alpha ia64 s390], gobjc, mig [hurd-i386], cdbs (>= 0.4.17), quilt (>= 0.30-1), libkvm-dev [@libkvm-dev@], type-handling (>= 0.2.1)
 
 Package: gdb
 Architecture: any
diff -ur gdb-6.1/debian.old/rules gdb-6.1/debian/rules
--- gdb-6.1/debian.old/rules	2004-08-07 03:33:07.000000000 +0200
+++ gdb-6.1/debian/rules	2004-08-07 03:49:44.000000000 +0200
@@ -81,6 +81,10 @@
 
 	rm -f check-stamp
 
+	cat debian/control.in \
+	| sed "s/@libkvm-dev@/`type-handling any kfreebsd-gnu`/g" \
+	> debian/control
+
 binary-post-install/gdb ::
 	if [ -x debian/gdb/usr/bin/run ]; then					\
 		mv debian/gdb/usr/bin/run					\
