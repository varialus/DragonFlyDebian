#!/bin/bash -e

# Status: in BTS.

cp debian/control{,.in}
patch -p1 < $0
exit 0

diff -ur db4.2-4.2.52.old/debian/control.in db4.2-4.2.52/debian/control.in
--- db4.2-4.2.52.old/debian/control.in	2005-01-20 20:50:02.000000000 +0100
+++ db4.2-4.2.52/debian/control.in	2005-01-20 19:56:42.000000000 +0100
@@ -4,7 +4,7 @@
 Maintainer: Debian Berkeley DB Maintainers <pkg-db-devel@lists.alioth.debian.org>
 Uploaders: Clint Adams <schizo@debian.org>, Matthew Wilcox <willy@debian.org>, Andreas Barth <aba@not.so.argh.org>
 Standards-Version: 3.6.1
-Build-Depends: tcl8.4-dev, procps [!hurd-i386], gcj (>= 3:3.2.2-0) [!hppa !mips !mipsel !hurd-i386], fastjar [!hppa !mips !mipsel !hurd-i386], sablevm [!hppa !mips !mipsel !hurd-i386], libgcj4-dev [!hppa !mips !mipsel !hurd-i386]
+Build-Depends: tcl8.4-dev, procps [!hurd-i386], gcj (>= 3:3.2.2-0) [@java_archs@], fastjar [@java_archs@], sablevm [@java_archs@], libgcj4-dev [@java_archs@]
 
 Package: db4.2-doc
 Architecture: all
diff -ur db4.2-4.2.52.old/debian/rules db4.2-4.2.52/debian/rules
--- db4.2-4.2.52.old/debian/rules	2005-01-20 19:50:27.000000000 +0100
+++ db4.2-4.2.52/debian/rules	2005-01-20 20:17:44.000000000 +0100
@@ -16,11 +16,24 @@
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
 
 CONFIGURE_VARS =  CFLAGS="$(CFLAGS)" CPPFLAGS="-I/usr/include/tcl8.4" 
 CONFIGURE_SWITCHES =    --prefix=/usr \
@@ -38,13 +51,11 @@
 
 DB_BINARY_PKGS = libdb4.2 libdb4.2-dev libdb4.2++ libdb4.2++-dev libdb4.2-tcl db4.2-util
 
-ifeq (,$(findstring z$(DEB_BUILD_GNU_CPU)z,$(JAVA_UNSUPPORTED_CPUS)))
-ifeq (,$(findstring z$(DEB_BUILD_GNU_SYSTEM)z,$(JAVA_UNSUPPORTED_SYSTEMS)))
+ifeq ($(JAVA_ENABLED), yes)
 CONFIGURE_VARS += JAVAC="gcj-wrapper" JAR="fastjar"
 CONFIGURE_SWITCHES += --enable-java
 DB_BINARY_PKGS += libdb4.2-java
 endif
-endif
 
 package=db4.2
 bdbversion=4.2
@@ -82,6 +93,8 @@
 	rm -f build install-stamp
 	-rm -rf debian/tmp `find debian/* -type d ! -name CVS` debian/files* core
 	-rm -f debian/substvars.*
+	sed -e "s/@java_archs@/`type-handling -r -n $(JAVA_UNSUPPORTED_CPUS) any` `type-handling -r -n any $(JAVA_UNSUPPORTED_SYSTEMS)`/g" \
+	< debian/control.in > debian/control
 
 install-stamp: build
 	$(checkdir)
@@ -137,22 +150,18 @@
 	cp -a debian/tmp/usr/bin debian/$(package)-util/usr
 	cp -a debian/tmp/usr/lib/*.so debian/tmp/usr/lib/*.a \
 	        debian/tmp/usr/lib/*.la debian/lib$(package)-dev/usr/lib
-ifeq (,$(findstring z$(DEB_BUILD_GNU_CPU)z,$(JAVA_UNSUPPORTED_CPUS)))
-ifeq (,$(findstring z$(DEB_BUILD_GNU_SYSTEM)z,$(JAVA_UNSUPPORTED_SYSTEMS)))
+ifeq ($(JAVA_ENABLED), yes)
 	cp -a debian/tmp/usr/lib/db.jar \
 		debian/lib$(package)-java/usr/share/java/lib$(package)-java-$(version).jar
 	ln -s lib$(package)-java-$(version).jar \
 		debian/lib$(package)-java/usr/share/java/lib$(package)-java.jar
 endif
-endif
 	mv debian/lib$(package)-dev/usr/lib/*cxx* debian/lib$(package)++-dev/usr/lib
 	mv debian/lib$(package)-dev/usr/include/*cxx* debian/lib$(package)++-dev/usr/include
 	mv debian/lib$(package)-dev/usr/lib/*tcl* debian/lib$(package)-tcl/usr/lib
-ifeq (,$(findstring z$(DEB_BUILD_GNU_CPU)z,$(JAVA_UNSUPPORTED_CPUS)))
-ifeq (,$(findstring z$(DEB_BUILD_GNU_SYSTEM)z,$(JAVA_UNSUPPORTED_SYSTEMS)))
+ifeq ($(JAVA_ENABLED), yes)
 	mv debian/lib$(package)-dev/usr/lib/*java* debian/lib$(package)-java/usr/lib
 endif
-endif
 	mv debian/lib$(package)-dev/usr/lib/libdb-$(bdbversion).so debian/lib$(package)/usr/lib
 	mv debian/lib$(package)++-dev/usr/lib/libdb_cxx-$(bdbversion).so debian/lib$(package)++/usr/lib
 
@@ -172,11 +181,9 @@
 	echo 'libdb $(bdbversion) lib$(package)' >debian/lib$(package)/DEBIAN/shlibs
 	echo 'libdb_cxx $(bdbversion) lib$(package)++' >debian/lib$(package)++/DEBIAN/shlibs
 	echo 'libdb_tcl $(bdbversion) lib$(package)-tcl' >debian/lib$(package)-tcl/DEBIAN/shlibs
-ifeq (,$(findstring z$(DEB_BUILD_GNU_CPU)z,$(JAVA_UNSUPPORTED_CPUS)))
-ifeq (,$(findstring z$(DEB_BUILD_GNU_SYSTEM)z,$(JAVA_UNSUPPORTED_SYSTEMS)))
+ifeq ($(JAVA_ENABLED), yes)
 	echo 'libdb_java $(bdbversion) lib$(package)-java' >debian/lib$(package)-java/DEBIAN/shlibs
 endif
-endif
 
 	for i in $(DB_BINARY_PKGS); \
 	do dpkg-shlibdeps -Tdebian/substvars.$${i} -dDepends `find debian/$${i}/usr -name "*.so" -o -name "$(package)_*"` ; \
