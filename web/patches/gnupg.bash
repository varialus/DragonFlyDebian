#!/bin/bash
set -e

# Status: in BTS.

patch -p1 < $0
fakeroot debian/rules clean
exit 0

diff -ur gnupg-1.2.5.old/debian/control.in gnupg-1.2.5/debian/control.in
--- gnupg-1.2.5.old/debian/control.in	2005-01-21 12:13:58.000000000 +0100
+++ gnupg-1.2.5/debian/control.in	2005-01-21 12:24:56.000000000 +0100
@@ -3,11 +3,11 @@
 Priority: standard
 Maintainer: James Troup <james@nocrew.org>
 Standards-Version: 3.6.1.1
-Build-Depends: gettext, libz-dev, libldap2-dev, file, libbz2-dev, libcap-dev, dpatch, mail-transport-agent
+Build-Depends: gettext, libz-dev, libldap2-dev, file, libbz2-dev, libcap-dev [@linux-gnu@], dpatch, mail-transport-agent, type-handling (>= 0.2.1)
 
 Package: gnupg
 Architecture: any
-Depends: ${shlibs:Depends}, makedev (>= 2.3.1-13) | devfsd | hurd
+Depends: ${shlibs:Depends}, makedev (>= 2.3.1-13) [@linux-gnu@] | devfsd [@linux-gnu@]
 Suggests: gnupg-doc, xloadimage
 Conflicts: gpg-rsa, gpg-rsaref, suidmanager (<< 0.50), gpg-idea (<= 2.2)
 Replaces: gpg-rsa, gpg-rsaref
diff -ur gnupg-1.2.5.old/debian/rules gnupg-1.2.5/debian/rules
--- gnupg-1.2.5.old/debian/rules	2005-01-21 12:09:30.000000000 +0100
+++ gnupg-1.2.5/debian/rules	2005-01-21 12:14:45.000000000 +0100
@@ -36,6 +36,8 @@
 	-rm -rf debian/tmp debian/files* debian/substvars debian/patched
 	-rm -f po/ca.gmo
 	find . -name \*~ | xargs rm -vf
+	sed -e "s/@linux-gnu@/`type-handling any linux-gnu`/g" \
+	< debian/control.in > debian/control
 
 binary-indep:
 
