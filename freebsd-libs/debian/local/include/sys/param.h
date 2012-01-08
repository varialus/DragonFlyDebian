#ifndef _SYS_PARAM_H_
#define _SYS_PARAM_H_
#include_next <sys/param.h>
#define	roundup2(x, y)	(((x)+((y)-1))&(~((y)-1))) /* if y is powers of two */
#endif
