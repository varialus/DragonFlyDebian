#!/bin/sh -e

# Idea borrowed from RedHat's kernel package

arch="$1"
dir_in="$2"
dir_out="$3"

if [ ! -d "$dir_in" ] ; then
	echo "$dir_in" does not exist, or is not a directory
	exit 1
fi

case "$arch" in
	amd64)
		define_biarch="#ifdef __i386__"
		arch="amd64"
		biarch="i386"
		;;
	i386)
		define_biarch="#ifdef __x86_64__"
		arch="i386"
		biarch="amd64"
		;;
	*)
		echo Invalid architecture >&2
		exit 1
esac

machine_dir="$arch/include"
machine_dir_biarch="$biarch/include"

# The directory to create in /usr/include. 
machine_dir_out="machine-$arch"
machine_dir_out_biarch="machine-$biarch"

if [ ! -d "$dir_in/$machine_dir" ] || [ ! -d "$dir_in/$machine_dir_biarch" ] ; then
	echo E: $machine_dir and $machine_dir_biarch must exist, or you will have problems
	exit 1
fi

mkdir -p $dir_out/machine
cp -a $dir_in/$machine_dir $dir_out/$machine_dir_out
cp -a $dir_in/$machine_dir_biarch $dir_out/$machine_dir_out_biarch

dirs=$( (( cd "$dir_in/$machine_dir"; find . -type d ); ( cd "$dir_in/$machine_dir_biarch"; find . -type d )) | sort -u )
files=$( (( cd "$dir_in/$machine_dir"; find . -name "*.h" -type f ); ( cd "$dir_in/$machine_dir_biarch"; find . -name "*.h" -type f )) | sed 's/^.\///g' | sort -u )

for h in $dirs; do
	mkdir -p "$dir_out/machine/$h"
done

for h in $files; do
	name=$(echo $h | tr a-z. A-Z_)
	file_out="$dir_out/machine/$h"
	# common header
	cat > $file_out << EOF
/* All machine/ files are generated and point to the corresponding
 * file in $machine_dir_out or $machine_dir_biarch.
 */

EOF

	if [ -f $dir_in/$machine_dir/$h ] && [ -f $dir_in/$machine_dir_biarch/$h ]; then
		cat >> $file_out <<EOF
$define_biarch
# include <$machine_dir_out_biarch/$h>
#else
# include <$machine_dir_out/$h>
#endif
EOF

	elif [ -f $dir_in/$machine_dir/$h ]; then
		cat >> $file_out <<EOF
$define_biarch
# error This header is not available for $biarch
#else
# include <$machine_dir_out/$h>
#endif
EOF
	else
		cat >> $file_out <<EOF
$define_biarch
# include <$machine_dir_out_biarch/$h>
#else
# error This header is not available for $arch
#endif
EOF
	fi

done

