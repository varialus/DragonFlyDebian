#!/bin/sh -e

for i in `find src -type f -name \*.c` `find src -type f -name \*.h` ; do
  mv $i $i.old
  cat $i.old | sed s/__FreeBSD__/__FreeBSD_kernel__/g > $i
  rm $i.old
  (ed $i || true) << EOF >/dev/null 2>/dev/null
/^#/
i
#undef __linux__
#undef __FreeBSD_kernel__
#define __FreeBSD_kernel__ 5
#define __FreeBSD_version 502010
.
w
q
EOF
done
