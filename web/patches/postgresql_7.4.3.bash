#!/bin/bash -e

# Status: in BTS

cp debian/control{,.in}
cat $0 | patch -p1
fakeroot debian/rules clean
exit 0

diff -x control -Nur postgresql-7.4.3.old/debian/control.in postgresql-7.4.3/debian/control.in
--- postgresql-7.4.3.old/debian/control.in	2004-07-29 19:19:20.000000000 +0200
+++ postgresql-7.4.3/debian/control.in	2004-07-29 17:11:13.000000000 +0200
@@ -4,13 +4,13 @@
 Maintainer: Oliver Elphick <Oliver.Elphick@lfix.co.uk>
 Uploaders: Martin Pitt <mpitt@debian.org>
 Standards-Version: 3.6.1
-Build-Depends: bison, perl (>= 5.8), libperl-dev, tk8.4-dev, flex, debhelper (>= 4.1.29), libreadline4-dev (>= 4.2), libssl-dev, zlib1g-dev | libz-dev, libpam0g-dev | libpam-dev, dbs, libxml2-dev, libltdl3-dev, libkrb5-dev, po-debconf, python-dev, gettext
+Build-Depends: bison, perl (>= 5.8), libperl-dev, tk8.4-dev, flex, debhelper (>= 4.1.29), libreadline4-dev (>= 4.2), libssl-dev, zlib1g-dev | libz-dev, libpam0g-dev | libpam-dev, dbs, libxml2-dev, libltdl3-dev, libkrb5-dev, po-debconf, python-dev, gettext, autotools-dev, autoconf
 
 Package: postgresql
 Architecture: any
 Section: misc
 Pre-Depends: adduser (>= 3.34) 
-Depends: ${shlibs:Depends}, ${misc:Depends}, procps, debianutils (>= 1.13.1), postgresql-client (>= 7.4), libpq3 (>= 7.4), mailx, ucf (>= 0.28)
+Depends: ${shlibs:Depends}, ${misc:Depends}@procps@, debianutils (>= 1.13.1), postgresql-client (>= 7.4), libpq3 (>= 7.4), mailx, ucf (>= 0.28)
 Conflicts: postgres95,libpq1, postgresql-pl, postgresql-test, postgresql-contrib (<< 7.2), ecpg (<< 7.2), libpgtcl (<< 7.3rel-5), libpgperl (<< 1:2.0.1-1)
 Replaces: postgresql-pl,libpgtcl (<< 7.3rel-5), libpgperl (<< 1:2.0.1-1)
 Suggests: libpg-perl,libpgjava,libpgtcl,postgresql-doc,postgresql-dev,postgresql-contrib,pidentd | ident-server,pgdocs,pgaccess
diff -x control -Nur postgresql-7.4.3.old/debian/patches/14kbsd-gnu postgresql-7.4.3/debian/patches/14kbsd-gnu
--- postgresql-7.4.3.old/debian/patches/14kbsd-gnu	1970-01-01 01:00:00.000000000 +0100
+++ postgresql-7.4.3/debian/patches/14kbsd-gnu	2004-07-29 17:10:34.000000000 +0200
@@ -0,0 +1,12 @@
+--- postgresql-7.4.3/configure.in~	2004-06-08 17:36:35.000000000 +0200
++++ postgresql-7.4.3/configure.in	2004-07-29 17:08:45.000000000 +0200
+@@ -64,7 +64,8 @@
+  freebsd*) template=freebsd ;;
+     hpux*) template=hpux ;;
+     irix*) template=irix5 ;;
+-   linux*) template=linux ;;
++   linux*|gnu*|k*bsd*-gnu)
++           template=linux ;;
+    mingw*) template=win32 ;;
+   netbsd*) template=netbsd ;;
+ nextstep*) template=nextstep ;;
diff -x control -Nur postgresql-7.4.3.old/debian/rules postgresql-7.4.3/debian/rules
--- postgresql-7.4.3.old/debian/rules	2004-07-29 19:18:45.000000000 +0200
+++ postgresql-7.4.3/debian/rules	2004-07-29 17:24:48.000000000 +0200
@@ -28,6 +28,11 @@
   include /usr/share/dbs/dpkg-arch.mk
 endif
 
+ifeq ($(DEB_BUILD_GNU_SYSTEM),linux)
+procps = , procps
+else
+procps =
+endif
 
 # These are used for cross-compiling and for saving the configure script
 # from having to guess our platform (since we know it already)
@@ -92,7 +97,8 @@
 	@echo debian/rules target $(BUILD_TREE)/config.status
 	dh_testdir
 
-	cd $(BUILD_TREE) && \
+	cp /usr/share/misc/config.* $(BUILD_TREE)/config/
+	cd $(BUILD_TREE) && autoconf2.50 && \
 	    echo /usr/include/ncurses /usr/include/readline | \
 	    	DOCBOOKSTYLE=/usr/share/sgml/docbook/stylesheet/dsssl/modular \
 		./configure --host=$(DEB_HOST_GNU_TYPE) \
@@ -353,6 +359,9 @@
 	# Commands to clean up after the build process.
 	rm -rf $(STAMP_DIR) $(SOURCE_DIR)
 
+	cat debian/control.in | sed "s/@procps@/$(procps)/g" \
+	> debian/control
+
 	dh_clean
 
 # Build architecture-independent files here.
