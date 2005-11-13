#!/bin/bash
set -e

if ! test -e ./linux/msdos_fs.h ; then
  cat << EOF
Linux headers need to be obtained from Linux sources, patched with
linux_msdos.bash, and put in dosfstools-2.11/linux/.  Since this is needed for
other packages (e.g. ms-sys), it'd be nice if they were in a common place.
If the Debian Linux maintainers don't want it, we could have a separate package
for patched headers..
EOF
  exit 1
fi

# these types are defined in Linux sources and shouldn't be used
find . -type f | \
  (while read i ; do \
    sed -i $i -e "s/__u8/unsigned char/g" -e "s/__u16/unsigned short/g" -e "s/__u32/unsigned int/g" ; \
  done)

patch -p1 < $0
exit 0

diff -ur dosfstools-2.11.old/debian/rules dosfstools-2.11/debian/rules
--- dosfstools-2.11.old/debian/rules	2005-11-13 10:52:39.000000000 +0100
+++ dosfstools-2.11/debian/rules	2005-11-13 10:53:20.000000000 +0100
@@ -19,9 +19,9 @@
 docdir=$(tmpdir)/usr/share/doc/dosfstools
 mandir=$(tmpdir)/usr/share/man
 oldmandir=$(tmpdir)/usr/man
-ARCH = $(shell dpkg --print-gnu-build-architecture)
+DEB_HOST_ARCH_CPU ?= $(shell dpkg-architecture -qDEB_HOST_ARCH_CPU)
 
-ifeq ($(ARCH),alpha)
+ifeq ($(DEB_HOST_ARCH_CPU),alpha)
 OPTFLAGS="-fomit-frame-pointer -fno-strict-aliasing $(shell getconf LFS_CFLAGS)"
 else
 OPTFLAGS="-O2 -fomit-frame-pointer $(shell getconf LFS_CFLAGS)"
diff -ur dosfstools-2.11.old/dosfsck/Makefile dosfstools-2.11/dosfsck/Makefile
--- dosfstools-2.11.old/dosfsck/Makefile	2005-11-13 10:52:39.000000000 +0100
+++ dosfstools-2.11/dosfsck/Makefile	2005-11-13 10:53:20.000000000 +0100
@@ -7,7 +7,7 @@
 	$(CC) -o $@ $(LDFLAGS) $^
 
 .c.o:
-	$(CC) -c $(CFLAGS) $*.c
+	$(CC) -c $(CFLAGS) $*.c -I..
 
 install: dosfsck
 	mkdir -p $(SBINDIR) $(MANDIR)
diff -ur dosfstools-2.11.old/dosfsck/common.h dosfstools-2.11/dosfsck/common.h
--- dosfstools-2.11.old/dosfsck/common.h	2005-11-13 10:52:39.000000000 +0100
+++ dosfstools-2.11/dosfsck/common.h	2005-11-13 10:53:20.000000000 +0100
@@ -2,12 +2,17 @@
 
 /* Written 1993 by Werner Almesberger */
 
+#ifdef __linux__
 #include <linux/version.h>
 #if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 0)
 # define __KERNEL__
 # include <asm/types.h>
 # undef __KERNEL__
-# define MSDOS_FAT12 4084 /* maximum number of clusters in a 12 bit FAT */
+#endif
+#endif /* __linux__ */
+
+#ifndef MSDOS_FAT12
+#define MSDOS_FAT12 4084 /* maximum number of clusters in a 12 bit FAT */
 #endif
 
 #ifndef _COMMON_H
diff -ur dosfstools-2.11.old/dosfsck/dosfsck.h dosfstools-2.11/dosfsck/dosfsck.h
--- dosfstools-2.11.old/dosfsck/dosfsck.h	2005-11-13 10:52:39.000000000 +0100
+++ dosfstools-2.11/dosfsck/dosfsck.h	2005-11-13 10:53:20.000000000 +0100
@@ -10,6 +10,8 @@
 #define _DOSFSCK_H
 
 #include <sys/types.h>
+
+#ifdef __linux__
 #define _LINUX_STAT_H		/* hack to avoid inclusion of <linux/stat.h> */
 #define _LINUX_STRING_H_	/* hack to avoid inclusion of <linux/string.h>*/
 #define _LINUX_FS_H             /* hack to avoid inclusion of <linux/fs.h> */
@@ -21,6 +23,7 @@
 # include <asm/byteorder.h>
 # undef __KERNEL__
 #endif
+#endif /* __linux__ */
 
 #include <linux/msdos_fs.h>
 
diff -ur dosfstools-2.11.old/dosfsck/file.c dosfstools-2.11/dosfsck/file.c
--- dosfstools-2.11.old/dosfsck/file.c	2005-11-13 10:52:39.000000000 +0100
+++ dosfstools-2.11/dosfsck/file.c	2005-11-13 10:53:20.000000000 +0100
@@ -12,6 +12,7 @@
 #include <ctype.h>
 #include <unistd.h>
 
+#ifdef __linux__
 #define _LINUX_STAT_H		/* hack to avoid inclusion of <linux/stat.h> */
 #define _LINUX_STRING_H_	/* hack to avoid inclusion of <linux/string.h>*/
 #define _LINUX_FS_H             /* hack to avoid inclusion of <linux/fs.h> */
@@ -22,6 +23,7 @@
 # include <asm/types.h>
 # undef __KERNEL__
 #endif
+#endif /* __linux__ */
 
 #include <linux/msdos_fs.h>
 
Only in dosfstools-2.11/: linux
diff -ur dosfstools-2.11.old/mkdosfs/Makefile dosfstools-2.11/mkdosfs/Makefile
--- dosfstools-2.11.old/mkdosfs/Makefile	2005-11-13 10:52:39.000000000 +0100
+++ dosfstools-2.11/mkdosfs/Makefile	2005-11-13 10:53:20.000000000 +0100
@@ -7,7 +7,7 @@
 	$(CC) $(LDFLAGS) $^ -o $@
 
 .c.o:
-	$(CC) $(CFLAGS) -c $< -o $@
+	$(CC) $(CFLAGS) -c $< -o $@ -I..
 
 install: mkdosfs
 	mkdir -p $(SBINDIR) $(MANDIR)
diff -ur dosfstools-2.11.old/mkdosfs/mkdosfs.c dosfstools-2.11/mkdosfs/mkdosfs.c
--- dosfstools-2.11.old/mkdosfs/mkdosfs.c	2005-11-13 10:52:39.000000000 +0100
+++ dosfstools-2.11/mkdosfs/mkdosfs.c	2005-11-13 10:53:20.000000000 +0100
@@ -66,21 +66,23 @@
 #include <time.h>
 #include <errno.h>
 
+#ifdef __linux__
 #include <linux/version.h>
 #if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 0)
 # define __KERNEL__
 # include <asm/types.h>
 # undef __KERNEL__
 #endif
+#endif
 
 #if __BYTE_ORDER == __BIG_ENDIAN
 
 #include <asm/byteorder.h>
-#ifdef __le16_to_cpu
+#ifdef unsigned short_to_cpu
 /* ++roman: 2.1 kernel headers define these function, they're probably more
  * efficient then coding the swaps machine-independently. */
-#define CF_LE_W	__le16_to_cpu
-#define CF_LE_L	__le32_to_cpu
+#define CF_LE_W	unsigned short_to_cpu
+#define CF_LE_L	unsigned int_to_cpu
 #define CT_LE_W	__cpu_to_le16
 #define CT_LE_L	__cpu_to_le32
 #else
@@ -89,7 +91,7 @@
                (((unsigned)(v)<<8)&0xff0000) | ((unsigned)(v)<<24))
 #define CT_LE_W(v) CF_LE_W(v)
 #define CT_LE_L(v) CF_LE_L(v)
-#endif /* defined(__le16_to_cpu) */
+#endif /* defined(unsigned short_to_cpu) */
     
 #else
 
