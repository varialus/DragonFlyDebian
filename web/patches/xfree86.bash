#!/bin/sh
set -e

patch -p1 < $0
for i in `find . -name \*hurd-i386\*` ; do cp $i `echo $i | sed -e "s/hurd/kfreebsd/g"` ; done
exit 0

diff -Nur xfree86-4.3.0.dfsg.1.old/debian/MANIFEST.hurd-i386.in xfree86-4.3.0.dfsg.1/debian/MANIFEST.hurd-i386.in
--- xfree86-4.3.0.dfsg.1.old/debian/MANIFEST.hurd-i386.in	2005-04-04 18:53:56.000000000 +0200
+++ xfree86-4.3.0.dfsg.1/debian/MANIFEST.hurd-i386.in	2005-04-04 18:54:31.000000000 +0200
@@ -440,6 +440,7 @@
 usr/X11R6/bin/XFree86-debug
 usr/X11R6/bin/Xmark
 usr/X11R6/bin/Xnest
+usr/X11R6/bin/Xprt
 usr/X11R6/bin/Xvfb
 usr/X11R6/bin/appres
 usr/X11R6/bin/atobm
@@ -1628,7 +1629,6 @@
 usr/X11R6/lib/modules/input/summa_drv.o
 usr/X11R6/lib/modules/input/tek4957_drv.o
 usr/X11R6/lib/modules/input/void_drv.o
-usr/X11R6/lib/modules/input/wacom_drv.o
 usr/X11R6/lib/modules/libafb.a
 usr/X11R6/lib/modules/libcfb.a
 usr/X11R6/lib/modules/libcfb16.a
@@ -3360,7 +3360,6 @@
 usr/X11R6/man/man4/via.4x
 usr/X11R6/man/man4/vmware.4x
 usr/X11R6/man/man4/void.4x
-usr/X11R6/man/man4/wacom.4x
 usr/X11R6/man/man5/XF86Config-4.5x
 usr/X11R6/man/man7/X.7x
 usr/X11R6/man/man7/X.Org.7x
diff -Nur xfree86-4.3.0.dfsg.1.old/debian/changelog xfree86-4.3.0.dfsg.1/debian/changelog
--- xfree86-4.3.0.dfsg.1.old/debian/changelog	2005-04-04 18:54:03.000000000 +0200
+++ xfree86-4.3.0.dfsg.1/debian/changelog	2005-04-04 19:21:14.000000000 +0200
@@ -1,3 +1,9 @@
+xfree86 (4.3.0.dfsg.1-12+kbsd.1) unreleased; urgency=low
+
+  * Fix Michael's patch to #800 (was truncated by mistake).
+
+ -- Robert Millan <rmh@debian.org>  Mon,  4 Apr 2005 19:20:48 +0200
+
 xfree86 (4.3.0.dfsg.1-12) unstable; urgency=medium
 
   * Urgency set to medium due to fix for release-critical bug #295175
diff -Nur xfree86-4.3.0.dfsg.1.old/debian/control xfree86-4.3.0.dfsg.1/debian/control
--- xfree86-4.3.0.dfsg.1.old/debian/control	2005-04-04 18:54:03.000000000 +0200
+++ xfree86-4.3.0.dfsg.1/debian/control	2005-04-04 18:57:07.000000000 +0200
@@ -1586,7 +1586,7 @@
  xfonts-base, xfonts-100dpi or xfonts-75dpi, and xfonts-scalable packages.
 
 Package: xserver-xfree86
-Architecture: alpha amd64 arm hppa hurd-i386 i386 ia64 m68k mips mipsel netbsd-i386 powerpc sh3 sh4 sparc
+Architecture: alpha amd64 arm hppa i386 hurd-i386 kfreebsd-i386 knetbsd-i386 ia64 m68k mips mipsel netbsd-i386 powerpc sh3 sh4 sparc
 Depends: xserver-common (>= 4.3.0.dfsg.1-5), ${shlibs:Depends}, ${misc:Depends}
 Suggests: discover, mdetect, read-edid, libglide2 (>> 2001.01.26)
 Conflicts: libxfont-xtt
@@ -1620,7 +1620,7 @@
 
 Package: xserver-xfree86-dbg
 Priority: extra
-Architecture: alpha amd64 arm hppa hurd-i386 i386 ia64 m68k mips mipsel netbsd-i386 powerpc sh3 sh4 sparc
+Architecture: alpha amd64 arm hppa i386 hurd-i386 kfreebsd-i386 knetbsd-i386 ia64 m68k mips mipsel netbsd-i386 powerpc sh3 sh4 sparc
 Depends: xserver-common (>= 4.3.0.dfsg.1-5), ${shlibs:Depends}, ${misc:Depends}
 Recommends: xserver-xfree86
 Suggests: discover, mdetect, read-edid
@@ -1637,71 +1637,6 @@
  of the XFree86 X server, but is not mandatory.  See the package description
  of xserver-xfree86 for further information.
 
-Package: xspecs
-Architecture: all
-Conflicts: xbooks
-Description: X protocol, extension, and library technical specifications
- A comprehensive collection of manuals (most in HTML and PostScript as well as
- text format, but some in text format only) documenting the standard
- specifications of the X protocol, extensions to the core protocol, and C
- library interfaces is provided by this package.
- .
- The manuals provided include:
-  * X Window System Protocol
-  * Xlib - C Library Interface
-  * X Toolkit Intrinsics - C Library Interface
-  * Athena Widget Set - C Library Interface
-  * Bitmap Distribution Format (BDF)
-  * Compound Text Encoding (CTEXT)
-  * X Display Power Management Signaling (DPMS) Extension Protocol
-  * X Display Power Management Signaling (DPMS) Extension Library
-  * The X Font Service Protocol
-  * Inter-Client Communications Conventions Manual (ICCCM)
-  * Inter-Client Exchange (ICE) Protocol
-  * Inter-Client Exchange (ICE) Library
-  * The RX Document
-  * X Session Management Library
-  * X Session Management Protocol
-  * X Display Manager Control Protocol (XDMCP)
-  * The Input Method Protocol
-  * X Logical Font Description Conventions (XLFD)
-  * Extending X for Double-Buffering, Multi-Buffering, and Stereo
-  * Double Buffer Extension (DBE) Protocol
-  * Double Buffer Extension (DBE) Library
-  * Low Bandwidth X (LBX) Extension
-  * LBX X Consortium Algorithms
-  * MIT-SHM - The MIT Shared Memory Extension
-  * Record Extension Protocol Specification
-  * X Record Extension Library
-  * Security Extension Specification
-  * X Nonrectangular Window Shape Extension Protocol
-  * X Nonrectangular Window Shape Extension Library
-  * X Synchronization Extension Protocol
-  * X Synchronization Extension Library
-  * XC-MISC Extension
-  * XTEST Extension Protocol
-  * XTEST Extension Library
-  * X Input Device Extension Library
-  * X11 Input Extension Porting Document
-  * X11 Input Extension Protocol Specification
-  * Xmu Library
-  * Analysis of the X Protocol for Security Concerns
-  * Description of the Application Group Extension Implementation
-  * Definition of the Porting Layer for the X v11 Sample Server
-  * The X Font Library
-  * Security Extension Server Design
-  * X11R6 Sample Implementation Frame Work
-  * X Locale Database Definition
-  * The XIM Transport Specification
-  * A Flexible Remote Execution Protocol Based on rsh
-  * Xlib and X Protocol Test Suite: User Guide for the X Test Suite
-  * Font Server Implementation Overview
-  * X Transport Interface
-  * the Application Group (APPGROUP) extension
-  * the BIG-REQUESTS extension
- .
- This package supersedes the xbooks package in older versions of Debian.
-
 Package: xterm
 Architecture: any
 Depends: xlibs-data, ${shlibs:Depends}, ${misc:Depends}
diff -Nur xfree86-4.3.0.dfsg.1.old/debian/patches/800_gnu_config.diff xfree86-4.3.0.dfsg.1/debian/patches/800_gnu_config.diff
--- xfree86-4.3.0.dfsg.1.old/debian/patches/800_gnu_config.diff	2005-04-04 18:53:57.000000000 +0200
+++ xfree86-4.3.0.dfsg.1/debian/patches/800_gnu_config.diff	2005-04-04 18:54:31.000000000 +0200
@@ -1,6 +1,7 @@
 $Id: 800_gnu_config.diff 1799 2004-09-06 10:13:18Z fabbione $
 
-Add Debian-specific configuration to gnu.cf (mostly derived from linux.cf).
+Add Debian-specific configuration to gnu.cf and resync it along with
+gnuLib.{tmpl,rules} (mostly derived from their Linux counterparts).
 
 This patch by Marcus Brinkmann <brinkmd@debian.org>, Robert Millan
 <zeratul2@wanadoo.es>, Daniel Stone <dstone@trinity.unimelb.edu.au>,
@@ -12,9 +13,10 @@
 # define HasKatmaiSupport	NO
 #endif
 
---- xc/config/cf/gnu.cf~	2004-07-27 13:17:07.000000000 +0200
-+++ xc/config/cf/gnu.cf	2004-07-27 17:14:26.000000000 +0200
-@@ -18,6 +18,154 @@
+diff -Naur xc.orig/config/cf/gnu.cf xc/config/cf/gnu.cf
+--- xc/config/cf/gnu.cf~	2005-02-16 01:18:29.701334208 +0100
++++ xc/config/cf/gnu.cf	2005-02-16 01:08:35.000000000 +0100
+@@ -18,9 +18,157 @@
  #endif
  XCOMM operating system:  OSName (OSMajorVersion./**/OSMinorVersion./**/OSTeenyVersion)
  
@@ -168,7 +170,11 @@
 +
  #define GNUSourceDefines      -D_POSIX_C_SOURCE=199309L \
                                -D_POSIX_SOURCE -D_XOPEN_SOURCE \
-                               -D_BSD_SOURCE -D_SVID_SOURCE
+-                              -D_BSD_SOURCE -D_SVID_SOURCE
++                              -D_BSD_SOURCE -D_SVID_SOURCE -D_GNU_SOURCE
+ 
+ XCOMM XXXMB: What about _GNU_SOURCE, see Linux/UseInstalled?
+ 
 @@ -66,6 +214,14 @@
  #define HasNCurses		YES
  #endif
@@ -210,3 +216,160 @@
  #define ConnectionFlags		-DUNIXCONN -DTCPCONN
  
  #ifndef StaticLibrary
+@@ -161,6 +325,12 @@
+ 
+ #include <gnuLib.rules>
+ 
++#define XInputDrivers           mouse keyboard /* acecad */ calcomp citron \
++                                digitaledge dmc dynapro elographics tek4957 \
++                                microtouch mutouch penmount spaceorb summa \
++                                void magellan /* magictouch */ hyperpen \
++                                jamstudio fpit palmax
++
+ XCOMM XXX Might need this if they are not careful with slashes.
+ XCOMM #define DirFailPrefix -
+ 
+diff -Naur xc.orig/config/cf/gnuLib.rules xc/config/cf/gnuLib.rules
+--- xc/config/cf/gnuLib.rules~	2002-01-16 01:39:59.000000000 +0100
++++ xc/config/cf/gnuLib.rules	2005-02-16 01:10:34.000000000 +0100
+@@ -158,6 +158,45 @@
+ 
+ #endif /* SharedDepLibraryTarget */
+ 
++/*
++ * SharedDepCplusplusLibraryTarget - generate rules to create a shared library.
++ */
++#ifndef SharedDepCplusplusLibraryTarget
++#ifdef UseInstalled
++#ifndef LinkBuildSonameLibrary
++#define LinkBuildSonameLibrary(lib) true
++#endif
++#else
++#ifndef LinkBuildSonameLibrary
++#define LinkBuildSonameLibrary(lib) (RemoveFile($(BUILDLIBDIR)/lib); \
++	cd $(BUILDLIBDIR); $(LN) $(BUILDINCTOP)/$(CURRENT_DIR)/lib .)
++#endif
++#endif
++
++#define SharedDepCplusplusLibraryTarget(libname,rev,deplist,solist,down,up) @@\
++AllTarget(Concat(lib,libname.so.rev))					@@\
++									@@\
++Concat(lib,libname.so.rev):  deplist $(EXTRALIBRARYDEPS)		@@\
++	$(RM) $@~							@@\
++	@SONAME=`echo $@ | sed 's/\.[^\.]*$$//'`; set -x; \		@@\
++		(cd down; $(CXX) -o up/$@~ $(SHLIBLDFLAGS) -Wl,-soname,$$SONAME solist $(REQUIREDLIBS) BaseShLibReqs); \ @@\
++		$(RM) $$SONAME; $(LN) $@ $$SONAME; \			@@\
++		LinkBuildSonameLibrary($$SONAME)			@@\
++	$(RM) $@ 							@@\
++	$(MV) $@~ $@							@@\
++	@if $(SOSYMLINK); then (set -x; \				@@\
++	  $(RM) Concat(lib,libname.so); \				@@\
++	  $(LN) $@ Concat(lib,libname.so)); fi				@@\
++	LinkBuildLibrary($@)						@@\
++	LinkBuildLibraryMaybe(Concat(lib,libname.so),$(SOSYMLINK))	@@\
++									@@\
++clean::									@@\
++	@MAJREV=`expr rev : '\([^.]*\)'`; \				@@\
++	set -x; $(RM) Concat(lib,libname.so.$$MAJREV)			@@\
++	$(RM) Concat(lib,libname.so.rev) Concat(lib,libname.so)
++
++#endif /* SharedDepCplusplusLibraryTarget */
++
+ #ifndef SharedDepModuleTarget
+ #define SharedDepModuleTarget(name,deps,solist)				@@\
+ AllTarget(name)								@@\
+@@ -173,6 +212,23 @@
+ 
+ #endif /* SharedDepModuleTarget */
+ 
++# ifndef SharedDriModuleTarget
++#  define SharedDriModuleTarget(name,deps,solist)			@@\
++AllTarget(name)								@@\
++									@@\
++name: deps								@@\
++	$(RM) $@~ $@.map						@@\
++	@(echo 'DRI_MODULE { global: __dri*; local: *; };' > $@.map)	@@\
++	$(CC) -o $@~ -Wl,--version-script=$@.map $(SHLIBLDFLAGS) solist $(REQUIREDLIBS) BaseShLibReqs @@\
++	$(RM) $@ $@.map							@@\
++	$(MV) $@~ $@							@@\
++									@@\
++clean::									@@\
++	$(RM) name							@@\
++	$(RM) name.map
++
++# endif /* SharedDriModuleTarget */
++
+ /*
+  * SharedLibraryDataTarget - generate rules to create shlib data file;
+  */
+diff -Naur xc.orig/config/cf/gnuLib.tmpl xc/config/cf/gnuLib.tmpl
+--- xc/config/cf/gnuLib.tmpl~	2000-11-14 19:20:31.000000000 +0100
++++ xc/config/cf/gnuLib.tmpl	2005-02-16 01:10:34.000000000 +0100
+@@ -16,15 +16,55 @@
+ 
+ #define CplusplusLibC
+ 
+-#define SharedX11Reqs
+-#define SharedOldXReqs	$(LDPRELIB) $(XLIBONLY)
+-#define SharedXtReqs	$(LDPRELIB) $(XLIBONLY) $(SMLIB) $(ICELIB)
+-#define SharedXaw6Reqs	$(LDPRELIB) $(XMULIB) $(XTOOLLIB) $(XLIB)
+-#define SharedXawReqs	$(LDPRELIB) $(XMULIB) $(XTOOLLIB) $(XPMLIB) $(XLIB)
+-#define SharedXmuReqs	$(LDPRELIB) $(XTOOLLIB) $(XLIB)
+-#define SharedXextReqs	$(LDPRELIB) $(XLIBONLY)
+-#define SharedXiReqs	$(LDPRELIB) $(XLIB)
+-#define SharedPexReqs	$(LDPRELIB) $(XLIBONLY) MathLibrary
+-#define SharedXtstReqs	$(LDPRELIB) $(XLIB)
+-#define SharedXieReqs	$(LDPRELIB) $(XLIBONLY)
+-#define SharedSMReqs	$(LDPRELIB) $(ICELIB)
++#if ThreadedX
++# ifndef SharedThreadReqs
++#   define SharedThreadReqs -lpthread
++# endif
++#else
++# ifndef SharedThreadReqs
++#   define SharedThreadReqs
++# endif
++#endif
++
++#define SharedX11Reqs	  SharedThreadReqs
++#define SharedOldXReqs	  $(LDPRELIB) $(XLIBONLY)
++#define SharedXtReqs	  $(LDPRELIB) $(XLIBONLY) $(SMLIB) $(ICELIB) SharedThreadReqs
++#define SharedXaw6Reqs	  $(LDPRELIB) $(XMULIB) $(XTOOLLIB) $(XLIB)
++#define SharedXawReqs	  $(LDPRELIB) $(XMULIB) $(XTOOLLIB) $(XPMLIB) $(XLIB)
++#define SharedXmuReqs	  $(LDPRELIB) $(XTOOLLIB) $(XLIB)
++#define SharedXextReqs	  $(LDPRELIB) $(XLIBONLY)
++#define SharedXiReqs	  $(LDPRELIB) $(XLIB)
++#define SharedXrenderReqs $(LDPRELIB) $(EXTENSIONLIB) $(XLIB)
++#define SharedPexReqs	  $(LDPRELIB) $(XLIBONLY) MathLibrary
++#define SharedXtstReqs	  $(LDPRELIB) $(XLIB)
++#define SharedXieReqs	  $(LDPRELIB) $(XLIBONLY)
++#define SharedSMReqs	  $(LDPRELIB) $(ICELIB)
++#define SharedGLUReqs	  $(LDPRELIB) $(GLXLIB)
++#define SharedXmuuReqs	  $(LDPRELIB) $(XONLYLIB)
++#define SharedXpReqs	  $(LDPRELIB) $(XLIB)
++#define SharedXpmReqs	  $(LDPRELIB) $(XONLYLIB)
++#define SharedXrandrReqs  $(LDPRELIB) $(XRENDERLIB) $(XLIB)
++#define SharedDPSReqs	  $(LDPRELIB) $(XTOOLLIB) $(XLIB)
++#define SharedDPSTKReqs	  $(LDPRELIB) $(DPSLIB) $(XLIB) MathLibrary
++#define SharedXvReqs		  $(LDPRELIB) $(XLIB)
++
++#if GlxUseBuiltInDRIDriver
++#define ExtraSharedGLReqs /**/
++#else
++#define ExtraSharedGLReqs -ldl
++#endif
++#define SharedGLReqs	  $(LDPRELIB) $(XLIB) ExtraSharedGLReqs
++
++#ifndef SharedXReqs
++# define SharedXReqs $(XTOOLLIB) $(XPLIB) $(XLIB) $(LDPOSTLIBS) SharedThreadReqs
++#endif
++
++#ifndef SharedXmReqs
++# define SharedXmReqs $(LDPRELIBS) SharedXReqs -lc
++#endif
++
++#ifndef SharedTtReqs
++# define SharedTtReqs $(LDPRELIBS) SharedXReqs $(CXXLIB) SharedThreadReqs
++#endif
++
++#define NoMessageCatalog
diff -Nur xfree86-4.3.0.dfsg.1.old/debian/patches/999_kbsd-gnu.diff xfree86-4.3.0.dfsg.1/debian/patches/999_kbsd-gnu.diff
--- xfree86-4.3.0.dfsg.1.old/debian/patches/999_kbsd-gnu.diff	1970-01-01 01:00:00.000000000 +0100
+++ xfree86-4.3.0.dfsg.1/debian/patches/999_kbsd-gnu.diff	2005-04-04 18:57:07.000000000 +0200
@@ -0,0 +1,1532 @@
+diff -Nur xc.old/config/cf/Imake.cf xc/config/cf/Imake.cf
+--- xc.old/config/cf/Imake.cf	2005-02-19 15:51:13.000000000 +0100
++++ xc/config/cf/Imake.cf	2005-02-19 15:57:56.000000000 +0100
+@@ -219,6 +219,11 @@
+ #define GNUFreeBSDArchitecture
+ #endif
+ 
++/* Systems based on kernel of NetBSD */
++#if defined(__NetBSD__) || defined(__NetBSD_kernel__)
++#define kNetBSDArchitecture
++#endif
++
+ #ifdef __FreeBSD__
+ # define MacroIncludeFile <FreeBSD.cf>
+ # define MacroFile FreeBSD.cf
+@@ -240,6 +245,11 @@
+ # endif
+ #endif /* __FreeBSD__ */
+ 
++/* Systems based on kernel of FreeBSD */
++#if defined(__FreeBSD__) || defined(__FreeBSD_kernel__)
++#define kFreeBSDArchitecture
++#endif
++
+ #ifdef AMOEBA
+  /* Should be before the 'sun' entry because we may be cross-compiling */
+ # define MacroIncludeFile <Amoeba.cf>
+@@ -927,10 +937,20 @@
+ #define i386Architecture
+ #endif /* minix */
+ 
+-#ifdef MACH
+-#ifdef __GNU__
++/* Systems with GNU libc and userland */
++#if defined(__GNU__) || \
++  defined(__GLIBC__)
++#define GNUArchitecture
+ #define MacroIncludeFile <gnu.cf>
+ #define MacroFile gnu.cf
++#ifdef __i386__
++#define i386Architecture
++#endif
++#endif
++
++#ifdef MACH
++#ifdef __GNU__
++/* Mach-based GNU system */
+ #define GNUMachArchitecture
+ #else
+ #define MacroIncludeFile <mach.cf>
+diff -Nur xc.old/config/cf/gnu.cf xc/config/cf/gnu.cf
+--- xc.old/config/cf/gnu.cf	2005-02-19 15:51:13.000000000 +0100
++++ xc/config/cf/gnu.cf	2005-02-19 15:58:03.000000000 +0100
+@@ -4,6 +4,10 @@
+ #define OSName			DefaultOSName
+ #endif
+ 
++#ifndef DefaultOSName
++#define DefaultOSName		GNU
++#endif
++
+ #ifndef OSVendor
+ #define OSVendor		/**/
+ #endif
+@@ -279,7 +283,19 @@
+ #define VarDbDirectory		$(VARDIR)/lib
+ 
+ XCOMM i386Architecture
++#ifndef DefaultGcc2i386Opt
++#define DefaultGcc2i386Opt	-O2
++#endif
+ #define OptimizedCDebugFlags	DefaultGcc2i386Opt
++#ifndef HasGcc
++#define HasGcc			YES
++#endif
++#ifndef HasGcc2
++#define HasGcc2			YES
++#endif
++#ifndef HasGcc3
++#define HasGcc3			YES
++#endif
+ #define GNUMachineDefines	-D__i386__
+ #define ServerOSDefines		XFree86ServerOSDefines -DDDXTIME -DPART_NET
+ #define ServerExtraDefines	-DGCCUSESGAS XFree86ServerDefines
+@@ -287,7 +303,7 @@
+ #define VendorHasX11R6_3libXext	YES
+ 
+ #ifndef StandardDefines
+-#define StandardDefines		-D__GNU__ GNUMachineDefines GNUSourceDefines
++#define StandardDefines		GNUMachineDefines GNUSourceDefines
+ #endif
+ 
+ #define DlLibrary		-rdynamic -ldl
+@@ -317,6 +333,21 @@
+ 
+ #define XserverNeedsSetUID	YES
+ 
++#if defined(kFreeBSDArchitecture)
++# ifdef i386Architecture
++#  ifndef XFree86ConsoleDefines
++#    define XFree86ConsoleDefines -DSYSCONS_SUPPORT -DPCVT_SUPPORT
++#  endif
++# endif
++#endif
++#if defined(kNetBSDArchitecture)
++# ifdef i386Architecture
++#  ifndef XFree86ConsoleDefines
++#    define XFree86ConsoleDefines -DPCCONS_SUPPORT -DPCVT_SUPPORT -DWSCONS_SUPPORT
++#  endif
++# endif
++#endif
++
+ #include <gnuLib.rules>
+ 
+ #define XInputDrivers           mouse keyboard /* acecad */ calcomp citron \
+diff -Nur xc.old/config/cf/xfree86.cf xc/config/cf/xfree86.cf
+--- xc.old/config/cf/xfree86.cf	2005-02-19 15:51:13.000000000 +0100
++++ xc/config/cf/xfree86.cf	2005-02-19 15:57:56.000000000 +0100
+@@ -1719,14 +1719,7 @@
+ #define SystemV4		NO
+ #endif
+ #ifndef BuildScanpci
+-# if SystemV || SystemV4 || \
+-    defined(LinuxArchitecture) || \
+-    defined(i386BsdArchitecture) || defined(LynxOSArchitecture) || \
+-    defined(OS2Architecture) || defined(GNUMachArchitecture)
+ #   define BuildScanpci		YES
+-# else
+-#   define BuildScanpci		NO
+-# endif
+ #endif
+ 
+ #ifndef CompressAllFonts
+diff -Nur xc.old/programs/Xserver/hw/xfree86/Imakefile xc/programs/Xserver/hw/xfree86/Imakefile
+--- xc.old/programs/Xserver/hw/xfree86/Imakefile	2003-02-17 18:06:40.000000000 +0100
++++ xc/programs/Xserver/hw/xfree86/Imakefile	2005-02-19 15:58:03.000000000 +0100
+@@ -124,13 +124,13 @@
+ DPI75USFONTPATH=\"$(LIBDIR)/fonts/75dpi/:unscaled\"
+ DPI100USFONTPATH=\"$(LIBDIR)/fonts/100dpi/:unscaled\"
+ 
+-#ifdef FreeBSDArchitecture
++#ifdef KFreeBSDArchitecture
+   FREEBSDMOUSEDEV="    Option	\"Device\"	\"/dev/mse0\""
+ #else
+   FREEBSDMOUSEDEV="XCOMM    Option	\"Device\"	\"/dev/mse0\""
+ #endif
+ 
+-#if defined(i386BsdArchitecture)&&defined(NetBSDArchitecture)
++#if defined(i386BsdArchitecture)&&defined(KNetBSDArchitecture)
+ #  if (OSMajorVersion >= 1) && (OSMinorVersion >= 1)
+   NETBSDOLDMOUSEDEV="XCOMM    Option	\"Device\"	\"/dev/mms0\""
+   NETBSDNEWMOUSEDEV="    Option	\"Device\"	\"/dev/lms0\""
+diff -Nur xc.old/programs/Xserver/hw/xfree86/common/Imakefile xc/programs/Xserver/hw/xfree86/common/Imakefile
+--- xc.old/programs/Xserver/hw/xfree86/common/Imakefile	2005-02-19 15:51:05.000000000 +0100
++++ xc/programs/Xserver/hw/xfree86/common/Imakefile	2005-02-19 15:58:03.000000000 +0100
+@@ -18,7 +18,7 @@
+ #endif /* GNUMachArchitecture */
+ #else
+ # if defined(i386BsdArchitecture) || defined(AlphaBsdArchitecture) \
+-	|| defined(OpenBSDArchitecture) || defined(NetBSDArchitecture)
++	|| defined(KOpenBSDArchitecture) || defined(KNetBSDArchitecture)
+         KBD = xf86KbdBSD
+ # else
+ #  ifdef LinuxArchitecture
+diff -Nur xc.old/programs/Xserver/hw/xfree86/common/compiler.h xc/programs/Xserver/hw/xfree86/common/compiler.h
+--- xc.old/programs/Xserver/hw/xfree86/common/compiler.h	2005-02-19 15:51:12.000000000 +0100
++++ xc/programs/Xserver/hw/xfree86/common/compiler.h	2005-02-19 15:58:03.000000000 +0100
+@@ -30,6 +30,7 @@
+ # endif
+ 
+ # define _COMPILER_H
++#include "kbsd.h"
+ 
+ /* Allow drivers to use the GCC-supported __inline__ and/or __inline. */
+ # ifndef __inline__
+@@ -196,9 +197,9 @@
+ #    endif /* (__FreeBSD__ || __OpenBSD__ ) && !DO_PROTOTYPES */
+ 
+ 
+-#if defined(__NetBSD__)
++#if defined(__NetBSD_kernel__)
+ #include <machine/pio.h>
+-#endif /* __NetBSD__ */
++#endif /* __NetBSD_kernel__ */
+ 
+ /*
+  * inline functions to do unaligned accesses
+diff -Nur xc.old/programs/Xserver/hw/xfree86/common/kbsd.h xc/programs/Xserver/hw/xfree86/common/kbsd.h
+--- xc.old/programs/Xserver/hw/xfree86/common/kbsd.h	1970-01-01 01:00:00.000000000 +0100
++++ xc/programs/Xserver/hw/xfree86/common/kbsd.h	2005-02-19 15:58:03.000000000 +0100
+@@ -0,0 +1,19 @@
++/* Compatibility with k*BSD-based non-BSD systems (e.g. GNU/k*BSD) */
++
++#if defined(__FreeBSD__) && !defined(__FreeBSD_kernel__)
++# define __FreeBSD_kernel__ __FreeBSD__
++#endif
++#ifdef __FreeBSD_kernel__
++# include <osreldate.h>
++# ifndef __FreeBSD_kernel_version
++#  define __FreeBSD_kernel_version __FreeBSD_version
++# endif
++#endif
++
++#if defined(__NetBSD__) && !defined(__NetBSD_kernel__)
++# define __NetBSD_kernel__ __NetBSD__
++#endif
++
++#if defined(__OpenBSD__) && !defined(__OpenBSD_kernel__)
++# define __OpenBSD_kernel__ __OpenBSD__
++#endif
+diff -Nur xc.old/programs/Xserver/hw/xfree86/common/xf86Config.c xc/programs/Xserver/hw/xfree86/common/xf86Config.c
+--- xc.old/programs/Xserver/hw/xfree86/common/xf86Config.c	2005-02-19 15:51:10.000000000 +0100
++++ xc/programs/Xserver/hw/xfree86/common/xf86Config.c	2005-02-19 15:58:03.000000000 +0100
+@@ -27,6 +27,7 @@
+ #include "xf86_OSlib.h"
+ 
+ #include "globals.h"
++#include "kbsd.h"
+ 
+ #ifdef XINPUT
+ #include "xf86Xinput.h"
+@@ -43,7 +44,7 @@
+ #endif
+ 
+ #if (defined(i386) || defined(__i386__)) && \
+-    (defined(__FreeBSD__) || defined(__NetBSD__) || defined(linux) || \
++    (defined(__FreeBSD_kernel__) || defined(__NetBSD_kernel__) || defined(linux) || \
+      (defined(SVR4) && !defined(sun)) || defined(__GNU__))
+ #define SUPPORT_PC98
+ #endif
+diff -Nur xc.old/programs/Xserver/hw/xfree86/common/xf86Configure.c xc/programs/Xserver/hw/xfree86/common/xf86Configure.c
+--- xc.old/programs/Xserver/hw/xfree86/common/xf86Configure.c	2003-01-18 08:27:13.000000000 +0100
++++ xc/programs/Xserver/hw/xfree86/common/xf86Configure.c	2005-02-19 15:58:03.000000000 +0100
+@@ -51,6 +51,7 @@
+ #include "xf86Sbus.h"
+ #endif
+ #include "globals.h"
++#include "kbsd.h"
+ 
+ typedef struct _DevToConfig {
+     GDevRec GDev;
+@@ -79,7 +80,7 @@
+ #elif defined(__QNXNTO__)
+ static char *DFLT_MOUSE_PROTO = "OSMouse";
+ static char *DFLT_MOUSE_DEV = "/dev/devi/mouse0";
+-#elif defined(__FreeBSD__)
++#elif defined(__FreeBSD_kernel__)
+ static char *DFLT_MOUSE_DEV = "/dev/sysmouse";
+ static char *DFLT_MOUSE_PROTO = "auto";
+ #else
+diff -Nur xc.old/programs/Xserver/hw/xfree86/common/xf86Globals.c xc/programs/Xserver/hw/xfree86/common/xf86Globals.c
+--- xc.old/programs/Xserver/hw/xfree86/common/xf86Globals.c	2005-02-19 15:51:10.000000000 +0100
++++ xc/programs/Xserver/hw/xfree86/common/xf86Globals.c	2005-02-19 15:58:03.000000000 +0100
+@@ -17,6 +17,7 @@
+ #include "xf86Parser.h"
+ #include "xf86Xinput.h"
+ #include "xf86InPriv.h"
++#include "kbsd.h"
+ 
+ /* Globals that video drivers may access */
+ 
+@@ -94,7 +95,7 @@
+ #if defined(SVR4) && defined(i386)
+ 	FALSE,		/* panix106 */
+ #endif
+-#if defined(__OpenBSD__) || defined(__NetBSD__)
++#if defined(__OpenBSD_kernel__) || defined(__NetBSD_kernel__)
+ 	0,		/* wskbdType */
+ #endif
+ 	NULL,		/* pMouse */
+diff -Nur xc.old/programs/Xserver/hw/xfree86/common/xf86KbdBSD.c xc/programs/Xserver/hw/xfree86/common/xf86KbdBSD.c
+--- xc.old/programs/Xserver/hw/xfree86/common/xf86KbdBSD.c	2002-05-22 23:38:27.000000000 +0200
++++ xc/programs/Xserver/hw/xfree86/common/xf86KbdBSD.c	2005-02-19 15:58:03.000000000 +0100
+@@ -36,6 +36,7 @@
+ #include "xf86_OSlib.h"
+ #include "atKeynames.h"
+ #include "xf86Keymap.h"
++#include "kbsd.h"
+ 
+ #if (defined(SYSCONS_SUPPORT) || defined(PCVT_SUPPORT)) && defined(GIO_KEYMAP)
+ #define KD_GET_ENTRY(i,n) \
+@@ -267,7 +268,7 @@
+ #endif
+       };
+ 
+-#ifdef __OpenBSD__
++#ifdef __OpenBSD_kernel__
+ /* don't mark AltR and  CtrlR for remapping, since they 
+  * cannot be remapped by pccons */
+ static unsigned char pccons_remap[128] = {
+@@ -393,7 +394,7 @@
+ 
+ #ifdef PCCONS_SUPPORT
+   case PCCONS:
+-#if defined(__OpenBSD__)
++#if defined(__OpenBSD_kernel__)
+     /*
+      * on OpenBSD, the pccons keymap is programmable, too
+      */
+@@ -493,7 +494,7 @@
+ 	ErrorF("Can't read pccons keymap\n");
+       }
+     }
+-#endif /* __OpenBSD__ */
++#endif /* __OpenBSD_kernel__ */
+   break;
+ #endif
+ 
+diff -Nur xc.old/programs/Xserver/hw/xfree86/common/xf86Privstr.h xc/programs/Xserver/hw/xfree86/common/xf86Privstr.h
+--- xc.old/programs/Xserver/hw/xfree86/common/xf86Privstr.h	2003-02-20 05:05:14.000000000 +0100
++++ xc/programs/Xserver/hw/xfree86/common/xf86Privstr.h	2005-02-19 15:58:03.000000000 +0100
+@@ -14,6 +14,7 @@
+ 
+ #include "xf86Pci.h"
+ #include "xf86str.h"
++#include "kbsd.h"
+ 
+ /* PCI probe flags */
+ 
+@@ -74,7 +75,7 @@
+ #if defined(SVR4) && defined(i386)
+     Bool		panix106;
+ #endif  /* SVR4 && i386 */
+-#if defined(__OpenBSD__) || defined(__NetBSD__)
++#if defined(__OpenBSD_kernel__) || defined(__NetBSD_kernel__)
+     int                 wsKbdType;
+ #endif
+ 
+@@ -97,7 +98,8 @@
+     /* graphics part */
+     Bool		sharedMonitor;
+     ScreenPtr		currentScreen;
+-#ifdef CSRG_BASED
++#if defined(CSRG_BASED) || defined(__FreeBSD_kernel__) || \
++ defined(__NetBSD_kernel__) || defined(__OpenBSD_kernel__)
+     int			screenFd;	/* fd for memory mapped access to
+ 					 * vga card */
+     int			consType;	/* Which console driver? */
+@@ -190,7 +192,8 @@
+ #define XCOMP	((unsigned long) 0x00008000)
+ 
+ /* BSD console driver types (consType) */
+-#ifdef CSRG_BASED
++#if defined(CSRG_BASED) || defined(__FreeBSD_kernel__) || \
++ defined(__NetBSD_kernel__) || defined(__OpenBSD_kernel__)
+ #define PCCONS		   0
+ #define CODRV011	   1
+ #define CODRV01X	   2
+diff -Nur xc.old/programs/Xserver/hw/xfree86/drivers/i810/i830_driver.c xc/programs/Xserver/hw/xfree86/drivers/i810/i830_driver.c
+--- xc.old/programs/Xserver/hw/xfree86/drivers/i810/i830_driver.c	2005-02-19 15:51:00.000000000 +0100
++++ xc/programs/Xserver/hw/xfree86/drivers/i810/i830_driver.c	2005-02-19 15:58:03.000000000 +0100
+@@ -3374,8 +3374,10 @@
+    RestoreHWState(pScrn);
+    RestoreBIOSMemSize(pScrn);
+    I830UnbindGARTMemory(pScrn);
++#ifdef XF86DRI
+    if (pI830->AccelInfoRec)
+       pI830->AccelInfoRec->NeedToSync = FALSE;
++#endif
+ }
+ 
+ /*
+diff -Nur xc.old/programs/Xserver/hw/xfree86/etc/Imakefile xc/programs/Xserver/hw/xfree86/etc/Imakefile
+--- xc.old/programs/Xserver/hw/xfree86/etc/Imakefile	2005-02-19 15:51:13.000000000 +0100
++++ xc/programs/Xserver/hw/xfree86/etc/Imakefile	2005-02-19 15:58:03.000000000 +0100
+@@ -80,8 +80,8 @@
+        SRCS2 = scanpci.c
+ 
+ #if defined(i386Architecture) && \
+-    (defined(OpenBSDArchitecture) || \
+-	(defined(NetBSDArchitecture) && \
++    (defined(KOpenBSDArchitecture) || \
++	(defined(KNetBSDArchitecture) && \
+ 	 ((OSMajorVersion == 1 && OSMinorVersion >= 1) || \
+ 	  OSMajorVersion >= 2)))
+ DEFINES = -DUSE_I386_IOPL
+@@ -113,7 +113,7 @@
+ #if 0 /*BuildMatchagp*/
+        SRCS5 = matchagp.c
+ 
+-# if defined(OpenBSDArchitecture) || defined(NetBSDArchitecture) \
++# if defined(KOpenBSDArchitecture) || defined(KNetBSDArchitecture) \
+     && ((OSMajorVersion == 1 && OSMinorVersion >= 1) || OSMajorVersion >= 2)
+ DEFINES = -DUSE_I386_IOPL
+ SYS_LIBRARIES = -li386
+diff -Nur xc.old/programs/Xserver/hw/xfree86/input/joystick/Imakefile xc/programs/Xserver/hw/xfree86/input/joystick/Imakefile
+--- xc.old/programs/Xserver/hw/xfree86/input/joystick/Imakefile	2000-11-06 20:24:07.000000000 +0100
++++ xc/programs/Xserver/hw/xfree86/input/joystick/Imakefile	2005-02-19 15:58:03.000000000 +0100
+@@ -15,7 +15,7 @@
+         ARCH_JSTK = ../os-support/linux/lnx_jstk.o
+ #endif
+ 
+-#if defined(FreeBSDArchitecture) || defined(NetBSDArchitecture) || defined(OpenBSDArchitecture)
++#if defined(KFreeBSDArchitecture) || defined(KNetBSDArchitecture) || defined(KOpenBSDArchitecture)
+         ARCH_JSTK = ../os-support/bsd/bsd_jstk.o
+ #endif
+ 
+diff -Nur xc.old/programs/Xserver/hw/xfree86/input/wacom/wcmCommon.c xc/programs/Xserver/hw/xfree86/input/wacom/wcmCommon.c
+--- xc.old/programs/Xserver/hw/xfree86/input/wacom/wcmCommon.c	2005-02-19 15:51:05.000000000 +0100
++++ xc/programs/Xserver/hw/xfree86/input/wacom/wcmCommon.c	2005-02-19 15:58:03.000000000 +0100
+@@ -825,7 +825,11 @@
+ 	if (pChannel->nSamples < 4) ++pChannel->nSamples;
+ 
+ 	/* don't send the first sample due to the first USB package issue*/
+-	if ( (pChannel->nSamples != 1) || (common->wcmDevCls != &gWacomUSBDevice) )
++	if ( (pChannel->nSamples != 1)
++#ifdef LINUX_INPUT
++	     || (common->wcmDevCls != &gWacomUSBDevice)
++#endif
++	     )
+ 	{
+ 		commonDispatchDevice(common,channel,pChannel);
+ 		resetSampleCounter(pChannel);
+diff -Nur xc.old/programs/Xserver/hw/xfree86/os-support/Imakefile xc/programs/Xserver/hw/xfree86/os-support/Imakefile
+--- xc.old/programs/Xserver/hw/xfree86/os-support/Imakefile	2005-02-19 15:51:13.000000000 +0100
++++ xc/programs/Xserver/hw/xfree86/os-support/Imakefile	2005-02-19 15:58:03.000000000 +0100
+@@ -12,10 +12,10 @@
+ 
+ #if defined(i386Architecture) || defined(ia64Architecture) || \
+ 	(defined(SunArchitecture) && defined(SparcArchitecture)) || \
+-	(defined(FreeBSDArchitecture) && defined(AlphaArchitecture)) || \
+-	(defined(NetBSDArchitecture) && defined(AlphaArchitecture)) || \
+-	(defined(NetBSDArchitecture) && defined(PpcArchitecture)) || \
+-	(defined(NetBSDArchitecture) && defined(SparcArchitecture)) || \
++	(defined(kFreeBSDArchitecture) && defined(AlphaArchitecture)) || \
++	(defined(kNetBSDArchitecture) && defined(AlphaArchitecture)) || \
++	(defined(kNetBSDArchitecture) && defined(PpcArchitecture)) || \
++	(defined(kNetBSDArchitecture) && defined(SparcArchitecture)) || \
+ 	defined(OpenBSDArchitecture) || \
+ 	(defined(LynxOSArchitecture) && defined(PpcArchitecture)) || \
+ 	defined(x86_64Architecture) || defined(LinuxArchitecture) || defined(GNUMachArchitecture)
+@@ -58,7 +58,7 @@
+ OS_SUBDIR = lynxos
+ #endif
+ 
+-#if defined(FreeBSDArchitecture) || defined(NetBSDArchitecture) || \
++#if defined(kFreeBSDArchitecture) || defined(kNetBSDArchitecture) || \
+     defined(OpenBSDArchitecture)
+ OS_SUBDIR = bsd
+ #endif
+diff -Nur xc.old/programs/Xserver/hw/xfree86/os-support/bsd/Imakefile xc/programs/Xserver/hw/xfree86/os-support/bsd/Imakefile
+--- xc.old/programs/Xserver/hw/xfree86/os-support/bsd/Imakefile	2003-02-17 17:37:19.000000000 +0100
++++ xc/programs/Xserver/hw/xfree86/os-support/bsd/Imakefile	2005-02-19 15:58:03.000000000 +0100
+@@ -8,7 +8,7 @@
+ 
+ #include <Server.tmpl>
+ 
+-#if defined(FreeBSDArchitecture) || defined(NetBSDArchitecture) || defined(OpenBSDArchitecture)
++#if defined(KFreeBSDArchitecture) || defined(KNetBSDArchitecture) || defined(KOpenBSDArchitecture)
+ #if BuildXInputExt
+ # if JoystickSupport
+  JOYSTICK_SRC = bsd_jstk.c
+@@ -23,7 +23,7 @@
+ #endif
+ #endif
+ 
+-#if defined(NetBSDArchitecture) \
++#if defined(KNetBSDArchitecture) \
+     && ((OSMajorVersion == 1 && OSMinorVersion >= 1) || OSMajorVersion >= 2)
+ # if defined(AlphaArchitecture)
+   IOPERMDEFINES = -DUSE_ALPHA_PIO
+@@ -38,14 +38,14 @@
+ # else
+   IOPERMDEFINES = -DUSE_I386_IOPL
+ # endif
+-#elif defined(OpenBSDArchitecture) 
++#elif defined(KOpenBSDArchitecture) 
+ # if defined(i386Architecture) 
+   IOPERMDEFINES = -DUSE_I386_IOPL
+ # elif defined(PpcArchitecture) || defined(Sparc64Architecture) 
+   IOPERM_SRC = ioperm_noop.c
+   IOPERM_OBJ = ioperm_noop.o
+ # endif
+-#elif defined(FreeBSDArchitecture) && !defined(AlphaBsdArchitecture)
++#elif defined(KFreeBSDArchitecture) && !defined(AlphaBsdArchitecture)
+   IOPERMDEFINES = -DUSE_DEV_IO
+ #else
+ # if defined(AlphaBsdArchitecture)
+@@ -71,11 +71,11 @@
+ MTRRDEFINES = -DHAS_MTRR_SUPPORT
+ #endif
+ 
+-#if defined(NetBSDArchitecture) && defined(HasMTRRBuiltin)
++#if defined(KNetBSDArchitecture) && defined(HasMTRRBuiltin)
+ MTRRDEFINES = -DHAS_MTRR_BUILTIN
+ #endif
+ 
+-#if defined(FreeBSDArchitecture)
++#if defined(KFreeBSDArchitecture)
+ SYSVIPCDEFINES = -DHAVE_SYSV_IPC
+ #endif
+ 
+@@ -93,7 +93,7 @@
+ #endif
+ USBMOUSEDEFINES = $(USBMOUSEDEFINES1) $(USBMOUSEDEFINES2)
+ 
+-#if (defined(OpenBSDArchitecture) || defined(NetBSDArchitecture)) && defined(i386Architecture)
++#if (defined(KOpenBSDArchitecture) || defined(KNetBSDArchitecture)) && defined(i386Architecture)
+ # if !defined(HasApmKqueue) || !HasApmKqueue
+ APMSRC = bsd_apm.c
+ APMOBJ = bsd_apm.o
+@@ -106,7 +106,7 @@
+ APMOBJ = pm_noop.o
+ #endif
+ 
+-#if defined(FreeBSDArchitecture) && (OSMajorVersion > 2)
++#if defined(KFreeBSDArchitecture) && (OSMajorVersion > 2)
+ KMODSRC = bsd_kmod.c
+ KMODOBJ = bsd_kmod.o
+ #else
+@@ -127,7 +127,7 @@
+ AXP_OBJ=bsd_ev56.o xf86Axp.o bsd_axp.o
+ #endif
+ 
+-#if (defined(FreeBSDArchitecture) || defined(NetBSDArchitecture)) && HasAgpGart
++#if (defined(KFreeBSDArchitecture) || defined(KNetBSDArchitecture)) && HasAgpGart
+ AGP_SRC=lnx_agp.c
+ AGP_OBJ=lnx_agp.o
+ #else
+@@ -204,7 +204,7 @@
+ # endif
+ #endif
+ 
+-#if !defined(NetBSDArchitecture) && !defined(OpenBSDArchitecture) || \
++#if !defined(KNetBSDArchitecture) && !defined(KOpenBSDArchitecture) || \
+ 	!defined(i386Architecture)
+ LinkSourceFile(pm_noop.c,../shared)
+ #endif
+@@ -218,7 +218,7 @@
+ LinkSourceFile(vidmem.c,../shared)
+ LinkSourceFile(sigio.c,../shared)
+ LinkSourceFile(kmod_noop.c,../shared)
+-#if (defined(FreeBSDArchitecture) || defined(NetBSDArchitecture)) && HasAgpGart
++#if (defined(KFreeBSDArchitecture) || defined(KNetBSDArchitecture)) && HasAgpGart
+ LinkSourceFile(lnx_agp.c,../linux)
+ #else
+ LinkSourceFile(agp_noop.c,../shared)
+diff -Nur xc.old/programs/Xserver/hw/xfree86/os-support/bsd/alpha_video.c xc/programs/Xserver/hw/xfree86/os-support/bsd/alpha_video.c
+--- xc.old/programs/Xserver/hw/xfree86/os-support/bsd/alpha_video.c	2005-02-19 15:50:56.000000000 +0100
++++ xc/programs/Xserver/hw/xfree86/os-support/bsd/alpha_video.c	2005-02-19 15:58:03.000000000 +0100
+@@ -29,11 +29,12 @@
+ #include "X.h"
+ #include "xf86.h"
+ #include "xf86Priv.h"
++#include "kbsd.h"
+ 
+ #include <sys/param.h>
+-#ifndef __NetBSD__
++#ifndef __NetBSD_kernel__
+ #  include <sys/sysctl.h>
+-#  ifdef __FreeBSD__
++#  ifdef __FreeBSD_kernel__
+ #      include <machine/sysarch.h>
+ #   endif
+ # else
+@@ -45,7 +46,7 @@
+ #include "xf86_OSlib.h"
+ #include "xf86OSpriv.h"
+ 
+-#if defined(__NetBSD__) && !defined(MAP_FILE)
++#if defined(__NetBSD_kernel__) && !defined(MAP_FILE)
+ #define MAP_FLAGS MAP_SHARED
+ #else
+ #define MAP_FLAGS (MAP_FILE | MAP_SHARED)
+@@ -57,7 +58,7 @@
+ 
+ axpDevice bsdGetAXP(void);
+ 
+-#ifndef __NetBSD__
++#ifndef __NetBSD_kernel__
+ extern unsigned long dense_base(void);
+ 
+ static int axpSystem = -1;
+@@ -74,7 +75,7 @@
+     if (base == 0) {
+ 	size_t len = sizeof(base);
+ 	int error;
+-#ifdef __OpenBSD__
++#ifdef __OpenBSD_kernel__
+        int mib[3];
+ 
+        mib[0] = CTL_MACHDEP;
+@@ -98,7 +99,7 @@
+     static int bwx = 0;
+     size_t len = sizeof(bwx);
+     int error;
+-#ifdef __OpenBSD__
++#ifdef __OpenBSD_kernel__
+     int mib[3];
+ 
+     mib[0] = CTL_MACHDEP;
+@@ -116,7 +117,7 @@
+ 	return bwx;
+ #endif
+ }
+-#else /* __NetBSD__ */
++#else /* __NetBSD_kernel__ */
+ static struct alpha_bus_window *abw;
+ static int abw_count = -1;
+ 
+@@ -168,7 +169,7 @@
+ 		return 0;
+ 	}
+ }
+-#endif /* __NetBSD__ */
++#endif /* __NetBSD_kernel__ */
+ 
+ #define BUS_BASE	dense_base()
+ #define BUS_BASE_BWX	memory_base()
+@@ -177,7 +178,7 @@
+ /* Video Memory Mapping section                                            */
+ /***************************************************************************/
+ 
+-#ifdef __OpenBSD__
++#ifdef __OpenBSD_kernel__
+ #define SYSCTL_MSG "\tCheck that you have set 'machdep.allowaperture=1'\n"\
+                   "\tin /etc/sysctl.conf and reboot your machine\n" \
+                   "\trefer to xf86(4) for details"
+@@ -255,14 +256,14 @@
+            xf86Msg(X_WARNING, "checkDevMem: failed to open/mmap %s (%s)\n",
+                    DEV_MEM, strerror(errno));
+ #else
+-#ifndef __OpenBSD__
++#ifndef __OpenBSD_kernel__
+            xf86Msg(X_WARNING, "checkDevMem: failed to open %s and %s\n"
+                "\t(%s)\n", DEV_APERTURE, DEV_MEM, strerror(errno));
+-#else /* __OpenBSD__ */
++#else /* __OpenBSD_kernel__ */
+            xf86Msg(X_WARNING, "checkDevMem: failed to open %s and %s\n"
+                    "\t(%s)\n%s", DEV_APERTURE, DEV_MEM, strerror(errno),
+                    SYSCTL_MSG);
+-#endif /* __OpenBSD__ */
++#endif /* __OpenBSD_kernel__ */
+ #endif
+            xf86ErrorF("\tlinear framebuffer access unavailable\n");
+ 	}
+@@ -387,7 +388,7 @@
+ }
+ 
+ 
+-#if defined(__FreeBSD__) || defined(__OpenBSD__)
++#if defined(__FreeBSD_kernel__) || defined(__OpenBSD_kernel__)
+ 
+ extern int ioperm(unsigned long from, unsigned long num, int on);
+ 
+@@ -404,7 +405,7 @@
+ 	return;
+ }
+ 
+-#endif /* __FreeBSD__ || __OpenBSD__ */
++#endif /* __FreeBSD_kernel__ || __OpenBSD_kernel__ */
+ 
+ #ifdef USE_ALPHA_PIO
+ 
+@@ -478,7 +479,7 @@
+ static void
+ writeSparse32(int Value, pointer Base, register unsigned long Offset);
+ 
+-#ifdef __FreeBSD__
++#ifdef __FreeBSD_kernel__
+ extern int sysarch(int, char *);
+ #endif
+ 
+@@ -489,7 +490,7 @@
+ static int
+ sethae(u_int64_t hae)
+ {
+-#ifdef __FreeBSD__
++#ifdef __FreeBSD_kernel__
+ #ifndef ALPHA_SETHAE
+ #define ALPHA_SETHAE 0
+ #endif
+@@ -497,7 +498,7 @@
+ 	p.hae = hae;
+ 	return (sysarch(ALPHA_SETHAE, (char *)&p));
+ #endif
+-#ifdef __OpenBSD__
++#ifdef __OpenBSD_kernel__
+ 	return -1;
+ #endif
+ }
+diff -Nur xc.old/programs/Xserver/hw/xfree86/os-support/bsd/arm_video.c xc/programs/Xserver/hw/xfree86/os-support/bsd/arm_video.c
+--- xc.old/programs/Xserver/hw/xfree86/os-support/bsd/arm_video.c	2005-02-19 15:51:00.000000000 +0100
++++ xc/programs/Xserver/hw/xfree86/os-support/bsd/arm_video.c	2005-02-19 15:58:03.000000000 +0100
+@@ -64,6 +64,7 @@
+ #include "xf86Priv.h"
+ #include "xf86_OSlib.h"
+ #include "xf86OSpriv.h"
++#include "kbsd.h"
+ 
+ #ifdef __arm32__
+ #include "machine/devmap.h"
+@@ -90,7 +91,7 @@
+ 				   FALSE, FALSE };
+ #endif /* __arm32__ */
+ 
+-#if defined(__NetBSD__) && !defined(MAP_FILE)
++#if defined(__NetBSD_kernel__) && !defined(MAP_FILE)
+ #define MAP_FLAGS MAP_SHARED
+ #else
+ #define MAP_FLAGS (MAP_FILE | MAP_SHARED)
+diff -Nur xc.old/programs/Xserver/hw/xfree86/os-support/bsd/bsd_KbdMap.c xc/programs/Xserver/hw/xfree86/os-support/bsd/bsd_KbdMap.c
+--- xc.old/programs/Xserver/hw/xfree86/os-support/bsd/bsd_KbdMap.c	2002-10-11 03:40:34.000000000 +0200
++++ xc/programs/Xserver/hw/xfree86/os-support/bsd/bsd_KbdMap.c	2005-02-19 15:58:03.000000000 +0100
+@@ -23,6 +23,7 @@
+ #include "atKeynames.h"
+ #include "xf86Keymap.h"
+ #include "bsd_kbd.h"
++#include "kbsd.h"
+ 
+ #if (defined(SYSCONS_SUPPORT) || defined(PCVT_SUPPORT)) && defined(GIO_KEYMAP)
+ #define KD_GET_ENTRY(i,n) \
+@@ -186,7 +187,7 @@
+ 	NoSymbol,	NoSymbol,	NoSymbol,	NoSymbol
+ };
+ 
+-#ifdef __OpenBSD__
++#ifdef __OpenBSD_kernel__
+ /* don't mark AltR and  CtrlR for remapping, since they 
+  * cannot be remapped by pccons */
+ static unsigned char pccons_remap[128] = {
+@@ -837,7 +838,7 @@
+ 
+ #ifdef PCCONS_SUPPORT
+   case PCCONS:
+-#if defined(__OpenBSD__)
++#if defined(__OpenBSD_kernel__)
+     /*
+      * on OpenBSD, the pccons keymap is programmable, too
+      */
+@@ -937,7 +938,7 @@
+ 	ErrorF("Can't read pccons keymap\n");
+       }
+     }
+-#endif /* __OpenBSD__ */
++#endif /* __OpenBSD_kernel__ */
+   break;
+ #endif
+ 
+diff -Nur xc.old/programs/Xserver/hw/xfree86/os-support/bsd/bsd_axp.c xc/programs/Xserver/hw/xfree86/os-support/bsd/bsd_axp.c
+--- xc.old/programs/Xserver/hw/xfree86/os-support/bsd/bsd_axp.c	2002-10-30 00:19:13.000000000 +0100
++++ xc/programs/Xserver/hw/xfree86/os-support/bsd/bsd_axp.c	2005-02-19 15:58:03.000000000 +0100
+@@ -9,6 +9,7 @@
+ #include "xf86_OSlib.h"
+ #include <stdio.h>
+ #include <sys/sysctl.h>
++#include "kbsd.h"
+ 
+ axpDevice bsdGetAXP(void);
+ 
+@@ -43,7 +44,7 @@
+ 	char sysname[64];
+ 	size_t len = sizeof(sysname);
+ 	
+-#ifdef __OpenBSD__
++#ifdef __OpenBSD_kernel__
+ 	int mib[3];
+ 	int error;
+ 
+diff -Nur xc.old/programs/Xserver/hw/xfree86/os-support/bsd/bsd_init.c xc/programs/Xserver/hw/xfree86/os-support/bsd/bsd_init.c
+--- xc.old/programs/Xserver/hw/xfree86/os-support/bsd/bsd_init.c	2002-05-05 20:54:02.000000000 +0200
++++ xc/programs/Xserver/hw/xfree86/os-support/bsd/bsd_init.c	2005-02-19 15:58:03.000000000 +0100
+@@ -32,9 +32,12 @@
+ #include "xf86.h"
+ #include "xf86Priv.h"
+ #include "xf86_OSlib.h"
++#include "kbsd.h"
+ 
+ #include <sys/utsname.h>
++#include <sys/ioctl.h>
+ #include <stdlib.h>
++#include <errno.h>
+ 
+ static Bool KeepTty = FALSE;
+ static int devConsoleFd = -1;
+@@ -43,7 +46,7 @@
+ 
+ #ifdef PCCONS_SUPPORT
+ /* Stock 0.1 386bsd pccons console driver interface */
+-#ifndef __OpenBSD__
++#ifndef __OpenBSD_kernel__
+ #  define PCCONS_CONSOLE_DEV1 "/dev/ttyv0"
+ #else
+ #  define PCCONS_CONSOLE_DEV1 "/dev/ttyC0"
+@@ -61,7 +64,7 @@
+ 
+ #ifdef PCVT_SUPPORT
+ /* Hellmuth Michaelis' pcvt driver */
+-#ifndef __OpenBSD__
++#ifndef __OpenBSD_kernel__
+ #  define PCVT_CONSOLE_DEV "/dev/ttyv0"
+ #else
+ #  define PCVT_CONSOLE_DEV "/dev/ttyC0"
+@@ -69,11 +72,15 @@
+ #define PCVT_CONSOLE_MODE O_RDWR|O_NDELAY
+ #endif
+ 
+-#if defined(WSCONS_SUPPORT) && defined(__NetBSD__)
++#if defined(WSCONS_SUPPORT) && defined(__NetBSD_kernel__)
+ /* NetBSD's new console driver */
+ #define WSCONS_PCVT_COMPAT_CONSOLE_DEV "/dev/ttyE0"
+ #endif
+ 
++#ifdef __GLIBC__
++#define setpgrp setpgid
++#endif
++
+ #define CHECK_DRIVER_MSG \
+   "Check your kernel's console driver configuration and /dev entries"
+ 
+@@ -233,11 +240,11 @@
+ 	     * switching anymore. Here we check for FreeBSD 3.1 and up.
+ 	     * Add cases for other *BSD that behave the same.
+ 	    */
++#if defined(__FreeBSD_kernel__)
+ 	    uname (&uts);
+-	    if (strcmp(uts.sysname, "FreeBSD") == 0) {
+-		i = atof(uts.release) * 100;
+-		if (i >= 310) goto acquire_vt;
+-	    }
++	    i = atof(uts.release) * 100;
++	    if (i >= 310) goto acquire_vt;
++#endif
+ 	    /* otherwise fall through */
+ 	case PCVT:
+ 	    /*
+@@ -441,7 +448,7 @@
+ 	    }
+ 
+ 	    close(fd);
+-#ifndef __OpenBSD__
++#ifndef __OpenBSD_kernel__
+ 	    sprintf(vtname, "/dev/ttyv%01x", xf86Info.vtno - 1);
+ #else 
+ 	    sprintf(vtname, "/dev/ttyC%01x", xf86Info.vtno - 1);
+@@ -493,7 +500,7 @@
+     struct stat status;
+     struct pcvtid pcvt_version;
+ 
+-#ifndef __OpenBSD__
++#ifndef __OpenBSD_kernel__
+     vtprefix = "/dev/ttyv";
+ #else
+     vtprefix = "/dev/ttyC";
+@@ -604,9 +611,9 @@
+ 
+     /* XXX Is this ok? */
+     for (i = 0; i < 8; i++) {
+-#if defined(__NetBSD__)
++#if defined(__NetBSD_kernel__)
+ 	sprintf(ttyname, "/dev/ttyE%d", i);
+-#elif defined(__OpenBSD__)
++#elif defined(__OpenBSD_kernel__)
+ 	sprintf(ttyname, "/dev/ttyC%d", i);
+ #endif
+ 	if ((fd = open(ttyname, 2)) != -1)
+diff -Nur xc.old/programs/Xserver/hw/xfree86/os-support/bsd/bsd_io.c xc/programs/Xserver/hw/xfree86/os-support/bsd/bsd_io.c
+--- xc.old/programs/Xserver/hw/xfree86/os-support/bsd/bsd_io.c	2002-10-21 22:38:04.000000000 +0200
++++ xc/programs/Xserver/hw/xfree86/os-support/bsd/bsd_io.c	2005-02-19 15:58:03.000000000 +0100
+@@ -34,6 +34,10 @@
+ #include "xf86Priv.h"
+ #include "xf86_OSlib.h"
+ 
++#ifdef __GLIBC__
++#include <termios.h>
++#endif
++
+ #ifdef WSCONS_SUPPORT
+ #define KBD_FD(i) ((i).kbdFd != -1 ? (i).kbdFd : (i).consoleFd)
+ #endif
+@@ -144,7 +148,7 @@
+ }
+ 
+ #if defined(SYSCONS_SUPPORT) || defined(PCCONS_SUPPORT) || defined(PCVT_SUPPORT) || defined(WSCONS_SUPPORT)
+-static struct termio kbdtty;
++static struct termios kbdtty;
+ #endif
+ 
+ void
+diff -Nur xc.old/programs/Xserver/hw/xfree86/os-support/bsd/bsd_kbd.c xc/programs/Xserver/hw/xfree86/os-support/bsd/bsd_kbd.c
+--- xc.old/programs/Xserver/hw/xfree86/os-support/bsd/bsd_kbd.c	2003-02-17 16:11:56.000000000 +0100
++++ xc/programs/Xserver/hw/xfree86/os-support/bsd/bsd_kbd.c	2005-02-19 15:58:03.000000000 +0100
+@@ -23,6 +23,10 @@
+ #include "atKeynames.h"
+ #include "bsd_kbd.h"
+ 
++#ifdef __GLIBC__
++#include <termios.h>
++#endif
++
+ extern Bool VTSwitchEnabled;
+ #ifdef USE_VT_SYSREQ
+ extern Bool VTSysreqToggle;
+@@ -37,7 +41,11 @@
+ };
+ 
+ typedef struct {
++#ifdef __GLIBC__
++   struct termios kbdtty;
++#else
+    struct termio kbdtty;
++#endif
+ } BsdKbdPrivRec, *BsdKbdPrivPtr;
+ 
+ static
+@@ -56,8 +64,8 @@
+             case WSCONS:
+ #endif
+  	         tcgetattr(pInfo->fd, &(priv->kbdtty));
+-#endif
+ 	         break;
++#endif
+         }
+     }
+ 
+@@ -70,6 +78,15 @@
+     KbdDevPtr pKbd = (KbdDevPtr) pInfo->private;
+     int real_leds = 0;
+ 
++#ifndef LED_CAP
++#define LED_CAP 0
++#endif
++#ifndef LED_NUM
++#define LED_NUM 0
++#endif
++#ifndef LED_SCR
++#define LED_SCR 0
++#endif
+     if (leds & XLED1)  real_leds |= LED_CAP;
+     if (leds & XLED2)  real_leds |= LED_NUM;
+     if (leds & XLED3)  real_leds |= LED_SCR;
+@@ -199,7 +216,9 @@
+ 		 }
+ 		 break;
+ #endif
++#if defined (SYSCONS_SUPPORT) || defined (PCVT_SUPPORT) || defined (WSCONS_SUPPORT)
+         }
++#endif
+     }
+     return Success;
+ }
+@@ -302,16 +321,20 @@
+              case KEY_F8:
+              case KEY_F9:
+              case KEY_F10:
++#ifdef VT_ACTIVATE
+                   if (down) {
+                     ioctl(xf86Info.consoleFd, VT_ACTIVATE, key - KEY_F1 + 1);
+                     return TRUE;
+                   }
++#endif
+              case KEY_F11:
+              case KEY_F12:
++#ifdef VT_ACTIVATE
+                   if (down) {
+                     ioctl(xf86Info.consoleFd, VT_ACTIVATE, key - KEY_F11 + 11);
+                     return TRUE;
+                   }
++#endif
+          }
+       }
+     }
+diff -Nur xc.old/programs/Xserver/hw/xfree86/os-support/bsd/bsd_mouse.c xc/programs/Xserver/hw/xfree86/os-support/bsd/bsd_mouse.c
+--- xc.old/programs/Xserver/hw/xfree86/os-support/bsd/bsd_mouse.c	2003-02-15 06:37:59.000000000 +0100
++++ xc/programs/Xserver/hw/xfree86/os-support/bsd/bsd_mouse.c	2005-02-19 15:58:03.000000000 +0100
+@@ -12,6 +12,7 @@
+ #include "xf86OSmouse.h"
+ #include "xisb.h"
+ #include "mipointer.h"
++#include "kbsd.h"
+ #ifdef WSCONS_SUPPORT
+ #include <dev/wscons/wsconsio.h>
+ #endif
+@@ -48,9 +49,9 @@
+ static int
+ SupportedInterfaces(void)
+ {
+-#if defined(__NetBSD__)
++#if defined(__NetBSD_kernel__)
+     return MSE_SERIAL | MSE_BUS | MSE_PS2 | MSE_AUTO;
+-#elif defined(__FreeBSD__)
++#elif defined(__FreeBSD_kernel__)
+     return MSE_SERIAL | MSE_BUS | MSE_PS2 | MSE_AUTO | MSE_MISC;
+ #else
+     return MSE_SERIAL | MSE_BUS | MSE_PS2 | MSE_XPS2 | MSE_AUTO;
+@@ -73,7 +74,7 @@
+  * main "mouse" driver.
+  */
+ static const char *miscNames[] = {
+-#if defined(__FreeBSD__)
++#if defined(__FreeBSD_kernel__)
+ 	"SysMouse",
+ #endif
+ 	NULL
+@@ -102,14 +103,14 @@
+ static const char *
+ DefaultProtocol(void)
+ {
+-#if defined(__FreeBSD__)
++#if defined(__FreeBSD_kernel__)
+     return "Auto";
+ #else
+     return NULL;
+ #endif
+ }
+ 
+-#if defined(__FreeBSD__) && defined(MOUSE_PROTO_SYSMOUSE)
++#if defined(__FreeBSD_kernel__) && defined(MOUSE_PROTO_SYSMOUSE)
+ static struct {
+ 	int dproto;
+ 	const char *name;
+@@ -178,7 +179,7 @@
+     mode.rate = rate > 0 ? rate : -1;
+     mode.resolution = res > 0 ? res : -1;
+     mode.accelfactor = -1;
+-#if defined(__FreeBSD__)
++#if defined(__FreeBSD_kernel__)
+     if (pMse->autoProbe ||
+ 	(protocol && xf86NameCmp(protocol, "SysMouse") == 0)) {
+ 	/*
+@@ -583,7 +584,7 @@
+     p->BuiltinNames = BuiltinNames;
+     p->DefaultProtocol = DefaultProtocol;
+     p->CheckProtocol = CheckProtocol;
+-#if defined(__FreeBSD__) && defined(MOUSE_PROTO_SYSMOUSE)
++#if defined(__FreeBSD_kernel__) && defined(MOUSE_PROTO_SYSMOUSE)
+     p->SetupAuto = SetupAuto;
+     p->SetPS2Res = SetSysMouseRes;
+     p->SetBMRes = SetSysMouseRes;
+diff -Nur xc.old/programs/Xserver/hw/xfree86/os-support/bsd/i386_video.c xc/programs/Xserver/hw/xfree86/os-support/bsd/i386_video.c
+--- xc.old/programs/Xserver/hw/xfree86/os-support/bsd/i386_video.c	2005-02-19 15:51:00.000000000 +0100
++++ xc/programs/Xserver/hw/xfree86/os-support/bsd/i386_video.c	2005-02-19 15:58:03.000000000 +0100
+@@ -29,9 +29,13 @@
+ #include "X.h"
+ #include "xf86.h"
+ #include "xf86Priv.h"
++#include "kbsd.h"
++
++#include <errno.h>
++#include <sys/mman.h>
+ 
+ #ifdef HAS_MTRR_SUPPORT
+-#ifndef __NetBSD__
++#ifndef __NetBSD_kernel__
+ #include <sys/types.h>
+ #include <sys/memrange.h>
+ #else
+@@ -40,7 +44,7 @@
+ #define X_MTRR_ID "XFree86"
+ #endif
+ 
+-#if defined(HAS_MTRR_BUILTIN) && defined(__NetBSD__)
++#if defined(HAS_MTRR_BUILTIN) && defined(__NetBSD_kernel__)
+ #include <machine/mtrr.h>
+ #include <machine/sysarch.h>
+ #include <sys/queue.h>
+@@ -49,7 +53,7 @@
+ #include "xf86_OSlib.h"
+ #include "xf86OSpriv.h"
+ 
+-#if defined(__NetBSD__) && !defined(MAP_FILE)
++#if defined(__NetBSD_kernel__) && !defined(MAP_FILE)
+ #define MAP_FLAGS MAP_SHARED
+ #else
+ #define MAP_FLAGS (MAP_FILE | MAP_SHARED)
+@@ -59,7 +63,7 @@
+ #define MAP_FAILED ((caddr_t)-1)
+ #endif
+ 
+-#ifdef __OpenBSD__
++#ifdef __OpenBSD_kernel__
+ #define SYSCTL_MSG "\tCheck that you have set 'machdep.allowaperture=1'\n"\
+ 		   "\tin /etc/sysctl.conf and reboot your machine\n" \
+ 		   "\trefer to xf86(4) for details\n"
+@@ -89,7 +93,7 @@
+ static void undoWC(int, pointer);
+ static Bool cleanMTRR(void);
+ #endif
+-#if defined(HAS_MTRR_BUILTIN) && defined(__NetBSD__)
++#if defined(HAS_MTRR_BUILTIN) && defined(__NetBSD_kernel__)
+ static pointer NetBSDsetWC(int, unsigned long, unsigned long, Bool,
+ 			   MessageType);
+ static void NetBSDundoWC(int, pointer);
+@@ -169,14 +173,14 @@
+ 	} else {
+ 	    if (warn)
+ 	    {
+-#ifndef __OpenBSD__
++#ifndef __OpenBSD_kernel__
+ 		xf86Msg(X_WARNING, "checkDevMem: failed to open %s and %s\n"
+ 			"\t(%s)\n", DEV_MEM, DEV_APERTURE, strerror(errno));
+-#else /* __OpenBSD__ */
++#else /* __OpenBSD_kernel__ */
+ 		xf86Msg(X_WARNING, "checkDevMem: failed to open %s and %s\n"
+ 			"\t(%s)\n%s", DEV_MEM, DEV_APERTURE, strerror(errno),
+ 			SYSCTL_MSG);
+-#endif /* __OpenBSD__ */
++#endif /* __OpenBSD_kernel__ */
+ 	    }
+ 	}
+ 	
+@@ -202,7 +206,7 @@
+ 		}
+ 	}
+ #endif
+-#if defined(HAS_MTRR_BUILTIN) && defined(__NetBSD__)
++#if defined(HAS_MTRR_BUILTIN) && defined(__NetBSD_kernel__)
+ 	pVidMem->setWC = NetBSDsetWC;
+ 	pVidMem->undoWC = NetBSDundoWC;
+ #endif
+@@ -290,7 +294,7 @@
+ 		xf86Msg(X_WARNING, 
+ 			"xf86ReadBIOS: %s mmap[s=%x,a=%x,o=%x] failed (%s)\n",
+ 			DEV_MEM, Len, Base, Offset, strerror(errno));
+-#ifdef __OpenBSD__
++#ifdef __OpenBSD_kernel__
+ 		if (Base < 0xa0000) {
+ 		    xf86Msg(X_WARNING, SYSCTL_MSG2);
+ 		} 
+@@ -327,7 +331,7 @@
+ 
+ 	if (i386_iopl(TRUE) < 0)
+ 	{
+-#ifndef __OpenBSD__
++#ifndef __OpenBSD_kernel__
+ 		FatalError("%s: Failed to set IOPL for extended I/O\n",
+ 			   "xf86EnableIO");
+ #else
+@@ -416,7 +420,7 @@
+ }
+ 
+ 
+-#ifdef __NetBSD__
++#ifdef __NetBSD_kernel__
+ /***************************************************************************/
+ /* Set TV output mode                                                      */
+ /***************************************************************************/
+@@ -829,7 +833,7 @@
+ #endif /* HAS_MTRR_SUPPORT */
+ 
+ 
+-#if defined(HAS_MTRR_BUILTIN) && defined(__NetBSD__)
++#if defined(HAS_MTRR_BUILTIN) && defined(__NetBSD_kernel__)
+ static pointer
+ NetBSDsetWC(int screenNum, unsigned long base, unsigned long size, Bool enable,
+ 	    MessageType from)
+diff -Nur xc.old/programs/Xserver/hw/xfree86/os-support/bsd/kbsd.h xc/programs/Xserver/hw/xfree86/os-support/bsd/kbsd.h
+--- xc.old/programs/Xserver/hw/xfree86/os-support/bsd/kbsd.h	1970-01-01 01:00:00.000000000 +0100
++++ xc/programs/Xserver/hw/xfree86/os-support/bsd/kbsd.h	2005-02-19 15:58:03.000000000 +0100
+@@ -0,0 +1,19 @@
++/* Compatibility with k*BSD-based non-BSD systems (e.g. GNU/k*BSD) */
++
++#if defined(__FreeBSD__) && !defined(__FreeBSD_kernel__)
++# define __FreeBSD_kernel__ __FreeBSD__
++#endif
++#ifdef __FreeBSD_kernel__
++# include <osreldate.h>
++# ifndef __FreeBSD_kernel_version
++#  define __FreeBSD_kernel_version __FreeBSD_version
++# endif
++#endif
++
++#if defined(__NetBSD__) && !defined(__NetBSD_kernel__)
++# define __NetBSD_kernel__ __NetBSD__
++#endif
++
++#if defined(__OpenBSD__) && !defined(__OpenBSD_kernel__)
++# define __OpenBSD_kernel__ __OpenBSD__
++#endif
+diff -Nur xc.old/programs/Xserver/hw/xfree86/os-support/bsd/ppc_video.c xc/programs/Xserver/hw/xfree86/os-support/bsd/ppc_video.c
+--- xc.old/programs/Xserver/hw/xfree86/os-support/bsd/ppc_video.c	2005-02-19 15:51:00.000000000 +0100
++++ xc/programs/Xserver/hw/xfree86/os-support/bsd/ppc_video.c	2005-02-19 15:58:03.000000000 +0100
+@@ -32,6 +32,7 @@
+ 
+ #include "xf86_OSlib.h"
+ #include "xf86OSpriv.h"
++#include "kbsd.h"
+ 
+ #include "bus/Pci.h"
+ 
+@@ -44,7 +45,7 @@
+ /* Video Memory Mapping section                                            */
+ /***************************************************************************/
+ 
+-#ifndef __OpenBSD__
++#ifndef __OpenBSD_kernel__
+ #define DEV_MEM "/dev/mem"
+ #else
+ #define DEV_MEM "/dev/xf86"
+diff -Nur xc.old/programs/Xserver/hw/xfree86/os-support/bus/Imakefile xc/programs/Xserver/hw/xfree86/os-support/bus/Imakefile
+--- xc.old/programs/Xserver/hw/xfree86/os-support/bus/Imakefile	2005-02-19 15:51:12.000000000 +0100
++++ xc/programs/Xserver/hw/xfree86/os-support/bus/Imakefile	2005-02-19 15:58:03.000000000 +0100
+@@ -48,7 +48,7 @@
+ PCIDRVRSRC = linuxPci.c
+ PCIDRVROBJ = linuxPci.o
+ 
+-#elif defined(OpenBSDArchitecture) && \
++#elif defined(KOpenBSDArchitecture) && \
+ 	(defined(PpcArchitecture) || \
+ 	defined(AlphaArchitecture) || \
+ 	defined(Sparc64Architecture))
+@@ -58,7 +58,7 @@
+ PCIDRVRSRC = freebsdPci.c
+ PCIDRVROBJ = freebsdPci.o
+ 
+-#elif defined(NetBSDArchitecture) && defined(PpcArchitecture)
++#elif defined(KNetBSDArchitecture) && defined(PpcArchitecture)
+ 
+ XCOMM NetBSD/powerpc
+ 
+@@ -80,7 +80,7 @@
+ PCIDRVRSRC = ix86Pci.c linuxPci.c
+ PCIDRVROBJ = ix86Pci.o linuxPci.o
+ 
+-#elif defined(FreeBSDArchitecture) && defined(AlphaArchitecture)
++#elif defined(KFreeBSDArchitecture) && defined(AlphaArchitecture)
+ 
+ 
+ XCOMM generic FreeBSD PCI driver (using /dev/pci)
+@@ -88,7 +88,7 @@
+ PCIDRVRSRC = freebsdPci.c
+ PCIDRVROBJ = freebsdPci.o
+ 
+-#elif defined(NetBSDArchitecture) && defined(AlphaArchitecture)
++#elif defined(KNetBSDArchitecture) && defined(AlphaArchitecture)
+ 
+ XCOMM Alpha (NetBSD) PCI driver
+ 
+diff -Nur xc.old/programs/Xserver/hw/xfree86/os-support/xf86_OSlib.h xc/programs/Xserver/hw/xfree86/os-support/xf86_OSlib.h
+--- xc.old/programs/Xserver/hw/xfree86/os-support/xf86_OSlib.h	2002-05-31 20:46:00.000000000 +0200
++++ xc/programs/Xserver/hw/xfree86/os-support/xf86_OSlib.h	2005-02-19 15:58:03.000000000 +0100
+@@ -98,6 +98,8 @@
+ #endif
+ #endif
+ 
++#include "kbsd.h"
++
+ #include <stdio.h>
+ #include <ctype.h>
+ #include <stddef.h>
+@@ -337,12 +339,24 @@
+ #endif /* DGUX && SVR4 */
+ 
+ /**************************************************************************/
+-/* Linux                                                                  */
++/* Linux or Glibc-based system                                            */
+ /**************************************************************************/
+-#if defined(linux)
++#if defined(linux) || defined(__GLIBC__)
+ # include <sys/ioctl.h>
+ # include <signal.h>
+-# include <termio.h>
++# include <stdlib.h>
++# include <sys/types.h>
++# include <assert.h>
++
++#ifdef __GNU__ /* GNU/Hurd */
++# define USE_OSMOUSE
++#endif
++
++# ifdef linux
++#  include <termio.h>
++# else /* __GLIBC__ */
++#  include <termios.h>
++# endif
+ # ifdef __sparc__
+ #  include <sys/param.h>
+ # endif
+@@ -351,20 +365,21 @@
+ 
+ # include <sys/stat.h>
+ 
+-# define HAS_USL_VTS
+ # include <sys/mman.h>
+-# include <sys/kd.h>
+-# include <sys/vt.h>
+-# define LDGMAP GIO_SCRNMAP
+-# define LDSMAP PIO_SCRNMAP
+-# define LDNMAP LDSMAP
+-
+-# define CLEARDTR_SUPPORT
+-# define USE_VT_SYSREQ
++# ifdef linux
++#  define HAS_USL_VTS
++#  include <sys/kd.h>
++#  include <sys/vt.h>
++#  define LDGMAP GIO_SCRNMAP
++#  define LDSMAP PIO_SCRNMAP
++#  define LDNMAP LDSMAP
++#  define CLEARDTR_SUPPORT
++#  define USE_VT_SYSREQ
++# endif
+ 
+ # define POSIX_TTY
+ 
+-#endif /* linux */
++#endif /* linux || __GLIBC__ */
+ 
+ /**************************************************************************/
+ /* LynxOS AT                                                              */
+@@ -424,6 +439,25 @@
+ 
+ # include <errno.h>
+ 
++# include <sys/types.h>
++# include <sys/mman.h>
++# include <sys/stat.h>
++
++# if defined(__bsdi__)
++#  include <sys/param.h>
++# if (_BSDI_VERSION < 199510)
++#  include <i386/isa/vgaioctl.h>
++# endif
++# endif /* __bsdi__ */
++
++#endif /* CSRG_BASED */
++
++/**************************************************************************/
++/* Kernel of *BSD                                                         */
++/**************************************************************************/
++#if defined(__FreeBSD_kernel__) || defined(__NetBSD_kernel__) || \
++ defined(__OpenBSD_kernel__) || defined(__bsdi__)
++
+ # if !defined(LINKKIT)
+   /* Don't need this stuff for the Link Kit */
+ #  if defined(__bsdi__)
+@@ -432,7 +466,7 @@
+ #   define CONSOLE_X_MODE_OFF PCCONIOCCOOK
+ #   define CONSOLE_X_BELL PCCONIOCBEEP
+ #  else /* __bsdi__ */
+-#   if defined(__OpenBSD__)
++#   if defined(__OpenBSD_kernel__)
+ #     ifdef PCCONS_SUPPORT
+ #       include <machine/pccons.h>
+ #       undef CONSOLE_X_MODE_ON
+@@ -442,12 +476,11 @@
+ #   endif
+ #   ifdef SYSCONS_SUPPORT
+ #    define COMPAT_SYSCONS
+-#    if defined(__NetBSD__) || defined(__OpenBSD__)
++#    if defined(__NetBSD_kernel__) || defined(__OpenBSD_kernel__)
+ #     include <machine/console.h>
+ #    else
+-#     if defined(__FreeBSD__)
+-#        include <osreldate.h>
+-#        if __FreeBSD_version >= 410000
++#     if defined(__FreeBSD_kernel__)
++#        if (__FreeBSD_kernel_version >= 410000)
+ #          include <sys/consio.h>
+ #          include <sys/kbio.h>
+ #        else
+@@ -461,17 +494,17 @@
+ #   if defined(PCVT_SUPPORT)
+ #    if !defined(SYSCONS_SUPPORT)
+       /* no syscons, so include pcvt specific header file */
+-#     if defined(__FreeBSD__)
++#     if defined(__FreeBSD_kernel__)
+ #      include <machine/pcvt_ioctl.h>
+ #     else
+-#      if defined(__NetBSD__) || defined(__OpenBSD__)
++#      if defined(__NetBSD_kernel__) || defined(__OpenBSD_kernel__)
+ #       if !defined(WSCONS_SUPPORT)
+ #        include <machine/pcvt_ioctl.h>
+ #       endif /* WSCONS_SUPPORT */
+ #      else
+ #       include <sys/pcvt_ioctl.h>
+-#      endif /* __NetBSD__ */
+-#     endif /* __FreeBSD__ || __OpenBSD__ */
++#      endif /* __NetBSD_kernel__ */
++#     endif /* __FreeBSD_kernel__ || __OpenBSD_kernel__ */
+ #    else /* pcvt and syscons: hard-code the ID magic */
+ #     define VGAPCVTID _IOWR('V',113, struct pcvtid)
+       struct pcvtid {
+@@ -484,9 +517,8 @@
+ #    include <dev/wscons/wsconsio.h>
+ #    include <dev/wscons/wsdisplay_usl_io.h>
+ #   endif /* WSCONS_SUPPORT */
+-#   if defined(__FreeBSD__)
+-#    include <osreldate.h>
+-#    if __FreeBSD_version >= 500013
++#   if defined(__FreeBSD_kernel__)
++#    if (__FreeBSD_kernel_version >= 500013)
+ #     include <sys/mouse.h>
+ #    else
+ #     undef MOUSE_GETINFO
+@@ -525,17 +557,6 @@
+ #  endif /* __bsdi__ */
+ # endif /* !LINKKIT */
+ 
+-# include <sys/types.h>
+-# include <sys/mman.h>
+-# include <sys/stat.h>
+-
+-# if defined(__bsdi__)
+-#  include <sys/param.h>
+-# if (_BSDI_VERSION < 199510)
+-#  include <i386/isa/vgaioctl.h>
+-# endif
+-# endif /* __bsdi__ */
+-
+ #ifdef USE_I386_IOPL
+ #include <machine/sysarch.h>
+ #endif
+@@ -546,7 +567,8 @@
+ #  define USE_VT_SYSREQ
+ # endif
+ 
+-#endif /* CSRG_BASED */
++#endif
++/* __FreeBSD_kernel__ || __NetBSD_kernel__ || __OpenBSD_kernel__ || __bsdi__ */
+ 
+ /**************************************************************************/
+ /* OS/2                                                                   */
+@@ -656,25 +678,6 @@
+ #endif
+ 
+ /**************************************************************************/
+-/* GNU/Hurd								  */
+-/**************************************************************************/
+-#if defined(__GNU__)
+-
+-#include <stdlib.h>
+-#include <sys/types.h>
+-#include <errno.h>
+-#include <signal.h>
+-#include <sys/ioctl.h>
+-#include <termios.h>
+-#include <sys/stat.h>
+-#include <assert.h>
+-
+-#define POSIX_TTY
+-#define USE_OSMOUSE
+-
+-#endif /* __GNU__ */
+-
+-/**************************************************************************/
+ /* Generic                                                                */
+ /**************************************************************************/
+ 
+diff -Nur xc.old/programs/Xserver/include/kbsd.h xc/programs/Xserver/include/kbsd.h
+--- xc.old/programs/Xserver/include/kbsd.h	1970-01-01 01:00:00.000000000 +0100
++++ xc/programs/Xserver/include/kbsd.h	2005-02-19 15:58:03.000000000 +0100
+@@ -0,0 +1,19 @@
++/* Compatibility with k*BSD-based non-BSD systems (e.g. GNU/k*BSD) */
++
++#if defined(__FreeBSD__) && !defined(__FreeBSD_kernel__)
++# define __FreeBSD_kernel__ __FreeBSD__
++#endif
++#ifdef __FreeBSD_kernel__
++# include <osreldate.h>
++# ifndef __FreeBSD_kernel_version
++#  define __FreeBSD_kernel_version __FreeBSD_version
++# endif
++#endif
++
++#if defined(__NetBSD__) && !defined(__NetBSD_kernel__)
++# define __NetBSD_kernel__ __NetBSD__
++#endif
++
++#if defined(__OpenBSD__) && !defined(__OpenBSD_kernel__)
++# define __OpenBSD_kernel__ __OpenBSD__
++#endif
+diff -Nur xc.old/programs/xdm/config/Imakefile xc/programs/xdm/config/Imakefile
+--- xc.old/programs/xdm/config/Imakefile	2005-02-19 15:51:13.000000000 +0100
++++ xc/programs/xdm/config/Imakefile	2005-02-19 15:58:03.000000000 +0100
+@@ -9,7 +9,7 @@
+ 
+ all:: Xservers.ws xdm-config Xservers Xresources
+ 
+-#if defined(i386Architecture) && (defined(NetBSDArchitecture) || defined(OpenBSDArchitecture))
++#if defined(i386Architecture) && (defined(kNetBSDArchitecture) || defined(OpenBSDArchitecture))
+ DEFAULTVT=vt05
+ #endif
+ 
+diff -Nur xc.old/programs/xload/get_load.c xc/programs/xload/get_load.c
+--- xc.old/programs/xload/get_load.c	2005-02-19 15:51:13.000000000 +0100
++++ xc/programs/xload/get_load.c	2005-02-19 15:58:39.000000000 +0100
+@@ -354,7 +354,7 @@
+ }
+ #else /* not KVM_ROUTINES */
+ 
+-#if defined(linux) || defined(__GNU_FreeBSD__)
++#if defined(linux) || defined(__FreeBSD_kernel__) || defined(__NetBSD_kernel__)
+ 
+ void InitLoadPoint()
+ {
+diff -Nur xc.old/programs/xterm/main.c xc/programs/xterm/main.c
+--- xc.old/programs/xterm/main.c	2005-02-19 15:51:13.000000000 +0100
++++ xc/programs/xterm/main.c	2005-02-19 15:59:14.000000000 +0100
+@@ -490,7 +490,9 @@
+  * about padding generally store the code in a short, which does not have
+  * enough bits for the extended values.
+  */
++#ifdef __GLIBC__
+ #include <termios.h>
++#endif
+ #ifdef B38400			/* everyone should define this */
+ #define VAL_LINE_SPEED B38400
+ #else /* ...but xterm's used this for a long time */
+diff -Nur xc.old/programs/xterm/xterm_io.h xc/programs/xterm/xterm_io.h
+--- xc.old/programs/xterm/xterm_io.h	2005-02-19 15:51:05.000000000 +0100
++++ xc/programs/xterm/xterm_io.h	2005-02-19 15:58:03.000000000 +0100
+@@ -89,7 +89,7 @@
+ #endif /* macII */
+ 
+ #if defined(__GLIBC__) && !defined(linux)
+-#define USE_POSIX_TERMIOS	/* GNU/Hurd, GNU/KFreeBSD and GNU/KNetBSD */
++
+ #endif
+ 
+ #ifdef __MVS__
+--- xc/config/cf/gnu.cf~	2005-02-19 17:50:46.000000000 +0100
++++ xc/config/cf/gnu.cf	2005-02-20 14:50:20.000000000 +0100
+@@ -173,11 +173,13 @@
+ #define XawI18nDefines        -DHAS_WCHAR_H -DHAS_WCTYPE_H -DNO_WIDEC_H
+ 
+ XCOMM Enable this when we have pthreads.
+-XCOMM #define HasPosixThreads         YES
+-XCOMM #define ThreadedX               YES
+-XCOMM #define HasThreadSafeAPI        YES
+-XCOMM #define ThreadsLibraries        -lpthread
+-XCOMM #define SystemMTDefines         -D_REENTRANT
++#ifndef __GNU__
++#define HasPosixThreads         YES
++#define ThreadedX               YES
++#define HasThreadSafeAPI        YES
++#define ThreadsLibraries        -lpthread
++#define SystemMTDefines         -D_REENTRANT
++#endif
+ 
+ #define HasDevRandom		YES
+ #define PollDevRandom		YES
diff -Nur xfree86-4.3.0.dfsg.1.old/debian/xserver-xfree86.config.in xfree86-4.3.0.dfsg.1/debian/xserver-xfree86.config.in
--- xfree86-4.3.0.dfsg.1.old/debian/xserver-xfree86.config.in	2005-04-04 18:53:56.000000000 +0200
+++ xfree86-4.3.0.dfsg.1/debian/xserver-xfree86.config.in	2005-04-04 18:57:07.000000000 +0200
@@ -652,7 +652,7 @@
     DRIVER_LIST=${DRIVER_LIST:=ati, chips, fbdev, glint, mga, nv, s3, s3virge, savage, sis, tdfx, trident, vga}
     DEFAULT_DRIVER=fbdev
     ;;
-  hurd-i386)
+  *-i386)
     DRIVER_LIST=${DRIVER_LIST:=apm, ark, ati, chips, cirrus, cyrix, fbdev, glint, i128, i740, i810, imstt, mga, neomagic, newport, nsc, nv, rendition, s3, s3virge, savage, siliconmotion, sis, tdfx, tga, trident, tseng, vesa, vga, via, vmware}
     DEFAULT_DRIVER=vesa
     ;;
diff -Nur xfree86-4.3.0.dfsg.1.old/debian/xserver-xfree86.install.hurd-i386 xfree86-4.3.0.dfsg.1/debian/xserver-xfree86.install.hurd-i386
--- xfree86-4.3.0.dfsg.1.old/debian/xserver-xfree86.install.hurd-i386	2005-04-04 18:53:55.000000000 +0200
+++ xfree86-4.3.0.dfsg.1/debian/xserver-xfree86.install.hurd-i386	2005-04-04 18:54:31.000000000 +0200
@@ -104,7 +104,6 @@
 usr/X11R6/lib/modules/input/summa_drv.o
 usr/X11R6/lib/modules/input/tek4957_drv.o
 usr/X11R6/lib/modules/input/void_drv.o
-usr/X11R6/lib/modules/input/wacom_drv.o
 usr/X11R6/lib/modules/libafb.a
 usr/X11R6/lib/modules/libcfb.a
 usr/X11R6/lib/modules/libcfb16.a
@@ -177,5 +176,4 @@
 usr/X11R6/man/man4/via.4x
 usr/X11R6/man/man4/vmware.4x
 usr/X11R6/man/man4/void.4x
-usr/X11R6/man/man4/wacom.4x
 usr/X11R6/man/man5/XF86Config-4.5x
