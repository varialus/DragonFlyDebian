#!/bin/bash -e

# Status: in BTS + dirty

cp debian/control{,.in}
cat $0 | patch -p1
`which autoconf2.50 || which autoconf`
rm -rf autom4te.cache
which type-handling
fakeroot debian/rules clean
exit 0

diff -ur control-center-2.6.1.old/configure.in control-center-2.6.1/configure.in
--- control-center-2.6.1.old/configure.in	2004-04-15 18:58:03.000000000 +0200
+++ control-center-2.6.1/configure.in	2004-09-21 11:59:00.000000000 +0200
@@ -120,14 +120,7 @@
 dnl Check for XRandR, needed for display capplet
 dnl		
 	
-have_randr=no
-AC_CHECK_LIB(Xrandr, XRRUpdateConfiguration,
-  [AC_CHECK_HEADER(X11/extensions/Xrandr.h,
-     have_randr=yes
-     RANDR_LIBS="-lXrandr -lXrender"
-     AC_DEFINE(HAVE_RANDR, 1, Have the Xrandr extension library),
-	  :, [#include <X11/Xlib.h>])], : ,
-       -lXrandr -lXrender $x_libs)
+have_randr=yes
 AM_CONDITIONAL(HAVE_RANDR, [test $have_randr = yes])
 	
 PKG_CHECK_MODULES(DISPLAY_CAPPLET, $COMMON_MODULES)
diff -ur control-center-2.6.1.old/debian/control.in control-center-2.6.1/debian/control.in
--- control-center-2.6.1.old/debian/control.in	2004-09-20 19:32:42.000000000 +0200
+++ control-center-2.6.1/debian/control.in	2004-09-21 11:59:25.000000000 +0200
@@ -4,7 +4,7 @@
 Maintainer: Arnaud Patard <arnaud.patard@rtp-net.org>
 Uploaders: Debian GNOME Maintainers <pkg-gnome-maintainers@lists.alioth.debian.org>, Akira TAGOH <tagoh@debian.org>, Andreas Rottmann <rotty@debian.org>, Andrew Lau <netsnipe@users.sourceforge.net>, Carlos Perelló Marín <carlos@pemas.net>, Edd Dumbill <ejad@debian.org>, Emil Soleyman-Zomalan <emil@nishra.com>, Gustavo Noronha Silva <kov@debian.org>, J.H.M. Dassen (Ray) <jdassen@debian.org>, Joe Drew <drew@debian.org>, Johannes Rohr <j.rohr@comlink.org>, Jordi Mallach <jordi@debian.org>, Jose Carlos Garcia Sogo <jsogo@debian.org>, Josselin Mouette <joss@debian.org>, Ondřej Surý <ondrej@debian.org>, Rob Bradford <rob@debianplanet.org>, Robert McQueen <robot101@debian.org>, Ross Burton <ross@debian.org>, Sebastien Bacher <seb128@debian.org>, Takuo KITAME <kitame@debian.org>, Marc 'HE' Brockschmidt <he@debian.org>
 Standards-Version: 3.6.1
-Build-Depends: cdbs, gnome-pkg-tools, debhelper (>= 4.0.2), libgnomeui-dev (>= 2.6.1.1-4), intltool, libglade2-dev (>= 2.4.0-1), libgnome-desktop-dev (>= 2.6.1-2), zlib1g-dev, flex,liborbit2-dev (>= 2.10.2-1.1), libmetacity-dev (>= 1:2.8.1-3), libxcursor-dev, libbonobo2-dev (>= 2.6.0-2), libnautilus2-dev (>=2.6.1-2), libgtk2.0-dev (>=2.4.1-3), libxklavier-dev (>=1.02), libxrandr-dev, xlibs-static-dev, docbook-to-man, libgstreamer-plugins0.8-dev, libasound2-dev (>= 1.0.3b-1)
+Build-Depends: cdbs, gnome-pkg-tools, debhelper (>= 4.1.0), libgnomeui-dev (>= 2.6.1.1-4), intltool, libglade2-dev (>= 2.4.0-1), libgnome-desktop-dev (>= 2.6.1-2), zlib1g-dev, flex,liborbit2-dev (>= 2.10.2-1.1), libmetacity-dev (>= 1:2.8.1-3), libxcursor-dev, libbonobo2-dev (>= 2.6.0-2), libnautilus2-dev (>=2.6.1-2), libgtk2.0-dev (>=2.4.1-3), libxklavier-dev (>=1.02), libxrandr-dev, xlibs-static-dev, docbook-to-man, libgstreamer-plugins0.8-dev, libasound2-dev (>= 1.0.3b-1) [@linux-gnu@], type-handling (>= 0.2.1)
 
 Package: capplets
 Architecture: any
diff -ur control-center-2.6.1.old/debian/rules control-center-2.6.1/debian/rules
--- control-center-2.6.1.old/debian/rules	2004-09-20 19:29:54.000000000 +0200
+++ control-center-2.6.1/debian/rules	2004-09-21 12:00:00.000000000 +0200
@@ -18,3 +18,8 @@
 
 binary-post-install/capplets:: 
 	dh_link -pcapplets usr/lib/control-center/gnome-settings-daemon usr/bin/gnome-settings-daemon
+
+clean::
+	cat debian/control.in \
+	| sed "s/@linux-gnu@/`type-handling any linux-gnu`/g" \
+	> debian/control
