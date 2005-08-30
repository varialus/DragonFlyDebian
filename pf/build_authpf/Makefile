# $FreeBSD: src/usr.sbin/authpf/Makefile,v 1.1 2004/02/28 21:50:50 mlaier Exp $

.PATH:	${.CURDIR}/../authpf
.PATH:	${.CURDIR}/../pfctl

PROG=	authpf
MAN=	authpf.8
BINOWN=	root
BINGRP= authpf
BINMODE= 6555

SRCS=   authpf.c parse.y pfctl_parser.c pf_print_state.c pfctl_altq.c
SRCS+=  pfctl_radix.c pfctl_osfp.c

CFLAGS+= -I../pfctl -Wall -Werror
CFLAGS+= -I../contrib
CFLAGS+= -include bsd/bsd.h -D_GNU_SOURCE

# XXX ALTQ:
#CFLAGS+= -DENABLE_ALTQ
CFLAGS+= -I${.CURDIR}/../build_pfctl/missing

#LDADD+= -lm -lmd -lbsd
LDADD+= -lm -lbsd
DPADD+= ${LIBM} ${LIBMD}

CLEANFILES+=y.tab.h

.include <bsd.prog.mk>
