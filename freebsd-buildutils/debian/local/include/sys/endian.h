#ifdef __FreeBSD_kernel__
/* We have <sys/endian.h>.  Use it.  */
# include_next <sys/endian.h>
#else
# ifndef _SYS_ENDIAN_H_
#  define _SYS_ENDIAN_H_
#  include_next <machine/endian.h>
# endif
#endif
