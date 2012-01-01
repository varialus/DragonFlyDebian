#include <features.h>
#if __FAVOR_BSD
#  include_next <netinet/tcp.h>
#else
#  define __FAVOR_BSD 1
#  include_next <netinet/tcp.h>
#  undef __FAVOR_BSD
#endif
