#!/bin/bash -e

cp debian/control{,.in}
cat $0 | patch -p1
which type-handling
fakeroot debian/rules clean
exit 0

diff -ur gdm-2.6.0.3.old/debian/control.in gdm-2.6.0.3/debian/control.in
--- gdm-2.6.0.3.old/debian/control.in	2004-08-20 03:30:13.000000000 +0200
+++ gdm-2.6.0.3/debian/control.in	2004-08-20 03:32:50.000000000 +0200
@@ -2,7 +2,7 @@
 Section: gnome
 Priority: optional
 Maintainer: Ryan Murray <rmurray@debian.org>
-Build-Depends: libpam0g-dev, libgnomeui-dev (>= 1.96.0), librsvg2-dev, libglade2-dev, libwrap0-dev, debhelper, gettext, intltool, scrollkeeper, libselinux1-dev, libattr1-dev, xlibs-static-dev, libxt-dev
+Build-Depends: libpam0g-dev, libgnomeui-dev (>= 1.96.0), librsvg2-dev, libglade2-dev, libwrap0-dev, debhelper, gettext, intltool, scrollkeeper, libselinux1-dev [@selinux@], libattr1-dev [@attr@], xlibs-static-dev, libxt-dev, type-handling (>= 0.2.1)
 Standards-Version: 3.6.1
 
 Package: gdm
diff -ur gdm-2.6.0.3.old/debian/rules gdm-2.6.0.3/debian/rules
--- gdm-2.6.0.3.old/debian/rules	2004-08-20 03:28:51.000000000 +0200
+++ gdm-2.6.0.3/debian/rules	2004-08-20 03:35:42.000000000 +0200
@@ -8,10 +8,17 @@
 # This is the debhelper compatability version to use.
 export DH_COMPAT=4
 
+DEB_HOST_GNU_SYSTEM	?= $(shell dpkg-architecture -qDEB_HOST_GNU_SYSTEM)
+
+conf_args = --disable-dependency-tracking --with-tags= --prefix=/usr --libexecdir=\$${prefix}/lib --mandir=\$${prefix}/share/man --infodir=\$${prefix}/share/info --sysconfdir=/etc --localstatedir=/var/lib
+ifeq ($(DEB_HOST_GNU_SYSTEM),linux)
+conf_args += --with-selinux
+endif
+
 configure: configure-stamp
 configure-stamp:
 	dh_testdir
-	./configure --disable-dependency-tracking --with-tags= --prefix=/usr --libexecdir=\$${prefix}/lib --mandir=\$${prefix}/share/man --infodir=\$${prefix}/share/info --sysconfdir=/etc --localstatedir=/var/lib --with-selinux
+	./configure $(conf_args)
 
 	touch configure-stamp
 
@@ -30,6 +37,11 @@
 
 	-$(MAKE) distclean
 
+	cat debian/control.in \
+	| sed "s/@selinux@/`type-handling any linux-gnu`/g" \
+	| sed "s/@attr@/`type-handling any linux-gnu`/g" \
+	> debian/control
+
 	dh_clean debian/gdm.8 debian/gdmlogin.8 debian/gdmchooser.8 debian/gdmflexiserver.1 po/*.gmo po/.intltool-merge-cache config/gnome.desktop config/CDE.desktop config/default.desktop
 
 install: build
