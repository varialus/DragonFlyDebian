#! /bin/sh -e

. ./version

tempdir=temp-unpack/
[ -d $tempdir ] && rm -rf $tempdir

trap 'rm -rf $tempdir' 1 2 3 13 15

mycat() {
    local prog
    case $1 in
	*.bz2|.bz)	prog="bzcat";;
	*.gz|*.Z|*.tgz)	prog="zcat";;
	*)		prog="cat";;
    esac
    $prog $1
}

unpack() {
    local tarfile srcdir destdir status
    [ -d $tempdir ] || mkdir -p $tempdir
    tarfile=$1
    if [ ! -r $tarfile ]; then
	echo "E: $tarfile does not exist."
	exit 1
    fi
    # $2 is "in"
    srcdir=$tempdir${3}
    # $4 is "creating"
    destdir=$5
    echo "I: Unpacking ${tarfile} as ${destdir} in ${srcdir}"
    mycat ${tarfile} | tar -C $srcdir -xf -
    status=$?
    if [ $status -gt 0 ]; then
	echo "E: subprocess (tar) exited with $status exit status."
	exit 1
    fi
}

overlay() {
    local srcdir tarfile destdir status
    srcdir=$(pwd)/
    tarfile=$1
    if [ ! -r $tarfile ]; then
	echo "E: $tarfile does not exist."
	exit 1
    fi
    # $2 is "on"
    destdir=$(pwd)/$tempdir$3
    echo "I: Overlaying ${tarfile} on ${destdir}."
    mycat ${srcdir}${tarfile} | tar -C $destdir -xf -
    status=$?
    if [ $status -gt 0 ]; then
	echo "E: subprocess (tar) exited with $status exit status."
	exit 1
    fi
}

patch() {
    local srcdir origdir newdir patchfile strip status
    srcdir=$(pwd)/
    origdir=$1
    # $2 is "to"
    if [ "$2" != "inplace" ]; then
	newdir=$3
	# $4 is "with" or "using"
	patchfile=$5
	if [ ! -r $patchfile ]; then
	    echo "E: $patchfile does not exist."
	    exit 1
	fi
	# $6 is "strip" or "stripping"
	strip=$7
	if [ ! -d $newdir ] && [ -d $origdir ]; then
	    echo "I: Moving $origdir to $newdir for patching."
	    mv $tempdir$origdir $tempdir$newdir
	fi
    else
	newdir=${origdir}
	patchfile=$4
	strip=$6
    fi
    echo "I: Patching $newdir with $patchfile."
    (mycat ${srcdir}${patchfile} | command patch -d $tempdir$newdir -p${strip})
    status=$?
    if [ $status -gt 0 ]; then
	echo "E: subprocess (patch) exited with $status exit status."
	exit 1
    fi
}

finish() {
    if [ -e "$1" ]; then
	echo "I: removing $1"
	rm -rf "$1"
    fi
    echo "I: Finishing $1 and removing $tempdir"
    mv "$tempdir$1" "$2"
    rmdir $tempdir > /dev/null 2>&1 || true
}

# Glibc
unpack glibc-${TARBALL_VERSION}.tar.bz2 in . creating glibc-${TARBALL_VERSION}
finish glibc-${TARBALL_VERSION} ./glibc-${VERSION}
cp -a /usr/src/glibc-kbsd/sysdeps glibc-${VERSION}/
ln -s /usr/src/kfreebsd-headers-4.6 \
  glibc-${VERSION}/sysdeps/unix/bsd/bsd4.4/kfreebsd/kernel-headers
(cd glibc-${VERSION}/sysdeps/unix/bsd/bsd4.4/kfreebsd/ && \
  autoconf2.13 -l ../../../../..)
cp -f /usr/share/misc/config.* ./glibc-${VERSION}/scripts/
