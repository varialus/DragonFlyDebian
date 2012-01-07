#ifndef	_SYS_CDEFS_H_
#define	_SYS_CDEFS_H_
#include_next <sys/cdefs.h>
#define	__FBSDID(s)
#define __dead2		__attribute__((__noreturn__))
#define __unused	__attribute__((__unused__))
#define __printflike(fmtarg, firstvararg) \
	__attribute__((__format__ (__printf__, fmtarg, firstvararg)))
#endif
