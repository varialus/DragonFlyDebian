#!/bin/sh
set -ex

# sysdeps dir
tmp=`mktemp -d`
mkdir -p ${tmp}/sysdeps/unix/bsd/bsd4.4 ${tmp}/linuxthreads/sysdeps/unix/bsd/bsd4.4
cp -a sysdeps/kfreebsd ${tmp}/sysdeps/unix/bsd/bsd4.4/
cp -a linuxthreads/kfreebsd ${tmp}/linuxthreads/sysdeps/unix/bsd/bsd4.4/
(cd ${tmp} && diff -x .svn -Nurd null sysdeps/ ) > sysdeps.diff
(cd ${tmp} && diff -x .svn -Nurd null linuxthreads/ ) >> sysdeps.diff
rm -rf ${tmp}

