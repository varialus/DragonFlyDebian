/* GNU/kFreeBSD <machine/_types.h> is patched to check for the GNU form
   (_SYS_CDEFS_H) instead of BSD form (_SYS_CDEFS_H_).  */
#if defined(_SYS_CDEFS_H_) && !defined(_SYS_CDEFS_H)
#define _SYS_CDEFS_H
#endif

#include_next <machine/_types.h>
