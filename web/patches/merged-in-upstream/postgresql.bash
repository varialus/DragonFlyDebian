diff -Nur postgresql-7.4.6.old/debian/control postgresql-7.4.6/debian/control
--- postgresql-7.4.6.old/debian/control	2005-01-20 09:35:30.000000000 +0100
+++ postgresql-7.4.6/debian/control	2005-01-20 10:07:21.000000000 +0100
@@ -4,7 +4,7 @@
 Maintainer: Oliver Elphick <Oliver.Elphick@lfix.co.uk>
 Uploaders: Martin Pitt <mpitt@debian.org>
 Standards-Version: 3.6.1
-Build-Depends: bison, perl (>= 5.8), libperl-dev, tk8.4-dev, flex, debhelper (>= 4.1.29), libreadline4-dev (>= 4.2), libssl-dev, zlib1g-dev | libz-dev, libpam0g-dev | libpam-dev, dbs, libxml2-dev, libltdl3-dev, libkrb5-dev, po-debconf, python-dev, gettext, mmv
+Build-Depends: bison, perl (>= 5.8), libperl-dev, tk8.4-dev, flex, debhelper (>= 4.1.29), libreadline4-dev (>= 4.2), libssl-dev, zlib1g-dev | libz-dev, libpam0g-dev | libpam-dev, dbs, libxml2-dev, libltdl3-dev, libkrb5-dev, po-debconf, python-dev, gettext, mmv, autotools-dev, autoconf
 
 Package: postgresql
 Architecture: any
diff -Nur postgresql-7.4.6.old/debian/patches/15kbsd-gnu postgresql-7.4.6/debian/patches/15kbsd-gnu
--- postgresql-7.4.6.old/debian/patches/15kbsd-gnu	1970-01-01 01:00:00.000000000 +0100
+++ postgresql-7.4.6/debian/patches/15kbsd-gnu	2005-01-20 10:26:58.000000000 +0100
@@ -0,0 +1,12 @@
+--- postgresql-7.4.6/configure.in~	2004-06-08 17:36:35.000000000 +0200
++++ postgresql-7.4.6/configure.in	2004-07-29 17:08:45.000000000 +0200
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
diff -Nur postgresql-7.4.6.old/debian/rules postgresql-7.4.6/debian/rules
--- postgresql-7.4.6.old/debian/rules	2005-01-20 09:35:30.000000000 +0100
+++ postgresql-7.4.6/debian/rules	2005-01-20 10:06:55.000000000 +0100
@@ -90,7 +90,8 @@
 	@echo debian/rules target $(BUILD_TREE)/config.status
 	dh_testdir
 
-	cd $(BUILD_TREE) && \
+	cp /usr/share/misc/config.* $(BUILD_TREE)/config/
+	cd $(BUILD_TREE) && `which autoconf2.50 || which autoconf` && \
 	    echo /usr/include/ncurses /usr/include/readline | \
 	    	DOCBOOKSTYLE=/usr/share/sgml/docbook/stylesheet/dsssl/modular \
 		./configure --host=$(DEB_HOST_GNU_TYPE) \
