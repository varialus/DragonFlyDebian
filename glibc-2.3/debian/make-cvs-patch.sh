#!/bin/bash

# This script is designed to help make patches to update from the last
# release to the latest CVS.  Hand it the argument of the directory from
# which to generate the diff.

# This script is not robust.  Feel free to improve it.  Specifically,
# run this from the root of the package.

# This file is in the PUBLIC DOMAIN
# written by Jeff Bailey jbailey@debian.org September 6th, 2002

if [ $# -ne 1 ]; then
  echo "`basename $0`: script expects a CVS tree to diff against"
  exit 1
fi

source version

debian/rules unpack

diff -urN -x CVS -x .cvsignore -x '*texi' -x '*manual*' glibc-$VERSION $1 >cvs.patch

