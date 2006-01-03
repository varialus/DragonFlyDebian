# Additional header files to be installed in $prefix/include:

ifeq ($(subdir),misc)
sysdep_headers += machine/pal.h
sysdep_routines += sys_select sys_utimes sys_lutimes sys_futimes
endif

# Additional functions, and particular system calls:

ifeq ($(subdir),io)
sysdep_routines += sys_poll
endif

ifeq ($(subdir),math)
sysdep_routines += ieee_get_fp_control ieee_set_fp_control
endif

ifeq ($(subdir),posix)
sysdep_routines += sys_nanosleep sys_sched_rr_gi
endif

ifeq ($(subdir),time)
sysdep_routines += sys_adjtime sys_gettimeofday sys_settimeofday sys_getitimer sys_setitimer
endif

ifeq ($(subdir),resource)
sysdep_routines += sys_getrusage
endif
