#!/bin/bash
set -e

# In BTS, plus some dirty hacks that upstream rejected

cp debian/sysctl.conf{,.linux}
mv debian/sysctl.conf{,.generic}
patch -p1 < $0
exit

diff -ur procps-3.2.4.old/debian/control procps-3.2.4/debian/control
--- procps-3.2.4.old/debian/control	2005-01-28 00:35:14.000000000 +0100
+++ procps-3.2.4/debian/control	2005-01-28 00:35:42.000000000 +0100
@@ -9,8 +9,8 @@
 Architecture: any
 Provides: watch
 Depends: ${shlibs:Depends}
-Conflicts: watch, libproc-dev (<< 1:1.2.6-2), w-bassman (<< 1.0-3), procps-nonfree, pgrep (<< 3.3-5)
-Replaces: watch, bsdutils (<< 2.9x-1)
+Conflicts: watch, libproc-dev (<< 1:1.2.6-2), w-bassman (<< 1.0-3), procps-nonfree, pgrep (<< 3.3-5), hurd, freebsd-utils (<< 5.2.1-11)
+Replaces: watch, bsdutils (<< 2.9x-1), freebsd-utils (<< 5.2.1-11)
 Recommends: psmisc
 Description: The /proc file system utilities
  These are utilities to browse the /proc filesystem, which is not a real file
diff -ur procps-3.2.4.old/debian/procps.sh procps-3.2.4/debian/procps.sh
--- procps-3.2.4.old/debian/procps.sh	2005-01-28 00:35:14.000000000 +0100
+++ procps-3.2.4/debian/procps.sh	2005-01-28 00:35:42.000000000 +0100
@@ -8,7 +8,8 @@
 [ -r /etc/default/rcS ] || exit 0
 . /etc/default/rcS
 
-[ -x /sbin/sysctl ] || exit 0
+PATH=/sbin:$PATH
+which sysctl > /dev/null || exit 0
 
 
 case "$1" in
@@ -26,7 +27,7 @@
                        n=""
                        redir=""
                fi
-               eval "/sbin/sysctl $n -q -p $redir"
+               eval "sysctl $n -q -p $redir"
                if [ "$VERBOSE" = "yes" ]
                then
 			echo "... done."
diff -ur procps-3.2.4.old/debian/rules procps-3.2.4/debian/rules
--- procps-3.2.4.old/debian/rules	2005-01-28 00:35:14.000000000 +0100
+++ procps-3.2.4/debian/rules	2005-01-28 00:35:42.000000000 +0100
@@ -10,6 +10,13 @@
 
 PACKAGE="procps"
 
+DEB_HOST_GNU_SYSTEM	?= $(shell dpkg-architecture -qDEB_HOST_GNU_SYSTEM)
+
+ifeq ($(DEB_HOST_GNU_SYSTEM), linux)
+sysctl_conf	= linux
+endif
+sysctl_conf	?= generic
+
 ifeq (,$(findstring nostrip,$(DEB_BUILD_OPTIONS)))
 	INSTALL_PROGRAM += -s
 endif
@@ -49,7 +56,7 @@
 
 	# Add here commands to install the package into debian/procps.
 	$(MAKE) lib64=lib ln_f="ln -sf" ldconfig=echo DESTDIR=$(CURDIR)/debian/procps install
-	install --mode 644 -o root -g root debian/sysctl.conf $(CURDIR)/debian/procps/etc
+	install --mode 644 -o root -g root debian/sysctl.conf.$(sysctl_conf) $(CURDIR)/debian/procps/etc/sysctl.conf
 	# Rename w as there are two of them
 	(cd $(CURDIR)/debian/procps/usr/bin && mv w w.procps )
 	(cd $(CURDIR)/debian/procps/usr/share/man/man1 && mv w.1 w.procps.1 )
@@ -58,6 +65,15 @@
 	(cp proc/*.h $(CURDIR)/debian/procps/usr/include/proc)
 	cp static/libproc.a $(CURDIR)/debian/libproc-dev/usr/lib
 
+ifneq ($(DEB_HOST_GNU_SYSTEM), linux)
+	rm -f \
+		$(CURDIR)/debian/procps/bin/kill \
+		$(CURDIR)/debian/procps/usr/share/man/man1/kill.1 \
+		$(CURDIR)/debian/procps/sbin/sysctl \
+		$(CURDIR)/debian/procps/usr/share/man/man8/sysctl.8 \
+		$(NULL)
+endif
+
 	dh_movefiles --sourcedir=debian/procps
 	rmdir $(CURDIR)/debian/procps/usr/include/proc
 
diff -ur procps-3.2.4.old/debian/sysctl.conf.generic procps-3.2.4/debian/sysctl.conf.generic
--- procps-3.2.4.old/debian/sysctl.conf.generic	2005-01-28 00:35:14.000000000 +0100
+++ procps-3.2.4/debian/sysctl.conf.generic	2005-01-28 00:35:42.000000000 +0100
@@ -7,5 +7,3 @@
 # network options with builtin values.  These values may be overridden
 # using /etc/network/options.
 
-#kernel.domainname = example.com
-#net/ipv4/icmp_echo_ignore_broadcasts=1
diff -ur procps-3.2.4.old/proc/sig.c procps-3.2.4/proc/sig.c
--- procps-3.2.4.old/proc/sig.c	2003-03-19 01:52:39.000000000 +0100
+++ procps-3.2.4/proc/sig.c	2005-01-28 00:35:39.000000000 +0100
@@ -50,6 +50,10 @@
 #  define SIGPWR 29
 #endif
 
+#ifndef SIGPOLL
+#define SIGPOLL SIGIO
+#endif
+
 typedef struct mapstruct {
   const char *name;
   int num;
diff -ur procps-3.2.4.old/ps/common.h procps-3.2.4/ps/common.h
--- procps-3.2.4.old/ps/common.h	2004-10-09 05:55:50.000000000 +0200
+++ procps-3.2.4/ps/common.h	2005-01-28 00:41:32.000000000 +0100
@@ -14,7 +14,18 @@
 
 #include "../proc/procps.h"
 #include "../proc/readproc.h"
-#include <asm/page.h>  /* looks safe for glibc, we need PAGE_SIZE */
+
+#ifndef PAGE_SIZE
+#if defined(__linux__)
+#include <asm/page.h>  /* looks safe for glibc */
+#elif defined(__FreeBSD__) || defined(__FreeBSD_kernel__)
+#include <machine/param.h>
+#elif defined(_SC_PAGE_SIZE)
+#define PAGE_SIZE sysconf (_SC_PAGE_SIZE)
+#else
+#error
+#endif
+#endif
 
 #if 0
 #define trace(args...) printf(## args)
diff -ur procps-3.2.4.old/top.c procps-3.2.4/top.c
--- procps-3.2.4.old/top.c	2004-10-20 18:51:49.000000000 +0200
+++ procps-3.2.4/top.c	2005-01-28 00:35:39.000000000 +0100
@@ -1819,6 +1819,9 @@
       std_err("failed tty get");
    newtty = Savedtty;
    newtty.c_lflag &= ~(ICANON | ECHO);
+#ifndef TAB3
+#define TAB3 XTABS
+#endif
    newtty.c_oflag &= ~(TAB3);
    newtty.c_cc[VMIN] = 1;
    newtty.c_cc[VTIME] = 0;
diff -ur procps-3.2.4.old/minimal.c procps-3.2.4/minimal.c
--- procps-3.2.4.old/minimal.c	2004-05-05 02:26:14.000000000 +0200
+++ procps-3.2.4/minimal.c	2005-01-28 00:39:14.000000000 +0100
@@ -57,7 +57,6 @@
 ///////////////////////////////////////////////////////
 #ifdef __linux__
 #include <asm/param.h>  /* HZ */
-#include <asm/page.h>   /* PAGE_SIZE */
 #define NO_TTY_VALUE DEV_ENCODE(0,0)
 #ifndef HZ
 #warning HZ not defined, assuming it is 100
@@ -68,8 +67,15 @@
 ///////////////////////////////////////////////////////////
 
 #ifndef PAGE_SIZE
-#warning PAGE_SIZE not defined, assuming it is 4096
-#define PAGE_SIZE 4096
+#if defined(__linux__)
+#include <asm/page.h>  /* looks safe for glibc */
+#elif defined(__FreeBSD__) || defined(__FreeBSD_kernel__)
+#include <machine/param.h>
+#elif defined(_SC_PAGE_SIZE)
+#define PAGE_SIZE sysconf (_SC_PAGE_SIZE)
+#else
+#error
+#endif
 #endif
 
 
diff -ur procps-3.2.4.old/proc/version.c procps-3.2.4/proc/version.c
--- procps-3.2.4.old/proc/version.c	2003-01-29 02:11:43.000000000 +0100
+++ procps-3.2.4/proc/version.c	2005-01-28 00:40:16.000000000 +0100
@@ -35,6 +35,9 @@
 
 static void init_Linux_version(void) __attribute__((constructor));
 static void init_Linux_version(void) {
+#ifndef __linux__
+    int x = 2, y = 0, z = 0;
+#else
     static struct utsname uts;
     int x = 0, y = 0, z = 0;	/* cleared in case sscanf() < 3 */
     
@@ -45,5 +48,6 @@
 		"Non-standard uts for running kernel:\n"
 		"release %s=%d.%d.%d gives version code %d\n",
 		uts.release, x, y, z, LINUX_VERSION(x,y,z));
+#endif
     linux_version_code = LINUX_VERSION(x, y, z);
 }
--- procps-3.2.4/debian/examples~	2005-01-28 00:51:28.000000000 +0100
+++ procps-3.2.4/debian/examples	2005-01-28 00:51:30.000000000 +0100
@@ -1,2 +1,2 @@
-debian/sysctl.conf
+debian/sysctl.conf*
 
