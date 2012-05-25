#ifdef __FreeBSD_kernel__
#include <sys/kern/queue.h>
#else
#include_next <sys/queue.h>
#endif
