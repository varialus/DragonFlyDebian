#include_next <sys/types.h>

#ifndef _SYS_TYPES_H_

# ifdef __FreeBSD_kernel__
#  include <sys/kern/types.h>
# else
#  define _SYS_TYPES_H_
#  include <sys/cdefs.h>
#  include <stdint.h> /* uintXX_t */

/* Emulate implicit includes on FreeBSD */
#  include <machine/endian.h>
#  include <sys/_types.h>
# endif

#endif
