/* BSD-style include guards (used by e.g. alias_local.h) */
#ifndef _NETINET_UDP_H_
#define _NETINET_UDP_H_

#include <features.h>
#if __FAVOR_BSD
#  include_next <netinet/udp.h>
#else
#  define __FAVOR_BSD 1
#  include_next <netinet/udp.h>
#  undef __FAVOR_BSD
#endif

#endif
