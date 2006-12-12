#!/bin/bash
#
# skeleton	example file to build /etc/init.d/ scripts.
#		This file should be used to construct scripts for /etc/init.d.
#
#		Written by Miquel van Smoorenburg <miquels@cistron.nl>.
#		Modified for Debian 
#		by Ian Murdock <imurdock@gnu.ai.mit.edu>.
#
# Version:	@(#)skeleton  1.9  26-Feb-2001  miquels@cistron.nl
#

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
set -e

case "$1" in
  start)
    echo -n "Setting up /dev permissions..."

    # only do this during boot, to avoid messing up ttys
    if [ "$RUNLEVEL" = "S" ] ; then
      chown root:root /dev/*
    fi
    
    for i in /dev/dsp{,[0-9]} /dev/mixer{,[0-9]} /dev/audio{,ctl,[0-9]} ; do
      if test -e $i ; then
        chgrp audio $i
      fi
    done
    for i in /dev/{,a}cd[0-9] ; do
      if test -e $i ; then
        chgrp cdrom $i
      fi
    done
    for i in /dev/console /dev/ptyp[0-9] ; do
      if test -e $i ; then
        chgrp tty $i
      fi
    done
    for i in /dev/fd[0-9] ; do
      if test -e $i ; then
        chgrp floppy $i
      fi
    done
    for i in /dev/ata /dev/ad[0-9]* /dev/da[0-9]* ; do
      if test -e $i ; then
        chgrp disk $i
      fi
    done
    for i in /dev/{,k}mem ; do
      if test -e $i ; then
        chgrp kmem $i
      fi
    done
    for i in /dev/lpt[0-9]* ; do
      if test -e $i ; then
        chgrp lp $i
      fi
    done
    for i in /dev/cuaa[0-9] ; do
      if test -e $i ; then
        chgrp dialout $i
      fi
    done
    
    # setup /dev/cdrom symlink
    if ! test -e /dev/cdrom && ! test -L /dev/cdrom ; then
      for i in {,a}cd{0,1,2,3,4,5,6,7,8,9} ; do
        if test -e /dev/$i ; then
          ln -s $i /dev/cdrom
          break
        fi
      done
    fi
    
    echo "done."
    
    # This syctl is (suposedly) correct in kernel, but kfreebsd-loader enjoys messing with it
    sysctl "kern.module_path=/lib/modules/`uname -r`;/boot/kernel"
    
    if test -f /etc/mtab && ! test -h /etc/mtab ; then
      echo "Warning: /etc/mtab is a regular file, replacing with symlink."
      rm -f /etc/mtab
    fi
    ln -sf /proc/mounts /etc/mtab
    
    ;;

  stop|reload|restart|force-reload)
    ;; 

  *)
      echo "Usage: /etc/init.d/$NAME {start|stop|restart|force-reload}" >&2
      exit 1
      ;;
esac

exit 0
    
