/* Copyright (C) 1997, 2000, 2002 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
   02111-1307 USA.  */

/* FreeBSD version.  */

#ifndef _NETINET_IN_H
# error "Never use <bits/in.h> directly; include <netinet/in.h> instead."
#endif


/* Link numbers.  */
#define	IMPLINK_IP		155
#define	IMPLINK_LOWEXPER	156
#define	IMPLINK_HIGHEXPER	158


/* Options for use with `getsockopt' and `setsockopt' at the IP level.
   The first word in the comment at the right is the data type used;
   "bool" means a boolean value stored in an `int'.  */
#define	IP_OPTIONS	1	/* ip_opts; IP per-packet options.  */
#define	IP_HDRINCL	2	/* int; Header is included with data.  */
#define	IP_TOS		3	/* int; IP type of service and precedence.  */
#define	IP_TTL		4	/* int; IP time to live.  */
#define	IP_RECVOPTS	5	/* bool; Receive all IP options w/datagram.  */
#define	IP_RECVRETOPTS	6	/* bool; Receive IP options for response.  */
#define	IP_RECVDSTADDR	7	/* bool; Receive IP dst addr w/datagram.  */
#define	IP_RETOPTS	8	/* ip_opts; Set/get IP per-packet options.  */
#define IP_MULTICAST_IF 9	/* in_addr; set/get IP multicast i/f */
#define IP_MULTICAST_TTL 10	/* u_char; set/get IP multicast ttl */
#define IP_MULTICAST_LOOP 11	/* i_char; set/get IP multicast loopback */
#define IP_ADD_MEMBERSHIP 12	/* ip_mreq; add an IP group membership */
#define IP_DROP_MEMBERSHIP 13	/* ip_mreq; drop an IP group membership */
#define IP_MULTICAST_VIF 14	/* set/get IP mcast virt. iface */
#define IP_RSVP_ON	15	/* enable RSVP in kernel */
#define IP_RSVP_OFF	16	/* disable RSVP in kernel */
#define IP_RSVP_VIF_ON	17	/* set RSVP per-vif socket */
#define IP_RSVP_VIF_OFF	18	/* unset RSVP per-vif socket */
#define IP_PORTRANGE	19	/* int; range to choose for unspec port */
#define	IP_RECVIF	20	/* bool; receive reception if w/dgram */
/* for IPSEC */
#define	IP_IPSEC_POLICY	21	/* int; set/get security policy */
#define	IP_FAITH	22	/* bool; accept FAITH'ed connections */

#define	IP_FW_ADD    	50	/* add a firewall rule to chain */
#define	IP_FW_DEL    	51	/* delete a firewall rule from chain */
#define	IP_FW_FLUSH   	52	/* flush firewall rule chain */
#define	IP_FW_ZERO    	53	/* clear single/all firewall counter(s) */
#define	IP_FW_GET     	54	/* get entire firewall rule chain */
#define	IP_FW_RESETLOG	55	/* reset logging counters */

#define	IP_DUMMYNET_CONFIGURE	60	/* add/configure a dummynet pipe */
#define	IP_DUMMYNET_DEL		61	/* delete a dummynet pipe from chain */
#define	IP_DUMMYNET_FLUSH	62	/* flush dummynet */
#define	IP_DUMMYNET_GET		64	/* get entire dummynet pipes */

/*
 * Defaults and limits for options
 */
#define	IP_DEFAULT_MULTICAST_TTL  1	/* normally limit m'casts to 1 hop  */
#define	IP_DEFAULT_MULTICAST_LOOP 1	/* normally hear sends if a member  */
#define	IP_MAX_MEMBERSHIPS	20	/* per socket */

/*
 * Argument for IP_PORTRANGE:
 * - which range to search when port is unspecified at bind() or connect()
 */
#define	IP_PORTRANGE_DEFAULT	0	/* default range */
#define	IP_PORTRANGE_HIGH	1	/* "high" - request firewall bypass */
#define	IP_PORTRANGE_LOW	2	/* "low" - vouchsafe security */

/*
 * Names for IP sysctl objects
 */
#define	IPCTL_FORWARDING	1	/* act as router */
#define	IPCTL_SENDREDIRECTS	2	/* may send redirects when forwarding */
#define	IPCTL_DEFTTL		3	/* default TTL */
#ifdef notyet
#define	IPCTL_DEFMTU		4	/* default MTU */
#endif
#define IPCTL_RTEXPIRE		5	/* cloned route expiration time */
#define IPCTL_RTMINEXPIRE	6	/* min value for expiration time */
#define IPCTL_RTMAXCACHE	7	/* trigger level for dynamic expire */
#define	IPCTL_SOURCEROUTE	8	/* may perform source routes */
#define	IPCTL_DIRECTEDBROADCAST	9	/* may re-broadcast received packets */
#define IPCTL_INTRQMAXLEN	10	/* max length of netisr queue */
#define	IPCTL_INTRQDROPS	11	/* number of netisr q drops */
#define	IPCTL_STATS		12	/* ipstat structure */
#define	IPCTL_ACCEPTSOURCEROUTE	13	/* may accept source routed packets */
#define	IPCTL_FASTFORWARDING	14	/* use fast IP forwarding code */
#define	IPCTL_KEEPFAITH		15	/* FAITH IPv4->IPv6 translater ctl */
#define	IPCTL_GIF_TTL		16	/* default TTL for gif encap packet */
#define	IPCTL_MAXID		17

/* Structure used to describe IP options for IP_OPTIONS and IP_RETOPTS.
   The `ip_dst' field is used for the first-hop gateway when using a
   source route (this gets put into the header proper).  */
struct ip_opts
  {
    struct in_addr ip_dst;	/* First hop; zero without source route.  */
    char ip_opts[40];		/* Actually variable in size.  */
  };

/* Structure used for IP_ADD_MEMBERSHIP and IP_DROP_MEMBERSHIP. */
struct ip_mreq
  {
    struct in_addr imr_multiaddr;	/* IP multicast address of group */
    struct in_addr imr_interface;	/* local IP address of interface */
  };

/* IPV6 socket options.  */
#define IPV6_ADDRFORM		1
#define IPV6_RXINFO		2
#define IPV6_RXHOPOPTS		3
#define IPV6_RXDSTOPTS		4
#define IPV6_RTHDR		5
#define IPV6_PKTOPTIONS		6
#define IPV6_CHECKSUM		7
#define IPV6_HOPLIMIT		8

#define IPV6_TXINFO		IPV6_RXINFO
#define SCM_SRCINFO		IPV6_TXINFO
#define SCM_SRCRT		IPV6_RXSRCRT

#define IPV6_UNICAST_HOPS	16
#define IPV6_MULTICAST_IF	17
#define IPV6_MULTICAST_HOPS	18
#define IPV6_MULTICAST_LOOP	19
#define IPV6_JOIN_GROUP		20
#define IPV6_LEAVE_GROUP	21

/* Obsolete synonyms for the above.  */
#define IPV6_ADD_MEMBERSHIP	IPV6_JOIN_GROUP
#define IPV6_DROP_MEMBERSHIP	IPV6_LEAVE_GROUP

/* Routing header options for IPv6.  */
#define IPV6_RTHDR_LOOSE	0	/* Hop doesn't need to be neighbour. */
#define IPV6_RTHDR_STRICT	1	/* Hop must be a neighbour.  */

#define IPV6_RTHDR_TYPE_0	0	/* IPv6 Routing header type 0.  */
