#include <sysdeps/generic/allocrtsig.c>
strong_alias (__libc_current_sigrtmin, __libc_current_sigrtmin_private);
strong_alias (__libc_current_sigrtmax, __libc_current_sigrtmax_private);
strong_alias (__libc_allocate_rtsig, __libc_allocate_rtsig_private);
