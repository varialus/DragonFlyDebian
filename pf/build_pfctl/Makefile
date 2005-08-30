# $FreeBSD: src/sbin/pfctl/Makefile,v 1.3 2004/07/07 17:33:20 ru Exp $

.PATH:	${.CURDIR}/../pfctl
.PATH:	${.CURDIR}/../man

PROG=	pfctl
MAN=	pfctl.8 pf.4 pflog.4 pfsync.4 pf.conf.5 pf.os.5

SRCS = pfctl.c parse.y pfctl_parser.c pf_print_state.c pfctl_altq.c
SRCS+= pfctl_osfp.c pfctl_radix.c pfctl_table.c pfctl_qstats.c

CFLAGS+= -Wall -Wmissing-prototypes -Wno-uninitialized
CFLAGS+= -Wstrict-prototypes -I${.CURDIR}/../pfctl
CFLAGS+= -I${.CURDIR}/../contrib
CFLAGS+= -include bsd/bsd.h -D_GNU_SOURCE

# XXX ALTQ
CFLAGS+= -DENABLE_ALTQ
#CFLAGS+= -I${.CURDIR}/missing

YFLAGS=

LDADD+=	-lm -lbsd
DPADD+=	${LIBM}

.include <bsd.prog.mk>
