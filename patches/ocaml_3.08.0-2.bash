#!/bin/bash -e

cp debian/control{,.in}
cat $0 | patch -p1
which type-handling
fakeroot debian/rules clean
exit 0

diff -x control -Nur ocaml-3.08.0.old/debian/control.in ocaml-3.08.0/debian/control.in
--- ocaml-3.08.0.old/debian/control.in	2004-08-03 00:18:51.000000000 +0200
+++ ocaml-3.08.0/debian/control.in	2004-08-03 00:24:52.000000000 +0200
@@ -2,7 +2,7 @@
 Section: devel
 Priority: optional
 Maintainer: Sven Luther <luther@debian.org>
-Build-Depends: debhelper (>> 4.0.2), tcl8.4-dev, tk8.4-dev, libncurses5-dev, libgdbm-dev, dpatch, bzip2
+Build-Depends: debhelper (>> 4.0.2), tcl8.4-dev, tk8.4-dev, libncurses5-dev, libgdbm-dev, dpatch, bzip2, type-handling (>= 0.2.1)
 Standards-Version: 3.6.1
 
 Package: ocaml-nox
@@ -94,7 +94,7 @@
  you do not require any graphical capilities for your runtime.
 
 Package: ocaml-native-compilers
-Architecture: alpha amd64 arm hppa i386 ia64 powerpc sparc
+Architecture: @native-arches@
 Depends: ocaml-nox (= ${Source-Version}), ocaml-nox-3.08, ${shlibs:Depends}
 Provides: ocaml-best-compilers
 Description: Native code compilers of the ocaml suite (the .opt ones)
diff -x control -Nur ocaml-3.08.0.old/debian/patches/00list ocaml-3.08.0/debian/patches/00list
--- ocaml-3.08.0.old/debian/patches/00list	2004-08-02 23:21:23.000000000 +0200
+++ ocaml-3.08.0/debian/patches/00list	2004-08-03 00:23:40.000000000 +0200
@@ -1,3 +1,4 @@
 versioned_libdir
 objinfo
 camlp4-coq-fix
+kbsd-gnu
diff -x control -Nur ocaml-3.08.0.old/debian/patches/kbsd-gnu.dpatch ocaml-3.08.0/debian/patches/kbsd-gnu.dpatch
--- ocaml-3.08.0.old/debian/patches/kbsd-gnu.dpatch	1970-01-01 01:00:00.000000000 +0100
+++ ocaml-3.08.0/debian/patches/kbsd-gnu.dpatch	2004-08-03 00:24:13.000000000 +0200
@@ -0,0 +1,157 @@
+#! /bin/sh -e 
+## kbsd-gnu.dpatch by Robert Millan <rmh@debian.org>
+##
+## All lines beginning with `## DP:' are a description of the patch.
+## DP: Port to GNU and GNU/k*BSD
+
+if [ $# -ne 1 ]; then
+    echo "`basename $0`: script expects -patch|-unpatch as argument" >&2
+    exit 1
+fi
+case "$1" in
+    -patch) patch -f --no-backup-if-mismatch -p1 < $0;;
+    -unpatch) patch -f --no-backup-if-mismatch -R -p1 < $0;;	
+    *)
+	echo "`basename $0`: script expects -patch|-unpatch as argument" >&2
+	exit 1;;
+esac
+
+exit 0
+@DPATCH@
+diff -x control -ur ocaml-3.08.0.old/asmrun/signals.c ocaml-3.08.0/asmrun/signals.c
+--- ocaml-3.08.0.old/asmrun/signals.c	2004-06-19 18:13:32.000000000 +0200
++++ ocaml-3.08.0/asmrun/signals.c	2004-08-02 23:20:20.000000000 +0200
+@@ -555,21 +555,21 @@
+   }
+ }
+ 
+-#if defined(TARGET_i386) && defined(SYS_linux_elf)
++#if defined(TARGET_i386)
++#if defined(SYS_linux_elf) && defined(__linux__)
+ static void segv_handler(int signo, struct sigcontext sc)
+ {
+   if (is_stack_overflow((char *) sc.cr2))
+     caml_raise_stack_overflow();
+ }
+-#endif
+-
+-#if defined(TARGET_i386) && !defined(SYS_linux_elf)
++#else
+ static void segv_handler(int signo, siginfo_t * info, void * arg)
+ {
+   if (is_stack_overflow((char *) info->si_addr))
+     caml_raise_stack_overflow();
+ }
+ #endif
++#endif
+ 
+ #endif
+ 
+@@ -618,7 +618,7 @@
+     stk.ss_sp = sig_alt_stack;
+     stk.ss_size = SIGSTKSZ;
+     stk.ss_flags = 0;
+-#if defined(TARGET_i386) && defined(SYS_linux_elf)
++#if defined(TARGET_i386) && defined(SYS_linux_elf) && defined(__linux__)
+     act.sa_handler = (void (*)(int)) segv_handler;
+     act.sa_flags = SA_ONSTACK | SA_NODEFER;
+ #else
+diff -x control -ur ocaml-3.08.0.old/config/auto-aux/stackov.c ocaml-3.08.0/config/auto-aux/stackov.c
+--- ocaml-3.08.0.old/config/auto-aux/stackov.c	2003-07-23 09:57:17.000000000 +0200
++++ ocaml-3.08.0/config/auto-aux/stackov.c	2004-08-02 23:19:51.000000000 +0200
+@@ -20,7 +20,7 @@
+ static char sig_alt_stack[SIGSTKSZ];
+ static char * system_stack_top;
+ 
+-#if defined(TARGET_i386) && defined(SYS_linux_elf)
++#if defined(TARGET_i386) && defined(SYS_linux_elf) && defined(__linux__)
+ static void segv_handler(int signo, struct sigcontext sc)
+ {
+   char * fault_addr = (char *) sc.cr2;
+@@ -49,7 +49,7 @@
+   stk.ss_sp = sig_alt_stack;
+   stk.ss_size = SIGSTKSZ;
+   stk.ss_flags = 0;
+-#if defined(TARGET_i386) && defined(SYS_linux_elf)
++#if defined(TARGET_i386) && defined(SYS_linux_elf) && defined(__linux__)
+   act.sa_handler = (void (*)(int)) segv_handler;
+   act.sa_flags = SA_ONSTACK | SA_NODEFER;
+ #else
+diff -x control -ur ocaml-3.08.0.old/configure ocaml-3.08.0/configure
+--- ocaml-3.08.0.old/configure	2004-07-09 17:08:51.000000000 +0200
++++ ocaml-3.08.0/configure	2004-08-02 23:55:48.000000000 +0200
+@@ -268,7 +268,7 @@
+     echo "#define ARCH_CODE32" >> m.h;;
+   cc,alpha*-*-osf*)
+     bytecccompopts="-std1 -ieee";;
+-  gcc,alpha*-*-linux*)
++  gcc,alpha*-*-linux*|alpha*-*-gnu*|alpha*-*-k*bsd*-gnu)
+     if cc="$bytecc" sh ./hasgot -mieee; then
+       bytecccompopts="-mieee $bytecccompopts";
+     fi;;
+@@ -293,7 +293,7 @@
+     bytecccompopts="-fno-defer-pop $gcc_warnings -U_WIN32"
+     exe=".exe"
+     ostype="Cygwin";;
+-  gcc*,x86_64-*-linux*)
++  gcc*,x86_64-*-linux*|x86_64-*-gnu*|x86_64-*-k*bsd*-gnu)
+     bytecccompopts="-fno-defer-pop $gcc_warnings"
+     # Tell gcc that we can use 32-bit code addresses for threaded code
+     echo "#define ARCH_CODE32" >> m.h;;
+@@ -481,7 +481,7 @@
+ 
+ if test $withsharedlibs = "yes"; then
+   case "$host" in
+-    *-*-linux-gnu|*-*-linux|*-*-freebsd[3-9]*)
++    *-*-linux*-gnu|*-*-linux|*-*-gnu*|*-*-k*bsd*-gnu|*-*-freebsd[3-9]*)
+       sharedcccompopts="-fPIC"
+       mksharedlib="$bytecc -shared -o"
+       bytecclinkopts="$bytecclinkopts -Wl,-E"
+@@ -559,15 +559,18 @@
+ 
+ case "$host" in
+   alpha*-*-osf*)                arch=alpha; system=digital;;
+-  alpha*-*-linux*)              arch=alpha; system=linux;;
++  alpha*-*-linux*|alpha*-*-gnu*|alpha*-*-k*bsd*-gnu)
++                                arch=alpha; system=linux;;
+   alpha*-*-freebsd*)            arch=alpha; system=freebsd;;
+   alpha*-*-netbsd*)             arch=alpha; system=netbsd;;
+   alpha*-*-openbsd*)            arch=alpha; system=openbsd;;
+   sparc*-*-sunos4.*)            arch=sparc; system=sunos;;
+   sparc*-*-solaris2.*)          arch=sparc; system=solaris;;
++  sparc*-*-linux*|sparc*-*-gnu*|sparc*-*-k*bsd*-gnu)
++                                arch=sparc; system=linux;;
+   sparc*-*-*bsd*)               arch=sparc; system=bsd;;
+-  sparc*-*-linux*)              arch=sparc; system=linux;;
+-  i[3456]86-*-linux*)           arch=i386; system=linux_`sh ./runtest elf.c`;;
++  i[3456]86-*-linux*|i[3456]86-*-gnu*|i[3456]86-*-k*bsd*-gnu)
++                                arch=i386; system=linux_`sh ./runtest elf.c`;;
+   i[3456]86-*-*bsd*)            arch=i386; system=bsd_`sh ./runtest elf.c`;;
+   i[3456]86-*-nextstep*)        arch=i386; system=nextstep;;
+   i[3456]86-*-solaris*)         arch=i386; system=solaris;;
+@@ -576,15 +579,20 @@
+   mips-*-irix6*)                arch=mips; system=irix;;
+   hppa1.1-*-hpux*)              arch=hppa; system=hpux;;
+   hppa2.0*-*-hpux*)             arch=hppa; system=hpux;;
+-  hppa*-*-linux*)		arch=hppa; system=linux;;
+-  powerpc-*-linux*)             arch=power; model=ppc; system=elf;;
++  hppa*-*-linux*|hppa*-*-gnu*|hppa*-*-k*bsd*-gnu)
++                                arch=hppa; system=linux;;
++  powerpc-*-linux*|powerpc-*-gnu*|powerpc-*-k*bsd*-gnu)
++                                arch=power; model=ppc; system=elf;;
+   powerpc-*-netbsd*)            arch=power; model=ppc; system=bsd;;
+   powerpc-*-rhapsody*)          arch=power; model=ppc; system=rhapsody;;
+   powerpc-*-darwin*)            arch=power; model=ppc; system=rhapsody;;
+-  arm*-*-linux*)                arch=arm; system=linux;;
+-  ia64-*-linux*)                arch=ia64; system=linux;;
++  arm*-*-linux*|arm*-*-gnu*|arm*-*-k*bsd*-gnu)
++                                arch=arm; system=linux;;
++  ia64-*-linux*|ia64-*-gnu*|ia64-*-k*bsd*-gnu)
++                                arch=ia64; system=linux;;
+   ia64-*-freebsd*)              arch=ia64; system=freebsd;;
+-  x86_64-*-linux*)              arch=amd64; system=linux;;
++  x86_64-*-linux*|x86_64-*-gnu*|x86_64-*-k*bsd*-gnu)
++                                arch=amd64; system=linux;;
+   x86_64-*-freebsd*)            arch=amd64; system=freebsd;;
+   x86_64-*-openbsd*)            arch=amd64; system=openbsd;;
+ esac
diff -x control -Nur ocaml-3.08.0.old/debian/rules ocaml-3.08.0/debian/rules
--- ocaml-3.08.0.old/debian/rules	2004-08-02 23:21:23.000000000 +0200
+++ ocaml-3.08.0/debian/rules	2004-08-03 00:24:52.000000000 +0200
@@ -94,6 +94,11 @@
 ifneq "$(wildcard /usr/share/misc/config.guess)" ""
 	cp -f /usr/share/misc/config.guess config/gnu/config.guess
 endif
+
+	cat debian/control.in \
+	| sed "s/@native-arches@/`type-handling \
+		alpha,x86_64,arm,hppa,i386,ia64,powerpc,sparc any`/g" \
+	> debian/control
 	
 	dh_clean debian/README.labltk camlp4/config/Makefile.cnf camlp4/config/Makefile config/m.h config/s.h config/Makefile
 
