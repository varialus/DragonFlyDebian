#!/bin/bash
set -e

# Status: in BTS and upstream BTS

cp debian/control{,.in}
mv debian/libgphoto2-2.files{,.in}
patch -p1 < $0
which type-handling
fakeroot debian/rules clean
exit

diff -ur libgphoto2-2.1.5.old/debian/control.in libgphoto2-2.1.5/debian/control.in
--- libgphoto2-2.1.5.old/debian/control.in	2005-03-02 18:46:40.000000000 +0100
+++ libgphoto2-2.1.5/debian/control.in	2005-03-03 12:54:27.000000000 +0100
@@ -2,7 +2,7 @@
 Section: libs
 Priority: optional
 Maintainer: Frederic Peters <fpeters@debian.org>
-Build-Depends: debhelper (>> 3.0.0), zlib1g-dev, libtool, libusb-dev (>= 1:0.1.5), libgpmg1-dev, pkg-config, libexif-dev (>= 0.5.9), libjpeg62-dev
+Build-Depends: debhelper (>> 3.0.0), zlib1g-dev, libtool, libusb-dev (>= 1:0.1.5), libgpmg1-dev [@linux-gnu@], pkg-config, libexif-dev (>= 0.5.9), libjpeg62-dev, type-handling (>= 0.2.1)
 Build-Conflicts: liblockdev1-dev
 Standards-Version: 3.6.1.0
 
diff -ur libgphoto2-2.1.5.old/debian/libgphoto2-2.files.in libgphoto2-2.1.5/debian/libgphoto2-2.files.in
--- libgphoto2-2.1.5.old/debian/libgphoto2-2.files.in	2005-03-03 13:08:23.000000000 +0100
+++ libgphoto2-2.1.5/debian/libgphoto2-2.files.in	2005-03-03 13:14:36.000000000 +0100
@@ -3,4 +3,4 @@
 usr/share/libgphoto2/2.1.5/konica/*
 usr/lib/libgphoto2.so.*
 usr/lib/gphoto2/2.1.5/libgphoto2_*.so
-usr/lib/libgphoto2/print-usb-usermap
+@linux-gnu@ usr/lib/libgphoto2/print-usb-usermap
diff -ur libgphoto2-2.1.5.old/debian/libgphoto2-2.postinst libgphoto2-2.1.5/debian/libgphoto2-2.postinst
--- libgphoto2-2.1.5.old/debian/libgphoto2-2.postinst	2005-03-02 18:14:20.000000000 +0100
+++ libgphoto2-2.1.5/debian/libgphoto2-2.postinst	2005-03-03 12:54:27.000000000 +0100
@@ -14,7 +14,9 @@
         fi
 
         # create USB usermap
-        /usr/lib/$PACKAGE-$MAJOR/print-usb-usermap $PACKAGE > /etc/hotplug/usb/$PACKAGE.usermap
+	for i in /lib/$PACKAGE-$MAJOR/print-usb-usermap ; do if test -e $i ; then
+	    $i $PACKAGE > /etc/hotplug/usb/$PACKAGE.usermap
+	fi ; done
         ;;
 
     abort-upgrade|abort-remove|abort-deconfigure)
diff -ur libgphoto2-2.1.5.old/debian/rules libgphoto2-2.1.5/debian/rules
--- libgphoto2-2.1.5.old/debian/rules	2005-03-02 18:14:20.000000000 +0100
+++ libgphoto2-2.1.5/debian/rules	2005-03-03 13:14:02.000000000 +0100
@@ -38,6 +38,11 @@
 	rm -f config.log config.status confdefs.h
 	rm -f libgphoto2_port/config.log libgphoto2_port/config.status
 	-rm -rf `pwd`/debian/tmp `pwd`/debian/libgphoto2 `pwd`/debian/libgphoto2-dev
+	rm -f debian/libgphoto2-2.files
+
+	sed -e "s/@linux-gnu@/`type-handling any linux-gnu`/g" \
+	< debian/control.in > debian/control
+
 	dh_clean
 
 install: build
@@ -46,6 +51,14 @@
 	dh_clean -k
 	dh_installdirs
 
+ifeq ($(DEB_HOST_GNU_SYSTEM), linux)
+	sed -e "s/^@linux-gnu@ *//g" \
+	< debian/libgphoto2-2.files.in > debian/libgphoto2-2.files
+else
+	grep -v "^@linux-gnu@" \
+	< debian/libgphoto2-2.files.in > debian/libgphoto2-2.files
+endif
+
 	export LIBRARY_PATH=`pwd`/debian/tmp/usr/lib; $(MAKE) install prefix=`pwd`/debian/tmp/usr
 
 	# remove upstream 0-byte files to make lintian happy
@@ -58,8 +71,9 @@
 
 	mv debian/libgphoto2-$(major)/usr/share/doc/libgphoto2 \
 		debian/libgphoto2-$(major)/usr/share/doc/libgphoto2-$(major)
-	mv debian/libgphoto2-$(major)/usr/lib/libgphoto2 \
-		debian/libgphoto2-$(major)/usr/lib/libgphoto2-$(major)
+	for i in debian/libgphoto2-$(major)/usr/lib/libgphoto2 ; do if test -e $$i ; then mv $$i \
+		debian/libgphoto2-$(major)/usr/lib/libgphoto2-$(major) ; \
+	fi ; done
 	mv debian/libgphoto2-port0/usr/share/doc/libgphoto2_port \
 		debian/libgphoto2-port0/usr/share/doc/libgphoto2-port0
 
diff -ur libgphoto2-2.1.5.old/libgphoto2_port/serial/unix.c libgphoto2-2.1.5/libgphoto2_port/serial/unix.c
--- libgphoto2-2.1.5.old/libgphoto2_port/serial/unix.c	2003-12-11 17:42:31.000000000 +0100
+++ libgphoto2-2.1.5/libgphoto2_port/serial/unix.c	2005-03-03 12:54:27.000000000 +0100
@@ -845,12 +845,10 @@
         tio.c_cflag = (tio.c_cflag & ~CSIZE) | CS8;
 
         /* Set into raw, no echo mode */
-#if defined(__FreeBSD__) || defined(__NetBSD__) || defined(__APPLE__)
         tio.c_iflag &= ~(IGNBRK | IGNCR | INLCR | ICRNL |
                          IXANY | IXON | IXOFF | INPCK | ISTRIP);
-#else
-        tio.c_iflag &= ~(IGNBRK | IGNCR | INLCR | ICRNL | IUCLC |
-                         IXANY | IXON | IXOFF | INPCK | ISTRIP);
+#ifdef IUCLC
+        tio.c_iflag &= ~IUCLC;
 #endif
         tio.c_iflag |= (BRKINT | IGNPAR);
         tio.c_oflag &= ~OPOST;
