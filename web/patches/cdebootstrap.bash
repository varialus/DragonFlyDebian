#!/bin/bash
set -e

# Status: in BTS

cp config/sid/packages{,.in}
patch -p1 < $0
exit 0

diff -ur cdebootstrap-0.3.2.old/config/sid/packages.in cdebootstrap-0.3.2/config/sid/packages.in
--- cdebootstrap-0.3.2.old/config/sid/packages.in	2005-01-20 19:42:35.000000000 +0100
+++ cdebootstrap-0.3.2/config/sid/packages.in	2005-01-20 19:03:42.000000000 +0100
@@ -6,6 +6,10 @@
 Arch: any
 Packages: apt, apt-utils
 
+Section: base
+Arch: @kfreebsd-gnu@
+Packages: kfreebsd5, freebsd-utils
+
 Section: boot
 Arch: alpha
 Packages: aboot
@@ -15,8 +19,8 @@
 Packages: palo
 
 Section: boot
-Arch: i386
-Packages: lilo
+Arch: @i386@
+Packages: grub
 
 Section: boot
 Arch: ia64
@@ -60,11 +64,26 @@
 Packages:
  dhcp3-client
  ifupdown
+ tcpd
+ wget
+
+Section: network
+Arch: @linux-gnu@
+Packages:
  iptables
  iputils-ping
- tcpd
  telnet
- wget
+
+Section: network
+Arch: @not+linux-gnu@
+Packages:
+ inetutils-ping
+ inetutils-telnet
+
+Section: network
+Arch: @kfreebsd-gnu@
+Packages:
+ pf
 
 Section: network
 Arch: alpha arm i386 hppa ia64 m68k powerpc sparc mips mipsel
@@ -101,11 +120,20 @@
  nano
  nvi
  psmisc
- sysklogd
  tasksel
  whiptail
 
 Section: standard
+Arch: @linux-gnu@
+Packages:
+ sysklogd
+
+Section: standard
+Arch: @not+linux-gnu@
+Packages:
+ inetutils-syslogd
+
+Section: standard
 Arch: alpha arm i386 hppa ia64 m68k powerpc sparc mips mipsel
 Packages:
  console-tools
diff -ur cdebootstrap-0.3.2.old/debian/control cdebootstrap-0.3.2/debian/control
--- cdebootstrap-0.3.2.old/debian/control	2004-07-10 17:37:22.000000000 +0200
+++ cdebootstrap-0.3.2/debian/control	2005-01-20 09:58:33.000000000 +0100
@@ -2,7 +2,7 @@
 Section: admin
 Priority: optional
 Maintainer: Bastian Blank <waldi@debian.org>
-Build-Depends: debhelper (>= 4.2.0), libdebian-installer4-dev (>= 0.27), libdebconfclient0-dev (>= 0.40), po-debconf, autotools-dev
+Build-Depends: debhelper (>= 4.2.0), libdebian-installer4-dev (>= 0.27), libdebconfclient0-dev (>= 0.40), po-debconf, autotools-dev, libpmount-dev (>= 0.0.4), type-handling (>= 0.2.1)
 Standards-Version: 3.6.1
 
 Package: cdebootstrap
diff -ur cdebootstrap-0.3.2.old/debian/rules cdebootstrap-0.3.2/debian/rules
--- cdebootstrap-0.3.2.old/debian/rules	2005-01-14 09:59:56.000000000 +0100
+++ cdebootstrap-0.3.2/debian/rules	2005-01-20 19:03:28.000000000 +0100
@@ -80,6 +80,15 @@
 	cp -f /usr/share/misc/config.sub config.sub
 	cp -f /usr/share/misc/config.guess config.guess
 
+	for i in config/*/packages.in ; do \
+		sed \
+		-e "s/@linux-gnu@/`type-handling any linux-gnu`/g" \
+		-e "s/@not+linux-gnu@/`type-handling -n any linux-gnu`/g" \
+		-e "s/@kfreebsd-gnu@/`type-handling any kfreebsd-gnu`/g" \
+		-e "s/@i386@/`type-handling i386 any`/g" \
+		< $$i > `echo $$i | sed 's/\.in$$//g'` ; \
+	done
+
 	dh_clean
 
 install: build
diff -ur cdebootstrap-0.3.2.old/src/Makefile.am cdebootstrap-0.3.2/src/Makefile.am
--- cdebootstrap-0.3.2.old/src/Makefile.am	2005-01-11 11:33:34.000000000 +0100
+++ cdebootstrap-0.3.2/src/Makefile.am	2005-01-20 10:41:38.000000000 +0100
@@ -20,7 +20,7 @@
 
 cdebootstrap_LDADD = \
 	frontend/@FRONTEND@/libfrontend_@FRONTEND@.a @FRONTEND_LIBS@ \
-	-ldebian-installer-extra -ldebian-installer
+	-ldebian-installer-extra -ldebian-installer -lpmount
 
 cdebootstrap_DEPENDENCIES = \
 	frontend/@FRONTEND@/libfrontend_@FRONTEND@.a
diff -ur cdebootstrap-0.3.2.old/src/Makefile.in cdebootstrap-0.3.2/src/Makefile.in
--- cdebootstrap-0.3.2.old/src/Makefile.in	2005-01-16 11:56:18.000000000 +0100
+++ cdebootstrap-0.3.2/src/Makefile.in	2005-01-20 10:41:38.000000000 +0100
@@ -188,7 +188,7 @@
 
 cdebootstrap_LDADD = \
 	frontend/@FRONTEND@/libfrontend_@FRONTEND@.a @FRONTEND_LIBS@ \
-	-ldebian-installer-extra -ldebian-installer
+	-ldebian-installer-extra -ldebian-installer -lpmount
 
 cdebootstrap_DEPENDENCIES = \
 	frontend/@FRONTEND@/libfrontend_@FRONTEND@.a
diff -ur cdebootstrap-0.3.2.old/src/install.c cdebootstrap-0.3.2/src/install.c
--- cdebootstrap-0.3.2.old/src/install.c	2005-01-14 22:34:27.000000000 +0100
+++ cdebootstrap-0.3.2/src/install.c	2005-01-20 10:41:38.000000000 +0100
@@ -29,7 +29,7 @@
 #include <string.h>
 #include <sys/stat.h>
 #include <sys/types.h>
-#include <sys/mount.h>
+#include <pmount.h>
 #include <unistd.h>
 
 #include "download.h"
@@ -458,27 +458,39 @@
   return ret;
 }
 
+#if defined(__linux__)
+#define MNTDIR "/proc"
+#define FSTYPE "procfs_linux"
+#elif defined(__FreeBSD_kernel__)
+#define MNTDIR "/dev"
+#define FSTYPE "devfs"
+#endif
+
 int install_mount_proc (void)
 {
+#ifdef MNTDIR
   if (mount_status_proc (0) == umounted)
   {
     char buf[PATH_MAX];
-    snprintf (buf, PATH_MAX, "%s/proc", install_root);
-    if (mount ("proc", buf, "proc", 0, 0))
+    snprintf (buf, PATH_MAX, "%s" MNTDIR, install_root);
+    if (pmount (FSTYPE, buf, 0, NULL))
       return 1;
     mount_status_proc (mounted);
   }
+#endif
   return 0;
 }
 
 void install_umount (void)
 {
+#ifdef MNTDIR
   if (mount_status_proc (0) == mounted)
   {
     char buf[PATH_MAX];
-    snprintf (buf, PATH_MAX, "%s/proc", install_root);
-    umount (buf);
+    snprintf (buf, PATH_MAX, "%s" MNTDIR, install_root);
+    pumount (buf, 0);
   }
+#endif
 }
 
 int install_helper_execute (const char *command)
