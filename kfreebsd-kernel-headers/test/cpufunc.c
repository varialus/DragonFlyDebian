#include <sys/types.h>

/* Include potentially conflicting declarations: inb(), inw(), outb(), etc. */
#include <sys/io.h>

/* Include <machine/cpufunc.h> WITHOUT explicit <stdint.h>. */
#include <machine/cpufunc.h>
