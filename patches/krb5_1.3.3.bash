#!/bin/bash -e

# Status: in BTS

cat $0 | patch -p1
(cd src && ACLOCAL=true ./util/reconf --force)
exit 0

diff -ur krb5-1.3.3.old/src/appl/gssftp/ftpd/ftpcmd.y krb5-1.3.3/src/appl/gssftp/ftpd/ftpcmd.y
--- krb5-1.3.3.old/src/appl/gssftp/ftpd/ftpcmd.y	2002-10-23 17:00:23.000000000 +0200
+++ krb5-1.3.3/src/appl/gssftp/ftpd/ftpcmd.y	2004-07-29 16:42:02.000000000 +0200
@@ -96,7 +96,7 @@
 #endif
 
 #ifndef NBBY
-#ifdef linux
+#ifdef unix
 #define NBBY 8
 #endif
 #ifdef __pyrsoft
diff -ur krb5-1.3.3.old/src/appl/telnet/telnet/sys_bsd.c krb5-1.3.3/src/appl/telnet/telnet/sys_bsd.c
--- krb5-1.3.3.old/src/appl/telnet/telnet/sys_bsd.c	2002-11-15 21:21:35.000000000 +0100
+++ krb5-1.3.3/src/appl/telnet/telnet/sys_bsd.c	2004-07-29 16:48:53.000000000 +0200
@@ -52,6 +52,9 @@
 #endif /* POSIX_SIGNALS */
 #include <errno.h>
 #include <arpa/telnet.h>
+#ifdef USE_TERMIO
+#include <termios.h>
+#endif
 
 #include "ring.h"
 
@@ -116,32 +119,22 @@
 # define old_tc ottyb
 
 #else	/* USE_TERMIO */
-struct	termio old_tc = { 0 };
-extern struct termio new_tc;
+struct	termios old_tc = { 0 };
+extern struct termios new_tc;
 
 # ifndef	TCSANOW
 #  ifdef TCSETS
 #   define	TCSANOW		TCSETS
 #   define	TCSADRAIN	TCSETSW
-#   define	tcgetattr(f, t) ioctl(f, TCGETS, (char *)t)
 #  else
 #   ifdef TCSETA
 #    define	TCSANOW		TCSETA
 #    define	TCSADRAIN	TCSETAW
-#    define	tcgetattr(f, t) ioctl(f, TCGETA, (char *)t)
 #   else
 #    define	TCSANOW		TIOCSETA
 #    define	TCSADRAIN	TIOCSETAW
-#    define	tcgetattr(f, t) ioctl(f, TIOCGETA, (char *)t)
 #   endif
 #  endif
-#  define	tcsetattr(f, a, t) ioctl(f, a, (char *)t)
-#  define	cfgetospeed(ptr)	((ptr)->c_cflag&CBAUD)
-#  ifdef CIBAUD
-#   define	cfgetispeed(ptr)	(((ptr)->c_cflag&CIBAUD) >> IBSHIFT)
-#  else
-#   define	cfgetispeed(ptr)	cfgetospeed(ptr)
-#  endif
 # endif /* TCSANOW */
 # ifdef	sysV88
 # define TIOCFLUSH TC_PX_DRAIN
@@ -258,7 +251,9 @@
     void
 TerminalFlushOutput()
 {
-#ifdef	TIOCFLUSH
+#if defined(USE_TERMIO)
+    (void) tcflush (fileno(stdout), TCIOFLUSH);
+#elif defined(TIOCFLUSH)
     (void) ioctl(fileno(stdout), TIOCFLUSH, (char *) 0);
 #else
     (void) ioctl(fileno(stdout), TCFLSH, (char *) 0);
diff -ur krb5-1.3.3.old/src/appl/telnet/telnetd/configure.in krb5-1.3.3/src/appl/telnet/telnetd/configure.in
--- krb5-1.3.3.old/src/appl/telnet/telnetd/configure.in	2002-11-15 21:21:51.000000000 +0100
+++ krb5-1.3.3/src/appl/telnet/telnetd/configure.in	2004-07-29 16:42:02.000000000 +0200
@@ -22,7 +22,7 @@
 fi
 fi
 AC_HEADER_TIME
-AC_CHECK_HEADERS(string.h arpa/nameser.h utmp.h sys/time.h sys/tty.h sac.h sys/ptyvar.h sys/filio.h sys/stream.h sys/utsname.h memory.h)
+AC_CHECK_HEADERS(string.h arpa/nameser.h utmp.h sys/time.h sys/tty.h sys/ttycom.h sac.h sys/ptyvar.h sys/filio.h sys/stream.h sys/utsname.h memory.h)
 AC_CHECK_FUNCS(gettosbyname vsnprintf)
 KRB5_AC_INET6
 dnl
diff -ur krb5-1.3.3.old/src/appl/telnet/telnetd/telnetd.c krb5-1.3.3/src/appl/telnet/telnetd/telnetd.c
--- krb5-1.3.3.old/src/appl/telnet/telnetd/telnetd.c	2003-01-10 01:14:14.000000000 +0100
+++ krb5-1.3.3/src/appl/telnet/telnetd/telnetd.c	2004-07-29 16:42:02.000000000 +0200
@@ -59,6 +59,9 @@
 #include <stdlib.h>
 #include <libpty.h>
 #include <com_err.h>
+#ifdef HAVE_SYS_TTYCOM_H
+#include <sys/ttycom.h>
+#endif
 #if	defined(_SC_CRAY_SECURE_SYS)
 #include <sys/sysv.h>
 #include <sys/secdev.h>
@@ -97,10 +100,15 @@
 
 int	registerd_host_only = 0;
 
+#ifdef USE_TERMIO
+# include <termios.h>
+#else
+# include <termio.h>
+#endif
+
 #ifdef	STREAMSPTY
 #include <sys/stream.h>
 # include <stropts.h>
-# include <termio.h>
 /* make sure we don't get the bsd version */
 #ifdef HAVE_SYS_TTY_H
 # include "/usr/include/sys/tty.h"
diff -ur krb5-1.3.3.old/src/appl/telnet/telnetd/termstat.c krb5-1.3.3/src/appl/telnet/telnetd/termstat.c
--- krb5-1.3.3.old/src/appl/telnet/telnetd/termstat.c	2001-08-03 00:07:00.000000000 +0200
+++ krb5-1.3.3/src/appl/telnet/telnetd/termstat.c	2004-07-29 16:44:07.000000000 +0200
@@ -33,6 +33,7 @@
 
 /* based on @(#)termstat.c	8.1 (Berkeley) 6/4/93 */
 
+#include <sys/ioctl.h> /* TIOCSWINSZ */
 #include "telnetd.h"
 
 /*
