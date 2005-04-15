#!/bin/bash
set -e

# Status: in BTS.

cp debian/control{,.in}
patch -p1 < $0
which type-handling
fakeroot debian/rules clean
exit


diff -u arts-1.3.2/debian/control.in arts-1.3.2/debian/control.in
--- arts-1.3.2/debian/control.in
+++ arts-1.3.2/debian/control.in
@@ -3,7 +3,7 @@
 Priority: optional
 Maintainer: Debian Qt/KDE Maintainers <debian-qt-kde@lists.debian.org>
 Uploaders: Christopher L Cheney <ccheney@debian.org>, Christopher Martin <chrsmrtn@freeshell.org>, Adeodato Simó <asp16@alu.ua.es>
-Build-Depends: debhelper (>> 4.2.0), docbook-to-man, gawk, gettext, libasound2-dev, libaudio-dev, libaudiofile-dev, libesd0-dev, libglib2.0-dev, libjack0.80.0-dev, libmad0-dev, libqt3-mt-dev, libvorbis-dev, sharutils, texinfo, xlibs-static-pic
+Build-Depends: debhelper (>> 4.2.0), docbook-to-man, gawk, gettext, libasound2-dev [alpha arm hppa i386 ia64 m68k mips mipsel powerpc s390 s390x sh3 sh3eb sh4 sh4eb sparc sparc64 amd64], libaudio-dev, libaudiofile-dev, libesd0-dev, libglib2.0-dev, libjack0.80.0-dev, libmad0-dev, libqt3-mt-dev, libvorbis-dev, sharutils, texinfo, xlibs-static-pic, libtool, type-handling (>= 0.2.1)
 Build-Conflicts: libmas-dev
 Standards-Version: 3.6.1
 
@@ -43,7 +43,7 @@
 Package: libarts1-dev
 Architecture: any
 Section: libdevel
-Depends: libarts1 (= ${Source-Version}), libartsc0-dev, libasound2-dev, libaudio-dev, libaudiofile-dev, libesd0-dev, libglib2.0-dev, libjack0.80.0-dev, libmad0-dev, libogg-dev, libqt3-mt-dev, libvorbis-dev
+Depends: libarts1 (= ${Source-Version}), libartsc0-dev, libaudio-dev, libaudiofile-dev, libesd0-dev, libglib2.0-dev, libjack0.80.0-dev, libmad0-dev, libogg-dev, libqt3-mt-dev, libvorbis-dev
 Conflicts: kdelibs3 (<< 4:3.0.0), libarts (<< 4:3.0.0), libarts-alsa (<< 4:3.0.0), libarts-dev (<< 4:3.0.0), libkmid (<< 4:3.0.0), libkmid-alsa (<< 4:3.0.0), libkmid-dev (<< 4:3.0.0)
 Replaces: kdelibs3 (<< 4:3.0.0), libarts (<< 4:3.0.0), libarts-alsa (<< 4:3.0.0), libarts-dev (<< 4:3.0.0), libkmid (<< 4:3.0.0), libkmid-alsa (<< 4:3.0.0), libkmid-dev (<< 4:3.0.0)
 Description: aRts Sound system (development files)
diff -u arts-1.3.2/debian/rules arts-1.3.2/debian/rules
--- arts-1.3.2/debian/rules
+++ arts-1.3.2/debian/rules
@@ -149,6 +149,17 @@
 		$(MAKE) -f admin/Makefile.common cvs-clean ;\
 	fi
 
+ifeq (linux,$(DEB_HOST_GNU_SYSTEM))
+	sed \
+		-e "s/@libasound2-dev@, /libasound2-dev, /g" \
+		-e "s/@linux-gnu@/`type-handling any linux-gnu`/g" \
+	< debian/control.in > debian/control
+else
+	sed \
+		-e "s/@libasound2-dev@, //g" \
+		-e "s/@linux-gnu@/`type-handling any linux-gnu`/g" \
+	< debian/control.in > debian/control
+endif		
 	dh_clean
 
 install: install-arch install-indep
