#!/bin/bash
set -e

# Status: in BTS.

cp debian/control{,.in}
patch -p1 < $0
fakeroot debian/rules clean
exit 0

diff -ur gnupg-1.4.0.old/debian/control.in gnupg-1.4.0/debian/control.in
--- gnupg-1.4.0.old/debian/control.in	2005-02-24 08:16:57.000000000 +0100
+++ gnupg-1.4.0/debian/control.in	2005-02-24 08:18:04.000000000 +0100
@@ -3,11 +3,11 @@
 Priority: standard
 Maintainer: James Troup <james@nocrew.org>
 Standards-Version: 3.6.1.1
-Build-Depends: libz-dev, libldap2-dev, libbz2-dev, libcap-dev, libusb-dev, libreadline5-dev, file, gettext, dpatch, mail-transport-agent
+Build-Depends: libz-dev, libldap2-dev, libbz2-dev, libcap-dev [@linux-gnu@], libusb-dev, libreadline5-dev, file, gettext, dpatch, mail-transport-agent
 
 Package: gnupg
 Architecture: any
-Depends: ${shlibs:Depends}, makedev (>= 2.3.1-13) | devfsd | hurd
+Depends: ${shlibs:Depends}, makedev (>= 2.3.1-13) [@linux-gnu@] | devfsd [@linux-gnu@]
 Suggests: gnupg-doc, xloadimage
 Conflicts: gpg-rsa, gpg-rsaref, suidmanager (<< 0.50), gpg-idea (<= 2.2)
 Replaces: gpg-rsa, gpg-rsaref
diff -ur gnupg-1.4.0.old/debian/rules gnupg-1.4.0/debian/rules
--- gnupg-1.4.0.old/debian/rules	2005-02-24 08:16:39.000000000 +0100
+++ gnupg-1.4.0/debian/rules	2005-02-24 08:17:05.000000000 +0100
@@ -58,6 +58,8 @@
 	-rm -rf debian/tmp debian/gpgv-udeb debian/files* debian/*substvars debian/patched
 	-rm -f po/ca.gmo
 	find . -name \*~ | xargs rm -vf
+	sed -e "s/@linux-gnu@/`type-handling any linux-gnu`/g" \
+	< debian/control.in > debian/control
 
 binary-indep:
 
