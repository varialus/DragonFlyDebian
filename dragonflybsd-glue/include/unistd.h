#include_next <unistd.h>

#ifndef _UNISTD_H_
#define	_UNISTD_H_

#ifdef __FreeBSD_kernel__
#include <sys/syscall.h>
#include <stdlib.h>		/* setenv */
#endif

#define getopt(argc, argv, options) bsd_getopt(argc, argv, options)

__BEGIN_DECLS

int bsd_getopt(int argc, char *const *argv, const char *options);
extern int optreset;

#ifdef __FreeBSD_kernel__

static inline int
nfssvc (int a, void *b)
{
  return syscall (SYS_nfssvc, a, b);
}

#ifndef SYS_closefrom
#define SYS_closefrom 509
#endif

static inline void
closefrom (int lowfd)
{
  syscall (SYS_closefrom, lowfd);
}

/*
 * Copyright (c) 1989, 1993
 *	The Regents of the University of California.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 4. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include <stddef.h>
#include <sys/sysctl.h>
#include <stdlib.h>

static inline int
getosreldate(void)
{
	int mib[2];
	size_t size;
	int value;
	char *temp;

	if ((temp = getenv("OSVERSION"))) {
		value = atoi(temp);
		return (value);
	}

	mib[0] = CTL_KERN;
	mib[1] = KERN_OSRELDATE;
	size = sizeof value;
	if (sysctl(mib, 2, &value, &size, NULL, 0) == -1)
		return (-1);
	return (value);
}

/*-
 * Copyright (c) 2008 Yahoo!, Inc.
 * All rights reserved.
 * Written by: John Baldwin <jhb@FreeBSD.org>
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the author nor the names of any co-contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include <sys/cdefs.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*
 * Returns true if the named feature is present in the currently
 * running kernel.  A feature's presence is indicated by an integer
 * sysctl node called kern.feature.<feature> that is non-zero.
 */
static inline int
feature_present(const char *feature)
{
	char *mib;
	size_t len;
	int i;

	if ((!strcmp(feature, "inet") || !strcmp(feature, "inet6")) && getosreldate() <= 900038)
		return (1);

	if (asprintf(&mib, "kern.features.%s", feature) < 0)
		return (0);
	len = sizeof(i);
	if (sysctlbyname(mib, &i, &len, NULL, 0) < 0) {
		free(mib);
		return (0);
	}
	free(mib);
	if (len != sizeof(i))
		return (0);
	return (i != 0);
}

static inline int
execvP(const char *name, const char *path, char * const argv[])
{
	setenv ("PATH", path, 1);
	return execvp(name, argv);
}

#endif /* __FreeBSD_kernel__ */

__END_DECLS

#endif
