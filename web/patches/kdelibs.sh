#!/bin/sh
set -e

patch -p1 < $0
make -f admin/Makefile.common dist
exit

diff -u kdelibs-3.3.2/debian/rules kdelibs-3.3.2/debian/rules
--- kdelibs-3.3.2/debian/rules
+++ kdelibs-3.3.2/debian/rules
@@ -78,7 +78,8 @@
 	--with-distribution="$$version (`cat /etc/debian_version`)" \
 	--host=$(DEB_HOST_GNU_TYPE) --build=$(DEB_BUILD_GNU_TYPE) \
 	--enable-dnotify --enable-mitshm --with-alsa --with-ipv6-lookup=auto \
-	$(FAST_MALLOC)
+	$(FAST_MALLOC) \
+	--host=$(DEB_HOST_GNU_TYPE) --build=$(DEB_BUILD_GNU_TYPE)
 
 	touch configure-stamp

--- kdelibs-3.3.2.orig/kdecore/kpty.cpp
+++ kdelibs-3.3.2/kdecore/kpty.cpp
@@ -95,24 +95,24 @@
 # endif
 #endif
 
-#if defined (__FreeBSD__) || defined (__NetBSD__) || defined (__OpenBSD__) || defined (__bsdi__) || defined(__APPLE__)
+#if defined(HAVE_TCGETATTR)
+# define _tcgetattr(fd, ttmode) tcgetattr(fd, ttmode)
+#elif defined(TIOCGETA)
 # define _tcgetattr(fd, ttmode) ioctl(fd, TIOCGETA, (char *)ttmode)
+#elif defined(TCGETS)
+# define _tcgetattr(fd, ttmode) ioctl(fd, TCGETS, (char *)ttmode)
 #else
-# if defined(_HPUX_SOURCE) || defined(__Lynx__)
-#  define _tcgetattr(fd, ttmode) tcgetattr(fd, ttmode)
-# else
-#  define _tcgetattr(fd, ttmode) ioctl(fd, TCGETS, (char *)ttmode)
-# endif
+# error
 #endif
 
-#if defined (__FreeBSD__) || defined (__NetBSD__) || defined (__OpenBSD__) || defined (__bsdi__) || defined(__APPLE__)
+#if defined(HAVE_TCSETATTR) && defined(TCSANOW)
+# define _tcsetattr(fd, ttmode) tcsetattr(fd, TCSANOW, ttmode)
+#elif defined(TIOCSETA)
 # define _tcsetattr(fd, ttmode) ioctl(fd, TIOCSETA, (char *)ttmode)
+#elif defined(TCSETS)
+# define _tcsetattr(fd, ttmode) ioctl(fd, TCSETS, (char *)ttmode)
 #else
-# ifdef _HPUX_SOURCE
-#  define _tcsetattr(fd, ttmode) tcsetattr(fd, TCSANOW, ttmode)
-# else
-#  define _tcsetattr(fd, ttmode) ioctl(fd, TCSETS, (char *)ttmode)
-# endif
+# error
 #endif
 
 #if defined (_HPUX_SOURCE)
--- kdelibs-3.3.2.orig/admin/libtool.m4.in
+++ kdelibs-3.3.2/admin/libtool.m4.in
@@ -1273,7 +1273,7 @@
   dynamic_linker=no
   ;;
 
-freebsd*-gnu*)
+kfreebsd*-gnu*)
   version_type=linux
   need_lib_prefix=no
   need_version=no
@@ -2119,7 +2119,7 @@
   lt_cv_deplibs_check_method=pass_all
   ;;
 
-freebsd*)
+freebsd* | kfreebsd*-gnu)
   if echo __ELF__ | $CC -E - | grep __ELF__ > /dev/null; then
     case $host_cpu in
     i*86 )
@@ -2931,7 +2931,7 @@
   freebsd-elf*)
     _LT_AC_TAGVAR(archive_cmds_need_lc, $1)=no
     ;;
-  freebsd*)
+  freebsd* | kfreebsd*-gnu)
     # FreeBSD 3 and later use GNU C++ and GNU ld with standard ELF
     # conventions
     _LT_AC_TAGVAR(ld_shlibs, $1)=yes
@@ -4577,7 +4577,7 @@
 	    ;;
 	esac
 	;;
-      freebsd*)
+      freebsd* | kfreebsd*-gnu)
 	# FreeBSD uses GNU C++
 	;;
       hpux9* | hpux10* | hpux11*)
@@ -5376,7 +5376,7 @@
       ;;
 
     # FreeBSD 3 and greater uses gcc -shared to do shared libraries.
-    freebsd*)
+    freebsd* | kfreebsd*-gnu)
       _LT_AC_TAGVAR(archive_cmds, $1)='$CC -shared -o $lib $libobjs $deplibs $compiler_flags'
       _LT_AC_TAGVAR(hardcode_libdir_flag_spec, $1)='-R$libdir'
       _LT_AC_TAGVAR(hardcode_direct, $1)=yes
--- kdelibs-3.3.2.orig/kinit/kinit.cpp
+++ kdelibs-3.3.2/kinit/kinit.cpp
@@ -59,7 +59,7 @@
 #include <kapplication.h>
 #include <klocale.h>
 
-#ifdef Q_OS_LINUX
+#ifdef HAVE_SYS_PRCTL_H
 #include <sys/prctl.h>
 #ifndef PR_SET_NAME
 #define PR_SET_NAME 15
@@ -521,7 +521,7 @@
        d.argv[argc] = 0;
 
        /** Give the process a new name **/
-#ifdef Q_OS_LINUX
+#ifdef HAVE_SYS_PRCTL_H
        /* set the process name, so that killall works like intended */
        r = prctl(PR_SET_NAME, (unsigned long) name.data(), 0, 0, 0);
        if ( r == 0 )
--- kdelibs-3.3.2.orig/configure.in.in
+++ kdelibs-3.3.2/configure.in.in
@@ -46,7 +46,7 @@
 KDE_CHECK_STL
 AC_HEADER_DIRENT
 AC_HEADER_STDC
-AC_CHECK_HEADERS(sys/param.h sys/mman.h sys/time.h sysent.h strings.h sys/stat.h sys/select.h paths.h malloc.h limits.h sys/soundcard.h dlfcn.h termios.h)
+AC_CHECK_HEADERS(sys/param.h sys/mman.h sys/time.h sysent.h strings.h sys/stat.h sys/select.h paths.h malloc.h limits.h sys/soundcard.h dlfcn.h termios.h sys/prctl.h)
 
 DCOPIDL2CPP="compiled"
 DCOPIDL="compiled"
@@ -115,7 +115,7 @@
 AC_CHECK_RANDOM
 AC_CHECK_MKSTEMPS
 AC_CHECK_MKDTEMP
-AC_CHECK_FUNCS(strtoll socket seteuid setegid strfmon stpcpy gettimeofday)
+AC_CHECK_FUNCS(strtoll socket seteuid setegid strfmon stpcpy gettimeofday tcgetattr tcsetattr)
 
 AH_BOTTOM([
 /* provide a definition for a 32 bit entity, usable as a typedef, possibly
