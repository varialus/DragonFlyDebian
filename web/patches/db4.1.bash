#!/bin/bash -e

# Status: in BTS.

cp debian/control{,.in}
patch -p1 < $0
exit 0

diff -ur db4.1-4.1.25.old/debian/control.in db4.1-4.1.25/debian/control.in
--- db4.1-4.1.25.old/debian/control.in	2005-01-20 20:46:50.000000000 +0100
+++ db4.1-4.1.25/debian/control.in	2005-01-20 19:54:45.000000000 +0100
@@ -4,7 +4,7 @@
 Maintainer: Debian Berkeley DB Maintainers <pkg-db-devel@lists.alioth.debian.org>
 Uploaders: Clint Adams <schizo@debian.org>, Matthew Wilcox <willy@debian.org>
 Standards-Version: 3.6.1
-Build-Depends: tcl8.4-dev, procps [!hurd-i386], gcj (>= 3:3.2.2-0) [!hppa !mips !mipsel !hurd-i386], libgcj4-dev [!hppa !mips !mipsel !hurd-i386], fastjar [!hppa !mips !mipsel !hurd-i386], sablevm [!hppa !mips !mipsel !hurd-i386]
+Build-Depends: tcl8.4-dev, procps [!hurd-i386], gcj (>= 3:3.2.2-0) [@java_archs@], libgcj4-dev [@java_archs@], fastjar [@java_archs@], sablevm [@java_archs@], type-handling (>= 0.2.1)
 
 Package: db4.1-doc
 Architecture: all
diff -ur db4.1-4.1.25.old/debian/rules db4.1-4.1.25/debian/rules
--- db4.1-4.1.25.old/debian/rules	2005-01-20 19:52:28.000000000 +0100
+++ db4.1-4.1.25/debian/rules	2005-01-20 20:18:04.000000000 +0100
@@ -16,11 +16,30 @@
 INSTALL_PROGRAM += -s
 endif
 
-DEB_BUILD_GNU_CPU ?= $(shell dpkg-architecture -qDEB_BUILD_GNU_CPU)
-DEB_BUILD_GNU_SYSTEM ?= $(shell dpkg-architecture -qDEB_BUILD_GNU_SYSTEM)
+DEB_HOST_GNU_CPU	?= $(shell dpkg-architecture -qDEB_HOST_GNU_CPU)
+DEB_HOST_GNU_SYSTEM	?= $(shell dpkg-architecture -qDEB_HOST_GNU_SYSTEM)
+DEB_HOST_GNU_TYPE	?= $(shell dpkg-architecture -qDEB_HOST_GNU_TYPE)
+DEB_BUILD_GNU_CPU	?= $(shell dpkg-architecture -qDEB_BUILD_GNU_CPU)
+DEB_BUILD_GNU_TYPE	?= $(shell dpkg-architecture -qDEB_BUILD_GNU_TYPE)
+
+# this hack gets libtool to work on k*bsd-gnu
+ifneq (, $(filter $(DEB_HOST_GNU_SYSTEM), kfreebsd-gnu knetbsd-gnu))
+DEB_BUILD_GNU_TYPE     := $(DEB_BUILD_GNU_CPU)-gnu
+DEB_HOST_GNU_TYPE      := $(DEB_HOST_GNU_CPU)-gnu
+endif
+
+JAVA_UNSUPPORTED_CPUS		:= hppa mips mipsel
+JAVA_UNSUPPORTED_SYSTEMS	:= gnu kfreebsd-gnu knetbsd-gnu
+
+ifeq (:, $(filter $(DEB_HOST_GNU_SYSTEM), $(JAVA_UNSUPPORTED_SYSTEMS)):$(filter $(DEB_HOST_GNU_CPU), $(JAVA_UNSUPPORTED_CPUS)))
+JAVA_ENABLED = yes
+else
+JAVA_ENABLED = no
+endif
+
+JAVA_UNSUPPORTED_CPUS		:= $(shell echo $(JAVA_UNSUPPORTED_CPUS) | tr " " ",")
+JAVA_UNSUPPORTED_SYSTEMS	:= $(shell echo $(JAVA_UNSUPPORTED_SYSTEMS) | tr " " ",")
 
-JAVA_UNSUPPORTED_CPUS = zhppaz zmipsz zmipselz
-JAVA_UNSUPPORTED_SYSTEMS = zgnuz zkfreebsd-gnuz zknetbsd-gnuz
 
 CONFIGURE_VARS =  CFLAGS="$(CFLAGS)" CPPFLAGS="-I/usr/include/tcl8.4" \
 		  CC=gcc CXX=g++
@@ -39,12 +58,16 @@
 
 DB_BINARY_PKGS = libdb4.1 libdb4.1-dev libdb4.1++ libdb4.1++-dev libdb4.1-tcl db4.1-util
 
-ifeq (,$(findstring z$(DEB_BUILD_GNU_CPU)z,$(JAVA_UNSUPPORTED_CPUS)))
-ifeq (,$(findstring z$(DEB_BUILD_GNU_SYSTEM)z,$(JAVA_UNSUPPORTED_SYSTEMS)))
+ifeq ($(JAVA_ENABLED), yes)
 CONFIGURE_VARS += JAVAC="gcj-wrapper" JAR="fastjar"
 CONFIGURE_SWITCHES += --enable-java
 DB_BINARY_PKGS += libdb4.1-java
 endif
+
+ifeq ($(DEB_BUILD_GNU_TYPE), $(DEB_HOST_GNU_TYPE))
+  CONFIGURE_SWITCHES += --build $(DEB_HOST_GNU_TYPE)
+else
+  CONFIGURE_SWITCHES += --build $(DEB_BUILD_GNU_TYPE) --host $(DEB_HOST_GNU_TYPE)
 endif
 
 package=db4.1
@@ -77,6 +100,8 @@
 	rm -f build install-stamp
 	-rm -rf debian/tmp `find debian/* -type d ! -name CVS` debian/files* core
 	-rm -f debian/substvars.*
+	sed -e "s/@java_archs@/`type-handling -r -n $(JAVA_UNSUPPORTED_CPUS) any` `type-handling -r -n any $(JAVA_UNSUPPORTED_SYSTEMS)`/g" \
+	< debian/control.in > debian/control
 
 install-stamp: build
 	$(checkdir)
@@ -132,22 +157,18 @@
 	cp -a debian/tmp/usr/bin debian/db4.1-util/usr
 	cp -a debian/tmp/usr/lib/*.so debian/tmp/usr/lib/*.a \
 	        debian/tmp/usr/lib/*.la debian/libdb4.1-dev/usr/lib
-ifeq (,$(findstring z$(DEB_BUILD_GNU_CPU)z,$(JAVA_UNSUPPORTED_CPUS)))
-ifeq (,$(findstring z$(DEB_BUILD_GNU_SYSTEM)z,$(JAVA_UNSUPPORTED_SYSTEMS)))
+ifeq ($(JAVA_ENABLED), yes)
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
+ifeq ($(JAVA_ENABLED), yes)
 	mv debian/libdb4.1-dev/usr/lib/*java* debian/libdb4.1-java/usr/lib
 endif
-endif
 	mv debian/libdb4.1-dev/usr/lib/libdb-4.1.so debian/libdb4.1/usr/lib
 	mv debian/libdb4.1++-dev/usr/lib/libdb_cxx-4.1.so debian/libdb4.1++/usr/lib
 
@@ -164,11 +185,9 @@
 	echo 'libdb 4.1 libdb4.1' >debian/libdb4.1/DEBIAN/shlibs
 	echo 'libdb_cxx 4.1 libdb4.1++' >debian/libdb4.1++/DEBIAN/shlibs
 	echo 'libdb_tcl 4.1 libdb4.1-tcl' >debian/libdb4.1-tcl/DEBIAN/shlibs
-ifeq (,$(findstring z$(DEB_BUILD_GNU_CPU)z,$(JAVA_UNSUPPORTED_CPUS)))
-ifeq (,$(findstring z$(DEB_BUILD_GNU_SYSTEM)z,$(JAVA_UNSUPPORTED_SYSTEMS)))
+ifeq ($(JAVA_ENABLED), yes)
 	echo 'libdb_java 4.1 libdb4.1-java' >debian/libdb4.1-java/DEBIAN/shlibs
 endif
-endif
 
 	for i in $(DB_BINARY_PKGS); \
 	do dpkg-shlibdeps -Tdebian/substvars.$${i} -dDepends `find debian/$${i}/usr -name "*.so" -o -name "db4.1_*"` ; \
