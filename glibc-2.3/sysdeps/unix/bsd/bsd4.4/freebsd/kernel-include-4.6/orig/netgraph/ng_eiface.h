/*
 * ng_eiface.h
 *
 * Copyright (c) 1999-2000, Vitaly V Belekhov
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice unmodified, this list of conditions, and the following
 *    disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 * 	$Id: ng_eiface.h,v 1.4 2000/03/06 09:46:14 vitaly Exp $
 * $FreeBSD: src/sys/netgraph/ng_eiface.h,v 1.2.2.1 2002/04/15 00:16:02 julian Exp $
 */

#ifndef _NETGRAPH_EIFACE_H_
#define _NETGRAPH_EIFACE_H_

/* Node type name and magic cookie */
#define NG_EIFACE_NODE_TYPE		"eiface"
#define NGM_EIFACE_COOKIE		948105892

/* Interface base name */
#define NG_EIFACE_EIFACE_NAME		"nge"
#define NG_EIFACE_EIFACE_NAME_MAX		15

/* My hook names */
#define NG_EIFACE_HOOK_ETHER		"ether"

/* MTU bounds */
#define NG_EIFACE_MTU_MIN		72
#define NG_EIFACE_MTU_MAX		2312
#define NG_EIFACE_MTU_DEFAULT		1500

/* Netgraph commands */
enum {
	NGM_EIFACE_GET_IFNAME = 1,	/* returns struct ng_eiface_ifname */
	NGM_EIFACE_GET_IFADDRS,		/* returns list of addresses */
	NGM_EIFACE_SET,			/* set ethernet address */
};

struct ng_eiface_ifname {
	char    ngif_name[NG_EIFACE_EIFACE_NAME_MAX + 1];
};

struct ng_eiface_par {
    u_char oct0;
    u_char oct1;
    u_char oct2;
    u_char oct3;
    u_char oct4;
    u_char oct5;
};

static const struct ng_parse_struct_info ng_eiface_par_fields = {
  {
    { "oct0",		&ng_parse_int8_type	},
    { "oct1",		&ng_parse_int8_type	},
    { "oct2",		&ng_parse_int8_type	},
    { "oct3",		&ng_parse_int8_type	},
    { "oct4",		&ng_parse_int8_type	},
    { "oct5",		&ng_parse_int8_type	},
    { NULL },
  }
};

static const struct ng_parse_type ng_eiface_par_type = {
	&ng_parse_struct_type,
	&ng_eiface_par_fields
};

static const struct ng_cmdlist ng_eiface_cmdlist[] = {
	{
	  NGM_EIFACE_COOKIE,
	  NGM_EIFACE_SET,
	  "set",
	  &ng_eiface_par_type,
	  NULL
	},
	{ 0 }
};


#endif /* _NETGRAPH_EIFACE_H_ */
