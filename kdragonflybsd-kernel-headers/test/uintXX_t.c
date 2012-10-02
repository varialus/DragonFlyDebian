/* Test that <sys/kern/types.h> provides uintXX_t without explicitly including
   <stdint.h>.  */

#include <sys/kern/types.h>

uint8_t a;
uint16_t b;
uint32_t c;
uint64_t d;
