diff -x control -x po -ur wine-0.0.20040716.old/configure wine-0.0.20040716/configure
--- wine-0.0.20040716.old/configure	2004-07-17 02:52:37.000000000 +0200
+++ wine-0.0.20040716/configure	2004-10-21 23:52:28.000000000 +0200
@@ -14679,7 +14679,7 @@
 esac
 
 case $host_os in
-  linux*)
+  linux* | gnu* | k*bsd*-gnu)
     WINE_BINARIES="wine-glibc wine-kthread wine-pthread wine-preloader"
 
     MAIN_BINARY="wine-glibc"
@@ -17061,6 +17061,8 @@
 
 
 
+case $host_os in
+  linux*)
 echo "$as_me:$LINENO: checking for GNU style IPX support" >&5
 echo $ECHO_N "checking for GNU style IPX support... $ECHO_C" >&6
 if test "${ac_cv_c_ipx_gnu+set}" = set; then
@@ -17196,6 +17198,8 @@
 
   fi
 fi
+;;
+esac
 
 
 echo "$as_me:$LINENO: checking for an ANSI C-conforming const" >&5
diff -x control -x po -ur wine-0.0.20040716.old/configure.ac wine-0.0.20040716/configure.ac
--- wine-0.0.20040716.old/configure.ac	2004-07-06 23:01:19.000000000 +0200
+++ wine-0.0.20040716/configure.ac	2004-10-21 23:52:08.000000000 +0200
@@ -990,7 +990,7 @@
 esac
 
 case $host_os in
-  linux*)
+  linux* | gnu* | k*bsd*-gnu)
     AC_SUBST(WINE_BINARIES,"wine-glibc wine-kthread wine-pthread wine-preloader")
     AC_SUBST(MAIN_BINARY,"wine-glibc")
     ;;
@@ -1214,6 +1214,8 @@
 
 dnl **** Check for IPX headers (currently Linux only) ****
 
+case $host_os in
+  linux*)
 AC_CACHE_CHECK([for GNU style IPX support], ac_cv_c_ipx_gnu,
  AC_TRY_COMPILE(
    [#include <sys/types.h>
@@ -1249,6 +1251,8 @@
       AC_DEFINE(HAVE_IPX_LINUX, 1, [Define if IPX includes are taken from Linux kernel])
   fi
 fi
+;;
+esac
 
 dnl **** Check for types ****
 
diff -x control -x po -ur wine-0.0.20040716.old/debian/changelog wine-0.0.20040716/debian/changelog
--- wine-0.0.20040716.old/debian/changelog	2004-10-04 23:32:26.000000000 +0200
+++ wine-0.0.20040716/debian/changelog	2004-10-04 23:39:53.000000000 +0200
@@ -1,3 +1,9 @@
+wine (0.0.20040716-1.2+kbsd) unreleased; urgency=low
+
+  * foo
+
+ -- Robert Millan <rmh@debian.org>  Mon,  4 Oct 2004 23:39:46 +0200
+
 wine (0.0.20040716-1.2) unstable; urgency=low
 
   * NMU.
diff -x control -x po -ur wine-0.0.20040716.old/debian/control.in wine-0.0.20040716/debian/control.in
--- wine-0.0.20040716.old/debian/control.in	2004-10-04 23:34:19.000000000 +0200
+++ wine-0.0.20040716/debian/control.in	2004-12-01 02:56:11.000000000 +0100
@@ -6,14 +6,15 @@
  xlibs-dev, xlibmesa-dev | libgl-dev, xlibmesa-glu-dev | xlibmesa-dev (<= 4.2.1-4) | libglu-dev,
  freeglut3-dev | libglut-dev | glutg3-dev,
  libncurses5-dev, libcupsys2-dev, libjpeg62-dev | libjpeg-dev, libungif4-dev,
- libfreetype6-dev, libasound2-dev, libjack0.80.0-dev | libjack-dev,
- libartsc0-dev | libarts-dev, libaudio-dev | nas-dev, libsane-dev, libusb-dev,
- libicu21-dev | libicu-dev, libfontconfig1-dev, libssl-dev, libcapi20-dev
+ libfreetype6-dev, libasound2-dev [@linux-gnu_arches@], libjack0.80.0-dev | libjack-dev,
+ libartsc0-dev | libarts-dev, libaudio-dev | nas-dev, libsane-dev [@linux-gnu_arches@], libusb-dev [@linux-gnu_arches@],
+ libicu21-dev [@linux-gnu_arches@] | libicu-dev [@linux-gnu_arches@], libfontconfig1-dev, libssl-dev, libcapi20-dev [@linux-gnu_arches@],
+ type-handling (>= 0.2.1)
 Build-Depends-Indep: debhelper (>= 3.0), docbook-utils, c2man
 Standards-Version: 3.6.0
 
 Package: wine
-Architecture: i386 hurd-i386 freebsd-i386 netbsd-i386 powerpc hurd-powerpc freebsd-powerpc netbsd-powerpc sparc hurd-sparc freebsd-sparc netbsd-sparc
+Architecture: @arches@
 Depends: ${debconf-depends}, libwine (= ${Source-Version}), xbase-clients (>= 4.0) | xcontrib
 Suggests: wine-doc, wine-utils, winesetup, msttcorefonts, binfmt-support
 Conflicts: binfmt-support (<< 1.1.2)
@@ -27,7 +28,7 @@
  Wine is often updated.
 
 Package: libwine-dev
-Architecture: i386 hurd-i386 freebsd-i386 netbsd-i386 powerpc hurd-powerpc freebsd-powerpc netbsd-powerpc sparc hurd-sparc freebsd-sparc netbsd-sparc
+Architecture: @arches@
 Section: libdevel
 Depends: libwine (= ${Source-Version}), libc6-dev
 Replaces: libwine (<< 0.0.20010216)
@@ -43,7 +44,7 @@
 
 Package: libwine
 Section: libs
-Architecture: i386 hurd-i386 freebsd-i386 netbsd-i386 powerpc hurd-powerpc freebsd-powerpc netbsd-powerpc sparc hurd-sparc freebsd-sparc netbsd-sparc
+Architecture: @arches@
 Depends: ${debconf-depends}, ${shlibs:Depends}${freetype}
 Replaces: libwine0.0.971116, wine (<< 0.0.20040213)
 Conflicts: libwine0.0.971116
@@ -58,7 +59,7 @@
 
 Package: libwine-alsa
 Section: libs
-Architecture: i386 hurd-i386 freebsd-i386 netbsd-i386 powerpc hurd-powerpc freebsd-powerpc netbsd-powerpc sparc hurd-sparc freebsd-sparc netbsd-sparc
+Architecture: @linux-gnu_arches@
 Depends: libwine (= ${Source-Version}), ${shlibs:Depends}
 Description: Windows Emulator (ALSA Sound Module)
  This is an ALPHA release of Wine, the MS-Windows emulator.  This is
@@ -70,7 +71,7 @@
 
 Package: libwine-arts
 Section: libs
-Architecture: i386 hurd-i386 freebsd-i386 netbsd-i386 powerpc hurd-powerpc freebsd-powerpc netbsd-powerpc sparc hurd-sparc freebsd-sparc netbsd-sparc
+Architecture: @arches@
 Depends: libwine (= ${Source-Version}), ${shlibs:Depends}
 Replaces: libwine (<< 0.0.20020710)
 Description: Windows Emulator (aRts Sound Module)
@@ -83,7 +84,7 @@
 
 Package: libwine-capi
 Section: libs
-Architecture: i386 hurd-i386 freebsd-i386 netbsd-i386 powerpc hurd-powerpc freebsd-powerpc netbsd-powerpc sparc hurd-sparc freebsd-sparc netbsd-sparc
+Architecture: @linux-gnu_arches@
 Depends: libwine (= ${Source-Version}), ${shlibs:Depends}
 Description: Windows Emulator (ISDN Module)
  This is an ALPHA release of Wine, the MS-Windows emulator.  This is
@@ -96,7 +97,7 @@
 
 Package: libwine-jack
 Section: libs
-Architecture: i386 hurd-i386 freebsd-i386 netbsd-i386 powerpc hurd-powerpc freebsd-powerpc netbsd-powerpc sparc hurd-sparc freebsd-sparc netbsd-sparc
+Architecture: @arches@
 Depends: libwine (= ${Source-Version}), ${shlibs:Depends}${jack}
 Description: Windows Emulator (JACK Sound Module)
  This is an ALPHA release of Wine, the MS-Windows emulator.  This is
@@ -108,7 +109,7 @@
 
 Package: libwine-nas
 Section: libs
-Architecture: i386 hurd-i386 freebsd-i386 netbsd-i386 powerpc hurd-powerpc freebsd-powerpc netbsd-powerpc sparc hurd-sparc freebsd-sparc netbsd-sparc
+Architecture: @arches@
 Depends: libwine (= ${Source-Version}), ${shlibs:Depends}
 Replaces: libwine (<< 0.0.20020710)
 Description: Windows Emulator (NAS Sound Module)
@@ -121,7 +122,7 @@
 
 Package: libwine-print
 Section: libs
-Architecture: i386 hurd-i386 freebsd-i386 netbsd-i386 powerpc hurd-powerpc freebsd-powerpc netbsd-powerpc sparc hurd-sparc freebsd-sparc netbsd-sparc
+Architecture: @arches@
 Depends: libwine (= ${Source-Version}), ${shlibs:Depends}${freetype}${cupsys}
 Replaces: libwine (<< 0.0.20020710)
 Description: Windows Emulator (Printing Module)
@@ -135,7 +136,7 @@
 
 Package: libwine-twain
 Section: libs
-Architecture: i386 hurd-i386 freebsd-i386 netbsd-i386 powerpc hurd-powerpc freebsd-powerpc netbsd-powerpc sparc hurd-sparc freebsd-sparc netbsd-sparc
+Architecture: @arches@
 Depends: libwine (= ${Source-Version}), ${shlibs:Depends}
 Replaces: libwine (<< 0.0.20020710)
 Description: Windows Emulator (Scanner Module)
@@ -159,7 +160,7 @@
  Wine is often updated.
 
 Package: wine-utils
-Architecture: i386 hurd-i386 freebsd-i386 netbsd-i386 powerpc hurd-powerpc freebsd-powerpc netbsd-powerpc sparc hurd-sparc freebsd-sparc netbsd-sparc
+Architecture: @arches@
 Depends: libwine (= ${Source-Version}), wine
 Replaces: libwine-dev (<< 0.0.20010216)
 Description: Windows Emulator (Utilities)
diff -x control -x po -ur wine-0.0.20040716.old/debian/rules wine-0.0.20040716/debian/rules
--- wine-0.0.20040716.old/debian/rules	2004-10-04 23:32:26.000000000 +0200
+++ wine-0.0.20040716/debian/rules	2004-12-01 06:33:24.000000000 +0100
@@ -85,6 +85,11 @@
 	po2debconf debian/libwine.templates.master > debian/libwine.templates
 	rm -f debian/po/output
 endif
+
+	cat debian/control.in \
+	| sed "s/@arches@/`type-handling i386,powerpc,sparc any`/g" \
+	| sed "s/@linux-gnu_arches@/`type-handling i386,powerpc,sparc linux-gnu`/g" \
+	> debian/control
 	dh_clean
 
 install-indep: build-indep
@@ -106,9 +111,9 @@
 	dh_testdir
 	dh_testroot
 	# clean up first in case the package maintainer is experimenting again
-	dh_clean -a -k
+	dh_clean -s -k
 	# create installation directories
-	dh_installdirs -a
+	dh_installdirs -s
 
 	# install wine, libwine, and tools
 	$(MAKE) install prefix=`pwd`/debian/tmp/usr libdir=`pwd`/debian/tmp/usr/lib
@@ -154,7 +159,7 @@
 
 	# distribute the files in debian/tmp into debian/<packagename>
 	# according to the <packagename>.files files
-	dh_movefiles -a
+	dh_movefiles -s
 
 	# distribute files we want that weren't in debian/tmp
 	cp dlls/twain/README debian/libwine-twain/usr/share/doc/libwine-twain
@@ -173,9 +178,11 @@
 	cp tools/winedump/README debian/wine-utils/usr/share/doc/wine-utils/README.winedump
 
 	# split up libwine
+ifeq ($(DEB_HOST_GNU_SYSTEM),linux)
 	mv debian/libwine/usr/lib/wine/winealsa* debian/libwine-alsa/usr/lib/wine
-	mv debian/libwine/usr/lib/wine/winearts* debian/libwine-arts/usr/lib/wine
 	mv debian/libwine/usr/lib/wine/capi*     debian/libwine-capi/usr/lib/wine
+endif
+	mv debian/libwine/usr/lib/wine/winearts* debian/libwine-arts/usr/lib/wine
 	mv debian/libwine/usr/lib/wine/winejack* debian/libwine-jack/usr/lib/wine
 	mv debian/libwine/usr/lib/wine/winenas*  debian/libwine-nas/usr/lib/wine
 	mv debian/libwine/usr/lib/wine/wineps*   debian/libwine-print/usr/lib/wine
@@ -237,22 +244,21 @@
 	po2debconf -e utf8 debian/libwine.templates.master > debian/libwine.templates
 endif
 
-	dh_installdebconf -a
-	dh_installdocs -a
-#	dh_installmenu -a
-	dh_installmime -a
+	dh_installdebconf -s
+	dh_installdocs -s
+#	dh_installmenu -s
+	dh_installmime -s
 
 	# FIXME: concatenate wineinstall script
 
-	dh_undocumented -a
-	dh_installchangelogs -a ChangeLog
-	dh_link -a
-	dh_strip -a
-	dh_compress -a
-	dh_fixperms -a
-	dh_makeshlibs -a
-	dh_installdeb -a
-	dh_shlibdeps -a -ldlls:libs:
+	dh_installchangelogs -s ChangeLog
+	dh_link -s
+	dh_strip -s
+	dh_compress -s
+	dh_fixperms -s
+	dh_makeshlibs -s
+	dh_installdeb -s
+	dh_shlibdeps -s -ldlls:libs:
 
 	# if the distro we're compiling for has freetype, depend on it
 	(dpkg -s libfreetype6-dev >/dev/null && \
@@ -279,9 +285,9 @@
 	 echo "icu=, libicu21c102" >> debian/libwine.substvars) || \
 	true
 
-	dh_gencontrol -a -- -V'debconf-depends=debconf (>= $(MINDEBCONFVER))'
-	dh_md5sums -a
-	dh_builddeb -a
+	dh_gencontrol -s -- -V'debconf-depends=debconf (>= $(MINDEBCONFVER))'
+	dh_md5sums -s
+	dh_builddeb -s
 
 binary: binary-indep binary-arch
 .PHONY: build-indep build-arch build clean binary-indep binary-arch binary \
diff -x control -x po -ur wine-0.0.20040716.old/dlls/kernel/cpu.c wine-0.0.20040716/dlls/kernel/cpu.c
--- wine-0.0.20040716.old/dlls/kernel/cpu.c	2004-04-22 00:22:09.000000000 +0200
+++ wine-0.0.20040716/dlls/kernel/cpu.c	2004-12-01 02:38:56.000000000 +0100
@@ -521,7 +521,7 @@
 
         }
         memcpy(si,&cachedsi,sizeof(*si));
-#elif defined(__FreeBSD__)
+#elif defined(__FreeBSD_kernel__)
 	{
 	unsigned int regs[4], regs2[4];
 	int ret, len, num;
diff -x control -x po -ur wine-0.0.20040716.old/dlls/kernel/heap.c wine-0.0.20040716/dlls/kernel/heap.c
--- wine-0.0.20040716.old/dlls/kernel/heap.c	2004-06-24 06:08:33.000000000 +0200
+++ wine-0.0.20040716/dlls/kernel/heap.c	2004-12-01 02:39:34.000000000 +0100
@@ -1043,7 +1043,7 @@
 #ifdef linux
     FILE *f;
 #endif
-#if defined(__FreeBSD__) || defined(__NetBSD__)
+#if defined(__FreeBSD_kernel__) || defined(__NetBSD_kernel__)
     int *tmp;
     int size_sys;
     int mib[2] = { CTL_HW };
@@ -1108,7 +1108,7 @@
                                       / (TotalPhysical / 100);
         }
     }
-#elif defined(__FreeBSD__) || defined(__NetBSD__)
+#elif defined(__FreeBSD_kernel__) || defined(__NetBSD_kernel__)
     mib[1] = HW_PHYSMEM;
     sysctl(mib, 2, NULL, &size_sys, NULL, 0);
     tmp = malloc(size_sys * sizeof(int));
diff -x control -x po -ur wine-0.0.20040716.old/dlls/ntdll/cdrom.c wine-0.0.20040716/dlls/ntdll/cdrom.c
--- wine-0.0.20040716.old/dlls/ntdll/cdrom.c	2004-06-16 21:03:25.000000000 +0200
+++ wine-0.0.20040716/dlls/ntdll/cdrom.c	2004-12-01 02:42:13.000000000 +0100
@@ -414,7 +414,7 @@
 #ifdef linux
    struct cdrom_tochdr		hdr;
    struct cdrom_tocentry	entry;
-#elif defined(__FreeBSD__) || defined(__NetBSD__)
+#elif defined(__FreeBSD_kernel__) || defined(__NetBSD_kernel__)
    struct ioc_toc_header	hdr;
    struct ioc_read_toc_entry	entry;
    struct cd_toc_entry         toc_buffer;
@@ -463,7 +463,7 @@
     }
     cdrom_cache[dev].toc_good = 1;
     io = 0;
-#elif defined(__FreeBSD__) || defined(__NetBSD__)
+#elif defined(__FreeBSD_kernel__) || defined(__NetBSD_kernel__)
 
     io = ioctl(fd, CDIOREADTOCHEADER, &hdr);
     if (io == -1)
@@ -575,7 +575,7 @@
         }
     }
     return 1;
-#elif defined(__NetBSD__)
+#elif defined(__NetBSD_kernel__)
     struct scsi_addr addr;
     if (ioctl(fd, SCIOCIDENTIFY, &addr) != -1)
     {
@@ -595,7 +595,7 @@
         return 1;
     }
     return 0;
-#elif defined(__FreeBSD__)
+#elif defined(__FreeBSD_kernel__)
     FIXME("not implemented for BSD\n");
     return 0;
 #else
@@ -706,7 +706,7 @@
 {
 #if defined(linux)
     return CDROM_GetStatusCode(ioctl(fd, CDROMRESET));
-#elif defined(__FreeBSD__) || defined(__NetBSD__)
+#elif defined(__FreeBSD_kernel__) || defined(__NetBSD_kernel__)
     return CDROM_GetStatusCode(ioctl(fd, CDIOCRESET, NULL));
 #else
     return STATUS_NOT_SUPPORTED;
@@ -722,7 +722,7 @@
 {
 #if defined(linux)
     return CDROM_GetStatusCode(ioctl(fd, doEject ? CDROMEJECT : CDROMCLOSETRAY));
-#elif defined(__FreeBSD__) || defined(__NetBSD__)
+#elif defined(__FreeBSD_kernel__) || defined(__NetBSD_kernel__)
     return CDROM_GetStatusCode((ioctl(fd, CDIOCALLOW, NULL)) ||
                                (ioctl(fd, doEject ? CDIOCEJECT : CDIOCCLOSE, NULL)) ||
                                (ioctl(fd, CDIOCPREVENT, NULL)));
@@ -740,7 +740,7 @@
 {
 #if defined(linux)
     return CDROM_GetStatusCode(ioctl(fd, CDROM_LOCKDOOR, rmv->PreventMediaRemoval));
-#elif defined(__FreeBSD__) || defined(__NetBSD__)
+#elif defined(__FreeBSD_kernel__) || defined(__NetBSD_kernel__)
     return CDROM_GetStatusCode(ioctl(fd, (rmv->PreventMediaRemoval) ? CDIOCPREVENT : CDIOCALLOW, NULL));
 #else
     return STATUS_NOT_SUPPORTED;
@@ -898,7 +898,7 @@
 
  end:
     ret = CDROM_GetStatusCode(io);
-#elif defined(__FreeBSD__) || defined(__NetBSD__)
+#elif defined(__FreeBSD_kernel__) || defined(__NetBSD_kernel__)
     unsigned            size;
     SUB_Q_HEADER*       hdr = (SUB_Q_HEADER*)data;
     int                 io;
@@ -1056,7 +1056,7 @@
 	  msf.cdmsf_min1, msf.cdmsf_sec1, msf.cdmsf_frame1);
  end:
     ret = CDROM_GetStatusCode(io);
-#elif defined(__FreeBSD__) || defined(__NetBSD__)
+#elif defined(__FreeBSD_kernel__) || defined(__NetBSD_kernel__)
     struct	ioc_play_msf	msf;
     int         io;
 
@@ -1101,7 +1101,7 @@
 #if defined(linux)
     struct cdrom_msf0	msf;
     struct cdrom_subchnl sc;
-#elif defined(__FreeBSD__) || defined(__NetBSD__)
+#elif defined(__FreeBSD_kernel__) || defined(__NetBSD_kernel__)
     struct ioc_play_msf	msf;
     struct ioc_read_subchannel	read_sc;
     struct cd_sub_channel_info	sc;
@@ -1154,7 +1154,7 @@
       return CDROM_GetStatusCode(ioctl(fd, CDROMSEEK, &msf));
     }
     return STATUS_SUCCESS;
-#elif defined(__FreeBSD__) || defined(__NetBSD__)
+#elif defined(__FreeBSD_kernel__) || defined(__NetBSD_kernel__)
     read_sc.address_format = CD_MSF_FORMAT;
     read_sc.track          = 0;
     read_sc.data_len       = sizeof(sc);
@@ -1194,7 +1194,7 @@
 {
 #if defined(linux)
     return CDROM_GetStatusCode(ioctl(fd, CDROMPAUSE));
-#elif defined(__FreeBSD__) || defined(__NetBSD__)
+#elif defined(__FreeBSD_kernel__) || defined(__NetBSD_kernel__)
     return CDROM_GetStatusCode(ioctl(fd, CDIOCPAUSE, NULL));
 #else
     return STATUS_NOT_SUPPORTED;
@@ -1210,7 +1210,7 @@
 {
 #if defined(linux)
     return CDROM_GetStatusCode(ioctl(fd, CDROMRESUME));
-#elif defined(__FreeBSD__) || defined(__NetBSD__)
+#elif defined(__FreeBSD_kernel__) || defined(__NetBSD_kernel__)
     return CDROM_GetStatusCode(ioctl(fd, CDIOCRESUME, NULL));
 #else
     return STATUS_NOT_SUPPORTED;
@@ -1226,7 +1226,7 @@
 {
 #if defined(linux)
     return CDROM_GetStatusCode(ioctl(fd, CDROMSTOP));
-#elif defined(__FreeBSD__) || defined(__NetBSD__)
+#elif defined(__FreeBSD_kernel__) || defined(__NetBSD_kernel__)
     return CDROM_GetStatusCode(ioctl(fd, CDIOCSTOP, NULL));
 #else
     return STATUS_NOT_SUPPORTED;
@@ -1253,7 +1253,7 @@
         vc->PortVolume[3] = volc.channel3;
     }
     return CDROM_GetStatusCode(io);
-#elif defined(__FreeBSD__) || defined(__NetBSD__)
+#elif defined(__FreeBSD_kernel__) || defined(__NetBSD_kernel__)
     struct  ioc_vol     volc;
     int io;
 
@@ -1287,7 +1287,7 @@
     volc.channel3 = vc->PortVolume[3];
 
     return CDROM_GetStatusCode(ioctl(fd, CDROMVOLCTRL, &volc));
-#elif defined(__FreeBSD__) || defined(__NetBSD__)
+#elif defined(__FreeBSD_kernel__) || defined(__NetBSD_kernel__)
     struct  ioc_vol     volc;
 
     volc.vol[0] = vc->PortVolume[0];
@@ -1445,7 +1445,7 @@
 
     ret = CDROM_GetStatusCode(io);
 
-#elif defined(__NetBSD__)
+#elif defined(__NetBSD_kernel__)
     scsireq_t cmd;
     int io;
 
@@ -1576,7 +1576,7 @@
 
     ret = CDROM_GetStatusCode(io);
 
-#elif defined(__NetBSD__)
+#elif defined(__NetBSD_kernel__)
     scsireq_t cmd;
     int io;
 
@@ -1712,7 +1712,7 @@
     ret =CDROM_GetStatusCode(ioctl(fd, DVD_AUTH, &auth_info));
     *sid_out = auth_info.lsa.agid;
     return ret;
-#elif defined(__FreeBSD__) || defined(__NetBSD__)
+#elif defined(__FreeBSD_kernel__) || defined(__NetBSD_kernel__)
     return STATUS_NOT_SUPPORTED;
 #else
     return STATUS_NOT_SUPPORTED;
@@ -1735,7 +1735,7 @@
 
     TRACE("\n");
     return CDROM_GetStatusCode(ioctl(fd, DVD_AUTH, &auth_info));
-#elif defined(__FreeBSD__) || defined(__NetBSD__)
+#elif defined(__FreeBSD_kernel__) || defined(__NetBSD_kernel__)
     return STATUS_NOT_SUPPORTED;
 #else
     return STATUS_NOT_SUPPORTED;
@@ -1777,7 +1777,7 @@
 	FIXME("Unknown Keytype 0x%x\n",key->KeyType);
     }
     return ret;
-#elif defined(__FreeBSD__) || defined(__NetBSD__)
+#elif defined(__FreeBSD_kernel__) || defined(__NetBSD_kernel__)
     TRACE("bsd\n");
     return STATUS_NOT_SUPPORTED;
 #else
@@ -1869,7 +1869,7 @@
 	FIXME("Unknown keytype 0x%x\n",key->KeyType);
     }
     return ret;
-#elif defined(__FreeBSD__) || defined(__NetBSD__)
+#elif defined(__FreeBSD_kernel__) || defined(__NetBSD_kernel__)
     TRACE("bsd\n");
     return STATUS_NOT_SUPPORTED;
 #else
diff -x control -x po -ur wine-0.0.20040716.old/dlls/ntdll/signal_i386.c wine-0.0.20040716/dlls/ntdll/signal_i386.c
--- wine-0.0.20040716.old/dlls/ntdll/signal_i386.c	2004-02-24 02:21:56.000000000 +0100
+++ wine-0.0.20040716/dlls/ntdll/signal_i386.c	2004-12-01 04:02:18.000000000 +0100
@@ -206,7 +206,7 @@
 
 #endif /* bsdi */
 
-#if defined(__NetBSD__) || defined(__FreeBSD__) || defined(__OpenBSD__)
+#if defined(__NetBSD_kernel__) || defined(__FreeBSD_kernel__) || defined(__OpenBSD__)
 
 typedef struct sigcontext SIGCONTEXT;
 
@@ -293,7 +293,7 @@
 
 #endif /* __CYGWIN__ */
 
-#if defined(linux) || defined(__NetBSD__) || defined(__FreeBSD__) ||\
+#if defined(linux) || defined(__NetBSD_kernel__) || defined(__FreeBSD_kernel__) ||\
     defined(__OpenBSD__) || defined(__EMX__) || defined(__CYGWIN__)
 
 #define EAX_sig(context)     ((context)->sc_eax)
@@ -313,7 +313,7 @@
 
 #define TRAP_sig(context)    ((context)->sc_trapno)
 
-#ifdef __NetBSD__
+#ifdef __NetBSD_kernel__
 #define ERROR_sig(context)   ((context)->sc_err)
 #endif
 
@@ -323,7 +323,7 @@
 #define FAULT_ADDRESS        ((void *)HANDLER_CONTEXT->cr2)
 #endif
 
-#ifdef __FreeBSD__
+#ifdef __FreeBSD_kernel__
 #define EFL_sig(context)     ((context)->sc_efl)
 /* FreeBSD, see i386/i386/traps.c::trap_pfault va->err kludge  */
 #define FAULT_ADDRESS        ((void *)HANDLER_CONTEXT->sc_err)
@@ -334,7 +334,7 @@
 #define EIP_sig(context)     (*((unsigned long*)&(context)->sc_eip))
 #define ESP_sig(context)     (*((unsigned long*)&(context)->sc_esp))
 
-#endif  /* linux || __NetBSD__ || __FreeBSD__ || __OpenBSD__ */
+#endif  /* linux || __NetBSD_kernel__ || __FreeBSD_kernel__ || __OpenBSD__ */
 
 #if defined(__svr4__) || defined(_SCO_DS) || defined(__sun)
 
@@ -1152,7 +1152,7 @@
     sigaddset( &sig_act.sa_mask, SIGINT );
     sigaddset( &sig_act.sa_mask, SIGUSR2 );
 
-#if defined(linux) || defined(__NetBSD__) || defined(__FreeBSD__) || defined(__OpenBSD__)
+#if defined(linux) || defined(__NetBSD_kernel__) || defined(__FreeBSD_kernel__) || defined(__OpenBSD__)
     sig_act.sa_flags = SA_RESTART;
 #elif defined (__svr4__) || defined(_SCO_DS)
     sig_act.sa_flags = SA_SIGINFO | SA_RESTART;
diff -x control -x po -ur wine-0.0.20040716.old/dlls/winsock/socket.c wine-0.0.20040716/dlls/winsock/socket.c
--- wine-0.0.20040716.old/dlls/winsock/socket.c	2004-06-02 23:33:17.000000000 +0200
+++ wine-0.0.20040716/dlls/winsock/socket.c	2004-12-01 02:55:24.000000000 +0100
@@ -128,10 +128,10 @@
 #include "wine/server.h"
 #include "wine/debug.h"
 
-#ifdef __FreeBSD__
+#ifdef __FreeBSD_kernel__
 # define sipx_network    sipx_addr.x_net
 # define sipx_node       sipx_addr.x_host.c_host
-#endif  /* __FreeBSD__ */
+#endif  /* __FreeBSD_kernel__ */
 
 WINE_DEFAULT_DEBUG_CHANNEL(winsock);
 
diff -x control -x po -ur wine-0.0.20040716.old/include/wine/port.h wine-0.0.20040716/include/wine/port.h
--- wine-0.0.20040716.old/include/wine/port.h	2004-06-14 19:00:38.000000000 +0200
+++ wine-0.0.20040716/include/wine/port.h	2004-12-01 02:38:24.000000000 +0100
@@ -449,4 +449,11 @@
 
 #endif /* NO_LIBWINE_PORT */
 
+#if defined(__FreeBSD__) && !defined(__FreeBSD_kernel__)
+#define __FreeBSD_kernel__
+#endif
+#if defined(__NetBSD__) && !defined(__NetBSD_kernel__)
+#define __NetBSD_kernel__
+#endif
+
 #endif /* !defined(__WINE_WINE_PORT_H) */
diff -x control -x po -ur wine-0.0.20040716.old/server/context_i386.c wine-0.0.20040716/server/context_i386.c
--- wine-0.0.20040716.old/server/context_i386.c	2003-09-06 01:15:41.000000000 +0200
+++ wine-0.0.20040716/server/context_i386.c	2004-12-01 02:59:21.000000000 +0100
@@ -19,6 +19,7 @@
  */
 
 #include "config.h"
+#include "wine/port.h"
 
 #ifdef __i386__
 
@@ -336,7 +337,7 @@
     file_set_error();
 }
 
-#elif defined(__FreeBSD__) || defined(__OpenBSD__) || defined(__NetBSD__)
+#elif defined(__FreeBSD_kernel__) || defined(__OpenBSD__) || defined(__NetBSD_kernel__)
 #include <machine/reg.h>
 
 /* retrieve a thread context */
