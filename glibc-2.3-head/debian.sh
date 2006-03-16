#!/bin/sh
set -ex

if [ "$1" = "" ] ; then
  echo "Usage: $0 ..../glibc-2.3-head/  (to be run from debian source tree)"
  exit 1
fi

# sysdeps dir
tmp=`mktemp -d`
mkdir -p ${tmp}/sysdeps/unix/bsd/bsd4.4 ${tmp}/linuxthreads/sysdeps/unix/bsd/bsd4.4
cp -a $1/sysdeps/kfreebsd ${tmp}/sysdeps/unix/bsd/bsd4.4/
cp -a $1/linuxthreads/kfreebsd ${tmp}/linuxthreads/sysdeps/unix/bsd/bsd4.4/
echo "kfreebsd-sysdeps.diff -p0" >> debian/patches/series
(cd ${tmp} && diff -x .svn -Nurd null sysdeps/ ) > debian/patches/kfreebsd-sysdeps.diff
(cd ${tmp} && diff -x .svn -Nurd null linuxthreads/ ) >> debian/patches/kfreebsd-sysdeps.diff
rm -rf ${tmp}

for i in `ls $1/patches` ; do
  cat $1/patches/$i/*.patch > debian/patches/kfreebsd-$i.diff
  echo "kfreebsd-$i.diff -p0" >> debian/patches/series
done

patch -p1 < $0

exit 0

--- glibc-2.3.6/debian/sysdeps/kfreebsd-amd64.mk~	2006-03-15 21:53:59.000000000 +0100
+++ glibc-2.3.6/debian/sysdeps/kfreebsd-amd64.mk	2006-03-16 07:47:12.000000000 +0100
@@ -3,7 +3,7 @@
 libc_rtlddir = /lib64
 
 # /lib64 and /usr/lib64 are provided by glibc instead base-files: #259302.
-define libc0.1_extra_pkg_install
+define libc6_extra_pkg_install
 ln -sf /lib debian/$(curpass)/lib64
 ln -sf lib debian/$(curpass)/usr/lib64
 endef
