ifeq ($(DEB_HOST_GNU_SYSTEM),linux)
  libc = libc6
  # alpha-linux uses 6.1 as libc's soname
  ifeq ($(DEB_HOST_GNU_CPU),alpha)
    libc = libc6.1
  endif
  ifeq ($(DEB_HOST_GNU_CPU),ia64)
    libc = libc6.1
  endif
endif

ifeq ($(DEB_HOST_GNU_SYSTEM),gnu)
  # libc0.3 for gnu
  libc = libc0.3
endif

ifeq ($(DEB_HOST_GNU_SYSTEM),kfreebsd-gnu)
  libc = libc0.1
endif

ifeq ($(DEB_HOST_GNU_SYSTEM),knetbsd-gnu)
  libc = libc1
endif
