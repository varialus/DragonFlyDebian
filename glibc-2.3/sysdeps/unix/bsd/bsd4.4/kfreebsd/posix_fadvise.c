/* 'posix_fadvise64' is the same as 'posix_fadvise', because
   __off64_t == __off_t and O_LARGEFILE == 0.  */

#include <sysdeps/generic/posix_fadvise.c>

weak_alias (posix_fadvise, posix_fadvise64)
