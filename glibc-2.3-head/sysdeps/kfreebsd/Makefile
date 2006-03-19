# Use bash, not /bin/sh, for executing scripts, because the native
# FreeBSD /bin/sh does not interpret the  IFS="<tab>" read ...  command
# in localedata/tst-fmon.sh correctly.
SHELL = bash

# Additional header files to be installed in $prefix/include:

ifeq ($(subdir),misc)
sysdep_headers += \
 sys/ktrace.h \
 sys/mount.h \
 sys/rfork.h
endif

ifeq ($(subdir),stdlib)
sysdep_headers += \
 bits/mcontext.h
endif

# Additional functions, and particular system calls:

ifeq ($(subdir),csu)
# For <errno.h>.
sysdep_routines += errno-loc
endif

ifeq ($(subdir),io)
# For <unistd.h>.
sysdep_routines += sys_getcwd sys_lseek
# For <fcntl.h>.
sysdep_routines += sys_open
# For <sys/stat.h>.
sysdep_routines += sys_fstat sys_lstat sys_mknod sys_nfstat sys_nlstat sys_nstat sys_stat
# For <sys/statfs.h>.
sysdep_routines += fstatfs64 statfs64 sys_fstatfs sys_statfs   
# Other.
sysdep_routines += lchmod
endif

ifeq ($(subdir),dirent)
# For <dirent.h>.
sysdep_routines += sys_getdents sys_getdirentries getdirentries getdirentries64
endif

ifeq ($(subdir),misc)
# For <sched.h>.
sysdep_routines += clone start_thread
# For <unistd.h>.
sysdep_routines += sys_ftruncate sys_truncate
# For <sys/acl.h>.
sysdep_routines += acl_aclcheck_fd acl_aclcheck_file acl_delete_fd acl_delete_file acl_get_fd acl_get_file acl_set_fd acl_set_file
# For <sys/extattr.h>.
sysdep_routines += extattrctl extattr_delete_file extattr_get_file extattr_set_file
# For <sys/jail.h>.
sysdep_routines += jail
# For <sys/ktrace.h>.
sysdep_routines += ktrace utrace
# For <sys/linker.h>.
sysdep_routines += kldfind kldfirstmod kldload kldnext kldstat kldsym kldunload kldunloadf
# For <sys/mman.h>.
sysdep_routines += minherit sys_mmap
# For <sys/mount.h>.
sysdep_routines += fhopen sys_fhstat sys_fhstatfs fhstat fhstat64 fhstatfs fhstatfs64 getfh getfsstat getfsstat64 sys_getfsstat getmntinfo getmntinfo64 mount nmount unmount
# For <sys/ptrace.h>.
sysdep_routines += sys_ptrace
# For <sys/rfork.h>.
sysdep_routines += rfork
# For <sys/rtprio.h>.
sysdep_routines += rtprio
# For <sys/socket.h>.
sysdep_routines += bsd_sendfile
# For <sys/sysctl.h>.
sysdep_routines += sysctl sysctlbyname
# For <sys/uio.h>.
sysdep_routines += sys_readv sys_writev
# Other.
sysdep_routines += swapon swapoff sys_aio_cancel sys_aio_error sys_aio_read sys_aio_return sys_aio_suspend sys_aio_waitcomplete sys_aio_write sys_lio_listio issetugid modfind modfnext modnext modstat obreak quotactl rfork sysarch undelete yield
# for INLINE_SYSCALL
sysdep_routines += sys_fork sys_execve sys_sigaction sys_close sys_fcntl
sysdep_routines += sys_clock_getres sys_clock_gettime sys_clock_settime
endif

ifeq ($(subdir),posix)
# For <unistd.h>.
sysdep_routines += sys_getlogin sys_pread sys_pwrite sys_setlogin sys_read sys_write
endif

ifeq ($(subdir),inet)
sysdep_headers += net/ethernet.h net/if_ether.h
endif

ifeq ($(subdir),time)
# For <sys/timex.h>.
sysdep_routines += ntp_adjtime ntp_gettime
endif

ifeq ($(subdir),socket)
sysdep_routines += sa_len sys_bind sys_connect sys_sendto
endif

# Linuxthreads dependencies.

ifeq ($(subdir),posix)
sysdep_headers += bits/initspin.h
endif

# Don't compile the ctype glue code, since we have a much better <ctype.h>
# than the old non-GNU C library.
inhibit-glue = yes

# Special ELF hacks.
ifeq ($(subdir),elf)

sysdep-rtld-routines += dl-brk dl-sbrk

endif
