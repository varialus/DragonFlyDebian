#!/bin/bash -e

# Status: in BTS + dirty

cat $0 | patch -p1
`which autoconf2.50 || which autoconf`
rm -rf autom4te.cache
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
