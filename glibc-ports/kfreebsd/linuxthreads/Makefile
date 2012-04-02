ifeq ($(subdir),linuxthreads)
sysdep_routines += register-atfork unregister-atfork
libpthread-routines += ptw-sigprocmask ptw-ioctl
endif

ifeq ($(subdir),rt)
librt-sysdep_routines += timer_routines
endif
