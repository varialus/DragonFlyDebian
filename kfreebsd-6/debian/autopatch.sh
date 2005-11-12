#!/bin/sh
set -e

for i in `find . -type f` ; do
  sed -i ${i} \
    -e 's/defined\( \|\t\)*(\( \|\t\)*__FreeBSD__\( \|\t\)*)/defined(__FreeBSD_kernel__)/g' \
    -e 's/#\( \|\t\)*ifdef\( \|\t\)*__FreeBSD__/#ifdef __FreeBSD_kernel__/g' \
    -e 's/#\( \|\t\)*ifndef\( \|\t\)*__FreeBSD__/#ifndef __FreeBSD_kernel__/g' \
    -e 's/__FreeBSD__/6/g' \
    -e 's,#\( \|\t\)*include\( \|\t\)*<sys/device.h>,,g' \
    -e 's,#\( \|\t\)*include\( \|\t\)*<dev/rndvar.h>,,g' \
    -e 's,#\( \|\t\)*include\( \|\t\)*<sys/pool.h>,,g' \
    -e 's,#\( \|\t\)*include\( \|\t\)*<netinet/ip_ipsp.h>,,g' \
    -e 's,#\( \|\t\)*include\( \|\t\)*\(<\|"\)bpfilter.h\(>\|"\),,g' \
    -e 's,#\( \|\t\)*include\( \|\t\)*\(<\|"\)pflog.h\(>\|"\),,g'
done
