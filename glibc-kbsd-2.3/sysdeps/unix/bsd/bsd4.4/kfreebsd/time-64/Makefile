# Particular system calls:

ifeq ($(subdir),misc)
sysdep_routines += sys_select sys_utimes sys_lutimes sys_futimes
endif

ifeq ($(subdir),posix)
sysdep_routines += sys_nanosleep sys_sched_rr_gi
endif

ifeq ($(subdir),time)
sysdep_routines += \
 sys_adjtime sys_gettimeofday sys_settimeofday \
 sys_getitimer sys_setitimer
endif

ifeq ($(subdir),resource)
sysdep_routines += sys_getrusage
endif
