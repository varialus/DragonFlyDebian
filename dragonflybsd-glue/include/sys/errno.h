#ifdef _ERRNO_H

/* We were included by <bits/errno.h> in order to obtain the full list of
   errno codes. Fallback to the real thing. */
# include_next <sys/errno.h>

#else

/* We were included by some FreeBSD program which just wanted <errno.h>
   and chose to use the unportable <sys/errno.h>.  */
# include_next <errno.h>

#endif
