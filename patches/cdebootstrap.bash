#!/bin/bash
set -e

# Status: in BTS

cp config/sid/packages{,.in}
cat $0 | patch -p1
exit 0

diff -ur cdebootstrap-0.2.6/config/sid/packages.in cdebootstrap-0.2.6+kbsd/config/sid/packages.in
--- cdebootstrap-0.2.6/config/sid/packages.in	2004-12-14 07:36:47.000000000 +0100
+++ cdebootstrap-0.2.6+kbsd/config/sid/packages.in	2004-12-14 07:56:07.000000000 +0100
@@ -1,6 +1,10 @@
-Comment: $LastChangedBy: bastian $
-Comment: $LastChangedDate: 2004-06-13 11:22:51 +0200 (Sun, 13 Jun 2004) $
-Comment: $LastChangedRevision: 455 $
+# Comment: $LastChangedBy: bastian $
+# Comment: $LastChangedDate: 2004-06-13 11:22:51 +0200 (Sun, 13 Jun 2004) $
+# Comment: $LastChangedRevision: 455 $
+
+Section: base
+Arch: `type-handling any kfreebsd-gnu | sed "s/,/, /g"`
+Packages: kfreebsd5, freebsd-utils
 
 Section: base
 Arch: any
@@ -15,8 +19,8 @@
 Packages: palo
 
 Section: boot
-Arch: i386
-Packages: lilo
+Arch: `type-handling i386 any | sed "s/,/, /g"`
+Packages: grub
 
 Section: boot
 Arch: ia64
@@ -51,7 +55,7 @@
 Packages: info, manpages, man-db
 
 Section: linux-devfs
-Arch: any
+Arch: `type-handling any linux-gnu | sed "s/,/, /g"`
 Packages: devfsd
 
 Section: network
@@ -59,11 +63,26 @@
 Packages:
  dhcp3-client
  ifupdown
+ tcpd
+ wget
+
+Section: network
+Arch: `type-handling any linux-gnu | sed "s/,/, /g"`
+Packages:
  iptables
  iputils-ping
- tcpd
  telnet
- wget
+
+Section: network
+Arch: `type-handling -n any linux-gnu | sed "s/,/, /g"`
+Packages:
+ inetutils-ping
+ inetutils-telnet
+
+Section: network
+Arch: `type-handling any kfreebsd-gnu | sed "s/,/, /g"`
+Packages:
+ pf
 
 Section: network
 Arch: alpha arm i386 hppa ia64 m68k powerpc sparc mips mipsel
@@ -99,12 +118,21 @@
  ed
  nano
  nvi
- psmisc
- sysklogd
  tasksel
  whiptail
 
 Section: standard
+Arch: `type-handling any linux-gnu | sed "s/,/, /g"`
+Packages:
+ psmisc
+ sysklogd
+
+Section: standard
+Arch: `type-handling -n any linux-gnu | sed "s/,/, /g"`
+Packages:
+ inetutils-syslogd
+
+Section: standard
 Arch: alpha arm i386 hppa ia64 m68k powerpc sparc mips mipsel
 Packages:
  console-tools
diff -ur cdebootstrap-0.2.6/debian/control cdebootstrap-0.2.6+kbsd/debian/control
--- cdebootstrap-0.2.6/debian/control	2004-07-10 17:37:22.000000000 +0200
+++ cdebootstrap-0.2.6+kbsd/debian/control	2004-12-14 07:12:57.000000000 +0100
@@ -2,7 +2,7 @@
 Section: admin
 Priority: optional
 Maintainer: Bastian Blank <waldi@debian.org>
-Build-Depends: debhelper (>= 4.2.0), libdebian-installer4-dev (>= 0.27), libdebconfclient0-dev (>= 0.40), po-debconf, autotools-dev
+Build-Depends: debhelper (>= 4.2.0), libdebian-installer4-dev (>= 0.27), libdebconfclient0-dev (>= 0.40), po-debconf, autotools-dev, libpmount-dev (>= 0.0.4)
 Standards-Version: 3.6.1
 
 Package: cdebootstrap
diff -ur cdebootstrap-0.2.6/debian/rules cdebootstrap-0.2.6+kbsd/debian/rules
--- cdebootstrap-0.2.6/debian/rules	2004-07-10 17:37:22.000000000 +0200
+++ cdebootstrap-0.2.6+kbsd/debian/rules	2004-12-14 07:54:41.000000000 +0100
@@ -78,6 +78,11 @@
 	cp -f /usr/share/misc/config.sub config.sub
 	cp -f /usr/share/misc/config.guess config.guess
 
+	for i in config/*/packages.in ; do \
+		sed -e "s/^/echo /g" < $$i | $(SHELL) \
+		| tee `echo $$i | rev | cut -c 4- | rev` ; \
+	done
+
 	dh_clean
 
 install: build
diff -ur cdebootstrap-0.2.6/src/Makefile.am cdebootstrap-0.2.6+kbsd/src/Makefile.am
--- cdebootstrap-0.2.6/src/Makefile.am	2004-06-06 12:33:27.000000000 +0200
+++ cdebootstrap-0.2.6+kbsd/src/Makefile.am	2004-12-14 07:26:44.000000000 +0100
@@ -24,4 +24,4 @@
 	frontend/@FRONTEND@/libfrontend_@FRONTEND@.a
 
 cdebootstrap_LDFLAGS = \
-	-ldebian-installer-extra -ldebian-installer
+	-ldebian-installer-extra -ldebian-installer -lpmount
diff -ur cdebootstrap-0.2.6/src/Makefile.in cdebootstrap-0.2.6+kbsd/src/Makefile.in
--- cdebootstrap-0.2.6/src/Makefile.in	2004-07-10 17:46:34.000000000 +0200
+++ cdebootstrap-0.2.6+kbsd/src/Makefile.in	2004-12-14 07:27:12.000000000 +0100
@@ -191,7 +191,7 @@
 	frontend/@FRONTEND@/libfrontend_@FRONTEND@.a
 
 cdebootstrap_LDFLAGS = \
-	-ldebian-installer-extra -ldebian-installer
+	-ldebian-installer-extra -ldebian-installer -lpmount
 
 all: all-recursive
 
diff -ur cdebootstrap-0.2.6/src/install.c cdebootstrap-0.2.6+kbsd/src/install.c
--- cdebootstrap-0.2.6/src/install.c	2004-06-06 12:33:27.000000000 +0200
+++ cdebootstrap-0.2.6+kbsd/src/install.c	2004-12-15 16:40:34.000000000 +0100
@@ -37,7 +37,7 @@
 #include <string.h>
 #include <sys/stat.h>
 #include <sys/types.h>
-#include <sys/mount.h>
+#include <pmount.h>
 #include <unistd.h>
 
 char install_root[PATH_MAX];
@@ -533,26 +533,38 @@
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
 
diff -ur cdebootstrap-0.2.6/debian/control cdebootstrap-0.2.6+kbsd/debian/control
--- cdebootstrap-0.2.6/debian/control	2004-07-10 17:37:22.000000000 +0200
+++ cdebootstrap-0.2.6+kbsd/debian/control	2004-12-14 07:12:57.000000000 +0100
@@ -2,7 +2,7 @@
 Section: admin
 Priority: optional
 Maintainer: Bastian Blank <waldi@debian.org>
-Build-Depends: debhelper (>= 4.2.0), libdebian-installer4-dev (>= 0.27), libdebconfclient0-dev (>= 0.40), po-debconf, autotools-dev
+Build-Depends: debhelper (>= 4.2.0), libdebian-installer4-dev (>= 0.27), libdebconfclient0-dev (>= 0.40), po-debconf, autotools-dev, libpmount-dev (>= 0.0.4), type-handling (>= 0.2.1)
 Standards-Version: 3.6.1
 
 Package: cdebootstrap
diff -ur cdebootstrap-0.2.6/src/Makefile.am cdebootstrap-0.2.6+kbsd/src/Makefile.am
--- cdebootstrap-0.2.6/src/Makefile.am	2004-06-06 12:33:27.000000000 +0200
+++ cdebootstrap-0.2.6+kbsd/src/Makefile.am	2004-12-14 07:26:44.000000000 +0100
@@ -24,4 +24,4 @@
 	frontend/@FRONTEND@/libfrontend_@FRONTEND@.a
 
 cdebootstrap_LDFLAGS = \
-	-ldebian-installer-extra -ldebian-installer
+	-ldebian-installer-extra -ldebian-installer -lpmount
diff -ur cdebootstrap-0.2.6/src/Makefile.in cdebootstrap-0.2.6+kbsd/src/Makefile.in
--- cdebootstrap-0.2.6/src/Makefile.in	2004-07-10 17:46:34.000000000 +0200
+++ cdebootstrap-0.2.6+kbsd/src/Makefile.in	2004-12-14 07:27:12.000000000 +0100
@@ -191,7 +191,7 @@
 	frontend/@FRONTEND@/libfrontend_@FRONTEND@.a
 
 cdebootstrap_LDFLAGS = \
-	-ldebian-installer-extra -ldebian-installer
+	-ldebian-installer-extra -ldebian-installer -lpmount
 
 all: all-recursive
 
diff -ur cdebootstrap-0.2.6/src/install.c cdebootstrap-0.2.6+kbsd/src/install.c
--- cdebootstrap-0.2.6/src/install.c	2004-06-06 12:33:27.000000000 +0200
+++ cdebootstrap-0.2.6+kbsd/src/install.c	2004-12-15 16:40:34.000000000 +0100
@@ -37,7 +37,7 @@
 #include <string.h>
 #include <sys/stat.h>
 #include <sys/types.h>
-#include <sys/mount.h>
+#include <pmount.h>
 #include <unistd.h>
 
 char install_root[PATH_MAX];
@@ -533,26 +533,38 @@
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
 
