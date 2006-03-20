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

exit 0

