#!/bin/bash -e

cp debian/control{,.in}
cat $0 | patch -p1
which type-handling
fakeroot debian/rules clean
rm -f debian/patches/03_libtool_arm.diff
exit 0

diff -ur arts-1.2.3.old/debian/control.in arts-1.2.3/debian/control.in
--- arts-1.2.3.old/debian/control.in	2004-08-05 02:18:44.000000000 +0200
+++ arts-1.2.3/debian/control.in	2004-08-05 03:28:22.000000000 +0200
@@ -3,7 +3,7 @@
 Priority: optional
 Maintainer: Debian Qt/KDE Maintainers <debian-qt-kde@lists.debian.org>
 Uploaders: Christopher L Cheney <ccheney@debian.org>
-Build-Depends: automake1.8, debhelper (>> 4.2.0), docbook-to-man, gawk, gettext, libasound2-dev, libaudio-dev, libaudiofile-dev, libesd0-dev, libglib2.0-dev, libmad0-dev, libqt3-mt-dev, libvorbis-dev, sharutils, texinfo, xlibs-static-pic (>= 4.3.0-3)
+Build-Depends: automake1.8, debhelper (>> 4.2.0), docbook-to-man, gawk, gettext, libasound2-dev [@linux-gnu@], libaudio-dev, libaudiofile-dev, libesd0-dev, libglib2.0-dev, libmad0-dev, libqt3-mt-dev, libvorbis-dev, sharutils, texinfo, xlibs-static-pic (>= 4.3.0-3), type-handling (>= 0.2.1), libtool
 Build-Conflicts: libmas-dev
 Standards-Version: 3.6.1.0
 
@@ -42,7 +42,7 @@
 Package: libarts1-dev
 Architecture: any
 Section: libdevel
-Depends: libarts1 (= ${Source-Version}), libartsc0-dev, libasound2-dev, libaudio-dev, libaudiofile-dev, libesd0-dev, libglib2.0-dev, libmad0-dev, libogg-dev, libqt3-mt-dev, libvorbis-dev
+Depends: libarts1 (= ${Source-Version}), libartsc0-dev@libasound@, libaudio-dev, libaudiofile-dev, libesd0-dev, libglib2.0-dev, libmad0-dev, libogg-dev, libqt3-mt-dev, libvorbis-dev
 Conflicts: kdelibs3 (<< 4:3.0.0), libarts (<< 4:3.0.0), libarts-alsa (<< 4:3.0.0), libarts-dev (<< 4:3.0.0), libkmid (<< 4:3.0.0), libkmid-alsa (<< 4:3.0.0), libkmid-dev (<< 4:3.0.0)
 Replaces: kdelibs3 (<< 4:3.0.0), libarts (<< 4:3.0.0), libarts-alsa (<< 4:3.0.0), libarts-dev (<< 4:3.0.0), libkmid (<< 4:3.0.0), libkmid-alsa (<< 4:3.0.0), libkmid-dev (<< 4:3.0.0)
 Description: aRts Sound system (development files)
diff -ur arts-1.2.3.old/debian/rules arts-1.2.3/debian/rules
--- arts-1.2.3.old/debian/rules	2004-02-24 03:36:00.000000000 +0100
+++ arts-1.2.3/debian/rules	2004-08-05 03:28:22.000000000 +0200
@@ -16,6 +16,7 @@
 # from having to guess our platform (since we know it already)
 DEB_HOST_GNU_TYPE	?= $(shell dpkg-architecture -qDEB_HOST_GNU_TYPE)
 DEB_BUILD_GNU_TYPE	?= $(shell dpkg-architecture -qDEB_BUILD_GNU_TYPE)
+DEB_BUILD_GNU_SYSTEM	?= $(shell dpkg-architecture -qDEB_BUILD_GNU_SYSTEM)
 
 CFLAGS = -Wall -g
 
@@ -30,6 +31,10 @@
 
 objdir = $(CURDIR)/obj-$(DEB_BUILD_GNU_TYPE)
 
+ifeq ($(DEB_BUILD_GNU_SYSTEM),linux)
+libasound = , libasound2-dev
+endif
+
 -include debian/debiandirs
 
 debian/debiandirs: admin/debianrules
@@ -59,10 +64,9 @@
 		touch patch-stamp ;\
 	fi
 
-	# KDE CVS does not have aclocal.m4 or configure
-	if test ! -f configure; then \
-		$(MAKE) -f admin/Makefile.common ;\
-	fi
+	# update libtool
+	cp /usr/share/aclocal/libtool.m4 admin/libtool.m4.in
+	$(MAKE) -f admin/Makefile.common
 
 	# ensure configure is executable
 	chmod +x configure
@@ -148,6 +152,11 @@
 		$(MAKE) -f admin/Makefile.common cvs-clean ;\
 	fi
 
+	cat debian/control.in \
+	| sed "s/@linux-gnu@/`type-handling any linux-gnu`/g" \
+	| sed "s/@libasound@/$(libasound)/g" \
+	> debian/control
+
 	dh_clean
 
 install: install-arch install-indep
diff -ur arts-1.2.3.old/mcop/thread.cc arts-1.2.3/mcop/thread.cc
--- arts-1.2.3.old/mcop/thread.cc	2003-10-13 21:59:41.000000000 +0200
+++ arts-1.2.3/mcop/thread.cc	2004-08-05 03:28:22.000000000 +0200
@@ -20,6 +20,10 @@
 
     */
 
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
 #include "thread.h"
 #include <string.h>
 
@@ -56,11 +60,13 @@
 {
 }
 
+#ifdef HAVE_SEMAPHORE_H
 // Semaphore
 Semaphore::~Semaphore()
 {
 	delete impl;
 }
+#endif
 
 Semaphore_impl::~Semaphore_impl()
 {
diff -ur arts-1.2.3.old/mcop_mt/threads_posix.cc arts-1.2.3/mcop_mt/threads_posix.cc
--- arts-1.2.3.old/mcop_mt/threads_posix.cc	2004-03-22 12:29:28.000000000 +0100
+++ arts-1.2.3/mcop_mt/threads_posix.cc	2004-08-05 03:28:22.000000000 +0200
@@ -33,7 +33,9 @@
 #include <stddef.h>
 #include <stdarg.h>
 #include <pthread.h>
+#ifdef HAVE_SEMAPHORE_H
 #include <semaphore.h>
+#endif
 #include <debug.h>
 #include <string.h>
 
@@ -186,9 +188,12 @@
 	Thread_impl(Thread *thread) : thread(thread) {
 	}
 	void setPriority(int priority) {
+/* In GNU pth, pthread_setschedparam is not supported */
+#ifndef _POSIX_THREAD_IS_GNU_PTH
 		struct sched_param sp;
 		sp.sched_priority = priority;
 		if (pthread_setschedparam(pthread, SCHED_FIFO, &sp))
+#endif
 			arts_debug("Thread::setPriority: sched_setscheduler failed");
 	}
 	static pthread_key_t privateDataKey;
@@ -243,6 +248,7 @@
 	}
 };
 
+#ifdef HAVE_SEMAPHORE_H
 class Semaphore_impl : public Arts::Semaphore_impl
 {
 private:
@@ -275,6 +281,7 @@
 		return retval;
 	}
 };
+#endif /* HAVE_SEMAPHORE_H */
 
 class PosixThreads : public SystemThreads {
 private:
@@ -306,9 +313,11 @@
 		else
 			return 0; /* main thread */
 	}
+#ifdef HAVE_SEMAPHORE_H
 	Arts::Semaphore_impl *createSemaphore_impl(int shared, int count) {
 		return new Semaphore_impl(shared, count);
 	}
+#endif
 };
 
 // set posix threads on startup
