# Additional header files to be installed in $prefix/include:

ifeq ($(subdir),misc)
sysdep_headers += \
 ../../../../sysv/linux/i386/sys/io.h \
 sys/perm.h \
 sys/vm86.h
endif

# Additional functions, and particular system calls:

ifeq ($(subdir),misc)
# For <sys/io.h> and <sys/perm.h>.
sysdep_routines += i386_get_ioperm i386_set_ioperm iopl
# For <sys/vm86.h>.
sysdep_routines += i386_vm86
endif
