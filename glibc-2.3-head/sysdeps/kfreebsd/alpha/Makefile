# Additional header files to be installed in $prefix/include:

ifeq ($(subdir),misc)
sysdep_headers += \
 machine/pal.h
endif

# Additional functions, and particular system calls:

ifeq ($(subdir),io)
sysdep_routines += sys_poll
endif

ifeq ($(subdir),math)
sysdep_routines += ieee_get_fp_control ieee_set_fp_control
endif
