#!/bin/bash
set -e

# Status: in BTS.  we still need to know what to do with SIGPWR (see bug log)

cp debian/sysctl.conf{,.linux}
mv debian/sysctl.conf{,.kfreebsd-gnu}
patch -p1 < $0
exit

diff -Nur procps-3.2.4.old/common.h procps-3.2.4/common.h
--- procps-3.2.4.old/common.h	1970-01-01 01:00:00.000000000 +0100
+++ procps-3.2.4/common.h	2005-01-15 18:19:10.000000000 +0100
@@ -0,0 +1,12 @@
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
diff -Nur procps-3.2.4.old/debian/control procps-3.2.4/debian/control
--- procps-3.2.4.old/debian/control	2005-01-15 17:34:24.000000000 +0100
+++ procps-3.2.4/debian/control	2005-01-16 07:32:02.000000000 +0100
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
diff -Nur procps-3.2.4.old/debian/procps.sh procps-3.2.4/debian/procps.sh
--- procps-3.2.4.old/debian/procps.sh	2005-01-15 17:34:24.000000000 +0100
+++ procps-3.2.4/debian/procps.sh	2005-01-15 18:51:58.000000000 +0100
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
diff -Nur procps-3.2.4.old/debian/rules procps-3.2.4/debian/rules
--- procps-3.2.4.old/debian/rules	2005-01-15 17:34:24.000000000 +0100
+++ procps-3.2.4/debian/rules	2005-01-16 07:01:43.000000000 +0100
@@ -10,6 +10,8 @@
 
 PACKAGE="procps"
 
+DEB_HOST_GNU_SYSTEM	?= $(shell dpkg-architecture -qDEB_HOST_GNU_SYSTEM)
+
 ifeq (,$(findstring nostrip,$(DEB_BUILD_OPTIONS)))
 	INSTALL_PROGRAM += -s
 endif
@@ -49,7 +51,7 @@
 
 	# Add here commands to install the package into debian/procps.
 	$(MAKE) lib64=lib ln_f="ln -sf" ldconfig=echo DESTDIR=$(CURDIR)/debian/procps install
-	install --mode 644 -o root -g root debian/sysctl.conf $(CURDIR)/debian/procps/etc
+	install --mode 644 -o root -g root debian/sysctl.conf.$(DEB_HOST_GNU_SYSTEM) $(CURDIR)/debian/procps/etc/sysctl.conf
 	# Rename w as there are two of them
 	(cd $(CURDIR)/debian/procps/usr/bin && mv w w.procps )
 	(cd $(CURDIR)/debian/procps/usr/share/man/man1 && mv w.1 w.procps.1 )
@@ -58,6 +60,15 @@
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
 
diff -Nur procps-3.2.4.old/debian/sysctl.conf.kfreebsd-gnu procps-3.2.4/debian/sysctl.conf.kfreebsd-gnu
--- procps-3.2.4.old/debian/sysctl.conf.kfreebsd-gnu	2005-01-16 07:39:33.000000000 +0100
+++ procps-3.2.4/debian/sysctl.conf.kfreebsd-gnu	2005-01-15 18:50:05.000000000 +0100
@@ -7,5 +7,3 @@
 # network options with builtin values.  These values may be overridden
 # using /etc/network/options.
 
-#kernel.domainname = example.com
-#net/ipv4/icmp_echo_ignore_broadcasts=1
diff -Nur procps-3.2.4.old/minimal.c procps-3.2.4/minimal.c
--- procps-3.2.4.old/minimal.c	2004-05-05 02:26:14.000000000 +0200
+++ procps-3.2.4/minimal.c	2005-01-15 18:20:31.000000000 +0100
@@ -57,7 +57,6 @@
 ///////////////////////////////////////////////////////
 #ifdef __linux__
 #include <asm/param.h>  /* HZ */
-#include <asm/page.h>   /* PAGE_SIZE */
 #define NO_TTY_VALUE DEV_ENCODE(0,0)
 #ifndef HZ
 #warning HZ not defined, assuming it is 100
@@ -67,11 +66,7 @@
 
 ///////////////////////////////////////////////////////////
 
-#ifndef PAGE_SIZE
-#warning PAGE_SIZE not defined, assuming it is 4096
-#define PAGE_SIZE 4096
-#endif
-
+#include "common.h"	/* PAGE_SIZE */
 
 
 static char P_tty_text[16];
diff -Nur procps-3.2.4.old/proc/sig.c procps-3.2.4/proc/sig.c
--- procps-3.2.4.old/proc/sig.c	2003-03-19 01:52:39.000000000 +0100
+++ procps-3.2.4/proc/sig.c	2005-01-15 17:48:07.000000000 +0100
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
diff -Nur procps-3.2.4.old/proc/sysinfo.c procps-3.2.4/proc/sysinfo.c
--- procps-3.2.4.old/proc/sysinfo.c	2004-10-01 06:37:18.000000000 +0200
+++ procps-3.2.4/proc/sysinfo.c	2005-01-15 18:43:25.000000000 +0100
@@ -201,11 +201,15 @@
   smp_num_cpus = sysconf(_SC_NPROCESSORS_ONLN);
   if(smp_num_cpus<1) smp_num_cpus=1; /* SPARC glibc is buggy */
 
+#ifdef __linux__
   if(linux_version_code > LINUX_VERSION(2, 4, 0)){ 
+#endif
     Hertz = find_elf_note(AT_CLKTCK);
     if(Hertz!=NOTE_NOT_FOUND) return;
+#ifdef __linux__
     fprintf(stderr, "2.4+ kernel w/o ELF notes? -- report this\n");
   }
+#endif
   old_Hertz_hack();
 }
 
diff -Nur procps-3.2.4.old/proc/version.c procps-3.2.4/proc/version.c
--- procps-3.2.4.old/proc/version.c	2003-01-29 02:11:43.000000000 +0100
+++ procps-3.2.4/proc/version.c	2005-01-15 18:40:25.000000000 +0100
@@ -29,7 +29,16 @@
  */
 #include <sys/utsname.h>
 
+#if defined(__FreeBSD__) || defined(__FreeBSD_kernel__)
+# include <sys/param.h>
+# ifdef __FreeBSD_kernel_version
+#  define LINUX_VERSION(x,y,z) __FreeBSD_kernel_version
+# else
+#  define LINUX_VERSION(x,y,z) __FreeBSD_version
+# endif
+#else
 #define LINUX_VERSION(x,y,z)   (0x10000*(x) + 0x100*(y) + z)
+#endif
 
 int linux_version_code;
 
@@ -40,10 +49,13 @@
     
     if (uname(&uts) == -1)	/* failure implies impending death */
 	exit(1);
+
+#if defined(__linux__)
     if (sscanf(uts.release, "%d.%d.%d", &x, &y, &z) < 3)
 	fprintf(stderr,		/* *very* unlikely to happen by accident */
 		"Non-standard uts for running kernel:\n"
 		"release %s=%d.%d.%d gives version code %d\n",
 		uts.release, x, y, z, LINUX_VERSION(x,y,z));
+#endif
     linux_version_code = LINUX_VERSION(x, y, z);
 }
diff -Nur procps-3.2.4.old/ps/common.h procps-3.2.4/ps/common.h
--- procps-3.2.4.old/ps/common.h	2004-10-09 05:55:50.000000000 +0200
+++ procps-3.2.4/ps/common.h	2005-01-15 18:19:37.000000000 +0100
@@ -14,7 +14,8 @@
 
 #include "../proc/procps.h"
 #include "../proc/readproc.h"
-#include <asm/page.h>  /* looks safe for glibc, we need PAGE_SIZE */
+
+#include "../common.h"			/* PAGE_SIZE */
 
 #if 0
 #define trace(args...) printf(## args)
diff -Nur procps-3.2.4.old/top.c procps-3.2.4/top.c
--- procps-3.2.4.old/top.c	2004-10-20 18:51:49.000000000 +0200
+++ procps-3.2.4/top.c	2005-01-15 18:10:40.000000000 +0100
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
