#!/bin/bash
cp debian/patches/{template.dpatch,kfreebsd-gnu.dpatch}
for i in `grep -v '^#' patches/0list` ; do
  cat patches/$i >> debian/patches/kfreebsd-gnu.dpatch
done
