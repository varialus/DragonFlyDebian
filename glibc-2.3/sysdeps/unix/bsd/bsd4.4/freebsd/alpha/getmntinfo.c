/* 'getmntinfo64' is the same as 'getmntinfo', because
   __fsblkcnt64_t == __fsblkcnt_t and __fsfilcnt64_t == __fsfilcnt_t.  */

#define getmntinfo64 __no_getmntinfo64_decl
#include <sysdeps/unix/bsd/bsd4.4/freebsd/getmntinfo.c>
#undef getmntinfo64

weak_alias (__getmntinfo, getmntinfo64)
