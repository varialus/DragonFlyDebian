#ifndef LIBFREEBSD_STDLIB_H
#define LIBFREEBSD_STDLIB_H

#include <sys/stat.h>		/* dev_t, mode_t */
#include <bsd/stdlib.h>

char *devname (dev_t dev, mode_t type);
char *devname_r (dev_t dev, mode_t type, char *buf, int len);

#endif
