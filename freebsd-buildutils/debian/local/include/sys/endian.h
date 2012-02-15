#ifdef __FreeBSD_kernel__
/* We have <sys/endian.h>.  Use it.  */
# include_next <sys/endian.h>
#else
# ifndef _SYS_ENDIAN_H_
#  define _SYS_ENDIAN_H_
#  include <machine/endian.h>
# endif
#endif
