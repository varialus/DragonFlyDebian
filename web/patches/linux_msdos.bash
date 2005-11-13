#!/bin/bash
set -e

# Diffed from linux-source-2.6.12 package, version 2.6.12-1.

# these types are defined in Linux sources and shouldn't be used
find . -type f | \
  (while read i ; do \
    sed -i $i -e "s/__u8/unsigned char/g" -e "s/__u16/unsigned short/g" -e "s/__u32/unsigned int/g" ; \
  done)
  # WARNING: this breaks big-endian
find . -type f | \
  (while read i ; do \
    sed -i $i -e "s/__le8/unsigned char/g" -e "s/__le16/unsigned short/g" -e "s/__le32/unsigned int/g" ; \
  done)

patch -p1 < $0
exit 0

diff -ur /usr/src/linux-source-2.6.12/include/linux/msdos_fs.h ./linux/msdos_fs.h
--- /usr/src/linux-source-2.6.12/include/linux/msdos_fs.h	2005-06-17 21:48:29.000000000 +0200
+++ ./linux/msdos_fs.h	2005-08-03 12:55:41.000000000 +0200
@@ -4,7 +4,9 @@
 /*
  * The MS-DOS filesystem constants/structures
  */
+#ifdef __linux__
 #include <asm/byteorder.h>
+#endif
 
 #define SECTOR_SIZE	512		/* sector size (bytes) */
 #define SECTOR_BITS	9		/* log2(SECTOR_SIZE) */
