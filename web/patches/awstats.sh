#!/bin/sh
set -e

ln -sf gnu.png wwwroot/icon/os/gnukfreebsd.png
patch -p1 < $0
exit 0

diff -ur awstats.old/wwwroot/cgi-bin/lib/operating_systems.pm awstats/wwwroot/cgi-bin/lib/operating_systems.pm
--- awstats.old/wwwroot/cgi-bin/lib/operating_systems.pm	2005-10-09 16:32:40.000000000 +0200
+++ awstats/wwwroot/cgi-bin/lib/operating_systems.pm	2005-11-19 22:21:40.000000000 +0100
@@ -42,6 +42,7 @@
 'hp-ux',
 'netbsd',
 'bsdi',
+'gnu/kfreebsd',									# Must be before freebsd and gnu
 'freebsd',
 'openbsd',
 'gnu.hurd',
@@ -90,6 +91,7 @@
 'hp-ux','hp-ux',
 'netbsd','netbsd',
 'bsdi','bsdi',
+'gnu/kfreebsd','gnukfreebsd',								# Must be before freebsd and gnu
 'freebsd','freebsd',
 'openbsd','openbsd',
 'gnu.hurd','gnu',
@@ -136,6 +138,7 @@
 'hp-ux','HP Unix',
 'netbsd','NetBSD',
 'bsdi','BSDi',
+'gnukfreebsd','GNU/kFreeBSD',
 'freebsd','FreeBSD',
 'openbsd','OpenBSD',
 'gnu','GNU Hurd',
