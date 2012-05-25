#include_next <sys/param.h>

#ifndef _SYS_PARAM_H_
#define _SYS_PARAM_H_

#undef __FreeBSD_version
#define __FreeBSD_version	1000010

/* FreeBSD code expects that this file implicitly defines SIG* macros.  */
#include <signal.h>

/* FreeBSD code expects that this file includes... */
#include <sys/types.h>

#endif
