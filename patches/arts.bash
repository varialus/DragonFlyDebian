
Status: in BTS.

diff -ur arts-1.3.0.old/configure.in.in arts-1.3.0/configure.in.in
--- arts-1.3.0.old/configure.in.in	2004-08-04 19:30:30.000000000 +0200
+++ arts-1.3.0/configure.in.in	2004-09-19 10:10:10.000000000 +0200
@@ -65,7 +65,7 @@
 AC_BASE_PATH_KDE([don't test]) dnl arts is a special case
 AC_CHECK_LIB(compat, main, [LIBCOMPAT="-lcompat"]) dnl for FreeBSD
 AC_CHECK_LIB(util, main, [LIBUTIL="-lutil"]) dnl for FreeBSD
-AC_CHECK_FUNC(sem_init, , AC_CHECK_LIB(rt, sem_init, [LIBSEM="-lrt"]))
+AC_CHECK_FUNC(sem_init, , AC_CHECK_LIB(rt, sem_init, [LIBSEM="-lrt"]) AC_CHECK_LIB(sem, sem_init, [LIBSEM="-lsem"]))
 
 AM_CONDITIONAL(HAVE_LIBJPEG, test -n "$LIBJPEG" )
 AM_CONDITIONAL(HAVE_LIBPNG, test -n "$LIBPNG" )
diff -ur arts-1.3.0.old/debian/control.in arts-1.3.0/debian/control.in
--- arts-1.3.0.old/debian/control.in	2004-09-18 19:26:07.000000000 +0200
+++ arts-1.3.0/debian/control.in	2004-09-19 09:55:31.000000000 +0200
@@ -3,7 +3,7 @@
 Priority: optional
 Maintainer: Debian Qt/KDE Maintainers <debian-qt-kde@lists.debian.org>
 Uploaders: Christopher L Cheney <ccheney@debian.org>
-Build-Depends: automake1.9, debhelper (>> 4.2.0), docbook-to-man, gawk, gettext, libasound2-dev, libaudio-dev, libaudiofile-dev, libesd0-dev, libglib2.0-dev, libjack0.80.0-dev, libmad0-dev, libqt3-mt-dev (>> 3:3.3.2), libvorbis-dev, sharutils, texinfo, xlibs-static-pic
+Build-Depends: automake1.9, debhelper (>> 4.2.0), docbook-to-man, gawk, gettext, libasound2-dev [@linux-gnu@], libaudio-dev, libaudiofile-dev, libesd0-dev, libglib2.0-dev, libjack0.80.0-dev, libmad0-dev, libqt3-mt-dev (>> 3:3.3.2), libvorbis-dev, sharutils, texinfo, xlibs-static-pic, libtool, type-handling (>= 0.2.1)
 Build-Conflicts: libmas-dev
 Standards-Version: 3.6.1.0
 
@@ -42,7 +42,7 @@
 Package: libarts1-dev
 Architecture: any
 Section: libdevel
-Depends: libarts1 (= ${Source-Version}), libartsc0-dev, libasound2-dev, libaudio-dev, libaudiofile-dev, libesd0-dev, libglib2.0-dev, libjack0.80.0-dev, libmad0-dev, libogg-dev, libqt3-mt-dev, libvorbis-dev
+Depends: libarts1 (= ${Source-Version}), libartsc0-dev@libasound@, libaudio-dev, libaudiofile-dev, libesd0-dev, libglib2.0-dev, libjack0.80.0-dev, libmad0-dev, libogg-dev, libqt3-mt-dev, libvorbis-dev
 Conflicts: kdelibs3 (<< 4:3.0.0), libarts (<< 4:3.0.0), libarts-alsa (<< 4:3.0.0), libarts-dev (<< 4:3.0.0), libkmid (<< 4:3.0.0), libkmid-alsa (<< 4:3.0.0), libkmid-dev (<< 4:3.0.0)
 Replaces: kdelibs3 (<< 4:3.0.0), libarts (<< 4:3.0.0), libarts-alsa (<< 4:3.0.0), libarts-dev (<< 4:3.0.0), libkmid (<< 4:3.0.0), libkmid-alsa (<< 4:3.0.0), libkmid-dev (<< 4:3.0.0)
 Description: aRts Sound system (development files)
diff -ur arts-1.3.0.old/debian/rules arts-1.3.0/debian/rules
--- arts-1.3.0.old/debian/rules	2004-02-24 03:44:10.000000000 +0100
+++ arts-1.3.0/debian/rules	2004-09-18 19:23:16.000000000 +0200
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
diff -ur arts-1.3.0.old/mcop_mt/threads_posix.cc arts-1.3.0/mcop_mt/threads_posix.cc
--- arts-1.3.0.old/mcop_mt/threads_posix.cc	2004-03-19 18:50:40.000000000 +0100
+++ arts-1.3.0/mcop_mt/threads_posix.cc	2004-09-18 19:23:16.000000000 +0200
@@ -186,9 +186,12 @@
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
