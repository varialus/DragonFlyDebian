
# Status: in BTS

#!/bin/bash -e

cp debian/control{,.in}
cat $0 | patch -p1
exit 0

diff -ur db4.1-4.1.25.old/debian/control.in db4.1-4.1.25/debian/control.in
--- db4.1-4.1.25.old/debian/control.in	2004-07-26 16:52:16.000000000 +0200
+++ db4.1-4.1.25/debian/control.in	2004-07-26 17:08:43.000000000 +0200
@@ -4,7 +4,7 @@
 Maintainer: Debian Berkeley DB Maintainers <pkg-db-devel@lists.alioth.debian.org>
 Uploaders: Clint Adams <schizo@debian.org>, Matthew Wilcox <willy@debian.org>
 Standards-Version: 3.6.1
-Build-Depends: tcl8.4-dev, procps [!hurd-i386], gcj (>= 3:3.2.2-0) [!hppa !mips !mipsel !hurd-i386], libgcj4-dev [!hppa !mips !mipsel !hurd-i386], fastjar [!hppa !mips !mipsel !hurd-i386], sablevm [!hppa !mips !mipsel !hurd-i386]
+Build-Depends: tcl8.4-dev, procps [@linux-gnu@], gcj (>= 3:3.2.2-0) [@java_no_archs@], libgcj4-dev [@java_no_archs@], fastjar [@java_no_archs@], sablevm [@java_no_archs@], type-handling (>= 0.2.0)
 
 Package: db4.1-doc
 Architecture: all
diff -ur db4.1-4.1.25.old/debian/rules db4.1-4.1.25/debian/rules
--- db4.1-4.1.25.old/debian/rules	2004-07-26 17:21:50.000000000 +0200
+++ db4.1-4.1.25/debian/rules	2004-07-26 17:22:35.000000000 +0200
@@ -18,9 +18,39 @@
 
 DEB_BUILD_GNU_CPU ?= $(shell dpkg-architecture -qDEB_BUILD_GNU_CPU)
 DEB_BUILD_GNU_SYSTEM ?= $(shell dpkg-architecture -qDEB_BUILD_GNU_SYSTEM)
+DEB_BUILD_GNU_TYPE ?= $(shell dpkg-architecture -qDEB_BUILD_GNU_TYPE)
 
-JAVA_UNSUPPORTED_CPUS = zhppaz zmipsz zmipselz
-JAVA_UNSUPPORTED_SYSTEMS = zgnuz zkfreebsd-gnuz zknetbsd-gnuz
+# this hack gets libtool to work on GNU/k*BSD
+ifeq ($(DEB_BUILD_GNU_SYSTEM),kfreebsd-gnu)
+DEB_BUILD_GNU_TYPE = $(DEB_BUILD_GNU_CPU)-gnu
+else
+ifeq ($(DEB_BUILD_GNU_SYSTEM),knetbsd-gnu)
+DEB_BUILD_GNU_TYPE = $(DEB_BUILD_GNU_CPU)-gnu
+endif
+endif
+
+JAVA_UNSUPPORTED_CPUS = hppa,mips,mipsel
+JAVA_UNSUPPORTED_SYSTEMS = gnu,kfreebsd-gnu,knetbsd-gnu
+
+JAVA_ENABLED = yes
+ifeq ($(DEB_BUILD_GNU_CPU),hppa)
+JAVA_ENABLED =
+endif
+ifeq ($(DEB_BUILD_GNU_CPU),mips)
+JAVA_ENABLED =
+endif
+ifeq ($(DEB_BUILD_GNU_CPU),mipsel)
+JAVA_ENABLED =
+endif
+ifeq ($(DEB_BUILD_GNU_SYSTEM),gnu)
+JAVA_ENABLED =
+endif
+ifeq ($(DEB_BUILD_GNU_SYSTEM),kfreebsd-gnu)
+JAVA_ENABLED =
+endif
+ifeq ($(DEB_BUILD_GNU_SYSTEM),knetbsd-gnu)
+JAVA_ENABLED =
+endif
 
 CONFIGURE_VARS =  CFLAGS="$(CFLAGS)" CPPFLAGS="-I/usr/include/tcl8.4" \
 		  CC=gcc CXX=g++
@@ -39,13 +69,13 @@
 
 DB_BINARY_PKGS = libdb4.1 libdb4.1-dev libdb4.1++ libdb4.1++-dev libdb4.1-tcl db4.1-util
 
-ifeq (,$(findstring z$(DEB_BUILD_GNU_CPU)z,$(JAVA_UNSUPPORTED_CPUS)))
-ifeq (,$(findstring z$(DEB_BUILD_GNU_SYSTEM)z,$(JAVA_UNSUPPORTED_SYSTEMS)))
+ifneq ($(JAVA_ENABLED),)
 CONFIGURE_VARS += JAVAC="gcj-wrapper" JAR="fastjar"
 CONFIGURE_SWITCHES += --enable-java
 DB_BINARY_PKGS += libdb4.1-java
 endif
-endif
+
+CONFIGURE_SWITCHES += $(DEB_BUILD_GNU_TYPE)
 
 package=db4.1
 
@@ -77,6 +107,10 @@
 	rm -f build install-stamp
 	-rm -rf debian/tmp `find debian/* -type d ! -name CVS` debian/files* core
 	-rm -f debian/substvars.*
+	cat debian/control.in \
+	| sed "s/@linux-gnu@/`type-handling any linux-gnu`/g" \
+	| sed "s/@java_no_archs@/`type-handling -n $(JAVA_UNSUPPORTED_CPUS) any` `type-handling -n any $(JAVA_UNSUPPORTED_SYSTEMS)`/g" \
+	> debian/control
 
 install-stamp: build
 	$(checkdir)
@@ -132,22 +166,18 @@
 	cp -a debian/tmp/usr/bin debian/db4.1-util/usr
 	cp -a debian/tmp/usr/lib/*.so debian/tmp/usr/lib/*.a \
 	        debian/tmp/usr/lib/*.la debian/libdb4.1-dev/usr/lib
-ifeq (,$(findstring z$(DEB_BUILD_GNU_CPU)z,$(JAVA_UNSUPPORTED_CPUS)))
-ifeq (,$(findstring z$(DEB_BUILD_GNU_SYSTEM)z,$(JAVA_UNSUPPORTED_SYSTEMS)))
+ifneq ($(JAVA_ENABLED),)
 	cp -a debian/tmp/usr/lib/db.jar \
 		debian/libdb4.1-java/usr/share/java/libdb4.1-java-$(version).jar
 	ln -s libdb4.1-java-$(version).jar \
 		debian/libdb4.1-java/usr/share/java/libdb4.1-java.jar
 endif
-endif
 	mv debian/libdb4.1-dev/usr/lib/*cxx* debian/libdb4.1++-dev/usr/lib
 	mv debian/libdb4.1-dev/usr/include/*cxx* debian/libdb4.1++-dev/usr/include
 	mv debian/libdb4.1-dev/usr/lib/*tcl* debian/libdb4.1-tcl/usr/lib
-ifeq (,$(findstring z$(DEB_BUILD_GNU_CPU)z,$(JAVA_UNSUPPORTED_CPUS)))
-ifeq (,$(findstring z$(DEB_BUILD_GNU_SYSTEM)z,$(JAVA_UNSUPPORTED_SYSTEMS)))
+ifneq ($(JAVA_ENABLED),)
 	mv debian/libdb4.1-dev/usr/lib/*java* debian/libdb4.1-java/usr/lib
 endif
-endif
 	mv debian/libdb4.1-dev/usr/lib/libdb-4.1.so debian/libdb4.1/usr/lib
 	mv debian/libdb4.1++-dev/usr/lib/libdb_cxx-4.1.so debian/libdb4.1++/usr/lib
 
@@ -164,11 +194,9 @@
 	echo 'libdb 4.1 libdb4.1' >debian/libdb4.1/DEBIAN/shlibs
 	echo 'libdb_cxx 4.1 libdb4.1++' >debian/libdb4.1++/DEBIAN/shlibs
 	echo 'libdb_tcl 4.1 libdb4.1-tcl' >debian/libdb4.1-tcl/DEBIAN/shlibs
-ifeq (,$(findstring z$(DEB_BUILD_GNU_CPU)z,$(JAVA_UNSUPPORTED_CPUS)))
-ifeq (,$(findstring z$(DEB_BUILD_GNU_SYSTEM)z,$(JAVA_UNSUPPORTED_SYSTEMS)))
+ifneq ($(JAVA_ENABLED),)
 	echo 'libdb_java 4.1 libdb4.1-java' >debian/libdb4.1-java/DEBIAN/shlibs
 endif
-endif
 
 	for i in $(DB_BINARY_PKGS); \
 	do dpkg-shlibdeps -Tdebian/substvars.$${i} -dDepends `find debian/$${i}/usr -name "*.so" -o -name "db4.1_*"` ; \
