#!/bin/sh

while true; do
  case "$1" in
    --help|--usage|--version) info=1; shift;;
    # ignore these
    --verbose|--print-cache|--format) shift;;
    # stop option processing
    --) shift; break;;
    --*) echo Unknown option "$1"; shift;;
    -*) getopts vnNXf:C:r:lpc:V opt || break
	case $opt in
	  V) info=1;;
	  # ignore these
	  v|p|c|f|C) ;;
	  # seems like the user wants something we can't really do
	  n|N|l|r) notsupp=1;;
	  ?) shift;;
	  *) echo $0: Internal error; exit 255;;
	esac;;
    *) break;;
  esac
done

shift `expr $OPTIND - 1`
[ -n "$1" ] && notsupp=1
[ -n "$info" -o -n "$notsupp" ] && echo The Hurd has no real ldconfig.
if [ -n "$info" ]; then
  cat <<EOF

There is no library cache that has to be kept current, so that part of
ldconfig's functionality is not applicable.

The other part is (re)creating soname -> realname links for shared libraries.
On Debian GNU/Hurd, all packages should come with this link, otherwise the
package has a bug. Therefore administrators will not need ldconfig.

ldconfig is sometimes also used during library building to create these
symlinks. This is not portable and should be considered a bug. Portable means
include linking by hand via "ln -s" or simply building the library with the
help of "libtool".
EOF
fi
if [ -n "$notsupp" ]; then
  echo 'See "ldconfig --help" for an explanation.'
  exit 1
fi

exit 0
