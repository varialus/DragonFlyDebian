#!/bin/bash

ANONCVS=anoncvs@anoncvs.fr.freebsd.org:/home/ncvs
RELENG=RELENG_7_0_0_RELEASE

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
	src/sbin/sunlabel:sunlabel \
	src/sbin/ffsinfo:ffsinfo \
	src/sbin/mount:mount \
	src/lib/libufs:libufs \
	src/sys/ufs:include"

include_files=" \
	src/sys/sys/disklabel.h:freebsd/sys \
	src/sys/sys/mount.h:freebsd/sys \
	src/sys/sys/param.h:freebsd/sys \
	src/sys/sys/ucred.h:freebsd/sys"
	
libc_files=" \
	src/lib/libc/gen/arc4random.c:libport \
	src/lib/libc/string/strlcat.c:libport \
	src/lib/libc/string/strlcpy.c:libport"
                        

move_repo()
{
  local list=$@

  for src in $list
  do
    repo=${src//:*/}
    dest=${src//*:/}
    echo " -> moving $repo to $dest"
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

echo "-> Downloading all upstream sources ..."
repos=`get_cvs_list $srcs $include_files $libc_files`

# Note: Does not use co -d because freebsd cvs server has
#       a fascist connection limit (2)

cvs -z3 -d $ANONCVS co -r $RELENG $repos

rm -rf badsect.ufs bsdlabel dump.ufs dumpfs.ufs ffsinfo freebsd fsck.ufs fsdb.ufs growfs.ufs include libufs libport mkfs.ufs sunlabel tunefs.ufs libdisklabel

mkdir -p include libport freebsd/sys

echo "-> Moving upstream sources to the proper place ..."
move_repo $srcs

echo "-> Moving upstream includes to the proper place ..."
move_repo $include_files

echo "-> Moving upstream libc bits to the proper place ..."
move_repo $libc_files

echo "-> Cleaning the mess ..."
rm -rf src
