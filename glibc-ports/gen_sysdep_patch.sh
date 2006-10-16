#!/bin/sh
set -ex
LANG=C

# sysdeps dir
tmp=`mktemp -d`
mkdir -p ${tmp}/ports/sysdeps/unix/bsd/bsd4.4
cp -a kfreebsd ${tmp}/ports/sysdeps/unix/bsd/bsd4.4/
(cd ${tmp} && diff -x .svn -Nurd null ports/ ) > sysdeps.diff
rm -rf ${tmp}

