#!/bin/sh
set -e

ln -sf gnu.png wwwroot/icon/os/gnu.kfreebsd.png
patch -p1 < $0
exit 0

--- awstats-6.5.old/wwwroot/cgi-bin/lib/operating_systems.pm	2005-10-09 16:32:40.000000000 +0200
+++ awstats-6.5/wwwroot/cgi-bin/lib/operating_systems.pm	2005-11-19 21:34:08.000000000 +0100
@@ -44,6 +44,7 @@
 'bsdi',
 'freebsd',
 'openbsd',
+'gnu.kfreebsd',
 'gnu.hurd',
 'unix','x11',
 # Other famous OS
@@ -92,6 +93,7 @@
 'bsdi','bsdi',
 'freebsd','freebsd',
 'openbsd','openbsd',
+'gnu.kfreebsd','gnu.kfreebsd',
 'gnu.hurd','gnu',
 'unix','unix','x11','unix',
 # Other famous OS
@@ -138,6 +140,7 @@
 'bsdi','BSDi',
 'freebsd','FreeBSD',
 'openbsd','OpenBSD',
+'gnu.kfreebsd','GNU/kFreeBSD',
 'gnu','GNU Hurd',
 'unix','Unknown Unix system',
 # Other famous OS
