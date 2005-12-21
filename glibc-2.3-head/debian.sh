#!/bin/sh
set -ex

pwd=`pwd`

if [ "$1" = "" ] ; then
  echo "Usage: $0 ..../glibc-2.3-head/  (to be run from debian source tree)"
  exit 1
fi

(cd $1 && tar -cjf ${pwd}/kfreebsd.tar.bz2 sysdeps linuxthreads)
cp $1/patches/* debian/patches/
ls $1/patches | sed -e "s,\.dpatch$,,g" >> debian/patches/00list
patch -p1 < $0
exit 0

diff -ur glibc-2.3.5.old/prep.sh glibc-2.3.5/prep.sh
--- glibc-2.3.5.old/prep.sh	2005-04-16 13:30:16.000000000 +0200
+++ glibc-2.3.5/prep.sh	2005-12-21 21:00:06.000000000 +0100
@@ -106,4 +106,8 @@
 overlay glibc-linuxthreads-${TARBALL_VERSION}.tar.bz2 on glibc-${TARBALL_VERSION}
 overlay glibc-libidn-${TARBALL_VERSION}.tar.bz2 on glibc-${TARBALL_VERSION}
 # overlay nptl-${NPTL_VERSION}.tar.bz2 on glibc-${TARBALL_VERSION}
+overlay kfreebsd.tar.bz2 on glibc-${TARBALL_VERSION}
+mv glibc-${TARBALL_VERSION}/sysdeps/kfreebsd glibc-${TARBALL_VERSION}/sysdeps/unix/bsd/bsd4.4/
+mkdir -p glibc-${TARBALL_VERSION}/linuxthreads/sysdeps/unix/bsd/bsd4.4
+mv glibc-${TARBALL_VERSION}/linuxthreads/sysdeps/kfreebsd glibc-${TARBALL_VERSION}/linuxthreads/sysdeps/unix/bsd/bsd4.4/
 finish glibc-${TARBALL_VERSION} ./glibc-${VERSION}
