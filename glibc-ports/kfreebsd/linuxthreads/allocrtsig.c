#if 1

#define __SIGRTMIN 65
#define __SIGRTMAX 126
#include <linuxthreads/sysdeps/unix/sysv/linux/allocrtsig.c>

#else

#include <signal/allocrtsig.c>
strong_alias (__libc_current_sigrtmin, __libc_current_sigrtmin_private);
strong_alias (__libc_current_sigrtmax, __libc_current_sigrtmax_private);
strong_alias (__libc_allocate_rtsig, __libc_allocate_rtsig_private);

#endif
