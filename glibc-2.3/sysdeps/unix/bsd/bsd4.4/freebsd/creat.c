/* 'creat64' is the same as 'creat', because __off64_t == __off_t and
   O_LARGEFILE == 0.  */

#include <sysdeps/generic/creat.c>

weak_alias (creat, creat64)
