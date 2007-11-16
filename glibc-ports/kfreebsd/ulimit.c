/* just use internal functions */
#define getrlimit __getrlimit
#define setrlimit __setrlimit
#define sysconf __sysconf
#include <sysdeps/unix/bsd/ulimit.c>
