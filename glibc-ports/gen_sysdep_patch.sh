#!/bin/sh
set -ex
LANG=C

# sysdeps dir
tmp=`mktemp -d`
mkdir -p ${tmp}/b/ports/sysdeps/unix/bsd/bsd4.4
cp -a kfreebsd ${tmp}/b/ports/sysdeps/unix/bsd/bsd4.4/
(cd ${tmp} && diff -x .svn -Nurd null b/ports ) | \
   sed -e "sz^--- null/sysdeps/unix/bsd/bsd4.4/kfreebsd/.*z--- /dev/nullz" \
       -e "\z^diff -x .svn -Nurd null/sysdeps/unix/bsd/bsd4.4/kfreebsd/.*zd" \
       -e "\z^+++ b/ports/sysdeps/unix/bsd/bsd4.4/kfreebsd/zsz\t20[0-9][0-9].*zz" \
   > sysdeps.diff
rm -rf ${tmp}

