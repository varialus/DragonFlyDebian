#!/bin/bash -e

cp debian/control{,.in}
cat $0 | patch -p1
which type-handling
fakeroot debian/rules clean
exit 0

diff -ur quintuple-agent-1.0.4.old/debian/control quintuple-agent-1.0.4+kbsd/debian/control
--- quintuple-agent-1.0.4.old/debian/control	2003-03-10 20:31:09.000000000 +0100
+++ quintuple-agent-1.0.4+kbsd/debian/control	2004-08-17 14:27:23.000000000 +0200
@@ -3,7 +3,7 @@
 Priority: optional
 Maintainer: Robert Bihlmeyer <robbe@debian.org>
 Standards-Version: 3.5.8
-Build-Depends: debhelper (>= 2.0.0), libglib1.2-dev, libgtk1.2-dev, libcap2-dev [!hurd-i386]
+Build-Depends: debhelper (>= 2.0.0), libglib1.2-dev, libgtk1.2-dev, libcap2-dev [alpha arm hppa i386 ia64 m68k mips mipsel powerpc s390 s390x sh3 sh3eb sh4 sh4eb sparc sparc64 amd64], type-handling (>= 0.2.1), autotools-dev
 
 Package: quintuple-agent
 Architecture: any
diff -ur quintuple-agent-1.0.4.old/debian/control.in quintuple-agent-1.0.4+kbsd/debian/control.in
--- quintuple-agent-1.0.4.old/debian/control.in	2004-08-17 14:32:57.000000000 +0200
+++ quintuple-agent-1.0.4+kbsd/debian/control.in	2004-08-17 14:24:52.000000000 +0200
@@ -3,7 +3,7 @@
 Priority: optional
 Maintainer: Robert Bihlmeyer <robbe@debian.org>
 Standards-Version: 3.5.8
-Build-Depends: debhelper (>= 2.0.0), libglib1.2-dev, libgtk1.2-dev, libcap2-dev [!hurd-i386]
+Build-Depends: debhelper (>= 2.0.0), libglib1.2-dev, libgtk1.2-dev, libcap2-dev [@linux-gnu@], type-handling (>= 0.2.1), autotools-dev
 
 Package: quintuple-agent
 Architecture: any
diff -ur quintuple-agent-1.0.4.old/debian/rules quintuple-agent-1.0.4+kbsd/debian/rules
--- quintuple-agent-1.0.4.old/debian/rules	2003-03-10 20:20:34.000000000 +0100
+++ quintuple-agent-1.0.4+kbsd/debian/rules	2004-08-17 14:24:40.000000000 +0200
@@ -32,6 +32,11 @@
 	# Add here commands to clean up after the build process.
 	-$(MAKE) distclean
 
+	cat debian/control.in \
+	| sed "s/@linux-gnu@/`type-handling any linux-gnu`/g" \
+	> debian/control
+	cp /usr/share/misc/config.* ./
+
 	dh_clean
 
 install: build
