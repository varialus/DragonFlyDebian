#!/bin/bash -e

# Status: in BTS

cp debian/control{,.in}
cat $0 | patch -p1
which type-handling || echo oops
fakeroot debian/rules clean
exit 0

diff -ur elinks-0.9.1.old/debian/control.in elinks-0.9.1/debian/control.in
--- elinks-0.9.1.old/debian/control.in	2004-07-30 20:04:01.000000000 +0200
+++ elinks-0.9.1/debian/control.in	2004-07-30 19:31:21.000000000 +0200
@@ -3,7 +3,7 @@
 Priority: optional
 Maintainer: Peter Gervai <grin@tolna.net>
 Standards-Version: 3.5.6.1
-Build-Depends: debhelper (>= 2.0.86), libgnutls10-dev, xlibs-dev, libgpmg1-dev [!hurd-i386], liblua50-dev, liblualib50-dev
+Build-Depends: debhelper (>= 2.0.86), libgnutls10-dev, xlibs-dev, libgpmg1-dev [@linux-gnu@], liblua50-dev, liblualib50-dev, type-handling (>= 0.2.1)
 
 Package: elinks
 Architecture: any
diff -ur elinks-0.9.1.old/debian/rules elinks-0.9.1/debian/rules
--- elinks-0.9.1.old/debian/rules	2004-07-30 19:29:47.000000000 +0200
+++ elinks-0.9.1/debian/rules	2004-07-30 19:48:52.000000000 +0200
@@ -34,6 +34,10 @@
 	# Add here commands to clean up after the build process.
 	-$(MAKE) distclean
 
+	cat debian/control.in \
+	| sed "s/@linux-gnu@/`type-handling any linux-gnu`/g" \
+	> debian/control
+
 	dh_clean -XChangelog.orig
 
 install: build
