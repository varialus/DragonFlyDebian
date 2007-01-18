#!/bin/bash

cvsroot=":ext:anoncvs@anoncvs.fr.freebsd.org:/home/ncvs"

srcs=" \
	src/sbin/badsect:badsect.ufs \
	src/sbin/dump:dump.ufs \
	src/sbin/dumpfs:dumpfs.ufs \
	src/sbin/fsck_ffs:fsck.ufs \
	src/sbin/fsdb:fsdb.ufs \
	src/sbin/growfs:growfs.ufs \
	src/sbin/newfs:mkfs.ufs \
	src/sbin/tunefs:tunefs.ufs \
	src/sbin/bsdlabel:bsdlabel \
	src/sbin/sunlabel:sunlable \
	src/sbin/ffsinfo:ffsinfo \
	src/lib/libufs:libufs \
	src/sys/ufs:include"

include_files=" \
	src/sys/sys/disklabel.h:include/sys \
	src/sys/sys/mount.h:include/sys \
	src/sys/sys/param.h:include/sys \
	src/sys/sys/ucred.h:include/sys"

move_repo()
{
  local list=$@

  for src in $list
  do
    repo=${src//:*/}
    dest=${src//*:/}
    echo " -> moving $repo to $dest"
    if [ ! -d $repo ]; then
      mkdir -p $dest
    fi
    mv $repo $dest
  done
}

get_cvs_list()
{
  local list=$@

  for src in $list
  do
    orig="$orig ${src//:*/}"
  done
  echo $orig
}

echo "-> Downloading upstream sources ..."
repos=`get_cvs_list $srcs`
# Note: Does not use co -d because freebsd cvs server has
#       a fascist connection limit (2)
cvs -z3 -d$cvsroot co $repos

mkdir include

echo "-> Moving upstream sources to the proper place ..."
move_repo $srcs

echo "-> Downloading upstream includes ..."
cvs_includes=`get_cvs_list $include_files`
cvs -z3 -d$cvsroot co $cvs_includes

echo "-> Moving upstream includes to the proper place ..."
move_repo $include_files

echo "-> Cleaning the mess ..."
rm -rf src

