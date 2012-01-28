#ifndef _UNISTD_H_
#define	_UNISTD_H_
#include_next <unistd.h>

#define getopt(argc, argv, options) bsd_getopt(argc, argv, options)

__BEGIN_DECLS

int bsd_getopt(int, char **, char *);
extern int optreset;

__END_DECLS

#endif
