/* 'posix_fallocate64' is the same as 'posix_fallocate', because
   __off64_t == __off_t and O_LARGEFILE == 0.  */

#include <sysdeps/posix/posix_fallocate.c>

weak_alias (posix_fallocate, posix_fallocate64)
