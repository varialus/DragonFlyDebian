#ifndef _SYS_TYPES_H_
#define	_SYS_TYPES_H_
#include_next <sys/types.h>
#include <sys/cdefs.h>
#include <stdint.h> /* uintXX_t */

/* Emulate implicit includes on FreeBSD */
#include <machine/endian.h>
#ifdef __FreeBSD_kernel__
#include <sys/_types.h>
#endif

#endif
