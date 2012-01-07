/* BSD-style include guards (used by e.g. alias_local.h) */
#ifndef _NETINET_TCP_H_
#define _NETINET_TCP_H_

#include <features.h>
#if __FAVOR_BSD
#  include_next <netinet/tcp.h>
#else
#  define __FAVOR_BSD 1
#  include_next <netinet/tcp.h>
#  undef __FAVOR_BSD
#endif

#endif
