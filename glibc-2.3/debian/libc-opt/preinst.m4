#!/bin/sh
changequote({,})
if [ "$1" != abort-upgrade ] && [ "`uname -s`" = Linux ]; then
    # These opt libs require a 2.4.x kernel, and certain
    # types of cpu's.

    kernel_ver=`uname -r`
    cpu=`uname -m`

    if dpkg --compare-versions "$kernel_ver" lt 2.4.0; then
	echo "This package requires you to be running a 2.4.0 kernel. Using an"
	echo "older kernel will cause severe failures so long as this package is"
	echo "installed."
	exit 1
    fi

    touch /etc/ld.so.nohwcap
    echo OPT >> /etc/ld.so.nohwcap

ifelse(OPT,i586,{
    case $cpu in
	i[34]86)
	    echo "Your cpu is not capable of running these libraries. Installing them"
	    echo "will cause severe problems on your system."
	    exit 1
    esac
 },
 OPT,i686,{
    case $cpu in
	i[345]86)
	    echo "Your cpu is not capable of running these libraries. Installing them"
	    echo "will cause severe problems on your system."
	    exit 1
    esac
 },
 OPT,v9,{
    if [ "$cpu" != "sparc64" ]; then
	echo "These libraries require an UltraSPARC in order to be usable."
	echo "Installing them will cause severe problems on your system."
	exit 1
    fi
 },{
    errprint(error: unknown value OPT for macro {OPT}
)m4exit(1)
 })
fi
