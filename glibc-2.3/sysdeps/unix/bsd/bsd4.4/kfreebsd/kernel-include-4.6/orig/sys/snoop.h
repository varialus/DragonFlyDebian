/*
 * Copyright (c) 1995 Ugen J.S.Antsilevich
 *
 * Redistribution and use in source forms, with and without modification,
 * are permitted provided that this entire comment appears intact.
 *
 * Redistribution in binary form may occur without any restrictions.
 * Obviously, it would be nice if you gave credit where credit is due
 * but requiring it would be too onerous.
 *
 * This software is provided ``AS IS'' without any warranties of any kind.
 *
 * Snoop stuff.
 *
 * $FreeBSD: src/sys/sys/snoop.h,v 1.14.2.1 2002/03/11 01:23:05 dd Exp $
 */

#ifndef _SYS_SNOOP_H_
#define	_SYS_SNOOP_H_

#include <sys/ioccom.h>

/*
 * Theese are snoop io controls
 * SNPSTTY accepts 'struct snptty' as input.
 * If ever type or  unit set to -1,snoop device
 * detached from its current tty.
 */

#define SNPSTTY       _IOW('T', 90, dev_t)
#define SNPGTTY       _IOR('T', 89, dev_t)

/*
 * Theese values would be returned by FIONREAD ioctl
 * instead of number of characters in buffer in case
 * of specific errors.
 */
#define SNP_OFLOW		-1
#define SNP_TTYCLOSE		-2
#define SNP_DETACH		-3

#endif /* !_SYS_SNOOP_H_ */
