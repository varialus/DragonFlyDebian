#!/bin/bash -e

# Status: in BTS.

cp debian/control.in{,.in}
cat $0 | patch -p1
which type-handling
fakeroot debian/rules clean
exit 0

diff -ur gnome-applets-2.6.2.1.old/debian/control.in.in gnome-applets-2.6.2.1/debian/control.in.in
--- gnome-applets-2.6.2.1.old/debian/control.in.in	2004-09-22 00:43:19.000000000 +0200
+++ gnome-applets-2.6.2.1/debian/control.in.in	2004-09-22 00:40:50.000000000 +0200
@@ -2,9 +2,9 @@
 Section: gnome
 Priority: optional
 Maintainer: Marc Dequènes (Duck) <Duck@DuckCorp.org>
-Uploaders: Debian GNOME Maintainers <pkg-gnome-maintainers@lists.alioth.debian.org>, Akira TAGOH <tagoh@debian.org>, Andreas Rottmann <rotty@debian.org>, Andrew Lau <netsnipe@users.sourceforge.net>, Carlos Perelló Marín <carlos@pemas.net>, Edd Dumbill <ejad@debian.org>, Emil Soleyman-Zomalan <emil@nishra.com>, Gustavo Noronha Silva <kov@debian.org>, J.H.M. Dassen (Ray) <jdassen@debian.org>, Joe Drew <drew@debian.org>, Johannes Rohr <j.rohr@comlink.org>, Jordi Mallach <jordi@debian.org>, Jose Carlos Garcia Sogo <jsogo@debian.org>, Josselin Mouette <joss@debian.org>, Marc 'HE' Brockschmidt <he@debian.org>, Ondřej Surý <ondrej@debian.org>, Rob Bradford <rob@debianplanet.org>, Robert McQueen <robot101@debian.org>, Ross Burton <ross@debian.org>, Sebastien Bacher <seb128@debian.org>, Takuo KITAME <kitame@debian.org>
+Uploaders: @GNOME_TEAM@
 Standards-Version: 3.6.1
-Build-Depends: debhelper (>= 4.1.87), libgtop2-dev (>= 2.6.0-4), intltool, libpanel-applet2-dev (>= 2.6.2-2), liborbit2-dev (>= 2.10.2-1.1), scrollkeeper (>= 0.3.14-8), libgail-dev (>= 1.4.1), libwnck-dev (>= 2.6.2), libgconf2-dev (>= 2.6.3), libglade2-dev (>= 1:2.4.0), libapm-dev, libgnomeui-dev (>= 2.6.1.1-4), libgnome-keyring-dev (>= 0.2.1-2) , libxklavier-dev (>= 1.03), gnome-pkg-tools, cdbs, xsltproc, docbook-xsl, xlibs-static-dev, sharutils, libgstreamer-plugins0.8-dev (>= 0.8.2-3), autotools-dev
+Build-Depends: debhelper (>= 4.1.87), libgtop2-dev (>= 2.6.0-4), intltool, libpanel-applet2-dev (>= 2.6.2-2), liborbit2-dev (>= 2.10.2-1.1), scrollkeeper (>= 0.3.14-8), libgail-dev (>= 1.4.1), libwnck-dev (>= 2.6.2), libgconf2-dev (>= 2.6.3), libglade2-dev (>= 1:2.4.0), libapm-dev [@linux-gnu@], libgnomeui-dev (>= 2.6.1.1-4), libgnome-keyring-dev (>= 0.2.1-2) , libxklavier-dev (>= 1.03), gnome-pkg-tools, cdbs, xsltproc, docbook-xsl, xlibs-static-dev, sharutils, libgstreamer-plugins0.8-dev (>= 0.8.2-3), autotools-dev, type-handling (>= 0.2.1)
 
 Package: gnome-applets-data
 Architecture: all
diff -ur gnome-applets-2.6.2.1.old/debian/rules gnome-applets-2.6.2.1/debian/rules
--- gnome-applets-2.6.2.1.old/debian/rules	2004-09-21 23:57:55.000000000 +0200
+++ gnome-applets-2.6.2.1/debian/rules	2004-09-22 00:41:02.000000000 +0200
@@ -46,3 +46,6 @@
 	rm -f Makefile gkb-new/gkb_xmmap mailcheck/mailcheck.soundlist screen-exec/egg-screen-exec.loT
 	rm -f $(MANPAGES)
 
+	cat debian/control.in.in \
+	| sed "s/@linux-gnu@/`type-handling any linux-gnu`/g" \
+	> debian/control.in
